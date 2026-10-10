# 引き継ぎまとめ

## 現在地

この会話では、定型メール作成ツールのMVPについて、Technical Spike A完了後のBaselineを段階的にレビュー・修正し、最終的に以下の4文書を**正式Baselineとして使用可能な状態**まで確定した。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.5
        +
Technical Spike A v0.2 CLOSED
        +
MVP Test Specification v0.1.1
```

最終判定：

```text
Baseline Status：PASS / Ready
```

確認済み事項：

- Requirement Gap：なし
- Design Gap：なし
- Test Gap：なし
- Additional Technical Spike：現Baseline整合のためには不要
- Route W：WordEditorのTechnical Decisionは維持
- Technical Spike AはCLOSEDのまま
- MVP Test Specification v0.1.1はBaseline化可能
- FR：47 / 47 Traceability Mapping
- AC：20 / 20
- NFR：6 / 6
- Test Case：69件
- Test Case一覧／詳細のID不一致：0件
- Test ID重複：0件

次工程は、Test Specification §27の流れに従えば、

```text
Technical Spike B / C 要否確認
        ↓
Implementation Plan v0.1
        ↓
VBA実装
        ↓
MVP Test実施
```

となる。

ただしTechnical Spike B / Cの具体的な内容・実施要否は、この会話では確定していない。

---

# 実施内容

## 1. Baseline 3文書の最終整合性レビュー

最初のBaseline：

```text
MVP Requirements v0.1.5
+
MVP Design v0.1.3
+
Technical Spike A v0.2 CLOSED
```

を対象に、以下の観点で最終整合性レビューを実施した。

- Version / 参照整合
- Requirement → Design Traceability
- Technical Spike A Decision反映
- Body処理方式の整合
- UserForm / Sync / Render / Unresolved / Outlook Lifecycle
- Requirement Gap有無

作成：

- `Baseline 最終整合性レビュー v0.1.md`
- `Baseline 最終整合性修正 差分パッチ v0.1.md`

### 抽出した主なFinding

#### CR-001
メール生成直前にCurrent OFTを再確認する経路が不足。

課題：

```text
UserForm起動時にOFT確認
↓
UserForm表示
↓
その間にOFT変更
↓
メール生成
```

の場合、変更後OFTをRender前に再確認できていなかった。

対応方針：

```text
生成用MailItem
↓
Subject / BodyText取得
↓
Template Scanner
↓
Configuration Validator
↓
Render
```

とする。

#### CR-002
FR-UNRESOLVED-002の「未置換Variable一覧表示」に必要なResult構造が不足。

追加した概念：

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

#### CR-003
Select型ComboBoxの自由入力禁止がDesign上未明示。

対応：

```text
fmStyleDropDownList 相当
```

の選択専用ComboBoxとする。

#### CR-004
以下のSync更新規則が不足。

- TemplateLocation
- FirstDetectedAt
- LastDetectedAt

New / Existing / Reactivated / Unusedごとに更新規則を定義した。

#### CR-005
Unused Variableについて、

- 通常は非表示
- 必要時は確認可能

というDesign責務が暗黙的だったため明文化した。

#### CR-006
Requirements §34の次工程が旧 `MVP Design v0.1.2 Reopen` を指していた。

文書の現在地へ更新した。

---

## 2. MVP Requirements v0.1.6 作成

`Baseline 最終整合性修正 差分パッチ v0.1` のRequirements部分をレビューした。

元Patchでは、

```text
Design v0.1.4で補完済み
```

と未来工程を先取りしていたため修正。

Requirementsを先に確定し、その後Designを更新する順序へ変更した。

作成：

- `MVP Requirements v0.1.6 日本語版.md`

### v0.1.6で変更したもの

- Version
- v0.1.6更新概要
- §34 次工程

### 変更しなかったもの

- FR本文
- Acceptance Criteria
- NFR
- MVP保証範囲

QA：

```text
FR  = 47
AC  = 20
NFR = 6
```

Requirement追加・削除なし。

---

## 3. MVP Design v0.1.4 作成

Requirements v0.1.6を上位BaselineとしてDesign v0.1.3を修正。

作成：

- `MVP Design v0.1.4 日本語版.md`

主な反映：

### Current OFT Guard

UserForm表示後にOFTが変更されても安全側にFailできるよう、

```text
生成用MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText
↓
Template Scanner
↓
Configuration Validator
↓
Render
```

とした。

### Unresolved Result

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

を定義。

Variable一覧はCase Insensitiveで重複統合。

### Select

Select用ComboBoxは自由入力不可。

```text
fmStyleDropDownList 相当
```

をDesignへ明記。

### Sync metadata

以下をNew / Existing / Reactivated / Unusedごとに定義。

- TemplateLocation
- FirstDetectedAt
- LastDetectedAt
- SyncTimestamp

### Unused Variable

```text
通常設定
→ Activeのみ

