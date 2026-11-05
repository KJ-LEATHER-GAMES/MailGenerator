# 引き継ぎまとめ

## 実施内容

### 1. プロジェクトの現在地を確認

- 対象プロジェクト：定型メール作成ツール
- 技術構成：Excel VBA + Outlook Classic + OFTテンプレート
- 開発対象：P2 Scan / Sync
- 現在の重点：P2-05のS5-B、Production Workbookに対するVBA Compileの安全な検証環境整備
- 検証候補PC：`S5B-TestPC-01`
- 正式な隔離方式：未選定
- A＋C1方式：候補として検討継続
  - A：テストPC全体のネットワーク制限
  - C1：専用Windows標準ユーザーによるProduction関連資源からの分離
- 代替候補：A＋C2（隔離VM方式）

既存のS1～S4 Closure、S5-Aの限定付きEvidence、Finding／Observation、Baseline履歴は変更していない。

### 2. Workbook配置申告の整合性を整理

以前の「同一Workbook」という表現を修正した。

- ローカルCloneはOneDrive管理外とのユーザー申告を維持。
- OneDrive側とClone側のWorkbookについて、「同一」は同じ版・内容を意味する。
- 物理的に同じファイルであることは意味しない。
- 過去の`SameFile: YES`は、ユーザーの説明によって置き換えた。
- `WorkbookLocationReconciliation: RESOLVED`
- `WorkbookPhysicalIdentity: UNKNOWN`
- 独立した技術検証は未実施。

### 3. F1-READ-01：Clone ACLの確認

`RESOURCE-CLONE-A`のルートフォルダーについて、既存のWindows標準GUIを利用してユーザーが手動確認した。

証拠区分：

- `USER_ATTESTED`
- `USER_MANUAL_GUI`

確認結果：

- ACL継承：`ENABLED`
- ACE一覧：P01～P04の4件が全件
- 全4件が継承されたAllow ACE
- Users：`ABSENT_IN_ROOT_ACL`
- Authenticated Users：`ABSENT_IN_ROOT_ACL`
- Everyone：`ABSENT_IN_ROOT_ACL`
- 直接共有：なし（ユーザー申告）

各ACE：

| ID | 主体 | 権限 | 継承 |
|---|---|---|---|
| P01 | CodexSandboxUsers | ReadAndExecute | Inherited |
| P02 | SYSTEM | FullControl | Inherited |
| P03 | Administrators | FullControl | Inherited |
| P04 | 現在のユーザー | FullControl | Inherited |

すべて「このフォルダー、サブフォルダー、ファイル」に適用されるとのGUI申告。

ただし、以下は未検証：

- 個別Workbookおよび子要素の実際のACL
- ACL上のP01と同名グループのSID一致
- 実際のグループ所属を含む実効アクセス
- 親階層や別経路の共有・アクセス
- 将来の専用標準ユーザーによるアクセス可否

### 4. ACL調査用PowerShellスクリプトの静的レビュー

対象ファイル：

`S5B_F1_READ_01_CloneACL_ReadOnly.ps1`

実施内容：

- 添付スクリプトの静的レビュー
- Codexによる構文解析
- 構文解析エラー0件との報告
- Codex報告のSHA-256：
  `7e93127bc1571ec28f47862dade6995849caed821735daa1e8c4f1c6fd4800ca`

確認された懸念：

1. `Get-LocalUser`／`Get-LocalGroup`が全ローカルユーザー・グループを列挙する。
2. `Get-Item`がReparsePoint検査に先行し、拒否前のアクセスを完全には防止できない。
3. パス入力画面から実パスがEvidenceに混入する可能性がある。

判定：

- `StaticReview: REVIEW_REQUIRED`
- スクリプト実行なし
- スクリプト修正なし
- 実行許可なし

代替手段としてGUI確認と限定されたWindows標準コマンドを採用したため、今回のF1-READ-01完了条件にスクリプト実行を追加しないこととした。

