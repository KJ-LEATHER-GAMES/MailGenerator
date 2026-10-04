# MVP Test Specification v0.1.4 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Test Specification |
| Document ID | DOC-MVP-TESTSPEC |
| 対象プロジェクト | 定型メール作成ツール |
| バージョン | v0.1.4 |
| 文書状態 | Review / Candidate |
| 文書種別 | MVPテスト仕様 |
| Related Requirement | DOC-MVP-REQ |
| Related Design | DOC-MVP-DES |
| Technical Evidence | DOC-TS-A |
| 対象プラットフォーム | Microsoft Excel Desktop + VBA + Classic Outlook |
| 対象テンプレート | Outlook Template File（`.oft`） |
| 作成日 | 2026-09-11 |

### v0.1.4 更新概要

DF-P1-001およびDOC-MVP-DES v0.1.8のOneDrive Local Path Resolution対応について、
`MVP Test Specification DF-P1-001 Impact Review v0.1` の判定を反映した。

主な変更は以下である。

1. `MTS-TPL-001` のExpectedを、単純な `ThisWorkbook.Path + TemplatePath` からWorkbook Relative Path Resolutionの結果確認へ更新
2. `MTS-TPL-001` にWindows Local Path / OneDrive Web URLの正常系Execution Variantを追加
3. `MTS-TPL-001` にOneDrive Local Root候補0件 / Local Workbook Path候補0件 / 異なる候補複数件のResolution Failure Variantを追加
4. `MTS-TPL-001` のEvidenceへ `ThisWorkbook.Path`、`TemplatePath`、`Resolved Local Path` を追加
5. `MTS-ERR-001` の代表Error確認対象へWorkbook Relative Path / OneDrive Local Path Resolution Errorを追加
6. `MTS-ERR-001` にPath Resolution Error時の `ConfigurationError`、Message / Target、Fail Fast条件を明示
7. 新規Test IDは追加せず、Test Case総数69件を維持

Requirement / Acceptance Criteria、MVP Test Gate、既存Test ID、Traceabilityの基本構造は変更していない。

**Change Type：Semantic Test Definition Update**  
**Requirement Impact：None**  
**Test Case Count：69（変更なし）**

---

### v0.1.3 更新概要

v0.1.3では、Migration QAで確認した§7 Test環境の実績記入欄をTest Result責務へ分離した。

1. Test SpecificationではTest実行時に記録すべきEnvironment項目のみを定義
2. `後日確認` 等の実績値・進捗表現を削除
3. 実際のEnvironment値はTest Resultへ記録することを明示

Test Case、Expected Result、Test Gate、Traceabilityの意味には変更を加えていない。

**Change Type：Editorial / Governance Correction**  
**Semantic Change：None**

---

### v0.1.2 更新概要

`AI協働開発 文書管理・Baseline運用ルール v0.1` および `Baseline 4文書 文書管理ルール移行 Migration Patch v0.1` を適用し、文書管理上のEditorial / Governance Migrationを実施した。

主な変更は以下である。

1. 固定Document ID `DOC-MVP-TESTSPEC` を付与
2. ActiveなRequirements / Design / Technical Evidence参照をVersion固定参照からDocument ID参照へ変更
3. Test Specificationから実施状態および作成時点の `NOT RUN` 進捗記述を削除
4. §3をRelated Documents / Baseline Resolutionへ変更し、具体Versionの解決をCurrent Approved Baselineへ分離
5. `MTS-UNR-004` の削除済みDesign §32参照を、`DOC-TS-A / TF-A-002`、`DOC-MVP-DES §14`、`DOC-MVP-DES §23` へ修復
6. §22 Entry Criteriaを固定Version指定からCurrent Approved Baselineベースへ変更
7. §24 Test Result記録テンプレートへBaseline ID / Commit ID / Environmentの記録欄を追加
8. §27「次工程」を削除し、進捗・Next ActionをProject Control / Context Handoff側へ分離

本変更はEditorial / Governance Changeであり、Test Case、Expected Result、Test Gate、Requirement / Design / Technical DecisionおよびTraceabilityの意味は変更していない。

---

### v0.1.1 更新概要

`MVP Test Specification v0.1` とBaseline 3文書の整合性レビュー結果を反映した。

