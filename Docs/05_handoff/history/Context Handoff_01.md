# 引き継ぎまとめ

## 実施内容

### 1. 定型メール作成ツールの企画検討
- Outlookのメールテンプレートファイル `.oft` を利用し、Excelから定型メールを生成するツール案を検討した。
- テンプレート内の可変箇所を `{{VariableName}}` 形式で定義し、Excel側で値を入力して置換する構想を整理した。
- Excelをプラットフォームとし、変数の型・必須設定・選択肢などを設定シートで管理する方針を検討した。
- UserFormを利用し、VariableDefinitionの設定内容に応じて入力UIを生成する構想を整理した。
- Subject / Body内の変数を対象にする方向で検討した。
- 将来的に複数テンプレート対応する構想を持ちつつ、MVPでは `1 Excel = 1 OFTテンプレート` に絞る方針を整理した。

### 2. テンプレート同期方式の検討
- OFTテンプレートから `{{...}}` 形式の変数を抽出し、Excel側のVariableDefinitionと同期する方法を検討した。
- 単純な再生成ではなく、既存設定を保持する「差分同期」方式を採用する方向で整理した。
- 以下の同期状態を検討した。
  - 新規変数
  - 継続変数
  - テンプレートから削除された変数
- 変数名変更を自動Rename扱いせず、
  - 旧変数 → `Unused`
  - 新変数 → `New`
  と扱う方式を整理した。

### 3. 企画書の作成
- 以下の文書を作成した。
  - **定型メール作成ツール 企画書 v0.1**
- 企画書では以下を整理した。
  - 背景
  - 目的
  - 企画コンセプト
  - 基本設計方針
  - 変数定義
  - テンプレート同期
  - UserForm
  - MultiSelect
  - URL / Hyperlink
  - Validation
  - 未置換変数チェック
  - メール生成
  - MVP / v0.2 / 最終版スコープ
  - 明示的な対象外
  - システム境界
  - 想定Excel構成
  - 技術前提
  - 成功条件
  - 主要リスク
  - MVP Requirementsで決定すべき事項

### 4. MVP Requirementsヒアリング設計
- MVP Requirements策定前に、一問一答・択一式のヒアリング項目を設計した。
- 当初18問構成として整理した。
- 以下の領域を対象にした。
  - テンプレート管理・同期
  - 変数仕様
  - Select / OptionMaster
  - UserForm
  - Validation
  - Outlookメール生成
- 各質問で選択肢、Pro / Con、推奨案、推奨理由を提示する形式で進行した。

### 5. MVP Requirementsヒアリング実施
以下のQ1〜Q18を一問一答で実施し、仕様を確定した。

#### Q1 OFTテンプレートの配置・参照方法
- Excel基準の相対パスをSettingsに保持する方式を選択。

#### Q2 テンプレート同期タイミング
- 自動同期ではなく、**手動同期**を採用。
- UserForm起動時には同期ではなく、テンプレートとVariableDefinitionの不整合チェックを行う方針に変更。

#### Q3 UserForm起動時の整合性チェック範囲
- 変数の増減だけでなく、UserForm生成に必要な設定項目まで確認する方式を採用。

#### Q4 新規変数検出時の扱い
- 新規変数はVariableDefinitionへ自動追加する。
- ただし「設定未完了」として扱い、必要設定完了まではUserFormを利用不可とする。

#### Q5 テンプレートから削除された変数
- `Unused` として保持する。
- 通常表示では非表示とする。

#### Q6 VariableName命名規則
- 先頭は英字。
- 以降は半角英数字＋アンダースコア `_`。
- 日本語VariableNameは使用しない。
- 日本語表示は `DisplayName` 側に持たせる。

#### Q7 Required初期値
- 自動でTrue / Falseを入れない。
- ユーザーが明示設定する。

#### Q8 Text型の改行対応
- MVPではText型は1行のみ。
- 複数行Textはv0.2以降候補。

#### Q9 Date型
- 入力形式は一定の柔軟性を許容。
- 以下を許容する方針。
  - `2026/09/08`
  - `2026/9/8`
  - `2026-09-08`
  - `2026-9-8`
