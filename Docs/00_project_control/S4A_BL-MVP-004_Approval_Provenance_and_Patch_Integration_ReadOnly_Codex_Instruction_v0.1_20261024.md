# 定型メール作成ツール — S4-A 限定Read-only補完確認 Codex指示 v0.1

- 指示日：2026-10-24（JST）
- 工程：P2 Scan / Sync — S4-A（BL-MVP-004承認根拠・3文書のApproved Patch統合条件の確認）
- 権限：**ユーザーはS4-AのRead-only確認のみ承認**。Repository内外の新規ファイル作成・既存ファイル編集・統合正本生成・S4-B実行は未承認。
- 目的：S4の`REVIEW_REQUIRED`の原因だけを明確化し、次のS4-Bを判断できるように、**根拠・適用順序・競合有無・最小更新範囲**を報告して停止する。

## 0. 変更しない確定状態

1. S1：`G2_RECORDED_S1_CLOSED`、S2：`S2_FORMAL_CLOSURE_RECORDED`、S3：`S3_FORMAL_CLOSURE_RECORDED`。再開・再Closureしない。`Project_Overview.md`本文v1.66、`Current_Handoff.md`本文v1.39（いずれもS3完了）が直近報告値。実際の版が異なれば報告するが編集しない。
2. BL-MVP-004の既存Approval Record本文v0.1には`Gate PASS / APPROVED`、Gate実施日`2026-10-01`、`CR-TS-001～003 CLOSED`、BL-MVP-003を`SUPERSEDED`とする記述があるとのS4 Precheck結果を**既存報告事実**として引き継ぐ。今回、実在する原文・根拠をRead-only照合する。APPROVEDを勝手に取り消したり、再承認したりしない。
3. BL-MVP-004の承認対象固定組合せ（直近Precheck確認値）：`DOC-MVP-REQ v0.1.9`、`DOC-MVP-DES v0.1.10`、`DOC-TS-A v0.4 CLOSED/PASS`、`DOC-MVP-TESTSPEC v0.1.6`。**これらは承認済み組合せであり、統合済み全文のRepository受入済みを意味しない。**
4. 現状：Requirements全文は一致、Design v0.1.10／Test Specification v0.1.6／Implementation Plan v0.4の全文正本は未確認。Registry v1.43とRepository側のCurrent Baselineは旧BL-MVP-003。S4-Bは未着手。
5. 3つの残留UNKNOWN（`OneDriveRegistration`、`ManagementShareEffectiveAccess`〔S1限定受容済み〕、`Stage2TotalExecutionCount`）および`OBS-P2-05-002：OPEN / NON-BLOCKING`、既存Source／Workbook／CompileのProvenance限定を維持。P2-05・P2 Phase・CP-P2は未完了。
6. READMEの旧Plan参照およびSpike Aの個人パスの公開時問題は既存S4 Precheckで識別済み。**今回S4-Aの追加調査対象にしない。**

## 1. 既存BL-MVP-004の承認主体・日付根拠を確認（Read-only）

対象候補：
- `Docs/00_project_control/baselines/BL-MVP-004_Approval_Record_v0.1.md`
- 同Recordから実際に参照されるGate記録／Quality Gate Review／Consistency Review／Decision Log／履歴（Repository内の既存文書に限る）

確認する事項：

1. `APPROVED`という**状態**、承認した**主体／権限**、承認の**意思表示と日時**、`2026-10-01`という**Gate実施日**を個別に抽出する。出典文書・節・原文上の表現を簡潔に示す。日時はタイムゾーンが不明なら補完しない。
2. Approval Record内の承認対象（Document ID＋固定Version）、`CR-TS-001～003` Closure、再Review PASS、BL-MVP-003 `SUPERSEDED`が既存参照と矛盾しないことを限定照合する。
3. Gate実施日を自動的に「ユーザー承認日」と認定しない。ファイル更新日時・チャット上の暗黙了解・文書名から承認主体／日付を推測しない。
4. 証拠が不足する場合、`APPROVAL_EVIDENCE_GAP`として「確認できた事実」「欠ける根拠」「ユーザーに確認すべき最小の事実」を示す。**承認記録の編集、再承認、追認の代行を実行しない。**
5. 個人情報・機密実パス・生ログを報告へ転記しない。既存Approval Recordの内容に関する根拠参照は相対パス・文書名・節・Document IDを優先する。

## 2. 承認済みPatchの統合条件を3文書ごとに特定（Read-only）

実際のRepositoryで対象ファイルの名前・本文Version・Status・Approval/Reviewとの対応を確認し、**未統合全文正本を作らず**、将来の統合先・順序・差分だけを特定する。既存正本が既に存在した場合はそれを報告し、重複生成を提案しない。

### A. `DOC-MVP-DES`：MVP Design v0.1.10