Unused確認
→ 全件
```

とした。

### InputValues

Workbook Session中のメモリ上にのみ保持し、永続保存しないことを明文化。

---

## 4. 3文書の再レビュー

Baseline：

```text
Requirements v0.1.6
+
Design v0.1.4
+
Technical Spike A CLOSED
```

を再レビュー。

前回CR-001〜006がCloseしていることを確認した。

その過程で新たに2点抽出。

### FCR-001
Mail生成時Input Validatorが、Current VariableDefinition / OptionMaster取得前に実行されていた。

旧Sequence：

```text
InputValues
↓
Input Validator
↓
VariableDefinition / OptionMaster取得
```

問題：

UserForm表示後にOptionMaster等が変更された場合、古い設定でValidationする可能性がある。

### FCR-002
Input State保持期間表現の不一致。

Design §5：

```text
Excel終了まで
```

Requirements / Design §18.2：

```text
Workbookを閉じるまで
```

---

## 5. Design v0.1.4 → v0.1.5 差分パッチ

作成：

- `MVP Design v0.1.4→v0.1.5 最終整合性差分パッチ v0.1.md`

対象はFCR-001 / FCR-002のみ。

### FCR-001対応

Mail生成時：

```text
InputValues
↓
Current VariableDefinition / OptionMaster取得
↓
Input Validator
↓
Current OFT Scan
↓
Configuration Validator
↓
Render
```

とした。

同一Mail生成処理内のCurrent Dataを、

- Input Validator
- Configuration Validator

で共有。

新しいSnapshot管理やVersion管理は追加しなかった。

### FCR-002対応

```text
Input State
→ Workbookを閉じるまで
```

へ統一。

---

## 6. MVP Design v0.1.5作成

Patchを再レビューした上で全文反映。

作成：

- `MVP Design v0.1.5 日本語版.md`

QA：

- FCR-001 Close
- FCR-002 Close
- Activeなv0.1.4自己参照なし
- Requirements v0.1.6参照
- Route W維持
- Requirement Gapなし

---

## 7. Baseline 3文書の最終確認

対象：

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
```

確認結果：

```text
PASS
```

FCR-001 / FCR-002ともCLOSED。

新しい矛盾なし。

Test Specification開始を妨げる残課題なし。

---

# 8. MVP Test Specification v0.1 作成

Baseline 3文書を入力としてTest Specification初版を作成。

作成：

- `MVP Test Specification v0.1 日本語版.md`

Test設計方針：

```text
Requirement
↓
Acceptance Criteria
↓
Design Component / Design Rule
↓
Test Case
↓
Evidence
↓
Result
```

Acceptance CriteriaだけではCoverage不足と判断し、

- Acceptance Test
- Supplementary Test

に分けた。

### Test Status

```text
NOT RUN
PASS
FAIL
BLOCKED
N/A
```

### Test分類

- Configuration
- Functional
- Integration
- Negative
- Regression
- Manual Visual
- Design Review

### Technical Spike A引継ぎ

Technical Spike AでPASSした項目も、本番MVP実装に対してRegression Testとして再確認する方針。

特にTF-A-002を受けて、

```text
A. Variableを正しく検出できた
B. Render後にUnresolvedが0件
```

を別Testとした。

---

# 9. MVP Test Specification v0.1 Baseline整合性レビュー

Test Specification v0.1をBaseline 3文書へ再照合。

作成：

- `MVP Test Specification v0.1 Baseline整合性レビュー v0.1.md`

判定：

```text
CONDITIONAL PASS
```

### 抽出したFinding

#### TSR-001
Mandatory TestがFAILでもTest Gate上PASSできる余地。

修正：

