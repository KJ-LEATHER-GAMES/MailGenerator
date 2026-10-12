# 引き継ぎまとめ

## 実施内容

- P2-02 `Sync Diff Core` について、Approved仕様を基準にProduction Implementationを実施した。
- Production Moduleとして以下を新規作成した。
  - `modSyncEngine_P2-02_v0.1_CP932.bas`
- Public APIは以下1本に限定した。

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

- `BuildSyncDiff()` のInputを以下に固定した。
  - `templateScanResult`
  - `currentDefinitions`
  - `syncTimestamp`
- Outputとして以下の`SyncDiffResult`を生成する実装とした。

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

- 各Diff Itemは以下5項目のみを保持する。

  - `VariableName`
  - `TemplateLocation`
  - `Status`
  - `FirstDetectedAt`
  - `LastDetectedAt`

- P2-02 Productionで以下を実装した。

  - Case InsensitiveなVariableName比較
  - `Scripting.Dictionary` Late Binding
  - `CompareMode = vbTextCompare`
  - New判定
  - Existing判定
  - Reactivated判定
  - Unused判定
  - Already-Unused = No-op
  - Rename非推測
  - Old Variable → Unused
  - New Variable → New
  - Existing / Reactivated / Unusedで既存VariableDefinition側の表記をCanonical VariableNameとして維持
  - NewではScanner側の表記を採用
  - Metadata Target State計算
  - 同一Syncの`syncTimestamp`利用
  - Input Immutability
  - User Configuration列をDiff Outputから除外
  - Defensive Contract Guard
  - Runtime Errorの`COperationResult`化

- P2-02では意図的に以下を実装しなかった。

  - Excelへの書き込み
  - VariableDefinition行追加・更新
  - `__RowIndex`利用
  - Manual Sync Orchestration
  - Sync Result UI
  - User Notification
  - OFT存在確認
  - 最終Fail Closed
  - `Now` / `Date()` / `Time()`によるTimestamp取得
  - Rename推測
  - User Configuration再計算

- Core Test Artifactを作成した。

  - 初版：
    - `modP2_02SyncDiffCoreTest_v0.1_CP932.bas`
  - 修正版：
    - `modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas`

- Core Test C1～C18を実装した。

  - C1 New
  - C2 Existing
  - C3 Reactivated
  - C4 Unused
  - C5 Already-Unused No-op
  - C6 Case Insensitive Existing
  - C7 Case Insensitive Reactivated
  - C8 Existing Canonical Name Preservation
  - C9 Rename = Old Unused + New
  - C10 Mixed Classification
  - C11 New Metadata
  - C12 Existing Metadata
  - C13 Reactivated Metadata
  - C14 Unused Metadata
  - C15 Common SyncTimestamp
  - C16 User Config / Input Immutability
  - C17 Empty Template Active → Unused
  - C18 Empty Template Unused → No-op

- Core Test初回Compile時に以下のエラーを検出した。

```text
コンパイルエラー:
配列がありません
```

- 代表箇所：

```vb
Dim t0 As Date
...
t0 = T0()
```

- 原因を特定した。

  - VBAは大文字・小文字を区別しない。
  - Local Variable `t0` / `t1` がModule-level Function `T0()` / `T1()` をshadowしていた。
  - `T0()`がFunction CallではなくLocal Variableに対する配列参照として解釈されていた。

- この不具合を以下として分類した。

```text
TF-P2-02-001
Classification:
Test Artifact Defect
```

- Production `modSyncEngine`には問題なしと判定した。

```text
Production Defect:
NONE
```

- 修正方針としてLocal Variableのみ改名した。

```text
t0
→ firstDetectedAt

t1
→ lastDetectedAt
```

- Function `T0()` / `T1()` は変更しなかった。

- 修正版Test Artifact：

  - `modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas`

- Correction Record：

  - `TF-P2-02-001 Core Test Local Name Collision Correction v0.1.md`

- Core Testを再実行し、以下の結果を確認した。

```text
PASS Count: 18
FAIL Count: 0
Overall: PASS
```

- Technical Negative Verification用Artifactを作成した。

  - `modP2_02SyncDiffNegativeTest_v0.1_CP932.bas`

- Entry Point：

  - `TestP202SyncDiffTechnicalNegative`

