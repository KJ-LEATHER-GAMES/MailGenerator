# S1 Evidence Archive・Provenance確定 実施計画 v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール（Excel VBA + Classic Outlook） |
| 作成日 | 2026-10-21 |
| Version | v0.1 |
| Status | **DRAFT / APPROVAL PENDING** |
| 対象工程 | S1（S0 Inventory Complete後、S2/S3正式Closure前） |
| 上位計画 | `P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md` |
| 主な根拠 | `S0_P2_Artifact_Evidence_Inventory_Summary_v0.1_20261021.md`、Codex S0原報告、既存Archive Manifest v0.1 Draft |
| 推奨配置 | `Docs/00_project_control/`（実際のFolder Management Rules v0.2に従い最終確定） |

> 本書は実施**案**。S1 Archiveの承認・実行・Registry変更は未実施。S0で観察された事実を元にしているが、ここでGitHubリモートやアクセス権を独立確認したものではない。

## 2. 目的と対象外

**目的**：P2-02、P2-03、P2-04およびI12のRegression Evidenceについて、実在する証拠を、誰が・どこに・どの公開範囲で保存し・どう真正性を確かめ・どの記録から参照するかを確定する。S2/S3正式ClosureがEvidenceを一意に追跡できる状態を作る。

**S1で行わないこと**：Regression再実行、VBA Compile、Production Source/Workbook/OFT編集、S2/S3のClosure承認、Baseline切替・Document RegistryのStatus更新、P2-05 Completion／P2 Phase Exit判定、Git履歴の書換え。

## 3. S0から引き継ぐ確定事項と限界

| Artifact / 論点 | S0時点の評価 | S1での扱い |
|---|---|---|
| P2-02 Raw `261018_P2-02_Regression Log.txt` | FILE_VERIFIED、SHA-256 `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` | 非公開原本を保全・照合 |
| P2-03 Raw `261018_P2-03_Regression Log.txt` | FILE_VERIFIED、SHA-256 `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` | 同上 |
| P2-04 Raw `261018_P2-04_Regression Log.txt` | FILE_VERIFIED、Repo追跡済みRawコピーとSHA一致 | 重複原本の役割・Git公開リスクを特定 |
| `Evidence/P2-04/2026-10-18/P2-04_Regression_20261018_Raw.txt` | REPO_VERIFIED、SHA-256 `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` | **既にGit追跡済み**。削除・履歴書換えを独断で行わない |
| `P2-04_Regression_20261018.zip` | FILE_VERIFIED、SHA-256 `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7`、9 Export | 非公開原本を保全。ZIP=Workbookではない |
| 外部開発用 `MailGeneratorNew.xlsm` | FILE_VERIFIED、SHA-256 `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` | ハッシュ一致現物を保存用スナップショットとして固定。**当時実行の独立証明ではない** |
| Repoルート `MailGeneratorNew.xlsm` | REPO_VERIFIED、SHA-256 `07336d8779f27039822539895c38fc8570c82fefc206ed83fb04672cb091a22e` | 実行Workbookと誤認しない |
| 9 Source照合 | Source ZIPとの正規化全文・文字列9/9一致、バイト一致9/9不成立 | Source/Binaryの検証範囲を維持 |
| `IF-P2-05-001 ... v0.7.md` | FILE_VERIFIED／Repo未登録 | S1の参照整備候補。機微情報検査・配置規則確認後に判断 |
| Evidence ZIP 2件 | 限定探索では未発見／UNVERIFIED | 必須原本と区別し、存在を断定しない |

上記はS0レポートに基づく。「当時使用した9 Source」や「2026-10-10 Compile継続性」は過去のUSER_ATTESTED事項を含む。S1の保管・ハッシュ照合がこれを新たに独立証明するわけではない。

## 4. S1の分割とゲート

```text
S1-A  保管方針案・公開リスク・既存Manifest差分のRead-only確認
  ↓ [G1: ユーザーが保管先 / 公開方針 / 担当者 / 実行範囲を明示承認]
S1-B  承認済み範囲で原本の保全コピー・SHA再照合
  ↓ [G2: コピー一致・アクセス制御・取得可能性を確認]
S1-C  既存Manifestの最小修訂／必要なら参照資料を登録候補化
  ↓ [G3: diffと公開情報の最終レビュー。Commit/Pushは別承認]
S1 完了判定 → S2 P2-02/P2-03 Closure準備へ引き渡し
```

S1-A終了では**方針案**のみ。S1-B/Cを自動開始しない。G1未承認なら作業停止。

## 5. S1-A：Codexに依頼するRead-only調査

