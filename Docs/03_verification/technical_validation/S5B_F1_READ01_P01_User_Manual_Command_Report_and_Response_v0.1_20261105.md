# S5-B F1-READ-01 P01所属確認のユーザー手動実行報告と応答

> 保存時の整形：コマンド入力行のユーザーパスを省略し、報告されたメンバー名2件をM01・M02へ置換した。以下は提示された報告・応答の記録であり、Codexによるコマンド実行や独立検証ではない。

## Prompt1

```text
net localgroup "CodexSandboxUsers"
エイリアス名     CodexSandboxUsers
コメント         Codex sandbox internal group (managed)

メンバー

---

M01
M02
コマンドは正常に終了しました。
```

## Response1

正常終了の表示と、直接メンバー2件の報告を受領しました。**`USER_ATTESTED / USER_MANUAL_COMMAND`**として、実名を再掲せず整理します。

照会した同名主体は、報告された結果上ではローカルグループです。ただし、ACL上のP01とのSID一致は`NOT_VERIFIED`を維持します。

| 匿名メンバーID | 主体区分 |
| --- | --- |
| M01 | UNKNOWN |
| M02 | UNKNOWN |

メンバー名からユーザー／グループ種別や権限を推定していません。

```yaml
Evidence: USER_ATTESTED / USER_MANUAL_COMMAND
CommandResult: SUCCESS_REPORTED

QueriedPrincipalType: LOCAL_GROUP
ACL_P01_SIDMatch: NOT_VERIFIED
DirectMemberCount: 2
TransitiveMembership: NOT_VERIFIED
FutureDedicatedUserEffectiveAccess: NOT_VERIFIED

TargetPCGUIConfirmation: NOT_REPORTED
NonElevatedSession: NOT_VERIFIED
WindowsAccountType: UNKNOWN

F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

今回の出力だけでは、対象PCのGUI確認と非昇格状態は確認できません。**実施済みの操作について「S5B-TestPC-01をGUI確認後、非昇格のコマンドプロンプトで実行した」か**を補足してください。追加操作・追加コマンドは不要です。標準ユーザーアカウントだったとは自動認定しません。

Codexによるコマンド実行・追加調査・設定変更は行わず、停止します。

## Prompt2

S5B-TestPC-01をGUI確認後、非昇格のコマンドプロンプトで実行した

## Response2

補足を受領しました。ユーザー手動実行の対象PC確認・非昇格状態を、**ユーザー申告として補完**します。

```yaml
Evidence: USER_ATTESTED / USER_MANUAL_COMMAND

UserManualExecution:
  TargetPC: S5B-TestPC-01
  GUIConfirmation: CONFIRMED_BY_USER
  NonElevatedPrompt: CONFIRMED_BY_USER
  CommandResult: SUCCESS_REPORTED
  DirectMembers: [M01, M02]
  MemberPrincipalTypes: UNKNOWN
  WindowsAccountType: UNKNOWN

ACL_P01_SIDMatch: NOT_VERIFIED
TransitiveMembership: NOT_VERIFIED
FutureDedicatedUserEffectiveAccess: NOT_VERIFIED

F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

非昇格だったことから、標準ユーザーアカウントだったとは認定しません。また、この申告をCodexツールの実行先・権限確認には転用しません。

追加操作・調査・変更は行わず、既存の判断と履歴を維持して停止します。
