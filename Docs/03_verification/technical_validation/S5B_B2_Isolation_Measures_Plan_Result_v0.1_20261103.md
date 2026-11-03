# S5-B B-2 隔離措置計画整理結果

**B2PlanDecisionはREADY_FOR_USER_REVIEWです。** 隔離方式は未選定、隔離成立はNOT_VERIFIEDです。以下を実施計画案とし、今回の環境操作は行いません。

Production原本の所在は、**S5B-TestPC-01とは別のPC（OTHER_PC）／USER_ATTESTED**として確定します。OneDrive上の検証用複製や、原本へのアクセス経路については引き続き確認が必要です。

隔離方式の比較は次のとおりです。

| 比較項目 | A：検証PCのネットワーク制限 | B：同期・接続経路の個別停止 | C：PC内の隔離実行領域 |
| --- | --- | --- | --- |
| Productionネットワーク経路 | 全対象経路を特定・遮断できれば広く制御できる。限定的な制限では未制御経路が残る | 同期以外の共有・ブラウザー・GitHub等への経路が残り得る | 実行領域からのネットワーク経路も制御する必要がある |
| 既存ローカル複製 | アクセス可能なまま残るため、別途対処が必要 | 同期停止後もキャッシュや通常ファイルが残る | 実行ユーザー・領域から複製へアクセスできない境界を検証する |
| 本番PCへの影響 | 本番PCの設定変更は対象外。PC間共有は利用できなくなる可能性がある | 共有データの更新が検証PCへ反映されなくなる。アカウント全体の変更は対象外 | 本番PCの変更は対象外。ホストとの共有機能を通じた経路に注意が必要 |
| 再接続・復元条件 | 検証終了、Evidence保全、ユーザー承認後に実施 | 同期再開時の対象・未反映変更・競合リスクを確認し、ユーザー承認後に実施 | 実行領域の終了とEvidenceの取扱いを確認後、承認された共有だけを復元する |
| 通常権限で実施可能か | UNKNOWN。必要な操作ごとに確認する | 通常権限で操作可能か、管理ポリシーを含めUNKNOWN | 既存環境の有無による。構築・ACL変更等の必要権限はUNKNOWN |
| 設定変更 | 必要 | 同期・クライアント・接続状態の変更が必要 | 構成に応じてユーザー、ACL、共有、ネットワーク等の変更が必要 |
| 残留リスク | ローカル複製、再接続、未把握の通信経路、Excel起動追加物 | 停止期限・自動再開、キャッシュ、同期以外のProductionアクセス | 不十分な権限境界、ホスト共有、継承した起動追加物、Excel／VBE環境の差異 |
| 別途明示承認が必要な操作 | 接続制限、復元、必要なローカルアクセス制御 | 同期停止・再開、クライアント終了、接続経路変更 | 領域構築、ユーザー・ACL・共有・ネットワーク変更、検証資材の配置 |

**選定条件の提案**として、Aはネットワーク経路の制御候補ですが、アクセス可能なローカル複製が残る場合は単独で要件を満たしません。Bも単独でProduction隔離を認定する根拠にはできません。

既存複製を削除・移動せずにアクセスを制限する必要がある場合は、Cを検討対象とします。ただし、専用ユーザーや仮想環境等を利用する場合でも、その名称だけで隔離成立とはせず、実際のアクセス境界を確認します。要件を満たす方式が成立しなければ、既存PCの採用を保留します。今回はいずれも採用しません。

最小の実施順序案は以下です。

| 順序 | 将来実施する内容 | 完了条件・停止条件 |
| --- | --- | --- |
| 1 | 対象セッションとProduction関連経路を整理する | Excel／VBEと対象プロセスを一意に特定する。OneDriveの同期範囲、ローカル複製、G:の接続形態、GitHubアクセス・Clone、共有、VPN、外部ストレージ、その他の共有・同期経路を整理する。内容読取り・到達性テストは追加しない |
| 2 | 隔離方式と具体的な変更一覧を選定・承認する | 対象、操作、確認方法、復元条件を確定する。必要な権限や重要な経路が不明なら実行を保留する |
| 3 | ユーザー管理下で既存Excel／VBEを通常終了する | 終了の明示承認と「保存不要」の最終確認を得る。保存要求や未承認Workbookへの影響が判明した場合は停止する |
| 4 | 対象プロセスの不存在を確認する | ウィンドウが消えたことだけでは完了にしない。強制終了・全Excelプロセスの一括終了は行わない。確認不能ならUNKNOWN |
| 5 | 承認された隔離措置を実施する | ネットワーク、同期、ローカル複製へのアクセスを、選定方式に従って制御する。削除・移動が不可避になった場合は停止し、別方式を検討する |
| 6 | 起動追加物、保存先、Evidence方針を確定する | 下記の確認・承認条件を満たす。未確認項目をPASSにしない |
| 7 | 隔離成立条件を確認し、採用可否を報告する | 全条件を満たした場合でも、Preflightは別途明示承認を得る |

ネットワーク制限によってCodexの接続や操作ツールが利用できなくなる可能性も計画に含めます。その場合は、遮断前にユーザーの手動確認手順と記録方法を確定し、自動再接続やEvidence転送を行わない方針とします。

Excel起動追加物は、確認と変更を分けます。

