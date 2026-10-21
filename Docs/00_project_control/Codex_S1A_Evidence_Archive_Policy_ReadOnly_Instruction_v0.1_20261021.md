# Codex作業指示：S1-A Evidence Archive方針・公開リスク調査（Read-only） v0.1

## 0. 作業の位置づけ

プロジェクト：定型メール作成ツール（Excel VBA + Classic Outlook）
対象：`S1-A`のみ。S0の棚卸し結果を踏まえ、S1-B原本保全とS1-C Manifest改訂の**承認判断材料**を準備する。**この指示ではコピー・新規ファイル作成・編集・正式承認に進まない**。

主要参照資料（読める範囲でRepository現物を優先）：

- `Docs/00_project_control/P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md`
- `S0_P2_Artifact_Evidence_Inventory_Summary_v0.1_20261021.md`（与えられていなければS0原報告を使用。存在しないからといって作成しない）
- `AGENTS.md`
- `Docs/00_project_control/rules/Folder_Management_Rules.md`（S0ではv0.2）
- `Docs/00_project_control/rules/AI協働開発 文書管理・Baseline運用ルール.md`
- `Docs/03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`
- `Docs/03_verification/technical_validation/P2-04_Regression_Build_Provenance_Verification_v0.4_Draft.md`
- `Docs/00_project_control/P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md`

## 1. 絶対制約（Read-only）

1. Repository、作業フォルダ、原本ファイル、Workbook、OFT、ZIP、Gitの状態を変更しない。新規ファイル作成、コピー、移動、削除、リネーム、ZIP展開保存、属性変更、アクセス権変更、ログのマスク・編集は禁止。
2. Commit、Push、Fetch、Pull、Checkout、Reset、Restore、Clean、Branch/PR作成、Git履歴の改変は禁止。`git status`、`git log`、`git ls-files`、`git show`、ハッシュ計算、Read-onlyファイル確認は可。
3. Workbook/Excel、Classic Outlook、VBA、Regression Test、Compileは実行しない。原文ログの読取りは認めるが、内容は個人パス・機密を含む可能性があるため**レポートには抜粋しない**。
4. Remote visibilityは、権限ある読み取り専用の方法で調べられる場合だけ確認する。`git remote -v`だけからPublic/Privateを推定しない。認証が必要な場合は新たな認証操作をしない。URL/トークンを全文出力しない。
5. 原本・Workbook・ZIPを外部サービスにアップロードしない。ログ全文をチャットへ貼り付けない。機微性の調査は「カテゴリーと件数または有無」だけを報告する。
6. レポートは**Codexチャット内のMarkdownのみ**。ファイル作成やPull Requestは行わない。指示書内の事項と既存Repository規則が衝突する場合は、変更を止めて衝突内容を報告する。

## 2. S0で確認されている基礎事実（再検証して変更しない）

- S0時点のローカルRepo：`main`、HEAD `d49d8c7c63379ac69cf0df40c1f16a89342d23e7`、Working Tree Clean。現在も同じとは決めつけず開始/終了時点を記録。
- Raw 3件（P2-02、P2-03、P2-04）、Production Source export ZIP、申告SHAに一致する外部Workbook現物がRepo外でFILE_VERIFIED。
- `Evidence/P2-04/2026-10-18/P2-04_Regression_20261018_Raw.txt`は**既にGit追跡済み**。この内容に個人パス等が存在する可能性があり、Repository公開状態はS0で未確認。
- 9 Production SourceはSource ZIPと正規化全文一致9/9。ただし元バイト9/9不一致、Workbook VBAProject全体未検証。
- P2-02=111/111、P2-03=46/46、P2-04=182/182、I12=TECHNICAL PASS/REVIEWED。S1-Aで新たなPASS/正式Closureを宣言しない。

## 3. 実施作業

### A01｜現状・規則

Repository root、ブランチ、HEAD、Working Treeを読み取り確認。Folder Management Rules v0.2、AGENTS.md、既存Manifestの規則を把握し、既存の正規Evidence配置/Version管理/アクセスの扱いを短く要約する。

### A02｜Repository Visibilityと既存Rawの公開リスク

Git追跡済みP2-04 Rawが現在のHEADで存在するか、いつから追跡されているかを読取りで確認する。Remoteの種別（例：GitHub）と現在の公開区分を**実際に確かめられる場合だけ**記録。共有先/アクセス制御も確認できた範囲のみ記録。

Rawおよび関連Manifestの機微性を、`個人ユーザーパス / メール・氏名 / 社内固有名 / 認証情報・秘密 / その他`のカテゴリー単位で報告。原文値は表示しない。

公開状態と内容の双方から対処の必要性を検討し、公開曝露の可能性がある場合、対応をユーザー決裁事項として最優先に報告する。**既存Rawの削除、Git履歴改変、force-push等は絶対にしない**。

### A03｜Evidence現物とChecksum

対象の現物、サイズ、SHA-256、重複関係、取得元を限定された既知のフォルダ内で確認し、S0との一致/相違を報告する。

