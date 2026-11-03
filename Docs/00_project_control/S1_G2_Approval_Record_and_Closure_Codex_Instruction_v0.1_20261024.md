# 定型メール作成ツール — S1 G2正式承認記録・S1 Closure Codex指示 v0.1

- 指示日：2026-10-24（JST）
- 対象：P2 Evidence Archive S1／G2
- **ユーザー判断：G2正式承認（APPROVED_BY_USER）**
- 本指示の実行範囲：既存文書へのG2承認記録、S1 Closureの整合性確認・現在地更新のみ
- **対象外：Git操作、Archive／Restore再実行、ACL・BitLocker変更、P2全体Closure、Baseline承認、S2以降の着手**

## 0. 前提（ユーザー提供のS1-C結果）

```text
Decision: S1C_REVIEW_PASS_PENDING_G2
Project_Overview.md: v1.63 / PASS
Current_Handoff.md: v1.36 / PASS
P2-04_I12_Evidence_Archive_Manifest: 本文v0.2 Draft / S1-C REVIEWED / G2 PENDING
Evidence originals: 5件
PrimaryArchive: 5/5_SHA256_PASS
BackupArchive: 5/5_SHA256_PASS
USBRestoreTest: 5/5_SHA256_PASS
PrivateIndexReadOnlyConsistency: PASS
FiveEvidenceTraceability: PASS
PublicPrivateBoundary: PASS
CrossDocumentConsistency: PASS
MarkdownLinksAnchors: PASS（前回報告：相対リンク239件、アンカー参照9件）
RemainingFindings: []
ArchiveRerun: NONE
PrivateIndexMutation: NONE
GitOperation: NONE
```

既存の照合根拠識別子：`ARC-MG-P2-I12-20261018`、`E-P202-RAW`、`E-P203-RAW`、`E-P204-RAW`、`E-P204-SOURCE`、`E-P204-WB`。識別子は既存資料との照合にのみ使用し、内容・日時・ハッシュを推測して補完しない。

ユーザーは**今回、G2を明示的に正式承認**した。これを単なる「承認待ち」と扱わない。ただし、S1の記録完了・Closureは以下の確認と管理文書更新が成立してから判定する。

## 1. 実行前の限定Read-only確認

1. 次の3文書の現行実体・Version・Status・既存のG2欄／現在地欄／変更履歴欄を確認する。
   - `Project_Overview.md`（報告時v1.63）
   - `Current_Handoff.md`（報告時v1.36）
   - `Docs/03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`（**ファイル名はv0.1_Draftのまま、本文はv0.2 Draft**）
2. 直近のS1-CレビューPASS、S1-B実行PASS、G2 Gateの既存Done When／承認記録方式を照合する。確定済みPASSを理由なく再テストしない。
3. 既存結果と矛盾する新たな事実、必須G2条件の欠落、対象外文書編集の必要、または承認範囲外の判断が判明したら**更新前にSTOP_REVIEW_REQUIRED**。
4. 既存ルールが記録に必要とする識別子・承認日時等は、出典が確かな値のみ使用する。ユーザー承認の年月日は2026-10-24（JST）。正確な時刻、架空のチケットID、電子署名等は作らない。

## 2. 許可する文書変更（3文書のみ）

### A. 既存Manifest

- 本文v0.2 DraftのS1-C PASS、Evidence 5件のPrimary／Backup保全とUSB復元試験、Private Index照合、Public／Private分離の既存記録を維持する。
- **G2正式承認：APPROVED_BY_USER**、承認範囲：P2 Evidence Archive S1、ユーザー判断日：2026-10-24（JST）を既存項目へ記録する。
- 適用ルールに従い、Manifest本文の承認状態をG2 Approvedとして扱う（例：`v0.2 / Approved`）。Version・Statusの具体的な表記は実物の既存ルールを優先する。**S1-CレビューPASSをG2の代用にしない**。
- 過去のDraft／G2 PENDING状態は履歴として保持する。既存Traceability・証跡識別子を変更しない。
- **ファイル名の `v0.1_Draft` と本文v0.2の不一致は既知**。この限定作業ではリネーム・リンク一括変更をしない。本文の正式Version／Statusと、ファイル名を維持した事情が参照者にわかるよう、既存管理欄に必要な最小注記を行う（既存ルール上、リネームが必須ならSTOPして報告）。

### B. Project_Overview.md

