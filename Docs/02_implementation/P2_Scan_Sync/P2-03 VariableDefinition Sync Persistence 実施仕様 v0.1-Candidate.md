# P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-03 VariableDefinition Sync Persistence 実施仕様 |
| バージョン | v0.1 |
| Status | **Candidate** |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Current Execution Baseline | `BL-MVP-003` |
| 対象Phase | P2 Scan / Sync |
| 対象Implementation Unit | P2-03 VariableDefinition Sync Persistence |
| Primary Production Module | `modVariableDefinitionData` |
| Dependency | P2-02 Sync Diff Core = PASS / COMPLETE |
| Boundary Input | P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1 |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements v0.1.9
- `DOC-MVP-DES` — MVP Design v0.1.9
- `DOC-MVP-TESTSPEC` — MVP Test Specification v0.1.5
- `DOC-MVP-IMPL` — Implementation Plan v0.3
- `BL-MVP-003 Baseline Approval Record v0.1`
- `P2-02 Sync Diff Core Completion Record v0.1`
- `P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1`

---

# 2. Objective

P2-03では、P2-02 `BuildSyncDiff()` が生成した `SyncDiffResult` を受け取り、そのTarget StateをExcel `tblVariableDefinition`へ永続化する。

```text
P2-02
BuildSyncDiff()
        ↓
SyncDiffResult
        ↓
P2-03
ApplySyncDiff()
        ↓
tblVariableDefinition
```

P2-02ではClassification、Canonical VariableName、Target Metadata、共通SyncTimestamp利用などが既に確定している。P2-03はそれらを再計算せず、Persistenceのみを担当する。

---

# 3. Implementation Principles

本Unitでは以下を優先する。

```text
1. Boundaryを崩さない
2. Write前に検知可能な異常を全件Preflightする
3. P2-02の意味論を再実装しない
4. User Configurationを同期処理で破壊しない
5. Excel依存をmodVariableDefinitionData内部へ封じ込める
6. MVPで不要なTransaction / Repository / Domain Classを追加しない
7. Production Public APIを最小化する
```

RequirementsではNew追加、Existing設定保持、Unused化、Reactivation、Rename非推測が定義されている。

DesignではExcel操作を薄いData Access層へ集約し、`modVariableDefinitionData`がVariableDefinitionのAdd / Metadata Updateを担う構造となっている。

---

# 4. Production Scope

## 4.1 Production変更対象

```text
modVariableDefinitionData
```

既存Moduleを拡張する。

新規Production Moduleは追加しない。

Implementation Plan上も `modVariableDefinitionData` はInfrastructureとしてP2の実装対象である。

---

## 4.2 新規Public API

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

Production Public APIはこの1本のみ追加する。

---

## 4.3 Input Contract

`syncDiffResult` はP2-02 Production Contractに従う。

```text
SyncDiffResult
├─ New            As Collection
├─ Existing       As Collection
├─ Reactivated    As Collection
└─ Unused         As Collection
```

各Item：

```text
Dictionary
├─ VariableName
├─ TemplateLocation
├─ Status
├─ FirstDetectedAt
└─ LastDetectedAt
```

P2-03ではCarrier Shapeを変更しない。

---

# 5. Output Contract

`ApplySyncDiff()` は既存 `COperationResult` のみを返す。

## Success

```text
Success = True
Errors  = Empty
```

## Failure

```text
Success = False
Errors  = 1件以上
```

Persistence件数等を保持する追加Result Carrierは作成しない。

件数はCallerが既存 `SyncDiffResult` から取得する。

---

# 6. ErrorType Mapping

既存Error Modelのみ使用する。

新しい `PersistenceError` 等は追加しない。

| Failure | ErrorType | Target |
|---|---|---|
| malformed SyncDiffResult | `UnexpectedError` | `SyncDiffResult` |
| malformed Diff Item | `UnexpectedError` | VariableName取得可能ならその名前 |
| invalid Target State | `UnexpectedError` | VariableName |
| Classification invariant violation | `UnexpectedError` | VariableName |
| tblVariableDefinition不存在 | `ConfigurationError` | `tblVariableDefinition` |
| Required Column不存在 | `ConfigurationError` | Column Name |
| Existing Table内VariableName重複 | `ConfigurationError` | VariableName |
| New Itemなのに既存行あり | `UnexpectedError` | VariableName |
| Existing系Itemなのに行なし | `UnexpectedError` | VariableName |
| Canonical VariableName不一致 | `UnexpectedError` | VariableName |
| Excel Runtime Failure | `UnexpectedError` | `VariableDefinition` |

