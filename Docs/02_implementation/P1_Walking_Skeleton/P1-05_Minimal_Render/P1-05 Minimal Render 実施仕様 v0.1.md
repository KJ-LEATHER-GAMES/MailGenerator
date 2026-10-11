# P1-05 Minimal Render 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-05 Minimal Render 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Draft |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-05 Minimal Render |
| Primary Production Module | `modSubjectRenderer` / `modOutlookAdapter` |
| 前提Implementation Unit | P1-04 Minimal Template Scanner = PASS / COMPLETE |
| Primary Verification | Subject Case Insensitive全出現置換 + Word Range Body基本置換 + Render後Snapshot再取得 |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `DOC-TS-A` — Technical Spike A
- `P1-03 Template Snapshot Boundary 実施仕様 v0.1`
- `P1-04 Minimal Template Scanner 実施仕様 v0.1`
- `P1-05 Minimal Render Boundary Confirmation` — 本仕様作成時に確定したImplementation Boundary

### v0.1 作成概要

P1-04で成立したProduction `modTemplateScanner` の最小Scan Boundary、およびP1-03までに成立済みのActive MailItem / Subject / BodyText Snapshot Boundaryを前提として、P1 Walking Skeleton内の最小Render経路を確立する。

本Unitでは以下を行う。

1. P1用の `FormattedValues` BoundaryをLate Bound `Scripting.Dictionary` として確立する
2. `modSubjectRenderer` にSubject文字列のCase Insensitive全出現置換を実装する
3. `modOutlookAdapter` に `SetSubject()` を実装する
4. `modOutlookAdapter` に `ReplaceBodyVariables()` を実装する
5. BodyはWord `Range.Find` / `Range.Text` により生成用MailItemそのものを編集する
6. Render後に既存 `ReadSubject()` / `ReadBodyText()` を再実行し、新しい文字列Snapshotを取得する
7. Outlook / Word COM ObjectをCore Logicへ公開しない
8. Render API自身へUnresolved Check、Display、MailItem Close責務を混在させない
9. P1ではValue FormatterをProduction実装せず、Smoke Test Fixtureから既にFormat済みのString値を供給する
10. P4 / P5の責務を先回り実装しない

本仕様は、BL-MVP-003で承認済みのRequirement / Design / Test Definition、およびP1-05 Boundary ConfirmationをImplementation Detailへ具体化するものである。

新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Detail / Unit Specification**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-05の目的は、Production Architecture上で以下の最小Render Boundaryを成立させることである。

```text
Existing Active MailItem
+
Subject Snapshot
+
FormattedValues
        │
        ├───────────────┐
        │               │
        ▼               ▼
modSubjectRenderer   modOutlookAdapter
        │            ReplaceBodyVariables
        │               │
renderedSubject         WordEditor
        │               │
        ▼               ▼
modOutlookAdapter     Word Document
SetSubject              │
        │               ▼
        │           Range.Find
        │               │
        │           Range.Text
        │               │
        └───────┬───────┘
                ▼
        Existing Active MailItem
                │
                ▼
        ReadSubject / ReadBodyText
                │
                ▼
        Render後Snapshot
```

P1-05では、

> **生成済みの表示用文字列を、最終ArchitectureのSubject / Body Render経路へ通せること**

を確認する。

Raw InputのValidation / Formatting、Current Data Guard、Unresolved Check、Displayまでを完成させることは本Unitの目的ではない。

---

# 3. Baseline上の根拠

## 3.1 Requirement

`DOC-MVP-REQ` では、Subject / Bodyについて以下が要求されている。

```text
Subject
- 有効なVariableを入力・選択値へ置換
- 同一Variableの全出現箇所を置換
- VariableNameはCase Insensitive

Body
- 有効なVariableを入力・選択値へ置換
- 同一Variableの全出現箇所を置換
- VariableNameはCase Insensitive
- 入力値を意図した文字列として反映
- Variable置換部分以外の代表的な基本書式を維持
```

P1-05では、このうちWalking Skeleton成立に必要な最小Render経路をImplementation Detailとして実装する。

Requirement上の正式な利用者入力経路はUserForm / Validation / Value Formattingを含むが、P1-05では後続P4の責務を代替しない。

## 3.2 Design

`DOC-MVP-DES` ではRender Engineを以下の責務分離として定義している。

```text
InputValues
↓
Value Formatter
↓
Formatted Values
├────────────→ Subject Renderer
│                    ↓
│               Subject設定
│
└────────────→ Outlook Adapter
                     ↓
               WordEditor
                     ↓
               Word Document
                     ↓
          Range.Find / Range.Text
                     ↓
                 Body反映
```

Subject RendererはPlain Text文字列を処理するCore Logicとする。

Bodyの物理置換はOutlook Adapter内部でWord Object Modelを使用する。

## 3.3 Outlook Adapter

`DOC-MVP-DES` ではOutlook AdapterのMailItem Boundaryとして以下が定義されている。

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
DisplayMail()
CloseWithoutSave()
```

P1-05ではこのうち、

```text
SetSubject()
ReplaceBodyVariables()
```

をProduction Boundaryへ追加する。

既存の以下は変更せず再利用する。

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
CloseWithoutSave()
```

