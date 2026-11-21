# P3-04 × P3-05 Input State接続仕様 Candidate v0.2

| 管理項目 | 内容 |
|---|---|
| Document ID | P3-04-P305-INTEGRATION-DESIGN-CANDIDATE |
| Revision / Status | **v0.2 / WORKING CANDIDATE・NOT APPROVED** |
| 作成・更新日 | 2026-11-21 |
| 対象Baseline | BL-MVP-004（変更なし） |
| 上位参照 | DOC-MVP-REQ v0.1.9 §19、DOC-MVP-DES v0.1.10 §17–18/§25.2、DOC-MVP-TESTSPEC v0.1.6 MTS-INPUT-001/002、DOC-MVP-IMPL v0.4 §6・§8.4 |
| 入力となる候補 | P3-04 XU-01+XU-02 A案 Form、P3-05 `modInputState` v0.1 |
| 位置付け | **実装接続仕様案のみ。VBAソース変更／承認は行わない。** |

## 1. 目的・スコープ・完了条件

目的：XU-01のGate強制・XU-02の表示用Scalarコピーを維持し、P3-05 Input Stateの保存・復元・ClearをUserFormへ接続するための責務とFailure経路を具体化する。

**In Scope**：Form再表示時の復元、終了時Capture、Clear、未選択Select、Result伝播、キー同一性、同一Workbook Session、テスト計画。**Out of Scope**：接続コードの改変、実機、フォームDesigner資産、メール生成、P4 Validation、外部永続化、P2 Closure、P3正式開始、GitHub変更。

完了条件：既承認契約とSourceを確認し、実装可能なフロー、未決事項、Quality Gateを記録すること。**ここで新しい仕様判断を承認済みとして扱わない。**

## 2. 既承認事項と候補の区分

| 項目 | 状態／根拠 |
|---|---|
| Workbook Session内Dictionary、Case Insensitive、TagによるBinding、Store＋画面Clear | Approved Design §18.1–18.4 |
| P3-05 `SetInputValue` / `TryGetInputValue` / `ClearInputValues`、生文字列String | **ユーザー承認済み：P3-04接続Candidate限定**。Production採用ではない |
| XU-01 A案：公開BuilderでP3-03 Gate強制 | **ユーザー承認済み設計**。Runtime NOT VERIFIED |
| XU-02 A案：Form Private Renderer側でScalarコピー | **ユーザー承認済み設計**。修正Candidate作成済み、Runtime NOT VERIFIED |
| 終了時Capture・閉じる経路・Clear後Close・Select失効値の扱い | **未承認／本設計案** |
| P3-04 XU-01+XU-02 Formの実Source | `BuildValidatedInputs()`はGate→全行Optionコピー→`BuildInputsFromSnapshot()`。保存・復元・Closeイベント・Clearは未実装 |
| P3-05実Source | 3 APIのメモリStore。空文字Keyと未登録Keyを区別し、Setは1キーずつ更新する |

## 3. Candidate公開境界（追加Public APIを原則増やさない）

```vb
' Current P3-05 API — APPROVED FOR INTEGRATION CANDIDATES ONLY
Public Function SetInputValue( _
    ByVal variableName As String, _
    ByVal inputText As String) As COperationResult
Public Function TryGetInputValue( _
    ByVal variableName As String, _
    ByRef hasValue As Boolean, _
    ByRef inputText As String) As COperationResult
Public Function ClearInputValues() As COperationResult

' Current P3-04 public API; XU-01 gate forced inside the form
Public Function BuildValidatedInputs() As COperationResult
```

Form固有の`RestoreInputsFromState`、`CaptureInputsBeforeClose`、`ClearDisplayedInputs`、`SnapshotInputControls`は**Private Sub/Function候補**であり、Public API確定ではない。`modInputState`にMSForms/Excel/Outlook依存を追加しない。Formの`Control.Tag`をVariableNameの唯一のBindingキーとし、Text/Dateは`TextBox.Value`、Selectは`ComboBox.ListIndex`を使う。

## 4. Form生成から再表示復元まで（提案）

```text
Controller → New frmMailGenerator
  → Public BuildValidatedInputs()  [XU-01：新FormごとにP3-03 Gate]
    → PrepareUserFormLaunch()     [Gate/Current OFT Scanを1回]
    → CreateDisplaySnapshot()     [XU-02：全Row・参照Option文字列コピー]
    → BuildInputsFromSnapshot()   [動的Control生成]
    → RestoreInputsFromState()    [P3-05へTagごとに取得]
    → mBuilt=True                 [全Controlと復元が成功した場合のみ]
  → SuccessかつForm有効時に `.Show vbModal`
```

