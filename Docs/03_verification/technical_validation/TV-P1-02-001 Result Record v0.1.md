# TV-P1-02-001 Result Record v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | TV-P1-02-001 Result Record |
| バージョン | v0.1 |
| 対象Technical Verification | TV-P1-02-001 Classic Outlook Cold Start / WordEditor Initialization |
| 対象Phase | P1 Walking Skeleton / P1-02 Inspector WordEditor Connection |
| 文書種別 | Technical Verification Result Record |
| Status | **PASS / CLOSED** |
| 実施日 | 2026-09-18 |
| 対象Workbook | `MailGenerator3.xlsm` |
| 対象Production Module | `modOutlookAdapter` |
| 対象Smoke Test | `modTVP102001ColdStartWordEditorSmokeTest_CP932.bas` |
| Production変更 | 本Verification中は未実施 |

---

## 2. 目的

Classic Outlookが事前起動していないCold Start状態において、Scan用MailItemをDisplayせずに `Inspector.WordEditor` / Word Documentへアクセスするために必要な最小初期化条件を特定する。

検証対象は以下の2候補とした。

```text
TV-C01
Hidden Explorer Initialization

TV-C02
Visible Explorer Initialization
```

MailItem自体の `Display` はScan Lifecycleと衝突するため、本Verificationでは対象外とした。

---

## 3. 背景

P1-02 Production実装後、Classic Outlookの起動状態により以下の差を確認した。

### Warm Start

Classic Outlookを事前起動済みの場合：

```text
CreateMailFromTemplate = PASS
ReadBodyText = PASS
BodyText Length = 238
Draft Count = 増加なし
Inspector Count = 残存なし
```

### Cold Start

Classic Outlookを事前起動していない場合：

```text
CreateMailFromTemplate = PASS
ReadBodyText = FAIL

ErrorType = OutlookError
Target = WordEditor
Error = -2147467259 / 操作は失敗しました
```

既存P1-02 Smoke TestではCold Start時にも以下まで実行済みであった。

```text
CreateObject("Outlook.Application")
↓
GetNamespace("MAPI")
↓
GetDefaultFolder(Drafts)
```

したがって、単純なOutlook Application生成 / MAPI Session取得 / Default FolderアクセスだけではWordEditor利用可能状態へ到達しないことは事前に確認済みであった。

---

## 4. 実施結果サマリー

| Case | 条件 | 結果 | 判定 |
|---|---|---|---|
| TV-C01 | Hidden Explorer | `ReadBodyText` FAIL | **FAIL** |
| TV-C02 Run 1 | Visible Explorer | `ReadBodyText` PASS | **PASS** |
| TV-C02 Run 2 | Visible Explorer | `ReadBodyText` PASS | **PASS** |

検証仕様ではTV-C02について、Cold Startから2回連続PASSを成立条件としている。

今回、TV-C02をCold Startから2回連続実施し、双方でPASSした。

---

## 5. TV-C01 Hidden Explorer 結果

### 実測

```text
Explorer Count Before: 0
Explorer Count After Initialization: 1
Explorer Initialization: HIDDEN

Draft Count Before: 17
Inspector Count Before: 0

CreateMailFromTemplate: PASS

ReadBodyText:
Success=False
ErrorType=OutlookError
Target=WordEditor
Message=Unable to access WordEditor:
-2147467259 - 操作は失敗しました。

Cleanup CloseWithoutSave: PASS
```

### 判定

```text
TV-C01 = FAIL
```

### Finding

非表示Explorer Objectを生成しただけでは、Cold Start状態のClassic OutlookをWordEditor利用可能状態まで初期化できない。

以下は不十分であることを確認した。

```text
Outlook.Application生成
MAPI Session取得
Default Folderアクセス
Hidden Explorer生成
```

---

## 6. TV-C02 Visible Explorer 結果

### Run 1

```text
Explorer Count Before: 0
Explorer Count After Initialization: 1
Explorer Initialization: VISIBLE

Draft Count Before: 17
Inspector Count Before: 0

CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 238

Inspector / WordEditor / Word Document:
PASS (indirect)

CloseWithoutSave: PASS

Draft Count After: 17
Inspector Count After: 0

Draft Residue: NONE
Inspector Residue: NONE
MailItem Display: NONE
```

判定：

```text
TV-C02 Run 1 = PASS
```

### Run 2

```text
Explorer Count Before: 0
Explorer Count After Initialization: 1
Explorer Initialization: VISIBLE

Draft Count Before: 17
Inspector Count Before: 0

CreateMailFromTemplate: PASS
ReadBodyText: PASS
BodyText Length: 238

Inspector / WordEditor / Word Document:
PASS (indirect)

CloseWithoutSave: PASS

Draft Count After: 17
Inspector Count After: 0

Draft Residue: NONE
Inspector Residue: NONE
MailItem Display: NONE
```

判定：

```text
TV-C02 Run 2 = PASS
```

### TV-C02最終判定

```text
Cold Startから2回連続PASS
↓
TV-C02 = PASS
```

---

## 7. Lifecycle Evidence

TV-C02では両Runとも以下を確認した。

