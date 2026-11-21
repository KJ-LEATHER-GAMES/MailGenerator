# P3-01～P3-04 横断整合性ソースレビュー v0.1

| 管理項目 | 値 |
|---|---|
| Document ID | REV-P3-CROSS-001（Working） |
| Revision / Status | v0.1 / **REVIEW COMPLETED WITH FINDINGS**（Production採用審査は **REVIEW_REQUIRED**） |
| 作成日 | 2026-11-21 |
| 対象 | P3-01 Validator、P3-02 Current Snapshot Application、P3-03 Launch Gate、P3-04 Form / Controller の **各Candidate v0.1** |
| 判定の基準 | **BL-MVP-004**／DOC-MVP-REQ v0.1.9、DOC-MVP-DES v0.1.10、DOC-MVP-TESTSPEC v0.1.6、DOC-MVP-IMPL v0.4（Approved） |
| レビュー種別 | Read-only Source / Cross-unit Contract / Static Review（VBA実行ではない） |
| 最終判断 | **接続形状は整合。ただし正式Production採用は非推奨。Gate迂回等の是正判断が必要。** |
| 実施しない作業 | 既存Production／GitHub／Baselineの変更、実機Excel/Outlook、B2-02環境調査、Compile、P3正式Phase開始、S5-C／P2 Closure認定 |

## 1. 目的・スコープ・完了条件

**目的:** P3-01～04の独立Candidate間で、公開API・Carrier形状・Success / Failure伝播・Gate迂回・Module Mapping・テストStub競合を照合し、修正候補と未決事項を分離する。

**In Scope:** 4候補5 Productionソース（P3-04はFormとController）、テストStub / Runner、候補レビュー記録、Approved文書との仕様マッピング。

**Out of Scope:** SourceのProductionへのImport / Commit、UserForm実機表示、P3-05実装、環境調査の再開、S5-C / P2 Closureの正式審査。

**完了条件（このレビュー作業のみ）:** 横断検査表、Issue / Risk、最小差分候補、Source同一性、未検証事項、次工程判断を作成。**正式採用可能性のPASSを条件とはしない。**

## 2. Reviewed Source / 同一性

元の4つのZIPを実際に展開し、CP932としてProductionソースの内容を読んだ。以下のSHA-256は対象5ファイルの**今回の読み取り元**を識別する。フルハッシュは同梱JSON参照。

| ID | ZIP内相対パス（レビュー作業上のprefixを含む） | SHA-256冒頭 | サイズ(Byte) |
|---|---|---|---:|
| p301 | `p301/src/modConfigurationValidator_P3-01_Candidate_v0.1.bas` | `491012dbaa8fc9cc…` | 20,879 |
| p302 | `p302/P3-02_Application_Candidate_Package/src/modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas` | `d00fa96dc59cf07b…` | 12,705 |
| p303 | `p303/P3-03_UserForm_Launch_Gate_Candidate_v0.1/src/modP3UserFormLaunchGate_P3-03_Candidate_v0.1_CP932.bas` | `6f8f2d934f81e036…` | 9,473 |
| p304c | `p304/P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas` | `5a26ca5e613b47f7…` | 3,708 |
| p304f | `p304/P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/frmMailGenerator_P3-04_Candidate_v0.1.frm` | `7ae49e7a20427313…` | 14,629 |

元アーカイブ：`P3-01_Configuration_Validator_Production_and_Test_Fixture_Candidate_v0.1.zip`、`P3-02_Current_Snapshot_Application_Integration_Candidate_v0.1.zip`、`P3-03_UserForm_Launch_Gate_Candidate_v0.1.zip`、`P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1.zip`。上記は**GitHubに登録されたProductionのSHAではない**。

Approved参照：
- `Docs/00_project_control/Document_Registry.md` v2.37、§3：BL-MVP-004がCurrent Approved Baseline。
- `Docs/02_implementation/Implementation Plan v0.4 日本語版.md`：§6 Module Mapping、§8.4 P3（Approved / BL-MVP-004）。
- `Docs/01_specifications/MVP Design v0.1.10 日本語版.md`：§7.3 / §16 / §17 / §18 / §25.2（Approved）。
- `Docs/01_specifications/MVP Requirements v0.1.9 日本語版.md`：§11 / §12 / §14 / §16 / §17。
- `Docs/01_specifications/MVP Test Specification v0.1.6 日本語版.md`：MTS-CFG-001～008 / MTS-UI-001～005。

