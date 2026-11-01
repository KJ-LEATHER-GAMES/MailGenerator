# S1-B Backup Precheck結果

**総合判定：`BACKUP_PRECHECK_BLOCKED`**

USBの識別・物理独立性は確認できました。ただし、**USBルートのEveryone FullControl**と、**BitLocker状態の独立確認不能**が残っています。コピー・設定変更は行っていません。

## 1. 調査日時・Repository状態

- 調査日時：2026-10-22 21:47～21:52 JST
- Branch／HEAD：`main`／`c86671f`
- 開始・終了時のHEAD、Working Tree、ステージ状態は一致。
- 既存の添付2文書は未追跡のまま、SHA-256も変更なし。

## 2. Backup媒体識別結果

以下は **VERIFIED** です。

| 項目       | 実測結果                            |
| -------- | ------------------------------- |
| ドライブ     | `D:`                            |
| ラベル      | `MG_EVIDENCE_BK`                |
| ファイルシステム | NTFS                            |
| 接続状態     | Ready／Removable                 |
| 容量       | 7,739,863,040 bytes             |
| 利用可能容量   | 7,711,531,008 bytes             |
| モデル      | ELECOM MF-BSU3 USB Device       |
| 接続       | Storage情報：USB、WMI情報：USB／USBSTOR |

ラベル・ドライブ文字だけでなく、パーティション、デバイス情報、識別情報の指紋を照合しています。シリアル番号原文は表示していません。

## 3. 物理ディスク独立性

**VERIFIED：Primaryとは別物理ディスクです。**

| 対象      | ディスク／パーティション       | デバイス                          |
| ------- | ------------------ | ----------------------------- |
| Primary | Disk 0／Partition 3 | KINGSTON SNV3S2000G・NVMe      |
| Backup  | Disk 1／Partition 1 | ELECOM MF-BSU3 USB Device・USB |

Storage APIとWMIのボリューム→パーティション→ディスク対応、パーティション位置が一致しました。両媒体の識別情報も異なり、別パーティションだけを根拠とする判定ではありません。

## 4. BitLocker状態

| 項目                 | 確度・結果             |
| ------------------ | ----------------- |
| 暗号化完了・ドライブ全体・互換モード | **USER_ATTESTED** |
| 再接続後のパスワード解除PASS   | **USER_ATTESTED** |
| 暗号化状態・完了率          | **UNKNOWN**       |
| Protection Status  | **UNKNOWN**       |
| Lock Status        | **UNKNOWN**       |
| 暗号化方式              | **UNKNOWN**       |
| ファイルシステム           | **VERIFIED：NTFS** |

通常権限でのBitLocker状態専用CIM照会はPermissionDenied、`manage-bde -status D:`も取得失敗でした。**暗号化無効と判定したのではなく、独立確認できていません。**

パスワード・回復キー・秘密値を取得する操作は行っていません。

## 5. 容量・アクセス制御

容量は必須5原本の既知合計 **1,064,213 bytes**を十分上回っています。

一方、USBルートのACLは次の状態でした。

| 項目           | 結果                      |
| ------------ | ----------------------- |
| Owner        | 実行Windowsユーザー           |
| Explicit ACE | Everyone：FullControl、1件 |
| 継承範囲         | 子フォルダ・ファイル              |
| その他のACE      | なし                      |

**これは承認済み3主体への最小権限制限に適合しません。** 通常の継承で保存先を作成すると、Everyoneの権限を引き継ぐ構成です。

暗号化済みという申告だけでは、解除中のアクセス制御を代替したとは扱いません。

## 6. Backup保存先候補