`CErrorInfo`は既存の、

```text
ErrorType
Message
Target
```

を使用する。

P2-03自身はErrorをUI表示しない。

---

# 7. Processing Sequence

`ApplySyncDiff()` のProduction Sequenceを以下で固定する。

```text
ApplySyncDiff
    ↓
[1] Input Structure Preflight
    ↓
[2] Persistence Destination Preflight
    ↓
[3] Existing Table State Index構築
    ↓
[4] Diff Item Contract Preflight
    ↓
[5] Current State Conflict Preflight
    ↓
------ Write Boundary ------
    ↓
[6] Existing Items Persistence
    ↓
[7] Reactivated Items Persistence
    ↓
[8] Unused Items Persistence
    ↓
[9] New Items Append
    ↓
[10] Success Result
```

`Existing → Reactivated → Unused` の順序にはBusiness Semanticsを持たせない。

実装およびVerificationの再現性を確保するための固定実行順序とする。

NewだけはBoundary Decisionに従い最後に処理する。

---

# 8. Preflight — Input Structure

## 8.1 syncDiffResult

以下を確認する。

```text
syncDiffResult Is Nothing
→ Failure
```

以下4 Classificationが存在すること。

```text
New
Existing
Reactivated
Unused
```

各値は `Collection` として利用可能であること。

4 Collectionがすべて0件でも正常とする。

```text
Total Target = 0
→ Success No-op
```

---

# 9. Preflight — Destination Structure

対象：

```text
Sheet / Table:
tblVariableDefinition
```

Tableが存在しない場合はWriteしない。

Required Columns：

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

列番号は固定値を使用せず、`ListColumns(ColumnName)`相当で名前から解決する。

列位置をData Access外へ公開しない。

---

# 10. Existing Row Index

Preflight中に現在の `tblVariableDefinition` を走査し、Case InsensitiveのLookupを構築する。

概念構造：

```text
ExistingRowMap
CompareMode = vbTextCompare

Key:
VariableName

Value:
Internal Row Index
```

Physical Row Indexは `modVariableDefinitionData` の内部情報としてのみ使用する。

P2-02 / P2-04 / Callerへ返さない。

---

## 10.1 Duplicate Detection

Table内で、

```text
ModelName
modelname
```

のようなCase Insensitive重複を検出した場合はFailureとする。

```text
Excel Write = 0
```

先頭行採用、Merge、削除等は行わない。

---

## 10.2 Empty Table

`DataBodyRange = Nothing` 相当の0行Tableは正常状態とする。

```text
ExistingRowMap.Count = 0
```

として処理する。

Dummy Rowは使用しない。

---

# 11. Diff Item Validation

各Itemは以下5 Fieldを必須とする。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

不足Fieldが1つでもある場合はFailureとする。

---

## 11.1 VariableName

以下に適合すること。

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

Blank / Empty / Nullは不可。

---

## 11.2 TemplateLocation

以下の完全一致のみ許可する。

```text
Subject
Body
Both
```

P2-03ではCase補正やTrimによる正規化を行わない。

---

## 11.3 Status

以下の完全一致のみ許可する。

```text
Active
Unused
```

P2-03では値を補正しない。

---

## 11.4 Timestamp

`FirstDetectedAt` および `LastDetectedAt` は、対象Classificationで必要な値が有効な `Date` として扱えること。

String形式への変換は行わない。

---

# 12. Classification Invariant Validation

P2-03はStatusを計算しない。

ただしP2-02 Contractが破損していないことを確認する。

```text
New
→ Status = Active

Existing
→ Status = Active

Reactivated
→ Status = Active

Unused
→ Status = Unused
```

不一致：

```text
Contract Violation
→ Failure
→ Write = 0
```

StatusをP2-03側で修正して続行してはならない。

---

