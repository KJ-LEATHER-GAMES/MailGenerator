# DOC-MVP-DES v0.1.10 Candidate

# ×

# DOC-MVP-TESTSPEC v0.1.6 Candidate

# Cross-document Consistency Review v0.1

## 1. Review Result

```text
RESULT:
PASS WITH CORRECTIONS
```

```text
Requirement Gap:
NONE

Design Reopen:
NOT REQUIRED

New Design Decision:
NONE

New Test ID:
NONE

Blocking Semantic Conflict:
NONE

Test Definition Correction:
3
```

本Reviewでは新しい仕様を決定しない。

確認対象は、`DOC-MVP-DES v0.1.10 Candidate` で確定したDetection History / Sync Metadataの各状態・Target State・Failure Expectedが、`DOC-MVP-TESTSPEC v0.1.6 Candidate` へ欠落なく写像されているかのみとする。

---

# 2. Review Basis

現行Designでは、Existing / Reactivated / UnusedについてMetadata更新規則をDesign §7.4 / §15で管理している。v0.1.9時点ではExisting / Reactivatedの `FirstDetectedAt` は単純に既存値保持であり、今回v0.1.10 CandidateでDetection History Bootstrap Ruleを追加する対象となった。

現行Test Specificationでは、

```text
MTS-SYNC-003 Existing設定保持
MTS-SYNC-004 Unused化
MTS-SYNC-005 Reactivated
MTS-SYNC-011 Sync metadata更新
```

が該当責務を持つ。

---

# 3. State / Expected Traceability Matrix

| Design State / Rule                               | Test Mapping                            | Result               |
| ------------------------------------------------- | --------------------------------------- | -------------------- |
| New                                               | MTS-SYNC-011 Variant A / 既存MTS-SYNC-002 | PASS                 |
| Existing / Initialized                            | MTS-SYNC-003 A / MTS-SYNC-011 B         | PASS                 |
| Existing / Uninitialized / Locationあり             | MTS-SYNC-003 B / MTS-SYNC-011 C         | PASS                 |
| Existing / Uninitialized / Location Blank         | MTS-SYNC-003 C / MTS-SYNC-011 D         | PASS                 |
| Reactivated / Initialized                         | MTS-SYNC-005 A / MTS-SYNC-011 E         | PASS                 |
| Reactivated / Uninitialized                       | MTS-SYNC-005 B / MTS-SYNC-011 F         | PASS                 |
| Unused化 / Initialized                             | MTS-SYNC-004 A / MTS-SYNC-011 G         | PASS                 |
| Unused化 / Uninitialized                           | MTS-SYNC-004 B / MTS-SYNC-011 H         | PASS                 |
| Already-Unused / Initialized                      | MTS-SYNC-011 I                          | PASS                 |
| Already-Unused / Uninitialized                    | MTS-SYNC-011 J                          | PASS                 |
| First Blank / Last Date                           | MTS-SYNC-011 K                          | PASS WITH CORRECTION |
| First Date / Last Blank                           | MTS-SYNC-011 L                          | PASS WITH CORRECTION |
| Invalid non-blank Date value                      | MTS-SYNC-011 M                          | PASS WITH CORRECTION |
| Common SyncTimestamp                              | MTS-SYNC-011 N                          | PASS                 |
| TemplateLocation / Detection History independence | MTS-SYNC-003 B/C + MTS-SYNC-011 C/D     | PASS                 |
| Unused時Timestamp非生成                               | MTS-SYNC-004 B + MTS-SYNC-011 H/J       | PASS                 |
| Existing user configuration preservation          | MTS-SYNC-003                            | PASS WITH CORRECTION |
| Reactivated user configuration reuse              | MTS-SYNC-005                            | PASS                 |
| Unused user configuration preservation            | MTS-SYNC-004                            | PASS                 |
| Existing canonical VariableName preservation      | 既存MTS-SYNC-007                          | PASS                 |
| Invalid / Partial → Persistenceなし                 | MTS-SYNC-011 K/L/M                      | PASS                 |
| Invalid / Partial → Error Result / Stop           | MTS-SYNC-011 K/L/M                      | PASS                 |
| Invalid / Partial → UI通知                          | Explicit Mappingなし                      | CORRECTION REQUIRED  |

Existing時のCanonical VariableName保持については、既存 `MTS-SYNC-007` がExisting判定と正式表記保持を明示しているため、新Variant追加は不要である。

---

# 4. PASS項目

## 4.1 Detection History State

