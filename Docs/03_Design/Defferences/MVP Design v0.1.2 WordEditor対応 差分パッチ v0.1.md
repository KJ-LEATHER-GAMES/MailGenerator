# MVP Design v0.1.2 WordEditor対応 差分パッチ v0.1

## 1. パッチ情報

| 項目 | 内容 |
|---|---|
| パッチ名 | MVP Design v0.1.2 WordEditor対応 差分パッチ |
| パッチバージョン | v0.1 |
| 対象文書 | `MVP Design v0.1.2 日本語版.md` |
| 適用後想定バージョン | `MVP Design v0.1.3 日本語版.md` |
| 上位Requirements | `MVP Requirements v0.1.5 日本語版.md` |
| 起点Spike | `Technical Spike A 実施仕様書 v0.2 日本語版_CLOSED.md` |
| 起点Technical Decision | Route W：WordEditor |
| 起点Finding | TF-A-001 / TF-A-002 |
| 変更分類 | Design Reopen / Technical Decision反映 |
| Requirement Gap | なし |
| 作成日 | 2026-09-11 |

---

## 2. Reopen理由

`MVP Design v0.1.2` では、OFT Bodyを `MailItem.HTMLBody` として取得し、以下のCore LogicでHTML文字列を直接処理する方式を採用していた。

```text
HTMLBody
├─ Template Scanner
├─ Body Renderer + HTML Encode
└─ Unresolved Checker
```

Technical Spike A v0.2では、同一OFTを用いて以下を比較した。

```text
Route H：HTMLBody
vs
Route W：Inspector.WordEditor / Word Document
```

実測の結果、Route Hでは通常作成したOFTでもVariable内部へHTMLタグが挿入され、以下が成立しなかった。

- Variable検出
- Template Scan
- Body置換
- Unresolved Check

一方、Route WではTSA-001〜TSA-010のMandatory Gateをすべて満たした。

Technical Spike Aは以下でCLOSEDとなった。

```text
Result      : PASS
Adopted     : Route W / WordEditor
Requirements: Document Consistency Patch
Design      : Reopen
Req. Gap    : None
```

したがって、本Patchで `MVP Design v0.1.2` をReopenし、Body処理をWordEditor方式へ改訂する。

---

## 3. Design差分レビューの結論

単純な以下の置換だけではDesignとして不十分である。

```text
HTMLBody
↓
WordEditor
```

理由は、現行Designが次の責務境界を持つためである。

> Core LogicからExcelセルやOutlook Object Modelを直接操作しない。

WordEditor / Word Document / Rangeは外部COM Object Modelであり、Template Scanner、Body Renderer、Unresolved Checkerへ直接渡すと、Core LogicへCOM依存が漏れる。

本PatchではMVP最小負荷を維持し、新しいInterface / Port / Adapter層を追加せず、以下を採用する。

```text
Outlook Adapter
  ├─ MailItem Lifecycle
  ├─ Inspector / WordEditor取得
  ├─ Word Document本文Text取得
  └─ Word RangeによるBody置換
            │
            ├── BodyText → Template Scanner
            └── BodyText → Unresolved Checker
```

### 3.1 採用する責務境界

- `Inspector.WordEditor`
- Word `Document`
- Word `Range`
- `Range.Find`
- `Range.Text`

へのアクセスは **Outlook Adapterへ集約する**。

Template Scanner / Unresolved Checkerへ渡すBody情報は、Word Objectそのものではなく、

```text
BodyText
```

という表示文字列ベースのSnapshotとする。

Bodyの物理置換はWord Object Model依存が不可避であるため、Core Logicの `Body Renderer` から分離し、Outlook Adapterの責務へ移す。

### 3.2 Body Rendererの扱い

現行の独立 `Body Renderer` は、HTMLBody文字列をCore Logicで置換するために必要だった。

Route Wでは、

```text
WordEditor
↓
Word Document
↓
Range.Find
↓
Range.Text
```

によってMailItem本文を直接編集するため、純粋な文字列Rendererとして独立させる実質的な責務がなくなる。

したがってMVPでは、

> **独立Body Rendererコンポーネント / `modBodyRenderer` を廃止し、Bodyの物理置換をOutlook Adapterへ統合する。**

