# P3 Configuration Application — Current Snapshot取得・Validation接続 実装候補レビュー v0.1

> **Status: WORKING CANDIDATE / NOT APPROVED / NOT COMPILED / NOT EXECUTED**  
> 作成日: 2026-11-15  
> Unit呼称: **P3-02 (暫定的な作業識別子)**。P3正式Phase Entryを意味しない。  
> 作業条件: P2-05 Production現状維持、B2-02環境調査停止、P2 Closure未成立、S5-C正式Gate未承認、実機Compile未検証、隔離方式未採用。

## 1. 目的・参照基準

P3-01 `modConfigurationValidator` **既存Candidate v0.1** を変更せず、UserForm起動用に **最新OFT Scan + 全VariableDefinition + 必要なActive Option集合** を取得してValidatorへ接続するための、独立したApplication候補を作成した。

参照（読み取り）：

- Current Approved Baseline `BL-MVP-004`：`DOC-MVP-REQ v0.1.9` / `DOC-MVP-DES v0.1.10` / `DOC-MVP-TESTSPEC v0.1.6` / `DOC-MVP-IMPL v0.4`。
- `DOC-MVP-DES §16`（Configuration Validator責務）、`§24`（Result/Error）、`§25.2`（UserForm起動時にCurrent OFTを再Scan・同期なし）、`§25.3`（メール生成時の再検証は後続Unit）。
- `DOC-MVP-IMPL v0.4 §8.4`、`MTS-CFG-001～008`。
- P2-04既存 `modSyncApplication_P2-04_v0.1_CP932.bas`（特にPrivate `ScanCurrentTemplate` / MailItem cleanup）。P2-04 Private関数は外部契約として利用していない。
- P1-07 `modOutlookAdapter_P1-07_v0.1.1_CP932.bas`：`CreateMailFromTemplate` / `ReadSubject` / `ReadBodyText` / `CloseWithoutSave`。
- P2-01 `ScanTemplate`、P2-03 `GetAllVariableDefinitions`、P0 `GetActiveOptions`、`modSettingsData.GetSettingValue` / `ResolveWorkbookRelativePath`、`modResult`/`COperationResult`。
- 前回 `/mnt/data/P3-01_Candidate_Package/`内のProduction候補・22テストID・レビュー記録（**いずれも未承認**）。

添付のv0.3 Plan / v0.1.9 Designなどの旧版を現行Approvedより優先していない。過去のP2 Evidenceは当時の版のまま扱い、Baselineを遡及変更しない。

## 2. 成果物とPublic契約

| ファイル | 役割 | 実装状態 |
|---|---|---|
| `src/modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas` | **Production候補**：Current Snapshot取得＋P3-01 Validation接続 | 作成済み、実機未検証 |
| `tests/modP3_02TestStubs_v0.1_CP932.bas` | **隔離テスト専用**：Settings / Outlook / Scanner / Data Accessの依存APIを代替 | 作成済み、実行なし |
| `tests/modP3_02ConfigurationApplicationCandidateTests_v0.1_CP932.bas` | **隔離テスト専用**：23シナリオの期待Result/cleanup/cache/出力公開検査 | 作成済み、実行なし |
| `Docs/STATIC_REVIEW.py` | Python静的確認（VBA Compileではない） | 25/25 PASS |

```vb
' NEW CANDIDATE API — NOT PRODUCTION-APPROVED
Public Function PrepareCurrentConfiguration( _
    ByRef templateScanResult As Object, _
    ByRef allVariableDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult
```

- 戻り値の `Success=True` のときに限り3つの`ByRef`出力を公開する。`Failure` / `Nothing` Result / 先行Getter失敗なら3出力は `Nothing` のまま。
- `COperationResult`は既存クラス。Getterが返すFailureは**同一Result参照を保持**する（新Errorで上書きしない）。
- `modConfigurationApplication`は**UserFormを表示しない**。呼び出すUI/Application Controllerが`result.Success`を確認し、Failureなら起動しない契約。UI通知実装は別Unit。
- ValidatorにはOFT存在を事前確認したため `templateExists=True` と、**現時点で取得した**3つのCarrierを渡す。

### 2.1 Application手順

