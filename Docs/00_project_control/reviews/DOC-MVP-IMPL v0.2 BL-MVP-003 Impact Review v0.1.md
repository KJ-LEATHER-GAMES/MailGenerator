# DOC-MVP-IMPL v0.2 / BL-MVP-003 Impact Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | DOC-MVP-IMPL v0.2 / BL-MVP-003 Impact Review |
| バージョン | v0.1 |
| 対象Document | DOC-MVP-IMPL Implementation Plan v0.2 |
| Old Execution Baseline | BL-MVP-002 |
| New Current Approved Baseline | BL-MVP-003 |
| Review日 | 2026-09-19 |
| Result | **AFFECTED / REVISION REQUIRED** |
| 推奨Revision | **DOC-MVP-IMPL v0.3 Candidate** |

## 2. Review目的

BL-MVP-003 Approvalに伴い、現在 `BL-MVP-002` をExecution Baselineとして固定する
`DOC-MVP-IMPL v0.2` について、Baseline差分がImplementation Planへ与える影響を確認する。

Implementation PlanはBaseline Manifest構成文書ではないため、
BL-MVP-003 Approvalそのものを阻害しない。

一方、実装継続時に旧BaselineをExecution基準として残すことは避ける。

## 3. Baseline差分

### BL-MVP-002

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

### BL-MVP-003

```text
DOC-MVP-REQ      v0.1.9
DOC-MVP-DES      v0.1.9
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.5
```

差分：

```text
Requirements:
v0.1.8 → v0.1.9
Semantic Change

Design:
v0.1.8 → v0.1.9
Semantic Design Change

Technical Spike A:
v0.4 → v0.4
UNCHANGED

Test Specification:
v0.1.4 → v0.1.5
Semantic Test Definition Update
```

## 4. Direct Baseline Reference Impact

DOC-MVP-IMPL v0.2にはActiveな `BL-MVP-002` 固定参照が複数存在する。

主な対象：

```text
Document Information / Execution Baseline
§2 Purpose
§4.1 Execution Baseline
§4.3 Technical Spike B / C
IMP-R01 Baseline Driven
P0 Input
P0 Exit Criteria
Formal Test Result Baseline ID
Implementation Entry Criteria
Appendix A Implementation Phase Flow
```

したがって：

```text
Execution Baseline Alignment:
AFFECTED
```

Revision Required：

```text
BL-MVP-002
→
BL-MVP-003
```

Historical Revision Summary内のBL-MVP-002記録は履歴として維持する。

## 5. P1 Walking Skeleton Impact

### 現行Plan

```text
Settings
↓
OFT Path
↓
Create MailItem
↓
Inspector / WordEditor
↓
...
```

現行P1 Input：

```text
DOC-MVP-DES §12～14、§22～25、D16
```

### BL-MVP-003 Design

DOC-MVP-DES v0.1.9では以下が追加された。

```text
Classic Outlook Readiness
↓
Explorerあり？
├─ Yes → Existing Outlook reuse
└─ No  → Visible Explorer起動 / Display
↓
Create MailItem
↓
Inspector / WordEditor
```

Design Decision：

```text
D18 Classic Outlook Cold Start Initialization
```

したがってP1 Walking Skeletonは以下へ更新が必要。

```text
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
必要時Visible Explorer起動
↓
Create MailItem
↓
Inspector / WordEditor
↓
...
```

判定：

```text
P1 Walking Skeleton:
AFFECTED
```

## 6. P1 Implementation Detail Impact

追加が必要：

```text
Classic Outlook Readiness確認
Existing Explorer再利用
Cold Start時Visible Explorer初期化
Explorer Local COM Reference解放
Startup / Explorer Initialization Error変換
Warm / Cold Start Verification
```

ただし以下はDesignで既に確定済みであり、Implementation Planでは再決定しない。

```text
Explorer存在時は既存Outlook利用
Explorerなし時のみVisible Explorer起動
Explorerは処理後Closeしない
Scan / Error途中MailItemはDisplayしない
```

## 7. P1 Phase Verification Impact

### Warm Start

```text
既存Explorerを利用
不要な追加Explorerなし
WordEditor Access PASS
```

### Cold Start

