# P1-07 Display / E2E Integration 実施仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-07 Display / E2E Integration 実施仕様 |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Implementation Unit Specification |
| Status | Approved |
| Current Execution Baseline | BL-MVP-003 |
| 対象Phase | P1 Walking Skeleton |
| 対象Implementation Unit | P1-07 Display / E2E Integration |
| Primary Production Module | `modMailApplication` |
| Supporting Production Module | `modOutlookAdapter` |
| 前提Implementation Unit | P1-06 Minimal Unresolved Checker = PASS / COMPLETE |
| Primary Verification | Warm / Cold E2E Display + Unresolved Fail Closed + Lifecycle + No Auto Send |
| Formal MVP Test | 本Unitでは実施しない |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `DOC-TS-A` — Technical Spike A
- `P1-02 Inspector / WordEditor Connection 実施仕様 v0.2`
- `P1-03 Template Snapshot Boundary 実施仕様 v0.1`
- `P1-04 Minimal Template Scanner 実施仕様 v0.1`
- `P1-05 Minimal Render 実施仕様 v0.1`
- `P1-05 Minimal Render Completion Record v0.1`
- `P1-06 Minimal Unresolved Checker 実施仕様 v0.1`
- `P1-06 Minimal Unresolved Checker Completion Record v0.1`
- `P1-07 Display / E2E Integration Boundary Confirmation v0.1`
- `P1-07 Display / E2E Integration 実施仕様 v0.1 Cross-document Consistency Review v0.1`

### v0.1 Consistency Review反映概要

`P1-07 Display / E2E Integration 実施仕様 v0.1 Cross-document Consistency Review v0.1` の結果を反映し、本v0.1をApprovedとした。

Review結果：

```text
PASS WITH CORRECTIONS
```

Approval前Correctionとして以下4件を反映した。

1. `CR-P1-07-001` — MVP Test Specification参照範囲を精密化し、`MTS-MAIL-001` はP1 Walking Skeletonで成立するDisplay経路部分、`MTS-MAIL-004` はUnresolved Error分岐部分のみをImplementation Verification対象とすることを明記した。Configuration Errorを含む正式Test全体のPASSとは扱わない
2. `CR-P1-07-002` — Cleanup Failure時のPrimary Error / Cleanup Errorの優先順位・統合方式をP1-07で最終固定しないよう修正した。P1-07では「Cleanup Failureを成功扱いせず、Overall Failureとし、Cleanup Failureを隠さない」ことまでをContractとし、複数Errorの保持・優先順位・User Message統合はP6へ残した
3. `CR-P1-07-003` — `DisplayMail()` 成功後の `mMailItem` Reference解放はDisplayed MailItemのClose / Save / Sendを意味しないことを明記し、P1基本COM Reference処理とP6の最終COM Release設計の境界を明確化した
4. `CR-P1-07-004` — Approved Technical DocumentからDraft専用のReview予定・次工程記述を除去し、Consistency Review実施済み状態とApproved Resultへ更新した

本CorrectionによるRequirement / Design / Test Specification / Implementation Plan / BaselineへのSemantic Impactはない。

**Consistency Review：PASS WITH CORRECTIONS → CORRECTIONS APPLIED**
**Blocking Finding：NONE**
**Semantic Conflict：NONE**
**Requirement Gap：NONE**
**Design Finding：NONE**
**Technical Finding：NONE**
**Technical Spike Reopen：NOT REQUIRED**
**Baseline Change：NOT REQUIRED**
**Document Status：Approved**

### v0.1 作成概要

`P1-07 Display / E2E Integration Boundary Confirmation v0.1` で確定した責務境界を、Production実装可能なImplementation Detailへ具体化する。

本Unitでは以下を行う。

1. P1-01～P1-06で成立したProduction Boundaryを `modMailApplication` で1本のE2E Flowへ接続する
2. `modOutlookAdapter` に最終MailItem表示用 `DisplayMail()` を追加する
3. `CheckUnresolved()` のResultをDisplay Gateへ接続する
4. `CheckUnresolved.Success=True` かつ `HasUnresolved=False` の場合のみDisplayを許可する
5. Unresolved 1件以上ではMailItemをDisplayせず、`Variables` を保持したまま `CloseWithoutSave()` する
6. Unresolved判定を `ErrorType="RenderError"` に依存させない
7. Technical FailureやResult不整合も成功側へ倒さずFail Closedとする
8. Success時は最終MailItemをDisplayし、ツール側から自動Sendしない
9. Display成功後はMailItemの所有をユーザー側へ移し、Adapterから自動Closeしない
10. Warm Start / Cold Start双方でP1 Walking Skeleton E2EをImplementation Verificationする
11. `MTS-UNR-002` 相当、および `MTS-MAIL-004` のUnresolved Error分岐相当のScenarioを確認するがFormal Test PASSとは扱わない
12. P5のCurrent Data Guard、P6のError / Safety / Lifecycle最終化を先回り実装しない

本仕様はBL-MVP-003で承認済みのRequirement / Design / Test Definition、およびP1-07 Boundary ConfirmationをImplementation Detailへ具体化するものである。

新しい利用者向けRequirement、Design Decision、Test Definitionを追加しない。

**Change Type：Implementation Detail / Unit Specification**
**Requirement Impact：None**
**Design Impact：None**
**Test Specification Impact：None**
**Baseline Impact：None**
**Technical Spike Reopen：Not Required**

---

# 2. 目的

P1-07の目的は、最終ArchitectureのModule境界を維持したまま、P1 Walking Skeletonの最後の区間である、

```text
Render
↓
Post-Render Snapshot
↓
Unresolved Check
↓
Display Gate
├─ Display
└─ Fail Closed
```

をProduction Orchestrationとして成立させることである。

P1-07完了時には、正常なBaseline Fixtureについて、

```text
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
Create MailItem
↓
Subject / Body Snapshot
↓
Template Scan
↓
FormattedValues
↓
Subject Render
↓
Body Render
↓
Post-Render Snapshot
↓
Unresolved Check
↓
Display
```

が本番Architecture上で端から端まで通ることを確認する。

またUnresolved Variableが残る場合、

```text
Unresolved Check
↓
Failure
↓
No Display
↓
CloseWithoutSave
```

となり、不完全なMailItemを利用者へ表示しないことを確認する。

P1-07はP1 Walking Skeletonの最終Implementation Unitであるが、P1 Phase VerificationおよびCP-P1判定そのものは別工程とする。

---

# 3. Baseline上の根拠

## 3.1 Requirement

`DOC-MVP-REQ` では未置換Variableについて、

```text
SubjectまたはBodyに
{{VariableName}}
形式の未置換変数が1件でも残っている場合、
メール生成を中止する。
```

