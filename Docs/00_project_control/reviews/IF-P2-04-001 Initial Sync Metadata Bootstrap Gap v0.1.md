# IF-P2-04-001 Initial Sync Metadata Bootstrap Gap

## Finding & Design Gap Resolution v0.1

## 1. Finding Information

| 項目                             | 内容                                               |
| ------------------------------ | ------------------------------------------------ |
| Finding ID                     | `IF-P2-04-001`                                   |
| Finding Name                   | Initial Sync Metadata Bootstrap Gap              |
| Detection Phase                | P2-04 Manual Sync Integration Local Verification |
| Execution Baseline             | `BL-MVP-003`                                     |
| Status                         | **CONFIRMED / DESIGN GAP RESOLUTION DEFINED**    |
| Blocking                       | **YES**                                          |
| P2-04 Production Defect        | **NONE**                                         |
| Requirement Gap                | **NONE**                                         |
| Design Gap                     | **YES**                                          |
| P2-02 / P2-03 Contract Finding | **YES**                                          |

---

# 2. Detection Evidence

P2-04 Happy Path Verification：

```text
ExecuteManualSync:
Success = False

ErrorType = UnexpectedError
Target    = ModelName
Message   = FirstDetectedAt is not a valid persisted date value.
```

同時に、

```text
TemplateScanResult:
ValidVariables.Count    = 4
InvalidCandidates.Count = 0
Locations.Count         = 4

syncDiffResult Is Nothing = True
```

であった。

したがって、

```text
Template Path
↓
OFT Acquisition
↓
Template Scan
↓
Invalid Candidate Guard
```

までは成立している。

後続Persistence BoundaryでFailureとなっている。

---

# 3. Current VariableDefinition Evidence

Diagnostic：

```text
ModelName
FirstDetectedAt = Empty
LastDetectedAt  = Empty

OldVariable
FirstDetectedAt = Empty
LastDetectedAt  = Empty
```

両値とも、

```text
TypeName = Empty
VarType  = 0
```

である。

---

# 4. Baseline Data Assessment

Requirementsでは、

```text
TemplateLocation = 自動
Status           = 自動
FirstDetectedAt  = 初回検出日時
LastDetectedAt   = 最終検出日時
```

として定義されている。

一方、MVP Test SpecificationのBaseline VariableDefinitionでは、

```text
ModelName
GateDate
Department
Comment
```

等のユーザー設定値とStatusを事前定義しているが、

```text
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

はBaseline値として固定しておらず、Sync Testで別途確認する扱いとなっている。

したがって、

```text
既存VariableDefinition行が存在する
+
初回Sync未実施
+
自動管理MetadataがEmpty
```

という状態は、Current Baselineから排除されていない。

---

# 5. Current Design

Current Design §7.4：

```text
New
TemplateLocation = Current
FirstDetectedAt   = SyncTimestamp
LastDetectedAt    = SyncTimestamp

Existing
TemplateLocation = Current
FirstDetectedAt   = Existing Value保持
LastDetectedAt    = SyncTimestamp

Reactivated
TemplateLocation = Current
FirstDetectedAt   = Existing Value保持
LastDetectedAt    = SyncTimestamp

Unused
TemplateLocation = Existing Value保持
FirstDetectedAt   = Existing Value保持
LastDetectedAt    = Existing Value保持
```

と定義している。

しかし、

```text
Existing Value = Empty
```

の場合の扱いは定義されていない。

---

# 6. Current P2-02 Contract

P2-02は、

```text
TemplateScanResult
+
Current VariableDefinitions
+
SyncTimestamp
↓
Target Metadata Calculation
↓
SyncDiffResult
```

を担当する。

SyncDiffResultには、

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

を含む。

P2-02ではExisting / Reactivated / Unused Metadata Ruleを成立済みとしていたが、Verificationには、

```text
Existing Metadata
Reactivated Metadata
Unused Metadata
```

は含まれる一方、

```text
Existing with uninitialized metadata
Reactivated with uninitialized metadata
Unused with uninitialized metadata
```

のBootstrap Variantは含まれていなかった。

---

# 7. Current P2-03 Contract

P2-03は、

```text
SyncDiffResult
↓
VariableDefinition Persistence
```

を担当する。

P2-03ではDate値として、

```text
VBA Date
Excel numeric Date serial
```

を受け付ける。

一方、

```text
Empty
String Date
```

は有効Dateとして扱わない。

したがって現在は、

```text
P2-02
Existing FirstDetectedAt = Emptyを保持
↓
P2-03
Empty Dateを拒否
↓
Manual Sync Failure
```

となる。

---

# 8. Root Cause

Root Cause：

```text
初回Sync前に存在するVariableDefinition行について、
自動管理Metadataが未初期化である状態の
Bootstrap RuleがDesignで定義されていなかった。
```

特に未定義だった項目：

```text
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

これはProduction Coding Errorではなく、

```text
Design Completeness Gap
```

である。

---

# 9. Finding Classification

```text
Finding:
IF-P2-04-001

Primary Classification:
Design Gap

Secondary Classification:
P2-02 / P2-03 Contract Integration Finding

Requirement Gap:
NONE

P2-04 Production Defect:
NONE

Test Artifact Defect:
NONE

Blocking:
YES
```

---

# 10. Design Gap Resolution Principle

自動管理Metadataについて、以下2状態を明示的に区別する。

## Initialized Metadata

過去のSyncにより有効なMetadataを持つ状態。

```text
TemplateLocation:
Subject / Body / Both

FirstDetectedAt:
Valid Date

LastDetectedAt:
Valid Date
```

