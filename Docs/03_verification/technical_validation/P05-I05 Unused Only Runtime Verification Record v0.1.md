# P05-I05 Unused Only Runtime Verification Record v0.1

## 1. Document Information

| Item | Value |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Implementation Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Verification Case | P05-I05 — Unused Only |
| Verification Type | Implementation Verification / Runtime Verification |
| Execution Baseline | BL-MVP-003 |
| Source Specification | P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification v0.1 — Approved |
| Related Design | MVP Design v0.1.9 |
| Execution Date | 2026-10-07 |
| Final Result | **PASS / CLOSED** |
| Re-test | **NOT REQUIRED** |

---

## 2. Verification Objective

P05-I05では、Manual Sync実行時に差分が **Unusedのみ** となるControlled Fixtureを使用し、以下を確認する。

```text
New = 0
Existing = 0
Reactivated = 0
Unused > 0
Success
```

P2-05 Approved SpecificationでのP05-I05 Expectedは以下。

```text
Unused化へ表示

VariableDefinition削除をUIから行わない

Success
```

---

## 3. Controlled Fixture

### VariableDefinition Initial State

P05-I04完了後の状態を利用した。

`P05_NewOnly` はManual Sync実行前に以下の状態であった。

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| P05_NewOnly | Body | Active | 10/7/2026 0:20 | 10/7/2026 0:29 |

その他既存行：

```text
ModelName
OldVariable
GateDate
Department
Comment
```

はいずれも `Unused` のまま。

Evidence:

```text
image(20261006-154144).png
```

### Template State

P05-I05 Fixtureとして、OFTから `{{P05_NewOnly}}` を削除した。

これにより、

```text
P05_NewOnly:
VariableDefinition = Active
Template = absent
```

のUnused化条件を成立させた。

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

`syncDiffResult` では以下の4 Keyが存在した。

```text
New
Existing
Reactivated
Unused
```

`templateScanResult` では以下の3 Keyが存在した。

```text
ValidVariables
InvalidCandidates
Locations
```

Evidence:

```text
image(20261006-154222).png
```

### Count Interpretation Note

Locals Window上の、

```text
syncDiffResult.Count = 4
templateScanResult.Count = 3
```

は、それぞれ分類件数・Variable件数ではない。

これはDictionary Key数であり、

```text
syncDiffResult.Count = 4
→ New / Existing / Reactivated / Unused の4 Key

templateScanResult.Count = 3
→ ValidVariables / InvalidCandidates / Locations の3 Key
```

を意味する。

Actual Category CountはSync Result UIから判定する。

---

### 5.2 Sync Result UI

Observed message:

```text
テンプレート同期結果

新規 (0件)
なし

継続 (0件)
なし

復活 (0件)
なし

Unused化 (1件)
- P05_NewOnly
```

Observed Category Counts:

| Category | Actual |
|---|---:|
| New / 新規 | 0 |
| Existing / 継続 | 0 |
| Reactivated / 復活 | 0 |
| Unused / Unused化 | 1 |

Displayed Unused Variable:

```text
P05_NewOnly
```

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
image(20261006-154235).png
```

---

### 5.3 VariableDefinition After Sync

Observed post-sync state:

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| P05_NewOnly | Body | Unused | 10/7/2026 0:20 | 10/7/2026 0:29 |

Before / After:

```text
Row:
Present
↓
Present

Status:
Active
↓
Unused

TemplateLocation:
Body
↓
Body

FirstDetectedAt:
10/7/2026 0:20
↓
10/7/2026 0:20

LastDetectedAt:
10/7/2026 0:29
↓
10/7/2026 0:29
```

Evidence:

```text
image(20261006-154248).png
```

---

## 6. Contract / Design Review

### 6.1 P05-I05 Expected Result

Approved P2-05 Specification requires:

```text
Unused化へ表示

VariableDefinition削除をUIから行わない

Success
```

Actual:

```text
Unused化 (1件)
- P05_NewOnly

VariableDefinition row:
remains present

Status:
Unused

operationResult.Success:
True
```

Result:

```text
PASS
```

---

### 6.2 Unused Persistence Semantics

MVP Design defines Unused as:

```text
Status:
Unusedへ更新

TemplateLocation:
最終検出Locationを保持

FirstDetectedAt:
既存値保持

LastDetectedAt:
既存値保持

LastDetectedAtはUnused化時刻で上書きしない
```

Observed:

```text
Status:
Active → Unused

TemplateLocation:
Body → Body

FirstDetectedAt:
10/7/2026 0:20 → 10/7/2026 0:20

