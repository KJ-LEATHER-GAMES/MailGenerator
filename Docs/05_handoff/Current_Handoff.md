# Current Handoff

Revision: v0.27 / 更新日: 2026-10-12

この文書は再開手順を管理する。現在地・Next Action・未解決事項の正本は[Project Overview](../00_project_control/Project_Overview.md)、正式な文書Revision構成は[Document Registry](../00_project_control/Document_Registry.md)である。

## Read First

1. [Project Overview](../00_project_control/Project_Overview.md)で現在地と保留条件を確認する。
2. [移動台帳](../00_project_control/Folder_Structure_Migration_Inventory_v0.1.md)の第17・18節でフォルダ整備の完了範囲・保持例外・管理フォルダ統合・後続作業を確認する。詳細検証は第13～16節を参照する。
3. [README](../../README.md)から対象資産とテストの入口を確認する。仕様が必要ならRegistryから対象文書へ進む。

## 再開手順

- `git status --short`と最新コミットを確認し、未コミットのユーザー変更を保持する。
- フォルダ整備はPASS／CLOSED。FS-00～06とD-07配置を完了として扱い、過去の保留記録を根拠に再開しない。別PC成果物受入・実機検証は後続の別作業であり、順序と完了条件はOverviewのNext Actionを使用する。
- P1-02は[Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection Completion Record v0.1.md>)でPASS／COMPLETE。Completion Recordの実行環境と当地の未同期`src`／Workbookを同一視せず、同期時はOverviewの受入条件に従う。
- P1-03は[Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/P1-03 Template Snapshot Boundary Completion Record v0.1.md>)によりPASS／COMPLETE。[Production Patch Review v0.2](<../00_project_control/reviews/P1-03 Production Patch Review v0.2.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<../00_project_control/reviews/P1-03 Finding Assessment v0.1.md>)はBlocking Findingなしと判定。ただしCP-P1は未確立で、Completion Recordの実行環境と当地の未同期`src`／Workbookを同一視しない。
- P1-04は[Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/P1-04 Minimal Template Scanner Completion Record v0.1.md>)によりPASS／COMPLETE。[Production Patch Review v0.2](<../00_project_control/reviews/P1-04 Production Patch Review v0.2.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<../00_project_control/reviews/P1-04 Finding Assessment v0.1.md>)はBlocking Findingなしと判定。TF-P1-04-001はOFT Fixture Driftとして解消、TF-P1-04-002はWorkbook Artifactとして解消済み・非ブロッキング。ただしCP-P1は未確立で、Completion Recordの実行環境と当地の未同期`src`／Workbook／OFTを同一視しない。
- P1-05は[Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/P1-05 Minimal Render Completion Record v0.1.md>)によりPASS／COMPLETE。[Production Patch Review v0.1](<../00_project_control/reviews/P1-05 Minimal Render Production Patch Review v0.1.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<../00_project_control/reviews/P1-05 Minimal Render Finding Assessment v0.1.md>)はBlocking Findingなしと判定。TF-P1-05-001はNegative Verification Coverage Gapとして解消済み・非ブロッキング。N6 WordEditor FailureはP6へ計画的に保留・非ブロッキング。ただしCP-P1は未確立で、Completion Recordの実行環境と当地の未同期`src`／Workbook／OFTを同一視しない。
- P1-06は[Boundary Confirmation v0.1](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Boundary Confirmation v0.1.md>)でCONFIRMED。[実施仕様v0.1](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker 実施仕様 v0.1.md>)はApproved。[Consistency Review v0.1](<../00_project_control/reviews/P1-06 Minimal Unresolved Checker 実施仕様 v0.1 Consistency Review v0.1.md>)のCorrection 3件は反映済みで、最終PASS／Blocking Findingなし。Render後Subject／BodyText Snapshotを入力とするCOM非依存の`modUnresolvedChecker` Core Logicとして、未置換TokenのCase Insensitive統合・Fail Closed可能なResultまでを責務とする。Requirement・Design・Test Specification・Baselineへの影響はない。Production実装・検証・PASS／COMPLETEは未実施であり、Approved仕様だけを根拠に`src`／Workbookへ実装・Importしない。
- P1-06の[実装手順](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Production 実装手順 v0.1.md>)、[Production候補](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/modUnresolvedChecker_P1-06_v0.1_CP932.bas>)、[Core Test](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerCoreTest_v0.1_CP932.bas>)、[Integration Test](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1_CP932.bas>)を追加。`RenderError`はP1 Interim Mappingであり、正式なUnresolved Error分類はP6へ残す。既存`src`との`VB_Name`衝突は確認されなかったが、今回Import・Compile・実行はしていない。同名Moduleを二重Importせず、Production候補だけを根拠に`src`／Workbookへ適用しない。
- TF-P1-06-001として、[Post-Render BodyText診断手順](<../03_verification/technical_validation/TF-P1-06-001 Post-Render BodyText Diagnostic 実行手順 v0.1.md>)と、[P1-05診断VBA](<../../tests/vba/P1_Walking_Skeleton/modP1_05MinimalRenderIntegrationDiag_v0.1_CP932.bas>)、[P1-06診断VBA](<../../tests/vba/P1_Walking_Skeleton/modP1_06MinimalUnresolvedCheckerIntegrationDiag_v0.1_CP932.bas>)を追加。P1-05／P1-06のpost-render BodyText Length差をTest Harnessから切り分ける診断であり、Production Moduleおよび正式Test Moduleは変更・置換しない。診断はNOT RUNで、Evidence確認前にProduction Defect・仕様／Baseline変更を判断しない。
- 別PCでP2対応中であり、当地にはWorkbook／OFTだけがコピーされている。未反映のModules・文書をWorkbookから推測で再生成せず、別PCから受け入れる範囲・時点を確認する。
- [history](history/)の01～11は過去記録。11はP1-05完了・関連Finding・P1-06検討開始時点の再開用スナップショットであり、現在地はOverviewとCompletion Recordを正本として確認する。特に08をそのまま現在の進捗や現WorkbookのPASS結果として扱わない。
- FS-05で移動したファイルはない。旧Current.mdはOverviewへの統合後に削除し、Gitで履歴を保持した。復元情報は移動台帳第14節を参照する。

本Handoffの作成は、追加Workbookのソース同期・Compile・回帰テスト・Baseline更新の完了を意味しない。

管理文書はDocs/00_project_controlへ統合済み。旧01_Project_Controlを再作成せず、共通ルールは同配下のrules、移動台帳は同配下のファイルを参照する。過去の移動元・Git復元パスは当時の記録として読む。
