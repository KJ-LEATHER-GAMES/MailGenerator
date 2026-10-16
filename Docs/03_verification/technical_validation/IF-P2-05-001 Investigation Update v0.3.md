# IF-P2-05-001 WordEditor Access Failure
# Investigation Update v0.3

## 1. New Evidence

### P2-05 Runtime

`RunManualSync` executed twice in the same Excel session.

```text
Classic Outlook:
WARM before first run

First RunManualSync:
FAIL at WordEditor

Outlook after failure:
still running

Second RunManualSync:
same WordEditor failure
```

### Direct P1-02 Warm Regression

`TestP102InspectorWordEditorWarmStart`:

```text
CreateMailFromTemplate:
PASS

Explorer Count After Readiness:
1

ReadBodyText:
PASS

BodyText Length:
251

Inspector / WordEditor / Word Document:
PASS (indirect)

CloseWithoutSave:
PASS

Production Functional Path:
PASS

TestP102InspectorWordEditorWarmStart:
PASS
```

Therefore:

```text
modOutlookAdapter basic Warm path:
FUNCTIONAL
```

---

## 2. Current modOutlookAdapter Source Review

Reviewed current source:

```text
modOutlookAdapter_Current.bas
```

Confirmed:

```text
P1-07 v0.1.1 lifecycle correction comments present

DisplayMail success:
mMailItem = Nothing
mOutlookApp = Nothing

CloseWithoutSave:
mMailItem = Nothing
mOutlookApp = Nothing

EnsureOutlookReady failure:
mOutlookApp = Nothing

Warm path:
Existing Explorer Count > 0
→ immediate Success

Cold path:
Visible Explorer Display
→ DoEvents
→ Success

ReadSubject:
reads mMailItem.Subject only
does not close/display/replace MailItem

ReadBodyText:
TryGetWordDocument(mMailItem, wordDocument)

TryGetWordDocument:
mailItem.GetInspector
→ inspector.WordEditor
```

No obvious source drift or stale-reference correction loss was found.

---

## 3. Updated Root Cause Assessment

### Excluded / strongly deprioritized

```text
P2-05 UI defect as root cause
Cold Start first-run-only timing
Missing P1-07 stale-reference correction
Basic Warm WordEditor path failure
```

### Remaining primary possibilities

```text
A. Integration timing/context difference between
   P1-02 test harness and normal Manual Sync production path

B. ReadSubject → ReadBodyText current-sequence interaction
   in the current Outlook environment

C. Current workbook modSyncApplication differs from
   the reviewed P2-04 production source

D. Test-harness instrumentation unintentionally gives
   Outlook enough COM/event processing time before WordEditor access
```

---

## 4. Important Timing Observation

Current `EnsureOutlookReady` behavior:

```text
Warm:
Explorer Count > 0
→ return Success immediately
→ no DoEvents

Cold:
Explorer created and displayed
→ DoEvents
→ return Success
```

`CreateMailFromTemplate` then creates the OFT MailItem.

The normal Manual Sync path proceeds immediately:

```text
CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
→ GetInspector
→ WordEditor
```

The P1-02 Warm smoke test, however, records evidence between creation and body read:

```text
CreateMailFromTemplate
→ Explorer Count After Readiness evidence
→ Warm Existing Explorer Reuse evidence
→ ReadBodyText
```

Therefore there is a plausible instrumentation/timing hypothesis:

```text
Smoke Test evidence acquisition / elapsed time
may allow Outlook/WordEditor initialization to complete,
while the production Manual Sync path reaches WordEditor earlier.
```

This is a hypothesis, not yet proven.

---

## 5. Next Decisive Test

Run the current P1-03 snapshot test, because it exercises the same semantic order as P2-04:

```text
CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
```

Preferred entry:

```text
TestP103TemplateSnapshotWarmStart
```

If not present:

```text
TestP103TemplateSnapshotBoundary
```

### Branch A — P1-03 FAIL at WordEditor

Then the issue is localized to:

```text
CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
```

in the current environment.

Primary hypothesis becomes:

```text
WordEditor readiness/timing after OFT MailItem creation
```

Next action:

```text
create a diagnostic-only timing harness
(no production modification)
```

to compare:

```text
Immediate ReadBodyText
vs
DoEvents before ReadBodyText
```

No fixed Sleep and no automatic production retry.

### Branch B — P1-03 PASS

Then:

```text
ReadSubject → ReadBodyText sequence itself is functional.
```

Next action:

```text
export current workbook modSyncApplication
```

and compare the actual workbook source with approved P2-04 production.

If current source matches, create a minimal diagnostic harness reproducing the exact `ScanCurrentTemplate` sequence without test-evidence side effects.

---

## 6. Current Finding Status

```text
IF-P2-05-001:
OPEN

P2-05 Fail-Closed UI:
WORKING

P05-I09 failure-presentation behavior:
PASS candidate

P2-05 success-path verification:
PAUSED

Production correction:
NOT AUTHORIZED / NOT YET JUSTIFIED
```

---

## 7. Immediate Action

Execute:

```text
TestP103TemplateSnapshotWarmStart
```

or, if that macro is unavailable:

```text
TestP103TemplateSnapshotBoundary
```

Share the complete log.

This single test distinguishes a snapshot-sequence / readiness issue from a P2-04 orchestration-specific issue.
