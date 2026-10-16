# P2-02 Sync Diff Core Regression Record v0.1

## 1. Document Information

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Parent Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Verification Type | Implementation / Regression Verification |
| Document Version | v0.1 |
| Record Date | 2026-10-10 |
| Document Status | **DRAFT — BASELINE / BUILD IDENTIFICATION PENDING** |
| Assertion Result | **PASS — 111 / 111; FAIL 0** |
| Formal MVP Test | **NOT CLAIMED** |
| Current Approved Baseline in existing supplied P2 records | `BL-MVP-003` |
| Execution Baseline printed in received runtime log | **`BL-MVP-004` — provenance not yet confirmed** |
| Build / Workbook / Commit ID | **NOT YET PROVIDED** |
| Pre-flight VBA Compile | **PASS — user-reported prior to this run (2026-10-10)** |

## 2. Scope and Source of Evidence

Regression target: P2-02 `BuildSyncDiff` classification, target metadata, failure guards, input immutability and P2-01/P0 carrier compatibility after P2-05 implementation.

Evidence reviewed: user-provided full execution transcript in the conversation on 2026-10-10, containing the `P2-02 v0.1.3 Regression Suite` output for six suites and a separate repeated Bootstrap output. This record is a review of that transcript; direct VBA source inspection or independent test execution was **not performed** by the reviewer. Archival log file path has **not yet been verified**.

Reference records:
- `P2-02 Sync Diff Core Completion Record v0.1.md`
- `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md`
- `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md`, Completion Criteria §59
- `AI協働開発 文書管理・Baseline運用ルール v0.1.md`
- `P2-02 Sync Diff Core Regression 実施チェックリスト v0.1.md`

## 3. Test Results

| Order | Suite | Expected PASS | Actual PASS | Actual FAIL | Overall |
|---:|---|---:|---:|---:|---|
| R1 | Bootstrap Metadata Regression | 33 | 33 | 0 | PASS |
| R2 | Detection History Regression | 43 | 43 | 0 | PASS |
| R3 | Excel Date Serial Compatibility Regression | 9 | 9 | 0 | PASS |
| R4 | Sync Diff Core Regression | 18 | 18 | 0 | PASS |
| R5 | Technical Negative Regression | 6 | 6 | 0 | PASS |
| R6 | Contract Compatibility Regression | 2 | 2 | 0 | PASS |
| **Total** | **6 Suites** | **111** | **111** | **0** | **PASS** |

All six child suites printed `Overall = PASS` in the supplied transcript. The final line `Expected aggregate assertions = 111 PASS / 0 FAIL` is an **expected-count declaration**, not an independently computed runner-level assertion. The six observed suite totals independently add to 111 and all showed zero failures.

After the wrapper output, a separate Bootstrap result was provided (`33 PASS, 0 FAIL`). This is recorded as a **repeat execution of R1**, not as 33 additional unique cases; official suite aggregate remains 111.

### R1 — Bootstrap Metadata (33/33)

- R01 / R02: Existing and Reactivated bootstrap initializes `TemplateLocation`, `FirstDetectedAt`, `LastDetectedAt` using current data and common timestamp.
- R03 / R04: Unused and Already-Unused behavior, including no-op and Empty metadata preservation.
- R05 / R06: Partial metadata fails without publishing `SyncDiffResult`.
- R07 / R08: Initialized Existing / Unused history and metadata preservation.

### R2 — Detection History (43/43)

- R09 / R10: Uninitialized Existing / Reactivated with nonblank Location succeeds and does not mutate inputs.
- R11 / R12: Uninitialized Unused and Already-Unused preserve appropriate metadata; no-op behavior.
- R13–R19: Partial / invalid date and invalid nonblank `TemplateLocation` fail without publishing `SyncDiffResult`.

### R3 — Date Serial (9/9)

- R20: Numeric Excel Date Serial inputs accepted; correct classifications and date preservation / timestamp update.

### R4 — Core (18/18)

- C1–C18: New / Existing / Reactivated / Unused, Already-Unused no-op, case-insensitive identity, canonical name, rename behavior, mixed classification, metadata, common timestamp, input and configuration immutability, empty-template behavior.

### R5 — Technical Negative (6/6)

- N1–N6: Nothing inputs, invalid candidates, duplicate definition identity, unknown status and structural invariant.

### R6 — Contract Compatibility (2/2)

- K1: P2-01 `ScanTemplate` carrier.
- K2: P0 `VariableDefinition` carrier.

## 4. Assessment

| Item | Result |
|---|---|
| Expected total 111 assertions | PASS |
| Six child `Overall = PASS` indicators | PASS |
| Observed FAIL / unexpected runtime error in supplied transcript | NONE |
| Confirmed new P2-02 Regression Defect in supplied transcript | NONE IDENTIFIED |
| Technical Negative / Fail Closed coverage represented by cases | PASS |
| Public Signature unchanged | **NOT INDEPENDENTLY VERIFIED against current Workbook** |
| Current Production Source / Build identified | **PENDING** |
| Baseline printed in log versus Approved Baseline reconciled | **PENDING** |
| Full runtime transcript archived under project | **PENDING USER CONFIRMATION** |
| Active / Blocking Finding globally zero | **PENDING FINAL ASSESSMENT** |

