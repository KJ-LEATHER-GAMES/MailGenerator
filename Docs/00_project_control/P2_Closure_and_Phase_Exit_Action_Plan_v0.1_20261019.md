# P2 Regression Closure ～ P2 Phase Exit 実行計画 v0.1

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール（Excel VBA + Classic Outlook） |
| 作成日 | 2026-10-19 |
| 文書種別 | Execution / Project Control 計画（提案） |
| Status | DRAFT / NOT APPROVED |
| 主な根拠 | `Context_Handoff_P2-04_I12_20261019(1).md`、`P2-05 ... Implementation Specification v0.1 — Approved`、`Implementation Plan v0.3`、`AI協働開発 文書管理・Baseline運用ルール v0.1` |
| GitHub格納候補 | `Docs/00_project_control/P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md` |

> **作業の境界**：本書は引継ぎ時点の計画であり、GitHubの最新実体・未添付Raw Evidence・実行Workbookをこの会話で独立再検証したものではない。GitHubへの登録、承認、Commit/Push、Workbook変更は未実施。

## 1. 現在地

| 対象 | 引継ぎによる技術判定 | 正式状態 / 次に必要な作業 |
|---|---|---|
| P2-01 | Regression PASS / CLOSED | 既存Recordを保持、I12参照を確認 |
| P2-02 | 111/111 PASS | Regression Record正式Closure未完了 |
| P2-03 | 46/46 PASS | Regression Record正式Closure未完了 |
| P2-04 | 新Cycle 182/182 PASS | Regression Record正式更新未完了 |
| P2-04 I12 | TECHNICAL PASS / REVIEWED | Formal Closure / Registry同期未完了 |
| P2-05 | Completion未判定 | 最終Compile、Static S01–S32等を完了して判定 |
| P2 Phase | Phase Exit未判定 | P2 Phase Verification → Exit Criteria → CP-P2 |
| Formal MVP Test | 実施済みと主張できない | P7で固定したTest Candidate Buildに対して別途実施 |

**既決事項を変更しない**：I12は過去Evidence再利用方式を承認済み。9 Production Modulesの正規化一致は9/9。2026-10-10 Compile PASS以後、当該VBAProjectのProduction Modules / Test Harnessの追加変更なしは実行者確認。これらを10月18日独立Compileや実行Workbookバイナリの完全一致と表現しない。

## 2. 推奨実施順序とGate

```text
S0  作業対象・証拠の棚卸し（Read-only）
  ↓
S1  Evidence保管先・原本保全・公開範囲を決定
  ↓
S2  P2-02 / P2-03 Regression Record の正式Closure
  ↓
S3  P2-04 I12 および P2-04 Regression の正式Closure
  ↓
S4  Document Registry / Project Overview / BL-MVP-004 の整合更新
  ↓
S5  P2-05 Completion Gate（最終Compile、S01–S32、Review、Finding）
  ↓
S6  P2 Phase Verification / Exit / CP-P2
  ↓
後続  P3（必要な依存Gateを満たした後）
```

注：S4の「差分調査」とS5の「既存Evidence棚卸し・Static Review準備」は、S1～S3と並行して**読取り専用**で進められる。Registryの確定更新やP2-05のCompletion判定は必要な先行Gateがそろってから行う。S0～S6の途中で新規Production変更が発生した場合、Source/Build連続性とRegression再利用の影響を再評価する。

## 3. 作業パッケージ

### S0 — 作業対象・Evidence棚卸し

**目的**：Candidate文書と原本、実行WorkbookとGitHubの古いWorkbook、版付きProduction Sourceを混同しない。

