# P2-04 Manual Sync Integration Regression Record v0.1 — DRAFT

## 0. 本記録の証拠能力・作成目的（必読）

本書はチャット「24_次アクション計画」で報告されたRegression実行結果を、**既存の引継ぎ記録に記載された範囲で**文書化したものである。

- **本書はImmediate Window原文の逐語転記ではない**。同チャットに貼付されたユーザー原文ログの所在は特定したが、現在のツールアクセスでは全Assertion行・時刻をそのまま抽出できていない。
- したがって、表中のPASS件数は`引継ぎに記録された実行結果`であり、`本書作成時に再実行またはRaw Log全文再照合済み`を意味しない。
- 本書中の`Overall = PASS`等は引継ぎ内で報告された表示文字列であって、実行環境のImmediate Windowから本書作成時に複製した文字列ではない。
- Original Conversation: [https://chatgpt.com/g/g-p-6a9f817f3494819191f072d806bf7565/c/6ac98b8c-c5d8-83ec-a6aa-4b0800c38510](https://chatgpt.com/g/g-p-6a9f817f3494819191f072d806bf7565/c/6ac98b8c-c5d8-83ec-a6aa-4b0800c38510)
- Secondary Source: `Pasted text(5).txt`（前チャットの引継ぎまとめ、ローカル参照。SHA-256 `08ad82ec4811264d74b189eef39729384c1d265ed9e946f51f618f2f253a96bd`）
- Build Source Corroboration: `P2-04_Regression_Build_Provenance_Verification_v0.2_Draft.md`。
- **Historical** `P2-04 Manual Sync Integration Completion Record v0.1` および `Regression Evidence Finalization v0.1` のPASSと、この2026-10-18の新Regression Cycleを区別する。

## 1. Document Information

| Item | Value |
|---|---|
| Project | 定型メール作成ツール MVP |
| Phase/Target | P2 Scan/Sync / P2-04 Manual Sync Integration |
| Verification | Implementation Regression（Formal MVP Testではない） |
| Execution date | 2026-10-18を中心とする実行（ユーザー引継ぎ） |
| User-tested Workbook | `MailGeneratorNew.xlsm`（GitHubにある同名Workbookではない） |
| Workbook SHA-256 | `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`（ユーザー申告。バイナリ未検証） |
| Post-execution source modification | なし（ユーザー申告） |
| Post-execution workbook saving | なし（ユーザー申告） |
| Source-to-GitHub comparison | 9/9 normalized-match（別途Build Provenance v0.2記録） |
| BL-MVP-004 | 2026-10-01 Approval Recordあり。Workbookへの実行Baseline紐付けは文書上評価中 |
| Status | **DRAFT / RAW LOG VERBATIM ARCHIVE PENDING / REGRESSION CLOSURE PENDING** |
| Baseline History | BL-MVP-003は旧Approved；BL-MVP-004承認記録ではSUPERSEDED。ただしGitHub Project Overview/Registryに旧版記載あり |

## 2. Evidence Classification

| Code | Meaning | この記録の扱い |
|---|---|---|
| `P-SUM` | 現行チャットで確認できる引継ぎ記録の結果・試験内容 | 以下の判定表の一次入力だが、実行ログ自体ではない |
| `P-CONVO` | 原文ログが貼られた過去会話の所在 | URL確認済み。全ログ原文の照合・抽出は未完了 |
| `P-BUILD` | ユーザー提供9モジュールのExportとGitHub版付きSourceの照合 | 9/9 normalized-match。ただしWorkbook内部の独立抽出ではない |
| `HIST` | 過去Implementation/Regression記録 | 今回の実行に再利用可否判定が必要 |
| `RAW-ARCHIVE` | Immediate Window全文を改変せず保存した生ログ | **未取得／保存先未確認** |

## 3. 2026-10-18 Regression Execution Result Matrix

| ID | Scenario | Entry Point | PASS | FAIL | Source status | Raw log |
|---|---|---|---:|---:|---|---|
| `R-BOOT` | Bootstrap Production Compatibility | `TestP202P203BootstrapProductionCompatibility` | 29 | 0 | **P-SUM：PASS報告** | `E-BOOT` **原文未照合** |
| `R-I03` | I03 Invalid Candidate | `TestP204I03InvalidCandidate` | 10 | 0 | **P-SUM：PASS報告** | `E-I03` **原文未照合** |
| `R-I04` | I04 OFT Missing | `TestP204I04OftMissing` | 11 | 0 | **P-SUM：PASS報告** | `E-I04` **原文未照合** |
| `R-I05` | I05 Definition Read Failure | `TestP204I05DefinitionReadFailure` | 17 | 0 | **P-SUM：PASS報告** | `E-I05` **原文未照合** |
| `R-I06` | I06 BuildSyncDiff Failure | `TestP204I06BuildSyncDiffFailure` | 22 | 0 | **P-SUM：PASS報告** | `E-I06` **原文未照合** |
| `R-I07I08` | I07/I08 Apply Failure → Fresh Retry | `TestP204I07I08ContinuousRetry` | 37 | 0 | **P-SUM：PASS報告** | `E-I07I08` **原文未照合** |
| `R-I09` | I09 Warm Lifecycle | `TestP204I09WarmLifecycle` | 16 | 0 | **P-SUM：PASS報告** | `E-I09` **原文未照合** |
| `R-I10` | I10 Cold Lifecycle | `TestP204I10ColdLifecycle` | 20 | 0 | **P-SUM：PASS報告** | `E-I10` **原文未照合** |
| `R-I11` | I11 Manual Only | `TestP204I11ManualOnlyAfterReopen` | 20 | 0 | **P-SUM：PASS報告** | `E-I11` **原文未照合** |
| **TOTAL** | **Bootstrap + I03–I11** |  | **182** | **0** | **P-SUM：PASS報告** | **原文取得待ち** |

**計数検算**：Bootstrap 29件 + I03–I11 153件 = **182件**。I07/I08は連続37件の単一Entry Pointであり二重計上しない。I10の初回ABORTはPASS/FAIL assertion件数に含めない。I01/I02は今回の182件には含めない。

## 4. ケース別実行内容・観測内容（Secondary Evidenceへの忠実な構造化転記）

### E-BOOT — Bootstrap Compatibility: 29/29 PASS

- Production path：`GetAllVariableDefinitions → BuildSyncDiff → ApplySyncDiff`。
- Fixture：`ModelName`（Active）と`OldVariable`（Unused）を中心に2行を構成。
- Existing/Already-Unused、Detection History未初期化、User Configuration保持を確認。
- `tblVariableDefinition`をテスト中に一時削除・Fixture投入・復元するHarness。Before/Afterの**表示データ一致**が報告されている。
- 数式・書式・入力規則を含む完全復元や異常終了時の復元保証は、本証拠から宣言しない。
- **Raw Transcript：未取得**。

### E-I03 — Invalid Candidate: 10/10 PASS

- OFTに一時的な`{{1stGate}}`を追加。Invalid Candidate 1件を検出。
- `ExecuteManualSync.Success = False`、`templateScanResult`はPublished、`syncDiffResult = Nothing`。
- VariableDefinition実行前後一致、OFT原状復帰と報告。
- **Raw Transcript：未取得**。

### E-I04 — OFT Missing: 11/11 PASS

- 一時的に存在しないOFTへの`Settings.TemplatePath`を設定。
- `ConfigurationError / TemplatePath`、両Carrier（`templateScanResult` / `syncDiffResult`）は`Nothing`、VariableDefinition不変。
- **注意**：テスト開始時点で`Templates\TESTP204I04.oft`が設定されていた。Harnessはその開始値へ復元することを確認した。I05では`Templates\MailTemplate.oft`へ戻っていた旨が報告された。
- **Raw Transcript：未取得**。

### E-I05 — Definition Read Failure: 17/17 PASS

- `Status`列名を一時的に`Status_TEST_BROKEN`へ変更。
- `GetAllVariableDefinitions`が`ConfigurationError / Status`。同期Failureまで伝播。
- Scanner結果はPublished、SyncDiff結果は非公開。Read Failure時の空Collection初期化を確認。
- 変更した列名とテーブルデータを復元した旨が報告された。
- **Raw Transcript：未取得**。

### E-I06 — BuildSyncDiff Failure: 22/22 PASS

- `ModelName.Status`を`InvalidStatus`へ一時変更。
- Definition Read Success後、`BuildSyncDiff`がFailure。`ExecuteManualSync.Success = False`、`syncDiffResult = Nothing`。
- Failure直後のFixture状態保持と最終復元を確認。
- **Test Artifact表示上の軽微事項**：Preflight見出しに`I05 Normal Template Preflight`と記載。
- **Raw Transcript：未取得**。

### E-I07/I08 — Apply Failure → Fresh Retry: 37/37 PASS

- I07：VariableDefinitionシート保護状態で`ApplySyncDiff`書込みを失敗させ、Excel Runtime Error 1004、`UnexpectedError / tblVariableDefinition`、`syncDiffResult = Nothing`。
- I07の観測ではBefore/Afterデータは一致し、自動RetryでSuccessにならないことを確認。
- I08：保護解除後、`ModelName.Status: Active → Unused`へ変更して**明示的に**再同期。`Reactivated`へ分類して`Active`へ復帰、新しいSyncTimestampの使用を確認。
- 最終的にテーブルデータとシート保護状態の原状復帰を報告。
- **重要**：I07の不変性は観測結果であって、Persistence途中失敗一般に対するRollback/Atomicity保証ではない。
- **Raw Transcript：未取得**。

### E-I09 — Warm Lifecycle: 16/16 PASS

- Outlook起動済で`ExecuteManualSync.Success = True`。
- Explorer `1→1`、Inspector `0→0`、Draft `23→23`、既存Explorer再利用を確認。
- VariableDefinitionの復元成功と報告。
- これらは終了時の残存個数のEvidenceであり一時表示が完全になかったことの保証ではない。
- **Raw Transcript：未取得**。

### E-I10 — Cold Lifecycle: Initial ABORT / Final 20/20 PASS

- Entry Point：`PrepareP204I10ColdLifecycleBaseline` → 同じVBA Sessionで`TestP204I10ColdLifecycle`。
- 初回は`I10 baseline has not been prepared in this VBA session`で**ABORTED**。その結果をPASSへ改変しない。
- `mI10BaselinePrepared`による事前準備のSession依存を確認。Procedureを明示的に実行してBaseline Preparationを成功させた。
- 初回ABORTの厳密な操作原因は未確定。Production Defectの証拠はなし。
- Outlook完全終了後、`OUTLOOK.EXE 0→1`、Visible/Active Explorer確立、Inspector `0`、Draft `23→23`、同期成功。
- VariableDefinition復元。最終結果20/20 PASS。
- **Raw Transcript（初回ABORT／Prepare／最終試行）：未取得**。

### E-I11 — Manual Only: 20/20 PASS

- Entry Point：`PrepareP204I11ManualOnlyBaseline` → Excel/Workbook通常終了 → 再オープン後`TestP204I11ManualOnlyAfterReopen`。
- `tblVariableDefinition`と`LastDetectedAt`のBaselineをWindows TEMPへ保存し、起動だけでは値が変更されないことを確認。
- 明示的なManual SyncでSuccess：`New=0`、`Reactivated=0`、`Unused=0`、`Existing>0`。
- User Configuration保持、安定同期でのLastDetectedAt更新を観測。
- 値復元とWorkbook保存を実施した旨が報告されている（Regression後保存なしの申告は、当該試験の復元・保存後を基点とする解釈に留め、時系列の最終固定点は原文で再確認）。
- TEMPのBaseline Evidenceはテスト成功後に削除済み。**削除済みTEMPファイルを現存証拠として引用しない**。
- `P3 UserForm Variant = N/A - P3 not implemented`はP2試験のFAILではない。
- **Raw Transcript：未取得**。

## 5. Source / Build Identification Evidence

ユーザー提供の`P2-04_Regression_20261018.zip`（Production Export 9件）とGitHub Versioned Sourceを全文テキスト比較（改行／小文字化等の正規化と、引用文字列の大文字小文字保持確認）し、**9/9 normalized-match**と記録済み。

識別チェーン：`ユーザー申告SHA-256（Workbook）` → `User-provided Export ZIP` → `GitHubの版付きProduction Source` → `BL-MVP-004`。

- 確認済み：Export ZIPファイル内容とGitHub側ソース対応版の正規化一致。
- 未確認：Workbookバイナリと同じVBAProjectの独立読出照合、実行PC上のハッシュを第三者再計算、未Export部分、実行時Test Harness一致。
- GitHubの古い`MailGeneratorNew.xlsm` Blobは今回の実行Buildとしない。

## 6. I12 Contract Regression Evidence Cross-reference

| Unit/Case | Evidenceの既存状態 | 今回への再利用判定 |
|---|---|---|
| P2-01 | 独立Regression Record `PASS/CLOSED`。Core 11/11＋OFT/Recipient統合PASS | Candidate。今回のScanner Revision一致、ただし過去実行Build・環境差の影響確認が必要 |
| P2-02 | 2026-10-10 Regression Record `111/111 PASS` / `DRAFT` | Candidate。実行ログ保存先、正式Closure未完了 |
| P2-03 | 2026-10-11 Regression Record `46/46 PASS` / `DRAFT` | Candidate。実行ログ保存先、Fixture復元、正式Closure未完了 |
| P2-04 I01/I02 | 以前のImplementation VerificationでPASS | **今回は再実行していない**。現行Buildでの実施と記録しない |
| 2026-10-18 Bootstrap/I03–I11 | **182/182 PASS報告** | 出典を確保したSecondary Evidence。Raw Log全文照合・Archive必要 |
| 2026-10-18 I12 | 集約作業継続 | **PENDING**。Aggregator追加やProduction改修は実施しない |

`P2-04_I12_Contract_Regression_Guide_v0.1`には既存Suiteの直接再実行を記載した箇所がある。一方、後続の`P2-04 Manual Sync Integration Regression 実施計画 v0.1`は既存Evidenceを統合する方式を採用。指示の適用範囲・再利用条件はI12最終判定前に整合性確認し、推測で同一視しない。

## 7. Observation / Finding / Restoration Boundary

| Item | Status | Treatment |
|---|---|---|
| OBS-P2-05-002 WordEditor断続E_FAIL | `OPEN / NON-BLOCKING` | I09/I10で再現せず＝根本解決の証拠ではない |
| I10初回ABORT | `ABORTED → 再実行20/20 PASS` | 初回と最終を両方記録。Root Cause未確定 |
| I06 Preflight見出し | Test Artifact表示誤記候補 | Regression PASSとは区別 |
| Fixture復元 | 対象テストでの復元成功が引継ぎに記載 | 全セル属性の完全復元保証までは主張しない |
| TemplatePath / OFT復元 | I03/I04に報告あり | 初期`Templates\TESTP204I04.oft`と通常Pathの時系列は原文で追認 |
| Regression BLOCKING Finding | 引継ぎは新たなProduction Defectを報告せず | **Final Finding Assessment未実施**。Blocking=0を無条件に正式認定しない |

## 8. Archive不足とOriginal Conversationからの取得手順

対象Conversation：[https://chatgpt.com/g/g-p-6a9f817f3494819191f072d806bf7565/c/6ac98b8c-c5d8-83ec-a6aa-4b0800c38510](https://chatgpt.com/g/g-p-6a9f817f3494819191f072d806bf7565/c/6ac98b8c-c5d8-83ec-a6aa-4b0800c38510)

このチャットに各Entry PointのImmediate Window原文が投稿された事実は、過去会話の検索結果および引継ぎから確認できている。ただし、本書作成時には**会話ページから各原文を全文コピーする権限・操作が成立しておらず、原文は実際には抽出していない**。

今後のRaw Archive構成候補（**ファイルはまだ存在しない**）：

```text
Evidence/P2-04/2026-10-18/
  Bootstrap_ProductionCompatibility_raw.txt
  I03_InvalidCandidate_raw.txt
  I04_OftMissing_raw.txt
  I05_DefinitionReadFailure_raw.txt
  I06_BuildSyncDiffFailure_raw.txt
  I07_I08_ContinuousRetry_raw.txt
  I09_WarmLifecycle_raw.txt
  I10_InitialAbort_raw.txt
  I10_BaselinePreparation_raw.txt
  I10_FinalPass_raw.txt
  I11_ManualOnly_raw.txt
```

転記ルール：ユーザー原文の開始・終端・PASS/FAIL件数・`Overall`・復元・ABORTを**原文のまま**保存。二次要約は別Recordへ残す。Rawファイルの作成日時を実行日時と偽装しない。各ファイルSHA-256、取得元会話URL、対象エントリ、採取日を記録。コピー時に機密情報が含まれる場合は生ログの取扱ポリシーに沿って保護する。

原文にしか残らない細部・件数矛盾が見つかれば、このDRAFTを見直す。現在の結果を自動的にPASS/CLOSEDへ昇格しない。

## 9. Gate Decision

```text
Historic P2-04 Completion / Finalized      PASS (Historical)
2026-10-18 Reported Harness Assertions    182/182 PASS; FAIL 0
I10 ABORT History                         RECORDED (Secondary Source)
Source Versioned Match                     9/9 NORMALIZED MATCH
Tested Workbook Hash                        RECORDED (USER-REPORTED)
2026-10-18 Raw Log Verbatim Archive        NOT VERIFIED
P2-02/P2-03 Regression Formal Closure     PENDING
I01/I02 Current Build Rerun                NOT CLAIMED
Finding Assessment for This Cycle          PENDING

2026-10-18 P2-04 Regression Closure        DRAFT / PENDING
I12 Contract Regression Decision           PENDING
P2-05 Completion                           NOT CLAIMED
P2 Phase Exit / CP-P2                      NOT CLAIMED
```

**判定**：今回提供できた根拠を最大限構造化した結果、182件のPASSは履歴・引継ぎから追跡可能。生ログの原文照合がまだないため、正式な`PASS / CLOSED`とはしない。新しいProduction修正や182件の再実行を自動要求する根拠はない。

## 10. Project Placement

- Document type：Regression Result Record。
- Suggested project path：`Docs/03_verification/technical_validation/P2-04 Manual Sync Integration Regression Record v0.1.md`。
- Raw Evidence：`Evidence/`（正式保存先は未確定）。
- 今回はローカルのDRAFT作成のみ。Project RepositoryのRegistry/Overview、Git Commit、Pushは変更していない。

## まとめ / Summary

**日本語**：過去会話のログ存在と引継ぎ情報を根拠に、2026-10-18の182 Assertionを回帰記録へ構造化した。全ログ原文は未抽出のためI12とRegressionの正式ClosureはPENDINGとする。9モジュールはGitHub対応版に正規化一致した。

**English**: This draft records the reported 182 passing regression assertions, with case-level findings from the handoff. Original raw logs are not yet copied, so regression and I12 closure remain pending. Nine production modules match their GitHub revisions after normalization.
