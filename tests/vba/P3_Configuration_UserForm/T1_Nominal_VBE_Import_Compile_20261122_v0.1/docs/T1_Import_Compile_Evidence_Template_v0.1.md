# T1 Import／Compile Evidence記録テンプレート

> **新規作成した隔離Workbook用。実測前にPASSを記入しないこと。**

| 項目 | 実行者記入欄 |
|---|---|
| Document ID | DOC-EVD-P304P305-T1-IMPORT-COMPILE |
| Status | NOT VERIFIED |
| 実行者 |  |
| 実行日時（JST） |  |
| Windows Version |  |
| Excel Edition / Version / Bit数 |  |
| 保存したT1 Workbook（フルパス） |  |
| VBAProject表示名 |  |
| 取得元GitHub branch / 日時 | `main` /  |
| P0 3ファイル取得状況／Commit等 |  |
| Form作成経路 | Direct / Manual Designer / 未実施 |
| `.frm` Direct Import実測 | NOT VERIFIED |
| 手動Designer使用 | 未実施 |
| 7固定Controlの名前・親子関係 | NOT VERIFIED |
| 11コンポーネント一致 | NOT VERIFIED |
| Duplicate／同名API衝突なし | NOT VERIFIED |
| Missing Referencesなし | NOT VERIFIED |
| VBA Compile結果 | NOT VERIFIED |
| Compile最初のエラーメッセージ | 未記入 |
| 強調されたModule／行 | 未記入 |
| Screenshots保存先 | 未記入 |
| Workbook保存完了 | NOT VERIFIED |
| Production・GitHub・Baseline不変更 | NOT VERIFIED |
| Result classification | NOT VERIFIED |
| Finding ID（該当時） |  |
| 次のアクション |  |

## コンポーネントチェック

- [ ] Class: `COperationResult`
- [ ] Class: `CErrorInfo`
- [ ] Module: `modResult`
- [ ] Module: `modP3UserFormController`
- [ ] Module: `modInputState`
- [ ] Module: `modP3_04GateStub`
- [ ] Module: `modP304P305NominalTests`
- [ ] Module: `modP3_04XU02Tests`
- [ ] Module: `modTESTONLY_DirectHide_Tests`
- [ ] Module: `modTESTONLY_ModalQueryClose_Smoke`
- [ ] UserForm: `frmMailGenerator`

## 固定Controlチェック

- [ ] `lblHeader`: Form直下 Label
- [ ] `lblGuidance`: Form直下 Label
- [ ] `fraInputArea`: Form直下 Frame
- [ ] `fraErrorArea`: Form直下 Frame
- [ ] `lblErrorText`: **fraErrorArea内** Label
- [ ] `cmdCreateMail`: Form直下 Button / Enabled=False
- [ ] `cmdClear`: Form直下 Button / Enabled=False

## Compile操作記録

- 実行メニュー：`Debug > Compile VBAProject`
- 実行日時：
- 実行結果：NOT VERIFIED
- 最初のエラーダイアログの原文：
- 強調された行の原文：
- 選択されたVBE Component：
- 画面証拠：
- 実行後Workbook保存：未確認

## 判定

**判定区分：** `COMPILE_PASS` / `FAIL_COMPILE` / `BLOCKED_IMPORT` / `NOT VERIFIED`

**根拠（実測Actual Resultのみ）：**

**次工程：**

---

## まとめ / Summary

**日本語：** T1のImportとCompileを実測し、証拠を記録するための未記入テンプレート。

**English:** This is a blank evidence form for T1 Import and Compile results.
