# TF-P1-06-001 Post-Render BodyText Diagnostic Test v0.1

## 目的

P1-05 Integrationでは `Body Length(post)=202`、
P1-06 Normal Integrationでは `Body Length(post)=213` となった差分を、
Production変更なしでTest Harnessだけから切り分ける。

## ファイル

- `modP1_05MinimalRenderIntegrationDiag_v0.1_CP932.bas`
- `modP1_06MinimalUnresolvedCheckerIntegrationDiag_v0.1_CP932.bas`

既存の正式Test Moduleとは別Module名なので、削除・置換せず追加Importできる。

## Import後

`Debug > Compile VBAProject` を実行する。

## 実行順

### 1. P1-05相当経路

```vb
TestP105MinimalRenderIntegrationDiagnostic
```

### 2. P1-06相当正常経路

```vb
TestP106UnresolvedZeroIntegrationDiagnostic
```

## 両Testで出力する診断情報

- `FormattedValues` のKey / Value / Len
- post BodyText Length
- 制御文字数
  - CR(13)
  - LF(10)
  - TAB(9)
  - Word table cell marker `Chr(7)`
  - VT(11)
  - FF(12)
- 置換後値の出現回数
  - `ABC123`
  - `2026/09/30`
  - `品質部`
  - `確認お願いします`
- Baseline Tokenの残存回数
- post BodyText全文
- 制御文字を `<CR>`, `<CELL>` 等で可視化したBodyText

## 判定の重点

特に次を比較する。

```text
Body Length(post)
品質部 Count
{{Department}} Count
CELL(7) Count
CR/LF Count
BODY ESCAPED
```

`202 vs 213 = 11` は、

```text
Len("{{Department}}") - Len("品質部")
= 14 - 3
= 11
```

と一致するため、Department周辺の差分を重点確認する。

ただし `Unresolved=0` であるため、単純な `{{Department}}` 未置換と決めつけず、
BodyText全文と制御文字Evidenceから実体を特定する。

## 注意

この診断版はFinding切り分け専用Test Artifactであり、
Production Moduleは変更しない。
正式Test Artifactの置換もしない。
