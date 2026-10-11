# 引き継ぎまとめ

## 実施内容

### 1. P1-05 Minimal Render 実施仕様 v0.1 のConsistency Review反映

- 対象文書：
  - `P1-05 Minimal Render 実施仕様 v0.1.md`
- 前工程で実施済みだったConsistency Review結果：
  - `PASS WITH CORRECTIONS`
- 以下4件のCorrectionを実施仕様へ反映した。

#### CR-P1-05-001 — Technical Specification内のProject State整理

- Technical Specification内に存在していた以下のようなProject State記述を削除。
  - `Production Implementation: NOT STARTED`
  - `Consistency Review: NOT YET EXECUTED`
- Technical Specificationでは文書Statusのみを管理する方針へ統一。
- `Status = Approved` に更新。
- Project Control上の進捗状態はTechnical Specificationで管理しない方針を維持。

#### CR-P1-05-002 — Formatted Value内 `{{...}}` の扱い

- 当初の、
  - 「Formatted Value内の特殊構文を再帰展開しない」\
    という記述を修正。
- P1-05では、
  - Formatted Value内に `{{...}}` が存在した場合、それを追加Variableとして解釈するかどうか\
    を新規の利用者向け仕様として決めないことにした。
- P1-05 Smoke Test Fixtureでは当該ケースを使用しない。
- Production実装中に意味論確定が必要になった場合は、Implementation Detailで決めずRequirement Gap要否を判定する。

#### CR-P1-05-003 — Local COM Reference Cleanup

- `ReplaceBodyVariables()` で取得する以下のLocal COM Referenceについて、Function呼出しを越えて保持しないことを明記。
  - Inspector
  - Word Document
  - Word Range
- P1では既存Adapterの基本Cleanup Patternへ従う。
- COM Release / Error Pathの最終化はP6へ残した。

#### CR-P1-05-004 — P1-04 Scanner Contract整合

- Integration Smoke Testで、
  - `ScanTemplate.Success = True`\
    だけではRender開始条件としないことを明確化。
- 以下をPreconditionとして確認する手順へ修正。
  - `ScanTemplate = Success`
  - `InvalidCandidates.Count = 0`
  - Expected `ValidVariables`確認
- Invalid Candidateが存在する場合はP1-05 Render Defectではなく、
  - `Test Fixture / Precondition Finding`\
    として扱う。

### 2. P1-05 実施仕様をApproved化

更新後：

```text
P1-05 Minimal Render 実施仕様 v0.1
Status: Approved
Execution Baseline: BL-MVP-003
```

追加したセクション：

- `v0.1 Consistency Review反映概要`
- `Consistency Review結果`

最終的に、

```text
Consistency Review:
PASS WITH CORRECTIONS → CORRECTIONS APPLIED

Blocking Finding:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

とした。

---

### 3. P1-05 Production実装

P1-05実施仕様に従いProduction実装を開始。

#### 新規Production Module

作成：

- `modSubjectRenderer_P1-05_v0.1_CP932.bas`

Public API：

```vb
Public Function RenderSubject( _
    ByVal subjectText As String, _
    ByVal formattedValues As Object, _
    ByRef renderedSubject As String _
) As COperationResult
```

実装内容：

- Plain Text Subject Render
- Late Bound `Scripting.Dictionary`
- VariableName → formatted String
- Case Insensitive置換
- 全出現箇所置換
- Missing KeyはTokenを残す
- Extra KeyはNo-op
- Empty SubjectはErrorにしない
- Outlook / Word COMへ依存しない
- Input Validation / Value Formattingは実装しない
- Unresolved Checkは実装しない
- Display / MailItem Lifecycleは持たない

Subject置換にはVBA `Replace(..., vbTextCompare)` を使用。

#### modOutlookAdapter更新

作成：

- `modOutlookAdapter_P1-05_v0.1_CP932.bas`

既存のP1-02 Cold Start / WordEditor接続ロジックを維持し、P1-03の `ReadSubject()` を含む統合版として作成。

追加Public API：

```vb
Public Function SetSubject( _
    ByVal subjectText As String _
) As COperationResult
```

```vb
Public Function ReplaceBodyVariables( _
    ByVal formattedValues As Object _
) As COperationResult
```

Body Render方式：

```text
Word Document
↓
Range.Find
↓
Found Range
↓
Range.Text = replacement
↓
置換後Rangeの後方から次検索
```

採用：

- Case Insensitive
- 全出現箇所置換
- `Range.Find`
- `Range.Text`
- `wdFindStop`

不採用：

- `Word ReplaceAll`
- `MailItem.Body`全文再設定
- `HTMLBody`再構築
- Body全文再生成

COM Objectは `modOutlookAdapter` 内部へ閉じ込める。

---

### 4. Production Module差し替え方針

`modOutlookAdapter_P1-05_v0.1_CP932.bas` は既存 `modOutlookAdapter` の差し替え用統合版として使用。

手順：

```text
既存 modOutlookAdapter 削除
↓
P1-05版Import
↓
Debug → Compile VBAProject
```

同名Moduleを残したままImportしない。

ユーザー側でCompileを実施し、

```text
VBA Compile:
PASS
```

を確認済み。

---

### 5. P1-05 Test Artifact作成

#### Core Test

作成：

- `modP1_05MinimalRenderCoreTest_v0.1_CP932.bas`

確認Case：

```text
C1 Baseline Subject
C2 Case Insensitive / All Occurrences
C3 Missing Value Leaves Token
C4 Extra Value No-op
C5 Empty Subject
N1 formattedValues = Nothing
```

実行結果：

```text
C1 PASS
C2 PASS
C3 PASS
C4 PASS
C5 PASS
N1 PASS

