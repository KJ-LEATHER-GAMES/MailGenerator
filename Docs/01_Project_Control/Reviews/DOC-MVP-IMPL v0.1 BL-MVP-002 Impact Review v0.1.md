# DOC-MVP-IMPL v0.1 / BL-MVP-002 Impact Review v0.1

## 1. Review情報

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール MVP |
| 対象文書 | DOC-MVP-IMPL / Implementation Plan v0.1 |
| Review対象Baseline | BL-MVP-002 |
| Review種別 | Baseline Change Impact Review |
| 実施日 | 2026-09-15 |
| 判定 | **AFFECTED / REVISION REQUIRED** |
| 推奨次Revision | **DOC-MVP-IMPL v0.2** |

---

## 2. Review目的

DOC-MVP-IMPL v0.1は、以下をExecution Baselineとして作成・承認されている。

```text
BL-MVP-001
```

その後、DF-P1-001対応によりDOC-MVP-DESおよびDOC-MVP-TESTSPECが更新され、
新しいCurrent Approved Baselineとして以下が承認された。

```text
BL-MVP-002
```

本Reviewでは、BL-MVP-002へのBaseline更新がDOC-MVP-IMPL v0.1へ与える影響を確認し、

```text
Affected
Not Affected
Needs Revision
```

を判定する。

---

## 3. Baseline差分

