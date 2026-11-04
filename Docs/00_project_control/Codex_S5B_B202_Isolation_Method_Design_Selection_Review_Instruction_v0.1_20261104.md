# S5-B B2-02：隔離方式の具体設計・選定レビュー

## Codex限定Design-only実行指示 v0.1

### 1. 目的・承認範囲

S5-B Preflightに使用する既存別PC `S5B-TestPC-01`について、Production資源からの隔離方式を具体設計し、ユーザーの方式選定に必要な比較・推奨案を提示する。

今回許可する作業は以下に限定する。

- 既存B2-01 Evidenceのレビュー
- A／B／Cおよび組合せ方式の設計比較
- 技術的成立条件・残留リスクの整理
- 必要な変更操作と個別承認境界の定義
- 推奨方式の提示
- 隔離成立を将来検証する方法の設計

**今回は設計・レビューのみ。隔離方式を正式採用したり、環境変更を実施したりしない。**

追加のOS・ネットワーク・ファイルシステム調査も自動実施しない。設計判断に必要な情報が不足した場合、確認項目を提示して停止する。

### 2. 前提Evidence

次の状態を維持する。

```yaml
S5BReuseStrategy: OPTION_B_SELECTED
Environment: S5B-TestPC-01

B201Decision: COMPLETE_WITH_LIMITATIONS
B2PlanDecision: READY_FOR_USER_REVIEW

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

ExistingExcel:
  Workbook: MailGeneratorNew.xlsm
  LastReportedPID: 6252
  ContractTestCompleted: USER_ATTESTED
  UnsavedWork: NONE_USER_ATTESTED
  ClosureAuthorized: FALSE

LocalProductionResources:
  GitHubClone: PRESENT_USER_ATTESTED
  WorkbookCopy: PRESENT_USER_ATTESTED
  CurrentUserCanAccess: YES_USER_ATTESTED
  ReportedRevision: edf5c5175b103e250144341071d885a3a992c65f
  RevisionVerified: FALSE

OneDrive:
  RunningOnBothPCs: USER_ATTESTED
  ExactSyncScope: UNKNOWN

GoogleDrive:
  RunningOnBothPCs: USER_ATTESTED
  ProductionRelationship: UNKNOWN

GitHubAccessPath: PRESENT_USER_ATTESTED
NetworkShares: UNKNOWN
EvidenceArchiveCopies: UNKNOWN
AlternateExcelStartupFolder: UNKNOWN
ExcelAddins: UNKNOWN
COMAddins: UNKNOWN

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
PreflightAuthorization: NOT_GRANTED
```

PIDは過去のユーザー観測であり、現在も同じプロセスが存在するとは断定しない。

WorkbookがOneDrive内にあるという以前の申告と、ローカルClone内にあるという新しい申告は併記し、同一ファイルと推定しない。

### 3. 隔離の要求条件

Preflightで実際にExcelを実行する主体を定義し、その主体について次の条件を評価する。

**R1：ローカルProduction資源**

- 既存GitHub Cloneへアクセスできないこと
- Production Workbookとそのコピーへのアクセスが制御されていること
- Evidence Archive等の既知のProduction関連資源へのアクセスが制御されていること
- フォルダーを分けただけで隔離成立としないこと

**R2：ネットワークProduction経路**

- OneDriveとGoogle Drive経由のProduction接続を制御すること
- GitHub、共有フォルダー、VPN、その他の接続経路を評価すること
- 不明なネットワーク経路を安全と推定しないこと

**R3：Excel起動条件**

- 既存Excel／VBEとのセッション分離を確認できること
- 起動時追加物・アドイン・代替起動フォルダーへの対処が設計されていること
- マクロ・イベント抑止の設定と読戻しが、将来のPreflightで検証可能であること

**R4：検証領域**

- 同期・共有対象外のFixture／Evidence保存領域を確保できること
- 実行主体のアクセス権限と書込み可能性を確認できること
- 検証終了後のEvidence保全方法が決まっていること

**R5：運用**

- 必要な操作が個別承認可能であること
- 通常権限での実施可能性、権限昇格の要否が整理されていること
- 想定外の動作で停止できること
- 自動Retry・Rollback・復元を行わないこと

