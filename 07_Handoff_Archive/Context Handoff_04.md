# 引き継ぎまとめ

## 実施内容

* 前会話から引き継いだ現在地を確認した。

  * `MVP Requirements v0.1.4 日本語版.md`

    * Requirements Baseline
  * `MVP Design v0.1.2 日本語版.md`

    * Design内容はCLOSED
  * Requirement Gap

    * RG-001：Closed
    * RG-002：Closed
  * Design Gap

    * DG-001：Closed
  * 次工程

    * Technical Spike A
    * その後に `MVP Test Specification v0.1`
* Requirements / Designの文書整合性について軽微な残件を確認した。

  * `MVP Design v0.1.2` にRequirements v0.1.3へのActive参照が一部残存
  * `MVP Requirements v0.1.4` の「次工程」記述が現在地に追いついていない
* ユーザー判断により、上記ドキュメント整備は後回しとし、Technical Spike Aを優先した。

### Technical Spike A 実施仕様書 v0.1作成

作成ファイル：

* `Technical Spike A 実施仕様書 v0.1 日本語版.md`

当初の検証対象：

* OFT読込
* Subject取得
* HTMLBody取得
* HTMLBody内でのVariable連続性
* Template Scanner成立性
* Case Insensitive検索・置換
* HTML Encode
* 基本書式維持
* Unresolved Check
* Outlook Display
* Scan用MailItem破棄

TSA-001〜TSA-010をMandatory Testとして定義。

追加で、

* TSA-011

  * Variable文字列途中へ部分書式を設定したケース
  * MVP保証対象外の探索試験
  * Non-Gating

を定義した。

### Technical Spike A用 VBA Spikeコード v0.1相当を作成

* 標準モジュール1個
* Late Binding
* `Outlook.Application`
* `Scripting.Dictionary`
* `VBScript.RegExp`
* HTMLBodyを直接Scanner / Renderer / Unresolved Checkerへ使用
* TSA-001〜006、008〜010を自動判定
* TSA-007のみOutlook画面を目視確認

本番実装ではなく、Technical Spike専用コードとして作成した。

---

### HTMLBody方式とWordEditor方式の再検討

ユーザーから、

> 以前検討した際にはHTMLBody置換よりWordEditor置換の方が良かった記憶がある

との指摘があった。

確認した結果：

* 現行 `MVP Design v0.1.2`

  * Body RendererはHTMLBody直接置換方式
  * HTML Encodeを実施
  * HTMLBody上でVariableを局所Replace
* 過去検討では

  * `Inspector.WordEditor`
  * Word `Range.Find`
  * を使う方式が有力候補だった
* WordEditor → HTMLBodyへ技術方針を変えた明確な比較Evidence / Decisionが現行Designに残っていないことを問題として認識した。

そのためTechnical Spike Aを、

```text
HTMLBody方式が成立するか
```

だけのSpikeから、

```text
Route H：HTMLBody
vs
Route W：WordEditor

を同一条件で比較し、
Body処理技術方針を決める
```

Spikeへ変更した。

---

### Technical Spike A 実施仕様書 v0.2へ改訂

作成ファイル：

* `Technical Spike A 実施仕様書 v0.2 日本語版.md`

主な変更：

* Route H

  * HTMLBody方式
* Route W

  * WordEditor方式
* 同一OFT・同一Variable・同一入力値で比較
* Subject処理は共通
* Body処理だけを比較対象とする
* TSA-001〜TSA-010をRoute H / W両方で評価
* TSA-011を探索試験として維持
* 技術方針選定軸を定義

判断軸：

1. Requirements適合性
2. 通常利用時の安定性
3. 書式維持
4. Template制約の少なさ
5. Lifecycle / 副作用
6. Unresolved Check
7. 実装・保守複雑性
8. Scope外ケースへの頑健性

また、Spike後の流れを次のように定義した。

```text
Technical Spike A
↓
Route H / Route W比較
↓
技術方針決定
↓
Requirements / Design影響判定
↓
必要な場合のみ文書改訂
↓
MVP Test Specification v0.1
```

---

### Route W対応のTechnical Spike VBAコードへ改訂

