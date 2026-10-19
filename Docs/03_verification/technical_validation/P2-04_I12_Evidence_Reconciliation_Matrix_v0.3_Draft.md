# P2-04 I12 Evidence照合マトリクス v0.3 — Draft

## 1. 前版差分と判断境界

| 項目 | v0.2 | v0.3（今回） |
|---|---|---|
| BL-MVP-004の承認記録 | 確認済み | 確認済み（変更なし） |
| 2026-10-18のWorkbook SHA-256 | 未確認 | ユーザー申告値を識別子として記録、独立再計算なし |
| Production VBA ExportとGitHub Revision | 未照合 | **9/9 Normalized Match**（Build Provenance v0.2） |
| Bootstrap・I03～I11のログ | **HANDOFF-REPORTED / RAW NOT VERIFIED** | **USER-RAW-LOG RECEIVED / ASSERTIONS VERIFIED** |
| 今回のExecution | 182/182 PASS報告 | **182/182 PASS、FAIL 0件を原文439行と照合済み** |
| I10初回ABORT | 引継ぎ要約 | **原文L325–331でABORT確認、L335–385に準備・最終PASSあり** |
| P2-02/P2-03の独立Regression Record | DRAFT | DRAFT（変更なし。旧ログArchive未確認） |
| I01/I02の現行Build独立再実行 | 実施なし | 実施なし |
| I12最終判定 | PENDING | **PENDING / NOT CLOSED** |

前版の未確認事項は**今回の182件のログ**についてのみ消し込む。P2-02 111件、P2-03 46件の過去Evidenceの原文と誤認して扱わない。

## 2. 原文ファイル・Integrity / Source of Truth

- User-provided source: `261018_P2-04_Regression Log.txt`。
- Byte-for-byte archive: [P2-04_Regression_20261018_Raw.txt](../../../Evidence/P2-04/2026-10-18/P2-04_Regression_20261018_Raw.txt)。
- Raw Log SHA-256: `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add`。
- Source Lines: **439**（UTF-8/CRLF）。
- Test Date: 2026-10-18（ユーザー申告）。
- Tested Workbook: `MailGeneratorNew.xlsm`（GitHubの別版とは区別）。
- Tested Workbook SHA-256（ユーザー申告）: `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`。
- Main result record: `P2-04_Manual_Sync_Integration_Regression_Record_v0.2_Draft.md`。
- VBA/source correlation: `P2-04_Regression_Build_Provenance_Verification_v0.2_Draft.md`。
- Historic source: `P2-04 Manual Sync Integration Completion Record v0.1.md` and historic `Regression Evidence Finalization v0.1.md`（**別Cycle**）。

## 3. 今回Cycle・ケース別Coverage

| Run | Log Lines | Assertion | Result | Observations |
|---|---|---|---|---|
| `BOOT` | L2–43 | 29/29 | **PASS** | Production Compatibility / original contents restored |
| `I03` | L44–88 | 10/10 | **PASS** | Invalid Candidate → SyncDiff Nothing |
| `I04` | L89–117 | 11/11 | **PASS** | Missing OFT → both carrier Nothing / restored to case initial path |
| `I05` | L118–169 | 17/17 | **PASS** | Broken Status column → fail closed / restored |
| `I06` | L170–229 | 22/22 | **PASS** | Invalid Status → fail closed / restored |
| `I07/I08` | L230–291 | 37/37 | **PASS** | 1004 Apply failure → explicit Fresh Retry / Restore |
| `I09` | L292–324 | 16/16 | **PASS** | Warm Explorer reused / No Inspector Draft residue |
| `I10-ABORT` | L325–334 | — | **ABORTED** | Baseline未準備、Production未実行 |
| `I10-PREP` | L335–348 | — | **PREPARED** | Outlook Warm baseline準備 |
| `I10-PASS` | L349–388 | 20/20 | **PASS** | Cold Outlook 0→1 / Explorer visible |
| `I11-PREP` | L389–407 | — | **PREPARED** | 保存・Fingerprint Baseline採取 |
| `I11-PASS` | L408–439 | 20/20 | **PASS** | Workbook Open no Sync / Explicit Manual Sync / Restore & Save |
| **合計** | — | **182/182** | **PASS / FAIL 0** | ABORT/PREP/SUPPORT行はAssertionに追加計上しない |

ここでの`RAW-LOG VERIFIED`は**ユーザー提供のログ原文と記録内容を突き合わせた**という意味。ログの生成過程、Workbookバイナリ、Officeアプリを独立再実行した保証を含まない。I11には本試行中の追加`PASS`観測2行が存在するが、Suiteの`PASS Count = 20`が正式値である。

## 4. I12 Evidence再利用評価

