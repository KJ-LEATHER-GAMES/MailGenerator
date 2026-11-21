# P3-05 Input State — 独立実装仕様 Candidate v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | P3-05-UNIT-SPEC-CANDIDATE |
| Revision / Status | v0.1 / WORKING CANDIDATE・NOT APPROVED |
| 作成日 | 2026-11-21 |
| Project / Baseline | 定型メール作成ツール / BL-MVP-004（変更なし） |
| Unit | P3-05（今回の作業呼称。P3正式開始ではない） |
| 対象 | `modInputState`、隔離Unit Testのみ |
| 上位根拠 | DOC-MVP-REQ v0.1.9 §19（FR-INPUT-001/002）、DOC-MVP-DES v0.1.10 §18、DOC-MVP-TESTSPEC v0.1.6 MTS-INPUT-001/002、DOC-MVP-IMPL v0.4 §6/§8.4 |

## 1. 背景・目的・完了条件

P3-01～04は未承認Candidateであり、XU-01はA案設計承認済みだがVBA Runtime / Production採用は未承認。XU-02の検証済みCarrier参照共有問題とXU-06の追加Module Mappingも未決。このため、P3-05は**Formとの統合をせず**、BL-MVP-004のInput State契約だけを単体で実装準備する。

本作業の完了条件は (1) API/データ表現/エラー契約の候補定義、(2) CP932のVBAソース候補、(3) Unit Fixture、(4) ソース静的検査、(5) 実機依存・未決事項の明示。**MTSのFormal PASSやP3正式開始は判定しない**。

## 2. Approved仕様から確定している契約

1. `InputValues` は `VariableName → Value` のCase Insensitive Dictionaryである（Design §18.2）。
2. 状態はWorkbook Session中のメモリのみ。Excel Sheet・ファイルへの永続保存はしない（Requirements §19、Design §18.2）。
3. 再表示時は、動的入力Controlの `Tag=VariableName` に対応する値を復元する（Design §18.1/§18.3）。
4. 入力クリアは辞書と表示中Controlの**双方**を消去する（Design §18.4、MTS-INPUT-002）。
5. Input Validation（Required、Date、Select）は別責務（Requirements §20、Design §19）。
6. `modInputState` はImplementation Plan §6でShared / State、P3/P4対象として指定されている。今回の新規Module自体に追加Mapping決定は不要。

## 3. 今回提案するImplementation Detail（ユーザー未承認）

| 項目 | Candidate方針 | 理由・制約 |
|---|---|---|
| 値の型 | `String`（表示中の生テキスト） | Text/Date/Selectの未検証入力を忠実に保持し、Type判定を持ち込まない |
| 保存API | `SetInputValue(variableName As String, inputText As String) As COperationResult` | UIがTag・Valueを渡す単純な契約 |
| 取得API | `TryGetInputValue(variableName As String, ByRef hasValue As Boolean, ByRef inputText As String) As COperationResult` | 未登録と「明示的に空文字を保持」を区別する |
| クリアAPI | `ClearInputValues() As COperationResult` | 辞書だけ全消去。表示中ControlはUIの責務 |
| 保存場所 | `Private mInputValues As Object`、遅延生成 `Scripting.Dictionary` | ファイルやCellを利用しない。参照を外へ公開しない |
| Key比較 | `CompareMode = vbTextCompare` | Case Insensitive契約 |
| Key異常 | 空文字・空白のみは`ConfigurationError` | `Tag`設定不備をサイレント無視しない。Syntax Regexは再実装しない |
| Empty値 | `""`を有効な保存値として保持 | 未入力表示と未登録を区別。入力必須性はP4へ |
| 技術例外 | `UnexpectedError`を`COperationResult`で返す | P0共有Result契約を再利用 |
| Clearの冪等性 | 未初期化／空DictionaryでもSuccess | 無用な副作用や初期化を避ける |

本仕様は**提案であり正式な新規Requirementではない**。`String`型の採用やAPI名は次のコードレビューで判断する。

### 3.1 Public Contract候補

```vb
Public Function SetInputValue( _
    ByVal variableName As String, _
    ByVal inputText As String _
) As COperationResult

Public Function TryGetInputValue( _
    ByVal variableName As String, _
    ByRef hasValue As Boolean, _
    ByRef inputText As String _
) As COperationResult

Public Function ClearInputValues() As COperationResult
```

#### Semantics

- `SetInputValue("GateDate", "2026/11/21")` は**文字列を保存するだけ**。Valid Dateかは判定しない。
- `TryGetInputValue`で対象キーがなければ`Success=True`、`hasValue=False`、`inputText=""`。
- `TryGetInputValue`で空文字が登録されていれば`Success=True`、`hasValue=True`、`inputText=""`。
- Failure時は`TryGetInputValue`の両出力を既定値に戻す。
- `ClearInputValues()`は全キーを削除し、Excel/Outlook/他Moduleには触れない。

### 3.2 不変条件

- 辞書はPrivateで外部へ参照公開しない。
- `SetInputValue`は入力文字列をTrim/Format/Date Parseせず、そのまま保存する。
- 同一VariableNameの大文字小文字違いは論理的に同一キーへ上書きする。
- 未知のKeyを検索しても辞書に新規追加しない。
- クリアは全件対象とし、指定された画面Controlの変更をCoreから行わない。
- Productionから`MsgBox`、OFT読み取り、Excel書込、COM/Word/Outlook操作、同期起動を行わない。

## 4. UI接続前の境界（今回実装しない）

```text
P3-04 Gate Success → UserForm Dynamic Controlsが存在
        ↓
UserForm表示・ユーザー入力
        ↓ (後続作業)
Control.Tagをキーに生文字列をSetInputValueへ保存
        ↓
UserForm再表示時、TryGetInputValue(Tag)で各ControlのValue/選択を復元
        ↓
入力クリア時、ClearInputValuesと表示中Controlの両方を消去
```

