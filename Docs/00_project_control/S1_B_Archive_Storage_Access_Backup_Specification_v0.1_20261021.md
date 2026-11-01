# S1-B Evidence Archive保全方式・実施前ゲート v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| プロジェクト | 定型メール作成ツール（Excel VBA + Classic Outlook） |
| 作成日 | 2026-10-21 |
| Version | v0.1 |
| Status | **G1 BASIC POLICY ACCEPTED / PHYSICAL CONTROLS PENDING** |
| 対象 | S1-B：Raw Evidence／Source Export／実行Workbook候補の非公開保全 |
| 根拠 | 2026-10-21 S1-A Codex報告、S0棚卸し、S1計画 v0.1 |
| 対象外 | S1-CのManifest改訂、S2/S3正式Closure、Baseline・Registry更新、Git履歴の修正／Push |

> G1の**基本方針**はユーザー承認済み。実在するディレクトリのアクセス権やバックアップ先は未検証であり、G2（保全成功）の承認を先取りしない。

## 2. S1-Aからの確定事項とEvidence限界

- GitHub RepositoryのVisibilityは**Public**。調査時、Remote公開`main`は`edf5c5175b103e250144341071d885a3a992c65f`で、対象P2-04 Rawはそのツリーに未掲載。一方、ローカル`main` HEADは`d49d8c7c63379ac69cf0df40c1f16a89342d23e7`で、P2-04 RawはローカルでGit追跡済み。公開履歴・別ブランチ・Fork等の曝露全体は未証明。
- 個人ユーザーパス6か所がP2-04 Rawに存在するとのS1-A調査結果。**該当履歴のPush、Branch／Tag Push、force-push、PRによる公開等はすべて禁止**。削除・履歴改変もCodexへ許可しない。
- 必須原本5件はS1-A時点でS0とハッシュ・サイズ一致。今後のコピー時点でも再照合する。
- 実行Workbook候補は**現在の現物ハッシュ一致**がFILE_VERIFIED。当時の実行日時・Compile・VBAProject全体一致はUSER_ATTESTED／UNVERIFIEDの限界を保持する。
- 外部開発用OneDriveフォルダは、別主体へのRead/Execute許可が観測されており、所有者限定の正式Archiveとは認定しない。同期・Version履歴・復元・Backupも未確認。

## 3. 保全アーキテクチャと場所

### 3.1 Archive識別子（提案）

- **Archive Set ID**: `ARC-MG-P2-I12-20261018`（新設する識別子。既存Manifestの`E-`系IDは変更しない）。
- **Primary Root候補**: `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\P2_I12_20261018\`
- **Backup Root**: ユーザーが指定する**別物理媒体**の暗号化済みローカルドライブ上の`MailGenerator\P2_I12_20261018\`。例として`<BACKUP_DRIVE>:\PrivateEvidenceBackup\MailGenerator\P2_I12_20261018\`と表記する。`<BACKUP_DRIVE>`は仮置きであり、Codexが任意のドライブへ自動決定しない。
- **開発用コピー元**: S1-Aで確認された外部開発用OneDriveフォルダ（DEV）。保全先・Git Repositoryとは別。

推奨配置：

```text
Primary Root (Repo外 / OneDrive同期外)
├─ originals/
│  ├─ 261018_P2-02_Regression Log.txt
│  ├─ 261018_P2-03_Regression Log.txt
│  ├─ 261018_P2-04_Regression Log.txt
│  ├─ P2-04_Regression_20261018.zip
│  └─ MailGeneratorNew.xlsm
└─ Archive_Index_Private.md   ← 正本・バックアップ・権限・検証記録（非公開）

