# 引き継ぎまとめ

## 実施内容

- **P2-05 Current Production Source Review**を実施した。
  - 対象：
    - `modUiController`
    - `modSyncApplication`
    - `COperationResult`
    - `CErrorInfo`
    - `SyncDiffResult`
    - `TemplateScanResult`
    - Manual Sync Button / Macro接続
  - 実Production Sourceを確認し、P2-05で必要なCarrier/API形状を確定した。
  - `modSyncApplication`のPublic API：
    ```vb
    Public Function ExecuteManualSync( _
        ByRef syncDiffResult As Object, _
        ByRef templateScanResult As Object _
    ) As COperationResult
    ```
  - `TemplateScanResult`：
    ```text
    Dictionary
    └─ InvalidCandidates = Collection
    ```
  - `SyncDiffResult`：
    ```text
    Dictionary
    ├─ New         = Collection
    ├─ Existing    = Collection
    ├─ Reactivated = Collection
    └─ Unused      = Collection
    ```
  - 各SyncDiff ItemはDictionary-compatible Object。
  - `COperationResult`は`Success`と`Errors`を公開。
  - `CErrorInfo`は`ErrorType / Message / Target`を公開。
  - 新しいResult Class / Error Model / Adapterは不要と判断した。
  - `modUiController`は当時まだ存在せず、Manual Sync Buttonも未作成であることをユーザー確認で確定した。
  - Current Production Source Review結果：
    ```text
    PASS / CLOSED
    Blocking Finding = 0
    ```

- **P2-05 Production Patch Design v0.1**を作成した。
  - 正式Patch Scope：
    ```text
    ADD / IMPLEMENT:
    modUiController

    MODIFY:
    NONE

    REUSE UNCHANGED:
    modSyncApplication
    modSyncEngine
    modVariableDefinitionData
    modTemplateScanner
    modSettingsData
    modOutlookAdapter
    modResult
    COperationResult
    CErrorInfo

    DELETE:
    NONE
    ```
  - Canonical UI Entry：
    ```vb
    Public Sub RunManualSync()
    ```
  - `modUiController`の責務：
    - Manual Sync明示実行
    - `ExecuteManualSync`呼出し
    - Success / Failure分岐
    - Sync Result表示
    - InvalidCandidates表示
    - Existing Error情報表示
    - Generic Failure fallback
    - 1回の実行につき1回のModal Notification
  - UI層から以下を直接呼ばない設計とした。
    ```text
    ScanTemplate
    BuildSyncDiff
    ApplySyncDiff
    GetAllVariableDefinitions
    ReadSubject
    ReadBodyText
    ```
  - `Reactivated`は`復活`として独立表示する。
  - Automatic Retry / Module-level Sync State / New Error Code体系は導入しない。
  - Production Patch Design結果：
    ```text
    APPROVED FOR IMPLEMENTATION
    ```

- **P2-05 Production Implementation**を実施した。
  - 新規作成：
    ```text
    modUiController_P2-05_v0.1_CP932.bas
    ```
  - Public Entry：
    ```vb
    Public Sub RunManualSync()
    ```
  - 実装内容：
    - `ExecuteManualSync`を唯一のApplication Entryとして呼び出す。
    - Success時：
      ```text
      New         → 新規
      Existing    → 継続
      Reactivated → 復活
      Unused      → Unused化
      ```
    - 4分類すべてを0件でも表示。
    - Invalid Candidate時は`TemplateScanResult("InvalidCandidates")`を直接利用。
    - Failure時は`COperationResult.Errors`の`Message / Target`をBasic UI表示。
    - 表示可能なError情報がなければGeneric Failureを表示。
    - SuccessにもかかわらずCarrierが`Nothing`の場合はFail Closed。
  - Pre-Compile Static Check：
    - `RunManualSync`存在
    - `ExecuteManualSync`呼出し1回
    - `ScanTemplate / BuildSyncDiff / ApplySyncDiff / GetAllVariableDefinitions`直接呼出しなし
    - Automatic Eventなし
    - Module-level Sync Object Stateなし
    - 4分類Mapping確認
    - PASS

