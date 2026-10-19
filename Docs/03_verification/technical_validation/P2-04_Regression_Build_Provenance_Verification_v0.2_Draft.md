# P2-04 Regression Build Provenance Verification v0.2 — Draft

## 1. 文書情報・判定境界

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Scope | 2026-10-18 P2-04 Regression Cycle／I12 Contract Regression |
| Revision | v0.2 Draft（v0.1の追加検証） |
| Verification Date | 2026-10-19 |
| Evidence Origin | ユーザー提供の実行情報、ZIP、およびGitHub read-only参照 |
| Execution Workbook | `MailGeneratorNew.xlsm`（別フォルダ、GitHub登録のWorkbookとは別） |
| Source Change After Run | `なし`（ユーザー申告） |
| Workbook Save After Run | `なし`（ユーザー申告） |
| Source Comparison | **9/9 NORMALIZED MATCH** |
| Workbook Binary Fingerprint | **USER-REPORTED / NOT INDEPENDENTLY VERIFIED** |
| Build Provenance Gate | **PARTIALLY VERIFIED — EXECUTED WORKBOOK BYTES NOT REVIEWED** |
| I12 Decision | **PENDING / NOT CLOSED** |
| Existing P2-04 Unit Completion | **Historical PASS / COMPLETE — unchanged** |
| Formal MVP Test | **NOT CLAIMED** |

**厳密な境界**：`2026-10-18`に使用したVBAのExportとされる9資産について、GitHub保存済み資産との内容の一致を確認した。一方、実行Workbook自体のバイナリは受領していないため、申告されたSHA-256の再計算・VBAProject全体の抽出・実機Compileは実施していない。

## 2. 受領EvidenceとFingerprint

- Source ZIP：`P2-04_Regression_20261018.zip`。
- ZIP中身：ディレクトリ1件、VBA標準モジュール7件（`.bas`）、クラス2件（`.cls`）、合計**9件**。
- ZIP CRCチェック：**PASS**（全ファイル読取可能）。
- ZIP SHA-256：`bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7`。
- 実行Workbook名：`MailGeneratorNew.xlsm`。
- Regression実施日：**2026-10-18**（ユーザー申告）。
- 実行後ソース変更：**なし**（ユーザー申告）。
- 実行後Workbook保存：**なし**（ユーザー申告）。
- 実行Workbook SHA-256：`0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`（ユーザー申告・Workbookファイル現物未照合）。
- 実行WorkbookとZIP Export元が同一のVBAProjectであること：ユーザー説明を根拠として関連付け。別のバイナリ検証では未証明。

## 3. GitHub参照Snapshot

- Repository：`KJ-LEATHER-GAMES/MailGenerator`
- Branch：`main`
- 確認したHEAD Commit：`edf5c5175b103e250144341071d885a3a992c65f`
- GitHub Workbook Git Blob（**別の古いWorkbook**）：`c0d2d8544049e517c6617be14fbf3ad0b1ea40b1`
- 実行Workbookは別フォルダに所在するため、上記GitHub WorkbookのBlobを今回の実行版の識別値として採用しない。

### 3.1 Source-to-GitHub照合マトリクス

| User ZIP Export | GitHub Source (main HEAD) | Git Blob SHA-1 | 判定 |
|---|---|---|---|
| `CErrorInfo.cls` | `src/classes/CErrorInfo.cls` | `efb4712de996…` | **MATCH*** |
| `COperationResult.cls` | `src/classes/COperationResult.cls` | `cc2ebce3b89d…` | **MATCH*** |
| `modOutlookAdapter.bas` | `Docs/02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/modOutlookAdapter_P1-07_v0.1.1_CP932.bas` | `2a5909176a50…` | **MATCH*** |
| `modSettingsData.bas` | `src/modules/modSettingsData_DF-P1-001_v0.1_CP932.bas` | `081975575165…` | **MATCH*** |
| `modSyncApplication.bas` | `Docs/02_implementation/P2_Scan_Sync/modSyncApplication_P2-04_v0.1_CP932.bas` | `bb895132da48…` | **MATCH*** |
| `modSyncEngine.bas` | `Docs/02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.3_CP932.bas` | `9493e174ac8a…` | **MATCH*** |
| `modTemplateScanner.bas` | `Docs/02_implementation/P2_Scan_Sync/modTemplateScanner_P2-01_v0.1.1_CP932.bas` | `0a3028fabcf4…` | **MATCH*** |
| `modUiController.bas` | `Docs/02_implementation/P2_Scan_Sync/modUiController_P2-05_v0.1_CP932.bas` | `7250379e521b…` | **MATCH*** |
| `modVariableDefinitionData.bas` | `Docs/02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.2_CP932.bas` | `a4e50ceb36c6…` | **MATCH*** |

