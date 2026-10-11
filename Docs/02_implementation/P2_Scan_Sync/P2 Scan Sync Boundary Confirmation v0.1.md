# P2 Scan / Sync Boundary Confirmation v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2 Scan / Sync Boundary Confirmation |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Phase Boundary Confirmation |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P2 Scan / Sync |
| Entry Dependency | CP-P0 / CP-P1 |
| 前提状態 | P1 Walking Skeleton = PASS / COMPLETE / CP-P1 ESTABLISHED |
| Primary Objective | Template Variable検出とVariableDefinition同期の完成に向け、P1成立済みBoundaryとP2実装責務を固定する |
| Boundary Result | **CONFIRMED** |
| Blocking Finding | **NONE** |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P1-04 Minimal Template Scanner Completion Record v0.1`
- `P1 Phase Verification Record v0.1`
- `CP-P1 Establishment Record v0.1`

---

## 2. 目的

本書は、P2 Scan / SyncへProduction実装を追加する前に、以下を確認・固定する。

1. P1-04 Minimal Template Scannerで成立済みのProduction Contract
2. P2で完成させるTemplate Scannerの追加責務
3. Sync Engine / VariableDefinition Data Access / Sync Applicationの責務分界
4. Invalid Template / OFT Error等でVariableDefinitionを更新しないFail Closed Boundary
5. P2で扱うMetadata更新規則
6. P2で扱わない後続Phase責務
7. P2 Implementation Unit分割およびUnit Specification作成に必要な前提Boundary

本書はRequirement / Design / Test Specificationを再定義しない。

BL-MVP-003で承認済みの仕様を、P2 Implementationへ落とし込むためのBoundary確認文書とする。

---

## 3. P2 Entry Confirmation

P1 Walking Skeletonでは、Production Architecture上で以下が成立済みである。

```text
Excel
↓
OFT
↓
Classic Outlook Readiness
↓
MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText Snapshot
↓
Template Scanner
↓
Render
↓
Unresolved Check
↓
Display
```

P1 Phase VerificationはPASSし、CP-P1はESTABLISHEDである。

したがってP2は、P1で成立したOFT / Outlook / WordEditor / Snapshot Boundaryを再構築せず、その上へScan / Sync機能を追加する。

```text
P2 Scan / Sync
ENTRY:
ALLOWED
```

---

# 4. P1から継承する確定Boundary

## 4.1 Scanner Input Boundary

P1-04でScanner入力は以下に固定されている。

```text
Subject As String
BodyText As String
```

Production Public API：

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

P2でも原則としてこのPublic APIを維持する。

Scannerへ以下を渡さない。

```text
MailItem
Inspector
WordEditor
Word Document
Word Range
Excel ListObject
VariableDefinition Table Object
```

Outlook / Word COM ObjectはOutlook Adapter内部へ閉じ込め、Scannerには表示文字列Snapshotのみを渡す。

---

## 4.2 P1 Minimal Scan Result

P1-04では、`scanResult` はLate Bound `Scripting.Dictionary` として成立済みである。

```text
scanResult
├─ ValidVariables
└─ InvalidCandidates
```

`ValidVariables`：

- `Collection`
- Case Insensitiveで同一Variableを統合
- Subject → BodyTextの順でScan
- 初回検出順を保持
- P1では初回検出時のVariableName表記を保持

`InvalidCandidates`：

- VariableName Syntax違反Candidateを保持
- 元の `{{...}}` 表記を保持
- Invalid Candidateの存在自体はScanner Technical Failureとは扱わない

```text
Scanner処理成功
+
InvalidCandidates.Count > 0

→ ScanTemplate()自体はSuccess
```

後続処理を停止する判断はApplication / Configuration側の責務とする。

---

## 4.3 Scanner Algorithm Boundary

P1-04で以下が成立済みである。

```text
Candidate Scan
↓
VariableName Syntax Validation
↓
Valid / Invalid分離
↓
Valid Variable Case Insensitive統合
```

Candidate Pattern：

```regex
\{\{([^{}]*)\}\}
```

VariableName Rule：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

P2ではこの成立済み方式を不要に再設計しない。

Production DefectまたはDesign Conflictが確認されない限り、P1-04 Scanner Coreを拡張して使用する。

---

## 4.4 P1で意図的に未実装としたScanner責務

P1-04では以下をOut of ScopeとしてP2へ残した。

```text
Subject / Body / Both Location統合
Locations正式出力
完成版TemplateScanResult
Sync Engine
VariableDefinition更新
```

したがってP2 Scanner Completionの主差分は、

```text
P1 Minimal Scan Result
├─ ValidVariables
└─ InvalidCandidates

        ↓ P2

TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

である。

---

# 5. P2 Template Scanner Boundary

## 5.1 P2 Scanner責務

P2で`modTemplateScanner`を完成版Scannerへ拡張する。

対象責務：

```text
Subject / BodyText Snapshot
↓
Candidate Scan
↓
VariableName Syntax Validation
↓
Valid / Invalid分離
↓
Case Insensitive統合
↓
Subject / Body / Both Location統合
↓
TemplateScanResult
```

P2完了時、後続処理はOutlook / Word Object ModelやRegExp処理を再実行せず、`TemplateScanResult`だけから以下を判断可能でなければならない。

```text
どのValid Variableが存在するか
Invalid Candidateが存在するか
各VariableがSubject / Body / Bothのどこに存在するか
```

---

## 5.2 Locations Logical Contract

P2では各Valid Variableについて以下のLocationを表現可能とする。

```text
Subject
Body
Both
```

判定：

```text
Subjectのみ出現
→ Subject

Bodyのみ出現
→ Body

Subject + Bodyの双方に出現
→ Both
```

Baseline OFTでは少なくとも以下を成立可能とする。

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

`Locations`の具体的なVBA Carrier構造はP2最初のScanner Unit Specificationで確定する。

本Boundaryでは、専用Class追加を必須としない。

P1の軽量Result方針を維持し、必要性が確認されない限り過剰なResult Modelを追加しない。

---

## 5.3 Public API Preservation

P2 Scanner Completionでは原則として、

```vb
ScanTemplate(subjectText, bodyText, scanResult) As COperationResult
```

を維持する。

`Locations`追加のためだけにPublic APIを増やさない。

既存Public APIではDesignを満たせない具体的理由が判明した場合のみ、

```text
Implementation Finding
↓
Design Impact確認
↓
必要ならBoundary再確認
```

とする。

Implementation側だけでAPIを変更しない。

---

## 5.4 Scanner Out of Scope

`modTemplateScanner`自身は以下を行わない。

```text
OFT Path解決
OFT存在確認
Outlook起動
MailItem生成
WordEditor取得
VariableDefinition読込
VariableDefinition更新
New / Existing等のSync分類
Configuration Errorとしての停止判断
UI通知
UserForm起動
Render
Unresolved Check
```

Scannerは文字列SnapshotからTemplate構造を解析するCore Logicに限定する。

---

# 6. P2 Sync Engine Boundary

## 6.1 Sync Engine Input

`modSyncEngine`は概念上、以下を比較する。

```text
TemplateScanResult
+
Current VariableDefinition Snapshot
```

比較用に、

```text
Template Dictionary A
VariableDefinition Dictionary B
```

を構築する。

VariableName IdentityはCase Insensitiveとする。

Core LogicからExcel ListObjectを直接操作しない。

---

## 6.2 Sync Classification

P2で以下の差分分類を成立させる。

| Template | VariableDefinition | Current Status | Sync Classification |
|---|---|---|---|
| あり | なし | - | New |
| あり | あり | Active | Existing |
| あり | あり | Unused | Reactivated |
| なし | あり | Active | Unused |
| なし | あり | Unused | No Change |

VariableName比較はCase Insensitiveとする。

Existing Variableが存在する場合、VariableDefinition側の既存VariableName表記を正式表記として保持する。

---

## 6.3 Rename Boundary

Variable Renameを推測しない。

```text
旧Variable
{{PIC}}

↓ Template変更

新Variable
{{PersonInCharge}}
```

Expected：

```text
PIC
→ Unused

PersonInCharge
→ New
```

類似名称、Location、並び順等からRenameを自動推測する処理はP2へ追加しない。

---

# 7. VariableDefinition Update Boundary

## 7.1 New

Newでは新規行を追加する。

初期状態：

