# 定型メール作成ツール Project Document Registry and Approved Baseline v1.23

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | 定型メール作成ツール Project Document Registry and Approved Baseline |
| バージョン | v1.23 |
| 文書種別 | Project Control / Document Registry / Baseline Manifest |
| 対象プロジェクト | 定型メール作成ツール |
| 適用ルール | AI協働開発 文書管理・Baseline運用ルール v0.1 |
| 更新日 | 2026-10-16 |

### v1.23 更新概要

- [P05-I02 New Only](<../03_verification/technical_validation/P05-I02 New Only Runtime Verification Record v0.1.md>)、[I04 Reactivated Only](<../03_verification/technical_validation/P05-I04 Reactivated Only Runtime Verification Record v0.1.md>)、[I05 Unused Only](<../03_verification/technical_validation/P05-I05 Unused Only Runtime Verification Record v0.1.md>)、[I06 Zero-diff Success](<../03_verification/technical_validation/P05-I06 Zero-diff Success Runtime Verification Record v0.1.md>)および[I01 Mixed Result](<../03_verification/technical_validation/P05-I01 Mixed Result Runtime Verification Record v0.1.md>)のRuntime Verification Record v0.1を追加。添付は実施日2026-10-07、5件すべてPASS／CLOSED・Re-test NOT REQUIREDを報告する。I02／I04のSuccess・Carrier存在はBehavioral／Contract-based Evidence、I05／I06／I01はLocalsの直接確認を含む記録として保持する。
- 参照されるScreenshot等の元Evidenceは今回の添付対象外。I01記録上では残っていたRuntime 5件をCloseし、次工程をVerification Evidence Consolidationとする。Regression・Compile・Static Review・Production Patch Review・Final Finding Assessment・Completion判断が後続として残り、P2-05 COMPLETE／CP-P2確立を意味しない。当地の成果物受入・同期状態、Current Approved Baseline BL-MVP-003およびOBS-P2-05-002 OPEN／NON-BLOCKINGの扱いを維持する。

### v1.22 更新概要

- ユーザー提示の[Context Handoff_22](<../05_handoff/history/Context Handoff_22.md>)を引継ぎ履歴として保存。Approved仕様書の状態反映、P05-I07／I16／I08のPASS／CLOSED記録、Evidence上の留保、残るRuntime Verificationと後続Completion Gateをまとめる。
- 次の記録上のActionはP05-I02 New OnlyのControlled Fixture設計で、I04／I05／I01／I06が続く。P2-05はImplementation Verification継続中、P2-05 COMPLETE・CP-P2は未成立、OBS-P2-05-002はOPEN／NON-BLOCKINGとする本文を保持する。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003は従来の管理状態を維持する。

### v1.21 更新概要

- ユーザー提示の[P05-I08 OFT Missing Evidence Record](<../03_verification/technical_validation/P05-I08 — OFT Missing Evidence Record.md>)をMarkdownとして保存。実施日2026-10-05、PASS／Re-test NOT REQUIREDを記録する。Settingsを変更せずOFTを一時リネームし、ConfigurationError／TemplatePath、両Carrier Nothing、Failure通知1回・Success通知0回、VariableDefinition不変とOFT復元を確認したとの結果を保持する。
- 提示結果は新規Findingなし・Blocking Finding 0、Unhandled Runtime Errorなし、OBS-P2-05-002非再発とする。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003は従来の管理状態を維持する。

### v1.20 更新概要

- ユーザー提示の[P05-I08 OFT Missing 詳細実施手順書 v0.1](<../03_verification/technical_validation/P05-I08 — OFT Missing 詳細実施手順書 v0.1.md>)をMarkdownとして保存。Settingsを変更せずOFTを一時リネームするFixture、Failure Carrier・単一Failure通知・Success通知なし・VariableDefinition不変の確認、想定外結果の切り分けとOFT復元を定める未実行手順である。
- 提示本文を保持し、I08実施結果やPASS判定は追加していない。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.19 更新概要

- ユーザー提示の[P05-I16 Fresh Retry Evidence Record](<../03_verification/technical_validation/P05‐I16 ‐ Fresh Retry Evidence Record.md>)をMarkdownとして保存。実施日2026-10-04、PASS／Re-test NOT REQUIREDを記録する。I07 Failure後の原因修正、Automatic Retryなし、明示的な2回目Manual Sync成功、Current State再取得・Previous Failure Result非再利用のBehavioral Evidenceを保持する。
- 提示結果はSuccess通知1回・Failure通知0回、Existing 4件、Active VariableのLastDetectedAt更新、OldVariableの意図しない更新なし、新規Findingなし・Blocking Finding 0、OBS-P2-05-002非再発とする。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003は従来の管理状態を維持する。

### v1.18 更新概要

- ユーザー提示の[P05-I16 Fresh Retry 実施手順](<../03_verification/technical_validation/P05-I16 Fresh Retry 実施手順.md>)をMarkdownとして保存。I07 Failureを1回目Executionとして利用し、原因修正後の明示的Manual Sync、Automatic Retryなし、Current State再取得・Previous Result非再利用、Success通知と正常Persistenceを確認する未実行手順である。
- 提示された本文を保持し、I16実行結果やPASS判定は追加していない。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.17 更新概要

- [P05-I07 Invalid Candidate 実施レポート v0.1](<../03_verification/technical_validation/P2-05 Implementation Verification Report_P05-I07 — Invalid Candidate 実施レポート v0.1.md>)を外部Implementation Verification記録として追加。本文の実施日2026-10-04とPASS／Re-test NOT REQUIRED判定を保持する。Failure Carrier、Invalid Candidate表示、単一Failure通知、VariableDefinition不変を報告する一方、InvalidCandidates CollectionのCount = 1は直接未観測とする留保を含む。Screenshot等の元Evidenceは今回の添付対象外。
- レポートの後続はP05-I16 Fresh Retryへの引継ぎであり、当地でのI07受入・追加実行・I16実行判断は行っていない。原本の先頭見出し末尾空白2文字を除去し、改行をLFへ正規化した（Editorial Change）。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.16 更新概要

- [P05-I07 Invalid Candidate 詳細実施手順書 v0.1](<../03_verification/technical_validation/P05-I07 Invalid Candidate 詳細実施手順書 v0.1.md>)を追加。`{{Bad-Name}}`を用いるFixture、Failure Carrier・単一通知・VariableDefinition不変の確認、WordEditor E_FAIL再発時の切り分けおよびI16への引継ぎを定める未実行手順である。
- 同時添付の[P2-05 Implementation Specification v0.1 Approved](<../02_implementation/P2_Scan_Sync/P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md>)で既存同名ファイルを更新。差分はReview情報欄、承認説明・見出し・Next Gate・Summary等のEditorial／Governance Changeで、技術契約・検証条件は同一。添付のVersion v0.1／APPROVEDを保持し、旧内容はコミット`d8ec4883cb39196f3134facc06ddfdadbc0d463b`の同パスから復元可能。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.15 更新概要

- [Context Handoff_21](<../05_handoff/history/Context Handoff_21.md>)を過去時点の引継ぎとして保管。P2-05実装・Compile・部分検証、IF-P2-05-001調査とFresh Warm 2回PASS後の処置、残るRuntime Verificationをまとめた外部記録である。本文はIF-P2-05-001をCLOSED AS NON-REPRODUCIBLE IMPLEMENTATION FINDING、残留事象をOBS-P2-05-002 OPEN／NON-BLOCKINGと報告する。
- 本文が参照する`IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md`は当地では未登録。Handoffの報告を当該判断書の保存済み確認や当地のClosure・検証再開判断に置き換えず、原記録として保持する。当地の成果物受入・同期状態、Current Approved Baseline BL-MVP-003を維持し、現在地はOverviewとCurrent Handoffを参照する。

### v1.14 更新概要

- [IF-P2-05-001 Investigation Update v0.6](<../03_verification/technical_validation/IF-P2-05-001 Investigation Update v0.6.md>)を外部調査記録として追加し、最新の調査参照先とする。v0.5以前は時点別の経過記録として保持する。添付はP1／診断実行後の同一Office Sessionで`RunManualSync`が2回成功し、P05-I03 Existing OnlyおよびI09 Failure PresentationをPASSと報告する。I16 Fresh Retryは未Closeである。
- 原因はセッション依存のWordEditor初期化状態が有力とされるが未確定。Finding OPEN／Production Correction NONEを維持し、次の外部確認は独立したFresh Warm SessionのFW-1／FW-2。非ブロッキングへの変更と成功経路検証再開は両試行のPASSを条件とする後続判断である。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.13 更新概要

- IF-P2-05-001の[Investigation Update v0.4](<../03_verification/technical_validation/IF-P2-05-001 Investigation Update v0.4.md>)、[v0.5](<../03_verification/technical_validation/IF-P2-05-001 Investigation Update v0.5.md>)および[WordEditor Timing Diagnostic v0.1 CP932](<../../tests/vba/P2_Scan_Sync/modP2_05WordEditorTimingDiagnostic_v0.1_CP932.bas>)を追加。最新の調査状況はv0.5を参照し、v0.4以前は時点別の経過記録として保持する。診断専用VBAは内部名`modP2_05WordEditorTimingDiagnostic`・CP932を維持してtestsへ保存する。
- 添付はP1-03 Snapshotと診断A／B／CのPASS、現`modSyncApplication`の意味的差分なしを報告する。v0.5では単一DoEvents不足の仮説は現診断結果に支持されず、初回WordEditor接続前後のセッション依存状態を未確定の仮説として残す。次の外部確認はFresh Warm Sessionでの再現。IF-P2-05-001はOPEN、成功経路の検証はPAUSED、Production PatchはNONEとされる。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.12 更新概要

- IF-P2-05-001の[WordEditor Access Failure Investigation Plan v0.1](<../03_verification/technical_validation/IF-P2-05-001 WordEditor Access Failure Investigation Plan v0.1.md>)、[Investigation Update v0.2](<../03_verification/technical_validation/IF-P2-05-001 Investigation Update v0.2.md>)および[v0.3](<../03_verification/technical_validation/IF-P2-05-001 Investigation Update v0.3.md>)を外部の技術検証・調査記録として追加。最新の調査状況はv0.3を参照し、初期計画とv0.2は経過記録として保持する。
- 添付はWarm状態のManual SyncでWordEditor失敗が2回再現し、直接のP1-02 Warm RegressionはPASSと報告する。v0.3は初期化タイミング・Snapshot処理順序・現WorkbookのOrchestration差分を未確定の仮説として残し、次の切り分け候補をP1-03 Snapshot Testとする。IF-P2-05-001はOPEN、P2-05成功経路の検証はPAUSED、P05-I09 Failure PresentationはPASS candidate。当地では記録追加として扱い、成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.11 更新概要

- [P2-05 Production Implementation Record v0.1](<../02_implementation/P2_Scan_Sync/P2-05 Production Implementation Record v0.1.md>)と[modUiController v0.1 CP932候補](<../02_implementation/P2_Scan_Sync/modUiController_P2-05_v0.1_CP932.bas>)を追加。実装記録は候補作成時点の状態を保持し、外部Workbookについて`modUiController`／Manual Sync Buttonが未存在との確認によりOBS-P2-05-SR-001をCLOSEDと記録する。VBA候補は内部名`modUiController`・CP932を維持して実装資料配下へ保存する。
- 後続の[VBA Compile Evidence v0.1](<../03_verification/technical_validation/P2-05 VBA Compile Evidence v0.1.md>)、[Verification Execution Plan and Evidence Record v0.1](<../03_verification/technical_validation/P2-05 Verification Execution Plan and Evidence Record v0.1.md>)および[Verification Partial Result v0.1](<../03_verification/technical_validation/P2-05 Verification Partial Result v0.1.md>)を追加。添付は外部環境のImport・Compile PASS、I09～I15／I17とK01～K04の計12件PASSを報告し、Runtime UIのI01～I08／I16はNOT RUN、RegressionとFinal Static Reviewは未着手、P2-05 VerificationはIN PROGRESSとする。当地の成果物受入・同期状態とCurrent Approved Baseline BL-MVP-003を維持する。

### v1.10 更新概要

- [P2-05 Current Production Source Review v0.1](<reviews/P2-05 Fail Closed - Sync Result - Phase Integration Current Production Source Review v0.1.md>)および[Production Patch Design v0.1](<../02_implementation/P2_Scan_Sync/P2-05 Fail Closed - Sync Result - Phase Integration Production Patch Design v0.1.md>)を追加。添付はSource Review PASS／CLOSED・Patch Scope CONFIRMED、Design APPROVED FOR IMPLEMENTATIONを記録し、実装対象を`modUiController`と`RunManualSync()`のUI Entry／基本通知に限定する。
- Source Review上ではOBS-P2-05-001／002はRESOLVED、003はPARTIALLY RESOLVEDで、Workbook固有の確認はOBS-P2-05-SR-001へ引き継ぐ。既存ボタン／マクロ接続はWorkbook Integration・P2-05 Verificationで完了前に確認する事項である。添付の次GateはProduction Implementation。当地の成果物受入・同期状態およびCurrent Approved Baseline BL-MVP-003は従来の管理状態を維持する。

### v1.09 更新概要

