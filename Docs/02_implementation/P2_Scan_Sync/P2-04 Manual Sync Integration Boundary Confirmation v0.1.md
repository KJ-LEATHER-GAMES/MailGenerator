# P2-04 Manual Sync Integration Boundary Confirmation v0.1

## 1. 文書情報

| 項目                         | 内容                                                  |
| -------------------------- | --------------------------------------------------- |
| 文書名                        | P2-04 Manual Sync Integration Boundary Confirmation |
| バージョン                      | v0.1                                                |
| 対象プロジェクト                   | 定型メール作成ツール MVP                                      |
| 文書種別                       | Implementation Boundary Confirmation                |
| Status                     | Confirmed                                           |
| Current Execution Baseline | BL-MVP-003                                          |
| 対象Phase                    | P2 Scan / Sync                                      |
| 対象Implementation Unit      | P2-04 Manual Sync Integration                       |
| Primary Production Module  | `modSyncApplication`                                |
| 前提Unit                     | P2-01 / P2-02 / P2-03 = PASS / COMPLETE             |
| 次Unit                      | P2-05 Fail Closed / Sync Result / Phase Integration |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements v0.1.9
- `DOC-MVP-DES` — MVP Design v0.1.9
- `DOC-MVP-TESTSPEC` — MVP Test Specification v0.1.5
- `DOC-MVP-IMPL` — Implementation Plan v0.3
- `BL-MVP-003 Baseline Approval Record v0.1`
- `P2-01 Full Template Scanner Completion Record v0.1`
- `P2-02 Sync Diff Core Completion Record v0.1`
- `P2-03 VariableDefinition Sync Persistence Completion Record v0.1`
- P2-03からのContext Handoff / Task Handoff

---

# 2. 目的

P2-04の目的は、P2-01〜P2-03で個別に成立したProduction Contractを、Manual SyncのApplication Flowとして接続するための責務境界を確定することである。

P2-04では以下を新しく再実装しない。

```text
Template Scan意味論
Sync Classification意味論
Metadata計算規則
Persistence意味論
User-facing Sync Result
User Notification
最終Error Policy
```

P2-04が担当するのは、

```text
既存Production Component
+
既存Production Contract
        ↓
Manual Sync Application Orchestration
```

である。

本Boundary Confirmationでは、特に以下を確定する。

```text
SyncTimestamp Ownership
Call Order
Template Scan Invocation
Current VariableDefinition Retrieval
BuildSyncDiff Invocation
ApplySyncDiff Invocation
Failure Propagation
Retry Boundary
P2-05 Responsibility Separation
```

---

# 3. Current State

P2開始後、以下が成立済みである。

```text
P2-01 Full Template Scanner
PASS / COMPLETE

P2-02 Sync Diff Core
PASS / COMPLETE

P2-03 VariableDefinition Sync Persistence
PASS / COMPLETE
```

したがって現在の主要Production Flowは論理的に、

```text
Template Snapshot
↓
ScanTemplate
↓
TemplateScanResult
↓
GetAllVariableDefinitions
↓
Current VariableDefinitions
↓
BuildSyncDiff
↓
SyncDiffResult
↓
ApplySyncDiff
↓
tblVariableDefinition
```

まで各Component単位では成立している。

P2-04では、これらをApplication Layerで正式な1つのManual Sync Flowとして接続する。

---

# 4. Baseline上の責務

## 4.1 Requirements

`FR-SYNC-001` によりTemplate Syncは、

```text
Automatic Sync
```

ではなく、

```text
User Explicit Manual Sync
```

とする。

Excel起動、Workbook Open、UserForm起動等を契機として自動的にVariableDefinitionを書き換えてはならない。

---

## 4.2 Design

Application Controllerの責務は、

```text
同期・メール作成の処理順序を制御
```

である。

Manual Sync Sequenceは概念上、

```text
Template取得
↓
Template Scan
↓
Invalid Check
↓
Current VariableDefinition取得
↓
Sync Engine
↓
VariableDefinition更新
↓
Sync Result
↓
UI通知
```

として定義されている。

P2-04はこのうち、

```text
Template取得
～
VariableDefinition更新
```

までのApplication Orchestration Boundaryを担当する。

---

## 4.3 Implementation Plan

P2 Implementation Scopeには以下が含まれる。