- GitHub HEAD、作業ブランチ、Working Tree差分を記録する（変更しない）。引継ぎ時点の `main=edf5c5175b103e250144341071d885a3a992c65f` は歴史的参照値。
- `Docs/02_implementation/` の9 Production Sourceに対する引継ぎ文書の対応表を確認する。`src/modules/` やGitHubルートの `MailGeneratorNew.xlsm` を最新実行Buildとみなさない。
- P2-02 / P2-03旧Regression Record、P2-04新Cycle Draft Record、I12 Decision / Assessment / Matrix、Archive Manifestの実在・版数・状態を一覧化する。
- 未添付の原文ログ3件、Source ZIP、各Review候補の保管場所を確認し、Evidence欠落を明示する。
- P2-05のI01～I17、K01～K04、Production Source Review、Patch Design、その他Completion Evidenceの有無を棚卸しする。既にPASSが確証できるケースは再試験を要求しない。

**Done When**：各対象に「正本候補・パス・Version・Status・Evidence参照・不足」の列があり、未確認をPASSと見なしていない。

### S1 — Evidence ArchiveとProvenanceの確定

**主な入力**：

- `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`
- `261018_P2-02_Regression Log.txt`
- `261018_P2-03_Regression Log.txt`
- `261018_P2-04_Regression Log.txt`
- `P2-04_Regression_20261018.zip`
- `P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md`

**方針**：

1. 原本は不変・非公開領域で保全する。原本SHA-256、実際の保管位置、取得時点をManifestへ記録する。
2. Windows個人ユーザーパス等を含むRawを公開Repoへ無加工で登録しない。公開が必要なときのみ**別コピー**でマスキングし、原本と公開版に別のハッシュを付与する。
3. GitHubには原本へのアクセス制御を侵さない形で、Manifest・Review・Decision・Evidence Indexを登録する（既存の `Docs/03_verification/technical_validation/` を主候補とし、実際のフォルダルールを優先）。
4. 記録粒度は `Test Run / Source Revision / Workbook Hashの証拠種類 / Baseline / Fixture / Finding / Evidence Location / Visibility`。
5. 引継ぎにあるWorkbook SHA-256は**USER-ATTESTED**と表記する。9/9一致は正規化全文の一致であってバイナリ同一性ではない。

**Done When**：S2/S3の各正式Recordが実在Evidenceを一意に参照でき、公開範囲を説明できる。欠けた原本がある場合は、それを明示してClosure Gateで扱う。

### S2 — P2-02・P2-03 Regression Record正式Closure

**対象**：

- `Docs/03_verification/technical_validation/P2-02 Sync Diff Core Regression Record v0.1.md`
- `Docs/03_verification/technical_validation/P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md`
- `P2-02_Sync_Diff_Core_Regression_Closure_Review_v0.3_Candidate.md`
- `P2-03_Sync_Persistence_Regression_Closure_Review_v0.3_Candidate.md`

**作業**：原Recordを削除・無言上書きせず、Repoの版管理規則に従って新Revisionまたは追補を作成。対象Suite、原文ログ、Production Source、Baseline、Compile continuity、Fixture復元、Finding、過去Run日と新Closure日を区別して記録する。

**見落とし防止**：

- P2-02末尾のBootstrap 33件再掲を二重加算しない（111/111）。
- P2-03の`Original tblVariableDefinition contents restored`はテーブル内容復元のEvidenceであり、Workbook全体の完全復元とは言わない（46/46）。
- 旧Completion RecordをRegression Recordへ置き換えない。Unit CompletionとRegression Closureは異なる。

**Done When**：個別のClosure承認条件が満たされ、正式Record・Status・Evidence参照の整合が取れている。承認前は `CANDIDATE` として保持。

### S3 — P2-04 I12 / Regression 正式Closure

**入力**：

- `P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md`
- `P2-04_I12_Historical_Regression_Evidence_Applicability_Assessment_v0.1_Draft.md`
- `P2-04_I12_Final_Quality_Gate_Assessment_v0.3_Review_Result.md`
- `P2-04_I12_Evidence_Reconciliation_Matrix_v0.8_Draft.md`
- `P2-04_Manual_Sync_Integration_Regression_Record_v0.3_Draft.md`

