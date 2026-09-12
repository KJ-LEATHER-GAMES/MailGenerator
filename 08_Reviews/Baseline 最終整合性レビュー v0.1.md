# Baseline最終整合性レビュー v0.1

## 1. 対象Baseline

| 文書 | バージョン | 役割 |
|---|---|---|
| MVP Requirements | v0.1.5 | 利用者要求・保証範囲 |
| MVP Design | v0.1.3 | MVP基本設計 |
| Technical Spike A | v0.2 CLOSED / PASS | Body処理方式のTechnical Evidence / Decision |

レビュー日：2026-09-11

---

## 2. 総合判定

**判定：CONDITIONAL PASS**

Technical Spike Aで決定したRoute W：WordEditorは、MVP Requirements v0.1.5およびMVP Design v0.1.3へ概ね一貫して反映されている。

以下は整合している。

- Route W：WordEditor採用
- SubjectはPlain Text処理
- Body物理置換はWord `Range.Find` + `Range.Text`
- HTMLBody直接置換の不採用
- HTML Encode責務の削除
- Word Object Model依存のOutlook Adapterへの集約
- Template Scanner / Unresolved CheckerのBodyText利用
- Body Renderer独立コンポーネントの廃止
- RISK-DES-001のCLOSED化
- Requirement Gapなし
- Technical Spike A：PASS / CLOSED

一方、Requirement→Designの詳細突合で、**4件のDesign completeness gap、1件のDesign明文化不足、1件の文書参照陳腐化**を確認した。

これらは新しい利用者要求を追加するものではなく、既存RequirementsをDesignへ完全に落とし込むための修正である。

したがって新規Requirement Gapは発行しない。

---

# 3. Finding一覧

| ID | 重要度 | 分類 | Finding | 対応 |
|---|---|---|---|---|
| CR-001 | High | Design Gap | メール生成時に現在のOFTを再確認する経路が不足 | Design修正 |
| CR-002 | High | Design Gap | 未置換Variableの「一覧表示」に必要なResult設計が不足 | Design修正 |
| CR-003 | Medium | Design Gap | Select型ComboBoxで自由入力を禁止する設計が未明示 | Design修正 |
| CR-004 | Medium | Design Gap | TemplateLocation / FirstDetectedAt / LastDetectedAtの更新規則が未定義 | Design修正 |
| CR-005 | Low | Design Clarification | Unused変数の通常非表示 / 必要時確認の責務が暗黙的 | Design明文化 |
| CR-006 | Low | Document Consistency | Requirements §34がMVP Design v0.1.2 Reopenを指したまま | Requirements文書更新 |

---

# 4. 詳細Finding

## CR-001 メール生成直前のTemplate再確認不足

### 関連Requirements

- FR-TPL-002
- FR-VAR-005
- FR-UI-CHECK-001 / 002
- FR-OUTLOOK-001
- NFR-004

Requirementsでは以下の場合にメール生成を継続してはならない。

- OFT不存在
- 命名規則違反Variable
- Configuration不整合

MVP Design v0.1.3ではUserForm起動前に現在OFTを再Scanしている。

しかしメール生成時は、

```text
Input Validator
↓
生成用MailItem
↓
Render
↓
Unresolved Check
```

となっており、**UserForm表示後にOFTが変更された場合のTemplate Scanner / Configuration Validator再実行がない。**

### リスク例

```text
1. UserForm起動時
   {{ModelName}} のみ
   → Configuration OK

2. UserForm表示後にOFTが変更
   {{ Bad-Name }} を追加

3. メール生成
   → 現DesignではInvalid Candidate Scanを再実行しない

4. Unresolved Checker
   → 有効Variable形式のみを対象とする場合、
      Invalid Candidateを取りこぼす可能性

5. Display
   → FR-VAR-005 / NFR-004違反
```

### 判定

既存Requirementから導ける安全性要件であり、Requirement Gapではない。

### 修正方針

メール生成時も生成用MailItemの現在内容から、

```text
Subject / BodyText
↓
Template Scanner
↓
Configuration Validator
```

をRender前に実行する。

新規コンポーネントは追加せず既存処理を再利用する。

---

## CR-002 FR-UNRESOLVED-002の一覧表示Result不足

### 関連Requirements

- FR-UNRESOLVED-001
- FR-UNRESOLVED-002
- AC-018
- NFR-003

Requirementsは未置換Variableが存在した場合、

1. メール生成停止
2. 対象Variableを一覧表示

