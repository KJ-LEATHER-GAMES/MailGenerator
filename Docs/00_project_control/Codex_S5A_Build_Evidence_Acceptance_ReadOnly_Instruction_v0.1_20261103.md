# S5-A Build／Evidence受入範囲確認

## Codex限定Read-only実行指示

### 1. 実行承認

ユーザーは、S5-AのRead-only確認を承認しました。

本作業の目的は、S5最終検証対象Workbookを特定し、既存P05 Runtime Evidenceをどの範囲までCompletion審査へ再利用できるかを整理することです。

**今回の承認はS5-Aのみです。S5-B以降の技術検証・編集・正式Completionは許可されていません。**

### 2. 前提状態

以下を既存の確定状態として保持してください。

- S1：G2_RECORDED_S1_CLOSED
- S2：S2_FORMAL_CLOSURE_RECORDED
- S3：S3_FORMAL_CLOSURE_RECORDED
- S4：BL-MVP-004 Repository Acceptance PASS
- S5 Precheck：REVIEW_REQUIRED
- P2-05 Completion：未成立
- P2 Phase Closure：未成立
- CP-P2：未成立

P2-05 Implementation Specification v0.1 Approvedの成立時点のExecution Baseline `BL-MVP-003`と、現在受入済みの`BL-MVP-004`を区別してください。

既存の実施仕様・Closure・Baseline履歴は変更しません。

### 3. S5対象Workbookの確認

対象候補は、既存Evidence `E-P204-WB`とSHA-256が一致すると報告された外部作業Workbookです。

次のRead-only確認を実施してください。

1. S5 Precheckで識別された外部作業Workbook候補を確認する。
2. 当該Workbookの実在、ファイル種類、サイズ、SHA-256を取得する。
3. `E-P204-WB`の既存SHA-256と厳密に比較する。
4. Repository側Workbookが別バイナリである事実を保持する。
5. 外部作業WorkbookをS5最終検証対象として固定できるか判定する。

一致した場合、対象Buildの識別を`VERIFIED_BY_WORKBOOK_SHA256`と報告してください。

ただし、次は自動的にPASSとしないでください。

- Workbook内VBAProject全体とRepository Sourceの完全同一性
- 過去のP05 Runtime実行Buildとの完全同一性
- Current Button／イベント接続の正当性
- 過去の全実行履歴の同一性

外部候補が複数ある場合やHashが一致しない場合は、推測で選択せず停止してください。

Repository側Workbookへの自動切替は禁止します。

### 4. Current Sourceとの対応確認

既存の9 Sourceについて、S5 Precheckで報告された以下の証拠限定を維持します。

- 保全済み`E-P204-SOURCE`との正規化比較：9/9一致
- 文字列リテラル比較：9/9一致
- 原バイト列一致：未証明
- Workbook内VBAProject全体の同一性：未証明

今回は必要最小限のRead-only確認として、次を実施してください。

1. 現行Sourceと既存Source Reviewの対象を対応付ける。
2. `modUiController`のManual Sync Entryを確認する。
3. `modSyncApplication.ExecuteManualSync`の既存2出力APIとの接続を確認する。
4. Basic Success／Failure Notificationへのデータ受渡し経路を確認する。
5. 対象Workbook内の関連Button／イベント接続について、ファイルを変更しない静的確認が可能か調べる。
6. 確認できた範囲と確認不能な範囲を明確に分ける。

Workbook内の静的検査が安全なRead-only手段で可能な場合のみ実施してください。

Excel起動、Workbook保存、VBA Import／Export、イベント実行、マクロ実行、Compileなどが必要になる場合は、今回実施せず追加承認が必要と報告してください。

今回のSource確認を、S01～S32の正式Static Review完了として扱わないでください。

### 5. 既存P05 Runtime Evidenceの対応確認

次の既存PASSは取り消さず、原Evidenceの限定を保持してください。

- P05-I01～I17：17件
- P05-K01～K04：4件

各ケースについて、次を照合してください。

| 確認列 | 内容 |
|---|---|
| Case ID | I01～I17、K01～K04 |
| Evidence | 既存の記録名・該当節 |
| Documented Result | 既存PASSと観測内容 |
| Execution Date | 記録された日付／UNKNOWN |
| Build Association | 実行Buildとの対応根拠 |
| Evidence Method | Runtime／Behavioral／Source-path等 |
| Limitation | 未実測・未証明事項 |
| Reuse Assessment | 再利用可能範囲と残課題 |

特に以下を厳守してください。

- I03／I09：Finding Assessment等の既存Runtime Evidenceとその限定を保持。
- I10～I12：P2-04 HarnessとP2-05 Source-path Evidenceを区別。
- I13～I15：既存の受理済みSource-path Strategyを維持。新規Fault Injectionを要求しない。
- I16：独立したControlled Retry記録によるPASSを保持。F7の調査Sequence自体で成立したと書き換えない。
- I17：既存Source確認をWorkbook全イベントの完全証明へ格上げしない。
- K01～K04：既存Contract Evidenceを保持し、新規Runtime検証と混同しない。

