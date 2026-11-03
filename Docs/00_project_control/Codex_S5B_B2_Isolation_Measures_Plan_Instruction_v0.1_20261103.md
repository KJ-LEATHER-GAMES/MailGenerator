# S5-B B-2 Isolation Measures Plan v0.1

## 既存別PC再利用に向けた隔離措置計画整理

### 1. 目的

S5-B Preflight環境として`S5B-TestPC-01`を再利用するB案について、隔離措置の最小実施計画を確定する。

今回の重要な追加事実：

```text
ProductionOriginalLocation:
  OTHER_PC
  Evidence: USER_ATTESTED

IsolationCandidate:
  S5B-TestPC-01

ReuseStrategy:
  OPTION_B_SELECTED
```

Production原本が別PCに存在することは確認者申告であり、検証PCからProduction資源へのアクセスが遮断されていることの証明ではない。

**今回の作業は計画整理のみとする。環境変更、Excel終了、同期停止、ファイル操作、Preflight実行は許可しない。**

### 2. 維持する状態

```text
S1-S4: CLOSED / PASS
S5-A: Evidence Reuse Accepted With Limitations
S5-B: REVIEW_REQUIRED

P05-I01-I17:
  DOCUMENTED_PASS_WITH_LIMITATION

P05-K01-K04:
  DOCUMENTED_PASS_WITH_LIMITATION

S5BPreflightAuthorization:
  NOT_GRANTED

S5BTargetBuildCompile:
  NOT_VERIFIED
```

既存のClosure、BL-MVP-003履歴、BL-MVP-004 Repository受入、Finding／Observation、残留UNKNOWNを維持する。

### 3. B2-01 既存Excel／VBEの終了計画

既存のContract Regression Testについて、以下のユーザー申告を前提とする。

- Test：COMPLETED
- Unsaved Work：NONE_USER_ATTESTED
- Uncollected Evidence：NONE_USER_ATTESTED
- Termination Decision Authority：USER
- Can Close：YES_USER_ATTESTED

提案する終了条件：

1. ユーザーが終了を明示承認する。
2. 対象Excel／VBEセッションを一意に特定する。
3. 保存が不要であることをユーザーが最終確認する。
4. 承認された方法で通常終了する。
5. 終了後、対象プロセスの不存在を確認する。

強制終了、自動保存、全Excelプロセスの一括終了を計画に含めない。

今回は終了操作を行わない。

### 4. B2-02 Production資源・接続経路

次の接続を個別に整理する。

**OneDrive**

- PC間共有に使用中。
- 検証用Workbookが存在する。
- Production原本との版関係はユーザー申告。
- 現在の同期状態はUNKNOWN。

確認事項：

- 検証PC上の同期対象の範囲
- Production資源に関係する既存コピーの有無
- 同期停止後も残るローカルファイル
- 別PCとの共有・同期経路
- Preflightで利用するWindowsユーザーからのアクセス可能性

同期停止だけを隔離PASSとしない。

**Google Drive**

- G:表示あり。
- 使用していないとのユーザー申告あり。
- 接続・同期実状態はUNKNOWN。

確認事項：

- クライアントの稼働状態
- G:の接続形態
- Production関連データとの関係

使用申告だけで非接続・非同期とは認定しない。

**その他**

- GitHubアクセス・Cloneの有無
- ネットワーク共有
- VPN
- USB・外部ストレージ
- Production関連の既存ローカルファイル
- その他の共有・同期経路

本番ファイルの内容確認や、共有への到達性テストを自動追加しない。

### 5. B2-03 隔離方式の選定

原本が別PCにあることを前提に、必要最小限の隔離方式を提案する。

候補：

A. 検証用PCのネットワーク接続を制限する方式

B. OneDrive／Google Drive等の同期・接続経路を個別に停止する方式

C. 検証用PC内で、Production資源にアクセスできない別の隔離実行領域を使用する方式

各方式について次を比較する。

- Productionネットワーク経路の遮断範囲
- 既存ローカル複製の扱い
- 本番PCへの影響
- 再接続・復元条件
- 通常権限で実施できるか
- 設定変更の必要性
- 残留リスク
- 明示承認が必要な操作

