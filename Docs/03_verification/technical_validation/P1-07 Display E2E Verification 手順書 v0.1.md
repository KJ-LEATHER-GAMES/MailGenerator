# P1-07 Display / E2E Integration Verification 手順書 v0.1

## 1. 目的

Approved済みの、

- `P1-07 Display / E2E Integration 実施仕様 v0.1`

およびP1-07 Production実装に対して、P1 Walking SkeletonのImplementation Verificationを実施する。

本VerificationはFormal MVP Testではない。

```text
P1-07 Implementation Verification
≠
Formal MTS Test Result
```

`MTS-UNR-002` 相当および `MTS-MAIL-004` のUnresolved Error分岐相当を確認しても、Formal Test PASSとは記録しない。

---

## 2. 対象Artifact

実行Module：

```text
modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas
```

Production Entry Point：

```vb
CreateMailForDisplay( _
    formattedValues, _
    unresolvedResult _
) As COperationResult
```

Test HarnessはProduction処理を再実装せず、`CreateMailForDisplay()` を通してE2Eを実行する。

Test HarnessからOutlook Object Modelへアクセスする用途は、原則として以下のEvidence取得に限定する。

```text
Explorer Count
Inspector Count
Draft Count
```

Test HarnessからWordEditor / Word Documentへ直接アクセスしない。

---

## 3. 前提

実施前に以下を確認する。

```text
P1-07実施仕様 v0.1:
Approved

P1-07 Production:
Imported

modOutlookAdapter:
P1-07版へ差し替え済み

modMailApplication:
追加済み

Debug → Compile VBAProject:
PASS
```

Baseline OFTはP1-04～P1-06で使用した内容を維持する。

Expected Variables：

```text
ModelName
GateDate
Department
Comment
```

Harness内FormattedValues Fixture：

```text
ModelName   = ABC123
GateDate    = 2026/09/30
Department  = 品質部
Comment     = 確認お願いします
```

日本語Fixtureは過去のEncoding Drift再発防止のため `ChrW()` で生成する。

Fixture Guard：

```text
Department Len = 3
Comment Len = 8
```

---

## 4. Import

VBEで、

```text
File
→ Import File...
```

から、

```text
modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas
```

をImportする。

Module名：

```text
modP1_07DisplayE2EIntegrationTest
```

Import後、再度、

```text
Debug
→ Compile VBAProject
```

を実行する。

Expected：

```text
PASS
```

Compile Errorがある場合はRuntime Verificationへ進まない。

---

# 5. 実行Entry Point

以下3本を**別々に**実行する。

```vb
TestP107WarmStartNormal
TestP107ColdStartNormal
TestP107UnresolvedFailClosed
```

案内用：

```vb
TestP107DisplayE2EIntegration
```

は実際のE2Eを自動連続実行せず、実行順だけをImmediate Windowへ表示する。

Cold StartではOutlookを完全に閉じる操作が必要なため、3本を自動連続実行しない。

---

# 6. V1 Warm Start Normal E2E

## 6.1 Precondition

Classic Outlookを通常起動する。

推奨：

```text
Explorer Window:
1以上

不要なMail Inspector:
閉じておく
```

Excel / VBEは開いたままでよい。

---

## 6.2 実行

VBE Immediate Windowを表示する。

```text
Ctrl + G
```

実行：

```vb
TestP107WarmStartNormal
```

---

## 6.3 Production Flow

Harnessは以下を直接呼ぶ。

```text
CreateMailForDisplay
```

Production内部：

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject / ReadBodyText
↓
ScanTemplate
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
Post-Render ReadSubject / ReadBodyText
↓
CheckUnresolved
↓
Display Gate
↓
DisplayMail
```

---

## 6.4 Expected

Production Result：

```text
CreateMailForDisplay:
PASS
```

Unresolved：

```text
HasUnresolved:
False

Variables.Count:
0
```

Outlook：

```text
Explorer Count After Display
=
Explorer Count Before

Inspector Count After Display
=
Inspector Count Before + 1

Draft Count After Display
=
Draft Count Before
```

つまり、

```text
Existing Explorer reuse
Final MailItem Display
Draft追加なし
```

を確認する。

---

## 6.5 Manual Confirmation

Productionが正常ならHarnessから確認Dialogを表示する。

画面上で以下を確認する。

```text
最終生成MailItemが表示されている
自動送信されていない
```

確認後、

```text
表示MailItemを保存せず閉じる
```

その後Dialogで、

```text
Yes
```

を選択する。

Harnessは成功時にDisplayed MailItemを勝手にCloseしない。

---

## 6.6 Cleanup Expected

ユーザーが表示Mailを保存せずCloseした後：

```text
Explorer Count
=
Before