- ユーザーが`modUiController_P2-05_v0.1_CP932.bas`をWorkbookへImportし、VBEで
  ```text
  Debug
  → Compile VBAProject
  ```
  を実行。
  - 結果：
    ```text
    VBA Compile:
    PASS
    ```

- **P2-05 Verification**へ移行した。
  - Verification対象：
    ```text
    P05-I01～I17
    P05-K01～K04
    ```
  - Evidence Strategyを整理した。
    - Runtime UI：
      - I01～I08
      - I16
    - 既存P2-04 Evidence + P2-05 Source Path：
      - I09～I12
    - Technical Negative / Source Path：
      - I13～I15
    - Static / Compatibility：
      - I17
      - K01～K04
  - 先行して以下をPASS判定した。
    ```text
    I09～I15
    I17
    K01～K04
    ```

- 最初の`RunManualSync` Runtime Verificationで**WordEditorアクセス失敗**が発生した。
  - 表示内容：
    ```text
    テンプレート同期に失敗しました。

    Unable to access WordEditor: -2147467259 - 操作は失敗しました。
    確認対象: WordEditor
    ```
  - 同一Excel Sessionで再実行しても同じFailure。
  - Outlookは最初から起動済み。
  - Finding：
    ```text
    IF-P2-05-001
    WordEditor Access Failure
    ```

- **WordEditor Failure調査**を段階的に実施した。
  - `TestP102InspectorWordEditorWarmStart`実行：
    ```text
    PASS
    ```
    主な結果：
    ```text
    CreateMailFromTemplate: PASS
    Warm Start Existing Explorer Reuse: PASS
    ReadBodyText: PASS
    Inspector / WordEditor / Word Document: PASS
    CloseWithoutSave: PASS
    Production Functional Path: PASS
    ```
  - 現行`modOutlookAdapter`を確認。
    - P1-07のstale reference対策が残っていることを確認。
    - `CloseWithoutSave`で：
      ```text
      mMailItem = Nothing
      mOutlookApp = Nothing
      ```
    - `EnsureOutlookReady` Failureでも`mOutlookApp = Nothing`。
    - Warm Startでは既存Explorerを再利用。
    - Cold StartではVisible Explorer生成 + `DoEvents`。
  - `TestP103TemplateSnapshotBoundary`実行：
    ```text
    PASS
    ```
    主な結果：
    ```text
    CreateMailFromTemplate: PASS
    ReadSubject: PASS
    ReadBodyText: PASS
    Same Active MailItem Boundary: CONFIRMED
    Snapshot Boundary: ESTABLISHED
    CloseWithoutSave: PASS
    ```
  - 現行`modSyncApplication_Current.bas`を、保存済みP2-04 Production Sourceと比較。
    - 628行同士。
    - 差分7箇所はすべてmember nameの大文字小文字のみ。
    - Semantic Difference：
      ```text
      NONE
      ```
    - Source Driftなしと判断した。

- WordEditor Timing仮説を確認するため、Diagnostic-only Test Moduleを作成した。
  - 作成：
    ```text
    modP2_05WordEditorTimingDiagnostic_v0.1_CP932.bas
    ```
  - Test：
    ```text
    TestP205DiagImmediateNoGuard
    TestP205DiagImmediateWithGuard
    TestP205DiagDoEventsWithGuard
    ```
  - 結果：
    ```text
    A Immediate / No File Guard       PASS
    B Immediate / With File Guard     PASS
    C DoEvents / With File Guard      PASS
    ```
  - よって、以下の単純仮説は支持されなかった。
    - `Dir$` File Guardが原因
    - `ReadBodyText`直前の単発`DoEvents`不足
    - Production Pathが「速すぎる」ことだけが原因

