# Technical Spike A 実施仕様書 v0.3 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | Technical Spike A 実施仕様書 |
| Document ID | DOC-TS-A |
| バージョン | v0.3 |
| 対象 | OFT Body処理方式比較検証（HTMLBody / WordEditor） |
| 実施時Requirements | MVP Requirements v0.1.4 日本語版 |
| 実施時Design | MVP Design v0.1.2 日本語版 |
| 起点リスク | RISK-DES-001 HTMLBody内のVariable表現 |
| 主な関連要件 | FR-RENDER-BODY-001 / FR-RENDER-BODY-002 / FR-UNRESOLVED-001 / AC-016 / AC-017 / AC-018 / AC-019 |
| 主な関連Design | Outlook Adapter / Template Scanner / Body Renderer / Unresolved Checker |
| ステータス | **CLOSED（Technical Spike A：PASS）** |
| Close日 | 2026-09-11 |
| 採用技術方針 | **Route W：WordEditor** |
| 本Spikeの決定対象 | MVPで採用するBody処理技術方針 |

---

## 2. 改訂理由

### v0.3 更新概要

v0.3では、`AI協働開発 文書管理・Baseline運用ルール v0.1` に基づくGovernance Migrationを実施した。

変更は以下に限定する。

- 固定Document ID `DOC-TS-A` の付与
- 実施時Requirements / Designの固定VersionをHistorical Execution Evidenceとして明確化
- 文書情報から「次工程」を削除
- §21の「次アクション」を削除
- §22の完了条件からNext Action管理を削除
- Spike完了後の標準フローを削除
- Close時点で未補完だった環境メタデータを、Technical DecisionをBlockingしないHistorical Factとして整理

Technical Test Result、Evidence、Finding、Requirements / Design Impact判定、Route W採用、PASS / CLOSED判定には変更を加えていない。

**Change Type：Editorial / Governance**  
**Semantic Change：None**

### v0.2 改訂理由

v0.1では、MVP Design v0.1.2で採用されているHTMLBody直接処理方式を前提に、OFT / HTMLBodyの成立性のみを確認対象としていた。

しかし、過去の技術検討では `Inspector.WordEditor` / Word `Range.Find` を利用したBody置換方式も有力候補として検討されていた。

現時点では、以下の技術方針変更について明示的な比較Evidenceが残っていない。

```text
過去検討
WordEditor方式が有力候補
        ↓
現行Design
HTMLBody直接置換を採用
```

このためTechnical Spike Aの目的を、単一方式の成立性確認から以下へ拡張する。

> 同一OFT・同一Variable・同一入力値を使用し、HTMLBody方式とWordEditor方式を比較検証し、MVPのBody処理技術方針をEvidenceに基づいて決定する。

---

## 3. 目的

本Technical Spikeの目的は、Classic OutlookのOFTを使用した実環境において、以下2方式を同一条件で比較し、MVPのTemplate Scanner / Body Renderer / Unresolved Checkerに採用するBody処理技術方針を決定することである。

### Route H：HTMLBody方式

```text
OFT
↓
CreateItemFromTemplate
↓
Subject / HTMLBody取得
↓
HTMLBody文字列からVariable検出
↓
HTML Encode
↓
HTMLBody文字列をCase Insensitiveで局所置換
↓
HTMLBody設定
↓
Unresolved Check
↓
MailItem.Display
```

### Route W：WordEditor方式

```text
OFT
↓
CreateItemFromTemplate
↓
Inspector / WordEditor取得
↓
Word Document / RangeからVariable検出
↓
Word Range.Find / Range.Textによる置換
↓
Unresolved Check
↓
MailItem.Display
```

Subjectは両Route共通でPlain Textとして扱う。

本SpikeはMVP機能の完成を目的とせず、Body処理方式の技術方針決定に必要な最小限の検証のみを行う。

---

## 4. 技術方針候補

### 4.1 Route H：HTMLBody方式

現行MVP Design v0.1.2で採用されている方式。

主な特徴：

- HTMLBodyを文字列として取得できる
- Regex / String Replaceとの親和性が高い
- Bodyへ挿入する値はHTML Encodeが必要
- HTML内部でVariable文字列がタグ分断される可能性がある
- HTML文字列を直接変更するため、書式維持を実OFTで確認する必要がある

### 4.2 Route W：WordEditor方式

Outlook Inspectorが提供するWordEditorを利用し、Word Object Model上でBodyを処理する方式。

主な特徴：

- Outlook編集画面に近いWord Documentを操作する
- Word Range.Find等で表示文字列としてVariableを探索できる可能性がある
- Range単位で置換することで周辺書式を維持しやすい可能性がある
- HTML文字列を直接編集しないため、Body入力値へのHTML Encodeが不要となる可能性がある
- Inspector / WordEditorの取得条件やMailItem Lifecycleへの影響を確認する必要がある
- Word Object Model利用による実装複雑性を評価する必要がある

---

## 5. 検証対象となる仮説

### HYP-A01：OFT読込

Classic Outlook Object Modelの `CreateItemFromTemplate` 相当の方法により、対象OFTをMailItemとして開ける。

### HYP-A02：Bodyアクセス

同一OFTについて以下の両方へアクセスできる。

