# P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Cross-document Consistency Review |
| Review対象 | `P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Draft` |
| Execution Baseline | BL-MVP-003 |
| Review Result | **PASS WITH CORRECTIONS** |
| Blocking Finding | **NONE** |

### Review Source

- `DOC-MVP-REQ` — MVP Requirements v0.1.9
- `DOC-MVP-DES` — MVP Design v0.1.9
- `DOC-MVP-TESTSPEC` — MVP Test Specification v0.1.5
- `DOC-MVP-IMPL` — Implementation Plan v0.3
- `DOC-TS-A` — Technical Spike A v0.4 CLOSED / PASS
- `P1-05 Minimal Render 実施仕様 v0.1`
- `P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1`

---

# 2. Review目的

P1-06 Draftで具体化したImplementation Detailが、BL-MVP-003で承認済みのRequirement / Design / Test DefinitionおよびP1-05 / P1-06 Boundaryと整合していることを確認する。

主なReview観点：

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

# 3. Review Summary

確認結果：

```text
Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
CORRECTION REQUIRED
→ Error Type Mappingの固定範囲のみ

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

総合判定：

```text
PASS WITH CORRECTIONS
```

CorrectionはImplementation Detail / Governance表現に限定される。

Requirement / Design / Test Specification / BaselineのSemantic Changeは不要。

---

# 4. Requirement Review

## 4.1 未置換検出

DOC-MVP-REQでは以下が確定済み。

```text
SubjectまたはBodyに
{{VariableName}}
形式の未置換変数が1件でも残っている場合、
メール生成を中止する。
```

Draftは以下を実装対象としており整合する。

```text
Subject
+
BodyText
↓
Valid Token Scan
↓
HasUnresolved
+
Variables
```

判定：

```text
PASS
```

---

## 4.2 Case Insensitive

Requirementでは未置換変数チェックにもCase Insensitive Ruleを適用する。

Draftは、

```text
Late Bound Scripting.Dictionary
CompareMode = vbTextCompare
```

によるCase Insensitive重複統合を採用している。

判定：

```text
PASS
```

---

## 4.3 一覧通知

Requirementでは未置換Variable一覧を利用者へ表示する必要がある。

DraftではP1-06が、

```text
Variables As Collection
```

を生成し、UI表示自体をP1-07以降へ分離している。

Core LogicとUI責務の分離として整合する。

判定：

```text
PASS
```

---

# 5. Design Review

## 5.1 独立Checker

Design §23ではUnresolved CheckerをRender後段の独立処理とする。

Draftも、

```text
Render後Snapshot
↓
modUnresolvedChecker
```

とし、Rendererへ判定を埋め込まない。

判定：

```text
PASS
```

---

## 5.2 Input Boundary

Designでは評価対象を、

```text
Subject
BodyText
```

とする。

Draftも同一Boundaryであり、MailItem / Word Document / Rangeを入力としない。

判定：

```text
PASS
```

---

## 5.3 UnresolvedCheckResult

Designの概念構造：

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

Draft：

```text
unresolvedResult
├─ HasUnresolved
└─ Variables As Collection
```

専用Classを追加せずDictionary + Collectionで実装することは、Designの軽量構造方針およびYAGNIに整合する。

判定：

```text
PASS
```

---

## 5.4 Failure Semantics

Designでは、

```text
1件以上
→ Error Result
→ UI一覧表示
```

とされ、警告のみで継続しない。

Draftは `COperationResult.Success = False` を返しつつ、`unresolvedResult` を保持する。

判定：

```text
PASS
```

ただしErrorTypeの具体MappingについてCorrectionを要する。

---

# 6. Test Specification Review

## 6.1 MTS-UNR-001

Draft Core C1 / Normal Integrationで、

```text
HasUnresolved = False
Variables.Count = 0
```

を確認する。

MTS-UNR-001の「Render完了後、Valid Variable形式の残存0件」と整合する。

判定：

```text
PASS
```

---

## 6.2 MTS-UNR-002

MTS-UNR-002は、

```text
{{GateDate}} 検出
MailItem Displayなし
保存せずClose
```

を要求する。

DraftはP1-06で `{{GateDate}}` 検出までを担当し、Display / CloseをP1-07へ分離する。

P1-05 → P1-06 → P1-07という既存Unit境界に一致する。

判定：

```text
PASS
```

---

## 6.3 MTS-UNR-003

Draft Core C4 / C5 / C6で、

```text
Case Insensitive重複統合
Variables一覧
```

を確認する。

判定：

```text
PASS
```

---

## 6.4 MTS-UNR-004 / TF-A-002

Test Specificationは、

```text
Render前Scanner成立性
+
Render後Unresolved 0件
```

を独立判定する。

Draftでは、

```text
ScanTemplate結果をCheckUnresolved Inputへ渡さない
```

かつIntegration Testで、

```text
Scanner Precondition確認
↓
Render
↓
Unresolved Checkを独立確認
```

としている。

TF-A-002のFalse Positive再発防止方針に整合する。

判定：

```text
PASS
```

---

# 7. Implementation Plan Review

## 7.1 P1 Walking Skeleton

Implementation PlanではP1に、

```text
modUnresolvedChecker 最小Happy Path
```

を含め、

```text
Render
↓
Unresolved Check
↓
Display
```

を最終E2E経路とする。

DraftはP1-06でUnresolved Checkのみを実装し、Display接続をP1-07へ分離している。

判定：

```text
PASS
```

---

## 7.2 P5 Boundary

Implementation PlanではP5で正式Mail Generationへ統合・最終化する。

DraftはCurrent Data Guard / Value Formatter /正式生成経路をP1-06へ先回り実装しない。

判定：

```text
PASS
```

---

## 7.3 P6 Error / Safety Boundary

Implementation Plan P6ではError / Safety Scopeとして、

```text
Render Error
Unresolved Error
```

を別項目として扱い、Error Code体系・User Message・Fail Closedを最終化する。

Draftでは当初、

```text
Unresolved >= 1
→ ErrorType = RenderError
```

を正式Mappingとして固定していた。

この固定はP6の「Unresolved Error最終化」責務を狭めるため、Correctionが必要。

判定：

```text
PASS WITH CORRECTION
```

---

# 8. P1-05 Boundary Review

P1-05では、

```text
Missing Formatted Value
→ Tokenを残す
```

とし、

```text
Unresolved Checker
Display
```

を後続Unitへ明示的に残している。

DraftのMissing Value Integration：

```text
RendererがTokenを残す
↓
P1-06が検出する
```

は責務分離に一致する。

判定：

```text
PASS
```

---

# 9. P1-06 Boundary Confirmation Review

Boundary Confirmationでは以下を確定済み。

```text
Render後Snapshotを入力
Subject / BodyText対象
Case Insensitive
HasUnresolved + Variables
Scanner独立
COM非依存
再帰Render禁止
Display / Close / UI非責務
新ErrorTypeを追加しない
ErrorType Mappingは実施仕様で既存体系との整合確認
```

Draftは基本的にこれへConformしている。

ただしErrorType MappingはP6責務を尊重する形へCorrectionする。

判定：

```text
PASS WITH CORRECTION
```

---

# 10. Correction

## CR-P1-06-001 — Unresolved Error Type MappingのP6責務保全

### Draft

```text
Unresolved >= 1
→ ErrorType = RenderError
```

を正式Mappingとして固定。

### Finding

DOC-MVP-DESのErrorType一覧には `UnresolvedError` は存在しない一方、DOC-MVP-IMPL P6では、

```text
Render Error
Unresolved Error
```

を別のError / Safety Scopeとして扱い、Error体系の最終化をP6責務としている。

したがってP1-06で `Unresolved = RenderError` を最終分類として固定すると、P6責務を先取りする。

### Correction

P1-06では以下までを正式Contractとする。

```text
Unresolved 1件以上
→ COperationResult.Success = False
→ unresolvedResult.HasUnresolved = True
→ unresolvedResult.Variables保持
→ Target = UnresolvedVariables
→ 最低限Message保持
```

現行 `CreateFailureResult()` がErrorTypeを必須とするため既存ErrorTypeが必要な場合、

```text
RenderError
```

を **P1 Interim Mapping** として使用してよい。

ただし：

```text
RenderError = Unresolvedの正式最終分類
```

とは定義しない。

P1-07はErrorType文字列へ依存せず、

```text
COperationResult.Success
+
unresolvedResult.HasUnresolved
```

でFail Closedを判断可能なBoundaryとする。

正式なUnresolved Error分類 / Error Code / User-facing MessageはP6で最終化する。

### Impact

```text
Requirement Impact:
NONE

