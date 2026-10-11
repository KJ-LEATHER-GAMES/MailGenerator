# 定型メール作成ツール Project Document Registry and Approved Baseline v0.16

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v0.16 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 更新日 | 2026-10-11 |

### v0.16 更新概要

- DOC-MVP-IMPL v0.3をApproved Artifactとして最新存在版へ登録。Execution BaselineはBL-MVP-003である。
- v0.3 CandidateのPlan Consistency ReviewはPASS。BL-MVP-003に対するDOC-MVP-IMPL v0.2のAFFECTED / REVISION REQUIREDはv0.3により解消した。
- P1-02 Implementation Unit Specificationのv0.2改訂は別成果物として未受入であり、本Revisionに含めない。

### v0.15 更新概要

- BL-MVP-003 Baseline Approval Quality GateのPASSとApproval Recordに基づき、Current Approved BaselineをBL-MVP-003へ更新。BL-MVP-002はSupersededへ移行し、Historical BaselineとしてManifestを保持する。
- DOC-MVP-REQ v0.1.9、DOC-MVP-DES v0.1.9、DOC-MVP-TESTSPEC v0.1.5をBL-MVP-003のBaseline Versionへ採用。
- DOC-MVP-IMPL v0.2のBL-MVP-003 ImpactはAFFECTED / REVISION REQUIRED。Implementation PlanはBaseline Manifestへ追加せず、v0.3 Candidateの作成・整合性確認を後続作業とする。

### v0.14 更新概要

- DOC-MVP-REQ v0.1.9、DOC-MVP-DES v0.1.9、DOC-MVP-TESTSPEC v0.1.5をApproved Artifactとして最新存在版へ登録。3文書のCold Start Semantic Change整合性レビューはPASS。
- BL-MVP-003 Candidateを登録。Candidate Creation GateはPASSだが、Approvalは未実施のためCurrent Approved BaselineはBL-MVP-002を維持する。
- 既存Candidate版はレビュー時点の履歴として保持し、今回のApproved ArtifactやBaselineを置き換えるものではない。

### v0.13 更新概要

- DOC-MVP-TESTSPEC v0.1.5 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-TESTSPEC v0.1.4は維持する。
- v0.1.5はClassic Outlook Cold Start時のTest Variantを既存Test Caseへ反映するSemantic Test Definition Updateであり、Review / Not Yet BaselineのCandidateである。

### v0.12 更新概要

- DOC-MVP-DES v0.1.9 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-DES v0.1.8は維持する。
- v0.1.9はClassic Outlook Cold Start時のReadiness／Explorer初期化を定義するSemantic Design Changeであり、Review / Not Yet BaselineのCandidateである。Test Specificationへの反映と整合性確認は未完了。

### v0.11 更新概要

- DOC-MVP-REQ v0.1.9 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-REQ v0.1.8は維持する。
- v0.1.9はClassic Outlook Cold Start時の利用者向け挙動を確定するSemantic Changeであり、Review / Not Yet BaselineのCandidateである。

### v0.10 更新概要

- P1-02 Classic Outlook Cold Start Design / UX Impact Reviewを継続参照する影響レビューとして追加（Editorial / Governance Change）。
- レビューが示すRequirements／Design／Test Specificationの影響判定は、当該文書を改訂またはBaselineへ採用したことを意味しない。

### v0.9 更新概要

- TV-P1-02-001のResult RecordをTechnical Verification Result Recordとして参照に追加（Editorial / Governance Change）。
- Cold Start Technical VerificationのPASS / CLOSEDは当該記録の対象・時点に限定し、P1-02 OverallのNOT COMPLETE、Baseline Manifest、登録文書Revision・Statusは変更しない。

### v0.8 更新概要

- 管理フォルダ統合に伴い、共通ルールと台帳の現行リンクを更新（Editorial / Governance Change）。
- 共通ルールはプロジェクト内の単一ファイルとして保持。共通標準v0.1の本文・位置付けを維持。
- 登録文書Revision・Status、現行／過去Baseline Manifestは変更しない。

### v0.7 更新概要

- FS-05のEditorial / Governance Changeとして、文書の現行配置へのリンクを追加。
- 現在地・Next Actionを[Project Overview](Project_Overview.md)に集約。過去の実装・承認判断は元の記録を参照。
- 本文書の管理Revisionだけを更新。登録技術文書のRevision・Status、BL-MVP-002／BL-MVP-001のManifestと承認状態は変更しない。
- 改訂前v0.6はコミット `f310667:Docs/00_project_control/Document_Registry.md` から復元可能。過去進捗の全文コピーは追加しない。

### v0.6 更新概要（過去の記録）

