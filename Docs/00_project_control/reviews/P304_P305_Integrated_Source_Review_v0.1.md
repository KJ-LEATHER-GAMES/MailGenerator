# P3-04 × P3-05 Input State統合 — Source Review / Candidate v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | P304-P305-INT-REVIEW |
| Revision | v0.1 |
| Status | WORKING CANDIDATE / REVIEW_REQUIRED |
| 作成日 | 2026-11-21 |
| Execution Baseline | BL-MVP-004（変更なし） |
| Approved documents | DOC-MVP-REQ v0.1.9 §19、DOC-MVP-DES v0.1.10 §§17–18,25.2、DOC-MVP-TESTSPEC v0.1.6 MTS-INPUT-001/002、DOC-MVP-IMPL v0.4 §8.4 |
| Source basis | P3-04 XU-01+XU-02 A Candidate v0.1 / P3-05 modInputState v0.1 |
| 実行環境 | Source static inspection only / Excel・Classic Outlook・VBE未実行 |

## 1. 目的、ゴール、スコープ

**目的：** 承認されたP3-04×P3-05接続設計の5決定を一つの最小ソースCandidateへ実装し、隔離テストFixtureを用意する。**ゴール：** Source構造の確認、差分と制約の記録、テスト実行前の準備。

- In Scope：Gate／XU-02回帰、Tag Binding、復元、Select失効、QueryClose保存、Clear、Failure抑止、部分保存、テストFixture。
- Out of Scope：P4 Validation、メール生成、P2 Production、GitHub変更、Baseline更新、S5-C、P3正式開始、正式MTS PASSの宣言。

## 2. 承認事項をコードへ適用した内容

| Decision | 承認済み設計 | Candidate実装 |
|---|---|---|
| P3-05 API/String | `SetInputValue` / `TryGetInputValue` / `ClearInputValues`、Raw String | P3-05 Coreを**バイト単位無変更**で収録。追加Public APIなし |
| XU-01 A | Form公開BuilderでP3-03 Gateを強制 | Builder内`PrepareUserFormLaunch`を維持。未構築`.Show`はActivateでHide（描画保証なし） |
| XU-02 A | 全Row/Option Scalar Snapshot→元Carrierから参照分離 | XU-02実装を維持。表示Control生成後のTag/Typeスキーマも表示Snapshotから新規Dictionaryに構築 |
| D-UI-CLOSE A | QueryCloseで全件Capture、Failure時Cancel | QueryCloseの全件Preflight後にSet逐次保存。FailはCancel=True＋案内 |
| D-UI-CLEAR A | Clear後全空ならStore空を維持、途中失敗なら終了制限 | Clear前Preflight→Store Clear→UI Clear。成功フラグ＋失敗時ロック。QueryClose全空では再保存なし |
| D-SEL-STALE A | 未選択＋警告。復元時Store無変更。閉じると空文字 | ListIndex=-1、失効値と空文字保存の警告をErrorAreaに表示 |
| D-SELECT-CASE A | Option Valueは`vbBinaryCompare` | Listの有効Valueとの完全一致のみ復元 |
| D-COMMIT A | 全件Preflight→逐次保存。部分更新を許容し再試行 | `CaptureCurrentInputs`が全Tag・型・件数を確認後、キーを順次保存。失敗時に画面の値から全件再試行可能 |

## 3. 実際のソース変更

1. `frmMailGenerator`: 上流Gate、XU-02 Scalar Snapshot、Source Rendererを維持。静的なErrorAreaを大きくし、Clearを有効化。復元終了後だけ`mBuilt=True`。
2. `CreateInputSchema`: 表示用Snapshotを基に、VariableName→Typeの**新規**Case Insensitive辞書を作り、Tagの空／重複／不明／型不一致をPreflightで拒否。
3. `RestoreInputState`: 現行StoreをRaw StringでText/Dateへ復元。Selectの一致は`vbBinaryCompare`。失効値は未選択＋警告。自動SyncとStore改変は行わない。
4. `cmdClear_Click`: CoreがSuccessした場合のみ画面のTextBox空文字／ComboBox未選択。UI変更失敗などでLockを立て、QueryCloseを禁止。再Clear成功でLock解除。
5. `UserForm_QueryClose`: Capture全件成功後にのみ逐次Set。失敗時は`Cancel=True`、Store部分更新を隠さず通知。Clear成功＋全空欄なら再保存しない。
6. `modP3UserFormController`: `.Show vbModal`から戻っても`InputCommitSucceeded`がFalseならSuccessとしない。**追加したFormのPublic Read-only Property Get**のみ変更対象（P3-05 APIは不変）。

## 4. QueryCloseイベントの技術的な実装上の条件