- `modP1_03TemplateSnapshotSmokeTest_v0.1_CP932(1).bas`をレビューした。
  - Positive PathはProduction APIを直接使用。
  - Snapshot Path：
    ```text
    GetSettingValue
    → ResolveWorkbookRelativePath
    → CreateMailFromTemplate
    → ReadSubject
    → ReadBodyText
    → CloseWithoutSave
    ```
  - Production Adapterロジックを書き換えるTestではないことを確認。

- その後、Productionコードを一切変更しないまま`RunManualSync`を再実行。
  - 2回連続で成功。
  - 表示：
    ```text
    新規 (0件)
    なし

    継続 (4件)
    - ModelName
    - GateDate
    - Department
    - Comment

    復活 (0件)
    なし

    Unused化 (0件)
    なし
    ```
  - これにより：
    ```text
    P05-I03 Existing Only:
    PASS
    ```

- **Fresh Warm Reproduction**を実施した。
  - 手順：
    1. Excel完全終了
    2. Outlook完全終了
    3. Classic Outlookを手動起動
    4. Explorer表示確認
    5. `MailGeneratorNew.xlsm`起動
    6. P1 Test / Diagnosticを一切実行しない
    7. 最初のWordEditor関連処理として`RunManualSync`
  - 1回目：
    ```text
    PASS
    ```
  - 2回目：
    ```text
    PASS
    ```
  - どちらも`Existing=4`の正常結果。
  - P1 Smoke Testを事前に実行しなくても正常だった。

- WordEditor Failure Findingを再評価した。
  - 正確なRoot Cause：
    ```text
    NOT PROVEN
    ```
  - 最も妥当な分類：
    ```text
    Intermittent Outlook / WordEditor COM state
    または
    transient session-specific WordEditor readiness condition
    ```
  - Production Defectとして再現できず、Production修正の根拠も得られなかった。
  - Finding処置：
    ```text
    IF-P2-05-001
    CLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING

    Blocking Finding:
    0
    ```
  - ただし事象自体はNon-blocking Observationとして継続管理：
    ```text
    OBS-P2-05-002
    Intermittent WordEditor E_FAIL

    Status:
    OPEN / NON-BLOCKING
    ```

- この会話で作成した主なArtifact：
  - `P2-05 Fail Closed - Sync Result - Phase Integration Current Production Source Review v0.1.md`
  - `P2-05 Fail Closed - Sync Result - Phase Integration Production Patch Design v0.1.md`
  - `modUiController_P2-05_v0.1_CP932.bas`
  - `P2-05 Production Implementation Record v0.1.md`
  - `P2-05 VBA Compile Evidence v0.1.md`
  - `P2-05 Verification Execution Plan and Evidence Record v0.1.md`
  - `P2-05 Verification Partial Result v0.1.md`
  - `IF-P2-05-001 WordEditor Access Failure Investigation Plan v0.1.md`
  - `IF-P2-05-001 Investigation Update v0.2.md`
  - `IF-P2-05-001 Investigation Update v0.3.md`
  - `IF-P2-05-001 Investigation Update v0.4.md`
  - `IF-P2-05-001 Investigation Update v0.5.md`
  - `IF-P2-05-001 Investigation Update v0.6.md`
  - `IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md`
  - `modP2_05WordEditorTimingDiagnostic_v0.1_CP932.bas`

---

## 決定事項

- P2-05 Current Production Source Reviewは：
  ```text
  PASS / CLOSED
  ```
  とする。

- P2-05 Production Patch Scopeは：
  ```text
  ADD / IMPLEMENT:
  modUiController

  MODIFY:
  NONE

  DELETE:
  NONE
  ```
  とする。

- `modUiController`の正式Public Entryは：
  ```vb
  Public Sub RunManualSync()
  ```
  とする。

- P2-05 UIは`ExecuteManualSync`のみをApplication Entryとして使用する。

- UIから以下を直接呼ばない。
  ```text
  ScanTemplate
  BuildSyncDiff
  ApplySyncDiff
  GetAllVariableDefinitions
  ReadSubject
  ReadBodyText
  ```

