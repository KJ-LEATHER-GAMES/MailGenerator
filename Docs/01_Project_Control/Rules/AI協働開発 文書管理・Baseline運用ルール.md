# AI協働開発 文書管理・Baseline運用ルール v0.1

## 1. 文書情報

| 項目    | 内容                                                                  |
| ----- | ------------------------------------------------------------------- |
| 文書名   | AI協働開発 文書管理・Baseline運用ルール                                           |
| バージョン | v0.1                                                                |
| 文書種別  | 全プロジェクト共通運用標準                                                       |
| 適用対象  | AI協働による個人開発・小規模システム／ツール開発                                           |
| 主目的   | 文書間不整合と不要なVersion更新連鎖を防ぎ、効率性・再現性・品質を両立する                            |
| 基本思想  | 技術仕様・プロジェクト状態・作業引継ぎ・判断履歴を分離する                                       |
| 関連標準  | AI協働開発 基本運用プロセス / Project Overview / Context Handoff / Decision Log |

### v0.1 制定理由

実プロジェクトへの適用過程で、Requirements、Design、Technical Spike、Test Specification等の技術文書へ、

* 現在地
* 次工程
* 実施状況
* 後続文書の予定Version
* 他文書の最新Version番号

を直接記載すると、後続工程が進むたびに上流文書が陳腐化し、仕様変更を伴わない文書改訂が連鎖する問題が確認された。

本ルールでは、この問題を解消するため、

> **技術的に何が正しいか**
>
> **現在どこまで進んでいるか**
>
> **どのVersionの組合せが正式Baselineか**
>
> **なぜその判断をしたか**

を別の責務として管理する。

---

# 2. 目的

本ルールの目的は、以下を同時に実現することである。

1. 技術文書を進捗から独立させ、不要な更新を減らす
2. 最新Versionと正式Baselineを区別する
3. 文書間参照によるVersion更新連鎖を防止する
4. ある時点の仕様構成を再現できる状態を維持する
5. Requirement → Design → Testの整合性を維持する
6. AIチャット変更時にも現在地を安全に復元できるようにする
7. Source of Truthを明確化する
8. 文書管理そのものの過剰設計を避ける

---

# 3. 基本原則

## 3.1 技術文書と進捗情報を分離する

技術文書は、

> **What is true**

を管理する。

Project Overview / Context Handoff等のProject Control文書は、

> **Where we are now**

を管理する。

Decision Logは、

> **Why we decided it**

を管理する。

Baselineは、

> **Which versions are authoritative together**

を管理する。

これらを同一文書へ混在させない。

---

## 3.2 下流工程の進行だけを理由に上流文書を更新しない

後続工程が進んだことは、RequirementやDesignの変更ではない。

したがって、

```text
Design完了
↓
Requirementsの「次工程」を修正
↓
Requirements Version Up
```

のような更新は原則として行わない。

RequirementsはRequirementが変わった場合のみ更新する。

DesignはDesignが変わった場合のみ更新する。

---

## 3.3 文書Version更新を下流へ自動伝播させない

上位文書のVersionが変更されたことだけを理由として、

```text
Requirements v0.1.6 → v0.1.7
        ↓
Design v0.1.5 → v0.1.6
        ↓
Test Specification v0.1.1 → v0.1.2
```

と更新してはならない。

変更内容が下流へ影響するかを判断し、

**影響がある文書だけを更新する。**

---

# 4. 文書レイヤー

文書を以下の4レイヤーへ分類する。

```text
Layer 1
Technical Documents
        │
        │ 技術的事実・仕様
        ▼
Layer 2
Project Control / Baseline
        │
        │ 正式Version・現在地
        ▼
Layer 3
Execution / Handoff
        │
        │ 作業・検証・再開情報
        ▼
Layer 4
Decision / History
        │
        │ 判断理由・変更履歴
```

---

# 5. Layer 1：Technical Documents

Technical Documentsは、プロダクト・システムについての技術的なSource of Truthを管理する。

主な対象：

* Project Requirements
* MVP Requirements
* Production Requirements
* MVP Design
* Production Design
* Technical Specification
* Technical Spike
* Test Specification
* API Specification
* Data Specification
* Operations / Maintenance Specification

