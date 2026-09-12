# 引き継ぎまとめ

## 実施内容

### 1. 前会話からの引き継ぎ確認

- 前会話で作成済みだった以下の内容を前提に作業を再開した。
  - `MVP Requirements v0.1.1 日本語版.md`
  - `MVP Design v0.1 日本語版.md`
  - Requirements残課題5件の確定内容
  - MVP Design D01〜D15の設計決定
  - Designヒアリング中に利用者向け振る舞いが新たに発生した場合は `Requirement Gap` としてRequirementsへ戻す運用ルール
- 次工程として、実装やTest Specificationへ進む前に、RequirementsとDesignの正式な整合性レビューを行う方針を採用した。

---

### 2. `MVP Requirements v0.1.1 × MVP Design v0.1` 正式整合性レビュー

#### レビュー方法

全文を文章ベースで読むだけではなく、Traceability Matrixを一時的に作り、以下の観点で機械的に確認した。

- RequirementがDesignで実現可能か
- DesignがRequirementにない利用者挙動を追加していないか
- RequirementsがDesignへ委譲した項目が処理されているか
- 未決事項が本当にDesign Decisionか
- Implementation Detailまで設計しすぎていないか
- 同一責務が複数Moduleへ重複していないか
- MVPとして不要な抽象化がないか
- AC-001〜AC-020がテスト可能か
- Technical Spikeが必要な不確実性は何か

判定区分：

- `OK`
- `Design Gap`
- `Requirement Gap`
- `Implementation Detail`

#### レビュー結果

- D01〜D15はすべてDesignへ反映されていることを確認。
- 軽量レイヤード構成、Data Access分離、Scanner、Sync Engine、Configuration Validator、UserForm、Input Validator、Renderer、Outlook Adapter、Result/Error設計などの骨格に重大な問題はなかった。
- Designを全面的にやり直す必要はないと判断。

一方で以下を検出した。

#### RG-001

`Required=False` のDate / Selectが空欄・未選択の場合の扱いがRequirements上で曖昧。

例：

```text
Type = Date
Required = False
Value = ""
```

```text
Type = Select
Required = False
Value = 未選択
```

#### RG-002

AC-017の、

```text
OFTの主要な本文書式が維持される
```

というPass条件が曖昧で、Test SpecificationでPASS / FAIL判定できない。

#### DG-001

UserForm起動前に、現在のOFTをどうScanしてConfiguration Validatorへ渡すのか、Design上の処理経路が不足。

旧イメージ：

```text
UserForm起動
↓
Configuration Validator
```

では、Configuration Validatorが現在のOFT内Variableを取得できない。

---

### 3. Requirement Gap RG-001 / RG-002 GrillMe

2件のみを一問一答・択一形式で確定した。

#### RG-001：Required=False時のValidation

選択：

- **A**

確定仕様：

```text
Required=False
+
空欄 / 未選択
→ 正常

値あり
→ Typeに応じてValidation
```

意味：

- `Required` = 入力必須かどうか
- `Type` = 入力された値の妥当性

例：

```text
Date + Required=False + 空欄
→ OK

Date + Required=False + abc
→ Error

Select + Required=False + 未選択
→ OK

Select + Required=False + 無効値
→ Error
```

---

#### RG-002：Body書式維持範囲

選択：

- **A**

MVPで保証対象とする基本書式：

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

MVP保証対象外：

- 埋め込み画像
- 複雑なHTML構造
- 特殊なOutlook固有書式
- Variable文字列途中がHTMLタグ等で分断されるケース

AC-017は、

```text
代表的なOFTを用いたテストにおいて、
Body内のVariableが正しく置換され、
Variable置換部分以外の基本的な本文書式が維持されること
```

という方向で明確化した。

---

### 4. `MVP Requirements v0.1.2` 作成

RG-001 / RG-002をRequirementsへ反映。

作成ファイル：

- `MVP Requirements v0.1.2 日本語版.md`

主な変更：

- FR-VAL-001
  - `Required=False` の空欄 / 未選択を有効と明文化
  - 値が存在する場合のみType Validation
- FR-RENDER-BODY-002
  - 基本書式の保証範囲を明文化
- AC-017
  - 「主要な本文書式」という曖昧表現をテスト可能な条件へ変更

---

### 5. DG-001修正として `MVP Design v0.1.1` 作成

作成ファイル：

- `MVP Design v0.1.1 日本語版.md`

