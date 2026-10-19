# 引き継ぎまとめ

## 実施内容

### 1. 対象と今回の到達点

- プロジェクト：定型メール作成ツール（Excel VBA + Classic Outlook）。OFTを読み取り、`{{VariableName}}`をExcelの変数定義に基づいて置換するMVP。メールは表示までとし、自動送信しない。
- 今回の主題：P2-01～P2-04 Regressionの実行Build／Production Sourceの出所を明らかにし、P2-02／P2-03の過去EvidenceをP2-04 I12 Contract Regressionに適用すること。
- **2026-10-19時点の評価**：P2-02 `111/111 PASS`、P2-03 `46/46 PASS`、P2-04新Cycle `182/182 PASS`。I12は **TECHNICAL PASS / REVIEWED**。一方、GitHub上の正式なRegression Record／I12 Closure、Document Registry、Evidence Archiveへの反映は**未実施**。P2-05 Completion、P2 Phase Exit、CP-P2、Formal MVP Testは未判定。

### 2. GitHubのProduction Sourceと実行Workbookを識別

- 当初「GitHubが古い」と説明していた対象を明確化。GitHubルートの`MailGeneratorNew.xlsm`はユーザーがRegressionを実行したWorkbookとは別の古いファイル。`src/modules/`には古い／未整備のソースが残る一方、**`Docs/02_implementation/`内に新しい版付きProduction Sourceが存在**した。GitHub全体のProduction Sourceが古いという意味ではない。
- Regression実行Workbook名：`MailGeneratorNew.xlsm`。GitHubとは別フォルダの、より新しいWorkbookを使用した（ユーザー確認）。
- 実行WorkbookのSHA-256（**ユーザー申告・Workbook現物の再計算なし**）：`0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`。
- 2026-10-18 Regression終了後のProduction Source変更：なし（申告）。同日Regression終了後のWorkbook保存：なし（申告）。ただし**I11試験手順内にはWorkbook保存が含まれており、終了後の保存なしと混同しない**。
- `P2-04_Regression_20261018.zip`から9モジュールを読取り、GitHub版付きファイルと照合。**9/9 正規化全文一致**（改行・VBE由来の大文字小文字差異を正規化）。大文字小文字が重要な文字列リテラルも別途照合。Rawバイトの完全一致やWorkbook全体の一致とは主張しない。
- 照合対象：
  - `modTemplateScanner` → P2-01 v0.1.1
  - `modSyncEngine` → P2-02 v0.1.3
  - `modVariableDefinitionData` → P2-03 v0.1.2
  - `modSyncApplication` → P2-04 v0.1
  - `modUiController` → P2-05 v0.1
  - `modOutlookAdapter` → P1-07 v0.1.1
  - `modSettingsData` → DF-P1-001 v0.1
  - `COperationResult`／`CErrorInfo` → GitHub保存版
- ユーザーが、**P2-01～P2-04の対象Regressionは同じ上記9 Production Modulesを使って実施した**と明示申告。これは実行者証言であり、過去のWorkbookバイナリを独立検証した証明ではない。
- GitHub参照時の`main`：`edf5c5175b103e250144341071d885a3a992c65f`。GitHubルートの古いWorkbookのGit Blob：`c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`（実行版SHA-256と別物）。

### 3. 生ログ・過去Recordの照合