```text
Mandatory Test
→ PASS必須
```

#### TSR-002
UserForm起動時の2Scenario不足。

追加：

```text
MTS-CFG-007
Template未登録Variable
```

```text
MTS-CFG-008
Template削除済みActive Variable
```

どちらも、

- UserForm停止
- 自動同期しない

ことを確認。

#### TSR-003
Invalid Variable Syntaxについて、

- Sync停止
- UserForm停止
- Mail生成停止
- 実際の不正記述をユーザーが確認可能

までのCoverage不足。

#### TSR-004
DateをValidation後に「日付値」として扱うことの直接Evidence不足。

#### TSR-005
Optional空欄VariableについてBodyしか確認しておらず、Subject側不足。

#### TSR-006
OptionMasterとVariableDefinitionの分離を直接確認していない。

#### TSR-007
Design `RISK-DES-003`：

実使用Variable数でUserFormが利用可能か未確認。

#### TSR-008
NFR-006をConditional Testにしており、RequirementをTest側で弱める可能性。

#### TSR-009
`MTS-SAFE-004` と `MTS-VAL-005` が重複。

#### TSR-010
`MTS-NFR-004` は実行TestというよりSummary Gate。

#### TSR-011
Date 6 Format Expectedが具体値不足。

#### TSR-012
同じ実行Evidenceを複数Testで再利用可能。

---

# 10. MVP Test Specification v0.1 → v0.1.1差分パッチ

作成：

- `MVP Test Specification v0.1→v0.1.1 差分パッチ v0.1.md`

TSR-001〜012をすべて反映。

主な変更：

### Test Gate

```text
Mandatory TestにFAIL / BLOCKEDが残る
→ PASS不可
```

### CFG追加

```text
MTS-CFG-007
Template未登録Variable
```

```text
MTS-CFG-008
Template削除済みActive Variable
```

### UserForm Risk

```text
MTS-UI-005
実使用Variable数でのUserForm利用可能性
```

### Date Test

例：

```text
Raw Input:
2026-9-30

Internal Meaning:
2026-09-30

Format:
yyyy/mm/dd

Expected:
2026/09/30
```

6 Formatすべて具体値化。

### Optional空欄

Subject / Body双方で確認。

### OptionMaster

VariableDefinitionにはOptionSourceのみ。

ComboBoxのOptionはOptionMasterから取得することをEvidence化。

### NFR

`MTS-NFR-006`：

```text
Conditional
↓
Mandatory Design Review
```

### 重複削除

`MTS-SAFE-004` をRetired。

`MTS-VAL-005` に統合。

### Safety

`MTS-NFR-004` をSummary Gate化。

---

# 11. MVP Test Specification v0.1.1作成

Patchをレビュー後、全文反映。

作成：

- `MVP Test Specification v0.1.1 日本語版.md`

QA結果：

```text
Test Case一覧 : 69
詳細Test Case : 69
ID欠落       : 0
余分なID     : 0
重複ID       : 0
Mandatory    : 69
Conditional  : 0
```

`MTS-SAFE-004` はActive Testから完全削除。

---

# 12. Baseline 4文書 最終整合性チェック

対象：

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1.1
```

作成：

- `Baseline 4文書 最終整合性チェック v0.1.md`

最終判定：

```text
PASS — Ready
```

確認結果：

```text
FR  : 47 / 47 referenced
AC  : 20 / 20 referenced
NFR : 6 / 6 referenced
```

さらに、

```text
Test Case一覧 = 69
Test Case詳細 = 69
未定義Test ID参照 = 0
```

を確認。

---

# 決定事項

## Baseline

正式Baselineとして以下を使用する。

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1.1
```

Baseline Status：

```text
PASS / Ready
```

---

## Technical Spike A

Technical Spike AはCLOSEDのまま維持する。

### 採用

```text
Route W
Inspector.WordEditor
Word Document
Range.Find
Range.Text
```

### 不採用

```text
Route H
MailItem.HTMLBody
```

理由：

通常作成したOFTでもVariableがHTML内部で、

```html
{{<span class=SpellE>ModelName</span>}}
```

のようにタグ分断される場合があり、Scanner / Renderer / Unresolved Checkerが不安定になるため。

---

## Requirements

`MVP Requirements v0.1.6` では、

- 47 FR
- 20 AC
- 6 NFR

