# P2-04 I12 Contract Regression Evidence照合マトリクス v0.2（Draft）

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール MVP（Excel VBA + Classic Outlook） |
| 文書種別 | Execution / Verification — 今回Regression CycleのEvidence照合記録 |
| 対象 | P2-04 Manual Sync Integration / I12 Contract Regression |
| Version / Status | **v0.2 / DRAFT — CLOSURE PENDING** |
| 照合日 | 2026-10-18 |
| 前版 | `P2-04_I12_Evidence_Reconciliation_Matrix_v0.1_Draft.md` |
| 参照GitHubリポジトリ | `KJ-LEATHER-GAMES/MailGenerator`、`main`の確認時点のHEAD `edf5c5175b103e250144341071d885a3a992c65f` |
| 今回Regression結果 | 引継ぎ報告 **182/182 PASS、FAIL 0**（生ログ未確認） |
| 今回I12判定 | **PENDING / NOT CLOSED** |
| 旧P2-04 Completion | **PASS / COMPLETE（既存判定を維持）** |
| 旧I12統合記録 | **PASS / FINALIZED（既存判定を維持）** |
| Formal MVP Test | **NOT CLAIMED** |

> **検証の境界：** GitHubのCommit IDおよびGit Blob SHAは「リポジトリの参照Snapshot」を識別する。2026-10-18に実行された別PCのExcel Workbook / VBAProjectのBuild IDを確定したものではない。文書の記載と実環境の実測も別扱いにする。

## 2. 前版からの照合進展（重要）

| ID | v0.1時点 | 今回確認した証拠と結果 | 今回Cycleへの影響 |
|---|---|---|---|
| B-01 Approved Baseline | 承認原本未確認 | `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`が存在。文書内で**2026-10-01 / PASS / APPROVED**と明記 | `BL-MVP-004`の**承認記録の存在・文書上のApproval**は確認済み。現在のExecution Source整合は別途未確認 |
| B-02 BL-003とBL-004 | 未確認 | `BL-MVP-004`承認記録は`BL-MVP-003 SUPERSEDED`と明記。Manifestも判明 | `BL-MVP-004`を単なるHarness誤記とは扱わない。Project Controlの表示不整合は未解決 |
| B-03 Workbook / Build | 未確認 | GitHub `main`に`MailGeneratorNew.xlsm`がある。HEADのWorkbook Blob SHA `c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`。Workbookパスの最新Commitは`88b19f350623284d8738a69170e1769540a9030a`（2026-10-11 05:24 JST） | **Git上の参照版は識別できたが、実行Buildは未確定** |
| B-04 Raw Log | 未確認 | GitHub `main`の再帰Treeでは、今回の182 Assertionに対応する独立Raw Log / Evidenceディレクトリを特定できず。添付ファイルにも生ログなし | **NOT VERIFIED**を維持。Repo外、別PC、未Commit保存の可能性を否定しない |
| B-05 P2-04実施計画 | 未確認 | `Docs/03_verification/technical_validation/P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`を確認。Source Review 2026-10-12、2026-10-16にGitへ追加 | **AVAILABLE / REVIEWED**。当該文書は実施前Planであり結果Recordではない |
| B-06 P2-02/P2-03独立Record | 未確認 | それぞれ`Docs/03_verification/technical_validation/`に存在、文書本文も確認 | **AVAILABLE / REVIEWED**。ただし両方**DRAFT / CLOSURE PENDING** |

### 2.1 承認Manifest（原本記載）

| Document ID | BL-MVP-003（2026-09-19承認） | BL-MVP-004（2026-10-01承認と記載） |
|---|---|---|
| DOC-MVP-REQ | v0.1.9 | v0.1.9 |
| DOC-MVP-DES | v0.1.9 | **v0.1.10** |
| DOC-TS-A | v0.4 CLOSED/PASS | v0.4 CLOSED/PASS |
| DOC-MVP-TESTSPEC | v0.1.5 | **v0.1.6** |

`BL-MVP-004`では`IF-P2-04-001 Initial Sync Metadata Bootstrap Gap`のDesign/Test定義が更新された。したがって、`BL-MVP-003`から**意味上の変更がない**という判断は不可。対応するProduction CorrectionとRegressionの適用範囲を評価する必要がある。

### 2.2 Project Controlの不一致：別PCの受入状態と承認記録の分離