- Sync Result表示Mapping：
  ```text
  New         → 新規
  Existing    → 継続
  Reactivated → 復活
  Unused      → Unused化
  ```

- ReactivatedをExistingへマージしない。

- 4分類は0件でも表示する。

- 1回のManual SyncにつきModal Notificationは1回とする。

- P2-05では以下を導入しない。
  ```text
  Automatic Retry
  Module-level Sync State
  New Result Class
  New Error Code体系
  P3 Unused Confirmation UI
  P6 Final Error UI
  ```

- `modUiController_P2-05_v0.1_CP932.bas`をProduction Candidateとして採用した。

- VBA Compileは：
  ```text
  PASS
  ```
  とする。

- 現行`modSyncApplication`はP2-04 Production SourceとSemantic Differenceなしと判断し、修正しない。

- WordEditor Failure調査の結果、以下の修正案は採用しない。
  ```text
  modSyncApplicationへDoEvents追加
  無条件DoEvents追加
  fixed Sleep
  Retry Loop
  Automatic Manual Sync Retry
  ```
  理由：
  - Diagnostic A/B/CがすべてPASS。
  - Fresh Warmでも1回目から`RunManualSync`がPASS。
  - 根本原因が証明されていないため。

- `IF-P2-05-001 WordEditor Access Failure`は：
  ```text
  CLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING
  ```
  とする。

- WordEditor事象自体は：
  ```text
  OBS-P2-05-002
  Intermittent WordEditor E_FAIL
  OPEN / NON-BLOCKING
  ```
  として後続Regression / P6へ持ち越す。

- P2-05 Verificationは本線へ復帰する。

- Runtime Verificationで以下は確定済み。
  ```text
  P05-I03 Existing Only:
  PASS

  P05-I09 Template / Scan Technical Failure:
  PASS
  ```

- 先行Source/Compatibility Reviewで以下もPASS済み。
  ```text
  I10
  I11
  I12
  I13
  I14
  I15
  I17

  K01
  K02
  K03
  K04
  ```

- P2-05 VerificationはFormal MVP Testではない。
  - Formal MTS PASSはまだ主張しない。
  - Formal MVP TestはP7 Test Candidate Build以降。

---

## 未解決事項

- **WordEditor初回Failureの正確なRoot Causeは未確定。**
  - 現時点では推定のみ：
    ```text
    Intermittent Outlook / WordEditor COM state
    または
    transient session-specific WordEditor readiness condition
    ```
  - 具体的に以下のどれだったかは未確認。
    - Outlook内部初期化
    - Inspector初期化
    - WordEditor初期化
    - COM Proxyの一過性状態
    - Office Processの一過性状態

- `OBS-P2-05-002 Intermittent WordEditor E_FAIL`はOPEN。
  - 再発条件：
    ```text
    Fresh Warm RunManualSyncでWordEditor E_FAIL再発
    または
    実運用/Regressionで繰り返し発生
    ```
  - 再発時は、そのSessionを壊さず直後に：
    ```text
    TestP205DiagImmediateNoGuard
    ```
    を実行して切り分けを再開する。

- P2-05 Runtime Verificationの残ケース：
  ```text
  I01 Mixed Result
  I02 New Only
  I04 Reactivated Only
  I05 Unused Only
  I06 Zero-diff Success
  I07 Invalid Candidate
  I08 OFT Missing
  I16 Fresh Retry
  ```

- `I16 Fresh Retry`はまだ未確定。
  - WordEditor事象からの回復はControlled Fixtureではないため、I16 Evidenceとして使用しない。

- P2-05 Verification完了後に必要：
  ```text
  Regression
  ↓
  Final Static Review
  ↓
  Final Finding Assessment
  ```

- P2-05 COMPLETEはまだ未成立。

- P2 Phase COMPLETEはまだ未成立。

- CP-P2はまだ確立していない。

