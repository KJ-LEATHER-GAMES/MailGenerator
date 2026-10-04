# 定型メール作成ツール Project Document Registry and Approved Baseline v0.3

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v0.3 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 更新日 | 2026-09-15 |

### v0.3 更新概要

- DOC-MVP-DESのLatest Versionをv0.1.8へ更新
- DOC-MVP-DES v0.1.8はDF-P1-001対応のSemantic Design Changeを反映
- DF-P1-001をCLOSEDとしてExecution Evidenceを確定
- P1-01 OFT Path / Outlook ConnectionをPASS / COMPLETEとしてImplementation Checkpointを確定
- DOC-MVP-TESTSPEC v0.1.3へのImpact Reviewを実施し `Affected` と判定
- DOC-MVP-TESTSPEC v0.1.4 Candidate作成が必要と判定
- Current Approved Baseline BL-MVP-001は変更しない

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | MVP Requirements | v0.1.8 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | MVP Design | v0.1.8 | Approved | v0.1.7 | Design |
| DOC-TS-A | Technical Spike A 実施仕様書 | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification | v0.1.3 | Approved | v0.1.3 | Test Definition |
| DOC-MVP-IMPL | Implementation Plan | v0.1 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- Latest VersionとBaseline Versionは一致しなくてもよい。
- DOC-MVP-DES v0.1.8はLatest Approved Designだが、BL-MVP-001ではv0.1.7を維持する。
- DOC-MVP-TESTSPEC v0.1.3はBL-MVP-001上ではApprovedを維持する。Latest Design v0.1.8とのImpact Review結果は別管理し、次Revision v0.1.4 Candidate作成をOpen Itemとする。

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

## 5. Test Specification Impact Status

Impact Review結果：

```text
DOC-MVP-TESTSPEC v0.1.3
Impact: AFFECTED
```

主な変更対象：

- MTS-TPL-001 Expected / Evidence / OneDrive Variant
- MTS-ERR-001 Path Resolution Error

新規Test IDは追加しない。

```text
Test Case Count: 69 → 69
```

次Revision Candidate：

```text
DOC-MVP-TESTSPEC v0.1.4
```

---

## 6. Baseline Update Gate

新Baselineはまだ作成しない。

次の順序で進める。

```text
DOC-MVP-TESTSPEC v0.1.4 Candidate作成
↓
Cross-document Consistency Review
↓
PASS
↓
BL-MVP-002 Candidate
↓
Approval
```

それまでは、

```text
Current Approved Baseline = BL-MVP-001
```

を維持する。

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
DOC-MVP-TESTSPEC v0.1.4 Candidate作成
```

---

## 8. Source of Truth

| 情報 | Source of Truth |
|---|---|
| Requirement | DOC-MVP-REQ |
| Design | DOC-MVP-DES v0.1.8 (Latest) / v0.1.7 (BL-MVP-001) |
| Technical Evidence | DOC-TS-A |
| Test Definition | DOC-MVP-TESTSPEC v0.1.3 until new revision approved |
| Implementation Plan | DOC-MVP-IMPL |
| DF-P1-001 Close Evidence | DF-P1-001 Close Record v0.1 |
| P1-01 Completion Evidence | P1-01 OFT Path Outlook Connection Completion Record v0.1 |
| Approved Version Combination | BL-MVP-001 |

---

## 9. Current Control Result

```text
DF-P1-001                : CLOSED
P1-01                     : PASS / COMPLETE
DOC-MVP-DES Latest        : v0.1.8 / Approved
DOC-MVP-TESTSPEC Impact   : AFFECTED
DOC-MVP-TESTSPEC Next     : v0.1.4 Candidate Required
Current Approved Baseline : BL-MVP-001 / MAINTAIN
BL-MVP-002                : NOT YET CREATED
```
