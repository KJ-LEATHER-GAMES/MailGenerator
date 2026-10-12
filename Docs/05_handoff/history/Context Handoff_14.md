# 引き継ぎまとめ

## 実施内容

- 対象プロジェクト：
  - 定型メール作成ツール MVP
  - Excel VBA + Classic Outlook + OFT
- 対象Phase：
  - P2 Scan / Sync
- 対象Implementation Unit：
  - `P2-01 Full Template Scanner`

### P2-01 Production Candidate

- P1-04 Production Scannerをベースに、P2-01仕様で必要な `Locations` を追加したProduction Candidateを使用。
- Final Production：
  - `modTemplateScanner_P2-01_v0.1.1_CP932.bas`
- Public APIはP1-04から変更なし。

```vb
Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult
```

- `scanResult`を以下のFull TemplateScanResultへ拡張。

```text
scanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

- `Locations`仕様：
  - Late Bound `Scripting.Dictionary`
  - `CompareMode = vbTextCompare`
  - Key = VariableName
  - Value = `"Subject"` / `"Body"` / `"Both"`
  - Case Insensitive Identity
  - 初回検出表記を維持
  - Subject→Bodyの順でScan
  - 同一Source重複はLocation変更なし
  - Subject / Body双方に存在した場合は`Both`

---

### Core Verification C1-C11

- 作成済みTest Module：
  - `modP2_01FullTemplateScannerCoreTest_v0.1_CP932.bas`
- Entry Point：

```vb
TestP201FullTemplateScannerCore
```

- 実行結果：

```text
C1  Subject Only                              PASS
C2  Body Only                                 PASS
C3  Both                                      PASS
C4  Case Insensitive Both                     PASS
C5  Multiple Same Source                      PASS
C6  Mixed Locations                           PASS
C7  Invalid Candidates Regression             PASS
C8  Valid + Invalid Mixed                     PASS
C9  Empty Input Regression                    PASS
C10 First Detection Order Regression          PASS
C11 TemplateScanResult Structural Invariant   PASS

PASS Count: 11
FAIL Count: 0

Overall:
PASS
```

- C11で確認したStructural Invariant：
  - `Locations.Count = ValidVariables.Count`
  - ValidVariables全件にLocationsが存在
  - Locations全KeyがValidVariablesへ対応
  - Case違いによるLocation重複なし
  - Invalid CandidateがLocationsへ混入しない

---

### Baseline OFT Integration Verification

- 作成：
  - `modP2_01FullTemplateScannerIntegrationTest_v0.1_CP932.bas`
- Entry Point：

```vb
TestP201FullTemplateScannerBaselineOftIntegration
```

- 実Production経路：

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
実Baseline OFT
↓
CreateMailFromTemplate
↓
ReadSubject
↓
ReadBodyText
↓
Production ScanTemplate
↓
CloseWithoutSave
```

- Workbook：

  - `MailGeneratorNew.xlsm`

- Baseline OFT：

  - `Templates\MailTemplate.oft`

- 実行結果：

```text
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

- Subject Snapshot：

```text
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

- BodyText Length：

  - `252`

- このVerificationにより、

  - 実OFT
  - Outlook Adapter
  - Subject / BodyText Snapshot
  - WordEditor経由BodyText
  - Production `ScanTemplate`
  - `Locations`\
    のProduction Architecture経路が成立した。

---

### MTS-SCAN-005相当 Recipient Exclusion Integration

- 専用OFT Variantを作成：
  - `Templates\MailTemplate_MTS-SCAN-005.oft`
- Fixture Intent：

```text
Subject:
{{ModelName}}

Body:
{{Department}}

To:
{{RecipientTo}}

CC:
{{RecipientCc}}

BCC:
{{RecipientBcc}}
```

- Settingsシートの`TemplatePath`は変更しない方針とした。

- Test Artifact内で専用Fixture Pathを直接指定。

- 作成：

  - `modP2_01MtsScan005IntegrationTest_v0.1_CP932.bas`

- Entry Point：

```vb
TestP201MtsScan005RecipientExclusionIntegration
```