- Technical Negative N1～N6を実行した。

  - N1 `TemplateScanResult = Nothing`
  - N2 `CurrentDefinitions = Nothing`
  - N3 `InvalidCandidates > 0`
  - N4 Duplicate Definition Identity
  - N5 Unknown Status
  - N6 Scan Structural Invariant

- 結果：

```text
PASS Count: 6
FAIL Count: 0
Overall: PASS
```

- Contract Compatibility Test Artifactを作成した。

  - `modP2_02SyncDiffCompatibilityTest_v0.1_CP932.bas`

- Entry Point：

  - `TestP202SyncDiffContractCompatibility`

- 実Production Carrier同士のCompatibilityを確認した。

  - K1 P2-01 `ScanTemplate` Carrier
  - K2 P0 `GetAllVariableDefinitions` Carrier

- 結果：

```text
PASS Count: 2
FAIL Count: 0
Overall: PASS
```

- K1により以下の実Production接続を確認した。

```text
P2-01 modTemplateScanner.ScanTemplate
↓
TemplateScanResult
↓
P2-02 modSyncEngine.BuildSyncDiff
```

- K2により以下の実Production接続を確認した。

```text
P0 modVariableDefinitionData.GetAllVariableDefinitions
↓
Collection + Dictionary
↓
P2-02 modSyncEngine.BuildSyncDiff
```

- VBA Compileについて、最終的に以下をユーザー側で確認済み。

```text
Debug
→ Compile VBAProject
→ PASS
```

- Production Implementation Recordを作成した。

  - `P2-02 Sync Diff Core Production Implementation Record v0.1.md`

- Production Implementation一式ZIPを作成した。

  - `P2-02 Sync Diff Core Production Implementation Package v0.1.zip`

- Finding Assessmentを作成した。

  - `P2-02 Sync Diff Core Finding Assessment v0.1.md`

- Finding Assessmentでは以下を最終判定した。

```text
Implementation Defect:
NONE

Test Artifact Defect:
TF-P2-02-001 -> RESOLVED / CLOSED

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Technical Finding:
NONE

Contract Compatibility Finding:
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

- `TF-P2-02-001`について、Correction後のC1～C18再実行、Negative、CompatibilityがすべてPASSしたため、

```text
RESOLVED / CLOSED
```

とした。

- Production Patch Reviewを実施した。

  - `P2-02 Sync Diff Core Production Patch Review v0.1.md`

- Approved仕様 §69 Static Review Checklistに対して、`modSyncEngine_P2-02_v0.1_CP932.bas`を最終照合した。

- Static Reviewは23項目すべてPASS。

```text
PASS:
23

FAIL:
0

NOT REVIEWED:
0

Overall:
PASS
```

- 主な確認内容：

  - Public APIは`BuildSyncDiff` 1本のみ
  - Excel Object依存なし
  - Outlook / Word COM依存なし
  - Late Bound Dictionary
  - `CompareMode = vbTextCompare`
  - Input Result変更なし
  - Current Definition変更なし
  - New Canonical = Scanner表記
  - Existing Canonical = Definition表記
  - Reactivated Canonical = Definition表記
  - Unused Canonical = Definition表記
  - Already-Unused = No-op
  - Rename推測なし
  - SyncTimestamp内部取得なし
  - New Metadata Rule一致
  - Existing Metadata Rule一致
  - Reactivated Metadata Rule一致
  - Unused Metadata Rule一致
  - User ConfigurationをOutputへ含めない
  - `__RowIndex`未使用
  - Classification重複なし
  - Test専用Public APIなし
  - Production Variable Hard Codingなし

- Production Patch Review最終結果：

```text
Approved Specification §69 Checklist:
23 / 23 PASS

VBA Compile:
PASS

Core Verification:
18 / 18 PASS

Technical Negative Verification:
6 / 6 PASS

Contract Compatibility:
2 / 2 PASS

TF-P2-02-001:
RESOLVED / CLOSED

Production Defect:
NONE

Production Change Required After Review:
NONE

Blocking Finding:
0