- **P2-04：** `261018_P2-04_Regression Log.txt`（439行）を読取り、Bootstrap `29/29`、I03 `10/10`、I04 `11/11`、I05 `17/17`、I06 `22/22`、I07/I08 `37/37`、I09 `16/16`、I10 `20/20`、I11 `20/20`、合計 **182/182 PASS、FAIL 0** を確認。I03～I11は153件。
- I10の最初の実行は`I10 baseline has not been prepared in this VBA session`で**ABORTED**（Production Path未実行）。Baseline準備後に20/20 PASS。ABORTを隠したりPASS件数に加算しない。
- I07シート保護中の書込失敗はExpected Failure。I08の明示的RetryはFresh Stateを使用してSuccess。I07でデータ不変が観測されても**Rollback／Atomicityの一般保証ではない**。
- I09 Warm Outlook、I10 Cold OutlookでExplorer確立、Inspector／Draft残存なし等を確認。I11はWorkbook再オープン時に自動同期せず、明示Sync時のみ更新するManual Onlyを検証。
- **P2-02：** `261018_P2-02_Regression Log.txt`を照合。6 Suite＝Bootstrap 33、Detection History 43、Excel Date Serial 9、Core 18、Negative 6、Compatibility 2、合計**111/111 PASS、FAIL 0**。末尾にBootstrap 33件の再掲があるが、重複加算しない。元Regression Record v0.1の記録日は2026-10-10。
- **P2-03：** `261018_P2-03_Regression Log.txt`を照合。5 Suite＝Bootstrap 7、Detection History 6、Core 12、Negative 18、Compatibility 3、合計**46/46 PASS、FAIL 0**。各Suiteに`Original tblVariableDefinition contents restored.`の出力あり。書式・数式等を含むWorkbook全体の完全復元は主張しない。元Regression Record v0.1の記録日は2026-10-11。
- **P2-01：** `P2-01 Full Template Scanner Regression Record v0.1.md`は既存**PASS / CLOSED**。Core 11/11、OFT／Recipient関連の歴史的EvidenceをI12に再利用。
- P2-04の旧CompletionにあるI01/I02は**過去の補足Evidence**。今回の新規実行として扱わない。旧Completion上のProduction Revisionの記載が今回の9 Sourceと必ずしも一致しない点も原記録のまま保持。
- **件数の扱い**：過去P2-02 111件、過去P2-03 46件、今回P2-04 182件は別のテスト系列。合算して「339件を10月18日に同一Workbookで新規実行した」と表現しない。

### 4. Baseline／Compile／Fixture／Finding

- GitHubの`Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`を確認。**BL-MVP-004 APPROVED（2026-10-01）**。BL-MVP-003は承認履歴上SUPERSEDED。ただし`Document_Registry.md`／`Project_Overview.md`には受入・同期状態としてBL-MVP-003が残る。Approval Recordの存在とGitHub Registryの正式受入／同期は別作業。
- `2026-10-10 Debug > Compile VBAProject = PASS`（ユーザー申告／過去報告）。**Compile PASS後、Production Modules・Test Harnessを含むVBAProjectへ追加／変更なし**と2026-10-19に追加確認。よって10月18日Regression時のVBAProjectにもCompile PASSを適用可能と評価。10月18日再Compile実施とは記録しない。Compile独立実行ログ・Workbook現物は未取得。
- `MailTemplate.oft`は元へ戻した、`Settings.TemplatePath`は意図した値、とユーザー申告。I03生ログにはOFT復元そのものの出力がないため、USER-ATTESTED復元として記録。I04単体ではTemplatePath復元PASSログあり。
- `OBS-P2-05-002`（WordEditor断続的E_FAIL）は**OPEN / NON-BLOCKING**のまま。I06のPreflight見出しに`I05`と出る誤記はNON-BLOCKING Test Artifact。今回照合範囲で新たなBlocking Production Regressionは識別されなかったが、Project全体のFinding Registerで`Active=0`を独立認定したわけではない。

### 5. 審査と作成・更新ドキュメント

- I12で旧Guide（直接再実行）と後続Regression Plan（過去Evidence再利用）に差異があると判明。2026-10-16にGitHubへ登録された`P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`を今回の運用として採用する判断文書を作成。
- Source／Build照合：`P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md`（最新）。
- 過去Evidence適用評価：`P2-04_I12_Historical_Regression_Evidence_Applicability_Assessment_v0.1_Draft.md`。
- P2-02／P2-03原文照合追補：`P2-02_Sync_Diff_Core_Regression_Raw_Evidence_Addendum_v0.1_Draft.md`、`P2-03_Sync_Persistence_Regression_Raw_Evidence_Addendum_v0.1_Draft.md`。
- P2-04新CycleのRegression Record：`P2-04_Manual_Sync_Integration_Regression_Record_v0.3_Draft.md`。
- P2-02／P2-03正式Closureのレビュー候補：`P2-02_Sync_Diff_Core_Regression_Closure_Review_v0.3_Candidate.md`、`P2-03_Sync_Persistence_Regression_Closure_Review_v0.3_Candidate.md`。
- I12実行方式の決定：`P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md`。
- I12最終技術審査：`P2-04_I12_Final_Quality_Gate_Assessment_v0.3_Review_Result.md`。**TECHNICAL PASS / REVIEWED**、Repo Formal ClosureはPending。
- I12 Evidence対応マトリクス：`P2-04_I12_Evidence_Reconciliation_Matrix_v0.8_Draft.md`。
- Evidence保管候補一覧：`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`。
- ZIPパッケージ：`P2-02_P2-03_Regression_Evidence_Bundle_20261019.zip`、`P2-04_I12_Final_Quality_Gate_Review_Package_20261019.zip`、`P2-04_I12_Review_Update_20261019.zip`、最新版の継続性追補`P2-04_I12_Compile_Continuity_Update_20261019.zip`。各ZIPの収録範囲はREADME／Manifestで確認。最新版ZIPだけで全履歴を包含しているとは限らない。
- 生ログ原本／コピー：`261018_P2-02_Regression Log.txt`、`261018_P2-03_Regression Log.txt`、`261018_P2-04_Regression Log.txt`、`P2-04_Regression_20261018_Raw.txt`。原本は改変せず、ハッシュを記録。
- この会話ではMarkdown候補ファイルを作成したが、**GitHubへのCommit／Push、正式Record／Registryの書換えは未実施**。