Technical Documentsには原則として以下を書かない。

* Current Phase
* 現在の進捗
* 次工程
* Next Action
* 「次に○○ v0.xを作成する」
* 後続工程の予定
* 作業担当状況
* 未着手／実施中等のプロジェクト進捗
* 他文書の「現在のVersion」を維持するためだけの参照

---

# 6. Layer 2：Project Control / Baseline

Project Controlは、プロジェクトの現在状態と正式文書構成を管理する。

原則として **Project OverviewをProject Controlの中心文書** とする。

Project Overviewには少なくとも以下を管理する。

* Current Phase
* Current Focus
* Project Status
* Next Action
* Open Items
* Current Risks
* Known Issues
* Document Registry
* Current Approved Baseline

小規模プロジェクトでは、Document RegistryやBaseline Manifestを独立文書にせず、Project Overview内のセクションとして管理してよい。

規模拡大によりProject Overviewが肥大化した場合のみ、

* Project Document Registry
* Baseline Manifest

として分離する。

YAGNIを優先し、最初から管理文書を増やさない。

---

# 7. Layer 3：Execution / Handoff

作業状態・実施状態・AIチャット再開情報を管理する。

主な対象：

* Context Handoff
* Test Result
* Test Run
* Trial Result
* Implementation Checkpoint
* Release Result

Context Handoffは、

> **再開装置**

であり、技術仕様のSource of Truthではない。

Handoffには以下を記載できる。

* Current Objective
* Completed
* Current State
* Confirmed Decisionsの要約
* Open Items
* Current Risks
* Known Issues
* Current Baseline ID
* Read First
* Next Action
* Done When
* Implementation State
* Verification State

ただし詳細なRequirementやDesignを複製してはならない。

---

# 8. Layer 4：Decision / History

判断理由・変更履歴を保存する。

主な対象：

* Decision Log
* Change Log

Decision Logは、

> **なぜその判断をしたか**

を管理する。

Change Logは、

> **何を変更したか**

を管理する。

RequirementやDesignの本文へ、意思決定の経緯を過剰に複製しない。

---

# 9. 文書責務マトリクス

| 情報                     | 管理先                          |
| ---------------------- | ---------------------------- |
| 利用者から見た振る舞い            | Requirements                 |
| 技術構成・責務・処理方式           | Design                       |
| 技術成立性Evidence          | Technical Spike              |
| Test条件・Expected Result | Test Specification           |
| Test実施結果               | Test Result                  |
| 現在Phase                | Project Overview             |
| 次Action                | Project Overview / Handoff   |
| 現在の進捗                  | Project Overview / Handoff   |
| 正式文書一覧                 | Document Registry            |
| 正式Version組合せ           | Current Approved Baseline    |
| 判断理由                   | Decision Log                 |
| 変更履歴                   | Change Log                   |
| 実装Version / Commit     | Implementation / Test Result |
| Session再開情報            | Context Handoff              |

同一情報を複数文書へ詳細に重複記載しない。

---

# 10. Document ID

## 10.1 基本原則

各正式文書には、Versionとは独立した**固定Document ID**を付与する。

Document IDはVersion Upしても変更しない。

例：

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-TS-A
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
```

---

## 10.2 Document IDとVersionの違い

```text
DOC-MVP-REQ
        │
        ├─ v0.1.5
        ├─ v0.1.6
        └─ v0.1.7
```

`DOC-MVP-REQ` は論理的な文書を示す。

`v0.1.7` はその文書の特定Revisionを示す。

---

# 11. 文書間参照ルール

## 11.1 通常の技術文書間参照

技術文書同士は、原則としてVersion番号ではなくDocument IDで参照する。

### 推奨

```text
Related Documents

- DOC-MVP-REQ
- DOC-TS-A
```

### 原則避ける

```text
MVP Requirements v0.1.6
Technical Spike A v0.2
```

Version解決はProject Control / Baselineが担当する。

---

## 11.2 Version固定が必要な場合

以下では特定VersionまたはBaseline IDを固定する。

* Technical Spike実施Evidence
* Test Result
* Trial Result
* Release
* Build Verification
* 過去Baseline
* 再現性が必要な検証記録

例えばTechnical Spikeでは、

```text
Related Documents:
DOC-MVP-REQ
DOC-MVP-DES

