# フォルダ構成移行台帳 v0.1（FS-00）

## 1. 目的と適用範囲

この台帳は、`Folder_Structure_Proposal_v0.1` に基づくフォルダ構成移行の事前確認記録である。
FS-00では移行対象の扱いを、移行実施前に確定できる状態にすることを目的とする。FS-01の配置先準備は第9節、FS-02の文書移動結果は第10節、FS-03の検証記録・履歴整理は第11節に記録する。第3節は移行元と予定先の対応表として保持し、実施状態は各工程の実施記録で確認する。

2026-10-10追記：ユーザー回答と現物確認を反映した。第4節は当初の検討履歴として保持し、決定と実行条件は第8節を優先する。今回は本台帳だけを更新し、移行・削除は実施しない。

| 項目 | 内容 |
| --- | --- |
| 作業単位 | FS-00: 移行前確認・移動台帳の確定 |
| 基準コミット | `23c553a` (`change folder structure by myself`) |
| 判定基準 | フォルダ構成見直し案 v0.1、および既存の文書管理・Baseline運用ルール v0.1 |
| 変更分類（予定） | Editorial / Governance Change。ただし実行資産の相対パスまたはWorkbookのImport対象へ影響するものは別途検証する。 |

## 2. 台帳の状態定義

| 状態 | 意味 | 次の扱い |
| --- | --- | --- |
| `READY` | 移動先と扱いが提案と現物から一意に決まる | FS-01以降で移動可能 |
| `REVIEW` | 内容・利用状態・保管方針を確認してから決める必要がある | 決定まで移動しない |
| `EXTERNAL` | リポジトリ外の実行資産または共通標準 | 所在・管理方針を確認するまで対象外 |
| `KEEP` | 新構成でも同じ位置・役割を維持する | 原則移動しない |

## 3. 移動台帳

下表のパスパターンに一致する追跡済みファイルは、同じ扱いで一括移動できる。ファイル本文、Document ID、Version、Statusは変更しない。

| ID | 現在のパス | 移行先 | 対象 | 状態 |
| --- | --- | --- | --- | --- |
| R-01 | `Docs/00_Proposal/定型メール作成ツール 企画書.md` | `docs/00_project_control/Proposal.md` | 企画書 | READY |
| R-02 | `Docs/01_Project_Control/Baseline/BL-MVP-002 Baseline Approval Record v0.1.md` | `docs/00_project_control/baselines/BL-MVP-002_Approval_Record_v0.1.md` | Baseline承認記録 | READY |
| R-03 | `Docs/01_Project_Control/Baseline/BL-MVP-002 Baseline Candidate.md` | `docs/00_project_control/baselines/BL-MVP-002_Candidate.md` | Baseline候補 | READY |
| R-04 | `Docs/01_Project_Control/Reviews/Consistency/*` | `docs/00_project_control/reviews/` | 文書横断レビュー | READY |
| R-05 | `Docs/01_Project_Control/Reviews/Impact/*` | `docs/00_project_control/reviews/` | 影響レビュー | READY |
| R-06 | `Docs/02_Requirements/MVP Requirements.md` | `docs/01_specifications/MVP_Requirements.md` | Requirements正本 | READY |
| R-07 | `Docs/03_Design/MVP Design.md` | `docs/01_specifications/MVP_Design.md` | Design正本 | READY |
| R-08 | `Docs/05_Test/MVP Test Specification.md` | `docs/01_specifications/MVP_Test_Specification.md` | Test Specification正本 | READY |
| R-09 | `Docs/06_Implementation/Implementation Plan.md` | `docs/02_implementation/Implementation_Plan.md` | Implementation Plan正本 | READY |
| R-10 | `Docs/06_Implementation/P0_Foundation/*` | `docs/02_implementation/P0_Foundation/` | P0実装記録 | READY |
| R-11 | `Docs/06_Implementation/P1_WalkingSkeleton/P1-01_OFT_Outlook/*` | `docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/` | P1-01 Unit記録 | READY |
| R-12 | `Docs/06_Implementation/P1_WalkingSkeleton/P1-02_WordEditor/*` | `docs/02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/` | P1-02 Unit記録 | READY |
| R-13 | `Docs/04_Technical_Evidence/TV-P1-001の正式判定.md` | `docs/03_verification/technical_validation/TV-P1-001_正式判定.md` | 技術検証の正式判定 | READY |
| R-14 | `Docs/04_Technical_Evidence/TV-P1-001 OneDrive Local Path Resolution 技術検証 作業手順書 v0.1.md` | `docs/01_specifications/technical_spikes/` | 技術検証の手順仕様 | READY |
| R-15 | `Docs/04_Technical_Evidence/Technical Spike A 実施仕様書.md` | `docs/01_specifications/technical_spikes/` | Technical Spike正本 | READY |
| R-16 | `Docs/04_Technical_Evidence/DF-P1-001 Close Record v0.1.md` | `docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/` | Finding Close記録 | READY |
| R-17 | `Docs/04_Technical_Evidence/P1-01 OFT Path Outlook Connection Completion Record v0.1.md` | `docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/` | P1-01完了記録 | READY |
| R-18 | `Docs/04_Technical_Evidence/OneDrive Cloud URL cannot be used directly as OFT file path.md` | `docs/03_verification/technical_validation/` | 技術検証の知見・判定補助 | READY |
| R-19 | `Docs/07_Handoff_Archive/Context Handoff_01.md` ～ `_08.md` | `docs/05_handoff/history/` | 過去Handoff | READY（D-03確定） |
| R-20 | `Source/Production/Classes/*.cls` | `src/classes/` | 本番クラス | READY |
| R-21 | `Source/Production/Modules/modOptionMasterData_CP932.bas`、`modOutlookAdapter_CP932.bas`、`modResult.bas`、`modSettingsData_DF-P1-001_v0.1_CP932.bas`、`modVariableDefinitionData_CP932.bas` | `src/modules/` | 現行本番候補モジュール | READY（D-05を除く） |
| R-22 | `Source/SmokeTests/P0-02/*` ～ `P0-06/*` | `tests/vba/P0_Foundation/` | P0テスト・テスト補助資料 | READY（D-06を除く） |
| R-23 | `Source/SmokeTests/P1-01/*` | `tests/vba/P1_Walking_Skeleton/` | P1-01 Smoke Test | READY |
| R-24 | `tree.txt` | 作業ツリーから削除、基準コミットで保持 | 旧構成のスナップショット | 方針確定・FS-03で実施（D-08） |

