# P3-04 XU-02 A案：前版差分・横断Source Review v0.1

| 管理項目 | 内容 |
|---|---|
| Document ID | DOC-P3-XU02-DIFF-REV-20261121 |
| Revision / Status | v0.1 / **SOURCE REVIEW COMPLETED / CANDIDATE ONLY** |
| 作成日 | 2026-11-21 |
| Approved Execution Baseline | **BL-MVP-004**（変更なし） |
| 比較元 | P3-04 XU-01 A案 Form Candidate v0.1 |
| 比較先 | P3-04 XU-01 + XU-02 A案 Scalar Snapshot Candidate v0.1 |
| 対象 | XU-02承認範囲との整合、XU-01回帰、UI状態接続への影響 |
| 対象外 | Production修正、VBA Import/Compile、Runtime、XU-01/02正式Closure、P3正式開始 |

## 1. レビュー結論

**判定：PASS（XU-02 A案の差分に対するソース整合レビュー限定）。Production採用はREVIEW_REQUIRED。**

親Formから新Formへの変更は、Form内部の全Row/OptionコピーとPrivate Rendererへの受け渡しに集中している。ControllerはSHA-256／バイト比較で**完全一致**。APIシグネチャ変更はなく、P3-03 Gate呼出しとXU-01の直接Showガードを保持している。

このPASSはSource Reviewに限定され、XU-02のRuntime検証、XU-01直接表示ガードの実UI動作、VBE/Designer取込成功を証明しない。

## 2. Source証拠

| 対象 | SHA-256 | 観測 |
|---|---|---|
| XU-01 親Form | `dfa70b8e4d3ede487c061bc82ac5be1ff0a7c2b0801c8899660da98a7d58a322` | 旧候補、無変更 |
| XU-02 新Form | `4fb506869d32ce8f7081b0b4a2678f511b452e770fe59d003bfa5feacb9f87df` | Formのみ最小修正候補 |
| 親・新Controller | `87fdefe7f53b568e4c7d3df56884828a7647f51c91fa24a0f998ef9c86d9cd88` | 旧新バイト一致 |
| P3-05 Input State | `293638d4a9617b56adc43925fe1c026c02dc7ca93870857e066918ef83fd6322` | 既存3 API、無変更 |
| XU-02 test Runner | `21335430c963c18567f8d8eda03e39e25ed1a38d1d200327cb58ced2431910fb` | 35件のシナリオ定義・未実行 |

差分の機械可読版：`diffs/XU02_vs_XU01_normalized_UTF8.diff`。**UTF-8/LF正規化したレビュー専用差分**であり、CP932/CRLF原本への適用用Patchではない。

## 3. 変更影響と承認されたXU-02 A案の照合

| ID | 元Candidate → 新Candidate | ソース証拠 | レビュー判定 |
|---|---|---|---|
| DR-01 | Gateの返した元Carrierをレンダラへ渡す → `CreateDisplaySnapshot()`で全件コピー後、レンダラへ渡す | 新Form L133–155 | PASS |
| DR-02 | 元Row Dictionaryを再参照 → 各行新DictionaryへValue/Type/Required/Description等を格納 | 新Form L178–265 | PASS |
| DR-03 | 元Option Dictionaryから追加 → 各Select行の新Collection[String] `OptionValues`へコピー | 新Form L232–264、L397–413 | PASS |
| DR-04 | 旧`BuildInputsFromGate` → 新`BuildInputsFromSnapshot`（Private） | 新Form L280–332 | PASS |
| DR-05 | 全件コピーが完了する前にControl追加へ進まない | 新Form L133–155、L178–278、L300–317 | PASS（静的） |
| DR-06 | Gate強制、二重Build防止、XU-01のShowガードを維持 | 新Form L82–123、Controller L9–70 | PASS（静的） |
| DR-07 | Control.Tag、Text/Date単一行、Selectリスト専用、Option順を維持 | 新Form L334–432 | PASS（静的） |
| DR-08 | Controllerの契約と実装を変更しない | Controller SHA一致、L9–70 | PASS |
| DR-09 | P3-05保存・復元・Clearを混入させない | Form L70–72、L300–301。InputState 3 API呼出なし | PASS |