- Route H：`MailItem.HTMLBody`
- Route W：`MailItem.GetInspector.WordEditor`

Route Wでは、MailItemを利用者へDisplayする前でもInspector / WordEditorへアクセス可能かを確認する。

### HYP-A03：Variable検出

通常入力した `{{VariableName}}` を以下の両Routeで検出できる。

- Route H：HTMLBody文字列
- Route W：Word Document / Range

### HYP-A04：Case Insensitive

以下を同一VariableNameとして検索・置換できる。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

### HYP-A05-H：HTMLBody局所置換

HTMLBody全体を再構築せず、対象Variable文字列のみを置換することで、Variable置換部分以外の基本書式を維持できる。

### HYP-A05-W：WordEditor Range置換

Word Range.Find / Range.Text等を利用して対象Variableのみを置換することで、Variable置換部分以外の基本書式を維持できる。

### HYP-A06-H：HTML安全性

Route Hでは、Bodyへ挿入する値をHTML Encodeすることで、入力値にHTML特殊文字が含まれてもHTML構造を破壊しない。

### HYP-A06-W：文字列安全性

Route Wでは、HTML Encodeを行わずWord Rangeへ文字列を設定しても、`&`、`<`、`>` 等が意図した表示文字列として扱われ、Body構造を破壊しない。

### HYP-A07：Unresolved Check

Render後に `{{VariableName}}` 形式の残存有無を、採用候補Routeで安定して判定できる。

### HYP-A08：MailItem Lifecycle

Scan目的で生成したMailItemをDisplayせず保存せず破棄できる。

特にRoute Wでは、Inspector / WordEditorを生成・取得したことにより、不要な表示、保存確認、Draft残存等の副作用が発生しないことを確認する。

---

## 6. Scope

### 6.1 共通検証対象

- OFT読込
- Subject取得
- Classic OutlookでのMailItem生成
- Case Insensitive処理
- 同一Variable複数箇所置換
- Render後の未置換Variable検出
- MailItem.Display
- Scan用MailItemの保存なし破棄
- 基本書式維持
- 技術方針比較
- Requirements / Design影響判定

### 6.2 Route H検証対象

- HTMLBody取得
- HTMLBody内Variable連続性
- Regex /文字列によるVariable検出
- HTML Encode
- HTMLBody局所置換
- HTMLBodyベースUnresolved Check

### 6.3 Route W検証対象

- Inspector取得
- WordEditor取得
- Word Document / Range取得
- Word Range上のVariable検出
- Word Range.Find等によるCase Insensitive置換
- HTML Encodeなしでの特殊文字挿入
- WordEditorベースUnresolved Check
- Inspector生成による副作用有無

### 6.4 書式維持確認対象

Requirements FR-RENDER-BODY-002 / AC-017に従い、以下を確認対象とする。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

### 6.5 Scope外

以下は本SpikeのPASS条件に含めない。

- 埋め込み画像
- 複雑なHTML構造
- 特殊なOutlook固有書式
- UserForm
- Excel Tables / Data Access
- VariableDefinitionとの完全なConfiguration Validation
- Sync Engine
- Date Formatterの正式実装
- SelectのOptionSource処理
- Error Code体系
- 本番用Module物理分割
- 本番用Class構成
- 本番用COM解放コードの確定
- WordEditor採用時の本番用Word Object Modelラッパー設計

`{{VariableName}}` の文字列途中へ意図的に異なる書式を設定するケースは、Requirements上はMVP保証対象外であるためMandatory Gateにはしない。ただし、両Routeの頑健性比較に有用なため探索試験として実施する。

---

## 7. Spikeで決めること / 決めないこと

### 7.1 本Spikeで決めること

本Spike完了時に以下を決定する。

1. MVP Body処理方式
   - Route H：HTMLBody
   - Route W：WordEditor
   - いずれも採用不可
2. 採用方式の技術的根拠
3. Current Designを維持できるか
4. MVP DesignのReopenが必要か
5. Requirements文書への影響があるか
6. Requirement Gapが発生するか

### 7.2 本Spikeで決めないこと

- 新しい利用者向けテンプレート記述ルール
- Requirementsに存在しないVariable制約
- 本番用Module構成
- 本番用Class構成
- 本番用Error Code
- 本番用Outlook COM解放実装
- UserForm仕様
- 本番用WordEditorラッパー構造
- 本番用HTML Encode関数の具体コード

Route Hが採用された場合のみ、HTML Encodeの具体実装はImplementationで決定する。

Route Wが採用され、HTML Encode責務自体が不要となる場合は、勝手にRequirements / Designから削除せず、Spike結果を根拠として文書影響判定へ回す。

---

## 8. 検証環境

本SpikeはMVP対象であるClassic Outlook上で実施済みである。OS / Excel / Outlookの詳細バージョン等は後日確認し、本節へ追記する。

これらの未記入項目は再現性を高めるための環境メタデータであり、今回のTechnical DecisionをBlockingする条件とはしない。後日確認した環境情報がMVP対象環境との不整合を示した場合のみ、影響を再評価する。

