# DOC-MVP-IMPL v0.4 Candidate Patch

## 0. Patch方針

本Patchは `DOC-MVP-IMPL v0.3 / BL-MVP-004 Impact Review v0.1` の `AFFECTED / v0.4 REQUIRED` 判定を反映する。

新しいRequirement / Design / Test Expected Resultは決定しない。

`BL-MVP-004` で既に確定した内容をImplementation Planへ写像する。

**重要：`BL-MVP-003` を文書全体で一括置換しない。**

`v0.3 更新概要`、`v0.2 更新概要` 等のHistorical Revision Record内に記載された過去Baseline IDはそのまま保持する。

---

# Patch 1 — 文書タイトル / 文書情報

## 変更前

```text
# Implementation Plan v0.3 日本語版
```

## 変更後

```text
# Implementation Plan v0.4 日本語版
```

文書情報を以下へ更新する。

```text
バージョン         : v0.4
Status             : Candidate
Execution Baseline : BL-MVP-004
```

その他の文書情報は変更しない。

---

# Patch 2 — v0.4 更新概要を追加

`### v0.3 更新概要` の直前へ以下を追加する。

### v0.4 更新概要

本Revisionは、`BL-MVP-004` のApproved化および `DOC-MVP-IMPL v0.3 / BL-MVP-004 Impact Review v0.1` の判定を反映し、Implementation PlanのExecution BaselineとP2 / P6実装計画をCurrent Approved Baselineへ整合させるRevisionである。

主な変更は以下である。

1. Execution Baselineを `BL-MVP-003` から `BL-MVP-004` へ更新
2. Baseline Manifestを `DOC-MVP-REQ v0.1.9` / `DOC-MVP-DES v0.1.10` / `DOC-TS-A v0.4 CLOSED / PASS` / `DOC-MVP-TESTSPEC v0.1.6` の構成へ更新
3. `IMP-R01 Baseline Driven`、P0 Input / Exit Criteria、Formal Test Result、Implementation Entry Criteria、Appendix AのActive Baseline参照を更新
4. P2 Inputへ `DOC-MVP-DES §7.4` を追加
5. P2 Sync Engine ScopeへDetection History State、Existing / Reactivated Bootstrap、Unused / Already-Unused Timestamp Preservation、Invalid / Partial Failureを反映
6. P2で `modSyncEngine` と `modVariableDefinitionData` のMetadata責務境界を明示
7. P2 Verification / Exit CriteriaへBootstrap Rule、Common SyncTimestamp、Invalid / Partial Fail Closedを反映
8. P6 Error / Safety ScopeへInvalid / Partial Detection History Errorを追加
9. P6 VerificationへDetection History ErrorのUser Notification / Fail Closed確認を追加
10. Phase構成、Checkpoint構成、Module Mapping、P1、P3～P5、P7基本方針、Route W / WordEditor、Technical Spike B / C = NOT REQUIRED、Formal MVP Test方式は変更しない
11. Test ID Mapping構造は変更せず、`DOC-MVP-TESTSPEC v0.1.6` の既存MTS IDへ追加されたVariantを参照する

**Change Type：Execution Baseline Update / Plan-level Semantic Alignment**\
**Requirement Impact：None（DOC-MVP-REQ v0.1.9を継続）**\
**Additional Design Change：None（DOC-MVP-DES v0.1.10を反映）**\
**Technical Decision Impact：None**\
**Additional Test Definition Change：None（DOC-MVP-TESTSPEC v0.1.6を反映）**\
**Document Status：Candidate**

---

# Patch 3 — §2 目的

以下の1文のみ変更する。

## 変更前

```text
本書の目的は、BL-MVP-003で承認されたMVPを、確定済みDesignに従ってVBA実装へ安全に落とし込むため、実装順序、依存関係、Verification、および完了条件を定義することである。
```

## 変更後

```text
本書の目的は、BL-MVP-004で承認されたMVPを、確定済みDesignに従ってVBA実装へ安全に落とし込むため、実装順序、依存関係、Verification、および完了条件を定義することである。
```