**作業**：S2で確定したP2-02/P2-03を参照し、I12の採用したEvidence再利用方針、対象Contract、証拠限界、承認者／承認日をFormal Closureへ反映。P2-04新Cycleの182/182 PASSをRecordへ正式反映する。

**必ず残す境界**：

- I10初回 `ABORTED` と準備後20/20 PASSを区別（ABORTをPASS数へ含めない）。
- I07 Expected FailureとI08 Fresh Retry PASSはRollback・Atomicityの一般保証と同一視しない。
- I01/I02は旧補足Evidence（Source Revision差異の限界を保持）。
- OBS-P2-05-002はOPEN / NON-BLOCKINGを維持（別途正式な変更判定がない限り）。
- I12 Formal ClosureはP2-05 COMPLETE、CP-P2、Formal MVP Test PASSを意味しない。

**Done When**：I12 ClosureとP2-04 RegressionのStatus／Evidence／対象Sourceが矛盾なく確定し、Registryに登録可能な状態。

### S4 — Project Control / Baseline整合

**現状の論点**：`BL-MVP-004_Approval_Record_v0.1.md` は2026-10-01 APPROVEDと記録される一方、`Document_Registry.md` / `Project_Overview.md` はBL-MVP-003の受入・同期状態を残す。

**作業**：

1. BL-MVP-004の承認記録・構成Manifest・適用開始・対象の影響評価を確認。
2. 「最新Approved Baseline」「当時のExecution Baseline」「Repository側の受入/同期状態」を別の列で区別。
3. 必要な承認／受入手続を経て `Document_Registry.md` と `Project_Overview.md` を整合更新。
4. P2の既存Execution Evidenceの `BL-MVP-003` を遡及変更しない。`Implementation Plan v0.3` の履歴的なBL-MVP-003記録も理由なく一括置換しない。
5. Requirements / Design / Test SpecificationをBaseline番号の同期だけのためにVersion Upしない。

**Done When**：現行の承認Baselineを一意に判定でき、履歴Evidenceの使用Baselineも再現できる。

### S5 — P2-05 Completion Quality Gate

**一次Source of Truth**：`P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification v0.1 — Approved` §59～§61。

**順序**：

1. Current Production Source Review / Production Patch Design / Production Implementationの既存完了Recordと対象Source Revisionを照合。
2. P05-I01～I17（Applicable Cases）とP05-K01～K04のEvidenceを確認し、不足Caseに限り追加Verification。
3. **現行の実行WorkbookのVBAProjectで `Debug > Compile VBAProject` を実施して新しいPASS Evidenceを取得**。対象Workbook名・格納位置・実施日・VBAProject構成と、必要ならSHAを記録。古いGitHubルートWorkbookでは実行しない。
4. Approved Checklist S01～S32を対象Production SourceへStatic Reviewし、各項目PASS/FAIL/NOT REVIEWEDを記録。
5. Production Patch Review → Final Finding Assessment → Completion Criteria Final Check → Completion Decision。
6. Finding Register全体を照合し、**Active Finding 0 / Blocking Finding 0**が成立することを確認する。`OBS-P2-05-002`はOPEN / NON-BLOCKINGのObservationとして別管理する。既存のFinding分類と矛盾する場合は勝手に0としない。

**変更管理**：新たなProduction修正・Test Harness修正があればCompile continuityの前提を見直し、影響範囲のRegression要否を判定する。

**Done When**：Approved §59の全Completion Criteriaを個別根拠で満たし、`P2-05 PASS / COMPLETE`を正式記録できる。I12だけで自動承認しない。

### S6 — P2 Phase Exit / CP-P2

**作業**：

1. P2-01～P2-05 Completion・Regression・Compile・FindingをPhase Verificationへ引き渡す。
2. `Implementation Plan v0.3` §8.3 のP2 Phase Verificationを再照合。
3. P2 Exit Criteria（Scanner結果、Classification、設定保持、Invalid Template Fail Closed、Metadata、Blocking Findingなし）を個別判定。
4. Source Revision / Workbook Build / Evidence / Baseline / Git CommitをCheckpointにひも付ける。
5. P2 Exit PASS後、別判定として `CP-P2 ESTABLISHED`を承認・記録する。