Execution Context:
BL-MVP-003
```

とする。

これにより、

* 論理的関係はDocument ID
* 実際に検証した状態はBaseline ID

として分離できる。

---

# 12. Document Registry

Project Overview内にDocument Registryを設ける。

推奨形式：

| Document ID      | Document               | Latest Version | Status   | Baseline Version | Role               |
| ---------------- | ---------------------- | -------------: | -------- | ---------------: | ------------------ |
| DOC-MVP-REQ      | MVP Requirements       |           v0.x | Approved |             v0.x | Requirement        |
| DOC-MVP-DES      | MVP Design             |           v0.x | Approved |             v0.x | Design             |
| DOC-TS-A         | Technical Spike A      |           v0.x | Closed   |             v0.x | Technical Evidence |
| DOC-MVP-TESTSPEC | MVP Test Specification |           v0.x | Approved |             v0.x | Test Definition    |

### Latest Version

存在する最新Revision。

### Status

文書自体の状態。

### Baseline Version

Current Approved Baselineに採用されているVersion。

`Latest Version` と `Baseline Version` は一致しなくてもよい。

---

# 13. Document Status

文書Statusは原則以下を使用する。

| Status     | 意味                         |
| ---------- | -------------------------- |
| Draft      | 作成・変更中                     |
| Review     | Review中                    |
| Approved   | 正式利用可能                     |
| Closed     | Technical Spike等、目的を完了した記録 |
| Superseded | 後続文書・Revisionへ正式に置換済み      |

文書種別に不要なStatusは使用しなくてよい。

---

# 14. Current VersionとBaseline Version

最も重要なルールの一つとする。

```text
Latest Version
≠
Current Approved Baseline Version
```

を許容する。

例：

```text
DOC-MVP-REQ

Latest Version:
v0.1.7

Current Baseline:
v0.1.6
```

v0.1.7が作成されても、DesignやTestとの整合性確認が完了するまではCurrent Approved Baselineを変更しない。

これにより、作業途中の文書と正式Baselineを混同しない。

---

# 15. Baseline

## 15.1 Baselineの定義

Baselineとは、

> **ある時点で相互整合性を確認し、正式な開発・検証基準として承認した文書Versionの組合せ**

である。

単一文書のVersionではない。

---

## 15.2 Baseline ID

Baselineには固定IDを付与する。

例：

```text
BL-MVP-001
BL-MVP-002
BL-MVP-003
```

Baseline IDは再利用しない。

---

## 15.3 Baseline Manifest

推奨形式：

```text
Baseline ID: BL-MVP-004
Status: Approved

DOC-MVP-REQ      v0.x
DOC-MVP-DES      v0.x
DOC-TS-A         v0.x
DOC-MVP-TESTSPEC v0.x
```

小規模プロジェクトではProject Overview内に保持する。

---

# 16. Baseline Status

| Status      | 意味             |
| ----------- | -------------- |
| Candidate   | 整合性確認中         |
| Approved    | 正式Baseline     |
| Superseded  | 新Baselineへ置換済み |
| Invalidated | 重大問題により利用不可    |

通常は `Candidate → Approved → Superseded` を使用する。

---

# 17. Baseline更新条件

Baselineは、単に新しいVersionが作成されたことでは更新しない。

以下を確認した場合のみ新Baselineを作成する。

* 必要文書が揃っている
* Blocking Gapが残っていない
* 文書間に既知のSemantic Conflictがない
* 必要なTraceabilityが成立している
* 変更影響確認が完了している
* 必要なReviewが完了している

---

# 18. Baseline更新フロー

標準フロー：

```text
Document Change
        ↓
Change Classification
        ↓
Impact Review
        ↓
必要な文書だけ更新
        ↓
Cross-document Consistency Review
        ↓
Baseline Candidate
        ↓
PASS
        ↓
