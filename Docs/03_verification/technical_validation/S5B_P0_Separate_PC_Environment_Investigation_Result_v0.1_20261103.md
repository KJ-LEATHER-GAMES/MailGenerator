# S5-B-P0 別PC環境調査結果（2026-10-25）

判定は **REVIEW_REQUIRED** です。Excel 64bitとVBE DLLの静的存在は確認でき、採用候補にはなります。ただし、Production遮断と起動追加物の安全性は確認できていません。Preflightは実行せず、調査を終了しました。

```yaml
S5BP0Authorization: APPROVED_READ_ONLY

Investigation:
  Start: "2026-10-25 16:07:44 +09:00"
  End: "2026-10-25 16:09:38 +09:00"
  TimeZone: Asia/Tokyo
  Scope: LOCAL_PC_ONLY

Environment:
  Type: SEPARATE_PC
  Alias: S5B-TestPC-01
  OSEdition: "Home相当（EditionID: Core）"
  OSVersion: "26H2（Registry値）"
  OSBuild: "26300.9711"
  OSArchitecture: 64bit
  OSProductNameRegistry: "Windows 10 Home"
  OSProductNameConsistency: UNKNOWN
  UpdateStatus: UNKNOWN
  CurrentPrivilege: NON_ELEVATED
  AdministratorGroupMembership: UNKNOWN

Excel:
  Installed: YES
  ProductReleaseId: Personal2019Retail
  Version: "16.0.19127.20860"
  Architecture: 64bit
  ExecutableExists: YES
  Executable: 'C:\Program Files\Microsoft Office\Root\Office16\EXCEL.EXE'
  VBEStaticEvidence: PRESENT
  VBEFileVersion: "7.01.1158"
  VBEUsability: UNKNOWN
  ExistingExcelProcess: NO
  ExcelStartedByThisTask: FALSE

ProductionIsolation:
  LocalResources: UNKNOWN
  KnownWorkspaceGitMetadata: NONE_IDENTIFIED
  ProductionRepositoryOrWorkbookLocations: UNKNOWN
  OneDrive: UNKNOWN
  SharesAndVPN: UNKNOWN
  FileSystemDrivesObserved: [C, G]
  DriveGType: UNKNOWN
  USBAndExternalStorage: UNKNOWN
  NetworkAndFirewallProfiles: UNKNOWN
  ExistingRoutesToProduction: UNKNOWN
  NetworkIsolation: UNKNOWN
  Overall: REVIEW_REQUIRED

Startup:
  XLSTART: REVIEWED
  UserXLSTART:
    Existing: YES
    ImmediateItemCount: 0
  Office64bitXLSTART:
    Existing: YES
    ImmediateItemCount: 0
  Office32bitXLSTART:
    Existing: NO
  AlternateStartupFolder: UNKNOWN
  ExcelAddins: UNKNOWN
  COMAddins: UNKNOWN
  OtherOfficeStartupSettings: UNKNOWN
  StartupSafety: REVIEW_REQUIRED

Storage:
  Candidate: 'C:\S5B_Preflight\'
  Existing: NO
  ExistingObjectCollision: NONE_IDENTIFIED
  ACL: REVIEWED
  ACLScope: PARENT_DIRECTORY_ONLY
  WriteCapability: UNKNOWN
  OneDriveOrShareRelationship: UNKNOWN
  Capacity: "約34.97 GiB空き（37,550,637,056 bytes）"
  Approved: FALSE

Fixture:
  Specification: DEFINED
  SpecificationBasis: USER_INSTRUCTION
  SpecificationIndependentlyVerified: FALSE
  Created: FALSE

EvidenceRetention:
  Proposal: 90_DAYS
  Status: PROPOSED
  Approved: FALSE

S5BP0SuitabilityDecision: REVIEW_REQUIRED

UnresolvedItems:
  - OS正式名称とRegistry表示の整合性
  - Windows更新状態
  - OneDrive同期設定・同期状態
  - 共有・マップドライブ・VPN・ネットワーク・Firewallの状態
  - USB／外部ストレージとGドライブの種別
  - Production資源の既知の配置場所と既存接続経路
  - 代替起動フォルダー・Excel Add-ins・COM Add-ins
  - 保存先の同期対象との関係および実際の書込み可否

PreflightAuthorization: NOT_GRANTED

ExcelStarted: FALSE
VBACompileExecuted: FALSE
SettingsModified: FALSE
FilesCreatedOrModified: NONE
GitOperation: NONE
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

確認方法と取得制限は次のとおりです。

| 対象 | Read-only確認方法・結果 |
| --- | --- |
| OS・権限 | 既存Registry、OSアーキテクチャ、現在トークンを照会。非昇格を確認。OSのCIM照会は失敗、`Get-HotFix`はアクセス拒否のためUNKNOWN。 |
| Excel・VBE | OfficeインストールRegistry、App Paths、既知の実行ファイル／DLLのVersion情報、`Get-Process`を使用。VBEの実使用可否は未検証。 |
| Production隔離 | OneDrive Registryはアクセス拒否。SMB、VPN、アダプター、接続Profile、Firewall、ディスク情報はCIM系エラーで取得不能。昇格・権限変更・拒否操作の再試行は未実施。 |
| ローカル資源 | 現在の作業フォルダーと既知の親フォルダーで`.git`の存在だけを確認し、いずれもなし。Productionの配置場所は未提示のため、資源不在とは判定しない。 |
| 起動追加物 | 既知のXLSTARTを直下列挙し、存在する2か所は空。Options、Excel Add-ins、COM Add-insのRegistry照会はアクセス拒否。 |
| 保存先 | 候補の存在、親`C:\`のACL、`.NET DriveInfo`で空き容量を確認。`Get-PSDrive`の空き容量表示は採用せず、直接取得値を使用。 |

親ACLには一般ユーザーの読取り権限や認証済みユーザーのフォルダー作成に相当する許可がありましたが、実効書込み権限は未検証です。保存先の正式採用はできません。

Preflight前には、まずProductionの配置場所・接続経路と遮断条件、未確認の起動追加物を確定する必要があります。そのうえで、保存先の正式採用と作成・書込み試験、Fixture作成、Excel起動・VBA Compileを含むPreflight実行について、対象と手順を限定した追加承認が必要です。90日保持案も未承認のままです。
