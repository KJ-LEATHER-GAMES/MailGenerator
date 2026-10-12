# P2-03 VariableDefinition Sync Persistence

# Production Patch Design v0.1

## 1. Document Information

| 項目                         | 内容                                        |
| -------------------------- | ----------------------------------------- |
| 対象Unit                     | P2-03 VariableDefinition Sync Persistence |
| 対象Production Module        | `modVariableDefinitionData`               |
| Source Review              | COMPLETE                                  |
| Approved Specification     | P2-03 実施仕様 v0.1 — Approved                |
| Patch方針                    | **Existing Source Minimal Extension**     |
| Existing Public API Change | **NONE**                                  |
| New Public API             | `ApplySyncDiff()`                         |
| New Production Module      | **NONE**                                  |
| P2-02 Change               | **NONE**                                  |
| Blocking Source Finding    | **0**                                     |
| Implementation Readiness   | **READY**                                 |

---

# 2. Reviewed Current Production Source

現行Module：

```vb
Attribute VB_Name = "modVariableDefinitionData"
Option Explicit
```

現在のPublic API：

```vb
GetAllVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
```

```vb
GetActiveVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
```

現在のPrivate Structure：

```text
GetVariableDefinitionTable
ValidateRequiredColumns
ReadVariableDefinitions
ReadVariableDefinitionRow
ReadCellValue
BuildCellTarget
```

現在の責務：

```text
tblVariableDefinition
↓
Read
↓
Collection + Dictionary
```

P2-03ではこのRead経路を壊さず、

```text
SyncDiffResult
↓
ApplySyncDiff
↓
tblVariableDefinition Write
```

を追加する。

---

# 3. Source Review Result

現行SourceとApproved仕様を比較した結果：

```text
Existing Read Architecture:
COMPATIBLE

Existing Table Access:
REUSABLE

Existing Required Column Validation:
REUSABLE

Existing Result / Error Model:
REUSABLE

Existing Key Constants:
REUSABLE

Existing Cell Target Builder:
REUSABLE

Existing Row Read:
UNCHANGED

Existing Public Read APIs:
UNCHANGED

Persistence Capability:
MISSING → ADD

Blocking Refactor:
NONE
```

したがって、P2-03のために既存Read処理を再設計する必要はない。

---

# 4. Patch Strategy

Patchは以下の3種類だけとする。

```text
ADD CONSTANTS
+
ADD PUBLIC ApplySyncDiff
+
ADD PRIVATE Persistence Helpers
```

既存Function Bodyは原則変更しない。

---

# 5. Existing Source — KEEP

以下は変更しない。

```text
GetAllVariableDefinitions
GetActiveVariableDefinitions
GetVariableDefinitionTable
ValidateRequiredColumns
ReadVariableDefinitions
ReadVariableDefinitionRow
ReadCellValue
BuildCellTarget
```

理由：

- Table取得が既に成立
- Required 12列検証が既に成立
- Result / Error処理が成立
- Excel ListObject依存がData Access内部に閉じている
- P0/P2-02で利用済みRead Contractを維持できる

---

# 6. Existing Public Contract — DO NOT CHANGE

以下のSignatureおよびCarrierを変更しない。

```vb
Public Function GetAllVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
```

```vb
Public Function GetActiveVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
```

Carrier：

```text
Collection
└─ Dictionary
   ├─ VariableName
   ├─ DisplayName
   ├─ Type
   ├─ Required
   ├─ Description
   ├─ OptionSource
   ├─ SortOrder
   ├─ Format
   ├─ TemplateLocation
   ├─ Status
   ├─ FirstDetectedAt
   ├─ LastDetectedAt
   └─ __RowIndex
```

`__RowIndex`も既存Read Contractとして残す。

ただしP2-03ではPersistence Identityとして使用しない。

---

# 7. Constants — ADD

既存：

```vb
Private Const STATUS_ACTIVE As String = "Active"
```

へ以下を追加する。

```vb
Private Const STATUS_UNUSED As String = "Unused"

Private Const LOCATION_SUBJECT As String = "Subject"
Private Const LOCATION_BODY As String = "Body"
Private Const LOCATION_BOTH As String = "Both"

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private Const VARIABLE_NAME_PATTERN As String = _
    "^[A-Za-z][A-Za-z0-9_]*$"
```

既存 `KEY_*` はそのまま再利用する。

---

# 8. Public API — ADD

追加するPublic APIは1本のみ。

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