**要注意：** 現行P3-04 XU-01 A案Candidateは`cmdClear.Enabled=False`であり、Formの入力保存/復元イベントは未接続。したがって、このUnit単体のPASSは **MTS-INPUT-001/002のPASSではない**。

UI側のイベント方針（都度Changeイベント、Form Close/Hide時一括採取等）は後続設計判断が必要。現状の動的Controlに`WithEvents`専用Classを安易に追加しない。Selectの復元時は現在のActive Optionとの再照合・欠落時の停止が別途必要。Formとの統合では、XU-02の検証済みCarrier参照共有・XU-06 Module Mapping・XU-01のRuntime未検証と衝突しないことを確認する。

## 5. Failureと停止規則

| 条件 | Result候補 | Output / State |
|---|---|---|
| 初回呼出・辞書未生成 | Success | 必要ならDictionary生成 |
| 非空Keyで保存 | Success | 対象Keyの値を保持／上書き |
| Key不存在で取得 | Success | `hasValue=False`、`inputText=""` |
| 保存済み空文字の取得 | Success | `hasValue=True`、`inputText=""` |
| `variableName`空／空白 | ConfigurationError | Setは書込なし。Getは出力リセット |
| Dictionary生成失敗 | UnexpectedError | 外部へDictionaryを返さない |
| その他Runtime例外 | UnexpectedError | UIがResultを受けて停止。自動再試行なし |
| Clear未初期化／空 | Success | 変化なし |
| Clear実行失敗 | UnexpectedError | 完了と主張しない |

## 6. Unit Test計画（Fixture 18件、すべてNOT RUN）

| ID | 概要 |
|---|---|
| P305-C01 | 初期状態でKeyなし |
| P305-C02 | 保存→同名取得 |
| P305-C03 | 異なる大小文字で取得 |
| P305-C04 | 大小文字の違うSetで上書き |
| P305-C05 | 保存済み空文字と未登録の区別 |
| P305-C06 | `"0"`を文字列として保持 |
| P305-C07 | `"False"`を文字列として保持 |
| P305-C08 | 日本語文字列Roundtrip |
| P305-C09 | 前後空白を保持 |
| P305-C10 | 複数Keyを独立保持 |
| P305-C11 | Clearで全件削除 |
| P305-C12 | Clearの冪等性 |
| P305-C13 | 空KeyのSet拒否 |
| P305-C14 | 空白KeyのSet拒否 |
| P305-C15 | Get失敗時出力初期化 |
| P305-C16 | Clear後に再利用 |
| P305-C17 | Set失敗で既存値不変 |
| P305-C18 | 未登録GetのSuccess／Found=False |

このUnit Fixtureは既存P0の`modResult`・`COperationResult`・`CErrorInfo`を使用する。実機での実行は**未承認・未実施**。同名モジュールの二重Import禁止。

## 7. Traceability・Completion Boundary

| Approved Test | 今回の寄与 | 今回の判定 |
|---|---|---|
| MTS-INPUT-001 | 生入力値保存、再取得、メモリのみのソース構造 | PARTIAL SOURCE COVERAGE / NOT RUN。Form Close/再表示/Workbook Close→Reopenは未検証 |
| MTS-INPUT-002 | `ClearInputValues`の全消去ロジック | PARTIAL SOURCE COVERAGE / NOT RUN。画面Controlクリアは未実装 |
| MTS-UI-001～005 | 変更なし | NOT IN SCOPE |
| P3 Phase Exit | 変更なし | NOT ACHIEVED |

## 8. Decision / Issue Log

- **承認済み:** XU-01 A案の設計判断（P3-04側）／BL-MVP-004既存Baselineの不変。
- **提案:** P3-05 Public API 3関数、入力値`String`、空文字と未登録の区別、初回遅延初期化。
- **未決:** 将来のControl値収集タイミング、Select Active Option喪失時の復元方針、画面Clearとの失敗時整合、Workbook Close/Reopen実機証跡。
- **継続管理:** XU-01 Runtime/Production、XU-02 Snapshot不変性、XU-03/04 Patch、XU-06 Module Mapping、XU-07 Designer/VBE、P3-01旧4判断。
- **禁止変更:** P2 Production、既存P3-01～04 Candidate、GitHub、Baseline、P2 Closure/S5-C/P3正式開始状態。

## 9. Quality Gate / Next Action

- Candidate仕様とコード／Fixture整合：静的確認後に判定。
- VBA Compile/実機Runtime：**NOT VERIFIED**。
- 形式的MTS PASS、P3-05 COMPLETE、P3正式開始：**CLAIMしない**。
- 次の別作業：P3-05単独Source Reviewで候補API・String表現を承認判断。その後、XU-02の扱いを決め、P3-04との接続候補を作成する。

## 10. 保存先案

- 本仕様：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/P3-05_Input_State_Unit_Specification_Candidate_v0.1.md`
- Source Candidate：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/modInputState_P3-05_Candidate_v0.1_CP932.bas`
- Fixture：`MailGenerator/tests/vba/P3_Configuration_UserForm/modP305InputStateCandidateTests_v0.1_CP932.bas`
- Review：`MailGenerator/Docs/00_project_control/reviews/P3-05_Input_State_Source_Review_v0.1.md`

いずれも現時点のGitHubには未保存。既存正本は上書きしない。

## まとめ / Summary

**日本語：** P3-05 Input StateをCore責務だけに絞った実装候補とした。UIの復元・Clear接続は別作業。VBA未実行、正式採用未承認。

**English:** P3-05 handles input values in memory only. Form restore and Clear are separate. VBA tests have not run. Production use is not approved.
