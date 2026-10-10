# 定型メール作成ツール Project Document Registry and Approved Baseline v0.5

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v0.5 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 更新日 | 2026-09-15 |

### v0.5 更新概要

- BL-MVP-002 CandidateのBaseline Manifestを確認
- Baseline Approval Quality Gateを実施しPASSと判定
- BL-MVP-002をApproved Baselineとして登録
- Current Approved BaselineをBL-MVP-001からBL-MVP-002へ更新
- BL-MVP-001をSupersededとしてHistorical Baselineへ移行
- DOC-MVP-DESのBaseline Versionをv0.1.7からv0.1.8へ更新
- DOC-MVP-TESTSPECのBaseline Versionをv0.1.3からv0.1.4へ更新
- DOC-MVP-REQ / DOC-TS-AのBaseline Versionは変更なし
- DOC-MVP-TESTSPEC v0.1.4の正式Approved Artifact確定を反映
- Test Case総数69件を維持
- BL-MVP-002 Baseline Approval Record v0.1をApproval Evidenceとして登録
- DOC-MVP-IMPL v0.1がExecution BaselineとしてBL-MVP-001を固定している点をImplementation Plan Impact Review対象として明示

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | MVP Requirements | v0.1.8 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | MVP Design | v0.1.8 | Approved | v0.1.8 | Design |
| DOC-TS-A | Technical Spike A 実施仕様書 | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification | v0.1.4 | Approved | v0.1.4 | Test Definition |
| DOC-MVP-IMPL | Implementation Plan | v0.1 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- Latest VersionとBaseline Versionは一致しなくてもよい。
- BL-MVP-002 Approvalにより、DOC-MVP-REQ / DOC-MVP-DES / DOC-TS-A / DOC-MVP-TESTSPECについてはLatest VersionとBaseline Versionが一致する。
- Latest Approved Revisionが存在しても、Baseline Candidateの整合性確認とApprovalが完了するまではCurrent Approved Baselineへ自動採用しない。
- DOC-MVP-IMPLはCurrent Approved Baseline Manifestの構成文書ではないため、Baseline Version欄は `—` を維持する。

---

## 3. Current Approved Baseline

```text
Baseline ID : BL-MVP-002
Status      : Approved
Approved On : 2026-09-15
```

### Baseline Manifest

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.8 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.4 | Approved |

正式表現：

```text
BL-MVP-002
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.8
├─ DOC-MVP-DES      MVP Design v0.1.8
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.4
```

Approval Evidence：

```text
BL-MVP-002 Baseline Approval Record v0.1
```

Baseline Approval Quality Gate：

```text
Blocking Requirement Gap : NONE
Blocking Design Gap      : NONE
Blocking Test Gap        : NONE
Semantic Conflict        : NONE
Traceability Break       : NONE
Quality Gate             : PASS
```

---

## 4. Historical Baseline

### BL-MVP-001

```text
Baseline ID   : BL-MVP-001
Status        : Superseded
Approved On   : 2026-09-12
Superseded By : BL-MVP-002
```

Historical Manifest：

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.7 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.3 | Approved |

BL-MVP-001は削除・Invalidatedせず、過去時点の正式Baselineとして保持する。

---

## 5. Execution / Implementation Status

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

### Workbook Reconstruction

旧Workbookの `Out of memory (Error 7)` 発生後、新WorkbookへProduction Assetを再構築済み。

再構築後に以下はPASS済み。

```text
Resolver Smoke Test
P1-01 Smoke Test
```

P0 Foundation全体のIntegration Regression再実行は未確認。

これはBL-MVP-002 ApprovalのBlocking条件ではなく、P1-02開始前のImplementation Health Check候補として扱う。

---

## 6. Test Specification Status

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

正式Approved Artifact：

```text
MVP Test Specification v0.1.4 日本語版.md
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
Requirement Impact   : NONE
Test Case Count      : 69
Consistency Review   : PASS
```

---

## 7. Baseline Approval Result

v0.4で定義したBaseline Update Flow：

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

について、すべて完了した。

結果：

