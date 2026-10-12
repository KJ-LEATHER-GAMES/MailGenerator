# P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1

## 1. 文書情報

| 項目                         | 内容                                                              |
| -------------------------- | --------------------------------------------------------------- |
| 文書名                        | P2-03 VariableDefinition Sync Persistence Boundary Confirmation |
| バージョン                      | v0.1                                                            |
| 対象プロジェクト                   | 定型メール作成ツール MVP                                                  |
| 文書種別                       | Implementation Unit Boundary Confirmation                       |
| Status                     | Confirmed                                                       |
| Current Execution Baseline | BL-MVP-003                                                      |
| 対象Phase                    | P2 Scan / Sync                                                  |
| 対象Implementation Unit      | P2-03 VariableDefinition Sync Persistence                       |
| 前提Unit                     | P2-02 Sync Diff Core = PASS / COMPLETE                          |
| Primary Production Module  | `modVariableDefinitionData`                                     |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P2-02 Sync Diff Core Completion Record v0.1`

---

# 2. 目的

P2-03の目的は、P2-02 `Sync Diff Core` が生成した `SyncDiffResult` を受け取り、そのTarget Stateを `tblVariableDefinition` へPersistenceする責務境界を確定することである。

P2-03は、差分の意味を再計算するUnitではない。

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

責務の基本分離は以下とする。

```text
P2-02
= What the VariableDefinition state should become

P2-03
= Persist that target state into Excel
```

---

# 3. 前提Boundary

P2-02から以下のResultを受け取る。

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

各Diff Itemは以下のTarget Stateを保持する。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

P2-03では以下を再計算しない。

```text
Classification
Canonical VariableName
SyncTimestamp
Rename Inference
Metadata Meaning
```

P2-03はP2-02のTarget StateをPersistenceする。

---

# 4. Persistence Operation Boundary

## 4.1 Persistence単位

`SyncDiffResult` 全体を1回のPersistence Operationとして扱う。

ClassificationごとのPublic APIやItem単位のPublic APIは設けない。

```text
SyncDiffResult
        ↓
ApplySyncDiff()
        ↓
Preflight
        ↓
Persistence
```

---

## 4.2 Production Module

P2-03のProduction責務は既存Infrastructure Moduleである、

```text
modVariableDefinitionData
```

へ追加する。

新しいPersistence専用Moduleは追加しない。

---

## 4.3 Production Public API

Production Public APIは1本とする。

概念Interface：

```vb
Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult
```

Preflight ValidationおよびClassificationごとの具体的なExcel操作はPrivate実装へ閉じ込める。

Preflight専用Public APIは追加しない。

---

# 5. Target State Persistence Rule

## 5.1 基本原則

P2-03はP2-02が計算したTarget StateをそのままPersistenceする。

P2-03自身が、

```text
ExistingだからLastDetectedAtを更新する
UnusedだからStatusをUnusedへ変更する
```

等のSync Ruleを再計算しない。

---

## 5.2 New

Newの場合、新しいListRowを追加する。

自動管理項目として以下を保存する。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

User Configurationはすべて未設定状態とする。

```text
DisplayName   = Blank
Type          = Blank
Required      = Blank
Description   = Blank
OptionSource  = Blank
SortOrder     = Blank
Format        = Blank
```

P2-03はDefault値を推測しない。

特に、

```text
Required = False
Type = Text
SortOrder = 自動採番
```

等を自動設定しない。

---

## 5.3 Existing / Reactivated / Unused

既存行ではVariableNameをPersistenceし直さない。

VariableNameは以下に使用する。

```text
Logical Identity
+
対象行検索
+
Canonical Name整合確認
```

Persistence対象は以下4項目とする。

```text
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

4項目は毎回Target StateでWriteする。

Current Valueとの差分判定やClassificationごとのWrite列最適化は行わない。

---

# 6. Row Identity

既存VariableDefinitionの対象行は、`VariableName` をCase Insensitiveで検索して特定する。

```text
Logical Identity
= VariableName

Physical Excel Row
= modVariableDefinitionData内部で解決
```

