# P3-05 Input State — Source Review / Verification Preparation v0.1

| 項目 | 内容 |
|---|---|
| Document ID | P3-05-SOURCE-REVIEW |
| Revision | v0.1 |
| Status | **REVIEW / WORKING CANDIDATE** |
| 作成日 | 2026-11-21 |
| Approved Baseline | BL-MVP-004（変更なし） |
| 対象 | `modInputState_P3-05_Candidate_v0.1_CP932.bas`、`modP305InputStateCandidateTests_v0.1_CP932.bas` |
| 参照 | `P3-05_Input_State_Unit_Specification_Candidate_v0.1.md` |

## 1. Review目的・前提

XU-01 A案のP3-04 Gate改修Candidateに続き、`modInputState`の**独立したState責務のみ**をImplementation Preparationする。P3-04 UIと結合しない。既存P2 Production、GitHub、Baselineおよび承認済み文書への変更をしない。

参照したRepository Approved原文（読み取りのみ）：

- `Docs/01_specifications/MVP Requirements v0.1.9 日本語版.md`：§19 FR-INPUT-001/002（Git blob `c56df6fb5f5149c0e42a738dc44820082a356380`）
- `Docs/01_specifications/MVP Design v0.1.10 日本語版.md`：§18 Control Binding/Input State（Git blob `60fb48dde7993e04c38ae6651749aecc2052fcf5`）
- `Docs/01_specifications/MVP Test Specification v0.1.6 日本語版.md`：MTS-INPUT-001/002（Git blob `0d2684beba69e27e23799fb2fd3bcea4c6a96ec2`）
- `Docs/02_implementation/Implementation Plan v0.4 日本語版.md`：§6、§8.4（Git blob `e4a503d110875f64f067472676ead76386409d40`）
- P3-04 XU-01 A案のForm / Controller Candidateとレビュー（ローカル既存原本、変更なし）

既存GitHub Code Searchでは`modInputState`のProduction実装は見つからず、Design/Planのみで参照されていた。今回新規の`modInputState`はApproved Implementation Plan §6に列挙されているModuleである。

## 2. Source Review結果

| ID | 検査対象 | 判定 | 根拠・留保 |
|---|---|---|---|
| SR-01 | 公開Contract | MATCH（Candidate） | Public 3関数：Set / TryGet / Clear |
| SR-02 | Case Insensitive | MATCH | `Scripting.Dictionary.CompareMode=vbTextCompare` |
| SR-03 | Empty / Missing | MATCH | `hasValue`がStored BlankとAbsentを区別 |
| SR-04 | Input値の非加工 | MATCH | 生文字列をそのまま保存、Trim/Date Parseなし |
| SR-05 | 入力済みキーの上書き | MATCH | ExistsでAdd/Replaceを分岐 |
| SR-06 | すべての保存値クリア | MATCH | `RemoveAll`と冪等な空ストア扱い |
| SR-07 | Privateな状態管理 | MATCH | Module-level `Private mInputValues`、辞書参照非公開 |
| SR-08 | Result / Errorモデル | MATCH | 既存P0 `COperationResult` / `CreateFailureResult` |
| SR-09 | 不要な依存・副作用 | MATCH | Excel/Outlook/UserForm/ファイル永続化なし |
| SR-10 | CP932 / CRLF / 構造 | PASS（ソース静的） | 機械検査にて36/36項目PASS |
| SR-11 | VBA Compile | **NOT VERIFIED** | VBEを起動していない |
| SR-12 | 18 Fixture Runtime | **NOT RUN** | Fixtureは定義のみ |
| SR-13 | Workbook Close/Reopen | **NOT VERIFIED** | MTS-INPUT-001のSession再表示・永続保存なしを実機で未確認 |
| SR-14 | 画面ControlのClear | **NOT IMPLEMENTED** | MTS-INPUT-002のUI側は次Unitで実装 |
| SR-15 | P3-04接続 | **NOT IMPLEMENTED** | XU-01/02/06とFormイベント境界への影響を保留 |

### Static Audit

- 検査コマンド（再現用）: `python3 verification/static_audit.py`（パッケージRootからの相対パス）
- ソース静的検査: **36/36 PASS、0 FAIL**
- 範囲: CP932/CRLF、VB_Name、公開API、辞書/Key比較、入出力リセット、クリア、禁止依存、Fixture ID/構造など
- 本チェックは**VBA構文の完全検証でもVBA Compileでもない**。ResultのRuntime意味論、実際のWorkbook Session寿命、VBE Importは対象外。
- 検査ログ：`verification/P3-05_Static_Audit_20261121.json`

### Unit Fixture

- `RunP305InputStateCandidateTests`：18ケースを`P305-C01～C18`で定義。
- 使用するもの：Candidate `modInputState`、既存P0 `modResult`、`COperationResult`、`CErrorInfo`。
- 使用しないもの：実際のP3-01～04のStubや、Excel/Outlook/UserForm。
- Fixtureは隔離テスト向け。**Test Runnerの記載があることはケースPASSのEvidenceではない**。