`Technical Spike A v0.2` 対応コードをチャット上で作成した。

構成：

```text
同一OFT
├─ Route H用MailItem
│   └─ HTMLBody
│
└─ Route W用MailItem
    └─ Inspector.WordEditor
```

Route H：

* HTMLBody取得
* Regex Scanner
* Case Insensitive String Replace
* HTML Encode
* HTMLBody Unresolved Check

Route W：

* `MailItem.GetInspector`
* `Inspector.WordEditor`
* `Word.Document.Content`
* `Range.Find`
* `Range.Text`
* HTML Encodeなし
* Word Document text上でUnresolved Check

WordEditor側ではWordの一括Replace機能ではなく、

```text
Range.Find
↓
Found Range
↓
Range.Text = replacement
```

を採用した。

目的：

* Variableの対象Rangeだけを置換
* 周辺書式維持を確認
* Replacement文字列特有の制御構文の影響を減らす

---

### 検証用OFTの書式条件を補足

OFTの、

```text
文中：複数段落・改行
```

について具体化した。

* `Enter`

  * 段落
* `Shift + Enter`

  * 同一段落内の改行

を意図的に混在させ、TSA-007で置換後も維持されていることを確認する方式とした。

---

### Technical Spike A v0.2を実環境で実行

使用OFT：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\temp.oft
```

実行は最後まで正常完了した。

Fatal Errorなし。

最終出力まで到達：

```text
Technical Spike A v0.2 RESULT
...
NOTE:
PASS件数だけでRouteを選定しないこと。
v0.2仕様書 §13 の判断軸に従って比較すること。
```

---

### Route H：HTMLBody 実測結果

TSA-001：

* PASS
* OFTからMailItem生成成功

TSA-002：

* PASS
* Subject / HTMLBody取得成功
* HTMLBody length：48894

TSA-003：

* FAIL

実測：

```text
{{ModelName}} : NOT FOUND
{{MODELNAME}} : FOUND
{{GateDate}} : NOT FOUND
{{Department}} : FOUND
{{department}} : FOUND
```

HTMLBody内部でVariableの一部が次の形になっていた。

```html
{{<span class=SpellE>ModelName</span>}}
{{<span class=SpellE>GateDate</span>}}
```

つまりOutlook画面上では、

```text
{{ModelName}}
```

に見えていても、HTMLBody内部ではタグによってVariableNameが分断されるケースが実際に発生した。

これは `RISK-DES-001` で想定していたリスクの実発生Evidenceとなった。

TSA-004：

* FAIL

Scanner結果：

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

HTMLBodyをRegexで直接解析すると、分断されたVariableを正常なVariableとして認識できないことを確認した。

TSA-005：

コード出力上：

* PASS

ただし実際のOutlook表示では、

* Subjectは置換された
* Bodyには一部Variableが未置換のまま残った

ことを確認。

そのためTSA-005 Route HのPASSは**誤判定**と判明。

原因：

* 検証コードがHTML上で最初から検索可能だったVariableだけを置換対象・確認対象としている
* HTMLタグで分断されたVariableはbefore countにも含まれない
* その結果、検索可能Variableが0件残存になっただけでPASSしてしまう

実質評価：

* TSA-005 Route H：FAIL相当

TSA-006：

* コード上PASS
* `A&B <TEST>` をHTML Encode

```text
A&amp;B &lt;TEST&gt;
```

TSA-007：

* `Cancel` を選択
* MANUAL / 評価未完了

理由：

* Body Variableが置換されていないため、「置換後の書式維持」を正しく評価できない
* `No` にすると「書式崩れ」と誤記録されるためCancelとした

TSA-008：

コード出力上：

```text
Route H full     : 0
Route H negative : 1
```

* PASS表示

しかしBodyに未置換Variableが残っていたため、こちらも**誤PASS**と判明。

原因：

* Unresolved CheckerもHTMLBodyに対するRegex
* 分断された

```html
{{<span ...>ModelName</span>}}
```

を正常なVariableとして認識できない

つまり、

```text
未置換が0件
```

ではなく、

```text
未置換を検出できていない
```

状態。

実質評価：

* TSA-008 Route H：FAIL相当

TSA-009：

* PASS
* MailItem.Display成功

TSA-010：

* PASS
* Scan用MailItemをDisplayせず破棄成功

---

### Route W：WordEditor 実測結果

TSA-001：

* PASS

TSA-002：

* PASS
* Subject取得
* Inspector取得
* WordEditor取得
* Word Document取得

Word Content length：

```text
238
```

TSA-003：

* PASS

すべてWord Document上で検索できた。

```text
{{ModelName}} : FOUND
{{MODELNAME}} : FOUND
{{GateDate}} : FOUND
{{Department}} : FOUND
{{department}} : FOUND
```

TSA-004：

* PASS

Scanner結果：

```text
ValidVariables:
  ModelName [Both]
  GateDate [Both]
  Department [Body]

