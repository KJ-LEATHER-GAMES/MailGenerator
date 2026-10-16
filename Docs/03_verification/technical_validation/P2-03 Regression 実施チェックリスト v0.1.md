# P2-03 VariableDefinition Sync Persistence Regression 実施チェックリスト v0.1

## 1. Document Information

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Parent Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Target | P2-03 VariableDefinition Sync Persistence |
| Verification Type | Implementation / Regression Verification |
| Version | v0.1 |
| Status | **READY FOR SOURCE / FIXTURE CONFIRMATION**（実行結果未取得） |
| Execution Baseline | **要確定**：既存承認記録は`BL-MVP-003`、直近P2-02実行ログは`BL-MVP-004`と表示 |
| Current Production Reference | `modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas`（P2-04文書で記録されたControlled Correction後のSource Artifact。現行Workbookとの一致は未照合） |
| Preflight Compile | **PASS**（2026-10-10、ユーザー申告。後続変更があれば再実施） |
| Formal MVP Test | **NOT CLAIMED** |
| Created | 2026-10-10 |

### Source Documents

- `16_P2-03.txt`中の `P2-03 VariableDefinition Sync Persistence Completion Record v0.1`（初期P2-03 Unitの成立範囲）
- `P2-04_Documents.zip` 内 `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md`（後続Correction後のRegression件数、対象Revision、Bootstrap Production Compatibility）
- 同ZIP内 `P2-04 Production Change Scope Correction Record v0.1.md`（IF-P2-04-001、P2-03 Controlled Correction）
- `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md` §59（P2-03 Regression PASSはP2-05 Completionの必須条件）
- `AI協働開発 文書管理・Baseline運用ルール v0.1.md`（Baseline・Evidenceトレーサビリティ規則）
- `P2-02 Sync Diff Core Regression Record v0.1.md`（直前111/111 PASS、Baseline識別未解消）

> **照合上の注意**：初期P2-03 Completion RecordはSource `modVariableDefinitionData_P2-03_v0.1.bas` とBL-MVP-003を記載。一方、後続P2-04実施で`IF-P2-04-001`対応のControlled Correctionが入ったため、P2-03 Regressionでは後続修正済みSourceを照合する。本文書だけでWorkbookの実際のSource/Buildを確定したことにはしない。

## 2. Regression Scope / Public Contract

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

対象：

1. `SyncDiffResult` の検証（New / Existing / Reactivated / Unused）。
2. `tblVariableDefinition` へのNew追加、およびExisting / Reactivated / UnusedのTarget Metadata保存。
3. `VariableName` のCanonical Identity保持および既存User Configuration保持。
4. 不正入力、Destination Conflict、書き込み失敗時の定義済み動作。
5. P2-02 Output、P0 Read APIとのCompatibility。

非対象：Classificationの再計算、UI、Manual Sync Orchestration、Rollback／Transaction、Formal MVP Test。

## 3. 実行前チェック（必須）

- [ ] 現在の**Approved Baseline ID**をProject Overview / Baseline Manifest / Approval Recordで確認。`BL-MVP-003`と`BL-MVP-004`の差異を記録して解消する（ログ表示の恣意的な書換えは禁止）。
- [ ] 実行Workbookの名称・パス・Build/Revision・Commit ID（使用可能なら）を記録。
- [ ] Production ModuleがControlled Correction後の`modVariableDefinitionData`であること、古い重複実装がないことを確認。
- [ ] `ApplySyncDiff`のPublic Signatureが変更されていないことを確認。
- [ ] テストモジュールから**5 Suiteの正確なEntry Point**（Public Sub、引数なし）を探して名前を記入する。既存配布資料からEntry Point名までは確認できていないため**推測した名前を実行しない**。
- [ ] 作業用Workbookの完全コピー（VBA・Sheet・ListObjectを含む）を作成し、**元Workbookへの実行を避ける**。
- [ ] `tblVariableDefinition`の実行前スナップショットを取得（行数、列構成、Status、`TemplateLocation`、`FirstDetectedAt`、`LastDetectedAt`、User Configuration）。
- [ ] Baseline Fixture状態の確認：既存のP2-01 Regressionでは `ModelName Active / OldVariable Unused / GateDate Active / Department Active / Comment Active`、P05テスト用追加行は削除済み。今回のWorkbookで再確認する。
- [ ] **各SuiteがFixtureを復元する実装か**をテストソースで確認。未確認の場合、Suite間で元の初期状態に復元してから続行。
- [ ] N18 Runtime Write FailureのFault Injection手法・副作用をテストソースで確認。**部分更新が残り得るため元Workbookでは実行しない**。
- [ ] K1等でOutlook/OFTを実行する場合、Classic OutlookのWarm状態とVisible Explorerの前提を準備。`ReadBodyText`に失敗した場合はP2-03 Defectと即断せず、失敗境界とResult/Errorを保存。
- [ ] VBE `Ctrl+G` Immediate Windowを準備。テストごとに全文をEvidence保存。
- [ ] Compile PASSの記録を紐づける。ソース変更があれば再Compileする。

