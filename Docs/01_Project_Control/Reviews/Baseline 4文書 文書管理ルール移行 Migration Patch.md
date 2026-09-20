# Baseline 4文書 文書管理ルール移行 Migration Patch v0.1

## 1. Patch情報

| 項目                        | 内容                                           |
| ------------------------- | -------------------------------------------- |
| Patch名                    | Baseline 4文書 文書管理ルール移行 Migration Patch       |
| バージョン                     | v0.1                                         |
| 対象プロジェクト                  | 定型メール作成ツール                                   |
| 変更分類                      | **Editorial / Governance Change**            |
| Semantic Change           | **なし**                                       |
| Requirement Change        | **なし**                                       |
| Design Decision Change    | **なし**                                       |
| Technical Decision Change | **なし**                                       |
| Test Definition Change    | **なし**                                       |
| 目的                        | `AI協働開発 文書管理・Baseline運用ルール v0.1` を既存4文書へ適用する |

---

# 2. 対象文書

本Migration Patchは以下の4文書を対象とする。

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1.1
```

本Patch適用によるRevision候補：

```text
MVP Requirements v0.1.7
MVP Design v0.1.6
Technical Spike A v0.3 CLOSED
MVP Test Specification v0.1.2
```

Technical Spike A v0.2 CLOSEDはHistorical Evidenceとして保存し、
v0.3 CLOSEDをGovernance Migration後のRevisionとする。

---

# 3. 本Migrationの原則

今回変更するのは以下のみとする。

1. Document ID付与
2. Current Version固定参照のDocument ID化
3. 現在地記述の削除
4. 次工程記述の削除
5. Next Action記述のProject Controlへの移動
6. Test実施状態のTest Specificationからの分離
7. 削除される章への内部参照修復
8. 文書責務表現の現在形への整理

以下には触れない。

* FR
* Acceptance Criteria
* NFR
* MVP Scope
* User-visible Behavior
* Design Component
* Design Sequence
* Data Model
* Validation Rule
* Error Rule
* Route W / WordEditor Technical Decision
* Technical Spike Evidence
* Test Case
* Test Expected Result
* Test Gate条件
* Traceability上の意味

---

# 4. Document ID

以下を正式Document IDとして付与する。

| Document ID        | Document               |
| ------------------ | ---------------------- |
| `DOC-MVP-REQ`      | MVP Requirements       |
| `DOC-MVP-DES`      | MVP Design             |
| `DOC-TS-A`         | Technical Spike A      |
| `DOC-MVP-TESTSPEC` | MVP Test Specification |

Document IDは以後Version Upしても変更しない。

---

# 5. 共通ルール

## 5.1 過去の改訂履歴

各文書の、

```text
v0.x.x 更新概要
```

に記載されている過去Version番号はHistorical Change Recordとして原則維持する。

これらはActiveな文書依存関係として扱わない。

したがって、

```text
v0.1.3ではMVP Requirements v0.1.2との整合性レビューを行った
```

等の履歴記述までDocument IDへ機械的置換しない。

---

## 5.2 Active Reference

現在有効な文書関係を示す参照はDocument IDへ置換する。

```text
MVP Requirements v0.1.6
```

ではなく、

```text
DOC-MVP-REQ
```

を使用する。

---

## 5.3 Historical Evidence

Technical Spike実行時に使用したRequirements / Design Versionは、

> 何を前提としてSpikeを実行したか

を再現するEvidenceであるためVersion固定を維持する。

---

# 6. MVP Requirements Migration

対象：

```text
MVP Requirements v0.1.6
→
MVP Requirements v0.1.7
```

---

## REQ-MIG-001 Document ID追加

### 対象

§1 文書情報

### 追加

```markdown
| Document ID | DOC-MVP-REQ |
```

### 分類

Editorial / Governance

---

# 7. Requirements §2 文書目的

## REQ-MIG-002 後続工程表現を責務表現へ変更

### 現行

```text
VBAのクラス構成、モジュール構成、具体的な制御実装等の詳細設計は、
本書では定義せず、後続のMVP Designで定義する。
```

### 置換

```text
VBAのクラス構成、モジュール構成、具体的な制御実装等の詳細設計は、
本書では定義せず、DOC-MVP-DESの責務とする。
```

### 理由

「後続」という工程状態を除去し、文書責務のみを残す。

### Semantic Change

なし。

---

# 8. Requirements §32

## REQ-MIG-003 章タイトル変更

### 現行

```text
## 32. 後続工程へ引き継ぐ事項
```

### 置換

```text
## 32. 文書責務境界
```

---

## REQ-MIG-004 導入文変更

### 現行

```text
本Requirementsでは利用者から見た振る舞いまでを定義し、
具体的な実現方式は責務に応じて後続工程へ引き継ぐ。
```

### 置換

```text
本Requirementsでは利用者から見た振る舞いまでを定義し、
具体的な実現方式は以下の文書・工程責務へ分離する。
```

---

## REQ-MIG-005 §32.1タイトル変更

### 現行

```text
### 32.1 MVP Designで具体化する事項
```

### 置換

```text
### 32.1 DOC-MVP-DESの責務とする事項
```

配下18項目は**変更しない**。

---

## REQ-MIG-006 §32.2タイトル変更

### 現行

```text
### 32.2 Implementationで具体化する事項
```

### 置換

```text
### 32.2 Implementationの責務とする事項
```

配下6項目は**変更しない**。

---

## REQ-MIG-007 §32.3タイトル変更

### 現行

```text
### 32.3 MVP Test Specificationで具体化する事項
```

### 置換

```text
### 32.3 DOC-MVP-TESTSPECの責務とする事項
```

配下の、

```text
Acceptance Criteriaを検証するテストケース設計
```

は変更しない。

---

# 9. Requirements §34

## REQ-MIG-008 §34「次工程」を全削除

以下を章単位で削除する。

```text
## 34. 次工程
```

および配下全文。

削除対象には以下を含む。

* Technical Spike A完了後の現在地
* Requirements / Design / Technical Spike AのVersion組合せ
* Design v0.1.4作成予定
* Test Specification v0.1作成予定
* 将来Baseline想定
* CR-001〜005の後続処理説明
* Test Specificationで追跡予定のTraceability
* TF-A-002の後続Testへの引継ぎ記述

### 移動先

以下だけをProject Overview / Context Handoff側で管理する。

```text
Current Approved Baseline
Current Phase
Current Status
Next Action
Open Items
```

TF-A-002に基づく実際のTest Definitionは、
既にDOC-MVP-TESTSPEC側に存在するためRequirementsへ残さない。

---

# 10. Requirementsで変更しない事項

以下は今回のMigration対象外とする。

特に§33の、

```text
入力値保持 | Excel終了まで
```

は、他文書との意味整合性確認が必要となる可能性があるが、
これはGovernance MigrationではなくSemantic / Consistency Review対象である。

**本Patchでは修正しない。**

---

# 11. MVP Design Migration

対象：

```text
MVP Design v0.1.5
→
MVP Design v0.1.6
```

---

## DES-MIG-001 Document ID追加

§1 文書情報へ追加。

```markdown
| Document ID | DOC-MVP-DES |
```

---

## DES-MIG-002 Requirements固定Version参照変更

### 現行

```markdown
| 要件文書 | MVP Requirements v0.1.6 日本語版 |
```

### 置換

```markdown
| 要件文書 | DOC-MVP-REQ |
```

---

# 12. Design §2 文書目的

## DES-MIG-003 Requirements参照変更

### 現行

```text
本書は、MVP Requirements v0.1.6を満たすためのMVP基本設計を定義する。
```

### 置換

```text
本書は、DOC-MVP-REQを満たすためのMVP基本設計を定義する。
```

---

# 13. Design §31 完了条件

## DES-MIG-004 自己Version固定表現削除

### 現行

```text
本Design v0.1.5は、以下を満たした時点で基本設計完了とする。
```

### 置換

```text
本Designは、以下を満たした時点で基本設計完了とする。
```

---

## DES-MIG-005 Requirements Version参照変更

### 現行

```text
Requirements v0.1.6の主要要件に対応するコンポーネントが定義されている
```

### 置換

```text
DOC-MVP-REQの主要要件に対応するコンポーネントが定義されている
```

その他の完了条件は変更しない。

---

# 14. Design §32

## DES-MIG-006 §32「次工程」を全削除

以下を章単位で削除する。

```text
## 32. 次工程
```

配下の以下をすべて削除する。

* Requirements / Design / Technical Spike AのVersion組合せ
* MVP Test Specification v0.1作成予定
* Technical Spike B / C
* Implementation Plan
* VBA実装
* Test Specificationで追跡予定のTraceability

### 移動先

Project Overview / Context Handoff：

```text
Open Item:
Technical Spike B / C 要否確認