の両方を要求している。

Design §23は「1件でも存在すれば停止」までは定義しているが、Unresolved Checkerが**どのVariableが残ったかを後続UIへ返すデータ構造**を定義していない。

### 修正方針

概念Resultを以下とする。

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

`Variables[]` はCase Insensitiveで重複統合する。

UIはこの一覧からFR-UNRESOLVED-002のメッセージを構築する。

---

## CR-003 Select自由入力禁止のDesign不足

### 関連Requirements

- FR-TYPE-SELECT-001
- AC-011

RequirementsではSelect型を、

```text
一覧選択のみ
自由入力不可
```

としている。

Design §17.2は `Select → ComboBox` までしか定義していない。

MSForms ComboBoxは設定によって自由入力可能となるため、Control種別だけではRequirementを保証できない。

### 修正方針

Select型は、

```text
ComboBox.Style = fmStyleDropDownList
```

相当の選択専用設定を使用する。

具体的な生成コードはImplementation Detailとする。

---

## CR-004 VariableDefinition自動列の更新規則不足

### 関連Requirements

VariableDefinitionで以下を保持する。

- TemplateLocation
- Status
- FirstDetectedAt
- LastDetectedAt

Design §7では列定義、§10では一部Data Access責務があるが、Sync Engineに更新タイミングが定義されていない。

特に、

```text
New
Existing
Reactivated
Unused
```

ごとの `TemplateLocation / FirstDetectedAt / LastDetectedAt` の扱いが未確定。

### 修正方針

同期1回につき共通の `SyncTimestamp` を取得し、以下とする。

| Sync状態 | TemplateLocation | FirstDetectedAt | LastDetectedAt |
|---|---|---|---|
| New | 現在のScan結果 | SyncTimestamp | SyncTimestamp |
| Existing | 現在のScan結果へ更新 | 保持 | SyncTimestamp |
| Reactivated | 現在のScan結果へ更新 | 保持 | SyncTimestamp |
| Unused化 | 最終検出Locationを保持 | 保持 | 保持 |
| 既にUnused | 保持 | 保持 | 保持 |

Statusは既存DesignどおりActive / Unusedを更新する。

これは管理情報のDesign具体化であり、新しい利用者Requirementではない。

---

## CR-005 Unused通常非表示のDesign明文化不足

### 関連Requirements

FR-SYNC-004では、

- 通常の設定表示ではUnusedを非表示
- 必要時に確認可能

としている。

Designには、

- Active変数取得
- 全変数取得
- Status列

が存在するため実現可能だが、通常表示とUnused確認の利用規則が明記されていない。

### 修正方針

Designに以下を明記する。

```text
通常設定対象
→ Status = Active

Unused確認
→ Active / Unusedを含む全件
```

具体的なExcel Filter / UI切替方式はImplementationへ残す。

---

## CR-006 Requirements §34の現在地が古い

MVP Requirements v0.1.5 §34では次工程として、

```text
MVP Design v0.1.2 Reopen / 改訂
```

が記載されている。

しかし現在は、

```text
MVP Design v0.1.3
Route W反映済み
```

まで進んでいる。

Requirement本文の矛盾ではないが、Activeな「次工程」記述として陳腐化している。

### 修正方針

最終整合性修正後、

```text
MVP Requirements
+
MVP Design
+
Technical Spike A
↓
MVP Test Specification v0.1
```

へ更新する。

---

# 5. Technical Spike Aとの整合性

## 5.1 Technical Decision

一致している。

```text
Technical Spike A
Route W：WordEditor
```

```text
MVP Design v0.1.3
D16：Route W
Inspector.WordEditor
+ Range.Find
+ Range.Text
```

矛盾なし。

## 5.2 HTML Encode

Spike：

```text
Route WではHTML Encode不要
```

Requirements：

HTML Encodeの利用者Requirement化を解消済み。

Design：

HTML EncodeをActive Body処理から削除済み。

矛盾なし。

## 5.3 Scanner / Unresolved Checker

SpikeではWordEditor / Word Document上で検出成立を確認した。

DesignではCOM依存をOutlook Adapterへ閉じ込め、

```text
Word Document
↓
BodyText Snapshot
↓
Scanner / Unresolved Checker
```

としている。

これはSpike EvidenceをArchitectureへ抽象化したものであり、矛盾ではない。

## 5.4 TF-A-001

Design `RISK-DES-001 — CLOSED` へ反映済み。

矛盾なし。

## 5.5 TF-A-002

