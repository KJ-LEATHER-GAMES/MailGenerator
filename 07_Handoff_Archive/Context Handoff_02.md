# 引き継ぎまとめ

## 実施内容

### 1. 前回引き継ぎ内容の確認

- 前チャットから引き継がれた以下の状態を確認した。
  - `定型メール作成ツール 企画書 v0.1`
  - `MVP Requirements v0.1 日本語版`
  - MVP Requirements策定時のQ1〜Q18の決定内容
  - MVP Designで決めるべき未解決事項
- 次工程としてMVP Designへ進む前に、Requirements側に残っていた未確定事項を先に閉じる方針を採用した。

---

### 2. Requirements残課題5問のヒアリング

MVP Design開始前にRequirementsとして確定すべき5項目について、一問一答・択一式でヒアリングした。

#### Q1 VariableNameの大文字・小文字

- 選択：B
- VariableNameの比較では大文字・小文字を区別しないことを決定。

例：

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

は同一Variableとして扱う。

---

#### Q2 命名規則違反の `{{...}}`

- 選択：C
- 命名規則違反をConfiguration Errorとして扱い、処理を停止することを決定。

例：

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

---

#### Q3 Date Format

- 選択：B
- MVPで使用可能なDate Formatを以下6種類に確定。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

---

#### Q4 SortOrder

- 選択：B
- SortOrder未設定はConfiguration Error。
- SortOrder重複は許可。
- ユーザー追加指定により、重複時の第2ソート条件を

```text
VariableDefinitionテーブルの行順
```

とすることを決定。

正式なソート順：

```text
第1条件：SortOrder 昇順
第2条件：VariableDefinitionテーブルの行順
```

---

#### Q5 OFT不存在時

- 選択：B
- OFTが存在しない場合はテンプレート依存処理を停止する。
- 以下は実行不可。
  - 手動同期
  - UserForm起動
  - メール生成
- 以下は確認・編集可能。
  - Settings
  - VariableDefinition
  - OptionMaster

---

### 3. MVP Requirements v0.1 → v0.1.1 差分整理

5件の決定について、v0.1からv0.1.1へ反映する差分を整理した。

主な更新対象：

- VariableName Case Insensitive
- Invalid Variable Syntax
- Date Format
- SortOrder
- OFT不存在
- Template Scanner
- Template Sync
- Configuration Validator
- UserForm Generator
- Render Engine
- Acceptance Criteria

---

### 4. MVP Requirements v0.1.1作成

ユーザーから提供された `MVP Requirements v0.1 日本語版` 全文をベースに、差分を反映した全文版を作成した。

作成ファイル：

```text
MVP Requirements v0.1.1 日本語版.md
```

v0.1の構造を維持しつつ、関連箇所も整合するよう修正した。

特に元v0.1の以下の記述：

```text
UserFormの表示順はSortOrder昇順
Excel上の行順には依存しない
```

は今回のQ4決定と矛盾するため、

```text
第1条件：SortOrder 昇順
第2条件：VariableDefinitionテーブルの行順
```

へ更新した。

Acceptance Criteriaも追加要件を検証可能な形へ更新した。

---

### 5. MVP Design Questions候補15問の作成・レビュー

MVP Designへ進むためのDesign Questionsを15問に整理した。

レビュー軸：

- Requirementsとの重複有無
- Designとして決めるべき論点か
- 質問順の依存関係
- MVPとして過剰設計になっていないか

確定した質問：

1. D01 全体アーキテクチャ
2. D02 VariableDefinition設定完了状態
3. D03 OptionMaster構造
4. D04 Settings構造
5. D05 Excelシートと内部ロジックの分離
6. D06 OFT / MailItemライフサイクル
7. D07 Template Scanner
8. D08 Sync Engine
9. D09 Configuration Validator
10. D10 UserForm動的生成方式
11. D11 Control Binding / Input State
12. D12 Input Validator
13. D13 Render Engine
14. D14 Outlook Adapter
15. D15 Error Handling

レビュー結果：

- ヒアリング移行可否：GO
- Design開始前にRequirementsへ戻る必要のある重大な抜けはなし

---

### 6. Designヒアリング運用ルール設定

以下を正式なヒアリング運用ルールとして設定した。

