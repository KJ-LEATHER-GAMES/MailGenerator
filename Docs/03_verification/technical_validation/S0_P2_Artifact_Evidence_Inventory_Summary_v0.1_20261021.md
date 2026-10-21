# S0 作業対象・Evidence棚卸し 結果まとめ v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール（Excel VBA + Classic Outlook） |
| 文書種別 | S0 Read-only Inventory 調査結果要約／S1引継ぎ |
| バージョン | v0.1 |
| 文書状態 | Draft（本書はCodex調査結果の整理。独立した実機・Repository再検証ではない） |
| 元資料 | `Pasted text(6).txt`（Codex S0 調査レポート、全10章） |
| 元調査日時 | 2026-10-21 20:05～20:12 JST |
| 整理日 | 2026-10-21 |
| 作業範囲 | S0：Repository・関連EvidenceのRead-only棚卸し |
| 後続 | S1 Evidence Archiveの保存・公開方針決定 |

## 2. 結論・判定境界

**S0：Inventory Complete。S1の保管方針検討へ移行可能。**

- 引継ぎ時に未受領だった**Raw Log 3件、Production Source ZIP、実行Workbook候補**をRepository外で発見・読取確認した。
- P2-02は**111/111 PASS**、P2-03は**46/46 PASS**、P2-04新Cycleは**182/182 PASS**の原文を照合した。P2-01は既存Record上でPASS/CLOSED。
- P2-04 I12は**TECHNICAL PASS / REVIEWED**。一方、P2-02・P2-03・P2-04の正式Regression Closure、I12 Documentary Closure、P2-05 Completion、P2 Phase Exitは**今回実施・承認していない**。
- **原本の正規保管先・公開範囲・責任者を確定するまでは、Archive登録・正式Closureを開始しない**。
- 調査はRead-onlyで完了。Working Treeは開始・終了ともClean。

> 判定上の注意：`PASS`の記録を確認したことは、S0で新規にテストを実行・合格認定したことではない。

## 3. 調査環境とRepository Snapshot

| 項目 | Codex調査結果 |
|---|---|
| ローカルRepository Root | `C:\Users\<user>\AppProjects\Mail_Generator` |
| Branch | `main` |
| HEAD | `d49d8c7c63379ac69cf0df40c1f16a89342d23e7` |
| HEAD日時 | 2026-10-19 23:50:41 JST |
| 引継ぎ参照HEAD | `edf5c5175b103e250144341071d885a3a992c65f` |
| 差分 | 14コミット・39ファイル変更。文書・Evidence・README等が対象 |
| 版付き実装Source／`src`／Workbook／OFT | 上記比較範囲で差分なし |
| Working Tree | 開始／終了ともTracked・Untracked・Staged変更なし |
| 調査先 | ローカルRepository、既知のDownloads／Temp／外部開発フォルダ |
| GitHubリモート最新状態 | **未確認**（fetch/pullなし） |

### Evidence確度の区分

| 区分 | 意味 |
|---|---|
| `REPO_VERIFIED` | Repository現物に存在し、内容・記録をCodexが読み取り確認 |
| `FILE_VERIFIED` | Repository外のファイル現物をCodexが読み取り確認 |
| `USER_ATTESTED` | 実行者申告（当時の状態の独立証明ではない） |
| `HANDOFF_ONLY` | 引継ぎ記録のみ |
| `UNVERIFIED` | 調査範囲で現物・根拠未確認 |

## 4. 重要Artifactの棚卸し

### 4.1 Project Control・基準文書

| Artifact | 現物・状態 | 主な課題 |
|---|---|---|
| `Docs/00_project_control/P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md` | REPO_VERIFIED / Draft・Not Approved | 保存済みと承認済みは別 |
| `Docs/05_handoff/Current_Handoff.md` | REPO_VERIFIED / v1.31 | 別PC記録の受入状態と区別 |
| `Docs/05_handoff/history/Context Handoff_25.md` | REPO_VERIFIED | 指定名`Context_Handoff_P2-04_I12_20261019(1).md`は未発見。近似資料 |
| `Docs/00_project_control/Document_Registry.md` | REPO_VERIFIED / v1.42 | Baseline Version列とManifest間に不一致 |
| `Docs/00_project_control/Project_Overview.md` | REPO_VERIFIED / v1.59 | 現在地が後続資料登録状況より古い |
| `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md` | REPO_VERIFIED / Approved（2026-10-01） | Registryへの当地受入・構成文書の正本確認が未完了 |
| `Docs/02_implementation/Implementation Plan v0.3 日本語版.md` | REPO_VERIFIED / Approved | Execution BaselineはBL-MVP-003 |
| P2-05 Implementation Specification v0.1 | REPO_VERIFIED / Approved | P2-05 Completion Gateの正式基準 |
| `Docs/00_project_control/rules/Folder_Management_Rules.md` | REPO_VERIFIED / v0.2 | 変更なし |

