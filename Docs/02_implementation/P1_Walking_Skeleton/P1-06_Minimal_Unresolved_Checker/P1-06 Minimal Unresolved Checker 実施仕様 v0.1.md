# P1-06 Minimal Unresolved Checker 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-06 Minimal Unresolved Checker 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Approved |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-06 Minimal Unresolved Checker |
| Primary Production Module | `modUnresolvedChecker` |
| 前提Implementation Unit | P1-05 Minimal Render = PASS / COMPLETE |
| Primary Verification | Render後Subject / BodyTextの未置換Variable検出 + Case Insensitive重複統合 + P1-05 Integration |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `DOC-TS-A` — Technical Spike A
- `P1-03 Template Snapshot Boundary 実施仕様 v0.1`
- `P1-04 Minimal Template Scanner 実施仕様 v0.1`
- `P1-05 Minimal Render 実施仕様 v0.1`
- `P1-05 Minimal Render Completion Record v0.1`
- `P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1`
- `P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1`

### v0.1 Consistency Review反映概要

`P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1` の結果を反映し、本v0.1をApprovedとした。

Review結果：

```text
PASS WITH CORRECTIONS
```

Approval前Correctionとして以下3件を反映した。

1. `CR-P1-06-001` — Unresolved 1件以上のErrorTypeを `RenderError` の正式最終分類として固定せず、P1ではFailure Result + Unresolved Resultを正式Contractとし、必要な `RenderError` 使用はP1 Interim Mappingへ限定。正式なUnresolved Error分類はP6へ残した
2. `CR-P1-06-002` — Consistency Review対象の略称を正式文書名へ正規化
3. `CR-P1-06-003` — Draft専用状態記述をApproved版のConsistency Review結果 / Approved Resultへ更新

本CorrectionによるRequirement / Design / Test Specification / BaselineへのSemantic Impactはない。

**Consistency Review：PASS WITH CORRECTIONS → CORRECTIONS APPLIED**
**Blocking Finding：NONE**
**Semantic Conflict：NONE**
**Requirement Gap：NONE**
**Design Finding：NONE**
**Technical Spike Reopen：NOT REQUIRED**
**Baseline Change：NOT REQUIRED**
**Document Status：Approved**

### v0.1 作成概要

`P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1` で確定した責務境界を、Production実装可能なImplementation Detailへ具体化する。

本Unitでは以下を行う。

1. Production `modUnresolvedChecker` を追加する
2. Render後Subject / BodyText文字列Snapshotを入力として受け取る
3. 有効な `{{VariableName}}` 形式の残存Tokenを検出する
4. VariableNameをCase Insensitiveに重複統合する
5. `HasUnresolved` と `Variables` を持つ最小Result Carrierを生成する
6. 未置換0件ではSuccess Resultを返す
7. 未置換1件以上では既存Error体系を使ったFailure Resultを返し、検出済みVariablesを保持する
8. Outlook / Word COM Objectへ依存しない
9. Template ScannerのResultとは独立して判定する
10. MailItem Display / Close / UI一覧表示をP1-06へ混在させない
11. P1-05までのRender後Snapshot BoundaryへIntegration接続する
12. P1-07 / P5 / P6の責務を先回り実装しない

本仕様は、BL-MVP-003で承認済みのRequirement / Design / Test Definition、およびP1-06 Boundary ConfirmationをImplementation Detailへ具体化するものである。

新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Detail / Unit Specification**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-06の目的は、Production Architecture上で以下の最小Unresolved Check Boundaryを成立させることである。

```text
P1-05
Subject Render
+
Word Range Body Render
        ↓
ReadSubject()
+
ReadBodyText()
        ↓
Render後 Snapshot
├─ Subject As String
└─ BodyText As String
        ↓
modUnresolvedChecker
        ↓
CheckUnresolved()
        ↓
Unresolved Result
├─ HasUnresolved
└─ Variables
        ↓
COperationResult
```

P1-06では、

> **Render後の最終文字列Snapshotに有効なVariable Tokenが残存しているかを、Outlook / Word COM非依存のCore Logicとして判定できること**

を確認する。

P1-06単体では、

```text
MailItem Display
MailItem Close
User-facing一覧表示
正式Mail Generation Orchestration
```

までを完成させない。

---

# 3. Baseline上の根拠

## 3.1 Requirement

`DOC-MVP-REQ` では未置換Variableについて以下が要求されている。

```text
SubjectまたはBodyに
{{VariableName}}
形式の未置換変数が1件でも残っている場合、
メール生成を中止する。
```

VariableName比較にはCase Insensitive Ruleを適用する。

未置換Variableが存在する場合は対象Variableを一覧表示する。

Acceptance Criteriaでは、

```text
未置換変数が1つでも残っている場合、
Outlookメールを表示しない。
```

ことが要求されている。

P1-06ではこのうち、

```text
未置換0件 / 1件以上判定
残存Variable一覧生成
Case Insensitive重複統合
```

をProduction Core Logicとして成立させる。

---

## 3.2 Design

`DOC-MVP-DES` ではUnresolved CheckerをCore Logicとして定義している。

```text
Render
↓
Unresolved Checker
↓
UnresolvedCheckResult
├─ 0件 → Outlook Display
└─ 1件以上 → Error Result → UI一覧表示
```

対象：

```text
Subject
BodyText
```