| 項目 | 実績記入欄 |
|---|---|
| OS | 後日確認 |
| Excelバージョン | 後日確認 |
| Excel 32bit / 64bit | 後日確認 |
| Classic Outlookバージョン | 後日確認 |
| Outlook 32bit / 64bit | 後日確認 |
| WordEditor利用可否 | **利用可（Display前に `Inspector.WordEditor` 取得成功）** |
| VBA実行元ブック | 後日確認 |
| OFT保存場所 | `C:\Users\monsi\OneDrive\ドキュメント\MailGenerator` |
| OFTファイル名 | `temp.oft` |
| 実施日 | 2026-09-10 |
| 実施者 | 後日確認 |

New Outlookではなく、MVP対象であるClassic Outlookを使用した。

---

## 9. 検証用OFT

### 9.1 Subject

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

目的：

- Subject取得
- 同一Variable複数出現
- Case Insensitive
- Date相当文字列の置換

### 9.2 Body

代表的な基本書式を1つのOFTに含める。

```text
関係者各位

対象機種：{{ModelName}}
開催日：{{GateDate}}

■確認事項
・担当部署：{{Department}}
・対象機種再掲：{{MODELNAME}}

以下をご確認ください。

[表]
項目        内容
機種        {{ModelName}}
部署        {{department}}
開催日      {{GateDate}}

よろしくお願いいたします。
```

以下の書式を設定する。

| 対象 | 書式 |
|---|---|
| 冒頭 | 通常段落 |
| `対象機種：` 行 | フォント変更 |
| `開催日：` 行 | 文字サイズ変更 |
| `■確認事項` | 太字 |
| `{{Department}}` を含む行 | 文字色変更 |
| 確認事項 | 箇条書き |
| 下段 | 表 |
| 文中 | 複数段落・改行 |

Mandatory TestではVariable文字列途中だけに異なる書式を設定しない。

### 9.3 検証用Variable

```text
ModelName
GateDate
Department
```

### 9.4 置換値

通常値：

```text
ModelName  = ABC123
GateDate   = 2026/09/30
Department = 品質保証部
```

特殊文字確認値：

```text
ModelName = A&B <TEST>
```

Route HではHTML Encode後に置換する。

Route WではHTML Encodeせず、Word Rangeへ文字列として設定する。

---

## 10. 実施方針

比較結果を正しくするため、Route HとRoute Wは同一MailItemを使い回さない。

```text
同一OFT
├─ MailItem H → Route H検証
└─ MailItem W → Route W検証
```

各Routeは独立してOFTから生成し、片方の変更結果が他方へ影響しないようにする。

Subject置換は両Routeで同一ロジックを使用し、Body処理方式だけを比較対象とする。

---

## 11. 実施手順

### Phase A：共通OFT / Body Access確認

1. VBAから対象OFTを指定する
2. Classic Outlook Applicationを取得または生成する
3. Route H用MailItemを生成する
4. Route W用MailItemを生成する
5. 両MailItemからSubjectを取得する
6. Route HからHTMLBodyを取得する
7. Route WからInspector / WordEditor / Word Documentを取得する
8. Route WでDisplay前にWordEditorへアクセスできるか確認する
9. 不要な画面表示・Draft作成等が発生しないか確認する

### Phase B：Variable検出比較

#### Route H

1. HTMLBodyを取得する
2. `{{...}}` 候補を抽出する
3. VariableName Syntaxを判定する
4. HTMLBody内でVariableが連続文字列として存在するか確認する
5. Case Insensitiveで同一Variableを統合する

#### Route W

1. Word Document / Content Rangeを取得する
2. 表示テキスト上で `{{VariableName}}` を探索する
3. `{{...}}` 候補抽出またはRange.Findによる探索が成立するか確認する
4. Case Insensitiveで同一Variableを扱えるか確認する

### Phase C：Render比較

#### Route H

1. SubjectをPlain TextとしてCase Insensitiveで置換する
2. Body用値へ検証用HTML Encodeを適用する
3. HTMLBody内VariableをCase Insensitiveで全置換する
4. HTMLBody全体の再生成や再整形は行わない
5. Render後HTMLBodyをMailItemへ設定する

#### Route W

1. SubjectをRoute Hと同じPlain Text方式で置換する
2. Word Range.Find等で対象Variableを検索する
3. 対象Rangeへ値を設定する
4. 同一Variableの全出現箇所を置換する
5. HTML Encodeは行わない
6. Body全体を文字列として再構築しない

### Phase D：Unresolved Check比較

各Routeで以下を実施する。

1. 全Variable置換後に未置換Variableが0件であることを確認する
2. `GateDate` 等を意図的に未置換とした別試験を行う
3. 未置換Variableを1件以上検出できることを確認する

Unresolved Checkの最終実装方式は、この比較結果を踏まえて技術方針決定時に判断する。

### Phase E：Display / 書式比較

1. Route HのMailItemをDisplayする
2. Route WのMailItemをDisplayする
3. Subject / Bodyの結果を比較する
4. Variable置換部分以外について以下を比較する
   - 改行
   - 段落
   - フォント
   - 文字サイズ
   - 太字
   - 文字色
   - 箇条書き
   - 表
5. `A&B <TEST>` が意図した表示文字列となっているか確認する
6. メールが自動送信されないことを確認する

### Phase F：Lifecycle確認

