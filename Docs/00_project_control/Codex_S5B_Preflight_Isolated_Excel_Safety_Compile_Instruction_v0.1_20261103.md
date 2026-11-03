# S5-B Preflight：隔離環境でのExcel安全制御・Compile両立確認

## Codex限定実行指示案 v0.1

### 1. 実行許可の前提

**本指示書の作成は、Preflight実行の承認を意味しない。**

ユーザーが本指示に対して別途、明示的にPreflight実行を承認した場合のみ実行すること。

目的は、隔離環境内で無害な検証用VBAProjectを使用し、次の3条件が両立するか確認すること。

- Excelの独立起動と起動時追加物の制御
- Workbook Open前のマクロ・イベント抑止
- マクロ無効状態でのVBAProject Compile

**本番Workbook、Production Source、既存Evidenceを使用した技術検証は対象外。**

### 2. 維持するプロジェクト状態

```text
S1～S4: CLOSED / PASS

S5-A:
  TargetWorkbook: VERIFIED_BY_SHA256
  P05 Evidence Reuse: ACCEPTED_WITH_LIMITATIONS

S5-B:
  FinalBuildCompile: NOT_VERIFIED
  CurrentDecision: REVIEW_REQUIRED

S5-C～S5-E: NOT_STARTED

P2-05 Completion: NOT_RECORDED
P2 Phase Closure: FALSE
CP-P2: NOT_ESTABLISHED
```

以下も維持する。

- P05-I01～I17、K01～K04の限定付きPASS
- 過去Runtime Buildの完全同一性：UNKNOWN
- IF-P2-05-001：CLOSED
- OBS-P2-05-002：OPEN／NON-BLOCKING
- 既存の残留UNKNOWN
- BL-MVP-003の歴史的Execution Baseline
- BL-MVP-004のRepository受入PASS

### 3. 実行境界

将来のPreflight実行承認で許可を求める対象は、次に限定する。

**許可候補**

1. 事前承認された隔離環境の使用
2. 隔離環境内のExcel起動
3. 専用プロセス・Application参照の確認
4. 無害な検証用VBAProjectの作成または使用
5. 隔離Excelインスタンス内の一時的な安全制御設定
6. 検証用WorkbookのOpen
7. 検証用VBAProjectのCompileを1回実施
8. 結果・環境・停止理由の記録

**禁止**

- 本番WorkbookのOpen／コピー／Import／Compile
- 保全済みE-P204-WBの操作
- Repository Sourceの変更
- 本番のExcel Security／Trusted Locations設定変更
- 権限昇格・Registry ACL変更
- Productionマクロ／Runtime Test実行
- Git操作、Baseline変更
- P2-05 Completion
- S5-C以降への着手
- 承認外の自動Retry／Rollback

### 4. Gate P0：隔離環境の成立確認

Excel起動前に、次を確認する。

- 隔離環境が既存の専用VM等であるか。
- OS、Office、VBEが利用可能であるか。
- 本番Repository、OneDrive、本番Workbook、保全Evidenceが隔離環境からアクセスできないか。
- ホスト側のExcelセッションや設定を変更しない構成か。
- 専用ユーザープロファイル、起動フォルダー、アドイン、起動時自動処理を評価できるか。
- 検証用ファイルの保存場所・保持方針が明確か。
- 想定外の外部接続やProductionデータへのアクセスを抑止できるか。

**別プロセスであることだけを隔離環境成立の証拠にしない。**

Officeのインストール、ライセンス変更、VM新規構築、ホスト設定変更が必要なら、追加承認を得るまで停止する。

Gate P0に不確定事項がある場合は、Excelを起動しない。

### 5. Gate P1：独立Excel起動

P0がPASSした場合のみ、隔離環境内でExcelを起動する。

確認事項：

1. 使用する起動方式を1つだけ選定する。
2. Office起動スイッチを非サポートの形で組み合わせない。
3. Excel専用PIDを記録する。
4. 操作対象のApplication参照とPIDの対応を確認する。
5. 既存Excelインスタンスへの意図しない接続がないことを確認する。
6. 起動時アドイン、XLSTART、Auto Macro等について、抑止状況と未確認範囲を記録する。

`/x`、`/safe`、`/automation`などの候補を、効果を推測して組み合わせない。

安全な起動方法が成立しない場合、Workbookを開かず停止する。

### 6. Gate P2：Application安全制御

P1がPASSした場合のみ、同じ専用Application参照に対して以下を実施する。

```text
Target Application:
  Verified isolated Excel instance

AutomationSecurity:
  msoAutomationSecurityForceDisable

EnableEvents:
  False
```

両プロパティの設定後、値を読み戻して一致を確認する。

読み戻しエラー、不一致、Application参照の不一致があれば停止する。

禁止事項：

- AskToUpdateLinks=Falseの使用
- DisplayAlerts=Falseを安全制御の代替に使用
- Trust Centerの恒久変更
- Trusted Locationsの追加
- VBOM Trust Accessの無断有効化
- Security Warningの自動承認

起動前に発生した処理は、これらのプロパティでは遡って抑止できないため、Gate P0／P1の成立を別途必要とする。

### 7. Gate P3：無害な検証用VBAProject

P2がPASSした場合のみ、隔離環境内の専用Fixtureを使用する。

Fixture条件：

- 本番コードを含まない。
- 本番データ、OneDrive、Outlook等の外部資源に依存しない。
- VBAProjectを含むマクロ有効Workbook形式である。
- 最小限の正常なVBAコードを含む。
- Compile操作の対象が一意である。
- 必要に応じて、Workbook_Openの実行有無を非破壊的に判別できる。
- 自動実行が生じても外部ファイル変更や通信を行わない設計である。
- XLM Macroを含まない。
- 外部リンク、外部接続、自動Refreshを含まない。

