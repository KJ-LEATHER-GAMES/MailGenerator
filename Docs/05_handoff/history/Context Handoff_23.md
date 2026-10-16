# 引き継ぎまとめ

## 実施内容

### 1. 現在地の確認とP2-05残Runtime Verification計画

- 対象プロジェクト：**定型メール作成ツール**
- 技術構成：Excel VBA + Classic Outlook + OFT
- Phase：**P2 Scan / Sync**
- Implementation Unit：**P2-05 Fail Closed / Sync Result / Phase Integration**
- Execution Baseline：**BL-MVP-003**
- 会話開始時点では以下が完了済みだった。
  - P05-I07 Invalid Candidate：PASS / CLOSED
  - P05-I16 Fresh Retry：PASS / CLOSED
  - P05-I08 OFT Missing：PASS / CLOSED
- 残Runtime Caseとして以下を実施した。
  - P05-I02 New Only
  - P05-I04 Reactivated Only
  - P05-I05 Unused Only
  - P05-I06 Zero-diff Success
  - P05-I01 Mixed Result
- Fixture変更量を最小化するため、実施順を以下へ最適化した。
  - `I02 → I04 → I05 → I06 → I01`
- Production CodeへTest専用Hookは追加しなかった。

---

### 2. P05-I02 — New Only

Controlled Fixture：

- 既存VariableDefinitionをUnused状態へ調整
- OFTには `{{P05_NewOnly}}` のみを配置
- `P05_NewOnly` はVariableDefinitionに存在しない状態で実行

実測結果：

- New = 1
  - `P05_NewOnly`
- Existing = 0
- Reactivated = 0
- Unused = 0
- Success UI表示あり
- VariableDefinitionへ新規行追加
  - Status = Active
  - TemplateLocation = Body
  - FirstDetectedAt = LastDetectedAt = `10/7/2026 0:20`
  - User Configuration列は未設定

判定：

```text
P05-I02 — New Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

作成：

- `P05-I02 New Only Runtime Verification Record v0.1.md`

論理保存先：

```text
定型メール作成ツール
└─ P2-05 Fail Closed - Sync Result - Phase Integration
   └─ Verification
      └─ P05-I02 New Only Runtime Verification Record v0.1.md
```

---

### 3. P05-I04 — Reactivated Only

Fixture：

- OFT側の `{{P05_NewOnly}}` は維持
- VariableDefinitionの `P05_NewOnly` をTest Fixtureとして
  - Active → Unused
- 他既存行はUnused維持

実測結果：

- New = 0
- Existing = 0
- Reactivated = 1
  - `P05_NewOnly`
- Unused = 0
- UIでは「復活」へ表示
- 「継続」にはマージされなかった
- VariableDefinition：
  - Status：Unused → Active
  - FirstDetectedAt：保持
  - LastDetectedAt：`0:20 → 0:29`

判定：

```text
P05-I04 — Reactivated Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

作成：

- `P05-I04 Reactivated Only Runtime Verification Record v0.1.md`

---

### 4. Locals Window Evidence方針を改善

I02 / I04ではUIとVariableDefinitionのBefore / Afterを中心に判定した。

I05以降はEvidence強化のため、原則として以下4点を取得する方針にした。

```text
1. 実施前 VariableDefinition
2. Locals Window
3. Sync Result UI
4. 実施後 VariableDefinition
```

Locals Windowでは主に以下を直接確認した。

```text
operationResult.Success

syncDiffResult
→ Exists / Dictionary

templateScanResult
→ Exists / Dictionary
```

注意点として、

```text
syncDiffResult.Count = 4
templateScanResult.Count = 3
```

は分類件数ではなくDictionary Key数であることを明文化した。

---

### 5. P05-I05 — Unused Only

Fixture：

- I04終了時の `P05_NewOnly = Active`
- OFTから `{{P05_NewOnly}}` を削除
- VariableDefinition側は手動変更しない

実測：

```text
operationResult.Success = True
syncDiffResult = Exists
templateScanResult = Exists
```

分類：

- New = 0
- Existing = 0
- Reactivated = 0
- Unused = 1
  - `P05_NewOnly`

Persistence：