- `Docs/00_project_control/Project_Overview.md`（v1.59、2026-10-12）は`BL-MVP-003`をCurrent Approved Baselineとして表示し、**別PCでP2を実装中、Workbook / OFTのみ当地へコピー、Module・文書は未反映**と記載している。
- `Docs/00_project_control/Document_Registry.md`（v1.28、2026-10-16）も当地の管理状態として`BL-MVP-003`を維持すると記載している。
- それに対し`BL-MVP-004_Approval_Record_v0.1.md`は`BL-MVP-004 APPROVED`および`BL-MVP-003 SUPERSEDED`と明記する。承認文書自体はGitへ2026-10-13に追加されている。
- この3文書が**同じPC／同じ受入状態を表すと確認できていない**。古いProject Control表記を勝手に更新せず、承認の有無、同期・受入状態、今回テストの実行環境を切り分ける。
- `Implementation Plan v0.3`はExecution Baseline `BL-MVP-003`のまま。BL-MVP-004 Approval Record §13はImpact Review `REQUIRED`と記載。Impact Review実施・承認済Revisionの有無は未確認。

## 3. Git Snapshotと今回実行Buildの区別

| 項目 | GitHub `main`で確認した値 | 今回Regressionの実行実体との対応 |
|---|---|---|
| Repository / Branch | `KJ-LEATHER-GAMES/MailGenerator` / `main` | **参照先は確認済み** |
| HEAD Commit | `edf5c5175b103e250144341071d885a3a992c65f`、Commit日時2026-10-16 23:56 JST | **今回テストをこのCommitで実行した証拠はない** |
| Workbook Path | ルート`MailGeneratorNew.xlsm` | ファイル名は引継ぎと一致するが、同一バイト列・同一VBAProjectは**未確認** |
| Workbook Blob SHA | `c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`（Git Blob Object ID） | 実行PCのWorkbookとは**未照合**。SHA-256の実ファイルハッシュとは別 |
| Workbook pathの最終Commit | `88b19f350623284d8738a69170e1769540a9030a`（2026-10-11 05:24 JST） | 今回実行報告の2026-10-18より前。後日編集を否定できない |
| `src/modules/` | Gitに`modVariableDefinitionData_CP932.bas`等あり。一方、`modSyncApplication`・`modSyncEngine`・`modTemplateScanner`・`modUiController`は当該`src/modules/`に確認できず | 完全な現行Production exportと判断不可。別の`Docs/02_implementation/...`に版付きArtifactは存在する |
| Production Artifact | Gitに`modSyncEngine_P2-02_v0.1.3_CP932.bas`、`modVariableDefinitionData_P2-03_v0.1.2_CP932.bas`あり | **版付きArtifactの存在 ≠ 実行WorkbookへのImport済み・コンパイル済み** |
| テスト資産 | `tests/vba/P2_Scan_Sync/`にI03～I11関連のVBA Harness群あり | ソースは存在するが、今回実行したそのハッシュ／実行時状態は未確認 |

**現時点のBuild判断：** `REPOSITORY SNAPSHOT IDENTIFIED / EXECUTED BUILD NOT VERIFIED`。

### 3.1 Build同一性を確定するための最小照合項目

1. 2026-10-18の回帰を実行したWorkbookの実際の保存場所、保存日時、**検証時点のWorkbookコピー**を特定する（後から更新された現行ファイルで代用しない）。
2. 該当コピーのSHA-256（Windows例：`Get-FileHash -Algorithm SHA256 '...\MailGeneratorNew.xlsm'`）を採取し、当該Copy/Run IDに関連付ける。
3. 実行時のVBAProject Exportまたはそれと同一と立証できるSnapshotを特定。少なくとも`modSyncEngine`、`modVariableDefinitionData`、`modSyncApplication`、`modTemplateScanner`、`modOutlookAdapter`のProduction実体を確認。
4. Gitに格納された版付きArtifactとの内容差分とPublic Signature、IF-P2-04-001対応箇所を比較する。
5. 実行PCから保存された時点に紐付けたCommitがある場合、そのCommit SHAを記録。**Git HEADを実行Commitに推定代入しない**。

## 4. P2-02 / P2-03独立Regression Record：再利用判定

