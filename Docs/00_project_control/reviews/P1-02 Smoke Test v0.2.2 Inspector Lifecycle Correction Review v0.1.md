# P1-02 Smoke Test v0.2.2 Inspector Lifecycle Correction Review v0.1

## 1. Observed Result

Cold Start実測：

```text
Explorer Count Before: 0
CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 238

Inspector Count Lifecycle Baseline: 1

CloseWithoutSave: PASS
Production Functional Path: PASS

Explorer Count After: 1
Draft Count After: 17
Inspector Count After: 0

Harness Result:
FAIL
```

## 2. Root Cause

v0.2.1ではCold Start時に、`ReadBodyText`成功後のInspector件数を
`Inspector Count Lifecycle Baseline` として保存し、Close後も同じ件数であることを要求していた。

しかし `ReadBodyText` 内ではProductionが以下を実行する。

```text
MailItem.GetInspector
↓
Inspector.WordEditor
↓
Word Document
```

この処理中はInspectorが一時的に存在する。

今回の実測：

```text
During ReadBodyText:
Inspector Count = 1

After CloseWithoutSave:
Inspector Count = 0
```

これはResidueではなく正常Cleanupである。

したがって、

```text
1 → 0
```

をFAILにしたTest Expectedが誤り。

## 3. Classification

```text
Finding:
TF-P1-02-003 Cold Start Inspector Baseline Misclassification

Classification:
Test Defect
/
Smoke Test Expected Result Defect

Production Defect:
NO

Requirement Gap:
NO

Design Finding:
NO

Production Change Required:
NO

Smoke Test Change Required:
YES
```

## 4. Correct Lifecycle Model

### Warm Start

Outlook起動済みのためProduction前にInspector Countを取得可能。

```text
Inspector Before
→ Production
→ Inspector After
```

Expected：

```text
Inspector After = Inspector Before
```

### Cold Start

Outlook未起動であることを確認済みなので、
Production前のInspector Countは論理的に0。

```text
Outlook not running
→ Inspector Before = 0

ReadBodyText実行中
→ Inspector Count may temporarily become 1

CloseWithoutSave後
→ Inspector After = 0
```

Expected：

```text
Inspector After = 0
```

`ReadBodyText`後に取得するInspector Countは
Baselineではなく診断用 `Inspector Count During ReadBodyText` とする。

## 5. v0.2.2 Correction

変更：

```text
Cold Start:
inspectorCountBaseline
→ inspectorCountDuring
```

出力：

```text
Inspector Count During ReadBodyText: <value>
```

最終判定：

```text
Warm Start:
Inspector After = Inspector Before

Cold Start:
Inspector After = 0
```

Explorer / Draft判定は変更しない。

## 6. Current Run Reinterpretation

今回のCold Start実測は以下を満たしている。

```text
CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 238
CloseWithoutSave: PASS

Explorer:
0 → 1 → 1

Draft:
17 → 17

Inspector:
0 (precondition inference)
→ 1 during ReadBodyText
→ 0 after Close
```

したがって実測Evidence自体にはProduction異常を示すものはない。

```text
Cold Start Production Functional Path:
PASS

Explorer Lifecycle:
PASS

Draft Residue:
NONE

Inspector Residue:
NONE

Harness Verdict:
FALSE FAIL
```

## 7. Next Gate

v0.2.2をImport後：

```text
VBA Compile
↓
Warm Start
↓
Cold Start
```

を再実行する。

期待Cold Start：

```text
Inspector Count Before: 0 (inferred from Outlook not running)
Inspector Count During ReadBodyText: 1
Inspector Count After: 0
Inspector Residue: NONE

TestP102InspectorWordEditorColdStart:
PASS
```
