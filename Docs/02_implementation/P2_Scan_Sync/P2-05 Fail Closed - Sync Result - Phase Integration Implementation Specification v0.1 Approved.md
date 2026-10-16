# P2-05 Fail Closed / Sync Result / Phase Integration
# Implementation Specification v0.1 — Approved

## 1. Document Information

| 項目 | 内容 |
|---|---|
| 文書名 | P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification |
| Version | v0.1 |
| Status | **APPROVED** |
| Execution Baseline | `BL-MVP-003` |
| Phase | P2 Scan / Sync |
| Implementation Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Preceding Unit | P2-04 Manual Sync Integration |
| Boundary Confirmation | **PASS** |
| Cross-document Consistency Review | **PASS / CLOSED** |
| Requirement Gap | **NONE** |
| Design Finding | **NONE** |
| Blocking Finding at Entry | **0** |
| Formal MVP Test | **NOT CLAIMED** |

---

## 2. Purpose

本Specificationは、P2最後のImplementation Unitである、

```text
P2-05
Fail Closed / Sync Result / Phase Integration
```

について、Production実装前に以下を固定する。

```text
Contract

Manual Sync UI Entry

Application / UI Responsibility

Success / Failure Decision

Sync Result Presentation

Invalid Candidate Presentation

P2-level Fail Closed

Retry Boundary

Verification Criteria

Completion Boundary
```

P2-05では、P2-01～P2-04ですでに成立したSync Core / Persistence / Application Orchestrationを再実装しない。

---

## 3. Source of Truth

本Specificationは以下をSource of Truthとする。

```text
DOC-MVP-REQ
MVP Requirements v0.1.9

DOC-MVP-DES
MVP Design v0.1.9

DOC-MVP-TESTSPEC
MVP Test Specification v0.1.5

DOC-MVP-IMPL
Implementation Plan v0.3

P2-04 Manual Sync Integration
Completion Record v0.1

P2-05 Fail Closed / Sync Result / Phase Integration
Boundary Confirmation v0.1

P2-05 Fail Closed / Sync Result / Phase Integration
Cross-document Consistency Review v0.1
```

Execution Baseline：

```text
BL-MVP-003
```

---

## 4. Entry Conditions

P2-05 Implementationへ進む前提を以下とする。

```text
P2-01 Full Template Scanner
COMPLETE

P2-02 Sync Diff Core
COMPLETE

P2-03 VariableDefinition Sync Persistence
COMPLETE

P2-04 Manual Sync Integration
PASS / COMPLETE

P2-05 Boundary Confirmation
PASS

P2-05 Cross-document Consistency Review
PASS / CLOSED

BC-P2-05-001
RESOLVED / CLOSED

BC-P2-05-002
RESOLVED / CLOSED

Blocking Finding
0
```

---

## 5. Primary Responsibility

P2-05のPrimary Responsibilityを以下に限定する。

```text
Manual Sync explicit user entry

P2-04 ExecuteManualSync connection

Basic Sync Result Presentation

Basic Success Notification

Basic Failure Notification

InvalidCandidates Presentation

P2-level Fail Closed

Fresh Manual Retry Connection

P2 Phase Integration
```

---

## 6. Explicit Non-responsibility

P2-05では以下を実装しない。

```text
Template Scanner意味論

Variable Syntax Regex判定

Case Insensitive Identity計算

Sync Classification計算

Canonical VariableName計算

Rename推測

Metadata Target計算

SyncTimestamp取得 / 再計算

VariableDefinition Persistence意味論

Automatic Retry

Rollback

Transaction Emulation

Dynamic UserForm

Validation UI

Unused Confirmation UI

Mail Generation

Final Sync Result UI

Final Error Code Taxonomy

Final User-facing Error Mapping

OFT Recovery UI

COM Lifecycle最終化

Product-wide Final Fail Closed

Formal MVP Test

MVP Product PASS
```

---

# 7. Established P2-04 Public Contract

P2-05はP2-04のApproved Public Contractを変更しない。

```vb
Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object, _
    ByRef templateScanResult As Object _
) As COperationResult
```

P2-05からP2-04へ新しい引数を追加しない。

P2-05の都合で、

```text
UI Flag
Message Format
Display Mode
Retry Flag
```

等を`ExecuteManualSync`へ追加しない。

---

## 8. P2-04 Success Contract

Success時：

```text
COperationResult.Success = True

syncDiffResult
= Persistence成功済みSyncDiffResult

templateScanResult
= Current TemplateScanResult
```

P2-05は、

```text
COperationResult.Success
```

をManual Sync Success判定のSource of Truthとする。

ただしSuccess ContractのStructural Guardとして、

```text
syncDiffResult Is Nothing
templateScanResult Is Nothing
```

のいずれかが成立した場合はSuccess Presentationへ進まない。

これは分類や成功意味論の再判定ではなく、P2-04 Output ContractのDefensive Guardである。

---

