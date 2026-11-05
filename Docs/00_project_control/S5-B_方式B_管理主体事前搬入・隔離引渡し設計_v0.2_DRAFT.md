# S5-B 方式B：管理主体による事前搬入・隔離引渡し設計 v0.2 — DRAFT

- 作成日：2026-11-03（JST）
- プロジェクト：定型メール作成ツール／P2-05 S5-B Current VBA Compile
- 文書区分：机上設計／承認前ドラフト
- 保存状態：ChatGPT作業領域にのみ生成。Project Repositoryへの登録・Commitなし
- 本書の選択：**方式B（管理主体による事前搬入）を優先して設計**。A＋C1隔離方式の正式採否、搬入実施、フォルダー作成、ACL・通信変更、Excel/VBE起動、Fixture、Compile等の実行承認ではない
- 既存文書：`S5-B_最小実行準備・検証用コピー受渡し設計_v0.1_DRAFT.md`、`B2-02-F1_隔離設計計画・承認ゲート定義_v0.1_DRAFT.md`を参照。両者を改訂せず、本書は方式Bの局所詳細設計として扱う

## 1. 判断・証拠の現状

| ID | 内容 | 状態・確度 |
|---|---|---|
| 基準Artifact | `E-P204-WB`／`ARC-MG-P2-I12-20261018` | **ユーザーが論理基準Buildとして採用済み** |
| 既存指紋 | `MailGeneratorNew.xlsm`、1,003,775 bytes、SHA-256 `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` | 既存保全記録の値。今回再測定なし |
| 既存保全 | Primary／Backup／復元SHA一致 | 過去のEvidence記録上PASS。現行受渡し経路のPASSではない |
| 後続変更 | 2026-10-18以降のProduction VBAおよびWorkbook変更なし | `USER_ATTESTED_NO_CHANGE`、物理的な現在のファイル検証ではない |
| 一般PC調査 | 限定付き終了 | ユーザーの作業管理上の判断。個別安全Gateの実測は残す |
| STEP A | `ArchiveTransferRoute: UNKNOWN` | 既存Primaryと検証PCとの受渡し経路未確定 |
| STEP B | `WorkspaceCandidate: NOT_FOUND` | `C:\S5B_Preflight\`候補は存在しないとのユーザー報告 |
| STEP C | Wi-Fi接続済み | `NetworkIsolationMethod: REVIEW_REQUIRED`。オフライン実効性未証明 |
| 既存Clone | `RESOURCE-CLONE-A` | **非採用**。同一性UNKNOWNは維持し、追加調査しない |
| 方式選定 | Bの優先設計 | **A＋C1の正式選定ではない** |
| S5-B Compile | 実行なし | `NOT_VERIFIED` |

`AUTH-04-PRECHECK-01`はユーザー手動の限定Read-only確認のみ承認・報告済み。親の`AUTH-04`によるEvidence領域準備、`AUTH-02/03/05/06`および提案上の`COPY-PREP`は承認されていない。 `AUTH-01`は必要な場合に限る。

## 2. 方式Bの構造：二段階での搬入・実行用引渡し

```text
[保全済み E-P204-WB 正規 Primary]
  （Private Indexで識別。原本はOpen・上書きしない）
               |
               | B-TRANSFER-01：別承認、管理主体による読取り専用取得と輸送
               v
[検証PC上の管理側ステージング領域]  ← ネットワーク等の制限実施前でも
  （ローカル・非同期・非共有、管理側だけアクセス）      Excel/Workbookは絶対に開かない
               |
               | A：検証PC全体をオフライン化＋検証
               | C1：専用標準ユーザーのアクセス境界を実測
               | SafeCompileFixture：安全性を事前検証
               v
  B-HANDOFF-01：別承認、ステージング側から実行用コピーへ受渡し
               |
               v
[専用標準ユーザーが利用する実行用コピー]
  （非同期作業領域、SHA一致、対象PC・実行主体・日時を固定）
               |
               | AUTH-06：さらに別の実行承認
               v
          [S5-B VBA Compile]