を維持。

この会話で新しい利用者Requirementは追加していない。

---

## Body処理

Subject：

```text
String処理
Subject Renderer
```

Body：

```text
Outlook Adapter
↓
Inspector.WordEditor
↓
Word Range.Find
↓
Range.Text
```

Body全文をPlain Textへ戻して再設定する方式は採用しない。

---

## Scanner / Unresolved

Core LogicにはWord Object Modelを渡さない。

```text
Word Document
↓
Outlook Adapter
↓
BodyText
↓
Template Scanner / Unresolved Checker
```

とする。

---

## Current Data Validation

Mail生成時はUserForm起動時の設定を無条件に信用しない。

```text
Current VariableDefinition
+
Current OptionMaster
↓
Input Validator
```

Current OFTもRender前に再Scanする。

---

## Select

Select型は自由入力不可。

```text
fmStyleDropDownList 相当
```

---

## Input State

InputValuesは、

```text
Workbookを閉じるまで
```

保持。

Excelシートや外部ファイルへ永続保存しない。

---

## Unresolved

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

未置換Variableが1件でもある場合：

- OutlookへDisplayしない
- 一覧表示
- 保存せず終了

---

## Test Governance

Test Result：

```text
NOT RUN
PASS
FAIL
BLOCKED
N/A
```

Mandatory Test：

```text
FAIL / BLOCKEDが残る
→ MVP PASS不可
```

N/A：

Baseline上適用外であることを説明できる場合のみ。

---

## Test Coverage

`47 / 47 FR` は、

```text
Traceability Mapping Coverage
```

を意味する。

Test実行後のPASS Coverageとは区別する。

---

## NFR-006

Conditionalではなく、

```text
Mandatory Design Review
```

とする。

将来型そのものを実装する必要はない。

---

## Technical Spike Evidence

Technical Spike AのPASSを本番実装Testの代替にはしない。

MVP実装でRegression Testを行う。

---

# 未解決事項

## 1. Technical Spike B / C

**要確認。**

Test Specification §27では次工程候補として、

```text
Technical Spike B / C 要否確認
```

が残っている。

この会話では、

- Spike Bとは何を検証するのか
- Spike Cとは何を検証するのか
- 本当に実施する必要があるか

は確定していない。

次チャットで確認が必要。

---

## 2. Implementation Plan v0.1

未作成。

次工程として作成する可能性が高い。

必要事項例：

- 実装順序
- VBA Module単位
- Dependency順
- Phase分割
- Testとの対応
- 完了条件
- Commit / Checkpoint戦略

ただし具体構成は未決定。

---

## 3. Technical Spike A 環境情報

以下は後日確認のまま。

- OS
- Excel Version
- Excel Bitness
- Classic Outlook Version
- Outlook Bitness
- VBA実行Workbook
- 実施者

Technical DecisionをBlockしないNon-Blocking metadataとしてCLOSED済み。

確認できた時点で追記可能。

---

## 4. 実装

VBA実装はまだ開始していない。

未実装：

- Excel Data Access
- Outlook Adapter
- Template Scanner
- Sync Engine
- Configuration Validator
- Input Validator
- Value Formatter
- Subject Renderer
- Unresolved Checker
- Dynamic UserForm
- Input State
- Error / Result Model

---

## 5. MVP Test実施

Test Specificationは作成済みだが、

```text
全69 Test Case = NOT RUN
```

の状態。

Test Result / Evidenceは未作成。

---

# 次アクション

## 優先度1：Technical Spike B / C 要否確認

次チャットでは最初に、

```text
Technical Spike B / Cとは何を検証予定だったか
```

を確認する。

見るファイル：

- `MVP Requirements v0.1.6 日本語版.md`
- `MVP Design v0.1.5 日本語版.md`
- `MVP Test Specification v0.1.1 日本語版.md`
- 既存のTechnical Spike B / Cに関する過去資料があればそれも確認

判断すること：

- Spike B / Cがまだ必要か
- Test Specificationで既に吸収できるか
- Implementation前に技術成立性Evidenceが必要か
- 実装してからTestすれば十分な内容ではないか

---

## 優先度2：Implementation Plan v0.1作成

Spike B / Cが不要、または完了後に進む。

候補構成：