- P2-05の[Boundary Confirmation v0.1](<../02_implementation/P2_Scan_Sync/P2-05 Fail Closed - Sync Result - Phase Integration Boundary Confirmation v0.1.md>)、[Boundary Cross-document Consistency Review v0.1](<reviews/P2-05 Fail Closed - Sync Result - Phase Integration Cross-document Consistency Review v0.1.md>)、[Implementation Specification v0.1 Approved](<../02_implementation/P2_Scan_Sync/P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md>)、[Specification Cross-document Consistency Review](<reviews/P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Cross-document Consistency Review.md>)および[Candidate](<../02_implementation/P2_Scan_Sync/P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Candidate.md>)を追加。仕様の参照先はApproved版とし、Candidate版は承認前の策定記録として保持する。Boundary ReviewはBC-P2-05-001／002を解決済み、Specification ReviewはPASS／CLOSED・Specification APPROVED・Residual Conflict／Blocking Finding 0と報告する。
- 添付はBL-MVP-003を前提に、UI LayerのManual Sync Entry・基本結果通知・Fail Closed境界を定義する。次GateはCurrent Production Source Reviewで、OBS-P2-05-001～003は非ブロッキングの確認事項として残る。添付の承認・Review判定は原記録として保持し、当地の別PC成果物受入・同期待ち状態およびCurrent Approved Baseline BL-MVP-003を維持する。

### v1.08 更新概要

- [Context Handoff_20](<../05_handoff/history/Context Handoff_20.md>)を過去時点の引継ぎとして保管。別環境のP2-04 Approved Contract補正、統合Static Review、Controlled Correction、Regression Evidence、完了条件照合・完了判断およびP2-05への引継ぎをまとめた記録である。
- 添付のP2-04 PASS／COMPLETE、承認・Closureおよび次Unitの記述は原記録として保持する。当地の受入状態は別PC成果物の同期・独立確認待ち、Current Approved BaselineはBL-MVP-003を維持し、再開時の現在地はOverviewとCurrent Handoffを参照する。

### v1.07 更新概要

- [P2-04 Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-04 Manual Sync Integration Completion Record v0.1.md>)および[Completion Criteria Final Check v0.1](<reviews/P2-04 Manual Sync Integration Completion Criteria Final Check v0.1.md>)を外部のUnit完了・完了条件照合記録として追加。添付は15/15 Completion Criteria PASS、P2-04 PASS／COMPLETE、Active／Blocking Finding 0を報告し、Final Check第4節にProduction Patch DesignのAPPROVED AS IMPLEMENTED判断を記録する。
- 添付本文の承認・判定は原記録として保持し、当地の受入状態は従来どおり別PC成果物の同期・独立確認待ちとする。Current Approved BaselineはBL-MVP-003を維持する。添付の完了範囲はP2-04 Unitであり、P2 PhaseはIN PROGRESS、CP-P2はNOT ESTABLISHED、Formal MVP Testは後続工程とされている。

### v1.06 更新概要

- [P2-04 Final Finding Assessment v0.1](<reviews/P2-04 Manual Sync Integration Final Finding Assessment v0.1.md>)、[Production Patch Review v0.1](<reviews/P2-04 Manual Sync Integration Production Patch Review v0.1.md>)および[Regression Evidence Finalization v0.1](<reviews/P2-04 Manual Sync Integration Regression Evidence Finalization v0.1.md>)を外部の最終判断・Review・Evidence記録として追加。これらはP2-04のActive／Blocking Finding 0、Production Patch Review PASS、Regression Evidence PASS／FINALIZEDを記録する。
- 当地では各記録の前提・Production Source・I01～I12、Compile、Regression EvidenceおよびStatic Review結論を独立確認していない。したがって追加は当地のFinal Finding Assessment PASS、P2-04 PASS／COMPLETE、IF-P2-04-001 Closure、Current Approved Baseline BL-MVP-003の変更、P2 Phase／CP-P2完了または`src`／Workbook／OFTの変更を意味しない。

### v1.05 更新概要

- [P2-04 Integrated Static Review v0.1](<reviews/P2-04 Manual Sync Integration 統合Static Review v0.1.md>)を、同名の[Open版](<reviews/P2-04 Manual Sync Integration 統合Static Review v0.1_Open.md>)の確定後続版として追加。Open版のISR-01 Evidence不足を、[Production Change Scope Correction Record](<reviews/P2-04 Production Change Scope Correction Record v0.1.md>)で記録した管理済み補正として評価し、ISR-01をPASS WITH CONTROLLED CORRECTION、全29 ControlsをPASS／CLOSEDとする外部Review記録である。
- 当地ではProduction Module Diff、Correction前提およびReview結論を独立確認していない。したがって、本確定版の追加は当地のStatic Review Close、IF-P2-04-001 Closure、P2-04 PASS／COMPLETE、Current Approved Baseline BL-MVP-003の変更、P2 Phase／CP-P2完了または`src`／Workbook／OFTの変更を意味しない。

### v1.04 更新概要

- [P2-04 Integrated Static Review v0.1 Open](<reviews/P2-04 Manual Sync Integration 統合Static Review v0.1_Open.md>)、[Production Change Scope Correction Record v0.1](<reviews/P2-04 Production Change Scope Correction Record v0.1.md>)および[Static Review Scope Correction Record](<reviews/P2-04 Static Review Scope Correction Record.md>)を外部のStatic Review／Scope判断記録として追加。統合ReviewはISR-01のProduction Module Diff Evidence不足により28/29 PASS・Close Pending、Correction RecordはIF-P2-04-001対応を管理済み補正としてISR-01をPASS WITH CONTROLLED CORRECTIONと扱う記録である。
- これらはBL-MVP-003を前提とした外部の時点別記録であり、当地では各前提・Production Module Diff・Static Review判定を独立確認していない。Current Approved Baseline BL-MVP-003、P2-04未完了、Formal MVP Test NOT RUN、`src`／Workbook／OFTを維持し、Static Review Close、IF-P2-04-001 Closure、P2-04 PASS／COMPLETE、Baseline更新またはP2 Phase／CP-P2完了を行わない。

### v1.03 更新概要

- [Context Handoff_19](<../05_handoff/history/Context Handoff_19.md>)を過去時点の引継ぎとして保管。別環境におけるP2-04 I03～I12のScenario Verification、I05 Harness補正、P2-02／P2-03 RegressionおよびP2-04の後続Completion Gateを記録する。
- 本記録はBL-MVP-004および外部環境のI01～I12 PASSを含む履歴であり、当地のCurrent Approved Baseline BL-MVP-003、P2-04未完了、Formal MVP Test NOT RUN、`src`／Workbook／OFTを変更しない。当地でのI03～I12受入、P2-04 PASS／COMPLETE、IF-P2-04-001 Closure、P2 Phase／CP-P2完了、Baseline更新、Import、CompileまたはVBA実行の根拠にはしない。

### v1.02 更新概要

- [P2-04 I12 Contract Regression Guide v0.1](<../03_verification/technical_validation/P2-04_I12_Contract_Regression_Guide_v0.1.md>)を追加。P2-01、P2-02 v0.1.3、P2-03 v0.1.2およびP2-02→P2-03 Bootstrap Production Compatibilityの既存Regression Suiteを、I12 Contract Regression Evidenceとして再実行する未実行計画である。新規Aggregator Harnessは追加しない。
- 添付ガイドが記載するWorkbook Import、VBA Compile、各Regression実行およびEvidence取得は当地で行わない。Current Approved Baseline BL-MVP-003、P2-04未完了、Formal MVP Test NOT RUN、`src`／Workbook／OFTを維持し、I12 PASS、P2-04 PASS／COMPLETE、Baseline更新またはP2 Phase／CP-P2完了を行わない。

### v1.01 更新概要

- [P2-04 I11 Manual Only Guide v0.1](<../03_verification/technical_validation/P2-04_I11_Manual_Only_Guide_v0.1.md>)および[I11 Manual Only Harness v0.1候補](<../../tests/vba/P2_Scan_Sync/modP2_04I11ManualOnlyVerification_v0.1_CP932.bas>)を追加。Workbookを閉じて再オープンしただけではVariableDefinitionとLastDetectedAtを変更せず、明示的Manual Sync後だけ必要なMetadataが更新されることを確認する未Import／未実行候補である。
- 添付ガイドはWorkbook保存・終了・再オープンおよびWindows TEMPへの一時Evidence保存を記載するが、当地では実施しない。Current Approved Baseline BL-MVP-003、P2-04未完了、Formal MVP Test NOT RUN、`src`／Workbook／OFTを維持し、P2-04 PASS／COMPLETE、Baseline更新またはP2 Phase／CP-P2完了を行わない。

### v1.00 更新概要

- [P2-04 I07／I08 Continuous Retry Guide v0.1](<../03_verification/technical_validation/P2-04_I07_I08_Continuous_Retry_Guide_v0.1.md>)、[I07／I08 Harness v0.1.1候補](<../../tests/vba/P2_Scan_Sync/modP2_04I07I08RetryVerification_v0.1.1_CP932.bas>)、[I09 Warm Lifecycle Guide v0.1](<../03_verification/technical_validation/P2-04_I09_Warm_Lifecycle_Guide_v0.1.md>)、[I09 Harness v0.1候補](<../../tests/vba/P2_Scan_Sync/modP2_04I09WarmLifecycleVerification_v0.1_CP932.bas>)、[I10 Cold Lifecycle Guide v0.1](<../03_verification/technical_validation/P2-04_I10_Cold_Lifecycle_Guide_v0.1.md>)および[I10 Harness v0.1候補](<../../tests/vba/P2_Scan_Sync/modP2_04I10ColdLifecycleVerification_v0.1_CP932.bas>)を追加。I07／I08のApply FailureとFresh Retry、I09のWarm Lifecycle、I10のCold Lifecycleを確認する未Import／未実行候補である。
- I07／I08 HarnessにはWorksheet保護Fixture専用の固定テスト用パスワードが含まれる。実運用資格情報ではないことを確認した上で原文を保持するが、実行時のみのFixture用途とする。添付ガイドが記載するWorksheet保護・Status変更・Outlook起動／終了・OFT／Workbook操作、Import、CompileおよびVBA実行は当地で行わず、Current Approved Baseline BL-MVP-003、P2-04未完了、`src`／Workbook／OFTを維持する。

### v0.99 更新概要

- [P2-04 I06 Execution Preparation v0.1](<../03_verification/technical_validation/P2-04_I06_Execution_Preparation_v0.1.md>)および[I03～I06 Remaining Verification Harness v0.4候補](<../../tests/vba/P2_Scan_Sync/modP2_04RemainingVerification_v0.4_CP932.bas>)を追加。I06 BuildSyncDiff FailureでTemplate ScanとDefinition Readの成功後にApplySyncDiffへ進まず、`syncDiffResult = Nothing`、Fixture状態不変および復元後のOriginal状態を確認する未Import／未実行候補である。
- 準備書はv0.3.1と同一の`modP2_04RemainingVerification`を前提とする一方、添付v0.4の実際の`VB_Name`は`modP2_04RemainVerification`である。この内部名不一致はImport前に解決が必要であり、当地ではファイルを原文のまま保存し、v0.3.1を置換・削除せず、Workbook Import、CompileおよびVBA実行を行わない。Current Approved Baseline BL-MVP-003、P2-04未完了、`src`／Workbook／OFTを維持する。

### v0.98 更新概要

- [P2-04 I05 Execution Preparation v0.1](<../03_verification/technical_validation/P2-04_I05_Execution_Preparation_v0.1.md>)、[I03～I05 Remaining Verification Harness v0.3候補](<../../tests/vba/P2_Scan_Sync/modP2_04RemainingVerification_v0.3_CP932.bas>)および[v0.3.1補正候補](<../../tests/vba/P2_Scan_Sync/modP2_04RemainingVerification_v0.3.1_CP932.bas>)を追加。I05 Definition Read FailureでTemplate Scan後に後続Sync処理へ進まず、`syncDiffResult = Nothing`およびVariableDefinition不変を確認する未Import／未実行候補である。
- v0.3.1はI05-07を既存`GetAllVariableDefinitions`の失敗時Carrier契約（初期化済み空Collection）へ整合させる後続候補、v0.3は履歴として保持する。両者と既存v0.1／v0.2は同一`VB_Name`（`modP2_04RemainingVerification`）を持つため、同一Workbookへ二重Importしない。列名の一時変更・復元、Workbook Import、CompileおよびVBA実行は当地で行わず、Current Approved Baseline BL-MVP-003、P2-04未完了、`src`／Workbook／OFTを維持する。

### v0.97 更新概要

- [P2-04 I04 Execution Preparation v0.1](<../03_verification/technical_validation/P2-04_I04_Execution_Preparation_v0.1.md>)および[I03／I04 Remaining Verification Harness v0.2候補](<../../tests/vba/P2_Scan_Sync/modP2_04RemainingVerification_v0.2_CP932.bas>)を追加。OFT Missing時のFail Closed、`templateScanResult = Nothing`、`syncDiffResult = Nothing`、VariableDefinition不変および`Settings.TemplatePath`復元を確認する未Import／未実行候補である。
- v0.2候補と既存v0.1候補は同一の`VB_Name`（`modP2_04RemainingVerification`）を持つ。v0.2を後続候補、v0.1を履歴として保持し、同一Workbookへ二重Importしない。添付準備文書が記載するSettings一時変更、Workbook Import、CompileおよびVBA実行は当地で行わず、Current Approved Baseline BL-MVP-003、P2-04未完了、`src`／Workbook／OFTを維持する。

### v0.96 更新概要

