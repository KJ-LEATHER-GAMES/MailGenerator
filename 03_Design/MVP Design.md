# MVP Design v0.1.1 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Design |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1.1 |
| 文書種別 | MVP基本設計 |
| 上位文書 | 定型メール作成ツール 企画書 v0.1 |
| 要件文書 | MVP Requirements v0.1.2 日本語版 |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| メールテンプレート | Outlook Template File（`.oft`） |
| MVP構成 | 1 Excelファイル = 1 OFTテンプレート |
| 設計方針 | 軽量な責務分離 / MVP最小負荷 / 過剰設計回避 |

---

### v0.1.1 更新概要

MVP Requirements v0.1.1 × MVP Design v0.1 の正式整合性レビュー結果、およびRequirements v0.1.2で確定したRequirement Gapを反映した。

1. UserForm起動前にOFTを再取得・再Scanし、その `TemplateScanResult` をConfiguration Validatorへ渡す処理経路を明示
2. VariableName Syntaxの判定責務をTemplate Scannerへ一本化し、Configuration ValidatorはScan結果を評価する責務へ整理
3. `Required=False` の空欄 / 未選択を有効とし、値が存在する場合のみType ValidationするルールをInput Validatorへ反映
4. Body置換時に維持する代表的な基本書式とMVP保証対象外をRequirements v0.1.2に合わせて明示

---

## 2. 文書目的

本書は、`MVP Requirements v0.1.2` を満たすためのMVP基本設計を定義する。

本書では、主に以下を定義する。

- 全体アーキテクチャ
- コンポーネント責務
- Excelデータ構造
- Excel Data Access方針
- OFT / Outlook MailItemのライフサイクル
- Template Scanner
- Sync Engine
- Configuration Validator
- UserForm生成
- Control Binding / Input State
- Input Validator
- Render Engine
- Outlook Adapter
- エラー処理
- 主要処理シーケンス
- Design Decision

詳細なプロシージャ実装、VBAコード、個別テストケースは後続工程で定義する。

---

## 3. 設計原則

### 3.1 MVP最小負荷

MVPでは、Requirementsを満たすために必要な構造のみ実装する。

将来拡張だけを目的とした以下のような先回り実装は行わない。

- 過剰なInterface
- Dependency Injection基盤
- Factoryの多用
- 完全なDomain Model
- 汎用フレームワーク化
- 将来機能用の未使用列・未使用クラス

### 3.2 責務分離

機能単位で責務を分離し、UI、Excel、Outlook、Validation、Renderingの依存を局所化する。

ただし、DDDやHexagonal Architectureを厳格に適用するのではなく、VBAで保守可能な軽量構成とする。

### 3.3 Single Source of Truth

設定完了状態を別途保存せず、VariableDefinition、OptionMaster、Settingsの現在値から都度導出する。

`ConfigurationStatus` のような派生状態列はMVPでは持たない。

### 3.4 Fail Fast

以下の状態では、後続処理へ進ませない。

- OFT不存在
- 不正なVariable記法
- Configuration不整合
- Input Validation Error
- 未置換変数残存
- Outlook生成に必要な前提条件の不足

ただし、復旧に必要な設定確認・編集は禁止しない。

### 3.5 Requirement Gap運用

Design検討中に、実装方法ではなく利用者から見た新しい振る舞いを決める必要が生じた場合、その論点をDesign内で決定せず、`Requirement Gap` としてRequirements側へ切り出す。

Design Questions 15件の検討時点では新規Requirement Gapは発生していなかった。後続のRequirements / Design整合性レビューで検出したRequirement Gap 2件は、MVP Requirements v0.1.2で解消済みとする。

---

## 4. 全体アーキテクチャ

### 4.1 採用構成

軽量レイヤード構成を採用する。

```text
┌────────────────────────────────────┐
│ UI Layer                           │
│ - Excel Sheet                      │
│ - UserForm                         │
└────────────────┬───────────────────┘
                 │
                 ▼
┌────────────────────────────────────┐
│ Application Layer                  │
│ - Template Sync orchestration      │
│ - Mail Creation orchestration      │
└────────────────┬───────────────────┘
                 │
                 ▼
┌────────────────────────────────────┐
│ Core Logic                         │
│ - Template Scanner                 │
│ - Configuration Validator          │
│ - Input Validator                  │
│ - Value Formatter                  │
│ - Renderer                         │
└────────────────┬───────────────────┘
                 │
                 ▼
┌────────────────────────────────────┐
│ Infrastructure                     │
│ - Excel Data Access                │
│ - Outlook Adapter                  │
└────────────────────────────────────┘
```

