# P2-04 Regression Build Provenance Verification v0.1 — Draft

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール MVP |
| 対象 | P2-04 Manual Sync Integration / 2026-10-18 Regression Cycle / I12 Contract Regression |
| 文書種別 | Implementation Regression — Build / Source / Evidence Provenance Review |
| Version | v0.1 |
| 作成日 | 2026-10-18 |
| Status | **DRAFT / BUILD PROVENANCE NOT VERIFIED / I12 CLOSURE PENDING** |
| 先行作業資料 | `P2-04_I12_Evidence_Reconciliation_Matrix_v0.2_Draft.md` |
| 既存P2-04 Unit Completion | **PASS / COMPLETE（変更しない）** |
| 既存P2-04 Regression Evidence Finalization | **PASS / FINALIZED（過去Cycleの記録として維持）** |
| 今回のRegression実績 | 引継ぎ報告：**182/182 Assertion PASS（Raw Log未突合）** |
| 今回I12 Decision | **PENDING / NOT CLOSED** |
| Formal MVP Test | **NOT CLAIMED** |

**確認方法：** 接続済みGitHub `KJ-LEATHER-GAMES/MailGenerator`のread-only APIで2026-10-18時点の`main` Tree、承認文書、Regression Record、Versioned Production Artifact、テストソースを参照した。別PCのExcel Workbookや未保存のVBAProjectは実行・取得していない。原本文書に書かれた実行結果と、今回直接確認したGitHubの状態を区別する。

## 2. 結論（先に判定）

```text
GitHub Repository Snapshot                         IDENTIFIED
BL-MVP-004 Approval Record                          FOUND / APPROVED IN RECORD
P2-02 / P2-03 Independent Regression Records        FOUND / DRAFT CLOSURE PENDING
Reference Git Workbook Blob                         IDENTIFIED
2026-10-18 Executed Workbook Byte Identity          NOT VERIFIED
2026-10-18 Executed VBAProject / Production Revisions NOT VERIFIED
2026-10-18 Raw Regression Logs / Archive Location    NOT VERIFIED
Prior Evidence Reuse for Executed Build             NOT YET JUSTIFIED
Current I12 Final Decision                          PENDING
```

**制約：** GitHubに存在するコードとWorkbookが同じBuildを表す保証はない。実行時点のWorkbook/VBAProject・原本ログを保有していない以上、GitHubのHEADやファイル名から「今回の実行Build」を逆算・断定しない。

## 3. GitHub Reference Snapshot（識別可能な参照状態）

- Repository: `KJ-LEATHER-GAMES/MailGenerator`
- Branch: `main`
- 照合時HEAD Commit: `edf5c5175b103e250144341071d885a3a992c65f`
- HEAD Commit内容: P2-04 Regression実施計画／Registry／Handoff更新（2026-10-16 23:56 JST）
- Workbook path: `MailGeneratorNew.xlsm`
- Workbook Git Blob SHA-1: `c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`
- Workbook pathのGit最終Commit: `88b19f350623284d8738a69170e1769540a9030a`（2026-10-11 05:24 JST）
- Git Blob SHAはGit object IDであり、`Get-FileHash -Algorithm SHA256`の出力と直接比較できない。Git管理下の同一内容照合には`git hash-object`を用いる。

### 3.1 版付きSource Artifactと`src/`の区別

| 種別 | Repository Path | Git Blob SHA-1（先頭12桁） | 直接確認した範囲 |
|---|---|---|---|
| P2-02 versioned source | `Docs/02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.3_CP932.bas` | `9493e174ac8a` | `Public Function BuildSyncDiff`あり |
| P2-03 versioned source | `Docs/02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.2_CP932.bas` | `a4e50ceb36c6` | `Public Function ApplySyncDiff`あり |
| P2-04 versioned source | `Docs/02_implementation/P2_Scan_Sync/modSyncApplication_P2-04_v0.1_CP932.bas` | `bb895132da48` | `Public Function ExecuteManualSync`あり |
| P2-05 versioned source | `Docs/02_implementation/P2_Scan_Sync/modUiController_P2-05_v0.1_CP932.bas` | `7250379e521b` | 版付きArtifactあり |
| `src`側 Data Access | `src/modules/modVariableDefinitionData_CP932.bas` | `974255812811` | `GetAllVariableDefinitions` / `GetActiveVariableDefinitions`あり、**`ApplySyncDiff`のPublic宣言は見つからない** |

