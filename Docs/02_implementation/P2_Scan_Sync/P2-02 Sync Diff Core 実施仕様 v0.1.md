# P2-02 Sync Diff Core 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-02 Sync Diff Core 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Draft / Cross-document Consistency Review Pending |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P2 Scan / Sync |
| 対象Implementation Unit | P2-02 Sync Diff Core |
| Primary Production Module | `modSyncEngine` |
| 前提Implementation Unit | P2-01 Full Template Scanner = PASS / COMPLETE |
| Primary Verification | Sync Diff Core C1-C18 |
| 後続Implementation Unit | P2-03 VariableDefinition Sync Persistence |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `BL-MVP-003 Baseline Approval Record v0.1`
- `P2-01 Full Template Scanner Completion Record v0.1`
- `P2-02 Sync Diff Core Boundary Confirmation v0.1`

### v0.1 作成概要

`P2-02 Sync Diff Core Boundary Confirmation v0.1` で確定した責務境界を、Production実装可能なImplementation Detailへ具体化する。

本仕様では以下を定義する。

1. Production `modSyncEngine` を追加する
2. `BuildSyncDiff()` Public APIを定義する
3. `TemplateScanResult + Current VariableDefinitions + SyncTimestamp` を入力とする
4. `SyncDiffResult` の具体的Carrier構造を定義する
5. Case Insensitive Identity比較用Internal Dictionaryを定義する
6. New / Existing / Reactivated / Unusedの分類アルゴリズムを定義する
7. Already-UnusedをNo-opとする
8. Canonical VariableName Ruleを実装へ落とす
9. Target Metadata計算規則を実装へ落とす
10. P2-02内部で `Now` を呼び出さない
11. Input Carrierを変更しない
12. Excel / Outlook / Word COMへ依存しない
13. C1-C18 Core Verificationを定義する
14. P2-03が再判定なしでPersistenceできるOutput Boundaryを成立させる

本仕様は新しいRequirement / Design Decision / Test Definitionを追加しない。

```text
Change Type:
Implementation Detail / Unit Specification

Requirement Impact:
None

Design Impact:
None

Test Specification Impact:
None

Baseline Impact:
None

Technical Spike Reopen:
Not Required
```

---

# 2. 目的

P2-02の目的は、Production Architecture上で以下のCore Logic Boundaryを成立させることである。

```text
P2-01 Full Template Scanner
        ↓
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations

Current VariableDefinitions
└─ Collection of Dictionary

SyncTimestamp
        ↓
────────────────────────────────
modSyncEngine
BuildSyncDiff()
────────────────────────────────
        ↓
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

P2-02では、

> **現在のTemplate状態とVariableDefinition状態から、どのVariableをどのTarget Metadataへ反映すべきかを、Excel非依存のCore Logicとして決定すること**

を確認する。

P2-02単体では、

```text
Excel Table書込み
New行追加
既存行更新
Manual Sync Orchestration
Sync Result UI
Fail Closed UI
```

までは完成させない。

---

# 3. Baseline上の根拠

## 3.1 Requirement

`DOC-MVP-REQ` ではTemplate Syncについて以下が要求されている。

```text
VariableName比較
→ Case Insensitive

Templateあり / Definitionなし
→ New

Templateあり / Definitionあり
→ Existing

Definitionあり / Templateなし
→ 削除せずUnused

UnusedがTemplateへ再登場
→ Reactivated

Rename
→ 自動推測しない
→ Old Unused + New

Existing設定
→ Syncで上書きしない

Existing VariableName表記
→ VariableDefinition側を正式表記として保持
```

P2-02ではこれらをCore Diff Logicとして成立させる。

## 3.2 Design

`DOC-MVP-DES` ではSync Engineを以下のSet比較として定義している。

```text
Template Dictionary A
VariableDefinition Dictionary B
```

両Dictionary：

```text
CompareMode = vbTextCompare
```

Design上の状態遷移：

| Template | VariableDefinition | Current Status | 判定 |
|---|---|---|---|
| あり | なし | - | New |
| あり | あり | Active | Existing |
| あり | あり | Unused | Reactivated |
| なし | あり | Active | Unused化 |
| なし | あり | Unused | 変更なし |

MetadataについてもNew / Existing / Reactivated / Unusedの更新規則が確定済みである。

## 3.3 Test Specification

`DOC-MVP-TESTSPEC` の関連Test Area：

```text
MTS-SYNC-002 New追加
MTS-SYNC-003 Existing設定保持
MTS-SYNC-004 Unused化
MTS-SYNC-005 Reactivated
MTS-SYNC-006 Rename
MTS-SYNC-007 Case Insensitive既存照合 / 正式表記保持
MTS-SYNC-011 Sync metadata更新
```

P2-02 VerificationはFormal Test Resultではない。

上記Test Caseへ接続可能なProduction LogicをImplementation Verificationとして成立させる。

## 3.4 Implementation Plan

`DOC-MVP-IMPL` のP2 Sync Engine Scope：

```text
New
Existing
Reactivated
Unused
Rename = Old Unused + New
TemplateLocation
FirstDetectedAt
LastDetectedAt
SyncTimestamp
Existingユーザー設定維持
```

P2-02はこのうち、

```text
Diff Classification
+
Target Metadata Calculation
```

を担当する。

---

# 4. 前提Implementation Boundary

## 4.1 P2-01 Full Template Scanner Contract

P2-01で以下が成立済みである。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Result：

```text
scanResult
├─ ValidVariables
│   └─ Collection
├─ InvalidCandidates
│   └─ Collection
└─ Locations
    └─ Scripting.Dictionary
       CompareMode = vbTextCompare
       VariableName → Subject / Body / Both
```

Structural Invariant：

```text
Locations.Count = ValidVariables.Count
ValidVariables全件にLocationsあり
Locations全KeyがValidVariablesへ対応
Case違いによる重複なし
Invalid CandidateはLocationsへ混入しない
```

P2-02はこのContractを変更しない。

## 4.2 VariableDefinition Data Access Contract

P0で以下が成立済みである。

```vb
GetAllVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
```

各Item：

```text
Dictionary
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

P2-02では、

```text
__RowIndex
```

を使用しない。

P2-02はExcel物理位置へ依存しない。

---

# 5. Scope

P2-02 Production Scope：