```text
modTemplateScanner
modSyncEngine
modSyncApplication
modVariableDefinitionData
modSettingsData
modOutlookAdapter
```

したがってManual Sync OrchestrationのPrimary Production Moduleは、

```text
modSyncApplication
```

とする。

---

# 5. Boundary Decision Summary

P2-04の責務を以下で固定する。

| Responsibility                           | P2-04   |
| ---------------------------------------- | ------- |
| Manual Sync Application Orchestration    | Own     |
| Component Call Order                     | Own     |
| Template Snapshot取得経路の呼出制御               | Own     |
| `ScanTemplate` Invocation                | Own     |
| Current VariableDefinition Retrieval     | Own     |
| SyncTimestamp Acquisition                | Own     |
| `BuildSyncDiff` Invocation               | Own     |
| `ApplySyncDiff` Invocation               | Own     |
| Operation Failure Propagation            | Own     |
| Failure後の後続Call停止                        | Own     |
| Classification Logic                     | Not Own |
| Canonical VariableName Logic             | Not Own |
| Metadata Meaning / Calculation           | Not Own |
| Persistence Semantics                    | Not Own |
| User Configuration Defaulting            | Not Own |
| Final Sync Result Carrier / Presentation | Not Own |
| User Notification                        | Not Own |
| Final Error Classification / Error Code  | Not Own |
| Final Phase-level Fail Closed Policy     | Not Own |
| Automatic Retry                          | Not Own |
| Manual Sync UI Control                   | Not Own |
| Formal MVP Test                          | Not Own |

---

# 6. Primary Production Module

P2-04のPrimary Production Moduleは、

```text
modSyncApplication
```

とする。

責務は、

```text
Application Orchestration
```

に限定する。

`modSyncApplication`自身が以下のCore / Infrastructure Logicを再実装してはならない。

```text
Variable Token Parsing
VariableName Syntax Validation
Location Calculation

New / Existing / Reactivated / Unused Classification
Case Insensitive Identity Logic
Canonical VariableName Selection
Metadata Calculation

Excel Row Lookup
Excel Cell Write
New Row Append
Persistence Preflight
```

これらはそれぞれ既存の、

```text
modTemplateScanner
modSyncEngine
modVariableDefinitionData
```

へ委譲する。

---

# 7. Manual Sync Entry Boundary

P2-04 Production Flowは、

```text
明示的なManual Sync要求
```

を起点とする。

以下から暗黙的に同期を実行する機能はP2-04で追加しない。

```text
Workbook Open
Excel起動
UserForm起動
Mail生成開始
Timer
Worksheet Change
その他Event
```

P2-04ではManual Syncを実行可能なApplication Entryを成立させる。

具体的な、

```text
Button
Ribbon
Worksheet Control
Menu
UserForm Control
```

等のユーザー操作UIは本Boundaryでは固定しない。

---

# 8. Template Acquisition Boundary

P2-04はManual Sync Flowの一部としてCurrent Templateを取得する。

概念上の既存経路：

```text
Settings
↓
TemplatePath
↓
Workbook Relative Path Resolution
↓
Classic Outlook Readiness
↓
OFT MailItem
↓
Inspector / WordEditor
↓
Subject
+
BodyText
```

P2-04はこの経路をApplicationから呼び出す。

ただし以下の意味論は再実装しない。

```text
OneDrive Path Resolution
Classic Outlook Cold Start
Existing Explorer Reuse
WordEditor Initialization
MailItem Lifecycle
COM Lifecycle
```

これらは既存Production Contractを利用する。

---

# 9. Template Scanner Boundary

P2-04は取得した、

```text
Subject As String
BodyText As String
```

をP2-01 Production Scannerへ渡す。

使用する責務：

```text
ScanTemplate
```

Logical Output：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

P2-04自身は、

```text
Regex Scan
VariableName Syntax Validation
Case Insensitive Deduplication
Location Calculation
```

を行わない。

---

# 10. Invalid Candidate Boundary

`TemplateScanResult.InvalidCandidates` が1件以上存在する場合、

```text
BuildSyncDiff
ApplySyncDiff
```

へ進んではならない。

P2-04ではこの処理順序制約を保証する。

```text
ScanTemplate
↓
InvalidCandidates確認
↓
1件以上
↓
後続Mutation Pathへ進まない
↓
FailureをCallerへ返す
```

