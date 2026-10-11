# P1-04 Minimal Template Scanner 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-04 Minimal Template Scanner 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Approved |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-04 Minimal Template Scanner |
| Primary Production Module | `modTemplateScanner` |
| 前提Implementation Unit | P1-03 Template Snapshot Boundary = PASS / COMPLETE |
| Primary Verification | Minimal Scanner Core + P1-03 Snapshot Integration |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P1-03 Template Snapshot Boundary 実施仕様 v0.1`
- `P1-03 Template Snapshot Boundary Completion Record v0.1`

### v0.1 Consistency Review反映概要

`P1-04 Minimal Template Scanner 実施仕様 v0.1 Consistency Review v0.1` の結果を反映し、本v0.1をApprovedとした。

Reviewでは、`DOC-MVP-REQ` / `DOC-MVP-DES` / `DOC-MVP-TESTSPEC` / `DOC-MVP-IMPL` / P1-03 Completion Boundaryとの間に、Blocking Semantic Conflict、Scope Expansion、Traceability Breakは確認されなかった。

Approval前に以下のConsistency Correctionのみ実施した。

1. `InvalidCandidates` の重複保持をP1-04 Public Contractとして固定しないよう補正した
2. P2でのPublic API Signatureについて「変更禁止」ではなく「原則維持。既存Design達成に変更が必要な場合はDesign Findingとして扱う」に統一した

上記CorrectionはP1-04のScanner責務、Requirement、Design、Test Specification、Baselineを変更しない。

**Consistency Review：PASS**
**Blocking Finding：NONE**
**Semantic Change：NONE**
**Document Status：Approved**

### v0.1 作成概要

P1-03で成立したSubject / BodyText文字列Snapshot Boundaryを入力として、P1 Walking Skeletonに必要な最小Happy PathのTemplate ScannerをProduction `modTemplateScanner` 上で成立させる。

本Unitでは以下を行う。

1. `Subject As String` / `BodyText As String` をScanner入力とする
2. `{{...}}` Candidate Scanを行う
3. Candidate内部文字列へVariableName Syntax Validationを行う
4. Valid / Invalidを分離する
5. Valid VariableをCase Insensitiveに統合する
6. Invalid Candidateの元記述を保持する
7. P2でLocationを追加してもPublic APIを変更しなくてよいLightweight Scan Result Boundaryを確立する
8. Outlook / Word COM ObjectおよびExcel Data Accessへ依存しないCore Logic Boundaryを維持する
9. VariableNameをProduction CodeへHard Codingしない
10. P1-03 SnapshotからScannerへ接続できることをVerificationする

P1-04はScanner完成版を実装するUnitではない。

Subject / Body / Both Location統合、正式な完成版TemplateScanResult、Sync Engineとの接続はP2へ残す。

本仕様は既存Requirement / DesignをP1 Walking Skeleton用のImplementation Detailへ具体化するものであり、新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Detail / Unit Specification**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-04の目的は、Production Architecture上で以下の最小Scanner経路を成立させることである。

```text
Subject As String
+
BodyText As String
        ↓
modTemplateScanner
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
        ↓
Minimal Scan Result
├─ ValidVariables
└─ InvalidCandidates
```

これにより、後続P1処理がVariableNameをProduction CodeへHard Codingせず、Templateから動的に取得したVariable集合を使用できる状態を作る。

本UnitではTemplate ScannerそのものをP2完成状態まで実装しない。

---

# 3. Baseline上の根拠

## 3.1 P1 Walking Skeleton

`DOC-MVP-IMPL` のP1では、Production Architecture上で以下の経路を成立させる。

```text
Subject / BodyText取得
↓
Template Scanner
↓
Input Value
↓
Subject Render
↓
Word Range Body Render
↓
...
```

P1の `modTemplateScanner` は「最小Happy Path」として実装する。

また、VariableName等をProduction CodeへHard CodingしてWalking Skeletonを成立させてはならない。

したがってP1-04では、最終Module `modTemplateScanner` を使用して正常TemplateからVariable集合を動的に取得できる最小Production Boundaryを作る。

## 3.2 Design上のScanner Architecture

`DOC-MVP-DES` ではTemplate Scannerを以下の2段階処理として定義する。

```text
Subject / BodyText
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
```

Candidate Scanの設計例：

```regex
\{\{([^{}]*)\}\}
```

VariableName Syntax：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

VariableName比較はCase Insensitiveとする。

ScannerはOutlook / Word COM Objectを保持しない。

Scanner入力はSubject / BodyTextの文字列Snapshotとする。

## 3.3 Final Scannerとの関係

最終Design上のTemplateScanResultは概念上以下を保持する。

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

ただし `DOC-MVP-IMPL` では、Location統合を含む完成版Template ScannerはP2 Scan / SyncのScopeとしている。

P1-04ではP1 Walking Skeletonに必要な以下を先に成立させる。

```text
ValidVariables
InvalidCandidates
```

P2では同じScanner Boundaryを拡張し、以下を完成させる。

```text
Locations
Subject / Body / Both統合
完成版TemplateScanResult
Sync接続
```

この段階的実装はFinal Requirementを削除・変更するものではない。

---

# 4. 前提Boundary

P1-03で以下が成立済みである。

```text
Active MailItem
├─ ReadSubject()
│    ↓
│  Subject As String
│
└─ ReadBodyText()
     ↓
   BodyText As String
