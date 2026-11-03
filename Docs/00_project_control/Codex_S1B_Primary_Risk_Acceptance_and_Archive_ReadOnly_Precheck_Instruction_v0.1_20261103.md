# Codex指示：S1-B Primary残留リスク受容記録・S1 Archive Read-only Precheck

## 1. 目的

定型メール作成ツールのP2 Evidence Archive S1について、以下の2作業を実施する。

1. ユーザーが正式承認したPrimary管理共有の残留リスク受容を既存文書に記録する。
2. S1 Evidence Archive実行前のRead-only Precheckを行う。

**Archiveの実行は未承認。事前確認結果を報告して停止すること。**

## 2. 確定済みの判断

### Primary Residual Risk Decision

- Decision：`ACCEPT_RESIDUAL_RISK`
- Decision Authority：USER
- Status：APPROVED
- Scope：P2 Evidence Archive S1のPrimary保管先に限定

承認内容：

- 既存Evidenceでは追加是正を必要とするNTFS ACL問題は確認されていない。
- 管理共有経由の他主体の実効アクセスはUNKNOWN。
- 管理共有の通信暗号化もUNKNOWN。
- 特権主体を信頼する前提で、これらの未確認リスクを今回のS1に限り受容する。
- 本判断は管理共有の技術的安全性を検証済みとするものではない。
- Primary側の追加ACL是正・追加調査は今回実施しない。

本承認をArchive作成・Evidenceコピー・G2 Approvalへ拡大解釈しないこと。

### 既存の確定状態

- USB Root ACL Stage 2：`STAGE2_VERIFIED`
- Root／SVI／Snapshot事後検証：PASS
- Stage 2実行履歴の残留不確実性：既存記録どおり維持
- S1 Archive：未実施
- G2：未承認

Stage 2の再調査・再実行は行わない。

## 3. 既存文書の更新

対象：

- `Project_Overview.md`（報告上の現行版 v1.60）
- `Current_Handoff.md`（報告上の現行版 v1.33）

作業前に実際の最新状態、既存の追記位置、文書管理ルールを確認する。

### Project_Overview\.md

既存のRisk／Decision／Current Status等の適切な箇所へ、上記残留リスク受容判断を必要最小限で追記する。

### Current_Handoff.md

以下を簡潔に記録する。

- Primary残留リスク：USER ACCEPTED
- 受容範囲：今回のS1に限定
- 未確認事項：管理共有実効アクセス・通信暗号化
- 次Action：S1 Archive Read-only Precheck
- Archive Execution：NOT APPROVED
- G2：PENDING

両文書に重複した詳細説明を作らない。

既往の判断・証跡・履歴は保持し、矛盾する新記述を追加しない。

文書Version変更は既存ルールに従い、機械的なVersion UpやBaseline更新は行わない。

個人SID・SDDL・実パス・機密EvidenceをPublic管理文書へ記載しない。

## 4. S1 Archive Read-only Precheck

既存のArchive計画・Manifest・Private Evidence配置情報を参照し、以下を確認する。

### P1：Evidence原本

- 既存Manifest等から対象原本5件を一意に特定できるか。
- 5件すべてが存在し、読み取り可能か。
- 原本サイズ・SHA-256をRead-onlyで確認できるか。
- 重複、欠落、参照先の曖昧さがないか。

既存資料から対象5件を確定できなければ、推測で選定せず停止する。

### P2：Primary保存先

- Repository外の既定Primary保存先を特定できるか。
- 既存ディレクトリ構成・ACLが承認済み方針に整合するか。
- 既承認の残留リスク判断と矛盾する新しい問題がないか。

書き込みテスト、ACL変更、追加の管理共有調査は行わない。

### P3：Backup保存先

- USB `MG_EVIDENCE_BK`を既存識別情報と照合できるか。
- Primaryとは別物理ディスクか。
- Stage 2後のUSB Root ACLが維持されているか。
- 既存のBitLocker検証Evidenceが参照できるか。
- 必要な空き容量があるか。
- Backup側のArchive保存先・作成予定構成が既存計画から特定できるか。

BitLockerを通常権限で取得できない場合、推測でPASSとせず、既存ユーザー実測Evidenceと今回の確認可否を区別して報告する。

Backupディレクトリは作成しない。

### P4：Archive実行準備

- Primary／Backupの保存先対応が明確か。
- 5件のコピー・SHA照合に必要な情報が揃っているか。
- USB Backupから5件を復元するための独立した試験先が計画上特定できるか。
- 既存`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`との接続が明確か。

既存計画の確認に限定し、新しいArchive設計や手順の追加は行わない。

## 5. 禁止事項

- Archive作成・コピー・移動・削除
- Evidence原本の変更
- 復元試験の実行
- ACL・Owner・BitLocker設定変更
- 管理者昇格
- 新規スクリプト・新規文書の作成
- Manifest更新
- Git add／commit／push等のGit操作
- 技術仕様・Approved Baseline変更
- 自動Rollback・Retry
- 派生課題の調査拡大

許可される書き込みは、Section 3の既存2文書への必要最小限の追記のみとする。

## 6. 完了報告

以下を簡潔に報告する。
```yaml
PrimaryRiskDecision: ACCEPT_RESIDUAL_RISK
DecisionStatus: APPROVED_BY_USER

ProjectOverviewUpdate: PASS / FAIL
CurrentHandoffUpdate: PASS / FAIL
DocumentConsistency: PASS / REVIEW_REQUIRED

EvidenceOriginals5: PASS / BLOCKED / UNKNOWN
PrimaryDestination: PASS / BLOCKED / UNKNOWN
BackupDestination: PASS / BLOCKED / UNKNOWN
ArchivePlanMapping: PASS / BLOCKED / UNKNOWN

ArchivePrecheckDecision:
  READY / BLOCKED / REVIEW_REQUIRED

ArchiveExecutionAuthorized: FALSE
G2Approved: FALSE
```

文書更新差分を最小限に確認し、予期しない変更がないことを報告すること。

Privateな実パスや生Evidenceは報告に転載しない。

`READY`はArchive実行準備が整ったという技術的評価に限り、実行承認を意味しない。

**結果を報告して停止する。次工程への自動移行は禁止。**
