# 引き継ぎまとめ

- **対象プロジェクト**：定型メール作成ツール（Excel VBA + Outlook Classic + OFTテンプレート）
- **引き継ぎ時点**：2026-10-23
- **今回の主題**：P2 Evidence Archive（S1）のBackup Precheck、USBルートACL修正の安全な設計・段階実行、G-PREP Snapshot保全、開発本筋への軌道修正
- **現在地**：**Stage 1は`STAGE1_VERIFIED`**。USBルートには通常ユーザー／SYSTEM／Administrators／Everyoneの4主体がFullControl（Explicit Allow、OI/CI）で存在。**Stage 2（Everyone除去）は未実施・未承認**。次はStage 2の限定承認と実行前再確認。
- **検証の前提**：ユーザー提示のPowerShell実測出力とCodex実行報告に基づく。ChatGPTがユーザーのPC上で直接実行・独立再検証したものではない。`PASS`（技術的な検証）とGate Approval／Formal Closureは区別する。

## 実施内容

### 1. S1-B Backup Precheckと阻害事項の整理

- 前チャットのS0/S1-A/S1-B引継ぎを受け、CodexのRead-only Backup Precheck結果（`BACKUP_PRECHECK_BLOCKED`）をレビュー。
- USB `MG_EVIDENCE_BK`（調査時`D:`、NTFS、ELECOM MF-BSU3 USB Device、約7.74 GB）が、Primaryを格納するKINGSTON NVMeとは**別物理ディスク**であることをCodexが確認。
- USBルートのACLは**Everyone（SID `S-1-1-0`）のExplicit Allow／FullControl／OI・CI**のみ。当初案の3主体制限と不整合だったため是正対象とした。
- Primary空ディレクトリ3階層は作成済みで、通常ユーザー・SYSTEM・AdministratorsのFullControlを報告。ただし、管理共有を介した他主体の実効アクセスは**UNKNOWN**、ユーザーによる残留リスク受容は**未確認**。
- 5件のEvidence原本コピー、Backup側Archive作成、復元試験、S1-C、G2は一切着手していない。

### 2. BitLocker状態を実測確認

- ユーザーがPowerShell `Get-BitLockerVolume -MountPoint 'D:'` を実行し、以下を確認：
  - `VolumeStatus=FullyEncrypted`
  - `EncryptionPercentage=100`
  - `ProtectionStatus=On`
  - `LockStatus=Unlocked`
  - `EncryptionMethod=Aes128`
  - `AutoUnlockEnabled=False`
- 暗号化・保護状態の確認はPASS。ただし「ドライブ全体暗号化を選択」「互換モードを選択」は`USER_ATTESTED`のまま扱う。

### 3. USBルートACL修正方針のRead-only設計

- `Codex_S1B_USB_ACL_Remediation_Design_ReadOnly_Instruction_v0.1_20261022.md` 等を作成・提示し、Codexへ**変更前調査・案比較のみ**を依頼。
- Codex初回判定：`REVIEW_REQUIRED`。ルート直下に`System Volume Information`（以下SVI）だけ存在し、通常権限ではSVIのACLを取得できなかった。
- 案A（USBルートを通常ユーザー・SYSTEM・Administratorsの3主体へ修正）と案B（Archive子フォルダのみ制限）を比較。**案Aを条件付き第一候補**とし、案B単独はルートの過剰権限を残すため推奨しないと評価。
- ユーザーが管理者PowerShellで `(Get-Acl -LiteralPath 'D:\System Volume Information').AreAccessRulesProtected` を実行し、**`True`**を確認。親からのDACL継承に対しSVIが保護される点を追加Evidence（`USER_PROVIDED_OS_OUTPUT`）とした。
- Codex最終設計判定：`REMEDIATION_DESIGN_READY`。**設計READYは変更の実行承認ではない**ことを明確化。
- Stage 1＝3主体のFullControl ACE追加（Everyone維持）、Stage 2＝Everyone Allow ACE除去、の**個別承認／検証方式**を採用。`/T`、`/reset`、Owner変更、管理者昇格、自動Rollbackは禁止。

### 4. G-PREP（変更前Snapshotの永続保全）

