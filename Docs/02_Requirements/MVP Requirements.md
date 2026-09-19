# MVP Requirements v0.1.6 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Requirements |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1.6 |
| 文書種別 | MVP要件定義 |
| 上位文書 | 定型メール作成ツール 企画書 v0.1 |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| メールテンプレート | Outlook Template File（`.oft`） |
| MVP構成 | 1 Excelファイル = 1 OFTテンプレート |
| 対象メール要素 | Subject / Body |
| 最終処理 | Outlookメールを表示（Display） |
| 自動送信 | 対象外 |

### v0.1.6 更新概要

v0.1.6では、`MVP Requirements v0.1.5` × `MVP Design v0.1.3` × `Technical Spike A v0.2 CLOSED` の最終整合性レビュー結果を反映した。

利用者向けRequirement、Acceptance Criteria、およびMVP保証範囲は変更していない。

1. §34の次工程を、Design v0.1.3反映後の現在地に合わせて更新した
2. 最終整合性レビューで確認したCR-001〜CR-005は、既存Requirementに対するDesign completeness / clarificationとして `MVP Design v0.1.4` で補完する方針とした
3. CR-006として確認した旧Design Reopen記述を解消し、Requirements v0.1.6 → Design v0.1.4 → 最終整合性確認 → MVP Test Specification v0.1 の順序を明確化した
4. 新規Requirement Gapは発生していない

---

### v0.1.5 更新概要

v0.1.5では、Technical Spike A v0.2の結果に基づき、Requirements内に残っていたHTMLBody方式固有の表現を技術非依存表現へ整理した。

Technical Spike AではRoute W：WordEditorをMVPのBody処理技術方針として採用したが、本Requirementsでは具体的な実現方式そのものではなく、利用者から見た要求・保証範囲を定義する。

1. FR-RENDER-BODY-002からHTML構造 / HTML Encode等の技術固有表現を除去し、本文の置換結果と書式維持に関する要求へ整理した
2. HTMLタグによるVariable分断の保証対象外表現を、Variable文字列途中へ部分的に異なる書式を設定したケースとして技術非依存化した
3. AC-017の保証対象外記述をFR-RENDER-BODY-002参照へ一本化した
4. §32.1の「HTMLBody置換方式」を技術非依存のBody処理方式へ変更した
5. §32.2からRoute H固有で不要となったHTML Encode関数の実装引継ぎを削除した
6. Technical Spike A完了後の現在地に合わせて§34「次工程」を更新した

本変更はDocument Consistency Patchであり、利用者向けRequirementの追加・削除およびRequirement Gapは発生していない。

---

### v0.1.4 更新概要

v0.1.4では、MVP Requirements v0.1.3 × MVP Design v0.1.2 の最終差分レビューで確認した工程責務表現のみを修正した。利用者向けRequirementおよびDesign Decisionは変更していない。

1. OFT不存在時の具体的な復旧UIをImplementation事項として明確化した
2. Invalid Variable Syntaxの具体的な表示形式・メッセージ文言・エラーコードをImplementation事項として明確化した
3. 曜日表記生成について、Design責務と具体的VBA実装責務を分離した
4. Validation強調について、VariableNameとの関連付けと具体的な表示方式・色の責務を分離した
5. HTML Encodeについて、Body Renderer側の責務と具体的Encode関数の実装責務を分離した

---

### v0.1.3 更新概要

v0.1.3では、MVP Requirements v0.1.2 × MVP Design v0.1.1 の最終整合性レビューで検出した文書責務上の不整合を修正した。利用者向けの新規Requirementは追加していない。

1. §32の引き継ぎ事項を、MVP Design / Implementation / MVP Test Specificationの3工程へ再分類した
2. FR-OUTLOOK-001から内部的なMailItem生成タイミングの制約を外し、ユーザーへDisplayするための成功条件を明確化した

---

### v0.1.2 更新概要

v0.1.2では、MVP Requirements v0.1.1 × MVP Design v0.1 の整合性レビューで検出した2件のRequirement Gapを確定し、関連箇所へ反映した。

1. `Required=False` の場合、Date / Selectを含め空欄・未選択を有効とし、値が入力されている場合のみTypeに応じたValidationを行う
2. Body置換後に保証する本文書式の範囲を、代表的な基本書式へ明確化し、MVP保証対象外を定義する

---

### v0.1.1 更新概要

v0.1.1では、MVP Design開始前に残っていた以下の要件を確定し、関連箇所へ反映した。

