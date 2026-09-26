# MVP Design DF-P1-001対応 最小差分パッチ v0.1

## 1. Patch情報

| 項目                        | 内容                              |
| ------------------------- | ------------------------------- |
| 対象文書                      | DOC-MVP-DES / MVP Design v0.1.7 |
| 反映後Version候補              | v0.1.8                          |
| Related Finding           | DF-P1-001                       |
| Technical Evidence        | TV-P1-001 PASS                  |
| Change Type               | Semantic Design Change          |
| Requirement Impact        | None                            |
| Outlook Adapter Impact    | None                            |
| Test Specification Impact | Needs Review                    |
| Production Impact         | `modSettingsData`               |

本Patchでは、OneDrive環境におけるWorkbook Relative Path Resolution方式のみを変更する。

---

# 2. §1 更新概要を追加

`v0.1.8 更新概要` として以下を追加する。

```markdown
### v0.1.8 更新概要

DF-P1-001およびTV-P1-001の検証結果を反映し、
OneDrive Web URL環境におけるWorkbook Relative Path Resolution方式を更新した。

1. `ThisWorkbook.Path` がWindows Local Pathの場合は従来方式を維持
2. `https://d.docs.live.net/<CID>/...` の場合はOneDrive Local Rootへ解決
3. OneDrive Root候補を環境変数から取得
4. 実在するLocal Workbook Directoryを使用してRootを一意に特定
5. `modSettingsData.ResolveWorkbookRelativePath` の責務を明確化
6. OFTを利用する主要シーケンスへPath Resolutionを明示

利用者から見た機能・操作・設定方式の変更はない。

**Change Type：Semantic Design Change**  
**Requirement Impact：None**
```

---

# 3. §9.3 パス解決を置換

## 現行

````markdown
### 9.3 パス解決

OFTの絶対パスは以下から導出する。

```text
ThisWorkbook.Path
+
TemplatePath
````

````

## 置換後

```markdown
### 9.3 パス解決

OFTはWorkbook相対Pathで管理し、`TemplatePath`には以下のような相対Pathを保持する。

```text
Templates\MailTemplate.oft
````

絶対Pathは `ThisWorkbook.Path` の形式に応じて解決する。

#### Windows Local Path

`ThisWorkbook.Path` がWindows Local Pathの場合は、従来どおり以下で解決する。

```text
ThisWorkbook.Path
+
TemplatePath
```

#### OneDrive Web URL

`ThisWorkbook.Path` が以下の形式の場合、

```text
https://d.docs.live.net/<CID>/...
```

Web URLをOFT Pathとして直接使用しない。

以下の順でWindows Local Pathへ解決する。

```text
ThisWorkbook.Path
↓
<CID>より後ろの相対Pathを抽出
↓
OneDrive Local Root候補を取得
↓
Local Workbook Path候補を生成
↓
実在するWorkbook Directoryを確認
↓
Local Workbook Pathを一意に特定
↓
TemplatePathを結合
↓
Windows Local OFT Path
```

OneDrive Local Root候補は以下の環境変数から取得する。

```text
OneDrive
OneDriveConsumer
OneDriveCommercial
```

空欄および同一Pathの重複候補は除外する。

候補判定は以下とする。

```text
実在候補 = 0
→ ConfigurationError

実在する異なる候補 = 1
→ 採用

実在する異なる候補 >= 2
→ ConfigurationError
```

ユーザー名またはOneDrive Rootの固定Pathはハードコードしない。

Path結合時はWindows PathとしてSeparatorを正規化する。

Path Resolutionの責務は利用可能な絶対Pathの導出までとし、
対象OFTファイル自体の存在確認は後続処理の責務とする。

````

---

# 4. §10.3 `modSettingsData` 責務を追加

## 現行

```markdown
`modSettingsData`

- Keyによる設定値取得
````

## 置換後

```markdown
`modSettingsData`

- Keyによる設定値取得
- Workbook相対PathからWindows絶対Pathへの解決
- `d.docs.live.net`形式のOneDrive Web URLからLocal Workbook Pathへの解決
```

新しいPath専用Moduleは追加しない。

`ResolveWorkbookRelativePath` の公開Interfaceは維持する。

```vb
ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult
```

---

# 5. §25 主要処理シーケンスを修正

以下3シーケンスを同じ考え方で修正する。

* §25.1 手動同期
* §25.2 UserForm起動
* §25.3 メール生成

## 現行部分

```text
Settings Data Access
↓
TemplatePath取得
↓
OFT存在確認
```

## 置換後

```text
Settings Data Access
↓
TemplatePath取得
↓
Workbook Relative Path解決
↓
Local OFT Path取得
↓
OFT存在確認
```

Path Resolution Errorの場合は、OFT存在確認へ進まずFail Fastする。

```text
Workbook Relative Path解決
↓
Path Resolution Errorあり？
├─ Yes → Error Result → UI通知 → Stop
└─ No
    ↓
OFT存在確認
```

それ以降の、

```text
Outlook Adapter
↓
MailItem生成
```

以降は変更しない。

---

# 6. §27 Design Decision追加

既存D01〜D16は変更せず、D17を追加する。

| ID  | Decision                          | 採用                                                                              |
| --- | --------------------------------- | ------------------------------------------------------------------------------- |
| D17 | Workbook Relative Path Resolution | Local Pathは直接結合。`d.docs.live.net`形式ではOneDrive環境変数と実在DirectoryからLocal Rootを一意に解決 |

---

# 7. 変更しない箇所

以下は本Patchでは変更しない。

```text
DOC-MVP-REQ
SettingsのKey / Value構造
TemplatePath = Templates\MailTemplate.oft
1 Excel = 1 OFT
modOutlookAdapter
CreateMailFromTemplate
WordEditor / Route W
Template Scanner
Configuration Validator
Input Validator
Render
Unresolved Check
Display
Technical Spike A
```

`TemplatePath`を絶対Pathへ変更しない。

OneDrive利用禁止等の新しいユーザー制約も追加しない。

---

# 8. 本PatchでDesignへ持ち込まない事項

以下はImplementation DetailとしてDesign本文へ追加しない。

```text
具体的なVBA Function分割
Private Function名
Collection / Dictionaryの具体構造
Environ$呼び出しコード
Path Separator正規化コード
GetAttr / Dir等の具体API
具体的Error Message文言
```

これらはProduction実装仕様および実装側で管理する。

---

# 9. Impact判定

| Document / Component | 判定           |
| -------------------- | ------------ |
| DOC-MVP-REQ          | Not Affected |
| DOC-MVP-DES          | Affected     |
| DOC-TS-A             | Not Affected |
| DOC-MVP-TESTSPEC     | Needs Review |
| modSettingsData      | Affected     |
| modOutlookAdapter    | Not Affected |

`DOC-MVP-TESTSPEC` は本Design Patch適用だけを理由に自動Version Upしない。

Design変更後にTest DefinitionへのSemantic Impactを確認し、必要な場合のみ変更する。

---

# 10. Baseline扱い

`MVP Design v0.1.8` 作成時点では、Current Approved Baselineを自動変更しない。

```text
Latest Design:
v0.1.8

Current Approved Baseline:
現行Baselineを維持
```

Design変更後、

```text
Test Specification Impact Review
↓
Cross-document Consistency Review
↓
必要ならNew Baseline Candidate
```

の順でBaseline更新を判断する。
