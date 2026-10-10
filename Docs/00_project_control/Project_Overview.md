# Project Overview

| 項目 | 内容 |
| --- | --- |
| Revision | v0.3 |
| 更新日 | 2026-10-11 |
| 文書の責務 | 現在地・未解決事項・次作業の正本 |
| Current Phase / Focus | 開発：別PCでP2対応中（2026-10-11ユーザー確認）。当地：FS-06静的検証完了 |
| Project Status | 承認済みの配置変更・静的検証は完了。実機検証は保留。P2詳細進捗と実行コードCheckpointは当地未反映 |
| Current Approved Baseline | BL-MVP-002。版構成・承認証跡は[Registry](Document_Registry.md)を参照 |
| 実行資産 | [MailGeneratorNew.xlsm](../../MailGeneratorNew.xlsm)と[Templates](../../Templates/) |

## 確認した状態と根拠

| 対象 | 確認済みの事実 | 意味・制限 |
| --- | --- | --- |
| フォルダ移行 | [移動台帳](../01_Project_Control/Folder_Structure_Migration_Inventory_v0.1.md)第9～15節にFS-01～06を記録 | 静的検証PASS。実機動作やコード同期の完了を意味しない |
| P0 | 過去Current.mdにCP-P0確立・P0-06 PASSの記録。原本は`f310667:Docs/01_Project_Control/Reviews/CurrentPosition/Current.md` | BL-MVP-001時点の記録。今回のWorkbookの判定には転用しない |
| P1-01／DF-P1-001 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/P1-01 OFT Path Outlook Connection Completion Record v0.1.md>)、[Close Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/DF-P1-001 Close Record v0.1.md>)に完了・Closeを記録 | 旧Current.mdのOneDrive課題を新たな未解決課題として登録しない |
| P0再構築後の回帰 | Registry旧v0.6は未確認と記載。[Handoff_08](<../05_handoff/history/Context Handoff_08.md>)第12・13節にはv0.2テストとMailGenerator3.xlsmでのPASS出力あり | 後続実施を示す履歴として保持。MailGeneratorNew.xlsmに対する再実行結果ではない |
| 現在のWorkbook | ユーザー確認：別PCでP2対応中。WorkbookとOFTだけを当地へコピーし、更新したModules・文書は未反映。FS-04のP2系モジュール検出とも整合 | 差分は部分同期によるもの。フォルダ移行による欠落として扱わず、P2完了承認も推定しない |
| OFT相対参照 | Settingsは`Templates\MailTemplate.oft`、参照先実在 | 静的確認。Outlookでの読込テスト未実施 |

## 未解決事項・既知の制限

| ID | 状態・対応 |
| --- | --- |
| D-02 | 共通標準の外部正本が未確認。既存[ルールv0.1](<../01_Project_Control/Rules/AI協働開発 文書管理・Baseline運用ルール.md>)を参照し、新しいコピーを作らない |
| 別PC成果物の同期 | 当地の文書整備はCurrent Handoffまで。別PCの更新文書・Modulesは未反映で、Workbook／OFTのみコピー済み。共通名ソースの内容一致も未確認。別PCの成果物受入は別作業とし、推測による補完・上書きを行わない |
| 実機検証 | MailGeneratorNew.xlsmに対するCompile・Path Resolution・OFT／WordEditor・回帰テストは未実施。実施対象はコード対応と利用可能な環境を確認して確定する |
| P0-03制限 | 選定したSettings Smoke Test v0.2にはローカルパス前提が残る。フォルダ整理ではコードを改修していない |
| 構成の例外 | 使用済みの旧空フォルダを整理済み。Docs／Evidenceの大文字表記は暫定維持し、D-02の共通ルール・移動台帳の既存位置を保持する |

D-05のWorkbook確認と検証モジュール移動、D-06の現行テスト選定、D-10のPatch分類は完了。詳細証跡は移動台帳を参照する。

D-07は2026-10-11のユーザー承認に基づき、[Technical Spike A VBAコード.txt](<../../tests/vba/technical_spikes/Technical Spike A VBAコード.txt>)をtestsへ移動して完了。既存検証コードとして内容・拡張子を維持し、現行Smoke Testへの自動追加・実行は行っていない。追加記録は移動台帳第16節を参照する。

## Next Action / Done When

1. 別PCの更新文書・Modulesを受け入れる範囲と時点を確認し、コードの採用元・Checkpointを別作業で確定する。現在の差分を推測で解消しない。
2. 実機検証の対象・環境を確定する。Compile・Path Resolution・OFT／WordEditor・関連Smoke／RegressionはNOT RUN。静的移行検証のPASSとアプリケーションのPASSを分ける。

再開方法は[Current Handoff](../05_handoff/Current_Handoff.md)、環境・配置・テストの入口は[README](../../README.md)を参照する。技術仕様やBaselineのRevision表はこの文書に複製しない。