> Designヒアリング中に、
> 「これは実装方法ではなく、利用者から見た振る舞いを新しく決めようとしている」
> 論点が出てきた場合は、その場でDesign判断せず、
> `Requirement Gap`
> として切り出す。

このルールは今後のDesign検討でも継続する。

---

### 7. MVP Designヒアリング D01〜D15実施

#### D01 全体アーキテクチャ

- 選択：B
- 軽量レイヤード構成を採用。

```text
UI
↓
Application
↓
Core Logic
↓
Infrastructure
```

DDD / Hexagonalを厳格適用せず、VBAで現実的な責務分離とする。

---

#### D02 VariableDefinition設定完了状態

- 選択：B
- `ConfigurationStatus` 列は持たない。
- 現在の設定値からConfiguration Validatorが都度導出する。

基本条件：

```text
DisplayName
Type
Required
SortOrder
```

追加条件：

```text
Date → Format
Select → OptionSource + 有効Option
```

---

#### D03 OptionMaster

- 選択：A
- MVP最小負荷を優先し、4列構成を採用。

```text
OptionGroup
Value
SortOrder
Active
```

- 内部値と表示値の分離はMVPでは行わない。

このタイミングで、MVP Designの判断軸として以下を明確化した。

> MVPは必要最小限の実装負荷を優先し、将来拡張の先回り実装や過剰設計を避ける。

---

#### D04 Settings

- MVPが `1 Excel = 1 OFT` であることを再確認。
- 選択：A

SettingsはKey / Valueの2列構成。

```text
Key            Value
TemplatePath   Templates\MailTemplate.oft
```

---

#### D05 Excelシートと内部ロジックの分離

AとBの違いを詳細比較した。

- A：各処理がExcelを直接参照
- B：Excelアクセスを薄いData Access層へ集約

ユーザーから、

> ATSと同じで責務分離をするという考え方

との確認があり、その理解で合っていることを確認。

- 選択：B

採用イメージ：

```text
Application / Core
↓
Data Access
↓
Excel Tables
```

ただし、

- Repository Patternを厳格導入しない
- DIしない
- Interfaceを乱立しない

など、MVPでは軽量に留める。

---

#### D06 OFT / MailItem

- 選択：B
- Scan用MailItemとメール生成用MailItemを分離する。

```text
Scan：
OFT → Scan用MailItem → Subject / Body取得 → 破棄

Mail生成：
OFT → 生成用MailItem → Render → Display
```

MailItem状態の持ち越しを防止する。

---

#### D07 Template Scanner

- 選択：B
- 候補抽出とVariableName Validationを2段階に分離。

```text
Subject / Body
↓
{{ ... }} Candidate Scan
↓
VariableName Validation
↓
Valid / Invalid
```

命名規則：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

---

#### D08 Sync Engine

- 選択：B
- Template側とVariableDefinition側をDictionary化し、Set比較する。

```text
Template Dictionary A
VariableDefinition Dictionary B
```

差分分類：

```text
New
Existing
Reactivated
Unused
```

VariableName比較はCase Insensitive。

---

#### D09 Configuration Validator

- 選択：B
- Configuration Validationを一元化する。
- ただし巨大な1関数にはせず、内部を小関数へ分割する。

例：

```text
ValidateTemplate()
ValidateVariableDefinition()
ValidateDateConfiguration()
ValidateOptionMaster()
```

---

#### D10 UserForm

- 選択：B
- 固定UserForm + 入力Controlのみ動的生成。

固定：

```text
UserForm本体
InputArea Frame
ErrorArea
メール作成Button
入力クリアButton
```

動的：

```text
Label
TextBox
ComboBox
Required表示
Description
```

---

#### D11 Control Binding / Input State

- MVP採用：B

```text
Control.Tag = VariableName
+
InputValues Dictionary
```

入力値は：

```text
VariableName → Value
```

でExcel終了まで保持する。

C案のBinding専用クラスへの移行トリガも整理した。

再検討トリガ：

- 1 Variableに複数Control
- Control Event個別処理増加
- ValidationState / ErrorMessage / Dirty等の状態増加
- Type分岐増大
- Tag + Dictionary処理の重複
- 1入力項目が独立した状態と振る舞いを持ち始めた場合

---

#### D12 Input Validator

- 選択：B
- Input Validation判定をUserFormから分離。

```text
UserForm
↓
Input Validator
↓
ValidationResult
↓
UserForm
```

