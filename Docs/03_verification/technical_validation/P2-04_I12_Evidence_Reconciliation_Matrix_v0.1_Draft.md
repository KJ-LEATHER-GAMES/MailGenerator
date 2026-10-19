# P2-04 I12 Contract Regression Evidence照合マトリクス v0.1（Draft）

## 1. 文書情報・判定

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール MVP（Excel VBA + Classic Outlook） |
| 対象 | P2-04 Manual Sync Integration — I12 Contract Regression Evidence統合 |
| 文書種別 | Execution / Handoff（新Regression CycleのEvidence照合作業記録） |
| 作成日 | 2026-10-18 |
| Version / Status | **v0.1 / DRAFT — EVIDENCE RECONCILIATION IN PROGRESS** |
| 対象Workbook（引継ぎ記載） | `MailGeneratorNew.xlsm` — 実ファイル・Build識別は未確認 |
| Current Approved Baseline | **未確認**。既存Implementation Planは`BL-MVP-003 Approved`を記載。今回のBootstrapログは`BL-MVP-004`と記載されたとの引継ぎ。承認記録との照合未了 |
| Current Build / Commit | **未確認** |
| 今回Regression実施日 | 引継ぎでは「2026-10-18を中心とする一連のRegression」。個別ログの日時・実施者・環境は未確認 |
| I12の今回サイクルの判定 | **PENDING（PASS/CLOSEDは宣言しない）** |
| P2-04既存Unit Completion | **PASS / COMPLETE（既存Completion Recordの判定をそのまま保持）** |
| Formal MVP Test | **NOT CLAIMED** |

> **範囲の区別**：本マトリクスは「新しいRegression CycleのEvidence照合」の開始成果物であり、既存のP2-04 Completion Recordや過去のI12 `PASS / FINALIZED`を改訂・取消し・再承認しない。ここに記載する今回のPASSは、原則として引継ぎ記録による報告値であり、生ログ／Buildを独立検証した結果ではない。

### 1.1 証拠の強さを示す表記

| 表記 | 意味 |
|---|---|
| `RECORD-CONFIRMED` | 現在参照可能な独立Record／既存Completion資料の記載を確認した。**現在Buildへの適用可否は別判定** |
| `HANDOFF-REPORTED` | 今回の引継ぎまとめに実行・結果の記載あり。生ログ未照合 |
| `SECONDARY-SUMMARY` | 過去の統合記録に結果の要約あり。独立した対象Regression Recordやログは未照合 |
| `NOT VERIFIED` | 必要な現物、識別情報、ログ、正式状態を未確認。推定で補完しない |
| `N/A (THIS CYCLE)` | 今回のCycleでは実行されていないことが引継ぎで明示されたもの。過去実績がない意味ではない |
| `PENDING` | このCycleとしてのI12 Gateの判定を保留 |

## 2. ソース／Evidence所在台帳

