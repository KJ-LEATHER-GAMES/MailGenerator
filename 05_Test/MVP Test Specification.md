# MVP Test Specification v0.1 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Test Specification |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1 |
| 文書種別 | MVPテスト仕様 |
| Requirements Baseline | `MVP Requirements v0.1.6 日本語版.md` |
| Design Baseline | `MVP Design v0.1.5 日本語版.md` |
| Technical Evidence | `Technical Spike A 実施仕様書 v0.2 日本語版_CLOSED.md` |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| 対象テンプレート | Outlook Template File（`.oft`） |
| 実施状態 | 未実施 |
| 作成日 | 2026-09-11 |

---

## 2. 目的

本書は、MVP Requirements v0.1.6およびMVP Design v0.1.5に定義されたRequirement / Acceptance Criteria / Design Ruleが、MVP実装上で成立していることを確認するためのテスト仕様を定義する。

本書では以下を明確化する。

1. 何をTestするか
2. どの入力・事前状態でTestするか
3. 何をもってPASSとするか
4. どのEvidenceを残すか
5. Requirement / Acceptance Criteria / DesignとのTraceability
6. Technical Spike AのFindingをどのRegression Testへ引き継ぐか

本書はTest Resultではない。

作成時点ではすべてのTest Caseを `NOT RUN` とする。

---

## 3. Baseline

本Test Specificationの入力Baselineは以下とする。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.5
        +
Technical Spike A v0.2 CLOSED
```

### 3.1 Requirements

利用者から見た振る舞い、MVP保証範囲、Acceptance Criteriaは `MVP Requirements v0.1.6` を正とする。

### 3.2 Design

内部責務、データ構造、処理Sequence、WordEditor方式等のDesign Ruleは `MVP Design v0.1.5` を正とする。

### 3.3 Technical Spike A

Technical Spike Aは以下のTechnical Decision / Evidenceを提供する。

```text
Body処理方式：
Route W：WordEditor

採用技術：
Inspector.WordEditor
Word Document
Range.Find
Range.Text
```

Technical Spike Aで確認済みであっても、本番MVP実装のPASSを代替しない。

WordEditor関連の主要項目はMVP実装に対してRegression Testとして再実施する。

---

## 4. Test方針

### 4.1 Traceability

最低限以下を追跡可能とする。

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

### 4.2 Test粒度

Acceptance CriteriaだけではCoverage不足となるため、以下の2種類を使用する。

#### Acceptance Test

AC-001〜AC-020の成立を直接確認する。

#### Supplementary Test

Acceptance Criteriaだけでは独立確認できない以下を補完する。

- Existing設定保持
- Reactivated
- Rename
- Sync metadata
- Current OFT再確認
- Current VariableDefinition / OptionMaster Validation
- Unresolved Variable一覧
- Error表示
- Technical Spike A Regression
- TF-A-002対策
- NFR / Design Risk

### 4.3 Testタイプ

| Test Type | 内容 |
|---|---|
| Configuration | Settings / VariableDefinition / OptionMaster整合性 |
| Functional | Sync / UI / Validation / Render等の機能 |
| Integration | Excel + OFT + Classic Outlook / WordEditor |
| Negative | 不正入力・不整合・OFT不存在等 |
| Regression | Technical Spike AのTechnical Decision再確認 |
| Manual Visual | UserForm / Outlook表示 / 書式維持 |
| Design Review | Runtimeで直接判定しにくいNFR / Architecture |

### 4.4 自動化方針

MVP Test SpecificationではTestの期待結果を固定する。

自動Test Frameworkの導入はMVP必須としない。

VBAで自動判定しやすい以下は可能な限り自動化候補とする。

- Scanner結果
- Sync前後テーブル比較
- Validation Result
- Subject結果
- BodyText上のVariable有無
- UnresolvedCheckResult
- Draft件数
- Inspector件数

以下はManual Evidenceを許可する。

- UserForm表示
- Error強調
- Outlook表示
- 書式維持
- 自動送信されないこと

---

## 5. Test Result Status

| Status | 意味 |
|---|---|
| NOT RUN | 未実施 |
| PASS | Expected Resultを満たした |
| FAIL | Expected Resultを満たさない |
| BLOCKED | 前提不足等により実施不能 |
| N/A | 対象外。理由記録必須 |

PASS / FAILだけでなく、実施不能と仕様対象外を区別する。

---

## 6. Evidence方針

各Test Caseで最低限以下を記録する。

| Evidence | 例 |
|---|---|
| 実行条件 | 使用OFT / Excel / Initial Table State |
| Input | 入力文字列 / User操作 |
| Actual Result | 実測値 |
| Excel Evidence | VariableDefinition / OptionMaster前後 |
| Scanner Evidence | Valid / Invalid / Location |
| UI Evidence | 画面メモまたはScreenshot |
| Outlook Evidence | Subject / Body / Display状態 |
| Lifecycle Evidence | Draft / Inspector件数 |
| Error Evidence | Error一覧 / Target / Message |
| Result | PASS / FAIL / BLOCKED / N/A |

Technical Spike Aで問題となったFalse Positiveを避けるため、

> 「0件だった」ことと「正しく検出できた」ことを別Evidenceとして扱う。

---

## 7. Test環境

実施前に記録する。

| 項目 | 実績記入欄 |
|---|---|
| OS | 後日確認 |
| Excel Version | 後日確認 |
| Excel 32bit / 64bit | 後日確認 |
| Classic Outlook Version | 後日確認 |
| Outlook 32bit / 64bit | 後日確認 |
| VBA実行ブック |  |
| Test用OFT保存場所 |  |
| 実施日 |  |
| 実施者 |  |

New Outlookは対象外。

---

# 8. 標準Test Data

## 8.1 Settings

```text
TemplatePath = Templates\MailTemplate.oft
```

---

## 8.2 Baseline OFT

### Subject

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

### Body

```text
関係者各位

