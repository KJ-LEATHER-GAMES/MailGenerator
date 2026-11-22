# T1 Nominal Runtime Source/Evidence Review & Progress v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | DOC-REV-P304P305-T1-NOMINAL |
| Revision | v0.1 |
| Status | REVIEW COMPLETED（Nominal PASS、T1全体IN PROGRESS） |
| Review date | 2026-11-22 |
| Scope | Nominal実行証拠、T1進捗、次工程の優先順位、残存Issue |
| Baseline | BL-MVP-004 不変更 |

## 1. 結論

`RunP304P305NominalCandidateTests`に対応する21件すべてのPASS表示と、集計`PASS=21 FAIL=0`をスクリーンショットおよび提出テキストで照合した。**T1 Nominal Runtime：PASS（実行者提供証拠に基づく）**。Compile Evidence v0.2のCOMPILE_PASSと矛盾しない。

これはTest WorkbookでのCandidate検証である。P3正式開始、正式MTS、Production採用、P2 Closure、S5-Cは成立しない。

## 2. テスト領域ごとの評価

| 対象 | 該当ケース | Review |
|---|---|---|
| Input restore | RESTORE_TEXT、DATE_RAW、SELECT_EXACT、MISSING、EMPTY、CASE_KEY | PASS（Nominal Runner） |
| Stale Select / case | STALE_SELECT、SELECT_CASE、STALE_CLOSE_EMPTY | PASS（Nominal Runner） |
| Close capture / preflight | CLOSE_CAPTURE、CLOSE_EMPTY_SELECT、PREFLIGHT_BAD_TAG、PREFLIGHT_DUP_TAG | PASS（Nominal Runner） |
| Clear flows | CLEAR_BOTH、CLEAR_SKIP_COMMIT、CLEAR_REINPUT、CLEAR_MANUAL_EMPTY | PASS（Nominal Runner） |
| Gate / snapshot | SINGLE_GATE、SCALAR_ISOLATED、GATE_FAILURE、UNBUILT_NO_SAVE | PASS（Stub/対象条件） |

**Limitations:** Nominal Runnerの`Unload f`呼出しは人がXを押した経路を証明しない。P3-03はStubであり、実GateとOutlook/OFTの処理は未検証。エラー注入はT2/T3で検証予定。`RESTORE_DATE_RAW`のPASSは日付型Validation成功を意味しない。

## 3. 新規Issue：T1モジュール一覧の不一致

| 項目 | 記録 |
|---|---|
| Issue ID | T1-FIND-001 |
| Severity | LOW（構成Evidence整合。機能影響は未判定） |
| Observation | 今回のスクリーンショットでは標準モジュール配下に`Module1`が表示される一方、先行Evidence v0.2にある`modTESTONLY_ModalQueryClose_Smoke`が一覧に見当たらない。 |
| Fact boundary | 画像からは`Module1`のコード内容やSmoke Macroが存在するか否かは判別できない。`Module1`に相当コードが貼付されている可能性もあるため断定しない。 |
| Impact | 直近のNominal 21件のPASSは覆さない。Xボタン手動Smokeの実施可否と11コンポーネント記録の整合を確認する必要がある。 |
| Proposed action | T1をバックアップし、VBEで`Module1`のコードと`RunTESTONLY_ModalQueryClose_Smoke`の存在を照合。正しく登録されていればEvidenceのモジュール構成を更新。未導入ならT1専用Smoke moduleを追加し、再Compile後に実施。無断でProduction側を変更しない。 |
| Status | OPEN |

## 4. T1進捗（対象範囲を明示）

| Step | Gate | Status |
|---:|---|---|
| 1 | T1隔離Workbook・11コンポーネント構成／Manual Designer | COMPLETED（先行Evidence）※T1-FIND-001確認待ち |
| 2 | VBA Compile | COMPLETED / COMPILE_PASS（先行Evidence） |
| 3 | **Nominal Runtime 21件** | **COMPLETED / PASS** |
| 4 | XU-01/XU-02 Regression Runtime 35件 | NOT STARTED |
| 5 | Direct Hide／Xボタンの実操作確認 | NOT STARTED |

