# S1-B EXECUTE_ARCHIVE限定実行結果

限定実行はPASSです。S1-C・G2には進んでいません。

```yaml
ExecuteArchiveAuthorization: APPROVED_BY_USER
ExecutionOutcome: PASS
PreExecutionCheck: PASS

SourceOriginals: 5/5_VERIFIED
PrimaryArchive: 5/5_SHA256_PASS
BackupArchive: 5/5_SHA256_PASS
USBRestoreTest: 5/5_SHA256_PASS
RestorePostProcessing: PLAN_CONFORMANT
ArchiveDirectoriesAndPrivateIndex: PASS
SourceOriginalsUnchanged: PASS

UnexpectedOverwrite: NONE
ACLOrBitLockerMutation: NONE
GitOperation: NONE
S1CManifestUpdated: FALSE
G2Approved: FALSE

ResidualUnknowns:
  - OneDriveRegistration: UNKNOWN
  - ManagementShareEffectiveAccess: UNKNOWN（限定受容済み）
  - Stage2TotalExecutionCount: UNKNOWN（既存記録を維持）

RemainingBlockers: []
Decision: S1_ARCHIVE_EXECUTION_PASS_PENDING_S1C_G2
```

Private IndexはPrimary・Backup双方で内容・サイズ・SHA-256一致を確認しました。

復元試験用コピー5件と試験Runフォルダだけを削除しました。両Archiveから再復元可能で、原本・Primary・Backupおよび復元先の上位2階層は保持しています。

ここで停止します。
