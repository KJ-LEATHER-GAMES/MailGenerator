# P2-04 Manual Sync Integration

# Production Patch Design v0.1

## 1. Document Information

| 項目                          | 内容                                                    |
| --------------------------- | ----------------------------------------------------- |
| 文書名                         | P2-04 Manual Sync Integration Production Patch Design |
| バージョン                       | v0.1                                                  |
| 対象プロジェクト                    | 定型メール作成ツール MVP                                        |
| Execution Baseline          | `BL-MVP-003`                                          |
| Implementation Unit         | P2-04 Manual Sync Integration                         |
| Production Module           | `modSyncApplication`                                  |
| Change Type                 | **ADD New Production Module**                         |
| Reference Production Source | `modMailApplication_P1-07_v0.1_CP932.bas`             |
| Approved Specification      | P2-04 Manual Sync Integration 実施仕様 v0.1               |
| Status                      | **Production Patch Design**                           |

---

# 2. Source Review Result

Current Workbookには、

```text
modSyncApplication
```

は存在しない。

したがってP2-04 Production Changeは、

```text
MODIFY:
NONE

ADD:
modSyncApplication

DELETE:
NONE
```

とする。

`modMailApplication` と `modSyncApplication` は統合しない。

DesignではApplication Layerとして、

```text
modMailApplication
modSyncApplication
```

を分離している。Application LayerはMail CreationとTemplate SyncのOrchestrationを担当する。

Implementation Planでも、

```text
modMailApplication → P1 / P5 / P6
modSyncApplication → P2 / P6
```

としてPhase責務が分離されている。

---

# 3. Reference Pattern from modMailApplication

現行 `modMailApplication` Sourceから、P2-04でも再利用するApplication Patternを以下とする。

```text
Option Explicit

Private Const
↓
Public Application Entry
↓
stepResult As COperationResult
↓
各Component Call
↓
Nothing Result Guard
↓
Success Guard
↓
次処理
↓
Private Gate / Helper
↓
UnexpectedError
↓
Cleanup
```

P1-07で成立したProduction Flowは、

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
↓
...
↓
DisplayMail / Fail Closed Cleanup
```

である。

P2-04ではこのうち、

```text
Settings.TemplatePath
ResolveWorkbookRelativePath
CreateMailFromTemplate
ReadSubject
ReadBodyText
ScanTemplate
CloseWithoutSave
```

のProduction Patternを再利用する。

---

# 4. Patterns to Reuse

`modMailApplication` から以下を構造上踏襲する。

```text
1 Public Entry = Application Use Case

COperationResultによるStep単位Failure Propagation

各ComponentがNothingを返した場合のContract Guard

On Error GoTo UnexpectedError

Infrastructure FailureをApplicationで再解釈しすぎない

Outlook / Word COM ObjectをApplicationへ露出しない

Private HelperでMailItem Lifecycleを閉じる

Final Cleanup LabelでObject Referenceを解放

User-facing MsgBoxをApplicationへ置かない
```

---

# 5. Patterns NOT to Copy

以下は `modMailApplication` 固有であり、`modSyncApplication` へ持ち込まない。

```text
formattedValues

RenderSubject
SetSubject
ReplaceBodyVariables

CheckUnresolved
ValidateUnresolvedGate

DisplayMail
Positive-Allow Display Gate

Unresolved Result

Display Ownership Transfer
```

P2-04はSync Applicationであり、Mail Generation Applicationではない。

---

# 6. Production Responsibility

`modSyncApplication` の責務を以下へ限定する。

```text
Manual Sync Application Entry

Current Template Acquisition
Current Template Scan

Invalid Candidate Execution Guard

Current VariableDefinitions Retrieval

SyncTimestamp Acquisition

BuildSyncDiff Invocation

ApplySyncDiff Invocation

Execution Order

MailItem Cleanup Coordination

Component Failure Propagation

TemplateScanResult Handoff