DG-001の解消としてUserForm起動前シーケンスを修正。

修正後：

```text
メール作成開始
↓
Settings Data Access
↓
TemplatePath取得
↓
OFT存在確認
↓
Outlook Adapter
↓
Scan用MailItem
↓
Subject / HTMLBody取得
↓
Template Scanner
↓
Candidate Scan
↓
VariableName Validation
↓
TemplateScanResult
↓
Scan用MailItem破棄
↓
VariableDefinition / OptionMaster取得
↓
Configuration Validator
↓
整合性判定
↓
UserForm生成
```

#### Scanner / Validator責務の整理

旧Designでは、

```text
Template Scanner
→ VariableName Validation

Configuration Validator
→ ValidateVariableSyntax()
```

となっており、Regex判定が二重実装される余地があった。

修正後：

```text
Template Scanner
→ Syntaxを判定

Configuration Validator
→ TemplateScanResultを評価
→ Configuration Errorとして停止するか判断
```

`TemplateScanResult`イメージ：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

---

### 6. `Requirements v0.1.2 × Design v0.1.1` 最終整合性レビュー

差分中心に再レビューした。

RG-001 / RG-002 / DG-001の主問題は解消したが、Close前に4件の小規模Patchが必要と判定。

#### 残った4件

1. Optional空欄のRender処理
2. OFT不存在時の明示的Fail Fast分岐
3. Requirements §32の工程責務分類
4. FR-OUTLOOK-001のMailItem生成タイミング

---

### 7. 4件を `Requirements v0.1.3 / Design v0.1.2` へPatch

#### Patch 1：Optional空欄Render

問題：

```text
Required=False
+ Date / Select空欄
→ Input Validator OK
```

までは決まったが、Formatter / Rendererで未入力Variableをどう扱うか未明示だった。

Designへ追加：

```text
Required=False
+
InputValue = 空欄 / 未選択
↓
Value Formatter
↓
Formatted Value = ""
↓
Renderer
↓
{{VariableName}} を空文字列へ置換
```

これにより、Optional Variableが未置換Variableとして残る問題を防止。

---

#### Patch 2：OFT不存在時Fail Fast

Design §25.1 / §25.2へ明示的分岐を追加。

```text
OFT存在？
├─ No
│  ↓
│ Error Result
│  ↓
│ UI通知
│  ↓
│ Stop
│
└─ Yes
   ↓
後続処理
```

対象：

- 手動同期
- UserForm起動

---

#### Patch 3：Requirements §32工程分類

旧Requirementsでは、

```text
MVP Designで具体化する事項
```

にImplementation DetailやTest Specification事項まで混在していた。

以下へ再分類。

```text
32.1 MVP Designで決める事項
32.2 Implementationで決める事項
32.3 MVP Test Specificationで決める事項
```

例：

Design：

- Layer / Module責務
- Scanner責務
- Binding方針
- Formatter / Renderer責務
- Outlook Adapter責務

Implementation：

- Validation強調色
- 曜日生成の具体的VBAコード
- HTML Encode関数
- 同期結果の具体的UI
- OFT復旧UI
- Error Code体系

Test Specification：

- テストケース
- Boundary Case
- Acceptance Criteria検証方法

---

#### Patch 4：FR-OUTLOOK-001

旧Requirementでは、

```text
すべてのValidationと未置換チェック成功後にMailItemを生成する
```

という内部オブジェクト生成タイミングまで規定していた。

修正後：

- 内部MailItem生成タイミングはDesignへ委ねる。
- 利用者向けRequirementとしては、

```text
Validation
Render
未置換Variable Check
```

に成功した場合のみClassic Outlook上へDisplayする。

これにより、

```text
Input Validation
↓
MailItem生成
↓
Render
↓
Unresolved Check
↓
Display
```

というDesignと整合。

作成ファイル：

- `MVP Requirements v0.1.3 日本語版.md`
- `MVP Design v0.1.2 日本語版.md`

---

### 8. `Requirements v0.1.3 × Design v0.1.2` 差分レビュー

前回4件だけを再確認。

結果：

- Optional空欄処理：PASS
- OFT Fail Fast：PASS
- FR-OUTLOOK-001：PASS
- Requirements §32工程再分類：PARTIAL

§32自体は修正済みだったが、Requirements本文に旧表現、

```text
具体的な○○はMVP Designで決定する
```

が残存していた。

確認した主な箇所：

