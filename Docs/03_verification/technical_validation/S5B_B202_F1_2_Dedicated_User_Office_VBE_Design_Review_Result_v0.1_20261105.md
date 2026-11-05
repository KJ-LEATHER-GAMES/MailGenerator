# S5-B B2-02-F1-2 専用Windowsユーザー／Office・VBE利用条件 設計レビュー結果

**B2-02-F1-2の机上レビューは`DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS`と評価します。**
専用標準ユーザーは設計候補になりますが、Production資源の遮断、Office再利用、専用ユーザーでのVBE／Compile利用は未成立です。実行承認やA＋C1の正式採用は行いません。

## 1. Evidenceと設計評価

今回提示されたWindows・Office情報は、引き続き`USER_ATTESTED`／`REPORTED`として扱います。実機状態の独立確認は行っていません。

### 専用ローカル標準ユーザー

Windows公式資料は、ローカルアカウントの追加とアカウント種別の管理を説明しており、この方式は候補にできます。ただし、対象PCでの作成・利用成功を確認したものではありません。[Microsoft公式：ユーザーアカウント管理](https://support.microsoft.com/en-us/windows/security/identity-signin/manage-user-accounts-in-windows)

成立条件は次のとおりです。

- 専用アカウント自体が標準ユーザーである。
- Administratorsおよび対象ローカルグループへの非所属を確認する。
- 既存の本番プロファイル・資格情報・同期設定を複製しない。
- Excelと制御側プロセスの実行主体も確認対象にする。
- 作成・切替・所属確認は、それぞれ承認された範囲で行う。

**管理者アカウントの非昇格実行と、標準ユーザーアカウントは別です。** 今回の`CurrentWindowsUser: ADMINISTRATOR_USER_ATTESTED`は、以前の非昇格実行申告と矛盾しません。[Microsoft公式：UACの動作](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/how-it-works)

### Production資源の遮断

Windowsのアクセス判定は、実行主体のアクセストークンと対象オブジェクトのDACLを照合します。[Microsoft公式：AccessCheck](https://learn.microsoft.com/en-us/windows/win32/secauthz/how-dacls-control-access-to-an-object)

したがって、以下は**設計上の推論・未検証条件**です。

- 新規ユーザーの非所属だけでは、Excelや制御プロセスを含む全経路の遮断を証明できない。
- 共通3主体のルートACE不在は、子要素・個別Workbook・Archive・別経路の遮断証明ではない。
- P01と照会した同名グループとのSID一致、推移的所属は未検証のまま。
- Clone、Workbook、Archiveごとに、対象ACL・継承例外・実行主体・共有／同期経路を評価する必要がある。

これはF1-READ-01の再開ではなく、**後続の隔離成立評価へ引き渡す条件**です。

## 2. Office 2019／VBE／Compile

### 既存Officeの再利用

`Personal2019Retail_REPORTED`、64bit、VBE DLL存在は、専用ユーザーからの利用PASSにはなりません。

確認すべき事項は以下です。

- 正確な製品・購入形態と適用される利用条件
- ライセンス所属・既存認証状態
- 専用WindowsプロファイルからのExcel利用可否
- 初回起動時の認証・権限・設定要求の有無

日本向けOffice 2019は提供形態によって利用条件の説明が異なります。製品識別文字列だけで利用権を確定したり、Microsoft 365の仕様を流用したりしません。[Microsoft公式：日本向けOffice 2019の提供形態](https://blogs.windows.com/japan/2019/01/15/sales-family-office-2019/)

認証失敗時にはOfficeの機能が制限され得ますが、**今回認証・再認証を実施する根拠にはしません**。必要になれば停止し、別途判断します。[Microsoft公式：認証エラーと機能制限](https://support.microsoft.com/ja-jp/microsoft-365-activation-licensing/office-install/unlicensed-product-and-activation-errors-in-office)

### セキュリティ設定を緩和しないCompile

次を別々に確認する必要があります。

1. 専用ユーザーからExcelを利用できる。
2. VBEと対象プロジェクトを参照できる。
3. 起動時追加物・マクロ・イベントの抑止条件が成立する。
4. その条件下でCompile操作を実施できる。
5. Compile結果と、意図しない実行がなかった観測を別々に記録できる。

VBE DLLの存在は、このどれも実証しません。VBOM Trust Accessはプログラムアクセスの許可であり、手動VBE操作と同一の判定でもありません。[Microsoft公式：Macro Security](https://support.microsoft.com/ja-jp/excel/change-macro-security-settings-in-excel)

公式資料はCompileコマンドを説明していますが、**マクロ無効化との両立が対象環境で成立することは未検証**です。[Microsoft公式：Debug menu](https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/debug-menu)

Trust Center／Trusted Locations／VBOMの緩和が必要なら停止します。将来の一時的なApplication安全制御も、今回の実行承認には含まれません。

### Office 2019のサポート終了

Office 2019のサポートは**2025年10月14日に終了**しています。Microsoftは、アプリは引き続き機能する一方、セキュリティリスク等が残ると説明しています。終了と起動・Compile不能は同一視しません。[Microsoft公式：サポート終了](https://support.microsoft.com/ja-jp/office/system-requirements/end-of-support-for-office-2016-and-office-2019)

**設計評価：** 別PC・標準ユーザー・無害Fixture・通信制限は低減策の候補ですが、未修正の脆弱性を解消しません。今回限定の利用リスク判断、または別環境の選択が必要です。既存S1の限定リスク受容は流用しません。

## 3. Risks／RemainingUnknowns

以下のIDは、本レビュー内の整理用です。正式なFinding登録ではありません。

| ID | 内容・必須確認事項 | 影響 | 確認予定工程・必要な承認 |
| --- | --- | --- | --- |
| F1-2-R01 | 専用ユーザーの標準属性・非所属・実行主体 | 権限分離が成立しない可能性 | ユーザー成立確認。作成・切替・所属確認の個別承認 |
| F1-2-R02 | P01のSID対応・推移的所属・対象別ACL・別経路 | Production資源へのアクセスが残る可能性 | 後続の遮断評価。対象・方法を限定した確認承認 |
| F1-2-R03 | Officeの利用条件・購入形態・認証状態 | 再利用不可、機能制限、承認外の認証要求 | 既存証跡の照合。認証操作が必要なら別承認 |
| F1-2-R04 | 専用ユーザーでのExcel／VBE利用 | DLL存在だけではPreflightに進めない | 専用ユーザーでの限定利用確認。起動の別承認 |
| F1-2-R05 | 起動抑止・安全制御とCompileの両立 | 意図しない実行、Compile未成立 | 隔離条件成立後のPreflight。Fixture・起動・Compile等の別承認 |
| F1-2-R06 | Office 2019のサポート終了 | 未修正不具合・脆弱性の残留 | Office実利用前のユーザー判断。限定受容または別環境選択 |
| F1-2-R07 | Office Build・参照設定等の環境差 | Fixture PASSを本番Buildへ転用できない | 将来のS5-B適用範囲審査。本番検証は別承認 |

## 4. 後続工程との依存関係

F1-3、F1-4、F1-5、AUTH-03、AUTH-05の**正式な工程定義・承認範囲は、今回の提示資料では未照合**です。番号から役割を推測して割り当てません。

本レビューから引き渡す依存条件は、次のとおりです。

- 変更操作より先に、その操作をカバーする承認が必要。
- 専用ユーザー成立・所属確認と、対象別アクセス遮断を別判定にする。
- Office利用条件と専用プロファイルでの利用可否を確認してから、VBE／Preflightの実施可否を判断する。
- FixtureのCompile成立後も、本番S5-Bへの適用を別審査にする。

各条件を上記5工程のどこへ割り当てるかは、**既存工程定義との机上照合で確定する残件**です。今回は後続工程へ着手していません。

```yaml
DesignFeasibility:
  DedicatedStandardUser: CANDIDATE
  ProductionResourceIsolation: NOT_VERIFIED
  ExistingOfficeReuse: REVIEW_REQUIRED
  DedicatedUserVBE: NOT_VERIFIED
  VBACompile: NOT_VERIFIED

F1Read01Decision: COMPLETE_WITH_LIMITATIONS
F1_2_ReviewDecision: DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS

C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
APlusC1FormallyAdopted: FALSE

PCOperation: NONE
CommandExecuted: FALSE
OfficeActivationPerformed: FALSE
FixtureCreated: FALSE
PreflightExecuted: FALSE
DocumentMutation: NONE
GitOperation: NONE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

researchスキルを公式資料の照合に限定し、調査文書は作成していません。既存Closure、S5-A・P05の限定付きEvidence、Finding／Observation、Baseline履歴を維持し、ここで停止します。
