# MVP Design v0.1.8 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Design |
| Document ID | DOC-MVP-DES |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1.8 |
| 文書種別 | MVP基本設計 |
| 上位文書 | 定型メール作成ツール 企画書 v0.1 |
| 要件文書 | DOC-MVP-REQ |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| メールテンプレート | Outlook Template File（`.oft`） |
| MVP構成 | 1 Excelファイル = 1 OFTテンプレート |
| 設計方針 | 軽量な責務分離 / MVP最小負荷 / 過剰設計回避 |

---

### v0.1.8 更新概要

DF-P1-001およびTV-P1-001の検証結果を反映し、OneDrive Web URL環境におけるWorkbook Relative Path Resolution方式を更新した。

1. `ThisWorkbook.Path` がWindows Local Pathの場合は従来方式を維持
2. `https://d.docs.live.net/<CID>/...` の場合はOneDrive Local Rootへ解決
3. OneDrive Root候補を環境変数から取得
4. 実在するLocal Workbook Directoryを使用してRootを一意に特定
5. `modSettingsData.ResolveWorkbookRelativePath` の責務を明確化
6. OFTを利用する主要シーケンスへPath Resolutionを明示
7. Design Decision D17 `Workbook Relative Path Resolution` を追加

利用者から見た機能・操作・設定方式の変更はない。

**Change Type：Semantic Design Change**  
**Requirement Impact：None**  
**Test Specification Impact：Needs Review**

---

### v0.1.7 更新概要

v0.1.7では、Migration QAで確認したActiveなTechnical Evidence参照をDocument IDベースへ統一した。

1. D16 Body処理方式の `Technical Spike A v0.2` 参照を `DOC-TS-A` へ変更
2. RISK-DES-001の `Technical Spike A v0.2` 参照を `DOC-TS-A` へ変更
3. 過去の改訂履歴に含まれるVersion固定参照はHistorical Recordとして維持

Design Decision、Route W、Architecture、Data Model、Validation Rule、Risk判定の意味には変更を加えていない。

**Change Type：Editorial / Governance Correction**  
**Semantic Change：None**

---

### v0.1.6 更新概要

`AI協働開発 文書管理・Baseline運用ルール v0.1` および `Baseline 4文書 文書管理ルール移行 Migration Patch v0.1` を適用し、文書管理上のEditorial / Governance Migrationを実施した。

1. 固定Document ID `DOC-MVP-DES` を付与
2. ActiveなRequirements参照をVersion固定参照から `DOC-MVP-REQ` 参照へ変更
3. §31の自己Version固定表現およびRequirements Version固定表現をDocument IDベースへ変更
4. §32「次工程」を削除し、進捗・Next Action・後続工程管理をProject Control / Context Handoff側へ分離

本変更は文書管理方式の移行のみを目的とするEditorial / Governance Changeであり、Design Decision、Architecture、Component Responsibility、Data Model、Validation Rule、Route W：WordEditor Technical Decision、およびRequirement Traceabilityの意味は変更していない。

---

### v0.1.5 更新概要

`MVP Requirements v0.1.6` × `MVP Design v0.1.4` × `Technical Spike A v0.2 CLOSED` の最終整合性再確認で残ったFCR-001 / FCR-002を反映した。

1. メール生成時のInput Validatorが、生成時点のCurrent VariableDefinition / OptionMasterを使用することを明示
2. Mail生成シーケンスでVariableDefinition / OptionMaster取得をInput Validation前へ移動
3. Input Stateの保持期間表現を「Workbookを閉じるまで」へ統一

本変更は既存RequirementをDesignへ正確に反映するための局所修正であり、新規Requirement Gapおよび追加Technical Spikeは発生していない。

---

### v0.1.4 更新概要

`MVP Requirements v0.1.6` を上位Baselineとし、`MVP Requirements v0.1.5` × `MVP Design v0.1.3` × `Technical Spike A v0.2 CLOSED` の最終整合性レビューで確認したDesign completeness / clarification事項を反映した。

主な変更は以下である。

1. メール生成直前にCurrent OFTを再Scanし、Configuration Validatorを再実行するFail Fast経路を追加
2. Unresolved Checkerが未置換Variable一覧を返す `UnresolvedCheckResult` を明示
3. Select型ComboBoxを選択専用とし、自由入力不可をDesignへ明示
4. `TemplateLocation` / `FirstDetectedAt` / `LastDetectedAt` のSync更新規則を明示
5. Unused Variableの通常非表示 / 必要時確認方針を明示
6. InputValuesをWorkbook Session中のみ保持し、永続保存しないことを明示
7. Requirements参照を `MVP Requirements v0.1.6` へ更新
8. Technical Spike Aの `TF-A-002` をMVP Test Specificationへの引継ぎ事項として明示