`__RowIndex` はP2-03の外部ContractおよびPersistence Identityとして使用しない。

Excel上の物理Row IndexをP2-02からP2-03へ持ち回らない。

---

# 7. Preflight Validation

## 7.1 基本方針

Excel Writeを開始する前に、`SyncDiffResult`全体およびPersistence先全体をPreflight Validationする。

1件でも不正が存在する場合、

```text
Excel Write = 0件
COperationResult.Success = False
```

とする。

Itemを書きながら逐次Validationする方式は採用しない。

---

## 7.2 SyncDiffResult構造

少なくとも以下が正しいことを確認する。

```text
New
Existing
Reactivated
Unused
```

正常な4 Collectionが存在し、すべて0件の場合は正常なNo-opとして扱う。

```text
Persistence Target = 0
→ Success
→ Excel Write = 0
```

---

## 7.3 Classification横断一意性

`New / Existing / Reactivated / Unused` を横断し、VariableNameがCase Insensitiveで一意であることを確認する。

同一VariableNameが複数Classificationに存在する場合はContract Violationとする。

P2-03では、

- 優先Classificationを決めない
- 自動Mergeしない
- ItemをSkipしない

---

## 7.4 Target State Value Validation

P2-03は値を再計算しないが、Persistence Contractとして値域を確認する。

### VariableName

既定のVariableName Syntaxに適合すること。

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

### TemplateLocation

以下のいずれかであること。

```text
Subject
Body
Both
```

### Status

以下のいずれかであること。

```text
Active
Unused
```

### Timestamp

必要な `FirstDetectedAt` / `LastDetectedAt` は有効なVBA `Date` として扱えること。

---

## 7.5 Classification / Target State Invariant

Target Stateを再計算せず、既知Contractとの矛盾だけを確認する。

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

不一致時はContract Violationとし、P2-03側で補正しない。

---

# 8. Blank / Empty / Null Boundary

## 8.1 User Configuration

User ConfigurationのBlankは正常な「未設定状態」として許容する。

特にNew Variableでは正常状態である。

---

## 8.2 Automatic Metadata

そのClassificationで必須となるTarget State MetadataのBlank / Empty / NullはContract違反とする。

Preflight FailureとしてWrite開始前に停止する。

---

## 8.3 Existing Metadata Defect

既存VariableDefinition由来のMetadata欠損をP2-03で自動補正しない。

例：

```text
FirstDetectedAt = Blank
```

の場合、

```text
現在時刻
LastDetectedAt
SyncTimestamp
```

等を用いた推測補完は行わない。

Data RepairはP2-03の責務外とする。

---

# 9. Persistence Destination Validation

Write前にPersistence先を検証する。

## 9.1 Table

以下が存在すること。

```text
tblVariableDefinition
```

## 9.2 Required Columns

少なくとも以下が存在すること。

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

列位置には依存せず、列名で特定する。

Table / Column構造が不正な場合はWriteを開始しない。

---

# 10. Empty Table Boundary

`tblVariableDefinition` が存在しRequired Columnsが揃っていれば、Data Rowが0件でも正常状態とする。

```text
DataBodyRange = Nothing
または
Rows.Count = 0
```

を異常とはしない。

Empty Tableに対してNew Variableを追加可能とする。

Dummy Rowは使用しない。

一方、

```text
Existing
Reactivated
Unused
```

が存在するのに対応行がない場合はContract Conflictとする。

---

# 11. Current Table State Guard

## 11.1 Existing TableのVariableName重複

既存 `tblVariableDefinition` にCase Insensitiveで同一となるVariableNameが複数存在する場合、

```text
Preflight Failure
Excel Write = 0件
```

とする。

P2-03では、

- 先頭行を採用しない
- 自動Mergeしない
- 自動削除しない

Data Repairは責務外とする。

---

## 11.2 New Item Conflict

P2-02でNewと分類されたVariableNameが、P2-03 Preflight時点ですでに存在する場合はContract Conflictとする。

