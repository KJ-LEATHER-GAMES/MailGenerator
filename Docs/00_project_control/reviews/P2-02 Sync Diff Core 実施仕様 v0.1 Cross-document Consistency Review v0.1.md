# P2-02 Sync Diff Core 実施仕様 v0.1 Cross-document Consistency Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P2-02 Sync Diff Core 実施仕様 v0.1 Cross-document Consistency Review |
| バージョン | v0.1 |
| 対象プロジェクト | 定型メール作成ツール MVP |
| 文書種別 | Cross-document Consistency Review |
| Review対象 | P2-02 Sync Diff Core 実施仕様 v0.1 |
| Execution Baseline | BL-MVP-003 |
| Review Result | **PASS WITH CORRECTIONS** |
| Final Approval Result | **APPROVED AFTER CORRECTIONS** |

---

## 2. Review目的

`P2-02 Sync Diff Core 実施仕様 v0.1` が、以下のSource of Truthおよび前提Implementation Boundaryと整合していることを確認する。

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
P2-01 Full Template Scanner Completion Record v0.1
P2-02 Sync Diff Core Boundary Confirmation v0.1
```

確認観点：

```text
Semantic Conflict
Traceability Break
Scope Expansion
Requirement Gap
Design Finding
Test Definition Conflict
P2-01 Contract Conflict
Boundary Conflict
Baseline Change Need
Technical Spike Reopen Need
```

---

## 3. Review対象

### 3.1 Primary Review Target

```text
P2-02 Sync Diff Core 実施仕様 v0.1
Status before review:
Draft / Cross-document Consistency Review Pending
```

### 3.2 Source of Truth

```text
DOC-MVP-REQ
- FR-VAR-004
- FR-VAR-005
- FR-SCAN-001～003
- FR-SYNC-001～008
- VariableDefinition要件

DOC-MVP-DES
- §7.4 自動管理列の更新規則
- §11 内部データ構造
- §14 Template Scanner
- §15 Sync Engine
- §25.1 手動同期

DOC-MVP-TESTSPEC
- MTS-SYNC-002～011

DOC-MVP-IMPL
- P2 Scan / Sync

P2-01 Completion
- Full TemplateScanResult Contract

P2-02 Boundary Confirmation
- P2-02 / P2-03 Responsibility Boundary
```

---

## 4. Requirement Consistency Review

### 4.1 Case Insensitive Identity

Requirement：

```text
VariableName比較では大文字・小文字を区別しない
既存VariableDefinitionが存在する場合は既存表記を正式表記として保持
```

実施仕様：

```text
templateIndex.CompareMode = vbTextCompare
currentIndex.CompareMode = vbTextCompare

New
→ Scanner初回検出表記

Existing / Reactivated / Unused
→ Existing VariableDefinition表記
```

判定：

```text
PASS
```

### 4.2 New

Requirement：

```text
Templateに存在
VariableDefinitionに存在しない
→ New
```

実施仕様：

```text
Pass A
currentIndex.Exists = False
→ New
```

Target Metadata：

```text
Status = Active
TemplateLocation = Current Scan
FirstDetectedAt = SyncTimestamp
LastDetectedAt = SyncTimestamp
```

判定：

```text
PASS
```

### 4.3 Existing設定保持

Requirement：

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format

をSyncで上書きしない
```

実施仕様：

```text
User ConfigurationをDiff Itemへ含めない
Input Dictionaryを変更しない
```

判定：

```text
PASS
```

P2-02で成立するのはCore側の更新対象制限まで。

Excel Persistence後の最終保持はP2-03以降で確認する。

### 4.4 Unused

Requirement：

```text
Templateから削除
→ 行削除せずUnused
→ 既存設定保持
```

実施仕様：

```text
Templateなし
Current Active
→ Unused

TemplateLocation / FirstDetectedAt / LastDetectedAt
→ Existing値保持
```

判定：

```text
PASS
```

### 4.5 Reactivated

Requirement：

```text
Unusedと同一Variableが再登場
→ Active
→ 既存設定再利用
```

実施仕様：

```text
Templateあり
Current Unused
→ Reactivated

Status = Active
Canonical = Existing Definition
Metadata = Design Ruleどおり
```

判定：

```text
PASS
```

### 4.6 Rename

Requirement：

```text
Renameを自動推測しない
Old → Unused
New → New
```

実施仕様：

```text
Similarity / Rename Mappingなし
Pass A + Pass Bで自然にOld Unused + New
```

判定：

```text
PASS
```

### 4.7 Invalid Variable

Requirement：

```text
Invalid Variableが存在する場合
→ 手動Sync開始不可
```

Design sequenceではInvalid判定はSync Engine前に実施される。

Draft実施仕様には、

```text
InvalidCandidates > 0
→ ConfigurationError
```

という防御処理が存在した。

これは防御的Guardとしては妥当だが、記述だけを見るとP2-02がManual Sync開始前Validationを担当するように解釈できる余地があった。

判定：

```text
PASS WITH CORRECTION
```

Correction：

