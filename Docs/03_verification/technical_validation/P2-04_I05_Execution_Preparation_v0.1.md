# P2-04 Remaining Verification — I05 Definition Read Failure 実行準備 v0.1

## 1. I05目的

I05ではP2-04 Manual Sync Orchestrationについて、Current OFTのScan成功後に
VariableDefinition Data AccessがFailureした場合、後続Sync処理へ進まないことを確認する。

Approved Expected：

```text
Template Scan = Success
GetAllVariableDefinitions = Failure
BuildSyncDiff = Not Executed
ApplySyncDiff = Not Executed
syncDiffResult = Nothing
No persistence update
```

Fixture：

```text
tblVariableDefinition
Status
↓
Status_TEST_BROKEN
```

## 2. Production Sequence

現行 `ExecuteManualSync` は以下の順序。

```text
ScanCurrentTemplate
↓
templateScanResult Publish
↓
Invalid Candidate Gate
↓
GetAllVariableDefinitions
↓
BuildSyncDiff
↓
ApplySyncDiff
↓
syncDiffResult Publish
```

したがってDefinition Read Failure時は、

```text
templateScanResult = Published
InvalidCandidates.Count = 0
GetAllVariableDefinitions = Failure
syncDiffResult = Nothing
VariableDefinition Data = Unchanged
```

となることを確認する。

## 3. Safety Strategy

v0.3 Harnessでは以下の安全策を入れる。

### 3.1 Normal Template Preflight

列名を変更する前にCurrent OFTを独立Scanし、

```text
OFT exists
Template Read = Success
ScanTemplate = Success
InvalidCandidates.Count = 0
```

を確認する。

### 3.2 Broken Column Preflight

以下を確認してからFixtureを作る。

```text
Status exists
Status_TEST_BROKEN does not exist
```

### 3.3 Direct Definition Read Safety Check

`Status -> Status_TEST_BROKEN` 変更直後に、

```vb
GetAllVariableDefinitions
```

を直接呼び、

```text
Failure
```

になることを確認する。

もしUnexpected Successになった場合：

```text
ExecuteManualSync = NOT EXECUTED
Status column = RESTORED
RESULT = ABORTED
```

とする。

これにより、Fixture不成立のままNormal Syncが走ることを防ぐ。

## 4. Harness

更新版：

```text
modP2_04RemainingVerification_v0.3_CP932.bas
```

同じModule名 `modP2_04RemainingVerification` を使用する。

手順：

1. VBE上のv0.2 ModuleをRemove
2. v0.3をImport
3. `Debug -> Compile VBAProject`

Production Moduleは変更しない。

## 5. I05 Entry Point

```vb
TestP204I05DefinitionReadFailure
```

OFTはBaseline状態のまま使用する。
VariableDefinitionを手作業で変更しない。

HarnessがStatus列名を自動変更・復元する。

## 6. Expected Evidence

代表Expected：

```text
PASS  I05-00 Normal template preflight
PASS  I05-01 Status column preflight
PASS  I05-02 VariableDefinition Before snapshot
PASS  I05-03 Broken Status column applied
PASS  I05-04 Original Status column unavailable
PASS  I05-05 Direct definition read returns COperationResult
PASS  I05-06 Direct GetAllVariableDefinitions = Failure
PASS  I05-07 Failed definition read publishes no collection
PASS  I05-08 ExecuteManualSync returns COperationResult
PASS  I05-09 ExecuteManualSync = Failure
PASS  I05-10 templateScanResult = Published
PASS  I05-11 templateScanResult is Dictionary
PASS  I05-12 InvalidCandidates.Count = 0
PASS  I05-13 syncDiffResult = Nothing
PASS  I05-14 VariableDefinition After snapshot
PASS  I05-15 VariableDefinition Data Before = After
PASS  I05-16 Status column restored

FAIL Count = 0
Overall = PASS
```

ErrorType / Target / Messageは今回のApproved Expectedに固定されていないため、
Harnessはログへ出力するが文字列一致をPASS条件にはしない。

重要なのは、

```text
Template Scan Success
↓
Definition Read Failure
↓
syncDiffResult Nothing
↓
Data unchanged
```

というOrchestration Boundary。

## 7. 実行後確認

Immediate Windowで必ず：

```text
PASS  I05-16 Status column restored
Restored Column Name = Status
```

を確認する。

Excel TableのHeaderも目視で、

```text
Status
```

へ戻っていることを確認してよい。

## 8. Test Scope

これはImplementation VerificationでありFormal MVP Test Resultではない。

Production変更：

```text
NONE
```

を前提として実行する。
