# P2-01 Full Template Scanner Regression Record v0.1

## 1. Document Information

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Parent Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Regression Target | P2-01 Full Template Scanner |
| Verification Type | Implementation / Regression Verification |
| Execution Baseline | `BL-MVP-003` |
| Record Date | 2026-10-09 |
| Formal MVP Test | **NOT CLAIMED** |
| Final Result | **PASS / CLOSED** |

---

# 2. Purpose

P2-05実装後も、P2-01 Full Template Scannerで成立済みの以下ContractにRegressionがないことを確認する。

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

確認対象：

```text
Core Scanner Contract
Valid / Invalid Candidate Separation
Case Insensitive Identity
Subject / Body / Both Location Merge
Baseline OFT Integration
Recipient Field Exclusion
TemplateScanResult Structural Invariant
CloseWithoutSave
```

本RecordはImplementation / Regression Verification Evidenceであり、Formal MVP Test PASSを意味しない。

---

# 3. Pre-Regression State

P2-05 Runtime Verification用Controlled Fixtureを解除し、Baseline状態へ復元した。

VariableDefinition：

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

はBaseline状態から除去済み。

Baseline OFT：

```text
Templates\MailTemplate.oft
```

MTS-SCAN-005 Fixture：

```text
Templates\MailTemplate_MTS-SCAN-005.oft
```

---

# 4. R1 — Core Regression

Entry Point：

```vb
TestP201FullTemplateScannerCore
```

Observed Result：

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
```

Result：

```text
PASS Count: 11
FAIL Count: 0

TestP201FullTemplateScannerCore:
PASS
```

Decision：

```text
R1 Core Regression:
PASS
```

---

# 5. Initial Integration Execution

## 5.1 Baseline OFT Integration — Initial Execution

Production path reached：

```text
GetSettingValue(TemplatePath): PASS
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: FAIL
CloseWithoutSave: PASS
```

Observed：

```text
ResolvedPath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

Subject Snapshot:
【{{ModelName}}】ゲート審査 {{GateDate}} / {{modelname}}
```

`ReadBodyText` failure occurred before `ScanTemplate`.

Therefore：

```text
Scanner execution:
NOT REACHED

TemplateScanResult evaluation:
NOT REACHED
```

Initial Result：

```text
TestP201FullTemplateScannerBaselineOftIntegration:
FAIL
```

---

## 5.2 MTS-SCAN-005 Recipient Exclusion — Initial Execution

Production path reached：

```text
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: FAIL
CloseWithoutSave: PASS
```

Observed：

```text
ResolvedPath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate_MTS-SCAN-005.oft

Subject Snapshot:
【{{ModelName}}】ゲート審査
```

`ReadBodyText` failure occurred before `ScanTemplate`.

Initial Result：

```text
TestP201MtsScan005RecipientExclusionIntegration:
FAIL
```

---

# 6. Initial Failure Triage

## 6.1 Fixture Verification

Manual inspection confirmed Baseline OFT contains the expected Subject / Body variables.

Baseline OFT：

```text
Subject:
{{ModelName}}
{{GateDate}}
{{modelname}}

Body includes:
{{ModelName}}
{{GateDate}}
{{Department}}
{{Comment}}
```

MTS-SCAN-005 OFT：

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

MTS-SCAN-005 Test Harness expects：

```text
VAR_SUBJECT = ModelName
VAR_BODY    = Department
VAR_TO      = RecipientTo
VAR_CC      = RecipientCc
VAR_BCC     = RecipientBcc
```

Therefore：

```text
Fixture Content Defect:
NOT IDENTIFIED

Wrong Recipient Exclusion Fixture:
NO
```

MTS-SCAN-005 requirement is limited to:

```text
Subject / Body are scanner targets
To / CC / BCC are not scanner targets
```

The Body containing only `{{Department}}` is valid for this test purpose.

---

## 6.2 Failure Localization

Both failed Integration executions showed the same boundary:

```text
CreateMailFromTemplate:
PASS

ReadSubject:
PASS

ReadBodyText:
FAIL

