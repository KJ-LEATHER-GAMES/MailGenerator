# P3-04 XU-02 A 最小修正Candidate v0.1

| 管理項目 | 値 |
|---|---|
| Status | **WORKING CANDIDATE / NOT APPROVED / NOT APPLIED** |
| 作成日 | 2026-11-21 |
| Execution Baseline | **BL-MVP-004（変更なし）** |
| 親Candidate | P3-04 XU-01 A Gate-Enforced Candidate v0.1 |
| 決定事項 | XU-01 A案、XU-02 A案は設計方針として承認済み。今回の実装は未承認 |
| 実機操作 | なし（Excel/VBE/OutlookのImport・Compile・実行なし） |

## 内容

- `src/frmMailGenerator_P3-04_XU01_XU02_A_Candidate_v0.1.frm`: **XU-02だけ**を追加したForm候補。CP932/CRLF。正規のVBE Export/Designer資産としては未検証
- `src/frmMailGenerator_CodeOnly_XU01_XU02_A_v0.1.txt`: 固定Designerを別途準備した場合のCodeOnly候補。CP932/CRLF
- `src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas`: **XU-01 A案からバイト単位で無変更**の参照同梱
- `tests/modP3_04GateStub_XU02_v0.1_CP932.bas`: **TEST ONLY**。本物のP3-03と同名の`PrepareUserFormLaunch`を提供するため、同一Workbookへ混合Import禁止
- `tests/modP3_04XU02Tests_v0.1_CP932.bas`: 独立Fixture。`RunP304XU02CandidateTests()`を定義（**35ケース、未実行**）
- `docs/P3-04_XU02_A_Minimal_Change_Source_Review_v0.1.md`: 変更管理・Quality Gate・残存リスク
- `docs/P3-04_XU02_A_Test_Matrix_v0.1.md`: Fixture期待値・MTSとの境界
- `docs/XU02_UTF8_Normalized_Review_Diff_v0.1.patch`: **レビュー用正規化Diff**。CP932/CRLF原本に直接適用しない。正規化したコピーでは適用一致を確認
- `verification/XU02_STATIC_AUDIT.json`および`verification/static_review_xu02.py`: 静的検査の結果と再実行用スクリプト
- `SOURCE_MANIFEST.md`: SHA-256とSource同一性記録

## 最小修正の境界

```text
Public frmMailGenerator.BuildValidatedInputs()
  -> P3-03 PrepareUserFormLaunch()  （XU-01 A案を維持）
  -> Gate Failure: 同一COperationResultを返して停止
  -> Private CreateDisplaySnapshot(全Rows/Options)
       -> すべてのRow/Optionを**文字列・Boolean値**へ複製
       -> OptionValuesは新Collection[String]で表示順を維持
       -> 全件成功してからDisplaySnapshotを公開
  -> 元のGate出力Carrier参照を解放
  -> Private BuildInputsFromSnapshot()
       -> 元のRow/Optionを再参照しない
       -> Controls.Add / mBuilt=True はすべてのコピー成功後
  -> UI起動Controller (変更なし)
```

**XU-02の承認はDesign方針に限定**。VBA実機での参照共有・描画・Control生成、35ケースのPASSは未確認。XU-01の直接`.Show`遮断も実機未確認のまま。

## 隔離テスト条件

VBEやExcelの実行許可を意味しない。後続で別途承認された隔離VBAプロジェクトを用意する場合のみ、`frmMailGenerator`（正規Designerと固定Control必須）、今回のController、`modResult`/`COperationResult`/`CErrorInfo`、テストStubとRunnerを使用する。テストStubと実`modP3UserFormLaunchGate`を混在させない。古い`frmMailGenerator`も同じProjectへ二重Importしない。

## 保存先（提案、GitHubには未保存）

- 修正Candidate: `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Fixture: `MailGenerator/tests/vba/P3_Configuration_UserForm/`
- レビュー: `MailGenerator/Docs/00_project_control/reviews/`

## まとめ / Summary

日本語：XU-02 A案のソース候補は作成済み。静的PASSはVBA実行PASSではなく、Production・GitHub・Baselineは変更していない。  
English: We prepared an XU-02 Option A source candidate. Static checks do not mean the VBA tests passed. Production, GitHub, and the baseline are unchanged.
