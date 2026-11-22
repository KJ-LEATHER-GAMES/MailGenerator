# T1 Import／Compile Evidence記録テンプレート

> **新規作成した隔離Workbook用。実測前にPASSを記入しないこと。**

| 項目 | 実行者記入欄 |
|---|---|
| Document ID | DOC-EVD-P304P305-T1-IMPORT-COMPILE |
| Status | NOT VERIFIED |
| 実行者 | Ko-chan |
| 実行日時（JST） | 2026/11/22 20:20 |
| Windows Version | Windows 11 Home Ver.26H2 |
| Excel Edition / Version / Bit数 | Personal / 2508 / 64bit |
| 保存したT1 Workbook（フルパス） | C:\Users\S5B_Compile\Documents\MailGenerator_Test\T1_20261122\T1_Nominal_20261122.xlsm |
| VBAProject表示名 | T1_Nominal_20261122.xlsm |
| 取得元GitHub branch / 日時 | `main` / 2026/11/22 10:50 |
| P0 3ファイル取得状況／Commit等 | 取得済み |
| Form作成経路 | Manual Designer |
| `.frm` Direct Import実測 | 標準モジュールとしてインポートされる |
| 手動Designer使用 | 実施 |
| 7固定Controlの名前・親子関係 | OK |
| 11コンポーネント一致 | OK |
| Duplicate／同名API衝突なし | OK |
| Missing Referencesなし | OK |
| VBA Compile結果 | OK |
| Compile最初のエラーメッセージ | エラーなし |
| 強調されたModule／行 | エラーなし |
| Screenshots保存先 | C:\Users\S5B_Compile\Documents\MailGenerator_Test\T1_20261122\evidence\screenshots |
| Workbook保存完了 | OK |
| Production・GitHub・Baseline不変更 | OK |
| Result classification | COMPILE_PASS |
| Finding ID（該当時） | - |
| 次のアクション | T1のNominal 21件＋XU-01/02回帰35件およびDirect Hide/Xボタン手動チェックへ進む |

## コンポーネントチェック

- [x] Class: `COperationResult`
- [x] Class: `CErrorInfo`
- [x] Module: `modResult`
- [x] Module: `modP3UserFormController`
- [x] Module: `modInputState`
- [x] Module: `modP3_04GateStub`
- [x] Module: `modP304P305NominalTests`
- [x] Module: `modP3_04XU02Tests`
- [x] Module: `modTESTONLY_DirectHide_Tests`
- [x] Module: `modTESTONLY_ModalQueryClose_Smoke`
- [x] UserForm: `frmMailGenerator`

## 固定Controlチェック

- [x] `lblHeader`: Form直下 Label
- [x] `lblGuidance`: Form直下 Label
- [x] `fraInputArea`: Form直下 Frame
- [x] `fraErrorArea`: Form直下 Frame
- [x] `lblErrorText`: **fraErrorArea内** Label
- [x] `cmdCreateMail`: Form直下 Button / Enabled=False
- [x] `cmdClear`: Form直下 Button / Enabled=False

## Compile操作記録

- 実行メニュー：`Debug > Compile VBAProject`
- 実行日時：2026/11/22 20:20
- 実行結果：COMPILE_PASS
- 最初のエラーダイアログの原文：-
- 強調された行の原文：-
- 選択されたVBE Component：-
- 画面証拠：T1_01_Project_Explorer.png
- 実行後Workbook保存：済み

## 判定

**判定区分：** `COMPILE_PASS`

**根拠（実測Actual Resultのみ）：** 添付スクショ

**次工程：** T1のNominal 21件＋XU-01/02回帰35件およびDirect Hide/Xボタン手動チェックへ進む
