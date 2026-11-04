# S5-B F1-READ-01：Clone ACL限定補完 v0.1

## 目的

S5B-TestPC-01上の既存RESOURCE-CLONE-Aについて、ACL情報の不足項目だけを補完する。

F1-READ-01の他の調査には進まない。

## 前提

```yaml
F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED

WorkbookLocationReconciliation: RESOLVED
WorkbookPhysicalIdentity: UNKNOWN

CloneUnderOneDrive: NO_USER_ATTESTED
DedicatedUserExisting: NO_USER_ATTESTED

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

## Step 1：既存スクリプトの静的確認

対象：

`S5B_F1_READ_01_CloneACL_ReadOnly.ps1`

次を確認する。

1. 対象フォルダー1件のACL読取りに限定されている。
2. 子ファイルやWorkbookの内容を読み取らない。
3. ファイル・フォルダー・ACLを変更しない。
4. 実ユーザー名、SID、実パスを報告しない。
5. 許可先を匿名主体IDに分類する。
6. 管理者昇格、実行ポリシー変更を必要としない。
7. ファイル出力・ログ作成・ネットワーク接続を行わない。
8. 共有状態は確認対象外であることを認識する。

既存スクリプトに問題があれば実行せず報告する。無断修正しない。

## Step 2：既存GUIからのACL確認

ユーザーによる手動確認、または既に許可されたGUIの非変更操作で次を確認する。

対象：

RESOURCE-CLONE-Aのルートフォルダーのみ。

確認項目：

- ACL継承が有効か無効か
- 許可先の匿名主体区分
- Allow/Deny
- Read/List/Modify/FullControl等の権限
- Explicit/Inherited
- Users、Authenticated Users、EveryoneのACE有無
- 既存共有の有無

フォルダー内部の列挙、Workbook Open、セキュリティ設定の編集は禁止する。

## Step 3：PowerShell確認の承認境界

既存PowerShellスクリプトによる確認は、ユーザーが対象と実行方法を限定して明示承認した場合のみ実施する。

承認前に以下を確認する。

- 対象は既知のローカルCloneルート1件
- 通常ユーザー権限
- Windows PowerShell 64bit
- 既存スクリプトの静的レビューPASS
- スクリプトが対象PCに既に存在するか
- 新規配置が必要なら、そのファイル作成も別承認
- 実行は1回のみ
- 画面出力のみ
- 実パスや識別情報を回答に含めない

実行ポリシーによって拒否された場合はSTOP。ExecutionPolicy変更、Bypass指定、昇格、再試行は禁止。

明示承認がなければPowerShellは実行しない。

## Step 4：Evidence整理

各結果について以下を区別する。

- GUI_OBSERVED
- USER_ATTESTED
- SCRIPT_OBSERVED
- PRIOR_EVIDENCE
- UNKNOWN

スクリプトでACL情報を取得しても、その結果はフォルダールートに限定する。

個別Workbook、継承例外、グループの実際の所属、別経路からのアクセスは確認済みにしない。

将来作成する専用Windowsユーザーの実効アクセス遮断もNOT_VERIFIEDを維持する。

## Step 5：報告形式

```yaml
F1Read01ACLCompletion:
  Target: RESOURCE_CLONE_A
  Scope: ROOT_DIRECTORY_ONLY

  ACLInheritance:
    Status: ENABLED / DISABLED / UNKNOWN
    Evidence: [...]

  PrincipalRules:
    - AnonymousID: [...]
      PrincipalType: [...]
      AccessType: ALLOW / DENY / UNKNOWN
      Permissions: [...]
      ExplicitOrInherited: [...]

  CommonPrincipalACEs:
    Users: PRESENT / ABSENT_IN_ROOT_ACL / UNKNOWN
    AuthenticatedUsers: PRESENT / ABSENT_IN_ROOT_ACL / UNKNOWN
    Everyone: PRESENT / ABSENT_IN_ROOT_ACL / UNKNOWN

  ExistingShare:
    Status: NO_USER_ATTESTED / GUI_VERIFIED / UNKNOWN

  ChildResourceACL:
    NOT_VERIFIED

  FutureDedicatedUserEffectiveAccess:
    NOT_VERIFIED

  Script:
    StaticReview: PASS / REVIEW_REQUIRED
    ExecutionAuthorization: NOT_GRANTED / EXPLICITLY_GRANTED
    Executed: FALSE / TRUE

  RemainingUnknowns:
    [...]

F1Read01Decision:
  COMPLETE_WITH_LIMITATIONS / REVIEW_REQUIRED / BLOCKED

C1OverallAssessment: C1_REVIEW_REQUIRED

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

EnvironmentMutation: NONE
WorkbookMutation: NONE
ACLModified: FALSE
WindowsUserCreated: FALSE
ExcelClosedByTask: FALSE
GitOperation: NONE
FixtureCreated: FALSE
PreflightExecuted: FALSE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

## 終了条件

ACL情報を整理して報告し、停止する。

F1-3～F1-5、AUTH-01～AUTH-06には進まない。

既存Closure、限定付きEvidence、Finding／Observation、Baseline履歴を維持する。