New Approved Baseline
```

FAILした場合、Current Approved Baselineは維持する。

---

# 19. 変更分類

文書変更は原則3種類へ分類する。

## 19.1 Editorial Change

意味を変更しない修正。

例：

* 誤字修正
* レイアウト
* 表現統一
* 進捗情報削除
* 古いNext Action削除
* 文書管理ルールへの移行

原則：

> 下流文書Impactなし。

---

## 19.2 Clarification Change

意味を変えず、曖昧さを解消する。

例：

* 既存Requirementの説明補足
* Design責務の明文化
* 用語定義追加

原則：

> Impact Reviewを行うが、自動的に下流Versionを更新しない。

---

## 19.3 Semantic Change

仕様・設計上の意味が変わる。

例：

* Requirement追加・削除
* Acceptance Criteria変更
* User Behavior変更
* Data Model変更
* Architecture変更
* Validation Rule変更
* Test Expected Result変更

原則：

> 下流Impact Analysis必須。

---

# 20. 下流Impact Analysis

Semantic Change発生時のみ、原則以下を確認する。

```text
Requirement
    ↓
Design
    ↓
Test Specification
    ↓
Implementation
    ↓
Test Result
```

ただし、すべてを必ず変更するわけではない。

各文書について、

```text
Affected
Not Affected
Needs Review
```

を判断する。

`Not Affected` と判断できた文書はVersion Upしない。

---

# 21. Version更新ルール

Version Upは、

> **その文書自身の内容が変更された場合**

に行う。

上位文書Versionが変更されたことだけを理由にVersion Upしない。

例：

```text
Requirements v0.1.6
        ↓ Editorial Change
Requirements v0.1.7
```

Design内容に影響がない場合、

```text
Design v0.1.5
```

を維持してよい。

新Baselineは、

```text
REQ v0.1.7
DES v0.1.5
```

という異なるRevision番号の組合せでも問題ない。

Version番号を横並びに揃える必要はない。

---

# 22. Requirements記載ルール

Requirementsには主に以下を保持する。

* Purpose
* Scope
* Out of Scope
* Functional Requirements
* Non-functional Requirements
* Acceptance Criteria
* User-visible Constraints
* Requirement Decisions
* Requirement-level Exit Criteria

原則記載しない：

* 次工程
* Design進捗
* Test作成予定
* Implementation予定
* 「現在○○まで完了」
* 下流文書の予定Version

---

# 23. Design記載ルール

Designには主に以下を保持する。

* Architecture
* Component Responsibility
* Sequence
* Data Model
* Error Handling
* Validation
* Interface
* Design Rules
* Technical Constraints
* Design Risk
* Implementation Detail Boundary
* Design-level Exit Criteria

原則記載しない：

* 次工程
* Test進捗
* Implementation進捗
* 「次にTechnical Spike Bを実施」
* 後続文書Version予定

---

# 24. Technical Spike記載ルール

Technical Spikeは通常の進捗文書とは異なり、

* Technical Question
* Hypothesis
* Validation Method
* Evidence
* Finding
* Decision
* PASS / CONDITIONAL PASS / FAIL
* CLOSED

を保持してよい。

これらはSpikeそのものの成果だからである。

一方、

* 次工程
* Requirementsを次に更新する
* Test Specificationを次に作成する

等は原則Project Controlへ移す。

Technical Spikeは完了後、原則として歴史的Evidenceとして変更しない。

---

# 25. Test SpecificationとTest Resultの分離

Test Specificationは、

> **何をどの条件で確認するか**

を定義する。

Test Resultは、

> **何に対して実行し、何が起きたか**

を記録する。

Test Specificationには原則として、

```text
全Test NOT RUN
実施待ち
次工程：Implementation
```

等の進捗を持たせない。

Test Resultには最低限、

* Test Specification Version
* Baseline ID
* Build ID
* Commit ID（使用可能な場合）
* Environment
* Test Date
* Result
* Evidence

を記録する。

これにより、

> 何をテストしたか

を後から再現可能にする。

---

# 26. Context Handoffルール

Context Handoffには、詳細Version一覧を重複保持しない。

推奨：

```text
Current Baseline:
BL-MVP-004
```

詳細VersionはProject Overview / Baseline Manifestを参照する。

Reference Documentsでは、

* Document ID
* 文書名
* 読む目的

を中心に記載する。

Handoffが古くなってもTechnical Documentの正当性へ影響させない。

---

# 27. Project Overviewルール

Project Overviewを、

> **Project Control Cockpit**

として使用する。

最低限以下を維持する。

```text
Current Phase
Current Focus
Current Status
Current Approved Baseline
Document Registry
Open Items
Current Risks
Known Issues
Next Action
```

Project Overviewは「今」を管理するため、更新頻度が高くてよい。

技術文書を安定させる代わりに、現在地の変更はProject Overviewへ集約する。

---

# 28. Decision Logとの関係

重要な技術判断はDecision Logへ記録する。

例：

```text
DEC-007
Body Rendering Route