```text
modSyncEngine
├─ BuildSyncDiff()
├─ Input Contract Validation
├─ Template Identity Index
├─ Current Definition Identity Index
├─ Case Insensitive Lookup
├─ Canonical VariableName決定
├─ New判定
├─ Existing判定
├─ Reactivated判定
├─ Unused判定
├─ Already-Unused No-op
├─ Rename非推測
├─ Target Metadata計算
├─ SyncDiffResult生成
├─ COperationResult返却
└─ Unexpected Runtime Error変換
```

Verification Scope：

```text
Core Test C1-C18
+
Static Responsibility Review
+
VBA Compile
```

---

# 6. Out of Scope

P2-02では以下を実装しない。

```text
Worksheet / ListObject / ListRow操作
VariableDefinitionへのWrite
New行物理追加
既存行Cell更新
modVariableDefinitionData Write API
Manual Sync Button
modSyncApplication完成
OFT Path取得
OFT存在確認
Outlook Readiness
MailItem生成
Subject / BodyText取得
Template Scan再実装
Invalid Candidate UI
Sync Result UI
MsgBox
Unused確認UI
Configuration Validator
UserForm
Final Error Taxonomy
Final Error Code
Formal MVP Test
```

P2-02のためだけに以下を追加しない。

```text
CSyncDiffResult
CSyncDiffItem
ISyncEngine
Sync Repository
Clock Interface
Persistence Adapter
```

MVPではCollection / late-bound Dictionaryを使用する。

---

# 7. Responsibility Boundary

## 7.1 Production Boundary

```text
Caller
│
├─ templateScanResult As Object
├─ currentDefinitions As Collection
└─ syncTimestamp As Date
        │
        ▼
────────────────────────────────
Core Logic Boundary
────────────────────────────────
        │
        ▼
modSyncEngine.BuildSyncDiff()
        │
        ├─ Input Contract Validation
        ├─ Case Insensitive Identity
        ├─ Diff Classification
        ├─ Canonical Name Resolution
        └─ Target Metadata Calculation
        │
        ▼
COperationResult
+
syncDiffResult As Object
```

## 7.2 Scannerとの責任分離

```text
modTemplateScanner
= Template文字列からVariable / Invalid / Locationを抽出

modSyncEngine
= Scan結果とCurrent Definitionを比較し差分を判定
```

P2-02はRegexでTemplateを再Scanしない。

P2-02はSubject / BodyTextを入力として受け取らない。

## 7.3 Data Accessとの責任分離

```text
modVariableDefinitionData
= Excel Tableを読み書きするInfrastructure

modSyncEngine
= Excel非依存で差分とTarget Stateを計算するCore Logic
```

P2-02は `__RowIndex` を使用しない。

## 7.4 P2-03との責任分離

```text
P2-02
What should change?
        ↓
SyncDiffResult
        ↓
P2-03
Persist the decided changes.
```

P2-03は、

```text
Classification
Canonical Name
Metadata Rule
SyncTimestamp
```

を再判定しない。

---

# 8. Production Module

Production Module：

```text
modSyncEngine
```

標準Moduleとして追加する。

理由：

- Design上Core Logicである
- Module Stateを保持する必要がない
- Excel / Outlook / Word COM非依存
- P1 / P2 Scannerと同じ軽量Standard Module構成に整合
- 専用Classを追加する必要性がない

想定Production Artifact：

```text
modSyncEngine_P2-02_v0.1_CP932.bas
```

最終Production File名は実装時のCorrection有無に応じてRevisionを上げてよい。

---

# 9. Public API

## 9.1 API

P2-02 Production Public API：

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

Public APIはP2-02では1本とする。

## 9.2 Input

### templateScanResult

P2-01 Full `TemplateScanResult`。

Expected Keys：

```text
ValidVariables
InvalidCandidates
Locations
```

### currentDefinitions

Current VariableDefinition全件。

```text
Collection
└─ Dictionary
```

ActiveのみではなくUnusedも含む。

### syncTimestamp

Callerが1 Syncにつき1回取得したTimestamp。

P2-02はこの値をそのままTarget Metadata計算へ使用する。

## 9.3 Output

`syncDiffResult` はlate-bound `Scripting.Dictionary` とする。

構造：

```text
syncDiffResult
├─ "New"         → Collection
├─ "Existing"    → Collection
├─ "Reactivated" → Collection
└─ "Unused"      → Collection
```

`Already-Unused` Keyは持たない。

## 9.4 COperationResult

戻り値は既存 `COperationResult` とする。

概念：

```text
Diff生成成功
→ Success = True
→ syncDiffResult = 非Nothing

Input / Configuration Failure
→ Success = False
→ syncDiffResult = Nothing

Unexpected Runtime Error
→ Success = False
→ syncDiffResult = Nothing
```

Diffが0件でもSuccessとする。

---

# 10. SyncDiffResult Carrier

## 10.1 Top-level Dictionary

生成：

```vb
Set syncDiffResult = CreateObject("Scripting.Dictionary")
syncDiffResult.CompareMode = vbTextCompare
```

固定Key：

```text
New
Existing
Reactivated
Unused
```

各Valueは `Collection` とする。

## 10.2 Collection

各Classificationは順序付き一覧として `Collection` を使用する。

```text
syncDiffResult("New")
syncDiffResult("Existing")
syncDiffResult("Reactivated")
syncDiffResult("Unused")
```

専用Result Classは追加しない。

## 10.3 Diff Item Dictionary

各Collection Itemはlate-bound `Scripting.Dictionary` とする。

固定Key：

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

概念：

```text
Diff Item
├─ VariableName
├─ TemplateLocation
├─ Status
├─ FirstDetectedAt
└─ LastDetectedAt
```

各Diff Item：

```vb
item.CompareMode = vbTextCompare
```

とする。

## 10.4 Classification KeyをItemへ持たせない

Item自体には、

```text
Classification
Action
SyncType
```

等の重複Fieldを持たせない。

Classificationは所属Collectionによって一意に表現される。

理由：

- 同一情報の二重管理回避
- CollectionとItemの矛盾防止
- YAGNI

---

# 11. Output初期化規則

`BuildSyncDiff()` 開始時に必ず、

```vb
Set syncDiffResult = Nothing
```

とする。

Input ValidationおよびResult Carrier生成が成功した場合のみResultを設定する。

Failure時に以前のResultをCallerが誤再利用できないようにする。

