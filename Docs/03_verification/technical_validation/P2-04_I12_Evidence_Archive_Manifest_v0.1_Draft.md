# P2-04 I12 Evidence Archive Manifest v0.3 — Approved

Version: v0.3 / Updated: 2026-10-24 (JST)

Status: Approved / G2 APPROVED_BY_USER / S1-C REVIEWED / S1 CLOSED

本文v0.2 Draftの既存保全・レビュー結果を維持し、G2承認記録を追加したv0.3／Approved。既存の参照入口名 `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md` はリンク保持のため維持する。正式Version／Statusは本管理欄によるもので、ファイル名の旧v0.1_Draftを現行状態と解釈しない。新規文書・改名・Baseline変更は行わない。

## 1. Handling Policy

Original logs are immutable for audit. Some P2-04 output contains a Windows user profile path; do not publish unredacted raw logs to public GitHub. Store originals in a private/access-controlled Evidence location and record the original SHA-256 unchanged. If public sanitized copies are needed, track them as separate files with separate SHA-256 and an explicit transformation note.

Public metadata is limited to the existing Archive Set ID / Evidence IDs, filenames, byte sizes, original SHA-256 values, verification results, and safe document references. Actual locators, raw Evidence, SID/SDDL, secrets, and Private Index contents remain private. No sanitized derivative was created.

## 2. Evidence Registry

Archive Set ID: `ARC-MG-P2-I12-20261018`（既存の保全識別子）。以下のPASSはS1-Bで実測されたサイズ・SHA-256一致を示す。S1-Cでは両Private Indexと既存実行Evidenceを照合して再利用し、Archive／Restoreを再実行していない。

| ID | Raw file | Bytes | SHA-256 | Primary | USB Backup | USB Restore | Evidence |
|---|---|---:|---|---|---|---|---|
| E-P202-RAW | `261018_P2-02_Regression Log.txt` | 11,170 | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` | PASS | PASS | PASS | P2-02 111/111; duplicate bootstrap excerpt excluded |
| E-P203-RAW | `261018_P2-03_Regression Log.txt` | 4,131 | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` | PASS | PASS | PASS | P2-03 46/46, five suite restored markers |
| E-P204-RAW | `261018_P2-04_Regression Log.txt` | 19,812 | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` | PASS | PASS | PASS | P2-04 182/182, I10 first ABORT + 20/20 pass |
| E-P204-SOURCE | `P2-04_Regression_20261018.zip` | 25,325 | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` | PASS | PASS | PASS | 9 Production source exports; GitHub 9/9 normalized match |
| E-P204-WB | `MailGeneratorNew.xlsm` | 1,003,775 | `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9` | PASS | PASS | PASS | Selected binary FILE_VERIFIED in S1-B; historical execution/Compile identity not independently proved |

### Preservation / Restore Evidence

| 項目 | 照合済みの結果・根拠 |
|---|---|
| 実行識別 | 上記Archive Set ID。EXECUTE_ARCHIVEの実行前照合は2026-10-24 10:58:14 JST、最終事後照合は同11:07:22 JST（既存Codex実行Evidence）。新しい実行Run IDは生成しない |
| 保全・復元 | E2：原本→Primary 5/5、E3：同じ原本→USB Backup 5/5、E4：USB Backupだけを復元元として5/5。全段階で表のサイズ・原本SHA-256と一致 |
| Private Index | Primary／Backupの既存IndexをS1-CでRead-only照合し、内容・各9,712 bytes・SHA-256が一致。実行時のIndexチェックサムとも一致。Index本体・実Locator・Indexチェックサム実値は既存の非公開Evidence側で保持 |
| 後処理 | PLAN_CONFORMANT。照合後、この実行で生成したRestoreコピー5件と試験Runフォルダだけを削除。原本・両Archiveは保持され再復元可能。復元先の上位2階層は保持（最下層は空） |
| 事後条件 | 既存実行Evidenceで原本5件のサイズ・SHA-256・LastWriteTimeUtc不変、意図しない上書きNONE、ACL／BitLocker変更NONE、Git操作NONE。今回のS1-CでもArchive／Indexへの書込み・再実行なし |

Private locatorは、上記Archive Set IDに対応するPrimary／Backupの非公開`Archive_Index_Private.md`からEvidence IDとRaw file名で解決する。公開Manifestに実パスへのリンクやPrivate Index全文は置かない。

### Provenance

- Reviewer can verify SHA-256 of received original logs and ZIP. Source ZIP is not the binary Workbook.
- Workbooks used in prior individual Regression sessions may not share same binary SHA even when Production Source is attested identical.
- `BL-MVP-004` approval record exists; GitHub Project Registry has different acceptance/synchronization context.
- I12 Evidence-Reuse policy was expressly accepted by the operator on 2026-10-19; do not claim 157 past tests are fresh 2026-10-18 assertions.
- v0.1のWorkbook欄にあった「User-reported SHA-256, binary not received」、保管位置未確定・未保全・Repository write未実施等は作成当時の記録であり、上表のS1-B現物保全確認と時点を区別する。現物保存の確認を過去の実行日時・VBAProject全体一致・Compileの独立証明へ格上げしない。
- Private Index内のRepository参照ハッシュや「S1-C未実施」はS1-B記録時点の履歴。今回の許可済み現在地訂正・Manifest更新後の状態へ合わせてIndexを書き換えない。