ただしP2-04では以下を最終決定しない。

```text
最終ErrorType
Error Code
User-facing Message
Invalid Candidate一覧のUI
Phase-level Fail Closed Result
```

これらはP2-05 / P6へ残す。

したがってP2-04で成立させるのは、

> Invalid Templateを成功経路としてPersistenceへ流さないApplication Sequence

までとする。

---

# 11. Current VariableDefinition Retrieval Boundary

ValidなTemplateScanResult取得後、

```text
modVariableDefinitionData.GetAllVariableDefinitions
```

を使用してCurrent VariableDefinitionを取得する。

使用するのは、

```text
Active
+
Unused
```

を含む全件である。

理由：

Sync Engineは、

```text
Existing
Reactivated
Unused
Already-Unused No-op
```

を判定するためCurrent Definition全体を必要とする。

P2-04自身はWorksheet / ListObjectを直接参照しない。

---

# 12. SyncTimestamp Ownership

## 12.1 Ownership

`SyncTimestamp` の取得責務は、

```text
P2-04 / modSyncApplication
```

とする。

P2-01：

```text
Timestamp取得しない
```

P2-02：

```text
Timestampを入力として受け取る
取得しない
```

P2-03：

```text
SyncDiffResult内TimestampをPersistence
取得しない
```

したがってApplication Layerが取得する。

---

## 12.2 Acquisition Count

1回のManual Syncにつき、

```text
SyncTimestamp取得回数 = 1
```

とする。

同一Sync内でNew / Existing / Reactivatedへ共通して使用する。

---

## 12.3 Acquisition Timing

SyncTimestampは、

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

の位置で1回取得する。

つまり、

```text
BuildSyncDiff直前
```

をP2-04のTimestamp Acquisition Boundaryとする。

理由：

- Invalid TemplateではSyncを開始しない
- Current Definition取得FailureでもSyncを開始しない
- P2-02へ渡すTimestampを1つに固定できる
- 不要に早いTimestamp取得を避けられる
- Retry時に新しいSyncとして新Timestampを取得できる

---

# 13. P2-02 Invocation Boundary

P2-04は以下の既存Production APIを呼び出す。

```vb
BuildSyncDiff( _
    templateScanResult, _
    currentDefinitions, _
    syncTimestamp, _
    syncDiffResult _
)
```

Logical Input：

```text
TemplateScanResult
+
Current VariableDefinitions
+
SyncTimestamp
```

Logical Output：

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

P2-04では以下を再計算しない。

```text
Classification
Case Insensitive Identity
Canonical VariableName
Rename Inference
TemplateLocation
FirstDetectedAt
LastDetectedAt
Status
```

P2-02のOutputをそのままP2-03へ渡す。

---

# 14. P2-03 Invocation Boundary

P2-04はP2-02成功後、

```vb
ApplySyncDiff(syncDiffResult)
```

を呼び出す。

P2-04自身は以下を行わない。

```text
Row Lookup
New Row Append
Metadata Cell Write
User Configuration Preservation Logic
Preflight Validation
Cross-class Duplicate Validation
Canonical Name Guard
```

これらはP2-03責務とする。

P2-04は、

```text
BuildSyncDiff Result
↓
ApplySyncDiff
```

をCarrier変換なしで接続する。

---

# 15. Production Sequence

P2-04で成立させるProduction Sequenceを以下とする。

```text
Manual Sync Entry
↓
Template Path / Current Template Acquisition
↓
Failure?
├─ Yes → Return Failure
└─ No
    ↓
Subject / BodyText Snapshot
    ↓
ScanTemplate
    ↓
Failure?
├─ Yes → Return Failure
└─ No
    ↓
InvalidCandidates > 0?
├─ Yes → Stop before Mutation / Return Failure
└─ No
    ↓
GetAllVariableDefinitions
    ↓
Failure?
├─ Yes → Return Failure
└─ No
    ↓
SyncTimestamp = Current Time
    ↓
BuildSyncDiff
    ↓
Failure?
├─ Yes → Return Failure
└─ No
    ↓
ApplySyncDiff
    ↓
Failure?
├─ Yes → Return Failure
└─ No
    ↓
Manual Sync Application Success
```

P2-04のSuccess条件は、

```text
Scan成功
+
InvalidCandidates = 0
+
Current Definitions取得成功
+
BuildSyncDiff成功
+
ApplySyncDiff成功
```

