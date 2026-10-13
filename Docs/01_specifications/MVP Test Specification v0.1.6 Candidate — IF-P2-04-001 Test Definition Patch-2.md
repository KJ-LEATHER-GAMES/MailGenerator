# MVP Test Specification v0.1.6 Candidate

## IF-P2-04-001 Test Definition Patch

## 1. v0.1.6 更新概要

`DOC-MVP-DES v0.1.10 Candidate` で確定した `IF-P2-04-001 Initial Sync Metadata Bootstrap Gap` のDesign Gap ResolutionをTest Definitionへ反映する。

主な変更は以下とする。

1. `MTS-SYNC-003` にExistingのDetection History Initialized / Uninitialized Variantを追加する
2. `MTS-SYNC-004` にUnused化のDetection History Initialized / Uninitialized Variantを追加する
3. `MTS-SYNC-005` にReactivatedのDetection History Initialized / Uninitialized Variantを追加する
4. `MTS-SYNC-011` にDetection History State、Bootstrap、Invalid / Partial Failure、Already-Unused No-op、Common SyncTimestampのVariantを追加する
5. `TemplateLocation` とDetection History Stateを独立して確認する
6. Detection History Uninitializedは `FirstDetectedAt = Blank AND LastDetectedAt = Blank` とする
7. Detection History Invalid / PartialではVariableDefinitionを更新しないことを確認する
8. Invalid / Partial Detection HistoryはClassificationに依存しない共通Failure Guardとして確認する
9. Invalid / Partial Detection History時のError Result → UI通知 → Stopを既存 `MTS-ERR-001` と接続して確認する
10. 新規Test IDは追加しない
11. Test Case総数69件を維持する

本変更は `DOC-MVP-DES v0.1.10 Candidate` のSemantic Design Changeを既存Test Caseへ反映するSemantic Test Definition Updateである。

**Change Type：Semantic Test Definition Update**\
**Requirement Impact：None**\
**Design Impact：DOC-MVP-DES v0.1.10 Candidateを反映**\
**Test Case Count：69（変更なし）**\
**Formal Test Execution：NOT RUN**

---

# 2. §8.3 Baseline VariableDefinition

変更しない。

既存の以下を維持する。

```text
TemplateLocation / FirstDetectedAt / LastDetectedAtはSync Testで別途確認する。
```

Detection History用の初期状態は、各 `MTS-SYNC-*` Test VariantのPreconditionとして定義する。

---

# 3. MTS-SYNC-003 Existing設定保持 — 全文置換

## MTS-SYNC-003 Existing設定保持

**Traceability**

- FR-SYNC-003
- AC-004
- NFR-002
- Design §7.4
- Design §15.4

**共通Precondition**

VariableDefinitionに既存のActive Variableを用意し、以下のユーザー設定を持たせる。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

同一VariableNameをCurrent OFTにも配置する。

同期開始時に使用するTimestampを `TSync` とする。

### Variant A：Detection History Initialized

VariableDefinition：

```text
VariableName     = ModelName
Status           = Active
TemplateLocation = Body
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

Current OFT：

```text
ModelName Location = Subject
```

**Expected**

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = TFirst
LastDetectedAt   = TSync
```

以下のユーザー設定はすべて保持する。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

VariableNameの既存表記も保持する。

### Variant B：Detection History Uninitialized / Existing TemplateLocationあり

VariableDefinition：

```text
VariableName     = ModelName
Status           = Active
TemplateLocation = Body
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFT：

```text
ModelName Location = Subject
```

**Expected**

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

当該SyncをDetection History上の初回検出として扱う。

既存 `TemplateLocation = Body` が存在していてもDetection History Initializedとは判定しない。

以下のユーザー設定はすべて保持する。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

### Variant C：Detection History Uninitialized / TemplateLocation Blank

VariableDefinition：

```text
VariableName     = ModelName
Status           = Active
TemplateLocation = Blank
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFT：

```text
ModelName Location = Subject
```

**Expected**

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

Variant Bと同じDetection History Stateとして扱う。

以下のユーザー設定はすべて保持する。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

