# P2-01 Regression ReadBodyText Failure Triage Plan v0.1

## 1. Status

```text
P2-01 Core Regression:
PASS 11 / 11

Baseline OFT Integration:
FAIL at ReadBodyText

Recipient Exclusion Integration:
FAIL at ReadBodyText

Root Cause:
NOT YET PROVEN

Scanner Defect:
NOT INDICATED

Fixture Content Defect:
NOT INDICATED
```

---

## 2. Key Observations

### Baseline OFT

Observed manually:

```text
Subject contains:
{{ModelName}}
{{GateDate}}
{{modelname}}

Body contains:
{{ModelName}}
{{GateDate}}
{{Department}}
{{Comment}}
```

### MTS-SCAN-005 OFT

Observed manually:

```text
Subject:
{{ModelName}}

Body:
担当部署：{{Department}}

To:
{{RecipientTo}}

CC:
{{RecipientCc}}

BCC:
{{RecipientBcc}}
```

The current test module `modP201MtsScan005IntegTest_current.bas` expects exactly:

```text
VAR_SUBJECT = ModelName
VAR_BODY    = Department
VAR_TO      = RecipientTo
VAR_CC      = RecipientCc
VAR_BCC     = RecipientBcc
```

Therefore the MTS-SCAN-005 fixture is consistent with the test harness.

---

## 3. Failure Localization

Both integration tests reached:

```text
ResolveWorkbookRelativePath = PASS
CreateMailFromTemplate       = PASS
ReadSubject                  = PASS
ReadBodyText                 = FAIL
CloseWithoutSave             = PASS
```

This localizes the failure before `ScanTemplate`.

Therefore the current evidence does not indicate a defect in:

```text
modTemplateScanner
ValidVariables classification
InvalidCandidates classification
Locations merge
VariableDefinition
MTS-SCAN-005 fixture content
```

The common failing boundary is:

```text
modOutlookAdapter.ReadBodyText
↓
Inspector
↓
WordEditor
↓
Word Document
```

This is consistent with the previously tracked intermittent WordEditor observation, but exact cause is not yet proven.

---

## 4. Important Evidence Gap

The current P2-01 integration test helper logs only:

```text
ReadBodyText: FAIL
```

It does not print the underlying `COperationResult.Errors` details.

Therefore the current log does not establish whether the failure is:

```text
OutlookError / WordEditor
OutlookError / another Outlook target
UnexpectedError
or another mapped failure
```

Before changing Production Code, acquire ErrorType / Message / Target.

---

## 5. Immediate Action Plan

### Step 1 — End the contaminated session

The failed session was subsequently changed by manually opening OFT files in Outlook.

Therefore do not use the current session as pristine root-cause evidence.

Close without saving:

```text
MailTemplate.oft inspector
MailTemplate_MTS-SCAN-005.oft inspector
```

Then fully close:

```text
Excel
Classic Outlook
```

Confirm no unintended draft/template edits were saved.

### Step 2 — Establish Fresh Warm State

```text
1. Start Classic Outlook manually.
2. Confirm normal Explorer window is visible.
3. Open MailGeneratorNew.xlsm.
4. Do NOT run any P1 smoke test.
5. Do NOT manually open any OFT.
```

This reproduces the previously defined Fresh Warm boundary.

### Step 3 — Re-run Baseline OFT Integration first

Execute:

```vb
TestP201FullTemplateScannerBaselineOftIntegration
```

If PASS:

```text
Record as intermittent recurrence not reproduced on controlled rerun.
Then execute Recipient Exclusion Integration.
```

If FAIL again at ReadBodyText:

```text
Preserve the session.
Do not run P1-02 smoke test yet.
Proceed immediately to Step 4.
```

### Step 4 — Run the existing immediate WordEditor diagnostic

Execute:

```vb
TestP205DiagImmediateNoGuard
```

Do this before any P1 smoke test.

Capture the full Immediate Window output.

### Step 5 — Capture Result Error Details

For the failing `ReadBodyText` result, record:

