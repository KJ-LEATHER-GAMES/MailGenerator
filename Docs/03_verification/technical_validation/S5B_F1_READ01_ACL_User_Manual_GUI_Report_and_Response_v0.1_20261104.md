# S5-B F1-READ-01 ACL手動GUI確認報告と整理結果

> 保存時の匿名化：Prompt中の実パスを継承元識別子PARENT-A／PARENT-Bに、P01・P04の主体表記を匿名ラベルに置換した。同じ継承元には同じ識別子を使用し、報告されたACE・権限・適用先・継承元の対応を保持した。匿名ラベルは主体の詳細種別を認定するものではない。

## CodexへのPrompt

F1-READ-01のACL手動GUI確認結果を報告します。

確認対象：RESOURCE-CLONE-A（ルートフォルダーのみ）

確認方法：Windows標準GUI

証拠区分：USER_ATTESTED / USER_MANUAL_GUI

### ルートACLの各ACE

```text
PrincipalID       : P01
Principal         : REPORTED_PRINCIPAL_A
Type              : Allow
Access            : ReadAndExecute
Inherited from    : PARENT-A
AppliesTo         : This folder, subfolders and files

PrincipalID       : P02
Principal         : SYSTEM
Type              : Allow
Access            : Full control
Inherited from    : PARENT-B
AppliesTo         : This folder, subfolders and files

PrincipalID       : P03
Principal         : Administrators
Type              : Allow
Access            : Full control
Inherited from    : PARENT-B
AppliesTo         : This folder, subfolders and files

PrincipalID       : P04
Principal         : REPORTED_PRINCIPAL_D
Type              : Allow
Access            : Full control
Inherited from    : PARENT-B
AppliesTo         : This folder, subfolders and files
```

### 共通主体のACE

- Users：UNKNOWN
- Authenticated Users：UNKNOWN
- Everyone：UNKNOWN

### 対象フォルダーの直接共有

- 共有なし

確認不能な項目はUNKNOWNとします。

既存ファイル、ACL、共有設定は変更していません。専用Windowsユーザーの作成、Excel操作、PowerShell実行、Preflight実行も行っていません。

取得したACL情報はルートフォルダーに限定し、個別Workbookや将来の専用ユーザーの実効アクセス遮断はNOT_VERIFIEDを維持してください。

## CodexからのResponse

受領しました。すべて **`USER_ATTESTED / USER_MANUAL_GUI`** として整理します。Codexによる独立観測には格上げせず、実パス・実ユーザー名は再掲しません。

### ルートACLの整理

| 匿名ID | 主体区分（申告に基づく） | 種類 | 権限 | 明示／継承 | 適用先 |
| --- | --- | --- | --- | --- | --- |
| P01 | カスタム主体・詳細種別UNKNOWN | Allow | ReadAndExecute | Inherited | このフォルダー・子フォルダー・ファイル |
| P02 | SYSTEM相当 | Allow | FullControl | Inherited | 同上 |
| P03 | Administrators相当 | Allow | FullControl | Inherited | 同上 |
| P04 | 匿名ユーザー相当・詳細種別UNKNOWN | Allow | FullControl | Inherited | 同上 |

これは**報告された4件**の整理です。主体のSID対応・実際のグループ所属、子要素への実効権限は確認済みにしません。

継承元の表示は記録しますが、ACL継承設定の有効／無効そのものは明示されていないため、UNKNOWNを維持します。

```yaml
F1Read01ACLCompletion:
  Target: RESOURCE_CLONE_A
  Scope: ROOT_DIRECTORY_ONLY
  Evidence: USER_ATTESTED / USER_MANUAL_GUI

  ACLInheritance:
    Status: UNKNOWN
    Evidence: 継承ACEの表示4件をユーザー報告として受領

  CommonPrincipalACEs:
    Users: UNKNOWN
    AuthenticatedUsers: UNKNOWN
    Everyone: UNKNOWN

  ExistingShare:
    Status: NO_USER_ATTESTED
    Scope: DIRECT_SHARE_ONLY

  ChildResourceACL: NOT_VERIFIED
  FutureDedicatedUserEffectiveAccess: NOT_VERIFIED

  Script:
    StaticReview: REVIEW_REQUIRED
    ExecutionAuthorization: NOT_GRANTED
    Executed: FALSE

  RemainingUnknowns:
    - ACL継承設定の有効／無効
    - 共通3主体のACE有無
    - 主体の詳細種別・グループ所属
    - 子要素の継承例外・別経路のアクセス
    - WorkbookPhysicalIdentity

F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
PreflightAuthorization: NOT_GRANTED

EnvironmentMutation: NONE_BY_CODEX
UserReportedChanges: NONE
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

「直接共有なし」は、親階層・管理共有・別経路も含めたアクセス遮断の証明には使用しません。

既存Closure・限定付きEvidence・Finding／Observation・Baseline履歴を維持し、F1-3～F1-5、AUTH-01～AUTH-06へ進まず停止します。