Success時はDiff 0件でも、

```text
syncDiffResult <> Nothing

New.Count         = 0
Existing.Count    = 0
Reactivated.Count = 0
Unused.Count      = 0
```

を返す。

---

# 12. SyncDiffResult Contract

## 12.1 New Item

```text
VariableName
= Scanner初回検出表記

TemplateLocation
= Current Scan Location

Status
= Active

FirstDetectedAt
= SyncTimestamp

LastDetectedAt
= SyncTimestamp
```

## 12.2 Existing Item

```text
VariableName
= Existing VariableDefinition Canonical Name

TemplateLocation
= Current Scan Location

Status
= Active

FirstDetectedAt
= Existing value

LastDetectedAt
= SyncTimestamp
```

## 12.3 Reactivated Item

```text
VariableName
= Existing VariableDefinition Canonical Name

TemplateLocation
= Current Scan Location

Status
= Active

FirstDetectedAt
= Existing value

LastDetectedAt
= SyncTimestamp
```

## 12.4 Unused Item

```text
VariableName
= Existing VariableDefinition Canonical Name

TemplateLocation
= Existing value

Status
= Unused

FirstDetectedAt
= Existing value

LastDetectedAt
= Existing value
```

## 12.5 Already-Unused

Outputへ追加しない。

```text
No-op
```

---

# 13. Metadata Type Handling

`FirstDetectedAt` / `LastDetectedAt` のDictionary ValueはVariantとして保持される。

P2-02は、

```text
Existing value
```

を文字列化・再Formatせず、そのままTarget Itemへコピーする。

`SyncTimestamp`由来値はVBA `Date` 値のままItemへ設定する。

P2-02は日時表示Formatを決定しない。

P2-03はTarget StateをPersistenceする際にSemanticなTimestampを再計算しない。

---

# 14. Canonical VariableName

## 14.1 IdentityとCanonical Nameを分離

Identity比較：

```text
Case Insensitive
```

Canonical Name：

```text
Original Casingを保持
```

`LCase()` / `UCase()` した値をOutput VariableNameとして返さない。

## 14.2 New

Current VariableDefinitionに同一Identityがない。

Canonical：

```text
P2-01 Scanner初回検出表記
```

## 14.3 Existing

Current VariableDefinitionに同一Identityがあり、Status=Active。

Canonical：

```text
Existing VariableDefinition VariableName
```

## 14.4 Reactivated

Current VariableDefinitionに同一Identityがあり、Status=Unused。

Canonical：

```text
Existing VariableDefinition VariableName
```

## 14.5 Unused

Templateに存在せずCurrent DefinitionがActive。

Canonical：

```text
Existing VariableDefinition VariableName
```

---

# 15. Internal Dictionary

P2-02では少なくとも以下のInternal Dictionaryを使用する。

```text
templateIndex
currentIndex
```

必要に応じて、

```text
seenTemplate
```

を `templateIndex` と兼用してよい。

---

# 16. templateIndex

## 16.1 目的

P2-01 `ValidVariables` のIdentity LookupとStructural Validationに使用する。

## 16.2 構造

late-bound `Scripting.Dictionary`。

```vb
Set templateIndex = CreateObject("Scripting.Dictionary")
templateIndex.CompareMode = vbTextCompare
```

Key：

```text
Scanner VariableName
```

Value：

```text
Current Location
```

例：

```text
ModelName → Both
GateDate  → Subject
```

## 16.3 構築順

`ValidVariables` Collectionを先頭から順に走査する。

各Variableについて、

```text
Locations.Exists(variableName)
```

を確認する。

存在しない場合、P2-01 Contract違反としてTechnical Failureとする。

## 16.4 Duplicate

Case Insensitiveで同一Variableが `ValidVariables` に複数存在する場合、

```text
P2-01 Structural Invariant Violation
```

としてFailureとする。

P2-02で重複を黙って統合して上流Contract違反を隠さない。

---

# 17. currentIndex

## 17.1 目的

Current VariableDefinitionをVariableNameでCase Insensitive Lookupする。

## 17.2 構造

late-bound `Scripting.Dictionary`。

```vb
Set currentIndex = CreateObject("Scripting.Dictionary")
currentIndex.CompareMode = vbTextCompare
```

Key：

```text
Current Definition VariableName
```

Value：

```text
Current Definition Item Dictionary
```

## 17.3 Input順

`currentDefinitions` Collectionの先頭から順に構築する。

## 17.4 Duplicate Identity

以下を同一Identityとして扱う。

```text
ModelName
MODELNAME
modelname
```

Current VariableDefinitionにCase Insensitive重複が存在する場合、

```text
Ambiguous Current Definition
```

となるためBuildSyncDiffをFailureとする。

先頭行を自動採用しない。

---

# 18. Current Definition Required Fields

P2-02がClassification / Metadata計算に必要なField：

```text
VariableName
Status
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

以下はData Access Carrierに存在するが、P2-02のTarget計算には使用しない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
__RowIndex
```

ただしP2-02はInput Dictionaryからこれらを削除・変更しない。

---

# 19. Status Rule

P2-02が認識するCurrent Status：

```text
Active
Unused
```

比較はCase Insensitiveでよい。

Outputは正式表記として、

```text
Active
Unused
```

を使用する。

Current Statusが上記以外の場合、

```text
ConfigurationError
```

としてFailureとする。

P2-02が未知Statusを推測補正しない。

---

# 20. Location Rule

P2-01から受け取るCurrent Location：

```text
Subject
Body
Both
```

New / Existing / ReactivatedではCurrent Scan LocationをTargetへ使用する。

UnusedではCurrent Definitionの既存 `TemplateLocation` を保持する。

Already-Unusedでも既存値を保持しOutputしない。

P2-02はUnused化時にLocationを空欄へしない。

---

# 21. SyncTimestamp Rule

## 21.1 Caller Responsibility

Caller：

```text
SyncTimestamp = Now
```

を1回だけ取得する。

## 21.2 P2-02 Responsibility

P2-02は引数 `syncTimestamp` を、

```text
New.FirstDetectedAt
New.LastDetectedAt
Existing.LastDetectedAt
Reactivated.LastDetectedAt
```

へ使用する。

## 21.3 禁止事項

P2-02内で、

```vb
Now
Date
Time
Timer
```

等からSync時刻を再取得しない。

## 21.4 Testability