Next Action:
Implementation Plan作成前にB / C要否を確認
```

Technical Spike B / Cの**実施決定は本Migrationでは行わない。**

---

# 15. Designで変更しない事項

以下は変更しない。

* §3〜30のDesign Definition
* Route W
* Outlook Adapter
* Template Scanner
* Sync Engine
* Configuration Validator
* Dynamic UserForm
* Input Validator
* Value Formatter
* Subject Renderer
* Word Range Body Render
* Unresolved Checker
* Error / Result Model
* Current Data Validation
* Risk
* Design Decision一覧
* Requirements Traceability

過去の更新概要に記録されている旧Version番号はHistorical Recordとして維持する。

---

# 16. Technical Spike A Migration

元Evidence：

```text
Technical Spike A v0.2 CLOSED
```

元文書はHistorical Evidenceとして変更せず保存する。

Governance Migration後：

```text
Technical Spike A v0.3 CLOSED
```

を作成する。

Technical Test Result / Evidence / Decisionはv0.2から変更しない。

---

## TSA-MIG-001 Document ID追加

§1 文書情報へ追加。

```markdown
| Document ID | DOC-TS-A |
```

---

## TSA-MIG-002 Execution Context固定Versionは維持

以下は**置換しない**。

```text
上位Requirements | MVP Requirements v0.1.4
上位Design       | MVP Design v0.1.2
```

理由：

これらはCurrent Version参照ではなく、

> Technical Spike Aをどの仕様・設計前提で実施したか

を示すHistorical Execution Evidenceだからである。

必要であれば項目名のみ次のように変更してよい。

```text
Execution Requirements
Execution Design
```

Version値は維持する。

---

# 17. Technical Spike §1

## TSA-MIG-003 「次工程」削除

文書情報の、

```text
| 次工程 | ... |
```

を削除する。

---

## TSA-MIG-004 Statusは維持

以下は削除しない。

```text
CLOSED
PASS
Route W / WordEditor
```

これらはProject ProgressではなくTechnical Spike自身のResultである。

---

# 18. Technical Spike §21

## TSA-MIG-005 「次アクション」削除

以下のSubsectionを削除する。

```text
### 次アクション
```

配下のAction 1〜5もTechnical Spike本文から削除する。

---

## TSA-MIG-006 Next Action移動判断

旧Action 1〜4：

```text
Requirements Patch
Design Reopen
整合性確認
Test Specification作成
```

は既に完了済みであり、Current Next ActionとしてProject Overviewへ移さない。

必要であればContext HandoffのCompletedへ要約する。

旧Action 5：

```text
OS / Excel / Classic Outlook等の詳細環境情報を後日追記
```

のみ未解決情報としてProject Overviewへ移動する。

推奨：

```text
Open Item:
Technical Spike A Environment Metadata補完