その他の§2は変更しない。

---

# Patch 4 — §4.1 Execution Baseline 全文置換

## 4.1 Execution Baseline

本Implementation Planの実行基準は以下とする。

```text
Baseline ID : BL-MVP-004
Status      : Approved
```

Baseline構成：

```text
BL-MVP-004
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.9
├─ DOC-MVP-DES      MVP Design v0.1.10
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.6
```

---

# Patch 5 — §4.2 Baseline変更ルール

**変更なし。**

既存Ruleをそのまま維持する。

---

# Patch 6 — §4.3 Technical Spike B / C

冒頭1文のみ変更する。

## 変更前

```text
BL-MVP-003を基準として再確認した結果、Technical Spike B / CはともにNOT REQUIREDを維持する。
```

## 変更後

```text
BL-MVP-004を基準として再確認した結果、Technical Spike B / CはともにNOT REQUIREDを維持する。
```

後続文は変更しない。

---

# Patch 7 — IMP-R01 Baseline Driven

## 変更前

```text
### IMP-R01 Baseline Driven

すべての実装判断はBL-MVP-003を基準とする。
```

## 変更後

```text
### IMP-R01 Baseline Driven

すべての実装判断はBL-MVP-004を基準とする。
```

IMP-R02～IMP-R10は変更しない。

---

# Patch 8 — P0 Foundation

## Input

変更前：

```text
- BL-MVP-003
```

変更後：

```text
- BL-MVP-004
```

## Exit Criteria

変更前：

```text
- BL-MVP-003とのConflictがない
```

変更後：

```text
- BL-MVP-004とのConflictがない
```

P0のImplementation Scope / Verification等は変更しない。

---

# Patch 9 — §8.3 P2 Scan / Sync 全文置換

### 8.3 P2 — Scan / Sync

#### Objective

Template Variable検出とVariableDefinition同期をDesignどおり完成させる。

#### Input

- CP-P0
- CP-P1
- DOC-MVP-DES §7.4 / §14 / §15 / §25.1

#### Implementation Scope

```text
modTemplateScanner
modSyncEngine
modSyncApplication
modVariableDefinitionData
modSettingsData
modOutlookAdapter
```

#### Template Scanner

- `{{...}}` Candidate抽出
- VariableName Syntax Validation
- ValidVariables / InvalidCandidates分離
- Case Insensitive統合
- Subject / Body / Both Location統合
- TemplateScanResult生成
- To / CC / BCCを抽出対象外とする

#### Sync Engine

- New
- Existing
- Reactivated
- Unused
- Already-Unused = No-op
- Rename = Old Unused + New
- TemplateLocation
- FirstDetectedAt
- LastDetectedAt
- Detection History State
  - Initialized
  - Uninitialized
  - Invalid / Partial
- TemplateLocation StateとDetection History Stateを独立して扱う
- Existing Detection History Bootstrap
- Reactivated Detection History Bootstrap
- Unused / Already-Unusedで未検出Timestampを新規生成しない
- Invalid / Partial Detection Historyを正常Bootstrapとして扱わない
- Metadata Target State Calculation
- SyncTimestamp
- 同一Sync内のCommon SyncTimestamp
- Existingユーザー設定維持
- Sync開始前Error時はVariableDefinitionを更新しない
- Invalid / Partial Detection History時はVariableDefinitionを更新しない

#### Sync Metadata Responsibility Boundary

`modSyncEngine` は以下を担当する。

```text
Sync Classification
Detection History State判定
Bootstrap Detection
Metadata Target State Calculation
SyncTimestampのTarget State適用
```

`modVariableDefinitionData` は以下を担当する。

```text
Sync Engineが決定したTarget StateのValidation
VariableDefinition Persistence
```

`modVariableDefinitionData` では以下を行わない。

```text
Sync Classification再計算
Detection History Stateの意味変更
SyncTimestamp再取得
Bootstrap Timestamp生成
Metadata Meaning再定義
Rename推測
```

