# S1-B Backup Precheck 実施指示（Read-only）

## 1. 目的

定型メール作成ツールのS1-B Evidence Archive保全に向けて、ユーザーが初期設定したBackup専用USBメモリの適合性を確認してください。

今回の作業はRead-only調査に限定します。

原本Evidenceのコピー、Archive作成、設定変更、Git更新は承認していません。

## 2. 前提情報

### Primary Archive

`%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\P2_I12_20261018\`

- 空の3階層は作成済み。
- NTFS ACLは実行ユーザー・SYSTEM・Administratorsに限定されていることを確認済み。
- 管理共有経由の実効アクセスには残留リスクがあり、正式受容は未確定。
- 原本Evidenceは未コピー。

### Backup媒体

- 種類：USBメモリ
- ボリュームラベル：`MG_EVIDENCE_BK`
- 現在のドライブ文字：`D:`
- ファイルシステム：NTFS（ユーザー設定）
- 暗号化方式：BitLocker To Go
- 暗号化範囲：ドライブ全体
- 暗号化モード：互換モード
- ユーザー申告：暗号化完了、再接続後のパスワード解除PASS
- 用途：Evidence Backup専用

ドライブ文字やユーザー申告だけをもって、媒体の識別・暗号化適合性をPASSとしないでください。

## 3. 調査項目

### A. Backup媒体の識別

現在の`D:`について、次をRead-onlyで確認してください。

1. ボリュームラベル
2. ドライブ文字
3. ファイルシステム
4. 容量・空き容量
5. ディスク番号・パーティション対応
6. 物理ディスクの識別情報
7. USB接続の確認
8. Primaryが存在する物理ディスクとの相違

ディスク番号やドライブ文字だけで物理独立性を断定せず、取得できるデバイス情報との対応を検証してください。

対象が一致しない場合は停止してください。

### B. BitLocker状態

読み取り可能な範囲で次を確認してください。

1. BitLockerの暗号化状態
2. 暗号化完了率
3. Protection Status
4. Lock Status
5. 暗号化方式
6. ファイルシステムとの整合

期待する状態は、完全に暗号化され、BitLocker保護が有効で、ユーザーによってロック解除された状態です。

パスワードや回復キーの取得・表示・保存は絶対に行わないでください。キー保護機構の存在確認が必要な場合も、秘密値を表示しない方法に限定してください。

### C. Backup保存先の確認

Backup保存先の候補を次とします。

`D:\MailGenerator\P2_I12_20261018\`

- 候補パスの妥当性
- 既存ファイル・ディレクトリとの衝突
- 利用可能容量
- アクセス制御
- 通常共有・同期の有無
- 保存先作成に必要な承認事項

候補フォルダは今回作成しないでください。

### D. Primary側の継続性

既存Primary Archiveについて、Read-onlyで以下を確認してください。

- 指定3階層の存在
- 内容が空であること
- 既知のACL構成から予期しない変更がないこと
- Git Repository外であること
- 確認可能なOneDrive同期範囲外であること

前回未確認だった管理共有の実効アクセスを推測でPASSに変更しないでください。

### E. S1-B実行準備

次回の原本コピーに向け、以下を整理してください。

- 原本Evidence 5件の参照元
- 既知SHA-256との照合方法
- Primary・Backupの保存先候補
- コピー先の新規作成が必要な範囲
- 既存ファイルとの衝突防止
- コピー前後のSHA-256検証方法
- 独立した復元試験の実施方法
- ユーザーが別途承認すべき変更操作

計画のみ作成し、実際のコピーや復元試験は行わないでください。

## 4. 禁止事項

以下はすべて禁止します。

- USBメモリの初期化・フォーマット
- BitLockerの有効化・解除・設定変更
- ファイル・フォルダの作成、コピー、移動、削除
- ACL・共有・所有者の変更
- 管理者権限への昇格
- 原本Evidence・Workbook・Source ZIPの変更
- Git Add / Commit / Push / Pull / Fetch / Reset / 履歴変更
- Repositoryへの新規文書保存
- S1-C以降への着手

個人ユーザーパスを含むローカルGit履歴のPublic RepositoryへのPush禁止は継続します。

## 5. 報告形式

Markdown形式で次をCodexチャット内に報告してください。

1. 調査日時とRepository状態
2. Backup媒体識別結果
3. 物理ディスク独立性判定
4. BitLocker暗号化・保護状態
5. ファイルシステム・容量・アクセス制御
6. Backup保存先候補の適合性
7. Primary Archive継続性
8. 未確認事項・残留リスク
9. S1-B実行前の不足事項
10. 次にユーザーが承認すべき具体的操作
11. Read-only遵守確認

各項目をVERIFIED、USER_ATTESTED、UNKNOWNなどの確度で区別してください。

総合判定は以下のいずれかとします。

- `BACKUP_PRECHECK_PASS`
- `BACKUP_PRECHECK_REVIEW_REQUIRED`
- `BACKUP_PRECHECK_BLOCKED`

今回の判定をS1-B CompletionまたはG2承認として扱わないでください。

結果報告後、原本コピーに進まず停止してください。
