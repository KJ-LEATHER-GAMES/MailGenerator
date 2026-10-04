# 定型メール作成ツール Project Document Registry and Approved Baseline v0.4

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v0.4 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 更新日 | 2026-09-15 |

### v0.4 更新概要

- DOC-MVP-TESTSPEC v0.1.4 CandidateとDOC-MVP-DES v0.1.8のCross-document Consistency Reviewを実施
- Semantic Conflictなし、Blocking Test Gapなし、Traceability Breakなしを確認
- Cross-document Consistency ReviewをPASSと判定
- DOC-MVP-TESTSPECのLatest Versionをv0.1.4へ更新
- DOC-MVP-TESTSPEC v0.1.4をApprovedとして登録
- Test Case総数69件を維持
- Current Approved Baseline BL-MVP-001は変更しない
- 次のBaseline管理ActionをBL-MVP-002 Candidate作成へ更新

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | MVP Requirements | v0.1.8 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | MVP Design | v0.1.8 | Approved | v0.1.7 | Design |
| DOC-TS-A | Technical Spike A 実施仕様書 | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification | v0.1.4 | Approved | v0.1.3 | Test Definition |
| DOC-MVP-IMPL | Implementation Plan | v0.1 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- Latest VersionとBaseline Versionは一致しなくてもよい。
- DOC-MVP-DES v0.1.8はLatest Approved Designだが、BL-MVP-001ではv0.1.7を維持する。
- DOC-MVP-TESTSPEC v0.1.4はLatest Approved Test Specificationだが、BL-MVP-001ではv0.1.3を維持する。
- Latest Approved Revisionが存在しても、Baseline Candidateの整合性確認とApprovalが完了するまではCurrent Approved Baselineを変更しない。

---

## 3. Current Approved Baseline

```text
Baseline ID : BL-MVP-001
Status      : Approved
Approved On : 2026-09-12
```

### Baseline Manifest

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.7 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.3 | Approved |

Current Approved Baselineは変更しない。

---

## 4. Execution / Implementation Status

### DF-P1-001

```text
Status: CLOSED
```

Evidence：

- TV-P1-001 PASS
- Resolver Smoke Test PASS
- P1-01 Regression PASS
- VBA Compile PASS

詳細は `DF-P1-001 Close Record v0.1` を参照する。

### P1-01 OFT Path / Outlook Connection

```text
Status: PASS / COMPLETE
```

詳細は `P1-01 OFT Path Outlook Connection Completion Record v0.1` を参照する。

---

## 5. Test Specification Status

DF-P1-001 Impact Review：

```text
DOC-MVP-TESTSPEC v0.1.3
Impact: AFFECTED
```

対応Revision：

```text
DOC-MVP-TESTSPEC v0.1.4
Status: Approved
```

反映内容：

- MTS-TPL-001のWorkbook Relative Path Resolution対応
- Windows Local Path / OneDrive Web URLの正常系Variant
- OneDrive Local Root候補0件 / Local Workbook Path候補0件 / 異なる候補複数件の異常系Variant
- ConfigurationError / Fail Fast / Error Evidenceの明示
- MTS-ERR-001のPath Resolution Error補強
- Test Case総数69件を維持

Cross-document Consistency Review：

```text
DOC-MVP-DES v0.1.8
×
DOC-MVP-TESTSPEC v0.1.4

Semantic Conflict    : NONE
Blocking Test Gap    : NONE
Traceability Break   : NONE
Consistency Review   : PASS
```

---

## 6. Baseline Update Gate

DOC-MVP-DES v0.1.8とDOC-MVP-TESTSPEC v0.1.4の整合性確認は完了した。

次のBaseline管理Action：

```text
BL-MVP-002 Candidate作成
↓
Baseline Manifest確認
↓
Baseline Quality Gate
↓
PASS
↓
BL-MVP-002 Approval
```

BL-MVP-002 CandidateをApprovedとするまでは、

```text
Current Approved Baseline = BL-MVP-001
```

を維持する。

想定するBL-MVP-002 Candidate構成：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

---

## 7. Current Development State

```text
P0 Foundation = COMPLETE
CP-P0 = ESTABLISHED

P1 Walking Skeleton = IN PROGRESS
P1-01 = PASS / COMPLETE
DF-P1-001 = CLOSED

Next Implementation Task:
P1-02 Inspector / WordEditor Connection

Document Management Open Item:
BL-MVP-002 Candidate作成
```

---

## 8. Source of Truth

| 情報 | Source of Truth |
|---|---|
| Requirement | DOC-MVP-REQ |
| Design | DOC-MVP-DES v0.1.8 (Latest) / v0.1.7 (BL-MVP-001) |
| Technical Evidence | DOC-TS-A |
| Test Definition | DOC-MVP-TESTSPEC v0.1.4 (Latest Approved) / v0.1.3 (BL-MVP-001) |
| Implementation Plan | DOC-MVP-IMPL |
| DF-P1-001 Close Evidence | DF-P1-001 Close Record v0.1 |
| P1-01 Completion Evidence | P1-01 OFT Path Outlook Connection Completion Record v0.1 |
| Approved Version Combination | BL-MVP-001 |

---

## 9. Current Control Result

```text
DF-P1-001                    : CLOSED
P1-01                         : PASS / COMPLETE
DOC-MVP-DES Latest            : v0.1.8 / Approved
DOC-MVP-TESTSPEC Latest       : v0.1.4 / Approved
DES × TESTSPEC Consistency    : PASS
Test Case Count               : 69
Current Approved Baseline     : BL-MVP-001 / MAINTAIN
BL-MVP-002                    : CANDIDATE NOT YET CREATED
```
