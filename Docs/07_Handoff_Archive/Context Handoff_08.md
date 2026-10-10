

# 引き継ぎまとめ

## 現在地

```text
Project:
定型メール作成ツール

Current Phase:
P1 Walking Skeleton

P0 Foundation:
COMPLETE

CP-P0:
ESTABLISHED

New Workbook P0 Integration Regression:
PASS

P1-01 OFT Path / Outlook Connection:
PASS / COMPLETE

DF-P1-001 OneDrive Local Path Resolution:
CLOSED

TV-P1-001:
PASS

Current Approved Baseline:
BL-MVP-002

DOC-MVP-IMPL:
Implementation Plan v0.2 / Approved

P1-02 Entry:
READY

Next Implementation Task:
P1-02 Inspector / WordEditor Connection
```

この会話では、前チャットから引き継いだP1-01完了後の状態から、文書管理・Baseline更新・Implementation Plan更新・新Workbook P0 Regressionまでを完了した。

現在、P1-02開始を妨げるBlocking Itemは確認されていない。

---

# 実施内容

## 1. 前チャットHandoffの確認と次Action整理

前チャットから以下の状態を引き継いだ。

```text
P0 Foundation = COMPLETE
CP-P0 = ESTABLISHED
P1-01 = PASS / COMPLETE
DF-P1-001 = CLOSED
TV-P1-001 = PASS

Latest Approved:
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4相当

Current Approved Baseline:
BL-MVP-001
```

次の優先Actionとして、

1. MVP Test Specification v0.1.4のCandidate表記解消
2. BL-MVP-002 Candidate作成
3. Baseline Approval Quality Gate
4. Implementation PlanへのImpact Review
5. P0 Regression
6. P1-02開始

の順で整理した。

---

## 2. MVP Test Specification v0.1.4を正式Approved Artifact化

元の文書では、

```text
Document ID:
DOC-MVP-TESTSPEC

Version:
v0.1.4

Status:
Review / Candidate
```

となっていた。

一方、前チャットのCross-document Consistency Reviewでは、

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

まで確認済みだった。

そのため、Test定義自体には変更を加えず、文書状態のみ正式化した。

作成：

```text
MVP Test Specification v0.1.4 日本語版.md
```

確定状態：

```text
DOC-MVP-TESTSPEC
Version: v0.1.4
Status: Approved
Test Case Count: 69
```

変更しなかったもの：

- Test ID
- Test Case
- Expected Result
- Requirement Traceability
- Design Traceability
- Test Gate
- FR / AC / NFR Coverage

---

## 3. BL-MVP-002 Candidate作成

新Baseline Candidateとして以下を固定した。

```text
BL-MVP-002 Candidate

DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

作成：

```text
BL-MVP-002 Baseline Candidate.md
```

BL-MVP-001との差分：

```text
DOC-MVP-REQ
v0.1.8 → v0.1.8
unchanged

DOC-MVP-DES
v0.1.7 → v0.1.8
Semantic Design Change

DOC-TS-A
v0.4 → v0.4
unchanged

DOC-MVP-TESTSPEC
v0.1.3 → v0.1.4
Semantic Test Definition Update
```

Candidate Creation Gate：

```text
PASS
```

---

## 4. BL-MVP-002 Baseline Approval Quality Gate実施

Baseline Approval Quality Gateとして以下を確認した。

```text
Document Registry最新状態
Baseline対象Version特定
Blocking Requirement Gap
Blocking Design Gap
Blocking Test Gap
Semantic Conflict
Traceability
Semantic Change Impact Review
Test Specification / Test Result責務分離
Project進捗のTechnical Document混入
Baseline ID一意性
```

結果：

```text
Baseline Approval Quality Gate:
PASS

Blocking Requirement Gap:
NONE

Blocking Design Gap:
NONE

Blocking Test Gap:
NONE

Semantic Conflict:
NONE

Traceability Break:
NONE
```

正式決定：

```text
BL-MVP-002:
APPROVED

BL-MVP-001:
SUPERSEDED

