# P3-01 Configuration Validator — Production / Test Fixture Candidate Review v0.1

> Status: **WORKING CANDIDATE / NOT APPROVED / NOT COMPILED / NOT RUN**  
> Date: 2026-11-15  
> Unit: P3-01 Configuration Validator / P3正式Phase開始前のSource Preparation  
> Phase: **P2 Closure / CP-P2未成立。P3正式開始ではない。**

## 1. Purpose & Inputs

Prior working source: `P3-01_Configuration_Validator_Implementation_Preparation_Candidate_v0.1.md` (the source of V01–V13 and DEV-P3CFG-01–22). Approved references (read-only, GitHub):

- `DOC-MVP-REQ v0.1.9`: `FR-REQ-001`, `FR-TYPE-DATE-004`, `FR-OPT-002`, `FR-UI-003`, `FR-UI-CHECK-001/002`.
- `DOC-MVP-DES v0.1.10`: §§7.3, 16.1–16.4, 24, 25.2.
- `DOC-MVP-TESTSPEC v0.1.6`: `MTS-CFG-001～008` (**formal execution has not occurred**).
- `DOC-MVP-IMPL v0.4`: §8.4 P3, baseline `BL-MVP-004`.
- Existing carriers: `modTemplateScanner` (P2-01), `modVariableDefinitionData` (P2-03), `modOptionMasterData` (P0), `modResult`, `COperationResult`, `CErrorInfo`.

## 2. Output files and intended repository locations (NOT committed)

| Artifact | Candidate repo path | Purpose |
|---|---|---|
| `modConfigurationValidator_P3-01_Candidate_v0.1.bas` | `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/` | Production-source candidate; module name `modConfigurationValidator` |
| `modP3_01ConfigurationValidatorCandidateTests_v0.1.bas` | `MailGenerator/tests/vba/P3_Configuration_UserForm/` | Isolated VBA fixture; manually callable test runner |
| This review | `MailGenerator/Docs/00_project_control/reviews/` | Evidence classification and candidate decisions |
| `STATIC_REVIEW.py` | Local package `Docs/` only | Reproducible source-only checks, not a VBA compiler |

VBA source encoding: **CP932**. Imported module names follow `Attribute VB_Name`, not the long artifact filenames. The two `.bas` files can be imported only after a separate approval into a **non-production test workbook**; they are not integrated into the existing Production workbook.

## 3. Minimal public contract

```vb
Public Function ValidateConfiguration( _
    ByVal templateExists As Boolean, _
    ByVal templateScanResult As Object, _
    ByVal allVariableDefinitions As Collection, _
    ByVal activeOptionsByGroup As Object _
) As COperationResult
```

**Input**: Current OFT existence flag, `TemplateScanResult` Dictionary (`ValidVariables`, `InvalidCandidates`, `Locations`), `GetAllVariableDefinitions` Collection of row dictionaries, and an Application-assembled Dictionary of `OptionGroup` → `GetActiveOptions` Collection.  
**Output**: Existing `COperationResult`, first error as `CErrorInfo` with `ErrorType/Message/Target`, or Success with empty errors. No Input/Workbook mutation.  
**Role separation**: Application must stop on Data Access/Scanner failure before calling Validator; previous failed `COperationResult` is passed through by the Application, **not** by this API. Application is responsible for creating/closing temporary Outlook MailItem, selecting source file, collecting Options, and withholding UserForm on failure.

### Core rules implemented

| Rule | Current candidate behavior |
|---|---|
| V01 | `templateExists=False` → `ConfigurationError` (`TemplatePath`) |
| V02 | Missing/wrong Scan carrier → `UnexpectedError` |
| V03 | InvalidCandidates present → `ConfigurationError` with first invalid candidate Target; no re-scan |
| V04/05 | `ValidVariables` set and Active Definition set equal ignoring VariableName case; no auto sync |
| V06 | Active `DisplayName` must not be empty/whitespace |
| V07 | Active `Type` must be exactly `Text/Date/Select` |
| V08 | Active `Required` must be explicitly True/False; False is valid |
| V09 | Active `SortOrder` must be numeric; equal values accepted, no sorting in Core |
| V10 | Date Format must exactly match one of 6 Approved strings |
| V11/12 | Select OptionSource nonblank, matching exact OptionGroup active-only snapshot with ≥1 item |
| V13 | Data Access/COM failures must be stopped/passed by future Application, outside this Core |

### Implementation details selected only in this candidate (NOT an Approved change)

1. **First-error return** (source-row order for setting checks). `Errors[]` batching may be added only by separate review. A failed case is never treated as Success.
2. **Required** accepts VBA Boolean True/False, numeric 1/0, text `true`/`false` (case-insensitive, trims text). Empty, Null, Excel error, other numeric/text are rejected. This mirrors existing `modOptionMasterData.ReadActiveValue` conventions. **It is a candidate choice**, not a newly approved rule.
3. **SortOrder** accepts `IsNumeric` scalar, including numeric strings, rejects blank, Boolean and malformed values. Duplicates are not errors. Numeric range, fractional order and locale acceptance need review; no unapproved numeric range restriction was introduced.
4. **Type/Date Format** use exact defined strings; no silent normalization. **VariableName** identity is case-insensitive. **OptionGroup** identity uses `vbBinaryCompare`, matching current `GetActiveOptions`, including if caller's Dictionary uses a different `CompareMode`.
5. **Carrier defense**: unexpected structure, duplicate VariableName, unknown Status, invalid Locations map, or an inactive/mismatched Option in a purported active-only Option snapshot fail closed. Unknown Status is a ConfigurationError candidate; no attempt is made to repair P2-managed metadata.
6. **Unused** is excluded from field-completeness validation, but its identity/status is read for full-set integrity. A Template variable still marked Unused prevents Success.
7. **No minimum variable count** is imposed when both Current Template and Active definitions are empty; Approved docs do not explicitly define that as an error.
8. **No direct I/O**: there are no Excel worksheet/table, Outlook, filesystem, `ExecuteManualSync`, `ApplySyncDiff`, `MsgBox`, or UserForm calls in this Production candidate.

