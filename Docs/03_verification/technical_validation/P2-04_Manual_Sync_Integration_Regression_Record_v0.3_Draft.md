# P2-04 Manual Sync Integration Regression Record v0.3 — Draft

## 1. 文書情報 / Result Boundary

| 項目 | 内容 |
|---|---|
| Project | 定型メール作成ツール MVP |
| Unit | P2-04 Manual Sync Integration |
| Verification Type | Implementation / Regression Verification（Formal MVP Testではない） |
| Execution Date | 2026-10-18（ユーザー申告） |
| Record Update | 2026-10-19 / v0.3 Draft |
| Source | `261018_P2-04_Regression Log.txt`（ユーザー提供テキスト） |
| Raw Log Status | **RECEIVED / BYTE-PRESERVED / ASSERTIONS RECONCILED** |
| Execution Workbook | `MailGeneratorNew.xlsm`（GitHubにある別版ではなく、ユーザーの別フォルダの実行版） |
| Workbook SHA-256 | `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`（ユーザー申告・Workbookバイナリ未受領） |
| VBA Source Match | 9 / 9 Normalized Match to GitHub Versioned Source（既存Build Provenance v0.2を参照） |
| Per-Scenario Regression | **182/182 PASS, 0 FAIL — RAW-LOG-CONFIRMED** |
| I10 Initial Attempt | **ABORTED**（Production実行前、後続の準備・再実行でPASS） |
| Historical P2-02/P2-03 Raw Evidence | **RECEIVED / VERIFIED TEXT：111 + 46（別Cycle・追加計上なし）** |
| P2-04 Regression Record | **DRAFT / CLOSURE PENDING** |
| I12 Contract Regression | **PENDING / NOT CLOSED** |
| Historical P2-04 Completion | **PASS / COMPLETE（別Cycle）** |
| P2-05 / CP-P2 / Formal MVP Test | **NOT CLAIMED** |

この記録が直接照合したのは、**ユーザーが保存して提供したログ原文**である。Excel / Outlookを本書作成者が再実行したわけではない。ログ以外の実行環境・全Workbook属性を独立に検証したものでもない。

## 2. 原文Evidence・Integrity

- Primary evidence：`261018_P2-04_Regression Log.txt`（ユーザー提供の原本ファイル）。
- Immutable staging copy：`P2-04_Regression_20261018_Raw.txt`（原本と**バイト単位で同一**）。
- SHA-256：`4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add`。
- Encoding：UTF-8。改行：CRLF。テキスト行数：**439行**。
- ZIPによるSource Snapshot：`P2-04_Regression_20261018.zip`（ユーザー提供、9モジュール）。
- GitHub版付きProduction Sourceの内容照合：`P2-04_Regression_Build_Provenance_Verification_v0.2_Draft.md`。
- 原文内にはWindowsユーザーフォルダへの絶対パス、OFT参照パス、TEMPパスが含まれる。**原本は変更せずアクセス管理し、公開・Git登録前には機微情報を確認すること。** 必要なマスキングは別コピーに実施する。
- このファイルは**会話から再構成したログではない**。ユーザーが提供した439行のテキスト原本である。取得元のImmediate Windowとの真正性はユーザー提供を根拠とする。

## 3. ケース別実行結果（原文Line Number付き）