Backup Root (別の暗号化媒体)
├─ originals/                   ← 上記5件の同一コピー
└─ Archive_Index_Private.md    ← Primary完成後、最終Indexを別媒体にも保全
```

**Primary Rootの絶対パス確定とBackup媒体の識別は実行直前に必要**。両方のRootがGit配下／Git管理対象／Web共有配下／クラウド同期配下でないことを確認。シンボリックリンク・Junction等のReparsePointにより別の場所へ解決される場合は停止。

### 3.2 Gitに置くもの

S1-Bでは**何も置かない**。S1-Cの既存Manifest改訂で、Archive Set ID、論理Evidence ID、SHA-256、Byte Size、保管レベルなど機微でないメタデータのみ採用検討する。絶対パス・Windowsアカウント名・ドライブ識別の詳細・接続手段・秘密情報はPublic Gitへ書かない。

## 4. 必須保全対象（5件）

| ID | DEV内ファイル名 | Byte | SHA-256（S1-A確認値） |
|---|---|---:|---|
| E-P202-RAW | `261018_P2-02_Regression Log.txt` | 11,170 | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` |
| E-P203-RAW | `261018_P2-03_Regression Log.txt` | 4,131 | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` |
| E-P204-RAW | `261018_P2-04_Regression Log.txt` | 19,812 | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` |
| E-P204-SOURCE | `P2-04_Regression_20261018.zip` | 25,325 | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` |
| E-P204-WB | `MailGeneratorNew.xlsm` **（外部DEV版のみ）** | 1,003,775 | `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` |

禁止：Repositoryルートの古い`MailGeneratorNew.xlsm`（SHAが異なる）を代替使用すること、ZIP解凍、Workbook起動、原本内容の修正・マスキング。

## 5. アクセス制御の定義

### 5.1 許容する主体

最小限の許可主体：

- **現在のWindows実行ユーザー**：Primary/Backupの読み書き・管理。
- **NT AUTHORITY\\SYSTEM**：OS管理上必要なアクセス。
- **BUILTIN\\Administrators**：管理者アクセス（完全な本人専用とは主張しない）。

上記以外の主体への明示的または継承された広範なRead/Write Allow（`Everyone`、`Users`、`Authenticated Users`等を含む）は原則不可。実際に許す管理主体が追加で必要ならユーザー個別承認。アクセス制御エントリだけでなく継承・共有設定を確認する。

- Primary候補の**親**と作成する**子**のNTFS ACLを検査する。親に広範な権限がある場合、Codexは親のACLを変更せず停止。
- **既存フォルダのACLを勝手に変更しない**。ACL設定が必要な場合は、新規Archiveフォルダだけを対象とする別途承認された操作として切り分ける。
- 設定を実施せず条件を満たせなければ`ACCESS_CONTROL_NOT_VERIFIED`で停止。ACLに関する権限確認だけでネットワーク共有・バックアップ・改変不能性を保証したことにしない。
- Private Rootのフルパス、アカウント名、ACLの主体名の生値はPublic Git・公開報告へ記載しない。Codexチャット報告は必要な範囲でマスク。

### 5.2 暗号化とBackup媒体

- バックアップは**Primaryとは異なる物理媒体**であり、BitLocker To Go等の**有効なディスク暗号化**を条件とする。
- 別ドライブ文字でも同一物理ディスクなら独立バックアップと認定しない。
- 暗号化状態・使用媒体・Rootの非共有性は実際に確認。確認不能なら`BACKUP_PROTECTION_UNKNOWN`とし、完了扱いにしない。
- 可能ならバックアップ後は安全に取り外してオフライン保管。媒体を常時接続したままの場合、ランサムウェアや操作ミスからの独立性は限定的。
- 暗号化解除キーはOS標準手段で**別途安全に保管**する。Codexへ回復キー、パスワード、トークンを入力・収集・表示させない。

## 6. コピー・照合・復元手順

### G1-B：実行前チェック（Fail Closed）

1. ユーザーによるPrimary Root絶対パス、Backup Root絶対パス、Backup媒体、必要主体の指定を確認する。未指定なら**PRECHECKのみ**で停止する。
2. `git status`・HEADを読み取り、Public Repositoryを変更しないことを確認。
3. 既知のDEV5件を個別に検出し、ファイル種類、Byte数、SHAを表と照合。**いずれか不一致ならコピーを開始しない**。
4. Primary・BackupのRootと親ディレクトリを評価し、Repository内、OneDrive同期内、共有・ReparsePoint、ACL過剰許可、同一物理媒体の疑いがある場合は停止。
5. 暗号化・復元に必要な媒体アクセスを確認。確認できないときは新規コピーを開始せず、必要なユーザー操作を報告。
6. 既存同名ファイルを上書きしないことを確認。既存フォルダの再利用はユーザーの明示許可が必要。

### S1-B実行（G1-B PASS後のみ）

1. 承認済みのPrimary新規フォルダを作成。作成後の実効ACLを再確認。規則外なら**コピー前に停止**。
2. 5件を`Copy-Item -LiteralPath`相当の**バイト単位コピー**でPrimary `originals`へコピー。元ファイルは移動・削除・編集しない。
3. コピー後、Primary5件のByte/SHAを再計算して各原本と照合。1件でも違えば**`FAILED`**。不一致コピーを上書き修復せず報告。
4. Backup側でも新規フォルダ・ACL・別媒体暗号化を再チェック。5件をPrimaryからBackupへコピーし、Byte/SHAを照合。
5. 独立した一時Restore TestフォルダにBackupの5件をコピーしてSHA検証。テスト中は原本・Primary・Backupを編集しない。テスト専用ディレクトリのみ、全検証成功後に限定して片付け可。
6. Restoreの実施方法とRecovery Keyの保管責任（キー**自体は記録しない**）を確認する。
7. Private IndexにEvidence ID、元名、SHA、サイズ、Archive Set ID、実保管先、コピー／復元検証日時、権限の確認結果、Evidence確度、保留事項を記録。Private IndexもBackupにコピー・照合する。
8. GitのHEAD/Working Treeを作業前後で比較し、改変がないことを確認。**Commit、Push、Fetch、Pull、Reset、履歴変更を禁止**。

### 復元方法（将来の事故時）

1. 保存していたBackup媒体をユーザーが接続・解錠する。Codexは回復キー・パスワードを取得しない。
2. `Archive_Index_Private.md`でArchive Set IDと対象Evidence ID/SHAを確認する。
3. 復元先は**新規・隔離された、非共有の復元用ディレクトリ**とし、開発用DEV、Git、Primary正本へ**直接上書きしない**。
4. バックアップから復元先へ必要ファイルをコピーし、Index記載Byte/SHAと照合する。不一致は失敗として停止。
5. Userが復元データの受入れを承認して初めて、必要な作業用コピーへ引き渡す。Primaryの修復や古い原本の削除は別作業とする。

## 7. 完了区分と停止条件

| 判定 | 条件 |
|---|---|
| `PRECHECK_BLOCKED` | パス・許可主体・別媒体・暗号化・ACL・元SHAのいずれか未確定／不一致。**コピーなし** |
| `PRIMARY_VERIFIED / S1-B INCOMPLETE` | Primary5件のコピー・SHA一致までは完了、BackupまたはRestore未完了。G2未承認。例外的な中断状態のみ。 |
| `FAILED` | コピー・SHA・復元のいずれか不一致、または規則外の操作。原因と影響範囲を報告。 |
| `S1-B TECHNICAL PASS / G2 REVIEW PENDING` | Primary5件・Backup5件・Restore5件のHash一致、ACLと暗号化確認、Private Index整備、Git無変更。**ユーザーG2承認は別**。 |
| `S1-B ACCEPTED` | G2にてユーザーが上記結果を確認・承認。S1-Cを自動開始しない。 |

Hard Stop: Path/ACL/共有範囲UNKNOWN、別媒体の独立性・暗号化不明、Raw SHA相違、Workbook SHA不一致、同名衝突、ReparsePoint、Git操作要求、原本編集・開封が必要になった場合。

## 8. G1決定追跡（基本承認と未確認を区別）

| ID | G1基本方針 | 実行時の未完了条件 |
|---|---|---|
| D-S1-01 | Repo外専用Archiveを採用 | 実パスの確定とRepo/同期外の実物確認 |
| D-S1-02 | 最小権限 | Primary/Backupの実効ACLと共有範囲を検証 |
| D-S1-03 | 必須5件 | コピー前後のサイズ・SHAを検証 |
| D-S1-04 | Workbook保全用を開発用と分離 | 正しいWorkbook SHA照合、未起動・未修正 |
| D-S1-05 | Gitには安全なManifestだけ | S1-B Git更新ゼロ、Public共有派生版なし |
| D-S1-06 | ユーザー承認、Codex実施補助 | 実施結果のG2 Reviewをユーザーが担当 |
| D-S1-07 | Archive新規コピーのみ／S1-C別 | S1-BでRepo/既存資料無変更、Git無操作 |
| D-S1-08 | 機微履歴Pushを禁止 | 継続禁止。削除や履歴書換えも別承認 |

## 9. Codexが報告するEvidence

- 5件の原本SHA/サイズ一致、PrimaryコピーSHA/サイズ一致、Backup SHA/サイズ一致、Restore SHA/サイズ一致のマトリクス。
- Archive Set ID、Primary/Backupルート**匿名化識別子**、Backup媒体の独立性・暗号化検証（秘密値は出さない）。
- ACL・共有・同期・ReparsePoint確認結果と、未検証の限界。
- Private Indexの存在・Checksum、原本未変更とGit Working Tree無変更の確認。
- `S1-B TECHNICAL PASS / G2 REVIEW PENDING`または停止状態と理由。S1-Cへ進むための不足事項。

## まとめ / Summary

**日本語：** S1-Bは、Public Gitから原本を分離し、非公開Primaryと暗号化済み別媒体Backupへ5件を保全し、SHAと復元確認を行う。権限・保存先が未確認なら止める。G2承認後に初めてS1-Cへ進める。

**English:** S1-B keeps five evidence files outside public Git. It uses a private primary archive and an encrypted backup on another device. Check hashes, access, and restore. Stop if any key condition is unknown. S1-C starts only after G2 approval.