これらは既存RequirementをDesignへ完全に落とし込むための補完であり、新しい利用者向けRequirement Gapは発生していない。

---

### v0.1.3 更新概要

Technical Spike A v0.2の比較検証結果を反映し、MVPのBody処理方式をRoute H：HTMLBodyからRoute W：WordEditorへ変更した。

主な変更は以下である。

1. `Inspector.WordEditor` / Word Document / Rangeを利用するBody処理方式を採用
2. WordEditor / Word Object ModelへのアクセスをOutlook Adapterへ集約
3. Template Scanner / Unresolved CheckerのBody入力をHTMLBodyから表示文字列ベースのBodyTextへ変更
4. HTMLBody直接置換、HTML Encode、および独立Body Rendererを廃止
5. Word `Range.Find` + `Range.Text` によるCase Insensitiveな全出現箇所置換を採用
6. MailItem / Inspector / WordEditorを含むScan・Mail生成Lifecycleを更新
7. Technical Spike Aで実発生したRISK-DES-001をCLOSEDとし、Evidenceを記録
8. Requirements参照をMVP Requirements v0.1.5へ更新
9. 次工程をRequirements / Design / Technical Spike A整合性レビュー → MVP Test Specification v0.1へ更新

本変更は内部技術方式の変更であり、新しい利用者向けRequirement Gapは発生していない。

---

### v0.1.2 更新概要

MVP Requirements v0.1.2 × MVP Design v0.1.1 の最終整合性レビューで残ったDesign側の2件を局所修正し、MVP Requirements v0.1.3との文書参照を更新した。新しいDesign Decisionは追加していない。

1. `Required=False` かつ空欄 / 未選択の入力値はValue Formatterで空文字列 `""` とし、RendererがVariableを空文字列へ置換する規則を明示
2. 手動同期およびUserForm起動シーケンスで、OFT不存在時にError Resultを返して後続処理を停止するFail Fast分岐を明示

---

### v0.1.1 更新概要

MVP Requirements v0.1.1 × MVP Design v0.1 の正式整合性レビュー結果、およびRequirements v0.1.2で確定したRequirement Gapを反映した。

1. UserForm起動前にOFTを再取得・再Scanし、その `TemplateScanResult` をConfiguration Validatorへ渡す処理経路を明示
2. VariableName Syntaxの判定責務をTemplate Scannerへ一本化し、Configuration ValidatorはScan結果を評価する責務へ整理
3. `Required=False` の空欄 / 未選択を有効とし、値が存在する場合のみType ValidationするルールをInput Validatorへ反映
4. Body置換時に維持する代表的な基本書式とMVP保証対象外をRequirements v0.1.2に合わせて明示

## 2. 文書目的

本書は、`DOC-MVP-REQ` を満たすためのMVP基本設計を定義する。

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

機能単位で責務を分離し、UI、Excel、Outlook / WordEditor、Validation、Renderingの依存を局所化する。

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
│ - Subject Renderer                 │
│ - Unresolved Checker               │
└────────────────┬───────────────────┘
                 │
                 ▼
┌────────────────────────────────────┐
│ Infrastructure                     │
│ - Excel Data Access                │
│ - Outlook Adapter                  │
│   - MailItem / Inspector           │
│   - WordEditor / Word Document     │
│   - Word Range Body Rendering      │
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

Core LogicからExcelセル、Outlook Object Model、Word Object Modelを直接操作しない。

MailItem / Inspector / WordEditor / Word Document / Word Rangeへの依存はInfrastructureのOutlook Adapterへ集約する。

Template ScannerおよびUnresolved CheckerがBodyを評価する場合は、Outlook AdapterがWord Documentから取得した表示文字列ベースのBodyTextを入力として使用する。

## 5. コンポーネント責務

