# MVP Requirements v0.1 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Requirements |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1 |
| 文書種別 | MVP要件定義 |
| 上位文書 | 定型メール作成ツール 企画書 v0.1 |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| メールテンプレート | Outlook Template File（`.oft`） |
| MVP構成 | 1 Excelファイル = 1 OFTテンプレート |
| 対象メール要素 | Subject / Body |
| 最終処理 | Outlookメールを表示（Display） |
| 自動送信 | 対象外 |

---

# 2. 文書目的

本書は、定型メール作成ツールのMVPとして実装する機能、制約、振る舞い、および完了条件を定義する。

本書では、

- **MVPとして何を実現するか**
- **利用者から見てどのように振る舞うか**
- **何をMVP対象外とするか**

を明確化する。

VBAのクラス構成、モジュール構成、具体的な制御実装等の詳細設計は、本書では定義せず、後続のMVP Designで定義する。

---

# 3. MVPの目的

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

# 4. システム概要

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

# 5. MVPスコープ

## 5.1 対象

MVPでは以下を対象とする。

- Classic Outlook
- Excel Desktop
- VBA
- `.xlsm`
- `.oft`
- 1 Excelファイルにつき1 OFTテンプレート
- Subjectの変数置換
- Bodyの変数置換
- `{{VariableName}}`形式の変数
- テンプレートからの変数抽出
- VariableDefinitionとの差分同期
- Text型
- Date型
- Select型
- UserForm
- Validation
- 未置換変数チェック
- Outlook MailItemのDisplay

---

## 5.2 MVP対象外

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

# 6. テンプレート管理要件

## FR-TPL-001 OFTファイルの参照

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

### Acceptance Criteria

- Excelファイルの格納場所を基準にOFTを特定できる
- Excelと関連フォルダ一式を別フォルダへ移動しても、相対関係が維持されていれば参照できる
- OFTが存在しない場合は、処理を中止してユーザーへ通知する

---

# 7. 変数記法要件

## FR-VAR-001 変数表現

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

---

## FR-VAR-002 変数名命名規則

VariableNameは以下を満たすこと。

- 先頭は半角英字
- 2文字目以降は半角英字、数字、アンダースコア `_`
- 日本語は使用しない

基本ルール：