## 4. 当初の判断待ち一覧（検討履歴）

ここにある項目は、承認または事実確認が完了するまで移動しない。D番号ごとに決定を記録してから、対応する作業単位へ渡す。

| ID | 対象 | 判断が必要な点 | 選択肢 | 推奨 | 影響 |
| --- | --- | --- | --- | --- | --- |
| D-01 | `Docs/01_Project_Control/Baseline/定型メール作成ツール Project Document Registry and Approved Baseline.md` | Project Overviewを新設してRegistry/Baselineを統合するか、現在の独立文書を維持するか | (A) `Project_Overview.md`へ統合、(B) `Document_Registry.md`として独立維持 | B | README・Handoff・リンク更新範囲 |
| D-02 | `Docs/01_Project_Control/Rules/AI協働開発 文書管理・Baseline運用ルール.md` | これは本プロジェクトのコピーか、全プロジェクト共通標準の正本か | (A) プロジェクト内に残す、(B) リポジトリ外の正本へ移しリンク化 | A（所在が確定するまで） | 移動すると参照が壊れる可能性 |
| D-03 | `Context Handoff_08.md` | 最新Handoffを `Current_Handoff.md` として改名・内容更新するか、全件をhistoryに置き新規作成するか | (A) `_08`をCurrentへ昇格、(B) 全件history＋新規作成 | B | 内容編集の要否。単純移動では済まない |
| D-04 | `Docs/01_Project_Control/Reviews/CurrentPosition/Current.md` | 内容を `Project_Overview.md` へ移すか、Current Position記録として残すか | (A) Overviewへ統合、(B) historyへ保存 | A | 新規Project Overviewの作成と内容編集が必要 |
| D-05 | `Source/Production/Modules/modP1OneDrivePathVerification_CP932.bas` | WorkbookへImportする本番モジュールか、技術検証専用か | (A) `src/modules/`、(B) `tests/vba/P1_Walking_Skeleton/` | B（ファイル名と提案に基づく暫定） | 本番Import対象・回帰テスト範囲 |
| D-06 | `Source/SmokeTests/P0-03/modSettingsDataSmokeTest.bas` と `_v0.2_CP932.bas`、および `P0-06` の v0.1/v0.2 | 同一テストの旧版を保持するか、現行テストのみ残すか | (A) 全て履歴保管、(B) 現行のみtests＋旧版archive | B | テスト実行対象の一意性 |
| D-07 | `Docs/04_Technical_Evidence/Technical Spike A VBAコード.txt` | 実行可能な検証コード、説明用の証跡、または旧ソースか | (A) `tests/vba/`、(B) `evidence/technical_validation/`、(C) `docs/90_archive/` | B（内容確認後） | テスト資産かRaw Evidenceかが変わる |
| D-08 | `tree.txt` | 構成整理後も履歴資料として残すか | (A) pre-Git archiveへ保管、(B) Git履歴で十分なため削除 | A | 旧構成の再現性 |
| D-09 | ルートの `Archive/`、`Evidence/`、`Templates/`、および未確認の `MailGenerator.xlsm` / `MailTemplate.oft` | 実行資産の実在位置と、空フォルダの目的を確定する | (A) 現行位置を維持、(B) 実在資産を新構成へ受入 | A（相対パス優先） | VBAの相対パス、OFT接続、実機テスト |
| D-10 | `Docs/01_Project_Control/Reviews/Migration/*` | 各ファイルを、反映済みPatchか、継続参照するQA Reviewかに分類する | (A) Patchをarchive、(B) Reviewをproject controlへ配置 | ファイル単位で分類 | 監査証跡の検索性 |