- VariableDefinition行は削除されない
- Status：Active → Unused
- TemplateLocation：Body保持
- FirstDetectedAt：保持
- LastDetectedAt：保持

判定：

```text
P05-I05 — Unused Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

作成：

- `P05-I05 Unused Only Runtime Verification Record v0.1.md`

---

### 6. P05-I06 — Zero-diff Success

I05終了後の状態をそのまま利用した。

Initial State：

- Template側に分類対象Variableなし
- VariableDefinition全行Unused

Fixture変更：

```text
NONE
```

実測：

```text
operationResult.Success = True

syncDiffResult = Exists
templateScanResult = Exists

New = 0
Existing = 0
Reactivated = 0
Unused = 0
```

VariableDefinition：

- Row Add = 0
- Row Delete = 0
- Status Change = 0
- TemplateLocation Change = 0
- FirstDetectedAt Change = 0
- LastDetectedAt Change = 0

Zero-diffでも正常なManual Sync Successとなることを確認。

判定：

```text
P05-I06 — Zero-diff Success
PASS / CLOSED

Re-test:
NOT REQUIRED
```

作成：

- `P05-I06 Zero-diff Success Runtime Verification Record v0.1.md`

---

### 7. P05-I01 — Mixed Result

Controlled Fixture：

```text
ModelName
Active + Templateあり
→ Existing

GateDate
Active + Templateなし
→ Unused

Department
Unused + Templateあり
→ Reactivated

P05_MixedNew
VariableDefinition行なし + Templateあり
→ New
```

OFT：

```text
{{ModelName}}
{{Department}}
{{P05_MixedNew}}
```

実測分類：

```text
New:
1
- P05_MixedNew

Existing:
1
- ModelName

Reactivated:
1
- Department

Unused:
1
- GateDate
```

Locals：

```text
operationResult.Success = True
syncDiffResult = Exists
templateScanResult = Exists
```

Persistence確認：

- New `P05_MixedNew`
  - Active
  - Body
  - FirstDetectedAt = LastDetectedAt = `10/7/2026 6:42`
- Existing `ModelName`
  - Active維持
  - TemplateLocation Both → Body
  - FirstDetectedAt保持
  - LastDetectedAt → `6:42`
- Reactivated `Department`
  - Unused → Active
  - FirstDetectedAt保持
  - LastDetectedAt → `6:42`
- Unused `GateDate`
  - Active → Unused
  - TemplateLocation保持
  - FirstDetectedAt保持
  - LastDetectedAt保持

同一Sync内で検出対象Variableに共通のSyncTimestamp：

```text
10/7/2026 6:42
```

が使われることも確認した。

判定：

```text
P05-I01 — Mixed Result
PASS / CLOSED

Re-test:
NOT REQUIRED
```

作成：

- `P05-I01 Mixed Result Runtime Verification Record v0.1.md`

---

### 8. Verification Evidence Consolidation

P2-05 Implementation Verification Evidenceを統合した。

作成：

- `P2-05 Verification Evidence Consolidation v0.1.md`

整理した状態：

```text
P05-I01 ～ P05-I17
PASS = 17
FAIL = 0
BLOCKED = 0
UNRESOLVED = 0

P05-K01 ～ P05-K04
PASS = 4
FAIL = 0
```

今回新規にRuntime確認した：

- I01
- I02
- I04
- I05
- I06

については新しいRuntime Evidenceを使用。

既存Evidenceを利用した：

- I03
- I07
- I08
- I09
- I10～I17
- K01～K04

Consolidation判定：

```text
P2-05 Verification Evidence Consolidation
PASS / CLOSED
```

ただし：

```text
P2-05
NOT COMPLETE

P2 Phase
IN PROGRESS