```

**役割分離**

| 役割 | 想定主体 | 権限・責務 |
|---|---|---|
| Archive管理主体 | 正本アクセスを既に認可された管理者／所有者 | Private IndexでPrimary確認。保全原本は読取りのみ。Backupを自動選定しない |
| 搬入主体 | ユーザーが後続承認で指定する管理側の操作主体 | 輸送経路の確定、ステージングへのコピー、SHA照合、記録。C1専用ユーザーにArchive権限を渡さない |
| 環境構築／検証主体 | 個別AUTHで指定する主体 | ローカル領域・ACL・専用標準ユーザー・通信制限・Evidence準備の実施／検証。管理主体と同一でも承認単位は分離 |
| S5-B Compile主体 | 後続承認で固定するC1専用標準ユーザー | 許可された実行用コピーのみ使用。Archive／ステージング／保護対象へのアクセスなし |

同一の実人が管理側と検証側を担当する場合も、**操作アカウント／権限／作業ログを区別**する。一般の管理者アカウントを非昇格で使っただけではC1標準ユーザーとしない。

## 3. 受渡し経路の選定ルール（現時点では未決定）

- **B-L：管理側から検証PCへローカルに搬入できる場合**。実在する正規Primaryの参照・ステージング領域が同じPCにあること等が既存記録や後続の限定確認で確定した場合のみ採用。現在は`UNKNOWN`。
- **B-M：別PC・別媒体から搬入する場合**。既存の認可済み物理媒体・転送経路が必要。使用媒体・受渡し担当・原本保護・媒体上の一時コピーの扱いを個別承認で固定する。**S1用Backup媒体を自動的に搬送用とみなさない**。
- ネットワークやクラウド経由取得はB方式の既定経路にしない。追加接続・同期・ダウンロードを無断で行わず、不可避なら経路・転送先・漏えいリスク・必要な操作について別判断する。
- Private Indexの実Locatorが分からない状態で、パスの類推や広域探索をしない。搬入できる経路が確定しなければ `TRANSFER_ROUTE_UNRESOLVED / STOP`。

## 4. 提案する領域・アクセス境界（**すべて未作成**）

| 論理領域 | 目的 | 必須条件 |
|---|---|---|
| 管理側ステージング `STAGE` | 搬入後、正式な実行用コピーを渡すまでの一時保管 | 検証PC上・ローカル非同期・非共有。専用標準ユーザーから読取不可。管理側主体のみアクセス |
| 実行用領域 `WORK` | AUTH-06対象コピーの保管 | 検証PC上・ローカル非同期・非共有。C1専用標準ユーザーに必要最小限の権限。Archive／Clone／STAGEへのアクセス不可 |
| Evidence領域 `EVIDENCE` | 受渡し、ハッシュ、隔離、Fixture、Compile、STOP記録 | 最初の環境変更より前に設計・利用可能にする。Private情報と匿名化共有を分離し、保持期間・担当を承認 |

`C:\S5B_Preflight\`は過去の候補名だが`NOT_FOUND`。`STAGE/WORK/EVIDENCE`の名前と配置は**論理名称**であり、勝手に`C:\`下へ新規フォルダーを作る指定ではない。実際の候補は、同期・共有・リパースポイント・親ACLの問題がないと確認し、作成対象を明記して個別承認する。

**禁止する安易な解決策：** Production原本・Archive／CloneのACLを変更する、C1へArchiveアクセスを与える、同名の古いRepository Workbookを使用する、既存同期フォルダーを実行場所にする、境界未確認のままTrusted Locationを追加する。

## 5. 実施順序と各Gate（すべて将来・個別承認）

| フェーズ | 最小作業 | 成立確認・必要Evidence | 承認境界 |
|---|---|---|---|
| B0：設計確定 | B-L/B-Mどちらの経路か、管理主体、実際の保管・輸送経路、検証PC、候補STAGE/WORK/EVIDENCE、保存期間を決める | `TRANSFER_ROUTE_DEFINED`／対象・実行主体・復旧方針の一意性。未知ならSTOP | **机上判断のみ**、本書作成は操作承認でない |
| B1：Evidence準備 | 作業前記録方式、保存領域、Private/Public、異常時記録を確定。必要な作成は限定実施 | 最初の変更より先に、変更開始を記録できる承認済みの既存手段があること。新規Evidence領域の作成自体も操作・時点・対象・結果を記録 | `AUTH-04`の準備操作は別承認 |
| B2：構築用領域の準備 | 非同期性・共有・親ACLを評価し、STAGE/WORK/EVIDENCE必要分のみ用意 | 変更前後の状態、所有者／権限、作成対象、STOP／戻し方 | 環境変更の独立承認（AUTH-02等との関係を明示） |
| B3：管理主体による事前搬入 | 正規Primaryから承認経路でSTAGEへ搬入。Excelは開かない | PrimaryのサイズとSHAを搬入時点で照合、STAGE側も一致。輸送媒体・中継コピーの存在・処置を記録 | `COPY-PREP`内の`B-TRANSFER-01`として独立承認。経路未定なら承認依頼しない |
| B4：隔離構築 | C1ローカル標準ユーザー作成・グループ／権限境界。A方式のPC全体通信制限を実行前に適用 | 各設定の前後・復帰／異常時停止。アカウント作成と通信制限は分割承認 | `AUTH-02`、必要な場合だけ`AUTH-01` |
| B5：隔離実効検証 | C1の実行主体・保護対象拒否・WORK可否・STAGE不可・全接続経路制限を確認 | 実在する資源への予期された拒否と、正のアクセス結果を区別。存在しないパスはPASSにしない | `AUTH-03`、AUTH-04 Evidence準備済みが前提 |
| B6：無害Fixture Preflight | 専用ユーザーでExcel/VBEの起動・Compile安全性を限定検証 | Office利用可、XLSTART・アドイン・イベント・リンク・マクロ等安全境界、Fixture結果・例外・STOP | `AUTH-05`。Fixture作成と起動/Compileは分割承認 |
| B7：実行用引渡し | STAGE内の一致確認済みコピーからWORKへ実行用コピーを作り、再SHA・サイズ照合、実行主体を固定 | `SourceArtifact=E-P204-WB`、STAGE/WORKのハッシュ、C1のアクセス、Private Locator、日時。変更・保存を想定し別バイナリとして管理 | `COPY-PREP`内の`B-HANDOFF-01`として独立承認 |
| B8：S5-B Compile | AUTH-06で特定WORKコピーだけを安全条件下でVBA Compile。結果を記録 | PASS/FAIL/BLOCKED、対象・時刻・実行ユーザー・保存状態・異常 | `AUTH-06`別承認。未許可ならSTOP |
| B9：後処理 | STAGE・WORK・中継媒体の保持または廃棄を判断。原本・Evidenceは不変 | 保持期間・証跡・削除対象・承認・残存情報リスク | **自動消去せず、別途範囲を定めて承認** |

**順序の要点：** 管理主体による事前搬入はB4/B5の前になり得るが、`STAGE`はC1に見せず、オンライン時でも同期・共有・予期しない実行がないことをB2で確認する。安全Fixtureが通るまでは`WORK`へ本番Workbookを引き渡さない。安全な`STAGE`を設けられないならB3を行わない。

## 6. A（通信制限）とC1（実行主体）の成立条件

**A：** 過去のSTEP CでWi-Fi接続を確認したにとどまる。Wi-Fiだけの切断で全経路遮断と断言できない。追加の既知経路、復旧操作、オフライン中のOffice認証・Evidence採取可否を、B4実行承認の前に限定設計する。遠隔支援が必要ならオフライン中の支援喪失も考慮する。切断・通信設定変更は本書では未承認。

**C1：** Windows 11 Homeで専用ローカル標準ユーザーを新規使用する案。Office 2019がそのユーザーで利用可能か、ライセンス・安全起動が成立するかは未検証。STAGE・Archive・Cloneへの実効アクセス拒否とWORKへの必要なアクセスをB5で確認する。既存のAdmin非昇格セッションによる閲覧結果は代用できない。Protected対象そのものを開く必要がある検証は実施しない。

**不成立時：** Office認証、同期隔離、ACL、通信遮断、実行用コピーの一致いずれかが必須条件を満たせなければ、設定を無断緩和せず`BLOCKED`。A＋C2のような代替を別途判断する。`S5-B Compile = NOT_VERIFIED`を維持。

## 7. STOP条件・禁止事項

- Primary／Archive／Private Indexを無断で参照・コピー・編集、Backupを代わりに使用、Cloneを新規調査する。
- 実行主体・検証PC・移送経路・作業場所・原本SHAが曖昧なまま搬入する。
- STAGE/WORK/EVIDENCEが同期・共有・リパース先・親ACLについて未確認であるのに書き込む。
- STAGEへのC1アクセス、Protected対象へのアクセス、既知の拒否試験の判定不明。
- コピーのSHA／サイズ不一致、違うWorkbookを発見、変更履歴の齟齬。
- 管理者認証・設定変更・追加接続が承認範囲を超える。
- Office認証・マクロ・イベント・リンク・アドイン等の安全確認不成立、予期しないWorkbook保存要求。
- 中断後の自動再試行、無承認の復旧・削除・搬送、保護設定緩和。

本書の作成に伴う実作業は**Markdown新規ファイルの作成のみ**。対象PCとArchiveにはアクセスせず、コピー、ネットワーク切断、Office起動、Compile、Git操作、Approved文書・Baseline改訂を一切行わない。

## 8. 現時点のGate判定と、次の最小判断

```yaml
ReferenceArtifact: E-P204-WB
ReferenceBuildDecision: USER_APPROVED
GeneralPCInvestigation: CLOSED_WITH_LIMITATIONS
PreferredTransferDesign: B_ADMIN_PRESTAGING
TransferRoute: UNKNOWN
WorkspaceCandidate: NOT_FOUND
NetworkCondition: WIFI_CONNECTED_REVIEW_REQUIRED
APlusC1FormalSelection: NOT_GRANTED
IsolationEstablished: FALSE
EvidenceWorkspacePrepared: FALSE
PreStagingAreaCreated: FALSE
PreStagingCopyCreated: FALSE
ExecutionCopyCreated: FALSE
AUTH_04_PRECHECK_01: APPROVED_USER_GUI_RESULTS_REPORTED
AUTH_04_PREPARATION: NOT_GRANTED
AUTH_02: NOT_GRANTED
AUTH_03: NOT_GRANTED
AUTH_05: NOT_GRANTED
AUTH_06: NOT_GRANTED
B_TRANSFER_01: NOT_GRANTED_PROPOSED_ONLY
B_HANDOFF_01: NOT_GRANTED_PROPOSED_ONLY
Compile: NOT_VERIFIED
DesignDecision: B_PREFERRED_DESIGN_ONLY
```

**次の最小判断は`B0`（実行を伴わない経路・役割・領域の机上確定）**：Private Indexに依存する正規Primaryから検証PCまでの受渡しを担当する管理主体と、採用可能な既存経路（同一PC／既存許可済み搬送媒体／その他）を**権限者が特定できるか**を判断する。現段階でその経路は`UNKNOWN`なので、コピー承認・領域作成承認を先に発行しない。追加のPC一般調査は要求しない。経路が確定しない場合は`TRANSFER_ROUTE_UNRESOLVED / STOP`であり、実行方式を無理に通さない。

## まとめ / Summary

**日本語：** 管理主体の事前搬入B方式を優先設計する。原本→管理側STAGE→隔離・安全Fixture→C1用WORKコピー→Compileを別Gateとし、Archiveと専用ユーザーを分離する。今は経路`UNKNOWN`、作業領域`NOT_FOUND`であり、B0机上確定が次の必要判断。搬入・PC変更・Compileは未承認。

**English:** Method B is the preferred design. Keep the archived original separate from a management staging area and the user's test copy. Check isolation and the safe fixture before Compile. The transfer route is unknown, and no workspace exists yet. The next step is to decide the route and roles on paper. No transfer, PC change, or Compile is approved.
