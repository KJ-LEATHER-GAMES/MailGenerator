

# 引き継ぎまとめ

## 現在地

- プロジェクト：定型メール作成ツール
- Current Phase：**P1 Walking Skeleton**
- P0 Foundation：**COMPLETE**
- CP-P0：**ESTABLISHED**
- P1-01 OFT Path / Outlook Connection：**PASS / COMPLETE**
- DF-P1-001 OneDrive Local Path Resolution：**CLOSED**
- TV-P1-001 OneDrive Local Path Resolution Verification：**PASS**
- 最新Design：`DOC-MVP-DES / MVP Design v0.1.8` / Approved
- 最新Test Specification：`DOC-MVP-TESTSPEC / MVP Test Specification v0.1.4` / Approved扱い
- Current Approved Baseline：**BL-MVP-001 維持**
- 次の文書管理Task：**BL-MVP-002 Candidate作成**
- 次の実装Task：**P1-02 Inspector / WordEditor Connection**

---

# 実施内容

## 1. P1-01 OFT Path / Outlook Connectionの実装仕様作成

P0完了後の最初のP1 Walking Skeletonとして、

```text
Settings
↓
TemplatePath
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
MailItem取得
↓
CloseWithoutSave
```

を最小Production Flowとして定義した。

作成物：

- `P1-01 OFT Path Outlook Connection 実施仕様 v0.1.md`
- `modOutlookAdapter_CP932.bas`
- `modP1OftConnectionSmokeTest_v0.1_CP932.bas`
- `P1-01 README.txt`
- `P1-01 OFT Path Outlook Connection v0.1.zip`

`modOutlookAdapter` はOutlook依存を閉じ込めるInfrastructure Moduleとし、P1-01では以下を公開。

```vb
CreateMailFromTemplate(...)
CloseWithoutSave()
```

Outlookの生API `CreateItemFromTemplate` はAdapter内部で使用する設計とした。

---

## 2. OneDrive Web URLによるP1-01 FAILを検出

最初のP1-01実行では以下を確認。

```text
ThisWorkbook.Path:
https://d.docs.live.net/<CID>/ドキュメント/MailGenerator
```

`ResolveWorkbookRelativePath` により、

```text
https://d.docs.live.net/.../MailGenerator\Templates\MailTemplate.oft
```

が生成され、Classic Outlookの `CreateItemFromTemplate` がFAILした。

`\` を `/` に変更しても結果は変わらなかった。

これにより、Separatorではなく、

```text
https://d.docs.live.net/...
```

というWeb URL形式自体が原因候補となった。

---

## 3. Local Path Control Testを実施

同じ `MailTemplate.oft` をOneDriveのローカル同期Pathで直接指定して確認。

使用Path：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

作成物：

- `modP1CreateMailFromTemplateSmokeTest_v0.1_CP932.bas`

結果：

```text
CreateMailFromTemplate: PASS
Cleanup CloseWithoutSave: PASS
TestCreateMailFromTemplateLocalPath: PASS
```

これにより、

```text
OneDrive保存そのもの
→ 問題なし

OneDrive Local Sync Path
→ Outlookで利用可能

d.docs.live.net Web URL
→ Outlook OFT Pathとして直接利用不可
```

と切り分けた。

---

## 4. DF-P1-001をDesign Findingとして確定

Finding：

```text
DF-P1-001
OneDrive Local Path Resolution
```

Root Cause：

```text
ThisWorkbook.PathがOneDrive Web URLを返す環境で、
Workbook Relative Path Resolutionが
Web URLをWindows File Pathとして扱っていた。
```

以下は原因ではないと確認。

- OFTファイル自体
- Classic Outlook
- `modOutlookAdapter`
- OneDriveへの保存そのもの
- Path Separatorのみの問題

---

## 5. TV-P1-001小規模Technical Verificationを計画・実施

DF-P1-001解決方式の技術成立性確認として、

```text
TV-P1-001
OneDrive Local Path Resolution Verification
```

を定義。

確認フロー：

```text
ThisWorkbook.Path
↓
OneDrive環境変数取得
↓
URL Relative Path抽出
↓
Local OneDrive Root特定
↓
Local Workbook Path生成
↓
TemplatePath結合
↓
OFT存在確認
↓
CreateMailFromTemplate
```

使用した環境変数：

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

作成物：

- `TV-P1-001 OneDrive Local Path Resolution 技術検証 作業手順書 v0.1`
- `modP1OneDrivePathVerification.bas`

実行結果：

```text
OneDrive=C:\Users\monsi\OneDrive
OneDriveConsumer=C:\Users\monsi\OneDrive
OneDriveCommercial=<empty>

