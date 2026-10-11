# P1-04 Minimal Template Scanner 実施仕様 v0.1 Consistency Review v0.1

## 1. Review対象

- `P1-04 Minimal Template Scanner 実施仕様 v0.1`
- `DOC-MVP-REQ` — MVP Requirements v0.1.9
- `DOC-MVP-DES` — MVP Design v0.1.9
- `DOC-MVP-TESTSPEC` — MVP Test Specification v0.1.5
- `DOC-MVP-IMPL` — Implementation Plan v0.3
- `P1-03 Template Snapshot Boundary Completion Record v0.1`
- Execution Baseline: `BL-MVP-003`

## 2. Review目的

P1-04実施仕様が、P1 Walking Skeletonの最小Happy Pathとして過不足なく、かつP2 Scan / Syncの完成責務を先回り実装していないことを確認する。

重点確認項目：

```text
P1 / P2 Phase Boundary
Subject / BodyText Snapshot入力境界
Candidate Scan / Syntax Validation
Case Insensitive統合
Invalid Candidate責務
LocationのP2保留
Result Carrier
Public API拡張性
COM / Excel依存遮断
VariableName Hard Coding禁止
Error / OperationResult責務
Smoke Test / Completion Gate
```

## 3. Requirement Consistency

### FR-SCAN-001

RequirementはScanner対象をSubject / Bodyに限定し、To / CC / BCCを対象外としている。

P1-04 APIは入力を以下に限定する。

```text
Subject As String
BodyText As String
```

Outlook Recipient ObjectをScannerから扱わないため整合する。

判定：

```text
PASS
```

### FR-SCAN-002

Final RequirementではVariableNameとLocation（Subject / Body / Both）が必要。

P1-04ではVariableName抽出を成立させ、Location統合はP2完成版Scannerへ残す。

これはRequirement削除ではなく、Implementation Planで定義されたP1「最小Happy Path」→ P2「Scanner完成」の段階実装である。

判定：

```text
PASS
Requirement Defer to P2:
Location completion only
```

### FR-SCAN-003 / FR-VAR-005

Invalid Candidateを検出し元記述を保持するため、後続Fail Closedへ接続可能。

Scanner自身はInvalid Candidateの存在をTechnical Failureとは扱わず、後続Application / Configurationが処理停止を判断する責務分離もDesignと整合する。

判定：

```text
PASS
```

## 4. Design Consistency

Design §14の以下と一致する。

```text
Subject / BodyText
↓
Candidate Scan
↓
VariableName Validation
↓
Valid / Invalid
```

VariableName Rule：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

Case Sensitivity：

```text
Case Insensitive
```

ScannerはOutlook / Word COM Objectを保持しない。

判定：

```text
PASS
```

## 5. P1 / P2 Scope Consistency

Implementation PlanではP1：

```text
modTemplateScanner
最小Happy Path
```

P2：

```text
Candidate抽出
Syntax Validation
Valid / Invalid
Case Insensitive統合
Location統合
TemplateScanResult完成
Sync
```

と定義されている。

P1-04はCandidate Scan / Validation / Valid-Invalid / Case Insensitiveを先に実装するが、Location / SyncをP2へ残す。

P1 Walking SkeletonでVariable Hard Codingを避けるために必要な最小Scannerとして妥当。

判定：

```text
PASS
Scope Creep:
NONE
```

## 6. Test Specification Consistency

P1-04 Verificationは以下を部分的にImplementation Unit Smoke Testとして先行確認する。

```text
MTS-SCAN-001相当:
Baseline Variable抽出

MTS-SCAN-003相当:
Case Insensitive統合

MTS-SCAN-004相当:
Invalid Candidate検出
```

Formal MVP TestをこのUnitで実施した扱いにはしない。

MTS-SCAN-002 LocationはP2へ残す。

MTS-SCAN-005 To / CC / BCCは、Scanner入力をSubject / BodyTextへ限定するArchitectureで満たす方向を維持し、Formal Verificationは後工程とする。

判定：

```text
PASS
Formal Test Status:
UNCHANGED / NOT CLAIMED
```

## 7. P1-03 Boundary Consistency

P1-03 Completionで確立済み：

```text
ReadSubject
→ Subject As String

ReadBodyText
→ BodyText As String
```

P1-04はこの2 StringのみをScanner入力とし、MailItem / Inspector / WordEditor / Word Documentを再取得しない。

判定：

```text
PASS
Boundary Regression:
NONE
```

## 8. Result / Error Responsibility Review

以下の分離は妥当。

```text
COperationResult
→ Scanner技術処理の成否

InvalidCandidates
→ Template内容上のSyntax違反
```

したがって、

```text
Scanner実行成功
+
InvalidCandidatesあり
```

で `COperationResult.Success = True` とし、後続がFail Closedを判断する設計は整合する。

判定：

```text
PASS
```

## 9. Consistency Corrections

Blocking issueではないが、Approval前に以下2点を補正した。

### CR-P1-04-001 Invalid Candidate Duplicate Contract

Draftでは以下をPublic Contractとして固定していた。

```text
InvalidCandidates
→ 重複保持
```

Requirement / Test SpecificationはInvalid Candidateの重複表示・重複集約方式を規定していない。

UI表示へ波及する可能性があるため、P1-04 Public Contractでは固定しないよう補正。

変更後：

```text
InvalidCandidates
→ 元Candidate文字列保持
→ 重複表現はP1-04 Public Contractでは固定しない
```

Classification：

```text
Consistency / YAGNI Correction
Semantic Requirement Change:
NONE
```

### CR-P1-04-002 Public API Future Stability

DraftではP2でもFunction Signatureを変更しないことを強く固定していた。

P2でDesign達成上の具体的必要性が発見された場合まで拘束するのは過剰であるため、以下へ補正。

```text
P2でもPublic Signatureは原則維持
必要な変更が具体化した場合はDesign Finding
```

Classification：

```text
Consistency / Future Constraint Correction
Semantic Requirement Change:
NONE
```

## 10. Quality Gate

```text
Requirement Conflict                  : NONE
Design Conflict                       : NONE
Test Specification Conflict           : NONE
Implementation Plan Conflict          : NONE
P1-03 Boundary Conflict               : NONE
P1 / P2 Scope Conflict                : NONE
COM Dependency Leakage by Spec        : NONE
Excel Data Access Leakage by Spec     : NONE
Variable Hard Coding Allowance        : NONE
Blocking Requirement Gap              : NONE
Blocking Design Finding               : NONE
Blocking Test Gap for P1-04 Unit      : NONE
Technical Spike Reopen                : NOT REQUIRED
```

## 11. Final Decision

```text
P1-04 Minimal Template Scanner
実施仕様 v0.1

Consistency Review:
PASS

Blocking Finding:
NONE

Approved:
YES

Execution Baseline:
BL-MVP-003
```

P1-04 Production Implementationへ進行可能と判定する。
