# Codex作業指示書 — S0 作業対象・Evidence棚卸し（Read-only）v0.1

## 1. 依頼の目的と位置づけ

定型メール作成ツール（Excel VBA + Classic Outlook）のP2 Regression Closure～P2 Phase Exitに向けて、**現在アクセス可能なRepositoryの現物とEvidenceの所在を読み取り専用で棚卸し**してください。

今回のS0は**事実確認とS1～S5の着手準備だけ**が目的です。正式Recordの改訂、文書の承認、Baseline/Registryの同期、Production修正は後続Stepです。引継ぎ記述は探索の手掛かりであり、現物の独立検証結果ではありません。

参照できる場合は以下を優先して読み、Repository上に存在しなければ「参照不可」と明示してください。

- `P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md`（Status: DRAFT / NOT APPROVED、S0中心）
- `Context_Handoff_P2-04_I12_20261019(1).md`（2026-10-19引継ぎ）
- `AI協働開発 文書管理・Baseline運用ルール v0.1.md`
- `Implementation Plan v0.3 日本語版`（DOC-MVP-IMPL）
- `P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification v0.1 — Approved`（特に§59～§61）
- Repository固有のフォルダ管理・命名・承認・文書Registry運用ルール（存在する場合）

## 2. 絶対的な作業制限

- **Read-onlyを厳守**。Tracked / Untrackedを含むファイルの新規作成、編集、移動、削除、リネーム、ZIP展開保存、生成物の保存をしない。
- `git add` / `git commit` / `git push` / `git pull` / `git fetch` / `git checkout` / `git switch` / `git reset` / `git restore` / `git clean` 等、Repositoryや作業環境の状態を変える操作をしない。ブランチ作成、PR作成も禁止。
- VBAコードの修正・取り込み、Workbook/OFTの起動・保存、Excel/Outlook操作、Compile、Regression再実行をしない。外部サービスへの原文Evidenceアップロードや公開も禁止。
- `git status`, `git log`, `git ls-files`, `git diff`、ファイル検索、既存文書の読取り、保存済みファイルのハッシュ確認など、変更を伴わない操作のみを使用する。
- レポート用Markdownファイルも**作成しない**。結果は**Codexのチャット回答へMarkdownで出力**する。
- 原文ログに個人ユーザーパス・機密情報・トークン等があれば、回答に原文を転載しない。公開可能な最小限の情報だけ要約する。
- 確認不能な項目は `UNKNOWN`、Repository外にある可能性があるものは `EXTERNAL / UNVERIFIED` とする。未発見を直ちに「不存在」「紛失」と断定しない。

## 3. S0の実施手順

### S0-1｜Repositoryスナップショット

1. Repository Root、現在のブランチ、`HEAD` Commit SHA、コミット日時、Working Treeの差分（Tracked/Untracked）を記録する。
2. Git上の現在の`HEAD`と、2026-10-19引継ぎで参照された`main`=`edf5c5175b103e250144341071d885a3a992c65f`を区別する。差があれば差分の有無と、確認可能な関連ファイルへの影響を報告する。勝手に過去Commitへ戻さない。
3. Working TreeがDirtyであっても絶対に整理・復元しない。以後の照合ではWorking Tree内容と`HEAD`内容を混同しない。

### S0-2｜Production Source / Workbookの識別

次の9 Production Moduleについて、`Docs/02_implementation/`内の版付きSource、`src/modules/`内のファイル、その他同名ファイルの**実在するパス、版数、内容上の識別情報**を調査し、候補間の関係を整理する。

| Module | 引継ぎ上の対応Revision |
|---|---|
| `modTemplateScanner` | P2-01 v0.1.1 |
| `modSyncEngine` | P2-02 v0.1.3 |
| `modVariableDefinitionData` | P2-03 v0.1.2 |
| `modSyncApplication` | P2-04 v0.1 |
| `modUiController` | P2-05 v0.1 |
| `modOutlookAdapter` | P1-07 v0.1.1 |
| `modSettingsData` | DF-P1-001 v0.1 |
| `COperationResult` | GitHub保存版 |
| `CErrorInfo` | GitHub保存版 |

- これは**探索用の対応表**。ファイル名の完全一致や現在の正式Production Revisionを確認前に確定しない。
- GitHubルートの`MailGeneratorNew.xlsm`は引継ぎでは**古い別Workbook**。2026-10-18 Regressionで使用した別フォルダのWorkbookと同一視しない。
- 実行WorkbookのSHA-256 `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9` は**USER-ATTESTED**。現物がない場合は再計算済みと書かない。
- 過去の9/9一致は**正規化全文一致**の検証結果。Rawバイト同一／Workbook全体のバイナリ一致／過去Workbook内容の独立証明ではない。ZIPとSourceが双方見つかった場合だけ、利用できる証拠の範囲で別途読取り比較結果を記録してよい。ただし再検証をS0の必須条件としない。

