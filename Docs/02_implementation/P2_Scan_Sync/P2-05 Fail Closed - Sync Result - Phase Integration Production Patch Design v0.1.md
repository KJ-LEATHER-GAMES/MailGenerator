# P2-05 Fail Closed / Sync Result / Phase Integration
# Production Patch Design v0.1

## 1. Document Information

| 項目 | 内容 |
|---|---|
| Document | P2-05 Production Patch Design |
| Version | v0.1 |
| Status | **APPROVED FOR IMPLEMENTATION** |
| Execution Baseline | `BL-MVP-003` |
| Approved Specification | P2-05 Implementation Specification v0.1 — Approved |
| Current Source Review | **PASS / CLOSED** |
| Formal Patch Scope | **CONFIRMED** |
| Blocking Finding | **0** |
| Code Change Performed Here | **NONE** |

---

## 2. Purpose

本Designは、P2-05 Approved SpecificationとCurrent Production Source ReviewをProduction Patchへ変換する。

本書では、

```text
Production Module
Public Entry
Private Responsibilities
Concrete Carrier Access
Success / Failure Flow
Basic User Notification
Fail Closed
Error Aggregation
Dependency
Patch Scope
Verification Hook
```

を固定する。

本書作成時点ではProduction Codeを変更しない。

---

# 3. Formal Patch Scope

## ADD / IMPLEMENT

```text
modUiController
```

---

## MODIFY

```text
NONE
```

---

## REUSE UNCHANGED

```text
modSyncApplication
modSyncEngine
modVariableDefinitionData
modTemplateScanner
modSettingsData
modOutlookAdapter
modResult

COperationResult
CErrorInfo
```

---

## DELETE

```text
NONE
```

---

# 4. Module Responsibility

`modUiController`のP2-05責務：

```text
Manual Sync User Entry
ExecuteManualSync Invocation
Result Contract Defensive Check
Success / Failure Branch
Basic Sync Result Message Assembly
Invalid Candidate Message Assembly
Existing Operation Error Aggregation
Generic Failure Fallback
Single Modal Notification
```

非責務：

```text
Template Scan
Variable Syntax Validation
Sync Classification
Canonical Name Calculation
Metadata Calculation
Persistence
Current Definition Read
Outlook Lifecycle
Automatic Retry
Final Error Taxonomy
Final Error Mapping
Unused Confirmation UI
Mail Generation
```

---

# 5. Public API

Production UI Entry：

```vb
Public Sub RunManualSync()
```

Argument：

```text
NONE
```

Return Value：

```text
NONE
```

呼出元：

```text
User explicit action
```

このProcedureがP2-05のCanonical Manual Sync Macroとなる。

---

# 6. Private Structure

Candidate Production Structure：

```text
modUiController

Public
└─ RunManualSync

Private
├─ BuildSyncSuccessMessage
├─ AppendSyncCategory
├─ BuildInvalidCandidateMessage
├─ BuildOperationFailureMessage
└─ ShowManualSyncNotification
```

必要に応じて、過剰分割を避けるためPrivate Helperを統合してよい。

新Class：

```text
NONE
```

---

# 7. Private Constants

最小Private Constant候補：

```vb
Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private Const KEY_VARIABLE_NAME As String = "VariableName"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Private Const LABEL_NEW As String = "新規"
Private Const LABEL_EXISTING As String = "継続"
Private Const LABEL_REACTIVATED As String = "復活"
Private Const LABEL_UNUSED As String = "Unused化"
```

新しいShared Constants Moduleは追加しない。

理由：

```text
P2-05 Presentation Consumerに必要な最小Contract Keyのみ
+
YAGNI
```

---

# 8. RunManualSync Flow

```text
RunManualSync
↓
Local output初期化
syncDiffResult = Nothing
templateScanResult = Nothing
↓
ExecuteManualSync(
    syncDiffResult,
    templateScanResult
)
↓
operationResult取得
↓
operationResult Is Nothing?
├─ Yes
│   ↓
│  Generic Failure
│   ↓
│  1回通知
│   ↓
│  End
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
│  │  Generic Failure
│  │   ↓
│  │  Success Notification禁止
│  │   ↓
│  │  End
│  │
│  └─ No
│      ↓
│  BuildSyncSuccessMessage
│      ↓
│  Success Message
│      ↓
│  1回通知
│      ↓
│  End
│
└─ False
    ↓
    Success Notification禁止
    ↓
InvalidCandidatesあり？
├─ Yes
│   ↓
│  BuildInvalidCandidateMessage
│   ↓
│  1回通知
│   ↓
│  End
│
└─ No
    ↓
Errorsあり？
├─ Yes
│   ↓
│  BuildOperationFailureMessage
│   ↓
│  1回通知
│   ↓
│  End
│
└─ No
    ↓
Generic Failure
    ↓
1回通知
    ↓
End
```

