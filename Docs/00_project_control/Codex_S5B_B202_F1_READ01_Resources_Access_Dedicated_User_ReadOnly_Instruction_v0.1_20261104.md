# S5-B B2-02-F1-READ-01

## Production資源の配置・アクセス境界と専用Windowsユーザーの静的確認

### Codex限定Read-only実行指示 v0.1

## 1. 目的・今回の承認範囲

対象環境：`S5B-TestPC-01`

目的は、A＋C1（PC全体のネットワーク制限＋専用Windows標準ユーザー）の実装可能性を判断するため、F1-1およびF1-2の既存情報を収集することである。

今回の実施範囲：

- 既知のProduction関連資源の配置関係の確認
- 既存のフォルダーACL・継承・共有設定の静的確認
- 専用Windows標準ユーザーの存在・権限条件の確認
- 既存Excel／VBEインストール情報と専用ユーザー利用条件の整理
- 残留UNKNOWNと次回の追加承認事項の報告

**実行承認は上記の非変更確認のみ。**

ユーザー作成、ユーザー切替、Excel操作、設定変更、Preflight実行は含めない。

## 2. 前提状態

```yaml
Environment: S5B-TestPC-01
S5BReuseStrategy: OPTION_B_SELECTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B202Decision: REVIEW_REQUIRED
B202F1Plan: READY_FOR_USER_REVIEW
B202F1Assessment: C1_REVIEW_REQUIRED

RecommendedOption: A_PLUS_C1_CONDITIONAL_CANDIDATE
AlternativeOption: A_PLUS_C2_REVIEW_CANDIDATE

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

LocalClone:
  Present: USER_ATTESTED
  CurrentUserCanAccess: YES_USER_ATTESTED
  ReportedRevision: edf5c5175b103e250144341071d885a3a992c65f
  RevisionVerified: FALSE

ValidationWorkbook:
  Name: MailGeneratorNew.xlsm
  OneDriveLocation: USER_ATTESTED_PREVIOUS
  CloneLocation: USER_ATTESTED_LATEST
  SamePhysicalFile: UNKNOWN

ExistingExcel:
  LastReportedPID: 6252
  CurrentState: UNKNOWN
  ClosureAuthorized: FALSE

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

今回の確認によって過去のUSER_ATTESTED情報を独立検証済みに変更しない。

## 3. 調査方法と厳格な境界

使用できる情報源：

1. ユーザーが既に把握している配置・アカウント情報
2. 既存のB2-01／B2-02／F1計画Evidence
3. ユーザーが手動で確認するWindows標準GUIの既存状態表示
4. Codexが承認された範囲で安全に参照できるWindows標準GUIの非変更表示

今回の許可対象GUI：

- エクスプローラーの既知対象のプロパティ
- Windowsの設定にある既存アカウント情報表示
- 既存のExcel／Officeインストール情報の表示

操作できないGUIについてはユーザー手動確認に切り替える。

前回アクセス拒否・タイムアウトとなった操作を自動再試行しない。

**禁止する調査手段：**

- PowerShell、コマンドプロンプト、CIM、Registry再照会
- 新規調査スクリプト
- 管理者権限への昇格
- Gitコマンド
- PC全体のファイル探索
- Production Workbook／Repository内容のOpen
- 新規共有接続、クラウドサインイン、到達性テスト
- ファイルのコピー、移動、削除
- 新規Evidenceファイルやスクリーンショットの保存

作業を実行するために禁止された操作が必要な場合、その項目はUNKNOWNとして停止する。

## 4. F1-1：既存資源の配置関係

### 4.1 対象の分類

以下を別々の資源として扱う。

| 識別子 | 対象 |
|---|---|
| RESOURCE-CLONE-A | 既存ローカルGitHub Clone |
| WB-CLONE-A | Clone内にあると申告されたWorkbook |
| WB-OD-A | OneDrive管理下にあると申告された検証用Workbook |
| EVIDENCE-A | 既知のEvidence Archiveまたは複製 |

同じ名前でも、同一物理ファイルであると推定しない。

実パスはユーザー側で確認する。報告には可能な限り上記の識別子を使用する。

### 4.2 最小確認項目

**RESOURCE-CLONE-A**

- 所在はローカルディスクか
- OneDrive管理領域の内側か外側か
- 既存Production原本とは別実体か
- 現在のWindowsユーザーによるアクセスについて既知の情報
- 他のユーザー・サービスからの共有可能性
- ACLと継承の既知情報

**WB-CLONE-A／WB-OD-A**

- 各Workbookの既知の所在
- OneDrive管理下か
- Clone内にあるか
- 同一実体と確認できる根拠の有無
- 別コピーの存在について把握済みの情報

**EVIDENCE-A**

- 検証PC上に既知の複製があるか
- 存在する場合、実行主体からのアクセス制御が必要か
- 所在が不明な場合はUNKNOWN

### 4.3 GUI確認方法

ユーザーが既知の対象フォルダーを特定できる場合のみ、エクスプローラーのプロパティ画面で以下を確認してよい。

- 全般：ドライブ・場所の分類
- セキュリティ：表示可能なアクセス許可
- 詳細設定：継承の状態
- 共有：既存の共有状態

Productionフォルダー内部の内容列挙やWorkbook Openは行わない。

プロパティ参照にも新規接続、クラウドからの取得、昇格等が必要な場合は停止する。

ACL変更やアクセス許可の編集画面への操作は行わない。

表示できない項目はUNKNOWN。

### 4.4 判定上の注意

親フォルダーのACLだけで全子ファイルのアクセスを断定しない。

個別ACL、継承例外、共有権限、クラウド同期、別経路を考慮する。

専用Windowsユーザーが存在しない場合、そのユーザーに対する実効アクセスは未検証のままとする。

既存資源の内容・ACLを変更せずにアクセス境界を構成する見込みだけを評価する。

## 5. F1-2：専用Windowsユーザー

### 5.1 既存アカウントの確認

Windowsの既存アカウント表示から、以下を確認する。

- 検証専用に利用可能なユーザーが既に存在するか
- 存在する場合、標準ユーザーか管理者か
- そのユーザーがProduction作業に利用されていないか
- Production用認証情報やクラウドアカウントを共有していないか
- 新規ユーザーの作成が必要か

必要ならユーザーの申告を受け付ける。

実ユーザー名、メールアドレス、SID等の識別子は回答に記載しない。

既存ユーザーが存在しない場合、`DEDICATED_USER_NOT_PRESENT`とする。

### 5.2 Windows権限とアクセス境界

専用ユーザー候補について、次を設計条件として整理する。

- 標準ユーザーとして実行できるか
- Administrators等の特権グループとの関係
- 既存Productionフォルダーのアクセス許可との関係
- 共通ユーザー・共有フォルダー等を通じたアクセス経路
- 既存クラウド認証情報を継承する可能性
- Windowsアカウント作成時に必要となる権限

まだ存在しないユーザーについて、所属グループや実効権限を確認済みと扱わない。

Windowsユーザーの新規作成・初回サインイン・権限変更は行わない。

### 5.3 Excel／VBE利用条件

既存Evidence：

```yaml
ExcelInstalled: YES
ExcelArchitecture: 64bit
ExcelVersion: 16.0.19127.20860
OfficeProductReleaseId: Personal2019Retail
VBEStaticEvidence: PRESENT
```

確認項目：

- 専用ユーザーから既存Excelを利用するための前提条件
- ユーザーごとのOffice初期設定の必要性
- Office認証・ライセンスに関する既知の条件
- Excel／VBE利用に管理者権限が必要となる可能性
- 既存Production用Office設定や認証情報から分離できるか

ユーザーが把握しているOffice利用条件を受領してよい。

ただし以下は禁止する。

- 専用ユーザーへのサインイン
- Excel／VBEの新規起動
- Office認証状態を変更する操作
- アドインやTrust Center設定の変更
- ライセンス認証を伴う操作

静的インストール情報が存在しても、専用ユーザーでの利用可能性をPASSにしない。

Office 2019のサポート終了は残留リスクとして維持するが、これだけで利用不可能とは判定しない。

## 6. F1-READ-01判定基準

### COMPLETE_WITH_LIMITATIONS

F1-1とF1-2の対象を整理でき、確認済み情報と重要なUNKNOWNを区別し、C1成立可能性を評価する材料が得られた。

ただし、隔離成立や実効アクセス不可を意味しない。

### REVIEW_REQUIRED

資源の配置関係、専用ユーザーの有無、アクセス境界等に、方式判断を妨げる重要な情報不足がある。

未確認項目と追加確認方法を提示する。

### BLOCKED

非変更・通常権限の方法では重要な確認を実施できず、許可された範囲で続行できない。

未承認の変更や権限昇格で解決しない。

## 7. C1の設計上の評価

F1-READ-01の結果から次を評価する。

```text
F1LocalBoundaryDesign:
  CONDITIONALLY_FEASIBLE /
  REVIEW_REQUIRED /
  NOT_FEASIBLE_UNDER_CONSTRAINTS