- [P2-04 I03 Execution Preparation v0.1](<../03_verification/technical_validation/P2-04_I03_Execution_Preparation_v0.1.md>)および[I03 Remaining Verification Harness候補](<../../tests/vba/P2_Scan_Sync/modP2_04RemainingVerification_v0.1_CP932.bas>)を追加。Invalid Candidate時に`ExecuteManualSync`がFail Closedとなり、`templateScanResult`の公開、`syncDiffResult = Nothing`およびVariableDefinition不変を確認するための未Import／未実行候補である。
- 添付準備文書はOFTへの一時Fixture追加、WorkbookへのHarness Import、CompileおよびVBA実行を記載するが、当地ではこれらを実施しない。Current Approved Baseline BL-MVP-003、P2-04未完了、IF-P2-04-001の当地での未受入状態、`src`／Workbook／OFTを維持し、P2-04 PASS／COMPLETE、Baseline更新またはP2 Phase／CP-P2完了を行わない。

### v0.95 更新概要

- [Context Handoff_18](<../05_handoff/history/Context Handoff_18.md>)を過去時点の引継ぎとして保管。別環境におけるP2-02 v0.1.3／P2-03 v0.1.2の補正・検証、P2-04 Normal Local Verification、IF-P2-04-001 Closure、P2-04の残るI03～I12等の計画を記録する。
- 本記録は外部環境のBL-MVP-004と実行結果を含む履歴であり、当地のCurrent Approved Baseline BL-MVP-003、P2-04未完了、Formal MVP Test NOT RUNおよび`src`／Workbook／OFTを変更しない。当地のImport、Compile、VBA実行、IF-P2-04-001 Closure、P2-02／P2-03／P2-04 PASS／COMPLETE、P2 Phase／CP-P2完了またはBaseline更新の根拠にはしない。

### v0.94 更新概要

- [P2-04 Manual Sync Integration Completion Review v0.1](<reviews/P2-04 Manual Sync Integration Completion Review v0.1.md>)および[IF-P2-04-001 Closure Assessment / Closure Record v0.1](<reviews/IF-P2-04-001 Closure Assessment - Closure Record v0.1.md>)を外部実行・判断記録として追加。前者はP2-04をIN PROGRESS／NOT YET PASSとし、後者はIF-P2-04-001をRESOLVED／CLOSEDと記録する。
- 両記録はBL-MVP-004および外部環境のCompile／回帰／Local Verificationを前提とする。当地ではこれらを独立確認しておらず、Current Approved Baseline BL-MVP-003、IF-P2-04-001の当地での未受入状態、P2-04の未完了、`src`／Workbook／OFTを維持する。当地でのClosure、P2-04 PASS／COMPLETE、P2 Phase／CP-P2完了、Baseline更新、Import、Compileまたはテスト実行は行わない。

### v0.93 更新概要

- [P2-02→P2-03 Bootstrap Production Compatibility Guide](<../03_verification/technical_validation/P2-02_P2-03_Bootstrap_Production_Compatibility_Guide_v0.1.md>)および[Bootstrap Production Compatibility Test候補](<../../tests/vba/P2_Scan_Sync/modP2_02P2_03BootstrapProductionCompatibilityTest_v0.1_CP932.bas>)を追加。IF-P2-04-001で確認された下位層のBootstrap状態について、P2-02 v0.1.3とP2-03 v0.1.2を組み合わせて検証する未Import／未実行候補である。
- 添付ガイドはBL-MVP-004をExecution Baselineとして記載するが、当地ではBL-MVP-004を受入しておらず、Current Approved Baseline BL-MVP-003を維持する。当地でのWorkbook Import、VBA Compile、互換性テスト実行、P2-02／P2-03 PASS／COMPLETE、IF-P2-04-001 Closure、Baseline更新または既存`src`／Workbook／OFTの変更は行わない。

### v0.92 更新概要

- [P2-02 v0.1.3 Production候補](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.3_CP932.bas>)、[v0.1.2→v0.1.3未適用diff](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.2_to_v0.1.3.diff>)、[DateSerial Regression Test候補](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffDateSerialRegressionTest_v0.1_CP932.bas>)、[v0.1.3 Regression Suite候補](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffV013RegressionSuite_v0.1_CP932.bas>)および[DateSerial Regression Guide](<../03_verification/technical_validation/P2-02_v0.1.3_DateSerial_Regression_Guide_v0.1.md>)を追加。Excel `.Value2`で読み取るDate Serialを`TryGetMetadataDateValue`で受容するP2-02補正を対象とする未Import／未実行候補であり、既存v0.1～v0.1.2候補は履歴・比較用に保持する。
- 添付ガイドはBL-MVP-004をExecution Baselineとして記載するが、当地ではBL-MVP-004を受入しておらず、Current Approved Baseline BL-MVP-003を維持する。当地でのProduction Patch適用、Workbook Import、VBA Compile、Regression実行、P2-02 PASS／COMPLETE、Baseline更新または既存`src`／Workbook／OFTの変更は行わない。

### v0.91 更新概要

- [P2-03 v0.1.2 Production候補](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.2_CP932.bas>)および[P2-03 v0.1.2 Regression Review v0.1](<reviews/P2-03 v0.1.2 Regression Review v0.1.md>)を追加。添付ReviewはProduction系43/43 PASS、Compatibility K1 FAIL・K2/K3 PASSによりP2-03 v0.1.2をNOT COMPLETEと記録し、Failureを`ApplySyncDiff`到達前の`GetAllVariableDefinitions`→`BuildSyncDiff`と報告する。
- 当地では当該Production候補のWorkbook Import、VBA Compile、Regression／Compatibility実行および実行環境を独立確認していない。従って追加は当地のP2-03受入・PASS／COMPLETE、Current Approved Baseline BL-MVP-003の変更、Workbook／`src`／OFT変更またはP2 Phase／CP-P2完了を意味しない。

### v0.90 更新概要

- [P2-03 v0.1.2 Regression Execution Guide](<../03_verification/technical_validation/P2-03_v0.1.2_Regression_Execution_Guide_v0.1.md>)、[ValidateDiffItem最小修正定義](<../02_implementation/P2_Scan_Sync/P2-03_v0.1.2_ValidateDiffItem_Minimal_Correction.txt>)、[v0.1.1 fix1→v0.1.2未適用Patch](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.1_fix1_to_v0.1.2.patch>)、[Detection History Regression Test候補](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceDetectionHistoryRegressionTest_v0.1_CP932.bas>)および[v0.1.2 Regression Suite候補](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceV012RegressionSuite_v0.1_CP932.bas>)を追加。IF-P2-04-001のP2-03 Validation／Persistence補正を対象とする未適用／未実行記録であり、既存v0.1～v0.1.1 fix1候補は履歴・比較用に保持する。
- 添付ガイドはBL-MVP-004をExecution Baselineとして記載するが、当地ではBL-MVP-004を受入しておらず、Current Approved Baseline BL-MVP-003を維持する。当地でのProduction Patch適用、Workbook Import、VBA Compile、Regression実行、P2-03 PASS／COMPLETE、Baseline更新または既存`src`／Workbook／OFTの変更は行わない。

### v0.89 更新概要

- [P2-02 v0.1.2 Production Correction Regression Review v0.1](<reviews/P2-02 v0.1.2 Production Correction Regression Review v0.1.md>)を外部検証記録として追加。添付記録はBL-MVP-004上で`modSyncEngine_P2-02_v0.1.2_CP932.bas`のCompile PASS、Bootstrap／Detection History／Core／Negative／Compatibility合計102/102 PASS、FAIL 0を報告する。
- 当地では当該Production候補のWorkbook Import、VBA Compile、Regression実行および実行環境を独立確認していない。従って追加は当地のP2-02受入・PASS／COMPLETE、Current Approved Baseline BL-MVP-003の変更、Workbook／`src`／OFT変更またはP2 Phase／CP-P2完了を意味しない。

### v0.88 更新概要

- [P2-02 v0.1.2 Production候補](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.2_CP932.bas>)、[v0.1.1→v0.1.2未適用diff](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.1_to_v0.1.2.diff>)、[Detection History Regression Test候補](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffDetectionHistoryRegressionTest_v0.1_CP932.bas>)、[v0.1.2 Regression Suite候補](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffV012RegressionSuite_v0.1_CP932.bas>)および[Regression Execution Guide](<../03_verification/technical_validation/P2-02_v0.1.2_Regression_Execution_Guide_v0.1.md>)を追加。IF-P2-04-001のDetection History補正を対象とする未Import／未実行候補であり、既存v0.1およびv0.1.1候補は履歴・比較用に保持する。
- 添付ガイドはBL-MVP-004をExecution Baselineとして記載するが、当地ではBL-MVP-004を受入しておらず、Current Approved Baseline BL-MVP-003を維持する。当地でのWorkbook Import、VBA Compile、Regression実行、P2-02 PASS／COMPLETE、Baseline更新または既存`src`／Workbook／OFTの変更は行わない。

### v0.87 更新概要

- [Design v0.1.10 Candidate Patch](<../01_specifications/MVP Design v0.1.10 Candidate — IF-P2-04-001 Design Gap Resolution Patch.md>)、[Test Specification v0.1.6初期Candidate Patch](<../01_specifications/MVP Test Specification v0.1.6 Candidate - IF-P2-04-001 Test Definition Patch.md>)、[補正後Candidate Patch-2](<../01_specifications/MVP Test Specification v0.1.6 Candidate — IF-P2-04-001 Test Definition Patch-2.md>)、[Design／Test Consistency Review](<reviews/DOC-MVP-DES v0.1.10 Candidate × DOC-MVP-TESTSPEC v0.1.6 Candidate Cross-document Consistency Review v0.1.md>)および[BL-MVP-004 Approval Record](<baselines/BL-MVP-004_Approval_Record_v0.1.md>)を外部候補・承認記録として追加。初期Test CandidateはReview前の履歴、Patch-2はReviewの3件のCorrectionを反映する後続Candidateとして保持する。
- [DOC-MVP-IMPL v0.3／BL-MVP-004 Impact Review](<reviews/DOC-MVP-IMPL v0.3 - BL-MVP-004 Impact Review v0.1.md>)、[v0.4 Candidate Patch](<../02_implementation/DOC-MVP-IMPL v0.4 Candidate Patch.md>)および[v0.4 Consistency Review](<reviews/DOC-MVP-IMPL v0.4 Candidate - BL-MVP-004 Consistency Review v0.1.md>)を外部候補・レビュー記録として追加。
- 添付のBL-MVP-004 Approval RecordはBL-MVP-004 APPROVED、Design v0.1.10／Test Specification v0.1.6を報告するが、当地では候補文書・承認経路・P2成果物の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加は現行Design v0.1.9、Test Specification v0.1.5、Implementation Plan v0.3、Current Approved Baseline BL-MVP-003の置換、当地のBaseline受入、Production修正、Workbook Import、Compile、再検証またはP2 PASS／COMPLETEを意味しない。

### v0.86 更新概要

- [Context Handoff_17](<../05_handoff/history/Context Handoff_17.md>)を過去時点の引継ぎとして保管。別環境におけるP2-04 Local Verification、IF-P2-04-001の追加調査、およびP2-02／P2-03再Correction・P2-04検証再開の後続作業を記録する。
- 本文の別環境での検出結果・進捗・Next Actionは現行状態の根拠にしない。当地ではP2成果物の実行環境・Workbook／Module同期・実行結果を独立確認しておらず、Project OverviewとCurrent HandoffのCP-P1未確立・未受入状態を維持する。

### v0.85 更新概要

- [P2-03 VariableDefinition候補 v0.1.1 fix1](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.1_CP932_fix1.bas>)を追加。既存v0.1.1候補の`ValidateCurrentStateCollection`にある重複連結された`rowIndex`代入を単一代入へ修正する未Import候補であり、既存v0.1およびv0.1.1候補は履歴・比較用に保持する。
- 当地では修正版候補のWorkbook Import、VBA Compile、Regression実行およびP2-03 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。既存`src`、Workbook、OFTおよびBaselineは変更しない。

### v0.84 更新概要

- [P2-02 Sync Engine候補 v0.1.1](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1.1_CP932.bas>)、[P2-03 VariableDefinition候補 v0.1.1](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.1_CP932.bas>)、[P2-02 Bootstrap Regression Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffBootstrapRegressionTest_v0.1_CP932.bas>)および[P2-03 Bootstrap Regression Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceBootstrapRegressionTest_v0.1_CP932.bas>)を追加。IF-P2-04-001のBootstrap Metadata Regressionを対象とする後続候補であり、既存v0.1候補は履歴・比較用に保持する。
- 当地では4候補のWorkbook Import、VBA Compile、Regression実行およびP2-02／P2-03／P2-04 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。既存`src`、Workbook、OFTおよびBaselineは変更しない。

### v0.83 更新概要

- [IF-P2-04-001 Initial Sync Metadata Bootstrap Gap v0.1](<reviews/IF-P2-04-001 Initial Sync Metadata Bootstrap Gap v0.1.md>)、[Design Patch Definition v0.1](<reviews/IF-P2-04-001 Design Patch Definition v0.1.md>)および[Test Specification Impact v0.1](<reviews/IF-P2-04-001 Test Specification Impact v0.1.md>)を外部検出の影響・Patch候補記録として追加。FindingはInitial Sync Metadata Bootstrap GapをBlockingのDesign Gapとし、Design v0.1.10およびTest Specification v0.1.6をPatch Target Candidateとして提示する。
- これらは現行のDesign v0.1.9、Test Specification v0.1.5、Requirements、Implementation PlanおよびBL-MVP-003を改訂・承認・置換しない。当地では検出環境・P2-04実行結果・前提P2成果物を独立確認していないため、IF-P2-04-001の受入、Production修正、Workbook Import、Compile、再検証、P2-04 PASS／COMPLETEまたはBaseline更新を行わない。