### 4.2 依存方向

基本依存方向は上位から下位とする。

```text
UI
↓
Application
↓
Core Logic
↓
Infrastructure
```

Core LogicからExcelセルやOutlook Object Modelを直接操作しない。

---

## 5. コンポーネント責務

| コンポーネント | 主責務 |
|---|---|
| Application Controller | 同期・メール作成の処理順序を制御 |
| VariableDefinition Data Access | VariableDefinitionテーブルの読み書き |
| OptionMaster Data Access | OptionMasterテーブルの読み取り |
| Settings Data Access | Settingsテーブルの読み取り |
| Outlook Adapter | OFT読込、MailItem生成、Subject / HTMLBody設定、Display |
| Template Scanner | `{{...}}` 候補抽出、VariableName妥当性判定、出現位置統合 |
| Sync Engine | Template / VariableDefinitionの差分判定 |
| Configuration Validator | 設定整合性の一元チェック |
| UserForm Generator | VariableDefinitionに基づく入力Control生成 |
| Input State | Excel終了までの入力値保持 |
| Input Validator | Required / Date / Selectの入力妥当性判定 |
| Value Formatter | Type / Formatに基づくメール出力文字列化 |
| Subject Renderer | Subject変数置換 |
| Body Renderer | HTMLBody変数置換、HTML Encode |
| Unresolved Checker | Render後の未置換変数検出 |
| Error / Result Model | 予見可能なエラー情報の受け渡し |

---

## 6. Excel構成

```text
MailGenerator.xlsm

├─ VariableDefinition
├─ OptionMaster
└─ Settings

Templates\
└─ MailTemplate.oft
```

LogシートはMVP対象外とする。

---

## 7. VariableDefinition設計

### 7.1 テーブル

```text
Sheet : VariableDefinition
Table : tblVariableDefinition
```

### 7.2 列構成

| 列 | 必須 | 用途 |
|---|---|---|
| VariableName | 必須 | システム識別子 |
| DisplayName | 必須 | UserForm表示名 |
| Type | 必須 | Text / Date / Select |
| Required | 必須 | True / False |
| Description | 任意 | 入力補助説明 |
| OptionSource | 条件付き必須 | Select用OptionGroup |
| SortOrder | 必須 | UserForm表示順 |
| Format | Dateで必須 | Date出力Format |
| TemplateLocation | 自動 | Subject / Body / Both |
| Status | 自動 | Active / Unused |
| FirstDetectedAt | 自動 | 初回検出日時 |
| LastDetectedAt | 自動 | 最終検出日時 |

### 7.3 設定完了状態

`ConfigurationStatus` 列は持たない。

設定完了状態はConfiguration Validatorが現在値から都度導出する。

共通必須条件：

- DisplayName
- Type
- Required
- SortOrder

追加条件：

```text
Date
→ Format必須

Select
→ OptionSource必須
→ OptionSourceに有効なOptionが1件以上必要
```

---

## 8. OptionMaster設計

### 8.1 テーブル

```text
Sheet : OptionMaster
Table : tblOptionMaster
```

### 8.2 列構成

MVPでは最小4列構成とする。

| 列 | 用途 |
|---|---|
| OptionGroup | 選択肢グループ識別子 |
| Value | UserForm表示およびメール置換値 |
| SortOrder | 選択肢表示順 |
| Active | 有効 / 無効 |

内部値とDisplayNameは分離しない。

---

## 9. Settings設計

### 9.1 テーブル

```text
Sheet : Settings
Table : tblSettings
```

### 9.2 構造

Key / Value の2列構成とする。

| Key | Value |
|---|---|
| TemplatePath | `Templates\MailTemplate.oft` |

MVPでは1 Excel = 1 OFTのため、Template管理用の追加階層は設けない。

### 9.3 パス解決

OFTの絶対パスは以下から導出する。

```text
ThisWorkbook.Path
+
TemplatePath
```

---

## 10. Excel Data Access設計

### 10.1 方針

各Core / Application処理からExcelシートを直接操作しない。

Excel依存処理は薄いData Access層へ集約する。

```text
Application / Core
        ↓
Data Access
        ↓
Excel Table
```

### 10.2 Data Access候補