```text
明示的な「メール作成開始」イベント（後続Controller）
  → GetSettingValue("TemplatePath")
  → ResolveWorkbookRelativePath
  → Dir$ によるOFT存在確認（既存P2-04のGuard意味論に準拠）
  → CreateMailFromTemplate（Adapter内でOutlook Readiness）
  → ReadSubject / ReadBodyText
  → ScanTemplate（正規表現責務は既存Scannerだけ）
  → CloseWithoutSave（成功しない限りScan結果を公開しない）
  → GetAllVariableDefinitions（Active＋Unusedの全行）
  → Active / Select / OptionSource設定済みの各GroupへGetActiveOptions
       ※ OptionGroupはvbBinaryCompare、同じGroupは1回のみ取得
       ※ OptionSource欠落はGetterを呼ばずValidatorで設定Errorにする
  → ValidateConfiguration(True, scan, definitions, groupSnapshots)
  → Success時だけ3 Carrierを公開
  → ControllerでSortOrder＋__RowIndex安定順・UserForm構築（今回対象外）
```

**禁止**：`ExecuteManualSync`、`ApplySyncDiff`、`BuildSyncDiff`、VariableDefinitionの書込み、自動追加・自動Unused化、UserForm直接生成、リトライ、既存P2 Productionへの改変。

## 3. Fail Closed / Cleanupの制御規則

1. Settings/Resolve/存在確認/Adapter/Read/Scan/Definition/Option/Validator の**各段階**が`Failure`なら、そのResultを原則そのまま返して中止。
2. 先行処理が`Success`でも期待するCarrierが`Nothing`なら`UnexpectedError`を返して中止。
3. `CreateMailFromTemplate`成功後は、Subject/Body/Scanの結果を問わず `CloseWithoutSave` を1回試みる。`CloseWithoutSave`成功前に後続Data Accessは呼ばない。
4. Primary Scan失敗＋Cleanup失敗時、**P2-04の先例と同様にPrimary Resultを優先**する。Cleanup失敗だけの場合はCleanup Resultを返し、3つの出力を公開しない。
5. Runtime例外は `UnexpectedError` に変換し、可能ならCleanupへ進む。Cleanupの完了や安全性を実機で保証したものではない。
6. `InvalidCandidates`はScannerが返したCarrierをP3-01へ渡し、ValidatorがErrorとする。Applicationで独自のRegex判定や再Scanをしない。
7. Active/SelectのOptionGroupだけを取得し、Unused行やText/Dateから不要なOptionMaster参照を発生させない。
8. MailItemとCOMの内部参照管理は既存Adapterの責務であり、本ApplicationはMailItem Objectを保持・操作しない。

**Residual risk**：`CloseWithoutSave`の戻り値Failureは捕捉するが、実環境でCOM参照残留やMailItem解放を直接証明していない。Primary失敗とCleanup失敗の同時発生ではCleanup情報を返却Resultへ追加しない（既存first-error方針の限界）。

## 4. 前回からの未決4項目：候補判断・保留点

| 論点 | Current P3-01 Candidate | このReviewの判断案（**未承認**） | 扱い |
|---|---|---|---|
| **Required受容表現** | Boolean True/False、数値0/1、文字列`true`/`false`（大小文字不問・Trim）を受容 | Excelセル/既存`modOptionMasterData.ReadActiveValue`との整合を優先するなら現候補を維持。ただし`0/1`の明示的Required設定との同値性はレビューで確定 | **OPEN** |
| **SortOrder数値範囲** | `IsNumeric`、空欄/Boolean/Error等は拒否、重複許可、整数・小数・文字列数値は受容 | `FR-UI-003`が数値範囲を固定していないため任意の正数/整数制限を新設しない。ただし後続ソートが`CDbl`可能か、巨大指数値によるOverflowなどは実装前防御を検討 | **OPEN** |
| **Carrier異常時Error分類** | Scanner/Dictionary構造不正=`UnexpectedError`、設定不備=`ConfigurationError` | 壊れたAPI Carrierは`UnexpectedError`、ユーザーが修正できる設定値不備は`ConfigurationError`で維持。原因特定のTargetを残す | **OPEN（候補整合）** |
| **最初のエラーのみ返却** | P3-01はfirst-error、P3-02は先行Failureをそのまま伝播 | P2-04のPrimary優先と同様、最小Unitではfirst-error維持。複数Errorの集約/UI一回通知はP6または個別設計判断へ保留 | **OPEN（候補整合）** |

