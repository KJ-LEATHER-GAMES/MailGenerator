# 引き継ぎまとめ

## 実施内容

### 1. P2-04 Local VerificationでIF-P2-04-001を検出

`TestP204ManualSyncIntegrationNormal` 実行時、当初以下で失敗した。

```text
Success = False
ErrorType=UnexpectedError
Target=ModelName
Message=FirstDetectedAt is not a valid persisted date value.
```

Diagnosticでは、

```text
TemplateScanResult:
  ValidVariables.Count = 4
  InvalidCandidates.Count = 0
  Locations.Count = 4

syncDiffResult Is Nothing = True
```

となっており、

```text
Template Scan
→ PASS

P2-04 Failure Propagation
→ PASS

下位層Metadata処理
→ FAIL
```

という状態だった。

このFindingを、

```text
IF-P2-04-001
Initial Sync Metadata Bootstrap Gap
```

として扱った。

---

### 2. 最初のCurrent VariableDefinition Date診断

`DiagnoseP204CurrentDefinitionDates` により以下を確認した。

```text
VariableName = ModelName

FirstDetectedAt
TypeName = Empty
VarType  = 0
Value    = []

LastDetectedAt
TypeName = Empty
VarType  = 0
Value    = []
```

```text
VariableName = OldVariable

FirstDetectedAt
TypeName = Empty
VarType  = 0
Value    = []

LastDetectedAt
TypeName = Empty
VarType  = 0
Value    = []
```

この時点では `TemplateLocation` を診断していなかった。

---

### 3. IF-P2-04-001 Finding確定

Findingを以下として整理した。

```text
Finding:
IF-P2-04-001

Finding Name:
Initial Sync Metadata Bootstrap Gap

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

当初のRoot Cause：

```text
初回Sync前に存在するVariableDefinition行について、
System-managed Metadataが未初期化である状態の
Bootstrap RuleがDesignで定義されていなかった。
```

---

### 4. 最初のDesign Gap Resolution

当初は以下をUninitialized Metadataと定義した。

```text
TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

Initialized Metadata：

```text
TemplateLocation = Subject / Body / Both
FirstDetectedAt   = Valid Date
LastDetectedAt    = Valid Date
```

この前提で以下を定義した。

#### New

```text
TemplateLocation = Current
Status           = Active
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
```

#### Existing

Initialized：

```text
FirstDetectedAt = Existing
LastDetectedAt  = SyncTimestamp
```

Uninitialized：

```text
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

#### Reactivated

Initialized：

```text
FirstDetectedAt = Existing
LastDetectedAt  = SyncTimestamp
```

Uninitialized：

```text
FirstDetectedAt = SyncTimestamp
LastDetectedAt  = SyncTimestamp
```

#### Unused

Initialized：

```text
TemplateLocation = Existing
FirstDetectedAt  = Existing
LastDetectedAt   = Existing
```

Uninitialized：

```text
TemplateLocation = Empty
FirstDetectedAt  = Empty
LastDetectedAt   = Empty
```

Already-UnusedはNo-opとした。

---

### 5. Design Patch具体化

`MVP Design v0.1.9` に対するPatch案を作成した。

Patch対象：

```text
§7.4 自動管理列の更新規則
§15.4 Existing
§15.5 Reactivated
§15.6 Unused
```

変更不要とした主な箇所：

```text
§15.1 比較方式
§15.2 差分分類
§15.3 New
§15.7 Rename
§25.1 Manual Sync Sequence
```

Candidate案：

```text
MVP Design v0.1.9
→ MVP Design v0.1.10 Candidate
```

Requirements / Implementation PlanのSemantic Changeは不要と判断した。

---

### 6. Test Specification Impact具体化

`MVP Test Specification v0.1.5` について、新MTS IDは追加せず既存CaseへVariant追加する方針を整理した。

対象：

```text
MTS-SYNC-003 Existing設定保持
MTS-SYNC-004 Unused化
MTS-SYNC-005 Reactivated
MTS-SYNC-011 Sync metadata更新
```

Candidate案：

```text
MVP Test Specification v0.1.5
→ v0.1.6 Candidate
```

当初追加した主なVariant：

```text
Existing / Initialized
Existing / Bootstrap

Unused / Initialized
Unused / Bootstrap