```

P1-04ではこのBoundaryをそのまま利用する。

以下をP1-04で再実装しない。

```text
Classic Outlook Readiness
MailItem生成
Inspector取得
WordEditor取得
Word Document取得
Subject取得
BodyText取得
CloseWithoutSave
```

---

# 5. Scope

P1-04のProduction実装対象は以下とする。

```text
modTemplateScanner
├─ Subject String受領
├─ BodyText String受領
├─ Candidate Scan
├─ VariableName Syntax Validation
├─ Valid / Invalid分離
├─ Valid Variable Case Insensitive統合
├─ Invalid Candidate元記述保持
├─ Lightweight Scan Result生成
├─ Scanner技術ErrorのCOperationResult変換
└─ Outlook / Word / Excel非依存維持
```

P1-04でProduction Codeへ実装するScanner機能は、P1 Walking Skeletonの後続処理がVariable集合を動的に利用できる最小範囲とする。

---

# 6. Out of Scope

P1-04では以下を実装しない。

```text
Subject / Body / Both Location統合
Locations正式出力
完成版TemplateScanResult
Sync Engine
modSyncApplication
New / Existing / Reactivated / Unused判定
Rename判定
VariableDefinition更新
TemplateLocation更新
FirstDetectedAt / LastDetectedAt
SyncTimestamp
Existing VariableDefinition正式表記保持
Configuration Validator
UserForm
Input State
Value Formatter
Subject Renderer
Body Renderer
Unresolved Checker
DisplayMail
```

また、P1-04のためだけに以下を追加しない。

```text
CTemplateScanResult専用Class
Scanner専用Interface
Scanner専用Adapter
Outlook Object Wrapper
Word Object Wrapper
Excel Data Access Wrapper
Test専用Production Public API
```

To / CC / BCCを読むProduction Codeも追加しない。

Scanner APIの入力自体をSubject / BodyTextに限定することで、To / CC / BCCをScanner対象外とするDesign Boundaryを維持する。

---

# 7. Responsibility Boundary

## 7.1 Layer Boundary

```text
Application
    │
    │ Subject As String
    │ BodyText As String
    ▼
──────────────────────────────
modTemplateScanner
Core Logic
──────────────────────────────
    │
    │ Scan Result
    │ COperationResult
    ▼
