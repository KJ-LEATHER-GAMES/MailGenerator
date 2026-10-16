# 引き継ぎまとめ

## 実施内容

### 1. P2-04 Approved Specificationの正式状態を再確認

- `P2-04 Manual Sync Integration 実施仕様 v0.1 — Candidate`だけを見ると、当初Public APIは以下だった。
  ```vb
  Public Function ExecuteManualSync( _
      ByRef syncDiffResult As Object _
  ) As COperationResult
  ```
- `P2-04 Manual Sync Integration 実施仕様 v0.1 Cross-document Consistency Review.md`を確認し、Chapter 10の`CR-P2-04-003`でPublic APIが正式補正されていたことを確認した。
  ```vb
  Public Function ExecuteManualSync( _
      ByRef syncDiffResult As Object, _
      ByRef templateScanResult As Object _
  ) As COperationResult
  ```
- Correction理由は、Invalid Candidate検出時に`TemplateScanResult("InvalidCandidates")`をP2-05へ引き渡す経路がCandidate APIになかったため。
- Cross-document Review結果は以下。
  - `PASS WITH CORRECTION`
  - `CR-P2-04-003 = APPLIED`
  - `Residual Conflict = 0`
  - `Blocking Finding = 0`
  - `P2-04 Implementation Specification v0.1 = APPROVED`
- このCross-document Reviewが、Candidate → Approvedへの正式なCorrection / Approval記録として利用可能であることを確定した。

---

### 2. Static ReviewのS01-S25が2種類あることを整理

以下の2種類が存在することを確認した。

#### Approved Specification Static Review

- Candidate時点ではS01-S22。
- `CR-P2-04-003`適用時に以下のS23-S25を追加。
  - S23：Invalid Candidate Failure時に`TemplateScanResult`保持
  - S24：Invalid Candidate一覧をError Message文字列だけへ変換しない
  - S25：P2-05が再Scanせず`InvalidCandidates`取得可能
- Correction後は正式に`S01-S25`。

#### Production Patch Static Review

`P2-04 Manual Sync Integration Production Patch Design v0.1.md`に別のS01-S25が存在。

代表例：

- S01：`modSyncApplication`追加のみ
- S02：Public API = `ExecuteManualSync` 1本
- S05：`Now`取得 = 1箇所
- S14：Invalid時`templateScanResult`保持
- S23：Module-level Sync Stateなし
- S24：New Result Classなし
- S25：Test-only Public APIなし

同じ「S01-S25」という名称だが、番号と意味が一致しないことを確認した。

---

### 3. 統合Static Reviewを作成

作成：

```text
P2-04 Manual Sync Integration 統合Static Review v0.1
```

識別子を以下に分離した。

```text
SPEC-Sxx
= Approved Specification Static Review

PATCH-Sxx
= Production Patch Static Review

ISR-xx
= Integrated Static Review Control
```

2種類のS01-S25、計50項目を意味単位で整理し、29個の統合Controlへマッピングした。

```text
ISR-01 ～ ISR-29
```

目的は、Production Sourceを二重レビューせず、一つのEvidenceから両正式ChecklistへTraceできるようにすること。

---

### 4. `modSyncApplication_P2-04_v0.1_CP932.bas` Static Review

Production Source：

```text
modSyncApplication_P2-04_v0.1_CP932.bas
```

をISR-01～ISR-29へ照合した。

Source上で確認した主要事項：

```text
Public Procedure:
ExecuteManualSync 1本

Automatic Sync Event:
NONE

MsgBox / UserForm:
NONE

DisplayMail:
NONE

Now:
1箇所

ScanTemplate:
PRESENT

GetAllVariableDefinitions:
PRESENT

BuildSyncDiff:
PRESENT

ApplySyncDiff:
PRESENT

Classification Recalculation:
NONE

Canonical Name Recalculation:
NONE

Metadata Recalculation:
NONE

Excel ListObject Direct Access:
NONE

Outlook / Word COM Direct Access:
NONE

Automatic Retry:
NONE

Module-level Mutable Sync State:
NONE

New Result Class:
NONE

Test-only Public API:
NONE
```