対象：`D:\MailGenerator\P2_I12_20261018\`

| 観点             | 結果                              |
| -------------- | ------------------------------- |
| 保存先・親フォルダ      | ともに不存在。既存対象との衝突なし               |
| Git            | 現在のRepository外。ドライブルートに`.git`なし |
| ReparsePoint   | 既存祖先のドライブルートでは検出なし              |
| 関連SMB共有        | 検出なし                            |
| 登録済みOneDrive同期 | 確認できたルート1件の対象外                  |
| アクセス制御         | ルートの過剰権限により不適合                  |
| 作成             | 未実施                             |

新規保存先の実際のACLは未検証です。他の同期方式や、別主体による実効アクセスまで網羅した保証ではありません。

## 7. Primary Archive継続性

**VERIFIED：既知の状態を維持しています。**

- 指定3階層が存在し、合計ファイル数0件。末端フォルダは空。
- Ownerは実行ユーザー。
- 各階層は実行ユーザー・SYSTEM・AdministratorsのFullControlだけを継承。
- ReparsePointなし、Repository外、登録済みOneDriveルート外。
- `originals`・Private Indexは未作成。

管理共有の許可は引き続き存在します。**他主体による実効アクセスはUNKNOWN、正式受容も未確定**のままです。

## 8. 未確認事項・残留リスク

1. USBルートのEveryone FullControl。
2. BitLockerの暗号化・保護状態の独立確認不足。
3. Primaryの管理共有経由の実効アクセスと、その残留リスクの受容。
4. 新規Backup保存先の作成後ACL。
5. 実コピー・復元試験は未実施。

子フォルダだけのACL制限で十分とは判断せず、USBルートの権限も含めた修正案の審査が必要です。今回は変更していません。

## 9. S1-B実行前の不足事項・検証計画

原本参照元は、既知の外部OneDrive開発フォルダ **DEV** です。

| Evidence ID   | 参照ファイル                            |
| ------------- | --------------------------------- |
| E-P202-RAW    | `261018_P2-02_Regression Log.txt` |
| E-P203-RAW    | `261018_P2-03_Regression Log.txt` |
| E-P204-RAW    | `261018_P2-04_Regression Log.txt` |
| E-P204-SOURCE | `P2-04_Regression_20261018.zip`   |
| E-P204-WB     | DEV版 `MailGeneratorNew.xlsm`      |

今回、原本ハッシュは再計算していません。コピー直前に、承認済み固定表のサイズ・SHA-256と全5件を再照合し、不一致なら停止する計画です。Repository内の同名Workbookは代用しません。

必要な新規作成範囲は、別途承認対象として以下を想定します。

- Primary：`originals`
- Backup：`MailGenerator`、`P2_I12_20261018`、`originals`
- Private Index：PrimaryとBackup
- 復元試験：Git／DEV／Primary／Backup外の専用新規一時フォルダ

コピーは上書きなしとし、原本→Primary→Backup→復元先の各5件でサイズ・SHA-256を比較します。途中失敗時の無断削除・上書き修復は行いません。

## 10. 次に承認すべき具体的操作

まずはコピーではなく、次の準備段階が必要です。

1. **USBのACL修正案の審査**\
   専用USBのルートと新規保存先を対象に、承認3主体へ限定する案。既存システムフォルダへの一括適用は含めず、実行は別途承認。

2. **BitLocker状態を確認できる資料・手段の用意**\
   秘密値を含まないOS状態情報で確認すること。今回の管理者昇格禁止は維持しています。

3. **Backup保存先の空フォルダ作成と作成後検査の承認**

4. **Primary側の残留リスクの審査・受容判断**

5. 条件充足後に、コピー・Index作成・復元試験を明示承認。

## 11. Read-only遵守確認

フォーマット、BitLocker変更・解除、ファイル／フォルダ作成・コピー・削除、ACL・共有・所有者変更、管理者昇格は行っていません。原本Evidence・Workbook・ZIPは変更せず、Repositoryへの保存・Git書込み・ネットワーク更新・S1-Cへの着手もありません。

**本判定はS1-B CompletionでもG2承認でもありません。原本コピーに進まず停止します。**
