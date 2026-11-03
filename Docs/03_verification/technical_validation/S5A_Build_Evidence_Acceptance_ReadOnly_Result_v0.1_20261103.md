# S5-A Build／Evidence受入範囲確認 Read-only結果

S5-Aの判定は `REVIEW_REQUIRED` です。

外部作業Workbookは、S5対象として `VERIFIED_BY_WORKBOOK_SHA256` により識別できました。残る確認は、過去のP05 Evidenceをこの対象BuildのCompletion審査へ適用する範囲です。既存21ケースのPASSは維持し、再実行はしていません。

## 1. 対象Workbook

| 対象 | サイズ | 確認結果 |
| --- | --- | --- |
| 外部作業Workbook候補 | 1,003,775 bytes | E-P204-WBとSHA-256完全一致 |
| 保全済みE-P204-WB | 1,003,775 bytes | 外部候補と一致 |
| Repository側Workbook | 1,003,571 bytes | 別バイナリ。切替なし |

一致したSHA-256：

```text
0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9
```

外部候補は既存Evidenceで指定された1件です。拡張子だけでなく、内部のマクロ有効Workbook形式と`vbaProject.bin`の存在も確認しました。

ただし、次は証明していません。

- Workbook内VBAProject全体とRepository Sourceの完全同一性
- 過去の各P05実行Workbookとのバイナリ同一性
- Workbook全イベントの接続・動作の正当性

## 2. Current Sourceとの対応

現行ファイルのSHA-256は、S5 Precheckで参照したSourceから変化していません。

| 現行Source | 版・対応 | 既存Reviewとの関係 |
| --- | --- | --- |
| modTemplateScanner | P2-01 v0.1.1 | 既存9 Source対応・Provenance |
| modSyncEngine | P2-02 v0.1.3 | 同上 |
| modVariableDefinitionData | P2-03 v0.1.2 | 既存Source ReviewのPersistence対象は旧v0.1.1 fix1 |
| modSyncApplication | P2-04 v0.1 | Source Review §4～6のApplication／Carrier |
| modUiController | P2-05 v0.1 | Patch Design・Implementation Record・Partial Result |
| modOutlookAdapter | P1-07 v0.1.1 | 既存9 Source対応・Provenance |
| modSettingsData | DF-P1-001 v0.1 | 同上 |
| COperationResult | 既存保存版 | Source Review §7 |
| CErrorInfo | 既存保存版 | Source Review §8 |

保全済み`E-P204-SOURCE`との正規化比較9/9一致、文字列リテラル比較9/9一致を既存Evidenceから維持します。原バイト列一致やWorkbook内VBAProject全体の一致には格上げしません。

Source上では、以下の接続を確認しました。

```text
RunManualSync
  → ExecuteManualSync(syncDiffResult, templateScanResult)
  → COperationResult.Successで分岐
      Success：既存4分類を通知へ渡す
      Failure：InvalidCandidates → ErrorsのMessage／Target → 汎用通知
```

確認箇所は、`modUiController`の38～117行、`modSyncApplication`の36～216行です。補助的に`modResult`も参照しましたが、9 Source比較対象へ追加した扱いにはしていません。

WorkbookはスプレッドシートのRead-only手順に従い、ファイル展開・保存をせず構造情報だけを検査しました。読み取ったOOXML部分にはButton、ActiveX、マクロ割当・コールバックは見つかりませんでした。ただし、VBA内イベントは未確認です。Button不存在だけを不適合とは判定していません。

今回の確認は、正式なS01～S32 Static Reviewではありません。

## 3. P05 Evidence対応表

参照略称：

- **V**：[Verification Evidence Consolidation v0.1](<P2-05 Verification Evidence Consolidation v0.1.md>)
- **P**：[Verification Partial Result v0.1](<P2-05 Verification Partial Result v0.1.md>)
- **F7**：`IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md`（既存外部資料）
- **U**：`BUILD_ASSOCIATION_UNKNOWN`
- **S**：`BUILD_ASSOCIATION_SUPPORTED`。既存9 Source／Source-pathの対応に限定し、Workbook全体の同一性は含みません。

全21ケースの既存結果は、`DOCUMENTED_PASS_WITH_LIMITATION`として維持します。

