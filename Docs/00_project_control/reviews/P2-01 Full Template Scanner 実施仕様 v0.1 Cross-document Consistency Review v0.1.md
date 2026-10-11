# P2-01 Full Template Scanner 実施仕様 v0.1 Cross-document Consistency Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-01 Full Template Scanner 実施仕様 v0.1 Cross-document Consistency Review |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Cross-document Consistency Review |
| Execution Baseline | BL-MVP-003 |
| Review Target | `P2-01 Full Template Scanner 実施仕様 v0.1` |
| Review Result | **PASS WITH CORRECTIONS** |
| Corrections Applied | **YES** |
| Approval Result | **APPROVED** |

### Review Sources

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `AI協働開発 文書管理・Baseline運用ルール v0.1`
- `P1-04 Minimal Template Scanner Completion Record v0.1`
- `P2 Scan / Sync Boundary Confirmation v0.1`
- `P2 Implementation Unit Decomposition Decision v0.1`

---

# 2. Review Objective

P2-01仕様がCurrent Execution BaselineおよびP1-04で確定したScanner Contractと整合し、P2-02以降の責務を先回りせずProduction実装可能な状態か確認する。

主確認観点：

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

# 3. Executive Result

Review結果：

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

P2 Boundary Conflict:
NONE

P2 Unit Decomposition Conflict:
NONE

Blocking Scope Expansion:
NONE

Blocking Traceability Break:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Governance Conflict:
CORRECTION REQUIRED

Result:
PASS WITH CORRECTIONS
```

Correction 3件をApproved前に反映した。

---

# 4. Requirement Consistency

## 4.1 Variable Syntax / Identity

P2-01は以下を維持する。

```text
{{VariableName}}
^[A-Za-z][A-Za-z0-9_]*$
Case Insensitive Identity
```

Requirement Conflictなし。

## 4.2 Scan Target

Scanner InputをSubject / BodyTextに限定し、To / CC / BCCを対象外としている。

FR-SCAN-001と整合。

## 4.3 Location

`Subject / Body / Both`を返すLocationsを追加する。

FR-SCAN-002と整合。

## 4.4 Invalid Candidate

命名規則違反CandidateをValidVariablesへ混入させず、InvalidCandidatesへ元表記で保持する。

FR-SCAN-003 / FR-VAR-005と整合。

Scanner Technical SuccessとConfiguration Errorとしての後続停止を分離しており、P1-04 Contractとも整合。

---

# 5. Design Consistency

## 5.1 Two-stage Scan

```text
Candidate Scan
↓
VariableName Validation
↓
Valid / Invalid
```

を維持している。

Design §14.1～14.3と整合。

## 5.2 String Snapshot Boundary

ScannerはSubject / BodyTextのみを受け取り、Word Document / Outlook COMを保持しない。

Design §14.6およびP1成立済みArchitectureと整合。

## 5.3 TemplateScanResult

```text
ValidVariables
InvalidCandidates
Locations
```

を返す。

Design §14.6と整合。

## 5.4 Locations Carrier

DesignはLocationsの具体的VBA Carrierを固定していない。

P2 BoundaryでもCarrier構造はP2-01 Unit Specificationで確定する方針としている。

したがって、

```text
Late Bound Scripting.Dictionary
CompareMode = vbTextCompare
VariableName → Subject / Body / Both
```

の採用はImplementation Detailとして許容範囲。

専用Classを追加しない判断にDesign Conflictなし。

---

# 6. Test Specification Consistency

## 6.1 MTS-SCAN-001

Baseline OFTから、

```text
ModelName
GateDate
Department
Comment
```

を抽出するIntegration Verificationを持つ。

整合。

## 6.2 MTS-SCAN-002

Baseline Expected：

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

を仕様へ保持。

整合。

## 6.3 MTS-SCAN-003

ReviewでClarificationが必要と判定した。

Test SpecificationのExpectedには、

```text
Case Insensitive
+
既存VariableDefinitionの正式表記保持
```

の双方が含まれる。

一方、P2-01のScannerは意図的にVariableDefinition非依存である。

したがってP2-01単独で`MTS-SCAN-003 Full PASS`を主張すると責務不整合になる。

Correction：

```text
P2-01
→ MTS-SCAN-003 Scanner Core Portion

P2-02
→ Existing VariableDefinition Canonical Casing

