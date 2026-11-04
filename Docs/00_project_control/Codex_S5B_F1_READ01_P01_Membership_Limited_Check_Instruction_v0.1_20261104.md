# S5-B F1-READ-01：P01所属関係の限定確認

次工程は、P01（CodexSandboxUsers）の主体区分と所属メンバーの確認に限定します。

Windows 11 Homeを使用していることはUSER_ATTESTEDとして記録してください。

確認方法として、次のWindows標準コマンドを提案します。

`net localgroup "CodexSandboxUsers"`

ただし、今回は実行指示の準備のみです。別途明示承認を得るまではコマンドを実行しないでください。

将来の実行条件：

- 対象PCはS5B-TestPC-01のみ
- 通常権限で1回実行
- 追加オプション・スクリプト・再試行なし
- 権限要求やアクセス拒否の場合は停止
- 結果は匿名メンバーIDと主体区分に整理
- 実ユーザー名、SID、ホスト名は報告しない
- ファイル作成・設定変更なし

結果からP01の主体区分、所属メンバー、確認できなかった項目を報告してください。

専用Windowsユーザーの作成、グループ所属変更、ACL変更、Excel操作、Preflightは承認しません。

```yaml
F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

報告後に停止してください。