Successful SyncDiffResult Handoff
```

---

# 7. Explicit Non-responsibility

`modSyncApplication` では以下を行わない。

```text
Variable Syntax判定ロジック
Sync Classification
Canonical VariableName計算
Metadata Target計算
VariableDefinition Persistence意味論

User Configuration Default計算

Sync Result Message生成
MsgBox / UserForm表示
Manual Sync Button実装

Final Error Code体系
Final User-facing Error Mapping

Automatic Retry
Rollback
Transaction Emulation

Module-level Current Sync State

Formal MVP Test

Outlook / Word COM直接操作
```

P2-02はManual Sync OrchestrationとPersistenceを非責務としており、差分分類のみを担当する。

P2-03はPersistenceを担当し、SyncTimestamp取得、Manual Sync Orchestration、Retry、UI等を非責務としている。

---

# 8. Public API

Approved ContractをそのままProduction APIとする。

```vb
Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object, _
    ByRef templateScanResult As Object _
) As COperationResult
```

Public APIはこの1本のみとする。

---

# 9. Public Output Contract

Function Entry時：

```text
syncDiffResult = Nothing
templateScanResult = Nothing
```

## Success

```text
COperationResult.Success = True

templateScanResult
= Current TemplateScanResult

syncDiffResult
= ApplySyncDiff成功済みのSyncDiffResult
```

## Invalid Candidate

```text
COperationResult.Success = False

templateScanResult
= Current TemplateScanResult

InvalidCandidates.Count > 0

syncDiffResult
= Nothing
```

## Template取得 / Scan Technical Failure

```text
COperationResult.Success = False

templateScanResult
= Nothing

syncDiffResult
= Nothing
```

## Current Definition / Build / Apply Failure

```text
COperationResult.Success = False

templateScanResult
= 成立済みCurrent TemplateScanResult

syncDiffResult
= Nothing
```

`syncDiffResult` はPersistence成功後のみ公開する。

---

# 10. Proposed Module Structure

Production `modSyncApplication` は以下の最小構造とする。

```text
modSyncApplication

Option Explicit

Private Const
├─ SETTING_TEMPLATE_PATH
├─ KEY_INVALID_CANDIDATES
├─ ERROR_TYPE_CONFIGURATION
├─ ERROR_TYPE_UNEXPECTED
├─ TARGET_SYNC_APPLICATION
├─ TARGET_TEMPLATE_SCAN_RESULT
└─ TARGET_MAIL_CLEANUP

Public
└─ ExecuteManualSync

Private
├─ ScanCurrentTemplate
├─ ValidateSyncScanGate
├─ ValidateTemplateFileExists
├─ FailScanAndCleanup
└─ DebugPrintOperationResult
```

Private Helperは必要最小限とする。

---

# 11. Public Entry — ExecuteManualSync

Main Application Flow：

```text
ExecuteManualSync
↓
Output初期化
↓
ScanCurrentTemplate
↓
TemplateScanResult公開
↓
ValidateSyncScanGate
↓
InvalidCandidatesあり？
├─ Yes → Failure / Stop
└─ No
    ↓
GetAllVariableDefinitions
    ↓
SyncTimestamp = Now
    ↓
BuildSyncDiff
    ↓
candidateSyncDiffResult
    ↓
ApplySyncDiff
    ↓
成功？
├─ No → Failure / syncDiffResult = Nothing
└─ Yes
    ↓
syncDiffResult = candidateSyncDiffResult
    ↓
Success
```

---

# 12. ExecuteManualSync Local Variables

想定する主要Local Variable：

```vb
Dim stepResult As COperationResult
Dim gateResult As COperationResult
Dim primaryFailure As COperationResult

Dim currentDefinitions As Collection

Dim candidateTemplateScanResult As Object
Dim candidateSyncDiffResult As Object

