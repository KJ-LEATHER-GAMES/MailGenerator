# P3-05 Input State — Working Candidate Package v0.1

- Date: 2026-11-21
- Status: WORKING CANDIDATE / NOT APPROVED / NOT IMPORTED
- Baseline: BL-MVP-004 (unchanged)
- Scope: standalone Input State module, unit fixture, static review
- Excluded: P3-04 UI wiring, Form restore/Clear, XU-01 Runtime, P2/Production, GitHub, Excel/Outlook, Formal Gate

## Contents

- `src/modInputState_P3-05_Candidate_v0.1_CP932.bas` — VBA standard module candidate, CP932/CRLF
- `tests/modP305InputStateCandidateTests_v0.1_CP932.bas` — isolated unit-test runner (requires existing P0 modResult and classes)
- `docs/P3-05_Input_State_Unit_Specification_Candidate_v0.1.md` — contract and traceability
- `docs/P3-05_Input_State_Source_Review_v0.1.md` — source-review results and open findings
- `verification/P3-05_Static_Audit_20261121.json` — source-only verification log
- `verification/static_audit.py` — reproducible source checks, Python 3 standard library
- `SOURCE_MANIFEST.md` — file hashes and provenance

Never import the test fixture into the production workbook without an approved isolated test plan. No VBA Compile/Runtime results are included.

## Suggested project destinations (not committed)

- `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/` — code and candidate specification
- `MailGenerator/tests/vba/P3_Configuration_UserForm/` — isolated test fixture
- `MailGenerator/Docs/00_project_control/reviews/` — review and static evidence
