# S1-B Stage 2 Read-only Precheck結果

## 判定：`STOP / REVIEW_REQUIRED`

Read-only確認を実施しました。**RootのStage 1後状態は正常ですが、BitLockerと現在のSVIに未確認項目が残るため、`CODEX_STAGE2_ROOT_PRECHECK_PASS`は発行しません。**

確認日時：2026-10-23 21:29 JST

| 確認項目                             | 結果                                 |
| -------------------------------- | ---------------------------------- |
| 媒体の物理情報一致・ドライブ文字不変               | PASS                               |
| Primaryとは別物理ディスク                 | PASS                               |
| Rootの4主体                         | PASS                               |
| Owner・継承設定・直下項目の不変               | PASS                               |
| Root／SVI Snapshotの既知SHA-256・対応関係 | PASS                               |
| BitLockerの現在状態                   | **UNKNOWN：通常権限ではPermissionDenied** |
| 現在のSVI ACL                       | **SVI_ADMIN_CHECK_REQUIRED：取得拒否**  |

Rootは通常ユーザー・SYSTEM・Administrators・Everyoneの**各1件、Explicit Allow／FullControl／OI・CIあり**を維持しています。重複、Deny、未知のACEはありません。変更前Snapshotの1主体状態とは混同せず、Stage 1後の4主体として検証しました。

### 次のユーザー確認

1. 対象USBのBitLockerが、現在も`FullyEncrypted／100%／Protection On／Unlocked`であることを確認する。秘密値は提示不要です。
2. 既存の`Test-SVI-SnapshotPostStage1.ps1`が信頼済みファイルと同一であることを確認したうえで、ユーザーの管理者PowerShellで再確認する。
3. `SVI_POSTSTAGE1_READONLY_PASS`と指示書記載の照合項目がすべてTrueであることを確認する。`Stage2Authorized=False`は現時点では正常です。

今回、ACL・Owner・設定・ファイルは変更していません。検査前後のRoot状態とSnapshotハッシュも不変です。管理者昇格、Git操作、Stage 2は実行していません。

**ここで停止します。Stage 2は引き続き未承認・未実施です。**
