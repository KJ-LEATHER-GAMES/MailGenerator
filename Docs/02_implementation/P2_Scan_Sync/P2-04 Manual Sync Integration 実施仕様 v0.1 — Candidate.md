# P2-04 Manual Sync Integration

# 実施仕様 v0.1 — Candidate

## 1. 文書情報

| 項目                        | 内容                                                                  |
| ------------------------- | ------------------------------------------------------------------- |
| 文書名                       | P2-04 Manual Sync Integration 実施仕様                                  |
| バージョン                     | v0.1                                                                |
| Status                    | **Candidate**                                                       |
| 対象プロジェクト                  | 定型メール作成ツール MVP                                                      |
| 文書種別                      | Implementation Unit Specification                                   |
| Execution Baseline        | `BL-MVP-003`                                                        |
| 対象Phase                   | P2 Scan / Sync                                                      |
| 対象Implementation Unit     | P2-04 Manual Sync Integration                                       |
| Primary Production Module | `modSyncApplication`                                                |
| 前提Unit                    | P2-01 / P2-02 / P2-03 = PASS / COMPLETE                             |
| Boundary                  | P2-04 Manual Sync Integration Boundary Confirmation v0.1            |
| Consistency Check         | P2-04 Manual Sync Integration Cross-document Consistency Check v0.1 |
| 次Unit                     | P2-05 Fail Closed / Sync Result / Phase Integration                 |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements v0.1.9
- `DOC-MVP-DES` — MVP Design v0.1.9
- `DOC-MVP-TESTSPEC` — MVP Test Specification v0.1.5
- `DOC-MVP-IMPL` — Implementation Plan v0.3
- `BL-MVP-003 Baseline Approval Record v0.1`
- `P1-07 Completion Record v0.1`
- `P2-01 Full Template Scanner Completion Record v0.1`
- `P2-02 Sync Diff Core Completion Record v0.1`
- `P2-03 VariableDefinition Sync Persistence Completion Record v0.1`

Current Approved Baselineは `BL-MVP-003` とする。

---

# 2. Change Classification

本仕様は既存BoundaryをImplementation Detailへ具体化する。

```text
Change Type:
Implementation Detail / Unit Specification

Requirement Change:
NONE

Design Change:
NONE

Test Specification Change:
NONE

Baseline Change:
NONE

Technical Spike Reopen:
NOT REQUIRED
```

新しい利用者向け振る舞いは追加しない。

---

# 3. 目的

P2-04の目的は、P2-01～P2-03で成立済みのProduction Componentを、

```text
Manual Sync Application Flow
```

として `modSyncApplication` から接続することである。

成立させるProduction経路：

```text
Manual Sync Command Entry
↓
Current Template Scan
↓
Current VariableDefinition取得
↓
Sync Processing Start
↓
SyncTimestamp取得
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
Manual Sync Application Result
```

P2-04では、

> **既存Production Contractを変更せず、Manual Syncの実行順序・Failure停止・Result HandoffをApplication Layerで成立させること**

を目的とする。

Application Controllerが同期処理順序を制御するというDesign責務に従う。

---

# 4. 前提Contract

## 4.1 P2-01 Template Scanner

Production API：

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Logical Result：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

P2-04はScanner内部の、

```text
Candidate Scan
VariableName Validation
Case Insensitive統合
Location計算
```

を再実装しない。

---

## 4.2 P2-02 Sync Diff Core

Production API：

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

Output：

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

P2-02が以下を所有する。

```text
Classification
Case Insensitive Identity
Canonical VariableName
Rename Non-Inference
Metadata Target Calculation
Common SyncTimestamp Usage
User Configuration Protection
```

Manual Sync Orchestration、Persistence、UI、User NotificationはP2-02の責務ではない。

---

## 4.3 P2-03 Persistence

Production API：

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

P2-03は、

```text
SyncDiffResult
↓
tblVariableDefinition Persistence
```

を担当する。

以下はP2-03で実施しない。

```text
Template Scan
Classification
SyncTimestamp Acquisition
Manual Sync Orchestration
Retry Orchestration
Sync Result UI
User Notification
```



---

# 5. Primary Production Module

Production Module：

```text
modSyncApplication
```

Implementation Plan上でも `modSyncApplication` はApplication LayerのP2 / P6対象Moduleである。

新Production Module：

```text
NONE
```

新Class：

```text
NONE
```

新Interface：

```text
NONE
```

新Adapter：

```text
NONE
```

YAGNIを維持する。

---

# 6. Production Source Review Gate

現時点の参照資料から、

```text
modSyncApplication
```

の現在のProduction Source本体は確認できていない。

したがってProduction Patch作成前に、

```text
Current modSyncApplication Source Review
```

を必須とする。

確認項目：