* MATCHは次の照合規則による：
1. Exportをテキストとして復号（8ファイルUTF-8、`modUiController`はCP932）。
2. 改行コード（CRLF/LF）、終端改行を正規化。
3. VBA識別子に由来する大文字・小文字の差異を吸収して、**全文の文字列が一致**することを文字数とFNV-1a 64-bit fingerprintで比較。
4. 大文字・小文字を変えると動作に影響し得る**ダブルクォート文字列リテラルについては、元の大文字・小文字を保持したまま別途比較**し、9件すべて一致した。
5. 正規化前のバイト単位完全一致ではない。元ZIPとGitHub ArtifactはEncoding／改行／VBE表記の差異が存在する。

照合結果：**9/9 Normalized Full-Source Match、および9/9 Case-Sensitive String Literal Match**。

- `modOutlookAdapter`は`src/modules/modOutlookAdapter_CP932.bas`とは一致せず、**`Docs/02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/modOutlookAdapter_P1-07_v0.1.1_CP932.bas`と一致**した。従って`src`のみを最新版とみなしてはいけない。
- `modVariableDefinitionData`も`src`の版ではなく、**P2-03 v0.1.2の版付きArtifactと一致**した。
- 同一の実行ソースとして扱うVersioned Artifactを明示したので、これまでの「GitHubにあるProduction Sourceが古い可能性」という未分化な保留事項は**この9モジュールの照合に関しては解消**する。
- ただし、ZIP未収載のVBAProject Modules、Worksheet／ThisWorkbookイベントコード、参照設定、データ・OFT・実行環境まで一致したと扱わない。

### 3.2 ZIP Export個別SHA-256（受領ファイルそのもの）

| Export | Raw SHA-256 | Size (bytes) | Decoding |
|---|---|---:|---|
| `CErrorInfo.cls` | `04ae5f319d04b146f5925969c019c51fd90c8376dd1ede2d9780eb1812d20820` | 847 | UTF-8 |
| `COperationResult.cls` | `c04db113a63c74a6d9221958e6a80bcd83914f057466b704e53bee779c60abcb` | 930 | UTF-8 |
| `modOutlookAdapter.bas` | `9245c1a6c2040f391cd0f577bb5a66fc3c92e6dec65fb7ee6c10232fa21bc137` | 22,558 | UTF-8 |
| `modSettingsData.bas` | `b7981c7f0cb4722f3c5407a6b9ff90eb65977ea17429c8afdf0071696915f113` | 14,929 | UTF-8 |
| `modSyncApplication.bas` | `b93afd18e79afb365dbd3b0c47f5366275b5fe6ec28912ff29f0e1a3aaec26e2` | 20,583 | UTF-8 |
| `modSyncEngine.bas` | `7f8c7bedbda97b1aa75c9c1e501e31c57ee595b12cfe8dbd76fd7427fed47b00` | 25,739 | UTF-8 |
| `modTemplateScanner.bas` | `dfb5fa189d19fa7ec76fa59a70677d3798f07d3ca1ab3a801b3ff9ab37fcc789` | 9,493 | UTF-8 |
| `modUiController.bas` | `d57afc45db9df0135605583161776173d16c6f8177c8560eef1e2b7b1a2fbb90` | 10,692 | CP932 |
| `modVariableDefinitionData.bas` | `9ba8cd37d1d226923a0f00110d697af6ad82470c79cdbd9961607b7b788780fd` | 37,509 | UTF-8 |

上記SHA-256は**実際に受領したZIP内のファイルバイト**を計算したもの。Git Blob Object IDとはアルゴリズム・バイトの形式が異なるため同じ値になることを要求しない。

## 4. BL-MVP-004へのTraceability

- `BL-MVP-004_Approval_Record_v0.1.md`：`2026-10-01`にAPPROVEDと記録。
- Manifest：REQ v0.1.9／DES v0.1.10／TS-A v0.4 CLOSED/PASS／TESTSPEC v0.1.6。
- 今回ZIPの`modSyncEngine`と`modVariableDefinitionData`は、GitHub保存済みP2-02 v0.1.3／P2-03 v0.1.2とNormalized Match。
- `modSyncApplication`はGitHubのP2-04 v0.1とNormalized Match。P2-05 UI Controllerも対応資産とNormalized Match。
- 以上により**Versioned Production Sourceの照合チェーンが成立**した。ただしBL-MVP-004準拠の実機Verification PASSや今回I12のClosureを、Source一致から単独で宣言しない。
- GitHub Project Overview／Registryには別PC同期・受入に関する`BL-MVP-003`残記載が存在。Baseline Approvalの存在とProject Controlの受入／表示の同期を別Gateとして扱う。

