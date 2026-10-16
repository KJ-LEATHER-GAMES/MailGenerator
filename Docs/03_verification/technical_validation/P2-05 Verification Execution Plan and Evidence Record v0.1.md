# P2-05 Fail Closed / Sync Result / Phase Integration
# Verification Execution Plan & Evidence Record v0.1

## 1. Status

```text
Execution Baseline:
BL-MVP-003

Production Candidate:
modUiController_P2-05_v0.1_CP932.bas

VBA Compile:
PASS

Verification Type:
Implementation Verification

Formal MVP Test:
NOT EXECUTED

P2-05 Verification:
IN PROGRESS
```

## 2. Evidence Strategy

Approved Specification requires `P05-I01～I17` applicable cases and `P05-K01～K04`.

### Runtime UI Integration
Execute actual `RunManualSync` production path for:

```text
I01 Mixed Result
I02 New Only
I03 Existing Only
I04 Reactivated Only
I05 Unused Only
I06 Zero-diff Success
I07 Invalid Candidate
I08 OFT Missing
I16 Fresh Retry
```

### Existing Failure Evidence + P2-05 Source Path
For:

```text
I09 Template / Scan Technical Failure
I10 Definition Read Failure
I11 BuildSyncDiff Failure
I12 ApplySyncDiff Failure
```

reuse established P2-04 failure-generation / propagation evidence and verify the current P2-05 common failure presentation branch.

This is evidence reuse plus current-source integration verification, not N/A.

### Defensive Technical Negative
For:

```text
I13 Success + syncDiffResult Nothing
I14 Success + templateScanResult Nothing
I15 Failure without displayable detail
```

verify the actual production source paths. Normal P2-04 production intentionally prevents these inconsistent input states, and Approved Specification prohibits production test hooks / public fault injection APIs.

This is `TECHNICAL NEGATIVE / SOURCE-PATH EVIDENCE`, not N/A.

### Static / Compatibility
Verify from current production source:

```text
I17 Manual Only
K01 ExecuteManualSync signature unchanged
K02 SyncDiffResult four-category carrier
K03 TemplateScanResult.InvalidCandidates direct use
K04 COperationResult / CErrorInfo reuse
```

## 3. Case Matrix

| Case | Method | Status |
|---|---|---|
| I01 | Runtime UI | NOT RUN |
| I02 | Runtime UI | NOT RUN |
| I03 | Runtime UI | NOT RUN |
| I04 | Runtime UI | NOT RUN |
| I05 | Runtime UI | NOT RUN |
| I06 | Runtime UI | NOT RUN |
| I07 | Runtime UI | NOT RUN |
| I08 | Runtime UI | NOT RUN |
| I09 | P2-04 Evidence + P2-05 Source Path | PENDING |
| I10 | P2-04 Evidence + P2-05 Source Path | PENDING |
| I11 | P2-04 Evidence + P2-05 Source Path | PENDING |
| I12 | P2-04 Evidence + P2-05 Source Path | PENDING |
| I13 | Technical Negative Source Path | PENDING |
| I14 | Technical Negative Source Path | PENDING |
| I15 | Technical Negative Source Path | PENDING |
| I16 | Runtime UI | NOT RUN |
| I17 | Static Source | PENDING |
| K01 | Contract Compatibility | PENDING |
| K02 | Contract Compatibility | PENDING |
| K03 | Contract Compatibility | PENDING |
| K04 | Contract Compatibility | PENDING |

## 4. First Runtime Check

Without changing the current template or VariableDefinition, execute:

```text
Excel
-> Alt + F8
-> RunManualSync
-> Run
```

Record:

```text
1. Exact displayed message
2. Notification count
3. New / Existing / Reactivated / Unused counts
4. Variable names shown
5. Any runtime error outside the notification
```

The observed current state determines which of I01～I05 can be closed immediately.

## 5. Runtime Expected Results

### I01 Mixed Result
`New > 0`, `Existing > 0`, `Reactivated > 0`, `Unused > 0`.

Expected: one success notification, four sections, all variable names visible.

### I02 New Only
Expected: New > 0, other three sections 0, success notification once.

### I03 Existing Only
Expected: Existing shown under `継続`, not under `復活`, success once.

### I04 Reactivated Only
Expected: Reactivated shown under `復活`, not merged into `継続`, success once.

### I05 Unused Only
Expected: Unused shown under `Unused化`, no UI-side deletion, success once.

### I06 Zero-diff Success
Expected:

```text
新規 = 0
継続 = 0
復活 = 0
Unused化 = 0
Success Notification = 1
```

A normal unchanged active template is not automatically zero-diff because active template variables normally classify as Existing.

### I07 Invalid Candidate
Expected: failure, invalid candidate strings visible, no success notification, no VariableDefinition update.

### I08 OFT Missing
Expected: one failure notification, no success notification, no VariableDefinition update.

### I16 Fresh Retry
Cause I07 or I08 failure, correct the cause, then manually execute again. The second execution must use current state and succeed if current state is valid.

## 6. Evidence Fields

For each runtime case record:

```text
Test Case ID
Initial Template State
Initial VariableDefinition State
User Action
COperationResult.Success if observable from supporting evidence
syncDiffResult existence if applicable
templateScanResult existence if applicable
Category Counts
Displayed Labels
Displayed Variable Names
Displayed InvalidCandidates
Failure Message / Target
VariableDefinition before / after
Notification Count
Actual Result
PASS / FAIL
```

## 7. Current Gate

```text
Production Implementation:
PASS / IMPORTED

VBA Compile:
PASS

P2-05 Verification:
IN PROGRESS

Regression:
NOT STARTED

Final Static Review:
NOT STARTED
```

Next action: execute `RunManualSync` once against the current workbook state and record the displayed result.