# 13. Cross-classification Uniqueness

4 Classification全体を横断し、VariableNameをCase Insensitiveで一意確認する。

例：

```text
New:
ModelName

Existing:
MODELNAME
```

はFailure。

```text
Classification Priority
Merge
Skip
```

は導入しない。

---

# 14. Current State Conflict Guard

## 14.1 New

New Itemについて、

```text
ExistingRowMap.Exists(VariableName) = True
```

の場合：

```text
Failure
Write = 0
```

Existingへの再分類は行わない。

---

## 14.2 Existing / Reactivated / Unused

対象VariableNameがTableに存在しない場合：

```text
Failure
Write = 0
```

Newへの再分類、新規作成、Skipは行わない。

---

## 14.3 Canonical VariableName

Existing系ではまずCase InsensitiveでLogical Identityを検索する。

その後、Tableに保存されている正式表記とDiff Itemの `VariableName` が完全一致することを確認する。

例：

```text
Table:
ModelName

Diff:
MODELNAME
```

Case Insensitive Identityとしては同一だが、P2-02はExistingのCanonical Nameとして既存正式表記を返すContractであるため、この状態はContract Violationとする。

P2-03でTable側またはDiff側の表記を補正しない。

---

# 15. Metadata Completeness

New / Existing / Reactivated / UnusedのTarget Stateとして必要な自動MetadataがBlank / Empty / Nullの場合はFailureとする。

P2-03は以下のような補完を行わない。

```text
FirstDetectedAt Blank
→ Now()

LastDetectedAt Blank
→ FirstDetectedAt

TemplateLocation Blank
→ Body
```

既存データ修復は本Unitの責務外とする。

---

# 16. User Configuration Boundary

User Configuration：

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

## Existing / Reactivated / Unused

一切Writeしない。

現在値を保持する。

P2-03 PreflightではConfiguration Completenessも判定しない。

例えば、

```text
DisplayName = Blank
Type = Blank
Required = Blank
```

であっても、それ自体をPersistence Failureとはしない。

Configuration Validationは後続責務とする。

---

## New

新しいListRow追加後、以下を明示的にBlank状態とする。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

自動Defaultは設定しない。

特に、

```text
Required = False
Type = Text
SortOrder = 0
```

等を設定してはならない。

---

# 17. Existing Row Persistence

Existing / Reactivated / Unusedでは、以下4 Fieldを毎回Writeする。

```text
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

現在値とのDiff比較は行わない。

Classification別にWrite対象列を変えない。

P2-02が返したTarget StateをPersistenceする。

---

## 17.1 VariableName

Existing系ではVariableName Cellを書き換えない。

VariableNameは以下にのみ使用する。

```text
Row Identity
Canonical Consistency Validation
Error Target
```

---

# 18. New Row Persistence

New Itemごとに、

```vb
tblVariableDefinition.ListRows.Add
```

相当で末尾へ追加する。

追加行に以下を設定する。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

User Configuration 7 FieldはBlankにする。

---

## 18.1 Multiple New

`SyncDiffResult("New")` のCollection順で追加する。

P2-03ではSortしない。

---

# 19. Date Persistence

以下はExcel CellへVBA DateとしてWriteする。

```text
FirstDetectedAt
LastDetectedAt
```

概念：

```vb
cell.Value = CDate(item("FirstDetectedAt"))
```

Dateを事前にStringへ変換しない。

以下は行わない。

```text
Format()
CStr()
yyyy/mm/dd ...
NumberFormat変更
```

Cell Display Formatは既存Excel設定へ委ねる。

---

# 20. Excel UI / Workbook Side Effects

P2-03が意図的に変更するもの：

```text
対象Cell Value
New時のListRow
```

意図的に変更しないもの：

```text
Filter
Sort
Selection
ActiveSheet
Column Width
NumberFormat
Cell Format
Worksheet表示状態
```

`Select` / `Activate` はProduction Codeで使用しない。

---

# 21. Runtime Error Handling

Public `ApplySyncDiff()` をRuntime Error Boundaryとする。

概念：

```text
On Error GoTo EH
```

Preflightで返却可能なFailureはRuntime Exception化せず、通常の `COperationResult` Failureとして返す。

---

## 21.1 Write開始前Runtime Error

```text
UnexpectedError
Target = VariableDefinition
```

として返す。

Writeは開始しない。

---

## 21.2 Write開始後Runtime Error

即座に処理を停止する。

```text
No Further Write
Failure Result
```

既に完了したWriteはRollbackしない。

Error Messageには、Partial Updateの可能性を判断できる情報を含める。

例：

```text
VariableDefinition persistence failed after writing started.
The table may be partially updated.
Run synchronization again from the current workbook state.
```

P2-03自身はMessageを表示しない。

---

# 22. Retry Rule

Runtime FailureによってPartial Writeの可能性が生じた場合、**同一 `SyncDiffResult` をそのまま再適用してはならない。**

再試行時は、

```text
Template Scan
↓
Current VariableDefinitions再取得
↓
BuildSyncDiff
↓
新しいSyncDiffResult
↓
ApplySyncDiff
```

とし、現在状態からManual Syncを最初から再構築する。

これはRollbackなし、およびNew Conflict / Existing Missing Guardを採用したBoundaryから導かれるRecovery Ruleである。

---

# 23. No Production Read Back

正常Write完了後に、

```text
Excel再読込
↓
Expected vs Actual比較
```

をProduction処理では行わない。

Runtime Errorが発生しなければPersistence Successとする。

Persisted StateのExpected / Actual比較はImplementation Verification側で実施する。

---

# 24. Private Procedure Structure

Production実装では、Public API以外をPrivateへ閉じる。

推奨構造：

```text
Public
└─ ApplySyncDiff

