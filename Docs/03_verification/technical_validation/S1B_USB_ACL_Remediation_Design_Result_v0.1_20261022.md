# S1-B USB ACL Remediation Design

**最終判定：`REVIEW_REQUIRED`**

案Aを第一候補とします。ただし、既存の`System Volume Information`のACLを取得できず、ルート変更による影響を確定できません。**現時点で修正コマンドを実行できる状態とは判定しません。**

調査日時：2026-10-22 22:39～22:44 JST。

## 1. USB媒体の再識別結果

以下は **VERIFIED** です。

| 項目            | 今回の確認結果                       |
| ------------- | ----------------------------- |
| 該当ラベルのボリューム数  | 1件                            |
| 現在のドライブ       | `D:`                          |
| ラベル           | `MG_EVIDENCE_BK`              |
| ファイルシステム      | NTFS                          |
| 容量            | 7,739,863,040 bytes           |
| デバイス          | ELECOM MF-BSU3 USB Device     |
| 接続方式          | USB                           |
| 物理ディスク        | Disk 1                        |
| パーティション       | WMI Index 0（前回のPartition 1相当） |
| パーティション位置・サイズ | 前回値と一致                        |
| Primaryとの対応   | KINGSTON側Disk 0とは別物理ディスク      |

許可された識別情報の組合せは前回と一致しました。シリアル番号原文・PNP情報は要求していません。

BitLockerの提示値は、次のように区別します。

- **USER_PROVIDED_OS_OUTPUT**：FullyEncrypted、100%、Protection On、Unlocked、Aes128、AutoUnlockEnabled=False。
- **USER_ATTESTED**：ドライブ全体暗号化の選択、互換モード。
- 今回Codexによる独立再検証は行っていません。

## 2. 現在のACLと継承状態

| 項目                | 結果                     |
| ----------------- | ---------------------- |
| Owner             | 現在の実行WindowsユーザーとSID一致 |
| 現在の実行             | 管理者トークンではない            |
| Explicit ACE      | 1件                     |
| Inherited ACE     | 0件                     |
| SID／主体            | `S-1-1-0`／Everyone     |
| 種別・権限             | Allow／FullControl      |
| Object Inherit    | 有効                     |
| Container Inherit | 有効                     |
| Inherit Only      | なし                     |
| ACL継承             | 有効                     |
| Deny ACE          | なし                     |

Everyoneの権限には、子の削除・アクセス許可変更も含まれています。Ownerと実行ユーザーの個人SIDは内部照合済みですが、報告では匿名化しています。

修正案で使う固定SIDは以下です。

- SYSTEM：`S-1-5-18`
- Administrators：`S-1-5-32-544`
- 実行ユーザー：実行時のWindowsトークンから取得するSID

## 3. 既存子要素への影響

直下の列挙だけを行いました。

| 直下項目                        | 属性                                     | ACL確認                        |
| --------------------------- | -------------------------------------- | ---------------------------- |
| `System Volume Information` | Directory／Hidden／System、ReparsePointなし | UnauthorizedAccessによりUNKNOWN |

直下項目はこの1件でした。内部列挙・再帰走査・ファイル内容閲覧は行っていません。

