# Technical Spike A 実施仕様書 v0.1 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | Technical Spike A 実施仕様書 |
| バージョン | v0.1 |
| 対象 | OFT / HTMLBody成立性確認 |
| 上位Requirements | MVP Requirements v0.1.4 日本語版 |
| 上位Design | MVP Design v0.1.2 日本語版 |
| 対象リスク | RISK-DES-001 HTMLBody内のVariable表現 |
| 主な関連要件 | FR-RENDER-BODY-001 / FR-RENDER-BODY-002 / FR-UNRESOLVED-001 / AC-016 / AC-017 / AC-018 / AC-019 |
| 主な関連Design | Outlook Adapter / Template Scanner / Body Renderer / Unresolved Checker |
| ステータス | 実施前 |
| 次工程 | PASS判定後、MVP Test Specification v0.1作成へ進む |

---

## 2. 目的

本Technical Spikeの目的は、Classic OutlookのOFTを使用した実環境において、MVP Design v0.1.2で採用している以下の基本方式が、通常利用ケースで技術的に成立することを確認することである。

```text
OFT
↓
CreateItemFromTemplate
↓
Subject / HTMLBody取得
↓
Template Scanner
↓
Variable検出
↓
Case Insensitive置換
↓
HTMLBody設定
↓
Unresolved Check
↓
MailItem.Display
```

特に、RISK-DES-001で未確認となっている以下を検証する。

1. 通常入力した `{{VariableName}}` がOFTのHTMLBody内で連続文字列として保持されること
2. 現在のTemplate Scanner方式でVariableを検出可能であること
3. HTMLBody内のVariableを局所置換しても、Variable置換部分以外の基本書式を破壊しないこと
4. Case Insensitiveの検索・置換が成立すること
5. Render後のMailItemをClassic Outlook上へDisplayできること
6. Scan目的で生成したMailItemを保存せず破棄できること

本Spikeは、MVP機能の完成を目的としない。

---

## 3. 検証対象となる設計仮説

### HYP-A01：OFT読込

Classic Outlook Object Modelの `CreateItemFromTemplate` 相当の方法により、対象OFTをMailItemとして開き、SubjectおよびHTMLBodyを取得できる。

### HYP-A02：Variable連続性

利用者が通常のOutlook編集操作で入力した `{{VariableName}}` は、HTMLBody内でも検索可能な連続文字列として保持される。

### HYP-A03：Scanner成立性

HTMLBody文字列に対して `{{...}}` 候補を抽出し、VariableName Syntaxを判定する現在のTemplate Scanner方式が成立する。

Design上の候補抽出規則：

```regex
\{\{([^{}]*)\}\}
```

VariableName判定規則：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

### HYP-A04：Case Insensitive成立性

