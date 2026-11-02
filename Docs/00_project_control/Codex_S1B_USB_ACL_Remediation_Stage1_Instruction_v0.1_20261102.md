# Codex作業指示：S1-B USB ACL Remediation Stage 1

## 目的・承認範囲

`SVI_PRESTAGE1_READONLY_PASS`を確認したため、USBルートACLに承認済み3主体を追加する**Stage 1のみ実行承認**します。

承認する変更：

- 通常利用ユーザー：FullControl（OI／CI）
- SYSTEM：FullControl（OI／CI）
- Administrators：FullControl（OI／CI）

**EveryoneのFullControlはStage 1では維持してください。**

Stage 2（Everyone除去）は承認しません。

## 1. 既存Evidence

- Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- Root Snapshot SHA-256：`b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
- SVI Snapshot SHA-256：`f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
- 直前確認：`SVI_PRESTAGE1_READONLY_PASS`

## 2. 実行直前の確認

変更前に以下を再確認してください。

1. `MG_EVIDENCE_BK`を物理情報から再識別する。ドライブ文字だけで判定しない。
2. 通常ユーザーの非昇格セッションで実施する。
3. 通常ユーザーSID、実行SID、USBルートOwnerの一致を確認する。
4. Root／SVI SnapshotのSHA-256と対応関係を確認する。
5. USBルートACLが変更前Snapshotと一致する。
6. ルート直下は保護された`System Volume Information`のみである。
7. SVIの現在状態について、直前に実施した管理者PowerShellのPASS結果を確認する。媒体再接続・状態変化・時間経過により結果の鮮度を保証できない場合は、ユーザーへ再確認を要求して停止する。
8. 追加する3主体以外のACEを変更しないことを確認する。

不一致・UNKNOWNがあれば変更せず停止してください。

## 3. Stage 1実行

承認済みの`icacls /grant:r`方式により、3主体のFullControl（OI／CI）をUSBルートへ追加してください。

実行条件：

- 正しいUSBルートのみを対象とする。
- SIDは固定済みの通常利用ユーザーSIDを使用する。
- `Everyone`を残す。
- `/T`、`/reset`、`/remove`、Deny追加、Owner変更、管理者昇格は禁止する。
- 変更は一度だけ実行する。
- コマンド失敗・部分成功・予期しない状態の場合は即停止し、自動再試行や自動Rollbackを行わない。

## 4. 実行後の検証

Stage 1実行後にRead-onlyで確認してください。

- USB媒体が同一。
- ルートOwner不変。
- DACLが想定する4主体のAllow／FullControlのみ。
- 3主体のOI／CIが想定どおり。
- EveryoneのFullControlが維持されている。
- 想定外ACEやDenyがない。
- 通常ユーザーによるルートACL読取り・列挙が可能。
- SVIの現在ACLは独立確認できなければUNKNOWNとし、ユーザーによる管理者PowerShellの変更後比較を要求する。

## 5. 禁止事項

Stage 2、Evidenceコピー、Archiveディレクトリ作成、Snapshotの編集・再生成、Git操作、Owner変更、BitLocker変更、SVIへの書込みはすべて禁止します。

復旧が必要と考えられる場合も自動実行せず、別途承認を要求してください。

## 6. 完了報告

次の情報を報告してください。

- Stage 1コマンド実行結果
- USB媒体の再識別結果
- 実行前後のRoot DACL検証
- 期待4主体の存在・権限・継承フラグ
- Ownerの不変
- SVIの事後照合要否
- エラー・残留リスク・UNKNOWN
- 次のユーザー作業

判定：

- `STAGE1_ROOT_PASS_PENDING_SVI`
- `STAGE1_VERIFIED`（SVIの事後照合も確認できた場合のみ）
- `REVIEW_REQUIRED`
- `BLOCKED`

個人SID・SDDL・個人の絶対パスは報告に表示しないでください。

**Stage 1実行後は停止してください。Stage 2へ進まないでください。**
