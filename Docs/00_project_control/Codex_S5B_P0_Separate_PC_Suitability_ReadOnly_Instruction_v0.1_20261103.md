# S5-B-P0 別PC環境適合性確認

## Codex限定Read-only実行指示 v0.1

### 1. 目的と承認範囲

ユーザーは、S5-B Preflightに利用できる別PCが存在すると申告した。

今回の目的は、この別PCがS5-Bの隔離検証環境として利用可能か、Read-onlyで確認することである。

許可される作業：

- 別PCのOS・Office構成の読取り
- Production資源との分離状況の調査
- 既存の共有・同期・ネットワーク設定の確認
- Excel起動時追加物の静的調査
- Fixture／Evidence保存先候補の適合性評価
- 未解決事項と必要な追加承認の整理

**今回の承認は環境適合性確認のみ。Excelを起動するPreflight実行は承認されていない。**

### 2. 前提状態

```text
S1～S4:
  CLOSED / PASS

S5-A:
  Target Workbook: VERIFIED_BY_SHA256
  P05 Evidence Reuse: ACCEPTED_WITH_LIMITATIONS

S5-B:
  Final Build Compile: NOT_VERIFIED
  Decision: REVIEW_REQUIRED

S5-B Preflight:
  Execution: NOT_AUTHORIZED

Isolation Candidate:
  Separate PC
  Existence: USER_ATTESTED
  Suitability: NOT_VERIFIED

S5-C～S5-E:
  NOT_STARTED
```

既存21ケースの限定付きPASS、Finding／Observation、Baseline履歴、残留UNKNOWNを維持する。

### 3. 調査対象の限定

調査対象は、ユーザーが検証用として指定する別PCのみ。

本番PC、Production Repository、OneDrive内の本番Workbook、Evidence Archiveを調査対象に追加しない。

Codexが別PCにアクセスできない場合、無断でリモート接続・エージェント導入・資格情報取得を行わない。

その場合は、別PC上でユーザーが確認すべき項目を報告して停止する。

別PCの識別情報は必要最小限とし、ユーザー名、アカウント情報、シリアル番号、資格情報等を不要に収集・報告しない。

### 4. Gate P0-A：環境識別・OS／Office構成

次をRead-onlyで確認する。

**PC識別**

- 検証用PCの識別名またはユーザーが指定する管理用識別子
- 物理PCか仮想環境か
- 本番PCとは異なる端末であること
- 現在利用中のユーザー権限の種別

**OS**

- Windows Edition
- Windows Version／Build
- 32bit／64bit
- 更新状態について確認できる範囲
- 通常権限での確認可否

**Office／Excel**

- Microsoft Excelのインストール有無
- Excel Version／Build
- 32bit／64bit
- VBEコンポーネントの存在について静的に確認できる範囲
- Excelが既に起動中かどうか
- Officeのインストール方式について確認できる範囲

Excelの実行可能ファイル情報や既存のインストール情報等、静的な手段を優先する。

**Excel／Officeアプリケーションを起動して確認してはならない。**

実際のExcel起動・VBE操作・ライセンス動作確認が必要な事項はUNKNOWNとして残す。

### 5. Gate P0-B：Production資源との隔離

以下の存在・設定をRead-onlyで確認する。

**Productionデータ**

- 本番Repositoryのローカルコピー
- 本番Workbook
- 既存Evidence Archive
- 本番Sourceファイル
- 本番ユーザーデータ

**共有・同期**

- OneDriveの利用・同期設定
- ネットワーク共有／マップドライブ
- 共有フォルダーへの既存接続
- 本番PCとのファイル共有
- リモートファイルアクセス手段
- USB等の外部記憶媒体の接続状況

**ネットワーク**

- ネットワーク接続状態
- VPN接続状況
- 既存Firewall設定
- 本番共有資源へ到達する可能性のある既存経路

確認は既存設定・接続情報の読取りに限定する。

