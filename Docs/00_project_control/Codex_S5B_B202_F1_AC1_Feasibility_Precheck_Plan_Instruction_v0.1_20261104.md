# S5-B B2-02-F1

## A＋C1実装可能性の事前確認計画確定

### Codex Design-only指示 v0.1

## 1. 目的

既存別PC `S5B-TestPC-01`について、以下の隔離方式の実装可能性を判断するための、限定的な事前確認計画を確定する。

**A＋C1：PC全体のProduction関連ネットワーク経路制限＋専用Windows標準ユーザーによる隔離実行**

本計画では、既存のProduction原本、GitHub Clone、Workbook、Evidenceを変更しないことを基本制約とする。

今回の実施範囲は、既存Evidenceに基づく計画策定・判定条件の確定のみ。

新しい環境調査や実機操作は承認しない。

## 2. 前提状態

```yaml
S5BReuseStrategy: OPTION_B_SELECTED
Environment: S5B-TestPC-01

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B202Decision: REVIEW_REQUIRED

RecommendedOption:
  A_PLUS_C1_CONDITIONAL_CANDIDATE

AlternativeOption:
  A_PLUS_C2_REVIEW_CANDIDATE

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

ExistingClone:
  Present: USER_ATTESTED
  CurrentUserAccess: YES_USER_ATTESTED
  RevisionReported: edf5c5175b103e250144341071d885a3a992c65f
  RevisionVerified: FALSE

ExistingExcel:
  ContractRegressionCompleted: USER_ATTESTED
  LastObservedPID: 6252
  CurrentProcessState: UNKNOWN
  ClosureAuthorized: FALSE

CloudConnections:
  OneDrive: RUNNING_USER_ATTESTED
  GoogleDrive: RUNNING_USER_ATTESTED
  GitHubAccessPath: PRESENT_USER_ATTESTED

PreflightExecutionAuthorization: NOT_GRANTED
S5BTargetBuildCompile: NOT_VERIFIED
```

既存のClosure、限定付きEvidence、Finding／Observation、Baseline履歴、残留UNKNOWNを維持する。

## 3. 共通の確認原則

将来のF1確認において、次を遵守する計画とする。

1. 既存Production資源の内容を開かない。
2. 既存ファイル・フォルダー・ACLを変更しない。
3. 専用Windowsユーザーを今回作成しない。
4. Excel／VBEを今回起動・終了しない。
5. ネットワーク・同期・共有設定を今回変更しない。
6. 確認不能事項を推測でPASSにしない。
7. ユーザー申告と技術的に直接検証した結果を区別する。
8. 追加ツール・権限昇格・到達性試験が必要なら個別承認対象とする。

将来のRead-only確認でも、対象・方法・出力範囲を別途限定して承認する。

## 4. F1-1：Production資源とアクセス境界

### 確認対象

- ローカルGitHub Clone
- MailGeneratorNew.xlsmの検証用コピー
- OneDrive管理下の関連ファイル
- Evidence Archive等の既知コピー
- その他把握済みProduction関連資源

### 確認計画

以下を、既知の配置情報と承認された非変更確認手段により整理する。

1. Cloneの所在がOneDrive同期対象内か、独立したローカル領域か。
2. 開いているWorkbookとClone内Workbookの実体関係。
3. 別コピーやEvidenceの既知の配置関係。
4. 対象フォルダーのACLと継承。
5. 専用標準ユーザーに適用されるグループ権限。
6. 共有・別名・クラウドを経由するアクセス可能性。
7. 既存資源のACL変更なしでアクセス境界を成立させられるか。

具体的な実パスや個人情報は、必要な範囲で匿名化する。

### 判定条件

`F1LocalBoundaryDesign`を次の区分で評価する。

- `CONDITIONALLY_FEASIBLE`：必要な対象が特定され、既存資源を変更せずにアクセスを制限できる設計上の見込みがある。
- `REVIEW_REQUIRED`：対象、ACL、継承、実行主体等に重要なUNKNOWNがある。
- `NOT_FEASIBLE_UNDER_CONSTRAINTS`：既存資源を変更しない条件ではアクセス境界を実現できないことが確認された。

静的確認だけで実効アクセス遮断を検証済みとは認定しない。

既存資源の移動・削除・ACL変更が不可避であれば、C1を強行せず停止し、C2等の代替方式レビューへ戻す。

## 5. F1-2：専用WindowsユーザーとExcel

### 確認対象

**Windowsユーザー**

- 利用可能な専用標準ユーザーの有無
- 新規作成が必要か
- 作成に必要な権限
- Administrators等のグループ所属
- Production用認証情報との分離
- 既存ユーザープロファイルとの共有資源
- 実行時に昇格が必要になる可能性

**Excel／VBE**

