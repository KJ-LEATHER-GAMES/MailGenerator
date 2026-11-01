# 引き継ぎまとめ

- **対象プロジェクト**：定型メール作成ツール（Excel VBA + Outlook Classic／OFTテンプレート）
- **整理日**：2026-10-22
- **対象期間・主題**：P2のClosure／Phase Exitに向けたS0棚卸し、S1-A Archive方針調査、S1-B Private Evidence Archive準備、USB Backup方針のGrill MeおよびBitLocker初期設定
- **直近の現在地**：USB Backup媒体のユーザー初期設定と識別情報申告まで完了。**次はCodexによるS1-B Backup Precheck（Read-only）**。原本5件のPrimary／Backupコピー・復元試験、S1-C、G2は未実施。
- **確度の読み方**：`REPO_VERIFIED`＝CodexがRepository現物を確認、`FILE_VERIFIED`＝CodexがRepository外現物を確認、`USER_ATTESTED`＝ユーザーの申告、`UNKNOWN`＝未確認。以下で「Codex報告」と記す内容は、ChatGPT自身がユーザーPC上で再検証したものではない。

## 実施内容

### 1. P2 Closure／Exit計画の整理

- 先行引継ぎ `Context_Handoff_P2-04_I12_20261019(1).md` を起点に、段階的な作業計画を策定した。
- `P2_Closure_and_Phase_Exit_Action_Plan_v0.1_20261019.md` を作成。順序は **S0（Read-only棚卸し）→ S1（Evidence Archive）→ S2（P2-02/P2-03正式Closure）→ S3（P2-04/I12正式Closure）→ S4（Baseline／Project Control整合）→ S5（P2-05 Completion）→ S6（P2 Phase Exit／CP-P2）**。
- プロジェクトのルールとして、技術的PASS・証拠の存在・正式Closure・Baseline承認・Phase Exitを分離して扱った。

### 2. S0のCodex指示・調査・記録

- `Codex_S0_ReadOnly_Inventory_Instruction_v0.1_20261020.md` を作成し、CodexへRead-only棚卸しを依頼した。
- CodexのS0実行結果をレビューし、`S0_P2_Artifact_Evidence_Inventory_Summary_v0.1_20261021.md` を作成。**S0＝Inventory Complete**。ただし後続Gate承認ではない。
- S0の主な調査結果（Codex報告）：
  - Repository内の9 Production Source候補と外部Source ZIPを比較。**正規化テキスト9/9一致**、文字列リテラル列9/9一致。ただし**バイト列は9件とも不一致**であり、実行WorkbookのVBAProject全体との一致は未検証。
  - 外部開発フォルダで実行Workbook候補を発見。SHA-256 `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` が以前のユーザー申告と一致。**現物同一性の確認**であり、過去の実行・Compileの独立証明ではない。
  - 外部にP2-02／P2-03／P2-04の生ログとProduction Source ZIP、関連レビューZIP、IF-P2-05-001判断書を確認。
  - P2-02 **111/111 PASS**、P2-03 **46/46 PASS**、P2-04新Cycle **182/182 PASS** を原文ベースで再集計。I12は既存Assessment上 `TECHNICAL PASS / REVIEWED`。**P2-02／03／04のRegression Record正式Closure、I12 documentary closureは未完了**。
  - P2-01 Regression Recordは既存記録上PASS/CLOSED。
  - `BL-MVP-004_Approval_Record_v0.1.md` はAPPROVED（2026-10-01）だが、`Document_Registry.md`、`Project_Overview.md` のCurrent Approved BaselineはBL-MVP-003で整合が未完了。BL004の完成版Approved技術文書も一部Repoで未確認。
  - P2-05の最終Completionには、現行BuildのCompile、S01～S32項目別Static Review、Production Patch Review、Final Finding Assessment、Active／Blocking Finding集計などが残る。`OBS-P2-05-002` はOPEN／NON-BLOCKINGの扱いを維持。
- I10の初回ABORTはPASSに加算せず、過去のI01/I02を今回Cycleの同一Revision実行とは扱わない等、Evidenceの限界を保全した。

### 3. S1-A：保管方針・公開リスク調査