ScanTemplate:
NOT REACHED
```

Therefore the failure was localized before Scanner execution.

Current evidence did not indicate Regression in：

```text
modTemplateScanner
ValidVariables
InvalidCandidates
Locations
Recipient Exclusion
VariableDefinition
```

Common failure boundary：

```text
modOutlookAdapter.ReadBodyText
↓
Inspector
↓
WordEditor
↓
Word Document
```

---

## 6.3 Exact Root Cause Boundary

The initial Integration Harness output recorded only：

```text
ReadBodyText: FAIL
```

and did not capture：

```text
ErrorType
Message
Target
```

Therefore：

```text
Exact Technical Root Cause:
NOT PROVEN
```

The initial failure cannot be formally identified as the same exact `WordEditor E_FAIL` previously tracked under OBS-P2-05-002.

However, the observed boundary is consistent with the existing intermittent Outlook / WordEditor readiness observation.

---

# 7. Fresh Warm Controlled Rerun

After the initial failure, a Fresh Warm controlled rerun was performed.

No Production Code correction was applied before rerun.

```text
Production Code Change:
NONE
```

---

# 8. R2 — Baseline OFT Integration Fresh Warm Rerun

Entry Point：

```vb
TestP201FullTemplateScannerBaselineOftIntegration
```

Observed Production Path：

```text
GetSettingValue(TemplatePath): PASS
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: PASS
ScanTemplate: PASS
CloseWithoutSave: PASS
```

Observed Scanner Result：

```text
ValidVariables Count: 4

ModelName
GateDate
Department
Comment
```

Invalid Candidate Result：

```text
InvalidCandidates Count: 0
InvalidCandidates: <empty>
```

Locations：

```text
ModelName  = Both
GateDate   = Both
Department = Body
Comment    = Body
```

Additional Contract Evidence：

```text
Baseline ValidVariables: PASS
Baseline InvalidCandidates: PASS
Locations CompareMode: PASS
ModelName Location: PASS / Both
GateDate Location: PASS / Both
Department Location: PASS / Body
Comment Location: PASS / Body
TemplateScanResult Structural Invariant: PASS
CloseWithoutSave: PASS
```

Result：

```text
TestP201FullTemplateScannerBaselineOftIntegration:
PASS
```

Decision：

```text
R2 Baseline OFT Integration:
PASS
```

---

# 9. R3 — Recipient Exclusion Fresh Warm Rerun

Entry Point：

```vb
TestP201MtsScan005RecipientExclusionIntegration
```

Observed Production Path：

```text
ResolveWorkbookRelativePath: PASS
CreateMailFromTemplate: PASS
ReadSubject: PASS
ReadBodyText: PASS
Fixture Subject Precondition: PASS
Fixture Body Precondition: PASS
ScanTemplate: PASS
CloseWithoutSave: PASS
```

Observed Scanner Result：

```text
ValidVariables Count: 2

ModelName
Department
```

Locations：

```text
ModelName   = Subject
Department  = Body
```

Recipient Exclusion：

```text
RecipientTo:
NOT DETECTED

RecipientCc:
NOT DETECTED

RecipientBcc:
NOT DETECTED
```

Additional Contract Evidence：

```text
Subject / Body Scan Target: PASS
ModelName Location: PASS / Subject
Department Location: PASS / Body
To Exclusion: PASS
CC Exclusion: PASS
BCC Exclusion: PASS
InvalidCandidates: PASS / 0
Locations CompareMode: PASS
TemplateScanResult Structural Invariant: PASS
CloseWithoutSave: PASS
```

Result：

```text
TestP201MtsScan005RecipientExclusionIntegration:
PASS
```

Decision：

```text
R3 Recipient Exclusion:
PASS
```

---

# 10. Initial Failure → Fresh Warm PASS Assessment

Observed sequence：

```text
Initial Session
├─ Baseline OFT Integration
│  └─ ReadBodyText FAIL
│
└─ Recipient Exclusion Integration
   └─ ReadBodyText FAIL

Fresh Warm Controlled Rerun
├─ Baseline OFT Integration
│  └─ PASS
│
└─ Recipient Exclusion Integration
   └─ PASS
```

No Production Code change occurred between failure and rerun.

Therefore the evidence supports：

```text
Deterministic Scanner Regression:
NOT IDENTIFIED

Deterministic OFT Fixture Defect:
NOT IDENTIFIED

Deterministic Recipient Exclusion Defect:
NOT IDENTIFIED

Session-dependent / transient ReadBodyText behavior:
PLAUSIBLE
```

The evidence does **not** prove the exact technical root cause.

---

# 11. OBS-P2-05-002 Impact

Existing Observation：

```text
OBS-P2-05-002
Intermittent WordEditor E_FAIL

Status:
OPEN / NON-BLOCKING
```

The P2-01 Regression initial failure adds relevant observation evidence：

```text
Two independent OFT Integration tests
→ same session
→ ReadBodyText FAIL

Fresh Warm controlled rerun
→ both PASS
```

However the initial failure did not capture：

```text
ErrorType
Message
Target
```

Therefore the following is not claimed：

```text
The initial P2-01 failure was definitively
the same WordEditor E_FAIL as OBS-P2-05-002.
```

Disposition：

```text
OBS-P2-05-002:
OPEN / NON-BLOCKING