## 3. API接続マトリクス

| 接続 | 呼出元 → 呼出先 | 契約と実コードの観測 | 判定 |
|---|---|---|---|
| P3-01 | P3-02 → `ValidateConfiguration(Boolean, Object, Collection, Object) As COperationResult` | P3-02:71–77 → P3-01:26–31。存在判定後`True`と3 Carrierを渡す | **MATCH** |
| P3-02 | P3-03 → `PrepareCurrentConfiguration(ByRef Object, ByRef Collection, ByRef Object) As COperationResult` | P3-03:33–45 → P3-02:17–21。失敗時結果を返してソートしない | **MATCH** |
| P3-03 | P3-04 Controller → `PrepareUserFormLaunch(ByRef Collection, ByRef Object) As COperationResult` | P3-04 Controller:20–38 → P3-03:18–21。成功後にForm新規生成 | **MATCH** |
| P3-04 | Controller → `frmMailGenerator.BuildValidatedInputs(Collection, Object) As COperationResult` | Controller:40–52 → Form:80–83。Form構築成功後だけ公開 | **MATCH（呼出形状）／Gate迂回Issueあり** |
| Result | 全Unit → `CreateSuccessResult / CreateFailureResult / COperationResult` | 既存`modResult`／`CErrorInfo`の公開契約に整合 | **MATCH（実機Compile未確認）** |

**依存方向:** Infrastructure / Outlook Adapter → P3-02 Application → P3-01 Core → P3-03表示データGate → P3-04 UI Controller / Form。P3-03はApplicationを呼び、P3-04はGateを呼ぶが、P3-01はOFT・Excel ListObjectを直接触らない。P2-05 `modUiController`への変更はない。

## 4. CarrierとFailure伝播

| 観点 | 観測結果 | 判定 |
|---|---|---|
| Scan Carrier | P3-02がCurrent OFT取得・`ScanTemplate`・`CloseWithoutSave`を行い、`TemplateScanResult`をP3-01へ渡す | MATCH（実機実行は未確認） |
| Definition Carrier | `GetAllVariableDefinitions`によりActive + Unusedを収集し、Dictionary行の`__RowIndex`をソートで参照する | MATCH |
| Option Carrier | P3-02はActive / Select行の`OptionSource`別に`GetActiveOptions`結果を取得し、GroupキーはBinary比較。P3-01 / FormもBinary比較 | MATCH |
| Required | P3-01 / FormがBoolean・数値0/1・文字列true/falseを暫定受容。両候補は整合するが、採用判断はOPEN | MATCH / OPEN |
| SortOrder | P3-01の`IsNumeric`受容はP3-03の`CDbl`要求より広い。後続でFail Closedするが、Validator Successの意味が揃わない | **ISSUE XU-03** |
| `InvalidCandidates` | P3-01が0件以外をConfigurationError扱い。P3-02はScannerの結果を使い再Scanしない | MATCH |
| P3-02 Failure | Successでない先行Resultを保持し、出力3件をNothingとして返す。正常Scan結果はClose成功時だけ外へ出す | MATCH |
| P3-03 Failure | 先行Failureを保持し、ソート開始せず、出力2件はNothing | MATCH |
| P3-04 Failure | Gate FailureならForm非生成、Build FailureならUnload、Showへの進行なし | MATCH（Controller経由に限る） |
| Primary / Cleanup | P3-02はScan失敗時の一次Failureを保持する一方、同時発生したCleanup失敗を診断しない | **ISSUE XU-04** |
| ErrorType | 構造Carrier異常はUnexpectedError、設定値不備はConfigurationErrorを基本に実装。ErrorType境界の正式承認はOPEN | MATCH / OPEN |
| Multiple errors | first-error伝播が基本。複数エラーの集約方針はOPEN、`COperationResult.Errors`の能力だけで全件通知を主張しない | MATCH / OPEN |

## 5. Static Audit（元の候補、無修正）

実ソースから22項目を判定。**17 MATCH / 4 ISSUE / 1 NOT_VERIFIED**。正規表現とソース行を用いたSource-only観測であり、VBA Compile・実行試験・Formal TestのPASSではない。観測定義は付属JSONを参照。