- Excel 64bitの既存インストール
- 専用ユーザーに対する実行ファイル・コンポーネントのアクセス
- Excel／VBEの利用条件
- Office 2019 Personal Retailの認証・利用条件
- ユーザー初回サインイン時の初期設定や外部認証の必要性
- ユーザー単位とマシン全体のOffice設定

### 重要な制約

専用ユーザーの作成、サインイン、Excel起動、ライセンス認証は、今回実施しない。

専用ユーザーで利用できるという見込みと、実際にExcel／VBEを使用できた証拠は区別する。

Office 2019のサポート終了に伴うリスクは記録するが、それだけで専用ユーザーの利用可否を推定しない。

### 判定条件

`F1DedicatedUserAndExcel`：

- `CONDITIONALLY_FEASIBLE`
- `REVIEW_REQUIRED`
- `NOT_FEASIBLE_UNDER_CONSTRAINTS`

必要なアカウント作成・初回サインイン・認証操作と、それぞれの承認境界を明示する。

## 6. F1-3：Excel起動追加物

### 既存Evidence

```yaml
KnownXLSTARTFolders:
  ImmediateItemCount: 0
  Evidence: PRIOR_EVIDENCE

AlternateStartupFolder: UNKNOWN
ExcelAddins: UNKNOWN
COMAddins: UNKNOWN
MachineWideStartupComponents: UNKNOWN
```

### 確認計画

専用ユーザーを実行主体として、次を整理する。

- ユーザー単位のXLSTART
- マシン全体のXLSTART
- 代替起動フォルダー
- Excel Add-ins
- COM Add-ins
- Office起動関連サービス
- 既存Excelセッションとの独立性
- 初回ユーザープロファイル作成に伴う初期化処理

既知XLSTARTが空であることだけで安全性を認定しない。

確認のためExcel操作や設定変更が必要なら、操作対象・方法・停止条件を別承認対象として提案する。

### 判定条件

`F1StartupControl`：

- `CONDITIONALLY_FEASIBLE`
- `REVIEW_REQUIRED`
- `NOT_FEASIBLE_UNDER_CONSTRAINTS`

起動処理が不明なまま実機確認へ進む必要がある場合、その不明要素を明示して停止する。

## 7. F1-4：ネットワーク遮断・オフライン運用

### 確認対象

- OneDrive
- Google Drive
- GitHub
- 共有・マップドライブ
- VPN
- ブラウザーのクラウド接続
- その他のProduction関連ネットワーク経路

### 確認計画

1. PC全体で制御すべき経路を整理する。
2. Windowsユーザー単位の対策とPC全体の対策を区別する。
3. ネットワーク制限後に残るローカル資源へのアクセスを別途評価する。
4. CodexやGUI操作ツールが通信不能になる場合の手動運用を定義する。
5. オフラインでも安全制御の設定・読戻し・Compile操作・観測を行えるか評価する。
6. 誤って接続が再開した場合の停止条件を定義する。
7. 再接続・同期再開の必要性と承認境界を整理する。

今回はネットワークを切断しない。

通信制限を設定したことと、遮断が実効的に成立したことは区別する。

無通信の表示だけで遮断成立とはしない。

### 判定条件

`F1OfflineOperation`：

- `CONDITIONALLY_FEASIBLE`
- `REVIEW_REQUIRED`
- `NOT_FEASIBLE_UNDER_CONSTRAINTS`

## 8. 保存先・Evidence保全の前提条件

候補：

```text
C:\S5B_Preflight\
  fixture\
  evidence\
  logs\
```

正式採用前に以下を確認する計画とする。

- 非同期・非共有のローカル領域であること
- Production関連資源の領域外であること
- 専用ユーザーから必要なアクセスが可能であること
- その他のユーザーやサービスからのアクセス境界
- 既存物との衝突
- 実効書込み権限
- 容量
- ネットワーク制限下でのEvidence保全

今回、フォルダー作成・資材配置・書込み試験を行わない。

Evidence保持方針：

```yaml
RetentionProposal: 90_DAYS_AFTER_VERIFICATION
Approved: FALSE
UnresolvedEvidence: RETAIN_PENDING_DECISION
AutomaticDeletion: NONE
ResponsibleAuthority: USER
```

保持期間の起算点、保全方法、受渡し方法、復元時の扱いは追加承認対象とする。

## 9. GateとSTOP条件

| Gate | 将来の確認結果に必要な条件 | STOP条件 |
|---|---|---|
| F1-1 | 既知Production資源とアクセス境界を整理できる | 既存資源の変更が不可避、重要な対象が不明 |
| F1-2 | 専用標準ユーザーとExcel利用の必要条件を特定できる | 権限・認証・利用条件が確認不能 |
| F1-3 | 起動追加物の適用範囲と対処方法を特定できる | 未確認の追加物を安全と扱う必要がある |
| F1-4 | ネットワーク制限とオフライン運用を計画できる | 操作やEvidence保全を継続できない |
| F1-5 | 保存先・保持方針の追加承認条件が明確 | 未承認の作成・書込み・転送が必要 |