- OFT復旧UI
- Invalid Syntaxの具体エラー表示
- 曜日表記生成
- Validation強調色 / Tag
- HTML Encode方式

---

### 9. `MVP Requirements v0.1.4` 最終Patch

上記5箇所程度の工程責務表現だけを機械的に修正した。

作成ファイル：

- `MVP Requirements v0.1.4 日本語版.md`

修正内容：

#### OFT Error

```text
Design
→ Fail Fast / Error Result責務

Implementation
→ 具体的な復旧UI
```

#### Invalid Variable Syntax

```text
Design
→ Scanner / Error責務

Implementation
→ 具体的メッセージ / Error Code
```

#### Date

```text
Design
→ Date Format規則 / Value Formatter責務

Implementation
→ 曜日生成の具体的VBAコード
```

#### Validation強調

```text
Design
→ UIが該当Controlを強調する
→ Tag = VariableName

Implementation
→ 強調色など具体表示
```

#### HTML Encode

```text
Design
→ Body Renderer側でEncodeする
→ Encode適用位置

Implementation
→ 具体的Encode関数
```

---

### 10. Design v0.1.2の上位Requirements参照更新

正式Close対象を、

```text
MVP Requirements v0.1.4
×
MVP Design v0.1.2
```

とするため、Design v0.1.2内の上位Requirements参照だけをv0.1.4へ更新。

Design Decisionや設計内容自体は変更していない。

最終ファイル：

- `MVP Requirements v0.1.4 日本語版.md`
- `MVP Design v0.1.2 日本語版.md`

---

### 11. 最終Close判定

最終差分確認結果：

```text
Requirement Gap
RG-001                Closed
RG-002                Closed

Design Gap
DG-001                Closed

Document Consistency
Optional空欄          PASS
OFT Fail Fast         PASS
§32工程責務           PASS
FR-OUTLOOK-001        PASS
本文工程表現5箇所     PASS

新規Requirement Gap   0
新規Design Gap        0
Blocking Issue        0
```

正式判定：

```text
MVP Requirements v0.1.4
→ Requirements Baseline

MVP Design v0.1.2
→ CLOSED
```

---

# 決定事項

## Requirements

### RG-001：Required=False

採用：

```text
Required=False
+
空欄 / 未選択
→ 正常
```

値が入力された場合のみType Validationを実施する。

判断理由：

- `Required` の意味をTypeによらず統一できる
- Text / Date / Selectで一貫した仕様になる
- Validation責務が明確になる

---

### Optional VariableのRender

採用：

```text
Required=False
+
空欄 / 未選択
↓
Formatted Value = ""
↓
Variableを空文字列へ置換
```

未置換Variableとして残さない。

---

### RG-002：Body書式維持

MVP保証対象：

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

保証対象外：

- 埋め込み画像
- 複雑なHTML
- 特殊なOutlook固有書式
- Variable文字列途中がHTMLタグ等で分断されるケース

---

## Design

### UserForm起動前Template確認

採用：

```text
OFT
↓
Outlook Adapter
↓
Scan用MailItem
↓
Subject / HTMLBody
↓
Template Scanner
↓
TemplateScanResult
↓
Configuration Validator
↓
UserForm
```

---

### Variable Syntax責務

採用：

```text
Template Scanner
→ Syntax判定

Configuration Validator
→ Scan結果を評価して処理可否を判断
```

Regex判定を複数Componentへ重複させない。

---

### OFT不存在

採用：

```text
OFT存在？
No
↓
Error Result
↓
UI通知
↓
Stop
```

対象：

- 手動同期
- UserForm起動
- テンプレート依存処理

---

### MailItem生成タイミング

内部MailItemの生成タイミングはDesign / Implementationへ委ねる。

利用者向けRequirementは、

```text
Validation
Render
Unresolved Check
```

成功時のみOutlook上へDisplayすること。

---

### 工程責務

Requirements §32を、

- MVP Design
- Implementation
- MVP Test Specification

へ分離する方針を採用。

MVP Designでは実装方式の全詳細まで確定しない。

---

### MVP Design正式Close

確定：

```text
MVP Requirements v0.1.4
→ Baseline

MVP Design v0.1.2
→ CLOSED
```

---

# 未解決事項

## Technical Spike：RISK-DES-001

最重要の未確認事項。

OFTのHTMLBody内で、

```text
{{VariableName}}
```

が連続文字列として保持されるか未確認。

可能性：

```html
{{Variable<span>Name}}
```

