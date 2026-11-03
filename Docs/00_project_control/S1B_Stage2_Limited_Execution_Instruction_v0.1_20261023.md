# P2 Evidence Archive S1-B — USB Root ACL Stage 2 限定実行指示 v0.1

- **対象**：定型メール作成ツール / P2 Evidence Archive S1-B
- **指示日**：2026-10-23（JST）
- **状態**：Stage 1 `STAGE1_VERIFIED` / Stage 2 **ユーザーが限定実行を明示承認済み、未実行**
- **実行者**：Codex（**通常ユーザー権限の既存セッション**）
- **作業目的**：識別済みBitLocker USB `MG_EVIDENCE_BK`の**Root DACL**から、Everyone（SID `S-1-1-0`）の**Explicit Allow ACE 1件だけを除去**する。
- **対象ボリューム**：事前識別済みのUSB（直近のドライブ文字 `D:`）。**ラベルまたはドライブ文字だけで対象を決めない。**

## 1. 承認の範囲と既存Evidence

ユーザーはStage 2のみを明示承認した。以下の**Read-only照合・1回限りのACL変更・Read-only事後照合**以外は承認されていない。

既存の事前確認：

1. Codex Read-only Precheck（2026-10-23 21:29 JST）：媒体識別・別物理ディスク・Rootの4主体・Owner／継承設定／直下項目・既存Snapshot SHAすべてPASS。Codex通常権限からのBitLockerとSVI照合はアクセス拒否のため`STOP / REVIEW_REQUIRED`（**Root不一致ではない**）。`CODEX_STAGE2_ROOT_PRECHECK_PASS`は**発行されていない**。
2. ユーザーの管理者PowerShell：`Test-SVI-SnapshotPostStage1.ps1`の信頼済みSHA-256一致確認後、`SVI_POSTSTAGE1_READONLY_PASS`、`MediaMatch`、`SnapshotHashesMatch`、`Stage1RootFourAcesMatch`、`RootOwnerUnchanged`、`SVIProtected`、`SVIOwnerMatch`、`SVIDaclMatch`はすべて`True`。
3. ユーザーの管理者PowerShell：`Get-BitLockerVolume -MountPoint 'D:'`で`FullyEncrypted / 100 / Protection On / Unlocked`を確認。
4. `Stage2Authorized=False`は既存の**Read-onlyスクリプトが表示した値**であり、今回のユーザーによるチャット上の**明示承認を否定・更新するものではない**。スクリプトの値を書き換えたり、承認済みと偽って報告したりしない。

上記3種類のEvidenceを組み合わせた**合成事前GateはPASS**とのレビュー結果に基づく。Codex単独PASSへの表示変更・再発行はしない。

## 2. 実行直前の停止条件（Read-only）

以下を**一度だけRead-onlyで再照合**し、すべて満たす場合に限り§3へ進む。確認不能・変化・矛盾が1件でもあれば、**実行せず`STOP / REVIEW_REQUIRED`で報告**。

- 対象は同一のUSB `MG_EVIDENCE_BK`：前回の媒体識別情報、NTFS、容量、物理ディスク識別と一致し、Primary NVMeと別物理ディスク。ドライブ文字が変化した場合は**旧`D:`を操作せず停止**。
- USBは直近の管理者PowerShellによるBitLocker確認後に交換・再接続・状態変更されていない。新たな変更／再接続／疑義があるなら停止し、ユーザーによる管理者再照合に戻す。通常権限でBitLocker確認が拒否されることを理由に、昇格を要求したり同じ失敗を反復したりしない。
- Root DACLは、通常ユーザー（前回照合した**同一SID**）／SYSTEM／Administrators／Everyone（`S-1-1-0`）の**4主体のみ、各1件**。全ACEは`Explicit Allow / FullControl / OI,CI`。未知のACE、重複、Deny、その他の継承ACEがない。
- Root Owner、RootのDACL継承設定、Root直下項目一覧はStage 1後の記録と同一。Root直下は前回確認したSVIのみで、予期しない子ファイル／フォルダがない。
- 非公開の既存Runフォルダ（Run ID `G-PREP-20261022T143534Z-21b5c43a`）内の`Root.before.json`と`SVI.before.json`は存在し、不変。SHA-256：
  - `Root.before.json`: `b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
  - `SVI.before.json`: `f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
- SVIそのものに触れない。SVIの管理者Read-only確認は**ユーザー取得済みのPASSを事前Evidenceとして扱う**。Codexが通常権限でSVI ACLへアクセスできないのは既知の制約であり、回避しない。