- Manual Sync Buttonはまだ作成していない。
  - 現状は`Alt + F8 → RunManualSync`で実行。
  - Button具体配置は現在のProduction Code Patchには含めていない。
  - 後続UI Integrationで必要性を確認する。

---

## 次アクション

### 優先度1：P05-I07 Invalid Candidate

次のチャットでは、まずここから再開する。

推奨Fixture：

```text
OFTへ意図的にInvalid Candidateを追加
例：
{{Bad-Name}}
```

確認すること：

```text
RunManualSync
→ Failure

Invalid Candidateが表示される

Success Notification:
0

syncDiffResult:
Nothing

VariableDefinition:
更新なし
```

見るべきファイル・論点：

```text
modUiController_P2-05_v0.1_CP932.bas
modSyncApplication_Current.bas
MVP Requirements FR-SYNC-008
P2-05 Implementation Specification
P05-I07
```

### 優先度2：P05-I16 Fresh Retry

I07と連続して実施する。

手順：

```text
1. Invalid CandidateでI07 Failure確認
2. OFTからInvalid Candidateを修正
3. 自動Retryなしを確認
4. ユーザーが再度RunManualSync
5. Current OFTを再取得してSuccess
```

確認ポイント：

```text
Previous resultを再利用しない
新しいManual Operationとして処理
Current Templateを再Scan
Current VariableDefinitionを再取得
Fresh SyncTimestamp
```

### 優先度3：P05-I08 OFT Missing

Fixture：

```text
MailTemplate.oftを一時退避
または
TemplatePathが指す実ファイルを一時的に不存在状態へする
```

確認：

```text
Failure Notification = 1
Success Notification = 0
VariableDefinition更新なし
Outlook処理へ進まない
```

終了後OFTを必ず復元。

### 優先度4：Success分類ケース

順次実施：

```text
I02 New Only
I04 Reactivated Only
I05 Unused Only
I01 Mixed Result
```

各CaseではOFTとVariableDefinitionのFixtureを明確に記録する。

特にI04：

```text
Unused VariableをOFTへ再登場
→ 復活
```

を確認し、

```text
継続へマージされない
既存設定が保持される
```

ことを確認する。

### 優先度5：I06 Zero-diff Success

注意：

```text
通常の「変更なし」
≠
Zero-diff
```

Active VariableがTemplateに存在すれば`Existing`に分類されるため、全4分類0件になるFixtureを別途設計する必要がある。

Fixture設計は次チャットで慎重に決める。

### 優先度6：P2-05 Verification Completion

全Applicable Case完了後：

```text
Verification Evidence Consolidation
↓
Regression
↓
Static Review
↓
Final Finding Assessment
```

へ進む。

---

# 記事用素材

## 気づき

- **「テストでPASSした」と「Production実行でPASSした」は別物。**
  - P1-02/P1-03がPASSしていても、最初の`RunManualSync`ではWordEditor Failureが発生した。
  - Integration Pointで実際に動かすVerificationが必要。

- **逆に、1回のFailureだけでProduction Codeを直すのも危険。**
  - 今回は最初に2回連続でWordEditor Failure。
  - しかしコードを一切変更せず、その後すべてPASS。
  - もし最初の段階で`DoEvents`や`Sleep`を入れていたら、「直ったように見えるだけ」の修正になっていた可能性がある。

- **再現しない不具合を無理に修正しないことも品質管理。**
  - 根本原因未確定。
  - Production Correctionなし。
  - Blocking Findingを閉じつつ、Observationとして残す方式を採った。

- FindingとObservationを分けると、問題を「なかったこと」にせず前へ進める。
  ```text
  IF-P2-05-001
  → CLOSED AS NON-REPRODUCIBLE

  OBS-P2-05-002
  → OPEN / NON-BLOCKING
  ```