主な変更は以下である。

1. Mandatory Testは「実施済み」ではなく「すべてPASS」をMVP Test Gate条件とした
2. UserForm起動時の未登録Variable / 削除済みActive Variableを独立Testとして追加した
3. Invalid Variable Syntaxについて、処理停止だけでなく不正記述をユーザーが確認できることを明示した
4. Date入力をValidation後に日付値として扱い、入力表記を直接引き継がず再FormatするTestを明確化した
5. Optional空欄VariableのSubject / Body双方での空文字列置換を確認対象とした
6. Select OptionがOptionMaster管理であることを直接確認するEvidenceを追加した
7. RISK-DES-003に対応し、実使用Variable数でのUserForm利用可能性を確認するTestを追加した
8. NFR-006をMandatory Design Reviewとした
9. 重複していたMTS-SAFE-004をMTS-VAL-005へ統合した
10. MTS-NFR-004を独立実行TestではなくSafety Summary Gateへ再分類した
11. Date 6 FormatのExpectedを具体値で定義した
12. 1回の実行Evidenceを複数Test Caseへ再利用できるルールを明示した

利用者向けRequirement、Design Decision、Technical Decisionは変更していない。

---

## 2. 目的

本書は、DOC-MVP-REQおよびDOC-MVP-DESに定義されたRequirement / Acceptance Criteria / Design Ruleが、MVP実装上で成立していることを確認するためのテスト仕様を定義する。

本書では以下を明確化する。

1. 何をTestするか
2. どの入力・事前状態でTestするか
3. 何をもってPASSとするか
4. どのEvidenceを残すか
5. Requirement / Acceptance Criteria / DesignとのTraceability
6. Technical Spike AのFindingをどのRegression Testへ引き継ぐか

本書はTest Resultではない。


---

## 3. Related Documents / Baseline Resolution

本Test Specificationの論理参照先は以下とする。

- DOC-MVP-REQ
- DOC-MVP-DES
- DOC-TS-A

Test実行時に適用する具体的なVersion組合せは、Current Approved Baselineで解決する。

実際にTestしたBaseline IDはTest Resultへ記録する。

### 3.1 Requirements

Requirement / Acceptance CriteriaのSource of TruthはDOC-MVP-REQとする。

### 3.2 Design

Design RuleのSource of TruthはDOC-MVP-DESとする。

### 3.3 Technical Spike A

DOC-TS-Aは以下のTechnical Decision / Evidenceを提供する。

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

Requirement Coverageは以下の2段階で扱う。

```text
Traceability Mapping Coverage
= Requirement IDが1件以上のTest Caseへ紐付いていること

Condition Coverage
= Requirement本文に含まれる必要条件がTest手順 / Expectedへ具体化されていること
```

§18の `47 / 47 FR` はTraceability Mapping Coverageを表す。

MVP Test PASS判定では、IDの紐付けだけでなく、各Mandatory TestのExpected ResultがPASSしていることを必要とする。

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

### 6.1 Evidence再利用

1回のTest実行が複数のRequirement / Test Caseを同時に検証する場合、同一Evidenceを複数Test Caseから参照してよい。

ただし以下を満たすこと。

- 各Test IDごとのExpected Resultを個別に判定できる
- Evidenceの参照先を記録する
- 1つのTest CaseがFAILしたことを、同じEvidenceを参照する別Test Caseへ自動的に波及させない
- Test目的の異なるCaseを単に1件として統合しない

例：

```text
MTS-TPL-004実行Evidence
→ MTS-ERR-001のOFT読込Error確認にも参照可能

MTS-UNR-002実行Evidence
→ MTS-MAIL-004のError時Lifecycle確認にも参照可能
```

Test Coverageを維持しながら、不要な再実行を避ける。

---

## 7. Test環境

Test実行時は、Test Resultへ以下のEnvironment情報を記録する。

| 項目 | 記録要否 |
|---|---|
| OS | 必須 |
| Excel Version | 必須 |
| Excel 32bit / 64bit | 必須 |
| Classic Outlook Version | 必須 |
| Outlook 32bit / 64bit | 必須 |
| VBA実行ブック | 必須 |
| Test用OFT保存場所 | 必須 |
| 実施日 | 必須 |
| 実施者 | 必須 |

