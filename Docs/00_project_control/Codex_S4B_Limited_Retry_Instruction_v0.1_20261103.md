# S4-B 限定再試行指示（1回のみ）

## 1. 承認

ユーザーは、S4-Bの編集処理について**1回限りの限定再試行**を追加承認しました。

前回の`STOP_REVIEW_REQUIRED`は、Design §25.1末尾に存在しない`---`区切りを仮定した候補生成処理の文脈照合失敗によるものです。

承認済みPatchの競合ではありません。

前回は既存16ファイルのSHA-256が不変、新規3件は未作成、部分変更はありませんでした。

## 2. 変更対象

前回承認済みの以下8ファイルのみ。

**新規3件**

1. `Docs/01_specifications/MVP Design v0.1.10 日本語版.md`
2. `Docs/01_specifications/MVP Test Specification v0.1.6 日本語版.md`
3. `Docs/02_implementation/Implementation Plan v0.4 日本語版.md`

**既存更新5件**

4. `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`
5. `Docs/00_project_control/Document_Registry.md`
6. `Docs/00_project_control/Project_Overview.md`
7. `Docs/05_handoff/Current_Handoff.md`
8. `README.md`

## 3. 実行前確認

- 既存ファイルの現行版・SHA-256を前回停止時のEvidenceと照合する。
- 新規3件の保存先が存在しないことを確認する。
- 承認済みPatch・Review・現在のユーザーDecisionに変更がないことを確認する。
- 不一致、対象衝突、想定外の変更があれば編集前に停止する。

## 4. Design §25.1の修正方法

今回修正するのは**候補生成処理の文脈特定方法のみ**です。

1. Design v0.1.9全文を読み直す。
2. 実際の`§25.1`と、その次の`§25.2`の見出しを特定する。
3. 両見出しが各1件で、正しい順序にあることを確認する。
4. その範囲内で、承認済みPatchの変更前断片が完全一致で1件だけ存在することを確認する。
5. 一致した断片のみ、承認済みPatchの変更後内容へ置換する。
6. §25.2以降、および承認範囲外の本文が不変であることを検証する。

**節末の`---`を仮定しない。**

変更前断片が0件または複数件の場合、推測して適用せず停止する。

Design全体の統合範囲は従来どおりPatch §1～6の明示操作に限定する。Patch §8・§9は根拠資料として保持し、新規本文節として挿入しない。

## 5. 保存前検証

ファイルを書き込む前に、統合済み全文候補を検証する。

- Design：明示されたSemantic変更だけを反映し、承認範囲外の本文を保持。
- Test Specification：v0.1.5＋補正後Patch-2のみ。CR-TS-001～003を反映し、既存69 Test IDを保持。
- Implementation Plan：v0.3＋承認済みPatch＋CR-IMPL-004-001のP6 Input補正を反映。
- 3文書とも、Version・Status・履歴が承認済み判断と整合すること。
- 予定外の差分、重複適用、意味論の欠落がないこと。

**3文書の保存前検証がすべてPASSするまで、8ファイルのいずれにも書き込まない。**

保存前検証に失敗した場合は、その時点で停止する。

## 6. 実行順序

保存前検証がすべてPASSした場合のみ、前回承認済みの順序で実行する。

1. BL-MVP-004 Approval Recordへ2026-10-24 JSTの追認を追加記録。
2. Design v0.1.10全文正本を作成。
3. Test Specification v0.1.6全文正本を作成。
4. Implementation Plan v0.4全文正本を作成。
5. 保存後に全文・承認済み差分を読み戻して照合。
6. Document Registryを同期。
7. Project Overview → Current Handoff → READMEを最小更新。
8. Cross-document Consistency、Traceability、リンク、Public／Private境界、変更ファイルを検証。

各工程のPASSを確認してから次へ進むこと。

## 7. 維持する制約

- BL-MVP-004の固定4文書構成は変更しない。
- 過去の承認主体・承認日時はUNKNOWN。
- 2026-10-01はGate実施日。
- 2026-10-24 JSTの追認は独立したUSER Decision。
- BL-MVP-003の歴史的記録を保持。
- 既存S1～S3 ClosureとProvenance限定を保持。
- 残留UNKNOWNおよび`OBS-P2-05-002：OPEN／NON-BLOCKING`を維持。

## 8. 禁止事項

- 本承認を超える再試行
- 失敗時の自動Retry・Rollback
- 対象外ファイルの編集・作成・削除
- Git操作
- Baseline再構成・新Baseline作成
- 技術テスト・Compile・Archive再実行
- S5以降への着手

失敗時は直ちに停止し、既に変更したファイルと未完了工程を正確に報告する。無断で復旧しない。

## 9. 報告

以下を報告する。

```yaml
S4BRetryAuthorization: APPROVED_BY_USER
RetryLimit: ONE

Design25_1ContextResolution: PASS / FAIL
PreSaveCandidateValidation: PASS / FAIL

ApprovalRecordUpdate: PASS / NOT_PERFORMED / FAIL
DesignFullText: PASS / NOT_PERFORMED / FAIL
TestSpecFullText: PASS / NOT_PERFORMED / FAIL
ImplementationPlanFullText: PASS / NOT_PERFORMED / FAIL

RegistrySync: PASS / NOT_PERFORMED / FAIL
OverviewUpdate: PASS / NOT_PERFORMED / FAIL
HandoffUpdate: PASS / NOT_PERFORMED / FAIL
READMELinkUpdate: PASS / NOT_PERFORMED / FAIL

ApprovedSemanticDiffMatch: PASS / FAIL / NOT_CHECKED
CrossDocumentConsistency: PASS / FAIL / NOT_CHECKED
PublicPrivateBoundary: PASS / FAIL / NOT_CHECKED
MarkdownLinksAnchors: PASS / FAIL / NOT_CHECKED

CreatedFiles: [...]
ModifiedFiles: [...]
UnexpectedChanges: NONE / [...]
PartialMutation: TRUE / FALSE

GitOperation: NONE
BaselineReconfiguration: NONE
TechnicalTestRerun: NONE
S5Started: FALSE

S4BRepositoryAcceptance: PASS / STOP_REVIEW_REQUIRED
```

**全条件PASSの場合のみRepository AcceptanceをPASSとし、それ以外は実態どおり報告して停止すること。**

追加再試行の自動実行は禁止する。