- **責務境界があるとデバッグ範囲を絞りやすい。**
  - UI：
    - Result Consumer
  - Application：
    - Orchestration
  - Outlook Adapter：
    - Inspector / WordEditor / COM Lifecycle
  - そのためWordEditor FailureだからといってUIやApplicationへCOM回避コードを混ぜずに済んだ。

- **Diagnostic TestはProduction変更前に作る価値が高い。**
  - A：Immediate / No Guard
  - B：Immediate / File Guard
  - C：DoEventsあり
  - 3ケースすべてPASSだったことで、単純な`DoEvents`不足説を棄却できた。

- **「仮説を立てる → 最小試験で潰す」流れが有効だった。**
  - Cold Start説
  - stale reference説
  - Source Drift説
  - `ReadSubject → ReadBodyText`説
  - `Dir$`説
  - `DoEvents`説
  - Session-dependent COM State説
  - という順にEvidenceで範囲を狭めた。

- **同一Sessionの状態変化もEvidence。**
  - Failure x2
  - その後PASS x多数
  - Production Code変更なし
  - これだけでもDeterministic Logic Defectの可能性を下げられる。

- **「原因未特定」と「何も分からない」は違う。**
  - Root Causeは未特定でも、
    - UI defectではなさそう
    - Application Source Driftではない
    - `Dir$`ではない
    - 単発`DoEvents`ではない
    - Fresh Warmでは再現しない
  - まで絞れている。

- **Formal TestとImplementation Verificationを分ける運用が効いた。**
  - 今回のPASSはP2-05 Implementation Verification。
  - Formal MTS PASSではない。
  - Evidenceの意味を過大評価しない。

---

## 記事にできそうな切り口

### 開発日記向き

- **「直してないのに直った」不具合とどう向き合ったか**
  - WordEditor E_FAIL発生
  - 再実行してもFailure
  - P1 TestはPASS
  - DiagnosticもPASS
  - Fresh Sessionでは再現せず
  - 最終的に「修正しない」を選んだ経緯

- **AIと一緒にバグを追うとき、すぐコードを書かせない**
  - 原因候補を順番に狭める
  - Diagnostic Testだけ作る
  - Productionは触らない
  - Evidenceが揃うまでPatchしない

- **個人開発でもFinding Managementをやってみた**
  - Finding ID
  - Blocking / Non-blocking
  - Root Cause
  - Disposition
  - Reopen Condition
  - Observationへの降格

- **「PASSしたから終わり」ではなく、Failureの再現性を見る**
  - 1回のPASS
  - 2回連続PASS
  - Fresh Session PASS
  - 条件を変えながらEvidenceを積む開発日記

- **MVPなのにここまでやる？――やりすぎと品質保証の境界**
  - Sleep / Retryを入れずに止めた判断
  - YAGNIとFail Closedの両立
  - 根本原因が分からないときの撤退ライン

- **ボタンすらない段階でManual Syncを完成させる**
  - `Alt + F8`
  - `RunManualSync`
  - UI Controlより先にUse Caseを完成させる進め方

---

### 技術記事向き

- **VBA + Classic OutlookでInspector.WordEditorを安全に扱う**
  - `MailItem.GetInspector`
  - `Inspector.WordEditor`
  - `Word.Document`
  - Display前アクセス
  - Explorer Readiness
  - Warm / Cold Start差

- **Classic Outlook Cold StartでHidden Explorerが失敗した理由をどう扱ったか**
  - Hidden Explorer FAIL
  - Visible Explorer PASS
  - `DoEvents`
  - Explorer Lifecycle
  - Scan MailItem自体はDisplayしない

- **VBAでCOMの一過性Errorを追跡する方法**
  - `E_FAIL / -2147467259`
  - FailureのLayer切り分け
  - State cleanup
  - Same-session retry
  - Fresh-session reproduction
  - Diagnostic-only Module

- **「DoEventsを入れれば直る」を疑う**
  - A/B/C Diagnostic
  - Productionへ入れる前にTest Harnessで検証
  - PASSしたからといって修正しない理由

