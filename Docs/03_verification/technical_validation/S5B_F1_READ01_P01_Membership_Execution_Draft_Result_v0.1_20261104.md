# S5-B F1-READ-01 P01所属確認の実行指示案整理結果

実行指示の準備として整理しました。**コマンドは実行していません。**

S5B-TestPC-01のWindows 11 Home利用は、`USER_ATTESTED`として受領します。独立検証済みにはしません。

## 将来の実行指示案

別途明示承認後、S5B-TestPC-01上で、通常権限により次のコマンドだけを1回実行します。

```text
net localgroup "CodexSandboxUsers"
```

- 追加オプション・スクリプト・再試行は行わない。
- 権限要求、アクセス拒否、その他エラーがあれば停止する。
- 設定変更・ファイル出力・ログ作成の追加処理は行わない。
- 結果は匿名メンバーIDへ置換し、実ユーザー名・SID・ホスト名を報告しない。
- 各メンバーの主体区分を出力だけで確定できなければ`UNKNOWN`とし、追加照会しない。
- 直接メンバーの確認と、推移的所属・実効アクセスの確認を区別する。

ユーザー手動実行の結果を受領する場合、証拠区分はユーザー申告として扱います。実名を匿名IDに置換した結果だけを共有してください。

```yaml
TargetPC: S5B-TestPC-01

OS:
  Edition: Windows 11 Home
  Evidence: USER_ATTESTED

P01:
  PrincipalType: UNKNOWN
  Members: UNKNOWN
  MembershipVerification: NOT_VERIFIED

CommandExecutionAuthorization: NOT_GRANTED
CommandExecuted: FALSE

FutureDedicatedUserEffectiveAccess: NOT_VERIFIED

F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

EnvironmentMutation: NONE
PreflightExecuted: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
```

ユーザー作成・所属変更・ACL変更・Excel操作・Preflightは行わず、別途承認待ちで停止します。