以下を同一VariableNameとして検索・置換できる。

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
```

### HYP-A05：Body局所置換

HTMLBody全体を再構築せず、対象Variable文字列のみを置換することで、Variable置換部分以外の基本書式を維持できる。

### HYP-A06：HTML安全性

Bodyへ挿入する値をHTML Encodeした上で置換することで、入力値にHTML特殊文字が含まれてもHTML構造を破壊しない方式が成立する。

本Spikeで使用するEncode処理は検証用の最小実装とし、正式なEncode関数仕様を決定するものではない。

### HYP-A07：Unresolved Check

Render後のSubject / HTMLBodyを再走査し、`{{VariableName}}` 形式の残存有無を判定できる。

### HYP-A08：MailItem Lifecycle

Scan目的で生成したMailItemをDisplayせずに閉じ、保存せず破棄できる。Render完了後のMailItemはDisplayでき、自動送信されない。

---

## 4. Scope

### 4.1 検証対象

本Spikeでは以下を確認する。

- OFT読込
- Subject取得
- HTMLBody取得
- Variable候補抽出
- VariableName Syntax判定
- HTMLBody内でのVariable連続性
- Case Insensitive検索
- Case Insensitive置換
- 同一Variable複数箇所置換
- HTML Encode後のBody置換
- Variable置換部分以外の基本書式維持
- Render後の未置換Variable検出
- MailItemへのSubject / HTMLBody再設定
- Classic Outlook上でのDisplay
- Scan用MailItemの保存なし破棄

### 4.2 書式維持確認対象

Requirements FR-RENDER-BODY-002 / AC-017に従い、以下を確認対象とする。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

### 4.3 Scope外

以下は本SpikeのPASS条件に含めない。

- 埋め込み画像
- 複雑なHTML構造
- 特殊なOutlook固有書式
- `{{VariableName}}` の文字列途中がHTMLタグ等によって分断されるよう意図的に編集したケース
- UserForm
- Excel Tables / Data Access
- VariableDefinitionとの完全なConfiguration Validation
- Sync Engine
- Date Formatterの正式実装
- SelectのOptionSource処理
- Error Code体系
- 本番用HTML Encode関数の確定
- 本番用COM参照解放コードの確定
- Module物理分割の確定

---

## 5. Spikeで決めてはいけないこと

本Spike中に以下の事項を正式仕様として確定しない。

- 新しい利用者向けテンプレート記述ルール
- Requirementsに存在しないVariable制約
- 本番用Module構成
- 本番用Class構成
- 本番用Error Code
- 本番用HTML Encode実装
- 本番用Outlook COM解放実装
- UserForm仕様

新しい利用者向け制約が必要と判明した場合は、本Spike内で仕様化せず、Technical Findingとして記録し、Requirement Gap判定へ回す。

---

## 6. 検証環境

最低限、以下を記録してから実施する。

| 項目 | 実績記入欄 |
|---|---|
| OS |  |
| Excelバージョン |  |
| Excel 32bit / 64bit |  |
| Classic Outlookバージョン |  |
| Outlook 32bit / 64bit |  |
| VBA実行元ブック |  |
| OFT保存場所 |  |
| OFTファイル名 |  |
| 実施日 |  |
| 実施者 |  |

New Outlookではなく、MVP対象であるClassic Outlookを使用する。

---

## 7. 検証用OFT

### 7.1 Subject

以下のようなSubjectを設定する。

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

目的：

- Subject取得
- 同一Variable複数出現
- Case Insensitive
- Date相当文字列の置換

### 7.2 Body

代表的な基本書式を1つのOFTに含める。

例：

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

上記に対し、以下の書式を意図的に設定する。

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

Variable文字列自体へ部分的な文字単位書式変更は行わない。

Variable全体に同一書式を設定するケースは通常利用ケースとして実施してよい。

### 7.3 検証用Variable

最低限以下を使用する。

```text
ModelName
GateDate
Department
```

### 7.4 置換値

通常値：

```text
ModelName  = ABC123
GateDate   = 2026/09/30
Department = 品質保証部
```

HTML安全性確認値：

```text
ModelName = A&B <TEST>
```

HTML安全性確認値は、文字列をそのままHTMLとして解釈させる目的ではなく、Encode後に表示文字列として安全に扱えることを確認するために使用する。

---

## 8. 実施手順

### Phase A：OFT読込確認

1. VBAから対象OFTを指定する
2. Classic Outlook Applicationを取得または生成する
3. `CreateItemFromTemplate` 相当処理でMailItemを生成する
4. Subjectを取得する
5. HTMLBodyを取得する
6. Subject / HTMLBodyが空でないことを確認する
7. MailItemをDisplayせず、保存せず閉じる
8. Draft等へ不要なMailItemが残らないことを確認する

### Phase B：Raw HTML確認

1. 同じOFTを再度読み込む
2. HTMLBodyを取得する
3. 以下を文字列検索する

```text
{{ModelName}}
{{modelname}}
{{MODELNAME}}
{{GateDate}}
{{Department}}
{{department}}
```

4. 通常入力したVariableが連続文字列として保持されていることを確認する
5. Variable前後のHTML断片を記録する

記録例：

```html
...<span>{{ModelName}}</span>...
```

許容例：

```html
...<b>{{ModelName}}</b>...
```

本Spikeの通常利用ケースでは不成立とみなす例：

```html
...{{Model<span>Name}}...
```

### Phase C：Scanner確認

1. SubjectとHTMLBodyを入力としてCandidate Scanを実施する
2. `{{...}}` 候補を抽出する
3. VariableName Syntax判定を実施する
4. Case Insensitiveで同一Variableを統合する
5. Subject / Body / Bothを識別できることを確認する

期待される概念結果：

```text
TemplateScanResult
├─ ValidVariables
│   ├─ ModelName
│   ├─ GateDate
│   └─ Department
├─ InvalidCandidates
│   └─ 0件
└─ Locations
    ├─ ModelName = Both
    ├─ GateDate = Both
    └─ Department = Body
