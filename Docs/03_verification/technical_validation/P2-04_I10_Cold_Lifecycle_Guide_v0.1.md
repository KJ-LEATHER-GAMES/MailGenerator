# P2-04 I10 Cold Lifecycle Verification Guide v0.1

## 1. 目的

I10ではClassic Outlook完全終了状態から、P2-04 `ExecuteManualSync` が
Outlook AdapterのCold Start Readinessを通じてVisible Explorerを起動し、
Template Scan / Syncを完走できることを確認する。

Approved Expected：

```text
Classic Outlook completely stopped
OUTLOOK.EXE not running
↓
ExecuteManualSync
↓
Visible Explorer established
Readiness established
Template Read / Scan Success
ExecuteManualSync Success
Scan MailItem Display = NONE
Draft Residue = NONE
Inspector Residue = NONE
```

## 2. なぜ2段階実行か

Cold Start前にDraft Countを取得しようとしてOutlook Objectへ接続すると、
観測処理自身がCold Start条件へ影響する可能性がある。

そのため：

```text
Step A
Outlook running
↓
Draft Count baselineだけ取得
↓
COM参照を全解放
↓
UserがOutlook完全終了

Step B
OUTLOOK.EXE = 0確認
↓
ExecuteManualSync
↓
Cold Start Lifecycle Evidence取得
```

とする。

この方式なら、Cold Start条件を壊さずにDraft Before / After比較ができる。

## 3. Module

```text
modP2_04I10ColdLifecycleVerification_v0.1_CP932.bas
```

Module内部名：

```text
modP204I10ColdLifecycle
```

Standalone Module。
I03-I09 Harnessは削除不要。

## 4. Compile

Module Import後、最初に：

```text
Debug
-> Compile VBAProject
```

Compile PASSを確認する。

**CompileはBaseline準備前に行うこと。**

Baseline準備後にVBA Project Reset / Compileをすると
Module-level baselineが失われる可能性がある。

## 5. Step A — Baseline Preparation

Classic Outlookを通常どおり手動起動する。

条件：

```text
Explorer Count >= 1
Inspector Count = 0
```

開いているメールWindowがあれば閉じる。

実行：

```vb
PrepareP204I10ColdLifecycleBaseline
```

Expected例：

```text
PASS  Baseline prepared
OUTLOOK.EXE Process Count = 1
Explorer Count Baseline = 1
Inspector Count Baseline = 0
Draft Count Baseline = 21
```

Baseline取得後、HarnessはOutlook COM参照をすべて解放する。

## 6. User Action — Outlook完全終了

**Excelは開いたまま**Classic Outlookだけを完全終了する。

重要：

```text
OUTLOOK.EXE
= Not Running
```

にする。

Task ManagerでOUTLOOK.EXEが残っていないことを確認してよい。

この間：

```text
VBA Reset
Workbook Close
Excel Close
Compile
```

はしない。

Module-level Draft baselineを保持するため。

## 7. Step B — Cold Lifecycle

Outlookを手動再起動せず、そのまま：

```vb
TestP204I10ColdLifecycle
```

を実行する。

HarnessはまずWMIで：

```text
OUTLOOK.EXE Process Count Before = 0
```

を確認する。

さらに：

```text
GetObject(, "Outlook.Application")
= Nothing
```

を確認する。

ここまでHarnessはOutlookを起動しない。

その後初めて：

```vb
ExecuteManualSync
```

を呼ぶ。

## 8. Expected Evidence

主要Expected：

```text
PASS  I10-00 Pre-shutdown lifecycle baseline available
PASS  I10-01 OUTLOOK.EXE Not Running
PASS  I10-02 No running Outlook.Application available
PASS  I10-03 VariableDefinition original snapshot
PASS  I10-04 ExecuteManualSync returns COperationResult
PASS  I10-05 ExecuteManualSync = Success
PASS  I10-06 templateScanResult = Published
PASS  I10-07 syncDiffResult = Published

PASS  I10-08 Classic Outlook process established
PASS  I10-09 Cold Start Outlook.Application reacquired
PASS  I10-10 Visible Explorer established
PASS  I10-11 Active Explorer available

PASS  I10-12 Inspector residue = NONE
PASS  I10-13 Draft residue = NONE
PASS  I10-14 Scan MailItem Display residue = NONE (indirect)
PASS  I10-15 Cold-start Explorer remains open

PASS  I10-17 Original VariableDefinition state restored
PASS  I10-19 Original State = Restored State

FAIL Count = 0
Overall = PASS
```

## 9. Draft Evidence

Draft CountはStep AのBaselineとStep B終了後を比較する。

例：

```text
Draft Count Baseline = 21
Draft Count After = 21
```

なら：

```text
Draft Residue = NONE
```

とする。

Cold Start中にOutlookが外部同期してDraft Folder自体が変化した場合、
即Production Defectとはせず、

```text
External Outlook activity
Evidence interference
Production Lifecycle Defect
```

を切り分ける。

## 10. Scan MailItem Display

I10では：

```text
Inspector Count After = 0
Draft Count After = Baseline
```

に加え、既存Adapter Contract：

```text
Scan用MailItemはDisplayしない
Cold Start時にDisplayするのはExplorer
```

を組み合わせ、

```text
Scan MailItem Display residue = NONE (indirect)
```

として記録する。

## 11. Cold-start Explorer

Production DesignではCold Start時に起動したExplorerは
Readiness成立後にツールがCloseしない。

したがってI10完了後：

```text
Explorer Count >= 1
```

はExpected。

HarnessもOutlook ExplorerをCloseしない。

ログ取得後はユーザーが通常操作でOutlookを閉じてよい。

## 12. VariableDefinition Cleanup

成功SyncによりLastDetectedAt等が更新されるため、
Harnessは実行前SnapshotへVariableDefinitionを復元する。

これはTest CleanupでありProduction Rollbackではない。
