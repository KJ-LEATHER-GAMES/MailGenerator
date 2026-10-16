# P2-01 Full Template Scanner Regression 実施計画 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase | P2 Scan / Sync |
| Parent Unit | P2-05 Fail Closed / Sync Result / Phase Integration |
| Regression Target | P2-01 Full Template Scanner |
| Execution Baseline | BL-MVP-003 |
| Verification Type | Regression Verification |
| Formal MVP Test | NOT CLAIMED |
| Status | READY TO EXECUTE |

---

## 2. 目的

P2-05実装・Verification後も、P2-01 Full Template Scannerで成立済みの以下のContractが維持されていることを確認する。

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

確認範囲：

```text
Candidate Scan
Syntax Validation
Valid / Invalid Separation
Case Insensitive Identity
Subject / Body / Both Location Merge
TemplateScanResult Structural Invariant
Baseline OFT Integration
Recipient Exclusion
```

P2-01 Regression PASSはP2-05 Completion Criteriaの一部であり、Formal MVP Test PASSはClaimしない。

---

# 3. Pre-Regression Environment Reset

P05-I01 Mixed Result終了時点では、P2-05用Controlled Fixtureが残っている可能性がある。

Regression開始前に、P2-05 Verification開始前に保存したSnapshotへ戻す。

## 3.1 Baseline OFT Restore

対象：

```text
Templates\MailTemplate.oft
```

期待されるBaseline Scanner Result：

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
```

したがって、以下のP2-05 Fixtureが残っていないことを確認する。

```text
P05_NewOnly
P05_MixedNew
Bad-Name
```

## 3.2 VariableDefinition Restore

P2-01 Scanner自体はVariableDefinitionへ依存しないが、後続RegressionをClean Stateから開始するため、P2-05 Verification開始前Snapshotへ復元する。

少なくとも以下のP2-05 Fixture Row / Status変更をBaselineへ戻す。

```text
P05_NewOnly
P05_MixedNew

ModelName / GateDate / Department / Comment の
P2-05 Fixture用Status変更
```

復元方法はManual Syncではなく、事前保存Snapshotからの復元を優先する。

理由：

```text
Manual Syncで戻す
→ LastDetectedAt等が再更新される

Snapshot Restore
→ Pre-P2-05 stateを正確に復元可能
```

---

# 4. Regression Execution Sequence

実行順：

```text
R1 Core Regression
↓
R2 Baseline OFT Integration
↓
R3 Recipient Exclusion Integration
↓
P2-01 Regression Decision
```

---

# 5. R1 — Core Regression

## Test Module

```text
modP2_01FullTemplateScannerCoreTest_v0.1_CP932.bas
```

## Entry Point

```vb
TestP201FullTemplateScannerCore
```

## Expected

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

PASS Count:
11

FAIL Count:
0

Overall:
PASS
```

## Evidence

Immediate Windowの結果全文を取得する。

最低限：

```text
11 / 11 PASS
FAIL = 0
Overall = PASS
```

---

# 6. R2 — Baseline OFT Integration Regression

## Test Module

```text
modP2_01FullTemplateScannerIntegrationTest_v0.1_CP932.bas
```

## Entry Point

```vb
TestP201FullTemplateScannerBaselineOftIntegration
```

## Fixture

```text
Workbook:
MailGeneratorNew.xlsm

OFT:
Templates\MailTemplate.oft
```

## Expected Production Path

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
CloseWithoutSave
```

## Expected Result

```text
GetSettingValue(TemplatePath):
PASS

ResolveWorkbookRelativePath:
PASS

CreateMailFromTemplate:
PASS

ReadSubject:
PASS

ReadBodyText:
PASS

ScanTemplate:
PASS
```

TemplateScanResult：

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

## Fail Criteria

以下のいずれかでRegression Finding候補とする。

```text
ValidVariablesの不足 / 余分
InvalidCandidates > 0
Location不一致
Structural Invariant FAIL
CloseWithoutSave FAIL
Unhandled Runtime Error
WordEditor E_FAIL再発
```

WordEditor E_FAILがFresh Warm状態で再発した場合は、単純なP2-01 Regression FAILと即断せず、既存OBS-P2-05-002のReopen条件としてSessionを保持してFinding再評価へ切り替える。

---

# 7. R3 — Recipient Exclusion Integration Regression

## Test Module

```text
modP2_01MtsScan005IntegrationTest_v0.1_CP932.bas
```

## Entry Point

```vb
TestP201MtsScan005RecipientExclusionIntegration
```

## Dedicated Fixture

```text
Templates\MailTemplate_MTS-SCAN-005.oft
```

Fixture Intent：

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

## Expected

```text
ResolveWorkbookRelativePath:
PASS

CreateMailFromTemplate:
PASS

ReadSubject:
PASS

ReadBodyText:
PASS

Fixture Subject Precondition:
PASS

Fixture Body Precondition:
PASS

ScanTemplate:
PASS
```

TemplateScanResult：

```text
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

---

# 8. Regression PASS Criteria

以下をすべて満たした場合のみP2-01 RegressionをPASSとする。

```text
R1 Core:
11 / 11 PASS

R2 Baseline OFT Integration:
PASS

R3 Recipient Exclusion:
PASS

Unhandled Runtime Error:
NONE

Production Code Change:
NONE

Regression Finding:
NONE
```

Final：

```text
P2-01 Full Template Scanner Regression
PASS
```

---

# 9. Evidence to Share

各実行後、以下を保存する。

```text
1. R1 Immediate Window
   - 11 / 11 PASSが分かる全文

2. R2 Immediate Window
   - Baseline OFT Integration結果全文
   - ValidVariables / InvalidCandidates / Locationsを含む

3. R3 Immediate Window
   - Recipient Exclusion結果全文
   - RecipientTo / RecipientCc / RecipientBcc = NOT DETECTEDを含む
```

スクリーンショットでもよいが、Immediate WindowのTextコピーが可能ならTextの方がレビューしやすい。

---

# 10. Regression Record Template

実行後の正式Recordでは以下を記録する。

```text
P2-01 Full Template Scanner Regression

Execution Baseline:
BL-MVP-003

Pre-Regression Environment Reset:
PASS

Core:
11 / 11 PASS

Baseline OFT Integration:
PASS

Recipient Exclusion Integration:
PASS

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

Unhandled Runtime Error:
NONE

Production Change Required:
NONE

Regression Finding:
NONE

Blocking Finding:
0

RESULT:
PASS / FAIL
```

---

# 11. Next Gate

PASS後：

```text
P2-01 Regression
PASS
↓
P2-02 Sync Diff Core Regression
```

P2-01 RegressionのみでP2-05 COMPLETEとはしない。

---

## 12. まとめ / Summary

### 日本語

P2-01 Regressionでは、まずP2-05 Controlled FixtureをBaseline Snapshotへ復元する。その後、Core 11件、Baseline OFT Integration、Recipient Exclusion Integrationの3段階でScanner Contractを再確認する。3項目すべてPASSし、Production変更やRegression FindingがなければP2-01 RegressionをPASSとし、P2-02 Regressionへ進む。

### English

For P2-01 Regression, first restore the P2-05 controlled fixtures to the baseline snapshot. Then run the Core 11-case test, the Baseline OFT Integration test, and the Recipient Exclusion Integration test. If all three pass with no production change or regression finding, P2-01 Regression is PASS and the next step is P2-02 Regression.
