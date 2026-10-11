# Project Overview

| 項目 | 内容 |
| --- | --- |
| Revision | v1.32 |
| 更新日 | 2026-10-12 |
| 文書の責務 | 現在地・未解決事項・次作業の正本 |
| Current Phase / Focus | P1-01～P1-07：PASS／COMPLETE（Completion Record）。P1-07はLF-P1-07-001（Outlook stale reference／Error 462）をv0.1.1で解消し、Compile・Warm／Cold E2E・Unresolved Fail Closed・P1-02回帰はPASS。CP-P1は未確立。P2 Boundary Confirmationは追加済みだがCP-P1 ESTABLISHEDを前提としており、当地ではP2実装開始不可。開発：別PCでP2対応中（2026-10-11ユーザー確認）。当地：フォルダ整備CLOSED |
| Project Status | P1-06のExecution EvidenceはPASS／COMPLETE。別PC成果物の同期と当地環境での実機検証は独立した後続作業 |
| Current Approved Baseline | BL-MVP-003。版構成・承認証跡は[Registry](Document_Registry.md)を参照 |
| 実行資産 | [MailGeneratorNew.xlsm](../../MailGeneratorNew.xlsm)と[Templates](../../Templates/) |

## 確認した状態と根拠

| 対象 | 確認済みの事実 | 意味・制限 |
| --- | --- | --- |
| フォルダ移行 | [移動台帳](Folder_Structure_Migration_Inventory_v0.1.md)第17節でクロージング。検証対象コミット`e54b5e0` | フォルダ整備PASS／CLOSED。実機動作やコード同期の完了を意味しない |
| P0 | 過去Current.mdにCP-P0確立・P0-06 PASSの記録。原本は`f310667:Docs/01_Project_Control/Reviews/CurrentPosition/Current.md` | BL-MVP-001時点の記録。今回のWorkbookの判定には転用しない |
| P1-01／DF-P1-001 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/P1-01 OFT Path Outlook Connection Completion Record v0.1.md>)、[Close Record](<../02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/DF-P1-001 Close Record v0.1.md>)に完了・Closeを記録 | 旧Current.mdのOneDrive課題を新たな未解決課題として登録しない |
| BL-MVP-003承認 | [Approval Record](baselines/BL-MVP-003_Approval_Record_v0.1.md)のQuality GateはPASS。REQ v0.1.9／DES v0.1.9／TS-A v0.4／TESTSPEC v0.1.5を採用 | BL-MVP-002はSupersededとして履歴保持。Baseline承認はWorkbook／VBAの実機PASSや別PC成果物の同期を意味しない |
| P0再構築後の回帰 | Registry旧v0.6は未確認と記載。[Handoff_08](<../05_handoff/history/Context Handoff_08.md>)第12・13節にはv0.2テストとMailGenerator3.xlsmでのPASS出力あり | 後続実施を示す履歴として保持。MailGeneratorNew.xlsmに対する再実行結果ではない |
| 現在のWorkbook | ユーザー確認：別PCでP2対応中。WorkbookとOFTだけを当地へコピーし、更新したModules・文書は未反映。FS-04のP2系モジュール検出とも整合 | 差分は部分同期によるもの。フォルダ移行による欠落として扱わず、P2完了承認も推定しない |
| OFT相対参照 | Settingsは`Templates\MailTemplate.oft`、参照先実在 | 静的確認。Outlookでの読込テスト未実施 |

## 未解決事項・既知の制限

