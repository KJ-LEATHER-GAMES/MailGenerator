# S5-B 最小実行準備・検証用コピー受渡し設計 v0.1 — DRAFT

> **目的：** P2-05 S5-Bで現行Target BuildのVBA Compileを安全に実施するための、基準Build・検証用コピー・実行主体・個別承認境界を最小限に設計する。**本書は机上設計のみ。コピー作成、対象PC変更、Excel/VBE起動、Compileを許可しない。**

## 0. 決定記録・適用範囲

| 項目 | 状態・根拠 |
|---|---|
| 基準Build | **`E-P204-WB`をS5-Bの論理的基準Buildとして採用済み**（本チャットのユーザー明示判断） |
| Archive Set | `ARC-MG-P2-I12-20261018` |
| 基準バイナリ識別値 | `MailGeneratorNew.xlsm`／`1,003,775 bytes`／SHA-256 `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9`（既存Archive・S0記録由来） |
| 根拠の範囲 | Primary・Backup・復元のSHA照合PASSは**既存Evidenceの報告**。この文書は再測定していない |
| 後続変更 | 「2026-10-18のRegression後、Production VBA・Workbookに変更なし」は**USER_ATTESTED**。現在の物理バイト列は未測定 |
| 一般PC調査 | ユーザー判断により**限定付き終了（作業管理上）**。未確認事項は消さず、操作直前の必要条件へ移管 |
| 方式候補 | A（テストPC全体の通信制限）＋C1（専用ローカル標準ユーザー）。**採用の実行方式・隔離成立は未確定**。A＋C2（VM）は不成立時の代替検討のみ |
| 既存資産 | S1～S4の既存Closure、Approved仕様、Baseline、過去Evidence、Private Indexを不変保持 |
| 既存F1記録 | F1-READ-01=`COMPLETE_WITH_LIMITATIONS`、F1-2=`DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS`、F1-3～5は完全実施未了 |
| 既存AUTH状態 | **AUTH-01～AUTH-06：すべて`NOT_GRANTED`**。この文書の作成・レビューは承認の代替にならない |
| S5-B | `TARGET_BUILD_REFERENCE_SELECTED`／`PHYSICAL_COMPILE_FILE_NOT_FIXED`／`COMPILE_NOT_VERIFIED` |
| 本書のStatus | `DRAFT / DESIGN_ONLY`。プロジェクトRepositoryへの配置・承認・Commitなし |

**判断の分離：** `E-P204-WB`の採用は「どのバイナリ指紋を基準にするか」という論理的決定。実際にVBEで開く*検証用コピーの物理位置・現物SHA・アクセス主体・安全性*は別に確認する。既存ローカルClone（`RESOURCE-CLONE-A`）は採用しない。Cloneのハッシュ／同一性確認は今回不要であり、UNKNOWNのまま保持する。Repositoryルートの同名Workbookも対象にしない。

## 1. 保護対象と検証用コピーの分離

| 区分 | 許容する位置付け | 原則 |
|---|---|---|
| Archive基準資産 `E-P204-WB` | 参照元。Private Indexで特定された承認済みPrimary所在を**将来の限定操作時に**参照 | **上書き・リネーム・Excel Open・直接Compile禁止**。Backupは通常使用せず、必要なら別判断 |
| 外部開発原本／OneDrive配下 | 過去の一致確認対象。新規コピーの直接取得元には自動採用しない | OneDrive登録・同期稼働状況はUNKNOWNを維持。無断同期停止・移動禁止 |
| Repositoryルートの同名Workbook | 古い別バイナリ | Compile対象に自動選定しない |
| Local Clone（`RESOURCE-CLONE-A`） | 保護対象 | 内容のOpen・Copy・ACL変更・ハッシュ測定を今回の必要条件に含めない |
| 新しいS5-B検証用コピー | 基準資産からバイトコピーされた**作業専用ファイル**（将来の別承認後に作成） | 非同期ローカル領域。専用ユーザーはこの1件だけにアクセス可能とし、Archive元へアクセスさせない |
| Evidence | 実パス・SID等を含むPrivate記録と匿名化共有要約 | Public Repository／同期領域へ生Evidenceを自動送信しない |

