# DOC-MVP-IMPL v0.3 / BL-MVP-004 Impact Review v0.1

## 1. 文書情報

| 項目                | 内容                                    |
| ----------------- | ------------------------------------- |
| 対象文書              | DOC-MVP-IMPL Implementation Plan v0.3 |
| Impact Source     | BL-MVP-004                            |
| Review Type       | Baseline Impact Review                |
| Review Date       | 2026-10-01                            |
| Result            | **AFFECTED**                          |
| Revision Decision | **v0.4 REQUIRED**                     |

---

## 2. Review Objective

BL-MVP-004 Approvalに伴い、`DOC-MVP-IMPL v0.3` がCurrent Approved Baselineおよび更新されたDesign / Test Definitionと整合しているかを確認する。

本ReviewではRequirement / Design / Test Specificationを再決定しない。

確認対象は以下とする。

```text
Execution Baseline Reference
+
Implementation Plan Scope
+
Phase Verification
+
Exit Criteria
+
Test Specification Mapping
```

---

## 3. Baseline Difference

### BL-MVP-003

```text
DOC-MVP-REQ      v0.1.9
DOC-MVP-DES      v0.1.9
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.5
```

### BL-MVP-004

```text
DOC-MVP-REQ      v0.1.9
DOC-MVP-DES      v0.1.10
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.6
```

変更対象：

```text
DOC-MVP-DES:
v0.1.9 → v0.1.10

DOC-MVP-TESTSPEC:
v0.1.5 → v0.1.6
```

変更なし：

```text
DOC-MVP-REQ:
v0.1.9

DOC-TS-A:
v0.4 CLOSED / PASS
```

---

## 4. Impact Classification

```text
Requirement Impact:
NONE

Additional Design Change:
NONE

Technical Decision Impact:
NONE

Additional Test Definition Change:
NONE

Implementation Plan Impact:
AFFECTED
```

Change Type：

```text
Execution Baseline Update
+
Plan-level Semantic Alignment
```

BL-MVP-004で確定済みのDesign / Test DefinitionをImplementation Planへ反映するものであり、Implementation Plan自身が新しい仕様を決定するものではない。

---

# 5. Affected Sections

## 5.1 §1 文書情報

### Current

```text
Execution Baseline = BL-MVP-003
```

### Required

```text
Execution Baseline = BL-MVP-004
```

判定：

```text
AFFECTED
```

---

## 5.2 Revision Summary

`v0.3 更新概要` はHistorical Revision Recordとして変更しない。

v0.4 Revision作成時に、新たに `v0.4 更新概要` を追加する。

想定Change Summary：

```text
BL-MVP-004へのExecution Baseline更新
+
P2 Detection History / Bootstrap / Fail Closed整合
+
P6 Invalid / Partial Detection History Error Path整合
```

判定：

```text
NEW v0.4 SUMMARY REQUIRED
v0.3 HISTORY UNCHANGED
```

---

## 5.3 §2 目的

現在：

```text
BL-MVP-003で承認されたMVPを...
```

Required：

```text
BL-MVP-004で承認されたMVPを...
```

Source of Truth構造自体は変更しない。

判定：

```text
AFFECTED
```

---

## 5.4 §4.1 Execution Baseline

以下を更新する。

```text
Baseline ID:
BL-MVP-003
↓
BL-MVP-004
```

Baseline Manifest：

```text
DOC-MVP-REQ      v0.1.9
DOC-MVP-DES      v0.1.10
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.6
```

判定：

```text
AFFECTED
```

---

## 5.5 §4.2 Baseline変更ルール

既存ルール：

```text
新Revisionが作成されてもExecution Baselineを自動更新しない
Design Gap等では正式Baseline Approvalへ戻る
```

は今回実際に適用された運用と一致する。

判定：

```text
NOT AFFECTED
```

---

## 5.6 §4.3 Technical Spike B / C

Baseline参照：

```text
BL-MVP-003
↓
BL-MVP-004
```

へ更新する。