Private
├─ GetVariableDefinitionTable
├─ ResolveVariableDefinitionColumns
├─ BuildExistingRowMap
├─ ValidateSyncDiffStructure
├─ ValidateDiffItems
├─ ValidateDiffItem
├─ ValidateCurrentState
├─ ApplyExistingItems
├─ WriteExistingMetadata
├─ AppendNewItems
└─ WriteNewRow
```

必要に応じて小規模なHelper統合は許可する。

ただしPublic APIを増やさない。

---

# 25. Private Data Structures

新しいClassは作成しない。

必要な内部Lookupにはlate-bound `Scripting.Dictionary`を使用可能とする。

```vb
CreateObject("Scripting.Dictionary")
```

VariableName Lookup：

```text
CompareMode = vbTextCompare
```

Column Lookup：

```text
Key   = Column Name
Value = ListColumn Index
```

Row Lookup：

```text
Key   = VariableName
Value = Internal ListRow Index
```

とする。

---

# 26. Detailed Pseudocode

```text
Function ApplySyncDiff(syncDiffResult)

    writeStarted = False

    1. Validate syncDiffResult structure
       Failure → Return

    2. Resolve tblVariableDefinition
       Failure → Return

    3. Resolve all required columns
       Failure → Return

    4. Build ExistingRowMap
       Detect case-insensitive duplicate
       Failure → Return

    5. Validate all Diff Items
       - Required keys
       - VariableName syntax
       - Location domain
       - Status domain
       - Date validity
       - Classification invariant
       - Cross-class duplicate
       Failure → Return

    6. Validate table current state
       - New must not exist
       - Existing must exist
       - Reactivated must exist
       - Unused must exist
       - Existing canonical name must match
       Failure → Return

    -------------------------
    All Preflight PASS
    -------------------------

    writeStarted = True

    7. Persist Existing
    8. Persist Reactivated
    9. Persist Unused
    10. Append New

    Return Success

EH:
    Stop immediately

    If writeStarted Then
        Return UnexpectedError
        Message includes partial-update warning
    Else
        Return UnexpectedError
    End If

End Function
```

---

# 27. Explicit Prohibitions

Production P2-03へ以下を実装してはならない。

```text
ScanTemplate()
BuildSyncDiff()
Get SyncTimestamp
Now()
Date()
Time()

Classification recalculation
Rename inference
Canonical VariableName recalculation
Metadata meaning recalculation

Manual Sync orchestration
MsgBox
UserForm access
Sync result notification

Excel Sort
Excel Filter
Select / Activate

Rollback
Transaction emulation
Temporary backup table
Snapshot restore

Post-write production verification