MVPでは、過剰なRepository Patternを導入せず、標準Module中心とする。

```text
modVariableDefinitionData
modOptionMasterData
modSettingsData
```

### 10.3 責務例

`modVariableDefinitionData`

- Active変数取得
- 全変数取得
- VariableName検索
- 新規変数追加
- Status更新
- TemplateLocation更新
- LastDetectedAt更新

`modOptionMasterData`

- OptionGroupごとのActive値取得
- SortOrder順取得

`modSettingsData`

- Keyによる設定値取得

Excel列位置・ListObject操作はData Access層の外へ漏らさない。

---

## 11. 内部データ構造

### 11.1 Dictionary利用方針

検索・差分比較には `Scripting.Dictionary` を利用する。

VariableName比較ではCase Insensitiveとするため、Dictionaryは以下の比較モードを使用する。

```text
CompareMode = vbTextCompare
```

### 11.2 利用箇所

主に以下で使用する。

- Template変数一覧
- VariableDefinition一覧
- Sync差分比較
- InputValues
- 必要に応じたRender用値

### 11.3 過剰なDomain Model回避

MVPでは、全設定をClass階層へ変換する完全Domain Modelは作成しない。

必要なデータ構造のみ、Dictionary / Collection / 小規模なData Carrierで表現する。

---

## 12. OFT / MailItemライフサイクル

### 12.1 Scan時

```text
OFT
↓
Scan用 MailItem生成
↓
Subject / HTMLBody取得
↓
Template Scanner
↓
Scan用 MailItemを保存せず終了
↓
COM参照解放
```

### 12.2 Mail生成時

```text
OFT
↓
生成用 MailItem生成
↓
Subject / HTMLBody取得
↓
Render
↓
Subject / HTMLBody設定
↓
Display
```

### 12.3 設計原則

Scan用MailItemと生成用MailItemは使い回さない。

常に元OFTから新しいMailItemを生成し、処理間でMailItem状態を持ち越さない。

---

## 13. Outlook Adapter設計

### 13.1 方針

Classic Outlook Object Modelへの依存は軽量Adapterへ集約する。

MVPではPort / Interfaceは設けない。

### 13.2 責務候補

```text
CreateMailFromTemplate()
ReadTemplateSubject()
ReadTemplateHtmlBody()
SetSubject()
SetHtmlBody()
DisplayMail()
CloseWithoutSave()
```

具体的なFunction / Sub名はImplementation時に確定する。

### 13.3 禁止事項

以下のコンポーネントからOutlook Object Modelを直接操作しない。

- Template Scanner
- Configuration Validator
- Input Validator
- Value Formatter
- Renderer

---

## 14. Template Scanner設計

### 14.1 2段階処理

```text
Subject / HTMLBody
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
```

### 14.2 Candidate Scan

まず `{{...}}` 形式の候補を広く抽出する。

候補抽出用正規表現の設計例：

```regex
\{\{([^{}]*)\}\}
```

### 14.3 VariableName Validation

候補内部文字列へ以下を適用する。

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

### 14.4 Case Sensitivity

VariableNameはCase Insensitiveとする。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

は同一変数として扱う。

### 14.5 出現位置統合

同一Variableが、SubjectのみならSubject、BodyのみならBody、双方ならBothとして統合される。

### 14.6 TemplateScanResult

Template Scannerは、後続処理がOutlook Object Modelや正規表現処理へ依存せず判定できるよう、Scan結果を軽量なデータとして返す。

概念上、少なくとも以下を保持可能とする。

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

- `ValidVariables`：命名規則を満たしたVariable一覧
- `InvalidCandidates`：`{{...}}` 候補のうち命名規則違反となった一覧
- `Locations`：各VariableのSubject / Body / Both情報

VariableName Syntaxの判定責務はTemplate Scannerに置き、Configuration ValidatorではRegex等による再判定を行わない。

---

## 15. Sync Engine設計

### 15.1 比較方式

Template側とVariableDefinition側をDictionary化し、Set比較する。

```text
Template Dictionary A
VariableDefinition Dictionary B
```

両DictionaryはCase Insensitiveとする。

### 15.2 差分分類

| 条件 | Sync判定 |
|---|---|
| Aにあり / Bになし | New |
| Aにあり / Bにあり / Active | Existing |
| Aにあり / Bにあり / Unused | Reactivated |
| Aになし / Bにあり / Active | Unused化 |
| Aになし / Bにあり / Unused | 変更なし |