ことが要求されている。

また、

```text
Validation
Render
Unresolved Check
```

が成功した場合のみ、生成結果をClassic OutlookへDisplayする。

MVPでは自動送信を行わない。

したがってP1-07では、

```text
全Gate成功
→ Display

Unresolvedあり
→ No Display

ツール処理
→ Sendしない
```

をProduction Flowへ接続する。

---

## 3.2 Design

`DOC-MVP-DES` ではUnresolved Check後の基本Flowを以下としている。

```text
Render
↓
Unresolved Checker
↓
UnresolvedCheckResult
├─ 0件 → Outlook Display
└─ 1件以上 → Error Result → UI一覧表示
```

メール生成Sequenceでは、

```text
Unresolvedあり
↓
未置換Variable一覧
↓
MailItem表示せず保存せずClose
```

と定義されている。

またOutlook AdapterのMailItem Boundaryには、

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
DisplayMail()
CloseWithoutSave()
```

が定義されている。

P1-07ではこのうち、

```text
DisplayMail()
```

をProduction Boundaryへ追加し、既存、

```text
CloseWithoutSave()
```

をFail Closed Cleanupとして再利用する。

---

## 3.3 Test Specification

`DOC-MVP-TESTSPEC` の関連Testは以下である。

```text
MTS-UNR-001
正常系未置換0件

MTS-UNR-002
未置換1件以上でDisplay停止

MTS-MAIL-001
成功時Classic Outlook Display

MTS-MAIL-002
自動送信されない

MTS-MAIL-003
Scan用MailItem保存なしClose

MTS-MAIL-004
Error時生成MailItem非表示 / 保存なしClose
```

P1-07ではこれらのFormal Test Resultを作成しない。

P1-07 Verificationでは、上記Test DefinitionをImplementation Verificationの観点として使用する。ただしP1-07はP1 Walking Skeletonであり、後続Phaseの責務を含むTest Case全体をP1-07だけで満たしたとは扱わない。

参照範囲は以下とする。

```text
MTS-UNR-002
→ Scenario全体に直接対応
→ 未置換あり / No Display / CloseWithoutSave

MTS-MAIL-001
→ P1 Walking Skeletonで成立するWarm / Cold Display経路部分を参照
→ P4 / P5で完成する正式Validation経路の完了を意味しない

MTS-MAIL-002
→ No Auto Send観点を参照

MTS-MAIL-003
→ P1-01～P1-06 RegressionとしてScan用MailItem Lifecycle観点を参照

MTS-MAIL-004
→ Unresolved Error分岐のみを参照
→ Configuration Error分岐はP1-07の直接Verification対象外
```

したがってP1-07で得たPASSは、

```text
P1-07 Implementation Verification PASS
```

を意味するが、

```text
Formal MTS-UNR-002 PASS
Formal MTS-MAIL-001 PASS
Formal MTS-MAIL-002 PASS
Formal MTS-MAIL-003 PASS
Formal MTS-MAIL-004 PASS
```

とは扱わない。

---

## 3.4 Implementation Plan

`DOC-MVP-IMPL` のP1 Walking Skeletonでは以下の最小E2Eが要求されている。

```text
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
Create MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText
↓
Template Scanner
↓
Input Value
↓
Subject Render
↓
Word Range Body Render
↓
Post-Render Snapshot
↓
Unresolved Check
↓
Display
```

P1-06完了時点で、

```text
Unresolved Check
```

まで成立済みである。

P1-07は、

```text
Unresolved Check
↓
Display Gate
↓
Display / Fail Closed
```

をProduction Orchestrationへ接続する。

---

## 3.5 Boundary Confirmation

P1-07 Boundary Confirmationでは以下を確定済みとする。

```text
Display Allowed
=
CheckUnresolved.Success = True
AND
unresolvedResult exists
AND
HasUnresolved = False
```

Unresolved Failureは、

```text
CheckUnresolved.Success = False
+
unresolvedResult exists
+
HasUnresolved = True
```

で識別可能とする。

`ErrorType="RenderError"` はUnresolved Failure判定条件としない。

正式なUnresolved Error taxonomy / Error Code / User-facing MessageはP6で最終化する。

---

# 4. 前提Implementation Boundary

## 4.1 P1-01

P1-01により以下が成立済みである。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
Active MailItem
↓
CloseWithoutSave
```

OneDrive Web URL環境ではLocal Windows Pathへ解決する。

P1-07ではPath Resolutionを再設計しない。

---

## 4.2 P1-02

P1-02により以下が成立済みである。

```text
Classic Outlook Readiness
Existing Explorer reuse
Cold Start Visible Explorer Initialization
Inspector
WordEditor
Word Document
ReadBodyText
```

Outlook / Word COM Objectは `modOutlookAdapter` 内部へ閉じ込められている。

P1-07ではReadiness方式を再設計しない。

---

## 4.3 P1-03

P1-03により同一Active MailItemから、

```text
ReadSubject()
ReadBodyText()
```

を使用してString Snapshotを取得可能である。

P1-07でもPre-Render / Post-Render Snapshotはこの既存APIを使用する。

---

## 4.4 P1-04

P1-04では以下が成立済みである。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

Minimal Result：

```text
scanResult
├─ ValidVariables
└─ InvalidCandidates
```

P1-07ではScannerを再実装しない。

P1 E2E上の最低限のFail Fastとして、

```text
ScanTemplate.Success = True
AND
InvalidCandidates.Count = 0
```

をRender開始条件とする。

これは完成版Configuration Validatorの代替ではなく、P1 Walking Skeletonで既に成立しているScanner Contractを尊重するための最小Gateである。

---

## 4.5 P1-05

P1-05により以下が成立済みである。

```vb
Public Function RenderSubject( _
    ByVal subjectText As String, _
    ByVal formattedValues As Object, _
    ByRef renderedSubject As String _
) As COperationResult
```

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

Render API自身はMailItemをDisplay / Closeしない。

P1-07ではこの責務分離を維持する。

---

## 4.6 P1-06

P1-06により以下が成立済みである。

```vb
Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

Result：

```text
unresolvedResult
├─ "HasUnresolved" → Boolean
└─ "Variables"     → Collection
```

Unresolved 0件：

```text
Success = True
HasUnresolved = False
Variables.Count = 0
```

Unresolved 1件以上：

```text
Success = False
HasUnresolved = True
Variables.Count >= 1
```

Technical Failure：

```text
Success = False
unresolvedResult = Nothing
```

P1-07はこのContractを変更しない。

---

# 5. Scope

P1-07のProduction実装対象は以下とする。

```text
modMailApplication
├─ P1 E2E Orchestration
├─ Settings.TemplatePath取得
├─ Path Resolution
├─ CreateMailFromTemplate接続
├─ Snapshot取得
├─ Scan Gate
├─ Render接続
├─ Post-Render Snapshot取得
├─ CheckUnresolved接続
├─ Display Gate
├─ Failure時Cleanup Orchestration
└─ Result返却