F1DedicatedUserAndExcel:
  CONDITIONALLY_FEASIBLE /
  REVIEW_REQUIRED /
  NOT_FEASIBLE_UNDER_CONSTRAINTS
```

判断できるのは静的な設計上の成立見込みまで。

F1-3～F1-5が未調査であることを維持し、A＋C1の総合成立を宣言しない。

専用ユーザーからの実効アクセス遮断は、将来のAUTH-03までNOT_VERIFIEDとする。

## 8. STOP条件

次の場合、該当する確認を中止する。

- アカウント作成・切替・サインインが必要
- Excel／Workbookの操作が必要
- ACL・共有・同期設定変更が必要
- Production内容の読取りが必要
- 管理者権限への昇格が必要
- 認証情報の入力が必要
- クラウドデータの新規取得が必要
- GUI操作のタイムアウト・アクセス拒否
- 予定外の環境変更が発生した

想定外の変更が発生した場合は全体を停止する。

自動Retry、Rollback、復元、同期再開は禁止する。

## 9. 報告形式

```yaml
B202F1Read01:
  Authorization: LIMITED_READ_ONLY
  Environment: S5B-TestPC-01

  Observation:
    Timestamp: [value]
    TimeZone: Asia/Tokyo
    Method: [USER_MANUAL_GUI / CODEX_GUI / PRIOR_EVIDENCE]
    Scope: F1_1_AND_F1_2_ONLY

  ResourceLocations:
    Clone:
      LocationClass: [LOCAL / CLOUD_MANAGED / UNKNOWN]
      UnderOneDrive: [YES / NO / UNKNOWN]
      Evidence: [classification]

    WorkbookInClone:
      Existence: [status]
      Evidence: [classification]

    WorkbookInOneDrive:
      Existence: [status]
      Evidence: [classification]

    WorkbookPhysicalIdentity:
      SameFile: [YES / NO / UNKNOWN]
      VerificationMethod: [method / NOT_VERIFIED]

    EvidenceCopies:
      Status: [value / UNKNOWN]

  AccessBoundary:
    KnownACL: [status / UNKNOWN]
    Inheritance: [status / UNKNOWN]
    SharePaths: [status / UNKNOWN]
    DedicatedUserEffectiveAccess: NOT_VERIFIED
    DesignAssessment: [assessment]

  DedicatedUser:
    Existing: [YES / NO / UNKNOWN]
    StandardUser: [YES / NO / UNKNOWN]
    GroupMembership: [status / UNKNOWN]
    ProductionCredentialSeparation: [status / UNKNOWN]
    CreationRequired: [YES / NO / UNKNOWN]

  ExcelForDedicatedUser:
    InstallationEvidence: PRESENT
    RuntimeAvailability: NOT_VERIFIED
    VBEAvailability: NOT_VERIFIED
    LicenseAndActivationConditions: [status / UNKNOWN]
    DesignAssessment: [assessment]

  EvidenceClassification:
    [item-specific evidence and limitations]

  RemainingUnknowns:
    [...]

  F1Read01Decision:
    COMPLETE_WITH_LIMITATIONS /
    REVIEW_REQUIRED /
    BLOCKED

  C1OverallAssessment: C1_REVIEW_REQUIRED

  IsolationMethodSelected: NONE
  IsolationEstablished: NOT_VERIFIED

  EnvironmentMutation: NONE
  WorkbookMutation: NONE
  FilesCreatedOrModified: NONE
  GitOperation: NONE

  WindowsUserCreated: FALSE
  UserSwitched: FALSE
  ExcelStartedByTask: FALSE
  ExcelClosedByTask: FALSE
  FixtureCreated: FALSE
  VBACompileExecuted: FALSE
  PreflightExecuted: FALSE

  S5BTargetBuildCompile: NOT_VERIFIED
  S5CStarted: FALSE
  P2_05CompletionRecorded: FALSE
  CP_P2Established: FALSE
```

実施できなかった項目は、UNKNOWN理由を明示する。

新たな接続や環境変更を行わず、報告して停止する。

## 10. 終了境界

今回の確認が完了しても、次は自動実施しない。

- F1-3起動追加物の追加調査
- F1-4ネットワーク・オフライン運用調査
- F1-5保存先・Evidence調査
- 専用Windowsユーザー作成
- 既存Excel終了
- A＋C1の正式採用
- AUTH-01～AUTH-06
- Preflight実行

既存のS1～S4 Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴、残留UNKNOWNを維持する。