Dim syncTimestamp As Date
```

Module-level Stateは持たない。

---

# 13. Current Template Scan Boundary

Private API：

```vb
Private Function ScanCurrentTemplate( _
    ByRef scanResult As Object _
) As COperationResult
```

責務：

```text
TemplatePath取得
↓
Workbook Relative Path Resolution
↓
OFT Existence Guard
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
Success
```

Design上、Manual SyncはSettings → Path Resolution → OFT存在確認 → Outlook Adapter → Scanの順で進む。OFT不存在やInvalid Variableでは後続へ進まない。

---

# 14. ScanCurrentTemplate Local State

想定：

```vb
Dim stepResult As COperationResult
Dim primaryFailure As COperationResult
Dim cleanupResult As COperationResult

Dim templatePath As String
Dim resolvedTemplatePath As String
Dim subjectText As String
Dim bodyText As String

Dim candidateScanResult As Object

Dim mailCreated As Boolean
```

---

# 15. TemplatePath

既存 `modMailApplication` と同じProduction APIを利用する。

```vb
GetSettingValue( _
    SETTING_TEMPLATE_PATH, _
    templatePath)
```

続いて、

```vb
ResolveWorkbookRelativePath( _
    templatePath, _
    resolvedTemplatePath)
```

を利用する。

P2-04でPath Resolutionを再実装しない。

---

# 16. OFT Existence Guard

P2-04ではDesign §25.1 / FR-SYNC-008に従い、

```text
Path Resolution
↓
OFT Existence Guard
↓
Outlook
```

の順序を明示する。

Private Helper：

```vb
Private Function ValidateTemplateFileExists( _
    ByVal resolvedTemplatePath As String _
) As COperationResult
```

を想定する。

このHelperは、

```text
存在する
→ Success

存在しない
→ Failure
```

のみを担当する。

Path Resolution自体は担当しない。

最終User-facing Error MessageはP2-05 / P6で確定する。

既存Productionに再利用可能なOFT Existence Guardが後から確認された場合のみ、そのAPIへ置換してよい。

新しいInfrastructure Moduleは作成しない。

---

# 17. Outlook Boundary

P2-04は、

```text
CreateMailFromTemplate
ReadSubject
ReadBodyText
CloseWithoutSave
```

のみ利用する。

Inspector / WordEditor / Word Document / Explorerを直接触らない。

DesignではClassic Outlook ReadinessおよびWordEditor依存を `modOutlookAdapter` 内へ閉じ込めている。

---

# 18. MailItem Lifecycle

Scan MailItem：

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

正常Scanでも必ずCloseする。

```text
DisplayMail:
NONE

Save:
NONE
```

P1-07ではWarm / Cold双方でScan用MailItem LifecycleがProduction Architecture上成立している。

---

# 19. Scan Result Publication Boundary

`ScanTemplate` がSuccessしても、即座にPublic `templateScanResult` へ公開しない。

まずLocal：

```text
candidateScanResult
```

へ保持する。

その後、

```text
CloseWithoutSave
```

まで成功して初めて、

```text
ScanCurrentTemplate = Success
```

とする。

したがって、

```text
Scan Success
+
Cleanup Failure
```

の場合、

```text
ScanCurrentTemplate = Failure
```

となる。

`ExecuteManualSync` はこの状態をSuccessful Scanとして扱わない。

---

# 20. ValidateSyncScanGate

Private API：

```vb
Private Function ValidateSyncScanGate( _
    ByVal scanResult As Object _
) As COperationResult
```

`modMailApplication.ValidateScanGate` のPatternを参照するが、P2-04ではSync用途に限定する。

最低限確認：

```text
scanResult Is Nothing → Failure

TypeName = Dictionary → 必須

InvalidCandidates Key存在 → 必須

InvalidCandidates Collection存在 → 必須

