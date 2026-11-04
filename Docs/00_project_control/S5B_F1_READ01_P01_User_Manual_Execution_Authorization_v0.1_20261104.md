# F1-READ-01：P01所属確認のユーザー手動実行承認

提示された手動実行方式を承認します。

対象：S5B-TestPC-01

ユーザー本人が、対象PCのGUI確認後、非昇格のコマンドプロンプトから以下のコマンドを1回だけ実行することを承認します。

`net localgroup "CodexSandboxUsers"`

承認範囲は既存手順案のとおりとします。

なお、非昇格であることと、Windowsアカウントが標準ユーザーであることは区別してください。

コマンド成功時も、ACL上のP01とのSID一致はNOT_VERIFIEDとして扱ってください。

Codex自身によるコマンド実行は承認しません。

ユーザーが匿名化結果を報告するまで、Codexは実行・追加調査を行わず停止してください。

```yaml
F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```
