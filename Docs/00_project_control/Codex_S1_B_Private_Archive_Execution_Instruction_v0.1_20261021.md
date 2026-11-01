# Codex実行指示：S1-B Private Evidence Archive保全 v0.1

## 0. 作業モードと許可境界

**Project**: Mail_Generator / P2 Regression Closure  
**Stage**: S1-Bのみ。S1-Aは完了、G1の基本方針はユーザー承認済み。  
**初期モード**: `PRECHECK_ONLY`。以下「実行許可の条件」が満たされない場合は、候補調査と停止理由の報告だけで終える。  
**禁止**: GitのPush（Branch/Tag/force-push/PRを含む）・Fetch/Pull・Commit/Add・履歴改変・既存履歴の削除。GitHub Public、ローカル追跡P2-04 Rawを前提とし、独断で公開しない。

### 目的

Raw Regressionログ3件、Production Source ZIP1件、実行Workbook候補1件の**5原本**を、Public Repository外のPrimary Archiveと別物理媒体の暗号化Backupに保全する。原本→Primary→Backup→RestoreのSHA-256・Byteサイズ一致、NTFSアクセス権・共有状態、Git無変更を確認する。

この作業は**S2/S3正式Closure、S1-C Manifest改訂、VBA Compile、Regression実行、BL-MVP-004適用ではない**。Indexへの検証記録を除き、証拠内容やVBA資産は変更しない。

## 1. 入力資料・作業対象

1. `AGENTS.md`と`Docs/00_project_control/rules/Folder_Management_Rules.md`。
2. S1-A Codex調査報告、`S1_B_Archive_Storage_Access_Backup_Specification_v0.1_20261021.md`（利用可能なら）。
3. `Docs/03_verification/technical_validation/P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`（**読み取りのみ**）。
4. S0/S1-Aで確認した外部開発フォルダ（DEV）。個人名をチャットへ出さない。
5. 現在のGitのHEADとWorking Tree（読み取りのみ）。S1-A時点HEAD `d49d8c7c63379ac69cf0df40c1f16a89342d23e7` は比較用であり、現在値を決め打ちしない。

**G1基本方針**: Repo外非公開Archive、必要最小限の権限、必須5件、実行Workbook保全、Gitには後日安全なManifestのみ、Codex作業・ユーザー承認、S1-B新規コピー限定、Git履歴Push禁止。

## 2. 実行パラメータ（実地確認・ユーザー承認を要する）