など、HTMLタグによりVariable文字列が分断される可能性がある。

現時点の扱い：

- MVP Designの未完了事項ではない
- Technical Spike対象
- MVP保証対象外としてRequirements境界は定義済み
- 通常のテンプレート作成方法でもScanner / Renderer方式が成立しない場合はRequirement Gapとして再度DesignをReopenする可能性あり

---

## VBA実装詳細

未確定 / Implementation Detail：

- `Scripting.Dictionary`
  - Early Binding
  - Late Binding
- `VBScript.RegExp`
  - 生成方式
- Result / ErrorInfo
  - Class
  - 軽量構造
- UserForm寸法
- UserFormスクロール方式
- Description表示方式
- Validation強調色
- HTML Encode具体関数
- Outlook COM参照解放コード
- 同期結果UI
- Unused確認UI
- OFT復旧UI
- Error Code体系
- Module物理分割の最終調整

---

## Module構成

Design上の候補は存在するが、物理Module数はImplementationで統合可能。

例：

```text
modValueFormatter
modSubjectRenderer
modBodyRenderer
modUnresolvedChecker
```

を、

```text
modRenderer
```

へ統合する可能性あり。

責務分離は維持する。

---

## Test Specification

未作成。

主要Test候補：

- New Variable
- Existing設定保持
- Unused
- Reactivated
- Rename
- Case Insensitive
- Invalid Variable Syntax
- Required未設定
- Required=False + 空欄
- Optional Date
- Optional Select
- SortOrder未設定
- SortOrder重複
- Date正常 / 異常
- Date Format
- Select OptionSource
- OFT不存在
- OFT読込失敗
- Input保持
- Inputクリア
- Subject置換
- Body置換
- HTML Encode
- 基本書式維持
- 未置換Variable
- Outlook Display成功
- Outlook生成 / Display失敗

---

# 次アクション

## 優先度1：Technical Spike A — OFT / HTMLBody

次チャットで最初に取り組む。

参照ファイル：

- `MVP Requirements v0.1.4 日本語版.md`
- `MVP Design v0.1.2 日本語版.md`

特に見る箇所：

- Template Scanner
- Body Renderer
- RISK-DES-001
- FR-RENDER-BODY-002
- AC-017

確認内容：

```text
CreateItemFromTemplate
↓
OFTを開く
↓
Subject取得
↓
HTMLBody取得
↓
{{VariableName}}が連続文字列として存在するか
↓
置換
↓
MailItem.Display
↓
基本書式維持確認
```

最低限確認すること：

- OFT読込可能か
- Subject取得可能か
- HTMLBody取得可能か
- VariableがHTMLBody上で連続文字列か
- Case Insensitive検索 / 置換可能か
- Variable置換後に基本書式が維持されるか
- Display可能か
- Scan用MailItemを破棄可能か

---

## 優先度2：Technical Spike結果のGate判定

### Spike成功

```text
Current Design維持
↓
MVP Test Specification v0.1
```

### Spike失敗

通常のOFT作成でもVariableが分断される等の場合：

```text
Technical Finding
↓
Requirement Gap判定
↓
必要ならRequirements / Design Reopen
```

---

## 優先度3：MVP Test Specification v0.1

Technical Spike A成功後に作成。

推奨構造：

```text
Test ID
Requirement ID
Design Component
Precondition
Input
Procedure
Expected Result
Error / Boundary
```

Traceability：

```text
Requirement
↓
Acceptance Criteria
↓
Design Component
↓
Test Case
```

を追える形にする。

---

## 優先度4：Technical Spike B / C

### Spike B：動的UserForm

確認：

- Frame内へTextBox / ComboBoxを動的生成
- `Tag = VariableName`
- Error強調
- SortOrder + Table Row順
- スクロール

### Spike C：Case Insensitive

確認：

- Scanner
- Dictionary
- Renderer
- Unresolved Checker

で同じCase Insensitive規則を維持可能か。

---

## 優先度5：Implementation Plan v0.1

Spike / Test Specification後に作成。

例：

```text
Phase 1
Excel Tables / Data Access

Phase 2
Outlook Adapter / Template Scanner

Phase 3
Sync Engine

Phase 4
Configuration Validator

Phase 5
UserForm / Input State

Phase 6
Input Validator

Phase 7
Renderer

Phase 8
Outlook Display

Phase 9
Integration Test
```

---

# 気づき

