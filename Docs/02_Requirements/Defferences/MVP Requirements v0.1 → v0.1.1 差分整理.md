# MVP Requirements v0.1 → v0.1.1 差分整理

## 1. 文書情報

- 対象文書：`MVP Requirements v0.1 日本語版`
- 更新後バージョン：`MVP Requirements v0.1.1 日本語版`
- 更新種別：Requirements残課題の確定反映
- 更新目的：
  - MVP Design開始前に残っていた要件レベルの未確定事項を確定する
  - Template Scanner、UserForm生成、Configuration Validation、OFT参照処理に関する基本動作を明文化する
  - RequirementsとDesignの境界を明確にする

---

# 2. 変更概要

v0.1.1では、以下の5項目を新たに確定した。

1. VariableNameの大文字・小文字の扱い
2. 命名規則違反の変数記法を検出した場合の扱い
3. Date型の出力Format候補
4. SortOrder未設定・重複時の扱い
5. OFTファイルが存在しない場合の基本動作

既存のMVPスコープ、対応型、同期方式、UserForm方針、Validation方針、Outlook処理等に変更はない。

---

# 3. 差分内容

## 3.1 VariableNameの大文字・小文字

### v0.1

未確定。

VariableNameの大文字・小文字を区別するかどうかは、MVP Design前の確認事項として残っていた。

### v0.1.1

VariableNameの比較では、**大文字・小文字を区別しない**。

以下は同一VariableNameとして扱う。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

VariableDefinitionに既存のVariableNameが存在する場合は、そのVariableNameを正式な表記として利用する。

### 要件

- Template Scanner
- Template Sync
- VariableDefinition照合
- Render処理
- 未置換変数チェック

におけるVariableName比較では、共通して大文字・小文字を区別しない。

同一VariableNameについて、大文字・小文字のみ異なる別変数を定義することはできない。

---

## 3.2 命名規則違反の変数記法

### v0.1

VariableName命名規則は以下としていた。

- 先頭は半角英字
- 2文字目以降は半角英字、数字、アンダースコア `_`
- 日本語VariableNameは使用しない

ただし、テンプレート内に命名規則違反の `{{...}}` が存在した場合の処理は未確定だった。

### v0.1.1

テンプレート内に命名規則違反の変数記法を検出した場合、**Configuration Errorとして扱い、処理を停止する**。

例：

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

### 要件

命名規則違反を1件以上検出した場合、以下の処理を実行不可とする。

- 手動テンプレート同期
- UserForm起動
- メール生成

エラー発生時は、検出した不正な記述をユーザーが確認できるようにする。

具体的なエラーダイアログ、表示形式、エラーコード等はMVP Designで決定する。

---

## 3.3 Date型の出力Format

### v0.1

Date型について以下を決定済みだった。

入力では以下を許容する。

```text
2026/09/08
2026/9/8
2026-09-08
2026-9-8
```

- 4桁年必須
- ゼロ埋め任意
- `/` と `-` を許容
- 入力後はDate型として扱う
- 出力FormatはVariableDefinitionで管理する
- Formatは自由入力ではなく定義済み候補から選択する方向

ただし、正式なFormat候補は未確定だった。

### v0.1.1

MVPで利用可能なDate Formatを以下の6種類とする。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

### 出力例

入力値：

```text
2026/09/09
```

出力例：

```text
2026/09/09
2026-09-09
2026年9月9日
9月9日
2026年9月9日(水)
9月9日(水)
```

### 要件

- Date型Variableでは、上記6種類からFormatを選択する
- MVPではDate Formatの自由入力を許可しない
- Date型として正常に変換できない入力値はValidation Errorとする
- 曜日表記の具体的な生成方法はMVP Designで決定する

---

## 3.4 SortOrderの未設定・重複

### v0.1

UserFormの表示順をVariableDefinitionの `SortOrder` で制御することは決定済みだった。

ただし、以下は未確定だった。

- SortOrder未設定時
- SortOrder重複時
- 重複時の第2ソート条件

### v0.1.1

以下のルールを採用する。

### SortOrder未設定

`SortOrder` が未設定の場合は、**Configuration Error** とする。

設定が完了するまでUserFormを起動できない。

### SortOrder重複

同じ `SortOrder` を複数Variableで使用することを許可する。

### 第2ソート条件

同じSortOrderを持つVariable同士では、

**VariableDefinitionテーブル上の行順**

を第2ソート条件とする。

### ソートルール

```text
第1ソート条件：SortOrder 昇順
第2ソート条件：VariableDefinitionテーブルの行順
```

### 例

```text
VariableName   SortOrder
ModelName      10
StageName      20
GateDate       20
OwnerName      30
```

UserForm表示順：

```text
ModelName
StageName
GateDate
OwnerName
```

### 要件

- SortOrderはUserForm生成対象Variableでは必須とする
- SortOrderの重複は許可する
- 同一SortOrder内の順序はVariableDefinition上の並び順に従う
- VariableDefinitionの行順を変更した場合、同一SortOrder内のUserForm表示順も変更される

---

## 3.5 OFTファイル不存在時の基本動作

### v0.1

OFTはExcelファイルを基準とした相対パスで参照し、その相対パスをSettingsに保持することは決定済みだった。

ただし、対象OFTが削除・移動・名称変更等により存在しない場合の基本動作は未確定だった。

### v0.1.1

Settingsに設定されたOFTファイルが存在しない場合、**Configuration Errorとして扱う**。

ただしExcel自体の操作は継続可能とする。

### 実行不可とする機能

OFTが存在しない場合、以下を実行不可とする。

- 手動テンプレート同期
- UserForm起動
- メール生成

### 実行可能とする操作

