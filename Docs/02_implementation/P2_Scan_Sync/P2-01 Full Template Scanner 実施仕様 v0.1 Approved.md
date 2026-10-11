# P2-01 Full Template Scanner 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-01 Full Template Scanner 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | **Approved** |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P2 Scan / Sync |
| 対象Implementation Unit | P2-01 Full Template Scanner |
| Primary Production Module | `modTemplateScanner` |
| 前提Implementation Unit | P1-04 Minimal Template Scanner = PASS / COMPLETE |
| Entry Dependency | `CP-P1` |
| Primary Verification | Full TemplateScanResult / Locations / P1-04 Regression |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P2 Scan / Sync Boundary Confirmation v0.1`
- `P2 Implementation Unit Decomposition Decision v0.1`
- `P1-04 Minimal Template Scanner Completion Record v0.1`
- `P2-01 Full Template Scanner 実施仕様 v0.1 Cross-document Consistency Review v0.1`

### v0.1 Consistency Review反映概要

Cross-document Consistency Review結果：

```text
PASS WITH CORRECTIONS
```

Approval前Correctionとして以下3件を反映した。

1. `CR-P2-01-001` — `MTS-SCAN-003`をP2-01単独のFull PASS対象と読めないよう、P2-01はScanner Core Portion（Case Insensitive Identity）を担当し、既存VariableDefinitionの正式表記保持はP2-02 Sync Diff Core / MTS-SYNC-007で完成させることを明示
2. `CR-P2-01-002` — Full TemplateScanResultの構造整合性として、`ValidVariables`と`Locations`の1:1対応、Orphan Location禁止、Invalid CandidateのLocations混入禁止をResult Invariantとして追加
3. `CR-P2-01-003` — Technical DocumentへCurrent Project State / Next Actionを保持しないGovernanceへ整合し、`前提Phase`を`Entry Dependency = CP-P1`へ変更、Related DocumentsのBaseline文書参照をDocument ID中心へ正規化、末尾の進捗記述を削除

本CorrectionによるRequirement / Design / Test Specification / Implementation Plan / BaselineへのSemantic Impactはない。

**Semantic Conflict：NONE**
**Requirement Gap：NONE**
**Design Finding：NONE**
**Technical Spike Reopen：NOT REQUIRED**
**Baseline Change：NOT REQUIRED**
**Blocking Finding：NONE**
**Document Status：Approved**

---

## 2. v0.1 作成概要

本仕様は、P1-04で成立したMinimal Template Scannerを再設計せず、P2で必要となる完成版`TemplateScanResult`へ拡張するためのImplementation Detailを定義する。

P1-04成立済み：

```text
Subject As String
+
BodyText As String
        ↓
modTemplateScanner.ScanTemplate
        ↓
scanResult
├─ ValidVariables
└─ InvalidCandidates
```

P2-01で追加する差分：

```text
scanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
     ├─ VariableName → Subject
     ├─ VariableName → Body
     └─ VariableName → Both
```

P2-01では以下を実施する。

1. P1-04 Public APIを原則維持する
2. Subject / Bodyごとの出現Locationを取得する
3. Case InsensitiveなVariable IdentityのままLocationを統合する
4. `Locations`をFull TemplateScanResultへ追加する
5. `ValidVariables` / `InvalidCandidates`のP1-04 Contractを維持する
6. ScannerのOutlook / Word COM非依存を維持する
7. ScannerのExcel Data Access / VariableDefinition非依存を維持する
8. MTS-SCAN-001～005へ接続可能なProduction Logicを完成させる
9. P1-04 Core / OFT IntegrationのRegressionを確認する
10. P2-02 Sync Diff Core以降の責務を先回り実装しない

本仕様は、承認済みRequirement / Design / Test SpecificationをImplementation Detailへ具体化するものであり、新しい利用者向けRequirementを追加しない。

---

# 3. Source of Truth / Traceability

## 3.1 Requirement

P2-01のPrimary Requirement：

```text
FR-VAR-001  {{VariableName}}形式
FR-VAR-002  VariableName Syntax
FR-VAR-003  同一Variable重複統合
FR-VAR-004  Case Insensitive Identity
FR-VAR-005  Invalid Variable記法検出

