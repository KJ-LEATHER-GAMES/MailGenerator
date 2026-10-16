# P05-I01 Mixed Result Runtime Verification Record v0.1

## 1. Document Information

| Item | Value |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Implementation Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Verification Case | P05-I01 — Happy Path / Mixed Result |
| Verification Type | Implementation Verification / Runtime Verification |
| Execution Baseline | BL-MVP-003 |
| Source Specification | P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification v0.1 — Approved |
| Related Design | MVP Design v0.1.9 |
| Execution Date | 2026-10-07 |
| Final Result | **PASS / CLOSED** |
| Re-test | **NOT REQUIRED** |

---

## 2. Verification Objective

P05-I01では、1回のManual Syncで4分類すべてを同時に成立させ、Basic Sync Resultが各Variableを正しいSectionへ表示することを確認する。

Approved Precondition:

```text
New > 0
Existing > 0
Reactivated > 0
Unused > 0
```

Approved Expected:

```text
ExecuteManualSync Success

Success Notification 1回

新規 / 継続 / 復活 / Unused化
4 Section表示

各VariableName確認可能
```

---

## 3. Controlled Fixture

### 3.1 VariableDefinition Initial State

実施前の主要状態：

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| ModelName | Both | Active | 10/1/2026 21:51 | 10/4/2026 23:37 |
| OldVariable | Body | Unused | — | — |
| GateDate | Both | Active | 10/1/2026 21:51 | 10/4/2026 23:37 |
| Department | Body | Unused | 10/1/2026 21:51 | 10/4/2026 23:37 |
| Comment | Body | Unused | 10/1/2026 21:51 | 10/4/2026 23:37 |
| P05_NewOnly | Body | Unused | 10/7/2026 0:20 | 10/7/2026 0:29 |

Evidence:

```text
image(20261006-214146).png
```

### 3.2 Template State

OFT Bodyには以下の3 Variableを設定した。

```text
{{ModelName}}

{{Department}}

{{P05_MixedNew}}
```

`GateDate` はTemplateから除外した。

Evidence:

```text
image(20261006-214201).png
```

### 3.3 Expected Classification Mapping

Fixtureから期待される分類：

```text
ModelName
VariableDefinition = Active
Template = Present
→ Existing

GateDate
VariableDefinition = Active
Template = Absent
→ Unused

Department
VariableDefinition = Unused
Template = Present
→ Reactivated

P05_MixedNew
VariableDefinition row = Absent
Template = Present
→ New
```

その他：

```text
OldVariable
Comment
P05_NewOnly
= Unused + Template Absent
→ No-op
```

---

## 4. User Action

```text
User explicit action
↓
RunManualSync
↓
ExecuteManualSync
↓
Basic Sync Result Presentation
```

Automatic Sync / Automatic Retryは使用していない。

---

## 5. Runtime Evidence

### 5.1 Locals Window

RunManualSync内でLocals Windowを直接確認した。

Observed:

```text
operationResult
→ COperationResult

operationResult.mSuccess
→ True

operationResult.Success
→ True

syncDiffResult
→ Object/Dictionary
→ Exists

templateScanResult
→ Object/Dictionary
→ Exists
```

`syncDiffResult`:

```text
Count = 4

Keys:
New
Existing
Reactivated
Unused
```

`templateScanResult`:

```text
Count = 3

Keys:
ValidVariables
InvalidCandidates
Locations
```

Evidence:

```text
image(20261006-214236).png
```

### Count Interpretation Note

```text
syncDiffResult.Count = 4
templateScanResult.Count = 3
```

はDictionary Key数であり、分類件数ではない。

Actual Category CountおよびVariableNameはSync Result UIをEvidence Sourceとする。

---

### 5.2 Sync Result UI

Observed:

```text
テンプレート同期結果

新規 (1件)
- P05_MixedNew

継続 (1件)
- ModelName

復活 (1件)
- Department

Unused化 (1件)
- GateDate
```

Observed Category Counts:

| Category | Actual | Variable |
|---|---:|---|
| New / 新規 | 1 | P05_MixedNew |
| Existing / 継続 | 1 | ModelName |
| Reactivated / 復活 | 1 | Department |
| Unused / Unused化 | 1 | GateDate |

Success Notification:

```text
Observed = 1
```

Failure Notification:

```text
Observed = 0
```

