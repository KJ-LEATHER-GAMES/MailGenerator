# Codex作業指示：S1-B G-PREP Snapshot Final Verification

## 1. 目的

S1-B ACL RemediationのStage 1実行承認前に、Root SnapshotおよびSVI Snapshotの保存状態・完全性・整合性をRead-onlyで最終確認する。

**今回はRead-only検証のみを承認する。ACL変更・ファイル変更は承認しない。**

## 2. 確定済みEvidence

### Root Snapshot

- Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- ファイル：`Root.before.json`
- サイズ：1,489 bytes
- SHA-256：`b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
- 取得元：Codex G-PREP実行

### SVI Snapshot

ユーザーが管理者PowerShellで取得・保存した。

- ファイル：`SVI.before.json`
- Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- サイズ：569 bytes
- SHA-256：`f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
- `AreAccessRulesProtected=True`
- 取得時のEvidence分類：`USER_PROVIDED_OS_OUTPUT`

両ファイルの保存先は、通常ユーザーのプロファイル配下にある既存のG-PREP Runフォルダとする。

## 3. 実施内容

### A. Snapshotファイル検証

1. Root／SVIの両ファイルが既存Runフォルダに存在することを確認する。
2. 各ファイルのサイズ・SHA-256を期待値と照合する。
3. JSONを読み込み、SchemaVersionと必須項目を確認する。
4. 両SnapshotのRun IDが一致することを確認する。
5. SVI Snapshotの`RootSnapshotSHA256`がRoot Snapshotの期待SHA-256と一致することを確認する。
6. SVI Snapshot内のDACL SDDLハッシュを再計算し、記録値と照合する。
7. 保存先フォルダと両SnapshotのACLが、承認3主体のFullControlに限定されていることを確認する。
8. 意図しない追加ファイル・上書き・変更がないことを確認する。

### B. USB状態確認

1. USB媒体を物理情報から再識別する。
2. Root Snapshotに記録された媒体情報と一致することを確認する。
3. USBルートOwner・DACLがRoot Snapshot取得時から変化していないことを確認する。
4. USBルート直下に想定外の項目が増えていないことを確認する。
5. SVIの現在のACLは、通常権限で取得できなければ`UNKNOWN`とする。管理者昇格は行わない。

### C. Stage 1 Entry Criteriaレビュー

以下を評価する。

- 媒体識別が成立する。
- Root／SVI Snapshotの完全性・相互整合性が成立する。
- 固定した通常ユーザーSIDが維持されている。
- Root DACLが変更前の状態を維持している。
- Snapshotの永続退避が成立している。
- SVI継承保護がSnapshot上でTrue。
- ACL変更実行前の再確認事項が明確になっている。

現在のSVI状態を独立確認できない場合は、Stage 1実行直前のユーザーによる管理者PowerShell再確認を必要条件として明記すること。

## 4. 禁止事項

- ACL・Owner・BitLocker・共有設定の変更
- ファイル・フォルダの作成、変更、削除、コピー
- Snapshotの再生成、上書き
- 管理者昇格
- Git Add／Commit／Push／Fetch／Pull
- Evidence原本のコピー
- Stage 1／Stage 2の実行
- S1-Cへの着手

## 5. 結果報告

以下の構成で報告する。

1. USB再識別結果
2. Root Snapshot検証結果
3. SVI Snapshot検証結果
4. Snapshot相互整合性
5. 保存先ACLとファイル完全性
6. 未確認事項と残留リスク
7. Stage 1実行前に必要なユーザー操作
8. Stage 1実行承認に進めるかの判断

最終判定は以下から選択する。

- `STAGE1_PRECHECK_READY`
- `REVIEW_REQUIRED`
- `BLOCKED`

`STAGE1_PRECHECK_READY`でもACL変更の実行承認とは扱わない。

SID・SDDL・シリアル番号等の原文は報告しない。

**結果報告後、Stage 1を実行せず停止すること。**

## 参照ファイルの指定

以下のPC上の既存ファイルを直接参照してください。

**Snapshot保存フォルダ：**

`%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a`

対象ファイル：

- `Root.before.json`
- `SVI.before.json`

**SVI取得スクリプト：**

`%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\Scripts\Save-SVI-Snapshot.ps1`

Snapshotの内容・SHA-256・ACL・相互整合性をRead-onlyで確認してください。

スクリプトは、実行せず、必要な場合に限りコードを参照してください。

既存ファイルの移動・コピー・再生成・編集・削除は行わないでください。

ファイルへのアクセスが拒否された場合は、管理者昇格やACL変更をせず、確認できない項目をUNKNOWNとして報告してください。

SID・SDDL・個人パスなどの機微情報は、報告本文やPublic Repositoryへ転記しないでください。