InvalidCandidates.Count > 0
→ Configuration Failure
```

Variable Syntaxそのものを再判定しない。

---

# 21. ValidVariables Validation

`modMailApplication.ValidateScanGate` は、

```text
ValidVariables
InvalidCandidates
```

双方を確認している。

P2-04では `BuildSyncDiff` へ完全な `TemplateScanResult` を渡すため、

```text
ValidVariables
InvalidCandidates
Locations
```

の構造ContractそのものはP2-01 / P2-02側で既に検証される。

したがってP2-04 Gateでは、

```text
InvalidCandidatesを安全に判定できる最低限
```

に限定する。

P2-02のPreflightをApplication側で重複実装しない。

---

# 22. Invalid Candidate Boundary

Gate Failure時：

```text
templateScanResult
= current scan result

syncDiffResult
= Nothing

GetAllVariableDefinitions
= NOT CALLED

BuildSyncDiff
= NOT CALLED

ApplySyncDiff
= NOT CALLED
```

このResult Carrierは後続P2-05がInvalid Candidate一覧を通知するために利用する。

---

# 23. Current VariableDefinitions

Invalid Guard通過後：

```vb
GetAllVariableDefinitions(currentDefinitions)
```

を呼ぶ。

`GetActiveVariableDefinitions` は使用しない。

理由：

```text
Reactivated判定
Unused維持判定
```

にはUnusedを含むCurrent Stateが必要である。

---

# 24. SyncTimestamp Boundary

以下の順番を固定する。

```text
Template Scan Success
↓
InvalidCandidates = 0
↓
GetAllVariableDefinitions Success
↓
syncTimestamp = Now
↓
BuildSyncDiff
```

`Now` は1 Manual Syncにつき1回だけ実行する。

P2-02はTimestampを内部取得せず、Callerから受け取るContractで成立している。

---

# 25. BuildSyncDiff

呼出：

```vb
BuildSyncDiff( _
    candidateTemplateScanResult, _
    currentDefinitions, _
    syncTimestamp, _
    candidateSyncDiffResult)
```

P2-04では、

```text
New
Existing
Reactivated
Unused
Canonical VariableName
Metadata
```

を一切再計算しない。

---

# 26. Candidate SyncDiff Boundary

`BuildSyncDiff` Success後も、

```text
candidateSyncDiffResult
```

はLocalに保持する。

この段階ではPublic：

```text
syncDiffResult
```

へ公開しない。

理由：

```text
Diff計算成功
≠
Persistence成功
≠
Manual Sync成功
```

だからである。

---

# 27. ApplySyncDiff

呼出：

```vb
ApplySyncDiff(candidateSyncDiffResult)
```

Adapter / Copy / Transformは挟まない。

P2-03 ContractはP2-02 `SyncDiffResult` を直接消費する。

---

# 28. Successful Result Publish Boundary

以下がすべて成功した場合のみ、

```vb
Set syncDiffResult = candidateSyncDiffResult
```

を実行する。

```text
Template Acquisition
Template Scan
Scan MailItem Cleanup
Invalid Guard
Current Definitions
BuildSyncDiff
ApplySyncDiff
```

その後、

```vb
Set ExecuteManualSync = CreateSuccessResult()
```

とする。

---

# 29. Apply Failure

`ApplySyncDiff` Failure時：

```text
ExecuteManualSync
= Failure

syncDiffResult
= Nothing

templateScanResult
= Current TemplateScanResult
```

自動Retryしない。

Rollbackしない。

P2-03ではRuntime Failure後にPartial Writeが発生する可能性があり、再実行時はCurrent Stateから再取得して新しいDiffを作る必要がある。

---

# 30. Retry Boundary

新しいManual Sync要求では必ず、

```text
Template再取得
↓
再Scan
↓
Current VariableDefinitions再取得
↓
新SyncTimestamp
↓
BuildSyncDiff再実行
↓
ApplySyncDiff
```

とする。

以下を保持しない。

```text
Previous TemplateScanResult
Previous VariableDefinitions
Previous SyncTimestamp
Previous SyncDiffResult
Retry Count
```

---

# 31. Failure Result Handling

`modMailApplication` と同じPatternを使用する。

各Component Call後：

```vb
If stepResult Is Nothing Then
    ' Contract Failure
End If

