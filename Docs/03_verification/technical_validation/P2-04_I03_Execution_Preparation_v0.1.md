# P2-04 Remaining Verification — I03 実行準備 v0.1

## 1. 現行コード確認結果

### modSyncApplication_P2-04_v0.1

`ExecuteManualSync` のI03関連Production Sequenceは次のとおり。

```text
ScanCurrentTemplate
↓
candidateTemplateScanResult取得
↓
templateScanResultへ公開
↓
ValidateSyncScanGate
↓
InvalidCandidates.Count > 0
→ Failure
→ GetAllVariableDefinitionsへ進まない
→ BuildSyncDiffへ進まない
→ ApplySyncDiffへ進まない
→ syncDiffResultはNothingのまま
```

したがって、I03 ExpectedとProduction構造は整合している。

## 2. 既存P2-04 Test Module確認結果

既存Public Entry Point：

- `TestP204ManualSyncIntegrationNormal`
  - I01 Happy Path
  - I02 Common SyncTimestamp
  - 直接再利用可能
- `RunP204ManualSyncDiagnostic`
  - Negative / Warm / Cold FixtureでProduction `ExecuteManualSync` を呼ぶ汎用診断
  - I03～I10のトラブルシュートには再利用可能
  - ただし自動PASS/FAIL判定、VariableDefinition Before/After、Lifecycle Count判定は不足

## 3. I03～I12 再利用分類

| Case | 既存Entry Point再利用 | 判定 |
|---|---|---|
| I03 Invalid Candidate | `RunP204ManualSyncDiagnostic` は診断用に部分再利用 | 追加Harness必要 |
| I04 OFT Missing | 同上 | 後続で追加Harness必要 |
| I05 Definition Read Failure | 同上 | 後続で追加Harness必要 |
| I06 BuildSyncDiff Failure | 同上 | 後続で追加Harness必要 |
| I07 ApplySyncDiff Failure | 同上 | 後続で追加Harness必要 |
| I08 Retry Fresh State | 単発Diagnosticだけでは不足 | 後続で専用Harness必要 |
| I09 Warm Lifecycle | DiagnosticでProduction実行は可能 | Lifecycle Evidence補完必要 |
| I10 Cold Lifecycle | DiagnosticでProduction実行は可能 | Lifecycle Evidence補完必要 |
| I11 Manual Only | 直接対応Entry Pointなし | Manual/専用Harness必要 |
| I12 Contract Regression | 既存P2-01/P2-02/P2-03 Entry Pointを再利用 | 新P2-04 Harness不要 |

I12既存Entry Point：

```vb
TestP201FullTemplateScannerCore
TestP201FullTemplateScannerBaselineOftIntegration
TestP201MtsScan005RecipientExclusionIntegration

TestP202SyncDiffV013RegressionSuite

TestP203SyncPersistenceV012RegressionSuite

TestP202P203BootstrapProductionCompatibility
```

## 4. 今回追加するHarness

ファイル：

```text
modP2_04RemainingVerification_v0.1_CP932.bas
```

Entry Point：

```vb
TestP204I03InvalidCandidate
```

I03 Expected：

```text
ExecuteManualSync = Failure
templateScanResult = Published
InvalidCandidates.Count > 0
syncDiffResult = Nothing
VariableDefinition Before = After
```

### Safety Preflight

Test実行前に現行OFTを独立Scanする。

```text
InvalidCandidates.Count = 0
```

の場合は、

```text
RESULT = ABORTED
No ExecuteManualSync call
```

として停止する。

これにより、Fixture設定漏れのままNormal Syncが走ってVariableDefinitionを更新することを防止する。

## 5. I03 Fixture

Current OFTのSubjectまたはBodyへ以下を一時追加する。

```text
{{1stGate}}
```

これはVariableName Syntax：

```regex
^[A-Za-z][A-Za-z0-9_]*$
```

に違反するInvalid Candidateである。

## 6. Compile

1. `modP2_04RemainingVerification_v0.1_CP932.bas` をVBEへImport
2. `Debug`
3. `Compile VBAProject`

Expected：

```text
Compile:
PASS
```

Compile Errorが出た場合は、I03を実行せずError全文を記録する。

## 7. I03実行

Immediate Windowを表示し、次を実行。

```vb
TestP204I03InvalidCandidate
```

Expected Summary：

```text
PASS  I03-00 Invalid Candidate fixture preflight
PASS  I03-01 VariableDefinition Before snapshot
PASS  I03-02 ExecuteManualSync returns COperationResult
PASS  I03-03 ExecuteManualSync = Failure
PASS  I03-04 templateScanResult = Published
PASS  I03-05 templateScanResult is Dictionary
PASS  I03-06 InvalidCandidates.Count > 0
PASS  I03-07 syncDiffResult = Nothing
PASS  I03-08 VariableDefinition After snapshot
PASS  I03-09 VariableDefinition Before = After

FAIL Count = 0
Overall = PASS
```

## 8. 実行後

I03 Evidenceを保存した後、OFTから `{{1stGate}}` を削除してBaseline Fixtureへ戻す。

I03 PASSまではProduction変更を行わない。
