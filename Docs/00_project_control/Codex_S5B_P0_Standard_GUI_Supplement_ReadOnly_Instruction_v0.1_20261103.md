# S5-B-P0 標準GUI補完確認

## Codex向け限定Read-only指示 v0.1

### 1. 目的・承認境界

対象は別PC `S5B-TestPC-01`。

既存S5-B-P0調査でUNKNOWNとなった項目を、Windows標準GUIによる非変更操作で補完する。

今回は以下を実施しない。

- Excel／Office起動
- Fixture作成、VBA Compile
- Windows／Office設定変更
- OneDrive同期操作、VPN接続・切断
- Productionファイルへのアクセス
- 新規リモート接続
- ファイル・フォルダー・Evidence作成
- Git操作、Baseline変更、S5-C以降への着手

本指示書の準備はPreflight実行承認を意味しない。GUI調査についても、ユーザーの承認範囲内でのみ実行する。

### 2. GUI操作方法

Windows標準の以下のGUIだけを使用する。

- 設定（Settings）
- エクスプローラー
- タスクマネージャー
- コントロールパネル
- Windowsセキュリティの状態表示

CodexがGUIを直接操作できない場合、操作可能と推定してはならない。その場合はユーザーへ確認手順を提示し、観測結果を受け取る。

PowerShell、Registry照会、CIM、コマンドプロンプトを再実行しない。

設定画面の表示名が異なる場合は、同等の確認項目を探してよい。ただし推測で別の設定を操作しない。

認証要求・管理者権限要求・設定変更が必要になったら、その項目はUNKNOWNとして停止する。

### 3. P0-B1：OS表示の確認

操作候補：

`設定 → システム → バージョン情報`

確認する項目：

- Windowsの正式表示名
- Edition
- Version
- OS Build
- 64bit／32bit

既存調査では次の情報がある。

```text
EditionID: Core
Version: 26H2
Build: 26300.9711
Registry ProductName: Windows 10 Home
```

GUIの表示内容と既存情報を比較する。

不一致はそのまま記録し、Registryを書き換えたりOS名を推定で修正したりしない。

Windows Update画面を参照する場合は表示のみとし、「更新プログラムのチェック」やインストールを実行しない。

### 4. P0-B2：Production隔離の補完

#### A. ローカルドライブ

`エクスプローラー → PC`

次を確認する。

- Cドライブの表示
- Gドライブの表示と種別を示す情報
- ネットワークドライブの既存表示
- 外部ストレージとして識別可能なもの

Gドライブの内容は開かない。

表示から種別を特定できなければUNKNOWN。

ネットワーク共有を開いてアクセス可能性を試験しない。

#### B. OneDrive

タスクバーの通知領域、エクスプローラーのナビゲーションなどで、既に表示されているOneDriveの状態を確認する。

調査対象：

- OneDriveの表示・既存起動状態
- 同期対象が存在することを示す情報
- Productionデータとの関係を判断できる既存情報

サインイン、同期開始・停止、フォルダー選択、アカウント変更は禁止。

OneDriveアプリの起動が必要な場合はUNKNOWNとする。

Productionファイルの中身を開いて確認しない。

#### C. ネットワーク・VPN・共有

操作候補：

`設定 → ネットワークとインターネット`

確認対象：

- ネットワーク接続状態
- VPNの既存接続表示
- 既存ネットワークProfile
- 詳細共有設定の表示
- 既存のマップドライブ表示
- Windowsセキュリティ上のFirewall Profile状態

設定画面の表示だけで取得できる範囲に限定する。

禁止：

- ネットワーク探索
- Ping
- 共有へのアクセス試行
- VPN接続・切断
- ネットワーク切断
- Firewall設定変更

現在通信が見られないことだけでProduction遮断PASSにしない。

#### D. USB・外部ストレージ

操作候補：

`設定 → Bluetoothとデバイス`

またはエクスプローラーの既存ドライブ表示。

接続済みデバイスの種別を確認できる範囲で記録する。

安全な取り外し、USBの抜き差し、ドライブOpenは実施しない。

### 5. P0-C：Excel起動追加物

Excelは起動しない。

#### A. 既存XLSTART

前回の結果を維持する。

```text
User XLSTART:
  Existing
  Immediate Items: 0

Office 64bit XLSTART:
  Existing
  Immediate Items: 0
```

前回結果を取り消す根拠がなければ、再探索は不要。

#### B. 代替起動フォルダー

Excelの代替起動フォルダー設定を、Excelを起動しないGUIだけで確認できるか検討する。

通常、Excel内部のオプション画面を開く必要がある場合は、今回確認しない。

その場合：

`AlternateStartupFolder: UNKNOWN`

#### C. Excel Add-ins／COM Add-ins

操作候補：

`設定 → アプリ → インストールされているアプリ`

既存のインストール済みOffice関連拡張製品を確認できる範囲で記録する。

ただし、Windowsにインストールされている拡張製品の一覧だけで、Excel Add-ins／COM Add-insの有効状態を証明しない。

Excelのオプション画面が必要なら、今回確認しない。

その場合：

```text
ExcelAddins: UNKNOWN
COMAddins: UNKNOWN
```

アドインの削除・無効化は禁止。

