# S1-B Primary Archive空フォルダ作成・作成後検証

## 目的

S1-B Precheck追加調査の結果を受け、Primary Archiveの空フォルダを作成し、実際のアクセス権限・配置の安全性を検証してください。

本作業は、S1-B実施前の限定的な準備作業です。

**今回承認するのは、指定した空3階層の作成と作成後のRead-only検査のみです。**

Backup媒体未確定の状態で原本をコピーすることは承認していません。

## 1. 承認する作成先

Primary Root：

`%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\P2_I12_20261018\`

作成を許可するディレクトリは、次の3階層のみです。

1. `PrivateEvidenceArchive`
2. `PrivateEvidenceArchive\MailGenerator`
3. `PrivateEvidenceArchive\MailGenerator\P2_I12_20261018`

実行ユーザーのプロファイルを基準に絶対パスへ展開してください。

上記以外のディレクトリ、`originals`、Private Index、その他ファイルの作成は禁止します。

## 2. 作成前の確認

- 実行ユーザーのプロファイル内であること
- Git Repositoryと既知のOneDrive同期対象外であること
- 既存祖先に予期しないReparsePointがないこと
- 対象3階層がいずれも未作成であること
- 既存親フォルダのACLが事前調査結果と整合していること

条件に差異があれば、作成せず報告してください。

## 3. 空フォルダの作成

上記の3階層だけを新規作成してください。

- 既存ファイル・フォルダを変更しない
- ACLの明示的な変更は行わない
- 管理者権限への昇格は行わない
- 原本Evidenceをコピーしない
- 作成に失敗した場合、無断で設定変更や削除をしない

## 4. 作成後の検証

作成された各階層について、次を確認してください。

- Owner
- NTFS ACL
- Explicit / Inherited ACE
- ACL継承の有効状態
- 許可主体と権限
- 未承認主体へのRead / Write / Modify権限
- ReparsePoint
- Git Repository内外
- 確認可能なOneDrive同期設定
- 共有設定と確認可能な実効アクセス

許可主体は、実行Windowsユーザー、SYSTEM、Administratorsを基本とします。

確認不能な事項はUNKNOWNとし、安全性を推定でPASSにしないでください。ただし、管理共有の存在や親のTraverse権限だけを理由に内容の読取り可能と断定しないでください。

不適合があれば、修正案を提示して停止してください。ACL変更の実行は承認していません。

## 5. 禁止事項

- Raw Log、Source ZIP、Workbookのコピー・移動・変更
- Backupフォルダ・Private Indexの作成
- ACL・共有設定・所有者の変更
- 不適合なフォルダの無断削除
- Git Add / Commit / Push / Fetch / Pull / Reset / 履歴変更
- Workbook / OFTの起動
- S1-C、S2以降への着手

個人ユーザーパスを含むローカルGit履歴のPush禁止は継続します。

## 6. 報告形式

Markdown形式で次を報告してください。

1. 作成前Precheck結果
2. 実際に作成した3階層と作成結果
3. 各階層のACL・Owner・継承確認結果
4. Git・同期・共有・ReparsePoint確認結果
5. 未確認事項と残留リスク
6. Primary Archiveとしての準備判定
7. 原本コピー前に残る承認事項
8. Git Working Treeの変更前後比較
9. 今回の承認範囲の遵守確認

最終判定は次のいずれかとしてください。

- `PRIMARY_DIRECTORY_READY`
- `PRIMARY_DIRECTORY_REVIEW_REQUIRED`
- `PRIMARY_DIRECTORY_CREATION_FAILED`

いずれの場合も、S1-B CompletionやG2承認とは扱わないでください。

報告後は停止し、原本コピーには進まないでください。
