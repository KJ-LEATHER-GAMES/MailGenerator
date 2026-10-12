# P2-04 Manual Sync Integration
# Cross-document Consistency Check v0.1

## 1. Review Information

| 項目 | 内容 |
|---|---|
| 文書名 | P2-04 Manual Sync Integration Cross-document Consistency Check |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| Review対象 | P2-04 Manual Sync Integration Boundary Confirmation v0.1 |
| Execution Baseline | `BL-MVP-003` |
| 対象Phase | P2 Scan / Sync |
| Review種別 | Cross-document Consistency Check |
| Review Result | **PASS with Non-blocking Clarification** |
| Requirement Gap | **NONE** |
| Design Conflict | **NONE** |
| Test Specification Conflict | **NONE** |
| Implementation Plan Conflict | **NONE** |
| Contract Conflict | **NONE** |
| Blocking Finding | **0** |
| Non-blocking Clarification | **2** |

---

# 2. Review Scope

P2-04 Manual Sync Integration Boundary Confirmation v0.1について、以下とのCross-document Consistencyを確認した。

```text
DOC-MVP-REQ
MVP Requirements v0.1.9

DOC-MVP-DES
MVP Design v0.1.9

DOC-MVP-TESTSPEC
MVP Test Specification v0.1.5

DOC-MVP-IMPL
Implementation Plan v0.3

P2-01
Full Template Scanner established contract

P2-02
Sync Diff Core Completion Record v0.1

P2-03
VariableDefinition Sync Persistence Completion Record v0.1

BL-MVP-003
Baseline Approval Record v0.1
```

Current Approved Baselineは `BL-MVP-003` であり、Requirements v0.1.9、Design v0.1.9、Technical Spike A v0.4、Test Specification v0.1.5がBaseline Manifestとして承認済みである。

---

# 3. Review Axes

以下を主要Review Axisとした。

```text
Manual Sync Trigger
Application Orchestration Responsibility
Template Acquisition
Template Scanner Contract
InvalidCandidates Boundary
Current VariableDefinition Retrieval
SyncTimestamp Ownership / Timing
BuildSyncDiff Contract
ApplySyncDiff Contract
Failure Propagation
Retry Boundary
Sync Result Boundary
P2-05 Responsibility Separation
Formal MVP Test Boundary
Baseline Impact
```

---

# 4. Manual Sync Requirement Consistency

## 4.1 FR-SYNC-001

RequirementsではTemplate Syncを、

```text
Automatic Sync
```

ではなく、

```text
User Explicit Manual Sync
```

としている。

また、同期処理はTemplateから抽出したVariableと既存VariableDefinitionを比較して差分を反映する。

Boundary Confirmationでは、

```text
Manual Sync Entry
```

をApplication Flowの起点とし、

```text
Workbook Open
Excel起動
UserForm起動
Timer
Worksheet Change
```

等から自動同期しないとしている。

MTS-SYNC-001でも、Excel起動・UserForm起動等ではVariableDefinitionを自動変更せず、ユーザーが同期実行した場合のみ更新することを要求している。

判定：

```text
FR-SYNC-001 Consistency:
PASS

MTS-SYNC-001 Compatibility:
PASS
```

---

# 5. Application Controller Responsibility

DesignではApplication Controllerの主責務を、

```text
同期・メール作成の処理順序を制御
```

としている。

Template ScannerはScan、Sync Engineは差分判定、VariableDefinition Data AccessはTable Read / Writeを担当する。

P2-04 BoundaryではPrimary Production Moduleを、

```text
modSyncApplication
```

とし、

```text
Template acquisition invocation
ScanTemplate invocation
Current Definition retrieval
SyncTimestamp acquisition
BuildSyncDiff invocation
ApplySyncDiff invocation
Failure propagation
```

をApplication Orchestrationとしている。

Core / Infrastructure Logicを `modSyncApplication` へ移動しないため、Design責務分離と一致する。

判定：

```text
Architecture Consistency:
PASS

Application Responsibility:
PASS

Responsibility Duplication:
NONE
```

---

# 6. Manual Sync Sequence Consistency

Design §25.1ではManual Syncを概念上、

