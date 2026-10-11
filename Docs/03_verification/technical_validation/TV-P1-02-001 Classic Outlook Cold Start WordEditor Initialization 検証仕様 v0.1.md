# TV-P1-02-001 Classic Outlook Cold Start / WordEditor Initialization 検証仕様 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | TV-P1-02-001 Classic Outlook Cold Start / WordEditor Initialization 検証仕様 |
| バージョン | v0.1 |
| 対象Phase | P1 Walking Skeleton / P1-02 Inspector WordEditor Connection |
| 種別 | Local Technical Verification |
| Status | Ready for Execution |
| Production変更 | 本Verification完了までは行わない |

---

## 2. 背景

P1-02 Production実装後、以下のA/B結果を確認した。

### Warm Start

Classic Outlookを事前起動した状態では以下が成立した。

```text
CreateMailFromTemplate = PASS
ReadBodyText = PASS
BodyText Length = 238
Draft Count 17 -> 17
Inspector Count 0 -> 0
```

### Cold Start

Classic Outlookを事前起動していない状態では以下となった。

```text
CreateMailFromTemplate = PASS
ReadBodyText = FAIL
ErrorType = OutlookError
Target = WordEditor
Error = -2147467259 / 操作は失敗しました
```

既存Smoke TestはCold Start時にもLifecycle Evidence取得のため、Production処理前に以下を実行している。

```text
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(Drafts)
↓
Draft Items.Count取得
```

したがって以下は既に不成立と判断する。

```text
単純なOutlook.Application生成
MAPI Session取得
Default Folderアクセス
```

だけではWordEditor利用可能状態へ到達しない。

本Verificationでは候補をExplorer初期化へ限定する。

---

## 3. 目的

Classic Outlook Cold Start時に、MailItemをDisplayせずにWordEditor利用可能状態へ到達するために必要な最小初期化条件を特定する。

優先順位は以下とする。

```text
1. ユーザーへ画面を表示しない初期化
2. Outlook Explorerのみ表示する初期化
3. MailItem.Displayは本Verification対象外
```

---

## 4. 検証仮説

### H1：Hidden Explorer Initialization

Outlook Application / MAPI Sessionだけでは不足するが、非表示Explorer Objectを生成すればWordEditor利用可能状態へ初期化される可能性がある。

概念フロー：

```text
Classic Outlook Cold Start
↓
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(Inbox)
↓
Explorers.Add(...)
↓
Explorerは非表示のまま
↓
Production CreateMailFromTemplate
↓
Production ReadBodyText
```

### H2：Visible Explorer Initialization

H1がFAILする場合、Explorerを実際にDisplayしてClassic Outlook UIを起動することでWordEditor利用可能状態へ到達する可能性がある。

概念フロー：

```text
Classic Outlook Cold Start
↓
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(Inbox)
↓
Explorers.Add(...)
↓
Explorer.Display
↓
Production CreateMailFromTemplate
↓
Production ReadBodyText
```

---

## 5. 検証対象外

以下は本Verificationでは試さない。

```text
MailItem.Display
Inspector.Display
固定Sleepによる待機
無制限Retry
NameSpace.Logonの追加
WordEditor専用Adapter追加
Requirement変更
Production modOutlookAdapter変更
```

理由：

- 現時点ではExplorer初期化だけで解決可能かを先に確認する
- MailItem.DisplayはScan Lifecycleの「Displayしない」と衝突する
- 固定待ち時間はRoot Cause条件を曖昧にする
- Production変更はTechnical Verification結果確定後に行う

---

## 6. 共通Precondition

各Caseは必ず独立して実施する。

```text
1. Excel Workbookを開く
2. 旧modOutlookAdapterが存在しないことを確認
3. Microsoft Outlook Object Library参照なしでCompile PASS
4. Classic Outlookを完全終了
5. OUTLOOK.EXEが残っていないことを確認
6. Baseline OFTは変更しない
7. Test開始前にOutlookのメール画面・Inspectorが存在しない
```

Case間では必ずClassic Outlookを完全終了し、Cold Start状態へ戻す。

---

## 7. Case TV-C01：Hidden Explorer

### 実施内容

Test Harness内でLate Bindingのみを使用する。