既存Formは`BuildInputsFromSnapshot`末尾で`mBuilt=True`を立てるため、**復元を追加する実装時はこれを復元Success後へ移動する**必要がある。復元Failureでは、生成したControlを削除、`mBuilt=False`に戻し、Successを返さない。`UserForm_Activate`の未構築Hideガードを維持する。

- `TryGetInputValue`はControlの非空`Tag`で呼び出す。`Result Is Nothing`、`Success=False`ならForm生成Failureにする。
- `hasValue=False`はText/Date空文字・Select未選択。`hasValue=True, inputText=""`も空欄・未選択だが、Store側の「明示的な空文字」は勝手に削除しない。
- Text/DateはRaw Stringをそのまま`.Value`へセット。日付変換やRequiredチェックは行わず、P4へ残す。
- Selectは`ListIndex=-1`で初期化。保存値に一致するActive Optionがあるときのみ、その選択肢を選ぶ。**先頭Optionへの黙示的Defaultは禁止**。
- Select `Value`の大小文字区別／失効値通知／Store更新は**D-SEL-STALE（未決）**。OptionGroup `vbBinaryCompare`の既存契約と混同しない。
- 復元でCurrent OFTの再Scanや`PrepareUserFormLaunch()`の再呼出しを行わない。

## 5. Form終了と保存（提案・要承認）

**推奨案：対応対象の通常終了（X）および管理下の`Unload`で`UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)`を一次Capture入口とする。** Form非構築時は保存しない。`CloseMode`とControllerの`Unload`経路を組み合わせて**二重Captureを防ぐ状態フラグ**を設ける。未対応の直接`.Hide`はCallsiteを禁止・監査する（`QueryClose`は直接`.Hide`を捕捉しない）。

```text
QueryClose (mBuilt=True & save not yet completed)
  → TextBox/ComboBoxだけをTagで抽出。Labelは除外
  → 全件Preflight：Tag非空、Case Insensitive重複なし、値読取可能
    → Select ListIndex=-1なら必ず "" とする（.Valueを仮定しない）
  → Preflight OK後、P3-05 SetInputValue(Tag, rawString)を順次呼出
    ├─ 全件Success → Close許可、保存済フラグをセット
    └─ 1件でもFailure / Result Nothing → Cancel=True、ErrorAreaで通知しFormを残す
```

保存は**1キー単位で非原子的**である。入力値を全部PreflightしてもStore更新途中の技術Failureが起きた場合、先行Keyだけ更新され得る。既承認APIは変更しないので、失敗時は閉じず、再試行で同じ全件を上書きする方針を候補とする。**「Store全件Rollback可能」とは主張しない。**

**Closeイベント境界：** `QueryClose`で捕捉できる`CloseMode`と、Workbook終了時に`Cancel=True`が実際に守られるかは実機NOT VERIFIED。`UserForm_Deactivate`だけに保存を依存しない。Controllerの`.Show`復帰後`Unload`は重複保存やFailureを隠さないよう、終了状態と二次Cleanupを検査する。Controlを手動で`Hide`すると保存が失われるため、UIの正式出口に採用しない。

## 6. ClearでStoreと画面を同時消去（提案・要承認）

```text
cmdClear_Click（mBuilt=Trueのときのみ有効）
  → 対象Control（TextBox / ComboBox）を全件Preflight
  → ClearInputValues()を呼ぶ
    ├─ Failure / Nothing → 画面を変更せずErrorArea通知
    └─ Success → 全TextBoxを ""、全ComboBoxをListIndex=-1
                → 全Control正常なら「Clear完了」＋mExplicitClearSucceeded=True
                → UI変更に失敗した場合は部分クリアを警告し画面維持
```

**新たに発見した結合リスク：** P3-05のClearはStoreキーをすべて削除する。一方、終了時の`SetInputValue`で全空欄Controlを保存すると、空文字のKeyが再び作られる。すると`TryGetInputValue`は`hasValue=True`となり、Design §18.4の「辞書もクリア」と意味上の不整合が発生する。

**AI推奨の条件付き仕様**：`mExplicitClearSucceeded=True`かつ閉じる際にすべての入力Controlが空／未選択なら、QueryCloseでは保存をスキップし、空のStoreを維持する。Clear後にいずれかを入力した場合は、全Controlを通常Captureし、入力した値と他Controlの空文字を保存する（Clear後の新入力による再保存）。Clearしていない通常の手動全消去は、空文字を明示値として保存する。これは**未承認のImplementation Detail**である。