## 9. P2-04 Invalid Candidate Contract

Invalid Candidate時：

```text
COperationResult.Success = False

syncDiffResult
= Nothing

templateScanResult
= Current TemplateScanResult

templateScanResult.InvalidCandidates
= PRESERVED
```

P2-05は、

```text
InvalidCandidates
```

を再Scanせず、そのままUser Presentationへ使用する。

P2-05でRegex判定を再実行しない。

---

## 10. P2-04 Other Failure Contract

Template取得前 / Scan Technical / Definition Read / Build / Apply等のFailure：

```text
COperationResult.Success = False

syncDiffResult
= Nothing
```

`templateScanResult`はFailure Stageにより、

```text
Nothing
```

または、

```text
成立済みCurrent TemplateScanResult
```

となり得る。

P2-05はFailure Stageを推測してApplication Resultを上書きしない。

---

# 11. SyncDiffResult Contract

P2-05はP2-02 / P2-04で成立した以下のShapeをPresentation Inputとして使用する。

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

各Diff Itemは少なくとも以下を持つ既存Carrierである。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

P2-05のBasic Result Presentationでは原則として、

```text
VariableName
```

のみをUser-facing Difference Listへ使用する。

MetadataをBasic Result画面へ表示することはP2-05必須としない。

---

# 12. Presentation Mapping

Cross-document Reviewで確定したUser-facing Mappingを固定する。

```text
Internal Classification
→ User-facing Category

New
→ 新規

Existing
→ 継続

Reactivated
→ 復活

Unused
→ Unused化
```

P2-05では、

```text
Existing + Reactivated
```

を1つのCollectionへマージしない。

Internal Classificationを保持したままPresentation Labelだけを変換する。

---

# 13. Basic Sync Result UI

P2 Basic Sync Result UIは最小構成とし、

```text
1 Manual Sync実行
→ 1回の結果通知
```

を基本とする。

Candidate実装方式：

```text
UI LayerからのModal Message
```

VBA Production Candidateでは、

```text
MsgBox
```

相当の単一モーダル通知を基本方式とする。

ただしMsgBox呼出は、

```text
modSyncApplication
```

には置かない。

UI Layer側で実施する。

P6ではこのBasic UIを最終形へ変更可能とする。

---

## 14. Success Message Structure

Success時の基本表示構造を以下とする。

```text
テンプレート同期結果

新規 (n件)
<VariableName list or なし>

継続 (n件)
<VariableName list or なし>

復活 (n件)
<VariableName list or なし>

Unused化 (n件)
<VariableName list or なし>
```

表示順は固定する。

```text
1. 新規
2. 継続
3. 復活
4. Unused化
```

各Categoryが0件の場合もSection自体は表示する。

例：

```text
新規 (0件)
なし
```

これにより、

```text
分類が0件
```

と、

```text
分類表示自体が欠落
```

を区別可能とする。

---

## 15. Success Message Variable Ordering

各Category内のVariable順序は、

```text
SyncDiffResultの既存Carrier順
```

を維持する。

P2-05 Presentation都合で新しいSort Ruleを追加しない。

Alphabetical Sort等を新規実装しない。

Current Source Review / Production Designで既存CarrierがDictionary等で順序保証を持たないことが判明した場合のみ、表示安定性のためのImplementation Detailを別途評価する。

---

# 16. Zero-diff Success

Manual Syncが正常完了し、

```text
New = 0
Existing = 0
Reactivated = 0
Unused = 0
```

の場合も、

```text
COperationResult.Success = True
```

であればSuccessとして扱う。

表示例：

```text
テンプレート同期結果

新規 (0件)
なし

継続 (0件)
なし

復活 (0件)
なし

Unused化 (0件)
なし
```

「変更なし」を新しい第5分類として追加しない。

---

# 17. Failure Presentation Priority

Failure時は以下のPriorityでPresentation Dataを選択する。

```text
1. InvalidCandidatesが存在
   ↓
   Invalid Candidate Presentation

2. InvalidCandidatesなし
   +
   COperationResult Failure情報あり
   ↓
   Existing Result Error Presentation

3. 上記情報を取得不能
   ↓
   Generic Basic Failure Presentation
```

Success PresentationはFailure時に絶対に表示しない。

---

## 18. Invalid Candidate Presentation

以下が成立する場合：

```text
COperationResult.Success = False

templateScanResult Is Nothing = False

InvalidCandidates.Count > 0
```

Invalid Candidate Presentationを使用する。

基本表示構造：

```text
テンプレート内に命名規則違反の変数記法があります。
同期は実行されませんでした。

対象
<Invalid Candidate 1>
<Invalid Candidate 2>
...
```

Invalid Candidate文字列は、

```text
TemplateScanResult.InvalidCandidates
```

の内容をそのままUserへ識別可能な形で表示する。

P2-05でCandidateを修正・正規化・再判定しない。

---

# 19. Other Failure Presentation

