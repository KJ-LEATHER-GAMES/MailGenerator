# 定型メール作成ツール — S3 P2-04新Cycle／I12 Documentary Closure Read-only Precheck 指示 v0.1

- 指示日：2026-10-24（JST）
- 対象：P2 Scan / Sync — S3（P2-04新Cycle・I12 Documentary Closureの事前確認）
- 権限：**既存情報のRead-only調査・報告のみ**
- 目的：P2-04の新Cycle回帰証跡とI12 Documentary Closureに必要な根拠・承認状態を照合し、**正式Closureが可能か／追加の判断を要するか**を明示する。
- **本指示は正式Closure承認ではない。** すべての確認後、結果を報告して停止する。

## 0. 既定の現在地と確認の境界

1. S1：`G2_RECORDED_S1_CLOSED`。Evidence原本5件をPrimary／Backupに保全し、USBから5/5の復元試験PASS。Manifestは報告上、**本文v0.3／Approved**（旧v0.1 Draftを含む既存ファイル名は維持）。S1を再開しない。
2. S2：`S2_FORMAL_CLOSURE_RECORDED`。P2-02 Regression Record **本文v0.2／PASS・CLOSED（111/111）**、P2-03 Regression Record **本文v0.2／PASS・CLOSED（46/46）**。両者を再Closureしない。
3. 管理入口の最終報告：`Project_Overview.md` **v1.65**、`Current_Handoff.md` **v1.38**。S2完了、S3未着手の状態から、**今回S3 Precheckのみ着手**する。現物を読み、実Version・Statusが異なれば報告する。
4. P2-04新Cycle **182/182 PASS**は引継ぎ上の既存技術報告値。**今回、最新の原文・Case内訳・Source／Run対応と照合する。** 過去のP2-04 Unit Completion、I01–I12や他Unitの111/111＋46/46を足して182/182と見なさない。
5. 2026-10-02付近のP2-04既存Completion系記録には`PASS / COMPLETE`、I12 Evidence Incompleteの`RESOLVED / CLOSED`があるが、**以前のImplementation Unit実績**であり、新Cycle Regression Recordおよび**現在のDocumentary Closureを自動的に成立させない**。新Cycleの証跡・正式な記録状態を優先確認する。
6. 現行Build Provenance等で定められた証拠上の限定を引き継ぐ。**原文にない実行日時、未証明のWorkbook全体同一性、未実施の最新Compileを創作しない。** `BL-MVP-004`の承認事実・文書上の表示・Repository受入／同期は分け、S4の作業を先取りしない。
7. `IF-P2-04-001`等の既存解消記録を無断で再Openせず、`OBS-P2-05-002`は既存の**OPEN／NON-BLOCKING**を維持する。P2全体のFinding 0を宣言しない。

## 1. 既存正本・Evidenceの特定（Read-only）

実Repositoryに存在する正本を、**実際のパス／本文Version／Status／承認履歴**で特定する。事前のファイル名や過去スナップショットだけで新Cycle正本を決めない。

### A. Project Control／計画

- `Project_Overview.md`、`Current_Handoff.md`、現行文書管理・Baselineルール
- `Implementation Plan v0.3`（または実際の現行正本）
- P2-04に適用する既存Completion／Regression／I12 Documentary Closureの判定基準と決定権限

### B. P2-04 Unitと新Cycle

- P2-04 Manual Sync IntegrationのApproved実施仕様、Completion Record、Finding Assessment、Production Patch Review、関連Correction／Closure Review
- **P2-04新Cycle Regression Record／原実行Evidence／Suite・Case対応表**、Source／Workbook／Run／Build Provenanceの既存対応資料
- `IF-P2-04-001`の解消記録および既存のI12 Evidence Incompleteに関する補完記録（歴史的実績と今回の新Cycleを区別）

### C. I12 Evidence Archive

