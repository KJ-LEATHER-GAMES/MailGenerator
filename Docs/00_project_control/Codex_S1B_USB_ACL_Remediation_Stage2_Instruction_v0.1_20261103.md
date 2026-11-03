# Codex作業指示：S1-B USB ACL Remediation Stage 2

## 目的・承認範囲

Stage 1の実行後検証で`SVI_POSTSTAGE1_READONLY_PASS`を確認しました。

**Stage 2として、対象USBルートからEveryoneのExplicit Allow ACEを除去する操作のみ、条件付きで実行承認します。**

Stage 2以外のACL変更、Evidenceコピー、Archiveディレクトリ作成は承認しません。

## 1. 既存Evidence

- Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- Root Snapshot SHA-256：`b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
- SVI Snapshot SHA-256：`f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
- Stage 1結果：`STAGE1_ROOT_PASS_PENDING_SVI`
- Stage 1事後検証：`SVI_POSTSTAGE1_READONLY_PASS`

## 2. 実行直前の必須確認

次のすべてをRead-onlyで確認してください。

1. USB媒体`MG_EVIDENCE_BK`が既存Snapshotと一致する。
2. 非昇格の通常ユーザーセッションで実行する。
3. 実行ユーザーSID、固定SID、USBルートOwnerが一致する。
4. Root／SVI SnapshotのSHA-256と相互参照が一致する。
5. USBルートが期待する4主体のExplicit Allow／FullControl（OI／CI）のみを持つ。
6. Everyone以外の3主体のACEが正常である。
7. USBルート直下に想定外項目がない。
8. Stage 1後の管理者PowerShellによるSVI照合PASSが確認済みで、その後の媒体再接続・状態変更がない。

最後の条件を確認できなければ、ユーザーに直近のSVI再照合を依頼し、結果が確認できるまで停止してください。

いずれかが不一致・UNKNOWNの場合は変更せず停止してください。

## 3. Stage 2実行

媒体識別で確定したUSBルートだけを対象とし、承認済みの`icacls /remove:g`でEveryone（SID `S-1-1-0`）のAllow ACEを除去してください。

- 操作は1回のみ。
- `/T`、`/reset`、`/C`は使用しない。
- 他の3主体のACEは変更しない。
- Owner、SVI、BitLocker、共有設定を変更しない。
- エラー時は即停止し、自動再試行・自動Rollbackを行わない。

## 4. 実行後の確認

Read-onlyで次を検証してください。

- 同一USB媒体である。
- `icacls`が終了コード0を返した。
- USBルートのAllow ACEが通常ユーザー・SYSTEM・Administratorsの3主体のみである。
- 3主体はFullControl、OI／CIあり、Explicit Allowである。
- EveryoneのAllow ACEが残っていない。
- 想定外のAllow／Denyがない。
- Owner・継承設定・直下項目は不変。
- 通常ユーザーによるルートACL読取り・列挙が成功する。
- Root／SVI Snapshotのハッシュが不変。

Codexが通常権限でSVIの現在ACLを取得できない場合はUNKNOWNとし、ユーザーに管理者PowerShellでの事後照合を依頼してください。

## 5. 禁止事項

- Stage 2以外のACL変更
- Owner変更、管理者昇格
- Snapshotの再生成・上書き
- 証拠原本のコピー・移動・削除
- Archiveディレクトリ作成
- Git操作・Repository変更
- S1-C、P2 Closureへの着手
- 自動Rollback

## 6. 完了報告

以下を報告してください。

1. Stage 2コマンド実行結果
2. USB媒体の同一性
3. 変更前後のRoot ACL確認
4. 3主体の権限・継承フラグ
5. Owner・直下項目の不変確認
6. SVI事後照合の要否
7. エラー・残留リスク・UNKNOWN
8. 次のユーザー作業

最終判定：

- `STAGE2_ROOT_PASS_PENDING_SVI`
- `STAGE2_VERIFIED`（SVIの事後照合も完了した場合のみ）
- `REVIEW_REQUIRED`
- `BLOCKED`

**Stage 2のRoot検証後は停止し、SVIの事後照合を待ってください。Evidenceコピーには進まないでください。**