Technical Spikeでは、

> 「検出できなかった」ことを「残存0件」と誤判定しない

ことが重要なFindingとなった。

Design矛盾ではないためDesign Gapとはしないが、MVP Test Specificationで以下を別TestとしてTraceする必要がある。

```text
A. Template Variableを正しく検出できたか
B. Render後のUnresolved Variableが0件か
```

Bだけを確認してAを省略してはならない。

---

# 6. Version / Referenceレビュー

## Requirements → Design

- Requirements本文中の「具体方式はMVP Designで定義」：整合
- Body処理方式：Design D16へ反映済み
- Requirements §34：CR-006として更新必要

## Design → Requirements

- 文書情報：MVP Requirements v0.1.5を参照
- §2：MVP Requirements v0.1.5を参照
- Active Body Requirement：FR-RENDER-BODY-002参照
- 過去版番号は更新履歴としてのみ存在

問題なし。

## Technical Spike → Requirements / Design

Technical Spike Aの上位Requirements v0.1.4、上位Design v0.1.2は**Spike実施時点の検証Baseline**を示すため、そのまま保持する。

CLOSED文書を現在版へ書き換えない。

Spike内の「次アクション」もClose時点の履歴として扱う。

---

# 7. Requirement領域別Coverage

| Requirements領域 | Design Coverage | 判定 |
|---|---|---|
| OFT参照 / 不存在 | Settings / Outlook Adapter / Fail Fast | △ CR-001 |
| Variable記法 / Case | Template Scanner / Dictionary / Renderer | OK |
| Invalid Variable Syntax | Scanner / Configuration Validator | △ CR-001 |
| Template Scan | Template Scanner / BodyText | OK |
| Template Sync | Sync Engine | △ CR-004 |
| VariableDefinition | Excel Table / Data Access | △ CR-004 / CR-005 |
| Required | Configuration Validator / Input Validator | OK |
| Text | TextBox | OK（Implementationで1行設定確認） |
| Date | Input Validator / Value Formatter | OK |
| Select | ComboBox / OptionMaster | △ CR-003 |
| UserForm | UserForm Generator | OK |
| SortOrder | Data Access / UserForm Generator | OK |
| Input保持 / Clear | Input State | OK |
| Validation | Input Validator / UI | OK |
| Subject置換 | Subject Renderer | OK |
| Body置換 / 書式 | Outlook Adapter / WordEditor | OK |
| Unresolved | Unresolved Checker | △ CR-002 |
| Outlook Display / No Send | Outlook Adapter | OK |
| Error / Safety | Result Model / UI / Fail Fast | △ CR-001 / CR-002 |
| NFR Standardization | Config-driven architecture | OK |
| NFR Maintainability | Responsibility separation | OK |
| NFR Observability | Result / UI | OK after CR-002 |
| NFR Safety | Fail Fast | OK after CR-001 |
| NFR Usability | UserForm | OK |
| NFR Extensibility | Lightweight separated components | OK |

---

# 8. Requirement Gap判定

今回のFindingはいずれも既存Requirementsから直接導出できる。

新しい利用者向け振る舞い・制約を決める必要はない。

```text
Requirement Gap：なし
```

対応分類：

```text
CR-001〜005
→ Design completeness / clarification

CR-006
→ Document Consistency Patch
```

---

# 9. 最終Baseline判定

現状：

```text
MVP Requirements v0.1.5
+
MVP Design v0.1.3
+
Technical Spike A v0.2 CLOSED
```

はTechnical Directionとしては整合している。

ただし、Test Specificationへ進む前にCR-001〜006を反映することを推奨する。

修正後想定：

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.4
+
Technical Spike A v0.2 CLOSED
        ↓
MVP Test Specification v0.1
```

Technical Spike AはCLOSED文書のため版更新しない。

---

# 10. レビュー完了条件

以下を修正後に再確認する。

- [ ] メール生成直前に現在OFTを再Scan / Configuration Checkする
- [ ] OFT不存在時に生成開始しない
- [ ] Invalid Variable Syntaxが生成直前にもBlockされる
- [ ] Unresolved Variable一覧をResultとして返せる
- [ ] Selectの自由入力が禁止される
- [ ] VariableDefinition自動列の更新規則が定義される
- [ ] Unused通常非表示 / 確認可能の責務が明示される
- [ ] Requirements §34が現在地に更新される
- [ ] TF-A-002をTest Specificationへ引き継ぐ
- [ ] Requirement Gapを新規発行していない

