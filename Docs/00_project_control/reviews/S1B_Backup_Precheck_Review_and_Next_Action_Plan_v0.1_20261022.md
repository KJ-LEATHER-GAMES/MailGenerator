# S1-B Backup Precheck Review and Next Action Plan v0.1

## 1. Document Control

| Item | Value |
|---|---|
| Project | 定型メール作成ツール（Excel VBA + Outlook Classic） |
| Document | S1-B Backup Precheck Review and Next Action Plan |
| Version | v0.1 |
| Date | 2026-10-22 |
| Status | PROPOSED — 未承認 |
| Project-control recommended location | `Docs/00_project_control/` |
| Input Evidence | ユーザー共有のCodex実行結果（2026-10-22 21:47–21:52 JST）およびS1-B引継ぎ |
| Evidence level | Codex報告をレビュー。ChatGPTによるユーザーPC／USBの独立実測は行っていない |

## 2. Review Decision

**判定：`BACKUP_PRECHECK_BLOCKED`を維持（妥当）。**

- `D:`／`MG_EVIDENCE_BK`／NTFS／ELECOM MF-BSU3、Primaryと別物理ディスク（Disk 0 NVMe vs Disk 1 USB）はCodex報告上 `VERIFIED`。
- 容量は5原本の合計1,064,213 bytesを十分に上回る。
- USBルートの明示的 `Everyone: FullControl` は、承認済みの「実行ユーザー・SYSTEM・Administrators」に制限する条件に不適合。解除中のUSBへの書込み可能性を広げる。
- BitLockerの暗号化完了・Protection・Lock・方式については `UNKNOWN`。ユーザー申告を無効とは扱わないが、独立確認を代替させない。
- Primaryは空3階層を維持したが、管理共有経由の実効アクセスが `UNKNOWN`。残留リスクの正式受容は未確認。
- この段階では`EXECUTE_ARCHIVE`、Backup保存先の作成、コピー、Restore、S1-C、G2を承認しない。

## 3. Findings / Treatment

| ID | Finding | Evidence | Classification | Treatment |
|---|---|---|---|---|
| BK-01 | USBルート Everyone FullControl | Codex報告 VERIFIED | BLOCKER | DACLの変更前設計→承認→限定実行→再検証 |
| BK-02 | BitLocker状態を通常権限で取得不能 | UNKNOWN（PermissionDenied） | BLOCKER | 別承認の管理者権限による**状態参照のみ**、秘密値を共有しない |
| BK-03 | Primaryの管理共有残留リスク | 実効アクセス UNKNOWN | GATE DECISION | リスク記述を固定し、ユーザーが受容か追加措置を選択 |
| BK-04 | Backup保存先未作成・作成後ACL未確認 | NOT EXECUTED | FOLLOW-UP | BK-01/02対応後に空フォルダ作成の限定承認・ACL確認 |
| BK-05 | 原本コピー・復元・Index未実施 | NOT EXECUTED | FOLLOW-UP | EXECUTE_ARCHIVE別承認まで保留 |

**注意：** BitLockerが正常でもUSBが解除・接続されている間のDACL不適合を免除しない。逆に、DACLを直してもBitLockerによる持出し時の保護を確認したことにはならない。両条件を別々に審査する。

## 4. Next Actions and Gates

| Step | Owner | Action | Evidence / Exit | Prohibited before approval |
|---|---|---|---|---|
| R1 | ユーザー | 管理者としてBitLocker**状態だけ**を表示し、秘密値を伏せた情報を共有 | 同一USB確認、Encryption 100%、保護On、ロック解除中の状態、方式、必要に応じ暗号化範囲 | 暗号化・保護・Key Protectorの変更 |
| R2 | Codex（Read-only） | USBルートDACL・継承・既存子要素・SID・変更影響を確認し、非再帰的な修正案とRollback案を設計 | 変更対象と対象外、期待ACL、事前退避方法、停止条件、検証コマンドが明確 | ACL・所有者・ファイルの変更、昇格、フォルダ作成 |
| G-ACL | ユーザー | R2の変更対象を明示承認 | 許可対象とコマンド単位の操作範囲が特定済み | 包括的な変更承認として扱わない |
| R3 | Codex（限定実行） | 承認されたACL修正のみ実行 | 変更前後DACL、継承、Root/既存子への影響、不要ACEなし、操作失敗なし | `/T`を伴う再帰的な一括書換え、`reset`、deny追加、無断rollback |
| G-PRIMARY | ユーザー | Primaryの管理共有等の残留リスクを受容するか判断 | 受容なら前提・限界・再評価条件、非受容なら追加措置の依頼 | 管理共有の勝手な無効化 |
| R4 | Codex | 別承認を受け、Backupの空3階層を作成しRead-only検査 | `MailGenerator`、`P2_I12_20261018`、`originals`のOwner/DACL/非共有/Repo外/同期外、空であること | 原本コピー、既存ファイル上書き |
| G-PRECHECK | ChatGPT＋ユーザー | R1/R3/R4、Primary判断を統合レビュー | `BACKUP_PRECHECK_PASS`等の判定とUNKNOWNの扱いを確定 | PASSのみでCOPY承認としない |
| G-EXECUTE | ユーザー | 5原本の参照元・固定SHA・Primary/Backup/Restore先・後始末を含む`EXECUTE_ARCHIVE`を限定承認 | 対象と許可操作を明文化 | その他ファイル変更・Git操作 |
| R5 | Codex | 再ハッシュ→Primary→Backup→Restore（5件全件）→SHA照合 | 原本から復元先までサイズ・SHA一致、失敗と未確認の区別 | 不一致原本の上書き、無断削除、進捗の先取り |
| R6 | Codex＋ユーザー | S1-C Manifest/Private Index → G2 | Publicには機微な絶対パスなし、G2をユーザー承認 | 公開Push |

