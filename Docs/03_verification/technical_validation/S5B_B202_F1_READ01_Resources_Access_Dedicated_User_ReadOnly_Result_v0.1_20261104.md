# S5-B B2-02-F1-READ-01 資源配置・アクセス境界と専用Windowsユーザー静的確認結果

## Response1

**F1-READ-01はREVIEW_REQUIRED（手動確認待ち・未完了）です。** 配置、対象ACL、専用ユーザーの有無について確認を依頼しましたが、新たな回答はまだ得られていません。今回は新規GUI観測や環境調査を行わず、既存Evidenceを整理しました。

```
B202F1Read01:
  Authorization: LIMITED_READ_ONLY
  Environment: S5B-TestPC-01

  Observation:
    Timestamp: UNKNOWN
    ReviewStartedAt: "2026-10-25T22:51:05+09:00"
    TimeZone: Asia/Tokyo
    Method: PRIOR_EVIDENCE
    Scope: F1_1_AND_F1_2_ONLY
    CurrentGUIObservation: NOT_CHECKED
    UserManualConfirmation: PENDING

  ResourceLocations:
    Clone:
      ResourceID: RESOURCE-CLONE-A
      LocationClass: LOCAL
      UnderOneDrive: UNKNOWN
      Evidence: USER_ATTESTED
      EvidencePeriod: PRIOR_REPORT
      IndependentlyVerifiedByThisTask: FALSE

    WorkbookInClone:
      ResourceID: WB-CLONE-A
      Existence: PRESENT_USER_ATTESTED
      Evidence: USER_ATTESTED
      EvidencePeriod: PRIOR_REPORT

    WorkbookInOneDrive:
      ResourceID: WB-OD-A
      Existence: PRESENT_USER_ATTESTED_PREVIOUS
      Evidence: USER_ATTESTED
      CurrentLocationVerification: NOT_VERIFIED

    WorkbookPhysicalIdentity:
      SameFile: UNKNOWN
      VerificationMethod: NOT_VERIFIED

    EvidenceCopies:
      ResourceID: EVIDENCE-A
      Status: UNKNOWN

  AccessBoundary:
    CurrentUserAccessToClone: YES_USER_ATTESTED_PRIOR
    KnownACL: UNKNOWN
    Inheritance: UNKNOWN
    SharePaths: UNKNOWN
    DedicatedUserEffectiveAccess: NOT_VERIFIED
    DesignAssessment: REVIEW_REQUIRED

  DedicatedUser:
    Existing: UNKNOWN
    StandardUser: UNKNOWN
    GroupMembership: UNKNOWN
    ProductionCredentialSeparation: UNKNOWN
    CreationRequired: UNKNOWN

  ExcelForDedicatedUser:
    InstallationEvidence: PRESENT
    InstallationEvidenceSource: PRIOR_EVIDENCE
    ExcelArchitecture: 64bit
    ExcelVersion: "16.0.19127.20860"
    OfficeProductReleaseId: Personal2019Retail
    VBEStaticEvidence: PRESENT
    RuntimeAvailability: NOT_VERIFIED
    VBEAvailability: NOT_VERIFIED
    LicenseAndActivationConditions: UNKNOWN
    FirstSignInAndInitializationConditions: UNKNOWN
    ElevatedExecutionRequired: UNKNOWN
    DesignAssessment: REVIEW_REQUIRED

  EvidenceClassification:
    ClonePlacementAndCurrentUserAccess:
      Source: USER_ATTESTED
      Limitation: PRIOR_REPORT_NOT_INDEPENDENTLY_VERIFIED
    WorkbookLocations:
      Source: USER_ATTESTED
      Limitation: PHYSICAL_RELATIONSHIP_UNKNOWN
    ExcelAndVBEInstallation:
      Source: PRIOR_EVIDENCE
      Limitation: DEDICATED_USER_RUNTIME_NOT_VERIFIED
    TargetACLInheritanceAndSharing:
      Source: UNKNOWN
      Reason: AWAITING_TARGET_SPECIFIC_MANUAL_CONFIRMATION
    DedicatedUserInformation:
      Source: UNKNOWN
      Reason: AWAITING_MANUAL_CONFIRMATION
    NewDirectGUIEvidence:
      Status: NOT_CHECKED

  RemainingUnknowns:
    - CloneとOneDrive管理領域の関係
    - WB-CLONE-AとWB-OD-Aの物理的な同一性
    - EVIDENCE-A等の既知コピー
    - 対象資源のACL・継承例外・共有や別経路
    - 専用標準ユーザーの存在・所属グループ・認証情報分離
    - アカウント作成の必要性と必要権限
    - 専用ユーザーのOffice初期設定・認証・利用条件

  F1Read01Decision: REVIEW_REQUIRED
  Completion: INCOMPLETE
  C1OverallAssessment: C1_REVIEW_REQUIRED

  F1_3AdditionalInvestigation: NOT_CHECKED
  F1_4AdditionalInvestigation: NOT_CHECKED
  F1_5AdditionalInvestigation: NOT_CHECKED

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

Cloneの`LOCAL`は過去のローカル配置申告を表し、**OneDrive管理外・非同期領域という判定ではありません**。また、前回確認したCドライブ直下のACLは、対象CloneやWorkbookのACLとして流用していません。

現在の承認範囲で残る確認は以下です。

| 手動確認 | 得たい情報 |
| --- | --- |
| 既知フォルダーの場所・把握済み配置情報 | CloneがOneDrive管理内か外か、Workbook同士の関係、Evidenceコピーの有無 |
| 対象フォルダーのプロパティ | 表示可能なアクセス許可、継承、既存共有。編集・内部列挙・クラウド取得は行わない |
| 既存アカウント表示・把握済みOffice条件 | 専用ユーザーの有無、標準／管理者の別、Production認証情報との分離、既知の初期設定・認証条件 |

ユーザーが存在しないとの確認はまだないため、`DEDICATED_USER_NOT_PRESENT`とは記録しません。静的インストール情報も、専用ユーザーでのExcel／VBE利用可能性の証明にはしません。Office 2019のサポート終了リスクは維持しますが、利用不可能とは判定しません。

確認にユーザー作成・切替・サインイン、Excel操作、認証、設定変更、昇格等が必要なら、その項目をUNKNOWNとして停止し、別承認対象とします。既存Closure、限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴、残留UNKNOWNを維持し、ここで停止します。

## Prompt2

**把握済みの配置情報と、必要なら既知フォルダーのプロパティだけで教えてください：①RESOURCE-CLONE-Aはローカルディスク上か、OneDrive管理内か外か、②WB-CLONE-AとWB-OD-Aは同一実体か別コピーか（同じ名前・版だけならUNKNOWN）、③EVIDENCE-Aの検証PC上の既知コピーはあるか。実パスは記載せず、UNKNOWNで構いません。フォルダー内部やWorkbookは開かず、クラウド取得・接続が必要なら停止してください。**

①ローカル。OneDrive管理外

②同一

③なし

**RESOURCE-CLONE-Aと、所在が分かる他の対象について、既知フォルダーのプロパティに表示される範囲で、①標準ユーザー共通グループ（Users／Authenticated Users／Everyone等）の読取り・一覧表示の許可、②継承の有無、③既存共有の有無を教えてください。実ユーザー名・SID・共有パスは不要です。許可の編集・継承切替はせず、権限要求や確認不能はUNKNOWNとして止めてください。**

①システムとAdministratorとCodexと本人のみ許可

②Unknown

③共有無し

**既存アカウントの表示または把握済み情報から、①検証専用ユーザーは既に存在するか、②存在する場合は標準／管理者の別とProduction・クラウド認証情報の分離状況、③専用ユーザーで既存Office 2019を利用する際の既知の初期設定・認証条件を教えてください。アカウント名は不要です。ユーザー作成・切替・サインイン・Office起動・認証は行わず、不明はUNKNOWNで構いません。**

ユーザーは私一人で管理者でもあります。Officeの利用は可能です。

## Response2

**F1-READ-01はREVIEW_REQUIREDを維持します。** 今回の回答をUSER_ATTESTEDとして反映しました。専用ユーザーは未存在で、A＋C1を選定する場合は新規作成が必要です。ACLの継承、許可の詳細、専用ユーザーのOffice条件は未確認です。

```
B202F1Read01:
  Authorization: LIMITED_READ_ONLY
  Environment: S5B-TestPC-01

  Observation:
    Timestamp: UNKNOWN
    TimestampReason: USER_OBSERVATION_TIME_NOT_SUPPLIED
    TimeZone: Asia/Tokyo
    Method: USER_MANUAL_GUI
    EvidenceSource: USER_ATTESTED
    CodexDirectGUIObservation: NONE
    Scope: F1_1_AND_F1_2_ONLY

  ResourceLocations:
    Clone:
      ResourceID: RESOURCE-CLONE-A
      LocationClass: LOCAL
      UnderOneDrive: NO
      Evidence: USER_ATTESTED

    WorkbookInClone:
      ResourceID: WB-CLONE-A
      Existence: PRESENT_USER_ATTESTED
      Evidence: USER_ATTESTED

    WorkbookInOneDrive:
      ResourceID: WB-OD-A
      Existence: PREVIOUSLY_REPORTED
      LatestIdentityReport: SAME_AS_WB_CLONE_A
      CurrentOneDriveManagement: UNKNOWN
      Evidence: USER_ATTESTED

    WorkbookPhysicalIdentity:
      SameFile: YES
      VerificationMethod: USER_DECLARATION
      IndependentTechnicalVerification: NOT_VERIFIED
      PreviousOneDriveLocationReconciliation: UNKNOWN

    EvidenceCopies:
      ResourceID: EVIDENCE-A
      Status: NONE_KNOWN_USER_ATTESTED
      WholePCSearchPerformed: FALSE

  AccessBoundary:
    KnownACL: PARTIALLY_REPORTED_USER_ATTESTED
    ReportedAllowedPrincipals:
      - SYSTEM_PRINCIPAL
      - ADMINISTRATIVE_PRINCIPAL
      - TASK_RELATED_PRINCIPAL_A
      - CURRENT_USER
    DetailedPermissions: UNKNOWN
    PrincipalTypesAndMemberships: UNKNOWN
    Inheritance: UNKNOWN
    SharePaths: NO_SHARE_REPORTED_FOR_RESOURCE_CLONE_A
    ShareEvidence: USER_ATTESTED
    DedicatedUserEffectiveAccess: NOT_VERIFIED
    DesignAssessment: REVIEW_REQUIRED

  DedicatedUser:
    Existing: NO
    Status: DEDICATED_USER_NOT_PRESENT
    Evidence: USER_ATTESTED
    StandardUser: UNKNOWN
    GroupMembership: NOT_CREATED
    ProductionCredentialSeparation: NOT_VERIFIED
    CreationRequired: YES
    CreationCondition: IF_A_PLUS_C1_SELECTED
    CurrentUserAdministratorStatus: YES_USER_ATTESTED
    CreationAuthorized: FALSE

  ExcelForDedicatedUser:
    InstallationEvidence: PRESENT
    InstallationEvidenceSource: PRIOR_EVIDENCE
    ExcelArchitecture: 64bit
    ExcelVersion: "16.0.19127.20860"
    OfficeProductReleaseId: Personal2019Retail
    VBEStaticEvidence: PRESENT
    OfficeUsePossible: USER_ATTESTED
    DedicatedUserSpecificConditions: UNKNOWN
    RuntimeAvailability: NOT_VERIFIED
    VBEAvailability: NOT_VERIFIED
    LicenseAndActivationConditions: UNKNOWN
    FirstSignInAndInitializationConditions: UNKNOWN
    ElevatedExecutionRequired: UNKNOWN
    DesignAssessment: REVIEW_REQUIRED

  EvidenceClassification:
    LocalPlacementAndOneDriveExclusion: USER_ATTESTED
    WorkbookSameFileStatement: USER_ATTESTED
    NoKnownEvidenceCopies: USER_ATTESTED
    AllowedPrincipalsAndNoShareStatement: USER_ATTESTED
    DedicatedUserAbsenceAndCurrentUserRole: USER_ATTESTED
    OfficeUsePossibleStatement: USER_ATTESTED
    ExcelAndVBEInstallation: PRIOR_EVIDENCE
    ACLInheritanceAndEffectiveBoundary: UNKNOWN

  RemainingUnknowns:
    - 前回OneDrive配置申告と今回の配置・同一実体申告の整理
    - ACL継承・詳細な権限・各主体の種類と所属
    - 個別ファイルACL・継承例外・別経路
    - 新規専用ユーザーの実効権限と認証情報分離
    - 専用ユーザーでのOffice初期設定・認証・利用条件

  F1Read01Decision: REVIEW_REQUIRED
  C1OverallAssessment: C1_REVIEW_REQUIRED

  F1_3AdditionalInvestigation: NOT_CHECKED
  F1_4AdditionalInvestigation: NOT_CHECKED
  F1_5AdditionalInvestigation: NOT_CHECKED

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