- 基礎版：既存`MVP Design v0.1.9 日本語版.md`を起点とする実体を確認。
- BL-MVP-004で承認されたv0.1.10 Patch、付随するImpact／Consistency Review、承認された修正範囲を実ファイル・節単位で確認。
- 特にBootstrap規則と`Existing / Reactivated`の`FirstDetectedAt`保持の相違について、**旧本文と承認Patchのどちらが正本上の最終ルールか**を根拠付きで特定する。
- 他の箇所で同じ見出しへの重複Patch、先行Patch前提、未承認の追加変更がないか確認する。
- 統合する場合の基礎版・Patch順序・対象節・想定本文Version／Status・変更内容を提示するが、**現時点では統合しない**。

### B. `DOC-MVP-TESTSPEC`：MVP Test Specification v0.1.6

- 基礎版：既存`MVP Test Specification v0.1.5 日本語版.md`を起点とする実体を確認。
- **初期Candidate Patchではなく、CR-TS-001～003の補正を経た承認済みPatch-2**の正確な実体と優先関係を確認。
- CR-TS-001～003のDisposition・補正箇所と、承認記録の固定Version v0.1.6との対応を示す。
- Patch-2の適用前提、旧版側と競合する節、Patch-1等の重複適用リスク、必要な置換／追記順序を特定。
- 未確認のテスト期待値やMTSケースを独自に追加しない。実際の全文生成・Patch適用・再Reviewは行わない。

### C. `DOC-MVP-IMPL`：Implementation Plan v0.4

- 基礎版：既存`Implementation Plan v0.3`のRepository正本を確認。
- 既存v0.4 Patch、`DOC-MVP-IMPL v0.4 Consistency Review`およびその§9 Approvedの根拠、`CR-IMPL-004-001`の**P6 Input補正**を確認する。
- v0.4が単純な`BL-MVP-003`→`BL-MVP-004`の文字列置換では成立しない点を前提に、P6 Inputを含む最終差分・適用順序・対象節を特定する。
- PlanはBL-MVP-004の固定4文書組合せに含まれるか否かをApproval Record原文に基づき判定し、**Baseline構成要素**と**Baseline移行に伴う影響修正文書**を混同しない。
- 旧版の変更履歴、過去のExecution Baseline、P2実行証跡への歴史的参照はそのまま残す修正方針とする。

### 3文書共通の照合項目

各文書につき：
- `Base`・承認された最終`Patch`・補正/Decision・Reviewの**実パス（機密転記を避ける相対パス）／本文Version／Status／参照節**
- `Approved Patch`と単なる`Candidate`を区別する根拠
- 適用する変更の意味分類（Semantic／Editorial）と、承認済み範囲外の変更有無
- 適用順序、対象見出し・アンカーの一意性、重複・矛盾・欠損、既存正本の有無
- 統合後に照合すべき範囲（差分一致、Document ID・Version・Status、限定的Cross-document Consistency）
- 見つからない文書、アクセス拒否、競合があれば`NOT_FOUND`／`INACCESSIBLE`／`REVIEW_REQUIRED`とし、推測でPASSをつけない。

## 3. S4-Bに必要な最小編集計画だけ提示

**S4-Bの承認要求を準備するだけ。実施しない。**

1. Design v0.1.10／Test Specification v0.1.6／Implementation Plan v0.4の統合を、重複ない単位に分け、文書ごとに`Base → 最終承認済Patch → 適用範囲 → 検証`を示す。
2. Approval証拠不足が残る場合、S4-B開始前にユーザーへ確認すべき内容を具体化。本人の判断を伴う事項と、既存文書で確認可能な事項を分ける。
3. 次のRegistry／Overview／Handoff／README同期はS4-B以降の別承認対象として**修正予定箇所の列挙にとどめる**。`Latest Version`、`Baseline Version`、`Status`を別々に扱う。BL-MVP-003の過去履歴を消さない。
4. フルスコープ再Review、技術テスト再実行、S1～S3の再検証、新文書・新Baselineの創作を必要条件として追加しない。承認済み変更との新たな意味論的矛盾が実際に見つかった場合だけ報告する。

## 4. 禁止事項・停止条件

- **完全Read-only**：Repository、外部フォルダ、Private Index、Manifest等のファイル**作成・変更・削除・リネーム・移動なし**。統合先の空ファイル・Preview・差分ファイル・Patchファイル・スクリプトを作成しない。In-memory比較とチャット報告のみ。
- **Git操作一切禁止**（`status`、`diff`、`add`、`commit`、`push`、`reset`、履歴書換えを含む）。Gitの情報取得がなくても本Gateを遂行する。
- Approval Record／Baseline／Registry／Project Control／各技術正本の編集、新規Versionの登録、承認の作成・再承認・撤回、S4-BのRepo受入・同期を禁止。
- VBA実行、Compile／Regression／Archive／Restore再実行、Source／Workbook／OFT／Settingsの変更、管理者昇格、ACL・OneDrive・BitLocker設定変更、S5／S6着手は禁止。
- 一意に適用できないPatch、承認範囲不明、文書欠落、意味論的な競合、承認主体証拠不足を**推測で解消しない**。対応する`REVIEW_REQUIRED`または`BLOCKED`で報告し停止。自動Retry／Rollback／範囲拡大は禁止。
- 参照した証拠は必要な箇所のみ、原文の変更・Private値の転載なし。対象の既存Markdownリンク・アンカーを必要最小限Read-only確認。