Route H / Route WそれぞれについてScan目的のMailItemを生成し、

1. Displayせず処理できるか
2. 保存せず閉じられるか
3. 保存確認が発生しないか
4. Draftへ不要なMailItemが残らないか
5. Route WではInspector / WordEditor取得による副作用がないか

を確認する。

---

## 12. Test Cases

### TSA-001 OFT読込

**目的**  
OFTから独立したRoute H / Route W用MailItemを生成できることを確認する。

**Expected**
- 両方のMailItemをエラーなく生成できる

**Gate**
- Mandatory

---

### TSA-002 Body Access

**Route H**
- Subject取得
- HTMLBody取得

**Route W**
- Subject取得
- Inspector取得
- WordEditor取得
- Word Document取得

**Expected**
- 両RouteでBody処理に必要なObject / Dataへアクセスできる
- Route WではDisplay前アクセス可否を記録する

**Gate**
- Mandatory / Critical

---

### TSA-003 Variable検出・表現

**Route H**
- 通常入力したVariableがHTMLBody内で連続文字列として検索可能か
- HTMLタグ等による分断有無を記録する

**Route W**
- 同じVariableをWord Document / Range上で検索可能か

**Expected**
- 少なくとも採用候補Routeでは、通常利用ケースの全Variableを安定して検出できる

**Gate**
- Mandatory / Critical

---

### TSA-004 Scanner / Case Insensitive

以下を同一Variableとして扱えることを確認する。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

**Route H**
- HTMLBody文字列上でCase Insensitive処理

**Route W**
- Word Range上でCase Insensitive処理

また、Subject / Body / BothのLocation判定に必要な情報を取得できることを確認する。

**Gate**
- Mandatory

---

### TSA-005 Body置換比較

**Route H**
- HTMLBody内のVariableを局所置換する
- 同一Variableの全出現箇所を置換する

**Route W**
- Word Range.Find / Range.Text等でVariableを置換する
- 同一Variableの全出現箇所を置換する

**Expected**
- 両Routeそれぞれで対象Variableを正しく置換できる
- Body全体を意図的に再構築しない

**Gate**
- Mandatory / Critical

---

### TSA-006 特殊文字安全性

**Input**

```text
A&B <TEST>
```

**Route H**
- HTML Encode後にHTMLBodyへ置換する

**Route W**
- HTML EncodeせずWord Rangeへ設定する

**Expected**
- Outlook表示上 `A&B <TEST>` と表示される
- Body構造を破壊しない
- 周辺書式を破壊しない

**Gate**
- Mandatory

**備考**
- Route HのEncode関数はSpike用最小実装
- Route WでHTML Encode不要と確認されても、その時点でRequirements / DesignのHTML Encode記述を直接削除しない

---

### TSA-007 基本書式維持比較

**目的**  
FR-RENDER-BODY-002 / AC-017に対する両Routeの成立性を比較する。

**確認対象**
- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

**Expected**
- 採用候補RouteでVariable置換部分以外の全確認対象書式が維持される

**Gate**
- Mandatory / Critical

---

### TSA-008 Unresolved Check比較

**Test A：正常系**
- 全Variableを置換する

**Expected**
- 未置換0件

**Test B：異常系**
- `GateDate` 等を意図的に未置換とする

**Expected**
- 未置換Variableを検出できる

**Route H**
- HTMLBodyベースで確認

**Route W**
- WordEditor / Word Rangeベースで確認

**Gate**
- Mandatory

---

### TSA-009 Display比較

**目的**  
Render済みMailItemをClassic Outlook上へ表示できることを確認する。

**Expected**
- Route H / Route WともにMailItemをDisplayできる
- Subject / Bodyが期待値である
- 自動送信されない

**Gate**
- Mandatory

---

### TSA-010 Scan用MailItem Lifecycle比較

**目的**  
UserForm起動前Scanで想定するLifecycleが成立することを確認する。

**Route H**
- HTMLBody取得後、Displayせず保存せず破棄

**Route W**
- Inspector / WordEditor取得後、Displayせず保存せず破棄

**Expected**
- 不要なDraftが残らない
- 保存確認等で通常フローを妨げない
- Route WでInspector取得に起因する許容できない副作用がない

**Gate**
- Mandatory / Critical

---

### TSA-011 Variable途中書式変更（探索試験）

**目的**  
Requirements保証対象外ケースを利用し、両Routeの頑健性差を把握する。

例：

```text
{{ModelName}}
```

の一部分だけフォント、太字、文字色等を変更する。

**Route H確認**
- HTMLBody内でVariable文字列がタグ分断されるか
- 検出 / 置換できるか

**Route W確認**
- Word Range上で表示文字列として検出 / 置換できるか

**Gate**
- Non-Gating

本Test単独のFAILによってSpike全体をFAILとしない。

ただし、両RouteがMandatory Testを満たした場合は、技術方針比較の「頑健性」Evidenceとして使用する。

---

## 13. 技術方針の判断軸

単純なPASS件数ではなく、以下の優先順位で判断する。