BodyTextはBody Render後にOutlook Adapterから再取得した表示文字列Snapshotとする。

Unresolved Checker自身は、

```text
Word Document
Word Range
MailItem
Inspector
WordEditor
```

を直接操作しない。

Design上の論理Resultは以下である。

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

`Variables[]` はVariableNameをCase Insensitiveで重複統合する。

---

## 3.3 Test Specification

`DOC-MVP-TESTSPEC` の関連Testは以下である。

```text
MTS-UNR-001
正常系未置換0件

MTS-UNR-002
未置換1件以上でDisplay停止

MTS-UNR-003
未置換Variable一覧 / Case統合

MTS-UNR-004
Scanner成立性とUnresolved 0件を独立判定
```

P1-06では、

```text
MTS-UNR-001
MTS-UNR-003のCore部分
MTS-UNR-004 Test B
```

へ直接接続可能なProduction Logicを成立させる。

`MTS-UNR-002` の最終Display停止 / CloseはP1-07で接続する。

---

## 3.4 Implementation Plan

`DOC-MVP-IMPL` のP1 Walking Skeletonでは以下が要求されている。

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
Subject / BodyText再取得
↓
Unresolved Check
↓
Display
```

P1-05で、

```text
Subject / BodyText再取得
```

まで成立済みである。

P1-06は次の1区間を担当する。

```text
Render後Snapshot
↓
Unresolved Check
```

---

# 4. 前提Implementation Boundary

## 4.1 P1-05成立済みBoundary

P1-05により以下が成立済みである。

```text
FormattedValues
↓
RenderSubject
↓
SetSubject

FormattedValues
↓
ReplaceBodyVariables

        ↓

ReadSubject
+
ReadBodyText
        ↓
Render後Snapshot
```

P1-06は既存Production APIを変更せず、このRender後Snapshotを入力として使用する。

---

## 4.2 P1-04 Scanner Boundary

P1-04では以下が成立済みである。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Minimal Result：

```text
scanResult
├─ ValidVariables
└─ InvalidCandidates
```

P1-06では `scanResult` を入力としない。

Scanner成立性とUnresolved Check成立性は独立して判定する。

---

# 5. Scope

P1-06のProduction実装対象は以下とする。

```text
modUnresolvedChecker
├─ Public CheckUnresolved()
├─ Render後 Subject As String
├─ Render後 BodyText As String
├─ 有効Token抽出
├─ Case Insensitive重複統合
├─ unresolvedResult生成
│   ├─ HasUnresolved
│   └─ Variables
├─ 未置換0件 → Success
├─ 未置換1件以上 → Failure / Error Result
├─ Runtime Error → UnexpectedError
└─ COM非依存
```

Verificationでは以下を行う。

```text
Core Test
+
P1-05 Integration
+
Missing Value Integration
+
必要最小限Regression
```

---

# 6. Out of Scope

P1-06では以下を実装しない。

```text
Template Scanner再設計
Invalid Candidate一覧生成
Configuration Validator
VariableDefinition照合
OptionMaster照合
TemplateLocation
Sync Engine
Input State
Input Validator
Value Formatter
Subject Renderer変更
Body Renderer変更
Word Range検索
Current OFT Guard
Current VariableDefinition Guard
Current OptionMaster Guard
MailItem生成
DisplayMail
CloseWithoutSaveのProduction Orchestration
自動送信
Error UI
未置換Variable一覧UI
最終User Message
正式Error Code体系
Formal MVP Test
```

また、P1-06のためだけに以下を追加しない。

```text
CUnresolvedCheckResult
CUnresolvedVariable
Unresolved専用Interface
Unresolved専用Adapter
MailItemを受け取るPublic API
Word Documentを受け取るPublic API
Test専用Production Public API
```

---

# 7. Responsibility Boundary

## 7.1 Production Boundary

P1-06完了時の責務境界は以下とする。

```text
Application / Test Harness
        │
        │ subjectText As String
        │ bodyText As String
        ▼
─────────────────────────────────
Core Logic Boundary
─────────────────────────────────
        │
        ▼
modUnresolvedChecker
        │
        ├─ Valid Token Scan
        ├─ Case Insensitive Dedup
        ├─ HasUnresolved
        └─ Variables
        │
        ▼
COperationResult
+
unresolvedResult As Object
```

Core LogicはOutlook / Word COM Objectへ依存しない。

---

## 7.2 Scannerとの責任分離

```text
modTemplateScanner
= Render前Template構成確認

modUnresolvedChecker
= Render後生成結果の完全性確認
```

P1-06はScannerの `ValidVariables` を見て、

```text
Expected Variable - Replaced Variable
```

の差分計算を行わない。

最終Snapshot上に残存するTokenを直接確認する。

---

## 7.3 Rendererとの責任分離

```text
modSubjectRenderer / modOutlookAdapter
= Variableを置換する

modUnresolvedChecker
= 置換後にTokenが残っているか確認する
```

Unresolved Checkerは残存Tokenを見つけても再置換しない。

---

# 8. Production Module

Production Module：

```text
modUnresolvedChecker
```

標準Moduleとして追加する。

理由：

- Design上Core Logicである
- Stateを保持する必要がない
- Outlook / Excel / Word Object Modelへ依存しない
- P1でClass化する必要性がない
- P1-04 `modTemplateScanner` / P1-05 `modSubjectRenderer` と同じ軽量Core Module構成に合わせる

---

# 9. Public API

## 9.1 API

P1-06では以下をProduction Public APIとする。

```vb
Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

