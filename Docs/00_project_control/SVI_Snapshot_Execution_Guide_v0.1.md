# S1-B G-PREP — SVI Snapshot取得ガイド v0.1

## 目的

`SVI.before.json` を、USBのACL変更に進む前の比較用Evidenceとして **既存G-PREP Runフォルダへ新規作成**する。ACL/Owner/BitLockerは変更せず、原本Evidenceコピー・Git操作は実施しない。

## ダウンロードファイル

- `Root.before.json`：共有されたJSONを再構成した参照用の同一ハッシュファイル。SHA-256 `b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`、サイズ1,489 bytes。
- `Save-SVI-Snapshot.ps1`：SVI情報を読み取り、検証後に `SVI.before.json` を新規保存する実行スクリプト。SHA-256 `e19bf12f2f4ce2dd6bbfe82ceab5ac7b1d369d42af9e79b0f978762baaca8fb8`。

**重要：** Codexが保存した既存 `Root.before.json` を上書きしないこと。スクリプトは既存の原本を入力とする。

## 推奨保存先

```text
C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\
  Scripts\
    Save-SVI-Snapshot.ps1
  ACL_Remediation_Rollback\
    G-PREP-20261022T143534Z-21b5c43a\
      Root.before.json     ← 既存原本／変更禁止
      SVI.before.json      ← スクリプトで新規生成
```

Root / SVI Snapshotは個人SID・DACLを含むため、Public GitHub、OneDrive同期領域、USB Backupの保管対象にしない。

## 保存方法

1. `Save-SVI-Snapshot.ps1` をダウンロードする。
2. エクスプローラーで `C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\` を開く。
3. `Scripts` フォルダが存在しなければ手動作成し、その中へ `.ps1` を保存する（内容確認後）。
4. `Root.before.json` は**既存のRunフォルダのファイルを使用する**。ダウンロードしたコピーで置換しない。

ダウンロードが使えずテキストエディタで作成する場合は、拡張子が `.ps1.txt` にならないよう「ファイルの種類：すべてのファイル」、名前 `Save-SVI-Snapshot.ps1` で保存する。スクリプトはASCIIで記述済み。

## 実行方法

USBメモリ `MG_EVIDENCE_BK` を接続・BitLocker解除し、Windows PowerShellを **管理者として実行**する。自動的な権限昇格はスクリプトに含まれない。

まずスクリプトのハッシュを確認する。

```powershell
Get-FileHash -LiteralPath 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\Scripts\Save-SVI-Snapshot.ps1' -Algorithm SHA256
```

期待値：`e19bf12f2f4ce2dd6bbfe82ceab5ac7b1d369d42af9e79b0f978762baaca8fb8`

続いて実行する。

```powershell
& 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\Scripts\Save-SVI-Snapshot.ps1' `
  -RootSnapshotPath 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\ACL_Remediation_Rollback\G-PREP-20261022T143534Z-21b5c43a\Root.before.json'
```

ダウンロードマークにより署名エラーで実行を拒否された場合は、コードとハッシュを十分確認した後、必要に応じて次の操作を検討する（グローバル実行ポリシー変更は不要）。

```powershell
Unblock-File -LiteralPath 'C:\Users\monsi\PrivateEvidenceArchive\MailGenerator\Scripts\Save-SVI-Snapshot.ps1'
```

組織ポリシーなどが別途適用されている場合は回避せず停止する。

## 正常終了時

チャットへ共有するのは次の5項目のみとする。

```text
Result                  : SVI_SNAPSHOT_SAVED
RunId                   : G-PREP-20261022T143534Z-21b5c43a
AreAccessRulesProtected : True
FileSHA256              : <実測値>
Bytes                   : <実測値>
```

SID、SDDL、JSON本文、回復キーなどは共有しない。

## 異常時

Rootハッシュ不一致、媒体識別不一致、SVI保護解除、ACL不一致、既存SVI Snapshot、作成・読み戻しエラーでは停止する。途中でできたファイルがあっても独断で削除・上書きしない。ACL Stage 1 / Stage 2には進まない。

## 次のGate

SVI Snapshot作成後、CodexへRead-onlyでRoot／SVI Snapshotの整合、ファイルACL、USBルートACL不変、SHAを確認させる。Stage 1のACL変更は別途ユーザーが承認する。