| ID | Test Entry Point | Log Lines | PASS Count | FAIL Count | Overall | Evidence |
|---|---|---|---:|---:|---|---|
| BOOT | `TestP202P203BootstrapProductionCompatibility` | L2–L43 | 29 | 0 | PASS | RAW-LOG-CONFIRMED |
| I03 | `TestP204I03InvalidCandidate` | L44–L88 | 10 | 0 | PASS | RAW-LOG-CONFIRMED |
| I04 | `TestP204I04OftMissing` | L89–L117 | 11 | 0 | PASS | RAW-LOG-CONFIRMED |
| I05 | `TestP204I05DefinitionReadFailure` | L118–L169 | 17 | 0 | PASS | RAW-LOG-CONFIRMED |
| I06 | `TestP204I06BuildSyncDiffFailure` | L170–L229 | 22 | 0 | PASS | RAW-LOG-CONFIRMED |
| I07/I08 | `TestP204I07I08ContinuousRetry` | L230–L291 | 37 | 0 | PASS | RAW-LOG-CONFIRMED |
| I09 | `TestP204I09WarmLifecycle` | L292–L324 | 16 | 0 | PASS | RAW-LOG-CONFIRMED |
| I10-ABORT | `TestP204I10ColdLifecycle` | L325–L334 | — | — | ABORTED | 操作／事前準備履歴 |
| I10-PREP | `PrepareP204I10ColdLifecycleBaseline` | L335–L348 | — | — | PREPARED | 操作／事前準備履歴 |
| I10-PASS | `TestP204I10ColdLifecycle` | L349–L388 | 20 | 0 | PASS | RAW-LOG-CONFIRMED |
| I11-PREP | `PrepareP204I11ManualOnlyBaseline` | L389–L407 | — | — | PREPARED | 操作／事前準備履歴 |
| I11-PASS | `TestP204I11ManualOnlyAfterReopen` | L408–L439 | 20 | 0 | PASS | RAW-LOG-CONFIRMED |
| **TOTAL** | **Bootstrap + I03–I11（成功時試験9群）** | — | **182** | **0** | **PASS** | **原文集計一致** |

**集計根拠：** `29 + 10 + 11 + 17 + 22 + 37 + 16 + 20 + 20 = 182`。すべての対象Sectionに`PASS Count`、`FAIL Count = 0`、`Overall = PASS`が存在する。原文の`PASS  `で始まる行は188行あるが、**I10 Baseline Preparation 1行、I11 Baseline Preparation 3行、I11本文中の追加観測2行**は各Suiteの正式`PASS Count`対象外であり、182件に加算しない。I07の`SUPPORT PASS`も集計対象外。I10初回ABORTはAssertion PASS/FAILの件数には入れず、独立した試行記録として保持。

## 4. 原文から直接確認したContractと観測値

### 4.1 Bootstrap / I03–I06 — Sync Safety / Failure Carrier

| ID | 原文で確認したこと | Source lines |
|---|---|---|
| BOOT | `GetAllVariableDefinitions→BuildSyncDiff→ApplySyncDiff`の成功、既存`ModelName`のBlank/Blank→共通SyncTimestamp、`OldVariable` Already-Unused Timestamp空欄保持、User Configuration保持、行数2維持、テーブル内容復元メッセージ | L7–40 |
| I03 | 不正`{{1stGate}}`を1件検出。`ConfigurationError / TemplateScanResult`、ScanResult Published、SyncDiff Nothing、Before/After 5行×12列一致 | L46–85 |
| I04 | Missing OFTに対して`ConfigurationError / TemplatePath`、両Carrier Nothing、テーブル不変。`TemplatePath`は開始時の`Templates\TESTP204I04.oft`へ復元 | L91–114 |
| I05 | `Status`列を壊すとDirect ReadとManual Syncが`ConfigurationError / Status`、空Collection初期化、ScanResult Published、SyncDiff Nothing、元の列名`Status`へ復元 | L120–166 |
| I06 | `ModelName.Status`をInvalidStatusに変更するとRead Success→Direct BuildSyncDiff Failure→Manual Sync Failure。`ConfigurationError / Status`、ScanResult Published、SyncDiff Nothing、Status元値への復元とBefore/After一致 | L172–226 |

**I03 Fixture復元の境界：** 原文にはOFTへの一時挿入や事前検査はあるが、OFTファイルそのものの最終復元完了を宣言する直接の行はない。過去引継ぎでの「OFT復元済み」は二次情報として保持し、**この原文のみでOFT原状復帰を実証したとはしない**。

