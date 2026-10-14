# P2-04 I12 Contract Regression Execution Guide v0.1

## 1. 目的

I12では、新しいProduction機能を追加・変更せず、P2-04までの実装・検証によって
下位Unit Contractが壊れていないことを既存Regression Suiteの再実行で確認する。

対象：

```text
P2-01 Full Template Scanner
P2-02 Sync Diff Core v0.1.3
P2-03 VariableDefinition Sync Persistence v0.1.2
P2-02 -> P2-03 Bootstrap Production Compatibility
```

I12はImplementation Verificationであり、Formal MVP Testではない。

---

## 2. 方針

I12では新しいAggregator Harnessを作らない。

理由：

```text
既存Regression Suiteそのものが現在も単独実行可能
```

であること自体がContract Regression Evidenceだから。

各既存Entry Pointを直接実行し、Immediate Windowの全文ログを残す。

---

## 3. 実行前確認

最初に：

```text
Debug
-> Compile VBAProject
```

Compile PASSを確認する。

Production Module / Regression ModuleをI12のために変更しない。

Baseline OFTおよびVariableDefinitionはI11終了時の通常状態を使用する。

---

# 4. Execution Order

以下の順番で実行する。

```text
I12-A P2-01 Scanner Regression
↓
I12-B P2-02 Sync Diff v0.1.3 Full Regression
↓
I12-C P2-03 Persistence v0.1.2 Full Regression
↓
I12-D P2-02 -> P2-03 Bootstrap Production Compatibility
```

Bootstrap Production Compatibilityは実Production Persistence Pathを通るため最後に実行する。

---

# 5. I12-A — P2-01 Full Template Scanner

## A1. Core

Entry Point：

```vb
TestP201FullTemplateScannerCore
```

Expected：

```text
PASS Count = 11
FAIL Count = 0
Overall = PASS
```

または同等の：

```text
11 PASS / 0 FAIL
```

Evidence：

```text
Candidate extraction
Valid / Invalid separation
Case-insensitive identity
Subject / Body / Both location
```

---

## A2. Baseline OFT Integration

Entry Point：

```vb
TestP201FullTemplateScannerBaselineOftIntegration
```

Expected：

```text
Overall = PASS
```

Current Baseline OFTをProduction Path経由でScanできることを確認する。

---

## A3. Recipient Exclusion Integration

Entry Point：

```vb
TestP201MtsScan005RecipientExclusionIntegration
```

Expected：

```text
Overall = PASS
```

To / CC / BCCをVariable抽出対象へ含めないContractが維持されていることを確認する。

---

# 6. I12-B — P2-02 Sync Diff Core v0.1.3

Entry Point：

```vb
TestP202SyncDiffV013RegressionSuite
```

Expected Total：

```text
PASS Count = 111
FAIL Count = 0
Overall = PASS
```

必ず全文ログを残す。

特に以下を省略しない。

## B1. Bootstrap Regression

```text
33 / 33 PASS
```

## B2. Detection History Regression

```text
43 / 43 PASS
```

## B3. Core Regression

```text
18 / 18 PASS
```

## B4. Technical Negative

```text
6 / 6 PASS
```

## B5. Contract Compatibility

```text
2 / 2 PASS
```

## B6. Date Serial Regression

```text
9 / 9 PASS
```

Total確認：

```text
33 + 43 + 18 + 6 + 2 + 9
= 111
```

重点Contract：

```text
Detection History Blank / Blank = valid Uninitialized
Partial Timestamp = invalid
Existing / Reactivated bootstrap
Unused / Already-Unused bootstrap
Unknown Status guard
P2-01 TemplateScanResult compatibility
P0 VariableDefinition carrier compatibility
Excel numeric Date Serial compatibility
String Date rejection
```

---

# 7. I12-C — P2-03 Persistence v0.1.2

Entry Point：

```vb
TestP203SyncPersistenceV012RegressionSuite
```

Expected Total：

```text
PASS Count = 46
FAIL Count = 0
Overall = PASS
```

Expected Breakdown：