## 5. アーカイブ候補（適用状況・履歴の照合が必要）

| 現在のパス | 提案上の移行先 | 補足 |
| --- | --- | --- |
| `Docs/01_Project_Control/Baseline/Archive/*` | `docs/90_archive/pre_git_revisions/` | Git導入前または旧Revisionの復元用 |
| `Docs/01_Project_Control/Baseline/patch/*` | `docs/90_archive/applied_patches/` | 適用済みPatchとして保管 |
| `Docs/01_Project_Control/Reviews/Migration/*` | `docs/90_archive/applied_patches/` または `docs/00_project_control/reviews/` | D-10: PatchかQA Reviewかをファイル単位で分類 |
| `Docs/02_Requirements/Defferences/*` | `docs/90_archive/applied_patches/` | 誤記を含む旧ディレクトリは新設しない |
| `Docs/03_Design/Defferences/*` | `docs/90_archive/applied_patches/` | 同上 |
| `Docs/05_Test/Defferences/*` | `docs/90_archive/applied_patches/` | 同上 |
| `Docs/05_Test/old/*` | `docs/90_archive/pre_git_revisions/` | Git履歴で不要と判断した場合のみ後で削除を検討 |
| `Docs/06_Implementation/old/*` | `docs/90_archive/pre_git_revisions/` | 同上 |
| `Source/Production/Modules/old/*` | `docs/90_archive/pre_git_revisions/source/` | `src/`へ混在させない |

## 6. FS-00完了判定

FS-00は、次を満たした時点で完了とする。

- `READY` の対象に一意の移行先がある。
- `REVIEW` / `EXTERNAL` の対象に、判断内容・選択肢・影響が記録されている。
- 実行資産（Workbook、OFT、Templates）の扱いを、文書の配置変更と混同していない。
- 移行がBaselineのVersion、承認状態、技術文書の意味を変更しないことを確認している。
- 次のFS-01ではD-01～D-10の決定済み項目だけを実行し、未決定項目は現位置に残す。

## 7. 次工程への引渡し

ユーザー回答済みの方針は再承認を求めない。条件付き項目は第8節の確認を満たした時点で対応する作業単位へ渡す。FS-01は必要な配置先の準備、実際の移動はFS-02～04、入口文書・参照更新はFS-05とする。本台帳の更新は移行実行の開始を意味しない。

## 8. 回答反映・内容確認結果（2026-10-10）

判断基準：Source of Truthの一意性、文書管理・Baseline運用ルールv0.1との整合、再現性と安全性、管理負荷の最小化。

| ID | 採用方針・状態 | 実施単位・残る確認 |
| --- | --- | --- |
| D-01 | B確定。`Document_Registry.md`を独立維持し、Overviewから参照する。ManifestやRevision一覧を複製しない | FS-02移動／FS-05参照整備 |
| D-02 | A暫定維持。外部正本が確認できるまで既存パスに保持する | 移行対象外。詳細は下記 |
| D-03 | B確定。01～08を全件historyへ移し、Currentを新規作成する | FS-03／FS-05。08を最新実態とみなさず根拠資料と照合する |
| D-04 | A確定。現行の裏付けがある情報だけOverviewへ統合する | FS-05。下記の旧情報をそのまま転載しない |
| D-05 | B条件付き。技術検証コードと確認できた。予定先は`tests/vba/P1_Walking_Skeleton/modP1OneDrivePathVerification_CP932.bas` | FS-04。実WorkbookのImport状態・呼出元確認待ち |
| D-06 | B確定。現行テストだけtestsへ配置し、旧版はGitまたはArchiveで保持する | FS-04。版番号だけで現行を確定せず、内容・既存テスト記録・VB_Nameを照合する |
| D-07 | 内容確認によりAへ変更提案。`tests/vba/technical_spikes/Technical Spike A VBAコード.txt`を候補とする | FS-03/04。実行資産という分類は確認済み。配置案変更は未確定 |
| D-08 | B確定。基準コミット収録と現物一致を確認。独立Archiveを作らず作業ツリーから削除予定 | FS-03。今回は削除しない |
| D-09 | A確定。WorkbookとOFTの現行配置・相対関係を維持し、実行資産は別作業とする | 空のArchive/Evidenceは整理候補。Templatesは実行時パスのため維持。Workbook所在は未確認 |
| D-10 | ファイル単位分類の方針確定。反映済みPatchはArchive、QA ReviewはProject Controlへ配置 | FS-03。Patch反映済みの照合が必要。名前だけで適用済みと断定しない |

