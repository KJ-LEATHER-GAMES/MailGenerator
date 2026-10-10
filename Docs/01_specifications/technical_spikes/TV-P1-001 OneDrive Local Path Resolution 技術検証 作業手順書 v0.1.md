# TV-P1-001 OneDrive Local Path Resolution 技術検証 作業手順書 v0.1

## 1. 文書情報

| 項目                | 内容                                                  |
| ----------------- | --------------------------------------------------- |
| 文書名               | TV-P1-001 OneDrive Local Path Resolution 技術検証 作業手順書 |
| Version           | v0.1                                                |
| Verification ID   | TV-P1-001                                           |
| Related Finding   | DF-P1-001                                           |
| 対象Phase           | P1 Walking Skeleton                                 |
| 対象Task            | P1-01 OFT Path / Outlook Connection                 |
| 文書種別              | Implementation Technical Verification               |
| Production Code変更 | なし                                                  |
| Design変更          | なし                                                  |
| Formal MVP Test   | 対象外                                                 |

---

# 2. 背景

P1-01において、以下のProduction Flowを検証した。

```text
Settings
↓
TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
CloseWithoutSave
```

`ThisWorkbook.Path` がOneDrive環境で以下を返した。

```text
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
```

この値から生成したOFT Pathを `CreateMailFromTemplate` へ渡したところFAILした。

一方、同じOFTを以下のローカル同期Pathで指定した場合はPASSした。

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

確認結果：

```text
Web URL Path      → FAIL
Local Sync Path   → PASS
```

この結果から、以下をDesign Findingとして扱う。

```text
DF-P1-001

ThisWorkbook.Path がOneDrive Web URLを返す環境では、
現在のWorkbook Relative Path Resolutionだけでは、
Outlook CreateItemFromTemplateで利用可能な
Windows Local File Pathを生成できない。
```

---

# 3. 目的

本Verificationでは、以下を確認する。

> OneDrive Web URLから、ユーザー名やOneDrive Rootをハードコードせず、Outlookが利用可能なローカル同期Pathを再現可能に生成できるか。

最終的に以下が成立することを確認する。

```text
ThisWorkbook.Path
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
        ↓
Local OneDrive Root取得
        ↓
相対Path抽出
        ↓
Local Workbook Path生成
        ↓
TemplatePath結合
        ↓
Local OFT Path生成
        ↓
OFT存在確認
        ↓
CreateMailFromTemplate
        ↓
PASS
```

---

# 4. Technical Question

## TQ-01

以下のOneDrive Web URLから、

```text
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
```

以下に相当するWindows Local Pathを、ハードコードせず生成できるか。

```text
C:\Users\<User>\OneDrive\ドキュメント\MailGenerator
```

---

# 5. 検証対象

## 5.1 In Scope

以下を検証する。

1. `ThisWorkbook.Path` の取得
2. OneDrive関連環境変数の取得
3. Local OneDrive Root候補の特定
4. Web URLから相対Pathを抽出
5. Local Workbook Path生成
6. `TemplatePath`との結合
7. OFTファイル存在確認
8. `CreateMailFromTemplate`実行
9. `CloseWithoutSave`による後処理

---

## 5.2 Out of Scope

以下は今回実施しない。

```text
Production modSettingsData変更
Production modOutlookAdapter変更
MVP Design変更
Requirements変更

OneDrive for Business完全対応
SharePoint一般URL対応
複数OneDrive Account完全対応
Box / Cloudrive対応
UNC Path対応
Network Drive対応

P1-02 WordEditor
Template Scanner
Render
Unresolved Check
Dynamic UserForm
Formal MVP Test
```

---

# 6. 使用する既存Asset

## 6.1 Workbook

```text
MailGenerator.xlsm
```

---

## 6.2 OFT

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

既に以下が確認済み。

```text
CreateMailFromTemplate(Local Path)
= PASS
```

---

## 6.3 Settings

```text
Key:
TemplatePath

Value:
Templates\MailTemplate.oft
```

---

## 6.4 使用するProduction Module

```text
modSettingsData
modOutlookAdapter
COperationResult
CErrorInfo
```

Production Moduleのコードは本Verificationでは変更しない。

