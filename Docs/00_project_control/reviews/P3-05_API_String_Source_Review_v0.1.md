# P3-05 Input State Public API / String保持方式 ― Source Review v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | P3-05-API-REVIEW-20261121 |
| Revision | v0.1 |
| Status | REVIEW COMPLETED / CANDIDATE ACCEPTANCE PROPOSED / NOT APPROVED |
| 日付 | 2026-11-21 |
| Project | 定型メール作成ツール / MailGenerator |
| Current Approved Baseline | BL-MVP-004（変更なし） |
| 対象Unit | P3-05 Input State（先行準備、P3正式Phase未開始） |
| Source of Truth | DOC-MVP-REQ v0.1.9 §19、DOC-MVP-DES v0.1.10 §18、DOC-MVP-TESTSPEC v0.1.6 MTS-INPUT-001/002、DOC-MVP-IMPL v0.4 §6・§8.4 |
| 対象Source | `P3-05_Input_State_Candidate_v0.1/src/modInputState_P3-05_Candidate_v0.1_CP932.bas`（参照、無変更） |

## 1. 目的・スコープ・完了条件

**目的**：P3-05のPublic APIと生文字列保持がApproved契約と矛盾しないことをSource Reviewし、P3-04との接続検討に必要な条件を確定候補として整理する。

**In Scope**：`modInputState`実コード、隔離Unit Fixture 18件、Approved仕様とのTraceability、Session保存範囲、P3-04接続条件の抽出。

**Out of Scope**：Production採用承認、既存Candidateの編集、GitHubへの書込、Excel/Outlook/VBA実行、XU-01 Runtime検証、P2 Closure、S5-C、P3正式開始、P4 Input Validator実装。

**レビュー完了条件**：API・型・Error・状態保持のSource判定と懸念、接続時の未決事項、次工程のQuality Gateを明示する。正式Production承認は完了条件に含めない。

## 2. Source Review：API・データ・責務

### 2.1 Public Contract（Candidate）

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

| 評価項目 | 根拠／ソース挙動 | Review判定 |
|---|---|---|
| Module名 | `Attribute VB_Name = "modInputState"`。Implementation Plan §6のShared/Stateに既存のModule名 | SOURCE MATCH |
| 単一の状態所有者 | `Private mInputValues As Object`。Public Store直接公開なし | SOURCE MATCH |
| Case Insensitive | `Scripting.Dictionary`生成直後に`CompareMode = vbTextCompare` | SOURCE MATCH |
| 値の型 | `SetInputValue` / `TryGetInputValue`のString。入力文字列をTrim・Date Parse・Formatしない | SOURCE MATCH / **API型は今回の提案** |
| 未登録 vs 空文字 | Get時は `hasValue=False` を初期化。存在時のみ `hasValue=True` | SOURCE MATCH |
| 書込・更新 | `Exists` 分岐で同Keyを上書き。大文字小文字違いでも同一 | SOURCE MATCH |
| 入力名異常 | `Trim$(variableName)`空は`ConfigurationError`で拒否。Keyを自動補正しない | SOURCE MATCH / Detail候補 |
| Clear | `RemoveAll`。未生成辞書でもSuccess。画面は触らない | SOURCE MATCH |
| Result | P0 `COperationResult`、`ConfigurationError` / `UnexpectedError` を使用 | SOURCE MATCH |
| 永続化・依存 | Worksheet・ファイル・Outlook・UserFormの直接呼出しなし | SOURCE MATCH |
| Workbook Session | VBA標準Module変数がプロジェクト存続中保持する構造 | SOURCE-ONLY MATCH / **実環境でのSession挙動は未確認** |

**承認済み仕様とImplementation Detailの区別**：Approved Designが固定しているのは「VariableName→Value、Case Insensitive、Workbook Session中のみ、Tagを用いた復元、辞書と画面の同時Clear」であり、3つの関数名や`String`の型は本Candidateが具体化した案である。**ユーザーの実装契約承認は未取得。**

### 2.2 Stringの妥当性と制約

- TextおよびDateの**表示用未検証文字列**を保存する方針は、Date変換・Required判定をP4へ分離するApproved要件と矛盾しない。
- Selectは表示・保存するOptionの`Value`を文字列とする。`ListIndex=-1`（未選択）の場合、`.Value`が空文字であると**仮定せず**UI境界で明示的に`""`へ正規化する。
- 空文字は保存された値、未登録Keyは`hasValue=False`で区別される。両者ともForm側で空欄表示可能。
- キーをCStr・Trim等で黙って変換せず、`Control.Tag`の非空をUIで確認して渡す。
- Clearで全件消える。**個別Key削除APIは存在しない**。Selectの失効値を「未選択」にしたい場合、`SetInputValue(Tag, "")`は削除ではなく明示的空文字への更新となる。