Inspector Count
=
Before

Draft Count
=
Before
```

Expected：

```text
Overall:
PASS
```

---

# 7. V2 Cold Start Normal E2E

## 7.1 Precondition

V1で使用したOutlookを含め、Classic OutlookのExplorer Windowをすべて閉じる。

少なくともHarnessから見た、

```text
Explorer Count Before:
0
```

が必要。

Test HarnessはCold Start Preconditionを壊さないため、Outlookが存在しない場合にDraft Count取得目的でOutlookを起動しない。

したがって真のCold Startでは、

```text
Draft Count Before:
N/A
```

となる場合がある。

これはTest Defectではない。

---

## 7.2 実行

```vb
TestP107ColdStartNormal
```

---

## 7.3 Expected

Production：

```text
CreateMailForDisplay:
PASS
```

Cold Start：

```text
Explorer Count:
0 → 1以上
```

Unresolved：

```text
HasUnresolved:
False

Variables.Count:
0
```

Display：

```text
Inspector Count After Display
=
Inspector Count Before + 1
```

Classic Outlook Explorerと最終MailItem Inspectorの両方が表示される。

Explorer表示だけを最終MailItem Displayとは扱わない。

---

## 7.4 Manual Confirmation

V1と同様、

```text
最終MailItemが表示されている
自動送信されていない
```

ことを確認する。

その後、

```text
最終MailItemだけ保存せずClose
```

する。

Cold Startで起動したExplorerは**閉じない**。

Dialogで、

```text
Yes
```

を選択する。

---

## 7.5 Cleanup Expected

```text
Explorer Count After User Cleanup:
1以上

Inspector Count After User Cleanup:
Inspector Count Before
```

Draftについて：

### Draft Count Beforeを取得できた場合

```text
Draft Count After Cleanup
=
Draft Count Before
```

### Outlookが完全停止しておりBeforeを取得できなかった場合

Cold Startを破壊しないためBefore比較を行わない。

代わりに、

```text
Draft Count After Cleanup
=
Draft Count After Display
```

を確認する。

Expected：

```text
Overall:
PASS
```

---

# 8. V3 Unresolved Fail Closed

## 8.1 Precondition

V2後のClassic Outlook Explorerをそのまま残してよい。

Expected：

```text
Explorer Count Before:
1以上
```

不要なMail Inspectorは閉じておく。

---

## 8.2 Fixture

HarnessはNormal Fixtureから、

```text
GateDate
```

だけを意図的に除外する。

```text
ModelName   = ABC123
Department  = 品質部
Comment     = 確認お願いします

GateDate:
NOT INCLUDED
```

Production RendererはMissing ValueをErrorにせずTokenを残し、P1-06 Unresolved Checkerが後段で検出する。

---

## 8.3 実行

```vb
TestP107UnresolvedFailClosed
```

---

## 8.4 Expected Result

`CreateMailForDisplay()`：

```text
Failure
```

これはExpected FailureでありTest FAILではない。

Unresolved Result：

```text
HasUnresolved:
True

Variables.Count:
1

Variable:
GateDate
```

`GateDate`がSubject / Bodyの複数箇所に残っていても、Variables上はCase Insensitiveに1件である。

---

## 8.5 Fail Closed Expected

```text
Final MailItem Display:
NONE

Inspector Count After:
=
Inspector Count Before

Draft Count After:
=
Draft Count Before

Explorer Count After:
=
Explorer Count Before
```

Production側：

```text
No Display
↓
CloseWithoutSave
```

が成立したEvidenceとして扱う。

HarnessはUnresolved Failure後に重複してProduction `CloseWithoutSave()`を呼ばない。

Expected：

```text
Overall:
PASS
```

---

# 9. Immediate Windowで記録するEvidence

各CaseについてImmediate Windowの出力を保存する。

最低限：

```text
Test Case
Outlook Start State
Fixture Guard

Explorer Count Before
Inspector Count Before
Draft Count Before

CreateMailForDisplay Result

HasUnresolved
Variables.Count
Variables

Explorer Count After Display / Failure
Inspector Count After Display / Failure
Draft Count After Display / Failure

Manual Display / No Auto Send Confirmation
User Cleanup Lifecycle

