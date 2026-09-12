# Baseline最終整合性修正 差分パッチ v0.1

## 1. パッチ情報

| 項目 | 内容 |
|---|---|
| パッチ名 | Baseline最終整合性修正 差分パッチ |
| パッチバージョン | v0.1 |
| Source Requirements | MVP Requirements v0.1.5 日本語版 |
| Target Requirements | MVP Requirements v0.1.6 日本語版 |
| Source Design | MVP Design v0.1.3 日本語版 |
| Target Design | MVP Design v0.1.4 日本語版 |
| Technical Evidence | Technical Spike A v0.2 CLOSED / PASS |
| Requirement Gap | なし |
| 作成日 | 2026-09-11 |

---

## 2. Patch目的

Baseline最終整合性レビューで確認した以下を修正する。

1. メール生成直前のCurrent OFT再確認
2. 未置換Variable一覧Result
3. Select自由入力禁止
4. VariableDefinition自動管理列の更新規則
5. Unused通常非表示 / 必要時確認
6. Requirements次工程記述の現在地更新

新しい利用者Requirementは追加しない。

---

# 3. Requirements Patch

## PATCH-REQ-FINAL-001 Version更新

### Before

```markdown
# MVP Requirements v0.1.5 日本語版
```

```markdown
| バージョン | v0.1.5 |
```

### After

```markdown
# MVP Requirements v0.1.6 日本語版
```

```markdown
| バージョン | v0.1.6 |
```

文書情報直後に追加：

```markdown
### v0.1.6 更新概要

v0.1.6では、MVP Requirements v0.1.5 × MVP Design v0.1.3 × Technical Spike A v0.2 CLOSEDの最終整合性レビュー結果を反映した。

利用者向けRequirementは変更していない。

1. §34の次工程を、Design Reopen前の状態から最終整合性修正完了後の状態へ更新した
2. Requirement→Designの不足事項はMVP Design v0.1.4側で補完し、Requirement Gapは発生していない
```

---

## PATCH-REQ-FINAL-002 §34 次工程更新

### Replace

`## 34. 次工程` 全体を以下へ置換する。

```markdown
## 34. 次工程

Technical Spike A v0.2はCLOSED / PASSで完了し、Route W：WordEditorをMVPのBody処理技術方針として採用した。

Technical Spike Aの結果はMVP RequirementsおよびMVP Designへ反映済みであり、最終整合性レビューで確認したRequirement→Designの不足事項もMVP Design v0.1.4で補完した。

現在のBaselineは以下とする。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.4
        +
Technical Spike A v0.2 CLOSED
```

次工程は `MVP Test Specification v0.1` の作成とする。

Traceabilityは以下を追跡可能とする。

```text
Requirement
↓
Acceptance Criteria
↓
Design Component / Design Rule
↓
Test Case
```

Technical Spike Aの `TF-A-002` を踏まえ、Template Variableの検出成立性とRender後の未置換0件判定を別Testとして扱う。
```

---

# 4. Design Patch

## PATCH-DES-FINAL-001 Version / Requirements参照更新

### Before

```markdown
# MVP Design v0.1.3 日本語版
```

```markdown
| バージョン | v0.1.3 |
| 要件文書 | MVP Requirements v0.1.5 日本語版 |
```

### After

```markdown
# MVP Design v0.1.4 日本語版
```

```markdown
| バージョン | v0.1.4 |
| 要件文書 | MVP Requirements v0.1.6 日本語版 |
```

更新概要を追加：

```markdown
### v0.1.4 更新概要

MVP Requirements v0.1.5 × MVP Design v0.1.3 × Technical Spike A v0.2 CLOSEDの最終整合性レビュー結果を反映した。

1. メール生成直前にCurrent OFTを再Scan / Configuration CheckするFail Fast経路を追加
2. Unresolved Checkerが未置換Variable一覧を返すResultを明示
3. Select型ComboBoxを選択専用とし、自由入力不可をDesignへ明示
4. TemplateLocation / FirstDetectedAt / LastDetectedAtのSync更新規則を明示
5. Unused変数の通常非表示 / 必要時確認方針を明示
6. Requirements参照をMVP Requirements v0.1.6へ更新
7. TF-A-002をMVP Test Specificationへの引継ぎ事項として明示

