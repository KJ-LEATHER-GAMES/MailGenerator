# Codex指示：S1 Restore Test Destination Approval・Archive Final Precheck

## 1. 目的

S1 Evidence Archiveの実行準備を完了させるため、以下のみ実施する。

1. 復元試験先の正式採用・限定リスク受容を既存文書に記録する。
2. 既存Precheck結果と今回の承認を統合し、Archive Precheckの最終判定を行う。

**Archive実行そのものは未承認。**

## 2. ユーザー承認済みDecision
```yaml
Decision: ACCEPT_RESTORE_DESTINATION
DecisionAuthority: USER
DecisionStatus: APPROVED

RestoreTestDestination:
%USERPROFILE%\PrivateEvidenceRestoreTest\MailGenerator\P2_I12_20261018_Run01\

Scope: S1 Evidence 5-file Restore Test ONLY
ResidualRisk: ACCEPTED_WITH_LIMITATIONS
ArchiveExecutionAuthorized: FALSE
```

受容範囲：

- 既存Read-only調査で報告された配置・親ACL条件を前提とする。
- 特権主体によるアクセス可能性を残留リスクとして受容する。
- 管理共有経由の実効アクセスはUNKNOWNのまま受容する。
- OneDrive登録・同期状態はUNKNOWNとして維持する。
- 安全性が技術的に検証済みであるとは記録しない。
- Primaryについての既存リスク受容判断を変更しない。
- 今回のS1復元試験以外へ受容範囲を拡大しない。

復元試験後のファイル保持・削除は既存計画に従う。未規定であり実行に必要な判断であれば、未解決事項として報告すること。

## 3. 既存文書への記録

対象：

- `Project_Overview.md`（報告上の現行版 v1.61）
- `Current_Handoff.md`（報告上の現行版 v1.34）

作業前に最新状態を確認し、既存の適切なDecision／Risk／Next Action欄へ最小限で追記する。

記録事項：

- Restore Test Destination：USER APPROVED
- Residual Risk：USER ACCEPTED / S1 ONLY
- OneDrive Registration：UNKNOWN
- Archive Execution：NOT APPROVED
- G2：PENDING

文書管理ルールに従いVersionを扱う。過去の判断履歴は保持する。

非公開の実パス・個人SID・生EvidenceをPublic文書へ記載しない。必要な詳細は既存の非公開管理情報を参照する。

## 4. Archive Final Precheck

直近のPrecheck結果を再利用し、すでにPASSした項目を理由なく再調査しない。

既存結果：
```yaml
EvidenceOriginals5: PASS
PrimaryDestination: PASS
PrimaryResidualRisk: ACCEPTED

BackupMediaIdentity: PASS
PhysicalIndependence: PASS
BitLockerCurrentState: PASS
BackupRootACL: PASS

RestoreTestDestination: REVIEW_REQUIRED
OneDriveRegistration: UNKNOWN
```

今回のユーザー承認を反映したうえで、以下のみ最終確認する。

### F1：Restore Destination

- 採用候補が既存計画の隔離条件を満たすこと。
- 原本、Primary Archive、USB Backupと重複しないこと。
- 既存の親ACL確認結果が今回の承認条件と整合すること。
- 未作成の子ディレクトリは、後続の明示承認後に作成する予定であることを区別する。

未作成であることだけを理由にFAILとしない。ただし、必要な作成条件が未成立ならREADYとしない。

### F2：OneDrive Registration

UNKNOWNを維持する。

既存のPrimaryリスク受容および今回のRestore Destination承認から、OneDriveの安全性PASSを推定しない。

既存S1 Gateに照らして今回のArchive実行を妨げるか判断し、根拠を簡潔に報告する。

追加調査を自動開始しない。

### F3：Archive Execution Readiness

既存のArchive計画・Manifestに照らし、以下を確認する。

- Evidence原本5件の識別とSHA-256照合が成立済み。
- Primary／Backup保存先が確定している。
- 復元試験先が承認済み。
- Archive作成・コピー・SHA照合・USBからの5件復元試験の実行条件が明確である。
- 未承認の新しい設計判断が必要ない。
- G2は未承認であり、Archive実行後の別Gateとして維持されている。

新しい要件や不要な検証工程は追加しない。

## 5. 判定ルール
```
ArchivePrecheckDecision:

READY
  既存Gateに必要な条件がすべて成立。

REVIEW_REQUIRED
  実行前にユーザー判断が必要。

BLOCKED
  必須条件の不成立が確認された。
```

UNKNOWNは根拠なくPASSにしない。一方、既存Gateで不要な追加調査を完了条件として新設しない。

## 6. 禁止事項

- Archive・Restore Testフォルダの作成
- Evidenceコピー・移動・削除
- 復元試験実行
- ACL／BitLocker／Owner変更
- 管理者昇格
- Manifest変更
- Git操作
- 新規文書・新規スクリプト作成
- Baseline変更
- S1-C・G2の自動実行

許可される書込みは既存2文書への最小記録のみ。

## 7. 報告形式
```yaml
RestoreDestinationDecision: APPROVED_BY_USER
RestoreResidualRisk: ACCEPTED_S1_ONLY

ProjectOverviewUpdate: PASS / FAIL
CurrentHandoffUpdate: PASS / FAIL
DocumentConsistency: PASS / REVIEW_REQUIRED

EvidenceOriginals5: PASS / ...
PrimaryDestination: PASS / ...
BackupMediaIdentity: PASS / ...
PhysicalIndependence: PASS / ...
BitLockerCurrentState: PASS / ...
BackupRootACL: PASS / ...
RestoreTestDestination: READY / REVIEW_REQUIRED
OneDriveRegistration: UNKNOWN / VERIFIED

ArchivePlanMapping: PASS / REVIEW_REQUIRED
ArchivePrecheckDecision: READY / REVIEW_REQUIRED / BLOCKED

RemainingBlockers:
- ...

ArchiveExecutionAuthorized: FALSE
G2Approved: FALSE
```

判定根拠と更新差分を簡潔に報告し、停止すること。

**READYであってもArchiveを実行しない。別途ユーザーによる`EXECUTE_ARCHIVE`の明示承認を必要とする。**