```text
User
↓
同期実行
↓
Settings / TemplatePath
↓
Path Resolution
↓
OFT existence
↓
Outlook Adapter
↓
Subject / BodyText
↓
Template Scanner
↓
Invalid Check
↓
VariableDefinition Data Access
↓
Sync Engine
↓
VariableDefinition更新
↓
同期結果
↓
UI通知
```

としている。

P2-04 BoundaryのProduction Sequenceは、

```text
Manual Sync Entry
↓
Template Acquisition
↓
ScanTemplate
↓
InvalidCandidates Guard
↓
GetAllVariableDefinitions
↓
SyncTimestamp
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
Application Success / Failure
```

であり、Design上の主要順序を変更していない。

P2-04では同期結果UIまで実装しないが、これはP2-04単体のImplementation Unit Boundaryであり、P2 Phase全体から削除したものではない。

判定：

```text
Design §25.1 Sequence Conflict:
NONE

P2 Unit Decomposition Conflict:
NONE
```

---

# 7. Template Scanner Contract

DesignではTemplate Scannerの入力を、

```text
Subject
BodyText
```

というString Snapshotとし、後続処理へOutlook / Word COM依存を伝播させない。

TemplateScanResultは概念上、

```text
ValidVariables
InvalidCandidates
Locations
```

を保持する。

P2-02では、P2-01 Production `ScanTemplate` のTemplateScanResultをそのまま `BuildSyncDiff` へ渡す実Production Compatibilityが確認済みである。

P2-04ではScanner意味論を再実装せず、

```text
Subject / BodyText
↓
ScanTemplate
↓
TemplateScanResult
```

を利用する。

判定：

```text
P2-01 Contract Compatibility:
PASS

Carrier Conversion Requirement:
NONE

Scanner Reimplementation:
NONE
```

---

# 8. FR-SYNC-008 / Fail Fast Consistency

Requirements `FR-SYNC-008` は、

```text
OFT不存在
Invalid Variable記法
```

の場合、

```text
手動同期を開始しない
```

と規定している。

DesignのFail Fast原則でも、

```text
OFT不存在
不正なVariable記法
```

では後続処理へ進ませない。

Test Specificationではさらに期待結果を具体化している。

```text
MTS-SYNC-009
OFT不存在
→ Sync Engineへ進まない

MTS-SYNC-010
Invalid Candidateあり
→ VariableDefinitionを更新しない
```



P2-04 Boundaryでは、

```text
OFT / Template Acquisition Failure
→ downstream stop

InvalidCandidates > 0
→ BuildSyncDiff / ApplySyncDiffへ進まない
```

としており、これらのTest Expected Resultを満たす方向である。

判定：

```text
FR-SYNC-008 Behavioral Conflict:
NONE

MTS-SYNC-009 Compatibility:
PASS

MTS-SYNC-010 Compatibility:
PASS
```

ただしTerminology上のClarificationを `CR-P2-04-001` として後述する。

---

# 9. Current VariableDefinition Retrieval

Design §25.1ではInvalid Check後に、

```text
VariableDefinition Data Access
↓
Template Dictionary / Definition Dictionary
↓
Sync Engine
```

へ進む。

P2-04 Boundaryも、

```text
InvalidCandidates = 0
↓
GetAllVariableDefinitions
↓
BuildSyncDiff
```

としている。

P2-02の成立済みContractは、

```text
GetAllVariableDefinitions
↓
Collection
↓
BuildSyncDiff
```

であり、AdapterなしのCompatibilityが成立済みである。

判定：

```text
Call Order:
PASS

P0 / P2-02 Carrier Compatibility:
PASS
```

---

# 10. SyncTimestamp Consistency

## 10.1 Source Documents

Design §7.4では、

```text
同期処理開始時に1つのSyncTimestampを取得
同一Sync内では共通して使用
```

と定義している。

Test Specification MTS-SYNC-011では、

```text
同一Syncで使用するTimestampが共通
```

であることをExpectedとしている。

Implementation Planでは、

```text
SyncTimestampの取得・1 Sync内共有方法
```

をP2のImplementation Detailとして明示的に残している。

---

## 10.2 P2-02 Contract

P2-02 Production APIは、

```vb
BuildSyncDiff( _
    templateScanResult, _
    currentDefinitions, _
    syncTimestamp, _
    syncDiffResult _
)
```

であり、Timestampは外部から入力される。

