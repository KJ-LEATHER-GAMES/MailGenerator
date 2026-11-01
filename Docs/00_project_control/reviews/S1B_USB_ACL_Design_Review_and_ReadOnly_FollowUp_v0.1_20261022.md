# S1-B USB ACL修正設計レビューと次アクション v0.1

- Project: 定型メール作成ツール（Excel VBA + Outlook Classic）
- Date: 2026-10-22
- Status: Review Proposal / NOT APPROVED FOR CHANGE
- Input: Codex `S1-B USB ACL Remediation Design`（2026-10-22 22:39～22:44 JST）
- Next Gate: SVI ACL Read-only Check → Impact Review → Explicit ACL Change Approval
- Suggested repository location (not saved): `Docs/00_project_control/`

## 1. レビュー結論

Codexの最終判定 `REVIEW_REQUIRED` を維持する。USB媒体再識別、Primaryとの独立性、USBルートのEveryone FullControl確認、案A／案Bの比較は妥当。ルートのACL変更により `System Volume Information`（以下SVI）等へ継承可能ACEが自動伝播する可能性があり、`/T`省略だけでは影響排除を保証できない。

- 選択肢A：USBルートを3主体（通常利用ユーザー／SYSTEM／Administrators）のFullControlにする案。**条件付き第一候補、未承認**。
- 選択肢B：Archive子フォルダだけを保護する案。ルートのEveryone権限、ルートからの子削除・改変リスクが残り、**現行承認条件を満たす最終案とは扱わない**。採用する場合は例外・残留リスクの明示承認が必要。
- BitLocker：ユーザーによる管理者PowerShell OS出力で FullyEncrypted／100%／Protection On／Aes128／AutoUnlockEnabled=False を確認済み。これはCodexの独立確認結果とは区別する。
- Primaryの管理共有に関する残留リスク受容、Evidenceコピー、Index、復元試験、G2は未承認／未実施。

## 2. 実行候補の追加レビュー所見

1. `icacls /grant:r`による第1段階だけでも、継承可能ACEの追加が子へ影響する可能性がある。第1段階も無害な準備操作ではない。
2. ACL操作は不可逆とは限らないが、複数対象への伝播は原子的なトランザクションではない。中途失敗時の部分変更を想定する。
3. ルートDACLのメモリ退避だけでは再起動・セッション終了に耐えない。変更前の非公開・永続的なACL退避と、その保存場所・保護・削除方針は別途承認する。
4. ルートDACLの再設定のみでは、変更前の既存子要素ACLの復元まで保証できない。
5. 昇格に別アカウントを使用する場合、`WindowsIdentity.GetCurrent()` は通常利用ユーザーと異なるSIDになる可能性がある。操作対象ユーザーSIDは別途照合・固定する。
6. SVIのACLがアクセス拒否でも、それだけで継承保護状態は確定しない。アクセス拒否時に所有権取得、権限付与、File Explorerの「続行」操作を行わない。

## 3. 次の作業：ユーザー実行の管理者PowerShellによるRead-only確認

### 実施前提

- 対象はUSB媒体 `MG_EVIDENCE_BK`、前回 `D:`。事前に物理媒体が一致することを確認する。
- BitLockerはユーザー本人が解除した状態とする。パスワード・回復キーを記録しない。
- Windows PowerShell／PowerShellを**管理者として実行**し、以下の**読取り専用**コードのみ実行する。所有権取得や権限変更をしない。
- 出力のうち個人情報に当たり得るSID等は、下記コードで種類だけを表示する。

```powershell
$ErrorActionPreference = 'Stop'
$expectedLabel = 'MG_EVIDENCE_BK'
$volume = Get-Volume -DriveLetter 'D'
if ($volume.FileSystemLabel -ne $expectedLabel -or $volume.FileSystem -ne 'NTFS') {
    throw '媒体のラベルまたはファイルシステムが不一致。中止。'
}

$path = 'D:\System Volume Information'
try {
    $acl = Get-Acl -LiteralPath $path -ErrorAction Stop
    $ownerSid = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
    $currentSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $ownerCategory = switch ($ownerSid) {
        'S-1-5-18' { 'SYSTEM'; break }
        'S-1-5-32-544' { 'Administrators'; break }
        default { if ($ownerSid -eq $currentSid) { 'CurrentElevatedUser' } else { 'Other' } }
    }
    'SVI_ACL_READ=PASS'
    "OwnerCategory=$ownerCategory"
    "DaclInheritanceProtected=$($acl.AreAccessRulesProtected)"
    $rules = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
    foreach ($rule in $rules) {
        $principal = switch ($rule.IdentityReference.Value) {
            'S-1-1-0' { 'Everyone'; break }
            'S-1-5-18' { 'SYSTEM'; break }
            'S-1-5-32-544' { 'Administrators'; break }
            default { if ($rule.IdentityReference.Value -eq $currentSid) { 'CurrentElevatedUser' } else { 'OtherSID' } }
        }
        [pscustomobject]@{
            Principal        = $principal
            Type             = $rule.AccessControlType
            Rights           = $rule.FileSystemRights
            IsInherited      = $rule.IsInherited
            InheritanceFlags = $rule.InheritanceFlags
            PropagationFlags = $rule.PropagationFlags
        }
    }
} catch {
    'SVI_ACL_READ=BLOCKED'
    "ExceptionType=$($_.Exception.GetType().Name)"
    # エラーメッセージの実パスや個人名を共有する必要はない。
}
```