Production資源への新規接続、共有へのアクセス試行、Ping等の能動的な到達性テストは実施しない。

OneDriveへのログイン・ログアウト、同期停止、ネットワーク切断、Firewall変更も禁止する。

Production資源への接続経路が存在しないことを確認できない場合、`PRODUCTION_ISOLATION: UNKNOWN`とする。

**Productionファイルが見つからないことだけを、隔離成立の証拠として扱わない。**

### 6. Gate P0-C：Excel起動時追加物

Excelを起動せず、静的な範囲で次を確認する。

- XLSTARTフォルダーの設定・既存内容
- 代替起動フォルダー
- Excel Add-ins
- COM Add-ins
- Office Startup関連設定
- 自動起動Workbook
- 起動時に実行され得る追加機能
- 既存Excelプロセスの有無

確認可能な設定だけを記録する。

アドインが存在する場合は、その識別情報と自動起動可能性を整理する。

不明なアドインを無効化したり、削除したりしない。

`/safe`、`/automation`、`/x`等の起動スイッチを今回試してはならない。

複数スイッチの非サポートな併用を前提としない。

起動追加物の動作可否は実際のExcel起動を伴わない限り未検証であることを明記する。

### 7. Gate P0-D：Fixture保存先の評価

既存のS5-B-P0案を使用する。

```text
C:\S5B_Preflight\
    fixture\
    evidence\
    logs\
```

これは候補であり、実パスとして未採用である。

今回のRead-only確認では、次を評価する。

- 指定パスの既存状態
- 既存ファイルとの衝突
- 権限設定について読める範囲
- OneDrive等の同期対象かどうか
- ネットワーク共有・Production領域との関係
- Fixture／Evidenceを保持するための利用可能容量
- 通常権限で利用できる見込み

**フォルダーの作成、テストファイル書込み、ACL変更は禁止する。**

書込み権限の実証が必要であっても、今回は実行しない。

読取り情報のみでは書込み可能性を保証できない場合はUNKNOWNとする。

候補パスが不適切な場合、代替候補を提案するだけとし、無断採用しない。

### 8. Gate P0-E：Fixture／Evidence／保持方針

以下の既存仕様案を、環境適合性評価の前提とする。

**Fixture**

```text
File:
  SafeCompileFixture.xlsm

Worksheet:
  Observation

Observation Cell:
  B2 = 0 initially

Standard Module:
  modSafeCompileFixture

Workbook_Open:
  Set Observation!B2 = 1

External Connections:
  NONE

Production Dependencies:
  NONE

XLM Macro:
  NONE
```

今回はFixtureを作成しない。

将来、Workbook_Openが動作せずB2が0のままでも、その結果はForceDisable＋EnableEvents=False併用条件下の観測に限定する。

**Evidence取得候補**

- 環境・Office構成
- PID／Application参照の対応
- マクロ・イベント制御値の設定／読戻し
- Fixture SHA-256
- B2の初期状態・Open後・Compile後の観測
- Compile画面・実行結果
- 実施日時・タイムゾーン・実行者
- STOP理由・予期しない変更

今回はEvidenceファイルを作成しない。

**保持方針候補**

```text
Retention:
  90 days after verification

Unresolved Evidence:
  Retain pending explicit decision

Automatic Deletion:
  NONE

Responsible Authority:
  USER

Codex Deletion / Restore:
  Separately Authorized Only
```

90日保持は提案段階であり、今回のRead-only調査によって正式採用されたことにはしない。

### 9. 適合性判定

各項目を次の区分で評価する。

- `VERIFIED`：確認した設定・事実について直接の根拠がある
- `SUPPORTED_WITH_LIMITATION`：限定された証拠がある
- `UNKNOWN`：確認不能
- `NOT_SUITABLE`：必要な隔離条件に明確な不適合がある
- `NOT_CHECKED`：今回確認していない

次の全項目について報告する。