### 2.3 証明可能範囲

独立Fixture 18件はコードとして存在するが**0件実行**。特に`P305-C01`は`ClearInputValues()`で初期状態を作るテストであり、VBA Project初期起動やWorkbook Close/Reopenの実際の証拠ではない。`P305-C15`は空Key入力によるFailure経路の確認案で、技術的例外注入ではない。既存の36/36静的チェックもVBA Compile/Runtime PASSを示さない。

## 3. Findings / Risk

| ID | 判定 | 見つかった事実 | リスク・対応 |
|---|---|---|---|
| P305-R01 | NON-BLOCKING / IMPLEMENTATION DETAIL | Public 3 APIとString型はApproved文書に関数名まで規定されていない | 実装契約として承認を得る。ソース変更の必然性は見つからず |
| P305-R02 | OPEN / INTEGRATION | CoreのみではForm入力の最終保存、Form再表示、UI Clearを行わない | P3-04との接続で満たす。MTS-INPUT-001/002は未達 |
| P305-R03 | OPEN / INTEGRATION | `SetInputValue`は1キー単位で更新。全入力一括保存をAtomic CommitするAPIはない | 保存直前に全Controlを検査し、失敗時は閉じさせない。部分更新が発生した場合の再試行方針を明記。必要になってからBatch APIを検討 |
| P305-R04 | OPEN / UI DECISION | Select保存値が現行Optionから消えた場合の復元規則は未確定 | 無言の別Option選択を禁止。未選択に戻して明示通知する案を接続仕様で提案 |
| P305-R05 | NOT VERIFIED | Workbookを閉じて再起動したときの非永続性は実行証拠なし | 将来MTS-INPUT-001で確認 |

## 4. Source Review Quality Gate

| 観点 | 判定 |
|---|---|
| Sourceに3 APIと`String`保持が実装されている | PASS（静的確認） |
| Approved Requirements/Designとの意味整合 | PASS（静的確認） |
| 既存P0 Resultへの依存構造 | PASS（静的確認） |
| VBA Import / Compile | NOT VERIFIED |
| 18件Unit Runtime | NOT RUN |
| MTS-INPUT-001／002 End-to-End | NOT VERIFIED |
| Public API / StringのProduction採用承認 | PENDING USER APPROVAL |

**推奨判定**：`modInputState` v0.1を**変更なしで次のP3-04接続設計の前提Candidateとして採用する案**。Production実装確定やFormal PASSと扱わない。

## 5. Decision Log（承認状態を分離）

| ID | 分類 | 内容 | 状態 |
|---|---|---|---|
| D-P305-01 | AI推奨 | Public 3 APIを維持 | PROPOSED / NOT APPROVED |
| D-P305-02 | AI推奨 | 生文字列Stringを保持、型検証はP4 | PROPOSED / NOT APPROVED |
| D-P305-03 | Approved既存仕様 | Session内Dictionary、Case Insensitive、Tag、Clear双方 | APPROVED by baseline |
| D-P305-04 | 今回の変更 | P3-05コード・Baselineの変更 | NONE |

## 6. 依存資料

- `P3-05_Input_State_Candidate_v0.1/docs/P3-05_Input_State_Unit_Specification_Candidate_v0.1.md`
- `P3-05_Input_State_Candidate_v0.1/src/modInputState_P3-05_Candidate_v0.1_CP932.bas`
- `P3-05_Input_State_Candidate_v0.1/tests/modP305InputStateCandidateTests_v0.1_CP932.bas`
- `P3-04_XU01_Gate_Enforced_Candidate_v0.1/src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm`
- `P3-04_XU01_Gate_Enforced_Candidate_v0.1/src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas`
- `P3-01_to_P3-04_Cross_Unit_Source_Review_v0.1_20261121.md`

## 7. 保存先

今回の作業領域は`/mnt/data/P3-05_Source_Review_and_P3-04_Integration_Package_v0.1/`。将来GitHubへ受け入れる場合の推奨保存先は`MailGenerator/Docs/00_project_control/reviews/`。**GitHub保存・既存正本上書きは実施していない。**