この段階のGateは、実行可能性の判断材料を得るためのものとする。

個々のGateが計画上成立しても、隔離実施PASSやPreflight PASSを意味しない。

## 10. F1の総合判定

次の3区分を使用する。

### C1_FEASIBLE_WITH_PRECONDITIONS

既存Production資源を変更せずにA＋C1を構成できる設計上の見込みがあり、必要な権限・確認方法・承認対象が明確。

ただし実機検証と隔離成立は未完了。

### C1_REVIEW_REQUIRED

重要な条件が不明で、A＋C1の構成可能性をまだ判断できない。

UNKNOWNを列挙し、最小限の追加確認方法を提示する。

### C1_NOT_FEASIBLE_UNDER_CONSTRAINTS

既存Production資源を変更しない条件では、必要な境界を実現できないことが確認された。

A＋C1の実施を推奨せず、A＋C2その他の方式レビューへ戻す。

**不明であることを不可能であることと混同しない。**

## 11. 将来の承認区分

次の区分を維持する。

- `F1-READ`：F1の限定Read-only確認。対象・方法・権限を別途承認。
- `AUTH-01`：既存Excel／VBEの通常終了。
- `AUTH-02`：選定された専用ユーザー、アクセス制御、ネットワーク制限等の構築。
- `AUTH-04`：保存先採用、Evidence記録・保持方針の承認。
- `AUTH-03`：構築後の隔離状態の確認。
- `AUTH-05`：SafeCompileFixtureとExcel Compile両立Preflight。
- `AUTH-06`：Production WorkbookのS5-B最終Compile再試行。

AUTH-04の保存・保全条件は、Evidenceを伴うAUTH-03の実施前に成立させる。

ネットワーク遮断前には、オフラインでの操作方法・観測方法・保全方法を確定する。

今回、上記の追加作業はすべて未承認とする。

## 12. 今回の禁止事項

- Windowsユーザーの作成・切替
- アカウント・認証情報・ACL変更
- Excel／VBE／Workbook起動・終了・保存
- OneDrive／Google Driveの操作
- ネットワーク・VPN・Firewall変更
- ProductionファイルのOpen・コピー・移動・削除
- Git操作
- 新規Registry／CIM／PowerShell調査
- VM／Sandbox構築
- フォルダー作成
- Evidenceファイル作成・転送・削除
- Fixture作成
- VBA Compile
- Preflight実行
- Baseline変更
- 自動Retry・Rollback

## 13. 報告形式

```yaml
S5BReuseStrategy: OPTION_B_SELECTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B202Decision: REVIEW_REQUIRED

B202F1:
  Scope: DESIGN_ONLY
  PlanStatus: READY_FOR_USER_REVIEW

  LocalBoundary:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  DedicatedUserAndExcel:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  StartupControl:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  OfflineOperation:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  StorageAndEvidence:
    PlanDefined: TRUE
    StorageApproved: FALSE
    RetentionApproved: FALSE

  FutureReadOnlyVerification:
    Authorization: NOT_GRANTED

  Assessment:
    C1_REVIEW_REQUIRED

RecommendedOption:
  A_PLUS_C1_CONDITIONAL_CANDIDATE

AlternativeOption:
  A_PLUS_C2_REVIEW_CANDIDATE

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

RequiredAdditionalEvidence:
  - KnownResourceLocationAndAccessBoundary
  - DedicatedUserAvailabilityAndPrivileges
  - ExcelAndVBEAvailabilityForDedicatedUser
  - StartupAdditions
  - NetworkRestrictionAndOfflineOperation
  - StorageAndEvidenceFeasibility

ExecutionAuthorization: NOT_GRANTED
EnvironmentMutation: NONE
WorkbookMutation: NONE
FilesCreatedOrModified: NONE
GitOperation: NONE

ExcelClosedByTask: FALSE
FixtureCreated: FALSE
VBACompileExecuted: FALSE
PreflightExecuted: FALSE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

## 14. 終了条件

B2-02-F1の確認計画を整理し、次の項目を報告して停止する。

1. F1-1～F1-4の確認項目と根拠取得方法。
2. 必要な最小追加確認。
3. 各確認に必要な承認境界。
4. C1の成立・不成立を判断する条件。
5. A＋C2へ切り替える条件。
6. 残留UNKNOWNとSTOP条件。

**計画確定をもってF1の実機調査、方式選定、隔離成立としないこと。**

既存のS1～S4 Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴、残留UNKNOWNを維持する。
