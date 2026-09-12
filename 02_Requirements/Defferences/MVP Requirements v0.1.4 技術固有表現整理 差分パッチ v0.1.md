# MVP Requirements v0.1.4 技術固有表現整理 差分パッチ v0.1

## 1. パッチ情報

| 項目 | 内容 |
|---|---|
| パッチ名 | MVP Requirements v0.1.4 技術固有表現整理 差分パッチ |
| パッチバージョン | v0.1 |
| 対象文書 | `MVP Requirements v0.1.4 日本語版.md` |
| 適用後想定バージョン | `MVP Requirements v0.1.5 日本語版.md` |
| 起点 | `Technical Spike A 実施仕様書 v0.2 日本語版_CLOSED.md` |
| 起点Decision | Route W：WordEditor採用 |
| 変更分類 | Document Consistency Patch |
| Requirement Gap | なし |
| 利用者向けRequirement変更 | なし |
| 作成日 | 2026-09-11 |

---

## 2. 目的

Technical Spike A v0.2の結果、MVPのBody処理技術方針としてRoute W：WordEditorが採用された。

一方、`MVP Requirements v0.1.4 日本語版.md` には、現行Designで採用していたHTMLBody方式に由来する以下の技術固有表現が残っている。

- HTML構造
- 複雑なHTML構造
- HTMLタグによるVariable分断
- HTML Encode
- HTMLBody置換方式

これらは利用者から見た要求そのものではなく、Design / Implementation上の実現方式に依存する表現である。

本Patchでは、**既存の利用者向けRequirementおよび保証範囲を変更せず、技術方式に依存しない表現へ整理する。**

また、Technical Spike A完了後の現在地に合わせて、§34「次工程」を更新する。

---

## 3. パッチ方針

本Patchでは以下を原則とする。

1. 利用者から見た振る舞いは変更しない。
2. Route W：WordEditorという具体的技術方式をFunctional Requirement本文へ直接書かない。
3. HTMLBody方式に依存していた表現は、利用者から観測可能な保証内容へ置き換える。
4. 既存のMVP保証対象外範囲は、意味を変えず技術非依存表現へ置き換える。
5. Technical Spike Aで不要となったHTML Encode実装責務はRequirementsの後続工程引継ぎから削除する。
6. `Classic Outlook`、`Excel Desktop + VBA`、`.oft` 等のMVPプラットフォーム制約は変更しない。
7. v0.1.4までの更新履歴は履歴として保持し、過去の記録を書き換えない。

---

## 4. 技術固有表現の監査結果

| 対象 | 現行表現 | 判定 | Patch方針 |
|---|---|---|---|
| FR-RENDER-BODY-002 | HTML構造を破壊しない | 技術方式依存 | 「本文を破損させず、入力値を意図した文字列として反映」へ変更 |
| FR-RENDER-BODY-002 | 複雑なHTML構造 | 技術方式依存 | 「代表的な基本書式を超える複雑な本文レイアウト・装飾」へ変更 |
| FR-RENDER-BODY-002 | HTMLタグ等によるVariable分断 | 技術方式依存 | 利用者操作として観測可能な「Variable文字列の一部分だけに異なる書式を設定したケース」へ変更 |
| FR-RENDER-BODY-002 | HTML Encode責務 | Route H固有 | 削除し、具体的なBody置換方式はDesignへ委ねる |
| AC-017 | HTML構造 / HTMLタグ分断の保証対象外記述 | 技術方式依存・重複 | FR-RENDER-BODY-002への参照へ一本化 |
| §32.1 | HTMLBody置換方式 | Route H固有 | 技術非依存のBody処理方式へ変更 |
| §32.2 | HTML Encode関数 | Route H固有 | 削除 |
| §34 | Technical Spike前の次工程 | 現在地と不整合 | Spike完了後の工程へ更新 |
| Classic Outlook / `.oft` / Excel Desktop + VBA | プラットフォーム制約 | Requirementsとして有効 | 変更なし |
| `Display` | MVPの処理責任境界 | Requirementsとして有効 | 変更なし |
| UserForm | MVPの利用UI | Requirementsとして有効 | 変更なし |
| Outlook Object Model | §32.1のDesign引継ぎ事項 | 配置上妥当 | 変更なし |

---

# 5. 差分

## PATCH-REQ-001 文書バージョン更新

### 対象

文書タイトルおよび文書情報。

### Before

```markdown
# MVP Requirements v0.1.4 日本語版
```

```markdown
| バージョン | v0.1.4 |
```

### After

```markdown
# MVP Requirements v0.1.5 日本語版
```

```markdown
| バージョン | v0.1.5 |
```

