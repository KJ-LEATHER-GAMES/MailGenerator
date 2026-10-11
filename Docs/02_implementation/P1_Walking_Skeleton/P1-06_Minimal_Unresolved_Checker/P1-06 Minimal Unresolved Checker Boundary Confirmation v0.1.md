# P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-06 Minimal Unresolved Checker Boundary Confirmation |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Boundary Confirmation |
| Status | Confirmed |
| Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-06 Minimal Unresolved Checker |
| Primary Production Module | `modUnresolvedChecker` |
| 前提Implementation Unit | P1-05 Minimal Render = PASS / COMPLETE |
| Boundary Result | **CONFIRMED** |

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

### v0.1 作成概要

P1-05で成立したRender後のSubject / BodyText Snapshot Boundaryを前提として、P1 Walking Skeletonにおける最小Unresolved Checkerの責務境界を確認した。

本Boundary Confirmationでは、以下を確定する。

1. P1-06はRender後のSubject / BodyText文字列Snapshotのみを入力とする
2. P1-06はCore LogicとしてOutlook / Word COM Objectへ依存しない
3. 残存する有効な `{{VariableName}}` 形式を未置換Variableとして検出する
4. VariableNameはCase Insensitiveで重複統合する
5. Unresolved Checkerは件数だけでなくVariable一覧を返却可能な論理Resultを持つ
6. 未置換Variableが1件以上存在する場合はFail扱いとする
7. P1-06自身はMailItem Display、Close、UI表示を行わない
8. Scanner成立性とUnresolved Check成立性を独立して扱う
9. P1-05で保留したFormatted Value内 `{{...}}` の再帰展開は行わない
10. 一方、Render後Snapshot上に残存した有効Tokenは、その発生元を追跡せずUnresolved Checkerの検出対象とする
11. P1-07でDisplay / Fail Closed / E2E Orchestrationを接続する
12. P5 / P6の正式生成経路・Error / Lifecycle最終化を先回り実装しない

本確認はBL-MVP-003で承認済みのRequirement / Design / Test DefinitionをImplementation Boundaryへ具体化するものであり、新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Boundary Confirmation**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-06の目的は、P1-05までに生成可能となったRender後Snapshotに対して、

> **未置換Variableが残存しているかを、Production Architecture上の独立したCore Logicとして判定できる境界**

を確定することである。

P1-06の基本Flowは以下とする。

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
P1-06
modUnresolvedChecker
        ↓
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

P1-06では、この判定結果をMailItem LifecycleやUIへ最終接続することまでは目的としない。

---

# 3. Baseline上の根拠

## 3.1 Requirement Boundary

`DOC-MVP-REQ` では未置換Variableについて以下が確定済みである。

```text
FR-UNRESOLVED-001

SubjectまたはBodyに
{{VariableName}}
形式の未置換変数が1件でも残っている場合、
メール生成を中止する。
```

また、VariableName比較にはFR-VAR-004のCase Insensitive Ruleを適用する。

さらに、

```text
FR-UNRESOLVED-002

未置換変数が存在する場合、
対象変数を一覧表示する。
```

ことが要求されている。

Acceptance Criteriaでは、

```text
AC-018

未置換変数が1つでも残っている場合、
Outlookメールを表示しない。
```

とされている。

したがって、P1-06には最低限以下が必要である。

```text
0件 / 1件以上の判定
+
残存Variable一覧
+
Case Insensitive統合
```

一方、実際の一覧UI表示およびMailItem非表示制御はP1-06単体のCore Logic責務ではない。

---

## 3.2 Design Boundary

`DOC-MVP-DES` ではUnresolved CheckerをCore Logicとして独立Component化している。

```text
Core Logic
├─ Template Scanner
├─ Configuration Validator
├─ Input Validator
├─ Value Formatter
├─ Subject Renderer
└─ Unresolved Checker
```

Unresolved CheckerはRender処理内部へ埋め込まず、Render後段の独立処理とする。

```text
Render
↓
Unresolved Checker
↓
UnresolvedCheckResult
├─ 0件 → Outlook Display
└─ 1件以上 → Error Result → UI一覧表示
```

