# 引き継ぎまとめ

## 実施内容

### 1. P1-07 Production実装後のCompile確認

- 対象プロジェクト：
  - 定型メール作成ツール MVP
  - Excel VBA + Classic Outlook
- Current Approved Baseline：
  - `BL-MVP-003`
- 対象Phase：
  - `P1 Walking Skeleton`
- P1-07 Productionとして以下をWorkbookへ反映した。
  - `modMailApplication_P1-07_v0.1_CP932.bas`
  - `modOutlookAdapter_P1-07_v0.1_CP932.bas`
- ユーザー側で、
  - 既存`modOutlookAdapter`をP1-07版へ差し替え
  - `modMailApplication`追加
  - `Debug → Compile VBAProject`\
    を実施。
- 結果：

```text
VBA Compile:
PASS
```

---

### 2. P1-07 Verification Artifact作成

P1-07のImplementation Verification用として以下を作成した。

- `modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas`
- `P1-07 Display E2E Verification 手順書 v0.1.md`
- `P1-07 Verification v0.1.zip`

Verification Entry Point：

```vb
TestP107WarmStartNormal
TestP107ColdStartNormal
TestP107UnresolvedFailClosed
```

補助Entry Point：

```vb
TestP107DisplayE2EIntegration
```

Test Harness方針：

- Production Entry Pointは`CreateMailForDisplay()`を使用
- Harness自身でProduction処理を再実装しない
- Outlook Object Modelは以下のEvidence取得に限定
  - Explorer Count
  - Inspector Count
  - Draft Count
- WordEditor / Word DocumentへHarnessから直接アクセスしない
- 正常Display後のMailItemはHarnessから自動Closeせず、ユーザーが保存せず閉じる
- Unresolved Failure時はHarnessから`CloseWithoutSave()`を呼ばず、Production Cleanupそのものを確認
- Formal MVP TestではなくImplementation Verificationとして扱う

Fixture：

```text
ModelName   = ABC123
GateDate    = 2026/09/30
Department  = 品質部
Comment     = 確認お願いします
```

過去のP1-06 Encoding Drift対策として、日本語Fixtureは`ChrW()`で生成。

Fixture Guard：

```text
Department Len = 3
Comment Len = 8
```

---

### 3. P1-07初回Verification

#### 1回目 Warm Start

結果：

```text
Warm Start Normal E2E:
PASS
```

主なEvidence：

```text
Explorer Count Before: 1
Inspector Count Before: 0
Draft Count Before: 21

CreateMailForDisplay: PASS
Unresolved Gate: PASS

Explorer Count After Display: 1
Inspector Count After Display: 1
Draft Count After Display: 21

Final MailItem Display Evidence: PASS
Warm Start Existing Explorer Reuse: PASS
Manual Display / No Auto Send Confirmation: PASS

User Cleanup Lifecycle: PASS
Overall: PASS
```

#### Cold Start

結果：

```text
FAIL / BLOCKED
```

Production Error：

```text
ErrorType=OutlookError
Target=OutlookExplorer
Error 462

リモート サーバーがないか、使用できる状態ではありません。
```

Failure Point：

```text
EnsureOutlookReady
↓
mOutlookApp.Explorers.Count
```

同じCold Testを再実行してもError 462が再発。

その後Outlookを手動起動してWarm Testを再実行しても、Production側だけError 462となった。

---

### 4. Error 462の原因特定

ログ比較から、Test HarnessではなくProduction側のLifecycle Defectと判定した。

決定的Evidence：

```text
2回目Warm Test

Harness:
Explorer Count Before = 1
→ 現在のOutlookを正常取得

Production:
mOutlookApp.Explorers.Count
→ Error 462
```

Root Cause：

P1-07 v0.1の`DisplayMail()`ではDisplay成功後、

```vb
Set mMailItem = Nothing
```

のみ実行し、

```vb
mOutlookApp
```

をModule Stateに保持していた。

その後ユーザーがClassic Outlookを終了すると、

```text
mOutlookApp Is Nothing = False
```

のまま、

```text
終了済みOutlookを指すstale COM proxy
```

となった。

次回`EnsureOutlookReady()`では、

```vb
If mOutlookApp Is Nothing Then
```

がFalseになるためCurrent Outlookを再取得せず、古いCOM参照の、

```vb
mOutlookApp.Explorers.Count
```

へアクセスしてError 462が発生。