---

# 7. 作成するVerification Module

新規で以下を作成する。

```text
modP1OneDrivePathVerification.bas
```

文字コード：

```text
CP932
```

目的：

```text
検証専用
```

Production Moduleとして採用しない。

---

# 8. Verification全体フロー

```text
STEP 1
Precondition確認
        ↓
STEP 2
ThisWorkbook.Path取得
        ↓
STEP 3
OneDrive環境変数確認
        ↓
STEP 4
Local Root Candidate判定
        ↓
STEP 5
URL Relative Path抽出
        ↓
STEP 6
Local Workbook Path生成
        ↓
STEP 7
TemplatePath取得
        ↓
STEP 8
Local OFT Path生成
        ↓
STEP 9
OFT存在確認
        ↓
STEP 10
CreateMailFromTemplate
        ↓
STEP 11
CloseWithoutSave
        ↓
STEP 12
PASS / FAIL判定
```

---

# 9. STEP 1：Precondition確認

## 9.1 確認項目

以下を確認する。

```text
[ ] MailGenerator.xlsmがOneDrive上に存在する
[ ] MailTemplate.oftが存在する
[ ] Classic Outlookが使用可能
[ ] modOutlookAdapterがCompile済み
[ ] Local Path直接指定TestがPASS済み
```

今回すでに以下はEvidence取得済み。

```text
CreateMailFromTemplate:
PASS

Cleanup CloseWithoutSave:
PASS
```

---

# 10. STEP 2：ThisWorkbook.Path取得

Verification Moduleから以下を取得する。

```vb
ThisWorkbook.Path
```

Expected：

```text
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
```

Debug Output例：

```text
ThisWorkbook.Path:
https://d.docs.live.net/9053d70584a86a5b/ドキュメント/MailGenerator
```

## 判定

### PASS

```text
https://d.docs.live.net/
```

で始まる。

### NOT APPLICABLE

ローカルPathの場合。

例：

```text
C:\Users\...\OneDrive\...
```

この場合、DF-P1-001再現環境ではないためVerificationを終了する。

---

# 11. STEP 3：OneDrive環境変数取得

以下を取得する。

```vb
Environ$("OneDrive")
Environ$("OneDriveConsumer")
Environ$("OneDriveCommercial")
```

Debug Output例：

```text
Environment Variables:

OneDrive=
C:\Users\monsi\OneDrive

OneDriveConsumer=
C:\Users\monsi\OneDrive

OneDriveCommercial=
<empty>
```

## 注意

この時点では、どの値を正式採用するか決定しない。

実値をEvidenceとして取得するだけとする。

---

# 12. STEP 4：Local Root Candidate判定

現在の実環境で、以下と一致するRootが取得できるか確認する。

```text
Expected:
C:\Users\monsi\OneDrive
```

判定候補順：

```text
1. OneDrive
2. OneDriveConsumer
3. OneDriveCommercial
```

ただし、この順序はVerification用であり、Production Designとして確定しない。

## PASS条件

少なくとも1つから、

```text
C:\Users\monsi\OneDrive
```

相当が取得できる。

## FAIL条件

すべて空欄。

または、

既知のOneDrive Rootと一致する候補が存在しない。

---

# 13. STEP 5：URL Relative Path抽出

対象：

```text
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
```

以下を除去する。

```text
https://d.docs.live.net/<CID>/
```

Expected Relative Path：

```text
ドキュメント/MailGenerator
```

Windows Path用にSeparatorを正規化する。

Expected：

```text
ドキュメント\MailGenerator
```

Debug Output：

```text
Relative Workbook Path:
ドキュメント\MailGenerator
```

---

# 14. STEP 6：Local Workbook Path生成

取得したOneDrive Root：

```text
C:\Users\monsi\OneDrive
```

Relative Path：

```text
ドキュメント\MailGenerator
```

を結合する。