```text
BL-MVP-002 Candidate        : CREATED
Baseline Manifest           : CONFIRMED
Baseline Approval Quality Gate : PASS
BL-MVP-002                  : APPROVED
BL-MVP-001                  : SUPERSEDED
```

Current Approved Baseline：

```text
BL-MVP-002
```

Baseline管理上のBlocking Open Itemはなし。

---

## 8. Implementation Plan Baseline Impact

### 現状

DOC-MVP-IMPL v0.1はApprovedであるが、文書内のExecution Baselineを以下として固定している。

```text
Execution Baseline:
BL-MVP-001
```

また、Implementation Principle `IMP-R01 Baseline Driven` では、実装判断をBL-MVP-001基準とすることを定義している。

一方、Current Approved Baselineは本v0.5で以下へ更新された。

```text
BL-MVP-002
```

### 判定

これはBL-MVP-002自体のApprovalを無効化する問題ではない。

ただし、P1-02以降のImplementationをどのBaseline基準で継続するかを曖昧にしないため、P1-02開始前にDOC-MVP-IMPLへの影響確認を行う。

```text
Implementation Plan Impact Review:
REQUIRED BEFORE P1-02
```

このv0.5ではDOC-MVP-IMPLの内容・Versionを推測で変更しない。

Impact Review結果に基づき、必要な場合のみDOC-MVP-IMPLをRevisionする。

---

## 9. Current Development State

```text
P0 Foundation = COMPLETE
CP-P0 = ESTABLISHED

P1 Walking Skeleton = IN PROGRESS
P1-01 = PASS / COMPLETE
DF-P1-001 = CLOSED
TV-P1-001 = PASS

Current Approved Baseline:
BL-MVP-002

Next Project Control Task:
DOC-MVP-IMPL Baseline Impact Review

Recommended Implementation Health Check:
New Workbook P0 Integration Regression

Next Implementation Task:
P1-02 Inspector / WordEditor Connection
```

---

## 10. Source of Truth

| 情報 | Source of Truth |
|---|---|
| Requirement | DOC-MVP-REQ v0.1.8 / BL-MVP-002 |
| Design | DOC-MVP-DES v0.1.8 / BL-MVP-002 |
| Technical Evidence | DOC-TS-A v0.4 / BL-MVP-002 |
| Test Definition | DOC-MVP-TESTSPEC v0.1.4 / BL-MVP-002 |
| Implementation Plan | DOC-MVP-IMPL v0.1 |
| DF-P1-001 Close Evidence | DF-P1-001 Close Record v0.1 |
| P1-01 Completion Evidence | P1-01 OFT Path Outlook Connection Completion Record v0.1 |
| Baseline Approval Evidence | BL-MVP-002 Baseline Approval Record v0.1 |
| Current Approved Version Combination | BL-MVP-002 |
| Historical Approved Version Combination | BL-MVP-001 / Superseded |

---

## 11. Current Control Result

```text
DF-P1-001                    : CLOSED
TV-P1-001                    : PASS
P1-01                        : PASS / COMPLETE
DOC-MVP-DES Latest           : v0.1.8 / Approved
DOC-MVP-TESTSPEC Latest      : v0.1.4 / Approved
DES × TESTSPEC Consistency   : PASS
Test Case Count              : 69

BL-MVP-001                   : SUPERSEDED
BL-MVP-002                   : APPROVED
Current Approved Baseline    : BL-MVP-002

Baseline Management Blocking Item:
NONE

Implementation Plan Impact Review:
REQUIRED BEFORE P1-02
```

---

## 12. Next Action

優先順：

```text
1. DOC-MVP-IMPL v0.1に対するBL-MVP-002 Impact Review
2. 必要に応じてImplementation Plan Revision
3. 新Workbook P0 Integration Regression（推奨）
4. P1-02 Inspector / WordEditor Connection
```

P0 Integration RegressionはBL-MVP-002 ApprovalのBlocking条件ではない。

P1-02開始前には、少なくともImplementation Planが参照するExecution BaselineとCurrent Approved Baselineの関係を明確化する。