These choices are not silent replacements for user-approved specs; they remain review candidates.

## 4. Test fixture classification: 22 existing local IDs

| Local ID | Included in VBA runner | Meaning / limitation |
|---|---|---|
| DEV-P3CFG-01 | Defined | Success; base matching configuration |
| 02 | Defined | Empty DisplayName → ConfigurationError |
| 03 | Defined, 2 variants | Empty / unsupported Type → ConfigurationError |
| 04 | Defined, 2 variants | Required blank fails / explicit False succeeds |
| 05 | Defined | Missing SortOrder fails |
| 06 | Defined, **Core-only** | Equal SortOrder succeeds; **UI stable sort not verified** |
| 07 | Defined, 6 variants | Every Approved Date Format succeeds |
| 08 | Defined | Invalid Date Format fails |
| 09 | Defined | Missing Select OptionSource fails |
| 10 | Defined | Group with zero Active options fails |
| 11 | Defined | Template has unregistered name → Fail, no write in Core |
| 12 | Defined | Active definition missing from Template → Fail |
| 13 | Defined | Incomplete Unused row ignored when unused by Template |
| 14 | Defined | Template variable with Unused row → Fail |
| 15 | Defined | VariableName case-insensitive match succeeds |
| 16 | Defined | InvalidCandidates → Fail; does not re-scan |
| 17 | Defined, **Core-only** | OFT existence flag false fails; physical OFT path read not verified |
| 18 | Defined, 3 variants | Missing Scan/Definition/Option carrier fail closed |
| 19 | **SKIP** | Data Access failure propagation needs Application integration |
| 20 | Defined, 4 variants | Missing Locations, duplicate Definition, unknown Status, invalid inactive Option snapshot |
| 21 | Defined, **Core-only** | Two Select rows share supplied Group; Application-level caching unverified |
| 22 | Defined, **limited footprint** | Two evaluations give Success, test-side shallow input footprint unchanged; not a complete deep mutation proof |

Fixture provides `RunP3_01ConfigurationValidatorCandidateTests()` as a manual entry; uses `Debug.Print`, no workbook events, no production calls. The fixture **has not been imported or executed**. Local ID numbering is not a new Formal Test ID.

## 5. Static evidence and remaining verification

Local static checker: `python Docs/STATIC_REVIEW.py` from package root (or execute absolute script path). 

- CP932 source decode/roundtrip: checked.
- Single Public Production API and balanced Function/Sub starts/ends: checked.
- Source text inspection of no forbidden I/O / UI / Sync APIs: checked.
- Return-type syntax, case comparison tokens, 6 Date strings and 22 test IDs: checked.
- No VBA execution, VBA Import, Excel/Outlook startup, VBA Compile, COM integration or formal MTS test: **performed NONE**.

**Explicit unfinished items**:

- VBIDE Compile and true VBA runtime verification, including type/property availability and VBA argument evaluation, are **NOT VERIFIED**.
- Application's creation of `activeOptionsByGroup`, Data Access failure propagation, P3 scan-only MailItem lifecycle, one-time UI notification and no UserForm on failure are **NOT IMPLEMENTED/NOT VERIFIED**.
- Stable sort by `SortOrder`, then `__RowIndex`, Dynamic UserForm, Input State are **P3 later units**.
- Future integration tests should verify that InvalidCandidates Target is rendered safely to users and that Excel workbook / Current Template remain unchanged.
- Candidate decisions (Required accepted forms, `SortOrder` numeric scalar, Status/Carrier error classification, first-error policy) need contract review before Production promotion.

## 6. Status and next action

| Boundary | Status |
|---|---|
| Candidate code / fixture created | **YES, working files only** |
| Source-level static checks | **PASS** (text checks only) |
| Local VBA test execution | **NOT RUN** |
| P3 Production integrated / formally approved | **NO** |
| P3 official Phase Entry | **NOT STARTED** |
| P2 Closure / CP-P2 | **NOT ESTABLISHED** |
| P2-05 Production change | **NONE** |
| S5-C formal Gate / S5 final Compile | **NOT APPROVED / NOT VERIFIED** |
| Isolation method selection / environment work | **NO CHANGE / NOT REOPENED** |
| GitHub commit / Baseline update | **NONE** |

**Next recommended unit**: review the 4 candidate implementation choices; then prepare a separate `P3 Configuration Validation Application Orchestration` source candidate that reads the Current Snapshot and passes errors without triggering Sync. It must not be described as P3 formal Phase Entry.

## 7. まとめ / Summary

**日本語**：P3-01のProduction候補とテストFixtureを新規作成した。静的確認のみ実施し、VBA実行・Compile・P2 Closure・P3正式開始は行っていない。

**English**: We created the P3-01 code and test fixture candidates. Only static source checks were done. VBA tests and Compile were not run. P2 is not closed, and P3 has not formally started.