対象機種：{{ModelName}}
開催日：{{GateDate}}
担当部署：{{Department}}
備考：{{Comment}}

■確認事項
・対象機種再掲：{{MODELNAME}}
・担当部署再掲：{{department}}

[表]
項目        内容
機種        {{ModelName}}
部署        {{Department}}
開催日      {{GateDate}}

よろしくお願いいたします。
```

BodyにはFR-RENDER-BODY-002の確認用として以下を含める。

- 改行
- 段落
- フォント変更
- 文字サイズ変更
- 太字
- 文字色
- 箇条書き
- 表

---

## 8.3 Baseline VariableDefinition

| VariableName | DisplayName | Type | Required | Description | OptionSource | SortOrder | Format | Status |
|---|---|---|---|---|---|---:|---|---|
| ModelName | 対象機種 | Text | True | 機種名を入力 |  | 10 |  | Active |
| GateDate | 開催日 | Date | True | 開催日を入力 |  | 20 | yyyy/mm/dd | Active |
| Department | 担当部署 | Select | True | 部署を選択 | Department | 30 |  | Active |
| Comment | 備考 | Text | False | 必要な場合のみ入力 |  | 40 |  | Active |

TemplateLocation / FirstDetectedAt / LastDetectedAtはSync Testで別途確認する。

---

## 8.4 Baseline OptionMaster

| OptionGroup | Value | SortOrder | Active |
|---|---|---:|---|
| Department | 設計部 | 10 | True |
| Department | 品質部 | 20 | True |
| Department | 生産部 | 30 | False |

---

## 8.5 Baseline Input

```text
ModelName  = ABC123
GateDate   = 2026/09/30
Department = 品質部
Comment    = 確認お願いします
```

---

## 8.6 特殊文字Input

```text
ModelName = A&B <TEST>
```

WordEditor方式ではHTML Encodeせず、意図した文字列として表示されることを確認する。

---

# 9. Test Case一覧

## 9.1 Template / Scan

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-TPL-001 | 相対パスOFT参照 | Integration | Mandatory |
| MTS-TPL-002 | Excel一式移動後の相対パス参照 | Integration | Mandatory |
| MTS-TPL-003 | OFT不存在Fail Fast | Negative | Mandatory |
| MTS-TPL-004 | OFT読み込み失敗通知 | Negative | Mandatory |
| MTS-SCAN-001 | Subject / Body Variable抽出 | Functional | Mandatory |
| MTS-SCAN-002 | Location Subject / Body / Both | Functional | Mandatory |
| MTS-SCAN-003 | Case Insensitive統合 | Functional | Mandatory |
| MTS-SCAN-004 | Invalid Candidate検出 | Negative | Mandatory |
| MTS-SCAN-005 | To / CC / BCCを抽出対象外とする | Functional | Mandatory |

## 9.2 Sync

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-SYNC-001 | 手動同期のみ | Functional | Mandatory |
| MTS-SYNC-002 | New追加 | Functional | Mandatory |
| MTS-SYNC-003 | Existing設定保持 | Functional | Mandatory |
| MTS-SYNC-004 | Unused化 | Functional | Mandatory |
| MTS-SYNC-005 | Reactivated | Functional | Mandatory |
| MTS-SYNC-006 | Rename = Old Unused + New | Functional | Mandatory |
| MTS-SYNC-007 | Case Insensitive既存照合 / 正式表記保持 | Functional | Mandatory |
| MTS-SYNC-008 | Sync結果通知 | Manual / Functional | Mandatory |
| MTS-SYNC-009 | Sync開始前OFT不存在 | Negative | Mandatory |
| MTS-SYNC-010 | Sync開始前Invalid Variable | Negative | Mandatory |
| MTS-SYNC-011 | Sync metadata更新 | Functional | Mandatory |
| MTS-SYNC-012 | Unused通常非表示 / 必要時確認 | Manual / Functional | Mandatory |

## 9.3 Configuration / UserForm

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-CFG-001 | 新規Variable設定未完了でUserForm停止 | Negative | Mandatory |
| MTS-CFG-002 | SortOrder未設定 | Negative | Mandatory |
| MTS-CFG-003 | SortOrder重複時の行順 | Functional | Mandatory |
| MTS-CFG-004 | Date Format不正 | Negative | Mandatory |
| MTS-CFG-005 | Select OptionSource未設定 | Negative | Mandatory |
| MTS-CFG-006 | Select Active Optionなし | Negative | Mandatory |
| MTS-UI-001 | Dynamic UserForm生成 | Manual / Functional | Mandatory |
| MTS-UI-002 | Type / Control対応 | Manual / Functional | Mandatory |
| MTS-UI-003 | DisplayName / Required / Description | Manual | Mandatory |
| MTS-UI-004 | Select選択専用 / Active Option順 | Manual / Functional | Mandatory |

## 9.4 Input / Validation

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-INPUT-001 | Workbookを閉じるまで入力保持 | Functional | Mandatory |
| MTS-INPUT-002 | 入力クリア | Functional | Mandatory |
| MTS-VAL-001 | Required=True未入力 | Negative | Mandatory |
| MTS-VAL-002 | Required=False空欄 Date / Select | Functional | Mandatory |
| MTS-VAL-003 | Date許容形式 | Functional | Mandatory |
| MTS-VAL-004 | Date不正値 / 2桁年 | Negative | Mandatory |
| MTS-VAL-005 | Select Current Active Option Validation | Negative | Mandatory |
| MTS-VAL-006 | 複数Error一括表示 | Manual / Functional | Mandatory |
| MTS-VAL-007 | Error Control強調 | Manual | Mandatory |
| MTS-VAL-008 | 再Validation時Error状態Reset | Manual / Functional | Mandatory |

## 9.5 Render / Unresolved

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-REN-001 | Subject全出現箇所置換 / Case Insensitive | Functional | Mandatory |
| MTS-REN-002 | Body全出現箇所置換 / Case Insensitive | Integration | Mandatory |
| MTS-REN-003 | Optional空欄を空文字列置換 | Functional | Mandatory |
| MTS-REN-004 | Date 6 Format | Functional | Mandatory |
| MTS-REN-005 | Body特殊文字 | Regression / Integration | Mandatory |
| MTS-REN-006 | Body基本書式8項目維持 | Manual / Regression | Mandatory |
| MTS-UNR-001 | 正常系未置換0件 | Functional | Mandatory |
| MTS-UNR-002 | 未置換1件以上でDisplay停止 | Negative | Mandatory |
| MTS-UNR-003 | 未置換Variable一覧 / Case統合 | Negative | Mandatory |
| MTS-UNR-004 | Scanner成立性とUnresolved 0件を独立判定 | Regression | Mandatory |

## 9.6 Mail / Safety / Error

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-MAIL-001 | 成功時Classic Outlook Display | Integration | Mandatory |
| MTS-MAIL-002 | 自動送信されない | Manual / Safety | Mandatory |
| MTS-MAIL-003 | Scan用MailItem保存なしClose | Regression | Mandatory |
| MTS-MAIL-004 | Error時生成用MailItem非表示 / 保存なしClose | Negative / Safety | Mandatory |
| MTS-SAFE-001 | UserForm表示後OFT削除 | Negative / Safety | Mandatory |
| MTS-SAFE-002 | UserForm表示後Invalid Variable追加 | Negative / Safety | Mandatory |
| MTS-SAFE-003 | UserForm表示後VariableDefinition変更 | Negative / Safety | Mandatory |
| MTS-SAFE-004 | UserForm表示後OptionMaster変更 | Negative / Safety | Mandatory |
| MTS-ERR-001 | 主要Errorが理解可能なMessageを返す | Manual | Mandatory |
| MTS-ERR-002 | Outlook / Word COM Error変換 | Negative | Mandatory |

## 9.7 NFR / Design

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-NFR-001 | Template固有処理を設定で変更可能 | Design / Functional | Mandatory |
| MTS-NFR-002 | Component責務分離 Review | Design Review | Mandatory |
| MTS-NFR-003 | 問題箇所がユーザーから観測可能 | Manual | Mandatory |
| MTS-NFR-004 | 不完全状態Fail Fast | Safety Summary | Mandatory |
| MTS-NFR-005 | UserFormのみでメール生成 | Manual E2E | Mandatory |
| MTS-NFR-006 | 将来型追加時の局所変更性Review | Design Review | Conditional |

---

# 10. 詳細Test Case

## MTS-TPL-001 相対パスOFT参照

**Traceability**

- FR-TPL-001
- AC-001
- Design §9.3

**Precondition**

- Excelと `Templates\MailTemplate.oft` が相対関係を満たす
- Settings.TemplatePathが正しい

**Steps**

1. Excelを起動する
2. Template依存処理を開始する
3. 解決したTemplatePathを記録する

**Expected**

- `ThisWorkbook.Path + TemplatePath` から対象OFTを特定できる
- Template読込に成功する

**Evidence**

- 解決パス
- 読込結果

---

## MTS-TPL-002 Excel一式移動後の相対パス参照

**Traceability**

- FR-TPL-001
- AC-001

**Steps**

1. Excel + Templatesフォルダを別フォルダへ一式コピーする
2. 相対関係を維持した状態でExcelを開く
3. Template依存処理を開始する

**Expected**

- Settingsを書き換えずOFTを参照できる

---

## MTS-TPL-003 OFT不存在Fail Fast

**Traceability**

- FR-TPL-002
- FR-SYNC-008
- FR-UI-CHECK-001 / 002
- FR-OUTLOOK-001
- AC-001
- NFR-004

**Steps**

1. Settingsの参照先OFTを存在しない状態にする
2. 手動同期を実行する
3. UserForm起動を試行する
4. メール生成を試行する
5. Settings / VariableDefinition / OptionMasterを確認する

**Expected**

- 手動同期：開始しない
- UserForm：起動しない
- メール生成：開始しない
- 原因と確認対象が通知される
- Settings / VariableDefinition / OptionMasterの確認・編集は可能

---

## MTS-TPL-004 OFT読み込み失敗通知

**Traceability**

- §25 エラー処理要件
- NFR-003 / 004
- Design §24

**Precondition**

OFTは存在するが、読込失敗を再現できる状態を用意する。

**Expected**

- Template / Outlook系Errorとして捕捉する
- VBA Runtime Errorをそのままユーザーへ表示しない
- 後続処理へ進まない

---

## MTS-SCAN-001 Subject / Body Variable抽出

**Traceability**

- FR-SCAN-001
- AC-002
- Design §14
- Technical Spike TSA-003 / 004

**Expected**

Baseline OFTから以下を検出する。

```text
ModelName
GateDate
Department
Comment
```

Subject / Bodyの双方から抽出できる。

---

## MTS-SCAN-002 Location Subject / Body / Both

**Traceability**

- FR-SCAN-002
- Design §14.5 / 14.6

**Expected**

Baseline OFTで少なくとも以下となる。

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

---

## MTS-SCAN-003 Case Insensitive統合

**Traceability**

- FR-VAR-003 / 004
- AC-002

**Input**

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

**Expected**

- VariableDefinition上は1変数
- 比較はCase Insensitive
- 既存VariableDefinitionの正式表記 `ModelName` を保持する

---

## MTS-SCAN-004 Invalid Candidate検出

**Traceability**

- FR-VAR-002 / 005
- FR-SCAN-003
- AC-003
- NFR-004

**Input**

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

**Expected**

- ValidVariablesへ入らない
- InvalidCandidatesとして全件検出する
- 手動同期 / UserForm / メール生成を停止可能なResultとなる

---

## MTS-SCAN-005 To / CC / BCC対象外

**Traceability**

- FR-SCAN-001

**Precondition**

To / CC / BCCへ `{{Recipient}}` 等を配置したTest用OFTを用意する。

**Expected**

- Subject / BodyだけがScanner対象
- To / CC / BCCのVariableは抽出対象としない

---

# 11. Sync Test詳細

## MTS-SYNC-001 手動同期のみ

**Traceability**

- FR-SYNC-001

**Expected**

- Excel起動、UserForm起動等でVariableDefinitionを自動変更しない
- ユーザーが同期実行した場合のみSync Engineが更新する

---

## MTS-SYNC-002 New追加

**Traceability**

- FR-SYNC-002
- FR-REQ-001
- AC-004 / 005
- Design §15.3

**Precondition**

OFTへ `{{GateOwner}}` を追加する。

**Expected**

新規行：

```text
VariableName   = GateOwner
Status         = Active
DisplayName    = 未設定
Type           = 未設定
Required       = 未設定
TemplateLocation = 現在Location
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