1. VariableNameの大文字・小文字は区別しない
2. 命名規則違反の `{{...}}` をConfiguration Errorとして扱い、テンプレート依存処理を停止する
3. Date型の出力Formatを6種類に確定する
4. SortOrder未設定はConfiguration Error、重複は許可し、同順位ではVariableDefinitionテーブルの行順を使用する
5. OFT不存在時はテンプレート依存処理を停止するが、設定確認・編集は可能とする

---

## 2. 文書目的

本書は、定型メール作成ツールのMVPとして実装する機能、制約、振る舞い、および完了条件を定義する。

本書では、

- MVPとして何を実現するか
- 利用者から見てどのように振る舞うか
- 何をMVP対象外とするか

を明確化する。

VBAのクラス構成、モジュール構成、具体的な制御実装等の詳細設計は、本書では定義せず、後続のMVP Designで定義する。

---

## 3. MVPの目的

MVPでは、Outlookの定型メールテンプレートに含まれる変数をExcel上で管理し、UserFormから入力された値によってSubjectおよびBodyを置換し、安全に送信用メールを生成できることを確認する。

MVPで特に検証する価値は以下とする。

1. OFTテンプレートから変数を抽出できること
2. テンプレート変更時に既存設定を保持しながら変数定義を同期できること
3. 変数定義に応じた入力UIを生成できること
4. 入力値を検証できること
5. SubjectおよびBodyを正しく置換できること
6. 未置換変数や設定不整合を検知し、不完全なメール生成を防止できること
7. 生成結果をClassic Outlookでユーザーが確認できること

---

## 4. システム概要

基本処理フローを以下とする。

```text
OFT Template
     │
     ├─ Subject
     └─ Body
          │
          ▼
    Variable Scan
          │
          ▼
 Variable Definition
          │
          ▼
   Manual Sync
          │
          ▼
 Configuration Check
          │
          ▼
      UserForm
          │
          ▼
      User Input
          │
          ▼
     Validation
          │
          ▼
   Format / Replace
          │
          ▼
Unresolved Variable Check
          │
          ▼
 Outlook Mail Display
```

---

## 5. MVPスコープ

### 5.1 対象

MVPでは以下を対象とする。

- Classic Outlook
- Excel Desktop
- VBA
- `.xlsm`
- `.oft`
- 1 Excelファイルにつき1 OFTテンプレート
- Subjectの変数置換
- Bodyの変数置換
- `{{VariableName}}` 形式の変数
- テンプレートからの変数抽出
- VariableDefinitionとの差分同期
- Text型
- Date型
- Select型
- UserForm
- Validation
- 未置換変数チェック
- Outlook MailItemのDisplay

### 5.2 MVP対象外

以下はMVP対象外とする。

- Number型
- MultiSelect型
- URL型
- ハイパーリンク先置換
- 複数テンプレート管理
- 条件分岐
- 添付ファイル自動追加
- To / CC / BCCの変数置換
- メール自動送信
- ログ記録
- 入力値の永続保存
- 複数行Text
- New Outlook対応

---

## 6. テンプレート管理要件

### FR-TPL-001 OFTファイルの参照

MVPでは、Excelファイルからの相対パスによってOFTテンプレートを参照する。

テンプレートパスはSettingsに保持する。

例：

```text
MailGenerator.xlsm
Templates\
    GateMail.oft
```

Settings：

```text
TemplatePath = Templates\GateMail.oft
```

**Acceptance Criteria**

- Excelファイルの格納場所を基準にOFTを特定できる
- Excelと関連フォルダ一式を別フォルダへ移動しても、相対関係が維持されていれば参照できる

### FR-TPL-002 OFTファイル不存在時の動作

Settingsに設定された相対パス上にOFTファイルが存在しない場合は、Configuration Errorとして扱う。

OFTが存在しない状態では、テンプレートとの整合性を保証できないため、以下のテンプレート依存処理を実行不可とする。

- 手動テンプレート同期
- UserForm起動
- メール生成

一方で、復旧に必要な以下の確認・編集操作は可能とする。

- Settingsの確認・編集
- VariableDefinitionの確認・編集
- OptionMasterの確認・編集

OFT不存在時は、ユーザーが原因と必要な確認内容を理解できる形で通知する。

OFT再指定専用UIやファイル選択ダイアログをMVP必須要件とはしない。具体的な復旧UIはImplementationで具体化する。

---

## 7. 変数記法要件

### FR-VAR-001 変数表現

テンプレート変数は以下の形式とする。

```text
{{VariableName}}
```

例：

```text
{{ModelName}}
{{GateDate}}
{{Department}}
```

