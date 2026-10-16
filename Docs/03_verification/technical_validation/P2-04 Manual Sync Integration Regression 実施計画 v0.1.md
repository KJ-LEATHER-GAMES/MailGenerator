# P2-04 Manual Sync Integration Regression 実施計画 v0.1

## 1. Document Information

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase / Parent | P2 Scan / Sync / P2-05 |
| Regression Target | P2-04 Manual Sync Integration |
| Status | 実行計画確定（実施前Prerequisiteは実環境で確認） |
| Verification Type | Implementation / Regression Verification |
| Formal MVP Test | NOT CLAIMED |
| Source Package | `P2-04_Regression.zip`（現行WorkbookからExport） |
| Source Review Date | 2026-10-12 |
| Approved Baseline | 要確認：既存文書 BL-MVP-003、テストソースの一部に BL-MVP-004 固定表示 |
| Regression Outcome | NOT EXECUTED（本計画の新規実行分） |

## 2. Scope and Completion Boundary

P2-05実装後、既存`modSyncApplication.ExecuteManualSync`のApplication責務・Failure Guard・Output Carrier・Excel Persistence接続・Outlook Lifecycle・Manual-only動作にRegressionがないことを確認する。

既存記録：
- P2-01 Full Template Scanner Regression：PASS/CLOSED
- P2-02 Sync Diff Core Regression：111/111 PASS（Record ClosureにBaseline/Build確認が必要）
- P2-03 VariableDefinition Sync Persistence Regression：46/46 PASS（同）
- P2-04 Integration Verification I01–I12：既存Completion Recordで12/12 PASS（過去のImplementation Evidence。今回の新規再実行と混同しない）

今回の追加実行：Bootstrap Production Compatibility 29件、P2-04 I03–I11の実行可能Harness（I07/I08は1連続実行）、既存I12 Contract Regression Evidenceの統合。

I01 Happy Path・I02 Common SyncTimestampは過去のP2-04 Verification RecordとP2-05 Runtime Evidenceで対応づける。ZIPに個別の再実行Entry Pointはない。**I01/I02を現行Buildで独立再実行したと主張しない。** 全I01–I12の現行Build再実行を要求する場合は、I01/I02手順またはHarnessを別途確認して計画更新する。

I12は専用Aggregatorを作らない。既存P2-01/P2-02/P2-03 RegressionとBootstrap CompatibilityのEvidenceを参照する。

## 3. Verified Source Package

- Production 7：`modSyncApplication`, `modSyncEngine`, `modVariableDefinitionData`, `modTemplateScanner`, `modOutlookAdapter`, `modSettingsData`, `modUiController`
- Classes 2：`COperationResult`, `CErrorInfo`
- Tests 6：`modP2_04RemainVerification`, `modP2_04I07I08RetryVerifi`, `modP2_04I09WarmLCVerification`, `modP204I10ColdLifecycle`, `modP204I11ManualOnly`, `modP2_02P2_03BSProductCompaTest`

`MailGeneratorNew.xlsm`と`MailTemplate.oft`等のRuntime FixtureはZIPに含まれない。存在・内容・現行Revisionをユーザー側で確認する。本ZIPはVBAProject全体の完全Exportではないため、ZIP単体でのCompile PASSを意味しない。

## 4. Global Preflight（最初に実施）

- [ ] 作業用`.xlsm`のバックアップ作成。必要なOFTもバックアップ。
- [ ] `Debug > Compile VBAProject` PASS（現行Workbook）。
- [ ] `Settings.tblSettings` の `TemplatePath` を記録。
- [ ] `VariableDefinition.tblVariableDefinition`のデータ・列名・行数・シート保護状態を記録。
- [ ] 正常OFTで`ModelName`を含み、異常Candidateがなく、予期しないNew変数が生じないことを確認（特にI07/I08）。
- [ ] P2-01/P2-02/P2-03回帰Evidenceを保存・紐づけ。
- [ ] 現行Approved BaselineとWorkbook Build/Revisionを特定。表示文字列だけでBaseline Approvedと判定しない。
- [ ] Immediate Window出力は各Test実行直後に別ファイルへ保存（ログ流出防止）。

## 5. Execution Order（個別実行、固定）