## 3.4 Implementation Plan

`DOC-MVP-IMPL` のP1 Walking Skeletonでは、以下を最終Architecture上で成立させることが要求されている。

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

P1-05はこのうち、

```text
Input Value相当のFormattedValues Fixture
↓
Subject Render
↓
Word Range Body Render
↓
Subject / BodyText再取得
```

を担当する。

Implementation Plan上、Range.Find Loopは、

```text
P1基本形
/
P5最終化
```

とされている。

したがってP1-05で完成版Render Engine全体を先回り実装しない。

---

# 4. 前提Implementation Boundary

## 4.1 P1-03成立済みBoundary

P1-03により、同一Active MailItemから以下を取得可能である。

```text
ReadSubject()
↓
Subject As String

ReadBodyText()
↓
BodyText As String
```

Outlook / Word COM Objectは `modOutlookAdapter` 内部に閉じ込められている。

## 4.2 P1-04成立済みBoundary

P1-04により以下が成立済みである。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Minimal Scan Result：

```text
scanResult
├─ ValidVariables
└─ InvalidCandidates
```

Valid VariableはCase Insensitiveで重複統合される。

P1-05はScannerを再実装しない。

## 4.3 Active MailItem

P1-05は既存 `modOutlookAdapter` が保持するActive MailItemを利用する。

P1-05自身で別MailItemを生成しない。

---

# 5. Scope

P1-05の実装対象は以下とする。

```text
FormattedValues Boundary
├─ Late Bound Scripting.Dictionary
├─ VariableName → String
└─ P1 Smoke Test Fixtureから供給

modSubjectRenderer
├─ RenderSubject()
├─ Plain Text Subject処理
├─ Case Insensitive Variable照合
├─ 全出現箇所置換
├─ Missing Value時は対象Variableを残す
└─ Extra Value時はNo-op

modOutlookAdapter
├─ SetSubject()
├─ ReplaceBodyVariables()
├─ Inspector / WordEditor / Word Document取得
├─ Word Range.Find
├─ MatchCase = False
├─ Range.Textによる置換
├─ 全出現箇所置換の基本Loop
├─ Body全文再設定禁止
└─ COM Object非公開

Render後
├─ ReadSubject()
├─ ReadBodyText()
└─ 新しいSnapshot取得

Error / Lifecycle
├─ COperationResult使用
├─ RenderError / OutlookError等の既存Error分類使用
├─ Render API自身はMsgBox表示しない
├─ Render API自身はMailItemをDisplayしない
└─ Render API自身はMailItemをCloseしない
```

---

# 6. Out of Scope

P1-05では以下を実装しない。

```text
Raw Input取得
Input State
UserForm
Input Validator
Required Validation
Date Parse
Date 6 Format
曜日生成
Select Validation
Optional判定
Value Formatter Production実装
VariableDefinition取得
OptionMaster取得
Current Data Guard
Current OFT再Scanの正式生成経路
Configuration Validator
TemplateLocation
Sync Engine
Unresolved Checker
UnresolvedCheckResult
DisplayMail
最終生成MailItem Display
自動送信
Error UI
Validation UI
正式なUser Message
完成版COM Error Handling
完成版Range.Find Loop
Formal MVP Test
```

また、P1-05のためだけに以下を追加しない。

```text
CFormattedValues
CSubjectRenderResult
CBodyRenderer
WordRenderer専用Class
WordEditor専用Adapter
Render専用Interface
MailItemを返すPublic API
Inspectorを返すPublic API
WordEditorを返すPublic API
Word Documentを返すPublic API
Word Rangeを返すPublic API
Test専用Production Public API
```

P1-05では、P1-02 / P1-03で成立済みの以下も再設計しない。

```text
Classic Outlook Readiness
Existing Explorer再利用
Cold Start Visible Explorer Initialization
MailItem Ownership
ReadSubject
ReadBodyText
TryGetWordDocument相当
CloseWithoutSave
Late Binding方針
```

---

# 7. Responsibility Boundary

## 7.1 Production Boundary

P1-05完了時の責務境界は以下とする。

```text
Application / Core Logic
        │
        │ Subject As String
        │ formattedValues As Object
        │ COperationResult
        ▼
──────────────────────────────────
Core Logic Boundary
──────────────────────────────────
        │
        ▼
modSubjectRenderer
        │
        │ renderedSubject As String
        ▼
──────────────────────────────────
Infrastructure Boundary
──────────────────────────────────
        │
        ▼
modOutlookAdapter
        │
        ├─ SetSubject()
        ├─ ReplaceBodyVariables()
        │
        ├─ MailItem      [Private Module State]
        ├─ Inspector     [Private / Local]
        ├─ WordEditor    [Private / Local]
        ├─ Word Document [Private / Local]
        └─ Word Range    [Private / Local]
```

Core LogicはOutlook / Word COM Objectへ直接依存しない。

## 7.2 Subject責務

```text
modSubjectRenderer
= String → String

modOutlookAdapter.SetSubject
= String → Active MailItem.Subject
```

Subject RendererはMailItemを知らない。