```

### Phase D：Render確認

1. 検証用置換値を準備する
2. Subject内VariableをCase Insensitiveで全置換する
3. Body用置換値へ検証用HTML Encodeを適用する
4. HTMLBody内VariableをCase Insensitiveで全置換する
5. HTMLBody全体の再生成や再整形は行わない
6. Render後のSubject / HTMLBodyをMailItemへ設定する

### Phase E：Unresolved Check

1. Render後のSubjectを再走査する
2. Render後のHTMLBodyを再走査する
3. `{{VariableName}}` 形式の残存が0件であることを確認する
4. 意図的に1Variableだけ置換しない試験も行い、残存を検出できることを確認する

### Phase F：Display / 書式確認

1. Unresolvedが0件のMailItemのみDisplayする
2. Outlook画面上でSubjectを確認する
3. Outlook画面上でBodyを確認する
4. 以下の基本書式がVariable置換部分以外で維持されていることを確認する
   - 改行
   - 段落
   - フォント
   - 文字サイズ
   - 太字
   - 文字色
   - 箇条書き
   - 表
5. メールが自動送信されないことを確認する
6. 検証後は送信せず閉じる

---

## 9. Test Cases

### TSA-001 OFT読込

**目的**  
OFTからMailItemを生成できることを確認する。

**手順**
1. 対象OFTを読み込む
2. MailItem Objectを取得する

**Expected**
- エラーなくMailItemを取得できる

**Gate**
- Mandatory

---

### TSA-002 Subject / HTMLBody取得

**目的**  
Scannerへ渡す元データを取得できることを確認する。

**Expected**
- Subjectを取得できる
- HTMLBodyを取得できる
- HTMLBodyがHTML文字列として取得できる

**Gate**
- Mandatory

---

### TSA-003 Variable連続性

**目的**  
RISK-DES-001の主要仮説を確認する。

**Expected**
- 通常入力したすべての検証VariableがHTMLBody内で連続文字列として検索可能である

**FAIL条件**
- 通常入力だけで `{{VariableName}}` がHTMLタグにより途中分断され、現在のScanner方式で検出できない

**Gate**
- Mandatory / Critical

---

### TSA-004 Scanner / Case Insensitive

**目的**  
現在のScanner設計が成立することを確認する。

**Expected**
- `{{ModelName}}`
- `{{modelname}}`
- `{{MODELNAME}}`

を同一Variableとして扱える。

また、Subject / Body / Bothを識別可能である。

**Gate**
- Mandatory

---

### TSA-005 Body局所置換

**目的**  
HTMLBodyを再構築せずVariableのみを置換できることを確認する。

**Expected**
- 対象Variableがすべて置換される
- 同一Variableの複数出現箇所がすべて置換される
- Variable以外のHTMLBodyを意図的に変更しない

**Gate**
- Mandatory

---

### TSA-006 HTML安全性

**目的**  
Encodeを前提としたBody Renderer方式が成立することを確認する。

**Input**

```text
A&B <TEST>
```

**Expected**
- Outlook表示上、入力文字列が意図した文字列として確認できる
- `<TEST>` がHTMLタグとして解釈されてBody構造を破壊しない
- 周辺書式を破壊しない

**備考**
- 本TestはEncode責務の成立性確認であり、正式なEncode関数実装を確定するものではない

**Gate**
- Mandatory

---

### TSA-007 基本書式維持

**目的**  
FR-RENDER-BODY-002 / AC-017の成立性を事前確認する。

**Expected**

Variable置換部分以外について以下が維持される。

- 改行
- 段落
- フォント
- 文字サイズ
- 太字
- 文字色
- 箇条書き
- 表

**Gate**
- Mandatory / Critical

---

### TSA-008 Unresolved Check

**目的**  
Render後の独立チェック方式が成立することを確認する。

**Test A**
全Variable置換。

**Expected**
- 未置換0件

**Test B**
`GateDate` 等を意図的に未置換とする。

**Expected**
- 未置換Variableを検出できる

**Gate**
- Mandatory

---

### TSA-009 Display

**目的**  
Render済みMailItemをClassic Outlook上へ表示できることを確認する。

**Expected**
- MailItemをDisplayできる
- Subject / Bodyが期待値である
- 自動送信されない

**Gate**
- Mandatory

---

### TSA-010 Scan用MailItem破棄

**目的**  
UserForm起動前Scanで想定するMailItem Lifecycleが成立することを確認する。

**Expected**
- MailItemをDisplayせず閉じられる
- 保存確認等で通常フローが妨げられない
- 不要なDraftが残らない

**Gate**
- Mandatory

---

### TSA-011 Variable途中書式変更（探索試験）

**目的**  
MVP保証対象外ケースの実挙動を把握する。

例：

```text
{{ModelName}}
```

の一部分だけフォントや太字等を変更する。

**確認**
- HTMLBody内でVariableが分断されるか
- Scannerで検出可能か

**Gate**
- Non-Gating

本TestがFAILしても、それだけではSpike全体をFAILとしない。

ただし、通常のテンプレート編集でも同様の分断が頻発することが判明した場合はTSA-003の結果として扱う。

---

## 10. Evidence

各Test Caseについて、最低限以下を記録する。

| 項目 | 内容 |
|---|---|
| Test ID | TSA-xxx |
| Result | PASS / FAIL / N/A |
| 実測値 | Subject、Variable一覧など |
| Raw HTML Evidence | Variable前後の必要最小限のHTML断片 |
| Visual Evidence | Outlook表示結果の確認メモまたはスクリーンショット |
| Finding | 期待との差 |
| Impact | Requirement / Design / Implementationのどこへ影響するか |

Raw HTMLBody全文を成果物へ貼り付ける必要はない。判断根拠となるVariable周辺の断片のみを残す。

---

## 11. Pass / Fail Gate

### 11.1 PASS

以下をすべて満たす場合、Technical Spike AをPASSとする。

- TSA-001〜TSA-010のMandatory TestがすべてPASS
- 通常入力したVariableがHTMLBody上で連続文字列として取得できる
- Template Scanner方式でVariableを検出できる
- Case Insensitive処理が成立する
- Bodyの局所置換が成立する
- HTML Encode前提でHTML構造を保護できる
- FR-RENDER-BODY-002対象の基本書式が維持される
- Unresolved Checkが成立する
- MailItemをDisplayできる
- Scan用MailItemを保存せず破棄できる
- 新しい利用者向け制約を追加する必要がない

**判定後**

```text
Technical Spike A
        ↓ PASS