さらにReadiness Failure後も`mOutlookApp`を解放していなかったため、Failure Stateが後続Runにも残った。

---

### 5. LF-P1-07-001としてFinding化

Finding：

```text
LF-P1-07-001
Outlook Application Stale Reference
```

Classification：

```text
Implementation Defect
/
Lifecycle Defect
```

以下には分類しなかった。

```text
Requirement Gap:
NONE

Design Finding:
NONE

Test Artifact Defect:
NONE

Blocking Technical Finding:
NONE
```

既存Architecture / Adapter Boundary内のCOM Reference Lifecycle修正で解決可能と判断。

---

### 6. modOutlookAdapter v0.1.1へCorrection

修正版を作成。

- `modOutlookAdapter_P1-07_v0.1.1_CP932.bas`
- `modOutlookAdapter_P1-07_v0.1_to_v0.1.1.patch`
- `LF-P1-07-001 Outlook Application Stale Reference Correction v0.1.md`
- `LF-P1-07-001 Correction Static Review v0.1.md`
- `P1-07 Lifecycle Correction v0.1.zip`

Correction内容：

#### Display成功時

```vb
mMailItem.Display

Set mMailItem = Nothing
Set mOutlookApp = Nothing
```

`Set mOutlookApp = Nothing`はAdapter-held COM Referenceの解放であり、

```text
Outlook.Quit
MailItem.Close
MailItem.Save
MailItem.Send
```

ではない。

#### Readiness Failure時

```vb
Set mOutlookApp = Nothing
```

を実行し、stale / partially initialized Outlook Application Referenceを次Runへ持ち越さない。

Static Review：

```text
Display success releases mMailItem:
PASS

Display success releases mOutlookApp:
PASS

Executable Outlook.Quit:
NONE

Executable MailItem.Send:
NONE

Readiness failed cleanup clears mOutlookApp:
PASS

Readiness ErrorHandler clears mOutlookApp:
PASS

CP932:
PASS

Overall:
PASS
```

---

### 7. Correction後のP1-07再Verification

ユーザーが以下を実施。

```text
modOutlookAdapter v0.1.1へ差し替え
↓
Debug → Compile VBAProject
↓
PASS
```

その後、

```text
1. Warm Start Normal
2. Outlook完全終了
3. Cold Start Normal
4. Cold Startで起動したExplorerを残す
5. Unresolved Fail Closed
```

を実施。

#### Warm Start Normal

```text
CreateMailForDisplay: PASS
Unresolved Gate: PASS
Final MailItem Display Evidence: PASS
Warm Start Existing Explorer Reuse: PASS
Draft Count After Display: PASS
Manual Display / No Auto Send Confirmation: PASS
User Cleanup Lifecycle: PASS

Overall:
PASS
```

#### Cold Start Normal

```text
Explorer Count Before: 0
CreateMailForDisplay: PASS
Unresolved Gate: PASS

Explorer Count After Display: 1
Inspector Count After Display: 1
Draft Count After Display: 21

Cold Start Visible Explorer Initialization: PASS
Final MailItem Display Evidence: PASS
Manual Display / No Auto Send Confirmation: PASS
Cold Start User Cleanup Lifecycle: PASS

Overall:
PASS
```

Cold StartではPreconditionを壊さないため、Outlook未起動時のDraft Count Beforeは取得せず、

```text
N/A
```

とした。

#### Unresolved Fail Closed

意図的に`GateDate`をFormattedValuesから除外。

結果：

```text
CreateMailForDisplay Failure Expected: PASS

HasUnresolved=True
Variables.Count=1
Variable=GateDate

Final MailItem Display = NONE: PASS
Production CloseWithoutSave Lifecycle: PASS

Explorer Count After: 1
Inspector Count After: 0
Draft Count After: 21

Overall:
PASS
```

---

### 8. Error 462再発確認

さらに以下を実施。

```text
Warm PASS
↓
Outlook完全終了
↓
Outlook手動起動
↓
Warm再実行
```

結果：

```text
PASS
```

Error 462：

```text
Recurrence:
NONE
```

LF-P1-07-001のCorrectionが有効であることを確認した。

---

### 9. P1-02 Warm / Cold Regression

`modOutlookAdapter`を変更したため、既存P1-02 Regressionを直接再実行した。

対象：

```text
modP1_02InspectorWordEditorSmokeTest_v0.2.2_CP932.bas
```

#### Warm Start Regression

結果：

