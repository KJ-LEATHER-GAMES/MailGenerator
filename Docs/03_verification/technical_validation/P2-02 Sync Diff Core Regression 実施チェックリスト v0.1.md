# P2-02 Sync Diff Core Regression 実施チェックリスト v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Parent Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Regression Target | P2-02 Sync Diff Core |
| 文書種別 | Implementation Regression Execution Checklist（実施準備） |
| Version | v0.1 |
| Status | **READY FOR SOURCE / ENTRY-POINT CONFIRMATION**（実行結果未記入） |
| Execution Baseline | `BL-MVP-003`（引継ぎ時点） |
| 対象環境 | Excel Desktop / VBA |
| Formal MVP Test | **NOT CLAIMED** |
| プレフライトCompile | **PASS（ユーザー報告：2026-10-10）** |
| 作成日 | 2026-10-10 |

### 参照資料

- `P2-02 Sync Diff Core Completion Record v0.1.md`：Core / Negative / Compatibilityの確定Entry Point、Contract、完了時Evidence
- `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md`：後続修正後に達成済みの6 Suiteの総数、Production修正Revisionの記録
- `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md`：P2-02 RegressionをP2-05 Completion条件とする規則
- `P2-01 Full Template Scanner Regression Record v0.1.md`：直前Regressionの完了状態およびFixture復元状態
- 前回実行履歴：`TestP202SyncDiffV013RegressionSuite` Wrapperと個別Test Entry（**現行Workbookで再確認する**）

> 注意：`P2-02 Completion Record v0.1` に記録されたProduction Artifactは `modSyncEngine_P2-02_v0.1_CP932.bas`。後続のP2-04 Regression Evidenceでは `modSyncEngine_P2-02_v0.1.1_CP932.bas` を記録している。また、過去の実行履歴に `V013` というWrapper名がある。**この3つの情報のみから現行WorkbookのProduction Revisionを断定しない。** 実行前にWorkbook側を確認し、結果Recordへ対象Build / Commit / Export名を残す。

---

## 2. 目的 / PASS条件

**目的**：P2-05実装後もP2-02の差分分類・Target Metadata・Defensive Guard・Carrier CompatibilityにRegressionがないことを確認する。

1. 6 Suiteすべてが予定件数でPASSし、合計 **111 / 111 PASS**。
2. 各Suiteについて個別の実行ログを欠落なく保存できる。
3. `BuildSyncDiff` のPublic Signatureを含む既存P2-02 Contractへの意図しない変更がない。
4. 確認されたActive / Blocking Regression Findingが0件。
5. 本結果をFormal MVP Test PASSと誤記しない。

### 対象Public Contract

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

---

## 3. 実行前チェック（必須）

- [x] **Pre-flight**：`Debug → Compile VBAProject` がPASS（2026-10-10、ユーザー確認）
- [ ] 実行対象Workbook名、パス、版またはCommit IDを記録
- [ ] `modSyncEngine` の現行ソースが意図した修正済みRevisionであることを確認（古いModuleとの重複・共存なし）
- [ ] `BuildSyncDiff` のPublic Signatureが上記と一致することを確認
- [ ] 6つの個別Entry Point（§4）が現行VBA Projectに存在し、**Public Sub・引数なし**等で実行可能なことを確認
- [ ] Wrapper `TestP202SyncDiffV013RegressionSuite` の有無・呼出順を確認（Wrapperは参考、今回の必須実行対象ではない）
- [ ] テストに必要なFixtureの初期状態を把握。Excel Table / OFTへ変更が生じるTestは、作業用コピーまたは復元手順を確保
- [ ] `P05_NewOnly` / `P05_MixedNew` 等、P2-05専用FixtureがBaselineに残っていないことを確認（P2-01 Regression時点では除去済み）
- [ ] VBEのImmediate Window（`Ctrl+G`）でログを取得できる状態を用意
- [ ] 実行日時、Excel / VBA環境情報を記録

**Source Check判断**：現行Entry Point / Production Revisionに不一致が見つかった場合は、先にTest ArtifactまたはSource構成を照合する。安易にテスト内容・Productionを変更しない。

---

## 4. Regression 6 Suite・実行順・Entry Point