| ID | 文書・証拠 | 今回確認できた事実 | Evidenceの扱い | 未確認事項 |
|---|---|---|---|---|
| S-01 | `Pasted text(5).txt`（引継ぎまとめ） | 今回のBootstrap 29、I03～I11 153、合計182 Assertion PASSの記載 | `HANDOFF-REPORTED` | 当該Cycleの生ログ、実施環境、Commit |
| S-02 | `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md`（`P2-04_Documents.zip`収録） | **過去**のP2-01～P2-03、Bootstrap、I12を`PASS / FINALIZED`と記載 | `RECORD-CONFIRMED`（過去の統合判断） | 今回CycleとのBuild同一性・変更差分 |
| S-03 | `P2-04 Manual Sync Integration Completion Record v0.1.md`（同ZIP） | **既存Unit**はI01～I12 `12/12 PASS`、`PASS / COMPLETE`。`BL-MVP-003`を使用 | `RECORD-CONFIRMED`（既存Completion） | 今回Build・実行状態への再適用性 |
| S-04 | `P2-01 Full Template Scanner Regression Record v0.1.md` | 2026-10-09、`BL-MVP-003`、Core 11/11、OFT Integration PASS、Recipient Exclusion PASS、`PASS / CLOSED` | `RECORD-CONFIRMED`（独立Regression Record） | 対象Build/Commitと今回Buildの一致・変更影響 |
| S-05 | `P2-02 Sync Diff Core Completion Record v0.1.md` | **Unit Completion**はPASS。ただし当該文書は今回必要な**独立Regression Recordの代替ではない** | `RECORD-CONFIRMED`（Unit Completionのみ） | 独立Regression Record、Closure保留解除の記録 |
| S-06 | `16_P2-03.txt` 内のP2-03 Completion文面 | **Unit Completion**はPASSとの記載。後続のControlled Correctionとの版整合未確認 | `SECONDARY-SUMMARY`（Unit Completion文面） | 独立Regression Recordと正式Closure |
| S-07 | `Implementation Plan v0.3 日本語版(2).md` | `BL-MVP-003 Approved`、仕様Baselineの構成を記載 | `RECORD-CONFIRMED`（計画上の宣言） | 独立のApproved Baseline Manifest/Approval Recordの現物 |
| S-08 | `P2-04 Manual Sync Integration Completion Criteria Final Check v0.1.md`（同ZIP） | 過去のCompletion Criteria判定資料として利用可 | `RECORD-CONFIRMED`（既存Unitの判断資料） | 新しいRegression Cycleの判定根拠には自動転用しない |
| S-09 | `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md` | P2-04のPublic ContractおよびP2-05との責務境界を確認可 | `RECORD-CONFIRMED`（仕様/Contract参照） | このCycleのI12実行条件・完全な受入基準の代替ではない |
| S-10 | `P2-04 Manual Sync Integration Regression 実施計画 v0.1.md` | 引継ぎに**文書名のみ**登場 | **NOT VERIFIED／現物未用意** | I12の要求範囲・各Caseの正式Expected・再利用条件 |
| S-11 | `P2-02 Sync Diff Core Regression Record` | 引継ぎ：111/111 PASS。過去S-02にも111/111の記載 | **NOT VERIFIED／独立Record未用意** | 対象Build・実施日・Closure判定・生Evidence |
| S-12 | `P2-03 VariableDefinition Sync Persistence Regression Record` | 引継ぎ：46/46 PASS。過去S-02にも46/46の記載 | **NOT VERIFIED／独立Record未用意** | 対象Build・実施日・Closure判定・生Evidence |
| S-13 | Approved Baseline Manifest / `BL-MVP-003`・`BL-MVP-004`承認記録 | 今回未用意。S-07と引継ぎの表記に差異あり | **NOT VERIFIED** | 正式なCurrent Approved Baseline、`BL-MVP-004`の実在/状態 |
| S-14 | 現行Workbook、Export済Production Source、Git Commit / Build Manifest | Workbook名以外は今回未用意 | **NOT VERIFIED** | 現行Build ID、ソース差分、S-02～S-04適用性 |
| S-15 | 今回182 AssertionのRegression生ログ、スクリーンショット、保存先 | 引継ぎは結果のみ。Evidenceファイルと保存先は未用意 | **NOT VERIFIED** | Assertion明細、実行時刻、環境、Fixture原状復帰、ABORT履歴原文 |
| S-16 | 今回の`P2-04 Manual Sync Integration Regression Record v0.1.md` | 引継ぎで未作成と明記 | **NOT CREATED** | Step 3で生成・Closure判定を実施 |

**注意**：S-02の過去集計とS-01の今回集計に同じ値（例：Bootstrap 29）が現れても、**同一の実行であるとも異なる実行であるとも断定できない**。Run ID・日時・Buildがない段階では同一性を推測しない。S-02は過去のCompletion根拠、S-01は今回Cycleの引継ぎとして別管理する。

## 3. Regression Coverage × Evidence照合マトリクス（今回Cycle）