FR-SCAN-001 Subject / Bodyを抽出対象とする
FR-SCAN-002 VariableName + Subject / Body / Bothを特定する
FR-SCAN-003 Invalid Candidateも検出する
```

To / CC / BCCはScanner対象外とする。

---

## 3.2 Design

`DOC-MVP-DES §14` に従い、Scannerは以下の2段階処理を維持する。

```text
Subject / BodyText
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
```

Candidate Pattern：

```regex
\{\{([^{}]*)\}\}
```

VariableName Rule：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

完成版概念Result：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

ScannerはWord Document Objectを保持せず、入力はSubject / BodyText文字列Snapshotとする。

---

## 3.3 Test Specification

P2-01が直接接続するTest Area：

```text
MTS-SCAN-001 Subject / Body Variable抽出
MTS-SCAN-002 Location Subject / Body / Both
MTS-SCAN-004 Invalid Candidate検出
MTS-SCAN-005 To / CC / BCC対象外
```

`MTS-SCAN-003 Case Insensitive統合`については、P2-01は以下のScanner Core Portionへ接続する。

```text
Case InsensitiveなVariable Identity
Case違いによるValidVariables重複禁止
Case違いによるLocations重複禁止
```

一方、MTS-SCAN-003 Expectedに含まれる、

```text
既存VariableDefinitionの正式表記を保持する
```

はP2-01単独では完了させない。

これはP2-02 Sync Diff CoreでCurrent VariableDefinitionとの照合を行い、`MTS-SYNC-007`と合わせて成立させる。

したがって、

```text
P2-01 Verification
≠ MTS-SCAN-003 Formal Full PASS
```

とする。

Unit VerificationはFormal MVP Test Resultではない。

---

# 4. 前提Implementation Boundary

## 4.1 P1-04 Public API

P1-04で以下が成立済みである。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

P2-01では原則としてこのPublic APIを維持する。

`Locations`追加のためだけに以下を追加しない。

```text
ScanSubject()
ScanBody()
ScanLocations()
GetLocation()
```

Public Scanner APIは1本を維持する。

---

## 4.2 P1-04 Minimal Result

P1-04成立済み：

```text
scanResult
├─ ValidVariables     → Collection
└─ InvalidCandidates  → Collection
```

`ValidVariables`：

- Case Insensitiveで重複排除
- Subject → BodyTextの順でScan
- 初回検出順を保持
- 初回検出時のVariableName表記を保持

`InvalidCandidates`：

- Syntax違反Candidateを検出
- 元の`{{...}}`表記を保持
- Invalid Candidateが存在してもScanner Technical Failureとはしない

```text
Scan成功
+
InvalidCandidates.Count > 0
→ COperationResult.Success = True
```

Invalid Templateとして後続処理を停止する責務はApplication / Configuration側に残す。

---

## 4.3 P1-04 Implementation Characteristics

P1-04では以下のImplementation方式が成立済みである。

```text
Candidate Scan
→ Late Bound VBScript.RegExp

Variable Validation
→ Late Bound VBScript.RegExp

Case Insensitive重複判定
→ Late Bound Scripting.Dictionary
→ CompareMode = vbTextCompare

Result Carrier
→ Late Bound Scripting.Dictionary
```

P2-01は、具体的な欠陥またはConflictが確認されない限り、この成立済み方式を継承する。

---

# 5. P2-01 Scope

Production実装対象：

```text
modTemplateScanner

Existing:
├─ Candidate Scan
├─ VariableName Validation
├─ ValidVariables
├─ InvalidCandidates
└─ Case Insensitive Dedup

P2-01 ADD:
├─ Source Location認識
├─ Subject Location登録
├─ Body Location登録
├─ Subject / Body重複時Both統合
└─ Locations Result
```

Verification：

```text
Core Verification
+
P1-04 Regression
+
Baseline OFT Integration
+
To / CC / BCC Exclusion確認
```

---

# 6. Out of Scope

P2-01では以下を実装しない。

```text
Sync Engine
New / Existing / Reactivated / Unused判定
VariableDefinition照合
VariableDefinition正式表記へのCanonicalization
TemplateLocation Excel更新
FirstDetectedAt
LastDetectedAt
SyncTimestamp
VariableDefinition Data Access変更
Manual Sync Application
Invalid Template時のVariableDefinition No-Update Orchestration
Configuration Validator
UserForm
Input State
Input Validator
Value Formatter
Subject Render
Body Render
Unresolved Check
Display
Sync Result UI
Unused確認UI
Formal MVP Test
```

また、P2-01のためだけに以下を追加しない。

```text
CTemplateScanResult
CTemplateVariable
CLocation
Scanner専用Interface
Scanner専用Adapter
Generic Collection Framework
Generic Result Framework
Test専用Production Public API
```

---

# 7. Responsibility Boundary

```text
Application / Test Harness
        │
        │ subjectText As String
        │ bodyText As String
        ▼
────────────────────────────────────
Core Logic Boundary
────────────────────────────────────
        │
        ▼
modTemplateScanner.ScanTemplate
        │
        ├─ Candidate Scan
        ├─ VariableName Validation
        ├─ Case Insensitive Identity
        ├─ Valid / Invalid分離
        └─ Location統合
        │
        ▼