**Do not conflate test-label `v0.1.3` with current Production Module version.** Historical P2-02 Completion Record names `modSyncEngine_P2-02_v0.1_CP932.bas`, while later P2-04 Regression Evidence names `modSyncEngine_P2-02_v0.1.1_CP932.bas`. The current Workbook Module revision was not provided with this execution transcript.

## 5. Baseline Discrepancy — Open Record Item

**BR-P2-02-REG-001 — Execution Baseline provenance**

Observed runtime suite header:

```text
P2-02 v0.1.3 Regression Suite
Execution Baseline = BL-MVP-004
```

Existing supplied approved implementation documents identify `BL-MVP-003` as the execution baseline. The string `BL-MVP-004` also appears in the baseline-management rules as an **illustrative template**; it is not an approval record.

**Required resolution:**

1. Check Project Overview / Current Approved Baseline / Baseline Manifest / Approval Record to establish whether `BL-MVP-004` was actually Approved.
2. If Approved, record approval reference, baseline document versions and relationship/impact to this P2-02 regression. Do not silently relabel prior BL-MVP-003 records.
3. If current Approved Baseline remains `BL-MVP-003`, inspect whether the suite header hardcodes an incorrect display label. Correct test-artifact metadata/reporting with change control as appropriate. Preserve original transcript unchanged. A label correction alone does not justify a Production patch or automatic 111-case rerun; evaluate impact of any executable test change separately.
4. Record actual Workbook identification (filename/path), source revision or export, build/commit if applicable and observed execution date.

Classification: **Evidence / Configuration-Identification issue under assessment; not an established Production Defect.**

## 6. Evidence Preservation

- [ ] Preserve complete received wrapper output verbatim in an immutable test evidence file, e.g. `Evidence/P202_Regression_6Suites_20261010.txt`.
- [ ] Optionally preserve supplemental Bootstrap rerun separately as `Evidence/P202_Bootstrap_Rerun_20261010.txt`.
- [ ] Verify all six suite sections have their PASS counts, zero fails and `Overall = PASS` (already reviewed in supplied transcript).
- [ ] Record Workbook / build / Production Revision and `BuildSyncDiff` public signature check.
- [ ] Resolve `BR-P2-02-REG-001` and record Baseline approval/source of label.
- [ ] Verify Active / Blocking Finding classification (no new failed test was found here).

## 7. Closure Decision

```text
P2-02 Regression Test Assertions:
PASS — 111 / 111; FAIL 0

P2-02 Regression Record:
DRAFT / CLOSURE PENDING BASELINE & BUILD PROVENANCE

P2-05 Completion:
NOT CLAIMED

P2 Phase Completion:
NOT CLAIMED

CP-P2 Establishment:
NOT CLAIMED

Formal MVP Test PASS:
NOT CLAIMED
```

After evidence archive and baseline/source reconciliation are complete, update this **same record** with the confirmed effective baseline/build and, if no additional finding is identified, finalize `P2-02 Regression = PASS / CLOSED` without changing the immutable original test output.

## 8. Next Action

1. Resolve `BR-P2-02-REG-001` and identify tested Workbook / Production Source.
2. Preserve runtime transcript in the project and finalize this record.
3. Proceed with **P2-03 VariableDefinition Sync Persistence Regression**, with existing expectations:
   - Bootstrap 7/7
   - Detection History 6/6
   - Core 12/12
   - Technical Negative 18/18
   - Compatibility 3/3
   - Total **46/46 PASS**
4. Subsequently P2-04 Regression, Final VBA Compile, Static Review S01–S32, Production Patch Review, Final Finding Assessment and P2-05 Completion Decision.

## 9. Logical Project Destination

```text
定型メール作成ツール/
  P2-05 Fail Closed - Sync Result - Phase Integration/
    Regression/
      P2-02/
        P2-02 Sync Diff Core Regression Record v0.1.md
        Evidence/
```

This document is created as a downloadable artifact; it is **not automatically saved** into the user's OneDrive or Project folder.

## 10. まとめ / Summary

**日本語：** 提供された6 Suiteのログでは111/111 PASS、FAIL 0であり、P2-02 Regressionのテスト結果はPASS。Baselineラベル `BL-MVP-004` の出典が既存記録の `BL-MVP-003` と一致しないため、Baseline承認状態および実行Buildを照合してから正式CLOSEする。Production変更やテスト再実行は現時点では不要。

**English:** All six suites passed, totaling 111/111 checks with no failures. Confirm the baseline and tested build before formally closing the regression. No production change or test rerun is currently indicated by the evidence.
