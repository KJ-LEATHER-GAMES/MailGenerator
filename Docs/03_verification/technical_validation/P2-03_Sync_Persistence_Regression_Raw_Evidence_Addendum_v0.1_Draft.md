# P2-03 VariableDefinition Sync Persistence Regression — Raw Evidence照合追補 v0.1 Draft

## 1. 文書情報・判定

| 項目 | 内容 |
|---|---|
| 対象 | P2-03 `ApplySyncDiff` / 既存Regression Record v0.1（GitHub） |
| Original Record review date | 2026-10-11（既存Recordの記載。**ログ原文から実行日を検証したものではない**） |
| Evidence受領・照合日 | 2026-10-19 |
| Source | `261018_P2-03_Regression Log.txt`（ユーザー提供） |
| Immutable staging copy | `P2-03_Regression_UserSupplied_20261019_Raw.txt`（バイト単位コピー） |
| File SHA-256 | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` |
| File byte count / Line count | 4,131 bytes / 100 lines（UTF-8 / CRLF） |
| Test Workbook displayed | `ThisWorkbook: MailGeneratorNew.xlsm`（Core / Negative / Compatibility、L38/61/90） |
| Baseline label | `BL-MVP-004 Detection History Regression`（L20）、他Suiteの個別Baseline表示はなし |
| 対応Source | `modVariableDefinitionData_P2-03_v0.1.2_CP932.bas`（GitHub／ユーザー提供Exportは9/9 Normalized Matchの一部） |
| Transcript Assertion Outcome | **46/46 PASS、FAIL 0、全5 Suite Overall PASS** |
| Raw Evidence Source Verification | **COMPLETE（提供テキストとの照合）** |
| Independent Regression Record | **DRAFT / CLOSURE PENDING（変更しない）** |
| I12 Reuse Assessment | **REUSE CANDIDATE / FINAL ACCEPTANCE PENDING** |
| Formal MVP Test | **NOT CLAIMED** |

**境界：** `261018`を実行日時として断定せず、原文にないWorkbookハッシュ・Commit IDを補わない。実機テストの再実行・バイナリ同一性保証ではない。

## 2. 原文ログとSuite別対応

| Suite | 原文行 | Assertion | FAIL | Overall | Fixture restoration line |
|---|---|---:|---:|---|---|
| Bootstrap Metadata | L1–17 | 7 | 0 | PASS | L16 |
| Detection History | L19–34 | 6 | 0 | PASS | L33 |
| Sync Persistence Core | L36–57 | 12 | 0 | PASS | L56 |
| Technical Negative | L59–86 | 18 | 0 | PASS | L85 |
| Compatibility | L88–100 | 3 | 0 | PASS | L99 |
| **Total** | **L1–100** | **46** | **0** | **PASS** | **全Suiteに復元メッセージあり** |

5 Suiteの集計`7 + 6 + 12 + 18 + 3 = 46`で独立照合。全Suiteに`Original tblVariableDefinition contents restored.`の出力がある。

### テスト対象の確認

- Bootstrap：Unusedの初期化／初期化済保持、New/Existing/ReactivatedのDate必須、Partial/Invalid Metadata拒否。
- Detection History：Unused Subject/Body/Both Blank-Blank、Partial Timestamp、Invalid Location拒否。
- Core：New／Existing／Reactivated／Unused、分類混合、Zero Target No-op、Date保存、ユーザー設定・既存名保持。
- Negative：不正Diff/Status/TemplateLocation/Timestamp、Duplicate、Table Missing、Column Missing、各分類の対象行不一致、Runtime Write Failure等。
- Compatibility：P2-02→P2-03 Production Compatibility、VariableDefinition Read、P2-02 Contract維持。

## 3. Fixture／証拠の限界

- 復元メッセージは5 Suiteすべてで確認。ただし**実際に復元されたセル値の個別Before/After、書式、数式、入力規則、関連シートの全面比較**は、この100行のテキストだけでは確認できない。
- 既存Recordには当時のWorkbook画面による一部Before/After表示比較の記録があるが、今回の添付ファイルには画像がない。この追補の原文範囲を超える追加証拠として混同しない。
- Workbook名は表示されるが、**その実行時点のWorkbook SHA-256／VBAProject全体の正規化Source比較証拠はログには存在しない**。
- 2026-10-18 P2-04実行WorkbookのUser-export `modVariableDefinitionData`がGitHub v0.1.2と一致することは別の`Build Provenance Verification v0.2`で確認済み。**本過去ログと同一Workbook実行と断定しない**。
- `BL-MVP-004` Approval RecordはGitHubに存在するが、個別Regressionの実行時点での適用条件は別に評価する。

## 4. Closure残件・扱い

1. **Historical Build Trace**：過去Regressionの実行Build Revisionを現行Buildとの比較で追跡。単に同じWorkbook名が表示されたことだけでは不十分。
2. **Evidence Reference**：原文Archiveを`Evidence/P2-03/`へ登録しSHA-256をRecordに付す（Repoは未更新）。
3. **Restoration／Compile／Finding**：当時のFixture復元・Compile・Finding Assessmentは原文と既存Recordの双方で区別し、最終判断する。
4. **Original Record正式Revision**：受入基準を満たしてから既存RecordをClosureへ移す。新たなProduction Failureは本ログでは観測されていない。

## まとめ / Summary

**日本語：** 5 Suite合計46件PASS、FAIL 0。各Suite末尾のtblVariableDefinition復元報告も確認した。原文は確保したが、過去実行時Buildおよび完全復元の最終確認が必要なため、独立RecordはDRAFTを維持する。

**English:** All 46 P2-03 assertions passed, and every suite reports restored table contents. Source log is preserved; historical build provenance and final closure remain pending.