| Target | Record実在 | Recordの実行結果 | Record Status | Build / Baseline / Archiveの問題 | 今回への再利用 |
|---|---|---|---|---|---|
| P2-01 Full Scanner | **YES** | Core 11/11、2 Integration PASS | `PASS / CLOSED`（2026-10-09） | 現行Buildとのソース差分未確認。最初の`ReadBodyText`失敗はFresh Warm再実行でPASS、原因未証明 | **PENDING** |
| P2-02 Sync Diff v0.1.3 | **YES**（2026-10-10） | 33+43+9+18+6+2 = **111/111 PASS** | **DRAFT / CLOSURE PENDING** | Logの`BL-MVP-004`は現在承認記録で裏付けられるが、実行Build・生ログ保存先とProduction実体未確認 | **PENDING** |
| P2-03 Persistence v0.1.2 | **YES**（2026-10-11） | 7+6+12+18+3 = **46/46 PASS** | **DRAFT / CLOSURE PENDING** | Detection Historyログの`BL-MVP-004`は承認記録あり。実行Build・生ログ保管・最終Fixture復元保証未確認 | **PENDING** |
| Bootstrap P2-02→P2-03 | 旧P2-04 Finalizationに29/29 PASS | 今回も**29/29 PASSと引継ぎ** | 今回生ログ未照合 | Raw Evidence、Build、Fixture Restoration未照合 | **PENDING** |
| I01/I02 | 旧P2-04 Completionで各PASS | **今回の独立再実行なし** | 過去Implementation Evidence | 実行Buildへの適用可能性未確認 | **PENDING** |

**判定の厳密性：** P2-02/03のPASS件数は独立Record本文に基づき確認済み。ただし、**独立Record自体はCLOSEDではない**。Recordの見つかったことをClosure済み、まして現行Buildでの実行済みと読み替えない。

## 5. P2-04今回Cycle：I12 Evidence照合

| Item | Result | Evidence強度 | 今回Cycleでの扱い |
|---|---|---|---|
| Bootstrap | **29/29 PASS** | 引継ぎ記録（生ログ未照合） | `HANDOFF-REPORTED` |
| I03 | **10/10 PASS** | 同 | `HANDOFF-REPORTED` |
| I04 | **11/11 PASS** | 同 | `HANDOFF-REPORTED` |
| I05 | **17/17 PASS** | 同 | `HANDOFF-REPORTED` |
| I06 | **22/22 PASS** | 同 | `HANDOFF-REPORTED`。見出し誤記を別記録 |
| I07 + I08（連続Harness） | **37/37 PASS** | 同 | `HANDOFF-REPORTED`（各ID別件数は不明） |
| I09 | **16/16 PASS** | 同 | `HANDOFF-REPORTED` |
| I10 | **20/20 PASS** | 同 | `HANDOFF-REPORTED`。初回ABORT履歴を保持、ABORT原因未確定 |
| I11 | **20/20 PASS** | 同 | `HANDOFF-REPORTED` |
| I01 / I02 | 過去PASS | 旧Completion Record | **今回未実行**と明示。Build再利用評価待ち |
| I12 | 今回の統合審査 | 本照合マトリクス | **PENDING** |
| 合計 | **182 / 182 PASS** | 引継ぎの報告値、算術一致 | I12 PASSの自動根拠にはしない |

`P2-04 Manual Sync Integration Regression 実施計画 v0.1`は2026-10-16時点の実行計画で、I12を**既存P2-01/P2-02/P2-03＋Bootstrap Evidenceの統合**として扱い、I01/I02は過去Evidenceを明示的に区別する方針を採用している。対して既存`P2-04_I12_Contract_Regression_Guide_v0.1.md`はI12-A～Dの**直接再実行**を手順に記載する。**文書間で再利用／再実行の表現が異なる**ため、現行計画の統合方式を採用してよい条件（Build同一性、Source差分の評価、ログ所在）を明記し、根拠なしにI12-A～Dを新Cycleで再実行済みとしない。

## 6. Raw Evidence所在調査（今回の成果と限界）

- 今回の引継ぎ`Pasted text(5).txt`には各Assertionの集計、環境操作、Fixture復元の要約があるが、**Immediate Windowの生ログ本文、File Path、実行Run ID、Excel実行PCにおける時点別Build記録は含まれない**。
- 添付`P2-04_Documents.zip`には旧P2-04 Completion / Finalizationの文書はあるが、2026-10-18回帰の個別Raw Logは含まれない。
- GitHub `main`再帰Tree（HEAD `edf5c517...`）から、今回の2026-10-18全9Harness実行に対応するRaw LogファイルとEvidence保存先を特定できなかった。これは**未保存の証明ではなく、Git管理外・別PC・未同期の可能性を含む所在未確認**である。
- P2-02 / P2-03の独立Regression Recordは**過去に会話で受け取った全文出力をレビューした記録**であり、生ログの独立Archiveパスはそれぞれ未確認と明記されている。
- 各Runで必要な最低限のEvidenceリンク：`Run ID → 実施日・時刻 → Workbookコピー/Build Hash → Harness Entry Point → 全文Output → Fixture Restoration → 対応Record`。
- Raw Evidence保管先はフォルダ管理ルール上の**`Evidence/`**。実際に存在する具体的なファイル・フォルダは未確認のまま残す。サンプルパスを既存保存先として記載しない。