Relative Workbook Path:
ドキュメント\MailGenerator

Resolved Local Workbook Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator

Resolved Local Template Path:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

File Exists: PASS
CreateMailFromTemplate: PASS
Cleanup CloseWithoutSave: PASS

TV-P1-001: PASS
```

Candidate A：

```text
OneDrive環境変数
+
d.docs.live.net URL Relative Path Mapping
```

の技術成立性を確認した。

---

## 6. DF-P1-001対応Production実装仕様を作成

作成：

- `DF-P1-001対応 OneDrive Local Path Resolution Production実装仕様 v0.1`

主な仕様：

```text
ResolveWorkbookRelativePathの公開APIは維持
```

Windows Local Pathの場合：

```text
ThisWorkbook.Path
+
relativePath
```

OneDrive Web URLの場合：

```text
d.docs.live.net URL
↓
CIDより後ろのRelative Path抽出
↓
OneDrive Root候補取得
↓
実在Workbook Directory確認
↓
一意なLocal Root決定
↓
relativePath結合
```

Root候補：

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

判定：

```text
実在候補0件
→ ConfigurationError

実在する異なる候補1件
→ 採用

実在する異なる候補2件以上
→ ConfigurationError
```

同一Rootは重複除外。

ユーザー名・OneDrive Rootはハードコードしない。

---

## 7. MVP Design v0.1.8へ最小Semantic Patch反映

Design変更箇所を整理後、

- `MVP Design v0.1.8 日本語版.md`

を全文生成。

主な変更：

- v0.1.8更新概要
- §9.3 Path Resolution
- §10.3 `modSettingsData`責務
- §25.1 手動同期シーケンス
- §25.2 UserForm起動シーケンス
- §25.3 メール生成シーケンス
- §27 D17追加

D17：

```text
Workbook Relative Path Resolution
```

Requirements、Technical Spike A、`modOutlookAdapter`、Route W等は変更していない。

---

## 8. `modSettingsData`をProduction仕様へ修正

作成：

- `modSettingsData_DF-P1-001_v0.1_CP932.bas`
- `modSettingsData.bas`

公開APIは維持。

```vb
GetSettingValue(...)
ResolveWorkbookRelativePath(...)
```

`ResolveWorkbookRelativePath` にOneDrive Web URL対応を追加した。

---

## 9. Workbook固有の「Out of memory (Error 7)」問題が発生

Resolver Smoke Test Moduleを追加しようとしたところ、

```text
Out of memory (Error 7)
```

が発生。

確認結果：

- Excel再起動でも改善なし
- PC再起動でも改善なし
- Smoke Test Module削除でも改善なし
- xlsxとして保存しVBAを除去しても再現
- 新規Workbookでは正常
- 過去の別Workbookでも正常

そのため、

```text
MailGenerator Workbook固有の破損
または内部不整合
```

を強く疑った。

ユーザー判断：

```text
ファイルを作り直す
```

新規WorkbookへProduction Assetを復元した。

現在のP1-01実行ログ上のWorkbook名：

```text
MailGenerator3.xlsm
```

---

## 10. 新規WorkbookへProduction Moduleを再構築

復元対象として整理したProduction Asset：

### Classes

```text
CErrorInfo
COperationResult
```

### Modules

```text
modResult
modSettingsData
modVariableDefinitionData
modOptionMasterData
modOutlookAdapter
```

Smoke Testは最小限のみ追加。

```text
modResolveWorkbookRelativePathSmokeTest
modP1OftConnectionSmokeTest
```

---

## 11. Resolver Smoke Test初版の不具合を修正

最初に生成したResolver Smoke Testで、

```vb
"Templates\\MailTemplate.oft"
```

のように記載してしまっていた。

VBAでは `\` はエスケープ文字ではないため、

```text
\\
```

は本当に2文字のバックスラッシュになる。

結果：

```text
...\Templates\\MailTemplate.oft
```

となった。

また、

```vb
Mid$(..., 3, 1) <> "\\"
```

としていたためWindows絶対Path判定も誤ってFAILしていた。

修正版：

- `modResolveWorkbookRelativePathSmokeTest_v0.2_CP932.bas`

主要修正：

```vb
"Templates\MailTemplate.oft"
"C:\Temp\MailTemplate.oft"
Replace(..., "/", "\")
```

Production `modSettingsData` 側には同じ問題がないことを確認。

---

## 12. Resolver Smoke Test PASS

実行結果：

```text
[Case 1] Workbook-relative path resolution
PASS

ResolvedPath=
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

Case 2：

```text
Empty relative path
→ ConfigurationError
→ PASS
```

Case 3：

```text
Absolute path rejection
C:\Temp\MailTemplate.oft
→ ConfigurationError
→ PASS
```

最終：

```text
TestResolveWorkbookRelativePath: PASS
```

---

## 13. 元のP1-01 Smoke Test Regression PASS

実行結果：

```text
TemplatePath:
Templates\MailTemplate.oft

ResolvedPath:
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft

Settings / Path Resolution: PASS
CreateItemFromTemplate: PASS
Close Without Save: PASS

TestP1OftConnection: PASS
```

これによりProduction Flow：

```text
Settings
↓
TemplatePath
↓
ResolveWorkbookRelativePath
↓
OneDrive Local Path Resolution
↓
CreateMailFromTemplate
↓
MailItem
↓
CloseWithoutSave
```

がEnd-to-Endで成立した。

---

## 14. DF-P1-001をCLOSED判定

Close条件をすべて確認。

```text
Root Cause特定            PASS
TV-P1-001                 PASS
Design Decision           PASS
Design v0.1.8反映         PASS
Production実装            PASS
VBA Compile               PASS
Resolver Smoke Test       PASS
P1-01 Regression          PASS
```

判定：

```text
DF-P1-001 = CLOSED
P1-01 = PASS / COMPLETE
```

---

## 15. Close / Completion / Impact文書を作成

作成：

- `DF-P1-001 Close Record v0.1.md`
- `P1-01 OFT Path Outlook Connection Completion Record v0.1.md`
- `MVP Test Specification DF-P1-001 Impact Review v0.1.md`
- `P1-01 Document Management Records v0.1.zip`

---

## 16. Test Specification Impact Review

当初、

```text
DOC-MVP-TESTSPEC v0.1.3
```

を確認したところ、

`MTS-TPL-001` のExpectedに、

```text
ThisWorkbook.Path + TemplatePath
```

という旧Design前提が残っていた。

したがって、

```text
Impact = AFFECTED
```

と判定。

新規Test IDは追加せず、

```text
MTS-TPL-001
MTS-ERR-001
```

を修正する方針とした。

---

## 17. MVP Test Specification v0.1.4 Candidate作成

作成：

- `MVP Test Specification v0.1.4 Candidate 日本語版.md`

初回変更：

### MTS-TPL-001

- Windows Local Path Variant
- OneDrive Web URL Variant
- Resolved Local Path Evidence追加

### MTS-ERR-001

- Workbook Relative Path / OneDrive Local Path Resolution Error追加

Test Case総数：

```text
69件維持
```

---

## 18. Design v0.1.8 × Test Spec v0.1.4 初回整合性レビュー

初回判定：

```text
CONDITIONAL PASS
```

理由：

Designでは以下を定義していたが、

```text
OneDrive Root候補0件
Local Workbook Path候補0件
異なる候補複数件
```

Test Specificationで具体的にTestされていなかった。

分類：

```text
Semantic Conflict = NONE
Test Coverage Gap = あり
```

---

## 19. Test Specification v0.1.4 Candidateを修正

MTS-TPL-001へ追加：

```text
Variant C
OneDrive Local Root候補なし

Variant D
Local Workbook Path候補なし

Variant E
異なるLocal Workbook Path候補が複数存在
```

Expected：

```text
ConfigurationError
OFT存在確認へ進まない
Outlook処理へ進まない
```

MTS-ERR-001へ追加：

```text
Design §9.3
Design §24
Design §25.1〜25.3
```

および、

```text
ConfigurationError
Message
Target
Fail Fast
```

を明示。

Test ID：

```text
69件
```

を維持。

---

## 20. Design v0.1.8 × Test Spec v0.1.4 再整合性レビュー

最終判定：

```text
Semantic Conflict:
NONE

Blocking Test Gap:
NONE

Traceability Break:
NONE

Requirement Impact:
NONE

Test Case Count:
69

Cross-document Consistency:
PASS
```

したがって、

```text
DOC-MVP-TESTSPEC v0.1.4
→ Approved可能
```

と判定。

---

## 21. Document Registry更新

更新：

- `定型メール作成ツール Project Document Registry and Approved Baseline v0.3.md`
- 最終的に `v0.4.md`

最新：

```text
定型メール作成ツール Project Document Registry and Approved Baseline v0.4.md
```

v0.4で記録：

```text
DOC-MVP-DES
Latest = v0.1.8
Status = Approved

DOC-MVP-TESTSPEC
Latest = v0.1.4
Status = Approved
Baseline Version = v0.1.3
```

Current Approved Baseline：

```text
BL-MVP-001
```

は維持。

次Action：

```text
BL-MVP-002 Candidate作成
```

想定構成：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

---

# 決定事項

## P1-01

- `P1-01 OFT Path / Outlook Connection` は **PASS / COMPLETE**。
- `DF-P1-001` は **CLOSED**。
- `TV-P1-001` は **PASS**。

---

## OneDrive Path Resolution

- OneDriveへOFTを保存すること自体は問題なし。
- Classic OutlookはOneDrive Local Sync PathのOFTを開ける。
- `https://d.docs.live.net/...` をOFT Pathとして直接使用しない。
- `ThisWorkbook.Path` が `d.docs.live.net` の場合はLocal OneDrive Pathへ解決する。
- Root候補は以下から取得。

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

- 同一Rootは重複除外。
- User名や `C:\Users\xxx\OneDrive` をハードコードしない。
- 実在するLocal Workbook Directoryを利用してRootを一意に決定。
- 候補0件・複数件は `ConfigurationError`。
- 複数候補の場合に先頭候補を勝手に採用しない。

---

## Production責務

- OneDrive Local Path Resolutionは `modSettingsData.ResolveWorkbookRelativePath` に保持。
- 新しいPath専用Moduleは追加しない。
- `ResolveWorkbookRelativePath` の公開APIは変更しない。
- `modOutlookAdapter` は変更しない。
- OFTファイルそのものの存在確認はPath Resolverの主責務にはしない。

---

## Design

- `MVP Design v0.1.8` をLatest Approved Designとする。
- DF-P1-001対応はSemantic Design Change。
- Requirements変更は不要。
- Technical Spike A変更は不要。
- `modOutlookAdapter`変更は不要。

---

## Test Specification

- `MVP Test Specification v0.1.4` はDesign v0.1.8との再整合性レビュー **PASS**。
- Latest Approved Test Specificationとして扱う。
- Test Case数は **69件維持**。
- 新規Test IDは増やさない。
- Path Resolution正常系・異常系は既存 `MTS-TPL-001` / `MTS-ERR-001` へ統合。

---

## Baseline

- Current Approved Baselineは **BL-MVP-001を維持**。
- Latest VersionがApprovedになっただけではBaselineを自動更新しない。
- 次に `BL-MVP-002 Candidate` を作成する。
- 想定構成：

```text
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

---

## VBA / Test運用

- VBAでは `\` はエスケープ不要。
- `"\\ "`のように記述すると実際に2文字になる。
- Smoke Testは `Debug.Assert` ではなくFail-Fast型。
- Technical VerificationコードをそのままProduction化しない。
- Verification → Design → Production仕様 → 実装 → Regressionの順を維持する。

---

# 未解決事項

## 1. BL-MVP-002 Candidate未作成

現在：

```text
Current Approved Baseline = BL-MVP-001
```

次に、

```text
BL-MVP-002 Candidate
```

を作成する必要がある。

Candidate作成後、

- Baseline Manifest確認
- Baseline Quality Gate
- Cross-document consistency最終確認
- Approval

が必要。

---

## 2. Test Specification v0.1.4の物理ファイル状態

文書管理上は、

```text
DOC-MVP-TESTSPEC v0.1.4
Status = Approved
```

としてRegistryへ登録済み。

ただし作成ファイル名は、

```text
MVP Test Specification v0.1.4 Candidate 日本語版.md
```

のまま。

**要確認：**

- Approved版としてファイル名・文書内Statusから `Candidate` を外した正式ファイルを作成するか。

文書管理上は正式Approved Artifactを作っておく方が自然。

---

## 3. Workbook再構築後の完全Regression

新規Workbookへ再構築後、

- Resolver Smoke Test
- P1-01 Smoke Test

はPASS済み。

ただしP0全体のIntegration Smoke Testを新Workbookで再度実行したかは、この会話では未確認。

必要なら、

```text
modP0FoundationIntegrationSmokeTest
```

を再投入してRegression確認する余地あり。

Blockingかどうかは要判断。

---

## 4. Workbook破損原因

旧Workbookで発生した、

```text
Out of memory (Error 7)
```

について、

```text
Workbook固有の破損 / 内部不整合
```

を強く疑ったが、内部XML等を解析して原因箇所を特定してはいない。

新Workbookへ再構築したため、開発Blockingではない。

---

## 5. OneDrive Commercial / 複数Account

今回実測した環境：

```text
OneDrive
= C:\Users\monsi\OneDrive

OneDriveConsumer
= C:\Users\monsi\OneDrive

OneDriveCommercial
= <empty>
```

OneDrive Personal環境では成立確認済み。

以下は未確認：

- OneDrive for Business
- 複数異なるOneDrive Account
- Commercial環境

MVP Scopeで追加検証が必要かは要判断。

現時点ではBlocking Findingにはしていない。

---

## 6. P1-02以降

未実装：

```text
P1-02 Inspector / WordEditor Connection
P1-03 Subject / BodyText Snapshot
P1-04 Minimal Template Scanner
P1-05 Minimal Render
P1-06 Unresolved Check
P1-07 Display / Lifecycle
```

---

# 次アクション

## 優先度1：BL-MVP-002 Candidate作成

最初に見るファイル：

```text
定型メール作成ツール Project Document Registry and Approved Baseline v0.4.md
```

想定Baseline：

```text
BL-MVP-002 Candidate

DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4
```

確認事項：

- 必要Documentが揃っている
- Blocking Requirement Gapなし
- Blocking Design Gapなし
- Blocking Test Gapなし
- Semantic Conflictなし
- Traceability成立
- Test Case 69件維持
- DF-P1-001 CLOSED
- P1-01 PASS / COMPLETE

PASS後：

```text
BL-MVP-002
→ Approved
```

を検討。

---

## 優先度2：Test Specification v0.1.4 Approved Artifact整理

現在のCandidateファイルを正式版へ整理する。

候補：

```text
MVP Test Specification v0.1.4 日本語版.md
```

文書状態：

```text
Approved
```

内容そのものは再整合性レビューPASS済み。

---

## 優先度3：P1-02 Inspector / WordEditor Connection

Baseline管理が整理できたら開発へ戻る。

次のProduction Vertical Slice：

```text
Settings
↓
TemplatePath
↓
Local OFT Path
↓
modOutlookAdapter
↓
MailItem
↓
Inspector
↓
WordEditor
```

P1-02の目的：

> Production Module Boundary上で `MailItem → Inspector → WordEditor` を取得できることを確認する。

Technical Spike AではWordEditor成立性は確認済み。

P1-02ではProduction Architectureでの再接続を行う。

最初に見るファイル：

- `MVP Design v0.1.8 日本語版.md`
- `Technical Spike A 実施仕様書 v0.4 日本語版_CLOSED.md`
- `Implementation Plan v0.1 日本語版.md`
- 最新 `modOutlookAdapter`
- P1-01 Completion Record

---

## 優先度4：必要なら新Workbook P0 Regression

再構築したWorkbookについて、

```text
COperationResult / CErrorInfo
Settings
VariableDefinition
OptionMaster
```

のP0 Integration Smoke Test再実行を検討。

P1-01はすでにPASSしているため、必須Blocking扱いにするかは次チャットで判断可能。

---

# 気づき

## OneDriveは「使えない」のではなくPath表現が問題だった

当初、

```text
OneDrive上のOFTだからOutlookで開けない？
```

という疑問があった。

実際には、

```text
OneDrive Local Sync Path
→ PASS

OneDrive Web URL
→ FAIL
```

だった。

問題は保存媒体ではなく、

```text
APIが期待するPath形式
```

だった。

---

## Control Testの価値

同一の、

- OFT
- Outlook
- PC
- User

を維持し、

```text
Web URL
vs
Local Path
```

だけを変えたことでRoot Causeをかなり明確に切り分けられた。

「問題が起きたらすぐ修正する」のではなく、

```text
変更変数を1つにするControl Test
```

が有効だった。

---

## Design Findingをすぐ実装で潰さない

DF-P1-001では、

```text
Local Path変換が必要そう
```

と分かってもすぐProductionコードを書かなかった。

```text
Finding
↓
Technical Verification
↓
Production仕様
↓
Design
↓
Implementation
↓
Regression
```

という順序を守ったことで、

- なぜ変えるか
- 何を変えるか
- どこまで変えるか

を追跡可能にできた。

---

## VBAのバックスラッシュは一般的言語と違う

Python / C系の感覚で、

```text
\\
```

を書いてしまうとVBAでは本当に2文字になる。

VBAでは、

```vb
"C:\Temp\File.txt"
```

でよい。

生成AIが複数言語を跨いでコード生成する際に起こり得る典型的ミス。

Smoke Test自身もTest対象になり得るという学びになった。

---

## Smoke TestのFAILはProduction不具合とは限らない

Resolver Smoke Test初版は、

```text
Production Resolver
```

ではなく、

```text
Test Code
```

自身にBugがあった。

したがって、

```text
TestがFAIL
≠
ProductionがFAIL
```

であり、

Evidenceを分解して確認する必要がある。

---

## Workbook Artifact自体も壊れる

Excel VBA開発では、

```text
Source Code
```

だけがArtifactではない。

Workbookには、

- VBA Project
- Worksheet
- Table
- Style
- Name
- Shape
- Relationship
- Workbook Metadata

等が含まれ、WorkbookそのもののIntegrityが開発環境へ影響する。

新規Workbookへ再構築できるように、

```text
Production VBA
+
Workbook Structure
+
External Asset
```

を分けて管理する価値がある。

---

## Latest VersionとBaselineは別

今回、

```text
Design v0.1.8 = Approved
Test Specification v0.1.4 = Approved
```

になっても、

```text
Current Approved Baseline = BL-MVP-001
```

を維持した。

「最新だから正式Baseline」という扱いをしない運用が実際に機能した事例。

---

# 記事にできそうな切り口

## 開発日記向き

### 1. 「OneDriveだから動かない」と思ったら違った話

流れ：

```text
OutlookでOFTが開かない
↓
OneDriveが原因？
↓
Local PathならPASS
↓
Web URLが原因だった
```

思い込みをControl Testで崩した開発日記。

---

### 2. AIが作ったSmoke Testにバグがあった

```text
Templates\\MailTemplate.oft
```

というAI生成コードのミス。

「AIにTestを書かせれば安心」ではなく、

```text
Test CodeもReview対象
```

というリアルなAI協働開発の記事。

---

### 3. Excelファイルが突然「Out of memory」になった

- Module追加不能
- PC再起動でも直らない
- xlsx化でも直らない
- 他Workbookは正常
- 結局作り直した

Excel VBA開発特有のArtifact破損との付き合い方。

---

### 4. 小さな個人開発なのにBaseline管理を導入した理由

今回実際に、

```text
Latest Design
Latest Test Spec
Current Baseline
```

が別々になった。

文書管理ルールが机上論ではなく役立った事例。

---

### 5. 「まず直す」から「まず切り分ける」へ

DF-P1-001で、

```text
FAIL
↓
Control Test
↓
Finding
↓
Verification
↓
Design
↓
Implementation
```

と進めた過程。

---

# 技術記事向き

## 1. Excel VBA + OneDriveで `ThisWorkbook.Path` がURLになる問題

テーマ：

```text
https://d.docs.live.net/<CID>/...
```

を、

```text
C:\Users\<User>\OneDrive\...
```

へ変換する設計。

内容：

- `ThisWorkbook.Path`
- `OneDrive`
- `OneDriveConsumer`
- `OneDriveCommercial`
- Relative Path Mapping
- Candidate Root判定
- Fail Fast
- Ambiguous Root Error

---

## 2. Outlook `CreateItemFromTemplate` とOneDrive Local Path

比較：

```text
Web URL
→ FAIL

Local Sync Path
→ PASS
```

Classic OutlookとOFT Template運用の記事。

---

## 3. VBAでWindows Pathを扱うときの注意

特に、

```vb
"\"
"\\"
```

の違い。

Python / JavaScript / C系との比較も記事にしやすい。

---

## 4. VBA Smoke TestをFail-Fastにする

```text
Precondition
↓
Operation
↓
Explicit Check
↓
FAILならExit
↓
PASS
```

`Debug.Assert`依存との比較。

---

## 5. Integration FindingからDesign変更へ戻す方法

```text
Implementation Finding
↓
Technical Verification
↓
Design Finding
↓
Production Specification
↓
Semantic Design Change
↓
Test Impact Review
↓
Regression
```

今回のDF-P1-001を事例化可能。

---

## 6. Requirement / Design / TestをVersion連鎖させない管理

今回、

```text
Requirement = unchanged
Design = v0.1.8
Test Specification = v0.1.4
Technical Spike = unchanged
```

となった実例。

文書Versionを揃えない方が健全なケースの記事。

---

# 有料note / テンプレート化候補

## 1. Technical Finding対応テンプレート

項目例：

```text
Finding ID
Observed
Root Cause Candidate
Control Test
Technical Verification
Classification
Requirement Impact
Design Impact
Test Impact
Close Criteria
Evidence
```

---

## 2. Small Technical Verificationテンプレート

今回のTV-P1-001形式。

```text
Objective
Technical Question
Scope
Out of Scope
Candidate
Steps
Expected
PASS / CONDITIONAL PASS / FAIL
Production変更禁止条件
```

---

## 3. Design Semantic Change Impact Reviewテンプレート

```text
Requirements
Design
Technical Evidence
Test Specification
Implementation
```

について、

```text
Affected
Not Affected
Needs Review
```

を判定する形式。

---

## 4. Baseline Quality Gateチェックリスト

```text
Document Registry最新
Required Documents存在
Blocking Gapなし
Semantic Conflictなし
Traceability成立
Latest / Baseline Version分離
Test Definition整合
Evidence確認
Baseline ID一意
```

---

## 5. VBA Fail-Fast Smoke Testテンプレート

```text
START
↓
Precondition
↓
Explicit Check
↓
Error Evidence
↓
Cleanup
↓
PASS / FAIL
```

`Debug.Assert`を使わない汎用Template。

---

## 6. AI生成コードReviewチェックリスト

今回の `\\` 問題から、

- 対象言語の文字列Escape規則
- Path Separator
- Null / Nothing
- Error Handling
- API境界
- Testコード自体の妥当性
- 他言語由来の癖が混入していないか

を確認するチェックリスト化が可能。

---

## 7. Excel VBA Project再構築手順書

Workbook破損時の復旧用。

```text
新規xlsm
↓
Sheet / Table再構築
↓
Class Import
↓
Compile
↓
Production Module Import
↓
Compile
↓
Smoke Test追加
↓
Integration Regression
```

個人開発・社内ツール開発で再利用価値が高い。

---

# 次チャット開始時の最重要Handoff

```text
Current Phase:
P1 Walking Skeleton

P0 Foundation:
COMPLETE

CP-P0:
ESTABLISHED

P1-01:
PASS / COMPLETE

DF-P1-001:
CLOSED

TV-P1-001:
PASS

Latest Approved Documents:
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4

Current Approved Baseline:
BL-MVP-001

Next Document Task:
BL-MVP-002 Candidate作成

Expected BL-MVP-002:
DOC-MVP-REQ      v0.1.8
DOC-MVP-DES      v0.1.8
DOC-TS-A         v0.4 CLOSED / PASS
DOC-MVP-TESTSPEC v0.1.4

Next Implementation Task:
P1-02 Inspector / WordEditor Connection

Read First:
1. 定型メール作成ツール Project Document Registry and Approved Baseline v0.4.md
2. MVP Design v0.1.8 日本語版.md
3. MVP Test Specification v0.1.4
4. Technical Spike A 実施仕様書 v0.4 日本語版_CLOSED.md
5. Implementation Plan v0.1 日本語版.md
6. P1-01 OFT Path Outlook Connection Completion Record v0.1.md
```

# まとめ / Summary

**日本語**

この会話では、P1-01で発生したOneDrive Web URL問題を `DF-P1-001` として切り出し、Control Test、`TV-P1-001`、Design変更、Production実装、Resolver Smoke Test、P1-01 Regressionまで完了しました。結果としてDF-P1-001はCLOSED、P1-01はPASS / COMPLETEです。Design v0.1.8とTest Specification v0.1.4の整合性レビューもPASSし、Document Registryはv0.4へ更新済みです。Current Approved BaselineはBL-MVP-001を維持しており、次の最優先作業はBL-MVP-002 Candidate作成です。その後、P1-02 Inspector / WordEditor Connectionへ進みます。

**English**

In this conversation, we handled the OneDrive web URL problem as `DF-P1-001`. We completed the control test, `TV-P1-001`, design update, production implementation, resolver smoke test, and P1-01 regression test. DF-P1-001 is now CLOSED, and P1-01 is PASS / COMPLETE. Design v0.1.8 and Test Specification v0.1.4 also passed the consistency review. The Document Registry is now v0.4. BL-MVP-001 is still the current approved baseline. The next priority is to create BL-MVP-002 Candidate, then move to P1-02 Inspector / WordEditor Connection.