P2-02自身はCommon SyncTimestampを使用するが、取得責務は持たない。

P2-03もSyncTimestamp取得を非責務としている。

したがって、

```text
P2-04 / modSyncApplication
owns SyncTimestamp acquisition
```

というBoundary Decisionは整合する。

---

## 10.3 Acquisition Timing

Boundary Confirmationでは、

```text
Template Scan成功
↓
InvalidCandidates = 0
↓
Current VariableDefinitions取得成功
↓
SyncTimestamp取得
↓
BuildSyncDiff
```

とした。

この順序自体は、

```text
同一SyncでTimestampが1つ
```

というRequirements / Test Expectedを変更しない。

また、Implementation Planが具体的な取得方法をP2 Implementation Detailとして残しているため、

```text
BuildSyncDiff直前に1回取得
```

という実装選択は許容範囲と判断する。

ただしDesign §7.4の、

```text
同期処理開始時
```

という表現との対応を明文化する必要がある。

したがって：

```text
Design Conflict:
NONE

Implementation Detail:
VALID

Clarification:
REQUIRED
```

→ `CR-P2-04-001`

---

# 11. P2-02 Contract Consistency

P2-02で成立済みの責務は、

```text
Case Insensitive Identity
Canonical VariableName
New
Existing
Reactivated
Unused
Rename Non-Inference
Metadata Target Calculation
Common SyncTimestamp Usage
User Configuration Protection
```

である。

P2-02の非責務は、

```text
Persistence
Manual Sync Orchestration
Sync Result UI
User Notification
OFT Existence Guard
Final Invalid Template Fail Closed
```

である。

P2-04は、

```text
BuildSyncDiff Invocation
```

のみを担当し、分類・Canonical Name・Metadataを再計算しない。

判定：

```text
P2-02 Contract Conflict:
NONE

P2-02 Reopen:
NOT REQUIRED
```

---

# 12. P2-03 Contract Consistency

P2-03 Production API：

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

P2-03は、

```text
Template Scan
Classification
Canonical VariableName Calculation
Rename Inference
SyncTimestamp Acquisition
Metadata Meaning Calculation
Manual Sync Orchestration
Retry Orchestration
Sync Result UI
User Notification
```

を明示的に非責務としている。

P2-03 Completion Recordでも、次Unit P2-04の主要責務として、

```text
SyncTimestamp Acquisition
Template Scan Call
Current VariableDefinitions Retrieval
BuildSyncDiff Call
ApplySyncDiff Call
Execution Order / Orchestration
Result Handoff
```

が引き渡されている。

P2-04 Boundaryはこれと一致する。

判定：

```text
P2-03 Contract Conflict:
NONE

P2-03 Reopen:
NOT REQUIRED
```

---

# 13. Failure Propagation Consistency

P2-04 Boundaryでは、

```text
Component Failure
↓
後続Componentを呼ばない
↓
Success扱いしない
↓
FailureをCallerへ返す
```

としている。

これはDesignのFail Fast原則と一致する。

特に、

```text
BuildSyncDiff Failure
→ ApplySyncDiffを呼ばない
```

はInvalid / Incomplete StateをPersistenceへ渡さないために必要である。

`ApplySyncDiff` Runtime FailureについてはP2-03 Contract上Partial Writeの可能性を隠蔽せず、P2-04がAutomatic Recoveryを行わない。

判定：

```text
Failure Propagation:
PASS

Automatic Recovery Introduction:
NONE

Design Conflict:
NONE
```

---

# 14. Retry Boundary Consistency

P2-03ではRuntime Failure後の再実行について、

```text
Current State再取得
↓
BuildSyncDiff再実行
↓
新SyncDiffResult
↓
ApplySyncDiff
```

とし、staleなSyncDiffResultの再適用を採用していない。

P2-04 Boundaryも、

```text
Current Template再取得
Current Definitions再取得
New SyncTimestamp
New BuildSyncDiff
New SyncDiffResult
```

を要求している。

判定：

```text
Retry Contract:
PASS

Stale Result Reuse:
PROHIBITED

Contract Conflict:
NONE
```

---

# 15. Sync Result Responsibility

Requirements `FR-SYNC-007` はManual Sync完了後に少なくとも、

```text
新規
継続
Unused化
```