新しい `WordBodyAdapter` 等は追加しない。

これは責務境界を維持しつつModule数を増やさない、MVP最小変更とする。

---

# 4. 差分一覧

| Patch ID | 対象 | 主変更 |
|---|---|---|
| PATCH-DES-001 | 文書情報 / 更新概要 | v0.1.3、Requirements v0.1.5、Technical Spike A反映 |
| PATCH-DES-002 | §2 文書目的 | Requirements参照更新 |
| PATCH-DES-003 | §4 全体アーキテクチャ | Body RendererをCoreから外し、WordEditor依存をInfrastructureへ集約 |
| PATCH-DES-004 | §5 コンポーネント責務 | Outlook Adapter / Scanner / Body処理責務更新 |
| PATCH-DES-005 | §12 MailItem Lifecycle | HTMLBody取得・設定をWordEditor / BodyText方式へ変更 |
| PATCH-DES-006 | §13 Outlook Adapter | WordEditor / Range操作責務を追加 |
| PATCH-DES-007 | §14 Template Scanner | InputをSubject / BodyTextへ変更 |
| PATCH-DES-008 | §17 Configuration Validator | HTMLBody取得表現をBodyTextへ変更 |
| PATCH-DES-009 | §21 Value Formatter | HTML Encode記述を削除 |
| PATCH-DES-010 | §22 Render Engine | Body Renderer / HTML Encodeを廃止しWordEditor置換へ変更 |
| PATCH-DES-011 | §23 Unresolved Checker | HTMLBodyではなくBodyTextを対象化 |
| PATCH-DES-012 | §25 主要処理シーケンス | Scan / Mail生成をWordEditor方式へ変更 |
| PATCH-DES-013 | §26 VBA構成 | `modBodyRenderer` を削除 |
| PATCH-DES-014 | §27 Design Decision | Route W Technical Decisionを正式追加 |
| PATCH-DES-015 | §28 Traceability | HTML保護を削除、Body置換責務更新 |
| PATCH-DES-016 | §29 実装時確認事項 | HTML Encode削除、Word Object Model実装事項追加 |
| PATCH-DES-017 | §30 RISK-DES-001 / 002 | HTMLBodyリスクをCLOSED化、COMリスクを更新 |
| PATCH-DES-018 | §31 完了条件 | Requirements v0.1.5 / Spike Decision反映を追加 |
| PATCH-DES-019 | §32 次工程 | Technical Spike Aを完了済みへ更新 |

---

# 5. 詳細差分

## PATCH-DES-001 文書情報 / v0.1.3更新概要

### 対象

- 文書タイトル
- §1 文書情報
- 更新概要

### Before

```markdown
# MVP Design v0.1.2 日本語版
```

```markdown
| バージョン | v0.1.2 |
| 要件文書 | MVP Requirements v0.1.3 日本語版 |
```

### After

```markdown
# MVP Design v0.1.3 日本語版
```

```markdown
| バージョン | v0.1.3 |
| 要件文書 | MVP Requirements v0.1.5 日本語版 |
```

既存の `v0.1.2 更新概要` の前へ以下を追加する。

```markdown
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
9. 次工程をRequirements / Design / Technical Spike整合性レビュー → MVP Test Specification v0.1へ更新

本変更は内部技術方式の変更であり、新しい利用者向けRequirement Gapは発生していない。
```

### 理由

Technical Spike AのTechnical DecisionをDesign Baselineへ正式反映し、上位RequirementsとのActive参照を最新化する。

---

## PATCH-DES-002 §2 文書目的のRequirements参照更新

### Before

```markdown
本書は、`MVP Requirements v0.1.3` を満たすためのMVP基本設計を定義する。
```

### After

```markdown
本書は、`MVP Requirements v0.1.5` を満たすためのMVP基本設計を定義する。
```

### 理由

Active Requirements Baselineをv0.1.5へ更新する。

---

## PATCH-DES-003 §4 全体アーキテクチャ

### 4.1 採用構成

#### Before

```text
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

#### After

```text
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

#### Before

```markdown
Core LogicからExcelセルやOutlook Object Modelを直接操作しない。
```

#### After

