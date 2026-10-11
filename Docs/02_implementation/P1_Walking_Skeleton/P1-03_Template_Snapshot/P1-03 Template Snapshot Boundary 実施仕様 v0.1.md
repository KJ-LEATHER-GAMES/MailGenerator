# P1-03 Template Snapshot Boundary 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-03 Template Snapshot Boundary 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Review Candidate |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-03 Template Snapshot Boundary |
| Primary Production Module | `modOutlookAdapter` |
| 前提Implementation Unit | P1-02 Inspector / WordEditor Connection = PASS / COMPLETE |
| Primary Verification | Subject / BodyText Snapshot Boundary + P1-02 Regression |

### Related Documents

- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `P1-02 Inspector WordEditor Connection 実施仕様 v0.2`
- `P1-02 Inspector WordEditor Connection Completion Record v0.1`

### v0.1 作成概要

P1-02で成立したProduction `modOutlookAdapter` のMailItem / WordEditor Boundaryを前提として、P1 Walking Skeletonの次段であるSubject / BodyText文字列Snapshot境界を確定する。

本Unitでは以下を行う。

1. 最終Designに定義された `ReadSubject()` をProduction APIとして追加する
2. P1-02で成立済みの `ReadBodyText()` を変更せず再利用する
3. 同一のActive MailItemからSubject / BodyTextを文字列として取得する
4. Subject / BodyTextの両方が取得成功した場合のみSnapshot Boundary成立と扱う
5. Outlook / Word COM ObjectをCore Logicへ公開しない
6. Snapshot専用Class / DTO / Adapterを追加しない
7. Template Scannerは本Unitでは実装せず、後続Unitへ接続可能な入力境界までを完成させる
8. P1-02で成立したWarm / Cold Start、MailItem Lifecycle、CloseWithoutSave経路をRegression確認する

本仕様は既存Requirement / DesignをImplementation Detailへ具体化するものであり、新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Detail / Unit Specification**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-03の目的は、Production `modOutlookAdapter` 上で、OFTから生成された同一MailItemについて以下の境界を成立させることである。

```text
Active MailItem
├─ ReadSubject()
│    ↓
│  Subject As String
│
└─ ReadBodyText()
     ↓
   BodyText As String

        ↓

Subject / BodyText Snapshot Boundary
```

この境界により、後続のTemplate ScannerがOutlook Object Model / Word Object Modelへ依存せず、文字列だけを入力として処理できる状態を作る。

本UnitではTemplate Scannerそのものは実装しない。

---

# 3. Baseline上の根拠

## 3.1 Design責務