**Done When**：Phase ExitとCP-P2の正式Recordがある。Formal MVP Test PASSとは表示しない。

## 4. 実行・レビューの責務分担（提案）

| 担当 | 推奨作業 | 禁止・留意事項 |
|---|---|---|
| Codex | GitHub現物のRead-only棚卸し、文書差分、Manifest作成、Record改訂案、S01～S32のソース静的チェック補助 | 指示なくStatusをCLOSEDにしない。Commit/Pushしない。古いWorkbookを正本扱いしない |
| ChatGPT | Evidenceの解釈、判定境界のレビュー、Cross-document consistency、Closure Gateの品質審査補助 | USER-ATTESTEDを独立証明と表示しない。I12 PASSからP2-05完了へ飛躍しない |
| 実行者（ユーザー） | 原本保管先/アクセス範囲の決定、Excel/Outlook実機Compile・不足テスト、正式承認、GitHub反映の最終判断 | 実行したと確認できない試験をPASS登録しない |

## 5. リスク・エスカレーション

| リスク | 判定軸と対策 |
|---|---|
| 原文ログの公開 | 個人パス・機密情報が含まれる場合は非公開原本と公開マスク版を分離。原本上書き禁止 |
| 正本不明なWorkbook | GitHubルートの古いxlsmでCompileしない。実機で使用するWorkbookと9 Sourceを特定 |
| BL-MVP-003 / 004混同 | Approved / Current / Historical Executionを分離。過去Record改ざん禁止 |
| I12の過大Claim | 9/9正規化一致とWorkbookバイナリ完全一致を区別。過去Evidenceを新Runに数えない |
| WordEditor断続的E_FAIL | OBS-P2-05-002を監視。再現時は失敗Session保全・診断。根拠なきSleep/自動Retryは追加しない |
| ドキュメント増殖 | 既存RecordとManifestを優先し、不要な別帳票を作らない。必要な変更だけRevision化 |
| 新たなProduction変更 | Compile continuity / Regression reuseを再評価し、影響に応じて必要Caseのみ再確認 |

## 6. 最初の着手単位（次チャットまたはCodex依頼）

**S0＋S1の前半をRead-onlyで実施する。**

作業依頼例：

> 対象Repositoryを読み取り専用で確認してください。まずHEAD、ブランチ、未Commit差分を記録してください。P2-02/P2-03 Regression Record、P2-04 I12 Decision / Assessment / Matrix / Draft Record、Evidence Archive Manifest、Project Overview / Document Registry / BL-MVP-004 Approval Record、P2-05 Completion関連Recordの存在・Status・Version・所在を棚卸ししてください。版付きProduction Sourceと `src/modules/`、GitHubルートの古いxlsmを明確に区別してください。各Artifactについて「GitHubパス、Status、依存元Evidence、欠落、修正必要性」を表にまとめ、推奨する最小変更セットと実施順を示してください。**この依頼ではファイル修正、Commit、Push、Baseline変更、正式Closure承認、Production修正を行わないでください。**

**S0着手完了判定**：GitHubにある物と、ローカル/非公開領域にしかない物と、存在未確認の物が分離できている。続いてS1で原本保管ポリシーを決める。

## 7. 結論・Summary

- **日本語**：最初にEvidenceとRepositoryの正本を整理し、P2-02/P2-03 → I12/P2-04を正式Closureする。その後、Baseline/Registryを同期し、P2-05の残Gateを満たしてからP2 Exit / CP-P2へ進む。不要な再試験や文書Version更新は避ける。
- **English**: First, organize the evidence and source files. Then close P2-02, P2-03, and I12/P2-04. Update the baseline records, complete the P2-05 checks, and finally approve P2 Exit and CP-P2. Avoid extra tests and document changes.