## 3. 仕様整合と判断の区別

**Approved事実:** Dictionary Case Insensitive、Workbook Session中だけメモリ保持、再表示復元、辞書とControl両方のClear、BindingにはControl.Tag、State管理はShared / State Module `modInputState`。

**今回のImplementation提案:** `SetInputValue/TryGetInputValue/ClearInputValues`というPublic API、`String`値の採用、`hasValue`出力でEmpty/Absent分離、キー空白をConfigurationErrorとする、遅延Dictionary生成。

**未決・非採用:** UIイベント／動的Controlの取得方法（Change、Close時Snapshotなど）、Select復元で失効済みOptionをどう扱うか、UI ClearとState Clearの失敗時整合方法。P3-04の`cmdClear`は引き続きDisabled。専用Binding Classは作成していない。

## 4. Issue / Risk Log

| ID | 種類 | 状態 | リスク・次工程 |
|---|---|---|---|
| P305-I01 | API Value型 | PROPOSED / DECISION REQUIRED | Stringで全Typeの入力を生テキスト保持する候補。Date型/Selectの復元値表現と整合確認 |
| P305-I02 | UI Capture/Restore | DEFERRED | Form Close/Hide/Controller Unloadのタイミングに依存。Input値の取りこぼし防止 |
| P305-I03 | UI Clear原子性 | DEFERRED | StateだけのClearを「入力クリア完了」と通知してはならない |
| P305-I04 | Select復元 | DEFERRED | OptionMaster再取得後、保存値が現Active Optionにない場合のFail Closedを設計 |
| P305-I05 | Workbook Session | NOT VERIFIED | Close/Reopenで永続復元しない証跡は実機が必要 |
| XU-01 | Form Gate迂回 | DESIGN APPROVED / RUNTIME OPEN | P3-04 A案改修CandidateのRuntimeを今回進めていない |
| XU-02 | Snapshot参照共有 | OPEN | P3-04統合前に不変性リスクを判断 |
| XU-03/04 | 先行最小Patch | CANDIDATE / NOT APPLIED | 今回触らない |
| XU-06 | P3追加Module Mapping | OPEN | `modInputState`自体はPlan §6既存。追加Moduleの議論は別 |
| XU-07 | VBE/Designer | NOT VERIFIED | 実機依存。今は調査しない |

## 5. Gateおよび進捗

| Quality Gate | 判定 | 説明 |
|---|---|---|
| Approved契約とCandidate範囲の整合 | PASS（Source Review範囲） | 直接矛盾は発見していない。String APIなどは提案 |
| ソースCandidate作成 | COMPLETED | CP932/CRLF形式で新規生成 |
| Fixture作成 | COMPLETED | 18シナリオ、未実行 |
| Static Audit | PASS（36/36） | Source-only |
| VBA Compile | NOT VERIFIED | 実機未使用 |
| VBA Unit Test | NOT RUN | 実機未使用 |
| MTS-INPUT-001/002 Formal Test | NOT RUN | UI統合なし、P7 Formal Testでもない |
| P3-05 Production採用 | **REVIEW_REQUIRED** | API Detail未承認、Compile/Runtime未実施 |
| P3正式Phase開始 | NOT APPROVED / UNCHANGED | P2 Closure未成立 |

**今回のタスク（仕様・独立候補・テスト準備）はCOMPLETED。Unitの正式完了ではない。**

## 6. 次の開発アクション（承認待ち）

1. `String`によるUI生値保存と3 Public APIの採用可否をSource Reviewで判断する（Production適用は別）。
2. その後、P3-04のForm終了／再表示に対するUI結線方式を最小仕様として決める。`UserForm_QueryClose`等の入力採取タイミングとModal/Modelessの差異は実機で確認する。
3. Clearボタンを有効にする時点で、保存辞書と表示Controlの双方がクリアされた場合に限り成功と判断する。
4. XU-02の判断が必要な連携は独断で実施しない。
5. 実機が利用可能になった別承認工程で、VBE Compile→18 Unit Test→MTS-INPUT-001/002の順にEvidenceを取得する。

## 7. 保存先

- Spec/Code: `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Fixture: `MailGenerator/tests/vba/P3_Configuration_UserForm/`
- Review/Evidence: `MailGenerator/Docs/00_project_control/reviews/`

**現在の実ファイルは `/mnt/data/P3-05_Input_State_Candidate_v0.1/` 内のみ。GitHub未反映。**

## まとめ / Summary

**日本語:** P3-05単体のソース準備と静的検査は完了。18件のテストは未実行で、UI復元/クリアは次工程。Production採用とP3正式開始は未承認。

**English:** P3-05 code preparation and static review are complete. The 18 tests have not run. Form restore and Clear are next. Production and the official P3 start are not approved.