Core Verificationでは固定値を注入できる。

例：

```vb
syncTimestamp = DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0)
```

同一Sync内の全Timestampが完全一致することを確認する。

---

# 22. Classification Algorithm

## 22.1 全体

```text
Initialize Output
↓
Validate TemplateScanResult
↓
Build templateIndex
↓
Validate Current Definitions
↓
Build currentIndex
↓
Pass A:
Template-present Variablesを分類
↓
Pass B:
Template-absent Current Definitionsを分類
↓
Return Success
```

---

# 23. Pass A — Template-present Variables

`ValidVariables` をScanner順で走査する。

各 `templateVariableName`：

```text
currentIndex.Exists(templateVariableName)?
│
├─ No
│   ↓
│   New
│
└─ Yes
    ↓
    currentDefinition.Status?
    │
    ├─ Active
    │   ↓
    │   Existing
    │
    └─ Unused
        ↓
        Reactivated
```

Location：

```text
Locations(templateVariableName)
```

を使用する。

---

# 24. New Algorithm

条件：

```text
Template = Exists
Current Definition = Not Exists
```

生成Item：

```text
VariableName     = templateVariableName
TemplateLocation = currentLocation
Status           = Active
FirstDetectedAt  = syncTimestamp
LastDetectedAt   = syncTimestamp
```

追加先：

```text
syncDiffResult("New")
```

New判定時、他のCurrent Variableとの文字列類似度比較は行わない。

---

# 25. Existing Algorithm

条件：

```text
Template = Exists
Current Definition = Exists
Current Status = Active
```

生成Item：

```text
VariableName
= currentDefinition("VariableName")

TemplateLocation
= currentLocation

Status
= Active

FirstDetectedAt
= currentDefinition("FirstDetectedAt")

LastDetectedAt
= syncTimestamp
```

追加先：

```text
syncDiffResult("Existing")
```

User ConfigurationはItemへ追加しない。

---

# 26. Reactivated Algorithm

条件：

```text
Template = Exists
Current Definition = Exists
Current Status = Unused
```

生成Item：

```text
VariableName
= currentDefinition("VariableName")

TemplateLocation
= currentLocation

Status
= Active

FirstDetectedAt
= currentDefinition("FirstDetectedAt")

LastDetectedAt
= syncTimestamp
```

追加先：

```text
syncDiffResult("Reactivated")
```

---

# 27. Pass B — Template-absent Definitions

`currentDefinitions` をInput順で走査する。

各Current Definition：

```text
templateIndex.Exists(currentVariableName)?
│
├─ Yes
│   ↓
│   Pass Aで処理済み
│   → 何もしない
│
└─ No
    ↓
    Current Status?
    │
    ├─ Active
    │   ↓
    │   Unused
    │
    └─ Unused
        ↓
        Already-Unused / No-op
```

---

# 28. Unused Algorithm

条件：

```text
Template = Not Exists
Current Definition = Exists
Current Status = Active
```

生成Item：

```text
VariableName
= currentDefinition("VariableName")

TemplateLocation
= currentDefinition("TemplateLocation")

Status
= Unused

FirstDetectedAt
= currentDefinition("FirstDetectedAt")

LastDetectedAt
= currentDefinition("LastDetectedAt")
```

追加先：

```text
syncDiffResult("Unused")
```

Unused化時刻でLastDetectedAtを更新しない。

---

# 29. Already-Unused Algorithm

条件：

```text
Template = Not Exists
Current Definition = Exists
Current Status = Unused
```

処理：

```text
No-op
```

以下へ追加しない。

```text
New
Existing
Reactivated
Unused
```

Metadata変更Itemも生成しない。

---

# 30. Rename Non-Inference

例：

```text
Current:
PIC / Active

Template:
PersonInCharge
```

Algorithm結果：

```text
Pass A:
PersonInCharge
→ currentIndex不存在
→ New

Pass B:
PIC
→ templateIndex不存在
→ Unused
```

結果：

```text
New:
PersonInCharge

Unused:
PIC
```

以下を実装しない。

```text
Levenshtein Distance
Prefix / Suffix Match
類似度
過去履歴Match
1対1候補推測
```

---

# 31. Output Order

Public Requirementとして順序保証はしない。

ただしImplementation Verificationの再現性のため、P2-02では以下の決定的順序を採用する。

```text
New
Existing
Reactivated
→ ValidVariables内での相対順

Unused
→ currentDefinitions内での相対順
```

Classificationごとに別Collectionであるため、分類間の全体順序は定義しない。

この順序はImplementation Detailであり、User-facing表示順のRequirementではない。

---

# 32. Input Mutation禁止

P2-02はInput Carrierを変更しない。

禁止：

```text
templateScanResultへのAdd / Remove / Key更新
ValidVariables変更
InvalidCandidates変更
Locations変更
currentDefinitions Collection変更
Current Definition DictionaryのField更新
Status書換
Location書換
Timestamp書換
User Configuration書換
__RowIndex書換
```

Target Stateは必ず新しいDiff Item Dictionaryへ書き込む。

これにより、

```text
Read Model
+
Calculated Target State
```

を分離する。

---

# 33. User Configuration保護

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

P2-02 Output ItemにはこれらのKeyを含めない。

理由：

- Sync Engineが更新対象として扱わないことを構造的に保証する
- P2-03が誤ってUser Configurationを上書きする入力を受け取らない
- Existing / Reactivated / Unused設定保持を安全側へ寄せる

New行のUser Configuration初期化方式はP2-03責務とする。

---

# 34. Input Contract Validation

## 34.1 templateScanResult = Nothing

Expected：

```text
Failure
syncDiffResult = Nothing
```

Technical Caller / Contract Failureとして扱う。

## 34.2 Required Result Key不存在

以下のいずれかが存在しない場合：

```text
ValidVariables
InvalidCandidates
Locations
```

P2-01 Contract違反としてFailure。

## 34.3 InvalidCandidates > 0

P2-02通常Precondition違反。

```text
ConfigurationError
Target = InvalidCandidates
```

としてFailureを返してよい。

Invalid Candidateを分類しない。

## 34.4 Locations Structural Violation

以下はTechnical Contract Failure：

```text
ValidVariablesに対応Locationなし
Locations Count不整合
Case Insensitive Duplicate
未知Location
```

P2-02で黙って補正しない。

