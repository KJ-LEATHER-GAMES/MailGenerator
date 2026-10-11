# P2 Implementation Unit Decomposition Decision v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2 Implementation Unit Decomposition Decision |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Planning Decision |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P2 Scan / Sync |
| Primary Reference | P2 Scan / Sync Boundary Confirmation v0.1 |
| Dependency | CP-P0 / CP-P1 |
| Decision | P2を5 Implementation Unitへ分割する |
| Result | **APPROVED FOR UNIT SPECIFICATION** |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P2 Scan / Sync Boundary Confirmation v0.1`
- `P1-04 Minimal Template Scanner Completion Record v0.1`
- `P1 Phase Verification Record v0.1`
- `CP-P1 Establishment Record v0.1`

---

# 2. 目的

P2 Scan / Syncを、一括実装ではなく、責務と依存関係が明確なImplementation Unitへ分割する。

分割にあたっては以下を優先する。

1. 各Unit単独でProduction ChangeとVerification Scopeを説明できる
2. 依存方向を一方向にする
3. Core LogicとExcel / Outlook Infrastructureを混在させない
4. P1で成立したContractを再実装しない
5. 文書・Verification管理コストを増やしすぎない
6. 各Unit Completion後に次Unitへ安全に進める
7. P2 Exit Criteriaへ段階的に接続できる

---

# 3. 分割判断

## 3.1 採用

P2を以下の5 Unitへ分割する。

```text
P2-01 Full Template Scanner
        ↓
P2-02 Sync Diff Core
        ↓
P2-03 VariableDefinition Sync Persistence
        ↓
P2-04 Manual Sync Integration
        ↓
P2-05 P2 Fail Closed / Result / Phase Integration
        ↓
P2 Phase Verification
        ↓
CP-P2
```

---

## 3.2 VariableDefinition Read Boundaryを独立Unitにしない理由

P0 Foundationで`modVariableDefinitionData`はすでにRead Boundaryを成立させている。

Public API：

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

取得対象にはSync判定に必要な以下を含む。

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
__RowIndex
```

したがって、

```text
P2-02 VariableDefinition Read Boundary
```

を独立Unitとして追加しても新しい意味のあるProduction Boundaryにならない。

必要なのはReadではなく、

```text
Sync Diff
↓
Write / Metadata Persistence
```

である。

よってP2ではRead Boundaryを再実装せず、P0成立済みContractを再利用する。

---

# 4. P2-01 Full Template Scanner

## 4.1 Objective

P1-04 Minimal Template Scannerを、Design上の完成版`TemplateScanResult`へ拡張する。

```text
P1-04
scanResult
├─ ValidVariables
└─ InvalidCandidates

        ↓

P2-01
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

## 4.2 Primary Production Module

```text
modTemplateScanner
```

## 4.3 In Scope

```text
P1 Candidate Scan維持
VariableName Syntax Validation維持
Valid / Invalid分離維持
Case Insensitive統合維持

ADD:
Subject / Body / Both Location統合
Locations Result
Full TemplateScanResult
```

Baseline Expected例：

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

## 4.4 Preserve

P1-04で成立済みの以下を維持する。

```vb
ScanTemplate( _
    subjectText, _
    bodyText, _
    scanResult _
) As COperationResult
```

原則としてPublic APIを変更しない。

Scannerは引き続き、

```text
Outlook / Word COM非依存
Excel Data Access非依存
VariableDefinition非依存
```

とする。

## 4.5 Primary Verification

```text
Subject Variable
Body Variable
Both Variable
Case Insensitive Location統合
InvalidCandidates Regression
Empty Input Regression
P1-04 Core Regression
OFT Integration
```

関連Test Area：

```text
MTS-SCAN-001
MTS-SCAN-002
MTS-SCAN-003
MTS-SCAN-004
MTS-SCAN-005
```

## 4.6 Completion Boundary

P2-01 Completion時点で、

```text
TemplateScanResultだけで

Valid Variable集合
Invalid Candidate集合
各Variable Location

を後続処理が判断できる
```

こと。

Sync分類はまだ行わない。

---

# 5. P2-02 Sync Diff Core

## 5.1 Objective

完成版TemplateScanResultとCurrent VariableDefinition Snapshotから、Excel非依存でSync差分を分類する。

## 5.2 Primary Production Module

```text
modSyncEngine
```

## 5.3 Input Boundary

```text
TemplateScanResult
+
Current VariableDefinition Snapshot
+
SyncTimestamp
```

Current VariableDefinitionはP0成立済み`modVariableDefinitionData`から取得可能とする。

`modSyncEngine`自身はExcel Tableを読まない。

## 5.4 In Scope

```text
Case Insensitive Identity

