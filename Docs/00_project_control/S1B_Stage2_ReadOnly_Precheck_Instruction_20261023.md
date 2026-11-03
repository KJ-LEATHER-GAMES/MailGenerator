# P2 Evidence Archive S1-B — Stage 2 実行前 Read-only 確認指示

- 日付: 2026-10-23
- 対象: BitLocker USB `MG_EVIDENCE_BK`（前回 `D:`。ドライブ文字は固定とみなさない）
- 開始状態: Stage 1 `STAGE1_VERIFIED`／Stage 2 **未承認・未実施**
- この指示の承認範囲: **Read-only確認のみ**。ACL変更・新規ファイル作成・削除・コピー・Git操作は承認しない。
- 実行主体: Codexは通常ユーザー権限。SVI事後確認はユーザーが管理者PowerShellで別途実行する。

## Codexへの指示（このまま渡せます）

以下を**Read-only**で確認し、結果を報告したら停止してください。失敗時の修復・権限昇格・再試行による状態変更は禁止します。

1. **媒体の再識別**：現在のUSBボリュームをラベルだけでなく前回保存した媒体情報（NTFS、物理ディスク、容量、既存の識別情報）と照合。Primary NVMeとは別物理ディスクであることを確認。ドライブ文字が変わった場合は旧`D:`を操作せず停止し、差分を報告。
2. **BitLocker**：対象USBの`FullyEncrypted`／暗号化率100%／`Protection On`／`Unlocked`をRead-only確認。回復キーやパスワードは取得・表示しない。
3. **Root ACL**：通常ユーザー、`SYSTEM`、`Administrators`、`Everyone (S-1-1-0)`の**4主体のみ**で、各1件のExplicit `Allow`／`FullControl`／`OI,CI`が維持されていることをSID基準で確認。未知のACE、Deny、重複、継承状態変更があれば停止。
4. **Root不変事項**：既存のRoot Owner、Root DACL継承設定、直下項目一覧がStage 1事後記録と一致することを確認。事前SnapshotとStage 1後のRoot状態を混同しない。
5. **既存Snapshot**：非公開Run ID `G-PREP-20261022T143534Z-21b5c43a` の`Root.before.json`／`SVI.before.json`が存在し、上書きされていないことを確認。既知のSHA-256は以下。
   - `Root.before.json`: `b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
   - `SVI.before.json`: `f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
6. **SVIは変更しない**：通常ユーザー権限で`System Volume Information`のACLを取得できない場合、アクセス回避・昇格・継承変更を試みず、`SVI_ADMIN_CHECK_REQUIRED`として報告。
7. **報告・停止**：媒体一致、BitLocker、Root4主体、Owner/継承/直下項目、Snapshot SHAの結果を`PASS / FAIL / UNKNOWN`で簡潔に報告する。識別情報・個人SID・実パス・SDDL等はチャットやPublic Gitへ転載しない。全項目一致なら`CODEX_STAGE2_ROOT_PRECHECK_PASS`、不一致／未確認なら`STOP / REVIEW_REQUIRED`。**確認がPASSでもStage 2を実行しない。**

## ユーザー側のSVI Read-only再確認

既存の `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\Scripts\Test-SVI-SnapshotPostStage1.ps1` を、**以前検証した信頼できるファイルと同一であることを確認**したうえで、管理者PowerShellで再実行してください（新規スクリプト作成不要）。既存スクリプトの内容やSHAが確認できなければ停止してください。Execution Policyの全体変更・組織ポリシー回避は禁止です。

期待する照合結果（前回の出力仕様に基づく）：

- `SVI_POSTSTAGE1_READONLY_PASS`
- `MediaMatch=True`
- `SnapshotHashesMatch=True`
- `Stage1RootFourAcesMatch=True`
- `RootOwnerUnchanged=True`
- `SVIProtected=True`
- `SVIOwnerMatch=True`
- `SVIDaclMatch=True`
- `Stage2Authorized=False` は**現時点では正常**。承認済みの意味ではない。

上記を満たさない場合、Stage 2の承認を行わず停止。

## Stage 2 限定承認ゲート（この文書自体は承認ではない）

`CODEX_STAGE2_ROOT_PRECHECK_PASS` と管理者PowerShellの `SVI_POSTSTAGE1_READONLY_PASS` の**両方**を確認後、ユーザーが別途明示的に承認した場合に限り、次の別工程へ進む。

**次工程の範囲**：識別済みUSBのルート**だけ**にある `Everyone (S-1-1-0)` の既存Explicit Allow ACEを `icacls /remove:g` で1回だけ除去。`/T`、`/reset`、Owner変更、権限追加、SVI変更、昇格、自動Rollbackは禁止。変更したら**直ちに停止**し結果報告。ほかの3主体は変更しない。

Stage 2の成否判定は、CodexによるRoot3主体・Owner・媒体等のRead-only事後照合に加え、ユーザーの管理者PowerShellによる**既存**`Test-SVI-SnapshotPostStage2.ps1`でSVI Owner／DACL／継承保護の不変を確認した後とする。どちらかが未確認・FAILなら`STAGE2_VERIFIED`としない。Rollbackは別承認。

## 非対象

Primary ACL残留リスクの受容判断、Archiveフォルダ作成、原本5件コピー／SHA、復元試験、S1-C／G2、S2〜S6、Git操作、共通運用ルール改訂は本指示の対象外。