- `S1_Evidence_Archive_Implementation_Plan_v0.1_20261021.md` と `Codex_S1A_Evidence_Archive_Policy_ReadOnly_Instruction_v0.1_20261021.md` を作成。
- CodexのRead-only調査結果：**GitHub RepositoryはPublic**。公開`main`は`edf5c5175b103e250144341071d885a3a992c65f`、当時のローカルHEADは`d49d8c7c63379ac69cf0df40c1f16a89342d23e7`。
- 個人ユーザーパス6か所を含むP2-04 Rawは**ローカルGitで追跡済み**。調査時点の公開`main`ツリーには対象ファイルはなく、**他ブランチ・Fork・過去取得など公開曝露全体の不存在は未証明**。
- 原本5件のSHA／サイズがS0と一致。専用非公開ArchiveをRepo外に置き、Gitには機微な実パスや生ログを置かない方針を提案。
- G1でユーザーが**基本方針を承認**。ただし保存先の実効権限・Backupの成立・コピー権限等は別承認とした。
- **個人パスを含むローカル履歴のPublic RepoへのPushは禁止継続**。Git履歴削除やforce-pushは承認していない。

### 4. S1-B：仕様・Precheck・Primary空フォルダ検証

- `S1_B_Archive_Storage_Access_Backup_Specification_v0.1_20261021.md` と `Codex_S1_B_Private_Archive_Execution_Instruction_v0.1_20261021.md` を作成。
- ユーザーはまず**添付2ファイルをRepositoryへ追加することだけ承認**。Codexは`Docs/00_project_control/`へ原文のまま保存しSHA一致を報告。後続確認時点では2ファイルはGit未追跡で、Add／Commit／Pushは未実施との報告。
- Precheck：Primary候補はGit管理外・既知OneDriveルート外、元Evidence 5件のSHA／サイズ一致。しかし保存先・実効権限・Backup媒体／暗号化が未確定だったため `PRECHECK_BLOCKED`。原本コピー未実施。
- HEAD変更の理由をユーザーの`git log`で確認：`c86671f1ba8e377a7327687a955b5ee4a1a2d0cd`（2026-10-21 22:11:04 JST、`Add S0 inventory summary and S1 archive planning instructions`）は、先行する`d49d8c7...`からの文書追加Commit。**追加のHEAD差分調査は必須ではない**と判断。ただし正確な変更ファイル一覧の独立照合は未実施。
- `S1-B_Precheck_Review_and_Next_Actions_v0.1_20261021.md`、`S1-B_Primary_Directory_Review_and_Next_Action_Plan_v0.1_20261021.md` を作成。いずれもレビュー／提案文書であり、正式Approvalとは別。
- ユーザーが**Primaryの空3階層の作成と、その後のRead-only検査だけを追加承認**。Codexは以下を作成：
  - `%USERPROFILE%\PrivateEvidenceArchive\`
  - `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\`
  - `%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\P2_I12_20261018\`
- Codex報告：3階層作成成功、ファイル0件、実行ユーザーがOwner、許可ACEは実行ユーザー／SYSTEM／Administratorsの継承FullControl各1件、その他主体のACEなし。Git管理外・確認可能なOneDrive同期ルート外・通常SMB共有なし。
- ただし管理共有の共有ACLにはAdministrators／Backup Operators／INTERACTIVEのFull許可が観測され、別主体の実効アクセスは`UNKNOWN`。管理共有`EncryptData=false`を、すべての通信が平文である証明とは扱わない。Codex最終判定は**`PRIMARY_DIRECTORY_REVIEW_REQUIRED`**。
- ChatGPTは**残留リスク付き受入れを推奨**したが、**ユーザーによるPrimary Directory残留リスクの明示的な正式受容は未確認**。ACL・共有設定の変更はしていない。
- 従来のS1-BではBackup条件確認後にコピーする方針。PrimaryとBackupを別Gate（B1/B2）に分割する案も出たが、**正式な手順変更・先行コピー承認はない**。

### 5. Backup媒体・運用方針のGrill Me（Q1～Q23）

- 1問ずつのヒアリングで以下を決定・確認。
  - 使用媒体：手元の**USBメモリ**、Backup専用として使用可能。
  - 暗号化：実施。必要なら初期化を許容。Windows 11 Pro／Enterprise／Education系、個人所有・自己管理PC。
  - 暗号化方式：**BitLocker To Goを第一候補として選定**。
  - 回復キー：**紙＋パスワードマネージャー**に二重保管。
  - 接続：Backup時のみ接続し、終了後取り外す。USBメモリは自宅内のPCと別の部屋に保管。
  - 更新頻度：重要Evidenceの追加・確定時。原本の無断上書きなし。
  - 復元検証：**初回は全5件を復元してSHA-256照合**。以降は重要Evidence追加時にBackupを更新し、SHA-256を照合。
  - 責任分担：USB初期化・暗号化・パスワード／回復キー管理はユーザー。承認後のコピー・SHA照合・復元試験はCodex。最終承認はユーザー。
- Windowsでのフォーマット設定を案内：NTFS、アロケーションユニット4096バイト（既定）、ボリュームラベル`MG_EVIDENCE_BK`、クイックフォーマット。**実際のフォーマット実施日時・操作ログは未受領**。
- BitLockerの設定手順を案内：パスワード方式、回復キー保管、ドライブ全体の暗号化、リムーバブルドライブ向け互換モード。
- ユーザーは**BitLocker暗号化完了、再接続後のパスワード解除成功、紙とパスワードマネージャーへの回復キー保管完了**を回答。これらは`USER_ATTESTED`であり、Codexの実機検証はまだ。
- バックアップ媒体識別：ボリュームラベル`MG_EVIDENCE_BK`、現時点のドライブ文字`D:`（ユーザー申告）。再接続でドライブ文字が変わり得るため、物理ディスク情報との照合が必須。
- 会話末尾で、**`S1-B Backup Precheck 実施指示（Read-only）`** をCodexへ渡す文章として確定・提示。指示は媒体識別、物理ディスク独立性、BitLocker保護状態、`D:\MailGenerator\P2_I12_20261018\`候補、Primary継続性、次のコピー承認条件の調査に限定。**このPrecheckの実施結果はまだ受領していない**。

### 6. Evidence 5件の識別値（CodexのS1-A／S1-B Precheck報告）

| Logical ID | 内容 | Bytes | SHA-256 |
|---|---|---:|---|
| `E-P202-RAW` | `261018_P2-02_Regression Log.txt` | 11,170 | `b91f028b4679dc9608d264698edf4d8ef356a4a54ced24ff044b6baa95d7dbae` |
| `E-P203-RAW` | `261018_P2-03_Regression Log.txt` | 4,131 | `f0253df8e7e77a0ac6f2d1aa827d5e6dab34df2bb18708ef66ebf53a1c4e6877` |
| `E-P204-RAW` | `261018_P2-04_Regression Log.txt` | 19,812 | `4a16f9dfb09573bd28c6732372465c39644417502081b8d37b5c132b76f08add` |
| `E-P204-SOURCE` | `P2-04_Regression_20261018.zip` | 25,325 | `bdd107be84b160c4ac2ea82c5a5127acf87731017401af548f50882fa0de67e7` |
| `E-P204-WB` | 実行Workbook候補 `MailGeneratorNew.xlsm`（Repo外） | 1,003,775 | `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` |

- P2-04 RawのRepository内追跡コピーは上記原本とSHA一致したが、**現在のPublic remote `main`には未掲載**というS1-A確認結果。公開経路全体については未確認。
- 9 Sourceの正規化一致、Workbook SHA一致は、過去全RunのSource一致やWorkbook VBAProject内部一致を証明しない。

## 決定事項

- S0は**Inventory Complete**。その完了をRegression ClosureやPhase Exitと混同しない。
- S1の基本方式は**Repository外の非公開ArchiveをPrimaryとし、別の暗号化済み物理媒体をBackupとする**。Public GitHubには原本を追加しない方針。
- 現在のローカルGit履歴（個人パス入りRawを含む）の**Pushは禁止継続**。履歴改変・強制Pushは許可していない。
- Primaryの空3階層の作成とRead-only検証を限定承認し、実施済み。**原本コピーは承認していない**。
- Backup媒体は専用USBメモリ、BitLocker暗号化、紙とパスワードマネージャーへの回復キー保管、作業時のみ接続・自宅の別室保管。
- 更新は重要Evidence追加・確定時。初回は全5件の完全復元＋SHA-256照合、以降は追加・更新時のSHA-256照合。
- USBの初期設定・秘密情報管理はユーザー、承認後の保全・検証作業はCodex、最終Approvalはユーザー。
- **作業単位ごとに変更権限を承認**。Read-only指示ではコピーや設定変更を行わず、完了を先取りしない。

## 未解決事項

### S1-B／安全性

- **最優先**：Codex `S1-B Backup Precheck（Read-only）`未実施。媒体`D:`／`MG_EVIDENCE_BK`の物理ディスク識別、Primaryとの物理独立性、BitLockerの暗号化完了率・Protection／Lock状態などの実測が必要。
- Primary DirectoryはCodex判定`PRIMARY_DIRECTORY_REVIEW_REQUIRED`。管理共有経由の実効アクセス、共有・同期の確認限界に対するユーザーの**残留リスク受容／追加措置の判断**が未確定。
- Backupの実際の保存先候補 `D:\MailGenerator\P2_I12_20261018\` は**未作成・未承認**。容量、媒体構成、アクセス制御、衝突有無の確認待ち。
- `EXECUTE_ARCHIVE`は未承認。`originals`／Backup用ディレクトリ／Private Index等の作成、原本5件のPrimary／Backupコピー・SHA検証・Restore試験は未実施。
- 保存後のPrivate Index作成・Archive Manifest改訂、G2完了承認は未実施。
- PrimaryとBackupの段階Gate分割（Backup未完了でもPrimaryコピーを先行する案）は**提案止まり**。従来の「双方の条件確認後に原本コピー」を維持。
- USB初期化・フォーマットの作業ログ、BitLocker保護状態、物理媒体番号は独立未検証。回復キーそのものはCodex／ChatGPTに提示しない。

### Git／文書／後続Gate

- GitHub Public、ローカル履歴に個人パス入りRawがあるため、**安全なPush方法／履歴の取扱いは別途判断が必要**。S1-B完了とは分ける。
- `S1_B_Archive_Storage_Access_Backup_Specification_v0.1_20261021.md`、`Codex_S1_B_Private_Archive_Execution_Instruction_v0.1_20261021.md` はCodex報告時点では追加済み・未追跡。後続Commit有無は要確認。
- `P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md` は実保管先・確認日時・Private Locator・Archive SHA・Visibility等の正式反映待ち（S1-C）。別台帳を無用に増やさない。
- `IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md` はRepo外で発見され、正式登録・参照整備が残る。
- S2：P2-02／P2-03 Regression Recordの正式Closure。S3：P2-04新Cycle／I12 documentary closure。S4：BL-MVP-004とRegistry／Overview、Approved正本の整合。S5：P2-05 Compile・Static Review S01–S32・Patch Review・Finding Assessment・Completion。S6：P2 Phase Exit／CP-P2。

## 次アクション

**P0：Codex Backup Precheck（Read-only）を実行する**

- 前チャット末尾の指示文 **`S1-B Backup Precheck 実施指示（Read-only）`** をそのままCodexへ渡す（作業指示の正本を一つにする）。以前のレビュー計画書の指示を混ぜない。
- USBメモリをPCに接続し、本人がBitLockerパスワードでロック解除した状態で実施。パスワード／回復キーの共有不要。
- 確認対象：`MG_EVIDENCE_BK`（直近`D:`）、NTFS、ディスク番号と物理USB媒体、Primaryとの独立性、BitLocker暗号化／Protection／Lock状態、Backup候補パスの衝突・容量・アクセス制御、既存Primaryの継続性。
- **絶対禁止**：ファイル作成／コピー、BitLocker設定変更、管理者昇格、Git Add／Commit／Push／Fetch／Pull／履歴変更、S1-C着手。
- 出力を`BACKUP_PRECHECK_PASS`／`REVIEW_REQUIRED`／`BLOCKED`から判定し、確認根拠とUNKNOWNを区別させる。

**P1：Precheck結果をレビューし、ユーザー判断を確定する**

- Backup媒体適合性を審査。
- Primaryの管理共有等の残留リスクについて、**受容するか／限定的な追加措置を求めるか**を明示決定する。
- Primary／Backupコピー先の実パス、作成対象、原本5件、SHA照合、復元試験を一覧にして次の承認範囲を確定する。

**P2：別承認後、S1-B Evidence保全を実行する**

- コピー前に原本5件のサイズ・SHAを再測定。
- 承認された新規保存先のみ作成、**既存ファイルを上書きしない**。
- 原本→Primary→Backupの各コピーのSHA一致を確認。Backupから別の試験用場所へ復元し全5件照合。
- 原本・Workbook・Production Sourceを変更しない。復元試験用残存ファイルの処置も承認範囲を明確にする。

**P3：S1-C → G2 → S2以降**

- 既存Archive Manifestに保管ID、Size、SHA、確認日時、Visibility、関連コピーとEvidence限界を最小反映。機微な絶対パスはPublic Gitに書かない。
- Codex技術結果をユーザーがG2で審査。G2までS1-B完了／正式Closureとしない。
- その後、S2→S3→S4→S5→S6の依存順で進める。

### 次チャット冒頭に貼る短い再開指示

> 定型メール作成ツールのP2 Evidence Archive S1-Bを再開します。Grill Meで専用USBメモリ`MG_EVIDENCE_BK`（前回`D:`）を選び、BitLocker To Goの暗号化・再接続解除はユーザー申告上完了しました。Primary Archiveの空3階層は作成済み、Codex判定は`PRIMARY_DIRECTORY_REVIEW_REQUIRED`。原本5件は未コピー、Backup Precheckは未実施、Git Pushは禁止継続。まず前チャットの`S1-B Backup Precheck 実施指示（Read-only）`によるCodex結果をレビューし、Primary残留リスクの受容と`EXECUTE_ARCHIVE`承認条件を整理してください。技術PASSと正式Closureは区別してください。