New
Existing
Reactivated
Unused
No Change

Rename
= Old Unused + New

Existing側Canonical VariableName保持

Metadata更新内容の論理決定
```

## 5.5 Sync Decision

```text
Templateあり / Definitionなし
→ New

Templateあり / Definitionあり / Active
→ Existing

Templateあり / Definitionあり / Unused
→ Reactivated

Templateなし / Definitionあり / Active
→ Unused

Templateなし / Definitionあり / Unused
→ No Change
```

## 5.6 Metadata Decision

P2-02は「Excelへ書く」のではなく、各分類に対して何を更新すべきかを論理的に決定する。

### New

```text
Status = Active
TemplateLocation = Current Location
FirstDetectedAt = SyncTimestamp
LastDetectedAt = SyncTimestamp
```

### Existing

```text
User Settings = Preserve
Status = Active維持
TemplateLocation = Current Location
FirstDetectedAt = Preserve
LastDetectedAt = SyncTimestamp
```

### Reactivated

```text
User Settings = Preserve
Status = Active
TemplateLocation = Current Location
FirstDetectedAt = Preserve
LastDetectedAt = SyncTimestamp
```

### Unused

```text
User Settings = Preserve
Status = Unused
TemplateLocation = Preserve
FirstDetectedAt = Preserve
LastDetectedAt = Preserve
```

## 5.7 Out of Scope

```text
Excel ListObject更新
OFT読込
Outlook操作
UI通知
Manual Sync Orchestration
```

## 5.8 Primary Verification

```text
New
Existing
Reactivated
Unused
Already Unused
Rename
Case Insensitive Existing
Existing User Settings Preservation
Metadata Decision
One SyncTimestamp
```

関連Test Area：

```text
MTS-SYNC-002
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-006
MTS-SYNC-007
MTS-SYNC-011
```

## 5.9 Completion Boundary

P2-02 Completion時点で、

```text
TemplateScanResult
+
VariableDefinition Snapshot
↓
Sync Classification / Update Plan
```

がExcel非依存で成立すること。

---

# 6. P2-03 VariableDefinition Sync Persistence

## 6.1 Objective

P2-02のSync Decision / Update Planを、Data Access Boundary内でVariableDefinitionへ安全に反映できるようにする。

## 6.2 Primary Production Module

```text
modVariableDefinitionData
```

必要に応じて`modSyncApplication`との接続用Production APIを追加する。

## 6.3 In Scope

Data Accessとして必要なWrite Operation：

```text
New Row追加
Status更新
TemplateLocation更新
FirstDetectedAt設定
LastDetectedAt更新
```

既存ユーザー設定：

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

をSync Persistenceによって破壊しない。

## 6.4 Responsibility Rule

```text
modSyncEngine
= 何を変更するか決める

