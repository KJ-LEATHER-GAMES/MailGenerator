#requires -Version 5.1
<#
.SYNOPSIS
  Read-only SVI / USB-root verification immediately before ACL Stage 1 approval.
.DESCRIPTION
  Reads the existing G-PREP Root.before.json and SVI.before.json; verifies their
  fixed hashes, USB identity, unchanged root owner/DACL and SVI owner/DACL.
  Does NOT create files, change permissions, or run icacls.
  The reported PASS is only a read-only precheck, never change authorization.
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
$expectedSviFileSha  = 'f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c'

function Get-TextSha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
}

# SVI ACL inspection may require a user-opened elevated session; never auto-elevate.
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Administrator PowerShell is required to read SVI ACL. No automatic elevation.'
}

$rootFile = Get-Item -LiteralPath $RootSnapshotPath -ErrorAction Stop
if ($rootFile.PSIsContainer -or $rootFile.Name -cne 'Root.before.json') { throw 'Expected original Root.before.json.' }
$runDirectory = Split-Path -Parent $rootFile.FullName
$sviFile = Join-Path $runDirectory 'SVI.before.json'
if (-not (Test-Path -LiteralPath $sviFile -PathType Leaf)) { throw 'SVI.before.json missing.' }

$rootHash = (Get-FileHash -LiteralPath $rootFile.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
$sviHash  = (Get-FileHash -LiteralPath $sviFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($rootHash -ne $expectedRootFileSha -or $sviHash -ne $expectedSviFileSha) {
    throw 'Snapshot file SHA-256 mismatch. STOP; do not overwrite or repair.'
}
$root = Get-Content -LiteralPath $rootFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$svi  = Get-Content -LiteralPath $sviFile -Raw -Encoding UTF8 | ConvertFrom-Json
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
    throw 'Snapshot structure, relationship, DACL hash or run path mismatch.'
}

# Identify target without assuming the drive letter is permanent.
$volumes = @(Get-CimInstance -ClassName Win32_LogicalDisk |
    Where-Object { $_.VolumeName -eq $root.Volume.Label })
if ($volumes.Count -ne 1) { throw 'Volume label missing or ambiguous.' }
$volume = $volumes[0]
$parts = @(Get-CimAssociatedInstance -InputObject $volume -Association Win32_LogicalDiskToPartition)
if ($parts.Count -ne 1) { throw 'Logical disk to partition mapping is ambiguous.' }
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
$rootAcl = Get-Acl -LiteralPath $usbRoot -ErrorAction Stop
if ($rootAcl.GetOwner([Security.Principal.SecurityIdentifier]).Value -ne $root.OwnerSid -or
    $rootAcl.GetSecurityDescriptorSddlForm([Security.AccessControl.AccessControlSections]::Access) -ne $root.DaclSddl -or
    $rootAcl.AreAccessRulesProtected -ne [bool]$root.AreAccessRulesProtected) {
    throw 'USB root Owner / DACL differs from pre-change snapshot.'
}
$children = @(Get-ChildItem -LiteralPath $usbRoot -Force -ErrorAction Stop)
if ($children.Count -ne 1 -or $children[0].Name -ne 'System Volume Information' -or
    (-not $children[0].PSIsContainer) -or
    (($children[0].Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
    throw 'Unexpected root item or reparse point.'
}

$sviAcl = Get-Acl -LiteralPath (Join-Path $usbRoot 'System Volume Information') -ErrorAction Stop
$currentSviDacl = $sviAcl.GetSecurityDescriptorSddlForm([Security.AccessControl.AccessControlSections]::Access)
$currentSviOwner = $sviAcl.GetOwner([Security.Principal.SecurityIdentifier]).Value
if (-not $sviAcl.AreAccessRulesProtected -or
    $currentSviOwner -ne $svi.OwnerSid -or
    $currentSviDacl -ne $svi.DaclSddl -or
    (Get-TextSha256 $currentSviDacl) -ne $svi.DaclSddlSha256) {
    throw 'SVI protection / Owner / DACL differs from the saved SVI snapshot.'
}

# Output only non-sensitive booleans. No files are created.
[pscustomobject]@{
    Result = 'SVI_PRESTAGE1_READONLY_PASS'
    RunId = $expectedRunId
    MediaMatch = $true
    RootBeforeMatch = $true
    SnapshotHashesMatch = $true
    SVIProtected = $true
    SVIOwnerMatch = $true
    SVIDaclMatch = $true
    Stage1Authorized = $false
}