If Not stepResult.Success Then
    ' Propagate Failure
End If
```

Componentが有効な `COperationResult` Failureを返した場合、

```text
ErrorType
Target
Message
```

をApplication側で不要に書き換えない。

---

# 32. Unexpected Error

Public Entry：

```vb
On Error GoTo UnexpectedError
```

Unexpected VBA Runtime Errorは、

```text
COperationResult
ErrorType = UnexpectedError
Target = SyncApplication
```

相当へ変換する。

最終的なUser-facing Message / Error Code体系はP6責務を維持する。

---

# 33. Cleanup Strategy

`modMailApplication` の `FailAndCleanup` Patternを参照するが、**その実装をそのままコピーしない**。

P2-04 Approved Contractに従い、Scan用MailItem Cleanupは `ScanCurrentTemplate` 内へ閉じ込める。

概念：

```text
Primary Processing Failureあり
+
MailItem Created
↓
CloseWithoutSave attempt
```

---

# 34. Cleanup Precedence

P2-04では以下とする。

## Primary Processing Success + Cleanup Failure

```text
Return:
Cleanup Failure
```

Manual Syncを成功扱いしない。

## Primary Processing Failure + Cleanup Success

```text
Return:
Primary Failure
```

## Primary Processing Failure + Cleanup Failure

```text
Return:
Primary Failure
```

Cleanup FailureはDebug Evidenceへ残す。

P2-04でMultiple Error Aggregation Modelは追加しない。

最終Error PrecedenceはP6で再評価可能とする。

これは現行 `modMailApplication.FailAndCleanup` を機械的にコピーしない点である。

---

# 35. Proposed Cleanup Helper

Private Helper候補：

```vb
Private Function FailScanAndCleanup( _
    ByVal primaryResult As COperationResult, _
    ByVal mailCreated As Boolean _
) As COperationResult
```

ただし、

```text
Scan Success
→ Cleanup
```

にも利用すると意味が曖昧になるため、実装時には以下のどちらかを採用してよい。

```text
A:
FailScanAndCleanup
+
Normal CloseをScanCurrentTemplate内で直接処理

B:
CompleteScanCleanup
として正常 / Failure双方を処理
```

★推奨：

```text
A
```

理由：

既存 `modMailApplication` のPatternに近く、正常CleanupとFailure Cleanupの意味を混ぜずに済む。

---

# 36. DebugPrintOperationResult

`modMailApplication` に存在する、

```vb
Private Sub DebugPrintOperationResult(...)
```

相当を `modSyncApplication` 内へPrivateで持ってよい。

用途：

```text
Primary Failure
+
Cleanup Failure
```

でCleanup情報を失わずDeveloper Evidenceとして残す。

共通Logging Moduleは新設しない。

P6で必要性が確定するまでYAGNIを維持する。

---

# 37. Constants

想定する最小Constant：

```vb
Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Private Const KEY_INVALID_CANDIDATES As String = _
    "InvalidCandidates"

Private Const ERROR_TYPE_CONFIGURATION As String = _
    "ConfigurationError"

Private Const ERROR_TYPE_UNEXPECTED As String = _
    "UnexpectedError"

Private Const TARGET_SYNC_APPLICATION As String = _
    "SyncApplication"

Private Const TARGET_TEMPLATE_SCAN_RESULT As String = _
    "TemplateScanResult"

Private Const TARGET_MAIL_CLEANUP As String = _
    "MailItemCleanup"
```

P2-04で新しいError Code体系は作らない。

---

# 38. Proposed Production Skeleton

構造イメージ：

```vb
Attribute VB_Name = "modSyncApplication"
Option Explicit

' P2-04 Manual Sync Integration
'
' Responsibility:
' - Orchestrate Manual Sync production flow
' - Acquire one SyncTimestamp per Sync
' - Connect Scanner / Sync Engine / Persistence
' - Enforce pre-sync mutation guards
' - Return TemplateScanResult / persisted SyncDiffResult
'
' Non-responsibility:
' - Scan semantics
' - Sync classification
' - Persistence semantics
' - User-facing Sync Result UI
' - Final error taxonomy
' - Automatic retry
' - Rollback