Decision:
Route W / WordEditor

Reason:
HTMLBodyではVariable内部がHTML Tagで分断される場合があり、
Scanner / Rendererの安定性を保証できないため。

Evidence:
DOC-TS-A
```

Technical Spikeは詳細Evidenceを管理する。

Decision Logは判断の索引・理由を管理する。

---

# 29. Source of Truth

情報種別ごとにSource of Truthを定義する。

| 情報                           | Source of Truth           |
| ---------------------------- | ------------------------- |
| Requirement                  | Requirements              |
| Design                       | Design                    |
| Technical Evidence           | Technical Spike           |
| Test Definition              | Test Specification        |
| Test Result                  | Test Result               |
| Approved Version Combination | Current Approved Baseline |
| Current Project State        | Project Overview          |
| Decision Rationale           | Decision Log              |
| Session Restart State        | Latest Context Handoff    |

---

# 30. 文書間矛盾時のルール

文書間矛盾を検出した場合、

**勝手に最新版へ合わせて補正しない。**

まず、

1. 情報の責務を確認
2. Current Approved Baselineを確認
3. Semantic Conflictか単なる古い進捗記述か分類
4. 必要な文書のみ修正
5. 必要なら新Baselineを作成

とする。

Baseline内でSemantic Conflictが発見された場合は、Baseline Quality Issueとして扱う。

---

# 31. AI運用ルール

AIは文書Review・作成時に以下を守る。

### Rule 1

技術文書へ現在地・次工程を勝手に追加しない。

### Rule 2

関連文書参照には原則Document IDを使用する。

### Rule 3

最新版Version番号を技術文書へ機械的に転記しない。

### Rule 4

上位文書Version変更だけを理由に下流Version Upを提案しない。

### Rule 5

変更をEditorial / Clarification / Semanticへ分類する。

### Rule 6

Semantic Changeの場合のみ下流Impact Analysisを行う。

### Rule 7

Current VersionとApproved Baselineを混同しない。

### Rule 8

Context Handoffを詳細仕様のSource of Truthとして使用しない。

### Rule 9

Baseline変更前にCross-document Consistencyを確認する。

### Rule 10

不整合を検知しても、仕様を推測して自動修正しない。

---

# 32. 最小運用セット

小規模プロジェクトでは、Baseline管理のためだけに大量の文書を追加しない。

標準的な最小構成：

```text
Project Overview
├─ Current Status
├─ Document Registry
├─ Current Approved Baseline
└─ Next Action

Technical Documents
├─ Requirements
├─ Design
├─ Technical Spike
└─ Test Specification

Management
├─ Decision Log
└─ Context Handoff