RESULT:
PASS
```

- Production Candidateは変更せず以下で確定した。

```text
modSyncEngine_P2-02_v0.1_CP932.bas
```

- Version Bumpも不要とした。

- 最後にCompletion Recordを作成した。

  - `P2-02 Sync Diff Core Completion Record v0.1.md`

- Completion Criteriaを最終確認した。

```text
Approved Unit Specification                      PASS
VBA Compile                                      PASS
modSyncEngine Production Implementation          PASS
C1-C18 = 18 / 18 PASS                            PASS
P2-01 Contract Compatibility                     PASS
P0 VariableDefinition Carrier Compatibility      PASS
Production Patch Review                          PASS
Finding Assessment                               PASS
Blocking Finding = 0                             PASS
```

- Supplementary Verification：

```text
Technical Negative N1-N6 = 6 / 6 PASS
TF-P2-02-001 = RESOLVED / CLOSED
```

- Completion Criteria：

```text
ALL PASS
```

- 最終的にP2-02を正式Closeした。

```text
P2-02 Sync Diff Core
PASS / COMPLETE
```

---

## 決定事項

- P2-02のProduction Moduleは以下で確定。

```text
modSyncEngine
```

- Final Production Artifactは以下。

```text
modSyncEngine_P2-02_v0.1_CP932.bas
```

- Production Public APIは以下1本。

```vb
BuildSyncDiff(
    templateScanResult,
    currentDefinitions,
    syncTimestamp,
    syncDiffResult
) As COperationResult
```

- P2-02のInputは以下3つ。

  - `TemplateScanResult`
  - Current VariableDefinitions
  - Callerから渡される`SyncTimestamp`

- P2-02自身は`Now`等でTimestampを取得しない。

- Public Classificationは4種類のみ。

```text
New
Existing
Reactivated
Unused
```

- `Already-Unused`は5番目のClassificationにしない。

  - No-op
  - Output Itemなし

- Rename Classificationは作らない。

```text
Old Variable
→ Unused

New Variable
→ New
```

- VariableName IdentityはCase Insensitive。

- Canonical VariableNameは以下。

  - New：
    - Scanner側の表記
  - Existing：
    - Existing VariableDefinition側の表記
  - Reactivated：
    - Existing VariableDefinition側の表記
  - Unused：
    - Existing VariableDefinition側の表記

- P2-02がTarget Stateを計算する自動管理項目は以下。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

- P2-02 OutputにはUser Configurationを含めない。

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

- Existing等のUser ConfigurationはP2-02では変更しない。

- Metadata Ruleは以下で確定。

```text
New:
TemplateLocation = current
Status = Active
FirstDetectedAt = SyncTimestamp
LastDetectedAt = SyncTimestamp

Existing:
TemplateLocation = current
Status = Active
FirstDetectedAt = keep
LastDetectedAt = SyncTimestamp

Reactivated:
TemplateLocation = current
Status = Active
FirstDetectedAt = keep
LastDetectedAt = SyncTimestamp

Unused:
TemplateLocation = keep
Status = Unused
FirstDetectedAt = keep
LastDetectedAt = keep

Already-Unused:
No-op
```

- `LastDetectedAt`はUnused化時刻ではなく、「最後にTemplate上で存在確認した時刻」とする。

- P2-02ではInputを変更しない。

  - `templateScanResult`
  - `currentDefinitions`
  - 各Definition Dictionary

- P2-02はExcel Persistenceを担当しない。

- `__RowIndex`をP2-02で使用しない。

- `InvalidCandidates > 0`時のP2-02チェックは、

  - Defensive Precondition / Contract Guard
  - Manual Sync全体の正式Fail Closed責務ではない

- FR-SYNC-008 / MTS-SYNC-010の正式なFail Closedは後続Application / Integration側に残す。

- P2-02 VerificationはFormal MVP Testではない。

```text
C1-C18 PASS
≠
MTS-SYNC-* Formal PASS
```

- `TF-P2-02-001`は以下で確定。

```text
Classification:
Test Artifact Defect