## 決定事項

- **I12実行方針**：2026-10-16登録の後続Regression実施計画を優先し、P2-01／P2-02／P2-03の過去Evidenceを再利用してI12を評価する方式を**ユーザーが明示承認**。旧I12 Guideの直接再実行方式は履歴として保持。全面再実行は現在のEvidenceからは要求しない。
- **Production Sourceの範囲**：提供した9モジュールをP2-01～P2-04 Regressionで共通使用したことをユーザーが明示確認。GitHubとの9/9正規化一致をEvidence再利用の判断材料として採用する。
- **Compile履歴**：10月10日のCompile PASS以後、Production Module／Test Harnessの追加・変更なしとユーザー確認。10月18日のVBAProjectへの適用を受入れ。ただし10月18日再Compileと記載しない。
- **Fixture最終状態**：`MailTemplate.oft`復元済み、`Settings.TemplatePath`は意図した値であることを実行者の確認として採用。実物／ログによる独立証明とは区別する。
- **Evidenceカウント**：P2-02 Bootstrap再掲を二重集計しない。P2-04 I10初回ABORTは履歴として保持し、後続20/20 PASSと分離する。I01/I02旧Evidenceは補足用途に限定する。
- **判定境界**：I12は**TECHNICAL PASS / REVIEWED**。P2-02／P2-03は技術PASSかつ正式Closure推奨。ただし、**GitHubの正式Record／Registryを`CLOSED`に変更したことにはしない**。P2-05 Completionなど別Gateは判定しない。

## 未解決事項

- **正式Evidence Archiveの確定と登録**：原文ログ3件、Source ZIP、ハッシュ、各Review／Decisionをどの正規フォルダ・アクセス権限で保存するか。原文にWindows個人ユーザーパスがあるので公開GitHubへの無加工掲載は慎重に扱う。非公開原本とマスキング版の分離も検討。
- **P2-02／P2-03 Regression Recordの正式Closure**：GitHub既存の各`Regression Record v0.1.md`はDRAFT／CLOSURE PENDING。Closure Review v0.3 Candidateを用い、原Record履歴を維持した改訂・承認とRegistry反映が必要。
- **I12正式Closure**：技術PASSを正式なI12 Closure Record、P2-04 Regression Record、Document Registryに反映する作業。承認・登録フローは未実施。
- **Project Control／Baseline同期**：BL-MVP-004 Approval Recordは承認を記録しているが、Registry／Project OverviewではBL-MVP-003を受入・同期状態として維持。正式な更新方針と範囲を確定する必要がある。履歴を無言で書換えない。
- **I01/I02の履歴差異**：旧Completion上のSource Revisionは現行9モジュールと異なる記述を含む。補足Evidenceの限界を正式マトリクスでも維持。
- **Final Finding全体判定**：今回のRegression資料から新規Blocking Findingは見つからないが、Project全体のFinding RegisterのActive／Blocking 0は未独立照合。`OBS-P2-05-002`は継続OPEN／NON-BLOCKING。
- **P2-05 Completionの後続Gate**：現時点のVBAProjectで最終Compile（新たな証拠）、Static Review S01–S32、Production Patch Review、Final Finding Assessment、その後P2-05 Completion判定。さらにP2 Phase Exit／CP-P2、Formal MVP Testは別Gate。
- **Workbook現物の独立確認**：2026-10-18 Workbook SHAは申告値。現物バイナリ／VBAProject全体、過去Workbook Hash、書式・数式等を含む完全Fixture復元は未検証。I12技術判定では申告の限界を明示したうえで再利用を受容している。