このAPIがP2-03 Production Boundaryとなる。

---

# 9. ApplySyncDiff Processing Flow

```text
ApplySyncDiff
    ↓
Validate SyncDiffResult Structure
    ↓
GetVariableDefinitionTable
    ↓
  Existing:
  Table existence check
  Required 12 columns check
    ↓
Build ExistingRowMap
    ↓
Validate All Diff Items
    ↓
Validate Current Table State
    ↓
===========================
        WRITE BOUNDARY
===========================
    ↓
Existing Write
    ↓
Reactivated Write
    ↓
Unused Write
    ↓
New Append
    ↓
Success
```

全Preflightが成功するまでWriteを開始しない。

---

# 10. Existing Function Reuse

## 10.1 GetVariableDefinitionTable

そのまま利用する。

既に以下を実施している。

```text
VariableDefinition Sheet存在確認
tblVariableDefinition存在確認
Required Column確認
```

したがってApproved仕様Candidateで想定していた、

```text
ResolveVariableDefinitionColumns
```

の新設は不要。

---

## 10.2 ValidateRequiredColumns

そのまま利用する。

現在すでに全12列を検証している。

```text
VariableName
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

P2-03用に別Column Validatorを作らない。

---

## 10.3 ReadCellValue

Existing Row Map作成およびCanonical Name確認にも再利用可能。

既存の、

```text
Excel Error Value
→ ConfigurationError
```

もそのまま活用する。

---

## 10.4 BuildCellTarget

Persistence Error Target生成でも必要に応じて再利用する。

新しいCell Target Formatは作らない。

---

# 11. Source-specific Observation OBS-P2-03-001

現行 `ReadCellValue()` は、

```vb
cellValue = ...
    .Value2
```

を使用している。

Excel Date Cellは`.Value2`では、

```text
Variant/Double
```

として既存Carrierへ入る可能性がある。

したがって、

```text
Existing
Reactivated
Unused
```

のP2-02 Target Stateに含まれる、

```text
FirstDetectedAt
LastDetectedAt
```

もDate Serial Numberとして渡る可能性がある。

---

# 12. Date Validation Adaptation

P2-03で以下のような厳密型判定は行わない。

```vb
VarType(value) = vbDate
```

これを採用すると既存P0 CarrierとのCompatibilityを破壊する可能性がある。

代わりにPrivate Helperで、

```text
Blank / Empty / Null / Error
→ Invalid

VBA Date
→ Valid

Excel numeric Date serial
→ Valid if CDate conversion succeeds

Invalid value
→ Failure
```

とする。

概念：

```vb
Private Function TryGetDateValue( _
    ByVal rawValue As Variant, _
    ByRef dateValue As Date _
) As Boolean
```

Persistence時：

```vb
dateValue = CDate(rawValue)
cell.Value = dateValue
```

とする。

Date StringへのFormat処理は行わない。

---

# 13. ExistingRowMap — ADD

追加：

```vb
Private Function BuildExistingRowMap( _
    ByVal lo As ListObject, _
    ByRef rowMap As Object _
) As COperationResult
```

内部構造：

```text
Scripting.Dictionary
CompareMode = vbTextCompare

Key:
VariableName