```text
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(olFolderInbox = 6)
↓
Application.Explorers.Add(
    Inbox,
    olFolderDisplayNormal = 0
)
↓
Explorer.Displayは呼ばない
↓
Production CreateMailFromTemplate
↓
Production ReadBodyText
↓
Production CloseWithoutSave
↓
Explorer.Close
```

### Expected

```text
Outlook Explorer画面 = 表示されない
CreateMailFromTemplate = PASS
ReadBodyText = PASS
BodyText Length > 0
Draft Residue = NONE
Inspector Residue = NONE
MailItem.Display = NONE
```

### 判定

2回連続したCold Start実行でPASSした場合、TV-C01を成立とする。

---

## 8. Case TV-C02：Visible Explorer

TV-C01がFAILした場合のみ実施する。

### 実施内容

```text
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(olFolderInbox = 6)
↓
Application.Explorers.Add(
    Inbox,
    olFolderDisplayNormal = 0
)
↓
Explorer.Display
↓
DoEvents
↓
Production CreateMailFromTemplate
↓
Production ReadBodyText
↓
Production CloseWithoutSave
```

### Expected

```text
Classic Outlook Explorer = 表示される
MailItem自体はDisplayされない
CreateMailFromTemplate = PASS
ReadBodyText = PASS
BodyText Length > 0
Draft Residue = NONE
Inspector Residue = NONE
```

### 判定

2回連続したCold Start実行でPASSした場合、TV-C02を成立とする。

---

## 9. Evidence

各Caseで最低限以下を記録する。

```text
Case ID
Cold Start確認
Explorer Count Before
Explorer Count After Initialization
Explorer Visible / Hidden
Draft Count Before
Inspector Count Before
CreateMailFromTemplate Result
ReadBodyText Result
BodyText Length
CloseWithoutSave Result
Draft Count After
Inspector Count After
Unexpected MailItem Display
Final Result
```

---

## 10. Decision Rule

### TV-C01 PASS

```text
Hidden Explorer Initialization = sufficient
```

判定：

```text
Finding Classification:
Implementation Detail

Production候補:
Outlook Cold Start時のみHidden Explorerを一時生成
↓
WordEditor利用可能状態成立
↓
不要ExplorerをClose
```

Production Patch作成後、Cold / Warm双方でRegressionする。

### TV-C01 FAIL / TV-C02 PASS

```text
Visible Outlook Explorer Initialization = required
```

判定：

```text
Technical Condition identified
↓
Visible Side Effectあり
↓
Design / UX Impact Review
```

この時点ではProductionへ自動採用しない。

検討候補：

```text
A. ツール側でClassic Outlookを起動する
B. ユーザーへClassic Outlook起動を要求する
```

利用者向け前提条件を追加する場合はRequirement Gap有無を判定する。

### TV-C01 FAIL / TV-C02 FAIL

Explorer初期化だけでは解決しない。

```text
Finding Classification:
Technical Risk / Design Finding候補
```

次のVerification候補としてのみ以下を再検討する。

```text
WordEditor readiness retry
Inspector / MailItem Display依存
Technical Spike再評価要否
```

本TV内では実装しない。

---

## 11. PASS / FAIL Criteria

### TV PASS

以下のいずれか。

```text
TV-C01 = PASS
```

または

```text
TV-C01 = FAIL
TV-C02 = PASS
Root Cause ConditionをExplorer可視化要否まで特定
```

本TVのPASSはP1-02 COMPLETEを直接意味しない。

Production解決策を反映後、P1-02 Smoke Testを再実行する。

### TV FAIL

```text
TV-C01 = FAIL
TV-C02 = FAIL
```

かつExplorer初期化ではCold Start WordEditor Failureを説明できない場合。

---

## 12. Production反映前Gate

Technical Verification結果確定前に以下をProductionへ追加しない。

```text
Explorers.Add
Explorer.Display
Sleep
Retry Loop
MailItem.Display
```

結果に基づき、最小の成立方式だけをProductionへ反映する。

---

## 13. Deliverables

```text
TV-P1-02-001 Classic Outlook Cold Start / WordEditor Initialization 検証仕様 v0.1.md

modTVP102001ColdStartWordEditorSmokeTest_CP932.bas

TV-P1-02-001 Result Record v0.1.md
※ 実行後に作成
```