### 4.2 Regression・I12文書

| 対象 | 現物／記録Status | 未完了事項 |
|---|---|---|
| P2-01 Regression Record v0.1 | REPO_VERIFIED / **PASS・CLOSED** | 初回ReadBodyText失敗の厳密原因は未証明 |
| P2-02 Regression Record v0.1 | REPO_VERIFIED / **Draft・Closure Pending** | Closure Review v0.3 Candidateを正式反映 |
| P2-03 Regression Record v0.1 | REPO_VERIFIED / **Draft・Closure Pending** | Archive・Build・Fixture等を正式Dispositionへ反映 |
| P2-04 Regression Record v0.3 Draft | REPO_VERIFIED / **Draft・Closure Pending** | 182件、I12後続判定を正式化 |
| P2-04 I12 Execution Policy Decision v0.2 | REPO_VERIFIED / **Accepted** | 再利用方針維持。再承認なし |
| P2-04 I12 Final Quality Gate Assessment v0.3 | REPO_VERIFIED / **Technical PASS・Reviewed** | Documentary Closure Pending |
| P2-04 I12 Evidence Matrix v0.8 Draft | REPO_VERIFIED | §1にClosure Review v0.2旧参照 |
| P2-04 I12 Archive Manifest v0.1 Draft | REPO_VERIFIED | 正規保存先、Visibility、取得時点未確定 |
| Build Provenance Verification v0.4 Draft | REPO_VERIFIED | 作成時の「Workbook未取得」は今回の現物発見と時点が異なる |
| P2-02/P2-03 Raw Evidence Addendum v0.1 Draft | REPO_VERIFIED | 原文保管先未確定 |
| P2-02/P2-03 Closure Review v0.3 Candidate | REPO_VERIFIED | 技術Closure推奨だが元Record未承認 |

## 5. Production Source・実行Workbookの同定

### 5.1 9 Production Module

| Module | Repository上の照合候補 | 補足 |
|---|---|---|
| `modTemplateScanner` | P2-01 v0.1.1（`Docs/02_implementation/P2_Scan_Sync/`） | `src`に同名なし。旧P1-04版あり |
| `modSyncEngine` | P2-02 v0.1.3（同上） | `BuildSyncDiff`。旧Revisionあり |
| `modVariableDefinitionData` | P2-03 v0.1.2（同上） | `src`版は`ApplySyncDiff`なし |
| `modSyncApplication` | P2-04 v0.1（同上） | `ExecuteManualSync` |
| `modUiController` | P2-05 v0.1（同上） | `RunManualSync` |
| `modOutlookAdapter` | P1-07 v0.1.1（`Docs/02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/`） | `src`版は旧P1-01相当 |
| `modSettingsData` | DF-P1-001 v0.1（`src/modules/`） | 修正前版はArchiveに存在 |
| `COperationResult` | `src/classes/COperationResult.cls` | 公開：`Success`、`Errors` |
| `CErrorInfo` | `src/classes/CErrorInfo.cls` | 公開：`ErrorType`、`Message`、`Target` |

- 9件すべての内部`VB_Name`を確認。
- 外部Source ZIPと上記Repository候補を、復号・改行・終端改行・大文字小文字正規化後に比較し**9/9一致**。
- ダブルクォート内の文字列（大文字小文字を維持した列）も**9/9一致**。
- **元バイト列は9件すべて不一致**。Raw一致とは記載しない。
- Workbook内VBAProject全体との一致は**未検証**。過去の全Runで同じ9 Sourceを使用したことは**USER_ATTESTED**。

### 5.2 Workbook

| 対象 | SHA-256 | 判定 |
|---|---|---|
| Repositoryルート `MailGeneratorNew.xlsm` | `07336d8779f27039822539895c38fc8570c82fefc206ed83fb04672cb091a22e` | REPO_VERIFIED。引継ぎ申告実行版とは異なる |
| 外部開発フォルダの `MailGeneratorNew.xlsm` | `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` | **FILE_VERIFIED。引継ぎ申告SHAと一致** |