### v0.82 更新概要

- [P2-04 Production Patch Design v0.1](<../02_implementation/P2_Scan_Sync/P2-04 Manual Sync Integration Production Patch Design v0.1.md>)、[P2-04 Production候補 v0.1](<../02_implementation/P2_Scan_Sync/modSyncApplication_P2-04_v0.1_CP932.bas>)および[P2-04 Integration Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_04ManualSyncIntegrationTest_v0.1_CP932.bas>)を条件付きで追加。Production候補は新規`modSyncApplication`、Test候補はPublic `ExecuteManualSync`を対象とするImplementation Verificationであり、いずれも未Importの記録である。
- 当地ではP2-04候補のWorkbook Import、VBA Compile、Integration Test実行およびP2-04 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。既存`src`、Workbook、OFTおよびBaselineは変更しない。

### v0.81 更新概要

- [P2-04 Manual Sync Integration 実施仕様 v0.1（Candidate）](<../02_implementation/P2_Scan_Sync/P2-04 Manual Sync Integration 実施仕様 v0.1 — Candidate.md>)および[Cross-document Consistency Review](<reviews/P2-04 Manual Sync Integration 実施仕様 v0.1 Cross-document Consistency Review.md>)を条件付き記録として追加。Reviewは1件のCorrection反映後にAPPROVED、Residual Conflict／Blocking Finding 0と記録する。
- CandidateおよびReviewはP2-01～03のPASS／COMPLETEとCP-P1 ESTABLISHEDを前提に含む。当地ではP2成果物の実行環境・Workbook／Module同期・実行結果を独立確認していないため、追加はP2-04の正式承認・実装・Workbook Import・Compile・検証・PASS／COMPLETE、当地のP2受入、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.80 更新概要

- [P2-04 Manual Sync Integration Boundary Confirmation v0.1](<../02_implementation/P2_Scan_Sync/P2-04 Manual Sync Integration Boundary Confirmation v0.1.md>)および[Cross-document Consistency Check v0.13](<reviews/P2-04 Manual Sync Integration Cross-document Consistency Check v0.13.md>)を条件付き記録として追加。前者は`modSyncApplication`によるManual Sync Application Orchestrationの責務境界、後者はBL-MVP-003およびP2-01～03との整合性をPASS with Non-blocking Clarification（Blocking Finding 0）と記録する。
- 両文書はP2-01～03のPASS／COMPLETEおよびCP-P1 ESTABLISHEDを前提に含むが、当地ではP2成果物の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加はP2-04実装・Workbook Import・Compile・検証・PASS／COMPLETE、当地のP2受入、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.79 更新概要

- [Context Handoff_16](<../05_handoff/history/Context Handoff_16.md>)を過去時点の引継ぎとして保管。P2-03の別環境での実装・検証・完了記録および次Unit P2-04 Boundary Confirmationの再開情報を含む。
- 本文のP2-03 PASS／COMPLETEおよびCP-P1 ESTABLISHEDは現行状態の根拠にしない。当地ではP2-03の実行環境・Workbook／Module同期・実行結果を独立確認しておらず、Project OverviewとCurrent HandoffのCP-P1未確立・未受入状態を維持する。

### v0.78 更新概要

- [P2-03 Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Completion Record v0.1.md>)、[Final Finding Assessment v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Final Finding Assessment v0.1.md>)および[Production Patch Review v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Production Patch Review v0.1.md>)を条件付き記録として追加。添付記録はCompile、Core C01～C12、Negative N01～N18、Compatibility K1～K3、P0 Read Regression、Static Review S01～S22を根拠にP2-03をPASS／COMPLETE、Active／Blocking Finding 0と報告する。
- 当地では記録の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加は当地のP2-03受入、CP-P1確立、P2 Phase／CP-P2完了、Workbook ImportまたはBaseline更新を意味しない。

### v0.77 更新概要

- [P2-03 Negative Verification Finding Assessment v0.1](<reviews/P2-03 Negative Verification Finding Assessment v0.1.md>)および[P2-03 Compatibility / Regression / Static Production Review v0.1](<reviews/P2-03 Compatibility - Regression - Static Production Review v0.1.md>)を条件付き記録として追加。添付記録はNegative N01～N18、Compatibility K1～K3、既存P0 Read Regression、Static Review S01～S22およびVBA CompileをPASS、Blocking Finding 0と報告する。
- 当地ではこれらのCompile・Negative・Compatibility・Regression・Static Review結果を独立確認していない。従って追加はP2-03 PASS／COMPLETE、Production候補のWorkbook Import、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.76 更新概要

- [P2-03 Negative Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceNegativeTest_v0.1_CP932.bas>)を追加。`ApplySyncDiff`のNothing入力、Structure／値域／Invariant／重複・行不整合、Table／ColumnおよびRuntime Write FailureをN01～N18で確認し、実行後にTable状態を復元する検証候補である。
- 当地ではWorkbook Import、VBA Compile、N01～N18の実行およびP2-03 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。Workbook・OFT・`src`・Baselineは変更しない。

### v0.75 更新概要

- [P2-03 VariableDefinition Sync Persistence Finding Assessment v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Finding Assessment v0.1.md>)を条件付き記録として追加。添付記録はVBA CompileおよびCore C01～C12をPASS、Production／Test Artifact／Requirement／DesignのActive Findingなし、Blocking Finding 0と報告し、OBS-P2-03-001を実装確認済みとする。
- 当地では当該Compile・Core実行・Table復元を独立確認していない。従って追加はP2-03 PASS／COMPLETE、Production候補のWorkbook Import、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.74 更新概要

- [P2-03 Production候補](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.bas>)および[P2-03 Core Test候補](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceCoreTest_v0.1_CP932.bas>)を追加。Production候補は既存`modVariableDefinitionData`を拡張する未Import候補、Test候補は`tblVariableDefinition`を復元するCore Verification用Moduleである。
- 当地では候補Module／TestのWorkbook Import、VBA Compile、実行およびP2-03 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。既存`src`、Workbook、OFTおよびBaselineは変更しない。

### v0.73 更新概要

- [P2-03 VariableDefinition Sync Persistence Production Patch Design v0.1](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Production Patch Design v0.1.md>)を条件付き記録として追加。既存`modVariableDefinitionData`を最小拡張し、既存Read APIを変更せず`ApplySyncDiff`とPrivate Persistence Helperを追加する設計を記録する。
- 本書のImplementation Readinessは添付記録上の評価であり、当地ではP2-03のProduction Module差分を受入・比較していない。従って追加は本番変更、Workbook Import、Compile、検証、PASS／COMPLETE、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.72 更新概要

- [P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1（Approved）](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 — Approved.md>)と[Cross-document Consistency Review v0.1](<reviews/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>)を条件付き記録として追加。Review結果はPASS WITH CORRECTIONSで、3件のCorrectionはApproved版へ全件反映済み、Blocking Finding／Requirement Gap／Design Conflictは0と記録されている。
- Approved化はP2-03のImplementation Detail確定記録であり、当地のP2-03実装・Workbook Import・Compile・検証・PASS／COMPLETE、P2-02受入、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.71 更新概要

- [P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1-Candidate](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1-Candidate.md>)を条件付きCandidate Artifactとして追加。`modVariableDefinitionData`へ`ApplySyncDiff`を追加し、P2-02のSyncDiffResultを再計算せずPreflight後にPersistenceするImplementation Detailを定義する。
- CandidateはReview／Approved化前であり、当地では前提P2-02の実行結果を独立確認していない。従って追加はP2-03実装、WorkbookへのImport、Compile、検証、PASS／COMPLETE、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.70 更新概要

- [P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1.md>)を条件付き記録として追加。P2-02のSyncDiffResultを再計算せず、`modVariableDefinitionData`の`ApplySyncDiff`でPreflight後にVariableDefinitionへPersistenceする責務境界を定義する。
- 本文はP2-02 PASS／COMPLETEを前提とするが、当地ではP2-02の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加はP2-03実装開始、P2-02受入、CP-P1確立、P2 Phase／CP-P2完了またはBaseline更新を意味しない。

### v0.69 更新概要

- [P2-02 Sync Diff Core Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Completion Record v0.1.md>)を条件付き記録として追加。添付記録はApproved Completion Criteria、VBA Compile、Core C1～C18、Negative N1～N6、P2-01／P0 Compatibility、Finding AssessmentおよびProduction Patch Reviewを根拠にP2-02をPASS／COMPLETEと報告する。
- 当地では記録の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加は当地のP2-02受入、CP-P1確立、P2 Phase完了、CP-P2確立またはBaseline更新を意味しない。
- [Context Handoff_15](<../05_handoff/history/Context Handoff_15.md>)を過去時点の引継ぎとして保管。本文のCP-P1 ESTABLISHED等は現行状態の根拠にせず、現在地はProject OverviewとCurrent Handoffを正本とする。

### v0.68 更新概要

- [P2-02 Sync Diff Core Production Patch Review v0.1](<reviews/P2-02 Sync Diff Core Production Patch Review v0.1.md>)を条件付き記録として追加。添付記録はApproved Specification §69 Static Review Checklist 23／23、VBA Compile、Core C1～C18、Negative N1～N6およびCompatibility K1～K2をPASS、Production Patch不要、Blocking Finding 0と報告する。
- 当地では当該Compile・検証結果を独立確認していない。従って追加はP2-02 PASS／COMPLETE、CP-P1確立、WorkbookへのImportまたはBaseline更新を意味しない。

### v0.67 更新概要

- [P2-02 Sync Diff Core Finding Assessment v0.1](<reviews/P2-02 Sync Diff Core Finding Assessment v0.1.md>)を条件付き記録として追加。添付記録はCore C1～C18、Negative N1～N6、Compatibility K1～K2をPASS、Blocking Finding 0と報告し、TF-P2-02-001をTest Artifact Defectとして扱う。
- 当地では当該実行結果を独立確認していない。従って追加はP2-02 PASS／COMPLETE、CP-P1確立またはBaseline更新を意味しない。

### v0.66 更新概要

- [TF-P2-02-001 Core Test Local Name Collision Correction v0.1](<../03_verification/technical_validation/TF-P2-02-001 Core Test Local Name Collision Correction v0.1.md>)と[P2-02 Core Test候補 v0.1.1](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas>)を追加。Test Artifact内のLocal VariableとFixture Function名の衝突を修正するもので、Production Module・Requirement・Design・Baselineは変更しない。
- v0.1.1を現行Core Test候補とし、v0.1は履歴として保持する。WorkbookへのImport、VBA Compile、Core再実行、P2-02 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。

### v0.65 更新概要

- [P2-02 Sync Diff Core Production候補](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1_CP932.bas>)、[Production Implementation Record v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Production Implementation Record v0.1.md>)、および[Core](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCoreTest_v0.1_CP932.bas>)／[Negative](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffNegativeTest_v0.1_CP932.bas>)／[Compatibility Test候補](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCompatibilityTest_v0.1_CP932.bas>)を追加。Production候補は新規modSyncEngineのみを追加する未ImportのCP932候補である。
- 実装記録はVBA Compile PendingおよびFormal MVP Test Not Executedとする。当地では候補Module／TestのWorkbook Import、VBA Compile、実行およびP2-02 PASS／COMPLETEは未実施であり、CP-P1未確立のため開始しない。

### v0.64 更新概要

- [P2-02 Sync Diff Core 実施仕様 v0.1（Approved）](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core 実施仕様 v0.1 Approved.md>)と[Cross-document Consistency Review v0.1](<reviews/P2-02 Sync Diff Core 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>)を条件付き記録として追加。Review結果はPASS WITH CORRECTIONSで、2件のCorrectionはApproved版へ反映済み、Semantic Conflict／Blocking FindingはNONEと記録されている。
- Approved化はImplementation Detailの確定記録であり、P2-01外部完了記録またはCP-P1の当地受入を意味しない。当地ではP2-02 Production実装、Compile、VerificationおよびPASS／COMPLETEを開始しない。

### v0.63 更新概要

- [P2-02 Sync Diff Core 実施仕様 v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core 実施仕様 v0.1.md>)を条件付きDraft Artifactとして追加。BuildSyncDiff Public API、SyncDiffResult、4分類、Canonical VariableName、Target MetadataおよびCore C1～C18をImplementation Detailとして定義する。
- 本文はP2-01 PASS／COMPLETEを前提とし、Cross-document Consistency Review Pendingである。当地ではP2-01外部記録およびCP-P1確立を独立確認していないため、Review、Approved化、Production実装、Compile、VerificationおよびP2-02 PASS／COMPLETEは開始しない。

### v0.62 更新概要

- [P2-02 Sync Diff Core Boundary Confirmation v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Boundary Confirmation v0.1.md>)を条件付き記録として追加。P2-01のFull TemplateScanResultとCurrent VariableDefinitionsをExcel非依存のCore Logicで比較し、New／Existing／Reactivated／Unusedを判定する境界と、P2-03 Persistenceとの責務分離を定義する。
- 本文はP2-01 PASS／COMPLETEを前提とするが、当地ではP2-01外部記録およびCP-P1確立を独立確認していない。従ってP2-02実装、Compile、VerificationおよびPASS／COMPLETEは開始しない。

### v0.61 更新概要