```markdown
Core LogicからExcelセル、Outlook Object Model、Word Object Modelを直接操作しない。

MailItem / Inspector / WordEditor / Word Document / Word Rangeへの依存はInfrastructureのOutlook Adapterへ集約する。

Template ScannerおよびUnresolved CheckerがBodyを評価する場合は、Outlook AdapterがWord Documentから取得した表示文字列ベースのBodyTextを入力として使用する。
```

### 理由

Route Wを採用しても、既存の外部COM依存局所化原則を維持するため。

---

## PATCH-DES-004 §5 コンポーネント責務

### Before

```markdown
| Outlook Adapter | OFT読込、MailItem生成、Subject / HTMLBody設定、Display |
| Template Scanner | `{{...}}` 候補抽出、VariableName妥当性判定、出現位置統合 |
...
| Subject Renderer | Subject変数置換 |
| Body Renderer | HTMLBody変数置換、HTML Encode |
| Unresolved Checker | Render後の未置換変数検出 |
```

### After

```markdown
| Outlook Adapter | OFT読込、MailItem生成、Subject取得・設定、Inspector / WordEditor取得、BodyText取得、Word RangeによるBody変数置換、Display、保存なしClose |
| Template Scanner | Subject / BodyTextからの `{{...}}` 候補抽出、VariableName妥当性判定、出現位置統合 |
...
| Subject Renderer | Subject変数置換 |
| Unresolved Checker | Render後のSubject / BodyTextから未置換変数検出 |
```

`Body Renderer` 行は削除する。

### 理由

Bodyの物理置換はWord Object Modelに依存するため、独立Core LogicではなくOutlook Adapterへ集約する。

---

## PATCH-DES-005 §12 OFT / MailItemライフサイクル

### 12.1 Scan時

#### Before

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

#### After

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

#### Before

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

#### After

```text
OFT
↓
生成用 MailItem生成
↓
Outlook Adapter
↓
Inspector / WordEditor取得
↓
Value Format
↓
Subject Render
↓
Subject設定
↓
Word Range Body Render
↓
Subject / BodyText再取得
↓
Unresolved Check
↓
Display
```

### 12.3 設計原則へ追記

```markdown
Inspector / WordEditorはOutlook Adapter内部で取得し、Core LogicへCOM Objectを公開しない。

Technical Spike Aでは、Display前のWordEditor取得、Scan後の保存なしClose、およびDraft / Inspector残存なしを確認済みである。

BodyのWord Range編集は生成用MailItemそのものへ反映されるため、HTMLBody方式のような「Body文字列を再設定する」工程は持たない。
```

---

## PATCH-DES-006 §13 Outlook Adapter設計

### 13.1 方針

#### Before

```markdown
Classic Outlook Object Modelへの依存は軽量Adapterへ集約する。
```

#### After

```markdown
Classic Outlook Object Modelおよび、OutlookのWordEditor経由で利用するWord Object Modelへの依存は軽量なOutlook Adapterへ集約する。

MVPでは新しいPort / Interface / WordEditor専用Adapterは追加せず、MailItem LifecycleとBodyのWord Range操作を既存Outlook Adapterへまとめる。
```

### 13.2 責務候補

#### Before

```text
CreateMailFromTemplate()
ReadTemplateSubject()
ReadTemplateHtmlBody()
SetSubject()
SetHtmlBody()
DisplayMail()
CloseWithoutSave()
```

#### After

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
DisplayMail()
CloseWithoutSave()
```

補足を追加する。

```markdown
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
```

### 13.3 禁止事項

#### Before

```markdown
以下のコンポーネントからOutlook Object Modelを直接操作しない。

- Template Scanner
- Configuration Validator
- Input Validator
- Value Formatter
- Renderer
```

#### After

```markdown
以下のコンポーネントからOutlook Object Model / Word Object Modelを直接操作しない。

- Template Scanner
- Configuration Validator
- Input Validator
- Value Formatter
- Subject Renderer
- Unresolved Checker

Inspector / WordEditor / Word Document / Word RangeはOutlook Adapter内部に閉じ込める。
```

---

## PATCH-DES-007 §14 Template Scanner設計

### 14.1 2段階処理

#### Before

```text
Subject / HTMLBody
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
```

#### After

```text
Subject / BodyText
        ↓
Candidate Scan
        ↓
VariableName Validation
        ↓
