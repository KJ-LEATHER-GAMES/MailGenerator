# BL-MVP-002 Baseline Candidate

## 1. Baseline情報

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール |
| Baseline ID | BL-MVP-002 |
| Status | **Candidate** |
| 作成日 | 2026-09-15 |
| Baseline種別 | MVP Development / Verification Baseline |
| Current Approved Baseline | BL-MVP-001 |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 主目的 | DF-P1-001対応後のLatest Approved Technical Documentsを、次の正式Baseline候補として固定する |

---

## 2. Candidate作成目的

BL-MVP-001確立後、以下のSemantic Changeが発生した。

```text
DF-P1-001
OneDrive Local Path Resolution
```

これに伴い、

- DOC-MVP-DES
- DOC-MVP-TESTSPEC

が更新された。

一方、

- DOC-MVP-REQ
- DOC-TS-A

にはSemantic Changeを必要としないことが確認されている。

本Candidateは、DF-P1-001対応後の相互整合した最新版4文書を、新しいBaseline候補として固定することを目的とする。

本Candidate作成時点では、BL-MVP-001をCurrent Approved Baselineとして維持する。

---

## 3. Baseline Manifest

BL-MVP-002 Candidateの構成を以下とする。

| Document ID | Document | Candidate Version | Document Status | Role |
|---|---|---:|---|---|
| DOC-MVP-REQ | MVP Requirements | v0.1.8 | Approved | Requirement |
| DOC-MVP-DES | MVP Design | v0.1.8 | Approved | Design |
| DOC-TS-A | Technical Spike A 実施仕様書 | v0.4 | Closed / PASS | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification | v0.1.4 | Approved | Test Definition |

正式表現：

```text
BL-MVP-002 Candidate
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.8
├─ DOC-MVP-DES      MVP Design v0.1.8
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.4
```

---

## 4. BL-MVP-001からの変更

BL-MVP-001：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.7
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.3
```

BL-MVP-002 Candidate：

```text
DOC-MVP-REQ      v0.1.8   unchanged
DOC-MVP-DES      v0.1.8   updated
DOC-TS-A         v0.4     unchanged
DOC-MVP-TESTSPEC v0.1.4   updated
```

差分：

| Document ID | BL-MVP-001 | BL-MVP-002 Candidate | Change |
|---|---:|---:|---|
| DOC-MVP-REQ | v0.1.8 | v0.1.8 | None |
| DOC-MVP-DES | v0.1.7 | v0.1.8 | Semantic Design Change |
| DOC-TS-A | v0.4 | v0.4 | None |
| DOC-MVP-TESTSPEC | v0.1.3 | v0.1.4 | Semantic Test Definition Update |

---

## 5. Change Classification

### 5.1 DOC-MVP-REQ

```text
Version:
v0.1.8

Change for BL-MVP-002:
None
```

DF-P1-001による利用者向けRequirement変更はない。

Requirement Gapは発生していない。

---

### 5.2 DOC-MVP-DES

```text
Version:
v0.1.8

Change Type:
Semantic Design Change

Requirement Impact:
None
```

主な変更：

- OneDrive Web URL環境でのWorkbook Relative Path Resolution
- `d.docs.live.net` URLからOneDrive Local Sync Pathへの解決
- OneDrive Root候補の取得・一意判定
- `modSettingsData.ResolveWorkbookRelativePath` 責務明確化
- D17 `Workbook Relative Path Resolution` 追加

起点：

```text
DF-P1-001
```

Technical Verification：

```text
TV-P1-001 = PASS
```

---

### 5.3 DOC-TS-A

```text
Version:
v0.4

Status:
CLOSED / PASS

Change for BL-MVP-002:
None
```

Route W / WordEditorのTechnical Decisionは維持する。

DF-P1-001はOFT Path ResolutionのDesign Findingであり、Body処理方式に関するDOC-TS-AのTechnical Decisionを変更しない。

---

### 5.4 DOC-MVP-TESTSPEC

```text
Version:
v0.1.4

Status:
Approved

Change Type:
Semantic Test Definition Update

Requirement Impact:
None

Test Case Count:
69
```

主な変更：

- MTS-TPL-001へOneDrive Web URL正常系を追加
- OneDrive Root候補0件をResolution Failure Variantとして追加
- Local Workbook Path候補0件を追加
- 異なるLocal候補複数件を追加
- MTS-ERR-001へPath Resolution Errorを追加
- ConfigurationError / Message / Target / Fail Fastを明示
- 新規Test IDは追加しない

---

## 6. Cross-document Consistency Evidence

BL-MVP-002 Candidate作成に使用する既知Evidenceは以下とする。

### 6.1 Requirement Impact

```text
DF-P1-001
→ Requirement Impact: None
```

DOC-MVP-REQ v0.1.8を維持する。

### 6.2 Design → Test Specification

DOC-MVP-DES v0.1.8とDOC-MVP-TESTSPEC v0.1.4の再整合性レビュー結果：

```text
Semantic Conflict:
NONE

Blocking Test Gap:
NONE

Traceability Break:
NONE

Requirement Impact:
NONE

Test Case Count:
69

