# P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1

# Cross-document Consistency Review v0.1

## 1. Review Information

| 項目                 | 内容                                                              |
| ------------------ | --------------------------------------------------------------- |
| Review対象           | P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 — Candidate |
| Review種別           | Cross-document Consistency Review                               |
| Execution Baseline | BL-MVP-003                                                      |
| Review Result      | **PASS WITH CORRECTIONS**                                       |
| Corrections        | **3件 / 全件反映可能**                                                 |
| Blocking Finding   | **0**                                                           |
| Requirement Gap    | **0**                                                           |
| Design Conflict    | **0**                                                           |
| Baseline Change    | **NOT REQUIRED**                                                |
| P2-02 Reopen       | **NOT REQUIRED**                                                |
| Final Disposition  | Corrections適用後 Approved可能                                       |

## 2. Review Sources

以下をSource of Truthとして比較した。

- MVP Requirements v0.1.9
- MVP Design v0.1.9
- MVP Test Specification v0.1.5
- Implementation Plan v0.3
- P2-02 Sync Diff Core Completion Record v0.1
- P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1
- P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 — Candidate

---

# 3. Requirement Consistency

## 3.1 New

CandidateではNewについて、

```text
VariableDefinitionへNew Row追加
Status = Active
User Configuration = Blank
```

としている。

Requirementsでは、新しいVariableを自動追加し、設定未完了状態とし、少なくともDisplayName / Type / Requiredを未設定とすることが要求されている。

CandidateがDisplayName / Type / Requiredに加え、Description / OptionSource / SortOrder / FormatもBlankとすることはRequirementに反しない。

判定：

```text
Requirement Conflict:
NONE
```

---

## 3.2 Existing

CandidateではExistingのUser Configurationを一切Writeせず保持する。

Requirementsでは、

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

を同期処理によって上書きしないことが要求されている。

判定：

```text
PASS
```

---

## 3.3 Unused / Reactivated

Candidateでは、

```text
Deleted Variable
→ Row削除なし
→ Unused

Reappeared Variable
→ Activeへ復帰
→ Existing User Configuration保持
```

としている。

これはFR-SYNC-004 / 005と一致する。

判定：

```text
PASS
```

---

## 3.4 Rename

CandidateはRenameを推測せず、P2-02 Target StateをそのままPersistenceする。

Requirementsでは、

```text
Old → Unused
New → New
```

とし、自動Rename推測を禁止している。

判定：

```text
PASS
```

---

# 4. Design Consistency

## 4.1 Metadata

CandidateのPersistence対象：

```text
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

はDesign §7.4の自動管理列と一致する。

New / Existing / Reactivated / UnusedのTarget StateもDesignのMetadata表と一致している。

特に、

```text
Unused:
LastDetectedAtをUnused化時刻で更新しない
```

も一致する。

判定：

```text
PASS
```

---

## 4.2 Data Access Responsibility

Candidateでは、

```text
modVariableDefinitionData
```

へ `ApplySyncDiff()` を追加し、

```text
ListObject
Column Index
Physical Row Index
```

をModule内部へ閉じる。

Design §10ではExcel依存をData Accessへ集約し、`modVariableDefinitionData`へ新規Variable追加およびMetadata更新責務を置いている。

判定：

```text
PASS
```

---

## 4.3 Sync Semantics

CandidateはClassificationを行わず、P2-02から受け取ったTarget StateをPersistenceする。

Design §15では、

```text
New
Existing
Reactivated
Unused
Rename
```

およびMetadataの意味が既に定義されている。

したがってP2-03がこれを再計算しない構造はDesign責務分離と一致する。

判定：

```text
PASS
```

---

## 4.4 Manual Sync Boundary

Design §25.1では、

```text
Scan
↓
VariableDefinition取得
↓
Sync Engine
↓
VariableDefinition更新
↓
同期結果
↓
UI通知
```

の順で構成されている。

Candidateの、

```text
P2-04 = Orchestration
P2-03 = Persistence
```

という分離はこのFlowを具体化したものであり、Design Conflictではない。

判定：

```text
PASS
```

---

# 5. Test Specification Consistency

MVP Test SpecificationではP2対象として、

```text
MTS-SYNC-002 New
MTS-SYNC-003 Existing
MTS-SYNC-004 Unused
MTS-SYNC-005 Reactivated
MTS-SYNC-006 Rename
MTS-SYNC-007 Case Insensitive
MTS-SYNC-011 Metadata
```

が定義されている。

CandidateのC01-C12 / N01-N18 / K1-K3はこれらの正式Testを置換するものではなく、Production実装に対するImplementation Verificationとして定義されている。

Implementation Planでも、Phase VerificationでMTS相当Scenarioを確認してもFormal MVP Test PASSには算入しないことが明示されている。

判定：

```text
Test Specification Conflict:
NONE