### 期待結果と停止条件

- `SVI_ACL_READ=PASS`：`DaclInheritanceProtected`、OwnerCategory、ACE種別・継承状態を元にCodex/ChatGPTで影響評価する。**PASS自体はACL変更承認ではない**。
- `SVI_ACL_READ=BLOCKED`：そこで終了。所有権取得、特権操作、権限変更、ファイル内容の閲覧を行わない。これ以上の昇格調査を自動反復しない。
- SVI配下や隠しファイルの列挙・書込みは実施しない。

## 4. Read-only確認後のCodex指示（そのまま貼り付け可）

> 定型メール作成ツール S1-B USB ACL Remediation Design の追加レビューをRead-onlyで実施してください。前回の判定は REVIEW_REQUIRED です。管理者PowerShellでユーザーが取得したSVIのACL確認結果を追加Evidenceとして提供します。
>
> 1. 媒体 `MG_EVIDENCE_BK` の確認済み事実とユーザー取得OS出力を、`REPO_VERIFIED`／`USER_PROVIDED_OS_OUTPUT`／`USER_ATTESTED`／`UNKNOWN`に分離する。
> 2. SVIの継承保護状態・既存ACEと、USBルートのEveryone FullControlを3主体へ変更する際の影響を分析する。SVI取得失敗時はUNKNOWNとして残す。
> 3. 案Aの実行前提、既存子への波及、変更前永続ACL退避場所と退避内容、途中失敗時の停止／限定復元手順、通常利用SIDと昇格プロセスSIDの照合を明文化する。
> 4. 変更後検証にSVIの予期しない権限変化や正常動作、BitLocker状態不変、ルート3主体ACL適合の確認を含める。
> 5. SVIを独立確認できない場合は無理に案AをREADYにせず、リスク受容を条件とした代替案（Archive子のみ保護等）の残留リスクと現行承認条件との差異を示す。
> 6. 結果は `READY_FOR_APPROVAL_REVIEW`／`REVIEW_REQUIRED`／`BLOCKED` とし、変更実行の承認を先取りしない。
>
> 禁止：ACL変更、所有権取得、`icacls /grant`／`/remove`／`/reset`／`/T`の実行、BitLocker変更、ファイル／フォルダ作成・削除・コピー、管理者昇格、Git変更、Evidence保全実行、S1-C着手、秘密値・生シリアル番号取得。変更コマンドは提案としてのみ提示する。未承認の書込みはすべて禁止。

## 5. 次の判断フロー

| SVI Read-only確認 | 次の判断 | この時点の許可範囲 |
|---|---|---|
| PASS、継承保護が確認され、影響・退避・限定復元方針に重大な欠落なし | 案Aの実行計画を承認審査へ | 設計レビューのみ |
| PASS、継承が有効または既存子への影響不明 | SVIへの影響・復旧条件を追加検討 | 設計レビューのみ |
| BLOCKED（管理者でも閲覧できず） | 調査ループを停止し、案Aの未確認影響を受容するか代替保護を選ぶか、ユーザーへ判断提示 | 設計レビューのみ |

どの分岐でも、ACL修正、Archiveフォルダ作成、原本5件のコピーを自動実行しない。ACL変更承認後も、Backup保存先の空フォルダ作成・再検査、Primary残留リスク判断、EXECUTE_ARCHIVEを別Gateとする。

## 6. 後続ゲート

1. G-ACL-DESIGN：SVI影響・変更方法・永続退避・限定復元方針の承認
2. G-ACL-EXECUTE：対象／操作の明示承認を受け、別作業でACL変更・検証
3. G-BACKUP-DIR：Backup保存先の空フォルダ作成・実ACL検査
4. G-PRIMARY：Primary管理共有残留リスクの受容／追加措置判断
5. G-PRECHECK：S1-B前提充足を再評価
6. G-ARCHIVE：原本5件のPrimary／Backup保全・復元試験の明示承認
7. S1-C → G2 → S2～S6：Manifest・正式Closure・Baseline整合・P2-05 Completion・CP-P2

## 7. 参考技術資料

- Microsoft Learn: Automatic Propagation of Inheritable ACEs https://learn.microsoft.com/en-us/windows/win32/secauthz/automatic-propagation-of-inheritable-aces
- Microsoft Learn: icacls https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls
- Microsoft Learn: Continue dialog box for folder access / permissions may be modified https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/dont-have-permission-access-folder

## まとめ / Summary

**日本語：** 現在の結論はREVIEW_REQUIRED。次は管理者PowerShellでSVIのACL・継承保護を読取り専用で確認し、その結果で案Aの承認条件を再評価する。ACL変更と原本コピーは未承認のまま。

**English:** The review status is REVIEW_REQUIRED. Next, read the SVI access rules with administrator PowerShell. Review the result before approving any ACL change. Do not change permissions or copy evidence yet.