---

# 9. Local State

`RunManualSync` Local Variable候補：

```vb
Dim operationResult As COperationResult
Dim syncDiffResult As Object
Dim templateScanResult As Object
Dim messageText As String
```

必要に応じて、

```vb
Dim invalidCandidates As Collection
```

等をLocalで使用する。

Module-level State：

```text
NONE
```

---

# 10. Application Invocation

唯一のManual Sync Application Entry：

```vb
Set operationResult = ExecuteManualSync( _
    syncDiffResult, _
    templateScanResult)
```

UIから以下を直接呼ばない。

```text
ScanTemplate
GetAllVariableDefinitions
BuildSyncDiff
ApplySyncDiff
ResolveWorkbookRelativePath
CreateMailFromTemplate
ReadSubject
ReadBodyText
```

---

# 11. Success Source of Truth

Success判定：

```text
operationResult.Success = True
```

これ以外をSuccess判定Sourceとしない。

ただしDefensive Contract Guardとして、

```text
syncDiffResult Is Nothing
templateScanResult Is Nothing
```

を検査する。

いずれかがNothingなら：

```text
Success Presentation禁止
Generic Failure
```

---

# 12. SyncDiffResult Access

Concrete Carrier：

```text
Dictionary-compatible Object
```

必須Keys：

```text
New
Existing
Reactivated
Unused
```

各Value：

```text
Collection
```

UIでは各Collectionを、

```vb
For Each item In items
```

で列挙する。

新Sort：

```text
NONE
```

---

# 13. Diff Item Access

各Item：

```text
Dictionary-compatible Object
```

Presentation Field：

```text
VariableName
```

概念：

```vb
variableName = CStr(item("VariableName"))
```

P2-05 UIで、

```text
Status
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

は表示必須としない。

---

# 14. Success Category Mapping

```text
New
→ 新規

Existing
→ 継続

Reactivated
→ 復活

Unused
→ Unused化
```

表示順：

```text
1. 新規
2. 継続
3. 復活
4. Unused化
```

変更不可。

---

# 15. BuildSyncSuccessMessage

Conceptual Output：

```text
テンプレート同期結果

新規 (n件)
<VariableName ... / なし>

継続 (n件)
<VariableName ... / なし>

復活 (n件)
<VariableName ... / なし>

Unused化 (n件)
<VariableName ... / なし>
```

全Category 0件でも4Sectionを表示する。

第5Category：

```text
追加しない
```

---

# 16. AppendSyncCategory

Logical Responsibility：

```text
Required Classification存在確認
↓
Collection取得
↓
Count取得
↓
Label + Count追加
↓
0件
├─ Yes → "なし"
└─ No  → VariableName列挙
```

このHelperはClassificationを再判定しない。

---

# 17. Success Carrier Structural Failure

以下の場合：

```text
Required keyなし
Collection取得不能
Collection = Nothing
Item = Nothing
VariableName Keyなし
VariableName取得不能
```

UI Presentation Contract Failureとして、

```text
Success Notification禁止
Generic Failure Notification
```

へ倒す。

UI側でDataを修復しない。

---

# 18. Invalid Candidate Access

Concrete Carrier：

```text
templateScanResult
= Dictionary-compatible Object

templateScanResult("InvalidCandidates")
= Collection
```

Failure時に以下が成立すればInvalid Candidate Presentationを優先する。

```text
templateScanResult Is Nothing = False
+
templateScanResult.Exists("InvalidCandidates")
+
InvalidCandidates Collection Is Nothing = False
+
Count > 0
```

---

# 19. BuildInvalidCandidateMessage

Conceptual Message：

```text
テンプレート内に命名規則違反の変数記法があります。
同期は実行されませんでした。

対象
<Invalid Candidate 1>
<Invalid Candidate 2>
...
```

Candidate文字列はScanner Resultをそのまま識別可能に表示する。

禁止：

```text
Regex再判定
自動補正
Normalize
VariableDefinition更新
```

---

# 20. COperationResult Error Access

Concrete：

```text
operationResult.Errors
= Collection snapshot
```

各Element：

```text
CErrorInfo
```

Read Fields：

```text
ErrorType
Message
Target
```

P2-05 Basic Failureでは原則、

```text
Message
Target
```

を表示する。

`ErrorType`から独自最終文言を生成しない。

---

# 21. BuildOperationFailureMessage

Conceptual：

```text
テンプレート同期に失敗しました。

<Error Message>

確認対象:
<Target>
```

複数Error：

```text
1つのModal Messageへ集約
```

例：

```text
テンプレート同期に失敗しました。

[1]
<Message 1>
確認対象: <Target 1>