- 4桁年必須。
- ゼロ埋めは任意。
- `/` と `-` を許容。
- 入力後はDate型として扱い、出力FormatはVariableDefinition側で管理。
- `yyyy/mm/dd`
- `yyyy年m月d日`
- `m月d日`
  などの定義済みFormatから選択する方向。

#### Q10 Number型
- MVPではNumber型を採用しない。
- 数値が必要な場合もText型として扱う。
- Number型は将来拡張候補。

#### Q11 Select型の選択肢管理
- `OptionMaster` シートで管理する。

#### Q12 Select型の自由入力
- 許可しない。
- 一覧からの選択のみ。
- 自由入力が必要な場合はText型を使用する。

#### Q13 UserForm表示順
- `SortOrder` をVariableDefinitionに持たせる。

#### Q14 UserFormの補助情報
- 以下を表示する。
  - `DisplayName`
  - 必須表示
  - `Description`

#### Q15 UserForm入力値の保持
- Excelを閉じるまで保持する。
- UserFormに「入力クリア」ボタンを設ける。

#### Q16 Validationエラー表示
- 全エラーをまとめて表示する。
- 該当入力欄も視覚的に強調する。
- UserFormではTextBox / ComboBox等の `BackColor` を変更できることを確認。
- 動的UserFormとの関連付けには `Tag = VariableName` が有力案として提示された。
- ただし `Tag` の利用はまだDesignレベルの候補であり、正式決定ではない。

#### Q17 未置換変数
- Subject / Bodyのどちらでも `{{...}}` が残ればメール生成停止。
- 警告のみで継続する方式は採用しない。

#### Q18 Outlook生成後の責任範囲
- Outlook MailItemを `Display` した時点でツール側の処理完了。
- 自動送信は行わない。
- ログ記録もMVP対象外。

### 6. MVP Requirements文書作成
- 以下の文書を作成した。
  - **MVP Requirements v0.1 日本語版**
- 文書には以下を整理した。
  - 文書目的
  - MVPの目的
  - システム概要
  - MVPスコープ
  - 対象外
  - テンプレート管理要件
  - 変数記法要件
  - 変数抽出要件
  - テンプレート同期要件
  - VariableDefinition要件
  - Required設定要件
  - Text / Date / Select型要件
  - OptionMaster要件
  - UserForm生成要件
  - UserForm起動時整合性チェック
  - 入力値保持
  - Validation
  - Subject / Body置換
  - 未置換変数チェック
  - Outlookメール生成
  - エラー処理
  - 非機能要件
  - 操作フロー
  - 想定Excel構成
  - Acceptance Criteria
  - v0.2候補
  - 最終対象外
  - MVP Designへの引き継ぎ事項

---

# 決定事項

## プラットフォーム・基本構成
- Classic Outlookを前提とする。
- Excel Desktop + VBA + `.xlsm` を利用する。
- Outlookテンプレートは `.oft` を利用する。
- MVPでは **1 Excel = 1 OFTテンプレート** とする。
- 将来的には1 Excelで複数テンプレートを扱う構想を持つ。
- MVPの置換対象は **Subject / Body** とする。
- To / CC / BCCはMVP対象外。

## OFT参照
- OFTはExcelファイルを基準とした**相対パス**で参照する。
- 相対パスはSettingsに保持する。

## テンプレート同期
- テンプレート同期は**手動同期**とする。
- UserForm起動時には自動同期しない。
- UserForm起動前にテンプレートとVariableDefinitionの整合性チェックを行う。
- 不整合がある場合はUserFormを起動しない。

## 新規変数
- テンプレートから検出された新規変数はVariableDefinitionへ自動追加する。
- 新規変数は設定未完了状態として扱う。
- 設定完了まではUserFormで利用不可。

## 継続変数
- 既存変数はType、Required、DisplayName等の設定を保持する。
- 同期によって既存設定を上書きしない。