Reactivated / Initialized
Reactivated / Bootstrap
```

Formal Test実行ではなく、Test Specificationの補強のみとした。

---

### 7. P2-02 Sync Diff Core Correction

元Production：

```text
modSyncEngine_P2-02_v0.1_CP932.bas
```

を確認し、Bootstrap Metadata対応を追加した。

作成：

```text
modSyncEngine_P2-02_v0.1.1_CP932.bas
```

主なCorrection：

- Existing Bootstrap時：
  - `FirstDetectedAt = SyncTimestamp`
- Reactivated Bootstrap時：
  - `FirstDetectedAt = SyncTimestamp`
- Unused Bootstrap時：
  - Empty Metadata保持
- Partial Metadata：
  - Failure
- `CreateDiffItem` の `templateLocation` を `String` から `Variant` へ変更
  - Empty保持のため

Public API：

```vb
Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult
```

は変更していない。

---

### 8. P2-02 Bootstrap Regression追加

作成：

```text
modP2_02SyncDiffBootstrapRegressionTest_v0.1_CP932.bas
```

Entry Point：

```vb
TestP202SyncDiffBootstrapRegression
```

追加した主要Case：

```text
R01 Existing Bootstrap
R02 Reactivated Bootstrap
R03 Unused Bootstrap
R04 Already-Unused Bootstrap
R05 Partial Metadata / Present
R06 Partial Metadata / Absent
R07 Initialized Existing Regression
R08 Initialized Unused Regression
```

実行結果：

```text
Bootstrap Regression:
33 / 33 PASS

Existing Core:
18 / 18 PASS

Technical Negative:
6 / 6 PASS
```

CompileもPASS。

この時点ではP2-02 Correctionを一旦Verifiedと判断した。

---

### 9. P2-03 VariableDefinition Sync Persistence Correction

Libraryから元Production：

```text
modVariableDefinitionData_P2-03_v0.1.bas
```

を取得し、Sourceを直接確認した。

元Sourceでは、

```text
ValidateDiffItem
```

が全Classificationに対して、

```text
TemplateLocation必須
FirstDetectedAt Date必須
LastDetectedAt Date必須
```

としていた。

また、

```text
WriteExistingMetadata
```

で常に、

```vb
CDate(item(KEY_FIRST_DETECTED_AT))
CDate(item(KEY_LAST_DETECTED_AT))
```

していた。

そのためUnused BootstrapのEmpty MetadataをPersistenceできなかった。

---

### 10. P2-03 Correction Candidate作成

作成：

```text
modVariableDefinitionData_P2-03_v0.1.1_CP932.bas
```

Correction内容：

#### `ValidateDiffItem`

当初：

```text
New / Existing / Reactivated
→ Date Metadata必須

Unused / Initialized
→ Date Metadata必須

Unused / Bootstrap
→ TemplateLocation / FirstDetectedAt / LastDetectedAt
   全Emptyを許可

Unused / Partial
→ Failure
```

#### `WriteExistingMetadata`

Emptyの場合：

```text
ClearContents
```

Non-emptyの場合：

```text
従来どおりDateとしてPersistence
```

P2-03ではBootstrap値を生成せず、

```text
P2-02 Target State
↓
Validate
↓
Persist
```

のみを担当する方針を維持した。

---

### 11. P2-03 Source生成時のArtifact Defect

最初に生成した `v0.1.1` で以下の構文エラーが発生した。

```vb
rowIndex = CLng(rowMap(variableName))rowIndex = CLng(rowMap(variableName))
```

原因：

```text
Source復元時に
1～1000行
+
1000行目～末尾
を連結したため、
境界1000行目が重複した。
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

を作成した。

---

### 12. ユーザー提供のv0.1との整合確認

ユーザーから実Source：

```text
modVariableDefinitionData_P2-03_v0.1(1).bas
```

を提供してもらい、

```text
v0.1
+
IF-P2-04-001 Correction
```

と、

```text
v0.1.1 fix1
```

を全文比較した。

結果：

```text
完全一致:
YES
```

意図した差分は以下2Procedureのみ。

```text
ValidateDiffItem
WriteExistingMetadata
```

それ以外のSourceは元v0.1と一致。

Artifact Generation Defectは解消済み。

---

### 13. P2-03 Regression実行

Compile：

```text
PASS
```

Bootstrap Regression：

```text
TestP203SyncPersistenceBootstrapRegression

7 / 7 PASS
```

Existing Core：

```text
TestP203SyncPersistenceCore

12 / 12 PASS
```

Technical Negative：