**I04 Fixtureの差異：** もとのTemplatePathは`Templates\TESTP204I04.oft`。I05以降は正常OFTとして`Templates\MailTemplate.oft`を参照している。別のテスト間でFixtureが変更されており、I04は「テスト開始時の設定へ復元」を示すだけで、最終グローバル設定値を実証するものではない。

**I06 表示事項：** Preflight見出しに`I05 Normal Template Preflight`とある（L172）。実行ケースはI06であり、結果本体およびCountはI06。テストログ見出しの表示誤記候補であり、Production Defectと判定しない。

### 4.2 I07/I08 — Apply Failure / Fresh Manual Retry

- I07：VariableDefinitionシート保護中に書込み失敗。`UnexpectedError / tblVariableDefinition`でExcel Error 1004。エラーメッセージは **"The table may be partially updated"** と注意している（L245–256）。SyncDiff Nothing、Automatic Retryなし。`SUPPORT PASS`ではこの試行のBefore/After一致が確認できる（L257–258）。
- **No rollback guarantee**：上記はその試行で観測した不変性であり、一般的なTransaction/Rollback/Atomicity保証ではない。
- I08：シート保護解除→`ModelName.Status: Active→Unused`→明示的に再実行。`Reactivated`と分類され、`Status=Active`へ復帰。LastDetectedAtは2026-10-18 09:16:10、Retry時の新SyncTimestamp使用を確認（L263–279）。
- C00–C03で元のVariableDefinitionの状態とシート保護状態を復元。総数37/37 PASS（L281–288）。

### 4.3 I09 / I10 — Outlook Lifecycle

| 確認項目 | I09 Warm | I10 Cold（最終PASS時） |
|---|---|---|
| Outlook実行事前条件 | 起動中・Explorer 1 | 完全終了・OUTLOOK.EXE 0 |
| ExecuteManualSync | Success | Success |
| Outlook実行後 | 起動中・Explorer 1 | OUTLOOK.EXE 1・Visible/Active Explorer 1 |
| Inspector残存 | 0 | 0 |
| Draft Count | 23→23 | Baseline 23→23 |
| VariableDefinition | 最終状態復元、元状態と一致 | 最終状態復元、元状態と一致 |
| PASS | 16/16 | 20/20 |
| Log lines | L294–321 | L351–385 |

**I10前段：** 初回試行は`I10 baseline has not been prepared in this VBA session`、`RESULT = ABORTED`、**Production Pathは実行されなかった**と原文で明記（L325–331）。後で同一VBAセッションのBaseline Preparationを成功させ、Outlookを完全終了してから再実行。Baseline Captured At 2026-10-18 09:43:36、OUTLOOK.EXE Before=0、After=1、最終20/20 PASS。ABORTの正確な操作原因は原文から確定できない。**ABORT結果をPASSへ置換せず、正常な後続試行と併記する。**

### 4.4 I11 — Manual Only / 保存を含む試験操作

- Baseline Preparationで**Workbookを保存してから**Baselineを採取し、VariableDefinitionとLastDetectedAtのBaselineファイルをWindows TEMPへ置く（L389–395）。
- Excelを完全終了・再オープンし、**手動Syncの前に**VariableDefinitionとLastDetectedAtが変化しないことを確認（L397–413）。
- 明示Syncで`ExecuteManualSync.Success=True`、`New=0`、`Reactivated=0`、`Unused=0`、`Existing>0`。User Configuration不変、LastDetectedAtは手動Sync後に更新（L415–428）。
- 最終復元後に**Workbookを保存**し、TEMP Baseline Evidenceファイルを削除したとのログ（L429–437）。P3 UserForm Variantは未実装のためN/A（L438）。
- **Workbook保存に関する解釈**：ユーザーの「Regression後のWorkbook保存なし」は**全試験完了後の追加保存なし**として扱うとI11中の保存ログと両立する。ただし保存の最終時点・当該SHA-256に実際に対応するバイト列はユーザー申告であり、Workbookバイナリ未取得のため独立証明していない。
- **TEMP Fileは削除済み**：ログ上の一時Evidenceパスを、現在存在する生ログとして引用しない。