Current Approved Baseline:
BL-MVP-002
```

作成：

```text
BL-MVP-002 Baseline Approval Record v0.1.md
```

BL-MVP-001は削除せず、Historical Baselineとして保持する方針とした。

---

## 5. Project Document Registry v0.5作成

当初はv0.4本体が会話内に存在しなかったため、

```text
定型メール作成ツール Project Document Registry and Approved Baseline v0.5 Update Patch.md
```

を作成した。

その後、ユーザーがv0.4本体をSourcesへ保存したため、正式な全文版v0.5を作成した。

作成：

```text
定型メール作成ツール Project Document Registry and Approved Baseline v0.5.md
```

v0.5で反映：

```text
Current Approved Baseline:
BL-MVP-002

BL-MVP-001:
Superseded

DOC-MVP-REQ:
v0.1.8 / Approved / Baseline v0.1.8

DOC-MVP-DES:
v0.1.8 / Approved / Baseline v0.1.8

DOC-TS-A:
v0.4 / Closed / Baseline v0.4

DOC-MVP-TESTSPEC:
v0.1.4 / Approved / Baseline v0.1.4
```

---

## 6. DOC-MVP-IMPL v0.1に対するBL-MVP-002 Impact Review

Project Document Registry v0.5確認時に、

```text
DOC-MVP-IMPL
Implementation Plan v0.1
```

が依然として、

```text
Execution Baseline:
BL-MVP-001
```

を固定参照していることを検出した。

特に以下が旧Baseline依存だった。

- 文書情報 / Execution Baseline
- §2 Purpose
- §4.1 Execution Baseline
- §4.2 Baseline変更ルール
- §4.3 Technical Spike B / C判定
- `IMP-R01 Baseline Driven`
- P0 Input
- P0 Exit Criteria
- Test Candidate Build
- Implementation Entry Criteria
- Appendix A Phase Flow

Impact Review結果：

```text
DOC-MVP-IMPL v0.1
BL-MVP-002 Impact:

AFFECTED

REVISION REQUIRED

Recommended Revision:
DOC-MVP-IMPL v0.2
```

作成：

```text
DOC-MVP-IMPL v0.1 BL-MVP-002 Impact Review v0.1.md
```

---

## 7. Implementation Plan v0.2 Candidate作成

Impact Reviewに基づき、v0.1から最小差分でv0.2 Candidateを作成した。

作成：

```text
Implementation Plan v0.2 Candidate 日本語版.md
```

主な変更：

```text
Version:
v0.1
↓
v0.2

Status:
Approved
↓
Review / Candidate

Execution Baseline:
BL-MVP-001
↓
BL-MVP-002
```

あわせて以下を更新。

- Baseline Manifest
- `IMP-R01 Baseline Driven`
- P0 Input
- P0 Exit Criteria
- Test Candidate Build Baseline ID
- Implementation Entry Criteria
- Appendix A Phase Flow
- Baseline変更ルール

変更しなかったもの：

- P0〜P7 Phase構成
- CP-P0〜CP-P7 Checkpoint構成
- Module Mapping
- Route W / WordEditor
- P1 Walking Skeleton方針
- P1-02 Inspector / WordEditor方針
- Finding Flow
- Formal MVP Test方針

旧`BL-MVP-001`参照は、

```text
v0.2変更履歴
v0.1 Historical Summary
```

だけに残し、Active Referenceからは除去した。

---

## 8. Implementation Plan v0.2 Plan Consistency Review

Candidateに対してPlan Consistency Reviewを実施した。

確認内容：

- Execution Baseline = BL-MVP-002
- Baseline Manifest整合
- 旧BL-MVP-001 Active Referenceの有無
- IMP-R01
- P0〜P7 Phase構造
- CP-P0〜CP-P7
- Module Mapping
- Route W / WordEditor
- P1 Walking Skeleton
- Design Section Reference
- Test ID Reference
- Test Candidate Build
- Entry Criteria
- Appendix A
- Scope Expansion有無

Test IDについて機械確認し、Implementation Planが参照している20個のMTS IDがすべて、

```text
DOC-MVP-TESTSPEC v0.1.4
```

に存在することを確認した。

結果：

```text
Plan Consistency Review:
PASS

Old Baseline Active Reference:
NONE

Blocking Requirement Conflict:
NONE

Blocking Design Conflict:
NONE

Blocking Test Conflict:
NONE