Input Validator：

- Required
- Date
- Select

UserForm：

- エラー一覧表示
- Control強調
- 強調解除

---

#### D13 Render Engine

- 選択：B
- 値Formatと出力先固有処理を分離。

```text
Raw Input
↓
Value Formatter
↓
Formatted Value
├─ Subject Renderer
└─ HTML Encode → Body Renderer
```

HTML EncodeはValue FormatterではなくBody側責務。

未置換変数チェックはRender後段の独立処理とする方向。

---

#### D14 Outlook Adapter

- 選択：B
- Outlook Object Model依存を軽量Adapterへ集約。

```text
Application / Core
↓
Outlook Adapter
↓
Classic Outlook
```

MVPではPort / Interfaceまでは作らない。

---

#### D15 Error Handling

- 選択：B
- 予見可能なエラーはResultとして返し、UI層で表示。

```text
Core / Application
↓
OperationResult
↓
UI
↓
User表示
```

エラー分類例：

```text
ConfigurationError
TemplateError
InputValidationError
RenderError
OutlookError
UnexpectedError
```

予期しないVBA / COM Errorは、

```text
On Error等で捕捉
↓
UnexpectedError等へ変換
↓
UI
```

とする。

---

### 8. Requirement Gap確認

Designヒアリング15問を通じて、新規にRequirementsへ戻す必要のあるRequirement Gapは発生しなかった。

D03で内部値と表示値を分離する案を採用した場合には、

```text
メールにはOptionValue / DisplayNameのどちらを出力するか
```

という利用者向け仕様決定が必要だったが、MVPでは4列最小構成を採用したため発生しなかった。

---

### 9. MVP Design v0.1作成

15件のDesign Decisionを統合した設計書を作成した。

作成ファイル：

```text
MVP Design v0.1 日本語版.md
```

主な章・内容：

- 文書情報
- 文書目的
- 設計原則
- 軽量レイヤードアーキテクチャ
- コンポーネント責務
- Excel構成
- VariableDefinition設計
- OptionMaster設計
- Settings設計
- Excel Data Access
- Dictionary等の内部データ構造
- OFT / MailItemライフサイクル
- Outlook Adapter
- Template Scanner
- Sync Engine
- Configuration Validator
- UserForm
- Control Binding / Input State
- Input Validator
- Date処理
- Value Formatter
- Render Engine
- 未置換変数チェック
- Error / Result設計
- 手動同期シーケンス
- UserForm起動シーケンス
- メール生成シーケンス
- VBA Module構成案
- Design Decision一覧
- Requirements Traceability
- 実装時確認事項
- 設計上のリスク
- 次工程

---

## 決定事項

### Requirements v0.1.1追加決定

- VariableNameは大文字・小文字を区別しない。
- 命名規則違反の `{{...}}` はConfiguration Error。
- 不正記法があればテンプレート依存処理を停止する。
- Date Formatは以下6種類。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

- SortOrder未設定はConfiguration Error。
- SortOrder重複は許可。
- SortOrder同順位時はVariableDefinitionテーブルの行順を第2ソート条件とする。
- OFT不存在時は以下を停止。
  - 手動同期
  - UserForm
  - メール生成
- OFT不存在時でもSettings / VariableDefinition / OptionMasterの確認・編集は可能。

---

### Design方針

- 軽量レイヤード構成を採用。
- MVPは最小実装負荷を優先。
- 将来拡張の先回り実装を避ける。
- ATSと同様に責務分離を重視するが、VBAでは軽量に実装する。
- `ConfigurationStatus` は保存せず都度導出。
- OptionMasterは4列。
- SettingsはKey / Value。
- Excelアクセスは薄いData Access層へ集約。
- Scan用MailItemと生成用MailItemを分離。
- Template ScannerはCandidate Scan + Validation。
- Sync EngineはDictionary Set比較。
- Configuration Validationは一元化。
- UserFormは固定Form + 動的Input Controls。
- Control Bindingは `Tag = VariableName`。
- Input StateはDictionary。
- Input ValidationはUIから分離。
- RenderはValue Formatterと出力先処理を分離。
- Outlook依存は軽量Adapterへ集約。
- エラーはResultとして上位へ返し、UIで表示。
- 予期しない技術エラーは捕捉後、Error Resultへ変換。

---

### Designヒアリング運用ルール