を区別して通知することを要求する。

MTS-SYNC-008も同じ通知をMandatory Testとして要求する。

一方、P2-04ではUser-facing Sync Resultを生成せず、

```text
P2-02 SyncDiffResult
```

をP2-05が利用可能な状態まで保持する。

Implementation Plan上、P2全体のDeliverableには、

```text
Manual Sync処理
Sync Result
```

の双方が含まれている。

したがって、

```text
P2-04 = Orchestration
P2-05 = Final Sync Result / User Notification Integration
```

というUnit分割は、P2 Phase全体としてFR-SYNC-007を満たす限り矛盾しない。

判定：

```text
FR-SYNC-007 Deletion:
NONE

P2-04 Scope Conflict:
NONE

P2-05 Dependency:
EXPECTED
```

---

# 16. P2-04 / P2-05 Fail Closed Separation

Context HandoffではP2-05に、

```text
OFT不存在時Fail Closed
InvalidCandidates > 0時Fail Closed
Sync Result Data
User Notification
Final Manual Sync Integration
Phase-level Error Boundary
```

を残している。

一方、P2-04はPersistenceを防ぐため、

```text
OFT Acquisition Failure
InvalidCandidates > 0
Build Failure
```

で技術的に後続Callを停止する必要がある。

この2つは以下のように分離すれば矛盾しない。

```text
P2-04
Technical Execution Guard
↓
危険な後続処理を実行しない
↓
Failureを返す

P2-05
Final Phase Integration
↓
Failure / Invalid Resultを受け取る
↓
User-facing Result / Notification
↓
P2 PhaseとしてFail Closedを完成
```

P2-02でもInvalidCandidates GuardはDefensive Contract Guardとして存在するが、それだけではFR-SYNC-008やMTS-SYNC-010のFinal Fail Closed成立を意味しないことが明示されている。

したがって責務分離自体は妥当である。

ただし二重実装と誤解されないようClarificationを追加する。

→ `CR-P2-04-002`

---

# 17. UI Boundary Consistency

Design §25.1にはError時およびSync Result時のUI通知が含まれる。

P2-04では具体的な、

```text
Button
Ribbon
UserForm Command
Result Dialog
Error Dialog
```

を実装しない。

これはDesignからUIを削除するものではなく、

```text
P2-05 / P6へImplementationを延期
```

するUnit分割である。

Implementation Planでも同期結果UIはP2で基本形、P6で最終化するImplementation Detailとされている。

判定：

```text
UI Requirement Removal:
NONE

Design Conflict:
NONE

P2-04 UI Boundary:
PASS
```

---

# 18. Formal MVP Test Boundary

P2-04で実施予定の、

```text
Manual Sync Integration Verification
Failure Stop Verification
Timestamp Verification
Contract Regression
```

はImplementation Verificationである。

Implementation Planでは、

```text
Local Verification
↓
Phase Verification
↓
P7 Test Candidate Build
↓
Formal MVP Test
```

を明確に分離しており、Phase VerificationでMTS相当Scenarioを確認してもFormal MVP Test PASSには算入しない。

P2-04 BoundaryもFormal MTS-SYNC PASSをClaimしない。

判定：

```text
Formal Test Boundary:
PASS

Premature Formal PASS Claim:
NONE
```

---

# 19. Cross-document Matrix

