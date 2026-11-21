# P3-04 XU-02差分Review → P3-05接続仕様化 Package v0.1

**作業内容**：承認済みXU-02 A案のP3-04修正Candidateを、XU-01親Candidateと実ソース差分レビュー。P3-05の承認済み接続APIを前提として、保存・復元・Clearの接続契約を設計Candidate v0.2へ具体化した。

**レビュー結論**：XU-02差分はSOURCE-ONLY PASS。VBA実行／Production採用／正式XU-02 Closureは未実施。接続仕様は**WORKING / NOT APPROVED**。

| ファイル | 内容 |
|---|---|
| `01_XU02_Diff_Source_Review_v0.1.md` | 旧新Formの根拠付き差分レビューとQuality Gate |
| `02_P304_P305_Input_State_Interface_Spec_Candidate_v0.2.md` | 接続の時系列・Close・Clear・Select規則の候補 |
| `03_P304_P305_Integration_Test_Matrix_Candidate_v0.2.md` | 30件の設計テスト（NOT RUN） |
| `04_DECISION_ISSUE_RISK_LOG_v0.1.md` | 承認済み／未決を区別したDecision・Riskログ |
| `05_SOURCE_MANIFEST.md` | 対象Sourceと成果物SHA-256 |
| `diffs/XU02_vs_XU01_normalized_UTF8.diff` | UTF-8正規化済み閲覧用Diff、CP932原本への適用禁止 |
| `verification/source_delta_audit.json` | 30項目の独立Source構造検査（VBA Compileではない） |

**推奨プロジェクト保存先（未保存）**：
- `MailGenerator/Docs/00_project_control/reviews/`：差分レビュー／Decision Log
- `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`：接続仕様Candidate
- `MailGenerator/tests/vba/P3_Configuration_UserForm/`：Test Matrix

**無変更**：P3-01～P3-05ソース、GitHub、既存Production、BL-MVP-004。環境調査・実機・P3正式Phase開始を実施していない。