```text
Phase 1
Excel Data Access / Result Model

Phase 2
Template Scanner / Sync Engine

Phase 3
Configuration Validator / UserForm

Phase 4
Input Validator / Value Formatter

Phase 5
Outlook Adapter / WordEditor

Phase 6
Unresolved / Error / Lifecycle

Phase 7
E2E / Test
```

ただしこれは候補であり、まだ決定していない。

---

## 優先度3：Test実施準備

実装前後で必要。

確認するもの：

- Test用Excel Workbook
- Test用OFT
- Baseline Test Data
- Test環境Version
- Evidence保存方法
- Test Build識別方法

---

# 気づき

## 1. TraceabilityがあるだけではCoverageとは言えない

今回、

```text
47 / 47 FR
```

と表示できても、Requirement本文の条件単位ではTest抜けが見つかった。

重要なのは、

```text
Requirement ID Mapping
≠
Condition Coverage
```

という点。

これはTest Specification設計で非常に重要な学び。

---

## 2. Test SpecificationはRequirementを弱めることもある

NFR-006を最初、

```text
Conditional
```

としていた。

しかしBaselineではRequirementなので、Test側が勝手にOptional化するとRequirementを弱めることになる。

Test Specificationは単にTestを並べるだけでなく、

```text
Baseline Requirementを
強めても
弱めてもいけない
```

という視点が必要。

---

## 3. 「検出0件」は安全性の証明にならない

Technical Spike Aでは、

```text
Variableを検出できていない
↓
未置換Variable 0件
↓
PASS
```

というFalse Positiveが発生した。

学び：

```text
検出機構が成立しているか
```

と、

```text
検出結果が0件か
```

は別々に確認する必要がある。

Test Specificationでは、

```text
MTS-UNR-004
```

として独立確認することにした。

---

## 4. Versioned Documentの「次工程」はSnapshotとして扱う

下流文書が進むたびに上位文書の「次工程」を更新すると、

```text
Requirements更新
↓
Design参照更新
↓
Design更新
↓
Requirementsがまた古くなる
```

というVersion Churnが発生する。

そのため、

- Versioned Document：そのVersion作成時のSnapshot
- Current進捗：Handoff / Review / Project Status

として分離する方がよい。

---

## 5. Current Dataを使う設計はSafetyに効く

UserFormを開いている間に、

- OFT
- VariableDefinition
- OptionMaster

が変更される可能性がある。

そのため生成時にはCurrent Dataを取り直す。

これは単なる実装詳細ではなく、

```text
ユーザー操作開始時の状態
≠
メール生成時の状態
```

という時間差問題への対処。

---

## 6. Technical Spikeは「そのまま実装Testの代替」ではない

Spikeは技術成立性を確認するEvidence。

実際のMVPコードで、

- Scanner
- Renderer
- Lifecycle
- Formatting

が成立するかはRegression Testが必要。

---

## 7. Test重複とCoverageは別問題

同じ操作を、

```text
Validation Test
Safety Test
```

として二重実行する必要はない。

同じEvidenceを複数Requirement / Test Caseへ参照できる。

Coverageを維持しつつ実行負荷を減らせる。

---

## 8. 「新しいRequirementか」「既存Requirementの具体化か」を毎回分ける

今回追加した、

- Current OFT再確認
- Current OptionMaster Validation
- CFG-007 / 008
- UserForm Layout確認

などは、新Requirementではなく既存Baselineを安全に確認するためのDesign/Test具体化だった。

Design / Testレビューで重要な判断軸。

---

# 記事にできそうな切り口

## 開発日記向き

### 1. 「あと1回だけレビュー」が何回も続いた理由

- Requirements
- Design
- Technical Spike
- Test Specification

を往復しながら、

```text
CR
↓
FCR
↓
TSR
```

と問題が段階的に見つかった過程。

「最初から完璧に作る」のではなく、Baselineを段階的に締めていく実際の開発プロセスとして書ける。

---

### 2. 47/47なのにTest抜けがあった話

一見、

```text
Coverage 100%
```

なのに条件単位では抜けがあった。

個人開発でTraceabilityを導入した結果見えた盲点として記事にしやすい。

---

### 3. AIと文書レビューを繰り返したらVersion Churn問題に気づいた

Requirementsの「次工程」を毎回更新すると文書Versionが連鎖して上がる。

