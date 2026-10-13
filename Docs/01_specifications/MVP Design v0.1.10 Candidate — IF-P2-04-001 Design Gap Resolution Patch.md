# MVP Design v0.1.10 Candidate

## IF-P2-04-001 Initial Sync Metadata Bootstrap Gap Resolution Patch

### 1. Revision Summaryへの追加

`v0.1.9 更新概要` の前へ以下を追加する。

### v0.1.10 更新概要

P2-04 Manual Sync Local Verificationで検出した `IF-P2-04-001 Initial Sync Metadata Bootstrap Gap` を解消するため、Initial Sync前から存在するVariableDefinition行に対するDetection History Bootstrap Ruleを追加した。

実Workbookでは、以下の状態が存在することを確認した。

```text
TemplateLocation = Subject / Body / Both
FirstDetectedAt   = Blank
LastDetectedAt    = Blank
```

従来Designでは `TemplateLocation` とDetection Timestampの初期化状態を明確に分離しておらず、Existing / Reactivatedに対して `FirstDetectedAt = 既存値保持` としていたため、この状態からDetection Historyを開始する規則が未定義であった。

v0.1.10では以下を確定する。

1. `TemplateLocation` の状態とDetection Historyの初期化状態を独立して扱う
2. `FirstDetectedAt = Blank AND LastDetectedAt = Blank` を正当な `Detection History Uninitialized` 状態として扱う
3. Existing / ReactivatedでDetection HistoryがUninitializedの場合、当該Syncを初回検出として `FirstDetectedAt / LastDetectedAt = SyncTimestamp` に初期化する
4. Unused化 / Already-UnusedでDetection HistoryがUninitializedの場合、Template上で検出していないためDetection Timestampを新規生成しない
5. Unused化 / Already-Unusedでは既存 `TemplateLocation` を保持する
6. `FirstDetectedAt` / `LastDetectedAt` の片側のみがBlankである状態、または非Blankの不正Date値を含む状態は `Invalid / Partial Detection History` としてFailureとする
7. P2-02 Sync EngineがDetection History State判定とTarget State計算を担当し、P2-03 VariableDefinition Data AccessはTarget StateのValidation / Persistenceのみを担当する

本変更は、既存Requirementを変更せず、未定義だったSystem-managed MetadataのBootstrap挙動をDesignとして確定するSemantic Design Changeである。

**Change Type：Semantic Design Change**\
**Requirement Impact：None**\
**Test Specification Impact：Required**\
**Implementation Impact：P2-02 / P2-03**\
**P2-04 Production Impact：None at present**\
**Technical Spike Reopen：Not Required**

---

## 2. §7.4 自動管理列の更新規則 — 全文置換

### 7.4 自動管理列の更新規則

`TemplateLocation`、`Status`、`FirstDetectedAt`、`LastDetectedAt` はユーザー設定値ではなく、Template Scan / Sync結果からシステムが更新する。

同期処理開始時に1つの `SyncTimestamp` を取得し、同一Sync内では共通して使用する。

#### Detection History State

`FirstDetectedAt` / `LastDetectedAt` はDetection Historyとして対で扱う。

Detection History Stateは以下とする。

| FirstDetectedAt   | LastDetectedAt    | State             |
| ----------------- | ----------------- | ----------------- |
| Valid Date        | Valid Date        | Initialized       |
| Blank             | Blank             | Uninitialized     |
| Blank             | Valid Date        | Invalid / Partial |
| Valid Date        | Blank             | Invalid / Partial |
| Invalid non-blank | 任意                | Invalid           |
| 任意                | Invalid non-blank | Invalid           |

`Detection History Uninitialized` はInitial Sync前から存在するVariableDefinition行で許容する正当なBootstrap Stateであり、Configuration破損とは扱わない。

`Invalid / Partial Detection History` は正当なBootstrap Stateとは扱わず、Sync処理をFailureとしてVariableDefinition更新へ進めない。

#### TemplateLocationとの独立性

`TemplateLocation` の現在値とDetection History Stateは独立して扱う。

したがって、以下は正当なDetection History Uninitialized Stateとなり得る。