過去のRuntime実行Buildに個別Hashがない場合は、そのままUNKNOWNとしてください。

現在のWorkbookのHash一致だけで、過去の全Runtime実行が同一Workbookだったと断定しないでください。

ユーザー・実行者による補足確認が必要な場合は、正確な確認事項を質問案として提示するだけとしてください。実行者の代わりに回答を生成しないでください。

### 6. Evidence再利用の判定

各ケースは次の観点で判定してください。

- `DOCUMENTED_PASS_WITH_LIMITATION`：既存PASSがあり、証拠限定を明記できる。
- `BUILD_ASSOCIATION_SUPPORTED`：対象Buildとの対応を支持する具体的証拠がある。
- `BUILD_ASSOCIATION_UNKNOWN`：同一Buildと断定できる証拠がない。
- `REVIEW_REQUIRED`：受入判断に必要な追加確認がある。

既存PASSとBuild対応判定は別の列として管理してください。

既存PASSの再利用方針はユーザー承認済みですが、最終Buildへの適用可能性を無条件に承認したものではありません。

新しい不一致が認められた場合は、該当ケースと影響範囲を特定し、全面再実行を自動的に要求せず停止してください。

### 7. Findingsと残留UNKNOWN

既存状態を維持してください。

- `IF-P2-05-001`：CLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING
- `OBS-P2-05-002`：OPEN／NON-BLOCKING
- WordEditor E_FAILの正確なRoot Cause：NOT PROVEN
- OneDriveRegistration：UNKNOWN
- ManagementShareEffectiveAccess：UNKNOWN
- Stage2TotalExecutionCount：UNKNOWN

OBS-P2-05-002について、追加Evidenceなしに再開・Close・Production修正を行わないでください。

S1で限定受容されたRiskを、全工程の無条件受容へ拡張しないでください。

### 8. 今回の禁止事項

- 文書・Source・Workbookの作成、編集、削除、移動、リネーム
- Workbookの保存やVBA Import／Export
- VBA Compile
- Runtime Verification／Regression再実行
- Static Review S01～S32の正式実施・PASS記録
- Production Patch Reviewの正式実施
- Final Finding Assessmentの正式実施
- Git操作
- Baseline変更
- Archive／Restore再実行
- Repository全体の再構成
- P2-05 Formal Completion
- S6着手

検証結果はCodexの応答として報告してください。新規ファイルを作成する必要はありません。

Read-only確認のために新規ファイル書込みが不可避となる場合は、その操作を実行せず停止してください。

### 9. 報告形式

次の形式で結果を報告してください。

```text
S5AAuthorization: APPROVED_READ_ONLY

TargetWorkbook:
  CandidateIdentified: YES / NO
  E-P204-WB_SHA256_Match: PASS / FAIL / UNKNOWN
  TargetBuildDesignation:
    VERIFIED / REVIEW_REQUIRED / BLOCKED

SourceAssociation:
  NineSourceNormalizedMatch:
    CONFIRMED_FROM_EXISTING_EVIDENCE / REVIEW_REQUIRED
  WorkbookVBAProjectIdentity:
    VERIFIED / UNKNOWN
  UIEntryConnection:
    VERIFIED / PARTIAL / UNKNOWN
  WorkbookEventConnection:
    VERIFIED / PARTIAL / UNKNOWN

P05EvidenceReuse:
  I01_I17_DocumentedPASS: PRESERVED
  K01_K04_DocumentedPASS: PRESERVED
  EvidenceMapping: PASS / REVIEW_REQUIRED
  HistoricalBuildIdentity: VERIFIED / UNKNOWN
  AdditionalOperatorConfirmation:
    NONE / REQUIRED

NextS5TechnicalScope:
  FinalVBACompile: PENDING
  StaticReview_S01_S32: PENDING
  ProductionPatchReview: PENDING
  FinalFindingAssessment: PENDING

OBS_P2_05_002: OPEN_NON_BLOCKING
ResidualUnknowns: UNCHANGED

S5ADecision:
  READY_FOR_S5_B_AUTHORIZATION /
  REVIEW_REQUIRED /
  BLOCKED

DocumentMutation: NONE
SourceMutation: NONE
WorkbookMutation: NONE
TechnicalExecution: NONE
GitOperation: NONE
BaselineMutation: NONE
P2_05CompletionRecorded: FALSE
S6Started: FALSE
```

あわせて、以下を簡潔に報告してください。

1. S5対象Buildとして固定できる具体的根拠
2. I01～I17／K01～K04のEvidence対応表
3. なお残るBuild／Provenance上のUNKNOWN
4. 次に必要なユーザー確認事項
5. S5-B以降で承認すべき最小作業範囲

報告後、停止してください。

`READY_FOR_S5_B_AUTHORIZATION`となっても、S5-BのCompile等を自動実行しないでください。