ただし結論：

```text
Technical Spike B:
NOT REQUIRED

Technical Spike C:
NOT REQUIRED
```

は維持する。

BL-MVP-004では新しい技術成立性Questionは発生していない。

判定：

```text
REFERENCE UPDATE ONLY
```

---

## 5.7 IMP-R01 Baseline Driven

現在：

```text
すべての実装判断はBL-MVP-003を基準とする。
```

Required：

```text
すべての実装判断はBL-MVP-004を基準とする。
```

判定：

```text
AFFECTED
```

IMP-R02～IMP-R10の原則自体は変更しない。

---

## 5.8 P0 Foundation

P0の機能Scope / Verificationは変更しない。

ただし以下のBaseline固定参照はCurrent Execution Baselineへ更新する。

```text
Input:
BL-MVP-003
↓
BL-MVP-004
```

```text
Exit Criteria:
BL-MVP-003とのConflictがない
↓
BL-MVP-004とのConflictがない
```

判定：

```text
REFERENCE UPDATE ONLY
```

P0 Architecture / Data Access Scope：

```text
NOT AFFECTED
```

---

# 6. P2 Scan / Sync Impact

P2は本Impact Reviewの主要Affected Areaとする。

## 6.1 P2 Input

現在：

```text
DOC-MVP-DES §14 / §15 / §25.1
```

Required：

```text
DOC-MVP-DES §7.4 / §14 / §15 / §25.1
```

理由：

Detection History StateおよびMetadata更新規則のSource of TruthとしてDesign §7.4が明示的に必要となったため。

判定：

```text
AFFECTED
```

---

## 6.2 P2 Implementation Scope — Sync Engine

既存Scope：

```text
New
Existing
Reactivated
Unused
Rename
TemplateLocation
FirstDetectedAt
LastDetectedAt
SyncTimestamp
Existingユーザー設定維持
Sync開始前Error時はVariableDefinitionを更新しない
```

は維持する。

これに以下のBL-MVP-004 Alignmentを追加する必要がある。

```text
Detection History State
├─ Initialized
├─ Uninitialized
└─ Invalid / Partial

TemplateLocation Stateと
Detection History Stateの独立判定

Existing Bootstrap

Reactivated Bootstrap

Unused / Already-Unused
Detection Timestamp非生成

Invalid / Partial Detection History
→ Failure

Metadata Target State Calculation
```

判定：

```text
AFFECTED
```

---

## 6.3 P2 Responsibility Boundary

BL-MVP-004で以下の責務境界が明確化されたため、Planにも反映する必要がある。

```text
modSyncEngine
├─ Sync Classification
├─ Detection History State判定
├─ Bootstrap Detection
├─ Metadata Target State Calculation
└─ SyncTimestamp Target State適用

modVariableDefinitionData
├─ Target State Validation
└─ Persistence
```

`modVariableDefinitionData`では以下を行わない。

```text
Classification再計算
Bootstrap意味再判定
SyncTimestamp再取得
Bootstrap Timestamp生成
Metadata Meaning再定義
```

これはModule Mappingの変更ではなく、既存Module間のResponsibility Boundaryの明確化である。

判定：

```text
AFFECTED
```

---

## 6.4 P2 Implementation Detail to Decide

以下は引き続きImplementation Detailでよい。

```text
VBScript.RegExp生成方式
Dictionary Key正規化方式
SyncTimestampの具体的取得方法
同期結果UIの基本表示方式
Unused確認UIへ渡すData形式
```

ただし、

```text
Detection Historyをどういう意味として扱うか
Bootstrap時にTimestampを作るか
P2-02 / P2-03のどちらがTarget Stateを決めるか
```

はImplementation Detailではない。

これらはBL-MVP-004で既にDesign確定済みである。

判定：

```text
STRUCTURE MAINTAINED
NO NEW IMPLEMENTATION DECISION
```

---

## 6.5 P2 Phase Verification

既存の一般的な、

```text
MetadataがNew / Existing / Reactivated / Unused規則どおり更新される
```