Status:
RESOLVED / CLOSED
```

- Production `modSyncEngine`へのCorrectionは不要。

- Requirement Gapなし。

```text
Requirement Gap:
NONE
```

- Design Findingなし。

```text
Design Finding:
NONE
```

- Technical Spike再開不要。

```text
Technical Spike Reopen:
NOT REQUIRED
```

- Baseline変更不要。

```text
Baseline Change:
NOT REQUIRED
```

- Current Execution Baselineは引き続き、

```text
BL-MVP-003
```

- P2-02 Completionに伴うRequirements / Design / Test Specification / Implementation PlanのVersion Upは不要。

- P2-02最終判定：

```text
PASS / COMPLETE
```

- ただし以下は明確に区別する。

```text
P2-02 COMPLETE
≠
P2 Phase COMPLETE
≠
CP-P2 ESTABLISHED
```

- 次のImplementation Unitは、

```text
P2-03 VariableDefinition Sync Persistence
```

とする。

- P2-03はP2-02の`SyncDiffResult`をPersistenceする責務に限定する。

- P2-03では以下を再計算しない方針。

```text
Classification
Canonical VariableName
SyncTimestamp
Rename Inference
Metadata Meaning
```

- 次の正式アクションはP2-03の実装ではなく、

```text
P2-03 Boundary Confirmation
```

から開始する。

---

## 未解決事項

### 1. P2-03 VariableDefinition Sync Persistenceの詳細Boundary

未確定。

次チャットで確認が必要。

主な論点：

```text
SyncDiffResult
↓
VariableDefinition Persistence
```

において、

- NewをどのようにListObjectへ追加するか
- Existingをどの列だけ更新するか
- Reactivatedをどの列だけ更新するか
- Unusedをどの列だけ更新するか
- `__RowIndex`をどこまで利用するか
- Existing / Reactivated / Unusedの対象行特定方法
- New行追加後のRow Index扱い
- Excel書き込み順序
- Partial Write防止
- Write途中Failure時の整合性
- RollbackをMVPで行うか
- Write前ValidationをどこまでP2-03で持つか
- P2-03がDefensive Contract Guardとして何を確認するか
- `SyncDiffResult`が不正な場合の扱い
- 既存`modVariableDefinitionData`へどのPublic APIを追加するか
- 1件ずつWriteするか、一括適用APIにするか
- New VariableのUser Configuration初期値をどのようにExcelへ書くか
- Empty / Blank / Nullの扱い
- Excel Date値の保存形式
- `FirstDetectedAt` / `LastDetectedAt`をVariantのまま扱うか
- Persistence時に`SyncTimestamp`を再取得しないことの保証方法

### 2. P2-03 Error / Atomicity Boundary

未確定。

特に要確認：

```text
複数Diff Itemのうち途中でWrite Failure
```

が起きた場合に、

- 途中まで更新済みを許容するか
- 事前ValidationでFail Closedを強化するか
- Transaction相当のRollbackを作るか
- MVPではRollbackを作らず、Application側で事前条件を厳格にするか

についてはまだ決定していない。

### 3. P2-03とP2-04の責任分離

まだ詳細未確定。

現在の予定：

```text
P2-03
VariableDefinition Sync Persistence