```text
Representative Error / No Active MailItem: PASS
Settings / Path Resolution: PASS

Explorer Count Before: 1
Draft Count Before: 21
Inspector Count Before: 0

CreateMailFromTemplate: PASS
Explorer Count After Readiness: 1
Warm Start Existing Explorer Reuse: PASS

ReadBodyText: PASS
BodyText Length: 252
Inspector / WordEditor / Word Document: PASS (indirect)

CloseWithoutSave: PASS
Production Functional Path: PASS

Explorer Count After: 1
Draft Count After: 21
Inspector Count After: 0

Explorer Lifecycle: PASS
Draft Residue: NONE
Inspector Residue: NONE
Scan MailItem Display: NONE

TestP102InspectorWordEditorWarmStart:
PASS
```

#### Cold Start Regression

結果：

```text
Explorer Count Before: 0
Inspector Count Before: 0

CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 252

Inspector / WordEditor / Word Document:
PASS (indirect)

Cold Start Evidence Reacquisition After ReadBodyText:
PASS

Explorer Count Lifecycle Baseline: 1
Draft Count Lifecycle Baseline: 21
Inspector Count During ReadBodyText: 1

CloseWithoutSave: PASS
Production Functional Path: PASS

Explorer Count After: 1
Draft Count After: 21
Inspector Count After: 0

Explorer Lifecycle: PASS
Draft Residue: NONE
Inspector Residue: NONE
Scan MailItem Display: NONE
Cold Start Visible Explorer Initialization: PASS

TestP102InspectorWordEditorColdStart:
PASS
```

---

### 10. P1-07 Close用Execution Record作成

以下4文書を作成した。

1. `P1-07 Production Patch Review v0.1.md`
2. `P1-07 Finding Assessment v0.1.md`
3. `LF-P1-07-001 Closure v0.1.md`
4. `P1-07 Completion Record v0.1.md`

一括：

- `P1-07 Execution Records v0.1.zip`

#### Production Patch Review

最終Production Candidate：

```text
modMailApplication_P1-07_v0.1_CP932.bas

modOutlookAdapter_P1-07_v0.1.1_CP932.bas
```

結果：

```text
Static Review:
PASS

VBA Compile:
PASS

Warm Start E2E:
PASS

Cold Start E2E:
PASS

Unresolved Fail Closed:
PASS

Variables Preservation:
PASS

Production Cleanup:
PASS

No Auto Send:
PASS

Lifecycle:
PASS

LF-P1-07-001:
RESOLVED

P1-02 Warm Regression:
PASS

P1-02 Cold Regression:
PASS

Required P1-01～P1-06 Regression:
PASS

Scope Boundary:
PASS

Blocking Finding:
0

RESULT:
PASS
```

Regressionの扱い：

- P1-02：
  - Warm / Cold Smoke Testを直接再実行
- P1-01 / P1-03 / P1-04 / P1-05 / P1-06：
  - P1-07 E2Eで実Production API経路を再通過
  - 全履歴Testを全件再実行したわけではない
  - Blocking Regressionなしと評価

#### Finding Assessment

最終判定：

```text
Implementation Defect:
LF-P1-07-001 → RESOLVED / CLOSED

Test Artifact Defect:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Technical Finding:
NONE

Regression Finding:
NONE

Active Lifecycle Finding:
NONE

Blocking Finding:
0

RESULT:
PASS
```

#### LF-P1-07-001 Closure

結果：

```text
Root Cause Identified:
PASS

Correction Implemented:
PASS

VBA Compile:
PASS

Warm Re-verification:
PASS

Cold Re-verification:
PASS

Unresolved Fail Closed:
PASS

Recurrence Check:
PASS

P1-02 Warm Regression:
PASS

P1-02 Cold Regression:
PASS

Final Status:
RESOLVED / CLOSED
```

#### P1-07 Completion Record

Completion Criteria：

```text
Approved Unit Specification       PASS
VBA Compile                       PASS
modMailApplication Orchestration  PASS
DisplayMail Production API        PASS
Warm Start Normal E2E             PASS
Cold Start Normal E2E             PASS
Display Gate                      PASS
Unresolved Fail Closed            PASS
Variables Preservation            PASS
Production Cleanup                PASS
No Auto Send                      PASS
Lifecycle                         PASS
P1-01～P1-06 Regression           PASS
Production Patch Review           PASS
Finding Assessment                PASS
Blocking Finding = 0              PASS
```

最終判定：

