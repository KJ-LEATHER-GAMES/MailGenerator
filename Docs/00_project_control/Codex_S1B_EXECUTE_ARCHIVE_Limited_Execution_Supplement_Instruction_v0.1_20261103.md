# Codex作業指示：S1-B EXECUTE_ARCHIVE限定実行（補足）

添付の `S1B_EXECUTE_ARCHIVE_Limited_Execution_Instruction_v0.1_20261024.md` に従い、S1-Bの`EXECUTE_ARCHIVE`を実施してください。

ユーザーは指示書に定めた限定実行を明示承認済みです。

実行直前のRead-only照合がすべてPASSした場合のみ、既存計画に従ってEvidence原本5件のPrimary／Backup保全、SHA-256照合、USB Backupからの5件復元試験を実施してください。

各工程で不一致・不明点・既存ファイルとの衝突が発生した場合は、その時点で停止してください。自動再試行やRollbackは禁止します。

S1-C Manifest更新、G2承認、ACL変更、Git操作は実施しないでください。

実行結果を指定書式で報告し、停止してください。
