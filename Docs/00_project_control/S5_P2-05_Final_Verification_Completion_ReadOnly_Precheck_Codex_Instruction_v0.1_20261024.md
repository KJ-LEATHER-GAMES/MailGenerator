# Codex実行指示：S5 P2-05最終検証・Completion Read-only Precheck v0.1

- 作成日：2026-10-24 JST
- プロジェクト：Mail Generator / P2 Scan & Sync
- 承認範囲：**Read-only Precheckのみ**
- 本指示の目的：既存Evidence、現行Production Source、P2-05承認済み完了条件を照合し、未実施作業・証拠不足・次の限定承認範囲を確定する。
- **本指示によるVBA Compile、テスト、コード修正、文書編集、Formal Completion、P2 Phase Exitは一切承認されない。**

## 1. 維持する既定状態と判定境界

- S1：`G2_RECORDED_S1_CLOSED`。
- S2：`S2_FORMAL_CLOSURE_RECORDED`（P2-02 111/111 PASS、P2-03 46/46 PASSのRegression Records CLOSED）。
- S3：`S3_FORMAL_CLOSURE_RECORDED`（P2-04新Cycle 182/182 PASS、I12 Documentary CLOSED）。
- S4：BL-MVP-004の既存固定4文書組合せをRepositoryへ正式受入・Registry整合済み（報告：`S4BRepositoryAcceptance: PASS`）。旧BL-MVP-003等の歴史的Execution Baselineは変更しない。
- 2026-10-24 JSTのBL-MVP-004追認はユーザー申告権限に基づく独立のDecision。過去承認主体・過去承認日時はUNKNOWN、2026-10-01はGate実施日。
- S5：**この指示を受けた時点ではRead-only Precheckのみ着手許可**。P2-05 `PASS / COMPLETE`、P2 Phase COMPLETE、`CP-P2 ESTABLISHED`を宣言しない。
- 既存Provenance限定（Source正規化照合・実行者申告、Workbook全体の過去同一性未証明、OFT/SettingsのUSER-ATTESTED範囲）を保持する。
- 2026-10-10のCompile PASSは**ユーザー申告と以後変更なし申告**。10月18日／24日にCompileを実行したという記録にしない。現行Sourceに対するCompile証拠の充足性は別途評価する。
- `IF-P2-05-001`は既存の「CLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING」。`OBS-P2-05-002`（WordEditor E_FAIL）は**OPEN / NON-BLOCKING**を保持。新たな実測なしに原因や恒久対策を確定しない。
- OneDriveRegistration、ManagementShareEffectiveAccess（S1限定受容）、Stage2TotalExecutionCountの残留UNKNOWNを維持し、P2-05一般のリスク受容に自動拡張しない。

## 2. Read-onlyで参照する資料（現在のRepository正本を優先）

1. `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md`（とくに§45～54、§59～62）。当該仕様の成立時Baseline記述は歴史的に保持する。
2. P2-05のBoundary Confirmation、Cross-document Consistency Review、**Current Production Source Review**、**Production Patch Designの正式承認記録**。未発見なら`NOT_FOUND`とする。
3. P2-05 Production実装・変更履歴・Patch Review、各Integration Verification／Compatibility Evidence、Compile Evidence、Static Review、Final Finding Assessment、Completion Record。未作成・Draft・Approved・実施済みを区別する。
4. `IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md`、その他既存P2-05 Finding/Observation記録。v0.7以降の正本があれば現在Versionと履歴を確認する。
5. P2-01～04のRegression CLOSED記録とRaw Evidence、S1 Archive Manifest/Private Indexの必要な参照、S2・S3のClosure、S4のBL-MVP-004 Approved/Registry同期結果、`Project_Overview.md`、`Current_Handoff.md`。
6. 現行RepositoryのVBA Production Source、関連 `.bas`／`.cls`／Workbookへの参照、Source Hash/Build Provenanceを**読むだけ**で照合する。Source export、Excel/Outlookの起動・実行・保存を要する照合は行わない。Read-onlyでは確認不能なら`UNKNOWN`とする。

ファイル名が異なるときは実Repositoryの正本ID・リンクを優先し、候補を推測して正本化しない。Private Evidenceの機微な内容・ユーザーの実パス・SID・生ログは公開管理文書や出力へ転載せず、参照IDと検証結果に限定する。

## 3. 照合タスク（全部Read-only）

### A. 実装・Source・Provenance Gate