- ユーザーがG-PREP限定作業を承認し、Codexが非昇格セッションで次を実施：
  - USB／通常ユーザーSID／Root Owner・DACLを再照合。
  - Privateな既存領域下にRollback用Runフォルダを作成。
  - `Root.before.json`を新規保存、読み戻し・SHA-256照合、ACL 3主体確認。
  - Codex判定：`G_PREP_COMPLETE`（**Root Snapshot側完了**）。
- Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- 保管先：`%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a\`
- `Root.before.json`：1,489 bytes／SHA-256 `b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
- ユーザーが管理者PowerShellで`Save-SVI-Snapshot.ps1`を実行して`SVI.before.json`を新規保存：569 bytes／SHA-256 `f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`。`AreAccessRulesProtected=True`。
- スクリプトの初回起動時はデジタル署名エラー。ユーザーがSHA-256一致を確認し、`Unblock-File`後に正常実行（システム全体のExecution Policyは変更していない）。
- CodexのRead-only最終検証：`STAGE1_PRECHECK_READY`。Root／SVI Snapshotのサイズ・SHA・JSON・相互参照・Run ID・保存先ACLが一致。SVIファイルOwnerはAdministrators、DACLは3主体のみであり、これを区別して評価。Runフォルダ内にSnapshot2件と手順書1件を確認。

### 5. Stage 1実行および事後照合

- ユーザーが管理者PowerShellで`Test-SVI-SnapshotPreStage1.ps1`を実施：`SVI_PRESTAGE1_READONLY_PASS`。媒体、Root、Snapshot SHA、SVI保護／Owner／DACLすべて一致。`Stage1Authorized=False`はRead-onlyスクリプトの正常な固定出力。
- Stage 1のみ明示承認のもとCodexが2026-10-23 20:41:53 JSTに`icacls /grant:r`を**1回だけ**実行、終了コード0。
- 変更後Root ACL：**通常ユーザー／SYSTEM／Administrators／Everyone**の4主体のみ、すべてExplicit Allow／FullControl／OI・CI。Owner、Root継承設定、直下項目、Snapshot SHAは不変。Codex判定：`STAGE1_ROOT_PASS_PENDING_SVI`。
- ユーザーが管理者PowerShellで`Test-SVI-SnapshotPostStage1.ps1`を実行：`SVI_POSTSTAGE1_READONLY_PASS`。`MediaMatch`、`SnapshotHashesMatch`、`Stage1RootFourAcesMatch`、`RootOwnerUnchanged`、`SVIProtected`、`SVIOwnerMatch`、`SVIDaclMatch`がすべて`True`。`Stage2Authorized=False`は正常な未承認表示。
- 以上を受け、**Stage 1を`STAGE1_VERIFIED`として完了判定**。**Stage 2は未実施**。

### 6. 今回作成・参照した主なファイル

