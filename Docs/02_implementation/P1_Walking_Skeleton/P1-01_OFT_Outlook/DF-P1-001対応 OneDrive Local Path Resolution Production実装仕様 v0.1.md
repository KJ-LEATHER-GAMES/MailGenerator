# DF-P1-001対応 OneDrive Local Path Resolution Production実装仕様 v0.1

## 1. 目的

OneDrive上のWorkbookで `ThisWorkbook.Path` が以下のWeb URLを返す場合でも、

```text
https://d.docs.live.net/<CID>/...
```

Outlook `CreateItemFromTemplate` で利用可能なWindowsローカルPathへ解決する。

対象Finding：

```text
DF-P1-001
```

---

## 2. 対象Module

変更対象：

```text
modSettingsData
```

対象公開API：

```vb
ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult
```

公開APIのシグネチャは変更しない。

`modOutlookAdapter` は変更しない。

---

## 3. 基本動作

### 3.1 Local Workbook Pathの場合

例：

```text
C:\Work\MailGenerator
```

従来どおり、

```text
ThisWorkbook.Path
+
relativePath
```

で絶対Pathを生成する。

---

### 3.2 OneDrive Web URLの場合

対象：

```text
https://d.docs.live.net/<CID>/...
```

以下の順で解決する。

```text
ThisWorkbook.Path
↓
<CID>より後ろの相対Pathを抽出
↓
OneDrive Local Root候補を取得
↓
Local Workbook Path候補を生成
↓
存在するWorkbook Directoryを特定
↓
relativePathを結合
↓
absolutePathとして返却
```

---

## 4. OneDrive Root候補

以下の環境変数を候補とする。

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

空欄は無視する。

同一Pathは重複候補として扱わない。

ユーザー名、以下のようなPathはハードコードしない。

```text
C:\Users\monsi
C:\Users\monsi\OneDrive
```

---

## 5. Root選択ルール

各Root候補とURL相対PathからLocal Workbook Path候補を生成する。

例：

```text
Root:
C:\Users\monsi\OneDrive

Relative:
ドキュメント\MailGenerator

Candidate:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator
```

判定：

```text
存在する候補 = 0件
→ ConfigurationError

存在する候補 = 1件
→ 採用

存在する異なる候補 >= 2件
→ ConfigurationError
```

複数候補時に先頭候補を自動採用しない。

---

## 6. Path正規化

結合時は以下を行う。

```text
/ → \
```

先頭・末尾の余分なPath Separatorを除去する。

最終例：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

---

## 7. File存在確認の責務

`ResolveWorkbookRelativePath` の責務は、

> 利用可能な絶対Pathを解決すること

までとする。

対象ファイルそのものの存在確認は必須責務としない。

ただしOneDrive Root判定時には、

```text
Local Workbook Directoryが存在するか
```

を候補特定のために確認する。

OFT存在確認は呼び出し側または後続処理の責務とする。

---

## 8. Error条件

最低限以下をErrorとする。

| 条件                      | Error              |
| ----------------------- | ------------------ |
| `relativePath`空欄        | ConfigurationError |
| Workbook未保存             | ConfigurationError |
| 絶対Path指定                | ConfigurationError |
| OneDrive Root候補0件       | ConfigurationError |
| Local Workbook Path候補0件 | ConfigurationError |
| 異なるLocal候補が複数存在         | ConfigurationError |
| 予期しないVBA Runtime Error  | UnexpectedError    |

Error情報には可能な範囲で以下を含める。

```text
ErrorType
Message
Target
```

---

## 9. 対象外

本対応では以下を実装しない。

```text
SharePoint一般URL対応
OneDrive Account Metadata / Registry参照
複数Accountの高度な自動判定
Box / Cloudrive対応
UNC変換
Network Drive対応
URLからのFile Download
```

必要性が確認された場合のみ別Findingとして扱う。

---

## 10. Smoke Test

最低限以下を確認する。

### Case 1：通常Local Path

```text
ThisWorkbook.Path:
Windows Local Path

Expected:
従来どおりWorkbook相対Pathを解決
```

### Case 2：OneDrive Web URL

```text
ThisWorkbook.Path:
https://d.docs.live.net/...

Expected:
Local OneDrive Pathへ変換
```

### Case 3：OneDrive Root取得不可

```text
Expected:
ConfigurationError
```

### Case 4：Local Workbook候補なし

```text
Expected:
ConfigurationError
```

---

## 11. P1-01完了条件

以下をすべて満たした場合、DF-P1-001をClose候補とする。

```text
VBA Compile PASS
+
ResolveWorkbookRelativePath PASS
+
Local OFT Path生成 PASS
+
CreateMailFromTemplate PASS
+
CloseWithoutSave PASS
+
Original P1-01 Smoke Test PASS
```

その後、

```text
DF-P1-001 = CLOSED
P1-01 = PASS / COMPLETE
```

とする。
