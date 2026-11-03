# S5-B-P0 別PC環境適合性確認

## Codex最小Read-only実行指示 v0.2

### 1. 目的・実行承認

ユーザーは、検証用の別PC上で行うS5-B-P0限定Read-only環境調査を承認した。

目的は、当該PCをS5-B Preflightの隔離環境として採用できるか判断するための事実収集である。

今回は環境情報の読取りのみを行う。

**Preflight実行、Excel起動、VBA Compile、Fixture作成、環境設定変更は未承認。**

### 2. 調査対象の限定

- 現在Codexが動作している別PCのみを調査する。
- 本番PCやRepositoryへ接続しない。
- 新規のリモート接続・ネットワーク接続を開始しない。
- 通常ユーザー権限の範囲だけを使用する。
- PowerShell等の既存のWindows標準機能をRead-onlyで使用してよい。
- 調査スクリプト・ログファイルを新規作成しない。
- 結果はCodexの回答内に報告する。

PCには管理用別名（例：`S5B-TestPC-01`）を付ける。実際のホスト名、ユーザー名、シリアル番号、アカウント、認証情報は報告しない。

### 3. 調査項目

#### A. OS

既存のOS情報から次を取得する。

- Windows Edition
- Version
- Build
- 32bit／64bit
- 確認できる更新状態
- 現在の権限種別

`Get-CimInstance Win32_OperatingSystem`等の読取り専用操作を使用してよい。

取得できない情報はUNKNOWN。

#### B. Excel／Office

Excelを起動せず、既存のインストール情報・実行ファイル情報から次を確認する。

- Excelインストール有無
- Excel Version／Build
- 32bit／64bit
- EXCEL.EXEの存在
- VBEコンポーネントの静的な存在確認
- Excelプロセスが現在起動中かどうか

`Get-Process`、実行ファイルのVersion情報、Office既存インストール情報などを使用してよい。

**Excel／Officeアプリケーションの起動は禁止する。**

VBEが実際に使用可能かどうかは、この調査で証明しない。

#### C. Production資源との隔離

以下の既存設定・接続状況をRead-onlyで確認する。

- OneDriveの既存同期状態
- 既存の共有フォルダ／マップドライブ
- VPN設定・接続状態
- USB／外部ストレージの接続
- Production RepositoryやWorkbookのローカル配置について、既知の場所だけで確認できる範囲
- ネットワーク接続とFirewall Profileの既存情報
- 本番PCやProduction資源につながる既存経路

`Get-SmbMapping`、`Get-PSDrive`、`Get-NetAdapter`などの既存Windows標準コマンドを必要に応じて使用してよい。

ただし次は禁止する。

- Pingや共有へのアクセス試行
- ネットワークスキャン
- 本番PCへの接続
- Productionファイル内容の読取り
- OneDriveログイン／ログアウト・同期変更
- VPN、Firewall、ネットワーク設定変更
- PC全体の無差別ファイル探索

Production遮断を確認できなければUNKNOWNとする。

#### D. Excel起動追加物

Excelを起動せず、既存の設定と既知のフォルダから次を調べる。

- XLSTART
- 代替起動フォルダー
- Excel Add-ins
- COM Add-ins
- Office起動時の追加処理に関係する既存設定

必要な場合のみ、既存Registryの読み取り専用照会を行ってよい。

PermissionDeniedの場合は、権限変更・昇格・再試行をせずUNKNOWNとする。

アドインを有効化・無効化・削除しない。

起動時挙動の実証は今回行わない。

#### E. Fixture／Evidence保存先候補

以下の候補を確認する。

`C:\S5B_Preflight\`

確認対象：

- ディレクトリの存在
- 既存物との衝突
- 親ディレクトリのACL（読取り可能な範囲）
- OneDriveや共有・同期対象との関係
- 利用可能なディスク空き容量

フォルダ作成、書込み試験、ACL変更は禁止。

書込み可能性は実測しない。既存設定だけで判断できない場合はUNKNOWNとする。

保存先を自動採用しない。

### 4. Evidence・保持方針

今回の調査結果はCodexの回答内だけに記録する。

以下を含める。

- 調査日時・タイムゾーン
- 別PCの管理用別名
- 各確認項目の結果
- 使用したRead-only確認方法
- PermissionDenied／UNKNOWN
- Preflight実行前に必要な追加判断

実際のEvidenceファイルは作成しない。

既存の90日保持案は`PROPOSED`のままとし、ユーザーが承認するまで正式採用しない。

### 5. STOP条件

以下の場合、その操作を停止する。

- 管理者権限への昇格が必要
- Excel起動が必要
- 新規リモート接続が必要
- ファイル作成・設定変更が必要
- Production資源へのアクセスが必要
- 調査による環境変更が発生する可能性がある

確認不能な項目はUNKNOWNとして残し、安全に確認できる他の独立項目は継続してよい。

想定外の変更が発生した場合は、調査全体を停止し、実際の変更内容を報告する。

### 6. 報告形式

```yaml
S5BP0Authorization: APPROVED_READ_ONLY

Environment:
  Type: SEPARATE_PC
  Alias: [assigned alias]
  OSVersion: [value / UNKNOWN]
  OSBuild: [value / UNKNOWN]
  OSArchitecture: [value / UNKNOWN]

Excel:
  Installed: YES / NO / UNKNOWN
  Version: [value / UNKNOWN]
  Architecture: [value / UNKNOWN]
  VBEStaticEvidence: PRESENT / UNKNOWN
  ExistingExcelProcess: YES / NO / UNKNOWN
  ExcelStartedByThisTask: FALSE

ProductionIsolation:
  LocalResources: NONE_IDENTIFIED / PRESENT / UNKNOWN
  OneDrive: REVIEWED / UNKNOWN
  SharesAndVPN: REVIEWED / UNKNOWN
  NetworkIsolation: VERIFIED / UNKNOWN
  Overall: VERIFIED / REVIEW_REQUIRED / NOT_SUITABLE

Startup:
  XLSTART: REVIEWED / UNKNOWN
  ExcelAddins: REVIEWED / UNKNOWN
  COMAddins: REVIEWED / UNKNOWN
  StartupSafety: REVIEW_REQUIRED / SUPPORTED_WITH_LIMITATION

Storage:
  Candidate: C:\S5B_Preflight\
  Existing: YES / NO / UNKNOWN
  ACL: REVIEWED / UNKNOWN
  Capacity: [value / UNKNOWN]
  Approved: FALSE

Fixture:
  Specification: DEFINED
  Created: FALSE

EvidenceRetention:
  Proposal: 90_DAYS
  Approved: FALSE

S5BP0SuitabilityDecision:
  READY_FOR_USER_REVIEW /
  REVIEW_REQUIRED /
  NOT_SUITABLE

UnresolvedItems:
  [...]

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

### 7. 終了条件

収集した情報を基に、次を判定する。

1. 別PCをPreflight環境として採用する見込みがあるか。
2. Production遮断で不足する条件は何か。
3. Fixture／Evidence保存先を正式採用できるか。
4. Preflight実行前に必要な最小追加承認は何か。

結果を報告して停止する。

`READY_FOR_USER_REVIEW`でもPreflightを自動実行しないこと。