- T1の主要5工程：**3/5完了 = 60%**（工程数ベース。全テスト完成度を表す指標ではない）。
- T1自動テスト：**21/56 PASS = 37.5%**（定義済み21+35件、35件は未実行）。
- T2／T3、正式MTS、Production採用はこの分母に含まない。

## 5. 次の実施順序（推奨）

1. **T1-FIND-001**を確認する。特に手動Smokeマクロの実在を確認し、Compile済み状態を維持する。未承認Productionへの移植を行わない。
2. Workbookをバックアップし、`RunP304XU02CandidateTests`（35件）を実行。期待最終ログ：`P3-04 candidate total: PASS=35 FAIL=0`。初回FAIL/実行時Errorならその時点でSTOPし、Immediateログ・エラー行・画面を記録。
3. 回帰PASS後に`RunTESTONLY_DirectHide_Test`で `DIRECT-HIDE-001 ... PASS` を確認。**テスト専用の意図的なHide**であり、Production操作は禁止。
4. `RunTESTONLY_ModalQueryClose_Smoke`を起動し、表示されたFormの最初の入力欄に`QC-OK`と入力、右上Xを押す。期待ログ：`QC-MODAL-001 Real X/QueryClose route: PASS`。マクロ未確認の場合は実行せず構成を修正する。
5. T1完了後、別Workbookに隔離したT2 Failure Injection、T3 UI Clear Faultを実施。実P3-05と同名Fault Stubを同居させない。

## 6. Decision / Risk Log

| ID | 決定／リスク | 状態 |
|---|---|---|
| D-COMMIT A | Preflight後逐次保存、部分更新リスクを許容 | APPROVED（接続Candidate設計） |
| D-UI-CLOSE A | QueryClose保存。Failureなら終了取消 | APPROVED（接続Candidate設計） |
| D-UI-CLEAR A | 明示Clear後に全空欄ならStore空状態を維持 | APPROVED（接続Candidate設計） |
| D-SEL-STALE A | 失効Selectは未選択＋警告 | APPROVED（接続Candidate設計） |
| D-SELECT-CASE A | `vbBinaryCompare`で完全一致 | APPROVED（接続Candidate設計） |
| XU-01 | 直接Form表示・Gate迂回リスク | REVIEW_REQUIRED（正式Closure未承認） |
| XU-02 | Scalar Snapshot参照共有リスク | REVIEW_REQUIRED（正式Closure未承認） |
| T1-FIND-001 | Module1／Modal Smoke module一覧差 | OPEN |
| TEST-FLOW-001 | T2/T3 Failure・Clear途中Failure未検証 | OPEN |
| BASELINE | Production／GitHub／BL-MVP-004 | NO CHANGE |

## 7. Quality Gate

| Check | Result |
|---|---|
| Submitted result and screenshot consistency | PASS |
| Nominal 21-case Runtime evidence | PASS |
| T1 full regression | NOT VERIFIED |
| T1 actual X/direct Hide flows | NOT VERIFIED |
| T2/T3 Failure paths | NOT VERIFIED |
| Formal MTS-INPUT-001/002 | NOT VERIFIED |
| P3正式開始、Production採用 | NOT APPROVED |

## まとめ / Summary

**日本語:** T1 Nominal 21件は全PASS。T1主要工程は3/5、T1自動テストは21/56完了。次はモジュール構成差分の確認と回帰35件。その後にHide/Xの実操作確認を実施する。

**English:** All 21 T1 nominal tests passed. Three of five T1 steps are complete, and 21 of 56 automated tests have passed. Next, check the module list and run 35 regression tests, then test Hide and the X button.