| コンポーネント | 主責務 |
|---|---|
| Application Controller | 同期・メール作成の処理順序を制御 |
| VariableDefinition Data Access | VariableDefinitionテーブルの読み書き |
| OptionMaster Data Access | OptionMasterテーブルの読み取り |
| Settings Data Access | Settingsテーブルの読み取り |
| Outlook Adapter | OFT読込、MailItem生成、Subject取得・設定、Inspector / WordEditor取得、BodyText取得、Word RangeによるBody変数置換、Display、保存なしClose |
| Template Scanner | Subject / BodyTextからの `{{...}}` 候補抽出、VariableName妥当性判定、出現位置統合 |
| Sync Engine | Template / VariableDefinitionの差分判定 |
| Configuration Validator | 設定整合性の一元チェック |
| UserForm Generator | VariableDefinitionに基づく入力Control生成 |
| Input State | Workbookを閉じるまでの入力値保持 |
| Input Validator | Required / Date / Selectの入力妥当性判定 |
| Value Formatter | Type / Formatに基づくメール出力文字列化 |
| Subject Renderer | Subject変数置換 |
| Unresolved Checker | Render後のSubject / BodyTextから未置換変数を検出し、一覧Resultを生成 |
| Error / Result Model | 予見可能なエラー情報の受け渡し |

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


### 7.4 自動管理列の更新規則

`TemplateLocation`、`Status`、`FirstDetectedAt`、`LastDetectedAt` はユーザー設定値ではなく、Template Scan / Sync結果からシステムが更新する。

同期処理開始時に1つの `SyncTimestamp` を取得し、同一Sync内では共通して使用する。

| Sync状態 | TemplateLocation | Status | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|---|
| New | 現在のScan結果 | Active | SyncTimestamp | SyncTimestamp |
| Existing | 現在のScan結果へ更新 | Active維持 | 既存値保持 | SyncTimestamp |
| Reactivated | 現在のScan結果へ更新 | Activeへ更新 | 既存値保持 | SyncTimestamp |
| Unused化 | 最終検出Locationを保持 | Unusedへ更新 | 既存値保持 | 既存値保持 |
| 既にUnused | 既存値保持 | Unused維持 | 既存値保持 | 既存値保持 |

`LastDetectedAt` は「最後にTemplate上で存在を確認した時刻」であり、Unused化した時刻ではない。

### 7.5 Unused表示方針

通常の設定・処理対象は `Status = Active` のVariableとする。

Unused Variableは通常の設定表示対象から除外するが、確認操作ではActive / Unusedを含む全件を取得可能とする。

概念上のData Access利用は以下とする。

```text
通常表示
→ Active変数取得

Unused確認
→ 全変数取得
```

具体的なExcel Filter、表示切替Button等はImplementationで決定する。

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

OFTはWorkbook相対Pathで管理し、`TemplatePath`には以下のような相対Pathを保持する。

```text
Templates\MailTemplate.oft
```

絶対Pathは `ThisWorkbook.Path` の形式に応じて解決する。

#### Windows Local Path

`ThisWorkbook.Path` がWindows Local Pathの場合は、従来どおり以下で解決する。

```text
ThisWorkbook.Path
+
TemplatePath
```

#### OneDrive Web URL

`ThisWorkbook.Path` が以下の形式の場合、

```text
https://d.docs.live.net/<CID>/...
```

Web URLをOFT Pathとして直接使用しない。

以下の順でWindows Local Pathへ解決する。

```text
ThisWorkbook.Path
↓
<CID>より後ろの相対Pathを抽出
↓
OneDrive Local Root候補を取得
↓
Local Workbook Path候補を生成
↓
実在するWorkbook Directoryを確認
↓
Local Workbook Pathを一意に特定
↓
TemplatePathを結合
↓
Windows Local OFT Path
```

OneDrive Local Root候補は以下の環境変数から取得する。

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

空欄および同一Pathの重複候補は除外する。

候補判定は以下とする。

```text
実在候補 = 0
→ ConfigurationError

実在する異なる候補 = 1
→ 採用

実在する異なる候補 >= 2
→ ConfigurationError
```

ユーザー名またはOneDrive Rootの固定Pathはハードコードしない。

Path結合時はWindows PathとしてSeparatorを正規化する。

Path Resolutionの責務は利用可能な絶対Pathの導出までとし、対象OFTファイル自体の存在確認は後続処理の責務とする。

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
- 全変数取得（Unused確認用）
- VariableName検索
- 新規変数追加
- Status更新
- TemplateLocation更新
- FirstDetectedAt初期設定
- LastDetectedAt更新

`modOptionMasterData`

- OptionGroupごとのActive値取得
- SortOrder順取得

`modSettingsData`

- Keyによる設定値取得
- Workbook相対PathからWindows絶対Pathへの解決
- `d.docs.live.net`形式のOneDrive Web URLからLocal Workbook Pathへの解決

`ResolveWorkbookRelativePath` の公開Interfaceは維持する。