Application / downstream Core
```

`modTemplateScanner` は以下へ直接依存しない。

```text
Outlook.Application
MailItem
Inspector
WordEditor
Word Document
Word Range
Explorer
Excel Workbook
Excel Worksheet
Excel ListObject
VariableDefinition Table
OptionMaster Table
```

## 7.2 Scannerの責務

Scannerの責務：

```text
文字列からVariable Candidateを検出
↓
VariableName Syntaxを判定
↓
Valid / Invalidを分類
↓
Valid VariableをCase Insensitiveに統合
↓
軽量Scan Resultを返す
```

Scannerの非責務：

```text
Invalid Candidateがある場合に業務処理を停止する判断
VariableDefinitionとの整合判定
正式VariableName表記の決定
Sync差分判定
Input Validation
Render
UI通知
```

Invalid CandidateをConfiguration Errorとして扱い後続処理を停止する判断は、後続Application / Configuration側の責務とする。

---

# 8. Production Public API

## 8.1 Public API

P1-04では以下をProduction Boundaryへ追加する。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

`scanResult` はLate Bound `Scripting.Dictionary` を使用するLightweight Result Carrierとする。

専用Result Classは追加しない。

## 8.2 Public API安定性

P1-04では以下のResult Keyを保証する。

```text
ValidVariables
InvalidCandidates
```

P2では、原則としてPublic Function Signatureを維持したまま、必要に応じてResultへ以下を追加可能とする。

```text
Locations
```

P1-04からP2への拡張では、以下のPublic APIを維持することを第一候補とする。

```vb
ScanTemplate(subjectText, bodyText, scanResult)
```

ただし、P2 Implementationで既存Requirement / Designを満たすためにSignature変更が必要であることが具体的に判明した場合は、Design Findingとして扱う。P1-04の時点で将来のSignature不変を絶対条件として固定しない。

---

# 9. Minimal Scan Result Contract

## 9.1 Top-level Result

Success時、`scanResult` は最低限以下のKeyを持つDictionaryとする。

```text
scanResult
├─ "ValidVariables"     → Collection
└─ "InvalidCandidates"  → Collection
```

P1-04では `"Locations"` Keyを必須としない。

## 9.2 ValidVariables

`ValidVariables` は以下を満たす。

```text
型:
Collection

内容:
Syntax ValidationをPASSしたVariableName

重複:
Case Insensitiveに統合

順序:
初回検出順

表記:
初回検出時のVariableName表記を保持
```

例：

```text
Input:
{{ModelName}}
{{modelname}}
{{MODELNAME}}

ValidVariables:
ModelName
```

P1-04における「初回検出時表記」は軽量Scan Result内の表示値であり、VariableDefinition上の正式表記を意味しない。

Existing VariableDefinitionの正式表記維持はP2 Sync側の責務とする。

## 9.3 InvalidCandidates

`InvalidCandidates` は以下を満たす。

```text
型:
Collection

内容:
Candidate Scanでは検出されたが
VariableName Syntax ValidationにFAILした元記述

表記:
{{...}} を含むCandidate文字列そのものを保持

順序:
検出順

重複:
P1-04 Public Contractでは固定しない
```

例：

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

はそのままInvalidCandidatesへ保持する。

Invalid Candidate内部文字列だけへ変換しない。

同一Invalid Candidateが複数回出現した場合のResult内重複表現は、P1-04では利用者向け仕様として固定しない。Production実装が複数Occurrenceを保持してもよいが、後続UIの表示方式・重複集約方針まで本Unitで決定しない。

---

# 10. Result Initialization

`ScanTemplate()` 開始時に必ず以下を行う。

```vb
Set scanResult = Nothing
```

Technical Failure時に過去のScan Resultを呼出元へ残さない。

Success時のみ新しいResult Dictionaryを `scanResult` へ設定する。

---

# 11. Scanner Algorithm

## 11.1 全体フロー

```text
ScanTemplate
↓
scanResult = Nothing
↓
Result用Collection / Dictionary初期化
↓
Subject Candidate Scan
↓
Subject Candidate Validation
↓
BodyText Candidate Scan
↓
BodyText Candidate Validation
↓
Case Insensitive Valid Variable統合
↓
Minimal Scan Result生成
↓
Success
```

Subjectを先にScanし、その後BodyTextをScanする。

各文字列内では左から右への検出順を維持する。

この順序はP1-04 Resultを再現可能にするためのImplementation Detailであり、VariableDefinitionのSortOrderを意味しない。

## 11.2 Candidate Scan

Candidate ScanはLate Bound `VBScript.RegExp` を使用する。

Pattern：

```regex
\{\{([^{}]*)\}\}
```

基本設定：

```text
Global = True
IgnoreCase = False
```

Candidate全体は `Match.Value` から取得する。

Candidate内部文字列は `SubMatches(0)` から取得する。

ScannerはCandidate内部文字列をTrimしない。

したがって、

```text
{{ UserName }}
```

は内部文字列 `" UserName "` のままValidationへ渡し、Invalidとする。

## 11.3 VariableName Validation

Candidate内部文字列へ以下を適用する。

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

Validation PASS：

```text
ValidVariables候補
```

Validation FAIL：

```text
InvalidCandidates
```

Invalid Candidateを無視しない。

---

# 12. Case Insensitive統合

## 12.1 統合方法

Valid Variableの重複判定にはLate Bound `Scripting.Dictionary` を使用する。

Dictionaryの `CompareMode` はCase Insensitiveとする。

概念：

```text
ModelName
modelname
MODELNAME
↓
同一Keyとして認識
↓
ValidVariablesへ1件だけ追加
```

P1-04では最初に検出した表記を `ValidVariables` へ保持する。

## 12.2 正式表記との分離

P1-04 ScannerはVariableDefinitionを参照しない。

したがって以下は決定しない。

```text
VariableDefinition上の正式表記
既存DefinitionとのCase Insensitive照合
New / Existing判定
```

これらはP2 Sync Scopeとする。

---

# 13. Invalid CandidateとOperationResult

## 13.1 基本方針

Invalid CandidateはScanner処理の技術失敗ではない。

以下を明確に分離する。

```text
COperationResult
→ Scanner処理が技術的に完了したか

