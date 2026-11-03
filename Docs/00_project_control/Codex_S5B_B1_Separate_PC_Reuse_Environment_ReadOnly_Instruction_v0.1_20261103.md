# S5-B：B-1 既存別PCの再利用に向けた環境確認

## 目的

既存の別PC `S5B-TestPC-01`を、S5-B Preflight検証環境として再利用するための最小Read-only確認を行う。

ユーザーはB案（別PCの再利用方針）を選択済み。

ただし、環境変更、隔離成立の認定、Preflight実行は未承認。本指示の調査実行も、ユーザーが別途認めたRead-only範囲に限定する。

## 既知の事実

- 別PCにはExcel 64bitとVBE DLLが存在する。
- 既存Excel／VBEは`MailGeneratorNew.xlsm`のContract Regression Testに使用されていた（USER_ATTESTED）。
- Google Drive（G:）と個人用OneDriveの表示がある。
- Production資源との接続関係はUNKNOWN。
- 起動追加物の全体像はUNKNOWN。
- Preflightは未実施。
- S5-B最終VBA CompileはNOT_VERIFIED。

## B-1確認内容

### 1. Contract Regression Test後の状態

以下を確認する。

- Contract Regression Testが終了しているか。
- 既存Excel／VBEセッションが継続しているか。
- 未保存の変更・未取得Evidenceがあるか。
- 使用Workbookの配置場所とProduction資源との関係。
- 既存セッションの所有者・終了判断を誰が行うか。

Workbookの内容確認、保存、終了は今回行わない。

必要な情報を取得するためにWorkbook操作が必要となる場合、ユーザー確認事項として提示する。

### 2. クラウド・共有経路

以下を確認する。

- Google Drive（G:）の利用目的とProductionとの関係。
- OneDriveの利用目的、同期対象とProductionとの関係。
- Production Repository／Workbook／Evidenceのローカル配置の有無。
- ネットワーク共有、VPN、外部ストレージを介したProduction接続の有無。
- 隔離措置として後から変更が必要になる接続経路。

Productionファイルを開いたり、共有への到達性テストを行ったりしない。

接続が確認できない場合はUNKNOWNとする。

### 3. Excel起動追加物

既存Evidenceを再利用し、次を整理する。

- 既知のXLSTARTは2か所とも直下0件。
- 代替起動フォルダー：UNKNOWN。
- Excel Add-ins：UNKNOWN。
- COM Add-ins：UNKNOWN。

通常権限のRead-only手段で確認できない場合は、無理に確認せずUNKNOWNとする。

Excelの起動、既存セッションへの接続、アドイン変更は行わない。

### 4. 隔離措置案

確認結果を基に、次を提案する。

- 既存Excel／VBEの安全な終了条件。
- 必要なProduction接続経路の遮断方法。
- Google Drive／OneDriveの扱い。
- ローカル検証領域の候補。
- 残る起動追加物リスクへの対処。
- 隔離成立を検証する方法。

これらの操作は提案のみとし、実行しない。

### 5. STOP条件

以下が必要になった場合は停止する。

- Excel／Workbookの操作
- 未保存データの変更
- 設定変更、同期停止、ネットワーク切断
- ファイルの移動・削除・コピー
- 管理者権限への昇格
- Git操作
- Preflight実行

GUI操作ツールでアクセス不能・タイムアウトが発生した場合は、再試行せず、ユーザーの手動確認項目として提示する。

## 最終報告

```yaml
S5BReuseStrategy: OPTION_B_SELECTED

Environment:
  Alias: S5B-TestPC-01
  IsolationSuitability: REVIEW_REQUIRED

ExistingExcel:
  Purpose: CONTRACT_REGRESSION_TEST
  Source: USER_ATTESTED
  SessionStatus: [value / UNKNOWN]
  UnsavedWork: [value / UNKNOWN]

ProductionConnections:
  GoogleDrive: [value / UNKNOWN]
  OneDrive: [value / UNKNOWN]
  LocalProductionResources: [value / UNKNOWN]
  OtherConnections: [value / UNKNOWN]

StartupSafety:
  Status: REVIEW_REQUIRED / SUPPORTED_WITH_LIMITATION

RequiredIsolationActions:
  [...]

ActionsRequiringUserApproval:
  [...]

B1Decision:
  READY_FOR_ISOLATION_PLAN_REVIEW /
  REVIEW_REQUIRED /
  BLOCKED

EnvironmentMutation: NONE
WorkbookMutation: NONE
ExcelStartedByTask: FALSE
VBACompileExecuted: FALSE
PreflightExecuted: FALSE
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

結果を報告して停止すること。

B-1が完了しても、環境変更やPreflight実行に自動的に進まない。