---

## 9.2 Input

```text
subjectText
= Render後のSubject Snapshot

bodyText
= Render後のBodyText Snapshot
```

Render前Snapshotを渡してはならない。

P1-06 API自身はSnapshotがRender前かRender後かを識別しない。

Callerが正しい処理順序を保証する。

---

## 9.3 Output

`unresolvedResult` はLate Bound `Scripting.Dictionary` とする。

構造：

```text
unresolvedResult
├─ "HasUnresolved" → Boolean
└─ "Variables"     → Collection
```

例：

```text
HasUnresolved = True

Variables
├─ GateDate
└─ Department
```

専用Result Classは追加しない。

---

## 9.4 COperationResult

戻り値は既存 `COperationResult` とする。

概念：

```text
Unresolved 0件
→ Success = True

Unresolved 1件以上
→ Success = False
→ Failure / Error Result
→ unresolvedResultは保持

予期しないRuntime Error
→ Success = False
→ ErrorType = UnexpectedError
→ unresolvedResult = Nothing
```

---

# 10. Result Carrier

## 10.1 Dictionary

`unresolvedResult` は以下で生成する。

概念：

```vb
Set unresolvedResult = CreateObject("Scripting.Dictionary")
unresolvedResult.CompareMode = vbTextCompare
```

Keyは固定とする。

```text
HasUnresolved
Variables
```

これはP1-06 Production Contract上のResult Keyである。

---

## 10.2 Variables Carrier

`Variables` はVBA `Collection` とする。

理由：

- Design上の `Variables[]` に近い
- 順序付き一覧として後続へ渡せる
- 新規Class不要
- VariableNameのみを保持すればP1要件を満たす
- 重複排除は内部Dictionaryへ分離できる

概念：

```vb
Dim variables As Collection
Set variables = New Collection
```

---

## 10.3 Internal Dedup Dictionary

Case Insensitive重複排除用に、内部でLate Bound `Scripting.Dictionary` を使用する。

```vb
Set seenVariables = CreateObject("Scripting.Dictionary")
seenVariables.CompareMode = vbTextCompare
```

`seenVariables` はPublic Resultへ公開しない。

---

# 11. Output初期化規則

`CheckUnresolved()` 開始時に必ず、

```vb
Set unresolvedResult = Nothing
```

とする。

その後、処理に必要なResult Carrier生成が成功した場合のみ新しいResultを設定する。

これにより、Failure時にCallerが以前の `unresolvedResult` を誤って再利用することを防止する。

ただし、

```text
Unresolved Variableを正常に検出
```

した場合はOperation Result自体をFailureとしつつ、検出済み `unresolvedResult` は保持する。

このFailureはTechnical FailureではなくFail Closed判定に必要な正常な検出結果である。

---

# 12. Token Pattern

## 12.1 P1-06 Detection Pattern

P1-06では、最終Snapshot中の有効なVariable Tokenだけを直接抽出する。

使用Pattern：

```regex
\{\{([A-Za-z][A-Za-z0-9_]*)\}\}
```

対象例：

```text
{{GateDate}}
{{ModelName}}
{{MODEL_1}}
```

非対象例：

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

---

## 12.2 Binding

`VBScript.RegExp` はLate Bindingとする。

概念：

```vb
Set regex = CreateObject("VBScript.RegExp")
regex.Global = True
regex.IgnoreCase = True
regex.Pattern = "\{\{([A-Za-z][A-Za-z0-9_]*)\}\}"
```

P1-04で成立済みのLate Bound方針と整合させる。

---

## 12.3 RegExp責務

RegExpは、

```text
有効Tokenの抽出
```

のみを担当する。

以下を担当しない。

```text
Template全体のCandidate Validation
Invalid Candidate通知
VariableDefinition照合
Location統合
```

---

# 13. Scan順序

P1-06では以下の順で文字列を評価する。

```text
1. Subject
2. BodyText
```

これはImplementation Detailとする。

`Variables` Collectionへは初回検出時のみ追加する。

結果として通常は、

```text
Subjectで初めて見つかったVariable
↓
BodyTextで初めて見つかったVariable
```

の順になる。

ただしこの順序をUser-facing Requirementとして保証しない。

---

# 14. Case Insensitive重複統合

以下を同一Variableとして扱う。

```text
{{GateDate}}
{{gatedate}}
{{GATEDATE}}
```

内部処理：

```text
Match
↓
VariableName取得
↓
seenVariables.Exists(variableName)?
├─ Yes → Variablesへ追加しない
└─ No
    ├─ seenVariables.Add
    └─ Variables.Add
```

`Variables` には初回検出時の表記を保持する。

例：

```text
最初の検出:
{{GateDate}}

後続:
{{GATEDATE}}

Variables:
GateDate
```

初回表記保持はP1 Implementation Detailであり、正式なCanonical Name保証ではない。

P5でCurrent VariableDefinitionと統合する際に正式表記の必要性が発生した場合は、そのPhaseで判断する。

---

# 15. HasUnresolved

全Scan完了後：

```text
Variables.Count = 0
→ HasUnresolved = False

Variables.Count >= 1
→ HasUnresolved = True
```

