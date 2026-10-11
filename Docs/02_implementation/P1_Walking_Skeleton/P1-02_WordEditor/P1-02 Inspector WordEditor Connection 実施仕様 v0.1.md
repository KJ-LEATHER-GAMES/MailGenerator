# P1-02 Inspector WordEditor Connection 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-02 Inspector WordEditor Connection 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Approved |
| Current Execution Baseline | BL-MVP-002 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-02 Inspector / WordEditor Connection |
| Primary Production Module | `modOutlookAdapter` |
| 前提Implementation Unit | P1-01 OFT Path / Outlook Connection = PASS / COMPLETE |
| Primary Verification | Production Boundary + Lifecycle Evidence |

### Related Documents

- `DOC-MVP-DES` — MVP Design
- `DOC-TS-A` — Technical Spike A
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `DF-P1-001対応 OneDrive Local Path Resolution Production実装仕様 v0.1`

### v0.1 Review Correction反映概要

現行Production `modOutlookAdapter` Review結果を反映し、実装開始前のAPI / Lifecycle境界を確定した。

主なCorrectionは以下である。

1. 現行Adapterが `mMailItem` をPrivate Module Stateとして保持していることを明示
2. Public `ReadBodyText()` から `mailItem` 引数を削除し、内部 `mMailItem` を使用する形へ修正
3. P1-02でMailItemを含むCOM Objectを新規Public APIとして公開しないことを明確化
4. `ReadBodyText()` 開始時に `bodyText = vbNullString` とし、Failure時に古いSnapshotを残さない
5. P1-02では既存Error体系 `OutlookError` を使用し、新しいErrorTypeを追加しない
6. `ReadBodyText()` Error時も `mMailItem` / `mOutlookApp` のOwnershipを維持し、Callerが `CloseWithoutSave()` でCleanupできるようにする
7. Nothing MailItem Negative Testを、Public引数注入ではなく「Active MailItemが存在しないAdapter State」で確認する形へ修正

本CorrectionはImplementation Specification上のClarificationであり、Requirement / Design / Baselineの変更を伴わない。

---

# 2. 目的

P1-02の目的は、Production `modOutlookAdapter` 上で、OFTから生成したMailItemに対して以下の接続経路を成立させることである。

```text
MailItem
↓
Inspector
↓
Inspector.WordEditor
↓
Word Document
```

この接続を、Walking Skeleton専用の捨てコードではなく、最終Designで使用するProduction Boundary上に実装する。

さらに、最終Design APIである `ReadBodyText()` をこの接続経路へ接続し、Word Documentから表示文字列ベースのBodyText Snapshotを取得できる最小Production経路を成立させる。

本P1-02では、BodyTextの内容をScanner / Rendererへ接続すること自体を目的としない。

---

# 3. Baseline上の根拠

## 3.1 Design責務

`DOC-MVP-DES` では、Outlook / Word Object Model依存をInfrastructureのOutlook Adapterへ集約する。

特に以下をOutlook Adapter内部へ閉じ込める。

```text
Inspector
WordEditor
Word Document
Word Range
```

Core LogicからOutlook Object Model / Word Object Modelを直接操作しない。

BodyTextはWord Document Objectそのものではなく、`Word.Document.Content.Text` 相当の表示文字列SnapshotとしてCore Logicへ渡す。

## 3.2 Technical Evidence

`DOC-TS-A` ではRoute W：WordEditorについて以下が確認済みである。

```text
TSA-002
- Subject取得成功
- Inspector取得成功
- WordEditor取得成功
- Word Document取得成功
- Display前WordEditor Access成功

TSA-010
- Scan用MailItemを保存せず破棄可能
- Draft残存なし
- Inspector残存なし
```

Technical Spike AのEvidenceは技術方式の成立性を示すが、Production実装のPASSを代替しない。

P1-02ではProduction `modOutlookAdapter` 上で同じ技術境界を再確認する。

## 3.3 Implementation Plan