## 5. 完了報告形式

```text
S4AUserAuthorization: APPROVED_READ_ONLY
S1Closure: G2_RECORDED_S1_CLOSED (existing)
S2FormalClosure: S2_FORMAL_CLOSURE_RECORDED (existing)
S3FormalClosure: S3_FORMAL_CLOSURE_RECORDED (existing)

BL-MVP-004:
  ExistingApprovalStatus: APPROVED / <observed>
  GateExecutionDate: 2026-10-01 / <observed>
  ApprovalAuthority: VERIFIED / UNKNOWN / CONFLICT
  ApprovalDecisionDate: VERIFIED / UNKNOWN / CONFLICT
  ApprovalEvidenceReferences: [existing paths/sections; no secrets]
  FixedVersionCombination: VERIFIED / REVIEW_REQUIRED
  ApprovalEvidenceGap: NONE / [minimal missing facts]

Design_v0.1.10:
  Base: [observed version/status/path]
  FinalApprovedPatch: [observed version/status/path or NOT_FOUND]
  PatchOrderAndScope: PASS / REVIEW_REQUIRED / BLOCKED
  BootstrapFirstDetectedAtRule: [approved outcome and evidence]
  IntegratedFullText: EXISTS / NOT_FOUND / INACCESSIBLE
  Readiness: READY_FOR_INTEGRATION / REVIEW_REQUIRED / BLOCKED

TestSpecification_v0.1.6:
  Base: [observed version/status/path]
  CorrectedPatch2: [observed version/status/path or NOT_FOUND]
  CR-TS-001_003Mapping: PASS / REVIEW_REQUIRED / BLOCKED
  PatchOrderAndScope: PASS / REVIEW_REQUIRED / BLOCKED
  IntegratedFullText: EXISTS / NOT_FOUND / INACCESSIBLE
  Readiness: READY_FOR_INTEGRATION / REVIEW_REQUIRED / BLOCKED

ImplementationPlan_v0.4:
  Base: [observed version/status/path]
  FinalApprovedPatch: [observed version/status/path or NOT_FOUND]
  CR-IMPL-004-001_P6Input: PASS / REVIEW_REQUIRED / BLOCKED
  PatchOrderAndScope: PASS / REVIEW_REQUIRED / BLOCKED
  IntegratedFullText: EXISTS / NOT_FOUND / INACCESSIBLE
  Readiness: READY_FOR_INTEGRATION / REVIEW_REQUIRED / BLOCKED

PatchConflicts: NONE / [exact document and section]
CandidateVsApprovedBoundary: PASS / REVIEW_REQUIRED
HistoricalBaselineReferencesPreserved: PASS
RequiredUserFacts: NONE / [minimum questions]
S4BProposedEditScope: [paths and exact sections, proposal only]
S4AReadOnlyDecision: READY_FOR_S4B_REVIEW / REVIEW_REQUIRED / BLOCKED

DocumentMutation: NONE
NewFullTextCreated: FALSE
GitOperation: NONE
BaselineMutation: NONE
TechnicalTestRerun: NONE
ArchiveRerun: NONE
S4BExecuted: FALSE
S5Started: FALSE
P2PhaseClosed: FALSE
CP-P2Established: FALSE
NextAction: USER_REVIEW_S4A_RESULT
```

判定ルール：
- `READY_FOR_S4B_REVIEW`：承認主体・承認日時の証拠上の取扱いが特定でき、Patchの実在・承認範囲・順序・競合有無を根拠付きで確認済み。**S4-B実行を意味せず、別途ユーザー承認が必要**。
- `REVIEW_REQUIRED`：承認主体／日時の証拠が未確認、またはPatchの適用範囲等について実行前のユーザー判断が必要。証拠が不足する場合は`RequiredUserFacts`に具体的に記載する。
- `BLOCKED`：必須のPatch・基礎文書が発見できない、または確定的な競合で計画不能。

**結果をチャットへ報告し停止。S4-B承認・文書更新・Baseline登録は別途ユーザー判断。**

## 6. 判断境界の再掲

今回許可されたのは、S4-Aの**証拠確認と統合方法の設計上の照合だけ**。BL-MVP-004のAPPROVED記録を新たな技術検証で置き換えない。S4-BのRepository受入・文書改訂・Registry同期は承認されていない。