Core Clearが成功した後でUI Controlのクリアに失敗した場合は、Core/UI間の部分不一致を起こし得る。補償・再試行・報告を実機確認するまでは、**Clear操作全体の原子性を保証しない**。前のUI値を採取していたとしても完全なRollbackが成立するとの主張は避ける。

## 7. Select失効値（未決）

**AI推奨案（未承認）：** Current Active Optionsに一致しない保存Valueがある場合は、勝手に別Valueへ切り替えず、`ListIndex=-1`で未選択表示とし、`ErrorArea`に対象VariableNameと「以前の選択肢が現在は無効」を明示する。既存P3-05 Storeは承認されるまで**書き換えない**。ユーザーの新選択・次回の保存方針は別判断。

OptionGroup照合のCase Sensitiveルールは従来どおり。Option Valueの比較方式はD-SELECT-CASEとして明示判断が必要。

## 8. 検証観点と接続時のQuality Gate

| Gate | 完了条件 | 今回判定 |
|---|---|---|
| IG-01 | P3-03 Gate失敗で復元・Form表示を実行しない | SOURCE PATH / 将来Runtime未実施 |
| IG-02 | コピー・Control生成・復元が全成功した後だけ`mBuilt=True` | **NOT IMPLEMENTED** |
| IG-03 | 同一Workbook SessionでRaw Text/Date/SelectをTagで復元 | **NOT IMPLEMENTED** |
| IG-04 | 通常Closeの前に全件Preflight／保存、保存Failureは`Cancel=True` | **NOT IMPLEMENTED** |
| IG-05 | `.Hide`経路を禁止し、ControllerのUnloadで二重Captureを起こさない | **NOT VERIFIED** |
| IG-06 | Clear時、Storeと画面が両方空になる | **NOT IMPLEMENTED** |
| IG-07 | Clear→何もせずCloseでStoreが空を維持 | **DECISION REQUIRED** |
| IG-08 | Select失効値は勝手に選択しない・方針を明示 | **DECISION REQUIRED** |
| IG-09 | P3-05が文字列Store／Case Insensitive／無永続化を維持 | **SOURCE MATCH / Runtime未実行** |
| IG-10 | Workbook Close/Reopenで前Sessionの値を復元しない | **NOT VERIFIED** |
| IG-11 | XU-01 Gate・XU-02 Private Snapshotに回帰がない | **SOURCE MATCH / Runtime未実行** |
| IG-12 | 失敗時のStore部分更新とUI不整合を確認し、重大問題を隠さない | **NOT VERIFIED** |

将来の正式Test追跡：MTS-INPUT-001（再表示・Workbook再起動）、MTS-INPUT-002（辞書と画面双方Clear）。いずれも**今回実施していない**。接続候補を作る場合の隔離FixtureではStub/実P3-03 Public名重複に注意する。

## 9. 変更管理・未決事項

| ID | 状態 | 対象／AI案 | 承認後の影響 |
|---|---|---|---|
| D-UI-CLOSE | **OPEN** | QueryCloseでCapture・正常時閉じる・Failure時Cancel・直接Hide禁止 | P3-04 Form／Controller／テスト追加 |
| D-UI-CLEAR | **OPEN** | Store成功後画面Clear。Clear後Close時は全空なら再保存しない | P3-04 Form／Clearボタン／テスト追加 |
| D-SEL-STALE | **OPEN** | Select失効値は未選択＋通知、Storeは即時改変しない | P3-04復元／ErrorArea／テスト追加 |
| D-SELECT-CASE | **OPEN** | Option Value照合大小文字規則の具体化 | P3-04復元／テスト追加 |
| D-COMMIT | **OPEN / CONSTRAINT** | 既承認3 API維持、全件原子性なし／Failure時再試行 | P3-04保存UIのError処理 |
| XU-06 | **OPEN** | Controller独立Moduleの採用可否 | 正式Module Mapping判断 |
| XU-01/02 | **SOURCE CANDIDATE** | Gate強制・Scalar SnapshotのRuntime証拠不足 | 実機Gate／正式採用判断 |

**この文書の記載によってOPEN項目が自動承認されることはない。**

## 10. 次の一問（推奨）

**まずD-UI-CLOSEを判断する。** 既承認APIとXU-02差分を変更せず、QueryCloseを正常Closeの単一Capture入口とし、管理外Hideを禁止する案を推奨する。ClearとSelect失効値は、その後個別判断する。
