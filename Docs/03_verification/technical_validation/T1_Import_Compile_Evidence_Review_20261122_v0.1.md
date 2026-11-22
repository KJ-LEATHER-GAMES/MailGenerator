# T1 Nominal Import／Compile Evidence Review v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | DOC-REV-P304P305-T1-COMPILE-001 |
| Revision | v0.1 |
| Status | REVIEWED — User-reported `COMPILE_PASS` accepted for T1 preparation gate; independent reproduction `NOT VERIFIED` |
| Review Date | 2026-11-22 (JST) |
| 対象 | T1 Nominal 隔離Workbook（P3-04 × P3-05 Integrated Input State Candidate v0.1） |
| 判定対象 | Class Module / Standard Module / UserForm の配置、VBE Import、Compile |
| 対象外 | Runtime Test、実P3-03統合、Production採用、P3 Phase Closure |

## 1. 参照Evidence

- ユーザー提出 `T1_Import_Compile_Evidence_v0.1.md`（原本は変更しない）
- ユーザー提出 `drive-download-20261122T122932Z-1-001.zip`：PNG5枚
  - `T1_01_Project_Explorer.png`：Windowsファイルエクスプローラーの画面（名称と内容に差異）
  - `T1_02_Form_Designer_01.png`：VBE Project Explorer／Form上部／固定Control配置
  - `T1_03_Form_Designer_02.png`：VBE Project Explorer／Form下部／ボタン配置
  - `T1_04_Form_Code.png`：FormのVBEコード画面
  - `T1_05_Excel_Version.png`：Excelアカウント／製品情報
- 検証用部品一覧：`T1_VBE_Import_Compile_Detailed_Runbook_v0.1.md` と `P304_P305_Isolated_VBE_Execution_Kit_20261121_v0.1.zip`

## 2. 事実とEvidenceの区別

| 項目 | 実行者記録 | Reviewer観測 | 判定 |
|---|---|---|---|
| 作業対象Workbook | `T1_Nominal_20261122.xlsm` | VBE画面に隔離Workbookを確認 | 記録・画像整合 |
| 11コンポーネント | チェック済み | VBE Project Explorerにクラス、標準Module、UserFormが見える（画像解像度で個々の名称は記録が主証拠） | 実行者確認を受容 |
| Class 2件 | クラスとして登録 | Project Explorerに Class Modules の2件が見える | 画像整合 |
| 7固定Control | チェック済み | Form Designerの上部／下部にControlが見える。全Property値・親子構造の完全独立検証はしていない | 実行者確認を受容 |
| `.frm` Direct Import | 標準Moduleになった | Import操作を直接示す画像なし | **Direct Import PASSではない** |
| Form作成 | Manual Designer | VBE Designerを確認 | 記録・画像整合 |
| VBA Compile | `Debug > Compile VBAProject`、エラーなし、`COMPILE_PASS` | Compile処理そのものを示す画面はなし（成功時はダイアログなし） | **実行者の実測報告として `COMPILE_PASS` 受領** |
| Workbook保存 | 保存済み | 保存されたブックの存在はWindows画面で補助確認（内部のExcelファイルは未提出） | 実行者確認を受容 |
| Production/GitHub/Baseline | 変更なし | 独立確認なし | 実行者報告。遠隔変更は行っていない |

**解釈：** User-reported `COMPILE_PASS` の証拠を受領し、T1のRuntime準備へ移行してよい。ただしReviewerが実際にVBEでCompileしたことや、元Candidateとの全コード同一性を証明したものではない。T1 Gate Stubを使っているため実P3-03統合は未検証。

## 3. Evidence整合性の修正推奨（原本には未反映）

- 原本の表の `Status = NOT VERIFIED` を、実行者確認のうえ `COMPILE_PASS (T1 Manual Designer)` 等の表現へ更新し、`Revision v0.2` を付ける。末尾は既に `COMPILE_PASS` であり、現在は文書内不一致。
- `T1_01_Project_Explorer.png` はWindowsファイルエクスプローラーで、VBEのProject Explorerは主に `T1_02` と `T1_03` に写っている。証拠説明のラベルを直す（画像を加工しない）。
- 実機で使用したクラス作成方法（正規化済み`.cls` Importまたは手動Class Module）を、可能ならEvidenceに追記する。
- 候補ソースと実機Workbook内コードのバイト／テキスト一致、`Debug > Compile`メニューの実行後画面は未取得。必要なら追加確認するが、今回の報告を取り消す理由ではない。

## 4. 進捗 / Decision Log

| 対象 | Status |
|---|---|
| T1 Import / Manual Designer 構成 | `COMPLETED`（実行者報告、画像補助確認） |
| T1 VBA Compile | `COMPILE_PASS`（ユーザー実測、Reviewer未再実行） |
| `.frm` Direct Import | `NOT PASSED`（Manual Designer採用） |
| T1 Runtime Nominal (21) | `NOT RUN` |
| T1 XU-01/XU-02 Regression (35) | `NOT RUN` |
| T1 Direct Hide, X/QueryClose Manual | `NOT RUN` |
| T2 Fault / T3 UI Clear Fault | `NOT RUN` |
| Production / Baseline / GitHub | `NO CHANGE`（今回の作業） |
| XU-01 / XU-02 Runtime Closure | `OPEN` |
| P2 Closure / S5-C / P3正式開始 | `UNCHANGED` |

## 5. 次工程：T1 Runtime 実施順

実行前：隔離Workbookを別名保存／バックアップし、VBE Immediate Window（`Ctrl+G`）とEvidence記録を準備する。Production Workbookは開かない。

1. `RunP304P305NominalCandidateTests`（`modP304P305NominalTests`）を実行。Immediate Windowの `P304-P305 nominal: PASS=21 FAIL=0` が期待値。例外や終了不能があればSTOPして最初のFindingを記録。
2. `RunP304XU02CandidateTests`（`modP3_04XU02Tests`）を実行。期待 `P3-04 candidate total: PASS=35 FAIL=0`。
3. `RunTESTONLY_DirectHide_Test` を実行。`DIRECT-HIDE-001 ... PASS` を期待。このテストは**本来禁止の直接Hide**を、隔離環境でのみ意図的に呼ぶ。
4. `RunTESTONLY_ModalQueryClose_Smoke` を実行。表示Formの**最初の入力欄に `QC-OK` を入力し、右上Xで閉じる**。`QC-MODAL-001 ... PASS` を期待。無応答・Failureでは強制的にSuccess扱いせず実測を保存。

上記の順序は推奨。1ケースでも異常ならエラーメッセージ、画面、Immediateログ、どのテストIDまで進んだかを記録し、元Candidateを無断修正しない。T2/T3は別Workbookで後続実施。

## 6. 最終判定

**T1 Import / Compile：`PASS (user-observed; evidence reviewed)`。** 
**T1 Runtime：`NOT RUN`。**
**Production採用／P3正式開始：`NOT APPROVED`。**

## まとめ / Summary

日本語：T1のManual DesignerとCompile成功の実測報告を受領・照合しました。Compile PASSとして進捗を更新できますが、Runtime PASSではありません。次はT1の21＋35ケースとDirect Hide／Xボタンの手動検証です。

English: T1 manual setup and Compile passed in the user's test. We reviewed the evidence. Runtime tests have not run. Next, run 21 nominal tests, 35 regression tests, and two manual checks.
