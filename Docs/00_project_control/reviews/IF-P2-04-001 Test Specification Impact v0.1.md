# IF-P2-04-001 Test Specification Impact v0.1

## 1. Target

```text
Current:
DOC-MVP-TESTSPEC
MVP Test Specification v0.1.5

Patch Target Candidate:
MVP Test Specification v0.1.6
```

目的：

```text
Initial Sync Metadata Bootstrap Ruleを
Formal Test Specificationへ反映する。
```

---

# 2. Test Case Numbering Policy

新しいMTS IDは追加しない。

既存：

```text
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-011
```

の中へVariantを追加する。

したがって、

```text
Formal Test Case ID体系:
UNCHANGED
```

とする。

---

# 3. §8.3 Baseline VariableDefinition Patch

現行：

```text
TemplateLocation / FirstDetectedAt / LastDetectedAtは
Sync Testで別途確認する。
```

を以下へ明確化する。

### Baseline Sync Metadata

特定Test Caseで別途指定しない限り、Baseline VariableDefinitionの自動管理Metadataは初回Sync前の状態として以下を使用する。

```text
TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

この状態は、

```text
VariableDefinition行は存在するが、
Template Syncによる正常検出履歴はまだ存在しない
```

ことを表す。

Initialized Metadataを前提とするTest Caseでは、Preconditionで明示的に既存値を設定する。

---

# 4. MTS-SYNC-003 Existing設定保持

既存Caseを2 Variantへ拡張する。

## Variant A — Initialized Existing

### Precondition

既存Variable：

```text
Status = Active

TemplateLocation = Existing Valid Location
FirstDetectedAt   = Existing Valid Date
LastDetectedAt    = Existing Valid Date
```

ユーザー設定あり。

### Expected

ユーザー設定：

```text
保持
```

Metadata：

```text
TemplateLocation = Current Location
FirstDetectedAt  = Existing FirstDetectedAt
LastDetectedAt   = SyncTimestamp
```

---

## Variant B — Bootstrap Existing

### Precondition

Current Templateに存在する既存Variable：

```text
Status = Active

TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

### Expected

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

既存ユーザー設定は保持する。

---

# 5. MTS-SYNC-004 Unused化

既存Caseを2 Variantへ拡張する。

## Variant A — Initialized Unused

従来Case。

### Precondition

Active VariableにInitialized Metadataを設定し、OFTから削除する。

### Expected

```text
Status           = Unused
TemplateLocation = Existing Value
FirstDetectedAt  = Existing Value
LastDetectedAt   = Existing Value
```

ユーザー設定保持。

---

## Variant B — Bootstrap Unused

### Precondition

VariableDefinition：

```text
Status = Active

TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

Current Template：

```text
Variable does not exist
```

### Expected

```text
Status           = Unused

TemplateLocation = Empty
FirstDetectedAt  = Empty
LastDetectedAt   = Empty
```

同期時刻をDetection Metadataへ設定しない。

VariableDefinition行は削除しない。

ユーザー設定を保持する。

---

# 6. MTS-SYNC-005 Reactivated

既存Caseを2 Variantへ拡張する。

## Variant A — Initialized Reactivated

従来Case。

### Precondition

Unused VariableにInitialized Metadataがあり、OFTへ再追加する。

### Expected

```text
Status           = Active
TemplateLocation = Current Location
FirstDetectedAt  = Existing FirstDetectedAt
LastDetectedAt   = SyncTimestamp
```

既存設定を再利用する。

---

## Variant B — Bootstrap Reactivated

### Precondition

VariableDefinition：

```text
Status = Unused

TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

Current Template：

```text
Variable exists
```

### Expected

```text
Status           = Active
TemplateLocation = Current Location
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

既存ユーザー設定は再利用する。

---

# 7. MTS-SYNC-011 Sync Metadata更新

MTS-SYNC-011をBootstrap Ruleの主要Formal Verification Caseとして拡張する。

## Expected Matrix

| 状態                          | TemplateLocation | FirstDetectedAt | LastDetectedAt |
| --------------------------- | ---------------- | --------------- | -------------- |
| New                         | Current          | SyncTimestamp   | SyncTimestamp  |
| Existing / Initialized      | Current          | Existing        | SyncTimestamp  |
| Existing / Uninitialized    | Current          | SyncTimestamp   | SyncTimestamp  |
| Reactivated / Initialized   | Current          | Existing        | SyncTimestamp  |
| Reactivated / Uninitialized | Current          | SyncTimestamp   | SyncTimestamp  |
| Unused / Initialized        | Existing         | Existing        | Existing       |
| Unused / Uninitialized      | Empty            | Empty           | Empty          |

同一Manual Syncで新たに設定されるTimestampは同一値でなければならない。

対象：

```text
New.FirstDetectedAt
New.LastDetectedAt

Bootstrap Existing.FirstDetectedAt
Existing.LastDetectedAt

Bootstrap Reactivated.FirstDetectedAt
Reactivated.LastDetectedAt
```

Unused化のみを理由として、

```text
FirstDetectedAt
LastDetectedAt
```

へSyncTimestampを設定してはならない。

---

# 8. Partial Metadata

以下はBootstrap Variantとして扱わない。

例：

```text
TemplateLocation = Empty
FirstDetectedAt   = Valid Date
LastDetectedAt    = Empty
```

または、

```text
TemplateLocation = Subject
FirstDetectedAt   = Empty
LastDetectedAt    = Valid Date
```

これらは、

```text
Uninitialized Metadata
```

ではなく、

```text
Inconsistent Metadata
```

として扱う。

Formal MTS Caseを今回新設せず、

```text
P2-02 / P2-03 Technical Negative Regression
```

で確認する。

---

# 9. Existing Formal Coverage Impact

変更なし：

```text
MTS-SYNC-001
MTS-SYNC-002
MTS-SYNC-006
MTS-SYNC-007
MTS-SYNC-008
MTS-SYNC-009
MTS-SYNC-010
MTS-SYNC-012
```

意味論補強：

```text
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-011
```

---

# 10. Test Count Impact

```text
New Formal MTS ID:
0

Deleted Formal MTS ID:
0

Existing MTS with Added Variants:
4
```

正式Test Case体系の番号変更は行わない。

---

# 11. Traceability Impact

Requirements Traceability：

```text
UNCHANGED
```

主な既存Traceability：

```text
MTS-SYNC-003
→ FR-SYNC-003

MTS-SYNC-004
→ FR-SYNC-004

MTS-SYNC-005
→ FR-SYNC-005

MTS-SYNC-011
→ VariableDefinition Requirement
→ Design §7.4 / §15
```

新Requirement IDは追加しない。

---

# 12. Document Impact

```text
MVP Requirements v0.1.9:
Change NOT REQUIRED

MVP Design:
v0.1.9
→ v0.1.10 Candidate

MVP Test Specification:
v0.1.5
→ v0.1.6 Candidate

Implementation Plan v0.3:
Change NOT REQUIRED
```

---

# 13. Formal Test Boundary

今回追加するVariantはFormal Test Specificationへ入れるが、現段階ではFormal PASS判定を行わない。

```text
Specification Updated
≠
Formal Test Executed
```

Formal Testは従来どおりP7後のTest Candidate Buildに対して実施する。

---

# 14. Impact Decision

```text
IF-P2-04-001 Test Specification Impact:
CONFIRMED

Test Specification Patch:
REQUIRED

New MTS ID:
NOT REQUIRED

Variant Addition:
REQUIRED

Target Candidate:
MVP Test Specification v0.1.6
```
