# MVP Test Specification DF-P1-001 Impact Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | MVP Test Specification DF-P1-001 Impact Review |
| Version | v0.1 |
| 文書種別 | Test Definition Impact Review |
| Review対象 | DOC-MVP-TESTSPEC v0.1.3 |
| Change Source | DOC-MVP-DES v0.1.8 / DF-P1-001 |
| Review Date | 2026-09-15 |
| Current Approved Baseline | BL-MVP-001 |

---

## 2. Review Objective

DF-P1-001対応によるDesign Semantic Changeが、DOC-MVP-TESTSPEC v0.1.3のTest Definitionへ影響するか確認する。

Design変更点：

```text
旧:
ThisWorkbook.Path + TemplatePath

新:
ThisWorkbook.Path形式を判定
├─ Windows Local Path → 直接結合
└─ d.docs.live.net URL → OneDrive Local Rootへ解決後に結合
```

---

## 3. Requirement Impact

DOC-MVP-REQ v0.1.8の以下は変更されていない。

```text
FR-TPL-001:
Excelファイルからの相対パスによってOFTテンプレートを参照する。

AC-001:
相対パスで指定されたOFTを正常に読み込める。
```

したがってRequirement Impactは以下とする。

```text
Requirement Impact: None
```

---

## 4. Test Specification Impact Result

```text
DOC-MVP-TESTSPEC v0.1.3
= AFFECTED
```

理由：

`MTS-TPL-001` のExpectedが以下となっている。

```text
ThisWorkbook.Path + TemplatePath から対象OFTを特定できる
```

この記述はDOC-MVP-DES v0.1.8のOneDrive Web URL処理を表現できず、OneDrive環境では文字どおりには成立しない。

よってTest Expectedを現行Designへ合わせる必要がある。

---

## 5. Affected Test Definition

### 5.1 MTS-TPL-001 相対パスOFT参照

**判定：Affected**

変更対象：

- Expected
- Evidence
- OneDrive Web URL環境での確認条件

推奨Expected：

```text
- Workbook相対Path Resolutionによって対象OFTのWindows絶対Pathを解決できる
- ThisWorkbook.PathがWindows Local Pathの場合はLocal Pathとして解決できる
- ThisWorkbook.Pathがd.docs.live.net形式の場合はOneDrive Local Sync Pathへ解決できる
- Web URLをOFT File Pathとして直接使用しない
- 解決したPathからTemplate読込に成功する
```

推奨Evidence：

```text
ThisWorkbook.Path
TemplatePath
Resolved Local Path
Template Read Result
```

新しいTest IDは追加せず、MTS-TPL-001内の実行Variantとして扱う。

---

### 5.2 MTS-TPL-002 Excel一式移動後の相対パス参照

**判定：Not Affected**

既存Expected：

```text
Settingsを書き換えずOFTを参照できる
```

はDesign変更後も意味が変わらない。

---

### 5.3 MTS-TPL-003 OFT不存在Fail Fast

**判定：Not Affected**

Path解決後のOFT不存在判定という既存Test目的は変更されない。

---

### 5.4 MTS-TPL-004 OFT読み込み失敗通知

**判定：Not Affected**

OFTが存在する状態で読込自体が失敗するError Testであり、Path Resolution変更によるExpected変更は不要。

---

### 5.5 MTS-ERR-001 主要Error Message

**判定：Affected / Minor**

DF-P1-001対応によりPath Resolution Failureが `ConfigurationError` として返るDesignとなったため、代表Error確認対象へ以下を追加する。

```text
Workbook Relative Path / OneDrive Local Path Resolution Error
```

Expected自体の「何が問題か / 何を確認すべきか理解できる」は変更しない。

---

### 5.6 MTS-NFR-002 保守性

**判定：Not Affected**

Path Resolutionは既存 `modSettingsData` / Excel Data Access責務内で実装され、新Componentは追加されていない。

---

## 6. Test Case Count Impact

新規Test IDは追加しない。

```text
Current Test Case Count: 69
After Patch Expected : 69
```

既存Test Caseの意味を最新Designへ合わせる最小Semantic Updateとする。

---

## 7. Required Document Action

DOC-MVP-TESTSPECは内容変更が必要なためVersion Up対象とする。

```text
Current:
DOC-MVP-TESTSPEC v0.1.3

Next Candidate:
DOC-MVP-TESTSPEC v0.1.4
```

v0.1.4では最低限以下を変更する。

1. v0.1.4更新概要追加
2. MTS-TPL-001 Expected / Evidence更新
3. MTS-TPL-001へOneDrive Web URL実行Variant追加
4. MTS-ERR-001代表ErrorへPath Resolution Error追加
5. Test Case総数69件を維持

---

## 8. Baseline Impact

Current Approved Baseline：

```text
BL-MVP-001
DOC-MVP-DES      v0.1.7
DOC-MVP-TESTSPEC v0.1.3
```

Latest Design：

```text
DOC-MVP-DES v0.1.8
```

Test Specification修正およびCross-document Consistency Review完了までは、Current Approved Baselineを変更しない。

```text
BL-MVP-001 = MAINTAIN
BL-MVP-002 = NOT YET CREATED
```

---

## 9. Final Decision

```text
Test Specification Impact: AFFECTED
Requirement Impact          : NONE
New Test ID Required        : NO
Test Case Count Change      : NO (69維持)
DOC-MVP-TESTSPEC Update     : REQUIRED
Target Revision             : v0.1.4 Candidate
Baseline Update             : NOT YET
```