### 理由

Technical Spike AのTechnical Decisionに基づくDocument Consistency Patchを反映した版として識別するため。

---

## PATCH-REQ-002 v0.1.5更新概要を追加

### 対象

§1 文書情報の直後、既存の「v0.1.4 更新概要」の前。

### Add

```markdown
### v0.1.5 更新概要

v0.1.5では、Technical Spike A v0.2の結果に基づき、Requirements内に残っていたHTMLBody方式固有の表現を技術非依存表現へ整理した。

Technical Spike AではRoute W：WordEditorをMVPのBody処理技術方針として採用したが、本Requirementsでは具体的な実現方式そのものではなく、利用者から見た要求・保証範囲を定義する。

1. FR-RENDER-BODY-002からHTML構造 / HTML Encode等の技術固有表現を除去し、本文の置換結果と書式維持に関する要求へ整理した
2. HTMLタグによるVariable分断の保証対象外表現を、Variable文字列途中へ部分的に異なる書式を設定したケースとして技術非依存化した
3. AC-017の保証対象外記述をFR-RENDER-BODY-002参照へ一本化した
4. §32.1の「HTMLBody置換方式」を技術非依存のBody処理方式へ変更した
5. §32.2からRoute H固有で不要となったHTML Encode関数の実装引継ぎを削除した
6. Technical Spike A完了後の現在地に合わせて§34「次工程」を更新した

本変更はDocument Consistency Patchであり、利用者向けRequirementの追加・削除およびRequirement Gapは発生していない。
```

### 理由

過去のv0.1.4更新履歴を変更せず、今回の変更理由とTechnical Spike AとのTraceabilityを残すため。

---

## PATCH-REQ-003 FR-RENDER-BODY-002 技術非依存化

### 対象

`## 22. Body置換要件`  
`### FR-RENDER-BODY-002`

### Before

```markdown
### FR-RENDER-BODY-002

Body内のVariable置換では、入力値によってHTML構造を破壊せず、Variable置換部分以外の代表的な基本書式を維持する。

MVPで書式維持の確認対象とする代表的な基本書式は以下とする。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

以下はMVPでの書式維持保証対象外とする。

- 埋め込み画像
- 複雑なHTML構造
- 特殊なOutlook固有書式
- `{{VariableName}}` の文字列途中がHTMLタグ等によって分断されるケース

HTML EncodeをBody Renderer側で適用する責務はMVP Designで定義し、具体的なEncode関数はImplementationで具体化する。
```

### After

```markdown
### FR-RENDER-BODY-002

Body内のVariable置換では、入力値を意図した文字列として反映し、本文を破損させることなく、Variable置換部分以外の代表的な基本書式を維持する。

MVPで書式維持の確認対象とする代表的な基本書式は以下とする。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

以下はMVPでの書式維持保証対象外とする。

- 埋め込み画像
- 上記の代表的な基本書式を超える複雑な本文レイアウト・装飾
- 特殊なOutlook固有書式
- `{{VariableName}}` の文字列途中の一部分だけに異なる書式を設定したケース

具体的なBody処理・置換方式はMVP Designで定義する。
```

### 変更理由

#### 1. 「HTML構造」を削除

利用者が必要としているのはHTML内部表現の保全ではなく、

- 入力値が意図した文字列として本文へ反映されること
- メール本文が破損しないこと
- 既存の基本書式が維持されること

である。

したがってRequirementsでは上記の利用者観測可能な振る舞いを定義し、HTML / WordEditor等の内部表現はDesignへ委ねる。

#### 2. 「複雑なHTML構造」を技術非依存化

「複雑なHTML構造」は内部実装上の分類であり、利用者から見た保証境界として不明瞭である。

元の保証範囲を拡大せず、

```text
代表的な基本書式を超える複雑な本文レイアウト・装飾
```

へ置き換える。

#### 3. 「HTMLタグによる分断」を利用者操作へ変換

Technical Spike Aで問題となったHTMLタグ分断は内部現象である。

一方、元Requirementsで保証対象外としていた意図は、

```text
Variable文字列途中へ部分的に異なる書式を設定する特殊ケース
```

を保証しないことにある。

この保証境界を維持するため、技術方式ではなくテンプレート上の状態として記述する。

#### 4. HTML Encode責務を削除

Technical Spike AでRoute W：WordEditorを採用し、HTML Encodeを行わず特殊文字を意図した表示文字列として設定できることを確認した。

HTML EncodeはRoute H固有の実装責務となったためRequirementsから削除する。

---

## PATCH-REQ-004 AC-017 保証対象外記述をRequirement参照へ一本化