評価対象は以下である。

```text
Subject
BodyText
```

Bodyについては、Word Document / Rangeを直接検索せず、Render後にOutlook Adapterから再取得した表示文字列ベースの `BodyText` を使用する。

したがってP1-06は以下へ依存しない。

```text
Outlook.Application
MailItem
Inspector
WordEditor
Word Document
Word Range
```

---

## 3.3 Test Specification Boundary

`DOC-MVP-TESTSPEC` では以下4件がUnresolved Checkの正式Testとして定義されている。

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

P1-06単体で直接成立させる範囲は主に以下である。

```text
MTS-UNR-001
→ 未置換0件判定

MTS-UNR-003
→ Variable一覧 / Case Insensitive重複統合のCore部分

MTS-UNR-004 Test B
→ Render後Unresolved Checkの独立判定
```

`MTS-UNR-002` のうち、

```text
MailItemをDisplayしない
保存せずClose
```

はApplication / Lifecycleとの接続を必要とするため、P1-07でE2E統合する。

P1-06では、

```text
{{GateDate}} を検出
↓
Failure / Unresolved Resultを返却可能
```

までを成立させる。

---

## 3.4 Implementation Plan Boundary

`DOC-MVP-IMPL` のP1 Walking Skeletonでは、

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

を最小E2E経路としている。

P1-05までに、

```text
Word Range Body Render
↓
Subject / BodyText再取得
```

までが成立済みである。

したがってP1-06は、

```text
Render後Snapshot
↓
Unresolved Check
```

を担当する。

`Display` との統合はP1-07の責務とする。

---

# 4. 前提Implementation Boundary

## 4.1 P1-05 Output Boundary

P1-05完了時点で以下がProduction Boundary上で成立している。

```text
modSubjectRenderer.RenderSubject
↓
modOutlookAdapter.SetSubject

+

modOutlookAdapter.ReplaceBodyVariables
↓
Word Range Body Render

        ↓

ReadSubject()
+
ReadBodyText()
        ↓
Render後Snapshot
```

P1-06はこのRender後Snapshotをそのまま入力として使用する。

古いRender前Snapshotは使用しない。

---

## 4.2 Inputは文字列Snapshotのみ

P1-06の入力Boundaryは以下とする。

```text
subjectText As String
bodyText As String
```

概念：

```text
Render後 Subject
+
Render後 BodyText
↓
modUnresolvedChecker
```

以下をInputとしない。

```text
MailItem
Inspector
WordEditor
Word Document
Word Range
FormattedValues
VariableDefinition
OptionMaster
TemplateScanResult
ValidVariables
InvalidCandidates
```

この境界により、P1-06はRender結果そのものの完全性だけを評価する。

---

# 5. P1-06 Responsibility Boundary

## 5.1 主責務

P1-06の主責務は以下とする。

```text
Render後Subject / BodyText
↓
有効な {{VariableName}} 残存検索
↓
Case Insensitive統合
↓
UnresolvedCheckResult生成
```

最低限、論理的に以下を返却可能とする。

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

---

## 5.2 非責務

P1-06は以下を行わない。

```text
Variable置換
再Render
再帰Render
FormattedValues参照
VariableDefinition照合
OptionMaster照合
Input Validation
Configuration Validation
Template Sync
Template構成の妥当性判定
Invalid Candidate Configuration Error判定
Current Data Guard
MailItem生成
MailItem.Display
MailItem.Close
保存
送信
MsgBox
最終UI文言生成
```

P1-06は、

> **何が残っているかを判定するCore Logic**

に限定する。

---

# 6. Unresolved Candidate Boundary

## 6.1 検出対象

P1-06の検出対象はBaseline Requirementで定義済みの、

```text
{{VariableName}}
```

形式とする。

VariableNameはFR-VAR-002の有効なVariableName形式を前提とする。

概念上：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

を満たすVariableNameを含むTokenをUnresolved Candidateとして扱う。

例：

```text
{{GateDate}}
{{ModelName}}
{{MODEL_1}}
```

