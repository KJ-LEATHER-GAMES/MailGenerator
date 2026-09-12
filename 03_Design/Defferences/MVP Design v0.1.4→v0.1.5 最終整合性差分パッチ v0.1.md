# MVP Design v0.1.4 → v0.1.5 最終整合性差分パッチ v0.1

## 1. パッチ情報

| 項目 | 内容 |
|---|---|
| パッチ名 | MVP Design v0.1.4 → v0.1.5 最終整合性差分パッチ |
| パッチバージョン | v0.1 |
| Source Design | `MVP Design v0.1.4 日本語版.md` |
| Target Design | `MVP Design v0.1.5 日本語版.md` |
| 上位Requirements | `MVP Requirements v0.1.6 日本語版.md` |
| Technical Evidence | `Technical Spike A 実施仕様書 v0.2 日本語版_CLOSED.md` |
| 起点レビュー | `Baseline 最終整合性再確認 v0.1.md` |
| 対象Finding | FCR-001 / FCR-002 |
| Requirement Gap | なし |
| Additional Technical Spike | 不要 |
| 作成日 | 2026-09-11 |

---

## 2. 目的

本Patchは、Baseline最終整合性再確認で残った以下2点だけを修正する。

1. **FCR-001**  
   メール生成時のInput Validatorが、メール生成時点のCurrent `VariableDefinition` / `OptionMaster` を使用することをDesign上保証する。

2. **FCR-002**  
   Input Stateの保持期間表現を、Requirementsおよび§18.2に合わせて「Workbookを閉じるまで」へ統一する。

本Patchでは、上記2点以外のArchitecture、Component、Technical Decision、Requirement、Acceptance Criteria、保証範囲を変更しない。

---

## 3. Patch方針

```text
Requirement追加
    なし
      │
      ▼
FCR-001 / FCR-002
既存RequirementのDesign完全化
      │
      ▼
Designのみ局所修正
      │
      ▼
MVP Design v0.1.5
```

FCR-001への対応では、新しいSnapshot管理、Version管理、Validator、Repository、Adapter等を追加しない。

既存の、

- VariableDefinition Data Access
- OptionMaster Data Access
- Input Validator
- Template Scanner
- Configuration Validator

を使用する。

---

# 4. 差分一覧

| Patch ID | 対象 | 内容 | 対応Finding |
|---|---|---|---|
| PATCH-DES-015-001 | 文書Version / 更新概要 | v0.1.5化 | Mechanical |
| PATCH-DES-015-002 | §5 Component責務 | Input State保持期間表現統一 | FCR-002 |
| PATCH-DES-015-003 | §19 Input Validator | Current設定を入力とする契約を明示 | FCR-001 |
| PATCH-DES-015-004 | §25.3 Mail生成 | Current VariableDefinition / OptionMaster取得をInput Validation前へ移動 | FCR-001 |
| PATCH-DES-015-005 | §31 完了条件 | v0.1.5自己参照・FCR-001/002 Close条件 | Mechanical |
| PATCH-DES-015-006 | §32 次工程 | v0.1.5自己参照へ更新 | Mechanical |

---

# 5. 詳細差分

## PATCH-DES-015-001 文書Version / 更新概要

### 対象

- 文書タイトル
- §1 文書情報
- 更新概要

### Before

```markdown
# MVP Design v0.1.4 日本語版
```

```markdown
| バージョン | v0.1.4 |
```

### After

```markdown
# MVP Design v0.1.5 日本語版
```

```markdown
| バージョン | v0.1.5 |
```

既存の `### v0.1.4 更新概要` の前へ以下を追加する。

```markdown
### v0.1.5 更新概要

`MVP Requirements v0.1.6` × `MVP Design v0.1.4` × `Technical Spike A v0.2 CLOSED` の最終整合性再確認で残ったFCR-001 / FCR-002を反映した。

1. メール生成時のInput Validatorが、生成時点のCurrent VariableDefinition / OptionMasterを使用することを明示
2. Mail生成シーケンスでVariableDefinition / OptionMaster取得をInput Validation前へ移動
3. Input Stateの保持期間表現を「Workbookを閉じるまで」へ統一

本変更は既存RequirementをDesignへ正確に反映するための局所修正であり、新規Requirement Gapおよび追加Technical Spikeは発生していない。
```

### 理由

v0.1.4までの履歴を保持したまま、今回の局所修正を識別可能にする。

---

## PATCH-DES-015-002 §5 Input State責務の表現統一

### 対象

`## 5. コンポーネント責務`

### Before

```markdown
| Input State | Excel終了までの入力値保持 |
```

### After

```markdown
| Input State | Workbookを閉じるまでの入力値保持 |
```

### 理由

以下と表現を一致させる。

- `MVP Requirements v0.1.6` FR-INPUT-001
- `MVP Design v0.1.4` §18.2

意味変更はない。

---

## PATCH-DES-015-003 §19 Input Validatorの入力契約を明示

### 対象

`## 19. Input Validator設計`

### 19.1 責務分離

#### Before

```markdown
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
```

#### After

```markdown
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
```

### 19.2 Validation項目への追記

既存のValidation規則の末尾へ以下を追加する。

```markdown
メール生成時のValidationでは、以下をCurrent Dataから判定する。

- Required：Current VariableDefinition.Required
- Type：Current VariableDefinition.Type
- Select有効値：Current OptionMasterのActive Option

Select型では、入力値がメール生成時点のCurrent Active Optionに存在しない場合はErrorとする。

Input Validator自身はExcel Tableを直接読み取らず、Application層がData Accessから取得したCurrent VariableDefinition / OptionMasterを入力として渡す。
```