```text
Module存在有無
Current Shell内容
既存Public Procedure
既存Private Procedure
Option Explicit
Result生成Pattern
命名衝突
既存P0 Shellからの変更有無
```

本Candidateで定義するPublic API名と既存Sourceが衝突する場合は、

```text
Semantic Contractを維持した名称調整
```

を許容する。

利用者向けRequirementまたはComponent責務を変更する名称変更は認めない。

---

# 7. Scope

P2-04でProduction実装する対象：

```text
modSyncApplication

├─ Manual Sync Public Entry
├─ Current Template Scan Orchestration
├─ Scan用MailItem Lifecycle接続
├─ InvalidCandidates Execution Guard
├─ Current VariableDefinitions Retrieval
├─ SyncTimestamp Acquisition
├─ BuildSyncDiff Invocation
├─ ApplySyncDiff Invocation
├─ Failure Propagation
├─ Result Handoff
└─ Retry Fresh-State Boundary
```

---

# 8. Out of Scope

P2-04では以下を実装しない。

```text
Scanner Logic変更
VariableName Rule変更
Sync Classification変更
Canonical VariableName計算
Rename推測
Metadata Meaning変更
Persistence Logic変更

Rollback
Transaction Emulation
Backup / Restore

Automatic Retry

Final Sync Result Carrier
Sync Result Dialog
Manual Sync Button / Ribbon / UserForm UI
User-facing Error Message最終化
Final Error Code体系
Final Phase-level Fail Closed
Unused確認UI

Configuration Validator
Dynamic UserForm
Mail Generation
Formal MVP Test
CP-P2 Establishment
```

またP2-04のためだけに以下を追加しない。

```text
CManualSyncResult
CSyncApplicationContext
ISyncService
ISyncRepository
Template Snapshot専用Class
Retry Manager
Transaction Manager
```

---

# 9. Manual Sync Public API

## 9.1 Candidate API

P2-04では以下をPrimary Candidateとする。

```vb
Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object _
) As COperationResult
```

---

## 9.2 Input

明示的なArgument Input：

```text
NONE
```

TemplatePath等はCurrent Workbook Settingsから取得する。

Current Template / Current VariableDefinitionをCallerから注入しない。

理由：

```text
Manual Sync
=
Current Stateをその都度取得して同期する処理
```

であり、Callerが古いSnapshotを渡せるContractを作らないため。

---

## 9.3 Output

成功時：

```text
COperationResult.Success = True

syncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

`syncDiffResult` はP2-02 Production Outputそのものとする。

Dedicated Manual Sync Result Classは作らない。

---

## 9.4 Failure Output

Function Entry時に必ず、

```vb
Set syncDiffResult = Nothing
```

相当の初期化を行う。

以下のいずれかでFailureした場合：

```text
Template Acquisition
Template Scan
Invalid Candidate Guard
Current Definition Read
BuildSyncDiff
ApplySyncDiff
```

Callerへ返すOutputは、

```text
syncDiffResult = Nothing
COperationResult.Success = False
```

とする。

---

## 9.5 Success Output Timing

`syncDiffResult` をCallerへSuccess Outputとして確定するのは、

```text
ApplySyncDiff
SUCCESS
```

の後のみとする。

つまり、

```text
BuildSyncDiff成功
+
ApplySyncDiff失敗
```

の場合に、Target StateのDiffを「完了した同期結果」として公開しない。

P2-05へ渡すResultと実Persistence結果の不一致を防ぐ。

---

# 10. Manual Sync Command Entry

`ExecuteManualSync()` は、

```text
Manual Sync Command Entry
```

である。

これは、

```text
Sync Processing Start
```

と同義ではない。

Cross-document Checkの `CR-P2-04-001` に従い、

```text
Manual Sync Command Entry
↓
Pre-Sync Processing
↓
Sync Processing Start
```

を区別する。

---

# 11. Pre-Sync Processing

Pre-Sync Processing：

```text
TemplatePath取得
↓
Workbook Relative Path Resolution
↓
OFT Guard
↓
Classic Outlook Readiness
↓
Scan用MailItem生成
↓
Subject / BodyText取得
↓
Template Scan
↓
Scan用MailItem Cleanup
↓
InvalidCandidates確認
↓
Current VariableDefinitions取得
```

ここまでが成立するまでは、

```text
SyncTimestamp取得
BuildSyncDiff
ApplySyncDiff
```

へ進まない。

---

# 12. Current Template Scan Helper

## 12.1 Private Responsibility

`modSyncApplication` 内部に、

```text
Current TemplateをScanしてTemplateScanResultを返す
```

Private Application Helperを持つ。

Candidate名：

```vb
Private Function ScanCurrentTemplate( _
    ByRef templateScanResult As Object _
) As COperationResult
```

具体名はCurrent Source Review後に確定可能とする。

---

## 12.2 Logical Flow

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
OFT存在Guard
↓
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
ScanTemplate
↓
CloseWithoutSave
↓
TemplateScanResult
```