単なる別プロセス、別ディレクトリ、同期停止だけでProduction資源へのアクセス不可を証明したと扱わない。

既存ローカル複製を削除・移動せずに隔離要件を満たせない場合は、別方式の検討を報告し、停止条件とする。

特定方式を自動採用しない。

### 6. B2-04 Excel起動追加物

既存情報：

```text
Known XLSTART Direct Items:
  0

AlternateStartupFolder:
  UNKNOWN

ExcelAddins:
  UNKNOWN

COMAddins:
  UNKNOWN
```

確認不能な起動追加物を無断で無効化しない。

安全なExcel起動方法を確定するため、追加の確認方法と、必要な設定変更を別々に提示する。

未確認の場合はStartupSafetyをPASSにしない。

### 7. B2-05 検証領域・Evidence管理

候補：

```text
C:\S5B_Preflight\
  fixture\
  evidence\
  logs\
```

正式採用前に次を確認する計画とする。

- ローカル領域であること
- OneDrive／Google Drive等の同期対象外であること
- Production領域ではないこと
- 既存物との衝突がないこと
- 通常権限での利用可能性
- ACLと実効アクセス範囲
- 必要容量
- 隔離後のEvidence保全方法

今回はディレクトリ作成・書込み試験を行わない。

保持方針案：

```text
Retention:
  90 days after verification

Unresolved Evidence:
  RETAIN_PENDING_DECISION

Automatic Deletion:
  NONE

Responsible Authority:
  USER
```

90日保持は未承認の提案として維持する。

ネットワーク遮断が必要な場合、Evidenceをホストやクラウドへ自動転送しない。受渡し方法は別途判断する。

### 8. B2-06 隔離成立の検証条件

将来の隔離措置実施後に、以下を確認する計画とする。

```text
Production Original:
  On Other PC / USER_ATTESTED

Existing Excel Session:
  CLOSED_AND_VERIFIED

Production Network Paths:
  BLOCKED_OR_INACCESSIBLE

Production Local Copies:
  ACCESS_CONTROL_VERIFIED

OneDrive / Google Drive:
  RELEVANT_SYNC_AND_ACCESS_PATHS_CONTROLLED

Startup Additions:
  REVIEWED_AND_CONTROLLED

Fixture Storage:
  APPROVED_LOCAL_NON_SYNC_PATH

Evidence Policy:
  APPROVED

Unexpected Changes:
  NONE
```

未確認項目をPASSへ補完しない。

全条件を満たせない場合、隔離環境採用を保留する。

必要な隔離措置の実行後も、Preflightには別途明示承認を必要とする。

### 9. 禁止事項

- Excel／Workbook／VBE終了
- OneDrive／Google Drive停止・設定変更
- ネットワーク・VPN・Firewall変更
- ファイル移動、コピー、削除
- Fixture作成
- ディレクトリ作成・書込み試験
- アドイン設定変更
- 権限昇格
- VBA Compile
- Preflight実行
- Git操作
- Baseline変更
- S5-C以降着手
- P2-05 Completion

今回は新規管理文書を作成せず、回答内で計画を報告する。

### 10. 報告形式

```text
S5BReuseStrategy:
  OPTION_B_SELECTED

ProductionOriginal:
  Location: OTHER_PC
  Evidence: USER_ATTESTED

IsolationCandidate:
  S5B-TestPC-01

B2Plan:
  ExistingExcelClosure: PLANNED_NOT_AUTHORIZED
  ProductionPathControl: PLANNED_NOT_AUTHORIZED
  StartupControl: REVIEW_REQUIRED
  StorageApproval: PENDING
  RetentionApproval: PENDING

IsolationMethodOptions:
  [options and tradeoffs]

RequiredActions:
  [minimal ordered actions]

SeparateAuthorizationRequired:
  [specific operations]

B2PlanDecision:
  READY_FOR_USER_REVIEW /
  REVIEW_REQUIRED /
  BLOCKED

IsolationEstablished:
  NOT_VERIFIED

EnvironmentMutation: NONE
WorkbookMutation: NONE
PreflightExecuted: FALSE
S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

B2計画を報告して停止する。

隔離措置の実行やPreflightへ自動的に移行しない。