またFlowは、

```text
Current Template Scan
↓
templateScanResult Publish
↓
Invalid Candidate Guard
↓
Current VariableDefinitions
↓
SyncTimestamp = Now
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
syncDiffResult Publish
```

となっており、Approved Contractと整合していることを確認した。

---

### 5. ISR-01についてProduction変更実績を再整理

当初、ISR-01：

```text
Production変更は
modSyncApplication追加範囲に限定
```

についてEvidence不足と判断した。

その後、P2-04中に実際には以下2Production ModuleもCorrectionしていたことを再確認した。

```text
modSyncEngine
modVariableDefinitionData
```

したがって単純な「ADD only」ではなかった。

Final Production Change：

```text
ADD:
modSyncApplication

MODIFY:
modSyncEngine
modVariableDefinitionData

DELETE:
NONE
```

これを無管理なScope Expansionではなく、`IF-P2-04-001`に基づく**Controlled Integration Correction**として整理した。

---

### 6. P2-02 Sync Diff Core Correctionを正式整理

Original：

```text
modSyncEngine_P2-02_v0.1_CP932.bas
```

Correction：

```text
modSyncEngine_P2-02_v0.1.1_CP932.bas
```

主なCorrection：

- Existing Bootstrap
  - `FirstDetectedAt = SyncTimestamp`
- Reactivated Bootstrap
  - `FirstDetectedAt = SyncTimestamp`
- Unused Bootstrap
  - Empty Metadata保持
- Partial Metadata
  - Failure
- `CreateDiffItem.templateLocation`
  - `String` → `Variant`
  - Empty保持対応

Public API：

```vb
BuildSyncDiff(
    templateScanResult,
    currentDefinitions,
    syncTimestamp,
    syncDiffResult
)
```

は変更していない。

Bootstrap Regression：

```text
33 / 33 PASS
```

既存Core：

```text
18 / 18 PASS
```

Technical Negative：

```text
6 / 6 PASS
```

---

### 7. P2-03 VariableDefinition Sync Persistence Correctionを正式整理

Original：

```text
modVariableDefinitionData_P2-03_v0.1.bas
```

Correction：

```text
modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas
```

変更対象は以下2Procedureのみ。

```text
ValidateDiffItem
WriteExistingMetadata
```

Correction内容：

- Bootstrap Unusedでは
  - `TemplateLocation`
  - `FirstDetectedAt`
  - `LastDetectedAt`\
    を全Emptyで許可
- Partial MetadataはFailure
- Empty Metadata Persistence時は`ClearContents`
- Non-emptyは従来どおりDate Persistence
- P2-03自身はMetadata Target Stateを生成せず、
  ```text
  P2-02 Target State
  ↓
  Validate
  ↓
  Persist
  ```
  の責務を維持

---

### 8. P2-03 Source生成時Artifact Defectを整理

最初に生成したCorrection Sourceで、

```vb
rowIndex = CLng(rowMap(variableName))rowIndex = CLng(rowMap(variableName))
```

という構文エラーが発生。

原因：

```text
Source復元時に
1～1000行
+
1000行目～末尾
を連結
↓
境界行重複
```

Classification：

```text
Production Logic Defect:
NONE

Correction Design Defect:
NONE

Artifact Generation Defect:
YES
```

修正版：

```text
modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas
```

Original Sourceと全文比較し、意図した差分が、

```text
ValidateDiffItem
WriteExistingMetadata
```

のみであることを確認。

Artifact Generation Defect：

```text
RESOLVED / CLOSED
```

---

### 9. P2-03 Regression / Compatibilityを整理

Regression：

```text
Bootstrap:
7 / 7 PASS

Core:
12 / 12 PASS

Technical Negative:
18 / 18 PASS
```

Compatibility：

```text
K1 P2-02 -> P2-03
PASS

K2 VariableDefinition Read Regression
PASS

K3 P2-02 Contract / No-Reopen
PASS

3 / 3 PASS
```