UserFormは設定完了まで起動不可。

---

## MTS-SYNC-003 Existing設定保持

**Traceability**

- FR-SYNC-003
- AC-004
- NFR-002

**Precondition**

既存Variableにユーザー設定を持たせる。

**Expected**

Sync後も以下を保持する。

- DisplayName
- Type
- Required
- Description
- OptionSource
- SortOrder
- Format
- FirstDetectedAt

更新：

- TemplateLocation
- LastDetectedAt

---

## MTS-SYNC-004 Unused化

**Traceability**

- FR-SYNC-004
- AC-004

**Steps**

1. Active VariableをOFTから削除
2. 手動同期

**Expected**

- VariableDefinition行は削除しない
- Status = Unused
- ユーザー設定保持
- TemplateLocation / FirstDetectedAt / LastDetectedAtは最終検出値保持

---

## MTS-SYNC-005 Reactivated

**Traceability**

- FR-SYNC-005

**Steps**

1. Unused VariableをOFTへ再追加
2. 手動同期

**Expected**

- Status = Active
- 既存設定再利用
- FirstDetectedAt保持
- TemplateLocation更新
- LastDetectedAt更新

---

## MTS-SYNC-006 Rename

**Traceability**

- FR-SYNC-006

**Input**

```text
PIC
↓
PersonInCharge
```