```text
Success
Errors.Count
ErrorType
Message
Target
```

Preferred evidence example:

```text
ReadBodyText:
Success = False
ErrorType = OutlookError
Message = <mapped message>
Target = WordEditor
```

Do not infer `Target = WordEditor` unless actually observed.

### Step 6 — Only after Step 4/5, run P1-02 Warm Regression

Use the existing P1-02 Warm test.

Purpose:

```text
Determine whether the same adapter boundary succeeds immediately after the regression failure.
```

Interpretation:

```text
Baseline Integration FAIL
+ Immediate Diagnostic FAIL
+ P1-02 Warm FAIL
→ stronger evidence of active WordEditor / COM state failure

Baseline Integration FAIL
+ Immediate Diagnostic PASS
→ transient state already recovered; retain intermittent classification

Baseline Integration FAIL
+ P1-02 Warm PASS
→ integration/session sequencing difference remains candidate; root cause still not proven
```

---

## 6. Finding Handling

Current recommended classification:

```text
New Regression Finding Candidate:
RF-P2-01-001

Title:
ReadBodyText Failure During P2-01 Integration Regression

Linked Observation:
OBS-P2-05-002 Intermittent WordEditor E_FAIL

Status:
OPEN / UNDER INVESTIGATION
```

Do not classify as Production Defect yet.

Until resolved or dispositioned:

```text
P2-01 Regression:
NOT PASS

P2-05 Completion Decision:
BLOCKED
```

This is a regression-gate block, not yet proof of a scanner defect.

---

## 7. Production Change Rule

At this stage:

```text
Production Code Change:
DO NOT APPLY
```

Specifically, do not add yet:

```text
Sleep
Fixed delay
Retry loop
DoEvents patch
Automatic retry
New public API
```

First acquire failure details and controlled reproduction evidence.

---

## 8. Test Harness Improvement Candidate

The current `ResultSucceeded` helper can be improved in the TEST module only so that a failure prints `COperationResult.Errors`.

This is a Test Artifact improvement, not a Production change.

Suggested behavior:

```text
stageName: FAIL
Success = False
Error[1].ErrorType
Error[1].Message
Error[1].Target
```

Apply only if needed after the existing diagnostic is used; do not alter Production source to gain observability.

---

## 9. Decision Tree

```text
Correct OFT fixtures confirmed
↓
Fresh Warm controlled rerun
↓
ReadBodyText PASS?
├─ Yes
│   ├─ run Recipient Exclusion
│   └─ if both PASS, record intermittent non-reproduction and continue review
│
└─ No
    ↓
    Preserve session
    ↓
    TestP205DiagImmediateNoGuard
    ↓
    Capture ErrorType / Message / Target
    ↓
    P1-02 Warm Regression
    ↓
    Finding Assessment
```

---

## 10. Summary / まとめ

### 日本語

MTS-SCAN-005のBodyが `担当部署：{{Department}}` だけであることはTest Harnessの期待と一致しており、Fixture不備ではない。Baseline OFTも想定内容を持っている。両Integration Testが `CreateMailFromTemplate` と `ReadSubject` を通過し、`ReadBodyText` だけで失敗しているため、現時点の故障境界はScannerではなくOutlook Adapter / WordEditor側に限定できる。ただしErrorType / Message / Targetがログに出ていないため、正確なRoot Causeは未確定である。Fresh Warm状態で再現し、失敗した場合はP1 Smoke Testより先に `TestP205DiagImmediateNoGuard` を実行してEvidenceを取得する。

### English

The MTS-SCAN-005 body containing only `Department` matches the test harness, so the fixture is correct. The baseline OFT also has the expected content. Both integration tests pass template creation and subject reading but fail only at `ReadBodyText`, so the failure is localized to the Outlook Adapter / WordEditor boundary, not the scanner. The exact root cause is still unknown because ErrorType, Message, and Target were not captured. Reproduce in a Fresh Warm state and, if it fails, run `TestP205DiagImmediateNoGuard` before any P1 smoke test.