- 最新現在地のG2を`APPROVED_BY_USER`、S1 Archiveを`CLOSED`（3文書の整合性確認成立後）として更新する。
- S1-B実行PASS・S1-CレビューPASS・G2承認済みを簡潔に参照する。結果の詳細を重複転記しない。
- 次アクションを**S2：P2-02／P2-03 Regression Recordsの正式Closure**とする。P2 Phase Exit、`CP-P2`、`BL-MVP-004`等を完了・承認扱いにしない。
- Document Registry等が既存Overview内にある場合、必要なManifestの最新版・Status記載だけ整合させる。独立したRegistry文書は編集しない。

### C. Current_Handoff.md

- G2ユーザー正式承認、S1 CLOSED、次工程S2への引継ぎ状態を簡潔に更新する。
- S1を再開する必要はないこと、S2〜S6は未完了であることを明記する。
- 既往本文・判断履歴・以前の承認前の「PENDING」記録は保存し、**最新現在地のみ**に反映する。

3文書のVersion／変更履歴処理は現行の文書管理ルールに従い、不要なVersion Up連鎖やBaseline変更を行わない。

## 3. 残留不確実性と守秘境界

以下の状態は変更しない。G2承認を根拠に技術的PASSへ格上げしない。

```text
OneDriveRegistration: UNKNOWN
ManagementShareEffectiveAccess: UNKNOWN（既存S1限定の残留リスク受容済み）
Stage2TotalExecutionCount: UNKNOWN（既存の後続訂正・履歴を保持）
```

復元試験先の限定リスク受容もS1以外へ拡大しない。Public文書に実ユーザーパス、個人SID、SDDL、生ログ、Private Index全文、回復キーなどを転記しない。

## 4. 最終整合性確認と停止条件

3文書の変更後、以下をRead-onlyで確認する。

- ManifestのG2承認済みStatusと、Overview／Handoffの**最新現在地**が一致する。
- S1-B実行PASS、S1-CレビューPASS、G2ユーザー承認、S1 CLOSEDが同じ時系列で矛盾しない。
- 以前のPENDING／Draftは履歴として残り、最新現在地の表示と混同されない。
- 5件のTraceability、Private Index、Archive実体に**変更がない**（既存検証結果・差分確認を利用し、不要な再ハッシュ・再実行をしない）。
- 変更箇所の相対リンク／アンカーとPublic／Private境界に不備がない。
- 想定外の文書変更がなく、G2以外の承認・Baseline／P2 Closureが混入していない。

不一致・承認ルール違反・リネーム必須などが見つかれば、推測で解消せず`STOP_REVIEW_REQUIRED`として報告。**G2のユーザー承認事実は保持するが、S1 CLOSEDは記録整合が成立するまで確定しない。** ロールバックや勝手な追加調査は行わない。

## 5. 禁止事項

- Archive・Restore Testの作成／コピー／再実行／自動Retry／Rollback
- Evidence原本・Primary／Backup Archive・Private Indexの編集／削除
- ACL、Owner、BitLocker、共有・OneDrive設定の変更
- Git add／commit／push／履歴改変を含む**すべてのGit操作**
- Manifestのリネーム、既存文書以外の新規作成・編集
- MVP Requirements、Design、Test Specification、Approved Baselineの変更
- G2を超えたP2全体のCompletion／`CP-P2`宣言、S2以降への自動着手
- 残留UNKNOWNの無断解消・承認範囲拡張

## 6. 完了報告（3文書更新後に停止）

```text
G2UserDecision: APPROVED_BY_USER
G2Documentation: PASS / STOP_REVIEW_REQUIRED
S1BExecution: PASS (existing)
S1CReview: PASS (existing)
ManifestVersionStatus: <actual>
ProjectOverviewVersionStatus: <actual>
CurrentHandoffVersionStatus: <actual>
CrossDocumentConsistency: PASS / REVIEW_REQUIRED
MarkdownLinksAnchors: PASS / REVIEW_REQUIRED
PublicPrivateBoundary: PASS / REVIEW_REQUIRED
ResidualUnknowns:
  OneDriveRegistration: UNKNOWN
  ManagementShareEffectiveAccess: UNKNOWN (accepted in S1 scope)
  Stage2TotalExecutionCount: UNKNOWN
ArchiveRerun: NONE
PrivateIndexMutation: NONE
GitOperation: NONE
S1Closure: CLOSED / PENDING_DOCUMENTATION
G2RecordOutcome: G2_RECORDED_S1_CLOSED / STOP_REVIEW_REQUIRED
NextAction: S2_P2-02_P2-03_FORMAL_CLOSURE (only when S1 closed)
```

各文書の変更節・差分概要、根拠となる既存Evidence識別子、未解決事項があれば必要最小限で報告する。**すべてPASSでもS2へ自動着手せず、結果を報告して停止すること。**