CP-P2
NOT ESTABLISHED
```

---

### 9. P2-01 Full Template Scanner Regression開始

作成：

- `P2-01 Full Template Scanner Regression 実施計画 v0.1.md`

Regression Scope：

```text
R1 Core Regression
R2 Baseline OFT Integration
R3 Recipient Exclusion Integration
```

Pre-Regressionとして、P2-05用FixtureをBaselineへ戻した。

VariableDefinitionは以下へ復元。

```text
ModelName    Active
OldVariable  Unused
GateDate     Active
Department   Active
Comment      Active
```

P2-05 Fixture Row：

```text
P05_NewOnly
P05_MixedNew
```

は除去した。

---

### 10. P2-01 Core Regression

実行：

```vb
TestP201FullTemplateScannerCore
```

結果：

```text
C1 Subject Only: PASS
C2 Body Only: PASS
C3 Both: PASS
C4 Case Insensitive Both: PASS
C5 Multiple Same Source: PASS
C6 Mixed Locations: PASS
C7 Invalid Candidates Regression: PASS
C8 Valid + Invalid Mixed: PASS
C9 Empty Input Regression: PASS
C10 First Detection Order Regression: PASS
C11 TemplateScanResult Structural Invariant: PASS

PASS Count: 11
FAIL Count: 0
```

判定：

```text
Core Regression
11 / 11 PASS
```

---

### 11. P2-01 Integration初回実行でReadBodyText Failure

Baseline OFT Integration：

```text
GetSettingValue: PASS
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: FAIL
CloseWithoutSave: PASS
```

Recipient Exclusion Integration：

```text
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: FAIL
CloseWithoutSave: PASS
```

両方とも `ScanTemplate` 到達前にFailure。

一時的に、参照OFT違いの可能性も確認した。

実際のResolvedPath：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate_MTS-SCAN-005.oft
```

---

### 12. OFT Fixture内容を再確認

Baseline `MailTemplate.oft`：

- Subject：
  - `{{ModelName}}`
  - `{{GateDate}}`
  - `{{modelname}}`
- Body：
  - `{{ModelName}}`
  - `{{GateDate}}`
  - `{{Department}}`
  - `{{Comment}}`

MTS-SCAN-005：

```text
Subject:
{{ModelName}}

Body:
担当部署：{{Department}}

To:
{{RecipientTo}}

CC:
{{RecipientCc}}

BCC:
{{RecipientBcc}}
```

ユーザーが共有した：

- `modP201MtsScan005IntegTest_current.bas`

も確認した。

Test Harnessは以下を期待していた。

```text
VAR_SUBJECT = ModelName
VAR_BODY    = Department
VAR_TO      = RecipientTo
VAR_CC      = RecipientCc
VAR_BCC     = RecipientBcc
```

したがって、

```text
MTS-SCAN-005 BodyがDepartmentだけ
```

なのはFixture不備ではないと判断した。

---

### 13. ReadBodyText FailureのTriage

初回Integration Failureは両OFTで共通して、

```text
CreateMailFromTemplate = PASS
ReadSubject            = PASS
ReadBodyText           = FAIL
```

だったため、故障境界を以下まで絞った。

```text
modOutlookAdapter.ReadBodyText
↓
Inspector
↓
WordEditor
↓
Word Document
```

Scannerは未実行だったため、

```text
modTemplateScanner
ValidVariables
InvalidCandidates
Locations
Recipient Exclusion
```

のRegressionを示すEvidenceではないと整理。

ただし初回Failureログでは：

```text
ErrorType
Message
Target
```

を取得していなかったため、Exact Root Causeは未証明。

既知Observation：

```text
OBS-P2-05-002
Intermittent WordEditor E_FAIL
```

との関連は疑われるが、同一原因と断定しない方針にした。

作成：

- `P2-01 Regression ReadBodyText Failure Triage Plan v0.1.md`

---

### 14. Fresh Warm Controlled Rerun

Production Code変更なしでFresh Warm状態から再実行した。

Baseline OFT Integration結果：

```text
ReadBodyText: PASS
BodyText Length: 251

ScanTemplate: PASS

ValidVariables:
ModelName
GateDate
Department
Comment

InvalidCandidates:
0

Locations:
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body

TemplateScanResult Structural Invariant:
PASS

CloseWithoutSave:
PASS

Overall:
PASS
```

Recipient Exclusion結果：