| パラメータ | 初期値・条件 |
|---|---|
| `ARCHIVE_SET_ID` | `ARC-MG-P2-I12-20261018` |
| `PRIMARY_ROOT_CANDIDATE` | `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\P2_I12_20261018\` |
| `APPROVED_PRIMARY_ROOT` | 上記を展開した**実際の絶対パス**。ユーザーによる配置承認とPrecheck PASSが必要 |
| `APPROVED_BACKUP_ROOT` | **未入力**。ユーザー指定の別物理媒体・暗号化済みドライブ上の絶対パス。Codexがドライブ文字を推測しない |
| `APPROVED_ACCESS_PRINCIPALS` | 現在の実行Windowsユーザー、SYSTEM、Administrators。それ以外は別承認 |
| `ALLOW_ACL_MODIFICATION` | **false**。親や既存フォルダのACL変更は禁止。必要になれば停止し別承認を受ける |
| `ALLOW_EXISTING_ARCHIVE_REUSE` | **false**。上書き・既存保管セットの流用は禁止 |
| `ALLOW_GIT_WRITE` | **false**（履歴Pushは継続禁止） |

**実行許可の条件**：Primary実パス、Backup実パス、BackUp媒体、暗号化、必要なACL主体をユーザー承認でき、Codexが独立に検証できた場合に限り、`EXECUTE_ARCHIVE`へ移行可。現在の会話で**Backup実パスは指定されていない**ため、単にこの指示を実行しただけではコピーに進んではならない。未指定なら候補と不足情報だけを報告して停止。

Codexが必要情報を自動で推定して既成事実化すること、承認未確認なのに`EXECUTE_ARCHIVE`を選ぶことは禁止。

## 3. 固定Evidence一覧（ファイル名・サイズ・SHA）

| ID | 外部DEV内ファイル名 | Bytes | SHA-256 |
|---|---|---:|---|
| E-P202-RAW | `261018_P2-02_Regression Log.txt` | 11170 | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` |
| E-P203-RAW | `261018_P2-03_Regression Log.txt` | 4131 | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` |
| E-P204-RAW | `261018_P2-04_Regression Log.txt` | 19812 | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` |
| E-P204-SOURCE | `P2-04_Regression_20261018.zip` | 25325 | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` |
| E-P204-WB | `MailGeneratorNew.xlsm`（**外部DEVのSHA一致版**） | 1003775 | `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` |

DEVの場所はS1-Aで確認した外部OneDrive開発フォルダ。必ず**上記SHA**でSourceを特定する。Repository Rootの同名Workbookは別物なので対象外。ファイルの欠落やハッシュ相違時は他候補を勝手に代用せず停止。

## 4. Precheck（すべてRead-only）

実際に何を確認したか、結論と根拠を記録すること。

1. 既存Repositoryの`git status --porcelain`、branch、HEADを確認。**変更操作はしない**。
2. 5件それぞれの存在、`Get-Item`等によるByte数、`Get-FileHash -Algorithm SHA256`によるHashを照合。**一件でも差があればコピー前に停止**。
3. 候補Primary/Backupについて`Resolve-Path`／`Get-Item`等を使い、祖先パスのReparsePoint、OneDrive等同期配下、公開共有、Git Repository配下、相互包含を調査。**候補が存在しない場合は親を確認**。安全を断定できなければ停止。
4. Windowsの`Get-Acl`/`icacls`等で祖先・対象Rootの明示・継承ACLを調査。`Everyone`、`Users`、`Authenticated Users`、未承認主体への広いRead/Writeアクセスが残る、または権限が不明な場合は停止。管理者・SYSTEMが読めることは仕様上許容、個人専用の完全隔離と表現しない。
5. Backupドライブが**Primaryとは別物理媒体**か確認。ドライブ文字・別パーティションだけで独立と認定しない。BitLocker等の暗号化**有効状態**を確認。復旧キー・パスワードは取得・表示しない。暗号化や物理独立性が確認できなければ停止。
6. Backupの共有・ACLも確認。本人や承認管理主体以外のRead許可が確認されたら停止。
7. 作成予定先に同名ファイル／予期しない既存データがないことを確認。存在したら**上書きせず停止**。既存Archiveの再利用も許可されていない。
8. バックアップ媒体の空き容量、書込み可否を確認。秘密値・個人名を公開報告に載せない。

**重要**：`New-Item`、`Copy-Item`、`Set-Acl`、`icacls /grant|/remove`、`git add|commit|push`など、状態変更操作はPrecheckでは実施しない。

## 5. 条件を満たした場合だけS1-Bコピー

`EXECUTE_ARCHIVE`としての明示許可があり、Precheckが全PASSのときだけ以下を順に実施する。

1. ユーザー承認Rootのみに必要な新規ディレクトリ（`originals`を含む）を作成。既存ファイルの移動・編集・削除・上書き、既存親のACL変更は禁止。作成後のACLを再検査し、不適合なら**原本コピー前に停止**。ACLが不適合なら勝手に権限変更せず報告。
2. DEV5件を`Copy-Item -LiteralPath`等でPrimaryの`originals`へ**コピー**。ZIPの展開は禁止。Workbookは起動しない。全コピーで既存同名があれば上書き禁止。
3. Primaryで5件のByte数・SHA-256を計算し、元の5件・固定表と照合。1件でも違えば停止し`FAILED`。不一致コピーの無断削除・上書き修復は禁止。
4. 別媒体Backupに新規の`originals`を用意。暗号化・実効ACLを再確認し、Primaryから5件を新規コピー。Backup5件のHash/Size照合。
5. **実復元試験**：ユーザーに秘密キーを提出させることなく、暗号化済みBackupを通常の認証手順でマウント。バックアップ5件を専用の新規一時フォルダ（Git/DEV/Archive外）へコピーして復元先のHash/Sizeを照合。Primary・Backupの既存ファイルへ上書きしない。成功後、**この実行で作成した一時テストフォルダだけ**削除可。削除対象パスを厳密照合し、不確かなら残して報告。
6. Primaryの`Archive_Index_Private.md`を作成し、Archive Set ID、Evidence ID、SHA、Size、Original/Primary/Backupの関係、確認日時、確認者、ACL・暗号化・物理独立性・Restore Test結果、証拠確度／残留限界を記録。Index自体は**Public Repo外**でのみ保持し、Backupへコピーして両方のSHAを記録。
7. 元ファイルのサイズ・Hashを作業終了時にも再確認（ユーザー申告の過去実行情報の独立証明に格上げしない）。RepositoryのHEAD/Working Treeが作業前と同一か照合。

コピーや復元の途中で停止した場合は、その時点の作成先・成功件数・失敗条件を報告し、**S1-B COMPLETEと表示しない**。既存ファイル・証拠を勝手に整理・消去しない。

## 6. 明示的な禁止事項

- `git add`/`commit`/`push`/`fetch`/`pull`/`rebase`/`reset`/`clean`、force-push、branch/tagのremote更新、PR作成、Git履歴の変更。
- Repository内の`Evidence`、`Docs`、`src`、Workbook/OFT、既存Manifest、Document Registry、Project Overviewの作成・編集・削除。
- Raw/ZIP/Workbookの元ファイルの移動・編集・削除・上書き、Excel/Outlook起動、VBA実行、ZIP展開。
- ファイル内容のログや秘密値をチャットへ貼ること。絶対ユーザーパス・認証情報の公開。
- ネットワークアップロード、外部共有リンク作成、公開版作成、履歴の秘匿操作。
- ACL不適合状態での「一時的な」原本コピー、暗号化不明媒体へのバックアップ、別パーティションだけを独立媒体扱いすること。
- S1-C、S2/S3 Closure、P2-05/CP-P2の判断。

## 7. Codex報告形式（Markdown、チャット内のみ）

### A. Precheck & Approval Gate

| 観点 | 判定 | 根拠・未確認事項 |
|---|---|---|
| Primary実パス承認 | PASS / BLOCKED | ユーザー名は伏せる |
| Backup実パス／別媒体 | PASS / BLOCKED | ドライブ識別は公開しない |
| 暗号化・保管権限 | PASS / BLOCKED | ACLの種類と広範権限の有無 |
| 源泉SHA／Size 5件 | PASS / FAIL | 個別結果 |
| 既存ファイル衝突 | PASS / BLOCKED | 上書きなし |
| Git履歴Push禁止 | CONFIRMED | Git変更なし |

### B. Copy / Restore Evidence Matrix

| ID | Original SHA/Byte | Primary SHA/Byte | Backup SHA/Byte | Restore SHA/Byte | 判定 |
|---|---|---|---|---|---|
| E-P202-RAW | … | … | … | … | … |
| E-P203-RAW | … | … | … | … | … |
| E-P204-RAW | … | … | … | … | … |
| E-P204-SOURCE | … | … | … | … | … |
| E-P204-WB | … | … | … | … | … |

### C. Security / Recovery Result

Archive Set ID、許可主体（カテゴリのみ）、ReparsePoint・共有・同期除外・Backup暗号化・物理独立性・復元方法、Private IndexのSHAを記録。**証拠の限界**も明記。

### D. Git No-Change Check

HEAD・branch・Working TreeのBefore/After。Repoの個人パスを含む追跡履歴は継続**Push禁止**。

### E. Final Disposition

- `PRECHECK_BLOCKED`（コピー未実施）
- `PRIMARY_VERIFIED / S1-B INCOMPLETE`（例外的な途中停止）
- `FAILED`（不一致等）
- `S1-B TECHNICAL PASS / G2 REVIEW PENDING`（5/5 × Original/Primary/Backup/Restore一致、権限・暗号化確認）

**ユーザーによるG2承認は代行しない**。最後に、S1-Cへ引き渡すべきEvidence ID・SHA・Archive Set ID・未解決事項を提示して、必ず停止。

## まとめ / Summary

**日本語：** この指示書はS1-Bだけに適用する。両保管先・権限・暗号化・別媒体が確認できなければコピーしない。5原本をPrimary/Backupへ保全し、復元検査後にG2審査待ちとする。Git Pushは禁止。

**English:** This instruction is for S1-B only. Do not copy files until the two storage locations and their security are verified. Check all five files in primary, backup, and restore tests. Do not push to Git. Stop for G2 review.