`DOC-MVP-IMPL` のP1 Walking Skeletonでは、以下をImplementation DetailとしてP1で具体化する。

- Word Object Model参照方式
- Inspector / WordEditor取得コード
- BodyText取得方法
- MailItem Close基本パターン
- COM参照解放の基本パターン
- WordEditor取得失敗時のResult変換基本形

P1-02ではこのうち、Inspector / WordEditor / Word Document AccessとBodyText取得境界を扱う。

---

# 4. Scope

P1-02の実装対象は以下とする。

```text
modOutlookAdapter
├─ MailItemからInspectorを取得
├─ Inspector.WordEditorへアクセス
├─ Word Documentを取得
├─ Word Document ContentからBodyText Snapshotを取得
├─ Outlook / Word COM ErrorをResultへ変換
├─ Local COM Referenceを解放
└─ P1-01 CloseWithoutSave経路と接続
```

Production APIとして、最終Designに定義された `ReadBodyText()` を実装または接続する。

---

# 5. Out of Scope

P1-02では以下を実装しない。

```text
Template Scanner
Variable Candidate抽出
Case Insensitive Variable統合
Subject Snapshotの正式化
Subject Renderer
Range.FindによるVariable検索
Range.TextによるBody置換
ReplaceBodyVariables完成
Unresolved Checker
DisplayMail
メール表示
自動送信
Configuration Validator
Input Validator
Value Formatter
正式なUser-facing Error UI
P6レベルの全COM Error統合
P6レベルの最終COM Release設計
```

また、P1-02のためだけの以下を追加しない。

```text
WordEditor専用Class
WordEditor専用Adapter
Test専用Production Public API
Inspectorを返すPublic API
WordEditorを返すPublic API
Word Documentを返すPublic API
Word Rangeを返すPublic API
```

---

# 6. Responsibility Boundary

## 6.1 Production Boundary

P1-02で追加するWord系COM Objectは、すべて `modOutlookAdapter` 内部に閉じ込める。

```text
Application / Core Logic
        │
        │ String / Result
        ▼
modOutlookAdapter
        │
        ├─ MailItem         [Private Module State]
        ├─ Inspector        [Private]
        ├─ WordEditor       [Private]
        └─ Word Document    [Private]
```

外部Componentへ返却してよいP1-02の新規Outputは以下のみとする。

```text
BodyText As String
COperationResult
```

## 6.2 MailItem境界

P1-01で既に成立しているMailItem生成・Close境界はP1-02で再設計しない。

現行Production `modOutlookAdapter` は以下をPrivate Module Stateとして保持する。

```vb
Private mOutlookApp As Object
Private mMailItem As Object
```

したがってP1-02でも、MailItemを新たにPublic APIの引数または戻り値としてAdapter外へ公開しない。

`ReadBodyText()` は内部 `mMailItem` を使用し、P1-02で新規に導入する以下のWordEditor接続Objectも同様にAdapter内部へ閉じ込める。

```text
MailItem
Inspector
WordEditor
Word Document
Word Range
```

P1-01の既存Public APIである `CreateMailFromTemplate()` / `CloseWithoutSave()` は維持する。

これら既存API形を変更する必要が生じた場合は、P1-02内で推測変更せずImplementation Findingとして切り出す。

---

# 7. Binding方針

P1-02のWord Object Modelは **Late Binding** を採用する。

Production Codeでは、P1-02で新たにWord Object LibraryへのCompile-time Referenceを要求しない。

基本形：

```vb
Dim inspector As Object
Dim wordDocument As Object
```

`Inspector.WordEditor` が返すObjectをWord Documentとして扱う。

理由：

1. MVP配布環境でWord Object Libraryの明示参照追加を必須化しない
2. Word Object Model依存を `modOutlookAdapter` 内へ局所化できる
3. P1-02ではWord定数を必要としない
4. 将来のRange操作方式をP1-02で先回り固定しない