**Expected**

```text
PIC            = Unused
PersonInCharge = New
```

自動Rename推測しない。

---

## MTS-SYNC-007 Case Insensitive既存照合

**Traceability**

- FR-SYNC-001
- FR-VAR-004

**Precondition**

VariableDefinition：

```text
ModelName
```

OFT：

```text
{{MODELNAME}}
```

**Expected**

- Newを追加しない
- Existingとして扱う
- VariableDefinition上の正式表記 `ModelName` を保持する

---

## MTS-SYNC-008 Sync結果通知

**Traceability**

- FR-SYNC-007

**Expected**

少なくとも以下を区別して通知する。

- 新規
- 継続
- Unused化

ユーザーが差分内容を把握できる。

---

## MTS-SYNC-009 Sync開始前OFT不存在

**Traceability**

- FR-SYNC-008
- AC-001

**Expected**

Sync Engineへ進まない。

---

## MTS-SYNC-010 Sync開始前Invalid Variable

**Traceability**

- FR-SYNC-008
- FR-VAR-005
- AC-003

**Expected**

Invalid Candidateが存在する場合、VariableDefinitionを更新しない。

---

## MTS-SYNC-011 Sync metadata更新

**Traceability**

- VariableDefinition要件
- Design §7.4 / §15

**Expected**

New / Existing / Reactivated / Unusedについて、Design §7.4の表どおりに更新される。

同一Syncで使用するTimestampが共通である。

---

## MTS-SYNC-012 Unused通常非表示 / 必要時確認

**Traceability**

- FR-SYNC-004
- Design §7.5

**Expected**

- 通常設定対象：Activeのみ
- Unused確認操作：Unusedを含む全件確認可能

---

# 12. Configuration / UserForm Test詳細

## MTS-CFG-001 新規Variable設定未完了

**Traceability**

- FR-SYNC-002
- FR-UI-CHECK-001 / 002
- AC-005

**Expected**

DisplayName / Type / Required / SortOrder等が不足するActive Variableが存在する場合、UserFormを起動しない。

---

## MTS-CFG-002 SortOrder未設定

**Traceability**

- FR-UI-003
- AC-007

**Expected**

Configuration ErrorとなりUserFormを起動しない。

---

## MTS-CFG-003 SortOrder重複

**Traceability**

- FR-UI-003
- AC-007
- Design §16.4 / §17.3

**Precondition**

```text
ModelName  10
StageName  20
GateDate   20
OwnerName  30
```

VariableDefinition上ではStageNameがGateDateより上の行。

**Expected**

```text
ModelName
StageName
GateDate
OwnerName
```

重複自体はConfiguration Errorとしない。

---

## MTS-CFG-004 Date Format不正

**Traceability**

- FR-TYPE-DATE-004
- FR-UI-CHECK-001
- AC-010

**Input**

定義済み6形式以外を設定。

**Expected**

