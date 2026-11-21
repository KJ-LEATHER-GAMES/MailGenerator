# P3-04 XU-01 Gate迂回防止 A案 ― 最小修正Candidateレビュー v0.1

| 項目 | 内容 |
|---|---|
| Document ID | P3-04-XU01-REVIEW |
| Revision | v0.1 |
| 作成日 | 2026-11-21 |
| Status | **WORKING CANDIDATE / REVIEW_REQUIRED** |
| 親Decision | **XU-01 A案：ユーザー承認済み**（本会話） |
| Implemented Artifact | **未承認・未適用**のP3-04 Candidate修正 |
| Execution Baseline | BL-MVP-004（Approved、変更なし） |
| 関連文書 | DOC-MVP-REQ v0.1.9 / DOC-MVP-DES v0.1.10 / DOC-MVP-TESTSPEC v0.1.6 / DOC-MVP-IMPL v0.4 |
| 先行レビュー | `P3-01_to_P3-04_Cross_Unit_Source_Review_v0.1_20261121.md`、XU-01 |

## 1. 目的・今回の完了条件

- **目的**：P3-04 Form公開構築メソッドへの直接呼出しでP3-03 Gateが迂回されるリスクを減らし、未検証Formを直接`.Show`しても操作可能状態に残さない。
- **Scope**：`frmMailGenerator`と`modP3UserFormController`の最小変更、隔離Stub/Runner、静的レビュー。
- **Out of Scope**：P3-01/02/03 Candidate変更、P2-05 Production、GitHub、Baseline、Excel/VBE/Outlook実行・環境調査、P2 Closure/S5-C/P3正式開始、Input State、メール生成。
- **この作業の完了**：修正Candidate・Patch・テストFixture作成、ソース整合静的確認、残存リスクの記録。**Production採用・XU-01正式Closeとは別**。

## 2. 承認された判断と変更管理

**承認済みの設計方針**：A案。Formの公開構築入口自体が`PrepareUserFormLaunch`を実行し、成功したCarrierだけをPrivateレンダラへ渡す。ControllerはFormを先に生成し、ビルド成功後のみForm参照を返し、表示する。Current OFT再Scanは既存P3-03呼出経路内で1回とする。

**このCandidateの技術実装・テスト結果をユーザーが承認したことにはならない。**

| 対象 | 変更前 | 変更後（Candidate） | 理由・影響 |
|---|---|---|---|
| Formの公開API | `BuildValidatedInputs(Collection, Object)` | `BuildValidatedInputs() As COperationResult` | 呼出元から任意Carrierを渡せない。既存Callsiteに破壊的変更 |
| Gate呼出 | `modP3UserFormController` | `frmMailGenerator.BuildValidatedInputs` | 全公開Build経路でGateを通す |
| Control生成 | FormのPublic Builderが直接実行 | Private `BuildInputsFromGate(Collection, Object)` | Rendererへの外部直接呼出しを防止 |
| インスタンス生成 | Gate成功後 | Gate呼出し前 | Gate Failure時も一時Form Objectは生成されるが**表示しない** |
| Display Guard | なし | `UserForm_Activate`で`Not mBuilt`なら`Me.Hide` | 直接`.Show`による未構築Form残留を抑止。瞬間的描画は未検証 |
| Errorの扱い | ControllerがP3-03 Failureを返却 | FormがP3-03 Failureオブジェクトを保持して返却し、Controllerが維持 | Failure伝播・一次Error優先は変更しない |
| 二重Build | Formの`mBuilt`を確認 | 同条件＋`mBuildInProgress`ガード | 再入／二重Gateを防御 |

**無変更**：固定Designer Shell、Text/Date=単一行TextBox、Select=選択専用ComboBox、Control.Tag、Required、Description、Scroll、ボタン無効、Option表示順、`COperationResult`、P3-03 Public Signature。

## 3. 実装境界とFail Closed