Design §25.1のManual Sync Sequenceと一致させる。

P1-07でも、

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject / ReadBodyText
↓
ScanTemplate
```

のProduction経路が成立済みである。

---

# 13. Settings / Path Boundary

TemplatePath取得は既存 `modSettingsData` Contractを使用する。

Workbook Relative Path Resolutionは既存：

```vb
ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult
```

を使用する。

P2-04からExcel Settings Sheetや`ThisWorkbook.Path`解決ロジックを再実装しない。

---

# 14. OFT Existence Guard

FR-SYNC-008により、OFT不存在時はSync Engineへ進んではならない。

P2-04では、

```text
Resolved Local OFT Path
↓
OFT存在確認
↓
不存在
→ Failure
→ Template Scanしない
→ GetAllVariableDefinitionsしない
→ BuildSyncDiffしない
→ ApplySyncDiffしない
```

とする。

RequirementsではOFT不存在およびInvalid Variable時に手動同期を開始しないことを要求している。

### Implementation Rule

Current P1 Production Sourceに再利用可能なOFT Guardが存在する場合：

```text
REUSE
```

再利用可能なGuardが存在しない場合のみ、

```text
modSyncApplication Private Helper
```

として最小限の存在確認を実装してよい。

新しいInfrastructure Moduleは追加しない。

---

# 15. Outlook Adapter Boundary

P2-04はOutlook / Word Object Modelを直接操作しない。

利用するLogical Production API：

```text
CreateMailFromTemplate
ReadSubject
ReadBodyText
CloseWithoutSave
```

Outlook AdapterはClassic Outlook Readiness、Cold Start Explorer初期化、MailItem / WordEditor依存を内部へ閉じ込める。

Application側では、

```text
Explorer
Inspector
WordEditor
Word.Document
Word.Range
```

を直接取得しない。

Designではこれらの依存をOutlook Adapterへ集約している。

---

# 16. Scan用MailItem Lifecycle

P2-04 Manual SyncではScan用MailItemを、

```text
Displayしない
Saveしない
同期結果Mailとして残さない
```

ものとする。

Lifecycle：

```text
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
ScanTemplate
↓
CloseWithoutSave
```

正常系・Invalid Template系ともに、

```text
Scan終了後
→ CloseWithoutSave
```

を実施する。

P1 / Designで成立済みのScan用MailItem Lifecycleを維持する。

---

# 17. MailItem Cleanup Rule

Scan用MailItem生成後は、

```text
ReadSubject Failure
ReadBodyText Failure
ScanTemplate Failure
InvalidCandidatesあり
```

の場合でも、可能な限り、

```text
CloseWithoutSave
```

を実行する。

P2-04はFailure時にScan用MailItemをDisplayしない。

---

# 18. Cleanup Result Precedence

P2-04では複雑なComposite Error Carrierを追加しない。

基本ルール：

```text
Primary Processing = Success
+
CloseWithoutSave = Failure
→ Cleanup Failureを返す
```

理由：

Lifecycle完了を確認できない状態をManual Sync Successとして扱わないため。

一方、

```text
Primary Processing = Failure
+
CloseWithoutSave = Failure
```

の場合は、

```text
Primary FailureをRoot Failureとして維持
```

する。

Cleanup Failureの最終統合・User-facing Error表現はP6へ残す。

P2-04で新しいComposite Error Modelは作らない。

---

# 19. Scanner Invocation

Snapshot取得成功後、

```vb
ScanTemplate( _
    subjectText, _
    bodyText, _
    templateScanResult _
)
```

を呼ぶ。

P2-04はScanner Resultの内容を再計算しない。

---

# 20. InvalidCandidates Execution Guard

`ScanTemplate`自体がSuccessでも、

```text
templateScanResult("InvalidCandidates").Count > 0
```

相当の場合、

```text
Manual Sync Execution Failure
```

として後続Mutation Pathを停止する。

禁止：

```text
GetAllVariableDefinitions
BuildSyncDiff
ApplySyncDiff
```

少なくとも、

```text
ApplySyncDiff
```

へ到達してはならない。

MTS-SYNC-010でもInvalid Candidate存在時にVariableDefinitionを更新しないことが要求されている。

---

# 21. Invalid Candidate Failure Result

InvalidCandidatesはScannerが正常に検出したBusiness / Validation Resultであり、

```text
Unhandled VBA Error
```

として扱わない。

P2-04では既存 `COperationResult / CErrorInfo` Patternを利用してFailureを返す。

固定するSemantic：

```text
Success:
False

Target:
Template Scan / Invalid Candidateを識別可能