```vb
ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult
```

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
Outlook Adapter
↓
Inspector / WordEditor取得
↓
Subject / BodyText取得
↓
Template Scanner
↓
Scan用 MailItemを保存せず終了
↓
COM参照解放
```

`BodyText` は `Word.Document.Content.Text` 相当の表示文字列Snapshotとし、Word Document Object自体をTemplate Scannerへ渡さない。

### 12.2 Mail生成時

```text
OFT
↓
生成用 MailItem生成
↓
Outlook Adapter
↓
Inspector / WordEditor取得
↓
Subject / BodyText取得
↓
Template Scanner
↓
Configuration Validator
↓
Current Template / Configuration確認
↓
Value Format
↓
Subject Render / Subject設定
↓
Word Range Body Render
↓
Subject / BodyText再取得
↓
Unresolved Check
↓
Display
```

UserForm起動時のScan結果をメール生成時まで無条件に信用せず、生成用MailItemのCurrent OFT内容をRender前に再確認する。

### 12.3 設計原則

Scan用MailItemと生成用MailItemは使い回さない。

常に元OFTから新しいMailItemを生成し、処理間でMailItem状態を持ち越さない。

Inspector / WordEditorはOutlook Adapter内部で取得し、Core LogicへCOM Objectを公開しない。

Technical Spike Aでは、Display前のWordEditor取得、Scan後の保存なしClose、およびDraft / Inspector残存なしを確認済みである。

BodyのWord Range編集は生成用MailItemそのものへ反映されるため、HTMLBody方式のような「Body文字列を再設定する」工程は持たない。

## 13. Outlook Adapter設計

### 13.1 方針

Classic Outlook Object Modelおよび、OutlookのWordEditor経由で利用するWord Object Modelへの依存は軽量なOutlook Adapterへ集約する。

MVPではPort / Interfaceを設けず、新しいWordEditor専用Adapterも追加しない。

MailItem LifecycleとBodyのWord Range操作を既存Outlook Adapterへまとめる。

### 13.2 責務候補

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
DisplayMail()
CloseWithoutSave()
```

`ReadBodyText()` はOutlook Adapter内部でInspector / WordEditor / Word Documentを取得し、表示文字列ベースのBodyTextを返す。

`ReplaceBodyVariables()` はFormatted Valuesを受け取り、Word Document上で対象VariableをCase Insensitiveに検索し、全出現箇所を置換する。

Body置換の技術方式はTechnical Spike Aで成立した以下を採用する。

```text
Word Document
↓
Range.Find
↓
Found Range
↓
Range.Text = replacement
↓
次の出現箇所を検索
```

WordのReplaceAllはMVPの採用方式としない。

具体的なFunction / Sub名、Range更新ループ、COM参照解放コードはImplementation時に確定する。

### 13.3 禁止事項

以下のコンポーネントからOutlook Object Model / Word Object Modelを直接操作しない。

- Template Scanner
- Configuration Validator
- Input Validator
- Value Formatter
- Subject Renderer
- Unresolved Checker

Inspector / WordEditor / Word Document / Word RangeはOutlook Adapter内部に閉じ込める。

## 14. Template Scanner設計

### 14.1 2段階処理

