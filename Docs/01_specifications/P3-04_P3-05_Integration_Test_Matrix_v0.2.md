# P3-04 × P3-05 Integration Test Matrix Candidate v0.2

| 管理項目 | 内容 |
|---|---|
| Document ID | P3-04-P305-INT-TEST-MATRIX |
| Revision | v0.2（前版 v0.1 20件の拡張／置換案） |
| Status | **TEST DESIGN ONLY / NOT IMPLEMENTED / NOT RUN** |
| Date / Baseline | 2026-11-21 / BL-MVP-004（変更なし） |
| 対象 | XU-01 / XU-02回帰、P3-05復元・Capture・Clear、MTS-INPUT-001/002 |

> このMatrixは設計Candidateであり、ここに書いたExpectedを「実装済み」や「承認済み仕様」として扱わない。未決項目は関連欄にDecision IDを明示した。

| Test ID | Preconditions / Steps | Expected（Candidate） | Traceability |
|---|---|---|---|
| INT-01 | P3-03 Gate Failureで起動を試行 | State読出し・Form表示をしない | XU-01 / IG-01 |
| INT-02 | Gate Success、元Carrierを変更（Snapshotコピー後） | Form表示値・Option一覧はコピー時の値のまま | XU-02 / IG-11 |
| INT-03 | Gate Success、既存StateにKeyがない | Text/Date=""、Select未選択 | §18.3 |
| INT-04 | Text保存値が日本語・空白・改行を含む | 現行Text単一行要件に従う。改行は別途入力境界で検証し黙って置換しない | String / P3-04 |
| INT-05 | Dateに日付として不正な文字列を保存 | FormはRaw Stringを復元、Date検証はP4 | §18.3 / P4 |
| INT-06 | StateのVariableName大文字小文字を変更して検索 | 同一Keyとして値を取得 | §18.2 |
| INT-07 | StateはhasValue=Trueかつ空文字 | 空欄表示。未登録との差異はStoreで保持 | 3 API |
| INT-08 | Select保存値が有効Optionに一致 | 一致したListIndexが選択される | §17.2 |
| INT-09 | Selectが未登録または空文字 | ListIndex=-1、先頭を自動選択しない | §18.3 |
| INT-10 | Select保存値が失効 | 未選択＋通知案。Storeは即時変更しない（承認待ち） | D-SEL-STALE |
| INT-11 | Select Valueの大文字小文字だけ異なる | 一致可否を承認済み規則に従って判定（未決） | D-SELECT-CASE |
| INT-12 | 復元途中でTryGetInputValueがFailure | mBuilt=False、Formは表示不可、Result Failure | IG-02 |
| INT-13 | 復元結果がNothing | UnexpectedError、Formは表示不可 | IG-02 |
| INT-14 | Text/Date/Selectを入力後、標準XでClose | 全件Preflight→保存成功後だけ閉じる | IG-04 |
| INT-15 | SelectがListIndex=-1のままClose | SetInputValue(Tag,"") | D-UI-CLOSE |
| INT-16 | 複数ControlのTagが重複・空 | Storeを更新する前にFailure、Close中止 | IG-04 |
| INT-17 | 2番目のSetInputValueでFailure | 先行Keyの部分保存を記録、画面維持、再試行可能 | D-COMMIT |
| INT-18 | 保存がSuccess後にControllerがUnload | 保存済フラグによって二重Captureを防ぐ | D-UI-CLOSE |
| INT-19 | 直接Me.Hide／外部Hideで終了 | 禁止Callsite監査。QueryCloseで捕捉したと主張しない | IG-05 |
| INT-20 | 通常Close失敗時ErrorAreaへ通知 | Cancel=True、Form保持。機能テストは未実施 | IG-04 |
| INT-21 | Clearクリック時、StoreとControlに値がある | ClearInputValues Success後、全Controlが空 | IG-06 |
| INT-22 | ClearInputValues Failure | 画面は変更しない、成功通知しない | IG-06 |
| INT-23 | Store Clear成功後にControl Clearが失敗 | 部分状態とErrorを通知、成功扱いしない | IG-12 |
| INT-24 | Clear後に入力せずClose | 空のStoreが維持され、Keyを再生成しない | D-UI-CLEAR |
| INT-25 | Clear後に再入力してClose | 新入力値を保存。空値の扱いは仕様候補どおり | D-UI-CLEAR |
| INT-26 | ClearしていないFormで全Controlを手動消去→Close | 明示的空文字がStoreへ保存される | String / D-UI-CLEAR |
| INT-27 | 同Workbook SessionでForm再表示 | 前回の保存値を復元 | MTS-INPUT-001 |
| INT-28 | Workbook Close後に再Open | 前Session入力値を永続復元しない | MTS-INPUT-001 |
| INT-29 | Formが未構築のままUnload／Close | InputStateを誤更新せず解放する | XU-01 / D-UI-CLOSE |
| INT-30 | 再表示後にOptionが現在のActive Optionsと不一致 | AutoSync・暗黙の別Value選択をしない | D-SEL-STALE |

## テスト段階

- **Source only**：Function呼出順、Failure抑止、`Tag`、Scalarコピー、実P3-03とStubのPublic名競合を静的確認する。
- **VBA Unit/Isolated**：Form・InputState・`COperationResult`とテストStubを隔離Workbookへ導入して実行する（**今回は未実施**）。
- **Runtime Integration**：VBE Import/Compile、X/Unload/Hide/Workbook Closeのイベント実際の挙動、動的Control操作、Select失効値を検証する（**今回は未実施**）。
- **Formal MVP Test**：MTS-INPUT-001/002は別途適切なTest Candidate Buildで実施する。本設計レビューはFormal PASSではない。

## 実施前の前提

`PrepareUserFormLaunch` Stubと実P3-03を同一VBAプロジェクトで共存させない。Form `.frm/.frx`のImport、Compileは未確認。Clear後Close・Select失効値の未決判断を承認するまで、対応ケースを確定Expectedとして扱わない。