Priority:
Non-Blocking

対象:
OS
Excel Version
Excel Bitness
Classic Outlook Version
Outlook Bitness
VBA実行Workbook
実施者
```

---

# 19. Technical Spike §22

## TSA-MIG-007 完了条件からNext Action管理を削除

### 削除

```text
[x] 次アクションを記録済み
```

Technical Spike完了条件とはしない。

---

## TSA-MIG-008 Spike完了後フロー削除

以下を削除する。

```text
Spike完了後の標準フローは以下とする。
```

および配下フローチャート。

理由：

これはTechnical EvidenceではなくProject Process / Governanceである。

標準フローは、

```text
AI協働開発 基本運用プロセス
AI協働開発 文書管理・Baseline運用ルール
Project Overview
```

側で管理する。

---

## TSA-MIG-009 Requirement Gap復帰条件

末尾の、

```text
Requirement Gapが発生した場合のみ、Requirementsの利用者仕様判断へ戻る。
```

はTechnical Finding分類ルールとして意味を持つ場合は保持してよい。

ただし「次工程」の意味でのみ使用している場合は削除する。

本Migrationでは、

> Requirement Gap / Design Finding / Technical Findingの分類原則

自体は変更しない。

---

# 20. Technical Spikeで絶対に変更しないもの

以下はHistorical Evidenceとして固定する。

* TSA-001〜TSA-011
* Raw Evidence
* Route H結果
* Route W結果
* TF-A-001
* TF-A-002
* Requirements / Design Impact判定
* Route W採用
* PASS
* CLOSED
* Close Date
* Technical Decision根拠

---

# 21. MVP Test Specification Migration

対象：

```text
MVP Test Specification v0.1.1
→
MVP Test Specification v0.1.2
```

---

## TEST-MIG-001 Document ID追加

§1へ追加。

```markdown
| Document ID | DOC-MVP-TESTSPEC |
```

---

# 22. Test Specification §1文書情報

## TEST-MIG-002 Requirements Baseline置換

### 現行

```text
Requirements Baseline | MVP Requirements v0.1.6
```

### 置換

```text
Related Requirement | DOC-MVP-REQ
```

---

## TEST-MIG-003 Design Baseline置換

### 現行

```text
Design Baseline | MVP Design v0.1.5
```

### 置換

```text
Related Design | DOC-MVP-DES
```

---

## TEST-MIG-004 Technical Evidence置換

### 現行

```text
Technical Evidence | Technical Spike A 実施仕様書 v0.2 ...
```

### 置換

```text
Technical Evidence | DOC-TS-A
```

具体的VersionはCurrent Approved Baselineで解決する。

---

## TEST-MIG-005 実施状態削除

以下を削除する。

```text
| 実施状態 | 未実施 |
```

Test SpecificationはTest Definitionであり、
Test Execution Stateを持たない。

---

# 23. Test Specification §2

## TEST-MIG-006 PurposeのVersion参照変更

### 現行

```text
本書は、MVP Requirements v0.1.6およびMVP Design v0.1.5に定義された...
```

### 置換

```text
本書は、DOC-MVP-REQおよびDOC-MVP-DESに定義された
Requirement / Acceptance Criteria / Design Ruleが、
MVP実装上で成立していることを確認するためのテスト仕様を定義する。
```

---

## TEST-MIG-007 NOT RUN進捗記述削除

### 削除

```text
作成時点ではすべてのTest CaseをNOT RUNとする。
```

これはTest Execution Stateである。

---

## TEST-MIG-008 NOT RUN Status Definitionは維持

以下は削除しない。

```text
NOT RUN
PASS
FAIL
BLOCKED
N/A
```

これはTest Result Schemaであり、進捗そのものではない。

---

# 24. Test Specification §3

## TEST-MIG-009 「Baseline」章を論理参照へ変更

### 現行

```text
## 3. Baseline