`DOC-MVP-DES` では、Outlook AdapterのMailItem Boundaryとして以下が定義されている。

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
DisplayMail()
CloseWithoutSave()
```

また、Template Scannerの入力は以下の文字列Snapshotとする。

```text
Subject
BodyText
```

Scannerは以下を保持・操作しない。

```text
MailItem
Inspector
WordEditor
Word Document
Word Range
Explorer
```

これらOutlook / Word COM Objectは `modOutlookAdapter` 内部に閉じ込める。

## 3.2 P1-02成立済み境界

P1-02では以下がProduction Boundary上で成立済みである。

```text
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
Private mMailItem
↓
ReadBodyText
↓
Inspector
↓
WordEditor
↓
Word Document
↓
Document.Content.Text
↓
BodyText As String
```

したがってP1-03では `ReadBodyText()` を再設計・再実装しない。

## 3.3 Implementation Plan

`DOC-MVP-IMPL` のP1 Walking Skeletonでは、最小Vertical Sliceとして以下が要求される。

```text
Create MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText取得
↓
Template Scanner
↓
...
```

P1-03はこのうち、P1-02で成立済みのBodyText取得にSubject取得を加え、後続Scannerへ接続可能な文字列Boundaryを完成させる。

---

# 4. Scope

P1-03の実装対象は以下とする。

```text
modOutlookAdapter
├─ Public ReadSubject() 追加
├─ 内部 mMailItem からSubject取得
├─ Failure時のSubject出力初期化
├─ Outlook Runtime ErrorのResult変換
├─ 既存 ReadBodyText() 再利用
├─ 同一Active MailItemからSubject / BodyTextを取得
├─ Subject / BodyText Snapshot Boundary成立確認
├─ COM Object非公開確認
└─ 既存 CloseWithoutSave経路とのLifecycle整合確認
```

P1-03で新規実装するProduction機能は原則 `ReadSubject()` のみとする。

---

# 5. Out of Scope

P1-03では以下を実装しない。

```text
Template Scanner
Candidate Scan
VBScript.RegExp
VariableName Syntax Validation
ValidVariables / InvalidCandidates
Case Insensitive Variable統合
Subject / Body / Both Location統合
TemplateScanResult
Subject Renderer
SetSubject完成
Range.FindによるBody Variable検索
Range.TextによるBody Render
ReplaceBodyVariables完成
Unresolved Checker
DisplayMail
最終生成MailItem Display
Configuration Validator
Input Validator
Value Formatter
Sync Engine
UserForm
```

また、P1-03のためだけに以下を追加しない。

```text
CTemplateSnapshot
TemplateSnapshot DTO
Snapshot専用Class
Snapshot専用Adapter
Snapshot専用Interface
MailItemを返すPublic API
Inspectorを返すPublic API
WordEditorを返すPublic API
Word Documentを返すPublic API
Explorerを返すPublic API
Test専用Production Public API
```

P1-02で成立済みの以下も再設計しない。

```text
Classic Outlook Readiness
Existing Explorer再利用
Cold Start Visible Explorer Initialization
ReadBodyText
TryGetWordDocument相当
Explorer Lifecycle
MailItem Ownership
CloseWithoutSave
Late Binding方針
```

---

# 6. Responsibility Boundary

## 6.1 Production Boundary

P1-03完了時の責務境界は以下とする。

```text
Application / Core Logic
        │
        │ Subject As String
        │ BodyText As String
        │ COperationResult
        ▼
────────────────────────────────
        Snapshot Boundary
────────────────────────────────
        ▲
        │
modOutlookAdapter
        │
        ├─ Outlook Application [Private Module State]
        ├─ MailItem            [Private Module State]
        ├─ Inspector           [Private / Local]
        ├─ WordEditor          [Private / Local]
        ├─ Word Document       [Private / Local]
        └─ Explorer            [Private / Local]
```

Adapter外へ返却してよい値は以下のみとする。

```text
Subject As String
BodyText As String
COperationResult
```

COM Object ReferenceをAdapter外へ公開しない。

## 6.2 Snapshotの定義

P1-03におけるSnapshotとは、

> 同一Active MailItemのSubjectおよびBodyを、ある時点の文字列値として取得したもの

とする。

Snapshotは永続状態ではない。

以下を意味しない。

```text
Excelへの保存
Cache
MailItem状態との自動同期
長期保持Object
Snapshot専用Domain Model
Outlook / Word Object Wrapper
```

Render後にCurrent状態を確認する必要がある場合は、古いSnapshotを更新するのではなく、`ReadSubject()` / `ReadBodyText()` を再実行して新しい文字列Snapshotを取得する。

## 6.3 Snapshot成立条件

以下の両方が同一Active MailItemに対してSuccessとなった場合のみSnapshot成立とする。

```text
ReadSubject = Success
AND
ReadBodyText = Success
```

概念フロー：

```text
CreateMailFromTemplate
↓
Active MailItem A
↓
ReadSubject
├─ Failure → Snapshot NOT ESTABLISHED
└─ Success
    ↓
ReadBodyText
├─ Failure → Snapshot NOT ESTABLISHED
└─ Success
    ↓
