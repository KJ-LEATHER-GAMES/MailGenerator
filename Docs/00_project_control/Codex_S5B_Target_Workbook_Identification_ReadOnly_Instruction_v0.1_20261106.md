# S5-B Target Workbook特定の既存資料Read-only照合指示

S5-B Target Workbookを特定するため、既存資料のRead-only照合のみ行ってください。

**目的：** 現行S5-BのCompile対象Workbookを一意に特定できるか判定する。

**対象資料：**

- S4完了時点のProject Overview／Current Handoff／S4 Closure関連記録
- P2-05 Production Implementation Record
- 既存Workbook Build Provenance／Evidence Archive Manifest
- 必要な範囲の既存Production Source構成記録

**確認項目：**

1. 現行Target Buildとして採用されたWorkbook名・Artifact ID・所在・SHA-256
2. 2026-10-21に確認した外部開発フォルダーのMailGeneratorNew.xlsmとの対応
3. OneDrive管理下WorkbookとローカルCloneの識別状態
4. S4完了後にVBAProject／Workbookの変更が記録されているか
5. S5-Bの対象を一意に確定するために不足するEvidence

**禁止事項：**

PC全体の探索、新規コマンド／スクリプト実行、Workbook Open、Excel/VBE起動、Compile、ファイル変更、Git操作、Baseline更新。

既存資料だけで特定できなければ `TARGET_BUILD_IDENTIFICATION: INCOMPLETE` と報告し、不足している最小の確認事項だけを提示して停止してください。推測によるTarget Build確定は禁止します。