- [P2-01 Full Template Scanner Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner Completion Record v0.1.md>)を追加。添付記録は別環境のVBA Compile、Core C1～C11、Baseline OFT／MTS-SCAN-005 Integration、P1-04 RegressionおよびReviewを根拠に、P2-01をPASS／COMPLETEと報告している。
- 当地ではCompletion Recordの実行環境・Workbook／Module同期・実行結果を独立確認していない。従って本記録の追加はCP-P1確立、P2 Phase Exit、Baseline更新または当地のP2-01受入を意味しない。

### v0.60 更新概要

- [P2-01 Full Template Scanner Finding Assessment v0.1.1](<reviews/P2-01 Full Template Scanner Finding Assessment v0.1.1.md>)を追加し、v0.1の有効参照を置換。別環境でのTF-P2-01-001（MTS-SCAN-005 Test Pathの重複Separator）修正・再検証をRESOLVED／CLOSED、Production Code変更なしと記録している。
- [P2-01 Full Template Scanner Production Patch Review v0.1](<reviews/P2-01 Full Template Scanner Production Patch Review v0.1.md>)を追加。添付記録はP1-04との差分、Public APIおよび既存Contract維持をReview PASS、Blocking Finding 0と報告している。
- 当地では両記録の実行環境・Workbook／Module同期・実行結果を独立確認していない。従って追加・有効参照更新はP2-01 PASS／COMPLETE、CP-P1確立またはBaseline更新を意味しない。

### v0.59 更新概要

- [P2-01 Full Template Scanner Finding Assessment v0.1](<reviews/P2-01 Full Template Scanner Finding Assessment v0.1.md>)を追加。添付記録は、別環境でのCompile、Core C1～C11、Baseline OFT／MTS-SCAN-005 IntegrationおよびP1-04 RegressionをPASS、Blocking Finding 0と報告している。
- 当地ではその実行環境・Workbook／Module同期・実行結果を独立確認していない。従って本記録の追加はP2-01 PASS／COMPLETE、CP-P1確立またはBaseline更新を意味せず、OverviewのCP-P1未確立を維持する。

### v0.58 更新概要

- [P2-01 MTS-SCAN-005 Integration Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01MtsScan005IntegrationTest_v0.1_CP932.bas>)を追加。Test用OFTのSubject／BodyTextのみをScanner Inputとし、To／CC／BCCを除外する境界を確認する検証専用Moduleである。
- Moduleが参照するTest用OFTの存在は確認したが、WorkbookへのImport、VBA Compile、実行、P2-01 VerificationおよびPASS／COMPLETE判定は未実施。CP-P1未確立のためP2検証開始を許可しない。

### v0.57 更新概要

- [P2-01 Full Template Scanner Integration Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01FullTemplateScannerIntegrationTest_v0.1_CP932.bas>)を追加。Baseline OFTの相対パス解決、Subject／BodyText SnapshotおよびScanner統合を対象とする検証専用Moduleである。
- 当該Test候補のWorkbookへのImport、VBA Compile、Baseline OFT Integration実行、Core／Integration VerificationおよびP2-01 PASS／COMPLETEは未実施。CP-P1未確立のためP2検証開始を許可しない。

### v0.56 更新概要

- [P2-01 Full Template Scanner Core Test候補 v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01FullTemplateScannerCoreTest_v0.1_CP932.bas>)を追加。Approved仕様のC1～C11を対象とする検証専用Moduleであり、Production CodeへのTest専用Public API追加は行わない。
- 当該Test候補のWorkbookへのImport、VBA Compile、Core実行、Integration VerificationおよびP2-01 PASS／COMPLETEは未実施。CP-P1未確立のためP2検証開始を許可しない。

### v0.55 更新概要

- [P2-01 Full Template Scanner CP932候補 v0.1.1](<../02_implementation/P2_Scan_Sync/modTemplateScanner_P2-01_v0.1.1_CP932.bas>)を追加。P1-04の`ScanTemplate` Public APIを維持し、`Locations`をFull TemplateScanResultへ追加するProduction候補である。
- 候補Moduleの`src`／WorkbookへのImport・置換、VBA Compile、Core／Integration VerificationおよびP2-01 PASS／COMPLETEは未実施。CP-P1未確立のためP2実装開始を許可しない。

### v0.54 更新概要

- [P2-01 Full Template Scanner 実施仕様 v0.1（Approved）](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner 実施仕様 v0.1 Approved.md>)と[Cross-document Consistency Review v0.1](<reviews/P2-01 Full Template Scanner 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>)を登録。Review結果はPASS WITH CORRECTIONS、3件のCorrectionはApproved版へ反映済み、Semantic Conflict／Blocking FindingはNONE。
- Approved化はImplementation Detailの確定であり、Entry DependencyであるCP-P1の確立を意味しない。現行Project OverviewのCP-P1未確立が解消するまでP2-01 Production実装、Compile、VerificationおよびPASS／COMPLETEは開始しない。

### v0.53 更新概要

- [P2-01 Full Template Scanner 実施仕様 v0.1](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner 実施仕様 v0.1.md>)をDraft Artifactとして登録。P1-04 Scanner Contractを維持し、`Locations`を含むFull TemplateScanResultへ拡張するImplementation Detailを定義する。
- 本文はCP-P1 ESTABLISHEDを前提とするが、現行Project OverviewのCP-P1は未確立である。前提の整合を別途確認するまでConsistency Review、Approved化、Production実装、Compile、VerificationおよびP2-01 PASS／COMPLETEは開始しない。

### v0.52 更新概要

- [P2 Implementation Unit Decomposition Decision v0.1](<../02_implementation/P2_Scan_Sync/P2 Implementation Unit Decomposition Decision v0.1.md>)を登録。P2-01～P2-05の5 Unit分割と依存方向を定義する。
- 本文はP2-01 Entry ALLOWEDおよびCP-P1 ESTABLISHEDを前提とするが、現行Project OverviewのCP-P1は未確立である。前提の整合を別途確認するまで分割判断をP2実装開始の根拠とせず、Requirement／Design／Test Specification／Baselineへの変更は反映しない。

### v0.51 更新概要

- [P2 Scan / Sync Boundary Confirmation v0.1](<../02_implementation/P2_Scan_Sync/P2 Scan Sync Boundary Confirmation v0.1.md>)を登録。P1 Scanner Contract上のLocation統合、VariableDefinition Sync、Invalid Template No Updateの境界を定義する。
- 本文はCP-P1 ESTABLISHEDをEntry Dependencyとしているが、現行Project OverviewのCP-P1は未確立である。前提の整合を別途確認するまでP2実装開始を許可せず、Requirement／Design／Test Specification／Baselineへの変更は反映しない。

### v0.50 更新概要

- [P1-07 Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Completion Record v0.1.md>)、[Production Patch Review v0.1](<reviews/P1-07 Production Patch Review v0.1.md>)、[Finding Assessment v0.1](<reviews/P1-07 Finding Assessment v0.1.md>)および[LF-P1-07-001 Closure v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/LF-P1-07-001 Closure v0.1.md>)を登録し、P1-07をBL-MVP-003上でPASS／COMPLETEとして反映。
- v0.1.1 Correction後のVBA Compile、Warm／Cold E2E、Unresolved Fail Closed、再発確認およびP1-02 Warm／Cold RegressionはPASS。LF-P1-07-001はRESOLVED／CLOSED、Production Defect・Requirement／Design／Baseline変更はなし。当地の`src`／Workbook／OFTとの内容一致は別途確認する。

### v0.49 更新概要

- P1-07初回Verificationで確認された`LF-P1-07-001`（Outlook.Application stale reference／Error 462）について、[Correction v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/LF-P1-07-001 Outlook Application Stale Reference Correction v0.1.md>)、`modOutlookAdapter` v0.1.1 CP932候補、差分Patch、および[Correction Static Review v0.1](<reviews/LF-P1-07-001 Correction Static Review v0.1.md>)を追加。
- ClassificationはImplementation／Lifecycle Defect。Static ReviewはPASSだが、v0.1.1のWorkbook Import・VBA Compile・Warm／Cold／Unresolved再検証は未実施。Requirement／Design／Baseline変更およびTechnical Spike再開は不要。

### v0.48 更新概要

- [P1-07 Display E2E Verification手順書 v0.1](<../03_verification/technical_validation/P1-07 Display E2E Verification 手順書 v0.1.md>)と、[P1-07 Display E2E Integration Test v0.1 CP932](<../../tests/vba/P1_Walking_Skeleton/modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas>)を追加。Warm／Cold Start Normal E2EとUnresolved Fail Closedを、Formal MVP Testと区別したImplementation Verificationとして定義する。
- Test候補のWorkbook Import、VBA Compile、Classic Outlook Runtime／Regression Verification、およびP1-07 PASS／COMPLETEは未実施。手順書・Test候補は実行結果ではない。

### v0.47 更新概要

- [P1-07 Production実装手順 v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Production 実装手順 v0.1.md>)、`modMailApplication`／`modOutlookAdapter`のCP932候補、および[Production Static Review v0.1](<reviews/P1-07 Production Static Review v0.1.md>)を追加。Static ReviewはPASSで、Display Gate、No Send、Cleanup、Module名およびCP932 round-tripを確認している。
- 候補Moduleの`src`／WorkbookへのImport・置換、VBA Compile、Classic Outlook Runtime／Regression Verification、およびP1-07 PASS／COMPLETEは未実施。Static ReviewのPASSをRuntime Verificationとして扱わない。

### v0.46 更新概要

- [P1-07 Display / E2E Integration 実施仕様 v0.1（Approved）](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display E2E Integration 実施仕様 v0.1 Approved.md>)と[Cross-document Consistency Review v0.1](<reviews/P1-07 Display E2E Integration 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>)を登録。Review結果はPASS WITH CORRECTIONS、4件のCorrectionはApproved版へ反映済み、Blocking Finding／Semantic ConflictはNONE。
- Approved化はImplementation Detailの確定であり、Requirement／Design／Test Specification／BaselineへのSemantic Impactはない。Production実装、Compile、Implementation VerificationおよびP1-07 PASS／COMPLETEは未実施。

### v0.45 更新概要

- [P1-07 Display / E2E Integration 実施仕様 v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display E2E Integration 実施仕様 v0.1.md>)をDraft Artifactとして登録。Display Gate、Unresolved Fail Closed、Warm／Cold E2E VerificationのImplementation Detailを定義する。
- 本仕様はRequirement／Design／Test Specification／Baselineを変更しない。Consistency Review、Approved化、Production実装、Compile、Implementation VerificationおよびP1-07 PASS／COMPLETEは未実施。

### v0.44 更新概要

- [P1-07 Display / E2E Integration Boundary Confirmation v0.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display - E2E Integration Boundary Confirmation v0.1.md>)をDraft Artifactとして登録。P1-06までのProduction経路をDisplay Gateへ接続する責務境界を定義し、Requirement／Design／Test Specification／Baselineへの変更はない。
- P1-07のUnit Specification、Production実装、Compile、Implementation VerificationおよびPASS／COMPLETEは未実施。P6のError／Safety／Lifecycle最終化を先取りしない。

### v0.43 更新概要

- [P1-06 Minimal Unresolved Checker Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Completion Record v0.1.md>)、Production Patch Review v0.1（PASS）、Finding Assessment v0.1（PASS）を登録し、P1-06をBL-MVP-003上でPASS／COMPLETEとして反映。
- Completion RecordはVBA Compile、Core、Normal／Missing Value Integration、Scanner／Unresolved独立判定、P1-05 Major Regressionを含む。TF-P1-06-001はTest Artifact DefectとしてRESOLVED／CLOSED、Production Defect・Baseline変更はなし。当地の未同期`src`／Workbook／OFTとの内容一致は別途確認する。

### v0.42 更新概要

- [TF-P1-06-001 Integration Test Artifact Correction v0.1](<../03_verification/technical_validation/TF-P1-06-001 P1-06 Integration Test Artifact Correction v0.1.md>)と、[P1-06 Integration Test v0.1.1 CP932](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas>)を追加。
- 日本語Fixtureを`ChrW()`生成へ変更し、長さGuardを追加したTest Artifact Correctionである。Production Module・Requirement・Design・Test Specification・Baselineは変更しない。v0.1.1を現行候補とし、v0.1は履歴として保持する。Import・Compile・再実行・P1-06 PASS／COMPLETEは未実施である。

### v0.41 更新概要

- [TF-P1-06-001 Post-Render BodyText Diagnostic実行手順 v0.1](<../03_verification/technical_validation/TF-P1-06-001 Post-Render BodyText Diagnostic 実行手順 v0.1.md>)およびP1-05／P1-06 Integration診断VBAを追加。P1-05とP1-06のpost-render BodyText Length差を、Production変更なしでTest Harnessから切り分ける。
- TF-P1-06-001は診断実行待ちであり、Production Defect・仕様変更・Baseline変更・P1-06 PASS／COMPLETEを意味しない。診断VBAは正式Test Moduleを置換せず、同名`VB_Name`衝突なし。

### v0.40 更新概要

- P1-06 Production実装手順、`modUnresolvedChecker` CP932候補、Core Test、およびIntegration Testを追加。P1 Interim Error Mappingとして`RenderError`を使用するが、正式なUnresolved Error分類はP6で最終化する。
- 本候補は`src`／WorkbookへのImport、VBA Compile、Core／Integration実行、P1-06 PASS／COMPLETEを未実施とする。既存実行資産との`VB_Name`衝突は確認されず、同名Moduleを二重Importしない。

### v0.39 更新概要