InvalidCandidates
→ Template内容にSyntax違反Candidateが存在するか
```

したがって、

```text
Scan実行成功
+
InvalidCandidates > 0
```

の場合：

```text
COperationResult.Success = True
InvalidCandidates.Count > 0
```

とする。

Scanner自身はConfiguration Errorへ変換しない。

## 13.2 後続Fail Closed

最終MVPではInvalid Candidate検出結果を後続処理停止へ接続する必要がある。

ただしP1-04では停止制御を実装しない。

P1-04は後続が以下を判断できるResultを返すところまでを責務とする。

```text
InvalidCandidates.Count > 0
```

---

# 14. Empty Input

以下はScannerのTechnical Errorとしない。

```text
Subject = vbNullString
BodyText = vbNullString
```

Expected：

```text
ScanTemplate = Success

ValidVariables.Count = 0
InvalidCandidates.Count = 0
```

「TemplateにVariableが1件以上必要か」という利用者向け判断をScanner Reader責務へ追加しない。

P1 Walking Skeleton Verificationでは正常な1つ以上のVariableを持つBaseline OFTを使用する。

---

# 15. Error / Result方針

## 15.1 基本方針

P1-04では既存 `COperationResult` / `CErrorInfo` を使用する。

新しいError Modelを追加しない。

## 15.2 Technical Error

以下のようなScanner内部Technical ErrorはFailure Resultへ変換する。

```text
VBScript.RegExp生成失敗
Scripting.Dictionary生成失敗
RegExp実行時Runtime Error
Collection / Dictionary操作時の想定外Runtime Error
```

ErrorType：

```text
UnexpectedError
```

Target：

```text
TemplateScanner
```

Messageは少なくともScanner処理を完了できなかったことを識別可能にする。

例：

```text
Template variable scanning could not be completed.
```

必要に応じて技術診断情報を付加してよいが、技術例外文字列だけをUser Messageとする設計にはしない。

## 15.3 Failure時Result

Technical Failure時：

```text
ScanTemplate = Failure
scanResult = Nothing
```

Partial ResultをSuccess扱いで返さない。

---

# 16. Private Implementation

P1-04では責務を小さく保つため、必要に応じてPrivate Helperへ分割してよい。

概念候補：

```vb
Private Function ScanText( _
    ByVal sourceText As String, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef seenVariables As Object _
) As COperationResult
```

または同等の小規模構造を採用してよい。

Private Helper名は実装時に既存命名規則へ合わせて調整してよい。

以下はPrivate Implementation Detailとする。

```text
RegExp Object生成位置
Validation用RegExp再利用方式
Dictionary生成Helper
Collection追加Helper
Error Handler配置
```

Public Boundaryの意味を変更しない範囲で調整可能とする。

---

# 17. Dependency Rules

`modTemplateScanner` から参照してよいもの：

```text
String
Collection
Late Bound VBScript.RegExp
Late Bound Scripting.Dictionary
COperationResult
CErrorInfo
modResult
```

直接参照してはならないもの：

```text
modOutlookAdapter内部COM Object
Outlook Object Model
Word Object Model
Excel ListObject
VariableDefinition Data Access
OptionMaster Data Access
Settings Data Access
UI Form
```

Scannerは純粋なCore Logic Boundaryとして維持する。

---

# 18. Production Flow

P1-04 Completion時に成立させるProduction Flow：

```text
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
Subject / BodyText Snapshot
↓
modTemplateScanner.ScanTemplate
↓
Minimal Scan Result
├─ ValidVariables
└─ InvalidCandidates
↓
CloseWithoutSave
```

P1-04では後続Renderへまだ接続しない。

---

# 19. Smoke Test方針

Verification Module候補：

```text
modP1_04MinimalTemplateScannerSmokeTest
```

Entry Point候補：

```vb
TestP104MinimalTemplateScannerCore
TestP104MinimalTemplateScannerIntegration
```

P1-04 Smoke TestはFormal MVP Testではなく、Implementation Unit Verificationとする。

---

# 20. Core Smoke Test

## 20.1 Case C1：Baseline相当Happy Path

固定Stringを直接Scannerへ渡す。

Subject例：

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

BodyText例：

```text
対象機種：{{ModelName}}
開催日：{{GateDate}}
担当部署：{{Department}}
備考：{{Comment}}
対象機種再掲：{{MODELNAME}}
担当部署再掲：{{department}}
```

Expected：

```text
ScanTemplate:
PASS