SetSubjectはVariable置換を行わない。

## 7.3 Body責務

BodyはString Snapshotを書き戻さない。

```text
FormattedValues
↓
modOutlookAdapter
↓
Active MailItem
↓
Inspector
↓
WordEditor
↓
Word Document
↓
Range.Find / Range.Text
```

BodyTextはScanner / Unresolved Checker用の表示文字列Snapshotであり、Body Render用の書き戻しCarrierではない。

---

# 8. FormattedValues Boundary

## 8.1 定義

P1-05における `FormattedValues` は、

> VariableNameと、既にメール出力可能な表示用Stringとの対応を保持する一時的なKey / Value集合

とする。

概念：

```text
FormattedValues
├─ ModelName   → "ABC123"
├─ GateDate    → "2026/09/30"
├─ Department  → "品質部"
└─ Comment     → "確認お願いします"
```

## 8.2 Carrier

P1-05では専用Classを追加せず、Late Bound `Scripting.Dictionary` を使用する。

Production API Boundaryでは、

```vb
formattedValues As Object
```

として受け取る。

P1-05 Smoke Testで生成するDictionaryは以下を基本とする。

```vb
Set formattedValues = CreateObject("Scripting.Dictionary")
formattedValues.CompareMode = vbTextCompare
```

## 8.3 Key Contract

Keyは `{{ }}` を含まないVariableNameとする。

```text
OK:
ModelName
GateDate
Department
Comment

Not Boundary Value:
{{ModelName}}
{{GateDate}}
```

VariableName Syntax ValidationそのものはP1-05の責務ではない。

P1-04 Scannerまたは後続Configuration Guardの責務とする。

## 8.4 Value Contract

ValueはRender可能なStringとする。

```text
ModelName → "ABC123"
GateDate  → "2026/09/30"
```

P1-05では、

```text
"2026/09/30"
```

をDate Format処理結果として検証しない。

単なる既にFormat済みのString Fixtureとして扱う。

## 8.5 Case Insensitive

Dictionaryの `CompareMode = vbTextCompare` を使用してよい。

ただしRendererのCase Insensitive要件はDictionary CompareModeだけへ依存させない。

Subject Renderer / Body Renderer自身がCase Insensitive置換を保証する。

## 8.6 Lifetime

FormattedValuesは永続状態ではない。

以下を意味しない。

```text
Excelへの保存
Workbook Session State
Input State代替
VariableDefinition代替
Cache
Domain Model
```

P4で正式なValue Formatterが導入された後は、その出力を同じRender Boundaryへ接続する。

---

# 9. Subject Renderer API

## 9.1 Production Module

```text
modSubjectRenderer
```

## 9.2 Public API

```vb
Public Function RenderSubject( _
    ByVal subjectText As String, _
    ByVal formattedValues As Object, _
    ByRef renderedSubject As String _
) As COperationResult
```

## 9.3 基本処理

概念フロー：

```text
renderedSubject = vbNullString
↓
FormattedValues Boundary確認
↓
workingSubject = subjectText
↓
For Each VariableName
↓
token = "{{" & VariableName & "}}"
↓
Case Insensitive全出現置換
↓
renderedSubject = workingSubject
↓
Success
```

## 9.4 Case Insensitive全出現置換

SubjectはPlain Textとして処理する。

概念上、以下と同等の置換を行う。

```vb
workingSubject = Replace( _
    workingSubject, _
    "{{" & variableName & "}}", _
    replacement, _
    1, _
    -1, _
    vbTextCompare _
)
```

具体的なPrivate Helper化の有無はImplementation時に決定してよい。

## 9.5 Case Example

Input：

```text
Subject:
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}

FormattedValues:
ModelName → ABC123
GateDate  → 2026/09/30
```

Expected：

```text
【ABC123】ゲート審査 2026/09/30 / ABC123
```

## 9.6 Missing Value

SubjectにVariableが存在するがFormattedValuesに対応Keyが存在しない場合、

```text
対象Variableをそのまま残す
```

とする。

例：

```text
Subject:
{{ModelName}} / {{GateDate}}

FormattedValues:
ModelName → ABC123

Result:
ABC123 / {{GateDate}}
```

Renderer自身はMissing ValueをUnresolved Errorとして判定しない。

残存Variable判定は後続 `modUnresolvedChecker` の責務とする。

## 9.7 Extra Value

FormattedValuesに存在するがSubjectに存在しないVariableはNo-opとする。

```text
Find 0
→ Success
```

とする。

Subject / Body Location判定をRendererへ持たせない。

## 9.8 Empty Subject

`subjectText = vbNullString` 自体はRender Errorとしない。

Rendererは空文字列を有効なPlain Text入力として扱う。

Subject空欄可否の利用者仕様判断をP1-05で追加しない。

## 9.9 非責務

`RenderSubject()` は以下を行わない。

```text
MailItem取得
MailItem.Subject設定
Outlook Readiness
Scanner
VariableName Syntax Validation
Input Validation
Value Formatting
Unresolved Check
Display
MailItem Close
MsgBox
```

---

# 10. SetSubject API

## 10.1 Production Module

```text
modOutlookAdapter
```