## 3. Proposed placement (subject to repository folder rules)

次の3項目はv0.1の配置提案として保持する。Raw正本の現行保管先は上記の非公開Archiveであり、Public Repositoryへ原本・Workbook・Private Indexを追加する意味ではない。

- `Docs/03_verification/technical_validation/` : Closure Reviews, Final I12 Assessment, Execution Policy Decision, Evidence Matrix.
- `Evidence/` : non-public raw files or access-restricted Evidence reference/manifest where permitted.
- `Docs/00_project_control/Document_Registry.md` : authoritative references and status only after full review. Preserve BL003 history/other-PC acceptance distinction.

### Residual Risk / G2 Disposition

- OneDriveRegistration：**UNKNOWN**。同期安全性の技術的PASSとはしない。
- ManagementShareEffectiveAccess：**UNKNOWN**。[Primary限定受容](../../00_project_control/Project_Overview.md#s1-primary-risk-acceptance-20261024)と[Restore限定受容](../../00_project_control/Project_Overview.md#s1-restore-final-precheck-20261024)の既存S1範囲を維持する。
- Stage2TotalExecutionCount：**UNKNOWN**。[既存訂正履歴](../../00_project_control/Project_Overview.md#s1b-stage2-closure-20261024)を保持し、再調査・再実行しない。

<a id="s1-g2-approval-closure-20261024"></a>

### G2正式承認記録・S1 Closure

| 項目 | 記録 |
|---|---|
| G2 Decision / Authority | APPROVED_BY_USER / USER |
| ユーザー判断日 | 2026-10-24（JST）。本Codex会話の明示承認による。正確な時刻・架空の承認ID・電子署名は付与しない |
| 承認範囲 | P2 Evidence Archive S1に限定。S1-B実行PASS、S1-CレビューPASSを維持 |
| 承認根拠 | `ARC-MG-P2-I12-20261018`と上表5件。既存Primary／Backup／USB復元は各5/5_SHA256_PASS、Private Index Read-only整合・Traceability・Public／Private分離はPASS |
| 最終文書確認 | 本Manifest・Project Overview・Current HandoffのStatus／現在地・相対リンク／アンカー・差分・情報境界はPASS。既存PASSを再テストせず、Archive／Private Indexには変更なし |
| S1 Closure | CLOSED / G2_RECORDED_S1_CLOSED。3文書の整合性確認成立による記録完了 |
| 残留事項 | 上記3件のUNKNOWN、Primary／Restoreの既存S1限定リスク受容、歴史的Evidenceの限界を維持。技術的PASSや他工程の承認へ拡張しない |
| 対象外 | P2-02／P2-03正式Closure、P2全体Closure、P2 Phase Exit、CP-P2確立、Baseline承認・切替。Git操作・Archive／Restore再実行なし |

### G2承認前の履歴（本文v0.2 Draft／S1-Cレビュー時点）

[S1計画](../../00_project_control/S1_Evidence_Archive_Implementation_Plan_v0.1_20261021.md)および[S1-B実施条件](../../00_project_control/S1_B_Archive_Storage_Access_Backup_Specification_v0.1_20261021.md)の保全・照合・復元・Index整備の範囲を維持する。今回はユーザーの明示承認によるG2前のS1-C資料整備・レビューであり、旧計画のG2先行条件を通過済みとは扱わない。新しいGateを追加せず、上記照合結果と非公開Index／既存実行EvidenceをG2判断材料とする。

**S1-C：REVIEW PASS／G2：PENDING・NOT APPROVED／S1：NOT CLOSED**。最新現在地は[Project Overview](../../00_project_control/Project_Overview.md#s1c-current-after-execution-20261024)、再開入口は[Current Handoff](../../05_handoff/Current_Handoff.md)を参照する。ユーザーによるG2正式承認・S1 Closure・P2 Closure・Baseline切替は本書の更新／レビューに含めない。

## 4. Revision History

| Version | 記録 |
|---|---|
| v0.1 Draft | 4原文資産＋Workbook申告を5行で索引化した時点の記録。非公開保全位置は未確定。旧SHA値・歴史的検証の限界は維持 |
| v0.2 Draft | 2026-10-24 S1-C：原本5件の保全・USB復元・Private Index整合と既存実行Evidenceを照合し反映。参照入口の既存ファイル名は維持。G2承認・S1 Closureなし |
| v0.3 Approved | 2026-10-24 G2ユーザー正式承認と3文書の最終整合性確認に基づきS1 CLOSEDを記録。v0.2 Draft／G2 PENDINGは上記履歴に保持。5件の保全結果・SHA・既存限定リスク受容は不変。ファイル名維持・Git操作なし |

## まとめ / Summary

**日本語**：対象5件のPrimary／Backup保全とUSB復元の各5/5 SHA-256 PASSおよびS1-CレビューPASSを維持。2026-10-24（JST）のユーザーG2正式承認を記録し、3文書の最終整合性確認によりS1 CLOSED。残留UNKNOWN・既存S1限定受容は維持し、P2全体Closure・Baseline更新は含まない。

**English:** Existing five-file archive, USB restore, and S1-C review PASS results are preserved. User G2 approval dated 2026-10-24 JST is recorded; documentation consistency confirms S1 CLOSED. Residual UNKNOWNs remain; no P2 closure or baseline change is implied.