---

## 6.2 Invalid Candidateとの責任分離

以下のような命名規則違反記法はTemplate Scanner / Configuration Error側の責務である。

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

P1-06はTemplate Scannerの代替ではない。

通常の正式Mail Generation経路では、Render前にCurrent Template Scan / Configuration Validationを通過していることを前提とする。

P1 Walking SkeletonのP1-06 Verificationでも、必要に応じてP1-04 / P1-05で成立済みの正常Preconditionを利用する。

---

# 7. Case Insensitive Boundary

VariableName比較はFR-VAR-004に従いCase Insensitiveとする。

例：

```text
{{GateDate}}
{{gatedate}}
{{GATEDATE}}
```

が複数残っていても、

```text
Variables[]
→ GateDate相当 1件
```

として重複統合する。

P1-06では、

```text
同一Variableの残存箇所数
```

をユーザー通知件数として返さない。

必要なのは、

```text
残存している論理Variable一覧
```

である。

---

# 8. Variables[] Boundary

## 8.1 必須情報

`Variables[]` は少なくともVariableNameを保持可能とする。

概念：

```text
Variables[]
├─ GateDate
├─ Department
└─ ModelName
```

---

## 8.2 Location情報

P1-06では以下を必須Outputとしない。

```text
Subject / Body Location
出現回数
文字位置
Range位置
```

これらはFR-UNRESOLVED-001 / 002およびDesign §23の成立に必要ではない。

P1-06のためにLocation Resultを先回り追加しない。

---

## 8.3 表示順

`Variables[]` のUser-facing表示順はBaseline Requirement / Designで固定されていない。

したがってBoundary Confirmationでは、

```text
Alphabetical
First Appearance
Subject優先
VariableDefinition SortOrder
```

のいずれも新規仕様として固定しない。

P1-06ではCase Insensitiveに一意なVariable集合を生成できることを必須とする。

具体的なCarrier / 列挙順はImplementation Detailとして実施仕様で最小化する。

---

# 9. Formatted Value内 `{{...}}` の扱い

## 9.1 P1-05で保留した事項

P1-05ではFormatted Value内に `{{...}}` が含まれる場合について、

> それを追加Variableとして解釈して再帰展開するか

という意味論を新規定義しなかった。

この方針を維持する。

---

## 9.2 P1-06での境界

P1-06はFormattedValuesをInputとして受け取らない。

P1-06が評価するのは、

```text
Render後の最終Subject Snapshot
Render後の最終BodyText Snapshot
```

のみである。

したがって、Render後Snapshot上に有効な、

```text
{{VariableName}}
```

形式が残っている場合、その文字列が、

```text
元Template由来
Formatted Value由来
その他の上流処理由来
```

のどれであるかをP1-06は追跡しない。

最終Snapshot上の有効TokenとしてUnresolved Candidateへ含める。

---

## 9.3 再帰Renderとの区別

以下は行わない。

```text
Formatted Value:
"{{Department}}"

↓ P1-06

Departmentの値を再検索して置換
```

P1-06はRendererではない。

P1-06の動作は、

```text
Rendered Snapshot:
"{{Department}}"

↓ P1-06

Unresolved = True
Variables[] = Department
```

までである。

これは、

```text
再帰展開する
```

という意味ではなく、

```text
最終生成結果に有効なVariable Tokenが残存している
```

ことを検出するSafety Checkである。

---

## 9.4 Requirement Gap判定

Baseline Design §23は、

```text
Render後Subject / BodyText
+
{{VariableName}} 形式の残存
```

を直接判定対象としている。

またUnresolved CheckerのInputにはToken発生元を識別するProvenance情報が定義されていない。

したがってP1-06では、

```text
最終Snapshot上に存在する有効Tokenを発生元によらず検出する
```

ことを既存Designの具体化として扱う。

判定：

```text
Requirement Gap:
NONE
```

ただし、将来、

```text
ユーザーが入力値として literal な {{VariableName}} を
最終メール本文へそのまま出力できなければならない
```