Invalid Candidate以外のFailureでは、

```text
COperationResult
```

が保持する既存Error情報を利用する。

利用対象：

```text
Message
Target
```

複数Errorが存在する場合は、UI Layerで1つのBasic Failure Messageへ集約可能とする。

P2-05では、

```text
ErrorType → 最終User文言
```

の独自Mapping Tableを作らない。

Technical Errorの最終User Message MappingはP6へ残す。

---

## 20. Generic Basic Failure Presentation

以下の異常Contractが発生した場合：

```text
COperationResult.Success = False
+
InvalidCandidatesなし
+
Userへ表示可能なError情報なし
```

または、

```text
ExecuteManualSync Result = Nothing
```

等のDefensive Failureでは、

```text
テンプレート同期に失敗しました。
同期結果を確定できませんでした。
```

相当の最小Generic Messageを表示可能とする。

このGeneric MessageはP6のFinal Error Mappingを代替しない。

---

# 21. UI / Application Responsibility

Responsibilityを以下で固定する。

## UI Layer

```text
Manual Sync User Entry

ExecuteManualSync呼出

Success / Failure Branch

Basic Message組立

Basic Result Presentation

InvalidCandidates Presentation
```

## modSyncApplication

```text
Manual Sync Application Use Case

Current State Acquisition

Scanner / Sync / Persistence Orchestration

Failure Propagation

TemplateScanResult Handoff

SyncDiffResult Handoff
```

`modSyncApplication`へ以下を追加しない。

```text
MsgBox

User-facing Message Formatting

Button Event

UI Control Access
```

---

# 22. P2 UI Module Candidate

Cross-document Review Decisionに従い、

```text
modUiController
```

をP2 Basic Sync UI ConnectionのProduction Candidate Ownerとする。

ただしCurrent Production Source Review前のため、以下はCandidate扱いとする。

```text
Existing module presence
Existing shell content
Existing Public Procedure names
Name collision
Current responsibility
```

Current Source ReviewでConflictがなければ`modUiController`を採用する。

Conflictがある場合はResponsibilityを維持したまま最小Correctionを行う。

---

## 23. Proposed UI Entry Contract

Manual Sync Button / Excel UIから呼出可能なUI Entryは、

```text
Public Sub
No arguments
```

を基本Contractとする。

Candidate Procedure Name：

```vb
Public Sub RunManualSync()
```

目的：

```text
User explicit action
↓
ExecuteManualSync
↓
Basic Result Presentation
```

Final Procedure NameはCurrent Source ReviewでName Collisionを確認後に確定する。

Name変更のみで意味論は変更しない。

---

# 24. Proposed Private UI Responsibilities

`modUiController`内のLogical Private Responsibilityを以下とする。

```text
RunManualSync
│
├─ ExecuteManualSync Call
├─ Validate Returned Contract
├─ Branch Success / Failure
│
├─ Build Basic Success Message
│   ├─ New
│   ├─ Existing
│   ├─ Reactivated
│   └─ Unused
│
├─ Build Invalid Candidate Message
│
├─ Build Existing Result Failure Message
│
└─ Show Basic Notification
```

Private Procedure具体名はProduction Designで決定する。

新しいPublic APIを必要以上に追加しない。

---

# 25. Proposed Processing Flow

```text
User
↓
Manual Sync UI action
↓
UI Entry
↓
syncDiffResult = Nothing
templateScanResult = Nothing
↓
modSyncApplication.ExecuteManualSync(
    syncDiffResult,
    templateScanResult
)
↓
operationResult取得
↓
operationResult Is Nothing?
├─ Yes
│   ↓
│  Fail Closed
│   ↓
│  Generic Failure Notification
│   ↓
│  Stop
│
└─ No
    ↓
operationResult.Success?
├─ True
│   ↓
│  syncDiffResult Is Nothing?
│  OR
│  templateScanResult Is Nothing?
│  ├─ Yes
│  │   ↓
│  │  Contract Failure
│  │   ↓
│  │  Success Notification禁止
│  │   ↓
│  │  Generic Failure Notification
│  │   ↓
│  │  Stop
│  │
│  └─ No
│      ↓
│  SyncDiffResult 4分類取得
│      ↓
│  Basic Success Message生成
│      ↓
│  Success Notification
│      ↓
│  End
│
└─ False
    ↓
    Success Notification禁止
    ↓
templateScanResultあり？
+
InvalidCandidates > 0?
├─ Yes
│   ↓
│  Invalid Candidate Message生成
│   ↓
│  Failure Notification
│   ↓
│  End
│
└─ No
    ↓
COperationResult Error情報取得
    ↓
Error情報あり？
├─ Yes
│   ↓
│  Basic Failure Message生成
│   ↓
│  Failure Notification
│   ↓
│  End
│
└─ No
    ↓
Generic Failure Notification
    ↓
End
```

---

# 26. Fail Closed Rules

P2-05 Fail Closed Rulesを以下で固定する。