| 順序 | Suite | 過去の実行履歴にある個別Entry Point | 期待PASS数 | 現行ソース確認 | 実測 |
|---:|---|---|---:|:---:|:---:|
| 1 | Bootstrap | `TestP202SyncDiffBootstrapRegression` | **33/33** | ☐ | — |
| 2 | Detection History | `TestP202SyncDiffDetectionHistoryRegression` | **43/43** | ☐ | — |
| 3 | Date Serial | `TestP202SyncDiffDateSerialRegression` | **9/9** | ☐ | — |
| 4 | Core | `TestP202SyncDiffCore` | **18/18** | ☐ | — |
| 5 | Technical Negative | `TestP202SyncDiffTechnicalNegative` | **6/6** | ☐ | — |
| 6 | Contract Compatibility | `TestP202SyncDiffContractCompatibility` | **2/2** | ☐ | — |
| | **合計** | | **111/111** | | **未実施** |

**根拠区分**：4～6のEntry Pointは`P2-02 Completion Record v0.1`記載と一致。1～3およびWrapperは過去の実行履歴から回収した名称であり、今回の現行VBA Projectを未照合のため、最終確定前の確認対象とする。

**既存Wrapper参考**：`TestP202SyncDiffV013RegressionSuite`。過去の実行履歴上の呼出順は、Bootstrap → Detection History → Date Serial → Core → Technical Negative → Contract Compatibility。

### 今回の実行方法

**6つの個別Entry Pointを上表の順番でそれぞれ1回実行する**。一括Wrapper実行によるImmediate Windowの出力超過や先頭ログ欠落を避け、各Suiteの完全なEvidenceを確保する。対象Suiteの独立実行ができない場合は、その理由と依存条件を記録し、Wrapper利用を再評価する。

VBE Immediate Windowでの呼出例（**存在確認後**）：

```vb
TestP202SyncDiffBootstrapRegression
```

各実行について、先に前回ログを退避し、必要に応じてImmediate Windowをクリアしてから次のSuiteへ進む。クリア前に必ずログを保存する。

---

## 5. 6 Suite実施チェック

### R1 Bootstrap（33）

- [ ] 実行前Fixture / Workbook状態を記録
- [ ] `TestP202SyncDiffBootstrapRegression` を実行
- [ ] Immediate Windowに **33/33 PASS・FAIL 0** がある
- [ ] 全ログを `R1_Bootstrap_YYYYMMDD.txt` へ保存
- [ ] Unexpected Runtime Error / 異常な状態変更がない
- **実測**：____ / 33、FAIL ____、判定：____

### R2 Detection History（43）

- [ ] `TestP202SyncDiffDetectionHistoryRegression` を実行
- [ ] Immediate Windowに **43/43 PASS・FAIL 0** がある
- [ ] 全ログを `R2_DetectionHistory_YYYYMMDD.txt` へ保存
- [ ] Detection Historyに関するResultと異常の有無を確認
- **実測**：____ / 43、FAIL ____、判定：____

### R3 Date Serial（9）

- [ ] `TestP202SyncDiffDateSerialRegression` を実行
- [ ] Immediate Windowに **9/9 PASS・FAIL 0** がある
- [ ] 全ログを `R3_DateSerial_YYYYMMDD.txt` へ保存
- [ ] Date Serial / VBA Dateの扱いにRegressionがないことを確認
- **実測**：____ / 9、FAIL ____、判定：____

### R4 Core（18）

- [ ] `TestP202SyncDiffCore` を実行
- [ ] Immediate Windowに **18/18 PASS・FAIL 0** がある
- [ ] 全ログを `R4_Core_YYYYMMDD.txt` へ保存
- [ ] New / Existing / Reactivated / Unused、Canonical Name、No-op、Rename非推測、Metadata、Common SyncTimestamp、Input不変性の既存成立範囲を確認
- **実測**：____ / 18、FAIL ____、判定：____

### R5 Technical Negative（6）

- [ ] `TestP202SyncDiffTechnicalNegative` を実行
- [ ] Immediate Windowに **6/6 PASS・FAIL 0** がある
- [ ] 全ログを `R5_TechnicalNegative_YYYYMMDD.txt` へ保存
- [ ] Nothing、Invalid Candidate、Duplicate、Unknown Status、Structural Invariant等の既存Guardを確認
- **実測**：____ / 6、FAIL ____、判定：____

### R6 Contract Compatibility（2）

- [ ] `TestP202SyncDiffContractCompatibility` を実行
- [ ] Immediate Windowに **2/2 PASS・FAIL 0** がある
- [ ] 全ログを `R6_ContractCompatibility_YYYYMMDD.txt` へ保存
- [ ] P2-01 Scanner Carrier / P0 VariableDefinition Carrierの既存互換性を確認
- **実測**：____ / 2、FAIL ____、判定：____

---

## 6. Evidence取得規則

各Suite終了時、以下を**別々に**記録する。