#### Implementation Detail to Decide

- VBScript.RegExpの生成方式
- Dictionary Key正規化方式
- SyncTimestampの取得・1 Sync内共有の具体的実装方式
- 同期結果UIの基本表示方式
- Unused確認UIへ渡すData形式

Detection History Stateの意味、Bootstrap条件、Classification別Metadata Target State、Sync Engine / VariableDefinition Data Accessの責務境界はImplementation Detailとして再決定しない。

これらはDOC-MVP-DESをSource of Truthとする。

#### Deliverables

- 完成版Template Scanner
- Manual Sync処理
- Sync Result

#### Phase Verification

- Valid VariableをSubject / Bodyから抽出できる
- Invalid Candidateを検出できる
- Case違いを同一Variableとして扱える
- LocationをSubject / Body / Bothへ統合できる
- Newを追加できる
- Existingのユーザー設定を維持できる
- 削除VariableをUnused化できる
- Reactivatedを再有効化できる
- Already-UnusedをNo-opとして扱える
- Renameを推測せずOld Unused + Newとして扱える
- Existing / InitializedではFirstDetectedAtを保持し、LastDetectedAtをSyncTimestampへ更新できる
- Existing / UninitializedではFirstDetectedAt / LastDetectedAtを同一SyncTimestampでBootstrapできる
- Reactivated / InitializedではFirstDetectedAtを保持し、LastDetectedAtをSyncTimestampへ更新できる
- Reactivated / UninitializedではFirstDetectedAt / LastDetectedAtを同一SyncTimestampでBootstrapできる
- Unused / UninitializedではDetection Timestampを新規生成しない
- Already-Unused / UninitializedではMetadataを変更せずDetection Timestampを新規生成しない
- TemplateLocationに既存値が存在しても `FirstDetectedAt = Blank AND LastDetectedAt = Blank` をDetection History Uninitializedとして扱える
- TemplateLocationがBlankであることだけを理由としてDetection History Stateを判定しない
- Invalid / Partial Detection HistoryをClassificationに依存しないFailure Guardとして扱える
- Invalid / Partial Detection History時にVariableDefinition Persistenceへ進まない
- 同一Sync内で新規設定・更新するDetection Timestampへ共通SyncTimestampを使用できる
- OFT不存在 / Invalid Variable時にSync更新されない
- 同期結果を利用者へ通知可能なDataを生成できる

#### Related Test Area

- MTS-TPL-001～004
- MTS-SCAN-001～005
- MTS-SYNC-001～012

#### Exit Criteria

- TemplateScanResultだけで後続処理がVariable集合とInvalid Candidateを判断可能
- Sync差分分類がDesignどおり成立する
- Existingユーザー設定をSyncが破壊しない
- Invalid TemplateからVariableDefinitionを更新できない
- Sync Metadata規則が成立する
- Detection History Bootstrap Ruleが成立する
- Invalid / Partial Detection HistoryからVariableDefinitionを更新できない
- Sync Engine / VariableDefinition Data AccessのMetadata責務境界がDesignどおり成立する
- Blocking Sync / Scanner Findingがない

---

# Patch 10 — §8.7 P6 Error / Safety / Integration

P6全体は置換せず、以下だけ局所追加する。

## Error / Safety Scope

既存項目：

```text
- Invalid Variable
- Configuration Error
- Input Error
```

付近へ以下を追加する。

```text
- Invalid / Partial Detection History Error
```

最終的に少なくとも以下を含む。

```text
Invalid Variable
Configuration Error
Invalid / Partial Detection History Error
Input Error
```

その他のError / Safety Scopeは変更しない。

## Phase Verification

以下を追加する。

```text
- Invalid / Partial Detection History FailureをError ResultとしてUser Notificationへ伝播できる
- Invalid / Partial Detection History Failure後にVariableDefinition Persistenceまたは正常Sync完了へ進まない
```