| ID | 状態・対応 |
| --- | --- |
| D-02（保持例外） | 共通標準の外部正本が未確認。既存[ルールv0.1](<rules/AI協働開発 文書管理・Baseline運用ルール.md>)をプロジェクト内の単一ファイルとして保持する暫定運用を採用。今回の統合で既存パス保持条件を解除し、00_project_control/rulesへ移動。外部正本への移管は別件 |
| 別PC成果物の同期 | 当地の文書整備はCurrent Handoffまで。別PCの更新文書・Modulesは未反映で、Workbook／OFTのみコピー済み。共通名ソースの内容一致も未確認。別PCの成果物受入は別作業とし、推測による補完・上書きを行わない |
| 実機検証 | MailGeneratorNew.xlsmに対するCompile・Path Resolution・OFT／WordEditor・回帰テストは未実施。実施対象はコード対応と利用可能な環境を確認して確定する |
| P0-03制限 | 選定したSettings Smoke Test v0.2にはローカルパス前提が残る。フォルダ整理ではコードを改修していない |
| BL-MVP-003実装計画整合 | [Implementation Plan v0.3](<../02_implementation/Implementation Plan v0.3 日本語版.md>)はBL-MVP-003をExecution Baselineとし、[Plan Consistency Review](<reviews/Implementation Plan v0.3 Plan Consistency Review v0.1.md>)はPASS | DOC-MVP-IMPL v0.2のAFFECTED / REVISION REQUIREDは解消 |
| P1-02完了判定 | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/P1-02 Inspector WordEditor Connection Completion Record v0.1.md>)はBL-MVP-003上でP1-02をPASS／COMPLETEと判定。Compile、Warm／Cold Start、P1-01 Regression、Explorer／Draft／Inspector LifecycleはPASS | BL-MVP-003は変更なし。当地の`src`／Workbookが同一実行環境であることは未確認 |
| P1-02実装・Smoke Test資産 | [Cold Start Patch](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/modOutlookAdapter_P1-02_v0.2_ColdStart.patch>)、[CP932候補Module](<../02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/modOutlookAdapter_P1-02_v0.2_ColdStart_CP932.bas>)、[Smoke Test v0.2.2](<../../tests/vba/P1_Walking_Skeleton/modP1_02InspectorWordEditorSmokeTest_v0.2.2_CP932.bas>)を保持 | 同一`VB_Name`の旧Smoke Testは二重Importしない。当地でのImport・再実行は未実施 |
| P1-03 Template Snapshot Boundary | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-03_Template_Snapshot/P1-03 Template Snapshot Boundary Completion Record v0.1.md>)によりBL-MVP-003上でPASS／COMPLETE。Subject／BodyText Snapshot Boundary、P1-03 Smoke、P1-02 Warm／Cold Regression、P1-01 Regression、および変更差分のRuntime ExecutionはPASS | CP-P1は未確立。当地の`src`／WorkbookがCompletion Recordの実行環境と一致することは未確認 |
| P1-03 Production Patch | [Production Patch Review v0.2](<reviews/P1-03 Production Patch Review v0.2.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<reviews/P1-03 Finding Assessment v0.1.md>)はBlocking Findingなしと判定 | `Debug → Compile VBAProject`の今回ログは未記録だが、変更差分のRuntime ExecutionをCompile Gateの根拠としている |
| P1-04 Minimal Template Scanner | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-04_Minimal_Template_Scanner/P1-04 Minimal Template Scanner Completion Record v0.1.md>)によりBL-MVP-003上でPASS／COMPLETE。Core Smoke、P1-03 Snapshot→Scanner Integration、CloseWithoutSaveおよび変更差分のRuntime ExecutionはPASS | CP-P1は未確立。当地の`src`／WorkbookがCompletion Recordの実行環境と一致することは未確認 |
| P1-04 Production Patch | [Production Patch Review v0.2](<reviews/P1-04 Production Patch Review v0.2.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<reviews/P1-04 Finding Assessment v0.1.md>)はBlocking Findingなしと判定 | TF-P1-04-001（OFT Fixture Drift）はRESOLVED、TF-P1-04-002（Workbook Artifact）はRESOLVED／NON-BLOCKING。`Debug → Compile VBAProject`の今回ログは未記録 |
| P1-05 Minimal Render | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-05_Minimal_Render/P1-05 Minimal Render Completion Record v0.1.md>)によりBL-MVP-003上でPASS／COMPLETE。VBA Compile、Core、Warm／Cold Integration、Render後Snapshot、Negative Verification N1～N5、Required RegressionはPASS | CP-P1は未確立。当地の`src`／Workbook／OFTがCompletion Recordの実行環境と一致することは未確認 |
| P1-05 Production Patch | [Production Patch Review v0.1](<reviews/P1-05 Minimal Render Production Patch Review v0.1.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<reviews/P1-05 Minimal Render Finding Assessment v0.1.md>)はBlocking Findingなしと判定 | TF-P1-05-001（Negative Verification Coverage Gap）はRESOLVED／NON-BLOCKING。N6 WordEditor FailureはP6へDEFERRED／NON-BLOCKING |
| P1-06 Minimal Unresolved Checker | [Completion Record](<../02_implementation/P1_Walking_Skeleton/P1-06_Minimal_Unresolved_Checker/P1-06 Minimal Unresolved Checker Completion Record v0.1.md>)によりBL-MVP-003上でPASS／COMPLETE。VBA Compile、Core、Normal／Missing Value Integration、Scanner／Unresolved独立判定、P1-05 Major RegressionはPASS | CP-P1は未確立。当地の`src`／Workbook／OFTがCompletion Recordの実行環境と一致することは未確認 |
| P1-06 Production Patch | [Production Patch Review v0.1](<reviews/P1-06 Minimal Unresolved Checker Production Patch Review v0.1.md>)はStatic＋Runtime VerificationでPASS、[Finding Assessment](<reviews/P1-06 Minimal Unresolved Checker Finding Assessment v0.1.md>)はBlocking Findingなしと判定 | TF-P1-06-001はTest Artifact DefectとしてRESOLVED／CLOSED。Production Defect・Requirement／Design／Baseline変更はなし。`RenderError`はP1 Interim Mappingであり、P6の正式分類を固定しない |
| 構成の例外 | 使用済みの旧空フォルダを整理済み。Docs／Evidenceの大文字表記は暫定維持し、共通ルール・移動台帳は00_project_controlへ統合済み |