### D-02：共通標準の扱い

文書情報は「全プロジェクト共通運用標準」「v0.1」と明記されている。プロジェクト専用ルールへ変更する根拠はない。確認した文書・リポジトリからは外部正本の所在を特定できないため、外部正本が存在しないとは断定しない。

既存の`Docs/01_Project_Control/Rules/AI協働開発 文書管理・Baseline運用ルール.md`を、このプロジェクトの暫定的な参照先として維持する。新しいdocs配下やリポジトリ外へコピーを作らず、README／Overviewから既存ファイルを参照する。旧階層が部分的に残ることを移行の例外として認める。Windowsの`Docs`→`docs`表記統一も、この保持条件と整合するよう実施時に扱う。

同ルール第21節は「その文書自身の内容が変更された場合」にVersion更新を行うとしている。したがって、単純移動は内容不変だが、FS-05でリンクや本文を編集する文書はEditorial Changeとして個別に改訂を扱う。「フォルダ整理だから一切Versionを上げない」という先の一律方針を訂正する。Baseline採用Revision・承認状態を自動更新せず、基準コミットから旧承認版を復元できる関係を維持する。

### D-04：Current.mdは過去時点の記録

全文に記載されているのは、BL-MVP-001、P0完了／CP-P0確立、P0-06とCompileのPASS、Blocking Finding 0件、P1 Entry ALLOWED、OneDrive URL互換リスクである。日付や現Workbookを識別する情報はない。

一方、Registry v0.6にはBL-MVP-002、P1-01完了、DF-P1-001 CLOSED、Workbook再構築後のP0 Integration Regression未確認が記載されている。OverviewではBL-MVP-001を現行扱いせず、旧Compile PASS・Finding 0件・P0-06 PASSを現在のWorkbookの確認結果として転載しない。P0完了なども「既存記録上の状態」として出典を伴わせる。OneDrive課題はClose Record等に従い、未解決リスクとして再登録しない。

Overviewを現在地の唯一の正本とし、Registryの現在進捗欄とHandoffには必要最小限の要約・参照だけを残す。Current.mdの旧内容は基準コミットで保持し、統合完了後に現行の現在地文書として残さない。削除はFS-05で統合結果とGit収録を確認した後に扱う。

### D-05：技術検証用途は確認、Workbook確認は残る

公開入口は`TestOneDriveLocalPathResolution()`で、`TV-P1-001`のSTART/PASS/FAILを出力する。OneDrive Web URLという前提を判定し、設定読取、OFTからのMailItem生成、保存せずCloseを検証している。補助関数はPrivateである。本番の`ResolveWorkbookRelativePath`は別の`modSettingsData`に存在する。確認したSource内に当該モジュール／入口を外部から呼ぶコードは見つからなかった。

ただし、ソース検索だけではWorkbookのImport状態、ボタン割当、Application.Run等の実行時参照を保証できない。プロジェクト内にxlsm／oftは確認できず、実Workbook検査は未実施。FS-04で当該ファイルを移動する前に、実Workbookを特定し、VBComponentの有無・内容一致・イベントやボタン等の呼出元を確認する。検証モジュールがImport済みでも、それだけで本番コードとは判定しない。Workbookからの削除・再Importはフォルダ移行に含めない。

### D-07：テキスト拡張子だが実行用の検証コード

冒頭に「Technical Spike A v0.2」「本番実装ではなくTechnical Spike用」とあり、`RunTechnicalSpikeA_v02()`、`OFT_PATH = C:\Temp\TechnicalSpikeA.oft`、Outlook生成、Route H/W比較、判定カウンタ、結果出力を持つ。これは実行結果ログではなく、結果を生成する検証ハーネスである。

提案の「実行可能なテストコードはtests」という責務に合わせ、Aへの変更を提案する。拡張子・本文・固定パスは保存し、自動実行、bas変換、パス書換えは行わない。実行環境未確認の既存検証コードとして扱い、現行Smoke Testの実行対象へ自動追加しない。Evidenceには実行ログ・画面等の出力を配置する。配置の正本は1つとし、testsとevidenceへ二重保存しない。

### D-08：Git保持条件を確認済み

`git cat-file -e 23c553a:tree.txt`は成功した。`git rev-parse 23c553a:tree.txt`と`git hash-object tree.txt`はともに`5545554a0653a05ad9c7faffb81083605556de0a`で一致した。現物にはDocs／Source／Templates等の旧構成が記録されている。

基準コミットから`git show 23c553a:tree.txt`で閲覧できる。削除後に復元が必要なら、既存ファイルを上書きしないことを確認して`git restore --source=23c553a -- tree.txt`で戻せる。Git管理済みの資料を`pre_git_revisions`へ重複保管する必要はない。