| 点検項目 | 判定 |
|---|---|
| 01: P3-01 exports ValidateConfiguration | **MATCH** |
| 02: P3-02 invokes P3-01 | **MATCH** |
| 03: P3-02 exports PrepareCurrentConfiguration | **MATCH** |
| 04: P3-03 invokes P3-02 | **MATCH** |
| 05: P3-03 exports PrepareUserFormLaunch | **MATCH** |
| 06: P3-04 Controller invokes P3-03 | **MATCH** |
| 07: Controller invokes Form builder | **MATCH** |
| 08: Form implements Builder | **MATCH** |
| 09: P3-02 publishes snapshot only after success | **MATCH** |
| 10: P3-03 fails before sort | **MATCH** |
| 11: P3-04 creates Form only after Gate check | **MATCH** |
| 12: P3-04 shows only after Build success | **MATCH** |
| 13: Stable sort uses SortOrder then __RowIndex | **MATCH** |
| 14: Select ComboBox is noneditable | **MATCH** |
| 15: Input controls bind Tag to VariableName | **MATCH** |
| 16: No production calls to ExecuteManualSync/ApplySyncDiff | **MATCH** |
| 17: First-error propagation is present | **MATCH** |
| 18: Gate bypass through direct public Form builder | **ISSUE** |
| 19: Row Dictionary references reused in sorted output | **ISSUE** |
| 20: Validator uses IsNumeric without Double conversion | **ISSUE** |
| 21: P3-02 suppresses secondary cleanup error without diagnostic | **ISSUE** |
| 22: P3-04 Form Designer not VBE verified | **NOT_VERIFIED** |

## 6. Issue / Risk Log

| ID | 深刻度 | Findingと証拠 | 推奨対応 | 状態 |
|---|---|---|---|---|
| **XU-01** | **HIGH / 採用前Blocking** | `frmMailGenerator`の`BuildValidatedInputs`が**Public**（Form:80）。P3-01～03の評価は同メソッドに存在せず、任意Carrierで呼び出し可能。`ValidateRenderableRow`は構造検査だけ（Form:154～203）。現Controller経路は正しいが、プロジェクト全域でGateを強制できていない | **公開構築APIとGate実行境界を再設計**。詳細は§7 | **OPEN / 承認待ち** |
| **XU-02** | MED / Integrality | P3-03が`sortedCandidate.Add item`（P3-03:157,162）で元行Dictionaryを共有し、`activeOptionsByGroup`も同じOption参照を公開（P3-03:80～82）。Current Call Pathで変更する証拠はないが、検証後変更を防ぐ不変Snapshotではない | P3-04表示まで同期一貫性を維持する設計判断。必要なら検証済みCarrierのコピー／読み取り専用化。P3-05統合前に再評価 | **OPEN（リスク）** |
| **XU-03** | MED / 最小修正候補 | P3-01 `IsValidSortOrder`（526～532）は`IsNumeric`のみ。P3-03 `TrySortKey`（181～200）は`CDbl`が必要で、OverflowではFailure | **`CDbl`受容可能性をP3-01で事前確認**（Candidate Patch A） | **PATCH CANDIDATE / 未反映** |
| **XU-04** | MED / 診断性 | P3-02 `CaptureCurrentTemplateScan`（147～182）で一次FailureとCleanup失敗が同時発生すると二次Failureが観測可能な診断から消える | 一次Result維持のまま二次Cleanup FailureのみDebug.Print（Candidate Patch B）。**Cleanup成功と誤認しない** | **PATCH CANDIDATE / 未反映** |
| **XU-05** | **HIGH / Import禁止条件** | P3-02テストStubは本番の9公開関数と衝突。P3-03 Stubは`PrepareCurrentConfiguration`、P3-04 Stubは`PrepareUserFormLaunch`を定義 | **全Stubを混合Importしない**。Unit別隔離、または統合時はStubを一層に統一し競合関数を除外 | **CONTROLLED / 設計上既知** |
| **XU-06** | MED / Module Governance | Implementation Plan v0.4 §6/§8.4にない`modConfigurationApplication`、`modP3UserFormLaunchGate`、`modP3UserFormController`が追加候補。§6には近接Module統合ルールはあるが新規分離Moduleの承認はない | Layer責務を維持した独立採用か、`modUiController` / `modMailApplication`への統合かを選択。既存P2を無断修正しない | **OPEN / 承認待ち** |
| **XU-07** | HIGH / 実機証跡不足 | P3-04 `.frm`はDesignerテキスト案のみ、正式`.frx` / VBE Import / VBA Compile / UI操作性Evidenceなし | 実機が使える際に別途承認された環境でImport・Compile・表示/操作性を確認。今は環境調査へ戻らない | **NOT VERIFIED** |