Design Impact:
NONE

Test Specification Impact:
NONE

Baseline Impact:
NONE
```

---

## CR-P1-06-002 — Review Source名の正規化

### Draft

Consistency Review対象に、

```text
P1-04 Minimal Template Scanner Boundary
P1-05 Minimal Render Boundary
P1-06 Boundary Confirmation
```

という略称を使用。

### Correction

実在する正式文書名へ整理する。

```text
P1-04 Minimal Template Scanner 実施仕様 v0.1
P1-05 Minimal Render 実施仕様 v0.1
P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1
```

### Impact

```text
Editorial / Governance only
Semantic Impact:
NONE
```

---

## CR-P1-06-003 — Draft状態記述のApproved版整理

### Draft

以下を保持。

```text
Status = Draft
Draft Consistency Self-Check
Draft Result
Proposed ...
```

### Correction

Consistency Review完了後のTechnical Specificationとして、

```text
Status = Approved
Consistency Review結果
Approved Result
```

へ更新する。

Current Project State / Next Actionは追加しない。

### Impact

```text
Editorial / Governance only
Semantic Impact:
NONE
```

---

# 11. Correction反映後判定

Correction反映後：

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

---

# 12. Final Review Result

```text
Cross-document Consistency Review:

PASS WITH CORRECTIONS
↓
CR-P1-06-001 APPLIED
CR-P1-06-002 APPLIED
CR-P1-06-003 APPLIED
↓
CORRECTIONS APPLIED

Final Result:
PASS

Blocking Finding:
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

`P1-06 Minimal Unresolved Checker 実施仕様 v0.1` はCorrection反映後、Approved化可能と判定する。
