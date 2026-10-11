# P1-05 Minimal Render 実施仕様 v0.1 Consistency Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-05 Minimal Render 実施仕様 v0.1 Consistency Review |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Consistency Review |
| Review対象 | `P1-05 Minimal Render 実施仕様 v0.1` |
| Current Execution Baseline | BL-MVP-003 |
| Review Result | **PASS WITH CORRECTIONS** |
| Blocking Finding | **NONE** |
| Semantic Conflict | **NONE** |
| Requirement Gap | **NONE（ただし1件の記述をRequirement Gap化防止のため修正要）** |
| Design Finding | **NONE** |
| Technical Spike Reopen | **NOT REQUIRED** |
| Baseline Change | **NOT REQUIRED** |

---

# 2. Review目的

`P1-05 Minimal Render 実施仕様 v0.1` が、Current Approved Baselineおよび成立済みP1 Production Boundaryと整合していることを確認する。

Review対象観点：

```text
Requirement Conflict
Design Conflict
Test Specification Conflict
Implementation Plan Conflict
P1-03 Production Boundary Conflict
P1-04 Production Boundary Conflict
Scope Expansion
Traceability Break
Lifecycle Conflict
Error Model Conflict
Governance Conflict
Requirement Gap
Design Finding
Technical Spike Reopen要否
```

---

# 3. Review Source

本Reviewでは以下をSource of Truth /成立済みBoundaryとして使用した。

```text
DOC-MVP-REQ
- MVP Requirements v0.1.9

DOC-MVP-DES
- MVP Design v0.1.9

DOC-MVP-TESTSPEC
- MVP Test Specification v0.1.5

DOC-MVP-IMPL
- Implementation Plan v0.3

P1-03
- P1-03 Template Snapshot Boundary 実施仕様 v0.1
- Approved

P1-04
- P1-04 Minimal Template Scanner
- PASS / COMPLETE
- Production API / Result Boundary / Scope / Error Semantics
```

Execution Baseline：

```text
BL-MVP-003
├─ DOC-MVP-REQ v0.1.9
├─ DOC-MVP-DES v0.1.9
├─ DOC-TS-A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC v0.1.5
```

---

# 4. Executive Result

総合判定：

```text
Semantic Conflict:
NONE

Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P1-03 Boundary Conflict:
NONE

P1-04 Boundary Conflict:
NONE

Blocking Scope Expansion:
NONE

Traceability Break:
NONE

Technical Spike Reopen:
NOT REQUIRED
```

ただし、Approval前に以下4件の局所Correctionを実施する。

```text
CR-P1-05-001
Technical Specification内のProject State記述削除

CR-P1-05-002
Replacement Value内 {{...}} の意味をP1-05で新規定義しないよう修正

CR-P1-05-003
P1基本COM Release Boundaryを明示

CR-P1-05-004
P1-04 InvalidCandidates契約をIntegration Smoke Testへ明示
```

4件はいずれもP1-05仕様書内で解決可能であり、上位文書Revisionは不要である。

---

# 5. Requirement Consistency Review

## 5.1 Subject置換

Requirement：

```text
FR-VAR-003
- 同一Variableの全出現箇所を同一値で置換

FR-VAR-004
- VariableName比較はCase Insensitive

FR-RENDER-SUB-001
- Subject内Variableを入力・選択値へ置換
- 全出現箇所置換
- Case Insensitive
```

P1-05：

```text
RenderSubject()
- Plain Text Subject
- Case Insensitive
- 全出現箇所置換
```

判定：

```text
CONSISTENT
```

## 5.2 Body置換

Requirement：

```text
FR-RENDER-BODY-001
- 全出現箇所置換
- Case Insensitive

FR-RENDER-BODY-002
- 意図した文字列として反映
- Variable置換部分以外の代表的基本書式を維持
```

P1-05：

```text
ReplaceBodyVariables()
- Word Range.Find
- MatchCase = False
- Range.Text
- 全出現箇所置換
- Body全文再設定禁止
```

判定：

```text
CONSISTENT
```

## 5.3 未置換Variable

Requirement：