だけではBL-MVP-004のVerificationとして不足する。

以下を明示的に追加する必要がある。

```text
Existing / Initialized
→ First保持 / Last更新

Existing / Uninitialized
→ First / Lastを同一SyncTimestampでBootstrap

Reactivated / Initialized
→ First保持 / Last更新

Reactivated / Uninitialized
→ First / Lastを同一SyncTimestampでBootstrap

Unused / Uninitialized
→ Detection Timestampを生成しない

Already-Unused / Uninitialized
→ No-op

TemplateLocationが既存値を持っていても
Blank / Blank Detection HistoryをUninitializedとして扱える

Invalid / Partial Detection History
→ Failure

Invalid / Partial Detection History
→ VariableDefinition Persistenceなし

同一Sync内の更新Timestamp
→ 共通SyncTimestamp
```

判定：

```text
AFFECTED
```

---

## 6.6 P2 Related Test Area

現在：

```text
MTS-TPL-001～004
MTS-SCAN-001～005
MTS-SYNC-001～012
```

MTS-SYNC-003 / 004 / 005 / 011の新Variantは既存ID範囲内である。

したがってID Mapping自体は変更不要。

```text
MTS-SYNC-001～012
```

の参照でv0.1.6の新Variantを包含する。

判定：

```text
NOT AFFECTED
```

---

## 6.7 P2 Exit Criteria

既存：

```text
Sync Metadata規則が成立する
```

は維持するが、BL-MVP-004で重要となったFailure ContractをExit Criteriaへ明示する必要がある。

追加すべき条件：

```text
Detection History Bootstrap Ruleが成立する

Invalid / Partial Detection Historyから
VariableDefinitionを更新できない

Sync Engine / VariableDefinition Data Accessの
責務境界がDesignどおり成立する
```

判定：

```text
AFFECTED
```

---

# 7. P3 / P4 / P5 Impact

BL-MVP-004はSync Metadata Bootstrap / Persistence Contractに関する変更であり、

```text
P3 Configuration / UserForm
P4 Validation / Formatting
P5 Full Mail Generation
```

の主要Implementation Scope、Sequence、Verification、Exit Criteriaを変更しない。

判定：

```text
NOT AFFECTED
```

---

# 8. P6 Error / Safety / Integration Impact

P6は既に、

```text
異常系
User Notification
Fail Closed
MTS-ERR-001
```

を担当している。

したがってPhase構造自体は変更不要である。

ただしBL-MVP-004 / DOC-MVP-TESTSPEC v0.1.6では、

```text
Invalid / Partial Detection History
→ Error Result
→ UI Notification
→ Stop
```

が明示された。

このためP6 Error / Safety Scopeへ、

```text
Invalid / Partial Detection History Error
```

を追加する。

Phase Verificationへ、

```text
Invalid / Partial Detection History Failureが
User Notificationへ伝播する

Failure後に正常Sync完了として扱わない
```

を追加する。

具体的ErrorType / Message文言は新規決定しない。

判定：

```text
AFFECTED
```

---

# 9. §11 Test Specification Mapping

現在P2は、

```text
MTS-SYNC-001～012
```

を参照している。

P6は、

```text
MTS-ERR-001 / 002
```

を参照している。

DOC-MVP-TESTSPEC v0.1.6の変更は既存Test IDへのVariant追加であり、新Test IDは追加されていない。

したがってMapping TableのID範囲はそのままで新Test Definitionを包含する。

判定：

```text
NOT AFFECTED
```

---

# 10. §12.4 Formal Test Result

現在：

```text
Baseline ID : BL-MVP-003
Build ID    : MVP-Bxxx
Commit ID   : <Git Commit ID>
```

Required：

```text
Baseline ID : BL-MVP-004
Build ID    : MVP-Bxxx
Commit ID   : <Git Commit ID>
```

判定：

```text
AFFECTED
```

---

# 11. §13 Finding Handling

以下のFlowは今回実際に適用された。

