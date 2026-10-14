# P2-04 I09 Warm Lifecycle Verification Guide v0.1

## 1. 目的

I09では、Classic Outlook起動済みのWarm Start環境で
P2-04 `ExecuteManualSync` を実行し、既存Explorerを再利用したまま
Lifecycle residueを残さないことを確認する。

Approved Expected：

```text
ExecuteManualSync = Success
Existing Explorer reuse
Unnecessary Explorer = NONE
Scan MailItem Display = NONE
Inspector Residue = NONE
Draft Residue = NONE
```

## 2. Precondition

**Classic Outlookをユーザーが手動で起動しておく。**

少なくとも1つのExplorerが存在する状態：

```text
Explorer Count >= 1
```

Harness自身はOutlookを起動しない。

以下の場合はABORT：

```text
GetObject(, "Outlook.Application") = Failure
Explorer Count < 1
```

これによりI09をCold Startへ変質させない。

## 3. Lifecycle Evidence

実行前：

```text
Explorer Count Before
Inspector Count Before
Draft Count Before
```

実行：

```text
ExecuteManualSync
```

実行後：

```text
Explorer Count After
Inspector Count After
Draft Count After
```

PASS条件：

```text
Explorer After = Explorer Before
Inspector After = Inspector Before
Draft After = Draft Before
```

Explorer Count一致：

```text
Existing Explorer reuse
Unnecessary Explorer = NONE
Existing Explorer unexpected close = NONE
```

Inspector / Draft Count一致：

```text
Inspector residue = NONE
Draft residue = NONE
```

## 4. Scan MailItem Displayの扱い

P1-02でEstablished済みのAdapter契約では、

```text
Scan用MailItemをDisplayしない
Cold Start時のみ必要なExplorerをDisplay
```

となっている。

I09 Runtimeでは、

```text
Explorer追加なし
Inspector residueなし
Draft residueなし
```

を取得し、

```text
Scan MailItem Display residue = NONE (indirect)
```

として記録する。

瞬間的なInspector取得はWordEditorアクセス内部で発生し得るため、
処理中のInspector Countを0固定のContractにはしない。

## 5. VariableDefinition Cleanup

I09は正常Syncなので、

```text
LastDetectedAt
TemplateLocation
その他Sync Metadata
```

が正当に更新され得る。

そのためHarnessは実行前Snapshotを保存し、
Lifecycle Evidence取得後に元状態へ復元する。

確認：

```text
Original VariableDefinition state restored
Original State = Restored State
```

これはTest Cleanupであり、Production Rollbackではない。

## 6. Test Module

```text
modP2_04I09WarmLifecycleVerification_v0.1_CP932.bas
```

Standalone Moduleなので、
既存I03-I08 Harnessは削除不要。

## 7. 実行手順

1. Classic Outlookを手動で起動
2. Outlook Explorer Windowが1つ以上存在することを確認
3. ModuleをImport
4. `Debug -> Compile VBAProject`
5. Compile PASS
6. 以下を実行

```vb
TestP204I09WarmLifecycle
```

## 8. Expected

```text
PASS  I09-00 Classic Outlook Warm Start precondition
PASS  I09-01 Lifecycle baseline acquired
PASS  I09-02 VariableDefinition original snapshot
PASS  I09-03 ExecuteManualSync returns COperationResult
PASS  I09-04 ExecuteManualSync = Success
PASS  I09-05 templateScanResult = Published
PASS  I09-06 syncDiffResult = Published
PASS  I09-07 Existing Explorer reused / no unnecessary Explorer
PASS  I09-08 Inspector residue = NONE
PASS  I09-09 Draft residue = NONE
PASS  I09-10 Scan MailItem Display residue = NONE (indirect)
PASS  I09-11 Existing Explorer remains open
PASS  I09-12 Post-sync VariableDefinition snapshot
PASS  I09-13 Original VariableDefinition state restored
PASS  I09-14 Restored snapshot captured
PASS  I09-15 Original State = Restored State

FAIL Count = 0
Overall = PASS
```

## 9. Review時の注意

Draft/Inspector CountがBefore/Afterで変化した場合、
即Production Defectとはせず、

```text
External Outlook activity
Test Artifact / Evidence acquisition
Production Lifecycle Defect
```

を切り分ける。

特にテスト中にユーザーが別メールを作成・保存・開閉しないこと。