| 項目 | 記録内容 |
|---|---|
| Test Suite / Entry Point | 呼び出したPublic Sub（実際の名前） |
| Test環境 | 実行Workbook、Source Revision / Commit、実行日時 |
| Initial State | 影響するFixture、TableまたはInputの初期状態 |
| Actual | Case別PASS/FAIL、総数、観測されたError |
| Runtime Evidence | Immediate Window全文。必要に応じてLocals / Debugger Evidence |
| Side Effects | Table / OFTの変更有無、必要な復元結果 |
| Outcome | `PASS / FAIL / BLOCKED`。未取得EvidenceはPASSにしない |
| Evidence Path | 個別Text LogまたはScreenshotの保存場所 |

**重要**：以前のP2-04 RegressionではImmediate Window出力超過で一部ログを保存できず、対象Testを再実行して補完した。今回の原則は1 Suite実行→Evidence保存→次Suiteとする。

---

## 7. Failure / Evidence不足時の分岐

1. **FAILを検出**：次Suiteへの無条件進行を止め、実行時のログ・Fixtureを保存。失敗位置と再現条件を記録。
2. **分類**：Production Defect / Test Artifact Defect / Fixture Defect / Contract Finding / Environment・Session Issueを分けて判断。根拠なしにProduction不良扱いしない。
3. **Evidence欠落**：Case未実施と混同せず `EVIDENCE INCOMPLETE` と記録。対象Suiteのみ再実行してログを補完する。
4. **Production Patchが必要**：承認済みContractとの整合確認を行い、修正後に影響範囲のRegressionを再実行。今回の旧PASSを無条件に新BuildのPASSへ流用しない。
5. **不安定な外部依存がある場合**：WordEditor事象 `OBS-P2-05-002` へ無根拠に同一原因として統合しない。該当Boundaryの実測情報を保存する。

ProductionへのTest専用Hook、Sleep、推測的DoEvents、Automatic Retryの追加はこのRegression準備の対象外とする。

---

## 8. Final Gate（このChecklistだけでは未判定）

- [ ] R1 = **33/33 PASS**
- [ ] R2 = **43/43 PASS**
- [ ] R3 = **9/9 PASS**
- [ ] R4 = **18/18 PASS**
- [ ] R5 = **6/6 PASS**
- [ ] R6 = **2/2 PASS**
- [ ] Total = **111/111 PASS**
- [ ] 全SuiteのEvidenceが保存され、欠落なし
- [ ] 検証したCurrent Production Source / Buildが明確
- [ ] Active Regression Finding = 0
- [ ] Blocking Regression Finding = 0
- [ ] `P2-02 Sync Diff Core Regression Record v0.1.md` 作成済み

Final Result：**NOT RUN / NOT DECIDED**（実測後に記入）

PASS後の次Action：**P2-03 VariableDefinition Sync Persistence Regression**。P2-02 Regression PASSはP2-05 CompletionやCP-P2確立を意味しない。

---

## 9. プロジェクト内推奨保存先

```text
定型メール作成ツール/
└─ P2-05 Fail Closed - Sync Result - Phase Integration/
   └─ Regression/
      └─ P2-02/
         ├─ P2-02 Sync Diff Core Regression 実施チェックリスト v0.1.md
         ├─ P2-02 Sync Diff Core Regression Record v0.1.md（PASS後作成）
         └─ Evidence/
            ├─ R1_Bootstrap_YYYYMMDD.txt
            ├─ R2_DetectionHistory_YYYYMMDD.txt
            ├─ R3_DateSerial_YYYYMMDD.txt
            ├─ R4_Core_YYYYMMDD.txt
            ├─ R5_TechnicalNegative_YYYYMMDD.txt
            └─ R6_ContractCompatibility_YYYYMMDD.txt
```

このパスは**プロジェクト内での論理保存先**。実際のOneDrive / ローカルのフォルダへの転記は別途必要。

---

## 10. まとめ / Summary

**日本語**：プレフライトCompileはPASS。P2-02 Regressionは6 Suite・111件の既存期待値を維持する。過去に確認された個別Entry Pointを現行Workbookと照合した後、各Suiteを個別実行し、Immediate Window Evidenceを保存する。全111件PASS、Evidence完備、Blocking Finding 0を確認したらRegression Recordを作成し、次のP2-03 Regressionへ進む。

**English**: The pre-flight compile passed. P2-02 regression has six suites and 111 checks. Confirm the test entry points in the current workbook. Run each suite separately and save its log. When all 111 checks pass and no blocking issue remains, create the regression record and move to P2-03.