syncDiffResult:
Nothing
```

以下は固定しない。

```text
Final Error Code
Final ErrorType体系
Final User-facing Message
Dialog表示方式
```

これらはP2-05 / P6で最終化する。

新しいError TypeをP2-04だけのために追加しない。

---

# 22. Current VariableDefinition Retrieval

InvalidCandidates = 0 の後、

```vb
GetAllVariableDefinitions( _
    currentDefinitions _
)
```

を呼ぶ。

使用するのはActiveのみではなく、

```text
Active
+
Unused
```

を含む全件。

P2-02のProduction ContractがこのCarrierを直接受け取れることは成立済みである。

---

# 23. Sync Processing Start

以下がすべて成功した時点を、

```text
Sync Processing Start
```

と解釈する。

```text
Current Template Scan = Success
InvalidCandidates = 0
Current VariableDefinitions Retrieval = Success
```

この位置はCross-document Check `CR-P2-04-001` によるImplementation Interpretationである。

利用者がSync Commandを押した時刻そのものではない。

---

# 24. SyncTimestamp Acquisition

## 24.1 Ownership

取得責務：

```text
modSyncApplication
```

P2-02 / P2-03では取得しない。

---

## 24.2 Timing

取得位置：

```text
GetAllVariableDefinitions SUCCESS
↓
SyncTimestamp = Now
↓
BuildSyncDiff
```

概念：

```vb
syncTimestamp = Now
```

取得回数：

```text
1 Manual Sync
=
1 SyncTimestamp
```

---

## 24.3 Shared Timestamp

同じ`syncTimestamp`を、

```text
BuildSyncDiff
```

へ1回だけ渡す。

P2-04がNew / Existing / ReactivatedごとにTimestampを取得し直してはならない。

Designは同一Syncで1つのTimestampを共用する。

MTS-SYNC-011でも同一Sync内Timestamp共通がExpectedである。

---

# 25. BuildSyncDiff Invocation

Call：

```vb
Set result = BuildSyncDiff( _
    templateScanResult, _
    currentDefinitions, _
    syncTimestamp, _
    candidateSyncDiffResult _
)
```

概念上のLocal Carrier：

```text
candidateSyncDiffResult
```

とする。

この時点ではCallerへ返す、

```text
syncDiffResult
```

へ確定しない。

---

# 26. BuildSyncDiff Failure

`BuildSyncDiff`がFailureの場合：

```text
ApplySyncDiff:
NOT CALLED

Public syncDiffResult:
Nothing

Return:
BuildSyncDiff Failure
```

P2-04で、

```text
Classification修正
Diff補正
Metadata補完
```

を試みない。

---

# 27. ApplySyncDiff Invocation

`BuildSyncDiff`成功後、

```vb
ApplySyncDiff(candidateSyncDiffResult)
```

を呼ぶ。

Carrier変換：

```text
NONE
```

Adapter：

```text
NONE
```

Rebuild：

```text
NONE
```

P2-02 OutputをP2-03へ直接渡す。

---

# 28. ApplySyncDiff Failure

`ApplySyncDiff`がFailureの場合：

```text
Public syncDiffResult:
Nothing

Return:
ApplySyncDiff Failure