### 5. P01：CodexSandboxUsersの所属確認

環境：

- Windows 11 Home（USER_ATTESTED）
- 現在のユーザーは管理者アカウントとの過去申告
- 専用標準ユーザーは未作成

Windows 11 Homeでは、通常の「ローカルユーザーとグループ」管理GUIが利用できないため、Windows標準コマンドによる限定照会を検討した。

対象コマンド：

`net localgroup "CodexSandboxUsers"`

実行までの経緯：

1. 当初はCodex実行を限定承認。
2. Codexのコマンド実行先が`S5B-TestPC-01`に対応することを確認できず停止。
3. `ExecutionTargetBinding: UNKNOWN`を維持。
4. Codexによるコマンド実行は0回。
5. ユーザー本人による手動実行方式を別途承認。
6. 対象PCをGUIで確認。
7. 非昇格のコマンドプロンプトで指定コマンドを1回だけ実行。
8. 正常終了を確認。
9. 結果を匿名化してCodexへ報告。

結果：

- 同名のローカルグループを確認
- 直接メンバー：2件
- 匿名ID：M01、M02
- メンバーの主体区分：UNKNOWN
- 推移的所属：NOT_VERIFIED
- P01とのSID一致：NOT_VERIFIED
- Codexツールの実行先：引き続きUNKNOWN

証拠区分：

`USER_ATTESTED / USER_MANUAL_COMMAND`

非昇格セッションであったことは、Windowsアカウントが標準ユーザーだったことを意味しない。

### 6. F1-READ-01の限定付き完了

ACL棚卸しとP01の直接メンバー確認について、既存Evidenceによる完了評価を実施。

最終判定：

- `P01DirectMembershipAssessment: COMPLETE_WITH_LIMITATIONS`
- `F1Read01Decision: COMPLETE_WITH_LIMITATIONS`

判断理由：

- 今回定義した調査範囲の情報が取得された。
- 取得できなかった事項と証拠の限界が明示された。
- 追加のPC操作を今回の完了条件に含める必要がない。

ただし、これは調査の限定付き完了であり、C1の隔離成立ではない。

### 7. B2-02-F1-2：専用WindowsユーザーとOffice/VBE利用条件の設計レビュー

F1-READ-01完了後、次の机上レビューを実施した。

レビュー対象：

- 新規ローカル標準ユーザー方式
- Administrators／CodexSandboxUsersへの非所属設計
- Production関連Clone・Workbook・Evidence Archiveのアクセス遮断
- Office 2019の専用ユーザーでの利用条件
- Office認証とVBE利用可能性
- セキュリティ設定を緩めずにCompileを行う成立条件
- Office 2019サポート終了リスク
- 後続工程と承認ゲートの依存関係

既存環境の報告：

- Office：`Personal2019Retail`
- 64-bit版
- Excelバージョンの過去報告：`16.0.19127.20860`
- VBE関連DLL存在の過去報告
- 専用ユーザーでのExcel/VBE動作：未確認

Microsoft公式資料を参照して整理した論点：

- Windows 11のローカルユーザーと標準ユーザー
- UACと非昇格セッション
- Windows DACLとアクセストークン
- Office 2019の製品形態・認証条件
- VBA Compileとマクロセキュリティ
- Office 2019の2025年10月14日サポート終了

Codexの最終判定：

`F1_2_ReviewDecision: DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS`

設計評価：

| 項目 | 判定 |
|---|---|
| 専用標準ユーザー方式 | CANDIDATE |
| Production資源の隔離 | NOT_VERIFIED |
| 既存Office再利用 | REVIEW_REQUIRED |
| 専用ユーザーでのVBE | NOT_VERIFIED |
| VBA Compile | NOT_VERIFIED |
| C1全体 | C1_REVIEW_REQUIRED |

### 8. F1-2のリスク整理

レビュー内の暫定リスクIDとして以下を整理した。正式なFinding登録ではない。