## 9. FS-01実施記録（2026-10-10）

判定：FS-01実施可能。確定済みファイルの受入先準備を完了した。D-05等の条件は後続の個別ファイル移動に適用し、配置先準備の阻害条件とはしない。

### 作成・確認した配置先

以下の12配置先と、その親ディレクトリを作成した。全配置先の存在を確認した。

| 配置先（現時点の実パス） | 受入対象・作業単位 |
| --- | --- |
| `src/modules/` | R-21本番モジュール／FS-04 |
| `src/classes/` | R-20本番クラス／FS-04 |
| `tests/vba/P0_Foundation/` | P0テスト／FS-04。D-06該当版の選定は別途 |
| `tests/vba/P1_Walking_Skeleton/` | R-23テスト／FS-04。D-05対象の移動は条件確認後 |
| `Docs/00_project_control/baselines/` | R-02・03／FS-02 |
| `Docs/00_project_control/reviews/` | R-04・05／FS-02 |
| `Docs/01_specifications/technical_spikes/` | R-14・15／FS-02。親にR-06～08を受入 |
| `Docs/02_implementation/P0_Foundation/` | R-10／FS-02。親にR-09を受入 |
| `Docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/` | R-11・16・17／FS-02・03 |
| `Docs/02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/` | R-12／FS-02 |
| `Docs/03_verification/technical_validation/` | R-13・18／FS-03 |
| `Docs/05_handoff/history/` | R-19／FS-03 |

### 保持・後続工程に回した事項

- Windows上の既存`Docs/`を使用した。`docs/`という別の文書ルートは作成していない。Git上の大文字小文字統一はD-02の既存パス保持と合わせて後続工程で扱う。
- `Evidence/`は既存の受入先として保持。今回、確定した生証跡の移動対象がないため、その下の空フォルダは追加しない。
- `Templates/`、`Archive/`、既存のDocs／Source階層は保持。Workbook・OFTへの操作はない。
- 未確定のD-07用`tests/vba/technical_spikes/`、適用状況・履歴未照合のarchive用階層、未着手P2・forms・正式MVPテスト等の将来用階層は作成しない。
- README、Project Overview、Current Handoffの本文整備は計画どおりFS-05で行う。
- 空ディレクトリはGitでは追跡されない。管理対象を増やさないため`.gitkeep`等は追加しない。別チェックアウトでは本節の配置先一覧から再作成でき、FS-02～04でファイルを配置するとGit追跡対象になる。

### 完了条件と引渡し

FS-01の範囲である受入先準備は完了。既存追跡ファイルに差分がないこと、ファイルの移動・削除がないことを確認した。台帳は未追跡のままであり、コミットは実施していない。

次工程はFS-02。後続工程に残る条件は、D-05の実Workbook確認、D-06の現行テスト選定、D-07の配置変更案確定、D-10等のPatch適用・履歴照合である。D-02は既存パス保持という暫定措置を継続する。

## 10. FS-02実施記録（2026-10-10）

状態：完了。開始時のHEADは`41eec25`（Complete FS-01）、作業ツリーはクリーンだった。第3節のR-01～R-12・R-14・R-15、およびD-01のRegistryを対象として19ファイルを移動した。

### 移動結果

以下は実際の移動先。ディレクトリのみの記載では元のファイル名を維持した。ルートの大文字表記`Docs/`はFS-01とD-02の保持条件を継続する。

| 台帳ID | 移動対象 | 件数 | 移動先 |
| --- | --- | ---: | --- |
| R-01 | 企画書 | 1 | `Docs/00_project_control/Proposal.md` |
| D-01 | Document Registry and Approved Baseline | 1 | `Docs/00_project_control/Document_Registry.md` |
| R-02 | BL-MVP-002承認記録 | 1 | `Docs/00_project_control/baselines/BL-MVP-002_Approval_Record_v0.1.md` |
| R-03 | BL-MVP-002 Candidate | 1 | `Docs/00_project_control/baselines/BL-MVP-002_Candidate.md` |
| R-04 | Consistency内の2レビュー | 2 | `Docs/00_project_control/reviews/` |
| R-05 | Impact内の2レビュー | 2 | `Docs/00_project_control/reviews/` |
| R-06 | Requirements | 1 | `Docs/01_specifications/MVP_Requirements.md` |
| R-07 | Design | 1 | `Docs/01_specifications/MVP_Design.md` |
| R-08 | Test Specification | 1 | `Docs/01_specifications/MVP_Test_Specification.md` |
| R-09 | Implementation Plan | 1 | `Docs/02_implementation/Implementation_Plan.md` |
| R-10 | P0実装開始準備 | 1 | `Docs/02_implementation/P0_Foundation/` |
| R-11 | P1-01実施仕様、DF-P1-001実装仕様、README | 3 | `Docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/` |
| R-12 | P1-02実施仕様 | 1 | `Docs/02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/` |
| R-14 | TV-P1-001作業手順書 | 1 | `Docs/01_specifications/technical_spikes/` |
| R-15 | Technical Spike A実施仕様書 | 1 | `Docs/01_specifications/technical_spikes/` |