本Test Specificationの入力Baselineは以下とする。

MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
```

### 置換

```markdown
## 3. Related Documents / Baseline Resolution

本Test Specificationの論理参照先は以下とする。

- DOC-MVP-REQ
- DOC-MVP-DES
- DOC-TS-A

Test実行時に適用する具体的なVersion組合せは、
Current Approved Baselineで解決する。

実際にTestしたBaseline IDはTest Resultへ記録する。
```

---

## TEST-MIG-010 §3.1 Requirements参照変更

### 現行

```text
MVP Requirements v0.1.6を正とする。
```

### 置換

```text
Requirement / Acceptance CriteriaのSource of Truthは
DOC-MVP-REQとする。
```

---

## TEST-MIG-011 §3.2 Design参照変更

### 現行

```text
MVP Design v0.1.5を正とする。
```

### 置換

```text
Design RuleのSource of TruthはDOC-MVP-DESとする。
```

---

## TEST-MIG-012 §3.3 Technical Spike

Technical Decision内容は変更しない。

参照先だけ、

```text
DOC-TS-A
```

とする。

Route W / WordEditor等のTechnical Decisionはそのまま保持する。

---

# 25. MTS-UNR-004参照修復

Design §32を削除すると、

```text
MTS-UNR-004 Scanner成立性とUnresolved 0件を独立判定
```

のTraceabilityに参照切れが生じる。

### 現行

```text
- Technical Spike TF-A-002
- Design §32
```

### 置換

```text
- DOC-TS-A / TF-A-002
- DOC-MVP-DES §14
- DOC-MVP-DES §23
```

理由：

* §14：Template Scanner
* §23：Unresolved Checker

のTechnical Definitionが直接のDesign根拠だからである。

Test A / Test B / PASS Rule自体は変更しない。

---

# 26. Test Specification §22 Entry Criteria

## TEST-MIG-013 Version固定Baseline条件を削除

### 現行

```text
MVP Requirements v0.1.6がBaseline
MVP Design v0.1.5がBaseline
Technical Spike A v0.2 CLOSED
```

### 置換

```text
- Current Approved Baselineが定義されている
- Current Approved BaselineにDOC-MVP-REQが含まれている
- Current Approved BaselineにDOC-MVP-DESが含まれている
- Current Approved BaselineにDOC-TS-AのCLOSED Technical Evidenceが含まれている
- Current Approved BaselineにDOC-MVP-TESTSPECが含まれている
```

以下のEntry Criteriaは変更しない。

* 実装対象Versionを識別可能
* Test用Excel / OFT準備済み
* Classic Outlook利用可能
* Baseline Test Data再現可能

---

# 27. Test Result記録テンプレート

§24は基本的に変更しない。

ただしTest Result実施時には文書管理ルールに従い、

```text
Baseline ID
Build ID
Commit ID（使用可能な場合）
Environment
```

を記録する。

本Migration PatchではTest Result Documentそのものは未作成のため、
Test Case DefinitionへSemantic Changeを加えない。

---

# 28. Test Specification §27

## TEST-MIG-014 §27「次工程」を全削除

以下を章単位で削除する。

```text
# 27. 次工程
```

削除対象：

```text
Test Specification最終整合性確認
Technical Spike B / C 要否確認
Implementation Plan v0.1
VBA実装
MVP Test実施
Test Result / Finding
MVP判定
```

および、

```text
Technical Spike B / Cの具体内容は...
```

の記述。

---

## TEST-MIG-015 Project Controlへ移動

Project Overview / Context Handoffへ以下を移動する。

```text
Current Phase:
Implementation Planning Preparation

