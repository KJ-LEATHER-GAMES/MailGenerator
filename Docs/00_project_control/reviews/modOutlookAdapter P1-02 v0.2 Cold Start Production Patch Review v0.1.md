# modOutlookAdapter P1-02 v0.2 Cold Start Production Patch Review v0.1

## 1. 対象

```text
Source:
modOutlookAdapter_P1-02_CP932.bas

Patched:
modOutlookAdapter_P1-02_v0.2_ColdStart_CP932.bas

Specification:
P1-02 Inspector WordEditor Connection 実施仕様 v0.2

Execution Baseline:
BL-MVP-003
```

## 2. Patch Scope

追加：

```text
EnsureOutlookReady()
OL_FOLDER_INBOX = 6
OL_FOLDER_DISPLAY_NORMAL = 0
TARGET_OUTLOOK_STARTUP
TARGET_OUTLOOK_EXPLORER
```

変更：

```text
CreateMailFromTemplate()
→ MailItem生成前にEnsureOutlookReady()を実行
```

維持：

```text
Public CreateMailFromTemplate API
Public ReadBodyText API
Public CloseWithoutSave API
Private mOutlookApp / mMailItem Ownership
TryGetWordDocument()
Late Binding
Scan MailItem非Display
CloseWithoutSave Lifecycle
```

## 3. Warm Start

```text
mOutlookApp取得
↓
Explorers.Count > 0
↓
Success
```

既存Explorerを利用し、新規Explorerを生成しない。

## 4. Cold Start

```text
Outlook.Application取得 / 起動
↓
Explorers.Count = 0
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(Inbox)
↓
Explorers.Add(...)
↓
Explorer.Display
↓
DoEvents
↓
CreateItemFromTemplate
```

`TV-P1-02-001` で成立したVisible Explorer候補をProductionへ最小反映した。

固定Sleep / 無制限Retryは追加していない。

## 5. Explorer Lifecycle

Readiness成功後：

```text
Explorer.Close
= 実行しない

Local Explorer Reference
= Nothing
```

Readiness失敗時に本Patchが新規生成したExplorerだけはCleanup対象とする。

既存ExplorerはCloseしない。

## 6. MailItem Lifecycle

変更なし。

```text
CreateMailFromTemplate
↓
ReadBodyText
↓
CloseWithoutSave
```

Cold Startで表示されるのはOutlook Explorerであり、Scan用MailItemではない。

## 7. Error Model

新規ErrorTypeなし。

```text
Outlook Application / MAPI:
ErrorType = OutlookError
Target = OutlookStartup

Explorer取得 / 生成 / Display:
ErrorType = OutlookError
Target = OutlookExplorer
```

WordEditor以降は既存分類を維持する。

## 8. Public API Compatibility

```text
CreateMailFromTemplate(templatePath)
ReadBodyText(bodyText)
CloseWithoutSave()
```

すべて変更なし。

Caller側変更：

```text
不要
```

## 9. Static Review

```text
Public API expansion:
NONE

New Adapter / Class:
NONE

Early Binding dependency:
NONE

MailItem.Display:
NONE

Explorer.Close after successful readiness:
NONE

Fixed Sleep:
NONE

Unlimited Retry:
NONE
```

## 10. Verification Gate

このArtifactだけではP1-02 PASS / COMPLETEにしない。

次の順で実機確認する。

```text
1. 旧modOutlookAdapterを置換
2. VBA Compile
3. Warm Start Smoke
4. Cold Start Smoke
5. Explorer / Draft / Inspector Lifecycle Evidence
6. P1-01 Regression
7. P1-02 PASS / FAIL
```

### 重要

既存 `modP1_02InspectorWordEditorSmokeTest_CP932.bas` は、
Production `CreateMailFromTemplate` の前にEvidence取得用として
Outlook Applicationを生成するため、そのままではProduction Cold Startを検証できない。

Cold Start Regressionでは、Production呼出し前にOutlookを起動しない
Smoke Test v0.2が必要である。

## 11. Static Review Result

Artifact static checks：

```text
CP932 Decode:
PASS

Public Functions:
CreateMailFromTemplate
ReadBodyText
CloseWithoutSave

MailItem.Display occurrence:
0

Explorer.Display:
1 production path

Explorer.Close:
Failure cleanup only

Fixed Sleep:
NONE

DoEvents:
1 after Explorer.Display
```

`DoEvents` は `TV-P1-02-001` でPASSしたVisible Explorer初期化シーケンスをProductionへ最小反映したImplementation Detailであり、固定待ち時間ではない。

```text
P1-02 v0.2 Specification Alignment:
PASS

Production API Compatibility:
PASS

Cold Start Readiness Placement:
PASS

Explorer Lifecycle:
PASS

MailItem Lifecycle:
PASS

Error Model:
PASS

Compile:
NOT RUN

Runtime Verification:
NOT RUN

P1-02 Overall:
NOT COMPLETE
```