```text
FR-UNRESOLVED-001 / 002
- 未置換が1件以上残れば生成停止
- Variable一覧通知
```

DesignではUnresolved CheckerをRenderから独立させている。

P1-05：

```text
Missing Formatted Value
→ tokenを残す
→ Renderer自体はFailureにしない
→ P1-06 Unresolved Checkerへ委譲
```

判定：

```text
CONSISTENT
```

P1-05が未置換判定をRender内部へ取り込んでいないため、Design責務分離を維持している。

## 5.4 Requirement Gap判定

既存Requirementに不足しているためP1-05を実装不能となる論点は確認されなかった。

```text
Requirement Gap:
NONE
```

ただしCR-P1-05-002を修正せず残すと、Replacement Value内 `{{...}}` の扱いをImplementationだけで新規仕様化する可能性があるため、Approval前に記述修正する。

---

# 6. Design Consistency Review

## 6.1 Formatted Values Boundary

Design：

```text
Raw Input
↓
Value Formatter
↓
Formatted Values
├─ Subject Renderer
└─ Outlook Adapter / Body Rendering
```

P1-05：

```text
P1では既Format済みString Fixtureを供給
Production Value FormatterはP4へ残す
```

判定：

```text
CONSISTENT
```

P1-05はValue FormatterのProduction責務を先取りしていない。

## 6.2 Subject Renderer

Design：

```text
Subject Renderer
- Plain Text
- Formatted Value
- Case Insensitive
- 全出現置換
- 完成SubjectをOutlook Adapter経由で設定
```

P1-05：

```text
modSubjectRenderer.RenderSubject
↓
renderedSubject
↓
modOutlookAdapter.SetSubject
```

判定：

```text
CONSISTENT
```

## 6.3 Body Rendering

Design：

```text
Outlook Adapter
↓
WordEditor
↓
Word Document
↓
Range.Find / Range.Text
```

P1-05は同一構造を採用し、Body全文をPlain Text / HTMLとして再設定しない。

判定：

```text
CONSISTENT
```

## 6.4 COM Boundary

Design：

```text
MailItem
Inspector
WordEditor
Word Document
Word Range
Explorer
```

はOutlook Adapter内部に閉じ込める。

P1-05もCOM Object Public Exposureを禁止している。

判定：

```text
CONSISTENT
```

## 6.5 Lifecycle

Design：

```text
生成用MailItem
↓
Render
↓
再Read
↓
Unresolved Check
↓
Display
```

P1-05：

```text
Render API
- Closeしない
- Displayしない
- 同一Active MailItemを維持
- Render後ReadSubject / ReadBodyText
```

判定：

```text
CONSISTENT
```

---

# 7. Test Specification Consistency Review

## 7.1 MTS-REN-001 Subject置換

Expected：

```text
【ABC123】ゲート審査 2026/09/30 / ABC123
```

大小文字違いを含む全出現箇所を置換。

P1-05 Core / Integration Testは同じ期待結果を採用している。

判定：

```text
CONSISTENT
```

## 7.2 MTS-REN-002 Body置換

Expected：

```text
全Variable
全出現箇所
Word Range.Find / Range.Text
```

P1-05の基本Body Render Verificationは一致する。

判定：

```text
CONSISTENT
```

## 7.3 MTS-REN-003 Optional空欄

P1-05はOptional判定 / Value FormatterをProduction実装しない。

P4 / P5へ残している。

判定：

```text
CONSISTENT
```

## 7.4 MTS-REN-004 Date 6 Format

P1-05の `2026/09/30` は、

```text
既にFormat済みのP1 Test Fixture
```

として扱い、Date Format成立Evidenceとしない。

判定：

```text
CONSISTENT
```

## 7.5 MTS-REN-005 / 006

P1-05は、

```text
特殊文字Formal PASS
基本書式8項目Formal PASS
```

をCompletion条件にしていない。

P5 / Formal MVP Testへ残す。

判定：

```text
CONSISTENT
```

Formal Test Scopeの先取りは確認されなかった。

---

# 8. Implementation Plan Consistency Review

## 8.1 P1 Walking Skeleton

Implementation Plan P1：