1. 環境識別
2. OS／Office構成
3. VBE利用可能性の静的根拠
4. Production資源との分離
5. OneDrive／共有・ネットワーク設定
6. 起動追加物
7. 保存先候補
8. Evidence管理
9. 保持方針の承認待ち事項

静的な設定確認ができても、実際の起動時挙動を検証済みとはしない。

### 10. 禁止事項

今回のRead-only確認で禁止するもの：

- Excel／Office起動
- Workbook Open
- Fixture作成
- VBAProject作成
- VBA Compile
- マクロ実行
- Production Workbook／Sourceの読込み・コピー
- フォルダー・Evidenceファイル作成
- Registry／Office Security設定変更
- アドイン設定変更
- OneDrive／ネットワーク設定変更
- 権限昇格
- ソフトウェア・調査ツールの新規インストール
- Git操作
- Baseline変更
- S5-B Preflight実行
- S5-C以降への着手
- P2-05 Completion

PermissionDenied等が発生した場合は、権限を変更せずUNKNOWNとして報告する。

Read-only調査でも環境への変更を伴うことが判明した場合は、実行せず停止する。

### 11. 報告形式

```text
S5BP0Authorization:
  APPROVED_READ_ONLY

IsolationCandidate:
  EnvironmentType: SEPARATE_PC
  Existence: USER_ATTESTED
  Identification: VERIFIED / UNKNOWN

OS:
  Version: [value / UNKNOWN]
  Build: [value / UNKNOWN]
  Architecture: [value / UNKNOWN]

Excel:
  Installed: YES / NO / UNKNOWN
  Version: [value / UNKNOWN]
  Architecture: [value / UNKNOWN]
  VBEAvailability: SUPPORTED / UNKNOWN
  ExcelStarted: FALSE

ProductionIsolation:
  LocalProductionResources:
    NONE_IDENTIFIED / PRESENT / UNKNOWN
  OneDrive:
    REVIEWED / UNKNOWN
  NetworkShares:
    REVIEWED / UNKNOWN
  NetworkIsolation:
    VERIFIED / UNKNOWN
  Overall:
    VERIFIED / REVIEW_REQUIRED / NOT_SUITABLE

StartupEnvironment:
  XLSTART: REVIEWED / UNKNOWN
  ExcelAddins: REVIEWED / UNKNOWN
  COMAddins: REVIEWED / UNKNOWN
  StartupSafety:
    SUPPORTED_WITH_LIMITATION / REVIEW_REQUIRED

Storage:
  CandidatePath:
    C:\S5B_Preflight\
  PathApproved: FALSE
  Existence: EXISTING / ABSENT / UNKNOWN
  ACLReviewed: TRUE / FALSE
  Writable: NOT_TESTED
  SynchronizationRisk:
    REVIEWED / UNKNOWN

Evidence:
  CapturePlan: DEFINED
  RetentionProposal: 90_DAYS
  RetentionApproved: FALSE

Fixture:
  Specification: DEFINED
  Created: FALSE

S5BP0SuitabilityDecision:
  READY_FOR_USER_REVIEW /
  REVIEW_REQUIRED /
  NOT_SUITABLE

RemainingDecisions:
  [...]

PreflightExecutionAuthorization:
  NOT_GRANTED

ExcelStarted: FALSE
FixtureCreated: FALSE
CompileExecuted: FALSE
SettingsModified: FALSE
FilesCreatedOrModified: NONE
GitOperation: NONE

S5BTargetBuildCompile:
  NOT_VERIFIED

S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

### 12. 最終報告

次の4点を簡潔に報告する。

1. 別PCの識別・OS／Office情報
2. Production遮断について確認できた事実とUNKNOWN
3. Fixture・Evidence保存先・保持方針に関する未決定事項
4. 次回のユーザー判断と必要な最小承認範囲

確認結果を報告して停止する。

`READY_FOR_USER_REVIEW`の場合でも、Preflightを自動実行してはならない。
