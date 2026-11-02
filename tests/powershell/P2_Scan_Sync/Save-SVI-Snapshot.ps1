#requires -Version 5.1
<#
.SYNOPSIS
  Capture the pre-remediation SVI owner/DACL as one new private JSON snapshot.
.DESCRIPTION
  Read-only for USB root and SVI security settings; writes only SVI.before.json
  into the previously approved G-PREP rollback directory. No ACL changes.
  Run from an elevated Windows PowerShell session. Never commit snapshots to Git.
.EXAMPLE
  & 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\Scripts\Save-SVI-Snapshot.ps1' -RootSnapshotPath 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a\Root.before.json'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $RootSnapshotPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedRunId = 'G-PREP-20261022T143534Z-21b5c43a'
$expectedRootSha256 = 'b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847'

function Get-TextSha256 {
    param([Parameter(Mandatory = $true)][string] $Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Assert-ThreePrincipalDacl {
    param([Parameter(Mandatory = $true)][string] $Path,
          [Parameter(Mandatory = $true)][string] $NormalUserSid)

    $expected = @($NormalUserSid, 'S-1-5-18', 'S-1-5-32-544')
    $acl = Get-Acl -LiteralPath $Path -ErrorAction Stop
    $actual = @($acl.Access)
    if ($actual.Count -ne 3) {
        throw 'Private rollback directory/file has an unexpected ACE count.'
    }
    $actualSids = @()
    foreach ($ace in $actual) {
        $sid = $ace.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value
        if ($ace.AccessControlType -ne [System.Security.AccessControl.AccessControlType]::Allow -or
            (($ace.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::FullControl) -ne
             [System.Security.AccessControl.FileSystemRights]::FullControl)) {
            throw 'Private rollback directory/file ACL is not restricted to FullControl Allow.'
        }
        $actualSids += $sid
    }
    if (@($actualSids | Sort-Object -Unique).Count -ne 3) {
        throw 'Private rollback directory/file ACL has duplicate or unexpected ACEs.'
    }
    foreach ($sid in $expected) {
        if ($actualSids -notcontains $sid) {
            throw 'Private rollback directory/file ACL has an unexpected principal.'
        }
    }
}

# Administrator access is required for the SVI ACL read. Do not auto-elevate.
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run in a user-opened elevated Windows PowerShell session. No automatic elevation.'
}

# 1. Verify the original G-PREP Root snapshot (never modify it).
$rootFile = Get-Item -LiteralPath $RootSnapshotPath -ErrorAction Stop
if ($rootFile.PSIsContainer -or $rootFile.Name -cne 'Root.before.json') {
    throw 'Specify the original Root.before.json file, not a folder or reference copy.'
}
$rootFileHash = (Get-FileHash -LiteralPath $rootFile.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
if ($rootFileHash -ne $expectedRootSha256) {
    throw 'Original Root.before.json SHA-256 mismatch. No file written.'
}
$rootRecord = Get-Content -LiteralPath $rootFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$runDirectory = Split-Path -Parent $rootFile.FullName
if ($rootRecord.SchemaVersion -ne '1.0' -or $rootRecord.RunId -ne $expectedRunId -or
    ([System.IO.Path]::GetFullPath($runDirectory).TrimEnd('\') -ine
     [System.IO.Path]::GetFullPath([string]$rootRecord.RollbackRunPath).TrimEnd('\')) -or
    $rootRecord.NormalUserSid -ne $rootRecord.OwnerSid -or
    -not $rootRecord.OwnerMatchesNormalUser -or
    [string]$rootRecord.DaclSddlSha256 -ne (Get-TextSha256 ([string]$rootRecord.DaclSddl))) {
    throw 'Original Root snapshot data or rollback path mismatch. No file written.'
}
Assert-ThreePrincipalDacl -Path $runDirectory -NormalUserSid ([string]$rootRecord.NormalUserSid)

$outputFile = Join-Path $runDirectory 'SVI.before.json'
if (Test-Path -LiteralPath $outputFile) {
    throw 'SVI.before.json already exists. Never overwrite it.'
}

# 2. Re-identify the USB without trusting a fixed drive letter.
$volumes = @(Get-CimInstance -ClassName Win32_LogicalDisk |
    Where-Object { $_.VolumeName -eq $rootRecord.Volume.Label })
if ($volumes.Count -ne 1) { throw 'USB label missing or ambiguous. No file written.' }
$volume = $volumes[0]
$partitions = @(Get-CimAssociatedInstance -InputObject $volume -Association Win32_LogicalDiskToPartition)
if ($partitions.Count -ne 1) { throw 'USB partition mapping unknown. No file written.' }
$partition = $partitions[0]
$disk = Get-CimInstance -ClassName Win32_DiskDrive -Filter ("Index=$($partition.DiskIndex)")
if ($null -eq $disk) { throw 'Physical USB disk not found. No file written.' }
if ($volume.FileSystem -ne $rootRecord.Volume.FileSystem -or
    [uint64]$volume.Size -ne [uint64]$rootRecord.Volume.VolumeBytes -or
    [uint64]$partition.StartingOffset -ne [uint64]$rootRecord.Volume.PartitionOffset -or
    [uint64]$partition.Size -ne [uint64]$rootRecord.Volume.PartitionBytes -or
    [int]$partition.DiskIndex -ne [int]$rootRecord.Volume.DiskIndex -or
    [int]$partition.Index -ne [int]$rootRecord.Volume.WmiPartitionIndex -or
    $disk.Model -ne $rootRecord.Volume.Model -or
    $disk.InterfaceType -ne 'USB') {
    throw 'Physical USB identity mismatch. No file written.'
}
$usbRoot = $volume.DeviceID + '\'

# 3. Confirm unchanged root DACL/owner and only the known direct child.
$rootAclNow = Get-Acl -LiteralPath $usbRoot -ErrorAction Stop
$rootOwnerNow = $rootAclNow.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
$rootDaclNow = $rootAclNow.GetSecurityDescriptorSddlForm(
    [System.Security.AccessControl.AccessControlSections]::Access)
if ($rootOwnerNow -ne $rootRecord.OwnerSid -or
    $rootDaclNow -ne $rootRecord.DaclSddl -or
    $rootAclNow.AreAccessRulesProtected -ne [bool]$rootRecord.AreAccessRulesProtected) {
    throw 'USB root owner/DACL changed since G-PREP. No file written.'
}
$directChildren = @(Get-ChildItem -LiteralPath $usbRoot -Force -ErrorAction Stop)
if ($directChildren.Count -ne 1 -or $directChildren[0].Name -ne 'System Volume Information' -or
    (-not $directChildren[0].PSIsContainer) -or
    (($directChildren[0].Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)) {
    throw 'Unexpected USB root item or reparse point. No file written.'
}

# 4. Read (never modify) the protected SVI security descriptor.
$sviPath = Join-Path $usbRoot 'System Volume Information'
$svi = Get-Acl -LiteralPath $sviPath -ErrorAction Stop
if (-not $svi.AreAccessRulesProtected) {
    throw 'SVI DACL is not inheritance-protected. No file written.'
}
$sviDacl = $svi.GetSecurityDescriptorSddlForm(
    [System.Security.AccessControl.AccessControlSections]::Access)
$sviOwnerSid = $svi.GetOwner([System.Security.Principal.SecurityIdentifier]).Value

# 5. Write exactly one new private file, fail closed if it already exists.
$record = [ordered]@{
    SchemaVersion           = '1.0'
    RunId                   = $rootRecord.RunId
    EvidenceClassification  = 'USER_PROVIDED_OS_OUTPUT'
    CapturedAt              = (Get-Date).ToString('o')
    RootSnapshotSHA256      = $expectedRootSha256
    VolumeLabel             = $volume.VolumeName
    DriveLetter             = $volume.DeviceID
    OwnerSid                = $sviOwnerSid
    AreAccessRulesProtected = $svi.AreAccessRulesProtected
    DaclSddl                = $sviDacl
    DaclSddlSha256          = Get-TextSha256 -Text $sviDacl
}
$json = ($record | ConvertTo-Json -Depth 5) + "`n"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
$expectedFileHash = Get-TextSha256 -Text $json
$stream = [System.IO.File]::Open(
    $outputFile,
    [System.IO.FileMode]::CreateNew,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::None)
try {
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush($true)
}
finally {
    $stream.Dispose()
}

# 6. Verify persisted evidence; NEVER delete/overwrite on failure.
$actualFileHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
$readBack = Get-Content -LiteralPath $outputFile -Raw -Encoding UTF8 | ConvertFrom-Json
if ($actualFileHash -ne $expectedFileHash -or
    $readBack.DaclSddl -ne $sviDacl -or
    -not $readBack.AreAccessRulesProtected -or
    $readBack.RunId -ne $expectedRunId -or
    $readBack.RootSnapshotSHA256 -ne $expectedRootSha256) {
    throw 'SVI snapshot read-back/hash mismatch; stop without deletion or overwrite.'
}
Assert-ThreePrincipalDacl -Path $outputFile -NormalUserSid ([string]$rootRecord.NormalUserSid)

# Share only these safe summary fields; keep raw SID/SDDL/JSON private.
[pscustomobject]@{
    Result                  = 'SVI_SNAPSHOT_SAVED'
    RunId                   = $rootRecord.RunId
    AreAccessRulesProtected = $readBack.AreAccessRulesProtected
    FileSHA256              = $actualFileHash
    Bytes                   = (Get-Item -LiteralPath $outputFile).Length
}