## Uninitialized Metadata

VariableDefinition行は存在するが、そのVariableをTemplate上でまだ正常検出した履歴がない状態。

```text
TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

Emptyは、

```text
Invalid Date
```

ではなく、

```text
Not Yet Detected
```

を表すBootstrap状態として扱う。

---

# 11. Resolved Metadata Rules

## 11.1 New

変更なし。

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

---

## 11.2 Existing

Current Template上にVariableが存在する。

### FirstDetectedAt initialized

```text
FirstDetectedAt = Existing FirstDetectedAt
```

### FirstDetectedAt uninitialized

```text
FirstDetectedAt = SyncTimestamp
```

共通：

```text
TemplateLocation = Current Location
Status           = Active
LastDetectedAt   = SyncTimestamp
```

すなわち、

```text
FirstDetectedAt =
    Existing Value    if initialized
    SyncTimestamp     if uninitialized
```

とする。

---

# 12. Reactivated

Current Definition：

```text
Status = Unused
```

かつCurrent Template上にVariableが再存在する場合。

### FirstDetectedAt initialized

```text
FirstDetectedAt = Existing FirstDetectedAt
```

### FirstDetectedAt uninitialized

```text
FirstDetectedAt = SyncTimestamp
```

共通：

```text
TemplateLocation = Current Location
Status           = Active
LastDetectedAt   = SyncTimestamp
```

現在Template上で確認できたSyncを、

```text
First known detection
```

として扱う。

---

# 13. Unused

Current Definition：

```text
Status = Active
```

だがCurrent Template上に存在しない場合。

以下を保持する。

```text
TemplateLocation
FirstDetectedAt
LastDetectedAt
```

既存Metadataがinitializedなら、その値を保持する。

既存Metadataがuninitializedなら、

```text
TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

をそのまま保持する。

Current Template上で検出していないため、

```text
SyncTimestampをFirstDetectedAtへ設定しない
SyncTimestampをLastDetectedAtへ設定しない
```

とする。

---

# 14. Already-Unused

変更なし。

```text
No-op
```

現在のP2-02 ContractどおりOutput Itemを生成しない。

---

# 15. Invalid Non-empty Metadata

今回のResolutionは、

```text
Empty
```

のみを正当なBootstrap状態として追加する。

以下を有効化するものではない。

```text
Invalid String Date
不正なTemplateLocation
Excel Error
その他破損値
```

したがって、

```text
Empty
→ Uninitialized Metadataとして許容

Non-empty
→ Existing Validation Ruleに従う
```

とする。

---

# 16. Responsibility after Resolution

## P2-02 Sync Diff Core

責務：

```text
Metadata Target State Calculation
```

を維持する。

したがって、

```text
Existing / Reactivated
+
FirstDetectedAt = Empty
↓
FirstDetectedAt = SyncTimestamp
```

への変換は **P2-02責務** とする。

P2-03へBootstrap計算を移さない。

---

## P2-03 VariableDefinition Sync Persistence

責務：

```text
P2-02が計算したTarget StateのPersistence
```

を維持する。

P2-03ではMetadata意味論を再計算しない。

ただしValidationをClassification-awareにし、

```text
New / Existing / Reactivated
→ FirstDetectedAt / LastDetectedAtは有効Date必須

Unused
→ Emptyを保持可能
→ Non-emptyなら既存型Validationを適用
```

とする。

またUnusedの`TemplateLocation`について、

```text
Empty
```

を未検出履歴として保持可能とする。

---

# 17. P2-04 Assessment

P2-04では今回、

```text
TemplateScanResultを正常取得
InvalidCandidates = 0
下流FailureをCOperationResultとして伝播
templateScanResultを保持
syncDiffResultをNothingとして維持
```

できている。

したがって、

```text
modSyncApplication Production Correction:
NOT REQUIRED
```

とする。

P2-04 Local VerificationはGap解消まで、

```text
BLOCKED
```

とする。

---

# 18. Control Impact

```text
P2-01:
Reopen NOT REQUIRED

P2-02:
REOPEN REQUIRED

P2-03:
REOPEN REQUIRED

P2-04 Production:
Correction NOT REQUIRED

P2-04 Local Verification:
BLOCKED

P2-05:
NOT STARTED

P2 Phase:
IN PROGRESS

CP-P2:
NOT ESTABLISHED
```

Implementation Plan上もP2 Exit CriteriaにはSync Metadata規則成立とBlocking Sync Findingがないことが要求されているため、本Findingを未解決のままP2をCloseできない。

---

# 19. Document Impact — Resolution Stage

この時点ではまだ文書を変更しない。

Impact判定：

```text
MVP Requirements v0.1.9:
Semantic Change NOT REQUIRED

MVP Design v0.1.9:
PATCH REQUIRED

MVP Test Specification v0.1.5:
IMPACT / PATCH REQUIRED

Implementation Plan v0.3:
Semantic Change NOT REQUIRED

P2-02 Implementation Contract:
CORRECTION REQUIRED

P2-03 Implementation Contract:
CORRECTION REQUIRED
```

Requirementsには既に、

```text
FirstDetectedAt = 初回検出日時
LastDetectedAt  = 最終検出日時
```

という意味が存在するため、新しいUser-visible Requirementは追加しない。

---

# 20. Resolution Decision

```text
IF-P2-04-001:
CONFIRMED

Design Gap:
CONFIRMED

Design Gap Resolution:
DEFINED

Requirement Gap:
NONE

P2-04 Production Defect:
NONE

Blocking:
YES

Next:
Design Patch
```