| 順序 | 検証 | 実行Entry Point | 固有事前条件 / 操作 | Evidence / 終了条件 |
|---:|---|---|---|---|
| 1 | Bootstrap Production Compatibility | `TestP202P203BootstrapProductionCompatibility` | 作業用Workbook、Table Backup。Harnessが表をクリア・再生成。 | 29/29 PASS、復元ログ・Before/After |
| 2 | I03 Invalid Candidate | `TestP204I03InvalidCandidate` | OFTに不正Candidate（例 `{{1stGate}}`）を用意し、事前Scanner PreflightがInvalidを確認。 | Failure + InvalidCandidates保持 + `syncDiffResult=Nothing` + Table不変。終われば正常OFTへ復元。 |
| 3 | I04 OFT Missing | `TestP204I04OftMissing` | 正常な`Settings.TemplatePath`。Harnessが存在しない相対パスを作成・復元。 | Failure、Table不変、TemplatePath復元。 |
| 4 | I05 Definition Read Failure | `TestP204I05DefinitionReadFailure` | 正常OFT、`Status`列存在、`Status_TEST_BROKEN`列が事前に存在しない。 | Failure、列名復元、Table不変。 |
| 5 | I06 BuildSyncDiff Failure | `TestP204I06BuildSyncDiffFailure` | 正常OFT、`ModelName.Status`セル存在。 | Failure、状態復元、Table不変。 |
| 6 | I07 + I08 Apply Failure → Fresh Retry | `TestP204I07I08ContinuousRetry` | 正常OFT、`ModelName.Status=Active`、既存分類、New.Count=0、シート保護なし。 | I07は書込み失敗でFailure、I08は手動再実行Success。Protection・Table復元。 |
| 7 | I09 Warm Lifecycle | `TestP204I09WarmLifecycle` | Classic Outlook起動済、Explorer >=1、Lifecycle Counts取得可能。 | Success、Explorer再利用、Draft/Inspector残存なし、Table復元。 |
| 8A | I10 Cold Lifecycle準備 | `PrepareP204I10ColdLifecycleBaseline` | Outlook起動中、Explorer >=1、Inspector=0。 | Baseline prepared。Outlookを完全終了する。 |
| 8B | I10 Cold Lifecycle実行 | `TestP204I10ColdLifecycle` | **同じVBAセッションのまま**Outlook完全終了、OUTLOOK.EXE=0。 | Outlook起動・Explorer確立・Draft/Inspector異常なし・Table復元。 |
| 9A | I11 Manual Only準備 | `PrepareP204I11ManualOnlyBaseline` | 正常OFT、Workbookを保存できる状態。FingerprintをWindows TEMPへ保存。 | Baseline prepared。Workbook/Excelを通常終了。 |
| 9B | I11 Manual Only実行 | `TestP204I11ManualOnlyAfterReopen` | **Workbook再オープン後、同期を手動実行せず**Entry Pointを実行。 | Open時変更なし→明示Sync Success→復元＆Workbook保存。 |
| 10 | I12 Contract Regression統合 | （専用Entry Pointなし） | 既存P2-01、P2-02 111件、P2-03 46件、今回Bootstrap 29件のEvidenceを照合。 | Contract変更なし・Blocking Finding=0。 |

I01/I02は既存Implementation EvidenceとP2-05 Runtime Verificationの対応表で扱う。新規実行する場合は追加手順・Entry Pointを確認してから別途実行する。

## 6. Execution Rule / FAIL Handling

- [ ] 各Macroの`Overall = PASS`を確認（表示形式はHarnessに従う）。`ABORTED`はPASSとしない。
- [ ] I07/I08は連続Scenarioなので途中で分離しない。
- [ ] I10はPrepareから実行までVBAProjectをReset/Excel終了しない。Outlook終了後のみCold Entry Pointを呼ぶ。
- [ ] I11は実Workbook終了・再オープンを要するため最後に行う。Fingerprintの一時ファイル管理も記録。
- [ ] Restorationはログの報告に加え、Table名、列名、保護、Settings、行数・値、Outlook状態を適宜確認。
- [ ] 失敗時は連続実行を停止し、Excel/Outlook状態と完全ログを保存。Production Defect / Test Artifact / Fixture / Contract / Environmentを切り分ける。
- [ ] WordEditor E_FAILが再現した場合、既存`OBS-P2-05-002`の調査手順に従い、状況を保持して診断。仮説だけでSleep/Retry等を追加しない。

## 7. Final Gate

- [ ] 今回の各実行可能HarnessがPASS、ABORTED/未復元なし。
- [ ] Bootstrap Compatibility = 29/29 PASS。
- [ ] I01/I02の既存Evidenceを正しく引用（新規実行と表示しない）。
- [ ] I12既存Regression Evidenceと今回の互換性Evidenceを統合。
- [ ] Source/Build/Approved Baselineの照合（`BL-MVP-003`とテストソース中の`BL-MVP-004`表記差異を解消）。
- [ ] Active / Blocking Regression Finding = 0。
- [ ] `P2-04 Manual Sync Integration Regression Record v0.1`を作成し`PASS/CLOSED`判定。

本GateはP2-05 Complete、P2 Phase Complete、CP-P2 Establishment、Formal MVP Test PASSを意味しない。P2-05 Final Compile、Static Review S01–S32等は別Gateで実施する。

## まとめ / Summary

日本語：現行Export一式でP2-04の既存Harnessを個別実行できる。I01/I02の新規再実行Entry Pointは含まれず、I12は既存Regression Evidenceの統合とする。I10・I11には二段階準備があり、I11を最後に実施する。

English: The exported source covers the available P2-04 regression harnesses. I01/I02 have no new execution entry points in the ZIP, and I12 uses existing regression evidence. Run I10 and I11 as two-stage tests, with I11 last.