実際の値は本Test Specificationへ記録せず、Test Resultに保持する。

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
| MTS-CFG-007 | Template未登録VariableでUserForm停止 | Negative | Mandatory |
| MTS-CFG-008 | Template削除済みActive VariableでUserForm停止 | Negative | Mandatory |
| MTS-UI-001 | Dynamic UserForm生成 | Manual / Functional | Mandatory |
| MTS-UI-002 | Type / Control対応 | Manual / Functional | Mandatory |
| MTS-UI-003 | DisplayName / Required / Description | Manual | Mandatory |
| MTS-UI-004 | Select選択専用 / Active Option順 / OptionMaster参照 | Manual / Functional | Mandatory |
| MTS-UI-005 | 実使用Variable数でのUserForm利用可能性 | Manual / Risk | Mandatory |

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
| MTS-ERR-001 | 主要Errorが理解可能なMessageを返す | Manual | Mandatory |
| MTS-ERR-002 | Outlook / Word COM Error変換 | Negative | Mandatory |

## 9.7 NFR / Design

| ID | Test | Type | Gate |
|---|---|---|---|
| MTS-NFR-001 | Template固有処理を設定で変更可能 | Design / Functional | Mandatory |
| MTS-NFR-002 | Component責務分離 Review | Design Review | Mandatory |
| MTS-NFR-003 | 問題箇所がユーザーから観測可能 | Manual | Mandatory |
| MTS-NFR-004 | 不完全状態Fail Fast | Summary Gate | Mandatory |
| MTS-NFR-005 | UserFormのみでメール生成 | Manual E2E | Mandatory |
| MTS-NFR-006 | 将来型追加時の局所変更性Review | Design Review | Mandatory |

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
- OneDrive Web URL Variantでは、対象WorkbookとOFTがOneDriveローカル同期対象である

**Execution Variants**

### Variant A：Windows Local Path

`ThisWorkbook.Path` がWindows Local Pathを返す環境で実施する。

### Variant B：OneDrive Web URL

`ThisWorkbook.Path` が以下の形式を返す環境で実施する。

```text
https://d.docs.live.net/<CID>/...
```

**Steps**

1. Excelを起動する
2. `ThisWorkbook.Path` を確認する
3. Template依存処理を開始する
4. Settingsの `TemplatePath` を記録する
5. Workbook Relative Path Resolution後のPathを記録する
6. Template読込結果を確認する

**Expected**

- Workbook Relative Path Resolutionによって対象OFTのWindows絶対Pathを解決できる
- Variant AではWindows Local Pathを基点として対象OFTを解決できる
- Variant Bでは `d.docs.live.net` のWeb URLをOneDrive Local Sync Pathへ解決できる
- Variant BではWeb URLをOFT File Pathとして直接使用しない
- Settingsの `TemplatePath` はWorkbook相対Pathのまま維持される
- 解決したWindows絶対PathからTemplate読込に成功する

**Resolution Failure Variants**

### Variant C：OneDrive Local Root候補なし

**Expected**

- Path Resolutionは失敗する
- `ConfigurationError`を返す
- OFT存在確認へ進まない
- Outlook処理へ進まない

### Variant D：Local Workbook Path候補なし

**Expected**

- Path Resolutionは失敗する
- `ConfigurationError`を返す
- OFT存在確認へ進まない
- Outlook処理へ進まない

### Variant E：異なるLocal Workbook Path候補が複数存在

**Expected**

- 先頭候補を自動採用しない
- Path Resolutionは失敗する
- `ConfigurationError`を返す
- OFT存在確認へ進まない
- Outlook処理へ進まない

**Evidence**

正常系では以下を記録する。

- `ThisWorkbook.Path`
- Settings `TemplatePath`
- Resolved Local Path
- Template Read Result

Resolution Failure Variantでは以下を記録する。

- 発生条件
- `ErrorType`
- `Message`
- `Target`
- 後続処理へ進んでいないことを確認できるEvidence

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
- 検出した不正記述そのものをResultとして保持する

Expected InvalidCandidates：

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

このResultが以下へ接続できること。

