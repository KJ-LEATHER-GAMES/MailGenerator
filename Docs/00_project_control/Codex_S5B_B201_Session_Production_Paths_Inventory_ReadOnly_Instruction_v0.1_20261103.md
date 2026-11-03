# S5-B B2-01：対象セッション・Production関連経路の棚卸し

## Codex限定Read-only実行指示 v0.1

### 1. 目的

既存別PC `S5B-TestPC-01`をS5-B Preflight環境として再利用するため、B2-01の対象セッションとProduction関連経路の棚卸しを完了する。

ユーザーはB案（既存別PC再利用）を選択済み。

Production原本はS5B-TestPC-01とは別PCに存在する（USER_ATTESTED）。

B2隔離措置計画は`READY_FOR_USER_REVIEW`だが、隔離方式は未選定、隔離成立は`NOT_VERIFIED`である。

今回の承認範囲は、**既存状態のRead-only棚卸しと報告のみ**。

Excel終了、同期停止、ファイル操作、環境設定変更、Fixture作成、Preflight実行は承認されていない。

### 2. 調査方法の制限

- 対象はS5B-TestPC-01のローカル環境のみ。
- Windows標準GUIの既存状態表示を優先する。
- CodexによるGUI操作が制限される場合、ユーザーの手動確認を依頼する。
- PowerShell、CIM、Registry再照会、スクリプト実行は今回使用しない。
- 前回発生したGUI操作タイムアウトや権限不足を回避するための無断再試行・昇格を行わない。
- Production関連ファイルの内容を読み取らない。
- 共有、GitHub、OneDrive、Google Driveへの新規接続・サインイン・到達性試験をしない。
- 調査ログやスクリーンショットを新規保存しない。
- 取得結果はCodexの回答本文にのみ記録する。

本番PCは調査対象外とする。

既存の同期情報や接続表示を確認できない場合、UNKNOWNとして記録する。

### 3. Inventory-01：既存Excel／VBEセッション

既知情報：

- Purpose：Contract Regression Test
- Workbook：MailGeneratorNew.xlsm
- Test Status：COMPLETED／USER_ATTESTED
- Unsaved Work：NONE／USER_ATTESTED
- Uncollected Evidence：NONE／USER_ATTESTED
- Termination Authority：USER
- Closure Permission：NOT_GRANTED

ユーザーがWindows標準GUIから安全に確認できる範囲で、次を取得する。

1. Excelウィンドウの現在の存在有無
2. VBEウィンドウの現在の存在有無
3. EXCEL.EXEプロセス数
4. 対象プロセスのPID
5. 対象ExcelセッションとPIDとの対応を裏付ける情報
6. 現在のセッションがContract Regression Testに使用したものかどうかのユーザー確認

PIDは個人情報を含まない範囲で記録してよい。

VBEが独立したEXCEL.EXEプロセスであるとは仮定しない。

Task ManagerからPIDを確認できない場合、無理に確認せずUNKNOWNとする。

Excel／VBEへ操作を送らない。Workbookを開かない。保存・終了しない。

前回存在したウィンドウが現在も存在するとは仮定しない。

### 4. Inventory-02：OneDriveと検証用Workbook

既知情報：

- OneDriveはPC間データ共有に使用されている。
- MailGeneratorNew.xlsmの検証用複製が存在する。
- 原本と同等版との関係はUSER_ATTESTED。
- 同期状態・アクセス境界はUNKNOWN。

確認項目：

1. OneDriveクライアントの現在の起動表示
2. 既存の同期状態表示
3. 検証用Workbookの配置先がOneDrive管理下かどうか
4. ローカル複製の存在についてユーザーが把握している情報
5. Production原本が保存された別PCとの同期・共有関係
6. 検証実行主体が既存コピーへアクセスできる可能性
7. 同期停止後にも残ると考えられるローカル資源

確認はユーザー申告と既存GUI表示に限定する。

ファイル内容のOpen、同期対象の変更、同期停止、ファイル移動・削除は禁止。

共有パスやアカウント識別情報は必要最小限の抽象名に置き換える。

### 5. Inventory-03：Google Drive

既知情報：

- G:にGoogle Driveの表示がある。
- ユーザーは特に使用していないと申告している。
- 接続・同期の実状態はUNKNOWN。

確認項目：

1. Google Driveクライアントの既存起動表示
2. G:の種別について既存表示から判断できること
3. 接続・同期の既存状態
4. Production関連データとの関係についてのユーザー申告
5. Preflight実行時に利用できる可能性のある経路

G:の中身を開かない。

未使用申告だけでDISCONNECTEDと判定しない。

### 6. Inventory-04：その他のProduction関連経路

次を区分して整理する。

**ローカル資源**

- Production RepositoryのローカルCloneまたはコピー
- 本番Workbookのコピー
- Evidence Archiveのコピー
- その他Production関連資源

**ネットワーク**

- 既存の共有フォルダー・マップドライブ
- VPN
- SMB等の共有経路
- ブラウザー経由のクラウドサービス
- GitHubへの既存接続可能性

**外部媒体**