Designで定義した、

```text
Initialized
Uninitialized
Invalid / Partial
```

の3系統すべてがTest側へ存在する。

Initialized / Uninitializedについては、Existing / Reactivated / Unused / Already-UnusedのTarget StateまでTest Variantへ展開されている。

判定：

```text
PASS
```

---

## 4.2 TemplateLocationとの独立性

Design：

```text
TemplateLocation State
≠
Detection History State
```

に対し、Testでは、

```text
Locationあり + Blank / Blank
Location Blank + Blank / Blank
```

をExistingで比較するVariantが存在する。

したがって、`TemplateLocation` の値だけでDetection History Stateを判定しないことを直接確認可能である。

判定：

```text
PASS
```

---

## 4.3 Existing Bootstrap

Design：

```text
Existing
+
Detection History Uninitialized
↓
TemplateLocation = Current
Status           = Active
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

に対して、

```text
MTS-SYNC-003 Variant B / C
MTS-SYNC-011 Variant C / D
```

が対応する。

判定：

```text
PASS
```

---

## 4.4 Reactivated Bootstrap

Design：

```text
Reactivated
+
Detection History Uninitialized
↓
Status           = Active
TemplateLocation = Current
FirstDetectedAt  = TSync
LastDetectedAt   = TSync
```

に対して、

```text
MTS-SYNC-005 Variant B
MTS-SYNC-011 Variant F
```

が対応する。

判定：

```text
PASS
```

---

## 4.5 Unused Bootstrap

Design：

```text
Unused
+
Detection History Uninitialized
↓
TemplateLocation = Existing
Status           = Unused
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

に対して、

```text
MTS-SYNC-004 Variant B
MTS-SYNC-011 Variant H
```

が対応する。

Timestampを新規生成しないExpectedも明示されている。

判定：

```text
PASS
```

---

## 4.6 Already-Unused

Designで定義したNo-opについて、

```text
Initialized
Uninitialized
```

の双方を、

```text
MTS-SYNC-011 Variant I
MTS-SYNC-011 Variant J
```

が直接確認する。

判定：

```text
PASS
```

---

## 4.7 Common SyncTimestamp

Designの、

```text
同一Sync内では1つのSyncTimestampを共通使用
```

に対し、MTS-SYNC-011 Variant Nが、

```text
New
Existing / Initialized
Existing / Uninitialized
Reactivated / Initialized
Reactivated / Uninitialized
```

を同一Syncに混在させて確認する。

Unused / Already-Unusedについても「Timestampを更新しない」と明示されている。

判定：

```text
PASS
```

---

# 5. Correction Findings

## CR-TS-001

### Invalid / Partial Variantの適用範囲が明示されていない

DesignではDetection HistoryがInvalid / Partialの場合、

```text
Existing
Reactivated
Unused
Already-Unused
```

の正常Target Stateへ進ませずFailureとする。

一方、MTS-SYNC-011 Variant K / L / Mでは、

```text
First Blank / Last Date
First Date / Last Blank
Invalid non-blank
```

というDetection History条件は定義されているが、

```text
Status
Current Template Presence
Sync Classification
```

が明示されていない。

このため、Test Definition単独では、

```text
Invalid / Partial Guardが
Classification非依存の共通Guardとして確認されるのか
```

が明確でない。

### Required Correction

新しいExpectedは追加しない。

K / L / Mについて、

```text
Design §7.4 / §25.1に従い、
Sync Classificationにかかわらず
Invalid / Partial Detection HistoryはFailureとする
```

ことをTest適用範囲として明示する。

または、該当VariantがDesign上の全対象Classificationへ適用されることを明記する。

```text
Classification-specific Design Change:
NONE

New Test ID:
NONE
```

---

## CR-TS-002

### MTS-SYNC-003 Variant Cでユーザー設定保持Expectedが明示されていない

Design §15.4ではExistingについて、

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

をDetection History StateやTemplateLocation Stateにかかわらず保持する。

MTS-SYNC-003 Variant A / Bではユーザー設定保持が明示されている。

一方Variant C：

```text
TemplateLocation = Blank
FirstDetectedAt  = Blank
LastDetectedAt   = Blank
```

では、Metadata Target Stateは明示されているが、ユーザー設定保持のExpectedがVariant内に明記されていない。

### Required Correction

Variant Cにも、

```text
既存ユーザー設定をすべて保持する
```

という既存MTS-SYNC-003共通Expectedを明示する。