Automatic Retry:
NONE
```

P2-03のRuntime FailureではPartial Writeの可能性があるため、

```text
Manual Sync Success
```

として返してはならない。

P2-04ではRollbackしない。

---

# 29. Success Commit Boundary

以下がすべてSuccessの場合のみ：

```text
Current Template Scan
Invalid Guard
Current Definition Retrieval
BuildSyncDiff
ApplySyncDiff
```

Manual Sync Application Successとする。

その時点で初めて、

```vb
Set syncDiffResult = candidateSyncDiffResult
```

相当を実行する。

概念：

```text
candidateSyncDiffResult
↓
ApplySyncDiff SUCCESS
↓
Public syncDiffResult
```

---

# 30. Production Sequence

最終Candidate Sequence：

```text
ExecuteManualSync
│
├─ syncDiffResult = Nothing
│
▼
ScanCurrentTemplate
│
├─ Settings.TemplatePath
├─ ResolveWorkbookRelativePath
├─ OFT Guard
├─ CreateMailFromTemplate
├─ ReadSubject
├─ ReadBodyText
├─ ScanTemplate
└─ CloseWithoutSave
│
├─ Failure
│    └─ Return Failure
│
▼
TemplateScanResult
│
├─ InvalidCandidates > 0
│    └─ Return Failure
│
▼
GetAllVariableDefinitions
│
├─ Failure
│    └─ Return Failure
│
▼
Sync Processing Start
│
▼
syncTimestamp = Now
│
▼
BuildSyncDiff
│
├─ Failure
│    └─ Return Failure
│
▼
candidateSyncDiffResult
│
▼
ApplySyncDiff
│
├─ Failure
│    └─ Return Failure
│
▼
syncDiffResult = candidateSyncDiffResult
│
▼
Return Success
```

---

# 31. COperationResult Propagation Rule

既存ComponentがFailureを返した場合、原則として、

```text
Original COperationResult
```

をCaller方向へ返す。

P2-04は不要に、

```text
ErrorType変換
Message書換え
Target書換え
```

を行わない。

Application Contextがどうしても必要な場合でも、

```text
Original Error Meaningを失わない
```

ことを必須とする。

Final Technical Error → User Message変換はP6責務。

---

# 32. Unexpected Error Boundary

`modSyncApplication` 自身で発生した予期しないVBA Runtime Errorは、

```text
既存COperationResult / CErrorInfo Pattern
```

へ変換する。

未処理Runtime Errorとして終了してはならない。

ただし、

```text
Final Error Code
Final User Message
```

はP2-04で新設しない。

---

# 33. Retry Rule

P2-04はAutomatic Retryしない。

Failure後にユーザーがManual Syncを再度実行した場合：

```text
ExecuteManualSync
↓
Current Template再取得
↓
ScanTemplate再実行
↓
Current Definitions再取得
↓
New SyncTimestamp
↓
BuildSyncDiff再実行
↓
New SyncDiffResult
↓
ApplySyncDiff
```

とする。

禁止：

```text
前回TemplateScanResult再利用
前回CurrentDefinitions再利用
前回SyncTimestamp再利用
前回SyncDiffResult再適用
```

P2-03で確定したFresh-State Retry Constraintを維持する。

---

# 34. State Management

`modSyncApplication` はSync間Stateを保持しない。

Module-levelで保持しないもの：

```text
LastTemplateScanResult
LastDefinitions
LastSyncTimestamp
LastSyncDiffResult
RetryCount
LastSyncSuccess
```

必要な情報は、

```text
ExecuteManualSync
```

のLocal Variableのみで保持する。

---

# 35. P2-05 Result Handoff

P2-04 Success時の、

```text
syncDiffResult
```

をP2-05が利用可能とする。

P2-05では少なくとも、

```text
New
Existing
Unused
```

を利用者通知へ接続する必要がある。

FR-SYNC-007ではこれらの分類によるSync結果通知を要求している。

P2-04では、

```text
User-facing Message
```

へ変換しない。

---

# 36. Reactivated Result

P2-02 Outputには、

```text
Reactivated
```

が存在する。

P2-04はこれを削除・Existingへ統合しない。

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

をそのままP2-05へ渡す。

P2-05側でReactivatedをUser-facing Result上どう表示するかはP2-04で決定しない。

---

# 37. Technical Guard / Final Fail Closed Separation

Cross-document Check `CR-P2-04-002` を以下で具体化する。

## P2-04

```text
Technical Execution Guard

OFT Failure
Invalid Candidate
Component Failure
    ↓
Downstream Stop
    ↓
Mutation Prevention
    ↓
Failure Propagation
```

## P2-05

```text
Final Phase Integration

P2-04 Result
    ↓
Final Sync Result
User Notification
Phase-level Fail Closed
```

P2-05がP2-04と同じScanner / Guard Logicを複製することを前提としない。

---

# 38. Manual Sync UI Boundary

P2-04 Production Public APIは、

```text
UIから呼び出し可能
```

なApplication Entryを提供する。

しかし以下はP2-04で固定しない。

```text
Worksheet Button
Ribbon
Menu
UserForm Button
Shortcut
```

UI Event ProcedureにSync Logicを直接書かない。

将来UIからは、

```text
UI
↓
ExecuteManualSync
```

と接続する。

---

# 39. No Automatic Sync Rule

以下から `ExecuteManualSync` を自動呼出ししない。

```text
Workbook_Open
Worksheet_Change
UserForm_Initialize
UserForm_Show
Timer
Outlook Event
```

FR-SYNC-001およびMTS-SYNC-001を維持する。

---

# 40. Dependency Direction

P2-04 Production Dependency：

```text
modSyncApplication
│
├─ modSettingsData
├─ modOutlookAdapter
├─ modTemplateScanner
├─ modVariableDefinitionData
└─ modSyncEngine
```

逆方向Dependencyは禁止する。

例：

```text
modSyncEngine
→ modSyncApplication
```

は禁止。

Core LogicはApplication Layerを知らない。

---

# 41. Production Change Candidate

想定Production Change：

```text
MODIFY / IMPLEMENT:
modSyncApplication
```

原則として以下は変更しない。

```text
modTemplateScanner
modSyncEngine
modVariableDefinitionData
modSettingsData
modOutlookAdapter
modResult

COperationResult
CErrorInfo
```

既存Module変更が必要と判明した場合は、

```text
P2-04 Integration Finding
```

として影響評価する。

勝手にPublic Contractを変更しない。

---

# 42. Candidate Procedure Structure

Current Source Review後のCandidate構成：

```text
modSyncApplication

