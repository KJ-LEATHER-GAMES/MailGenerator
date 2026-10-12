# P2-02 Sync Diff Core Boundary Confirmation v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-02 Sync Diff Core Boundary Confirmation |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Boundary Confirmation |
| Status | Confirmed |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P2 Scan / Sync |
| 対象Implementation Unit | P2-02 Sync Diff Core |
| 前提Implementation Unit | P2-01 Full Template Scanner = PASS / COMPLETE |
| Primary Production Module | `modSyncEngine` |
| 次Implementation Unit | P2-03 VariableDefinition Sync Persistence |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `BL-MVP-003 Baseline Approval Record v0.1`
- `P2-01 Full Template Scanner Completion Record v0.1`

---

## 2. 目的

P2-02の目的は、P2-01で成立したFull `TemplateScanResult` と、現在の `VariableDefinition` を比較し、Variableごとの差分をCore Logicとして判定できる境界を確定することである。

P2-02では以下を固定する。

```text
Input
Output
Canonical VariableName
New / Existing / Reactivated / Unused の4分類
Already-Unusedの扱い
SyncTimestamp責務
Metadata計算範囲
P2-03 VariableDefinition Sync Persistenceとの責務境界
```

P2-02ではExcel Tableへの書込みを行わない。

P2-02完了時点で、

> TemplateScanResultとCurrent VariableDefinitionsから、VariableDefinitionへ何を反映すべきかを、Excel非依存のCore Logicとして決定できること

を成立させる。

---

## 3. Baseline上の根拠

### 3.1 Requirement

`DOC-MVP-REQ` ではTemplate Syncについて以下を要求している。

- VariableName比較はCase Insensitive
- Templateに存在しVariableDefinitionに存在しないVariableはNew
- TemplateとVariableDefinition双方に存在するVariableはExisting
- 既存ユーザー設定をSyncで上書きしない
- Templateから消えた既存Active Variableは削除せずUnused
- Unused Variableが再登場した場合はReactivated
- Renameを自動推測しない
- RenameはOld Unused + New
- Existing VariableDefinitionがある場合、そのVariableName表記を正式表記として保持する

### 3.2 Design

`DOC-MVP-DES` ではSync Engineについて以下を定義している。

```text
Template Dictionary A
VariableDefinition Dictionary B
```

両DictionaryはCase Insensitiveとする。

Design上の判定は以下である。

| 条件 | Design上の判定 |
|---|---|
| Aにあり / Bになし | New |
| Aにあり / Bにあり / Active | Existing |
| Aにあり / Bにあり / Unused | Reactivated |
| Aになし / Bにあり / Active | Unused化 |
| Aになし / Bにあり / Unused | 変更なし |

また、`TemplateLocation`、`Status`、`FirstDetectedAt`、`LastDetectedAt` の更新規則および、1 Sync内で共通の `SyncTimestamp` を使用することが定義されている。

### 3.3 Test Specification

`DOC-MVP-TESTSPEC` では少なくとも以下が確認対象となっている。

```text
MTS-SYNC-002 New
MTS-SYNC-003 Existing設定保持
MTS-SYNC-004 Unused化
MTS-SYNC-005 Reactivated
MTS-SYNC-006 Rename
MTS-SYNC-007 Case Insensitive既存照合 / 正式表記保持
MTS-SYNC-011 Sync metadata更新
```

P2-02ではこれらのうち、PersistenceやUIを除いたCore判定部分へ接続可能なProduction Logicを成立させる。

---

## 4. P2-01からのInput Boundary

P2-01 Full Template Scannerで、以下のResult Contractが成立済みとする。

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

### 4.1 ValidVariables

- 有効なVariableName一覧
- Case Insensitiveに重複統合済み
- 初回検出表記を保持
- Subject → BodyのScan順による初回検出順を保持

### 4.2 InvalidCandidates

- `{{...}}` Candidateのうち命名規則違反となった一覧

### 4.3 Locations

```text
Key   = VariableName
Value = Subject / Body / Both
```

- Late Bound `Scripting.Dictionary`
- `CompareMode = vbTextCompare`
- Case Insensitive Identity
- `Locations.Count = ValidVariables.Count`
- Invalid Candidateは含まない

---

## 5. Current VariableDefinitions Input Boundary

P2-02はCurrent VariableDefinitionsをExcel Objectとして受け取らない。

論理Inputは以下とする。

```text
Current VariableDefinitions
└─ Collection
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
      └─ LastDetectedAt
```

