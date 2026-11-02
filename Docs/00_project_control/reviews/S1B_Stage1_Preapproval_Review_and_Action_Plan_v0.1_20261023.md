# S1-B Stage 1事前承認レビュー・次アクション計画 v0.1

- プロジェクト：定型メール作成ツール
- 作成日：2026-10-23（JST）
- Status：**Review Complete / Stage 1 NOT APPROVED**
- 現在地：`STAGE1_PRECHECK_READY`（Codex報告）
- Evidence分類：`CODEX_REPORTED_VERIFIED`／`USER_PROVIDED_OS_OUTPUT`／`UNKNOWN`を混同しない

## 1. レビュー結論

Codexの`STAGE1_PRECHECK_READY`は**Stage 1の承認審査に進める判定**として妥当。Snapshotの保全・ハッシュ・相互参照、USB媒体・Root DACL不変を確認したと報告。SVIの現時点のOwner/DACLと継承保護はCodex通常権限では確認不能で、**変更実行直前にユーザーの管理者PowerShellで独立照合することを必須条件**とする。

現時点で**Stage 1実行は未承認**。Stage 2 Everyone除去、Evidenceコピー、Git書込み、S1-C着手も未承認。

### 補足

- `SVI.before.json`のファイルOwnerがAdministratorsでも、DACLの3主体FullControlとは別の属性であり、今回の報告だけで問題とはしない。
- Runフォルダ内3件（Root, SVI, 実行ガイド）は説明済み。改変・削除しない。
- RootとSVIのDACLは各Snapshotに非公開保管済み。外部にSID/SDDL本文を共有しない。
- SVIの`AreAccessRulesProtected=True`は親ACEの通常継承伝播を防ぐが、OS動作全体の無影響保証ではない。

## 2. 現在の承認境界

| Gate | 内容 | 状態 |
|---|---|---|
| G-PREP | Root/SVI Snapshot永続退避・整合性 | Codex報告上完了 |
| G-SVI | 直前のSVI Owner/DACL/継承保護照合 | **未実施（次）** |
| G-ACL-1 | USBルートに承認3主体のACE追加のみ | **未承認** |
| G-ACL-1-POST | RootはEveryone含む4主体、SVI不変 | 未実施 |
| G-ACL-2 | USBルートEveryone Allow除去 | **別承認** |
| G-ARCHIVE | Backupディレクトリ・Evidenceコピー等 | **未承認** |

## 3. 次の作業順序

1. `Test-SVI-SnapshotPreStage1.ps1`を**非公開Scriptsフォルダ**へ配置（これ自体は既存Snapshotの変更ではない）。スクリプト内容・ハッシュを確認する。運用環境では未実行・未検証である。
2. USB接続・BitLocker解除後、**ユーザーが管理者PowerShellでRead-onlyチェックのみを実施**。Root/SVIの保存済みSnapshotと現在のACL/Ownerおよび媒体情報を照合する。`SVI_PRESTAGE1_READONLY_PASS`以外は停止。秘密値はチャットへ出さない。
3. 結果をユーザー/ChatGPTがレビューし、**G-ACL-1だけの明示的承認**を行うか判断。成功から時間が空いた場合・USB再接続後は、実行直前に再確認する。
4. 明示承認後にのみ、通常ユーザー権限のCodexが媒体・固定SID・Root ACL/Owner・Snapshot退避を再照合し、USBルートへ通常ユーザー/SYSTEM/AdministratorsのACEを**追加するだけ**のStage 1を実行する。`Everyone`は削除しない。`/T`、`/reset`、所有権取得は禁止。
5. Codexはroot ACEが「4主体（既存Everyone＋追加3主体）」で期待どおりか、Owner・ディスク・直下項目が不変かを確認して**停止**。SVIについては管理者による実行後Read-only照合までStage 1完了を主張しない。
6. ユーザーが管理者PowerShellでSVIの継承保護・Owner/DACLを**同じSVI Snapshot**と比較。差分・取得失敗の場合は**Stage 2へ進まない**。手動修復・再設定は別承認。
7. Stage 1最終レビュー後に、**別ゲートでG-ACL-2（Everyone除去）**を判断。Stage 2後にもSVI比較を行う。

## 4. Read-onlyチェックの実行例

管理者Windows PowerShell 5.1で実行（署名ポリシーを無断変更しない）。以下の`<NORMAL_USER_PROFILE>`は実際の通常ユーザープロファイル絶対パスへ置換する。

```powershell
& '<NORMAL_USER_PROFILE>\PrivateEvidenceArchive\MailGenerator\Scripts\Test-SVI-SnapshotPreStage1.ps1' `
  -RootSnapshotPath '<NORMAL_USER_PROFILE>\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a\Root.before.json'
```

成功時の期待Resultは`SVI_PRESTAGE1_READONLY_PASS`、`Stage1Authorized=False`。これは**変更の実行権限ではない**。エラー時は停止し、Root/SVI Snapshotを再作成・上書きしない。

### スクリプトの注意

- 新しい`Test-SVI-SnapshotPreStage1.ps1`は**本会話で作成した参考実装で、Windows実機での実行検証はまだ行っていない**。失敗時は読み取り結果と停止箇所をレビューする。
- Windowsでの取得前後の`Get-Acl`情報を比較し、原文を表示せずTrue/Falseだけを出力する。
- スクリプト自体は読み取り専用。保存操作・`Set-Acl`・`icacls`を含めない。

## 5. Stage 1向けCodex指示に含める必須制約（後日承認時）

- `G-ACL-1`の明示承認がない場合は**実行不可**。
- 非昇格セッションのSIDを固定されたNormalUserSidと照合し、不一致なら停止。
- 媒体をドライブ文字だけで決めず、識別情報一式を照合。
- Root現在値＝`Root.before.json`、SVI直前照合PASS、永続退避2件のSHA一致が前提。
- `icacls /grant:r`で3主体追加のみ。`Everyone`への変更なし。
- 実行後のACE/Owner/継承確認を報告。`Stage1Applied`と`Stage1FinalVerified`を区別する。
- Stage 1後の管理者SVI照合前にStage 2へ進むことは禁止。
- エラー時は変更を止め、無断の自動復旧、ACLリセット・所有権取得・管理者昇格を行わない。

## 6. 保存先案

- 実行用スクリプト：`<NORMAL_USER_PROFILE>\PrivateEvidenceArchive\MailGenerator\Scripts\`
- Root/SVI Snapshot：既存の`<NORMAL_USER_PROFILE>\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a\`に保持（変更禁止）
- Project Control計画書：個人実パスを除去した版のみRepositoryの`Docs/00_project_control/`を推奨。今回のファイルはプレースホルダ形式。Public Gitの現ローカル履歴のPush禁止は維持し、SID/SDDL等の秘密値をRepositoryへ含めない。

## 7. Summary / まとめ

**日本語：** Snapshotの保全と相互整合性は成立。次はユーザーによるSVI現在状態のRead-only照合。Stage 1は別途承認後に3主体の追加のみを実行し、必ず停止・再レビューする。

**English:** The snapshots are saved and match. Next, check the current SVI access rules in read-only mode. Stage 1 needs separate approval and must add only three access entries.