K1 FixtureはInitialized Metadata中心だったため、Initial Sync Bootstrap Pipelineの直接Evidenceとしては不足と判断。

後続でBootstrap Production Compatibilityを追加確認。

---

### 10. Production Change Scope Correctionを正式記録

作成：

```text
P2-04 Production Change Scope Correction Record v0.1
```

記録内容：

```text
Original Patch Design:
ADD modSyncApplication only

Actual:
ADD modSyncApplication
MODIFY modSyncEngine
MODIFY modVariableDefinitionData
```

Classification：

```text
Production Defect:
NONE

Uncontrolled Scope Expansion:
NONE

Controlled Integration Correction:
YES
```

`IF-P2-04-001`：

```text
RESOLVED / CLOSED
```

とした。

---

### 11. 統合Static Reviewを正式Close

`ISR-01`を、

```text
PASS WITH CONTROLLED CORRECTION
```

へ更新。

最終結果：

```text
ISR-01:
PASS WITH CONTROLLED CORRECTION

ISR-02-ISR-29:
28 / 28 PASS

FAIL:
0

NOT REVIEWED:
0

Blocking Finding:
0

RESULT:
PASS / CLOSED
```

現在の正式な統合Static Reviewは`PASS / CLOSED`。

---

### 12. Regression Evidence Finalization

作成：

```text
P2-04 Manual Sync Integration
Regression Evidence Finalization v0.1
```

最終Evidence：

```text
P2-01 Regression:
PASS

P2-02 Regression:
111 / 111 PASS

P2-03 Regression:
46 / 46 PASS

Bootstrap Production Compatibility:
29 / 29 PASS

I12 Contract Regression:
PASS

VBA Compile:
PASS
```

I12では一度Immediate WindowのEvidence欠落が発生したが、

```text
Evidence Incomplete
```

として扱い、該当Testを再実行して補完した。

最終：

```text
Regression Evidence:
PASS / FINALIZED
```

---

### 13. Production Patch Reviewを作成・PASS

作成：

```text
P2-04 Manual Sync Integration
Production Patch Review v0.1
```

Review対象：

- Approved Specification
- Production Source
- I01-I12
- Integrated Static Review
- P2-01 / P2-02 / P2-03 Regression
- Bootstrap Production Compatibility
- `CR-P2-04-003`
- `IF-P2-04-001`

最終結果：

```text
Production Defect:
NONE

Regression Finding:
NONE

Contract Conflict:
NONE

Requirement Gap:
NONE

Design Conflict:
NONE

Static Review Finding:
NONE

Active Finding:
0

Blocking Finding:
0

Production Correction Required:
NONE

RESULT:
PASS
```

---

### 14. Final Finding Assessmentを作成・PASS

作成：

```text
P2-04 Manual Sync Integration
Final Finding Assessment v0.1
```

最終統合したFinding：

- `CR-P2-04-003`
- `IF-P2-04-001`
- I05 Test Artifact Defect
- P2-03 Artifact Generation Defect
- I12 Evidence Incomplete
- Static Review Controlled Deviation

最終状態：

```text
Production Defect:
NONE

Implementation Defect:
NONE ACTIVE

Test Artifact Defect:
NONE ACTIVE

Artifact Generation Defect:
NONE ACTIVE

Evidence Incomplete:
NONE ACTIVE

Requirement Gap:
NONE

Design Gap:
NONE

Specification Conflict:
NONE

Contract Conflict:
NONE

Regression Finding:
NONE

Static Review Finding:
NONE

Active Finding:
0

Blocking Finding:
0
```

Result：

```text
PASS
```

---

### 15. Completion Criteria Final Checkを実施

作成：

```text
P2-04 Manual Sync Integration
Completion Criteria Final Check v0.1
```

Approved SpecificationのCompletion Criteriaを最終照合した。

Candidate時点のCompletion Criteriaには、

```text
Static Review S01-S22
```

とあったが、Cross-document Correction後のApproved Static ReviewはS01-S25であるため、補正後契約をSource of Truthとして確認した。