| 優先度 | 判断軸 | 確認内容 |
|---|---|---|
| 1 | Requirements適合性 | FR-RENDER-BODY-001 / 002、AC-017等を満たせるか |
| 2 | 通常利用時の安定性 | 通常のOFTでVariable検出・置換が安定するか |
| 3 | 書式維持 | 基本書式を安定して維持できるか |
| 4 | Template制約の少なさ | 新しい利用者向け制約を要求しないか |
| 5 | Lifecycle / 副作用 | Scan時に不要なDisplay / Draft等を生じないか |
| 6 | Unresolved Check | Render後チェックを安定して実施できるか |
| 7 | 実装・保守複雑性 | VBAコード量、Object Model依存、保守容易性 |
| 8 | Scope外ケースへの頑健性 | TSA-011等でどちらが壊れにくいか |

Requirements適合性、通常利用時の安定性、書式維持を、実装の簡単さより優先する。

---

## 14. Route選定ルール

### 14.1 Route HのみMandatory Gateを満たす

```text
Route H = PASS
Route W = FAIL
        ↓
HTMLBody方式を採用
        ↓
Current Design維持可能性あり
```

Design v0.1.2との整合を確認し、技術方針差分がなければDesign Reopen不要と判定する。

---

### 14.2 Route WのみMandatory Gateを満たす

```text
Route H = FAIL
Route W = PASS
        ↓
WordEditor方式を採用
        ↓
Current Designと不一致
        ↓
Design Reopen
```

DesignのBody Renderer、Scanner、Unresolved Checker、Outlook Adapter、RISK-DES-001等への影響を確認する。

Requirements内のHTML固有記述も影響確認する。

---

### 14.3 両RouteがMandatory Gateを満たす

判断軸の優先順位に従い比較する。

原則として以下を優先する。

1. Requirementsをより安定して満たせる
2. 通常OFTへの制約が少ない
3. 書式維持リスクが低い
4. Scan / Render / Unresolved Checkの処理方式を一貫させやすい
5. Lifecycle副作用が少ない
6. 上記が同等の場合、実装・保守が単純

「現行Designだから」という理由だけでRoute Hを優先しない。

「過去検討で有力だったから」という理由だけでRoute Wを優先しない。

実OFTで得たEvidenceを選定根拠とする。

---

### 14.4 両RouteがMandatory Gateを満たさない

```text
Route H = FAIL
Route W = FAIL
        ↓
Technical Spike A FAIL
        ↓
Technical Finding
        ↓
Design / Requirement Gap判定
```

---

## 15. Evidence

各Test Caseについて、Route別に最低限以下を記録する。

| 項目 | 内容 |
|---|---|
| Test ID | TSA-xxx |
| Route | H / W / Common |
| Result | PASS / FAIL / N/A |
| 実測値 | Subject、Variable一覧、Object取得可否等 |
| Raw HTML Evidence | Route Hで必要なVariable周辺HTML断片 |
| WordEditor Evidence | Route Wで取得したRange / 検出結果 |
| Visual Evidence | Outlook表示確認メモまたはスクリーンショット |
| Side Effect | Display、Draft、保存確認等 |
| Finding | Expectedとの差 |
| Impact | Requirements / Design / Implementation |

Raw HTMLBody全文やWord Document全文を成果物へ残す必要はない。判断根拠となる最小限のEvidenceのみ記録する。

---

## 16. Technical Spike A Gate

### 16.1 PASS

以下を満たす場合、Technical Spike AをPASSとする。

- TSA-001〜TSA-010を実施済み
- 少なくとも1つのRouteがMandatory Gateをすべて満たす
- 採用Routeを判断軸に基づいて決定できる
- 新しい利用者向け制約が不要、または既存Requirements境界内で成立する
- 技術方針の根拠となるEvidenceが残っている
- Requirements / Design影響判定が完了している

PASSは「現行Design維持」を意味しない。

WordEditor方式を採用した場合でも、技術方針が確定し、必要な文書改訂範囲を特定できればTechnical Spike A自体はPASSとなる。

---

### 16.2 CONDITIONAL PASS

以下の場合はCONDITIONAL PASSとする。

- 採用RouteのMandatory GateはすべてPASS
- Scope外ケースや環境依存の注意事項が存在する
- その注意事項がMVP保証範囲を変更しない
- ImplementationまたはTest Specificationへ明示的に引き継げる

---

### 16.3 FAIL

以下の場合はFAILとする。

- 両RouteともMandatory Gateを満たさない
- Requirementsで保証する基本書式を満たせない
- 通常利用ケースでVariable検出 / 置換が安定しない
- Render後のUnresolved Checkが成立しない
- 許容できないMailItem Lifecycle副作用が発生する
- 新しい利用者向け制約なしではMVPを成立させられず、その制約の妥当性判断が未完了
- Evidence不足により技術方針を決定できない

---

## 17. Requirements / Design影響判定

技術方針決定後、必ず文書影響を確認する。

### 17.1 Route H採用時

現行Design v0.1.2はHTMLBody方式を採用しているため、原則としてDesign維持候補とする。

ただし、Spikeで現行Designと異なる実装前提が判明した場合はDesign差分を確認する。

Requirementsは利用者挙動の変更がなければ原則維持する。

### 17.2 Route W採用時

現行Design v0.1.2の以下は改訂候補となる。