Test-only Public API
```

---

# 28. Implementation Verification Strategy

P2-03ではFormal MVP TestではなくImplementation Verificationを行う。

MVP Test Specification上では、P2-03が主に支える正式Test Areaは `MTS-SYNC-002～007` および `MTS-SYNC-011` である。

Formal PASSはTest Candidate Build確定後に別途判定する。

---

# 29. Core Verification Cases

## C01 — New / Empty Table

Precondition：

```text
tblVariableDefinition = 0 rows
```

Input：

```text
New = GateDate
```

Expected：

```text
1 Row追加

VariableName     = GateDate
TemplateLocation = Target
Status           = Active
FirstDetectedAt  = Target Date
LastDetectedAt   = Target Date

User Configuration:
All Blank
```

---

## C02 — New / Existing Table

既存行を変更せずNewを末尾追加できること。

---

## C03 — Multiple New

3件以上のNewを入力し、Collection順に末尾追加されること。

---

## C04 — Existing

Expected：

```text
VariableName
→ unchanged

User Configuration
→ unchanged

Metadata 4 Fields
→ Target Stateへ更新
```

---

## C05 — Existing Case Insensitive Identity

Table：

```text
ModelName
```

P2-02 Target：

```text
ModelName
```

Scanner側入力が異なるCaseだった履歴を持っていても、P2-02 Canonical NameをPersistence Identityとして正常に扱えること。

---

## C06 — Reactivated

Expected：

```text
Status = Active
Metadata = Target
User Configuration = preserved
```

---

## C07 — Unused

Expected：

```text
Status = Unused
Metadata = P2-02 Target
User Configuration = preserved
Row deletion = NONE
```

---

## C08 — Mixed Classification

Input：

```text
Existing    1
Reactivated 1
Unused      1
New         2
```

Expected Target StateへすべてPersistenceされること。

---

## C09 — Zero Target

全Collection = 0。

Expected：

```text
Success = True
Excel Write = 0
```

---

## C10 — Date Persistence

Expected：

```text
FirstDetectedAt / LastDetectedAt
= Excel Date Value

String化されていない
```

---

## C11 — User Configuration Preservation

Existing / Reactivated / Unusedの全User Configuration FieldについてBefore / After完全一致を確認する。

---

## C12 — Existing VariableName Preservation

Existing系のVariableName CellがWriteされていないことを確認する。

---

# 30. Negative Verification Cases

## N01 — syncDiffResult Nothing

```text
Failure
Write = 0
```

---

## N02 — Classification Missing

例：

```text
Reactivated key missing
```

Expected：

```text
Failure
Write = 0
```

---

## N03 — Diff Item Required Field Missing

例：

```text
LastDetectedAt missing
```

Expected：

```text
Failure
Write = 0
```

---

## N04 — Invalid VariableName

例：

```text
1Model
Model-Name
```

Expected：

```text
Failure
Write = 0
```

---

## N05 — Invalid TemplateLocation

例：

```text
Header
```

Expected：

```text
Failure
Write = 0
```

---

## N06 — Invalid Status

例：

```text
Enabled
```

Expected：

```text
Failure
Write = 0
```

---

## N07 — Classification / Status Conflict

例：

```text
Unused
+
Status = Active
```

Expected：

```text
Failure
No correction
Write = 0
```

---

## N08 — Invalid Timestamp

Blank / non-Date。

Expected：

```text
Failure
Write = 0
```

---

## N09 — Cross-class Duplicate

例：

```text
New       ModelName
Existing  MODELNAME
```

Expected：

```text
Failure
Write = 0
```

---

## N10 — Table Missing

`tblVariableDefinition`不存在。

Expected：

```text
ConfigurationError
Write = 0
```

---

## N11 — Required Column Missing

例：

```text
LastDetectedAt Column Missing
```

Expected：

```text
ConfigurationError
Write = 0
```

---

## N12 — Existing Table Duplicate

```text
ModelName
modelname
```

Expected：

```text
ConfigurationError
Write = 0
```

---

## N13 — New Conflict

Diff：

```text
New = GateDate
```

Table：

```text
GateDate exists
```

Expected：

```text
Failure
No reclassification
Write = 0
```

---

## N14 — Existing Missing

Existing Itemに対応する行なし。

Expected：

```text
Failure
No New row
Write = 0
```

---

## N15 — Reactivated Missing

Expected：

```text
Failure
No New row
Write = 0
```

---

## N16 — Unused Missing

Expected：

```text
Failure
No Skip
Write = 0
```

---

## N17 — Canonical Name Conflict

Table：

```text
ModelName
```

Diff：

```text
MODELNAME
```

Expected：

```text
Case-insensitive row lookup succeeds
Canonical consistency check fails
Write = 0
```

---

## N18 — Runtime Write Failure

Production CodeへTest Hookを追加せず、Workbook側を制御してExcel Write Errorを誘発する。

例：

```text
Worksheet / TableをWrite不可状態にする
```

Expected：

```text
ApplySyncDiff = Failure
以降のWrite停止
Rollbackなし
```

Runtime FailureがWrite開始後に発生した場合、Partial Write可能性をError Messageで確認する。

---

# 31. Compatibility Verification

## K1 — P2-02 Contract Compatibility

実Production：

```text
modSyncEngine.BuildSyncDiff
        ↓