## 削除変数
- テンプレートから削除された変数は `Unused` として保持する。
- 通常表示では非表示とする。
- 同一VariableNameが再登場した場合は既存設定を再利用する。

## 変数名変更
- Renameを自動推測しない。
- 旧変数をUnused、新変数をNewとして扱う。

## VariableName
- 先頭は半角英字。
- 2文字目以降は半角英字、数字、アンダースコア。
- 日本語はVariableNameに使用しない。
- 日本語表示はDisplayName側で管理する。

## Required
- 新規変数のRequiredには自動初期値を設定しない。
- True / Falseをユーザーが明示設定する。

## MVP対応型
- Text
- Date
- Select

## MVP非対応型
- Number
- MultiSelect
- URL
- 複数行Text

## Text
- MVPでは1行入力のみ。

## Date
- 4桁年必須。
- ゼロ埋めは任意。
- `/` と `-` を許容。
- 以下の形式を許容。
  - `2026/09/08`
  - `2026/9/8`
  - `2026-09-08`
  - `2026-9-8`
- 入力後はDate型として扱う。
- 出力FormatはVariableDefinition側で管理する。
- Date Formatは自由入力より定義済み候補から選択する方向。

## Number
- MVPではNumber型を持たせない。
- 数字入力もText型で扱う。

## Select
- Selectの選択肢は `OptionMaster` で管理する。
- Selectでは自由入力を許可しない。
- 自由入力が必要な変数はText型とする。

## UserForm
- UserFormの表示順は `SortOrder` で制御する。
- 各入力欄には以下を表示する。
  - DisplayName
  - 必須表示
  - Description
- 入力値はExcelを閉じるまで保持する。
- 「入力クリア」ボタンを設置する。

## Validation
- Validationエラーは全件まとめて表示する。
- エラー該当入力欄も視覚的に強調する。
- 背景色変更等で強調する方向。
- 再Validation時には以前の強調状態をリセットする。

## 未置換変数
- Subject / Bodyに `{{VariableName}}` が1件でも残ればメール生成停止。
- 警告のみで処理継続する方式は採用しない。

## Outlook処理
- 生成したメールはClassic Outlookで `Display` する。
- `Display` 時点でツールの責任範囲終了。
- 自動送信しない。
- ログ記録はMVP対象外。

## 明示的な対象外
- 条件分岐
- 添付ファイル自動処理
- 自動送信
- New Outlook対応

---

# 未解決事項

## MVP Designで決定する事項
- VBAモジュール構成
- クラス構成
- Template Scannerの構造
- Sync Engineの構造
- Configuration Validatorの構造
- UserForm Generatorの構造
- Input Validatorの構造
- Render Engineの構造
- Outlook Adapterの構造
- VariableDefinitionシートの実際の列順
- OptionMasterの詳細テーブル構造
- Settingsシートの詳細構造
- OFT読み込み方法の詳細
- Subject / HTMLBodyの取得・書き換え方法
- 変数抽出に使う具体的な正規表現
- Dictionary / Collection等の内部データ構造
- UserFormをどの程度動的生成するか
- コントロールとVariableNameの関連付け方法
  - `Tag = VariableName` は有力候補だが未決定
- Validationエラー強調方法の詳細
  - 背景色変更は実現可能
  - 色、解除方式、対象コントロールはDesignで決める
- Dateの内部変換処理
- Date Format候補の正式一覧
- HTMLBodyへTextを置換する際のHTML Encode方式
- HTML書式維持の具体方式
- Unused変数の表示切替方法
- 新規変数の「設定未完了」判定方法
  - 専用のConfigurationStatus列を持つか
  - 必須項目の未設定から都度判定するか
- 手動同期UI
- 同期結果UI
- エラーコード・例外処理
- Outlook生成失敗時の処理
- Acceptance Criteriaに対するテストケース設計

## 要件としてまだ詰め切っていない事項
- VariableNameの大文字小文字を区別するか
  - 会話中では「区別しない方が安全」という提案はあったが、明示決定はしていないため要確認。