- Outlook Adapter責務
- Template ScannerのBody取得方式
- Render Engine全体フロー
- Body Renderer
- HTML Encode
- Unresolved Checker
- MailItem生成 / Inspector取得シーケンス
- RISK-DES-001
- 次工程上のTechnical Spike記述

Design Reopenが必要と判定する。

### 17.3 Requirements影響

MVP Requirements v0.1.4には以下のHTML固有表現が存在する。

- FR-RENDER-BODY-002のHTML構造 / HTML Encode記述
- §32.1の「HTMLBody置換方式」
- §32.2の「HTML Encode関数」

Route W採用によりこれらの技術前提が不要になる場合、利用者向けRequirement変更ではなく、まず以下として分類する。

```text
技術方針変更
↓
Requirements内のDesign / Implementation固有表現への影響
↓
Document Consistency Patch候補
```

ただし、Route Wを成立させるために新しい利用者向け制約や保証範囲変更が必要な場合はRequirement Gapとする。

---

## 18. Requirement Gap判定

Technical Finding発生時は以下で分類する。

```text
Technical Finding
        ↓
利用者から見た振る舞い・制約を変更する必要がある？
        │
   ┌────┴────┐
   │         │
  No        Yes
   │         │
   ↓         ↓
Design /     Requirement Gap
Implementation /
Document Patch
```

Requirement Gap例：

- Variableには書式を設定してはいけない
- Variableを表内へ配置できない
- Variableを箇条書き内へ配置できない
- Variable前後へ特定文字を置けない
- Template作成時に特殊な操作が必須
- Requirementsで保証する基本書式を縮小する必要がある

単に `HTMLBody` から `WordEditor` へ内部技術方式を変更するだけではRequirement Gapとしない。

---

## 19. Finding分類

| 分類 | 意味 | 対応 |
|---|---|---|
| Observation | 実挙動を確認しただけ | 記録のみ |
| Implementation Detail | 採用方式の本番コードで決めればよい | Implementationへ送る |
| Technical Decision | Route H / W選定に使う技術判断 | Spike最終判定へ反映 |
| Design Finding | 利用者仕様を変えずDesign変更が必要 | Design Reopen |
| Document Consistency Patch | Requirement内容は不変だが技術固有記述修正が必要 | 文書整備へ送る |
| Requirement Gap | 新しい利用者挙動・制約が必要 | Requirementsへ戻す |
| Blocking Issue | どちらの方式でもMVP成立困難 | Requirements / Design Reopen判定 |

---

## 20. 実施結果記録

### 20.1 Test Result

| Test ID | Route H | Route W | Finding |
|---|---|---|---|
| TSA-001 | PASS | PASS | 同一OFTから両Route用MailItemを生成できた。 |
| TSA-002 | PASS | PASS | Route HはSubject / HTMLBody取得成功（HTMLBody length：48894）。Route WはSubject / Inspector / WordEditor / Word Document取得成功（Word Content length：238）。Display前のWordEditorアクセスも成立した。 |
| TSA-003 | **FAIL** | **PASS** | Route Hでは `{{ModelName}}` / `{{GateDate}}` がHTMLタグにより分断され、連続文字列として検索不能。Route Wでは全Variableを表示文字列として検出できた。 |
| TSA-004 | **FAIL** | **PASS** | Route H Scannerはタグ分断VariableをInvalid Candidateとして扱い、通常OFTのVariable一覧を正しく構成できなかった。Route WはModelName / GateDate / DepartmentをCase Insensitiveで正しく統合・Location判定できた。 |
| TSA-005 | **FAIL** | **PASS** | Route Hの自動判定はPASS表示だったがFalse Positive。Outlook表示上、Bodyに未置換Variableが残存したため最終評価をFAILへ補正。Route Wは `Range.Find` + `Range.Text` で全出現箇所を置換した。 |
| TSA-006 | PASS | PASS | Route Hでは `A&B <TEST>` を `A&amp;B &lt;TEST&gt;` へEncodeできた。Route WではHTML Encodeなしで `A&B <TEST>` を意図した表示文字列として設定できた。 |
| TSA-007 | **N/A（評価不能）** | **PASS** | Route HはBody置換自体が成立せず、置換後書式維持を評価できないためN/A。Route Wは改行・段落・フォント・文字サイズ・太字・文字色・箇条書き・表の維持を目視確認した。 |
| TSA-008 | **FAIL** | **PASS** | Route Hの自動判定はPASS表示だったが、タグ分断した未置換Variableを検出できないFalse Negativeを確認。Route Wは正常系0件、異常系3件を検出した。 |
| TSA-009 | PASS | PASS | 両RouteでMailItem.Display成功。自動送信は発生しなかった。Route Hは表示自体は可能だがBody未置換が残存。 |
| TSA-010 | PASS | PASS | Scan用MailItemを保存せず破棄できた。Route WではDrafts 15→15、Inspectors 1→1で、Inspector / WordEditor取得による残存副作用なし。 |
| TSA-011 | N/A | N/A | Non-Gating探索試験。Route HがMandatory / Critical Testで不成立、Route WのみがMandatory Gateを満たしたためRoute選定に追加Evidenceは不要と判断し、実施しない。 |

#### TSA-003 Route H Raw HTML Evidence