Open Item:
Technical Spike B / C 要否確認

Next Action:
Technical Spike B / Cの必要性を確認する

Then:
Implementation Plan作成
VBA実装
MVP Test
```

これはTest Specificationへ戻さない。

---

# 29. Test Specificationで変更しないもの

以下は完全維持する。

* 69 Test Case
* Test ID
* Test Category
* Mandatory / Conditional
* Expected
* Precondition
* Evidence定義
* Acceptance Criteria Coverage
* FR Traceability
* NFR Traceability
* Safety Gate
* PASS / CONDITIONAL PASS / FAIL条件
* MTS-NFR-006 Mandatory Design Review
* Date Expected値
* Optional空欄Subject / Body Test
* OptionMaster Test
* UserForm実使用Variable数Test
* Technical Spike Regression方針

---

# 30. Project Controlへの移動情報

4文書から切り離したProject State情報は、
Project OverviewをSource of Truthとする。

最低限、以下を登録する。

## 30.1 Document Registry

Migration適用後：

| Document ID      | Document               | Latest Version | Status     | Baseline Version |
| ---------------- | ---------------------- | -------------: | ---------- | ---------------: |
| DOC-MVP-REQ      | MVP Requirements       |         v0.1.7 | Approved候補 |         v0.1.7候補 |
| DOC-MVP-DES      | MVP Design             |         v0.1.6 | Approved候補 |         v0.1.6候補 |
| DOC-TS-A         | Technical Spike A      |           v0.3 | Closed     |           v0.3候補 |
| DOC-MVP-TESTSPEC | MVP Test Specification |         v0.1.2 | Approved候補 |         v0.1.2候補 |

Migration Consistency Review完了までは正式Baselineへ切り替えない。

---

# 31. Current Approved Baseline

旧BaselineはHistorical Baselineとして保持する。

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1.1
```

