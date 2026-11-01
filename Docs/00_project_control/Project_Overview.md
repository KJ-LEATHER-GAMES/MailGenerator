# Project Overview

| 項目 | 内容 |
| --- | --- |
| Revision | v1.67 |
| 更新日 | 2026-10-24 |
| 文書の責務 | 現在地・未解決事項・次作業の正本 |
| S1～S4の最新現在地（2026-10-24） | S1～S3正式Closureを維持。S4 COMPLETED／S4-B Repository Acceptance PASS。次候補はS5 Read-only Precheck（別承認待ち・未着手）。[最新現在地](#s4b-repository-acceptance-20261024)を参照 |
| Current Phase / Focus | P1-01～P1-07：PASS／COMPLETE（Completion Record）。P1-07はLF-P1-07-001（Outlook stale reference／Error 462）をv0.1.1で解消し、Compile・Warm／Cold E2E・Unresolved Fail Closed・P1-02回帰はPASS。CP-P1は未確立。P2 Boundary／5 Unit分割／P2-01仕様v0.1（Approved）／Scanner候補／Core・Integration・MTS-SCAN-005 Boundary Test候補／外部実行のFinding Assessment v0.1.1・Production Patch Review・Completion Record／P2-02 Boundary Confirmation・Draft／Approved実施仕様・整合性Review／Sync Engine候補・Core v0.1.1・Negative・Compatibility Test候補・実装記録・Finding Assessment・Production Patch Review・Completion Record／P2-03 Boundary Confirmation・Candidate／Approved実施仕様・整合性Review・Production Patch設計・未Import Production／Core・Negative Test候補・Finding Assessment・Negative／Compatibility／Regression／Static Review・Final Finding Assessment・Production Patch Review・Completion Recordは追加済みだがCP-P1 ESTABLISHEDを前提としており、当地ではP2実装・検証開始不可。TF-P2-02-001はTest Artifact Correctionで、P2-02実装記録はCompile Pending／Formal Test Not Executedである。P2-03 Completion Recordを含む各PASS記録も当地で独立確認していない。開発：別PCでP2対応中（2026-10-11ユーザー確認）。当地：フォルダ整備CLOSED |
| Project Status | P1-06のExecution EvidenceはPASS／COMPLETE。P2-02 Completion Recordは別環境でのPASS／COMPLETEを報告する条件付き記録であり、当地の受入・CP-P1確立・P2 Phase／CP-P2完了を意味しない。別PC成果物の同期と当地環境での実機検証は独立した後続作業 |
| Current Approved Baseline | BL-MVP-004（Repository文書受入）。固定版構成・追認・過去Baselineは[Registry](Document_Registry.md#3-current-approved-baseline)を参照。過去Execution Baselineは変更しない |
| 実行資産 | [MailGeneratorNew.xlsm](../../MailGeneratorNew.xlsm)と[Templates](../../Templates/) |

<a id="s4b-repository-acceptance-20261024"></a>

## S4-B Repository受入・文書同期の最新現在地（2026-10-24 JST）

**S4：COMPLETED／S4-B Repository Acceptance：PASS**。8対象の承認済み差分、文書間整合性、Traceability、リンク／アンカー、Public／Private分離の最終照合はPASS。承認済み全文3件の保存後照合と[Registry同期](Document_Registry.md#3-current-approved-baseline)はPASS。既存APPROVEDのBL-MVP-004を固定4文書のVersion組合せを変えずRepository文書として受け入れた。Plan v0.4は承認済み影響修正文書であり、固定4文書には含めない。[Current Acceptance Ratification](baselines/BL-MVP-004_Approval_Record_v0.1.md#bl-mvp-004-current-ratification-20261024)は2026-10-24 JSTの独立したUSER Decisionで、権限は本人申告・独立検証なし。歴史的承認主体・承認決定日はUNKNOWN、2026-10-01はGate実施日である。

S1：G2_RECORDED_S1_CLOSED、S2：S2_FORMAL_CLOSURE_RECORDED、S3：S3_FORMAL_CLOSURE_RECORDEDを維持する。過去BL-MVP-003 Execution Baseline、Source Version／Workbook全体の同一性未証明、2026-10-10 CompileのUSER-REPORTED Evidence、実行日時・Fixtureに関する既存のProvenance限定は不変。今回の文書受入をSource Import・Workbook一致・Compile・技術テスト／Formal MVP Testの合格と扱わない。

OneDriveRegistration／ManagementShareEffectiveAccess／Stage2TotalExecutionCountはUNKNOWN、Primary／Restoreの残留リスク受容は既存S1範囲のみ。`OBS-P2-05-002`はOPEN / NON-BLOCKINGを維持する。P2-05は未完了、**P2PhaseClosed=FALSE／CP-P2Established=FALSE**。Git操作・Baseline再構成・技術テスト／Compile／Archive再実行はない。

次Action：S4-B結果をユーザーへ報告して停止し、レビューを待つ。次候補は**S5：P2-05 Completion準備のRead-only Precheck（別承認待ち・未着手）**。S5／S6には進まない。以下のv1.66以前のS4未着手・旧Baseline現在地は当時の履歴として保持し、現在地は本欄を優先する。

<a id="s3-newcycle-i12-formal-closure-20261024"></a>

## S3 Formal Closureの最新現在地（2026-10-24 JST）

**S3：COMPLETED／S3_FORMAL_CLOSURE_RECORDED**。2026-10-24（JST）のユーザー正式承認に基づき、[P2-04新Cycle Regression Record](../03_verification/technical_validation/P2-04_Manual_Sync_Integration_Regression_Record_v0.3_Draft.md#p204-newcycle-regression-formal-closure-20261024)を本文v0.4／**182/182 PASS・FAIL 0／CLOSED**、[I12 Final Quality Gate Assessment](../03_verification/technical_validation/P2-04_I12_Final_Quality_Gate_Assessment_v0.3_Review_Result.md#i12-documentary-formal-closure-20261024)を本文v0.4／**Documentary CLOSED**へ改訂した。両記録の読み戻し・Status・相互参照が整合し、S1 G2／5件Traceabilityと既存Evidenceを根拠とする。技術結果、Source／Workbook／Compile／Fixtureの証拠限定、旧I10 ABORT・旧PENDING履歴は保持し、詳細は2記録を正本とする。

**S1：G2_RECORDED_S1_CLOSED／S2：S2_FORMAL_CLOSURE_RECORDED**は維持。今回S3のClosureをUnit Completion・G2再承認・P2-05 Completion・Phase Closureと混同しない。次Actionは**S4：BL-MVP-004 Repository受入・文書整合のRead-only Precheck／別承認待ち**。**S4は未着手・未承認**であり、BL-MVP-003履歴とBL-MVP-004承認記録の区別を保持し、Baselineは今回変更しない。S5 P2-05 Completion、S6 P2 Phase Exit／CP-P2は残工程。**P2PhaseClosed=FALSE／CP-P2Established=FALSE**。

`OBS-P2-05-002`は**OPEN / NON-BLOCKING**。今回S3審査範囲でBlocking Finding NONEであり、P2全体のFinding 0は主張しない。OneDriveRegistration／ManagementShareEffectiveAccess／Stage2TotalExecutionCountはUNKNOWN、Primary／Restoreの受容は既存S1限定のままS3・S4へ拡張しない。技術テスト・Compile・Archiveの再実行、Manifest・Private Index変更、Git操作はない。以下のv1.65以前のS3未着手・旧PENDING等は当時の履歴として保持し、最新現在地は本欄を優先する。

<a id="s2-regression-formal-closure-20261024"></a>

## S2 Regression Record Formal Closureの最新現在地（2026-10-24 JST）

**S2：FORMAL CLOSURE RECORDED**。ユーザーの2026-10-24（JST）の明示承認に基づき、[P2-02 Regression Record](<../03_verification/technical_validation/P2-02 Sync Diff Core Regression Record v0.1.md#p202-regression-formal-closure-20261024>)と[P2-03 Regression Record](<../03_verification/technical_validation/P2-03 VariableDefinition Sync Persistence Regression Record v0.1.md#p203-regression-formal-closure-20261024>)を各本文v0.2／**PASS・CLOSED**へ正式改訂した。111/111・46/46 PASSは既存Evidenceを維持し、Unit Completionとは別のRegression Record Closureである。詳細なDisposition・Traceability・証拠限定は各Recordを正本とする。

次Actionは**S3：P2-04新Cycle／I12 Documentary ClosureのPrecheck**（**未着手・未承認**）。次のユーザー指示に基づくRead-only確認または別途承認判断へ引き継ぎ、今回S3作業は開始しない。**S1：G2_RECORDED_S1_CLOSED**は維持。S4のBL-MVP-004 Repository受入・同期、S5 P2-05 Completion、S6 Phase Exit／CP-P2は未完了のまま。

OneDriveRegistration／ManagementShareEffectiveAccess／Stage2TotalExecutionCountはUNKNOWNを維持し、S1限定リスク受容をS2へ拡張しない。技術テスト・Compile・Archiveの再実行、Git操作、Baseline変更はない。以下のv1.64以前のS2未完了・旧PENDING等は各時点の履歴として保持し、最新現在地は本欄を優先する。

<a id="s1-g2-approval-closure-20261024"></a>

## G2正式承認・S1 Closureの最新現在地（2026-10-24 JST）

**G2：APPROVED_BY_USER／S1：CLOSED**。ユーザーは2026-10-24（JST）にP2 Evidence Archive S1を正式承認した。S1-B実行PASS・S1-CレビューPASSと今回の3文書最終整合性確認を根拠とする。承認記録の正本は[ManifestのG2承認記録](../03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md#s1-g2-approval-closure-20261024)（本文v0.3／Approved、既存ファイル名維持）。正確な承認時刻・新規承認IDは付与しない。

次Actionは**S2：P2-02／P2-03 Regression Recordsの正式Closure**。S2～S6は未完了・今回未着手であり、S1の再開・Archive／Restore再実行は不要。P2全体Closure、P2 Phase Exit、CP-P2確立、BL-MVP-004へのBaseline切替は今回の承認・完了範囲に含めない。

**OneDriveRegistration、ManagementShareEffectiveAccess、Stage2TotalExecutionCountはUNKNOWNを維持**。Primary管理共有・Restore Destinationの既存S1限定リスク受容を拡大せず、技術的PASSへ格上げしない。Private Index・Archive・Baselineの変更、Git操作はない。以下のv1.63以前のDraft／G2 PENDING／NOT CLOSED等は当時の履歴であり、最新現在地は本欄を優先する。

<a id="s1c-current-after-execution-20261024"></a>

## S1-B実行後の最新現在地（2026-10-24訂正）

v1.62の承認待ち表示を、ユーザー追加承認に基づき最新現在地だけ訂正した。既存のS1-B実行報告は`S1_ARCHIVE_EXECUTION_PASS_PENDING_S1C_G2`。EXECUTE_ARCHIVEはAPPROVED_BY_USER、実行結果はPASS。Primary・Backup保全とUSB Backupを復元元とした試験は各5/5_SHA256_PASS、後処理はPLAN_CONFORMANT、原本不変はPASS。今回のS1-CではPrivate Index両系統の内容・サイズ・SHA-256一致と、原本5件の対応・既存実行Evidenceとの整合をRead-onlyで確認した。実パス・生Evidenceをここに複製せず、既存の非公開Private IndexとCodex実行Evidenceを参照する。Archive／Restore自体は今回再実行していない。

現在作業の判定は**S1-C：REVIEW PASS／G2 REVIEW PENDING**。[既存Manifest](../03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md)をv0.2 Draftへ更新し、5件のTraceability・文書間整合・Markdownリンク・Public／Private情報分離はPASS。**G2：PENDING／NOT APPROVED、S1：NOT CLOSED**を維持し、レビュー結果を報告して停止した後にユーザーのG2判断を待つ。Private Index・Baseline・Gitの変更はない。

**OneDriveRegistration、ManagementShareEffectiveAccess、Stage2TotalExecutionCountはUNKNOWNのまま**。既存のPrimary／RestoreのS1限定リスク受容とStage 2訂正履歴を変更せず、安全性の技術的PASSへ格上げしない。本最新欄より前の意味を持つ下段のNOT APPROVED・承認待ち・Precheck READY等は、当時の正しい履歴として保持し、現在地の判断には本欄を優先する。

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

<a id="s1b-stage2-closure-20261024"></a>

## S1-B Stage 2 Closure・再開判断（2026-10-24追記）

記録ID：`S1B-S2-CORR-20261024-01`。本書v1.59からv1.60への追記として、既存のCodex会話・実行ログとユーザーのClosure指示を整理する。以前の証跡・添付指示書・Snapshotは訂正上書きせず、その時点の記録として保持する。本追記はS1-Bの管理状態だけを更新し、既往のP2受入条件、技術仕様、Baseline、S1-B全体の完了条件を変更しない。

### Stage 2技術判定と実行履歴の訂正

| 事項 | 根拠・確度 | 確定内容／限界 |
| --- | --- | --- |
| Codex事前確認 | 既存tool実行結果・VERIFIED_LOG | 2026-10-23 22:29:50 JST、STAGE2_PRECONDITIONS_PASS |
| Codex変更実行 | 既存tool実行結果・VERIFIED_LOG | 2026-10-23 22:30:58 JST、識別済みUSBルートへの`icacls /remove:g`によるEveryone Allow ACE除去を1回実行。終了コード0。単なる提案・指示ではない |
| Codex実行前後 | 同じ既存tool実行結果・VERIFIED_LOG | Root ACEは4件から3件へ変化。他3主体、Owner、継承設定、直下項目、既存Snapshotハッシュは不変。2026-10-23 23:09:04 JSTのRead-only事後照合もSTAGE2_ROOT_POSTCHECK_PASS_PENDING_SVI |
| ユーザー管理者PowerShell実行 | 終了コード0の出力提示についてのユーザー報告・USER_REPORTED | Codex実行とは別の実行申告として保持。ユーザー実行日時・セッション対応・重複の有無は未確定 |
| SVI事後照合とClosure | SVI_POSTSTAGE2_READONLY_PASSのユーザー報告、および2026-10-24の明示判定・USER_CONFIRMED | Root／SVI／SnapshotはPASS、Blocking Technical Findingは0、Technical DecisionはSTAGE2_VERIFIED。今回の技術検証再実行による判定ではない |

訂正対象：過去の「Codex実行なし」という説明は、上記の実際の実行ログと矛盾するため、現在有効な説明としては採用しない。原記録を削除せず、本記録IDによって後続訂正を追跡する。後日のRead-only事後検証で変更コマンドを実行しなかったことと、それ以前のCodex変更実行は区別する。

実行回数：**ログで確認できるCodex実行は1回**。これとは別にユーザー実行の申告があるが、**実行総回数とユーザー実行日時はUNKNOWN**。総回数を1回または2回と推定確定しない。この不確実性は記録上の残留事項であり、Stage 2の技術Closureを妨げるFindingとは扱わない。履歴確認のためのACL再操作・再検証・Rollbackは行わない。

### Primary管理共有：既存Evidenceの整理

以下は2026-10-21以降の既存Precheck・空フォルダ作成後確認・会話内報告の整理であり、今回の再測定ではない。VERIFIED_AT_PRIOR_CHECKは当時の確認事実を示し、現在の実効アクセスを推定でPASSにはしない。

| 対象 | 既存Evidence・確度 | 残る限界 |
| --- | --- | --- |
| Primaryの空3階層 | VERIFIED_AT_PRIOR_CHECK：Ownerは通常ユーザー、NTFS Allowは通常ユーザー・SYSTEM・AdministratorsのFullControlのみ。継承は有効、追加の広範なRead／Write／Modify ACEなし | 将来の親ACL変更、通常ユーザー権限で動作する不正プログラム、管理者等の特権は排除しない |
| 配置・同期・通常共有 | VERIFIED_AT_PRIOR_CHECK：Repository外、確認できたOneDrive同期ルート外、ReparsePointなし、関連する通常SMB共有なし | 未把握の同期サービス・共有方針まで不存在と保証しない |
| 管理共有 | VERIFIED_AT_PRIOR_CHECK：Primaryを包含する管理共有が存在。共有側でAdministrators／Backup Operators／INTERACTIVEへのFull許可を観測 | 共有ACLだけではPrimary内容の読取り可否は確定しない。NTFSとの組合せ、実際のトークン・特権・ネットワーク条件による実効アクセスはUNKNOWN |
| 親のTraverse権限 | VERIFIED_AT_PRIOR_CHECK：親のみの非継承Traverse等を観測。ユーザープロファイルの継承保護を確認 | TraverseだけをPrimary内容のRead許可と同一視しない |
| 暗号化・到達性 | 共有側EncryptData=Falseを既存調査で観測 | 実際のSMBセッション暗号化・ネットワーク到達性・Primaryの保存時暗号化はUNKNOWN。平文通信や情報漏えいが実証されたという意味ではない |

### A／B比較と次の判断

| 案 | 内容・利点 | 判断に必要な情報／残留リスク |
| --- | --- | --- |
| A：残留リスクを明示受容 | 現行の3主体NTFS制限を維持し、管理共有・OS設定を変更しない。追加変更と管理負荷を抑える | 管理者等の特権主体を信頼できるか、ネットワーク経由の未検証アクセスと暗号化のUNKNOWNを許容できるか、要求する保護水準をユーザーが判断する。完全な本人専用・ネットワーク隔離とは主張しない |
| B：必要最小限の追加是正 | 受容できない脅威・アクセス経路だけを特定し、別途承認した限定調査の後、実証された過剰権限または共有・ネットワーク側の該当箇所だけを是正する | 現在のPrimary NTFSに追加除去すべきACEは既存Evidence上示されていない。具体的な対象・管理／バックアップへの影響・復旧方法の確定が先。子フォルダACLの制限だけで管理者特権を遮断したとは扱わない |

推奨は**Aの条件付き明示受容を第一候補**とする。既存Evidenceだけでは追加ACL是正の必要性は立証されておらず、管理共有全体の無効化や広範な設定変更は推奨しない。ただし、特権主体への信頼やUNKNOWNの受容ができない場合はBを選び、対象を限定して追加承認を得る。本記録はユーザーに代わるリスク受容でも、既存のUNKNOWN停止条件の解除・緩和でもない。

次のユーザー判断は、Primary管理共有の残留リスクと未確認範囲を明記したAの受容、またはBの限定調査対象の承認。いずれもArchive作成・原本5件のコピー・Backup／復元試験の実行承認とは別である。Gate B1／B2の分離案もS1-B全体の完了条件を自動変更しない。

現在の停止点：**Stage 2はSTAGE2_VERIFIED／S1-Bは未完了／G2未承認／Archive作成・原本コピー・S1-Cは未承認**。この追記では新規文書・フォルダを作成せず、ACL・Evidence・Snapshotを変更していない。Git操作はユーザー指示により実施せず、コミットおよびWorking Tree全体の照合も未実施。

<a id="s1-primary-risk-acceptance-20261024"></a>

### Primary残留リスク受容決定（2026-10-24後続追記）

記録ID：`S1-PRIMARY-RISK-20261024-01`。Decisionは`ACCEPT_RESIDUAL_RISK`、Decision AuthorityはUSER、StatusはAPPROVED。対象は**P2 Evidence Archive S1のPrimary保管先のみ**。ユーザーの正式決定を反映するため本書をv1.61へ改訂し、技術文書・Approved Baselineへ版更新を伝播させない。

既存Evidenceでは追加是正を必要とするNTFS ACL問題は確認されていない。一方、**管理共有経由の他主体の実効アクセスと管理共有の通信暗号化はUNKNOWN**のまま、特権主体を信頼する前提で今回のS1に限り残留リスクを受容する。管理共有の技術的安全性を検証済みとする決定ではない。Primary側の追加ACL是正・追加の管理共有調査は今回実施しない。

この後続決定により、上節のA／B比較と「次のユーザー判断」は受容前時点の履歴となる。Stage 2のSTAGE2_VERIFIED、既存の訂正履歴、実行総回数・ユーザー実行日時のUNKNOWNは変更せず、Stage 2を再調査・再実行しない。

次Actionは**S1 Archive Read-only Precheck**。本決定はArchive作成・Evidenceコピー・復元試験・S1-Cへの実行承認ではなく、**Archive Execution：NOT APPROVED／S1-B：未完了／G2：PENDING**を維持する。他の未確認条件の包括的受容や、S1-B完了条件の緩和は行わない。

<a id="s1-restore-final-precheck-20261024"></a>

### Restore Destination承認・Archive Final Precheck（2026-10-24後続追記）

記録ID：`S1-RESTORE-APPROVAL-20261024-01`。Decisionは`ACCEPT_RESTORE_DESTINATION`、Decision AuthorityはUSER、Decision StatusはAPPROVED。**Restore Test Destination：USER APPROVED／Residual Risk：USER ACCEPTED・S1 ONLY（ACCEPTED_WITH_LIMITATIONS）**。対象は今回のS1 Evidence 5-file Restore Testに限定し、Primaryの既存受容判断を変更しない。採用先の実パスは本Codex会話のユーザー承認指定と既存Read-only報告を参照し、本公開管理文書へ転記しない。

配置・親ACLの既存確認を前提に、特権主体のアクセス可能性と管理共有経由の実効アクセスUNKNOWNを限定受容する。**OneDrive Registration／同期状態はUNKNOWN**のままとし、これらの技術的安全性を検証済みとは記録しない。本書v1.62はこの正式決定と最終判定の追記による改訂であり、技術仕様・Approved Baselineの版更新は行わない。

| 最終確認 | 判定 | 根拠・実行との境界 |
| --- | --- | --- |
| F1 Restore Destination | READY | 既存Read-only確認で原本・Primary・予定Backup・Repository・Archive領域と非重複、既存祖先にReparsePointなし。親から継承可能なACLは承認3主体のみで、親Ownerも許容主体。今回の正式採用・限定受容と整合する。子ディレクトリは未作成であり、後続の明示実行承認後に作成・実ACL確認を行い、不適合ならコピー前に停止する |
| F2 OneDrive Registration | UNKNOWN維持・追加Blockerなし | 既知同期ルート外という既存確認、PrimaryDestination PASSの継続、Restore側のUNKNOWNを維持した今回の限定承認を前提とする。登録情報の網羅的な独立取得を新しい必須Gateとして追加しない。同期安全性のPASS／VERIFIEDへは格上げせず、実際の同期対象等の矛盾が判明した場合は既存の停止条件を適用する |
| F3 Archive Plan Mapping | PASS | 原本5件のID・サイズ・SHA-256は既存Manifest／実施条件書と照合済み。Primaryと既存ユーザー指定Backup候補への計画上の対応は一意で、Backup予定階層の既存衝突なし。復元先は今回正式採用。媒体同一性・別物理ディスク・BitLocker・Root ACLの直近PASSは確度を維持して再利用し、再調査しない。コピー・照合・復元・Private Index整備の条件は既存計画どおりで、新しい設計判断は不要 |

媒体・物理ディスク対応およびBitLockerの最新実測はUSER_PROVIDED_OS_OUTPUTであり、過去EvidenceやCodexの独立測定と混同しない。Root ACL・ボリューム属性については直近のCodex Read-only照合結果も再利用する。復元試験後は既存実施指示第5節の規定に従い、照合成功後にこの実行で作成した試験専用フォルダだけを削除可とする。不確実・失敗時は保持して報告し、既存の原本・Primary・Backupを片付け対象にしない。保持・削除について実行に必須の新判断はない。

**ArchivePrecheckDecision：READY／RemainingBlockers：なし（計画上の実行準備に限る）**。これはArchiveの実行・完了・安全性全般の承認ではない。**Archive Execution：NOT APPROVED／G2：PENDING／S1-B：未完了**を維持する。次Actionはユーザーによる`EXECUTE_ARCHIVE`の明示承認待ち。今回、フォルダ作成・コピー・復元試験・設定変更・Manifest更新・Git操作は行わず、S1-C／G2へ自動移行しない。先行節のNext Actionは各追記時点の履歴として保持する。
