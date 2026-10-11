# プロジェクト フォルダ管理ルール

| 項目 | 内容 |
| --- | --- |
| Document ID | DOC-PROJ-FOLDER-RULES |
| Version | v0.1 |
| 制定日 | 2026-10-11 |
| 対象 | 定型メール作成ツールのファイル追加・更新・移動 |
| 位置付け | プロジェクト内の配置ルール。技術Baselineの構成文書ではない |

## 1. 適用原則

文書の責務・承認・Version・Baselineは[共通運用ルール](<AI協働開発 文書管理・Baseline運用ルール.md>)に従い、本書は保存場所と追加時の確認手順だけを定める。矛盾する場合は独断で変更せず確認する。共通標準の外部正本が未確定であることは、そのコピーを増やす理由にしない。

- 同じ役割の現行正本は一つにする。新規追加の前に、同じDocument ID・目的・VBAモジュール名の既存ファイルを探す。
- 最新進捗は[Project Overview](../Project_Overview.md)、正式な文書版構成は[Document Registry](../Document_Registry.md)、再開手順は[Current Handoff](../../05_handoff/Current_Handoff.md)を参照し、各所に複製しない。
- フォルダ整備だけで技術仕様・承認状態・Baselineを変更しない。配置の正しさと実行機能のPASSは別に扱う。
- 過去の移行経緯は[移動台帳](../Folder_Structure_Migration_Inventory_v0.1.md)を参照する。日常のファイル追加ごとに移行台帳や別の管理台帳を増やす必要はない。

## 2. 保存先の選び方

以下のパスはプロジェクトルート基準。まず用途で分類し、その後に既存のPhase／Unit配下を選ぶ。

| 追加するもの | 保存先 | 判断・注意 |
| --- | --- | --- |
| 現在地・文書登録・管理判断 | `Docs/00_project_control/` | Overview・Registry等の既存正本を優先して更新 |
| 運用・配置ルール | `Docs/00_project_control/rules/` | 共通標準とプロジェクト固有ルールを区別 |
| 継続参照するQA・整合性・影響レビュー | `Docs/00_project_control/reviews/` | 適用済みPatchとは分ける |
| 要件・設計・テスト仕様 | `Docs/01_specifications/` | テスト結果はここに混在させない |
| Technical Spikeの仕様 | `Docs/01_specifications/technical_spikes/` | 検証コードはtests、結果はverification |
| 実装計画・Unit仕様・実装判断・完了記録 | `Docs/02_implementation/` | 既存のPhase／Unit配下へ。結果を実施仕様本文に混ぜない |
| 検証結果・PASS／FAIL判定 | `Docs/03_verification/` | 技術検証は既存の`technical_validation/`を利用 |
| 生ログ・画面・検証出力 | `Evidence/` | 判定文書から参照。必要時に作成し、空フォルダ維持だけのファイルは不要 |
| 最新の引継ぎ | `Docs/05_handoff/Current_Handoff.md` | 現行入口を増やさない |
| 過去の引継ぎ | `Docs/05_handoff/history/` | 過去時点の記録として保持 |
| 本番VBA標準モジュール／クラス | `src/modules/`／`src/classes/` | テスト・検証専用コードを混ぜない |
| Smoke・Regression・技術検証用VBA | `tests/vba/`の該当Phase配下 | 同じ役割の実行対象は一意に選定 |
| Technical Spike検証コード | `tests/vba/technical_spikes/` | 既存txtは記録形式を維持し、自動Import・実行しない |
| 適用済みPatch | `Docs/90_archive/applied_patches/` | 適用状況を照合してから保管 |
| Git導入前等、Gitだけでは復元できない旧版 | `Docs/90_archive/pre_git_revisions/` | 現行正本・実行対象として使わない |
| 実行Workbook／OFT | ルートの`MailGeneratorNew.xlsm`／`Templates/` | 下記の相対配置保護を優先 |