## 次アクション

1. **最優先：Evidence保管方法と登録先を確定**。`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`、Raw 3ログ、`P2-04_Regression_20261018.zip`、`P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md`から開始。`Docs/03_verification/technical_validation/`とDocument Registryへのトレーサビリティを設計。原文を非公開保全し、必要に応じて公開版のみマスク。
2. **P2-02／P2-03正式Regression Recordの改訂とClosure審査**。GitHubの`Docs/03_verification/technical_validation/P2-02 Sync Diff Core Regression Record v0.1.md`および`P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md`を確認し、それぞれ`...Closure_Review_v0.3_Candidate.md`を参照。原文ログ・Baseline・Source・Compile申告・Fixture・Findingの根拠を明示して、所定の版管理・承認に従い`PASS/CLOSED`反映を判断。
3. **I12正式Quality Gate／Document Registry反映**。`P2-04_I12_Final_Quality_Gate_Assessment_v0.3_Review_Result.md`、`P2-04_I12_Evidence_Reconciliation_Matrix_v0.8_Draft.md`、`P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md`を起点に、I12 Closure Record・P2-04 Regression Record・`Docs/00_project_control/Document_Registry.md`を整合更新。旧Guideは履歴維持。
4. **Baseline管理の同期方針確認**。`Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`と`Document_Registry.md`、`Project_Overview.md`を突合。Approval RecordとLocal Acceptance Stateを分けて扱い、管理手続を踏む。
5. **P2-05 Completion準備**。Approved P2-05実施仕様・Completion Criteriaに対して、現行VBAProjectの最終Compile、Static Review S01–S32、Production Patch Review、Final Finding Assessmentを計画。I12 PASSをP2-05 COMPLETEやCP-P2へ自動昇格させない。
6. **必要時のみ追加確認**：正式Evidence保存先／アクセス権限、GitHub側で既存文書の改訂・Commitを開始する権限・方針、P2-05最終Compile結果。既に確認した10/10 Compileや9 Source同一性を再質問しない。

**次のチャット冒頭で伝える要点**：『I12技術審査はPASS、Evidence再利用方針は承認済み。P2-02 111/111、P2-03 46/46、P2-04 182/182の原文ログと9 Production Sourceの対応を照合済み。10/10 Compile PASS以降VBAProjectの追加・変更なしも確認済み。次は新テストではなく、Evidenceの正規保管・独立Regression Recordの正式Closure・I12／Document Registry反映から再開。P2-05 Completionは別Gate。』

---

# 記事用素材

## 気づき

- **GitHubに最新Sourceがあることと、GitHubのWorkbookが最新であることは別**。`src/modules/`のファイルだけを見ると古く見えても、版付きソースが`Docs/02_implementation/`に存在していた。正本の配置とBuild同一性が混乱の原因になり得る。
- **ソース一致と実行バイナリ一致は違う**。9/9正規化一致は有力だが、Workbook全体のSHA一致や当時の実行環境まで証明しない。どの主張が原文・ファイル・ユーザー申告に依存するか明示すると、レビューが健全になる。
- **PASSとClosureは別**。P2-02 111、P2-03 46、P2-04 182がPASSでも、原文保存、Baseline、Build Provenance、Finding、正式Record改訂が別途必要になる。
- **再実行だけが正解ではない**。同じSource、既存Raw Evidence、旧／新テスト計画の差を確認し、変更影響を分析して過去Evidenceを再利用する判断ができる。
- **履歴の意味を厳格に保つ**。I10 ABORT、再実行PASS、P2-02 Bootstrap33再掲、I01/I02の旧Revisionはそれぞれ別の事実。都合のよい「全部PASS」へ単純化しない。
- **Negative Testは「起きないこと」を証明する**。失敗時にDiffを公開しない、Workbook Openで自動同期しない、失敗後に勝手にRetryしない、OutlookにInspector/Draft残存がないことをAssertion化できる。
- **復元確認には範囲がある**。`tblVariableDefinition`のセル値を元へ戻したことと、書式／数式／入力規則／Workbookバイナリの完全復元は異なる。
- **ユーザー申告は無価値でも万能でもない**。観測ログの不足を補強できるが、独立検証した証拠に変化させない。`USER-ATTESTED`を明記することで活用しやすくなる。
- **技術的合格とドキュメントの正本更新は非同期になりやすい**。文書候補ばかり増やさず、承認・Registry・保管先を一度に整合する作業が必要。