| ID | 対象／Contract | 今回Cycleの実行報告 | 当該実行のRaw Evidence | 既存資料との関係 | I12統合時の暫定扱い |
|---|---|---|---|---|---|
| R-00 | P2-02→P2-03 Bootstrap Production Compatibility | **29/29 PASS**。`TestP202P203BootstrapProductionCompatibility` | **未確認** | S-02にも過去29/29 PASSあり。今回のRunとの同一性は不明 | `HANDOFF-REPORTED` / Build未照合 |
| R-01 | I01 Happy Path | **N/A (THIS CYCLE)**：今回の再実行なし | **未確認** | S-03で過去PASS。S-01は過去Implementation Evidenceとして再利用検討 | `RECORD-CONFIRMED`（過去のみ） / 再利用可否PENDING |
| R-02 | I02 Common SyncTimestamp | **N/A (THIS CYCLE)**：今回の再実行なし | **未確認** | S-03で過去PASS。今回のI08等をI02完全再実行とみなさない | `RECORD-CONFIRMED`（過去のみ） / 再利用可否PENDING |
| R-03 | I03 Invalid Candidate Fail Closed | **10/10 PASS**。`TestP204I03InvalidCandidate` | **未確認** | InvalidCandidates保持／同期しないと引継ぎに記載 | `HANDOFF-REPORTED` / Build未照合 |
| R-04 | I04 OFT Missing | **11/11 PASS**。`TestP204I04OftMissing` | **未確認** | `ConfigurationError / TemplatePath`と復元を引継ぎに記載 | `HANDOFF-REPORTED` / Build未照合 |
| R-05 | I05 Definition Read Failure | **17/17 PASS**。`TestP204I05DefinitionReadFailure` | **未確認** | Scanner結果のみPublished、SyncDiffなしとの記載 | `HANDOFF-REPORTED` / Build未照合 |
| R-06 | I06 BuildSyncDiff Failure | **22/22 PASS**。`TestP204I06BuildSyncDiffFailure` | **未確認** | 不正StatusによりFailure。Preflight見出しの誤記あり | `HANDOFF-REPORTED` / Build未照合 |
| R-07 | I07 ApplySyncDiff Failure + I08 Fresh Retry | **合算37/37 PASS**。`TestP204I07I08ContinuousRetry` | **未確認** | Failure→解除→明示的再実行の連続検証 | `HANDOFF-REPORTED` / **I07とI08の個別Assertion数は未確認** |
| R-09 | I09 Warm Lifecycle | **16/16 PASS**。`TestP204I09WarmLifecycle` | **未確認** | Explorer維持、Inspector/Draft残留なしとの記載 | `HANDOFF-REPORTED` / Build未照合 |
| R-10 | I10 Cold Lifecycle | **20/20 PASS**。`TestP204I10ColdLifecycle` | **未確認** | 初回ABORT、Baseline再準備後に成功。ABORT原因未確定 | `HANDOFF-REPORTED` / ABORT履歴と最終PASSは併記 |
| R-11 | I11 Manual Only / Reopen | **20/20 PASS**。`TestP204I11ManualOnlyAfterReopen` | **未確認** | Workbook再起動中の自動Syncなし／明示SyncはPASSとの記載 | `HANDOFF-REPORTED` / Build未照合 |
| R-12 | I12 Contract Regression **統合判定** | **今回Cycleは未実施**（I12専用Aggregatorなし） | **未確認** | S-02は**過去Cycleの**I12 `PASS / FINALIZED`を明記 | **PENDING**。過去のPASSを今回のPASSへ繰り入れない |

**算術照合（引継ぎの集計値に対してのみ）**：Bootstrap 29 + I03 10 + I04 11 + I05 17 + I06 22 + I07/I08 37 + I09 16 + I10 20 + I11 20 = **182**。I03～I11は **153**。これは**今回報告されたHarness Assertion数**であり、I01/I02/I12、P2-01～P2-03の過去Assertionを含まない。独立Test Case総数やFormal Test件数でもない。

## 4. 前段Regression Evidenceの再利用可否（暫定）

| 対象 | 過去/既存に確認できた結果 | 現在参照できる一次／独立Record | 新Cycleへの再利用判定 | 保留理由 |
|---|---|---|---|---|
| P2-01 Scanner | Core 11/11、Baseline OFT PASS、Recipient Exclusion PASS、`PASS/CLOSED` | **あり：S-04** | **PENDING** | 現行Buildとの変更影響・Source対応未確認。S-04は最初のReadBodyText失敗とFresh WarmでのPASSも記録 |
| P2-02 Sync Diff | **111/111 PASS（S-02／引継ぎ）** | **独立Regression Record未用意**。Unit Completion S-05は別 | **PENDING** | Regression RecordのClosure（引継ぎではBaseline/Build対応保留）とBuild同一性未確認 |
| P2-03 Persistence | **46/46 PASS（S-02／引継ぎ）** | **独立Regression Record未用意**。Unit Completion S-06は別 | **PENDING** | Regression RecordのClosureとBuild同一性未確認 |
| P2-02→P2-03 Bootstrap | **過去29/29 PASS（S-02）**、今回29/29 PASS（S-01） | **今回生ログ未用意** | **PENDING** | Run ID/Build/ログ照合不可。両者を別のEvidence候補として扱う |
| I01 / I02 | **過去各PASS（S-03）** | **独立の旧実行ログ未用意** | **PENDING** | 過去Evidenceの適用範囲と現行Buildの変更影響未確認 |

**ソース版の注意**：S-03はP2-04作業中のControlled Correctionとして`modSyncEngine_P2-02_v0.1.1_CP932.bas`および`modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas`を記録している。S-05/S-06のUnit Completion時点の版名と同一とは限らない。Regression Evidenceの適用は**実際のExport済みProduction Source・Commit**と照合して判断する。

## 5. Contract観点のCoverage候補（正式I12受入基準ではない）