`HasUnresolved` と `Variables.Count` が矛盾するResultを返してはならない。

Expected invariant：

```text
HasUnresolved = (Variables.Count > 0)
```

---

# 16. Formatted Value由来Token

P1-06はFormattedValuesを受け取らない。

以下を区別しない。

```text
元Templateから残ったToken
Formatted Valueに含まれていたToken
その他の上流処理によって最終Snapshotに存在するToken
```

最終Snapshot上に、

```text
{{ValidVariableName}}
```

が存在すればUnresolvedとして扱う。

例：

```text
Formatted Value:
"担当：{{Department}}"

Render後 BodyText:
備考：担当：{{Department}}

CheckUnresolved:
HasUnresolved = True
Variables = Department
```

P1-06は `Department` を再Renderしない。

---

# 17. Invalid Candidate Boundary

以下はP1-06のUnresolved Variable一覧には含めない。

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

これらのTemplate上の検出・処理停止はTemplate Scanner / Configuration責務とする。

P1-06 Verificationでは、

```text
Invalid Candidateが存在しない正常Precondition
```

を基本とする。

P1-06のためにInvalid Candidate Error Handlingを重複実装しない。

---

# 18. Empty String

以下はErrorとしない。

```text
subjectText = vbNullString
bodyText = vbNullString
```

Expected：

```text
CheckUnresolved = Success
HasUnresolved = False
Variables.Count = 0
```

P1-06はSubject / Body空欄そのもののRequirement妥当性を判定しない。

---

# 19. Operation Result

## 19.1 Unresolved 0件

Expected：

```text
COperationResult.Success = True

unresolvedResult:
HasUnresolved = False
Variables.Count = 0
```

既存 `modResult.CreateSuccessResult()` 相当を使用する。

---

## 19.2 Unresolved 1件以上

Designでは1件以上を、

```text
Error Result
```

として扱う。

P1-06の正式Contractは以下とする。

```text
COperationResult.Success = False

unresolvedResult:
HasUnresolved = True
Variables.Count >= 1

Error:
Message = Unresolved variables remain after rendering.
Target  = UnresolvedVariables
```

P1-06では、

```text
Unresolved = RenderError
```

を正式な最終Error分類として固定しない。

`DOC-MVP-IMPL` ではP6のError / Safety Scopeに、

```text
Render Error
Unresolved Error
```

を別項目として定義し、Error体系・Fail Closed・User Notificationの最終化をP6へ残している。

現行の `CreateFailureResult()` がErrorTypeを必須とし、P1実装で既存ErrorTypeを1つ指定する必要がある場合は、

```text
RenderError
```

を **P1 Interim Mapping** として使用してよい。

ただしこれは、

```text
RenderError = Unresolved Errorの正式最終分類
```

というDesign Decisionを意味しない。

P1-07はErrorType文字列そのものへ依存せず、

```text
COperationResult.Success = False
+
unresolvedResult.HasUnresolved = True
```

によってUnresolved Failureを識別可能なBoundaryとする。

正式なUnresolved Error分類 / Error Code / User-facing MessageはP6で最終化する。

---

## 19.3 Error Message

P1-06 Production Logic内の基本Message：

```text
Unresolved variables remain after rendering.
```

これはP1-06 Core / Application間で問題種別を識別するための最低限Messageである。

FR-UNRESOLVED-002の最終User-facing一覧文言はP1-06で固定しない。

---

## 19.4 Error Target

P1-06のUnresolved Failure Target：

```text
UnresolvedVariables
```

個々のVariableNameを `CErrorInfo.Target` へ1件ずつ複製しない。

Variable一覧は専用 `unresolvedResult("Variables")` をSourceとする。

---

# 20. Unexpected Error

## 20.1 対象

以下のような予期しないFailureをTechnical Failureとして扱う。

```text
VBScript.RegExp生成失敗
Scripting.Dictionary生成失敗
Collection操作Runtime Error
RegExp Execute Runtime Error
Result Carrier設定Runtime Error
その他の想定外VBA Runtime Error
```

---

## 20.2 Result

Expected：

```text
Set unresolvedResult = Nothing

COperationResult.Success = False
ErrorType = UnexpectedError
Target = UnresolvedChecker
```

Messageは少なくともUnresolved Check内部失敗であることを識別可能とする。

例：

```text
Unable to check unresolved variables.
```

VBA Runtime Error文字列だけを最終Messageとして使用しない。

必要に応じてDebug.Print等へ技術詳細を出力してよい。

---

# 21. Private Helper構成

推奨する最小Private Helper：

```vb
Private Function AddUnresolvedFromText( _
    ByVal sourceText As String, _
    ByVal regex As Object, _
    ByVal seenVariables As Object, _
    ByVal variables As Collection _
) As Boolean
```

または同等のPrivate処理とする。

目的：

```text
Subject
BodyText
```

に同じ抽出処理を適用する。

Public APIを増やさない。

Private Helper名はImplementation時に変更してよい。

---

# 22. Conceptual Algorithm

```text
CheckUnresolved
↓
unresolvedResult = Nothing
↓
Result Dictionary生成
↓
Variables Collection生成
↓
Seen Dictionary生成
↓
RegExp生成
↓
Subject Scan
↓
BodyText Scan
↓
HasUnresolved = (Variables.Count > 0)
↓
Result Carrier確定
↓
HasUnresolved?
├─ No
│   ↓
│  Success Result
│
└─ Yes
    ↓
   Failure / Error Result
   +
   unresolvedResult保持
```

