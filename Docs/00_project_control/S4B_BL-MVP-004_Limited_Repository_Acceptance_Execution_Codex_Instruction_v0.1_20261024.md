# S4-B：BL-MVP-004 Repository受入・文書同期 限定実行指示 v0.1

- 指示日：2026-10-24（JST）
- 工程：定型メール作成ツール／P2 Scan・Sync／S4-B
- ユーザー承認：**S4-Bの8ファイル限定実行を明示承認済み**（新規3件、既存更新5件）。この承認は文書の統合・同期作業に限る。
- 前提：S4-A Read-only確認・S4-B計画は`READY_FOR_USER_AUTHORIZATION`。BL-MVP-004の固定Version組合せは既存Approval Recordにより確認済み。2026-10-24（JST）付ユーザーの現在の受入追認とDesign Patch統合範囲の判断を使用する。
- **禁止**：Git操作、Baseline再構成・新Baseline発行、技術再実行、S5／S6着手。無断の範囲拡大・自動再試行・自動Rollbackなし。

## 0. 今回の達成目標と、変更対象8ファイル

S4-Bの目的は、**既存のAPPROVEDであるBL-MVP-004を、固定された4文書のVersion組合せを変えずにRepositoryで正式受入し、必要な正本・Registry・Project Controlの現在地を整合させること**。新しいSemantic変更や技術的合格を創作しない。

以下の8ファイルだけを新規作成・更新してよい。パスはRepositoryルートからの相対パス。パス・ファイル名が実環境と違えば推測で代替せず停止する。

| 操作 | 厳密な対象パス | 目的 |
|---|---|---|
| 新規 | `Docs/01_specifications/MVP Design v0.1.10 日本語版.md` | v0.1.9全文＋承認済みv0.1.10 Patchの明示§1～6操作 |
| 新規 | `Docs/01_specifications/MVP Test Specification v0.1.6 日本語版.md` | v0.1.5全文＋補正後v0.1.6 Patch-2を**直接**統合 |
| 新規 | `Docs/02_implementation/Implementation Plan v0.4 日本語版.md` | v0.3全文＋v0.4 Patch＋CR-IMPL-004-001補正＋承認状態 |
| 更新 | `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md` | 2026-10-24追認の**独立した追記**と更新履歴 |
| 更新 | `Docs/00_project_control/Document_Registry.md` | §1～4・正本参照を必要最小限同期 |
| 更新 | `Docs/00_project_control/Project_Overview.md` | 受入完了時のCurrent Baseline・S4状態・次Action |
| 更新 | `Docs/05_handoff/Current_Handoff.md` | 現在地とS5未着手の再開入口 |
| 更新 | `README.md` | 現行Planへの既存参照リンク**1件だけ**修正 |

対象外の旧全文、Patch、Consistency Review、Requirements v0.1.9、Technical Spike A v0.4、S1～S3のClosure Record、Private Index／Manifest／Evidenceを変更しない。`DOC-TS-A v0.4 CLOSED/PASS`も変更しない。**上記以外の一時ファイル、差分ファイル、スクリプト、補助文書をRepository内に新規作成しない。**

## 1. 確定済みの権限・判断境界

### 1.1 BL-MVP-004の固定構成（変更禁止）

```text
Baseline: BL-MVP-004
Existing Status: APPROVED
DOC-MVP-REQ       v0.1.9
DOC-MVP-DES       v0.1.10
DOC-TS-A          v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC  v0.1.6
```

`DOC-MVP-IMPL v0.4`はBaselineの固定4文書の**一員ではない**。Baseline移行に伴う承認済みの影響修正文書として扱う。RegistryのPlan `Baseline Version`は、既存計画に従い`—`を維持する。

### 1.2 ユーザーの2026-10-24（JST）付追認

Approval Recordに、既往本文を消さず独立した`Current Acceptance Ratification`節を追記する。

- Decision：`CURRENT ACCEPTANCE RATIFIED`
- Authority：`USER`。当人が正式な受入判断権限を持つ旨を**本人申告**。独立検証は実施していない。
- Decision Date：`2026-10-24 (JST)`。存在しない時刻を付与しない。
- Scope：上記既存BL-MVP-004の固定4文書のVersion組合せに限定。
- Historical Approval Authority：`UNKNOWN`
- Historical Approval Decision Date：`UNKNOWN`
- 既存の`2026-10-01`は**Gate実施日**。歴史的承認日と見なさない。
- 過去の`PASS / APPROVED`は取消さない。今回の追認だけでRepository受入／全文統合／Registry同期を完了扱いにしない。
- 文書管理ルールに従い更新履歴・本文Versionを改訂する（既存報告上の最小案は本文v0.2、ファイル名は維持）。現在の正本本文・ルールが異なる場合はそれを優先し、根拠が曖昧なら停止。

