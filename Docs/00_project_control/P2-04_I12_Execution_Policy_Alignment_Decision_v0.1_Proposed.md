# P2-04 I12 Execution Policy Alignment Decision v0.1 — Proposed

## 1. 対象と判断理由

- 審査日：2026-10-19
- 旧Guide：`P2-04_I12_Contract_Regression_Guide_v0.1.md`（GitHub追加2026-10-14、commit `dd810b5ec5120ea7fd0873b9529e188ef29d66b2`）。**I12-A～Dで既存Suiteを直接再実行**。
- 後続実施計画：`P2-04 Manual Sync Integration Regression 実施計画 v0.1.md`（GitHub追加2026-10-16、commit `edf5c5175b103e250144341071d885a3a992c65f`）。**I12は既存Regression Record／Raw Logsと今回Bootstrapを統合**。I01/I02は歴史的Evidenceを適切に紐付け、新規実行と称さない。
- 現行9 Production ModulesはGitHub Versioned SourceとNormalized 9/9 Match。ユーザーは過去P2-01/02/03と今回P2-04に同じ9モジュールを使用と申告。P2-02/03/P2-04 Rawは既に提供済み。

**注意**：追加順が新しいだけでは、自動的に旧Guideを失効させたと断言できない。本Decisionは後続計画を今回Cycleの正式手順として採用する**明示的な受入判断の提案**である。

## 2. 推奨Decision

> 今回（2026-10-18実行分）のP2-04 RegressionにおけるI12は、後続実施計画v0.1を支配的な手順とし、P2-01 / P2-02 / P2-03 の既存Regression Evidenceおよび現行CycleのBootstrap Production Compatibilityの証拠を、同一Source・Contract適用性評価付きで再利用する。旧Guideの直接再実行要件は、このCycleについて後続計画で置換された**運用方式**とする。新たなBlocking FindingまたはSource差分が判明した場合には、影響対象の選択的再検証を再検討する。

### 期待結果を変更しない

- P2-01：Core 11/11、Baseline OFT Integration、MTS-SCAN-005 Recipient Exclusionの既存Record PASS/CLOSED。
- P2-02：6 Suite 111/111、うちBootstrap 33、Detection 43、Date Serial 9。33件のログ再掲を二重計上しない。
- P2-03：5 Suite 46/46。
- P2-02→P2-03：今回29/29。
- I03～I11：今回153/153。
- I01/I02：歴史的Implementation EvidenceとP2-04現Cycle Regressionの関係を明示し、新規の独立再実行とは称さない。
- Compile PASSとBlocking Finding 0、Fixture復元は可能な限り確認し、ログ不足は理由・範囲を記録する。

## 3. 判定状態

| 項目 | 判定 |
|---|---|
| Evidence reuse feasibility | **SUPPORTED BY EVIDENCE** |
| Production modification or blanket retest needed | **NOT INDICATED** |
| Guide-to-Plan precedence as formal policy | **DECISION PROPOSED / USER ACCEPTANCE PENDING** |
| I12 Final Quality Gate | **PENDING until acceptance and remaining boundary evidence** |

## 4. 承認時に残す操作記録

- 採用／不採用の明示、日付、採用Reason、対象Regression Cycle、影響Source Revisionを記載。
- 旧Guideは削除せずHistoryとして保持。原Logも変更しない。
- 採用後、I12 Reconciliation MatrixとP2-02/03のClosure Reviewに決定への参照を追加し、正式Gateの扱いを統一する。

## まとめ / Summary

**日本語：** 後続のRegression実施計画によるEvidence再利用を提案する。GuideとPlanの優先関係は今まで黙示だったため、ここで明示承認を得る。証拠の期待値は変更しない。

**English:** Recommend applying the later regression plan to I12. The precedence decision needs explicit acceptance; expected test behavior is unchanged.