Valid / Invalid
```

### 14.2 Candidate Scanへ追記

```markdown
BodyのCandidate ScanはHTMLBodyではなく、Outlook AdapterがWord Documentから取得したBodyTextを対象とする。

BodyTextは表示文字列ベースであり、HTMLタグを含む内部HTML表現をScanner入力としない。

Technical Spike Aでは、HTMLBody上でタグ分断されたVariableもWord Documentの表示文字列では連続して検出できることを確認済みである。
```

### 14.6 TemplateScanResultへ追記

```markdown
Template ScannerはWord Document Objectを保持しない。

Scanner入力はSubject / BodyTextという文字列Snapshotとし、後続処理へOutlook / Word COM依存を伝播させない。
```

---

## PATCH-DES-008 §17 Configuration ValidatorのHTMLBody表現を更新

### 対象

Configuration Validatorの責務境界説明。

### Before

```markdown
Configuration Validator自身は、OFTを開く処理、Subject / HTMLBodyを取得する処理、Variable候補の抽出、VariableName SyntaxのRegex判定を行わない。
```

### After

```markdown
Configuration Validator自身は、OFTを開く処理、Subject / BodyTextを取得する処理、Variable候補の抽出、VariableName SyntaxのRegex判定を行わない。
```

### 理由

Bodyアクセス方式をWordEditorへ変更してもValidator責務は変えず、用語のみActive Designへ合わせる。

---

## PATCH-DES-009 §21 Value FormatterからHTML Encode記述を削除

### 対象

§21.2 Type別の末尾。

### Before

```markdown
HTML EncodeはValue Formatterの責務に含めない。
```

### After

```markdown
Outlook / Word Object Modelへの反映処理はValue Formatterの責務に含めない。

Value Formatterは、Subject / Bodyへ共通して使用可能な表示用文字列の生成までを責務とする。
```

### 理由

HTML Encode自体が採用Routeでは不要となったため、より上位の責務境界へ一般化する。

---

## PATCH-DES-010 §22 Render Engine設計

### 22.1 全体フロー

#### Before

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

#### After

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

現行記述を維持する。

```markdown
Formatted ValueをSubject内の対象VariableへCase Insensitiveで全出現箇所置換する。
```

以下を追記する。

```markdown
Subject RendererはPlain Text文字列としてSubjectを処理し、完成したSubjectをOutlook Adapter経由でMailItemへ設定する。
```

### 22.3 Body Rendering

現行 `### 22.3 Body Renderer` を以下へ置換する。

```markdown
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
```

### 22.4 HTML Encode

章全体を削除する。

#### 削除対象

```markdown
### 22.4 HTML Encode

少なくともユーザー入力によってHTML構造が破壊されないようにする。

具体的なEncode関数はImplementation時に定義する。
```

### 理由

Route WではHTML文字列を直接編集しないため、HTML Encodeは不要となる。

---

## PATCH-DES-011 §23 未置換変数チェック設計

### 23.2 対象

#### Before

```markdown
- Subject
- HTMLBody
```

#### After

```markdown
- Subject
- BodyText
```

### 23.3 判定へ追記

```markdown
BodyTextは、Body置換後にOutlook AdapterがWord Documentから再取得した表示文字列Snapshotを使用する。

Unresolved Checker自身はWord Document / Rangeを直接検索しない。

Template ScannerとUnresolved Checkerで同じ表示文字列モデルを使用することで、

```text
検出時：BodyText
置換後確認：BodyText
```

の一貫性を持たせる。
```

### 理由

Technical Spike AでRoute HのUnresolved Checkerはタグ分断Variableを検出できないFalse Negativeを起こした。

Route Wでは表示文字列ベースで正常系0件、異常系の残存Variable検出が成立したため、このモデルをDesignへ反映する。

---

## PATCH-DES-012 §25 主要処理シーケンス

### 25.2 UserForm起動

#### Before抜粋

```text
Outlook Adapter
↓
Scan用MailItem生成
↓
Subject / HTMLBody取得
↓
Template Scanner
```

#### After

```text
Outlook Adapter
↓
Scan用MailItem生成
↓
Inspector / WordEditor取得
↓
Subject / BodyText取得
↓
Template Scanner
```

後続は維持する。