- `S1B_Backup_Precheck_Review_and_Next_Action_Plan_v0.1_20261022.md`
- `Codex_S1B_USB_ACL_Remediation_Design_ReadOnly_Instruction_v0.1_20261022.md`
- `S1B_USB_ACL_Design_Review_and_ReadOnly_FollowUp_v0.1_20261022.md`
- `S1B_ACL_Design_Review_GPREP_Action_v0.1_20261022.md`
- `S1B_Stage1_Preapproval_Review_and_Action_Plan_v0.1_20261023.md`
- `SVI_Snapshot_Execution_Guide_v0.1.md`
- `Root.before.json`／`SVI.before.json`：ユーザーPCの**非公開Runフォルダ**に保存。Public Repoへ追加しない。
- `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\Scripts\`：
  - `Save-SVI-Snapshot.ps1`（実行済み）
  - `Test-SVI-SnapshotPreStage1.ps1`（実行済み）
  - `Test-SVI-SnapshotPostStage1.ps1`（実行済み）
  - `Test-SVI-SnapshotPostStage2.ps1`（**作成・提示済み、実行は未実施**）
- `AI_Collab_Development_Issue_Triage_Change_Proposal_v0.1(1).md`（文書表題：**AI協働開発 運用ルール改訂提案 v0.1**）：ユーザーが提示した**他プロジェクト向け改訂提案**。正式運用ルールとして未承認。
- 参照している既存仕様：`MVP Requirements v0.1.9 日本語版.md`、`MVP Design v0.1.9 日本語版.md`、`MVP Test Specification v0.1.5 日本語版.md`、`Implementation Plan v0.3 日本語版(2).md`、`AI協働開発 文書管理・Baseline運用ルール v0.1.md`など。**今回これらのApproved本文を改訂・Baseline更新した事実はない**。

### 7. 本来の開発への軌道修正を検討

- S1のBackup整備が派生課題の連鎖で肥大化しているとの問題提起を受け、**S1完了をバックアップ検討の終了点**とする方針を確認。
- S1の目標Done Whenとして次の4点を整理（**正式Gate条件の変更承認ではなく、作業管理上の目安**）：
  1. Primary／Backupの保存先・アクセス条件の確認（必要な残留リスク判断を含む）。
  2. 原本5件を双方へコピーし、SHA-256一致。
  3. USB Backupから5件を復元し、SHA-256一致。
  4. 既存Archive Manifest更新、G2正式承認。
- 新たな派生課題は`NOW / DEFER / OUT OF SCOPE`で評価する提案を採用方向で整理。ただし**共通運用ルールへの正式反映は「AI協働開発の関連ドキュメント整備」プロジェクトで別途審査**する。
- 具体的な暫定整理：USB Everyone除去・Evidence保全・必要なPrimary判断はNOW、定期自動バックアップ／世代管理はDEFER、新バックアップツール開発はOUT OF SCOPE。Public Repoへの危険なPush禁止は継続。Git履歴整理自体は安全なPushが必要になるまで別途扱う。

## 決定事項

- PrimaryはRepository外の非公開保存先、Backupは独立したBitLocker暗号化USBという既定方針を**維持**。秘密値・生Evidence・個人SID/SDDLなどをPublic Gitへ載せない。
- USBルートACL是正は**案A**（通常ユーザー・SYSTEM・Administratorsの3主体）を採用。Archive子フォルダだけを制限する案B単独は採用しない。
- Stage 1とStage 2は**別々の実行承認**とし、各段階で停止・検証。Stage 1でEveryoneを維持し、Stage 2で除去する。
- **Stage 1は実施・事後検証済み（`STAGE1_VERIFIED`）**。現在は4主体FullControl。**Stage 2、Archive作成、原本コピー、S1-C、Git操作は未承認・未実施**。
- Root／SVIの変更前Snapshotは既存の非公開Runフォルダで維持し、上書きしない。事後比較は保存済み原本を使う。
- `Get-Acl`によるSVI確認が通常権限では拒否されるため、管理者PowerShellによる**Read-only照合**を使用する。SVI Owner／DACL／継承保護の一致を変更後確認の必須条件とする。
- BitLockerの実測確認結果（FullyEncrypted 100%、Protection On、AES-128、AutoUnlock無効）を保持。回復キー／パスワードは共有しない。
- Public GitHubへ、個人パスを含む現ローカルGit履歴を**Pushしない**。Git履歴改変やForce Pushは承認されていない。
- バックアップ方式に関する追加検討は**S1完了で一旦止め、S2〜S6へ復帰する**。S1以外のGate条件は勝手に省略しない。
- 「今対応／後回し／対象外」の観点をこのP2作業の優先順位付けに用いる。**共通Approved運用ルール・Baselineの改訂を今回承認したわけではない**。

## 未解決事項

- **最優先**：Stage 2（USBルートからEveryone Allow ACEを除去）の実施は**未承認／未実施**。実行直前に4主体ACL／媒体／Snapshot／SVI事後確認の鮮度を検証する必要がある。
- Stage 2実行後のSVI Owner／DACL／継承保護の不変照合は未実施。`Test-SVI-SnapshotPostStage2.ps1`は提示済みだが未実行。
- Primary管理共有に関連する他主体の実効アクセスはUNKNOWN。残留リスクのユーザー正式受容か限定追加措置を決める必要あり。
- BackupのArchive用ディレクトリ・`originals`・Private Indexの作成、Primary／Backup双方へのEvidence原本5件コピー、SHA照合、**USB Backupから全5件の復元試験**は未実施。`EXECUTE_ARCHIVE`は未承認。
- `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md` のS1-C更新とG2正式承認は未実施。
- S2：P2-02／P2-03 Regression Records正式Closure。S3：P2-04新CycleとI12 documentary closure。S4：BL-MVP-004 Approvedと`Document_Registry.md`／`Project_Overview.md`・技術文書正本の整合。S5：P2-05 Compile／Static Review S01–S32／Production Patch Review／Final Finding Assessment／Completion。S6：P2 Phase Exit／CP-P2。
- `OBS-P2-05-002`（WordEditorの間欠的`E_FAIL`）は既存判定でOPEN／NON-BLOCKING。別の判断が出るまで勝手にCLOSEDにしない。
- P2技術Regression既存結果：P2-01はPASS／CLOSED、P2-02は111/111 PASS、P2-03は46/46 PASS、P2-04新Cycleは182/182 PASS。**P2-02〜04は技術PASS≠正式Closure**。
- Public GitHubに安全にPushする将来の方法／履歴処理は未決定。Git履歴の自動書換えを行わない。
- `AI協働開発 運用ルール改訂提案 v0.1`の現行Approvedルールとの差分レビュー・正式採否・Version／Baseline影響評価は別プロジェクトで未実施。

## 次アクション

1. **最優先：Stage 2限定実行の事前確認・承認**
   - 参照：直近のCodex用「S1-B USB ACL Remediation Stage 2」限定承認指示案、`Root.before.json`／`SVI.before.json`、Run ID、`SVI_POSTSTAGE1_READONLY_PASS`。
   - USB `MG_EVIDENCE_BK`をBitLocker解除後に再識別。期間が空いた／USB再接続があった場合は、必要に応じて`Test-SVI-SnapshotPostStage1.ps1`で最新のRead-only PASSを取得。
   - ユーザーが**Stage 2のみ**明示承認した場合、Codex通常権限でUSBルートのEveryone Allow ACE (`S-1-1-0`) のみを`icacls /remove:g`で1回除去。`/T`なし。他3主体やOwnerに触れず、結果を報告して**停止**。
2. **Stage 2事後照合・最終判定**
   - Codex：Rootの3主体・Owner／媒体／直下項目不変をRead-only検証。
   - ユーザー：管理者PowerShellで**既存**`Test-SVI-SnapshotPostStage2.ps1`をSHA確認後に実行し、SVI保護／Owner／DACL不変を確認。署名エラー時も組織ポリシーを回避しない。
   - 両者がPASSして初めてStage 2完了を判定。問題があれば停止し、復旧は別承認。
3. **S1-Bの残りを終了**
   - Primaryの管理共有リスクを一度判断（正式受容／必要最小限の措置）。Backup保存先の作成と3主体ACL確認を別承認。
   - `EXECUTE_ARCHIVE`の明示承認後に原本5件を再ハッシュし、PrimaryとBackupへ保存・SHA照合。USB Backupから別試験場所へ全5件復元してSHA照合。
4. **S1-C→G2でバックアップ作業を打ち切る**
   - 既存Manifestを必要な範囲だけ更新。Private LocatorとPublic側表示を分離し、個人実パス／生ログをPublic Gitに記録しない。
   - ユーザーがG2正式承認したらS1を終了。バックアップ自動化・世代管理などは必要な再評価トリガーまで保留。
5. **元のP2へ復帰**
   - S2→S3→S4→S5→S6を順に進め、`CP-P2`確立後にP3（Configuration／UserForm等）へ進む。
   - 新しい課題はGateへの必要性を評価し、**NOW／DEFER／OUT OF SCOPE**を暫定的に使う。記録は既存文書で済ませ、新規文書・新規検証を自動追加しない。

### 次チャット冒頭で使う再開文

> 定型メール作成ツールのP2 Evidence Archive S1-Bを再開します。USB `MG_EVIDENCE_BK`のBitLockerはOS実測でFullyEncrypted 100%／Protection On。USBルートACL是正のStage 1（通常ユーザー・SYSTEM・Administrators追加）は2026-10-23に1回実施し、管理者PowerShellによるSVI事後照合もPASS、`STAGE1_VERIFIED`です。USBルートにはEveryoneを含む4主体が残っています。**Stage 2（Everyone除去）は未実施・未承認**。次はStage 2の限定承認と実行前Read-only確認です。Root／SVI Snapshotは既存の非公開Runフォルダにあり、S1 Evidence 5件のコピーやG2は未実施。S1完了でバックアップ検討を終了し、S2〜S6のP2 Closure・P2-05 Completionへ戻す方針で、必要最小限の対応をお願いします。