### 1.3 Design Patchの明示統合範囲

ユーザーはv0.1.10 Patchの**§1～6に明示された操作だけを全文に適用**すると決定済み。Patch §8 `Responsibility Boundary`、§9 `Resolution Result`自体は根拠資料としてそのまま保持し、独自の新節として正本へ挿入しない。ただし§1～6の明示操作により反映する承認済み意味論は落とさない。

## 2. 必須Preflight（変更前・Read-only）

1. Repositoryの正しいルート・既存正本・承認資料を確認。Gitコマンド・Git APIを一切使わない（`git status`／`git diff`も禁止）。
2. 既存5更新対象について実在・現在の本文Version／Status・必要節・SHA-256を取得。既報値：Approval Record v0.1、Registry v1.43、Overview v1.66、Handoff v1.39。**現在値が異なればその差を評価し、想定外なら変更せず停止**。READMEの対象リンクが一意か確認。
3. 新規3件の予定先がいずれも**存在しない**ことを確認。すでに存在すれば上書き・リネーム・重複生成せず停止。
4. Base全文、最終Patch、補正Review、BL-MVP-004 Approval Recordの実在・一意の位置付け・読み取り可否・必要なSHA-256を確認。S4-A実測の適用先・優先順・非競合を再利用し、変更されていれば停止。
5. 参照対象がPublic／Private境界に反していないか確認。機微な実パス、個人SID／SDDL、生ログをPublic文書へ転記しない。
6. 予定している編集を**実際の見出し／局所断片に照らし、非重複の編集範囲に一意対応**させる。前工程の重複Patch問題を繰り返さない。
7. ここで1項目でも未確認・競合・アクセス不可なら、変更前に`STOP_REVIEW_REQUIRED`／`BLOCKED`として停止。

## 3. 実行順序（各段階に検証Gate、失敗時停止）

### A. BL-MVP-004 Approval Record：追認記録

§1.2を**既存のAPPROVED履歴とは独立**して追記し、更新履歴・文書情報を整合。旧BL-MVP-003 `SUPERSEDED`履歴、CR-TS-001～003 CLOSED、2026-10-01のGate日、固定構成を保つ。読み戻して追記箇所・差分範囲・Version・旧履歴を確認。PASSでなければ停止。

### B. Design v0.1.10：全文正本の新規作成

- Base：`MVP Design v0.1.9 日本語版.md`のRepository正本。
- Patch：`MVP Design v0.1.10 Candidate — IF-P2-04-001 Design Gap Resolution Patch.md`。Patchの`Candidate`というファイル表示と、BL-MVP-004に対する**後続承認**を区別し、承認済み§1～6の明示操作に限る。
- 文書タイトル／本文Version→v0.1.10、更新履歴を維持して追加概要を記録。§7.4、§15.4、§15.5、§15.6を承認済みPatchどおり置換。§25.1の**指定Sync Engine部分のみ**を置換。その他の本文を機械的に変えない。
- 規則：Initializedは`FirstDetectedAt`維持・`LastDetectedAt`をSyncTimestampへ更新。UninitializedのExisting／Reactivatedは両日時を同じSyncTimestampで初期化。Unused／Already-Unusedの未初期化日時はBlank維持。Invalid／PartialはFailureでPersistenceしない。
- §8／§9を独自に全文へ挿入しない。旧v0.1.9を編集しない。
- 保存後に全文を読み戻し、承認済み差分・Document ID／Version／Status・対象節の一意性・非対象節不変・Markdownリンクを照合。PASSでなければ停止。

### C. Test Specification v0.1.6：全文正本の新規作成

- Base：`MVP Test Specification v0.1.5 日本語版.md`のRepository正本。
- Patch：`MVP Test Specification v0.1.6 Candidate — IF-P2-04-001 Test Definition Patch-2.md`の**補正後Patch-2だけ**を直接適用。初期CandidateやPatch-1を前段適用・二重適用しない。
- 承認された変更対象：`MTS-SYNC-003/004/005/011`の4件を指定位置で置換、`MTS-ERR-001`を局所追加し既存Error Expectedを維持。
- `CR-TS-001`（Invalid／Partial共通Guard、K／L／M）、`CR-TS-002`（Variant Cで既存ユーザー設定保持）、`CR-TS-003`（UI通知Evidence・MTS-ERR-001）を補正後Patch-2どおり反映。新規Expected／新規Test IDを独自創作しない。
- 既存の詳細Test ID **69件**を維持し、重複・欠損なく承認された追加だけを含める。文書情報・Version／Status・更新履歴を整合させ、旧v0.1.5は編集しない。
- 保存後、全文読み戻し・Patch-2対応・3件のCR・Test ID集合・リンク・非対象本文不変を照合。PASSでなければ停止。