- [P1-06 Minimal Unresolved Checker 実施仕様 v0.1](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker 実施仕様 v0.1.md>)をApproved Artifactとして登録し、[Consistency Review v0.1](<reviews/P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1.md>)を登録。
- Reviewの3件のCorrectionは反映済みで、最終判定はPASS／Blocking Findingなし。Requirement・Design・Test Specification・BaselineへのSemantic Impactはない。Production実装・Compile・検証・P1-06 PASS／COMPLETEは未実施である。DraftはGit履歴として保持する。

### v0.38 更新概要

- [P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Draft](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Draft.md>)を登録。Boundary Confirmationで確定したP1-06の責務を、`modUnresolvedChecker`のProduction実装可能なImplementation Detailへ展開した。
- DraftはBL-MVP-003への影響なし。Consistency Review・Approved化・Production実装・Compile・検証・P1-06 PASS／COMPLETEは未実施である。

### v0.37 更新概要

- [P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1.md>)を登録。Render後Subject／BodyText Snapshotを入力とするCOM非依存の`modUnresolvedChecker`境界をCONFIRMEDとした。
- 本確認はBL-MVP-003のRequirement／Design／Test Definitionを実装境界へ具体化するもので、Requirement・Design・Test Specification・Baselineへの影響およびTechnical Spike再開はない。P1-06実施仕様・Production実装・検証・PASS／COMPLETEは未実施である。

### v0.36 更新概要

- [P1-05 Minimal Render Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/P1-05 Minimal Render Completion Record v0.1.md>)、Production Patch Review v0.1（PASS）、Finding Assessment v0.1（NO BLOCKING FINDING）を登録し、P1-05をBL-MVP-003上でPASS／COMPLETEとして反映。
- Completion RecordはVBA Compile、Core／Warm／Cold Integration、Negative Verification N1～N5、P1-01～P1-04 Required Regressionを含む。TF-P1-05-001はTest Artifact Gapとして解消済み、N6 WordEditor FailureはP6へ計画的に保留・非ブロッキング。BL-MVP-003 Manifestは変更せず、当地の未同期`src`／Workbook／OFTとの内容一致は別途確認する。

### v0.35 更新概要

- P1-05 Minimal Render Negative Test v0.2 CP932を追加し、Integration Test v0.1に埋め込まれていた同名の簡易Negative Entry Pointを除去して、`TestP105MinimalRenderNegative`の実行対象を一意化した。
- v0.2はN1～N5のNegative Verificationを拡張する候補であり、Workbook Import・Compile・Runtime実行・P1-05 PASS／COMPLETEは未実施である。

### v0.34 更新概要

- P1-05 `modSubjectRenderer`／`modOutlookAdapter` Production候補、Minimal Render Core／Integration Test v0.1、およびProduction Patch Static Reviewを追加。Static ReviewはPASSで、Requirement／Design／Test Specification／Baselineへの影響はNONEである。
- 本候補は`src`／WorkbookへのImport・VBA Compile・Core／Integration／Negative Verification・P1-01～P1-04 Regression・P1-05 PASS／COMPLETEを未実施とする。Static ReviewのPASSはRuntime Verificationを意味しない。

### v0.33 更新概要

- P1-05 Minimal Render 実施仕様 v0.1へConsistency Reviewの必須Correction 3件と推奨Correction 1件の反映を確認し、Approved Artifactへ更新。Requirement／Design／Test Specification／Implementation Plan／BaselineへのSemantic Impactはない。
- P1-05はProduction Implementation EntryがREADYとなったが、`modSubjectRenderer`／`modOutlookAdapter`実装、Workbook／OFT受入、Compile、Smoke Test、P1-05 PASS／COMPLETEは未実施である。Draft本文はGit履歴に保持する。

### v0.32 更新概要

- P1-05 Minimal Render 実施仕様 v0.1 Consistency Review v0.1を登録。Review結果はPASS WITH CORRECTIONS、Blocking Findingなし、上位Requirement／Design／Test Specification／Baseline改訂不要である。
- Approval前に必須の局所Correction 3件（Project State記述の削除、Replacement Value内`{{...}}`意味論の未定義化、P1-04 InvalidCandidates前提のIntegration Smoke明記）と、推奨Correction 1件（P1基本COM Release Boundary明記）が未反映のため、P1-05はDraftを維持する。

### v0.31 更新概要

- P1-05 Minimal Render 実施仕様 v0.1をDraftのImplementation Unit Specificationとして登録。P1-03／P1-04で成立したSnapshot／Scanner境界を前提に、`modSubjectRenderer`と`modOutlookAdapter`による最小Render境界を定義する。
- Draft仕様の追加はProduction Module・Workbook・OFT・Smoke Testの追加、実装承認、P1-05 PASS／COMPLETE、Requirement／Design／Test Specification／Baselineの改訂を意味しない。

### v0.30 更新概要

- [P1-04 Minimal Template Scanner Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/P1-04 Minimal Template Scanner Completion Record v0.1.md>)、Production Patch Review v0.2（PASS）、Finding Assessment v0.1（PASS）および適用済みProject Control Update Patchを登録し、P1-04をBL-MVP-003上でPASS／COMPLETEとして反映。
- Completion RecordはCore／Integration Smoke、P1-03 Snapshot→Scanner Integrationおよび変更差分のRuntime Executionに基づくCompile Gateを含む。TF-P1-04-001はBaseline OFT Fixture Driftとして解消、TF-P1-04-002はWorkbook Artifactとして解消済み・非ブロッキング。BL-MVP-003 Manifestは変更せず、当地の未同期`src`／Workbookとの内容一致は別途確認する。

### v0.29 更新概要

- P1-04 `modTemplateScanner` Production候補、Minimal Template Scanner Smoke Test v0.1、およびProduction Implementation Static Reviewを追加。Static ReviewはPASSで、既存Production ModuleへのSemantic変更、Requirement／Design／Test Specification／Baselineへの影響はNONEである。
- 本候補は`src`／WorkbookへのImport・VBA Compile・Core Smoke・P1-03 Snapshot Integration・P1-04 PASS／COMPLETEを未実施とする。Static ReviewのPASSはRuntime Verificationを意味しない。

### v0.28 更新概要

- P1-04 Minimal Template Scanner 実施仕様 v0.1をApproved Artifactへ更新し、Consistency Review v0.1（PASS）を登録。Reviewの2件のConsistency CorrectionはRequirement／Design／Test Specification／BaselineのSemantic Changeを伴わない。
- P1-04はProduction Implementation EntryがREADYとなったが、`modTemplateScanner`実装、Workbook Import、Compile、Smoke Test、P1-04 PASS／COMPLETEは未実施である。Draft本文はGit履歴に保持する。

### v0.27 更新概要

- P1-04 Minimal Template Scanner 実施仕様 v0.1をDraftのImplementation Unit Specificationとして登録。P1-03で成立したSubject／BodyText Snapshotを入力に、`modTemplateScanner`で最小Scanner境界を実装する候補を定義する。
- Draft仕様の追加はProduction Module・Workbook・Smoke Testの追加、実装承認、P1-04 PASS／COMPLETE、Requirement／Design／Test Specification／Baselineの改訂を意味しない。

### v0.26 更新概要

- [P1-03 Template Snapshot Boundary Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/P1-03 Template Snapshot Boundary Completion Record v0.1.md>)、Production Patch Review v0.2（PASS）、Finding Assessment v0.1（PASS）および適用済みProject Control Update Patchを登録し、P1-03をBL-MVP-003上でPASS／COMPLETEとして反映。
- Completion Recordの実行結果はP1-03 Smoke、P1-02 Warm／Cold Regression、P1-01 Regressionおよび変更差分のRuntime Executionに基づくCompile Gateを含む。BL-MVP-003のManifestは変更しない。当地の未同期`src`／Workbookとの内容一致は別途確認する。

### v0.25 更新概要

- P1-03 `ReadSubject()` Production Patch候補、P1-03 Template Snapshot Smoke Test v0.1、およびProduction Patch Static Reviewを追加。Static ReviewはPASSで、既存`ReadBodyText()`・P1-02 Lifecycleを変更せず、Requirement／Design／Test Specification／Baselineへの影響はNONEである。
- 本候補はProduction適用・Workbook Import・VBA Compile・Runtime Smoke・P1-02／P1-01 Regressionを未実施とする。P1-03 PASS／COMPLETEの根拠にはならない。

### v0.24 更新概要

- P1-03 Template Snapshot Boundary 実施仕様 v0.1をApproved Artifactとして登録。Consistency ReviewはPASSで、Governance Correction 2件はCLOSED、Requirement／Design／Test Specification／BaselineへのSemantic ImpactはNONEである。
- P1-03はProduction Implementation EntryがREADYとなったが、Production実装・Workbook Import・Smoke／Regression Verification・P1-03 COMPLETEは未実施である。Review Candidate時点の本文はGit履歴に保持する。

### v0.23 更新概要

- P1-03 Template Snapshot Boundary 実施仕様 v0.1をReview Candidateとして追加。P1-02で成立した`ReadBodyText()`を再利用し、`ReadSubject()`とSubject／BodyText文字列Snapshot境界を次Unitの対象として定義する。
- 本仕様はRequirement／Design／Test Specification／Baselineの変更を伴わない候補であり、承認・Production実装・Workbook Import・Verification・P1-03 COMPLETEを意味しない。

### v0.22 更新概要

- [P1-02 Inspector WordEditor Connection Completion Record v0.1](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection Completion Record v0.1.md>)に基づき、P1-02をPASS／COMPLETEとしてProject Controlへ反映。VBA Compile、Warm／Cold Start Smoke、P1-01 Regression、Explorer／Draft／Inspector Lifecycleの各判定はPASSである。
- P1-02完了はExecution Evidenceであり、BL-MVP-003 Manifestを変更しない。当地の未同期`src`／WorkbookがCompletion Recordの実行環境と一致することは、この記録だけからは導出しない。

### v0.21 更新概要

- P1-02 Smoke Test v0.2.1a中間成果物、v0.2.2 CP932後継候補、およびInspector Lifecycle Correction Reviewを追加。TF-P1-02-003は、Cold Start中に一時的に存在するInspectorを残留と誤分類したSmoke Test Expected Result Defectであり、Production Change RequiredはNOである。
- `modP102InspectorWordEditorTest`の現行候補はv0.2.2とする。v0.2／v0.2.1aは履歴として保持するが、同一`VB_Name`のため同一Workbookへ二重Importしない。v0.2.2のImport・Compile・Warm／Cold Start再実行は未実施である。

### v0.20 更新概要

- P1-02 Smoke Test v0.2.1 Correction ReviewとCP932後継候補を追加。Cold StartのEvidence再取得失敗をProduction DefectではなくTest Defectとして扱い、Production Functional Path PASSとLifecycle Evidence BLOCKEDを分離する。
- `modP102InspectorWordEditorTest`の現行候補はv0.2.1とする。v0.2はGit履歴と既存ファイルで保持するが、同一`VB_Name`のためv0.2とv0.2.1を同一Workbookへ二重Importしない。Compile／実行は未実施である。

### v0.19 更新概要

- P1-02 Smoke Test v0.2 ReviewとCP932 Smoke Test候補を追加。Cold StartではHarnessがOutlookを先行起動しないこと、Warm／Cold Startを別Entry Pointで確認すること、P1-02 COMPLETEにはCompile・両Smoke・P1-01 Regressionが必要であることを記録する。
- 当該テスト候補のWorkbook Import・Compile・実行は未実施である。追加はProduction Patchの適用、Runtime Verification、P1-02 COMPLETEを意味しない。

### v0.18 更新概要

- `modOutlookAdapter` P1-02 v0.2 Cold Start Production Patchの候補一式（Patch／CP932モジュール）とStatic Reviewを追加。仕様整合・Public API互換性・Lifecycle／Error Modelの静的レビューはPASSである。
- 現行`src/modules/modOutlookAdapter_CP932.bas`は更新しない。Compile／Runtime VerificationはNOT RUNであり、候補一式の追加はProduction適用、Workbook Import、P1-02 COMPLETEを意味しない。

### v0.17 更新概要

- P1-02 Inspector WordEditor Connection 実施仕様 v0.2をApproved Artifactとして追加。BL-MVP-003、Cold Start Readiness、Explorer Lifecycle、Warm / Cold Start VerificationをUnit仕様へ反映する。
- v0.2 CandidateのConsistency ReviewはPASS。P1-02のProduction実装・実機Verification・Completion判定は、本仕様の承認だけでは完了しない。

### v0.16 更新概要

- DOC-MVP-IMPL v0.3をApproved Artifactとして最新存在版へ登録。Execution BaselineはBL-MVP-003である。
- v0.3 CandidateのPlan Consistency ReviewはPASS。BL-MVP-003に対するDOC-MVP-IMPL v0.2のAFFECTED / REVISION REQUIREDはv0.3により解消した。
- P1-02 Implementation Unit Specificationのv0.2改訂は別成果物として未受入であり、本Revisionに含めない。

### v0.15 更新概要

- BL-MVP-003 Baseline Approval Quality GateのPASSとApproval Recordに基づき、Current Approved BaselineをBL-MVP-003へ更新。BL-MVP-002はSupersededへ移行し、Historical BaselineとしてManifestを保持する。
- DOC-MVP-REQ v0.1.9、DOC-MVP-DES v0.1.9、DOC-MVP-TESTSPEC v0.1.5をBL-MVP-003のBaseline Versionへ採用。
- DOC-MVP-IMPL v0.2のBL-MVP-003 ImpactはAFFECTED / REVISION REQUIRED。Implementation PlanはBaseline Manifestへ追加せず、v0.3 Candidateの作成・整合性確認を後続作業とする。

### v0.14 更新概要

