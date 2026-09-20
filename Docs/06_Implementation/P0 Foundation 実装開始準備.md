# P0 Foundation 実装開始準備 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P0 Foundation 実装開始準備 |
| バージョン | v0.1 |
| 対象 | DOC-MVP-IMPL / P0 Foundation |
| Execution Baseline | BL-MVP-001 |
| Implementation Plan | DOC-MVP-IMPL v0.1 Approved |
| Formal Checkpoint | CP-P0 |
| 目的 | P0実装を開始できるよう、実装順、最小API、Implementation Detail、Commit単位、Verificationを固定する |

---

## 2. P0 Objective

後続Phaseが共通利用する以下を構築する。

- VBA Project基盤
- Result / Errorモデル
- Settings Data Access
- VariableDefinition Data Access
- OptionMaster Data Access
- Workbook基準相対Path解決基盤
- Case Insensitive Dictionary利用基盤

P0ではOutlook、Scanner、Sync、UserForm、Validation、Renderは実装しない。

---

## 3. P0で確定するImplementation Detail

### 3.1 Result / Errorモデル

**決定：小規模Classを採用する。**

Class Module:

- `CErrorInfo`
- `COperationResult`

Standard Module:

- `modResult`

概念構造：

```text
CErrorInfo
├─ ErrorType As String
├─ Message As String
└─ Target As String

COperationResult
├─ Success As Boolean
└─ Errors As Collection
```

`modResult` は生成Helperを提供する。

想定Public API：

```text
CreateSuccessResult()
CreateFailureResult(errorType, message, target)
AddError(result, errorType, message, target)
```

理由：

- Designの `OperationResult -> Success / Errors[]` を直接表現できる
- 複数Errorへ自然に拡張できる
- DictionaryでResult構造まで表現するより責務が明確
- DesignでResult / Error情報のみ小規模Class化を許容している

完全なDomain ModelやClass階層は作らない。

### 3.2 Dictionary Binding

**決定：Late Bindingを採用する。**

```text
CreateObject("Scripting.Dictionary")
CompareMode = vbTextCompare
```

理由：

- 配布先でMicrosoft Scripting Runtime参照設定を要求しない
- MVPの配布性を優先
- DesignのCase Insensitive要件を満たす

Dictionary生成処理が重複する場合のみ、後から小さなPrivate Helperへ集約する。

### 3.3 Data Carrier

**決定：Collection + late-bound Dictionaryを使用する。**

P0ではVariableDefinition / OptionMasterを専用Classへ変換しない。

例：

```text
Collection
└─ Dictionary
   ├─ VariableName
   ├─ DisplayName
   ├─ Type
   ├─ Required
   └─ ...
```

VariableDefinitionについては、SortOrder同順位時の行順判定に使用できるよう、Data Access内部情報としてTable Row Indexを取得可能にする。

### 3.4 Public / Private規則

- 他Moduleから呼ぶData Access APIのみ `Public`
- ListObject取得、列検索、行変換、内部検証Helperは `Private`
- Data Access外からWorksheet / ListObjectを直接操作しない
- P0 Data AccessからMsgBox等のUIを呼ばない
- ErrorはOperationResultとして呼出元へ返す

### 3.5 共通定数

**決定：P0では `modConstants` を新設しない。**

- Sheet名
- Table名
- Setting Key
- Column名

は原則として所有するData Access Module内の `Private Const` とする。

3つ以上の責務で同一Const共有が必要になった場合のみ、後続Phaseで共通化を再評価する。

### 3.6 Error Code

**決定：数値Error Code体系はP6まで保留する。**

P0では以下で十分とする。

- `ErrorType As String`
- `Message As String`
- `Target As String`

Error Code採番そのものを目的化しない。

---

## 4. P0で作成するModule

### Class Module

```text
CErrorInfo
COperationResult
```

### Standard Module

```text
modResult
modSettingsData
modVariableDefinitionData
modOptionMasterData
```

### 後続Module Shell

P0では原則作成しない。

理由：

- Compileには不要
- 空Moduleを大量に作ると変更ノイズが増える
- 必要になったPhaseで作成した方が責務確認しやすい

Implementation Planの「Shellを作成する場合」はOptionalとして扱う。

---

## 5. Data Access最小API

### 5.1 modSettingsData

P0 Minimum API：

```text
GetSettingValue(key, ByRef value) As COperationResult
ResolveWorkbookRelativePath(relativePath, ByRef absolutePath) As COperationResult
```

責務：

- `Settings` / `tblSettings` を読む
- Key / Valueを取得する
- `ThisWorkbook.Path + relativePath` のPath解決

P0ではファイル存在判定やOutlook読込は行わない。

### 5.2 modVariableDefinitionData

P0 Minimum API：

```text
GetAllVariableDefinitions(ByRef items As Collection) As COperationResult
GetActiveVariableDefinitions(ByRef items As Collection) As COperationResult
```

各ItemはDictionaryとし、Design §7.2の列をFieldとして返す。

内部情報としてTable Row Indexを保持可能にする。

P0では以下はまだ実装しない。

- Add
- Status Update
- TemplateLocation Update
- FirstDetectedAt / LastDetectedAt Update

これらはP2 Syncで追加する。

### 5.3 modOptionMasterData