| Review Area | Requirements | Design | Test Spec | Impl Plan | Prior Contract | Result |
|---|---|---|---|---|---|---|
| Manual Sync Only | FR-SYNC-001 | §25.1 | MTS-SYNC-001 | P2 | — | PASS |
| Orchestration | — | Application Controller | — | `modSyncApplication` | P2-02/03 Non-responsibility | PASS |
| Template Scan | FR-SYNC-001 | §14 / §25.1 | MTS-SCAN | P2 Scanner | P2-01 | PASS |
| Invalid Guard | FR-SYNC-008 | Fail Fast / §25.1 | MTS-SYNC-010 | No Update | P2-02 Defensive Guard | PASS |
| OFT Guard | FR-SYNC-008 | §25.1 | MTS-SYNC-009 | No Update | Outlook/P1 Path | PASS |
| Definition Read | FR-SYNC-001 | §25.1 | Sync Tests | P2 | P0/P2-02 | PASS |
| Timestamp Ownership | — | §7.4 | MTS-SYNC-011 | Detail to Decide | P2-02/03 do not acquire | PASS |
| Timestamp Timing | — | 「同期処理開始時」 | Common only | Detail to Decide | — | PASS + Clarification |
| Diff Build | FR-SYNC-002～006 | §15 | MTS-SYNC-002～007 | Sync Engine | P2-02 | PASS |
| Persistence | FR-SYNC-002～006 | §15 / §25.1 | MTS-SYNC | P2 | P2-03 | PASS |
| Failure Stop | FR-SYNC-008 | Fail Fast | 009/010 | No Update | P2-02/03 | PASS |
| Retry | — | No conflicting rule | — | — | P2-03 | PASS |
| Sync Result | FR-SYNC-007 | §25.1 | MTS-SYNC-008 | P2 Deliverable | P2-05 handoff | PASS |
| User Notification | FR-SYNC-007/008 | §25.1 | 008～010 | P2/P6 | P2-05/P6 | PASS |
| Formal Test Boundary | — | — | Source of Truth | §10 | Prior records | PASS |

---

# 20. Clarification CR-P2-04-001
## Manual Sync Command Entry vs Sync Processing Start

### Observation

Boundary Confirmationでは、

```text
Manual Sync Entry
```

をFlow開始点としている。

一方Requirements FR-SYNC-008は、

```text
OFT不存在 / Invalid Variable
→ 手動同期を開始しない
```

と表現し、Design §7.4は、

```text
同期処理開始時にSyncTimestamp取得
```

と表現している。

このままでは、

```text
ユーザーがSync Commandを押した瞬間
=
Sync Processing Start
```

と誤読される可能性がある。

### Clarification

以降は以下を区別する。

```text
Manual Sync Command Entry
=
ユーザーが明示的に同期コマンドを要求した時点

Pre-Sync Processing
=
TemplatePath / OFT / Outlook / Scan / Invalid Guard /
Current Definition取得

Sync Processing Start
=
FR-SYNC-008等の前提Check成立後、
Sync Engineによる差分計算へ入る境界
```

P2-04 Implementationでは、

```text
Pre-Sync Processing成功
↓
Current Definitions取得成功
↓
SyncTimestampを1回取得
↓
BuildSyncDiff
```

を、

```text
Design §7.4
「同期処理開始時」
```

のImplementation Interpretationとする。

### Result

```text
Requirement Change:
NONE

Design Change:
NONE

Test Expected Change:
NONE

Implementation Detail Clarification:
YES

Blocking:
NO
```

---

# 21. Clarification CR-P2-04-002
## Technical Guard vs Final Fail Closed

### Observation

P2-04でも、

```text
InvalidCandidates > 0
OFT Acquisition Failure
Component Failure
```

で後続処理を停止する。

一方、P2-05にも、

```text
OFT不存在Fail Closed
InvalidCandidates Fail Closed
```

が残されている。

これをそのまま読むと、同じ判定をP2-04とP2-05で二重実装するように見える可能性がある。

### Clarification

責務を以下で固定する。

```text
P2-04
owns:
Execution Guard
Mutation Prevention
Failure Propagation

P2-05
owns:
Final Phase Integration
User-facing Result
User Notification
Phase-level Fail Closed Verification
```

したがってP2-05は原則として、

```text
P2-04が既に判定したFailureを無視して処理継続しない
```

一方で、

```text
同じScan / Guardロジックを新たに複製すること
```

を要求しない。

必要なDefensive Checkを除き、Final Integrationは既存Resultを利用する。

### Result

```text
Responsibility Change:
NONE

Duplicate Core Logic Required:
NO

P2-05 Scope Removed:
NO

Blocking:
NO
```

---

# 22. Finding Assessment

```text
Requirement Conflict:
NONE

Requirement Gap:
NONE

Design Conflict:
NONE

Design Gap:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P2-01 Contract Conflict:
NONE

P2-02 Contract Conflict:
NONE

P2-03 Contract Conflict:
NONE

Baseline Conflict:
NONE

Formal Test Boundary Conflict:
NONE

Non-blocking Clarification:
2

Blocking Finding:
0
```

---

# 23. Baseline Impact

Cross-document CheckによるSemantic Changeはない。