## 34.5 currentDefinitions = Nothing

Technical Caller / Contract FailureとしてFailure。

空Collectionは有効とする。

## 34.6 Current Definition VariableName

以下はConfiguration Failure：

```text
Key不存在
Null / Empty VariableName
Case Insensitive Duplicate
```

## 34.7 Current Definition Status

以下以外：

```text
Active
Unused
```

はConfiguration Failure。

---

# 35. Error / Result Mapping

P2-02ではProject全体のFinal Error Taxonomyを完成させない。

ただし既存Result Modelへ最低限変換する。

## 35.1 Configuration Failure

例：

```text
InvalidCandidates > 0
Duplicate VariableDefinition Identity
Unknown Status
Required Current Definition Field不足
```

基本Mapping：

```text
ErrorType = ConfigurationError
```

Target例：

```text
InvalidCandidates
VariableDefinition
```

User-facing最終MessageはP2-02で固定しない。

## 35.2 Internal Contract / Runtime Failure

例：

```text
P2-01 Structural Invariant違反
Scripting.Dictionary生成失敗
Collection操作Runtime Error
Result Carrier生成失敗
Unexpected Type Error
```

基本Mapping：

```text
ErrorType = UnexpectedError
Target = SyncEngine
```

## 35.3 Failure時Output

すべてのFailure：

```text
Set syncDiffResult = Nothing
```

とする。

---

# 36. Private Helper構成

推奨する最小Private Helper：

```vb
Private Function CreateSyncDiffResult( _
    ByRef syncDiffResult As Object _
) As COperationResult

Private Function BuildTemplateIndex( _
    ByVal templateScanResult As Object, _
    ByRef templateIndex As Object _
) As COperationResult

Private Function BuildCurrentIndex( _
    ByVal currentDefinitions As Collection, _
    ByRef currentIndex As Object _
) As COperationResult

Private Function CreateDiffItem( _
    ByVal variableName As String, _
    ByVal templateLocation As String, _
    ByVal status As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant, _
    ByRef diffItem As Object _
) As COperationResult

Private Function IsStatusActive( _
    ByVal statusValue As String _
) As Boolean

Private Function IsStatusUnused( _
    ByVal statusValue As String _
) As Boolean
```

実装時にHelperを細分化しすぎない。

以下のような1行Wrapperは不要。

---

# 37. Private Constants

`modConstants` は追加しない。

`modSyncEngine` 内Private Constとして最低限以下を配置してよい。

```vb
Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"
Private Const KEY_UNUSED As String = "Unused"

Private Const FIELD_VARIABLE_NAME As String = "VariableName"
Private Const FIELD_TEMPLATE_LOCATION As String = "TemplateLocation"
Private Const FIELD_STATUS As String = "Status"
Private Const FIELD_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const FIELD_LAST_DETECTED_AT As String = "LastDetectedAt"

Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"
```

Location値をValidationする場合のみ、

```text
Subject
Body
Both
```

のPrivate Constを追加する。

将来用共通定数Moduleを先回り追加しない。

---

# 38. Conceptual Algorithm

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult

    Set syncDiffResult = Nothing

    ' 1. Validate / build templateIndex
    ' 2. Validate / build currentIndex
    ' 3. Create empty SyncDiffResult

    ' Pass A:
    ' For Each variableName In ValidVariables
    '   If currentIndex.Exists(variableName) = False Then
    '       Add New
    '   Else
    '       Select Case current Status
    '           Active -> Add Existing
    '           Unused -> Add Reactivated
    '       End Select
    '   End If
    ' Next

    ' Pass B:
    ' For Each definition In currentDefinitions
    '   If templateIndex.Exists(definition("VariableName")) = False Then
    '       If Status = Active Then
    '           Add Unused
    '       ElseIf Status = Unused Then
    '           No-op
    '       End If
    '   End If
    ' Next

    ' Return Success

End Function
```

実装ではError HandlingとResult生成を既存 `modResult` へ接続する。

---

# 39. Structural Invariants

## 39.1 Classification Exclusivity

同一Variable Identityが同一Build結果で複数Classificationへ入ってはならない。

例外：

```text
Rename
```

はIdentity自体が異なるため、

```text
Old Variable = Unused
New Variable = New
```

として2件存在してよい。

## 39.2 Canonical Name

```text
New
→ Scanner表記

Existing
Reactivated
Unused
→ Existing Definition表記
```

## 39.3 Metadata

各Diff Itemは必ず以下5Keyを持つ。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

## 39.4 No User Configuration

Diff Itemに以下Keyを追加しない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

## 39.5 Already-Unused

Already-Unusedは4分類すべてに存在しない。

## 39.6 Input Immutability

BuildSyncDiff前後でInput Carrierの内容を変更しない。

---

# 40. Core Verification

## 40.1 Test Module

推奨Test Module：

```text
modP2_02SyncDiffCoreTest_v0.1_CP932.bas
```

Entry Point：

```vb
Public Sub TestP202SyncDiffCore()
```

Testは明示的なPASS / FAIL判定を使用する。

`Debug.Assert`停止後に処理継続して最終PASSへ到達するFalse Positiveを避ける。

## 40.2 Test Timestamp

共通Fixture：

```vb
syncTimestamp = DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0)
```

既存Timestamp Fixture例：

```text
T0 = 2026-09-01 09:00:00
T1 = 2026-09-20 10:00:00
```

実装上はDate値として生成する。

---

# 41. C1 — New

## Fixture

Template：

```text
ValidVariables:
GateOwner

Locations:
GateOwner = Body
```

Current Definitions：

```text
0件
```

## Expected

```text
New.Count         = 1
Existing.Count    = 0
Reactivated.Count = 0
Unused.Count      = 0
```

New Item：

```text
VariableName     = GateOwner
TemplateLocation = Body
Status           = Active
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

Result：

```text
PASS
```

---

# 42. C2 — Existing

## Fixture

Template：

```text
ModelName = Both
```

Current：

```text
VariableName     = ModelName
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

## Expected

```text
Existing.Count = 1
```

Item：

```text
VariableName     = ModelName
TemplateLocation = Both
Status           = Active
FirstDetectedAt  = T0
LastDetectedAt   = SyncTimestamp
```

他Classification：

```text
0件
```

---

# 43. C3 — Reactivated

## Fixture

Template：

```text
GateDate = Subject
```

Current：

```text
VariableName     = GateDate
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

