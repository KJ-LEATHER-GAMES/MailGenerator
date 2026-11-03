# S5-B Safe Execution Procedure Review結果

判定は `REVIEW_REQUIRED` です。安全制御の設計は一部支持されますが、**独立起動・起動時追加物の抑止・マクロ無効状態でのCompile可否**が未確定です。

重要な修正点として、`AskToUpdateLinks=False`は更新抑止に使えません。公式仕様では「確認ダイアログなしでリンクを自動更新する」設定です。候補手順から除外します。[Microsoft公式仕様](https://learn.microsoft.com/en-us/office/vba/api/excel.application.asktoupdatelinks)

## 1. 確認した公式仕様

| 項目 | 確認結果と設計上の扱い |
| --- | --- |
| AutomationSecurity | `ForceDisable`はプログラムで開くファイルのマクロを無効化。ただしXLMは例外。Open直前の設定・読戻しが必要。`DisplayAlerts`／`ScreenUpdating`は代用になりません。[公式仕様](https://learn.microsoft.com/ja-jp/office/vba/api/excel.application.automationsecurity) |
| EnableEvents | 読み書き可能で、`False`によるイベント抑止が可能。ただし、Application取得前に動いた起動処理を遡って止めるものではありません。[公式仕様](https://learn.microsoft.com/ja-jp/office/vba/api/excel.application.enableevents) |
| Workbooks.Open | `UpdateLinks:=0`、`ReadOnly:=True`、`AddToMru:=False`を明示する設計は支持されます。マクロ制御は別途必要です。[公式仕様](https://learn.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open) |
| 起動スイッチ | `/automation`は自動オープン・自動実行マクロ、`/safe`は起動フォルダーやExcelアドイン等の読込みを抑止する根拠があります。いずれも対象Workbookの安全性全体を保証しません。[公式説明](https://learn.microsoft.com/ja-jp/troubleshoot/microsoft-365-apps/excel/files-open-automatically) |
| 独立プロセス | `/x`は別プロセスを開始。ただし公式資料は複数スイッチ同時使用を非サポートとしており、`/x /safe`等を成立済みの方法にはできません。[公式スイッチ一覧](https://support.microsoft.com/en-us/office/lifecycle/command-line-switches-for-microsoft-office-products) |
| 外部データ更新 | QueryTable／OLE DB／ODBCには別の更新設定・仕様があります。`UpdateLinks:=0`を全外部アクセスの禁止と解釈しません。[QueryTable](https://learn.microsoft.com/en-us/office/vba/api/excel.querytable.refreshonfileopen)、[OLE DB](https://learn.microsoft.com/en-us/office/vba/api/excel.oledbconnection.refreshonfileopen)、[ODBC](https://learn.microsoft.com/en-us/office/vba/api/excel.odbcconnection.refreshonfileopen) |

Safe Modeにもコマンドラインオプション等の制限があるため、複数の効果を推測で合成しない方針です。[Safe Modeの制限](https://support.microsoft.com/en-us/office/lifecycle/open-office-apps-in-safe-mode-on-a-windows-pc)

### Compileとの両立

公式資料は「Compileがプロジェクトをコンパイルする操作」であることを説明しています。しかし、**ForceDisableで開いた対象をCompileでき、Productionマクロ・イベントを動作させないという組合せの保証は確認できませんでした**。[Debug menu](https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/debug-menu)

既存Compile Evidenceにも当時のForceDisable状態は記録されていません。したがって、`MacroDisabledCompile: NOT_VERIFIED`を維持します。

Trust AccessはVBA Object Modelへのプログラムアクセスの許可であり、手動VBE操作とは別判定です。無効・アクセス拒否でも設定は変更しません。[Macro Security公式説明](https://support.microsoft.com/ja-jp/excel/change-macro-security-settings-in-excel)

## 2. 今回確認した環境固有の事実

対象：OneDrive配下の外部作業Workbook `MailGeneratorNew.xlsm`（個人実パスは非公開）

サイズ1,003,775 bytes、SHA-256は指定値と一致しました。

```text
0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9
```

ZIP内部をファイル展開・書戻しなしで検査しました。

| 検査範囲 | 結果 |
| --- | --- |
| ZIP項目／XML・Relationship | 全19項目／18項目を確認 |
| シート対応 | 3件すべて通常Worksheet |
| XLM Macro SheetのPart・Content Type・Relationship | 検出0 |
| Defined Name・自動実行名 | 0 |
| External Link・外部Relationship | 0 |
| Connections・QueryTable・Power Query／Custom XML・Data Model関連Part | 検出0 |
| RefreshOnOpen関連属性・Worksheet数式 | 検出0 |
| VBAProject | 存在。バイナリ内部は未検査 |

これは**保存済みOOXML構造上の指標が見つからなかった**という結果です。VBAや起動アドインによる動的な処理、全外部通信の不存在は証明していません。

参照51件の前後Hash・サイズ・更新時刻は不変でした。Excelは起動していません。

## 3. 推奨する将来手順案（未実行）

以下は、未解決条件を解消してから別途承認する手順です。

1. **起動方式を確定**\
   既存セッションへ接続せず、起動追加物の抑止と専用PID・Application参照の対応を確認できる方式を選定する。成立しなければ対象Open前に停止。
2. **Compile両立の根拠を確保**\
   マクロ無効状態でのCompileについて、信頼できる既存Evidenceまたは別途承認した隔離環境での適用可能性確認を得る。未確認のまま対象を開かない。
3. **検証コピーを1件だけ作成**\
   保存先はRepository・Evidence保管領域外。実パス、アクセス条件、衝突、保持方針を事前確認し、原本とのHash一致を確認する。今回は保存先の採用・作成をしていない。
4. **対象未Openの状態で制御値を設定・読戻し**

   ```text
   同じ専用Application参照
   → AutomationSecurity = msoAutomationSecurityForceDisable
   → EnableEvents = False
   → 両値を読戻し
   → 不一致・例外ならOpenせず停止
   ```

   `AskToUpdateLinks=False`は使用しない。警告抑制をセキュリティの代用にしない。
5. **条件成立後だけプログラムでコピーをOpen**\
   `UpdateLinks:=0 / ReadOnly:=True / AddToMru:=False`を明示する。通常の手動Openへ自動切替しない。
6. **Source・イベントを確認後、Compileだけを実行**\
   Run／Step／Enable Contentは使用しない。Compileが無効・実行不明・エラーなら停止し、設定変更・修正・再Compileを行わない。
7. **保存せず終了・保全確認**\
   正常時は対象コピーを保存せず閉じ、所有を確認した専用セッションだけを終了する。異常時は無断終了・Retry・Rollbackをせず状態を報告する。コピーは所在と最終Hashを報告し、削除は別承認とする。

既存セッションのApplication値変更や、一括したExcelプロセス終了は計画に含めません。

## 4. 未解決事項と最小承認範囲

| 方式候補 | 評価 |
| --- | --- |
| 手動VBE Compile | プログラムによるVBOM参照に依存しない候補。ただし安全なOpenとマクロ無効状態でのCompile可否が未確定 |
| プログラム制御 | Open前の設定順序・読戻しを明示できる候補。ただし独立起動・起動時追加物・Application参照の対応が未検証 |
| 専用隔離環境 | 現環境で条件を満たせない場合の代替。環境準備・適用可能性確認は別承認。そこでの結果を現環境へ自動適用しない |

次の最小段階は、**対象Workbookを開かない独立起動・安全制御の成立確認**です。ただし、その起動自体の追加物リスクを先に整理する必要があります。Compile両立の既存証拠が得られない場合は、隔離環境での限定確認を別途計画します。

今回の結果だけでは、S5-B再試行のOpen／Compileまでを承認可能とは判定しません。

```text
S5BSafetyReviewAuthorization: APPROVED_READ_ONLY
PriorS5BDecision: REVIEW_REQUIRED

TargetWorkbook:
  Identification: VERIFIED_BY_SHA256
  WorkbookOpened: FALSE

SecurityControls:
  IndependentExcelInstance: REVIEW_REQUIRED
  AutomationSecurity: DESIGN_SUPPORTED
  EnableEvents: DESIGN_SUPPORTED
  ExternalLinkSuppression: DESIGN_SUPPORTED
  StartupAddinsAndAutoMacros: REVIEW_REQUIRED
  Excel4MacroRisk: NO_INDICATOR_FOUND
  ExternalDataConnectionRisk: REVIEWED  # 保存済みOOXML構造の範囲

CompileFeasibility:
  MacroDisabledCompile: NOT_VERIFIED
  SafeManualVBEProcedure: REVIEW_REQUIRED
  CurrentCompile: NOT_EXECUTED

RecommendedS5BRetryProcedure:
  - 独立性・起動抑止方式の確定
  - Compile両立の根拠確認
  - 承認済み一時コピーのHash照合
  - Open前の安全制御設定・読戻し
  - 条件成立後のみOpen・構造確認・Compile
  - 保存せず終了・原本保全確認

UnresolvedSafetyIssues:
  - 独立起動と起動時追加物抑止の同時成立
  - 対象Application参照と専用プロセスの対応
  - ForceDisable状態でのCompile両立

AdditionalUserAuthorizationRequired: YES
S5BSafetyReviewDecision: REVIEW_REQUIRED

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

S1～S4、既存21ケースの限定付きPASS、IF-P2-05-001のCLOSED、OBS-P2-05-002のOPEN／NON-BLOCKING、既存の残留UNKNOWNは維持しています。調査スキルは根拠確認と非編集の構造検査に限定し、ファイルを作成せず停止します。