```text
ReadBodyText: PASS
BodyText Length: 20

ValidVariables:
ModelName
Department

Locations:
ModelName   = Subject
Department  = Body

RecipientTo:
NOT DETECTED

RecipientCc:
NOT DETECTED

RecipientBcc:
NOT DETECTED

InvalidCandidates:
0

TemplateScanResult Structural Invariant:
PASS

CloseWithoutSave:
PASS

Overall:
PASS
```

---

### 15. P2-01 Regression Record作成

初回Failure → Fixture確認 → Failure Boundary整理 → Fresh Warm再実行PASSまでを正式記録した。

作成：

- `P2-01 Full Template Scanner Regression Record v0.1.md`

最終判定：

```text
P2-01 Core:
11 / 11 PASS

Baseline OFT Integration:
PASS

Recipient Exclusion:
PASS

Confirmed Scanner Regression Finding:
NONE

Confirmed Fixture Finding:
NONE

Confirmed Production Defect:
NONE

Residual Observation:
OBS-P2-05-002
OPEN / NON-BLOCKING

Production Correction:
NONE

P2-01 Full Template Scanner Regression:
PASS / CLOSED
```

論理保存先：

```text
定型メール作成ツール
└─ P2-05 Fail Closed - Sync Result - Phase Integration
   └─ Regression
      └─ P2-01
         ├─ P2-01 Full Template Scanner Regression 実施計画 v0.1.md
         ├─ P2-01 Regression ReadBodyText Failure Triage Plan v0.1.md
         └─ P2-01 Full Template Scanner Regression Record v0.1.md
```

---

## 決定事項

### P05-I02

```text
P05-I02 New Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

---

### P05-I04

```text
P05-I04 Reactivated Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

- Reactivatedは「復活」へ表示する。
- Existing「継続」へマージしない。

---

### P05-I05

```text
P05-I05 Unused Only
PASS / CLOSED

Re-test:
NOT REQUIRED
```

- Unused化ではVariableDefinition行を削除しない。
- StatusのみActive → Unused。
- TemplateLocation / FirstDetectedAt / LastDetectedAtは保持。

---

### P05-I06

```text
P05-I06 Zero-diff Success
PASS / CLOSED

Re-test:
NOT REQUIRED
```

- 4分類すべて0件でもSuccessは正常。
- Zero-diffはFailureとして扱わない。

---

### P05-I01

```text
P05-I01 Mixed Result
PASS / CLOSED

Re-test:
NOT REQUIRED
```

- 4分類を同一Executionで正しく独立分類できることを確認。
- Single SyncTimestamp規則も成立。

---

### Runtime Verification Evidence方針

- Production CodeへTest専用Hookを追加しない。
- Runtimeで観測可能なものはLocals Windowで直接確認する。
- `syncDiffResult.Count` 等を分類件数と誤解しない。
- UIとCarrier / Persistence Evidenceを組み合わせる。
- Fixture変更とProductionによる変更を明確に分離して記録する。

---

### Verification Evidence Consolidation

```text
P2-05 Verification Evidence Consolidation
PASS / CLOSED
```

ただし：

```text
P2-05 COMPLETEではない
CP-P2 ESTABLISHEDでもない
```

---

### P2-01 Regression

```text
P2-01 Full Template Scanner Regression
PASS / CLOSED
```

成立Evidence：

```text
Core:
11 / 11 PASS

Baseline OFT Integration:
PASS

Recipient Exclusion:
PASS
```

---

### 初回ReadBodyText Failureの扱い

明確に決めたこと：

- Scanner Regressionとしない。
- Fixture Defectとしない。
- Production Defectと確定しない。
- Production Code修正を行わない。
- Exact Root Causeは未証明とする。
- Fresh Warm Controlled Rerun PASSをRegression最終判定に採用する。
- `OBS-P2-05-002` は継続。

```text
OBS-P2-05-002
OPEN / NON-BLOCKING
```

以下は採用しない。

```text
Sleep追加
Fixed delay追加
DoEvents推測追加
Retry loop追加
Automatic Retry追加
Public API変更
```

理由：

- Exact Root Causeが証明されていない。
- Production Code変更なしでFresh Warm再実行がPASSしたため。

---

## 未解決事項

### 1. Intermittent ReadBodyText / WordEditor FailureのExact Root Cause

未確認：

