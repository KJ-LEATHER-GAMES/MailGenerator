# P05-I04 Reactivated Only Runtime Verification Record v0.1

## 1. Document Information

| Item | Value |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Implementation Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Verification Case | P05-I04 — Reactivated Only |
| Verification Type | Implementation Verification / Runtime Verification |
| Execution Baseline | BL-MVP-003 |
| Source Specification | P2-05 Fail Closed / Sync Result / Phase Integration Implementation Specification v0.1 — Approved |
| Related Design | MVP Design v0.1.9 |
| Execution Date | 2026-10-07 |
| Final Result | **PASS / CLOSED** |
| Re-test | **NOT REQUIRED** |

---

## 2. Verification Objective

P05-I04では、Manual Sync実行時に差分が **Reactivatedのみ** となるControlled Fixtureを使用し、以下を確認する。

```text
New = 0
Existing = 0
Reactivated > 0
Unused = 0
Success
```

User-facing Presentationでは、Reactivatedを `復活` として独立表示し、Existingの `継続` へマージしないことを確認する。

---

## 3. Controlled Fixture

### Template

P05-I02からOFTを変更せず、以下のVariableをTemplate上に維持した。

```text
{{P05_NewOnly}}
```

### VariableDefinition Initial State

P05-I02完了時点でActiveとなった `P05_NewOnly` を、P05-I04用Test Fixtureとして手動で以下へ変更した。

```text
P05_NewOnly
Status:
Active
↓
Unused
```

実施前Screenshotで確認した状態：

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| P05_NewOnly | Body | Unused | 10/7/2026 0:20 | 10/7/2026 0:20 |

その他既存行：

```text
ModelName
OldVariable
GateDate
Department
Comment
```

はいずれも `Unused` のままとした。

Evidence image:

```text
image(20261006-152903).png
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

### 5.1 Sync Result UI

Observed message:

```text
テンプレート同期結果

新規 (0件)
なし

継続 (0件)
なし

復活 (1件)
- P05_NewOnly

Unused化 (0件)
なし
```

Observed Category Counts:

| Category | Actual |
|---|---:|
| New / 新規 | 0 |
| Existing / 継続 | 0 |
| Reactivated / 復活 | 1 |
| Unused / Unused化 | 0 |

Displayed Reactivated Variable:

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

Important presentation evidence:

```text
P05_NewOnly
→ 復活へ表示

継続:
0件
```

Therefore, Reactivated was not merged into Existing / 継続.

Evidence image:

```text
image(20261006-152917).png
```

---

### 5.2 VariableDefinition After Sync

Observed post-sync state:

| VariableName | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| P05_NewOnly | Body | Active | 10/7/2026 0:20 | 10/7/2026 0:29 |

Before / After:

```text
Status:
Unused
↓
Active

TemplateLocation:
Body
↓
Body

FirstDetectedAt:
10/7/2026 0:20
↓
10/7/2026 0:20

LastDetectedAt:
10/7/2026 0:20
↓
10/7/2026 0:29
```

Observed user configuration fields for `P05_NewOnly` remain unchanged / unset.

Evidence image:

```text
image(20261006-152925).png
```

---

## 6. Contract / Design Review

### 6.1 P05-I04 Expected Result

Approved P2-05 Specification requires:

```text
復活へ表示

継続へマージしない

Success
```

Actual:

```text
復活 (1件)
- P05_NewOnly

継続 (0件)
なし

Success Presentation observed
```

Result:

```text
PASS
```

---

### 6.2 Reactivated Persistence Semantics

MVP Design defines Reactivated as:

```text
Status → Active

Existing user configuration → reuse / preserve

FirstDetectedAt → preserve

TemplateLocation → update to current TemplateScanResult

LastDetectedAt → SyncTimestamp
```

Observed:

```text
Status:
Unused → Active

FirstDetectedAt:
10/7/2026 0:20 → 10/7/2026 0:20
Preserved

TemplateLocation:
Body → Body
Current location remains Body

LastDetectedAt:
10/7/2026 0:20 → 10/7/2026 0:29
Updated
```

Result:

```text
PASS
```

---

## 7. Internal Result Evidence Assessment

The supplied screenshots do not directly show the VBA Locals Window.

Therefore the following values were not directly inspected in the screenshots:

```text
COperationResult.Success
syncDiffResult object existence
templateScanResult object existence
```

However, the established P2-05 Success Contract allows Success Presentation only when the operation succeeds and the required result carriers are present.

The observed Basic Success Result therefore provides behavioral / contract-based evidence that the success path was reached.

Evidence classification:

```text
COperationResult.Success:
True — behavioral / contract-based evidence

