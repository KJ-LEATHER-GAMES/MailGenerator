# P3-04 × P3-05 Input State Integration Test Matrix Candidate v0.1

| Document ID | P3-04-P305-INT-TEST-MATRIX |
|---|---|
| Revision / Status | v0.1 / WORKING CANDIDATE・NOT RUN |
| Date / Baseline | 2026-11-21 / BL-MVP-004 |
| Purpose | Future integration test planning only; does not imply code has been written or tests executed |

| Test ID | Preconditions / 操作 | Expected | 関連 |
|---|---|---|---|
| INT-01 | Gate Failure→フォーム起動 | Form未表示、State変更なし | XU-01 / IG-01 |
| INT-02 | Gate Success、未登録Key | 対応Controlは空欄・未選択 | §18.3 |
| INT-03 | Textに保存済み日本語・前後空白あり | 値をそのまま復元 | MTS-INPUT-001 |
| INT-04 | Dateの未検証文字列を保存 | 入力文字列のまま復元、Valid Date判定はしない | §18 / P4 |
| INT-05 | Case違いTagで既存State取得 | 同一VariableNameとして復元 | §18.2 |
| INT-06 | SelectにActive Optionの値が保存 | 一致する選択肢を選択 | §17.2 / §18.3 |
| INT-07 | Select保存値が現行Active Optionにない | 無言で別Optionを選ばない。具体処理は判断後固定 | D-SELECT-STALE |
| INT-08 | Select値未登録／空文字 | ListIndex=-1 | §18.3 |
| INT-09 | Text/Date/Selectに入力後Xで閉じる | QueryCloseで全Tagを採取・Store更新してから閉じる | MTS-INPUT-001 |
| INT-10 | QueryCloseでSetInputValue失敗 | Cancel=True、Formを破棄しない、Error表示 | Fail Closed |
| INT-11 | `.Show`復帰後ControllerがUnload | 保存済み値が残る | IG-03 |
| INT-12 | 同一Workbook Sessionで再起動 | 保存済み入力値を復元 | MTS-INPUT-001 |
| INT-13 | Workbook終了→再Open | 入力値を永続復元しない | MTS-INPUT-001 |
| INT-14 | Clearボタン押下 | Store全件消去＋画面Text/Selectが空になる | MTS-INPUT-002 |
| INT-15 | Clear操作でCore Failure | Clear成功と表示しない。部分変更を観測 | IG-06 |
| INT-16 | 直接`.Hide`呼出 | 管理外Callsiteを検知／認可されたAPIへ誘導 | IG-05 |
| INT-17 | Gate直後に元Row/Optionを外部変更 | コピー済み表示用値は元参照の変更から独立 | XU-02 / IG-08 |
| INT-18 | P3-04 XU-01直接 `.Show` 未構築 | ガードで操作不可。描画の有無は実機観測 | XU-01 |
| INT-19 | Gate成功・Restoreエラー | Form非表示、Successを返さない | IG-02 |
| INT-20 | Input State保存中に技術的Failure | Failureを通知、Form維持、再試行可能 | P305-R03 |

**全20件：TEST DESIGN ONLY / NOT IMPLEMENTED / NOT RUN。** 実際のVBA Fixture・Workbook・Designerは作成していない。実機に関する環境調査・起動はしない。Test Specification MTS-INPUT-001/002をFormal PASSと扱わない。

推奨保存先：`MailGenerator/tests/vba/P3_Configuration_UserForm/`、GitHub保存未実施。