SyncDiffResult
        ↓
modVariableDefinitionData.ApplySyncDiff
```

追加変換Adapterなしで接続できること。

---

## K2 — Existing VariableDefinition Read Regression

P2-03 Production変更後も既存：

```text
GetAllVariableDefinitions
GetActiveVariableDefinitions
```

が従来Contractを維持すること。

P2-03追加によりRead APIのCarrier Shapeを変更してはならない。

---

## K3 — P2-02 No Reopen

P2-03成立のために以下を変更していないこと。

```text
BuildSyncDiff Signature
SyncDiffResult Shape
Classification
Metadata Meaning
Canonical Rule
SyncTimestamp Contract
```

Expected：

```text
P2-02 Production Change Required = NONE
```

---

# 32. Static Production Review

Production Patch Reviewで少なくとも以下を確認する。

```text
S01 Public ApplySyncDiff = 1本
S02 Test-only Public API = NONE
S03 New Production Module = NONE
S04 Now / Date / Time Acquisition = NONE
S05 BuildSyncDiff Call = NONE
S06 ScanTemplate Call = NONE
S07 Rename Inference = NONE
S08 Classification Recalculation = NONE
S09 Existing User Configuration Write = NONE
S10 Existing VariableName Write = NONE
S11 New User Configuration Default = NONE
S12 Post-write Read Back = NONE
S13 Rollback Logic = NONE
S14 MsgBox / UserForm Dependency = NONE
S15 Select / Activate = NONE
S16 Sort / Filter Manipulation = NONE
S17 Case Insensitive Row Lookup = PRESENT
S18 Preflight-before-write = PRESENT
S19 Runtime Failure Stop = PRESENT
S20 Excel ListObject dependency remains Data Access internal
```

---

# 33. Evidence to Record

Implementation Verification時に以下を記録する。

```text
VBA Compile Result
Production Artifact Name
Public API
C01-C12 Result
N01-N18 Result
K1-K3 Result
Static Review S01-S20
Finding List
Blocking Finding Count
Production Patch Review Result
```

Before / After Stateが重要なケースでは、少なくとも以下をEvidenceとして残す。

```text
VariableName
User Configuration
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
Row Count
```

---

# 34. Production Artifact Naming

初回Candidate：

```text
modVariableDefinitionData_P2-03_v0.1.bas
```

CP932 Exportが必要な運用では、

```text
modVariableDefinitionData_P2-03_v0.1_CP932.bas
```

をProduction Verification Artifactとする。

修正が発生した場合：

```text
v0.1.1
v0.1.2
...
```

とし、同一Artifact名への無記録上書きを避ける。

---

# 35. Finding Handling

Verification / Review中にFindingを検出した場合、以下へ分類する。

```text
Production Defect
Test Artifact Defect
Specification Ambiguity
Requirement Gap
Design Conflict
Non-blocking Observation
```

Requirement / Designに新しい利用者向け振る舞いが必要になった場合、P2-03内で独自決定しない。

```text
Requirement Gap
→ Implementation Stop
→ 上位文書へEscalate
```

ただしP2-03内部のPrivate Helper分割や局所的コード修正は、Boundaryを変更しない限りImplementation Detailとして扱う。

---

# 36. Completion Criteria

P2-03を `PASS / COMPLETE` とする条件：

```text
P2-03 Boundary Confirmation                PASS
P2-03 Approved Unit Specification          PASS
VBA Compile                                PASS
ApplySyncDiff Production Implementation    PASS