Configuration ErrorとなりUserFormを起動しない。

---

## MTS-CFG-005 Select OptionSource未設定

**Traceability**

- FR-OPT-002
- FR-UI-CHECK-001

**Expected**

Configuration ErrorとなりUserFormを起動しない。

---

## MTS-CFG-006 Select Active Optionなし

**Traceability**

- FR-OPT-002
- FR-UI-CHECK-001

**Precondition**

OptionSourceは存在するが、全Option `Active=False`。

**Expected**

Configuration ErrorとなりUserFormを起動しない。

---

## MTS-UI-001 Dynamic UserForm生成

**Traceability**

- FR-UI-001
- AC-006
- NFR-001

**Expected**

Activeかつ設定完了したVariableDefinitionから入力Controlを動的生成する。

テンプレート固有UserFormの個別実装を必要としない。

---

## MTS-UI-002 Type / Control対応

**Traceability**

- FR-UI-002
- FR-TYPE-TEXT-001

**Expected**

```text
Text   → TextBox / 1行
Date   → TextBox / 1行
Select → ComboBox
```

---

## MTS-UI-003 補助情報

**Traceability**

- FR-UI-004

**Expected**

各入力項目で以下を確認できる。

- DisplayName
- Required表示
- Description

---

## MTS-UI-004 Select選択専用

**Traceability**

- FR-TYPE-SELECT-001
- FR-OPT-001
- AC-011
- Design §17.2

**Expected**

- Active Optionのみ
- SortOrder順
- 自由入力不可
- Inactive Option「生産部」は表示しない

---

# 13. Input / Validation Test詳細

## MTS-INPUT-001 Workbookを閉じるまで入力保持

**Traceability**

- FR-INPUT-001
- AC-012
- Design §18.2 / 18.3

**Steps**

1. UserFormへ入力
2. UserFormを閉じる
3. 同一Workbook SessionでUserForm再表示
4. Workbookを閉じて再度開く

**Expected**

- Step 3：入力値復元
- Step 4：入力値を永続復元しない

---

## MTS-INPUT-002 入力クリア

**Traceability**

- FR-INPUT-002
- AC-013

**Expected**

InputValuesおよび画面Controlがクリアされる。

---

## MTS-VAL-001 Required=True未入力

**Traceability**

- FR-VAL-001
- AC-014

**Expected**

Required=Trueの空欄 / 未選択はError。

---

## MTS-VAL-002 Required=False空欄

**Traceability**

- FR-VAL-001

**Precondition**

Date / SelectをRequired=Falseにする。

**Expected**

空欄 / 未選択は正常。

Type Validationを行わない。

---

## MTS-VAL-003 Date許容形式

**Traceability**

- FR-TYPE-DATE-001 / 002
- AC-009

**Input**

```text
2026/09/08
2026/9/8
2026-09-08
2026-9-8
2028/2/29
```

**Expected**

すべて正常。

---

## MTS-VAL-004 Date不正値 / 2桁年

**Traceability**

- FR-TYPE-DATE-001 / 002

**Input**

```text
26/9/8
9/8
2026/2/29
2026/13/1
```

**Expected**

すべてValidation Error。

---

## MTS-VAL-005 Select Current Active Option Validation

**Traceability**

- FR-VAL-001
- NFR-004
- Design §19 / §25.3
- FCR-001

**Steps**

1. UserForm起動時にDepartment = 品質部を選択
2. UserForm表示中にOptionMasterの品質部を `Active=False`
3. メール作成を実行

**Expected**

- メール生成開始時にCurrent OptionMasterを再取得
- Input Validatorが品質部を無効値として検出
- Render / Displayへ進まない

---

## MTS-VAL-006 複数Error一括表示

**Traceability**

- FR-VAL-002
- AC-014

**Input**

複数Controlを同時にError状態にする。

**Expected**

最初の1件だけで停止せず、全Errorを一覧表示。

---

## MTS-VAL-007 Error Control強調

**Traceability**

- FR-VAL-003
- AC-015

**Expected**

ErrorのControlだけが視覚的に識別可能。

---

## MTS-VAL-008 再Validation時Reset

**Traceability**

- FR-VAL-004

**Steps**

1. Error状態を作る
2. 修正する
3. 再Validation

**Expected**

前回Error表示をResetし、現在Errorだけを反映する。

---

# 14. Render / Unresolved Test詳細

## MTS-REN-001 Subject置換

**Traceability**

- FR-VAR-003 / 004
- FR-RENDER-SUB-001
- AC-016

**Expected**

```text
【ABC123】ゲート審査 2026/09/30 / ABC123
```

ModelNameの大小文字違いを含む全出現箇所を置換。

---

## MTS-REN-002 Body置換

**Traceability**

- FR-VAR-003 / 004
- FR-RENDER-BODY-001
- AC-017
- Design D16

**Expected**

全Variableの全出現箇所が置換される。

Word `Range.Find / Range.Text` 方式で成立する。

---

## MTS-REN-003 Optional空欄

**Traceability**

- FR-VAL-001
- Design §21.1

**Input**

```text
Comment = 空欄
Required = False
```

**Expected**

`{{Comment}}` を空文字列へ置換し、未置換として残さない。

---

## MTS-REN-004 Date 6 Format

**Traceability**

- FR-TYPE-DATE-003 / 004
- AC-010

**Input**

同一日付を6 Formatで出力する。

**Expected**

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

定義どおり。

---

## MTS-REN-005 Body特殊文字

**Traceability**

- FR-RENDER-BODY-002
- Technical Spike TSA-006
- Design §22.3

**Input**

```text
A&B <TEST>
```

**Expected**

Outlook上でそのまま `A&B <TEST>` と表示。

Body構造を破壊しない。