Evidence:

```text
image(20261006-214248).png
```

---

## 6. VariableDefinition After Sync

Observed post-sync state:

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| ModelName | Body | Active | 10/1/2026 21:51 | 10/7/2026 6:42 |
| OldVariable | Body | Unused | — | — |
| GateDate | Both | Unused | 10/1/2026 21:51 | 10/4/2026 23:37 |
| Department | Body | Active | 10/1/2026 21:51 | 10/7/2026 6:42 |
| Comment | Body | Unused | 10/1/2026 21:51 | 10/4/2026 23:37 |
| P05_NewOnly | Body | Unused | 10/7/2026 0:20 | 10/7/2026 0:29 |
| P05_MixedNew | Body | Active | 10/7/2026 6:42 | 10/7/2026 6:42 |

Evidence:

```text
image(20261006-214301).png
```

---

## 7. Per-Classification Persistence Review

### 7.1 New — P05_MixedNew

Before:

```text
VariableDefinition row:
Absent
```

After:

```text
VariableName:
P05_MixedNew

TemplateLocation:
Body

Status:
Active

FirstDetectedAt:
10/7/2026 6:42

LastDetectedAt:
10/7/2026 6:42
```

User configuration fields are visibly unset.

Result:

```text
PASS
```

---

### 7.2 Existing — ModelName

Before:

```text
TemplateLocation:
Both

Status:
Active

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/4/2026 23:37
```

After:

```text
TemplateLocation:
Body

Status:
Active

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/7/2026 6:42
```

Visible user configuration remains:

```text
DisplayName = Model
Type = Text
Required = TRUE
SortOrder = 1
```

Result:

```text
PASS
```

---

### 7.3 Reactivated — Department

Before:

```text
TemplateLocation:
Body

Status:
Unused

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/4/2026 23:37
```

After:

```text
TemplateLocation:
Body

Status:
Active

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/7/2026 6:42
```

Result:

```text
PASS
```

---

### 7.4 Unused — GateDate

Before:

```text
TemplateLocation:
Both

Status:
Active

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/4/2026 23:37
```

After:

```text
TemplateLocation:
Both

Status:
Unused

FirstDetectedAt:
10/1/2026 21:51

LastDetectedAt:
10/4/2026 23:37
```

No row deletion occurred.

Result:

```text
PASS
```

---

## 8. Common SyncTimestamp Evidence

The following variables processed as detected variables in the same Manual Sync share:

```text
SyncTimestamp:
10/7/2026 6:42
```

Observed:

```text
ModelName LastDetectedAt
= 10/7/2026 6:42

Department LastDetectedAt
= 10/7/2026 6:42

P05_MixedNew FirstDetectedAt
= 10/7/2026 6:42

P05_MixedNew LastDetectedAt
= 10/7/2026 6:42
```

This is consistent with the Design rule that one SyncTimestamp is acquired at sync start and shared within the same sync.

`GateDate` was Unused化 and correctly retained its prior LastDetectedAt instead of receiving this timestamp.

Result:

```text
PASS
```

---

## 9. Contract / Specification Review

### 9.1 P05-I01 Precondition

Required:

```text
New > 0
Existing > 0
Reactivated > 0
Unused > 0
```

Actual:

```text
New = 1
Existing = 1
Reactivated = 1
Unused = 1
```

Result:

```text
PASS
```

### 9.2 P05-I01 Expected

Required:

```text
ExecuteManualSync Success
Success Notification 1回
4 Section表示
各VariableName確認可能
```

Actual:

```text
operationResult.Success = True

新規:
P05_MixedNew

継続:
ModelName

復活:
Department

Unused化:
GateDate

Success Notification:
1
```

Result:

```text
PASS
```

---

## 10. Evidence Requirement Check

| Evidence Item | Result | Evidence |
|---|---|---|
| Test Case ID | PASS | P05-I01 |
| Initial Template State | PASS | OFT screenshot |
| Initial VariableDefinition State | PASS | Before screenshot |
| User Action | PASS | Explicit RunManualSync |
| COperationResult.Success | PASS | Locals: True |
| syncDiffResult existence | PASS | Locals: Object/Dictionary |
| templateScanResult existence | PASS | Locals: Object/Dictionary |
| Category Counts | PASS | 1 / 1 / 1 / 1 |
| Displayed Category Labels | PASS | 新規 / 継続 / 復活 / Unused化 |
| Displayed Variable Names | PASS | All four variables individually confirmed |
| Displayed InvalidCandidates | N/A | Success case |
| Failure Message / Target | N/A | Success case |
| VariableDefinition before / after | PASS | All four persistence semantics confirmed |
| Notification Count | PASS | Success notification 1 observed |
| Actual Result | PASS | Expected matched |
| PASS / FAIL | PASS | PASS |

