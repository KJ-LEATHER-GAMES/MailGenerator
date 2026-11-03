# S1-B USB ACL Remediation Stage 1 実施結果

## 判定：`STAGE1_ROOT_PASS_PENDING_SVI`

**Stage 1を一度だけ実行し、USBルートの検証はPASSしました。**\
実行日時：2026-10-23 20:41:53 JST

### 実行・検証結果

- `icacls /grant:r`：実行1回、終了コード`0`
- 非昇格の通常ユーザーセッションで実施
- USB：`MG_EVIDENCE_BK`／ELECOM USB。実行前後で同一媒体
- 変更前：Everyoneの1主体 → 変更後：期待する4主体

| 主体             | 権限          | OI／CI | ACE            |
| -------------- | ----------- | ----- | -------------- |
| 通常利用ユーザー       | FullControl | 両方あり  | Explicit Allow |
| SYSTEM         | FullControl | 両方あり  | Explicit Allow |
| Administrators | FullControl | 両方あり  | Explicit Allow |
| Everyone       | FullControl | 両方あり  | **既存ACEを維持**   |

Owner・ルートの継承設定・直下項目は不変です。想定外ACEやDenyはなく、通常ユーザーによるACL読取り・列挙も成功しました。両Snapshotのハッシュも変更ありません。

### SVI事後照合：ユーザー確認待ち

現在のSVI ACLは通常権限では取得できず、**UNKNOWN**です。管理者昇格はしていません。

次にユーザーの管理者PowerShellで、現在のSVIと既存`SVI.before.json`を読み取り専用で比較してください。

- `AreAccessRulesProtected=True`
- Owner SIDが一致
- DACL SDDLが一致

報告は一致・不一致だけで構いません。**Snapshotの再生成・上書きや保存スクリプトの再実行は不要です。**

### 停止状態

エラー、自動再試行、Rollbackはありません。Stage 2、Everyone除去、Evidenceコピー、ディレクトリ作成、Git操作も行っていません。

**Everyoneの過剰権限は意図どおり残っています。SVI事後照合を待ち、ここで停止します。**