## C1. Bootstrap

```text
7 / 7 PASS
```

## C2. Detection History Persistence

```text
6 / 6 PASS
```

## C3. Core

```text
12 / 12 PASS
```

## C4. Technical Negative

```text
18 / 18 PASS
```

## C5. Compatibility

```text
3 / 3 PASS
```

Total確認：

```text
7 + 6 + 12 + 18 + 3
= 46
```

重点Contract：

```text
ApplySyncDiff persistence
Existing user configuration preservation
Detection History persistence
Date Serial compatibility
P2-02 -> P2-03 production carrier compatibility
Preflight-before-write
Runtime Failure stop
```

---

# 8. I12-D — Bootstrap Production Compatibility

Entry Point：

```vb
TestP202P203BootstrapProductionCompatibility
```

Production Path：

```text
tblVariableDefinition
↓
GetAllVariableDefinitions
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
tblVariableDefinition
```

Expected：

```text
PASS Count = 29
FAIL Count = 0
Overall = PASS
```

重点Evidence：

## ModelName

```text
Status = Active
TemplateLocation = Subject
FirstDetectedAt / LastDetectedAt = initially Blank

↓

Existing

↓

FirstDetectedAt = SyncTimestamp
LastDetectedAt = SyncTimestamp
User Configuration preserved
```

## OldVariable

```text
Status = Unused
TemplateLocation = Body
FirstDetectedAt / LastDetectedAt = Blank

↓

Already-Unused

↓

No-op
Status = Unused
TemplateLocation = Body
FirstDetectedAt = Blank
LastDetectedAt = Blank
User Configuration preserved
```

---

# 9. I12 PASS Criteria

以下をすべて満たした場合、I12 PASS候補とする。

```text
Compile
PASS

P2-01 Core
11 / 11 PASS

P2-01 Baseline OFT Integration
PASS

P2-01 Recipient Exclusion Integration
PASS

P2-02 v0.1.3
111 / 111 PASS

P2-02 Bootstrap
33 / 33 PASS

P2-02 Detection History
43 / 43 PASS

P2-02 Date Serial
9 / 9 PASS

P2-03 v0.1.2
46 / 46 PASS

Bootstrap Production Compatibility
29 / 29 PASS

Unhandled Runtime Error
NONE

Regression Finding
NONE
```

---

# 10. I12 FAIL / Finding Rule

以下のどれかが起きた場合、I12を即PASS扱いしない。

```text
既存Suite Compile Failure
Expected Count不一致
FAIL > 0
Unhandled Runtime Error
既存Contract Expectedの変化
Fixture / Cleanup異常
```

まず分類する：

```text
Production Regression
Test Artifact Regression
Fixture / Environment Issue
Contract Conflict
```

I12 Failureだけを理由にProductionを即修正しない。

---

# 11. Evidence共有方法

レビュー時は、以下4ブロックをそのまま共有する。

```text
1. P2-01
   - Core
   - Baseline OFT Integration
   - Recipient Exclusion Integration

2. P2-02
   - Full v0.1.3 Regression Suite
   - Bootstrap 33/33
   - Detection History 43/43
   - Date Serial 9/9
   - Total 111/111

3. P2-03
   - Full v0.1.2 Regression Suite
   - Total 46/46

4. Bootstrap Production Compatibility
   - Total 29/29
```

P2-02については、過去にBootstrap / Detection History部分のログ省略があったため、
今回は該当箇所を含む全文Evidenceを必ず残す。

---

# 12. I12後

I12 PASS後も、直ちにP2-04 COMPLETEとはしない。

次に：

```text
I01-I12 Evidence Consolidation
↓
Static Review S01-S25
↓
Regression Evidence Finalization
↓
Production Patch Review
↓
Final Finding Assessment
↓
Active Finding = 0
Blocking Finding = 0
↓
P2-04 PASS / COMPLETE Judgment
```

を行う。

P2-04 COMPLETE後に初めて：

```text
P2-05 Fail Closed / Sync Result / Phase Integration
```

へ進む。