**注**：S-10のRegression実施計画が未確認のため、本表は既存資料から整理した**暫定Traceability候補**である。正式なI12 Expected Resultsに置き換えたり、Coverage完了を宣言したりしない。

| Contract観点 | 照合先候補 | 現在わかる範囲 | 保留条件 |
|---|---|---|---|
| Scanner Carrier（ValidVariables / InvalidCandidates / Locations） | S-04、R-03 | 独立Scanner Regression Recordと今回Invalid Candidate報告あり | 現行Build適用性 |
| 4分類・Case-insensitive identity・Metadata | P2-02 111件の既存報告、R-07、R-00 | 旧集計と今回Bootstrap/Retryの報告あり | P2-02独立Recordと差分照合 |
| Persistence / User Configuration保持 | P2-03 46件の既存報告、R-00、R-07 | 旧集計と今回Fixture関連報告あり | P2-03独立Record、Build差分、部分書込み保証の誤解排除 |
| Application Happy Path | R-01、R-11 | I01は過去PASS、I11は今回報告PASS | I01の再利用妥当性 |
| Common SyncTimestamp | R-02、R-07 | I02過去PASS。I08で新Timestamp報告 | I02全Contractを今回再実行したとのClaimは禁止 |
| Fail Closed / Result Carrier公開段階 | R-03～R-07 | Failure Stageごとの結果と`syncDiffResult = Nothing`等を引継ぎに記載 | 生ログでActual Result確認 |
| Warm / Cold Outlook Lifecycle | R-09、R-10、S-04 | 今回はいずれもPASS報告、S-04は初回ReadBodyText問題あり | E_FAIL Observationは解決扱いにしない |
| Manual Only / explicit user action | R-11 | Workbook Openでは同期なし、明示同期で成功との報告 | 生ログと対象Build |
| Fresh Retry | R-07 | Failure→条件修正→明示再実行との報告 | 自動Retry/Atomicityの保証を追加解釈しない |

## 6. Baseline / Build / Evidence Blocker台帳

| Blocker | 確認すべき対象 | 現状 | 閉鎖条件 |
|---|---|---|---|
| B-01 | Approved Baseline Manifest / Approval Record | **NOT VERIFIED**。S-07に`BL-MVP-003 Approved`の計画記載はあるが、Manifest現物は未用意 | 承認済みBaseline ID・Manifest構成・Statusを正式記録で照合 |
| B-02 | `BL-MVP-003` vs `BL-MVP-004` | **NOT VERIFIED**。今回Bootstrapログの`BL-MVP-004`は引継ぎ情報であり、承認の証明でない | 実ログ定数、承認記録、実装側の基準を突き合わせ、誤記か正式差分か判断 |
| B-03 | 現行Workbook Build / Commit | **NOT VERIFIED** | 実ファイルとGit Commit/Build Manifest/Exportソースを識別し、旧Evidence適用範囲を確認 |
| B-04 | 今回のRegression生ログ・Evidence保存先 | **NOT VERIFIED** | R-00、R-03～R-11の実行ログ・実行日時・保存先・対応Build・Fixture復元証跡を特定 |
| B-05 | P2-04 Regression実施計画 | **NOT VERIFIED** | I12の正式Scope・Expected・Entry/Exit条件を現物と照合 |
| B-06 | P2-02 / P2-03独立Regression RecordとClosure | **NOT VERIFIED** | 111件/46件の個別Record、正式Closure状態、対象Buildを照合 |
| B-07 | I01 / I02旧Evidenceの再利用判断 | **PENDING** | 旧Evidenceの時点・対象Buildを追跡し、新Buildへの変更影響Reviewで再利用可否を判断 |
| B-08 | I10 ABORT履歴 | **HANDOFF-REPORTED** | 初回ABORT・Baseline Preparation・最終20/20 PASSの時系列を生ログに紐付け。原因は根拠なしに確定しない |
| B-09 | Environment / Fixture復元の完全性 | **NOT VERIFIED** | OS・Excel/Outlook版／bit数／実施者と、OFT/Settings/VariableDefinition/保護状態などの復元Evidenceを照合 |

`B-01`～`B-09`は**Evidence／Governance上の未解決項目**であり、直ちにProduction Defectや「Regression FAIL」を意味しない。Blockingかどうかの正式分類はS-10のCriteria確認後に判断するが、**本表の状態ではI12 PASS/CLOSEDへの移行を認めない**。

## 7. Observation／実行上の留意点

