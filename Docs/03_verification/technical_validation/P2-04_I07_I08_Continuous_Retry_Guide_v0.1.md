# P2-04 I07 / I08 Continuous Retry Verification Guide v0.1

## 1. 方針

I07とI08は分離せず、1つの連続Scenarioとして実行する。

```text
I07 ApplySyncDiff Failure
↓
syncDiffResult = Nothing
↓
Protection解除
↓
ModelName.Status Active -> Unused
↓
I08 Fresh Retry
↓
ModelName = Reactivated
```

I08の主要Evidenceは `ModelName = Reactivated`。

staleなI07 CurrentDefinitions / SyncDiffResultを再利用した場合、
ModelNameはActive時の状態を基準に `Existing` となる可能性がある。
Retry時にCurrent Stateを読み直した場合は、明示的にUnusedへ変更した
ModelNameが `Reactivated` となる。

## 2. I07のFault Fixture

`VariableDefinition` Worksheetを一時Protectする。

HarnessはProtection中にも、

```text
GetAllVariableDefinitions = Success
BuildSyncDiff = Success
ModelName = Existing
```

を直接確認してから `ExecuteManualSync` を実行する。

したがって、その後のFailureはPersistence Boundary
`ApplySyncDiff` で発生したものとしてEvidence化できる。

Expected：

```text
ExecuteManualSync = Failure
templateScanResult = Published
syncDiffResult = Nothing
```

## 3. Before = Afterの扱い

I07失敗前後のVariableDefinition比較は出力するが、

```text
SUPPORT PASS
```

または

```text
SUPPORT OBSERVATION
```

として扱い、PASS Count / FAIL Countには含めない。

P2-03はRollback / Transactionを普遍的な責務としていないため、
I07 Completion Contractには昇格させない。

今回のWorksheet Protect Fixtureでは最初のWrite前にFailureすることが期待されるため、
通常はBefore = Afterになる。

## 4. I08 Fresh Retry

I07後にHarnessがProtectionを解除し、

```text
ModelName.Status = Unused
```

へ変更する。

Production Data Accessを再度通して、

```text
CurrentDefinitions
ModelName.Status = Unused
```

を確認した後、2秒以上のTimestamp境界を作ってRetryする。

Expected：

```text
Retry ExecuteManualSync = Success
New syncDiffResult = Published
ModelName = Reactivated
ModelName != Existing
Persisted ModelName.Status = Active
Reactivated LastDetectedAt >= Retry lower-bound timestamp
```

これにより、

```text
Fresh Current State Read
Fresh BuildSyncDiff
New SyncTimestamp
New SyncDiffResult
```

をEvidence化する。

## 5. Cleanup

I08成功ではLastDetectedAt等が正当に更新されるため、
Harness終了時にI07開始前のVariableDefinition Snapshotへ復元する。

確認：

```text
Original State = Restored State
Worksheet protection state restored
```

既にWorksheetがProtect済みの場合は、
HarnessはProtection状態を勝手に変更せずABORTする。

## 6. Import / Compile

新規Standalone Module：

```text
modP2_04I07I08RetryVerification_v0.1_CP932.bas
```

既存 `modP2_04RemainingVerification` は削除不要。

Import後：

```text
Debug
-> Compile VBAProject
```

Compile PASSを確認する。

## 7. Entry Point

```vb
TestP204I07I08ContinuousRetry
```

OFT / VariableDefinitionを手作業で変更しない。

## 8. 主要Expected

I07：

```text
PASS  I07-01 Definition Read under protection = Success
PASS  I07-02 BuildSyncDiff under protection = Success
PASS  I07-03 Protected Build classifies ModelName Existing
PASS  I07-05 ExecuteManualSync = Failure
PASS  I07-06 templateScanResult = Published
PASS  I07-07 syncDiffResult = Nothing
PASS  I07-09 Worksheet protection removed
```

I08：

```text
PASS  I08-00 ModelName.Status Active -> Unused
PASS  I08-03 CurrentDefinitions contains ModelName / Unused
PASS  I08-05 Retry ExecuteManualSync = Success
PASS  I08-07 New syncDiffResult = Published
PASS  I08-08 ModelName classified Reactivated
PASS  I08-09 ModelName is not classified Existing
PASS  I08-10 Persisted ModelName.Status = Active
PASS  I08-12 Retry uses new SyncTimestamp
```

Cleanup：

```text
PASS  C00 Original VariableDefinition state restored
PASS  C02 Original State = Restored State
PASS  C03 Worksheet protection state restored
```

Final：

```text
FAIL Count = 0
Overall = PASS
```