Private Const ...

Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object, _
    ByRef templateScanResult As Object _
) As COperationResult

    ' 1. Initialize outputs
    ' 2. ScanCurrentTemplate
    ' 3. Publish valid scan carrier
    ' 4. Invalid gate
    ' 5. GetAllVariableDefinitions
    ' 6. syncTimestamp = Now
    ' 7. BuildSyncDiff
    ' 8. ApplySyncDiff
    ' 9. Publish syncDiffResult
    ' 10. Success
    ' UnexpectedError

End Function

Private Function ScanCurrentTemplate( _
    ByRef scanResult As Object _
) As COperationResult
End Function

Private Function ValidateSyncScanGate( _
    ByVal scanResult As Object _
) As COperationResult
End Function

Private Function ValidateTemplateFileExists( _
    ByVal resolvedTemplatePath As String _
) As COperationResult
End Function

Private Function FailScanAndCleanup( _
    ByVal primaryResult As COperationResult, _
    ByVal mailCreated As Boolean _
) As COperationResult
End Function

Private Sub DebugPrintOperationResult(...)
End Sub
```

---

# 39. Dependency Direction

Production dependency：

```text
modSyncApplication
│
├─ modSettingsData
├─ modOutlookAdapter
├─ modTemplateScanner
├─ modVariableDefinitionData
├─ modSyncEngine
└─ modResult
```

逆方向Dependencyは禁止する。

```text
modSyncEngine
→ modSyncApplication

modVariableDefinitionData
→ modSyncApplication

modOutlookAdapter
→ modSyncApplication
```

は作らない。

---

# 40. No Direct Infrastructure Access

`modSyncApplication` から許容するのは既存Public API呼出のみ。

禁止：

```text
ListObject直接操作
Worksheet直接更新

CreateObject("Outlook.Application")
GetObject(...)

Inspector
WordEditor
Word.Document
Word.Range

MailItem Object保持
```

MailItem Lifecycleの実体は `modOutlookAdapter` 内部へ維持する。

---

# 41. Production Change Matrix

```text
ADD:
modSyncApplication

MODIFY:
NONE

DELETE:
NONE
```

P2-04実装を理由として、

```text
modMailApplication
modOutlookAdapter
modTemplateScanner
modSyncEngine
modVariableDefinitionData
modSettingsData
modResult
COperationResult
CErrorInfo
```

を変更しない。

CompileまたはContract Compatibility上の必要性が発覚した場合のみFindingとして再評価する。

---

# 42. Why modMailApplication Is Not Reused Directly

`modMailApplication` には、

```text
Template取得
Scan
Lifecycle
Result Handling
```

という共通Patternが存在する。

しかし責務として、

```text
Render
Unresolved
Display
```

も持つ。

P2-04をそこへ追加すると、

```text
Mail Creation Application
+
Template Sync Application
```

が1 Moduleへ混在する。

現時点では統合による明確なMVP負荷削減メリットがなく、Design / Implementation Planも別Moduleを前提としている。

したがって、

```text
Code Reuse by Copying:
NO

Pattern Reuse:
YES