Broken Test Reference:
NONE

Broken Design Reference:
NONE

Unexpected Scope Expansion:
NONE
```

作成：

```text
Implementation Plan v0.2 Plan Consistency Review v0.1.md
```

正式Approved Artifact：

```text
Implementation Plan v0.2 日本語版.md
```

確定状態：

```text
DOC-MVP-IMPL
Version: v0.2
Status: Approved
Execution Baseline: BL-MVP-002
```

---

## 9. Project Document Registry v0.6更新

DOC-MVP-IMPL v0.2 ApprovedをProject Controlへ反映した。

作成：

```text
定型メール作成ツール Project Document Registry and Approved Baseline v0.6.md
```

v0.6で更新：

```text
DOC-MVP-IMPL:
v0.2 / Approved

Implementation Plan Execution Baseline:
BL-MVP-002

Implementation Plan Impact Review:
COMPLETE

Plan Consistency Review:
PASS

P1-02 Baseline / Plan Alignment:
READY
```

BL-MVP-002のManifest自体は変更しない。

理由：

```text
DOC-MVP-IMPL
```

はBaseline Manifest構成文書ではなく、Implementation PlanとしてProject Control / Executionを管理するため。

---

## 10. 新Workbook P0 Integration Regression実施

新Workbook：

```text
MailGenerator3.xlsm
```

に対して、

```vb
TestP0FoundationIntegration
```

を実行した。

初回結果：

```text
Result / Error Model:
PASS

FAIL:
Resolved path is not based on ThisWorkbook.Path.

ThisWorkbook.Path:
https://d.docs.live.net/.../ドキュメント/MailGenerator

AbsolutePath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

---

## 11. P0 Integration FAILの原因分析

今回のFAILを確認した結果、Production不具合ではなく、

```text
P0 Foundation Integration Smoke Testの旧Assertion
```

が原因と判断した。

旧Testは、

```text
Resolved AbsolutePath
must be based on
ThisWorkbook.Path
```

を前提としていた。

しかし現行Designでは、

```text
ThisWorkbook.Path
= https://d.docs.live.net/...

↓ OneDrive Local Path Resolution

AbsolutePath
= C:\Users\...\OneDrive\...
```

が正しい。

Finding分類：

```text
Test Defect
/
Regression Harness Drift

Production Defect:
NO

Design Gap:
NO

Requirement Gap:
NO
```

Productionコードを変更しない方針とした。

---

## 12. P0 Foundation Integration Smoke Test v0.2作成

ユーザーから元Module：

```text
modP0FoundationIntegrationSmokeTest_v0.1_CP932.bas
```

が提供された。

旧Path Assertionだけを現行Designへ合わせる最小修正を実施した。

作成：

```text
modP0FoundationIntegrationSmokeTest_v0.2_CP932.bas
```

Encoding：

```text
CP932
```

修正内容：

### Local Workbook Path

```text
AbsolutePath
→ ThisWorkbook.Path基点であることを確認
```

### OneDrive Web URL

```text
ThisWorkbook.Path
= https://d.docs.live.net/...

↓

AbsolutePathがWindows絶対Path
Web URLが残っていない
TemplatePathとの相対関係を維持
```

正常時ログ：

```text
Path Resolution Mode=OneDrive Web URL -> Local Windows Path
```

Productionコード：

```text
modSettingsData
modOutlookAdapter
```

等には変更を加えていない。

---

## 13. 新Workbook P0 Integration Regression再実行

修正版v0.2を使用して再実行。

結果：

```text
TestP0FoundationIntegration: START

ThisWorkbook:
MailGenerator3.xlsm

ThisWorkbook.Path:
https://d.docs.live.net/.../ドキュメント/MailGenerator

Result / Error Model:
PASS

Path Resolution Mode:
OneDrive Web URL -> Local Windows Path

Settings Data Access:
PASS

TemplatePath:
Templates\MailTemplate.oft

AbsolutePath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

VariableDefinition Data Access:
PASS

All Rows:
2

Active Rows:
1

OptionMaster Data Access:
PASS

Active Options:
2

Integrated Execution:
PASS

TestP0FoundationIntegration:
PASS
```