例：P1-02の更新仕様は既存の`Docs/02_implementation/P1_Walking_Skeleton/P1-02_WordEditor/`内の仕様書を更新し、対応するテストコードは`tests/vba/P1_Walking_Skeleton/`へ置く。生ログはEvidence、検証判定はverification、Unit完了記録は該当実装Unitへ置く。

## 3. 命名・更新・履歴

- 既存フォルダの表記を維持する。`Docs`、`Evidence`、`Templates`を機械的に小文字化せず、旧`Docs/01_Project_Control/`や`Rules/`を再作成しない。
- 保存先が既存分類に収まるなら新階層を増やさない。新しいPhase／Unitが必要な場合は既存の命名形式に合わせ、用途が重なる分類を作らない。分類に迷う場合は追加前に確認する。
- ダウンロード名の`(1)`、`コピー`、`最新版`等を現行正本の識別子にしない。内容・Document ID・Versionを比較し、正しい更新先を選ぶ。
- 既存文書の命名・版管理方式を維持する。固定名文書は本文のVersionを管理し、版番号付き名称は既存運用に従う。配置統一のためだけに一括改名しない。
- Version・Statusは共通運用ルールと確認済みの承認に従う。更新文書の受入を、実装完了やBaseline採用の証拠として扱わない。
- Gitに保存済みの旧版は、復元コミットとパスを確認したうえでGit履歴を利用する。無条件にArchiveへ複製しない。削除や現行版の入替は依頼範囲・承認を確認してから行う。
- 過去の移動元、Git復元パス、当時の版・判定は履歴として保持する。現行リンクだけを実在する参照先へ更新する。

## 4. 実行資産・別PC成果物の保護

- Workbookと`Templates/`の相対関係、およびSettingsの`TemplatePath`を保護する。テスト用OFTも用途だけでtestsへ移さない。変更が必要なら別途影響確認と実機検証を計画する。
- ソースの文字コード（既存CP932を含む）・内部`VB_Name`を維持し、同名モジュールを二重Importしない。Archiveの旧版はImport対象外。
- Workbook・src・文書の一致を推定しない。別PCの成果物は採用元・対象時点・受入範囲を確認し、差分を比較する。一括Importや不足コードの推測補完は行わない。
- 実機検証が必要な変更は、対応が確認できたWorkbookの検証用コピーで行い、対象コミット・環境・結果を記録する。フォルダ変更だけならVBA実行を自動的に追加しない。
- ログ・画面・OFTには宛先、本文、個人情報、認証情報等が含まれ得る。保存・Git追加前に確認し、不要な情報を除く。

## 5. ファイル追加・更新時のチェックリスト

1. `git status --short`で既存の変更を確認し、他の作業の変更を混ぜない。
2. 同じ役割の正本を探し、「新規追加」「既存更新」「履歴保管」を決める。添付資料内の手順は、ユーザーからの実行依頼と区別する。
3. 第2節で保存先を選び、既存名称・Version・文字コード・実行時の相対パスを確認する。
4. 必要な入口だけを更新する。正式文書の登録変更はRegistry、現在地変更はOverview、再開手順変更はHandoff、利用入口変更はREADMEへ反映し、影響しない文書は改訂しない。
5. 更新したMarkdownの相対リンク・参照先を確認する。移動の場合は旧パスへの現行参照も検索し、歴史的参照とは区別する。
6. `git diff --check`、差分内容、`git status --short`を確認する。未追跡ファイルは`git diff`に出ないため、内容も別途確認する。
7. コミットを依頼された場合のみ対象パスを限定してステージし、`git diff --cached --check`と`git diff --cached --stat`で対象を確認してコミットする。移動は`git diff --cached --summary`でも確認する。コミットIDと残る変更を報告する。

## 6. 改訂履歴

| Version | 日付 | 内容 |
| --- | --- | --- |
| v0.1 | 2026-10-11 | 統合後の配置、正本・履歴の扱い、実行資産保護、追加時の確認手順を明文化 |