- **Result Patternを使ったVBA Fail Closed設計**
  - `COperationResult`
  - `CErrorInfo`
  - `Success`
  - `Errors`
  - `Message`
  - `Target`
  - UIはResult Consumer
  - Runtime ErrorをMsgBox直結しない

- **Application / Adapter / UIの責務分離がデバッグで効く例**
  ```text
  modUiController
  ↓
  modSyncApplication
  ↓
  modOutlookAdapter
  ```
  - COMはAdapterへ閉じ込める
  - UIからInfrastructureへ直接アクセスしない
  - Error PresentationとError Detectionを分ける

- **Sync Resultを再計算せずCarrierから表示する設計**
  - `SyncDiffResult`
  - New / Existing / Reactivated / Unused
  - UIで再分類しない
  - Reactivated→復活
  - Persisted ResultをPresentation Source of Truthにする

- **VBAでCurrent Source ReviewをGate化する**
  - Specificationだけで実装しない
  - 実Production API/Carrierを確認
  - Expected Change Scope
  - Formal Patch Scope
  - Patch Design
  - Implementation
  - Compile
  - Verification

- **非再現バグのClosure設計**
  ```text
  Finding:
  CLOSED AS NON-REPRODUCIBLE

  Observation:
  OPEN / NON-BLOCKING
  ```
  - Root Cause未確定でも前進する基準
  - Reopen条件を明示する

---

## 有料note / テンプレート化候補

- **AI協働開発用「Production Source Review Checklist」**
  - Public API
  - Concrete Carrier
  - Current Module有無
  - Name Collision
  - Dependency Direction
  - Current UI Wiring
  - Source Drift
  - Expected Scope → Formal Scope

- **Production Patch Design Template**
  - ADD / MODIFY / REUSE / DELETE
  - Public Entry
  - Private Responsibility
  - Non-responsibility
  - Dependency
  - Fail Closed
  - Verification Hook
  - Compile Gate
  - Finding Rule

- **Intermittent Bug Investigation Template**
  ```text
  Initial Symptom
  Reproduction Count
  Same-session Retry
  Fresh-session Retry
  Lower-layer Direct Test
  Source Drift Check
  Diagnostic Variant
  Production Change禁止期間
  Root Cause Status
  Reopen Condition
  ```

- **COM / Outlook障害切り分けチェックリスト**
  - Warm / Cold
  - Explorer Count
  - Inspector Count
  - Draft Count
  - Active MailItem
  - `GetInspector`
  - `WordEditor`
  - Cleanup
  - stale reference
  - Same-session / Fresh-session比較

- **「修正しない判断」チェックリスト**
  - 再現するか
  - Deterministicか
  - Source Driftか
  - Diagnosticで仮説を再現できるか
  - 修正場所の責務は正しいか
  - Patchが症状隠しになっていないか
  - Reopen条件を設定できるか

- **Implementation Verification Case Template**
  ```text
  Case ID
  Preconditions
  Fixture
  Execution
  Expected
  Actual
  Evidence
  PASS / FAIL / BLOCKED / N/A
  Cleanup
  ```

- **Finding → Observation移行テンプレート**
  ```text
  Finding ID
  Original Symptom
  Reproduction Evidence
  Root Cause
  Production Defect判定
  Production Correction
  Disposition
  Residual Observation
  Blocking Status
  Reopen Condition
  ```

- **AIへのバグ調査プロンプト集**
  - 「コード変更せず原因候補を3層に分けて」
  - 「各仮説を最小Testで棄却する順序を作って」
  - 「Production責務を壊さないDiagnostic Testを設計して」
  - 「PASSしたEvidenceとRoot Cause確定を分けて整理して」
  - 「Findingを閉じる条件とObservationへ落とす条件を定義して」

- **P2-05 Verification Runbook**
  - I01～I17
  - K01～K04
  - Runtime / Source / Evidence Reuse分類
  - Formal Testとの境界
  - Regression
  - Static Review
  - Finding Assessment
  - Completion判定