```text
P1-07 Display / E2E Integration
PASS / COMPLETE
```

---

### 11. P1 Phase Verification実施

P1-01〜P1-07がすべてCompleteとなったため、Implementation Plan v0.3のP1 Phase Verification / Exit Criteriaと照合した。

作成：

- `P1 Phase Verification Record v0.1.md`
- `CP-P1 Establishment Record v0.1.md`
- `P1 Phase Verification and CP-P1 v0.1.zip`

P1 Objective：

```text
Excel
↓
OFT
↓
Classic Outlook Readiness
↓
Outlook
↓
WordEditor
↓
Render
↓
Unresolved Check
↓
Display
```

Production Architecture上で成立。

Phase Verification：

```text
Workbook Relative Path / OFT:
PASS

Warm Start Existing Explorer Reuse:
PASS

Cold Start Visible Explorer Initialization:
PASS

Scan MailItem Display Prevention:
PASS

Draft / Inspector Lifecycle:
PASS

OFT → MailItem:
PASS

Inspector / WordEditor:
PASS

Subject Read / Write:
PASS

BodyText Read:
PASS

Word Range Body Render:
PASS

Post-Render Snapshot:
PASS

Unresolved = 0:
PASS

Normal-only Display:
PASS

No Auto Send:
PASS

Scan / Error CloseWithoutSave:
PASS
```

P1 Exit Criteria：

```text
Production Architecture Happy Path E2E:
PASS

Route W Production Path:
PASS

Warm / Cold Readiness → WordEditor:
PASS

P2以降が利用できるOFT / WordEditor基盤:
PASS

Incomplete State Display Prevention:
PASS

Blocking Technical Finding:
NONE
```

最終判定：

```text
P1 Phase Verification:
PASS

P1 Exit Criteria:
ALL PASS

P1 Walking Skeleton:
PASS / COMPLETE
```

---

### 12. CP-P1 Establishment

Implementation Planでは、

```text
CheckpointはPhase Exit Criteriaを満たした状態を示す
```

と定義されている。

P1 Phase Verification PASSにより、

```text
CP-P1
ESTABLISHED
```

と正式判定した。

現在：

```text
P0 Foundation:
COMPLETE

CP-P0:
ESTABLISHED

P1 Walking Skeleton:
PASS / COMPLETE

CP-P1:
ESTABLISHED
```

Implementation Plan上、P2 Scan / SyncのDependencyは、

```text
P0 / P1
```

のため、

```text
P2 Scan / Sync
ENTRY ALLOWED
```

と判定した。

---

## 決定事項

- `P1-07 Display / E2E Integration`は正式に：

```text
PASS / COMPLETE
```

- P1-07最終Production Candidateは：

```text
modMailApplication_P1-07_v0.1_CP932.bas
modOutlookAdapter_P1-07_v0.1.1_CP932.bas
```

- `modOutlookAdapter_P1-07_v0.1_CP932.bas`は最終Candidateとして使用しない。
- Outlook Application ReferenceはDisplay成功後にAdapter側で解放する。
- Readiness Failure時にも`mOutlookApp`を解放し、次Runへstale COM proxyを持ち越さない。
- `Set mOutlookApp = Nothing`はCOM Reference Releaseであり、OutlookをQuitする処理ではない。
- Cold StartではユーザーによるClassic Outlook事前起動を必要としない。
- Cold Start時はVisible Explorer Initializationを使用する。
- Cold Start時にツールが起動したExplorerは処理後に閉じない。
- 正常系では最終MailItemのみDisplayする。
- 自動Sendは行わない。
- Unresolved Variableが1件以上ある場合：
  - Failure
  - Variables保持
  - Final MailItem Displayなし
  - Production側`CloseWithoutSave`
- P1-07は`ErrorType="RenderError"`の文字列比較でDisplay判定しない。
- `LF-P1-07-001 Outlook Application Stale Reference`は：

```text
RESOLVED / CLOSED
```

- LF-P1-07-001の最終分類：

```text
Implementation Defect
/
Lifecycle Defect
```

- Requirement Gap / Design Finding / Technical Spike Reopenは不要。
- P1-02 Warm / Cold RegressionはCorrection後もPASS。
- P1-01 / P1-03 / P1-04 / P1-05 / P1-06については、P1-07 E2Eによる実Production経路再通過をRequired Regression Evidenceとして使用した。
- P1-07 VerificationはFormal MVP Test Resultではない。
- `MTS-MAIL-*` / `MTS-UNR-*`のFormal PASSとは記録しない。
- `P1 Phase Verification`は：