Snapshot ESTABLISHED
```

片方だけ成功したPartial Snapshotを後続Scannerへ渡さない。

---

# 7. Production API

## 7.1 新規Public API：ReadSubject

P1-03では以下をProduction Boundaryへ追加する。

```vb
Public Function ReadSubject( _
    ByRef subjectText As String _
) As COperationResult
```

`ReadSubject()` は既存Adapter内部のPrivate Module State `mMailItem` を使用する。

MailItemを引数・戻り値として公開しない。

## 7.2 ReadSubject責務

`ReadSubject()` は以下のみを行う。

```text
subjectText = vbNullString
↓
内部 mMailItem妥当性確認
↓
mMailItem.Subject取得
↓
subjectTextへ設定
↓
Success Result
```

Subjectが空文字であること自体はAPI Errorとしない。

理由：

- Outlook MailItemのSubjectは空欄を取り得る
- Subject空欄可否のRequirement / Render判断はReaderの責務ではない
- P1-03は値取得Boundaryのみを扱う

`ReadSubject()` 開始時に必ず、

```vb
subjectText = vbNullString
```

とし、Failure時に呼出元へ過去のSubject Snapshotを残さない。

## 7.3 ReadSubject非責務

`ReadSubject()` は以下を行わない。

```text
Classic Outlook Readiness再実行
MailItem生成
MailItem.Display
MailItem.Close
Subject変更
Trim
Normalize
Variable Scan
Variable Validation
Variable置換
Unresolved Check
User Message表示
```

Classic Outlook ReadinessおよびMailItem生成は既存 `CreateMailFromTemplate()` 側の責務とする。

## 7.4 既存ReadBodyText

以下をそのまま維持する。

```vb
Public Function ReadBodyText( _
    ByRef bodyText As String _
) As COperationResult
```

P1-03では `ReadBodyText()` のProduction Logic、WordEditor接続、COM Reference処理、Error Patternを変更しない。

`ReadBodyText()` は引き続き、

```text
bodyText = vbNullString
↓
内部 mMailItem妥当性確認
↓
Inspector
↓
WordEditor
↓
Word Document
↓
Document.Content.Text
↓
BodyText
```

を担当する。

---

# 8. Error / Result

## 8.1 基本方針

P1-03では既存Error体系を拡張しない。

Outlook MailItem Boundary内で発生したErrorは既存 `OutlookError` を使用する。

新しいErrorTypeは追加しない。

## 8.2 ReadSubject Failure

最低限以下をFailureとして扱う。

### Case E1：Active MailItemなし

```text
CreateMailFromTemplate未実行
↓
ReadSubject
```

または、

```text
CreateMailFromTemplate
↓
CloseWithoutSave
↓
ReadSubject
```

Expected：

```text
ReadSubject = Failure
subjectText = vbNullString
未処理Runtime Errorなし
Error ResultからActive MailItem問題を識別可能
```

### Case E2：Subject取得Runtime Error

`mMailItem.Subject` 取得時にOutlook Runtime Errorが発生した場合：

```text
subjectText = vbNullString
Runtime Errorを呼出元へ未処理で伝播しない
OutlookErrorへ変換
Failure Resultを返す
```

Fault InjectionのためにProduction Public APIを追加しない。

再現困難なErrorの網羅確認はP6へ残す。

## 8.3 Error Target

P1-03で新規Error Code体系は作らない。

既存 `CErrorInfo` の `Target` には、少なくともSubject取得段階を識別可能な値を設定する。

推奨Target：

```text
Subject
```

既存命名規則上、より具体的な既存Targetが存在する場合はそれを優先し、P1-03実装時に整合させる。

## 8.4 Message

Messageは少なくともSubject取得失敗であることを識別可能とする。

例：

```text
Unable to read the Outlook mail subject.
```

VBA Runtime Error文字列だけをUser-facing Messageとして使用しない。

P1-03では最終UI文言の確定は行わない。

---

# 9. MailItem Ownership / Lifecycle

## 9.1 Ownership

P1-02で確定したOwnershipを維持する。

| Object | Owner | P1-03での扱い |
|---|---|---|
| `mOutlookApp` | Adapter Lifecycle | Read処理では解放しない |
| Explorer | Classic Outlook / Adapter Private Helper | P1-02方針を維持 |
| `mMailItem` | Adapter Lifecycle | Read処理ではClose / 解放しない |
| Inspector | `ReadBodyText()` / Private Helper | P1-02方針を維持 |
| Word Document | `ReadBodyText()` / Private Helper | P1-02方針を維持 |

`ReadSubject()` は `mMailItem` のOwnershipを変更しない。

## 9.2 ReaderはMailItemをCloseしない

以下を維持する。

```text
ReadSubject()
→ MailItem Closeしない