COperationResult
+
scanResult As Object
        │
        ├─ ValidVariables
        ├─ InvalidCandidates
        └─ Locations
```

Core Logicから以下へ依存しない。

```text
Outlook.Application
Outlook.MailItem
Outlook.Inspector
Word.Document
Word.Range
Excel.Worksheet
Excel.ListObject
modVariableDefinitionData
modSettingsData
```

---

# 8. Input Contract

## 8.1 subjectText

```vb
ByVal subjectText As String
```

Outlook Adapter等で取得済みのSubject文字列Snapshotを受け取る。

ScannerはSubjectをOutlook Objectから直接取得しない。

---

## 8.2 bodyText

```vb
ByVal bodyText As String
```

表示文字列ベースのBodyText Snapshotを受け取る。

HTMLBodyをScanner Inputとして扱わない。

---

## 8.3 Empty Input

以下はTechnical Errorとしない。

```text
subjectText = ""
bodyText = ""
```

Expected：

```text
ValidVariables.Count = 0
InvalidCandidates.Count = 0
Locations.Count = 0
ScanTemplate = Success
```

P1-04 Empty Input Contractを維持する。

---

# 9. Output Contract

P2-01完了後の`scanResult`：

```text
scanResult
├─ ValidVariables     → Collection
├─ InvalidCandidates  → Collection
└─ Locations          → Late Bound Scripting.Dictionary
```

---

## 9.1 ValidVariables

P1-04 Contractを変更しない。

```text
Type:
Collection

Identity:
Case Insensitive

Ordering:
Subject → BodyTextの初回検出順

Display Casing:
Scanner内の初回検出表記
```

例：

```text
Subject:
{{ModelName}} / {{GateDate}} / {{modelname}}

Body:
{{Department}} / {{GateDate}} / {{Comment}}
```

Expected：

```text
ValidVariables:
1 ModelName
2 GateDate
3 Department
4 Comment
```

`modelname`を別Variableとして追加しない。

---

## 9.2 InvalidCandidates

P1-04 Contractを変更しない。

```text
Type:
Collection

Value:
検出した元の {{...}} 表記
```

例：

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

Expected：

```text
ValidVariablesへ入れない
InvalidCandidatesへ保持する
```

Invalid Candidateの重複保持 / 重複排除は、P1-04と同様にPublic Contractとして新規固定しない。

---

## 9.3 Locations

P2-01で新規追加する。

```text
Type:
Late Bound Scripting.Dictionary

CompareMode:
vbTextCompare

Key:
Valid VariableName

Value:
"Subject"
"Body"
"Both"
```

例：

```text
Locations("ModelName")  = "Both"
Locations("GateDate")   = "Both"
Locations("Department") = "Body"
Locations("Comment")    = "Body"
```

Dictionary LookupはCase Insensitiveとする。

以下は同一Keyとして扱えること。

```text
Locations("ModelName")
Locations("modelname")
Locations("MODELNAME")
```

## 9.4 TemplateScanResult Structural Invariant

Success Resultでは、`ValidVariables`と`Locations`の構造を必ず整合させる。

```text
Locations.Count = ValidVariables.Count
```

さらに、以下を満たす。

```text
For Each Variable in ValidVariables
→ Locations.Exists(Variable) = True

For Each Key in Locations
→ 同一VariableがValidVariablesに1件存在

InvalidCandidates
→ Locationsへ登録しない
```

禁止：

```text
ValidVariablesに存在するがLocationsがない
Locationsに存在するがValidVariablesにない
同一VariableのCase違いでLocations Entryが複数存在する
Invalid CandidateがLocationsへ混入する
```

後続P2-02は、この整合したTemplateScanResultを入力前提として利用できる。

---

# 10. Location Value Contract

許可する値：

```text
Subject
Body
Both
```

その他の文字列をProduction Resultとして生成しない。

LocationはValid Variableだけを対象とする。

Invalid Candidateについて、

```text
InvalidCandidateLocation
```

等の追加OutputはP2-01で導入しない。

Requirement / Design上、Invalid CandidateにLocation情報を返すことは必須化されていない。

---

# 11. Location Merge Rule

## 11.1 Initial Detection

初回Valid Variable検出時：

```text
Source = Subject
→ Locations(VariableName) = "Subject"

Source = Body
→ Locations(VariableName) = "Body"
```

---

## 11.2 Same Source Duplicate

同一Variableが同じSource内に複数回存在：

```text
Subject + Subject
→ Subject

Body + Body
→ Body
```

`Both`へ変更しない。

---

## 11.3 Cross Source Duplicate

同一VariableがSubjectとBodyの双方に存在：

```text
Subject + Body
→ Both