Completion Criteria：

```text
Boundary Confirmation
PASS

Cross-document Consistency Check
PASS

Implementation Specification
APPROVED

Current Production Source Review
COMPLETE

Production Patch Design
APPROVED

VBA Compile
PASS

Production Implementation
PASS

Integration Verification I01-I12
12 / 12 PASS

Static Review
PASS / CLOSED

P2-01 Regression
PASS

P2-02 Regression
PASS

P2-03 Regression
PASS

Production Patch Review
PASS

Final Finding Assessment
PASS

Blocking Finding
0
```

最終：

```text
15 / 15 PASS
```

---

### 16. Production Patch DesignのApprovalをGovernance上補完

確認の結果、

```text
P2-04 Manual Sync Integration
Production Patch Design v0.1
```

本体のStatusは、

```text
Production Patch Design
```

であり、明示的な`APPROVED`表記がなかった。

一方、Approved Specification Completion Criteriaでは、

```text
Production Patch Design
APPROVED
```

が必要。

このためCompletion Criteria Final Check内で、

```text
Production Patch Design v0.1

STATUS:
APPROVED AS IMPLEMENTED
```

を正式記録した。

根拠：

- Production Implementation PASS
- I01-I12 PASS
- Static Review PASS / CLOSED
- Regression PASS / FINALIZED
- Production Patch Review PASS
- Final Finding Assessment PASS
- Active / Blocking Finding 0

Original Patch Design自体は履歴として書き換えない方針とした。

---

### 17. P2-04 Completion Recordを作成

作成：

```text
P2-04 Manual Sync Integration
Completion Record v0.1
```

Final Result：

```text
P2-04 Manual Sync Integration

PASS / COMPLETE
```

Completion Scope：

```text
Manual Sync Application Entry
Current Template Scan
Invalid Candidate Guard
Current Definition Retrieval
Single SyncTimestamp
BuildSyncDiff
ApplySyncDiff
TemplateScanResult Handoff
Successful SyncDiffResult Handoff
Failure Propagation
Fresh State Retry Boundary
```

---

### 18. P2-04正式Close後のProject Control

```text
P2-01 Full Template Scanner
COMPLETE

P2-02 Sync Diff Core
COMPLETE

P2-03 VariableDefinition Sync Persistence
COMPLETE

P2-04 Manual Sync Integration
PASS / COMPLETE

P2-05 Fail Closed / Sync Result / Phase Integration
NEXT

P2 Phase
IN PROGRESS

CP-P2
NOT ESTABLISHED
```

P2-04 CompletionはP2 Phase CompletionやCP-P2成立を意味しない。

---

## 決定事項

- P2-04 Implementation Specification v0.1は、Cross-document Consistency Reviewで`CR-P2-04-003`適用後に正式`APPROVED`となった。
- Approved Public APIは以下で確定。
  ```vb
  ExecuteManualSync(
      syncDiffResult,
      templateScanResult
  ) As COperationResult
  ```
- Invalid Candidate時は、
  ```text
  Failure
  +
  templateScanResult保持
  +
  InvalidCandidates保持
  +
  syncDiffResult = Nothing
  ```
  とする。
- Approved Specification Static ReviewはS01-S25。
- Production Patch Static Reviewにも別のS01-S25が存在する。
- 両者は別Checklistとして扱い、`SPEC-Sxx` / `PATCH-Sxx`で区別する。
- 両Checklistを29個の`ISR-xx`へ統合する方式を採用した。
- `modSyncApplication` Production SourceはApproved Contractに整合。
- P2-04中のP2-02/P2-03 Production変更は、無管理なScope Expansionではなく`IF-P2-04-001`によるControlled Integration Correctionとして扱う。
- `ISR-01` / `PATCH-S01`は`PASS WITH CONTROLLED CORRECTION`。
- Integrated Static Reviewは`PASS / CLOSED`。
- P2-02 Public `BuildSyncDiff` Contractは変更しない。
- P2-03 Public `ApplySyncDiff` Contractは変更しない。
- P2-02/P2-03の元Completion Recordは履歴として書き換えない。
- Correction履歴はP2-04側の正式RecordからTraceする。
- Original Production Patch Designは後から内容を書き換えず、設計時点の履歴を維持する。
- Production Patch DesignのApprovalはCompletion Criteria Final Checkで`APPROVED AS IMPLEMENTED`として正式記録する。
- Evidence欠落はTest FAILとは区別し、`Evidence Incomplete`として再実行・補完する。
- Formal MVP TestとImplementation Verificationは明確に分離する。
- Baselineは`BL-MVP-003`を維持する。
- `BL-MVP-004`はP2-04 Completionだけを理由に作成しない。
- P2-04 Manual Sync Integrationは正式に、
  ```text
  PASS / COMPLETE
  ```
  とする。