```text
PASS
```

- `P1 Walking Skeleton`は：

```text
PASS / COMPLETE
```

- `CP-P1`は：

```text
ESTABLISHED
```

- P2 Scan / Syncは：

```text
ENTRY ALLOWED
```

- Current Approved Baselineは引き続き：

```text
BL-MVP-003
```

- Formal MVP Testは未実施。
- Formal MVP TestはP7後のTest Candidate Buildに対して実施する。

---

## 未解決事項

### 1. P2 Scan / Sync

未着手。

次Phase：

```text
P2 Scan / Sync
```

主なImplementation Scope：

```text
modTemplateScanner
modSyncEngine
modSyncApplication
modVariableDefinitionData
modSettingsData
modOutlookAdapter
```

今後の主要論点：

```text
Template Scanner完成版
Locations情報
Sync差分分類
New
Existing
Reactivated
Unused
Rename = Old Unused + New
SyncTimestamp
Metadata更新
既存ユーザー設定維持
Invalid Template時のFail Closed
Sync Result
```

---

### 2. P1 Minimal ScannerとP2完成版Scannerの差分

P1-04ではMinimal Scannerとして、

```text
ValidVariables
InvalidCandidates
```

まで成立。

Design上の完成版`TemplateScanResult`には少なくとも、

```text
ValidVariables
InvalidCandidates
Locations
```

が想定されている。

P2でLocation情報およびSync向けScanner結果をどこまで拡張するか要確認。

---

### 3. Sync Engine設計詳細

未実装・未確認。

確認対象：

```text
New / Existing / Reactivated / Unused
Case Insensitive比較
Renameを推測しない
Existingユーザー設定を壊さない
FirstDetectedAt
LastDetectedAt
SyncTimestamp
TemplateLocation
```

---

### 4. P2のImplementation Unit分割

未決定。

P1では、

```text
P1-01 ～ P1-07
```

へ細分化したが、P2をどの粒度のImplementation Unitに分割するかは未決定。

候補例：

```text
P2-01 Scanner Completion
P2-02 VariableDefinition Read Boundary
P2-03 Sync Diff Core
P2-04 Metadata Update
P2-05 Sync Application Integration
P2-06 Error / No-Update Gate
```

ただし、この分割はまだ決定事項ではない。

---

### 5. Project Control / Registry更新

この会話では、

```text
P1 Phase Verification Record v0.1
CP-P1 Establishment Record v0.1
```

までは作成した。

一方で、Project Document Registry / Current Development State文書を、

```text
P1 COMPLETE
CP-P1 ESTABLISHED
P2 ENTRY ALLOWED
```

へ更新する専用Patch / Revisionは作成していない。

必要性は次チャットで確認。

---

### 6. P6責務として残している事項

P1では意図的に最終化していない。

```text
Final Error Taxonomy
COM Error網羅
Lifecycle最終化
Error Aggregation / User-facing Error Priority
User Notification
Final Fail Closed Error Integration
```

P1でこれらを完成扱いしない。

---

### 7. Cleanup Failureの最終Error表現

P1-07ではFail Closed基本経路は成立済み。

ただし、

```text
Primary Failure
+
Cleanup Failure
```

が同時発生した場合の、

```text
最終Error Aggregation
代表Error
User-facing Priority
```

はP6責務として残している。

P1-07で正式な最終Error Policyを固定しない。

---

### 8. Formal MVP Test

未実施。

現在のVerificationは、

```text
Implementation Verification
Phase Verification
Regression Evidence
```

であり、

```text
Formal DOC-MVP-TESTSPEC Test Result
```

ではない。

---

## 次アクション

### 優先度1：P2 Entry / Boundary Confirmation

次チャットでは、いきなり実装せず、

```text
P2 Scan / Sync
```

のBoundary Confirmationから開始する。

最初に確認するもの：

1. `Implementation Plan v0.3 日本語版(2).md`

   - P2 Scan / Sync
   - Objective
   - Scope
   - Phase Verification
   - Exit Criteria

2. `MVP Design v0.1.9 日本語版.md`

   - §14 Template Scanner
   - §15 Sync Engine
   - §25.1 手動同期

3. `MVP Test Specification v0.1.5 日本語版.md`

   - MTS-TPL
   - MTS-SCAN
   - MTS-SYNC