### BL-MVP-001

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.7
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.3
```

### BL-MVP-002

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

差分：

| Document ID | BL-MVP-001 | BL-MVP-002 | Impact |
|---|---:|---:|---|
| DOC-MVP-REQ | v0.1.8 | v0.1.8 | None |
| DOC-MVP-DES | v0.1.7 | v0.1.8 | Semantic Design Change |
| DOC-TS-A | v0.4 | v0.4 | None |
| DOC-MVP-TESTSPEC | v0.1.3 | v0.1.4 | Semantic Test Definition Update |

---

## 4. BL-MVP-002で追加・変更された意味

### 4.1 Design

DOC-MVP-DES v0.1.8では、DF-P1-001対応としてWorkbook Relative Path ResolutionがSemantic Changeされた。

主な内容：

```text
d.docs.live.net Web URL
↓
OneDrive Local Root候補取得
↓
Local Workbook Directoryの存在確認
↓
一意なLocal Root決定
↓
Windows Local Path生成
```

関連：

- Design §9.3
- modSettingsData責務
- §25.1～25.3 Sequence
- D17 Workbook Relative Path Resolution

RequirementsへのImpactはない。

### 4.2 Test Specification

DOC-MVP-TESTSPEC v0.1.4では、既存Test IDを維持したまま以下を追加・明確化した。

- MTS-TPL-001 Windows Local Path Variant
- MTS-TPL-001 OneDrive Web URL Variant
- OneDrive Local Root候補0件
- Local Workbook Path候補0件
- 異なる候補複数件
- ConfigurationError
- Fail Fast
- Message / Target Evidence
- MTS-ERR-001 Path Resolution Error

Test Case総数は69件のまま。

---

## 5. DOC-MVP-IMPL v0.1内の直接影響

DOC-MVP-IMPL v0.1には `BL-MVP-001` の固定参照が14箇所存在する。

### 5.1 Revision必須箇所

| 対象 | 現行 | 判定 | 推奨対応 |
|---|---|---|---|
| §1 文書情報 / Execution Baseline | BL-MVP-001 | AFFECTED | BL-MVP-002へ更新 |
| §1 v0.1作成概要 | BL-MVP-001前提 | AFFECTED | v0.2更新概要を追加。v0.1履歴自体は保持 |
| §2 目的 | BL-MVP-001で承認されたMVP | AFFECTED | BL-MVP-002へ更新 |
| §4.1 Execution Baseline | BL-MVP-001 Manifest | AFFECTED | BL-MVP-002 Manifestへ更新 |
| §4.2 Baseline変更ルール | BL-MVP-001を自動更新しない | AFFECTED | Current Execution Baselineを直接書換えない、へ一般化またはBL-MVP-002へ更新 |
| §4.3 Technical Spike B/C | BL-MVP-001基準 | AFFECTED | BL-MVP-002でもNOT REQUIRED維持を明示 |
| IMP-R01 Baseline Driven | BL-MVP-001基準 | AFFECTED | BL-MVP-002基準へ更新 |
| P0 Input | BL-MVP-001 | AFFECTED | BL-MVP-002へ更新 |
| P0 Exit Criteria | BL-MVP-001とのConflictなし | AFFECTED | BL-MVP-002とのConflictなしへ更新 |
| §12.4 Test Candidate Build | Baseline ID = BL-MVP-001 | AFFECTED | BL-MVP-002へ更新 |
| §13.6 Baseline変更 | BL-MVP-001を直接書き換えない | AFFECTED | Current Execution Baselineを直接書換えない、へ一般化 |
| §14.1 Implementation Entry Criteria | BL-MVP-001 Approved | AFFECTED | BL-MVP-002 Approvedへ更新 |
| Appendix A Phase Flow | BL-MVP-001 → P0 | AFFECTED | BL-MVP-002 → P0へ更新 |

※ v0.1作成概要に含まれるBL-MVP-001はHistorical Recordとして残してもよい。
ただしv0.2のCurrent Execution Contextと混同しないよう、v0.2更新概要を追加する。

---

## 6. Plan内容へのSemantic Impact

### 6.1 Phase構成

判定：

```text
NOT AFFECTED
```

以下のPhase構成は維持できる。

```text
P0 Foundation
P1 Walking Skeleton
P2 Scan / Sync
P3 Configuration / UserForm
P4 Validation / Formatting
P5 Full Mail Generation
P6 Error / Safety / Integration
P7 MVP Test Readiness
```

DF-P1-001は新Phase追加を必要としない。

---

### 6.2 P1 Walking Skeleton Objective

判定：

```text
NOT AFFECTED
```

P1の目的：

```text
Excel
↓
OFT
↓
Outlook
↓
WordEditor
↓
Render
↓
Unresolved Check
↓
Display
```

は変更不要。

P1-01でPath Resolutionが解決されたため、P1-02以降の目的はそのまま維持できる。

---

### 6.3 P1 Related Test Area

判定：

```text
NOT AFFECTED
```

Implementation Planは既に以下を参照している。

```text
MTS-TPL-001
```

Test Specification v0.1.4ではTest ID自体を変更せず、MTS-TPL-001のExpected / Variantを拡張している。

したがってImplementation Plan側で新しいTest IDを追加する必要はない。

---

### 6.4 Module Mapping

判定：

```text
NOT AFFECTED
```

DF-P1-001対応は `modSettingsData.ResolveWorkbookRelativePath` の責務として実装され、
新規Path専用Moduleは追加されていない。

既存Module構成：

```text
modSettingsData
modOutlookAdapter
modMailApplication
...
```

を維持できる。

---

### 6.5 Route W / WordEditor

判定：

```text
NOT AFFECTED
```

DOC-TS-A v0.4は変更なし。

以下も変更なし。

```text
Route W
Inspector.WordEditor
Range.Find
Range.Text
```

したがってP1-02 Inspector / WordEditor Connectionの目的・方針は変更不要。

---

## 7. Technical Spike B / C Impact

DOC-MVP-IMPL v0.1では、BL-MVP-001を基準としてTechnical Spike B / CをNOT REQUIREDとしている。

BL-MVP-002では、

- Requirement変更なし
- Route W変更なし
- DOC-TS-A変更なし
- DF-P1-001はTV-P1-001で技術成立性確認済み
- Production実装済み
- Regression PASS済み
- DF-P1-001 CLOSED

である。

したがって本Impact Reviewでは、

```text
Technical Spike B:
NOT REQUIRED維持

Technical Spike C:
NOT REQUIRED維持
```

と判定する。

BL-MVP-002への移行だけを理由としてSpike B / Cを再Openしない。

---

## 8. P0 / CP-P0への影響

### 判定

```text
CP-P0:
REOPEN NOT REQUIRED
```

理由：

DF-P1-001はP1-01で検出されたが、対象Production責務は `modSettingsData.ResolveWorkbookRelativePath` にある。

その後、

```text
TV-P1-001 PASS
Design v0.1.8反映
Production実装
Resolver Smoke Test PASS
P1-01 Regression PASS
DF-P1-001 CLOSED
```

まで完了している。

よってP0 Phaseそのものを再Openして再完了判定する必要はない。

ただし、新Workbook再構築後のP0 Integration RegressionはImplementation Health Checkとして別途推奨する。

これはBL-MVP-002 Impact ReviewのBlocking条件ではない。

---

## 9. Change Classification

DOC-MVP-IMPLへの変更分類：

```text
Implementation Plan Impact:
AFFECTED

Revision:
REQUIRED