## Expected

```text
Reactivated.Count = 1

VariableName     = GateDate
TemplateLocation = Subject
Status           = Active
FirstDetectedAt  = T0
LastDetectedAt   = SyncTimestamp
```

---

# 44. C4 — Unused

## Fixture

Template：

```text
0件
```

Current：

```text
VariableName     = Department
Status           = Active
TemplateLocation = Body
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

## Expected

```text
Unused.Count = 1

VariableName     = Department
TemplateLocation = Body
Status           = Unused
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

---

# 45. C5 — Already-Unused No-op

## Fixture

Template：

```text
0件
```

Current：

```text
VariableName     = Comment
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

## Expected

```text
New.Count         = 0
Existing.Count    = 0
Reactivated.Count = 0
Unused.Count      = 0
```

`Already-Unused` Key：

```text
NOT EXISTS
```

---

# 46. C6 — Case Insensitive Existing

## Fixture

Template：

```text
MODELNAME = Both
```

Current：

```text
VariableName = ModelName
Status       = Active
```

## Expected

```text
Existing.Count = 1
New.Count      = 0

VariableName = ModelName
```

Caseだけの違いでNewを生成しない。

---

# 47. C7 — Case Insensitive Reactivated

## Fixture

Template：

```text
GATEDATE = Body
```

Current：

```text
VariableName = GateDate
Status       = Unused
```

## Expected

```text
Reactivated.Count = 1
New.Count         = 0

VariableName = GateDate
Status       = Active
```

---

# 48. C8 — Existing Canonical Name Preservation

## Fixture

Template Scanner初回表記：

```text
mOdElNaMe
```

Current：

```text
VariableName = ModelName
Status       = Active
```

## Expected

```text
Classification = Existing
Output VariableName = ModelName
```

以下になってはならない。

```text
mOdElNaMe
modelname
MODELNAME
```

---

# 49. C9 — Rename = Old Unused + New

## Fixture

Template：

```text
PersonInCharge = Body
```

Current：

```text
PIC
Status = Active
```

## Expected

```text
New.Count    = 1
Unused.Count = 1
```

New：

```text
VariableName = PersonInCharge
```

Unused：

```text
VariableName = PIC
```

以下は存在しない。

```text
Rename
Renamed
MappedFrom
MappedTo
```

---

# 50. C10 — Mixed Classification

## Fixture

Template：

```text
ModelName = Both
GateDate = Subject
GateOwner = Body
```

Current：

```text
ModelName
Status = Active

GateDate
Status = Unused

Department
Status = Active

Comment
Status = Unused
```

## Expected

```text
New:
GateOwner

Existing:
ModelName

Reactivated:
GateDate

Unused:
Department
```

Comment：

```text
Already-Unused
→ No-op
```

Count：

```text
New         = 1
Existing    = 1
Reactivated = 1
Unused      = 1
```

---

# 51. C11 — New Metadata

## Fixture

New Variable：

```text
GateOwner
Location = Body
SyncTimestamp = TSync
```

## Expected

```text
VariableName     = GateOwner
TemplateLocation = Body
Status           = Active
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

Timestamp完全一致を確認する。

---

# 52. C12 — Existing Metadata

## Fixture

Current：

```text
VariableName     = ModelName
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

Template：

```text
ModelName = Both
```

## Expected

```text
TemplateLocation = Both
Status           = Active
FirstDetectedAt  = T0
LastDetectedAt   = SyncTimestamp
```

---

# 53. C13 — Reactivated Metadata

## Fixture

Current：

```text
VariableName     = GateDate
Status           = Unused
TemplateLocation = Subject
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

Template：

```text
GateDate = Both
```

## Expected

```text
TemplateLocation = Both
Status           = Active
FirstDetectedAt  = T0
LastDetectedAt   = SyncTimestamp
```

---

# 54. C14 — Unused Metadata

## Fixture

Current：

```text
VariableName     = Department
Status           = Active
TemplateLocation = Body
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

Template：

```text
Departmentなし
```

## Expected

```text
TemplateLocation = Body
Status           = Unused
FirstDetectedAt  = T0
LastDetectedAt   = T1
```

以下になってはならない。

```text
LastDetectedAt = SyncTimestamp
TemplateLocation = ""
```

---

# 55. C15 — Common SyncTimestamp

## Fixture

同一Buildに、

```text
New
Existing
Reactivated
```

を1件以上ずつ含める。

SyncTimestamp：

```text
TSync
```

## Expected

```text
New.FirstDetectedAt      = TSync
New.LastDetectedAt       = TSync
Existing.LastDetectedAt  = TSync
Reactivated.LastDetectedAt = TSync
```

すべて同一Date値。

P2-02内部時刻取得による差異がないことを確認する。

---

# 56. C16 — User Configuration Not In Update Target / Input Immutability

## Fixture

Current Existing Item：

```text
VariableName = ModelName
DisplayName  = 対象機種
Type         = Text
Required     = True
Description  = 機種名を入力
OptionSource = ""
SortOrder    = 10
Format       = ""
Status       = Active
```

## Expected A — Output Structure

Existing Diff Itemに以下Keyが存在しない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

## Expected B — Input Immutability

`BuildSyncDiff()` 実行後もCurrent Definition Itemの全値が実行前と一致する。

P2-02がInput DictionaryのStatus / Metadata / User Configurationを直接書換えていないことを確認する。

---

# 57. C17 — Empty Template / Existing Active → Unused

## Fixture

Template：

```text
ValidVariables.Count = 0
Locations.Count = 0
```

Current：

```text
ModelName / Active
GateDate / Active
```

## Expected

```text
New         = 0
Existing    = 0
Reactivated = 0
Unused      = 2
```

Unused順：

```text
ModelName
GateDate
```

Current Definition順を維持する。

---

# 58. C18 — Empty Template / Existing Unused → No-op

## Fixture

Template：

```text
ValidVariables.Count = 0
Locations.Count = 0
```

Current：

```text
Comment / Unused
Department / Unused
```

## Expected

```text
New         = 0
Existing    = 0
Reactivated = 0
Unused      = 0
```

Input Metadataは変更されない。

Result自体はSuccess。

---

# 59. C1-C18 Test Runner

推奨出力：

```text
P2-02 Sync Diff Core Test