Migration後は新Baseline Candidateを作成する。

```text
DOC-MVP-REQ      v0.1.7
DOC-MVP-DES      v0.1.6
DOC-TS-A         v0.3 CLOSED
DOC-MVP-TESTSPEC v0.1.2
```

Baseline IDはProject Overview側で新規採番する。

既存のBaseline ID体系が存在しない場合のみ、

```text
BL-MVP-001
```

から開始する。

---

# 32. Project Overviewへ移すCurrent State

```text
Current Status:
Technical / Functional Baseline Ready

Requirement Gap:
None

Design Gap:
None

Test Gap:
None

Technical Spike A:
CLOSED / PASS

Body Route:
Route W / WordEditor

Test Specification:
Defined

MVP Test Execution:
Not Started
```

Test実施状態はTechnical Test Specificationではなく、
Project Overview / Test Resultで管理する。

---

# 33. Project Overviewへ移すOpen Items

```text
OPN-001
Technical Spike B / C 要否確認

OPN-002
Implementation Plan作成

OPN-003
Test Assets準備

OPN-004
Technical Spike A Environment Metadata補完
Priority: Non-Blocking
```

---

# 34. Context Handoff記載方針

今後のContext Handoffでは、
4文書の詳細Versionを毎回列挙しない。

推奨：

```text
Current Baseline:
<Baseline ID>

Read First:
Project Overview
Latest Context Handoff
必要なTechnical Documents
```

具体VersionはProject OverviewのDocument Registry / Baseline Manifestで解決する。

---

# 35. Migration時に変更してはいけない既知論点

本PatchはGovernance Migrationである。

したがって、Migration作業中に以下を発見しても同時修正しない。

例：

```text
Requirements上の表現
vs
Design上の表現
```

が意味的に異なる場合。

その場合は、

```text
Documentation Issue
Clarification
Semantic Conflict
```

のいずれかとして別Findingに切り出す。

特に、

```text
入力値保持
Excel終了まで
vs
Workbookを閉じるまで
```

のような論点は、本Migration Patchの対象外とする。

---

# 36. Version更新理由

今回4文書のVersionを更新する理由は、

> 他文書Versionが更新されたから

ではない。

各文書自身へGovernance Migrationを適用し、
実際に文書内容を変更するためである。

変更種別：

```text
Editorial / Governance
```

Semantic Change：