Formal Test Preemption:
NONE
```

---

# 6. Implementation Plan Consistency

Implementation Plan P2では、

```text
modTemplateScanner
modSyncEngine
modSyncApplication
modVariableDefinitionData
```

をP2 Scopeとし、New / Existing / Reactivated / UnusedおよびMetadata更新、既存設定維持を成立させることが要求されている。

CandidateのModule配置と責務は一致する。

一方でP6は、

```text
Error / Safety / Integration
User Notification
User-facing Error Handling
技術例外 → User Message変換規則
```

の完成を担当する。

この点からCandidateに3点の表現補正が必要である。

---

# 7. P2-02 Contract Consistency

P2-02 Completion RecordはP2-03について明示的に、

```text
Input:
P2-02 SyncDiffResult

Responsibility:
VariableDefinitionへのPersistence

Do Not Recompute:
Classification
Canonical VariableName
SyncTimestamp
Rename Inference
Metadata Meaning
```

と定義している。

Candidateは、

```text
BuildSyncDiffを呼ばない
Now / Date / Timeを取得しない
Classificationを再計算しない
Canonical VariableNameを再計算しない
Renameを推測しない
```

ため、P2-02 Contractを変更しない。

判定：

```text
P2-02 Contract Conflict:
NONE

P2-02 Reopen:
NOT REQUIRED
```

---

# 8. Correction CR-P2-03-001

## ErrorType Mappingの位置付け

### Candidate

§6で、

```text
ConfigurationError
UnexpectedError
```

等をFailure別に固定している。

Design §24には既存ErrorTypeとResultモデルが定義されているため、これらをP2-03で利用すること自体に問題はない。

ただしImplementation Planでは、Error Path統合、User Message変換、Error Code等の最終決定をP6へ残している。

### Correction

§6へ以下を追加する。

```text
本表はP2-03 Implementationで使用するInterim Mappingである。

既存ErrorType自体はDesign §24に従うが、
End-to-End Error Classification、
Error Code、
User-facing Message Mappingの最終化は
P6 Error / Safety / Integrationの責務を維持する。
```

判定：

```text
Baseline Semantic Change:
NONE

Correction Type:
Responsibility Clarification
```

---

# 9. Correction CR-P2-03-002

## Runtime Failure Message

Candidate §21.2ではPartial Write時のError Message例を記載している。

しかしP2-03 Boundaryでは、

```text
User Notification:
OUT OF SCOPE
```

であり、Implementation Plan上もUser-facing Error Handlingの完成はP6責務である。

### Correction

P2-03では、

```text
ErrorInfoへPartial Write可能性を識別可能なContextを保持する
```

ところまでとする。

具体的な最終ユーザー向けMessage文言は固定しない。

```text
Exact User-facing Message:
P2-05 / P6 responsibility
```

へ変更する。

---

# 10. Correction CR-P2-03-003

## Retry Ruleの責務表現

Candidate §22の、

```text
Template Scan
↓
Current Definitions
↓
BuildSyncDiff
↓
ApplySyncDiff
```

というRecovery Sequence自体は、RollbackなしというBoundaryから妥当である。

ただし、このSequenceをP2-03内部処理として読む余地がある。

P2-02 Completion Recordでは、

```text
P2-03 Persistence
↓
P2-04 Manual Sync Integration
↓
P2-05 Fail Closed / Sync Result / Phase Integration
```

と分離されている。

### Correction

§22を、

```text
Recovery / Retry Integration Constraint
```

と位置付ける。

P2-03自身は再Scan / 再Build / Retry Orchestrationを実行しない。

P2-04 / P2-05がFailure後に再実行する場合、

```text
Stale SyncDiffResultを再適用せず
Current StateからSyncを再構築する
```

というIntegration ConstraintのみをP2-03から提示する。

---

# 11. Compatible Implementation Refinements

以下はBaselineに具体的な実装方法として明記されていないが、既存仕様に反しないためImplementation Detailとして許容する。

```text
ApplySyncDiff Public API 1本
Preflightの具体順序
Private Helper構成
ExistingRowMap
Required Column Preflight
Cross-class Duplicate Guard
New Conflict Guard
Existing Missing Guard
Canonical Name Contract Guard
Empty Table対応
New Row末尾追加
Multiple New Collection順
Production Read Backなし
Rollbackなし
Static Review項目
C / N / K Verification Case体系
```

これらはRequirement / Design / Test Expected Resultを変更しない。

---

# 12. Semantic Equivalence Check

特に以下は実装表現とDesign表現が異なるが、結果状態は同一である。

### Unused

Design：

```text
StatusのみUnusedへ変更
Metadataは保持
```

P2-03：

```text
Status
TemplateLocation
FirstDetectedAt
LastDetectedAt