ReadBodyText()
→ MailItem Closeしない
```

理由：

- Subject / BodyTextの両方を同一MailItemから取得する必要がある
- 後続P1 Unitで同一MailItemをScanner / Renderへ接続する
- ReaderへLifecycle Ownershipを混在させない

MailItem Lifecycle終了は既存 `CloseWithoutSave()` または後続正式Lifecycleが担当する。

## 9.3 Failure時Cleanup

`ReadSubject()` または `ReadBodyText()` がFailureの場合も、Reader自身は `mMailItem` をCloseしない。

CallerはFailure Resultを受け取った後、可能な範囲で `CloseWithoutSave()` を実行してCleanupする。

---

# 10. P1-03 Production Flow

P1-03完了時点の最小Production Flowを以下とする。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
Local OFT Path
↓
modOutlookAdapter
↓
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
Private mMailItem
├─ ReadSubject
│    ↓
│  Subject As String
│
└─ ReadBodyText
     ↓
   BodyText As String
↓
Snapshot Boundary Established
↓
CloseWithoutSave
```

本UnitではSnapshot取得後にTemplate Scannerへは接続しない。

後続Unitでは以下へ拡張する。

```text
Subject As String
+
BodyText As String
↓
Template Scanner
```

---

# 11. Snapshot Boundary Rules

## 11.1 同一MailItem

SubjectとBodyTextは必ず同一のActive `mMailItem` から取得する。

以下は禁止する。

```text
MailItem A → Subject
MailItem B → BodyText
```

## 11.2 値のコピー

Subject / BodyTextは文字列値として呼出元へ返す。

取得後にMailItem側が変更されても、既に取得済みStringを自動同期しない。

Current状態が必要な場合は再Readする。

## 11.3 COM依存非伝播

Snapshot取得後、後続処理は以下へ依存してはならない。

```text
Outlook.Application
Explorer
MailItem
Inspector
WordEditor
Word Document
Word Range
```

P1-03 Smoke Testでも、Snapshot確認のためにCOM ObjectをProduction APIから取得しない。

## 11.4 文字列加工禁止

Reader層では以下を行わない。

```text
Trim
改行正規化
Case変換
HTML Decode
HTML Encode
Variable抽出
Variable名正規化
```

Subject / BodyTextは取得した値をそのまま返す。

---

# 12. P1-03 Smoke Test

## 12.1 目的

Production `modOutlookAdapter` Boundary上で、

```text
ReadSubject
+
既存 ReadBodyText
```

が同一MailItemに対して成立し、Subject / BodyText文字列Boundaryを形成できることを確認する。

Smoke Test側でOutlook / Word取得ロジックを独自実装しない。

## 12.2 推奨Test Module

```text
modP1_03TemplateSnapshotSmokeTest
```

推奨Entry Point：

```vb
TestP103TemplateSnapshotBoundary
```

Warm / Cold Regressionを分離する場合：

```vb
TestP103TemplateSnapshotWarmStart
TestP103TemplateSnapshotColdStart
```

## 12.3 Baseline Happy Path

Baseline OFTを使用する。

概念手順：

```text
1. Settings.TemplatePath取得
2. ResolveWorkbookRelativePath
3. CreateMailFromTemplate
4. ReadSubject
5. ReadBodyText
6. Subject / BodyText Evidence出力
7. Snapshot成立判定
8. CloseWithoutSave
```

Expected：

```text
CreateMailFromTemplate = PASS
ReadSubject = PASS
ReadBodyText = PASS
Subject Length > 0
BodyText Length > 0
Snapshot Boundary = ESTABLISHED
CloseWithoutSave = PASS
```

Baseline OFTではSubject / Bodyの双方に内容が存在するため、Verificationでは両方のLength > 0を期待する。

これはAPI一般仕様として「空Subject / 空BodyをErrorとする」ことを意味しない。

## 12.4 Evidence

最低限以下を記録する。

```text
Resolved OFT Path
Outlook Start State
CreateMailFromTemplate Result
ReadSubject Result
Subject Length
Subject Snapshot
ReadBodyText Result
BodyText Length
Snapshot Boundary Result
CloseWithoutSave Result
```

BodyText全文をEvidenceへ必須出力しない。

必要であればVariableを含むことを確認可能な範囲だけ診断出力してよい。

## 12.5 Lifecycle Evidence

P1-02 Regressionとして最低限以下を確認する。

```text
Warm Start Readiness
Cold Start Readiness
Explorer Lifecycle
Draft Count Before / After
Inspector Count Before / After
Unexpected Scan MailItem Display
CloseWithoutSave
```

