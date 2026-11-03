# 定型メール作成ツール — S1-C 再開用 Codex統合指示 v0.1

- 指示日：2026-10-24（JST）
- 対象：P2 Evidence Archive S1-C（G2提出前）
- 今回のユーザー追加承認：`Project_Overview.md`と`Current_Handoff.md`の**最新現在地に限る**訂正
- 継続有効な既存承認：S1-C既存Manifestの更新・整合性レビュー
- **未承認：G2正式承認、S1 Closure、Archive／Restoreの再実行、Git操作**

## 0. 起点・作業の境界

前回のS1-Cは、管理入口の現在地に「Archive Execution: NOT APPROVED／EXECUTE_ARCHIVE承認待ち」が残り、S1-Bの実行PASSと矛盾していたため、**Manifestを編集せず `STOP_REVIEW_REQUIRED`** で停止した。これは過去の承認前記録の誤りではなく、**最新状態としての掲載が古い**ことによる。

以下は既存実行報告による確定状態として扱う。ファイル実物との独立照合が必要なS1-C事項は後段で検証する。

```text
S1B.ExecuteArchiveAuthorization: APPROVED_BY_USER
S1B.ExecutionOutcome: PASS
S1B.SourceOriginals: 5/5_VERIFIED / UNCHANGED
S1B.PrimaryArchive: 5/5_SHA256_PASS
S1B.BackupArchive: 5/5_SHA256_PASS
S1B.USBRestoreTest: 5/5_SHA256_PASS
S1B.RestorePostProcessing: PLAN_CONFORMANT
S1B.PrivateIndex: PRIMARY_AND_BACKUP_CONTENT_SIZE_SHA256_MATCH (reported)
S1C.Manifest: v0.1 Draft / NOT UPDATED
G2Approved: FALSE
S1Closed: FALSE
```

以下のUNKNOWNを維持し、技術的PASSに読み替えない。

```text
OneDriveRegistration: UNKNOWN
ManagementShareEffectiveAccess: UNKNOWN (S1限定の残留リスク受容済み)
Stage2TotalExecutionCount: UNKNOWN (既存の後続訂正・実行履歴を維持)
```

**本指示は、以前のS1-C指示書 `S1C_Manifest_Update_Consistency_Review_Codex_Instruction_v0.1_20261024.md` に対し、Overview／Handoffの最新現在地訂正を先行して例外的に許可するもの。その他のS1-C境界と停止条件は引き継ぐ。**

## 1. フェーズA：管理入口の現在地のみ最小訂正

### A0. 編集前Read-only確認

1. `Project_Overview.md`（ユーザー報告時点 v1.62）、`Current_Handoff.md`（同 v1.35）の**実際の最新版・所在・Status表示・履歴欄**を確認する。
2. `EXECUTE_ARCHIVE`が未承認と**最新現在地で表示されている箇所**を特定し、履歴・過去の検討・承認前時点の記述と区別する。
3. 現行の文書管理・Baselineルールを確認する。技術文書ではなく、Project Control／Execution Handoffの進捗訂正として扱う。
4. 旧Versionと実体に差異がある、どこが最新現在地か特定できない、または同等の更新が既に行われている場合は、重複更新せず状況を報告する。

### A1. 許可する最小編集

対象は**既存2文書の最新現在地**に限る。文書の既存構成・項目名・Status語彙に合わせ、次を反映する。

- `EXECUTE_ARCHIVE`: **ユーザー承認済み・実行結果PASS**。`NOT APPROVED`／「承認待ち」の表示を、現行ステータスから解消する。
- Primary・Backup原本保全、およびUSB Backupからの5件の復元試験：各`5/5_SHA256_PASS`（報告された実行事実として記載）。
- Private Index整合・後処理・原本不変：必要最小限の現在地要約のみ。詳細は既存非公開Evidenceへの参照にとどめる。
- **現在の作業**：S1-C Manifest更新・Private Index Read-only照合・整合性レビューを再開中。
- **G2**：`PENDING / NOT APPROVED`。**S1**：`NOT CLOSED`。
- 次アクション：S1-Cレビュー結果を報告して停止し、ユーザーのG2判断を待つ。
- 上記3件の残留UNKNOWNと限定リスク受容の範囲を変えない。