Responsibility Merge:
NO
```

とする。

---

# 43. Verification Hooks

ProductionへTest専用Public APIは追加しない。

VerificationはPublic：

```text
ExecuteManualSync
```

を入口とする。

必要なTest ArtifactはProduction Module外へ置く。

---

# 44. Static Review Target

Production Patch Reviewでは最低限以下を確認する。

```text
S01 modSyncApplication追加のみ
S02 Public API = ExecuteManualSync 1本
S03 Automatic Sync Eventなし
S04 MsgBox / UserFormなし
S05 Now取得 = 1箇所
S06 ScanTemplate呼出あり
S07 GetAllVariableDefinitions呼出あり
S08 BuildSyncDiff呼出あり
S09 ApplySyncDiff呼出あり
S10 Invalid時Buildなし
S11 Build Failure時Applyなし
S12 Apply Failure時Successなし
S13 Success前syncDiffResult公開なし
S14 Invalid時templateScanResult保持
S15 Classification再計算なし
S16 Canonical Name再計算なし
S17 Metadata再計算なし
S18 Persistence直接実装なし
S19 Excel ListObject直接操作なし
S20 Outlook / Word COM直接操作なし
S21 DisplayMailなし
S22 Automatic Retryなし
S23 Module-level Sync Stateなし
S24 New Result Classなし
S25 Test-only Public APIなし
```

---

# 45. Implementation Order

Production Implementationは次の順とする。

```text
1. New modSyncApplication作成
2. Constants / Header
3. ScanCurrentTemplate
4. ValidateTemplateFileExists
5. ValidateSyncScanGate
6. Scan Cleanup
7. ExecuteManualSync
8. Unexpected Error Path
9. VBA Compile
10. Local Verification
11. Static Review
12. Production Patch Review
```

---

# 46. Design Findings

Current Design時点：

```text
Requirement Gap:
NONE

Design Conflict:
NONE

Approved Specification Conflict:
NONE

P1 Contract Conflict:
NONE

P2-01 Contract Conflict:
NONE

P2-02 Contract Conflict:
NONE

P2-03 Contract Conflict:
NONE

New Technical Spike:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
0
```

---

# 47. Production Implementation Decision

Production Strategy：

```text
New Module Minimal Implementation
```

採用：

```text
modSyncApplication
```

Public API：

```vb
ExecuteManualSync( _
    syncDiffResult, _
    templateScanResult _
) As COperationResult
```

Primary Flow：

```text
Current Template
↓
Scan
↓
Invalid Guard
↓
Current VariableDefinitions
↓
Single SyncTimestamp
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
Successful Result Publish
```

Reference Pattern：

```text
modMailApplication
```

ただし、

```text
Pattern Reuse only
No Responsibility Merge
```

とする。

---

# 48. Next Action

次の正式作業：

```text
P2-04 Manual Sync Integration
Production Implementation
```

実装対象：

```text
ADD:
modSyncApplication
```

既存Production Module：

```text
CHANGE:
NONE
```

実装後、

```text
VBA Compile
↓
Local Verification
↓
Production Patch Review
↓
Finding Assessment
↓
P2-04 Completion Decision
```

へ進む。

---

# 49. まとめ / Summary

## 日本語

現行 `modMailApplication` のProduction Sourceを参照し、P2-04用の新規 `modSyncApplication` 構成を設計した。

`modMailApplication` からは、Application Orchestration、`COperationResult`、Nothing Guard、Unexpected Error変換、MailItem Cleanupという実装Patternを再利用する。

一方、Render、Unresolved Check、Display等のMail Generation責務は持ち込まない。

`modSyncApplication` はPublic API `ExecuteManualSync` 1本を持ち、

Current Template Scan → Invalid Guard → Current VariableDefinitions → Single SyncTimestamp → BuildSyncDiff → ApplySyncDiff → Successful Result Publish

のみを担当する。

Production変更は新規 `modSyncApplication` の追加だけとし、既存Production Moduleは変更しない。

Blocking Findingはない。

## English

A new `modSyncApplication` structure has been designed using the current `modMailApplication` production source as the implementation-pattern reference.

The new module reuses its orchestration, operation-result, contract-guard, error-conversion, and MailItem-cleanup patterns, but does not inherit mail-rendering, unresolved-checking, or display responsibilities.

`modSyncApplication` exposes one public API, `ExecuteManualSync`, and orchestrates:

Current Template Scan → Invalid Guard → Current Definitions → Single SyncTimestamp → BuildSyncDiff → ApplySyncDiff → Successful Result Publish.

The production change is limited to adding the new `modSyncApplication` module. No existing production module needs to be modified.