---

## MTS-REN-006 Body基本書式8項目

**Traceability**

- FR-RENDER-BODY-002
- AC-017
- Technical Spike TSA-007

**Expected**

Variable置換部分以外について以下を維持。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

---

## MTS-UNR-001 正常系未置換0件

**Traceability**

- FR-UNRESOLVED-001
- AC-018

**Expected**

Render完了後、Valid Variable形式の残存0件。

---

## MTS-UNR-002 未置換ありでDisplay停止

**Traceability**

- FR-UNRESOLVED-001
- AC-018
- NFR-004

**Precondition**

意図的に `GateDate` をRender対象から外す等のTest Hookを使用する。

**Expected**

- `{{GateDate}}` を検出
- MailItemをDisplayしない
- 保存せずClose

---

## MTS-UNR-003 未置換Variable一覧

**Traceability**

- FR-UNRESOLVED-002
- Design §23

**Precondition**

同一Variableを大小文字違いで複数残す。

**Expected**

`Variables[]` はCase Insensitiveに重複統合され、ユーザーへ一覧表示される。

---

## MTS-UNR-004 Scanner成立性とUnresolved 0件を独立判定

**Traceability**

- Technical Spike TF-A-002
- Design §32

**Test A**

Render前ScanでExpected Variable一覧を検出できることを独立確認する。

**Test B**

Render後Unresolved 0件を独立確認する。

**PASS Rule**

A / Bの両方がPASSして初めてRender系正常判定とする。

`Unresolved=0` だけを理由にScanner成立をPASSとしない。

---

# 15. Mail / Safety / Error Test詳細

## MTS-MAIL-001 Classic Outlook Display

**Traceability**

- FR-OUTLOOK-001 / 002 / 003
- AC-019

**Expected**

全Check成功後だけClassic OutlookにMailItemをDisplayする。

---

## MTS-MAIL-002 自動送信防止

**Traceability**

- FR-OUTLOOK-002 / 003
- AC-020

**Expected**

ツール実行だけではSendされない。

Display後の送信はユーザー操作のみ。

---

## MTS-MAIL-003 Scan用MailItem Lifecycle

**Traceability**

- Design §12.1
- Technical Spike TSA-010
- RISK-DES-002

**Evidence**

実行前後のDraft件数 / Inspector件数。

**Expected**

- Displayしない
- 保存しない
- Draft増加なし
- Inspector残存なし

---

## MTS-MAIL-004 Error時生成MailItem Lifecycle

**Traceability**

- NFR-004
- Design §25.3

**Expected**

Configuration / Unresolved Error時：

- MailItemをDisplayしない
- 保存せずClose
- 不要Draftを残さない

---

## MTS-SAFE-001 UserForm表示後OFT削除

**Traceability**

- FR-TPL-002
- FR-OUTLOOK-001
- NFR-004
- Design §25.3

**Steps**

1. 正常状態でUserFormを表示
2. OFTを削除
3. Mail作成

**Expected**

Current OFT存在確認で停止。

Renderしない。

---

## MTS-SAFE-002 UserForm表示後Invalid Variable追加

**Traceability**

- FR-VAR-005
- NFR-004
- Design §25.3

**Steps**

1. 正常UserForm表示
2. OFTへ `{{Bad-Name}}` を追加
3. Mail作成

**Expected**

Current OFT再ScanでInvalid Candidate検出。

Render / Displayへ進まない。

---

## MTS-SAFE-003 UserForm表示後VariableDefinition変更

**Traceability**

- FR-VAL-001
- NFR-004
- FCR-001

**Example**

ModelNameをRequired=False→True等、現在Validation結果へ影響する変更を行う。

**Expected**

Mail生成時Current VariableDefinitionを使用してInput Validationする。

---

## MTS-SAFE-004 UserForm表示後OptionMaster変更

**Traceability**

- FR-VAL-001
- FCR-001

MTS-VAL-005と同じScenarioをSafety視点で確認する。

---

## MTS-ERR-001 主要Error Message

**Traceability**

- §25 エラー処理要件
- NFR-003
- Design §24

以下の代表Errorを確認する。

- OFT不存在
- Invalid Variable
- Configuration不足
- Input Validation
- Unresolved Variable
- Outlook Error

**Expected**

技術エラー文字列だけではなく、

- 何が問題か
- 何を確認すべきか

が理解できる。

---

## MTS-ERR-002 Outlook / Word COM Error変換

**Traceability**

- Design §24.5
- RISK-DES-002

**Expected**

Runtime Errorを捕捉し、OperationResult / ErrorInfoとしてUIへ返す。

---

# 16. NFR Test / Review

## MTS-NFR-001 標準化

**Traceability**

- NFR-001

**Method**

Baseline以外のVariable構成へOFT / VariableDefinitionを変更する。

**Expected**

テンプレート固有Variableを大量にVBAへハードコードせず、設定変更でUserForm / Render対象を変更できる。

---

## MTS-NFR-002 保守性

**Traceability**

- NFR-002

**Review**

以下の責務が設計どおり分離されていることをCode Reviewで確認する。

- Excel Data Access
- Outlook Adapter
- Scanner
- Sync
- Configuration Validator
- Input Validator
- Formatter
- Subject Renderer
- Unresolved Checker

---

## MTS-NFR-003 可観測性

**Traceability**

- NFR-003

**Expected**

Sync / Configuration / Validation / Unresolved / Outlook Errorについて、ユーザーが問題対象を特定できる。

---

## MTS-NFR-004 安全性

**Traceability**

- NFR-004

**PASS**

以下の個別TestがすべてPASS。

- MTS-TPL-003
- MTS-SCAN-004
- MTS-CFG-001〜006
- MTS-VAL-001 / 003〜008
- MTS-UNR-002 / 003
- MTS-SAFE-001〜004