ValidVariables.Count:
4

ValidVariables:
ModelName
GateDate
Department
Comment

InvalidCandidates.Count:
0
```

Production `modTemplateScanner` に上記VariableNameをHard Codingしてはならない。

Expected値をSmoke Test側へ記述することは許可する。

## 20.2 Case C2：Case Insensitive統合

Input：

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

Expected：

```text
ScanTemplate:
PASS

ValidVariables.Count:
1

ValidVariables(1):
ModelName

InvalidCandidates.Count:
0
```

## 20.3 Case C3：Invalid Candidate

Input：

```text
{{ModelName}}
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

Expected：

```text
ScanTemplate:
PASS

ValidVariables:
ModelName

InvalidCandidates.Count:
5
```

InvalidCandidatesは以下の元記述を保持する。

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

Invalid CandidateをTechnical Failure扱いしない。

## 20.4 Case C4：Empty Input

Input：

```text
Subject = vbNullString
BodyText = vbNullString
```

Expected：

```text
ScanTemplate:
PASS

ValidVariables.Count:
0

InvalidCandidates.Count:
0
```

---

# 21. Production Integration Smoke Test

P1-03 Production Boundaryと接続する。

手順：

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
ScanTemplate
↓
Scan Result確認
↓
CloseWithoutSave
```

Baseline OFT Expected：

```text
ReadSubject:
PASS

ReadBodyText:
PASS

ScanTemplate:
PASS

ValidVariables.Count:
4

ValidVariables:
ModelName
GateDate
Department
Comment

InvalidCandidates.Count:
0

CloseWithoutSave:
PASS
```

Subject / Bodyの双方からVariableが取得された最終結果として4 Variableが成立することを確認する。

P1-04ではLocation Subject / Body / Bothの正式判定は行わない。

---

# 22. Evidence

P1-04 Core Smoke Testでは最低限以下を記録する。

```text
Test Case
ScanTemplate Result
ValidVariables Count
ValidVariables
InvalidCandidates Count
InvalidCandidates
Result
```

Production Integrationでは追加で以下を記録する。

```text
TemplatePath
ResolvedPath
ReadSubject Result
Subject Length
ReadBodyText Result
BodyText Length
ScanTemplate Result
ValidVariables Count
InvalidCandidates Count
CloseWithoutSave Result
```

BodyText全文はEvidence必須としない。

---

# 23. Negative / Boundary Verification

## Case N1：Invalid Candidate

Invalid CandidateありでもScanner技術処理が正常完了した場合：

```text
OperationResult = Success
InvalidCandidates.Count > 0
```

であることを確認する。

## Case N2：Empty Input

空文字入力をRuntime Errorにしない。

## Case N3：Technical Failure

安全に再現できるTechnical Failureが存在する場合のみFailure Result変換を確認する。

Failure InjectionのためにProduction Public APIを追加しない。

再現困難なTechnical FailureはCode ReviewによるError Handler確認でもよい。

---

# 24. Regression

P1-04で `modOutlookAdapter` / `modSettingsData` 等の既存Production Moduleを変更しない場合、P1-02 Warm / Cold Lifecycle全RegressionをP1-04 Completionの必須条件とはしない。

最低限以下を確認する。

```text
VBA Compile
P1-04 Core Smoke Test
P1-03 Snapshot → Scanner Production Integration
CloseWithoutSave
```

P1-04実装のために以下既存Production Moduleへ変更を加えた場合は、該当Regressionを追加する。

```text
modOutlookAdapter変更
→ P1-02 Warm / Cold Regression