```text
Subject / BodyText
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

BodyのCandidate ScanはHTMLBodyではなく、Outlook AdapterがWord Documentから取得したBodyTextを対象とする。

BodyTextは表示文字列ベースであり、HTMLタグを含む内部HTML表現をScanner入力としない。

Technical Spike Aでは、HTMLBody上でタグ分断されたVariableもWord Documentの表示文字列では連続して検出できることを確認済みである。

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

Template Scannerは、後続処理がOutlook Object ModelやWord Object Model、正規表現処理へ依存せず判定できるよう、Scan結果を軽量なデータとして返す。

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

Template ScannerはWord Document Objectを保持しない。

Scanner入力はSubject / BodyTextという文字列Snapshotとし、後続処理へOutlook / Word COM依存を伝播させない。

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

`TemplateLocation` にはTemplateScanResultの現在Locationを設定する。

`FirstDetectedAt` / `LastDetectedAt` には当該Syncの `SyncTimestamp` を設定する。

### 15.4 Existing

既存ユーザー設定を保持し、同期処理で上書きしない。

DisplayName / Type / Required / Description / OptionSource / SortOrder / Format等のユーザー設定は保持する。

`TemplateLocation` は現在のTemplateScanResultへ更新する。

`FirstDetectedAt` は保持し、`LastDetectedAt` は `SyncTimestamp` へ更新する。

VariableNameの表記は既存VariableDefinition側を正式表記として保持する。

### 15.5 Reactivated

StatusをActiveへ戻し、既存設定を再利用する。

`FirstDetectedAt` は保持する。

`TemplateLocation` は現在のTemplateScanResultへ更新し、`LastDetectedAt` は `SyncTimestamp` へ更新する。

### 15.6 Unused

StatusのみUnusedへ変更し、設定値は保持する。

`TemplateLocation` は最終検出時の値を保持する。

`FirstDetectedAt` / `LastDetectedAt` も保持し、Unused化時刻で `LastDetectedAt` を上書きしない。

既にUnusedのVariableも同様に管理情報を保持する。

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

Configuration Validator自身は、OFTを開く処理、Subject / BodyTextを取得する処理、Variable候補の抽出、VariableName SyntaxのRegex判定を行わない。

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

| Type | Control | 入力規則 |
|---|---|---|
| Text | TextBox | 1行入力 |
| Date | TextBox | 1行入力 |
| Select | ComboBox | OptionMasterの有効Optionからの選択のみ |

Text / Date用TextBoxは複数行入力を許可しない。

Select用ComboBoxは自由入力できない選択専用設定とする。

VBAでは `fmStyleDropDownList` 相当を使用する。

OptionはOptionMaster Data Accessが取得したActive OptionをSortOrder順に設定する。

具体的なControl Property設定コードはImplementationで確定する。

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

InputValuesはWorkbook Session中のメモリ上の状態とし、Excelシートや外部ファイルへ永続保存しない。

Workbookを閉じた時点で保持対象外となる。

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

Input Validatorは、メール生成時点でData Accessから取得したCurrent VariableDefinition / OptionMasterをValidation定義として使用する。

UserForm生成時に使用した過去のVariableDefinition / OptionMaster Snapshotを、メール生成時Validationの根拠として無条件に再利用しない。

```text
InputValues
+
Current VariableDefinition
+
Current OptionMaster
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

メール生成時のValidationでは、以下をCurrent Dataから判定する。

- Required：Current VariableDefinition.Required
- Type：Current VariableDefinition.Type
- Select有効値：Current OptionMasterのActive Option

Select型では、入力値がメール生成時点のCurrent Active Optionに存在しない場合はErrorとする。

Input Validator自身はExcel Tableを直接読み取らず、Application層がData Accessから取得したCurrent VariableDefinition / OptionMasterを入力として渡す。

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

`Required=False` かつRaw Inputが空欄 / 未選択の場合は、Date変換やSelect値変換を行わず、Formatted Valueとして空文字列 `""` を返す。

SubjectではSubject Renderer、BodyではOutlook AdapterのBody Renderingが、対象の `{{VariableName}}` をこの空文字列で置換する。

これにより、任意項目が未入力でも未置換Variableを残さず、Unresolved Checkerのエラー対象としない。

### 21.2 Type別

Text：入力文字列を出力値とする。

Date：Date値とVariableDefinition.FormatからFormatted Date Stringを生成する。

Select：選択されたValueを出力値とする。

Outlook / Word Object Modelへの反映処理はValue Formatterの責務に含めない。

Value Formatterは、Subject / Bodyへ共通して使用可能な表示用文字列の生成までを責務とする。

## 22. Render Engine設計

### 22.1 全体フロー

```text
InputValues
↓
Value Formatter
↓
Formatted Values
├────────────→ Subject Renderer
│                    ↓
│               Subject設定
│
└────────────→ Outlook Adapter
                     ↓
               WordEditor
                     ↓
               Word Document
                     ↓
          Range.Find / Range.Text
                     ↓
                 Body反映
```

### 22.2 Subject Renderer

Formatted ValueをSubject内の対象VariableへCase Insensitiveで全出現箇所置換する。

Subject RendererはPlain Text文字列としてSubjectを処理し、完成したSubjectをOutlook Adapter経由でMailItemへ設定する。

### 22.3 Body Rendering / WordEditor

Bodyの物理置換はOutlook AdapterがWordEditor / Word Document / Rangeを使用して実施する。

Formatted Valuesの各Variableについて、Word `Range.Find` をCase Insensitiveで実行し、Found Rangeへ `Range.Text = replacement` として値を設定する。

同一Variableが複数箇所に存在する場合は全出現箇所を置換する。

Body全体をPlain TextやHTML文字列として再構築・再設定しない。

これによりVariable置換部分以外のWord Document構造・書式を維持する。

Bodyへ設定するFormatted ValueにはHTML Encodeを適用しない。

Technical Spike Aでは `A&B <TEST>` をHTML EncodeせずRangeへ設定し、意図した表示文字列となることを確認済みである。

MVPでは、Requirements FR-RENDER-BODY-002に従い、代表的なOFTを用いて以下の基本書式がVariable置換後も維持されることを確認する。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