とする。

---

# 16. Failure Boundary

## 16.1 General Rule

P2-04で呼び出す既存Production APIがFailureを返した場合、

```text
そのFailureを成功扱いしない
+
後続Componentを呼び出さない
+
FailureをCallerへ返す
```

を基本ルールとする。

---

## 16.2 Before BuildSyncDiff

以下でFailureした場合、

```text
Template Acquisition
ScanTemplate
Current VariableDefinition Retrieval
```

`BuildSyncDiff`を呼ばない。

---

## 16.3 BuildSyncDiff Failure

`BuildSyncDiff`がFailureの場合、

```text
ApplySyncDiff
```

を呼ばない。

したがってP2-04によるVariableDefinition Mutationは発生しない。

---

## 16.4 ApplySyncDiff Failure

`ApplySyncDiff`がFailureの場合、

```text
Manual Sync Success
```

として返してはならない。

P2-03 Contract上、Runtime FailureではPartial Writeの可能性がある。

P2-04ではこれを隠蔽しない。

具体的な、

```text
Recovery Message
Error Code
User Guidance
```

はP2-05 / P6責務とする。

---

# 17. Fail Closed Responsibility Separation

P2-04におけるFailure停止と、P2-05におけるFinal Fail Closedを区別する。

## P2-04

```text
Technical / Application Sequence Guard

Failure
↓
後続Call停止
↓
Success扱いしない
↓
CallerへFailure返却
```

## P2-05

```text
Phase-level Fail Closed Integration

OFT不存在
InvalidCandidates
Sync Failure
Persistence Failure
      ↓
Final Result
      ↓
User Notification
      ↓
No Invalid Update保証
```

したがって、

```text
P2-04 Failure Propagation
≠
P2-05 Final Fail Closed Completion
```

とする。

---

# 18. Sync Result Boundary

P2-02が生成する、

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

は、P2-04でApplication Flow上利用される。

ただしP2-04では、

```text
User-facing Sync Result
```

へ変換しない。

未確定の以下はP2-05へ残す。

```text
Sync Result Carrier
New / Existing / Unused表示方式
Reactivated表示方式
件数表示
Variable一覧表示
表示順
Message Format
UI Control
```

P2-04では、

> Persistence成功時に、後続P2-05がSync結果生成へ利用可能な差分情報が存在する

ことまでをBoundaryとする。

具体的なProduction Public APIの戻りCarrierはP2-04 Unit Specificationで確定する。

---

# 19. Public API Boundary

P2-04では、

```text
modSyncApplication
```

にManual Sync用Production Public Entryを持たせる方向とする。

ただし本Boundary Confirmationでは、

```text
Procedure Name
Argument List
ByRef Output Shape
SyncResult専用Carrier有無
```

を固定しない。

これらは、

```text
P2-04 Manual Sync Integration 実施仕様 v0.1
```

でImplementation Detailとして確定する。

必須Contractのみ以下で固定する。

```text
Input:
Manual Sync Invocation

Output:
COperationResult相当

Success:
P2-01 → P2-02 → P2-03が完走

Failure:
途中Failureを成功扱いしない
```

P2-05で必要となるSyncDiffResultの受け渡し方式についても、専用Class等を先回り追加しない。

---

# 20. Retry Boundary

P2-04は自動Retryを行わない。

Failure後にユーザー等がManual Syncを再実行する場合は、

```text
Manual Sync再実行
↓
Current Template再取得
↓
ScanTemplate再実行
↓
Current VariableDefinitions再取得
↓
新しいSyncTimestamp取得
↓
BuildSyncDiff再実行
↓
新しいSyncDiffResult
↓
ApplySyncDiff
```

とする。

以下は禁止する。

```text
前回TemplateScanResultの無条件再利用
前回Current Definitionsの再利用
前回SyncTimestampの再利用
stale SyncDiffResultの再適用
```

P2-03のRetry ConstraintをApplication Flow側でも維持する。

---

# 21. State / Mutation Boundary

P2-04自身はPersistent Stateを持たない。

保持しないもの：

```text
Previous SyncTimestamp
Previous TemplateScanResult
Previous SyncDiffResult
Previous VariableDefinitions
Last Successful Sync Result
Retry Counter
```

Manual Sync実行中のLocal Variableとして必要なCarrierのみ保持する。

