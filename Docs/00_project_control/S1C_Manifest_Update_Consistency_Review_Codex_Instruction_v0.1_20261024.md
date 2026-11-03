# 定型メール作成ツール — P2 Evidence Archive S1-C
# 既存Manifest更新・整合性レビュー Codex限定実行指示 v0.1

- 指示日：2026-10-24（JST）
- 承認：ユーザーが **S1-C Manifest更新と整合性レビューのみ** を明示承認
- 実行上限：既存Manifestの必要最小限の編集および関連資料のRead-only照合
- **G2正式承認、Archive再実行、Git操作は未承認**

## 1. 作業開始時の確定情報

直近のCodex報告（独立したファイル実測ではなく、実行報告）に基づく：

```text
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
RemainingBlockers: []
Decision: S1_ARCHIVE_EXECUTION_PASS_PENDING_S1C_G2
```

加えて、PrimaryとBackupの**Private Indexは内容・サイズ・SHA-256が一致**。Restore Test用の5件のコピーと試験Runフォルダのみ既存計画に従い削除済み。原本、両Archive、復元先の上位2階層は保持されている。

既存の残留UNKNOWN（勝手にPASSに変更しない）：
- OneDriveRegistration: UNKNOWN
- ManagementShareEffectiveAccess: UNKNOWN（Primaryに関してS1限定受容済み）
- Stage2TotalExecutionCount: UNKNOWN（履歴差異を既存記録に保持）

## 2. 参照するSource of Truth

作業開始時に、Codexが実際のプロジェクト内の最新版と所在を確認すること：

1. **`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`**（今回更新する既存Manifest）
2. 既存のS1 Archive計画・S1-C/G2基準（あれば）
3. Primary／Backup双方の既存**非公開Private Index**と実行Evidence（Read-only）
4. 直近の`EXECUTE_ARCHIVE` PASS結果、および最新の`Project_Overview.md`／`Current_Handoff.md`（整合性確認用）
5. 適用中の文書管理・Baseline運用ルール

**Manifestの構成・項目・5件のファイル名・ハッシュ・実パスを推測しない。** 必須資料が見つからない、または矛盾がある場合は編集前に `STOP / REVIEW_REQUIRED` として報告する。

## 3. 許可する作業（S1-Cのみ）

### M1. 更新前Read-only照合

- Manifestの現在の版、Status、参照方式、既存5件の対応関係、S1-CとG2の境界を確認する。
- Private Indexと実行Evidenceから、5件の識別・サイズ・SHA-256、Primary／Backupの配置・一致、USBからの5件復元PASS、後処理の結果を照合する。
- 実行報告と非公開Evidenceに差異がある場合、**実行報告だけでPASS扱いせず停止**する。
- 既存のPrivate Locator／Public表示の分離ルールを確認する。

### M2. 既存Manifestへの必要最小限の追記

既存の項目・書式・参照方式を使用し、根拠がある情報だけを反映する。

- Archive実行日時・Run ID等：**既存Evidenceに実値がある場合のみ**記載。
- 既存Manifestの5件の対応付けと、Primary・Backupの保全状況（各5/5 SHA-256 PASS）。
- USB Backupからの復元試験（5/5 SHA-256 PASS）と、既存計画に準拠した後処理。
- Primary・Backup双方のPrivate Index整合（内容・サイズ・SHA-256一致）。
- 原本不変、意図しない上書きなし、ACL／BitLocker変更なし等、検証済み結果。
- 既存の受容済みリスクとUNKNOWNは、必要な場合だけ既存Decision／Risk参照へ接続。安全性の検証PASSとは表記しない。
- G2に提出するためのEvidence参照・未承認事項を、既存のManifest項目で明示。

**非公開情報の取扱い：** Public側Manifestには、生Evidence、個人実パス、個人SID／SDDL、BitLocker秘密値、Private Index全文等を転載しない。実ハッシュ／詳細Locatorの公開可否は既存方針に従う。許可が確認できないものは非公開の既存参照ID等で表す。Private Index本体は変更しない。