- P2 Phaseはまだ`IN PROGRESS`。
- `CP-P2`はまだ`NOT ESTABLISHED`。
- 次のImplementation Unitは、
  ```text
  P2-05 Fail Closed / Sync Result / Phase Integration
  ```
  とする。

---

## 未解決事項

### P2-04

技術的な未解決事項：

```text
NONE
```

Active Finding：

```text
0
```

Blocking Finding：

```text
0
```

ただし以下は要確認。

- この会話で作成した以下の最新正式RecordがProject Files / Libraryへ永続保存済みかは要確認。
  - `P2-04 Production Change Scope Correction Record v0.1`
  - `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1`
  - `P2-04 Manual Sync Integration Production Patch Review v0.1`
  - `P2-04 Manual Sync Integration Final Finding Assessment v0.1`
  - `P2-04 Manual Sync Integration Completion Criteria Final Check v0.1`
  - `P2-04 Manual Sync Integration Completion Record v0.1`
- `P2-04 Manual Sync Integration 統合Static Review v0.1`は保存・編集済みで、Final Resultは`PASS / CLOSED`。
- Production Patch Design本体のStatus欄は元の`Production Patch Design`のまま。正式ApprovalはCompletion Criteria Final Check側で`APPROVED AS IMPLEMENTED`として記録した。元文書をRevision Upするかは現時点で必要性なし。

### P2全体

未完了：

```text
P2-05 Fail Closed / Sync Result / Phase Integration
P2 Phase Verification
CP-P2 Establishment
```

未実施：

```text
Formal MVP Test
MVP Product PASS判定
```

Formal MVP TestはP7後のTest Candidate Buildに対して実施するため、現時点では実施しない。

---

## 次アクション

### 優先度1：P2-05 Boundary Confirmation

次チャットで最初に開始する。

Implementation Unit：

```text
P2-05
Fail Closed / Sync Result / Phase Integration
```

最初に確認すべき正式Input：

- `P2-04 Manual Sync Integration Completion Record v0.1`
- `P2-04 Manual Sync Integration Completion Criteria Final Check v0.1`
- `P2-04 Manual Sync Integration Final Finding Assessment v0.1`
- `P2-04 Manual Sync Integration Production Patch Review v0.1`
- `P2-04 Manual Sync Integration 統合Static Review v0.1`
- `P2-04 Manual Sync Integration Regression Evidence Finalization v0.1`
- `P2-04 Manual Sync Integration 実施仕様 v0.1 Cross-document Consistency Review.md`
- `P2-04 Manual Sync Integration Production Patch Design v0.1.md`
- `Implementation Plan v0.3 日本語版`
- `MVP Design v0.1.9 日本語版`
- `MVP Test Specification v0.1.5 日本語版`

P2-04からP2-05へのInput：

```text
Manual Sync Application Entry
Current Template Scan
Invalid Candidate Execution Guard
Current VariableDefinitions Retrieval
Single SyncTimestamp
BuildSyncDiff Invocation
ApplySyncDiff Invocation
Successful SyncDiffResult Handoff
TemplateScanResult / InvalidCandidates Handoff
Failure Propagation
Fresh State Retry Boundary
```

P2-05で扱う予定の主要責務：