## 10.2 Public API

```vb
Public Function SetSubject( _
    ByVal subjectText As String _
) As COperationResult
```

## 10.3 責務

`SetSubject()` は以下のみを担当する。

```text
内部 mMailItem妥当性確認
↓
mMailItem.Subject = subjectText
↓
Success
```

## 10.4 非責務

`SetSubject()` は以下を行わない。

```text
Variable置換
Case Insensitive比較
FormattedValues参照
Scanner
Value Formatting
Classic Outlook Readiness再実行
MailItem生成
MailItem.Display
MailItem.Close
Unresolved Check
User Message表示
```

## 10.5 Empty Subject

空文字列設定そのものはAPI Errorとしない。

```vb
SetSubject vbNullString
```

を許容する。

P1-05で新しいSubject必須Requirementを追加しない。

---

# 11. ReplaceBodyVariables API

## 11.1 Production Module

```text
modOutlookAdapter
```

## 11.2 Public API

```vb
Public Function ReplaceBodyVariables( _
    ByVal formattedValues As Object _
) As COperationResult
```

## 11.3 基本処理

概念フロー：

```text
Active mMailItem確認
↓
Inspector取得
↓
WordEditor取得
↓
Word Document取得
↓
For Each formattedValues Key
↓
Search Token生成
↓
Word Range.Find
↓
Case Insensitive
↓
Found Range.Text = Replacement
↓
次のOccurrenceへ進む
↓
全Variable完了
↓
Success
```

## 11.4 Search Token

Dictionary Key：

```text
ModelName
```

Search Token：

```text
{{ModelName}}
```

とする。

## 11.5 Range.Find Rule

最低限以下を満たす。

```text
Case Insensitive
Forward Search
Document内検索
同一Variableの全出現箇所置換
Wrapによる無限再検索を行わない
```

Word Object Modelの具体的なProperty設定値および数値定数はImplementation時に確定する。

## 11.6 Search Progression

同一Variableの置換では、置換後にDocument先頭から同じVariableを再検索し続けない。

概念：

```text
Document Range
↓
Find token
↓
Found Range取得
↓
Found Range.Text = replacement
↓
検索開始位置を置換済みRange後方へ進める
↓
Document末尾まで継続
```

これにより、同一Occurrenceの再検索や無限Loopを避ける。

P1-05ではFormatted Value内の特殊構文を再帰的に展開する機能を追加しない。

## 11.7 Find 0件

FormattedValuesに存在するVariableがBody内に存在しない場合、

```text
Find 0
→ Errorにしない
→ 次のVariableへ進む
```

とする。

Subject / Body / Both Location情報をBody Rendererへ要求しない。

## 11.8 Range.Text

FoundしたVariable Rangeだけを、

```text
Range.Text = replacement
```

で置換する。

Body全体を以下で再設定してはならない。

```text
MailItem.Body = ...
MailItem.HTMLBody = ...
Document.Content.Text = Body全文...
```

## 11.9 HTML Encode

P1-05 Body RenderingではFormatted ValueへHTML Encodeを適用しない。

Formatted Valueは表示用文字列として `Range.Text` へ設定する。

## 11.10 書式

P1-05はWord Range方式を使用することで、Variable置換部分以外のDocument構造を破壊しない経路を維持する。

ただし、Requirementsで定義した基本書式8項目の**Formalな保証判定**はP1-05 Completionだけでは行わない。

正式な書式維持成立はP5 / Formal MVP Testで確認する。

---

# 12. Render後Snapshot

## 12.1 再Read

Subject / Body Render後は既存Production APIを再利用する。

```text
SetSubject
+
ReplaceBodyVariables
↓
ReadSubject
+
ReadBodyText
↓
Render後Snapshot
```

## 12.2 古いSnapshotを更新しない

Render前に取得したSubject / BodyText Stringを書き換えてCurrent状態とみなさない。

Current状態が必要な場合は、

```text
ReadSubject()
ReadBodyText()
```

を再実行する。

## 12.3 P1-05での用途

Render後SnapshotはP1-05 Smoke TestでRender結果を確認するために使用する。

後続P1-06では同じBoundaryを `modUnresolvedChecker` へ接続する。

---

# 13. Error / Result Boundary

## 13.1 基本方針

既存 `COperationResult` / `CErrorInfo` を使用する。

P1-05のためにResult Class体系を追加しない。

Core / Infrastructureから直接MsgBoxを表示しない。

## 13.2 Subject Renderer Error

`modSubjectRenderer` 内部のRender処理として扱えるFailureは `RenderError` を基本とする。

最低限以下をFailure候補とする。

```text
formattedValues = Nothing
FormattedValues Boundaryとして利用不能
予期しないSubject置換処理Error
```

Failure時：

```text
renderedSubject = vbNullString
COperationResult.Success = False
```

を基本とする。

## 13.3 SetSubject Error

最低限以下をFailureとする。

### Case S1：Active MailItemなし

```text
CreateMailFromTemplate未実行
↓
SetSubject
```

または、

```text
CreateMailFromTemplate
↓
CloseWithoutSave
↓
SetSubject
```

Expected：