| ID | 事実の記録 | 現時点の取扱い |
|---|---|---|
| `OBS-P2-05-002` | WordEditor断続的E_FAIL。既存`OPEN / NON-BLOCKING`、今回I09/I10で再現なしと引継ぎ | **OPEN / NON-BLOCKINGを維持**。根本原因は未証明。再発時は別途切り分け |
| I10初回ABORT | `I10 baseline has not been prepared in this VBA session`。同一VBAセッションでBaseline準備後、20/20 PASS | **ABORTとPASSを併記**。操作原因を確定しない |
| I06のPreflight見出し | `I05 Normal Template Preflight`が残存 | **軽微なTest Artifact観察**。Production Defectとは扱わない |
| I07 Write Failure | 一時保護による書込失敗、今回の観測ではBefore/After一致 | **Rollback／Atomicity保証なし**。部分更新の可能性は仕様上残る |
| Fixture操作 | テストHarnessは実際のExcelテーブル行を一時削除・再作成する | セル値の復元確認を完全状態（数式・書式・入力規則等）復元保証へ拡大しない |

## 8. I12判定ゲート（今回Cycle）

| Gate | 判定条件 | 現状 |
|---|---|---|
| G-01 | 正式I12 Scope / Expected / Completion条件が照合できる | **PENDING**（S-10未用意） |
| G-02 | 対象Baselineの承認状態とBuild対応が追跡できる | **PENDING**（B-01～B-03） |
| G-03 | P2-01～P2-03独立Regression Evidenceを参照でき、再利用可否を説明できる | **PENDING**（S-04あり、S-11/S-12未用意） |
| G-04 | I01/I02の旧Evidenceを今回Buildに適用する根拠がある | **PENDING**（B-07） |
| G-05 | 今回182件の生ログを個別Harness・Buildへ対応付けられる | **PENDING**（B-04） |
| G-06 | ABORT・Observation・Fixture復元・FindingをEvidenceで評価できる | **PENDING**（B-08/B-09） |
| G-07 | I12のContract Coverageに未評価の必須項目が残らない | **PENDING**（G-01～G-06に依存） |

**現時点の判定：`I12 CURRENT REGRESSION CYCLE = PENDING / NOT CLOSED`。**

この判定は **過去P2-04 Completion Recordの`PASS / COMPLETE`、過去Regression Evidence Finalizationの`PASS / FINALIZED`、P2-01独立Regressionの`PASS / CLOSED`を変更しない**。

## 9. 次の照合順序（新規実行ではなくEvidenceの特定を優先）

1. **Baseline／Buildを特定**：S-13・S-14を確保し、`BL-MVP-004`表記の意味を確認。推定修正しない。
2. **生ログと保存先を特定**：S-15の各RunをR-00、R-03～R-11に結び付け、I10のABORT→PASSを残す。
3. **Regression実施計画と独立Recordを確保**：S-10～S-12の正式Criteria、111件・46件のClosure状態を確認。
4. **旧EvidenceのBuild適用性を判定**：S-02～S-04、I01/I02、P2-02/P2-03を比較。影響がある場合のみ必要範囲を再Verification。
5. **I12 Gateを再判定**：G-01～G-07を消し込み、Finding AssessmentとFixture復元の証拠を結合。
6. **別工程としてP2-04 Regression Recordを作成**：Closure可能な状態でのみ`PASS / CLOSED`。未充足なら`DRAFT / CLOSURE PENDING`のまま維持。

**ゲート分離**：I12新Cycle／P2-04 Regression Closure／P2-05 Completion／P2 Phase Exit／CP-P2 Establishmentは独立判定とする。

## 10. 保存・Source of Truthの扱い

- 本書の生成先（このチャットで確認できるファイル）：`/mnt/data/P2-04_I12_Evidence_Reconciliation_Matrix_v0.1_Draft.md`
- **プロジェクトフォルダ内の正式保存先：未確認**。フォルダ構成ルールおよび実リポジトリを確認していないため、フォルダパスは創作しない。
- 分類上は `Execution / Handoff` の**新Cycle作業記録**。正式なBaseline ManifestでもTest Resultの承認記録でもない。
- 同名の既存文書の上書きや、既存`P2-04 Regression Evidence Finalization v0.1`の履歴改変は行わない。

---

## まとめ / Summary

**日本語**：I12の新Regression CycleについてEvidence照合マトリクスを作成した。182/182 PASSは引継ぎ報告値として記録し、旧Completionや旧I12 PASSとは区別した。Baseline、Build、生ログ、Regression実施計画、P2-02/P2-03独立Recordが未確認のため、今回のI12 ClosureはPENDINGとする。

**English**: The I12 evidence matrix is ready as a draft. The handoff reports 182 of 182 checks passed. Old completion records are kept separate. The baseline, build, raw logs, plan, and some regression records are not verified. The new I12 cycle remains pending.
