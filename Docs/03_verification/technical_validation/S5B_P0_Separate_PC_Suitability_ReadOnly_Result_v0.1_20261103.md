# S5-B-P0 別PC環境適合性確認結果

判定は `REVIEW_REQUIRED` です。

別PCの存在はユーザー申告として受領していますが、**対象の管理用識別子・承認済み操作経路・別PCで取得した確認結果が未提示**です。そのため、環境調査は実施していません。本番PCを代わりに調査したり、新しいリモート接続を開始したりしていません。

環境固有の項目はすべて`NOT_CHECKED`、値は`UNKNOWN`です。不適合が確認されたという意味ではありません。

## 次に必要な情報

別PCについて、次をユーザー側で確認・共有してください。ユーザー名、シリアル番号、資格情報は不要です。

| 項目 | 必要な確認結果 |
| --- | --- |
| 環境識別 | 任意の管理用別名、物理PC／仮想環境、通常利用時の権限種別 |
| OS | Edition、Version、Build、Architecture、確認できる更新状態 |
| Office | インストール情報・EXCEL.EXEの静的情報、ビット数、VBEコンポーネントの存在、既存Excelプロセスの有無 |
| Production隔離 | ローカル資源の有無に加え、同期・共有・マップドライブ・VPN・接続媒体等の既存経路 |
| 起動追加物 | XLSTART、代替起動フォルダー、Excel／COMアドインの既存設定 |
| 保存先 | 候補パスの存在・衝突・親ACL・共有／同期関係・空き容量。書込み試験は不要 |

分からない項目はUNKNOWNのままで構いません。Production資源へのアクセス試行やPingは行わず、既存設定の読取り結果だけを使用します。

既存の承認済み操作経路がある場合は、対象PCの管理用識別子と併せて指定してください。

```yaml
S5BP0Authorization: APPROVED_READ_ONLY

IsolationCandidate:
  EnvironmentType: SEPARATE_PC
  Existence: USER_ATTESTED
  Identification: UNKNOWN

OS:
  Edition: UNKNOWN
  Version: UNKNOWN
  Build: UNKNOWN
  Architecture: UNKNOWN

Excel:
  Installed: UNKNOWN
  Version: UNKNOWN
  Architecture: UNKNOWN
  VBEAvailability: UNKNOWN
  ExistingProcessState: UNKNOWN
  ExcelStarted: FALSE

ProductionIsolation:
  LocalProductionResources: UNKNOWN
  OneDrive: UNKNOWN
  NetworkShares: UNKNOWN
  NetworkIsolation: UNKNOWN
  Overall: REVIEW_REQUIRED

StartupEnvironment:
  XLSTART: UNKNOWN
  ExcelAddins: UNKNOWN
  COMAddins: UNKNOWN
  StartupSafety: REVIEW_REQUIRED

Storage:
  CandidatePath: 'C:\S5B_Preflight\'
  PathApproved: FALSE
  Existence: UNKNOWN
  ACLReviewed: FALSE
  Writable: NOT_TESTED
  SynchronizationRisk: UNKNOWN

Evidence:
  CapturePlan: DEFINED
  RetentionProposal: 90_DAYS
  RetentionApproved: FALSE

Fixture:
  Specification: DEFINED
  Created: FALSE

S5BP0SuitabilityDecision: REVIEW_REQUIRED

RemainingDecisions:
  - 対象PCの識別とRead-only確認結果の取得方法
  - 隔離条件の適合性評価
  - 保存先の正式採用
  - 90日保持案と未解決Evidenceの扱いの承認

PreflightExecutionAuthorization: NOT_GRANTED

ExcelStarted: FALSE
FixtureCreated: FALSE
CompileExecuted: FALSE
SettingsModified: FALSE
FilesCreatedOrModified: NONE
GitOperation: NONE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

既存のClosure・限定付きPASS・Finding／Observation・Baseline履歴・残留UNKNOWNを維持し、停止します。Preflight実行、設定変更、フォルダー作成は引き続き別承認です。