```text
Failure
未処理Runtime Errorなし
Active MailItem問題をResultから識別可能
```

### Case S2：Subject設定COM Error

`mMailItem.Subject` 設定時にCOM / Runtime Errorが発生した場合、

```text
OutlookErrorまたは既存Error Policyに従う適切なErrorへ変換
Failure Result
未処理Runtime Errorなし
```

とする。

## 13.4 ReplaceBodyVariables Error

最低限以下をFailureとする。

```text
Active MailItemなし
Inspector取得失敗
WordEditor取得失敗
Word Document取得失敗
Range.Find実行失敗
Range.Text設定失敗
```

Outlook / Word COM Errorは既存Designに従い `OutlookError` または適切な既存Errorへ変換する。

## 13.5 Error Target

新しいError Code体系は作らない。

既存 `CErrorInfo.Target` を利用し、少なくとも処理段階を識別できる値を使用する。

候補：

```text
SubjectRender
Subject
BodyRender
WordEditor
WordRange
```

既存実装の命名規則が存在する場合はそれへ整合させる。

## 13.6 Message

Messageは少なくとも問題段階を識別可能とする。

例：

```text
Unable to render the mail subject.
Unable to set the Outlook mail subject.
Unable to replace variables in the Outlook mail body.
```

P1-05では最終User-facing Message文言を確定しない。

---

# 14. MailItem Ownership / Lifecycle

## 14.1 Ownership

P1-02 / P1-03で確立したOwnershipを維持する。

| Object | Owner | P1-05での扱い |
|---|---|---|
| `mOutlookApp` | Adapter Lifecycle | Render処理では解放しない |
| Explorer | Classic Outlook / Adapter Private Helper | 既存方針維持 |
| `mMailItem` | Adapter Lifecycle | Render処理ではClose / Displayしない |
| Inspector | Adapter Private / Local | Body Render時のみ取得 |
| Word Document | Adapter Private / Local | Body Render時のみ取得 |
| Word Range | Adapter Private / Local | Body Render Loop内で取得・更新 |

## 14.2 Render APIはMailItemをCloseしない

以下を維持する。

```text
SetSubject()
→ MailItem Closeしない

ReplaceBodyVariables()
→ MailItem Closeしない
```

理由：

- 同一生成用MailItemにSubject / Body双方のRenderを反映する必要がある
- Render後にSubject / BodyTextを再取得する必要がある
- 後続P1-06 / P1-07で同一MailItemを利用する
- Render責務へLifecycle終了責務を混在させない

## 14.3 Render APIはDisplayしない

```text
SetSubject()
→ Displayしない

ReplaceBodyVariables()
→ Displayしない
```

P1-05時点ではDisplay Gateを成立させない。

Displayは後続処理の責務とする。

## 14.4 Failure時Cleanup

Render API内でFailureが発生しても、原則としてRender API自身はMailItemをCloseしない。

CallerはFailure Resultを受け取った後、可能な範囲で既存 `CloseWithoutSave()` を呼び出す。

概念：

```text
Render Failure
↓
Failure Result
↓
Caller
↓
CloseWithoutSave
```

## 14.5 Explorer

Cold Start時にOutlook Adapterが起動したExplorerはP1-02の方針を維持する。

Render Failureを理由に既存Explorerまたはツールが起動した通常Outlook ExplorerをCloseしない。

---

# 15. P1 / P4 / P5 Scope Boundary

## 15.1 P1-05

P1-05はRender Architectureの最小成立を担当する。

```text
FormattedValues Boundary
Subject Renderer基本形
SetSubject
Word Range Body Render基本形
Case Insensitive
全出現箇所置換基本形
Render後Snapshot再取得
```

## 15.2 P4

P4はRaw Inputから正式Formatted Valueを生成する。

```text
Raw Input
↓
Input Validator
↓
Value Formatter
↓
Formatted Value
```

P4責務：

```text
Required=True / False
Date Parse
4桁年
Date Output 6 Format
曜日生成
Select Current Active Option
Text
Select String
Optional空欄 → ""
```

P1-05はこれらをProduction実装しない。

## 15.3 P5

P5はP1のRender経路を正式Mail Generationへ統合・最終化する。

```text
Current VariableDefinition / OptionMaster
↓
Input Validator
↓
Current OFT
↓
Current Template Scan
↓
Configuration Validator
↓
Value Formatter
↓
Subject Renderer
↓
Word Range Body Render
↓
Subject / BodyText再取得
↓
Unresolved Checker
↓
0件のみDisplay
```

P5で最終化する主なRender事項：

```text
Range.Find全出現検索Loop
空文字置換時のRange処理
特殊文字時のRange.Text処理
Subject全置換実装の最終化
Optional空欄との統合
Date Formatとの統合
Current Data Guardとの統合
Requirements保証範囲の正式確認
```

## 15.4 P1-06 / P1-07

P1-05直後のWalking Skeleton残Unitとの境界は以下とする。

```text
P1-05
Minimal Render
↓
P1-06
Minimal Unresolved Check
↓
P1-07
Display / E2E Integration
```

P1-05でUnresolved判定やDisplayを先回り実装しない。

---

# 16. P1-05 Production Flow