- 初版Test ArtifactではPath Literalが、

```text
Templates\\MailTemplate_MTS-SCAN-005.oft
```

となっていた。

- これはVBAでは`\`をescapeする必要がないためTest Artifact側の誤りと判定。
- 修正後：

```vb
Private Const TEST_TEMPLATE_PATH As String = _
    "Templates\MailTemplate_MTS-SCAN-005.oft"
```

- 修正後に再実行。

- Final Evidence：

```text
ResolveWorkbookRelativePath:
PASS

ResolvedPath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate_MTS-SCAN-005.oft

CreateMailFromTemplate:
PASS

ReadSubject:
PASS

Subject Snapshot:
【{{ModelName}}】ゲート審査

ReadBodyText:
PASS

BodyText Length:
20

Fixture Subject Precondition:
PASS

Fixture Body Precondition:
PASS

ScanTemplate:
PASS

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

Locations CompareMode:
PASS

TemplateScanResult Structural Invariant:
PASS

CloseWithoutSave:
PASS

Overall:
PASS
```

- P2-01 Unit Verificationとして以下を成立確認。

```text
Subject / Body
→ Scan対象

To / CC / BCC
→ Scan対象外
```

- Recipient値自体をProduction APIから読み返すTest専用APIは追加していない。
- To / CC / BCC内容はTest Fixture作成時のPreconditionとして扱った。

---

### TF-P2-01-001

- Finding ID：
  - `TF-P2-01-001`
- 内容：
  - MTS-SCAN-005 Test Path Duplicate Separator
- Classification：

```text
Test Artifact Defect
/
Path Literal Issue
```

- Root Cause：
  - VBA String Literal内でBackslash Escapeが不要なのに、Test Artifact生成時に`\\`を記述した。
- Correction：

```vb
Private Const TEST_TEMPLATE_PATH As String = _
    "Templates\MailTemplate_MTS-SCAN-005.oft"
```

- Production変更：
  - NONE
- Re-verification：
  - PASS
- Final Status：

```text
RESOLVED / CLOSED
```

---

### Finding Assessment

- 初版：

  - `P2-01 Full Template Scanner Finding Assessment v0.1.md`

- 再Verification反映後：

  - `P2-01 Full Template Scanner Finding Assessment v0.1.1.md`

- Final Result：

```text
Implementation Defect:
NONE

Test Artifact Defect:
TF-P2-01-001
→ RESOLVED / CLOSED

Requirement Gap:
NONE

Design Finding:
NONE

Technical Finding:
NONE

Regression Finding:
NONE

Active Finding:
NONE

Blocking Finding:
0

Baseline Change:
NOT REQUIRED

Technical Spike Reopen:
NOT REQUIRED

RESULT:
PASS
```

---

### P1-04 Regression Assessment

P2-01で`modTemplateScanner`を変更したため、P1-04主要ContractのRegressionを確認。

対応：

| P1-04 Regression Target      | P2-01 Evidence                | Result |
| ---------------------------- | ----------------------------- | ------ |
| Baseline Happy Path          | C6 + Baseline OFT Integration | PASS   |
| Case Insensitive Integration | C4 / C5                       | PASS   |
| Invalid Candidate Detection  | C7 / C8                       | PASS   |
| Empty Input                  | C9                            | PASS   |
| OFT Integration              | Baseline OFT Integration      | PASS   |

維持確認：

```text
ValidVariables Contract
InvalidCandidates Contract
Case Insensitive Dedup
初回検出順
初回検出表記
Scanner Technical Success / Invalid分離
```

Result：

```text
P1-04 Core Regression:
PASS

P1-04 OFT Integration Regression:
PASS

Regression Finding:
NONE
```

---

### Production Patch Review

- 作成：

  - `P2-01 Full Template Scanner Production Patch Review v0.1.md`

- Review対象：

  - Base Production：
    - P1-04 `modTemplateScanner.bas`
  - Candidate：
    - `modTemplateScanner_P2-01_v0.1.1_CP932.bas`

- 確認内容：

  - Public API維持
  - P1-04 Contract維持
  - `Locations`追加
  - `Subject / Body / Both` merge
  - `vbTextCompare`
  - Structural Invariant
  - Error Handling維持
  - ScannerのCOM非依存
  - Excel Data Access非依存
  - VariableDefinition非依存
  - Recipient非依存
  - YAGNI
  - Production Variable Hard Codingなし

- Final Result：

```text
Static Review:
PASS