## 1. Design Reviewは「全文レビュー」よりTraceability Matrixが有効

今回、

```text
Requirement
Design
状態
判定
```

で機械的に突き合わせることで、

- Requirement Gap
- Design Gap
- Implementation Detail
- Document Consistency Gap

を分離できた。

単に「設計書を読んで違和感を探す」より、判断理由を残しやすい。

---

## 2. Requirement GapとDesign Gapを混ぜないことが重要

例：

```text
Required=FalseのSelect未選択はOKか？
```

は利用者挙動なのでRequirement Gap。

一方、

```text
Current OFTをどうScannerへ渡すか
```

はDesign Gap。

この区別によって、Design側で勝手に利用者仕様を決めることを防げた。

---

## 3. Implementation DetailをBasic Designへ戻しすぎない

Requirements §32のレビューで、

- Validation強調色
- 曜日生成コード
- HTML Encode関数
- Error Code体系
- UIの具体表示

などをすべてDesignで固定すると過剰設計になることが分かった。

重要なのは、

```text
責務
境界
処理順
```

をDesignで決め、

```text
具体コード
表示色
物理Module
UI寸法
```

はImplementationへ残すこと。

---

## 4. 「Required」と「Type」の責務を分離すると仕様が整理しやすい

今回のRG-001で、

```text
Required
→ 入力必須か

Type
→ 入力された値の妥当性
```

と分離したことで、Text / Date / Selectに共通する規則になった。

---

## 5. Acceptance Criteriaは「何となく正しい」では不十分

旧AC-017：

```text
主要な本文書式が維持される
```

ではテストできなかった。

保証する書式範囲を具体化することで、Test Specificationへ落とせる条件になった。

---

## 6. Internal DesignをRequirementへ書きすぎると後で矛盾する

FR-OUTLOOK-001では、

```text
MailItemをいつ生成するか
```

までRequirementに入っていたため、Designの自然な処理順と衝突した。

Requirementは、

```text
利用者から見た結果
```

を中心にし、

内部オブジェクトのライフサイクルはDesignへ委ねる方がよい。

---

## 7. Close条件を明示すると「いつまで設計するか」が決めやすい

今回、

```text
Requirement Gap = 0
Design Gap = 0
Blocking Issue = 0
```

をClose条件として扱った。

Technical Spike対象が残っていても、

```text
Designの不備
```

ではなく、

```text
実環境で確認すべき技術的不確実性
```

として明確に分けられた。

---

## 8. YAGNIと責務分離は両立できる

- 厳格Repository Pattern
- DI
- Interface大量導入
- DDD / Hexagonal完全適用

は採用していない。

一方で、

- UI
- Application
- Core
- Infrastructure
- Data Access
- Adapter

の責務境界は維持した。

「設計しない」のではなく、

```text
必要な境界だけ設計する
```

というMVP向けの考え方が整理された。

---

# 記事にできそうな切り口

## 開発日記向き

- 「DesignをCloseしたいのに、レビューするほど細かいGapが出てきた話」
- 「2つのRequirement GapをGrillMeで潰してみた」
- 「Required=Falseって実は意外と難しい」
- 「仕様書を直したら、今度は仕様書の中で工程責務が矛盾した」
- 「設計レビューを3回やって、ようやくCLOSEDにした個人開発の記録」
- 「AIと設計するとき、勝手に仕様を増やさせないためのRequirement Gapルール」
- 「全部決めてから実装したい自分と、MVPで決めすぎない設計のバランス」
- 「DesignをClosedにする判断基準を作ったら終わりが見えた」
- 「Technical SpikeをDesign未完成と勘違いしない」
- 「小さなメール作成ツールでもRequirementsとDesignを分けてみた」

---

## 技術記事向き

- 「Requirements → Design Traceability Matrixの作り方」
- 「Requirement Gap / Design Gap / Implementation Detailの分類方法」
- 「VBAでも使える軽量レイヤードアーキテクチャ」
- 「Excel VBAでData Accessを分離する理由」
- 「Outlook OFTを扱うときのMailItemライフサイクル設計」
- 「Template ScannerとConfiguration Validatorの責務分離」
- 「Regex Validationを二重実装しない設計」
- 「Case Insensitive Variable置換を一貫させる設計」
- 「Optional Variableを空文字列へRenderする設計判断」
- 「HTMLBodyテンプレート置換でTechnical Spikeが必要な理由」
- 「Acceptance Criteriaをテスト可能な表現にする方法」
- 「UserForm + Dynamic Controls + Tag BindingのVBA設計」
- 「ResultベースError HandlingをVBAへ軽量導入する」
- 「Requirementsに内部実装を書きすぎないための境界設計」
- 「Basic DesignとImplementation Detailをどう分けるか」

