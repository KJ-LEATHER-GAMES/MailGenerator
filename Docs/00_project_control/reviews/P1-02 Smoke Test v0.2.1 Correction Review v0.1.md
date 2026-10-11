# P1-02 Smoke Test v0.2.1 Correction Review v0.1

## 1. Correction Scope

Production Code：

```text
変更なし
```

Smoke Testだけを修正する。

対象：

```text
v0.2
→
v0.2.1
```

## 2. Finding

v0.2 Cold Start実測：

```text
Explorer Count Before: 0
CreateMailFromTemplate: PASS
↓
Harness GetObject
→ Nothing
↓
FAIL
```

一方：

```text
Cleanup CloseWithoutSave: PASS
```

であり、Production側にはActive MailItemが存在していた。

分類：

```text
Test Defect
/
Smoke Test Evidence Acquisition Defect
```

Production Defectは成立していない。

## 3. v0.2.1 Correction

Cold Startでは、Productionの機能経路をEvidence再取得より優先する。

```text
Classic Outlook完全終了
↓
CreateMailFromTemplate
↓
ReadBodyText
↓
BodyText Length > 0
↓
Cold Start Lifecycle Baseline取得を試行
↓
CloseWithoutSave
↓
Lifecycle Evidence
```

v0.2で存在した、

```text
CreateMailFromTemplate
↓
GetObject Evidence
↓
取得失敗ならReadBodyText未実行
```

というBlocking構造を削除した。

## 4. Result Separation

v0.2.1では結果を以下へ分離する。

### Production Functional Path

```text
CreateMailFromTemplate
ReadBodyText
BodyText Length > 0
CloseWithoutSave
```

すべて成功：

```text
Production Functional Path:
PASS
```

### Lifecycle Evidence

`GetObject`再取得に成功し、Lifecycle BaselineとAfterを比較可能：

```text
Explorer Lifecycle
Draft Residue
Inspector Residue
```

すべて成立：

```text
Smoke Test:
PASS
```

`GetObject`を再取得できない、またはBefore/After Baselineを成立できない：

```text
Smoke Test:
BLOCKED (Production Functional Path PASS)
```

Production FAILとは扱わない。

## 5. Warm Start

Warm Startロジックは意味上変更しない。

```text
既存Explorer
→ Production
→ Explorer Count不変
→ ReadBodyText
→ CloseWithoutSave
→ Draft / Inspector Residueなし
```

## 6. Cold Start Evidence Timing

Cold StartのEvidence再取得は、

```text
ReadBodyText PASS後
```

へ移動した。

ここで取得できれば、

```text
Explorer / Draft / Inspector
Lifecycle Baseline
```

として使用する。

取得不能でも、

```text
CloseWithoutSave
```

は必ず実行する。

Close後に再取得できた場合はExplorer persistenceのみ確認可能だが、
Draft / Inspector before/after baselineがないためSmoke Test全体はBLOCKEDとする。

## 7. Static Review

```text
Production変更:
NONE

Cold Start Production前のCreateObject:
NONE

WordEditor direct access:
NONE

Create → Read間のGetObject Evidence:
NONE

ReadBodyText前のCold Start Evidence Failure:
NONE

CloseWithoutSave before Lifecycle Finalization:
YES

Production Functional PASS / Evidence BLOCKED分離:
YES
```

## 8. Next Verification

```text
1. v0.2.1 Import
2. VBA Compile
3. Warm Start
4. Cold Start
5. Result Review
```

期待するCold Start最重要Evidence：

```text
CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 238
CloseWithoutSave: PASS
Production Functional Path: PASS
```

その後、

```text
PASS
```

または

```text
BLOCKED (Production Functional Path PASS)
```

のどちらになるかでLifecycle Evidence側を判定する。