| ID | 作業 | 出力 | 合否・停止条件 |
|---|---|---|---|
| A01 | `AGENTS.md`、`Folder_Management_Rules.md v0.2`、既存Archive Manifest・Provenance文書の形式確認 | 既存規則・Manifest差分 | 先行記録を勝手に変更しない |
| A02 | Repository内のGit追跡状況、リモートURL種別、公開状態・共有アクセスの確認可能性を調査 | `CONFIRMED/UNKNOWN`・根拠 | `git remote -v`だけでPublic/Privateは確定しない。トークン等非表示 |
| A03 | 既存P2-04 Rawの機微情報リスクを内容**分類だけ**で点検 | パス/氏名/メール/秘密/社内情報の有無と高リスク論点 | 原文抜粋・本人特定パス・秘密値をレポートへ転記しない |
| A04 | 対象原本の現物・サイズ・SHA・原本コピー・履歴関係を再確認（必要最小限） | Evidenceマトリクス | `NOT FOUND`を紛失と断定しない |
| A05 | 保存候補の権限、同期、復元性、バックアップ確認可能性を調査 | 候補比較・未確認項目 | OneDrive配下という理由だけでPrivate/Immutableとは認定しない |
| A06 | Raw、ZIP、Workbook、マスク派生版、Review ZIP、Finding文書の保管/共有レベルを提案 | 区分案と理由 | 原本をGitに追加しない。Workbook/ZIPを無断公開しない |
| A07 | 既存Archive Manifestの追加・訂正必要事項を列挙 | 行単位の変更提案 | 新規台帳を前提にしない |
| A08 | G1のユーザー承認項目と実行影響を提示 | 意思決定シート・S1-B/Cへの最小指示案 | Read-only終了時に停止 |

### 推奨する保管方式（未承認の推奨案）

- **原本**：Git Repository**外**のアクセス制限可能な非公開Archiveにコピー保全。既存の開発用OneDriveフォルダを正式Archiveにする場合も、共有設定・同期競合・削除復元・バックアップを確認し、作業用と保全用を分ける。
- **参照**：Git内の既存`Docs/03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`を改訂して、Logical ID、SHA-256、可視性、Evidence種別・保存識別子を記す。機微な絶対パス・アクセス手段は非公開のArchive内Index／限定された管理情報で保持。
- **公開向け派生版**：外部共有に必要な場合**だけ**原本コピーから生成し、個人パス等をマスク。原本と別名、別SHA、派生関係を記録。マスク前後の意図しないデータ改変に注意。
- **保存の完全性**：コピー前・コピー後SHA-256を照合し、一致結果と実行日を記録。Read-only属性は補助であり、暗号学的改変防止やバックアップの代替ではない。
- **既存Git Raw**：公開状態とRawの機微性を先に確認。仮に公開履歴への機微情報混入が見つかっても**S1で勝手に削除・force-push・履歴改変しない**。ユーザーへ影響・対応選択肢をエスカレーションする。

## 6. G1：ユーザーの正式決定事項

| Decision ID | 決定項目 | 選択肢・推奨初期案 | 承認前状態 |
|---|---|---|---|
| D-S1-01 | 正規原本Archiveの**絶対配置先** | Repository外・非公開・復元可能な場所（初期推奨） | 未決定 |
| D-S1-02 | Archiveのアクセス主体・共有/公開範囲 | 所有者等に最小限限定。対象Git RepositoryのVisibilityも別途確認 | 未決定 |
| D-S1-03 | 原本の保存範囲 | 最小必須：Raw 3件、Source ZIP、SHA一致Workbook候補。Repo既存Rawは参照を整備。Review ZIPは必要性評価 | 未決定 |
| D-S1-04 | Workbookの保全方式 | 開発用から保全用スナップショットをコピーし、SHAを固定。今後は作業用コピーを編集 | 未決定 |
| D-S1-05 | Manifestへ記すLocator粒度と公開版要否 | Gitには機密のないLogical ID / SHA / 限定的Locator、フルパスはPrivate Index。公開マスク版は必要時のみ | 未決定 |
| D-S1-06 | 実行担当・Review/承認担当 | Codex：調査/差分案/承認範囲内のローカル作業、ユーザー：方針/最終確認/承認 | 未決定 |
| D-S1-07 | ファイル作成・Git反映権限 | S1-Bは承認フォルダに**新規コピーのみ**、S1-Cは許可されたManifestのみ編集。Commit/Pushは別承認 | 未決定 |
| D-S1-08 | 既存Git追跡P2-04 Rawの扱い | 現状を調査し、公開リスクがあれば別件として対応判断 | 未決定 |

**承認形式**：実際の保管パス、共有可否、コピー対象、編集可能ファイルを明示し、Codexが推測で決めない。アクセス権・公開状態を確かめられない場合は`UNKNOWN`のまま停止する。

## 7. S1-B：承認後の原本保全（実行計画）