#### D. Windowsスタートアップ

操作候補：

`タスクマネージャー → スタートアップ アプリ`

Officeに関係する既存の起動項目を確認する。

無効化・有効化は行わない。

この一覧だけでExcel固有の起動追加物を網羅したと認定しない。

### 6. P0-D：Evidence保存先候補

対象：

`C:\S5B_Preflight\`

前回結果：

```text
Directory Existing: NO
Collision: NONE_IDENTIFIED
Free Space: 約34.97 GiB
Parent ACL: REVIEWED
Effective Write Access: UNKNOWN
```

今回はGUIから次を補完する。

- エクスプローラー上で既存フォルダーの不存在を確認できるか
- Cドライブがローカル領域か
- OneDrive等の同期対象に含まれる兆候があるか
- 親フォルダーの共有状態
- 保存先に関係する既存セキュリティ情報

フォルダー作成、ACL変更、書込み試験は禁止。

読み取り可能な親ACLだけで、実効書込み権限をPASSにしない。

今回も保存先の正式採用は行わない。

### 7. Evidence保持方針

既存の提案を保持する。

```text
Retention Proposal: 90 days
Automatic Deletion: NONE
Unresolved Evidence: RETAIN_PENDING_DECISION
Responsible Authority: USER
```

90日保持は未承認。

GUI調査によって保持方針を自動確定しない。

新しいスクリーンショットやログファイルを保存しない。観測内容はCodexの回答内に記載する。

機密情報、アカウント名、実ホスト名、共有パス等は必要に応じて伏せる。

### 8. 判定ルール

各確認事項は以下に分類する。

- VERIFIED：GUIで直接確認できた事実
- SUPPORTED_WITH_LIMITATION：限定付きで支持された事実
- UNKNOWN：確認できない
- NOT_CHECKED：未確認
- NOT_SUITABLE：明確な不適合

画面に表示されないことを、不存在の証明にしない。

隔離性に関係する設定・接続がUNKNOWNのままなら、ProductionIsolationをPASSにしない。

明確なProduction接続経路が存在すれば、具体的なリスクを報告してPreflight実行可否を保留する。

### 9. STOP条件

次の場合、該当操作を直ちに停止する。

- Excel起動が必要
- 設定の書込みが必要
- 管理者権限が必要
- OneDriveや共有への接続が必要
- Production資源のOpenが必要
- 新しい調査ツールのインストールが必要
- 不明な警告や認証要求が表示された
- GUI操作により意図しない変更が発生した

確認不能な項目はUNKNOWNとして残す。

独立して安全に確認できる別項目は続行してよい。ただし、想定外の環境変更が発生した場合は調査全体を停止する。

自動Retry・Rollbackは禁止。

### 10. 報告形式

```text
S5BP0GUIReview:
  Scope: LOCAL_SEPARATE_PC_ONLY
  PC: S5B-TestPC-01
  Authorization: READ_ONLY

OS:
  DisplayName: [value / UNKNOWN]
  Version: [value / UNKNOWN]
  Build: [value / UNKNOWN]
  RegistryConsistency: PASS / REVIEW_REQUIRED

ProductionIsolation:
  DriveGType: [value / UNKNOWN]
  OneDriveState: [value / UNKNOWN]
  Shares: [value / UNKNOWN]
  VPN: [value / UNKNOWN]
  FirewallProfile: [value / UNKNOWN]
  ExternalStorage: [value / UNKNOWN]
  Overall: VERIFIED / REVIEW_REQUIRED / NOT_SUITABLE

Startup:
  XLSTART: EXISTING_EVIDENCE_PRESERVED
  AlternateStartupFolder: VERIFIED / UNKNOWN
  ExcelAddins: VERIFIED / UNKNOWN
  COMAddins: VERIFIED / UNKNOWN
  WindowsStartupApps: REVIEWED / UNKNOWN
  Overall: SUPPORTED_WITH_LIMITATION / REVIEW_REQUIRED

Storage:
  Candidate: C:\S5B_Preflight\
  Locality: VERIFIED / UNKNOWN
  SynchronizationRisk: REVIEWED / UNKNOWN
  Writable: NOT_TESTED
  Approved: FALSE

EvidenceRetention:
  Proposal: 90_DAYS
  Approved: FALSE

S5BP0GUIReviewDecision:
  READY_FOR_USER_REVIEW /
  REVIEW_REQUIRED /
  NOT_SUITABLE

RemainingUnknowns:
  [...]

ExcelStarted: FALSE
FixtureCreated: FALSE
CompileExecuted: FALSE
SettingsModified: FALSE
FilesCreatedOrModified: NONE
GitOperation: NONE

PreflightExecutionAuthorized: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

結果には、各項目のGUI確認経路、観測値、未確認理由を含める。

調査後、停止する。

### 11. 今回の完了境界

目的は、別PCのPreflight適合性を判断するための未確認情報を補完すること。

今回のGUI確認がPASSしても、それだけで以下を認定しない。

- Excelの安全な独立起動
- マクロ・イベント抑止の実証
- VBA Compileとの両立
- S5-B最終Build Compile PASS
- P2-05 Completion

Preflight実行には引き続き別途明示承認が必要。