### D. Implementation Plan v0.4：全文正本の新規作成

- Base：`Implementation Plan v0.3 日本語版.md`のRepository正本。
- Patch：`DOC-MVP-IMPL v0.4 Candidate Patch.md`を適用。その後、`DOC-MVP-IMPL v0.4 Candidate - BL-MVP-004 Consistency Review v0.1.md`の§4～5にある`CR-IMPL-004-001`を反映し、同Review §9のAPPROVED判断に整合させる。
- 対象：§1、§2、§4.1、§4.3、IMP-R01、§8.1、§8.3、§8.7、§12.4、§14.1、Appendix Aの**指定箇所だけ**。承認済み差分にない一括文字列置換をしない。
- P6 Input最終参照は`DOC-MVP-DES §7.4 / §12 / §13 / §24 / §25.1 / RISK-DES-002`とする（`CR-IMPL-004-001`に従う）。Candidate Patchだけで完結したと判定しない。
- 本文v0.4、承認に基づくStatus、更新履歴を整合。過去の`BL-MVP-003`というExecution Baseline／履歴記載は保持し、旧v0.3は編集しない。
- 保存後、全文読み戻し・Approved Patch＋CR補正・対象節と非対象本文・Status・リンクを照合。PASSでなければ停止。

### E. Registry：正式Repository受入・Baseline登録の同期

A～DすべてPASS後にのみ、`Document_Registry.md`の§1～4および必要な正本参照行を最小更新する。

- 固定4文書：REQ v0.1.9、DES v0.1.10、TS-A v0.4 CLOSED/PASS、TESTSPEC v0.1.6。確認した**新規全文正本を参照先**として登録。
- `Latest Version`、文書`Status`、`Baseline Version`、`Current Approved Baseline`は別フィールドとして個別に整合。Latestを自動的にBaselineと混同しない。
- `BL-MVP-004`を現行として受け入れ、`BL-MVP-003`の既存`SUPERSEDED`判断を**歴史的状態として維持**。過去EvidenceのBL-MVP-003実行基準を変更しない。
- Plan v0.4は影響修正文書としてLatest／Status／正本参照を同期し、**Baseline Version=`—`**を維持。固定4文書へ追加しない。
- 旧文書へのリンク・履歴を保持。文書内Versionは実際に編集した場合のみ規則に基づき更新。
- Read-backで登録と4固定Version、Planの位置付け、全正本参照を照合。PASSでなければ停止。**Registry更新前はRepository Acceptanceを完了扱いにしない**。

### F. Overview → Handoff → README：現在地・参照の最小同期

EのPASS後に、次の順で更新する。

1. `Project_Overview.md`：現行Baseline `BL-MVP-004`、受入済み4文書とPlan v0.4の区別、S4-B同期の実施状況、S5未着手、次Action。既存S1～S3のClosure履歴を保持。
2. `Current_Handoff.md`：現在地とS5への**次の候補Action（着手は別承認）**を最小反映。詳細なVersion表を重複させない。
3. `README.md`：旧Planへの参照**1件のみ**を採用済みv0.4全文正本への有効な相対リンクに差し替える。ファイル全体の清掃をしない。

全工程の最終整合確認がPASSするまでは、進行中の工程を形式上`S4 COMPLETED`と断定しないこと。最新状態の文言・更新順の都合で二段階のステータス記入が必要なら、**同じ承認済み2ファイル内に限り**最終PASS後に確定させる。予期しない失敗時には実際に書き込まれた途中状態と未完了部分を報告し、追加修正・Rollbackを勝手に実施しない。

### G. 最終検証と停止