## 5. Regression Evidenceとの対応

| Evidence | 提供済みのResult | 今回のSource照合による追加評価 | 残課題 |
|---|---|---|---|
| P2-01 Regression | 独立Record：PASS/CLOSED | ScannerはP2-01 v0.1.1にNormalized Match | 実行時Workbook／Raw Evidenceへの適用履歴 |
| P2-02 Regression | 独立Record：111/111 PASS、DRAFT/CLOSURE PENDING | Sync EngineはP2-02 v0.1.3にNormalized Match | 2026-10-10の実行Build、Raw Log Archive／正式Closure |
| P2-03 Regression | 独立Record：46/46 PASS、DRAFT/CLOSURE PENDING | Data AccessはP2-03 v0.1.2にNormalized Match | 2026-10-11の実行Build、Raw Log Archive／Fixture確認・正式Closure |
| P2-04 Bootstrap | 引継ぎ：29/29 PASS | `BuildSyncDiff→ApplySyncDiff`の対応Production Codeを特定 | 2026-10-18 Raw Logの保存先・日時／復元Evidence |
| P2-04 I03–I11 | 引継ぎ：153/153 PASS（I10初回ABORT→再実行PASS） | `modSyncApplication`などの対象Productionを特定 | 2026-10-18 Raw Logの保存先・ABORT記録・復元Evidence |
| P2-04 I01/I02 | 歴史的Implementation Evidence | 今回の新規実行とは区別 | Evidence再利用条件の妥当性 |
| 今回 I12 | Integration in progress | **Source Provenance部分の照合完了** | Raw LogとEvidence再利用妥当性、最終Finding／Closure判定 |

**182 Assertion（29 + 153）のPASSは引継ぎ報告であり、本照合でテストを再実行していない。** ZIP中にはVBA Production Sourceのみがあり、Raw Regression Logは含まれていない。

## 6. Closure Gateと次アクション

```text
VBA Export supplied and ZIP integrity              PASS
GitHub Production Source identification             PASS
9-module normalized Source Match                     9 / 9 PASS
9-module case-sensitive string literal match         9 / 9 PASS
Executed Workbook SHA-256 value recorded             YES / USER-REPORTED
Executed Workbook SHA-256 independently recalculated NO / FILE NOT SUPPLIED
Executed Workbook VBAProject fully inspected         NO
2026-10-18 Raw Regression Log archive verified       NO
P2-02 / P2-03 Regression Record formally CLOSED      NO
I12 Source-Provenance Subtask                         SUBSTANTIALLY COMPLETE
I12 Final Closure                                     PENDING
```

推奨Action順：

1. **実行ログの所在確認**：Bootstrap、I03～I11、I10の初回ABORTと再実行、Fixture復元の原文Evidenceを保存・参照化。
2. **P2-02／P2-03 Regression RecordのClosure**：両RecordのRaw Log、当該実行Build、Original Fixtureの復元を照合。既存PASSを無条件にFormal Closureへ変更しない。
3. **実行Workbookとソースのトレーサビリティ**：提供ZIPが2026-10-18実行WorkbookからのExportという申告を記録。必要な場合のみ同じWorkbookのBinary SnapshotまたはVBAProjectのRead-only Inspectionで独立裏付け。
4. **今回I12 Decision**：Evidence CoverageとFinding Assessmentが完了した時点でPASS/CLOSED可否を別途判断。
5. **Project Controlとの同期**：BL-004承認とGitHub Registry／Overviewの別PC未受入状態を区別し、Project受入・Git Source正本整理は別Gateとして扱う。

追加ソース修正や回帰テストの全面再実行は、現時点のStatic Evidenceからは必要と判断しない。

## 7. 変更・未変更

- 今回の照合は**read-only**。ユーザーZIP・GitHub Source・Workbookに変更を加えていない。
- 既存P2-04 Completion `PASS / COMPLETE`を変更していない。
- P2-05 Completion／P2 Phase Exit／CP-P2／Formal MVP Testの完了は宣言していない。
- 推奨保存場所：`Docs/03_verification/technical_validation/`（GitHubへの追加／Commitは未実施）。

## まとめ / Summary

**日本語：** 受領した9つのVBA Exportは、改行・大文字小文字を正規化するとGitHubに保存されている適切な版付きProduction Sourceと全件一致した。文字列リテラルは大文字小文字を保持して比較しても一致する。Workbook SHA-256はユーザー報告値として記録済みだが、Workbook本体と実行生ログは未照合。I12はPENDINGを維持する。

**English:** All nine exported VBA modules match their corresponding GitHub source revisions after text normalization. Case-sensitive string literals also match. The workbook hash is recorded as user-reported. Raw regression logs and workbook bytes are not independently verified, so I12 remains pending.