```text
Candidate Scan
↓
VariableName Validation
↓
TemplateScanResult
↓
Scan用MailItemを保存せず終了 / COM参照解放
```

### 25.3 メール生成

#### Before

```text
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
```

#### After

```text
Outlook Adapter
↓
生成用MailItem作成
↓
Inspector / WordEditor取得
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
未置換あり？
├─ Yes
│   ↓
│ MailItem表示せずError
│   ↓
│ 保存せずClose
│
└─ No
    ↓
Display
    ↓
ツール責任範囲終了
```

### 追記

```markdown
BodyはWord Range編集によって生成用MailItemへ直接反映されるため、Render後にBody全文をMailItemへ再設定する処理は行わない。

未置換Variableが検出された場合は利用者へMailItemをDisplayせず、生成用MailItemを保存せず終了する。
```

---

## PATCH-DES-013 §26 VBA構成

### 26.3 Core Logic

#### Before

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

#### After

```text
modTemplateScanner
modSyncEngine
modConfigurationValidator
modInputValidator
modValueFormatter
modSubjectRenderer
modUnresolvedChecker
```

`modBodyRenderer` を削除する。

### 26.4 Infrastructure

現行を維持する。

```text
modVariableDefinitionData
modOptionMasterData
modSettingsData
modOutlookAdapter
```

新しいWordEditor専用ModuleはMVPでは追加しない。

### 26.6 設計上の注意

現行の以下の例を削除する。

```text
modSubjectRenderer
+
modBodyRenderer
→ modRenderer
```

以下へ置換する。

```markdown
Outlook Adapter内部のWordEditor関連処理がImplementation時に過大化した場合のみ、責務を再評価する。

ただし、将来の複雑化を先取りしてMVP段階からWordEditor専用Class / Adapterを追加しない。
```

### 理由

Technical Route変更によって責務が消えたModuleを形式的に残さない。

---

## PATCH-DES-014 §27 Design Decision一覧

### 既存Decision更新

#### D13

Before:

```markdown
| D13 | Render | Formatterと出力先処理を分離 |
```

After:

```markdown
| D13 | Render | Formatter / Subject文字列処理 / WordEditor Body反映を分離 |
```

#### D14

Before:

```markdown
| D14 | Outlook | 軽量Adapter |
```

After:

```markdown
| D14 | Outlook | 軽量AdapterへOutlook / Word Object Model依存を集約 |
```

### 新規Decision追加

```markdown
| D16 | Body処理方式 | Route W：Inspector.WordEditor + Word Range.Find / Range.Text |
```

### D16判断根拠

Design Decision一覧の後へ以下を追加する。

```markdown
### D16 Body処理方式

Technical Spike A v0.2の結果、Route W：WordEditorを採用する。

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
```

---

## PATCH-DES-015 §28 Requirements Traceability

### Before

```markdown
| Subject置換 | Subject Renderer |
| Body置換 | Body Renderer |
| HTML保護 | Body Renderer |
| 未置換チェック | Unresolved Checker |
| Outlook Display | Outlook Adapter |
```

### After

```markdown
| Subject置換 | Subject Renderer / Outlook Adapter |
| Body置換 | Outlook Adapter |
| Body書式維持 | Outlook Adapter / WordEditor Body Rendering |
| 未置換チェック | Unresolved Checker / Outlook Adapter（BodyText取得） |
| Outlook Display | Outlook Adapter |
```

### 理由

Requirements v0.1.5ではHTML保護という技術固有Requirementは存在しない。

Body書式維持という利用者要求と、Design上のWordEditor処理の対応へ変更する。

---

## PATCH-DES-016 §29 実装時の確認事項

### 削除

```markdown
- HTML Encode関数
```

### 追加

```markdown
- Word Object Modelの参照設定 / Late Binding方針
- `Range.Find` の具体的な検索Range更新ループ
- Word / Outlook COM参照解放の具体コード
- WordEditor取得失敗時のError捕捉・Result変換
```

### 既存項目の修正

Before:

```markdown
- Outlook COM参照解放の具体コード
```

After:

```markdown
- Outlook / Word COM参照解放の具体コード
```

重複しないよう1項目へ統合する。

### 理由

Technical Decisionで方式は決定したが、具体的なVBAの参照方法・Range制御・COM解放はImplementation Detailとして残す。