```text
Subject / BodyText
↓
Template Scanner
↓
Input Value
↓
Subject Render
↓
Word Range Body Render
↓
再Read
↓
Unresolved
↓
Display
```

P1-05：

```text
FormattedValues Fixture
↓
Subject Render
↓
Word Range Body Render
↓
再Read
```

判定：

```text
CONSISTENT
```

P1-05はP1全体ではなくRender Unitだけを担当している。

## 8.2 P4 Boundary

Implementation Plan P4：

```text
Raw Input
↓
Validation
↓
Formatted Value
```

P1-05はRaw Input / Validation / Production Value FormatterをOut of Scopeとしている。

判定：

```text
CONSISTENT
```

## 8.3 P5 Boundary

Implementation Plan P5：

```text
Current Data Guard
Current OFT Scan
Configuration Validator
Value Formatter
Subject Renderer
Body Render
Unresolved Checker
Display
```

P1-05は正式統合・Current Data Guard・Render最終化をP5へ残す。

判定：

```text
CONSISTENT
```

## 8.4 Range.Find Loop

Implementation Plan：

```text
Range.Find Loop
P1基本形 / P5最終化
```

P1-05：

```text
基本Loopのみ
正式な空文字 / 特殊文字 /完成版LoopはP5
```

判定：

```text
CONSISTENT
```

## 8.5 COM Release

Implementation Plan：

```text
COM Release
P1基本形 / P6最終化
```

P1-05はOwnership / Private Local Boundaryは記載しているが、`ReplaceBodyVariables()` で新たに扱うWord Range等のLocal COM Referenceについて、P1基本Release責務が明示不足である。

判定：

```text
SEMANTIC CONFLICT:
NONE

COMPLETENESS CORRECTION:
REQUIRED
```

→ CR-P1-05-003。

---

# 9. P1-03 Boundary Consistency Review

P1-03 Approved Boundary：

```text
ReadSubject()
ReadBodyText()
↓
Subject As String
BodyText As String

COM Object:
Adapter外へ公開禁止

Reader:
MailItemをCloseしない

Current状態:
必要なら再Read
```

P1-05：

```text
同一Active MailItemを継続利用
↓
SetSubject / ReplaceBodyVariables
↓
ReadSubject / ReadBodyText再実行
```

判定：

```text
CONSISTENT
```

特に以下が一致している。

```text
古いSnapshotをCurrent状態として更新しない
Render後は再Readする
COM ObjectをCoreへ渡さない
API自身へClose責務を混在させない
```

P1-03 Production Boundaryへの破壊的変更はない。

---

# 10. P1-04 Boundary Consistency Review

P1-04成立済みBoundary：

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Result：

```text
Scripting.Dictionary
├─ ValidVariables → Collection
└─ InvalidCandidates → Collection
```

P1-04主要Rule：

```text
Subject → BodyText順Scan
ValidVariables Case Insensitive Dedup
First Detection Order保持
First Detected Spelling保持

InvalidCandidates:
元 {{...}} 表記保持

Invalid Candidate存在
≠ Scanner Technical Failure

Scan Success
+
InvalidCandidates.Count > 0
が成立し得る
```

P1-05はScanner API / Result Model / Regex / Syntax Validationを変更していない。

判定：

```text
PRODUCTION BOUNDARY:
CONSISTENT
```

ただしP1-05 Integration Smoke Testは、

```text
ScanTemplate = Success
```

だけでRenderへ進むと、P1-04の

```text
Success + InvalidCandidates > 0
```

を見落とす可能性がある。

P1-05の正常Fixture前提として、

```text
InvalidCandidates.Count = 0
```

を明示確認してからRenderへ進むべきである。

これはProduction Scannerの意味変更ではない。

→ CR-P1-05-004。

---

# 11. Correction Findings

## CR-P1-05-001 — Technical Specification内Project State

### 分類

```text
Governance Correction
Severity: Non-Blocking
Approval前Correction: REQUIRED
Semantic Impact: NONE
```

### 現状

P1-05 §31に以下のProject Stateが記載されている。

```text
Production Implementation:
NOT STARTED

Consistency Review:
NOT YET EXECUTED
```