```text
New + Existing Row
→ Failure
```

P2-03ではExistingへ再分類しない。

---

## 11.3 Existing系Item Missing

P2-02で、

```text
Existing
Reactivated
Unused
```

と分類されたVariableNameの行が存在しない場合もContract Conflictとする。

```text
Existing系 + Missing Row
→ Failure
```

Newへの再分類や行の自動再作成は行わない。

---

# 12. Concurrency Boundary

P2-03では完全なMetadata-level Optimistic Concurrency Controlを実装しない。

確認するもの：

```text
New
→ 同名行が存在しない

Existing / Reactivated / Unused
→ 対象行が一意に存在する
```

確認しないもの：

```text
P2-02 Current Definition Read時点
        =
P2-03 Write直前
のMetadata完全一致
```

P2-02 ContractへCurrent State SnapshotやVersion情報を追加しない。

Metadata-level concurrency detectionはMVP対象外とする。

---

# 13. Timestamp Boundary

`SyncTimestamp` はP2-04 Manual Sync IntegrationがSync開始時に1回取得する。

```text
P2-04
SyncTimestamp取得
        ↓
P2-02 BuildSyncDiff()
        ↓
Target State
        ↓
P2-03 ApplySyncDiff()
```

P2-03へ`SyncTimestamp`そのものは渡さない。

P2-03では以下を呼び出さない。

```text
Now()
Date()
Time()
```

`FirstDetectedAt` / `LastDetectedAt` はVBA `Date` 値としてExcelへPersistenceする。

P2-03では日時文字列へのFormatを行わない。

表示形式はExcel側に委ねる。

---

# 14. Write Order

Rollbackを実装しないため、Write順序は以下とする。

```text
1. Existing Row Persistence
2. New Row Addition
```

`Existing / Reactivated / Unused` 相互の順序はSemantic Ruleとしない。

それらの相対順序はImplementation Detailとする。

構造変更を伴うNew行追加を既存行更新後に行う。

---

# 15. New Row Addition Rule

New Variableは `tblVariableDefinition` の末尾へ追加する。

P2-03では以下を行わない。

```text
既存行Sort
Template順への挿入
VariableName順Sort
SortOrder自動設定
```

複数New Itemが存在する場合は、

```text
SyncDiffResult.New
```

のCollection順を保持して末尾追加する。

この順序はImplementation上の再現性として維持するが、User-facing Requirementとして保証しない。

---

# 16. Atomicity / Rollback

## 16.1 Pre-write

事前に検知可能なFailureはPreflightで検出し、Writeを開始しない。

---

## 16.2 Runtime Failure

Write開始後に予期しないRuntime Failureが発生した場合、

```text
処理停止
↓
以降のWrite停止
↓
Failure Result
```

とする。

既に完了したWriteは戻さない。

---

## 16.3 Rollback

P2-03では、

```text
Transaction
Snapshot Restore
Best-effort Rollback
Staging Table
```

等のRollback機構を実装しない。

したがって、

> Runtime Failure発生時にはPartial Write状態が残る可能性がある。

これはP2-03の既知制約として明示する。

---

# 17. Post-write Read Back

Production `ApplySyncDiff()` ではWrite後のRead Back Verificationを行わない。

```text
Preflight
↓
Write
↓
Runtime Errorなし
↓
Success
```

とする。

Expected Target StateとActual Persisted Stateの比較はP2-03 Implementation Verificationで行う。

Production RuntimeへRead Back Failure Modeを追加しない。

---

# 18. Result / Error Boundary

## 18.1 Success / Failure Result

`ApplySyncDiff()` は既存 `COperationResult` のみを返す。

追加のPersistence専用Result Carrierは作らない。

```text
Success
→ COperationResult.Success = True

Failure
→ COperationResult.Success = False
→ ErrorInfo
```

New / Existing / Reactivated / Unused件数はCallerが既存`SyncDiffResult`から取得可能であるため、P2-03では重複Carrierを生成しない。

---

## 18.2 ErrorInfo

既存ErrorInfoを利用する。