- Date Formatの具体的な選択肢一覧
- Descriptionの最大長や表示方法
- SortOrderの重複・未設定時の扱い
- SelectのOptionMasterでActive / SortOrderを必須にするか
- Unusedをユーザーがどこから確認するか
- Settingsシートに持たせる項目一覧
- OFTファイル名変更時の扱い
- 同期前にOFTが存在しない場合のUI詳細
- テンプレート内に命名規則違反の `{{...}}` が存在した場合の具体的処理

## v0.2候補
- MultiSelect
- URL
- Hyperlink Target書き換え
- 複数行Text
- 1 Excel / 複数OFT
- Number型
- DefaultValue高度化
- 入力値再利用機能の拡張
- テンプレート管理機能
- 同期結果UI改善

---

# 次アクション

## 優先度1：MVP Designの作成
次のチャットでは、まず以下を参照してMVP Designへ進む。

### 参照文書
1. **定型メール作成ツール 企画書 v0.1**
2. **MVP Requirements v0.1 日本語版**

### 最初に決めるべき設計
- 全体アーキテクチャ
- コンポーネント責任分離
- Excelシート構造
- 内部データ構造
- UserForm生成方式
- 同期処理
- Render処理
- Outlook連携

### 推奨する設計検討順
1. 全体コンポーネント構成
2. VariableDefinition / OptionMaster / Settingsのデータ構造
3. OFT読み込み・Template Scanner
4. Sync Engine
5. Configuration Validator
6. UserForm Generator
7. Input Validator
8. Render Engine
9. Outlook Adapter
10. エラーハンドリング
11. テスト設計

## 優先度2：MVP Designヒアリング項目の設計
- 企画書・Requirementsと同様に、一問一答択一式で設計判断を進めるのがよい。
- Requirementsで決めたことを再度聞かない。
- Designで必要な判断に限定する。

## 優先度3：Requirements整合性レビュー
MVP Design開始前または並行で、以下の整合性を確認するとよい。
- 企画書 v0.1
- MVP Requirements v0.1
- 今後作るMVP Design

特に確認すべき点：
- MVP / v0.2 / 最終対象外の境界
- Number型が企画書では候補に存在し、RequirementsではMVP対象外となった点
- MultiSelect / URL / Hyperlinkがv0.2へ送られたこと
- 手動同期へ変更されたこと
- UserForm起動時は同期ではなく整合性チェックになったこと

## 優先度4：実装開始前のテストシナリオ作成
最低限以下のテストケースを先に定義する。
- 新規変数追加
- 既存変数維持
- 変数削除→Unused
- Unused変数復活
- 変数Rename
- Required未設定
- Select OptionSource未設定
- Date正常 / 異常
- 未置換変数残存
- OFT不存在
- Outlook生成成功 / 失敗

---

# 気づき

## 1. 「自動化」しすぎると設定不整合を隠す
当初はOFT変更検知→自動同期も候補だったが、

- テンプレートから新規変数を抽出
- 自動追加
- しかしType / Required / Select設定が未設定

という状態が発生する。

そのため、
- 同期は管理操作
- UserForm起動は利用操作

として分離した方が責任境界が明確になった。

## 2. 同期と設定完了は別状態
- 「テンプレートへ追従済み」
- 「変数仕様が設定済み」

は別の状態である。

新規変数を自動追加しても、それだけでは利用可能にしない設計が重要。

## 3. 設定値を削除しない設計が変更耐性を高める
テンプレートから消えた変数を削除せず `Unused` とすることで、
- 一時的な削除
- 誤削除
- 後日の復活

に強くなる。

## 4. Rename自動推測は便利そうで危険
`PIC` → `PersonInCharge` を自動Renameと判断すると、異なる意味の変数へ設定を誤引継ぎする可能性がある。

安全側として、
- Old → Unused
- New → New
と扱う方がよい。

## 5. データ型とUI表現を分離する考え方
会話中ではText / MultilineTextを別型にする案もあったが、MVPでは複数行を外す判断をした。

将来的には、
- Type = Text
- Multiline = True / False
のように「型」と「UI属性」を分離する余地がある。