### 4. 比較対象

以下5案を評価する。

#### A：検証PC全体のネットワーク制限

評価項目：

- 制御できるネットワーク経路
- 残存するローカルCloneアクセス
- Codex接続・操作ツールへの影響
- 必要な設定変更・権限
- 再接続時のリスク

ネットワーク制限だけでローカル資源へのアクセス不可とは認定しない。

#### B：同期・接続経路の個別停止

対象候補：

- OneDrive
- Google Drive
- GitHubに関する通信
- 共有・マップドライブ
- その他確認された接続経路

個別停止後もローカルファイル、キャッシュ、未把握の経路が残る可能性を評価する。

同期停止のみをIsolation PASS条件にしない。

#### C1：専用Windowsユーザーによる実行領域

既存PC上の別ユーザーで検証する案。

次を設計評価する。

- 専用ユーザーの必要権限
- 既存Clone／Workbookへの実効アクセス
- 既存共有フォルダーや継承ACL
- OneDrive・Google Drive・GitHubのアカウント／認証情報との分離
- マシン全体で共有されるアドイン・サービス・設定
- Excel／VBEを使用できる条件
- 新規ユーザー作成やACL変更に必要な権限
- 検証用Evidenceの保全方法

別ユーザーという名称だけで隔離PASSにしない。

#### C2：同一PC内の独立VM／Sandbox

次を評価する。

- 現在のOS Editionで利用可能か
- 既存の仮想化環境があるか
- 新規構築が必要か
- VM内でExcel／VBEを利用できるか
- Officeライセンスとインストールの要否
- ホスト共有・クリップボード・ドライブ連携
- 仮想ネットワーク
- Snapshot／Evidence保持
- 必要な権限と残留リスク

Windows SandboxはWindows Homeでサポートされないため、現在のOS Editionが確定するまで採用可能と扱わない。

ホスト上のExcelがVM内で利用できると仮定しない。

VM構築、Office導入、OS機能有効化、Windows Edition変更は今回行わない。

#### A＋C：ネットワーク制限＋隔離実行領域

C1またはC2とネットワーク制限を組み合わせる方式。

次を比較する。

- A＋C1
- A＋C2

ローカルProduction資源と外部接続を別々に制御できるか評価する。

Codexがオフラインで利用不能になる場合、ユーザーによる手動実行・Evidence記録をどのように行うか設計する。

オフライン化を解除する操作は別途承認対象とする。

### 5. 選定基準

各案を以下の基準で評価する。

| 基準 | 評価内容 |
|---|---|
| LocalAccessBoundary | 既存Productionコピーへの実効アクセス制御 |
| NetworkIsolation | Production関連通信経路の制御 |
| ExcelCompatibility | Excel／VBEの利用可能性 |
| StartupControl | 起動追加物とセッション分離 |
| ImplementationFeasibility | 必要な権限・既存機能・変更範囲 |
| EvidencePreservation | 隔離中と終了後のEvidence保全 |
| Reversibility | 復元手順・責任者・残留リスク |
| OperationalRisk | 誤操作、Production影響、ツール接続消失 |

評価は次のいずれかとする。

- SATISFIED_BY_DESIGN
- CONDITIONALLY_FEASIBLE
- NOT_SATISFIED
- UNKNOWN

設計上成立する見込みと、実環境で検証済みであることを区別する。

判定不能な条件はUNKNOWNを維持する。

### 6. 最小変更方針

推奨方式を選ぶ場合、以下を優先する。

1. Production原本と既存Cloneを変更しない。
2. 既存Regression Test Evidenceを保持する。
3. 既存Excelセッションの終了は別途ユーザー承認とする。
4. 既存Productionファイルの移動・削除を前提にしない。
5. 必要な新規実行領域・アクセス制御を最小化する。
6. 起動・Compile・Evidence管理を別Gateで承認する。

C1／C2が現在のPCで成立しない場合は、既存PCの利用を強行せず、不採用候補または追加環境整備が必要と報告する。

### 7. 隔離成立の将来検証計画