**コピー範囲の厳密な意味：** Form表示に使うActive Rowと、そのSelectが参照する有効Optionの文字列を全件コピーする。参照されないOptionGroup全体まで複製するわけではない。コピー済みDictionary/CollectionはForm内部だけで用い、元Row/OptionへのObject参照を新Snapshotへ保持しない。

## 4. Failure伝播／残存境界

- Gate Failure時は`COperationResult`を同一参照のまま返し、Snapshot/Controlを生成しない。Gate SuccessでもCarrier不正ならFailureにする。
- Snapshot生成中の不正Row/Optionでは、公開Snapshotは`Nothing`のままでControl追加前に停止する。
- レンダリング途中のFailureでは`RemoveDynamicControls`を通り、`mBuilt=False`として表示準備を成立させない。
- `UserForm_Activate`は未構築Formを`Me.Hide`するが、直接`.Show`時の一瞬の描画抑止は未検証。**XU-01正式CLOSEDではない**。
- Gate成功からコピー開始前の元参照変更を防止する仕組みは導入していない。**XU-02の保証範囲はコピー完了後の表示用参照分離**。
- Source内のCopy/Render構造を確認しただけで、実機のMSForms/Designer実行を検証したものではない。

## 5. 独立SourceチェックとテストCoverage

`verification/source_delta_audit.json`：**30/30 PASS、FAIL=0**。

検査はテキスト・ハッシュ・ブロック構造確認であり、VBA Compileではない。XU-02の既存Fixture35ケースはファイル上に定義されているが**NOT RUN**。特に「Form構築後に元Carrierを改変する」ケースは、コピー開始前の変更競合を証明しない。

## 6. 新規統合観点のFinding（本差分への実装修正要求ではない）

| ID | 観測 | 分類 | 対応 |
|---|---|---|---|
| INT-F01 | XU-02 Formに`UserForm_QueryClose`もP3-05 API呼出もない | **INTEGRATION GAP / EXPECTED** | 次の接続Unitで設計・実装 |
| INT-F02 | Controllerは`.Show vbModal`復帰後`Unload`する。直接`.Hide`はQueryCloseを通らない | **INTEGRATION RISK** | 保存経路と禁止Callsiteを契約で固定 |
| INT-F03 | Clear後の終了時全件保存が、空文字KeyをStoreに再生成し得る | **SPECIFICATION DETAIL OPEN** | Clear後Close時の状態規則を決定 |
| INT-F04 | `SetInputValue`は単一Key更新で全件Atomic Commitではない | **INTEGRATION RISK** | 全件Preflight／失敗時Close停止と部分保存扱いを設計 |
| INT-F05 | Select失効値とOption Valueの大小文字照合規則が未承認 | **DECISION OPEN** | 復元方式を明示承認後に実装 |

本レビューで**新たなXU-02実装差分のBlocking Source Defectは確認していない**。ただしVBA Compiler・実行不能環境のため、動作上の不具合が存在しないと断言するものではない。

## 7. Quality Gate / Result

| 項目 | 判定 |
|---|---|
| XU-02設計方針（Private Scalarコピー） | APPROVED（既存ユーザー判断） |
| XU-02 Candidate Source差分整合 | **PASS（Source-only）** |
| 元Controller回帰／公開API維持 | PASS（Source-only） |
| 隔離VBA Fixture35件 | NOT RUN |
| VBE Import／Compile／UI表示 | NOT VERIFIED |
| XU-01／XU-02 正式Closure | REVIEW_REQUIRED |
| P3-04／P3-05 Production採用 | NOT APPROVED |

## 8. 次工程

現行ソースを変えず、別文書`02_P304_P305_Input_State_Interface_Spec_Candidate_v0.2.md`で接続条件を明示する。接続コードは未作成。