### FR-VAR-002 変数名命名規則

VariableNameは以下を満たすこと。

- 先頭は半角英字
- 2文字目以降は半角英字、数字、アンダースコア `_`
- 日本語は使用しない

基本ルール：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

例：

```text
OK:
{{GateDate}}
{{PIC_Email}}
{{Model1}}

NG:
{{1stGate}}
{{_GateDate}}
{{審査日}}
```

DisplayNameはVariableNameとは分離し、日本語表示を許可する。

### FR-VAR-003 同一変数の重複

同一VariableNameがSubjectまたはBody内に複数回存在しても、VariableDefinition上では1件として扱う。

メール生成時には、該当するすべての出現箇所を同一値で置換する。

### FR-VAR-004 VariableNameの大文字・小文字

VariableNameの比較では、大文字・小文字を区別しない。

以下は同一VariableNameとして扱う。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

VariableDefinitionに既存のVariableNameが存在する場合は、そのVariableNameの表記を正式な表記として保持する。

少なくとも以下の処理では同一のCase Insensitiveルールを適用する。

- Template Scanner
- Template Sync
- VariableDefinition照合
- Subject / Body置換
- 未置換変数チェック

大文字・小文字のみが異なる別変数を定義することはできない。

### FR-VAR-005 命名規則違反の変数記法

テンプレート内に `{{...}}` 形式の記述が存在し、その内容がFR-VAR-002の命名規則を満たさない場合は、Configuration Errorとして扱う。

例：

```text
{{123Name}}
{{User-Name}}
{{ユーザー名}}
{{ UserName }}
```

命名規則違反を1件以上検出した場合、以下を実行不可とする。

- 手動テンプレート同期
- UserForm起動
- メール生成

エラー発生時は、検出した不正記述をユーザーが確認できるようにする。

不正変数記法を検出して処理停止へつなげる責務構造はMVP Designで定義し、具体的な表示形式、メッセージ文言、エラーコード等はImplementationで具体化する。

---

## 8. 変数抽出要件

### FR-SCAN-001 抽出対象

変数抽出対象は以下とする。

- Subject
- Body

To、CC、BCCは対象外とする。

### FR-SCAN-002 抽出結果

抽出処理では、

- VariableName
- 出現位置

を特定する。

出現位置は以下のいずれかとして扱う。

- Subject
- Body
- Both

### FR-SCAN-003 不正記法の検出

変数抽出処理では、有効なVariableNameだけでなく、`{{...}}` 形式で記述されている命名規則違反の記述も検出できること。

不正記法を検出した場合はFR-VAR-005に従う。

---

## 9. テンプレート同期要件

### FR-SYNC-001 同期方式

テンプレート同期は自動ではなく、ユーザーが明示的に実行する手動同期方式とする。

同期処理では、テンプレートから抽出した変数と既存VariableDefinitionを比較し、差分を反映する。

VariableNameの比較はFR-VAR-004に従い、大文字・小文字を区別しない。

### FR-SYNC-002 新規変数

テンプレートに存在し、VariableDefinitionに存在しない変数は、新規変数として自動追加する。

新規変数は設定未完了状態として扱う。

新規追加時点では、少なくとも以下は未設定とする。

- DisplayName
- Type
- Required

設定完了まではUserForm利用対象としない。

### FR-SYNC-003 継続変数

テンプレートにもVariableDefinitionにも存在する変数については、既存設定を保持する。

以下のようなユーザー設定を同期処理によって上書きしてはならない。

- DisplayName
- Type
- Required
- Description
- OptionSource
- SortOrder
- Format

### FR-SYNC-004 削除変数

VariableDefinitionに存在するがテンプレートから削除された変数は、削除せず `Unused` とする。

既存設定は保持する。

通常の設定表示ではUnused変数を非表示とし、必要時に確認可能とする。

### FR-SYNC-005 Unused変数の復活

Unused変数と同一VariableNameがテンプレートへ再登場した場合は、Activeへ復帰させる。

復帰時は既存設定を再利用する。

VariableNameの同一性判定はFR-VAR-004に従う。

### FR-SYNC-006 変数名変更

変数名変更は自動推測しない。

例：

```text
{{PIC}}
↓
{{PersonInCharge}}
```

この場合は、

```text
PIC            → Unused
PersonInCharge → New
```

として扱う。

### FR-SYNC-007 同期結果通知

手動同期完了後、少なくとも以下の分類で同期結果をユーザーへ通知する。

- 新規
- 継続
- Unused化

例：

```text
テンプレート同期結果

新規
+ GateOwner

継続
= GateDate
= ModelName

未使用
- Department
```

