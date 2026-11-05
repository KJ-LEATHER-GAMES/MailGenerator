# S5-B F1-READ-01 限定完了評価結果

既存Evidenceに基づき、今回定義されたF1-READ-01の限定調査範囲は`COMPLETE_WITH_LIMITATIONS`と評価できます。

これは調査結果と証拠上の限界の整理完了であり、C1の隔離成立・実効アクセス遮断・S5-Bの安全性確認完了ではありません。

## 完了根拠

| 確認項目 | 受入済みEvidence |
| --- | --- |
| ルートACL継承 | ENABLED：ユーザーGUI申告 |
| ACE一覧 | P01～P04がALL_ENTRIES：ユーザーGUI申告 |
| 共通3主体 | Users／Authenticated Users／EveryoneのACE不在：ルートACL上に限定した申告 |
| 直接共有 | 共有なし：ユーザーGUI申告 |
| 同名主体の照会 | 対象PCをGUI確認後、非昇格セッションで1回実行、SUCCESS_REPORTED |
| 直接メンバー | 同名LOCAL_GROUPの直接メンバー2件：M01、M02 |

未実行のスクリプトを修正・実行することは、代替手段で補完済みの今回の完了条件には追加しません。スクリプト自体の`StaticReview: REVIEW_REQUIRED`と実行未承認状態は維持します。

## 維持する限定

以下は完了判定によって解消した扱いにしません。

- ACL上のP01と、照会した同名LOCAL_GROUPとのSID一致
- M01・M02の主体区分
- 推移的グループ所属
- 個別Workbook・子要素のACL
- 将来の専用ユーザーの実効アクセス
- 非昇格セッションと標準ユーザーアカウントの同一視
- 既存のWorkbook物理同一性等のUNKNOWN

```yaml
EvaluationBasis: EXISTING_EVIDENCE_ONLY

P01DirectMembershipAssessment: COMPLETE_WITH_LIMITATIONS
F1Read01Decision: COMPLETE_WITH_LIMITATIONS
EvidenceLimitations: PRESERVED

AdditionalPCChecksRequiredWithinCompletedScope: NONE
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

NewPCOperation: NONE
AdditionalCommandExecuted: FALSE
ACLModified: FALSE
WindowsUserCreated: FALSE
ExcelOperated: FALSE
PreflightExecuted: FALSE
DocumentMutation: NONE
GitOperation: NONE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

本回答内の評価のみ更新しました。既存Closure・限定付きEvidence・Finding／Observation・Baseline履歴を維持し、F1-3～F1-5、AUTH-01～AUTH-06へ進まず停止します。