GitHub `src/modules/`には、当該HEAD時点で`modSyncEngine`、`modSyncApplication`、`modTemplateScanner`、`modUiController`の本番標準モジュールを確認できない。一方、対応する版付き実装資産は`Docs/02_implementation/`に存在する。

**判定：** `src/modules/modVariableDefinitionData_CP932.bas`と版付きP2-03 v0.1.2は同じGit Blobではなく、Public API範囲も異なる。`src`をそのまま「2026-10-18実行Workbookの完全Source Snapshot」と扱うことはできない。これはGit格納資産の**Source completeness / synchronization gap**であり、Excel実行結果のProduction Defectと判定する証拠ではない。

### 3.2 記録の時系列（同一性は未証明）

| 事実 | 記録日・Git履歴 | 意味 |
|---|---|---|
| BL-MVP-004 Approval | 承認記録上 2026-10-01 | 仕様Baselineは正式Approval Recordで確認可能 |
| P2-02 Regression Record | 2026-10-10、111/111 PASSと記録 | 独立RecordはDRAFT、実行Build/原本Log未照合 |
| P2-03 Regression Record | 2026-10-11、46/46 PASSと記録 | 独立RecordはDRAFT、実行Build/原本Log未照合 |
| Git Workbook Path最新Commit | 2026-10-11 05:24 JST | その時点のGit参照Workbookを識別するのみ |
| P2-04 versioned sourceのGit最終Commit | 2026-10-12 22:31 JST | Gitへ追加された時点。実行WorkbookにImport済みの証明ではない |
| P2-03 v0.1.2 sourceのGit最終Commit | 2026-10-15 01:20 JST | 同上 |
| P2-02 v0.1.3 sourceのGit最終Commit | 2026-10-15 01:24 JST | 同上 |
| P2-05 UI versioned sourceのGit最終Commit | 2026-10-16 22:14 JST | 同上 |
| 今回のRegression | 引継ぎ上2026-10-18、182/182 PASS | 別PCでの実行実体・Raw Log・Run IDは未確認 |

**重要：** Git上のWorkbookのCommitがVersioned SourceのGit追加より前であることは、**同じGit HEADに全ファイルがあっても、Workbookへ各版付きSourceがImport済みであることを推定できない**という追加の理由になる。Gitへの追加時刻だけでWorkbookの内部コードを推定もしない。

## 4. Baseline ApprovalとProject Control受入状態の切り分け

| 資料 | 直接確認できた記載 | 判断 |
|---|---|---|
| `Docs/00_project_control/baselines/BL-MVP-003_Approval_Record_v0.1.md` | 2026-09-19 APPROVED、REQ 0.1.9 / DES 0.1.9 / TS-A 0.4 / TESTSPEC 0.1.5 | 過去Baseline Approvalの証拠 |
| `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md` | 2026-10-01 **APPROVED**、BL-003 **SUPERSEDED**、REQ 0.1.9 / DES 0.1.10 / TS-A 0.4 / TESTSPEC 0.1.6 | **BL-004の承認記録は確認済み** |
| `Docs/00_project_control/Project_Overview.md`（v1.59） | Current Approved Baseline = BL-003。別PCでのP2実装・成果物同期／当地実機受入は未完了と記載 | 記録している**作業場所・受入状態**の範囲を確認する必要あり |
| `Docs/00_project_control/Document_Registry.md`（v1.28） | Current Approved Baseline = BL-003維持。P2-02/03 Regression Closure未了 | Approved Recordとの表記不一致が残る。**自動修正しない** |
| `DOC-MVP-IMPL v0.3 / BL-MVP-004 Impact Review v0.1` | **AFFECTED / v0.4 REQUIRED** | 影響レビューは実施済み |
| `DOC-MVP-IMPL v0.4 Candidate / BL-MVP-004 Consistency Review v0.1` | Candidate整合性確認とApproved移行の文言あり | Git Treeでは**Approved版 `Implementation Plan v0.4` の独立実体を確認できず**。Review記述とApproved Artifactは区別 |
| `Docs/02_implementation/Implementation Plan v0.3 日本語版.md` | Approved、Execution Baseline BL-003 | v0.3をBL-004準拠Planとして黙示的に読み替えない |

**判定:** Approval Recordは`BL-MVP-004`の承認を裏付けるが、別PCの実行WorkbookがBL-004に従うBuildであること、Git Project Controlの受入が完了したこと、実施計画v0.4 Approvedが存在することまで保証しない。