という利用者Requirementが追加された場合はSemantic Changeとなるため、P1-06 Implementation Detailだけで例外化しない。

---

# 10. Template Scannerとの責任分離

## 10.1 Scannerの責務

P1-04 Template ScannerはRender前Template Snapshotについて、

```text
ValidVariables
InvalidCandidates
Location
```

等のTemplate構成を評価する。

---

## 10.2 Unresolved Checkerの責務

P1-06はRender後Snapshotについて、

```text
有効Token残存
↓
Unresolved Variable一覧
```

を評価する。

概念：

```text
Template Scanner
= Render前Template構成の成立性

Unresolved Checker
= Render後生成結果の完全性
```

---

## 10.3 MTS-UNR-004との整合

`MTS-UNR-004` では、

```text
Test A
Render前Scanner成立性

Test B
Render後Unresolved 0件
```

を独立して判定することが要求されている。

したがって、

```text
Unresolved = 0
```

だけを理由として、

```text
Scannerも正しく動作した
```

とは判定しない。

逆に、

```text
Scanner = PASS
```

だけを理由として、

```text
Render後Unresolved = 0
```

とも判定しない。

---

## 10.4 Production依存境界

P1-06 Public Boundaryは `TemplateScanResult` をInputとしない。

```text
Subject / BodyText
↓
Unresolved Checker
```

のみで成立させる。

`modTemplateScanner.ScanTemplate()` をP1-06の意味上の前提Resultとして渡す構成は採用しない。

Token抽出の具体的なPrivate実装方法や既存ロジックの重複回避方法は実施仕様で判断してよいが、Scanner ResultとUnresolved Resultの意味を統合してはならない。

---

# 11. Result Boundary

## 11.1 論理Result

P1-06ではDesignに従い、論理的に以下を保持する。

```text
UnresolvedCheckResult
├─ HasUnresolved As Boolean
└─ Variables[]
```

具体的なVBA CarrierはBoundary Confirmationでは固定しない。

候補：

```text
Late Bound Scripting.Dictionary
Collection
軽量Class
Object-based Result
```

P1 Walking Skeletonのためだけに過剰なDomain Modelを追加しない。

---

## 11.2 0件

Expected：

```text
HasUnresolved = False
Variables.Count = 0
```

P1-06 Checkerとしては正常完了とする。

後続P1-07はこの結果を受けてDisplay Gateへ進める。

---

## 11.3 1件以上

Expected：

```text
HasUnresolved = True
Variables.Count >= 1
```

Designに従い、

```text
Warning
+
処理継続
```

とはしない。

後続処理から見てFail Closed可能なResultを返す。

ただしP1-06自身はMailItemをDisplay / Closeしない。

---

# 12. COperationResult Boundary

P1-06は既存の `COperationResult` / `CErrorInfo` 体系を使用する。

新しいResult基盤は追加しない。

概念上：

```text
Check処理自体が成立
+
Unresolved 0件
→ Success

Check処理自体が成立
+
Unresolved 1件以上
→ Failure / Error Result
  + UnresolvedCheckResult保持

予期しないChecker Runtime Error
→ Failure / Error Result
```

Designでは未置換1件以上を `Error Result` として扱うため、Unresolvedありを単なる `Success=True + HasUnresolved=True` の通知だけで終わらせない。

一方で、未置換Variable一覧は後続UIへ渡す必要があるため、Failure時でも検出済みVariablesを失わないBoundaryとする。

---

# 13. Error Type Boundary

`DOC-MVP-DES` の既存Error分類は以下である。

```text
ConfigurationError
TemplateError
InputValidationError
RenderError
OutlookError
UnexpectedError
```

P1-06 Boundary Confirmationでは新しい、

```text
UnresolvedError
```

ErrorTypeを追加しない。

未置換検出を既存ErrorTypeのどれへMappingするかは、

```text
P1-06 実施仕様 v0.1
+
Consistency Review
```

で既存Result実装との整合を確認して確定する。

候補としてはRender後の完全性Errorであるため `RenderError` が最も近いが、本Boundary Confirmationでは新しいError分類Decisionを追加しない。