```text
TemplateLocation = Blank / Subject / Body / Both
FirstDetectedAt   = Blank
LastDetectedAt    = Blank
```

`TemplateLocation` に既存値が存在することだけを理由として、Detection HistoryをInitializedとは判定しない。

同様に、`TemplateLocation` がBlankであることだけを理由として、Detection HistoryをUninitializedとは判定しない。

#### Sync状態別更新規則

| Sync状態      | Detection History | TemplateLocation | Status    | FirstDetectedAt | LastDetectedAt |
| ----------- | ----------------- | ---------------- | --------- | --------------- | -------------- |
| New         | N/A               | 現在のScan結果        | Active    | SyncTimestamp   | SyncTimestamp  |
| Existing    | Initialized       | 現在のScan結果へ更新     | Active維持  | 既存値保持           | SyncTimestamp  |
| Existing    | Uninitialized     | 現在のScan結果へ更新     | Active維持  | SyncTimestamp   | SyncTimestamp  |
| Reactivated | Initialized       | 現在のScan結果へ更新     | Activeへ更新 | 既存値保持           | SyncTimestamp  |
| Reactivated | Uninitialized     | 現在のScan結果へ更新     | Activeへ更新 | SyncTimestamp   | SyncTimestamp  |
| Unused化     | Initialized       | 既存値保持            | Unusedへ更新 | 既存値保持           | 既存値保持          |
| Unused化     | Uninitialized     | 既存値保持            | Unusedへ更新 | Blank維持         | Blank維持        |
| 既にUnused    | Initialized       | 既存値保持            | Unused維持  | 既存値保持           | 既存値保持          |
| 既にUnused    | Uninitialized     | 既存値保持            | Unused維持  | Blank維持         | Blank維持        |

`LastDetectedAt` は「最後にTemplate上で存在を確認した時刻」であり、Unused化した時刻ではない。

したがって、Current Template上でVariableを検出していないUnused化 / Already-Unused処理では、Detection HistoryがUninitializedであっても新しいDetection Timestampを生成しない。

Existing / ReactivatedでDetection HistoryがUninitializedの場合は、Current Template上でVariableを実際に検出した当該SyncをDetection History上の初回検出として扱い、`FirstDetectedAt` / `LastDetectedAt` の双方へ同一 `SyncTimestamp` を設定する。

---

## 3. §15.4 Existing — 全文置換

### 15.4 Existing

既存ユーザー設定を保持し、同期処理で上書きしない。

DisplayName / Type / Required / Description / OptionSource / SortOrder / Format等のユーザー設定は保持する。

`TemplateLocation` は現在のTemplateScanResultへ更新する。

Detection HistoryがInitializedの場合：

```text
FirstDetectedAt = 既存値保持
LastDetectedAt  = SyncTimestamp
```

Detection HistoryがUninitializedの場合：

```text
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

この場合、当該SyncをDetection History上の初回検出として扱う。

Detection HistoryがInvalid / Partialの場合はFailureとし、VariableDefinition更新へ進めない。

VariableNameの表記は既存VariableDefinition側を正式表記として保持する。

---

## 4. §15.5 Reactivated — 全文置換

### 15.5 Reactivated

StatusをActiveへ戻し、既存設定を再利用する。

`TemplateLocation` は現在のTemplateScanResultへ更新する。

Detection HistoryがInitializedの場合：

```text
FirstDetectedAt = 既存値保持
LastDetectedAt  = SyncTimestamp
```

Detection HistoryがUninitializedの場合：

```text
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

この場合、再登場した当該SyncをDetection History上の初回検出として扱う。

Detection HistoryがInvalid / Partialの場合はFailureとし、VariableDefinition更新へ進めない。

---

## 5. §15.6 Unused — 全文置換

### 15.6 Unused

Current Template上に存在しないActive VariableはStatusをUnusedへ変更し、既存ユーザー設定を保持する。

`TemplateLocation` は既存値を保持する。

Detection HistoryがInitializedの場合：

```text
FirstDetectedAt = 既存値保持
LastDetectedAt  = 既存値保持
```