| Case | Evidence・該当節 | Documented Result／観測 | 実行日 | Build対応 | 方法 | 限定 | 再利用範囲・残課題 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| I01 | Mixed Result Runtime Record v0.1 §5～8・12、V§6 | PASS。4分類各1、Carrier存在、共通Timestamp | 2026-10-07 | U | Runtime／Locals／UI／データ比較 | 個別実行Hashなし | 記録再利用可。最終Buildへの適用判断待ち |
| I02 | New Only Runtime Record v0.1 §5・7・10、V§6 | PASS。New=1、他0、新規行追加 | 2026-10-07 | U | Runtime／Behavioral | 内部CarrierはLocals直接観測なし | 既存Behavioral判定を維持。Build確認待ち |
| I03 | F7§2・6、V§4.1・6 | PASS。Fresh Warm初回と直後の再実行、Existing=4 | UNKNOWN | U | Runtime／UI | 個別Hash・ケース別Locals記録なし | 既存PASS維持。独立した複数Fresh Sessionとはしない |
| I04 | Reactivated Only Runtime Record v0.1 §5・7・10、V§6 | PASS。Reactivated=1、復活表示、Status更新 | 2026-10-07 | U | Runtime／Behavioral | 内部CarrierはLocals直接観測なし | 既存判定維持。Build確認待ち |
| I05 | Unused Only Runtime Record v0.1 §5～6・10、V§6 | PASS。Unused=1、行・検出履歴保持 | 2026-10-07 | U | Runtime／Locals／データ比較 | 個別実行Hashなし | 記録再利用可。Build確認待ち |
| I06 | Zero-diff Runtime Record v0.1 §5～6・10、V§6 | PASS。全分類0でもSuccess、データ不変 | 2026-10-07 | U | Runtime／Locals／UI | 個別実行Hashなし | 記録再利用可。Build確認待ち |
| I07 | Invalid Candidate実施レポート v0.1 §6～10・12、V§7 | PASS。Failure、Diffなし、Scan保持、更新なし | 2026-10-04 | U | Runtime／Locals／UI／比較 | InvalidCandidates.Count=1は直接未観測 | 既存組合せEvidenceを維持。Count確認だけの再試験不要 |
| I08 | OFT Missing Evidence Record、V§7 | PASS。ConfigurationError、両Carrierなし、更新なし | 2026-10-05 | U | Runtime／Locals／UI／比較 | 個別実行Hashなし | 記録再利用可。Build確認待ち |
| I09 | F7§1・6、P§2、V§7 | PASS。WordEditor技術Failureを制御通知、誤Successなし | UNKNOWN | U | Runtime＋Source-path | Root Cause未証明、個別Hashなし | 既存Failure Evidenceを維持 |
| I10 | P§2、V§4.2、P2-04 Definition Read Failure Evidence | PASS。読取失敗とFailure経路 | UNKNOWN | S※ | P2-04 Harness＋P2-05 Source-path | P05 UIでの新規Runtime実測ではない | 受理済み組合せ方式で再利用可 |
| I11 | P§2、V§4.2、P2-04 BuildSyncDiff Failure Evidence | PASS。Build失敗、UIから直接再呼出しなし | UNKNOWN | S※ | Harness＋Source-path | HarnessとUI実行を同一視不可 | 受理済み方式を維持 |
| I12 | P§2、V§4.2、P2-04 Apply Failure Evidence | PASS。Apply失敗、Success用Diff非公開 | UNKNOWN | S※ | Harness＋Source-path | Rollback／Atomicity保証ではない | 受理済み方式を維持 |
| I13 | P§2、V§4.2 | PASS。Success＋DiffなしをFailure表示へ | UNKNOWN | S | Technical negative Source-path | Fault Injection未実施 | Source根拠として再利用可。新規注入不要 |
| I14 | P§2、V§4.2 | PASS。Success＋ScanなしをFailure表示へ | UNKNOWN | S | Technical negative Source-path | Fault Injection未実施 | 同上 |
| I15 | P§2、V§4.2 | PASS。表示詳細なし→汎用Failure通知 | UNKNOWN | S | Technical negative Source-path | 通知回数のRuntime実測ではない | 受理済みSource-path判定を維持 |
| I16 | `P05‐I16 ‐ Fresh Retry Evidence Record.md`、V§7 | PASS。原因修正後の明示RetryでSuccess、旧Failure非再利用 | 2026-10-04 | U | Controlled Runtime／Behavioral | Object Identity比較なし、個別Hashなし | 独立Controlled Retry記録を再利用。F7からの成立とはしない |
| I17 | P§2、V§4.3 | PASS。明示Entry、確認Source内に自動同期経路なし | UNKNOWN | S | Source／既存ユーザー確認 | Workbook全イベントの完全証明ではない | Source範囲で再利用可。組込イベント接続はUNKNOWN |
| K01 | P§3、V§5、Source Review §4.2 | PASS。既存2出力API維持 | UNKNOWN | S | Contract／Source | 今回のCompile結果ではない | Contract Evidenceとして再利用可 |
| K02 | P§3、V§5、Source Review §6 | PASS。既存4分類を直接消費 | UNKNOWN | S | Contract／Source | 新規Runtime実測なし | 同上 |
| K03 | P§3、V§5、Source Review §5 | PASS。InvalidCandidatesを再Scanせず利用 | UNKNOWN | S | Contract／Source | 同上 | 同上 |
| K04 | P§3、V§5、Source Review §7～9 | PASS。既存Result／Errorを利用 | UNKNOWN | S | Contract／Source | 同上 | 同上 |