Body + Subject
→ Both
```

Production Scan順はSubject → BodyTextであるため通常は、

```text
Subject
↓
Body検出
↓
Both
```

となる。

---

## 11.4 Case Insensitive Cross Source

例：

```text
Subject:
{{ModelName}}

Body:
{{modelname}}
```

Expected：

```text
ValidVariables.Count = 1
ValidVariables(1) = "ModelName"

Locations.Count = 1
Locations("ModelName") = "Both"
```

Case差異によって別Location Entryを作らない。

---

# 12. Scanner Casing Boundary

ScannerはVariableDefinitionを参照しない。

したがってP2-01で保証するCasingは、

```text
初回検出時のVariableName表記を保持
```

までとする。

MTS-SCAN-003に含まれる、

```text
既存VariableDefinitionの正式表記を保持
```

はP2-01単独責務ではない。

これはP2-02 Sync Diff Coreで、

```text
Template Scan Identity
+
Existing VariableDefinition
↓
Existing側VariableName表記をCanonicalとして保持
```

することで完成させる。

P2-01でVariableDefinition依存を導入してMTS-SCAN-003全体を単独完了扱いしない。

---

# 13. To / CC / BCC Exclusion Boundary

Scanner Public APIは、

```text
Subject
BodyText
```

のみを受け取る。

以下の引数は存在しない。

```text
To
CC
BCC
Recipients
```

したがってP2-01ではTo / CC / BCCをScanner Inputへ追加しない。

MTS-SCAN-005のUnit Verificationでは、

```text
To / CC / BCCに {{Recipient}} 等が存在
+
Subject / BodyにはRecipientが存在しない
```

状態で、Scanner Resultへ`Recipient`が含まれないことをIntegrationで確認可能とする。

---

# 14. Result Carrier Decision

## 14.1 Decision

P2-01では専用`CTemplateScanResult` Classを追加しない。

P1-04のLate Bound Dictionary Resultを拡張する。

```text
scanResult("ValidVariables")
scanResult("InvalidCandidates")
scanResult("Locations")
```

採用理由：

1. P1-04で既に成立している
2. P2-01の追加情報はVariable → Locationの単純Mapである
3. 専用ClassなしでDesign上のTemplateScanResultを表現できる
4. P2-02へ必要な情報を十分渡せる
5. MVPで不要なClass階層を先回り追加しない

---

## 14.2 Locations Carrier

`Locations`にはLate Bound`Scripting.Dictionary`を使用する。

```vb
Set locations = CreateObject("Scripting.Dictionary")
locations.CompareMode = vbTextCompare
```

Keyを`LCase$()`等でPublic Resultへ正規化しない。

Case Insensitive IdentityはDictionaryのCompareModeで処理し、初回検出表記を維持する。

---

# 15. Public API Contract

Production Public API：

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Success時：

```text
scanResult Is Nothing = False

scanResult.Exists("ValidVariables") = True
scanResult.Exists("InvalidCandidates") = True
scanResult.Exists("Locations") = True
```

P2-01のためにPublic APIを追加しない。

---

# 16. Conceptual Algorithm

```text
ScanTemplate
↓
scanResult初期化
↓
ValidVariables Collection生成
↓
InvalidCandidates Collection生成
↓
SeenVariables Dictionary生成
CompareMode = vbTextCompare
↓
Locations Dictionary生成
CompareMode = vbTextCompare
↓
Candidate RegExp生成
↓
VariableName RegExp生成
↓
Subject Scan
│
├─ Candidate抽出
├─ Syntax Validation
├─ Invalid → InvalidCandidates
└─ Valid
    ├─ 未登録 → ValidVariablesへ追加
    ├─ SeenVariablesへ登録
    └─ Locations = Subject
↓
BodyText Scan
│
├─ Candidate抽出
├─ Syntax Validation
├─ Invalid → InvalidCandidates
└─ Valid
    ├─ 未登録 → ValidVariablesへ追加 / Locations = Body
    └─ 既登録
         ├─ Existing Location = Subject → Both
         └─ Existing Location = Body / Both → 維持
↓
scanResultへ
ValidVariables
InvalidCandidates
Locations
を格納
↓
Success Result
```

---

# 17. Recommended Private Helper Boundary

以下は推奨構成であり、Private Helper名は実装時に調整可能とする。

```vb
Private Function ScanText( _
    ByVal sourceText As String, _
    ByVal sourceLocation As String, _
    ByVal candidateRegex As Object, _
    ByVal variableRegex As Object, _
    ByVal seenVariables As Object, _
    ByVal validVariables As Collection, _
    ByVal invalidCandidates As Collection, _
    ByVal locations As Object _
) As Boolean
```

または同等のPrivate処理。

Location統合は必要に応じて以下のようなPrivate Helperへ分離してよい。

```vb
Private Sub RegisterValidVariable( ... )