Production Correction:
NONE
```

No new deterministic Production defect is established by this regression run.

---

# 12. Production Change Assessment

Based on current evidence：

```text
Production Correction:
NONE
```

The following are not justified by the regression evidence：

```text
DoEvents insertion
Sleep
Fixed delay
Retry loop
Automatic Manual Sync retry
Application-layer Outlook handling change
Public API change
```

---

# 13. Regression Finding Assessment

Initial integration failure：

```text
Observed:
YES
```

Controlled Fresh Warm rerun：

```text
PASS:
YES
```

Confirmed Scanner Regression Finding：

```text
NONE
```

Confirmed Fixture Finding：

```text
NONE
```

Confirmed Production Defect：

```text
NONE
```

Residual Observation：

```text
OBS-P2-05-002
OPEN / NON-BLOCKING
```

Active Blocking Regression Finding：

```text
0
```

---

# 14. Final Regression Decision

Final required P2-01 Regression Evidence：

```text
P2-01 Core:
11 / 11 PASS

Baseline OFT Integration:
PASS

Recipient Exclusion:
PASS
```

Confirmed Contract Coverage：

```text
TemplateScanResult Contract:
PASS

ValidVariables:
PASS

InvalidCandidates:
PASS

Locations:
PASS

Subject / Body / Both:
PASS

Case Insensitive Merge:
PASS

Recipient Exclusion:
PASS

Structural Invariant:
PASS

CloseWithoutSave:
PASS
```

Final：

```text
P2-01 Full Template Scanner Regression

RESULT:
PASS / CLOSED
```

---

# 15. Completion Boundary

This result means：

```text
P2-01 Regression:
PASS / CLOSED
```

It does not mean：

```text
P2-05 COMPLETE
P2 Phase COMPLETE
CP-P2 ESTABLISHED
Formal MVP Test PASS
MVP Product PASS
```

P2-05 remaining sequence：

```text
P2-02 Regression
↓
P2-03 Regression
↓
P2-04 Regression
↓
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

---

# 16. Test Artifact Improvement Candidate

The P2-01 Integration Harness currently reports：

```text
ReadBodyText: FAIL
```

without the underlying `COperationResult.Errors`.

Future test-artifact improvement candidate：

```text
Success
Errors.Count
ErrorType
Message
Target
```

This is：

```text
Test Artifact Observability Improvement
```

and does not require Production Code modification.

It is not a blocker for the present P2-01 Regression closure.

---

# 17. Summary / まとめ

## 日本語

P2-01 Full Template Scanner Regressionを実施した。Core Regressionは11 / 11 PASSした。Initial Integration ExecutionではBaseline OFTおよびMTS-SCAN-005の両方が`ReadBodyText`でFAILしたが、いずれも`ScanTemplate`到達前のFailureであり、Fixture内容にも不整合は確認されなかった。

Production Codeを変更せずFresh Warm条件でControlled Rerunした結果、Baseline OFT IntegrationおよびRecipient Exclusion IntegrationはともにPASSした。ValidVariables、InvalidCandidates、Locations、Subject / Body / Both、Recipient Exclusion、Structural Invariantはいずれも期待結果と一致した。

したがってDeterministicなScanner Regression、Fixture Defect、Production Defectは確認されていない。Initial FailureのErrorType / Message / Targetは未取得のためExact Root Causeは未証明とする。既存`OBS-P2-05-002`はOPEN / NON-BLOCKINGのまま維持し、Production Correctionは行わない。

以上より、**P2-01 Full Template Scanner RegressionをPASS / CLOSED** とする。次はP2-02 Sync Diff Core Regressionへ進む。

## English

P2-01 Full Template Scanner Regression was completed. The Core Regression passed 11 / 11 cases. During the initial integration execution, both the Baseline OFT and MTS-SCAN-005 tests failed at `ReadBodyText`, before `ScanTemplate` was reached. No fixture mismatch was confirmed.

Without any production code change, both integration tests passed in a Fresh Warm controlled rerun. ValidVariables, InvalidCandidates, Locations, Subject / Body / Both behavior, recipient exclusion, and the structural invariant all matched the expected results.

No deterministic scanner regression, fixture defect, or production defect was identified. The exact root cause of the initial failure is not proven because ErrorType, Message, and Target were not captured. `OBS-P2-05-002` remains OPEN / NON-BLOCKING, and no production correction is applied.

Therefore, **P2-01 Full Template Scanner Regression is PASS / CLOSED**. The next step is P2-02 Sync Diff Core Regression.