C1  New                                           PASS
C2  Existing                                      PASS
C3  Reactivated                                   PASS
C4  Unused                                        PASS
C5  Already-Unused No-op                          PASS
C6  Case Insensitive Existing                     PASS
C7  Case Insensitive Reactivated                  PASS
C8  Existing Canonical Name Preservation          PASS
C9  Rename = Old Unused + New                     PASS
C10 Mixed Classification                          PASS
C11 New Metadata                                  PASS
C12 Existing Metadata                             PASS
C13 Reactivated Metadata                          PASS
C14 Unused Metadata                               PASS
C15 Common SyncTimestamp                          PASS
C16 User Config / Input Immutability               PASS
C17 Empty Template Active → Unused                PASS
C18 Empty Template Unused → No-op                 PASS

PASS Count:
18

FAIL Count:
0

Overall:
PASS
```

1件でもFAILの場合：

```text
Overall:
FAIL
```

最終PASSを出力しない。

---

# 60. Core Test Fixture Helper

Test Artifactでは必要最小限のFixture Helperを作成してよい。

例：

```vb
Private Function CreateScanResult( ... ) As Object
Private Function CreateDefinition( ... ) As Object
Private Sub AddValidVariable( ... )
Private Function DateValueAt( ... ) As Date
Private Function CheckDiffItem( ... ) As Boolean
```

Fixture HelperをProduction Moduleへ追加しない。

Test専用Public APIをProductionへ追加しない。

---

# 61. Technical Negative Verification

C1-C18とは別に、実装時Static / Technical確認として以下を確認する。

```text
templateScanResult = Nothing
→ Failure

currentDefinitions = Nothing
→ Failure

InvalidCandidates > 0
→ Failure

Current VariableDefinition Case Insensitive Duplicate
→ Failure

Unknown Status
→ Failure

P2-01 Structural Invariant Violation
→ Failure
```

これらをC1-C18へ追加して番号を増やすかは実装時に行わない。

C1-C18はApproved Core Verification Matrixとして維持する。

必要な追加Technical Testは `N1` 等の別IDとする。

---

# 62. Compile Evidence

Production導入後：

```text
Debug
→ Compile VBAProject
```

結果を記録する。

Expected：

```text
PASS
```

P2-02変更によってP2-01 / P1 ModuleのCompileを破壊しない。

---

# 63. Regression Scope

P2-02は新規 `modSyncEngine` を追加する。

原則としてP2-01 `modTemplateScanner` Production Codeは変更しない。

Required Regression：

```text
P2-01 Public API Preservation
P2-01 TemplateScanResult Contract Preservation
P0 GetAllVariableDefinitions Carrier Compatibility
```

P2-01 Scanner Core C1-C11の全再実行は、`modTemplateScanner` を変更しない限りP2-02 Completion必須とはしない。

Scanner変更が発生した場合はP2-01 Regression Scopeを再評価する。

---

# 64. P2-01 Contract Compatibility Verification

P2-02 Test Artifactで使用する `TemplateScanResult` FixtureはP2-01 Contractに一致させる。

少なくとも：

```text
ValidVariables
InvalidCandidates
Locations
```

をP2-01と同じCarrier Typeで生成する。

可能であればP2-01 Production `ScanTemplate()` の実Resultを1ケースP2-02へ入力し、Carrier互換性を確認する。

ただしこれはFormal OFT Integrationではない。

---

# 65. P0 VariableDefinition Carrier Compatibility

P0 `GetAllVariableDefinitions()` のItem Dictionaryが持つ、

```text
VariableName
Status
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

をP2-02が直接参照可能であることを確認する。

P2-02のためにData Access Read Contractを変更しない。

`__RowIndex` が存在しても無視する。

---

# 66. Production Hard Coding Rule

Production CodeへTemplate固有Variable名をHard Codingしない。

禁止例：

```vb
If variableName = "ModelName" Then
If variableName = "GateDate" Then
```

Test Fixtureでは使用可。

ProductionでHard CodingしてよいものはContract / Status Key等のみ。

例：

```text
New
Existing
Reactivated
Unused
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
Active
Unused
```

---

# 67. Binding Rule

`Scripting.Dictionary`：

```text
Late Binding
```

とする。

```vb
CreateObject("Scripting.Dictionary")
```

Microsoft Scripting Runtime参照設定を追加しない。

理由：

- P0 / P1 / P2-01方針との整合
- 配布先のReference依存回避

---

# 68. Excel / COM Independence

`modSyncEngine` Production Codeに以下を含めない。

```text
Worksheet
Workbook
ListObject
ListRow
Range
Outlook.Application
MailItem
Inspector
Word.Document
Word.Range
```

Core TestはExcel Table / Outlook起動なしで実行可能な構造とする。

---

# 69. Static Review Checklist

Production Patch Reviewでは少なくとも以下を確認する。

```text
[ ] Public APIはBuildSyncDiff 1本のみ
[ ] Excel Object依存なし
[ ] Outlook / Word COM依存なし
[ ] Late Bound Dictionary
[ ] CompareMode = vbTextCompare
[ ] Input Resultを変更しない
[ ] Current Definitionを変更しない
[ ] New Canonical = Scanner表記
[ ] Existing Canonical = Definition表記
[ ] Reactivated Canonical = Definition表記
[ ] Unused Canonical = Definition表記
[ ] Already-Unused = No-op
[ ] Rename推測なし
[ ] SyncTimestamp内部取得なし
[ ] New Metadata Rule一致
[ ] Existing Metadata Rule一致
[ ] Reactivated Metadata Rule一致
[ ] Unused Metadata Rule一致
[ ] User ConfigurationをOutputに含めない
[ ] __RowIndexを使用しない
[ ] Classification重複なし
[ ] Test専用Public APIなし
[ ] Production Variable Hard Codingなし
```

---

# 70. Finding Classification

## 70.1 Implementation Defect

既存Baseline / Boundary / Approved Specificationが明確で、実装が一致しない。

例：

```text
Case Insensitive比較にならない
ExistingをNewへ分類
Existing CanonicalをScanner表記へ変更
Unused LastDetectedAtをSyncTimestampへ更新
Already-UnusedをUnusedへ再出力
```

→ Production Patch候補。

## 70.2 Test Artifact Defect

Productionは正しいがTest Fixture / Expected / Path / Encoding等が誤っている。

→ Test Artifact Correction。

