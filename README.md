# 定型メール作成ツール

Excel VBAとClassic Outlookを使用する定型メール作成ツールです。実行ブックは[MailGeneratorNew.xlsm](MailGeneratorNew.xlsm)です。

## 読む順序と正本

1. [Project Overview](Docs/00_project_control/Project_Overview.md)：現在地、確認済み事項、未解決事項、次の作業。
2. [Document Registry](Docs/00_project_control/Document_Registry.md)：技術文書へのリンクと承認済みBaselineのRevision構成。
3. [Current Handoff](Docs/05_handoff/Current_Handoff.md)：セッション再開の手順。

[文書管理・Baseline運用ルールv0.1](<Docs/01_Project_Control/Rules/AI協働開発 文書管理・Baseline運用ルール.md>)は全プロジェクト共通標準として暫定的に既存位置で参照します。詳細な仕様はRegistryから辿り、READMEには複製しません。

## 保存場所

| 保存物 | 場所 |
| --- | --- |
| 実行本体 | [MailGeneratorNew.xlsm](MailGeneratorNew.xlsm) |
| OFT | [通常テンプレート](Templates/MailTemplate.oft)、[MTS-SCAN-005用](Templates/MailTemplate_MTS-SCAN-005.oft) |
| エクスポート本番ソース | [標準モジュール](src/modules/)、[クラス](src/classes/) |
| テスト | [P0](tests/vba/P0_Foundation/)、[P1](tests/vba/P1_Walking_Skeleton/) |
| 既存Technical Spike検証コード | [Technical Spike A](<tests/vba/technical_spikes/Technical Spike A VBAコード.txt>)（本文・txt形式を維持。自動実行対象外） |
| 仕様 | [仕様書](Docs/01_specifications/) |
| 実装判断・完了記録 | [実装文書](Docs/02_implementation/) |
| 検証判定 | [検証記録](Docs/03_verification/) |
| 引継ぎ履歴 | [history](Docs/05_handoff/history/) |
| 旧版・適用済みPatch | [Archive](Docs/90_archive/) |

生ログ・画面・検証出力の保存先はルートの`Evidence/`です。現在は空でGit追跡されていないため、別チェックアウトでは必要時に作成します。`Docs`・`Evidence`の大文字表記と共通ルール・台帳の旧階層は、記録済みの保持例外です。

## 実行環境とWorkbookの扱い

Windows上のExcel Desktop（VBA）とClassic Outlookを前提とします。Web版Excel／新しいOutlookは、この実装の確認対象ではありません。

Workbookを開く際はルートの`MailGeneratorNew.xlsm`を使用し、Settingsの`TemplatePath = Templates\MailTemplate.oft`とWorkbook／Templatesの相対関係を維持します。具体的な操作は[Implementation Plan](Docs/02_implementation/Implementation_Plan.md)と対象Unit仕様を参照します。追加Workbookの現在のUI操作手順・実機動作は未検証です。

**別PCでP2対応中で、当地にはWorkbookとOFTだけがコピーされています。** 更新文書・Modulesは未反映です。現在のsrcだけでWorkbook全体を再構築できるとは扱わず、既存Workbookへの一括Import・上書きは行わないでください。別PC成果物の受入・照合はフォルダ移行と別作業として扱います。現在地の詳細はProject Overviewを参照してください。

## 検証の入口

Compile／Smoke Testは、対象WorkbookとImportするソースの対応を確認した検証用コピーで実施します。本番クラス2件・標準モジュール5件はsrc、テストはtestsを参照します。Archive内の旧版はImport対象外です。CP932のソースは文字コードと内部`VB_Name`を保持し、同名モジュールを二重Importしないでください。

| 確認内容 | 現行ファイル／入口 |
| --- | --- |
| P0統合 | [v0.2](tests/vba/P0_Foundation/modP0FoundationIntegrationSmokeTest_v0.2_CP932.bas)／`TestP0FoundationIntegration` |
| 相対パス解決 | [Resolver Smoke Test](tests/vba/P1_Walking_Skeleton/modResolveWorkbookRelativePathSmokeTest.bas)／`TestResolveWorkbookRelativePath` |
| P1 OFT接続 | [OFT Smoke Test](tests/vba/P1_Walking_Skeleton/modP1OftConnectionSmokeTest_v0.1_CP932.bas)／`TestP1OftConnection` |
| OneDrive技術検証 | [TV-P1-001モジュール](tests/vba/P1_Walking_Skeleton/modP1OneDrivePathVerification_CP932.bas)／`TestOneDriveLocalPathResolution` |

P0統合では保存済みWorkbook、Settings／tblSettingsのTemplatePath、VariableDefinition／tblVariableDefinitionの読取可能行とActive行、OptionMaster／tblOptionMasterの`__SmokeTestGroup__`のActive行2件以上が前提です。P0-03 Settings v0.2はローカルパス前提のAssertionを含み、OneDrive Web URL環境でのPASSを保証しません。TV-P1-001はOneDrive Web URLの再現環境専用です。

実施時はVBEのCompileと対象テストの出力をそれぞれ記録し、対象Workbook・コミット・環境を紐付けます。ログ等はEvidence、判定文書はDocs/03_verificationへ配置します。実装検証とFormal MVP Testを区別します。今回のフォルダ整理では実機テストを実行していません。

フォルダ整備は2026-10-11にPASS／CLOSEDとしました。完了記録・移動履歴・復元元コミットは[移動台帳](Docs/01_Project_Control/Folder_Structure_Migration_Inventory_v0.1.md)第17節を参照してください。別PC成果物の同期と実機検証は後続の別作業です。