P2-04
Manual Sync Integration
```

ただし、

- P2-03がどこまでData Access APIを持つか
- P2-04がどこからOrchestrationを引き受けるか
- `syncTimestamp`をどのLayerで取得するか
- P2-03へ渡す入力Carrier
- Result集約方法

はBoundary Confirmationで確定する必要がある。

### 4. P2-05 Fail Closed / Sync Result / Phase Integration

未着手。

残っている論点：

```text
OFT不存在
InvalidCandidates
Current Definition Read Failure
Persistence Failure
Sync Result
User Notification
Manual Sync End-to-End
P2 Phase Verification
```

### 5. CP-P2

未成立。

```text
CP-P2:
NOT YET ESTABLISHED
```

P2-03～P2-05およびP2 Phase Verification完了後に判定する。

### 6. Formal MVP Test

未実施。

現在のEvidence：

```text
Implementation Verification
Unit Completion Evidence
Static Review
Contract Compatibility
```

であり、

```text
MTS-SYNC-* Formal PASS
```

ではない。

Formal TestはP7後のTest Candidate Buildに対して実施する。

---

## 次アクション

### 優先度1：P2-03 Boundary Confirmation

次チャットでは最初に以下を確認する。

```text
P2-03 VariableDefinition Sync Persistence
```

いきなりProduction実装へ進まない。

最初に固定すべきもの：

```text
Input
Output
責務
非責務
Persistence対象Field
対象行識別
New Row追加
Existing Row更新
Failure Boundary
Partial Update Boundary
P2-04との境界
```

### 優先度2：P2-02成果物をInputとして確認

最初に参照するファイル：

1. `P2-02 Sync Diff Core Completion Record v0.1.md`
2. `P2-02 Sync Diff Core Production Patch Review v0.1.md`
3. `P2-02 Sync Diff Core Finding Assessment v0.1.md`
4. `P2-02 Sync Diff Core 実施仕様 v0.1 — Approved`
5. `P2-02 Sync Diff Core Boundary Confirmation v0.1.md`
6. `modSyncEngine_P2-02_v0.1_CP932.bas`

特に確認するContract：

```text
SyncDiffResult
├─ New
├─ Existing
├─ Reactivated
└─ Unused
```

各Item：

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

### 優先度3：既存VariableDefinition Data Accessを確認

P2-03ではP0で作成済みの、

```text
modVariableDefinitionData
```

を拡張する可能性が高い。

確認対象：

```vb
GetAllVariableDefinitions(...)
GetActiveVariableDefinitions(...)
```

既存Carrier：

```text
Collection
└─ Dictionary
   ├─ VariableName
   ├─ DisplayName
   ├─ Type
   ├─ Required
   ├─ Description
   ├─ OptionSource
   ├─ SortOrder
   ├─ Format
   ├─ TemplateLocation
   ├─ Status
   ├─ FirstDetectedAt
   ├─ LastDetectedAt
   └─ __RowIndex
```

P0ではRead専用だったため、P2-03でWrite APIを追加する場合は責務とPublic APIを明示的に決める。

### 優先度4：Baseline文書との整合確認

P2-03 Boundary Confirmation時に最低限確認する。

- `MVP Requirements v0.1.9 日本語版.md`
  - FR-SYNC-002～006
  - VariableDefinition列
- `MVP Design v0.1.9 日本語版.md`
  - §7.4 自動管理列
  - §10 Excel Data Access
  - §15 Sync Engine
  - §25.1 Manual Sync
- `MVP Test Specification v0.1.5 日本語版.md`
  - MTS-SYNC-002～007
  - MTS-SYNC-011
- `Implementation Plan v0.3 日本語版(2).md`
  - P2 Scan / Sync
  - `modVariableDefinitionData`
  - `modSyncEngine`
  - `modSyncApplication`

### 次チャット開始用短縮版

```text
Project:
定型メール作成ツール MVP

Current Approved Baseline:
BL-MVP-003

P0 Foundation:
PASS / COMPLETE
CP-P0:
ESTABLISHED

P1 Walking Skeleton:
PASS / COMPLETE
CP-P1:
ESTABLISHED

P2 Scan / Sync:
IN PROGRESS

P2-01 Full Template Scanner:
PASS / COMPLETE

P2-02 Sync Diff Core:
PASS / COMPLETE

P2-02 Production:
modSyncEngine_P2-02_v0.1_CP932.bas

P2-02 API:
BuildSyncDiff(
    templateScanResult,
    currentDefinitions,
    syncTimestamp,
    syncDiffResult
) As COperationResult

Core:
18 / 18 PASS

Technical Negative:
6 / 6 PASS

Contract Compatibility:
2 / 2 PASS

VBA Compile:
PASS

TF-P2-02-001:
Test Artifact Defect
RESOLVED / CLOSED

Finding Assessment:
PASS

Production Patch Review:
23 / 23 PASS

Blocking Finding:
0

Baseline Change:
NOT REQUIRED

P2 Phase:
NOT COMPLETE

CP-P2:
NOT ESTABLISHED

Next Unit:
P2-03 VariableDefinition Sync Persistence

Next Formal Action:
P2-03 Boundary Confirmation