### Stub名の衝突（混合Import禁止）

- P3-02 `modP3_02TestStubs`：`GetSettingValue`、`ResolveWorkbookRelativePath`、`CreateMailFromTemplate`、`ReadSubject`、`ReadBodyText`、`ScanTemplate`、`CloseWithoutSave`、`GetAllVariableDefinitions`、`GetActiveOptions`（**既存Production Data Access等と衝突**）。
- P3-03 `modP3_03GateTestStub`：`PrepareCurrentConfiguration`（P3-02 Production Candidateと衝突）。
- P3-04 `modP3_04GateStub`：`PrepareUserFormLaunch`（P3-03 Production Candidateと衝突）。
- Unit別の個別テストFixtureは**P3-01～04統合試験の証拠ではない**。隔離方式の採用、VBA ProjectのImport / Compileは今回承認されていない。

## 7. Gate迂回に関する正式判断案（変更未承認）

**A案（推奨、設計変更候補）:** `frmMailGenerator`の公開構築入口そのものがP3-03 Gateを内部で呼び、必要なSnapshotを取得した場合にだけControlを生成する。P3-04 ControllerはFormを作成して入口を呼び、成功時だけShow。**利点:** どの呼出元もFormの公開構築APIからGateを迂回できない／再Scanは1回。**変更点:** Gate失敗でも一時Formオブジェクトは生成されるが動的Controlは生成されず表示もされない。これは旧Candidateの「Gate FailureではFormインスタンスすら生成しない」を変更するため、**ユーザー承認後にのみ別Patch**にする。

**B案（暫定運用）:** Builderの呼出しをControllerに限定し、Static Callsiteチェックを追加する。現在のController経路の安全性を維持できるが、Public APIへの直接呼出しは実行時には防げないため、XU-01の完全解消とはしない。

**不採用:** `Public`を単に`Friend`に変更して解決済みとする方法。同一VBA Project内からの呼出し制限にはならず、Gate成功の証明を伴わない。

**推奨判断:** A案の変更影響を先に承認審査し、修正Candidate → 横断再レビュー。現時点ではA案を承認済みとして扱わない。

## 8. 最小修正候補（Production未変更）

`P3_Cross_Unit_Minimal_Fixes_Candidate_v0.1.patch`と、**CP932 / CRLFの丸ごと置換用Candidate 2ファイル**を作成した。

| Patch | 変更対象 | 変更内容 | 動作契約への影響 | 実施状態 |
|---|---|---|---|---|
| A | P3-01 `modConfigurationValidator` | `IsNumeric`だけでSuccessにせず、例外捕捉下で`CDbl`変換可能なSortOrderのみ受容 | P3-03で必要な数値Domainを早期確認。小数/負数/数値文字列など、変換できる数値の許容政策は変更しない | **Candidateのみ** |
| B | P3-02 `modConfigurationApplication` | 既存一次Failureの返却は維持、二次Cleanup Failure 3パターンのみ開発向けDebug出力 | エラー優先順位・表示文字列・再試行・COM操作・返却Carrierは変更しない | **Candidateのみ** |

`git apply --check --ignore-whitespace`は元のCP932 / CRLFを保った展開済みCandidateに対し **PASS**。一時コピーでパッチ適用後のテキストと生成差分を比較し、一致確認 **PASS**。**元の候補ファイル自体に変更はない。**

**適用時注意:** `.patch`はUTF-8 / LFであり、元VBAはCP932 / CRLF。行末差のためGit Applyでは`--ignore-whitespace`が必要になる。実際の採用作業では、同梱した**均一CP932/CRLFの修正済み候補ファイル**を主たる確認対象とする。いずれもVBA Compile・テスト未実施のため、修正済みProductionではない。

## 9. 未決事項 / Decision Log