### S0-3｜Regression / I12 / Evidence Archive文書の所在

次を**名前・近似名・Document ID・本文見出し**で検索し、実在パス・Version・本文Status・承認/Closed表記・主要Evidence参照を一覧化する。見つからなければRepository外／未確認を区別する。

**既存Record / Project Control：**
- `P2-01 Full Template Scanner Regression Record v0.1.md`
- `P2-02 Sync Diff Core Regression Record v0.1.md`
- `P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md`
- `P2-04 Manual Sync Integration`の旧Completionと新Cycle Regression Record
- `P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`
- `Docs/00_project_control/Document_Registry.md`
- `Docs/00_project_control/Project_Overview.md`（パス違いも探索）
- `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`

**引継ぎで作成された候補・審査資料：**
- `P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md`
- `P2-04_I12_Historical_Regression_Evidence_Applicability_Assessment_v0.1_Draft.md`
- `P2-02_Sync_Diff_Core_Regression_Raw_Evidence_Addendum_v0.1_Draft.md`
- `P2-03_Sync_Persistence_Regression_Raw_Evidence_Addendum_v0.1_Draft.md`
- `P2-02_Sync_Diff_Core_Regression_Closure_Review_v0.3_Candidate.md`
- `P2-03_Sync_Persistence_Regression_Closure_Review_v0.3_Candidate.md`
- `P2-04_Manual_Sync_Integration_Regression_Record_v0.3_Draft.md`
- `P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md`
- `P2-04_I12_Final_Quality_Gate_Assessment_v0.3_Review_Result.md`
- `P2-04_I12_Evidence_Reconciliation_Matrix_v0.8_Draft.md`
- `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`

**Raw Evidence / Archive候補：**
- `261018_P2-02_Regression Log.txt`
- `261018_P2-03_Regression Log.txt`
- `261018_P2-04_Regression Log.txt`
- `P2-04_Regression_20261018_Raw.txt`
- `P2-04_Regression_20261018.zip`
- `P2-02_P2-03_Regression_Evidence_Bundle_20261019.zip`
- `P2-04_I12_Final_Quality_Gate_Review_Package_20261019.zip`
- `P2-04_I12_Review_Update_20261019.zip`
- `P2-04_I12_Compile_Continuity_Update_20261019.zip`

ZIPが存在するときは**展開保存せず収録一覧を確認**してよい。原本・コピー・引用・Manifestのみを区別し、実際の保管先とアクセス制御を未確認のまま推定しない。必要に応じて既存ファイルのSHA-256を読み取り専用で計算し、未計算なら `NOT CHECKED` とする。

### S0-4｜RegressionとI12のGate状態・Evidence限界

引継ぎにある以下の値を**「引継ぎ上の主張」**として出発点にし、Repository現物で裏付け可能な範囲だけを`REPO_VERIFIED`へ更新する。

- P2-01: Regression `PASS / CLOSED`、Core 11/11
- P2-02: 111/111 PASS、正式Regression Closure未実施
- P2-03: 46/46 PASS、正式Regression Closure未実施
- P2-04: 新Cycle 182/182 PASS、正式Record反映待ち
- P2-04 I12: `TECHNICAL PASS / REVIEWED`、Repo Formal Closure Pending
- `OBS-P2-05-002`: `OPEN / NON-BLOCKING`

次の注意点を記録・確認する。
- P2-02 Bootstrap 33件のログ末尾再掲を二重集計しない。
- P2-04 I10初回 `ABORTED` はPASSへ算入しない。後続20/20 PASSは別記録。
- P2-04 I01/I02は旧Completionの補足Evidence。旧Source Revisionとの差異も保持。
- P2-04 I07 Expected FailureとI08 Fresh Retryは一般的なRollback/Atomicity保証ではない。
- P2-03テーブル内容復元ログはWorkbook全体の完全復元を意味しない。
- 2026-10-10 Compile PASSと以後のVBAProject変更なしは**USER-ATTESTED**。2026-10-18に再Compileしたという記録にしない。
- I12で過去Evidence再利用方式を採用したDecisionは維持し、S0で全面再実行を提案・着手しない。

### S0-5｜Baseline / Project Control差分の棚卸し

- BL-MVP-004 Approval Recordの**承認日・Status・Manifest・適用範囲**を現物から抽出する。
- Document Registry / Project Overviewに残るBaseline IDと照合する。
- `Approved Baseline`、`Current Registry / Acceptance State`、`Historical Regression Execution Baseline`を別項目で表示する。
- 引継ぎではBL-MVP-004 Approved（2026-10-01）、Registry / Overview側はBL-MVP-003表記とされているが、**現在の現物で再確認**する。
- 不整合と更新候補だけを列挙し、Baselineの承認・変更・Registry修正・過去RecordのBL-MVP-003書換えはしない。