### FC-01

```text
operationResult = Nothing
→ Success Notification禁止
```

### FC-02

```text
operationResult.Success = False
→ Success Notification禁止
```

### FC-03

```text
operationResult.Success = True
+
syncDiffResult = Nothing
→ Success Notification禁止
```

### FC-04

```text
operationResult.Success = True
+
templateScanResult = Nothing
→ Success Notification禁止
```

### FC-05

```text
InvalidCandidates > 0
→ Success Notification禁止
```

### FC-06

```text
Failure時
→ UI側からBuildSyncDiff / ApplySyncDiffを再呼出ししない
```

### FC-07

```text
Failure時
→ VariableDefinitionをUIから直接変更しない
```

### FC-08

```text
Failure時
→ Automatic Retryしない
```

---

# 27. OFT Missing Boundary

OFT不存在はP2-04でFailureとして返却される。

P2-05は以下のみ担当する。

```text
Failure Result受領
↓
Success Notification禁止
↓
Basic Failure Notification
↓
Stop
```

P2-05 UIから、

```text
Sync Engine
BuildSyncDiff
ApplySyncDiff
```

を直接呼び出さない。

OFT不存在時の最終Recovery UIはP6責務とする。

---

# 28. Invalid Candidate Boundary

Invalid Candidateは、

```text
P2-04
→ Failure
→ InvalidCandidates保持
```

を利用する。

P2-05 UIは、

```text
InvalidCandidates Presentation
```

のみ担当する。

以下は禁止する。

```text
再Scan

Regex再判定

Invalid Candidate自動修正

VariableDefinition更新

Success扱い
```

---

# 29. Technical / Persistence Failure Boundary

以下のFailure：

```text
Template Read
Outlook Readiness
Scan Technical
Definition Read
BuildSyncDiff
ApplySyncDiff
Unexpected Error
```

について、P2-05は、

```text
COperationResultをUser Notificationへ接続
```

する。

P2-05 UI内で技術Failureを再実行しない。

P6 Final Error Mappingを先取りしない。

---

# 30. Retry Specification

再実行はUserによる新しいManual Sync操作とする。

```text
Failure
↓
Userが原因を修正
↓
Userが再度Manual Sync
↓
RunManualSync
↓
ExecuteManualSync
↓
Fresh Current State
```

Previous Executionの、

```text
syncDiffResult
templateScanResult
Error State
Message State
InvalidCandidates
```

を次回実行の判定Sourceとして保持しない。

UI Entry開始時にLocal Output Referenceを毎回初期化する。

---

# 31. Automatic Execution Prohibition

P2-05実装を理由としてManual Syncを以下から自動実行しない。

```text
Workbook_Open

Worksheet_Change

Workbook_SheetChange

UserForm Initialize

Timer

Application Event

OFT File Change Detection
```

Manual SyncはUser explicit actionのみとする。

---

# 32. No Module-level Sync State

P2-05 UI Layerでは以下のModule-level Stateを持たない。

```text
Previous SyncDiffResult

Previous TemplateScanResult

Previous OperationResult

Previous InvalidCandidates

Current Sync Success Flag

Retry Counter
```

1 Manual Sync invocation内のLocal Stateのみを使用する。

---

# 33. Basic Notification Count

1 Manual Sync Invocationについて、

```text
Normal Success
→ Success Notification 1回

Failure
→ Failure Notification 1回
```

を基本とする。

同一Executionで、

```text
Error MsgBox
+
Result MsgBox
```

を二重表示しない。

Invalid CandidateもFailure Notification 1回に集約する。

---

# 34. No UI Mutation of Production Data

UI Layerでは以下を変更しない。

```text
syncDiffResult

templateScanResult

VariableDefinition

Settings

OptionMaster
```

UIはResult Consumerとする。

Presentation用文字列生成のみ許容する。

---

# 35. No Reclassification

P2-05 UIでは以下を行わない。

```text
New再判定

Existing再判定

Reactivated再判定

Unused再判定

Rename推測

Canonical VariableName変更
```

CategoryはSyncDiffResultの既存Key / Carrierをそのまま使用する。

---

# 36. Reactivated Presentation Rule

Reactivatedは必ず、

```text
復活
```

として独立Sectionへ表示する。

以下は禁止する。

```text
Reactivatedを継続へマージ

Reactivatedを新規へマージ

Reactivatedを非表示
```

これによりP2内部4分類をPresentationまで保持する。

---

# 37. P3 Boundary

P2-05では、

```text
Unused化されたVariable名
```

をSync Resultへ表示可能とする。

ただし、

```text
現在Unusedである全Variableの一覧表示

Unused確認Button

Active / Unused切替表示
```

は実装しない。

これらはP3 Unused Confirmation UI責務とする。

---

# 38. P6 Boundary

P2-05では以下を完成扱いしない。