以下はFR-RENDER-BODY-002で定義したMVP書式維持保証対象外とする。

- 埋め込み画像
- 上記の代表的な基本書式を超える複雑な本文レイアウト・装飾
- 特殊なOutlook固有書式
- `{{VariableName}}` の文字列途中の一部分だけに異なる書式を設定したケース

## 23. 未置換変数チェック設計

### 23.1 独立チェック

未置換変数チェックはRender処理内部へ埋め込まず、Render後段の独立処理とする。

```text
Render
↓
Unresolved Checker
↓
UnresolvedCheckResult
├─ 0件 → Outlook Display
└─ 1件以上 → Error Result → UI一覧表示
```

### 23.2 対象

- Subject
- BodyText

### 23.3 判定

`{{VariableName}}` 形式の残存を検出し、1件でも存在すればメール生成を停止する。

BodyTextは、Body置換後にOutlook AdapterがWord Documentから再取得した表示文字列Snapshotを使用する。

Unresolved Checker自身はWord Document / Rangeを直接検索しない。

Template ScannerとUnresolved Checkerで同じ表示文字列モデルを使用することで、

```text
検出時：BodyText
置換後確認：BodyText
```

の一貫性を持たせる。

Unresolved Checkerは件数だけでなく、残存したVariableを後続UIへ渡す。

概念構造：

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

`Variables[]` はVariableNameをCase Insensitiveで重複統合する。

同一Variableが複数箇所、大文字・小文字違いで残存しても、ユーザー通知上は同一Variableとして扱う。

UIは `Variables[]` からFR-UNRESOLVED-002の未置換Variable一覧を表示する。

警告のみで処理継続せず、1件以上でFailとする。

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

`Message` は技術例外文字列をそのまま格納することを目的とせず、ユーザーが問題と次に確認すべき対象を理解できる内容とする。

複数Targetを通知する必要がある場合は、`Errors[]` または専用Resultの一覧情報をUIで集約表示する。

### 24.4 Resultモデル

```text
OperationResult
├─ Success
└─ Errors[]
```

VBA実装では、小規模なResult / ErrorInfoクラスまたは同等の軽量構造を用いる。

### 24.5 予期しない技術エラー

Outlook / Word COMエラーや想定外のVBA Runtime Errorは、`On Error` 等で捕捉し、`UnexpectedError` または `OutlookError` 等へ変換してUIへ返却する。

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
Workbook Relative Path解決
↓
Path Resolution Errorあり？
├─ Yes → Error Result → UI通知 → Stop
└─ No
    ↓
Local OFT Path取得
    ↓
OFT存在確認
    ↓
OFT存在？
├─ No → Error Result → UI通知 → Stop
└─ Yes
    ↓
Outlook Adapter
↓
Scan用MailItem生成
↓
Inspector / WordEditor取得
↓
Subject / BodyText取得
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
Workbook Relative Path解決
↓
Path Resolution Errorあり？
├─ Yes → Error Result → UI通知 → Stop
└─ No
    ↓
Local OFT Path取得
    ↓
OFT存在確認
    ↓
OFT存在？
├─ No → Error Result → UI通知 → Stop
└─ Yes
    ↓
Outlook Adapter
↓
Scan用MailItem生成
↓
Inspector / WordEditor取得
↓
Subject / BodyText取得
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

UserForm起動時のConfiguration Check結果をメール生成時まで無条件に信用しない。

メール生成では、生成開始時にCurrent VariableDefinition / OptionMasterをData Accessから取得してInput Validatorへ渡す。

その後、生成用MailItemのCurrent OFT内容を再Scanし、Render前にConfiguration Validatorを再実行する。

```text
User
↓
メール作成
↓
Control値 → InputValues
↓
VariableDefinition Data Access
+
OptionMaster Data Access
↓
Current VariableDefinition / OptionMaster取得
↓
Input Validator
↓
Input Errorあり？
├─ Yes
│   ↓
│ Error一覧 / Control強調
│
└─ No
    ↓
Settings Data Access
    ↓
TemplatePath取得
    ↓
Workbook Relative Path解決
    ↓
Path Resolution Errorあり？
├─ Yes → Error Result → UI通知 → Stop
└─ No
    ↓
Local OFT Path取得
    ↓
OFT存在確認
    ↓
OFT存在？
├─ No → Error Result → UI通知 → Stop
└─ Yes
    ↓
Outlook Adapter
    ↓
生成用MailItem作成
    ↓
Inspector / WordEditor取得
    ↓
Subject / BodyText取得
    ↓
Template Scanner
    ↓
TemplateScanResult
    ↓
Configuration Validator
    ↓
Current Template / Configuration Errorあり？
├─ Yes
│   ↓
│ 生成用MailItemを保存せずClose
│   ↓
│ UI通知 → Stop
│
└─ No
    ↓
Value Formatter
    ↓
Subject Renderer
    ↓
Subject設定
    ↓
Outlook Adapter
    ↓
Word Range Body Render
    ↓
Subject / BodyText再取得
    ↓
Unresolved Checker
    ↓
UnresolvedCheckResult
    ↓
未置換あり？
├─ Yes
│   ↓
│ 未置換Variable一覧 → Error Result / UI
│   ↓
│ MailItem表示せず保存せずClose
│
└─ No
    ↓
Display
    ↓
ツール責任範囲終了
```