**確定範囲：** 申告SHAに一致するWorkbook現物が調査時点で存在したこと。**未証明範囲：** 過去の実行日時・未保存状態・VBAProject全体の構成・Compile履歴。

## 6. Raw Evidence／Archiveの所在

外部開発フォルダ（表示上の個人識別を省略）：`C:\Users\<user>\OneDrive\ドキュメント\MailGenerator`

| Artifact | 現物状態／場所 | SHA-256・内容 |
|---|---|---|
| `261018_P2-02_Regression Log.txt` | FILE_VERIFIED／外部開発フォルダ | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae`（233行／11,170 bytes） |
| `261018_P2-03_Regression Log.txt` | FILE_VERIFIED／外部開発フォルダ | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877`（100行／4,131 bytes） |
| `261018_P2-04_Regression Log.txt` | FILE_VERIFIED／外部開発フォルダ・Downloads | 下記RepositoryコピーとSHA一致（439行／19,812 bytes） |
| `Evidence/P2-04/2026-10-18/P2-04_Regression_20261018_Raw.txt` | REPO_VERIFIED／Git追跡済み | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` |
| `P2-04_Regression_20261018.zip` | FILE_VERIFIED／外部開発フォルダ | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7`（Production Export 9件） |
| `P2-04_I12_Final_Quality_Gate_Review_Package_20261019.zip` | FILE_VERIFIED／Downloads | 旧Review群・原文3ログなど11ファイル。最新版文書のみのBundleではない |
| `P2-04_I12_Compile_Continuity_Update_20261019.zip` | FILE_VERIFIED／Downloads | 最新更新文書5件＋README。Raw Log・Production ZIPは含まない |
| `P2-02_P2-03_Regression_Evidence_Bundle_20261019.zip` | UNVERIFIED／限定検索では未発見 | 紛失とは断定しない |
| `P2-04_I12_Review_Update_20261019.zip` | UNVERIFIED／限定検索では未発見 | 同上 |
| `IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md` | FILE_VERIFIED／Downloads | Findingは非再現としてClose。`OBS-P2-05-002`はOPEN/NON-BLOCKING。Repository未登録 |

- Repository内ZIP：**0件**。ZIP保存・展開・移動なし。
- Archive Manifest v0.1の主要SHAは発見現物と整合。
- 原文に個人パス・TEMPパス等が含まれるため、**Repositoryの公開/非公開・アクセス権を確認する前に原本公開しない**。
- 現在の外部保存場所をアクセス制御済みの正式Archiveとは認定しない。

## 7. Regression／I12結果とEvidenceの限界

| 項目 | 確認された技術結果 | Formal/Documentary Status |
|---|---|---|
| P2-01 | Core 11/11、OFT・Recipient Exclusion PASS（既存Record） | **PASS / CLOSED** |
| P2-02 | 生ログ再集計：**111/111 PASS、FAIL 0** | **CLOSURE PENDING** |
| P2-03 | 生ログ再集計：**46/46 PASS、FAIL 0** | **CLOSURE PENDING** |
| P2-04新Cycle | 生ログ再集計：**182/182 PASS、FAIL 0** | **CLOSURE PENDING** |
| P2-04 I12 | **TECHNICAL PASS / REVIEWED** | **DOCUMENTARY PENDING** |

記録時の注意事項：

1. P2-02のSuite内訳は`33+43+9+18+6+2=111`。末尾Bootstrap 33件は先頭と同一出力で**再加算しない**。「repeat execution」は原Record改訂時に確認する。
2. P2-04の内訳は`29+10+11+17+22+37+16+20+20=182`。I10初回**ABORT**は履歴として残し、PASS件数に含めない。
3. 旧P2-04 CompletionのI01/I02は**補足Evidence**。旧Revisionと今回9 SourceのRevisionは同一と断定しない。
4. I07 Expected Failure＋I08 Fresh Retryは、**Rollback／Atomicityの一般保証ではない**。
5. 2026-10-10 Compile PASSと以降の変更なしは**USER_ATTESTED**。10/18の再Compileとは記載しない。
6. P2-03のTable復元出力はWorkbook全体の完全復元保証ではない。
7. S0はRegressionもCompileも新規実行しておらず、Formal MVP Test PASSを意味しない。

## 8. Baseline／Project Controlの未整合

