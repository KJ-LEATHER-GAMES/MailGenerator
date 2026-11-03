# 定型メール作成ツール — P2 Evidence Archive S1-B
# EXECUTE_ARCHIVE 限定実行指示 v0.1

- **発行日**：2026-10-24（JST）
- **対象**：S1-B Evidence Archive実行（S1-C／G2とは別工程）
- **権限**：ユーザーがチャット上で`EXECUTE_ARCHIVE`の限定実行を明示承認済み
- **実行者**：Codex（既存の許可された通常ユーザー環境を基本とし、無断昇格しない）
- **開始状態**：`ArchivePrecheckDecision: READY`、`RemainingBlockers: []`
- **停止条件**：Archive保全・復元試験の結果を報告した時点、または以下の不一致／未確認が生じた時点

## 1. 最重要の実行境界

今回の承認は、**確定済みの5件を既存のArchive計画に従ってPrimaryとUSB Backupへ保全し、USBからの復元可能性を検証する作業**だけに適用する。

**承認された作業**
1. 実行直前の最小Read-only照合（原本5件、対象媒体、保存先、必要なACL／BitLockerの既存確認と鮮度）。
2. 既存計画で指定済みのArchive関連フォルダを必要な範囲だけ作成（既存ディレクトリを再作成しない）。
3. 既存の正本情報で確定したEvidence原本5件をPrimary／Backup双方へコピーし、サイズ／SHA-256を照合。
4. **USB Backupのコピーを読み出し元として**、承認済みの隔離Restore Test先へ5件を復元し、原本のSHA-256と照合。
5. 既存計画に規定済みの保持・後処理のみ行い、許可された非公開領域に最小限の実行結果／照合Evidenceを記録して停止。

**承認されない作業**
- 原本の編集、移動、削除、置換、上書き。
- 原本、既存のArchive、既存のRestore成果物への無断上書き。
- 既存の承認範囲を超えたディレクトリ／ツール／スクリプト／文書の新設。
- ACL、Owner、継承、共有設定、BitLockerの変更、管理者昇格。
- USB Stage 1／Stage 2の再実行、Rollback、自動修復、自動Retry。
- `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`のS1-C更新、G2承認、Baseline／Approved技術文書の更新。
- Git add／commit／push／履歴変更、Public Repoへの生Evidence・個人実パス・SID・SDDL・秘密値の記録。
- 定期バックアップ、自動化、世代管理などの追加設計。

## 2. 既に確定している条件（再判断しない）

- `STAGE2_VERIFIED`：USB Rootは通常ユーザー／SYSTEM／Administratorsの3主体。Everyone Allowは除去済み。Root／SVI／Snapshot事後検証はPASS。
- Stage 2実行履歴の不整合・総実行回数UNKNOWNは既存文書に記録済み。再調査しない。
- Primary管理共有の限定残留リスクは`ACCEPT_RESIDUAL_RISK / APPROVED_BY_USER`（S1のみ）。管理共有実効アクセス等のUNKNOWNをPASSとはしない。
- 復元試験先と当該領域の限定残留リスクは`APPROVED_BY_USER / ACCEPTED_S1_ONLY`。
- OneDrive Registrationは`UNKNOWN`を維持。網羅調査を新しいGateとして追加しない。
- Final Precheck：原本5件、Primary、媒体識別、別物理ディスク、BitLocker、USB Root ACL、Restore Test先、Archive Plan MappingがPASS／READY、Blocking 0件。
- `Project_Overview.md` v1.62／`Current_Handoff.md` v1.35は**直近のCodex報告上のVersion**。実行開始時に最新の正本を参照し、今回のArchive実行と無関係の改訂はしない。

**基準とする資料**：既存のS1 Archive計画、正本5件の一覧／ハッシュ、非公開Locator／Index情報、既存Manifest Draft、直近Final Precheck報告。**ファイル名・実パス・ハッシュや命名規則を推測で生成しないこと。** 参照できない必須情報があれば変更前に停止。

## 3. 実行直前の停止Gate — READ ONLY

- 原本5件のSourceが既存資料から**一意に特定**でき、全件存在・読取り可能、サイズ／SHA-256が既存の期待値と一致する。
- Primary保存先はRepository外の既定非公開領域であり、直近PASSの構成と整合する。既存の空3階層を尊重する。
- Backupは`MG_EVIDENCE_BK`の同一識別媒体で、NTFS、Primaryとは別物理ディスク。ドライブ文字だけで識別しない。再接続・交換・識別の曖昧さがあれば停止。
- BitLockerは既知の`FullyEncrypted / 100% / Protection On / Unlocked`という最新の確認Evidenceを参照し、実行時点で新しい矛盾・変更がない。通常権限で照会拒否された場合に無断昇格しない。必要な鮮度を確保できなければ停止。
- USB Root ACLが承認された3主体（各1件、Explicit Allow／FullControl／OI・CI、Everyoneなし）である。
- Backupの必要容量と保存先の対応、5件のファイル名衝突、既存ファイルの有無、Restore先の隔離性および既定の保持／削除規則を、変更前に確認する。
- 原本、Primary、Backup、Restore先に衝突・不明点・予期しない既存ファイルがあれば、**上書きせず停止**する。