1. 作業前のHEAD、ブランチ、Working Tree、対象原本ファイルのSHAとサイズを記録（現物がS0時点から変わったら停止・報告）。
2. 承認済みの**非公開・Repo外フォルダ**へ、対象を**コピー**。元ファイルは移動・編集・改名・削除しない。
3. 既存保存先ファイルがあれば上書きしない。衝突を報告して停止。保存時は原本名と取得日/Run IDで再現可能に識別。
4. コピー後、原本・保存コピーのSHAを再計算して照合。不一致時は失敗扱いとして即停止、原因・対象を報告。不要な原本複製を無制限に増やさない。
5. コピー先の所有者/共有設定、閲覧方法、復元方針を確認できる範囲で記録。実際に確認できない項目は`UNKNOWN`とする。
6. 保存用WorkbookをExcelで起動しない。以降の開発・Compileは別の作業用コピーで行う。
7. 必要と認めた派生マスク版の作成は、原本保全完了後、**別途承認された場合のみ**行う。

## 8. S1-C：ManifestとEvidenceトレーサビリティ

既存`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`をSource of Truthとし、Versionと履歴を維持して最小修訂案を作る。対象形式・配置・改訂方式はRepository既存規則による。

最低限の行項目：

| 項目 | 意味 |
|---|---|
| Evidence key / Logical ID | 一意の参照名。既存IDがあれば優先 |
| Content / Run / Scope | P2-02 / 03 / 04、Source export、Workbook snapshot等 |
| Original filename | 元名。ただし機微情報なら安全な表示名 |
| Original SHA-256 / Size | 原本の識別（S0値と保存時再照合値を区別） |
| Archive copy SHA-256 | コピー後の一致証拠 |
| Private archive locator | 公開文書には秘密のない識別子だけ。完全な取得場所はアクセス制限したPrivate Index |
| Evidence certainty | `REPO_VERIFIED` / `FILE_VERIFIED` / `USER_ATTESTED` 等 |
| Visibility / Access control | 非公開等。未確認は`UNKNOWN` |
| Verified at / Verified by | S0検証日時とS1コピー検証日時を混同しない |
| Historical limitations | Compile継続性、9/9正規化一致、当時のWorkbook実行時点の未証明等 |
| Derived / Related evidence | マスク版・Repoコピー・Review Packageとの関係 |

- P2-02の111件、P2-03の46件、P2-04の182件、I12技術PASSは**既存技術記録の評価**として保持する（S1で新たにPASSを付け直さない）。
- I10初回ABORT、P2-02 Bootstrap重複、P2-04旧I01/I02、P2-03テーブル復元限界はClosure前の参照時に意味が失われないようにする。
- `IF-P2-05-001 ... v0.7.md`のRepository登録は、可視性・正本・配置ルール確認後に最小変更候補として提案。`OBS-P2-05-002`をCLOSEDにしない。
- Document Registry / Project Overview / Baseline statusは**S4以降**の専用Gateに残す。

## 9. S1 Done When（S2への受け渡し条件）

- [ ] G1：D-S1-01～08をユーザーが明示承認（該当事項が不要なら理由とN/Aを記録）。
- [ ] 原本Raw 3件、Source ZIP、保全対象Workbookの保管先が確定し、**原本とArchiveコピーのSHA一致**が記録された。
- [ ] Repositoryに既にあるP2-04 Rawの可視性・取扱い方針を記録した（公開漏えい懸念があれば別判断にエスカレーション）。
- [ ] 非公開Archiveの取得手順、所有者・アクセス制御・復元方針が確認済み、または未確認事項がClosureを妨げるか評価済み。
- [ ] Existing Archive Manifestの必要改訂案と、関連Recordの参照方法が一意に定まった。承認を要する差分は承認前に正式版と称しない。
- [ ] 既存Raw／Workbook／Sourceは無変更。Git履歴・Remote無変更。Commit/Pushなし（別途承認があればその時点の作業で判断）。
- [ ] 原本未発見のZIPは必要性を評価して`NOT LOCATED / NON-BLOCKING候補`等と根拠付きで分類し、存在を捏造しない。
- [ ] S2へ「対象Evidence ID、SHA、参照先、確度、制約、未解決事項」を引渡せる。

**重要**：S1完了は、P2-02/03 Closure、I12/P2-04 Closure、P2-05 COMPLETE、Formal MVP Test PASSを意味しない。

## 10. 直近アクション

**次に実施するのは S1-A のみ**。CodexにRead-onlyで方針比較・リスク確認・承認候補を提出させ、ユーザーがG1を判断する。保管コピー／Manifest編集／Git登録は、G1決定後にS1-B/Cの個別指示で行う。

## まとめ / Summary

**日本語：** S1は非公開原本保全と証拠参照の確定工程。まずS1-Aで方針案を読み取り専用で作り、ユーザー承認後にコピー照合とManifest改訂を実施する。正式ClosureはS2以降。

**English:** S1 sets the private evidence archive and clear evidence links. First, review options without changes. After approval, copy and verify files, then update the manifest. Formal closure comes later.
