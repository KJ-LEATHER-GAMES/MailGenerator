# IF-P2-05-001 WordEditor Access Failure
# Investigation Update v0.5

## 1. New Evidence

### Timing Diagnostic

All three diagnostic variants passed.

```text
A Immediate / No File Guard:
PASS

B Immediate / With File Guard:
PASS

C DoEvents / With File Guard:
PASS
```

Common observed values:

```text
ReadSubject:
PASS

Subject Length:
49

ReadBodyText:
PASS

BodyText Length:
251

CloseWithoutSave:
PASS
```

### P1-03 Snapshot Smoke Test

Current source reviewed:

```text
modP1_03TemplateSnapshotSmokeTest_v0.1_CP932(1).bas
```

Current runtime result:

```text
CreateMailFromTemplate:
PASS

ReadSubject:
PASS

ReadBodyText:
PASS

Same Active MailItem Boundary:
CONFIRMED

Snapshot Boundary:
ESTABLISHED

CloseWithoutSave:
PASS

Overall:
PASS
```

---

## 2. Source Review Result

The P1-03 test performs a defensive `CloseWithoutSave()` before the positive-path fixture, then executes:

```text
GetSettingValue
→ ResolveWorkbookRelativePath
→ CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
→ CloseWithoutSave
```

It does not alter Production Outlook Adapter logic.

The P2-05 diagnostic A deliberately removed:

```text
File Guard
DoEvents before ReadBodyText
Debug.Print between Create / Subject / Body
```

and still passed.

Therefore the earlier hypothesis:

```text
P2-04 path is simply too fast and needs one DoEvents
```

is **NOT SUPPORTED** by the current evidence.

---

## 3. State Cleanup Review

`modOutlookAdapter.CloseWithoutSave()` clears:

```text
mMailItem
mOutlookApp
```

both on normal close and error cleanup.

`modSyncApplication.ScanCurrentTemplate()` calls `FailScanAndCleanup()` when `ReadBodyText()` fails, and that helper calls `CloseWithoutSave()` when a scan MailItem was created.

Therefore the two consecutive original `RunManualSync` failures cannot be explained simply by an Adapter module-level MailItem/Application reference that was never cleared.

The stale-reference hypothesis is further deprioritized.

---

## 4. Updated Root Cause Assessment

### Strongly excluded / deprioritized

```text
modUiController business logic
modSyncApplication source drift
ReadSubject → ReadBodyText incompatibility
Dir$ / file-existence guard
single missing DoEvents immediately before ReadBodyText
uncleared mMailItem after first failure
missing P1-07 stale-reference correction
```

### Current leading hypothesis

```text
Session-dependent Outlook / WordEditor initialization state
that existed before the first successful P1-02/P1-03 access
```

Rationale:

```text
Initial state:
RunManualSync FAIL
RunManualSync retry FAIL

Then:
P1-02 Warm Regression PASS

After that:
P1-03 PASS
Diagnostic A PASS
Diagnostic B PASS
Diagnostic C PASS
```

The important variable may therefore be:

```text
before vs after the first successful WordEditor connection
in the current Office session
```

rather than a single `DoEvents` inside the immediate production sequence.

This remains a hypothesis until reproduced from a fresh Office session.

---

## 5. Production Correction Decision

Current decision:

```text
Production Code Change:
DO NOT APPLY YET
```

No justified correction location has been proven.

In particular, do not yet add:

```text
DoEvents to modSyncApplication
DoEvents to modOutlookAdapter
fixed Sleep
retry loop
automatic Manual Sync retry
```

A correction made now would be speculative.

---

## 6. Next Decisive Verification — Fresh Warm Session

Use a clean process state.

### Preparation

```text
1. Close Excel completely.
2. Exit Classic Outlook completely.
3. Reopen Classic Outlook manually.
4. Wait until one normal Explorer window is fully visible.
5. Open MailGeneratorNew.xlsm.
6. Do NOT execute any P1 smoke test or timing diagnostic first.
```

### Test FW-1

First WordEditor-related operation in the fresh workbook session:

```text
RunManualSync
```

Record:

```text
PASS / WordEditor FAIL
```

### If FW-1 FAIL

Without closing Excel/Outlook and before running any P1 test:

```text
TestP205DiagImmediateNoGuard
```

Record:

```text
PASS / FAIL
```

Then, only if ImmediateNoGuard also fails:

```text
TestP205DiagDoEventsWithGuard
```

### Interpretation

#### RunManualSync FAIL / Diagnostic A PASS

```text
Generic WordEditor initialization alone does not explain the issue.

Focus:
exact ExecuteManualSync / ScanCurrentTemplate call context.
```

Next action:

```text
diagnostic wrapper calling ExecuteManualSync directly
without modUiController presentation
```

#### RunManualSync FAIL / Diagnostic A FAIL / Diagnostic C PASS

```text
Fresh-session WordEditor readiness / event-pump issue strongly supported.
```

Correction ownership:

```text
modOutlookAdapter
```

Then design bounded readiness logic.

#### RunManualSync FAIL / Diagnostic A FAIL / Diagnostic C FAIL

```text
Single DoEvents is insufficient.
```

Next:

```text
diagnose Inspector / WordEditor availability transition
inside test artifact
```

No Sleep / blind retry.

#### RunManualSync PASS

The original failure is not reproduced in the fresh Warm state.

Repeat the same Fresh Warm sequence at least once more before closing the finding.

---

## 7. Optional Direct Application Isolation

Only if:

```text
RunManualSync FAIL
+
Diagnostic A PASS
```

create / run a test-only wrapper:

```text
ExecuteManualSync
directly
```

Purpose:

```text
modUiController call context
vs
Application orchestration
```

This wrapper must remain a Test Artifact and must not add Production hooks.

---

## 8. Additional Files

No additional Production file is required now.

Reviewed / available:

```text
modOutlookAdapter_Current.bas
modSyncApplication_Current.bas
modP1_03TemplateSnapshotSmokeTest_v0.1_CP932(1).bas
modP2_05WordEditorTimingDiagnostic_v0.1_CP932.bas
```

The P1-02 smoke-test source is not required for the next Fresh Warm reproduction, because its runtime behavior has already been established.

---

## 9. Current Finding State

```text
IF-P2-05-001:
OPEN

Root Cause:
NOT YET PROVEN

Timing / single-DoEvents hypothesis:
NOT SUPPORTED by current primed-session diagnostics

Session-dependent initialization hypothesis:
ACTIVE

Production Patch:
NONE

P2-05 Verification:
IN PROGRESS

Success-path verification:
PAUSED until fresh-session reproduction
```

## Summary

The three timing diagnostics and P1-03 snapshot test all pass, while the current Production sources are consistent with their established contracts. Therefore there is no evidence supporting an immediate code change to `modSyncApplication` or a blind `DoEvents` addition.

The most informative remaining variable is the Office session state before the first successful WordEditor connection. The next gate is a controlled Fresh Warm reproduction in which `RunManualSync` is deliberately the first WordEditor-related operation after restarting Excel and Outlook.