これにより、新Workbook再構築後のP0 Foundation Integration健全性を確認した。

---

# 決定事項

## Baseline

- `BL-MVP-002` を正式Approved Baselineとする。
- `BL-MVP-001` は `Superseded` とする。
- BL-MVP-001は削除せずHistorical Baselineとして保持する。
- Current Approved Baselineは `BL-MVP-002`。

正式Manifest：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

---

## Test Specification

- `DOC-MVP-TESTSPEC v0.1.4` を正式Approved Artifactとする。
- Test Case総数は69件維持。
- Candidate表記のみ解消し、Test Definitionそのものは変更しない。

---

## Implementation Plan

- `DOC-MVP-IMPL v0.1` はBL-MVP-002 Impactを受ける。
- Impact判定は `AFFECTED / REVISION REQUIRED`。
- `DOC-MVP-IMPL v0.2` を作成する。
- v0.2はBL-MVP-002をExecution Baselineとする。
- Plan Consistency ReviewはPASS。
- `DOC-MVP-IMPL v0.2 = Approved`。
- P0〜P7 Phase構成は変更しない。
- Module Mappingは変更しない。
- Route W / WordEditor方針は変更しない。
- Technical Spike B / Cは `NOT REQUIRED` を維持する。

---

## Project Document Registry

- Registry v0.5を作成。
- その後Implementation Plan更新を反映してv0.6へ更新。
- v0.6を現時点のLatest Project Control Documentとする。

---

## P0 Regression

- 新Workbook P0 Integration Regressionを実施する方針を採用。
- 初回FAILはProduction DefectではなくTest Defectと分類。
- Productionコードは変更しない。
- P0 Integration Smoke Testをv0.2へ修正。
- 修正版によるRegressionはPASS。
- P0 Foundationを再Openしない。
- CP-P0も再Openしない。

---

## P1-02開始判定

以下がすべて成立したため、

```text
P1-02 Entry:
READY
```

とする。

```text
P0 Foundation = COMPLETE
CP-P0 = ESTABLISHED
New Workbook P0 Integration Regression = PASS
P1-01 = PASS / COMPLETE
DF-P1-001 = CLOSED
TV-P1-001 = PASS
BL-MVP-002 = Approved
DOC-MVP-IMPL v0.2 = Approved
Plan Consistency Review = PASS
```

P1-02開始を妨げるBlocking Itemは現時点でなし。

---

# 未解決事項

## 1. P1-02 Inspector / WordEditor Connection

未着手。

次のProduction Task：

```text
P1-02
Inspector / WordEditor Connection
```

目的：

```text
Production Module Boundary上で
MailItem
↓
Inspector
↓
WordEditor
を取得できることを確認する
```

---

## 2. P1-02実施仕様

未作成。

次チャットで最初に作成する候補：

```text
P1-02 Inspector WordEditor Connection 実施仕様 v0.1.md
```

要確認：

- Production API Boundary
- `modOutlookAdapter`へInspector / WordEditor取得を追加するか
- 既存MailItemをどこまでAdapter内で扱うか
- Cleanup責務
- Smoke Test構成
- PASS / FAIL Evidence

---

## 3. P1-02でのModule Responsibility

未確定。

特に以下は次チャットでDesign v0.1.8を確認して決める。

```text
MailItem取得
Inspector取得
WordEditor取得
Word.Document参照
Cleanup
```

をどのModule境界へ置くか。

Technical Spike Aでは技術成立性は確認済みだが、Production ArchitectureとしてのAPI形はこれから確定する。

---

## 4. OneDrive Commercial / 複数Account

今回の対象外。

未確認：

```text
OneDrive for Business
OneDriveCommercial
複数異なるOneDrive Account
```

現時点でMVP Blocking Findingではない。

---

## 5. 旧Workbook Out of memory原因

旧Workbookで発生した、

```text
Out of memory (Error 7)
```

の内部原因は未特定。

新Workbook再構築＋Regression PASSにより、現在はBlockingではない。

---

## 6. P1-03以降

未着手。

予定：

```text
P1-02 Inspector / WordEditor Connection
P1-03 Subject / BodyText Snapshot
P1-04 Minimal Template Scanner
P1-05 Minimal Render
P1-06 Unresolved Check
P1-07 Display / Lifecycle
```