### FR-SYNC-008 同期開始前チェック

以下の場合は手動同期を開始しない。

- OFTファイルが存在しない
- テンプレート内にFR-VAR-005に該当する命名規則違反の変数記法が存在する

対象エラーをユーザーへ通知し、修正後に再実行できること。

---

## 10. VariableDefinition要件

MVPでは、各変数について少なくとも以下の情報を保持する。

| 項目 | MVP | 説明 |
|---|---|---|
| VariableName | 必須 | システム上の変数識別子 |
| DisplayName | 必須 | UserForm上の表示名称 |
| Type | 必須 | Text / Date / Select |
| Required | 必須 | 必須入力か |
| Description | 任意 | 入力補助説明 |
| OptionSource | 条件付き必須 | Select型の選択肢参照 |
| SortOrder | 必須 | UserForm表示順 |
| Format | Dateで使用 | 出力形式 |
| TemplateLocation | 自動 | Subject / Body / Both |
| Status | 自動 | Active / Unused |
| FirstDetectedAt | 管理情報 | 初回検出日時 |
| LastDetectedAt | 管理情報 | 最終検出日時 |

具体的なExcel列順やテーブル構造はMVP Designで決定する。

---

## 11. Required設定要件

### FR-REQ-001 Requiredの初期状態

新規変数についてRequiredの初期値を自動設定しない。

以下のどちらかをユーザーが明示的に選択する。

```text
True
False
```

これにより、

```text
False = 任意と明示的に判断した結果
```

として扱えることを要件とする。

---

## 12. 変数型要件

MVPでサポートする型は以下とする。

- Text
- Date
- Select

---

## 13. Text型要件

### FR-TYPE-TEXT-001

MVPのText型は1行入力のみとする。

複数行入力はMVP対象外とし、v0.2以降の拡張候補とする。

---

## 14. Date型要件

### FR-TYPE-DATE-001 入力形式

Date型は4桁年を必須とする。

年月日のゼロ埋めは任意とする。

以下の形式を許容する。

```text
2026/09/08
2026/9/8
2026-09-08
2026-9-8
```

以下はMVPでは許容しない。

```text
26/9/8
9/8
```

### FR-TYPE-DATE-002 Validation

日付入力は、文字列形式そのものではなく、有効な日付として解釈可能であることをValidation基準とする。

例：

```text
2026/2/29 → NG
2028/2/29 → OK
```

### FR-TYPE-DATE-003 内部値

入力された日付は、Validation後に日付値として扱う。

ユーザーが入力したゼロ埋めやセパレータは、出力形式には直接引き継がない。

### FR-TYPE-DATE-004 出力Format

Date型のメール出力形式は、VariableDefinitionのFormatによって設定する。

MVPで利用可能なFormatは以下の6種類とする。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

MVPではDate Formatの自由記述を許可しない。

Date型Variableでは、上記6種類からFormatを選択する。

Date変換処理および定義済みDate Formatを適用する責務はMVP Designで定義し、曜日表記生成の具体的なVBA実装はImplementationで具体化する。

---

## 15. Select型要件

### FR-TYPE-SELECT-001

Select型は一覧からの選択のみ許可する。

自由入力は許可しない。

自由文字列が必要な変数はText型として定義する。

---

## 16. OptionMaster要件

### FR-OPT-001

Select型の選択肢は、VariableDefinition内に直接保持せず、`OptionMaster` で管理する。

概念例：

| OptionGroup | Value | SortOrder | Active |
|---|---|---:|---|
| Department | 設計部 | 10 | True |
| Department | 品質部 | 20 | True |
| Department | 生産部 | 30 | True |

VariableDefinitionからはOptionSourceによって参照する。

### FR-OPT-002

Select型でOptionSourceが未設定、または有効な選択肢を取得できない場合は、UserFormを利用可能状態としない。

---

## 17. UserForm生成要件

### FR-UI-001

UserFormはVariableDefinitionに基づいて入力項目を生成する。

テンプレートごとの個別UserForm作成を基本方式としない。

### FR-UI-002 コントロール対応

MVPでは以下を基本とする。

| Type | UserForm Control |
|---|---|
| Text | TextBox |
| Date | TextBox |
| Select | ComboBox |

具体的なコントロール生成方式はMVP Designで決定する。

### FR-UI-003 表示順

UserFormの表示順は、以下の順序規則に従う。

1. `SortOrder` 昇順
2. `SortOrder` が同一の場合は、VariableDefinitionテーブル上の行順

