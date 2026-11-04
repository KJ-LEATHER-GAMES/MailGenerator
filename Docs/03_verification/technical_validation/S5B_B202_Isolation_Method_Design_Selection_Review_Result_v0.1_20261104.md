# S5-B B2-02 隔離方式の具体設計・選定レビュー結果

**優先推奨候補は、条件付きのA＋C1（PC全体のネットワーク制限＋専用Windowsユーザー）です。B202DecisionはREVIEW_REQUIREDとします。**

既存Clone・Workbookの内容やACLを変更せず、専用ユーザーからアクセスできない境界を確認できることが条件です。成立しない場合はA＋C2を再検討します。現時点では実装可能性が未確定のため、正式選定・構築には進みません。

PID 6252は過去のユーザー観測として保持します。また、Workbookの「OneDrive内」という申告と「ローカルClone内」という申告は併記し、同一実体とは推定しません。

比較対象の具体設計は以下です。

| 方式 | 実行主体・構成案 | 成立条件と主な限界 |
| --- | --- | --- |
| **A：NETWORK** | 現在のWindowsユーザーでExcelを実行し、PC全体の外部通信を遮断する案 | 設計上の遮断対象はGitHub、共有、VPN、クラウド等を含む全外向き経路。**既存Cloneへのローカルアクセスは残るため、単独ではR1を満たさない**。Codex接続も失われる可能性がある |
| **B：SYNC_CONTROL** | 現在のユーザーで、同期クライアント・共有・通信経路を個別制御する案 | 経路の網羅と停止状態の確認が必要。キャッシュ、通常ファイル、ブラウザーや未把握経路が残る。**同期停止だけではR1・R2を満たさない** |
| **C1：SEPARATE_USER** | Production用アカウント・認証情報を引き継がない専用の標準Windowsユーザーで、ホストのExcelを実行する案 | 既存Clone、Workbook、Evidence、共有・クラウド経由の実効アクセスを確認する。継承ACLや共通サービス、マシン全体のアドインは別途評価する。ネットワーク制御は別に必要 |
| **C2：VM_OR_SANDBOX** | ゲストの標準ユーザーでExcelを実行し、ホストドライブ共有・クリップボード・ドラッグ＆ドロップ・媒体連携・Production認証情報を持ち込まない案 | 仮想ネットワークも制御する。OS・仮想化環境・Office導入と利用条件・容量が未確認。**ホストのExcelをそのまま利用できるとは扱わない** |
| **A＋C1** | PC全体の外部通信制限と、専用標準ユーザーのアクセス境界を組み合わせる案 | 既存資源を変更せずにC1の境界が成立すれば、変更を比較的小さくできる候補。専用ユーザーでも既存コピーを読める場合は不成立 |
| **A＋C2** | PC全体の外部通信制限と、ホスト連携を閉じた独立ゲストを組み合わせる案 | ローカル境界と外部通信を別々に制御する候補。構築・Office・Evidence保全の負担が大きく、現PCでの成立可否は未確認 |

C2について、前回のRegistry情報はHome相当ですが、正式なOS表示は未確認です。指示にあるWindows SandboxのHome非対応条件を適用し、**Sandboxを採用可能とは扱いません**。他のVM方式も、利用可能な環境があるとは仮定しません。

評価記号は、`S = SATISFIED_BY_DESIGN`、`C = CONDITIONALLY_FEASIBLE`、`N = NOT_SATISFIED`、`U = UNKNOWN`です。Sも実機検証済みを意味しません。

| 基準 | A | B | C1 | C2 | A＋C1 | A＋C2 |
| --- | --- | --- | --- | --- | --- | --- |
| LocalAccessBoundary | N | N | C | C | C | C |
| NetworkIsolation | S | U | N | C | S | S |
| ExcelCompatibility | C | C | C | U | C | U |
| StartupControl | U | U | U | U | U | U |
| ImplementationFeasibility | C | U | U | U | U | U |
| EvidencePreservation | C | C | C | C | C | C |
| Reversibility | C | C | C | C | C | C |
| OperationalRisk | C | U | U | U | U | U |

AのNetworkIsolationをSとするのは、**全外向き通信を遮断する設計**についてです。一部接続を残す場合は再評価が必要です。OperationalRiskは、必要な停止・手動運用条件を含めてリスクを管理可能か、という評価です。

最小の追加確認は次のとおりです。今回はいずれも調査しません。