`Unload`によってFormインスタンスが消滅するとControllerへ保存済フラグを引き渡せない可能性がある。そこで**Candidateでは保存Success時の`UserForm_QueryClose`内で`Cancel=True`→`Me.Hide`（イベント内だけ許可）とし、Controllerが`InputCommitSucceeded=True`を確認してから最終`Unload`する**。後段Unloadでは再保存を行わない。

- **管理外の直接`.Hide`は禁止**。Controllerは検出可能な未Commitのモーダル復帰をFailure扱いする。ただし直接呼出しを言語機構だけで全面的に禁止することはできない。
- `QueryClose`内`Hide`の正しい発火順、二次Unloadのイベント順、Xボタン、Code Unload、Workbook終了時のCancel挙動は**VBE Runtime NOT VERIFIED**。
- Controller内で例外が発生して`UnexpectedFailure`へ飛んだときの二次Unloadは、例外の原因によって予期しないQueryClose保存を誘発する恐れがある。**追加検証が必要なResidual Risk（R-04）**とする。

## 5. Failureと非原子性

- Restoreで`TryGetInputValue`がNothing/Failure→Control破棄、Builder Failure、非表示。
- Capture Preflight失敗→Store書込み前停止、`Cancel=True`。
- 2件目以降のSetが失敗→先行Keyのみ更新済の可能性を通知し、以後停止。画面を保持し、次回は全件再Capture／保存。
- ClearでStore失敗→画面変更せず、失敗ロック（Store状態そのものの完全不変性は保証しない）。
- ClearでStore成功後、UI更新失敗→不整合を通知／QueryClose禁止。Rollback・完全原子性は保証しない。

## 6. Static Reviewの結果

- Source assertions: **112/112 PASS**（Failure 0）。明細は`verification/P304_P305_Source_Static_Audit_v0.1.json`。
- 新規Nominal Fixture **21ケース**、新規Failure注入Fixture **9ケース**、既存XU-02回帰Fixture **35ケース**の定義を収録。
- **VBA Compile=NOT VERIFIED、UserForm Designer Import=NOT VERIFIED、VBA Test実行=0、MTS-INPUT-001/002=NOT VERIFIED**。
- ソース静的PASSはRuntimeやProduction採用の証拠ではない。

## 7. Issue / Risk Log

| ID | Severity | 内容 | 方針 |
|---|---|---|---|
| R-01 | HIGH | UserForm `.frm` のDesigner Import、イベント実行順、`Hide`/`Unload`挙動は未実証 | VBEでCompile・X/Unload/Hide実機検証 |
| R-02 | HIGH | D-COMMITは逐次書込で部分更新を許容 | 保存Failure注入、全件再試行テスト。完全Rollbackを主張しない |
| R-03 | HIGH | Clear途中のStore／UI不整合、再Clearにも失敗する場合は画面終了不可 | Core/Widget Failure注入と復旧試験、必要に応じDesign再判断 |
| R-04 | MED | Controllerの例外Cleanup中にFormのQueryCloseが再発火する可能性 | 実機Fault Caseで確認し必要なら限定Patch |
| R-05 | MED | 複数失効Selectの警告は全文をCaptionとTooltipへ設定するが表示枠が狭い可能性 | 複数値の可読性とTooltip動作を実機確認。必要ならレビュー |
| R-06 | MED | direct `.Hide`・Form直接`.Show`はVBA固有メソッドで完全禁止できない | Callsite監査＋Controller保存済チェック、XU-01 Runtime検証 |
| R-07 | MED | P3-03 Gate～Scalarコピー開始前のSource変更は防がない | XU-02残存リスクとして管理 |
| R-08 | MED | P3-05はWorkbook内標準Module変数。Workbook Close/Reopenの保持条件は実機未確認 | MTS-INPUT-001 |
| R-09 | HIGH | P3-04 `.frm`の固定Designerリサイズ後Import/表示挙動未確認 | VBEでインポートしてレイアウト検証 |
| R-10 | HIGH | Fault Stubと実P3-05を同時ImportするとPublic名衝突 | テストWorkbookを完全分離 |

## 8. Quality Gate / Completion

| Gate | 判定 |
|---|---|
| 候補ソース／Fixture／Manifest作成 | COMPLETED（本作業範囲） |
| ソース静的チェック | PASS |
| VBA Compile・Runtime／イベント検証 | NOT VERIFIED |
| XU-01/XU-02正式Closure | REVIEW_REQUIRED |
| P3-04×P3-05 Production採用 | NOT APPROVED |
| CP-P2／P3正式Phase開始 | NOT ESTABLISHED |

**推奨次工程：** まずテスト専用WorkbookへNominal構成をImport・Compile、Form終了イベントとClearを実行確認。次に別WorkbookでFailure Stubを使って逐次保存・再試行・終了Lockを確認し、Source Findingを評価する。Production／GitHub／Baselineは明示承認まで無変更。