```text
Final Sync Result Screen

Final Error Layout

Final Error Severity

Final Error Icon

Final Error Code

Technical Error → User Message Mapping

OFT Missing Recovery Guidance UI

Outlook / COM Failure Recovery UI

Product-wide Error Handling
```

P2-05 Basic NotificationはP6で最終化可能とする。

---

# 39. Expected Production Change Scope

Current Source Review前のExpected Scopeは以下とする。

```text
MODIFY Candidate:
modUiController

REUSE UNCHANGED:
modSyncApplication
modSyncEngine
modVariableDefinitionData
modTemplateScanner
modSettingsData
modOutlookAdapter
modResult

ADD Production Module:
NONE expected

DELETE:
NONE
```

ただしこれはCandidate Scopeであり、Current Production Source Review後に正式Patch Scopeを確定する。

---

# 40. New Class / Result Type Policy

P2-05では原則として新しいClass / Result Typeを追加しない。

再利用する既存Carrier：

```text
COperationResult

CErrorInfo相当

TemplateScanResult

SyncDiffResult
```

Presentation文字列作成のためだけに、

```text
CSyncResultViewModel
CSyncNotification
CManualSyncUiResult
```

等を新設しない。

必要性がCurrent Source Reviewで実証された場合のみ再評価する。

---

# 41. Error Code Policy

P2-05では新しいError Code体系を導入しない。

使用するのは既存の、

```text
COperationResult
CErrorInfo
ErrorType
Message
Target
```

相当の情報とする。

Final Error Code採否はP6へ残す。

---

# 42. Message Text Policy

P2-05で固定するのは、

```text
Success Category Label

Invalid Candidateで同期しないこと

Failure時にSuccess扱いしないこと
```

までとする。

Error Typeごとの最終文言は固定しない。

Production Designでは、既存`Message / Target`を失わないBasic Displayを設計する。

---

# 43. Dependency Direction

P2-05 Logical Dependency：

```text
UI Layer / modUiController
↓
modSyncApplication
↓
Existing P2 Components
```

禁止：

```text
modSyncApplication
→ modUiController

modSyncEngine
→ modUiController

modVariableDefinitionData
→ modUiController

modOutlookAdapter
→ modUiController
```

Core / InfrastructureからUIを呼ばない。

---

# 44. No Direct Infrastructure Access from UI

P2-05 UIから以下を直接呼ばない。

```text
ScanTemplate

BuildSyncDiff

ApplySyncDiff

GetAllVariableDefinitions

ResolveWorkbookRelativePath

CreateMailFromTemplate

ReadSubject

ReadBodyText
```

Manual Sync Production Flowの唯一のApplication Entryは、

```text
ExecuteManualSync
```

とする。

---

# 45. Verification Strategy

P2-05 Verificationは、

```text
Implementation Verification
```

として実施する。

Formal MTS PASSとはしない。

対象は、

```text
UI Integration
Result Presentation
Failure Branch
Fail Closed
Retry Boundary
Contract Compatibility
Regression
```

とする。

---

# 46. Integration Verification Cases

## P05-I01 — Happy Path / Mixed Result

Precondition：

```text
New > 0
Existing > 0
Reactivated > 0
Unused > 0
```

Expected：

```text
ExecuteManualSync Success

Success Notification 1回

新規 / 継続 / 復活 / Unused化
4 Section表示

各VariableName確認可能
```

---

## P05-I02 — New Only

Expected：

```text
新規件数 > 0

継続 / 復活 / Unused化
0件として表示

Success
```

---

## P05-I03 — Existing Only

Expected：

```text
継続へExisting表示

Reactivatedへ誤分類しない

Success
```

---

## P05-I04 — Reactivated Only

Expected：

```text
復活へ表示

継続へマージしない

Success
```

---

## P05-I05 — Unused Only

Expected：

```text
Unused化へ表示

VariableDefinition削除をUIから行わない

Success
```

---

## P05-I06 — Zero-diff Success

Expected：

```text
Success

4 Category
全て0件

Success Notification 1回
```

---

## P05-I07 — Invalid Candidate

Expected：

```text
COperationResult Failure

InvalidCandidates保持

Invalid Candidate一覧を表示

syncDiffResult = Nothing

Success Notification = 0

VariableDefinition追加更新 = 0
```

---

## P05-I08 — OFT Missing

Expected：

```text
Failure Notification

Success Notification = 0

Sync EngineへUIから進めない

VariableDefinition更新 = 0
```

---

## P05-I09 — Template / Scan Technical Failure

Expected：

```text
Failure Notification

Success Notification = 0

Unhandled Runtime Errorなし
```

---

## P05-I10 — Definition Read Failure

Expected：

```text
Failure Notification

Success Notification = 0

UIからPersistence再実行なし
```

---

## P05-I11 — BuildSyncDiff Failure

Expected：

```text
Failure Notification

Success Notification = 0

ApplySyncDiffへUIから進まない
```

---

## P05-I12 — ApplySyncDiff Failure

Expected：

