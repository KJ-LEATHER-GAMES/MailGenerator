# P2-04 I11 Manual Only Verification Guide v0.1

## 1. 目的

I11は `MTS-SYNC-001 手動同期のみ` に対応するImplementation Verification。

Requirements：

```text
FR-SYNC-001
テンプレート同期は自動ではなく、
ユーザーが明示的に実行する手動同期方式。
```

Test Specification：

```text
Excel起動、UserForm起動等でVariableDefinitionを自動変更しない
ユーザーが同期実行した場合のみSync Engineが更新する
```

I11 Approved手順：

```text
VariableDefinition Snapshot
↓
Workbook保存・終了
↓
Workbook再オープン
↓
Manual Syncを実行せず比較
↓
VariableDefinition Before = After
LastDetectedAt No Change
↓
明示的Manual Sync
↓
ExecuteManualSync Success
必要なMetadataのみ更新
```

## 2. なぜ2段階Harnessか

Workbookを実際に閉じて再オープンするため、
Module-level変数ではBaselineを保持できない。

そこでBaselineはWorkbook外：

```text
%TEMP%
```

へ一時Evidenceファイルとして保存する。

Workbook内に：

```text
Test専用Sheet
Test専用Name
Test専用Cell
Workbook_Open Hook
```

は追加しない。

## 3. Module

```text
modP2_04I11ManualOnlyVerification_v0.1_CP932.bas
```

Module内部名：

```text
modP204I11ManualOnly
```

Standalone Harness。

## 4. Import / Compile

Module Import後：

```text
Debug
-> Compile VBAProject
```

Compile PASSを確認する。

## 5. Stage A — Baseline Preparation

実行：

```vb
PrepareP204I11ManualOnlyBaseline
```

Harnessは最初に：

```vb
ThisWorkbook.Save
```

を実行する。

その後、

```text
VariableDefinition Full Fingerprint
LastDetectedAt Fingerprint
```

をWindows TEMPへ保存する。

Expected：

```text
PASS  Workbook saved before baseline capture
PASS  VariableDefinition baseline saved
PASS  LastDetectedAt baseline saved
```

## 6. Workbook Close / Reopen

Stage A完了後：

1. Workbook / Excelを通常終了
2. 同じWorkbookを再オープン
3. **Manual Syncを実行しない**
4. UserFormもP3未実装なので操作不要
5. 直ちにStage Bを実行

重要：

```text
Stage A後からStage B前まで
VariableDefinitionを手作業で編集しない
OFTを変更しない
Manual Syncを実行しない
```

## 7. Stage B — No Auto Sync確認 + Explicit Manual Sync

実行：

```vb
TestP204I11ManualOnlyAfterReopen
```

最初に：

```text
VariableDefinition Full Fingerprint
LastDetectedAt Fingerprint
```

をStage AのBaselineと比較する。

Core Expected：

```text
PASS  I11-01 VariableDefinition Before Close = After Reopen
PASS  I11-02 LastDetectedAt unchanged after Workbook Open
```

これがI11の「Manual Only」の主要Evidence。

## 8. Explicit Manual Sync

No Auto Sync確認後、同じHarness内で2秒のTimestamp境界を作り、

```vb
ExecuteManualSync
```

を明示実行する。

Expected：

```text
ExecuteManualSync = Success
templateScanResult = Published
syncDiffResult = Published
```

Current stable fixtureでは：

```text
New.Count = 0
Reactivated.Count = 0
Unused.Count = 0
Existing.Count > 0
```

を期待する。

## 9. Metadata-only Evidence

明示Sync前後で、

```text
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
```

が不変であることを確認する。

さらにstable fixtureでは：

```text
LastDetectedAt以外の全列 = unchanged
LastDetectedAt = changed
```

を確認する。

Expected：

```text
PASS  I11-13 User Configuration unchanged
PASS  I11-14 Only LastDetectedAt changed in stable explicit sync
PASS  I11-15 LastDetectedAt updated only after explicit Manual Sync
```

## 10. Cleanup

Explicit Syncは正当にLastDetectedAtを更新するため、
Harness終了時に再オープン直後の状態へ復元する。

さらに：

```vb
ThisWorkbook.Save
```

でCleanup状態を保存する。

Expected：

```text
PASS  I11-16 Pre-manual-sync state restored
PASS  I11-18 Original reopened State = Restored State
PASS  I11-19 Restored workbook saved
```

I11全項目PASS時、一時Baselineファイルも削除する。

## 11. Expected Log

主要Expected：

```text
PASS  I11-00 Reopen baseline evidence files available
PASS  I11-01 VariableDefinition Before Close = After Reopen
PASS  I11-02 LastDetectedAt unchanged after Workbook Open
PASS  I11-03 Pre-manual-sync VariableDefinition snapshot
PASS  I11-04 Explicit ExecuteManualSync returns COperationResult
PASS  I11-05 Explicit ExecuteManualSync = Success
PASS  I11-06 templateScanResult = Published
PASS  I11-07 syncDiffResult = Published
PASS  I11-08 New.Count = 0
PASS  I11-09 Reactivated.Count = 0
PASS  I11-10 Unused.Count = 0
PASS  I11-11 Existing.Count > 0
PASS  I11-12 Post-manual-sync VariableDefinition snapshot
PASS  I11-13 User Configuration unchanged
PASS  I11-14 Only LastDetectedAt changed in stable explicit sync
PASS  I11-15 LastDetectedAt updated only after explicit Manual Sync
PASS  I11-16 Pre-manual-sync state restored
PASS  I11-17 Restored snapshot captured
PASS  I11-18 Original reopened State = Restored State
PASS  I11-19 Restored workbook saved

FAIL Count = 0
Overall = PASS

P3 UserForm Variant = N/A - P3 not implemented
```

## 12. Evidence境界

このI11は：

```text
Implementation Verification
```

であり、

```text
MTS-SYNC-001 Formal PASS
```

とはまだ記録しない。

Formal MVP TestはP7 Test Candidate Build固定後に実施する。