Current Design維持
        ↓
MVP Test Specification v0.1
```

---

### 11.2 CONDITIONAL PASS

以下の場合はCONDITIONAL PASSとする。

- Mandatory TestはすべてPASS
- TSA-011等のMVP保証対象外ケースではVariable分断等が発生する
- しかし、通常利用ケースでは現在のScanner / Renderer方式が安定して成立する
- Requirementsで既に保証対象外としている境界を追加変更する必要がない

**判定後**

Current Designを維持する。

必要に応じてTechnical Findingとして注意事項を記録するが、新規Requirementとはしない。

---

### 11.3 FAIL

以下のいずれかに該当する場合、Technical Spike AをFAILとする。

- OFTを安定して読み込めない
- Subject / HTMLBodyを取得できない
- 通常入力したVariableがHTMLBody内で安定して連続文字列にならない
- 現在のScanner方式では通常利用ケースのVariableを検出できない
- 局所置換により基本書式が破壊される
- HTML Encode前提でも通常入力値によりHTMLBody構造が破壊される
- Render後の未置換Variableを検出できない
- MailItemを正常にDisplayできない
- Scan用MailItemを安全に破棄できない
- 現在のDesignを成立させるために新しい利用者向け制約が必要となる

---

## 12. Requirement Gap判定

Spike FAILまたはTechnical Findingが発生した場合、まず問題を以下へ分類する。

```text
Technical Finding
        ↓
