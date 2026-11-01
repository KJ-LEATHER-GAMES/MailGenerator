# Codex指示書：S1-B USB ACL Remediation Design（Read-only）v0.1

## 1. 目的・現在地

定型メール作成ツールのS1-B Backup Precheck（2026-10-22）は `BACKUP_PRECHECK_BLOCKED` で停止中。

USB媒体（前回 `D:`、ラベル `MG_EVIDENCE_BK`、`ELECOM MF-BSU3 USB Device`、NTFS、約7.74GB）は、Primary（NVMe）とは別の物理ディスクであると先行Precheckにより報告されている。

**今回の新Evidence（ユーザー自身が管理者PowerShellで状態表示し、結果を共有）：**

```text
MountPoint           : D:
VolumeType           : Data
VolumeStatus         : FullyEncrypted
EncryptionPercentage : 100
ProtectionStatus     : On
LockStatus           : Unlocked
EncryptionMethod     : Aes128
AutoUnlockEnabled    : False
```

この結果は `USER_PROVIDED_OS_OUTPUT` として記録する。ChatGPT/Codexが独立取得した値とは書かない。BitLocker暗号化・保護状態の確認はこの出力に基づきPASSと評価済み。ただし、ドライブ全体暗号化を選択した事実や互換モードの独立確認はこの出力ではできないため、既存の `USER_ATTESTED` と区別する。

**残る主なBlocker：** USBルートに明示的 `Everyone: FullControl` があり、承認方針である「実行Windowsユーザー／SYSTEM／Administratorsの3主体」に限定されていない。Primary側の管理共有残留リスク受容も未決定だが、今回の調査・修正対象ではない。

今回の目的は、**USBルートのACL修正案をRead-onlyで設計・評価し、次のユーザー承認に必要な根拠を提示すること**。**ACL変更・フォルダ作成・原本コピーは許可しない。**

## 2. 作業権限

- **許可**：既存情報のRead-only照会、ACL・継承・既存子要素・媒体同一性の調査、変更候補コマンドと復旧案の提示、結果のチャット報告。
- **禁止**：ACL/DACL/SACL/Owner変更、権限昇格、BitLocker操作・再設定、暗号化解除、USBフォーマット、ファイル・フォルダ作成/変更/削除/コピー、共有・同期設定変更、管理者昇格、Git Add/Commit/Push/Fetch/Pull/履歴変更、S1-C・`EXECUTE_ARCHIVE`着手、原本5件へのアクセスまたは変更。
- `/T`などによる再帰的ACL変更、`icacls /reset`、`takeown`、`Set-Acl`、`icacls /grant`・`/remove`等の実行は禁止。変更コマンドは**提案としてテキスト表示する場合のみ**認める。
- `icacls /save`やACLスナップショットをファイルへ書き出す操作も今回は禁止（将来の承認対象として提案可）。
- 調査結果はチャット上に提示し、Repositoryその他の場所へファイル保存しない。

## 3. 実施手順

### A. USB媒体の再識別

先行結果の `D:` のみで対象確定しないこと。現在のドライブ文字、ラベル、NTFS、容量、USB接続、モデル、Volume→Partition→Physical Disk対応をRead-onlyで照合し、前回の媒体と一致するか判定する。物理ディスク番号は変わる可能性があるため、番号だけで一致判定しない。**不一致または同定不能ならSTOP**。デバイス固有のシリアル番号原文は報告しない。

### B. USBルートACLの現状把握