modOutlookAdapter
├─ DisplayMail()追加
├─ Active MailItem Display
├─ Display成功後のOwnership Transfer
├─ Display ErrorのResult変換
└─ 自動Sendなし

既存Production API再利用
├─ GetSetting相当
├─ ResolveWorkbookRelativePath
├─ CreateMailFromTemplate
├─ ReadSubject
├─ ReadBodyText
├─ ScanTemplate
├─ RenderSubject
├─ SetSubject
├─ ReplaceBodyVariables
├─ CheckUnresolved
└─ CloseWithoutSave
```

Verificationでは以下を行う。

```text
Warm Start Normal E2E
+
Cold Start Normal E2E
+
Unresolved Fail Closed
+
No Auto Send
+
Lifecycle
+
Compile
+
P1-01～P1-06必要Regression
```

---

# 6. Out of Scope

P1-07では以下を実装しない。

```text
Dynamic UserForm
Input State
Raw Input取得
Input Validator完成
Date Parse
Date 6 Format Production完成
Value Formatter Production完成
OptionMaster Validation
VariableDefinition正式Validation
Configuration Validator完成
Sync Engine
Current OFT Guard完成
Current VariableDefinition Guard
Current OptionMaster Guard
UserForm表示後変更検出
Optional空欄Formal Guarantee
特殊文字Formal Guarantee
Body基本書式Formal Test
Range.Find最終Edge Case
正式Unresolved Error taxonomy
正式Error Code体系
正式User-facing Error Message
Error UI
Validation UI
P6レベル全COM Error統合
P6レベルCOM Release最終化
Formal MVP Test
Test Candidate Build固定
CP-P1判定
```

またP1-07のためだけに以下を追加しない。

```text
新しいAdapter
Display専用Interface
MailItem Wrapper Class
MailItemを返すPublic API
Inspectorを返すPublic API
WordEditorを返すPublic API
Word Documentを返すPublic API
Unresolved専用Application Class
Test専用Production Public API
独自Exception Framework
```

---

# 7. Responsibility Boundary

## 7.1 Production Boundary

P1-07完了時の責務境界は以下とする。

```text
UI / Test Harness
        │
        │ formattedValues
        ▼
──────────────────────────────────
Application Boundary
──────────────────────────────────
        │
        ▼
modMailApplication
        │
        ├─ Sequence Control
        ├─ Fail Fast
        ├─ Display Gate
        └─ Cleanup Orchestration
        │
        ├───────────────┐
        ▼               ▼
Core Logic          Infrastructure
        │               │
        ▼               ▼
Scanner             modOutlookAdapter
Renderer            - MailItem
Unresolved Checker  - WordEditor
                    - DisplayMail
                    - CloseWithoutSave
