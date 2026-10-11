# P1-02 Smoke Test v0.2 Review v0.1

## 1. 目的

Production `modOutlookAdapter` のCold Start Resolutionを、Test Harness自身がOutlookを先行起動せずに検証する。

## 2. Entry Point

```text
TestP102InspectorWordEditorWarmStart
TestP102InspectorWordEditorColdStart
```

互換Entry Point：

```text
TestP102InspectorWordEditorConnection
→ Warm Startへ委譲
```

## 3. Cold Start純度

Cold StartではProduction呼出し前に以下を行わない。

```text
CreateObject("Outlook.Application")
GetNamespace("MAPI")
Drafts Folder Access
Explorer生成
```

Precondition確認は `GetObject` のみを使用する。

```text
GetObject成功 → FAIL: Outlook already running
GetObject失敗 → Cold Start precondition成立
```

最初にOutlookを起動可能な処理はProductionの `CreateMailFromTemplate` である。

## 4. Cold Start Evidence制約

Outlook起動前にDraft / Inspector件数を自動取得すると、そのEvidence取得自体がOutlookを起動してCold Start条件を破壊する。

したがってCold Startでは以下で比較する。

```text
Production Readiness成立
↓
Draft / Inspector Lifecycle Baseline取得
↓
ReadBodyText
↓
CloseWithoutSave
↓
After Count取得
```

## 5. Warm Start Expected

```text
Explorer Count Before >= 1
Explorer Count After Readiness = Explorer Count Before
Draft Count After = Draft Count Before
Inspector Count After = Inspector Count Before
```

不要な追加Explorer生成を検出する。

## 6. Cold Start Expected

```text
Explorer Count Before = 0
Production CreateMailFromTemplate
Explorer Count After Readiness >= 1
ReadBodyText = PASS
CloseWithoutSave = PASS
Explorer Count After = Explorer Count After Readiness
Draft / Inspector Residue = NONE
```

Explorerは処理後も開いたままとする。

## 7. Harness境界

```text
CreateObject("Outlook.Application") in harness = NONE
WordEditor direct access = NONE
Word Document direct access = NONE
MailItem Display = NONE
```

## 8. Run Order

Warm Start：

```text
1. Classic Outlookを通常起動
2. Explorerを1つ以上開く
3. TestP102InspectorWordEditorWarmStart
```

Cold Start：

```text
1. Classic Outlookを完全終了
2. OUTLOOK.EXEが残っていないことを確認
3. TestP102InspectorWordEditorColdStart
4. Outlook Explorerが開いたままであることを確認
```

## 9. Completion Gate

```text
VBA Compile = PASS
Warm Start = PASS
Cold Start = PASS
P1-01 Regression = PASS
```

これらが揃うまでP1-02をCOMPLETEとしない。