Production Diff Review:
PASS

Public API Preservation:
PASS

ValidVariables Contract:
PASS

InvalidCandidates Contract:
PASS

Locations Implementation:
PASS

TemplateScanResult Structural Invariant:
PASS

Error Handling Preservation:
PASS

Core Logic Boundary:
PASS

Recipient Exclusion Boundary:
PASS

P1-04 Core Regression:
PASS

P1-04 OFT Integration Regression:
PASS

Baseline OFT Integration:
PASS

MTS-SCAN-005 Equivalent Integration:
PASS

VBA Compile:
PASS

Finding Assessment:
PASS

Production Defect:
NONE

Production Change Required After Review:
NONE

Blocking Finding:
0

RESULT:
PASS
```

- Production Candidate：

```text
modTemplateScanner_P2-01_v0.1.1_CP932.bas
```

- Decision：

```text
ACCEPTED FOR P2-01 COMPLETION
```

---

### Completion Record

- 作成：

  - `P2-01 Full Template Scanner Completion Record v0.1.md`

- Approved Completion Criteriaを最終確認。

```text
Approved Unit Specification               PASS
VBA Compile                               PASS
modTemplateScanner Production Patch        PASS

Full TemplateScanResult                   PASS
ValidVariables                            PASS
InvalidCandidates                         PASS
Locations                                 PASS
TemplateScanResult Structural Invariant   PASS

Subject Location                          PASS
Body Location                             PASS
Both Location                             PASS
Case Insensitive Location Merge           PASS

P1-04 Regression                          PASS
Baseline OFT Integration                  PASS
Production Patch Review                   PASS
Finding Assessment                        PASS