```text
VariableName
→ Scannerで検出したVariable

DisplayName
→ 未設定

Type
→ 未設定

Required
→ 未設定

Status
→ Active

TemplateLocation
→ Current TemplateScanResult

FirstDetectedAt
→ SyncTimestamp

LastDetectedAt
→ SyncTimestamp
```

新規Variableを自動的に設定完了扱いしない。

---

## 7.2 Existing

Existingではユーザー設定を保持する。

Syncで上書きしてはならない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

自動管理情報：

```text
Status
→ Active維持

TemplateLocation
→ Current TemplateScanResultへ更新

FirstDetectedAt
→ 既存値保持

LastDetectedAt
→ SyncTimestampへ更新
```

VariableName表記は既存VariableDefinition側を正式表記として保持する。

---

## 7.3 Reactivated

Reactivatedでは既存設定を再利用する。

```text
Status
→ Active

User Settings
→ 保持

TemplateLocation
→ Current TemplateScanResultへ更新

FirstDetectedAt
→ 既存値保持

LastDetectedAt
→ SyncTimestampへ更新
```

新規Variableとして追加し直さない。

---

## 7.4 Unused

Templateから消えたActive Variableは削除しない。

```text
Status
→ Unused
```

以下を保持する。

```text
既存ユーザー設定
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

`LastDetectedAt`はUnused化した時刻ではなく、

> 最後にTemplate上でVariableの存在を確認した時刻

を意味する。

したがってUnused化時に`LastDetectedAt`を更新しない。

既にUnusedであるVariableも管理情報を変更しない。

---

## 7.5 SyncTimestamp

1回のSync処理では、1つの`SyncTimestamp`を共通使用する。

```text
Sync Start
↓
One SyncTimestamp
↓
New / Existing / Reactivated metadata update
```

具体的な取得位置、Helper名、引数形式等はImplementation DetailとしてP2 Unit Specificationで決定する。

---

# 8. VariableDefinition Data Access Boundary

`modVariableDefinitionData`はExcel TableへのData Accessを担当する。

主なP2責務：

```text
Current VariableDefinition取得
New行追加
Status更新
TemplateLocation更新
FirstDetectedAt設定
LastDetectedAt更新
```

一方、Data Access自身で以下を決定しない。

```text
New / Existing / Reactivated / Unused分類
Rename推測
Invalid Template判定
Sync実行可否
User-facing通知内容
```

差分ルールはSync Engine、処理順序はSync Applicationが担当する。

---

# 9. Sync Application Boundary

## 9.1 Manual Sync Only

P2のTemplate Syncはユーザーが明示的に開始するManual Syncとする。

自動Syncは追加しない。

---

## 9.2 Production Sequence

P2 Manual Syncの責務境界は以下とする。

```text
User
↓
Manual Sync
↓
modSettingsData
↓
TemplatePath取得 / Local Path解決
↓
OFT存在確認
↓
modOutlookAdapter
↓
Classic Outlook Readiness
↓
Scan用MailItem生成
↓
ReadSubject / ReadBodyText
↓
modTemplateScanner
↓
TemplateScanResult
↓
Scan用MailItem CloseWithoutSave
↓
InvalidCandidatesあり？
├─ Yes
│   ↓
│ Sync Stop
│ VariableDefinition Update = NONE
│
└─ No
    ↓
Current VariableDefinition取得
↓
modSyncEngine
↓
New / Existing / Reactivated / Unused
↓
VariableDefinition更新
↓
Sync Result生成
↓
UI通知
```

---

## 9.3 Scan MailItem Lifecycle

P2はP1で成立したOutlook / WordEditor Lifecycleを再設計しない。

Manual Sync用MailItemは、

```text
OFTから生成
↓
Subject / BodyText取得
↓
Template ScannerへString Snapshotを渡す
↓
保存せずClose
```

とする。

Scan用MailItemを利用者へDisplayしない。

Cold Start時のVisible Explorer InitializationとScan用MailItem Displayは別Lifecycleとして扱う。

---

# 10. Fail Closed / No-Update Boundary

以下の場合、VariableDefinition Sync Updateへ進まない。

```text
Workbook Relative Path Resolution Failure
OFT不存在
OFT読込失敗
Classic Outlook Readiness Failure
Scan用MailItem生成失敗
Subject / BodyText取得失敗
Scanner Technical Failure
InvalidCandidates 1件以上
```

特にInvalid Variableは、

```text
ScanTemplate
→ Technical Success