P1-05完了時の最小Production Flowを以下とする。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
Local OFT Path
↓
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
Private mMailItem
↓
ReadSubject
+
ReadBodyText
↓
Snapshot Boundary
↓
ScanTemplate
↓
ValidVariables / InvalidCandidates
↓
P1 FormattedValues Fixture
↓
modSubjectRenderer.RenderSubject
↓
renderedSubject
↓
modOutlookAdapter.SetSubject
↓
modOutlookAdapter.ReplaceBodyVariables
↓
ReadSubject
+
ReadBodyText
↓
Render後Snapshot
↓
CloseWithoutSave
```

P1-05では、

```text
Unresolved Checker
DisplayMail
```

へは接続しない。

---

# 17. Smoke Test

## 17.1 目的

Production Boundary上で、

```text
FormattedValues
↓
Subject Render
+
Word Range Body Render
↓
Render後Snapshot
```

が成立することを確認する。

Smoke Test側でOutlook / Word Renderロジックを独自実装しない。

## 17.2 推奨Test Module

```text
modP1_05MinimalRenderSmokeTest
```

推奨Entry Point：

```vb
TestP105MinimalRenderCore
TestP105MinimalRenderIntegration
```

必要に応じて統合Entry Pointを追加してよい。

```vb
TestP105MinimalRender
```

## 17.3 Core Test対象

Core Testは `modSubjectRenderer` を対象とする。

推奨Case：

```text
C1 Baseline Subject Render
C2 Case Insensitive / All Occurrences
C3 Missing Value Leaves Token
C4 Extra Value No-op
C5 Empty Subject
```

### C1 Baseline Subject Render

Input：

```text
Subject:
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}

FormattedValues:
ModelName → ABC123
GateDate  → 2026/09/30
```

Expected：

```text
【ABC123】ゲート審査 2026/09/30 / ABC123
```

### C2 Case Insensitive / All Occurrences

Input：

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

Formatted Value：

```text
ModelName → ABC123
```

Expected：

```text
ABC123
ABC123
ABC123
```

### C3 Missing Value Leaves Token

Input：

```text
{{ModelName}} / {{GateDate}}
```

FormattedValues：

```text
ModelName → ABC123
```

Expected：

```text
ABC123 / {{GateDate}}
```

Result：

```text
RenderSubject = PASS
```

Missing Value検出をRenderer Errorとしない。

### C4 Extra Value No-op

Input：

```text
{{ModelName}}
```

FormattedValues：

```text
ModelName  → ABC123
GateDate   → 2026/09/30
Department → 品質部
```

Expected：

```text
ABC123
```

Extra ValueがあってもSuccess。

### C5 Empty Subject

Input：

```text
vbNullString
```

Expected：

```text
RenderSubject = PASS
renderedSubject = vbNullString
```

## 17.4 Integration Test Fixture

Baseline OFTを使用する。

FormattedValues Fixture：

```text
ModelName   = ABC123
GateDate    = 2026/09/30
Department  = 品質部
Comment     = 確認お願いします
```

これはP1-05 Verification用の既Format済みString Fixtureであり、P4 Value FormatterのTest Evidenceではない。

## 17.5 Integration Test手順

概念手順：

```text
1. Settings.TemplatePath取得
2. ResolveWorkbookRelativePath
3. CreateMailFromTemplate
4. ReadSubject
5. ReadBodyText
6. ScanTemplate
7. ValidVariables / InvalidCandidates Evidence取得
8. P1 FormattedValues Fixture生成
9. RenderSubject
10. SetSubject
11. ReplaceBodyVariables
12. ReadSubject
13. ReadBodyText
14. Render後Subject / BodyText確認
15. CloseWithoutSave
```

## 17.6 Subject Expected

Baseline Subject：

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

Expected：

```text
【ABC123】ゲート審査 2026/09/30 / ABC123
```

## 17.7 Body Expected

Baseline Body中の少なくとも以下が置換される。

```text
{{ModelName}}
{{MODELNAME}}
{{GateDate}}
{{Department}}
{{department}}
{{Comment}}
```

Expected Value：

```text
ModelName   → ABC123
GateDate    → 2026/09/30
Department  → 品質部
Comment     → 確認お願いします
```

Case違いを含む全出現箇所が同一値へ置換される。

## 17.8 P1-05でPASS扱いしないもの

以下はP1-05 Smoke Test結果だけで正式PASS扱いしない。

```text
Date Format 6種類成立
Select Validation成立
Optional空欄成立
特殊文字保証成立
基本書式8項目Formal PASS
Unresolved = 0 Formal PASS
Display Gate成立
Formal MVP Test PASS
```

これらは対応Phase / Formal Testへ残す。

---

# 18. Negative Verification

## Case N1：formattedValues = Nothing

手順：

```text
RenderSubject
formattedValues = Nothing
```

Expected：

```text
Failure
renderedSubject = vbNullString
未処理Runtime Errorなし
```

同様に `ReplaceBodyVariables(Nothing)` もFailureとして扱う。

## Case N2：Active MailItemなし / SetSubject

手順：

```text
SetSubject
```

Expected：

```text
Failure
未処理Runtime Errorなし
```

## Case N3：Active MailItemなし / ReplaceBodyVariables

手順：

```text
ReplaceBodyVariables
```

Expected：

```text
Failure
未処理Runtime Errorなし
```

## Case N4：Missing Formatted Value

SubjectまたはBodyにVariableが存在するがFormattedValuesにKeyがない状態を作る。

Expected：

```text
Renderer自体はFailureにしない
対象Variableは残る
```

P1-05ではUnresolved Errorへ変換しない。

後続P1-06の責務とする。

## Case N5：Body Find 0件

FormattedValuesにSubject専用Variable相当のKeyを含め、Bodyには存在しない状態とする。

Expected：

```text
ReplaceBodyVariables = PASS
Find 0件をRender Errorとしない
```

## Case N6：WordEditor取得失敗

安全に再現可能な既存Test経路がある場合のみ確認する。

Expected：

```text
Failure
未処理Runtime Errorなし
OutlookError等の既存Resultへ変換
```

P1-05のためだけにFailure Injection用Production APIを追加しない。

再現困難な場合はStatic ReviewでError Pathを確認し、P6で最終化する。

---

# 19. Regression

P1-05実装後、P1-01～P1-04で成立済みの主要経路に明らかなRegressionがないことを確認する。

## P1-01

```text
ResolveWorkbookRelativePath
Local OFT Path生成
CreateMailFromTemplate
CloseWithoutSave
```

## P1-02

```text
Warm Start Readiness
Cold Start Readiness
WordEditor Access
Unexpected Scan MailItem Display = NONE
Draft Residue = NONE
Inspector Residue = NONE
```

## P1-03

```text
ReadSubject
ReadBodyText
同一Active MailItem
Snapshot Boundary
COM Object非公開
```

## P1-04

```text
ScanTemplate
ValidVariables
InvalidCandidates
Case Insensitive統合
Production VariableName Hard Coding = NONE
```

P1-05 Regressionでは各過去Unitの全Test Caseを再実施することを必須としない。

変更影響に応じて必要最小限のRegressionを実行する。

---

# 20. Compile Evidence

P1-05 Verificationでは可能な限り以下を明示的に記録する。

```text
Debug
↓
Compile VBAProject
↓
PASS
```

Runtime実行成功だけに依存せず、明示的なCompile操作Evidenceを残すことを推奨する。

Compile不可の場合、P1-05をPASS扱いしない。

---

# 21. Evidence

最低限以下を記録する。

```text
Workbook
Execution Baseline
Compile Result
Resolved OFT Path
Outlook Start State
CreateMailFromTemplate Result