既存のPhase Verificationは削除しない。

## Related Test Area

**変更なし。**

既存：

```text
MTS-TPL-003 / 004
MTS-MAIL-002～004
MTS-ERR-001 / 002
MTS-NFR-003 / 004
Safety Summary対象Test
```

で `DOC-MVP-TESTSPEC v0.1.6` のMTS-ERR-001更新を包含する。

## Exit Criteria

**変更なし。**

既存の、

```text
Fail Closedが成立する
```

で本Error Pathを包含する。

---

# Patch 11 — §11 Test Specification Mapping

**変更なし。**

特に以下を維持する。

```text
P2 Scan / Sync
→ MTS-TPL-001～004
→ MTS-SCAN-001～005
→ MTS-SYNC-001～012

P6 Error / Safety / Integration
→ MTS-TPL-003/004
→ MTS-MAIL-002～004
→ MTS-ERR-001/002
→ MTS-NFR-003/004
```

DOC-MVP-TESTSPEC v0.1.6は新Test IDを追加せず、既存MTS-SYNC-003 / 004 / 005 / 011およびMTS-ERR-001へVariant / Expectedを追加しているため、Mapping構造を変更しない。

---

# Patch 12 — §12.4 Test Candidate Build

Formal Test ResultのBaseline IDのみ変更する。

## 変更前

```text
Baseline ID : BL-MVP-003
Build ID    : MVP-Bxxx
Commit ID   : <Git Commit ID>
```

## 変更後

```text
Baseline ID : BL-MVP-004
Build ID    : MVP-Bxxx
Commit ID   : <Git Commit ID>
```

---

# Patch 13 — §13 Error / Finding Handling

**変更なし。**

今回のIF-P2-04-001対応で実際に使用した、

```text
Design Finding
↓
Design Revision
↓
Consistency Review
↓
Baseline Approval
```

は既存§13.3 / §13.6のRule内で成立しているため、新しいFinding Flowを追加しない。

---

# Patch 14 — §14.1 Implementation Entry Criteria

以下のみ変更する。

## 変更前

```text
- BL-MVP-003がApproved
```

## 変更後

```text
- BL-MVP-004がApproved
```

その他のEntry Criteriaは変更しない。

---

# Patch 15 — Appendix A Implementation Phase Flow

先頭Baselineのみ変更する。

## 変更前

```text
BL-MVP-003
    ↓
P0 Foundation
```

## 変更後

```text
BL-MVP-004
    ↓
P0 Foundation
```

P0～P7のPhase構成およびCheckpoint構成は変更しない。

---

# Patch 16 — Explicitly Unchanged

v0.4では以下を変更しない。

```text
DOC-MVP-REQ Scope

Architecture / Layer構成

Design / Module Mapping

P0 Architecture
P1 Walking Skeleton
P3 Configuration / UserForm
P4 Validation / Formatting
P5 Full Mail Generation
P7 MVP Test Readiness基本方針

P0～P7 Phase順序

CP-P0～CP-P7

Route W / WordEditor

Classic Outlook Cold Start Design

Technical Spike A

Technical Spike B / C = NOT REQUIRED

Formal MVP Test方式

Test Case ID総数 = 69

MTS ID Mapping構造

Automatic Send = Out of Scope
```

---

# Patch 17 — Historical Revision Preservation

以下は変更しない。

```text
v0.3 更新概要
v0.2 更新概要
v0.1 作成概要
```

これらに含まれる、

```text
BL-MVP-001
BL-MVP-002
BL-MVP-003
```

は当時のRevision Contextを示すHistorical Recordであるため、BL-MVP-004へ置換しない。

---

# Candidate Result

```text
Document:
DOC-MVP-IMPL

Revision:
v0.4 Candidate

Execution Baseline:
BL-MVP-004

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

Phase Structure Change:
NONE

Module Mapping Change:
NONE

P2 Plan Impact:
APPLIED

P6 Plan Impact:
APPLIED

Status:
CANDIDATE
```