- DOC-MVP-REQ v0.1.9、DOC-MVP-DES v0.1.9、DOC-MVP-TESTSPEC v0.1.5をApproved Artifactとして最新存在版へ登録。3文書のCold Start Semantic Change整合性レビューはPASS。
- BL-MVP-003 Candidateを登録。Candidate Creation GateはPASSだが、Approvalは未実施のためCurrent Approved BaselineはBL-MVP-002を維持する。
- 既存Candidate版はレビュー時点の履歴として保持し、今回のApproved ArtifactやBaselineを置き換えるものではない。

### v0.13 更新概要

- DOC-MVP-TESTSPEC v0.1.5 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-TESTSPEC v0.1.4は維持する。
- v0.1.5はClassic Outlook Cold Start時のTest Variantを既存Test Caseへ反映するSemantic Test Definition Updateであり、Review / Not Yet BaselineのCandidateである。

### v0.12 更新概要

- DOC-MVP-DES v0.1.9 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-DES v0.1.8は維持する。
- v0.1.9はClassic Outlook Cold Start時のReadiness／Explorer初期化を定義するSemantic Design Changeであり、Review / Not Yet BaselineのCandidateである。Test Specificationへの反映と整合性確認は未完了。

### v0.11 更新概要

- DOC-MVP-REQ v0.1.9 Candidateを最新存在版として登録。Current Approved BaselineのDOC-MVP-REQ v0.1.8は維持する。
- v0.1.9はClassic Outlook Cold Start時の利用者向け挙動を確定するSemantic Changeであり、Review / Not Yet BaselineのCandidateである。

### v0.10 更新概要

- P1-02 Classic Outlook Cold Start Design / UX Impact Reviewを継続参照する影響レビューとして追加（Editorial / Governance Change）。
- レビューが示すRequirements／Design／Test Specificationの影響判定は、当該文書を改訂またはBaselineへ採用したことを意味しない。

### v0.9 更新概要

- TV-P1-02-001のResult RecordをTechnical Verification Result Recordとして参照に追加（Editorial / Governance Change）。
- Cold Start Technical VerificationのPASS / CLOSEDは当該記録の対象・時点に限定し、P1-02 OverallのNOT COMPLETE、Baseline Manifest、登録文書Revision・Statusは変更しない。

### v0.8 更新概要

- 管理フォルダ統合に伴い、共通ルールと台帳の現行リンクを更新（Editorial / Governance Change）。
- 共通ルールはプロジェクト内の単一ファイルとして保持。共通標準v0.1の本文・位置付けを維持。
- 登録文書Revision・Status、現行／過去Baseline Manifestは変更しない。

### v0.7 更新概要

- FS-05のEditorial / Governance Changeとして、文書の現行配置へのリンクを追加。
- 現在地・Next Actionを[Project Overview](Project_Overview.md)に集約。過去の実装・承認判断は元の記録を参照。
- 本文書の管理Revisionだけを更新。登録技術文書のRevision・Status、BL-MVP-002／BL-MVP-001のManifestと承認状態は変更しない。
- 改訂前v0.6はコミット `f310667:Docs/00_project_control/Document_Registry.md` から復元可能。過去進捗の全文コピーは追加しない。

### v0.6 更新概要（過去の記録）

- `DOC-MVP-IMPL v0.1 / BL-MVP-002 Impact Review v0.1` を実施し、`AFFECTED / REVISION REQUIRED` と判定
- Impact Reviewに基づき `Implementation Plan v0.2 Candidate` を最小差分で作成
- `Implementation Plan v0.2 Plan Consistency Review v0.1` を実施し、PASSと判定
- `DOC-MVP-IMPL v0.2` を正式Approved Artifactとして確定
- DOC-MVP-IMPLのLatest Versionを `v0.1 → v0.2` へ更新
- DOC-MVP-IMPLのExecution Baselineが `BL-MVP-002` と整合したことをProject Controlへ反映
- BL-MVP-002のManifest自体は変更なし
- BL-MVP-001はSupersededを維持
- Implementation Plan Impact ReviewをOpen ItemからCompletedへ変更
- P1-02開始前のBaseline / Plan Alignment Conflictを解消
- 次Actionを「新Workbook P0 Integration Regression（推奨）」→「P1-02 Inspector / WordEditor Connection」へ更新

---

## 2. Document Registry

| Document ID | Document | Latest Version | Status | Baseline Version | Role |
|---|---|---:|---|---:|---|
| DOC-MVP-REQ | [MVP Requirements v0.1.9](<../01_specifications/MVP Requirements v0.1.9 日本語版.md>) | v0.1.9 | Approved | v0.1.8 | Requirement |
| DOC-MVP-DES | [MVP Design v0.1.9](<../01_specifications/MVP Design v0.1.9 日本語版.md>) | v0.1.9 | Approved | v0.1.8 | Design |
| DOC-TS-A | [Technical Spike A 実施仕様書](../01_specifications/technical_spikes/Technical%20Spike%20A%20実施仕様書.md) | v0.4 | Closed | v0.4 | Technical Evidence |
| DOC-MVP-TESTSPEC | [MVP Test Specification v0.1.5](<../01_specifications/MVP Test Specification v0.1.5 日本語版.md>) | v0.1.5 | Approved | v0.1.4 | Test Definition |
| DOC-MVP-IMPL | [Implementation Plan v0.3](<../02_implementation/Implementation Plan v0.3 日本語版.md>) | v0.3 | Approved | — | Implementation Plan |

### Registry Rule

- `Latest Version` は存在する最新Revisionを示す。
- `Baseline Version` はCurrent Approved Baselineに採用されているRevisionを示す。
- Latest VersionとBaseline Versionは一致しなくてもよい。
- BL-MVP-003 Approvalにより、DOC-MVP-REQ v0.1.9 / DOC-MVP-DES v0.1.9 / DOC-TS-A v0.4 / DOC-MVP-TESTSPEC v0.1.5がCurrent Approved Baselineを構成する。
- Latest Approved Revisionが存在しても、Baseline Candidateの整合性確認とApprovalが完了するまではCurrent Approved Baselineへ自動採用しない。BL-MVP-003はこの条件を満たして承認済みである。
- DOC-MVP-IMPLはCurrent Approved Baseline Manifestの構成文書ではないため、Baseline Version欄は `—` を維持する。

---

## 3. Current Approved Baseline

```text
Baseline ID : BL-MVP-003
Status      : Approved
Approved On : 2026-09-19
```

### Baseline Manifest

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.9 | Approved |
| DOC-MVP-DES | v0.1.9 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.5 | Approved |

正式表現：

```text
BL-MVP-003
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.9
├─ DOC-MVP-DES      MVP Design v0.1.9
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.5
```

Approval Evidence：

[BL-MVP-003 Approval Record v0.1](baselines/BL-MVP-003_Approval_Record_v0.1.md)

Baseline Approval Quality Gate：

```text
Blocking Requirement Gap : NONE
Blocking Design Gap      : NONE
Blocking Test Gap        : NONE
Semantic Conflict        : NONE
Traceability Break       : NONE
Quality Gate             : PASS
```

---

## 4. Historical Baseline

### BL-MVP-002

```text
Baseline ID   : BL-MVP-002
Status        : Superseded
Approved On   : 2026-09-15
Superseded On : 2026-09-19
Superseded By : BL-MVP-003
```

Historical Manifest：

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.8 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.4 | Approved |

BL-MVP-002は削除・Invalidatedせず、BL-MVP-003承認前の正式Baselineとして保持する。

### BL-MVP-001

```text
Baseline ID   : BL-MVP-001
Status        : Superseded
Approved On   : 2026-09-12
Superseded By : BL-MVP-002
```

Historical Manifest：

| Document ID | Approved Version | Status |
|---|---:|---|
| DOC-MVP-REQ | v0.1.8 | Approved |
| DOC-MVP-DES | v0.1.7 | Approved |
| DOC-TS-A | v0.4 | Closed / PASS |
| DOC-MVP-TESTSPEC | v0.1.3 | Approved |

BL-MVP-001は削除・Invalidatedせず、過去時点の正式Baselineとして保持する。

---

## 5. 記録と現在地の参照