1. **C1のアクセス境界**

   既知のClone、Workbook、Evidence関連資源の配置・同期範囲・ACL・継承・共有経路。専用ユーザーから、既存資源の内容やACLを変更せずアクセス不可にできるかを確認します。OneDriveとCloneの位置関係もここで整理します。

2. **専用ユーザーとExcelの利用条件**

   利用可能な専用標準ユーザーの有無、新規作成に必要な権限、Excel／VBEの利用・認証条件、Production用認証情報との分離を確認します。構築に必要な管理権限と、Excel実行時の標準権限を分けます。

3. **起動追加物**

   選定する実行主体に適用される代替起動フォルダー、ユーザー単位・マシン全体のアドイン、関連サービスを確認します。既知XLSTART直下0件だけではStartupSafetyを確定しません。

4. **ネットワークとオフライン運用**

   制限すべき接続と、Codex・操作ツールへの影響を確認します。遮断後にユーザーが安全制御の設定・読戻し・Evidence記録を実施できなければ、オフライン実行へ進みません。

5. **保存先とEvidence保全**

   非同期・非共有領域、実効アクセス、必要容量、保持・受渡し方法を確認します。C2の場合、ゲストの`C:\S5B_Preflight\`はホスト側候補と別物として審査します。

6. **C2を検討する場合のみ必要な事実**

   正式OS Edition、利用可能な仮想化環境、必要な機能・権限、Office導入・利用条件、ゲストとSnapshotを含む容量、Evidenceの永続化方法を確認します。

C1で既存Production資源の移動・削除やACL変更が必要になる場合は、今回の優先候補の前提から外れます。C1を強行せず、C2等の別案レビューへ戻します。

将来の隔離検証は、共通確認と方式固有確認を組み合わせます。

| 確認対象 | 将来の確認方法 | STOP条件 |
| --- | --- | --- |
| 構成・実行主体 | 実際にExcelを実行するユーザー、標準権限、ホスト／ゲストの別を識別する。新しいExcel起動後のPIDはその時点で対応を確認する | 実行主体やセッション対応が不明、未承認の昇格が必要 |
| ローカル実効アクセス | 既知対象のセキュリティ設定・実効アクセスを確認する。継承例外、個別ACL、共有や別名経路も評価する | Productionの内容を開かずに安全に確認できない、重要な対象範囲が未確定 |
| ネットワーク経路 | 接続・構成・遮断状態を確認する。無通信表示だけでは判定しない | 未制御経路、確認不能な構成、必要な接続制御が不明 |
| 起動追加物 | 選定主体に適用される起動フォルダー・アドイン等を静的に確認し、必要な変更を個別承認する | 未確認の追加物を安全と扱う必要がある、無断の無効化が必要 |
| マクロ・イベント制御 | AUTH-05で制御項目・期待値・読戻し方法を確定する。Fixture Open前、Open後、Compile前に必要な制御を確認する | 読戻し不能、不一致、想定外の処理発生 |
| Evidence | 承認済みのローカル保存先と保持方針で記録する。Snapshotを正式Evidenceの代わりとは扱わない | 保全不能、未承認の転送が必要、未解決Evidenceが失われる可能性 |

無害な観測資材や限定アクセス検査が必要なら、**作成・実行・対象範囲を独立して承認**します。その資材の結果だけで、対応未確認のProduction実体までアクセス不可と推定しません。

方式固有の確認は以下です。

- **A**：PC全体の対象接続を確認する。ローカル資源の境界は未成立として、単独採用を停止する。
- **B**：停止対象、停止状態、自動再開条件、同期以外の経路を確認する。既存コピーへのアクセスが残れば単独採用を停止する。
- **C1**：専用ユーザーの実効権限、認証情報分離、共通サービス・マシン全体設定を確認する。既存コピーへアクセスできれば停止する。
- **C2**：ゲストの実行主体、ホスト連携、仮想ネットワーク、持込み資材、保存の永続性を確認する。ホスト経由の到達経路やOffice利用条件が不明なら停止する。
- **A＋C1／A＋C2**：Aと対応するCの条件を、それぞれ満たしたことを確認する。一方の確認結果で他方を代替しない。

承認単位は次のように分けます。**すべて未承認です。**

| 承認 | 対象と境界 |
| --- | --- |
| **AUTH-01** | 対象セッションを改めて一意に特定し、保存不要を最終確認して通常終了する。保存要求時はSTOP。対象PIDの不存在を確認する。強制終了・全Excel一括終了は含めない |
| **AUTH-02** | 選定した実行領域・アクセス制御・接続制限を構築する。管理権限使用、Office導入、OS機能有効化、Edition変更等が必要なら、操作を具体化して個別承認する |
| **AUTH-03** | 実行主体・権限・構成・隔離状態を確認する。必要な観測資材や限定検査は明示的に承認する。Production内容のOpenは含めない |
| **AUTH-04** | 保存先採用、領域作成、書込み確認、保持方針、保全・受渡し方法を承認する。転送先・方向・方法を指定する |
| **AUTH-05** | SafeCompileFixture作成、Excel独立起動、安全制御と読戻し、Fixture Open、VBA Compile、Evidence取得を承認する |
| **AUTH-06** | Preflight結果レビュー後、対象Workbook・所在・実施範囲を指定してS5-B再試行を別途承認する |

AUTH-02は段階化し、ネットワーク遮断は手動確認手順・必要資材・記録先が対応する承認の下で準備できてから実施します。隔離確認のEvidenceを残すため、AUTH-04の保存・保持方針はAUTH-03の記録に先行させます。

Codexが利用不能になった後は、ユーザーが承認済み手順で確認・記録します。隔離判定後のAUTH-05も別途明示承認が必要です。実施不能なら停止し、**再接続・同期再開・復元・Evidence転送を自動で行いません**。

```
S5BReuseStrategy: OPTION_B_SELECTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B2PlanDecision: READY_FOR_USER_REVIEW
B202Authorization: DESIGN_REVIEW_ONLY