Execution Evidence
└─ Test Result
```

独立したDocument Registry / Baseline Manifestは、必要になるまで作らない。

---

# 33. 規模拡大時の分離

以下が発生した場合、Project Overviewから管理機能を分離してよい。

* 文書数が多く一覧性が低下
* 複数Baselineを並行管理
* 複数リリース系列を管理
* 複数チームが文書を変更
* Baseline Auditが必要
* Project Overviewが肥大化

その場合、

```text
Project Document Registry
Baseline Manifest
```

を独立させる。

---

# 34. Existing Document Migration

既存プロジェクトを本ルールへ移行する場合、以下を実施する。

## Step 1：Document ID付与

各正式文書へ固定Document IDを付与する。

## Step 2：進捗情報抽出

以下を技術文書から抽出する。

* 現在地
* 次工程
* Next Action
* 実施状態
* 後続Version予定

Project Overview / Handoffへ移す。

## Step 3：Version参照整理

技術文書間のVersion固定参照をDocument IDへ置き換える。

ただしHistorical Evidenceは元VersionまたはBaseline IDを維持する。

## Step 4：Document Registry作成

Latest Version / Statusを登録する。

## Step 5：Current Approved Baseline登録

既に整合性確認済みの文書組合せをBaseline IDとして固定する。

## Step 6：Consistency Review

移行によって技術的意味が変化していないことを確認する。

---

# 35. Migration Change Classification

本ルール導入のため、

* 次工程を削除
* 現在地を削除
* Version参照をDocument IDへ変更
* 進捗StatusをProject Overviewへ移動

するだけで、技術的意味が変わらない場合、

> **Editorial / Governance Change**

として扱う。

その変更だけを理由にRequirement → Design → Testの全面再Reviewを行う必要はない。

---

# 36. Baseline Quality Gate

BaselineをApprovedにする前に、最低限以下を確認する。

* [ ] Document Registryが最新
* [ ] Baseline対象Versionが特定できる
* [ ] Blocking Requirement Gapなし
* [ ] Blocking Design Gapなし
* [ ] Blocking Test Gapなし
* [ ] 既知Semantic Conflictなし
* [ ] 必要なTraceability確認済み
* [ ] Semantic ChangeのImpact Review完了
* [ ] Test SpecificationとTest Resultを混同していない
* [ ] Project進捗がTechnical Documentへ混入していない
* [ ] Baseline IDが一意

---

# 37. Anti-Patterns

以下の運用は禁止または原則非推奨とする。

### Anti-Pattern 1

Requirementsに、

> 次工程：Design v0.1を作成

と記載する。

### Anti-Pattern 2

Design Versionが上がったためRequirementsの次工程記述だけ更新する。

### Anti-Pattern 3

Requirements Versionが上がったという理由だけでDesign Versionを上げる。

### Anti-Pattern 4

Test Specificationに「現在69件すべてNOT RUN」と進捗を書き続ける。

### Anti-Pattern 5

Handoffの記述を正式仕様として扱う。

### Anti-Pattern 6

「Latest Versionだから」という理由だけで未Review文書をBaselineとして扱う。

### Anti-Pattern 7

Baseline IDを持たず、後からどのVersion組合せで実装・Testしたか分からなくなる。

---

# 38. 推奨運用フロー

通常開発：

```text
Project Overview
        ↓
Current Baseline確認
        ↓
技術文書変更
        ↓
Change Classification
        ↓
必要時Impact Analysis
        ↓
影響文書のみ変更
        ↓
Consistency Review
        ↓
New Baseline
        ↓
Implementation / Test
        ↓
Result
        ↓
Project Overview更新
```

チャット変更時：

```text
Project Overview
+
Latest Handoff
+
現在作業に必要なTechnical Documents
        ↓
作業再開
```

---

# 39. 本ルール導入後の責務分離

最終的な責務を以下とする。

```text
Technical Documents
= What is true

Project Overview
= Where we are now

Document Registry
= What documents exist and which revision is latest

Baseline
= Which revisions are authoritative together

Decision Log
= Why we decided it

Context Handoff
= What the next session needs to continue

Test Result
= What was actually verified
```

---

# 40. 完了条件

本ルールが適用されたプロジェクトでは、以下を満たすことを目標とする。

* 技術文書に現在地・次工程が混在していない
* 各正式文書をDocument IDで識別できる
* Latest Versionを一箇所で確認できる
* Current Approved Baselineを一意に特定できる
* Version Upが不要に下流へ伝播しない
* Semantic Changeのみ適切にImpact Analysisされる
* Test SpecificationとTest Resultが分離されている
* Handoffが仕様書代わりになっていない
* 過去Baselineを再現できる
* AIが新しいチャットでも安全に再開できる
* 文書管理コストが開発そのものを上回らない

---

# 41. v0.1適用後の改善方針

本ルール自体もMVPとして運用する。

実プロジェクトで使用し、

* Document IDが過剰か
* Registry更新が負担にならないか
* Baseline作成頻度が適切か
* Change Classificationが判断しやすいか
* AIがLatestとBaselineを正しく区別できるか
* Handoffとの情報重複がないか

を確認する。

実運用で不要と判明した項目は削減し、不足が確認された場合のみv0.2で追加する。

**本ルール自体についてもYAGNIを適用する。**