```text
TestP203SyncPersistenceTechnicalNegative

18 / 18 PASS
```

合計：

```text
37 PASS
0 FAIL
```

---

### 14. P2-03 Compatibility再確認

既存：

```text
TestP203SyncPersistenceCompatibility
```

を実行。

結果：

```text
K1 P2-02 -> P2-03 Production Compatibility
PASS

K2 Existing VariableDefinition Read Regression
PASS

K3 P2-02 Contract / No-Reopen Compatibility
PASS

3 / 3 PASS
```

ただしSource Reviewした結果、K1 FixtureはすべてInitialized Metadataを使用していた。

そのため、

```text
Initialized Metadata Pipeline
```

のRegression確認としてはPASSだが、

```text
Initial Sync Bootstrap Pipeline
```

そのものは未確認と判断した。

---

### 15. P2-04 Manual Sync Local Verification再開

`TestP204ManualSyncIntegrationNormal` を再実行した。

結果：

```text
PASS  I01-01 ExecuteManualSync returns COperationResult

Success = False
ErrorType=ConfigurationError
Target=VariableDefinition
Message=VariableDefinition contains partially initialized sync metadata.

FAIL  I01-02 ExecuteManualSync Success

Overall = FAIL
```

このErrorはP2-04ではなく、P2-02 `BuildSyncDiff` のCurrent Metadata Validationで発生していると判断した。

---

### 16. Current Sync Metadataを再診断

新たに、

```vb
DiagnoseP204CurrentSyncMetadata
```

を実行した。

実測結果：

#### ModelName

```text
Status = Active

TemplateLocation
TypeName = String
Value    = Subject

FirstDetectedAt
TypeName = Empty

LastDetectedAt
TypeName = Empty
```

#### OldVariable

```text
Status = Unused

TemplateLocation
TypeName = String
Value    = Body

FirstDetectedAt
TypeName = Empty

LastDetectedAt
TypeName = Empty
```

これにより、実Workbookの状態が、

```text
TemplateLocation = 有効値
Detection Timestamp = 未初期化
```

であることが確定した。

---

### 17. 当初Bootstrap定義の不足を特定

これまでのCorrectionでは、

```text
TemplateLocation = Empty
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

のみをBootstrap Stateとしていた。

しかし実データでは、

```text
TemplateLocation = Subject / Body
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

だった。

したがって、

```text
TemplateLocation
+
Detection Timestamp
```

を一体の初期化状態として扱う設計が狭すぎることが判明した。

---

## 決定事項

### IF-P2-04-001の分類

引き続き、

```text
IF-P2-04-001
Initial Sync Metadata Bootstrap Gap
```

として扱う。

Primary Classification：

```text
Design Gap
```

Requirement Gap：

```text
NONE
```

P2-04 Production Defect：

```text
NONE
```

---

### Bootstrap判定の中心

最新診断結果を受け、

```text
TemplateLocationの初期化状態
```

と、

```text
Detection Timestampの初期化状態
```

を同一視しない方針とする。

Bootstrap / Detection History未初期化の中心は、

```text
FirstDetectedAt = Blank
AND
LastDetectedAt  = Blank
```

とする方向で再定義が必要。

---

### TimestampのPartial State

以下は正当なBootstrapとは扱わない。

```text
FirstDetectedAt = Blank
LastDetectedAt  = Date
```

```text
FirstDetectedAt = Date
LastDetectedAt  = Blank
```

これらはPartial / Invalid Stateとして扱う方針。

---

### Existing Bootstrap

Current Template上に存在し、Detection Timestamp履歴が未初期化の場合：

```text
TemplateLocation = Current Location
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
Status           = Active
```

とする方向で維持。

---

### Reactivated Bootstrap

Detection Timestamp履歴が未初期化で再検出された場合：

```text
TemplateLocation = Current Location
FirstDetectedAt  = SyncTimestamp
LastDetectedAt   = SyncTimestamp
Status           = Active
```

とする方向で維持。

---

### Unused / Already-Unused

Current Template上に存在しない場合：

```text
Current Template未検出
→ Detection Timestampを新規生成しない
```

方針を維持。

既存の `TemplateLocation` がある場合は、その値を保持する必要がある。

Already-Unused：

```text
No-op
```

を維持。

---

### P2-02 / P2-03責務分離

P2-02：

```text
Classification
Metadata Target State Calculation
Bootstrap Detection
```