Design検討中に、

```text
利用者から見た新しい振る舞いを決める必要がある
```

場合は、その場でDesign判断せず、

```text
Requirement Gap
```

として切り出す。

---

## 未解決事項

### 優先確認：Requirements / Design整合性

まだ正式な整合性レビューは実施していない。

要確認対象：

```text
定型メール作成ツール 企画書 v0.1
MVP Requirements v0.1.1 日本語版.md
MVP Design v0.1 日本語版.md
```

特に確認すること：

- Requirementsに存在しない利用者挙動をDesignが追加していないか
- Design Decision D01〜D15がすべて設計書へ正しく反映されているか
- Acceptance CriteriaをDesignで実現可能か
- MVP / v0.2 / 最終対象外の境界
- Design上の責務重複
- Module分割の過剰さ

---

### HTMLBody内のVariable分断

設計上のリスクとして以下を認識している。

OFTのHTMLBody内で、

```text
{{VariableName}}
```

がHTMLタグ等によって文字列として分断される場合、単純な検索・置換で検出できない可能性がある。

例として、実際のHTMLBody構造は未確認。

対応：

- 実OFTを使ったTechnical Spike / 実装確認が必要。
- 利用者側に新しいテンプレート記述制約が必要になった場合は `Requirement Gap` とする。

---

### VBA実装詳細

以下は未確定。

- `Scripting.Dictionary`
  - Early Binding
  - Late Binding
- `VBScript.RegExp` の生成方式
- Result / ErrorInfo
  - Class
  - 軽量構造
- UserForm具体寸法
- UserFormスクロール方式
- Description表示方式
- Validation強調色
- HTML Encode関数
- Outlook COM参照解放コード
- 同期結果UI
- Unused確認UI
- エラーコード体系
- Module統合の最終調整

---

### VBA Module構成

`MVP Design v0.1` では候補として以下を定義している。

```text
UI
frmMailGenerator
modUiController

Application
modMailApplication
modSyncApplication

Core
modTemplateScanner
modSyncEngine
modConfigurationValidator
modInputValidator
modValueFormatter
modSubjectRenderer
modBodyRenderer
modUnresolvedChecker

Infrastructure
modVariableDefinitionData
modOptionMasterData
modSettingsData
modOutlookAdapter

Shared / State
modInputState
modResult
```

ただし、実装量に対して過剰な場合は、責務を崩さない範囲で統合可能とした。

例：

```text
modSubjectRenderer
+
modBodyRenderer
↓
modRenderer
```

最終Module構成は未確定。

---

### Test Specification

まだ未作成。

必要な主なTest Case候補：

- New Variable
- Existing設定保持
- Unused化
- Reactivated
- Rename
- Case Insensitive
- Invalid Variable Syntax
- Required未設定
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
- 未置換Variable
- Outlook Display成功
- Outlook生成失敗

---

## 次アクション

### 優先度1：Requirements / Design整合性レビュー

次チャットでは最初に以下2文書を確認する。

```text
MVP Requirements v0.1.1 日本語版.md
MVP Design v0.1 日本語版.md
```

必要に応じて上位文書：

```text
定型メール作成ツール 企画書 v0.1
```

も参照する。

レビュー観点：

1. Requirements → Design Traceability
2. Requirement漏れ
3. DesignによるRequirement追加
4. Design Decision D01〜D15反映確認
5. 責務重複
6. 過剰設計
7. MVP最小負荷との整合
8. Acceptance Criteria実現性
9. Requirement Gap有無

---

### 優先度2：MVP Test Specification v0.1

整合性レビュー後、

```text
MVP Test Specification v0.1
```

を作成する。

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

Acceptance CriteriaとDesign ComponentをTraceできる構成にする。

---

### 優先度3：Technical Spike

本実装前に、特に以下を小さく確認する。

#### Spike A：OFT / HTMLBody

- `CreateItemFromTemplate` でOFTを開けるか
- Subject取得
- HTMLBody取得
- HTMLBody内の `{{VariableName}}` が連続文字列として存在するか
- MailItemを書き換えてDisplayできるか

#### Spike B：動的UserForm

- Frame内へTextBox / ComboBoxを動的生成
- `Tag = VariableName`
- BackColorによるエラー強調
- SortOrder + Table Row順で生成

#### Spike C：Case Insensitive Replace