---

# 23. Scanner非依存

P1-06 Production Codeから、

```vb
modTemplateScanner.ScanTemplate(...)
```

を呼び出さない。

理由：

1. `MTS-UNR-004` でScanner成立性とUnresolved Checkを独立判定する
2. Unresolved Checkerは最終Snapshotのみを入力として完結できる
3. Invalid Candidate処理をP1-06へ混在させない
4. TemplateScanResult構造へ不要な依存を作らない
5. P1-06 Core Testを単独実行可能にする

Token Patternに類似ロジックが存在しても、Result責務は統合しない。

---

# 24. Outlook / Word COM非依存

`modUnresolvedChecker` は以下を参照しない。

```text
Outlook.Application
Outlook.MailItem
Outlook.Inspector
Word.Document
Word.Range
```

また以下も行わない。

```text
CreateObject("Outlook.Application")
GetObject(, "Outlook.Application")
Inspector.WordEditor
Range.Find
```

Core TestはClassic Outlook未起動でも実行可能でなければならない。

---

# 25. MailItem Lifecycle

P1-06 APIはMailItem Lifecycleを変更しない。

```text
CheckUnresolved()
→ MailItem Closeしない

CheckUnresolved()
→ MailItem Displayしない

CheckUnresolved()
→ MailItem Saveしない
```

Integration TestではTest Harnessが最後に `CloseWithoutSave()` を呼び、残存MailItemをCleanupする。

これはP1-06 Production責務ではない。

---

# 26. P1-06 Production Flow

P1-06完了時点の最小Production Flowを以下とする。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
ReadSubject
+
ReadBodyText
↓
ScanTemplate
↓
P1 FormattedValues Fixture
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
ReadSubject
+
ReadBodyText
↓
Render後Snapshot
↓
CheckUnresolved
↓
Unresolved Result
↓
Test Harness Cleanup
CloseWithoutSave
```

P1-06では、

```text
DisplayMail
```

へ接続しない。

---

# 27. P1-07接続Boundary

P1-06 OutputはP1-07で以下へ接続可能でなければならない。

```text
CheckUnresolved
↓
COperationResult
+
Unresolved Result
↓
HasUnresolved?
├─ Yes
│   ├─ Displayしない
│   ├─ VariablesをUI通知へ渡す
│   └─ CloseWithoutSave
│
└─ No
    ↓
DisplayMail
```

P1-06 Production Codeへこの分岐を実装しない。

---

# 28. Core Test

## 28.1 推奨Test Module

```text
modP1_06MinimalUnresolvedCheckerCoreTest
```

推奨Entry Point：

```vb
TestP106MinimalUnresolvedCheckerCore
```

---

## 28.2 C1 Baseline / Unresolved 0

Input：

```text
Subject:
【ABC123】ゲート審査 2026/09/30 / ABC123

BodyText:
対象機種：ABC123
開催日：2026/09/30
担当部署：品質部
備考：確認お願いします
```

Expected：

```text
CheckUnresolved:
PASS

HasUnresolved:
False

Variables.Count:
0
```

---

## 28.3 C2 Subject 1件

Input：

```text
Subject:
【ABC123】ゲート審査 {{GateDate}}

BodyText:
未置換なし
```

Expected：

```text
CheckUnresolved:
Failure / Error Result

HasUnresolved:
True

Variables.Count:
1

Variables:
GateDate
```

---

## 28.4 C3 Body 1件

Input：

```text
Subject:
未置換なし

BodyText:
開催日：{{GateDate}}
```

Expected：

```text
Failure / Error Result
HasUnresolved = True
Variables = GateDate
```

---

## 28.5 C4 Subject / Body重複

Input：

```text
Subject:
{{GateDate}}

BodyText:
{{GateDate}}
```

Expected：

```text
Variables.Count = 1
```

---

## 28.6 C5 Case Insensitive

Input：

```text
Subject:
{{GateDate}} / {{gatedate}}

BodyText:
{{GATEDATE}}
```

Expected：

```text
Variables.Count = 1
Variables(1) = 初回検出表記相当
```

大小文字違いを別Variableとして返さない。

---

## 28.7 C6 複数Variable

Input：

```text
Subject:
{{ModelName}} / {{GateDate}}

BodyText:
{{Department}} / {{modelname}}
```

Expected：

```text
HasUnresolved = True
Variables.Count = 3

論理Variable:
ModelName
GateDate
Department
```

列挙順そのものをFormal PASS条件にしない。

---

## 28.8 C7 Empty Input

Input：

```text
subjectText = vbNullString
bodyText = vbNullString
```

Expected：

```text
CheckUnresolved = PASS
HasUnresolved = False
Variables.Count = 0
```

---

## 28.9 C8 Formatted Value由来相当Token

Input：

```text
Subject:
未置換なし