---

## PATCH-DES-017 §30 設計上のリスク

### RISK-DES-001

現行章を削除せず、TraceabilityのためCLOSEDとして更新する。

### Before

```markdown
### RISK-DES-001 HTMLBody内のVariable表現

OFTのHTMLBody内部で `{{VariableName}}` がHTMLタグ等により分断された場合、単純な文字列検索・置換では検出できない可能性がある。

MVP実装時に、実際のOFTで以下を確認する。

- 通常入力した `{{VariableName}}` がHTMLBody内で連続文字列として保持されること
- 書式設定により変数文字列が分断されないこと

MVP Requirements v0.1.3では、Variable文字列途中がHTMLタグ等で分断されるケースをMVP保証対象外としている。Technical Spikeでは、通常入力したVariableが実OFTのHTMLBody内で連続文字列として保持され、現在のScanner / Renderer方式が通常利用ケースで成立することを確認する。

上記を超える新しい利用者向けテンプレート記述制約が必要になった場合は、Design内で決定せずRequirement Gapとして扱う。
```

### After

```markdown
### RISK-DES-001 HTMLBody内のVariable表現 — CLOSED

Technical Spike A v0.2で本リスクの実発生を確認した。

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
```

### RISK-DES-002

#### Before

```markdown
### RISK-DES-002 Outlook COM

Outlook MailItemの生成・解放・Displayに関するCOMエラーをInfrastructure層で適切に捕捉する必要がある。
```

#### After

```markdown
### RISK-DES-002 Outlook / Word COM

Outlook MailItemの生成・解放・Displayに加え、Inspector / WordEditor / Word Document / Range操作に関するCOMエラーをInfrastructure層で適切に捕捉する必要がある。

Technical Spike Aでは以下を確認済みである。

- Display前のWordEditor取得成功
- Scan用MailItemの保存なしClose成功
- Draft残存なし
- Inspector残存なし

したがってWordEditor採用自体をBlocking Riskとはしない。

Implementationでは、Object取得失敗、Range操作失敗、COM参照解放失敗をError / Result Modelへ変換する。
```

---

## PATCH-DES-018 §31 MVP Design完了条件

### Before

```markdown
本Design v0.1.2は、以下を満たした時点で基本設計完了とする。

- Requirements v0.1.3の主要要件に対応するコンポーネントが定義されている
...
```

### After

```markdown
本Design v0.1.3は、以下を満たした時点で基本設計完了とする。

- Requirements v0.1.5の主要要件に対応するコンポーネントが定義されている
- UI / Core / Excel / Outlook / WordEditorの責務境界が定義されている
- Template Scan / Sync / UserForm / Render / Outlook Displayの主要フローが定義されている
- Excelテーブル構造が定義されている
- Case Insensitive処理方針が定義されている
- Input State保持方式が定義されている
- Error伝播方針が定義されている
- Design Questions 15件が反映されている
- Technical Spike AのRoute W：WordEditor Technical Decisionが反映されている
- TF-A-001へのDesign対応が反映されている
- 新規Requirement Gapが残っていない
```

### 理由

Reopenの完了条件へTechnical Spike Aの反映確認を追加する。

---

## PATCH-DES-019 §32 次工程

### Before

```text
MVP Requirements v0.1.3
        ↓
MVP Design v0.1.2
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

### After

```text
MVP Requirements v0.1.5
        ↓
MVP Design v0.1.3
Route W：WordEditor反映
        ↓
Requirements / Design / Technical Spike A
最終整合性レビュー
        ↓
MVP Test Specification v0.1
        ↓
Technical Spike B / C
        ↓
Implementation Plan v0.1
        ↓