- `DOC-MVP-IMPL v0.1 / BL-MVP-002 Impact Review v0.1` を実施し、`AFFECTED / REVISION REQUIRED` と判定
- Impact Reviewに基づき `Implementation Plan v0.2 Candidate` を最小差分で作成
- `Implementation Plan v0.2 Plan Consistency Review v0.1` を実施し、PASSと判定
- `DOC-MVP-IMPL v0.2` を正式Approved Artifactとして確定
- DOC-MVP-IMPLのLatest Versionを `v0.1 → v0.2` へ更新
- DOC-MVP-IMPLのExecution Baselineが `BL-MVP-002` と整合したことをProject Controlへ反映
- BL-MVP-002のManifest自体は変更なし
- BL-MVP-001はSupersededを維持
- Implementation Plan Impact ReviewをOpen ItemからCompletedへ変更
- P1-02開始前のBaseline / Plan Alignment Conflictを解消
- 次Actionを「新Workbook P0 Integration Regression（推奨）」→「P1-02 Inspector / WordEditor Connection」へ更新

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | [MVP Requirements v0.1.9](<../01_specifications/MVP Requirements v0.1.9 日本語版.md>) | v0.1.9 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | [MVP Design v0.1.9](<../01_specifications/MVP Design v0.1.9 日本語版.md>) | v0.1.9 | Approved | v0.1.8 | Design |
| DOC-TS-A | [Technical Spike A 実施仕様書](../01_specifications/technical_spikes/Technical%20Spike%20A%20実施仕様書.md) | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | [MVP Test Specification v0.1.5](<../01_specifications/MVP Test Specification v0.1.5 日本語版.md>) | v0.1.5 | Approved | v0.1.4 | Test Definition |
| DOC-MVP-IMPL | [Implementation Plan v0.3](<../02_implementation/Implementation Plan v0.3 日本語版.md>) | v0.3 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- Latest VersionとBaseline Versionは一致しなくてもよい。
- BL-MVP-003 Approvalにより、DOC-MVP-REQ v0.1.9 / DOC-MVP-DES v0.1.9 / DOC-TS-A v0.4 / DOC-MVP-TESTSPEC v0.1.5がCurrent Approved Baselineを構成する。
- Latest Approved Revisionが存在しても、Baseline Candidateの整合性確認とApprovalが完了するまではCurrent Approved Baselineへ自動採用しない。BL-MVP-003はこの条件を満たして承認済みである。
- DOC-MVP-IMPLはCurrent Approved Baseline Manifestの構成文書ではないため、Baseline Version欄は `—` を維持する。

---

## 3. Current Approved Baseline

```text
Baseline ID : BL-MVP-003
Status      : Approved
Approved On : 2026-09-19
```

### Baseline Manifest

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.9 | Approved |
| DOC-MVP-DES | v0.1.9 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.5 | Approved |

正式表現：

```text
BL-MVP-003
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.9
├─ DOC-MVP-DES      MVP Design v0.1.9
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.5
```

Approval Evidence：

[BL-MVP-003 Approval Record v0.1](baselines/BL-MVP-003_Approval_Record_v0.1.md)

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

### BL-MVP-002

```text
Baseline ID   : BL-MVP-002
Status        : Superseded
Approved On   : 2026-09-15
Superseded On : 2026-09-19
Superseded By : BL-MVP-003
```

Historical Manifest：

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.8 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.4 | Approved |

BL-MVP-002は削除・Invalidatedせず、BL-MVP-003承認前の正式Baselineとして保持する。

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

## 5. 記録と現在地の参照

| 情報 | 正本・記録 |
| --- | --- |
| 現在地・未解決事項・次作業 | [Project Overview](Project_Overview.md) |
| セッション再開手順 | [Current Handoff](../05_handoff/Current_Handoff.md) |
| 共通運用標準v0.1 | [文書管理・Baseline運用ルール](<rules/AI協働開発 文書管理・Baseline運用ルール.md>) |
| DF-P1-001 Close | [Close Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/DF-P1-001 Close Record v0.1.md>) |
| P1-01完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/P1-01 OFT Path Outlook Connection Completion Record v0.1.md>) |
| TV-P1-001正式判定 | [技術検証記録](../03_verification/technical_validation/TV-P1-001_正式判定.md) |
| TV-P1-02-001結果記録 | [Technical Verification Result Record](<../03_verification/technical_validation/TV-P1-02-001 Result Record v0.1.md>) |
| P1-02 Cold Start影響レビュー | [Design / UX Impact Review](<reviews/P1-02 Classic Outlook Cold Start Design UX Impact Review v0.1.md>) |
| Cold Start 3文書整合性 | [Cross-document Consistency Review](<reviews/Cold Start Semantic Change Cross-document Consistency Review v0.1.md>) |
| BL-MVP-003候補 | [Baseline Candidate](<baselines/BL-MVP-003 Candidate.md>) |
| BL-MVP-003承認記録 | [Baseline Approval Record](baselines/BL-MVP-003_Approval_Record_v0.1.md) |
| BL-MVP-003のImplementation影響 | [Impact Review](<reviews/DOC-MVP-IMPL v0.2 BL-MVP-003 Impact Review v0.1.md>) |
| Implementation Plan v0.3整合性 | [Plan Consistency Review](<reviews/Implementation Plan v0.3 Plan Consistency Review v0.1.md>) |
| Design／Test整合性 | [Cross-document Review](<reviews/MVP Design v0.1.8 × MVP Test Specification v0.1.4 Cross-document Consistency Review.md>) |
| Implementation Plan Impact | [Impact Review](<reviews/DOC-MVP-IMPL v0.1 BL-MVP-002 Impact Review v0.1.md>) |
| Implementation Plan整合性 | [Plan Consistency Review](<reviews/Implementation Plan v0.2 Plan Consistency Review v0.1.md>) |
| フォルダ移行の履歴 | [移動台帳](Folder_Structure_Migration_Inventory_v0.1.md) |

各記録のPASSは当該記録の対象・時点に適用される。現在のWorkbookのCompile／Regression判定は、本RegistryのBaseline承認からは導出しない。
