# T1 Nominal Runtime Evidence v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | DOC-EVD-P304P305-T1-NOMINAL |
| Document Title | T1 Nominal 21-Case Runtime Evidence |
| Revision | v0.1 |
| Status | **NOMINAL_RUNTIME_PASS（21/21、実行者提供EvidenceによるReview）** |
| 作成・Review日 | 2026-11-22（JST） |
| 実行日時 | 時刻未記録（当日の提出Evidence） |
| 対象 | P3-04 × P3-05 Integrated Input State Candidate v0.1／T1 Nominal隔離Workbook |
| 実行Workbook | `T1_Nominal_20261122.xlsm`（実行者の直近Compile Evidence v0.2を参照） |
| テスト入口 | `RunP304P305NominalCandidateTests` |
| Test Environment | Windows 11 Home 26H2／Excel Personal 2508 64bit（Import／Compile Evidence v0.2の記録を継承。Runtime時点の再確認は未実施） |
| 証拠 | `evidence/T1_06_Runtime検証.png`、`evidence/T1_Nominal_21_Immediate_Log_User_Report.txt` |
| Reference | `reference/T1_Import_Compile_Evidence_v0.2.md`（変更なしコピー） |

## 1. 実測結果（ユーザー提供）

**21 PASS / 0 FAIL。** イミディエイトウィンドウの最終集計と提供テキストは一致した。21件の各行もスクリーンショットで可視的に照合した。Review側でExcel VBAを再実行したものではない。

```text
P304-P305-NOM-RESTORE_TEXT PASS
P304-P305-NOM-RESTORE_DATE_RAW PASS
P304-P305-NOM-RESTORE_SELECT_EXACT PASS
P304-P305-NOM-RESTORE_MISSING PASS
P304-P305-NOM-RESTORE_EMPTY PASS
P304-P305-NOM-RESTORE_CASE_KEY PASS
P304-P305-NOM-STALE_SELECT PASS
P304-P305-NOM-SELECT_CASE PASS
P304-P305-NOM-CLOSE_CAPTURE PASS
P304-P305-NOM-CLOSE_EMPTY_SELECT PASS
P304-P305-NOM-PREFLIGHT_BAD_TAG PASS
P304-P305-NOM-PREFLIGHT_DUP_TAG PASS
P304-P305-NOM-CLEAR_BOTH PASS
P304-P305-NOM-CLEAR_SKIP_COMMIT PASS
P304-P305-NOM-CLEAR_REINPUT PASS
P304-P305-NOM-CLEAR_MANUAL_EMPTY PASS
P304-P305-NOM-SINGLE_GATE PASS
P304-P305-NOM-SCALAR_ISOLATED PASS
P304-P305-NOM-GATE_FAILURE PASS
P304-P305-NOM-UNBUILT_NO_SAVE PASS
P304-P305-NOM-STALE_CLOSE_EMPTY PASS
P304-P305 nominal: PASS=21 FAIL=0
```

## 2. 個別ケース判定

| No. | Test ID | Actual log |
|---:|---|---|
| 01 | `P304-P305-NOM-RESTORE_TEXT` | PASS |
| 02 | `P304-P305-NOM-RESTORE_DATE_RAW` | PASS |
| 03 | `P304-P305-NOM-RESTORE_SELECT_EXACT` | PASS |
| 04 | `P304-P305-NOM-RESTORE_MISSING` | PASS |
| 05 | `P304-P305-NOM-RESTORE_EMPTY` | PASS |
| 06 | `P304-P305-NOM-RESTORE_CASE_KEY` | PASS |
| 07 | `P304-P305-NOM-STALE_SELECT` | PASS |
| 08 | `P304-P305-NOM-SELECT_CASE` | PASS |
| 09 | `P304-P305-NOM-CLOSE_CAPTURE` | PASS |
| 10 | `P304-P305-NOM-CLOSE_EMPTY_SELECT` | PASS |
| 11 | `P304-P305-NOM-PREFLIGHT_BAD_TAG` | PASS |
| 12 | `P304-P305-NOM-PREFLIGHT_DUP_TAG` | PASS |
| 13 | `P304-P305-NOM-CLEAR_BOTH` | PASS |
| 14 | `P304-P305-NOM-CLEAR_SKIP_COMMIT` | PASS |
| 15 | `P304-P305-NOM-CLEAR_REINPUT` | PASS |
| 16 | `P304-P305-NOM-CLEAR_MANUAL_EMPTY` | PASS |
| 17 | `P304-P305-NOM-SINGLE_GATE` | PASS |
| 18 | `P304-P305-NOM-SCALAR_ISOLATED` | PASS |
| 19 | `P304-P305-NOM-GATE_FAILURE` | PASS |
| 20 | `P304-P305-NOM-UNBUILT_NO_SAVE` | PASS |
| 21 | `P304-P305-NOM-STALE_CLOSE_EMPTY` | PASS |

## 3. 判定の範囲

- **PASS対象：** 実P3-05 `modInputState`、P3-04 Candidate、**P3-03のテスト用Gate Stub**を組み合わせたNominal 21件。Runnerが各条件を評価して出力した結果。
- `CLOSE_CAPTURE`等はRunnerが `Unload f` を呼ぶプログラム経路であり、**ユーザー操作による右上Xの実行証拠ではない**。
- `SINGLE_GATE`／`GATE_FAILURE`は**Stubに対する呼出し確認**であり、実P3-03との結合成功ではない。
- Excel再起動、実OFT／Outlook、正式MTS-INPUT-001／002、T2／T3 Failure、XU-01／XU-02の正式Closure、Production採用を含まない。
- スクリーンショットはVBEのDesignerとイミディエイトウィンドウであり、実ユーザー操作画面の証拠ではない。

## 4. Quality Gate

| Gate | Result | Evidence |
|---|---|---|
| T1 Import／Manual Designer | PASS（実行者記録） | 既存Evidence v0.2 |
| T1 Compile | COMPILE_PASS（実行者記録） | 既存Evidence v0.2 |
| **T1 Nominal 21件** | **PASS** | 今回のログ・画像 |
| T1 XU-01／XU-02 Regression 35件 | NOT RUN | 未提出 |
| Direct Hide manual/test | NOT RUN | 未提出 |
| 実際のXボタン／QueryClose smoke | NOT RUN | 未提出 |
| T2 Failure Injection／T3 Clear Fault | NOT RUN | 未提出 |
| Formal MVP Test | NOT VERIFIED | 対象外 |

## 5. Revision

| Revision | 日付 | 変更内容 |
|---|---|---|
| v0.1 | 2026-11-22 | 提出ログ21件とスクリーンショットを整理した初版。既存Import／Compile Evidence v0.2を上書きしない。 |