```text
Design Finding
↓
Design Revision
↓
Test Specification Impact
↓
Cross-document Review
↓
Baseline Approval
```

既存 §13.6 Baseline変更Ruleと整合する。

判定：

```text
NOT AFFECTED
```

---

# 12. §14.1 Implementation Entry Criteria

現在：

```text
BL-MVP-003がApproved
```

Required：

```text
BL-MVP-004がApproved
```

その他Criteriaは維持する。

判定：

```text
AFFECTED
```

---

# 13. Appendix A Implementation Phase Flow

開始点：

```text
BL-MVP-003
↓
P0 Foundation
```

を、

```text
BL-MVP-004
↓
P0 Foundation
```

へ更新する。

Phase構成：

```text
P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7
```

は変更しない。

判定：

```text
REFERENCE UPDATE ONLY
```

---

# 14. Explicitly Not Affected

以下はBL-MVP-004によるRevision不要と判定する。

| Area                        | Result       |
| --------------------------- | ------------ |
| Requirement Scope           | NOT AFFECTED |
| Architecture / Layer構成      | NOT AFFECTED |
| Module Mapping              | NOT AFFECTED |
| Phase数 / Phase順序            | NOT AFFECTED |
| CP-P0～CP-P7構成               | NOT AFFECTED |
| P1 Walking Skeleton         | NOT AFFECTED |
| P3 Configuration / UserForm | NOT AFFECTED |
| P4 Validation / Formatting  | NOT AFFECTED |
| P5 Full Mail Generation     | NOT AFFECTED |
| P7 Test Readiness基本方針       | NOT AFFECTED |
| Route W / WordEditor        | NOT AFFECTED |
| Technical Spike A Decision  | NOT AFFECTED |
| Technical Spike B / C要否     | NOT AFFECTED |
| Formal MVP Test方式           | NOT AFFECTED |
| Test Case ID総数              | NOT AFFECTED |
| Automatic Send Out of Scope | NOT AFFECTED |

---

# 15. Revision Necessity Assessment

文書管理ルール上、Version Upはその文書自身の内容が変更される場合に実施する。

今回、Implementation Planでは単なるCurrent Baseline参照だけでなく、

```text
P2 Input
P2 Sync Engine Scope
P2 Responsibility Boundary
P2 Phase Verification
P2 Exit Criteria
P6 Error / Safety Scope
P6 Phase Verification
```

の内容変更が必要となる。

したがって：

```text
DOC-MVP-IMPL v0.3:
AFFECTED

Editorial-only:
NO

Reference-only:
NO

Plan-level Semantic Alignment:
YES
```

---

# 16. Revision Decision

```text
DOC-MVP-IMPL v0.3
BL-MVP-004 Impact Review

RESULT:
AFFECTED

v0.4 Revision:
REQUIRED
```

v0.4は以下の位置付けとする。

```text
Change Type:
Execution Baseline Update
+
Plan-level Semantic Alignment

Requirement Impact:
NONE

Additional Design Change:
NONE

Technical Decision Impact:
NONE

Additional Test Definition Change:
NONE
```

v0.4ではBL-MVP-004で既に確定したDesign / Test DefinitionのみをImplementation Planへ写像し、新しい仕様・設計判断は行わない。

---

# 17. Next Action

次工程：

```text
DOC-MVP-IMPL v0.4 Candidate作成
```

Revision Scope：

```text
1. Execution Baseline / Manifest更新
2. Baseline固定参照更新
3. P2 Input更新
4. P2 Sync Engine Scope更新
5. P2 Responsibility Boundary追加
6. P2 Verification更新
7. P2 Exit Criteria更新
8. P6 Invalid / Partial Detection History Error Path追加
9. Formal Test Result Baseline更新
10. Implementation Entry Criteria更新
11. Appendix A Baseline更新
```

明示的に変更しない：

```text
Phase Architecture
Module Mapping
P1
P3～P5
P7基本方針
Route W
Technical Spike Decision
Test ID Mapping構造
```