TemplateScanResult.InvalidCandidates.Count > 0
→ Manual Sync Stop
→ VariableDefinition Update = NONE
```

とする。

Scanner Technical FailureとTemplate Configuration Errorを混同しない。

---

## 10.1 Update開始後のRuntime Failure

「更新途中でRuntime Errorが発生した場合の完全なTransaction / Rollback方式」は、BL-MVP-003の既存Requirement / Designだけからは固定しない。

P2 Unit Specification作成時に、Data Access更新方式から具体的Riskが発生した場合はImplementation Findingとして評価する。

本Boundaryで新しいTransaction Requirementを追加しない。

---

# 11. Sync Result Boundary

Manual Sync完了後、少なくとも以下を利用者へ通知可能なResult Dataを生成する。

```text
New
Existing
Unused
```

Reactivatedは内部Sync分類として保持する。

利用者向けの具体的な表示方法、MessageBox / Sheet表示等のUI方式はImplementation Detailとする。

P2では「通知可能なDataを生成できること」を最低Boundaryとし、将来拡張を目的とした汎用Notification Frameworkは追加しない。

---

# 12. Unused Confirmation Boundary

Unused Variableは通常処理対象から除外する一方、必要時に確認可能であることを維持する。

P2ではVariableDefinition Data Accessとして、

```text
Activeのみ取得
全件取得
```

が可能なBoundaryを維持する。

具体的なUnused確認UIはImplementation Detailであり、P2 Scanner / Sync Coreへ混在させない。

---

# 13. Module Responsibility Matrix

| Module | P2 Responsibility | P2で持たない責務 |
|---|---|---|
| `modTemplateScanner` | Candidate抽出、Syntax Validation、Case統合、Location統合、TemplateScanResult | Outlook / Excel / Sync分類 |
| `modSyncEngine` | Case Insensitive差分判定、New / Existing / Reactivated / Unused、Metadata更新ルール | Excel ListObject操作、UI |
| `modSyncApplication` | Manual Sync処理順序、Fail Fast / No-Update制御、各Module統合 | Scanner Regex詳細、Excel直接操作 |
| `modVariableDefinitionData` | VariableDefinition Read / Write | Sync分類ルール |
| `modSettingsData` | TemplatePath取得 / Path Resolution | Scanner / Sync判定 |
| `modOutlookAdapter` | Outlook Readiness、MailItem、Subject / BodyText取得、CloseWithoutSave | Variable解析、Sync分類 |
| UI Boundary | Sync開始、結果 / Error通知 | Core Logic |

---

# 14. P2 Invariants

P2実装では以下を維持する。

### INV-P2-001 Scanner COM Independence

```text
modTemplateScanner
≠ Outlook / Word COM依存
```

### INV-P2-002 Scanner Excel Independence

```text
modTemplateScanner
≠ Excel ListObject / Data Access依存
```

### INV-P2-003 Sync Core Excel Independence

```text
modSyncEngine
≠ Excel ListObject直接操作
```

### INV-P2-004 Case Insensitive Identity

VariableName IdentityはScanner / Sync双方でCase Insensitiveとする。

### INV-P2-005 Existing User Settings Preservation

Syncによって既存ユーザー設定を破壊しない。

### INV-P2-006 No Physical Delete

Templateから消えたVariableを削除せずUnused化する。

### INV-P2-007 No Rename Guess

Renameを推測しない。

### INV-P2-008 Invalid Template No Update

Invalid Candidateが存在するTemplateからVariableDefinitionを更新しない。

### INV-P2-009 One SyncTimestamp

同一Sync内のMetadata更新では1つのSyncTimestampを使用する。

### INV-P2-010 LastDetectedAt Meaning

`LastDetectedAt`は最後にTemplate上で存在確認した時刻とし、Unused化時刻へ変更しない。

---

# 15. P2 Out of Scope

P2では以下を完成させない。

```text
Configuration Validator完成
Dynamic UserForm
Input State
Input Validation
Date Parsing / Formatting
Value Formatter
Full Subject Render
Full Body Render
Current Configuration Guardを含むFull Mail Generation
Unresolved Checker最終統合
最終Error Taxonomy
Error Aggregation / Priority
Validation Error Control強調
Formal MVP Test
Test Candidate Build
```

これらはP3以降の責務とする。

また、P2のためだけに以下を導入しない。

```text
Generic Repository Framework
Dependency Injection Framework
Sync専用Interface階層
汎用Event Bus
汎用Transaction Framework
将来拡張用未使用Class
```

---

# 16. Formal Testとの境界

P2 Implementation Verificationでは、以下のMVP Test Areaへ接続可能なProduction Logicを成立させる。

```text
MTS-TPL-001 ～ MTS-TPL-004
MTS-SCAN-001 ～ MTS-SCAN-005
MTS-SYNC-001 ～ MTS-SYNC-012
```

ただしP2 Verification結果を、

```text
Formal MVP Test PASS
```

として記録しない。

Formal MVP TestはP7後のTest Candidate Buildに対して実施する。

---

# 17. P2 Phase Verification Boundary

P2 Exitまでに最低限以下を確認可能とする。

```text
Valid VariableをSubject / Bodyから抽出
Invalid Candidate検出
Case Insensitive統合
Subject / Body / Both Location統合