Expected：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator
```

Debug Output：

```text
Resolved Local Workbook Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator
```

## 禁止事項

以下をハードコードしない。

```text
monsi
C:\Users\monsi
C:\Users\monsi\OneDrive
```

---

# 15. STEP 7：TemplatePath取得

既存Production APIを使用する。

```vb
GetSettingValue("TemplatePath", templatePath)
```

Expected：

```text
Templates\MailTemplate.oft
```

Debug Output：

```text
TemplatePath:
Templates\MailTemplate.oft
```

---

# 16. STEP 8：Local OFT Path生成

以下を結合する。

```text
Local Workbook Path
+
TemplatePath
```

Expected：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

Debug Output：

```text
Resolved Local Template Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

---

# 17. STEP 9：OFT存在確認

この段階ではWindows Local File Pathが生成されているため、ファイル存在確認を実施する。

確認対象：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

Expected：

```text
Exists = True
```

Debug Output：

```text
File Exists: PASS
```

## FAIL時

以下を出力する。

```text
File Exists: FAIL

Target:
<Generated Local OFT Path>
```

この場合、Outlook Testへ進まない。

Fail Fastとする。

---

# 18. STEP 10：CreateMailFromTemplate実行

生成したLocal OFT Pathを、

```vb
modOutlookAdapter.CreateMailFromTemplate(...)
```

へ渡す。

Expected：

```text
Success = True
```

Debug Output：

```text
CreateMailFromTemplate: PASS
```

## FAIL時

以下を出力する。

```text
CreateMailFromTemplate: FAIL

ErrorType=
Message=
Target=
```

その時点でVerification FAILとする。

---

# 19. STEP 11：Cleanup

`CreateMailFromTemplate` がPASSした場合のみ、

```vb
modOutlookAdapter.CloseWithoutSave()
```

を実行する。

目的：

```text
Testで作成したMailItemを保存せず閉じる
```

Debug Output：

```text
Cleanup CloseWithoutSave: PASS
```

Cleanup Failureは別途記録する。

---

# 20. STEP 12：最終判定

## PASS条件

以下がすべて成立すること。

```text
[ ] OneDrive Rootを動的取得できた
[ ] User名をハードコードしていない
[ ] URL Relative Pathを抽出できた
[ ] Local Workbook Pathを生成できた
[ ] TemplatePathを取得できた
[ ] Local OFT Pathを生成できた
[ ] OFTが実在した
[ ] CreateMailFromTemplate PASS
[ ] CloseWithoutSave PASS
```

Expected Final Output：

```text
TV-P1-001: PASS
```

---

# 21. Expected Debug Output

成功時の想定：

```text
TV-P1-001: START

ThisWorkbook:
MailGenerator.xlsm

ThisWorkbook.Path:
https://d.docs.live.net/9053d70584a86a5b/ドキュメント/MailGenerator

Environment Variables:

OneDrive:
C:\Users\monsi\OneDrive

OneDriveConsumer:
C:\Users\monsi\OneDrive

OneDriveCommercial:
<empty>

Detected OneDrive Root:
C:\Users\monsi\OneDrive

Relative Workbook Path:
ドキュメント\MailGenerator

Resolved Local Workbook Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator

TemplatePath:
Templates\MailTemplate.oft

Resolved Local Template Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

File Exists: PASS

CreateMailFromTemplate: PASS

Cleanup CloseWithoutSave: PASS

TV-P1-001: PASS
```

---

# 22. Failure Classification

## Case A：環境変数取得FAIL

```text
OneDrive Rootを取得できない
```

判定：

```text
Candidate A = FAIL
```

次Action：

```text
Candidate B
OneDrive Account Metadata / UserFolder
```

のVerificationを検討する。

Production変更はまだ行わない。

---

## Case B：Relative Path変換FAIL

例：

```text
URL側のFolder構造
≠
Local OneDrive側のFolder構造
```

判定：

```text
単純なRoot置換方式では成立しない
```

次Action：

```text
Path Mapping方式を再検討
```

---

## Case C：Local Path生成成功 / File Exists FAIL

判定：

```text
Path Mapping不正
```

Outlookへ進まない。

---

## Case D：File Exists PASS / Outlook FAIL

判定：

```text
DF-P1-001以外の追加要因あり
```

確認対象：

```text
Outlook
OFT状態
Permission
File Lock
```

ただし既存Control TestがPASS済みなので、発生可能性は低い。

---