- Subject
- HTMLBody
- Dictionary
- Unresolved Check

で同じCase Insensitiveルールを維持できるか確認。

---

### 優先度4：Implementation Plan

テスト仕様とSpike結果を基に、

```text
Implementation Plan v0.1
```

を作成する。

例：

```text
Phase 1 Excel Tables / Data Access
Phase 2 Outlook Adapter / Template Scanner
Phase 3 Sync Engine
Phase 4 Configuration Validator
Phase 5 UserForm / Input State
Phase 6 Input Validator
Phase 7 Renderer
Phase 8 Outlook Display
Phase 9 Integration Test
```

---

## 気づき

### RequirementsとDesignの境界を明示する価値

- 「何をするか」と「どう作るか」を分けることで、Design中にRequirementsが勝手に増えることを防げた。
- `Requirement Gap` という明示ルールを置くことで、ヒアリング中に設計と要件が混ざるリスクを抑えられた。
- Designヒアリングの運用ルールとして他プロジェクトでも再利用可能。

---

### MVP最小負荷と責務分離は両立できる

当初、

```text
責務分離
=
Module / Classが大量に増える
```

という懸念があった。

しかし実際には、

```text
Excelアクセスだけ集約
Outlook依存だけ隔離
Validation判定だけ分離
```

程度でも責務分離は可能。

「設計する = 複雑化する」ではなく、

> 境界だけ先に決めて、実装は軽くする

という考え方が有効だった。

---

### ATSで使った設計思想がExcel VBAにも応用できる

ユーザー自身がD05検討時に、

> ATSと同じで責務分離をするという考え方

と気づいた。

Webアプリ / DBアプリの設計思想を、そのまま大規模なArchitectureとして持ち込むのではなく、

```text
責務
依存
境界
Single Source of Truth
```

という原則だけVBAへ適用できる。

---

### 状態は保存するより導出した方が安全な場合がある

`ConfigurationStatus` を保存すると、

```text
実データ = Incomplete
Status = Complete
```

の不整合が起きる。

今回は、

```text
事実
↓
Configuration Validator
↓
状態を導出
```

とした。

派生状態を保存しないという判断は他システムでも使える。

---

### UIとValidationを分離する

UserForm自身にValidationロジックを全部持たせる方が最初は簡単だが、

```text
判定
表示
```

を分離することで、

- テストしやすい
- ルールが一元化される
- UI肥大化を防げる

というメリットがある。

---

### DictionaryはVBAでもSet比較に使える

Sync Engineでは、

```text
Template Variables
vs
VariableDefinition
```

をDictionaryへ変換することで、

```text
New
Existing
Reactivated
Unused
```

を明確に分類できる。

Excel行を1件ずつ検索するより、処理意図が分かりやすい。

---

### Adapterは必ずしも大掛かりである必要はない

Outlook Adapterについて、

```text
Interface
Port
DI
Factory
```

までは採用しなかった。

MVPでは、

> Outlook Object Modelを触る場所を1か所にする

だけでも十分な価値がある。

---

### 将来クラス化する「トリガ」を先に決める方法

D11ではBinding専用Classを今すぐ作らず、

```text
状態やイベントが増えたらClass化
```

という移行トリガを定義した。

これは、

> 今は作らないが、いつ作るべきかは決めておく

という過剰設計回避の方法として再利用可能。

---

## 記事にできそうな切り口

### 開発日記向き

#### 1. 「Excel VBAなのに設計しすぎ？」と悩みながらMVPの境界を決めた話

- Excelマクロだから全部1Moduleでよいのか
- ATSで学んだ責務分離をどこまで使うか
- DDD / Hexagonalまではやらない判断
- 「軽量レイヤード」という着地点

---

#### 2. MVPなのに15問も設計ヒアリングした理由

- Requirementsを先に作った理由
- Design Questionsを分離した理由
- 一問一答方式
- Pro / Con / 推奨案
- AIと一緒に設計判断を積み上げる流れ

---

#### 3. 「将来必要かも」を実装しない勇気

具体例：

- OptionMasterの内部ID
- ConfigurationStatus
- Binding専用Class
- Outlook Port / Interface
- 複数Template

「将来使うかもしれない」ではなく、

```text
移行トリガを決めて今は作らない
```

というMVP判断。

---

#### 4. RequirementsとDesignが混ざり始めたのでルールを1つ追加した