**境界上の重要事項：** 「C1ユーザーからArchive／Cloneへアクセス禁止」と「C1ユーザーがCompile用コピーへアクセス可能」を両立させる。従って、実行主体にArchiveへの権限を与えて解決する方式は不採用。保全済み原本と検証用コピーを別の保管領域・ACLで扱う。

## 2. 検証用コピー受渡し手順案（すべて未実行）

**設計前提：** 作業用領域候補は`C:\S5B_Preflight\`。これは**候補パス**であり、存在・非同期性・ACL・リンク／再解析ポイント・権限状態はUNKNOWN。検証前にフォルダーを作成したり、既定安全状態とみなしたりしない。

| 順序 | 将来の手順と確認 | 必須Evidence／STOP条件 | 操作承認 |
|---|---|---|---|
| CP-0 | Private Indexにより`E-P204-WB`の正規Primaryを識別し、基準サイズとSHAを既存記録から確認。取得担当者・対象PCを特定 | LocatorはPrivateで保持。正本の識別が曖昧ならSTOP | 机上設計のみ。原本への新規アクセスは別承認 |
| CP-1 | 非同期ローカル作業領域と、その親フォルダーのアクセス境界を必要範囲で確認。対象ユーザー・保存先・コピー後取扱いを固定 | 保護対象と同一階層／同期対象／ネットワーク共有／意図しないリンクならSTOP | 環境確認・準備・作成は各々別承認 |
| CP-2 | 最小Evidenceの保存先・担当・時刻・ハッシュ・作業記録・異常時STOPを事前確定 | 環境変更より**前**にEvidenceを取得可能にする | AUTH-04相当の準備操作は別承認 |
| CP-3 | 将来の明示承認後、基準Primaryから**専用コピー1件だけ**を承認担当者が作成し、基準原本には書き込まない。C1ユーザーへの受渡しはコピー側の権限のみで実現 | コピー前の原本ハッシュ・サイズとコピー後のSHA・サイズが既存指紋に一致しなければSTOP。自動再コピー・原本変更なし | **COPY-PREP：独立した限定承認を新たに取得。AUTH-06のCompile承認と混同しない** |
| CP-4 | コピーのArtifact ID、元`E-P204-WB`、複製時刻、操作主体、検証対象PC、検証先Locator（Private）を対応付ける | 原本・コピー・実行ユーザーが一意にならなければSTOP | CP-3の承認範囲内で事前に列挙した記録のみ |
| CP-5 | 隔離成立・Office／VBE事前確認後、**指定したコピーだけ**をS5-B本番Compile候補に指定。Compile後の保存・破棄は別規定／別承認 | コピー不一致、予定外のマクロ／イベント／リンク、保存要求、権限要求、認証障害等でSTOP | **AUTH-06個別承認がさらに必要** |

**推奨順序：** Evidence計画・隔離環境の確立 → 無害FixtureによるOffice/VBE Preflight → コピー作成・ハッシュ照合 → コピーに対する本番Compile。これにより隔離の成立前にProductionコードを作業領域へ配布しない。

## 3. 最小安全Gate（既存AUTHへの対応）

| Gate | 合格判断に必要な最小要件 | 不成立時 | 現在状態 |
|---|---|---|---|
| G0：基準Build | ユーザーが`E-P204-WB`を論理基準に採用、歴史的SHA・サイズ・変更なし申告の証拠区分を維持 | 現行Artifactを推測で差替えない | **DECIDED（論理選定のみ）** |
| G1：Evidence準備 | F1-5最小設計。保存先、担当、Private/Public、時点、対象、ハッシュ、STOP記録を**最初の環境変更前に**用意 | Evidenceが残せなければ環境変更禁止 | **DESIGN_ONLY**／AUTH-04実操作未承認 |
| G2：隔離構築 | A＋C1を適用する場合、専用ローカル標準ユーザー、所属、コピーのみに付与するアクセス、PC全体の通信制限・復旧境界を確定。AUTH-02内でユーザー作成・通信変更を別々に承認 | 変更影響が過大ならA＋C2等を再評価（自動移行禁止） | **NOT_BUILT**／AUTH-02未承認 |
| G3：隔離の実効検証 | AUTH-03で実行主体を同定。既知で実在するProtected Resourcesへのアクセスを拒否（不存在／パス誤り／単なるエラーをPASS扱いしない）。承認済み作業領域のみ利用可能。ネットワーク制限実効も確認 | UNKNOWNや曖昧な否定試験ならSTOP | **NOT_VERIFIED**／AUTH-03未承認 |
| G4：Excel/VBE安全Preflight | F1-3/4の実行方式に必要な確認のみ。XLSTART／アドイン／イベント／リンク／接続リスクを対象ユーザーで評価。Officeライセンス等を確認し、無害FixtureでCompile可否を別承認・検証。マクロ警戒設定等の緩和禁止 | Excelを安全に開けない、FixtureがCompile不可なら本番対象は開かない | **NOT_VERIFIED**／AUTH-05未承認 |
| G5：コピーの現物固定 | CP-0～CP-4。Private Indexで識別、承認担当者がコピー作成。元とコピーのSHA-256・サイズ一致、コピーのLocatorとアクセス範囲を固定 | 不一致／対象不明／同期可能性ならSTOP | **NOT_PREPARED**／COPY-PREP未承認 |
| G6：本番Compile | AUTH-06で`G5`のコピーと対象PC・ユーザーを固定し、Excel/VBE起動時のガードを維持。実行日時、結果（PASS／FAIL／BLOCKED）、エラー、予期しない変更をEvidence化 | 対象ズレ／警告／保存要求等はSTOP。Fixture PASSをProduction PASSに転用しない | **NOT_EXECUTED**／AUTH-06未承認 |

### AUTHの依存関係（設計案）

```text
ユーザー決定：基準 E-P204-WB 採用／PC一般調査 限定付き終了  [記録済み]
      ↓