```text
Sync Result Data / Presentation
User Notification
Manual Sync UI Connection
OFT / Invalid Final Fail Closed Integration
Phase-level Error Boundary
P2 Phase Integration
```

P2-04 Approved SpecificationでもこのHandoffが定義されている。

### 優先度2：P2-05 Cross-document Consistency Review

Boundary Confirmation後、

```text
Requirements
Design
Test Specification
Implementation Plan
P2-04 Completion Contract
```

を照合する。

特に確認する論点：

- Sync ResultをどのCarrierからUIへ渡すか
- `templateScanResult.InvalidCandidates`を再ScanせずUser Notificationへ利用すること
- `syncDiffResult`をPersistence成功後のみ利用すること
- OFT Missing / Invalid CandidateのFinal Fail Closed責務
- User-facing Error MappingをP2-05でどこまで行い、P6へ何を残すか
- P2 Phase Verification / CP-P2との境界

### 優先度3：正式Recordの保存状態確認

今回作成したP2-04 Close系RecordがProject Filesへ保存されているか確認する。

未保存なら、P2-05開始前にMarkdownとして正式保存する。

---

# 記事用素材

## 気づき

- **CandidateとApprovedは同じv0.1でも内容が同じとは限らない。**
  - Version番号だけでなく、Cross-document Review / Correction / Approval Recordまで追跡する必要がある。
- 「Approved版ファイルが見当たらない」場合でも、Cross-document ReviewがCorrection適用とApproval Decisionを保持していれば、正式承認Evidenceになる場合がある。
- 同じ`S01-S25`という名前でも、別Documentでは全く別のChecklistだった。
  - IDだけではなく、Source Documentを含めて識別する必要がある。
- Review Checklistを統合するときは元IDを消してはいけない。
  - `SPEC-Sxx`
  - `PATCH-Sxx`
  - `ISR-xx`\
    のようにTraceabilityを維持すると、監査可能性と実務効率を両立できる。
- Static ReviewとRuntime Verificationは別Evidence。
  - Sourceを見れば分かること
  - Runtimeでしか証明できないこと\
    を混ぜない。
- `Before = After`だけでは「下流処理が実行されなかった」ことまでは証明できない。
- Test Harnessの想定がProduction Contractと違った場合、Production Defectと決めつけずTest Artifact Defectの可能性を確認する必要がある。
- Evidenceが保存できなかったことと、TestがFAILしたことは別。
  - `Evidence Incomplete`
  - `Test FAIL`\
    を分離する。
- 当初設計と実装実績が違っても、必ずしも設計失敗ではない。
  - Finding
  - Impact Assessment
  - Controlled Correction
  - Regression
  - Closure\
    が成立すれば、履歴を残したまま安全に変更できる。
- 過去文書を現在の状態に書き換えてしまうより、
  ```text
  Original Decision
  ↓
  Finding
  ↓
  Correction
  ↓
  Final State
  ```
  と残した方が監査証跡として強い。
- 「元文書を修正して綺麗にする」より、「Correction Recordで差分を残す」方が履歴管理として自然。
- Integration Phaseで初めて見つかるContract Gapはある。
  - Unit TestだけではInitialized Metadata Pipelineしか通っておらず、Initial Sync Bootstrap Pipelineの不足がIntegrationで顕在化した。
- 単体ComponentがそれぞれPASSでも、
  ```text
  P2-02 Target State
  ↓
  P2-03 Persistence
  ```
  のProduction Pipeline全体で初めて見える問題がある。
- Completion Criteriaは最後に一度Source of Truthへ戻って全件確認する価値がある。
- 「実装完了した気がする」ではなく、Completion Criteriaを1対1で潰すことで正式Closeできる。
- Formal MVP TestとImplementation Verificationを早い段階から分離したことで、「今PASSしたものが何のPASSなのか」が明確になった。

---

## 記事にできそうな切り口

### 開発日記向き