---

# 次アクション

## 優先度1：P1-02実施仕様作成

次チャットで最初に取り組む。

候補文書名：

```text
P1-02 Inspector WordEditor Connection 実施仕様 v0.1.md
```

最初に見るファイル：

```text
1. 定型メール作成ツール Project Document Registry and Approved Baseline v0.6.md

2. Implementation Plan v0.2 日本語版.md

3. MVP Design v0.1.8 日本語版.md

4. Technical Spike A 実施仕様書 v0.4 日本語版_CLOSED.md

5. MVP Test Specification v0.1.4 日本語版.md

6. P1-01 OFT Path Outlook Connection Completion Record v0.1.md

7. 最新 modOutlookAdapter
```

---

## 優先度2：P1-02のProduction Boundary決定

検討対象：

```text
MailItem
↓
Inspector
↓
WordEditor
```

確認事項：

- `modOutlookAdapter`の公開API
- Inspector取得責務
- WordEditor取得責務
- Word Document型の扱い
- COM Error変換
- CloseWithoutSaveとのLifecycle
- Smoke Test用APIとProduction APIの分離

---

## 優先度3：P1-02 Smoke Test設計

最低限確認する候補：

```text
CreateMailFromTemplate
↓
MailItem取得
↓
Inspector取得
↓
WordEditor取得
↓
Word Document確認
↓
CloseWithoutSave
```

Evidence候補：

```text
MailItem Is Nothing
Inspector Is Nothing
WordEditor Is Nothing
Document Type
Inspector Count before / after
Draft Count before / after
Cleanup Result
```

Technical Spike AでのTSA-002 / TSA-010等との整合を確認する。

---

## 優先度4：P1-02完了後

P1-03へ進む。

候補：

```text
Subject / BodyText Snapshot
```

ただしP1-02完了前に先回り実装しない。

---

# 気づき

## 1. Baseline更新後はImplementation PlanもImpact Review対象になる

今回、

```text
Design
Test Specification
Baseline
```

を更新しただけでは終わらなかった。

Implementation Planが旧Baselineを固定参照していたため、

```text
BL-MVP-001
↓
BL-MVP-002
```

への変更が実行計画にも影響した。

学び：

> Baseline変更時はTechnical Documentsだけでなく、Execution / Implementation Planの固定参照も確認する必要がある。

---

## 2. Latest VersionとExecution Baselineは別管理が必要

`DOC-MVP-IMPL v0.1` 自体はApprovedでも、

```text
Execution Baseline = BL-MVP-001
```

だったため、新Baseline下でそのまま使うと矛盾した。

学び：

> 文書StatusがApprovedでも、その文書が「どのBaselineを前提としているか」は別途確認が必要。

---

## 3. Test FAILはProduction Defectとは限らない

P0 Integration Regression初回では、

```text
Resolved path is not based on ThisWorkbook.Path
```

でFAILした。

しかし実際には、

```text
Web URL
↓
Local Windows Path
```

というProduction挙動が現行Designどおりだった。

Test側が旧Designを前提としていた。

学び：

```text
Test FAIL
≠
Production Defect
```

分類候補：

```text
Implementation Defect
Test Defect
Design Gap
Requirement Gap
Environment Issue
```

を分ける重要性を再確認した。

---

## 4. Regression HarnessもDesign Changeへ追従させる必要がある

Productionコードと正式Test Specificationは更新されていたが、

```text
P0 Foundation Integration Smoke Test
```

という内部Regression Harnessだけが旧Assertionのまま残っていた。

学び：

> Design変更時のImpact Review対象には、正式仕様書だけでなくSmoke Test / Test Harnessも含める必要がある。

---

## 5. Test修正はProduction修正より慎重に分類する

今回Productionを修正していたら、

```text
d.docs.live.net
```

をそのままOFT Pathへ使う旧不具合へ戻してしまう可能性があった。

先に、

```text
Expectedが正しいか
Productionが正しいか
```

を分けて確認したことで不要な修正を防げた。

---

## 6. Historical ReferenceとActive Referenceを分ける価値

Implementation Plan v0.2では、

```text
BL-MVP-001
```

を完全削除しなかった。