---

## MTS-NFR-005 操作性

**Traceability**

- NFR-005

**E2E**

正常に設定済みの状態で、

```text
Excel
↓
UserForm
↓
入力
↓
Mail作成
↓
Outlook Display
```

まで、OFT本文をユーザーが直接編集せず完了できる。

---

## MTS-NFR-006 拡張性

**Traceability**

- NFR-006

**Method**

Design / Code Review。

将来型追加を実装するTestではない。

以下が局所化されていることを確認する。

- Type / Control mapping
- Validation
- Value Formatter
- Data Access
- Renderer責務

**Gate**

Conditional。

MVP実装完了をBlockingする定量性能Testとはしない。

---

# 17. Acceptance Criteria Traceability

| AC | Primary Test |
|---|---|
| AC-001 | MTS-TPL-001 / 002 / 003 |
| AC-002 | MTS-SCAN-001 / 003 |
| AC-003 | MTS-SCAN-004 / MTS-SYNC-010 |
| AC-004 | MTS-SYNC-002 / 003 / 004 / 007 |
| AC-005 | MTS-SYNC-002 / MTS-CFG-001 |
| AC-006 | MTS-UI-001 / 002 / 003 |
| AC-007 | MTS-CFG-002 / 003 |
| AC-008 | MTS-UI-002 |
| AC-009 | MTS-VAL-003 |
| AC-010 | MTS-CFG-004 / MTS-REN-004 |
| AC-011 | MTS-UI-004 |
| AC-012 | MTS-INPUT-001 |
| AC-013 | MTS-INPUT-002 |
| AC-014 | MTS-VAL-006 |
| AC-015 | MTS-VAL-007 / 008 |
| AC-016 | MTS-REN-001 |
| AC-017 | MTS-REN-002 / 005 / 006 |
| AC-018 | MTS-UNR-002 / 003 / 004 |
| AC-019 | MTS-MAIL-001 |
| AC-020 | MTS-MAIL-002 |

---

# 18. Functional Requirement Coverage

| Requirement | Test |
|---|---|
| FR-TPL-001 | MTS-TPL-001 / 002 |
| FR-TPL-002 | MTS-TPL-003 / MTS-SAFE-001 |
| FR-VAR-001 | MTS-SCAN-001 |
| FR-VAR-002 | MTS-SCAN-004 |
| FR-VAR-003 | MTS-SCAN-003 / MTS-REN-001 / 002 |
| FR-VAR-004 | MTS-SCAN-003 / MTS-SYNC-007 / MTS-REN-001 / 002 / MTS-UNR-003 |
| FR-VAR-005 | MTS-SCAN-004 / MTS-SYNC-010 / MTS-SAFE-002 |
| FR-SCAN-001 | MTS-SCAN-001 / 005 |
| FR-SCAN-002 | MTS-SCAN-002 |
| FR-SCAN-003 | MTS-SCAN-004 |
| FR-SYNC-001 | MTS-SYNC-001 / 007 |
| FR-SYNC-002 | MTS-SYNC-002 |
| FR-SYNC-003 | MTS-SYNC-003 |
| FR-SYNC-004 | MTS-SYNC-004 / 012 |
| FR-SYNC-005 | MTS-SYNC-005 |
| FR-SYNC-006 | MTS-SYNC-006 |
| FR-SYNC-007 | MTS-SYNC-008 |
| FR-SYNC-008 | MTS-SYNC-009 / 010 |
| FR-REQ-001 | MTS-SYNC-002 / MTS-CFG-001 |
| FR-TYPE-TEXT-001 | MTS-UI-002 |
| FR-TYPE-DATE-001 | MTS-VAL-003 / 004 |
| FR-TYPE-DATE-002 | MTS-VAL-003 / 004 |
| FR-TYPE-DATE-003 | MTS-REN-004 |
| FR-TYPE-DATE-004 | MTS-CFG-004 / MTS-REN-004 |
| FR-TYPE-SELECT-001 | MTS-UI-004 |
| FR-OPT-001 | MTS-UI-004 |
| FR-OPT-002 | MTS-CFG-005 / 006 |
| FR-UI-001 | MTS-UI-001 |
| FR-UI-002 | MTS-UI-002 |
| FR-UI-003 | MTS-CFG-002 / 003 |
| FR-UI-004 | MTS-UI-003 |
| FR-UI-CHECK-001 | MTS-CFG-001〜006 / MTS-TPL-003 / MTS-SCAN-004 |
| FR-UI-CHECK-002 | MTS-CFG-001〜006 |
| FR-INPUT-001 | MTS-INPUT-001 |
| FR-INPUT-002 | MTS-INPUT-002 |
| FR-VAL-001 | MTS-VAL-001〜005 / MTS-SAFE-003 / 004 |
| FR-VAL-002 | MTS-VAL-006 |
| FR-VAL-003 | MTS-VAL-007 |
| FR-VAL-004 | MTS-VAL-008 |
| FR-RENDER-SUB-001 | MTS-REN-001 |
| FR-RENDER-BODY-001 | MTS-REN-002 / 003 |
| FR-RENDER-BODY-002 | MTS-REN-005 / 006 |
| FR-UNRESOLVED-001 | MTS-UNR-001 / 002 / 004 |
| FR-UNRESOLVED-002 | MTS-UNR-003 |
| FR-OUTLOOK-001 | MTS-TPL-003 / MTS-MAIL-001 / MTS-SAFE-001 |
| FR-OUTLOOK-002 | MTS-MAIL-001 / 002 |
| FR-OUTLOOK-003 | MTS-MAIL-002 |

**Coverage：47 / 47 FR**