## 7. 未解決項目とGate

| ID | 未解決事項 | 解消条件 | 現状 |
|---|---|---|---|
| G-01 | BL-MVP-004 ApprovalとProject Overview/Registryの管理表示不整合 | どのPCのどの文書が当該Runに有効だったか確定。承認記録の存在は確認済み | **PARTIALLY VERIFIED** |
| G-02 | 実際の2026-10-18実行Workbook / Build | 実行時コピー/Hash/Export/Commitの紐付け | **PENDING** |
| G-03 | 182 Assertionの生ログ／Evidence保存先 | 全Runを生ログと突合、I10 ABORT→PASS経緯も保存 | **PENDING** |
| G-04 | P2-02/P2-03独立RecordのClosure条件 | 原本ログ保存、Baseline/Build、Fixture最終復元、Findingが整合 | **PENDING** |
| G-05 | I01/I02旧Evidenceの今回Buildへの適用可能性 | Source差分・影響分析と旧Evidenceの版識別 | **PENDING** |
| G-06 | I12 Coverage／直接再実行Guidelineとの整合 | 計画優先・Guideの実行条件・証拠再利用範囲を正式照合 | **PENDING** |
| G-07 | Final Compile / Restoration / Blocking Finding | 該当RunのCompile・原状復帰とFinding最終判断を裏付けるEvidence | **PENDING** |

> **Quality Gate Separation:** 既存P2-04 Completion（過去PASS）、新P2-04 Regression I12（今回PENDING）、P2-05 Completion、P2 Phase Exit、CP-P2は別々に管理する。`BL-MVP-004 APPROVED`もVBA Build Verification PASSを意味しない。

## 8. 次のアクション（優先順）

1. **実行PCのRegression Run Folder特定**：2026-10-18のBootstrap・I03～I11全文ログ／Screenshotと保存場所を確保。`I10 ABORT`と最終20/20 PASS両方を残す。生ログに個人情報やメール内容があれば保存・共有前に確認する。
2. **実行WorkbookのSnapshot確定**：10/18テスト時のWorkbook Copy、更新日時、SHA-256、ExportされたProduction Module集合／版を記録。Git版と一致するかは差分照合で判定。
3. **BL-MVP-004適用状態を照合**：承認記録のManifestは確認できている。別PCの実行状態と、同期遅延しているProject Control／Implementation Planの適用状態を切り分ける。
4. **P2-02/P2-03のRecordを再評価**：独立Recordは発見済み。111/111、46/46 PASSの結果を保持し、Closure保留条件（Build／Archive／Fixture／Finding）を消し込む。自動再実行しない。
5. **I12 Evidence再利用判定**：Build差分が影響しないことを示せる場合のみ既存Evidenceを採用。影響を排除できないContractだけ選択的に再検証する。
6. **I12 Final FindingとP2-04 Regression Record作成**：各Gateが満たされたときに限り`PASS / CLOSED`。不足する間は`DRAFT / CLOSURE PENDING`。

## 9. プロジェクト保存先（未適用）

GitHub Repoの`Docs/00_project_control/rules/Folder_Management_Rules.md` v0.2を確認済み。今回の作業成果物は検証結果・照合記録に該当するため、**プロジェクトルートからの推奨配置先**は以下。

```text
Docs/03_verification/technical_validation/P2-04_I12_Evidence_Reconciliation_Matrix_v0.2_Draft.md
```

ただし、本書は**このチャットの作業環境にのみ生成**した。GitHubリポジトリへの追加・Document Registry／Overview更新・Commitは**未実施**。`Evidence/`にも生ログは作成／追加していない。Project Controlの現行正本や過去Completionを改変していない。

---

## まとめ / Summary

**日本語:** GitHub上でBL-MVP-004の正式Approval RecordとP2-02/P2-03独立Regression Recordを確認できた。BL-MVP-004は2026-10-01承認と記録されている。一方、Registry/OverviewにはBL-MVP-003が残り、実行PCとGitのWorkbookは未照合。今回182/182 PASSの生ログも未確認。従って新CycleのI12はPENDINGのままとする。

**English:** GitHub has the BL-MVP-004 approval record and the P2-02 and P2-03 regression records. BL-MVP-004 is marked approved on October 1, 2026. The project overview still says BL-MVP-003. The tested workbook and raw logs are not verified. The new I12 cycle remains pending.