P0 Minimum API：

```text
GetActiveOptions(optionGroup, ByRef items As Collection) As COperationResult
```

各ItemはDictionaryとし、以下を返す。

- OptionGroup
- Value
- SortOrder
- Active

SortOrder順で返す。

P0ではSelect Validationは行わない。

---

## 6. Error Handling方針

P0 Data Accessは、少なくとも以下をOperationResultへ変換する。

```text
WorksheetNotFound
TableNotFound
ColumnNotFound
SettingNotFound
DuplicateSettingKey
UnexpectedError
```

ただし上記文字列を正式な全Project Error Taxonomyとはしない。

P6でError体系全体を再評価する。

Data AccessはTechnical ExceptionをそのままUIへ表示しない。

---

## 7. 実装順序

### P0-01 VBA Project初期化

- Option Explicitを全Module / Classへ適用
- Class / Module作成
- Public / Private規則確認
- Compile

### P0-02 Result / Error Model

- CErrorInfo
- COperationResult
- modResult Factory / Helper
- Success Result生成
- Single Error生成
- Multiple Error追加
- Compile

### P0-03 Settings Data Access

- Settings Sheet / Table取得
- Column解決
- Key検索
- Value取得
- 相対Path解決
- Error Result変換
- Compile / Verification

### P0-04 VariableDefinition Data Access

- Sheet / Table取得
- Required Column解決
- All取得
- Active取得
- Dictionary化
- vbTextCompare
- Table Row Index保持
- Compile / Verification

### P0-05 OptionMaster Data Access

- Sheet / Table取得
- Column解決
- OptionGroup Filter
- Active Filter
- SortOrder順取得
- Dictionary化
- Compile / Verification

### P0-06 P0 Integration Verification

- P0 APIを順番に実行
- Result伝播確認
- Data Access外にListObject操作がないことをReview
- BL-MVP-001 Conflict確認
- Blocking Finding確認
- CP-P0判定

---

## 8. Commit Strategy

推奨Commit単位：

```text
C01 chore: establish P0 VBA project structure
C02 feat: add operation result model
C03 feat: add settings data access
C04 feat: add variable definition data access
C05 feat: add option master data access
C06 test: verify P0 foundation and establish CP-P0
```

各Commit前に最低限Compile成功を確認する。

Phase Checkpoint `CP-P0` はC06完了後に成立させる。

---

## 9. P0 Verification Checklist

### Compile

- [ ] VBA Project全体がCompile可能
- [ ] Option Explicitエラーなし

### Result

- [ ] Success Resultを生成できる
- [ ] Error Resultを生成できる
- [ ] 複数Errorを保持できる
- [ ] ErrorType / Message / Targetを取得できる

### Settings

- [ ] Key指定でValue取得可能
- [ ] TemplatePath取得可能
- [ ] Workbook基準で絶対Pathへ解決可能
- [ ] Key不存在をError Result化できる
- [ ] 重複KeyをError Result化できる

### VariableDefinition

- [ ] 全件取得可能
- [ ] Activeのみ取得可能
- [ ] Design §7.2のFieldを取得可能
- [ ] Case Insensitive Dictionaryを生成できる
- [ ] Table Row Indexを保持可能

### OptionMaster

- [ ] OptionGroup指定でActive Option取得可能
- [ ] SortOrder順で取得可能
- [ ] Design §8.2のFieldを取得可能

### Responsibility Review

- [ ] Worksheet / ListObject直接操作はData Access Module内だけ
- [ ] Data AccessからUIを呼ばない
- [ ] Outlook依存なし
- [ ] Scanner / Sync / Validationを先行実装していない

---

## 10. P0 Exit Criteria / CP-P0

以下をすべて満たした場合のみ `CP-P0` をEstablishedとする。

1. 後続処理がExcel Tableへ直接依存せず必要データを取得可能
2. Result / Errorを共通形式で呼出元へ返却可能
3. VBA Project全体がCompile可能
4. BL-MVP-001とのConflictなし
5. Blocking Implementation Findingなし
6. P0 Verification Checklistが完了

P0 VerificationはFormal MVP Testではない。

正式Test ResultはP7後にTest Candidate Build `MVP-Bxxx` を固定してから `DOC-MVP-TESTSPEC` に従って実施する。

---

## 11. P0で実装しないもの

以下は意図的に後続Phaseへ残す。

```text
Outlook / WordEditor       → P1
Template Scanner           → P1 / P2
Sync更新                   → P2
Configuration Validation   → P3
Dynamic UserForm           → P3
Input State                → P3
Input Validation           → P4
Value Formatting           → P4
Full Mail Generation       → P5
COM Lifecycle最終化        → P6
正式69 Test                → P7後
```

---

## 12. 最初の実装着手点

最初に実装するのは `CErrorInfo / COperationResult / modResult` とする。

理由：

Data Accessで異常をUIや例外のまま外へ漏らさず、共通Resultとして返す仕組みを先に成立させることで、P0以降のModuleが同じError Contractを利用できるため。

実装順：

```text
CErrorInfo
    ↓
COperationResult
    ↓
modResult
    ↓
modSettingsData
    ↓
modVariableDefinitionData
    ↓
modOptionMasterData
    ↓
CP-P0
```