Itemを特定できる場合：

```text
Target = VariableName
```

Itemに特定できない構造的不整合：

```text
Target = SyncDiffResult
または
Target = VariableDefinition
```

Runtime Errorも既存Error体系へ変換する。

Persistence専用Error Carrierは新設しない。

---

# 19. Excel UI Side Effect Boundary

P2-03はData Persistenceのみ担当する。

意図的に変更するもの：

```text
対象Metadata Cell Value
New時のListRow追加
```

意図的に変更しないもの：

```text
Sort
Filter
ActiveSheet
Selection
NumberFormat
Cell Format
Column Width
表示状態
```

ListRow追加に伴うExcel標準のTable書式継承等は許容する。

P2-03自身がUIを整える処理は追加しない。

---

# 20. P2-03 / P2-04 Responsibility Boundary

## 20.1 P2-03

P2-03の責務：

```text
SyncDiffResult Preflight
Persistence Destination Preflight
Actual Table State Contract Guard
Existing Metadata Persistence
New Row Addition
Runtime Error Result Conversion
```

P2-03では以下を呼び出さない。

```text
ScanTemplate()
BuildSyncDiff()
Now()
Date()
Time()
```

Sync用Inputを再構築するための `GetAllVariableDefinitions()` 呼出しも行わない。

---

## 20.2 P2-04

P2-04 Manual Sync Integrationの責務：

```text
SyncTimestamp取得
Template Scan呼出し
Current VariableDefinitions取得
BuildSyncDiff()呼出し
ApplySyncDiff()呼出し
処理順序制御
COperationResult伝播
```

責務構造：

```text
P2-04
= Workflow / Orchestration

P2-02
= Diff Meaning / Target State

P2-03
= Persistence
```

---

# 21. User Notification Boundary

P2-03ではUser Notificationを行わない。

```text
MsgBox
UserForm Result表示
同期件数表示
User-facing Message生成
```

はP2-03の責務外とする。

P2-03は`COperationResult`のみ返す。

Sync Result / User Notificationは後続Application / Integration責務とする。

---

# 22. Out of Scope

P2-03では以下を実装しない。

```text
Template Scan
Classification再計算
Canonical VariableName再計算
Rename推測
SyncTimestamp取得
Metadata Meaning再計算
Manual Sync Orchestration
OFT存在確認
Invalid Templateの最終Fail Closed
Sync Result UI
User Notification
VariableDefinition Data Repair
完全Transaction
Rollback
Metadata-level Concurrency Control
Post-write Production Read Back
Excel Sort / Filter / Selection制御
Formal MVP Test
```

---

# 23. Verification Boundary

P2-03ではProduction実装に対するImplementation Verificationを行う。

主な確認対象：

## Normal

```text
New Persistence
Existing Persistence
Reactivated Persistence
Unused Persistence
User Configuration Preservation
Mixed Classification
Empty Table + New
Zero Target No-op
Multiple New Order
Date Value Persistence
```

## Preflight / Negative

```text
Invalid SyncDiffResult
Missing Collection / Key
Invalid VariableName
Invalid Status
Invalid TemplateLocation
Invalid Date
Classification / Status Invariant Violation
Classification Duplicate
Existing Table Duplicate VariableName
New Conflict
Existing Row Missing
Missing Table
Missing Required Column
Missing Required Metadata
```

## Runtime

```text
Unexpected Persistence Runtime Failure
→ COperationResult Failure
→ Processing Stop
```

## Integration / Regression

```text
P2-02 SyncDiffResult Contract Compatibility
Existing P0 VariableDefinition Data Access Regression
```

---

# 24. Formal MVP Test Boundary

P2-03 Verificationは、

```text
Implementation Verification
```

である。

以下を意味しない。

```text
MTS-SYNC-* Formal PASS
```

Formal MVP Testは、後続で固定するTest Candidate Buildに対して別途実施する。

---

# 25. Completion Criteria

P2-03を `PASS / COMPLETE` とするには以下をすべて満たすこと。