## 70.3 Requirement Gap

利用者から見た新しい振る舞いを決める必要がある。

→ Requirementsへ戻す。

Implementation都合で決めない。

## 70.4 Design Finding

Requirementは明確だが、責務・状態遷移・Metadata Ruleが既存Designで決定不能または矛盾する。

→ Design Review。

## 70.5 Technical Finding

既存方式では通常Implementation + Verificationでは遅すぎる重大Technical Riskが新規発生。

→ Technical Spike要否を再判定。

単なるVBA BugをSpikeへ昇格しない。

---

# 71. Cross-document Consistency Review対象

本v0.1をApproved化する前に以下と照合する。

```text
DOC-MVP-REQ
- FR-VAR-004
- FR-SYNC-001～008
- VariableDefinition要件

DOC-MVP-DES
- §7.4 自動管理列
- §11 Internal Data Structure
- §15 Sync Engine
- §25.1 Manual Sync

DOC-MVP-TESTSPEC
- MTS-SYNC-002～007
- MTS-SYNC-011

DOC-MVP-IMPL
- P2 Scan / Sync
- Sync Engine
- Phase Verification
- Exit Criteria

P2-01 Completion
- TemplateScanResult Contract

P2-02 Boundary Confirmation
- Input / Output
- Canonical
- 4 Classification
- Already-Unused
- SyncTimestamp
- Metadata
- P2-03 Boundary
```

Review観点：

```text
Semantic Conflict
Traceability Break
Scope Expansion
Requirement Gap
Design Finding
Test Definition Conflict
Baseline Change Need
Technical Spike Reopen Need
```

---

# 72. Verification PASS Criteria

以下をすべて満たす。

```text
VBA Compile:
PASS

C1-C18:
18 / 18 PASS

Case Insensitive Identity:
PASS

Canonical VariableName:
PASS

New:
PASS

Existing:
PASS

Reactivated:
PASS

Unused:
PASS

Already-Unused No-op:
PASS

Rename Non-Inference:
PASS

SyncTimestamp Injection:
PASS

Metadata Rules:
PASS

User Configuration Protection:
PASS

Input Immutability:
PASS

Excel Dependency:
NONE

Outlook / Word COM Dependency:
NONE

Production Variable Hard Coding:
NONE

Blocking Implementation Finding:
NONE

Blocking Requirement Gap:
NONE

Blocking Design Finding:
NONE

Blocking Technical Finding:
NONE
```

---

# 73. P2-02 Completion Criteria

P2-02 Completion条件：

```text
Approved Unit Specification
+
VBA Compile PASS
+
modSyncEngine Production Implementation
+
C1-C18 = 18 / 18 PASS
+
P2-01 Contract Compatibility PASS
+
P0 VariableDefinition Carrier Compatibility PASS
+
Production Patch Review PASS
+
Finding Assessment PASS
+
Blocking Finding = 0
```

成立後：

```text
P2-02 Sync Diff Core
PASS / COMPLETE
```

と判定可能。

ただし、

```text
P2-02 COMPLETE
≠
P2 Phase COMPLETE
≠
CP-P2 ESTABLISHED
```

である。

---

# 74. P2-03 Downstream Boundary

P2-02 Completion後の静的Boundary：

```text
TemplateScanResult
+
Current VariableDefinitions
+
SyncTimestamp
↓
BuildSyncDiff
↓
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
↓
P2-03 VariableDefinition Sync Persistence
```

P2-03は、

```text
New
→ 新規行追加

Existing
→ 自動管理列Update

Reactivated
→ 自動管理列Update

Unused
→ 自動管理列Update
```

を担当する。

P2-03はP2-02 Classificationを再計算しない。

---

# 75. API Contract Summary

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

Input：

```text
templateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations

currentDefinitions
└─ Collection of Dictionary

syncTimestamp
└─ Caller-generated Date
```

Output：

```text
syncDiffResult
├─ New         As Collection
├─ Existing    As Collection
├─ Reactivated As Collection
└─ Unused      As Collection
```

Each Item：

```text
Dictionary
├─ VariableName
├─ TemplateLocation
├─ Status
├─ FirstDetectedAt
└─ LastDetectedAt
```

---

# 76. Traceability Summary

| P2-02 Concern | Requirement / Design / Test接続 |
|---|---|
| Case Insensitive | FR-VAR-004 / FR-SYNC-001 / Design §15.1 / MTS-SYNC-007 |
| New | FR-SYNC-002 / Design §15.3 / MTS-SYNC-002 |
| Existing | FR-SYNC-003 / Design §15.4 / MTS-SYNC-003 |
| Unused | FR-SYNC-004 / Design §15.6 / MTS-SYNC-004 |
| Reactivated | FR-SYNC-005 / Design §15.5 / MTS-SYNC-005 |
| Rename | FR-SYNC-006 / Design §15.7 / MTS-SYNC-006 |
| Canonical Casing | FR-VAR-004 / Design §15.4 / MTS-SYNC-007 |
| Metadata | VariableDefinition Requirement / Design §7.4 / §15 / MTS-SYNC-011 |
| Common Timestamp | Design §7.4 / Implementation Plan P2 / MTS-SYNC-011 |
| Existing設定保持 | FR-SYNC-003 / Design §15.4 / MTS-SYNC-003 |
| Excel非依存Core | Design Component Boundary / Implementation Plan Module Mapping |
| Persistence分離 | Design §10 / §15 / §25.1 / P2-02 Boundary |

---

# 77. Approval Status

本v0.1はImplementation Detailを具体化したDraftである。

現時点：

```text
P2-02 Sync Diff Core 実施仕様 v0.1

Status:
Draft

Cross-document Consistency Review:
NOT YET EXECUTED

Production Coding:
NOT YET STARTED
```

次に、

```text
P2-02 Sync Diff Core 実施仕様 v0.1
Cross-document Consistency Review
```

を実施する。

Review PASS後にApproved化し、その後Production Codingへ進む。

---

# 78. Next Action

```text
P2-02 Sync Diff Core 実施仕様 v0.1
↓
Cross-document Consistency Review
↓
必要Correction
↓
Approved
↓
modSyncEngine Production Implementation
↓
VBA Compile
↓
C1-C18 Core Verification
↓
Finding Assessment
↓
Production Patch Review
↓
Completion Record
```

Consistency Review前にProduction Codingを開始しない。