- USBストレージ
- 外付けドライブ
- その他の可搬媒体

既存表示とユーザー申告の範囲だけを収集する。

未知のProduction配置場所を探すためにPC全体を探索しない。

共有接続、GitHub Clone、Git操作、ネットワーク疎通試験、ファイル内容確認を行わない。

接続が存在することと、その接続を通じてProduction資源にアクセスできることを区別する。

既存情報から判定できなければUNKNOWNとする。

### 7. Inventory-05：隔離方式選定への影響

棚卸し結果から、以下の方式に必要な追加確認事項を整理する。

A. NETWORK_RESTRICTION

B. INDIVIDUAL_SYNC_AND_CONNECTION_CONTROL

C. ISOLATED_EXECUTION_AREA_WITH_VERIFIED_ACCESS_BOUNDARY

評価対象：

- Network経路を制御しても残るローカル複製
- OneDrive／Google Drive停止後に残るアクセス経路
- 専用の隔離実行領域を構成する必要性
- Excel／VBE既存セッションへの影響
- Codex接続が失われる可能性
- 別途変更承認が必要な操作

今回は方式を採用せず、各方式の残留リスクを整理するのみ。

### 8. Evidence分類

各確認結果には以下を付与する。

- `GUI_OBSERVED`：今回GUIで直接観測
- `USER_ATTESTED`：ユーザー申告
- `PRIOR_EVIDENCE`：過去の調査結果
- `UNKNOWN`：判定不能
- `NOT_CHECKED`：未調査

現在の実状態と過去の観測を混同しない。

接続経路が表示されないことを、実効アクセス不可の証明にしない。

### 9. STOP条件

以下の操作が必要になった場合は実行しない。

- Excel／Workbook／VBEへの操作、保存、終了
- OneDrive／Google Driveの停止・同期変更
- ネットワーク・VPN・Firewall変更
- 新規の共有アクセス・接続
- Productionファイルの内容読取り
- ファイルコピー・移動・削除
- Folder／Evidenceの作成
- 管理者権限への昇格
- Git操作
- スクリプトによる追加調査
- Fixture作成
- VBA Compile
- Preflight実行

GUIのアクセス不能・タイムアウト時は再試行せず、ユーザー手動確認へ切り替える。

想定外の環境変更が発生した場合は調査全体を停止する。

### 10. B2-01完了条件

以下を満たすこと。

1. Excel／VBEの現在の状態が、確認根拠付きで記録されている。
2. OneDriveと検証用Workbookの関係が整理されている。
3. Google Driveの既存状態が整理されている。
4. ローカル複製、GitHub、共有、VPN、外部媒体を含むProduction関連経路の棚卸し結果がある。
5. 重要なUNKNOWNと、その確認に必要な追加行為が明示されている。
6. 接続経路が判明しても、隔離方式を自動採用していない。
7. 環境・Workbook・Baselineに未承認の変更がない。

棚卸しを完了できても、アクセス遮断の実証を意味しない。

必要な確認自体ができない場合は、B2-01を未完了として報告する。

### 11. 報告形式

```text
S5BReuseStrategy: OPTION_B_SELECTED
Environment: S5B-TestPC-01

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

B201Inventory:
  ExcelSession:
    Existing: YES / NO / UNKNOWN
    PID: [value / UNKNOWN]
    ContractTestRelation: [status]
    ClosureAuthorized: FALSE

  OneDrive:
    Existing: YES
    SyncState: [status / UNKNOWN]
    ValidationWorkbook: USER_ATTESTED
    LocalCopyAccess: [status / UNKNOWN]
    ProductionRelationship: [status / UNKNOWN]

  GoogleDrive:
    GDriveDisplayed: YES
    ClientState: [status / UNKNOWN]
    ProductionRelationship: [status / UNKNOWN]

  LocalProductionResources:
    Status: [status / UNKNOWN]

  GitHub:
    LocalClone: [status / UNKNOWN]
    AccessPaths: [status / UNKNOWN]

  NetworkShares:
    Status: [status / UNKNOWN]

  VPN:
    Status: [status / UNKNOWN]

  ExternalStorage:
    Status: [status / UNKNOWN]

EvidenceClassification:
  [source of each material finding]

UnresolvedCriticalPaths:
  [...]

IsolationOptionImplications:
  A: [...]
  B: [...]
  C: [...]

B201Decision:
  COMPLETE_WITH_LIMITATIONS /
  REVIEW_REQUIRED /
  BLOCKED

B2PlanDecision: READY_FOR_USER_REVIEW
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

EnvironmentMutation: NONE
WorkbookMutation: NONE
ExcelClosedByTask: FALSE
FilesCreatedOrModified: NONE
GitOperation: NONE

FixtureCreated: FALSE
PreflightExecuted: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

### 12. 終了指示

B2-01の棚卸し結果を報告し、停止すること。

B2-02の隔離方式選定や、Excel終了・環境変更へ自動的に進まないこと。

既存のS1～S4 Closure、S5-A限定付きEvidence、P05-I01～I17／K01～K04の状態、Finding／Observation、Baseline履歴、残留UNKNOWNを維持する。