Private Function MergeLocation( _
    ByVal currentLocation As String, _
    ByVal detectedLocation As String _
) As String
```

Public APIへLocation専用Functionを増やさない。

---

# 18. Location Constants

Production内で以下のLiteralを複数箇所へ散在させないことを推奨する。

```text
Subject
Body
Both
```

`modTemplateScanner`内Private Const等で局所化してよい。

例：

```vb
Private Const LOCATION_SUBJECT As String = "Subject"
Private Const LOCATION_BODY As String = "Body"
Private Const LOCATION_BOTH As String = "Both"
```

共通Constants ModuleをP2-01のためだけに新設することは必須としない。

P2-02以降で共通化の実益が具体化した場合に再評価する。

---

# 19. Candidate / Validation Logic Preservation

P2-01ではP1-04の2段階方式を変更しない。

```text
Candidate Regex
\{\{([^{}]*)\}\}

        ↓

VariableName Regex
^[A-Za-z][A-Za-z0-9_]*$
```

以下のようなCandidateはInvalidとする。

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

以下はValid：

```text
{{GateDate}}
{{PIC_Email}}
{{Model1}}
```

P2-01ではCandidate Pattern自体をより複雑な1本のRegexへ統合しない。

理由：

```text
Candidate検出
+
Syntax判定
```

の責務分離が、Invalid Candidateを保持するRequirementに必要なため。

---

# 20. Invalid Candidate Semantics

Invalid Candidateが存在しても、ScannerはCandidate検出自体に成功している。

したがって、

```text
InvalidCandidates.Count >= 1
```

だけを理由に、

```text
ScanTemplate.Success = False
```

へ変更しない。

P2-01 Result：

```text
Technical Scan Success
+
InvalidCandidates保持
```

後続P2-04 / P2-05で、

```text
InvalidCandidates >= 1
→ Manual Sync Stop
→ VariableDefinition Updateなし
```

へ接続する。

P2-01でManual Sync停止処理を実装しない。

---

# 21. Technical Failure Boundary

P2-01ではP1-04の既存`COperationResult` / Technical Failure方針を維持する。

対象例：

```text
VBScript.RegExp生成失敗
Scripting.Dictionary生成失敗
Collection操作Runtime Error
RegExp Execute Runtime Error
Locations設定Runtime Error
Result Carrier設定Runtime Error
その他の想定外Runtime Error
```

P2-01で新しいError Type体系を導入しない。

未処理VBA Runtime Errorを呼出元へそのまま伝播させない既存方針を維持する。

Technical Failure時にPartial Resultを成功扱いしない。

具体的な既存ErrorType / Message / Target Mappingを変更する必要が生じた場合は、Implementation側だけで変更せずFinding Ruleへ従う。

---

# 22. Production Hard Coding Rule

Production Codeへ特定TemplateのVariableNameをHard Codingしない。

禁止例：

```text
ModelName
GateDate
Department
Comment
GateOwner
```

これらはTest Fixtureでは使用可能。

Production Scannerは任意のFR-VAR-002準拠VariableNameを処理する。

Location判定もVariableName固有条件を持たない。

---

# 23. Core Verification Cases

## C1 Subject Only

Input：

```text
Subject:
{{ModelName}}

Body:
(no variable)
```

Expected：

```text
ValidVariables:
ModelName

Locations:
ModelName = Subject

InvalidCandidates:
0
```

---

## C2 Body Only

Input：

```text
Subject:
(no variable)

Body:
{{Department}}
```

Expected：

```text
ValidVariables:
Department

Locations:
Department = Body

InvalidCandidates:
0
```

---

## C3 Both

Input：

```text
Subject:
{{GateDate}}

Body:
{{GateDate}}
```

Expected：

```text
ValidVariables.Count = 1
GateDate

Locations("GateDate") = Both
```

---

## C4 Case Insensitive Both

Input：

```text
Subject:
{{ModelName}}

Body:
{{modelname}}
```

Expected：

```text
ValidVariables.Count = 1
ValidVariables(1) = ModelName

Locations.Count = 1
Locations("MODELNAME") = Both
```

---

## C5 Multiple Same Source

Input：

```text
Subject:
{{ModelName}} / {{modelname}} / {{MODELNAME}}

Body:
(no variable)
```

Expected：

```text
ValidVariables.Count = 1
Locations("ModelName") = Subject
```

---

## C6 Mixed Locations

Input：

```text
Subject:
{{ModelName}} {{GateDate}}

