# Codex作業指示：S1-B G-PREP 永続退避準備

## 目的

USB ACL Remediation Designの`REMEDIATION_DESIGN_READY`判定に基づき、ACL変更前の退避準備を実施する。

今回の実行対象は**退避準備のみ**とする。

ユーザーによるG-PREPの明示承認が確認できなければ、ファイル・フォルダを作成せず停止する。

## 1. 実施内容

1. USB媒体`MG_EVIDENCE_BK`を再識別し、過去の媒体情報と一致することを確認する。
2. 非昇格セッションで通常ユーザーSIDを取得し、USBルートOwnerとの一致を確認する。
3. USBルートのOwner、DACL、継承状態が前回報告から変わっていないことを確認する。
4. 次の退避先について、Repository外・既知OneDrive同期ルート外・既存ACL・衝突有無を再確認する。
```
%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\
  ACL_Remediation_Rollback\<UniqueRunID>\
```

5. ユーザーが承認した場合に限り、新規Runフォルダを作成する。
6. `Root.before.json`に媒体識別情報、固定SID、Owner、DACL SDDL、継承状態、取得日時を記録する。
7. 保存ファイルを読み戻し、内容とSHA-256を確認する。
8. SVIの変更前Snapshotをユーザーが管理者PowerShellで取得・保存するための手順を提示する。

## 2. 禁止事項

- USBルートまたはSVIのACL変更
- Owner変更
- 管理者昇格
- BitLocker設定変更
- 未承認ファイルの作成・削除・上書き
- Git操作・Repository変更
- Evidence原本のコピー
- Stage 1／Stage 2の実行
- S1-Cへの着手

## 3. 完了報告

以下を報告すること。

- USB媒体の再識別結果
- 通常ユーザーSIDの整合確認結果
- 退避フォルダの作成結果
- Root Snapshotの保存・読み戻し・SHA検証結果
- SVI Snapshotのユーザー実施手順
- 未完了事項と残留リスク
- 次の承認対象

SID、DACL SDDL、シリアル番号の原文はチャットに表示しない。

最終判定は`G_PREP_COMPLETE`、`G_PREP_PARTIAL`、`BLOCKED`のいずれかとする。

**G-PREPが完了しても、ACL変更を開始せず停止すること。**