```text
MVP Requirements v0.1.9:
Change NOT REQUIRED

MVP Design v0.1.9:
Change NOT REQUIRED

MVP Test Specification v0.1.5:
Change NOT REQUIRED

Implementation Plan v0.3:
Change NOT REQUIRED

P2-01:
Reopen NOT REQUIRED

P2-02:
Reopen NOT REQUIRED

P2-03:
Reopen NOT REQUIRED

Technical Spike:
Reopen NOT REQUIRED

BL-MVP-003:
Change NOT REQUIRED
```

Current Approved Baseline：

```text
BL-MVP-003
```

を維持する。

---

# 24. Review Result

```text
P2-04 Manual Sync Integration
Cross-document Consistency Check

Requirements:
PASS

Design:
PASS

Test Specification:
PASS

Implementation Plan:
PASS

P2-01 Contract:
PASS

P2-02 Contract:
PASS

P2-03 Contract:
PASS

Formal Test Boundary:
PASS

Requirement Gap:
NONE

Design Conflict:
NONE

Blocking Finding:
0

Non-blocking Clarification:
2

RESULT:
PASS
```

`CR-P2-04-001` および `CR-P2-04-002` は既存Requirement / Designを変更するものではなく、P2-04 Implementation Specificationで明示的に継承する。

---

# 25. Boundary Status

Cross-document Checkの結果、

```text
P2-04 Manual Sync Integration
Boundary Confirmation v0.1

Status:
MAINTAIN
```

とする。

Boundary Reopen：

```text
NOT REQUIRED
```

Baseline Revision：

```text
NOT REQUIRED
```

---

# 26. Next Gate

次の正式作業：

```text
P2-04 Manual Sync Integration
実施仕様 v0.1 — Candidate
```

実施仕様では少なくとも以下を具体化する。

```text
Production Public API
modSyncApplication Procedure構成
Manual Sync Command Entry
Pre-Sync Processing
Sync Processing Start
SyncTimestamp取得実装
Production Call Sequence
Local Carrier
Failure Return
Invalid Guard
Template / MailItem Lifecycle接続
Retry Fresh-State Rule
P2-05 Result Handoff
Implementation Verification Cases
```

その際、

```text
CR-P2-04-001
CR-P2-04-002
```

を明示的に反映する。

---

# 27. まとめ / Summary

## 日本語

P2-04 Manual Sync Integration Boundary Confirmation v0.1をRequirements v0.1.9、Design v0.1.9、Test Specification v0.1.5、Implementation Plan v0.3、およびP2-01～P2-03の成立済みContractと照合した。

Requirement Conflict、Design Conflict、Test Specification Conflict、Implementation Plan Conflict、Contract Conflictはいずれもなく、Blocking Findingは0件である。

2件のNon-blocking Clarificationを抽出した。

1つ目は、ユーザーによる `Manual Sync Command Entry` とDesign §7.4の `Sync Processing Start` を区別し、SyncTimestamp取得位置の意味を明確化すること。

2つ目は、P2-04のTechnical Execution GuardとP2-05のFinal Phase-level Fail Closedを区別し、同一Guard Logicの二重実装を避けること。

いずれもRequirement / Design変更を必要とせず、Boundary Confirmation v0.1は維持できる。

Review Resultは **PASS**。

次の正式作業は **P2-04 Manual Sync Integration 実施仕様 v0.1 — Candidate** の作成とする。

## English

P2-04 Manual Sync Integration Boundary Confirmation v0.1 was checked against Requirements v0.1.9, Design v0.1.9, Test Specification v0.1.5, Implementation Plan v0.3, and the established P2-01 to P2-03 contracts.

There is no requirement, design, test specification, implementation plan, or contract conflict. There are zero blocking findings.

Two non-blocking clarifications were identified.

First, `Manual Sync Command Entry` should be distinguished from `Sync Processing Start` so that the SyncTimestamp timing is clear.

Second, the technical execution guard in P2-04 should be distinguished from the final phase-level Fail Closed integration in P2-05 to avoid duplicate guard logic.

No requirement or design change is needed. The existing P2-04 Boundary Confirmation remains valid.

The review result is **PASS**.

The next formal task is **P2-04 Manual Sync Integration Implementation Specification v0.1 — Candidate**.