Outlook Object Model側のBinding方式はP1-01で成立している既存実装を維持し、本P1-02のために変更しない。

---

# 8. Production API

## 8.1 Public API

最終Design APIである以下をProduction Boundaryとして使用する。

```vb
Public Function ReadBodyText( _
    ByRef bodyText As String _
) As COperationResult
```

`ReadBodyText()` は現行Adapter内部のPrivate Module State `mMailItem` を使用する。

MailItemをPublic APIの引数・戻り値として追加しない。

### 責務

`ReadBodyText()` は以下だけを行う。

```text
bodyText = vbNullString
↓
内部 mMailItem妥当性確認
↓
Inspector取得
↓
Inspector.WordEditor取得
↓
Word Document取得
↓
Document.Content.Text取得
↓
BodyTextへ設定
↓
Success Result
```

### 非責務

`ReadBodyText()` は以下を行わない。

```text
MailItem.Display
MailItem.Close
Body変更
Variable Scan
Variable置換
Unresolved Check
Trim / Normalize
HTML Decode / Encode
User Message表示
```

BodyTextが空文字であること自体はAPI Errorとしない。

`ReadBodyText()` 開始時に `bodyText = vbNullString` とし、Failure時に呼出元へ過去のBodyText Snapshotを残さない。

P1-02 Smoke TestではBaseline OFTを使用するため、Verification上は非空BodyTextを期待する。

---

# 9. Private Implementation

## 9.1 推奨Private Helper

Inspector / WordEditor / Word Document取得はPrivate Helperへ集約する。

推奨形：

```vb
Private Function TryGetWordDocument( _
    ByVal mailItem As Object, _
    ByRef wordDocument As Object _
) As COperationResult
```

Helper名は実装時に既存命名規則へ合わせて調整してよいが、責務は変更しない。

## 9.2 基本処理

```text
wordDocument = Nothing
↓
mailItem Is Nothing ?
├─ Yes → Error Result
└─ No
    ↓
mailItem.GetInspector
    ↓
Inspector Is Nothing ?
├─ Yes → Error Result
└─ No
    ↓
Inspector.WordEditor
    ↓
WordEditor / Word Document Is Nothing ?
├─ Yes → Error Result
└─ No
    ↓
Word Document返却
```

Outlookの `Inspector.WordEditor` の戻り値をWord Documentとして使用するため、Production Codeで別のWordEditor Wrapper Objectを追加しない。

## 9.3 `ReadBodyText()` 接続

```text
ReadBodyText()
↓
bodyText = vbNullString
↓
Private mMailItem
↓
TryGetWordDocument(mMailItem)
↓
wordDocument.Content.Text
↓
bodyText
```

取得した文字列は表示文字列Snapshotとしてそのまま返す。

P1-02では末尾段落記号等を独自にTrim / Normalizeしない。

---

# 10. Error / Result方針

## 10.1 基本方針

P1-02では既存 `COperationResult` / Error Modelを使用する。

新しいError Modelを追加しない。

Infrastructureから直接 `MsgBox` を表示しない。

## 10.2 Error分類

最低限以下をResultへ変換する。

| 条件 | Result分類 | Target候補 |
|---|---|---|
| `mMailItem Is Nothing` | OutlookError | `MailItem` |
| Inspector取得失敗 | OutlookError | `Inspector` |
| InspectorがNothing | OutlookError | `Inspector` |
| WordEditor取得失敗 | OutlookError | `WordEditor` |
| WordEditor / Word DocumentがNothing | OutlookError | `WordEditor` |
| `Document.Content.Text`取得失敗 | OutlookError | `BodyText` |
| `ReadBodyText()` 内の予期しないVBA Error | OutlookError | `ReadBodyText` |

現行 `modOutlookAdapter` では `TemplateError` / `OutlookError` を使用している。P1-02ではErrorType体系を拡張せず、Outlook / Word COM Boundary内のErrorは既存 `OutlookError` として返す。