残した場所：

```text
v0.2 Change History
v0.1 Historical Summary
```

Active Referenceからのみ除去した。

学び：

> 古いVersion番号やBaseline IDを機械的に全削除するのではなく、履歴Evidenceか現在参照かを区別する必要がある。

---

## 7. 文書管理をやりすぎないための境界も必要

BL-MVP-002にImplementation Planを追加しなかった。

理由：

```text
BL-MVP-002
= Technical Baseline

Implementation Plan
= Execution Plan
```

という責務分離を維持したため。

Baseline変更を理由にManifestへ何でも追加しないことが重要。

---

## 8. P0 RegressionをBlocking条件にしなかった判断は有効だった

P0 Integration Regressionは有用だったが、

```text
Baseline Approval
```

のBlocking条件にはしなかった。

結果として、

```text
Document Baseline Quality
Implementation Health
```

を分離できた。

Regressionは最終的にPASSしたため、現在は両方が健全な状態。

---

# 記事にできそうな切り口

## 開発日記向き

### 1. 「全部PASSしたと思ったら、昔のSmoke Testが落ちた」

流れ：

```text
P1-01完了
Baseline更新
Implementation Plan更新
↓
念のためP0 Regression
↓
FAIL
↓
Productionバグ？
↓
Test側が旧仕様だった
```

個人開発でありがちな「昔書いたTestに自分で刺される」話。

---

### 2. Baselineを更新したらImplementation Planまで古くなった

```text
BL-MVP-001
↓
BL-MVP-002
```

の変更によって、

```text
ApprovedなImplementation Plan
```

までImpact Reviewが必要になった事例。

「Approved = 永遠に正しい」ではないことを実例として書ける。

---

### 3. 「Testが赤いからコードを直す」をやめた話

今回Productionは正しく、Testが古かった。

記事テーマ：

> 赤いTestを見た瞬間にProduction Codeへ手を入れない。

---

### 4. 小さなExcel VBAツールでBaseline管理をやってみた

実際に、

```text
Latest Version
Approved
Current Baseline
Superseded Baseline
Execution Baseline
```

が別々になった。

机上論ではなく実運用で役立った話。

---

### 5. 一度壊れたExcel Workbookを作り直してRegressionした話

```text
Out of memory
↓
Workbook再構築
↓
Production Asset再投入
↓
P1-01 PASS
↓
P0 Integration Regression PASS
```

Excel VBA個人開発のリアルとして記事化可能。

---

# 技術記事向き

## 1. OneDrive上のExcel VBAでThisWorkbook.PathがURLになる問題

テーマ：

```text
https://d.docs.live.net/...
```

と、

```text
C:\Users\<User>\OneDrive\...
```

の違い。

内容：

- `ThisWorkbook.Path`
- OneDrive Web URL
- Local Sync Path
- Outlook `CreateItemFromTemplate`
- Path Resolution
- Fail Fast
- Smoke Test

---

## 2. VBA Smoke TestでLocal Path / OneDrive URLを分岐する

今回作成した、

```text
modP0FoundationIntegrationSmokeTest_v0.2_CP932.bas
```

を題材にできる。

論点：

- Windows絶対Path判定
- Web URL判定
- 相対Path末尾一致
- CP932 Module
- Test Assertionの責務

---

## 3. Regression Harness Driftとは何か

今回のケース：

```text
Production Design更新
Formal Test Spec更新
Smoke Test更新漏れ
```

Technical DebtとしてのTest Harness Driftを説明できる。

---

## 4. Baseline Change Impact Reviewの実例

流れ：

```text
Baseline更新
↓
Implementation Plan確認
↓
固定Baseline参照を検出
↓
Impact Review
↓
Candidate
↓
Consistency Review
↓
Approved
```

設計文書と実行計画をどう分離するかの記事に向く。

---

## 5. Active ReferenceとHistorical Referenceの分離

例：

```text
BL-MVP-001
```

を、

```text
Current Rule
Historical Change Record
```

で区別した実例。

Version管理・文書管理の技術記事として利用可能。

---

## 6. Excel VBAのIntegration Smoke Test設計

今回のP0 Test：