### S0-6｜P2-05 Completion Evidenceの有無を棚卸し

Approved P2-05 Implementation Specification **§59～§61**を基準に、次の各Criteriaについて `EVIDENCE FOUND / PARTIAL / NOT FOUND / UNKNOWN` を確認する。

- Current Production Source Review COMPLETE
- Production Patch Design APPROVED
- VBA Compile PASS（**最終・現行VBAProjectの新しい実行Evidenceがあるか**を別欄に）
- Production Implementation PASS
- P05-I01～I17（各Case単位、Applicable条件含む）
- P05-K01～K04（各Case単位）
- P2-01～P2-04 Regression
- Static Review S01～S32（各Item単位）
- Production Patch Review PASS
- Final Finding Assessment PASS
- Finding RegisterのActive Finding 0 / Blocking Finding 0（**全体Registerの独立確認**）

`OBS-P2-05-002`（OPEN / NON-BLOCKING）をActive Findingと無条件に同一視したり、都合よく0として集計したりしない。Finding分類・集計ルールの根拠がなければ`UNKNOWN`とする。

**S0ではPASS/COMPLETE/CLOSEDを新たに承認しない。** 既存Evidenceで成立した範囲を特定し、不足・追加確認候補だけを報告する。P2-05 COMPLETE、P2 Phase Exit、CP-P2 ESTABLISHED、Formal MVP Test PASSはいずれも未判定として扱う。

## 4. 出力形式（チャット内Markdownのみ）

以下の見出し順で報告すること。

1. **S0調査サマリー**：調査日時、Repository Root（個人情報マスク）、ブランチ、HEAD、Working Tree状態、調査可能範囲、S0結果（Inventory Complete / Partial / Blocked）。
2. **Artifact Inventory**：`区分 | Artifact名 | 実在パス | Version | 文書Status | 根拠位置（ファイル内見出し等） | Evidence分類 | 課題/不足`。長い表はカテゴリーごとに分けてよい。
3. **Source / Workbook Provenance Matrix**：9 Moduleと各Source候補・版数、`src/modules`との関係、GitHubルートWorkbookと実行Workbookの識別、比較済み/未比較の境界。
4. **Raw Evidence / Archive Inventory**：原文・ZIP・Manifestごとに `Repository内 / 外部のみ申告 / 未確認`、参照先、公開時の注意、SHA確認有無。
5. **Regression / I12 Status Matrix**：技術PASSと正式Closureを別列にし、Evidence限界・不足を記載。
6. **Baseline / Project Control差分**：Approval Record・Registry・Overviewの記述を並置。修正の実行はしない。
7. **P2-05 Completion Criteria Matrix**：Approved §59の項目を**省略せず**列挙。各項目 `Existing Evidence | Verified Status | Gap | 次に必要な確認`。I01～I17、K01～K04、S01～S32は追跡可能な粒度で記載。
8. **S1～S5の最小変更候補と依存順序**：今後必要となる既存Recordの改訂・Manifest登録・Registry同期・新しい実機Compile・不足Verificationを、`対象ファイル / 作業種別 / 前提 / 所要証拠 / 実施者` で一覧化する。**今回は実施しない**。
9. **Open Questions / Access Gaps**：未提示の原本保管場所、承認者、アクセス制御、実行Workbook現物、Finding Register等、S1前に確認すべき事項のみ。
10. **変更ゼロの確認**：開始時と終了時のWorking Tree状態を比べ、Codex自身がファイル・Git状態を変更していないことを記載。既存Dirty Stateがあればそのまま報告する。

Evidence分類には、必要に応じて `REPO_VERIFIED`（Repo現物で確認）、`FILE_VERIFIED`（別の現物ファイルで確認）、`USER_ATTESTED`（実行者申告）、`HANDOFF_ONLY`（引継ぎ記載のみ）、`UNVERIFIED`（根拠確認不可）を使用する。

## 5. S0 Done When / 引渡し

以下を満たせばS0完了です。

- Repository内で実在確認できたもの、Repository外にあると申告されたもの、未確認のものが明確に分かれている。
- Production Source候補・古いGitHub Workbook・Regression実行Workbookの混同がない。
- P2-02/P2-03、P2-04/I12、BL-MVP-004、P2-05に関する**正式状態とEvidenceの不足**が追跡できる。
- S1 Evidence保全を始めるための入力・不足資料と、後続S2～S5の最小作業順が判明している。
- **ファイル変更・Commit・Push・正式Closure・Baseline更新・実機テストを一切行っていない。**

最後に、**「S1へ進める / 追加資料が必要」**を、根拠と条件つきで提案してください。S1以降の作業を実行せず、そこで停止してください。
