# Codex作業指示：S1-B Stage 2実行済み・Read-only事後検証（補足）

添付の `S1B_Stage2_PostExecution_Verification_Instruction_v0.1_20261023.md` に従ってください。

Stage 2のEveryone ACE除去は、ユーザーが管理者PowerShellで1回実行済みです。終了コード0、Root ACLは期待する3主体になっています。

**旧Stage 2実行指示書は無効です。変更コマンドを再実行しないでください。**

今回はRead-only事後検証だけを実施してください。

対象媒体、Root ACL、Owner、継承設定、直下項目、既存Snapshotの不変を確認し、指定書式で結果を報告して停止してください。

ACL変更、管理者昇格、Rollback、Archive作成、Evidenceコピー、Git操作は禁止します。

SVIの管理者検証とStage 2正式完了判定は別途実施します。
