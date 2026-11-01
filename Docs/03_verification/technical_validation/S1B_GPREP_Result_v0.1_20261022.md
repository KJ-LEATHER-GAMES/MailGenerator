# G-PREP実施結果

**最終判定：`G_PREP_COMPLETE`**

承認されたRoot Snapshotの永続退避・読み戻し検証を完了しました。**SVI Snapshotはユーザー取得待ちです。ACL変更には進んでいません。**

## 1. 作成前確認

すべてPASSでした。

- USB：`MG_EVIDENCE_BK`／NTFS／ELECOM USB／Disk 1。容量・パーティション情報も前回と一致。
- 非昇格セッションの通常ユーザーSIDとUSBルートOwnerが一致。
- ルートDACL・継承状態は前回から変更なし。
- 退避先はRepository・登録済みOneDrive範囲外、通常共有なし。
- 既存親のACLは通常ユーザー・SYSTEM・AdministratorsのFullControlのみ。
- Primaryは空のまま。

管理共有に関する既知の残留リスクは解消・受容済みとは扱っていません。

## 2. 作成・保存結果

通常ユーザーのプロファイル配下に、以下を作成しました。

```text
PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\
└─ G-PREP-20261022T143534Z-21b5c43a\
   └─ Root.before.json
```

退避用コンテナとRunフォルダを新規作成し、保存ファイルは**1件だけ**です。

| 検証項目                  | 結果                  |
| --------------------- | ------------------- |
| Run・ファイルのアクセス制御       | 承認3主体のFullControlのみ |
| JSON読み戻し              | PASS                |
| 固定SID・Owner・DACL・継承状態 | 取得値／現在値と一致          |
| 媒体情報                  | 一致                  |
| サイズ                   | 1,489 bytes         |
| 生成時／保存後SHA-256        | 一致                  |

`Root.before.json`のSHA-256：

```text
b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847
```

検証日時：2026-10-22 23:38 JST。SID・SDDL原文は表示していません。

## 3. SVI Snapshotのユーザー実施手順

以下は**ユーザーが管理者PowerShellで実施するための手順**です。Codexは実行していません。

管理者アカウントの`%USERPROFILE%`を保存先として使わず、**今回作成した通常ユーザー側の`Root.before.json`**を指定してください。

実施前にUSBを再識別し、今回と一致することを確認します。その後、次のコードで取得・新規保存できます。上書き・ACL変更・再帰走査は行いません。

```powershell
$ErrorActionPreference = 'Stop'

function Get-TextSha256([string]$text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        ([BitConverter]::ToString(
            $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text))
        )).Replace('-', '').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

# 通常ユーザー側の今回のファイルを指定する
$snapshotFile = Read-Host 'Root.before.jsonの絶対パス'
$expectedHash = 'b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847'

if ((Get-FileHash -LiteralPath $snapshotFile).Hash.ToLowerInvariant() -ne $expectedHash) {
    throw 'Root Snapshotのハッシュ不一致'
}

$rootRecord = Get-Content -LiteralPath $snapshotFile -Raw | ConvertFrom-Json
$runDirectory = Split-Path -Parent $snapshotFile
$outputFile = Join-Path $runDirectory 'SVI.before.json'

if (Test-Path -LiteralPath $outputFile) {
    throw 'SVI.before.jsonが既存：上書きしない'
}

# ドライブ文字ではなくラベルから再検出
$volumes = @(Get-CimInstance Win32_LogicalDisk |
    Where-Object VolumeName -eq $rootRecord.Volume.Label)
if ($volumes.Count -ne 1) { throw 'USB未検出または複数候補' }
$volume = $volumes[0]

$partitions = @(Get-CimAssociatedInstance -InputObject $volume `
    -Association Win32_LogicalDiskToPartition)
if ($partitions.Count -ne 1) { throw 'パーティション対応が不明' }

$device = Get-CimInstance Win32_DiskDrive `
    -Filter ("Index=" + $partitions[0].DiskIndex) `
    -Property Index,Model,InterfaceType