Core Verification
C01-C12                                    ALL PASS

Negative Verification
N01-N18                                    ALL PASS

Compatibility
K1-K3                                      ALL PASS

Static Production Review
S01-S20                                    ALL PASS

Existing Data Access Regression            PASS
Finding Assessment                         PASS
Production Patch Review                    PASS

Blocking Finding                           0
Requirement Gap                            0
Design Conflict                            0

Baseline Impact Assessment                 COMPLETE
```

Completion後も、

```text
P2-03 COMPLETE
≠
P2 Phase COMPLETE
≠
CP-P2 ESTABLISHED
```

とする。

---

# 37. Cross-document Impact Assessment

本仕様は、確定済みBoundaryをImplementation Detailへ展開したものである。

現時点のImpact判定：

```text
MVP Requirements v0.1.9
→ Change NOT REQUIRED

MVP Design v0.1.9
→ Change NOT REQUIRED

MVP Test Specification v0.1.5
→ Change NOT REQUIRED

Implementation Plan v0.3
→ Change NOT REQUIRED

P2-02 Sync Diff Core
→ Reopen NOT REQUIRED

BL-MVP-003
→ Change NOT REQUIRED
```

P2-03のImplementation VerificationはFormal `MTS-SYNC-* PASS`ではない。

正式MVP Testでは、New追加、Existing設定保持、Unused、Reactivated、Rename、Case Insensitive、Metadata更新等が既存Test Caseとして定義済みである。

---

# 38. Implementation Start Gate

本仕様がApprovedになるまではProduction実装を正式開始しない。

Implementation Start条件：

```text
Boundary Confirmation
CONFIRMED

Implementation Unit Specification
APPROVED

Cross-document Consistency Review
PASS

Blocking Specification Finding
0
```

---

# 39. Next Action

本Candidate作成後の正式アクション：

```text
P2-03 VariableDefinition Sync Persistence
実施仕様 v0.1
Cross-document Consistency Review
        ↓
Finding対応
        ↓
実施仕様 v0.1 Approved
        ↓
Production Implementation
```

---

# 40. Summary

## 日本語

P2-03では、P2-02が生成した `SyncDiffResult` を `modVariableDefinitionData.ApplySyncDiff()` により `tblVariableDefinition`へPersistenceする。

全Preflight完了前にはExcelを書き換えない。

P2-03はClassification、Canonical VariableName、SyncTimestamp、Rename、Metadata Meaningを再計算しない。

Existing / Reactivated / UnusedではUser ConfigurationおよびVariableNameを保持し、自動Metadata 4 FieldのみをTarget StateでPersistenceする。

NewではTable末尾へRowを追加し、自動MetadataをPersistenceするとともにUser ConfigurationをBlank状態とする。

Runtime Failureに対するRollbackは実装せず、Partial Write可能性を既知制約とする。再試行時には同一SyncDiffResultを再利用せず、Current StateからManual Syncを再構築する。

本UnitではImplementation Verificationを実施するが、Formal MVP Testとはしない。

## English

P2-03 persists the `SyncDiffResult` produced by P2-02 into `tblVariableDefinition` through `modVariableDefinitionData.ApplySyncDiff()`.

No Excel write starts until the entire preflight succeeds.

P2-03 does not recalculate classification, canonical variable names, sync timestamps, rename semantics, or metadata meaning.

For Existing, Reactivated, and Unused variables, the VariableName and user configuration are preserved while the four automatic metadata fields are persisted from the target state.

For New variables, a new row is appended and user configuration remains blank.

Rollback is not implemented. A runtime failure after writing starts may leave a partial update. A retry must rebuild the synchronization from the current workbook state rather than reusing the stale SyncDiffResult.

P2-03 verification is implementation verification and does not constitute a formal MVP test pass.