| ID | 判断事項 | Reviewからの推奨 | 状態 |
|---|---|---|---|
| D-P3-X-01 | GateをForm内で強制するA案へ変更するか | **推奨：A案**。旧Candidateのインスタンス生成順序を変更する影響を承認してから差分作成 | **UNAPPROVED** |
| D-P3-X-02 | P3-02 / P3-03 / P3-04の追加独立Moduleを採用するか | 現時点では最小分離をCandidateとして保持。正式採用前にModule Mapping決定 | **UNAPPROVED** |
| D-P3-X-03 | Requiredの受容表現 | Boolean・0/1・true/falseは既存OptionMaster解釈に近いが、Required要件の「明示的選択」との適合をユーザーが承認 | **OPEN** |
| D-P3-X-04 | SortOrderの数値許容範囲 | 小数、負数、数値文字列の新制限を勝手に導入せず、CDbl安全性を優先確認 | **OPEN** |
| D-P3-X-05 | Carrier異常時のError分類 | 破損内部Carrier→UnexpectedError、設定不備→ConfigurationErrorの暫定区別 | **OPEN** |
| D-P3-X-06 | first-error優先 | P2-04と同様の一次Failure維持を暫定推奨、複数表示は別Decision | **OPEN** |
| D-P3-X-07 | 検証済みCarrierの参照共有 | P3-05で保持する値が現時点で確定するまで変更を拡大しない。再表示時の不変性を判断 | **OPEN** |

**このレビューで新たにユーザー承認を得た決定：0件。** 推奨は決定ではない。

## 10. Quality Gate / 作業状態

| 対象 | 判定 | 根拠 |
|---|---|---|
| 目的とスコープに沿った横断レビュー | **PASS** | 実ソースの5ファイルとStub / Approved仕様を照合し22項目を記録 |
| 公開API接続形状（Source Only） | **PASS** | §3、4ホップが一致 |
| Failureの既存契約（Source Only） | **PASS WITH LIMITATION** | §4、Controller経由でFail Closed。全経路Runtimeは未確認 |
| Gate全域迂回不可 | **FAIL** | XU-01、Formの直接Public呼出し |
| Module Mapping承認 | **NOT VERIFIED** | XU-06、決定待ち |
| テストStubの実Production混入なし | **NOT VERIFIED** | 今回Importしておらず、Stub競合はソース上で確認 |
| CP932/CRLF修正候補生成 | **PASS** | 元Candidateと差分を確認し、新規ファイルとして作成 |
| Unified Patch適用可能性 | **PASS（静的・限定）** | `git apply --check --ignore-whitespace`および一時コピーに適用・照合 |
| VBA Compile / Runtime / UserForm Import | **NOT VERIFIED** | 実機使用なし |
| P3-01～04 Production採用 | **FAIL / REVIEW_REQUIRED** | XU-01、未承認Decision、実機未検証 |
| S5-C / P2 Closure / P3正式Phase開始 | **NOT APPROVED / NO CHANGE** | 本レビューの範囲外 |

**レビューTask:** COMPLETED。**Promotion readiness:** REVIEW_REQUIRED。**P3-05着手可否:** Input State単独の仕様準備は可能。ただしP3-04との結合・Production昇格はXU-01とModule Mappingの扱いを確定してから行うことを推奨。

## 11. 次工程

1. **最優先:** D-P3-X-01（Gate自己完結化A案の採否）を判断する。A案承認後にのみP3-04最小修正候補を作る。
2. XU-03/04のCandidate Patchをレビューし、実装Candidateへ反映するか決定する。未承認のまま採用扱いにしない。
3. D-P3-X-02（Module Mapping）を判断する。P2-05 Productionに触れる選択肢は別途変更承認が必要。
4. P3-05 Input Stateの**独立準備**へ進む場合は、Form連携の前にGate境界を解決する。
5. 実機Import・Compile・Runtime Verificationは別途承認後のみ。B2-02環境調査は再開しない。

### 次の会話にそのまま渡せる開始指示

> `P3-01_to_P3-04_Cross_Unit_Source_Review_v0.1_20261121.md`を確認し、XU-01を優先してください。推奨A案（Form構築入口がGateを内部で検証）と現CandidateのForm非生成条件の差分・影響を承認判断できるよう整理してください。Approved BL-MVP-004と既存P3-01～04 Candidateは無断で変更しないでください。P2-05 Production、GitHub、Baseline、実機／環境調査、S5-C/P2 Closure/P3正式Phase開始は範囲外です。GrillMe方式で承認が必要な判断を一問ずつ進めてください。`

---

## まとめ / Summary

**日本語:** P3-01～04のソース連結は成立するが、公開Form BuilderのGate迂回が残るため正式採用は未準備。22項目のうち17整合、4指摘、1実機未確認。SortOrder/二次Cleanup診断に対する最小修正候補を作成したが未適用。次はGate境界の承認判断。

**English:** The four P3 candidates connect at the API level. The public form builder can bypass the gate, so production approval is not ready. We found 4 issues in 22 static checks. We prepared two small fix candidates but did not apply them. Next, decide how to enforce the gate.