```text
Failure Notification

Success Notification = 0

Persisted Success Resultとして表示しない
```

---

## P05-I13 — Success Contract Violation / syncDiffResult Nothing

Fault Condition：

```text
operationResult.Success = True
syncDiffResult = Nothing
```

Expected：

```text
Success Notification = 0

Generic Failure Notification

Fail Closed
```

ProductionへTest専用Public APIを追加しない。

Fault Injection具体方式はTest Artifactで決定する。

---

## P05-I14 — Success Contract Violation / templateScanResult Nothing

Fault Condition：

```text
operationResult.Success = True
templateScanResult = Nothing
```

Expected：

```text
Success Notification = 0

Generic Failure Notification

Fail Closed
```

---

## P05-I15 — Failure without Displayable Detail

Fault Condition：

```text
Success = False
InvalidCandidatesなし
Display可能Errorなし
```

Expected：

```text
Generic Failure Notification

Success Notification = 0
```

---

## P05-I16 — Fresh Retry

Sequence：

```text
1回目 Failure
↓
原因修正
↓
2回目 Manual Sync
```

Expected：

```text
2回目はCurrent Stateを再取得

Previous Resultを再利用しない

正常ならSuccess
```

---

## P05-I17 — Manual Only

Expected：

```text
User explicit action以外で
ExecuteManualSync自動実行なし
```

---

# 47. Contract Compatibility Verification

## P05-K01 — P2-04 Public API Compatibility

Expected：

```text
ExecuteManualSync Signature
UNCHANGED
```

---

## P05-K02 — SyncDiffResult Shape Compatibility

Expected：

```text
New
Existing
Reactivated
Unused
```

をAdapter / RecalculationなしでPresentationへ利用可能。

---

## P05-K03 — TemplateScanResult Compatibility

Expected：

```text
InvalidCandidates
```

を再ScanなしでPresentationへ利用可能。

---

## P05-K04 — Result Model Compatibility

Expected：

```text
COperationResult / CErrorInfo相当
```

の既存情報をUIで利用可能。

新Error Model追加不要。

---

# 48. Regression Verification

P2-05実装後に以下をRegression対象とする。

```text
P2-01 Full Template Scanner
PASS範囲維持

P2-02 Sync Diff Core
PASS範囲維持

P2-03 VariableDefinition Sync Persistence
PASS範囲維持

P2-04 Manual Sync Integration
PASS範囲維持

VBA Compile
PASS
```

特に以下を確認する。

```text
P2-04 ExecuteManualSync Contract変更なし

Invalid Candidate Carrier維持

Success時のみSyncDiffResult公開

Fresh State Retry維持

Automatic Retry追加なし

modSyncApplicationへUI責務流入なし
```

---

# 49. Static Review Checklist

Production Patch後、少なくとも以下をStatic Reviewする。

```text
S01  Manual Sync UI EntryはUser explicit action用
S02  ExecuteManualSyncのみをApplication Entryとして呼ぶ
S03  ExecuteManualSync Signature変更なし
S04  modSyncApplicationにMsgBox追加なし
S05  UIからScanTemplate直接Callなし
S06  UIからBuildSyncDiff直接Callなし
S07  UIからApplySyncDiff直接Callなし
S08  UIからVariableDefinition直接Writeなし
S09  Automatic Syncなし
S10  Automatic Retryなし
S11  Module-level Sync Stateなし
S12  New再計算なし
S13  Existing再計算なし
S14  Reactivated再計算なし
S15  Unused再計算なし
S16  Reactivatedを継続へマージしない
S17  New → 新規
S18  Existing → 継続
S19  Reactivated → 復活
S20  Unused → Unused化
S21  Failure時Success Notificationなし
S22  InvalidCandidates再Scanなし
S23  Success時syncDiffResult Nothing Guardあり
S24  Success時templateScanResult Nothing Guardあり
S25  Invalid Candidate Failure Presentationあり
S26  Other Failure Basic Presentationあり
S27  1 Execution = 1 Result Notification基本
S28  New Production Result Class追加なし
S29  Final Error Code体系追加なし
S30  P3 Unused Confirmation UI先取りなし
S31  P6 Final Error UI先取りなし
S32  UI / Application Dependency Direction維持
```

---

# 50. Evidence Requirements

P2-05 Verification Evidenceでは少なくとも以下を記録する。

```text
Test Case ID

Initial Template State

Initial VariableDefinition State

User Action

COperationResult.Success

syncDiffResult existence

templateScanResult existence

Category Counts

Displayed Category Labels

Displayed Variable Names

Displayed InvalidCandidates

Failure Message / Target where applicable

VariableDefinition before / after where applicable

Notification Count

Actual Result

PASS / FAIL
```

---

# 51. Test Artifact Policy

Verification用Test ArtifactはProduction Codeと分離する。

Productionへ以下を追加しない。

```text
Test-only Public API

Fault Injection Public API

Test Mode Flag

Mock Result Setter

Global Test State
```

