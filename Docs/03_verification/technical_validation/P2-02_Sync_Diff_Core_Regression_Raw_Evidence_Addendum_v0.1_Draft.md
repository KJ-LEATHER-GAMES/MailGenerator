# P2-02 Sync Diff Core Regression — Raw Evidence照合追補 v0.1 Draft

## 1. 文書情報・判定

| 項目 | 内容 |
|---|---|
| 対象 | P2-02 `BuildSyncDiff` / 既存Regression Record v0.1（GitHub） |
| Original Record date | 2026-10-10（既存Recordの記載。**本ログ原文から実行日を検証したものではない**） |
| Evidence受領・照合日 | 2026-10-19 |
| Source | `261018_P2-02_Regression Log.txt`（ユーザー提供） |
| Immutable staging copy | `P2-02_Regression_UserSupplied_20261019_Raw.txt`（バイト単位コピー） |
| File SHA-256 | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` |
| File byte count / Line count | 11,170 bytes / 233 lines（UTF-8 / CRLF） |
| Baseline表示 | `Execution Baseline = BL-MVP-004`（ログL3） |
| 対応Source | `modSyncEngine_P2-02_v0.1.3_CP932.bas`（GitHub／ユーザー提供Exportは9/9 Normalized Matchの一部） |
| Transcript Assertion Outcome | **111/111 PASS、FAIL 0、全6 Suite Overall PASS** |
| Raw Evidence Source Verification | **COMPLETE（提供テキストとの照合）** |
| Independent Regression Record | **DRAFT / CLOSURE PENDING（変更しない）** |
| I12 Reuse Assessment | **REUSE CANDIDATE / FINAL ACCEPTANCE PENDING** |
| Formal MVP Test | **NOT CLAIMED** |

**境界：** 本資料はテキスト原文のIntegrityと記載結果の照合であり、実行日・実行Workbookのバイナリ同一性、対象VBAProjectの実行時状態、Compileを単独で証明するものではない。ファイル名の`261018`を実行日認定の根拠としない。

## 2. 原文ログとSuite別対応

| Suite | 原文行 | Assertion | FAIL | Overall |
|---|---|---:|---:|---|
| R1 Bootstrap Metadata | L6–48 | 33 | 0 | PASS |
| R2 Detection History | L50–102 | 43 | 0 | PASS |
| R3 Excel Date Serial Compatibility | L104–122 | 9 | 0 | PASS |
| R4 Existing Core | L124–152 | 18 | 0 | PASS |
| R5 Technical Negative | L154–169 | 6 | 0 | PASS |
| R6 Contract Compatibility | L171–182 | 2 | 0 | PASS |
| **Official aggregate** | **L6–182** | **111** | **0** | **PASS** |
| R1 Bootstrap再掲 | L192–233 | 33 | 0 | PASS（**集計には加えない**） |

六つのChild Suiteは各々`PASS Count`、`FAIL Count = 0`、`Overall = PASS`を出力。`Expected aggregate assertions = 111 PASS / 0 FAIL`（L185）は**期待値表示**であり、独立の集計ランナー判定ではない。実測Child Suiteの和`33 + 43 + 9 + 18 + 6 + 2 = 111`で検証。

### 重複Bootstrapの扱い

- L193–232の40行とL8–47の40行は**テキストとして完全一致**。
- このため原文には33件が追加で掲載されているが、**144/144と記録しない**。
- 原文だけでは、二度目の独立実行か単なる同一出力の再掲かは判別不能。`REPEATED OUTPUT / EXECUTION COUNT NOT PROVEN`と記録する。
- 既存Recordに「separate repeated Bootstrap」と記載されていても、同一の内容だけで新規実行を立証したことにはならない。既存Recordの履歴を黙って書き換えず、注記する。

## 3. Contract Evidence要点

- R1：Existing/Reactivated/Unused/Already-UnusedのBootstrapとMetadata入力非破壊、Partial Metadataの拒否。
- R2：`BL-MVP-004` Detection HistoryのLocation有り／日付Blank-Blank／Partialや不正値のFail Closed。
- R3：Excel数値Date Serialと日付保持。
- R4：New/Existing/Reactivated/Unused分類、Canonical Name、Rename非推定、共通SyncTimestamp、入力不変。
- R5：Nothing／InvalidCandidates／重複／不正Status／構造不整合のNegative。
- R6：P2-01 ScanTemplate CarrierとP0 VariableDefinition Carrierの互換性。

## 4. Baseline・Build・Finding照合

- BL-MVP-004の**Approval RecordはGitHubで独立確認済み**（2026-10-01 PASS/APPROVED）。従来Recordの「BL-MVP-004は承認未確認」はSource不足による旧保留であり、現在のレビューでは出典が判明した。ただし実行PCへの適用状態は別論点。
- `Build Provenance Verification v0.2 Draft`で、2026-10-18実行WorkbookからのExportとされる`modSyncEngine`がGitHub版v0.1.3とNormalized Match。**本P2-02過去ログを実行した当時のWorkbookのSHA-256は未記録**。現在のWorkbookハッシュをそのまま過去ログに付与しない。
- Pre-flight Compile PASSは既存Recordに2026-10-10ユーザー報告として記載されるが、本テキストにはCompile表示なし。**既存の二次記録に基づく**。
- 新しいFAIL／Production Defectは原文に記載されない。ただし全体のActive Blocking Finding=0を本ファイルだけで証明しない。
- Runtime Fixtures・Versioned Source変更有無を通したEvidence適用審査はまだ必要。

## 5. Closure残件・扱い

1. **Historical Build Trace**：独立Regression Recordの実行Workbook／VBA Revisionを今回のExportと対応づける根拠を確認。
2. **Evidence Reference**：原文ファイル・本SHA・プロジェクトEvidence内の保存場所を紐づけ（現在は会話成果物、GitHub未Commit）。
3. **Finding / Test Precondition**：Baseline適用、Compile報告、Test Fixture、署名・Contract変更影響を評価。
4. **Original Record正式Revision**：Closure要件を満たしたら既存Recordを正式改訂。現時点で`PASS / CLOSED`へ自動変更しない。

推奨Repo Archive：`Evidence/P2-02/`配下。元ログは変更せず保存する。

## まとめ / Summary

**日本語：** 6 Suite合計111件PASS、FAIL 0。33件Bootstrapが原文内に再掲されているため追加計上しない。原文Archiveは確保できたが、旧実行BuildとFixture等の最終同定を待つため独立RecordはDRAFTを維持する。

**English:** All 111 unique P2-02 assertions passed. A verbatim duplicate of the 33-case Bootstrap output is excluded from the total. Source log is archived locally; historical build provenance and formal closure remain pending.