## 5. Regression Finding / Fixtureと補足留保

| ID | 事象 | Evidence | Classification / 判定 |
|---|---|---|---|
| OBS-P2-05-002 | WordEditorの断続的E_FAIL | 今回のI09/I10では再発が記録されていない | **OPEN / NON-BLOCKINGの既存状態を維持**。根本原因解決とは宣言しない |
| I10-ABORT | 初回Baseline未準備 | 原文L325–331。Production Path未実行 | **ABORTED / 後続試行PASS**。正確な操作原因未確定 |
| I06-HEAD | I06実行中の見出し`I05` | 原文L172 | Test Artifact表示誤記候補。Production不具合認定なし |
| I04-PATH | I04の開始TemplatePathがテスト用OFT | L91、L110 | 当該Case内では元の値へ復元。全Case後のSettings状態は別途確認 |
| I03-OFT | 不正OFT Fixtureの復元 | I03原文に最終復元の直接行なし | 二次記録を保持。OFTファイルのバイト単位復元は本書では未証明 |
| Data Restore | Bootstrap/I03–I11の対象条件に復元テストまたは復元出力あり | 対応するSnapshot／復元行 | **表示データ・該当属性に限る**。数式、書式、入力規則、全状態についての完全な復元保証はしない |
| Final Finding | P2-04 Regressionの新Production Defect | FAIL 0、テスト群すべてOverall PASS | **実行ログ上、新しいProduction Failure未検出**。Final Finding Assessment / Closureは別Gate |

## 6. I12 Evidence Cross-reference / Reuse Boundary

| Unit/Case | 証拠強度・版対応 | 今回I12への評価 |
|---|---|---|
| P2-01 Regression | 独立Record PASS/CLOSED、Scannerソース一致 | **Reuse Candidate**。旧実行時Build／OFT環境への適用性確認が残る |
| P2-02 Regression | 111/111 PASSの独立Record、`modSyncEngine v0.1.3`一致。**原文233行・SHA照合済み** | **Raw verified / Reuse Candidate**。旧Record DRAFT、歴史的実行Build・Fixtureと正式Closure未確認 |
| P2-03 Regression | 46/46 PASSの独立Record、`modVariableDefinitionData v0.1.2`一致。**原文100行・SHA照合済み** | **Raw verified / Reuse Candidate**。旧Record DRAFT、歴史的実行Build・Fixtureと正式Closure未確認 |
| Bootstrap Production Compatibility | **2026-10-18生ログL2–41、29/29 PASS** | **Current-Cycle RAW-LOG VERIFIED**。P2-02→P2-03 Production Pathの根拠 |
| P2-04 I03–I11 | **2026-10-18生ログL44–439、153/153 PASS**。I10初回ABORT経緯含む | **Current-Cycle RAW-LOG VERIFIED** |
| I01/I02 | 旧P2-04 Implementation CompletionにPASS記録 | **今回の独立再実行はしていない**。旧Evidenceの適用性を個別評価 |
| I12集約 | 旧GuideはP2-01/02/03直接再実行、後続P2-04実施計画は既存Evidence統合 | **PENDING**。既存Evidence再利用の受入判断はまだない |

今回受領したP2-02/P2-03原文を加えても、旧P2-02 / P2-03独立Regression Recordを`CLOSED`へ更新しない。既存履歴から新CycleへPASSを無条件に転用せず、再利用条件と結果を評価してからI12へ集約する。

### 6.1 旧独立Regression Raw Evidenceの追補（2026-10-19）