VBA実装
```

冒頭文も以下へ変更する。

```markdown
MVP Design v0.1.3への改訂後は、Requirements / Design / Technical Spike Aの最終整合性を確認し、MVP Test Specification v0.1を作成する。
```

### テスト優先項目

現行の以下を削除する。

```markdown
- HTML Encode
```

以下を追加・整理する。

```markdown
- Subject / Body置換
- Case InsensitiveなBody全出現箇所置換
- Body特殊文字表示
- Body基本書式維持
- 未置換Variable正常系 / 異常系
- WordEditor / MailItem Lifecycle
```

### 理由

Technical Spike Aは既にCLOSED / PASSであり、再度次工程として記載しない。

---

# 6. 変更しないDesign

今回のReopenでは、Technical Spike Aの影響範囲外を変更しない。

| 項目 | 判定 |
|---|---|
| Excel Data Access | 変更なし |
| VariableDefinition | 変更なし |
| OptionMaster | 変更なし |
| Settings | 変更なし |
| Sync Engine | 変更なし |
| Configuration Validation規則 | 変更なし |
| UserForm Generator | 変更なし |
| Input State | 変更なし |
| Input Validation | 変更なし |
| Value FormatterのText / Date / Select規則 | 変更なし |
| Subject RendererのCase Insensitive置換 | 変更なし |
| Error / Result基本方針 | 変更なし |
| Scan用 / 生成用MailItem分離 | 変更なし |
| 自動送信しない責任境界 | 変更なし |
| Classic Outlook対象 | 変更なし |
| `.oft` テンプレート | 変更なし |
| Requirement Gap運用 | 変更なし |

---

# 7. Requirement Gap判定

本Design変更は以下の内部技術方式変更である。

```text
HTMLBody直接処理
        ↓
WordEditor / Word Range処理
```

Technical Spike Aでは、Route Wを成立させるための新しい利用者向けTemplate制約は確認されていない。

また `MVP Requirements v0.1.5` では、HTMLBody / HTML Encode等の技術固有表現を既に技術非依存化している。

したがって、

```text
Requirement Gap：なし
```

とする。

Design内で新しい利用者向け制約は追加しない。

---

# 8. Design Gap / 追加Spike判定

## 8.1 Design Gap

本PatchでTechnical Spike Aにより特定されたDesign Findingを吸収できるため、新規Design Gapは作成しない。

```text
TF-A-001
↓
Design Reopen
↓
本Patch
↓
Design Gap新規発行なし
```

## 8.2 追加Technical Spike

WordEditor方式について以下はTechnical Spike Aで確認済みである。

- Display前WordEditor取得
- Variable検出
- Case Insensitive
- 全出現箇所置換
- 特殊文字
- 基本書式
- Unresolved Check
- Display
- Scan用MailItem Lifecycle

したがって、本Design Patch適用のために追加Technical Spikeは要求しない。

具体的なRangeループやCOM解放はImplementation Detail / Test Specificationへ送る。

---

# 9. Reopen後の設計フロー

```text
OFT
│
├──────────── Scan ────────────┐
│                              │
▼                              ▼
Outlook Adapter           Scan用MailItem
│                              │
├─ Subject取得                 │
├─ Inspector.WordEditor取得    │
├─ Word Document.Content.Text  │
│        ↓                     │
│     BodyText                 │
│        ↓                     │
│  Template Scanner            │
│        ↓                     │
│  TemplateScanResult          │
│                              │
└──── 保存せずClose ───────────┘
```

メール生成：

```text
InputValues
↓
Input Validator
↓
Value Formatter
↓
Formatted Values
├───────────────┐
│               │
▼               ▼
Subject       Outlook Adapter
Renderer         │
│                ├─ Inspector.WordEditor
▼                ├─ Word Document
SetSubject       └─ Range.Find / Range.Text
│                         │
└───────────┬─────────────┘
            ▼
Outlook Adapter
│
├─ Subject再取得
└─ BodyText再取得
        ↓
Unresolved Checker
        ↓
0件？
├─ No → 保存せずClose / Error
└─ Yes
     ↓
   Display
```

---

# 10. Design上の重要判断

## 10.1 ScannerとUnresolved CheckerはWord Objectを直接持たない

Technical SpikeではWordEditor上で検索できることを確認したが、本DesignではScanner / CheckerへWord Documentを直接渡さない。

理由：

- Core LogicへのCOM依存拡散を防ぐ
- Scanner / Checkerを文字列ベースでテスト可能に保つ
- Word Object LifecycleをInfrastructureへ閉じ込める

採用：

```text
Word Document
↓
Outlook Adapter
↓
BodyText
↓
Scanner / Unresolved Checker
```

## 10.2 Body置換だけはBodyText置換へ戻さない

BodyTextをScannerで利用できるからといって、Render時にBodyText全体を置換してWord Documentへ戻してはならない。

全文Text再設定は書式破壊につながるため、Bodyの物理置換はTechnical Spikeで成立したWord Range方式を使用する。

```text
NG:
Word Document → BodyText → String Replace → 全文再設定

