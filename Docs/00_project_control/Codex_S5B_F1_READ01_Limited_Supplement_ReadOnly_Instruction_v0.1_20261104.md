# S5-B F1-READ-01 未完了項目の限定補完確認

## 目的

`S5B-TestPC-01`について、F1-READ-01で残った次の2項目のみをRead-onlyで補完する。

1. WorkbookとOneDriveの配置関係
2. RESOURCE-CLONE-AのACL継承・権限の詳細

既存のUSER_ATTESTEDとPRIOR_EVIDENCEを保持する。

今回はWindowsユーザー作成・切替、Excel操作、ACL変更、Git操作、同期変更を行わない。

## 確認A：Workbook配置関係

ユーザーに以下を確認する。

- 以前の「OneDrive内にWorkbookがある」という申告は、現在も有効か、それとも訂正か。
- `WB-CLONE-A`と`WB-OD-A`が「同一」とは、実際に同じファイルを参照している意味か、同じ版・内容という意味か。
- 同じファイルの場合、OneDriveとCloneの関係をどう認識しているか。

実パス、アカウント情報、Workbook内容は取得しない。

回答が不明な場合、`WorkbookPhysicalIdentity: UNKNOWN`を維持する。

## 確認B：CloneのACL

既知の`RESOURCE-CLONE-A`について、ユーザーがエクスプローラーの既存プロパティ表示から確認できる範囲だけを受け取る。

- 継承が有効か無効か
- 許可対象がユーザー、ローカルグループ、組込み主体のどれか
- 許可の種類（読取り、一覧表示、変更、フルコントロール等）
- 権限が明示的か継承か
- Users、Authenticated Users、Everyone等の共通主体の許可があるか
- 既存共有の有無

実ユーザー名、SID、実パスは記載しない。

プロパティ確認に管理者昇格、内容のOpen、権限変更が必要なら停止してUNKNOWNとする。

親フォルダーの情報だけで個別Workbookまで判定しない。

## 判定

今回の補完確認後、以下を報告する。

```yaml
F1Read01Decision: COMPLETE_WITH_LIMITATIONS / REVIEW_REQUIRED / BLOCKED

WorkbookLocationReconciliation:
  Status: RESOLVED / REVIEW_REQUIRED
  Evidence: USER_ATTESTED
  IndependentVerification: NOT_VERIFIED

CloneACL:
  Inheritance: [value / UNKNOWN]
  PrincipalTypes: [value / UNKNOWN]
  DetailedPermissions: [value / UNKNOWN]
  EffectiveAccessForFutureUser: NOT_VERIFIED

DedicatedUser:
  Existing: NO_USER_ATTESTED
  CreationAuthorized: FALSE

C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

EnvironmentMutation: NONE
WorkbookMutation: NONE
WindowsUserCreated: FALSE
ExcelClosedByTask: FALSE
GitOperation: NONE
PreflightExecuted: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
```

上記を報告して停止する。

F1-3～F1-5、AUTH-01～AUTH-06には進まない。

既存Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴を維持する。