Important:
P2-03 must persist P2-02 SyncDiffResult.
Do not reclassify.
Do not recanonicalize VariableName.
Do not reacquire SyncTimestamp.
Do not infer Rename.
Do not redefine Metadata semantics.
```

# 記事用素材

## 気づき

- VBAでは大文字・小文字を区別しないため、Test Fixture用Function名とLocal Variable名でも衝突する。

  - `T0()`と`t0`のような短い名前は特に危険。
  - 「配列がありません」という一見分かりにくいCompile Errorでも、識別子shadowingが原因になることがある。

- Production CodeとTest ArtifactのFindingを分離して扱うことが重要だった。

  - 今回はProduction `modSyncEngine`は正しかった。
  - 不具合はTest側のみ。
  - Test失敗を即Production Defect扱いしなかったことで、不必要なProduction変更を避けられた。

- Implementation VerificationとFormal Testを分ける運用が有効だった。

  - C1～C18が全PASSしても`MTS-SYNC-* Formal PASS`とはしない。
  - Unit単体で証明できるCore Portionと、Persistence / Integrationを含むFormal Testを分離できた。

- `SyncDiffResult`を「更新命令」ではなく「Target State」として設計したことで、P2-03は意味論を再計算せずPersistenceに集中できる。

- Canonical VariableNameをP2-02で確定することで、Persistence Layer側でCase Handlingを再実装しなくてよい。

- `Already-Unused`を5番目のClassificationとして追加せずNo-opとしたことでResult構造を最小化できた。

- Rename推測をしない方針は実装を大幅に単純化する。

  - Old → Unused
  - New → New
  - 類似名判定や履歴追跡が不要。

- User ConfigurationをDiff Outputに含めないことで、`DisplayName`等を誤って更新するリスクを構造的に減らせた。

- `SyncTimestamp`をCore内部で取得しない設計にすると、

  - テストが決定的になる
  - 同一Sync内のTimestamp一貫性を保証しやすい
  - Application / Orchestration側の責務が明確になる

- Input Immutabilityを明示的なVerification Caseとして持つ価値があった。

  - 「正しい結果が返る」だけでなく、
  - 「既存Definitionを壊していない」ことも確認できた。

- Production Patch Reviewを「最終コードの見た目確認」ではなく、Approved仕様のStatic Review Checklistに対する機械的照合として運用すると、Close判断が曖昧になりにくい。

- Unit CompletionとPhase Completionを分離する運用が有効。

  - P2-02 COMPLETE
  - P2 Phase COMPLETE
  - CP-P2 ESTABLISHED\
    は別物として扱える。

- Boundary Confirmation → Approved Specification → Implementation → Compile → Core Verification → Negative → Contract Compatibility → Finding Assessment → Production Patch Review → Completion Record、という流れがかなり安定した開発プロセスになってきた。

---

## 記事にできそうな切り口

### 開発日記向き

- 「18テスト全部PASSする前に、テストコード自身でコンパイルエラーを出した話」

  - `T0()`と`t0`の衝突
  - 「配列がありません」という分かりにくいVBAエラー
  - 原因特定からTest Artifact Defect分類まで

- 「AIと一緒に作っていても、生成したテストコードは普通にバグる」

  - AI生成コードを鵜呑みにせずCompile / Verification Gateを置く重要性
  - AIのミスをProduction Defectと混同しない運用

- 「動いたから完成、にしない個人開発」

  - 18/18 PASS
  - Negative 6/6
  - Compatibility 2/2
  - Finding Assessment
  - Production Patch Review
  - Completion Record\
    までやって初めてUnit Close

- 「VBAマクロ開発を、企業システム開発っぽくやってみた」

  - Baseline
  - Boundary Confirmation
  - Unit Specification
  - Completion Record
  - Checkpoint\
    を個人開発へ持ち込んだ例

- 「テストが失敗したとき、コードを直す前に“どこが悪いか”を分類する」

  - Production Defect
  - Test Artifact Defect
  - Requirement Gap
  - Design Finding\
    の切り分け

- 「小さなExcel VBAでも責任分離は効く」

  - Scanner
  - Sync Core
  - Persistence
  - Application\
    を分割したことで、P2-02をExcel非依存で検証できた話

---

### 技術記事向き

- **VBAの名前解決とCase Insensitive Identifier**

  - Local VariableによるModule-level Function shadowing
  - `t0 = T0()`で「配列がありません」になる理由
  - 命名ルールの改善案

- **VBAでPure Coreに近いSync Engineを作る**

  - `Collection + Scripting.Dictionary`
  - Excel / Outlook非依存
  - `COperationResult`
  - Set comparison

- **差分同期を4分類で設計する**

  - New
  - Existing
  - Reactivated
  - Unused
  - Already-Unused = No-op
  - Rename = Old Unused + New

- **Canonical NameをどのLayerで確定するか**

  - Scanner表記
  - Existing Definition表記
  - Case Insensitive identity
  - Persistence側へCase Logicを漏らさない設計

- **Timestamp InjectionでVBAコードをテストしやすくする**

  - `Now`をCoreで呼ばない
  - `syncTimestamp As Date`を引数で渡す
  - 同一Sync一貫性
  - Deterministic Test

- **Target State DTOとしてのSyncDiffResult**

  - CommandではなくTarget State
  - Persistence Layerの単純化
  - 意味論再計算防止

- **User Configurationを構造的に守る方法**

  - Diff DTOに自動管理Fieldだけを含める
  - `DisplayName`等をそもそも出力しない

- **Unit Test + Negative Test + Contract Compatibility Testの三層構造**

  - Core logic
  - Defensive error paths
  - Real carrier compatibility

- **Formal TestとImplementation Verificationを分ける**

  - UnitのPASSをFormal Requirement PASSと混同しない
  - Core Portionという考え方

- **Excel VBAのData Access Layer設計**

  - P0 Read API
  - P2 Persistence API
  - `__RowIndex`
  - ListObject封じ込め
  - Core LogicからExcel Objectを排除

- **Static Review ChecklistでProduction Patchをレビューする**

  - API数
  - Dependency
  - Hard Coding
  - Input Mutation
  - Scope Boundary
  - Test Hook混入防止

---

## 有料note / テンプレート化候補

- **Implementation Unit Boundary Confirmation Template**

  - Input
  - Output
  - Responsibility
  - Non-responsibility
  - Error Boundary
  - Upstream / Downstream Contract
  - Completion Criteria

- **Sync Engine設計テンプレート**

  - Identity
  - Canonical Name
  - Classification Matrix
  - Metadata Rule
  - Rename Policy
  - No-op State
  - Timestamp Ownership
  - Persistence Boundary

- **差分同期Classification Matrix Template**

```text
Templateあり / Definitionなし
→ New

