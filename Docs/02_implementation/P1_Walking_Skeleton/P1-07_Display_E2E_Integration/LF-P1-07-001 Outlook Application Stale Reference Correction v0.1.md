# LF-P1-07-001 Outlook Application Stale Reference Correction v0.1

## 1. Finding

P1-07 Verificationで以下を確認した。

```text
1回目 Warm:
PASS

1回目 Cold:
FAIL / Error 462

2回目 Cold:
FAIL / Error 462

2回目 Warm:
FAIL / Error 462
```

Failure箇所：

```text
EnsureOutlookReady
↓
mOutlookApp.Explorers.Count
↓
Error 462
リモート サーバーがないか、使用できる状態ではありません
```

## 2. Root Cause

P1-07 v0.1 `DisplayMail()` は成功後に、

```vb
Set mMailItem = Nothing
```

だけを実行し、

```vb
mOutlookApp
```

をModule Stateへ保持していた。

1回目Warm成功後にユーザーがClassic Outlookを終了すると、
`mOutlookApp` はVBA上では `Nothing` ではないが、終了済みOutlookを指す無効なCOM proxyとなる。

次回 `EnsureOutlookReady()` は、

```vb
If mOutlookApp Is Nothing Then
```

を通過しないため再取得せず、

```vb
mOutlookApp.Explorers.Count
```

へアクセスしてError 462となる。

さらにReadiness Error Pathで `mOutlookApp = Nothing` へ戻していなかったため、
以降のCold / Warm実行も同じstale proxyを再利用して連続FAILした。

## 3. Classification

```text
Classification:
Implementation Defect
/
Lifecycle Defect

Requirement Gap:
NONE

Design Finding:
NONE

Test Artifact Defect:
NONE

Baseline Change:
NOT REQUIRED

Technical Spike Reopen:
NOT REQUIRED
```

## 4. Correction

### A. Display成功時

```vb
mMailItem.Display

Set mMailItem = Nothing
Set mOutlookApp = Nothing
```

`mOutlookApp = Nothing` はCOM reference解放であり、

```text
Outlook.Quit
MailItem.Close
MailItem.Save
MailItem.Send
```

ではない。

### B. Readiness Failure時

`EnsureOutlookReady()` が失敗した場合、

```vb
Set mOutlookApp = Nothing
```

として次回実行へstale / partial Application referenceを持ち越さない。

## 5. Expected Lifecycle

```text
CreateMailForDisplay
↓
EnsureOutlookReady
↓
mOutlookApp取得
↓
MailItem生成
↓
Display
↓
mMailItem reference release
mOutlookApp reference release
↓
User may close Outlook
↓
Next execution
↓
GetObject / CreateObjectでcurrent Outlookを再取得
```

## 6. Re-verification

修正版Import後：

```text
Debug → Compile VBAProject
```

PASSを確認する。

その後、以下を順に再実行する。

```text
V1 Warm Start Normal
↓
PASS expected

Outlookを完全終了

V2 Cold Start Normal
↓
PASS expected

Cold Startで起動したExplorerを残す

V3 Unresolved Fail Closed
↓
PASS expected
```

追加でLifecycle再発確認として、

```text
Warm PASS
↓
Outlook終了
↓
Outlook手動起動
↓
Warm再実行
```

もPASSすることを確認する。

## 7. Formal Test Boundary

本Correctionの再確認はP1-07 Implementation Verificationである。

Formal MTS PASSとは扱わない。
