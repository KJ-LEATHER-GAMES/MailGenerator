# P3-04 XU-01 A案 ― Gate自己検証・直接Show抑止 Candidate v0.1

- 作成日：2026-11-21
- **Status：WORKING CANDIDATE / REVIEW_REQUIRED**
- 設計判断：**XU-01 Option Aのみユーザー承認済み**
- 実装候補：**未承認、未Import、未Compile、未実行**
- 実行基準：BL-MVP-004（変更しない）

## 使い方

1. `Docs/P3-04_XU01_A_Design_Implementation_Review_v0.1.md`を読む。
2. `src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm`と`src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas`は**修正後の全量Candidate**。元のCandidateは上書きしない。
3. `Docs/P3-04_XU01_A_CP932_CRLF_Apply_Candidate_v0.1.patch`は**旧P3-04 Candidate 3ファイルへのCP932+CRLF適用用差分**。実際の元バイト列を使った一時コピーに対する`git apply --check`と適用後同一性がPASS。プロジェクト正本やApproved文書には適用しない。
4. `Docs/P3-04_XU01_A_UTF8_Normalized_Review_Diff_v0.1.patch`は**正規化したUTF-8のレビュー差分**。元CP932ファイルにそのまま適用しない。
5. `tests/`には**P3-03の本物と衝突する同名関数を持つテスト専用Stub**を収録。実P3-03と同一VBA Projectで同時Importしない。実機利用が別途許可されるまではRuntime Testを実施しない。
6. `Docs/STATIC_REVIEW_RESULT_XU01_A.json`に静的検査結果**46/46 PASS**を収録。VBA Compile/動作/描画PASSの証拠ではない。

## 最小差分

- Form公開API：`BuildValidatedInputs(Collection,Object)` → 引数なし`BuildValidatedInputs()`。
- Form公開APIが`PrepareUserFormLaunch()`を自ら呼び、Success時だけPrivate Rendererを起動する。
- 未Buildの直接`.Show`に対して`UserForm_Activate`でHideする。
- ControllerはFormを先に生成し、公開Builderを一度呼び出してSuccess時だけForm参照を公開する。
- P3-01/02/03・P2-05 Production・GitHub・Baselineは一切変更しない。

## Release / Verification Boundary

- 静的テスト：**PASS 46/46**（静的検査のみ）。
- 隔離VBA Fixture：**27 cases defined / NOT RUN**。
- 直接Showの非表示動作：**NOT VERIFIED**。`Activate`までの瞬間描画・ちらつきを保証しない。
- 正式XU-01 Closure：**REVIEW_REQUIRED**。
- Production Promotion：**NOT APPROVED**。

## プロジェクト内の推奨保存先

- 修正候補：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Stub / Runner：`MailGenerator/tests/vba/P3_Configuration_UserForm/`
- レビュー／Evidence：`MailGenerator/Docs/00_project_control/reviews/`

実際のGitHubやProject正本へは**保存していない**。このZIPは配布・レビュー用の作業コピー。