D-05のWorkbook確認と検証モジュール移動、D-06の現行テスト選定、D-10のPatch分類は完了。詳細証跡は移動台帳を参照する。

D-07は2026-10-11のユーザー承認に基づき、[Technical Spike A VBAコード.txt](<../../tests/vba/technical_spikes/Technical Spike A VBAコード.txt>)をtestsへ移動して完了。既存検証コードとして内容・拡張子を維持し、現行Smoke Testへの自動追加・実行は行っていない。追加記録は移動台帳第16節を参照する。

## Next Action / Done When

フォルダ整備の未完了タスクはない。以下は今回のクロージング後に扱う別作業である。

1. 別PCの更新文書・Modulesを受け入れる範囲と時点を確認し、コードの採用元・Checkpointを別作業で確定する。現在の差分を推測で解消しない。
2. 実機検証の対象・環境を確定する。Compile・Path Resolution・OFT／WordEditor・関連Smoke／RegressionはNOT RUN。静的移行検証のPASSとアプリケーションのPASSを分ける。
3. P1-03 Completion Recordの実行環境と当地のProduction Module・Workbookを照合する場合は、別PC成果物の受入範囲と時点を先に確定する。完了記録を根拠に当地資産を推測で上書き・Importしない。
4. P1-04 Completion Recordの実行環境と当地のProduction Module・Workbook・OFTを照合する場合は、別PC成果物の受入範囲と時点を先に確定する。完了記録を根拠に当地資産を推測で上書き・Importしない。
5. P1-05 Completion Recordの実行環境と当地のProduction Module・Workbook・OFTを照合する場合は、別PC成果物の受入範囲と時点を先に確定する。完了記録を根拠に当地資産を推測で上書き・Importしない。
6. P1-06 Completion Recordの実行環境と当地のProduction Module・Workbook・OFTを照合する場合は、別PC成果物の受入範囲と時点を先に確定する。完了記録を根拠に当地資産を推測で上書き・Importしない。
7. P1-07 Completion Recordの実行環境と当地のProduction Module・Workbook・OFTを照合する場合は、別PC成果物の受入範囲と時点を先に確定する。完了記録を根拠に当地資産を推測で上書き・Importしない。
8. P2を当地で開始する場合は、P1 Phase Verification RecordおよびCP-P1 Establishment Recordの正本・適用時点を確認し、OverviewのCP-P1未確立との整合を解消する。解消前にP2 Boundary Confirmationを実装開始の根拠として使わない。

再開方法は[Current Handoff](../05_handoff/Current_Handoff.md)、環境・配置・テストの入口は[README](../../README.md)を参照する。技術仕様やBaselineのRevision表はこの文書に複製しない。

管理フォルダ統合（2026-10-11）：旧01_Project_Controlを廃止し、00_project_controlへ統合した。詳細・検証は移動台帳第18節に記録。フォルダ整備のCLOSEDとBaselineは維持する。