```text
Result / Error Model
Settings Data Access
Path Resolution
VariableDefinition Data Access
OptionMaster Data Access
Integrated Execution
```

小規模VBAでもLayer単位でSmoke Testを構成できる事例。

---

# 有料note / テンプレート化候補

## 1. Baseline Approval Quality Gateテンプレート

項目例：

```text
Document Registry最新
Baseline Version特定
Blocking Requirement Gap
Blocking Design Gap
Blocking Test Gap
Semantic Conflict
Traceability
Impact Review
Test Result責務分離
Baseline ID一意
```

---

## 2. Baseline Change Impact Reviewテンプレート

今回のImplementation Plan Review形式。

```text
対象Document
Old Baseline
New Baseline
Baseline差分
Direct Reference
Semantic Impact
Affected
Not Affected
Needs Revision
Revision Scope
Next Action
```

---

## 3. Plan Consistency Reviewテンプレート

確認項目：

```text
Execution Baseline
Manifest
Old Active Reference
Phase Structure
Checkpoint
Module Mapping
Design Reference
Test Reference
Entry Criteria
Scope Expansion
Blocking Conflict
```

---

## 4. Regression Harness Driftチェックリスト

Design Change後に確認する対象：

```text
Production Code
Formal Test Specification
Smoke Test
Unit Test
Integration Test
Test Data
Fixtures
Mocks
Expected Result
Documentation
```

---

## 5. Test FAIL分類テンプレート

```text
Observed
Expected
Production Evidence
Test Evidence

Classification:
Implementation Defect
Test Defect
Requirement Gap
Design Gap
Environment Issue
Documentation Issue

Production Change Required:
Yes / No

Test Change Required:
Yes / No
```

---

## 6. VBA Smoke Test Fail-Fast Template

今回の考え方：

```text
START
↓
Precondition
↓
Explicit Check
↓
Debug.Print Evidence
↓
FAIL → Cleanup → Exit
↓
PASS
```

---

## 7. AI生成TestコードReviewチェックリスト

今回までの学びをまとめられる。

```text
対象言語のEscape
Path Separator
Windows / URL差
Expectedの現行Design整合
Test Code自身のBug
Historical Assertion残存
Fail Fast
Cleanup
Evidence出力
```

---

# 次チャット開始時の最重要Handoff

```text
Current Phase:
P1 Walking Skeleton

P0 Foundation:
COMPLETE

CP-P0:
ESTABLISHED

New Workbook:
MailGenerator3.xlsm

New Workbook P0 Integration Regression:
PASS

P1-01 OFT Path / Outlook Connection:
PASS / COMPLETE

DF-P1-001:
CLOSED

TV-P1-001:
PASS

Current Approved Baseline:
BL-MVP-002

BL-MVP-001:
SUPERSEDED

Latest Approved Technical Documents:
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4

Implementation Plan:
DOC-MVP-IMPL v0.2
Status: Approved
Execution Baseline: BL-MVP-002

Latest Project Control:
定型メール作成ツール Project Document Registry and Approved Baseline v0.6.md

Latest P0 Regression Harness:
modP0FoundationIntegrationSmokeTest_v0.2_CP932.bas

P0 Regression Result:
PASS

P1-02 Entry:
READY

Next Implementation Task:
P1-02 Inspector / WordEditor Connection

Recommended First Task:
P1-02 Inspector WordEditor Connection 実施仕様 v0.1.md 作成
```

## Read First

```text
1. 定型メール作成ツール Project Document Registry and Approved Baseline v0.6.md

2. Implementation Plan v0.2 日本語版.md

3. MVP Design v0.1.8 日本語版.md

4. Technical Spike A 実施仕様書 v0.4 日本語版_CLOSED.md

5. MVP Test Specification v0.1.4 日本語版.md

6. P1-01 OFT Path Outlook Connection Completion Record v0.1.md

7. 最新 modOutlookAdapter

8. modP0FoundationIntegrationSmokeTest_v0.2_CP932.bas
```

## 次の目的

```text
P1-02
Inspector / WordEditor Connection
```

Production Vertical Slice：

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

P1-02ではScanner / Renderまで先回りせず、

```text
MailItem
→ Inspector
→ WordEditor
```

のProduction接続成立までを確認する。
