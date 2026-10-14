# P2-04 Remaining Verification — I04 OFT Missing 実行準備 v0.1

## 1. Production Review

`modSyncApplication_P2-04_v0.1` のOFT不存在経路：

```text
ExecuteManualSync
↓
ScanCurrentTemplate
↓
GetSettingValue(TemplatePath)
↓
ResolveWorkbookRelativePath
↓
ValidateTemplateFileExists
↓
OFT Missing
→ ConfigurationError
→ ScanCurrentTemplate Failure
→ ExecuteManualSync Failure
```

`ValidateTemplateFileExists` は `CreateMailFromTemplate` より前に実行される。

したがってOFT不存在時はProduction構造上、

```text
Outlook MailItem Creation = Not Executed
Template Scan = Incomplete
GetAllVariableDefinitions = Not Executed
BuildSyncDiff = Not Executed
ApplySyncDiff = Not Executed
```

となる。

Runtime Evidenceでは以下を確認する。

```text
ExecuteManualSync = Failure
ConfigurationError / TemplatePath / Template file does not exist.
templateScanResult = Nothing
syncDiffResult = Nothing
VariableDefinition Before = After
Settings.TemplatePath = Restored
```

## 2. Harness

更新版：

```text
modP2_04RemainingVerification_v0.2_CP932.bas
```

同じVBA Module名 `modP2_04RemainingVerification` を使用するため、
v0.1 ModuleをVBEから削除してからv0.2をImportする。

Production Moduleは変更しない。

## 3. Fixture Strategy

OFTファイル自体は削除・移動・Renameしない。

HarnessがSettingsの `TemplatePath` だけを一時的に、

```text
Templates\__P2_04_I04_MISSING_<timestamp>_NN.oft
```

へ変更する。

変更前に、

1. 現在の `TemplatePath` を保存
2. Missing候補PathをResolve
3. そのFileが本当に存在しないことを確認

する。

実行後は成功・失敗にかかわらず元の `TemplatePath` へ復元する。

## 4. Compile

1. 既存 `modP2_04RemainingVerification` v0.1をRemove
   - Export確認は任意（生成済みv0.1ファイルが手元にあるため必須ではない）
2. `modP2_04RemainingVerification_v0.2_CP932.bas` をImport
3. `Debug -> Compile VBAProject`

Expected：

```text
Compile = PASS
```

## 5. I04実行

OFTはBaseline状態のままでよい。
手動でOFTを削除・Renameしない。

Entry Point：

```vb
TestP204I04OftMissing
```

Expected：

```text
PASS  I04-00 Missing OFT fixture preflight
PASS  I04-01 VariableDefinition Before snapshot
PASS  I04-02 Temporary TemplatePath applied
PASS  I04-03 ExecuteManualSync returns COperationResult
PASS  I04-04 ExecuteManualSync = Failure
PASS  I04-05 ConfigurationError / TemplatePath / OFT missing
PASS  I04-06 templateScanResult = Nothing
PASS  I04-07 syncDiffResult = Nothing
PASS  I04-08 VariableDefinition After snapshot
PASS  I04-09 VariableDefinition Before = After
PASS  I04-10 Settings.TemplatePath restored

FAIL Count = 0
Overall = PASS
```

Operation ResultのExpected詳細：

```text
Success = False
ErrorType = ConfigurationError
Target = TemplatePath
Message = Template file does not exist.
```

## 6. Safety Check after execution

Immediate Windowで以下を必ず確認する。

```text
PASS  I04-10 Settings.TemplatePath restored
Restored TemplatePath = <original path>
```

さらにSettings SheetのTemplatePathが元の値へ戻っていることを目視確認してよい。

I04終了時点でOFTそのものは一切変更していないため、Baseline OFT Fixtureの復元作業は不要。