[2]
<Message 2>
確認対象: <Target 2>
```

最終Severity / Error Code / Recovery Guidance：

```text
P6
```

---

# 22. Generic Failure

Displayable Result Detailを得られない場合：

```text
テンプレート同期に失敗しました。
同期結果を確定できませんでした。
```

相当を表示する。

Final wordingはP6で再評価可能。

---

# 23. UI Runtime Failure Boundary

`RunManualSync`は、

```vb
On Error GoTo UnexpectedError
```

相当でUI内部の予期しないRuntime Errorを捕捉する。

Unexpected UI Failure：

```text
Success Notification禁止
Generic Failure Notification
```

新しいCOperationResult生成は必須としない。

P2-05 UI自身のError Taxonomyを新設しない。

---

# 24. Notification Mechanism

P2 Basic UI：

```text
Single Modal Notification
```

Production候補：

```vb
MsgBox
```

1 Manual Sync Execution：

```text
Success → 1回
Failure → 1回
```

二重通知：

```text
禁止
```

P6 Final Error Icon / Severityを先取りしないため、P2-05では特別なSeverity IconをContract化しない。

---

# 25. ShowManualSyncNotification

Logical Responsibility：

```text
1つのMessage String
↓
Modal Display 1回
```

Business判断：

```text
NONE
```

Classification判断：

```text
NONE
```

Persistence：

```text
NONE
```

---

# 26. Retry Boundary

Failure後：

```text
Automatic Retry:
NONE
```

Userが再実行した場合：

```text
RunManualSync
↓
ExecuteManualSync
↓
P2-04 Fresh State
```

Previous UI State保持：

```text
NONE
```

---

# 27. Manual-only Boundary

禁止：

```text
Workbook_Open → RunManualSync
Worksheet_Change → RunManualSync
Workbook_SheetChange → RunManualSync
Timer → RunManualSync
Application Event → RunManualSync
```

User explicit actionのみ。

---

# 28. Workbook / Button Integration

Canonical Macro：

```text
modUiController.RunManualSync
```

Current Workbook Evidence：

```text
NOT AVAILABLE IN SOURCE REVIEW SET
```

Integration Rule：

```text
既存Manual Sync Controlあり
→ RunManualSyncへ割当

既存Controlなし
→ Production Codeから新Buttonを自動生成しない
```

Button作成をP2-05 Code Patch Scopeへ含めない。

`OBS-P2-05-SR-001`をP2-05 Verification前まで追跡する。

---

# 29. Source File Candidate

Production Artifact Candidate：

```text
modUiController_P2-05_v0.1_CP932.bas
```

Encoding：

```text
CP932
```

Line Ending：

```text
CRLF
```

既存WorkbookにShell Moduleがある場合は、同名Moduleの重複Importを避ける。

---

# 30. No Changes to Existing Production

以下へCode Changeを入れない。

```text
modSyncApplication
modSyncEngine
modVariableDefinitionData
modTemplateScanner
modSettingsData
modOutlookAdapter
modResult
COperationResult
CErrorInfo
```

Source Review後に変更必要性が発見された場合は、

```text
P2-05 Integration Finding
```

として正式に影響評価する。

勝手にScopeを拡張しない。

---

# 31. Public Contract Matrix

| Component | Current | P2-05 Patch |
|---|---|---|
| `ExecuteManualSync` | Existing | **UNCHANGED** |
| `BuildSyncDiff` | Existing | **UNCHANGED** |
| `ApplySyncDiff` | Existing | **UNCHANGED** |
| `ScanTemplate` | Existing | **UNCHANGED** |
| `COperationResult` | Existing | **UNCHANGED** |
| `CErrorInfo` | Existing | **UNCHANGED** |
| `RunManualSync` | Not established | **ADD in UI Layer** |

---

# 32. Dependency Matrix

Allowed：

```text
modUiController
→ modSyncApplication
→ Existing P2 Components
```

Not Allowed：

```text
modUiController
→ modSyncEngine direct

modUiController
→ modVariableDefinitionData direct

modUiController
→ modTemplateScanner direct

modUiController
→ modOutlookAdapter direct

