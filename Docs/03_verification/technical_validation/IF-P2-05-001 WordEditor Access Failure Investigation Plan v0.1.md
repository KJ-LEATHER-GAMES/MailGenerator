# IF-P2-05-001 WordEditor Access Failure
# Investigation Plan v0.1

## 1. Finding Information

| Item | Value |
|---|---|
| Finding ID | `IF-P2-05-001` |
| Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Stage | P2-05 Verification |
| Status | **OPEN / INVESTIGATION REQUIRED** |
| Blocking | **YES — blocks normal P2-05 success-path verification** |
| Production UI Candidate | `modUiController_P2-05_v0.1_CP932.bas` |
| VBA Compile | **PASS** |
| Requirement Gap | **NOT INDICATED** |
| Design Finding | **NOT INDICATED** |
| Production Defect Classification | **NOT YET DETERMINED** |

---

## 2. Observed Runtime Result

User executed:

```text
Alt + F8
→ RunManualSync
→ Run
```

Observed modal:

```text
テンプレート同期に失敗しました。

Unable to access WordEditor: -2147467259 - 操作は失敗しました。
確認対象: WordEditor
```

Observed failure point:

```text
Manual Sync
↓
modSyncApplication
↓
modOutlookAdapter
↓
ReadBodyText
↓
Inspector.WordEditor
↓
FAIL
```

The HRESULT `-2147467259` corresponds to generic COM `E_FAIL (0x80004005)`.
It identifies a generic COM operation failure, but does not by itself identify the root cause.

---

## 3. Immediate Assessment

### P2-05 UI / Fail-Closed behavior

The P2-05 UI did not treat the operation as success.

It received the failure result and displayed the existing Message / Target through one modal path.

Therefore the currently observed behavior is consistent with:

```text
P05-I09
Template / Scan Technical Failure

Failure Notification:
OBSERVED

Success Notification:
NOT OBSERVED

Unhandled Runtime Error:
NOT OBSERVED
```

Subject to confirmation that no additional notification occurred, classify:

```text
P05-I09:
PASS — P2-05 failure-presentation behavior
```

### Lower-layer functional path

The underlying WordEditor production path did not complete.

Historical P1 evidence established that both Warm and Cold Start WordEditor paths must succeed.

Therefore this failure is not accepted as normal behavior.

Current classification:

```text
Lower-layer Regression Candidate
/
Outlook-WordEditor Lifecycle / Readiness Finding

Root Cause:
NOT YET IDENTIFIED
```

---

## 4. Historical Evidence Relevant to the Finding

P1-02 established:

```text
Hidden Explorer Initialization
→ WordEditor Access FAIL

Visible Explorer Initialization
→ ReadBodyText PASS
```

Production therefore adopted:

```text
Cold Start
→ Visible Explorer Initialization
→ Readiness
→ WordEditor
```

Later P1-07 verification established both:

```text
Warm Start:
PASS

Cold Start:
PASS
```

P1-07 also previously detected and corrected:

```text
LF-P1-07-001
Outlook Application Stale Reference
```

Therefore the current failure has three primary investigation branches:

```text
A. Cold Start readiness / timing regression

B. Stale Outlook Application reference recurrence

C. Current workbook modOutlookAdapter differs from
   approved P1-07 v0.1.1 Production
```

A transient Outlook / COM environment condition remains possible but should not be assumed without reproduction evidence.

---

# 5. Investigation Principle

Do not modify Production code yet.

Sequence:

```text
Reproduce
↓
Separate Warm / Cold behavior
↓
Check lifecycle recurrence
↓
Confirm current modOutlookAdapter version/source
↓
Only then design a correction if required
```

Do not immediately add:

```text
Sleep
arbitrary wait
retry loop
automatic retry
new public test hook
```

---

# 6. Step 1 — Same-session Immediate Retry

After the first failure, do not close Excel or Outlook.

Execute:

```text
Alt + F8
→ RunManualSync
→ Run
```

again once.

Record:

```text
PASS / same WordEditor FAIL / different FAIL
```

Interpretation:

### Second run PASS

Strong indication of:

```text
Cold Start Explorer / WordEditor readiness timing race
```

because the first operation may have caused Outlook / Explorer initialization to complete before the second run.

### Second run FAIL

Proceed to clean Warm / Cold isolation.

---

# 7. Step 2 — Clean Warm Start Test

Prepare:

```text
1. Close Excel completely.
2. Start Classic Outlook manually.
3. Confirm a normal Outlook Explorer window is visible.
4. Open MailGeneratorNew.xlsm.
5. Run RunManualSync once.
```

Record:

```text
Warm Start:
PASS / FAIL
```

Interpretation:

### Warm PASS

Basic:

```text
MailItem
→ Inspector
→ WordEditor
```

path is functional.

Focus shifts to Cold Start Readiness.

### Warm FAIL

The problem is broader than Cold Start.

Focus on:

```text
current modOutlookAdapter source/version
Inspector / WordEditor acquisition
Outlook process state
stale COM/lifecycle state
```

---

# 8. Step 3 — Clean Cold Start Test

Prepare:

```text
1. Close Excel completely.
2. Exit Classic Outlook completely.
3. Confirm Outlook is not running.
4. Open MailGeneratorNew.xlsm only.
5. Run RunManualSync once.
```

Expected approved behavior:

```text
Tool starts Classic Outlook
Visible Explorer appears
Readiness established
WordEditor accessible
Manual Sync continues
```

Record:

```text
Cold Start:
PASS / FAIL
```

Interpretation matrix:

| Warm | Cold | Primary Direction |
|---|---|---|
| PASS | PASS | transient / one-off state; repeatability check |
| PASS | FAIL | Cold Start Readiness regression |
| FAIL | FAIL | general Adapter / WordEditor regression or source mismatch |
| FAIL | PASS | unusual state/lifecycle issue; reproduce before code change |

---

# 9. Step 4 — Post-failure Lifecycle Check

If Clean Cold Start fails:

```text
1. Keep the same Excel session open.
2. Ensure Classic Outlook now has a visible Explorer.
3. Run RunManualSync again manually.
```

Interpretation:

### Retry PASS

Likely:

```text
first-run initialization latency
/
Readiness completed too late for first WordEditor access
```

### Retry FAIL

Possible:

```text
stale / invalid mOutlookApp or mMailItem reference
remaining after the failure
```

This branch is especially relevant because P1-07 previously had a stale Outlook Application reference finding.

---

# 10. Step 5 — Current Production Source Confirmation

Before any correction, export the current workbook module:

```text
modOutlookAdapter
```

and compare it with the approved final P1 Production:

```text
modOutlookAdapter_P1-07_v0.1.1_CP932.bas
```

Confirm at minimum:

```text
Cold Start Visible Explorer initialization exists

EnsureOutlookReady path is current

Readiness failure clears invalid Outlook Application reference

P1-07 stale-reference correction is present

TryGetWordDocument / ReadBodyText path matches final Production
```

Decision:

### Current module is older / differs materially

Classification:

```text
Workbook Production Drift
/
Wrong Production Source
```

Action:

```text
restore approved P1-07 v0.1.1 source
→ Compile
→ P1-02 Warm Regression
→ P1-02 Cold Regression
→ RunManualSync
```

### Current module matches approved source

Continue to timing / lifecycle investigation.

---

# 11. Step 6 — Re-run P1-02 Regression

Use existing test entry points if still available:

```text
TestP102InspectorWordEditorWarmStart
TestP102InspectorWordEditorColdStart
```

Expected historical result:

```text
Warm:
PASS

Cold:
PASS
```

This isolates:

```text
Outlook Adapter
```

from:

```text
P2-04 / P2-05 orchestration
```

Decision:

### P1-02 regression FAIL

Finding belongs primarily to:

```text
modOutlookAdapter / P1 infrastructure regression
```

P2-05 should not patch around it in UI.

### P1-02 regression PASS but RunManualSync FAIL

Investigate P2-04 integration sequence:

```text
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
```

against the P1-02 smoke path:

```text
CreateMailFromTemplate
↓
ReadBodyText
```

No UI correction should be made unless evidence points to UI.

---

# 12. Potential Correction Direction — Only If Evidence Supports It

If evidence proves:

```text
Warm PASS
Cold first-run FAIL
Cold immediate second-run PASS
```

then evaluate a bounded readiness confirmation inside:

```text
modOutlookAdapter.EnsureOutlookReady
```

after:

```text
Explorer.Display
```

and before:

```text
CreateItemFromTemplate / WordEditor access
```

Preferred principle:

```text
verify readiness condition
```

rather than:

```text
fixed arbitrary Sleep
```

Any correction must remain inside the existing Outlook Adapter responsibility.

It must not add automatic Manual Sync retry.

---

# 13. P2-05 Verification Control

Current Verification status:

```text
P05-I09:
PASS candidate for P2-05 UI failure presentation

P05-I01-I08:
SUCCESS-PATH / FIXTURE VERIFICATION PAUSED

P05-I16:
PAUSED

P05-I17:
PASS

K01-K04:
PASS

IF-P2-05-001:
OPEN
```

Do not start P2-05 Regression or Final Static Review until the finding is resolved or formally classified as non-production.

---

# 14. Next Immediate Action

Execute only this first:

```text
Same Excel session
↓
RunManualSync again once
```

Then report:

```text
1. Second run PASS or FAIL
2. Whether Classic Outlook was already running before the first run
3. Whether an Outlook Explorer window appeared after the first failure
```

Those three facts determine the next branch with minimal disturbance to the environment.

---

## Summary

The P2-05 Fail-Closed UI behaved correctly: it converted the underlying WordEditor failure into a controlled failure notification and did not produce a false success.

The failure point is localized to `Inspector.WordEditor`, but the root cause is not yet proven. Historical evidence shows that Cold Start requires a visible Outlook Explorer and that the approved P1-07 production previously passed both Warm and Cold WordEditor regression. A stale Outlook Application reference was also previously found and corrected.

Therefore the next action is not to change P2-05 code. The correct sequence is to separate Warm / Cold behavior, check same-session retry behavior, confirm the actual `modOutlookAdapter` production version, and rerun the existing P1-02 Warm / Cold regression before designing any correction.