P1-03の主目的はSnapshot Boundaryであり、P1-02のCold Start技術成立性を再設計・再検証するものではない。

---

# 13. Negative Verification

## Case N1：Active MailItemなし / ReadSubject

手順：

```text
ReadSubject
```

Expected：

```text
Failure
subjectText = vbNullString
未処理Runtime Errorなし
```

## Case N2：Active MailItemなし / ReadBodyText

P1-02既存Negative Testを再利用可能とする。

Expected：

```text
Failure
bodyText = vbNullString
未処理Runtime Errorなし
```

## Case N3：Partial Snapshot

概念条件：

```text
ReadSubject = Success
ReadBodyText = Failure
```

または、

```text
ReadSubject = Failure
ReadBodyText = Success
```

Expected：

```text
Snapshot Boundary = NOT ESTABLISHED
後続Scannerへ進まない
```

P1-03のためだけにFailure Injection用Production APIを追加しない。

安全に再現できないPartial Failureは、コードReviewによるFail Fast経路確認でもよい。

---

# 14. Regression

P1-03実装後、P1-01 / P1-02で成立済みの主要経路をRegression確認する。

## P1-01

```text
ResolveWorkbookRelativePath
Local OFT Path生成
CreateMailFromTemplate
CloseWithoutSave
```

## P1-02

```text
Warm Start Readiness
Cold Start Readiness
Cold Start Visible Explorer Initialization
ReadBodyText
Inspector / WordEditor / Word Document Access
Unexpected Scan MailItem Display = NONE
Draft Residue = NONE
Inspector Residue = NONE
Existing Explorer Unexpected Close = NONE
CloseWithoutSave
```

`ReadSubject()` 追加のために既存Public APIやP1-02 Production Logicを破壊しない。

---

# 15. Code Review Gate

Production Patchに対して最低限以下をReviewする。

```text
[ ] ReadSubjectはmodOutlookAdapter内に実装されている
[ ] ReadSubject開始時にsubjectTextをvbNullStringへ初期化する
[ ] ReadSubjectは内部mMailItemを使用する
[ ] MailItemをPublic APIへ公開していない
[ ] Subject取得以外の責務を持たない
[ ] ReadSubjectはMailItemをCloseしない
[ ] ReadSubjectはMailItemをDisplayしない
[ ] Runtime Errorを未処理で伝播させない
[ ] 既存OutlookError体系を使用する
[ ] ReadBodyText Production Logicを不要に変更していない
[ ] Snapshot専用Class / DTO / Adapterを追加していない
[ ] Outlook / Word COM ObjectをCore Logicへ公開していない
[ ] P1-02 Readiness / Explorer Lifecycleを変更していない
```

---

# 16. PASS / FAIL Criteria

## 16.1 PASS

以下をすべて満たした場合、P1-03をPASS / COMPLETE候補とする。