```text
ErrorType
Message
Target
```

初回P2-01 Regression Failure時には取得できていない。

したがって：

```text
今回のFailure
=
OBS-P2-05-002 WordEditor E_FAIL
```

とは断定できない。

現状：

```text
Exact Technical Root Cause:
NOT PROVEN
```

---

### 2. OBS-P2-05-002

継続Observation：

```text
OBS-P2-05-002
Intermittent WordEditor E_FAIL

Status:
OPEN / NON-BLOCKING
```

Fresh Warm RunManualSyncでWordEditor E_FAILが再現、またはOperational Useで反復再発した場合は再評価が必要。

再発時はFailing Sessionを保持し、

```vb
TestP205DiagImmediateNoGuard
```

をP1 Smoke Testより先に実行する。

---

### 3. P2-01 Test Harnessの観測性

現在のIntegration HarnessはFailure時、

```text
ReadBodyText: FAIL
```

までしか出さない。

改善候補：

```text
Success
Errors.Count
ErrorType
Message
Target
```

をTest Artifact側で出す。

ただし：

- 現P2-01 Regression CloseのBlockerではない。
- Production Codeへ観測用Hookを追加しない。

---

### 4. P2-05 Completion残作業

未実施：

```text
P2-02 Regression
P2-03 Regression
P2-04 Regression
VBA Compile
Static Review S01-S32
Production Patch Review
Final Finding Assessment
P2-05 Completion Decision
```

したがって現状：

```text
P2-05:
IN PROGRESS / NOT COMPLETE

P2 Phase:
IN PROGRESS

CP-P2:
NOT ESTABLISHED
```

---

### 5. P2 Phase Completion

P2-05 COMPLETE後も以下が残る。

```text
P2 Phase Verification
↓
P2 Exit Criteria Final Check
↓
CP-P2 Establishment Decision
```

---

## 次アクション

### 優先度1 — P2-02 Sync Diff Core Regression

次チャットはここから開始する。

最初に参照するもの：

- `P2-02 Sync Diff Core Completion Record v0.1.md`
- `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md`
- `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md`
- `P2-01 Full Template Scanner Regression Record v0.1.md`

既存Regression基準：

```text
Bootstrap:
33 / 33 PASS

Detection History:
43 / 43 PASS

Date Serial:
9 / 9 PASS

Core:
18 / 18 PASS

Technical Negative:
6 / 6 PASS

Contract Compatibility:
2 / 2 PASS

Total:
111 / 111 PASS
```

最初にやること：

1. 現行P2-02 Regression Entry Pointを確認する。
2. 既存6 Suiteを実行する。
3. Immediate Window Evidenceを保存する。
4. `111 / 111 PASS` か確認する。
5. Failureが出た場合は即Production Defect扱いせず、
   - Production Defect
   - Test Artifact Defect
   - Fixture Defect
   - Contract Finding
   - Environment / Session Issue
   を切り分ける。
6. PASSなら `P2-02 Sync Diff Core Regression Record` を作成する。

---

### 優先度2 — P2-03 Regression

P2-02 PASS後。

既存基準：

```text
Bootstrap:
7 / 7 PASS

Detection History:
6 / 6 PASS

Core:
12 / 12 PASS

Technical Negative:
18 / 18 PASS

Compatibility:
3 / 3 PASS

Total:
46 / 46 PASS
```

---

### 優先度3 — P2-04 Regression

P2-03 PASS後。

P2-04既存Integration ContractがP2-05実装後も維持されていることを確認する。

---

### 優先度4以降

```text
VBA Compile
↓
Static Review S01-S32
↓
Production Patch Review
↓
Final Finding Assessment
↓
P2-05 Completion Decision
```

境界を維持する。

```text
Regression PASS
≠
P2-05 COMPLETE

P2-05 COMPLETE
≠
CP-P2 ESTABLISHED
```

---

# 記事用素材

## 気づき

### 1. 「失敗したテスト」と「壊れた機能」は同じではない

今回P2-01 Integrationが一度FAILしたが、

```text
CreateMailFromTemplate PASS
ReadSubject PASS
ReadBodyText FAIL
ScanTemplate未到達
```

だった。