Error taxonomyの最終整理が必要な場合はP6で扱い、P1-02だけを理由に `UnexpectedError` 等の新規ErrorTypeを追加しない。

## 10.3 Message

Messageには少なくとも、どの段階で接続に失敗したかを識別できる情報を含める。

例：

```text
Unable to access Outlook Inspector.
Unable to access WordEditor.
Unable to read the Word document body.
```

VBA Runtime Error文字列そのものだけを利用者向けMessageとしない。

P1-02ではUI表示文言の最終化までは行わない。

---

# 11. COM Reference / Cleanup

## 11.1 基本原則

P1-02では、Private処理内で取得したCOM Referenceを呼出元へ返さない。

Private Local Referenceは処理終了時に解放する。

推奨解放順：

```text
Word Document Reference
↓
Inspector Reference
```

VBA上はLocal Objectへ `Nothing` を設定する基本形を採用する。

P6で行う最終COM Release設計をP1-02で先回り実装しない。

## 11.2 MailItem Ownership

`ReadBodyText()` はMailItemをCloseしない。

理由：

- Scan FlowではBodyText取得後にScannerへ渡す必要がある
- Mail Generation Flowでは同一生成用MailItemを後続Renderへ使用する
- MailItem Lifecycleの所有権をReaderへ混在させない

現行AdapterのOwnershipは以下とする。

| Object | Owner | P1-02 Cleanup |
|---|---|---|
| `mOutlookApp` | Adapter Lifecycle | `ReadBodyText()` では解放しない |
| `mMailItem` | Adapter Lifecycle | `ReadBodyText()` では解放しない |
| Inspector | `ReadBodyText()` / Private Helper | Local Referenceを `Nothing` |
| Word Document | `ReadBodyText()` / Private Helper | Local Referenceを `Nothing` |

`ReadBodyText()` がFailureを返した場合も、`mMailItem` / `mOutlookApp` を勝手に `Nothing` にしない。

CallerはFailure Resultを受け取った後も、可能な範囲で既存 `CloseWithoutSave()` を実行してMailItem Lifecycleを終了できること。

MailItemの終了は既存 `CloseWithoutSave()` または後続正式Lifecycleが担当する。

---

# 12. Production処理フロー

P1-02完了時点の最小Production Flowは以下とする。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
Local OFT Path
↓
modOutlookAdapter.CreateMailFromTemplate
↓
Private mMailItem
↓
modOutlookAdapter.ReadBodyText
    ↓
    MailItem.GetInspector
    ↓
    Inspector.WordEditor
    ↓
    Word Document
    ↓
    Document.Content.Text
↓
BodyText String
↓
modOutlookAdapter.CloseWithoutSave
```

このFlowではDisplayしない。

---

# 13. P1-02 Smoke Test

## 13.1 目的

Technical Spike Aで成立したWordEditor Accessを、Production `modOutlookAdapter` Boundary上で再確認する。

Smoke TestはProduction Codeの代わりとなるInspector / WordEditor取得処理を独自実装しない。

## 13.2 推奨Test Module

```text
modP1_02InspectorWordEditorSmokeTest
```

推奨Entry Point：

```text
TestP102InspectorWordEditorConnection
```

実際の命名は既存Smoke Test命名規則へ合わせてよい。

## 13.3 Test Flow

```text
START
↓
P1-01前提確認
↓
Draft Count Before
Inspector Count Before
↓
Settings.TemplatePath取得
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadBodyText
↓
Connection Result確認
↓
CloseWithoutSave
↓
COM Reference解放
↓
Draft Count After
Inspector Count After
↓
PASS / FAIL
```

`CloseWithoutSave` はSuccess / Failureのどちらでも可能な範囲でCleanupとして実行する。

## 13.4 Connection Verification

P1-02では以下を確認する。

```text
CreateMailFromTemplate = Success
ReadBodyText = Success
BodyText取得処理がRuntime Errorで停止しない
Baseline OFTのBodyText Length > 0
```

`ReadBodyText = Success` は、Production内部で以下の全段階を通過できたEvidenceとして扱う。

```text
MailItem
→ Inspector
→ Inspector.WordEditor
→ Word Document
→ Document.Content.Text
```

Inspector / WordEditor / Word DocumentをSmoke Testへ返して直接Assertしない。

## 13.5 P1-03との境界

P1-02ではBodyTextを **接続成立確認用Snapshot** としてのみ使用する。

以下はP1-03で確認する。

```text
Subject Snapshot
BodyText Snapshotの内容整合
期待文字列との一致
Snapshotを後続Scannerへ渡す境界
```

したがってP1-02では、BodyText Lengthが0より大きいこと以上の詳細Content Assertionを必須としない。

---

# 14. Lifecycle Evidence

P1-02ではTSA-010およびMTS-MAIL-003との接続を意識し、最低限以下をEvidenceとして記録する。

```text
Draft Count Before
Inspector Count Before