```text
VBA Compile
= PASS

P1-01 Regression
= PASS

P1-02 Warm Start Regression
= PASS

P1-02 Cold Start Regression
= PASS

CreateMailFromTemplate
= PASS

Production ReadSubject
= PASS

Production ReadBodyText
= PASS

Baseline Subject Length
> 0

Baseline BodyText Length
> 0

Same Active MailItem
= CONFIRMED

Snapshot Boundary
= ESTABLISHED

COM Object Leakage
= NONE

Unexpected Scan MailItem Display
= NONE

Draft Residue
= NONE

Inspector Residue
= NONE

Existing Explorer Unexpected Close
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

## 16.2 FAIL

以下のいずれかをFAILとする。

```text
ReadSubjectがProduction Boundary上で成立しない
ReadSubjectで未処理Runtime Error
ReadSubject Failure時に古いsubjectTextが残る
ReadBodyText Regression
Subject / BodyTextが異なるMailItemから取得される
片方FailureでもSnapshot成立扱いとなる
Outlook / Word COM ObjectをAdapter外へ公開
ReadSubjectがMailItem Lifecycleを勝手に終了
Scan / Error途中MailItemを意図せずDisplay
Warm / Cold Start Regression Failure
不要Draft残存
不要Inspector残存
既存Explorerを意図せずClose
CloseWithoutSave Regression
P1-01 Regression Failure
```

---

# 17. Finding Classification

P1-03で問題を検出した場合は以下で分類する。

## Implementation Detail

既存Designのままコード具体化で解決できるもの。

例：

```text
ReadSubject内のNothing Check
On Error範囲
Result生成コード
Target文字列
Message文言
Smoke Test Evidence出力形式
```

## Implementation Defect

本仕様 / Designどおりの実装になっていないもの。

例：

```text
subjectText初期化漏れ
MailItem Public公開
ReadSubject内でMailItem Close
ReadBodyText不要変更
```

## Design Finding

Requirementは明確だが、既存Outlook Adapter BoundaryではSubject / BodyText Snapshotが成立せず、責務境界変更が必要となる場合。

Design FindingをP1-03内で推測修正しない。

## Requirement Gap

利用者から見た新しい振る舞い判断が必要となる場合。

例：

```text
空Subjectを利用者仕様として禁止すべきか
Snapshot取得失敗時に別経路でメールを継続すべきか
```

この種の判断をImplementation内で決めない。

## Technical Risk / Spike再判定

Subject取得は標準MailItem Property Accessであり、本Unit開始時点では追加Technical Spikeを必要としない。

通常Implementation + Verificationでは大規模手戻りを避けられない新たなTechnical Questionが具体化した場合のみ再判定する。

Technical Spike B / Cを自動的に復活させない。

---

# 18. Implementation Order

推奨実装順：

```text
1. 現行 modOutlookAdapter vP1-02 Boundary確認
   ↓
2. ReadBodyText / Result / Error Pattern確認
   ↓
3. Public ReadSubject実装
   ↓
4. VBA Compile
   ↓
5. P1-03 Smoke Test作成
   ↓
6. Subject Happy Path確認
   ↓
7. Subject / BodyText同一MailItem Snapshot確認
   ↓
8. Active MailItemなしNegative確認
   ↓
9. P1-02 Warm / Cold Regression
   ↓
10. P1-01 Regression
   ↓
11. Code Review Gate
   ↓
12. Finding判定
   ↓
13. P1-03 PASS / FAIL判定
```

---

# 19. Deliverables

P1-03の成果物候補は以下とする。

```text
Production
- 更新済み modOutlookAdapter
  - ReadSubject追加

Verification
- modP1_03TemplateSnapshotSmokeTest
- P1-03 Smoke Test Evidence

Review
- P1-03 Production Patch Review

Control
- P1-03 Completion Record（PASS後）
- Project Control Update Patch（必要な場合）
```

P1-03実施仕様自体のReviewで変更が必要な場合は、本v0.1を直接Approved扱いせず、CorrectionまたはRevisionを行う。

---

# 20. Completion後の状態

P1-03 PASS / COMPLETE後のP1 Walking Skeleton到達点は以下とする。

```text
Excel
↓
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText Snapshot
```

まだ成立していないもの：

```text
Template Scanner
Input Value
Subject Render
Word Range Body Render
Render後Subject / BodyText再取得
Unresolved Check
Final Display
```

したがってP1-03完了時点では、

```text
P1-03:
PASS / COMPLETE

CP-P1:
NOT YET ESTABLISHED
```

とする。

次のImplementation Unitでは、P1-03で確立した以下の文字列Boundaryを入力として使用する。

```text
Subject As String
BodyText As String
        ↓
Template Scanner
```

P1-03でOutlook / Word COM Boundaryへ戻って再実装しない。

---

# 21. Final Boundary Decision

```text
ReadSubject
→ P1-03 NEW

ReadBodyText
→ P1-02 REUSE / NO SEMANTIC CHANGE

Snapshot Boundary
→ Subject As String + BodyText As String

Snapshot成立
→ 同一Active MailItemに対して両ReadがSuccess

Snapshot Class / DTO
→ NOT REQUIRED

MailItem Public Exposure
→ PROHIBITED

Outlook / Word COM Exposure
→ PROHIBITED

Template Scanner
→ OUT OF SCOPE / NEXT UNIT

Requirement Change
→ NONE

Design Change
→ NONE

Test Specification Change
→ NONE

Baseline Change
→ NONE

Execution Baseline
→ BL-MVP-003
```