## 5. 今回CycleのRegression Evidence連結状況

| Evidence ID | 対象 | Result Source | 内容 | Provenance判定 |
|---|---|---|---|---|
| PR-01 | P2-01 | 独立Regression Record（2026-10-09） | Core 11/11、OFT Integration / Recipient Exclusion PASS、Record PASS/CLOSED | Record確認済み・今回Runへの適用 **PENDING** |
| PR-02 | P2-02 | 独立Regression Record（2026-10-10） | 6 Suite・111/111 PASS、Record DRAFT/CLOSURE PENDING | Report確認済み・実行Build/Raw Archive **PENDING** |
| PR-03 | P2-03 | 独立Regression Record（2026-10-11） | 5 Suite・46/46 PASS、Record DRAFT/CLOSURE PENDING | Report確認済み・実行Build/Raw Archive **PENDING** |
| PR-04 | 旧P2-04 / I12 | 旧Regression Evidence Finalization（BL-003） | I12 PASS/FINALIZED | **過去Cycleとしてのみ維持** |
| PR-05 | 今回Bootstrap | 2026-10-18の引継ぎ | 29/29 PASS（今回182に含む） | `HANDOFF-REPORTED` / Raw Log未照合 |
| PR-06 | 今回I03～I11 | 2026-10-18の引継ぎ | 153/153 PASS（I10初回ABORT→再実行20/20 PASS） | `HANDOFF-REPORTED` / Raw Log未照合 |
| PR-07 | I01/I02 | 過去Implementation Evidence | 過去PASS。今回の独立再実行なし | `HISTORICAL`、再利用判定待ち |
| PR-08 | 今回I12 | 本VerificationとI12 Matrix | Contract Evidence統合中 | **PENDING** |

**Raw Evidenceの実在・保存場所：** 現時点では特定できていない。Git `main`のTreeと受領した`P2-04_Documents.zip`には2026-10-18の個別実行ログの独立保存先が確認できず、未保存であったとの断定もしない。

## 6. Evidence Chain — 完了と判定するために必要な対応表