- Implementation Specification：APPROVEDの正本Version、現在のBL-MVP-004と仕様作成時のBL-MVP-003の関係を判別する。Baseline参照を機械的に置換しない。
- Current Production Source Review：`COMPLETE`を裏付ける証跡、対象Module／API／版・SHA・時点を確認する。
- Production Patch Design：正式`APPROVED`を裏付ける証跡・対象変更・責務を確認する。CandidateとApprovedを区別する。
- 現行Production Source：`modUiController`、`modSyncApplication.ExecuteManualSync`、既存Result carrier、現行Button/Macro接続、関連UI／Applicationの責務境界が承認設計と一致するかを**静的な根拠範囲のみ**照合。新規コード評価や修正は行わない。
- Production ImplementationとPatch ReviewのPASSは、現在のSource版に結びつく実Evidenceがある場合のみ認定する。単にファイルが存在するだけで`PASS`としない。
- `Build Provenance`：実行Evidence ↔ Source版／ハッシュ ↔ Workbook同一性の**立証済み範囲と未立証範囲**を分離して記録する。過去Workbookの完全同一性を仮定しない。

### B. P05-I01～I17 Integration Verification：17件を個別照合

- I01 Mixed Result、I02 New Only、I03 Existing Only、I04 Reactivated Only、I05 Unused Only、I06 Zero-diff Success。
- I07 Invalid Candidate、I08 OFT Missing、I09 Template/Scan Technical Failure、I10 Definition Read Failure、I11 BuildSyncDiff Failure、I12 ApplySyncDiff Failure。
- I13 Success Contract Violation / syncDiffResult Nothing、I14 Success Contract Violation / templateScanResult Nothing、I15 Failure without Displayable Detail、I16 Fresh Retry、I17 Manual Only。

各Caseについて、Case ID、原Evidence、実施／未実施、実行日時の立証状況、Source対応、入力・期待値・実際結果・通知回数、PASS／FAIL／NOT_VERIFIED／NOT_APPLICABLE（正式根拠がある場合のみ）を確認する。**未実施・未発見をPASSとしない。** Fault Injection不能の場合も無断でN/A化せず、既存Finding Ruleに従う「必要なEvidence Strategy判断」として分離する。

`IF-P2-05-001 v0.7`に記載されたI03とI09のPASSは**既存報告Evidence**として再評価する。I16について同文書はその調査Sequenceでは未成立と記録しているため、他に独立した正式EvidenceがなければPASSとしない。その他のCaseについても、その後の正本があれば証跡単位で照合する。

### C. P05-K01～K04 Contract Compatibility：4件を個別照合

- K01：P2-04 `ExecuteManualSync` Public API Signature不変。
- K02：`SyncDiffResult` のNew／Existing／Reactivated／Unused Carrier互換。
- K03：`TemplateScanResult.InvalidCandidates` Carrier互換、再Scanなし。
- K04：既存`COperationResult`／`CErrorInfo`相当のResult Model互換。

CaseごとにEvidence ID、判定、Source対応、残存事項を報告。仕様上の期待を実施PASSと混同しない。

### D. Regression / Compile / Static / Review Gate

- P2-01～P2-04の既存Regression正式Closureと証跡を参照する。ただし**P2-05実装後のRegression維持確認**が要求される範囲・時点を区別し、古いPASSを自動的に新しい実行PASSへ読み替えない。
- VBA Compile：承認済み仕様§52・§59に従い、**Production Patch後の現行版Compile PASS**に相当するEvidenceが存在するかを調べる。2026-10-10のユーザー申告と「以後変更なし申告」の適用可能性・限界を明記。Compileは**実行しない**。
- Static Review **S01～S32を32件それぞれ**、現行Source・既存レビューの根拠と照合する。仕様§49をチェックリスト正本とし、未実施をPASS／CLOSEDとしない。S01～S32の必要要件はすべて既存仕様を使用し、新しいルールを発明しない。
- Production Patch Review、Final Finding Assessment、Active Finding 0、Blocking Finding 0を**P2-05対象範囲**で別々に検証する。Project全体Finding 0を宣言しない。
- 新たなWordEditor E_FAIL再発を示す既存証跡があれば、`IF-P2-05-001`のReopen条件に照らし`REVIEW_REQUIRED`とする。**診断・再現試験は実施しない**。

### E. 完了条件・必要作業の切り分け