Cross-document Consistency:
PASS
```

### 6.3 Technical Evidence

```text
DOC-TS-A v0.4
Status: CLOSED / PASS
Route: Route W / WordEditor
```

Body処理Technical Decisionへの影響なし。

### 6.4 Implementation Finding

```text
DF-P1-001:
CLOSED

TV-P1-001:
PASS

P1-01:
PASS / COMPLETE
```

OneDrive Local Path Resolutionを含むP1-01 Production FlowについてRegression PASS済み。

---

## 7. Candidate Creation Gate

BL-MVP-002 Candidateを作成するための条件を確認する。

| Check | Result |
|---|---|
| Baseline IDが一意 | PASS |
| 必要4文書を特定可能 | PASS |
| DOC-MVP-REQ v0.1.8 | PASS |
| DOC-MVP-DES v0.1.8 | PASS |
| DOC-TS-A v0.4 CLOSED / PASS | PASS |
| DOC-MVP-TESTSPEC v0.1.4 Approved | PASS |
| Requirement Impact確認済み | PASS |
| Design → Test Impact Review完了 | PASS |
| Blocking Requirement Gap | NONE |
| Blocking Design Gap | NONE |
| Blocking Test Gap | NONE |
| Semantic Conflict | NONE |
| Traceability Break | NONE |
| Test Case Count | 69 |
| DF-P1-001 | CLOSED |
| P1-01 | PASS / COMPLETE |

**Candidate Creation Gate：PASS**

したがって、BL-MVP-002をBaseline Candidateとして登録可能とする。

---

## 8. Baseline Approval Quality Gate

BL-MVP-002を `Candidate → Approved` とする前に、以下を最終確認する。

- [ ] Document Registryが最新状態である
- [ ] Baseline Manifestの4文書VersionがRegistryと一致する
- [ ] 4文書のDocument StatusがBaseline採用可能な状態である
- [ ] Blocking Requirement Gapがない
- [ ] Blocking Design Gapがない
- [ ] Blocking Test Gapがない
- [ ] 既知Semantic Conflictがない
- [ ] 必要なTraceabilityが成立している
- [ ] DOC-MVP-DES v0.1.8のSemantic Change Impact Reviewが完了している
- [ ] DOC-MVP-TESTSPEC v0.1.4がそのDesign Changeを反映している
- [ ] Test SpecificationとTest Resultを混同していない
- [ ] Project進捗がTechnical Documentへ不適切に混入していない
- [ ] Baseline ID `BL-MVP-002` が再利用されていない

判定：

```text
全項目PASS
↓
BL-MVP-002 = Approved
```

FAILまたは未確認項目がある場合：

```text
BL-MVP-002 = Candidate維持
BL-MVP-001 = Current Approved Baseline維持
```

---

## 9. Approval時のProject Control更新

BL-MVP-002をApprovedとした場合、Project Controlを以下へ更新する。

### Current Approved Baseline

```text
BL-MVP-002
```

### BL-MVP-001

```text
Status:
Superseded
```

Historical BaselineとしてManifestは保持する。

### Document Registry Baseline Version

| Document ID | Baseline Version after BL-MVP-002 Approval |
|---|---:|
| DOC-MVP-REQ | v0.1.8 |
| DOC-MVP-DES | v0.1.8 |
| DOC-TS-A | v0.4 |
| DOC-MVP-TESTSPEC | v0.1.4 |

Latest VersionとBaseline Versionが一致する状態になる。

---

## 10. Baselineに含めない文書

BL-MVP-002のManifestは、技術的Source of Truthとなる4文書に限定する。

以下はBaseline Manifestへ追加しない。

- Implementation Plan
- P1-01 Completion Record
- DF-P1-001 Close Record
- TV-P1-001作業手順書 / Verification Code
- Production実装仕様
- Context Handoff
- Project Document Registry
- Smoke Test Module
- VBA Production Source

これらはExecution Plan / Evidence / Project Control / Implementation Assetとして参照可能だが、BL-MVP-002の構成Technical Documentsとはしない。

---

## 11. Candidate時点で決定しない事項

本Candidate作成だけでは以下を決定しない。

- BL-MVP-002のApproved化
- P0 Integration Regressionの実施結果
- P1-02のProduction実装仕様
- OneDrive Commercial環境の追加検証
- 複数OneDrive Account対応
- 旧Workbook破損原因の追加解析
- MVP Test実行結果

これらはそれぞれの責務・工程で扱う。

---

## 12. Candidate承認後の次Action

BL-MVP-002がApprovedになった後の推奨順序：

```text
BL-MVP-002 Approved
↓
Project Document Registry更新
↓
必要に応じて新Workbook P0 Integration Regression
↓
P1-02 Inspector / WordEditor Connection
```

P1-02では、以下のProduction Vertical Sliceを対象とする。

```text
Settings
↓
TemplatePath
↓
ResolveWorkbookRelativePath
↓
Local OFT Path
↓
modOutlookAdapter
↓
MailItem
↓
Inspector
↓
WordEditor
```

---

# Candidate判定

```text
Baseline ID:
BL-MVP-002

Status:
Candidate

Candidate Creation Gate:
PASS

Current Approved Baseline:
BL-MVP-001

Approval:
NOT YET PERFORMED
```

BL-MVP-002は、正式Approved Baselineへの昇格判定を実施できる状態とする。
