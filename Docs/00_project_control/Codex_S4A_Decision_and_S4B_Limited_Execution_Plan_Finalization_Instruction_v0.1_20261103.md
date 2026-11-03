# Codex指示：S4-A Decision確定・S4-B限定実行計画の最終整理

## 1. 目的

S4-AのRead-only確認結果に対してユーザーが確定した2件の判断を反映し、S4-Bの実行承認を判断できる最小計画を整理する。

**本指示はRead-onlyの計画整理のみ。S4-B実行や文書更新は許可しない。**

## 2. ユーザー確定判断

### A. BL-MVP-004の追認

- Decision：CURRENT ACCEPTANCE RATIFIED
- Decision Authority：USER（本人による権限申告）
- Decision Date：2026-10-24 JST
- Scope：既存BL-MVP-004の固定Version組合せ
  - DOC-MVP-REQ：v0.1.9
  - DOC-MVP-DES：v0.1.10
  - DOC-TS-A：v0.4 CLOSED／PASS
  - DOC-MVP-TESTSPEC：v0.1.6

次を厳守する。

- 過去の承認主体・承認日時はUNKNOWN。
- 2026-10-01はGate実施日であり、承認日とは認定しない。
- 今回の追認は既存APPROVED記録の取消しや、新Baselineの作成を意味しない。
- 権限に関して独立検証したと記録しない。
- Repositoryへの正式受入・Registry同期は未実施。

### B. Design Patch統合範囲

- Design v0.1.9全文を基礎版とする。
- v0.1.10 Candidate Patchの§1～6に明示された操作のみを統合する方針を承認済み。
- §7.4、§15.4～6、§25.1の指定範囲などは既存S4-A照合結果を使用する。
- Patch §8「Responsibility Boundary」と§9「Resolution Result」は根拠資料として保持する。
- §8・§9自体を推測で新しい本文節として追加しない。
- 承認済みの意味論を省略・変更しない。

### C. 他の2文書

S4-Aの確認結果を維持する。

Test Specification v0.1.6：

- 基礎版v0.1.5へ補正後Patch-2を直接統合する計画。
- CR-TS-001～003を反映。
- 初期Candidateの二重適用は禁止。

Implementation Plan v0.4：

- 基礎版v0.3へ承認済みCandidate Patchを適用する計画。
- CR-IMPL-004-001のP6 Input補正を追加反映。
- Review §9のApproved判断を維持。
- PlanはBaseline固定4文書の構成要素ではなく、影響修正文書として扱う。

## 3. 今回の作業

次のRead-only確認と計画整理のみ行う。

1. 今回のユーザー判断とS4-A確認結果を照合する。
2. 3文書の統合元・適用箇所・適用順序に未解決の競合がないか、既存Evidenceを再利用して確認する。
3. S4-Bで新規作成または編集する必要があるファイルを正確に列挙する。
4. BL-MVP-004 Approval Recordへの今回の追認記録方法を提案する。ただし、まだ編集しない。
5. 統合済み全文の照合条件とRepository受入条件を整理する。
6. Registry、Overview、Handoff、READMEの更新順序と必要最小限の対象範囲を明示する。
7. S4-B実行に必要な追加ユーザーDecisionが残るか判定する。

追加の仕様変更や新しいBaseline審査を自動的に要求しないこと。

## 4. 実行境界

- 既存のBL-MVP-003に関する歴史的記録は維持する。
- Latest Version、Current Approved Baseline、過去Execution Baselineを区別する。
- Requirements v0.1.9およびDOC-TS-A v0.4の技術本文を変更対象にしない。
- S1～S3 Closureを再開しない。
- Provenance限定、残留UNKNOWN、OBS-P2-05-002 OPEN／NON-BLOCKINGを維持する。

## 5. 禁止事項

- 文書の作成・編集・リネーム・削除
- 3文書の全文統合実行
- BL-MVP-004 Approval Recordへの追認記録
- Registry／Overview／Handoff／READMEの編集
- Repositoryへの正式受入処理
- Git操作
- Baselineの変更・再構成
- 技術テスト・Compile・Archive再実行
- S4-B実行・S5着手

承認された判断は、この応答時点では会話上のDecisionであり、Repository記録完了とは扱わないこと。

## 6. 報告形式

```yaml
BL-MVP-004_CurrentRatification: APPROVED_BY_USER
RatificationDate: 2026-10-24 JST
HistoricalApprovalAuthority: UNKNOWN
HistoricalApprovalDate: UNKNOWN

DesignIntegrationScope: APPROVED_BY_USER
TestSpecificationIntegrationPlan: READY / REVIEW_REQUIRED
ImplementationPlanIntegrationPlan: READY / REVIEW_REQUIRED

S4BTargetFiles: [exact proposed targets]
S4BExecutionOrder: [minimal steps]
AdditionalDecisionsRequired: NONE / [specific items]

S4BReadiness:
  READY_FOR_USER_AUTHORIZATION / REVIEW_REQUIRED / BLOCKED

DocumentMutation: NONE
RepositoryAcceptancePerformed: FALSE
GitOperation: NONE
BaselineMutation: NONE
S4BExecuted: FALSE
S5Started: FALSE
```

結果を報告して停止すること。

`READY_FOR_USER_AUTHORIZATION`であっても、S4-Bの実行は別途ユーザー承認を必要とする。