P0 Data Accessが内部利用する `__RowIndex` 等のExcel物理位置情報は、P2-02の論理判断には使用しない。

P2-02は、

```text
Worksheet
ListObject
ListRow
Range
Cell Address
```

へ依存しない。

---

## 6. P2-02 Logical Input Contract

P2-02の論理Inputは以下とする。

```text
1. templateScanResult
2. currentDefinitions
3. syncTimestamp
```

概念：

```text
TemplateScanResult
+
Current VariableDefinitions
+
SyncTimestamp
        ↓
modSyncEngine
```

### 6.1 templateScanResult

P2-01 Production Contractをそのまま使用する。

```text
ValidVariables
InvalidCandidates
Locations
```

P2-02の通常処理Preconditionでは、

```text
InvalidCandidates.Count = 0
```

とする。

Invalid TemplateのFail Closed OrchestrationはP2-05で完成させる。

P2-02はInvalid CandidateをNew / Existing等へ分類しない。

### 6.2 currentDefinitions

Current VariableDefinition全件を入力とする。

ActiveだけではなくUnusedも必要である。

理由：

```text
Existing
Reactivated
Unused化
Already-Unused
```

を判定するため。

### 6.3 syncTimestamp

1回の手動Syncで使用する共通Timestampを入力として受け取る。

P2-02内部で `Now` を呼び出してTimestampを生成しない。

---

## 7. SyncTimestamp責務

### 7.1 決定

`SyncTimestamp` はApplication / Orchestration側がSync開始時に1回取得し、P2-02へ渡す。

概念：

```text
Manual Sync開始
↓
Precondition成立
↓
SyncTimestamp = Now
↓
P2-02 Sync Diff Core
↓
P2-03 Persistence
```

### 7.2 理由

Design上要求されているのは、

> 同一Sync内で1つのSyncTimestampを共通利用すること

である。

P2-02内部で時刻取得すると、Core LogicがClockへ依存し、Verificationで固定Timestampを使用しにくくなる。

したがって、

```text
Clock取得
= Application / Orchestration責務

Timestampを使ったTarget Metadata計算
= P2-02責務
```

とする。

### 7.3 P2-03

P2-03は新しいTimestampを取得しない。

P2-02が算出したTarget MetadataをそのままPersistenceする。

---

## 8. Case Insensitive Identity

Template VariableとVariableDefinitionの同一性判定では大文字・小文字を区別しない。

概念：

```text
ModelName
MODELNAME
modelname
```

は同一Identityとする。

内部比較用Dictionaryは、

```text
CompareMode = vbTextCompare
```

を使用する。

VariableName文字列を `LCase` 等で破壊的に正規化してCanonical Nameとして使用しない。

Case InsensitiveはIdentity比較の規則であり、正式表記を小文字化する規則ではない。

---

## 9. Canonical VariableName

### 9.1 基本原則

P2-02では、

> Identity比較と表示上の正式表記を分離する。

Case Insensitive比較で同一Variableと判断しても、OutputではCanonical VariableNameを保持する。

### 9.2 New

VariableDefinitionに既存定義が存在しないため、P2-01 Scannerが保持している初回検出表記をCanonical Nameとする。

例：

```text
Template Scan:
MODELNAME
```

かつCurrent VariableDefinitionに同一Identityなし。

結果：

```text
Classification = New
VariableName    = MODELNAME
```

### 9.3 Existing

VariableDefinition側の既存VariableNameをCanonical Nameとする。

例：

```text
Template:
MODELNAME

VariableDefinition:
ModelName
```

結果：

```text
Classification = Existing
VariableName    = ModelName
```

Template側表記へ変更しない。

### 9.4 Reactivated

VariableDefinition側の既存VariableNameをCanonical Nameとする。

例：

```text
Template:
GATEDATE

VariableDefinition:
GateDate
Status:
Unused
```

結果：

```text
Classification = Reactivated
VariableName    = GateDate
```

### 9.5 Unused

VariableDefinition側の既存VariableNameをCanonical Nameとする。

### 9.6 Already-Unused

VariableDefinition側の既存VariableNameを維持するが、P2-02の4分類Outputには含めない。

---

## 10. 4分類

P2-02のPublic Diff Classificationは以下の4分類とする。

```text
New
Existing
Reactivated
Unused
```

ここで `Unused` は、

```text
Current Status = Active
AND
Current Templateに存在しない
```

VariableをUnusedへ遷移させる分類を意味する。

---

## 11. Classification Rule