4. `P1 Phase Verification Record v0.1.md`

5. `CP-P1 Establishment Record v0.1.md`

6. `P1-04 Minimal Template Scanner Completion Record v0.1.md`

   - P1 Minimal Scannerの成立範囲確認

---

### 優先度2：P2のImplementation Unit分割を決める

確認観点：

```text
Scanner Completion
Sync Core
VariableDefinition Data Access
Metadata Update
Application Integration
Failure / No-Update Boundary
```

P1同様、

```text
大きなPhaseを一気に実装しない
↓
意味のある最小Implementation Unitへ分割
↓
各UnitでSpecification
↓
Production
↓
Compile
↓
Verification
↓
Completion
```

の進め方を推奨。

---

### 優先度3：P2最初のImplementation Unit仕様作成

Boundary確定後に、

```text
P2-xx ... 実施仕様 v0.1
```

を作成。

最初の候補は、

```text
P1 Minimal Scanner
↓
P2 Full TemplateScanResult
```

の差分整理。

特に、

```text
Locations
Subject / Body / Both
Case Insensitive Identity
InvalidCandidates
```

をどこまでP2最初のUnitで完成させるか確認する。

---

### 次チャット開始用短縮版

```text
Project:
定型メール作成ツール MVP

Current Approved Baseline:
BL-MVP-003

P0 Foundation:
PASS / COMPLETE

CP-P0:
ESTABLISHED

P1 Walking Skeleton:
PASS / COMPLETE

CP-P1:
ESTABLISHED

P1-01:
PASS / COMPLETE

P1-02:
PASS / COMPLETE

P1-03:
PASS / COMPLETE

P1-04:
PASS / COMPLETE

P1-05:
PASS / COMPLETE

P1-06:
PASS / COMPLETE

P1-07:
PASS / COMPLETE

P1 Final Production:
modMailApplication_P1-07_v0.1_CP932.bas
modOutlookAdapter_P1-07_v0.1.1_CP932.bas

LF-P1-07-001:
Outlook Application Stale Reference
→ Implementation / Lifecycle Defect
→ mOutlookApp stale COM proxy
→ v0.1.1 Correction
→ Warm PASS
→ Cold PASS
→ Restart PASS
→ P1-02 Regression PASS
→ RESOLVED / CLOSED

Latest Phase Verification:
P1 Phase Verification = PASS

Checkpoint:
CP-P1 = ESTABLISHED

Formal MVP Test:
NOT EXECUTED

Next Phase:
P2 Scan / Sync

P2 Entry:
ALLOWED

Next Task:
P2 Boundary Confirmation

Start without coding.

Read First:
1. Implementation Plan v0.3 — P2
2. MVP Design v0.1.9 — §14 / §15 / §25.1
3. MVP Test Specification v0.1.5 — MTS-TPL / SCAN / SYNC
4. P1 Phase Verification Record v0.1
5. CP-P1 Establishment Record v0.1
6. P1-04 Minimal Template Scanner Completion Record v0.1
```

# 記事用素材

## 気づき

### 1. 「NothingではないCOM参照」が有効とは限らない

今回の最大の技術的学び。

```text
mOutlookApp Is Nothing = False
```

でも、

```text
COM Server側のOutlookが既に終了
```

していれば、そのReferenceは有効とは限らない。

実際に、

```text
Warm 1回目:
PASS

Outlook終了

Cold:
Error 462

次のWarm:
Error 462
```

となった。

COM Objectでは、

```text
Reference存在
≠
Server利用可能
```

というLifecycleを意識する必要がある。

---

### 2. Application-level COM ObjectをModule Stateへ長く保持するRisk

`mOutlookApp`をModule Stateへ保持すると便利だが、

```text
ユーザーがOutlookを終了
再起動
```

した場合に、VBA側がstale proxyを持ち続ける可能性がある。

今回、

```text
1生成処理
↓
必要なOutlook Application取得
↓
処理
↓
Reference release
```

へ寄せることで解決できた。

---

### 3. Test HarnessとProductionの観測結果を比較すると原因を絞れる

2回目Warm Testで、

```text
Harness:
Explorer Count Before = 1

Production:
Error 462
```

となったことが重要だった。

同じOutlook環境でも、

```text
Test Harnessが取得したCurrent COM Reference
Productionが保持していたOld COM Reference
```

で結果が異なる。

これにより、

```text
Outlook自体の問題
Test Harnessの問題
```

ではなく、

