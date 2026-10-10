# 定型メール作成ツール Project Document Registry and Approved Baseline v0.2

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v0.2 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 確定日 | 2026-09-12 |

### v0.2 更新概要

- DOC-MVP-IMPL / Implementation Plan v0.1を内容レビューPASS後にDocument Registryへ追加
- DOC-MVP-IMPLのStatusをApprovedとして登録
- DOC-MVP-IMPLはBL-MVP-001をExecution Baselineとして参照するが、BL-MVP-001の構成文書には追加しない
- Current Approved Baseline `BL-MVP-001` のManifest / Version構成は変更なし

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | MVP Requirements | v0.1.8 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | MVP Design | v0.1.7 | Approved | v0.1.7 | Design |
| DOC-TS-A | Technical Spike A 実施仕様書 | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification | v0.1.3 | Approved | v0.1.3 | Test Definition |
| DOC-MVP-IMPL | Implementation Plan | v0.1 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- 今回はLatest VersionとBaseline Versionが一致する。
- 今後、新Revisionが作成されてもBaseline Approval完了まではBaseline Versionを自動更新しない。
- Technical Documents間の通常参照はDocument IDを使用する。
- Technical Spike実施時等のHistorical Execution Evidenceは、必要に応じて特定Versionを固定してよい。
- DOC-MVP-IMPLはBL-MVP-001をExecution Baselineとして固定する実行計画であり、BL-MVP-001のBaseline Manifest構成文書ではないためBaseline Versionは `—` とする。

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

正式なBaseline構成は以下とする。

```text
BL-MVP-001
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.8
├─ DOC-MVP-DES      MVP Design v0.1.7
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.3
```

---

## 4. Baseline Approval Basis

Baseline Approvalは、以下のMigration QA / Governance Consistency Review結果を根拠とする。

```text
Migration Gate                  : PASS
Governance Consistency          : PASS
Semantic Preservation           : PASS
Document Reference Integrity    : PASS
Ready for Document Registry     : YES
Ready for Baseline Approval Step: YES
```

追加確認結果：

| 項目 | 結果 |
|---|---|
| Requirement Gap | None |
| Design Gap | None |
| Test Gap | None |
| FR Traceability | 47 / 47 |
| Acceptance Criteria | 20 / 20 |
| NFR | 6 / 6 |
| Test Case一覧 | 69 |
| Test Case詳細 | 69 |
| Test ID欠落 | 0 |
| Test ID余分 | 0 |
| Test ID重複 | 0 |
| Route W / WordEditor | 維持 |
| Technical Spike A | CLOSED / PASS |
| Semantic Change from Governance Migration | None |

Approval Evidence：

- Baseline 4文書 Migration QA Correction Patch v0.1
- Baseline 4文書 Migration QA / Governance Consistency Review v0.2

---

## 5. Historical Baseline

Document Registry / Baseline ID運用開始前に、以下の4文書組合せが正式Baselineとして使用されていた。

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1.1
```

この組合せは、過去時点の再現性を確保するためHistorical Baselineとして保持する。

### Historical Baseline ID

既存運用時にはBaseline IDが付与されていなかったため、後付け採番は行わない。

表記：

```text
Pre-Registry Historical Baseline
```

`BL-MVP-001` は、本Document Registry / Baseline ID運用開始後に正式承認する最初のBaselineとする。

---

## 6. Source of Truth

| 情報 | Source of Truth |
|---|---|
| Requirement | DOC-MVP-REQ |
| Design | DOC-MVP-DES |
| Technical Evidence | DOC-TS-A |
| Test Definition | DOC-MVP-TESTSPEC |
| Implementation Plan | DOC-MVP-IMPL |
| Approved Version Combination | BL-MVP-001 / 本Baseline Manifest |
| Current Project State | Project Overview |
| Session Restart State | Latest Context Handoff |
| Future Test Execution Result | MVP Test Result |

---

## 7. Baseline運用ルール

1. `BL-MVP-001` をCurrent Approved Baselineとする。
2. 新しい文書Revisionが作成されても、Current Approved Baselineは自動変更しない。
3. 新BaselineはCross-document Consistency ReviewがPASSした場合のみApprovedにする。
4. Baseline IDは再利用しない。
5. 次回Baseline更新時は `BL-MVP-002` を採番する。
6. Project進捗・Next ActionはTechnical Documentsへ記載せず、Project Overview / Context Handoffで管理する。
7. Test実行時はTest ResultへBaseline IDを記録し、どのBaselineに対する結果かを固定する。

---

## 8. 確定結果

```text
Document Registry : ESTABLISHED
Baseline ID       : BL-MVP-001
Baseline Status   : APPROVED
Baseline Ready    : YES
Implementation Plan: DOC-MVP-IMPL v0.1 / APPROVED
```

本Baselineを、今後のImplementation Planning、VBA Implementation、およびMVP Testの正式な基準とする。