現在のRequirement範囲内で
Design / Implementation変更のみで吸収可能？
        │
   ┌────┴────┐
   │         │
  Yes        No
   │         │
   ↓         ↓
Design /     Requirement Gap
Implementation
検討
```

以下のような新しい利用者向けルールが必要になった場合はRequirement Gapとする。

例：

- Variableには書式を一切設定してはいけない
- Variableは表内へ配置できない
- Variableは箇条書き内へ配置できない
- Variable前後に特定文字を置けない
- Template作成時に特殊な操作が必須
- Requirementsで保証対象としている基本書式の一部を保証対象外へ変更する必要がある

Requirement Gap発生時は、Technical Spike内で勝手に仕様追加せず、Requirementsへ戻して判断する。

---

## 13. Spike中に発生したFindingの分類

| 分類 | 意味 | 対応 |
|---|---|---|
| Observation | 挙動を確認しただけ | 記録のみ |
| Implementation Detail | 本番コードで決めればよい | Implementationへ送る |
| Design Finding | 利用者仕様を変えずDesign変更で吸収可能 | Design再検討 |
| Requirement Gap | 新しい利用者挙動・制約が必要 | Requirementsへ戻す |
| Blocking Issue | 現方式ではMVP成立困難 | Design / Requirements Reopen判定 |

---

## 14. 実施結果記録

### 14.1 Test Result

| Test ID | Result | Finding |
|---|---|---|
| TSA-001 | 未実施 |  |
| TSA-002 | 未実施 |  |
| TSA-003 | 未実施 |  |
| TSA-004 | 未実施 |  |
| TSA-005 | 未実施 |  |
| TSA-006 | 未実施 |  |
| TSA-007 | 未実施 |  |
| TSA-008 | 未実施 |  |
| TSA-009 | 未実施 |  |
| TSA-010 | 未実施 |  |
| TSA-011 | 未実施 |  |

### 14.2 Technical Findings

| Finding ID | 内容 | 分類 | 影響 | 対応 |
|---|---|---|---|---|
| TF-A-001 |  |  |  |  |

### 14.3 Requirement Gap

| Gap ID | 内容 | Status |
|---|---|---|
| RG-A-001 |  |  |

Gapがない場合は `None` と記録する。

---

## 15. 最終判定

```text
Technical Spike A Result：
[ ] PASS
[ ] CONDITIONAL PASS
[ ] FAIL
```

### 判定根拠

```text

```

### Current Design

```text
[ ] 維持
[ ] Design Reopen必要
```

### Requirement Gap

```text
[ ] なし
[ ] あり
```

### 次アクション

```text

```

---

## 16. 完了条件

以下をすべて満たした時点でTechnical Spike Aを完了とする。

- TSA-001〜TSA-010を実施済み
- TSA-011を必要に応じて探索実施済み
- Evidenceが判断可能な粒度で残っている
- Technical Findingが分類されている
- PASS / CONDITIONAL PASS / FAILが判定されている
- Requirement Gap有無が判定されている
- Current Design維持 / Reopenが判定されている
- 次アクションが記録されている

PASSまたはCONDITIONAL PASSの場合、次工程は `MVP Test Specification v0.1` とする。

FAILの場合、Technical Findingを起点にDesign変更またはRequirement Gapを判定してから次工程を再決定する。