## 6. 柔軟性より標準化を優先する箇所を明示した
Selectでは自由入力を認めず、
- Select = 統制された値
- Text = 自由入力
と役割を分離した。

## 7. UserFormのValidationは「検知」だけでなく「修正しやすさ」も要件
全エラー一覧＋入力欄強調にすることで、Validationを単なるエラー検出ではなく、修正支援として扱う方向になった。

## 8. 色だけでエラーを伝えない
背景色変更だけでなく、エラー内容を文字でも一覧表示することで、色だけに依存しないUIにできる。

## 9. テンプレートエンジンを作りすぎない
条件分岐を入れると、
- Parser
- Syntax
- Nesting
- Debugging
が必要となり、定型メール生成ツールからテンプレート言語処理系へ肥大化する。

条件分岐を最終版でも入れない方針は、スコープ管理上重要。

## 10. 添付ファイルは別責任
添付を扱うと、
- ファイル存在確認
- パス
- バージョン
- 権限
- クラウドストレージ
まで責任が広がる。

定型メール生成とは別責任として対象外にした。

## 11. 「自動送信しない」は安全設計
ツールはメール作成まで。
最終送信はユーザーがOutlookで確認して行う。

これにより、
- 宛先
- 表示崩れ
- 内容
- 添付有無
等を最終確認できる。

---

# 記事にできそうな切り口

## 開発日記向き

### 1. 「自動同期が便利だと思ったら、逆に危険だった」
- 最初はOFT更新検知→自動同期が便利そうだった。
- 実際には新規変数のTypeやRequiredが未設定になる。
- 最終的に「手動同期＋利用前チェック」に変えた判断過程。

### 2. 「機能を増やすより、やらないことを決める」
- 条件分岐
- 添付
- 自動送信
を入れないと決めた話。
- 個人開発でスコープを守る難しさ。

### 3. 「便利な自動化と、勝手に判断する自動化は違う」
- 同期は自動化してもよいように見える。
- しかし業務ルールや型の判断までは自動化しない。
- AIやツールにどこまで判断を任せるかという話。

### 4. 「テンプレート変更に強いツールを考える」
- 設定を毎回再生成するとカスタマイズが消える。
- 差分同期に切り替えた理由。
- Unusedという中間状態を持つ意味。

### 5. 「MVPでNumber型をあえて外した」
- 当初は文字列・日付・数値・選択式を想定。
- ヒアリングを進める中で、数値Validationは本当にMVPに必要か再考。
- Textで代替してMVPを小さくした判断。

---

# 技術記事向き

## 1. Excel VBAで設定駆動型メールジェネレーターを作る設計
テーマ候補：
- OFT
- VariableDefinition
- OptionMaster
- Settings
- UserForm
- Outlook Object Model

## 2. `{{VariableName}}` を使ったテンプレート変数抽出
内容候補：
- 正規表現
- 重複排除
- Subject / Body / Both
- 不正なVariableName検出

## 3. 差分同期アルゴリズム
状態：
- New
- Existing
- Unused

処理例：
- 新規追加
- 設定保持
- Unused化
- 復活

## 4. Excel VBAで動的UserFormを構成する設計
内容候補：
- Type → Control対応
- SortOrder
- DisplayName
- Required
- Description
- `Tag = VariableName` による関連付け候補

## 5. VBA UserFormでValidation UIを作る
内容候補：
- TextBox / ComboBoxのBackColor変更
- 一括エラー表示
- Validation前の表示リセット
- 色だけに依存しないエラー表現

## 6. Date型の入力と表示を分離する
内容候補：
- `2026/09/08`
- `2026/9/8`
- `2026-09-08`
- `2026-9-8`
を同じDate値として扱う考え方。
- 内部値と出力Formatの分離。

## 7. HTMLメール置換で気をつけること
今後のDesignで深掘り可能。
- `.HTMLBody`
- HTML Encode
- `<`
- `>`
- `&`
- OFT書式維持