```

COM ObjectをApplication / Coreへ公開しない。

---

## 7.2 modMailApplication責務

`modMailApplication` は以下を担当する。

```text
処理順序
Result確認
次処理へ進むかの判定
Display Gate
Failure時Cleanup呼出
```

以下を直接実装しない。

```text
Excel ListObject操作
Outlook Object Model操作
Word Object Model操作
Variable Token Regex
Subject置換ロジック
Word Range置換ロジック
Unresolved Token抽出ロジック
MsgBox
```

---

## 7.3 modOutlookAdapter責務

`modOutlookAdapter` は以下を担当する。

```text
Classic Outlook Readiness
MailItem生成
Subject / Body読取
Subject設定
Body Word Range Render
MailItem Display
保存なしClose
COM Object局所化
```

P1-07で新しく追加する責務は、

```text
DisplayMail()
```

のみとする。

---

## 7.4 modUnresolvedChecker責務

`modUnresolvedChecker` はP1-06 Contractを維持する。

```text
Render後Snapshot
↓
Token残存判定
↓
HasUnresolved
+
Variables
+
COperationResult
```

以下を行わない。

```text
Display
Close
Cleanup
UI通知
再Render
```

---

## 7.5 Test Harness責務

Test Harnessは、

```text
Fixture生成
開始状態設定
Evidence取得
Explorer / Draft / Inspector件数取得
Displayed MailItemの手動確認補助
Test終了後の環境復旧
```

を行ってよい。

ただしProduction Boundaryを迂回して、

```text
WordEditorへ直接アクセス
Production MailItemを直接編集
Production Display Gateを直接上書き
```

してはならない。

---

# 8. Production Module

P1-07で変更対象となるProduction Moduleは以下とする。

```text
modMailApplication
modOutlookAdapter
```

原則として、

```text
modTemplateScanner
modSubjectRenderer
modUnresolvedChecker
modSettingsData
modResult
```

は変更しない。

既存Module変更が必要となった場合はFindingとして影響範囲を再評価する。

---

# 9. modMailApplication Public API

## 9.1 採用API

P1-07では以下をProduction Public APIとして採用する。

```vb
Public Function CreateMailForDisplay( _
    ByVal formattedValues As Object, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

これはP1 Walking SkeletonにおけるMail Creation Orchestrationの最小Entry Pointとする。

---

## 9.2 Input

```text
formattedValues
```

はP1-05で確立したBoundaryと同じ、

```text
Late Bound Scripting.Dictionary
VariableName → Formatted String
```

とする。

P1-07ではRaw InputからFormattedValuesを生成しない。

TestではP1-05 / P1-06と同じBaseline Fixtureを使用する。

---

## 9.3 Output

戻り値：

```text
COperationResult
```

追加Output：

```text
unresolvedResult As Object
```

とする。

開始時：

```vb
Set unresolvedResult = Nothing
```

とする。

Unresolved 1件以上でFail Closedする場合も、検出済み`unresolvedResult`は保持する。

---

## 9.4 Success

Success条件：

```text
全P1-07 Production Step成功
AND
CheckUnresolved.Success = True
AND
HasUnresolved = False
AND
DisplayMail = Success
```

Expected：

```text
CreateMailForDisplay.Success = True
unresolvedResult exists
HasUnresolved = False
Variables.Count = 0
Final MailItem = Displayed
Auto Send = NONE
```

---

## 9.5 Failure

以下のいずれかでFailureとする。

```text
Settings取得Failure
Path Resolution Failure
CreateMailFromTemplate Failure
Pre-Render Snapshot Failure
ScanTemplate Failure
InvalidCandidates >= 1
RenderSubject Failure
SetSubject Failure
ReplaceBodyVariables Failure
Post-Render Snapshot Failure
CheckUnresolved Technical Failure
Unresolved 1件以上
Unresolved Result Contract不整合
DisplayMail Failure
Cleanup Failure
Unexpected Orchestration Error
```

MailItem生成後のFailureでは、可能な範囲で`CloseWithoutSave()`を実行する。

---

# 10. DisplayMail API

## 10.1 Production Module

```text
modOutlookAdapter
```

---

## 10.2 Public API

P1-07では以下をProduction Boundaryへ追加する。

```vb
Public Function DisplayMail() As COperationResult
```

引数としてMailItemを受け取らない。

既存Private Module State `mMailItem` を使用する。

---

## 10.3 基本処理

概念：

```text
Active mMailItem確認
↓
mMailItem.Display
↓
Display成功
↓
AdapterのmMailItem参照を解放
↓
Success
```

Display成功後はMailItem WindowのOwnershipをユーザー側へ移したものとして扱う。

---

## 10.4 Ownership Transfer

Display成功後は、

```text
mMailItem
→ Adapterから保持し続けない
```

とする。

概念実装：

```vb
mMailItem.Display
Set mMailItem = Nothing
```

目的：

1. Display後のMailItemをツール側から誤ってCloseしない
2. ツール責任範囲がDisplayまでであることを明確化する
3. Adapter Module Stateへ不要なCOM Referenceを残さない
4. 次のMail生成処理で過去のDisplayed MailItemを再利用しない

これは利用者向けRequirement変更ではなくMailItem OwnershipのImplementation Detailとする。

ここでの、

```vb
Set mMailItem = Nothing
```

はAdapterが保持するCOM Referenceを解放するP1基本処理であり、Displayed MailItemに対する、

```text
Close
Save
Send
```

を意味しない。

Display成功後のWindow / MailItemはClassic Outlook側でユーザー操作対象として維持されることを前提とする。Reference解放によってDisplayed MailItemが閉じる、消失する、編集不能になる等の挙動が確認された場合はP1-07 Technical Findingとして扱い、推測修正しない。

COM Reference解放方式の最終化はP6責務として維持する。

---

## 10.5 Display Failure

`mMailItem.Display` でRuntime / COM Errorが発生した場合、

```text
Success = False
ErrorType = OutlookError
Target = MailItemDisplay
```

相当のResultへ変換する。

P1-07では正式Error Codeを追加しない。

Display失敗時は、Cleanup可能性を残すため、Failure発生前に`mMailItem`参照を意図的に破棄しない。

Callerである`modMailApplication`が`CloseWithoutSave()`を試行する。

---

## 10.6 非責務

`DisplayMail()` は以下を行わない。

```text
Send
Save
Close
Render
Unresolved Check
Scanner
Input Validation
Value Formatting
User Message表示
Explorer Close
Outlook Quit
```

---

# 11. CloseWithoutSave再利用

P1-07では既存`CloseWithoutSave()`を変更せず再利用することを基本とする。

使用条件：

```text
MailItem生成済み
AND
Display成功前
AND
Failure発生
```

主用途：

```text
Unresolved Failure
Render / Snapshot Failure
Display Failure
Orchestration Failure
```

Display成功後は`CloseWithoutSave()`を呼ばない。

---

# 12. Display Gate

## 12.1 Positive Allow Rule

Display GateはPositive Allow方式とする。

```text
Display Allowed
=
CheckUnresolved.Success = True
AND
unresolvedResult Is Not Nothing
AND
unresolvedResult("HasUnresolved") = False
AND
Variables.Count = 0
```

この条件を満たす場合だけ`DisplayMail()`へ進む。

---

## 12.2 Unresolved Failure Rule

以下の場合：

```text
CheckUnresolved.Success = False
AND
unresolvedResult Is Not Nothing
AND
unresolvedResult("HasUnresolved") = True
AND
Variables.Count >= 1
```

Unresolved Failureとして扱う。

処理：

```text
DisplayMail
→ 呼ばない

Variables
→ 保持

CloseWithoutSave
→ 実行
```

---

## 12.3 ErrorType非依存

以下を禁止する。

```vb
If result.ErrorInfo.ErrorType = "RenderError" Then
    ' Unresolvedと判定
End If
```

Unresolved Failureの識別にErrorType文字列を使用しない。

P1 Interim Mappingとして`RenderError`が存在しても、P1-07 Orchestrationはその値へ依存しない。

---

# 13. Unresolved Result Invariant

P1-07はP1-06 Contractの整合性を確認する。

Result Carrierが存在する場合、原則以下を期待する。

```text
HasUnresolved = False
↔
Variables.Count = 0
```

```text
HasUnresolved = True
↔
Variables.Count >= 1
```

さらに通常Contract：

```text
Success = True
↔
HasUnresolved = False
```

```text
Success = False
+
Result Carrierあり
↔
HasUnresolved = True
```

を期待する。

---

# 14. Contract不整合

以下はUnresolved正常検出として扱わない。

```text
Success = True
HasUnresolved = True
```

```text
Success = False
HasUnresolved = False
Result Carrierあり
```

```text
HasUnresolved = False
Variables.Count >= 1
```

```text
HasUnresolved = True
Variables.Count = 0
```

これらはApplication Boundaryから見てContract不整合であり、

```text
Displayしない
↓
Cleanup
↓
UnexpectedError相当
```

とする。

P1-07では不整合状態を補正して成功側へ倒さない。

---

# 15. Technical Failure Boundary

`CheckUnresolved`が、

```text
Success = False
unresolvedResult = Nothing
```

を返した場合はTechnical Failureとする。

処理：

```text
Displayしない
↓
CloseWithoutSave
↓
Failure Result返却
```

正式なTechnical Error taxonomy / User MessageはP6へ残す。

---

# 16. Scan Gate

P1-07のProduction Flowでは、Render前にP1-04 Scanner Resultを最低限確認する。

条件：

```text
ScanTemplate.Success = True
AND
scanResult Is Not Nothing
AND
InvalidCandidates.Count = 0
```

Invalid Candidateが1件以上存在する場合、

```text
Renderへ進まない
Displayへ進まない
CloseWithoutSave
```

とする。

P1-07ではConfiguration Validator全体を実装しない。

---

# 17. FormattedValues Boundary

P1-07はP1-05で確立したFormattedValues Boundaryを維持する。

```text
formattedValues
├─ Late Bound Scripting.Dictionary
├─ CompareMode = vbTextCompare相当
└─ VariableName → String
```

Production CodeへBaseline固有Variable名をHard Codingしない。

Test FixtureではBaseline Test Dataを使用してよい。

---

# 18. MailItem Ownership

## 18.1 Create後

`CreateMailFromTemplate()` 成功後、

```text
modOutlookAdapter
= Active MailItem Owner
```

とする。

Application側はMailItem Object自体を保持しない。

---

## 18.2 Display前Failure

Display前にFailureが発生した場合、

```text
modMailApplication
→ CloseWithoutSave要求

modOutlookAdapter
→ Active MailItemを保存せずClose
```

とする。

---

## 18.3 Display成功後

Display成功後、

```text
MailItem
→ User-visible Outlook WindowへOwnership Transfer
```

と扱う。

AdapterはActive MailItem参照を保持し続けない。

---

# 19. Explorer Lifecycle

P1-02 / D18の方針を維持する。

```text
Warm Start:
Existing Explorer reuse
追加Explorerなし

Cold Start:
Visible Explorer Initialization
```

Cold Startでツールが起動したExplorerは、P1-07正常終了 / Failureを理由にCloseしない。

```text
Explorer
≠
生成用MailItem
```

である。

`CloseWithoutSave()`は生成用MailItemのみを対象とする。

---

# 20. Normal Success Flow

P1-07 Production Success Flow：

```text
CreateMailForDisplay
↓
unresolvedResult = Nothing
↓
Settings.TemplatePath取得
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
MailCreated = True
↓
ReadSubject
↓
ReadBodyText
↓
ScanTemplate
↓
InvalidCandidates = 0
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
ReadSubject
↓
ReadBodyText
↓
CheckUnresolved
↓
Success = True
HasUnresolved = False
Variables.Count = 0
↓
DisplayMail
↓
Success
```

---

# 21. Unresolved Fail Closed Flow

Missing Formatted Value等によりTokenが残る場合：

```text
Render
↓
Post-Render Snapshot
↓
CheckUnresolved
↓
Success = False
HasUnresolved = True
Variables.Count >= 1
↓
DisplayMailは呼ばない
↓
CloseWithoutSave
↓
Failure Result
+
unresolvedResult保持
```

`Variables` は後続UI通知用Dataとして保持する。

P1-07ではUI表示そのものは実装しない。

---

# 22. Other Failure Flow

MailItem生成後に他のFailureが発生した場合：

```text
Primary Failure
↓
CloseWithoutSave試行
↓
Cleanup Success?
├─ Yes → Overall Failure
└─ No  → Overall Failure + Cleanup Failureを隠さない
```

P1-07で固定するContractは以下までとする。

```text
Primary Failure後に可能な範囲でCleanupする
Cleanup Failureが発生してもSuccessを返さない
Cleanup FailureをEvidence / Result上で識別不能にしない
```

一方、以下はP1-07で最終決定しない。

```text
Primary ErrorとCleanup Errorのどちらを単一Resultの代表Errorにするか
複数Errorを同時保持するか
Error Code / Messageをどう統合するか
User-facing Messageでどちらを優先表示するか
```

これらのError Integration方針はP6へ残す。

P1-07実装では既存`COperationResult`で表現可能な最小方法を採用し、Cleanup Failureが発生したことを隠さずOverall Failureとする。

---

# 23. Display Failure Flow

```text
CheckUnresolved
↓
Display Allowed
↓
DisplayMail
↓
Failure
↓
CloseWithoutSave
↓
Failure
```

Display Runtime Errorを成功扱いしない。

`DisplayMail()` Failure時にMailItemが完全に表示済みか否かを網羅的に判定する高度なRecoveryはP6へ残す。

P1-07では安全に再現可能な範囲とStatic Reviewで基本経路を確認する。

---

# 24. Unexpected Orchestration Error

`modMailApplication` 自身で予期しないRuntime Errorが発生した場合：

```text
On Error
↓
MailItem生成済み？
├─ No  → UnexpectedError返却
└─ Yes
    ↓
   CloseWithoutSave試行
    ↓
   UnexpectedError / Cleanup Failure返却
```

新しいException Frameworkは導入しない。

既存 `COperationResult` / `CreateFailureResult()` を使用する。

---

# 25. Result Return Rule

## 25.1 Success

```text
DisplayMail成功
→ CreateSuccessResult()
```

---

## 25.2 Unresolved Failure

Cleanup成功時：

```text
CheckUnresolvedが返したFailure Result
→ 基本的にそのまま返却
```

`unresolvedResult` は保持する。

---

## 25.3 Pre-Display Failure

Cleanup成功時：

```text
発生元ModuleのFailure Result
→ 基本的にそのまま返却
```

ErrorTypeをP1-07側で不要に再分類しない。

---

## 25.4 Cleanup Failure

```text
CloseWithoutSave Failure
→ Overall Failure
→ Cleanup Failureを隠さない
```

P1-07ではPrimary Failure / Cleanup Failureの最終的な優先順位・統合方式を固定しない。

少なくとも、

```text
Cleanup FailureをSuccess扱いしない
Cleanup Failure発生をEvidenceから識別可能にする
```

ことを保証する。

正式な複数Error統合はP6へ残す。

---

# 26. Private Helper構成

`modMailApplication` では過剰にHelperを増やさない。

推奨候補：

```vb
Private Function FailAndCleanup( _
    ByVal primaryResult As COperationResult, _
    ByVal mailCreated As Boolean _
) As COperationResult
```

または同等の最小構成とする。

必要に応じて、

```vb
Private Function IsValidUnresolvedResult( _
    ByVal operationResult As COperationResult, _
    ByVal unresolvedResult As Object _
) As Boolean
```

相当を使用してよい。

ただしResult専用Class / Gate専用Interfaceは追加しない。

---

# 27. Conceptual Algorithm

```text
CreateMailForDisplay
↓
unresolvedResult = Nothing
↓
mailCreated = False
↓
TemplatePath取得
↓
Resolve Path
↓
CreateMailFromTemplate
↓
mailCreated = True
↓
Read Pre Snapshot
↓
ScanTemplate
↓
Scan Gate
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
Read Post Snapshot
↓
CheckUnresolved
↓
Result Carrier Contract確認
↓
Display Allowed?
├─ Yes
│   ↓
│  DisplayMail
│   ↓
│  Success
│
└─ No
    ↓
   FailAndCleanup
```

---

# 28. DisplayMail Conceptual Algorithm

```text
DisplayMail
↓
mMailItem Is Nothing?
├─ Yes → OutlookError
└─ No
    ↓
   mMailItem.Display
    ↓
   Display Success
    ↓
   Set mMailItem = Nothing
    ↓
   Success
```

`.Send` は呼び出さない。

---

# 29. Production Hard Coding Rule

Production Codeへ以下をHard Codingしてはならない。

```text
ModelName
GateDate
Department
Comment
ABC123
品質部
2026/09/30
```

また、

```text
ErrorType = "RenderError"
```

をUnresolved分岐条件としてHard Codingしない。

Test Fixture内ではBaseline Dataを使用してよい。

---

# 30. No Auto Send Rule

P1-07 Production Codeでは以下を禁止する。

```vb
mailItem.Send
```

または同等のSend実行。

`DisplayMail()` は必ず、

```text
Display only
```

とする。

P1-07 Static Reviewで、

```text
.Send呼出が追加されていない
```

ことを確認する。

---

# 31. Warm Start Verification

## 31.1 Precondition

```text
Classic Outlook起動済み
Explorer Count >= 1
```

---

## 31.2 Flow

Baseline OFT + Baseline FormattedValues Fixtureを使用する。

```text
CreateMailForDisplay
↓
Existing Explorer reuse
↓
E2E
↓
Unresolved = 0
↓
Display
```

---

## 31.3 Expected

```text
CreateMailForDisplay = Success
Additional Readiness Explorer = NONE
Final MailItem Display = YES
Auto Send = NONE
HasUnresolved = False
Variables.Count = 0
```

Displayed MailItemはVerification後、ユーザーまたはTest Procedureで保存せず閉じる。

Production `CloseWithoutSave()`をDisplayed MailItemへ後から適用するためのTest専用APIは追加しない。

---

# 32. Cold Start Verification

## 32.1 Precondition

```text
Classic Outlook完全終了
Explorer Count = 0
```

ユーザーはClassic Outlookを事前起動しない。

---

## 32.2 Flow

```text
CreateMailForDisplay
↓
Classic Outlook Readiness
↓
Visible Explorer Initialization
↓
Create MailItem
↓
WordEditor
↓
Scanner
↓
Render
↓
Unresolved = 0
↓
Display
```

---

## 32.3 Expected

```text
Explorer Count:
0 → 1以上

Readiness:
PASS

Final MailItem Display:
YES

Auto Send:
NONE

HasUnresolved:
False
```

Cold Startで起動したExplorerは最終MailItemを閉じた後も通常Windowとして残ることを許容する。

---

# 33. Unresolved Fail Closed Verification

## 33.1 Fixture

Baseline FormattedValuesから1件を意図的に除外する。

推奨：

```text
GateDate
```

Fixture：

```text
ModelName   = ABC123
Department  = 品質部
Comment     = 確認お願いします

GateDate:
NOT INCLUDED
```

---

## 33.2 Flow

```text
CreateMailForDisplay
↓
Render
↓
{{GateDate}}残存
↓
Post-Render Snapshot
↓
CheckUnresolved
↓
Failure
↓
HasUnresolved=True
↓
Variables=GateDate
↓
No Display
↓
CloseWithoutSave
```

---

## 33.3 Expected

```text
CreateMailForDisplay:
Failure

HasUnresolved:
True

Variables.Count:
1

Variables:
GateDate

Final MailItem Display:
NONE

CloseWithoutSave:
PASS

Draft Residue:
NONE
```

GateDateがSubject / Body双方へ残っていても`Variables`上は1件とする。

---

# 34. Technical Failure Verification

P1-07ではP6相当のFault Injection Frameworkを追加しない。

安全に再現可能な範囲で、

```text
Active MailItemなし
Invalid Scanner Precondition
Display APIをActive MailItemなしで呼ぶ
```

等をLocal Verificationしてよい。

網羅的な、

```text
COM Failure Injection
Display partial failure
Close Failure Injection
WordEditor Runtime Failure
```

はP6へ残す。

---

# 35. Lifecycle Verification

最低限以下をEvidenceとして記録する。

```text
Outlook Start State
Explorer Count Before
Explorer Count After Readiness
Draft Count Before
Draft Count After
Inspector Count Before
Inspector Count After
Final MailItem Display有無
CloseWithoutSave Result
```

## Success Path

Display後の最終MailItem Inspectorはユーザー表示そのものであり、Failure Residueと区別する。

Test終了時に表示MailItemを手動で保存せずCloseし、環境を復旧する。

## Fail Closed Path

Expected：

```text
Final MailItem Display = NONE
Draft Count After = Draft Count Before
Inspector Count After = Inspector Count Before
CloseWithoutSave = PASS
```

Cold Start Explorerは残ってよい。

---

# 36. P1-06 Test Harness Cleanupとの差

P1-06では、

```text
Normal
Unresolved
```

双方でTest Harnessが`CloseWithoutSave()`していた。

P1-07ではProduction Orchestrationを接続するため、責務を変更する。

```text
Normal Success:
Production → Display
Test Harness → Displayed Mailを手動Cleanup

Unresolved Failure:
Production → CloseWithoutSave
Test Harness → Production Cleanup結果を確認
```

Unresolved Failure TestでTest Harnessが重複して`CloseWithoutSave()`を呼び、Production Cleanup不備を隠してはならない。

---

# 37. Integration Test Module

推奨Test Module：

```text
modP1_07DisplayE2EIntegrationTest
```

推奨Entry Point：

```vb
TestP107DisplayE2EIntegration
```

必要に応じて以下を分離してよい。

```vb
TestP107WarmStartSuccess
TestP107ColdStartSuccess
TestP107UnresolvedFailClosed
```

Production Public APIをTest都合で増やさない。

---

# 38. Test Fixture Encoding Rule

P1-06で発生した`TF-P1-06-001`を踏まえ、日本語FixtureのEncoding Driftを再発させない。

P1-07 Test Artifactで、

```text
品質部
確認お願いします
```

等を使用する場合、既に成立したFixture生成方式を再利用する。

必要に応じて、

```text
ChrW()生成
Length Guard
```

を維持する。

Expected：

```text
Department Len = 3
Comment Len = 8
```

Fixture Guard Failure時はProduction E2Eを開始しない。

---

# 39. Regression Scope

P1-07では`modMailApplication`と`modOutlookAdapter`を変更するため、P1-01～P1-06への影響を確認する。

最低限：

```text
VBA Compile
P1-01 Path / OFT Connection
P1-02 Warm / Cold Readiness
P1-03 Subject / Body Snapshot
P1-04 Scanner
P1-05 Render
P1-06 Unresolved Checker
P1-07 E2E
```

ただし同一E2E実行Evidenceで複数Boundaryを確認できる場合は再利用してよい。

各BoundaryのExpectedを個別に判定可能であること。

---

# 40. Formal Test Boundary

P1-07で実行する、

```text
Warm Start Display
Cold Start Display
Unresolved No Display
Cleanup
No Auto Send
```

はすべてImplementation Verificationである。

Test Specificationとの対応は次の範囲に限定する。

```text
MTS-UNR-002
→ P1-07で直接Scenario相当を確認

MTS-MAIL-001
→ P1 Walking SkeletonのWarm / Cold Display経路部分を確認

MTS-MAIL-002
→ No Auto Send観点を確認

MTS-MAIL-003
→ Regression / Lifecycle観点を確認

MTS-MAIL-004
→ Unresolved Error分岐のみを確認
```

P1-07未実装のConfiguration Validator、正式Input Validation、Current Data Guard等を必要とする部分について、P1-07だけでTest Case全体を満たしたとは扱わない。

正式Test IDへReferenceしても、

```text
Formal PASS
```

とは記録しない。

Formal TestはP7で固定したTest Candidate Buildに対して別途実施する。

---

# 41. Evidence

最低限以下を記録する。

```text
Workbook
Execution Baseline
Production Module Version / Patch
Compile Result

Fixture:
FormattedValues Keys
Fixture Guard Result

Environment:
Outlook Start State
Explorer Count Before

Pre-Render:
Resolved OFT Path
CreateMailFromTemplate Result
ReadSubject Result
ReadBodyText Result
ScanTemplate Result
ValidVariables Count
InvalidCandidates Count

Render:
RenderSubject Result
SetSubject Result
ReplaceBodyVariables Result

Post-Render:
ReadSubject Result
ReadBodyText Result

Unresolved:
CheckUnresolved Result
HasUnresolved
Variables Count
Variables

Display Gate:
Display Allowed / Blocked
DisplayMail Called / Not Called
DisplayMail Result

Lifecycle:
Explorer Count After
Draft Count Before / After
Inspector Count Before / After
CloseWithoutSave Result
Final MailItem Display有無

Safety:
Auto Send = NONE

Result:
PASS / FAIL
```

BodyText全文は必須Evidenceとしない。

---

# 42. Implementation Detail Rule

P1-07実装時に変更してよい事項：

```text
Private Helper名
Local変数名
Debug.Print内容
Test Module内部構成
Cleanup Helperの有無
Result確認コードの局所構造
mailCreated Flag名
Display Target文字列の軽微な命名
```

ただし以下は変更してはならない。

```text
modMailApplicationがOrchestrationを担当する
COM ObjectをApplicationへ公開しない
Unresolved後にDisplay Gateを置く
Success + HasUnresolved=FalseのみDisplay
UnresolvedありでDisplayしない
Unresolved時にVariablesを保持する
Unresolved時にCloseWithoutSaveする
ErrorType="RenderError"へ依存しない
Display成功後に自動Closeしない
自動Sendしない
P5 / P6を先回り実装しない
Formal Test PASS扱いしない
```

これらの変更が必要な場合はFinding Ruleへ従う。

---

# 43. Finding Classification

## 43.1 Implementation Detail

既存Baseline / Boundaryを変えずコード局所修正で解決できるもの。

例：

```text
Helper分割
Nothing Check
Flag管理
Cleanup呼出位置
On Error範囲
Debug Evidence
```

---

## 43.2 Implementation Defect

本仕様どおりに実装されていないもの。

例：

```text
UnresolvedありでDisplayされる
Cleanupされない
DisplayMailがSendする
MailItem COM ObjectがApplicationへ漏れる
RenderError文字列依存
```

---

## 43.3 Test Artifact Gap

Productionは正しいがTest Artifact / Fixture / Expectedが誤っているもの。

例：

```text
Encoding Drift
誤ったInspector Count Expected
Test Harnessによる重複Cleanup
Display確認前の手動Close
```

---

## 43.4 Requirement Gap

利用者から見た新しい挙動を決める必要がある場合。

P1-07開始時点：

```text
NONE
```

発生した場合はImplementationで決めずRequirementsへ戻す。

---

## 43.5 Design Finding

Architecture / Responsibility / Sequenceを変更しなければ成立しない場合。

例：

```text
MailItemをAdapter外へ公開しないとDisplay制御不能
Display後Ownership方式が現Designで成立しない
Application Orchestration責務では処理不能
```

発生した場合はDesignへ戻す。

---

## 43.6 Technical Finding

既存Technical Evidenceで想定していない成立性問題。

例：

```text
Display前WordEditor状態からDisplayへ移行不能
Cold Start E2EだけDisplay失敗
Display後COM ReleaseでOutlook Windowが閉じる
```

通常Implementation + Verificationで解決不能かつ大規模手戻りRiskがある場合のみTechnical Spike要否を再判定する。

---

# 44. Consistency Review

本仕様のApproved化にあたり、以下とのCross-document Consistency Reviewを実施した。

```text
DOC-MVP-REQ
- FR-UNRESOLVED-001 / 002
- FR-OUTLOOK-001 / 002 / 003
- AC-019 / AC-020
- NFR-004

DOC-MVP-DES
- §12 MailItem Lifecycle
- §13 Outlook Adapter
- §23 Unresolved Checker
- §24 Error Design
- §25 Mail Generation Sequence
- §26 VBA構成
- D18

DOC-MVP-TESTSPEC
- MTS-UNR-001 / 002
- MTS-MAIL-001 / 002 / 003 / 004

DOC-MVP-IMPL
- IMP-R03 / R04 / R05 / R06 / R08 / R09
- P1 Exit Criteria
- P5 / P6 Boundary

P1-05
- Render API Lifecycle Boundary

P1-06
- CheckUnresolved Contract
- P1-07 Connection Boundary
- ErrorType非依存Rule
```

Review結果：

```text
Requirement Conflict = NONE
Design Conflict = NONE
Test Specification Conflict = NONE after scope corrections
Implementation Plan Conflict = NONE
P1-05 Contract Conflict = NONE
P1-06 Contract Conflict = NONE
Scope Expansion = NONE after corrections
Traceability Break = NONE
Requirement Gap = NONE
Design Finding = NONE
Blocking Technical Finding = NONE
Governance Conflict = NONE after corrections

RESULT:
PASS WITH CORRECTIONS
→ CORRECTIONS APPLIED
```

---

# 45. Approval Criteria

Cross-document Consistency ReviewおよびCorrection反映後、以下をすべて満たしていることを確認した。

```text
Requirement Conflict = NONE
Design Conflict = NONE
Test Definition Conflict = NONE
Implementation Plan Conflict = NONE
P1-05 Contract Conflict = NONE
P1-06 Contract Conflict = NONE
Requirement Gap = NONE
Blocking Design Finding = NONE
Blocking Technical Finding = NONE
Technical Spike Reopen = NOT REQUIRED
Baseline Change = NOT REQUIRED
```

Approval Result：

```text
Consistency Review:
PASS WITH CORRECTIONS

Corrections Applied:
YES

Blocking Finding:
0

Document Status:
Approved
```

Production実装は本Approved仕様を基準として実施する。

---

# 46. Verification PASS Criteria

P1-07 Verification PASSには最低限以下を必要とする。

```text
VBA Compile
= PASS

Warm Start E2E
= PASS

Cold Start E2E
= PASS

Normal Unresolved
= 0

Normal Final Display
= PASS

Auto Send
= NONE

Unresolved Failure
= DETECTED

Unresolved Variables
= PRESERVED

Unresolved Final Display
= NONE

Unresolved CloseWithoutSave
= PASS

Fail Closed Draft Residue
= NONE

Fail Closed Inspector Residue
= NONE

ErrorType="RenderError" Dependency
= NONE

P1-01～P1-06 Blocking Regression
= NONE

Blocking Finding
= 0
```

---

# 47. FAIL Criteria

以下のいずれかをP1-07 FAILとする。

```text
UnresolvedありでMailItem Display
Normal E2EでDisplay不可
Cold Start E2EでProduction経路不成立
DisplayMailがSendを実行
Display成功後にツールがMailItemを自動Close
Unresolved Variables消失
Unresolved Failure判定がRenderError文字列へ依存
CloseWithoutSave Failure
不要Draft残存
Fail Closed後の不要Inspector残存
COM ObjectがAdapter外へ漏れる
P1-01～P1-06 Blocking Regression
VBA Compile Failure
Blocking Requirement Gap
Blocking Design Finding
Blocking Technical Finding
```

---

# 48. P1-07 Completion Criteria

以下をすべて満たした場合、

```text
P1-07 Display / E2E Integration
PASS / COMPLETE
```

候補とする。

```text
Approved Unit Specification
PASS

VBA Compile
PASS

modMailApplication Orchestration
PASS

DisplayMail Production API
PASS

Warm Start Normal E2E
PASS

Cold Start Normal E2E
PASS

Display Gate
PASS

Unresolved Fail Closed
PASS

Variables Preservation
PASS

Production Cleanup
PASS

No Auto Send
PASS

Lifecycle
PASS

P1-01～P1-06 Regression
PASS

Production Patch Review
PASS

Finding Assessment
PASS

Blocking Finding
0
```

P1-07 Completionだけでは、

```text
CP-P1 ESTABLISHED
```

とはしない。

---

# 49. Static Review Checklist

Production Patchに対して最低限以下をReviewする。

```text
[ ] modMailApplicationがSequenceを制御している
[ ] modMailApplicationがOutlook COM Objectを直接操作していない
[ ] modOutlookAdapterにDisplayMail()がある
[ ] DisplayMail()は内部mMailItemを使用する
[ ] DisplayMail()はSendしない
[ ] DisplayMail()はSaveしない
[ ] DisplayMail()成功後にAdapterのActive MailItem参照を保持し続けない
[ ] Display failure時にCleanup可能性を残す
[ ] CheckUnresolved後にDisplay Gateがある
[ ] Success=True + HasUnresolved=FalseのみDisplayする
[ ] Variables.CountとのInvariantを確認する
[ ] UnresolvedありでDisplayMailを呼ばない
[ ] UnresolvedありでCloseWithoutSaveをProduction側が呼ぶ
[ ] unresolvedResultをFailure時にも保持する
[ ] ErrorType="RenderError"を分岐条件に使用していない
[ ] Failure後に可能な範囲でCleanupする
[ ] Cleanup FailureをSuccess扱いせず、発生を識別可能にしている
[ ] Cold Start ExplorerをCloseしない
[ ] P5 Current Data Guardを実装していない
[ ] P6 Error taxonomyを最終化していない
[ ] Test専用Production APIを追加していない
```

---

# 50. Production Patch想定

P1-07のProduction Patchは原則以下とする。

```text
modMailApplication
- CreateMailForDisplay()追加 / 実装
- E2E Sequence接続
- Display Gate
- Failure Cleanup

modOutlookAdapter
- DisplayMail()追加
- Display後Ownership Transfer
```

以下は原則変更しない。

```text
modTemplateScanner
modSubjectRenderer
modUnresolvedChecker
modSettingsData
modVariableDefinitionData
modOptionMasterData
```

---

# 51. Test Artifact想定

```text
modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas
```

必要に応じて、

```text
P1-07 Production 実装手順 v0.1.md
P1-07 Display E2E Production Patch Review v0.1.md
P1-07 Display E2E Finding Assessment v0.1.md
P1-07 Display E2E Completion Record v0.1.md
```

を後続で作成する。

---

# 52. API Contract Summary

## modMailApplication

```vb
Public Function CreateMailForDisplay( _
    ByVal formattedValues As Object, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

責務：

```text
P1 E2E Sequence
Display Gate
Fail Closed Cleanup
```

---

## modOutlookAdapter

新規：

```vb
Public Function DisplayMail() As COperationResult
```

既存再利用：

```text
CreateMailFromTemplate()
ReadSubject()
ReadBodyText()
SetSubject()
ReplaceBodyVariables()
CloseWithoutSave()
```

---

## modUnresolvedChecker

既存：

```vb
Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

変更しない。

---

# 53. Traceability Summary

```text
FR-UNRESOLVED-001
→ CheckUnresolved
→ Display Gate
→ Unresolved時No Display

FR-UNRESOLVED-002
→ unresolvedResult.Variables保持
→ P6 / UIへ引継ぎ

FR-OUTLOOK-001
→ CreateMailFromTemplate
→ Classic Outlook Readiness
→ DisplayMail

FR-OUTLOOK-002
→ DisplayMail
→ Sendなし

FR-OUTLOOK-003
→ Display成功でTool Responsibility終了

AC-019
→ Warm / Cold E2E
→ 全Check成功時のみDisplay

AC-020
→ No Auto Send

Design §23
→ Unresolved Result
→ Display Gate

Design §25
→ No Display / CloseWithoutSave

MTS-UNR-002相当
→ P1-07 Unresolved Fail Closed Verification

MTS-MAIL-001相当
→ P1-07 Normal Display Verification

MTS-MAIL-002相当
→ P1-07 No Auto Send Verification

MTS-MAIL-004相当
→ P1-07 Failure Cleanup Verification
```

---

# 54. Gap Assessment

P1-07実施仕様作成時点：

```text
Requirement Gap:
NONE

Design Gap:
NONE

Test Definition Gap:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED
```

---

# 55. Approved Result

```text
P1-07 Display / E2E Integration 実施仕様 v0.1

Status:
Approved

Consistency Review:
PASS WITH CORRECTIONS
→ CORRECTIONS APPLIED

Boundary:
DEFINED

Production API:
DEFINED

Display Gate:
DEFINED

Fail Closed:
DEFINED

Warm / Cold Verification:
DEFINED

Formal Test Boundary:
DEFINED

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Technical Finding:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Blocking Finding:
0
```