### 15.3 New

新規行をVariableDefinitionへ追加する。

少なくとも以下は未設定のままとする。

- DisplayName
- Type
- Required

StatusはActiveとする。

### 15.4 Existing

既存ユーザー設定を保持し、同期処理で上書きしない。

### 15.5 Reactivated

StatusをActiveへ戻し、既存設定を再利用する。

### 15.6 Unused

StatusのみUnusedへ変更し、設定値は保持する。

### 15.7 Rename

Rename推測は行わない。

```text
旧Variable → Unused
新Variable → New
```

---

## 16. Configuration Validator設計

### 16.1 方針

Configuration Validationは一元管理する。

ただし巨大な1処理にはせず、内部を小さなValidation単位へ分割する。

### 16.2 内部Validation単位

```text
ValidateTemplate()
ValidateTemplateScanResult()
ValidateVariableDefinition()
ValidateDateConfiguration()
ValidateOptionMaster()
```

`ValidateTemplateScanResult()` はTemplate Scannerが返したScan結果を評価する。

Configuration Validator自身は、OFTを開く処理、Subject / HTMLBodyを取得する処理、Variable候補の抽出、VariableName SyntaxのRegex判定を行わない。

### 16.3 入力と主な確認内容

Configuration Validatorは、Application層から少なくとも以下の現在値を受け取って整合性を判定する。

```text
TemplatePath / OFT存在確認結果
TemplateScanResult
VariableDefinition
OptionMaster
```

主な確認内容：

- OFT存在
- `TemplateScanResult.InvalidCandidates` が0件であること
- Template / VariableDefinition整合
- Active変数のType
- Active変数のDisplayName
- Active変数のRequired
- Active変数のSortOrder
- Date型Format
- Select型OptionSource
- Active Option有無

TemplateのVariable Syntaxを判定する責務はTemplate Scanner、Scan結果をConfiguration Errorとして扱い後続処理を停止するか判断する責務はConfiguration Validator / Application層とする。

### 16.4 SortOrder

SortOrder未設定はConfiguration Error。

SortOrder重複は許可する。

---

## 17. UserForm設計

### 17.1 基本構造

UserForm本体は固定とし、入力Controlのみ動的生成する。

```text
frmMailGenerator
├─ Header / Guidance         固定
├─ InputArea Frame           固定
│   ├─ Label                 動的
│   ├─ TextBox               動的
│   ├─ ComboBox              動的
│   ├─ Required表示          動的
│   └─ Description           動的
├─ ErrorArea                 固定
├─ Mail作成Button            固定
└─ 入力クリアButton          固定
```

### 17.2 Type / Control対応

| Type | Control |
|---|---|
| Text | TextBox |
| Date | TextBox |
| Select | ComboBox |

### 17.3 表示順

第1キー：`SortOrder ASC`

第2キー：`VariableDefinitionテーブル行順`

Data Access層はVariableDefinitionのExcel上の行位置を内部情報として取得可能とする。

---

## 18. Control Binding / Input State設計

### 18.1 Binding

動的生成Controlへ以下を設定する。

```vb
Control.Tag = VariableName
```

Control名そのものへ業務識別子を埋め込む方式は採用しない。

### 18.2 Input State

入力値はSession中のDictionaryへ保持する。

```text
InputValues
VariableName → Value
```

DictionaryはCase Insensitiveとする。

### 18.3 UserForm再表示

UserForm生成時、InputValuesに値が存在する場合は対応Controlへ復元する。

### 18.4 入力クリア

入力クリア操作では、InputValuesと表示中Control値の双方をクリアする。

### 18.5 Binding専用クラスへの移行トリガ

MVPではBinding専用クラスを導入しない。

以下が発生した場合は、将来 `VariableBinding` 等の専用クラスへの移行を再検討する。

- 1 Variableに複数Control
- Controlイベント個別処理の増加
- ValidationState / ErrorMessage / Dirty等の状態増加
- Typeごとの分岐増大
- Tag + Dictionaryロジックの重複
- 1入力項目が独立した状態と振る舞いを持ち始めた場合

---

## 19. Input Validator設計

### 19.1 責務分離

Input Validatorは判定のみ担当し、UserFormは表示のみ担当する。

```text
UserForm
↓
InputValues
↓
Input Validator
↓
Validation Result
↓
UserForm
↓
エラー一覧 + Control強調
```