Overall:
PASS
```

---

### 6. Warm Start Integration Test

作成：

- `modP1_05MinimalRenderIntegrationTest_v0.1_CP932.bas`

Outlook Classicを開いた状態で実施。

処理経路：

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
ScanTemplate
↓
InvalidCandidates = 0確認
↓
Expected ValidVariables確認
↓
FormattedValues Fixture
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
ReadSubject再取得
↓
ReadBodyText再取得
↓
CloseWithoutSave
```

結果：

```text
TemplatePath:
Templates\MailTemplate.oft

ResolvedPath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

ReadSubject(pre):
PASS / Length=49

ReadBodyText(pre):
PASS / Length=252

ScanTemplate:
PASS

ValidVariables Count:
4

InvalidCandidates Count:
0

RenderSubject:
PASS

SetSubject:
PASS

ReplaceBodyVariables:
PASS

ReadSubject(post):
PASS

Rendered Subject:
【ABC123】ゲート審査 2026/09/30 / ABC123

ReadBodyText(post):
PASS / Length=202

Known Baseline Tokens Remaining:
NONE

Overall:
PASS
```

---

### 7. Cold Start Integration Test

Outlook Classicを完全終了した状態で同じIntegration Testを実行。

結果：

```text
TestP105MinimalRenderIntegration:
PASS
```

Cold Startでも、

- Outlook Explorer自動起動
- WordEditor取得
- Subject / Body Render
- Render後Snapshot
- CloseWithoutSave

が成立。

---

### 8. P1-02 Warm / Cold Regression

既存：

- `modP1_02InspectorWordEditorSmokeTest_v0.2.2_CP932.bas`

を使用。

#### Warm Start

結果：

```text
Explorer Count Before: 1
Explorer Count After Readiness: 1

Warm Start Existing Explorer Reuse:
PASS

ReadBodyText:
PASS

CloseWithoutSave:
PASS

Explorer Count After: 1
Draft Count: 18 → 18
Inspector Count: 0 → 0

Explorer Lifecycle:
PASS

Draft Residue:
NONE

Inspector Residue:
NONE

Scan MailItem Display:
NONE

Overall:
PASS
```

#### Cold Start

結果：

```text
Explorer Count Before: 0

CreateMailFromTemplate:
PASS

ReadBodyText:
PASS

Cold Start Evidence Reacquisition:
PASS

Explorer Count Lifecycle Baseline:
1

Inspector Count During ReadBodyText:
1

CloseWithoutSave:
PASS

Explorer Count After:
1

Draft Count:
18 → 18

Inspector Count After:
0

Explorer Lifecycle:
PASS

Draft Residue:
NONE

Inspector Residue:
NONE

Scan MailItem Display:
NONE

Cold Start Visible Explorer Initialization:
PASS

Overall:
PASS
```

---

