# T1 XU-01 Direct Show診断パッケージ

**Status**：TEST ONLY / 未実行 / Source-based guidance

## 収録内容
- `docs/T1_XU01_DirectShow_Failure_Review_v0.1.md`：今回の実測レビュー、進捗、Finding、分岐条件
- `tests/modTESTONLY_XU01ShowDiag_v0.1_CP932.bas`：T1コピー用の診断Module。追加検査のみでForm/Controller/Storeを変更しません。
- `SOURCE_MANIFEST.md`：収録ファイルのSHA-256

## 実行原則
1. T1の作業用コピーにImport。元のT1、Production、GitHubへは適用しない。
2. 元の回帰RunnerやFormのコードを改変しない。
3. 2つのFailだけ再現・分解する。診断結果自体をPASSへ換算しない。
4. マクロ実行時、モデルレスの未構築Formを開くため、一瞬表示する可能性があります。観察とログ採取後に自動Unloadします。
