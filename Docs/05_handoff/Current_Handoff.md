# Current Handoff

Revision: v0.7 / 更新日: 2026-10-11

この文書は再開手順を管理する。現在地・Next Action・未解決事項の正本は[Project Overview](../00_project_control/Project_Overview.md)、正式な文書Revision構成は[Document Registry](../00_project_control/Document_Registry.md)である。

## Read First

1. [Project Overview](../00_project_control/Project_Overview.md)で現在地と保留条件を確認する。
2. [移動台帳](../00_project_control/Folder_Structure_Migration_Inventory_v0.1.md)の第17・18節でフォルダ整備の完了範囲・保持例外・管理フォルダ統合・後続作業を確認する。詳細検証は第13～16節を参照する。
3. [README](../../README.md)から対象資産とテストの入口を確認する。仕様が必要ならRegistryから対象文書へ進む。

## 再開手順

- `git status --short`と最新コミットを確認し、未コミットのユーザー変更を保持する。
- フォルダ整備はPASS／CLOSED。FS-00～06とD-07配置を完了として扱い、過去の保留記録を根拠に再開しない。別PC成果物受入・実機検証は後続の別作業であり、順序と完了条件はOverviewのNext Actionを使用する。
- P1-02は[Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection Completion Record v0.1.md>)でPASS／COMPLETE。Completion Recordの実行環境と当地の未同期`src`／Workbookを同一視せず、同期時はOverviewの受入条件に従う。
- 別PCでP2対応中であり、当地にはWorkbook／OFTだけがコピーされている。未反映のModules・文書をWorkbookから推測で再生成せず、別PCから受け入れる範囲・時点を確認する。
- [history](history/)の01～09は過去記録。09はP1-02完了までの経緯と実行証跡の要約であり、現在地はOverviewとCompletion Recordを正本として確認する。特に08をそのまま現在の進捗や現WorkbookのPASS結果として扱わない。
- FS-05で移動したファイルはない。旧Current.mdはOverviewへの統合後に削除し、Gitで履歴を保持した。復元情報は移動台帳第14節を参照する。

本Handoffの作成は、追加Workbookのソース同期・Compile・回帰テスト・Baseline更新の完了を意味しない。

管理文書はDocs/00_project_controlへ統合済み。旧01_Project_Controlを再作成せず、共通ルールは同配下のrules、移動台帳は同配下のファイルを参照する。過去の移動元・Git復元パスは当時の記録として読む。