F1-3/4/5の「採用方式に必要な部分」のみ机上で確定
      ↓
AUTH-04-A：Evidenceの設計合意（DESIGN_ONLY、操作許可ではない）
      ↓
AUTH-04-B：必要なEvidence領域の準備が発生する場合は、最初の変更前に別承認
      ↓
A＋C1採否の明示決定 → [必要時AUTH-01]
      ↓
AUTH-02：ユーザー／アクセス境界設定・ネットワーク制限を各々別承認
      ↓
AUTH-04のEvidence準備を実行時再確認 → AUTH-03：隔離境界の実測
      ↓
AUTH-05：無害Fixtureの作成と安全Preflight（分割承認）
      ↓
COPY-PREP：基準Artifactから専用コピー作成・照合（独立承認）
      ↓
AUTH-06：検証用コピーに対する現行S5-B Compile（独立承認）
      ↓
S5-C／S5-D／S5-E（別Gate）、P2 Exit／CP-P2（別Gate）
```

`COPY-PREP`はこの設計で付けた**提案上の承認単位名**であり、旧AUTH正本の既存IDとして主張しない。必要なら後続の正式計画のAUTH内に「コピーのみ」の個別承認を明示して収める。AUTH-01～06に現時点で付与された権限は**ゼロ**。

### Excel起動の重要な制約

- `AutomationSecurity=ForceDisable`、`EnableEvents=False`、`Workbooks.Open(ReadOnly:=True, UpdateLinks:=0, ...)`等の単一設定だけで、起動時の全マクロ・XLM・外部動作が安全化されたとは主張しない。
- Excelの実際の安全起動手順は、使用する専用ユーザー・インストール済みOffice・Workbookの性質に対して**事前に評価**する。未確認なら本番Workbookを開かない。
- Trust Center／Trusted Locations／VBOM保護・セキュリティ設定の緩和は一切この設計では承認しない。Office認証やネットワークとの両立に問題があれば停止。
- `Compile VBAProject`は「コードを編集しない意図」であっても、Workbook自体が自動保存されないことを保証しない。保全原本は絶対に開かず、作業用コピーのみを対象にする。

## 4. 机上設計の終了条件と保留事項

**机上設計で成立したこと**：基準Artifactの採用、原本／検証用コピーの役割分離、コピーの取得元優先順位、独立したCOPY-PREP承認、AUTH-04の事前Evidence条件、AUTH-03の負試験判定、Fixtureと本番Compileの分離、停止条件を明示。

**本番実行前にのみ必要な限定確認（現時点では実施しない）**：

1. Private Index内の`E-P204-WB`正規Primaryと、コピー担当者のアクセス可否・コピー先候補の非同期性と親ACLの限定確認。
2. A＋C1方式の実行可能性・明示採否。C1アカウント作成、ネットワーク制限、アクセス境界検証は個別AUTHが必要。
3. 専用ユーザーでOffice/VBEを安全利用できること、起動追加物とマクロ等の制御が成立すること、Fixture検証。
4. 承認されたCOPY-PREPの実施後に、指定コピーのSHA・サイズ・所在・実行主体を固定。

**今回意図的に実施しないこと**：Clone／全PC ACL調査、OneDrive登録状態の追加調査、Archive元の書換え、実Workbook確認やコピー、PCアカウント／ACL／通信の変更、Excel・VBE・Outlook起動、Fixture作成、Compile、レジストリ照会、Git操作、Approved仕様／Baseline改訂、Evidence変更。

## 5. 状態サマリー

```yaml
ReferenceBuild:
  ArtifactID: E-P204-WB
  ArchiveSet: ARC-MG-P2-I12-20261018
  Selection: USER_APPROVED_LOGICAL_REFERENCE
  SHA256: 0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9
  SizeBytes: 1003775
  HistoricalArchiveHashVerification: REPORTED_PASS
  ProductionAndWorkbookChangesSince20261018: USER_ATTESTED_NONE
  CurrentPhysicalCompileCopy: NOT_PREPARED