予期しないCore Logic Runtime Errorは既存Error設計に従ってResultへ変換する。

---

# 14. Empty String Boundary

以下はUnresolved Checker自体のError条件としない。

```text
Subject = vbNullString
BodyText = vbNullString
```

空文字列中に有効Tokenが存在しない場合、

```text
Unresolved = 0
```

として評価可能である。

Subject / Bodyの空欄可否やMail Template妥当性をP1-06で新規定義しない。

---

# 15. Outlook / Word COM Boundary

P1-06 Production Codeは以下へ直接依存しない。

```text
Outlook.Application
Outlook.MailItem
Outlook.Inspector
Word.Document
Word.Range
```

禁止するProduction Boundary例：

```vb
CheckUnresolved(ByVal mailItem As Object, ...)
CheckUnresolved(ByVal wordDocument As Object, ...)
```

P1-06はPure Coreに近い文字列処理として成立させる。

これによりCore TestをOutlook非依存で実行可能とする。

---

# 16. MailItem Lifecycle Boundary

P1-06はMailItem Lifecycle Ownershipを持たない。

以下を行わない。

```text
CreateMailFromTemplate
DisplayMail
CloseWithoutSave
Send
Save
```

Unresolvedありの場合の正式Lifecycleは後続Application Orchestrationで処理する。

P1 Walking SkeletonではP1-07で、

```text
Unresolvedあり
↓
Displayしない
↓
CloseWithoutSave
```

を接続する。

---

# 17. UI Boundary

P1-06はCore Logicであり、直接UIを表示しない。

禁止：

```text
MsgBox
UserForm Error表示
Outlook Display
```

P1-06は、

```text
Variables[]
+
Error / Operation Result
```

を返却可能な状態までを担当する。

FR-UNRESOLVED-002のUser-facing一覧表示はP1-07以降のUI / Application責務とする。

---

# 18. P1-06 Verification Boundary

## 18.1 Core Verification

最低限以下をP1-06 Core Verification対象とする。

### C1：Unresolved 0件

```text
Subject:
【ABC123】ゲート審査 2026/09/30

Body:
対象機種：ABC123
開催日：2026/09/30
```

Expected：

```text
HasUnresolved = False
Variables.Count = 0
```

### C2：Subject 1件

```text
Subject:
【ABC123】ゲート審査 {{GateDate}}

Body:
未置換なし
```

Expected：

```text
HasUnresolved = True
Variables = GateDate
```

### C3：Body 1件

```text
Subject:
未置換なし

Body:
開催日：{{GateDate}}
```

Expected：

```text
HasUnresolved = True
Variables = GateDate
```

### C4：Subject / Body同一Variable

```text
Subject:
{{GateDate}}

Body:
{{GateDate}}
```

Expected：

```text
Variables.Count = 1
```

### C5：Case Insensitive統合

```text
{{GateDate}}
{{gatedate}}
{{GATEDATE}}
```

Expected：

```text
Variables.Count = 1
```

### C6：複数Variable

```text
{{GateDate}}
{{Department}}
{{ModelName}}
```

Expected：

```text
Variables.Count = 3
```

### C7：Empty String

```text
Subject = vbNullString
BodyText = vbNullString
```

Expected：

```text
HasUnresolved = False
Variables.Count = 0
```

### C8：Formatted Value由来相当の有効Token

最終Snapshotのみを直接Fixtureとして与える。

```text
BodyText:
備考：{{Department}}
```

Expected：

```text
HasUnresolved = True
Variables = Department
```

このTestは再帰Renderを要求しない。

---

## 18.2 Integration Verification