Blocking Finding = 0                      PASS
```

- Completion Criteria：

```text
ALL PASS
```

- 最終判定：

```text
P2-01 Full Template Scanner
PASS / COMPLETE
```

---

## 決定事項

- `P2-01 Full Template Scanner`は正式に：

```text
PASS / COMPLETE
```

- Final Production：

```text
modTemplateScanner_P2-01_v0.1.1_CP932.bas
```

- `ScanTemplate` Public APIはP1-04から変更しない。

```vb
ScanTemplate(subjectText, bodyText, scanResult)
As COperationResult
```

- Full `TemplateScanResult`は以下とする。

```text
ValidVariables
InvalidCandidates
Locations
```

- `Locations`は：
  - Late Bound `Scripting.Dictionary`
  - `CompareMode = vbTextCompare`
  - `"Subject"` / `"Body"` / `"Both"`
- Case違いは同一Variableとして扱う。
- 初回検出表記を維持する。
- Subject→Bodyの順でScanする。
- 同一Source内重複ではLocationを変更しない。
- Subject / Body双方に存在した場合は`Both`。
- Invalid Candidateは`Locations`へ追加しない。
- To / CC / BCCはScanner対象外。
- Scanner Public APIにRecipient情報を追加しない。
- ScannerへOutlook / Word COM Objectを渡さない。
- ScannerへExcel Data Access / VariableDefinition / Sync責務を持ち込まない。
- `MTS-SCAN-005`相当Verification用OFT：
  - `Templates\MailTemplate_MTS-SCAN-005.oft`
- Settingsの`TemplatePath`は専用Test Fixtureのために変更しない。
- Test Fixture PathはTest Artifact内で直接指定する。
- `TF-P2-01-001`は：
  - Test Artifact Defect
  - Correction済み
  - Re-verification PASS
  - `RESOLVED / CLOSED`
- P1-04 RegressionはPASS。
- Finding Assessment v0.1.1はPASS。
- Production Patch Review v0.1はPASS。
- Production追加修正は不要。
- Active Finding = 0。
- Blocking Finding = 0。
- Requirement Gap = NONE。
- Design Finding = NONE。
- Technical Finding = NONE。
- Technical Spike Reopen = NOT REQUIRED。
- Baseline Change = NOT REQUIRED。
- Current Approved Baselineは`BL-MVP-003`を維持する。
- P2-01 Completionだけを理由に新Baselineは作成しない。
- 現在のVerificationはImplementation VerificationでありFormal MVP Testではない。
- `MTS-SCAN-003`についてP2-01で成立したのはScanner Core Portionまで。
- Existing VariableDefinitionの正式表記をCanonicalとして保持する責務はP2-02へ残す。
- P2-01 COMPLETEは`P2 Phase Complete`や`CP-P2 Established`を意味しない。

---

## 未解決事項

### P2-02 Sync Diff Core

- 未着手。
- 次Implementation Unit。

主な対象：

```text
Current TemplateScanResult
+
Current VariableDefinition
↓
Sync Diff Classification
```

想定Classification：

```text
New
Existing
Reactivated
Unused
```

Rename：

```text
Rename推測しない
=
Old Unused + New
```

### Canonical VariableName

P2-01では、

```text
Scanner初回検出表記
```

を維持する。

未実装：

```text
Existing VariableDefinitionが存在する場合
→ VariableDefinition側の正式表記をCanonicalとして保持
```

これはP2-02責務。

### Sync Metadata

未実装：

```text
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
SyncTimestamp
```

P2-02 / P2-03で責務分担を維持する必要あり。

### VariableDefinition Persistence

未実装。

予定：

```text
P2-03 VariableDefinition Sync Persistence
```

- Excel Table更新
- New追加
- Status変更
- Metadata更新
- Existingユーザー設定維持

### Manual Sync Integration

未実装。

予定：

```text
P2-04 Manual Sync Integration
```

### Fail Closed / Sync Result / Phase Integration

未実装。

予定：

```text
P2-05 Fail Closed / Sync Result / Phase Integration
```

### CP-P2

未成立。

```text
CP-P2:
NOT YET ESTABLISHED
```

P2-02～P2-05およびP2 Phase Verification完了後に判定する。

### Formal MVP Test

未実施。

現時点では、

```text
Implementation Verification
Regression Evidence
Unit Completion Evidence
```

のみ。

Formal TestはP7後のTest Candidate Buildに対して実施する。

---

## 次アクション

### 優先度1：P2-02 Sync Diff Core開始

次チャットでは、いきなりProduction Codingせず、まずP2-02の責務境界と実施仕様を整理する。

最初に見るもの：

1. `P2-01 Full Template Scanner Completion Record v0.1.md`

   - P2-01で成立したTemplateScanResult Contract確認

2. `MVP Design v0.1.9 日本語版.md`

   - §14 Template Scanner
   - §15 Sync Engine
   - §25.1 Manual Sync

3. `MVP Requirements v0.1.9 日本語版.md`

   - FR-SYNC群
   - FR-VAR-003 / 004 / 005
   - Metadata関連Requirement

4. `MVP Test Specification v0.1.5 日本語版.md`

   - MTS-SCAN-003
   - MTS-SYNC-001～012

5. `Implementation Plan v0.3 日本語版(2).md`

   - P2 Scan / Sync
   - Sync Engine
   - Phase Verification
   - Exit Criteria

6. `P2 Implementation Unit Decomposition Decision`

   - P2-02 / P2-03 / P2-04 / P2-05の責務分割確認

### 優先度2：P2-02 Input / Output Contract確定

確認すべきInput：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations

Current VariableDefinitions
└─ Collection of Dictionary
```

確認すべきOutput候補：

```text
New
Existing
Reactivated
Unused
```

要確認：

- Output Carrier形式
- Collection / Dictionary構造
- Existing VariableDefinitionのCanonical spelling保持
- Current Locationの引継ぎ
- Rename非推測
- SyncTimestampをP2-02が持つかP2-03が持つか
- Metadata更新値をPure Coreが計算する範囲

### 優先度3：P2-02 実施仕様作成

推奨フロー：