Public:
ExecuteManualSync

Private:
ScanCurrentTemplate
必要最小限のOFT Guard
必要最小限のResult生成Helper
```

Private Helperを細分化しすぎない。

以下のような過剰分割は行わない。

```text
SyncCoordinator
SyncContext
TimestampProvider
TemplateGateway
DefinitionRepositoryAdapter
PersistenceService
```

---

# 43. ExecuteManualSync Pseudocode

```vb
Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object _
) As COperationResult

    Set syncDiffResult = Nothing

    ' 1. Current Template Scan
    ' result = ScanCurrentTemplate(templateScanResult)
    ' Failure -> Return

    ' 2. InvalidCandidates Guard
    ' Invalid -> Failure / Return

    ' 3. Current VariableDefinitions
    ' result = GetAllVariableDefinitions(currentDefinitions)
    ' Failure -> Return

    ' 4. Sync Processing Start
    ' syncTimestamp = Now

    ' 5. Diff
    ' result = BuildSyncDiff( _
    '     templateScanResult, _
    '     currentDefinitions, _
    '     syncTimestamp, _
    '     candidateSyncDiffResult)
    ' Failure -> Return

    ' 6. Persistence
    ' result = ApplySyncDiff(candidateSyncDiffResult)
    ' Failure -> Return

    ' 7. Success Output
    ' Set syncDiffResult = candidateSyncDiffResult
    ' Return Success

End Function
```

これはProcedure Structureの仕様であり、最終VBA Sourceそのものではない。

---

# 44. ScanCurrentTemplate Pseudocode

```vb
Private Function ScanCurrentTemplate( _
    ByRef templateScanResult As Object _
) As COperationResult

    Set templateScanResult = Nothing

    ' TemplatePath取得
    ' ResolveWorkbookRelativePath
    ' OFT existence guard
    ' CreateMailFromTemplate
    '
    ' MailItem生成後:
    '   ReadSubject
    '   ReadBodyText
    '   ScanTemplate
    '
    ' Success / Failureいずれでも
    '   CloseWithoutSaveを試行
    '
    ' Success時のみ
    '   templateScanResultを返す

End Function
```

Outlook / Word COM ObjectをHelper内で直接操作しない。

MailItemは既存Outlook Adapter APIへ渡すだけとする。

---

# 45. Verification Strategy

P2-04では、

```text
Implementation Verification
```

を行う。

Formal MVP Testではない。

Implementation PlanはLocal / Phase VerificationとFormal MVP Testを分離している。

---

# 46. Core / Integration Verification

最低限以下を確認する。

## I01 Happy Path

```text
Valid OFT
Valid VariableDefinition
↓
ExecuteManualSync
↓
Success
↓
VariableDefinition更新
↓
syncDiffResult取得
```

Expected：

```text
Success = True
syncDiffResult Is Nothing = False
```

---

## I02 Common SyncTimestamp

New / Existing / Reactivatedを同一Syncで発生させる。

Expected：

```text
New.FirstDetectedAt / LastDetectedAt
Existing.LastDetectedAt
Reactivated.LastDetectedAt

→ 同一SyncTimestamp
```

---

## I03 Invalid Candidate

OFTにInvalid Variableを含める。

Expected：

```text
ExecuteManualSync = Failure
VariableDefinition = No Update
syncDiffResult = Nothing
```

---

## I04 OFT Missing

OFTを不存在状態とする。

Expected：

```text
ExecuteManualSync = Failure
Template Scan = Not Completed
VariableDefinition = No Update
syncDiffResult = Nothing
```

---

## I05 Current Definition Read Failure

VariableDefinition Data Accessが成立しない代表状態を作る。

Expected：

```text
BuildSyncDiffへ進まない
ApplySyncDiffへ進まない
syncDiffResult = Nothing
```

Production Test Hookは追加しない。

---

## I06 BuildSyncDiff Failure

Current Definition重複等、既存P2-02 GuardでFailureとなる再現可能状態を使用する。

Expected：

```text
BuildSyncDiff = Failure
ApplySyncDiff = Not Executed
syncDiffResult = Nothing
```

---

## I07 ApplySyncDiff Failure

再現可能なPersistence Failure Scenarioで確認する。

Expected：

```text
ApplySyncDiff = Failure
ExecuteManualSync = Failure
syncDiffResult = Nothing
Automatic Retry = NONE
```

Fault InjectionがProduction Test Hookを必要とする場合は採用しない。

Static Review / existing P2-03 negative evidenceで補完可能とする。

---

## I08 Retry Fresh State

1回目を意図的Failureとし、原因修正後に再実行する。

Expected：

```text
Template再取得
Definition再取得
New SyncTimestamp
New SyncDiffResult
```

stale Diffの再適用なし。

---

## I09 Warm Start Lifecycle

Classic Outlook起動済み。

Expected：

```text
Existing Explorer reuse
Scan MailItem Display = NONE
Draft Residue = NONE
Inspector Residue = NONE
```

---

## I10 Cold Start Lifecycle

Classic Outlook未起動。

Expected：

```text
Visible Explorer Initialization
ReadBodyText PASS
Scan MailItem Display = NONE
Draft Residue = NONE
Inspector Residue = NONE
```

P1-07ではWarm / Cold両経路が成立済みであるため、そのProduction経路をRegression利用する。

---

## I11 Manual Only

Workbook Open / UserForm起動ではVariableDefinitionを変更しない。

Manual Entry実行時のみ同期する。

---

## I12 Contract Regression

確認：

```text
P2-01 ScanTemplate Contract
PASS

