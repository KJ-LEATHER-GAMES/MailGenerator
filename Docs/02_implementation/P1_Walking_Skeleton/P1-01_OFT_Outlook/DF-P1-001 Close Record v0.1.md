# DF-P1-001 Close Record v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | DF-P1-001 Close Record |
| Version | v0.1 |
| 文書種別 | Execution Evidence / Finding Close Record |
| Finding ID | DF-P1-001 |
| Finding名 | OneDrive Local Path Resolution |
| 対象Phase | P1 Walking Skeleton |
| 対象Task | P1-01 OFT Path / Outlook Connection |
| Close Date | 2026-09-15 |
| Current Approved Baseline | BL-MVP-001 |
| Related Design | DOC-MVP-DES v0.1.8 |

---

## 2. Finding

OneDrive上のWorkbookでは `ThisWorkbook.Path` が以下のWeb URLを返す。

```text
https://d.docs.live.net/<CID>/...
```

このURLから単純にWorkbook相対Pathを結合して生成したOFT PathをClassic Outlook `CreateItemFromTemplate` へ渡すと、OFTを開くことができなかった。

---

## 3. Root Cause

Root CauseはOutlook Adapter、OFTファイル、OneDrive保存そのものではなく、Workbook Relative Path ResolutionがOneDrive Web URLをWindows File Pathとして扱っていたことと判定した。

対照確認：

```text
Web URL Path
https://d.docs.live.net/.../Templates/MailTemplate.oft
→ FAIL

Local Sync Path
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
→ PASS
```

---

## 4. Resolution

`modSettingsData.ResolveWorkbookRelativePath` を拡張し、`ThisWorkbook.Path` が `https://d.docs.live.net/<CID>/...` の場合は以下の方式でWindows Local Pathへ解決する。

```text
ThisWorkbook.Path
↓
<CID>より後ろの相対Pathを抽出
↓
OneDrive / OneDriveConsumer / OneDriveCommercialからLocal Root候補取得
↓
重複Root除外
↓
実在するLocal Workbook Directoryを確認
↓
Local Workbook Pathを一意に特定
↓
TemplatePathを結合
↓
Windows Local OFT Path
```

ユーザー名およびOneDrive Rootの固定PathはProductionコードへハードコードしない。

---

## 5. Verification Evidence

### 5.1 TV-P1-001

```text
TV-P1-001: PASS
```

確認済み：

- OneDrive Web URL再現
- OneDrive Local Root動的取得
- URL Relative Path抽出
- Local Workbook Path生成
- Local OFT Path生成
- OFT存在確認
- CreateMailFromTemplate PASS
- CloseWithoutSave PASS

### 5.2 Resolver Smoke Test

```text
TestResolveWorkbookRelativePath: PASS
```

確認結果：

- Workbook-relative path resolution: PASS
- Empty relative path rejection: PASS
- Absolute path rejection: PASS

正常系Resolved Path：

```text
C:\Users\monsi\OneDrive\ドキュメント\MailGenerator\Templates\MailTemplate.oft
```

### 5.3 P1-01 Regression

```text
Settings / Path Resolution: PASS
CreateItemFromTemplate: PASS
Close Without Save: PASS
TestP1OftConnection: PASS
```

---

## 6. Close Criteria

- [x] Root Cause特定
- [x] Technical Resolution成立性確認
- [x] DOC-MVP-DESへDesign反映
- [x] Production実装完了
- [x] VBA Compile PASS
- [x] Resolver Smoke Test PASS
- [x] P1-01 Regression PASS

---

## 7. Impact

| 対象 | 判定 |
|---|---|
| DOC-MVP-REQ | Not Affected |
| DOC-MVP-DES | Affected / v0.1.8へ反映済み |
| DOC-TS-A | Not Affected |
| DOC-MVP-TESTSPEC | Affected / Impact Reviewで最小修正要と判定 |
| modSettingsData | Affected / 実装済み |
| modOutlookAdapter | Not Affected |

---

## 8. Final Decision

```text
DF-P1-001 = CLOSED
```

Finding解消は確認済み。

Current Approved Baseline `BL-MVP-001` は本Closeを理由に自動更新しない。