```text
Public frmMailGenerator.BuildValidatedInputs()
  |-- mBuilt / mBuildInProgress guard
  |-- PrepareUserFormLaunch(sortedDefinitions, optionGroups)   ← P3-03
  |       |-- P3-02 PrepareCurrentConfiguration → P3-01 Validation
  |       '-- Current OFT Scan once (same pre-existing flow)
  |-- Result Is Nothing       → UnexpectedError / do not build
  |-- Result.Success=False    → return same COperationResult / do not build
  |-- Result.Success=True but outputs missing/malformed → UnexpectedError
  '-- Private BuildInputsFromGate(sortedDefinitions, optionGroups)
          |-- all-row preflight
          |-- add dynamic controls
          '-- mBuilt=True only after success

Controller.BuildMailGeneratorForm()
  |-- New frmMailGenerator (fixed shell only)
  |-- Form.BuildValidatedInputs()
  |-- failure → Unload, output Nothing
  '-- success → publish form
Controller.ShowMailGeneratorForm()
  '-- success path only → .Show vbModal

Direct frmMailGenerator.Show (without successful BuildValidatedInputs)
  '-- UserForm_Activate → If Not mBuilt Then Me.Hide
```

### Fail Closedと例外

- Gate Failureは**同一の`COperationResult`インスタンス**で返却し、`CErrorInfo`を再生成しない。
- Gateが`Nothing`を返す、SuccessでCarrierが不足している、Carrierの型が違う場合は`UnexpectedError`。
- Privateレンダラでの異常時は動的Controlを削除し、`mBuilt=False`を維持する。
- 成功時以外はControllerがFormの参照を公開せず、`.Show`にも進まない。
- `UserForm_Activate`ガード自体はGateを再実行しない（直接`.Show`はHideするのみ）。

**重要な限界**：VBA標準の`UserForm.Show`はオーバーライドできない。`UserForm_Activate`で`Me.Hide`しても、イベント実行前に**一瞬のウィンドウ描画が起きないことまではソースだけで保証できない**。現時点で証明できるのは、Formの正規公開BuilderがGateを迂回できないというソース構造、および表示ガードの実装存在である。「完全に表示されない」はVBE実機検証前にPASSと判定しない。

## 4. 互換性とCaller影響

- P3-04の旧`frmMailGenerator.BuildValidatedInputs(sortedDefinitions, optionGroups)`呼出元は**非互換**。Controllerと隔離Runnerは新APIへ更新済み。
- P3-03 `PrepareUserFormLaunch(ByRef Collection, ByRef Object)`契約は維持。
- P3-01/02/03は変更なし。XU-03（SortOrder）、XU-04（Cleanup診断）の先行Patchも**今回採用しない**。
- `modP3UserFormController`の独立Module採用はXU-06として未決。既存`modUiController`へ統合しない。
- P3-03が返すCollection/Dictionaryの参照共有はXU-02のまま。今回のA案はSnapshot不変性を解決しない。

## 5. テストFixture / 観測条件

テストRunner：`RunP304FormCandidateTests`、**27ケース**（旧19件＋新8件）。隔離VBA Project用。ここでは**1ケースも実行していない**。

| 開発テスト | 対象の期待結果 |
|---|---|
| 旧19ケース | Gate Failure、結果欠落、Carrier破損、3種Control、Tag/補助情報/Option順、重複Buildなどの継続 |
| DIRECT_BUILD_SUCCESS | Controllerを介さないBuilderでGateが1回、構築Success、12 Control |
| DIRECT_BUILD_FAILURE | Gate Failureが同一Resultで返却され、Control 0 |
| DIRECT_BUILD_NIL_RESULT | GateがResult NothingならFailure、Control 0 |
| DIRECT_BUILD_BAD_ROWS | Gate SuccessでもRows NothingならFailure、Control 0 |
| DIRECT_BUILD_BAD_OPTION | Gate SuccessでもOption値不正ならFailure、Control 0 |
| DIRECT_SHOW_UNBUILT | 直接モデルレス`.Show`した未構築Formが非表示、Gate呼出0、Control 0 |
| DIRECT_SHOW_AFTER_FAILURE | Gate Failure後の直接`.Show`が非表示、追加Gate呼出なし |
| DIRECT_SHOW_AFTER_SUCCESS | Builder成功後の直接モデルレス`.Show`は表示可、Gate呼出1 |

VBA Runtime確認時は、`frmMailGenerator`を**Designer付きUserFormとして**用意し、テストStub `modP3_04GateStub`と実P3-03 `modP3UserFormLaunchGate`を**同一VBA ProjectへImportしない**。後続の統合検証ではStubを外し、実P3-01/02/03を接続し直す。

### 静的検査

`STATIC_REVIEW_RESULT_XU01_A.json`参照：**46/46 PASS**。検査対象はソース構造、Gate呼出位置、Controller呼出順、前後Carrier・Error伝播、VBAソースのバランス、27ケース定義、オリジナルP3-04ソースに対するPatch適用テスト（UTF-8正規化コピーと**実際のCP932・CRLF元ファイルの使い捨てコピー**）。