### 対象

`### AC-017 Body置換`

### Before

```markdown
### AC-017 Body置換

代表的なOFTを用いたテストにおいて、Body内の全変数を正しく置換でき、Variable置換部分以外についてFR-RENDER-BODY-002で定義した基本書式が維持される。

大文字・小文字のみが異なる記述も、同一VariableNameとして置換できる。

埋め込み画像、複雑なHTML構造、特殊なOutlook固有書式、およびVariable文字列途中がHTMLタグ等で分断されるケースは、本Acceptance CriteriaのPass判定対象外とする。
```

### After

```markdown
### AC-017 Body置換

代表的なOFTを用いたテストにおいて、Body内の全変数を正しく置換でき、Variable置換部分以外についてFR-RENDER-BODY-002で定義した基本書式が維持される。

大文字・小文字のみが異なる記述も、同一VariableNameとして置換できる。

FR-RENDER-BODY-002で書式維持保証対象外としたケースは、本Acceptance CriteriaのPass判定対象外とする。
```

### 理由

保証対象外範囲をFR-RENDER-BODY-002とAC-017の2箇所で重複定義すると、将来片方だけを変更する不整合リスクがある。

Acceptance CriteriaはRequirementの保証境界を参照し、Pass条件のみを定義する。

---

## PATCH-REQ-005 §32.1 HTMLBody置換方式を技術非依存化

### 対象

`### 32.1 MVP Designで具体化する事項`

### Before

```markdown
14. HTMLBody置換方式
15. OFT読み込み処理
16. Outlook Object Model利用方法
17. 設定完了状態の内部判定方式
18. SortOrder同順位時のVariableDefinition行順取得方式
```

### After

```markdown
14. Body処理方式（変数抽出・置換・未置換チェック）
15. OFT読み込み処理
16. Outlook Object Model利用方法
17. 設定完了状態の内部判定方式
18. SortOrder同順位時のVariableDefinition行順取得方式
```

### 理由

RequirementsからMVP Designへ引き継ぐべき内容は、

```text
HTMLBodyをどう置換するか
```

ではなく、

```text
Bodyをどの内部モデルで扱い、
変数抽出・置換・未置換チェックをどう成立させるか
```

である。

具体的なWordEditor / Word Object Model / Range.Find等はReopenするMVP Designで定義する。

---

## PATCH-REQ-006 §32.2 HTML Encode関数の引継ぎを削除

### 対象

`### 32.2 Implementationで具体化する事項`

### Before

```markdown
1. Validationエラー強調の具体的な表示方式・色
2. 曜日表記生成の具体的なVBA実装
3. HTML Encode関数の具体実装
4. エラーコード体系および例外捕捉の具体コード
5. Unused表示切替の具体的なUI実装
6. 同期結果UIの具体表示
7. OFT不存在時の具体的な復旧UI
```

### After

```markdown
1. Validationエラー強調の具体的な表示方式・色
2. 曜日表記生成の具体的なVBA実装
3. エラーコード体系および例外捕捉の具体コード
4. Unused表示切替の具体的なUI実装
5. 同期結果UIの具体表示
6. OFT不存在時の具体的な復旧UI
```

### 理由

Route WではHTML EncodeをBody処理に使用しないため、Implementationへ引き継ぐべき未決事項ではない。

WordEditor方式の具体コードはMVP Designの改訂結果を受けてImplementationで具体化するため、本Requirementsから新しいWordEditor固有項目を追加しない。

---

## PATCH-REQ-007 §34 次工程を現在地へ更新

### 対象

`## 34. 次工程`

### Before

```markdown
## 34. 次工程

本Requirements確定後、次工程としてMVP Designへ変更内容を反映し、Requirements / Designの最終整合性を確認する。

MVP Designでは、特に以下の責務・処理経路との整合を確認する。

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
```

### After

````markdown
## 34. 次工程

Technical Spike A v0.2はPASSで完了し、MVPのBody処理技術方針としてRoute W：WordEditorを採用した。

本RequirementsへのDocument Consistency Patch反映後、Technical Spike AのTechnical DecisionをDesignへ反映するため、`MVP Design v0.1.2` をReopenする。

次工程は以下とする。

```text
MVP Requirements v0.1.5
        ↓
MVP Design v0.1.2 Reopen / 改訂
        ↓
Technical Spike A Technical Decision反映
Route W：WordEditor
        ↓
Requirements / Design / Technical Spike
最終整合性レビュー
        ↓
MVP Test Specification v0.1
```

MVP Design改訂では、特に以下の責務・処理経路との整合を確認する。

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