Outlook画面上では連続したVariableとして見える一部文字列が、HTMLBody内部では次のように分断されていた。

```html
{{<span class=SpellE>ModelName</span>}}
{{<span class=SpellE>GateDate</span>}}
```

Route Hでの検索結果例：

```text
{{ModelName}} : NOT FOUND
{{MODELNAME}} : FOUND
{{GateDate}} : NOT FOUND
{{Department}} : FOUND
{{department}} : FOUND
```

Route Wでは同一OFT上の全対象Variableを検出できた。

```text
{{ModelName}} : FOUND
{{MODELNAME}} : FOUND
{{GateDate}} : FOUND
{{Department}} : FOUND
{{department}} : FOUND
```

#### TSA-004 Scanner Evidence

Route H：

```text
ValidVariables:
  ModelName [Both]
  GateDate [Subject]
  Department [Body]

InvalidCandidates: 4
  Body: {{<span class=SpellE>ModelName</span>}}
  Body: {{<span class=SpellE>GateDate</span>}}
  Body: {{<span class=SpellE>ModelName</span>}}
  Body: {{<span class=SpellE>GateDate</span>}}
```

Route W：

```text
ValidVariables:
  ModelName [Both]
  GateDate [Both]
  Department [Body]

InvalidCandidates: 0
```

#### TSA-005 Route W Replacement Evidence

```text
{{ModelName}} : before=5 / after=0
{{GateDate}} : before=3 / after=0
{{Department}} : before=2 / after=0
```

#### TSA-008 Route W Unresolved Check Evidence

```text
Route W full     : 0
Route W negative : 3
```

#### TSA-010 Route W Lifecycle Evidence

```text
Drafts before     : 15
Inspectors before : 1

Drafts after scan     : 15
Inspectors after scan : 1
```

### 20.2 Route比較

| 判断軸 | Route H | Route W | 優位 |
|---|---|---|---|
| Requirements適合性 | **不適合**。通常OFTでVariable検出・置換・Unresolved Checkが成立しない。 | **適合**。TSA-001〜010のMandatory Gateを満たす。 | **Route W** |
| 通常利用時の安定性 | **低い**。通常入力したVariableでもOutlook / Word由来HTMLタグにより分断され得る。 | **高い**。Word Document上の表示文字列として全Variableを安定して検出・置換できた。 | **Route W** |
| 書式維持 | **評価不能**。Body置換自体が成立しなかった。 | **成立**。Requirements対象の基本書式を維持した。 | **Route W** |
| Template制約 | HTMLBody方式を維持するには、タグ分断回避等の追加制約または複雑な正規化処理が必要になる可能性がある。 | 今回の通常OFTでは新しい利用者向けTemplate制約を要求しない。 | **Route W** |
| Lifecycle / 副作用 | 問題なし。 | 問題なし。Display前WordEditor取得後もDraft / Inspector残存なし。 | 同等 |
| Unresolved Check | **不成立**。タグ分断Variableを検出できずFalse Negativeが発生。 | **成立**。正常系0件、異常系で残存Variable検出。 | **Route W** |
| 実装・保守複雑性 | String / Regex中心で相対的に単純。ただし通常OFTを安定処理するには追加対策が必要となり、単純性の利点が失われる。 | Word Object Model依存が増えるが、Scanner / Renderer / Unresolved Checkerを同一Bodyモデルで統一できる。 | Route Hは表面的には単純。ただし**採用判断ではWを優先** |
| Scope外ケース頑健性 | TSA-011未実施。 | TSA-011未実施。 | N/A |

**総合評価**

仕様書§13の優先順位に従い、Requirements適合性、通常利用時の安定性、書式維持を実装の単純さより優先する。Route HはCriticalなMandatory Testで不成立であり、Route WのみがMandatory Gateを満たすため、Route Wを採用する。

### 20.3 Technical Decision

```text
Body処理技術方針：

[ ] Route H：HTMLBody
[x] Route W：WordEditor
[ ] 採用方式なし
```

**判断根拠**

```text
1. Route Hでは通常作成したOFTでVariable内部にHTMLタグが挿入され、
   Scanner / Renderer / Unresolved Checkerが安定して成立しなかった。

2. Route HのTSA-005 / TSA-008では、検出不能なVariableを「残存0件」と扱う
   False Positive / False Negativeが発生し、通常利用時の信頼性を満たさない。

3. Route WではWord Document上の表示文字列を基準に、Variable検出、
   Case Insensitive処理、Range置換、特殊文字、Unresolved Checkが成立した。

4. Route WではRequirements対象の基本書式を維持でき、
   Display前のInspector / WordEditor取得によるDraft残存等の副作用も確認されなかった。

5. Route WはWord Object Model依存により実装複雑性が増えるが、
   §13で定義した優先順位ではRequirements適合性・安定性・書式維持を
   実装の単純さより優先するため、Route WをMVPのBody処理方式として採用する。
```

### 20.4 Technical Findings