---

## 11. Finding Assessment

```text
Misclassification:
NONE

New Persistence Finding:
NONE

Existing Persistence Finding:
NONE

Reactivated Persistence Finding:
NONE

Unused Persistence Finding:
NONE

Common SyncTimestamp Finding:
NONE

Unexpected User Configuration Change:
NONE OBSERVED

Presentation Finding:
NONE

Result Carrier Finding:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Finding:
0
```

OBS-P2-05-002 Intermittent WordEditor E_FAIL:

```text
Reproduction in this execution:
NONE OBSERVED

Disposition:
OPEN / NON-BLOCKING
```

No change to existing observation disposition.

---

## 12. Final Decision

All P05-I01-specific Precondition and Expected Results were satisfied.

```text
P05-I01 — Happy Path / Mixed Result

COperationResult.Success:
True

syncDiffResult:
Exists

templateScanResult:
Exists

New:
1
- P05_MixedNew

Existing:
1
- ModelName

Reactivated:
1
- Department

Unused:
1
- GateDate

Success Notification:
1

Classification:
PASS

Presentation:
PASS

Persistence:
PASS

Common SyncTimestamp:
PASS

Blocking Finding:
0

RESULT:
PASS / CLOSED
```

Re-test:

```text
NOT REQUIRED
```

This result is an **Implementation Verification** result and does not claim Formal MVP Test PASS.

---

## 13. Runtime Verification Status / Next Action

With P05-I01 closed, the runtime cases identified as remaining at the handoff are now all closed:

```text
P05-I02 New Only
PASS / CLOSED

P05-I04 Reactivated Only
PASS / CLOSED

P05-I05 Unused Only
PASS / CLOSED

P05-I06 Zero-diff Success
PASS / CLOSED

P05-I01 Mixed Result
PASS / CLOSED
```

Previously closed runtime cases remain unchanged.

Next formal work:

```text
Verification Evidence Consolidation
↓
P2-01 Regression
↓
P2-02 Regression
↓
P2-03 Regression
↓
P2-04 Regression
↓
VBA Compile
↓
Static Review S01-S32
↓
Production Patch Review
↓
Final Finding Assessment
↓
P2-05 Completion Decision
```

Important boundary:

```text
Runtime Verification PASS
≠
P2-05 COMPLETE

P2-05 COMPLETE
≠
CP-P2 ESTABLISHED
```

---

## 14. Summary / まとめ

### 日本語

P05-I01 Mixed Resultでは、ModelNameをExisting、GateDateをUnused、DepartmentをReactivated、P05_MixedNewをNewとするControlled FixtureでManual Syncを実行した。Locals Windowで `operationResult.Success = True`、`syncDiffResult`、`templateScanResult` の存在を直接確認した。UIでは4分類が各1件ずつ正しいSectionへ表示され、VariableDefinitionの更新もNew / Existing / Reactivated / UnusedそれぞれのDesign規則と一致した。同一Syncで更新される検出Variableには共通の `10/7/2026 6:42` が使用され、Common SyncTimestampも確認できた。したがって **P05-I01をPASS / CLOSED** とする。引き継ぎ時点で残っていたRuntime Verification 5件はすべてCloseし、次はVerification Evidence Consolidationへ進む。

### English

P05-I01 Mixed Result used a controlled fixture with ModelName as Existing, GateDate as Unused, Department as Reactivated, and P05_MixedNew as New. The Locals Window directly showed `operationResult.Success = True`, and both `syncDiffResult` and `templateScanResult` existed. The UI showed one correct variable in each of the four categories. VariableDefinition updates matched the design rules for New, Existing, Reactivated, and Unused. The detected variables also used the same sync time, `10/7/2026 6:42`. Therefore, **P05-I01 is PASS / CLOSED**. All five runtime cases that remained at handoff are now closed, and the next step is Verification Evidence Consolidation.