P2-02 BuildSyncDiff Contract
PASS

P2-03 ApplySyncDiff Contract
PASS

P0 GetAllVariableDefinitions
PASS
```

---

# 47. Static Review Checklist

Production `modSyncApplication` について最低限以下を確認する。

```text
S01 Public Manual Sync Entry = 1
S02 Automatic Sync Event = NONE
S03 Now / Time取得 = 1 Syncにつき1回
S04 ScanTemplate Call = PRESENT
S05 GetAllVariableDefinitions Call = PRESENT
S06 BuildSyncDiff Call = PRESENT
S07 ApplySyncDiff Call = PRESENT
S08 Classification Recalculation = NONE
S09 Canonical Name Calculation = NONE
S10 Metadata Calculation = NONE
S11 Persistence Direct Excel Access = NONE
S12 Outlook / Word Direct COM Access = NONE
S13 Invalid Candidate downstream stop = PRESENT
S14 Build Failure -> Applyなし
S15 Apply Failure -> Successなし
S16 Failure Output syncDiffResult = Nothing
S17 Success Output after Apply success only
S18 Automatic Retry = NONE
S19 Module-level Sync State = NONE
S20 New Result Class / Interface = NONE
S21 User-facing MsgBox / Form = NONE
S22 Formal Test Claim = NONE
```

---

# 48. Regression Boundary

P2-04によって以下を変更してはならない。

```text
P1 Warm / Cold Outlook Lifecycle
P2-01 Scanner Result
P2-02 Classification
P2-02 Metadata Meaning
P2-03 Persistence Rules
P0 VariableDefinition Read
```

既存Contract Signature変更：

```text
NOT ALLOWED
```

変更が必要になった場合：

```text
Finding
↓
Impact Assessment
↓
Reopen要否判定
```

を行う。

---

# 49. Formal Test Boundary

今回のVerificationは、

```text
Implementation Verification
```

である。

以下をClaimしない。

```text
MTS-SYNC-001 Formal PASS
MTS-SYNC-009 Formal PASS
MTS-SYNC-010 Formal PASS
MTS-SYNC-011 Formal PASS
Formal MTS-SYNC PASS
MVP Product PASS
```

Formal MVP TestはP7後のTest Candidate Buildに対して実施する。

---

# 50. Traceability

```text
FR-SYNC-001
↓
ExecuteManualSync
↓
MTS-SYNC-001

FR-SYNC-008
↓
OFT Guard
InvalidCandidates Guard
↓
MTS-SYNC-009 / 010

Design §7.4
↓
modSyncApplication SyncTimestamp Acquisition
↓
BuildSyncDiff
↓
MTS-SYNC-011

FR-SYNC-002～006
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
MTS-SYNC-002～007

FR-SYNC-007
↓
P2-04 syncDiffResult Handoff
↓
P2-05 User Notification
↓
MTS-SYNC-008
```

---

# 51. Completion Criteria

P2-04 Completionには以下を必要とする。

```text
Boundary Confirmation
PASS

Cross-document Consistency Check
PASS

P2-04 Implementation Specification
APPROVED

Current Production Source Review
COMPLETE

Production Patch Design
APPROVED

VBA Compile
PASS

Production Implementation
PASS

Integration Verification I01-I12
Applicable Cases PASS

Static Review S01-S22
PASS

P2-01 Regression
PASS

P2-02 Regression
PASS

P2-03 Regression
PASS

Production Patch Review
PASS

Final Finding Assessment
PASS