- **「S01-S25が2つあった」— AI協働開発で文書が増えた結果、Checklist IDが衝突した話**
- **Candidateしか見つからず焦ったら、Cross-document Reviewの中にApproved版が残っていた**
- **28/29 PASSから一転。「未確認」ではなく実は変更していた**
- **設計ではADD onlyだったのに、Integrationで2Module修正することになった**
- **単体テスト全部PASSでも、Bootstrap Pipelineで問題が出た**
- **テスト失敗だと思ったら、テストコード側の勘違いだった**
- **1000行目を二重結合してVBA Sourceを壊したArtifact Generation Defect**
- **Immediate Windowが溢れてEvidenceが消えた。FAILではなくEvidence Incompleteとして扱った**
- **「過去の設計書を書き直すか？」で悩み、Correction Record方式にした**
- **P2-04を正式Closeするまで、実装より文書整理の方が長かった話**
- **AIに実装を任せるほど、人間側の役割は「判断履歴を残すこと」になる**

---

### 技術記事向き

- **Excel VBA + OutlookでManual Sync Application Layerを作る**
  - Scanner
  - Sync Engine
  - Persistence
  - Application Orchestration\
    の責務分離
- **Failure ResultとResult Carrierを同時に返す設計**
  ```text
  COperationResult = Failure
  +
  TemplateScanResult保持
  ```
- **Fail ClosedでResult Carrierを捨てない理由**
- **Persistence成功後だけ`syncDiffResult`を公開するOutput Boundary**
- **Fresh Retry設計**
  ```text
  Template再取得
  Definition再取得
  New Timestamp
  New Diff
  ```
- **Module-level Stateを持たずにRetry安全性を確保する**
- **Bootstrap Metadataの設計**
  - Existing Bootstrap
  - Reactivated Bootstrap
  - Unused Bootstrap
  - Partial Metadata Failure
- **Target State生成とPersistenceの責務分離**
  ```text
  P2-02 BuildSyncDiff
  ↓
  P2-03 Validate / Persist
  ```
- **Static ReviewとRuntime Verificationを分ける**
- **Production Patch Review / Regression / Finding Assessmentの役割差**
- **Controlled Deviationを使った変更管理**
- **Regression Evidenceを「件数」だけでなくContract単位で整理する方法**
- **Candidate → Cross-document Review → Correction → Approvedという文書フロー**
- **Formal TestとImplementation Verificationを分離する開発プロセス**
- **VBAでもBaseline / Completion Criteria / Change Controlを適用する方法**

---

## 有料note / テンプレート化候補

- **Implementation Unit Completion Checklist Template**
  ```text
  Boundary
  Consistency Review
  Approved Specification
  Source Review
  Patch Design
  Compile
  Verification
  Static Review
  Regression
  Patch Review
  Finding Assessment
  Completion Record
  ```
- **Cross-document Consistency Review Template**
- **Candidate → Approved Correction Record Template**
- **Controlled Production Change Record Template**
- **Production Patch Review Template**
- **Final Finding Assessment Template**
- **Completion Criteria Final Check Template**
- **Completion Record Template**
- **Regression Evidence Finalization Template**
- **Integrated Static Review Template**
  - SPEC-Sxx
  - PATCH-Sxx
  - ISR-xx\
    のTraceability方式
- **Finding Classification Checklist**
  ```text
  Production Defect
  Test Artifact Defect
  Artifact Generation Defect
  Evidence Incomplete
  Requirement Gap
  Design Gap
  Contract Conflict
  Regression Finding
  ```
- **「FAILかEvidence不足か」を切り分ける判断基準**
- **既存Production変更時のChange Control Checklist**
  ```text
  Finding
  Impact Assessment
  Contract Impact
  Reopen判定
  Regression
  Closure
  ```
- **AI協働開発向け文書管理ルール**
  - Latest Version
  - Approved Baseline
  - Candidate
  - Approved
  - Completion Record
  - Correction Record\
    の使い分け
- **AIにCode ReviewさせるときのStatic / Runtime Evidence分離プロンプト**
- **長期AI協働開発で「過去の判断を上書きしない」ためのDocumentation Pattern**
