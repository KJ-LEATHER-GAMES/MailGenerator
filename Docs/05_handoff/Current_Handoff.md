# Current Handoff

Revision: v0.3 / 更新日: 2026-10-11

この文書は再開手順を管理する。現在地・Next Action・未解決事項の正本は[Project Overview](../00_project_control/Project_Overview.md)、正式な文書Revision構成は[Document Registry](../00_project_control/Document_Registry.md)である。

## Read First

1. [Project Overview](../00_project_control/Project_Overview.md)で現在地と保留条件を確認する。
2. [移動台帳](../01_Project_Control/Folder_Structure_Migration_Inventory_v0.1.md)の第13～16節で直近の検証範囲を確認する。
3. [README](../../README.md)から対象資産とテストの入口を確認する。仕様が必要ならRegistryから対象文書へ進む。

## 再開手順

- `git status --short`と最新コミットを確認し、未コミットのユーザー変更を保持する。
- FS-06の静的検証とD-07の配置は完了。別PC成果物受入・実機検証の順序と完了条件はOverviewのNext Actionを使用する。
- 別PCでP2対応中であり、当地にはWorkbook／OFTだけがコピーされている。未反映のModules・文書をWorkbookから推測で再生成せず、別PCから受け入れる範囲・時点を確認する。
- [history](history/)の01～08は過去記録。特に08をそのまま現在の進捗や現WorkbookのPASS結果として扱わない。
- FS-05で移動したファイルはない。旧Current.mdはOverviewへの統合後に削除し、Gitで履歴を保持した。復元情報は移動台帳第14節を参照する。

本Handoffの作成は、追加Workbookのソース同期・Compile・回帰テスト・Baseline更新の完了を意味しない。