### 9. Negative Test v0.2作成

初版Negative Testでは、N3とN5が独立確認されていないTest Artifact Gapが見つかった。

Production Defectではなく、

```text
Test Artifact Gap
/
Verification Coverage Gap
```

として扱った。

新規作成：

- `modP1_05MinimalRenderNegativeTest_v0.2_CP932.bas`

仕様どおりN1〜N5を整理。

#### N1

```text
N1a RenderSubject(Nothing)
N1b ReplaceBodyVariables(Nothing)
```

Expected：

- Failure Result
- 未処理Runtime Errorなし

#### N2

```text
Active MailItemなし
+
SetSubject
```

Expected：

- Failure

#### N3

```text
Active MailItemなし
+
正常FormattedValues Dictionary
+
ReplaceBodyVariables
```

重要：

- `Nothing`を渡すのではなく正常Dictionaryを渡し、
- FormattedValues ValidationではなくActive MailItem Boundaryまで到達させる。

#### N4

```text
Missing Formatted Value
```

Expected：

- RendererはSuccess
- Missing Tokenは残る

#### N5

```text
Body Find 0
```

Test Fixture限定：

```text
P105NotInBody = dummy
```

を使用。

Expected：

- `ReplaceBodyVariables = PASS`
- BodyText不変

---

### 10. Negative Test結果

実行結果：

```text
N1a RenderSubject(Nothing): PASS
N1b ReplaceBodyVariables(Nothing): PASS
N2 SetSubject without Active MailItem: PASS
N3 ReplaceBodyVariables without Active MailItem: PASS
N4 Missing Formatted Value: PASS
N5 Body Find 0: PASS

Overall:
PASS
```

これによりNegative Verification Coverage Gapは解消。

---

### 11. Production Patch Review

作成：

- `P1-05 Minimal Render Production Patch Review v0.1.md`

Review対象：

```text
modSubjectRenderer_P1-05_v0.1_CP932.bas
modOutlookAdapter_P1-05_v0.1_CP932.bas
```

Verification：

```text
Core Test
Warm Integration
Cold Integration
Negative Test
P1-02 Warm / Cold Regression
```

最終結果：

```text
Static Review:
PASS

VBA Compile:
PASS

Core Verification:
PASS

Warm Integration:
PASS

Cold Integration:
PASS

Negative Verification N1-N5:
PASS

P1-02 Lifecycle Regression:
PASS

Required P1-01～P1-04 Regression:
PASS

Scope Boundary:
PASS

Production Change Required:
NONE

Blocking Finding:
NONE

RESULT:
PASS
```

---

### 12. Finding Assessment

作成：

- `P1-05 Minimal Render Finding Assessment v0.1.md`

最終Finding：

```text
Implementation Defect:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Technical Finding:
NONE

Production Render Defect:
NONE

Regression Finding:
NONE

Lifecycle Finding:
NONE

Blocking Finding:
0
```

途中で検出した：

```text
TF-P1-05-001
Negative Verification Coverage Gap
```

は、

```text
RESOLVED
NON-BLOCKING
```

とした。

---

### 13. N6 WordEditor Failureの扱い

Approved仕様上のN6：

```text
WordEditor取得失敗
```

について専用Runtime Fault Injectionは実施していない。

理由：

- P1-05専用Failure Injection Public APIをProductionへ追加しない
- 安全に再現可能な既存Test経路がない場合はStatic Reviewでよい
- WordEditor / COM Error Pathの最終化はP6責務

判定：

```text
N6 WordEditor Failure Injection
→ DEFERRED TO P6 AS DESIGNED
→ NON-BLOCKING
```

---

### 14. P1-05 Completion Record

作成：

- `P1-05 Minimal Render Completion Record v0.1.md`

Completion Criteria：

```text
Approved Unit Specification       PASS
VBA Compile                       PASS
Subject Render Core               PASS
Subject Integration               PASS
Body Word Range Render            PASS
Render後Snapshot                  PASS
Lifecycle                         PASS
必要Regression                    PASS
Production Patch Review           PASS
Blocking Finding = 0              PASS
```

最終判定：

```text
P1-05 Minimal Render
PASS / COMPLETE
```

ただし、

```text
P1-05 COMPLETE
≠
CP-P1 ESTABLISHED
```