つまり「Scanner Regression TestがFAILした」ことと「Scannerが壊れた」ことは別。

失敗地点をBoundary単位で切り分けることで、

```text
Scanner
OFT Fixture
Outlook Adapter
WordEditor / COM
```

を混同せずに済んだ。

---

### 2. Failure Boundaryを特定してから修正を考える

初回Failureを見て、

```text
DoEvents
Sleep
Retry
```

を入れるのは簡単だった。

しかしFresh Warm再実行でProduction Code変更なしにPASSした。

このことから、

> 原因を証明できない状態でタイミング対策を入れると、推測修正になる

という実例になった。

---

### 3. Fixtureは「それっぽさ」ではなくTest Intentで評価する

`MailTemplate_MTS-SCAN-005.oft` のBodyが

```text
担当部署：{{Department}}
```

だけだったため、一時的に「Fixtureが足りないのでは」と疑った。

しかしTest Intentは、

```text
Subject / BodyをScanする
To / CC / BCCをScanしない
```

こと。

Test Harnessも `Department` だけを期待していた。

したがって、実運用OFTらしい内容である必要はなく、**目的を最小構成で満たすFixtureが正しい**。

---

### 4. Test Harness自身の観測性も品質の一部

今回、

```text
ReadBodyText: FAIL
```

だけでは、

```text
ErrorType
Message
Target
```

が分からず、Root Causeを確定できなかった。

ProductionへDebug Hookを増やすのではなく、Test Artifact側の診断能力を上げるという考え方が重要。

---

### 5. State Transitionを利用するとFixture作成量を減らせる

P2-05 Runtimeでは、

```text
I02 New
↓
I04 Reactivated
↓
I05 Unused
↓
I06 Zero-diff
```

と、前Testの終了状態を次TestのFixtureとして再利用した。

これによりFixture変更が少なくなり、

- 操作ミス低減
- Evidenceの説明容易化
- 再現性向上

につながった。

---

### 6. Zero-diffも正常なUse Case

同期結果が、

```text
New 0
Existing 0
Reactivated 0
Unused 0
```

でもSuccessであることを明示的に確認した。

「変化なし」と「処理失敗」は別概念。

Sync / Reconciliation系処理では一般化できる考え方。

---

### 7. `Count` の意味をObject構造から確認する

Locals Windowで、

```text
syncDiffResult.Count = 4
```

と表示されても、それは差分4件ではなく、

```text
New
Existing
Reactivated
Unused
```

というDictionary Key数だった。

Debug WindowやLocalsの数値を、意味を確認せずEvidenceへ転記しないことが重要。

---

### 8. 「PASS / CLOSED」の粒度を混ぜない

今回も明確に分けた。

```text
Test Case PASS
Verification Evidence Consolidation PASS
Regression PASS
Implementation Unit COMPLETE
Phase COMPLETE
Checkpoint ESTABLISHED
```

はすべて別。

AI協働開発で特に重要なGovernance観点。

---

## 記事にできそうな切り口

### 開発日記向き

- **「Regression Testが落ちた。でもコードは直さなかった」**
  - ReadBodyText初回FAIL
  - OFTを疑う
  - Fixtureを確認
  - Boundaryを特定
  - Fresh Warmで再実行
  - Production修正なしでPASS
  - 「直さない判断」も開発判断である、という話

- **「テストを順番に並べ替えただけで検証が楽になった」**
  - I02 → I04 → I05 → I06
  - State TransitionをFixtureとして使う
  - 個人開発でもVerification Costを抑えられる

- **「AIと一緒にテストしていたら、Count=4を危うく4件と勘違いしかけた話」**
  - Dictionary Key数とCollection件数
  - Runtime Evidenceの読み方

- **「全部PASSしたのに、まだ完成じゃない」**
  - Runtime Verification完了
  - Evidence Consolidation
  - Regression
  - Static Review
  - Completion Decision
  - 小規模個人開発にあえて工程Gateを設ける理由

- **「バグかもしれない、でもまだバグとは呼ばない」**
  - Intermittent WordEditor E_FAIL
  - Observation / Finding / Production Defectの使い分け
  - 不確実性を文書化する開発