新規Requirement Gapは発生していない。
```

---

## PATCH-DES-FINAL-002 §7 VariableDefinition管理規則追加

`§7.3 設定完了状態` の後へ追加する。

```markdown
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

```text
通常表示
→ GetActiveVariables()

Unused確認
→ GetAllVariables()
```

具体的なExcel Filter、表示切替Button等はImplementationで決定する。
```

---

## PATCH-DES-FINAL-003 §10.3 Data Access責務補強

`modVariableDefinitionData` 責務へ以下を明示する。

```markdown
- TemplateLocation更新
- FirstDetectedAt初期設定
- LastDetectedAt更新
- Active変数取得
- 全変数取得（Unused確認用）
```

既存項目と重複する場合は統合する。

---

## PATCH-DES-FINAL-004 §15 Sync Engine更新規則反映

### §15.3 New

以下を追記する。

```markdown
TemplateLocationにはTemplateScanResultの現在Locationを設定する。

FirstDetectedAt / LastDetectedAtには当該SyncのSyncTimestampを設定する。
```

### §15.4 Existing

以下へ補強する。

```markdown
DisplayName / Type / Required / Description / OptionSource / SortOrder / Format等のユーザー設定は保持する。

TemplateLocationは現在のTemplateScanResultへ更新する。

FirstDetectedAtは保持し、LastDetectedAtはSyncTimestampへ更新する。

VariableNameの表記は既存VariableDefinition側を正式表記として保持する。
```

### §15.5 Reactivated

以下へ補強する。

```markdown
StatusをActiveへ戻し、既存ユーザー設定およびFirstDetectedAtを保持する。

TemplateLocationは現在のTemplateScanResultへ更新し、LastDetectedAtはSyncTimestampへ更新する。
```

### §15.6 Unused

以下へ補強する。

```markdown
StatusのみUnusedへ変更し、ユーザー設定を保持する。

TemplateLocationは最終検出時の値を保持する。

FirstDetectedAt / LastDetectedAtも保持し、Unused化時刻でLastDetectedAtを上書きしない。
```

---

## PATCH-DES-FINAL-005 §17.2 Select自由入力禁止

### Before

```markdown
| Type | Control |
|---|---|
| Text | TextBox |
| Date | TextBox |
| Select | ComboBox |
```

### After

```markdown
| Type | Control | 入力規則 |
|---|---|---|
| Text | TextBox | 1行入力 |
| Date | TextBox | 1行入力 |
| Select | ComboBox | OptionMasterの有効Optionからの選択のみ |
```

追記：

```markdown
Text / Date用TextBoxは複数行入力を許可しない。

Select用ComboBoxは自由入力できない選択専用設定とする。

VBAでは `fmStyleDropDownList` 相当を使用する。

OptionはOptionMaster Data Accessが取得したActive OptionをSortOrder順に設定する。

具体的なControl Property設定コードはImplementationで確定する。
```

---

## PATCH-DES-FINAL-006 §18.2 Input State Lifecycle明文化

追記：

```markdown
InputValuesはWorkbook Session中のメモリ上の状態とし、Excelシートや外部ファイルへ永続保存しない。

Workbookを閉じた時点で保持対象外となる。
```

---

## PATCH-DES-FINAL-007 §23 Unresolved Checker Result補強

### §23.1

フローを以下へ変更する。

```text
Render
↓
Unresolved Checker
↓
UnresolvedCheckResult
├─ 0件 → Outlook Display
└─ 1件以上 → Error Result → UI一覧表示
```

### §23.3

現行記述へ以下を追加する。

```markdown
Unresolved Checkerは件数だけでなく、残存したVariableを後続UIへ渡す。

概念構造：

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

`Variables[]` はVariableNameをCase Insensitiveで重複統合する。

同一Variableが複数箇所、大文字・小文字違いで残存しても、ユーザー通知上は同一Variableとして扱う。

UIはVariables一覧からFR-UNRESOLVED-002の未置換Variable一覧を表示する。