仕様§59にある次のGateを1項目ずつ評価：Approved Specification、Source Review COMPLETE、Patch Design APPROVED、VBA Compile PASS、Production Implementation PASS、I01～I17 Applicable PASS、K01～K04 PASS、P2-01～04 Regression PASS、Static Review S01～S32 PASS/CLOSED、Production Patch Review PASS、Final Finding Assessment PASS、Active Finding 0、Blocking Finding 0。

各項目を次のいずれかで分類する：`VERIFIED_PASS`／`DOCUMENTED_PASS_WITH_LIMITATION`／`NOT_VERIFIED`／`NOT_STARTED`／`REVIEW_REQUIRED`／`BLOCKED`。資料間の時点差・Scope差・Version差は事実として報告する。**S5の完了条件の強弱を独断で変更しない。**

未実施のVerificationを具体的に列挙し、必要な実行順序と、そのための**次回の限定承認単位**を提案する。承認済みS1～S4の再開・再Closureを提案しない。

## 4. 厳格な禁止事項

- 文書・Source・Workbook・Test Fixture・Archive・Manifest・Registryの**作成、編集、エクスポート、コピー、移動、削除、リネーム、保存**。
- VBA `Compile`、Excel／Outlookマクロ実行、Unit／Integration／Regression／Diagnostic／Static Reviewの新規実施（**既存レビュー結果の読み取り**は可）。
- `Git`の操作（status / diff / add / commit / push / checkout / reset等）。Git証跡が必要なら既存文書のみ参照。
- BL-MVP-004再承認・再構成、Baseline変更、過去のExecution Baselineの一括書換え。
- 未立証CaseのPASS認定、Findingの勝手なCLOSED・N/A化、残留UNKNOWNのPASS昇格。
- S5正式Completion、P2 Phase Exit、CP-P2確立、S6着手、Formal MVP Test PASSの宣言。
- 調査失敗時の自動Retry・Rollback、追加の調査範囲拡大。

## 5. 完了報告（簡潔・機微情報非掲載）

```text
S5PrecheckAuthorization: READ_ONLY
S1Closure: G2_RECORDED_S1_CLOSED (existing)
S2Closure: S2_FORMAL_CLOSURE_RECORDED (existing)
S3Closure: S3_FORMAL_CLOSURE_RECORDED (existing)
S4RepositoryAcceptance: PASS (existing)

ApprovedSpecification: VERIFIED_PASS / ...
CurrentProductionSourceReview: ...
ProductionPatchDesign: ...
CurrentSourceIdentification: ...
BuildProvenanceCoverage: ...
ProductionImplementation: ...

P05_Integration_I01_I17: [case-by-case matrix; verified / not verified]
P05_Compatibility_K01_K04: [case-by-case matrix]
Regression_P2_01_P2_04: [record status, time/scope limitations]
VBACompileCurrentGate: ...
StaticReview_S01_S32: [32-item matrix; PASS/CLOSED only with evidence]
ProductionPatchReview: ...
FinalFindingAssessment: ...
ActiveFinding_P2_05_Scope: ...
BlockingFinding_P2_05_Scope: ...
OBS_P2_05_002: OPEN_NON_BLOCKING (unless existing evidence changes assessment)

VerifiedReadyConditions: [...]
MissingEvidenceOrVerification: [...]
DecisionGaps: [...]
NextMinimalAuthorizedWorkProposal: [scope; do not execute]

S5PrecheckDecision: READY_FOR_NEXT_AUTHORIZATION / REVIEW_REQUIRED / BLOCKED
P2_05CompletionRecorded: FALSE
P2PhaseClosed: FALSE
CP_P2Established: FALSE
DocumentMutation: NONE
TechnicalTestOrCompileExecuted: NONE
GitOperation: NONE
BaselineMutation: NONE
S6Started: FALSE
```

判定ルール：
- `READY_FOR_NEXT_AUTHORIZATION`：必要Evidence、未実施作業、次の限定承認範囲が特定され、計画化を阻む未解決判断がない。**Completion条件がすべてPASSしたことを意味しない。**
- `REVIEW_REQUIRED`：正式な判断またはEvidence Strategy／Source対応の確認が先に必要。
- `BLOCKED`：必要な基礎資料欠落や確定的な不整合により、次の実行範囲を安全に確定できない。

現行Source・実行Evidence・Compile・静的レビューは、CodexがユーザーPC上のRepositoryの実体で照合すること。今回共有された過去の資料のみから、現在の実施状況を推測しない。

**調査結果を報告して停止。次工程の実行は別途ユーザー承認。**