方式ごとに、以下を明示する。

- 設定・構成を確認する方法
- 実行主体を識別する方法
- Productionローカル資源への実効アクセス不可を確認する方法
- Productionネットワーク経路の制御を確認する方法
- 起動追加物を確認する方法
- Evidenceを保持する方法
- 検証不能時のSTOP条件

Production WorkbookやRepositoryの内容を開いてアクセス試験しない。

安全な方法で実効アクセスを確認できない場合は、NOT_VERIFIEDとして停止する設計とする。

将来の検証用の無害な観測資材やアクセス検査が必要なら、その作成・実行を独立した承認対象にする。

### 8. 必要な追加承認の分離

将来必要となる操作を、以下の承認単位に分ける。

**AUTH-01：既存セッションの終了**

- 対象Excel／VBE特定
- 通常終了
- 保存要求時STOP
- PID不存在確認

**AUTH-02：隔離環境の構築**

- 専用ユーザー／VM等の作成
- 必要なアクセス制御
- 必要な接続制限

**AUTH-03：隔離状態の確認**

- 実行主体・権限・ネットワークの確認
- 必要な限定アクセス検証

**AUTH-04：検証領域とEvidence管理**

- C:\S5B_Preflight\等の保存先採用
- 必要な領域作成
- 90日保持方針の承認
- Evidence保全・受渡し方法

**AUTH-05：Preflight実行**

- SafeCompileFixture作成
- Excel独立起動
- 安全制御設定
- Fixture Open
- VBA Compile
- Evidence取得

**AUTH-06：本番S5-B再試行**

- Preflight結果のレビュー後、対象Workbookと実施範囲を別途承認

今回、いずれの操作も実行しない。

### 9. 禁止事項

今回のB2-02では次を禁止する。

- Excel／VBE／Workbook操作・終了
- ProductionファイルのOpen・コピー・移動・削除
- Gitコマンド・Repository変更
- OneDrive／Google Drive操作
- ネットワーク・VPN・Firewall変更
- Windowsユーザー作成・ACL変更
- VM／Sandbox起動・構築
- Officeインストール・設定変更
- Registry操作・スクリプトによる環境調査
- 新規Evidence・管理ファイル作成
- Fixture作成
- VBA Compile
- Preflight実行
- Baseline変更
- 自動Retry・Rollback

設計のために不足情報があれば、必要な追加確認内容を報告する。勝手に調査や変更を開始しない。

### 10. 報告形式

```yaml
S5BReuseStrategy: OPTION_B_SELECTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B202Authorization: DESIGN_REVIEW_ONLY

DesignOptions:
  A_NETWORK: [...]
  B_SYNC_CONTROL: [...]
  C1_SEPARATE_USER: [...]
  C2_VM_OR_SANDBOX: [...]
  A_PLUS_C: [...]

DesignComparison:
  LocalAccessBoundary: [...]
  NetworkIsolation: [...]
  ExcelCompatibility: [...]
  StartupControl: [...]
  ImplementationFeasibility: [...]
  EvidencePreservation: [...]
  OperationalRisk: [...]

RecommendedOption:
  Method: [candidate / NONE]
  Rationale: [...]
  Preconditions: [...]
  ResidualRisks: [...]
  Confidence: [...]

RequiredAdditionalFacts:
  [...]

ProposedAuthorizationSequence:
  - AUTH-01
  - AUTH-02
  - AUTH-03
  - AUTH-04
  - AUTH-05
  - AUTH-06

B202Decision:
  READY_FOR_USER_SELECTION /
  REVIEW_REQUIRED /
  BLOCKED

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

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

### 11. 完了条件

次の内容を報告して停止する。

1. 各方式の比較結果。
2. 優先推奨候補と理由。
3. 実現可能性を確定するための最小追加確認。
4. 必要な変更操作と個別承認単位。
5. 隔離成立を将来検証する方法。
6. 残留UNKNOWNとSTOP条件。

`READY_FOR_USER_SELECTION`はユーザーが方式を選べる状態を意味し、隔離方式の正式採用や実施承認を意味しない。

既存のS1～S4 Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴を変更しない。