警告のみで処理継続せず、1件以上でFailとする。
```

---

## PATCH-DES-FINAL-008 §24 Error設計のユーザー通知原則

§24.3へ追記する。

```markdown
`Message` は技術例外文字列をそのまま格納することを目的とせず、ユーザーが問題と次に確認すべき対象を理解できる内容とする。

複数Targetを通知する必要がある場合は、Errors[]または専用Resultの一覧情報をUIで集約表示する。
```

---

## PATCH-DES-FINAL-009 §25.3 メール生成直前のCurrent Template Guard

`§25.3 メール生成` を以下の責務順へ変更する。

```text
User
↓
メール作成
↓
Control値 → InputValues
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
VariableDefinition / OptionMaster取得
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

追記：

```markdown
UserForm起動時のConfiguration Check結果をメール生成時まで無条件に信用しない。

メール生成では生成用MailItemのCurrent OFT内容を再Scanし、Render前にConfiguration Validatorを再実行する。

目的は、UserForm表示後にOFTが変更された場合でも以下を保証することである。

- OFT不存在で生成を開始しない
- Invalid Variable Syntaxを含むメールを生成しない
- Template / VariableDefinition不整合状態でRenderしない

新しいValidatorは追加せず、UserForm起動時と同じTemplate Scanner / Configuration Validatorを再利用する。
```

---

## PATCH-DES-FINAL-010 §28 Traceability補強

以下の行を追加または既存行へ統合する。

```markdown
| VariableDefinition自動管理列 | Sync Engine / VariableDefinition Data |
| Unused通常非表示 / 確認 | VariableDefinition Data / UI |
| Select自由入力禁止 | UserForm Generator / OptionMaster Data |
| 未置換Variable一覧 | Unresolved Checker / Result Model / UI |
| メール生成直前Template整合性 | Template Scanner / Configuration Validator / Outlook Adapter |
```

---

## PATCH-DES-FINAL-011 §31 完了条件

先頭を以下へ変更する。

```markdown
本Design v0.1.4は、以下を満たした時点で基本設計完了とする。

- Requirements v0.1.6の主要要件に対応するコンポーネントが定義されている
```

以下を追加する。

```markdown
- メール生成直前のCurrent OFT / Configuration再確認経路が定義されている
- Unresolved Variable一覧をUIへ渡す経路が定義されている
- Select自由入力禁止が定義されている
- VariableDefinition自動管理列のSync更新規則が定義されている
```

---

## PATCH-DES-FINAL-012 §32 次工程 / Test Specification引継ぎ

次工程を以下へ更新する。

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.4
        +
Technical Spike A v0.2 CLOSED
        ↓
MVP Test Specification v0.1
        ↓
Technical Spike B / C
        ↓
Implementation Plan v0.1
        ↓
VBA実装
```

Test優先項目へ以下を追加する。

```markdown
- UserForm表示後にOFTを変更した場合の生成直前再チェック
- Invalid Variable Syntaxの生成直前Block
- Unresolved Variable一覧表示
- Template Variable検出成立性とUnresolved 0件判定の独立確認（TF-A-002）
- Select自由入力禁止
- TemplateLocation / FirstDetectedAt / LastDetectedAt更新
- Unused通常非表示 / 必要時確認
```

---

# 5. Technical Spike Aの扱い

Technical Spike A v0.2 CLOSEDは変更しない。

理由：

- 上位Requirements v0.1.4 / Design v0.1.2はSpike実施時Baseline
- Technical Decisionは既にRoute Wで確定
- Close後のRequirements / Design改訂履歴は後続文書側で管理する

環境バージョン未確認項目も既定どおり後日追記可能なNon-Blocking情報とする。

---

# 6. Patch適用後Baseline

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.4
+
Technical Spike A v0.2 CLOSED
```

この状態をMVP Test Specification v0.1の入力Baselineとする。

---

# 7. Patch判定

```text
Requirement Change : No
Requirement Gap    : No
Design Gap         : Closed by patch
Technical Decision : Unchanged
Route              : W / WordEditor
Additional Spike   : Not Required
```

**Patch判定：適用可能**
