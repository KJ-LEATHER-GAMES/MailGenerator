# BL-MVP-003 Baseline Candidate

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| Baseline ID | BL-MVP-003 |
| Status | **Candidate** |
| 対象プロジェクト | 定型メール作成ツール |
| Candidate作成日 | 2026-09-19 |
| Current Approved Baseline | BL-MVP-002 |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |

---

## 2. Baseline Manifest

```text
BL-MVP-003 Candidate
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.9
├─ DOC-MVP-DES      MVP Design v0.1.9
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.5
```

| Document ID | Version | Status | Role |
|---|---:|---|---|
| DOC-MVP-REQ | v0.1.9 | Approved | Requirement |
| DOC-MVP-DES | v0.1.9 | Approved | Design |
| DOC-TS-A | v0.4 | Closed / PASS | Technical Evidence |
| DOC-MVP-TESTSPEC | v0.1.5 | Approved | Test Definition |

---

## 3. BL-MVP-002との差分

### DOC-MVP-REQ

```text
v0.1.8
↓
v0.1.9
```

Change：

```text
Semantic Change
```

内容：

```text
Classic Outlook事前起動をユーザーへ要求しない
未起動時はツールが必要に応じてClassic Outlookを起動
Startup / Readiness Failureをユーザーへ通知
AC-019 Cold Start対応
```

### DOC-MVP-DES

```text
v0.1.8
↓
v0.1.9
```

Change：

```text
Semantic Design Change
```

内容：

```text
Classic Outlook Readiness
Cold Start Visible Explorer Initialization
Explorer / MailItem Lifecycle分離
Outlook Adapter責務追加
D18追加
Startup / Explorer Error設計
RISK-DES-002更新
```

### DOC-TS-A

```text
v0.4
↓
v0.4
```

Change：

```text
UNCHANGED
```

Technical Spike AはHistorical Technical Evidenceとして維持する。

### DOC-MVP-TESTSPEC

```text
v0.1.4
↓
v0.1.5
```

Change：

```text
Semantic Test Definition Update
```

内容：

```text
MTS-MAIL-001 Cold Start Variant
MTS-MAIL-003 Warm / Cold Lifecycle Variant
MTS-ERR-001 Startup / Explorer Error Message
MTS-ERR-002 Cold Start Initialization Failure Variant
MTS-NFR-005 Cold Start E2E Variant
```

Test ID総数：

```text
69
```

変更なし。

---

## 4. Technical Evidence

本Baseline CandidateのCold Start変更は以下のEvidenceに基づく。

```text
TV-P1-02-001
Classic Outlook Cold Start / WordEditor Initialization

TV-C01 Hidden Explorer:
FAIL

TV-C02 Visible Explorer:
PASS × 2

Scan MailItem Display:
NONE

Draft Residue:
NONE

Inspector Residue:
NONE

Result:
PASS / CLOSED
```

Technical Spike A：

```text
DOC-TS-A v0.4
CLOSED / PASS
Route W / WordEditor
```

はReopenしない。

---

## 5. Cross-document Consistency Review

対象：

```text
DOC-MVP-REQ      v0.1.9
DOC-MVP-DES      v0.1.9
DOC-MVP-TESTSPEC v0.1.5
```

Result：

```text
Blocking Requirement Gap : NONE
Blocking Design Gap      : NONE
Blocking Test Gap        : NONE
Semantic Conflict        : NONE
Traceability Break       : NONE
Test Case Count          : 69
Cross-document Review    : PASS
```

Evidence：

```text
DOC-MVP-REQ / DES / TESTSPEC Cold Start Semantic Change
Cross-document Consistency Review v0.1
```

---

## 6. Candidate Creation Gate

確認：

```text
Required Documents       : PRESENT
Target Versions          : IDENTIFIED
Requirement Gap          : NONE
Design Gap               : NONE
Test Gap                 : NONE
Semantic Conflict        : NONE
Traceability             : PASS
Impact Review            : COMPLETE
Technical Evidence       : AVAILABLE
Baseline ID Uniqueness   : PASS
```

判定：

```text
Candidate Creation Gate:
PASS
```

---

## 7. Current Approved Baseline

BL-MVP-003はCandidateであり、まだApprovedではない。

したがって現時点では以下を維持する。

```text
Current Approved Baseline:
BL-MVP-002
```

BL-MVP-002：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

BL-MVP-002をSupersededへ変更するのはBL-MVP-003 Approval後とする。

---

## 8. Implementation Plan

`DOC-MVP-IMPL v0.2` はBaseline Manifest構成文書ではないため、BL-MVP-003 Candidateへ含めない。

現時点：

```text
DOC-MVP-IMPL v0.2
Status: Approved
Execution Baseline: BL-MVP-002
```

BL-MVP-003 Approval前にExecution Baselineを自動変更しない。

BL-MVP-003がApprovedとなった場合は、Implementation Planに対するBaseline Impact Reviewを行い、必要なRevisionのみ実施する。

---

## 9. Candidate Status

```text
BL-MVP-003:
CANDIDATE

Cross-document Consistency:
PASS

Candidate Creation Gate:
PASS

Current Approved Baseline:
BL-MVP-002

Approval:
NOT YET PERFORMED
```

次のBaseline管理Gateは `Baseline Approval Quality Gate` とする。