**過去の「未承認」記述は、その時点の正しい履歴として保持**する。歴史を改変・削除しない。最新現在地と歴史的記録を混同させないよう、必要なら最新欄に短い日付／状態補足を付ける。

文書自身のVersion・変更履歴の扱いは適用中のルールに従う。Version更新が必要であっても他文書へ連鎖させず、Baseline承認やApproved技術文書への変更を行わない。**許可した2文書以外はAフェーズで編集しない。**

### A2. 訂正後確認（S1-C再開の前提）

- Overview／Handoffの**最新現在地同士**がS1-Bの承認済み・実行PASSと整合する。
- 両文書ともS1-C未完了、G2未承認、S1未Closureを維持する。
- 過去の判断・履歴・UNKNOWNを保持し、承認範囲外の変更がない。
- 変更箇所のMarkdownリンク・アンカーが破損していない。必要に応じ既存の相対リンク検査をRead-onlyで実施する。
- 予期しない差分、機微情報混入、最新状態の矛盾があれば **`STOP_REVIEW_REQUIRED`** としてManifestには進まない。

## 2. フェーズB：承認済みS1-C Manifest更新・整合性レビュー再開

**A2がPASSした場合に限り**、前回承認済みS1-C指示の未実施部分を再開する。対象Manifestは前回確認された既存正本：

`Docs/03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`

### B1. 更新前Read-only照合

以下を**既存の資料と実行Evidence**で照合する（Archive再実行は不要）。

1. Manifest v0.1 Draftの現在状態、項目・5件の対応付け、Private Locator／Public表示分離方針。
2. Primary／Backup双方の**Private Index**の実在・読取り・内容／サイズ／SHA-256の一致。
3. Evidence原本5件の識別・サイズ・ハッシュ・Primary／Backupの各5/5保全・USB Restore 5/5・後処理について、既存の実行EvidenceとPrivate Indexの間に実質的不一致がないこと。
4. 残留UNKNOWN、受容範囲、G2判断条件が既存計画に反していないこと。

実行報告だけで未照合項目をPASS化しない。Private Index・実行Evidenceが読めない、対応関係が不明、実測不一致がある場合は**Manifest更新前に停止**する。

### B2. 既存Manifestだけを最小更新

B1がPASSした場合に限り、**既存Manifestの既存構成／フィールド**に実際に確認できた事項のみ反映する。

- 5件のPrimary／Backup保全（各5/5 SHA-256一致）、USB復元試験5/5一致、計画準拠の後処理。
- Primary／BackupのPrivate Index整合、原本不変、意図しない上書き・ACL／BitLocker変更なし（既存Evidenceが裏付ける範囲）。
- 既存の識別子・Run ID・実行日時・Locatorは根拠があるものだけ使う。推測・生成しない。
- 残留UNKNOWN／リスク受容の参照を必要な範囲で維持し、未確認事項を安全性PASSと表記しない。
- Statusは**G2正式承認前**であることを明示。既存ルールが許す範囲で扱い、`Approved`・`G2Approved`・`S1 COMPLETE`としない。

**Private Indexそのものは編集禁止。** Public側Manifestに生ログ、個人実パス、SID／SDDL、秘密値、Private Index全文を記載しない。ハッシュやLocatorの公開可否が不明なら既存の非公開参照方法を使い、判断が必要なら停止する。

### B3. Cross-document Consistency Review

- Manifest ⇔ Primary／Backup Private Index ⇔ 実行Evidence：対象5件、件数、SHA照合、復元元・復元結果・後処理が一致。
- Manifest ⇔ S1計画：既存の完了条件と範囲が一致（新しいGateを追加しない）。
- Manifest ⇔ Overview／Handoff：**S1-B PASS、S1-Cレビュー済み（実際の結果に応じて記載）、G2未承認、S1未Closure** が整合。
- Manifest・2文書の変更箇所のMarkdown構造、必要な相対リンク／アンカーに不備がない。
- Public／Private情報境界が守られている。