```text
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

---

## FR-VAR-003 同一変数の重複

同一VariableNameがSubjectまたはBody内に複数回存在しても、VariableDefinition上では1件として扱う。

メール生成時には、該当するすべての出現箇所を同一値で置換する。

---

# 8. 変数抽出要件

## FR-SCAN-001 抽出対象

変数抽出対象は以下とする。

- Subject
- Body

To、CC、BCCは対象外とする。

---

## FR-SCAN-002 抽出結果

抽出処理では、

- VariableName
- 出現位置

を特定する。

出現位置は以下のいずれかとして扱う。

```text
Subject
Body
Both
```

---

# 9. テンプレート同期要件

## FR-SYNC-001 同期方式

テンプレート同期は自動ではなく、ユーザーが明示的に実行する**手動同期方式**とする。

同期処理では、テンプレートから抽出した変数と既存VariableDefinitionを比較し、差分を反映する。

---

## FR-SYNC-002 新規変数

テンプレートに存在し、VariableDefinitionに存在しない変数は、新規変数として自動追加する。

新規変数は**設定未完了状態**として扱う。

新規追加時点では、少なくとも以下は未設定とする。

- DisplayName
- Type
- Required

設定完了まではUserForm利用対象としない。

---

## FR-SYNC-003 継続変数

テンプレートにもVariableDefinitionにも存在する変数については、既存設定を保持する。

以下のようなユーザー設定を同期処理によって上書きしてはならない。

- DisplayName
- Type
- Required
- Description
- OptionSource
- SortOrder
- Format

---

## FR-SYNC-004 削除変数

VariableDefinitionに存在するがテンプレートから削除された変数は、削除せず `Unused` とする。

既存設定は保持する。

通常の設定表示ではUnused変数を非表示とし、必要時に確認可能とする。

---

## FR-SYNC-005 Unused変数の復活

Unused変数と同一VariableNameがテンプレートへ再登場した場合は、Activeへ復帰させる。

復帰時は既存設定を再利用する。

---

## FR-SYNC-006 変数名変更

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

---

## FR-SYNC-007 同期結果通知

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

---

# 10. VariableDefinition要件

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

# 11. Required設定要件

## FR-REQ-001 Requiredの初期状態

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

# 12. 変数型要件

MVPでサポートする型は以下とする。

```text
Text
Date
Select
```

---

# 13. Text型要件

## FR-TYPE-TEXT-001

MVPのText型は1行入力のみとする。

複数行入力はMVP対象外とし、v0.2以降の拡張候補とする。

---

# 14. Date型要件

## FR-TYPE-DATE-001 入力形式

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

---

## FR-TYPE-DATE-002 Validation

日付入力は、文字列形式そのものではなく、**有効な日付として解釈可能であること**をValidation基準とする。

例：

```text
2026/2/29 → NG
2028/2/29 → OK
```

---

## FR-TYPE-DATE-003 内部値

入力された日付は、Validation後に日付値として扱う。

ユーザーが入力したゼロ埋めやセパレータは、出力形式には直接引き継がない。

---

## FR-TYPE-DATE-004 出力Format

Date型のメール出力形式は、VariableDefinitionのFormatによって設定する。

候補例：

```text
yyyy/mm/dd
yyyy年m月d日
m月d日
```

MVPでは自由記述よりも、定義済みFormatからの選択を基本とする。

---

# 15. Select型要件

## FR-TYPE-SELECT-001

Select型は一覧からの選択のみ許可する。

自由入力は許可しない。

自由文字列が必要な変数はText型として定義する。

---

# 16. OptionMaster要件

## FR-OPT-001

Select型の選択肢は、VariableDefinition内に直接保持せず、`OptionMaster` で管理する。

概念例：

| OptionGroup | Value | SortOrder | Active |
|---|---|---:|---|
| Department | 設計部 | 10 | True |
| Department | 品質部 | 20 | True |
| Department | 生産部 | 30 | True |

VariableDefinitionからはOptionSourceによって参照する。

---

## FR-OPT-002

Select型でOptionSourceが未設定、または有効な選択肢を取得できない場合は、UserFormを利用可能状態としない。

---

# 17. UserForm生成要件

## FR-UI-001

UserFormはVariableDefinitionに基づいて入力項目を生成する。

テンプレートごとの個別UserForm作成を基本方式としない。

---

## FR-UI-002 コントロール対応

MVPでは以下を基本とする。

| Type | UserForm Control |
|---|---|
| Text | TextBox |
| Date | TextBox |
| Select | ComboBox |

具体的なコントロール生成方式はMVP Designで決定する。

---

## FR-UI-003 表示順

UserFormの表示順はVariableDefinitionの `SortOrder` 昇順とする。

テンプレート内の出現順やExcel上の行順には依存しない。

---

## FR-UI-004 補助情報

UserFormでは各入力項目について以下を表示する。

- DisplayName
- 必須表示
- Description

Descriptionは入力補助用の短い説明を想定する。

---

# 18. UserForm起動時整合性チェック

## FR-UI-CHECK-001

UserForm起動前に、テンプレートとVariableDefinitionの整合性チェックを実施する。

MVPでは少なくとも以下を確認する。

- テンプレートに未登録変数が存在しない
- テンプレートから削除された変数がActiveのまま残っていない
- Active変数のTypeが設定されている
- Active変数のDisplayNameが設定されている
- Active変数のRequiredが明示設定されている
- Select型のOptionSourceが設定されている
- Select型のOptionSourceから有効な選択肢を取得できる

---

## FR-UI-CHECK-002

不整合が存在する場合はUserFormを起動せず、不整合内容をユーザーへ通知する。

自動同期は行わない。

---

# 19. 入力値保持要件

## FR-INPUT-001

UserFormで入力した値は、Excelファイルを閉じるまで保持する。

Excel終了後に入力値を永続保存しない。

---

## FR-INPUT-002 入力クリア

UserFormに「入力クリア」機能を設ける。

ユーザー操作によって、現在保持している入力値を明示的にクリアできること。

---

# 20. Validation要件

## FR-VAL-001

メール生成前にすべての入力値をValidationする。

MVPでは少なくとも以下を対象とする。

- Required項目の未入力
- Date型として解釈できない値
- Select型の未選択
- Select型の無効値

---

## FR-VAL-002 エラー一括表示

Validationでは、最初のエラーのみで停止せず、検出されたすべてのエラーをまとめてユーザーへ表示する。

例：

```text
入力内容を確認してください。