---

# 19. NFR Coverage

| NFR | Test / Review |
|---|---|
| NFR-001 標準化 | MTS-NFR-001 |
| NFR-002 保守性 | MTS-SYNC-003 + MTS-NFR-002 |
| NFR-003 可観測性 | MTS-SYNC-008 / MTS-VAL-006 / MTS-UNR-003 / MTS-ERR-001 |
| NFR-004 安全性 | MTS-NFR-004 |
| NFR-005 操作性 | MTS-NFR-005 |
| NFR-006 拡張性 | MTS-NFR-006 |

**Coverage：6 / 6 NFR**

---

# 20. Technical Spike A Regression Traceability

| Spike Evidence | MVP Test |
|---|---|
| TSA-001 OFT読込 | MTS-TPL-001 |
| TSA-002 WordEditor Access | MTS-MAIL-003 / MTS-REN-002 |
| TSA-003 Variable検出 | MTS-SCAN-001 / MTS-UNR-004 |
| TSA-004 Scanner / Case Insensitive | MTS-SCAN-003 |
| TSA-005 Body置換 | MTS-REN-002 |
| TSA-006 特殊文字 | MTS-REN-005 |
| TSA-007 基本書式 | MTS-REN-006 |
| TSA-008 Unresolved Check | MTS-UNR-001〜004 |
| TSA-009 Display | MTS-MAIL-001 |
| TSA-010 Lifecycle | MTS-MAIL-003 / 004 |
| TF-A-001 HTMLBodyタグ分断 | Route Hを実装しないこと + MTS-SCAN-001 / MTS-REN-002 |
| TF-A-002 False Positive | MTS-UNR-004 |

TSA-011はTechnical Spike AでN/AとしてClose済みであり、MVP Mandatory Testへ昇格しない。

---

# 21. Test実施順序

推奨順序：

```text
Phase 1
Excel Data / Scanner / Sync
        ↓
Phase 2
Configuration / UserForm
        ↓
Phase 3
Input / Validation
        ↓
Phase 4
Render / Unresolved
        ↓
Phase 5
Outlook Lifecycle / Safety
        ↓
Phase 6
E2E / NFR Review
```

理由：

下流のMail / Render Testが失敗した場合に、上流設定やScanner不良と切り分けやすくするため。

---

# 22. Entry Criteria

Test実施開始条件：

- MVP Requirements v0.1.6がBaseline
- MVP Design v0.1.5がBaseline
- Technical Spike A v0.2 CLOSED
- 実装対象Versionを識別可能
- Test用Excel / OFTを準備済み
- Classic Outlook環境が利用可能
- Baseline Test Dataを再現可能

---

# 23. Exit Criteria

MVP Test完了条件：

1. Mandatory Testをすべて実施済み
2. AC-001〜020がすべてPASS
3. 47 FRのCoverageがすべてPASSまたは正当なN/A
4. NFR-001〜005がPASS
5. NFR-006はDesign Review結果を記録
6. High / Blocking Failureが0件
7. 未解決Variable防止、安全性TestがPASS
8. Technical Spike A Regression項目がPASS
9. Test Evidenceを保存済み
10. FAILが存在する場合、MVP Release可否判断を記録済み

---

# 24. Test Result記録テンプレート

各Test Case実施時は以下を記録する。

```markdown
### MTS-XXX-999 Test Name

- Result:
  - [ ] NOT RUN
  - [ ] PASS
  - [ ] FAIL
  - [ ] BLOCKED
  - [ ] N/A
- 実施日:
- 実施者:
- 対象Build:
- 使用OFT:
- Initial State:
- Input:
- Actual Result:
- Evidence:
- Finding:
- Requirement Impact:
- Design Impact:
- Retest:
```

---

# 25. Finding分類

TestでExpectedと異なる結果が出た場合は以下へ分類する。

| 分類 | 意味 |
|---|---|
| Implementation Defect | Requirements / Designどおり実装されていない |
| Test Defect | Test手順 / Expected / Dataが不正 |
| Design Gap | Requirementは明確だがDesign不足 |
| Requirement Gap | 利用者から見た新しい判断が必要 |
| Environment Issue | Test環境固有 |
| Technical Risk | 技術方式に追加Evidenceが必要 |
| Documentation Issue | 文書参照・記述不整合 |

TestでRequirement Gapが出た場合、その場でTest側だけのExpectedへ変更しない。

Requirementsへ戻して判断する。

---

# 26. MVP Test Gate

## PASS

以下をすべて満たす。

- Mandatory Test実施済み
- AC-001〜020 PASS
- Blocking Failureなし
- Safety Test PASS
- Technical Spike A Regression PASS
- Requirement / Design Gap未解決なし

## CONDITIONAL PASS

- Mandatory Requirementは満たす
- Scope外またはNon-BlockingのIssueのみ残存
- Issueと対応方針を明示済み

## FAIL

以下のいずれか。

- ACを満たせない
- 不完全なメールをDisplayできてしまう
- Invalid Variable / Configuration / Input / UnresolvedをFail Fastできない
- WordEditor Body RenderがRequirements保証範囲で成立しない
- 自動送信が発生する
- Blocking Requirement / Design Gapが未解決

---

# 27. 次工程

```text
MVP Test Specification v0.1
        ↓
Test Specificationレビュー
        ↓
Technical Spike B / C 要否確認
        ↓
Implementation Plan v0.1
        ↓
VBA実装
        ↓
MVP Test実施
        ↓
Test Result / Finding
        ↓
MVP判定
```

Technical Spike B / Cの具体内容は、既存計画またはImplementation Plan作成時に確認する。

本Test Specification v0.1の作成によって、新しいRequirement / Design Decisionは追加しない。