Detection HistoryがUninitializedの場合：

```text
FirstDetectedAt = Blank維持
LastDetectedAt  = Blank維持
```

Unused化はTemplate上での検出イベントではないため、Detection HistoryがUninitializedであっても `SyncTimestamp` を新規設定しない。

既にUnusedでCurrent Templateにも存在しないVariableはNo-opとし、`TemplateLocation`、`Status`、`FirstDetectedAt`、`LastDetectedAt` を変更しない。

ただし、Unused化 / Already-UnusedのいずれでもDetection HistoryがInvalid / Partialの場合は正当なBootstrap Stateとは扱わずFailureとし、VariableDefinition更新へ進めない。

---

## 6. §25.1 手動同期 — Sync Engine部分のみ局所修正

既存の以下：

```text
VariableDefinition Data Access
    ↓
Template Dictionary / Definition Dictionary
    ↓
Sync Engine
    ↓
New / Existing / Reactivated / Unused判定
    ↓
VariableDefinition更新
```

を以下へ置換する。

```text
VariableDefinition Data Access
    ↓
Template Dictionary / Definition Dictionary
    ↓
Sync Engine
    ↓
Detection History State確認
    ↓
Invalid / Partialあり？
├─ Yes → Error Result → UI通知 → Stop
└─ No
    ↓
New / Existing / Reactivated / Unused判定
+
Metadata Target State計算
    ↓
VariableDefinition更新
```

Sync EngineはClassificationおよびMetadata Target Stateを決定する。

VariableDefinition Data AccessはSync Engineが決定したTarget StateをValidation / Persistenceし、Classification、Detection History State、SyncTimestamp、Metadata Meaningを再計算しない。

---

## 7. 変更しない箇所

以下は本Revisionでは変更しない。

```text
§15.1 比較方式
§15.2 差分分類
§15.3 New
§15.7 Rename
§24 エラー設計のErrorType体系
§27 Design Decision一覧
```

NewのMetadata Ruleは既に、

```text
TemplateLocation = Current
Status           = Active
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

として成立しているため変更しない。

Renameも従来どおり、

```text
Old Variable → Unused
New Variable → New
```

として扱い、自動Rename推測は行わない。

新規Design Decision IDは追加しない。

今回の変更は新しいArchitecture / Technology / Alternativeを選択するDecisionではなく、既存Sync Designの未定義状態を補完するDesign Gap Resolutionとして扱う。

---

## 8. Responsibility Boundary

本Revision後の責務境界を以下で固定する。

```text
P2-02 / Sync Engine
├─ New / Existing / Reactivated / Unused Classification
├─ Detection History State判定
├─ Bootstrap Detection
├─ Metadata Target State Calculation
└─ SyncTimestampのTarget State適用

P2-03 / VariableDefinition Data Access
├─ P2-02 Target State Validation
└─ Persistence
```

P2-03では以下を行わない。

```text
Classification再計算
Detection History再判定による意味変更
SyncTimestamp再取得
Bootstrap Timestamp生成
Metadata Meaning再定義
Rename推測
```

---

## 9. IF-P2-04-001 Resolution Result

```text
Finding:
IF-P2-04-001

Finding Name:
Initial Sync Metadata Bootstrap Gap

Primary Classification:
Design Gap

Root Cause:
TemplateLocation state and Detection History initialization state
were implicitly treated as one metadata initialization state,
leaving valid pre-existing VariableDefinition rows with blank
Detection Timestamp history undefined.

Resolution:
TemplateLocation and Detection History are modeled independently.
Blank / Blank Detection Timestamp is a valid Uninitialized state.
Existing / Reactivated bootstrap Detection History on actual detection.
Unused / Already-Unused do not synthesize detection timestamps.

Requirement Gap:
NONE

P2-04 Production Defect:
NONE

Design Change:
REQUIRED / RESOLVED BY DOC-MVP-DES v0.1.10

Test Specification Impact:
REQUIRED

P2-02 Implementation Impact:
REQUIRED

P2-03 Implementation Impact:
REQUIRED

Technical Spike Reopen:
NOT REQUIRED
```