**R1とR2は並行可能。R3/R4/R5は承認依存を保持。**

## 5. BitLocker Verification — User Action

1. USBを接続してパスワードで解除。作業直前に、ラベル・容量・モデルを再確認し対象が以前の`D:`に相当することを確認。
2. **ユーザーが自分で**PowerShellを「管理者として実行」し、次の**状態参照のみ**を実行。これは以前の「管理者昇格禁止のCodex Precheck」とは別の明示的な操作。

```powershell
Get-BitLockerVolume -MountPoint 'D:' |
  Select-Object MountPoint,VolumeType,VolumeStatus,EncryptionPercentage,ProtectionStatus,LockStatus,EncryptionMethod,AutoUnlockEnabled |
  Format-List
```

代替手段：管理者コマンドプロンプトで`manage-bde -status D:`。**`-protectors -get`、鍵の出力、`-on`、`-off`、`-unlock`などの変更・秘密取得コマンドは使用しない。**

3. 共有してよい項目は上記の状態フィールドのみ。ユーザー名・デバイスシリアル・パスワード・回復キー・回復キーID・Key Protector詳細等は共有しない。
4. 合格基準：対象媒体一致、FullyEncrypted相当、EncryptionPercentage=100、ProtectionStatus=On、ロック解除中ならLockStatus=Unlocked、暗号化方式が有効。ドライブ全体暗号化／互換モードは表示が不十分なら`UNKNOWN`を残して個別判断。
5. 権限エラー等で状態が取れない場合は`UNKNOWN`を維持。`PASS`にしない。

## 6. ACL Remediation Design Requirements — Codex Read-only

- 変更対象候補は**専用USBのルートのみ**。現在のドライブ文字で対象を同定しない。Disk/Partition/Model/Label/NTFS/容量を再照合する。
- Before: RootのOwner、DACL/SACLの公開可能な情報、継承状態、ACEの適用範囲（OI/CI等）、SIDを取得し、復旧に必要なスナップショットと保管先／保管方法を提案する。
- Root配下に既存の隠し・システム要素があるか、変更による継承ACEの影響を調査する。`/T`なしでも親DACL変更が継承先に影響し得る。
- Target: 実行ユーザー、SYSTEM、AdministratorsだけをFullControl主体とし、`Everyone`等の広範囲のACEを残さず、必要な子フォルダ・ファイルへ継承。実行ユーザーのSIDを特定する。否定ACEを新設しない。
- 操作順は「正規3主体を確保→広範なACEを除去→アクセス確認」を基本案として提案し、失敗時の停止と復旧を先に示す。現時点では**変更コマンドは実行しない**。
- DACL変更がWindowsのシステム管理・BitLocker動作に影響しないか、保留・別案の必要性を検討する。
- 子フォルダだけ制限する代替案も比較する。ただし今回はRootが承認3主体の条件に不適合なので、代替案への変更にはユーザー承認が必要。
- `icacls /T`、ACL一括リセット、所有者一括変更、ドライブ初期化、BitLocker変更、共有設定変更、Git Add/Commit/Pushは明示禁止。

## 7. Primary Residual Risk Decision

Primaryはユーザー・SYSTEM・AdministratorsのみのACEが報告されているが、管理共有の許可と別主体の実効アクセスには確認限界がある。標準の管理共有の存在と「外部へ無条件公開されていること」は同義ではないが、未確認リスクを「なし」として扱わない。