| 論点 | S0で確認した内容 | S4で必要な対処 |
|---|---|---|
| BL-MVP-004 | Approval Recordは2026-10-01 **APPROVED**。IF-P2-04-001 Bootstrap Gap対応 | 当地受入・Manifest整合を確認 |
| BL-MVP-004構成 | REQ v0.1.9／DES v0.1.10／TS-A v0.4／TESTSPEC v0.1.6 | Approved完成版文書の正本を探索・確認 |
| BL-MVP-003 | BL004 Approvalでは**SUPERSEDED** | 過去のExecution Baseline記録は維持 |
| Registry §3 | Current Approved Baselineを**BL-MVP-003**と記載 | BL004 Approvedと当地受入の関係を確定 |
| Project Overview | BL-MVP-003を維持し、10/12以降の現状反映に遅れ | 現在地を事実ベースで更新 |
| Registry §2 | Baseline VersionがREQ 0.1.8／DES 0.1.8／TESTSPEC 0.1.4 | **同Registryの§3 BL003 Manifestとも矛盾**。個別修復が必要 |
| Approved Source文書 | DES 0.1.10、TESTSPEC 0.1.6のCandidate Patchはある | Approved完成版の正本はRepo内未確認 |
| Implementation Plan | v0.3 ApprovedはBL003。BL004 Impact Reviewは`AFFECTED / v0.4 REQUIRED` | v0.4 Candidate Patch・Reviewから承認済み版の有無を確認 |

**BL003→BL004の一括置換は禁止。** `Approved`、当地Repositoryへの`Acceptance`、Historical `Execution Baseline`を区別する。

## 9. P2-05 Completion Gateの残作業

Approved P2-05 Specification §59にある**16 Criteria**の要点を整理する。

| Criteria群 | S0時点 | 次のアクション |
|---|---|---|
| Approved Specification | Evidence Found | Build・実装との対応づけ |
| Current Production Source Review | Evidence Found（既存PASS/CLOSED） | 最終Sourceとの差異を確認 |
| Production Patch Design | Evidence Found（Approved for Implementation） | 正式参照を固定 |
| VBA Compile | **PARTIAL** | 現行VBAProjectの新しい最終Compile Evidence |
| Production Implementation | **PARTIAL** | 作成時NOT YET EXECUTEDの古い状態と後続結果を整合 |
| P05-I01～I17 | **Evidence Found（既存記録上PASS）** | 結果の種類とBuildへの適用を整備 |
| P05-K01～K04 | **Evidence Found（既存記録上PASS）** | 最終Sourceとの対応確認 |
| P2-01 Regression | Evidence Found（CLOSED） | 保持 |
| P2-02・P2-03 Regression | **PARTIAL** | S1保管確定後、S2正式Closure |
| P2-04 Regression | **PARTIAL** | S3 I12・新Cycle正式Closure |
| Static Review S01～S32 | **PARTIAL** | **32項目すべて最終項目別PASS/CLOSED記録なし**。S5で審査 |
| P2-05 Production Patch Review | **NOT FOUND** | P2-05専用の最終Review |
| P2-05 Final Finding Assessment | **NOT FOUND** | P2-05全体を対象とするAssessment |
| Active Finding = 0 | **UNKNOWN** | 全体Register・集計規則を調査 |
| Blocking Finding = 0 | **UNKNOWN** | 同上 |

**補足：** 全16 Criteriaのうち、表ではP2-02/P2-03を1行に集約したため15行となる。P2-02とP2-03は独立Criteriaとして評価する。

### 検証ケースの解釈上の留保

- I01～I17、K01～K04は**既存記録にEvidenceあり**。S0で新規にPASS判定したわけではない。無断N/A扱いはない。
- I02／I04のCarrierはBehavioral/Contract-basedで、直接Locals観測とはしない。
- I07のCollection Count直接観測なし、I16のObject Identity直接比較なし、I17のWorkbook全イベント独立検査なしの限界を保持。
- I09にはSource-pathとRuntimeの表現差があり、Finding判断書と統合するときは区別する。
- I10～I12は過去Runtimeと現Source Pathを活用したEvidence。I13～I15の技術的NegativeはRuntime注入済みとしない。
- P2-05 S01～S32は**すべて最終審査記録が必要**。既存Pre-Compile Check、`PATCH-S01～S28`、P2-04 Static Reviewで代替しない。
- `OBS-P2-05-002`はOPEN/NON-BLOCKINGを継続。初期Source Reviewと後続資料で対象説明が異なるため、Finding ID・分類を照合する。全体Active/Blocking=0は未判定。

