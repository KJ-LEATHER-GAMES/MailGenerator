# T1 XU-01 Direct Show Regression Finding Review v0.1

| 項目 | 内容 |
|---|---|
| Document ID | DOC-REV-P304-P305-T1-XU01-SHOW |
| Revision | v0.1 |
| 作成日 | 2026-11-22 |
| Status | REVIEW / BLOCKED (Runtime evidence received) |
| 対象 | T1 Nominal隔離Workbook、P3-04 XU-01/XU-02回帰Fixture |
| Approved Baseline | BL-MVP-004（変更なし） |
| Production/GitHub変更 | なし |

## 1. 実測の整理

- T1 Import / Compile：COMPILE_PASS（既存 Evidence v0.2）。
- T1 P3-04×P3-05 Nominal：PASS=21、FAIL=0（既存Runtime Evidence）。
- 回帰：PASS=33、FAIL=2、全35件を実行。提供されたログとスクリーンショットで集計一致。
- FAIL：`DEV-P3FORM-DIRECT_SHOW_UNBUILT`、`DEV-P3FORM-DIRECT_SHOW_AFTER_FAILURE`。
- PASS：`DEV-P3FORM-DIRECT_SHOW_AFTER_SUCCESS`、`SOURCE_ROW_MUTATION`、`SOURCE_OPTION_MUTATION`など。
- 同時に、テスト用Module `modTESTONLY_ModQueryClose_Smoke` の存在を画面で確認。前回の `Module1` 疑義は表示名の更新により解消。

## 2. 原ソース突合と仮説

対象Runner：`modP3_04XU02Tests_v0.1_CP932.bas` の `CheckDirectCase`。

- `DIRECT_SHOW_UNBUILT`：`ConfigureP304Stub "MIXED"`、未構築Formを `Show vbModeless` 後に `(Not frm.Visible And P304GateCalls=0 And InputControlCount=0)` を判定。
- `DIRECT_SHOW_AFTER_FAILURE`：`ConfigureP304Stub "FAIL"` → `BuildValidatedInputs()` → 上流Result同一性確認 → `Show vbModeless` 後に `(Not frm.Visible And P304GateCalls=1)` を判定。
- 両方とも `CheckDirectCase` 内 `On Error GoTo TestFailed` のため、表示中/評価中の例外も原因をログ化せずFALSEとして返す。
- Formの `UserForm_Activate`: `If Not mBuilt Then Me.Hide`。このコードがVBE Runtimeでどのタイミングで呼ばれたか、Hideが有効だったかは不明。

**結論**：Direct Showガードに関わる2件の実測Failure。テストの偽陰性・イベントタイミング・実装ガードの不足のいずれかを現時点では断定できない。XU-01 Closureは不可。

## 3. 次の診断（Production/Candidateを変更しない）

1. 現状のT1 Workbookを保存し、作業用コピーを作成する。
2. `modTESTONLY_XU01ShowDiag_v0.1_CP932.bas` を **T1コピーに限り** VBE > File > Import File から追加。`modP3_04GateStub`が存在することを確認。本物のP3-03は同居させない。
3. VBE > Debug > Compile VBAProject。失敗時は以降を停止してエラーを記録。
4. VBEで `frmMailGenerator` のコード画面を開き、`UserForm_Activate` の `If Not mBuilt Then Me.Hide` にブレークポイントを設定（F9）。
5. `Alt+F8`から `RunTESTONLY_XU01_ShowDiagnostics` を実行（または VBEで当該Sub内からF5）。ブレークした場合、`mBuilt`、`Me.Visible`、イベント発火回数、F8でのHide結果を確認する。継続後もテストが進むため、必要に応じブレークポイントを解除する。
6. イミディエイトの `BEFORE_SHOW`、`SHOW Err.Number`、`IMMEDIATE_AFTER_SHOW`、`AFTER_DOEVENTS`、`GateCalls` とスクリーンショットを保存。
7. 2件以外のテストは再実行しない。直接Hide/Xボタン手動試験、T2、T3は診断完了まで保留。

診断Moduleは追加ログ採取のみ。テスト結果をPASSへ上書きしない。

## 4. 判断条件

| 観測結果 | 次の判断 |
|---|---|
| `UserForm_Activate`が呼ばれない／DoEvents後に呼ばれる | 表示イベントの発火タイミングとガード保証を再設計するか判断。すぐにテスト期待値を変えない |
| Activateが呼ばれるが `Hide` 後も Visible=True | Form側ガードの実装Finding。設計修正Candidateを別途検討 |
| Show／Visible読出しでErr.Numberが非ゼロ | エラー番号・メッセージを基にVBAイベント処理を調査 |
| 即時のみVisible=TrueでDoEvents後False | タイミング依存テストと瞬間表示リスクを区別して扱う。正式な「表示しない」保証は別途検証 |
| 診断では両方False、元回帰のみFAIL | Runnerの判定条件と実環境差・連続実行の状態依存を再検証 |

## 5. 進捗とGate

| 対象 | 状態 |
|---|---|
| T1構築 | COMPLETED |
| T1 Compile | PASS |
| T1 Nominal 21/21 | PASS |
| T1 回帰 33/35 | BLOCKED、Finding OPEN |
| Direct Hide / Xボタン手動 | NOT STARTED |
| T2/T3 | NOT STARTED |
| XU-01正式Closure | NOT VERIFIED／REVIEW_REQUIRED |
| XU-02正式Closure | REVIEW_REQUIRED（回帰対象PASSでも全体Gate未通過） |
| P3正式開始、Production採用、GitHub/Baseline変更 | なし |

T1主要5工程のうち3工程完了。自動テストは56/56実行、54 PASS・2 FAIL（PASS割合96.4%。これは完了率ではない）。

## 6. Decision / Issue / Risk

- Finding `T1-XU01-DS-001`：Direct Show未構築時／Gate Failure後の非表示期待に2件FAIL。Status OPEN、Blocking（XU-01 verification）。
- Decision：実装修正方針は未決。まず実測診断する。Approved XU-01 A案を黙って変更しない。
- Risk：UserForm intrinsic `.Show` と `UserForm_Activate` 内 `.Hide` では、画面描画の瞬間的露出も含めた遮断をコード静的検査だけでは証明できない。

## まとめ / Summary

日本語：回帰35件は33 PASS、2 FAIL。2件ともXU-01直接表示ガードに集中したため、Runtime診断を優先し他工程は保留する。Production/ GitHub/ Baselineの変更なし。

English: Regression tests passed 33 of 35 cases. Two direct-show tests failed. Diagnose the form display event before changing code. Production, GitHub, and the baseline are unchanged.