を担当。

P2-03：

```text
P2-02 Target State Validation
Persistence
```

のみを担当。

P2-03では以下を行わない。

```text
Classification再計算
SyncTimestamp再取得
Bootstrap Timestamp生成
Metadata Meaning再定義
Rename推測
```

---

### P2-04

今回のFAILはP2-04 Production Defectとはしない。

```text
P2-04 Production:
Correction NOT REQUIRED at present

P2-04 Local Verification:
BLOCKED
```

---

### Formal Test Boundary

今回の、

```text
P2-02 Regression
P2-03 Regression
Compatibility
P2-04 Local Verification
```

はいずれもImplementation Verification。

```text
Formal MTS-SYNC PASS
```

とはしない。

Formal MVP TestはP7後のTest Candidate Buildに対して実施する。

---

## 未解決事項

### 1. IF-P2-04-001 Design Gap Resolutionの再修正

以前作成したDesign Patchでは、

```text
Uninitialized Metadata =
TemplateLocation Empty
+
FirstDetectedAt Empty
+
LastDetectedAt Empty
```

としていた。

この定義は実Workbook状態と一致しないため、Revisionが必要。

要再整理：

```text
TemplateLocationが有効値
+
FirstDetectedAt / LastDetectedAtがBlank
```

をどのようにDesign上表現するか。

---

### 2. MVP Design Patch Revision

以前の対象：

```text
MVP Design v0.1.9

§7.4
§15.4
§15.5
§15.6
```

について、Patch内容を再修正する必要がある。

特に、

```text
Metadata Initialized / Uninitialized
```

という3列一体の概念をやめ、

```text
Detection History Initialized / Uninitialized
```

を中心とした表現へ見直す必要がある。

---

### 3. Test Specification Impact Revision

以前追加予定だったBootstrap Variantは、

```text
TemplateLocation Empty
+
Date Metadata Empty
```

前提だった。

以下を追加または置換する必要がある。

```text
TemplateLocation = Subject / Body / Both
FirstDetectedAt   = Empty
LastDetectedAt    = Empty
```

対象：

```text
MTS-SYNC-003 Existing
MTS-SYNC-004 Unused
MTS-SYNC-005 Reactivated
MTS-SYNC-011 Metadata
```

---

### 4. P2-02 v0.1.2 Correction

現状：

```text
modSyncEngine_P2-02_v0.1.1_CP932.bas
```

は、

```text
TemplateLocation / First / Last
全3項目Empty
```

のみBootstrap扱いしている。

必要なCorrection：

```text
Detection Timestamp 2列
FirstDetectedAt
LastDetectedAt

を中心にBootstrap判定する。
```

TemplateLocation：

```text
Blank
Subject
Body
Both
```

の扱いをDesign Revisionに従って整理する必要がある。

---

### 5. P2-02 Regression Revision

既存Bootstrap Regression：

```text
modP2_02SyncDiffBootstrapRegressionTest_v0.1_CP932.bas
```

は全Empty Fixture中心。

追加が必要なCase候補：

```text
Existing:
Location = Subject
First = Empty
Last  = Empty

Reactivated:
Location = Body
First = Empty
Last  = Empty

Unused:
Location = Both
First = Empty
Last  = Empty

Already-Unused:
Location = Body
First = Empty
Last  = Empty

Timestamp Partial:
First Blank / Last Date
→ Failure

Timestamp Partial:
First Date / Last Blank
→ Failure
```

---

### 6. P2-03 v0.1.2 Correction

現状：

```text
modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas
```

はUnused Bootstrapを、

```text
TemplateLocation
FirstDetectedAt
LastDetectedAt

全Empty
```

の場合だけ許可している。

必要なCorrection：

```text
Unused
+
TemplateLocation = valid value
+
FirstDetectedAt = Empty
+
LastDetectedAt = Empty

を有効Target StateとしてPersistence可能にする。
```

ただしP2-03自身でBootstrap値は生成しない。

---

### 7. P2-03 Regression Revision

現在のBootstrap Regression：

```text
modP2_03SyncPersistenceBootstrapRegressionTest_v0.1_CP932.bas
```

へLocationありTimestampなしのFixture追加が必要。

---

### 8. Bootstrap Production Compatibility

既存：

```text
TestP203SyncPersistenceCompatibility
```

は3/3 PASSだが、K1はInitialized Metadata Fixture。

以下の実Pipeline確認が必要。