Fault Injectionが必要なI13～I15は、既存Module差替えやTest Artifact側の方法等をProduction Design / Test Designで決定する。

---

# 52. Compile Requirement

Production Patch後は、

```text
Debug
→ Compile VBAProject
```

を実行し、

```text
PASS
```

を必須とする。

Compile Errorが残る状態でP2-05 Verificationへ進まない。

---

# 53. Finding Rule

Implementation / Verification中にFindingを検出した場合はImplementation PlanのFinding Ruleへ従う。

```text
Existing Design内で解決可能
→ Implementation Detail

Design責務不足 / 矛盾
→ Design Finding

利用者振る舞いの新判断が必要
→ Requirement Gap

Technical Decision成立性の重大不確実性
→ Technical Spike再判定
```

Implementation都合でSpecificationを暗黙変更しない。

---

# 54. Production Patch Design Entry Criteria

Production Patch Designへ進む前に以下を実施する。

```text
Implementation Specification
APPROVED

Current Production Source Review
COMPLETE

modUiController current state確認

modSyncApplication current API確認

COperationResult / Error carrier利用方法確認

Name Collision確認

Current Button / Macro Connection確認
```

---

# 55. Candidate Production Structure

現時点のLogical Candidate：

```text
modUiController

Public
└─ RunManualSync      ' Candidate name

Private
├─ ValidateManualSyncResultContract
├─ BuildSyncResultMessage
├─ AppendSyncCategory
├─ BuildInvalidCandidateMessage
├─ BuildOperationFailureMessage
└─ ShowManualSyncNotification
```

これはLogical Structureであり、Current Source Review後のProduction Patch DesignでProcedure名 / 分割数を最終決定する。

YAGNIに従い、処理量が小さい場合はPrivate Helperを統合してよい。

---

# 56. Candidate Success Message Example

```text
テンプレート同期結果

新規 (1件)
GateOwner

継続 (2件)
GateDate
ModelName

復活 (1件)
Department

Unused化 (1件)
OldOwner
```

Exact punctuation / blank lines / titleはProduction Designで微調整可能。

Category意味論は変更しない。

---

# 57. Candidate Invalid Message Example

```text
テンプレート内に命名規則違反の変数記法があります。
同期は実行されませんでした。

対象
{{1Owner}}
{{Gate-Owner}}
```

InvalidCandidatesの内容を識別可能であることを優先する。

---

# 58. Candidate Failure Message Example

既存Resultが、

```text
Message
Target
```

を持つ場合：

```text
テンプレート同期に失敗しました。

<Existing Message>

確認対象:
<Existing Target>
```

P2-05で技術例外そのものを独自変換しない。

---

# 59. Completion Criteria

P2-05 Completionには少なくとも以下を必要とする。

```text
Approved Implementation Specification

Current Production Source Review
COMPLETE

Production Patch Design
APPROVED

VBA Compile
PASS

Production Implementation
PASS

P05-I01～I17
Applicable Cases PASS

P05-K01～K04
PASS

P2-01 Regression
PASS

P2-02 Regression
PASS

P2-03 Regression
PASS

P2-04 Regression
PASS

Static Review S01～S32
PASS / CLOSED

Production Patch Review
PASS

Final Finding Assessment
PASS

Active Finding
0

Blocking Finding
0
```

Test CaseのFault Injection不能等が判明した場合は、Evidence StrategyをFinding Ruleに従って調整し、無断でN/A化しない。

---

# 60. P2-05 Completion Boundary

重要：

```text
P2-05 PASS / COMPLETE
≠
P2 Phase COMPLETE
≠
CP-P2 ESTABLISHED
```

P2-05 Completion後に、

```text
P2 Phase Verification
↓
P2 Exit Criteria Final Check
↓
CP-P2 Establishment Decision
```

を実施する。

---

# 61. P2 Phase Verification Handoff

P2-05 Completion後、P2 Phase Verificationへ以下を引き渡す。

```text
P2-01 Scanner Evidence

P2-02 Classification Evidence

P2-03 Persistence Evidence

P2-04 Manual Sync Integration Evidence

P2-05 Basic Sync Result / Fail Closed Evidence

P2-01～P2-05 Regression Evidence

Current VBA Compile PASS

Active / Blocking Finding Status
```

---

# 62. Formal MVP Test Boundary

P2-05で実施するものは、

```text
Implementation Verification
Regression Verification
Phase Preparation Evidence
```

である。

以下をClaimしない。

```text
MTS-SYNC-008 Formal PASS

MTS-SYNC-009 Formal PASS

MTS-SYNC-010 Formal PASS

MTS-SYNC-011 Formal PASS

MTS-SYNC-012 Formal PASS

Formal MVP Test PASS

MVP Product PASS
```

Formal MVP TestはP7 Test Candidate Build固定後に実施する。

---

# 63. Baseline Impact

Approved Specification時点では、