4 FieldをP2-02 Target StateでWrite
```

P2-02 Target State自身が保持対象Metadataへ既存値を設定しているため、Persist後の状態は同一である。

したがって、

```text
Semantic Conflict:
NONE
```

と判定する。

---

# 13. Final Consistency Matrix

| Review Area                   | Result                                 |
| ----------------------------- | -------------------------------------- |
| MVP Requirements v0.1.9       | PASS                                   |
| MVP Design v0.1.9             | PASS                                   |
| MVP Test Specification v0.1.5 | PASS                                   |
| Implementation Plan v0.3      | PASS WITH RESPONSIBILITY CLARIFICATION |
| P2-02 Contract                | PASS                                   |
| P2-03 Boundary Confirmation   | PASS                                   |
| Requirement Gap               | NONE                                   |
| Design Gap                    | NONE                                   |
| Scope Expansion               | NONE                                   |
| Traceability Break            | NONE                                   |
| P2-02 Reopen                  | NOT REQUIRED                           |
| Technical Spike Reopen        | NOT REQUIRED                           |
| Baseline Change               | NOT REQUIRED                           |
| Blocking Finding              | 0                                      |

---

# 14. Correction Status

```text
CR-P2-03-001
ErrorType MappingをP2 Interim Mappingとして明示
→ APPLIED

CR-P2-03-002
Partial Write時の最終User-facing MessageをP2-05 / P6へ維持
→ APPLIED

CR-P2-03-003
Retry RuleをP2-04 / P2-05向けIntegration Constraintとして明示
→ APPLIED
```

---

# 15. Final Review Result

Corrections適用後：

```text
Requirement Conflict:
NONE

Design Conflict:
NONE

Test Specification Conflict:
NONE

Implementation Plan Conflict:
NONE

P2-02 Contract Conflict:
NONE

P2-03 Boundary Conflict:
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

P2-02 Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
0
```

最終判定：

```text
Cross-document Consistency Review:
PASS WITH CORRECTIONS

Corrections:
ALL APPLIED

Residual Conflict:
0

P2-03 Implementation Unit Specification v0.1:
APPROVABLE
```

## まとめ / Summary

### 日本語

P2-03実施仕様 v0.1 CandidateをRequirements、Design、Test Specification、Implementation Plan、P2-02 Contractと比較した。

同期意味論、Metadata、User Configuration保持、Data Access、Formal Test境界、P2-02責務境界には矛盾はない。

P6 / P2-05の責務を先取りして読めるError Mapping、User-facing Message、Retry Orchestrationの3点のみ責務表現を補正した。

補正後の残存Conflictは0件であり、Baseline変更およびP2-02 Reopenは不要である。

### English

The P2-03 implementation specification v0.1 Candidate was reviewed against Requirements, Design, Test Specification, Implementation Plan, and the P2-02 contract.

No conflicts were found in sync semantics, metadata rules, user-configuration preservation, data-access responsibility, formal-test boundaries, or the P2-02 contract.

Three responsibility clarifications were applied for error mapping, user-facing runtime-failure messages, and retry orchestration so that P2-05/P6 responsibilities remain intact.

After these corrections, there are zero remaining conflicts. No baseline change or P2-02 reopen is required.