P1-05 Production Flowへ接続する。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject / ReadBodyText
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
ReadSubject / ReadBodyText
↓
P1-06 CheckUnresolved
```

正常系Expected：

```text
Unresolved 0件
```

P1-06 Integration Testでは最終MailItem Displayを必須としない。

---

## 18.3 Missing Value Integration

P1-05で成立済みの、

```text
Missing Formatted Value
→ Tokenを残す
```

Boundaryを利用する。

例：

```text
GateDateをFormattedValuesから除外
↓
Render
↓
{{GateDate}} 残存
↓
Render後Snapshot取得
↓
CheckUnresolved
```

Expected：

```text
HasUnresolved = True
Variables = GateDate
```

これにより、

```text
RendererはTokenを残す
↓
Unresolved Checkerが検出する
```

という責務分離を確認する。

---

# 19. P1-06でFormal確認しないもの

P1-06 Completionだけでは以下の正式保証を行わない。

```text
MailItem Display停止のE2E
Error時CloseWithoutSaveのE2E
User-facing未置換一覧UI
正式Error Message
正式Error Target / Error Code
Current OFT Guard
Current VariableDefinition Guard
Current OptionMaster Guard
Optional空欄正式経路
Date 6 Format正式経路
Body特殊文字正式保証
Body基本書式8項目正式保証
COM Error最終化
Lifecycle最終化
Formal MVP Test
```

これらは責務に応じてP1-07 / P5 / P6 / Formal MVP Testへ残す。

---

# 20. P1-07 Boundary

P1-06完了後に接続可能となる境界は以下とする。

```text
Render後 Subject / BodyText
↓
P1-06 Unresolved Checker
↓
UnresolvedCheckResult
↓
P1-07 Application / E2E Integration
↓
HasUnresolved?
├─ Yes
│   ├─ Displayしない
│   └─ CloseWithoutSave
│
└─ No
    ↓
DisplayMail
```

P1-06ではこのOrchestrationを先回り実装しない。

---

# 21. P5 / P6 Boundary

## 21.1 P5

P5ではP1で成立したUnresolved Checkerを正式Mail Generation Flowへ統合する。

```text
Current Data Guard
↓
Input Validation
↓
Value Formatting
↓
Render
↓
Render後Snapshot
↓
Unresolved Checker
↓
0件のみDisplay
```

P1-06でCurrent Data Guardを先回り実装しない。

## 21.2 P6

P6ではError / Safety / Lifecycleを最終化する。

P1-06では、

```text
Fault Injection専用Production API
複雑なError Code体系
全Runtime Error網羅
```

を追加しない。

---

# 22. Production API Shape

Boundary Confirmation時点ではProduction APIの最終Signatureを固定しない。

ただし責務上、概念的には以下を満たす必要がある。

```vb
CheckUnresolved( _
    subjectText As String, _
    bodyText As String, _
    ByRef unresolvedResult As ... _
) As COperationResult
```

重要なのはSignature名ではなく以下である。

```text
Input
= Render後 Subject / BodyText

Output
= HasUnresolved + Variables[]