```text
BL-MVP-003:
MAINTAIN

MVP Requirements v0.1.9:
CHANGE NOT REQUIRED

MVP Design v0.1.9:
CHANGE NOT REQUIRED

MVP Test Specification v0.1.5:
CHANGE NOT REQUIRED

Implementation Plan v0.3:
CHANGE NOT REQUIRED

P2-01:
REOPEN NOT REQUIRED

P2-02:
REOPEN NOT REQUIRED

P2-03:
REOPEN NOT REQUIRED

P2-04:
REOPEN NOT REQUIRED

Technical Spike:
REOPEN NOT REQUIRED
```

とする。

---

# 64. Approval Conditions

本CandidateをApproved Unit Specificationとするには、少なくとも以下をReviewする。

```text
Requirement Consistency

Design Responsibility Consistency

MTS-SYNC-008～012 Consistency

P2 / P3 / P6 Scope Consistency

P2-04 Public Contract Compatibility

UI / Application Responsibility

Fail Closed Rules

Reactivated Presentation

Verification Coverage

No P6 Preemption

No P3 Preemption

No New Requirement
```

---

# 65. Approval Decision

本Specificationでは以下を承認する。

```text
P2-04 Public Contract:
UNCHANGED

Manual Sync Success Source of Truth:
COperationResult.Success

Success Presentation Source:
Persist済みSyncDiffResult

Invalid Presentation Source:
TemplateScanResult.InvalidCandidates

Presentation Categories:
New        → 新規
Existing   → 継続
Reactivated→ 復活
Unused     → Unused化

Basic UI:
Single Modal Notification

UI Owner Candidate:
modUiController

Application Owner:
modSyncApplication.ExecuteManualSync

Automatic Retry:
NONE

New Result Class:
NONE

Final Error Policy:
P6

Unused Confirmation UI:
P3

P2-05 Completion:
Separate from CP-P2
```

Status：

```text
APPROVED
```

---

# 66. Approval Result / Next Gate

Cross-document Consistency Review結果：

```text
Residual Conflict = 0
Blocking Finding = 0
```

したがって、

```text
Implementation Specification v0.1
APPROVED
```

とする。

次の正式Gate：

```text
Current Production Source Review
↓
Production Patch Design
```

へ進む。

---

# 67. まとめ / Summary

## 日本語

P2-05 Implementation Specification v0.1 Approvedでは、P2-04で成立済みの`ExecuteManualSync` Contractを変更せず、Manual Sync User EntryとBasic Sync Result / Failure NotificationをUI Layerへ接続する仕様とした。

Manual Sync成功判定は`COperationResult.Success`をSource of Truthとし、Success時のみPersistence成功済み`SyncDiffResult`をPresentationへ使用する。ResultはNew / Existing / Reactivated / Unusedの4分類を保持し、それぞれ「新規 / 継続 / 復活 / Unused化」として表示する。

Invalid Candidate時は`TemplateScanResult.InvalidCandidates`を再Scanせず表示する。その他Failureは既存`COperationResult / CErrorInfo`相当のMessage / TargetをBasic UIへ接続し、最終Error MappingはP6へ残す。

P2 Basic UIは1 Manual Syncにつき1回の単一モーダル通知をCandidateとし、`modUiController`をUI Entry / Presentationの所有候補とする。`modSyncApplication`へMsgBox、Button Event、User-facing Message Formatting責務を追加しない。

P2-05ではAutomatic Retry、新Result Class、Unused Confirmation UI、Final Error UI、Final Recovery UIを追加しない。

Implementation VerificationはP05-I01～I17、Contract Compatibility P05-K01～K04、Static Review S01～S32、およびP2-01～P2-04 Regressionを候補とする。

本書をApproved Unit Specificationとする。次の正式GateはCurrent Production Source Reviewである。

## English

The P2-05 Implementation Specification v0.1 Approved keeps the established P2-04 `ExecuteManualSync` contract unchanged and connects the Manual Sync user entry and basic result/failure notification through the UI layer.

`COperationResult.Success` remains the source of truth for Manual Sync success. Only a successful, persisted `SyncDiffResult` may be used for success presentation. The four internal categories remain unchanged and are presented as New, Continued, Reactivated, and Unused.

Invalid candidates are presented directly from `TemplateScanResult.InvalidCandidates` without rescanning. Other failures use the existing operation-result error information for the basic UI; final error mapping remains in P6.

The candidate basic UI is one modal notification per Manual Sync execution, with `modUiController` as the candidate UI owner. `modSyncApplication` does not gain MsgBox, button-event, or user-facing message-formatting responsibility.

P2-05 does not add automatic retry, a new result class, the Unused confirmation UI, or the final error/recovery UI.

Candidate verification consists of P05-I01–I17, compatibility checks P05-K01–K04, static review S01–S32, and P2-01–P2-04 regression verification.

This specification is Approved. The next formal gate is the Current Production Source Review.