※ I10～I12のP2-04 Harness Evidenceと、P2-05 UIのSource-path Evidenceは別です。P2-04側の実施日を、P05ケースの実行日として転記していません。

## 4. 残るUNKNOWNと確認案

[Build Provenance v0.4](<P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md>)の実行者申告は、P2-01～P2-04 Regressionの9 Source共通構成を対象としています。過去の全P05 Runtime実行まで自動的には拡張できません。

次に実行者へ確認する質問案は、以下の2点です。今回は回答を生成・代行していません。

1. **P05 Runtime実施時のProduction Sourceは、E-P204-SOURCEの9モジュールと同じ構成でしたか。異なる、または不明なケースを特定できますか。**
2. **各P05実施後から今回の対象Workbookまでに、Productionコード、関連Workbook／Worksheetイベント、参照設定、マクロ割当を変更しましたか。分からない範囲はUNKNOWNとして確認できますか。**

補足確認でも過去の個別Hashは復元できません。確認不能な範囲が残る場合は、その限定を伴う最終BuildへのEvidence適用可否をユーザーが判断する必要があります。全面再実行は要求していません。

次の状態は変更していません。

- IF-P2-05-001：CLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING
- OBS-P2-05-002：OPEN／NON-BLOCKING
- WordEditor E_FAIL Root Cause：NOT PROVEN
- OneDriveRegistration／ManagementShareEffectiveAccess／Stage2TotalExecutionCount：UNKNOWN

仕様成立時のExecution Baseline **BL-MVP-003**と、現在受入済みの**BL-MVP-004**も区別したままです。

## 5. 次回の最小承認範囲

まず上記の実行者確認・Evidence受入範囲を確定し、その後、別途承認により進める最小範囲は次のとおりです。

1. 識別済み外部Workbookの最終VBA Compileと、必要な組込Source・Button／イベント接続確認
2. 現行対象での正式Static Review S01～S32
3. Production Patch Review
4. Final Finding Assessment

Workbookの起動・検査方法、保存やImport／Exportの可否は、その実行承認で明確にする必要があります。既存RegressionやArchiveの再実行は今回の結果から要求していません。

```text
S5AAuthorization: APPROVED_READ_ONLY

TargetWorkbook:
  CandidateIdentified: YES
  E-P204-WB_SHA256_Match: PASS
  TargetBuildDesignation: VERIFIED
  IdentificationMethod: VERIFIED_BY_WORKBOOK_SHA256

SourceAssociation:
  NineSourceNormalizedMatch: CONFIRMED_FROM_EXISTING_EVIDENCE
  WorkbookVBAProjectIdentity: UNKNOWN
  UIEntryConnection: VERIFIED  # 確認したSource上の接続
  WorkbookEventConnection: UNKNOWN

P05EvidenceReuse:
  I01_I17_DocumentedPASS: PRESERVED
  K01_K04_DocumentedPASS: PRESERVED
  EvidenceMapping: PASS
  HistoricalBuildIdentity: UNKNOWN
  AdditionalOperatorConfirmation: REQUIRED

NextS5TechnicalScope:
  FinalVBACompile: PENDING
  StaticReview_S01_S32: PENDING
  ProductionPatchReview: PENDING
  FinalFindingAssessment: PENDING

OBS_P2_05_002: OPEN_NON_BLOCKING
ResidualUnknowns: UNCHANGED
S5ADecision: REVIEW_REQUIRED

DocumentMutation: NONE
SourceMutation: NONE
WorkbookMutation: NONE
TechnicalExecution: NONE
GitOperation: NONE
BaselineMutation: NONE
P2_05CompletionRecorded: FALSE
S6Started: FALSE
```

参照51件の前後SHA-256・サイズ・更新時刻は不変でした。Excel起動、Compile、マクロ実行、ファイル書込み、Git操作は行っていません。S1～S4の確定状態を維持し、ここで停止します。