```text
None
```

---

# 37. Migration QA

Migration適用後、以下のみ確認する。

## 37.1 Document ID

* [ ] DOC-MVP-REQが存在
* [ ] DOC-MVP-DESが存在
* [ ] DOC-TS-Aが存在
* [ ] DOC-MVP-TESTSPECが存在
* [ ] ID重複なし

## 37.2 Progress Separation

* [ ] Requirementsに「次工程」章なし
* [ ] Designに「次工程」章なし
* [ ] Technical SpikeにCurrent Next Actionなし
* [ ] Test Specificationに「次工程」章なし
* [ ] Test Specificationに実施状態なし

## 37.3 Reference

* [ ] ActiveなRequirements参照はDOC-MVP-REQ
* [ ] ActiveなDesign参照はDOC-MVP-DES
* [ ] ActiveなTechnical Evidence参照はDOC-TS-A
* [ ] Historical Evidence Versionは保持
* [ ] MTS-UNR-004から削除済みDesign §32参照なし

## 37.4 Semantic Preservation

* [ ] FR件数変更なし
* [ ] AC件数変更なし
* [ ] NFR件数変更なし
* [ ] Design Decision変更なし
* [ ] Route W変更なし
* [ ] Technical Finding変更なし
* [ ] Test Case件数変更なし
* [ ] Test Expected変更なし
* [ ] Test Gate変更なし

---

# 38. Expected Counts

Migration前後で以下を維持する。

```text
FR   = 47
AC   = 20
NFR  = 6

Test Case = 69
```

MigrationによってTraceabilityの意味を変更しない。

---

# 39. Migration Gate

以下を満たした場合、本MigrationをPASSとする。

```text
Document ID付与
        +
Progress / Next Action分離
        +
Active ReferenceのDocument ID化
        +
Historical Evidence保全
        +
参照切れ0件
        +
Semantic Change 0件
```

判定：

```text
PASS
↓
New Baseline Candidate
↓
Governance Consistency Review
↓
Approved Baseline
```

---

# 40. Migration後の文書責務

```text
DOC-MVP-REQ
= What the product must do

DOC-MVP-DES
= How the MVP is designed

DOC-TS-A
= What technical evidence established Route W

DOC-MVP-TESTSPEC
= What must be tested

Project Overview
= Where the project is now

Current Approved Baseline
= Which revisions are authoritative together

Context Handoff
= What the next session needs
```

---

# 41. 本Migrationで決定しない事項

以下は本Patchでは決定しない。

* Technical Spike Bの実施要否
* Technical Spike Cの実施要否
* Spike B / Cの検証テーマ
* Implementation Plan構成
* VBA実装順
* Test実施結果
* Semanticな既存文書不整合

これらはMigration完了後の通常開発プロセスで扱う。

---

# 42. Migration完了後の推奨状態

```text
Technical Documents
├─ DOC-MVP-REQ      MVP Requirements v0.1.7
├─ DOC-MVP-DES      MVP Design v0.1.6
├─ DOC-TS-A         Technical Spike A v0.3 CLOSED
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.2

Project Control
├─ Document Registry
├─ Current Approved Baseline
├─ Current Phase
├─ Open Items
└─ Next Action

Execution / Handoff
├─ Latest Context Handoff
└─ Future MVP Test Result
```

これ以降、下流工程が進んでも、

```text
Requirements
Design
Technical Spike
Test Specification
```

へ単なる進捗を追記しない。

進捗変更はProject Overview / Handoff側だけを更新する。

---

# 43. 最終判定

本Migration Patchは、

```text
Change Type:
Editorial / Governance

Requirement Impact:
None

Design Impact:
None

Technical Decision Impact:
None

Test Definition Impact:
None
```

として適用する。

Technical Documentsの「技術的に何が正しいか」は維持し、

```text
現在地
次工程
実施状態
Version解決
```

のみをProject Controlへ切り離す。
