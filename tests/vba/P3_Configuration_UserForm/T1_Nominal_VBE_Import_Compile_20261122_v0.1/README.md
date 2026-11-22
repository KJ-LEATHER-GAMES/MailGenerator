# T1 Nominal VBE Import / Compile Guide v0.1

**Status:** PREPARED / Import、Compile、Runtime未実施

- `docs/T1_VBE_Import_Compile_Detailed_Runbook_v0.1.md`：まず読む詳細手順（日本語）
- `docs/T1_Import_Compile_Quick_Checklist_v0.1.md`：実行時チェックリスト
- `docs/T1_Import_Compile_Evidence_Template_v0.1.md`：実行結果の記録テンプレート
- `T1_sources/`：元実行キット内T1用の**同一バイト**をコピーした部品（元からの改変なし）
- `SOURCE_MANIFEST.json`：収録元とSHA-256記録

**別途入手する3ファイル：** GitHub `KJ-LEATHER-GAMES/MailGenerator` / `main` の`src/classes/COperationResult.cls`、`src/classes/CErrorInfo.cls`、`src/modules/modResult.bas`（ZIPには含まれない）。

**禁止：** Production Workbook、GitHub、BL-MVP-004の変更、T2/T3との混在、Compile未成功でRuntimeを進めること。

## まとめ / Summary

**日本語：** T1の詳細実行手順と証拠テンプレート。未実行でありProduction変更なし。

**English:** A T1 execution guide and blank evidence form. No VBA test has run. Production is unchanged.