- 既存 `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`（**本文は最新報告上v0.3／Approved**）
- Archive ID `ARC-MG-P2-I12-20261018`、Evidence ID `E-P204-RAW`／`E-P204-SOURCE`／`E-P204-WB`、必要に応じて`E-P202-RAW`／`E-P203-RAW`
- 既存の`EXECUTE_ARCHIVE` 5/5 PASS・USB復元5/5 PASS・G2承認・S1 Closureの実行／承認記録
- Primary／Backupの**Private Indexは必要なメタデータだけRead-only照合**。原本やバックアップを再コピー／再ハッシュする必要があるかは既存Gateの必須条件に照らす。不要ならS1で確定したEvidenceを再利用する。

正本・証跡が見つからない場合は推測して作成せず、`NOT_FOUND`／`UNKNOWN`と報告する。

## 2. 新Cycle 182/182の検証

1. 182/182の原文、Suite名、Case ID、各SuiteのPass／Fail／Total、および集計方法を調べる。**重複・再掲・補完ログの二重計上**がないことを確認する。
2. 実行対象Source、Workbook、Run、実行日時（原文に存在する場合のみ）、Compile Evidence、および既存Build Provenanceとのつながりを確認する。Sourceのバージョンや実行者申告の位置づけを事実と分離して記載する。
3. 新Cycleの対象範囲（P2-04 Integration／I12 Contract Regression／関連P2-01～03 Contract）と、旧Completion／新Cycle／Formal MVP Testの各証拠を区別する。
4. RegressionのFinding／Disposition、既存Correction、Active／Blocking Findingを範囲限定で確認する。`OBS-P2-05-002`および他工程のFindingを根拠なくCLOSED扱いしない。
5. 新Cycle Regression Recordの現Status、既存Approval・Closure Review、正式Closureに必要な署名・ユーザーDecision・Evidence参照が満たされているか確認する。

## 3. I12 Documentary Closureの検証

1. S1のArchive・Manifest v0.3／Approved・Private Index・G2・S1 CLOSEDが、**I12のどのDone When／Documentary Closure条件を満たすか**既存文書に基づいて一対一で対応させる。**S1 Closure≠I12 Documentary Closure**として扱う。
2. `E-P204-RAW`／`E-P204-SOURCE`／`E-P204-WB`とI12新Cycle EvidenceのTraceabilityを確認。既存Index／ManifestのEvidence ID、Hash、Run ID、保全／復元結果の参照関係を確認し、証拠の取違い・欠落を探す。
3. I12 Evidence Incompleteの旧`RESOLVED / CLOSED`と、**今回の新Cycleでの原文保存状況**を区別し、未解決のEvidence Gapがないか判定する。
4. Documentary Closureの対象正本（P2-04 Regression Record／I12 Evidence Record／Unit Completion Record等）と、必要なStatus変更・Authorityを**既存ルールから特定**する。存在しない「I12専用Closure文書」を勝手に必須化しない。
5. S1限定で受容した残留リスク（ManagementShareEffectiveAccess UNKNOWN）を他工程へ自動拡張しない。OneDriveRegistration UNKNOWN／Stage2TotalExecutionCount UNKNOWNも維持し、既存Gateに無い再調査を追加しない。
6. Public／Private境界（個人パス、SID、SDDL、生ログ等）、リンク・アンカー、概要／Handoffの**現在地の整合性**を確認する。過去履歴を最新状態の矛盾と取り違えない。

## 4. Read-only判定ルール

P2-04新CycleRegression ClosureとI12 Documentary Closureを**別々に**評価する。

- `ALREADY_CLOSED`：既存正本と承認履歴で正式Closure済みと確認できた。
- `READY_FOR_FORMAL_CLOSURE`：必須Evidence／Finding Gate／Traceabilityは成立、正式Closure・ユーザーDecisionの記録のみ未実施。
- `REVIEW_REQUIRED`：Closure前に明示判断、文書間矛盾の解消、証拠限定の取扱い確認が必要。
- `BLOCKED`：必須Evidence欠落・不一致、Blocking Finding等が確認された。
- `UNKNOWN`：必要な正本／Evidenceに到達できず判定不能。