| Template | VariableDefinition | Current Status | P2-02 Classification |
|---|---|---|---|
| あり | なし | - | New |
| あり | あり | Active | Existing |
| あり | あり | Unused | Reactivated |
| なし | あり | Active | Unused |
| なし | あり | Unused | No-op / Already-Unused |

比較はCase Insensitiveとする。

---

## 12. Already-Unusedの扱い

### 12.1 決定

既に `Status = Unused` であり、現在のTemplateにも存在しないVariableは、

```text
Already-Unused
=
No-op
```

とする。

### 12.2 Public Classification

`Already-Unused` を第5のPublic Classificationとして追加しない。

以下の4分類を維持する。

```text
New
Existing
Reactivated
Unused
```

### 12.3 Output

Already-Unused Variableは、

```text
New
Existing
Reactivated
Unused
```

のいずれのCollectionにも追加しない。

### 12.4 Metadata

Already-Unusedでは以下をすべて変更しない。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
User Configuration
```

### 12.5 理由

Design上Already-Unusedは「変更なし」であり、新たなPersistence Actionを必要としない。

MVPで差分通知やPersistenceのために第5分類を公開する必要はないため、YAGNIに従いNo-opとする。

---

## 13. Rename

Renameは推測しない。

例：

```text
Before:
PIC

After Template:
PersonInCharge
```

P2-02では独立したRename Classificationを生成しない。

結果：

```text
PIC
→ Unused

PersonInCharge
→ New
```

Caseや文字列類似度からRenameを推測するLogicは実装しない。

---

## 14. Metadata計算責務

P2-02は分類結果だけでなく、P2-03がPersistenceすべき自動管理項目のTarget Stateを計算する。

対象：

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

以下のユーザー設定項目はP2-02のUpdate Targetに含めない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

---

## 15. Metadata Target Rule

### 15.1 New

```text
VariableName:
Scanner初回検出表記

TemplateLocation:
Current TemplateScanResult Locations

Status:
Active

FirstDetectedAt:
SyncTimestamp

LastDetectedAt:
SyncTimestamp
```

ユーザー設定値はP2-02で生成しない。

### 15.2 Existing

```text
VariableName:
Existing VariableDefinition Canonical Name

TemplateLocation:
Current TemplateScanResult Locations

Status:
Active

FirstDetectedAt:
Existing valueを保持

LastDetectedAt:
SyncTimestamp
```

以下は保持対象であり、P2-02の更新対象にしない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

### 15.3 Reactivated

```text
VariableName:
Existing VariableDefinition Canonical Name

TemplateLocation:
Current TemplateScanResult Locations

Status:
Active

FirstDetectedAt:
Existing valueを保持

LastDetectedAt:
SyncTimestamp
```

既存ユーザー設定は再利用する。

### 15.4 Unused

```text
VariableName:
Existing VariableDefinition Canonical Name

TemplateLocation:
Existing valueを保持

Status:
Unused

FirstDetectedAt:
Existing valueを保持

LastDetectedAt:
Existing valueを保持
```

Unused化時刻で `LastDetectedAt` を更新しない。

### 15.5 Already-Unused

```text
No Action
```

全値を保持する。

---

## 16. Metadata Rule Matrix

| Classification | VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|---|
| New | Scanner表記 | Current Scan | Active | SyncTimestamp | SyncTimestamp |
| Existing | Existing Canonical | Current Scan | Active | Keep | SyncTimestamp |
| Reactivated | Existing Canonical | Current Scan | Active | Keep | SyncTimestamp |
| Unused | Existing Canonical | Keep | Unused | Keep | Keep |
| Already-Unused | Keep | Keep | Unused | Keep | Keep |

---

## 17. P2-02 Output Boundary

P2-02の論理Outputは以下とする。

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

各分類は順序付き一覧として扱える `Collection` を想定する。

各Itemは少なくとも以下の論理情報を持つ。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

ただし、具体的なVBA Carrier構造およびPublic API Signatureは `P2-02 Sync Diff Core 実施仕様 v0.1` で確定する。

Boundary Confirmationでは、

> Outputが分類結果だけでなくPersistenceに必要なTarget Metadataを表現できること

を固定する。

---

## 18. Outputに含めないもの

P2-02 Outputには以下を含めない。

```text
Worksheet
ListObject
ListRow
Range
Cell
__RowIndex
OFT Path
MailItem
Inspector
WordEditor
User-facing Message
UI表示文字列
Excel更新成功 / 失敗情報
```

また、以下のユーザー設定値を「同期更新値」として生成しない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

Existing / Reactivated / UnusedではCurrent VariableDefinition側の既存値を保持する。

---

## 19. P2-02とP2-03の責務境界

### 19.1 P2-02 Sync Diff Core

P2-02の責務：

```text
Case Insensitive Identity判定
Canonical VariableName決定
New判定
Existing判定
Reactivated判定
Unused判定
Already-Unused No-op判定
Rename非推測
Target TemplateLocation計算
Target Status計算
Target FirstDetectedAt計算
Target LastDetectedAt計算
SyncTimestamp適用
SyncDiffResult生成
```

P2-02はExcelへ書き込まない。

### 19.2 P2-03 VariableDefinition Sync Persistence

P2-03の責務：

```text
SyncDiffResultを受け取る
↓
VariableDefinition Data Access
↓
New行追加
Existing自動管理列更新
Reactivated自動管理列更新
Unused自動管理列更新
```

P2-03は分類を再判定しない。

P2-03はCanonical VariableNameを再決定しない。

P2-03は新しいSyncTimestampを生成しない。

P2-03はRenameを推測しない。

### 19.3 責務境界

```text
P2-02
What should change?
        ↓