**PASS対象外：** VBE Import / Compile、Microsoft Formsイベント挙動、フォーム描画、実際の`.Visible`、Outlook Scan回数、27件のVBA実行結果、UIアクセシビリティ・表示のちらつき。

## 6. Issue / Risk Log

| ID | 内容 | Status | 対応 |
|---|---|---|---|
| XU-01 | 公開Form BuildがGate迂回できる | **A案承認／修正Candidate作成済み／実機未検証** | 現コードのソース上経路を確認。実機Runtimeで`DIRECT_*`ケース確認までCLOSE不可 |
| XU-01-R1 | 直接`.Show`における描画前完全遮断の保証なし | **OPEN / NOT VERIFIED** | `UserForm_Activate`抑止の実挙動・ちらつき・Modal/Modelessを実機確認 |
| XU-02 | P3-03が参照共有するSnapshotの不変性 | **OPEN** | P3-05統合前の別判断 |
| XU-03 | SortOrder `CDbl`受容差 | **PATCH CANDIDATE / 未適用** | 先行Patchを別途判断 |
| XU-04 | 二次Cleanup Failure診断 | **PATCH CANDIDATE / 未適用** | 先行Patchを別途判断 |
| XU-05 | テストStubが実P3-03公開APIと同名 | **CONTROLLED / 混合Import禁止** | Unit別隔離Fixtureのみ使用 |
| XU-06 | 追加ModuleのMapping承認 | **OPEN** | P3全体のProduction採用前に決定 |
| XU-07 | `.frm/.frx` / VBE / Compile未確認 | **NOT VERIFIED** | 後続Gateへ引き継ぐ（今は実機・環境調査しない） |
| P3-01-OPEN | Required、SortOrder、Carrier分類、first-error方針 | **OPEN** | 今回変更しない |

## 7. Quality GateとDecision Log

| Gate | 判定 | 根拠 |
|---|---|---|
| XU-01 A案の設計承認 | **APPROVED** | ユーザーが本会話で承認 |
| A案に一致する実装Candidate作成 | **PASS（ソース上）** | Form公開API移動、Controller簡素化、イベントガード |
| Source Static Check | **PASS 43/43** | JSON記録、Patch適用検証 |
| VBA Compile | **NOT VERIFIED** | 実機未使用 |
| Direct `.Show` 実行防止 | **NOT VERIFIED** | Fixture定義のみ。実描画前抑止の確証なし |
| XU-01正式Closure | **REVIEW_REQUIRED** | VBA Runtime / 直接Show Evidenceなし |
| P3-04 Production採用 | **REVIEW_REQUIRED** | Module Mapping等の未決事項を含む |
| P2 Closure / S5-C / P3 Phase開始 | **UNCHANGED / NOT APPROVED** | 今回の対象外 |

## 8. 保存先（推奨、実際のGitHub保存なし）

- Form／Controller修正Candidate：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Stub／Runner：`MailGenerator/tests/vba/P3_Configuration_UserForm/`
- レビュー文書・静的Evidence：`MailGenerator/Docs/00_project_control/reviews/`
- 本配布パッケージは既存正本を上書きしない。`CP932_CRLF_Apply` Patchは旧P3-04候補3件の**実ファイル文字コード・改行のまま**適用できることを確認済み。`UTF8_Normalized_Review_Diff`は閲覧用の正規化差分であり、元のCP932ファイルへ直接適用するものではない。**Approved仕様へ適用するPatchではない**。

## 9. 次アクション

1. P3-04 XU-01 A案Candidateに対するCode Review（承認された設計との差分確認）。
2. P3-05 Input Stateの**独立仕様準備**は可能。Formとの正式統合はXU-02 / XU-06等の判断後とする。
3. 実機利用可能かつ別途承認があるときのみ、VBE Import／Compile／27ケース／`.Show` Modal・Modelessの表示抑止を確認。
4. Runtime Evidenceを得るまではXU-01を**未Close**とし、Production・Baselineの変更を行わない。

## まとめ / Summary

**日本語**：XU-01 A案に基づくForm Gate内製化・直接`.Show`抑止の最小修正候補を作成した。静的46件PASSだが実機検証なし。設計承認と実装採用を明確に区別し、XU-01は正式Closeしていない。

**English**: We made an XU-01 Option A code candidate. The form checks the gate before building controls. A direct show of an unbuilt form is guarded. All 43 static checks passed, but VBA tests were not run. XU-01 is not formally closed.