・ゲート審査日：有効な日付ではありません
・担当部署：選択してください
```

---

## FR-VAL-003 入力欄強調

Validationエラーが存在する入力コントロールは、UserForm上で視覚的に識別できるよう強調する。

MVPでは背景色変更等の方式を想定する。

具体的な色、Tag利用等の実装方式はMVP Designで定義する。

---

## FR-VAL-004

再Validation時には、以前のエラー表示状態をリセットしたうえで現在のValidation結果を反映する。

---

# 21. Subject置換要件

## FR-RENDER-SUB-001

Subject内の有効な変数を、UserFormで入力・選択された値へ置換する。

同一変数が複数回存在する場合はすべて置換する。

---

# 22. Body置換要件

## FR-RENDER-BODY-001

Body内の有効な変数を、UserFormで入力・選択された値へ置換する。

同一変数が複数回存在する場合はすべて置換する。

---

## FR-RENDER-BODY-002

OFTの本文書式を可能な限り維持する。

HTML Bodyを扱う場合、入力値によってHTML構造を破壊しないことを要件とする。

HTML Encode等の具体的な処理方式はMVP Designで決定する。

---

# 23. 未置換変数チェック

## FR-UNRESOLVED-001

SubjectまたはBodyに `{{VariableName}}` 形式の未置換変数が1件でも残っている場合、メール生成を中止する。

---

## FR-UNRESOLVED-002

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

# 24. Outlookメール生成要件

## FR-OUTLOOK-001

すべてのValidationおよび未置換変数チェックに成功した場合、指定されたOFTを基にOutlook MailItemを生成する。

---

## FR-OUTLOOK-002

生成したメールはClassic Outlook上で表示する。

MVPではメールを自動送信しない。

---

## FR-OUTLOOK-003

ツールの責任範囲はOutlook MailItemを `Display` した時点までとする。

その後の、

- 内容確認
- 宛先確認
- 必要に応じた追加編集
- 送信

はユーザー責任とする。

---

# 25. エラー処理要件

MVPでは少なくとも以下の異常系をユーザーが理解できる形で通知する。

- OFTが存在しない
- OFTを読み込めない
- テンプレート変数の命名規則違反
- VariableDefinitionの設定不足
- SelectのOptionSource不備
- 入力Validationエラー
- 未置換変数の残存
- Outlook MailItem生成失敗

技術的な詳細情報のみをそのまま表示せず、ユーザーが次に何を確認すべきか分かるメッセージとする。

---

# 26. 非機能要件

## NFR-001 標準化

テンプレート固有の処理をVBAコードへ大量に埋め込まず、VariableDefinitionおよびOptionMasterの設定によって利用範囲を変更できる構造とする。

---

## NFR-002 保守性

テンプレート変更と変数設定を分離し、テンプレート変更時にも既存設定を可能な限り保持できること。

---

## NFR-003 可観測性

同期、設定不整合、Validationエラー等について、ユーザーが「何が問題なのか」を把握できること。

処理をブラックボックス化しない。

---

## NFR-004 安全性

不完全な状態でメール生成を続行させない。

特に以下の場合は処理を停止する。

- 設定不整合
- Validationエラー
- 未置換変数残存

---

## NFR-005 操作性

メール本文を直接修正しなくても、UserFormへの必要情報入力のみでメールを生成できること。

---

## NFR-006 拡張性

MVPの設計は、将来以下を追加する際に大規模な構造変更を必要としないことを目標とする。

- MultiSelect
- URL
- Hyperlink Target
- 1 Excel / 複数Template
- 複数行Text

ただし、MVP時点でこれらを実装する必要はない。

---

# 27. MVP画面・操作フロー

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

---

# 28. 想定Excel構成

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

# 29. MVP Acceptance Criteria

MVP完了時には、少なくとも以下をすべて満たすこと。

## AC-001 テンプレート参照

相対パスで指定されたOFTを正常に読み込める。

---

## AC-002 変数抽出

SubjectおよびBodyから有効な `{{VariableName}}` を抽出できる。

---

## AC-003 手動同期

テンプレート変更後に手動同期を実行すると、

- 新規変数の追加
- 継続変数の設定保持
- 削除変数のUnused化

が正しく実行される。

---

## AC-004 新規変数設定

新規変数について必要設定が完了していない場合、UserFormを起動できない。

---

## AC-005 UserForm生成

Activeかつ設定完了したVariableDefinitionに従って、入力項目を表示できる。

---

## AC-006 表示順

入力項目がSortOrder順に表示される。

---

## AC-007 Text入力

Text型に1行文字列を入力できる。

---

## AC-008 Date入力

以下の入力を有効な日付として扱える。

```text
2026/09/08
2026/9/8
2026-09-08
2026-9-8
```

---

## AC-009 Date Format

Date型の出力をVariableDefinitionのFormatに従って変換できる。

---

## AC-010 Select入力

OptionMasterの有効な値から選択でき、自由入力はできない。

---

## AC-011 入力保持

UserFormを再表示しても、Excelを閉じるまでは入力値を保持できる。

---

## AC-012 入力クリア

入力クリア操作によって保持値をリセットできる。

---

## AC-013 Validation

複数の入力エラーがある場合、すべてをまとめて表示できる。

---

## AC-014 エラー強調

Validationエラーのある入力欄を視覚的に識別できる。

---

## AC-015 Subject置換

Subject内の全変数を正しく置換できる。

---

## AC-016 Body置換

Body内の全変数を正しく置換でき、OFTの主要な本文書式が維持される。

---

## AC-017 未置換防止

未置換変数が1つでも残っている場合、Outlookメールを表示しない。

---

## AC-018 Outlook表示

すべてのチェックに成功した場合、Classic Outlook上に送信用メールを表示できる。

---

## AC-019 自動送信防止

ツール操作のみでメールが自動送信されない。

---

# 30. v0.2候補

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

# 31. 明示的な最終対象外方針

現時点では、MVPだけでなく最終版についても以下を実装しない方針とする。

## 条件分岐

以下のようなテンプレート構文は導入しない。

```text
{{#if Condition}}
...
{{/if}}
```

---

## 添付ファイル自動処理

ファイル選択、パス指定、添付自動化等は対象外とする。

---

## 自動送信

ツール自身によるメール自動送信は行わない。

---

# 32. MVP Designへ引き継ぐ事項

以下は本Requirementsでは決定せず、MVP Designで具体化する。

1. VBAモジュール構成
2. クラス構成
3. VariableDefinitionテーブルの実際の列順
4. OptionMasterの詳細テーブル構造
5. Settings構造
6. 変数抽出ロジック
7. Dictionary等の内部データ構造
8. 動的UserForm生成方式
9. コントロールとVariableNameの関連付け方法
10. Validationエラー強調方式
11. Date変換・Format処理
12. HTMLBody置換方式
13. HTML Encode方式
14. OFT読み込み処理
15. Outlook Object Model利用方法
16. エラーコード・例外処理
17. Unused表示切替方法
18. 設定完了状態の内部判定方式
19. 同期結果UI
20. テストケース設計

---

# 33. Requirements決定サマリー

| 項目 | 決定 |
|---|---|
| Outlook | Classic Outlook |
| MVPテンプレート数 | 1 Excel = 1 OFT |
| OFT参照 | Excel基準の相対パス |
| 同期 | 手動 |
| UserForm起動時 | 整合性チェック |
| 新規変数 | 自動追加＋設定未完了 |
| 削除変数 | Unused保持＋通常非表示 |
| VariableName | 英字始まり、英数字＋ `_` |
| Required | 初期値なし、明示設定 |
| Text | 1行のみ |
| Date | 4桁年必須、`/`・`-`許可、ゼロ埋め任意 |
| Number | MVP対象外 |
| Select | OptionMaster参照 |
| Select自由入力 | 不可 |
| UserForm順序 | SortOrder |
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

# 34. 次工程

本Requirements確定後、次工程として **MVP Design** を作成する。

MVP Designでは、特に以下を優先して設計する。

```text
VariableDefinition
        ↓
Template Scanner
        ↓
Sync Engine
        ↓
Configuration Validator
        ↓
UserForm Generator
        ↓
Input Validator
        ↓
Render Engine
        ↓
Outlook Adapter
```

RequirementsとDesignを分離し、本書のAcceptance Criteriaを満たすための最小構成を設計する。