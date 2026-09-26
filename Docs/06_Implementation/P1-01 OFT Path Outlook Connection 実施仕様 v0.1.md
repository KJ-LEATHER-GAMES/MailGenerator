# P1-01 OFT Path / Outlook Connection 実施仕様 v0.1

## 1. 位置づけ

| 項目 | 内容 |
|---|---|
| Phase | P1 Walking Skeleton |
| Task | P1-01 OFT Path / Outlook Connection |
| Current Baseline | BL-MVP-001 |
| 前提Checkpoint | CP-P0 = ESTABLISHED |
| Related Documents | DOC-MVP-DES / DOC-TS-A / DOC-MVP-IMPL |
| Change Classification | Implementation Detail / Phase Verification |

## 2. Objective

P0で成立済みのSettings / Workbook相対Path解決基盤とClassic OutlookをProduction Module境界で接続し、OFTからMailItemを生成して保存せずCloseできることを確認する。

特に、OneDrive環境で `ThisWorkbook.Path` が `https://d.docs.live.net/...` 形式となる場合に、`ResolveWorkbookRelativePath` が生成したPathをClassic Outlookの `CreateItemFromTemplate` が実際に処理できるかをEvidenceベースで確認する。

## 3. Scope

```text
GetSettingValue("TemplatePath")
↓
ResolveWorkbookRelativePath
↓
modOutlookAdapter.CreateMailFromTemplate
↓
MailItem生成確認
↓
modOutlookAdapter.CloseWithoutSave
```

Production側で新規作成するModule：

- `modOutlookAdapter`

Verification側：

- `modP1OftConnectionSmokeTest`

## 4. Out of Scope

P1-01では以下を実装しない。

- Inspector / WordEditor取得
- Subject / BodyText取得
- Template Scanner
- VariableDefinition連携
- Render
- Unresolved Check
- MailItem.Display
- 自動送信
- OneDrive URLからLocal Sync Pathへの変換
- Path正規化方式の追加
- Design / Requirement変更

## 5. Implementation Decisions

### 5.1 Outlook Binding

Outlook Object ModelはLate Bindingとする。

```vb
CreateObject("Outlook.Application")
```

既存Outlook Instanceが取得可能な場合は `GetObject` を優先する。

理由：

- Outlook参照設定をWorkbook配布条件にしない
- P1 Walking Skeletonで余分な参照設定リスクを増やさない
- COM依存を `modOutlookAdapter` 内へ閉じ込める

### 5.2 MailItem Lifecycle

`modOutlookAdapter` が内部状態としてOutlook Application / MailItem参照を保持する。

Core LogicやSmoke TestへMailItem COM Objectを直接返さない。

公開API：

```vb
CreateMailFromTemplate(ByVal templatePath As String) As COperationResult
CloseWithoutSave() As COperationResult
```

P1-01では同時に複数MailItemを保持しない。

### 5.3 File Existence Pre-check

P1-01では `Dir` / FileSystemObject等による事前存在確認を行わない。

理由：

今回の主要Technical Questionは `https://d.docs.live.net/...` 形式を `CreateItemFromTemplate` 自身が処理可能かどうかであり、ローカルファイル前提の事前存在確認を入れると検証対象へ到達する前に失敗する可能性があるため。

Resolved Pathは加工せず、そのまま `CreateItemFromTemplate` へ渡す。

### 5.4 Error Handling

- 空TemplatePath：`TemplateError`
- Outlook Application取得／生成失敗：`OutlookError`
- `CreateItemFromTemplate`失敗：`OutlookError`
- MailItem以外が返る等の想定外状態：`OutlookError`
- 保存なしClose失敗：`OutlookError`
- Core / InfrastructureからMsgBoxを表示しない
- `COperationResult / CErrorInfo / modResult` を使用する

数値Error Code体系は導入しない。

### 5.5 Outlook Application Lifecycle

Adapterが取得したOutlook Applicationに対して `Quit` は呼ばない。

MailItemを `olDiscard` 相当でCloseした後、VBA側のObject参照のみ解放する。

## 6. Production API

### 6.1 CreateMailFromTemplate

```vb
Public Function CreateMailFromTemplate( _
    ByVal templatePath As String _
) As COperationResult
```

Success条件：

- TemplatePathが空でない
- Outlook Applicationを取得または生成できる
- `CreateItemFromTemplate(templatePath)` が成功する
- 返却ObjectがMailItemである
- Adapter内部にMailItem参照を保持できる

### 6.2 CloseWithoutSave

```vb
Public Function CloseWithoutSave() As COperationResult
```

Success条件：

- Adapter内部にMailItemが存在する
- `MailItem.Close 1`（olDiscard相当）が成功する
- MailItem / Outlook ApplicationのVBA参照を解放する

## 7. Smoke Test Scenario

Test Macro：

```text
TestP1OftConnection
```

実行フロー：

```text
START
↓
ThisWorkbook.Path出力
↓
GetSettingValue("TemplatePath")
↓
TemplatePath出力
↓
ResolveWorkbookRelativePath
↓
ResolvedPath出力
↓
CreateMailFromTemplate
↓
PASS確認
↓
CloseWithoutSave
↓
PASS確認
↓
TestP1OftConnection: PASS
```

Fail時はその場で終了し、後続PASSを出力しない。

`Debug.Assert` は使用しない。

## 8. Expected Evidence

成功時の例：

```text
TestP1OftConnection: START
ThisWorkbook: MailGenerator.xlsm
ThisWorkbook.Path: <actual path>
TemplatePath: Templates\MailTemplate.oft
ResolvedPath: <actual resolved path>
  Settings / Path Resolution: PASS
  CreateItemFromTemplate: PASS
  Close Without Save: PASS
TestP1OftConnection: PASS
```

失敗時は以下を出力する。

```text
<Step>: FAIL
  ErrorType=<...>
  Message=<...>
  Target=<...>
TestP1OftConnection: FAIL
```

## 9. Result Classification

### PASS

`CreateItemFromTemplate` と保存なしCloseが成功した場合：

```text
P1-01 = PASS
Next = P1-02 Inspector / WordEditor
```

### FAIL — Implementation Detail候補

例：

- API呼出し方法
- Adapter内部状態管理
- Close処理
- 単純なVBA実装ミス

既存Designの意味を変えず解決できる場合はImplementation Detailとして修正する。

### FAIL — Design Finding候補

例：

- `ResolveWorkbookRelativePath` が生成するOneDrive HTTPS PathをClassic Outlookが扱えず、現行のWorkbook相対Path設計だけではOFT参照が成立しない

この場合、Local Sync Path変換等を勝手に追加せずDesign Findingとして切り出す。

利用者制約の変更が必要になる場合のみRequirement Gapを評価する。

## 10. Done Criteria

- [ ] `modOutlookAdapter` がVBA ProjectへImportできる
- [ ] `modP1OftConnectionSmokeTest` がImportできる
- [ ] Debug → Compile VBAProject PASS
- [ ] SettingsからTemplatePathを取得できる
- [ ] Workbook相対Pathを解決できる
- [ ] Resolved Pathを加工せずOutlookへ渡している
- [ ] OFTからMailItemを生成できる、または失敗Evidenceを取得できる
- [ ] 成功時にMailItemを保存せずCloseできる
- [ ] 自動送信されない
- [ ] Outlook ApplicationをQuitしない
- [ ] Fail-FastでPASS誤表示がない
- [ ] P1-01のPASS / FAILとFinding分類を判断できる
