# IF-P2-05-001 Investigation Update v0.4

## 1. New Evidence

`TestP103TemplateSnapshotBoundary` passed in the current workbook.

Observed:

```text
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: PASS
BodyText Length: 251
Same Active MailItem Boundary: CONFIRMED
Snapshot Boundary: ESTABLISHED
CloseWithoutSave: PASS
Overall: PASS
```

Therefore the established production sequence:

```text
CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
```

is functionally valid in the current environment.

---

## 2. Current modSyncApplication Review

Current source:

```text
modSyncApplication_Current.bas
```

was compared against the stored P2-04 production source:

```text
modSyncApplication_P2-04_v0.1_CP932(2).bas
```

Result:

```text
Line Count:
628 / 628

Semantic Difference:
NONE FOUND

Text Differences:
7

All 7 differences:
case-only member-name casing
(.Exists/.exists, .Item/.item, .Count/.count,
 Errors/errors, ErrorType/errorType, Target/target, Message/message)
```

These are not semantic differences in VBA.

The actual current P2-04 scan sequence remains:

```text
GetSettingValue
→ ResolveWorkbookRelativePath
→ ValidateTemplateFileExists
→ CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText
→ ScanTemplate
→ CloseWithoutSave
```

No source drift requiring a `modSyncApplication` correction was identified.

---

## 3. Root-cause Scope

The following are now strongly excluded as primary causes:

```text
P2-05 modUiController logic
Current modSyncApplication source drift
ReadSubject → ReadBodyText semantic incompatibility
Basic Warm WordEditor path failure
Cold Start first-run timing
Missing P1-07 stale-reference correction
```

The remaining strongest hypothesis is:

```text
execution timing / event-pump difference
between test harness execution and the fast P2-04 production path
```

Why:

```text
P1-02 Warm test:
PASS

P1-03 Snapshot test:
PASS

RunManualSync:
WordEditor E_FAIL

Current P2-04 source:
same approved sequence
```

The tests also perform diagnostic/evidence operations around the snapshot path, while `ScanCurrentTemplate` proceeds directly from one API call to the next.

This may give Outlook / WordEditor initialization more event-processing time in tests than in the production orchestration.

This is still a hypothesis and must be proven before Production correction.

---

## 4. Correction Location Assessment

### Do not patch modSyncApplication yet

Reason:

```text
WordEditor lifecycle / readiness
belongs to modOutlookAdapter.
```

Adding:

```text
DoEvents
Sleep
Retry
```

inside `modSyncApplication` would leak Outlook/Word COM readiness concerns into the Application layer.

### Candidate correction location if timing is proven

Preferred ownership:

```text
modOutlookAdapter
```

Candidate implementation points:

```text
A. immediately after CreateItemFromTemplate
or
B. inside WordEditor acquisition boundary before/around Inspector.WordEditor
```

Final choice requires diagnostic evidence.

Do not add:

```text
fixed Sleep
unlimited retry
Manual Sync automatic retry
```

---

## 5. Diagnostic Test

Created:

```text
modP2_05WordEditorTimingDiagnostic_v0.1_CP932.bas
```

This is a diagnostic-only test artifact.

It does not modify Production code.

### Case A

```text
CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText immediately

No file guard
No DoEvents
No Debug.Print between those calls
```

### Case B

```text
Dir$ file existence guard
→ CreateMailFromTemplate
→ ReadSubject
→ ReadBodyText immediately

No DoEvents
No Debug.Print between those calls
```

This most closely reproduces P2-04 pre-scan timing.

### Case C

```text
Dir$ file existence guard
→ CreateMailFromTemplate
→ ReadSubject
→ DoEvents
→ ReadBodyText
```

---

## 6. Interpretation Matrix

### A PASS / B FAIL

Suspect:

```text
ValidateTemplateFileExists / Dir$ interaction
```

This would be unexpected and requires direct confirmation before change.

### A FAIL / B FAIL / C PASS

Strongly supports:

```text
WordEditor event-pump / readiness timing
```

Likely correction belongs in `modOutlookAdapter`.

### A PASS / B PASS / C PASS

Timing harness does not reproduce the failure.

Next:

```text
instrument exact ExecuteManualSync / ScanCurrentTemplate path
without changing business logic
```

### A FAIL / B FAIL / C FAIL

A single `DoEvents` is insufficient.

Do not add Sleep.

Next investigate:

```text
Inspector creation state
WordEditor availability transition
bounded readiness condition
```

inside diagnostic/test code.

---

## 7. Required Files

At this point, no additional Production files are required.

Already available:

```text
modOutlookAdapter_Current.bas
modSyncApplication_Current.bas
```

If the diagnostic remains inconclusive, the next useful artifact would be the actual current:

```text
modP1_03TemplateSnapshotSmokeTest*.bas
```

to compare exact test-harness timing/evidence operations.

It is not required yet.

---

## 8. Current Gate State

```text
IF-P2-05-001:
OPEN

P2-05 Fail-Closed UI:
PASS candidate

P2-05 success-path verification:
PAUSED

Production correction:
NOT YET AUTHORIZED

Next:
Diagnostic timing test
```