`SortOrder` が未設定のActive変数はConfiguration Errorとし、UserFormを起動しない。

同一`SortOrder`を複数変数で使用することは許可する。

例：

| VariableName | SortOrder |
|---|---:|
| ModelName | 10 |
| StageName | 20 |
| GateDate | 20 |
| OwnerName | 30 |

この場合のUserForm表示順は以下とする。

```text
ModelName
StageName
GateDate
OwnerName
```

同一SortOrder内では、VariableDefinitionテーブルの行を並べ替えるとUserForm表示順も変更される。

### FR-UI-004 補助情報

UserFormでは各入力項目について以下を表示する。

- DisplayName
- 必須表示
- Description

Descriptionは入力補助用の短い説明を想定する。

---

## 18. UserForm起動時整合性チェック

### FR-UI-CHECK-001

UserForm起動前に、テンプレートとVariableDefinitionの整合性チェックを実施する。

MVPでは少なくとも以下を確認する。

- OFTファイルが存在する
- テンプレート内に命名規則違反の変数記法が存在しない
- テンプレートに未登録変数が存在しない
- テンプレートから削除された変数がActiveのまま残っていない
- Active変数のTypeが設定されている
- Active変数のDisplayNameが設定されている
- Active変数のRequiredが明示設定されている
- Active変数のSortOrderが設定されている
- Date型のFormatが定義済み6形式のいずれかである
- Select型のOptionSourceが設定されている
- Select型のOptionSourceから有効な選択肢を取得できる

SortOrderの重複自体は不整合としない。

### FR-UI-CHECK-002

不整合が存在する場合はUserFormを起動せず、不整合内容をユーザーへ通知する。

自動同期は行わない。

---

## 19. 入力値保持要件

### FR-INPUT-001

UserFormで入力した値は、Excelファイルを閉じるまで保持する。

Excel終了後に入力値を永続保存しない。

### FR-INPUT-002 入力クリア

UserFormに「入力クリア」機能を設ける。

ユーザー操作によって、現在保持している入力値を明示的にクリアできること。

---

## 20. Validation要件

### FR-VAL-001

メール生成前にすべての入力値をValidationする。

`Required` と `Type` のValidation責務を以下のとおり分離する。

- `Required=True` の場合、未入力または未選択はValidation Errorとする
- `Required=False` の場合、Date / Selectを含め、空欄または未選択を有効とする
- `Required=False` でも値が入力・選択されている場合は、Typeに応じたValidationを行う

MVPでは少なくとも以下を対象とする。

- Required項目の未入力 / 未選択
- 値が存在するDate型で、日付として解釈できない値
- 値が存在するSelect型で、OptionMasterの有効Optionに存在しない値

したがって、以下は正常入力として扱う。

```text
Type = Date   / Required = False / Value = 空欄
Type = Select / Required = False / Value = 未選択
```

### FR-VAL-002 エラー一括表示

Validationでは、最初のエラーのみで停止せず、検出されたすべてのエラーをまとめてユーザーへ表示する。

例：

```text
入力内容を確認してください。

・ゲート審査日：有効な日付ではありません
・担当部署：選択してください
```

### FR-VAL-003 入力欄強調

Validationエラーが存在する入力コントロールは、UserForm上で視覚的に識別できるよう強調する。

MVPでは背景色変更等の方式を想定する。

入力コントロールとVariableNameの関連付け方法はMVP Designで定義し、具体的な強調表示方式・色はImplementationで具体化する。

### FR-VAL-004

再Validation時には、以前のエラー表示状態をリセットしたうえで現在のValidation結果を反映する。

---

## 21. Subject置換要件

### FR-RENDER-SUB-001

Subject内の有効な変数を、UserFormで入力・選択された値へ置換する。

同一変数が複数回存在する場合はすべて置換する。

VariableNameの照合はFR-VAR-004に従い、大文字・小文字を区別しない。

---

## 22. Body置換要件

### FR-RENDER-BODY-001

Body内の有効な変数を、UserFormで入力・選択された値へ置換する。

同一変数が複数回存在する場合はすべて置換する。

VariableNameの照合はFR-VAR-004に従い、大文字・小文字を区別しない。

### FR-RENDER-BODY-002

Body内のVariable置換では、入力値を意図した文字列として反映し、本文を破損させることなく、Variable置換部分以外の代表的な基本書式を維持する。

MVPで書式維持の確認対象とする代表的な基本書式は以下とする。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

以下はMVPでの書式維持保証対象外とする。