メール生成時のInput Validatorは、生成開始時にData Accessから取得したCurrent VariableDefinition / OptionMasterを使用する。

このCurrent Dataは、同一メール生成処理内のConfiguration Validatorでも再利用する。

これにより、UserForm表示後に以下が変更された場合でもCurrent設定でFail Fastできる。

- Required
- Type
- SelectのActive Option
- VariableDefinition設定
- OptionMaster設定

Current Dataを保持するための新しい永続Snapshot / Version管理はMVPでは導入しない。

1回のメール生成処理内で取得したCurrent Dataを、その処理中のInput Validation / Configuration Validationで共有する。

目的は、UserForm表示後にOFTが変更された場合でも以下を保証することである。

- OFT不存在で生成を開始しない
- Invalid Variable Syntaxを含むメールを生成しない
- Template / VariableDefinition不整合状態でRenderしない

新しいValidatorは追加せず、UserForm起動時と同じTemplate Scanner / Configuration Validatorを再利用する。

BodyはWord Range編集によって生成用MailItemへ直接反映されるため、Render後にBody全文をMailItemへ再設定する処理は行わない。

未置換Variableが検出された場合は利用者へMailItemをDisplayせず、未置換Variable一覧を通知し、生成用MailItemを保存せず終了する。

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
modUnresolvedChecker
```

### 26.4 Infrastructure

```text
modVariableDefinitionData
modOptionMasterData
modSettingsData
modOutlookAdapter
```

新しいWordEditor専用ModuleはMVPでは追加しない。

### 26.5 Shared / State

```text
modInputState
modResult
```

必要に応じて、Result / Error情報のみ小規模Class化する。

### 26.6 設計上の注意

実装開始前に上記Module数が処理量に対して過剰と判断した場合は、責務を崩さない範囲で近接Moduleを統合してよい。

Outlook Adapter内部のWordEditor関連処理がImplementation時に過大化した場合のみ、責務を再評価する。

ただし、将来の複雑化を先取りしてMVP段階からWordEditor専用Class / Adapterを追加しない。

Value FormatterとOutlook Adapterは責務が異なるため分離を維持する。

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
| D13 | Render | Formatter / Subject文字列処理 / WordEditor Body反映を分離 |
| D14 | Outlook | 軽量AdapterへOutlook / Word Object Model依存を集約 |
| D15 | Error | Result返却 + UI表示 |
| D16 | Body処理方式 | Route W：Inspector.WordEditor + Word Range.Find / Range.Text |
| D17 | Workbook Relative Path Resolution | Local Pathは直接結合。`d.docs.live.net`形式ではOneDrive環境変数と実在DirectoryからLocal Rootを一意に解決 |

### D16 Body処理方式

DOC-TS-AのTechnical Decisionに基づき、Route W：WordEditorを採用する。

採用方式：

```text
MailItem
↓
Inspector.WordEditor
↓
Word Document
↓
Range.Find（Case Insensitive）
↓
Found Range
↓
Range.Text = replacement
```

採用理由：

- 通常OFTの全Variableを表示文字列として検出できた
- Case Insensitiveな全出現箇所置換が成立した
- HTML Encodeなしで特殊文字を安全に表示できた
- Requirements対象の基本書式を維持した
- Render後のUnresolved Checkが成立した
- Display前WordEditor取得によるDraft / Inspector残存を確認しなかった

不採用方式：

```text
Route H：HTMLBody直接処理
```

不採用理由：

通常作成したOFTでもVariable内部へHTMLタグが挿入され、Scanner / Renderer / Unresolved Checkerが安定して成立しなかったため。

## 28. Requirements Traceability

| Requirements領域 | 主Designコンポーネント |
|---|---|
| OFT参照 | Settings Data / Outlook Adapter |
| Variable記法 | Template Scanner |
| Case Insensitive | Scanner / Dictionary / Subject Renderer / Outlook Adapter |
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
| Subject置換 | Subject Renderer / Outlook Adapter |
| Body置換 | Outlook Adapter |
| Body書式維持 | Outlook Adapter / WordEditor Body Rendering |
| 未置換チェック | Unresolved Checker / Outlook Adapter（BodyText取得） |
| Outlook Display | Outlook Adapter |
| エラー通知 | Result Model / UI |
| VariableDefinition自動管理列 | Sync Engine / VariableDefinition Data |
| Unused通常非表示 / 確認 | VariableDefinition Data / UI |
| Select自由入力禁止 | UserForm Generator / OptionMaster Data |
| 未置換Variable一覧 | Unresolved Checker / Result Model / UI |
| メール生成直前Template整合性 | Template Scanner / Configuration Validator / Outlook Adapter |

## 29. 実装時の確認事項

以下はRequirements変更を伴わないImplementation Detailとして、実装時に確定する。

- `Scripting.Dictionary` のEarly Binding / Late Binding
- `VBScript.RegExp` の生成方式
- Result / ErrorInfoをClassにするか軽量構造にするか
- UserFormの具体的な寸法・スクロール方式
- Select用ComboBoxの具体的なProperty設定コード
- SyncTimestamp取得・更新処理の具体コード
- Descriptionの具体的表示方法
- Validation強調色
- Word Object Modelの参照設定 / Late Binding方針
- `Range.Find` の具体的な検索Range更新ループ
- Outlook / Word COM参照解放の具体コード
- WordEditor取得失敗時のError捕捉・Result変換
- 同期結果画面の具体表示
- Unused確認UI
- エラーコード体系の採否
- Module統合の最終調整

## 30. 設計上のリスク

### RISK-DES-001 HTMLBody内のVariable表現 — CLOSED

DOC-TS-Aで本リスクの実発生を確認した。

通常作成したOFTにおいて、Outlook画面上では連続して見えるVariableがHTMLBody内部では以下のように分断された。

```html
{{<span class=SpellE>ModelName</span>}}
{{<span class=SpellE>GateDate</span>}}
```

その結果、HTMLBody直接処理では以下が安定して成立しなかった。

- Template Scanner
- Body Renderer
- Unresolved Checker

Technical Finding `TF-A-001` としてDesign Findingに分類し、Route H：HTMLBodyを不採用とした。

MVP Body処理方式をRoute W：WordEditorへ変更したため、本リスクは採用Design上のActive RiskではなくCLOSEDとする。

新しい利用者向けTemplate制約は追加していない。

### RISK-DES-002 Outlook / Word COM

Outlook MailItemの生成・解放・Displayに加え、Inspector / WordEditor / Word Document / Range操作に関するCOMエラーをInfrastructure層で適切に捕捉する必要がある。

Technical Spike Aでは以下を確認済みである。

- Display前のWordEditor取得成功
- Scan用MailItemの保存なしClose成功
- Draft残存なし
- Inspector残存なし

したがってWordEditor採用自体をBlocking Riskとはしない。

Implementationでは、Object取得失敗、Range操作失敗、COM参照解放失敗をError / Result Modelへ変換する。

### RISK-DES-003 動的UserForm

変数数が増えた場合の縦方向レイアウト・スクロールが必要になる可能性がある。

MVPでは実使用テンプレートの変数数を基準に確認する。

## 31. MVP Design完了条件

本Designは、以下を満たした時点で基本設計完了とする。

- DOC-MVP-REQの主要要件に対応するコンポーネントが定義されている
- UI / Core / Excel / Outlook / WordEditorの責務境界が定義されている
- Template Scan / Sync / UserForm / Render / Outlook Displayの主要フローが定義されている
- Excelテーブル構造が定義されている
- Case Insensitive処理方針が定義されている
- Input State保持方式が定義されている
- Error伝播方針が定義されている
- Design Questions 15件が反映されている
- Technical Spike AのRoute W：WordEditor Technical Decisionが反映されている
- TF-A-001へのDesign対応が反映されている
- メール生成直前のCurrent OFT / Configuration再確認経路が定義されている
- Unresolved Variable一覧をUIへ渡す経路が定義されている
- Select自由入力禁止が定義されている
- VariableDefinition自動管理列のSync更新規則が定義されている
- Unused Variableの通常非表示 / 必要時確認方針が定義されている
- 新規Requirement Gapが残っていない
- メール生成時のInput ValidatorがCurrent VariableDefinition / OptionMasterを使用することが定義されている
- Input State保持期間が「Workbookを閉じるまで」で統一されている