### 19.2 Validation項目

`Required` と `Type` のValidationを以下の順で扱う。

1. `Required=True` で未入力 / 未選択の場合はError
2. `Required=False` で空欄 / 未選択の場合は正常としてType Validationを行わない
3. 値が存在する場合のみTypeに応じたValidationを行う

対象：

- Required=Trueの未入力 / 未選択
- 値が存在するDate型で、日付として解釈不能
- 値が存在するSelect型で、OptionMasterの有効Optionに存在しない値

したがって、`Required=False` のDate空欄およびSelect未選択は正常とする。

### 19.3 UI側責務

UserFormは以下を担当する。

- Validation Error一覧表示
- `Tag` により該当Controlを特定
- BackColor等による視覚的強調
- 再Validation時の強調解除

具体的な色はImplementation時に決定する。

---

## 20. Date処理設計

### 20.1 Input

許容形式：

```text
yyyy/m/d
yyyy/mm/dd
yyyy-m-d
yyyy-mm-dd
```

4桁年を必須とする。

### 20.2 Validation

文字列パターンだけでなく、実在する日付であることを確認する。

### 20.3 Internal Value

Validation後はDate値として保持する。

### 20.4 Output Format

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

---

## 21. Value Formatter設計

### 21.1 責務

Raw Inputをメール出力用文字列へ変換する。

```text
Raw Input
↓
Value Formatter
↓
Formatted Value
```

### 21.2 Type別

Text：入力文字列を出力値とする。

Date：Date値とVariableDefinition.FormatからFormatted Date Stringを生成する。

Select：選択されたValueを出力値とする。

HTML EncodeはValue Formatterの責務に含めない。

---

## 22. Render Engine設計

### 22.1 全体フロー

```text
InputValues
↓
Value Formatter
↓
Formatted Values
├────────────→ Subject Renderer
│
└→ HTML Encode → Body Renderer
```

### 22.2 Subject Renderer

Formatted ValueをSubject内の対象VariableへCase Insensitiveで全出現箇所置換する。

### 22.3 Body Renderer

Formatted ValueをHTML Encodeした後、HTMLBody内の対象VariableへCase Insensitiveで全出現箇所置換する。

置換はVariable文字列を対象とした局所置換とし、Variable置換部分以外のHTMLBodyを意図的に再構築・再整形しない。

MVPでは、Requirements FR-RENDER-BODY-002に従い、代表的なOFTを用いて以下の基本書式がVariable置換後も維持されることを確認する。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

埋め込み画像、複雑なHTML構造、特殊なOutlook固有書式、およびVariable文字列途中がHTMLタグ等で分断されるケースはMVPの書式維持保証対象外とする。

### 22.4 HTML Encode

少なくともユーザー入力によってHTML構造が破壊されないようにする。

具体的なEncode関数はImplementation時に定義する。

---

## 23. 未置換変数チェック設計

### 23.1 独立チェック

未置換変数チェックはRenderer内部へ埋め込まず、Render後段の独立処理とする。

```text
Render
↓
Unresolved Checker
↓
0件 → Outlook Display
1件以上 → Error
```

### 23.2 対象

- Subject
- HTMLBody

### 23.3 判定

`{{VariableName}}` 形式の残存を検出し、1件でも存在すればメール生成を停止する。

---

## 24. エラー設計

### 24.1 基本方針

予見可能なエラーはResultとして返す。

Core / Infrastructureから直接MsgBoxを表示しない。

```text
Core / Application
↓
Operation Result
↓
UI
↓
ユーザー表示
```

### 24.2 エラー分類

```text
ConfigurationError
TemplateError
InputValidationError
RenderError
OutlookError
UnexpectedError
```

### 24.3 Error情報

最低限以下を保持可能な構造とする。

```text
ErrorType
Message
Target
```

`Target` はVariableNameやTemplatePath等、問題箇所を特定する補助情報として使用する。

### 24.4 Resultモデル

```text
OperationResult
├─ Success
└─ Errors[]
```

VBA実装では、小規模なResult / ErrorInfoクラスまたは同等の軽量構造を用いる。

### 24.5 予期しない技術エラー

COMエラーや想定外のVBA Runtime Errorは、`On Error` 等で捕捉し、`UnexpectedError` または `OutlookError` 等へ変換してUIへ返却する。

---

## 25. 主要処理シーケンス

### 25.1 手動同期