DesignOptions:
  A_NETWORK: "PC全体の外部通信制限。ローカル境界は提供しない"
  B_SYNC_CONTROL: "個別経路制御。ローカル複製と未把握経路が残る"
  C1_SEPARATE_USER: "専用標準ユーザーと検証済みの実効アクセス境界"
  C2_VM_OR_SANDBOX: "独立ゲストと制限されたホスト連携・ネットワーク"
  A_PLUS_C:
    - A_PLUS_C1
    - A_PLUS_C2

DesignComparison:
  DetailedRatings: "本文の8基準比較表"
  AAloneMeetsR1: NOT_SATISFIED
  BAloneMeetsR1: NOT_SATISFIED
  StartupControl: UNKNOWN
  C1ImplementationFeasibility: UNKNOWN
  C2ImplementationFeasibility: UNKNOWN

RecommendedOption:
  Method: A_PLUS_C1_CONDITIONAL_CANDIDATE
  Alternative: A_PLUS_C2_REVIEW_CANDIDATE
  Rationale:
    - ローカルアクセスと外部通信を別々に制御する
    - 成立すればホストの既存Excel環境を利用できる可能性がある
    - Production原本・既存Clone・既存Evidenceを変更しない方針
  Preconditions:
    - 既存資源を変更せずC1の実効アクセス境界を確認できる
    - 専用標準ユーザーでExcel／VBEを利用できる
    - 起動追加物を確認・制御できる
    - オフライン確認とEvidence保全を実施できる
  ResidualRisks:
    - 継承ACL・共有・共通サービス等のアクセス経路
    - マシン全体のアドイン・設定
    - クラウド管理範囲と追加ローカル複製のUNKNOWN
    - Codex接続消失と手動運用
    - 再接続時の同期・共有再開
  Confidence:
    NeedForLocalAccessBoundary: HIGH
    C1ImplementationFeasibility: UNKNOWN
    C2ImplementationFeasibility: UNKNOWN

RequiredAdditionalFacts:
  - KnownResourceLocationsAndEffectiveAccess
  - DedicatedUserPrivilegesAndExcelAvailability
  - StartupAdditionsForSelectedExecutionIdentity
  - NetworkRestrictionAndOfflineOperationFeasibility
  - StorageCapacityRetentionAndEvidenceHandoff
  - C2PlatformAndOfficeConditionsIfRequired

ProposedAuthorizationSequence:
  - AUTH-01
  - AUTH-02
  - AUTH-04
  - AUTH-03
  - AUTH-05
  - AUTH-06

AllExecutionAuthorizations: NOT_GRANTED
B202Decision: REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
PreflightAuthorization: NOT_GRANTED

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

90日保持は未承認の提案、未解決EvidenceはRETAIN_PENDING_DECISION、自動削除はNONE、責任者はUSERとして維持します。既存Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴を変更せず、ここで停止します。