```text
ユーザー事前起動なし
Visible Explorer自動起動
WordEditor Access PASS
Scan MailItem Display NONE
Draft Residue NONE
Inspector Residue NONE
```

Related Test Areaは既存Test IDを維持し、DOC-MVP-TESTSPEC v0.1.5のVariantを参照する。

```text
MTS-MAIL-001
MTS-MAIL-003
```

## 8. P6 Error / Safety / Integration Impact

BL-MVP-003では以下を明示的に追加する必要がある。

```text
Outlook Application取得失敗
MAPI Session取得失敗
Default Folder取得失敗
Explorer生成失敗
Explorer Display失敗
Classic Outlook Readiness失敗
```

ErrorType：

```text
OutlookError
```

Target候補：

```text
OutlookStartup
OutlookExplorer
WordEditor
```

Related Test：

```text
MTS-ERR-001
MTS-ERR-002
```

判定：

```text
P6:
AFFECTED
```

## 9. Phase Structure / Module Structure Impact

以下は変更不要。

```text
P0 ～ P7 Phase構成
CP-P0 ～ CP-P7 Checkpoint構成
modOutlookAdapter配置
Route W / WordEditor
Outlook / Word依存のAdapter集約
Technical Spike B / C = NOT REQUIRED
Formal MVP Test方針
```

判定：

```text
Phase Structure:
UNCHANGED

Module Structure:
UNCHANGED
```

## 10. Technical Spike Impact

```text
Technical Spike A Reopen:
NOT REQUIRED

Technical Spike B / C:
NOT REQUIRED
```

Cold Start問題は `TV-P1-02-001` で技術条件を特定済み。

## 11. P1-02 Implementation Unit Specification Impact

現行 `P1-02 Inspector WordEditor Connection 実施仕様 v0.1` は以下を前提としている。

```text
Current Execution Baseline = BL-MVP-002

CreateMailFromTemplate
↓
ReadBodyText
↓
MailItem.GetInspector
↓
Inspector.WordEditor
```

Cold Start Readiness / Explorer Initializationは定義されていない。

したがって：

```text
P1-02 Implementation Unit Specification:
AFFECTED
```

推奨対応：

```text
P1-02 Inspector WordEditor Connection 実施仕様 v0.2
```

理由：

- Production FlowへReadinessが追加される
- Baseline IDがBL-MVP-003へ変わる
- PASS CriteriaへWarm / Cold Startが追加される
- Explorer Lifecycle責務が追加される

## 12. Impact Classification

```text
DOC-MVP-IMPL v0.2:
AFFECTED

Revision:
REQUIRED

Recommended:
DOC-MVP-IMPL v0.3 Candidate

Change Type:
Execution Baseline Update
+
Plan-level Semantic Alignment
```

Requirement / Design / Test DefinitionをImplementation Plan側で新たに変更しない。

## 13. Recommended v0.3 Revision Scope

### Required

```text
1. Execution Baseline
   BL-MVP-002 → BL-MVP-003

2. Baseline Manifest
   REQ v0.1.9
   DES v0.1.9
   TS-A v0.4
   TESTSPEC v0.1.5

3. Active BL-MVP-002 reference更新

4. P1 InputへD18追加

5. P1 Minimum Vertical SliceへClassic Outlook Readiness追加

6. P1 Implementation DetailへCold Start Explorer Initialization追加

7. P1 Phase VerificationへWarm / Cold Start追加

8. P6 Error ScopeへStartup / Explorer Initialization Failure追加

9. Formal Test Result / Entry Criteria / Appendix AのBaseline参照更新
```

### Unchanged

```text
P0～P7 Phase構成
CP-P0～CP-P7
Module Mapping
Route W / WordEditor
Test Case ID
Technical Spike B / C判定
Formal MVP Test Gate
```

## 14. Impact Review Result

```text
DOC-MVP-IMPL v0.2 / BL-MVP-003

Impact:
AFFECTED

Blocking Conflict with BL-MVP-003:
YES for continued execution under v0.2 as-is

BL-MVP-003 Approval Impact:
NONE

Implementation Plan Revision:
REQUIRED

Recommended Revision:
DOC-MVP-IMPL v0.3 Candidate
```

ImplementationをBL-MVP-003基準で継続する前に、v0.3 Candidateを作成しPlan Consistency Reviewを実施する。