```text
P2-02 Boundary Confirmation
↓
P2-02 Sync Diff Core 実施仕様 v0.1
↓
Cross-document Consistency Review
↓
Approved
↓
Production Implementation
↓
Compile
↓
Core Verification
↓
Integration / Regression
↓
Finding Assessment
↓
Production Patch Review
↓
Completion Record
```

### 次チャット開始時の短縮状態

```text
Project:
定型メール作成ツール MVP

Current Approved Baseline:
BL-MVP-003

P0:
PASS / COMPLETE
CP-P0:
ESTABLISHED

P1:
PASS / COMPLETE
CP-P1:
ESTABLISHED

P2 Scan / Sync:
IN PROGRESS

P2-01 Full Template Scanner:
PASS / COMPLETE

Final P2-01 Production:
modTemplateScanner_P2-01_v0.1.1_CP932.bas

P2-01 Result:
ValidVariables
InvalidCandidates
Locations

Locations:
Subject / Body / Both
Case Insensitive

P2-01 Core:
C1-C11 = 11/11 PASS

Baseline OFT Integration:
PASS

MTS-SCAN-005 Equivalent:
PASS

P1-04 Regression:
PASS

TF-P2-01-001:
Test Artifact Path Literal
→ corrected
→ re-verified
→ RESOLVED / CLOSED

Finding Assessment:
PASS

Production Patch Review:
PASS

Blocking Finding:
0

Formal MVP Test:
NOT EXECUTED

Next Unit:
P2-02 Sync Diff Core

Next Action:
P2-02 Boundary Confirmation / Unit Specification
```

# 記事用素材

## 気づき

- P1で「変数を検出できる」だけだったScannerを、P2で`TemplateScanResult`として完成させる場合、単純にFieldを1つ追加するだけでもRegression観点が必要だった。
- `Locations`は単なる付帯情報ではなく、
  - Variable Identity
  - Case Insensitive
  - First Detection Casing
  - Subject / Body merge\
    と密接に関係する。
- `ValidVariables`と`Locations`を別々に実装すると不整合が起きやすいため、Structural InvariantをTest Contractとして持つ価値が高い。
- 「結果が4件だった」だけでは不十分で、
  - `Locations.Count = ValidVariables.Count`
  - Orphan Locationなし
  - Missing Locationなし
  - Invalid Candidate混入なし\
    を確認するとResult Carrier全体の健全性を検証できる。
- Synthetic Core Testだけでなく、
  - 実OFT
  - Outlook Adapter
  - WordEditor
  - Subject / BodyText Snapshot
  - Production Scanner\
    を通すIntegration Verificationを追加することで、Production Architecture上の成立性を確認できた。
- To / CC / BCC対象外の仕様は、Scanner APIがSubject / BodyTextしか受け取らないという「構造的な除外」でも表現できる。
- ただし仕様上Integration Evidenceまで求める場合、専用OFT Variantを用意することで実経路確認も可能。
- TestのためだけにProductionへRecipient読取APIを追加しない判断はYAGNIと責務分離の両方で有効だった。
- Test Fixtureを切り替えるためにProduction Settingsを書き換えない方が安全。
- 専用Test Fixture PathはTest Artifact側で持たせることで、
  - Settings戻し忘れ
  - Baseline Drift
  - Test終了後のProduction設定汚染\
    を避けられる。
- Test ArtifactにもDefectは起こる。
- `Templates\\...`は今回Productionでは処理できたが、VBA String Literalとしては不適切だった。
- Productionを先に直さず、
  - Production
  - Test Artifact
  - Fixture
  - Environment\
    を分類してからCorrectionする運用が有効だった。
- Test Artifact修正後も同じIntegration Testを再実行し、Evidenceを更新したことでFindingを正式にCloseできた。
- 「PASSしたから終わり」ではなく、
  - Finding Assessment
  - Production Patch Review
  - Completion Record\
    を分けると、実装完了判定の根拠が追跡しやすい。
- Formal TestとImplementation Verificationを分離しておくことで、途中のSmoke / Integration PASSを正式Test Resultと誤認しにくい。
- Unit CompletionとPhase Completionを分離することも重要。
- P2-01 COMPLETEでも`CP-P2`は成立していない。