if ($volume.FileSystem -ne $rootRecord.Volume.FileSystem -or
    $volume.Size -ne $rootRecord.Volume.VolumeBytes -or
    $partitions[0].StartingOffset -ne $rootRecord.Volume.PartitionOffset -or
    $partitions[0].Size -ne $rootRecord.Volume.PartitionBytes -or
    $device.Model -ne $rootRecord.Volume.Model -or
    $device.InterfaceType -ne 'USB') {
    throw 'USB媒体情報の不一致'
}

$usbRoot = $volume.DeviceID + '\'
$rootNow = Get-Acl -LiteralPath $usbRoot
if ($rootNow.GetOwner([Security.Principal.SecurityIdentifier]).Value -ne
        $rootRecord.NormalUserSid -or
    $rootNow.GetSecurityDescriptorSddlForm(
        [Security.AccessControl.AccessControlSections]::Access
    ) -ne $rootRecord.DaclSddl) {
    throw 'USBルートのOwnerまたはDACLが変化'
}

$svi = Get-Acl -LiteralPath (
    Join-Path $usbRoot 'System Volume Information'
) -ErrorAction Stop

if (-not $svi.AreAccessRulesProtected) {
    throw 'SVIの継承保護が無効：停止'
}

$sviDacl = $svi.GetSecurityDescriptorSddlForm(
    [Security.AccessControl.AccessControlSections]::Access
)
$sviRecord = [ordered]@{
    SchemaVersion           = '1.0'
    RunId                   = $rootRecord.RunId
    EvidenceClassification  = 'USER_PROVIDED_OS_OUTPUT'
    CapturedAt              = (Get-Date).ToString('o')
    RootSnapshotSHA256      = $expectedHash
    VolumeLabel             = $volume.VolumeName
    DriveLetter             = $volume.DeviceID
    OwnerSid                = $svi.GetOwner(
        [Security.Principal.SecurityIdentifier]
    ).Value
    AreAccessRulesProtected = $svi.AreAccessRulesProtected
    DaclSddl                = $sviDacl
    DaclSddlSha256           = Get-TextSha256 $sviDacl
}

# CreateNew：既存ファイルは上書きしない
$json = ($sviRecord | ConvertTo-Json -Depth 5) + "`n"
$bytes = [Text.Encoding]::UTF8.GetBytes($json)
$expectedFileHash = Get-TextSha256 $json
$stream = [IO.File]::Open(
    $outputFile, [IO.FileMode]::CreateNew,
    [IO.FileAccess]::Write, [IO.FileShare]::None
)
try {
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush($true)
} finally {
    $stream.Dispose()
}

$actualFileHash = (Get-FileHash -LiteralPath $outputFile).Hash.ToLowerInvariant()
if ($actualFileHash -ne $expectedFileHash) {
    throw '保存後ハッシュ不一致：削除・上書きせず停止'
}

$readBack = Get-Content -LiteralPath $outputFile -Raw | ConvertFrom-Json
if ($readBack.DaclSddl -ne $sviDacl -or
    -not $readBack.AreAccessRulesProtected) {
    throw '読み戻し不一致：停止'
}

# SID・SDDL原文は表示しない
[pscustomobject]@{
    Result                  = 'SVI_SNAPSHOT_SAVED'
    RunId                   = $rootRecord.RunId
    AreAccessRulesProtected = $readBack.AreAccessRulesProtected
    FileSHA256              = $actualFileHash
    Bytes                   = (Get-Item -LiteralPath $outputFile).Length
}
```

実行結果として送るのは、最後の**Result・RunId・保護状態・ファイルSHA-256・サイズだけ**で十分です。JSON本文、SID、SDDLは貼り付けないでください。エラー時は上書き・削除・設定変更をせず停止してください。

## 4. 未完了事項・次の承認対象

- `SVI.before.json`のユーザー取得・保存。
- 保存結果、ファイルACL、Root Snapshotとの対応の確認。
- その後、**Stage 1「3主体追加のみ」**の実行可否を別途レビュー・承認。
- Stage 2、Evidenceコピー、S1-Cは引き続き未承認。

今回、USB／SVIのACL・Owner・BitLockerは変更せず、Evidenceコピー・Git操作・Repository変更も行っていません。

**G-PREP完了として停止し、次の承認を待ちます。**