CreateMailFromTemplate Result
ReadBodyText Result
BodyText Length
CloseWithoutSave Result

Draft Count After
Inspector Count After
```

期待値：

```text
Draft Count After     = Draft Count Before
Inspector Count After = Inspector Count Before
```

また、以下を確認する。

```text
MailItem.Display未実行
保存確認なし
不要Draft残存なし
不要Inspector残存なし
```

Draft / Inspector件数取得のためにTest Harness側でOutlook Object Modelを参照してよいが、その処理でWordEditor / Word Documentを取得してProduction Boundaryを迂回してはならない。

---

# 15. Negative / Error Verification

P1-02ではP6相当の網羅的Error Testは行わない。

ただしLocal Verificationとして、少なくとも以下の代表Error PathがResultとして返ることを確認する。

## Case E1：Active MailItemなし

Public APIからMailItemを注入せず、Adapter内部にActive MailItemが存在しないStateで確認する。

代表手順：

```text
CreateMailFromTemplate未実行
↓
ReadBodyText
```

または、独立したTest Runで以下を使用してよい。

```text
CreateMailFromTemplate
↓
CloseWithoutSave
↓
ReadBodyText
```

Expected：

```text
ReadBodyText = Failure
bodyText = vbNullString
Runtime Errorを呼出元へ未処理で伝播しない
Error ResultからMailItem接続問題を識別可能
```

## Case E2：WordEditor Access Error

実環境で安全に再現可能な場合のみ確認する。

Expected：

```text
Runtime Errorを未処理で停止させない
OperationResultへ変換する
```

無理にOutlook Objectを破壊してErrorを作るTest HookはP1-02では追加しない。

---

# 16. P1-01 Regression

P1-02実装後、P1-01で成立済みの以下をRegression確認する。

```text
ResolveWorkbookRelativePath
Local OFT Path生成
CreateMailFromTemplate
CloseWithoutSave
P0 / P1-01 Smoke Test
```

P1-02実装のためにP1-01 Production APIを破壊しない。

OneDrive Web URL → Local Windows Path Resolutionの責務は `modSettingsData` に維持し、`modOutlookAdapter` へ移動しない。

---

# 17. PASS / FAIL Criteria

## 17.1 PASS

以下をすべて満たした場合、P1-02をPASS / COMPLETE候補とする。

```text
VBA Compile
= PASS

P1-01 Regression
= PASS

CreateMailFromTemplate
= PASS

Production ReadBodyText
= PASS

Inspector Access
= PASS（ReadBodyText Successにより間接確認）

WordEditor Access
= PASS（ReadBodyText Successにより間接確認）

Word Document Access
= PASS（ReadBodyText Successにより間接確認）

Baseline BodyText Length
> 0

Unexpected Display
= NONE

Draft Residue
= NONE

Inspector Residue
= NONE

CloseWithoutSave
= PASS

Blocking Implementation Finding
= NONE

Blocking Design Finding
= NONE