WorkbookをまたぐSync State永続化は行わない。

---

# 22. UI Boundary

P2-04では具体的なManual Sync UIを実装対象としない。

特に以下をBoundary外とする。

```text
Sync Button
Ribbon
Worksheet Button
UserForm Command Button
Progress UI
Result Dialog
Error Dialog
Unused確認UI
```

P2-04は、

```text
UIから呼び出し可能なApplication Boundary
```

までを成立させる。

具体UIはP2-05および後続UI Integrationで扱う。

---

# 23. Error Mapping Boundary

P2-04は既存Componentから返された、

```text
COperationResult
CErrorInfo
```

を尊重する。

P2-04自身がComponent Failureを再分類して、

```text
Final Error Code
Final User Message
Final Error Policy
```

を決定しない。

必要最小限のApplication Context付加が必要かどうかはUnit Specificationで確認する。

最終Error PolicyはP6責務を維持する。

---

# 24. Out of Scope

P2-04では以下を実装しない。

```text
Template Scanner Logic変更
Sync Engine Logic変更
Persistence Logic変更
VariableName Rule変更
Classification変更
Rename推測
Metadata Rule変更
Rollback
Transaction Emulation
Automatic Retry
Sync Result UI
User Notification
Unused確認UI
Final Error Code
Final User-facing Error Message
Final Phase Fail Closed
Configuration Validator
UserForm
Mail Generation
Formal MVP Test
CP-P2 Establishment
```

---

# 25. Verification Boundary

P2-04ではFormal MVP Testではなく、

```text
Implementation Verification
```

を行う。

最低限以下を確認対象とする。

| Verification              | 確認内容                                                 |
| ------------------------- | ---------------------------------------------------- |
| V01 Manual Entry          | 明示的なManual Sync経路からのみ同期を開始                           |
| V02 Production Pipeline   | Scanner → Data Access → Sync Engine → Persistenceが接続 |
| V03 Common Timestamp      | 1 SyncにつきTimestamp 1回                                |
| V04 Timestamp Propagation | P2-02へ同一Timestampを渡す                                 |
| V05 Invalid Stop          | InvalidCandidatesありでMutation Pathへ進まない               |
| V06 Read Failure Stop     | Current Definitions取得Failure後にBuildしない               |
| V07 Build Failure Stop    | BuildSyncDiff Failure後にApplyしない                      |
| V08 Persistence Failure   | ApplySyncDiff FailureをSuccess扱いしない                   |
| V09 Carrier Compatibility | P2-01 → P2-02 → P2-03をAdapterなしで接続                   |
| V10 Retry Fresh State     | 再実行時にCurrent Stateから再構築                              |
| V11 No Recalculation      | P2-04内でClassification / Metadata等を再計算しない             |
| V12 Regression            | P2-01 / P2-02 / P2-03既存Contractを破壊しない                |

必要に応じてWarm / Cold Outlook経路を通過するが、P1で確立済みのOutlook Lifecycle自体をP2-04で再設計しない。

---

# 26. Formal MVP Test Boundary

P2-04 Verificationは、

```text
MTS-SYNC Formal PASS
```

を意味しない。

特に以下はまだFormal PASSではない。

```text
MTS-SYNC-001
MTS-SYNC-002
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-006
MTS-SYNC-007
MTS-SYNC-008
MTS-SYNC-009
MTS-SYNC-010
MTS-SYNC-011
MTS-SYNC-012
```

Formal MVP TestはP7後のTest Candidate Buildに対して実施する。

---

# 27. P2-05 Handoff Boundary

P2-04完了後、P2-05へ以下を引き渡す。

```text
Manual Sync Application Entry
+
Template Scan Integration
+
Current Definition Retrieval
+
Single SyncTimestamp Acquisition
+
BuildSyncDiff Integration
+
ApplySyncDiff Integration
+
Failure Propagation
```

P2-05で完成させる対象：

```text
OFT不存在時Final Fail Closed
InvalidCandidates時Final Fail Closed
Sync Result Data
User-facing Sync Result
User Notification
Manual Sync UI Connection
Phase-level Error Boundary
P2 Final Integration
```

必要に応じてP2-03 Runtime Failure ContextをUser-facing Policyへ接続する。

---

# 28. Requirement / Design Impact

