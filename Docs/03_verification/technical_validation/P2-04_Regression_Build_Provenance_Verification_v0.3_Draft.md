# P2-04 Regression Build Provenance Verification v0.3 — Draft

## 1. 今回の新Evidence（2026-10-19）

ユーザーは次を明示的に申告した。

> すべて少し前に提供したProductionSource9モジュールで実行したことは間違いありません。

**対象の解釈**：この会話で議題となったP2-01／P2-02／P2-03の過去Regressionおよび2026-10-18 P2-04 Regressionに対する、Production Source 9モジュールの**共通構成に関する実行者証言**とする。個別テストの実行日時、Workbookバイナリ、VBAProject全体、OFT、Fixture、Officeバージョン等の完全同一性を表明したものではない。

### Evidence種別と限界

| Evidence | 実証内容 | 種別 |
|---|---|---|
| Production ZIP `P2-04_Regression_20261018.zip` | 9モジュールの内容 | ユーザー提出の実ファイル |
| GitHub `main`参照（commit `edf5c5175b103e250144341071d885a3a992c65f`） | 対応した版付きSourceの実在 | GitHub read-only調査 |
| ZIP⇔GitHub照合（v0.2） | **9/9正規化一致**、文字列リテラルの大文字小文字一致 | 第三者によるStatic照合 |
| P2-01～P2-04に共通のSourceであったこと | **実行者の明示申告** | USER ATTESTATION（独立バイナリ証明ではない） |
| Workbook SHA-256 | `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9` | USER-REPORTED、Workbook現物は未入手 |
| P2-02/P2-03/P2-04の生ログ | 111/111・46/46・182/182 | 提供Raw Textの独立再集計（実機再実行なし） |

以上から、**9モジュールに限った「過去Regressionと今回RegressionのProduction Source Revision同一性」は、実行者申告と外部保存ソース照合を併せ、Evidence再利用審査に必要な水準として暫定受入可**と評価する。全Workbookバイナリを同一と認定しない。

## 2. 既存9 SourceのGitHub対応

- `modTemplateScanner` → P2-01 v0.1.1
- `modSyncEngine` → P2-02 v0.1.3
- `modVariableDefinitionData` → P2-03 v0.1.2
- `modSyncApplication` → P2-04 v0.1
- `modUiController` → P2-05 v0.1
- `modOutlookAdapter` → P1-07 v0.1.1
- `modSettingsData` → GitHub DF-P1-001 v0.1
- `COperationResult` → GitHub保存版
- `CErrorInfo` → GitHub保存版

原文ハッシュ：

| Item | SHA-256 |
|---|---|
| 9-module export ZIP | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` |
| P2-02 user raw log | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` |
| P2-03 user raw log | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` |
| P2-04 user raw log | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` |

## 3. 判定変更（v0.2から）

| 観点 | 旧判定 | 本文書の判定 |
|---|---|---|
| ZIP⇔GitHub Versioned Source | 9/9 MATCH | **維持** |
| 2026-10-18 Workbook SHA-256 | USER-REPORTED | **維持** |
| 過去Regression実行Source Revision | 不明 | **USER-ATTESTED SAME 9 SOURCE / EVIDENCE REUSE ELIGIBLE** |
| 過去Regression実行Workbookのbinary fingerprint | 不明 | **不明を維持、同じSHA-256を転記しない** |
| 実行時Compile・Fixture・OFTの全面同一性 | 不明 | **不明を維持** |
| Source-specific retest necessity | 未判定 | **現状再実行を要求する差分は認められない** |
| I12 Final Closure | PENDING | **PENDING（Evidence受入方式／Finding Gateを別途確認）** |

## 4. コントロール

- **対象のSource版の同一性と、実行したWorkbookの同一性を混同しない**。
- 自己申告を暗号学的な実行証明へ格上げしない。
- 実行日に変更・保存がないという申告は2026-10-18 Regression後についてのもの。I11内で行われた保存はログに明記されており矛盾扱いしない。
- 既存P2-02／P2-03 Regression Recordは従来のDRAFTを保持。正式`PASS/CLOSED`には原本履歴を保ったReview／承認が必要。
- GitHubへのCommit・文書Registry変更は本資料作成時点では実施していない。

## まとめ / Summary

**日本語：** ユーザーはP2-01～P2-04で共通のProduction 9モジュールを使ったと申告。Exportの9/9 GitHub正規化一致と合わせ、過去RegressionのSource Revision保留を実行者確認で解消可能と判断。Workbook完全同一性やI12 Closureは別問題とする。

**English:** The operator attests that the same nine production modules were used across historical and current regressions. All nine exports match corresponding GitHub sources after normalization. This supports source-based evidence reuse, not binary workbook identity or automatic I12 closure.