**重要**：本候補により4項目を承認済みに変更しない。P3-01 Source変更も行わない。

**追加のModule Mapping確認事項**：`DOC-MVP-IMPL v0.4 §8.4` のImplementation Scopeには`modConfigurationApplication`という独立Module名は明示されていない。本Candidateは責務を可視化するための新規Module案であり、正式採用前に「独立Moduleにするか、既存Application/Controllerへ配置するか」を判断する。今回の文書でImplementation PlanのModule Mappingを変更したものとは扱わない。なお`SortOrder`の`IsNumeric=True`だけでは`CDbl`変換時のOverflowを除外できない可能性があり、**次のソート実装の前に検査すべき具体的リスク**として残す。

## 5. 隔離Test Fixture 23シナリオ（定義済み／未実行）

テスト用Stubは**本番Data/Outlookモジュールと同じPublic名**を実装し、外部接続を行わない。Production VBA Projectへの混入は不可。`ValidateConfiguration`だけはP3-01 Candidate本体を使用する。

| Scenario | 入力・誘発する条件 | 期待Result | CleanUp呼出 |
|---|---|---|---|
| DEV-P3APP-01 | 正常なText / Template一致 | Success、3出力あり | 1 |
| 02 | Settings失敗 | ConfigurationError、出力なし | 0 |
| 03 | Path解決失敗 | ConfigurationError | 0 |
| 04 | 存在しないTemplatePath | ConfigurationError | 0 |
| 05 | Adapter CreateMail失敗 | OutlookError | 0 |
| 06 | ReadSubject失敗 | OutlookError | 1 |
| 07 | ReadBodyText失敗 | OutlookError | 1 |
| 08 | ScanTemplate失敗 | TemplateError（Stub注入） | 1 |
| 09 | MailItem Cleanup失敗 | OutlookError | 1 |
| 10 | GetAllVariableDefinitions失敗 | ConfigurationError（Stub注入） | 1 |
| 11 | GetActiveOptions失敗 | ConfigurationError（Stub注入） | 1 |
| 12 | Active DisplayName欠落 | ConfigurationError | 1 |
| 13 | InvalidCandidatesが非空 | ConfigurationError | 1 |
| 14 | Template未登録Variableあり | ConfigurationError | 1 |
| 15 | Active定義がTemplateにない | ConfigurationError | 1 |
| 16 | Select 2行で同じOptionSource | Success、GetActiveOptionsは1回 | 1 |
| 17 | Select OptionSource未設定 | ConfigurationError、Option Getter呼ばず | 1 |
| 18 | Select有効Optionなし | ConfigurationError | 1 |
| 19 | ScannerがSuccessかつCarrier Nothing | UnexpectedError | 1 |
| 20 | Definition GetterがSuccessかつCarrier Nothing | UnexpectedError | 1 |
| 21 | Option GetterがSuccessかつCarrier Nothing | UnexpectedError | 1 |
| 22 | ReadBodyText失敗＋Cleanup失敗 | Primary OutlookError / Target=`StubBodyError`を保持 | 1 |
| 23 | 大文字小文字不一致のOptionGroup | ConfigurationError（既存Binary契約） | 1 |

各Failureケースでは返却Carrier3件とも`Nothing`であること、通常Scanでは`CloseWithoutSave`呼出が1回であることを検査する。**これは実行されたテスト結果ではない。** Stubの`ScanTemplate`は合成Carrierを返すため、実際のRegex走査やWordEditorの振る舞いを検証しない。

### 5.1 テスト実行の前提・禁止事項