採用:
Word Document → Range.Find → Found Range.Text
```

## 10.3 HTML正規化によるRoute H救済は行わない

HTMLタグを除去・正規化してRoute Hを成立させる追加実装は行わない。

理由：

- Route WがMandatory Gateを満たしている
- HTML Normalizationは追加複雑性と書式破壊リスクを持つ
- MVPに不要な二重Routeを維持することになる
- Technical Spike AのDecisionを再度曖昧にする

Route Hは不採用としてDesignから除外する。

---

# 11. Patch適用後の整合性チェックリスト

`MVP Design v0.1.3 日本語版.md` 作成後、以下を確認する。

## 文書参照

- [ ] タイトルがv0.1.3
- [ ] 文書情報のVersionがv0.1.3
- [ ] Active Requirements参照がv0.1.5
- [ ] v0.1.3更新概要が追加されている
- [ ] v0.1.2以前の更新履歴を変更していない

## HTMLBody旧方式除去

- [ ] Active Design本文にBody処理として `HTMLBody` が残っていない
- [ ] Active Design本文に `HTML Encode` が残っていない
- [ ] `ReadTemplateHtmlBody()` が残っていない
- [ ] `SetHtmlBody()` が残っていない
- [ ] `modBodyRenderer` が残っていない
- [ ] `HTML保護` Traceabilityが残っていない
- [ ] 次工程のテスト項目に `HTML Encode` が残っていない

※ v0.1.1 / v0.1.2更新概要、RISK-DES-001 CLOSED Evidence等の履歴・EvidenceとしてのHTMLBody記述は除外する。

## WordEditor方式

- [ ] Outlook AdapterにInspector / WordEditor責務がある
- [ ] Word Document / Range依存がInfrastructure内に閉じている
- [ ] Scanner InputがSubject / BodyText
- [ ] Unresolved Checker InputがSubject / BodyText
- [ ] Body置換がRange.Find / Range.Text
- [ ] Body全文を再設定しない
- [ ] HTML Encodeを行わない
- [ ] Case Insensitive全出現箇所置換が明示されている
- [ ] WordEditor取得後のLifecycleが明示されている

## Architecture

- [ ] Core LogicからOutlook / Word Object Modelを直接操作しない
- [ ] 独立Body Rendererを廃止している
- [ ] WordEditor専用Adapterを先回り追加していない
- [ ] D16 Technical Decisionが追加されている
- [ ] RISK-DES-001がCLOSED
- [ ] RISK-DES-002がOutlook / Word COMを対象としている

## Requirements整合

- [ ] FR-RENDER-BODY-002の基本書式8項目と一致
- [ ] Requirement Gapを新規作成していない
- [ ] Variable途中部分書式の保証対象外境界がRequirements v0.1.5と一致
- [ ] 新しい利用者向けTemplate制約をDesignから追加していない

---

# 12. Patch適用後の次アクション

```text
本Patchレビュー
        ↓
MVP Design v0.1.3全文へ反映
        ↓
Design単体整合性チェック
        ↓
MVP Requirements v0.1.5
×
MVP Design v0.1.3
×
Technical Spike A CLOSED
最終整合性レビュー
        ↓
MVP Test Specification v0.1
```

---

# 13. Patch判定

```text
Source Design     : MVP Design v0.1.2
Target Design     : MVP Design v0.1.3
Requirements      : MVP Requirements v0.1.5
Technical Decision: Route W / WordEditor
Design Reopen     : Yes
Requirement Gap   : No
New Design Gap    : No
Additional Spike  : Not Required
```

**Patch判定：適用可能**

本Patchの中心方針は以下である。

```text
HTMLBody方式を削除
        ↓
WordEditor方式を採用
        ↓
COM依存はOutlook Adapterへ集約
        ↓
Scanner / CheckerはBodyTextを使用
        ↓
Body物理置換はRange.Find / Range.Text
        ↓
独立Body Rendererは廃止
        ↓
MVP最小構成を維持
```