---

## 記事にできそうな切り口

### 開発日記向き

- 「ScannerにLocationsを1個追加するだけのはずが、11ケースのVerificationになった話」
- 「テストコードのバックスラッシュ1個からFinding Assessmentまでやった個人開発」
- 「PASSしたテストをもう一度やり直した理由」
- 「Productionを直す前にTest Artifactを疑う」
- 「AIと開発するとき、勝手に直させないためのFinding運用」
- 「Baseline OFTを壊さず専用Test Fixtureを作る」
- 「実装より文書が多くなりすぎないためのYAGNI運用」
- 「1つのVBAマクロ開発にCompletion Recordまで作る意味」
- 「個人開発でもUnit CompletionとPhase Completionを分けてみた」
- 「Outlook VBAでTest Fixtureを切り替えるためにSettingsを書き換えなかった理由」

### 技術記事向き

- 「VBA + Scripting.DictionaryでCase InsensitiveなTemplateScanResultを設計する」
- 「Subject / Body / Bothを安全にMergeするLocation Algorithm」
- 「ValidVariablesとLocationsのStructural Invariant設計」
- 「VBA Template Scannerの2段階Regex設計」
  - Candidate Scan
  - VariableName Validation
- 「Case Insensitive IdentityとFirst Detection Casingの両立」
- 「実OFT → Outlook Adapter → WordEditor → Core LogicのIntegration Test設計」
- 「To / CC / BCCをAPI設計で構造的にScan対象外にする」
- 「Test専用Production APIを追加しないIntegration Verification」
- 「Regression Testを旧Harness再実行ではなくContract Mappingで評価する方法」
- 「Test Artifact DefectとProduction Defectの切り分け」
- 「Finding Assessment → Patch Review → Completion Recordという実装完了Gate」
- 「Formal TestとImplementation Verificationの責務分離」
- 「VBAでBackslashをEscapeしない：Python生成コードとの境界で起きたミス」
- 「Late Bound Dictionaryを使うVBA Core LogicのError Handling」

---

## 有料note / テンプレート化候補

- `Implementation Unit Completion Checklist`
  - Approved Specification
  - Compile
  - Core Verification
  - Integration
  - Regression
  - Finding Assessment
  - Production Patch Review
  - Blocking Finding = 0
  - Completion Record
- `Finding Assessment Template`
  - Classification
  - Symptom
  - Root Cause
  - Impact
  - Correction
  - Re-verification
  - Blocking判定
  - Status
- `Production Patch Review Template`
  - Public API Preservation
  - Existing Contract Preservation
  - New Contract Review
  - Error Handling
  - Dependency Boundary
  - Regression
  - Hard Coding
  - YAGNI
  - Production Change Required
- `Test Artifact Defect切り分けチェックリスト`
  - Fixture
  - Encoding
  - Path Literal
  - Expected Count
  - Actual Snapshot
  - Production Route
  - Cleanup
- `Structural Invariant Test Template`
  - Primary Collection
  - Metadata Dictionary
  - Count一致
  - Missing Key
  - Orphan Key
  - Duplicate Identity
  - Invalid Mixing
- `VBA Integration Test Harness Template`
  - Resolve Path
  - Create Resource
  - Read Snapshot
  - Call Core
  - Validate Result
  - Cleanup
- `専用Test Fixture運用ルール`
  - Baseline Fixtureは変更しない
  - Production Settingsは変更しない
  - Variant PathはTest側で指定
  - Fixture Intentを明示
  - Cleanup必須
- `AI協働開発向け「勝手に直さない」プロンプト`
  - FAILを見つけてもProductionを先に修正しない
  - Finding分類を先に行う
  - Requirement / Design / Test Artifact / Fixtureを切り分ける
  - Correction後は同一Evidenceで再Verification
- `Unit Completion Record Template`
- `Regression Mapping Template`
  - Old Contract
  - New Evidence
  - Coverage Mapping
  - PASS / GAP
- `Formal TestとImplementation Verificationを分離する運用テンプレート`