GeneralPCInvestigation:
  Status: CLOSED_WITH_LIMITATIONS_BY_USER_DECISION
  ResidualUnknowns: MAINTAIN
Isolation:
  Candidate: A_PLUS_C1
  MethodFormallySelected: FALSE
  Implemented: FALSE
  Verified: FALSE
Authorization:
  AUTH_01: NOT_GRANTED
  AUTH_02: NOT_GRANTED
  AUTH_03: NOT_GRANTED
  AUTH_04: NOT_GRANTED
  AUTH_05: NOT_GRANTED
  AUTH_06: NOT_GRANTED
  COPY_PREP: NOT_GRANTED_PROPOSED_ONLY
S5B:
  FixturePreflight: NOT_EXECUTED
  ProductionCompile: NOT_EXECUTED
  Result: NOT_VERIFIED
Mutations:
  ProductionOriginal: NONE
  ArchiveAndHistoricalEvidence: NONE
  ApprovedSpecificationAndBaseline: NONE
  RepositoryAndGit: NONE
  TargetPCAndWorkbook: NONE
```

## まとめ / Summary

**日本語：** `E-P204-WB`を基準Buildとして採用し、PC一般調査を限定付き終了とした。保全原本を変更せず、隔離成立・Fixture確認後に専用コピーを独立承認で作り、別承認でCompileする。現時点の全AUTHは未承認であり、S5-Bは未実行・未検証。

**English:** `E-P204-WB` is the selected reference build. General PC investigation is closed with limits. The archived original stays unchanged. A test copy will need separate approval after isolation and fixture checks. Compile also needs separate approval. No execution is approved yet.