- 将来実行する場合も、**別途承認された隔離テスト用の保存済みWindowsローカル `.xlsm` Workbook**でのみ実施。`ThisWorkbook.FullName`をStub上の**存在するローカルファイル**として使い、`Dir$`検証する。`.oft`内容のテストではない。未保存、Web URL形式、実Production Workbook、同一モジュール名の競合がある場合はテスト不可。
- Import対象：`modConfigurationApplication`本Candidate、P3-01 `modConfigurationValidator` Candidate、`modResult`、`COperationResult`、`CErrorInfo`、**`modP3_02TestStubs`**、Runner。
- **Import禁止**：同じTest Workbookへ本物の`modSettingsData`、`modOutlookAdapter`、`modTemplateScanner`、`modVariableDefinitionData`、`modOptionMasterData`を同時Importしない。公開API名が衝突するため。
- 実機Excel / Outlook起動、Compile、テストRunner実行、Stubインポートは**今回一切していない**。このテスト構成は環境隔離方式の正式採用を意味しない。

### 5.2 Evidenceの区分

| 検証対象 | 現在のStatus |
|---|---|
| CP932 encode/decode・CRLF | **STATIC PASS** |
| Public API数、依存名、呼出順のソース構造 | **STATIC PASS** |
| Sync/Persistence/UI直接呼出の不在（文字列静的検査） | **STATIC PASS** |
| Test ID・Stubの定義、静的Block数 | **STATIC PASS** |
| `Docs/STATIC_REVIEW.py` | **25/25 PASS**（ソース文字列検査であり正しさの証明ではない） |
| `DEV-P3APP-01～23` | **DEFINED / NOT RUN** |
| VBA Import・VBA Compile | **NOT RUN / NOT VERIFIED** |
| 実Outlook MailItem Lifecycle・WordEditor | **NOT RUN / NOT VERIFIED** |
| Data Access実値互換・Form起動停止 | **NOT RUN / NOT VERIFIED** |
| Formal MTS-CFG-001～008 | **NOT RUN** |
| P2 Closure / CP-P2 | **NOT ESTABLISHED** |
| S5-C Gate / Final Build Compile | **NOT APPROVED / NOT VERIFIED** |
| P3正式Phase Entry | **NOT STARTED** |

## 6. 次に必要なレビューと将来の接続点

1. 上表4項目をApproved仕様と矛盾しないImplementation Detailとしてレビューする。`SortOrder`後続ソート実装前の`CDbl` Overflow対策は優先確認。
2. 対象となるP1-07 Outlook Adapter実物とP2-04 Production組込ビルドのAPI/SHA同一性を**将来の隔離テスト環境で確認**する。ここでは現行Repository候補ファイルを読み取っただけでありWorkbook実物の同一性確認はしていない。
3. `PrepareCurrentConfiguration`の成功を受け、**後続UI Controllerが`.Success=True`時のみ**SortOrder＋`__RowIndex`の表示順・UserForm生成へ進む配線を新規Candidateとする（今回未実装）。
4. `DOC-MVP-DES §25.3`のMail生成時再検証は別Unit。今回のUserForm起動前Checkの成功を、後続Mail生成時まで無条件に信用しない。
5. P2 Gate/Closureに必要な残項目とP3準備を**別トラック**で管理。P2-05 ProductionやEvidenceへ変更を加えず、B2-02調査へ戻らない。

## 7. GitHub予定配置（実際には未保存）

```text
MailGenerator/
├── Docs/02_implementation/P3_Configuration_UserForm/
│   └── modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas
├── tests/vba/P3_Configuration_UserForm/
│   ├── modP3_02TestStubs_v0.1_CP932.bas
│   └── modP3_02ConfigurationApplicationCandidateTests_v0.1_CP932.bas
└── Docs/00_project_control/reviews/
    └── P3-02_Current_Snapshot_Application_Integration_Candidate_Review_v0.1.md
```

**ProjectへのGit Commit / VBA Import / 実機実行 / Baseline更新はすべて未実施**。今回の実ファイルはChatGPT作業領域の`/mnt/data/P3-02_Application_Candidate_Package/`下にのみ作成。

## 8. まとめ / Summary

**日本語：** P3-01 ValidatorとつなぐP3 ApplicationのCurrent Snapshot取得候補と隔離テスト用23シナリオを作成した。静的検査25/25 PASSであり、VBA Compile・実行・Phase開始・P2 Closureはいずれも実施／成立していない。未決4項目は明示的にOPENとした。

**English:** We created a P3 Application candidate to get the current snapshot and call the P3-01 validator. We also prepared 23 local test scenarios. All 25 static checks passed. VBA tests and Compile were not run. P2 is not closed, and P3 has not officially started. Four review items are still open.