BodyText:
備考：担当：{{Department}}
```

Expected：

```text
Failure / Error Result
HasUnresolved = True
Variables = Department
```

再帰Renderしない。

---

# 29. Integration Test

## 29.1 推奨Test Module

```text
modP1_06MinimalUnresolvedCheckerIntegrationTest
```

推奨Entry Point：

```vb
TestP106MinimalUnresolvedCheckerIntegration
```

必要に応じて以下を分離してよい。

```vb
TestP106UnresolvedZeroIntegration
TestP106MissingValueIntegration
```

---

## 29.2 Integration Normal Flow

Baseline OFTとP1-05 FormattedValues Fixtureを使用する。

概念手順：

```text
1. Settings.TemplatePath取得
2. ResolveWorkbookRelativePath
3. CreateMailFromTemplate
4. ReadSubject
5. ReadBodyText
6. ScanTemplate
7. ScanTemplate.Success確認
8. InvalidCandidates.Count = 0確認
9. Expected ValidVariables確認
10. FormattedValues Fixture生成
11. RenderSubject
12. SetSubject
13. ReplaceBodyVariables
14. ReadSubject
15. ReadBodyText
16. CheckUnresolved
17. Unresolved Result確認
18. CloseWithoutSave
```

Expected：

```text
CheckUnresolved = PASS
HasUnresolved = False
Variables.Count = 0
CloseWithoutSave = PASS
```

---

## 29.3 Scanner独立確認

P1-06 Integrationでは、

```text
ScanTemplate.Success = True
+
InvalidCandidates.Count = 0
+
Expected ValidVariables確認
```

をRender前Preconditionとして確認する。

その後、

```text
CheckUnresolved
→ 0件
```

を独立して確認する。

`Unresolved 0件` だけを理由にScanner成立をPASSとしない。

---

# 30. Missing Value Integration

## 30.1 目的

P1-05の、

```text
Missing Formatted Value
→ RendererはTokenを残す
```

BoundaryとP1-06を接続する。

---

## 30.2 Fixture

Baseline Variableのうち1件をFormattedValuesから意図的に除外する。

推奨：

```text
GateDate
```

FormattedValues：

```text
ModelName   = ABC123
Department  = 品質部
Comment     = 確認お願いします

GateDate:
NOT INCLUDED
```

---

## 30.3 Flow

```text
Render
↓
GateDate Token残存
↓
ReadSubject / ReadBodyText
↓
CheckUnresolved
```

Expected：

```text
CheckUnresolved:
Failure / Error Result

HasUnresolved:
True

Variables:
GateDate
```

GateDateがSubject / Body双方に残っていてもVariablesは1件とする。

---

# 31. Integration時Lifecycle

P1-06 Integration Testでは、Unresolvedあり / なしにかかわらずTest終了時に、

```text
CloseWithoutSave
```

を実行する。

ただしこれは、

```text
P1-06 Checker自身がCloseする
```

ことを意味しない。

P1-07で正式なFail Closed Orchestrationを接続するまでは、Test HarnessがCleanupを担当する。

---

# 32. Negative / Technical Error Verification

P1-06ではRuntime Errorを意図的に起こすためのProduction Public APIを追加しない。

以下を目的としたTest HookはProductionへ追加しない。

```text
ForceRegExpFailure
ForceDictionaryFailure
ForceUnexpectedError
```

Core / Integrationで安全に再現できないUnexpected Runtime Errorの網羅確認はP6へ残す。

P1-06ではStatic Reviewとして以下を確認する。

```text
On Error経路が存在
UnexpectedErrorへ変換
unresolvedResult = Nothing
未処理Runtime Errorを外へ伝播しない
```

---

# 33. Regression Scope

P1-06では新規 `modUnresolvedChecker` を追加するのみとし、原則として既存Production ModuleのSemantic変更を行わない。

そのためRegressionは変更影響に応じて必要最小限とする。

最低限：

```text
VBA Compile
P1-06 Core Test
P1-06 Normal Integration
P1-06 Missing Value Integration
```

P1-06 Integration自体が以下の既存経路を通過する。

```text
Path Resolution
CreateMailFromTemplate
ReadSubject / ReadBodyText
ScanTemplate
RenderSubject
SetSubject
ReplaceBodyVariables
Render後Read
CloseWithoutSave
```

これをP1-05主要Regression Evidenceとして利用してよい。

P1-02 Warm / Cold Lifecycle Full RegressionをP1-06追加だけを理由に必須再実行しない。

既存Moduleへ変更が発生した場合はRegression範囲を再評価する。

---

# 34. Warm / Cold Start

P1-06 Core Logic自体はOutlook Start Stateに依存しない。

Integration Verificationでは最低限1経路を実行する。

P1-06 Production実装が `modOutlookAdapter` を変更しない限り、Warm / Cold両方のFull Regressionを必須としない。

ただしP1 Phase Verification / P1-07ではWalking Skeleton全体としてWarm / Cold経路を再確認する。

---

# 35. Compile Evidence

P1-06 Verificationでは以下を明示的に確認する。

```text
Debug
↓
Compile VBAProject
↓
PASS
```

Compile不可の場合、P1-06をPASS扱いしない。

---

# 36. Evidence

最低限以下を記録する。

```text
Workbook
Execution Baseline
Compile Result

Core:
Case ID
Subject Input
BodyText Input
CheckUnresolved Result
HasUnresolved
Variables Count
Variables一覧
ErrorType
Error Target

Integration:
Resolved OFT Path
CreateMailFromTemplate Result
Pre-Render Subject / BodyText
ScanTemplate Result
ValidVariables
InvalidCandidates
FormattedValues Key
RenderSubject Result
SetSubject Result
ReplaceBodyVariables Result
Post-Render Subject / BodyText
CheckUnresolved Result
HasUnresolved
Variables
CloseWithoutSave Result