LastDetectedAt:
10/7/2026 0:29 → 10/7/2026 0:29
```

Result:

```text
PASS
```

---

### 6.3 Row Deletion

Before:

```text
P05_NewOnly row:
present
```

After:

```text
P05_NewOnly row:
present
```

Therefore:

```text
VariableDefinition row deletion:
NONE
```

Result:

```text
PASS
```

---

## 7. Evidence Requirement Check

| Evidence Item | Result | Evidence |
|---|---|---|
| Test Case ID | PASS | P05-I05 |
| Initial Template State | PASS | P05_NewOnly removed from OFT |
| Initial VariableDefinition State | PASS | P05_NewOnly = Active |
| User Action | PASS | Explicit RunManualSync |
| COperationResult.Success | PASS | Locals: True |
| syncDiffResult existence | PASS | Locals: Object/Dictionary |
| templateScanResult existence | PASS | Locals: Object/Dictionary |
| Category Counts | PASS | 0 / 0 / 0 / 1 |
| Displayed Category Labels | PASS | 新規 / 継続 / 復活 / Unused化 |
| Displayed Variable Names | PASS | P05_NewOnly under Unused化 |
| Displayed InvalidCandidates | N/A | Success case |
| Failure Message / Target | N/A | Success case |
| VariableDefinition before / after | PASS | Active → Unused; row preserved |
| Notification Count | PASS | Success notification 1 observed |
| Actual Result | PASS | Expected matched |
| PASS / FAIL | PASS | PASS |

---

## 8. Evidence Strength Assessment

P05-I05では以下を直接観測できた。

```text
operationResult.Success = True

syncDiffResult = Exists

templateScanResult = Exists

UI Category Count:
New = 0
Existing = 0
Reactivated = 0
Unused = 1

VariableDefinition:
row remains
Status Active → Unused
TemplateLocation preserved
FirstDetectedAt preserved
LastDetectedAt preserved
```

したがって、P05-I02 / I04でBehavioral Evidenceとして扱っていた内部Success Contractについても、今回はLocals WindowによるDirect Runtime Evidenceが得られた。

Test専用Hook追加：

```text
NOT REQUIRED
```

---

## 9. Finding Assessment

```text
Unexpected New:
NONE

Unexpected Existing:
NONE

Unexpected Reactivated:
NONE

Unused Presentation Finding:
NONE

VariableDefinition Row Deletion:
NONE

Metadata Finding:
NONE

Unexpected LastDetectedAt Update:
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

## 10. Final Decision

All P05-I05-specific Expected Results were observed.

```text
P05-I05 — Unused Only

New:
0

Existing:
0

Reactivated:
0

Unused:
1
- P05_NewOnly

COperationResult.Success:
True

syncDiffResult:
Exists

templateScanResult:
Exists

Unused Presentation:
PASS

VariableDefinition Row Preservation:
PASS

Status:
Active → Unused
PASS

TemplateLocation Preservation:
PASS

FirstDetectedAt Preservation:
PASS

LastDetectedAt Preservation:
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

## 11. Next Action

Proceed to:

```text
P05-I06 — Zero-diff Success
```

Recommended transition:

```text
Current Template:
P05_NewOnly absent

Current VariableDefinition:
P05_NewOnly = Unused
Other existing variables = Unused
```

No fixture change is required before I06 if the current template contains no valid variables that would generate New / Existing / Reactivated.

Expected:

```text
New          = 0
Existing     = 0
Reactivated  = 0
Unused       = 0

Success = True

Success Notification = 1
```

The current I05 post-state is therefore the preferred I06 initial state.

---

## 12. Summary / まとめ

### 日本語

P05-I05 Unused Onlyでは、`P05_NewOnly` をTemplateから除外し、VariableDefinitionではActiveの状態からManual Syncを実行した。Locals Windowで `operationResult.Success = True`、`syncDiffResult` および `templateScanResult` の存在を直接確認した。Sync Result UIは新規0、継続0、復活0、Unused化1で、`P05_NewOnly` がUnused化として表示された。VariableDefinition行は削除されず、StatusのみActiveからUnusedへ変更され、TemplateLocation / FirstDetectedAt / LastDetectedAtは保持された。したがって **P05-I05をPASS / CLOSED** とする。次は、この状態をそのまま利用してP05-I06 Zero-diff Successへ進む。

### English

P05-I05 Unused Only removed `P05_NewOnly` from the template while it was Active in VariableDefinition. The Locals Window directly showed `operationResult.Success = True`, and both `syncDiffResult` and `templateScanResult` existed. The UI showed New 0, Existing 0, Reactivated 0, and Unused 1 with `P05_NewOnly` under Unused. The VariableDefinition row was not deleted. Its Status changed from Active to Unused, while TemplateLocation, FirstDetectedAt, and LastDetectedAt were preserved. Therefore, **P05-I05 is PASS / CLOSED**. The next case is P05-I06 Zero-diff Success using the current state.