Requirementsでは利用者から見た要求・保証範囲を維持し、WordEditor / Word Object Model等の具体的なBody処理方式はMVP Designで定義する。
````

### 理由

現行§34はTechnical Spike A実施前の工程状態を前提としている。

Technical Spike Aは既にCLOSED / PASSであり、次に必要なのはDesign ReopenとTechnical Decision反映であるため、現在地に合わせて更新する。

---

# 6. 変更しない項目

今回のPatchでは以下を変更しない。

| 項目 | 理由 |
|---|---|
| FR-RENDER-BODY-001 | 「Body内Variableを置換する」という利用者要求は変更なし |
| FR-UNRESOLVED-001 / 002 | 未置換Variableを残したメールを生成しない要求は技術方式によらず有効 |
| FR-SCAN-001〜003 | Subject / BodyからVariableを抽出する要求は変更なし |
| FR-VAR-004 | Case Insensitive要件は変更なし |
| Classic Outlook | MVP対象プラットフォームとして確定済み |
| Excel Desktop + VBA | MVP実行環境として確定済み |
| `.oft` | MVPテンプレート形式として確定済み |
| Outlook MailItem / Display | Outlook連携と処理責任境界として現行Requirementsで確定済み |
| 基本書式8項目 | Technical Spike A Route Wで成立を確認しており保証範囲変更なし |
| 埋め込み画像 | MVP書式維持保証対象外を維持 |
| 特殊なOutlook固有書式 | MVP書式維持保証対象外を維持 |

---

# 7. Requirement Gap判定

```text
Technical Spike A
Route W：WordEditor採用
        ↓
利用者から見た振る舞い・保証範囲を変更する必要があるか？
        ↓
       No
        ↓
Requirement Gapなし
        ↓
Document Consistency Patch
```

今回の変更では以下を追加しない。

- 新しいVariable記述ルール
- Variable配置制約
- 表内利用制約
- 箇条書き内利用制約
- テンプレート作成時の追加操作
- 基本書式保証範囲の縮小

したがって、新しいRequirement IDおよびRequirement Gapは発生させない。

---

# 8. 適用後の整合性確認項目

本Patchを `MVP Requirements v0.1.4` へ適用してv0.1.5を作成した後、最低限以下を確認する。

- [ ] 文書タイトルと文書情報がv0.1.5になっている
- [ ] v0.1.5更新概要が追加されている
- [ ] v0.1.4以前の更新履歴を変更していない
- [ ] FR-RENDER-BODY-002に `HTML構造` が残っていない
- [ ] FR-RENDER-BODY-002に `HTML Encode` が残っていない
- [ ] FR-RENDER-BODY-002の基本書式8項目が維持されている
- [ ] Variable途中書式変更ケースの保証対象外境界が維持されている
- [ ] AC-017がFR-RENDER-BODY-002の保証境界を参照している
- [ ] §32.1に `HTMLBody置換方式` が残っていない
- [ ] §32.2に `HTML Encode関数` が残っていない
- [ ] FR-UNRESOLVED-001 / 002の要求内容を変更していない
- [ ] §34がTechnical Spike A完了後の工程を示している
- [ ] Requirement Gapを新規作成していない
- [ ] WordEditor固有の実装詳細をFunctional Requirement本文へ混入させていない

---

# 9. Patch適用後の次アクション

```text
本Patchレビュー
        ↓
MVP Requirements v0.1.5へ反映
        ↓
Requirements単体整合性確認
        ↓
MVP Design v0.1.2 Reopen
        ↓
Route W：WordEditor前提へDesign改訂
        ↓
Requirements / Design / Technical Spike
最終整合性レビュー
        ↓
MVP Test Specification v0.1
```

本PatchではMVP Designの具体的な改訂内容までは決定しない。

Design Reopen時に、Technical Spike Aの結果をEvidenceとして少なくとも以下を再設計対象とする。

- Outlook Adapter
- Template Scanner
- Render Engine
- Body Renderer
- Unresolved Checker
- MailItem / Inspector / WordEditor取得シーケンス
- HTML Encode責務
- RISK-DES-001

---

# 10. Patch完了判定

本Patchの意図は以下である。

```text
利用者要求
    維持
     │
     ▼
HTMLBody固有表現
    除去 / 技術非依存化
     │
     ▼
Technical Decision
Route W：WordEditor
     │
     ▼
具体技術方式はDesignへ
```

**Patch判定：適用可能**

- Requirement Gap：なし
- Functional Requirement追加：なし
- Functional Requirement削除：なし
- 保証範囲変更：なし
- Document Consistency Patch：あり
- Design Reopen：次工程