---

### 技術記事向き

- **Excel VBA + Classic OutlookでのWordEditor取得とTransient COM Failureの切り分け**
  - CreateMailFromTemplate
  - ReadSubject
  - ReadBodyText
  - Inspector.WordEditor
  - Fresh Warm条件
  - Failure Boundary

- **Sync Engineの4分類設計**
  - New
  - Existing
  - Reactivated
  - Unused
  - Already-Unused No-op
  - Zero-diff Success

- **VariableDefinition Persistence設計**
  - Status
  - TemplateLocation
  - FirstDetectedAt
  - LastDetectedAt
  - User Configuration保持
  - Common SyncTimestamp

- **Regression TestでProduction Defectを即断しない方法**
  - Failure Localization
  - Fixture Verification
  - Environment Reset
  - Controlled Rerun
  - Finding Assessment

- **Test Fixtureを状態遷移として設計する**
  - New → Reactivated → Unused → No-op
  - Fixture Churn削減

- **Test HarnessのObservability設計**
  - `COperationResult`
  - `CErrorInfo`
  - ErrorType
  - Message
  - Target
  - Production Hookを増やさない診断設計

- **Fail ClosedのIntegration Verification**
  - Invalid Candidate
  - OFT Missing
  - Fresh Retry
  - Result Carrier
  - Failure Notification / Success Notification

- **Implementation VerificationとFormal Testを分離する**
  - Candidate Build前のImplementation Evidence
  - Regression Evidence
  - P7 Formal Testとの境界

---

## 有料note / テンプレート化候補

### 1. Implementation Verification Case Template

項目例：

```text
Case ID
Objective
Initial State
Fixture Changes
User Action
Expected
Runtime Evidence
Locals Evidence
UI Evidence
Persistence Before / After
Finding Assessment
PASS / FAIL
Re-test Decision
Next Transition
```

---

### 2. Regression Failure Triage Template

今回の流れをそのまま汎用化できる。

```text
Observed Failure
↓
Failure Boundary
↓
Fixture Verification
↓
Environment / Session Verification
↓
Production Defect?
Test Artifact Defect?
Fixture Defect?
Contract Finding?
Transient Environment?
↓
Controlled Rerun
↓
Correction Decision
```

---

### 3. Evidence Strength Checklist

```text
Direct Runtime Evidence
Behavioral Evidence
Source Evidence
Persistence Evidence
UI Evidence
Fixture Evidence
```

「何を直接見たか」「何をContractから推定したか」を分離するテンプレート。

---

### 4. Finding / Observation / Defect 判断基準テンプレート

分類例：

```text
Observation
Implementation Finding
Regression Finding
Production Defect
Fixture Defect
Test Artifact Defect
Requirement Gap
Design Finding
```

それぞれ、

- いつOPENするか
- いつBlockingにするか
- いつCloseするか
- Reopen条件

を定義できる。

---

### 5. State-transition型Fixture設計テンプレート

今回の、

```text
New
→ Reactivated
→ Unused
→ Zero-diff
```

のようにTest Case同士を状態遷移で接続する設計表。

項目：

```text
Case
Initial State
Change
Expected Classification
Post State
Reusable by Next Case?
Restore Needed?
```

---

### 6. AI協働開発用Completion Boundary Checklist

```text
Unit Test PASS
≠
Regression PASS

Regression PASS
≠
Implementation Unit COMPLETE

Implementation Unit COMPLETE
≠
Phase COMPLETE

Phase COMPLETE
≠
Checkpoint ESTABLISHED

Implementation Verification
≠
Formal MVP Test
```

AIが「全部PASSしたから完成」と早合点するのを防ぐためのGovernanceテンプレートとして再利用可能。

---

### 7. VBA / Outlook Integration Diagnostic Checklist

```text
ResolvedPath
CreateMailFromTemplate
ReadSubject
ReadBodyText
Inspector
WordEditor
CloseWithoutSave

ErrorType
Message
Target

Warm / Cold / Fresh Warm
Explorer Count
Prior Diagnostic有無
```

WordEditorやCOM系の一時Failure調査用テンプレートとして有料素材化しやすい。