Body:
{{modelname}} {{GateDate}} {{Department}} {{Comment}}
```

Expected：

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

---

## C7 Invalid Candidates Regression

Input：

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

Expected：

```text
ValidVariablesへ入らない
InvalidCandidatesへ検出
Locationsへ入らない
ScanTemplate Technical Success
```

---

## C8 Valid + Invalid Mixed

Input：

```text
Subject:
{{ModelName}} {{1stGate}}

Body:
{{Department}} {{ UserName }}
```

Expected：

```text
ValidVariables:
ModelName
Department

Locations:
ModelName = Subject
Department = Body

InvalidCandidates:
{{1stGate}}
{{ UserName }}
```

InvalidがValid Location Resultを壊さない。

---

## C9 Empty Input Regression

Input：

```text
Subject = ""
BodyText = ""
```

Expected：

```text
ValidVariables.Count = 0
InvalidCandidates.Count = 0
Locations.Count = 0
Success
```

---

## C10 First Detection Order Regression

Input：

```text
Subject:
{{B}} {{A}}

Body:
{{C}} {{A}}
```

Expected：

```text
ValidVariables:
B
A
C
```

Location：

```text
B = Subject
A = Both
C = Body
```

P1-04の初回検出順を維持する。

---

## C11 TemplateScanResult Structural Invariant

Input：

```text
Subject:
{{ModelName}} {{GateDate}} {{1stGate}}

Body:
{{modelname}} {{Department}}
```

Expected：

```text
ValidVariables:
ModelName
GateDate
Department

Locations:
ModelName = Both
GateDate = Subject
Department = Body

InvalidCandidates:
{{1stGate}}
```

Structural Check：

```text
Locations.Count = ValidVariables.Count

ValidVariablesの全件についてLocations.Exists = True

Locationsの全KeyがValidVariablesに対応

InvalidCandidatesはLocationsへ存在しない
```

---

# 24. Baseline OFT Integration Verification

P1で成立済みのProduction経路を使用する。

```text
Settings / Path Resolution
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
```

Baseline OFT Expected：

```text
ValidVariables:
ModelName
GateDate
Department
Comment
```

Locations Expected：

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

InvalidCandidates：

```text
0
```

IntegrationではScan用MailItemをDisplayしない。

P2-01が`modOutlookAdapter`を変更しない限り、Outlook Lifecycle自体をP2-01で再設計しない。

---

# 25. To / CC / BCC Integration Variant

MTS-SCAN-005へ接続するため、必要に応じてTest用OFTで以下を設定する。

```text
To:
{{Recipient}}

CC:
{{CcRecipient}}

BCC:
{{BccRecipient}}
```

Subject / Bodyに同名Variableを置かない。

Scanner Inputは引き続き、

```text
Subject
BodyText
```

のみとする。

Expected：

```text
Recipient
CcRecipient
BccRecipient
```

が、

```text
ValidVariables
Locations
```

へ含まれない。

このVerificationのためにScannerへRecipient APIを追加しない。

---

# 26. P1-04 Regression Scope

P2-01は既存`modTemplateScanner`を変更するため、P1-04主要Regressionを必須とする。

最低限：

```text
P1-04 C1 Baseline Happy Path
P1-04 C2 Case Insensitive Integration
P1-04 C3 Invalid Candidate Detection
P1-04 C4 Empty Input
P1-04 OFT Integration
```

Regression Expected：

```text
ValidVariables Contract維持
InvalidCandidates Contract維持
初回検出順維持
初回検出表記維持
Scanner Technical Success / Invalid分離維持
```

---

# 27. P1 / P2 Downstream Regression Boundary

P2-01 Production APIを維持するため、P1-05 / P1-06 / P1-07のSemantic Contractを変更しない。

`scanResult`へ`Locations` Keyを追加しても、既存呼出側が、

```text
ValidVariables
InvalidCandidates
```

を従来どおり取得できることをStatic Reviewまたは必要最小限Integrationで確認する。

P2-01だけを理由にP1 Walking Skeleton全体のWarm / Cold Full E2Eを毎回必須再実行しない。

ただし以下のいずれかが発生した場合はRegression範囲を拡大する。

```text
modOutlookAdapter変更
ScanTemplate Public API変更
COperationResult Semantic変更
Subject / BodyText Input Boundary変更
MailItem Lifecycle変更
```

---

# 28. Warm / Cold Start

P2-01 Core LogicはOutlook Start Stateに依存しない。

Integration Verificationは成立済みP1経路を1つ以上利用する。

P2-01で`modOutlookAdapter`を変更しない場合、

```text
Warm Full Regression
+
Cold Full Regression
```

の両方をUnit Completion必須条件とはしない。

P2 Phase Verificationでは必要なP1 Lifecycle Regression範囲を再評価する。

---

# 29. Compile Evidence

P2-01 Verificationでは以下を明示的に確認する。

```text
Debug
↓
Compile VBAProject
↓
PASS
```

Compile不可の場合、P2-01をPASS扱いしない。

---

# 30. Evidence

最低限以下を記録する。

```text
Workbook
Execution Baseline
Production Module Version
Compile Result