```text
Production Module State
```

へ原因を絞れた。

---

### 4. Cold Start Testでは「測定」がPreconditionを壊すことがある

Outlook未起動時にDraft Countを取得しようとすると、その操作自体がOutlookを起動してしまう可能性がある。

そのため、

```text
Draft Count Before:
N/A
```

を許容した。

Testでは、

> 観測のための処理がTest対象の状態を変えていないか

を常に考える必要がある。

---

### 5. Integration TestでFailureしたら、すぐProductionを直さない

今回も、

```text
Warm PASS
Cold FAIL
```

の段階ですぐ大幅改修せず、

```text
再実行
Warm再確認
HarnessとProduction比較
Error Point特定
Root Cause仮説
Correction
再Verification
Regression
```

と進めた。

結果としてRequirement / Design変更なしで、Implementation DetailのLifecycle Defectとして閉じられた。

---

### 6. Finding Classificationを先に持っていると過剰修正を避けられる

今回のFindingは、

```text
Implementation Defect
Lifecycle Defect
```

であり、

```text
Requirement Gap
Design Finding
Technical Spike
```

ではなかった。

Classificationを明確にすることで、

```text
Requirementsを修正
DesignをRevision
Technical Spikeを再開
```

といった不要な作業を避けられた。

---

### 7. Phase VerificationとUnit Completionは別物

P1-07がCompleteになっても、

```text
P1-07 COMPLETE
≠
CP-P1 ESTABLISHED
```

だった。

Phase全体の、

```text
Objective
Phase Verification
Exit Criteria
Blocking Finding
```

を再評価して初めてCheckpointをEstablishedにした。

このGate設計は今後のP2〜P7でも使える。

---

### 8. Formal TestとImplementation Verificationを分ける重要性

今回、

```text
MTS-MAIL
MTS-UNR
```

相当のScenarioをかなり実行したが、

```text
Formal MTS PASS
```

とは記録しなかった。

理由：

```text
Implementation Phase Verification
≠
Frozen Test Candidate Buildに対するFormal Product Test
```

この分離により、途中のSmoke Testを正式品質判定と誤認しにくい。

---

### 9. Regressionは「全部再実行」ではなく変更影響から決める

`modOutlookAdapter`を変更したため、

```text
P1-02 Warm / Cold
```

は直接Regressionした。

一方、

```text
P1-01
P1-03
P1-04
P1-05
P1-06
```

はP1-07 E2EでProduction経路を再通過しているため、それをBlocking Regression Evidenceとして使った。

変更影響に応じてRegression範囲を決める考え方は再利用可能。

---

### 10. AI協働でもEvidenceをユーザー実行で閉じる必要がある

AI側では、

```text
コード生成
Static Review
Test Harness生成
原因分析
Finding文書化
```

までできる。

しかし、

```text
VBA Compile
Classic Outlook Runtime
Warm / Cold Start
Inspector / Draft Lifecycle
```

は実環境Evidenceが必要。

AIの推論と実Runtime Evidenceを明確に分ける運用が有効だった。

---

## 記事にできそうな切り口

### 開発日記向き

- 「Warmでは動くのにColdで壊れた――Outlook VBAのError 462を追いかけた日」
- 「最初のテストはPASS。でも2回目から全部壊れた」
- 「AIが作ったコードをそのまま信じず、Runtime Evidenceで潰した話」
- 「P1 Walking Skeleton完成まで7つのImplementation Unitに分けた個人開発」
- 「『動いた』ではなく『Checkpointを切れる』まで確認する開発」
- 「Cold Start TestでDraft Countを測ろうとするとTest条件が壊れるという罠」
- 「FindingをRequirement Gapにしなかった理由」
- 「バグを直したあとに、あえて古いP1-02 Testをもう一度回した話」
- 「個人開発なのにProduction Patch Review / Finding Assessment / Completion Recordを作る理由」
- 「AIと一緒にVBAを作ったら、COM Lifecycleのバグまで追跡できた」

---

### 技術記事向き

- **Outlook VBA Error 462とstale COM proxy**

  - `Is Nothing=False`でもCOM Serverが死んでいるケース
  - Module-level COM ReferenceのLifecycle
  - Outlook再起動を跨ぐReference保持のRisk

- **Classic Outlook Cold Start対応**

  - Existing Explorer reuse
  - Visible Explorer Initialization
  - Hidden Explorer不採用
  - WordEditor利用条件