重要なのは、**`/T`を付けなくても、継承可能ACEの追加・削除が既存子要素へ自動伝播し得る**点です。子が継承保護されているかによって影響が変わります。[Microsoftの継承伝播仕様](https://learn.microsoft.com/en-us/windows/win32/secauthz/automatic-propagation-of-inheritable-aces)

したがって今回は、次を確定できません。

- OS管理領域の継承保護状態。
- Everyone削除・3主体追加が同領域へ及ぶ範囲。
- 子要素を含めた完全な復旧方法。

## 4. 案A／案Bの比較と推奨案

| 観点           | 案A：USBルート修正  | 案B：Archive子だけ制限 |
| ------------ | ------------ | --------------- |
| ルートの過剰権限     | 解消できる        | 残る              |
| 新規Archiveの継承 | 3主体へ統一しやすい   | 子で個別管理が必要       |
| OS管理領域への影響   | 自動伝播の確認が必要   | ルート変更の影響は避けられる  |
| 削除・改変リスク     | ルート側も制限可能    | ルートの子削除権限等が残る   |
| 推奨           | **条件付き第一候補** | 単独の最終対策としては非推奨  |

案Bで子の内容読取りを制限できても、ルートのFullControlが残るため、Archive全体の保護が十分とは判断しません。子削除権限は内容読取りとは別の権限です。[Microsoftのファイル権限定義](https://learn.microsoft.com/en-us/windows/win32/fileio/file-access-rights-constants)

**推奨：案Aを維持し、OS管理領域への影響確認後に実行可否を判断する。**

## 5. 具体的な変更手順 — NOT EXECUTED

### 対象範囲

- 明示的な変更対象：再識別したUSBルートのDACLのみ。
- 変更しない対象：Owner、BitLocker、共有、原本、Git、Primary。
- `/T`、`/reset`、所有権取得、再帰的な明示変更は使用しない。
- ただし、自動継承による子への波及まで「変更なし」と保証することはできない。

### 操作順

1. 媒体・実行ユーザー・既存ACLを再照合。
2. 変更前DACLと復旧情報を退避。
3. Everyoneを残したまま、承認3主体を追加。
4. 追加結果と子への影響を検証。
5. 問題がない場合だけEveryoneのAllowを除去。
6. 再検証。不一致・エラーなら停止。

以下は**未承認・未実行の候補**です。影響審査と退避が終わるまで実行不可です。
```
# NOT EXECUTED
$ExecutionApproved = $false
if (-not $ExecutionApproved) {
    throw '未承認：OS管理領域への影響審査・退避が必要'
}

$Root = 'D:\'  # 固定使用禁止。実行直前に媒体を再識別する
$currentUserSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# メモリ退避。ファイルには出力しない
$beforeAcl = Get-Acl -LiteralPath $Root
$beforeDacl = $beforeAcl.GetSecurityDescriptorSddlForm(
    [Security.AccessControl.AccessControlSections]::Access
)

# 第1段階：Everyoneを残して3主体を追加
icacls.exe $Root /grant:r `
    "*${currentUserSid}:(OI)(CI)F" `
    '*S-1-5-18:(OI)(CI)F' `
    '*S-1-5-32-544:(OI)(CI)F'

if ($LASTEXITCODE -ne 0) {
    throw '追加失敗：Everyone削除へ進まない'
}
```

**ここで一旦停止し、ルート4主体のACEと影響範囲を検証します。** 検証を通過した場合に限る第2段階候補は以下です。
```
# NOT EXECUTED
$Stage1Reviewed = $false
if (-not $Stage1Reviewed) {
    throw '第1段階の検証未完了'
}

icacls.exe $Root /remove:g '*S-1-1-0'
if ($LASTEXITCODE -ne 0) {
    throw '削除失敗：追加操作せず停止'
}
```

`/grant:r`は対象主体の明示Allowを置換し、`/remove:g`は対象主体のAllowを除去します。EveryoneへのDenyは追加しません。[icacls公式仕様](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls)

必要な権限は、対象のACL読取りとDACL変更権限です。現在のFullControlには含まれますが、子への伝播処理まで成功する保証ではありません。AccessDenied時は昇格・所有権取得をせず停止します。

## 6. 変更前退避・失敗時の復旧計画

### 退避案

- ルートのDACL SDDL、Owner SID、継承設定、媒体識別情報を記録。
- メモリ退避だけではPowerShell終了・PC障害に耐えないため、実行前に**非公開・アクセス制御済み保管先への永続退避**を別途承認。
- OS管理領域へ波及する可能性があるなら、その影響対象の復旧情報も必要。

今回は、ファイル退避も`icacls /save`も実行していません。

### 失敗時

- コマンド失敗、Owner変更、想定外ACE、子への予期しない影響で停止。
- 同じセッションと退避情報を保持し、追加削除・リセット・昇格をしない。
- ルートDACLの復元候補は以下。ただし、復旧操作も追加承認対象です。
```
# NOT EXECUTED：限定復旧案
$restoreAcl = Get-Acl -LiteralPath $Root
$restoreAcl.SetSecurityDescriptorSddlForm(
    $beforeDacl,
    [Security.AccessControl.AccessControlSections]::Access
)
Set-Acl -LiteralPath $Root -AclObject $restoreAcl
```

**ルートDACL復元だけで既存子要素も完全復旧できるとは保証しません。** 復元にも継承伝播の可能性があり、自動Rollbackにはしません。

## 7. 検証方法・残留リスク・UNKNOWN

変更後に確認すべき事項は以下です。

- Ownerが変更されていない。
- ルートのAllowが承認3主体のFullControlのみ。
- Everyone、想定外のAllow／Denyがない。
- OI／CI・継承状態が承認した設計どおり。
- 実行ユーザーのACL読取り・ルート列挙が可能。
- OS管理領域の設定・動作に予期しない影響がない。
- 書込み試験は、別途承認されたテスト対象で実施。

現時点の主要UNKNOWNは、`System Volume Information`のACL・継承保護・変更影響・復旧範囲です。通常のACL確認と、管理者等の特権を含む完全隔離の保証も区別します。

## 8. 最終判定・次回承認対象

**`REVIEW_REQUIRED`**

次は、まず以下を審査することを推奨します。

1. ユーザー側で確認できる`System Volume Information`のOwner・DACL・継承設定のOS出力。
2. 自動伝播を含む変更対象・許容影響範囲。
3. 非公開の退避先と退避ファイル作成。
4. 検証条件、失敗時の停止・限定復旧範囲。
5. 上記確定後の案A実行承認。

今回、ルートDACLの開始・終了ハッシュ、Owner、直下項目、Git HEAD・Working Treeは不変でした。設定変更、ファイル出力、コピー、管理者昇格、秘密値・シリアル番号原文の取得は行っていません。

**修正コマンドは未実行です。ACL修正・原本コピー・S1-Cへ進まず停止します。**
