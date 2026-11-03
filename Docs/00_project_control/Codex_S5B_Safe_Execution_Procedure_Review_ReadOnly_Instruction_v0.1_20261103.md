# S5-B Safe Execution Procedure Review

## 限定Read-only確認指示 v0.1

### 1. 目的と承認範囲

ユーザーは、S5-Bの安全な検証手順について、限定Read-only確認のみ承認した。

直前のS5-Bは以下の理由で停止した。

- Excel Security／Trusted Locations設定の読取りがPermissionDenied
- 自動イベント・マクロ実行の抑止を確認できない
- Excel起動前にSTOP
- VBA Compile未実施
- Workbook／Source／Repositoryの変更なし

今回は、この問題を回避するための**安全手順の設計・根拠確認・適用可能性評価のみ**を実施する。

S5-Bの技術再試行は承認されていない。

### 2. 維持する状態

以下は変更しない。

```text
S1～S4:
  CLOSED / PASS

S5A:
  Target Workbook IDENTIFIED
  Evidence Reuse ACCEPTED_WITH_LIMITATIONS

S5B:
  REVIEW_REQUIRED

Target Workbook:
  E-P204-WBとのSHA-256一致

Expected SHA-256:
  0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9

Final VBA Compile:
  NOT_VERIFIED

Existing P05-I01～I17:
  DOCUMENTED_PASS_WITH_LIMITATION

Existing P05-K01～K04:
  DOCUMENTED_PASS_WITH_LIMITATION

OBS-P2-05-002:
  OPEN / NON-BLOCKING
```

過去のRuntime Buildの完全同一性、VBAProject全体の一致、残留UNKNOWNを推測で解消しない。

### 3. 公式仕様の確認

以下のMicrosoft公式資料を根拠として確認する。

1. Excel Application.AutomationSecurity
   https://learn.microsoft.com/ja-jp/office/vba/api/excel.application.automationsecurity

2. Excel Application.EnableEvents
   https://learn.microsoft.com/ja-jp/office/vba/api/excel.application.enableevents

3. Excel Workbooks.Open
   https://learn.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open

4. Excel VBAProjectへのアクセスとMacro Security
   https://support.microsoft.com/ja-jp/excel/change-macro-security-settings-in-excel

5. Excel起動時の自動オープン抑止
   https://learn.microsoft.com/ja-jp/troubleshoot/microsoft-365-apps/excel/files-open-automatically

現在の環境で未確認の仕様・操作は、公式仕様から自動的に環境上のPASSへ格上げしない。

### 4. Excel起動前の安全制御案

次の制御について、実行せずに設計・評価する。

#### 4.1 独立Excelセッション

- 既存のExcelセッションに接続しない。
- S5専用の独立プロセスを使用する候補を評価する。
- Excel起動時にアドイン、XLSTART、代替起動フォルダー、既存自動マクロ等が動作する可能性を評価する。
- `/automation`および`/safe`の効果と制限をMicrosoft公式資料で確認する。
- これらの起動スイッチのみを安全性の十分条件にしない。
- 独立プロセスを確保できない場合の停止条件を明示する。

今回はExcelプロセスを起動しない。

#### 4.2 Workbook Open前のApplication制御

将来の再試行候補として、以下の設定順序を検討する。

```text
Independent Excel Instance
↓
AutomationSecurity
= msoAutomationSecurityForceDisable

EnableEvents
= False

AskToUpdateLinks
= False (if supported/appropriate)

Read back control values
↓
Confirm pre-open safety conditions
↓
Workbooks.Open
  UpdateLinks:=0
  ReadOnly:=True
  AddToMru:=False
↓
VBA Structure Inspection
↓
Compile feasibility assessment
```

これは設計候補であり、今回実行してはならない。

次の点を評価する。

- 制御値をWorkbook Open前に設定・読み戻しできるか。
- 読み戻し失敗時の停止方法。
- 設定がWorkbook Openより先に成立することを保証できるか。
- `DisplayAlerts=False`や`ScreenUpdating=False`をMacro Securityの代用にしていないか。
- セキュリティ警告を自動承認・回避する経路がないか。
- エラー時・正常終了時の後始末が既存セッションに影響しないか。

Applicationプロパティの一時変更であっても、今回は禁止する。次回の実行承認で必要な操作として提案するだけとする。

#### 4.3 Excel 4.0 Macroの例外

`msoAutomationSecurityForceDisable`はExcel 4.0マクロを無効化しない。

既存WorkbookをExcelで開かず、ファイル構造をRead-onlyで調べられる場合、次の存在を確認する。

- Excel 4.0 Macro Sheetを示すOOXML要素・Relationship
- 関連するContent Type
- Macro Sheetに対応するシート定義
- XLM実行可能性に関係するDefined Name等の手掛かり

ZIP内部の内容は、展開・書戻しを伴わない方法で読み取る。

確認可能な範囲と、検査だけでは証明できない範囲を分ける。

XLMの存在を検出した場合は、安全なOpen条件を再評価し、未解決ならBLOCKED。

XLMが検出されなくても、調査範囲を明記し、無条件に安全性を証明したことにはしない。

#### 4.4 外部接続・自動更新

`UpdateLinks:=0`の対象と限界を確認する。

外部Workbookリンクに加えて、必要に応じて以下を評価する。

- Workbook Connections
- QueryTable
- OLE DB／ODBC Connections
- Power Query関連要素
- RefreshOnFileOpen等の設定
- 外部データの自動更新経路

`UpdateLinks:=0`だけで、すべての外部データアクセスが抑止されると仮定しない。

安全性を判断できない外部接続が存在する場合は、追加確認事項として報告する。

