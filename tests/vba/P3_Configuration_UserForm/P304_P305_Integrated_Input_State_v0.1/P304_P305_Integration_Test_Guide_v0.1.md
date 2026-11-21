# P3-04 × P3-05 Input State Candidate — Test Fixture / Execution Guide v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | P304-P305-INT-TESTS |
| Revision / Status | v0.1 / WORKING, NOT EXECUTED |
| Execution Baseline | BL-MVP-004 (unchanged) |
| Date | 2026-11-21 |
| Requirement traceability | FR-INPUT-001/002, DOC-MVP-DES §18, MTS-INPUT-001/002 |

## 1. Import前提（必須）

**このパッケージをProduction Workbookへ直接Importしないこと。** Test Workbookは開発用途で独立し、元Projectと取り違えないようにする。

- 共通: `COperationResult`, `CErrorInfo`, `modResult` の既存P0実装、`frmMailGenerator`, `modP3UserFormController`, `modP3_04GateStub`。
- **Nominal Test Workbook（実P3-05）**: 上記＋`modInputState`（src配下の無変更候補）＋`modP304P305NominalTests`＋旧`modP3_04XU02Tests`。`modP305FaultInjectionStub`はImport禁止。
- **Fault Workbook（P3-05をStubで代替）**: 共通＋`modP305FaultInjectionStub`＋`modP304P305FaultTests`。実`modInputState`はImport禁止。
- いずれのWorkbookでも実P3-03（本物の`PrepareUserFormLaunch`）と`modP3_04GateStub`を同時Import禁止。
- `.frm` Designer Exportだけを配布。`.frx`は未作成。実際のVBEのImport／Compileの可否は未確認。`frmMailGenerator`を新規作成・Designerを手作業で整備した場合も、その事実をEvidenceに記録する。

## 2. テストRunner

- Nominal（実InputState）: `RunP304P305NominalCandidateTests` — **21ケース**。
- 旧XU-01/XU-02回帰: `RunP304XU02CandidateTests` — **35ケース**。Nominalと同じWorkbookで実行可能な候補だが、終了時QueryClose追加後の動作は未検証。
- Fault（置換InputState）: `RunP304P305FaultCandidateTests` — **9ケース**。
- **計63ケースは定義済みだが、実行0件**。Debug.PrintのPASSは実行した場合の出力予定であり、現時点のEvidenceではない。

## 3. ケース概要

| Suite | ケース群 | 主に検証する挙動 |
|---|---|---|
| Nominal | RESTORE_* | 生文字列復元、未登録と空文字、大小文字キー |
| Nominal | STALE_SELECT / STALE_CLOSE_EMPTY / SELECT_CASE | 失効未選択＋警告、Option Value完全一致 |
| Nominal | CLOSE_* / PREFLIGHT_* | QueryClose前Capture、Select未選択、Tag重複・空欄Failure |
| Nominal | CLEAR_* | Store/UI Clear、全空Closeスキップ、再入力、手動空欄保存 |
| Nominal | SINGLE_GATE / SCALAR_ISOLATED / GATE_FAILURE / UNBUILT_NO_SAVE | XU-01/XU-02回帰 |
| Fault | RESTORE_GET_* | Result Failure／NothingでForm Build失敗 |
| Fault | SAVE_* / NO_DOUBLE_SAVE | 逐次Set途中Failure／Nothing／全件再試行 |
| Fault | CLEAR_* | Store Clear Failure／Nothing／ロックからの再Clear復旧 |
| Regression | 旧35件 | XU-01 Gate強制、XU-02 Snapshot、UI固定Shell |

## 4. Runtime専用（未自動化）

- UserFormの`.frm` Import、`Debug → Compile VBAProject`。
- 通常Xの`QueryClose`が保存→`Cancel=True/Hide`→Controller最終Unloadと発火し二重保存しない。
- 2件目のSet Failureで画面を保持し、再試行が全件保存となる。
- Store Clear成功→途中UI Clear Failureを故意に発生させた場合のロックと復旧（追加Fault設計が必要）。
- 外部直接Hideの検知とUncommittedShowのFailure報告。Formの直接Show未構築ガード。
- 複数Select失効時の警告表示。
- Workbookを閉じて開き直した場合の非永続性（MTS-INPUT-001）。

## 5. 記録するEvidence

Test ID、ImportしたModule名／Revision、VBE Compile Result、InputState Store前後、Control.Value/ListIndex、QueryClose/CloseMode/Cancel、Set/Get/Clear呼出回数、Failure ErrorCode、Controller Result、actual／expected／PASS/FAIL。

**未実行のため現時点では個別PASSを記録しない。**