最終的に、

```text
文書 = Snapshot
進捗 = Handoff / Review
```

と整理した話。

---

### 4. 技術検証がPASSしたのにTestで再検証する理由

Technical Spike AでWordEditorがPASS。

それでもMVP Test SpecificationへRegression Testを残した理由。

---

### 5. 「もう完成だと思ったDesign」に2つの穴が残っていた

- Current OptionMaster
- Workbook lifetime

のFCR-001 / FCR-002。

小さい差異でもSafety Requirementへ影響する話。

---

# 技術記事向き

## 1. Outlook OFTのHTMLBody置換が不安定だった理由

実例：

```html
{{<span class=SpellE>ModelName</span>}}
```

Visible TextとHTML内部表現の違い。

HTMLBody方式とWordEditor方式の比較記事。

---

## 2. Classic Outlook OFTをWordEditorで安全に置換する設計

構成：

```text
Inspector.WordEditor
↓
Word Document
↓
Range.Find
↓
Range.Text
```

HTML Encode不要。

書式を壊さずVariableを置換する考え方。

---

## 3. COM依存をCore Logicへ漏らさない方法

```text
Word Document
↓
Outlook Adapter
↓
BodyText
↓
Core Logic
```

として、

- Scanner
- Unresolved Checker

へCOM Objectを渡さない設計。

---

## 4. False Positiveを防ぐTest設計

```text
Detectorが正常
```

と、

```text
結果が0件
```

を別Testにする。

TF-A-002を一般化できる。

---

## 5. Requirement→Design→TestのTraceability設計

```text
Requirement
↓
Acceptance Criteria
↓
Design Rule
↓
Test Case
↓
Evidence
```

ID Mapping CoverageとCondition Coverageの違いまで含められる。

---

## 6. Configuration DrivenなVBA UserForm設計

- VariableDefinition
- OptionMaster
- Dynamic UserForm
- Type / Control Mapping
- Required
- SortOrder

を使ってOFT固有コードを減らす設計。

---

## 7. UserForm表示後に設定が変わる問題への対処

```text
UI起動時Snapshot
≠
Mail生成時Current State
```

として、

- VariableDefinition
- OptionMaster
- OFT

を生成時に再確認するSafety Design。

---

# 有料note / テンプレート化候補

## 1. AI協働開発 Baseline整合性レビューチェックリスト

チェック項目例：

- Version参照
- Requirement→Design
- Design→Test
- Technical Spike Decision
- Requirement Gap
- Design Gap
- Test Gap
- Current State Safety
- Version Churn

---

## 2. Requirement → Design → Test Traceability Template

テンプレート：

```text
Requirement ID
Acceptance Criteria
Design Component
Design Rule
Test Case
Evidence
Result
Finding
```

---

## 3. Technical Spike Close Template

含めるもの：

- Hypothesis
- Route比較
- Gate
- Evidence
- Finding
- Decision
- Rejected Route
- Regression Handoff
- Close Criteria

---

## 4. Test Specification Template

今回作成した構造を汎用化できる。

- Baseline
- Test方針
- Result Status
- Evidence
- Test Data
- Test Case一覧
- 詳細Test
- AC Traceability
- FR Coverage
- NFR Coverage
- Technical Spike Regression
- Entry Criteria
- Exit Criteria
- Finding分類
- Test Gate

---

## 5. 「Coverage 100%」を疑うレビューPrompt

AIへ、

```text
IDがTestへ紐付いているかではなく、
Requirement本文の各条件が
実際にExpected Resultへ落ちているか確認せよ
```

と指示するPromptテンプレート。

---

## 6. Requirement Gap / Design Gap / Test Gap 判定表

例：

| 状況 | 分類 |
|---|---|
| 利用者の振る舞いを新しく決める必要 | Requirement Gap |
| Requirementは明確だが内部方式不足 | Design Gap |
| Requirement / Designは明確だが検証不足 | Test Gap |
| 実装だけが違う | Implementation Defect |

AI協働開発用判断基準としてテンプレート化しやすい。

---

## 7. Baseline Freeze Checklist

次工程へ進む前に、

```text
Requirements
Design
Technical Spike
Test Specification
```

をFreeze可能か確認するChecklist。

今回の最終確認プロセスをそのままテンプレート化できる。