syncDiffResult:
Exists — behavioral / contract-based evidence

templateScanResult:
Exists — behavioral / contract-based evidence
```

No Production Test Hook or additional Public API is required.

---

## 8. Evidence Requirement Check

| Evidence Item | Result | Evidence |
|---|---|---|
| Test Case ID | PASS | P05-I04 |
| Initial Template State | PASS | `{{P05_NewOnly}}` retained |
| Initial VariableDefinition State | PASS | P05_NewOnly = Unused |
| User Action | PASS | Explicit RunManualSync |
| COperationResult.Success | PASS* | Success Presentation contract-based evidence |
| syncDiffResult existence | PASS* | Success Presentation structural guard-based evidence |
| templateScanResult existence | PASS* | Success Presentation structural guard-based evidence |
| Category Counts | PASS | 0 / 0 / 1 / 0 |
| Displayed Category Labels | PASS | 新規 / 継続 / 復活 / Unused化 |
| Displayed Variable Names | PASS | P05_NewOnly under 復活 |
| Reactivated not merged to Existing | PASS | 継続 = 0 |
| VariableDefinition before / after | PASS | Unused → Active; timestamp rule observed |
| Notification Count | PASS | Success notification 1 observed |
| Actual Result | PASS | Expected matched |
| PASS / FAIL | PASS | PASS |

`*` Direct Locals observation was not captured; behavioral evidence is used together with the established Success Contract.

---

## 9. Finding Assessment

```text
Unexpected New:
NONE

Unexpected Existing:
NONE

Unexpected Unused:
NONE

Reactivated Presentation Finding:
NONE

Reactivated → Existing Merge:
NONE

Persistence Finding:
NONE

User Configuration Loss:
NONE OBSERVED

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

No change to the existing observation disposition.

---

## 10. Final Decision

All P05-I04-specific Expected Results were observed.

```text
P05-I04 — Reactivated Only

New:
0

Existing:
0

Reactivated:
1
- P05_NewOnly

Unused:
0

Reactivated Presentation:
PASS

Not merged to Existing:
PASS

Status Reactivation:
Unused → Active
PASS

FirstDetectedAt Preservation:
PASS

LastDetectedAt Update:
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
P05-I05 — Unused Only
```

Recommended controlled transition from the current P05-I04 state:

```text
Current:
P05_NewOnly = Active
OFT contains {{P05_NewOnly}}

Next Fixture:
Remove {{P05_NewOnly}} from OFT

VariableDefinition:
Do not manually change P05_NewOnly
Keep Status = Active before execution

Other existing rows:
Keep Unused
```

Expected next result:

```text
New          = 0
Existing     = 0
Reactivated  = 0
Unused       = 1

UI:
Unused化 (1件)
- P05_NewOnly
```

Expected persistence:

```text
P05_NewOnly:
Status Active → Unused

Row remains present

TemplateLocation:
preserve last detected value

FirstDetectedAt:
preserve

LastDetectedAt:
preserve
```

Do not modify Production Code.

---

## 12. Summary / まとめ

### 日本語

P05-I04 Reactivated Onlyでは、実施前に `P05_NewOnly` をUnusedとし、OFT側には同Variableを残したControlled FixtureでManual Syncを実行した。結果は新規0、継続0、復活1、Unused化0で、`P05_NewOnly` は「復活」へ表示され、「継続」へマージされなかった。VariableDefinitionではStatusがUnusedからActiveへ戻り、FirstDetectedAtは保持、LastDetectedAtは更新された。したがって **P05-I04をPASS / CLOSED** とする。次はP05-I05 Unused Onlyへ進む。

### English

P05-I04 Reactivated Only used a controlled fixture where `P05_NewOnly` was Unused in VariableDefinition but still present in the OFT. The result was New 0, Existing 0, Reactivated 1, and Unused 0. `P05_NewOnly` was shown under Reactivated and was not merged into Existing. Its Status changed from Unused to Active, FirstDetectedAt was preserved, and LastDetectedAt was updated. Therefore, **P05-I04 is PASS / CLOSED**. The next case is P05-I05 Unused Only.