| Unit | 原文Archive | SHA-256 | Suites | Result | Gate |
|---|---|---|---:|---|---|
| P2-02 | `P2-02_Regression_UserSupplied_20261019_Raw.txt` | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` | 6 | 111/111 PASS、FAIL 0 | Raw confirmed; Closure pending |
| P2-03 | `P2-03_Regression_UserSupplied_20261019_Raw.txt` | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` | 5 | 46/46 PASS、FAIL 0 | Raw confirmed; Closure pending |

P2-02原文の末尾には33件Bootstrapの**完全同一ログ再掲**があるため追加カウントしない。P2-03各Suiteに復元報告があるが完全Fixture復元保証とは扱わない。両ファイル内の実行日時・当時のWorkbook SHA-256は特定できず、`261018`というファイル名だけで実行日認定しない。原文・SHA・残件の詳細は各Raw Evidence照合追補を参照。

## 7. Quality Gates / 次のアクション

| Gate | Status | 未完了条件 |
|---|---|---|
| 実行Log収集（今回182件） | **PASS / RECEIVED** | 原文を改変せず保管し、リンク／SHA-256で追跡可能にする |
| Assertion Count / Outcome | **PASS / RAW-LOG-VERIFIED** | 182件すべて一致、FAIL 0件 |
| Source Provenance | **9/9 MATCH** | ただし実行Workbookバイナリ独立照合は別途 |
| Baseline記録 | **BL-MVP-004 Approval Record確認済み** | Project Overview / Registryの旧Baseline記載との整合は別Gate |
| P2-02/P2-03旧Record | **DRAFT / CLOSURE PENDING、原文ログ照合済み** | 旧実行時Build、Evidence/正式保存先、Fixture、Findingを照合 |
| I01/I02 reuse | **PENDING** | 過去Evidenceと今回Buildの対応・影響評価 |
| I12 Final | **PENDING / NOT CLOSED** | Evidence Coverage、旧Evidence再利用、最終Finding／必要なCompile・Fixture状態の確定 |
| P2-05 / CP-P2 / Formal MVP Test | **NOT CLAIMED** | 別途Phase Gate／Formal Test |

### 次の作業

1. **今回の原文ログをプロジェクトEvidenceへ保存**：ルート`Evidence/`（推奨`Evidence/P2-04/2026-10-18/`）に元ファイルバイトを変更せず保存。文書側にSHA-256と相対Pathを登録。個人フォルダ等の絶対パスが含まれるためアクセス権限を適切に管理する。
2. **P2-02/P2-03 Regression Recordの再評価**：111件・46件の原文ログは受領・照合済み。別建てのEvidence Archive（SHA-256付）を登録し、歴史的実行時Buildを特定してClosure判断。今回182/182とは合算しない。
3. **I01/I02過去Evidenceの適用性評価**：今回Production Source 9件の一致と変更影響により対象Contractの再利用根拠を明示。
4. **I12 Final Closure判定**：上記とFinal Finding Assessment完了後、`PASS/CLOSED`か追加証拠が必要かを判断。

**プロジェクト書込み状態**：本書は会話内生成物。GitHubへの追加・`Evidence/`配置・Document Registry更新・Commitは**未実施**。Original Completion RecordやCurrent Project Controlを変更していない。

## まとめ / Summary

**日本語：** 2026-10-18の実行ログ439行を受領し、Bootstrap 29件＋I03～I11 153件の計182件がPASS、FAIL 0件であることを原文のAssertionとOverall表示から直接確認した。I10初回ABORTは残し、Fixture／Rollback／保存に関する留保も区別した。P2-02 111件・P2-03 46件の過去原文も受領したが、旧Recordの正式ClosureとI12最終Gateは未完了。

**English:** The supplied 439-line raw log confirms 182/182 passing checks with zero failures. The initial I10 abort is preserved separately. Historical P2-02 and P2-03 raw transcripts are now verified. Historic build attribution and I12 final closure remain pending.