今回の申告は、C1の検討材料になりますが、次の点は未確定です。

- **Workbookの配置関係**：「同一実体」という申告を受理しました。ただし、CloneがOneDrive管理外であることと、以前の「OneDrive内」という申告の関係は未整理です。以前の配置申告を訂正する趣旨かどうかを確認する必要があります。
- **ACLの範囲**：申告された許可先は匿名化して記録しました。各主体がユーザーかグループか、権限の内容、継承・個別例外は不明です。この一覧だけで将来の標準ユーザーのアクセス不可とは判定しません。「共有なし」も対象Cloneについての申告として扱います。
- **専用ユーザーとOffice**：専用ユーザー未存在は、不成立の証拠ではありません。「Office利用可能」は申告として保持しますが、未作成の専用ユーザーでの認証・初期設定・実行を検証した結果にはしません。現在ユーザーが管理者であることも、Excelに昇格が必要という証拠ではありません。

次に必要な非変更確認は、配置申告の整理と、対象ACLの継承・許可内容・主体の種類の補完です。確認に編集、昇格、サインイン、Excel操作等が必要ならUNKNOWNとして停止します。専用ユーザー作成・初回サインインはAUTH-02、実効アクセス境界の確認はAUTH-03、Excel起動・CompileはAUTH-05へ分離します。

Office 2019のサポート終了リスク、既存Closure、限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴、残留UNKNOWNを維持し、ここで停止します。
