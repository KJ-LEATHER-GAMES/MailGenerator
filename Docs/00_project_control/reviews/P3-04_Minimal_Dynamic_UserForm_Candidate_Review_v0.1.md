# P3-04 最小Dynamic UserForm・Gate接続 実装候補レビュー v0.1

> **Status: WORKING CANDIDATE / NOT APPROVED / NOT IMPORTED / NOT COMPILED / NOT EXECUTED**  
> 作成日: 2026-11-16  
> P3正式Phase開始ではなく、P2 Closure前のソースレベル開発準備。

## 1. 目的と成果物

- `src/frmMailGenerator_P3-04_Candidate_v0.1.frm`：固定ShellのDesigner候補と動的入力Control生成コード。**VBE Import-readyではない可能性がある**。`.frx`未作成。
- `src/frmMailGenerator_CodeOnly_v0.1.txt`：FormコードをVBEへコピーする場合の補助資料。
- `src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas`：P3-03 Gateに接続するApplication/UI Controllerの候補。
- `tests/modP3_04GateStub_v0.1_CP932.bas`：P3-03関数を模擬する隔離テスト用Stub。
- `tests/modP3_04FormCandidateTests_v0.1_CP932.bas`：非Production VBAテストRunner。
- `Docs/STATIC_REVIEW.py`と`STATIC_REVIEW_RESULT.md`：ソース構造の静的検査とその結果。**VBA Compile/実行ではない**。
- `Docs/Designer_Setup_and_Import_Limitations_v0.1.md`：固定Controlの作成と`.frx`制約。

## 2. 根拠となるApproved契約

- Approved `BL-MVP-004`：Requirements v0.1.9、Design v0.1.10、Test Specification v0.1.6、Implementation Plan v0.4。
- Design §17.1：Form Shell固定（Header/Guidance/InputArea/ErrorArea/作成・クリアButton）、**入力Controlだけ**動的生成。
- Design §17.2：Text/Date=1行TextBox、Select=自由入力不可ComboBox、有効OptionのSortOrder順。
- Design §17.3・§18.1：SortOrder→Table行順、`Control.Tag = VariableName`、Control名へVariableNameを組み込まない。
- Design §18.2～18.4：Input State復元/クリアは別責務。§25.2：UserFormの前にCurrent OFT再ScanとConfig Validation。
- Implementation Plan §8.4、Test Specification `MTS-UI-001～005`、`MTS-CFG-003`。**正式MTSテストは未実施**。
- P3-03 Gate Candidate v0.1：`PrepareUserFormLaunch(ByRef sortedActiveDefinitions As Collection, ByRef activeOptionsByGroup As Object) As COperationResult`。これは既存CandidateでありProduction契約として未承認。

## 3. Public API（候補）

```vb
' UI Application Controller
Public Function BuildMailGeneratorForm( _
    ByRef candidateForm As frmMailGenerator _
) As COperationResult

Public Function ShowMailGeneratorForm() As COperationResult

' frmMailGenerator CodeBehind
Public Function BuildValidatedInputs( _
    ByVal sortedActiveDefinitions As Collection, _
    ByVal activeOptionsByGroup As Object _
) As COperationResult
```

**制御順序**：Gate結果取得 → Result Nothing/Failureを検査 → Success時Carrier検査 → `New frmMailGenerator` → `BuildValidatedInputs` → 成功したFormだけ`Show vbModal`。Gate失敗では**Formを生成しない**。Build失敗時は`Unload`し、Form参照を公開しない。初期化後・表示後のMail送信は存在しない。

`BuildMailGeneratorForm`を分離した理由：Modal表示なしで隔離FixtureがControl構造を点検できるようにするため。実UI通知責務・起動Buttonイベントへの接続は未実装。`ShowMailGeneratorForm`のSuccessはフォームが閉じられたことまでであり、Mail生成成功を示さない。

## 4. Dynamic Controlの意味

| Row情報 | 描画 | 注意 |
|---|---|---|
| `DisplayName` | 動的Label | 長い文字列の表示崩れは実機評価待ち |
| `Required` | Trueなら`*`のLabel可視 | P3-01 CandidateのBoolean / 0・1 / 文字列True/Falseの解釈を暫定踏襲。**受容表現はOPEN** |
| `Type=Text` | 単一行TextBox | 入力検証・保持は未接続 |
| `Type=Date` | 単一行TextBox | Date形式確認は後続Input Validator、今回実装しない |
| `Type=Select` | `fmStyleDropDownList` ComboBox | `OptionSource`による厳密キー照合、既にGetActiveOptionsで並んだOptionをそのまま追加 |
| `VariableName` | 入力Controlの`Tag` | Control名は位置番号でありBusiness IDを含まない |
| `Description` | 動的Label | 任意、欠落は空欄扱い |
| `SortOrder`・`__RowIndex` | Formでは再ソートしない | P3-03から渡された順序を保つ |