```text
InvalidCandidates
├─ 手動同期停止 → MTS-SYNC-010
├─ UserForm起動停止
└─ メール生成停止 → MTS-SAFE-002等
```

UI通知では、少なくとも検出した不正記述をユーザーが確認できる。

Scanner内部の検出成功だけでFR-VAR-005全体をPASSとしない。

**Integration Variant：UserForm**

1. Invalid Variableを含むOFTを最初から用意する
2. UserForm起動を実行する

Expected：

- UserForm起動停止
- 自動同期しない
- 不正記述一覧を通知

手動同期停止は `MTS-SYNC-010`、メール生成停止は `MTS-SAFE-002` のEvidenceと合わせてFR-VAR-005を判定する。

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

## MTS-CFG-007 Template未登録VariableでUserForm停止

**Traceability**

- FR-UI-CHECK-001
- FR-UI-CHECK-002
- NFR-004

**Precondition**

VariableDefinitionには存在しないVariableをOFTへ追加する。

```text
OFT:
{{NewVariable}}

VariableDefinition:
NewVariableなし
```

手動同期は実施しない。

**Steps**

1. UserForm起動を実行する
2. VariableDefinitionを確認する

**Expected**

- Current OFT Scanで `NewVariable` を検出する
- Template未登録VariableとしてConfiguration Error
- UserFormを起動しない
- VariableDefinitionへ `NewVariable` を自動追加しない
- 自動同期を実行しない
- ユーザーが `NewVariable` が未登録であることを確認できる

---

## MTS-CFG-008 Template削除済みActive VariableでUserForm停止

**Traceability**

- FR-UI-CHECK-001
- FR-UI-CHECK-002
- NFR-004

**Precondition**

```text
OFT:
ModelNameなし

VariableDefinition:
ModelName = Active
```

手動同期は実施しない。

**Steps**

1. UserForm起動を実行する
2. VariableDefinitionを確認する

**Expected**

- Templateから削除されたActive VariableとしてConfiguration Error
- UserFormを起動しない
- `ModelName` を自動でUnusedへ変更しない
- 自動同期を実行しない
- ユーザーが `ModelName` の不整合を確認できる

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

**Precondition**

```text
VariableDefinition:
VariableName = Department
Type         = Select
OptionSource = Department
```

```text
OptionMaster:
Department / 設計部 / Active=True
Department / 品質部 / Active=True
Department / 生産部 / Active=False
```

**Expected**

- ComboBoxの選択肢はOptionMasterから取得する
- VariableDefinitionは選択肢文字列リストを直接保持せず、OptionSourceだけを参照する
- Active Optionのみ表示
- SortOrder順
- 自由入力不可
- Inactive Option「生産部」は表示しない

---

## MTS-UI-005 実使用Variable数でのUserForm利用可能性

**Traceability**

- FR-UI-001
- NFR-005
- Design RISK-DES-003

**Type**

Manual / Risk

**Precondition**

MVPで実際に使用予定のOFT / VariableDefinitionの最大または代表的Variable数を使用する。

**Steps**

1. UserFormを起動する
2. 全入力項目へアクセスできるか確認する
3. 末尾付近の項目へ入力する
4. 「入力クリア」「メール作成」等の主要操作へアクセスする

**Expected**

- 必要なすべての入力項目へアクセスできる
- 入力Controlが操作不能な位置へ隠れない
- Mail作成 / 入力クリア等の主要操作を実行できる
- 実使用Variable数でUserForm利用が成立する

具体的なForm寸法、ScrollBar有無、配置方式を本Testから新Requirementとして固定しない。

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
- FR-RENDER-SUB-001
- FR-RENDER-BODY-001
- Design §21.1

Optional Variableの空欄をSubject / Body双方で確認する。

### Variant A：Body

Baseline OFTの `{{Comment}}` を使用する。

```text
Comment  = 空欄
Required = False
```

**Expected**

- Bodyの `{{Comment}}` を空文字列へ置換
- Unresolved Variableとして残らない

### Variant B：Subject

Test用OFTのSubjectへOptional Variableを配置する。

```text
Subject:
【{{ModelName}}】{{OptionalNote}}

OptionalNote = 空欄
Required     = False
```

**Expected**

- Subjectの `{{OptionalNote}}` を空文字列へ置換
- Unresolved Variableとして残らない