modSyncApplication
→ modUiController
```

---

# 33. Static Review Controls for Patch

Production実装後、以下を確認する。

```text
PATCH-S01  ADD/IMPLEMENT = modUiControllerのみ
PATCH-S02  Existing Production変更なし
PATCH-S03  Public RunManualSyncのみ必要最小限
PATCH-S04  ExecuteManualSync Signature変更なし
PATCH-S05  UI→ExecuteManualSyncのみ
PATCH-S06  UI→ScanTemplate direct callなし
PATCH-S07  UI→BuildSyncDiff direct callなし
PATCH-S08  UI→ApplySyncDiff direct callなし
PATCH-S09  UI→VariableDefinition direct writeなし
PATCH-S10  MsgBoxはUI Layerのみ
PATCH-S11  Automatic Retryなし
PATCH-S12  Automatic Sync Eventなし
PATCH-S13  Module-level Sync Stateなし
PATCH-S14  New再分類なし
PATCH-S15  Existing再分類なし
PATCH-S16  Reactivated再分類なし
PATCH-S17  Unused再分類なし
PATCH-S18  Reactivated → 復活
PATCH-S19  Failure時Success Notificationなし
PATCH-S20  InvalidCandidates再Scanなし
PATCH-S21  Result.Errors SnapshotをRead-only消費
PATCH-S22  新Result Classなし
PATCH-S23  新Error Code体系なし
PATCH-S24  P3 Unused Confirmation UIなし
PATCH-S25  P6 Final Error UI先取りなし
PATCH-S26  1 Execution = 1 Notification
PATCH-S27  Workbook control自動生成なし
PATCH-S28  OBS-P2-05-SR-001追跡
```

---

# 34. Verification Alignment

Approved P2-05 Verification：

```text
P05-I01～I17
P05-K01～K04
S01～S32
P2-01～P2-04 Regression
```

本Patch Designはそれらを実行可能なStructureを提供する。

Formal MTS PASS：

```text
NOT CLAIMED
```

---

# 35. Compile Gate

Production Implementation後：

```text
Debug
→ Compile VBAProject
```

Expected：

```text
PASS
```

Compile PASS前にRuntime Verificationへ進まない。

---

# 36. Finding Rule

実装時にCurrent Workbook / Source差異が見つかった場合：

```text
既存Design内の配置差
→ Implementation Detail

Approved Contract変更が必要
→ Contract Finding

Design責務変更が必要
→ Design Finding

利用者振る舞い変更が必要
→ Requirement Gap
```

暗黙修正しない。

---

# 37. Production Patch Decision

Formal Patch：

```text
ADD / IMPLEMENT:
modUiController

MODIFY:
NONE

DELETE:
NONE
```

Canonical Entry：

```vb
Public Sub RunManualSync()
```

Existing P2 Production Contract：

```text
UNCHANGED
```

New Result / Error Class：

```text
NONE
```

Automatic Retry：

```text
NONE
```

Workbook Control Generation：

```text
NONE
```

Status：

```text
APPROVED FOR IMPLEMENTATION
```

---

# 38. Next Gate

次の正式Gate：

```text
P2-05 Production Implementation
```

開始時に、

```text
modUiController_P2-05_v0.1_CP932.bas
```

をProduction Candidateとして作成し、

```text
VBA Compile
↓
P2-05 Verification
↓
Regression
↓
Static Review
```

へ進む。

ただしWorkbook integration時には、

```text
OBS-P2-05-SR-001
Current Button / Macro Wiring
```

を確認する。

---

# 39. まとめ / Summary

## 日本語

P2-05 Production Patch Designでは、Current Source Review結果に基づき、Production変更を`modUiController`の実装だけに限定した。

`RunManualSync()`をUser explicit Manual Sync Entryとして追加し、既存`modSyncApplication.ExecuteManualSync`を唯一のApplication Entryとして呼び出す。Success時はPersist済み`SyncDiffResult`のNew / Existing / Reactivated / Unusedを、新規 / 継続 / 復活 / Unused化として表示する。Invalid Candidate時は`TemplateScanResult("InvalidCandidates")`を再Scanせず表示する。その他Failureは既存`COperationResult.Errors`の`CErrorInfo.Message / Target`をBasic UIへ集約する。

既存`modSyncApplication`、Sync Engine、Persistence、Scanner、Data Access、Outlook Adapter、Result Classは変更しない。新しいResult Class、Error Code体系、Automatic Retry、Module-level Sync State、Workbook Control自動生成も追加しない。

Current WorkbookがSource Review Setに存在しないため、既存Button / Macro Wiringのみ`OBS-P2-05-SR-001`として非Blockingで継続管理する。

本Production Patch Designを **APPROVED FOR IMPLEMENTATION** とする。

## English

The P2-05 Production Patch Design limits the production change to implementing `modUiController`.

`RunManualSync()` becomes the explicit user entry and calls the existing `modSyncApplication.ExecuteManualSync` as the only application entry. On success, the persisted SyncDiffResult categories are presented as New, Continued, Reactivated, and Unused. Invalid candidates are presented directly from `TemplateScanResult("InvalidCandidates")` without rescanning. Other failures aggregate the existing `COperationResult.Errors` / `CErrorInfo.Message` and `Target` into the basic UI.

Existing application, sync engine, persistence, scanner, data access, Outlook adapter, and result classes remain unchanged. No new result class, error-code taxonomy, automatic retry, module-level sync state, or automatic workbook-control creation is introduced.

Because the current workbook is not available in the reviewed source set, existing button/macro wiring remains a controlled non-blocking observation (`OBS-P2-05-SR-001`).

This Production Patch Design is **APPROVED FOR IMPLEMENTATION**.