Recommended Version:
v0.2
```

変更の性質：

```text
Execution Baseline Update
+
Plan-level Semantic Alignment
```

Product Semantic Impact：

```text
Requirement Impact:
None

Additional Design Change:
None

Technical Decision Impact:
None

Additional Test Definition Change:
None
```

つまり、BL-MVP-002によって既に承認済みのDesign / Test DefinitionへImplementation Planを追従させるRevisionであり、
新しいProduct RequirementやArchitectureを追加するRevisionではない。

---

## 10. v0.2で変更すべき内容

### Must

1. Document Versionをv0.2へ更新
2. Execution BaselineをBL-MVP-002へ更新
3. BL-MVP-002 Manifestを反映
4. §2 PurposeのBaseline参照更新
5. §4.2 Baseline変更ルールを現行Baselineに整合
6. §4.3 Technical Spike B / CをBL-MVP-002基準で再確認済みとする
7. IMP-R01をBL-MVP-002基準へ更新
8. P0 InputのBaselineをBL-MVP-002へ更新
9. P0 Exit CriteriaのConflict対象をBL-MVP-002へ更新
10. Test Candidate BuildのBaseline IDをBL-MVP-002へ更新
11. §13.6 Baseline変更ルールをBL-MVP-002 / Current Execution Baselineへ更新
12. §14.1 Entry CriteriaをBL-MVP-002 Approvedへ更新
13. Appendix Aの起点をBL-MVP-002へ更新
14. v0.2更新概要を追加

### Should

以下は文書重複を避けるため、詳細仕様をImplementation Planへ複製しない。

- OneDrive環境変数一覧
- Root候補判定アルゴリズム
- d.docs.live.net URL解析詳細
- Path Resolution Failure Variant詳細

これらはDOC-MVP-DES / DOC-MVP-TESTSPECをSource of Truthとする。

---

## 11. 変更不要な内容

以下はv0.2でも原則維持する。

- Scope / Out of Scope
- P0～P7 Phase構造
- Checkpoint体系 CP-P0～CP-P7
- Walking Skeleton First
- Incremental Integration
- Fail Fast / Fail Closed
- Phase VerificationとFormal MVP Testの分離
- No Spec-by-Implementation
- YAGNI
- Responsibility Preservation
- Module Mapping基本構造
- P1 Minimum Vertical Slice
- P1-02 Inspector / WordEditor方針
- P2～P7のObjective / Dependency
- Implementation Finding Flow
- Formal MVP TestをP7後に実施する方針
- Build ID / Commit ID / Evidence管理方針

---

## 12. Impact Review Gate

| Review項目 | Result |
|---|---|
| Current Baseline変更 | AFFECTED |
| Fixed BL-MVP-001 Reference | AFFECTED |
| Design v0.1.8 Change | AFFECTED |
| Test Spec v0.1.4 Change | AFFECTED |
| Phase Structure | NOT AFFECTED |
| Module Structure | NOT AFFECTED |
| Route W / WordEditor | NOT AFFECTED |
| Requirements | NOT AFFECTED |
| Technical Spike A | NOT AFFECTED |
| Technical Spike B/C要否 | NOT REQUIRED維持 |
| P1-02 Objective | NOT AFFECTED |
| Implementation Plan Revision | **REQUIRED** |

---

# 13. 最終判定

```text
DOC-MVP-IMPL v0.1
BL-MVP-002 Impact:

AFFECTED
```

理由：

1. v0.1はExecution BaselineをBL-MVP-001へ固定している
2. BL-MVP-001はSupersededとなった
3. Current Approved BaselineはBL-MVP-002である
4. Design v0.1.8 / Test Specification v0.1.4にSemantic Changeがある
5. Implementation Plan自身のBaseline Driven Ruleと矛盾したままP1-02へ進むことはできない

したがって、

```text
DOC-MVP-IMPL v0.2
```

を作成し、Execution BaselineをBL-MVP-002へ整合させる。

ただし、

```text
Phase構成変更
新Requirement追加
Architecture変更
Route W再選定
Test Case追加
```

は不要。

---

## 14. 次Action

```text
DOC-MVP-IMPL v0.1
↓
BL-MVP-002 Impact Review = AFFECTED
↓
DOC-MVP-IMPL v0.2 Candidate作成
↓
Plan Consistency Review
↓
Approved
↓
Registry更新
↓
必要に応じて新Workbook P0 Integration Regression
↓
P1-02 Inspector / WordEditor Connection
```