P1 Walking Skeletonではまだ以下が残る。

```text
P1-06 Minimal Unresolved Checker
↓
P1-07 Display / E2E Integration
↓
P1 Phase Verification
↓
CP-P1 Establishment Candidate
```

---

## 決定事項

- `P1-05 Minimal Render 実施仕様 v0.1` はCorrection 4件を反映し、`Status = Approved` とした。
- P1-05 Production実装は以下2Moduleで実施する。
  - `modSubjectRenderer`
  - `modOutlookAdapter`
- Subject RenderはCore LogicとしてOutlook / Word COMから分離する。
- Subject置換はCase Insensitiveかつ全出現箇所置換とする。
- `formattedValues` はLate Bound `Scripting.Dictionary` を使用する。
- P1-05ではRaw Input / Validation / Formattingを扱わず、既Format済みStringを受け取る。
- `SetSubject()` は `modOutlookAdapter` のPrivate Active MailItem Subject設定のみを担当する。
- Body RenderはWord `Range.Find / Range.Text` 方式を採用する。
- Word `ReplaceAll` は採用しない。
- Body全文再設定は行わない。
- Word / Outlook COM Objectは `modOutlookAdapter` 内へ閉じ込める。
- Missing Formatted ValueはP1-05ではRender Errorにせず、Tokenを残す。
- Unresolved判定はP1-06の責務とする。
- Body Find 0件はSuccessとする。
- Empty Subject自体はP1-05 Infrastructure Errorにしない。
- P1-05でFormatted Value内 `{{...}}` の意味論は新規定義しない。
- P1-05ではValue Formatterを実装しない。
- P1-05ではFinal Displayを実装しない。
- P1-05ではCurrent Template / Configuration Guardを実装しない。
- P1-02 Warm / Cold Start Readinessは既存仕様を維持する。
- Cold Startで起動したExplorerはP1-05処理終了時にCloseしない。
- P1-05 Negative VerificationはN1〜N5を正式確認対象とした。
- N6 WordEditor Failure InjectionはP6へDeferred、Non-blockingとした。
- P1-05実装後のP1-01〜P1-04 Regressionは全Test再実施ではなく、変更影響に応じた必要最小限でよい。
- P1-05 Production Codeの追加修正は不要と判定した。
- `TF-P1-05-001 Negative Verification Coverage Gap` はResolvedとした。
- Requirement Gapは発生していない。
- Design Findingは発生していない。
- Technical Spike再開は不要。
- BL-MVP-003の更新は不要。
- P1-05は正式に `PASS / COMPLETE` と判定した。
- P1-05完了だけではCP-P1は成立しない。
- 次Implementation Unitは `P1-06 Minimal Unresolved Checker` とする。

---

## 未解決事項

### P1-06 Minimal Unresolved Checker

未着手。

今後確認が必要：

```text
Render後 Subject / BodyText Snapshot
↓
Unresolved Checker
```

の具体Boundary。

主な論点候補：

- Unresolved Candidate検出方式
- Subject / Body両方の検出
- Case handling
- ScanTemplate再利用有無
- Result Carrier
- Unresolved一覧の表現
- Invalid Candidateとの責任分離
- P1最小版とP5正式版のScope境界
- Error / Result分類

これらはまだ未決定。

### P1-07 Display / E2E Integration

未着手。

P1-06完了後に、

```text
Render
↓
Unresolved Check
↓
Display
```

を接続する必要がある。

### CP-P1

未成立。

```text
CP-P1 = NOT YET ESTABLISHED
```

P1-06 / P1-07 / P1 Phase Verification完了後に判定する。

### N6 WordEditor Failure Runtime Verification

未実施。

```text
DEFERRED TO P6
```

P1-05 Completion上はBlockingではない。

### P5 / P6へ残した事項

P1-05では以下のFormal Guaranteeは未確認。

```text
Optional空欄
Date Format 6種類
特殊文字
基本書式保証
Range Loop最終Edge Case
Current Data Guard
正式Unresolved Error
Final Display Gate
COM Error / Lifecycle Finalization
```

---

## 次アクション

### 優先度1：P1-06 Minimal Unresolved Checker Boundary確認

最初に見るべき文書：