```text
Draft Count Before = 17
Draft Count After  = 17

Inspector Count Before = 0
Inspector Count After  = 0
```

したがって、

```text
Draft Residue = NONE
Inspector Residue = NONE
```

である。

また、Scan用MailItem自体については、

```text
MailItem Display = NONE
```

を維持したままWordEditor / Word Documentアクセスに成功した。

---

## 8. Technical Conclusion

検証結果より、Cold Start時のWordEditor初期化条件を以下まで特定した。

```text
Classic Outlook Cold Start
↓
Outlook.Application生成
↓
MAPI Session取得
↓
Explorer生成
↓
Explorer.Display
↓
Classic Outlook Explorer初期化
↓
CreateMailFromTemplate
↓
ReadBodyText
↓
WordEditor / Word Document Access PASS
```

一方、以下では成立しない。

```text
Classic Outlook Cold Start
↓
Outlook.Application生成
↓
MAPI Session取得
↓
Hidden Explorer生成
↓
ReadBodyText
↓
WordEditor Access FAIL
```

したがって、本Verificationで確認した環境では、

> **Cold Start状態からWordEditorを利用可能にするには、Visible Explorer Initializationが必要である。**

と結論する。

なお、本Verificationで確認したのは `Explorer.Display` を実行した場合に成立することであり、「画面が可視であること自体」がWordEditorの技術的必須条件であるとまでは断定しない。

---

## 9. Verification判定

検証仕様のDecision Rule：

```text
TV-C01 = FAIL
TV-C02 = PASS
Root Cause ConditionをExplorer可視化要否まで特定
```

を満たした。

最終判定：

```text
TV-P1-02-001
Classic Outlook Cold Start / WordEditor Initialization

Result:
PASS

Status:
CLOSED
```

---

## 10. Finding Classification

### Finding

```text
FI-P1-02-001
Classic Outlook Cold Start WordEditor Access Failure
```

### Root Cause Condition

```text
Classic Outlook未起動状態では、
Outlook.Application / MAPI / Hidden Explorerの初期化だけでは
Inspector.WordEditorが利用可能状態にならない。

Explorer.Displayを伴うVisible Explorer Initialization後は
WordEditor Accessが成立する。
```

### Classification

現時点では以下とする。

```text
Technical Condition identified
+
Visible Side Effectあり
↓
Design / UX Impact Review
```

本Verification結果だけを根拠にProductionへ `Explorer.Display` を自動採用しない。

---

## 11. Design / UX Impact Reviewへの引継ぎ

検討候補：

```text
A. ツール側でClassic Outlookを起動する
B. ユーザーへClassic Outlookの事前起動を要求する
```

現時点の優先方針：

```text
A. ツール側でClassic Outlookを起動する
```

理由：

- ユーザーへ新しい事前操作を要求せずに済む可能性がある
- 既存MVPの利用者向けRequirementsを維持できる可能性が高い
- Scan用MailItem自体はDisplayせずにWordEditor Accessを成立させられることを確認済み
- Draft / Inspector残存なしを維持できている

ただし、以下はDesign / UX Impact Reviewで確定する。

```text
Classic Outlookが未起動だった場合のみ起動するか
Explorerをどの画面で起動するか
Explorer Lifecycleを誰が所有するか
ツール起動Explorerを処理後にCloseするか
既存Outlook起動中の場合の挙動
ユーザーが利用中のOutlook Explorerへ影響を与えないか
Error時のExplorer Cleanup
```

本Result RecordではProduction実装方式を確定しない。

---

## 12. P1-02への影響

Technical Verification自体はPASS / CLOSEDとする。

ただしP1-02全体は、Cold Start対応のProduction方針およびProduction Patchが未確定であるため、現時点ではCOMPLETEとしない。

```text
P1-02 Production WordEditor Connection:
IMPLEMENTED

Warm Start Verification:
PASS

Cold Start Technical Verification:
PASS / CLOSED

Cold Start Production Resolution:
OPEN

P1-02 Overall:
NOT COMPLETE
```

---

## 13. 次アクション

```text
1. Design / UX Impact Review
   ↓
2. Candidate A:
   ツール側でClassic Outlookを起動する方式を詳細化
   ↓
3. Production Responsibility / Lifecycle決定
   ↓
4. modOutlookAdapter Production Patch
   ↓
5. VBA Compile
   ↓
6. Cold Start Regression
   ↓
7. Warm Start Regression
   ↓
8. Draft / Inspector / Explorer Lifecycle確認
   ↓
9. P1-01 Regression
   ↓
10. P1-02 PASS / COMPLETE判定
```

---

## 14. Final Result

```text
TV-P1-02-001
Classic Outlook Cold Start / WordEditor Initialization

TV-C01 Hidden Explorer:
FAIL

TV-C02 Visible Explorer:
PASS
- Cold Start Run 1: PASS
- Cold Start Run 2: PASS

Technical Condition:
Visible Explorer Initialization required
in the verified environment

MailItem Display:
NONE

Draft Residue:
NONE

Inspector Residue:
NONE

Result:
PASS

Status:
CLOSED
```