### 理由

FR-VAL-001では、Select値がOptionMasterの有効Optionに存在することを要求している。

UserForm表示後にOptionMasterまたはVariableDefinitionが変更された場合でも、メール生成時点のCurrent設定でValidationできるよう責務を明確化する。

新しいValidation規則は追加していない。

---

## PATCH-DES-015-004 §25.3 メール生成シーケンス修正

### 対象

`### 25.3 メール生成`

### 現行の問題箇所

#### Before

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
...
    ↓
TemplateScanResult
    ↓
VariableDefinition / OptionMaster取得
    ↓
Configuration Validator
```

この順序では、Input ValidatorがCurrent VariableDefinition / OptionMaster取得前に実行される。

### After

メール生成シーケンスを以下へ変更する。

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

### シーケンス後の説明へ追記

```markdown
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
```

### 理由

FCR-001を解消し、FR-VAL-001 / NFR-004をメール生成時点のCurrent Dataで満たす。

---

## PATCH-DES-015-005 §31 MVP Design完了条件

### Before

```markdown
本Design v0.1.4は、以下を満たした時点で基本設計完了とする。
```

### After

```markdown
本Design v0.1.5は、以下を満たした時点で基本設計完了とする。
```

既存完了条件の末尾へ以下を追加する。

```markdown
- メール生成時のInput ValidatorがCurrent VariableDefinition / OptionMasterを使用することが定義されている
- Input State保持期間が「Workbookを閉じるまで」で統一されている
```

### 理由

今回のFCR-001 / FCR-002がDesign完了条件としてCloseしたことを明示する。

---

## PATCH-DES-015-006 §32 次工程の自己参照更新

### Before

```markdown
`MVP Requirements v0.1.6` と本 `MVP Design v0.1.4`、および `Technical Spike A v0.2 CLOSED` の最終整合性を再確認した後、`MVP Test Specification v0.1` を作成する。
```

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.4
        +
Technical Spike A v0.2 CLOSED
```

### After

```markdown
`MVP Requirements v0.1.6` と本 `MVP Design v0.1.5`、および `Technical Spike A v0.2 CLOSED` の最終整合性を確認した後、`MVP Test Specification v0.1` を作成する。
```

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.5
        +
Technical Spike A v0.2 CLOSED
```

### 理由

Design文書自身のVersion参照をv0.1.5へ合わせるためのMechanical Update。

Test対象、Technical Decision、次工程そのものは変更しない。

---

# 6. 変更しない項目

本Patchでは以下を変更しない。

- Route W：WordEditor
- D16 Body処理方式
- Outlook Adapter責務
- Template Scanner
- Configuration ValidatorのValidation規則
- Sync Engine
- UserForm Generator
- Input State実装方式
- Date Validation
- Select自由入力禁止
- Subject Renderer
- Word Range Body Rendering
- Unresolved Checker
- `UnresolvedCheckResult`
- RISK-DES-001 / 002
- Technical Spike Aの扱い
- Requirements v0.1.6
- Requirement Gap判定
- Technical Spike追加要否

---

# 7. Requirement Gap判定

FCR-001 / FCR-002はいずれも既存Requirementから直接導出される。

```text
新しい利用者向け振る舞い？
        ↓
       No
        ↓
Design completeness / consistency
```

したがって、

```text
Requirement Gap：なし
```

とする。

---

# 8. 追加Technical Spike判定

本Patchは、

- Current Excel Dataの取得順序
- Validatorへの入力契約
- 文言統一

のみを変更する。

WordEditor、Range.Find、MailItem Lifecycle等の技術成立性には変更がない。

したがって、

```text
Additional Technical Spike：不要
```

とする。

---

# 9. Patch適用後のBaseline

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.5
        +
Technical Spike A v0.2 CLOSED
```

このBaselineを最終確認後、`MVP Test Specification v0.1` の入力とする。

---

# 10. 適用後チェックリスト

## FCR-001

- [ ] §19.1でInput ValidatorがCurrent VariableDefinition / OptionMasterを使用すると明記されている
- [ ] §19.2でRequired / Type / Active OptionをCurrent Dataから判定すると明記されている
- [ ] §25.3でVariableDefinition / OptionMaster取得がInput Validatorより前にある
- [ ] 同一メール生成処理内でCurrent DataをInput Validator / Configuration Validatorが共有する
- [ ] 新しいSnapshot永続化・Version管理を追加していない

## FCR-002

- [ ] §5 Input Stateが「Workbookを閉じるまで」となっている
- [ ] §18.2との意味が一致している
- [ ] FR-INPUT-001との意味が一致している

## Version

- [ ] タイトルがv0.1.5
- [ ] 文書情報がv0.1.5
- [ ] v0.1.5更新概要がある
- [ ] §31が「本Design v0.1.5」
- [ ] §32のActive BaselineがDesign v0.1.5

---

# 11. Patch判定

```text
Source Design       : MVP Design v0.1.4
Target Design       : MVP Design v0.1.5
Requirements        : MVP Requirements v0.1.6
Technical Spike     : A v0.2 CLOSED
FCR-001             : Close by patch
FCR-002             : Close by patch
Requirement Change  : No
Requirement Gap     : No
Technical Decision  : Unchanged
Additional Spike    : Not Required
```

**Patch判定：適用可能**
