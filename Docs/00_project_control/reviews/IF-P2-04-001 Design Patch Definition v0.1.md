# IF-P2-04-001 Design Patch Definition v0.1

## 1. Patch Target

```text
Current:
DOC-MVP-DES
MVP Design v0.1.9

Patch Target Candidate:
MVP Design v0.1.10
```

Change Type：

```text
Design Completeness Correction
```

Trigger：

```text
IF-P2-04-001
Initial Sync Metadata Bootstrap Gap
```

新しいUser Requirementは追加しない。

---

# 2. Change Scope

変更対象：

```text
§7.4 自動管理列の更新規則
§15.4 Existing
§15.5 Reactivated
§15.6 Unused
```

変更不要：

```text
§7.2 VariableDefinition列構成
§15.1 比較方式
§15.2 差分分類
§15.3 New
§15.7 Rename
§25.1 手動同期Sequence
```

Architecture / Public Classification / Sync Sequenceは変更しない。

---

# 3. §7.4 Patch

## 3.1 Metadata State Definitionを追加

§7.4の更新規則表の前に以下を追加する。

### 自動管理Metadataの初期状態

`TemplateLocation`、`FirstDetectedAt`、`LastDetectedAt` はSyncによって管理する。

初回Sync前からVariableDefinition行が存在する場合、以下の状態を正当な未初期化状態として扱う。

```text
Uninitialized Metadata

TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

これは、

```text
Template上で正常検出された履歴がまだない
```

ことを表す。

以下をInitialized Metadataとする。

```text
TemplateLocation = Subject / Body / Both
FirstDetectedAt   = Valid Date
LastDetectedAt    = Valid Date
```

一部のMetadataだけが設定されている状態はUninitialized Metadataとは扱わない。

```text
Partial Metadata
≠
Bootstrap State
```

Empty以外の不正値やPartial MetadataをBootstrap Ruleによって自動補正しない。

---

## 3.2 §7.4 更新規則表を置換

現行表を以下へ変更する。

| Sync状態                               | TemplateLocation | Status    | FirstDetectedAt | LastDetectedAt |
| ------------------------------------ | ---------------- | --------- | --------------- | -------------- |
| New                                  | 現在のScan結果        | Active    | SyncTimestamp   | SyncTimestamp  |
| Existing / Metadata Initialized      | 現在のScan結果へ更新     | Active維持  | 既存値保持           | SyncTimestamp  |
| Existing / Metadata Uninitialized    | 現在のScan結果へ更新     | Active維持  | SyncTimestamp   | SyncTimestamp  |
| Reactivated / Metadata Initialized   | 現在のScan結果へ更新     | Activeへ更新 | 既存値保持           | SyncTimestamp  |
| Reactivated / Metadata Uninitialized | 現在のScan結果へ更新     | Activeへ更新 | SyncTimestamp   | SyncTimestamp  |
| Unused化 / Metadata Initialized       | 最終検出Locationを保持  | Unusedへ更新 | 既存値保持           | 既存値保持          |
| Unused化 / Metadata Uninitialized     | Emptyを保持         | Unusedへ更新 | Emptyを保持        | Emptyを保持       |
| 既にUnused                             | 既存値保持            | Unused維持  | 既存値保持           | 既存値保持          |

補足：

```text
Current Template上でVariableを検出した
+
Metadataが未初期化
```

の場合、そのSyncをシステム上の最初の正常検出として扱う。

そのため、

```text
FirstDetectedAt = SyncTimestamp
```

とする。

一方、

```text
Current Template上にVariableが存在しない
```

Unused化では、そのSyncを検出履歴として扱わない。

したがって未初期化MetadataへSyncTimestampを設定しない。

`LastDetectedAt` は引き続き、

```text
最後にTemplate上で存在を確認した時刻
```

を意味し、Unused化した時刻ではない。

---

# 4. §15.4 Existing Patch

現行：

```text
FirstDetectedAtは保持し、
LastDetectedAtはSyncTimestampへ更新する。
```

を以下へ置換する。

### 15.4 Existing

既存ユーザー設定を保持し、同期処理で上書きしない。

DisplayName / Type / Required / Description / OptionSource / SortOrder / Format等のユーザー設定は保持する。

`TemplateLocation` は現在のTemplateScanResultへ更新する。

MetadataがInitializedの場合：

```text
FirstDetectedAt = 既存値保持
LastDetectedAt  = SyncTimestamp
```

MetadataがUninitializedの場合：

```text
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

とする。

VariableNameの表記は既存VariableDefinition側を正式表記として保持する。

---

# 5. §15.5 Reactivated Patch

現行：

```text
FirstDetectedAtは保持する。
TemplateLocationは現在のTemplateScanResultへ更新し、
LastDetectedAtはSyncTimestampへ更新する。
```

を以下へ置換する。

### 15.5 Reactivated

StatusをActiveへ戻し、既存設定を再利用する。

MetadataがInitializedの場合：

```text
FirstDetectedAt = 既存値保持
```

MetadataがUninitializedの場合：

```text
FirstDetectedAt = SyncTimestamp
```

とする。

共通して、

```text
TemplateLocation = 現在のTemplateScanResult
Status           = Active
LastDetectedAt   = SyncTimestamp
```

とする。

---

# 6. §15.6 Unused Patch

現行の「既存値保持」を明確化する。

### 15.6 Unused

StatusのみUnusedへ変更し、ユーザー設定値は保持する。

MetadataがInitializedの場合：

```text
TemplateLocation = 最終検出Location保持
FirstDetectedAt  = 既存値保持
LastDetectedAt   = 既存値保持
```

とする。

MetadataがUninitializedの場合：

```text
TemplateLocation = Empty
FirstDetectedAt  = Empty
LastDetectedAt   = Empty
```

をそのまま保持する。

Current Template上で検出していないVariableについて、

```text
FirstDetectedAt
LastDetectedAt
```

へ現在のSyncTimestampを設定してはならない。

既にUnusedのVariableについては従来どおりNo-opとする。

---

# 7. Responsibility Impact

Metadata Target Stateの計算責務は引き続き、

```text
P2-02 Sync Diff Core
```

に置く。

したがって、

```text
Existing / Reactivated
+
Uninitialized Metadata
↓
SyncTimestampによるBootstrap
```

はP2-02で計算する。

P2-03はこの判断を再計算しない。

---

# 8. Non-impact

以下は変更しない。

```text
4 Classification
New / Existing / Reactivated / Unused

Case-insensitive Identity

Canonical VariableName Rule

Rename Non-Inference

One Sync = One SyncTimestamp

User Configuration Preservation

Manual Sync Sequence

TemplateScanResult Structure

SyncDiffResult Structure
```

---

# 9. Document Impact

```text
MVP Requirements v0.1.9:
Change NOT REQUIRED

MVP Design:
v0.1.9
→ v0.1.10 Candidate

Implementation Plan v0.3:
Change NOT REQUIRED
```

`BL-MVP-003` 自体を上書きしない。

Design / Test Specification修正版のApproval後に、Baseline Manifest更新を別途実施する。

---

# 10. Patch Decision

```text
IF-P2-04-001 Design Patch:
DEFINED

Target:
MVP Design v0.1.10 Candidate

Scope:
§7.4
§15.4
§15.5
§15.6

Architecture Change:
NONE

Requirement Change:
NONE
```