modSettingsData変更
→ P1-01 Path Regression

modResult変更
→ P0 Result Regression
```

不要なRegressionを形式的に増やさず、変更影響範囲に応じて実施する。

---

# 25. Code Review Gate

Production Patchに対して最低限以下をReviewする。

```text
[ ] modTemplateScannerとして実装されている
[ ] InputはSubject / BodyText Stringのみ
[ ] Outlook / Word COM Objectを受け取らない
[ ] Excel ListObjectへ依存しない
[ ] Candidate ScanとSyntax Validationを分離している
[ ] Candidate PatternがDesign Semanticsと一致する
[ ] VariableName Syntax RuleがDesignと一致する
[ ] Valid VariableをCase Insensitiveに統合する
[ ] Invalid Candidateを無視しない
[ ] Invalid Candidateの元記述を保持する
[ ] Invalid CandidateをTechnical Failure扱いしない
[ ] Failure時scanResultをNothingにする
[ ] Production CodeへVariableNameをHard Codingしていない
[ ] CTemplateScanResult専用Classを先回り追加していない
[ ] Location統合を先回り実装していない
[ ] Sync処理を混入させていない
[ ] UI判断を混入させていない
[ ] P1-03 / Outlook Adapter責務を再実装していない
```

---

# 26. PASS / FAIL Criteria

## 26.1 PASS

以下をすべて満たした場合、P1-04をPASS / COMPLETE候補とする。

```text
VBA Compile
= PASS

P1-04 Core Happy Path
= PASS

Production Snapshot → Scanner Integration
= PASS

Baseline ValidVariables Count
= 4

Baseline Variables
= ModelName / GateDate / Department / Comment

Baseline InvalidCandidates
= 0

Case Insensitive Integration
= PASS

Invalid Candidate Detection
= PASS

Invalid Candidate Raw Preservation
= PASS

Invalid Candidate Scan Operation
= Success

Empty Input Handling
= PASS

Production VariableName Hard Coding
= NONE

Outlook / Word COM Dependency Leakage
= NONE

Excel Data Access Dependency Leakage
= NONE

P1-03 Boundary Regression
= NONE

CloseWithoutSave Integration
= PASS

Blocking Implementation Finding
= NONE

Blocking Design Finding
= NONE

Blocking Requirement Gap
= NONE
```

## 26.2 FAIL

以下のいずれかをFAILとする。

```text
Baseline Variableを動的に抽出できない
Case違いを別Variableとして重複返却する
Invalid Candidateを無視する
Invalid CandidateをValidVariablesへ混入する
Invalid Candidateだけを理由にScanner自体をTechnical Failure扱いする
Failure時に古いscanResultが残る
Production VariableNameをHard Codingする
Outlook / Word COM ObjectをScannerへ渡す
Excel ListObjectをScannerから直接参照する
Location / Sync等のP2責務をP1-04へ不必要に混入する
P1-03 Snapshot Boundaryを破壊する
CloseWithoutSave Regression
未処理Runtime Error
```

---

# 27. Finding Classification

P1-04で問題を検出した場合は以下で分類する。

## Implementation Detail

既存Requirement / Designを変更せず、コード具体化で解決できるもの。

例：

```text
RegExp Object生成位置
Dictionary CompareMode設定コード
Private Helper分割
Result Key定数配置
Error Handler範囲
Evidence表示形式
```

## Implementation Defect

Approved仕様 / Designどおりの実装になっていないもの。

例：

```text
Case Sensitive重複
Invalid Candidate無視
Production Variable Hard Coding
scanResult初期化漏れ
Outlook COM依存混入
```

## Design Finding

Requirementは明確だが、既存Scanner Boundaryでは成立せずDesign責務変更が必要となるもの。

例：

```text
Subject / BodyText StringだけではFinal Scanner要件を実現できない
Lightweight Result BoundaryではP2へ互換拡張できない
```

Design FindingをP1-04内で推測修正しない。

## Requirement Gap

利用者から見た新しい振る舞い判断が必要となる場合。

例：

```text
Variableが0件のTemplateを利用者仕様として禁止するか
同一Invalid Candidate重複時のUI表示方式をどうするか
```

この種の判断をImplementation Detailとして決めない。

## Technical Risk / Spike再判定

標準String / VBScript.RegExp / Scripting.Dictionaryで通常実装可能な範囲ではTechnical Spikeを追加しない。

通常Implementation + Verificationでは大規模手戻りを避けられない新たなTechnical Questionが具体化した場合のみ再判定する。

Technical Spike B / Cを自動的に復活させない。

---

# 28. Implementation Order

推奨実装順：

```text
1. P1-03 Completion Boundary確認
   ↓
