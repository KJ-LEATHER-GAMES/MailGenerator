#requires -Version 5.1
<#
.SYNOPSIS
    Read-only verification of USB root Stage 2 and unchanged SVI ACL.
.DESCRIPTION
    Validates existing G-PREP snapshots and the physical USB identity.
    Confirms that Stage 2 left exactly three explicit FullControl ACEs
    (normal user, SYSTEM, Administrators) and removed Everyone, and that the SVI
    owner, protected-DACL flag, and DACL SDDL match SVI.before.json.
    Does not modify files, ACLs, BitLocker, Git, or USB settings.
    Run in an elevated Windows PowerShell 5.1 session started by the user.
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
$expectedRootFileSha = 'b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847'
$expectedSviFileSha = 'f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c'

function Get-TextSha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString(
            $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text))
        )).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

# Never auto-elevate or alter security configuration.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Open Windows PowerShell as Administrator to inspect the SVI ACL. No auto-elevation.'
}

# Read and verify the existing immutable snapshots.
$rootFile = Get-Item -LiteralPath $RootSnapshotPath -ErrorAction Stop
if ($rootFile.PSIsContainer -or $rootFile.Name -cne 'Root.before.json') {
    throw 'Expected an existing Root.before.json file.'
}
$runDirectory = Split-Path -Parent $rootFile.FullName
$sviPath = Join-Path $runDirectory 'SVI.before.json'
if (-not (Test-Path -LiteralPath $sviPath -PathType Leaf)) {
    throw 'SVI.before.json is missing.'
}
$rootHash = (Get-FileHash -LiteralPath $rootFile.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
$sviHash = (Get-FileHash -LiteralPath $sviPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($rootHash -ne $expectedRootFileSha -or $sviHash -ne $expectedSviFileSha) {
    throw 'Snapshot SHA-256 mismatch. STOP without modifying snapshots.'
}
$root = Get-Content -LiteralPath $rootFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$svi = Get-Content -LiteralPath $sviPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($root.SchemaVersion -ne '1.0' -or $svi.SchemaVersion -ne '1.0' -or
    $root.RunId -ne $expectedRunId -or $svi.RunId -ne $expectedRunId -or
    $svi.RootSnapshotSHA256 -ne $expectedRootFileSha -or
    $svi.VolumeLabel -ne $root.Volume.Label -or
    $svi.DriveLetter -ne $root.Volume.DriveLetter -or
    -not [bool]$svi.AreAccessRulesProtected -or
    $root.DaclSddlSha256 -ne (Get-TextSha256 ([string]$root.DaclSddl)) -or
    $svi.DaclSddlSha256 -ne (Get-TextSha256 ([string]$svi.DaclSddl)) -or
    $root.OwnerSid -ne $root.NormalUserSid -or
    ([IO.Path]::GetFullPath($runDirectory).TrimEnd('\') -ine
     [IO.Path]::GetFullPath([string]$root.RollbackRunPath).TrimEnd('\'))) {
    throw 'Snapshot structure, relation, or recorded DACL hash mismatch.'
}

# Re-identify physical media, not by drive letter alone.
$volumes = @(Get-CimInstance -ClassName Win32_LogicalDisk |
    Where-Object { $_.VolumeName -eq $root.Volume.Label })
if ($volumes.Count -ne 1) { throw 'USB volume label is missing or ambiguous.' }
$volume = $volumes[0]
$parts = @(Get-CimAssociatedInstance -InputObject $volume -Association Win32_LogicalDiskToPartition)
if ($parts.Count -ne 1) { throw 'USB partition mapping is ambiguous.' }
$part = $parts[0]
$disk = Get-CimInstance -ClassName Win32_DiskDrive -Filter ("Index=$($part.DiskIndex)")
if ($null -eq $disk -or
    $volume.FileSystem -ne $root.Volume.FileSystem -or
    [uint64]$volume.Size -ne [uint64]$root.Volume.VolumeBytes -or
    [uint64]$part.StartingOffset -ne [uint64]$root.Volume.PartitionOffset -or
    [uint64]$part.Size -ne [uint64]$root.Volume.PartitionBytes -or
    [int]$part.DiskIndex -ne [int]$root.Volume.DiskIndex -or
    [int]$part.Index -ne [int]$root.Volume.WmiPartitionIndex -or
    $disk.Model -ne $root.Volume.Model -or
    $disk.InterfaceType -ne 'USB') {
    throw 'USB physical media identity mismatch.'
}
$usbRoot = $volume.DeviceID + '\'

# Stage 2 root ACL is SUPPOSED to differ from Root.before.json.
$rootAcl = Get-Acl -LiteralPath $usbRoot -ErrorAction Stop
if ($rootAcl.GetOwner([Security.Principal.SecurityIdentifier]).Value -ne $root.OwnerSid -or
    $rootAcl.AreAccessRulesProtected -ne [bool]$root.AreAccessRulesProtected) {
    throw 'USB root Owner or inheritance protection unexpectedly changed.'
}
$expectedSids = @($root.NormalUserSid, 'S-1-5-18', 'S-1-5-32-544')
$rules = @($rootAcl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))
if ($rules.Count -ne 3) { throw 'Stage 2 root ACL does not have exactly three ACEs.' }
$expectedInheritance = [Security.AccessControl.InheritanceFlags]::ContainerInherit -bor
    [Security.AccessControl.InheritanceFlags]::ObjectInherit
foreach ($rule in $rules) {
    $sid = $rule.IdentityReference.Value
    if (($expectedSids -notcontains $sid) -or $rule.IsInherited -or
        $rule.AccessControlType -ne [Security.AccessControl.AccessControlType]::Allow -or
        $rule.FileSystemRights -ne [Security.AccessControl.FileSystemRights]::FullControl -or
        $rule.InheritanceFlags -ne $expectedInheritance -or
        $rule.PropagationFlags -ne [Security.AccessControl.PropagationFlags]::None) {
        throw 'Stage 2 root ACL contains an unexpected ACE or access setting.'
    }
}
foreach ($sid in $expectedSids) {
    if (@($rules | Where-Object { $_.IdentityReference.Value -eq $sid }).Count -ne 1) {
        throw 'Stage 2 root ACL is missing or duplicating an expected trustee.'
    }
}
$children = @(Get-ChildItem -LiteralPath $usbRoot -Force -ErrorAction Stop)
if ($children.Count -ne 1 -or $children[0].Name -ne 'System Volume Information' -or
    (-not $children[0].PSIsContainer) -or
    (($children[0].Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
    throw 'Unexpected USB root child or reparse point.'
}

# Compare only current SVI owner and DACL with the saved SVI snapshot.
$sviAcl = Get-Acl -LiteralPath (Join-Path $usbRoot 'System Volume Information') -ErrorAction Stop
$currentSviDacl = $sviAcl.GetSecurityDescriptorSddlForm(
    [Security.AccessControl.AccessControlSections]::Access
)
$currentSviOwner = $sviAcl.GetOwner([Security.Principal.SecurityIdentifier]).Value
if (-not $sviAcl.AreAccessRulesProtected -or
    $currentSviOwner -ne $svi.OwnerSid -or
    $currentSviDacl -cne $svi.DaclSddl -or
    (Get-TextSha256 $currentSviDacl) -ne $svi.DaclSddlSha256) {
    throw 'SVI protection, Owner, or DACL differs from SVI.before.json.'
}

# No SID, SDDL, personal path, or private information in the output.
[pscustomobject]@{
    Result = 'SVI_POSTSTAGE2_READONLY_PASS'
    RunId = $expectedRunId
    MediaMatch = $true
    SnapshotHashesMatch = $true
    Stage2RootThreeAcesMatch = $true
    RootOwnerUnchanged = $true
    SVIProtected = $true
    SVIOwnerMatch = $true
    SVIDaclMatch = $true
    ArchiveAuthorized = $false
}