- `F1-2-R01`：専用ユーザーの標準属性・所属・実行主体
- `F1-2-R02`：P01のSID対応、対象別ACL、別アクセス経路
- `F1-2-R03`：Officeの製品形態、利用条件、認証
- `F1-2-R04`：専用ユーザーでのExcel/VBE利用
- `F1-2-R05`：起動抑止、安全制御とCompileの両立
- `F1-2-R06`：Office 2019サポート終了リスク
- `F1-2-R07`：Office Build、参照設定、FixtureとProductionの環境差

### 9. 参照した主な文書・管理対象

- `AI協働開発 文書管理・Baseline運用ルール v0.1.md`
- `MVP Requirements v0.1.9 日本語版.md`
- `MVP Design v0.1.9 日本語版.md`
- `MVP Test Specification v0.1.5 日本語版.md`
- `Implementation Plan v0.3 日本語版(2).md`
- `P2-05 Fail Closed - Sync Result - Phase Integration Implementation Specification v0.1 Approved.md`
- `P2-05 Fail Closed - Sync Result - Phase Integration Cross-document Consistency Review v0.1.md`
- `IF-P2-05-001 Finding Assessment and Verification Resume Decision v0.7.md`
- `S5B_F1_READ_01_CloneACL_ReadOnly.ps1`
- B2-02-F1設計計画・承認ゲート定義（正式な文書名・現行版は要確認）

本会話では、Production Workbook、Approved文書、Repository、Baselineを変更していない。

レビュー結果は主にチャット上で管理されており、正式な管理文書への反映は未確認。

## 決定事項

### 1. F1-READ-01を限定付き完了とする

- `F1Read01Decision: COMPLETE_WITH_LIMITATIONS`
- 調査範囲の完了と隔離成立は分けて扱う。
- 不明事項は後続工程へ引き継ぐ。
- 未実行PowerShellスクリプトの実行を完了条件に追加しない。

### 2. 手動コマンド結果の証拠区分

- ユーザー手動GUI確認：`USER_ATTESTED / USER_MANUAL_GUI`
- ユーザー手動コマンド：`USER_ATTESTED / USER_MANUAL_COMMAND`
- Codexの直接観測結果として扱わない。
- 未確認事項をPASSへ格上げしない。

### 3. F1-2の机上レビュー完了

- `DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS`を採用。
- 残る利用条件とアクセス遮断条件を後続の検証対象とする。
- 設計レビュー完了を環境構築の承認とみなさない。

### 4. 隔離方式の選定を保留

- A＋C1は引き続き設計候補。
- 正式採用はしていない。
- A＋C2も代替候補として維持。
- `IsolationMethodSelected: NONE`
- `IsolationEstablished: NOT_VERIFIED`

### 5. Office/VBEの評価方針

- Officeインストール済みと専用ユーザーでの利用可能性を区別。
- VBE DLL存在とVBE操作可否を区別。
- VBE操作可否と安全なCompile可否を区別。
- Compile成功と意図しないマクロ実行の不存在を別々に確認する。
- セキュリティ設定の緩和やOffice認証操作は無断実施しない。
- Office 2019のサポート終了リスクは別途判断する。

### 6. 承認境界を維持

- F1-3～F1-5は未着手。
- AUTH-01～AUTH-06は未承認。
- Windowsユーザー作成、所属変更、ACL変更、Excel/VBE起動、Fixture作成、Preflight、Git操作、Production Workbook変更は未承認。
- 実行承認は個別操作に限定し、後続操作へ自動継承しない。

## 未解決事項

### A. C1隔離設計

- ACL上のP01と照会したローカルグループのSID一致
- M01・M02の主体区分
- 推移的グループ所属
- 将来の専用標準ユーザーの所属先
- 対象ごとの実際のACL・継承例外
- Clone、Workbook、Archiveへの実効アクセス
- 別ユーザー、共有、同期、管理権限などのアクセス経路
- Codex実行主体と専用Windowsユーザーとの関係