| Finding ID | 内容 | 分類 | 影響 | 対応 |
|---|---|---|---|---|
| **TF-A-001** | Classic Outlookで通常作成したOFTにおいて、画面上は連続して見える `{{VariableName}}` の内部へ `<span class=SpellE>...</span>` 等のHTMLタグが挿入され、HTMLBody上ではVariable文字列が分断されるケースを確認した。 | **Design Finding** | HTMLBodyを直接扱うTemplate Scanner / Body Renderer / Unresolved Checkerでは、通常利用ケースでもVariableの検出・置換・残存確認が不安定になる。現行RISK-DES-001が実発生したEvidenceとなる。 | Route Hを不採用としRoute Wを採用。MVP Design v0.1.2をReopenし、Body処理をWordEditor前提へ改訂する。 |
| **TF-A-002** | Route HのSpikeコードでは、タグ分断により最初から検出できないVariableを評価母集団に含められず、TSA-005 / TSA-008がコード上PASSとなるFalse Positiveを確認した。 | **Observation** | 「残存0件」と「検出不能」を区別しない判定ではEvidenceを誤解するリスクがある。 | TSA-005 / TSA-008の最終結果をRaw HTML / Outlook表示Evidenceに基づきFAILへ補正。Route H不採用のためSpikeコード自体の修正は行わない。今後のTest Specificationでは検出成立性と残存0件を分離して確認する。 |

### 20.5 Requirements / Design Impact

```text
Requirements：
[ ] 変更不要
[x] Document Consistency Patch必要
[ ] Requirement Gapあり

Design：
[ ] Current Design維持
[x] Design Reopen必要
```

**Requirements判定**

- HTMLBody → WordEditorは内部技術方式の変更であり、利用者から見たMVPの要求振る舞い自体は変更しない。
- Route W成立のための新しい利用者向けTemplate制約は確認されていない。
- よってRequirement Gapは発生しない。
- `HTMLBody` / `HTML Encode` 等のDesign / Implementation固有表現は、Requirement内容を維持したまま技術非依存表現へ修正するため、Document Consistency Patchとする。

**Design判定**

Route W採用は現行MVP Design v0.1.2のHTMLBody直接処理方式と不一致であるため、Design Reopenを必須とする。少なくとも以下を改訂対象として確認する。

- Outlook Adapter
- Template Scanner
- Render Engine
- Body Renderer
- Unresolved Checker
- MailItem / Inspector / WordEditor取得シーケンス
- HTML Encode責務
- RISK-DES-001

---

## 21. 最終判定

```text
Technical Spike A Result：

[x] PASS
[ ] CONDITIONAL PASS
[ ] FAIL
```

### 採用技術方針

```text
Route W：WordEditor

BodyのScanner / Renderer / Unresolved Checkerは、
Inspector.WordEditor / Word Document / Rangeを利用する方式を採用する。

Subjectは従来どおりPlain Textとして処理する。
```

### 判定根拠

```text
- TSA-001〜TSA-010をRoute H / Route Wで実施した。
- Route HはTSA-003 / TSA-004 / TSA-005 / TSA-008で不成立となり、
  Critical Testを含むMandatory Gateを満たさない。
- Route WはTSA-001〜TSA-010のMandatory Gateをすべて満たした。
- Route Wは新しい利用者向け制約を追加せず、Requirementsで保証する
  Variable置換・基本書式維持・Unresolved Check・Lifecycleを成立させた。
- §13判断軸ではRequirements適合性、通常利用時の安定性、書式維持で
  Route Wが明確に優位である。
- 技術方針の根拠となるRaw HTML、Scanner、置換件数、Unresolved Check、
  Draft / Inspector数のEvidenceが残っている。
- Requirements / Designへの影響範囲を特定できた。

以上によりTechnical Spike AをPASSとし、Closeする。
```

### TSA-011の扱い

```text
TSA-011：N/A（実施不要）

TSA-011はNon-Gatingの探索試験である。
Route HはMandatory / Critical Testで既に不成立となり、
Route WのみがMandatory Gateを満たしたため、Route選定に追加Evidenceを必要としない。

Scope外ケースの頑健性確認はMVP技術方針決定には不要と判断し、
必要最小限のSpikeとするため実施しない。
```

### Requirements

```text
[ ] 維持
[x] Document Consistency Patch
[ ] Requirement Gap
```

### Design

```text
[ ] 維持
[x] Reopen
```

### Close記録

```text
Status     : CLOSED
Result     : PASS
Route      : Route W / WordEditor
Close Date : 2026-09-11
```

---

## 22. 完了条件

以下をすべて満たしたため、Technical Spike Aを完了とする。

- [x] TSA-001〜TSA-010をRoute H / Route Wで実施済み
- [x] TSA-011は実施不要理由を記録済み
- [x] 同一OFT / 同一入力値による比較Evidenceが残っている
- [x] Route H / Route Wを判断軸で比較済み
- [x] Body処理技術方針を決定済み
- [x] Technical Findingを分類済み
- [x] PASS / CONDITIONAL PASS / FAILを判定済み
- [x] Requirements影響を判定済み
- [x] Design維持 / Reopenを判定済み
- [x] Requirement Gap有無を判定済み

**Technical Spike A：CLOSED / PASS**

> §8のOS / Excel / Classic Outlook等の詳細環境情報はClose時点で未補完である。これは再現性メタデータの補完事項であり、Technical DecisionおよびClose判定をBlockingしない。
