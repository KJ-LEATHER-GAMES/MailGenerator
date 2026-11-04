# S5-B B2-02-F1 A＋C1実装可能性の事前確認計画整理結果

**B2-02-F1の確認計画をREADY_FOR_USER_REVIEWとして確定します。総合判定はC1_REVIEW_REQUIREDです。** A＋C1の実装可能性は未確認であり、今回の計画確定を実機調査・方式選定・隔離成立とは扱いません。

将来の実行主体は、**Production用認証情報を引き継がない専用Windows標準ユーザー**を候補とします。実在、所属グループ、実効権限、Excel利用条件はいずれも未確認です。

将来のF1-READでは、対象・GUI画面・方法・権限・出力項目を事前に限定します。既存表示とユーザー申告を優先し、前回拒否・タイムアウトとなった操作の再試行、追加ツール、昇格、到達性試験は含めません。結果は「確認時点・対象・実行主体・方法・情報源・観測値・UNKNOWN理由」に分けて回答内に記録し、実パスや識別情報は抽象名に置き換えます。

| Gate | 最小確認項目 | 根拠取得方法と確認の限界 | STOP条件 |
| --- | --- | --- | --- |
| **F1-1：ローカル境界** | Clone、検証Workbook、OneDrive関連資源、既知Evidenceコピーの配置関係。ACL・継承・グループ権限・共有や別名経路。既存資源を変更しない境界の構成可否 | ユーザーが把握済みの配置情報と、承認された既存GUIの場所・セキュリティ情報を照合する。WorkbookのOneDrive版とClone版は別対象として記録し、同一実体と推定しない。親ACLだけで個別ファイルや別経路まで判定しない | 重要な対象が不明、確認に内容Openが必要、既存資源の移動・削除・ACL変更が不可避 |
| **F1-2：専用ユーザーとExcel** | 専用標準ユーザーの有無、必要権限・所属グループ、認証情報分離、共有資源、Excel／VBEへのアクセスと利用・認証条件、初回設定の要否 | 既存アカウント情報の表示、既存インストールEvidence、ユーザーの保有ライセンス情報を分けて整理する。新規ユーザーがなければ、想定グループと実際のトークンを区別する。作成・サインイン・Office起動・認証は行わない | 権限・認証・利用条件が重要なUNKNOWNのまま、確認のため未承認の初回サインインや外部認証が必要 |
| **F1-3：起動追加物** | 専用ユーザーとマシン全体のXLSTART、代替起動フォルダー、Excel／COM Add-ins、関連サービス、初回プロファイル初期化、既存セッションとの独立性 | 既存Evidenceと承認された静的設定表示を使用する。既知XLSTART直下0件を、未作成の専用プロファイルへ適用しない。PID 6252は過去情報として保持し、現在状態と分ける | 未確認の追加物を安全と扱う必要がある、確認にExcel操作・設定変更・未承認の初回起動が必要 |
| **F1-4：ネットワークとオフライン運用** | PC全体とユーザー単位の経路、制限対象・例外、Codex依存、オフラインでの安全制御・読戻し・Compile・記録方法、再接続条件 | 既存の接続・同期表示とユーザー申告を整理する。設定内容、実際の遮断状態、ローカルアクセスを別評価する。通信不能時にユーザーが実施する手順・判定・記録方法を設計する | 重要な経路が不明、安全制御や読戻し・観測・Evidence保全を継続できない、未承認の接続再開が必要 |
| **F1-5：保存先とEvidence** | 非同期・非共有・Production領域外であること、専用ユーザーと他ユーザー・サービスの権限、衝突、容量、保全・受渡し | 候補と既存の親領域について、承認された非変更確認を行う。書込みは静的な見込みと実測を区別し、実測はAUTH-04へ分離する | 未承認の作成・書込み・転送が必要、保全方法が未確定、既存物への変更が必要 |

Office 2019のサポート終了に伴う保守・更新面のリスクは残留リスクとして記録します。**これは専用ユーザーでの実行・認証・利用可否とは別評価**であり、既存インストールがあることだけで利用可能とは認定しません。

最初のF1-READで必要な追加確認は、次の六点に限定します。

1. 既知Production関連資源の配置・同期範囲と、ACL・継承・共有経路。
2. 専用標準ユーザーの有無、想定グループ、構築に必要な権限。
3. 専用ユーザーでのExcel／VBE・Office認証に必要な条件。
4. 専用ユーザーとマシン全体に適用される起動追加物。
5. PC全体の接続制限範囲と、Codexなしでの操作・読戻し・観測方法。
6. 保存先候補、必要容量、Evidence保全・受渡しの成立条件。

確認のため別の操作が必要になれば、その項目をUNKNOWNとして止め、対象と方法を改めて承認対象にします。

C1の判定条件は以下に固定します。

