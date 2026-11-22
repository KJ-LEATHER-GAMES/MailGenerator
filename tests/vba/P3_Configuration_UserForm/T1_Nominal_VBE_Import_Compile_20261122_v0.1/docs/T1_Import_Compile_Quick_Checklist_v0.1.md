# T1 Import／Compile 現場用チェックリスト

**今回の対象：T1 Workbook新規作成 → 11部品Import／Form作成 → VBE Compile → Evidence記録。Runtimeは実行しない。**

- [ ] Productionを閉じ、新規空白Workbookを `.xlsm` で別保存（T1と表示確認）
- [ ] P0 Class 2件をGitHubの`main`から読み取り専用で取得
- [ ] P0 `modResult.bas`を同様に取得
- [ ] T1 Standard Module 7件をImport（本キット `T1_sources/`）
- [ ] GateはStub、Input Stateは実Candidate。Fault Stubと実P3-03はImportしない
- [ ] `.frm`直接Importを試し、結果を記録する
- [ ] 失敗時：手動Designerで固定Control7件を正確に作成しCodeOnly貼付
- [ ] VBAProjectのClass2・Module8・Form1＝**11件**
- [ ] `MISSING:` 参照なし、親子関係に誤りなし
- [ ] `Debug > Compile VBAProject` を実行
- [ ] 初回Compile Errorが出たら**停止**し、原文・行・スクリーンショットを保存
- [ ] Compile成功なら結果を記録し、隔離Workbookを保存
- [ ] **T1 Runtimeテストを実行していない**
- [ ] Production／GitHub／Baselineに変更がない

**提出：** `T1_Import_Compile_Result_YYYYMMDD.md`＋スクリーンショット。

## まとめ / Summary

**日本語：** T1のImport・Compile・証拠記録の漏れ防止用チェックリスト。

**English:** A short checklist for T1 Import, Compile, and evidence recording.