選択肢：
- A：個人管理PC、想定利用者、ネットワーク条件、管理者アクセス可能性を踏まえて**残留リスク付き受容**（推奨候補）。受容日、主体、適用範囲、再評価条件を記録。
- B：実効アクセス・ネットワークの限定調査を追加し、その結果で判断。管理共有の一律無効化等は無断実施しない。

A/Bはいずれも**未決定**。ユーザーの明示判断を待つ。

## 8. EXECUTE_ARCHIVE Entry Criteria (unchanged)

- R1でBitLocker保護状態を客観確認するか、未確認を正式例外として評価・承認している。
- USBルートおよびBackup新規保存先のACLを承認条件どおり確認する。
- Primaryの残留リスクを正式受容、または追加措置で解決する。
- 原本5件の参照元はDEV版。Repo同名Workbookで代替しない。
- コピー直前に固定済み5件のサイズ・SHA-256を再照合。いずれか不一致なら停止。
- Primary `originals`、Backup `MailGenerator/P2_I12_20261018/originals`、両Private Index、Git/DEV/Primary/Backup外のRestoreテスト先を事前に特定。
- 一律上書き・無断削除なし。Copy/Restoreの各5件をSHA照合。失敗時は残存物と不一致を記録し、次の対処の承認を得る。
- Public Repoへ実パス・機微なRaw・秘密情報を追加しない。現行Git履歴のPush禁止を維持。

## 9. Post-Archive Dependency

`S1-C → G2 → S2（P2-02/03 Regression Closure）→ S3（P2-04/I12 Closure）→ S4（BL-MVP-004／Registry／Overview整合）→ S5（P2-05 Compile・S01–S32・Patch Review・Finding Assessment・Completion）→ S6（P2 Exit／CP-P2）`

すべてのGateで、Verification PASS、Evidence存在、Formal Closure、Baseline Approval、Phase Exitを区別する。

## 10. Codex Read-only Instruction — Copy-ready

```text
定型メール作成ツールのS1-B Backup Precheckは2026-10-22にBACKUP_PRECHECK_BLOCKEDでした。次はUSB ACL Remediation DesignのRead-only調査のみ実施してください。

対象は専用USB MG_EVIDENCE_BK（前回D:、ELECOM MF-BSU3、Disk 1/Partition 1、NTFS）です。実行前にストレージ指紋を再照合し、一致しなければSTOPしてください。PrimaryはDisk 0 NVMeです。

必須調査：
(1) USBルートのOwner・明示/継承ACE・SID・OI/CI継承・現存子要素（隠し/システム含む）の状態。
(2) Everyone FullControlを除去し、実行Windowsユーザー/SYSTEM/Administratorsの3主体FullControlに限定する「非再帰的」最小変更案。Windows管理・BitLocker/隠し子要素への影響と、USBルートのみ制限する案・Archive子フォルダだけ制限する代替案の比較。
(3) 変更前DACLの記録・復旧手順、ロックアウトを防ぐ操作順、実行停止条件、作業後のACL/継承/読書き確認。実行を必要とする具体コマンドは提案として明示し、実行はしない。
(4) 対象Root以外に変更され得る範囲、管理者権限の要否、UNKNOWN、承認が必要な操作を明示。

絶対禁止：ACL・Owner・BitLocker・共有設定変更、フォルダ・ファイル作成/削除/コピー、ドライブ初期化、管理者昇格、Git Add/Commit/Push/Fetch/Pull/履歴変更、S1-C/EXECUTE_ARCHIVE着手。パスワード/回復キー/シリアル原文を出力しない。

出力はEvidence（VERIFIED/USER_ATTESTED/UNKNOWN）とRemediation Candidate（PROPOSED）を分離し、判定をREMEDIATION_DESIGN_READY / REVIEW_REQUIRED / BLOCKEDのいずれかで示してください。変更は別途ユーザー承認まで行わないでください。
```

## 11. Summary / まとめ

**日本語：** 今回のPrecheckはBLOCKEDが適切。USBの識別・独立性・容量は確認されたが、USBルートのEveryone FullControlとBitLocker状態の独立未確認がコピーを妨げる。BitLocker状態参照とACL修正設計を先に実施し、変更・コピーは作業単位ごとに正式承認する。

**English:** The blocked result is correct. The USB identity, disk separation, and capacity were checked. The USB access rules are too broad, and BitLocker status is not yet verified. Check BitLocker and plan the access change first. Approve each change before any copy.