---

# 有料note / テンプレート化候補

## 1. Requirements / Design整合性レビューチェックリスト

再利用候補：

```text
□ RequirementがDesignで実現可能か
□ Designが新しい利用者挙動を追加していないか
□ RequirementsからDesignへ委譲した事項を確認したか
□ Implementation DetailをDesignへ戻しすぎていないか
□ 責務重複がないか
□ MVPとして過剰設計になっていないか
□ Acceptance Criteriaがテスト可能か
□ Technical Spike対象をDesign Gapと混同していないか
```

---

## 2. Traceability Matrix Template

列候補：

```text
Requirement ID
Requirement
Design Component
Status
Classification
Review Comment
Action
```

Classification：

```text
OK
Requirement Gap
Design Gap
Implementation Detail
Document Consistency Gap
Technical Spike
```

---

## 3. Requirement Gap GrillMe Template

判断対象：

```text
利用者から見た振る舞いか？
内部実装方法か？
既存Requirementから一意に導けるか？
複数の合理的な挙動が存在するか？
```

複数の利用者挙動が成立する場合のみRequirement Gapとしてヒアリング。

---

## 4. Design Close Checklist

候補：

```text
Requirement Gap = 0
Design Gap = 0
Blocking Document Conflict = 0
Acceptance Criteria = Testable
Known Technical Risk = Spikeへ移管済み
Implementation Detail = 明確に後工程へ移管済み
Upper Requirement Version = 一致
```

---

## 5. 工程責務分類テンプレート

```text
Requirements
→ 利用者の振る舞い / 制約 / Acceptance Criteria

Design
→ Component責務 / Boundary / Data Flow / Sequence

Implementation
→ Library / VBA構文 / UI寸法 / 色 / Error Code / Module物理配置

Test Specification
→ Test Case / Boundary / Expected Result
```

---

## 6. AI協働開発向けレビューPrompt集

候補：

- Requirements → Design Traceability Review Prompt
- Requirement Gap検出Prompt
- Design Overengineering Review Prompt
- Acceptance Criteria Testability Review Prompt
- Close Gate Review Prompt
- Delta Review Prompt
- Document Responsibility Review Prompt

---

# 次チャット開始用ショートハンドオフ

次チャットでは以下から開始する。

```text
現在のBaseline：

MVP Requirements v0.1.4 日本語版.md
MVP Design v0.1.2 日本語版.md

状態：

MVP Requirements v0.1.4
→ Baseline確定

MVP Design v0.1.2
→ CLOSED

Requirement Gap
→ 0

Design Gap
→ 0

Blocking Issue
→ 0
```

次アクション：

```text
Technical Spike A
OFT / HTMLBody
```

目的：

```text
現在のTemplate Scanner / Renderer設計が
実際のClassic Outlook OFT / HTMLBodyで成立するか確認する。
```

特に確認すること：

```text
CreateItemFromTemplate
Subject
HTMLBody
{{VariableName}}の連続性
Variable置換
基本書式維持
MailItem.Display
```

Spikeで通常利用ケースでも設計が成立しない場合のみ、

```text
Requirement Gap
↓
Requirements / Design Reopen
```

とする。

---

# まとめ / Summary

**日本語**

- `MVP Requirements v0.1.4` をRequirements Baselineとして確定した。
- `MVP Design v0.1.2` は正式に `CLOSED`。
- RG-001、RG-002、DG-001、および文書整合性問題はすべて解消済み。
- 新規Requirement Gap / Design Gap / Blocking Issueは0件。
- 次工程は `Technical Spike A：OFT / HTMLBody`。
- Spikeの主目的は、現在のScanner / Renderer設計が実際のOFTで成立するか確認すること。

**English**

- `MVP Requirements v0.1.4` is the final requirements baseline.
- `MVP Design v0.1.2` is formally `CLOSED`.
- RG-001, RG-002, DG-001, and document consistency issues are resolved.
- There are no new Requirement Gaps, Design Gaps, or blocking issues.
- The next step is `Technical Spike A: OFT / HTMLBody`.
- The main goal of the spike is to confirm that the current Scanner and Renderer design works with a real Outlook OFT.