modVariableDefinitionData
= 決定された変更をExcelへ反映する
```

Data Access自身が、

```text
New / Existing / Reactivated / Unused
```

を再判定しない。

## 6.5 No Physical Delete

Unused VariableはRow削除しない。

```text
Delete Row
= PROHIBITED for normal Unused transition
```

## 6.6 Primary Verification

```text
New Row追加
Existing設定保持
Unused Status更新
Reactivated更新
TemplateLocation更新
FirstDetectedAt規則
LastDetectedAt規則
Already Unused No Change
Row Deleteなし
```

関連Test Area：

```text
MTS-SYNC-002
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-011
```

## 6.7 Completion Boundary

P2-03 Completion時点で、

```text
Sync Update Plan
↓
VariableDefinition Persistence
```

が成立すること。

OFTから開始するManual Sync E2Eはまだ完成扱いしない。

---

# 7. P2-04 Manual Sync Integration

## 7.1 Objective

P1で成立済みのPath / Outlook / WordEditor / Snapshot Boundaryと、P2-01～P2-03を接続し、正常系Manual SyncをProduction Architecture上で成立させる。

## 7.2 Primary Production Module

```text
modSyncApplication
```

Integration対象：

```text
modSettingsData
modOutlookAdapter
modTemplateScanner
modSyncEngine
modVariableDefinitionData
```

## 7.3 Normal Sequence

```text
User Manual Sync
↓
TemplatePath取得
↓
Local Path Resolution
↓
OFT確認
↓
Outlook Readiness
↓
Scan MailItem生成
↓
ReadSubject / ReadBodyText
↓
ScanTemplate
↓
Scan MailItem CloseWithoutSave
↓
Current VariableDefinition取得
↓
SyncTimestamp取得
↓
Sync Diff
↓
VariableDefinition Update
↓
Sync Result
```

## 7.4 In Scope

```text
Manual Sync Entry Point
Production Orchestration
1 SyncTimestamp生成 / 共有
P1 Outlook Lifecycle再利用
Scanner → Sync Engine接続
Sync Engine → Data Access接続
正常系Sync Result生成
```

## 7.5 Out of Scope

P2-04では異常系の網羅を完成扱いしない。

最低限正常系をProduction Architecture上で通す。

```text
Invalid Template
OFT Error
Outlook Error
No-Update Evidence
User-facing Error整理
```

はP2-05で最終接続確認する。

## 7.6 Primary Verification

```text
Baseline OFT Manual Sync
New Integration
Existing Integration
Unused Integration
Reactivated Integration
Rename Integration
Outlook Scan MailItem Lifecycle
Draft / Inspector Residue確認
Sync Result Data
```

関連Test Area：

```text
MTS-SYNC-001
MTS-SYNC-002～008
MTS-MAIL-003 Regression Area
```

## 7.7 Completion Boundary

P2-04 Completion時点で、

> 正常なOFTからManual Syncを実行し、VariableDefinitionへDesignどおりの差分を反映できる

こと。

---

# 8. P2-05 Fail Closed / Sync Result / Phase Integration

## 8.1 Objective

P2の異常系No-Update Boundary、Sync Result、Unused確認Boundary、およびP2全体Regressionを完成させ、P2 Phase Verificationへ接続する。

## 8.2 Primary Production Scope

主に、

```text
modSyncApplication
modVariableDefinitionData
既存Error / Result Boundary
```

をIntegration対象とする。

必要な場合のみ既存Moduleを最小修正する。

## 8.3 Fail Closed / No-Update

以下ではVariableDefinition Updateへ進まない。

```text
Path Resolution Failure
OFT不存在
OFT読込失敗
Outlook Readiness Failure
Scan MailItem生成失敗
Subject / BodyText取得失敗
Scanner Technical Failure
InvalidCandidates >= 1
```

Invalid Candidate：

```text
ScanTemplate
→ Technical Success

InvalidCandidates >= 1
→ Sync Failure / Stop
→ VariableDefinition Update = NONE
```

とする。

## 8.4 Sync Result

少なくとも以下を区別して利用者へ通知可能なDataを生成する。

```text
New
Existing
Unused
```

Reactivatedは内部分類として保持する。

具体的UIはMVP最小方式とし、汎用Notification Frameworkを作らない。

## 8.5 Unused Confirmation Boundary

```text
通常
→ Active Variable取得

必要時
→ Active / Unusedを含む全件取得
```

P0成立済みRead APIを利用可能とする。

UI詳細はImplementation Detailとする。

## 8.6 P2 Regression / Integration

最低限以下を再確認する。

```text
P1 Scanner Contract Regression
P1 Outlook / WordEditor Scan Lifecycle
P1 Cold / Warm Readinessへの不要なRegressionなし
P2 Scanner
P2 Sync Core
P2 Persistence
Manual Sync
Invalid Template No-Update
OFT Error No-Update
```

## 8.7 Primary Verification

関連Test Area：

```text
MTS-TPL-001～004
MTS-SCAN-001～005
MTS-SYNC-001～012
```

ただしFormal MVP TestではなくImplementation Verificationとする。

## 8.8 Completion Boundary

P2-05 Completion後、

```text
P2 Phase Verification
```

を実施可能とする。

P2-05 CompletionだけでCP-P2を自動Establishしない。

---

# 9. Dependency Graph

```text
P1-04 Minimal Scanner
        │
        ▼
P2-01 Full Template Scanner
        │
        ▼
P2-02 Sync Diff Core
        │
        ▼
P2-03 VariableDefinition Sync Persistence
        │
        ▼
