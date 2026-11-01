# Codexのレビュー結果を共有します。

# S1-B USB ACL Remediation Design 最終レビュー

**最終判定：`REMEDIATION_DESIGN_READY`**

案Aを**設計として採用可能**と判断します。ただし、実行直前の確認・永続退避・段階承認が条件です。**今回の判定はACL変更の実行承認ではありません。**

調査日時：2026-10-22 23:12～23:15 JST。

## 1. 追加Evidenceで解消した不確実性

SVIの`AreAccessRulesProtected=True`を、**USER_PROVIDED_OS_OUTPUT**として受け入れます。Codexによる独立確認には格上げしません。

継承保護されたDACLは、通常の親からの継承変更から保護されます。このため、前回の主要懸念だった「ルート変更がSVIのDACLへ継承される可能性」は、**保護状態が実行時も維持されることを条件に解消**できます。[Microsoftの継承仕様](https://learn.microsoft.com/en-us/windows/win32/secauthz/automatic-propagation-of-inheritable-aces)

ただし、SVIのDACL全体や変更前後の一致は、まだ確認されていません。

### 今回の再確認事実：VERIFIED

- `MG_EVIDENCE_BK`は1件、現在`D:`、NTFS。
- 容量・パーティション位置・モデル・USB接続が前回値と一致。
- Disk 1、ELECOM MF-BSU3 USB Device。
- Ownerは通常実行ユーザーと一致。
- ルートACLはEveryoneのExplicit Allow／FullControl、OI・CIありの1件。
- 直下は`System Volume Information`だけ。再帰調査なし。
- 調査開始・終了でルートDACLハッシュ、Owner、直下項目は不変。

## 2. 案Aの採否と影響評価

**案Aを採用します。案B単独は推奨しません。**

| 対象            | 想定する影響                                                   |
| ------------- | -------------------------------------------------------- |
| USBルート        | Everyoneを除去し、通常ユーザー・SYSTEM・AdministratorsのFullControlへ変更 |
| SVI           | 継承保護が維持されれば、通常の継承変更によるDACL変更は想定しない                       |
| 将来作成するArchive | 承認3主体を継承する設計                                             |
| その他の既存子要素     | 現在は検出なし。実行直前に増えていたら停止                                    |

SVI保護は、OS動作全体の無影響保証ではありません。**SVIの変更前後比較を成功条件に含めます。**

## 3. 修正対象・コマンド案・実行権限

### 変更範囲

変更対象は、再識別したUSBルートの**DACLのみ**です。

Owner、SVI、BitLocker、共有、Primaryは変更しません。`/T`、`/reset`、所有権取得、EveryoneへのDeny追加は使用しません。

### SID取り違え防止

1. **通常利用ユーザーの非昇格セッション**でSIDを取得して固定する。
2. USBルートOwner・Primary Ownerとの一致を確認する。
3. 固定したSIDを退避記録と実行計画へ保存する。
4. ACL変更セッションのSIDが固定SIDと異なる場合は停止する。

**管理者セッションの`GetCurrent()`から、通常ユーザーのSIDを自動決定してはいけません。** SVI確認はユーザーの管理者セッション、ACL変更は通常ユーザーのセッションに分離する設計を推奨します。

現在のルートFullControlにはDACL変更権限が含まれます。通常権限で失敗した場合は、昇格・所有権取得をせず停止します。

### 第1段階：3主体を追加 — NOT EXECUTED

以下は条件付きのコマンド案です。媒体再識別、永続退避、SVI事前確認を済ませ、別途承認された場合だけ使用します。
```
# NOT EXECUTED
$Stage1Approved = $false
if (-not $Stage1Approved) { throw '第1段階は未承認' }

$Root = 'D:\'  # 実行直前の媒体再識別で確定する
$ApprovedNormalUserSid = '<事前に固定・承認した通常ユーザーSID>'

$executionSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
if ($executionSid -ne $ApprovedNormalUserSid) {
    throw '実行アカウント相違：SIDを自動置換しない'
}

icacls.exe $Root /grant:r `
    "*${ApprovedNormalUserSid}:(OI)(CI)F" `
    '*S-1-5-18:(OI)(CI)F' `
    '*S-1-5-32-544:(OI)(CI)F'

if ($LASTEXITCODE -ne 0) { throw '追加失敗：停止' }
```

ここで停止し、**Everyoneを含む想定4主体のACE、Owner不変、SVI不変**を検証します。

### 第2段階：Everyoneを除去 — NOT EXECUTED

第1段階の結果を確認・承認した後の別操作です。
```
# NOT EXECUTED
$Stage2Approved = $false
if (-not $Stage2Approved) { throw '第2段階は未承認' }

icacls.exe $Root /remove:g '*S-1-1-0'
if ($LASTEXITCODE -ne 0) { throw '除去失敗：停止' }
```

最終期待値は、承認3主体のExplicit Allow／FullControl、OI・CIありです。[icacls公式仕様](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls)

## 4. 永続退避・復旧手順

### 退避先候補
```
<NORMAL_USER_PROFILE>\PrivateEvidenceArchive\MailGenerator\
  ACL_Remediation_Rollback\<一意なRun ID>\
```

USB・Repository・Evidence保全セットとは分離します。

今回、候補は未作成で、既存親には通常ユーザー・SYSTEM・AdministratorsのFullControlだけが継承されていることを確認しました。**採用・新規作成・ファイル保存は次回の承認対象**です。既知の管理共有に関する残留リスクも審査対象に残します。

### 保存する情報

| ファイル案              | 内容                                                 |
| ------------------ | -------------------------------------------------- |
| `Root.before.json` | 媒体識別情報、固定した通常ユーザーSID、Owner SID、DACL SDDL、継承設定、取得日時 |
| `SVI.before.json`  | ユーザー取得のOwner SID、DACL SDDL、継承保護状態、取得日時             |
| 検証記録               | 各ファイルのSHA-256、第1・第2段階の結果                           |

上書き禁止の新規保存とし、保存後に読み戻して取得値との一致・SHA-256を確認します。個人SID等を含むためPublic Gitには保存しません。SVI情報はユーザーが取得し、保護された退避先へ保存する方式です。

**メモリ退避だけでは実行に進みません。**

### 復旧方針

- エラー・検証不一致時は即停止し、記録とセッションを保持。
- 媒体と退避ファイルのハッシュを確認してから、承認された場合だけルートDACLを復元。
- OwnerやSVIの変更は、ルート復旧に含めない。
- SVIに差分があれば、自動修復せず追加審査。

限定復旧のコマンド案：
```
# NOT EXECUTED：別途承認されたルートDACL復旧のみ
$before = Get-Content -LiteralPath $ApprovedRootSnapshot -Raw |
    ConvertFrom-Json

$restoreAcl = Get-Acl -LiteralPath $Root
$restoreAcl.SetSecurityDescriptorSddlForm(
    $before.DaclSddl,
    [Security.AccessControl.AccessControlSections]::Access
)
Set-Acl -LiteralPath $Root -AclObject $restoreAcl
```

復元後もOwner・DACL・継承設定・SVIを再確認します。**自動Rollbackや無条件の完全復旧保証にはしません。**

## 5. 修正前後の検証方法

### SVI：ユーザー実施

同じ媒体に対し、変更前・第1段階後・第2段階後に、以下だけを取得します。
```
# ユーザーによるRead-only確認案
$svi = Get-Acl -LiteralPath 'D:\System Volume Information' -ErrorAction Stop
$sviOwnerSid = $svi.GetOwner(
    [Security.Principal.SecurityIdentifier]
).Value
$sviDaclSddl = $svi.GetSecurityDescriptorSddlForm(
    [Security.AccessControl.AccessControlSections]::Access
)
$sviProtected = $svi.AreAccessRulesProtected
```

- `AreAccessRulesProtected=True`が継続。
- Owner SIDが一致。
- DACL SDDLが一致。比較用にUTF-8表現のSHA-256も記録。
- 生のSID・SDDLは非公開退避先で保持し、チャットには必要最小限の比較結果だけを提示。

内部ファイルの列挙・内容確認は不要です。

### ルート：各段階で確認

| 時点          | 必須確認                              |
| ----------- | --------------------------------- |
| 変更前         | 既知ACL、Owner、媒体、直下項目、退避完了、SVI保護    |
| 3主体追加後      | 想定4主体、通常ユーザーの権限維持、Owner・SVI不変     |
| Everyone除去後 | 承認3主体のみ、OI・CI、Owner・SVI不変、ルート列挙可能 |

書込み試験はファイル作成を伴うため、このACL変更設計に暗黙には含めません。

## 6. 残留リスク・停止条件

次の場合は実行・次段階への移行を停止します。

- 媒体の一致を確認できない。
- 固定した通常ユーザーSID、Owner、実行SIDが整合しない。
- SVI保護がFalse、取得不能、または変更前後でDACL・Ownerに差分。
- 新しい直下項目・ReparsePoint・想定外ACEが出現。
- 永続退避、読み戻し、ハッシュ確認が未完了。
- コマンドの失敗・部分成功・アクセス喪失。
- BitLockerがロック中、または既知の保護状態と矛盾。

SVI保護とBitLocker状態は引き続きユーザー提供Evidenceです。特権アクセス、将来のOS変更、退避先の管理共有リスクまで解消したとは扱いません。

## 7. 次のユーザー承認事項

次回は段階を分けて承認することを推奨します。

1. **退避準備**：上記退避先の採用、新規Runフォルダ・退避ファイルの作成。
2. **実行前確認**：通常ユーザーSIDの固定、ユーザーによるSVI事前情報取得。
3. **第1段階**：3主体の追加だけを承認し、結果報告後に停止。
4. **第2段階**：第1段階・SVI比較結果をレビュー後、Everyone除去を別途承認。
5. **限定復旧条件**：ルートDACL復旧を実施できる条件と範囲を承認。

**設計はREADYですが、変更・退避ファイル作成・復旧操作は未承認です。** 今回はACL・Owner・ファイル・BitLocker・Repositoryを変更せず、Gitコマンドも実行していません。ACL修正・Evidenceコピー・S1-Cへ進まず停止します。