- `MVP Requirements v0.1.9 日本語版.md`
- `MVP Design v0.1.9 日本語版.md`
- `MVP Test Specification v0.1.5 日本語版.md`
- `Implementation Plan v0.3 日本語版`
- `P1-05 Minimal Render 実施仕様 v0.1.md`
- `P1-05 Minimal Render Completion Record v0.1.md`

再開ポイント：

```text
P1-05 Output Boundary
=
Rendered Subject As String
+
Rendered BodyText As String
```

ここをP1-06の入力として、Unresolved Checkerの責務境界を確認する。

### 優先度2：P1-06 Requirement / Design / Test / Plan整合確認

確認すること：

```text
Requirement Conflict
Design Conflict
Test Specification Conflict
Implementation Plan Conflict
P1-05 Boundary Conflict
Requirement Gap
Design Finding
Technical Spike Reopen
Baseline Change
```

利用者向け新挙動が必要ならImplementation Detailで決めずRequirement Gapへ戻す。

### 優先度3：P1-06 実施仕様作成

Boundary確定後、

```text
P1-06 Minimal Unresolved Checker 実施仕様 v0.1
```

を作成。

### 優先度4：Consistency Review

Requirement / Design / Test Specification / Plan / P1-05とのConsistency Reviewを実施。

PASS後にApproved化。

### 優先度5：Production実装

Approved後にProduction Codeを実装。

P1-05 Production CodeへUnresolved Checkerを追加しない。

---

# 記事用素材

## 気づき

- 「TestがPASSした」だけではImplementation Unit Completionにはならない。

  - Compile
  - Core
  - Integration
  - Lifecycle
  - Regression
  - Negative
  - Static Review
  - Finding Assessment\
    を明示的に閉じることで、初めて「Complete」と言える。

- Production DefectとTest Artifact Defectを分けることが重要だった。

  - N3 / N5不足はProduction Codeの欠陥ではなく、Test Coverage側の不足だった。
  - Test失敗や不足をすぐProduction修正へ結び付けないことが重要。

- Negative Testでは「どこでFailureさせたいか」を意識する必要がある。

  - `ReplaceBodyVariables(Nothing)` ではFormattedValues Validationで止まる。
  - Active MailItem Boundaryを検証したいなら、正常Dictionaryを渡す必要がある。

- Cold Start / Warm Startを分けてTestする価値が高い。

  - Warm Startでは既存Explorer再利用。
  - Cold StartではVisible Explorer自動起動。
  - 同じ機能でもLifecycle条件が異なる。

- OutlookのExplorerとMailItem Displayは別物。

  - Cold Start時にExplorerを表示することは必要。
  - Scan / Render中のMailItem自体は表示しない。
  - 「何が表示されたか」をObject単位で区別する必要がある。

- Word本文置換ではBody全文を再構築しない設計が有効。

  - `Range.Find`
  - `Range.Text`\
    を使うことでOFTの書式構造を維持しやすい。

- 「全部を今完成させない」ことがMVP実装では重要。

  - Range Loopの基本形はP1。
  - Edge Case最終化はP5。
  - COM Error / Lifecycle最終化はP6。\
    と段階分けした。

- Implementation中に仕様を勝手に決めないルールが有効だった。

  - Formatted Value内 `{{...}}` のような曖昧な意味論をImplementation Detailで決定しなかった。
  - 必要ならRequirement Gapへ戻す。

- Technical SpecificationにProject進捗状態を書かない方が運用しやすい。

  - Technical Specification = What is true
  - Project Control = Where we are now
  - Completion Record = Unitが完了したEvidence

- 「同じModuleを更新する」場合でも、既存UnitのRegressionが重要。

  - `modOutlookAdapter` をP1-05版へ置換したため、P1-02 Warm / Cold Lifecycleを再確認した。
  - 新機能がPASSしても、既存機能を壊していればCompletionではない。

---

## 記事にできそうな切り口

### 開発日記向き

- 「AIと一緒にVBAツールを作る：P1-05 Minimal Renderが完成するまで」
- 「テストが全部PASSしたのに、まだCompleteではなかった話」
- 「Productionのバグだと思ったらTest Artifactの不足だった」
- 「Outlook VBAのWarm Start / Cold Startを分けて検証してみた」
- 「AI協働開発で“実装しすぎない”ためのPhase分割」
- 「仕様にないことをAIに勝手に決めさせない運用」
- 「Excel VBA + Outlook ClassicでWalking Skeletonを1段ずつ作る」
- 「Completion Recordを作ると個人開発でも“終わった”が明確になる」
- 「P1-05であえてDisplayまで実装しなかった理由」
- 「Word本文置換をHTML再生成ではなくRange操作にした理由」