2. 現行modTemplateScanner Shell有無確認
   ↓
3. COperationResult / modResult Pattern確認
   ↓
4. ScanTemplate Public API実装
   ↓
5. Candidate Scan実装
   ↓
6. VariableName Validation実装
   ↓
7. Case Insensitive統合実装
   ↓
8. Minimal Scan Result生成
   ↓
9. VBA Compile
   ↓
10. Core Smoke Test
   ↓
11. Invalid Candidate Verification
   ↓
12. P1-03 Snapshot Integration
   ↓
13. Code Review Gate
   ↓
14. Finding判定
   ↓
15. P1-04 PASS / FAIL判定
```

---

# 29. Deliverables

P1-04の成果物候補：

```text
Production
- modTemplateScanner
  - ScanTemplate

Verification
- modP1_04MinimalTemplateScannerSmokeTest
- P1-04 Smoke Test Evidence

Review
- P1-04 Production Patch Review
```

本Draft仕様のSemantic内容を変更する場合は、文書管理ルールに従って必要なRevision / Impact Analysisを行う。

Project Control上の進捗は本Technical Specificationでは管理しない。

---

# 30. P1 Phase Boundaryとの関係

P1-04で成立させる技術境界は以下までとする。

```text
Excel
↓
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText Snapshot
↓
Minimal Template Scanner
↓
ValidVariables / InvalidCandidates
```

P1 Walking Skeleton全体のExit Criteriaを満たすためには、本Unitの外側で以下の経路が別途成立する必要がある。

```text
Input Value
Subject Render
Word Range Body Render
Render後Subject / BodyText再取得
Unresolved Check
Final Display
```

P1-04 CompletionはP1 Phase全体のExit Criteria成立を単独で意味しない。

P2ではScannerへ以下を追加して完成させる。

```text
Locations
Subject / Body / Both統合
Sync Engine接続
VariableDefinition同期
```

---

# 31. Final Boundary Decision

```text
Implementation Unit
→ P1-04 Minimal Template Scanner

Input
→ Subject As String
→ BodyText As String

Production Module
→ modTemplateScanner

Public API
→ ScanTemplate(subjectText, bodyText, scanResult)
→ COperationResult
→ P2でも原則維持、必要な変更はDesign Findingとして扱う

Result Carrier
→ Late Bound Scripting.Dictionary

P1-04 Guaranteed Result
→ ValidVariables
→ InvalidCandidates

ValidVariables
→ Collection
→ Case Insensitive重複排除
→ 初回検出表記保持

InvalidCandidates
→ Collection
→ 元Candidate文字列保持
→ 重複表現はP1-04 Public Contractでは固定しない

Candidate Scan
→ P1-04 IN

VariableName Syntax Validation
→ P1-04 IN

Valid / Invalid Separation
→ P1-04 IN

Case Insensitive Valid Variable Integration
→ P1-04 IN

Invalid Candidate Preservation
→ P1-04 IN

Location Subject / Body / Both
→ P2

Locations Result
→ P2

Formal TemplateScanResult Completion
→ P2

Sync
→ P2

Invalid Candidate
→ Scanner Operation Failureではない

Invalid Candidate停止判断
→ downstream Application / Configuration

To / CC / BCC
→ Scanner Input外
→ Outlook Recipient Access禁止

Outlook / Word COM Dependency
→ PROHIBITED

Excel Data Access Dependency
→ PROHIBITED

Production VariableName Hard Coding
→ PROHIBITED

Dedicated TemplateScanResult Class
→ NOT REQUIRED AT P1-04

Requirement Change
→ NONE

Design Change
→ NONE

Test Specification Change
→ NONE

Baseline Change
→ NONE

Execution Baseline
→ BL-MVP-003
```