`S3PrecheckDecision`は、両対象が`ALREADY_CLOSED`または`READY_FOR_FORMAL_CLOSURE`の場合のみ`READY`とし、必要に応じ`REVIEW_REQUIRED`／`BLOCKED`を選択する。未知の必須事項は推測でPASSにしない。

**技術PASS、Unit COMPLETE、S1/G2 APPROVED、S3 Documentary Closure、P2 Phase Exit、CP-P2は別の状態。**

## 5. 禁止事項（厳守）

- **すべてのファイル編集、追記、新規作成、リネーム、削除**（Overview／Handoff／Manifest／Private Indexを含む）
- VBAテスト・Compile・Regression・I12の再実行、Workbook／Source／Fixtureの変更
- S1 Archive／USB復元試験の再実行・新規証跡生成・再保全
- Git操作（status等の参照操作も含め本件では不要）、Baseline／Document Registry変更
- P2-04新Cycle／I12の正式Closure、G2再承認、S4以降への自動着手
- 管理者昇格、ACL／BitLocker／OneDrive設定変更
- 根拠がない日時・Version・Hash・同一性・承認の補完、調査の無制限な拡大、自動リトライ

既存ファイルのRead-only探索・照合・必要に応じたSHA-256読み取りは許可するが、**ユーザー環境上のファイル／Repoに変更を残さないこと**。結果をチャットで報告して停止する。

## 6. 完了報告形式

```text
S1Closure: G2_RECORDED_S1_CLOSED (existing)
S2FormalClosure: S2_FORMAL_CLOSURE_RECORDED (existing)
S3PrecheckAuthorization: READ_ONLY

P2-04_NewCycle:
  ReportedRegression: 182/182 PASS
  RegressionRecord: <path / version / status or NOT_FOUND>
  RawEvidenceAndCaseBreakdown: PASS / PARTIAL / UNKNOWN
  Aggregate182NoDoubleCount: PASS / REVIEW_REQUIRED / UNKNOWN
  SourceWorkbookRunProvenance: PASS / LIMITED / REVIEW_REQUIRED / UNKNOWN
  FindingGate: PASS / REVIEW_REQUIRED / BLOCKED
  ClosureAuthorityAndHistory: <verified facts>
  ClosureDecision: ALREADY_CLOSED / READY_FOR_FORMAL_CLOSURE / REVIEW_REQUIRED / BLOCKED / UNKNOWN

I12_Documentary:
  Manifest: <actual path; body version/status>
  S1ArchiveG2Traceability: PASS / REVIEW_REQUIRED / UNKNOWN
  EvidenceIDsAndPrivateIndex: PASS / REVIEW_REQUIRED / UNKNOWN
  NewCycleEvidenceCompleteness: PASS / REVIEW_REQUIRED / UNKNOWN
  DocumentaryClosureTarget: <existing record(s) / status / authority>
  ClosureDecision: ALREADY_CLOSED / READY_FOR_FORMAL_CLOSURE / REVIEW_REQUIRED / BLOCKED / UNKNOWN

CrossDocumentConsistency: PASS / REVIEW_REQUIRED / BLOCKED
PublicPrivateBoundary: PASS / REVIEW_REQUIRED
MarkdownLinksAnchors: PASS / REVIEW_REQUIRED / NOT_CHECKED
ProvenanceLimitationsPreserved: PASS / REVIEW_REQUIRED
ResidualUnknowns: [unchanged, or evidence-grounded changes]
BlockingFindingsInS3Scope: [IDs or NONE, scope-limited]
RequiredActionsForFormalClosure: [minimum exact records and decisions]
S3PrecheckDecision: READY / REVIEW_REQUIRED / BLOCKED
DocumentMutation: NONE
TechnicalTestRerun: NONE
ArchiveRerun: NONE
GitOperation: NONE
FormalClosurePerformed: FALSE
S4Started: FALSE
P2PhaseClosed: FALSE
CP-P2Established: FALSE
NextAction: USER_REVIEW_S3_PRECHECK
```

**報告して停止する。** 未確認／不足があれば最小項目と根拠を列挙し、正式Closureに必要な操作を勝手に実施・承認しない。