- 埋め込み画像
- 上記の代表的な基本書式を超える複雑な本文レイアウト・装飾
- 特殊なOutlook固有書式
- `{{VariableName}}` の文字列途中の一部分だけに異なる書式を設定したケース

具体的なBody処理・置換方式はMVP Designで定義する。

---

## 23. 未置換変数チェック

### FR-UNRESOLVED-001

SubjectまたはBodyに `{{VariableName}}` 形式の未置換変数が1件でも残っている場合、メール生成を中止する。

未置換変数の判定では、FR-VAR-004のCase Insensitiveルールを適用する。

### FR-UNRESOLVED-002

未置換変数が存在する場合は、対象変数を一覧表示する。

例：

```text
メールを生成できません。

未置換変数：
・{{GateDate}}
・{{Department}}
```

警告のみで処理継続する方式は採用しない。

---

## 24. Outlookメール生成要件

### FR-OUTLOOK-001

メール生成処理では、指定されたOFTを基にOutlook MailItemを利用する。内部的なMailItem生成タイミングはMVP Designに委ねる。

Validation、Render、未置換変数チェックに成功した場合のみ、生成結果をClassic Outlook上へDisplayする。

OFTが存在しない場合はFR-TPL-002に従い、メール生成を開始しない。

### FR-OUTLOOK-002

生成したメールはClassic Outlook上で表示する。

MVPではメールを自動送信しない。

### FR-OUTLOOK-003

ツールの責任範囲はOutlook MailItemを `Display` した時点までとする。

その後の、

- 内容確認
- 宛先確認
- 必要に応じた追加編集
- 送信

はユーザー責任とする。

---

## 25. エラー処理要件

MVPでは少なくとも以下の異常系をユーザーが理解できる形で通知する。

- OFTが存在しない
- OFTを読み込めない
- テンプレート変数の命名規則違反
- VariableDefinitionの設定不足
- SortOrder未設定
- Date Format不正
- SelectのOptionSource不備
- 入力Validationエラー
- 未置換変数の残存
- Outlook MailItem生成失敗

技術的な詳細情報のみをそのまま表示せず、ユーザーが次に何を確認すべきか分かるメッセージとする。

---

## 26. 非機能要件

### NFR-001 標準化

テンプレート固有の処理をVBAコードへ大量に埋め込まず、VariableDefinitionおよびOptionMasterの設定によって利用範囲を変更できる構造とする。

### NFR-002 保守性

テンプレート変更と変数設定を分離し、テンプレート変更時にも既存設定を可能な限り保持できること。

### NFR-003 可観測性

同期、設定不整合、Validationエラー等について、ユーザーが「何が問題なのか」を把握できること。

処理をブラックボックス化しない。

### NFR-004 安全性

不完全な状態でメール生成を続行させない。

特に以下の場合は処理を停止する。

- OFT不存在
- テンプレート変数の命名規則違反
- 設定不整合
- Validationエラー
- 未置換変数残存

ただし、設定不備を修正するためのSettings、VariableDefinition、OptionMasterの確認・編集まで禁止しない。

### NFR-005 操作性

メール本文を直接修正しなくても、UserFormへの必要情報入力のみでメールを生成できること。

### NFR-006 拡張性

MVPの設計は、将来以下を追加する際に大規模な構造変更を必要としないことを目標とする。

- MultiSelect
- URL
- Hyperlink Target
- 1 Excel / 複数Template
- 複数行Text

ただし、MVP時点でこれらを実装する必要はない。

---

## 27. MVP画面・操作フロー

想定される基本操作は以下とする。

```text
1. Excelを開く
      ↓
2. 必要に応じてテンプレート同期
      ↓
3. 新規変数があればVariableDefinitionを設定
      ↓
4. メール作成開始
      ↓
5. UserForm起動前整合性チェック
      ↓
6. UserForm表示
      ↓
7. 必要情報を入力
      ↓
8. メール作成
      ↓
9. Validation
      ↓
10. Subject / Body置換
      ↓
11. 未置換変数チェック
      ↓
12. Outlookメール表示
      ↓
13. ユーザー確認・送信
```

OFT不存在、命名規則違反、設定不整合が存在する場合は、該当するテンプレート依存処理へ進まず、ユーザーへ修正対象を通知する。

---

## 28. 想定Excel構成

MVPでは以下を基本候補とする。

```text
MailGenerator.xlsm

├─ VariableDefinition
├─ OptionMaster
└─ Settings

Templates\
└─ MailTemplate.oft
```

LogシートはMVP対象外とする。

具体的なテーブル構造や列順はMVP Designで決定する。

---

## 29. MVP Acceptance Criteria