Core:
Case ID
Subject Input
BodyText Input
ScanTemplate Result
ValidVariables Count
ValidVariables一覧
InvalidCandidates Count
InvalidCandidates一覧
Locations Count
Variable → Location一覧

Integration:
Resolved OFT Path
Outlook Start State
CreateMailFromTemplate Result
ReadSubject Result
Subject Snapshot
ReadBodyText Result
BodyText Length
ScanTemplate Result
ValidVariables
InvalidCandidates
Locations
CloseWithoutSave Result

Regression:
P1-04 Core Regression
P1-04 Integration Regression
既存Public API維持確認
```

BodyText全文をEvidenceへ必須出力しない。

Location判定に必要なVariable存在箇所を確認できればよい。

---

# 31. Production Patch想定

P2-01で想定するProduction Change：

```text
MODIFY:
modTemplateScanner
```

原則として変更しない：

```text
modResult
modSettingsData
modVariableDefinitionData
modOptionMasterData
modOutlookAdapter
modSubjectRenderer
modUnresolvedChecker
modMailApplication
CErrorInfo
COperationResult
```

既存Module変更が必要になった場合は、実装前に必要性と影響をFindingとして確認する。

---

# 32. Test Artifact想定

想定するTest Artifact：

```text
modP2_01FullTemplateScannerCoreTest
modP2_01FullTemplateScannerIntegrationTest
```

必要に応じて1 Moduleへまとめてよい。

Test Artifact命名の細部はImplementation Detailとする。

Production CodeへTest専用Public APIを追加しない。

---

# 33. Implementation Detail Rule

実装時に変更してよい事項：

```text
Private Helper名
Local Variable名
Locations用Private Const名
RegExp生成Helper構成
Dictionary生成Helper構成
Location Merge Helper構成
Debug.Print内容
Test Module内部構成
Collection列挙方法
```

以下は変更してはならない。

```text
Subject / BodyText String Snapshot Input
ScanTemplate Public API原則維持
Candidate Scan → Syntax Validationの2段階方式
Valid / Invalid分離
Case Insensitive Identity
ValidVariables Contract
InvalidCandidates Contract
Locations = Subject / Body / Both
Scanner COM非依存
Scanner Excel Data Access非依存
Invalid CandidateをTechnical Failure扱いしない
To / CC / BCC対象外
Sync責務を混在させない
```

変更が必要に見える場合はFinding Ruleへ従う。

---

# 34. Finding Rule

Implementation中にExpectedと異なる事象が出た場合：

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

例：

### Implementation Defect

```text
Subject / Body双方にあるVariableがBothにならない
Case違いでLocationsが2件になる
```

### Test Artifact Defect

```text
Baseline OFTの想定Variableが実際にはBodyに存在しない
```

### Requirement Gap

```text
Invalid CandidateにもLocation表示が利用者要件として必要と判明
```

### Design Finding

```text
既存ScanTemplate APIではDesign上必要なResultを表現不能と判明
```

### Technical Finding

```text
Late Bound Dictionary構造では通常実装・Verificationが困難な技術制約が判明
```

Requirement Gap / Design FindingをImplementation側だけで解決しない。

---

# 35. Technical Spike Reopen Rule

P2-01では原則としてTechnical Spikeを再開しない。

以下のような新しいTechnical Questionが具体化した場合のみ再評価する。

```text
通常Implementation + Verificationでは
大きな手戻りRiskを回避できない
```

`Locations` Dictionary追加やLocation Mergeは通常Implementation範囲とし、Technical Spike対象としない。

---

# 36. Traceability Summary

```text
FR-VAR-001 / 002
↓
Candidate Scan + VariableName Validation
↓
MTS-SCAN-001 / 004

FR-VAR-003 / FR-VAR-004 Scanner Portion
↓
Case Insensitive Seen Dictionary
↓
ValidVariables Dedup
+
Locations Dedup
↓
MTS-SCAN-003 Scanner Core Portion

FR-VAR-004 Existing VariableDefinition Casing
↓
P2-02 Sync Diff Core
↓
MTS-SYNC-007
+
MTS-SCAN-003 Full Expected

FR-SCAN-001
↓
ScanTemplate(subjectText, bodyText)
↓
To / CC / BCC Inputなし
↓
MTS-SCAN-001 / 005