新しい挙動ではなく、既存Design Expectedの写像補完のみとする。

---

## CR-TS-003

### Invalid / Partial Failure時のUI通知がTestへ明示写像されていない

Candidate Design §25.1では、

```text
Detection History State確認
↓
Invalid / Partialあり？
├─ Yes → Error Result → UI通知 → Stop
```

と定義されている。

MTS-SYNC-011 Variant K / L / Mでは、

```text
Sync Result = Failure
VariableDefinition Persistence = NONE
```

までは確認対象となっている。

しかし、

```text
UI通知
```

はExpectedに含まれていない。

既存MTS-ERR-001はDesign §24 / §25.1〜25.3をTraceability対象とし、Errorについて「何が問題か」「何を確認すべきか」をユーザーが理解できることを確認するTestである。

ただし既存の代表Error一覧には、

```text
Invalid / Partial Detection History
```

が明示されていない。

`Configuration不足` が本状態を含むとは現在のTest Specification本文からは断定できない。

### Required Correction

Designは変更しない。

Test Specification側で、

```text
Invalid / Partial Detection History Failure
```

について、既存MTS-ERR-001へ明示的に接続するか、MTS-SYNC-011からMTS-ERR-001のError UI Evidenceを参照することを明記する。

確認するExpectedは既存Designどおり、

```text
Error Result
↓
UI通知
↓
Stop
```

であり、新しいErrorTypeやMessage仕様は追加しない。

既存Designでも、予見可能なErrorはOperation ResultからUIへ渡し、ユーザー表示する基本方針となっている。

---

# 6. Non-Findings

以下はFindingとしない。

| 項目                                  | 判定理由                                          |
| ----------------------------------- | --------------------------------------------- |
| §8.3 Baseline VariableDefinition未変更 | MetadataはSync Testで別途確認する既存方針と一致              |
| 新規MTS IDなし                          | 既存4 Test Caseの責務内でCoverage可能                  |
| MTS-SYNC-011へのVariant集中             | Metadata横断Testとして既存責務と一致                      |
| ErrorType未固定                        | Candidate Designでも新ErrorTypeを追加していない          |
| Existing Canonical Name             | 既存MTS-SYNC-007でCoverage済み                     |
| Formal Test未実施                      | Test Specification RevisionでありTest Resultではない |

---

# 7. Coverage Assessment

Correction適用前：

```text
Design State Coverage:
PASS

Metadata Target State Coverage:
PASS

Bootstrap Coverage:
PASS

TemplateLocation Independence:
PASS

Common Timestamp Coverage:
PASS

Fail Closed Persistence Coverage:
PASS

User Configuration Condition Coverage:
PARTIAL

Invalid / Partial Applicability:
AMBIGUOUS

Error UI Coverage:
PARTIAL
```

したがって現時点では、

```text
Cross-document Consistency:
PASS WITH CORRECTIONS
```

とする。

---

# 8. Required Corrections

必要な補正はTest Specification側のみ。

| ID        | 対象                         | Correction                                       |
| --------- | -------------------------- | ------------------------------------------------ |
| CR-TS-001 | MTS-SYNC-011 K/L/M         | Invalid / Partial GuardのClassification非依存適用範囲を明示 |
| CR-TS-002 | MTS-SYNC-003 Variant C     | Existingユーザー設定保持Expectedを明示                      |
| CR-TS-003 | MTS-SYNC-011 / MTS-ERR-001 | Invalid / Partial FailureのUI通知Evidenceを明示接続      |

```text
DOC-MVP-DES v0.1.10 Candidate:
CHANGE NOT REQUIRED

DOC-MVP-REQ v0.1.9:
CHANGE NOT REQUIRED

New Requirement Gap:
NONE

New Design Gap:
NONE

New Test Case:
NONE
```

---

# 9. Gate Decision

```text
DOC-MVP-DES v0.1.10 Candidate
×
DOC-MVP-TESTSPEC v0.1.6 Candidate

Cross-document Consistency Review:

PASS WITH CORRECTIONS
```

Blocking Semantic Conflict：

```text
NONE
```

Correction Scope：

```text
Test Definition only
```

Correction適用後に再確認する対象は、

```text
CR-TS-001
CR-TS-002
CR-TS-003
```

のみとする。

新たなDesign ReviewやRequirement Reviewは不要。

3件のCorrectionが反映されれば、

```text
Cross-document Consistency:
PASS

Known Mapping Gap:
NONE
```

へ移行可能である。