```text
CR-P2-02-001
```

---

## 5. Design Consistency Review

### 5.1 Dictionary / Case Insensitive

Design：

```text
Scripting.Dictionary
CompareMode = vbTextCompare
```

実施仕様：

```text
templateIndex
currentIndex
syncDiffResult / Diff Item

late-bound Dictionary
```

判定：

```text
PASS
```

### 5.2 5状態Designと4 Public Classification

Design：

```text
New
Existing
Reactivated
Unused化
既にUnused = 変更なし
```

Boundary：

```text
Public Classification
= New / Existing / Reactivated / Unused

Already-Unused
= No-op
```

実施仕様：

```text
Already-UnusedをPublic Resultへ追加しない
```

判定：

```text
PASS
```

新しいDesign DecisionではなくBoundaryの具体化。

### 5.3 Metadata

Design §7.4 / §15：

```text
New:
Current Location / Active / SyncTimestamp / SyncTimestamp

Existing:
Current Location / Active維持 / Keep / SyncTimestamp

Reactivated:
Current Location / Active / Keep / SyncTimestamp

Unused:
Last Location Keep / Unused / Keep / Keep

Already-Unused:
Keep / Keep / Keep / Keep
```

実施仕様は同一。

判定：

```text
PASS
```

### 5.4 SyncTimestamp

Design：

```text
1 Sync内で共通Timestamp
```

Boundary：

```text
Application側で1回取得
P2-02へ注入
```

実施仕様：

```text
syncTimestamp As Date
P2-02内部でNow / Date / Time等を取得しない
```

判定：

```text
PASS
```

### 5.5 Manual Sync Sequence

Design §25.1：

```text
Template Scan
↓
Invalidあり？
├─ Yes → Stop
└─ No
    ↓
VariableDefinition Data Access
↓
Sync Engine
```

Draft実施仕様のInvalidCandidates defensive checkは、Production正常Sequenceでは到達しない。

CR-P2-02-001により、防御的Contract GuardでありPrimary Validation責務ではないことを明文化する。

Correction後：

```text
PASS
```

---

## 6. Test Specification Consistency Review

### 6.1 Core Logic Coverage

C1-C18は以下へ接続する。

```text
MTS-SYNC-002 New
MTS-SYNC-003 Existing
MTS-SYNC-004 Unused
MTS-SYNC-005 Reactivated
MTS-SYNC-006 Rename
MTS-SYNC-007 Case Insensitive / Canonical
MTS-SYNC-011 Metadata / Common Timestamp
```

分類・Canonical Name・Target MetadataのCore Coverageとしては十分。

判定：

```text
PASS
```

### 6.2 Formal Test Boundary

Formal Test SpecificationのExpectedには、

```text
新規行追加
VariableDefinition更新後の値
ユーザー設定保持
行非削除
Manual Sync挙動
```

等、Persistence / Integrationを含む。

P2-02はExcelへ書き込まないため、P2-02 Core VerificationだけではMTS-SYNC-002～007 / 011全体をFormal PASSにできない。

Draft実施仕様もFormal Testではない旨を記載していたが、Traceability表ではTest IDを直接記載しており、Core Portionであることをさらに明確化した方が安全。

判定：

```text
PASS WITH CORRECTION
```

Correction：

```text
CR-P2-02-002
```

---

## 7. Implementation Plan Consistency Review

Implementation Plan P2 Sync Engine Scope：

```text
New
Existing
Reactivated
Unused
Rename = Old Unused + New
TemplateLocation
FirstDetectedAt
LastDetectedAt
SyncTimestamp
Existingユーザー設定維持
```

P2-02 Scope：

```text
Diff Classification
Canonical Name
Target Metadata Calculation
```

Persistence / Manual Sync / UIは後続へ維持。

判定：

```text
PASS
```

Implementation PlanのPhase Scopeを縮小・拡大していない。

---

## 8. P2-01 Contract Review

P2-01 Final Contract：

```text
TemplateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

実施仕様Input：

```text
templateScanResult
├─ ValidVariables
├─ InvalidCandidates
└─ Locations
```

P2-01責務外：

```text
VariableDefinition Canonical Casing
Sync Diff
Excel Persistence
Manual Sync
UI
```

P2-02はこれらのうちSync Diff / Canonicalを引き受け、Scannerを再実装しない。

判定：

```text
PASS
```

P2-01 Public API変更：

```text
NONE
```

---

## 9. Boundary Confirmation Review

Boundaryで確定済み：

```text
Input
= TemplateScanResult + Current VariableDefinitions + SyncTimestamp

Public Classification
= New / Existing / Reactivated / Unused

Already-Unused
= No-op

Canonical
New = Scanner表記
Existing / Reactivated / Unused = Definition表記

SyncTimestamp
= Applicationで1回取得しP2-02へ注入

P2-02
= Target Metadata計算

