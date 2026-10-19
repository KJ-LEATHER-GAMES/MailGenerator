# P2-04 I12 Evidence Archive Manifest v0.1 — Draft

## 1. Handling Policy

Original logs are immutable for audit. Some P2-04 output contains a Windows user profile path; do not publish unredacted raw logs to public GitHub. Store originals in a private/access-controlled Evidence location and record the original SHA-256 unchanged. If public sanitized copies are needed, track them as separate files with separate SHA-256 and an explicit transformation note.

## 2. Evidence Registry Candidate

| ID | Raw file | SHA-256 | Evidence |
|---|---|---|---|
| E-P202-RAW | `261018_P2-02_Regression Log.txt` | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` | P2-02 111/111; duplicate bootstrap excerpt excluded |
| E-P203-RAW | `261018_P2-03_Regression Log.txt` | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` | P2-03 46/46, five suite restored markers |
| E-P204-RAW | `261018_P2-04_Regression Log.txt` | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` | P2-04 182/182, I10 first ABORT + 20/20 pass |
| E-P204-SOURCE | `P2-04_Regression_20261018.zip` | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` | 9 Production source exports; GitHub 9/9 normalized match |
| E-P204-WB | `MailGeneratorNew.xlsm` | `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9` | **User-reported** SHA-256, binary not received |

### Provenance

- Reviewer can verify SHA-256 of received original logs and ZIP. Source ZIP is not the binary Workbook.
- Workbooks used in prior individual Regression sessions may not share same binary SHA even when Production Source is attested identical.
- `BL-MVP-004` approval record exists; GitHub Project Registry has different acceptance/synchronization context.
- I12 Evidence-Reuse policy was expressly accepted by the operator on 2026-10-19; do not claim 157 past tests are fresh 2026-10-18 assertions.
- Original sources still need final archiving/registry placement and git-reviewed document integration. No Repository write has been performed.

## 3. Proposed placement (subject to repository folder rules)

- `Docs/03_verification/technical_validation/` : Closure Reviews, Final I12 Assessment, Execution Policy Decision, Evidence Matrix.
- `Evidence/` : non-public raw files or access-restricted Evidence reference/manifest where permitted.
- `Docs/00_project_control/Document_Registry.md` : authoritative references and status only after full review. Preserve BL003 history/other-PC acceptance distinction.

## まとめ / Summary

**日本語**：原文4資産をSHA付きで一覧化。保管位置は未確定。原文と公開用加工版は分離。

**English**: Four source artifacts are indexed by hash; formal private evidence placement remains pending.