New追加
Existing設定保持
Unused化
Reactivated
Rename = Old Unused + New

TemplateLocation更新
FirstDetectedAt更新
LastDetectedAt更新
1 SyncTimestamp共有

OFT不存在 → No Update
Invalid Variable → No Update

Sync Result生成
```

Phase Exit Criteria：

```text
TemplateScanResultだけで後続処理が
Variable集合とInvalid Candidateを判断可能

Sync差分分類がDesignどおり成立

Existingユーザー設定をSyncが破壊しない

Invalid TemplateからVariableDefinitionを更新できない

Sync Metadata規則が成立

Blocking Sync / Scanner Finding = NONE
```

---

# 18. Implementation Detailとして残す事項

本Boundaryでは以下を固定しない。

```text
Locationsの具体的なDictionary / Collection構造
Dictionary Key正規化の具体コード
VBScript.RegExp生成Helper
SyncTimestamp取得Helper名
SyncTimestamp引渡し方法
Sync Resultの具体的なCarrier
同期結果UIの表示形式
Unused確認UIの具体形式
Data Access更新用Private Helper構成
Debug.Print / Evidence出力形式
```

P1-04で成立済みのLate Binding方式は、変更理由がなければ継続可能とする。

ただしP2 Boundaryの目的はBinding方式そのものを固定することではない。

---

# 19. Finding / Escalation Rule

P2実装中に既存Boundaryで処理できない事象が確認された場合は、Implementation側だけで仕様変更しない。

```text
Unexpected Observation
↓
Classification
├─ Implementation Defect
├─ Test Artifact Defect
├─ Requirement Gap
├─ Design Finding
└─ Technical Finding
```

Requirement GapまたはDesign Findingである場合は、P2実装を根拠に暗黙変更せず、Source of Truth文書側へ戻す。

Technical Spikeは、新しいTechnical Questionが通常Implementation + Verificationでは遅すぎる場合のみ要否を再判定する。

---

# 20. Cross-Document Consistency Assessment

本Boundary Confirmationでは以下を照合した。

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
P1-04 Minimal Template Scanner Completion Record v0.1
P1 Phase Verification / CP-P1
```

確認結果：

```text
Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P1-04 Contract Conflict:
NONE

Blocking Requirement Gap:
NONE

Blocking Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
NONE
```

---

# 21. Boundary Decision

P2 Scan / SyncのImplementation Boundaryを以下として確定する。

```text
P1 Scanner Contract
↓
維持

ValidVariables
InvalidCandidates
↓
Locations追加
↓
完成版TemplateScanResult

        +

Current VariableDefinition
↓
Case Insensitive Sync Diff
↓
New / Existing / Reactivated / Unused
↓
Metadata Rule
↓
VariableDefinition Data Access
↓
Manual Sync Result
```

P2では、

> **P1で成立したString Snapshot Scanner Boundaryを維持したまま、Location情報とVariableDefinition同期を追加し、Invalid Templateからの更新を禁止する**

ことを主Boundaryとする。

最終判定：

```text
P2 Scan / Sync Boundary:
CONFIRMED

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
0

P2 Implementation Unit Decomposition:
ALLOWED
```