Operation
= COperationResult
```

具体的な、

```text
Function名
ByVal / ByRef詳細
Result Carrier型
Dictionary / Collection / Class
Private Helper構成
RegExp利用方法
```

はP1-06実施仕様で確定する。

---

# 23. Production Hard Coding Rule

Production Codeへ以下をHard Codingしてはならない。

```text
ModelName
GateDate
Department
Comment
```

Unresolved Checkerは任意の有効VariableNameを汎用的に処理する。

一方、Verification FixtureではBaseline Test Dataを使用してよい。

---

# 24. Requirement / Design / Test Gap Assessment

## 24.1 Requirement Gap

確認結果：

```text
NONE
```

理由：

- 未置換Token形式が定義済み
- Subject / Bodyが対象と定義済み
- Case Insensitiveが定義済み
- 1件以上で生成中止が定義済み
- Variable一覧通知が定義済み
- Render後Snapshotを評価するDesignが定義済み

## 24.2 Design Finding

確認結果：

```text
NONE
```

Design §23で、

```text
独立Unresolved Checker
Subject / BodyText
UnresolvedCheckResult
Case Insensitive重複統合
1件以上でFail
```

が定義済みである。

## 24.3 Test Specification Gap

確認結果：

```text
NONE
```

`MTS-UNR-001` ～ `MTS-UNR-004` が定義済みであり、P1-06 / P1-07への責務分割が可能である。

## 24.4 Technical Spike Reopen

確認結果：

```text
NOT REQUIRED
```

P1-06は文字列ベースCore Logicであり、新しいOutlook / Word技術成立性Riskを追加しない。

## 24.5 Baseline Change

確認結果：

```text
NOT REQUIRED
```

P1-06 BoundaryはBL-MVP-003のRequirement / Design / Test Definitionを変更しない。

---

# 25. Boundary Decision一覧

| ID | Decision | Result |
|---|---|---|
| BND-P1-06-001 | P1-06 InputはRender後Subject / BodyText Snapshot | CONFIRMED |
| BND-P1-06-002 | `modUnresolvedChecker` はCore Logic | CONFIRMED |
| BND-P1-06-003 | Outlook / Word COM非依存 | CONFIRMED |
| BND-P1-06-004 | 有効な `{{VariableName}}` 残存を検出 | CONFIRMED |
| BND-P1-06-005 | VariableNameはCase Insensitive | CONFIRMED |
| BND-P1-06-006 | 同一VariableはCase Insensitiveに1件へ統合 | CONFIRMED |
| BND-P1-06-007 | Logical ResultはHasUnresolved + Variables[] | CONFIRMED |
| BND-P1-06-008 | Unresolved 1件以上はFail Closed可能なResult | CONFIRMED |
| BND-P1-06-009 | Scanner ResultをP1-06 Inputとしない | CONFIRMED |
| BND-P1-06-010 | Invalid Candidate判定はScanner / Configuration責務 | CONFIRMED |
| BND-P1-06-011 | Formatted Valueの再帰Renderは行わない | CONFIRMED |
| BND-P1-06-012 | 最終Snapshot上の有効Tokenは発生元を問わず検出 | CONFIRMED |
| BND-P1-06-013 | P1-06自身はDisplay / Close / UIを行わない | CONFIRMED |
| BND-P1-06-014 | Variables Location / Count-by-locationはP1必須Outputにしない | CONFIRMED |
| BND-P1-06-015 | Variables表示順はBoundaryで新規仕様化しない | CONFIRMED |
| BND-P1-06-016 | 新ErrorTypeを追加しない | CONFIRMED |
| BND-P1-06-017 | Public API最終Signature / Carrierは実施仕様で確定 | CONFIRMED |
| BND-P1-06-018 | P1-07がDisplay / Fail Closed E2Eを接続 | CONFIRMED |
| BND-P1-06-019 | Requirement Gapなし | CONFIRMED |
| BND-P1-06-020 | Technical Spike Reopen不要 / Baseline変更不要 | CONFIRMED |

---

# 26. P1-06 実施仕様へ引き継ぐImplementation Detail

次の `P1-06 Minimal Unresolved Checker 実施仕様 v0.1` では、以下を具体化する。

```text
1. Production Public API名 / Signature
2. UnresolvedCheckResultのVBA Carrier
3. Case Insensitive Dictionary / Collection構成
4. Token抽出方式
5. VBScript.RegExp利用有無
6. Output初期化規則
7. Unresolvedあり時のCOperationResult構成
8. Existing ErrorTypeへのMapping
9. Error Target
10. Runtime Error変換
11. Core Test Module
12. Integration Test Module
13. P1-05 Regression範囲
14. Evidence形式
15. Completion Criteria
```

これらはImplementation Detailとして確定してよい。

ただし以下を変更してはならない。

```text
Render後Snapshot評価
Subject / BodyText対象
Case Insensitive
Variables[]返却
1件以上でFail
Core Logic / COM非依存
Scannerとの責務分離
Display / Close非責務
再帰Render禁止
```

---

# 27. Boundary Confirmation Result

最終判定：

```text
P1-06 Minimal Unresolved Checker
Boundary Confirmation:

CONFIRMED
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

P1-05 Boundary Conflict:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

P1-06は、

```text
Render後 Subject / BodyText Snapshot
↓
有効な {{VariableName}} 残存検出
↓
Case Insensitive重複統合
↓
HasUnresolved + Variables[]
```

という独立Core Logic Boundaryとして実施仕様化可能である。