これにより、

```text
TemplateLocation State
≠
Detection History State
```

であることを確認する。

---

# 4. MTS-SYNC-004 Unused化 — 全文置換

## MTS-SYNC-004 Unused化

**Traceability**

- FR-SYNC-004
- AC-004
- Design §7.4
- Design §15.6

**共通Steps**

1. VariableDefinitionにActive Variableを用意する
2. Current OFTには当該Variableを存在させない
3. 手動同期を実行する

### Variant A：Detection History Initialized

Precondition：

```text
VariableName     = Department
Status           = Active
TemplateLocation = Both
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

**Expected**

```text
VariableDefinition行 = 存続
Status                = Unused
TemplateLocation      = Both
FirstDetectedAt       = TFirst
LastDetectedAt        = TLast
```

以下を確認する。

- ユーザー設定保持
- TemplateLocation保持
- FirstDetectedAt保持
- LastDetectedAt保持
- Unused化時刻でLastDetectedAtを上書きしない

### Variant B：Detection History Uninitialized

Precondition：

```text
VariableName     = Department
Status           = Active
TemplateLocation = Both
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFT：

```text
Department = 存在しない
```

**Expected**

```text
VariableDefinition行 = 存続
Status                = Unused
TemplateLocation      = Both
FirstDetectedAt       = Blank
LastDetectedAt        = Blank
```

以下を確認する。

- ユーザー設定保持
- 既存TemplateLocation保持
- Detection Timestampを新規生成しない
- `TSync` をFirstDetectedAt / LastDetectedAtへ設定しない

Unused化はTemplate上での検出イベントではないため、Detection Historyを開始しない。

---

# 5. MTS-SYNC-005 Reactivated — 全文置換

## MTS-SYNC-005 Reactivated

**Traceability**

- FR-SYNC-005
- Design §7.4
- Design §15.5

**共通Steps**

1. VariableDefinitionにUnused Variableを用意する
2. 同一VariableNameをCurrent OFTへ再追加する
3. 手動同期を実行する

同期開始時に使用するTimestampを `TSync` とする。

### Variant A：Detection History Initialized

Precondition：

```text
VariableName     = Department
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

Current OFT：

```text
Department Location = Subject
```

**Expected**

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = TFirst
LastDetectedAt   = TSync
```

以下を確認する。

- 既存ユーザー設定再利用
- FirstDetectedAt保持
- TemplateLocationをCurrent Locationへ更新
- LastDetectedAtをTSyncへ更新

### Variant B：Detection History Uninitialized

Precondition：

```text
VariableName     = Department
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFT：

```text
Department Location = Subject
```

**Expected**

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

再登場した当該SyncをDetection History上の初回検出として扱う。

既存 `TemplateLocation = Body` が存在していても、Blank / BlankのDetection HistoryはUninitializedとして扱う。

既存ユーザー設定は再利用する。

---

# 6. MTS-SYNC-011 Sync metadata更新 — 全文置換

## MTS-SYNC-011 Sync metadata更新

**Traceability**

- VariableDefinition要件
- Design §7.4
- Design §15.3
- Design §15.4
- Design §15.5
- Design §15.6
- Design §25.1

**Purpose**

以下を横断的に確認する。

```text
Detection History State
+
TemplateLocation Stateとの独立性
+
Sync ClassificationごとのMetadata Target State
+
Invalid / Partial Detection History Fail Closed
+
Common SyncTimestamp
```

### Variant A：New

Current OFTにのみVariableが存在する。

Sync Timestamp：

```text
TSync
```

**Expected**

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

### Variant B：Existing / Initialized

Precondition：

```text
Status           = Active
TemplateLocation = Existing Location
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

**Expected**

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = TFirst
LastDetectedAt   = TSync
```

### Variant C：Existing / Uninitialized / Locationあり

Precondition：

```text
Status           = Active
TemplateLocation = Subject
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

**Expected**

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

### Variant D：Existing / Uninitialized / Location Blank

Precondition：

