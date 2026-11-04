# S5-B F1-READ-01 Clone ACLスクリプト静的確認結果

F1Read01Decision: REVIEW_REQUIREDです。添付スクリプトの静的確認のみ行い、スクリプト実行・Cloneへのアクセス・GUI操作は行っていません。

## 静的レビュー結果

| 確認項目 | 結果 |
| --- | --- |
| ACL取得対象 | Get-Aclの対象は入力されたルート1件。ただし、補助的な読取り範囲に確認事項あり |
| 子要素・Workbook内容 | 列挙・内容読取りの処理なし |
| ファイル・フォルダー・ACL変更 | 該当処理なし |
| 匿名化 | 結果行は匿名ID・主体区分で出力。実名・SID・実パスの明示出力なし |
| 昇格・実行ポリシー変更 | 該当処理なし。対象PCの実行条件は未確認 |
| ファイル出力・ログ作成 | スクリプト自身には該当処理なし |
| ネットワーク接続 | 明示的な接続処理はないが、下記のパス検査順序について確認が必要 |
| 共有状態 | 明示的に対象外と記載。共有なしの証拠にはならない |

構文解析エラーは0件でした。ただし、Windows PowerShell 64bitでの実行確認ではありません。

## PASSにできない確認事項

1. ルートACL以外の補助読取り

   63・70行目で、Get-LocalUser／Get-LocalGroupにより全ローカルユーザー・グループを列挙します。匿名分類用で出力はされませんが、この読取りを今回の許可範囲に含めるか確認が必要です。

2. パスの安全確認より先に対象へアクセス

   31行目で対象のGet-Itemを行った後、37行目以降で対象から祖先へReparsePointを検査しています。拒否前のアクセスまで防止できる順序とは確認できず、「既知ローカルClone以外へアクセスしない」を無条件にPASSにはできません。

3. 入力行の機微情報

   結果本文は匿名化されていますが、実パスを入力する行を含む画面を、そのまま共有Evidenceにしない配慮が必要です。

無断修正はしていません。確認した添付のSHA-256は次のとおりです。対象PC上の既存ファイルとの一致は未確認です。

```text
7e93127bc1571ec28f47862dade6995849caed821735daa1e8c4f1c6fd4800ca
```

## ACL補完状況

対象PCの実測ACLやGUI確認結果は今回共有されていないため、値は補完していません。CloneUnderOneDrive: NO_USER_ATTESTEDを「共有なし」の根拠にも使用していません。

```yaml
F1Read01ACLCompletion:
  Target: RESOURCE_CLONE_A
  Scope: ROOT_DIRECTORY_ONLY

  ACLInheritance:
    Status: UNKNOWN
    Evidence: [UNKNOWN]

  PrincipalRules: []  # 未取得。ACEが0件という意味ではない

  CommonPrincipalACEs:
    Users: UNKNOWN
    AuthenticatedUsers: UNKNOWN
    Everyone: UNKNOWN

  ExistingShare:
    Status: UNKNOWN

  ChildResourceACL: NOT_VERIFIED
  FutureDedicatedUserEffectiveAccess: NOT_VERIFIED

  Script:
    StaticReview: REVIEW_REQUIRED
    ExecutionAuthorization: NOT_GRANTED
    Executed: FALSE

  RemainingUnknowns:
    - ルートの継承状態とACE実測値
    - 既存共有の有無
    - 補助的なアカウント列挙の承認範囲
    - 対象パスの安全性と実行方法
    - 対象PC上のスクリプト存在・同一性
    - 子要素の継承例外・実際のグループ所属・別経路アクセス
    - WorkbookPhysicalIdentity

F1Read01Decision: REVIEW_REQUIRED
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

最小の次手段は、ユーザーが既存GUIから確認したルートの継承状態、匿名化したACE行、共有の有無を転記する方法です。スクリプト経由の場合は、上記確認事項を解消して静的レビューPASS後、対象・方法を限定した別途実行承認が必要です。

F1-3～F1-5、AUTH-01～AUTH-06には進まず、既存Closure・限定付きEvidence・Finding／Observation・Baseline履歴を維持して停止します。