- **Outlook / Word COM Lifecycle設計**

  - Application
  - Explorer
  - MailItem
  - Inspector
  - WordEditor
  - Word Document
  - 各ObjectのOwnership

- **Walking Skeletonの作り方**

  - Excel
  - OFT
  - Outlook
  - WordEditor
  - Scanner
  - Renderer
  - Unresolved Checker
  - Display

- **Fail Closed Mail Generation**

  - Render
  - Post Snapshot
  - Unresolved Checker
  - Positive Display Gate
  - Failure Cleanup

- **VBAでのResult Pattern**

  - `COperationResult`
  - `CErrorInfo`
  - ErrorType / Message / Target
  - Runtime ErrorをResultへ変換

- **WordEditorによるOutlook本文置換**

  - `Range.Find`
  - `Range.Text`
  - HTMLBodyを使わない理由
  - Case Insensitive / All Occurrences

- **Integration VerificationとFormal Testの分離**

  - Implementation Test
  - Phase Verification
  - Regression
  - Test Candidate Build
  - Formal Product Test

- **Regression Scopeの決め方**

  - 変更Moduleを直接Regression
  - E2EによるIntegrated Regression
  - 全件再実行との使い分け

- **Checkpoint Driven Development**

  - Unit Completion
  - Phase Exit Criteria
  - CP-P0
  - CP-P1
  - downstream dependency

---

## 有料note / テンプレート化候補

### 1. Implementation Unit Completion Template

```text
Approved Specification
Compile
Core Verification
Integration
Negative / Failure
Regression
Static Review
Finding Assessment
Blocking Finding
Completion Record
```

各Implementation Unitを閉じるための汎用Checklistとして使える。

---

### 2. Finding Classification Template

```text
Implementation Defect
Test Artifact Defect
Requirement Gap
Design Finding
Technical Finding
Regression Finding
Lifecycle Finding
```

各Findingについて、

```text
Evidence
Root Cause
Correction
Re-verification
Regression
Closure
```

まで管理するテンプレート。

---

### 3. COM Lifecycle Review Checklist

対象：

```text
Application
Explorer
MailItem
Inspector
WordEditor
Word Document
Range
```

確認事項：

```text
Owner
Lifetime
Release Timing
Closeするか
Quitするか
Local Referenceか
Module Stateか
Failure時Cleanup
再Run時staleにならないか
```

---

### 4. Warm / Cold Start Verification Template

```text
Outlook Start State
Explorer Count Before
Draft Count Before
Inspector Count Before

Production Result

Explorer Count After
Draft Count After
Inspector Count After

Existing Explorer Reuse
Visible Explorer Initialization
Draft Residue
Inspector Residue
No Auto Send
```

Outlookに限らず、外部Application依存処理のTest Templateとして展開可能。

---

### 5. Fail Closed Verification Template

```text
Normal:
Success
↓
Display

Failure:
Error Result
↓
No Display
↓
Cleanup
↓
Residue NONE
```

メール生成、ファイル生成、データ更新等に応用可能。

---

### 6. Phase Verification / Checkpoint Template

```text
Phase Objective
Phase Verification Matrix
Exit Criteria
Implementation Unit Summary
Regression
Finding Status
Scope Boundary
Formal Test Boundary
Checkpoint Decision
Downstream Entry
```

P0〜P7のような段階開発だけでなく、一般的な個人開発やAI協働開発にも使える。

---

### 7. AI協働開発用「Evidence First」プロンプト集

例：

```text
仕様変更を提案する前に、
Implementation Defect / Test Artifact Defect /
Requirement Gap / Design Finding /
Technical Findingを分類してください。

Runtime Evidenceが不足している場合は、
不足Evidenceを明示してください。

Formal Test Resultと
Implementation Verificationを混同しないでください。
```

AIが勝手にDesign変更・過剰修正するのを防ぐためのPrompt Templateにできる。

---

### 8. Production Patch Review Template

確認項目：

```text
Specification Conformance
Module Responsibility
Public API
Forbidden Behavior
Fail Closed
COM Leakage
Lifecycle
Scope Expansion
Regression
Formal Test Boundary
Blocking Finding
```

---

### 9. Completion Record Template

```text
What was implemented
Production artifacts
Verification evidence
Regression evidence
Findings
Resolved / Open
Completion criteria
Final result
Next gate
```

プロジェクトの「どこまで終わったか」を後から再現できるExecution Recordとして汎用化可能。