## 4. 5 Suite / Entry Point確認・実行表

**予定順**：Bootstrap → Detection History → Core → Technical Negative → Compatibility。これはEvidenceの確認と保全を行いやすい推奨順であり、Suite相互の依存がある場合はテストソース記載順を優先して記録する。

| 順序 | Suite | Entry Point（**現行VBAで実名を記入**） | 期待PASS | 実測PASS | FAIL | Evidence |
|---:|---|---|---:|---:|---:|---|
| 1 | Bootstrap | `未確認：________` | 7 | — | — | `R1_Bootstrap_YYYYMMDD.txt` |
| 2 | Detection History | `未確認：________` | 6 | — | — | `R2_DetectionHistory_YYYYMMDD.txt` |
| 3 | Core | `未確認：________` | 12 | — | — | `R3_Core_YYYYMMDD.txt` |
| 4 | Technical Negative | `未確認：________` | 18 | — | — | `R4_TechnicalNegative_YYYYMMDD.txt` |
| 5 | Compatibility | `未確認：________` | 3 | — | — | `R5_Compatibility_YYYYMMDD.txt` |
| | **合計** | | **46** | — | — | |

**注意**：上述5 Suiteの件数はP2-04 Regression Evidenceで確認済み。ただし5つの具体的Entry Point名・Wrapper名・Fixture初期化方式は、手元の提供資料からは確定できない。実行前にVBA Test ModuleのPublic Subを調べる。

### R1 — Bootstrap（7/7）

- [ ] Entry Point / Test Moduleを確定。
- [ ] Fixture初期状態と期待結果をテストソースで確認。
- [ ] 7/7 PASS・FAIL 0、`Overall = PASS`を確認。
- [ ] `R1_Bootstrap_YYYYMMDD.txt`に全文保存。
- [ ] Fixture変化と復元結果を記録。

### R2 — Detection History（6/6）

- [ ] Entry Point / Test Moduleを確定。
- [ ] Metadataの保存／保持の条件とFixtureをテストソースで確認。
- [ ] 6/6 PASS・FAIL 0、`Overall = PASS`を確認。
- [ ] `R2_DetectionHistory_YYYYMMDD.txt`に全文保存。
- [ ] Fixture変化と復元結果を記録。

### R3 — Core（12/12）

- [ ] Entry Point / Test Moduleを確定。
- [ ] C01–C12を照合：New（Empty/Existing Table）、Multiple New、Existing、Canonical Identity、Reactivated、Unused、Mixed Classification、No-op、Date Persistence、User Configuration Preservation、Existing VariableName Preservation。
- [ ] 12/12 PASS・FAIL 0、`Overall = PASS`を確認。
- [ ] `R3_Core_YYYYMMDD.txt`に全文保存。
- [ ] Fixture変化と復元結果を記録。

### R4 — Technical Negative（18/18）

- [ ] Entry Point / Test Moduleを確定。
- [ ] N01–N17：予測可能な異常時は**書き込み前Failure（Write=0）**を確認。
- [ ] N18：書き込み中のRuntime Failureを`COperationResult Failure`として返し、Unhandled Runtime Errorがないことを確認。
- [ ] **N18のRollbackを要求しない**。Suite後のデータ状態を確認し、初期状態へ復元。
- [ ] 18/18 PASS・FAIL 0、`Overall = PASS`を確認。
- [ ] `R4_TechnicalNegative_YYYYMMDD.txt`に全文保存。