## 3. 唯一承認された変更（1回だけ）

§2が全項目一致したら、**通常ユーザー権限で**以下のコマンド**のみ**を実行する。`D:\`が識別済みUSBのRootであることを確認済みであること。コマンドの引数・対象を広げたり、権限昇格したりしない。

```powershell
& icacls.exe 'D:\' '/remove:g' '*S-1-1-0'
$stage2ExitCode = $LASTEXITCODE
```

- `'/remove:g'`：指定したSIDの**Allow ACEを除去**。`'*S-1-1-0'`：Everyoneの数値SID指定。
- 操作対象はRoot **`D:\` 1箇所のみ**。`D:\*`や再帰処理に置き換えない。
- コマンドは**一度だけ**。終了コードにかかわらず、再試行・自動修復・Rollbackを実施しない。
- 実行結果（終了コード、成功／失敗件数、エラーメッセージ）は保持する。**終了コード0だけで最終完了としない**。

## 4. 直後のRead-only事後照合・停止

コマンド後は、**追加の変更を一切行わず**、次をRead-onlyで確認して報告する。

1. 媒体識別・ドライブ文字・物理ディスクが不変。
2. Root DACLに通常ユーザー（同一SID）／SYSTEM／Administratorsの**3主体だけが各1件**、いずれも`Explicit Allow / FullControl / OI,CI`。Everyone Allow ACEなし、未知のACE／Denyなし。
3. Root Owner、DACL継承設定、直下項目がStage 1後から不変。
4. `Root.before.json`／`SVI.before.json`の既知SHA-256が不変（Root Snapshotは**変更前状態**を保持するので、Stage 2後のRoot DACLそのものとの一致は要求しない）。
5. Exit Codeおよび`icacls`の処理成否を記録。失敗／不整合／不明点があれば**停止**。自動Rollback・再試行・新たなACE付与は禁止。

報告は以下の簡潔な形とする。**実パス、個人SID、完全なSDDL、秘密値、保護対象のEvidence原本は出力・Public Gitへ記録しない。**

```text
Stage2Execution: EXECUTED_ONCE / NOT_EXECUTED
Preflight: PASS / STOP
TargetMediaMatch: PASS / FAIL / UNKNOWN
RootFourAcesBefore: PASS / FAIL / UNKNOWN
Command: icacls <USB_ROOT> /remove:g *S-1-1-0
ExitCode: <number / N/A>
RootThreeAcesAfter: PASS / FAIL / UNKNOWN
RootOwnerInheritanceChildrenUnchanged: PASS / FAIL / UNKNOWN
SnapshotHashesUnchanged: PASS / FAIL / UNKNOWN
SVIPostStage2AdminCheck: PENDING
Decision: STAGE2_ROOT_PASS_PENDING_SVI / STOP_REVIEW_REQUIRED
```

`STAGE2_ROOT_PASS_PENDING_SVI`は**Root事後照合までの条件付き状態**であり、`STAGE2_VERIFIED`ではない。報告後、**Codexは停止**。

## 5. ユーザー側の後続確認（Codexには実行許可しない）

ユーザーが管理者PowerShellで、**既存**`Test-SVI-SnapshotPostStage2.ps1`を信頼済みハッシュと照合してからRead-only実行し、SVI Owner／DACL／継承保護、媒体、Root3主体、Snapshotの不変を確認する。スクリプトが必須パラメータを要求する場合は内容を確認し、既存Runフォルダの正しいSnapshotを渡す。スクリプトを変更しない。

CodexのRoot事後照合とユーザーのSVI事後照合の**双方がPASS**して初めて、別途レビューで`STAGE2_VERIFIED`とする。失敗時の復旧は**別承認**。

## 6. 明確な禁止事項・非対象

- 管理者昇格、追加のAccess Grant／Deny、Owner変更、SVI変更、Root継承設定変更。
- `/T`、`/reset`、`/inheritance`、`/C`、`/grant`、`/deny`、`/setowner`、自動Rollback、Retry、外部の修正スクリプト生成。
- Archive／`originals`／Private Index作成、S1 Evidence原本5件コピー、復元試験、S1-C／G2承認、Primary ACL操作。
- Git commit／push、Public Repoへの個人情報・実パス・Snapshot／生Evidenceの追加、Baseline／Approved文書の更新。
- Stage 2完了を口実としたバックアップ方式の追加設計やS2〜S6への自動移行。

**終了地点：Stage 2のRoot事後照合を報告して停止する。** 以後の管理者SVI照合、正式完了判定、S1 Evidence Archiveは別工程。