```text
Current VariableDefinition
↓
GetAllVariableDefinitions
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
tblVariableDefinition
```

Fixtureには少なくとも、

```text
ModelName
Status = Active
TemplateLocation = Subject
First = Empty
Last  = Empty
```

を含める。

---

### 9. P2-04 Local Verification

下位Correction完了後に再開する。

現在：

```text
P2-04 Local Verification:
BLOCKED
```

---

## 次アクション

### 優先度1：IF-P2-04-001 Design Gap Resolution Revision

次チャットで最初に行う。

確認対象：

```text
MVP Design v0.1.9
§7.4
§15.4 Existing
§15.5 Reactivated
§15.6 Unused
```

中心論点：

```text
TemplateLocation
≠
Detection History Initialization
```

として状態モデルを再定義する。

---

### 優先度2：Test Specification Impact Revision

確認対象：

```text
MVP Test Specification v0.1.5

§8.3 Baseline VariableDefinition
MTS-SYNC-003
MTS-SYNC-004
MTS-SYNC-005
MTS-SYNC-011
```

Locationあり / TimestampなしVariantを正式化する。

---

### 優先度3：P2-02 v0.1.2 Correction

対象Production：

```text
modSyncEngine_P2-02_v0.1.1_CP932.bas
```

修正対象：

```text
ValidateMetadataState
IsMetadataUninitialized
BuildSyncDiff Existing / Reactivated / Unused処理
```

Public API / SyncDiffResult Shapeは変更しない。

---

### 優先度4：P2-02 Regression

既存：

```text
modP2_02SyncDiffBootstrapRegressionTest_v0.1_CP932.bas
```

を拡張。

既存C1-C18 / N1-N6も再実行。

---

### 優先度5：P2-03 v0.1.2 Correction

対象：

```text
modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas
```

主に：

```text
ValidateDiffItem
WriteExistingMetadata
```

を再確認。

P2-03でMetadata Meaningを再計算しないこと。

---

### 優先度6：P2-03 Regression

```text
Bootstrap Regression
Core C01-C12
Technical Negative N01-N18
```

を再実行。

---

### 優先度7：P2-02 → P2-03 Bootstrap Compatibility

実Production Pipelineで、

```text
Locationあり
Timestampなし
```

のCurrent Stateを通す。

---

### 優先度8：P2-04 Local Verification再開

再実行：

```vb
TestP204ManualSyncIntegrationNormal
```

期待：

```text
ExecuteManualSync Success
```

その後I02 Common Timestamp等へ進む。

---

# 記事用素材

## 気づき

- 「未初期化」を単純に `Empty` だけで表現すると、実Workbookの運用状態を取りこぼす。
- 同じ「管理Metadata」でも、
  - `TemplateLocation`
  - `FirstDetectedAt / LastDetectedAt`\
    はLifecycleが異なる可能性がある。
- 「列が同時に初期化される」という暗黙仮定は危険。
- Initial Sync / Legacy Data / Pre-seeded Dataでは、通常のNew行とは異なるBootstrap Stateが発生する。
- Unit Testだけでは正常でも、Manual Syncという上位Integrationで初めて状態モデル不足が表面化することがある。
- P2-04のFAILをP2-04のバグと即断せず、
  - Template Scan
  - Diff Core
  - Persistence
  - Orchestration\
    を分離して追跡したことで責務境界を維持できた。
- Fail Closed Guardは、単にエラーを起こす機能ではなく「設計モデルと実データの不一致を早く見つけるセンサー」として機能する。
- Test HarnessのSnapshot/RestoreもProduction Dataを変化させ得るため、Test CodeもSourceとしてレビュー対象になる。
- Source生成・差分適用では境界行重複のようなArtifact Generation Defectが起こり得る。
- 「Compile Error = Production Logic Defect」とは限らない。
- 元Sourceとの差分比較とHash比較は、AI生成PatchのIntegrity確認に有効だった。
- Public Contractを維持しつつPrivate LogicだけをCorrectionすることで、影響範囲を限定できた。
- Formal TestとImplementation Verificationを分離して扱うことで、途中のPASSを過大評価せずに済んだ。

---

## 記事にできそうな切り口

### 開発日記向き