## 8. RequirementsとDesignを分ける
- Requirementsでは
  - 何をするか
  - どう振る舞うか
を決める。
- Designでは
  - どう実装するか
を決める。
- `BackColor` や `Tag` はDesign事項として切り分けた例。

---

# 有料note / テンプレート化候補

## 1. 「定型メール作成ツール 企画書テンプレート」
再利用できる章：
- 背景
- 目的
- コンセプト
- スコープ
- 対象外
- リスク
- 成功条件
- 次工程

## 2. 「MVP Requirements ヒアリング18問テンプレート」
カテゴリ：
- テンプレート管理
- 同期
- 変数仕様
- 型
- Select
- UI
- Validation
- Outlook生成

一問一答・択一式で、
- 選択肢
- Pro / Con
- 推奨案
- 理由
をセットにしたテンプレート化が可能。

## 3. 「設定駆動型ツール設計チェックリスト」
チェック項目例：
- 設定とテンプレートを分離できているか
- 自動同期が安全か
- 未設定状態を表現できるか
- 削除とUnusedを分けているか
- Renameを勝手に推測していないか
- 入力と表示Formatを分離しているか
- エラーを止める条件が明確か
- 対象外を明記しているか

## 4. 「MVPスコープ判断テンプレート」
各機能を、
- MVP
- v0.2
- 最終対象外
に分類するための判断表として再利用可能。

今回の例：
- Text → MVP
- Date → MVP
- Select → MVP
- Number → v0.2
- MultiSelect → v0.2
- URL → v0.2
- 条件分岐 → 最終対象外
- 添付 → 最終対象外
- 自動送信 → 最終対象外

## 5. 「テンプレート同期設計パターン」
比較対象：
- 毎回再生成
- 自動同期
- 手動同期
- 差分同期
- 更新日時検知
- 設定未完了状態

## 6. 「AIと一問一答でMVP要件を決めるプロンプト」
再利用可能なプロンプト構成：
- 一問ずつ質問
- 択一式
- Pro / Con
- ★推奨
- 推奨理由
- 回答後に確定事項だけ蓄積
- 要件と詳細設計を混ぜない

---

# 次チャット開始用の短縮Handoff

```markdown
# Context Handoff

## Project
定型メール作成ツール

## Completed
- 定型メール作成ツール 企画書 v0.1 作成済み
- MVP Requirementsヒアリング Q1〜Q18 完了
- MVP Requirements v0.1 日本語版 作成済み

## MVP Core
- Excel Desktop + VBA + Classic Outlook
- OFTテンプレート
- 1 Excel = 1 OFT
- Subject / Bodyのみ変数置換
- {{VariableName}}
- 手動テンプレート同期
- UserForm起動前に整合性チェック
- New / Existing / Unused の差分同期
- Newは設定未完了として追加
- Unusedは設定保持＋通常非表示
- Text / Date / Select
- Number / MultiSelect / URLはMVP対象外
- SelectはOptionMaster管理、自由入力不可
- UserForm順序はSortOrder
- DisplayName + Required + Description表示
- 入力値はExcel終了まで保持
- 入力クリアボタンあり
- Validationは全エラー一覧＋対象欄強調
- 未置換{{}}があれば生成停止
- Outlook Displayまで
- 条件分岐 / 添付自動処理 / 自動送信は対象外

## Next
MVP Design作成へ進む。

最初に以下を設計すること：
1. 全体コンポーネント構成
2. VariableDefinition / OptionMaster / Settings
3. Template Scanner
4. Sync Engine
5. Configuration Validator
6. UserForm Generator
7. Input Validator
8. Render Engine
9. Outlook Adapter
10. Error Handling / Tests

## Key unresolved
- VBA module/class構成
- VariableDefinition列構成
- OptionMaster詳細
- Settings詳細
- 正規表現
- UserForm動的生成方式
- ControlとVariableNameの紐付け
- Tag利用可否
- Validation強調詳細
- Date Format一覧
- HTMLBody / HTML Encode
- Configuration Complete判定
- Sync UI
- Error Handling
- Test cases
```