P2-04 Manual Sync Integration
        │
        ▼
P2-05 Fail Closed / Result / Phase Integration
        │
        ▼
P2 Phase Verification
        │
        ▼
CP-P2
```

依存方向は一方向とする。

原則として後続Unitの責務を先行Unitへ混在させない。

---

# 10. Unit / Module Matrix

| Unit | Primary Module | 主責務 |
|---|---|---|
| P2-01 | `modTemplateScanner` | Full TemplateScanResult / Locations |
| P2-02 | `modSyncEngine` | Pure Sync Diff / Metadata Decision |
| P2-03 | `modVariableDefinitionData` | Sync Write / Metadata Persistence |
| P2-04 | `modSyncApplication` | Normal Manual Sync Orchestration |
| P2-05 | `modSyncApplication` + Result/Data Access | Fail Closed / Result / Phase Integration |

---

# 11. Unit / Test Area Matrix

| Unit | 主なTest Area |
|---|---|
| P2-01 | MTS-SCAN-001～005 |
| P2-02 | MTS-SYNC-002～007 / 011 Core |
| P2-03 | MTS-SYNC-002～005 / 011 Persistence |
| P2-04 | MTS-SYNC-001～008 Integration |
| P2-05 | MTS-TPL-001～004 / MTS-SYNC-009～012 + P2 Regression |

同一MTS Test Areaへ複数Unitが接続してよい。

Unit VerificationはFormal MVP Test Resultではない。

---

# 12. 各Unit共通実施フロー

P2でもP1と同じ基本フローを採用する。

```text
Boundary / Previous Completion
↓
Implementation Unit Specification
↓
Cross-document Consistency Review
↓
Approved Unit Specification
↓
Production Implementation
↓
VBA Compile
↓
Local / Integration Verification
↓
Finding Assessment
↓
Production Patch Review
↓
Completion Record
```

Blocking Findingがある状態で次UnitをComplete扱いしない。

---

# 13. P2 Phase Exitへの接続

全Unit Completion後にP2 Phase Verificationを実施する。

確認対象：

```text
Full TemplateScanResult
Valid / Invalid / Locations

New
Existing
Reactivated
Unused
Rename

Existing Settings Preservation

TemplateLocation
FirstDetectedAt
LastDetectedAt
SyncTimestamp

Manual Sync Only
Invalid Template No Update
OFT Error No Update
Sync Result
Unused確認Boundary

Blocking Sync / Scanner Finding = NONE
```

P2 Exit Criteriaを満たした場合のみ、

```text
CP-P2
ESTABLISHED
```

を判定する。

---

# 14. 分割しなかった案

## 14.1 6 Unit案

候補：

```text
P2-01 Scanner Completion
P2-02 VariableDefinition Read Boundary
P2-03 Sync Diff Core
P2-04 Metadata Update
P2-05 Sync Application Integration
P2-06 Error / No-Update Gate
```

不採用理由：

`VariableDefinition Read Boundary`はP0で12列Readとして成立済みであり、新規Production Boundaryとして独立させる実益が小さい。

また、

```text
Metadata Update
```

をSync DiffとPersistenceから完全に独立させると、論理更新規則とExcel Writeの責務境界がかえって曖昧になる。

そのため、

```text
Metadata Decision
→ P2-02 Sync Diff Core

Metadata Persistence
→ P2-03 VariableDefinition Sync Persistence
```

へ分離する方が責務が明確である。

## 14.2 4 Unit以下への統合

例えば、

```text
Scanner
Sync
Integration
Verification
```

だけにまとめる案は採用しない。

理由：

```text
Pure Sync Logic
+
Excel Write
```

を同一Unitへ混在させると、Core LogicとInfrastructureの分離が弱くなり、Existing設定保持やMetadata規則のFailure原因を切り分けにくくなる。

---

# 15. Final Decision

P2 Implementation Unitを以下の5 Unitとして正式決定する。

```text
P2-01 Full Template Scanner

P2-02 Sync Diff Core

P2-03 VariableDefinition Sync Persistence

P2-04 Manual Sync Integration

P2-05 Fail Closed / Sync Result / Phase Integration
```

判定：

```text
P2 Unit Decomposition:
APPROVED

Unit Count:
5

P2-01 Entry:
ALLOWED

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

次のUnit Specification対象：

```text
P2-01 Full Template Scanner 実施仕様 v0.1
```