必須候補：
- `261018_P2-02_Regression Log.txt`
- `261018_P2-03_Regression Log.txt`
- `261018_P2-04_Regression Log.txt`
- `P2-04_Regression_20261018.zip`
- S0でSHA一致が見つかった**Repository外の**`MailGeneratorNew.xlsm`
- 既存Repo追跡済みP2-04 Raw

補助候補：Review Package ZIP 2件、`IF-P2-05-001 ... v0.7.md`、限定検索で未発見のZIP 2件。未発見のものは `NOT LOCATED` とし、紛失とは断定しない。巨大な個人フォルダの再帰探索は行わない。

### A04｜Archive候補・機密区分

以下の最小案を基準に、Repo内保管・Repo外非公開保管・公開用マスク版の利点/リスクを整理する。

- Original Raw 3件/Source ZIP/Workbookは**Repo外のアクセス制限可能なArchive**へ保全する案を優先。
- 元の開発用OneDriveフォルダは作業フォルダであり、共有設定・同期競合・復元・バックアップを確認せず正式Archiveとはみなさない。
- Repoには原則**機微なフルパス等を含まないManifestと参照**だけを記録。公開用マスク版は明確な共有要件がある場合だけ作る。
- Workbook保全コピーは今後の作業用Workbookから分け、開かない・編集しない運用を提案。

確認できないセキュリティ/権限事項は `UNKNOWN` とする。

### A05｜既存Manifestとの差分とS1-B/C案

`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`を読取り、`Evidence Logical ID / Run・用途 / Source original / Original SHA / Archive SHA / Size / Private locator（公開文書は抽象参照のみ） / Visibility /取得・確認日時 / 確度 / Historical limitation / Derived copies`の各情報がどこまであるかを表にする。

**既存のID体系、版管理規則、配置ルールを優先**し、代替台帳をむやみに提案しない。未発見ZIPはClosureに必須か補助かを確認し、必要性を分類する。

S1-B（承認済み非公開場所への原本の新規コピーと前後SHA照合）、S1-C（既存Manifestの最小改訂と必要に応じてIF-P2-05-001参照整備）の作業一覧を、**実行をせずに**提示する。

### A06｜ユーザー決裁待ち事項と推奨案

次の8点を`推奨案 / 根拠 / 未確認事項 / 承認が必要な理由`で提出する。

1. 正式な原本Archiveの絶対保存先
2. 実際の公開・共有範囲とアクセス可能者
3. 必須保管対象と補助ZIPの扱い
4. SHA一致Workbookの保全用スナップショット方式
5. Git ManifestのLocator粒度とマスク版要否
6. 作業責任者/技術レビュー担当/承認者
7. S1-B/Cのファイル操作許可範囲、Commit/Pushの別承認
8. 既存Git追跡済みP2-04 Rawへの対処方針

## 4. 出力フォーマット（チャット内Markdown）

1. `S1-A Executive Result`（Read-only完了/未完了、S1-B/C実施可否）
2. `Repository & Access Snapshot`（根拠とUNKNOWNを明示）
3. `Sensitive Data Exposure Risk`（**原文値は出さず**カテゴリと判定）
4. `Evidence Inventory & Hash Comparison`（SHA、Size、所在は個人名をマスク）
5. `Storage Options & Recommended Policy`（現状維持/Repo外Archive/公開マスク派生版を比較）
6. `Manifest Gap Matrix`（既存Manifestに対する変更が必要な列・行）
7. `Decision Request D-S1-01～08`（ユーザーが承認すべき具体値と未決事項）
8. `S1-B/C Minimal Execution Package`（許可が得られた場合に限る別作業）
9. `Risk / Stop Conditions`（機密公開、Checksum不一致、上書き衝突、権限不明）
10. `Read-only Compliance`（開始/終了HEADとWorking Tree差分、実施しなかった操作）

各項目の根拠を `REPO_VERIFIED / FILE_VERIFIED / USER_ATTESTED / HANDOFF_ONLY / UNVERIFIED` に分類する。「確認不能」を「問題なし」に読み替えない。

## 5. 完了条件と停止指示

- 原本の候補・重複・既存Git Rawの扱い・公開リスクと、保管方式の推奨を比較できた。
- Manifest改訂に必要な最低限の情報と、具体的な承認待ち事項を提示した。
- S1-B/Cで予定するファイル操作の**実行対象・保存先・禁止範囲**を提案できた。
- ファイル・Git・Workbook・原文を一切変更せず、レポートのみをチャットに出力した。

**S1-Aレポートを出したら停止。S1-B/Cのコピー、Manifestの変更、Git Commit/Push、Regression Closure、Baseline更新には着手しないでください。**

## まとめ / Summary

**日本語：** S1-AはEvidence保管の設計審査。リスク・推奨方式・承認候補をRead-onlyで提出し、実ファイル操作の前に必ず停止する。

**English:** S1-A reviews the evidence storage plan without changes. Report risks, options, and decisions. Stop before copying or editing any files.