新たな不整合があっても、追加で他文書を無断修正しない。今回許可された2文書の**最新現在地のみ**で吸収できない変更は `REVIEW_REQUIRED` として報告し停止する。

## 3. 全工程での禁止事項

- **G2正式承認、S1 Closure／P2 Closureの宣言、Baseline更新**
- **Archive作成・再コピー・復元試験の再実行・自動Rollback・再試行**
- 原本、Primary／Backup Archive、Private Index、Restore先の変更・上書き・削除
- ACL、Owner、共有設定、BitLockerの変更、管理者昇格
- 新規文書・新規スクリプト作成、別のバックアップ方式の追加、調査の拡大
- Approved技術文書、要件・設計・テスト仕様の編集
- Git add／commit／push／force push／履歴改変など**一切のGit操作**
- 既往履歴の削除、根拠のないPASS化、未承認範囲の自動実行

許可する書込みは、フェーズAの**Overview／Handoffの最新現在地の最小訂正**、およびフェーズBの**既存Manifestの必要最小限の更新**のみ。検証と差分確認はRead-onlyで行う。

## 4. 停止条件と最終報告

- A2不一致・許可外の変更が必要 ⇒ **Manifest更新に進まずSTOP**。
- B1の必須根拠に不備・Private Index未照合 ⇒ **Manifest更新に進まずSTOP**。
- B2・B3の根拠不足、文書間不整合、情報境界リスク ⇒ **新規作業・無断修正をせずSTOP**。
- すべてPASSでも、**G2を承認せず停止**。

```text
CurrentStateCorrectionAuthorization: APPROVED_BY_USER
S1CUserAuthorization: APPROVED_BY_USER
OverviewUpdate: PASS / STOP_REVIEW_REQUIRED / FAIL
HandoffUpdate: PASS / STOP_REVIEW_REQUIRED / FAIL
CurrentStateConsistency: PASS / REVIEW_REQUIRED
OverviewVersion: <actual>
HandoffVersion: <actual>
ManifestFoundAndVersion: <actual / UNKNOWN>
ManifestUpdate: PASS / STOP_REVIEW_REQUIRED / FAIL
PrivateIndexReadOnlyConsistency: PASS / REVIEW_REQUIRED
FiveEvidenceTraceability: PASS / REVIEW_REQUIRED
PrimaryBackupArchive5: PASS / REVIEW_REQUIRED
USBRestoreTest5: PASS / REVIEW_REQUIRED
RestorePostProcessing: PLAN_CONFORMANT / REVIEW_REQUIRED
PublicPrivateBoundary: PASS / REVIEW_REQUIRED
CrossDocumentConsistency: PASS / REVIEW_REQUIRED
MarkdownLinksAnchors: PASS / REVIEW_REQUIRED
ManifestStatus: <actual; not Approved without G2>
RemainingFindings: [] / <factual findings>
ResidualUnknowns:
  OneDriveRegistration: UNKNOWN
  ManagementShareEffectiveAccess: UNKNOWN (accepted only in existing S1 scope)
  Stage2TotalExecutionCount: UNKNOWN
ArchiveRerun: NONE
PrivateIndexMutation: NONE
GitOperation: NONE
G2Approved: FALSE
S1Closed: FALSE
Decision: S1C_REVIEW_PASS_PENDING_G2 / STOP_REVIEW_REQUIRED
```

併せて報告するもの：
- 3文書それぞれの実際のVersion・Status、変更対象節、**差分の要約**（非公開実パス／生Evidenceは報告へ転載しない）。
- PASS判定に使った既存Evidenceの識別子（非公開内容は開示不要）。
- もし`STOP_REVIEW_REQUIRED`なら、**解除に必要な最小の追加判断・修正**のみ。

**完了点：S1-Cレビュー結果をユーザーに提出し停止。G2承認・S1 Closureは次の独立判断。**