**Status：** 既存文書管理ルールに従い、S1-Cレビューの結果とG2正式承認を区別する。`Approved`、`G2Approved`、`S1 COMPLETE`を先取りしない。Versionやファイル名を機械的に変更しない。

### M3. Cross-document Consistency Review

更新後、Read-onlyで以下を照合する。

- Manifest ⇔ Primary／Backup Private Index ⇔ 実行Evidence：**5件の対象、件数、ハッシュ照合結果、復元元と復元結果、後処理**に意味上の矛盾がない。
- Manifest ⇔ 既存S1計画：範囲と完了条件が一致し、未定義の新しいGateを追加していない。
- Manifest ⇔ `Project_Overview.md`／`Current_Handoff.md`：S1-Bは実行PASS、S1-Cは今回レビュー、**G2は未承認、S1は未完了**という進捗に矛盾がない。
- ManifestのMarkdown構造、必要な相対リンク・アンカーに破損がない。
- 公開対象文書への機微情報混入がない。

必要な修正は今回の既存Manifest内に限定。別文書との食い違いを発見した場合は、それらのファイルを無断修正せず `REVIEW_REQUIRED` で停止する。既往Evidenceと変更履歴は保持する。

## 4. 明確な禁止事項

- **G2の正式承認／G2 APPROVEDの記録、S1 Closure宣言**
- 原本、Primary／Backup Archive、Private Index、Restore先への書込み・コピー・削除・再ハッシュのための追加ファイル生成
- Archive／復元試験の再実行、再コピー、Rollback、上書き
- ACL、Owner、共有設定、BitLockerの変更、管理者昇格
- 新規文書、新規スクリプト、追加の監査制度・バックアップ方式の作成
- `Project_Overview.md`／`Current_Handoff.md`／Approved技術文書／Baselineの編集（今回は参照のみ）
- Git add／commit／push／force push／履歴改変などのGit操作
- 既知UNKNOWNの独断によるPASS化、不要な追加調査への拡大

## 5. 停止条件

必須の既存Manifest、Private Index、5件の対応、実行Evidenceにアクセスできない、実測不一致、誤公開の恐れ、更新対象外文書を直す必要がある、Statusの承認意味が不明な場合は、**変更前または判明時点で停止**。未承認の作業に移らない。

## 6. 最終報告（簡潔）

```text
S1CUserAuthorization: APPROVED_BY_USER
ManifestFoundAndVersion: <verified value / UNKNOWN>
ManifestUpdate: PASS / STOP_REVIEW_REQUIRED / FAIL
PrivateIndexReadOnlyConsistency: PASS / REVIEW_REQUIRED
FiveEvidenceTraceability: PASS / REVIEW_REQUIRED
PrimaryBackupArchive5: PASS / REVIEW_REQUIRED
USBRestoreTest5: PASS / REVIEW_REQUIRED
RestorePostProcessing: PLAN_CONFORMANT / REVIEW_REQUIRED
PublicPrivateBoundary: PASS / REVIEW_REQUIRED
CrossDocumentConsistency: PASS / REVIEW_REQUIRED
MarkdownLinksAnchors: PASS / REVIEW_REQUIRED
ManifestStatus: <actual status, not assumed Approved>
RemainingFindings: [] / <facts>
ResidualUnknowns: <existing UNKNOWNs, unchanged>
ArchiveRerun: NONE
PrivateIndexMutation: NONE
GitOperation: NONE
G2Approved: FALSE
S1Closed: FALSE
Decision: S1C_REVIEW_PASS_PENDING_G2 / STOP_REVIEW_REQUIRED
```

変更した**既存Manifestのパス（非公開なら伏せて識別できる形）・変更節・差分要約**を併記する。`S1C_REVIEW_PASS_PENDING_G2`は、必要な照合がすべてPASSした場合のみ使用する。G2の承認可否をユーザーが判断できる材料を簡潔に示して**停止**する。

---

**完了点：S1-C Manifest更新・整合性レビューの結果報告。G2の正式承認とS1 Closureは別のユーザー判断。**