Value:
ListRow Index
```

TableがEmptyなら、

```text
rowMap.Count = 0
Success
```

とする。

---

# 14. Duplicate Detection

`BuildExistingRowMap()`内でCase Insensitive重複を検出する。

例：

```text
ModelName
modelname
```

→

```text
ConfigurationError
Write = 0
```

先頭行採用はしない。

---

# 15. SyncDiff Structure Validation — ADD

追加：

```vb
Private Function ValidateSyncDiffStructure( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

確認：

```text
syncDiffResult Is Nothing
New Collection存在
Existing Collection存在
Reactivated Collection存在
Unused Collection存在
```

4 CollectionすべてEmpty：

```text
Valid No-op
```

とする。

---

# 16. Diff Collection Access

Repeated late-bound accessを局所化するため、Private Helperを追加する。

```vb
Private Function GetSyncCollection( _
    ByVal syncDiffResult As Object, _
    ByVal classification As String, _
    ByRef items As Collection _
) As COperationResult
```

責務：

```text
Key exists
Object取得可能
Collectionとして取得可能
```

のみ。

Classification Meaningは再計算しない。

---

# 17. Diff Validation — ADD

追加：

```vb
Private Function ValidateDiffItems( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

内部で4 Collectionを走査する。

Cross-classification確認用：

```text
seenNames
CompareMode = vbTextCompare
```

を使用する。

---

# 18. ValidateDiffItem — ADD

```vb
Private Function ValidateDiffItem( _
    ByVal item As Object, _
    ByVal classification As String _
) As COperationResult
```

確認項目：

```text
VariableName key
TemplateLocation key
Status key
FirstDetectedAt key
LastDetectedAt key
```

---

# 19. VariableName Guard

Private Helper：

```vb
Private Function IsValidVariableName( _
    ByVal variableName As String _
) As Boolean
```

Late-bound：

```text
VBScript.RegExp
```

を使用する。

Pattern：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

P2-03ではVariableNameを修正しない。

---

# 20. TemplateLocation Guard

許可：

```text
Subject
Body
Both
```

比較：

```text
vbBinaryCompare
```

とする。

つまり、

```text
subject
BODY
both
```

をP2-03側で正規化しない。

---

# 21. Status / Classification Invariant

許可：

```text
New
        → Active

Existing
        → Active

Reactivated
        → Active

Unused
        → Unused
```

比較：

```text
vbBinaryCompare
```

とする。

不一致はContract Violation。

P2-03で補正しない。

---

# 22. Cross-classification Uniqueness

以下を禁止する。

```text
New:
ModelName

Existing:
MODELNAME
```

Case Insensitiveで同一VariableNameが複数Classificationに存在した場合：

```text
Failure
Write = 0
```

---

# 23. Current State Validation — ADD

追加：

```vb
Private Function ValidateCurrentState( _
    ByVal lo As ListObject, _
    ByVal syncDiffResult As Object, _
    ByVal rowMap As Object _
) As COperationResult
```

確認：

### New

```text
rowMap.Exists(name)
→ False必須
```

### Existing / Reactivated / Unused

```text
rowMap.Exists(name)
→ True必須
```

---

# 24. Canonical VariableName Check

Existing系では、

```text
Case Insensitive Search
```

でRowを特定後、実際のCell値を `ReadCellValue()` で再取得する。

その後、

```vb
StrComp( _
    CStr(tableVariableName), _
    CStr(diffVariableName), _
    vbBinaryCompare)
```

で完全一致を確認する。

例：

```text
Table:
ModelName

Diff:
MODELNAME
```

→ Contract Violation。

P2-02で既存正式表記が維持されるContractの防御確認とする。

---

# 25. Existing Metadata Write — ADD

追加：

```vb
Private Sub WriteExistingMetadata( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal item As Object _
)
```

Write対象：

```text
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

Writeしない：

```text
VariableName

DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

---

# 26. Existing Collection Persistence

追加：

```vb
Private Sub ApplyExistingCollection( _
    ByVal lo As ListObject, _
    ByVal items As Collection, _
    ByVal rowMap As Object _
)
```

対象：

```text
Existing
Reactivated
Unused
```

3 Classificationで同一Persistence処理を使用する。

Classification別Write Logicは作らない。

P2-02 Target StateをそのままWriteする。

---

# 27. New Row Append — ADD

追加：

```vb
Private Sub AppendNewItems( _
    ByVal lo As ListObject, _
    ByVal items As Collection _
)
```

Collection順に：

```vb
lo.ListRows.Add
```

する。

---

# 28. WriteNewRow — ADD

```vb
Private Sub WriteNewRow( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal item As Object _
)
```

設定：

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

Blank：

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

User Configuration Defaultは入れない。

---

# 29. Cell Write Method

文字列：

```vb
.Value2 = ...
```

Date：

```vb
.Value = CDate(...)
```

とする。

Date Columnへ以下は行わない。

```text
Format()
CStr()
NumberFormat変更
```

---

# 30. Runtime Error Boundary

`ApplySyncDiff()` に、

```vb
On Error GoTo UnexpectedError
```

を置く。

Private Write HelperではRuntime Errorを握りつぶさず、Public Boundaryまで伝播させる。

理由：

```text
ApplySyncDiff
```

が、

```text
writeStarted
```

を保持し、Partial Write可能性を判断するため。

---

# 31. writeStarted

概念：

```vb
Dim writeStarted As Boolean

writeStarted = False

' All preflight PASS

writeStarted = True

' Start persistence
```

Runtime Error：

```text
writeStarted = False
→ Standard Unexpected Failure

writeStarted = True
→ Persistence Failure
→ Partial Write possible
```

Rollbackは行わない。

---

# 32. Runtime Error Context

P2-03では最終User Messageを固定しない。

ErrorInfoには少なくとも、

```text
Persistence failure
Write started / not started
Partial update possible / not applicable
Target
```

を識別できる情報を保持する。

User NotificationはP2-05 / P6へ残す。

---

# 33. Zero-target Optimization

全Classificationが0件の場合：

```text
GetVariableDefinitionTable
```

まで進めるかどうかについてはApproved Processing Sequenceに合わせ、

```text
Input Structure Validation
↓
Destination Validation
↓
Current State Validation
↓
Success
```

とする。

つまり、

```text
SyncDiffResult structurally valid
+
tblVariableDefinition structurally valid
+
Target Count = 0
```

でSuccess。

Persistence Writeのみ0件。

---

# 34. Production Patch Location

Source差分を最小化するため、推奨配置：

## Existing Constants

既存Constants群へ必要Constantsのみ追記。

## Existing Public APIs

```text
GetAllVariableDefinitions
GetActiveVariableDefinitions
```

の直後へ、

```text
ApplySyncDiff
```

を追加。

## Existing Private Functions

既存Functionの順番・Bodyは変更しない。

現在最後の、

```text
BuildCellTarget
```

の後へP2-03 Private Helpersを追加する。

これにより既存P0コードへの差分を最小化する。

---

# 35. Exact Source Change Classification

## ADD

```text
STATUS_UNUSED

LOCATION_SUBJECT
LOCATION_BODY
LOCATION_BOTH

SYNC_NEW
SYNC_EXISTING
SYNC_REACTIVATED
SYNC_UNUSED

VARIABLE_NAME_PATTERN

ApplySyncDiff

ValidateSyncDiffStructure
GetSyncCollection
BuildExistingRowMap
ValidateDiffItems
ValidateDiffItem
ValidateCurrentState
IsValidVariableName
TryGetDateValue
ApplyExistingCollection
WriteExistingMetadata
AppendNewItems
WriteNewRow
```

Helper分割時に軽微な統合は可。

---

## MODIFY

```text
NONE
```

既存Function Bodyについては原則変更不要。

---

## DELETE

```text
NONE
```

---

# 36. Explicit DO NOT TOUCH

```text
GetAllVariableDefinitions Signature
GetActiveVariableDefinitions Signature

Existing Read Carrier
KEY_ROW_INDEX behavior

GetVariableDefinitionTable existing behavior
ValidateRequiredColumns existing behavior

ReadVariableDefinitions
ReadVariableDefinitionRow
ReadCellValue

modSyncEngine
P2-02 BuildSyncDiff
SyncDiffResult shape

COperationResult
CErrorInfo
modResult
```

---

# 37. No Refactoring Rule

P2-03実装を理由に以下を行わない。

```text
Read / Write Data Accessの別Module化

VariableDefinition Repository導入

Generic Excel Table Repository導入

Existing Read Helperの全面再編

KEY_* Constantsの共通Module移動

Error Framework再設計

Date Utility Module新設

Domain Class追加
```

今回必要な変更だけを追加する。

---

# 38. Source-specific Compatibility Finding

## OBS-P2-03-001

```text
Current ReadCellValue:
.Value2

Impact:
Excel Date may enter carrier as numeric serial.

Required Patch Adaptation:
Date validation must support existing numeric date serials.

Production Defect:
NONE

P0 Contract Change:
NONE

P2-02 Change:
NONE

Blocking:
NO
```

---

# 39. Gap Matrix

| Approved Requirement              | Current Source             | Patch       |
| --------------------------------- | -------------------------- | ----------- |
| ApplySyncDiff                     | Missing                    | ADD         |
| Table existence check             | Existing                   | REUSE       |
| 12 Column check                   | Existing                   | REUSE       |
| Case-insensitive identity         | Existing pattern available | ADD RowMap  |
| Existing duplicate detection      | Missing                    | ADD         |
| SyncDiff structural validation    | Missing                    | ADD         |
| Diff item validation              | Missing                    | ADD         |
| Classification invariant          | Missing                    | ADD         |
| Cross-class uniqueness            | Missing                    | ADD         |
| New conflict                      | Missing                    | ADD         |
| Existing missing                  | Missing                    | ADD         |
| Canonical exact check             | Missing                    | ADD         |
| Existing metadata write           | Missing                    | ADD         |
| New row append                    | Missing                    | ADD         |
| New config blank                  | Missing                    | ADD         |
| Date persistence                  | Read only                  | ADD         |
| Runtime write boundary            | Missing                    | ADD         |
| Rollback                          | Absent                     | KEEP ABSENT |
| Production read back              | Absent                     | KEEP ABSENT |
| UI notification                   | Absent                     | KEEP ABSENT |
| Existing Read API                 | Existing                   | KEEP        |
| `__RowIndex` persistence identity | Not used                   | KEEP UNUSED |

---

# 40. Expected Production Surface After Patch

```text
modVariableDefinitionData

Public
├─ GetAllVariableDefinitions
├─ GetActiveVariableDefinitions
└─ ApplySyncDiff                 ← NEW

Private Existing
├─ GetVariableDefinitionTable
├─ ValidateRequiredColumns
├─ ReadVariableDefinitions
├─ ReadVariableDefinitionRow
├─ ReadCellValue
└─ BuildCellTarget

Private P2-03
├─ ValidateSyncDiffStructure
├─ GetSyncCollection
├─ BuildExistingRowMap
├─ ValidateDiffItems
├─ ValidateDiffItem
├─ ValidateCurrentState
├─ IsValidVariableName
├─ TryGetDateValue
├─ ApplyExistingCollection
├─ WriteExistingMetadata
├─ AppendNewItems
└─ WriteNewRow
```

具体的なPrivate Helper名はProduction実装時に小規模調整可能。

Public Surfaceは変更しない。

---

# 41. Regression Boundary

Production Patch後、最低限以下を再確認する。

```text
GetAllVariableDefinitions
→ Existing behavior PASS

GetActiveVariableDefinitions
→ Existing behavior PASS

Collection / Dictionary Carrier
→ unchanged

__RowIndex
→ unchanged

Empty Table Read
→ unchanged

Status Active filter
→ unchanged
```

既存P0 Smoke TestをRegressionとして再実行する。

---

# 42. Production Patch Design Result

```text
Current Source Review:
PASS

Approved Spec Compatibility:
PASS

Existing Read Refactor Required:
NO

Existing Function Body Change Required:
NO

New Production Module Required:
NO

P2-02 Change Required:
NO

Public API Addition:
1

Private Persistence Helpers:
ADD

Blocking Source Finding:
0

Source-specific Observation:
1
OBS-P2-03-001
Non-blocking

Production Patch:
MINIMAL ADDITIVE PATCH

Implementation Readiness:
READY
```

---

# 43. Next Action

次工程：

```text
Current Production Source
+
Production Patch Design v0.1
        ↓
modVariableDefinitionData
P2-03 Production Patch作成
        ↓
CP932 Export Candidate
        ↓
Debug → Compile VBAProject
        ↓
Implementation Verification
```

Production実装時には、既存Read Functionを再生成・置換するのではなく、

```text
現行Source
+
必要な追加差分
```

としてPatchする。

---

# 44. Summary

## 日本語

現行`modVariableDefinitionData`を確認した結果、P2-03は既存Read Architectureを変更せず、追記型の最小Production Patchで実装可能である。

既存のTable取得、Required Column検証、ReadCellValue、BuildCellTarget、Result/Error Modelをそのまま再利用する。

既存Public APIおよびRead Carrierは変更しない。

新しいPublic APIは`ApplySyncDiff()` 1本のみとする。

P2-03固有のPreflight、Row Map、Current State Guard、Metadata Write、New Row AppendをPrivate Helperとして追加する。

現行Read処理が`.Value2`を使用しているため、Excel日時がnumeric serialとして既存Carrierへ入る可能性がある。したがってP2-03のDate Validationは既存Carrierと互換性のあるDate conversion方式とする。

Blocking Source Findingは0件であり、Production Patch実装へ進行可能である。

## English

The current `modVariableDefinitionData` source has been reviewed.

P2-03 can be implemented as a minimal additive patch without refactoring the existing read architecture.

The current table lookup, required-column validation, cell reader, cell-target builder, and result/error model will be reused.

Existing public read APIs and carrier structures remain unchanged.

Only one new public API, `ApplySyncDiff()`, is added. P2-03-specific preflight, row lookup, state guards, metadata writes, and new-row persistence remain private.

Because the existing reader uses `.Value2`, Excel dates may enter the existing carrier as numeric date serials. P2-03 date validation must therefore remain compatible with both existing serial values and VBA Date values.

There are no blocking source findings. The production patch is ready for implementation.