Regression:
P1-05主要経路確認結果
```

BodyText全文をEvidenceへ必須出力しない。

未置換判定に必要な箇所だけ診断出力してよい。

---

# 37. Production Hard Coding Rule

Production Codeへ以下をHard Codingしてはならない。

```text
ModelName
GateDate
Department
Comment
ABC123
品質部
2026/09/30
```

Production Checkerは任意の有効VariableNameを汎用的に処理する。

Test Fixture側ではBaseline Test Dataを明示的に使用してよい。

```text
Test Fixture Hard Coding
= Allowed

Production Variable Hard Coding
= Prohibited
```

---

# 38. Implementation Detail Rule

P1-06実装時に変更してよい事項：

```text
Private Helper名
Local変数名
RegExp Object生成Helperの有無
Dictionary生成Helperの有無
Debug.Print内容
Core Test Module内部構成
Integration Test Module内部構成
Collection列挙方法
Error Messageの軽微な文言調整
```

ただし以下は変更してはならない。

```text
Render後Snapshotを入力とする
Subject / BodyTextを対象とする
有効Tokenを残存判定する
Case Insensitiveに重複統合する
HasUnresolved + Variablesを返す
未置換1件以上をFail扱いとする
Scanner Resultと独立判定する
COM Objectへ依存しない
再帰Renderしない
Display / Close / UIをP1-06へ混在させない
```

これらを変更する必要が生じた場合、Implementation側だけで解釈変更せずFinding Ruleへ従う。

---

# 39. Finding Classification

P1-06実装・Verification中のFindingは以下で分類する。

## 39.1 Implementation Defect

既存Specificationどおりに実装されていない。

例：

```text
Case Insensitive統合されない
SubjectしかScanしない
BodyTextしかScanしない
Variables一覧が失われる
UnresolvedありでもSuccessを返す
Runtime Errorが未処理で伝播する
```

対応：

```text
Production Code修正
↓
Verification再実施
```

---

## 39.2 Test Artifact Gap

Production LogicではなくTest Code / Fixtureが不足している。

例：

```text
Case統合を独立確認していない
Missing Value Fixtureが不正
Expected Variable一覧を確認していない
```

対応：

```text
Test Artifact修正
```

Production Codeを不要に変更しない。

---

## 39.3 Requirement Gap

利用者から見た新しい振る舞いを決める必要がある。

例：

```text
literalな {{VariableName}} を入力値として最終メールへ残すことを許可するか
```

この場合、P1-06 Implementation Detailで決定しない。

```text
Requirement Gap
↓
DOC-MVP-REQ判断
↓
必要なImpact Review
```

---

## 39.4 Design Finding

既存Design責務で成立しない技術構造が確認された場合。

例：

```text
String SnapshotだけではRequirementを実現できず、
COM Object情報が必須であることが判明
```

P1-06だけでArchitectureを変更しない。

---

## 39.5 Technical Finding

新しい技術成立性Riskが具体化した場合。

通常のImplementation + Verificationで十分確認可能ならTechnical Spikeを再開しない。

大規模な手戻りを避けるためImplementation前検証が必要な新Technical QuestionだけSpike要否を再判定する。

---

# 40. Consistency Review対象

本仕様のApproved化にあたり、以下とのCross-document Consistency Reviewを実施した。

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
DOC-TS-A
P1-04 Minimal Template Scanner 実施仕様 v0.1
P1-05 Minimal Render 実施仕様 v0.1
P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1
```

確認観点：

```text
Requirement Conflict
Design Conflict
Test Specification Conflict
Implementation Plan Conflict
P1-05 Boundary Conflict
P1-06 Boundary Conflict
Scope Expansion
Traceability Break
Requirement Gap
Design Finding
Technical Spike Reopen
Baseline Change
Governance Conflict
```

---

# 41. Approval Criteria

本仕様は以下のApproval Criteriaを満たした。

```text
Cross-document Consistency Review = PASS
または
PASS WITH CORRECTIONS
+
Corrections Applied

Blocking Finding = 0
Requirement Gap = 0
Design Finding = 0
Technical Spike Reopen = Not Required
Baseline Change = Not Required
```

Production実装は本Approved仕様を基準として実施する。

---

# 42. Verification PASS Criteria

P1-06 Verificationの最低PASS条件：

```text
VBA Compile                         PASS
Core C1 Unresolved 0              PASS
Core C2 Subject 1件               PASS
Core C3 Body 1件                  PASS
Core C4 Subject / Body重複        PASS
Core C5 Case Insensitive          PASS
Core C6 複数Variable              PASS
Core C7 Empty Input               PASS
Core C8 Snapshot上Token           PASS
Normal Integration                PASS
Missing Value Integration         PASS
Scanner / Unresolved独立判定      PASS
P1-05主要Regression               PASS
Unhandled Runtime Error           NONE
Blocking Finding                  0
```

---

# 43. P1-06 Completion Criteria

P1-06を `PASS / COMPLETE` と判定するための条件：

```text
Approved Unit Specification       PASS
VBA Compile                       PASS
modUnresolvedChecker Production   PASS
Unresolved 0件判定               PASS
Subject残存検出                   PASS
Body残存検出                      PASS
Case Insensitive重複統合          PASS
Variables一覧                     PASS
Unresolved Failure Result         PASS
P1-05 Integration                 PASS
Missing Value Integration         PASS
必要Regression                    PASS
Production Patch Review           PASS
Blocking Finding = 0              PASS
```