SyncDiffResult
        ↓
P2-03
Persist the decided changes.
```

---

## 20. Existing User Configuration保護

以下はUser Configurationとする。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

P2-02はこれらの値を更新対象として生成しない。

P2-03はSyncDiffResultを理由としてこれらを上書きしてはならない。

NewについてはP2-03で新規行を作成する必要があるが、少なくとも、

```text
DisplayName
Type
Required
```

は未設定状態とするRequirementを維持する。

具体的なNew行生成時のExcel既定値・空欄設定方法はP2-03実施仕様で決定する。

---

## 21. Core Logic Boundary

P2-02 Production Boundaryは以下とする。

```text
TemplateScanResult
+
Current VariableDefinitions
+
SyncTimestamp
        ↓
─────────────────────────────
Core Logic
modSyncEngine
─────────────────────────────
        ↓
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

P2-02は以下へ依存しない。

```text
Excel Worksheet / ListObject
Outlook
WordEditor
MailItem
Settings
OFT Path
UserForm
UI
```

---

## 22. P2-02 Scope

P2-02で確定するもの：

```text
Input Contract
Output Contract
Case Insensitive Identity
Canonical VariableName Rule
4 Classification
Already-Unused No-op
Rename Non-Inference
SyncTimestamp Injection Boundary
Metadata Target Calculation
Existing User Configuration Preservation Boundary
P2-03 Persistence Boundary
```

---

## 23. Out of Scope

P2-02では以下を実装・確定しない。

```text
Excel Table書込み
New行の物理追加
既存行のCell更新
ListObject操作
VariableDefinition Data Access Write API
Manual Sync Button
Sync Result UI
User-facing通知文
OFT存在確認
Outlook Readiness
OFT読込
Template Scan
Invalid Candidate UI
Fail Closed Orchestration全体
Unused確認UI
Configuration Validator
Formal MVP Test
```

これらはP2-03以降の責務とする。

---

## 24. P2-02 Verification Boundary

P2-02 Verificationでは少なくとも以下をCore Test対象とする。

```text
C1  New
C2  Existing
C3  Reactivated
C4  Unused
C5  Already-Unused No-op
C6  Case Insensitive Existing
C7  Case Insensitive Reactivated
C8  Existing Canonical Name Preservation
C9  Rename = Old Unused + New
C10 Mixed Classification
C11 New Metadata
C12 Existing Metadata
C13 Reactivated Metadata
C14 Unused Metadata
C15 Common SyncTimestamp
C16 Existing User Configuration Not In Update Target
C17 Empty Template / Existing Active → Unused
C18 Empty Template / Existing Unused → No-op
```

具体的なTest Module名、Entry Point、Fixture、Expected出力形式はP2-02実施仕様で決定する。

これらはImplementation Verificationであり、Formal `DOC-MVP-TESTSPEC` Test Resultではない。

---

## 25. Boundary Invariants

P2-02では以下をInvariantとする。

### 25.1 Classification Exclusivity

1つのVariable Identityが同一Sync内で複数Classificationへ入ってはならない。

```text
New
Existing
Reactivated
Unused
```

は相互排他的とする。

### 25.2 Canonical Identity

Existing / Reactivated / UnusedのOutput VariableNameは、Current VariableDefinition側の正式表記を保持する。

### 25.3 New Identity

NewのOutput VariableNameはScannerの初回検出表記を保持する。

### 25.4 Metadata