Blocking Requirement Gap
= NONE
```

## 17.2 FAIL

以下のいずれかをFAILとする。

```text
Inspector / WordEditor / Word DocumentへProduction Boundaryからアクセス不能
ReadBodyTextで未処理Runtime Error
BodyText取得不能
MailItemを意図せずDisplay
不要Draft残存
不要Inspector残存
CloseWithoutSave Regression
P1-01 Regression Failure
```

---

# 18. Finding Classification

P1-02で問題を検出した場合は以下で分類する。

## Implementation Detail

既存Designのままコード修正で解決できる。

例：

```text
Object取得順序
Nothing Check
On Error範囲
Late Binding記述
Local Reference解放順
```

## Implementation Defect

本仕様・Designどおりのコードになっていない。

## Design Finding

Requirementは明確だが、既存 `modOutlookAdapter` 責務では成立しない、またはDesign責務境界の変更が必要。

## Requirement Gap

利用者から見た新しい振る舞い判断が必要。

## Technical Risk / Spike再判定

Route W自体のProduction成立性に新しい重大不確実性が生じ、通常Implementation + Verificationでは大規模手戻りリスクが高い場合のみ再判定する。

Technical Spike B / Cを自動的に復活させない。

---

# 19. Implementation Order

推奨実装順：

```text
1. 現行 modOutlookAdapter Boundary / Error Pattern確認
   ↓
2. Private TryGetWordDocument実装
   ↓
3. Public ReadBodyText接続
   ↓
4. Compile
   ↓
5. P1-02 Smoke Test作成
   ↓
6. Happy Path Verification
   ↓
7. Lifecycle Evidence確認
   ↓
8. Representative Error Verification
   ↓
9. P1-01 Regression
   ↓
10. Finding判定
   ↓
11. P1-02 PASS / FAIL判定
```

---

# 20. Deliverables

P1-02の成果物候補は以下とする。

```text
Production
- 更新済み modOutlookAdapter

Verification
- modP1_02InspectorWordEditorSmokeTest
- P1-02 Smoke Test Evidence

Control
- P1-02 Completion Record（PASS後、必要な場合のみ）
```

P1-02 Completion RecordはExecution Evidenceであり、本Implementation Specification本文へ実施結果を追記しない。

---

# 21. Completion Definition

P1-02 Completeとは、Production `modOutlookAdapter` 上で以下が成立し、Lifecycle Regressionがない状態とする。

```text
OFT
↓
MailItem
↓
Inspector
↓
WordEditor
↓
Word Document
↓
BodyText Snapshot
↓
CloseWithoutSave
```

P1-02完了はP1 Walking Skeleton全体の完了を意味しない。

また、以下の成立を意味しない。

```text
Scanner Complete
Render Complete
Unresolved Complete
Display Complete
CP-P1 Established
```

---

# 22. P1-03への接続境界

P1-02完了後、P1-03ではP1-02で成立したProduction APIを再利用する。

```text
P1-02
ReadBodyText接続成立
        ↓
P1-03
Subject / BodyText Snapshot
```

P1-03で新たにInspector / WordEditor / Word Document Accessを別経路として実装しない。

P1-03は、P1-02で確立したOutlook Adapter Boundaryから得られる文字列Snapshotを対象として確認を進める。

---

# 23. 最終方針

P1-02では、Route W：WordEditorを再選定しない。

実装するのは、Baselineですでに採用済みのTechnical DecisionをProduction Architectureへ接続する最小経路である。

最終責務は以下とする。

```text
modOutlookAdapter
= Outlook / Word COM Boundary

Private
= Inspector / WordEditor / Word Document

Public Output
= BodyText String + OperationResult

Lifecycle
= Existing MailItem Owner + CloseWithoutSave

Verification
= Production Boundary + Lifecycle Evidence
```

P1-02だけを理由として新しいArchitecture、WordEditor専用Adapter、Test専用Public API、Scanner / Render処理を先行実装しない。
