# S5-B F1-READ-01 P01所属確認の手動実行手順案整理結果

以下は**未承認の手順案**です。現在は実行せず、既存のCodex実行承認も使用しません。

## 手動実行方式の手順案

手動方式への明示承認後に限り、ユーザーが実施します。

1. **対象PCをGUIで確認**

   S5B-TestPC-01であることを確認します。判別できなければ停止します。識別用の追加コマンドは使用しません。

2. **通常権限のコマンドプロンプトを準備**

   非昇格であることを確認します。管理者実行・権限要求への承認は行いません。通常権限か確認できなければ停止します。

3. **指定コマンドだけを1回実行**

   ```text
   net localgroup "CodexSandboxUsers"
   ```

   追加オプション・追加コマンド・再試行は禁止です。エラーやアクセス拒否なら、その時点で停止します。

4. **画面上の結果を匿名化**

   メンバーを`M01`、`M02`等へ置換します。同じ主体には同じ匿名IDを使用し、実ユーザー名・SID・ホスト名は転記しません。ファイル出力やスクリーンショット保存は行いません。

5. **匿名化結果だけを報告**

   成功／失敗、匿名メンバー一覧を報告します。主体区分を出力から確定できなければ`UNKNOWN`とし、追加照会しません。「未取得」と「確認できたメンバー0件」を区別します。

6. **証拠区分を限定して停止**

   `USER_ATTESTED / USER_MANUAL_COMMAND`として記録します。直接メンバーの列挙を、推移的所属・将来の専用ユーザーの実効アクセス遮断の証明にはしません。

### 承認後の報告テンプレート

```yaml
Target: P01
Evidence: USER_ATTESTED / USER_MANUAL_COMMAND
TargetPCConfirmedByGUI: <確認結果>
NonElevatedPromptConfirmed: <確認結果>
ExecutionCount: <0 または 1>
CommandResult: <成功／アクセス拒否／その他エラー／未実行>
DirectMembers: <匿名ID一覧／実測で0件／UNKNOWN>
PrincipalTypes: <確認可能な区分／UNKNOWN>
TransitiveMembership: NOT_VERIFIED
FutureDedicatedUserEffectiveAccess: NOT_VERIFIED
```

現在の状態は維持します。

```yaml
ManualExecutionAuthorization: NOT_GRANTED
CommandExecuted: FALSE
ExecutionTargetBinding: UNKNOWN
ExecutionPrivilege: NOT_VERIFIED

F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

設定変更・ファイル作成・PC操作は行わず、手順案の提示のみで停止します。