Templateあり / Active
→ Existing

Templateあり / Unused
→ Reactivated

Templateなし / Active
→ Unused

Templateなし / Unused
→ No-op
```

- **Production Patch Review Checklist Template**

  - Public API
  - Dependency Boundary
  - Input Immutability
  - Hard Coding
  - Test-only API
  - Timestamp取得
  - Configuration保護
  - Scope越境
  - Blocking Finding

- **Finding Assessment Template**

  - Implementation Defect
  - Test Artifact Defect
  - Requirement Gap
  - Design Finding
  - Technical Finding
  - Regression Finding
  - Contract Finding
  - Blocking Finding
  - Baseline Impact

- **Completion Record Template**

  - Approved Specification
  - Compile
  - Verification
  - Negative
  - Contract Compatibility
  - Finding Closure
  - Production Patch Review
  - Completion Criteria
  - Formal Test Boundary
  - Next Gate

- **AI協働開発向け「テスト失敗時の分類プロンプト」**

  - Productionを直す前に、
    - Production Defectか
    - Test Artifact Defectか
    - Requirement Gapか
    - Design Findingか\
      を判定させるプロンプト

- **「AI生成コードを安全に取り込むためのGate」チェックリスト**

  - Static Review
  - Compile
  - Core Test
  - Negative
  - Contract Compatibility
  - Finding Assessment
  - Production Patch Review
  - Completion Record

- **VBA向け命名衝突チェックリスト**

  - Function名とLocal Variable名
  - Case Insensitive Collision
  - Module名 / Procedure名
  - Property / Variable
  - Test Fixture Helper名

- **Core / Persistence分離チェックリスト**

  - CoreがExcel Objectを参照していないか
  - PersistenceがBusiness Ruleを再計算していないか
  - Timestampを二重取得していないか
  - Canonicalizationを二重実装していないか
  - Rename推測をPersistence側へ持ち込んでいないか

- **Implementation VerificationとFormal Testの境界定義テンプレート**

  - Unitで確認できるCore Portion
  - Integration後にしか確認できない部分
  - Formal PASSを付けてよいタイミング