# 23. Verification結果の分類

## PASS

```text
TV-P1-001:
PASS
```

意味：

```text
OneDrive URL
↓
Local Sync Path

の解決方式に技術的成立性あり。
```

次工程：

```text
Design Impact Analysis
```

---

## CONDITIONAL PASS

例：

```text
OneDriveConsumerでは成立

ただし
Commercial / Multiple Account未確認
```

意味：

```text
Current MVP Environmentでは成立
```

次Action：

MVP Scopeとして十分かDesign判断する。

---

## FAIL

```text
TV-P1-001:
FAIL
```

意味：

```text
Candidate AではDF-P1-001を解決できない
```

次Action：

Candidate Bのみ追加検証する。

---

# 24. PASS後のDesign Impact Review

TV-P1-001 PASS後、以下を評価する。

| 対象               | 初期判定         |
| ---------------- | ------------ |
| DOC-MVP-REQ      | Not Affected |
| DOC-MVP-DES      | Affected     |
| DOC-TS-A         | Not Affected |
| DOC-MVP-TESTSPEC | Needs Review |
| Implementation   | Affected     |

この時点で初めてDesign変更案を作成する。

---

# 25. Production実装の開始条件

以下を満たすまでProductionコードを変更しない。

```text
[ ] TV-P1-001完了
[ ] PASS / CONDITIONAL PASS判定
[ ] Path Resolution方式決定
[ ] Design Impact確認
[ ] Production責務配置決定
```

---

# 26. Production実装後のRegression

Production実装後は、新しいVerification Testだけではなく、元のP1-01 Smoke Testを再実行する。

期待する最終経路：

```text
Settings
↓
TemplatePath
↓
Resolve Workbook Relative Path
↓
Local OFT Path
↓
CreateMailFromTemplate
↓
CloseWithoutSave
```

Expected：

```text
Settings / Path Resolution: PASS
CreateMailFromTemplate: PASS
Close Without Save: PASS

TestP1OftConnection: PASS
```

---

# 27. DF-P1-001 Close条件

以下をすべて満たした場合のみCloseする。

```text
[ ] TV-P1-001 PASS
[ ] Design Decision完了
[ ] 必要なDesign変更完了
[ ] Production実装完了
[ ] VBA Compile PASS
[ ] P1-01 Regression PASS
```

その後：

```text
DF-P1-001 = CLOSED

P1-01 =
PASS / COMPLETE
```

---

# 28. 次Task

DF-P1-001 Close後、

```text
P1-02
Inspector / WordEditor Connection
```

へ移行する。

---

# 29. 今回の実作業順

実際の作業は以下の順序で行う。

```text
1.
modP1OneDrivePathVerification.bas を作成

2.
VBEへImport

3.
Debug → Compile VBAProject

4.
Verification Macro実行

5.
Immediate Window全文保存

6.
環境変数取得結果確認

7.
Local Path変換結果確認

8.
File Exists確認

9.
CreateMailFromTemplate結果確認

10.
TV-P1-001 PASS / CONDITIONAL PASS / FAIL判定

11.
結果をEvidenceとして保存

12.
Design Impact Analysisへ進む
```

---

# 30. Do Not

本Verification中は以下を行わない。

```text
× modSettingsDataを変更する

× modOutlookAdapterを変更する

× OneDrive Rootをハードコードする

× C:\Users\monsi をProductionコードへ埋め込む

× Verification PASSだけでDesignを自動変更する

× Commercial対応を先回り実装する

× 複数Account対応を先回り実装する

× P1-02へ並行着手する

× Requirementsを変更する

× Technical Spike B/Cへ自動昇格する
```

---

# 31. 完了条件

本作業手順書に基づくVerificationは、以下のいずれかに到達した時点で完了とする。

### PASS

```text
OneDrive Root取得
+
URL → Local Path変換
+
OFT存在
+
CreateMailFromTemplate PASS
```

### CONDITIONAL PASS

```text
現在のMVP環境では成立するが、
追加環境条件が未検証
```

### FAIL

```text
Candidate Aでは安定したLocal Path Resolutionが成立しない
```

いずれの場合も、Production変更前に結果をレビューする。