`Row`とSelect Optionの全件を**Control追加前にPreflight**。予測可能なCarrier不整合はControl生成前にFailureにする。作成中の例外なら動的Controlを削除し、Controller側でFormを破棄する。`COperationResult.ErrorType`はCarrier異常時`UnexpectedError`を暫定採用（正式分類はOPEN）。

固定Buttonの`Enabled=False`を保持し、誤ってMail生成・Clear済みとみなされないようにした。`fraErrorArea`は固定Shellのみで、今段階ではエラーUIの集約表示を実装しない。

## 5. 隔離テストの対象と限界

`tests/modP3_04FormCandidateTests_v0.1_CP932.bas`はGate StubとFormを使い、**19シナリオ**を定義：上流Failure/Nothing、Carrier欠落・型異常、Control数、Tag、DisplayName/Description、Required表示、Option順、DropDownList/初期未選択、Text/Date単一行、空Variable、異常Type/Description/OptionSource/OptionValue、異なるFormの生成、同じFormの二重Build。

Test Stubは本物のP3-03と同名APIを提供するため、**同一VBA Projectへ混在禁止**。隔離VBA実行で実証できるのはStub契約経由のUserForm制御までであり、実P3-01/02/03の一体動作・COM接続・Excel環境・P3 Gate正式判定ではない。

`MTS-UI-001～004`の一部に対応するが、いずれも正式Test PASSではない。`MTS-UI-005`（実使用Variable数での操作性）は**実機手動確認待ち**。Selectに空白のActive `Value`が存在した場合の業務妥当性は現行Validatorの範囲外であり、今回新たな許容要件を創設しない。

## 6. OPEN事項・リスク

1. **P3-01から継続する4項目**：Requiredの受容表現、SortOrderの数値範囲、Carrier異常時Error分類、first-errorのみ返す運用。**未承認**。
2. **Module Mapping**：`modP3UserFormLaunchGate`、`modConfigurationApplication`、今回`modP3UserFormController`を独立配置するか、既存`modUiController`へ統合するか**未承認**。既存P2-05 Controllerは変更しない。
3. **UserForm Designer資産**：`.frm`はテキストCandidateであり、`.frx`正規Export無し。VBE Import／保存／Compile可能性は**未検証**。別文書にDesigner再構築手順を記載。
4. **表示**：固定高さ・ラベル幅・Scrollbar・高DPI・多数Variable・長いDescriptionの実機操作性は**未検証**。
5. **Input State**：値保持・再表示復元・Clear操作は未実装。Mail生成、入力Validation、ErrorArea連動も未実装。Button Disabled。
6. **OptionValue**：現行Data AccessはActive候補値が空文字であること自体を拒否しない。空白項目の業務上妥当性は今Unitでは判断しない。
7. **Gate自己完結性**：Formの`BuildValidatedInputs`はPublicなので、外部から直接呼べばGateを迂回できる。**実接続Controllerの呼出経路に対するGate保証**であり、VBA Project全域の呼出制約証明ではない。正式採用時に公開範囲を再評価。
8. **Manual Sync/P2**：P2-05 Production変更無し、P2 Closure未成立、S5-C正式Gate・最終Build Compile・隔離方式採用は未承認。

## 7. 静的チェック・次の判定

`STATIC_REVIEW_RESULT.md`参照。CP932ファイル・API署名・処理順序・禁止依存・Fixture件数の検査であり、コンパイラ・実描画・VBA実行・バインディングを保証しない。

**次工程（準備候補）**：P3-04のCode Review/Designer整合レビュー → Approved環境と別途承認された実機でForm作成/Compile/Runtime Fixture → 操作性確認 → Module Mapping・P3-01 OPEN事項の決定。P2正式ClosureとP3正式Phase開始は個別Gateが必要であり、候補作成によって自動成立しない。

## 8. Project保存先（提案、GitHub未保存）

- `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`: Form `.frm`／code-only補助／Controller `.bas`
- `MailGenerator/tests/vba/P3_Configuration_UserForm/`: Stub、Runner
- `MailGenerator/Docs/00_project_control/reviews/`: 本レビュー、Designer/Import制約、静的チェック記録

## 9. まとめ / Summary

**日本語**：P3-03 Gate成功後だけ動的Controlを作る最小Form/Controller候補を作成した。実機Import・Compile・Runtime・UI表示は未実施で、P3正式開始ではない。

**English**: We created a basic UserForm and controller candidate. It builds inputs only after the gate succeeds. We did not import, compile, run, or show the form. P3 has not formally started.