新しいFixtureを作成する場合、その作成も事前のPreflight実行承認に含まれている必要がある。

Fixture生成時に独自のExcel起動や設定変更が必要になる場合は、同じ安全条件を満たす方法を使用する。成立しなければ停止する。

Fixtureの作成・初期化を、マクロ無効化検証の成功と混同しない。

### 8. Gate P4：マクロ無効状態でOpen

P0～P3がすべてPASSした場合のみ、検証用Fixtureをプログラムで開く。

```text
Workbooks.Open(
  FileName := Approved Fixture,
  UpdateLinks := 0,
  ReadOnly := True,
  AddToMru := False
)
```

事前に設定・読み戻し済みのApplication参照を使用する。

Open後に確認する。

- 対象が指定Fixtureである。
- 予期しないWorkbook／Applicationイベント実行がない。
- 自動実行抑止の検証指標に異常がない。
- 外部リンク更新が発生していない。
- セキュリティ警告・権限要求・予期しない追加物がない。

異常を検出した場合は停止する。

**マクロを実行して安全性を確認しない。**

### 9. Gate P5：Compile両立確認

P4がPASSした場合のみ、隔離環境内のFixtureで次を試す。

```text
VBE
Debug
→ Compile VBAProject
```

確認事項：

1. 検証用VBAProjectを参照できる。
2. Compileメニューが利用できる。
3. 実際にCompile操作を行える。
4. 正常なFixtureについてCompile Errorが発生しない。
5. Compile結果を客観的に確認できる。
6. マクロ／イベントが実行されていないことを確認できる。
7. Productionマクロ、Run、Step、Enable Contentを使用していない。

メニューが無効、操作不能、結果不明、または安全性の確認不能が発生した場合、`NOT_VERIFIED`として停止する。

Compile Errorが発生した場合は、内容を記録して停止する。

設定を緩和して再試行しない。

**Compile成功だけで、マクロ無効状態での全操作が安全だったと断定しない。両条件のEvidenceを別々に取得する。**

### 10. Gate P6：終了と保全確認

正常終了の場合：

- 検証用Workbookを保存せず閉じる。
- 所有とPIDを確認した専用Excelセッションだけを終了する。
- 既存のホストExcelプロセスに触れない。
- Fixture、Evidenceの状態と保存先を報告する。
- 一時ファイルは承認された保持方針に従う。

異常終了の場合：

- 自動Retry、強制終了、Rollback、削除をしない。
- 開いたWorkbook、Excel PID、Application状態を報告する。
- 次の判断まで停止する。

原本、Repository、既存Evidenceの変更は認めない。

### 11. PASS判定

以下のすべてが確認できた場合のみ、限定PreflightをPASSとする。

```text
IsolationGate: PASS
IndependentExcelInstance: PASS
StartupSafetyControl: PASS
ApplicationOwnership: PASS

AutomationSecurityReadback: PASS
EnableEventsReadback: PASS

FixtureOnlyOpen: PASS
MacroSuppressionEvidence: PASS
UnexpectedExecution: NONE

FixtureVBACompile: PASS
CompileObserved: TRUE
SecurityControlsMaintained: TRUE

ProductionWorkbookOpened: FALSE
ProductionSourceModified: FALSE
RepositoryMutation: NONE
```

Gateの一部が不明でもPASSへ補完しない。

今回のPASSが成立しても、以下は別判定とする。

```text
Production Workbook Compile:
  NOT_EXECUTED

Production Build Compatibility:
  NOT_VERIFIED

P2-05 Completion:
  NOT_RECORDED
```

### 12. Codex最終報告

```text
S5BPreflightAuthorization:
  APPROVED / NOT_AUTHORIZED

Isolation:
  Environment: [type]
  IsolationGate: PASS / REVIEW_REQUIRED / BLOCKED
  ProductionResourcesAccessible: FALSE / UNKNOWN

ExcelStartup:
  Execution: TRUE / FALSE
  StartupMethod: [method]
  DedicatedPID: [value or NOT_AVAILABLE]
  ApplicationPIDMatch: PASS / FAIL / NOT_CHECKED
  StartupSafetyControl: PASS / REVIEW_REQUIRED

SecurityControls:
  AutomationSecurityReadback: PASS / FAIL / NOT_CHECKED
  EnableEventsReadback: PASS / FAIL / NOT_CHECKED
  Excel4MacroRisk: CONTROLLED / UNKNOWN
  ExternalAccessRisk: CONTROLLED / UNKNOWN

Fixture:
  FixtureOnly: TRUE / FALSE
  WorkbookOpened: TRUE / FALSE
  MacroSuppressionEvidence: PASS / FAIL / NOT_VERIFIED

Compile:
  Executed: TRUE / FALSE
  Result: PASS / FAIL / NOT_VERIFIED
  ControlsMaintained: TRUE / FALSE / UNKNOWN

ProductionWorkbook:
  Opened: FALSE
  CompileExecuted: FALSE

UnexpectedChanges: NONE / [details]
HostEnvironmentMutation: NONE / [details]
RepositoryMutation: NONE
GitOperation: NONE

S5BPreflightDecision:
  PASS_READY_FOR_S5B_RETRY_REVIEW /
  REVIEW_REQUIRED /
  BLOCKED

S5BTargetBuildCompile:
  NOT_VERIFIED

S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

報告には次を含める。

- 確認に使った環境とOffice構成
- 独立性・安全性を裏付ける具体的Evidence
- 実際のCompile操作と観測結果
- 残留UNKNOWN
- 本番WorkbookのS5-B再試行へ適用可能な条件と適用できない条件
- 次回追加承認が必要な操作

結果を報告して停止する。

**Preflight PASS後も、本番WorkbookでのS5-B再試行を自動実行してはならない。**