| 判定 | 必要な根拠 |
| --- | --- |
| **C1_FEASIBLE_WITH_PRECONDITIONS** | 必要な対象が整理され、既存Production資源を変更せず境界を構成する見込みがあり、専用標準ユーザー・Excel・起動制御・オフライン運用・保全の必要条件と承認対象が明確 |
| **C1_REVIEW_REQUIRED** | 対象、ACL、実行主体、認証、起動追加物、経路、手動運用等に重要なUNKNOWNが残る |
| **C1_NOT_FEASIBLE_UNDER_CONSTRAINTS** | 制約を守る構成では必要な境界を作れないことが確認された。例えば既存資源の変更が不可避で、許容される代替構成がない場合 |

現在のユーザーがCloneへアクセスできること、新規ユーザーが未作成であること、Office利用条件が未確認であることだけでは、C1を不可能とは判定しません。また、静的確認で見込みが得られても、**実効アクセス遮断はAUTH-03までNOT_VERIFIED**です。

C1が制約下で不成立と確認された場合は、A＋C2等の代替方式レビューへ戻します。重要なUNKNOWNを安全に解消できない場合もC1の実施を保留しますが、不成立とは区別します。代替レビューへの移行はC2の採用・構築承認ではありません。特に、オフラインで操作・保全を継続できない問題はA＋C2にも残り得るため、切替えだけで解消したとは扱いません。

将来の承認境界は次のとおりです。**今回、すべて未承認です。**

| 承認区分 | 含める範囲・境界 |
| --- | --- |
| **F1-READ** | 限定された非変更確認と報告のみ。作成・切替・初回サインイン・Excel操作・設定変更を含めない |
| **AUTH-01** | 対象セッションを改めて特定し通常終了。保存要求時STOP、対象PID不存在を確認。過去PIDをそのまま操作対象にしない |
| **AUTH-02** | 専用ユーザー作成、初回サインイン・初期設定、必要な新規領域のアクセス制御、接続制限を操作別に承認。認証・追加ツール・管理権限使用も明示する。既存Production資源の変更は含めない |
| **AUTH-04** | 保存先採用・作成・書込み確認、保持起算点、保全・受渡し・復元時の扱い。Evidenceを伴うAUTH-03より先に成立させる |
| **AUTH-03** | 構築後の実行主体・権限・経路・実効アクセス境界を確認。無害な観測資材や限定検査が必要なら作成・実行を個別承認。Production内容のOpenは含めない |
| **AUTH-05** | SafeCompileFixture、Excel独立起動、安全制御と読戻し、Compile、Evidence取得 |
| **AUTH-06** | Preflightレビュー後の、対象Workbookを限定したS5-B最終Compile再試行 |

ネットワーク遮断前に、対応する承認の下でオフラインの操作・観測・保全方法を確定します。安全制御の読戻しができない場合は進みません。誤って接続・同期が再開した場合は検証を停止し、発生状況を記録します。再接続、同期再開、再遮断等の対処、復元を自動実施しません。

保存先候補は引き続き次の構成です。

```
C:\S5B_Preflight\
  fixture\
  evidence\
  logs\
```

保持案は検証後90日、未解決EvidenceはRETAIN_PENDING_DECISION、自動削除NONE、責任者USERとして維持します。起算点・保全・受渡し・復元時の扱いは未承認です。

```
S5BReuseStrategy: OPTION_B_SELECTED

B201Decision: COMPLETE_WITH_LIMITATIONS
B202Decision: REVIEW_REQUIRED

B202F1:
  Scope: DESIGN_ONLY
  PlanStatus: READY_FOR_USER_REVIEW

  LocalBoundary:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  DedicatedUserAndExcel:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  StartupControl:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  OfflineOperation:
    PlanDefined: TRUE
    ActualFeasibility: UNKNOWN

  StorageAndEvidence:
    PlanDefined: TRUE
    StorageApproved: FALSE
    RetentionApproved: FALSE

  FutureReadOnlyVerification:
    Authorization: NOT_GRANTED

  Assessment: C1_REVIEW_REQUIRED

RecommendedOption: A_PLUS_C1_CONDITIONAL_CANDIDATE
AlternativeOption: A_PLUS_C2_REVIEW_CANDIDATE

IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED

RequiredAdditionalEvidence:
  - KnownResourceLocationAndAccessBoundary
  - DedicatedUserAvailabilityAndPrivileges
  - ExcelAndVBEAvailabilityForDedicatedUser
  - StartupAdditions
  - NetworkRestrictionAndOfflineOperation
  - StorageAndEvidenceFeasibility

ExecutionAuthorization: NOT_GRANTED
EnvironmentMutation: NONE
WorkbookMutation: NONE
FilesCreatedOrModified: NONE
GitOperation: NONE

ExcelClosedByTask: FALSE
FixtureCreated: FALSE
VBACompileExecuted: FALSE
PreflightExecuted: FALSE

S5BTargetBuildCompile: NOT_VERIFIED
S5CStarted: FALSE
P2_05CompletionRecorded: FALSE
CP_P2Established: FALSE
```

既存Closure、S5-A限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴、残留UNKNOWNを維持し、ここで停止します。