## 記事にできそうな切り口

### 開発日記向き

- 「339という数字の落とし穴：過去Regressionと今回Regressionを一緒に数えない」— 111＋46＋182の意味を分離した経緯。
- 「テストは全部PASSなのに開発が終わらない」— 個人開発でEvidence／Quality Gate／Closureまで管理した体験。
- 「GitHubにあるのに最新版が見つからない」— `src`と版付きDocs、古い`.xlsm`の違いを洗い出した話。
- 「AIとの開発でBuildを見失いかけた」— 違うフォルダのWorkbookを使っていたことからのProvenance検証。
- 「ABORTをFAILと勘違いしない」— I10の事前条件未準備とCold Start再実行のプロセス。
- 「テストのやり直しをしないという品質判断」— Evidence再利用を承認した理由と残る不確実性。

### 技術記事向き

- Excel VBAの**Build Provenance／Source-to-Workbook Traceability**：ZIP Export、SHA-256、Git Blob、改行・エンコーディング正規化、VBEによる大文字小文字差異。
- **Evidence Reuse Decision Matrix**：Approved Baseline、Contract、Source Revision、Raw Test Log、Compile continuityを用いたI12判定モデル。
- **Fail Closed × Result Carrier**：`COperationResult`、`templateScanResult`、`syncDiffResult`と失敗発生レイヤー別の公開条件。
- **Manual Syncの状態遷移とFresh Retry**：`BuildSyncDiff`→`ApplySyncDiff`、Active／Unused／Reactivated、`SyncTimestamp`、永続化失敗後の手動再実行。
- **Outlook COM Lifecycle Test**：Warm／Cold Start、Explorer／Inspector／Draftの残存、WordEditor断続的E_FAIL。
- **Negative TestとNo-op Contract**：Workbook Openで同期しない、未置換候補を拒否する、既存UnusedがNo-opとなること。
- **品質記録のデータモデル**：Baseline Approval、Implementation Completion、Regression Record、Finding、Evidence Artifact、Closure Decisionを別エンティティとして扱う考え方。
- **Evidence保管セキュリティ**：生ログ不変性、SHA、個人パスのマスキング、非公開原本／公開版分離。

## 有料note / テンプレート化候補

- `Regression Evidence Archive Manifest Template`：File、SHA-256、Run、Build、Contract、Fixture、Visibility、Canonical Storage Path。
- `Build Provenance Verification Checklist`：Workbook Hash、VBA Export、Git Source Revision、Normalization、User Attestation、Limits。
- `Regression Closure Review Template`：PASS/FAIL/ABORT、Baseline、Build、Raw Log、Finding、Formal Disposition、Approver。
- `Evidence Reuse Decision Matrix Template`：過去Evidenceの適用条件とDirect Rerunの要否を分ける判断表。
- `VBA Compile Continuity Attestation Template`：Compile日時／結果、変更有無、対象VBAProject、独立検証の有無。
- `Fixture Restoration Checklist`：OFT、Settings、VariableDefinition、Status、Worksheet Protection、Temp File、Outlook Inspector/Draft、書式・数式。
- `Fail Closed Regression Test Matrix`：失敗フェーズ×ErrorType×Target×公開Carrier×永続化の有無。
- `I12 Quality Gate Prompt Pack`：原文ログ照合、重複集計の除外、Source一致、Finding、Closure判定のAIレビュー指示。
- `Project Control Synchronization Checklist`：承認済みBaseline、Document Registry、Project Overview、Completion、Evidence Indexの同期。
- `AI協働開発チャット引継ぎテンプレート`：確定事項とUser Attestationを分離し、次アクションと記事素材を蓄積する形式。
