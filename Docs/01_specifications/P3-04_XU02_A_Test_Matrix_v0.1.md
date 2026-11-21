# P3-04 XU-02 A案：独立Fixture Test Matrix v0.1

| 項目 | 内容 |
|---|---|
| Status | WORKING CANDIDATE / NOT RUN |
| 実行入口 | `RunP304XU02CandidateTests()` |
| 実装対象 | XU-01 A案を維持した`frmMailGenerator`、参照隔離とFail Closed |
| Fixture定義 | **35ケース**（旧27、XU-02追加8） |
| 実行結果 | **0ケース実行／PASS数の主張なし** |
| テストStub | `modP3_04GateStub_XU02_v0.1_CP932.bas`（TEST ONLY） |

## 1. 既存XU-01回帰27ケース

| No. | ID | 主な確認内容 | Status |
|---:|---|---|---|
| 01 | `DEV-P3FORM-FAIL` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 02 | `DEV-P3FORM-NIL_RESULT` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 03 | `DEV-P3FORM-NO_ROWS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 04 | `DEV-P3FORM-NO_GROUPS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 05 | `DEV-P3FORM-GROUP_WRONG_TYPE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 06 | `DEV-P3FORM-MIXED` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 07 | `DEV-P3FORM-TAG_BINDING` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 08 | `DEV-P3FORM-LABELS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 09 | `DEV-P3FORM-REQUIRED_MARKERS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 10 | `DEV-P3FORM-OPTION_ORDER` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 11 | `DEV-P3FORM-SELECT_STYLE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 12 | `DEV-P3FORM-TEXT_SINGLE_LINE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 13 | `DEV-P3FORM-EMPTY` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 14 | `DEV-P3FORM-BAD_TYPE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 15 | `DEV-P3FORM-BAD_DESCRIPTION` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 16 | `DEV-P3FORM-MISSING_GROUP` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 17 | `DEV-P3FORM-BAD_OPTION_VALUE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 18 | `DEV-P3FORM-REPEATED_FORM` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 19 | `DEV-P3FORM-BUILD_TWICE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 20 | `DEV-P3FORM-DIRECT_BUILD_SUCCESS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 21 | `DEV-P3FORM-DIRECT_BUILD_FAILURE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 22 | `DEV-P3FORM-DIRECT_BUILD_NIL_RESULT` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 23 | `DEV-P3FORM-DIRECT_BUILD_BAD_ROWS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 24 | `DEV-P3FORM-DIRECT_BUILD_BAD_OPTION` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 25 | `DEV-P3FORM-DIRECT_SHOW_UNBUILT` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 26 | `DEV-P3FORM-DIRECT_SHOW_AFTER_FAILURE` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |
| 27 | `DEV-P3FORM-DIRECT_SHOW_AFTER_SUCCESS` | XU-01 A案の旧Runnerから継承。既存期待結果を維持 | 未実行 |

## 2. XU-02追加8ケース

| No. | ID | 期待結果 | Status |
|---:|---|---|---|
| 28 | `DEV-P3FORM-SOURCE_ROW_MUTATION` | Gateが返したVariableName/DisplayName/Required/Descriptionを書換後も、表示Tag/Label/必須表示/Descriptionが元の値のまま | 未実行 |
| 29 | `DEV-P3FORM-SOURCE_OPTION_MUTATION` | Gateが返したOption[Value]を書換後も、Selectの候補順・文字列が元のまま | 未実行 |
| 30 | `DEV-P3FORM-SOURCE_CLEAR` | Gateが返したRow CollectionとOptionGroupsを削除しても、Formが生成済み表示値を保持 | 未実行 |
| 31 | `DEV-P3FORM-CASE_MISMATCH` | OptionSource=Departmentに対しgroup key=department（親辞書はvbTextCompare）でもvbBinaryCompareの厳密一致で拒否 | 未実行 |
| 32 | `DEV-P3FORM-SECOND_ROW_INVALID` | 1行目が有効でも、2行目のType不正はControl追加前にFailure | 未実行 |
| 33 | `DEV-P3FORM-MISSING_REQUIRED` | 後半行でRequiredを欠落させた場合はFail Closed | 未実行 |
| 34 | `DEV-P3FORM-OPTION_NONOBJECT` | Select Optionの後半要素が非DictionaryならFail Closed | 未実行 |
| 35 | `DEV-P3FORM-OPTION_ARRAY_VALUE` | Select OptionのValueがArrayならFail Closed | 未実行 |

## 3. 補足とLimitations

- `SOURCE_*`の3件は**Form Build後**に元辞書を改変し、画面の値が変わらないかを見る。旧Candidateでも表示用Controlには文字列をコピーしていたので、このテスト単独では「描画前の全件コピー」まで証明しない。`verification/XU02_STATIC_AUDIT.json`で、`Controls.Add`より前の全件コピー、元Carrierをレンダラへ渡さない構造を別途静的に検査する。
- `CASE_MISMATCH`は、元Dictionary自体の`CompareMode=vbTextCompare`と、Domain上のOptionGroup厳密照合を混同しない回帰。
- `SECOND_ROW_INVALID`・`OPTION_NONOBJECT`・`OPTION_ARRAY_VALUE`は、後半Row/Optionの異常でもFormを利用可能状態にしないことを確認する。
- 実テストには、独立したVBE UserForm Designer、MSFormsと既存`COperationResult`/`CErrorInfo`/`modResult`が必要。今回Import・Compile・実行はしていない。
- Stubは実P3-03と同じ公開`PrepareUserFormLaunch`を定義する。同一VBA Project内で混合Importしてはならない。
- XU-01の直接Show抑止は、ちらつきなしの完全防止を主張しない。Runtime EvidenceはXU-01で別管理。
- MTS-UI-001～005やMTS-INPUT-001/002の**正式PASSではない**。特にState復元／Clear接続は今回のScope外。

## まとめ / Summary

日本語：35ケースのテストFixtureを定義した。VBAは未実行。XU-02の参照分離とXU-01の回帰を今後検証する。  
English: We defined 35 test cases. VBA tests were not run. They will check snapshot isolation and the XU-01 gate.