| Run ID | Run Date/Time (JST) | Machine/Environment | Workbook at Run（Path＋Hash） | VBA Source Snapshot / Commit | Entry Point / Suite | Raw Log Path | Cleanup Snapshot | 状態 |
|---|---|---|---|---|---|---|---|---|
| RUN-BOOT | **未確認** | **未確認** | **未確認** | **未確認** | `TestP202P203BootstrapProductionCompatibility` | **未確認** | **未確認** | 報告29/29 |
| RUN-I03 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I03InvalidCandidate` | **未確認** | **未確認** | 報告10/10 |
| RUN-I04 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I04OftMissing` | **未確認** | **未確認** | 報告11/11 |
| RUN-I05 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I05DefinitionReadFailure` | **未確認** | **未確認** | 報告17/17 |
| RUN-I06 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I06BuildSyncDiffFailure` | **未確認** | **未確認** | 報告22/22 |
| RUN-I07-08 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I07I08ContinuousRetry` | **未確認** | **未確認** | 報告37/37 |
| RUN-I09 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I09WarmLifecycle` | **未確認** | **未確認** | 報告16/16 |
| RUN-I10-A | **未確認** | **未確認** | **未確認** | **未確認** | I10初回ABORT | **未確認** | **未確認** | ABORT理由未証明 |
| RUN-I10-B | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I10ColdLifecycle` | **未確認** | **未確認** | 報告20/20 |
| RUN-I11 | **未確認** | **未確認** | **未確認** | **未確認** | `TestP204I11ManualOnlyAfterReopen` | **未確認** | **未確認** | 報告20/20 |

Run IDは本資料での**照合用仮ID**であり、実行時のログに存在した識別子を再現したものではない。I11のWindows TEMP Baseline Fingerprintは一時比較資産であり、これを各SuiteのRaw Log Archiveとみなさない。

### 6.1 実行PCでのRead-only採取（推奨順）

> **過去の実行時点のSnapshotがあるなら、そちらを優先する。** 現在のファイルを今日ハッシュ化しても、それだけで2026-10-18実行時の同一性を証明できない。またWorkbookが未保存の状態でVBAコードだけ変更されていた可能性は、Disk上ファイルのHashでは排除できない。

1. 2026-10-18実行時に使ったWorkbookコピーや自動バックアップ、Export済みVBAソース、過去コミット・保存履歴を探す。**保存前に原本を変更しない**。
2. 実行当時のファイルについて、Windows PowerShellで以下を**読み取りのみ**で実施し、出力と対象Full Pathを保存する。

   ```powershell
   $wb = 'C:\<TEST_SNAPSHOT_FOLDER>\MailGeneratorNew.xlsm'
   Get-Item -LiteralPath $wb | Select-Object FullName,Length,CreationTime,LastWriteTime
   Get-FileHash -LiteralPath $wb -Algorithm SHA256
   # Gitが使用可能なPCに限る。Git Blobとの同一性を照合するための値。
   git hash-object -- $wb
   ```

3. Git Cloneで実行した場合に限り、作業コピーのCommitと未Commit差分を**記録するだけ**のコマンドを使用する。

   ```powershell
   git rev-parse HEAD
   git status --short
   git log -1 --format="%H %cI" -- MailGeneratorNew.xlsm
   ```

4. 元Runに対応したProduction VBA Export（特に`modSyncEngine`、`modVariableDefinitionData`、`modSyncApplication`、`modOutlookAdapter`、`modTemplateScanner`、`modUiController`）とHarness Exportのバージョン・Hashを採取する。同名Moduleが一致しても本文差分を確認する。
5. 182件の各実行のImmediate Window全文ログ、I10 ABORT・再実行、Fixture原状復帰情報、Execution Date/Timeを対応付ける。ログが存在しなければ**未保管**ではなくまず**所在未確認**とし、実際に調査して初めて`NOT AVAILABLE`へ変更する。
6. 個人情報・メール本文・宛先・ファイルパス中の個人名等を含む場合は、機密性を確認のうえ証拠を保存する。Logの元版は改変せず、共有時にマスクした派生版と区別する。

### 6.2 GitHub Snapshotとの照合方法

- GitHub参照WorkbookのBlob SHA：`c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`。
- 過去実行Workbookを確保できた場合の`git hash-object <workbook>`が同値なら、**Gitの当該BlobとDiskファイルが同一内容**であることを確認できる。ただし未保存のメモリ上のVBA変更がなかったことは別途確認が必要。
- 同値でない場合は**差異あり**として、保存時点・Fixture変更・VBAソースRevisionの差分を調べる。単純にFAILやProduction Defectと判定しない。
- Workbook内部のVBAProject実体はGitの`Docs/...`版付きArtifact／`src/modules/`のいずれとも自動的に一致しない。必要なExportを比較して初めてContract Compatibilityを判断する。

## 7. Prior Evidence Reuse 判定基準

| 条件 | 判定要求 | 現状 |
|---|---|---|
| A：正式Baseline | BL-004 Approvalと対象Runで適用したDesign/Test Definitionを分離して記録 | **Approvalは確認済み、Runへの適用は未確認** |
| B：P2-01～03の実行ソース | 各Regression実行時Source Snapshotと10/18実行時点の該当Production Moduleを対比 | **未確認** |
| C：Contract不変性 | Public Signatureに加え、Bootstrap / Detection History / Failure Guard / Carrier / Persistenceの意味論に影響する変更がないことを示す | **Git版付きArtifactの存在を確認、実行コード差分未確認** |
| D：Raw Evidence | 既存Record本文の集計に加え、各Runの原本出力・時刻・Fixture復元・最終状態を追跡 | **未確認** |
| E：Finding | 関連Regression Finding/Observationに対し影響・Blocking Statusを判定 | **未完了** |
| F：I01/I02 | 過去Implementation PASSの対象Sourceを特定し、10/18への適用性を別途判定 | **未確認（今回は未実行）** |
| G：I12 Guide vs Plan | 直接再実行を記す旧Guideと既存Evidence統合を採用する新計画との実際の適用関係を確認 | **現行計画の統合方式を暫定採用、最終判定前に根拠確定** |

**再利用結論： `CONDITIONALLY ELIGIBLE / NOT YET APPROVED FOR 2026-10-18 BUILD`**。過去のPASSを消さず、影響を示せない契約だけを対象に選択的再検証する。すべてのテストを根拠なく再実行しない。

## 8. Open Items / Gate

| ID | 未解決事項 | Closureに必要な根拠 | 優先 |
|---|---|---|---|
| BPV-001 | 2026-10-18実行時Workbookの個体識別 | Run時のWorkbookコピー／Hash／保存状態、または同等のTraceability | **HIGH** |
| BPV-002 | 実行時VBAProjectのSource同一性 | Export集合・Hash・Public Contract／意味論差分 | **HIGH** |
| BPV-003 | Bootstrap＋I03～I11のRaw Log所在 | 全Runの元ログとI10 ABORT→20/20 PASSの独立参照 | **HIGH** |
| BPV-004 | P2-02 / P2-03の原本Evidence・Fixture・Finding | 独立Regression RecordのClosure保留項目を解消 | HIGH |
| BPV-005 | Project ControlとBL-004 Approved記録 | 受入／同期範囲を明示し、どの環境の管理状態か確定 | MEDIUM |
| BPV-006 | Implementation Plan v0.4のApproved原本 | Candidate Consistency ReviewとApproved Artifactを分離して所在確認 | MEDIUM |
| BPV-007 | I01/I02過去証拠の再利用適用範囲 | 対応する実行Sourceと10/18 Source差分・影響 | HIGH |
| BPV-008 | I12最終Coverageと最終Finding | ReviewしてI12を個別にPASS/FAIL/PENDING判定 | HIGH |

**Exit判定：** `BPV-001/002/003/004/007/008`が満たされ、BL-004適用状態との意味論整合が立証されるまでは、今回のI12をPASS/CLOSEDにしない。BPV-005/006を勝手に補完しない。Project Control上の独立した受入Gateにも先行PASSを宣言しない。

## 9. 次の具体的な照合作業

1. **最優先**：2026-10-18実行PCのWorkbook SnapshotとImmediate Window原本ログの有無・保存先・Source Exportを確認する。
2. 取得できたファイルのHash・Source Revision・Run番号を第6節へ反映する。Git Blobとの一致／不一致を事実として記録。
3. Source差分の影響評価により、P2-02 111/111・P2-03 46/46・P2-01結果・I01/I02旧Evidenceの再利用可否を決める。
4. 原本ログと182件の引継ぎ集計を照合し、I10 ABORT・復元Evidenceも含めてFindingを処置する。
5. `P2-04_I12_Evidence_Reconciliation_Matrix`をRevisionし、今回CycleのI12最終判定を**独立Gateとして**実施する。

## 10. Project Storage / Source References

- このチャットで生成したファイル：`/mnt/data/P2-04_Regression_Build_Provenance_Verification_v0.1_Draft.md`
- プロジェクトへ反映する場合の推奨保存先：`Docs/03_verification/technical_validation/P2-04_Regression_Build_Provenance_Verification_v0.1_Draft.md`
- Evidence保存区分：`Evidence/`（**具体的既存ファイルは未確認**）
- GitHub Repository：`https://github.com/KJ-LEATHER-GAMES/MailGenerator`
- GitHub参照Revision：`edf5c5175b103e250144341071d885a3a992c65f`
- 主な参照文書：`BL-MVP-003_Approval_Record_v0.1.md`、`BL-MVP-004_Approval_Record_v0.1.md`、`Project_Overview.md`、`Document_Registry.md`、`DOC-MVP-IMPL v0.3 - BL-MVP-004 Impact Review v0.1.md`、`DOC-MVP-IMPL v0.4 Candidate - BL-MVP-004 Consistency Review v0.1.md`、`P2-02 Sync Diff Core Regression Record v0.1.md`、`P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md`、`P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`、`P2-04_I12_Contract_Regression_Guide_v0.1.md`。

**変更範囲：** read-only調査と本Draftの作成のみ。GitHub RepositoryへのCommit／Project Overview・Registryの書換／実行Workbook・OFT・VBAの操作は行っていない。

---

## まとめ / Summary

**日本語：** GitHub上の承認BaselineとGit Snapshot、P2-02/P2-03の独立Regression Record、関連Versioned Sourceを特定した。一方、Gitの`src`と版付きSourceには差があり、10月18日に実行されたWorkbook/VBAProjectとの一致は未確認。182件の原本ログも未確認のため、今回のI12はPENDINGを維持する。次は実行時Workbook・VBA Export・Raw Logを確保し、実際のSource差分に基づいて過去Evidenceの再利用を判定する。

**English:** The approved baseline record, Git snapshot, regression records, and source files were found. The Git source files do not fully match each other. We cannot confirm that they match the workbook used on October 18. The original logs are also not verified. I12 stays pending. Next, confirm the tested workbook, VBA source, and raw logs before reusing old evidence.