### 技術記事向き

- 「Outlook OFT本文をWord Range.Find / Range.Textで安全に置換するVBA設計」
- 「VBAでCase Insensitiveな `{{Variable}}` 置換を実装する」
- 「Outlook Classic VBAでWarm Start / Cold Startを検証する方法」
- 「MailItem.GetInspector / WordEditorのLifecycle設計」
- 「VBAでCOM ObjectをAdapter内部に閉じ込める」
- 「Subject RendererとOutlook Adapterを分離する設計」
- 「Scripting.DictionaryをRender Boundaryに使う理由」
- 「Negative TestでFailure Pointを正しく狙う方法」
- 「Missing ValueをRenderer ErrorにせずUnresolved Checkerへ分離する設計」
- 「VBAで全出現置換するWord Range.Find Loopの基本形」
- 「Production DefectとTest Fixture/Test Artifact Defectの分類方法」
- 「Walking Skeletonでどこまで実装するか：P1 / P5 / P6の責任分界」
- 「Compile / Runtime / Regression / Negative / Static Reviewを分けたVBAテスト戦略」
- 「Snapshot Boundary：COM Objectを後段へ渡さずStringに落とす設計」

---

## 有料note / テンプレート化候補

### Implementation Unit Specification Template

以下を標準項目化できる。

```text
Purpose
Baseline
Precondition
Scope
Out of Scope
Responsibility Boundary
Public API
Error / Result
Lifecycle
Production Flow
Smoke Test
Negative Verification
Regression
Compile Evidence
Completion Criteria
Finding Classification
Document Impact
```

### Consistency Review Template

```text
Requirement Conflict
Design Conflict
Test Specification Conflict
Implementation Plan Conflict
Previous Unit Boundary Conflict
Semantic Conflict
Traceability Break
Requirement Gap
Design Finding
Technical Spike Reopen
Baseline Change
```

### Production Patch Review Checklist

```text
Static Review
Compile
Core Test
Warm Integration
Cold Integration
Negative Verification
Lifecycle
Regression
Scope Boundary
Production Hard Coding
COM Exposure
Production Change Required
Blocking Finding
```

### Finding Assessment Template

分類候補：

```text
Implementation Detail
Implementation Defect
Test Artifact Defect
Test Fixture Drift
Verification Coverage Gap
Design Finding
Requirement Gap
Technical Finding
Regression Finding
Lifecycle Finding
```

### Completion Record Template

```text
Completion Criteria
Evidence
Established Boundary
Public API
Verified Behavior
Explicitly Not Completed
Finding Status
Baseline Impact
Final Decision
Next Unit
```

### AI協働開発向け判断プロンプト

再利用可能な判断ルール：

```text
これは既存Designの実装詳細か？
Requirementは明確だがDesignが足りないか？
利用者向け新挙動を決めようとしていないか？
重大な技術的不確実性があるか？
```

分類：

```text
Implementation Detail
Design Finding
Requirement Gap
Technical Spike Reopen
```

### Regression Scope判断チェックリスト

- 変更したModuleは何か
- そのModuleを過去のどのUnitが利用しているか
- 全Test再実行が必要か
- 既存Integration Testで代替Evidenceを取れるか
- Lifecycle条件が変わるか
- Warm / Cold両方が必要か

### Negative Test設計チェックリスト

- 何をFailureさせたいか
- その前段Validationで止まっていないか
- 本当に目的のBoundaryまで到達しているか
- ProductionへTest専用APIを追加していないか
- 再現困難なFailureを無理に作っていないか
- 後続PhaseへDeferredすべきか

### VBA / Outlook用Smoke Testテンプレート

特に以下のEvidence項目はテンプレート化しやすい。

```text
Outlook Start State
Explorer Count Before / After
Draft Count Before / After
Inspector Count Before / During / After
CreateMailFromTemplate
ReadSubject
ReadBodyText
CloseWithoutSave
Unexpected MailItem Display
```