```text
Boundary Confirmation                      PASS
Approved Unit Specification               PASS
VBA Compile                               PASS
Production ApplySyncDiff Implementation   PASS
Normal Verification                       PASS
Preflight / Negative Verification         PASS
P2-02 Contract Compatibility              PASS
Existing P0 Data Access Regression        PASS
Production Patch Review                   PASS
Finding Assessment                        PASS
Blocking Finding                          0
Requirement / Design / Test / Baseline
Impact Assessment                         COMPLETE
```

ただし、

```text
P2-03 COMPLETE
≠
P2 Phase COMPLETE
≠
CP-P2 ESTABLISHED
```

とする。

---

# 26. Cross-document Consistency Result

今回のBoundary Confirmationは、以下の既存方針を変更しない。

```text
Requirement:
New自動追加
Existing設定保持
Unused化
Reactivation
Rename非推測
Case Insensitive Identity

Design:
VariableDefinition自動管理Metadata
Single SyncTimestamp
Excel Data Access分離
modVariableDefinitionData責務

Implementation Plan:
modVariableDefinitionData = Infrastructure
modSyncEngine = Core Logic
modSyncApplication = Application

P2-02:
SyncDiffResult
Target State
Classification
Canonical VariableName
Metadata Meaning
```

判定：

```text
Requirement Gap:
NONE

Design Finding:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P2-02 Contract Change:
NOT REQUIRED

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

Current Execution Baseline：

```text
BL-MVP-003
```

を継続する。

---

# 27. Confirmed Decision Summary

```text
B01  SyncDiffResult全体を1 Persistence Operationとする
B02  P2-02 Target Stateを再計算せずPersistenceする
B03  Existing Row Identity = Case Insensitive VariableName
B04  New User Configuration = Blank
B05  全Preflight完了後にWrite開始
B06  Rollbackなし / Runtime Partial Write可能性あり
B07  Existing系Write後にNewを追加
B08  modVariableDefinitionDataへPublic API 1本
B09  Return = COperationResultのみ
B10  Existing ErrorInfoを再利用
B11  Timestamp = VBA Date
B12  User Config Blank許容 / Required Metadata Blank不可
B13  Existing Metadata欠損を自動補正しない
B14  Zero Target = Success No-op
B15  SyncTimestamp取得 = P2-04
B16  Table / ColumnをPreflight
B17  Existing VariableName重複 = Failure
B18  Newなのに既存行あり = Failure
B19  Existing系なのに対象行なし = Failure
B20  Production Read Backなし
B21  Target State値域をPreflight
B22  Existing VariableNameは再Writeしない
B23  Existing Metadata 4列を毎回Write
B24  NewはTable末尾へ追加
B25  Multiple NewはCollection順を維持
B26  Classification横断VariableName一意性確認
B27  Metadata-level Concurrency ControlはMVP対象外
B28  Classification / Target State Invariantを確認
B29  Excel UI状態を変更しない
B30  Empty Tableを正常状態として扱う
B31  PreflightはApplySyncDiff内部へ閉じる
B32  P2-04 = Orchestration / P2-03 = Persistence
B33  P2-03ではUser Notificationなし
B34  Implementation VerificationとFormal Testを分離
B35  Completion Gateを明示
```

---

# 28. Boundary Confirmation Final Decision

P2-03の責務境界は以下で確定する。

```text
Input:
P2-02 SyncDiffResult

Production Module:
modVariableDefinitionData

Public Contract:
ApplySyncDiff(syncDiffResult)
→ COperationResult

Core Responsibility:
Preflight
+
VariableDefinition Persistence

Do Not Recompute:
Classification
Canonical VariableName
SyncTimestamp
Rename Inference
Metadata Meaning

Do Not Own:
Manual Sync Orchestration
User Notification
Formal MVP Test
Rollback
Data Repair
```

判定：

```text
P2-03 Boundary Confirmation:
CONFIRMED

Blocking Boundary Finding:
0

Next Action:
P2-03 VariableDefinition Sync Persistence
Implementation Unit Specification v0.1 作成
```