P2-03
= Persistence
```

実施仕様はこれを変更せず具体化している。

判定：

```text
PASS
```

---

## 10. Scope Review

### P2-02 In Scope

```text
Core Diff
Canonical Name
Metadata Target
Input Contract Validation
Defensive Runtime / Contract Guard
COperationResult変換
C1-C18
```

### Out of Scope維持

```text
Excel Write
Manual Sync Orchestration
OFT Precheck
Outlook
UI
User Notification
Formal Error Taxonomy
Formal MVP Test
```

CR-P2-02-001適用後、Invalid Candidate処理は防御的Guardに限定される。

判定：

```text
Scope Expansion:
NONE
```

---

## 11. Corrections

### CR-P2-02-001 — InvalidCandidates Responsibility Clarification

#### Finding

Draftでは、

```text
InvalidCandidates > 0
→ ConfigurationError
```

をP2-02 Input Validation / Error Mappingへ含めていた。

処理自体はFail Closedとして安全だが、Design §25.1とBoundaryでは、

```text
Application側
→ InvalidCandidates.Count = 0を保証
→ その後Sync Engine
```

である。

#### Correction

P2-02側の処理を、

```text
Primary Manual Sync Validation
```

ではなく、

```text
Defensive Precondition / Contract Guard
```

と明記する。

FR-SYNC-008 / MTS-SYNC-010の正式な停止・通知責務は後続Integrationへ維持する。

#### Classification

```text
Clarification
Responsibility Boundary Correction
Semantic Change = None
```

#### Status

```text
APPLIED
```

---

### CR-P2-02-002 — Formal Test Scope Clarification

#### Finding

DraftではMTS-SYNC-002～007 / 011へ直接Traceabilityを持たせていた。

Traceability自体は正しいが、P2-02ではPersistenceを実行しないため、

```text
P2-02 Verification PASS
=
MTS-SYNC-* Formal PASS
```

とはならない。

#### Correction

各Test IDとの関係を、

```text
Core Portion
```

と明記する。

Formal PASSはP2-03以降のPersistence / IntegrationおよびP7後のTest Candidate Buildで判定する。

#### Classification

```text
Clarification
Evidence Boundary Correction
Semantic Change = None
```

#### Status

```text
APPLIED
```

---

## 12. Final Consistency Matrix

| Review Area | Result |
|---|---|
| Requirement Semantic Consistency | PASS |
| FR-VAR-004 / Canonical Rule | PASS |
| FR-SYNC-001～006 | PASS |
| FR-SYNC-008 Responsibility | PASS AFTER CR-P2-02-001 |
| Design §7.4 Metadata | PASS |
| Design §11 Dictionary | PASS |
| Design §15 Sync Engine | PASS |
| Design §25.1 Sequence | PASS AFTER CR-P2-02-001 |
| Test Core Coverage | PASS |
| Formal Test Boundary | PASS AFTER CR-P2-02-002 |
| Implementation Plan P2 Scope | PASS |
| P2-01 Contract | PASS |
| Boundary Confirmation | PASS |
| P2-03 Responsibility Separation | PASS |
| Scope Expansion | NONE |
| Requirement Gap | NONE |
| Design Finding | NONE |
| Test Definition Conflict | NONE |
| Technical Spike Reopen | NOT REQUIRED |
| Baseline Change | NOT REQUIRED |

---

## 13. Quality Gate

```text
Semantic Conflict:
NONE

Traceability Break:
NONE

Blocking Requirement Gap:
NONE

Blocking Design Finding:
NONE

Blocking Test Definition Conflict:
NONE

Blocking Scope Expansion:
NONE

P2-01 Contract Conflict:
NONE

Boundary Conflict:
NONE

Technical Spike Reopen:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

Correction Count:
2

Corrections Applied:
2

Blocking Finding:
0
```

---

## 14. Review Result

Initial Review：

```text
PASS WITH CORRECTIONS
```

Corrections：

```text
CR-P2-02-001 APPLIED
CR-P2-02-002 APPLIED
```

Final Result：

```text
Cross-document Consistency:
PASS

P2-02 Sync Diff Core 実施仕様 v0.1:
APPROVED
```

---

## 15. Approval Decision

Correction反映後の `P2-02 Sync Diff Core 実施仕様 v0.1` は、

```text
DOC-MVP-REQ
DOC-MVP-DES
DOC-MVP-TESTSPEC
DOC-MVP-IMPL
P2-01 Completion
P2-02 Boundary Confirmation
```

とのSemantic Consistencyを満たす。

したがって、

```text
P2-02 Sync Diff Core 実施仕様 v0.1
Status:
APPROVED
```

とする。

Current Approved Baseline：

```text
BL-MVP-003
```

を維持する。

新Baseline：

```text
NOT REQUIRED
```

---

## 16. Next Action

```text
Approved P2-02 Sync Diff Core 実施仕様 v0.1
↓
modSyncEngine Production Implementation
↓
VBA Compile
↓
C1-C18 Core Verification
↓
必要Technical Negative Verification
↓
P2-01 / P0 Contract Compatibility
↓
Finding Assessment
↓
Production Patch Review
↓
Completion Record
```

Production CodingはApproved仕様を基準に開始する。