| Coverage | 既存Evidence | Current-cycle Build/Source link | 再利用／Closure判定 |
|---|---|---|---|
| P2-01 Full Scanner | 2026-10-09 Regression Record `PASS/CLOSED` | ExportのP2-01 v0.1.1一致 | **Candidate**。旧実行時Build・OFT条件の適用性は未完了 |
| P2-02 Sync Diff Core | 2026-10-10独立Record `111/111 PASS`、**DRAFT** | ExportのP2-02 v0.1.3一致 | **Candidate**。旧Execution Raw Log / Build/Fixture・Formal Closure未確認 |
| P2-03 Persistence | 2026-10-11独立Record `46/46 PASS`、**DRAFT** | ExportのP2-03 v0.1.2一致 | **Candidate**。旧Execution Raw Log / Build/Fixture・Formal Closure未確認 |
| P2-02→P2-03 Bootstrap | **今回原文**L2–41に29/29 PASS | 9-module Source Provenanceと関連付け | **CURRENT-CYCLE RAW VERIFIED** |
| P2-04 I03–I11 | **今回原文**L44–439に153/153 PASS、初回I10 ABORT | 同上 | **CURRENT-CYCLE RAW VERIFIED** |
| I01/I02 | Historical P2-04 Completion | 現行Buildで直接の再実行なし | 過去Evidenceの適用性評価待ち／新実行と記載しない |
| I12 | Previous Direct-Rerun Guide vs Subsequent Evidence Integration Plan | Source一致＋今回182件のRaw Evidenceが成立 | **PENDING**。旧P2-01/02/03証拠の適用判断が必要 |

**Guide vs Plan:** `P2-04_I12_Contract_Regression_Guide_v0.1.md`はI12-A～Dの直接再実行を記載。後続の`P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`は既存Evidence統合を採用。現時点では後者の方式を進めるが、再利用の条件とClosure判断を明確にした上で確定する。

## 5. 残るGateとFinding

| Gate | Status / Evidence | 次の処置 |
|---|---|---|
| G-01 BL-MVP-004 Approval | **Record CONFIRMED**、`BL-MVP-003`残表示あり | 申告実行PC・別PC受入状態とProject Control差分を別管理 |
| G-02 Build Provenance | **9/9 NORMALIZED MATCH**、Workbook SHA-256申告記録 | Workbook実バイナリ独立検査は未実施と明記 |
| G-03 今回182件Raw Evidence | **PASS / CLOSED FOR SOURCE-COLLECTION**：原文受領、SHA-256、439行、182PASS一致 | Evidence/の正式保存先とRecordリンクはRepo反映時に確定 |
| G-04 P2-02/P2-03過去のRaw Evidence | **PENDING**（今回ログとは別） | 2026-10-10 / 10-11の旧実行ログ保存先と独立Recordを照合 |
| G-05 I01/I02 Applicability | **PENDING** | 旧Evidence→今回Buildの契約影響評価 |
| G-06 I12 Integration Acceptance | **PENDING** | Reuse/Coverageを完成しFinal Finding Assessment実施 |
| G-07 Fixture / Compile / Global State | **PARTIALLY VERIFIED** | ログが示す個別Restoreと完全復元・Compileを区別。I03 OFT復元、I04 Setting最終状態はログのみでは立証せず |

### 観測・Finding境界

- I10：初回Baseline未準備でABORTED（Production未実行）、後続に20/20 PASS。原因は確定せず。初回を消さない。
- I06：Preflight見出し`I05`。軽微なTest Artifact表示誤記候補。
- I07：Persistence書込み開始後の失敗では部分更新の可能性が明示されており、Observed Before/After一致をRollback保証としない。
- I11：Test内のWorkbook保存とTEMP Baseline削除は原文確認済み。ユーザーの「Regression後保存なし」は追加保存なしの意味として扱い、バイナリの独立照合では未実証。
- `OBS-P2-05-002` WordEditor intermittent E_FAIL：**OPEN / NON-BLOCKING**を維持。今回I09/I10 PASSでも根本解消とは判断しない。
- Active Blocking Finding 0の**Final Assessmentは未実施**。No new production failure shown in supplied logsという範囲に限定。

## 6. 次のアクション

1. Original raw logをアクセス制御下で`Evidence/P2-04/2026-10-18/`へ保存し、SHA-256をRecordへ記載。個人ディレクトリ等が原文に含まれるため公開範囲を確認。
2. P2-02 111件・P2-03 46件の**過去原文ログ**とそれぞれの実行Buildの照合、独立Regression RecordのClosure判断。
3. 旧P2-04 I01/I02証拠の再利用影響確認。必要な場合のみ対象Contractを選択的に再検証。
4. I12 Evidence統合、Final Finding Assessment、`PASS/CLOSED`可否の独立判定。P2-05/CP-P2は別Gateで管理。

本資料は会話作業環境に作成したDraftである。GitHub Projectへの追加・Commit、Overview/Registry更新、Formal P2-04 Closureは実施していない。

## まとめ / Summary

**日本語:** 2026-10-18の原文439行で182 Assertion全件PASSと初回I10 ABORTの履歴を確認。今回Raw Evidenceの所在問題は解消した。ただしP2-02/P2-03の過去生ログ、旧Evidence再利用適用、Global Fixture/Compile、Final Assessmentは残るためI12はPENDING。

**English:** The 439-line raw transcript confirms 182 passing assertions and preserves the first I10 abort. Current-cycle raw evidence is now available. Historical regression archives and final I12 closure still require review.