### R5 — Compatibility（3/3）

- [ ] Entry Point / Test Moduleを確定。
- [ ] K1：P2-02 `BuildSyncDiff` → P2-03 `ApplySyncDiff` Production接続。
- [ ] K2：P0 `GetAllVariableDefinitions` / `GetActiveVariableDefinitions`、Carrier / `__RowIndex` / Active FilterのRead Regression。
- [ ] K3：P2-02 `SyncDiffResult` Carrierの互換性とContract No-Reopen。
- [ ] 3/3 PASS・FAIL 0、`Overall = PASS`を確認。
- [ ] `R5_Compatibility_YYYYMMDD.txt`に全文保存。

**補足**：P2-04記録の `Bootstrap Production Compatibility 29/29 PASS` は、P2-03の5 Suite／46件とは**別の追加Evidence**。今回の46件に足さない。P2-04 Regressionへ進む際に、別途利用／再確認を検討する。

## 5. Evidence / 判定方法

保存情報（推奨）：

```text
Executed at:
Excel/Outlook Environment:
Workbook / Build / Commit:
Current Approved Baseline:
Execution Log Baseline Label:
Production Module / Revision:
Test Module / Entry Point:
Fixture Before / After / Restored:
PASS / FAIL / Overall:
Unexpected Runtime Error:
Full Immediate Window Log File:
Findings / Observations:
```

- 5 Suiteをできる限り**個別実行**する。一括WrapperではImmediate Windowの先頭ログ欠落事例がある。
- 次Suiteの実行前に直前のログを保存。必要ならImmediate Windowをクリア。
- `PASS Count`と`Overall`の両方を確認し、期待集計行だけで実測PASSと認定しない。
- 初期不具合や環境エラーを再実行で消して記録しない。Initial FailureとRerunをそれぞれ保存。
- FAIL時はProduction Defect / Test Artifact Defect / Fixture Defect / Contract Finding / Environment Issueを切り分ける。
- P2-02の`111/111 PASS`はRuntime Evidenceとして得られたが、RecordはBaseline/Build照合待ち。P2-03の実行自体と正式Closureを区別する。

## 6. Completion Gate

- [ ] `R1 7/7`・`R2 6/6`・`R3 12/12`・`R4 18/18`・`R5 3/3`がPASS。
- [ ] `Total = 46 / 46 PASS`、FAIL = 0を確認。
- [ ] Evidenceログを5件保存でき、欠落・判定不能箇所がない。
- [ ] ProductionとTest ModuleのRevision / Buildが特定できる。
- [ ] Baseline Manifest照合を完了し、`BL-MVP-003` / `BL-MVP-004`の差異を解消した。
- [ ] Fixtureの実行後状態が事前スナップショットと一致（差異は原因を説明して復元）。
- [ ] Active / Blocking Regression Finding = 0。
- [ ] `P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md`を作成し、Evidence参照と判定を固定。

**Boundary**：`P2-03 Regression PASS / CLOSED` は、`P2-05 COMPLETE`、`P2 Phase COMPLETE`、`CP-P2 ESTABLISHED`、`Formal MVP Test PASS` を意味しない。

## 7. Next Action

1. **最初に**現行VBA ProjectのP2-03 Test Moduleを見て5 SuiteのEntry PointとFixture初期化／復元処理を特定する。
2. 実行用Workbookのコピー・Fixtureスナップショットを保存する。
3. R1 Bootstrap（7件）から順に5 Suiteを実行し、ログを個別保存する。
4. データ復元後、46/46の結果をレビューする。
5. P2-03 Regression Recordを作成し、Baseline/Build照合完了後にPASS/CLOSED判定する。
6. 次のP2-04 Regressionへ進む。

## まとめ / Summary

**日本語**：P2-03 Regressionは5 Suite・46件。P2-02と異なりExcel Tableを更新するため、作業用コピー、Fixtureの事前／事後比較、N18の部分更新リスク対応を必須とする。実行前に5 Entry PointとBaseline/Buildを特定する。

**English**: P2-03 regression covers 46 checks in five suites. Protect the workbook and fixtures, confirm the exact entry points and baseline, run each suite, and retain full evidence.