MVP完了時には、少なくとも以下をすべて満たすこと。

### AC-001 テンプレート参照

相対パスで指定されたOFTを正常に読み込める。

OFTが存在しない場合は、手動同期、UserForm起動、メール生成を実行せず、ユーザーへ通知できる。

Settings、VariableDefinition、OptionMasterの確認・編集は継続できる。

### AC-002 変数抽出

SubjectおよびBodyから有効な `{{VariableName}}` を抽出できる。

VariableNameの大文字・小文字は区別しない。

### AC-003 命名規則違反検出

テンプレート内に命名規則違反の `{{...}}` が存在する場合、それを検出し、手動同期、UserForm起動、メール生成を停止できる。

### AC-004 手動同期

テンプレート変更後に手動同期を実行すると、

- 新規変数の追加
- 継続変数の設定保持
- 削除変数のUnused化

が正しく実行される。

VariableNameの比較は大文字・小文字を区別しない。

### AC-005 新規変数設定

新規変数について必要設定が完了していない場合、UserFormを起動できない。

### AC-006 UserForm生成

Activeかつ設定完了したVariableDefinitionに従って、入力項目を表示できる。

### AC-007 表示順

入力項目がSortOrder昇順に表示される。

同一SortOrderの場合は、VariableDefinitionテーブルの行順で表示される。

SortOrder未設定のActive変数が存在する場合、UserFormを起動できない。

### AC-008 Text入力

Text型に1行文字列を入力できる。

### AC-009 Date入力

以下の入力を有効な日付として扱える。

```text
2026/09/08
2026/9/8
2026-09-08
2026-9-8
```

### AC-010 Date Format

Date型の出力をVariableDefinitionのFormatに従って変換できる。

以下の6種類を選択できる。

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

定義外Formatは有効な設定として扱わない。

### AC-011 Select入力

OptionMasterの有効な値から選択でき、自由入力はできない。

### AC-012 入力保持

UserFormを再表示しても、Excelを閉じるまでは入力値を保持できる。

### AC-013 入力クリア

入力クリア操作によって保持値をリセットできる。

### AC-014 Validation

複数の入力エラーがある場合、すべてをまとめて表示できる。

### AC-015 エラー強調

Validationエラーのある入力欄を視覚的に識別できる。

### AC-016 Subject置換

Subject内の全変数を正しく置換できる。

大文字・小文字のみが異なる記述も、同一VariableNameとして置換できる。

### AC-017 Body置換

代表的なOFTを用いたテストにおいて、Body内の全変数を正しく置換でき、Variable置換部分以外についてFR-RENDER-BODY-002で定義した基本書式が維持される。

大文字・小文字のみが異なる記述も、同一VariableNameとして置換できる。

FR-RENDER-BODY-002で書式維持保証対象外としたケースは、本Acceptance CriteriaのPass判定対象外とする。

### AC-018 未置換防止

未置換変数が1つでも残っている場合、Outlookメールを表示しない。

### AC-019 Outlook表示

すべてのチェックに成功した場合、Classic Outlook上に送信用メールを表示できる。

### AC-020 自動送信防止

ツール操作のみでメールが自動送信されない。

---

## 30. v0.2候補

MVP完了後、必要性を評価して以下を検討する。

- MultiSelect
- URL
- ハイパーリンク先置換
- 複数行Text
- 1 Excel / 複数OFT
- DefaultValue高度化
- 入力値再利用機能の拡張
- テンプレート管理機能
- 同期結果UI改善
- Number型

---

## 31. 明示的な最終対象外方針

現時点では、MVPだけでなく最終版についても以下を実装しない方針とする。

### 条件分岐

以下のようなテンプレート構文は導入しない。

```text
{{#if Condition}}
...
{{/if}}
```

### 添付ファイル自動処理

ファイル選択、パス指定、添付自動化等は対象外とする。

### 自動送信

ツール自身によるメール自動送信は行わない。

---

## 32. 後続工程へ引き継ぐ事項

本Requirementsでは利用者から見た振る舞いまでを定義し、具体的な実現方式は責務に応じて後続工程へ引き継ぐ。

### 32.1 MVP Designで具体化する事項

1. VBAモジュール構成
2. クラス構成
3. VariableDefinitionテーブルの実際の列順
4. OptionMasterの詳細テーブル構造
5. Settings構造
6. 変数抽出ロジック
7. Case Insensitive比較の具体的な実装方式
8. 不正変数記法検出の具体的な正規表現・判定方式
9. Dictionary等の内部データ構造
10. 動的UserForm生成方式
11. コントロールとVariableNameの関連付け方法
12. Date変換処理
13. 定義済みDate Formatの実装方法
14. Body処理方式（変数抽出・置換・未置換チェック）
15. OFT読み込み処理
16. Outlook Object Model利用方法
17. 設定完了状態の内部判定方式
18. SortOrder同順位時のVariableDefinition行順取得方式