- Owner、保護/継承状態、明示ACEと継承ACE、Identity（必要ならSID種別）、Allow/Deny、Rights、適用先/継承フラグを調査する。
- `Everyone: FullControl`が実際にどの範囲へ適用されるか確認する。
- Root直下に既存の隠し/システム項目（例：`System Volume Information`、`$RECYCLE.BIN`）やReparsePointが存在するか、**再帰走査なし・内容閲覧なし**で確認する。アクセス拒否は無理に迂回せず`UNKNOWN`と記録する。
- 現状のWindowsユーザー、SYSTEM、Administratorsが必要な権限を保持しているかをRead-onlyで評価する。Ownerであることだけで書込み権限を保証したと扱わない。
- ACL変更が既存子要素に継承を通じて及ぼす影響、およびBitLocker使用中のUSBでの運用上の注意点を整理する。

### C. 修正候補の比較（実行禁止）

以下を比較する。

1. **候補A：USBルートの明示ACEを最小修正し、実行ユーザー/SYSTEM/AdministratorsのみFullControlとする案**（既定の優先候補）。既存の正当な明示/継承設定、Windowsシステム項目、アクセス継続性への影響を評価する。
2. **候補B：Archive用子フォルダのみ継承を無効化して3主体に限定する案**。Rootの`Everyone FullControl`が残ることによる承認済み要件との不一致と、rootからの所有・削除等の経路に関する残余リスクを明示する。候補Bを勝手に採用しない。

候補Aの推奨可否、メリット/デメリット、変更対象、既存子要素への想定影響、必要権限、適用条件、UNKNOWNを説明する。

### D. 次工程用の安全な操作計画（提案のみ）

次の別承認で実行する場合を想定し、以下を順序付きで作成する。ただし**一切実行しない**。

1. 変更前の媒体再確認・ACL退避案（保存先・機微情報の扱いも明示）。
2. 正規3主体への権限を先に確保し、誤ったアクセス喪失を防止する最小修正案。既存の許可を不用意に失わないこと。
3. `Everyone` ACEの扱い、継承フラグ、Rootと既存子への影響・非再帰操作であることの保証範囲。
4. 停止条件、失敗時の復旧案。復旧コマンドも**今回の実行対象外**。
5. 変更後のRead-only検査項目（Root ACL、Owner、継承、3主体以外のFullControl不存在等）。将来の書込み試験を提案する場合は別承認の作成・削除範囲を指定。
6. 変更に管理者権限が必要な場合、**誰が、どの別承認のもとで行うか**を明記。今回Codexは昇格しない。

## 4. 出力形式

以下の順序で報告する。

1. `Scope & Read-only Compliance`：実施した参照、禁止操作が未実施であること。
2. `USB Identity Recheck`：識別根拠（個人情報・シリアル原文は伏せる）、`VERIFIED/UNKNOWN/STOP`。
3. `Current ACL Findings`：RootのOwner、ACE、継承、既存子要素、確認限界。
4. `Remediation Options`：候補Aと候補Bの比較、承認済み3主体方針との適合性。
5. `Proposed Execution Plan`：変更候補の具体的コマンド**（NOT EXECUTED）**、想定影響範囲、事前退避、復旧案、必要権限、作業後検査。
6. `Risks & Unknowns`：継承による既存子への影響、管理者権限、OS保護項目等。
7. `Final Decision`：`REMEDIATION_DESIGN_READY / REVIEW_REQUIRED / BLOCKED` のいずれか、理由、次回必要なユーザー承認項目。

Evidenceの確度を `REPO_VERIFIED / FILE_VERIFIED / USER_PROVIDED_OS_OUTPUT / USER_ATTESTED / UNKNOWN` に分けること。**提案された操作、推定値、未来の検証は実施済みPASSと書かない。**

## 5. 終了条件

USB同定が成立し、Root ACLの事実、最小修正案、既存子への影響、復旧案、停止条件、次の承認対象が明確になれば調査完了候補とする。確認不能な重大影響が残る場合は `REVIEW_REQUIRED` または `BLOCKED` とし、次工程を実行しない。

**この指示はRead-only調査のみの承認であり、ACL修正実行、Backup保存先作成、Evidence原本5件のコピー、Restore試験、Git Push、S1-B CompletionまたはG2承認を意味しない。**