Overall
```

Failure時は、

```text
ErrorType
Target
Message
```

も出力する。

---

# 10. PASS判定

## V1 Warm Start

```text
Fixture Guard                       PASS
CreateMailForDisplay                PASS
Unresolved Gate                     PASS
Final MailItem Display              PASS
Existing Explorer Reuse             PASS
Draft Count After Display           PASS
Manual Display / No Auto Send       PASS
User Cleanup Lifecycle              PASS
Overall                             PASS
```

## V2 Cold Start

```text
Fixture Guard                       PASS
CreateMailForDisplay                PASS
Unresolved Gate                     PASS
Cold Start Explorer Initialization  PASS
Final MailItem Display              PASS
Manual Display / No Auto Send       PASS
Cold Start User Cleanup Lifecycle   PASS
Overall                             PASS
```

## V3 Unresolved Fail Closed

```text
Fixture Guard                       PASS
Expected Failure                    PASS
HasUnresolved=True                  PASS
Variables.Count=1                   PASS
GateDate                            PASS
Final MailItem Display=NONE         PASS
Production CloseWithoutSave         PASS
Draft Residue=NONE                  PASS
Inspector Residue=NONE              PASS
Overall                             PASS
```

---

# 11. BLOCKEDの扱い

Cold Start直後などでHarnessがOutlook Evidenceを再取得できない場合、

```text
BLOCKED
```

とする。

Production ResultがPASSでも、Evidence不足をProduction FAILへ変換しない。

これは過去P1-02で確認した、

```text
Production Functional Path
≠
Evidence Reacquisition
```

の分離を維持するためである。

BLOCKEDの場合はログを保存し、Production Defectと決めつけずFinding Assessmentを行う。

---

# 12. FAIL時の扱い

以下はP1-07 Finding候補である。

```text
NormalでCreateMailForDisplay Failure
Unresolved 0なのにDisplayされない
NormalでInspectorが増えない
Warm Startで不要Explorerが増える
Cold StartでExplorerが起動しない
UnresolvedありでMailItemがDisplayされる
Unresolved Variablesが失われる
Unresolved後にInspector / Draftが残る
表示後MailItemが自動的に閉じる
自動Sendされた
```

FAIL時はその場でProductionを推測修正しない。

分類候補：

```text
Implementation Defect
Test Artifact Defect
Regression Finding
Lifecycle Finding
Technical Finding
Requirement Gap
Design Finding
```

を切り分ける。

---

# 13. Required Regression

P1-07 Productionでは、

```text
modOutlookAdapter
```

を差し替えているため、P1-07 V1～V3 PASS後に、既存P1-02 Warm / Cold Smoke Testを対象Regressionとして再実行する。

推奨既存Artifact：

```text
modP1_02InspectorWordEditorSmokeTest_v0.2.2_CP932.bas
```

確認：

```text
Warm Start Readiness
Cold Start Readiness
ReadBodyText / WordEditor
CloseWithoutSave
Explorer Lifecycle
Draft Residue
Inspector Residue
```

P1-07 E2E自体が、

```text
P1-01 Path
P1-03 Snapshot
P1-04 Scanner
P1-05 Render
P1-06 Unresolved
```

のProduction API接続を通るため、主要Integration Regression Evidenceとして再利用可能。

P1-06 Core C1～C8等、変更していないCore Moduleの全Testを機械的に再実行する必要はない。

ただしFindingが発生し、そのModuleへの影響が疑われる場合は対象Regressionを追加する。

---

# 14. Formal Test Boundary

本Verificationで参照する対応関係：

```text
V1 / V2
→ MTS-MAIL-001のP1 Walking Skeleton部分相当
→ MTS-MAIL-002 No Auto Send観点相当

V3
→ MTS-UNR-002相当
→ MTS-MAIL-004のUnresolved Error分岐相当
```

結果は必ず、

```text
Implementation Verification
```

として記録する。

以下とは記録しない。

```text
Formal MTS-MAIL-001 PASS
Formal MTS-MAIL-002 PASS
Formal MTS-UNR-002 PASS
Formal MTS-MAIL-004 PASS
```

Formal Testは後続のTest Candidate Buildに対して実施する。

---

# 15. P1-07 Verification完了後

V1～V3およびRequired Regressionが完了したら、以下を整理する。

```text
P1-07 Verification Result
↓
Production Patch Review
↓
Finding Assessment
↓
P1-07 Completion Record
```

Completion Criteriaをすべて満たした場合のみ、

```text
P1-07 Display / E2E Integration
PASS / COMPLETE
```

候補とする。

P1-07 COMPLETE後も、

```text
CP-P1 ESTABLISHED
```

とはまだしない。

その後、

```text
P1 Phase Verification
↓
CP-P1 Establishment判定
```

へ進む。