| 対象 | 追加確認の計画 | 必要と判明した場合の変更案 |
| --- | --- | --- |
| 既知のXLSTART 2か所 | 直下0件の既存Evidenceを保持する。選定した実行ユーザー・領域に適用できる範囲を確認する | 追加物が判明しても自動で移動・削除・無効化しない |
| 代替起動フォルダー | ユーザーによる既存設定の手動確認等を別途承認する。Excel操作が必要なら、その範囲を明示する | 設定変更が必要な場合だけ、対象と変更内容を個別承認する |
| Excel Add-ins／COM Add-ins | 登録・参照先・有効状態を確認する。インストール済み製品一覧だけで有効状態を認定しない | 必要なアドインだけを対象に変更案を作る。無断で一括無効化しない |
| 安全な起動方法 | 上記確認と選定領域に基づいて確定する | 起動オプションだけでマクロ・イベント抑止やVBA Compileとの両立を認定しない |

確認不能な起動追加物が残る間は、StartupSafetyはREVIEW_REQUIREDです。GUIツールのアクセス不能・タイムアウト、権限要求が発生した項目は再試行せず、手動確認または方式再検討に回します。

保存先候補は次の構成を維持します。

```
C:\S5B_Preflight\
  fixture\
  evidence\
  logs\
```

正式採用前に、ローカル領域であること、同期対象外・Production領域外であること、衝突の有無、実行ユーザーの通常権限での利用可否、ACLと実効アクセス範囲、必要容量を確認します。前回の空き約34.97 GiBは過去の観測値であり、必要容量の充足を確定する値にはしません。

フォルダー作成・資材配置・書込み試験は別途承認対象です。親ACLの読取りだけで書込み可能と認定せず、単なる別ディレクトリをアクセス境界として扱いません。

Evidence方針は、**検証後90日保持を未承認の提案として維持**します。起算点、未解決Evidenceの継続保持、責任者USER、受渡し方法を承認対象とし、自動削除はNONEです。隔離中にホストやクラウドへ自動転送しません。

隔離成立の将来の判定条件は、次の全項目とします。

- 原本所在：OTHER_PC／USER_ATTESTEDという証拠区分を維持する。
- 既存Excel：承認された終了を完了し、対象プロセスの不存在を確認する。
- Productionネットワーク経路：対象経路を特定し、遮断またはアクセス不可を確認する。
- ローカル複製：選定した実行主体からの実効アクセス制御を確認する。
- OneDrive／Google Drive：関係する同期経路とアクセス経路を制御する。
- 起動追加物：適用範囲を確認し、必要な制御を承認・実施する。
- 保存先・Evidence方針：正式承認を得る。
- 想定外の変更：NONEであることを確認する。

設定表示だけではアクセス不可を確認できない項目はUNKNOWNとして採用を保留します。Productionファイルを開く試験や到達性テストは、自動追加しません。

```
S5BReuseStrategy: OPTION_B_SELECTED

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

IsolationCandidate: S5B-TestPC-01

PreservedState:
  S1-S4: CLOSED / PASS
  S5-A: Evidence Reuse Accepted With Limitations
  S5-B: REVIEW_REQUIRED
  P05-I01-I17: DOCUMENTED_PASS_WITH_LIMITATION
  P05-K01-K04: DOCUMENTED_PASS_WITH_LIMITATION
  ExistingClosureAndBaselineHistory: PRESERVED
  FindingsObservationsAndResidualUnknowns: PRESERVED
  S5BPreflightAuthorization: NOT_GRANTED

B2Plan:
  ExistingExcelClosure: PLANNED_NOT_AUTHORIZED
  ProductionPathControl: PLANNED_NOT_AUTHORIZED
  StartupControl: REVIEW_REQUIRED
  StorageApproval: PENDING
  RetentionApproval: PENDING

IsolationMethodOptions:
  A: NETWORK_RESTRICTION
  B: INDIVIDUAL_SYNC_AND_CONNECTION_CONTROL
  C: ISOLATED_EXECUTION_AREA_WITH_VERIFIED_ACCESS_BOUNDARY
  Selected: NONE

RequiredActions:
  - IdentifySessionResourcesAndPaths
  - SelectAndAuthorizeIsolationMethod
  - CloseAuthorizedExcelSessionNormally
  - VerifyTargetProcessAbsence
  - ApplyAuthorizedIsolationMeasures
  - ApproveStartupStorageAndEvidenceControls
  - VerifyIsolationAndReport

SeparateAuthorizationRequired:
  - ExcelWorkbookVBEClosure
  - SyncClientAndConnectionChanges
  - NetworkVPNFirewallChangesAndRestoration
  - ExecutionAreaAccountOrACLChanges
  - DirectoryCreationFilePlacementAndWriteTest
  - ExcelSettingsOrAddinChanges
  - EvidenceTransfer
  - PreflightExecution

RetentionProposal:
  Period: 90_DAYS_AFTER_VERIFICATION
  Approved: FALSE
  UnresolvedEvidence: RETAIN_PENDING_DECISION
  AutomaticDeletion: NONE
  ResponsibleAuthority: USER

B2PlanDecision: READY_FOR_USER_REVIEW
IsolationEstablished: NOT_VERIFIED

EnvironmentMutation: NONE
WorkbookMutation: NONE
FilesCreatedOrModified: NONE
ExcelStartedByTask: FALSE
VBACompileExecuted: FALSE
GitOperation: NONE
BaselineModified: FALSE
PreflightExecuted: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

B2計画の報告を完了し、ここで停止します。