テーマ：

```text
Requirement Gap
```

- Design中に利用者の振る舞いを決め始めてしまう問題
- 「それはDesignでは決めない」と止める運用
- AI協働開発での文書境界管理

---

#### 5. Excel VBAでもATSと同じ設計思想が使えた

- ATSではUseCase / Repository等を学んだ
- VBAへそのまま持ち込むと過剰
- しかし「責務分離」という原則はそのまま使える
- 技術スタックを跨いで設計思想を転用した体験

---

## 技術記事向き

### 1. Excel VBAで軽量レイヤードアーキテクチャを作る

構成：

```text
UI
Application
Core
Infrastructure
```

例：

```text
UserForm
Sync Application
Template Scanner
Excel Data Access
Outlook Adapter
```

---

### 2. Excel VBAでRepository PatternをやりすぎないData Access分離

比較：

```text
各ModuleからExcel直接参照
vs
薄いData Access Module
```

テーマ：

- ListObject依存の局所化
- 列変更の影響範囲
- テスト容易性
- 過剰抽象化回避

---

### 3. DictionaryでTemplate差分同期を設計する

Set比較：

```text
A = Template
B = VariableDefinition
```

分類：

```text
A only → New
A + B Active → Existing
A + B Unused → Reactivated
B Active only → Unused
```

---

### 4. VBA UserFormを設定駆動で動的生成する

- VariableDefinition
- SortOrder
- Text / Date / Select
- `Tag = VariableName`
- Dynamic TextBox / ComboBox
- InputValues Dictionary

---

### 5. UIからValidationを分離するVBA設計

```text
UserForm
↓
Input Validator
↓
ValidationResult
↓
UserForm
```

- Required
- Date
- Select
- 複数Error
- Control強調

---

### 6. OFT + Classic Outlook + VBAのAdapter設計

- `CreateItemFromTemplate`
- Scan用MailItem
- Mail生成用MailItem
- COM依存隔離
- Displayまでを責任範囲とする

---

### 7. HTMLメールの変数置換で気をつけること

- HTML Encode
- SubjectとHTMLBodyの違い
- Variable文字列がHTML内で分断される可能性
- 未置換チェック
- Case Insensitive Replace

---

### 8. 保存状態ではなく導出状態を使う設計

題材：

```text
ConfigurationStatusを持たない
```

- Single Source of Truth
- 派生状態不整合
- Validatorで都度判定

---

## 有料note / テンプレート化候補

### 1. MVP Requirements → MVP Design ヒアリングテンプレート

含めるもの：

- Requirements確定後のDesign Questions作成手順
- Design質問レビュー軸
- Requirementsとの重複チェック
- Pro / Con
- 推奨案
- Requirement Gap判定

---

### 2. Design Question 一問一答テンプレート

形式：

```markdown
## Dxx — 設計論点

### A
Pro
Con

### B ★推奨
Pro
Con

### C
Pro
Con

### Requirement Gap確認

### Decision
```

---

### 3. Requirement Gap判定チェックリスト

判断基準：

```text
これは利用者から見える振る舞いか？
↓ Yes
Requirement Gap

これは内部の実現方法か？
↓ Yes
Design
```

---

### 4. MVP過剰設計防止チェックリスト

例：

- 将来機能だけのために作っていないか
- Interfaceは今必要か
- IDは今必要か
- 派生状態を保存していないか
- Class化の代わりに移行トリガを決められないか
- 境界だけ分けて実装を軽くできないか

---

### 5. Excel VBA軽量Architecture Template

構成：

```text
UI
Application
Core Logic
Infrastructure
```

コンポーネント候補：

```text
Data Access
Validator
Renderer
Adapter
State
Result
```

---

### 6. Requirements Traceability Template

例：

```text
Requirement ID
Requirement
Design Component
Test ID
Status
```

Requirements → Design → Testまでつなぐテンプレートとして再利用可能。

---

### 7. AI協働設計プロンプト集

今回使った流れをテンプレート化可能。

```text
Requirements残課題抽出
↓
択一ヒアリング
↓
Requirements更新
↓
Design Questions生成
↓
Designヒアリング
↓
Requirement Gap監視
↓
Design統合
↓
整合性レビュー
↓
Test Specification
```

個人開発や業務ツール設計用のプロンプトセットとして再利用可能。