P1-06 Completionだけでは、

```text
CP-P1
```

は成立しない。

P1 Walking Skeleton上は、

```text
P1-06 Unresolved Checker
+
P1-07 Display / E2E Integration
+
P1 Phase Verification
```

を通じてCP-P1判定へ接続する。

これはPhase責務境界の説明であり、Project State / Next Actionを本Technical Specificationへ保持するものではない。

---

# 44. Static Review Checklist

Production Patch Reviewでは最低限以下を確認する。

```text
[ ] modUnresolvedCheckerのみでCore Logicが完結している
[ ] Outlook Object Model参照なし
[ ] Word Object Model参照なし
[ ] Excel ListObject参照なし
[ ] VariableDefinition Data Access参照なし
[ ] OptionMaster Data Access参照なし
[ ] TemplateScanResult依存なし
[ ] Public APIが1本に抑えられている
[ ] Production Variable Hard Codingなし
[ ] RegExpは有効Variable Tokenのみを抽出する
[ ] Case Insensitive重複統合あり
[ ] unresolvedResult初期化あり
[ ] UnresolvedありでもVariablesが保持される
[ ] Technical Failure時にpartial Resultを残さない
[ ] UnresolvedありはFailure Result + unresolvedResult保持
[ ] P1 Interim ErrorTypeを使用する場合もP6最終分類を拘束しない
[ ] Unexpected Runtime ErrorはUnexpectedErrorへ変換
[ ] MsgBoxなし
[ ] Displayなし
[ ] Closeなし
[ ] Sendなし
[ ] 再帰Renderなし
```

---

# 45. Production Patch想定

P1-06で想定するProduction Change：

```text
ADD:
modUnresolvedChecker
```

原則として以下は変更しない。

```text
modResult
modTemplateScanner
modSubjectRenderer
modOutlookAdapter
modSettingsData
modVariableDefinitionData
modOptionMasterData
CErrorInfo
COperationResult
```

既存Module修正が必要になった場合は、必要性と変更影響をFindingとして確認する。

---

# 46. Test Artifact想定

P1-06で想定するTest Artifact：

```text
modP1_06MinimalUnresolvedCheckerCoreTest
modP1_06MinimalUnresolvedCheckerIntegrationTest
```

必要に応じてIntegrationを1 Moduleへまとめてよい。

Production CodeへTest専用Public APIを追加しない。

---

# 47. API Contract Summary

Production API：

```vb
Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

Result：

```text
unresolvedResult
├─ HasUnresolved : Boolean
└─ Variables     : Collection
```

Success：

```text
HasUnresolved = False
Variables.Count = 0
COperationResult.Success = True
```

Unresolved：

```text
HasUnresolved = True
Variables.Count >= 1
COperationResult.Success = False
Target = UnresolvedVariables

ErrorType:
P1 Interim Mappingとして既存ErrorTypeを使用可
正式なUnresolved Error分類はP6で最終化
```

Technical Failure：

```text
unresolvedResult = Nothing
COperationResult.Success = False
ErrorType = UnexpectedError
Target = UnresolvedChecker
```

---

# 48. Traceability Summary

```text
FR-UNRESOLVED-001
↓
DOC-MVP-DES §23
↓
modUnresolvedChecker.CheckUnresolved
↓
MTS-UNR-001 / 002 / 004

FR-UNRESOLVED-002
↓
DOC-MVP-DES §23
↓
unresolvedResult("Variables")
↓
MTS-UNR-003

FR-VAR-004
↓
Case Insensitive Rule
↓
seenVariables.CompareMode = vbTextCompare
↓
MTS-UNR-003
```

P1-06ではMTS-UNR-002のDisplay / Close部分までを単独完了扱いしない。

---

# 49. Consistency Review Result

Cross-document Consistency Review結果：

```text
Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P1-05 Boundary Conflict:
NONE

P1-06 Boundary Conflict:
NONE

Scope Expansion:
NONE

Traceability Break:
NONE

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

Correction：

```text
CR-P1-06-001
Unresolved Error Type MappingのP6責務保全
APPLIED

CR-P1-06-002
Review Source名の正規化
APPLIED

CR-P1-06-003
Draft状態記述のApproved版整理
APPLIED
```

---

# 50. Approved Result

```text
P1-06 Minimal Unresolved Checker
Implementation Unit Specification v0.1

Status:
APPROVED

Boundary:
P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1
CONFORMED

Consistency Review:
PASS WITH CORRECTIONS
→ CORRECTIONS APPLIED

Production API:
CheckUnresolved(subjectText, bodyText, unresolvedResult)

Result Carrier:
Late Bound Scripting.Dictionary
├─ HasUnresolved
└─ Variables As Collection

Unresolved Semantics:
1件以上
→ COperationResult.Success = False
→ unresolvedResult保持
→ Warning onlyで継続しない

Error Classification:
P1で最終Unresolved Error分類を固定しない
必要な既存ErrorType使用はP1 Interim Mapping
正式分類はP6で最終化

Unexpected Runtime Error:
→ UnexpectedError

Production Scope:
modUnresolvedChecker

Display / Close / UI:
OUT OF SCOPE

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