Blocking Finding
0
```

---

# 52. Unit Completion Boundary

P2-04 Completionは、

```text
Manual Sync Integration
```

のCompletionである。

以下を意味しない。

```text
P2 Phase COMPLETE
CP-P2 ESTABLISHED
Final Sync Result Complete
Final Fail Closed Complete
Formal MVP Test PASS
MVP Product PASS
```

---

# 53. P2-05 Handoff

P2-04完了後：

```text
Manual Sync Application Entry
+
Current Template Scan
+
Invalid Execution Guard
+
Current Definition Retrieval
+
Single SyncTimestamp
+
BuildSyncDiff
+
ApplySyncDiff
+
Success SyncDiffResult Handoff
+
Failure Propagation
```

が成立していることをP2-05のInputとする。

P2-05では主として、

```text
Sync Result Data / Presentation
User Notification
Manual Sync UI Connection
OFT / Invalid Final Fail Closed Integration
Phase-level Error Boundary
P2 Phase Integration
```

を完成させる。

---

# 54. Candidate Finding Status

本Candidate作成時点：

```text
Requirement Gap:
NONE

Design Conflict:
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

Known Blocking Finding:
0
```

ただし、

```text
Current modSyncApplication Production Source
```

のSource ReviewはProduction Patch設計前に必要。

これはRequirement / Design Gapではなく、

```text
Implementation Source Review Gate
```

として扱う。

---

# 55. Baseline Impact

```text
BL-MVP-003:
MAINTAIN

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
```

---

# 56. Approval前Review Points

本CandidateのConsistency Reviewでは特に以下を確認する。

```text
1. ExecuteManualSync APIがP2-05 Result Handoffに十分か

2. Failure時 syncDiffResult = Nothing が
   Result Contractと矛盾しないか

3. ScanCurrentTemplate内のMailItem Lifecycleが
   Design §12 / §25.1、P1 Productionと一致するか

4. SyncTimestamp = BuildSyncDiff直前が
   CR-P2-04-001と一致するか

5. InvalidCandidates Guardが
   CR-P2-04-002と一致し、
   P2-05責務を奪っていないか

6. Existing Production Public Contract変更がないか

7. P2-04がUser-facing Result / Errorを
   先回り実装していないか

8. RetryがFresh Stateから再構築されるか
```

---

# 57. Next Action

本Candidateの次の正式作業：

```text
P2-04 Manual Sync Integration
実施仕様 v0.1
Cross-document Consistency Review
```

Review PASS後：

```text
Candidate
↓
Consistency Review
↓
Corrections if required
↓
Approved Specification
↓
Current modSyncApplication Source Review
↓
Production Patch Design
↓
Production Implementation
↓
Compile
↓
Implementation Verification
↓
Regression
↓
Production Patch Review
↓
Final Finding Assessment
↓
Completion Record
```

---

# 58. まとめ / Summary

## 日本語

P2-04 Manual Sync Integrationでは、`modSyncApplication` にManual SyncのApplication Orchestrationを実装する。

Primary Candidate Public APIは、

```vb
ExecuteManualSync(ByRef syncDiffResult As Object) As COperationResult
```

とする。

Manual SyncではCurrent Templateを毎回取得・Scanし、InvalidCandidatesが存在しないことを確認後、Current VariableDefinitionsを取得する。その後を `Sync Processing Start` とし、1つの `SyncTimestamp` を取得して `BuildSyncDiff` へ渡す。

`BuildSyncDiff`成功後のみ `ApplySyncDiff` を呼び、`ApplySyncDiff`成功後のみP2-02の `SyncDiffResult` をCallerへ返す。

Failure時には `syncDiffResult = Nothing` とし、未PersistenceまたはPersistence Failure状態のDiffを成功したSync Resultとして公開しない。

Scan用MailItemは既存Outlook Adapter Contractを使用し、Display / Saveせず、正常・異常を問わず可能な限り `CloseWithoutSave` する。

P2-04ではClassification、Metadata、Persistence、User-facing Sync Result、User Notification、Final Fail Closed、Automatic Retryを実装しない。

Requirement / Design / Baseline変更は行わない。

次の作業は本Candidateに対するCross-document Consistency Reviewとする。

## English

P2-04 Manual Sync Integration implements the Manual Sync application orchestration in `modSyncApplication`.

The primary candidate public API is:

```vb
ExecuteManualSync(ByRef syncDiffResult As Object) As COperationResult
```

Each Manual Sync reads and scans the current template, checks that there are no invalid candidates, and then reads the current VariableDefinitions. After these pre-sync checks succeed, the sync processing starts and one `SyncTimestamp` is created and passed to `BuildSyncDiff`.

`ApplySyncDiff` is called only after `BuildSyncDiff` succeeds. The `SyncDiffResult` is returned to the caller only after persistence succeeds.

On failure, `syncDiffResult` is `Nothing`, so an uncommitted or failed diff cannot be treated as a successful sync result.

The scan MailItem uses the existing Outlook Adapter contract and is not displayed or saved. It is closed without saving whenever possible.

P2-04 does not implement classification, metadata calculation, persistence semantics, final user-facing sync results, user notification, final Fail Closed integration, or automatic retry.

No requirement, design, or baseline change is introduced.

The next task is the Cross-document Consistency Review of this Candidate.
