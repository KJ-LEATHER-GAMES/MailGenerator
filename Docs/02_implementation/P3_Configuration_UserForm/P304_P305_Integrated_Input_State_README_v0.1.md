# P3-04 × P3-05 Input State統合 Candidate v0.1

**Status：WORKING CANDIDATE / NOT APPROVED FOR PRODUCTION**  
**Baseline：BL-MVP-004（不変）**  
**Date：2026-11-21**

## 内容

Approved接続設計（D-UI-CLOSE, D-UI-CLEAR, D-SEL-STALE, D-SELECT-CASE, D-COMMIT）の**最小VBA接続Candidate**。XU-01公開Gate・XU-02 Scalar Snapshotも維持。P3-05の3 APIとRaw String方式はそのまま。

- `src/frmMailGenerator_...frm`：復元・保存・Clear・失効警告・Fail Closed。CP932/CRLF。
- `src/modP3UserFormController_...bas`：終了時Commit確認・二重保存防止。CP932/CRLF。
- `src/modInputState_...bas`：既存P3-05 v0.1の**無変更コピー**。重複Import禁止。
- `tests/nominal/`：本物のP3-05との21ケース＋XU-02回帰35ケース＋Gate Stub。
- `tests/fault_injection/`：P3-05 API置換Stub＋9ケース。**Nominalとは別Workbook**。
- `docs/`：Source Review、Test Guide。
- `verification/`：静的チェック（VBA Compile・Runtimeではない）。
- `diffs/`：XU-02 Candidateと今回のソース間のUTF-8正規化差分。**CP932原本へ直接Patchしない。**

## 重要な制限

**実VBE Import/Compile、UserForm Runtime Event、MTS-INPUT-001/002は未実施。** `.frx`は付属しない。テストFixtureはProductionに入れない。実P3-03とGate Stub、実P3-05とFailure Stubは共存不可。外部`.Hide`は禁止だが言語上完全には遮断できない。QueryClose保存Success時だけイベント内で`Hide`し、Controllerが確認してUnloadするCandidate。Runtimeでの成立性を確認するまで正式Closureとしない。

Production / GitHub / Baselineを変更せず、ファイルは作業領域にのみ保存した。

## プロジェクト内推奨保存先

- `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`：接続仕様・候補・ソース差分。
- `MailGenerator/tests/vba/P3_Configuration_UserForm/`：隔離Fixture。
- `MailGenerator/Docs/00_project_control/reviews/`：Source Review・Audit・Manifest。
