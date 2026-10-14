# P2-04 Remaining Verification — I06 BuildSyncDiff Failure 実行準備 v0.1

## 1. I06目的

Approved Expected：

```text
Template Scan = Success
GetAllVariableDefinitions = Success
BuildSyncDiff = Failure
ApplySyncDiff = Not Executed
syncDiffResult = Nothing
```

Fixture：

```text
ModelName
Status = InvalidStatus
```

## 2. Fixture成立根拠

VariableDefinition Data AccessはCurrent DefinitionをCarrierへ読み出す責務であり、
設定内容そのものの妥当性をStatus = Active / Unusedに限定してRead Failureへ変換する責務ではない。

P2-02 Sync Diff CoreではTechnical Negativeとして、

```text
N5 Unknown Status
PASS
```

が既に成立している。

したがって、

```text
Status = InvalidStatus
```

は、

```text
GetAllVariableDefinitions = Success
BuildSyncDiff = Failure
```

を作るI06 Fixtureとして適切。

## 3. Safety Strategy

v0.4 Harnessでは `ExecuteManualSync` 前に次を確認する。

```text
Normal Template Scan = Success
↓
ModelName.Status = InvalidStatus
↓
GetAllVariableDefinitions = Success
↓
CarrierにModelName / InvalidStatusが存在
↓
Direct BuildSyncDiff = Failure
```

Direct BuildがUnexpected Successの場合：

```text
ExecuteManualSync = NOT EXECUTED
ModelName.Status = RESTORED
RESULT = ABORTED
```

とする。

## 4. Persistence Evidence

I06ではTest自身がStatusを書き換えるため、単純な

```text
Original Before = Execution After
```

比較は使えない。

代わりに：

```text
Original State
↓
Fixture State (InvalidStatus)
↓
ExecuteManualSync
↓
Post-execution State
```

について、

```text
Fixture State = Post-execution State
```

を確認する。

これはManual Syncによる追加Persistenceが発生していないEvidence。

復元後さらに、

```text
Original State = Restored State
```

を確認し、Test residueなしを証明する。

## 5. Harness

更新版：

```text
modP2_04RemainingVerification_v0.4_CP932.bas
```

同じModule名：

```text
modP2_04RemainingVerification
```

を使用する。

手順：

1. VBE上のv0.3.1 ModuleをRemove
2. v0.4をImport
3. `Debug -> Compile VBAProject`

Production変更は不要。

## 6. Entry Point

```vb
TestP204I06BuildSyncDiffFailure
```

OFT・VariableDefinitionを手作業で変更しない。
HarnessがModelName.Statusを自動変更・復元する。

## 7. Expected Evidence

```text
PASS  I06-00 Normal template preflight
PASS  I06-01 Target Status cell preflight
PASS  I06-02 Original VariableDefinition snapshot
PASS  I06-03 Invalid Status fixture applied
PASS  I06-04 Fixture VariableDefinition snapshot
PASS  I06-05 Definition read returns COperationResult
PASS  I06-06 GetAllVariableDefinitions = Success
PASS  I06-07 Definition carrier contains ModelName / InvalidStatus
PASS  I06-08 Direct TemplateScanResult obtained
PASS  I06-09 Direct BuildSyncDiff returns COperationResult
PASS  I06-10 Direct BuildSyncDiff = Failure
PASS  I06-11 ExecuteManualSync returns COperationResult
PASS  I06-12 ExecuteManualSync = Failure
PASS  I06-13 templateScanResult = Published
PASS  I06-14 templateScanResult is Dictionary
PASS  I06-15 InvalidCandidates.Count = 0
PASS  I06-16 syncDiffResult = Nothing
PASS  I06-17 Post-execution VariableDefinition snapshot
PASS  I06-18 Fixture State = Post-execution State
PASS  I06-19 ModelName.Status restored
PASS  I06-20 Restored VariableDefinition snapshot
PASS  I06-21 Original State = Restored State

FAIL Count = 0
Overall = PASS
```

## 8. Error Detail

BuildSyncDiffの具体的なErrorType / Target / Messageはログ出力するが、
I06 Approved Expectedでは具体文字列を固定していないためPASS条件にはしない。

重要なBoundary：

```text
Template Scan Success
Definition Read Success
BuildSyncDiff Failure
ApplySyncDiff Not Executed
syncDiffResult Nothing
No Persistence Beyond Fixture
```

## 9. 実行後

必ず以下を確認する。

```text
PASS  I06-19 ModelName.Status restored
PASS  I06-21 Original State = Restored State
```

Test ArtifactによるWorkbook residueを残さない。