各ClassificationのTarget Metadataは§16のMatrixと一致する。

### 25.5 Already-Unused

Already-UnusedはOutput 4分類へ含まれず、Metadata変更も生成しない。

### 25.6 User Configuration

Existing / Reactivated / UnusedのUser Configuration更新を生成しない。

### 25.7 COM / Excel Independence

P2-02 Core LogicはExcel / Outlook / Word COM Objectへ依存しない。

---

## 26. Error / Precondition Boundary

P2-02はTechnical Coreであり、Manual Sync全体のError Orchestrationを担当しない。

Production Manual SyncではP2-02実行前に、

```text
OFT存在
Template Scan成功
InvalidCandidates.Count = 0
Current VariableDefinitions取得成功
```

が成立していることをApplication側が保証する。

P2-02自身のRuntime Failureや不正なInput Carrierに対するResult変換方式は、P2-02実施仕様で具体化する。

P2-02でUser-facing Error Messageや最終Error Taxonomyを固定しない。

---

## 27. Requirement / Design Gap Assessment

本Boundary Confirmationで新しい利用者向け振る舞いは追加しない。

```text
Requirement Gap:
NONE
```

Baseline Designに対する新しいArchitecture Decisionは追加しない。

```text
Design Finding:
NONE
```

Technical Spikeを再開する新しいTechnical Questionはない。

```text
Technical Spike Reopen:
NOT REQUIRED
```

Current Approved Baselineの変更は不要。

```text
Baseline Change:
NOT REQUIRED
```

---

## 28. Confirmed Decisions

以下をP2-02 Boundaryとして確定する。

1. P2-02は `modSyncEngine` のCore Logic Boundaryとする。
2. Inputは `TemplateScanResult + Current VariableDefinitions + SyncTimestamp` とする。
3. VariableName IdentityはCase Insensitiveとする。
4. NewはScanner初回検出表記をCanonical Nameとする。
5. Existing / Reactivated / UnusedはExisting VariableDefinition表記をCanonical Nameとする。
6. Public Classificationは `New / Existing / Reactivated / Unused` の4分類とする。
7. Already-UnusedはNo-opとし、第5のPublic Classificationを追加しない。
8. Renameは推測せず、Old Unused + Newとする。
9. SyncTimestampはApplication / Orchestration側で1回取得し、P2-02へ注入する。
10. P2-02内部で `Now` を呼び出さない。
11. P2-02はTarget Metadataを計算する。
12. P2-02が計算するMetadata対象は `VariableName / TemplateLocation / Status / FirstDetectedAt / LastDetectedAt` とする。
13. User ConfigurationはP2-02の更新対象に含めない。
14. Existing / Reactivated / Unusedのユーザー設定を保持する。
15. P2-02はExcel Tableを更新しない。
16. Excel PersistenceはP2-03責務とする。
17. P2-03は分類・Canonical Name・Metadata Ruleを再判定しない。
18. P2-03はP2-02が算出したTarget StateをPersistenceする。
19. P2-02 Outputは4分類とPersistence可能なTarget Metadataを表現できる構造とする。
20. 具体的なPublic API Signature / Dictionary Key / Test ModuleはP2-02実施仕様で確定する。

---

## 29. Boundary Result

```text
P2-02 Sync Diff Core Boundary Confirmation

Input Boundary:
CONFIRMED

Output Boundary:
CONFIRMED

Canonical VariableName:
CONFIRMED

4 Classification:
CONFIRMED

Already-Unused:
NO-OP / CONFIRMED

Rename:
OLD UNUSED + NEW / CONFIRMED

SyncTimestamp Responsibility:
APPLICATION ACQUIRES ONCE
P2-02 RECEIVES AS INPUT

Metadata Calculation:
P2-02 RESPONSIBILITY

Excel Persistence:
P2-03 RESPONSIBILITY

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

---

## 30. Next Action

次に作成する。

```text
P2-02 Sync Diff Core 実施仕様 v0.1
```

実施仕様では本Boundaryを変更せず、以下をImplementation Detailへ具体化する。

```text
Production Public API
COperationResult Boundary
SyncDiffResult Carrier
Collection / Dictionary構造
Dictionary Key
CompareMode
Internal Lookup Dictionary
Classification Algorithm
Output初期化規則
Runtime Error Handling
Core Verification Fixture
Core Verification C1-C18
Production Patch方針
Completion Criteria
```

Boundaryと矛盾する論点が発生した場合、実装都合で暗黙変更せず、Findingとして切り出す。