以下の設定・確認操作は継続可能とする。

- Settingsの確認・編集
- VariableDefinitionの確認・編集
- OptionMasterの確認・編集

### 要件

OFTの存在を確認できない状態では、テンプレートとの整合性を保証できないため、メール作成処理へ進ませない。

OFT再指定用の専用UIやファイル選択ダイアログはMVP Requirementsでは必須としない。

具体的な復旧UIはMVP Designで決定する。

---

# 4. v0.1.1で確定した追加要件一覧

| ID | 項目 | v0.1.1決定内容 |
|---|---|---|
| REQ-ADD-01 | VariableName Case | 大文字・小文字を区別しない |
| REQ-ADD-02 | Invalid Variable Syntax | Configuration Errorとして処理停止 |
| REQ-ADD-03 | Date Format | 定義済み6形式を採用 |
| REQ-ADD-04 | SortOrder未設定 | Configuration Error |
| REQ-ADD-05 | SortOrder重複 | 許可 |
| REQ-ADD-06 | SortOrder第2条件 | VariableDefinitionテーブルの行順 |
| REQ-ADD-07 | OFT不存在 | テンプレート依存処理を停止 |
| REQ-ADD-08 | OFT不存在時の設定操作 | Settings / VariableDefinition / OptionMaster編集は可能 |

---

# 5. 既存Requirementsへの影響

## 5.1 Template Scanner

以下を追加する。

- VariableName比較はCase Insensitive
- `{{...}}` のうち命名規則違反を検出可能とする
- 命名規則違反検出時はConfiguration Errorとする

---

## 5.2 Template Sync

以下を明文化する。

- VariableName比較はCase Insensitive
- OFT不存在時は同期を開始しない
- 不正Variable記法が存在する場合は同期を開始しない

---

## 5.3 Configuration Validator

以下を追加する。

Validation対象：

- OFTファイル存在確認
- VariableName命名規則
- SortOrder設定有無
- Date Formatが定義済み候補であること

SortOrderの重複自体はエラーとしない。

---

## 5.4 UserForm Generator

以下を追加する。

表示順：

```text
1. SortOrder 昇順
2. VariableDefinitionテーブル行順
```

UserForm起動前に以下を確認する。

- OFTが存在する
- TemplateとVariableDefinitionが整合している
- VariableDefinitionの必須設定が完了している
- SortOrderが設定されている
- 不正なVariable記法が存在しない

---

## 5.5 Date型

Date Format候補を以下に固定する。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

---

## 5.6 Render Engine

VariableName置換時の比較はCase Insensitiveとする。

ただし、具体的な置換アルゴリズムはMVP Designで決定する。

---

# 6. v0.1.1反映後もMVP Designで決定する事項

今回のRequirements更新によって、以下は依然としてDesign事項として残す。

- VBAモジュール構成
- クラス構成
- Template Scanner内部構造
- Sync Engine内部構造
- Configuration Validator内部構造
- UserForm Generator内部構造
- Input Validator内部構造
- Render Engine内部構造
- Outlook Adapter内部構造
- VariableDefinition実列構成
- OptionMaster詳細構造
- Settings詳細構造
- OFT読み込みAPI
- Subject / HTMLBody取得方法
- 具体的な正規表現
- Dictionary / Collection構成
- UserForm動的生成方式
- ControlとVariableNameのBinding方式
- Validation Errorの具体的な強調方法
- Date型の内部変換方法
- 曜日生成方法
- HTML Encode方式
- HTML書式維持方式
- Unused表示UI
- ConfigurationStatus列の採否
- 手動同期UI
- 同期結果UI
- エラーコード体系
- Outlook生成失敗時の具体処理
- Test Case設計

---

# 7. v0.1.1で解消された未解決事項

以下はRequirements上の未解決事項から削除する。

- VariableNameの大文字小文字を区別するか
- Date Formatの具体的な選択肢一覧
- SortOrderの重複・未設定時の扱い
- OFT不存在時の基本動作
- テンプレート内に命名規則違反の `{{...}}` が存在した場合の基本処理

---

# 8. 変更しない事項

今回のv0.1.1では、以下の既存決定に変更はない。

- Classic Outlook前提
- Excel Desktop + VBA + `.xlsm`
- OFT利用
- 1 Excel = 1 OFT
- Subject / Bodyのみ置換対象
- To / CC / BCC対象外
- OFTは相対パス参照
- 手動同期
- UserForm起動時は同期せず整合性チェック
- 新規Variableは自動追加
- 新規Variableは設定未完了状態
- 削除VariableはUnused保持
- Rename自動推測なし
- Requiredはユーザー明示設定
- MVP型はText / Date / Select
- Number / MultiSelect / URL / 複数行TextはMVP対象外
- SelectはOptionMaster管理
- Select自由入力不可
- UserFormにDisplayName / Required表示 / Descriptionを表示
- 入力値はExcel終了まで保持
- 入力クリア機能あり
- Validation Errorは全件表示
- エラー入力欄を視覚的に強調
- 未置換変数が残る場合はメール生成停止
- Outlook MailItemをDisplayした時点でツール処理終了
- 自動送信なし
- ログ記録なし

---

# 9. バージョン更新要約

`MVP Requirements v0.1.1` は、v0.1の機能スコープを変更する更新ではない。

本更新では、MVP Design開始前に残っていた要件レベルの曖昧さを解消し、以下の基本原則を強化した。

```text
不正状態を早期に検出する
↓
不整合状態ではUserForm・同期・メール生成へ進ませない
↓
ただし設定修正に必要なExcel操作は許可する
```

これにより、v0.1.1をMVP Designの正式な入力文書として利用可能な状態とする。