MTS-SCAN-003 Full Expected
→ P2-01 + P2-02 / MTS-SYNC-007で成立
```

Semantic ChangeではなくTraceability Clarification。

## 6.4 MTS-SCAN-004

InvalidCandidatesの検出・元記述保持・ValidVariables非混入を維持。

整合。

FR-VAR-005全体の処理停止はP2-01単独完了扱いしない。

## 6.5 MTS-SCAN-005

Public APIがSubject / BodyTextのみを受け取ること、およびTest用OFTのTo / CC / BCC VariableがResultへ出ないIntegration Variantを定義。

整合。

---

# 7. Implementation Plan Consistency

DOC-MVP-IMPLのP2 Scanner Scope：

```text
Candidate抽出
Syntax Validation
Valid / Invalid分離
Case Insensitive統合
Subject / Body / Both Location統合
TemplateScanResult生成
To / CC / BCC対象外
```

P2-01 Scopeと一致。

P2-01はSync Engine / VariableDefinition更新 / Manual Syncへ踏み込んでいない。

Scope Conflictなし。

---

# 8. P1-04 Contract Consistency

P1-04成立済みContract：

```vb
ScanTemplate(subjectText, bodyText, scanResult) As COperationResult
```

P1-04 Result：

```text
ValidVariables
InvalidCandidates
```

P2-01はPublic APIを維持し、既存2 Resultを変更せずLocationsを追加する。

また以下を維持する。

```text
Candidate Scan → Syntax Validation
Case Insensitive Dedup
初回検出順
初回検出表記
Invalid Candidate = Scanner Technical Failureではない
COM非依存
Excel Data Access非依存
```

Contract Conflictなし。

---

# 9. P2 Boundary / Unit Decision Consistency

P2 Boundaryでは、

```text
P1 Minimal Scan Result
↓
Locations追加
↓
Full TemplateScanResult
```

をP2 Scanner主差分としている。

Unit Decomposition DecisionではP2-01を、

```text
Full Template Scanner
Primary Module = modTemplateScanner
```

として分離している。

P2-01仕様はこの分割と一致。

---

# 10. Result Structural Consistency Review

Review時点のDraftでは、

```text
ValidVariables
Locations
```

の内容は定義されていたが、両者の構造整合性が明示的Invariantになっていなかった。

後続P2-02がTemplateScanResultを単独入力として信頼するためには、

```text
Valid Variableには必ずLocationがある
Location Entryは必ずValid Variableに対応する
```

ことをSpecification上明示する方が安全である。

これはDesign §14.6のResult概念から導かれるClarificationであり、新Requirementではない。

Correctionとして以下を追加。

```text
Locations.Count = ValidVariables.Count

ValidVariables全件
→ Locations Entryあり

Locations全Key
→ ValidVariablesに対応

InvalidCandidates
→ Locationsへ入らない
```

---

# 11. Governance Review

Technical Documentは`What is true`を保持し、Current Project State / Next ActionはProject Overview / Handoffへ置く運用である。

Draftには以下の進捗要素が含まれていた。

```text
前提Phase = P1 PASS / COMPLETE / CP-P1 ESTABLISHED
Production Implementation = NOT YET STARTED
次Unit = P2-02
```

技術的依存そのものは必要だが、Current State表現はTechnical Specificationへ保持しない方がGovernanceに整合する。

Correction：

```text
前提PhaseのCurrent State
→ Entry Dependency = CP-P1

Production Implementation進捗
→ 削除

次Unit / Next Action表現
→ 削除
```

またBaseline Technical DocumentsのRelated DocumentsはDocument ID中心へ正規化した。

---

# 12. Corrections

## CR-P2-01-001 MTS-SCAN-003 Responsibility Clarification

**Classification**

```text
Clarification / Traceability Correction
```

**Before**

P2-01がMTS-SCAN-003へ直接接続する記述のみ。

**Issue**

MTS-SCAN-003にはVariableDefinition側Canonical Casingも含まれるため、P2-01単独Full PASSと誤読可能。

**Correction**

```text
P2-01:
Scanner Core Portion

P2-02:
Existing VariableDefinition Casing

Full Expected:
P2-01 + P2-02 / MTS-SYNC-007
```

**Semantic Impact**

```text
NONE
```

---

## CR-P2-01-002 TemplateScanResult Structural Invariant

**Classification**

```text
Clarification / Contract Strengthening
```

**Issue**

ValidVariablesとLocationsの1:1整合が暗黙であり、Partial Resultを禁止する明示条件が不足。

**Correction**

以下を追加。

```text
Locations.Count = ValidVariables.Count
ValidVariables全件にLocationあり
Orphan Location禁止
Invalid CandidateのLocation登録禁止
```

Core Verification C11およびPASS Criteriaへ追加。

**Semantic Impact**

```text
NONE
```

---

## CR-P2-01-003 Technical Document Governance Alignment

**Classification**

```text
Editorial / Governance Correction
```

**Issue**

Technical SpecificationにCurrent Project State / Next Action相当が混在。

**Correction**

```text
Current State表現削除
Entry Dependencyへ置換
Next Unit記述削除
Baseline文書参照をDocument ID中心へ正規化
```

**Semantic Impact**

```text
NONE
```

---

# 13. No Correction Required

以下はDraftのまま妥当と判定。

```text
ScanTemplate Public API維持
Late Bound Scripting.Dictionary採用
Locations CompareMode = vbTextCompare
Location Values = Subject / Body / Both
初回検出表記保持
InvalidCandidates重複方針をPublic Contract化しない
Candidate Scan + Syntax Validationの2段階方式
To / CC / BCC APIを追加しない
専用CTemplateScanResult Classを追加しない
P2-02以降を先回りしない
```

---

# 14. Final Review Result

```text
Cross-document Consistency Review:
PASS WITH CORRECTIONS

Corrections:
3

Corrections Applied:
YES

Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE AFTER CLARIFICATION

Implementation Plan Conflict:
NONE

P1-04 Contract Conflict:
NONE

P2 Boundary Conflict:
NONE

P2 Unit Decomposition Conflict:
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

Approved Result：

```text
P2-01 Full Template Scanner 実施仕様 v0.1
APPROVED
```