## 10. Gap・リスクと推奨優先順位

| 優先 | Gap／リスク | 判断・対処案 | 担当候補 |
|---|---|---|---|
| P0 | Raw Evidenceに個人パス・TEMPパスが含まれ、Repository公開範囲が不明 | **公開状態／アクセス権を最優先確認**。原本非公開保存と公開用マスク版を必要に応じて分離 | ユーザー |
| P0 | Raw 3ログ、Source ZIP、実行Workbookの正規Archive未確定 | 原本保管先・識別子・改変禁止・Hash・Manifest・取得手順を決定 | ユーザー＋Codex補助 |
| P0 | 保存・改訂・Closure承認の責任境界未定 | 記録作成者と承認者を明示 | ユーザー |
| P1 | P2-02/P2-03/P2-04/I12の正式Closure未実施 | S1完了後に根拠のあるRecord改訂と承認を順次実施 | Codex＋承認者 |
| P1 | BL004のRegistry/Overview不一致、Approved正本未確認 | S4で差分を個別確認。Historical IDは不変 | Codex＋ユーザー |
| P1 | P2-05最終Compile、S01～S32、Patch Review、Finding Gate不足 | S5で対象Build固定後に必要なGateを実行 | 実行者＋レビュー担当 |
| P2 | 限定検索で未発見のZIP 2件 | 追加探索の要否をS1で判断。**紛失とは断定しない** | ユーザー |

## 11. S1～S5への引継ぎ計画

| Step | 実施内容 | Entry / Done When |
|---|---|---|
| **S1** | 原本保全、公開範囲・正規保管先・責任者決定。既存Archive Manifestを改訂し、IF-P2-05-001判断書を正規参照へ登録 | **Entry：** S0 Inventory Complete。**Done：** 原本取得可能性・SHA・Visibility・参照先が確定 |
| **S2** | P2-02／P2-03 Regression Recordの正式改訂・Closure | S1のEvidence参照が一意。過去結果・Compile申告・Fixture・Finding限界を明示 |
| **S3** | P2-04新Cycle／I12の正式Closure | S2 Closure・Accepted再利用Decision。182件とI10 ABORTを含む履歴を維持 |
| **S4** | BL-MVP-004の正本・適用範囲確認、Document Registry／Overview／Implementation Plan必要箇所のみ更新 | Approved技術文書・当地Acceptanceを確認。歴史的Baselineを書き換えない |
| **S5** | P2-05 Production整合、最終Compile、S01～S32、Patch Review、Final Finding Assessment、Completion判定 | 各Required Gateの独立Evidence成立、Active/Blockingの判定根拠明示 |

S4差分調査・S5準備はRead-onlyで並行可能。ただし、正式更新・Completion判定は依存関係に従う。S5後の**S6：P2 Phase Exit／CP-P2**は別Gateとして扱う。

### S1でユーザーが決めるべき3事項

1. **保管先と公開範囲：** 外部開発フォルダを正式Archiveとするか、別の非公開保管先を採用するか。GitHubのVisibilityも確認する。
2. **責任者・承認権限：** 原本保全、Manifest変更、Record改訂、Closure承認を誰が行うか。
3. **実行Workbookの保全：** SHA一致の現物を保全用（Read-only）として固定し、今後の検証用コピーと分離する方法。

## 12. S0 Read-only遵守と最終判定

- Git HEADは調査開始／終了で同一。Tracked／Untracked／Staged変更なし。
- ZIPの展開保存・コピー・移動なし。Workbook／OFT起動、Compile、Regression再実行なし。
- Commit／Push／Fetch／Pull等のGit更新、外部アップロードなし。
- **S0最終判定：Inventory Complete / S1方針決定へ進行可能。**
- **S1方針の正式決定前にArchiveの公開登録・正式Closureへ進めない。**

---

## まとめ / Summary

**日本語：** S0では、Repositoryと外部フォルダの重要Evidenceを確認し、原文ログ3件、9モジュールのSource ZIP、SHA一致のWorkbook候補を発見しました。技術RegressionのPASSは確認できていますが、正式ClosureとP2-05 Completionは残っています。次はS1で保管先・公開範囲・責任者を決めます。

**English:** S0 found the main evidence files, the source ZIP, and a workbook with a matching hash. Regression records show PASS, but formal closure and P2-05 completion are not done. Next, S1 will decide where to store the files, who can access them, and who is responsible.