これはTechnical Specification自身の技術的真実ではなく、現在のProject Stateである。

P1-03 Approved仕様では、

```text
Project Control上の進捗更新は本Technical Specificationでは管理しない
```

というGovernanceへ既に整合済みである。

### Correction

`# 31. Draft判定` を削除する。

文書のLifecycle状態は§1の、

```text
Status | Draft
```

のみで管理する。

Approval時は、

```text
Status | Approved
```

へ変更する。

実装開始状況 / Consistency Review実施状況はProject Control / Context Handoffへ保持する。

---

## CR-P1-05-002 — Replacement Value内 `{{...}}` の意味

### 分類

```text
Scope / Requirement-Gap Prevention
Severity: Non-Blocking
Approval前Correction: REQUIRED
Baseline Conflict: NONE
```

### 現状

P1-05 §11.6に、

```text
P1-05ではFormatted Value内の特殊構文を再帰的に展開する機能を追加しない。
```

とある。

Baseline Requirement / Design / Test Specificationでは、

```text
replacement value自身に {{VariableName}} 形式が含まれる場合
```

の意味論を明示していない。

この状態でImplementation Specificationだけが、

```text
再帰展開する / しない
```

を決めると、利用者から見た新しい挙動をImplementationが先行決定する可能性がある。

### Correction

当該記述を以下へ置換する。

```text
Formatted Value内に `{{...}}` 形式の文字列を含むケースについて、
その文字列を追加Variableとして解釈するかどうかの利用者向け意味論は、
本P1-05で新規定義しない。

P1-05 Smoke Test Fixtureでは当該ケースを使用しない。

Production実装中に当該ケースの挙動確定が必要となった場合は、
Implementation Detailとして暗黙決定せず、Requirement Gap要否を判定する。
```

これによりP1-05は既存Baselineの範囲を超えない。

---

## CR-P1-05-003 — P1基本COM Release Boundary

### 分類

```text
Implementation Completeness Correction
Severity: Non-Blocking
Approval前Correction: RECOMMENDED / Consistency上は反映推奨
Semantic Impact: NONE
```

### 根拠

Implementation Plan：

```text
COM Release
P1基本形 / P6最終化
```

P1-05ではBody Renderにより新たに以下を扱う。

```text
Inspector
Word Document
Word Range
Find
```

Ownership表ではPrivate / Localまで定義済みだが、P1基本Release責務をもう一段明確にした方がよい。

### Correction

LifecycleまたはReplaceBodyVariables節へ以下を追加する。

```text
ReplaceBodyVariables() 内で取得したLocal COM Referenceは、
処理成功 / Failureの双方でFunction呼出しを越えて保持しない。

P1では既存Adapterの基本COM Cleanup Patternへ従う。

具体的なRelease Codeおよび例外経路の最終化はP6で行う。
```

Verificationへ以下を追加する。

```text
Body Render後に不要なInspector / Range Referenceを
Adapter Stateとして保持しないこと
```

---

## CR-P1-05-004 — P1-04 InvalidCandidates Contract

### 分類

```text
Cross-Unit Verification Correction
Severity: Non-Blocking
Approval前Correction: REQUIRED
Semantic Impact: NONE
```

### 根拠

P1-04では、

```text
Invalid Candidate存在
≠ Scanner Technical Failure
```

であり、

```text
ScanTemplate.Success = True
InvalidCandidates.Count > 0
```

が成立し得る。

P1-05 Integration Smoke Testでは正常なBaseline OFTを前提とするため、Render開始前にScanner成立性だけでなくFixture健全性を確認する必要がある。

### Correction

Integration Test Step 7付近へ以下を追加する。

```text
ScanTemplate Success確認
↓
InvalidCandidates.Count = 0確認
↓
Expected ValidVariables確認
↓
P1 FormattedValues Fixture生成
```

InvalidCandidatesが1件以上の場合：

```text
P1-05 Render Failure
```

とは分類しない。

```text
Test Fixture / Precondition Finding
```

としてRender Verificationを開始しない。

---

# 12. No-Conflict Items

以下についてConflictは確認されなかった。