Pre-Render:
Subject Snapshot
BodyText Length
ScanTemplate Result
ValidVariables
InvalidCandidates

FormattedValues:
Key一覧
Value一覧または確認可能な要約

Subject Render:
RenderSubject Result
Rendered Subject
SetSubject Result

Body Render:
ReplaceBodyVariables Result

Post-Render:
ReadSubject Result
Rendered Subject Snapshot
ReadBodyText Result
Rendered BodyText Length
主要置換箇所確認

Lifecycle:
Unexpected MailItem Display
CloseWithoutSave Result

Regression:
P1-01～P1-04の必要確認結果
```

BodyText全文をEvidenceへ必須出力しない。

Variable置換結果を確認できる必要箇所のみ診断出力してよい。

---

# 22. Production Hard Coding Rule

Walking Skeleton成立のためにProduction Codeへ以下をHard Codingしてはならない。

```text
ModelName
GateDate
Department
Comment
ABC123
品質部
2026/09/30
```

Production CodeはDictionaryのKey / Valueを汎用的に処理する。

一方、Smoke Test Fixture側ではBaseline Test Dataを明示的に生成してよい。

```text
Test Fixture Hard Coding
= Allowed

Production Variable Hard Coding
= Prohibited
```

---

# 23. Implementation Detail Rule

P1-05実装時に決定してよい事項：

```text
Private Helper名
Subject置換Helperの有無
Dictionary列挙方法
Range.Find用Local Rangeの作成方法
Range更新Loopの基本形
Word定数のLocal Const化
Error Target文字列
Diagnostic Debug.Print内容
Smoke Test Module内部構成
```

ただし、Implementation Detailによって以下を変更してはならない。

```text
Case Insensitive
全出現箇所置換
Subject / Body責務分離
Word Object ModelのAdapter内封じ込め
Body全文再設定禁止
Unresolved Checker独立
P4 Value Formatter責務
P5 Current Data Guard責務
```

これらを変更する必要が生じた場合、Implementation側だけで解釈変更せずFinding Ruleへ従う。

---

# 24. Finding Classification

P1-05実装・Verification中のFindingは以下で分類する。

## 24.1 Implementation Defect

既存Specificationどおりに実装されていない。

例：

```text
Case Insensitiveにならない
Subject複数Occurrenceの一部しか置換されない
Body Range Loopが終了しない
SetSubjectがActive MailItemへ反映されない
```

→ Production Patch候補。

## 24.2 Design Finding

Requirementは明確だが、既存Designの責務・Interfaceだけでは実装判断不能または矛盾する。

→ Design Reviewへ戻す。

## 24.3 Requirement Gap

利用者から見た新しい振る舞いを決める必要がある。

→ Requirementsへ戻す。

## 24.4 Technical Finding

既存Technical Decisionの成立性に重大な不確実性が生じる。

例：

```text
Word Range方式ではBaseline OFTの基本置換そのものが成立しない
```

→ Technical Spike要否を再判定する。

単なる実装BugをTechnical Spikeへ昇格しない。

---

# 25. P1-05 Verification Gate

以下をすべて満たした場合、P1-05をPASS候補とする。

```text
VBA Compile PASS