- 8対象ファイルの新規／変更一覧・本文Version／Status、変更前後のSHA-256、差分範囲を照合（個人情報や秘密のハッシュ対象内容はPublic出力しない）。
- Base／Patch／Review／過去Closure EvidenceをRead-onlyで参照し、**対象外ファイルが不変**であることを可能な範囲でSHA-256比較する。
- 新規3全文の承認差分、4固定Version、Planの非固定位置付け、既存APPROVED／今回追認、Registry、Overview、Handoff、READMEの参照と状態が一致すること。
- 相対リンク・アンカー、Document ID、Status、Traceability、Public／Private境界を確認。対象外の歴史的BL-MVP-003記録に不必要な手直しをしない。
- 3残留UNKNOWN（`OneDriveRegistration`、`ManagementShareEffectiveAccess`〔S1限定受容〕、`Stage2TotalExecutionCount`）、過去のProvenance限定、`OBS-P2-05-002: OPEN / NON-BLOCKING`を変更しない。
- P2-05 Completion、P2 Phase Closure、`CP-P2`成立を宣言しない。**S5は開始せず報告して停止**。

## 4. 失敗時の停止ルール

- 実行直前に対象が存在／不存在の想定に合わない、Patchの適用位置が重複・曖昧、Approval／Reviewと矛盾、SHA・読み戻し不一致、Public情報混入、参照不整合、編集エラーが発生した場合、**その場で停止**。
- 無断の自動Retry、パッチ形式の自動切替、別ファイルへの回避作成、再生成、Restore、Rollback、Git操作を行わない。
- すでに変更したファイルがある場合は**部分変更を正確に報告**。未完了の状態を`PASS`／`COMPLETED`／`ACCEPTED`にしない。未編集ファイルはそのまま維持。
- `S4BRepositoryAcceptance: PASS`は、全8ファイルが期待どおり、3全文差分・Registry・各参照の最終整合がPASSし、重大な矛盾／不意の変更がない場合**のみ**判定する。

## 5. 結果報告フォーマット

```text
S4BUserAuthorization: APPROVED_BY_USER
S4BExecution: PASS / STOP_REVIEW_REQUIRED / BLOCKED

BL-MVP-004:
  HistoricalApprovalAuthority: UNKNOWN
  HistoricalApprovalDate: UNKNOWN
  GateExecutionDate: 2026-10-01
  CurrentRatification: 2026-10-24_JST / USER_ATTESTED_AUTHORITY
  ApprovalRecordUpdate: PASS / NOT_PERFORMED / PARTIAL
  FixedVersionCombination: REQ_v0.1.9 / DES_v0.1.10 / TS-A_v0.4 / TESTSPEC_v0.1.6

Design_v0.1.10_FullText: PASS / NOT_PERFORMED / PARTIAL
Design_ExplicitPatchOnly: PASS / NOT_PERFORMED / FAIL
TestSpec_v0.1.6_FullText: PASS / NOT_PERFORMED / PARTIAL
TestSpec_CorrectedPatch2_CR-TS-001_003: PASS / NOT_PERFORMED / FAIL
ImplementationPlan_v0.4_FullText: PASS / NOT_PERFORMED / PARTIAL
ImplementationPlan_CR-IMPL-004-001: PASS / NOT_PERFORMED / FAIL

RegistrySync: PASS / NOT_PERFORMED / PARTIAL
CurrentBaselineAccepted: BL-MVP-004 / NOT_ACCEPTED / PARTIAL
OverviewUpdate: PASS / NOT_PERFORMED / PARTIAL
HandoffUpdate: PASS / NOT_PERFORMED / PARTIAL
README_LinkUpdate: PASS / NOT_PERFORMED / PARTIAL

ApprovedSemanticDiffMatch: PASS / FAIL / NOT_CHECKED
CrossDocumentConsistency: PASS / FAIL / NOT_CHECKED
MarkdownLinksAnchors: PASS / FAIL / NOT_CHECKED
PublicPrivateBoundary: PASS / FAIL / NOT_CHECKED
HistoricalReferencesPreserved: PASS / FAIL / NOT_CHECKED
ProvenanceLimitationsPreserved: PASS / FAIL / NOT_CHECKED

CreatedFiles: [exact paths]
ModifiedFiles: [exact paths]
UnexpectedChanges: NONE / [details]
PartialMutation: FALSE / TRUE
ResidualUnknowns: UNCHANGED / [details]
GitOperation: NONE
BaselineReconfiguration: NONE
TechnicalTestRerun: NONE
ArchiveRerun: NONE
S5Started: FALSE
P2PhaseClosed: FALSE
CP-P2Established: FALSE

S4BRepositoryAcceptance: PASS / STOP_REVIEW_REQUIRED / BLOCKED
NextAction: USER_REVIEW_S4B_RESULT
```

**全結果を報告して停止する。** S4-B完了報告は、S5実行権限、P2 Phase Exit権限、Public Git公開権限の付与ではない。