```text
Status           = Active
TemplateLocation = Blank
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

**Expected**

Variant Cと同じDetection History Stateとして処理される。

```text
FirstDetectedAt = TSync
LastDetectedAt  = TSync
```

これによりDetection History Stateの判定がTemplateLocationに依存しないことを確認する。

### Variant E：Reactivated / Initialized

Precondition：

```text
Status           = Unused
TemplateLocation = Existing Location
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

Current OFTに当該Variableを存在させる。

**Expected**

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = TFirst
LastDetectedAt   = TSync
```

### Variant F：Reactivated / Uninitialized

Precondition：

```text
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFTに当該Variableを存在させる。

**Expected**

```text
TemplateLocation = Current Location
Status           = Active
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

### Variant G：Unused化 / Initialized

Precondition：

```text
Status           = Active
TemplateLocation = Both
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

Current OFTに当該Variableを存在させない。

**Expected**

```text
TemplateLocation = Both
Status           = Unused
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

### Variant H：Unused化 / Uninitialized

Precondition：

```text
Status           = Active
TemplateLocation = Both
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFTに当該Variableを存在させない。

**Expected**

```text
TemplateLocation = Both
Status           = Unused
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Detection Timestampを生成しない。

### Variant I：Already-Unused / Initialized

Precondition：

```text
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

Current OFTに当該Variableを存在させない。

**Expected**

```text
No-op
```

以下すべてを保持する。

```text
TemplateLocation = Body
Status           = Unused
FirstDetectedAt  = TFirst
LastDetectedAt   = TLast
```

### Variant J：Already-Unused / Uninitialized

Precondition：

```text
Status           = Unused
TemplateLocation = Body
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Current OFTに当該Variableを存在させない。

**Expected**

```text
No-op
```

以下を維持する。

```text
TemplateLocation = Body
Status           = Unused
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

Detection Timestampを生成しない。

### Invalid / Partial Variant共通適用条件

Variant K / L / Mは、既存VariableDefinition行を使用する以下すべてのSync Classificationへ適用する共通Failure Guardとして扱う。

```text
Existing
Reactivated
Unused化
Already-Unused
```

Detection HistoryがInvalid / Partialである場合は、Classificationごとの正常Metadata Target Stateへ進めない。

`TemplateLocation`、Status、Current Template PresenceによってInvalid / Partial Detection HistoryをBootstrap Stateへ読み替えない。

各代表入力について少なくとも1 Classificationで直接実行し、あわせて共通Guardが上記Classificationに依存しないことを確認する。

### Variant K：Invalid / Partial — First Blank / Last Date

Precondition：

```text
FirstDetectedAt = Blank
LastDetectedAt  = TLast
```

**Expected**

```text
Sync Result:
Failure

VariableDefinition Persistence:
NONE
```

正当なDetection History Uninitializedとは扱わない。

Classificationごとの正常Target Stateへ進まない。

Error ResultはUI通知へ接続し、後続処理を停止する。

UI通知のEvidenceは `MTS-ERR-001 Invalid / Partial Detection History` と併せて確認する。

### Variant L：Invalid / Partial — First Date / Last Blank

Precondition：

```text
FirstDetectedAt = TFirst
LastDetectedAt  = Blank
```

**Expected**

```text
Sync Result:
Failure

VariableDefinition Persistence:
NONE
```

正当なDetection History Uninitializedとは扱わない。

Classificationごとの正常Target Stateへ進まない。

Error ResultはUI通知へ接続し、後続処理を停止する。

UI通知のEvidenceは `MTS-ERR-001 Invalid / Partial Detection History` と併せて確認する。

### Variant M：Invalid non-blank Detection Value

代表例：

```text
FirstDetectedAt = "invalid-date"
LastDetectedAt  = TLast
```

または、

```text
FirstDetectedAt = TFirst
LastDetectedAt  = "invalid-date"
```

**Expected**

```text
Sync Result:
Failure

VariableDefinition Persistence:
NONE
```

Classificationごとの正常Target Stateへ進まない。

Error ResultはUI通知へ接続し、後続処理を停止する。

UI通知のEvidenceは `MTS-ERR-001 Invalid / Partial Detection History` と併せて確認する。