### 検証・変更範囲

- 移動前に全19件の移動元実在、移動先非存在、親フォルダ実在、ワークスペース内の絶対パスを確認した。
- 移動前後のSHA-256が全19件で一致し、元パスが残っていないことを確認した。本文・文字コード・改行を含めバイト単位で不変であり、Document ID・Version・Status・Baseline Manifestも不変。
- 共通ルール、Current.md、過去Handoff、旧版・Patch、Source、Templates、Evidence、tree.txtは今回の移動対象外。旧フォルダは削除していない。
- 本台帳だけに実施結果を追記した。台帳のファイル名はFS-00からの作業台帳識別子として維持する。
- 文書内リンク・RegistryのPath情報・入口文書の整備はFS-05で実施する。移行途中のため旧パス表記の解消やリンク検証の完了を意味しない。
- Gitのステージング・コミットは実施していない。作業ツリーでは旧パス削除と新パス未追跡として表示される場合があるが、19件は内容を保持した移動である。

### 次工程

FS-03で検証記録・引継ぎ・履歴を整理する。R-13・R-16～19・R-24、Reviews直下の未整理資料、旧版・Patch等を対象とする。D-10の適用状況照合とD-07の配置案判断は継続課題。D-05の実Workbook確認とD-06のテスト選定はFS-04へ引き継ぐ。

## 11. FS-03実施記録（2026-10-10）

開始時HEAD：`92be434`（Complete FS-02）。開始時の作業ツリーはクリーン。確定対象の整理を完了し、35ファイルを移動、R-24の`tree.txt`を削除した。D-07は継続保留であり、移行全体の完了を意味しない。

### 実施結果

- 検証判定・技術知見2件を`Docs/03_verification/technical_validation/`へ移動。
- P1-01のClose／Completion Record 2件をUnit配下へ移動。
- Handoff 01～08の8件を`Docs/05_handoff/history/`へ移動。Currentの新規作成はFS-05。
- Reviews直下のレビュー・要否判定7件を`Docs/00_project_control/reviews/`へ移動。Technical Spike B/C要否判定はBaselineを起点とするImplementation Entry Decisionのためここに分類した。
- 旧Registry v0.2～v0.5、旧Test Specification、旧Implementation Planの6件を`Docs/90_archive/pre_git_revisions/`へ移動。既存台帳で指定された旧版保管先を使用し、内容の複製は作っていない。フォルダ名は今回の保管分類であり、各資料がGit導入前に作成されたという事実認定ではない。
- Patch／差分整理10件を`Docs/90_archive/applied_patches/`へ移動。適用記録の照合根拠は下表。
- `tree.txt`は削除直前に`23c553a:tree.txt`と現物のGit blobが`5545554a0653a05ad9c7faffb81083605556de0a`で一致することを再確認した。Archiveへの複製は作らず、第8節の方法で復元可能。

### Patch分類と適用記録の照合

これはフォルダ整理のための適用履歴確認であり、過去Patchの再適用や技術仕様の再承認ではない。Patch本文の変更目的・対象Revisionを、後続の更新概要およびレビュー記録と照合した。改訂で置換・削除された過去のNext Actionは現行本文へ復活させない。

| Patch／差分整理 | 照合根拠 | 判定 |
| --- | --- | --- |
| Requirements v0.1 → v0.1.1 差分整理 | `MVP_Requirements.md`のv0.1.1更新概要に、大小文字、Invalid Syntax、Date 6 Format、SortOrder、OFT不存在の5項目が反映済みと記載 | 適用履歴として保管 |
| Requirements v0.1.4 技術固有表現整理 | Requirements v0.1.5更新概要の技術非依存表現・AC-017・HTML Encode整理と一致 | 適用履歴として保管 |
| Design v0.1.2 WordEditor対応 | `MVP_Design.md`のv0.1.3更新概要にRoute W、WordEditor、Range、Scanner入力変更等を反映 | 適用履歴として保管 |
| Baseline 最終整合性修正 | Requirements v0.1.6、Design v0.1.4更新概要、最終整合性再確認のCR-001～006 Close記録 | 適用履歴として保管 |
| Design v0.1.4→v0.1.5 最終整合性 | Design v0.1.5更新概要にFCR-001/002対応、Current設定取得とWorkbook単位の保持期間を反映 | 適用履歴として保管 |
| Test Specification v0.1→v0.1.1 | `MVP_Test_Specification.md`のv0.1.1更新概要12項目、Baseline 4文書最終整合性チェックのPASS記録 | 適用履歴として保管 |
| 文書管理ルール移行 Migration Patch | Requirements v0.1.7、Design v0.1.6、Spike A v0.3、Test Spec v0.1.2の更新概要にGovernance Migrationを明記 | D-10：A／適用履歴として保管 |
| Migration QA Correction Patch | QA Governance Consistency Review v0.2が適用Correctionを明記しPASS。REQ v0.1.8、DES v0.1.7、Spike v0.4、Test Spec v0.1.3の更新概要とも整合 | D-10：A／適用履歴として保管 |
| Design DF-P1-001対応 | Design v0.1.8更新概要にOneDrive Local Path Resolution対応。DES×TESTSPECレビュー、BL-MVP-002承認記録を保持 | 適用履歴として保管 |
| Registry v0.5 Update Patch | 旧Registry v0.5の更新概要・ManifestにBL-MVP-002承認とBL-MVP-001 Supersededを反映。現行v0.6でも維持 | 適用履歴として保管 |