**全項目一致の場合のみ次へ。Fail/UNKNOWN/不一致が必須前提にあれば `STOP / REVIEW_REQUIRED`。** 事前にPASSした内容の不必要な深掘りや、既定Gateの新設はしない。

## 4. 実行順序（工程ごとに照合・Fail Closed）

### E1 — Archive保存領域の準備

- 既存計画で確定しているPrimary／BackupのArchive関連ディレクトリ（必要な`originals`、Private Index等を含む）だけを作成する。**新しい階層名や運用方式を設計しない。**
- 既存ディレクトリの作成し直し、削除、Owner／ACL書換えは禁止。
- 作成された領域が予定場所・アクセス条件と整合することを確認。不一致なら停止。

### E2 — 原本5件 → Primary

- 既存の正本5件を変更せず、Primaryの予定Archive位置へ**コピー**する。
- 全5件のファイル名／件数／サイズ／SHA-256をSourceの期待値と照合する。5/5一致しない場合は、Backupコピーへ進まず停止。
- 失敗時に一部がコピー済みなら、**削除／Rollback／再コピーはせず**状態を報告する。

### E3 — 原本5件 → USB Backup

- 同じ原本5件を、識別済みUSBの予定Backup Archive位置へコピーする。
- 全5件のファイル名／件数／サイズ／SHA-256をSourceとPrimaryの確認結果に照合する。5/5一致しない場合は復元試験へ進まず停止。
- 原本／Primaryの既存ファイルを変更しない。

### E4 — USB Backup → Restore Test（全5件）

- 承認済みRestore Test先：
  `%USERPROFILE%\PrivateEvidenceRestoreTest\MailGenerator\P2_I12_20261018_Run01\`
- 既定計画の隔離条件および親ACLを維持する。予定どおりの空の試験先のみを作成・使用し、予期しない既存内容があれば上書きせず停止。
- **復元元はUSB Backupのみ**。Primaryからのコピーや原本の直接コピーを復元試験PASSの代用にしない。
- Restoreした5件のファイル名／サイズ／SHA-256を**原本の期待値**と比較する。5/5一致でRestore Verification PASS。
- 復元後の保持・削除は**既存計画で規定された範囲だけ**実施。削除が必要な場合は、この実行で生成したRestore Test用ファイルに限定し、対象と規則が一意に確定できない場合は削除せず停止して報告する。原本／Primary／USB Backupの削除は禁止。

### E5 — 最小限の結果保存・停止

- 既存計画で指定された**非公開**の実行記録・Private Index／照合Evidence保存先に、実際の結果のみ記録する。Public側へ生Evidenceを転記しない。
- 各工程の成功／失敗件数、コピー先、原本とのハッシュ一致、復元試験結果、処理した対象範囲を記録する。機微情報はチャット報告では伏せる。
- `S1-C Manifest Update`および`G2`は実行しない。S1全体の完了宣言、P2 Closure、Git操作を行わない。
- **結果を報告して停止**。実行成功であっても後続工程を自動開始しない。

## 5. エラー／中断時の共通ルール

- 事前照合・コピー・ハッシュ照合・復元中にFAIL、不一致、アクセス拒否、対象不明、既存物の衝突があれば**その場で停止**。
- 自動Retry・無断の権限変更・自動Rollback・再コピー・削除による帳尻合わせは禁止。
- 処理済みの範囲と未実施範囲を厳密に分け、Partial Stateとして記録・報告する。
- 終了コード0、コピー件数、ファイル存在だけでPASSとはしない。**SHA-256一致を必須**とする。

## 6. 最終報告書式

```text
ExecuteArchiveAuthorization: APPROVED_BY_USER
ExecutionOutcome: PASS / STOP_REVIEW_REQUIRED / FAIL
PreExecutionCheck: PASS / STOP_REVIEW_REQUIRED

SourceOriginals: 5/5_VERIFIED / PARTIAL / NOT_STARTED
PrimaryArchive: 5/5_SHA256_PASS / PARTIAL / NOT_STARTED
BackupArchive: 5/5_SHA256_PASS / PARTIAL / NOT_STARTED
USBRestoreTest: 5/5_SHA256_PASS / PARTIAL / NOT_STARTED
RestorePostProcessing: PLAN_CONFORMANT / NOT_REQUIRED / PENDING_REVIEW
ArchiveDirectoriesAndPrivateIndex: PASS / PARTIAL / NOT_STARTED
SourceOriginalsUnchanged: PASS / FAIL / UNKNOWN

UnexpectedOverwrite: NONE / DETECTED / UNKNOWN
ACLOrBitLockerMutation: NONE / DETECTED
GitOperation: NONE
S1CManifestUpdated: FALSE
G2Approved: FALSE

ResidualUnknowns:
- OneDriveRegistration: UNKNOWN (existing)
- <other, if any>

RemainingBlockers:
- <none or precise blocker>
Decision: S1_ARCHIVE_EXECUTION_PASS_PENDING_S1C_G2 / STOP_REVIEW_REQUIRED
```

最終判定を出力するのは**実際に全5件のPrimary・Backup・USB復元SHAがPASSし、事後条件が成立した場合のみ**。失敗したのに`PASS`を出したり、未実施を`N/A`へ付け替えたりしない。

---

**終了地点：S1-B EXECUTE_ARCHIVEの実行結果報告。S1-C Manifest正式更新およびG2承認は別Gate。**