具体的ErrorTypeは本Testでは固定しない。

### Variant N：Common SyncTimestamp / Mixed Classification

同一Manual Sync内に少なくとも以下を混在させる。

```text
New
Existing / Initialized
Existing / Uninitialized
Reactivated / Initialized
Reactivated / Uninitialized
Unused
```

Sync開始時Timestamp：

```text
TSync
```

**Expected**

当該Syncで新規設定または更新されるDetection Timestampはすべて同一 `TSync` を使用する。

例：

```text
New
FirstDetectedAt = TSync
LastDetectedAt  = TSync

Existing / Initialized
FirstDetectedAt = Existing
LastDetectedAt  = TSync

Existing / Uninitialized
FirstDetectedAt = TSync
LastDetectedAt  = TSync

Reactivated / Initialized
FirstDetectedAt = Existing
LastDetectedAt  = TSync

Reactivated / Uninitialized
FirstDetectedAt = TSync
LastDetectedAt  = TSync
```

Unused / Already-UnusedではDesign Ruleに従いDetection Timestampを更新しない。

## Evidence

各Variantでは最低限以下を記録する。

```text
Initial Status
Initial TemplateLocation
Initial FirstDetectedAt
Initial LastDetectedAt

Current Template Presence
Current TemplateLocation

SyncTimestamp

Result Success / Failure

Final Status
Final TemplateLocation
Final FirstDetectedAt
Final LastDetectedAt

VariableDefinition Write有無
```

Invalid / Partial Variantでは追加で以下を記録する。

```text
ClassificationまたはClassification候補
Error Result有無
UI通知有無
後続Persistence実行有無
```

Initialized / Uninitialized Variantでは、必要に応じてユーザー設定列のBefore / Afterも記録する。

---

# 7. MTS-ERR-001 主要Error Message — 局所Patch

既存の代表Error一覧へ以下を追加する。

```text
Invalid / Partial Detection History
```

追加後の代表Error一覧：

```text
OFT不存在
Workbook Relative Path / OneDrive Local Path Resolution Error
Invalid Variable
Configuration不足
Invalid / Partial Detection History
Input Validation
Unresolved Variable
Classic Outlook Startup / Explorer Initialization Error
Outlook Error
```

### Invalid / Partial Detection History

`MTS-SYNC-011 Variant K / L / M` で検出したInvalid / Partial Detection Historyについて、Error ResultがUI通知へ接続されることを確認する。

**Expected**

- 技術エラー文字列だけで終了しない
- Detection Historyに問題があることをユーザーが理解できる
- 問題対象を識別可能なMessage / Targetを持つ
- Error Result後にVariableDefinition Persistenceへ進まない
- Error Result後に正常Sync完了として扱わない
- 具体的ErrorTypeは本Testでは固定しない

本Variantでは新しいErrorType、Message文言、Target値を定義しない。

Design §24および§25.1で既に定義されたError Result → UI通知 → Stopの成立のみを確認する。

---

# 8. Test Definition Boundary

本Revisionでは以下を行わない。

```text
新規MTS ID追加
Formal Test実行
Formal MTS-SYNC PASS判定
Production Test Code実装
P2-02 / P2-03 Implementation Detail決定
ErrorTypeの新規Design
Requirement変更
Design変更
```

今回定義するVariantは、後続Implementation VerificationおよびP7後のFormal MVP Testの双方で使用可能なTest Definitionとする。

---

# 9. Patch Result

```text
CR-TS-001:
APPLIED
- MTS-SYNC-011 K/L/MをClassification非依存の共通Failure Guardとして明示

CR-TS-002:
APPLIED
- MTS-SYNC-003 Variant CへExistingユーザー設定保持Expectedを追加

CR-TS-003:
APPLIED
- MTS-SYNC-011 K/L/MとMTS-ERR-001を接続
- Error Result → UI通知 → Stopを明示

New Test ID:
NONE

Test Case Count:
69

Formal Test:
NOT RUN

Result:
MVP Test Specification v0.1.6 Candidate CORRECTED
```