D-10分類：Migrationフォルダ内の2件はいずれも変更指示を収めたPatchであり、ファイル名にQAが含まれてもQA Review本体とは区別する。QA Governance Consistency Review本体はFS-02で`Docs/00_project_control/reviews/`へ移動済み。D-10の今回対象2件の分類・履歴照合は完了。

### 全移動対応表

| 移動元（92be434） | 現在の移動先 |
| --- | --- |
| `Docs/04_Technical_Evidence/TV-P1-001の正式判定.md` | `Docs/03_verification/technical_validation/TV-P1-001_正式判定.md` |
| `Docs/04_Technical_Evidence/DF-P1-001 Close Record v0.1.md` | `Docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/DF-P1-001 Close Record v0.1.md` |
| `Docs/04_Technical_Evidence/P1-01 OFT Path Outlook Connection Completion Record v0.1.md` | `Docs/02_implementation/P1_Walking_Skeleton/P1-01_OFT_Outlook/P1-01 OFT Path Outlook Connection Completion Record v0.1.md` |
| `Docs/04_Technical_Evidence/OneDrive Cloud URL cannot be used directly as OFT file path.md` | `Docs/03_verification/technical_validation/OneDrive Cloud URL cannot be used directly as OFT file path.md` |
| `Docs/01_Project_Control/Reviews/Baseline 最終整合性修正 差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/Baseline 最終整合性修正 差分パッチ v0.1.md` |
| `Docs/07_Handoff_Archive/Context Handoff_01.md` | `Docs/05_handoff/history/Context Handoff_01.md` |
| `Docs/07_Handoff_Archive/Context Handoff_02.md` | `Docs/05_handoff/history/Context Handoff_02.md` |
| `Docs/07_Handoff_Archive/Context Handoff_03.md` | `Docs/05_handoff/history/Context Handoff_03.md` |
| `Docs/07_Handoff_Archive/Context Handoff_04.md` | `Docs/05_handoff/history/Context Handoff_04.md` |
| `Docs/07_Handoff_Archive/Context Handoff_05.md` | `Docs/05_handoff/history/Context Handoff_05.md` |
| `Docs/07_Handoff_Archive/Context Handoff_06.md` | `Docs/05_handoff/history/Context Handoff_06.md` |
| `Docs/07_Handoff_Archive/Context Handoff_07.md` | `Docs/05_handoff/history/Context Handoff_07.md` |
| `Docs/07_Handoff_Archive/Context Handoff_08.md` | `Docs/05_handoff/history/Context Handoff_08.md` |
| `Docs/01_Project_Control/Baseline/Archive/定型メール作成ツール Project Document Registry and Approved Baseline v0.2.md` | `Docs/90_archive/pre_git_revisions/定型メール作成ツール Project Document Registry and Approved Baseline v0.2.md` |
| `Docs/01_Project_Control/Baseline/Archive/定型メール作成ツール Project Document Registry and Approved Baseline v0.3.md` | `Docs/90_archive/pre_git_revisions/定型メール作成ツール Project Document Registry and Approved Baseline v0.3.md` |
| `Docs/01_Project_Control/Baseline/Archive/定型メール作成ツール Project Document Registry and Approved Baseline v0.4.md` | `Docs/90_archive/pre_git_revisions/定型メール作成ツール Project Document Registry and Approved Baseline v0.4.md` |
| `Docs/01_Project_Control/Baseline/Archive/定型メール作成ツール Project Document Registry and Approved Baseline v0.5.md` | `Docs/90_archive/pre_git_revisions/定型メール作成ツール Project Document Registry and Approved Baseline v0.5.md` |
| `Docs/05_Test/old/MVP Test Specification v0.1.3.md` | `Docs/90_archive/pre_git_revisions/MVP Test Specification v0.1.3.md` |
| `Docs/06_Implementation/old/Implementation Plan v0.1.md` | `Docs/90_archive/pre_git_revisions/Implementation Plan v0.1.md` |
| `Docs/01_Project_Control/Baseline/patch/定型メール作成ツール Project Document Registry and Approved Baseline v0.5 Update Patch.md` | `Docs/90_archive/applied_patches/定型メール作成ツール Project Document Registry and Approved Baseline v0.5 Update Patch.md` |
| `Docs/01_Project_Control/Reviews/Migration/Baseline 4文書 Migration QA Correction Patch v0.1.md` | `Docs/90_archive/applied_patches/Baseline 4文書 Migration QA Correction Patch v0.1.md` |
| `Docs/01_Project_Control/Reviews/Migration/Baseline 4文書 文書管理ルール移行 Migration Patch.md` | `Docs/90_archive/applied_patches/Baseline 4文書 文書管理ルール移行 Migration Patch.md` |
| `Docs/02_Requirements/Defferences/MVP Requirements v0.1 → v0.1.1 差分整理.md` | `Docs/90_archive/applied_patches/MVP Requirements v0.1 → v0.1.1 差分整理.md` |
| `Docs/02_Requirements/Defferences/MVP Requirements v0.1.4 技術固有表現整理 差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/MVP Requirements v0.1.4 技術固有表現整理 差分パッチ v0.1.md` |
| `Docs/03_Design/Defferences/MVP Design DF-P1-001対応 最小差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/MVP Design DF-P1-001対応 最小差分パッチ v0.1.md` |
| `Docs/03_Design/Defferences/MVP Design v0.1.2 WordEditor対応 差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/MVP Design v0.1.2 WordEditor対応 差分パッチ v0.1.md` |
| `Docs/03_Design/Defferences/MVP Design v0.1.4→v0.1.5 最終整合性差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/MVP Design v0.1.4→v0.1.5 最終整合性差分パッチ v0.1.md` |
| `Docs/05_Test/Defferences/MVP Test Specification v0.1→v0.1.1 差分パッチ v0.1.md` | `Docs/90_archive/applied_patches/MVP Test Specification v0.1→v0.1.1 差分パッチ v0.1.md` |
| `Docs/01_Project_Control/Reviews/Baseline 4文書 最終整合性チェック v0.1.md` | `Docs/00_project_control/reviews/Baseline 4文書 最終整合性チェック v0.1.md` |
| `Docs/01_Project_Control/Reviews/Baseline 最終整合性レビュー v0.1.md` | `Docs/00_project_control/reviews/Baseline 最終整合性レビュー v0.1.md` |
| `Docs/01_Project_Control/Reviews/Baseline 最終整合性再確認 v0.1.md` | `Docs/00_project_control/reviews/Baseline 最終整合性再確認 v0.1.md` |
| `Docs/01_Project_Control/Reviews/Implementation Plan v0.1 内容レビュー.md` | `Docs/00_project_control/reviews/Implementation Plan v0.1 内容レビュー.md` |
| `Docs/01_Project_Control/Reviews/MVP Design v0.1.8 × MVP Test Specification v0.1.4 Cross-document Consistency Review.md` | `Docs/00_project_control/reviews/MVP Design v0.1.8 × MVP Test Specification v0.1.4 Cross-document Consistency Review.md` |
| `Docs/01_Project_Control/Reviews/MVP Test Specification v0.1 Baseline整合性レビュー v0.1.md` | `Docs/00_project_control/reviews/MVP Test Specification v0.1 Baseline整合性レビュー v0.1.md` |
| `Docs/01_Project_Control/Reviews/Technical Spike B and C 要否判定.md` | `Docs/00_project_control/reviews/Technical Spike B and C 要否判定.md` |

### 検証と残課題

- 全35件の移動先を事前に重複・上書き・ワークスペース外パスがないことを確認。移動前後のSHA-256が一致し、元パスが残っていないことを確認した。Version・Document ID・承認記録・履歴本文は不変。
- 移動後、残る追跡済み44ファイルのハッシュが作業開始時と一致することを確認。その後、許可されたtree.txt削除と本台帳追記だけを行った。
- 台帳以外の本文・文書内リンクは編集していない。リンク整備はFS-05、旧空フォルダの削除・ルート表記統一も後続で扱う。ステージング・コミットは未実施。
- D-07：Technical Spike A VBAコード.txtは元の`Docs/04_Technical_Evidence/`に保持。testsへの配置変更案を継続課題とする。今回ユーザーが指定した保留条件を維持する。
- D-05：実WorkbookのImport・呼出元確認、D-06：現行テストの選定はFS-04へ引継ぎ。Source配下の旧本番コードもFS-04で扱う。
- 共通ルールはD-02どおり既存パスを保持。Current.mdはFS-05のOverview統合まで保持する。旧Handoffを最新進捗とは扱わない。