Subject Renderer Core:
PASS

Case Insensitive:
PASS

Subject All Occurrences:
PASS

SetSubject:
PASS

Word Range Body Render:
PASS

Body Case Insensitive:
PASS

Body All Occurrences:
PASS

Render後 ReadSubject:
PASS

Render後 ReadBodyText:
PASS

Production Variable Hard Coding:
NONE

COM Object Leakage:
NONE

Unexpected Final MailItem Display:
NONE

CloseWithoutSave:
PASS

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

# 26. Completion Criteria

P1-05 Completion条件：

```text
Approved Unit Specification
+
VBA Compile PASS
+
Subject Render Core PASS
+
Subject Integration PASS
+
Body Word Range Render PASS
+
Render後Snapshot PASS
+
Lifecycle PASS
+
必要Regression PASS
+
Production Patch Review PASS
+
Blocking Finding = 0
```

成立後：

```text
P1-05 Minimal Render
PASS / COMPLETE
```

と判定可能となる。

ただし、

```text
P1-05 COMPLETE
≠
CP-P1 ESTABLISHED
```

である。

P1 Walking Skeleton全体のExitには、Render後のUnresolved CheckおよびDisplayまでの最小E2E経路が別途必要となる。

---

# 27. P1 Phase Boundary

P1-05が提供する静的なdownstream Boundaryは以下とする。

```text
Existing Active MailItem
+
FormattedValues
↓
Subject / Body Render
↓
Render後 Subject / BodyText Snapshot
```

後続Core LogicはこのSnapshotを入力として未置換Variableを確認できる。

P1-05自身はUnresolved Checkの結果、Display判定、最終MailItem Displayを持たない。

---

# 28. Traceability Summary

| P1-05対象 | Requirement / Design / Plan |
|---|---|
| Subject Case Insensitive | FR-VAR-004 / FR-RENDER-SUB-001 |
| Subject全出現置換 | FR-VAR-003 / FR-RENDER-SUB-001 |
| Body Case Insensitive | FR-VAR-004 / FR-RENDER-BODY-001 |
| Body全出現置換 | FR-VAR-003 / FR-RENDER-BODY-001 |
| Word Range方式 | DOC-MVP-DES §22.3 / D16 |
| Body全文再設定禁止 | DOC-MVP-DES §22.3 |
| Formatted Values | DOC-MVP-DES §21 / §22 |
| Subject Renderer | DOC-MVP-DES §22.2 |
| Outlook Adapter Body Render | DOC-MVP-DES §13 / §22.3 |
| Render後再Read | DOC-MVP-DES §12.2 / §23 |
| Unresolved独立 | DOC-MVP-DES §23 |
| P1 Minimal Render | DOC-MVP-IMPL P1 Walking Skeleton |
| P4 Validation / Formatting分離 | DOC-MVP-IMPL P4 |
| P5 Render最終化 | DOC-MVP-IMPL P5 |

Formal Test Definitionは `DOC-MVP-TESTSPEC` の以下へ接続する。

```text
MTS-REN-001
MTS-REN-002
```

ただしP1-05 Smoke TestはFormal MVP Test Resultではない。

---

# 29. Document Impact

本仕様作成時点のImpact判定：

```text
Requirement Change:
NONE

Design Change:
NONE

Test Specification Change:
NONE

Implementation Plan Change:
NONE

Baseline Change:
NONE

Technical Spike Reopen:
NOT REQUIRED
```

本仕様は既存BL-MVP-003の範囲内でP1 Walking SkeletonのImplementation Detailを具体化する。

---

# 30. Approval前Review観点

本v0.1 DraftをProduction実装のSource of Truthとする前に、最低限以下をConsistency Reviewする。

```text
DOC-MVP-REQ Conflict
DOC-MVP-DES Conflict
DOC-MVP-TESTSPEC Conflict
DOC-MVP-IMPL Conflict
P1-03 Boundary Conflict
P1-04 Boundary Conflict
P1 / P4 / P5 Scope Conflict
Error Model Conflict
Lifecycle Conflict
Requirement Gap
Design Finding
Technical Spike Reopen要否
```

Consistency ReviewでBlocking Conflictがないことを確認後、本v0.1をApproved化する。

---

# 31. Draft判定

本書作成時点：

```text
P1-05 Minimal Render 実施仕様 v0.1

Status:
Draft

Boundary Confirmation:
COMPLETE

Current Execution Baseline:
BL-MVP-003

Production Implementation:
NOT STARTED

Consistency Review:
NOT YET EXECUTED
```