- 「直したはずなのに、Manual Syncでまた失敗した」
- Unit Test 57件PASS、37件PASS、Compatibility 3/3 PASSでもIntegrationで止まった話
- `Empty` だと思っていたら `TemplateLocation` は `Subject` だった
- AI協働開発で「推測を診断Macroで潰していく」進め方
- バグ修正より先に責務境界を守ったことで原因が見えた話
- 1000行境界の重複でVBA Sourceが壊れたArtifact Generation事故
- 「テストが全部通った＝設計が正しい」ではなかった実例
- 古いExcelデータを持つMVPでBootstrap設計が必要になった経緯

### 技術記事向き

- VBA + Excel TableでのBootstrap Metadata設計
- Detection HistoryとCurrent Locationを別Lifecycleとして扱う設計
- `Empty` / `""` / Date Serial / VBA Dateの扱い
- Sync EngineとPersistence Layerの責務分離
- Target State CalculationをCore、PersistenceをData Accessに分ける構成
- Classification-aware Validationの設計
- Preflight Validation + Fail Closed
- Regression TestとCompatibility Testの役割分担
- Initialized Fixtureだけでは見えないBootstrap Integration Gap
- Public APIを変えずPrivate実装だけをCorrectionする方法
- Excel `.Value2` がDate Serialを返すことを前提にしたValidation
- AI生成Source Patchの整合確認方法
  - 原Source比較
  - 意図したProcedureだけの差分確認
  - Hash比較
  - Compile
  - Regression

---

## 有料note / テンプレート化候補

- **Design Gap判定テンプレート**

  - Requirement Gap
  - Design Gap
  - Implementation Defect
  - Test Artifact Defect
  - Integration Finding\
    の分類表

- **Bootstrap State設計チェックリスト**

  - 新規行
  - 既存未初期化行
  - Legacy行
  - Partial Metadata
  - Reactivation
  - Unused
  - Already-Unused

- **AI生成Patch Integrity Checkテンプレート**

  - 元Sourceとの差分
  - Public API差分
  - Procedure差分
  - Function/End Function整合
  - Forbidden Dependency
  - Compile
  - Regression

- **Implementation Verification階層テンプレート**

  - Static Review
  - Unit Regression
  - Negative Test
  - Compatibility Test
  - Integration Test
  - Formal Test

- **Sync Engine設計テンプレート**

  - Input State
  - Classification
  - Target State
  - Metadata Rule
  - Persistence Boundary
  - Retry Rule
  - Fail Closed Rule

- **AI協働開発用Finding Record**

  - Finding ID
  - Trigger
  - Evidence
  - Classification
  - Root Cause
  - Responsibility
  - Document Impact
  - Production Impact
  - Regression Scope
  - Closure Criteria

- **「直す前に診断する」プロンプト集**

  - Runtime型確認
  - Current State確認
  - Production / Test Artifact切り分け
  - Responsibility Boundary確認
  - Source差分確認

---

## 次チャット開始用短縮版

```text
Project:
定型メール作成ツール MVP

Current Baseline:
BL-MVP-003

Phase:
P2 Scan / Sync IN PROGRESS

P2-01:
PASS / COMPLETE

P2-02:
IF-P2-04-001対応でCorrection済みだが、
Bootstrap State定義不足が追加判明。
再Correction REQUIRED。

P2-03:
Correction + Regression + Compatibilityは一度PASS。
ただしBootstrap State定義不足により再Correction REQUIRED。

P2-04:
Production Defectなし。
Local Verification BLOCKED。

Active Finding:
IF-P2-04-001 Initial Sync Metadata Bootstrap Gap

Latest Actual Current State:

ModelName:
Status = Active
TemplateLocation = Subject
FirstDetectedAt = Empty
LastDetectedAt = Empty

OldVariable:
Status = Unused
TemplateLocation = Body
FirstDetectedAt = Empty
LastDetectedAt = Empty

Key Finding:
TemplateLocationの初期化状態と
Detection Timestampの初期化状態を
同一視してはいけない。

Next Action:
1. Design Gap Resolution Revision
2. Design Patch Revision
3. Test Specification Impact Revision
4. P2-02 v0.1.2 Correction + Regression
5. P2-03 v0.1.2 Correction + Regression
6. Bootstrap Production Compatibility
7. P2-04 Local Verification再開

Important Responsibility:
P2-02 = Metadata Target State Calculation
P2-03 = Validation / Persistence only
P2-04 = Orchestration only

Do not move Bootstrap calculation into P2-03.
Do not patch P2-04 yet.
Formal MVP Test is still NOT EXECUTED.
```