```text
User
↓
同期実行
↓
Settings Data Access
↓
TemplatePath取得
↓
OFT存在確認
↓
Outlook Adapter
↓
Scan用MailItem生成
↓
Template Scanner
↓
Candidate Scan
↓
VariableName Validation
↓
不正あり？
├─ Yes → Error Result → UI
└─ No
    ↓
VariableDefinition Data Access
    ↓
Template Dictionary / Definition Dictionary
    ↓
Sync Engine
    ↓
New / Existing / Reactivated / Unused判定
    ↓
VariableDefinition更新
    ↓
同期結果
    ↓
UI通知
```

### 25.2 UserForm起動

UserForm起動前には、現在のOFT内容を必ず再取得・再Scanし、その結果と現在のExcel設定をConfiguration Validatorへ渡す。

```text
User
↓
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
Scan用MailItem生成
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
Scan用MailItemを保存せず終了 / COM参照解放
↓
VariableDefinition Data Access / OptionMaster Data Access
↓
Configuration Validator
↓
OFT / TemplateScanResult / VariableDefinition / OptionMaster整合確認
↓
Errorあり？
├─ Yes → UserForm起動せずUI通知
└─ No
    ↓
VariableDefinition取得
    ↓
SortOrder + Table Row順でSort
    ↓
UserForm Generator
    ↓
Control.Tag = VariableName
    ↓
InputValues復元
    ↓
UserForm表示
```

Configuration ValidatorはOFTを直接開かず、Template ScannerのRegex処理も再実行しない。Application層がOutlook Adapter、Template Scanner、Data Accessの結果を収集し、Configuration Validatorへ渡す。

### 25.3 メール生成

```text
User
↓
メール作成
↓
Control値 → InputValues
↓
Input Validator
↓
Errorあり？
├─ Yes
│   ↓
│ Error一覧
│   ↓
│ UserFormでControl強調
│
└─ No
    ↓
Outlook Adapter
    ↓
生成用MailItem作成
    ↓
Value Formatter
    ↓
Subject Renderer
    ↓
Body Renderer + HTML Encode
    ↓
Unresolved Checker
    ↓
未置換あり？
├─ Yes → MailItem表示せずError
└─ No
    ↓
Subject / HTMLBody設定
    ↓
Display
    ↓
ツール責任範囲終了
```

---

## 26. VBA構成案

MVPでは、標準Moduleを中心とした軽量構成とする。

### 26.1 UI

```text
frmMailGenerator
modUiController
```

### 26.2 Application

```text
modMailApplication
modSyncApplication
```

### 26.3 Core Logic

```text
modTemplateScanner
modSyncEngine
modConfigurationValidator
modInputValidator
modValueFormatter
modSubjectRenderer
modBodyRenderer
modUnresolvedChecker
```

### 26.4 Infrastructure

```text
modVariableDefinitionData
modOptionMasterData
modSettingsData
modOutlookAdapter
```

### 26.5 Shared / State

```text
modInputState
modResult
```

必要に応じて、Result / Error情報のみ小規模Class化する。

### 26.6 設計上の注意

実装開始前に上記Module数が処理量に対して過剰と判断した場合は、責務を崩さない範囲で近接Moduleを統合してよい。

例：

```text
modSubjectRenderer
+
modBodyRenderer
→ modRenderer
```

ただし、Value FormatterとOutlook Adapterは責務が異なるため分離を維持する。

---

## 27. Design Decision一覧

| ID | Decision | 採用 |
|---|---|---|
| D01 | 全体アーキテクチャ | 軽量レイヤード |
| D02 | 設定完了状態 | 現在値から都度導出 |
| D03 | OptionMaster | OptionGroup / Value / SortOrder / Active |
| D04 | Settings | Key / Value |
| D05 | Excel Access | 薄いData Access層 |
| D06 | MailItem | Scan用 / 生成用を分離 |
| D07 | Scanner | Candidate Scan → Validation |
| D08 | Sync | Dictionary Set比較 |
| D09 | Configuration Validator | 集約 + 内部分割 |
| D10 | UserForm | 固定Form + 動的Input Controls |
| D11 | Binding | Tag + InputValues Dictionary |
| D12 | Input Validation | Validator分離、表示はUI |
| D13 | Render | Formatterと出力先処理を分離 |
| D14 | Outlook | 軽量Adapter |
| D15 | Error | Result返却 + UI表示 |

---

## 28. Requirements Traceability