InvalidCandidates: 0
```

TSA-005：

* PASS
* Word `Range.Find` + `Range.Text` で置換成功

置換Evidence：

```text
{{ModelName}} : before=5 / after=0
{{GateDate}} : before=3 / after=0
{{Department}} : before=2 / after=0
```

TSA-006：

* PASS
* HTML Encodeなしで

```text
A&B <TEST>
```

をWord Rangeへ設定

* Outlook画面でも正常表示を確認

TSA-007：

* PASS
* 基本書式維持を目視確認

確認対象：

* 改行
* 段落
* フォント
* 文字サイズ
* 太字
* 文字色
* 箇条書き
* 表

TSA-008：

* PASS

```text
Route W full     : 0
Route W negative : 3
```

正常系：

* 未置換0件

異常系：

* GateDateを意図的に残した場合、未置換を検出

TSA-009：

* PASS
* MailItem.Display成功

TSA-010：

* PASS

実行前：

```text
Drafts before     : 15
Inspectors before : 1
```

Scan後：

```text
Drafts after scan     : 15
Inspectors after scan : 1
```

つまり今回の環境では、

```text
CreateItemFromTemplate
↓
GetInspector
↓
WordEditor
↓
Scan
↓
Close olDiscard
```

を行っても、

* Draft増加なし
* Inspector残存なし

を確認した。

---

## 決定事項

### Technical Spike Aの進め方

以下の流れを採用した。

```text
Technical Spike A実施仕様書改訂
↓
Route H / Route W比較コード作成
↓
実環境検証
↓
技術方針決定
↓
Requirements / Design影響確認
↓
必要文書改訂
```

理由：

* 過去にWordEditor方式が有力だった一方、現行DesignはHTMLBody方式になっていた
* 方式変更の比較Evidenceが不足していた
* 技術方式を推測ではなく実OFTのEvidenceで判断するため

---

### Technical Spike A v0.2の比較対象

正式に比較する方式：

* Route H：HTMLBody
* Route W：WordEditor

同一OFT、同一Variable、同一入力値で比較する。

---

### Subject処理

SubjectはRoute H / Route W共通でPlain Textとして扱う。

比較対象はBody処理方式とする。

---

### WordEditor側のSpike置換方式

Spikeでは、

```text
Range.Find
↓
Found Range
↓
Range.Text = replacement
```

方式を採用した。

Word FindのReplaceAllは今回のSpikeでは使用しない。

---

### TSA-007 Route Hの今回の記録

Body置換が成立していなかったため、書式維持を評価せず `Cancel` とした。

意味：

* 書式維持FAILではない
* 置換そのものが成立していないため評価不能

---

### WordEditor採用について

**まだ正式決定していない。**

実測結果はWordEditorを強く支持しているが、Technical Spike A v0.2の最終Technical Decisionとしては未確定。

決定事項には入れない。

---

## 未解決事項

### Technical Spike A TSA-011

未実施。

内容：

* `{{VariableName}}` の一部分だけ

  * フォント
  * 太字
  * 文字色
* などを変更する

確認：

Route H：

* HTMLタグ分断がどうなるか
* Scanner / Rendererがどう振る舞うか

Route W：

* Word Range上で表示文字列として検出・置換できるか

位置づけ：

* Non-Gating
* Requirements保証対象外
* 両Routeの頑健性比較Evidence

実施するかは次チャットで判断。

---

### Technical Spike Aの正式Technical Decision

未確定。

現時点のEvidence：

* Route H

  * TSA-003 FAIL
  * TSA-004 FAIL
  * TSA-005 実質FAIL
  * TSA-007 評価不能
  * TSA-008 実質FAIL
* Route W

  * TSA-001〜010すべてPASS

したがってWordEditorが非常に有力だが、`Technical Spike A 実施仕様書 v0.2` の§13 判断軸に沿った正式比較・記録は未実施。

---

### Route HのSpikeコード判定バグ

要修正。

TSA-005：

* HTMLタグ分断Variableを認識しないため誤PASSする

TSA-008：

* HTMLタグ分断VariableをUnresolvedとして認識せず誤PASSする

今後Route Hを再実行する場合は判定ロジック修正が必要。

ただし、今回得られたHTML断片とOutlook表示結果はTechnical FindingのEvidenceとして利用可能。

---

### Technical Findingの正式登録

未実施。

候補：

```text
TF-A-001
HTMLBody内で一部VariableNameに
<span class=SpellE>...</span>
が挿入され、Variable文字列が分断された。
```

影響候補：

* Template Scanner
* Body Renderer
* Unresolved Checker
* RISK-DES-001

分類：

* Technical Finding
* Design Finding候補

正式分類は次工程で実施。

---

### WordEditor採用時のDesign影響

要確認。

現行 `MVP Design v0.1.2` はHTMLBody方式を前提としているため、WordEditorを採用する場合は少なくとも以下を確認する。

* Outlook Adapter
* Template Scanner
* Body Renderer
* Render Engine
* Unresolved Checker
* MailItem / Inspector生成シーケンス
* HTML Encode責務
* RISK-DES-001

Design Reopenの要否：

* 未確定
* WordEditorを正式採用した場合はReopenが必要となる可能性が高い

---

### Requirements影響

要確認。

`MVP Requirements v0.1.4` 内には技術固有表現が残っている。

候補：

* HTML Encode
* HTMLBody置換方式
* HTML構造に関する記述

WordEditor採用時：

* 利用者向け振る舞いが変わらなければRequirement Gapではない
* `Document Consistency Patch` 候補

ただし新しい利用者向け制約が必要になった場合のみRequirement Gapとする。

---

### 既存ドキュメント整備

ユーザー判断で後回し。

残件：

* `MVP Design v0.1.2`

  * Requirements v0.1.3へのActive参照残存
* `MVP Requirements v0.1.4`

  * §34 次工程が旧工程のまま

Technical Spike結果に伴う改訂とまとめて処理する方針候補。

---

### MVP Test Specification v0.1

未作成。

Technical Spike Aの技術方針決定と必要なRequirements / Design整合性修正後に作成する。

---

## 次アクション

### 優先度1：Technical Spike Aの結果を正式評価する

最初に見るもの：

* `Technical Spike A 実施仕様書 v0.2 日本語版.md`

  * §13 技術方針の判断軸
  * §14 Route選定ルール
  * §20 実施結果記録
  * §21 最終判定
* 今回のImmediate Window出力

Route比較を以下で正式記録する。

```text
Requirements適合性
通常利用時の安定性
書式維持
Template制約
Lifecycle / 副作用
Unresolved Check
実装・保守複雑性
Scope外ケース頑健性
```

---

### 優先度2：TSA-011を実施するか判断する

推奨：

* 1回だけ実施する

理由：

* Non-Gatingだが、HTMLBodyとWordEditorの頑健性差を明確にできる
* WordEditor採用判断の追加Evidenceになる
* RISK-DES-001の性質を記事化しやすい

実施する場合：

```text
{{ModelName}}
```

の一部分だけ書式変更したOFTを用意して、Route H / Wを比較する。

---

### 優先度3：Technical Decisionを確定する

候補：

```text
Body処理技術方針
[ ] Route H：HTMLBody
[ ] Route W：WordEditor
[ ] 採用方式なし
```

現時点ではRoute Wが有力。

ただし正式決定は§13判断軸を埋めてから行う。

---

### 優先度4：Technical Findingを正式記録する

候補：

```text
TF-A-001
HTMLBody内部でOutlook/Word由来の
<span class=SpellE>...</span>
がVariableName内部へ挿入され、
見た目とHTML表現が一致しなかった。
```

関連Evidence：

```html
{{<span class=SpellE>ModelName</span>}}
{{<span class=SpellE>GateDate</span>}}
```

---

### 優先度5：Requirements / Design影響判定

WordEditor採用の場合：

```text
Technical Decision
↓
Design Reopen判定
↓
Requirements内技術固有記述確認
↓
必要箇所のみPatch
```

特に見るファイル：

* `MVP Requirements v0.1.4 日本語版.md`
* `MVP Design v0.1.2 日本語版.md`
* `Technical Spike A 実施仕様書 v0.2 日本語版.md`

---

### 優先度6：Technical Spikeコード修正

必要ならRoute Hの誤判定を修正。

対象：

* TSA-005
* TSA-008

目的：

* Spike Evidenceの再現性向上
* 「検出できないものを存在しないと判定する」False Negative防止

正式技術方針がWordEditorに決まる場合、Route Hコード修正をどこまで行うかは要判断。

---

### 優先度7：MVP Test Specification v0.1

Technical Spike A完了・Design整合後に開始。

Traceability：

```text
Requirement
↓
Acceptance Criteria
↓
Design Component
↓
Test Case
```

を追える構成にする。

---

## 気づき

### Outlookで「見えている文字列」とHTMLBodyは一致しないことがある

今回もっとも重要な発見。

Outlook画面上では、

```text
{{ModelName}}
```

と見えていてもHTMLBodyでは、

```html
{{<span class=SpellE>ModelName</span>}}
```

になるケースが確認された。

つまり、

> 「画面上で連続文字列だからHTML文字列でも連続している」

という前提は成立しない。

---

### Technical Spikeは実装可能性だけでなくDesign DecisionのEvidenceになる

当初は、

```text
現行Design = HTMLBody
↓
HTMLBodyが動くか確認
```

というSpikeだった。

しかし過去判断との不整合に気づき、

```text
HTMLBody vs WordEditor
↓
比較Evidence
↓
技術方針決定
```

へ目的を変更した。

Technical Spikeを「設計を正当化する確認作業」にせず、**設計を検証・覆すこともできる実験**として扱うことの重要性が見えた。

---

### PASS件数だけでは技術方式を選べない

仕様書v0.2で明示した判断軸：

* Requirements適合性
* 安定性
* 書式維持
* 制約
* Lifecycle
* 保守性

が重要。

今回も、Route Hはコード表示上7 PASSだったが、重要なCritical部分がFAILしている。

単純スコアでは誤判断する。

---

### テストコード自体もFalse Positive / False Negativeを起こす

今回、

```text
HTMLBody内にVariableが見つからない
↓
残存数0
↓
PASS
```

という逆転現象が発生した。

重要な学び：

> 「0件だった」は、「存在しない」のか「検出できなかった」のかを分ける必要がある。

Scanner / Unresolved Checkerでは特に重要。

---

### 目視テストにも「評価不能」が必要

TSA-007 Route Hでは、

* 書式が壊れた
* 書式が維持された

のどちらでもなく、

* そもそも置換できなかったため評価不能

だった。

PASS / FAILだけでなく、

```text
BLOCKED
N/A
MANUAL
```

などの状態が必要になる場面がある。

---

### WordEditorはRendererだけでなくScannerにも使える可能性が確認できた

懸念：

```text
GetInspector
↓
WordEditor
```

すると画面表示やDraft残存が起きるのではないか。

実測：

```text
Drafts 15 → 15
Inspectors 1 → 1
```

今回環境では問題なし。

そのため、

```text
Scanner
Renderer
Unresolved Checker
```

を同一のWordEditor系モデルで揃えられる可能性がある。

---

### 内部技術方式変更とRequirement Gapは別

HTMLBody → WordEditorの変更だけなら、

* 利用者から見た挙動は同じ
* 内部実装方式変更

なのでRequirement Gapではない。

一方、

```text
Variableに書式を付けてはいけない
表内では使えない
```

など新しい利用者制約が必要ならRequirement Gap。

「技術変更」と「仕様変更」を分離する判断ルールとして再利用できる。

---

## 記事にできそうな切り口

### 開発日記向き

* **「設計書ではHTMLBodyだった。でも昔の自分はWordEditorを推していた」**

  * 過去判断を思い出したことでTechnical Spikeの目的を変更した話
* **動くコードを書く前に、実験そのものを設計し直した話**

  * Technical Spike v0.1 → v0.2
* **PASS 7個でも採用してはいけない技術方式**

  * HTMLBody側の結果を単純スコアで評価すると危険だった話
* **目に見える `{{ModelName}}` と内部データは別物だった**

  * Outlook HTMLの実測で想定が崩れた話
* **「テストがPASSしたのに画面では失敗している」**

  * Spikeコード自身のFalse Positiveを発見した過程
* **設計を守るためではなく、設計を疑うためのTechnical Spike**
* **AIと一緒に仕様書→検証コード→Evidence→設計見直しまで回す個人開発**

---

## 技術記事向き

* **Outlook VBA：HTMLBody vs Inspector.WordEditorのVariable置換比較**
* **Outlook OFTでHTMLBodyのプレースホルダーが`span`タグに分断される問題**
* **`{{VariableName}}` をHTMLBody直接Replaceすると危険な理由**
* **Word `Range.Find` + `Range.Text` を使ったOFTテンプレート置換**
* **Outlook `GetInspector.WordEditor` をDisplay前Scannerとして使えるか**
* **HTML Encodeが必要なHTMLBody方式、不要になり得るWordEditor方式**
* **Unresolved Variable CheckerでFalse Negativeを防ぐ方法**
* **Technical SpikeのPASS / CONDITIONAL PASS / FAIL設計**
* **Requirement GapとDesign Findingをどう分離するか**
* **技術方式比較で単純なPASS件数を使ってはいけない理由**
* **Outlook VBAのMailItem Lifecycle：Draft / Inspector数をEvidenceとして確認する**

---

## 有料note / テンプレート化候補

* `Technical Spike 実施仕様書 Template`

  * Purpose
  * Hypothesis
  * Scope
  * Test Case
  * Evidence
  * PASS / FAIL Gate
  * Technical Finding
  * Requirement Gap判定
* **技術方式比較チェックリスト**

  * Requirements適合性
  * 安定性
  * 書式維持
  * 制約
  * Lifecycle
  * 保守性
* **Technical Finding分類テンプレート**

  * Observation
  * Implementation Detail
  * Technical Decision
  * Design Finding
  * Document Consistency Patch
  * Requirement Gap
  * Blocking Issue
* **Requirement Gap判定フロー**
* **Technical Spike → Design Reopen判定フロー**
* **AI協働開発向け「設計を疑うSpike」プロンプト**
* **PASS / FAILだけにしない検証結果テンプレート**

  * PASS
  * FAIL
  * MANUAL
  * BLOCKED
  * N/A
* **Traceability付きTechnical Spike Result Sheet**
* Outlook / VBA向け

  * OFT Template Scanner検証テンプレート
  * WordEditor `Range.Find` Spikeコード雛形
  * MailItem Lifecycle確認コード雛形

## まとめ / Summary

**日本語:** この会話では、Technical Spike AをHTMLBody単独検証からHTMLBodyとWordEditorの比較検証へ改訂し、実環境でTSA-001〜010を実行しました。HTMLBodyでは実際にVariable内部へ`span`タグが入り、Scanner・Renderer・Unresolved Checkに問題が出ました。一方、WordEditorはTSA-001〜010をすべてPASSしました。ただし、WordEditor採用の正式Technical Decisionはまだ未確定です。次のチャットでは、Spike結果を判断軸に沿って正式評価し、必要ならTSA-011を実施してから技術方針を確定するところから再開します。

**English:** In this conversation, Technical Spike A was changed from an HTMLBody-only test to a comparison of HTMLBody and WordEditor. TSA-001 to TSA-010 were run in the real environment. HTMLBody had problems because `span` tags split some variables. WordEditor passed TSA-001 to TSA-010. However, the final decision to use WordEditor has not been made yet. In the next chat, start by formally reviewing the spike results, optionally run TSA-011, and then decide the technical approach.