### 5. Macro SecurityとVBA Compileの両立

今回の重要確認事項。

次を分けて評価する。

1. Workbook Open時にVBAマクロを無効化できること。
2. VBAProjectを参照できること。
3. VBEのDebug → Compile VBAProjectを実行できること。
4. Compileを実行してもProductionマクロ・Workbookイベントを動作させないこと。
5. Compile結果を明確に記録できること。
6. 原本やRepositoryに変更を残さないこと。

**マクロ無効化状態でもCompile可能であると推定してはならない。**

公式仕様または信頼できる既存Evidenceで両立が確認できない場合、`COMPILE_FEASIBILITY: NOT_VERIFIED`とする。

VBAProject Object ModelへのTrust Accessが無効の場合も、設定を変更しない。

VBEでの手動Compile方式、プログラム制御方式、安全な隔離環境での方式を候補として比較してよいが、今回実行しない。

実装コードや自動化スクリプトを新規作成する必要はない。

### 6. 原本保護・一時コピーの方針

将来の再試行では、原本をExcelで開かず、一時作業コピーを用いる案を優先する。

設計上の確認事項：

- 原本と一時コピーのSHA-256照合
- 一時コピーの保存場所
- Repository／Evidence保管領域との分離
- Workbook保存の禁止
- VBA Import／Exportの禁止
- Compile終了後の一時コピーの取扱い
- 検証後の原本SHA-256不変確認
- エラー時の変更・未完了状態の記録

今回、一時コピーを作成してはならない。

### 7. STOP条件

次のいずれかの場合、将来のS5-B再試行はWorkbook Open前または問題発生時点で停止する設計とする。

- 対象WorkbookのHash不一致
- 独立Excelセッションの成立を保証できない
- Workbook Open前のMacro Security／EnableEvents抑止を確認できない
- XLM Macroの扱いが未解決
- 外部接続の自動実行リスクを評価できない
- Excel起動時の自動マクロ・アドイン等のリスクを解消できない
- VBAProjectへのアクセスが必要だが安全に確認できない
- Compileとマクロ無効化の両立が未確認
- 想定外のセキュリティ警告・権限要求が発生
- 保存・Import／Export・Production修正が必要になる
- その他、承認範囲外の操作が必要になる

PermissionDeniedの回避を目的とした管理者権限への昇格、Registry ACL変更、Trust Center／Trusted Locations変更は禁止する。

未知の警告には自動応答しない。

停止時の自動Retry・自動Rollbackは禁止する。

### 8. 今回の実施境界

許可：

- 公式資料・既存Evidenceの読取り
- Workbook既存構造の安全なRead-only参照
- 安全制御方式の比較
- 未証明事項・リスクの整理
- 将来のS5-B再試行手順案の提示

禁止：

- Excel起動
- Workbook Open
- VBA Compile
- マクロ実行
- 技術テスト
- 一時コピー作成
- VBA Import／Export
- Registry／Trust Center／Application設定変更
- 権限昇格
- ファイル・文書・Source編集
- 新規実行スクリプトの作成・実行
- Git操作
- Baseline変更
- S5-C以降の開始
- P2-05 Completion
- P2 Phase Closure／CP-P2

新しい管理文書やEvidenceファイルを作らず、Codexの回答内だけで結果を報告する。

### 9. 最終報告

以下の構造で報告する。

```text
S5BSafetyReviewAuthorization:
  APPROVED_READ_ONLY

PriorS5BDecision:
  REVIEW_REQUIRED

TargetWorkbook:
  Identification: VERIFIED_BY_SHA256
  WorkbookOpened: FALSE

SecurityControls:
  IndependentExcelInstance:
    SUPPORTED / REVIEW_REQUIRED / BLOCKED
  AutomationSecurity:
    DESIGN_SUPPORTED / REVIEW_REQUIRED
  EnableEvents:
    DESIGN_SUPPORTED / REVIEW_REQUIRED
  ExternalLinkSuppression:
    DESIGN_SUPPORTED / REVIEW_REQUIRED
  StartupAddinsAndAutoMacros:
    REVIEWED / REVIEW_REQUIRED
  Excel4MacroRisk:
    NO_INDICATOR_FOUND / PRESENT / UNKNOWN
  ExternalDataConnectionRisk:
    REVIEWED / REVIEW_REQUIRED

CompileFeasibility:
  MacroDisabledCompile:
    SUPPORTED_BY_EVIDENCE / NOT_VERIFIED / BLOCKED
  SafeManualVBEProcedure:
    PROPOSED / REVIEW_REQUIRED
  CurrentCompile:
    NOT_EXECUTED

RecommendedS5BRetryProcedure:
  [ordered preconditions and actions]

UnresolvedSafetyIssues:
  [...]

AdditionalUserAuthorizationRequired:
  YES

S5BSafetyReviewDecision:
  READY_FOR_USER_AUTHORIZATION /
  REVIEW_REQUIRED /
  BLOCKED

ExcelStarted: FALSE
WorkbookOpened: FALSE
TemporaryCopyCreated: FALSE
VBACompileExecuted: FALSE
SettingsModified: FALSE
DocumentMutation: NONE
SourceMutation: NONE
GitOperation: NONE

S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
P2PhaseClosed: FALSE
CP_P2Established: FALSE
```

最後に以下を明示する。

1. 確認済みのMicrosoft公式仕様
2. 今回実際に確認できた環境固有の事実
3. 未証明・判断待ちの事項
4. S5-B再試行に必要な最小承認範囲
5. 安全条件を満たせない場合の代替案

`READY_FOR_USER_AUTHORIZATION`でもS5-B再試行を自動実行せず、結果を報告して停止すること。