| Requirements領域 | 主Designコンポーネント |
|---|---|
| OFT参照 | Settings Data / Outlook Adapter |
| Variable記法 | Template Scanner |
| Case Insensitive | Scanner / Dictionary / Renderer |
| Template同期 | Sync Engine |
| New / Existing / Unused / Reactivated | Sync Engine |
| VariableDefinition | VariableDefinition Data |
| Required | Configuration Validator / Input Validator |
| Date | Input Validator / Value Formatter |
| Select | OptionMaster Data / Input Validator |
| UserForm | UserForm Generator |
| SortOrder | VariableDefinition Data / UserForm Generator |
| 入力保持 | Input State |
| Validation | Input Validator |
| Subject置換 | Subject Renderer |
| Body置換 | Body Renderer |
| HTML保護 | Body Renderer |
| 未置換チェック | Unresolved Checker |
| Outlook Display | Outlook Adapter |
| エラー通知 | Result Model / UI |

---

## 29. 実装時の確認事項

以下はRequirements変更を伴わないImplementation Detailとして、実装時に確定する。

- `Scripting.Dictionary` のEarly Binding / Late Binding
- `VBScript.RegExp` の生成方式
- Result / ErrorInfoをClassにするか軽量構造にするか
- UserFormの具体的な寸法・スクロール方式
- Descriptionの具体的表示方法
- Validation強調色
- HTML Encode関数
- Outlook COM参照解放の具体コード
- 同期結果画面の具体表示
- Unused確認UI
- エラーコード体系の採否
- Module統合の最終調整

---

## 30. 設計上のリスク

### RISK-DES-001 HTMLBody内のVariable表現

OFTのHTMLBody内部で `{{VariableName}}` がHTMLタグ等により分断された場合、単純な文字列検索・置換では検出できない可能性がある。

MVP実装時に、実際のOFTで以下を確認する。

- 通常入力した `{{VariableName}}` がHTMLBody内で連続文字列として保持されること
- 書式設定により変数文字列が分断されないこと

MVP Requirements v0.1.2では、Variable文字列途中がHTMLタグ等で分断されるケースをMVP保証対象外としている。Technical Spikeでは、通常入力したVariableが実OFTのHTMLBody内で連続文字列として保持され、現在のScanner / Renderer方式が通常利用ケースで成立することを確認する。

上記を超える新しい利用者向けテンプレート記述制約が必要になった場合は、Design内で決定せずRequirement Gapとして扱う。

### RISK-DES-002 Outlook COM

Outlook MailItemの生成・解放・Displayに関するCOMエラーをInfrastructure層で適切に捕捉する必要がある。

### RISK-DES-003 動的UserForm

変数数が増えた場合の縦方向レイアウト・スクロールが必要になる可能性がある。

MVPでは実使用テンプレートの変数数を基準に確認する。

---

## 31. MVP Design完了条件

本Design v0.1.1は、以下を満たした時点で基本設計完了とする。

- Requirements v0.1.2の主要要件に対応するコンポーネントが定義されている
- UI / Core / Excel / Outlookの責務境界が定義されている
- Template Scan / Sync / UserForm / Render / Outlook Displayの主要フローが定義されている
- Excelテーブル構造が定義されている
- Case Insensitive処理方針が定義されている
- Input State保持方式が定義されている
- Error伝播方針が定義されている
- Design Questions 15件が反映されている
- 新規Requirement Gapが残っていない

---

## 32. 次工程

MVP Design v0.1.1への修正後は、以下の順を推奨する。

```text
MVP Requirements v0.1.2
        ↓
MVP Design v0.1.1
        ↓
Design / Requirements 最終整合性レビュー
        ↓
Technical Spike A：OFT / HTMLBody
        ↓
MVP Test Specification v0.1
        ↓
Technical Spike B / C
        ↓
Implementation Plan v0.1
        ↓
VBA実装
```

実装前に、Acceptance CriteriaとDesignコンポーネントを対応付けたテストケースを作成する。

特に以下を優先する。

- 新規Variable
- Existing設定保持
- Unused化
- Reactivated
- Rename
- Case Insensitive
- Invalid Variable Syntax
- Required未設定
- SortOrder未設定 / 重複
- Date Validation / Format
- Select OptionSource
- OFT不存在
- Input保持 / クリア
- Subject / Body置換
- HTML Encode
- 未置換Variable
- Outlook Display成功 / 失敗