### B. Office/VBE

- Office 2019の正確な製品・利用条件
- 専用ユーザーでのOfficeライセンス・認証状態
- Excel起動可能性
- VBE操作可能性
- VBA参照設定・環境差
- マクロ抑止とCompile操作の両立
- Office 2019サポート終了リスクの受容可否
- Office認証とネットワーク遮断の両立

### C. 後続工程・承認

- B2-02-F1-3～F1-5の正式な工程定義との照合
- AUTH-01～AUTH-06の正式な対象・順序・条件との照合
- Evidence保存場所、保管方法、承認境界
- A＋C1の正式採否
- AUTH-03相当の実効アクセス検証方法
- AUTH-05相当の安全なFixture/Preflight実施条件

### D. P2-05の既存残件

- S5-B：Production WorkbookのVBA Compile未検証
- S5-C：Static Review S01～S32未着手
- S5-D：Production Patch Review／Final Finding Assessment未着手
- S5-E：P2-05 Completion未記録
- `OBS-P2-05-002`：OPEN / NON-BLOCKING
- 既存P05の21ケースは限定付き文書Evidenceであり、現在の実行PASSへ格上げしない
- `CP-P2`未確立
- Workbook物理同一性：UNKNOWN

## 次アクション

### 優先度1：既存B2-02-F1計画の定義照合

**次のチャットで最初に実施する作業。**

確認対象：

- B2-02-F1の既存設計・計画文書
- F1-3～F1-5の正式な目的、範囲、終了条件
- AUTH-01～AUTH-06の定義、順序、承認範囲
- F1-2-R01～R07との対応

進め方：

1. 既存文書の正本・Versionを確認する。
2. F1-3～F1-5の正式定義を抽出する。
3. 各AUTHゲートの対象操作と前提条件を抽出する。
4. 未解決事項と工程の対応表を作成する。
5. 工程重複・不足・循環依存を確認する。
6. 次に実施すべき最小工程を提案する。
7. 環境変更なしで停止する。

過去の作業上の位置づけ：

- F1-3：Excel起動時追加物
- F1-4：ネットワーク制限・オフライン運用
- F1-5：Evidence保存・保全条件

ただし、正式な定義との照合は未完了。

### 優先度2：F1-2のOpen Conditionsを工程へ割当て

- リスクR01～R07を必要な工程・Gateへマッピング。
- Office 2019の限定利用リスク判断を配置。
- 専用ユーザー成立確認とアクセス遮断確認を分離。
- Preflight FixtureとProduction Compileの判定を分離。

### 優先度3：後続工程の限定承認案を作成

- 優先度1・2の照合後に実施。
- 対象PC、操作、権限、Evidence、STOP条件を明文化。
- ユーザー承認前にPC操作を開始しない。

### 次チャットで使用する再開プロンプト

> 定型メール作成ツールのS5-B隔離計画を再開します。
>
> F1-READ-01は`COMPLETE_WITH_LIMITATIONS`、B2-02-F1-2は`DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS`で終了しました。
>
> Windows 11 HomeのS5B-TestPC-01に対するCloneルートACLとCodexSandboxUsersの直接メンバーは、ユーザー申告Evidenceとして整理済みです。
>
> A＋C1は候補ですが、`C1_REVIEW_REQUIRED`、`IsolationEstablished: NOT_VERIFIED`です。
>
> 次は既存のB2-02-F1計画を参照し、F1-3～F1-5とAUTH-01～AUTH-06の正式定義・依存関係・承認境界を机上照合してください。
>
> F1-2のOpen Conditions R01～R07を工程へ割り当て、重複・不足を評価してください。
>
> 新しいPC操作、ユーザー作成、ACL変更、Office起動、Compile、Preflight、文書変更、Git操作は承認しません。
>
> 既存Closure、限定付きEvidence、Finding／Observation、Baseline履歴を維持し、照合結果と次の最小工程を提示して停止してください。