本Boundary Confirmationは既存Requirement / DesignをImplementation Boundaryへ具体化するものである。

```text
Requirement Gap:
NONE

New User-visible Requirement:
NONE

Design Decision Change:
NONE

Test Definition Change:
NONE

Implementation Plan Change:
NONE
```

---

# 29. Baseline Impact

Current Execution Baseline：

```text
BL-MVP-003
```

を維持する。

本Boundary Confirmationによる、

```text
Baseline Change:
NOT REQUIRED

Technical Document Version Up:
NOT REQUIRED

Technical Spike Reopen:
NOT REQUIRED
```

とする。

Boundary Confirmation後のConsistency ReviewでSemantic Conflictが検出された場合のみ再判定する。

---

# 30. Completion Boundary

P2-04 Completionのためには、少なくとも以下が必要となる。

```text
Boundary Confirmation
PASS

P2-04 Unit Specification
APPROVED

Cross-document Consistency Review
PASS

Production Implementation
PASS

VBA Compile
PASS

Manual Sync Integration Verification
PASS

P2-01 Contract Regression
PASS

P2-02 Contract Regression
PASS

P2-03 Contract Regression
PASS

Production Patch Review
PASS

Finding Assessment
PASS

Blocking Finding
0
```

P2-04 Completionだけでは、

```text
P2 Phase COMPLETE
CP-P2 ESTABLISHED
Formal MTS-SYNC PASS
MVP Product PASS
```

とはしない。

---

# 31. Final Boundary Decision

P2-04 Manual Sync Integrationの責務を以下で確定する。

```text
Manual Sync Invocation
↓
Current Template Acquisition
↓
Template Scan
↓
Invalid Guard
↓
Current VariableDefinition Retrieval
↓
Single SyncTimestamp Acquisition
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
Application Success / Failure
```

Primary Module：

```text
modSyncApplication
```

P2-04 Owns：

```text
Application Orchestration
Call Order
SyncTimestamp Acquisition
Scan Invocation
Current Definition Retrieval
BuildSyncDiff Invocation
ApplySyncDiff Invocation
Failure Propagation
Retry Fresh-State Boundary
```

P2-04 Does Not Own：

```text
Scanner Meaning
Classification Meaning
Metadata Meaning
Persistence Meaning
Final Sync Result UI
User Notification
Final Error Policy
Final Phase-level Fail Closed
```

判定：

```text
P2-04 Boundary:
CONFIRMED

Requirement Gap:
NONE

Design Conflict:
NONE

Baseline Conflict:
NONE

Blocking Finding:
0
```

---

# 32. Next Action

次の正式作業は、

```text
P2-04 Manual Sync Integration
Cross-document Consistency Check
```

とする。

その後、

```text
Boundary Confirmation
↓
Cross-document Consistency Check
↓
P2-04 Manual Sync Integration 実施仕様 v0.1 Candidate
↓
Consistency Review
↓
Approved
↓
Production Implementation
↓
Implementation Verification
↓
Completion Record
```

の順で進める。

---

# 33. まとめ / Summary

## 日本語

P2-04 Manual Sync Integrationは、P2-01 Template Scanner、P2-02 Sync Diff Core、P2-03 VariableDefinition Sync Persistenceを `modSyncApplication` から接続するApplication Orchestrationとして責務境界を確定した。SyncTimestampはP2-04が1 Syncにつき1回取得し、`BuildSyncDiff`へ渡す。各Production APIがFailureを返した場合は後続処理を停止し、FailureをCallerへ伝播する。一方、最終的なSync Result、User Notification、Manual Sync UI、Phase-level Fail Closed、Error PolicyはP2-05 / P6へ残す。Requirement Gap、Design Conflict、Blocking Findingはなく、BL-MVP-003を維持する。

## English

P2-04 Manual Sync Integration is defined as the application orchestration that connects P2-01 Template Scanner, P2-02 Sync Diff Core, and P2-03 VariableDefinition Sync Persistence through `modSyncApplication`. P2-04 gets one SyncTimestamp for each sync and passes it to `BuildSyncDiff`. If a production call fails, P2-04 stops the later calls and returns the failure. Final Sync Result, user notification, Manual Sync UI, phase-level Fail Closed, and final error policy remain for P2-05 / P6. There is no requirement gap, design conflict, or blocking finding, and BL-MVP-003 remains unchanged.