```text
FormattedValues = Render入力Boundary
Subject RendererとSetSubjectの分離
SetSubjectがVariable置換を持たない
Body物理置換がOutlook Adapter責務
Body全文再設定禁止
HTML Encode不使用
Case Insensitive
全出現箇所置換
Missing ValueをRenderer Errorにしない
Extra ValueをErrorにしない
Unresolved Checker独立
Render後再Read
同一Active MailItem維持
Render APIでDisplayしない
Render APIでCloseしない
P4 Validation / Formatting分離
P5 Current Data Guard /正式Render統合分離
Production Variable Hard Coding禁止
専用WordEditor Adapter / DTO等の先回り追加禁止
```

---

# 13. Traceability Review

| P1-05要素 | Source | 判定 |
|---|---|---|
| Subject Case Insensitive | FR-VAR-004 / FR-RENDER-SUB-001 | PASS |
| Subject全出現置換 | FR-VAR-003 / FR-RENDER-SUB-001 | PASS |
| Body Case Insensitive | FR-VAR-004 / FR-RENDER-BODY-001 | PASS |
| Body全出現置換 | FR-VAR-003 / FR-RENDER-BODY-001 | PASS |
| Word Range方式 | DOC-MVP-DES §22.3 / D16 | PASS |
| Body全文再設定禁止 | DOC-MVP-DES §22.3 | PASS |
| Formatted Values Boundary | DOC-MVP-DES §21 / §22 | PASS |
| Subject Renderer責務 | DOC-MVP-DES §22.2 | PASS |
| Outlook Adapter Body Render | DOC-MVP-DES §13 / §22.3 | PASS |
| Render後Snapshot | DOC-MVP-DES §12.2 / §23 / P1-03 | PASS |
| Unresolved独立 | DOC-MVP-DES §23 | PASS |
| P1 Minimal Render | DOC-MVP-IMPL P1 | PASS |
| P4 Formatting分離 | DOC-MVP-IMPL P4 | PASS |
| P5 Render最終化 | DOC-MVP-IMPL P5 | PASS |
| MTS-REN-001 | DOC-MVP-TESTSPEC | PASS |
| MTS-REN-002 | DOC-MVP-TESTSPEC | PASS |
| P1-04 Scanner Boundary | P1-04 | PASS + CR-P1-05-004 |

```text
Traceability Break:
NONE
```

---

# 14. Baseline / Document Impact

Review結果：

```text
DOC-MVP-REQ Revision:
NOT REQUIRED

DOC-MVP-DES Revision:
NOT REQUIRED

DOC-MVP-TESTSPEC Revision:
NOT REQUIRED

DOC-MVP-IMPL Revision:
NOT REQUIRED

P1-03 Revision:
NOT REQUIRED

P1-04 Revision:
NOT REQUIRED

BL-MVP-003 Update:
NOT REQUIRED

Technical Spike Reopen:
NOT REQUIRED
```

必要な修正はすべて、

```text
P1-05 Minimal Render 実施仕様 v0.1
```

の局所Correctionで完結する。

---

# 15. Approval Recommendation

現状：

```text
Consistency Review:
PASS WITH CORRECTIONS

Blocking Finding:
NONE
```

Approval前に以下を反映する。

```text
CR-P1-05-001 REQUIRED
CR-P1-05-002 REQUIRED
CR-P1-05-003 RECOMMENDED
CR-P1-05-004 REQUIRED
```

推奨手順：

```text
P1-05 v0.1 Draft
↓
4件Correction反映
↓
Consistency Review反映概要追加
↓
Status = Approved
↓
Production Implementation開始
```

CR-P1-05-003も合わせて反映すれば、P1 Implementation PlanとのCOM Lifecycle責務がより明確になるため、4件すべてを反映することを推奨する。

---

# 16. Final Review Decision

```text
P1-05 Minimal Render 実施仕様 v0.1

Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P1-03 Boundary Conflict:
NONE

P1-04 Boundary Conflict:
NONE

Semantic Conflict:
NONE

Traceability Break:
NONE

Blocking Finding:
NONE

Required Local Corrections:
3

Recommended Local Correction:
1

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Review Result:
PASS WITH CORRECTIONS
```