FR-SCAN-002
↓
Locations Dictionary
↓
Subject / Body / Both
↓
MTS-SCAN-002

FR-SCAN-003 / FR-VAR-005
↓
InvalidCandidates
↓
MTS-SCAN-004
```

---

# 37. Consistency Review対象

本仕様をApproved化する前に、以下とのCross-document Consistency Reviewを実施する。

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
P1-04 Minimal Template Scanner Completion Record v0.1
P2 Scan / Sync Boundary Confirmation v0.1
P2 Implementation Unit Decomposition Decision v0.1
```

Review観点：

```text
Requirement Conflict
Design Conflict
Test Specification Conflict
Implementation Plan Conflict
P1-04 Contract Conflict
P2 Boundary Conflict
P2 Unit Decomposition Conflict
Scope Expansion
Traceability Break
Requirement Gap
Design Finding
Technical Spike Reopen
Baseline Change
Governance Conflict
```

---

# 38. Approval Criteria

本仕様をApprovedとする条件：

```text
Cross-document Consistency Review
= PASS
または
PASS WITH CORRECTIONS
+
Corrections Applied

Blocking Finding = 0

Requirement Gap = 0
またはSource of Truthへ反映済み

Design Finding = 0
またはSource of Truthへ反映済み

Technical Spike Reopen = Not Required
または必要Spike完了済み

Baseline Change = Not Required
またはBaseline Governanceに従い処理済み
```

Approved前にProduction実装をSource of Truth化しない。

---

# 39. Verification PASS Criteria

P2-01 Verification最低PASS条件：

```text
VBA Compile                               PASS

Core C1 Subject Only                      PASS
Core C2 Body Only                         PASS
Core C3 Both                              PASS
Core C4 Case Insensitive Both             PASS
Core C5 Multiple Same Source              PASS
Core C6 Mixed Locations                   PASS
Core C7 Invalid Regression                PASS
Core C8 Valid + Invalid Mixed              PASS
Core C9 Empty Input                       PASS
Core C10 First Detection Order Regression PASS
Core C11 Result Structural Invariant      PASS

Baseline OFT Integration                  PASS
MTS-SCAN-003 Scanner Core Portion         PASS
MTS-SCAN-005 Boundary Verification         PASS

P1-04 Core Regression                     PASS
P1-04 OFT Integration Regression          PASS

Public API Preserved                      PASS
ValidVariables Contract Preserved         PASS
InvalidCandidates Contract Preserved      PASS

Outlook / Word COM Dependency             NONE
Excel Data Access Dependency              NONE
Sync Responsibility Leakage               NONE

Unhandled Runtime Error                   NONE
Blocking Finding                          0
```

---

# 40. P2-01 Completion Criteria

P2-01を`PASS / COMPLETE`と判定する条件：

```text
Approved Unit Specification               PASS
VBA Compile                               PASS
modTemplateScanner Production Patch        PASS

Full TemplateScanResult                   PASS
ValidVariables                            PASS
InvalidCandidates                         PASS
Locations                                 PASS
TemplateScanResult Structural Invariant   PASS

Subject Location                          PASS
Body Location                             PASS
Both Location                             PASS
Case Insensitive Location Merge           PASS

P1-04 Regression                          PASS
Baseline OFT Integration                  PASS
Production Patch Review                   PASS
Finding Assessment                        PASS

Blocking Finding = 0                      PASS
```

P2-01 Completionは`CP-P2`成立条件の一部であり、P2 Phase Exit Criteria全体の成立を意味しない。

---

# 41. API Contract Summary

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Full Result：

```text
scanResult
├─ ValidVariables
│   └─ Collection
│
├─ InvalidCandidates
│   └─ Collection
│
└─ Locations
    └─ Scripting.Dictionary
       CompareMode = vbTextCompare
       VariableName → Subject / Body / Both
```

Scannerの責務：

```text
String Snapshot
↓
Template Syntax / Identity / Location
↓
TemplateScanResult
```

Scannerの責務ではない：

```text
VariableDefinition Canonical Casing
Sync Diff
Excel Persistence
Manual Sync
UI
```

---

# 42. Final Implementation Boundary

P2-01では、

> **P1-04のMinimal Scanner Contractを変更せず、Valid VariableのCase Insensitive Identityを維持したままSubject / Body / Bothを統合し、`Locations`を追加したFull TemplateScanResultを生成する**

ことをProduction Goalとする。

Approval Result：

```text
P2-01 Specification:
APPROVED

Cross-document Consistency Review:
PASS WITH CORRECTIONS
→ CORRECTIONS APPLIED

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
NONE
```