Optional空欄が存在してもRender / Displayを阻害しない。

---

## MTS-REN-004 Date 6 Format

**Traceability**

- FR-TYPE-DATE-003 / 004
- AC-010

**Input**

ユーザー入力：

```text
2026-9-30
```

Validation後は日付値 `2026-09-30` として扱い、入力時のゼロ埋め・セパレータを出力へ直接引き継がない。

同一日付値へ6種類のFormatを適用する。

**Expected**

```text
yyyy/mm/dd        → 2026/09/30
yyyy-mm-dd        → 2026-09-30
yyyy年m月d日       → 2026年9月30日
m月d日             → 9月30日
yyyy年m月d日(aaa)  → 2026年9月30日(水)
m月d日(aaa)        → 9月30日(水)
```

**PASS条件**

- Raw Input `2026-9-30` の文字列表現を直接コピーしていない
- Validation後の日付意味値から各Formatを生成している
- 6種類すべてExpectedと一致する

曜日生成の具体的なVBA実装方法はTest側で固定しない。

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

- DOC-TS-A / TF-A-002
- DOC-MVP-DES §14
- DOC-MVP-DES §23

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

## MTS-ERR-001 主要Error Message

**Traceability**

- §25 エラー処理要件
- NFR-003
- Design §9.3
- Design §24
- Design §25.1〜25.3

以下の代表Errorを確認する。

- OFT不存在
- Workbook Relative Path / OneDrive Local Path Resolution Error
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

Workbook Relative Path / OneDrive Local Path Resolution Errorでは、追加で以下を満たす。

- `ConfigurationError`として返却される
- 問題対象を特定できる `Message` / `Target` を持つ
- Path Resolution失敗後にOFT存在確認へ進まない
- Path Resolution失敗後にOutlook処理へ進まない

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

**Type**

Summary Gate

本Case自体で新しい操作を実行しない。

以下のSafety関連Mandatory Test Resultを集約する。

- MTS-TPL-003
- MTS-SCAN-004
- MTS-CFG-001〜008
- MTS-VAL-001
- MTS-VAL-003〜008
- MTS-UNR-002 / 003
- MTS-SAFE-001〜003
- MTS-MAIL-004

**PASS**

上記の適用対象Mandatory TestがすべてPASSしている。

**FAIL**

上記のいずれかにFAIL / BLOCKEDが残存している。

同一Evidenceを複数Caseから参照してよく、本Summary GateのためにTestを再実行しない。

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

Mandatory Design Review。

将来型そのものを実装する必要はない。

**PASS**

以下が局所化されており、将来型追加のためにMVP全体の大規模な構造変更を前提としていない。

- Type / Control mapping
- Validation
- Value Formatter
- Data Access
- Renderer / Outlook Adapter責務

Review Evidenceとして、影響Componentと変更箇所の想定を記録する。

NFR-006は性能数値のTestではないが、Baseline RequirementであるためReview自体を省略可能なConditional Testとはしない。

---

# 17. Acceptance Criteria Traceability

| AC | Primary Test |
|---|---|
| AC-001 | MTS-TPL-001 / 002 / 003 |
| AC-002 | MTS-SCAN-001 / 003 |
| AC-003 | MTS-SCAN-004 / MTS-SYNC-010 / MTS-SAFE-002 |
| AC-004 | MTS-SYNC-002 / 003 / 004 / 007 |
| AC-005 | MTS-SYNC-002 / MTS-CFG-001 |
| AC-006 | MTS-UI-001 / 002 / 003 / 005 |
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
| FR-UI-001 | MTS-UI-001 / MTS-UI-005 |
| FR-UI-002 | MTS-UI-002 |
| FR-UI-003 | MTS-CFG-002 / 003 |
| FR-UI-004 | MTS-UI-003 |
| FR-UI-CHECK-001 | MTS-CFG-001〜008 / MTS-TPL-003 / MTS-SCAN-004 |
| FR-UI-CHECK-002 | MTS-CFG-001〜008 / MTS-SCAN-004 |
| FR-INPUT-001 | MTS-INPUT-001 |
| FR-INPUT-002 | MTS-INPUT-002 |
| FR-VAL-001 | MTS-VAL-001〜005 / MTS-SAFE-003 |
| FR-VAL-002 | MTS-VAL-006 |
| FR-VAL-003 | MTS-VAL-007 |
| FR-VAL-004 | MTS-VAL-008 |
| FR-RENDER-SUB-001 | MTS-REN-001 / MTS-REN-003 |
| FR-RENDER-BODY-001 | MTS-REN-002 / 003 |
| FR-RENDER-BODY-002 | MTS-REN-005 / 006 |
| FR-UNRESOLVED-001 | MTS-UNR-001 / 002 / 004 |
| FR-UNRESOLVED-002 | MTS-UNR-003 |
| FR-OUTLOOK-001 | MTS-TPL-003 / MTS-MAIL-001 / MTS-SAFE-001 |
| FR-OUTLOOK-002 | MTS-MAIL-001 / 002 |
| FR-OUTLOOK-003 | MTS-MAIL-002 |