| 情報 | 正本・記録 |
| --- | --- |
| 現在地・未解決事項・次作業 | [Project Overview](Project_Overview.md) |
| セッション再開手順 | [Current Handoff](../05_handoff/Current_Handoff.md) |
| 共通運用標準v0.1 | [文書管理・Baseline運用ルール](<rules/AI協働開発 文書管理・Baseline運用ルール.md>) |
| DF-P1-001 Close | [Close Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/DF-P1-001 Close Record v0.1.md>) |
| P1-01完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/P1-01 OFT Path Outlook Connection Completion Record v0.1.md>) |
| TV-P1-001正式判定 | [技術検証記録](../03_verification/technical_validation/TV-P1-001_正式判定.md) |
| TV-P1-02-001結果記録 | [Technical Verification Result Record](<../03_verification/technical_validation/TV-P1-02-001 Result Record v0.1.md>) |
| P1-02 Cold Start影響レビュー | [Design / UX Impact Review](<reviews/P1-02 Classic Outlook Cold Start Design UX Impact Review v0.1.md>) |
| P1-02実施仕様v0.2 | [Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection 実施仕様 v0.2.md>) |
| P1-02実施仕様v0.2整合性 | [Consistency Review](<reviews/P1-02 Inspector WordEditor Connection 実施仕様 v0.2 Consistency Review v0.1.md>) |
| P1-02完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection Completion Record v0.1.md>) |
| P1-02完了Project Control更新 | [Applied Patch](<../90_archive/applied_patches/Project Control P1-02 Completion Update Patch v0.1.md>) |
| P1-03実施仕様v0.1 | [Approved Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/P1-03 Template Snapshot Boundary 実施仕様 v0.1.md>) |
| P1-03実施仕様v0.1整合性 | [Consistency Review](<reviews/P1-03 Template Snapshot Boundary 実施仕様 v0.1 Consistency Review v0.1.md>) |
| P1-03完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/P1-03 Template Snapshot Boundary Completion Record v0.1.md>) |
| P1-03 Production Patchレビュー | [Production Patch Review v0.2](<reviews/P1-03 Production Patch Review v0.2.md>) |
| P1-03 Finding判定 | [Finding Assessment](<reviews/P1-03 Finding Assessment v0.1.md>) |
| P1-03完了Project Control更新 | [Applied Patch](<../90_archive/applied_patches/Project Control P1-03 Completion Update Patch v0.1.md>) |
| P1-03 Production Patch候補 | [ReadSubject Patch](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/modOutlookAdapter_P1-03_ReadSubject.patch>) |
| P1-03 Smoke Test候補 | [CP932 Smoke Test](<../../tests/vba/P1_Walking_Skeleton/modP1_03TemplateSnapshotSmokeTest_v0.1_CP932.bas>) |
| P1-03 Production Patch静的レビュー | [Static Review](<reviews/P1-03 Production Patch Static Review v0.1.md>) |
| P1-04実施仕様v0.1 | [Approved Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/P1-04 Minimal Template Scanner 実施仕様 v0.1.md>) |
| P1-04実施仕様v0.1整合性 | [Consistency Review](<reviews/P1-04 Minimal Template Scanner 実施仕様 v0.1 Consistency Review v0.1.md>) |
| P1-04 Production候補 | [CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/modTemplateScanner_P1-04_v0.1_CP932.bas>) |
| P1-04 Smoke Test候補 | [CP932 Smoke Test](<../../tests/vba/P1_Walking_Skeleton/modP1_04MinimalTemplateScannerSmokeTest_v0.1_CP932.bas>) |
| P1-04 Production実装静的レビュー | [Static Review](<reviews/P1-04 Production Implementation Static Review v0.1.md>) |
| P1-04完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/P1-04 Minimal Template Scanner Completion Record v0.1.md>) |
| P1-04 Production Patchレビュー | [Production Patch Review v0.2](<reviews/P1-04 Production Patch Review v0.2.md>) |
| P1-04 Finding判定 | [Finding Assessment](<reviews/P1-04 Finding Assessment v0.1.md>) |
| P1-04完了Project Control更新 | [Applied Patch](<../90_archive/applied_patches/Project Control P1-04 Completion Update Patch v0.1.md>) |
| P1-05実施仕様v0.1 | [Approved Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/P1-05 Minimal Render 実施仕様 v0.1.md>) |
| P1-05実施仕様v0.1整合性 | [Consistency Review](<reviews/P1-05 Minimal Render 実施仕様 v0.1 Consistency Review v0.1.md>) |
| P1-05 Production候補 | [Subject Renderer CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/modSubjectRenderer_P1-05_v0.1_CP932.bas>)／[Outlook Adapter CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/modOutlookAdapter_P1-05_v0.1_CP932.bas>) |
| P1-05 Core Test候補 | [CP932 Core Test](<../../tests/vba/P1_Walking_Skeleton/modP1_05MinimalRenderCoreTest_v0.1_CP932.bas>) |
| P1-05 Integration Test候補 | [CP932 Integration Test](<../../tests/vba/P1_Walking_Skeleton/modP1_05MinimalRenderIntegrationTest_v0.1_CP932.bas>) |
| P1-05 Negative Test候補 | [CP932 Negative Test v0.2](<../../tests/vba/P1_Walking_Skeleton/modP1_05MinimalRenderNegativeTest_v0.2_CP932.bas>) |
| P1-05 Production Patch静的レビュー | [Static Review](<reviews/P1-05 Minimal Render Production Patch Static Review v0.1.md>) |
| P1-05完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/P1-05 Minimal Render Completion Record v0.1.md>) |
| P1-05 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P1-05 Minimal Render Production Patch Review v0.1.md>) |
| P1-05 Finding判定 | [Finding Assessment](<reviews/P1-05 Minimal Render Finding Assessment v0.1.md>) |
| P1-06実装境界確認v0.1 | [Confirmed Implementation Boundary](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1.md>) |
| P1-06実施仕様v0.1 | [Draft Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Draft.md>) |
| P1-06実施仕様v0.1（Approved） | [Approved Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker 実施仕様 v0.1.md>) |
| P1-06実施仕様v0.1整合性 | [Consistency Review](<reviews/P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1.md>) |
| P1-06 Production実装手順 | [Implementation Package](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Production 実装手順 v0.1.md>) |
| P1-06 Production候補 | [Unresolved Checker CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/modUnresolvedChecker_P1-06_v0.1_CP932.bas>) |
| P1-06 Core Test候補 | [CP932 Core Test](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerCoreTest_v0.1_CP932.bas>) |
| P1-06 Integration Test候補v0.1 | [CP932 Integration Test（履歴）](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1_CP932.bas>) |
| P1-06 Integration Test現行候補 | [CP932 Integration Test v0.1.1](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas>) |
| TF-P1-06-001診断手順 | [Post-Render BodyText Diagnostic](<../03_verification/technical_validation/TF-P1-06-001 Post-Render BodyText Diagnostic 実行手順 v0.1.md>) |
| TF-P1-06-001診断VBA | [P1-05 Integration Diagnostic](<../../tests/vba/P1_Walking_Skeleton/modP1_05MinimalRenderIntegrationDiag_v0.1_CP932.bas>)／[P1-06 Integration Diagnostic](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationDiag_v0.1_CP932.bas>) |
| TF-P1-06-001 Integration Test修正 | [Test Artifact Correction](<../03_verification/technical_validation/TF-P1-06-001 P1-06 Integration Test Artifact Correction v0.1.md>) |
| P1-06完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Completion Record v0.1.md>) |
| P1-06 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P1-06 Minimal Unresolved Checker Production Patch Review v0.1.md>) |
| P1-06 Finding判定 | [Finding Assessment](<reviews/P1-06 Minimal Unresolved Checker Finding Assessment v0.1.md>) |
| P1-07実装境界確認v0.1 | [Draft Implementation Boundary](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display - E2E Integration Boundary Confirmation v0.1.md>) |
| P1-07実施仕様v0.1 | [Draft Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display E2E Integration 実施仕様 v0.1.md>) |
| P1-07実施仕様v0.1（Approved） | [Approved Implementation Unit Specification](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Display E2E Integration 実施仕様 v0.1 Approved.md>) |
| P1-07実施仕様v0.1整合性 | [Cross-document Consistency Review](<reviews/P1-07 Display E2E Integration 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>) |
| P1-07 Production実装手順 | [Implementation Package](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Production 実装手順 v0.1.md>) |
| P1-07 Production候補 | [Mail Application CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/modMailApplication_P1-07_v0.1_CP932.bas>)／[Outlook Adapter CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/modOutlookAdapter_P1-07_v0.1_CP932.bas>) |
| P1-07 Production静的レビュー | [Static Review](<reviews/P1-07 Production Static Review v0.1.md>) |
| P1-07 Verification手順 | [Display E2E Verification手順書 v0.1](<../03_verification/technical_validation/P1-07 Display E2E Verification 手順書 v0.1.md>) |
| P1-07 Integration Test候補 | [CP932 Test Module](<../../tests/vba/P1_Walking_Skeleton/modP1_07DisplayE2EIntegrationTest_v0.1_CP932.bas>) |
| LF-P1-07-001 Lifecycle Correction | [Correction Record](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/LF-P1-07-001 Outlook Application Stale Reference Correction v0.1.md>) |
| LF-P1-07-001 Production候補 | [Outlook Adapter CP932 Module v0.1.1](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/modOutlookAdapter_P1-07_v0.1.1_CP932.bas>)／[Applied Diff Patch](<../90_archive/applied_patches/modOutlookAdapter_P1-07_v0.1_to_v0.1.1.patch>) |
| LF-P1-07-001静的レビュー | [Correction Static Review](<reviews/LF-P1-07-001 Correction Static Review v0.1.md>) |
| LF-P1-07-001 Closure | [Closure Record](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/LF-P1-07-001 Closure v0.1.md>) |
| P1-07完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-07_Display_E2E_Integration/P1-07 Completion Record v0.1.md>) |
| P1-07 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P1-07 Production Patch Review v0.1.md>) |
| P1-07 Finding判定 | [Finding Assessment](<reviews/P1-07 Finding Assessment v0.1.md>) |
| P2 Scan / Sync実装境界確認v0.1 | [Conditional Boundary Confirmation](<../02_implementation/P2_Scan_Sync/P2 Scan Sync Boundary Confirmation v0.1.md>) |
| P2 Implementation Unit分割判断v0.1 | [Conditional Decomposition Decision](<../02_implementation/P2_Scan_Sync/P2 Implementation Unit Decomposition Decision v0.1.md>) |
| P2-01 Full Template Scanner実施仕様v0.1 | [Conditional Draft Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner 実施仕様 v0.1.md>) |
| P2-01 Full Template Scanner実施仕様v0.1（Approved） | [Approved Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner 実施仕様 v0.1 Approved.md>) |
| P2-01 Full Template Scanner実施仕様v0.1整合性 | [Cross-document Consistency Review](<reviews/P2-01 Full Template Scanner 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>) |
| P2-01 Production候補 | [Template Scanner CP932 Module v0.1.1](<../02_implementation/P2_Scan_Sync/modTemplateScanner_P2-01_v0.1.1_CP932.bas>) |
| P2-01 Core Test候補 | [CP932 Core Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01FullTemplateScannerCoreTest_v0.1_CP932.bas>) |
| P2-01 Integration Test候補 | [CP932 Integration Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01FullTemplateScannerIntegrationTest_v0.1_CP932.bas>) |
| P2-01 MTS-SCAN-005 Integration Test候補 | [CP932 Boundary Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_01MtsScan005IntegrationTest_v0.1_CP932.bas>) |
| P2-01 Finding判定 | [Finding Assessment v0.1.1](<reviews/P2-01 Full Template Scanner Finding Assessment v0.1.1.md>) |
| P2-01 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P2-01 Full Template Scanner Production Patch Review v0.1.md>) |
| P2-01完了判定 | [Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-01 Full Template Scanner Completion Record v0.1.md>) |
| P2-02 Sync Diff Core実装境界確認v0.1 | [Conditional Boundary Confirmation](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Boundary Confirmation v0.1.md>) |
| P2-02 Sync Diff Core実施仕様v0.1 | [Conditional Draft Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core 実施仕様 v0.1.md>) |
| P2-02 Sync Diff Core実施仕様v0.1（Approved） | [Approved Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core 実施仕様 v0.1 Approved.md>) |
| P2-02 Sync Diff Core実施仕様v0.1整合性 | [Cross-document Consistency Review](<reviews/P2-02 Sync Diff Core 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>) |
| P2-02 Production候補 | [Sync Engine CP932 Module v0.1](<../02_implementation/P2_Scan_Sync/modSyncEngine_P2-02_v0.1_CP932.bas>) |
| P2-02 Production実装記録 | [Production Implementation Record v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Production Implementation Record v0.1.md>) |
| P2-02 Core Test候補v0.1 | [CP932 Core Test（履歴）](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCoreTest_v0.1_CP932.bas>) |
| P2-02 Core Test候補v0.1.1 | [CP932 Core Test（現行候補）](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas>) |
| TF-P2-02-001 Core Test修正 | [Test Artifact Correction](<../03_verification/technical_validation/TF-P2-02-001 Core Test Local Name Collision Correction v0.1.md>) |
| P2-02 Finding判定 | [Finding Assessment v0.1](<reviews/P2-02 Sync Diff Core Finding Assessment v0.1.md>) |
| P2-02 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P2-02 Sync Diff Core Production Patch Review v0.1.md>) |
| P2-02完了判定 | [Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-02 Sync Diff Core Completion Record v0.1.md>) |
| P2-03 VariableDefinition Sync Persistence実装境界確認v0.1 | [Conditional Boundary Confirmation](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Boundary Confirmation v0.1.md>) |
| P2-03 VariableDefinition Sync Persistence実施仕様v0.1 | [Conditional Candidate Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1-Candidate.md>) |
| P2-03 VariableDefinition Sync Persistence実施仕様v0.1（Approved） | [Approved Implementation Unit Specification](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 — Approved.md>) |
| P2-03 VariableDefinition Sync Persistence実施仕様v0.1整合性 | [Cross-document Consistency Review](<reviews/P2-03 VariableDefinition Sync Persistence 実施仕様 v0.1 Cross-document Consistency Review v0.1.md>) |
| P2-03 Production Patch設計 | [Production Patch Design v0.1](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Production Patch Design v0.1.md>) |
| P2-03 Production候補 | [VariableDefinition Data Module v0.1](<../02_implementation/P2_Scan_Sync/modVariableDefinitionData_P2-03_v0.1.bas>) |
| P2-03 Core Test候補 | [CP932 Core Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceCoreTest_v0.1_CP932.bas>) |
| P2-03 Finding判定 | [Finding Assessment v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Finding Assessment v0.1.md>) |
| P2-03 Negative Test候補 | [CP932 Negative Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_03SyncPersistenceNegativeTest_v0.1_CP932.bas>) |
| P2-03 Negative Finding判定 | [Negative Verification Finding Assessment v0.1](<reviews/P2-03 Negative Verification Finding Assessment v0.1.md>) |
| P2-03 Compatibility／Regression／Static Review | [Production Review v0.1](<reviews/P2-03 Compatibility - Regression - Static Production Review v0.1.md>) |
| P2-03 Final Finding判定 | [Final Finding Assessment v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Final Finding Assessment v0.1.md>) |
| P2-03 Production Patchレビュー | [Production Patch Review v0.1](<reviews/P2-03 VariableDefinition Sync Persistence Production Patch Review v0.1.md>) |
| P2-03完了判定 | [Completion Record v0.1](<../02_implementation/P2_Scan_Sync/P2-03 VariableDefinition Sync Persistence Completion Record v0.1.md>) |
| P2-02 Negative Test候補 | [CP932 Negative Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffNegativeTest_v0.1_CP932.bas>) |
| P2-02 Compatibility Test候補 | [CP932 Compatibility Test v0.1](<../../tests/vba/P2_Scan_Sync/modP2_02SyncDiffCompatibilityTest_v0.1_CP932.bas>) |
| P1-02 Cold Start Production Patch候補 | [Patch](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/modOutlookAdapter_P1-02_v0.2_ColdStart.patch>)／[CP932 Module](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/modOutlookAdapter_P1-02_v0.2_ColdStart_CP932.bas>) |
| P1-02 Cold Start Production Patch静的レビュー | [Patch Review](<reviews/modOutlookAdapter P1-02 v0.2 Cold Start Production Patch Review v0.1.md>) |
| P1-02 Smoke Test v0.2.2現行候補 | [CP932 Smoke Test](<../../tests/vba/P1_Walking_Skeleton/modP1_02InspectorWordEditorSmokeTest_v0.2.2_CP932.bas>) |
| P1-02 Smoke Test v0.2レビュー | [Smoke Test Review](<reviews/P1-02 Smoke Test v0.2 Review v0.1.md>) |
| P1-02 Smoke Test v0.2.1修正レビュー | [Correction Review](<reviews/P1-02 Smoke Test v0.2.1 Correction Review v0.1.md>) |
| P1-02 Smoke Test v0.2.1a中間成果物 | [CP932 Smoke Test](<../../tests/vba/P1_Walking_Skeleton/modP1_02InspectorWordEditorSmokeTest_v0.2.1a_CP932.bas>) |
| P1-02 Smoke Test v0.2.2 Inspector修正レビュー | [Inspector Lifecycle Correction Review](<reviews/P1-02 Smoke Test v0.2.2 Inspector Lifecycle Correction Review v0.1.md>) |
| Cold Start 3文書整合性 | [Cross-document Consistency Review](<reviews/Cold Start Semantic Change Cross-document Consistency Review v0.1.md>) |
| BL-MVP-003候補 | [Baseline Candidate](<baselines/BL-MVP-003 Candidate.md>) |
| BL-MVP-003承認記録 | [Baseline Approval Record](baselines/BL-MVP-003_Approval_Record_v0.1.md) |
| BL-MVP-003のImplementation影響 | [Impact Review](<reviews/DOC-MVP-IMPL v0.2 BL-MVP-003 Impact Review v0.1.md>) |
| Implementation Plan v0.3整合性 | [Plan Consistency Review](<reviews/Implementation Plan v0.3 Plan Consistency Review v0.1.md>) |
| Design／Test整合性 | [Cross-document Review](<reviews/MVP Design v0.1.8 × MVP Test Specification v0.1.4 Cross-document Consistency Review.md>) |
| Implementation Plan Impact | [Impact Review](<reviews/DOC-MVP-IMPL v0.1 BL-MVP-002 Impact Review v0.1.md>) |
| Implementation Plan整合性 | [Plan Consistency Review](<reviews/Implementation Plan v0.2 Plan Consistency Review v0.1.md>) |
| フォルダ移行の履歴 | [移動台帳](Folder_Structure_Migration_Inventory_v0.1.md) |

各記録のPASSは当該記録の対象・時点に適用される。現在のWorkbookのCompile／Regression判定は、本RegistryのBaseline承認からは導出しない。