### 32.2 Implementationで具体化する事項

1. Validationエラー強調の具体的な表示方式・色
2. 曜日表記生成の具体的なVBA実装
3. エラーコード体系および例外捕捉の具体コード
4. Unused表示切替の具体的なUI実装
5. 同期結果UIの具体表示
6. OFT不存在時の具体的な復旧UI

### 32.3 MVP Test Specificationで具体化する事項

1. Acceptance Criteriaを検証するテストケース設計

---

## 33. Requirements決定サマリー

| 項目 | 決定 |
|---|---|
| Outlook | Classic Outlook |
| MVPテンプレート数 | 1 Excel = 1 OFT |
| OFT参照 | Excel基準の相対パス |
| OFT不存在 | テンプレート依存処理停止、設定確認・編集は可能 |
| 同期 | 手動 |
| UserForm起動時 | 整合性チェック |
| 新規変数 | 自動追加＋設定未完了 |
| 削除変数 | Unused保持＋通常非表示 |
| VariableName | 英字始まり、英数字＋ `_` |
| VariableName大文字小文字 | 区別しない |
| 命名規則違反 | Configuration Errorとして処理停止 |
| Required | 初期値なし、明示設定 |
| Text | 1行のみ |
| Date入力 | 4桁年必須、`/`・`-`許可、ゼロ埋め任意 |
| Date Format | 定義済み6形式 |
| Number | MVP対象外 |
| Select | OptionMaster参照 |
| Select自由入力 | 不可 |
| UserForm順序 | SortOrder昇順 |
| SortOrder未設定 | Configuration Error |
| SortOrder重複 | 許可 |
| SortOrder同順位 | VariableDefinitionテーブルの行順 |
| UserForm補助情報 | DisplayName＋Required＋Description |
| 入力値保持 | Excel終了まで |
| 入力クリア | あり |
| Validation | 全件表示＋対象欄強調 |
| 未置換変数 | 生成停止 |
| Outlook処理 | Displayまで |
| ログ | MVP対象外 |
| 条件分岐 | 対象外 |
| 添付自動処理 | 対象外 |
| 自動送信 | 対象外 |

---

## 34. 次工程

Technical Spike A v0.2はCLOSED / PASSで完了し、MVPのBody処理技術方針としてRoute W：WordEditorを採用した。

Technical Spike AのTechnical Decisionは、`MVP Requirements v0.1.5` および `MVP Design v0.1.3` へ反映済みである。

その後の最終整合性レビューにより、利用者向けRequirementの変更は不要である一方、既存RequirementをDesignへ完全に落とし込むためのDesign completeness / clarification事項（CR-001〜CR-005）が確認された。

本v0.1.6ではRequirement本文・Acceptance Criteria・保証範囲を変更せず、次工程とBaselineの現在地のみを更新する。

現在地は以下とする。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.3
        +
Technical Spike A v0.2 CLOSED
```

次工程は以下とする。

```text
MVP Requirements v0.1.6
        ↓
MVP Design v0.1.4
最終整合性修正
        ↓
Requirements / Design / Technical Spike A
最終整合性再確認
        ↓
MVP Test Specification v0.1
```

`MVP Design v0.1.4` では、最終整合性レビューで確認した以下の既存RequirementへのDesign補完を行う。

- メール生成直前のCurrent OFT再確認
- 未置換Variable一覧をUIへ渡すResult設計
- Select型の自由入力禁止
- `TemplateLocation` / `FirstDetectedAt` / `LastDetectedAt` のSync更新規則
- Unused Variableの通常非表示 / 必要時確認方針

これらは新しい利用者向けRequirementではなく、既存Requirementに対するDesign completeness / clarificationとして扱う。

`MVP Design v0.1.4` 反映後の最終Baselineは以下を想定する。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.4
        +
Technical Spike A v0.2 CLOSED
```

MVP Test Specification v0.1では、以下のTraceabilityを追跡可能とする。

```text
Requirement
↓
Acceptance Criteria
↓
Design Component / Design Rule
↓
Test Case
```

また、Technical Spike Aの `TF-A-002` を踏まえ、Template Variableの検出成立性とRender後の未置換Variable 0件判定を別Testとして扱う。