**Traceability Mapping Coverage：47 / 47 FR**

これは全47 FRが1件以上のTest Caseへ紐付いていることを示す。

実行後のRequirement PASS Coverageは、各Mandatory Test Resultを基に判定する。

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

MTS-NFR-006はMandatory Design Reviewとする。

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

- Current Approved Baselineが定義されている
- Current Approved BaselineにDOC-MVP-REQが含まれている
- Current Approved BaselineにDOC-MVP-DESが含まれている
- Current Approved BaselineにDOC-TS-AのCLOSED Technical Evidenceが含まれている
- Current Approved BaselineにDOC-MVP-TESTSPECが含まれている
- 実装対象Versionを識別可能
- Test用Excel / OFTを準備済み
- Classic Outlook環境が利用可能
- Baseline Test Dataを再現可能

---

# 23. Exit Criteria

MVP Test完了条件：

1. Mandatory Testをすべて実施済み
2. Mandatory TestにFAIL / BLOCKEDが残っていない
3. Mandatory TestはすべてPASS、またはBaseline上適用外であることを明示した正当なN/Aである
4. AC-001〜020がすべてPASS
5. 47 FRのTraceability Mappingが維持され、適用対象RequirementのMandatory TestがPASSしている
6. NFR-001〜006がすべてPASS
7. Safety Summary Gate（MTS-NFR-004）がPASS
8. Technical Spike A Regression項目がPASS
9. Test Evidenceを保存済み
10. Requirement Gap / Design Gapが発生した場合、Baseline側で解決済み

Mandatory TestのN/Aは、Baseline上そのRequirement / Design Ruleが当該Buildへ適用されないことを明示できる場合のみ使用できる。

「実施困難」「未実装」「時間不足」はN/A理由としない。

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
- Baseline ID:
- 対象Build:
- Commit ID:
- Environment:
- 使用OFT:
- Initial State:
- Input:
- Actual Result:
- Evidence:
- Evidence Reference:
- N/A Reason:
- Finding:
- Requirement Impact:
- Design Impact:
- Retest:
```

ルール：

- PASS / FAIL判定時はEvidence Referenceを記録する
- N/A選択時はN/A Reasonを必須とする

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

- Mandatory TestにFAIL / BLOCKEDが残っていない
- Mandatory TestはすべてPASS、または正当なN/A
- AC-001〜020 PASS
- NFR-001〜006 PASS
- MTS-NFR-004 Safety Summary Gate PASS
- Technical Spike A Regression PASS
- Requirement / Design Gap未解決なし

## CONDITIONAL PASS

- Product Requirement / Acceptance Criteria / Mandatory Safety条件はすべて満たす
- Mandatory TestにFAIL / BLOCKEDは残っていない
- Scope外またはNon-BlockingなDocumentation / Environment Issueのみ残存
- IssueとMVP Releaseへの影響を記録済み

## FAIL

以下のいずれか。

- Mandatory TestにFAIL / BLOCKEDが1件以上残存する
- ACを満たせない
- 不完全なメールをDisplayできてしまう
- Invalid Variable / Configuration / Input / UnresolvedをFail Fastできない
- WordEditor Body RenderがRequirements保証範囲で成立しない
- 自動送信が発生する
- Blocking Requirement / Design Gapが未解決

---
