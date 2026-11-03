# P2 Evidence Archive S1-B — Stage 2 実行済み・事後検証指示 v0.1

- 日付：2026-10-23（JST）
- 状態：`STAGE2_EXECUTED_PENDING_VERIFICATION`
- 目的：既にユーザーが実行したUSB RootのEveryone Allow ACE除去について、**Read-onlyの事後確認のみ**を行う
- 本指示は、旧 `S1B_Stage2_Limited_Execution_Instruction_v0.1_20261023.md` の**未実行だったCodex実行手順を置き換える**。旧指示に含まれる `icacls /remove:g` は実行しない。

## 1. 既に確定している実施事実（ユーザー提供のOS出力）

対象：前回識別済みのBitLocker USB `MG_EVIDENCE_BK`（実行時 `D:\`）。

- ユーザーが管理者PowerShellで `icacls.exe 'D:\' '/remove:g' '*S-1-1-0'` を**実行済み**。
- `1 個のファイルが正常に処理されました。0 個のファイルを処理できませんでした`、`$LASTEXITCODE = 0`。
- 直後の `icacls.exe 'D:\'` で通常ユーザー・SYSTEM・Administratorsの3主体、各 `(OI)(CI)(F)` を確認。Everyoneは出力されなかった。
- CodexにはStage 2の実行指示をまだ送っていない。したがって**Codexによる事前確認および実行は行われていない**。
- 変更実行前には、CodexのRoot等の事前照合、ユーザー管理者による`SVI_POSTSTAGE1_READONLY_PASS`、BitLocker `FullyEncrypted/100/Protection On/Unlocked`の確認があった。ただしCodexの**実行直前確認は行われていない**。これを遡及してPASS扱いしない。
- 現時点で`STAGE2_VERIFIED`は宣言していない。

## 2. Codexの作業範囲：Read-only事後確認だけ

既存の**通常ユーザー権限のセッション**で以下を確認する。新しいツール、修正スクリプト、管理者昇格は行わない。

1. 対象USBの媒体情報（ラベルに加えて物理ディスク・容量・NTFS・ドライブ文字）が直近の照合記録に一致し、Primary NVMeとは別物理ディスクであること。変更・再接続・対象の疑義があれば停止。
2. Root DACLが**通常ユーザー（前回と同一SID）、SYSTEM、Administratorsの3主体だけ／各1件／Explicit Allow・FullControl・OI/CI**であること。Everyone（SID `S-1-1-0`）、未知ACE、Deny、重複がないこと。
3. Root Owner、Root DACL継承設定、直下項目一覧がStage 1後の記録と変わらないこと。通常権限で取得できない項目はUNKNOWNのまま報告し、権限を拡大しない。
4. G-PREP既存Runフォルダ `G-PREP-20261022T143534Z-21b5c43a` 内の変更前Snapshot2件が存在し、SHA-256が次の既知値と一致すること。
   - `Root.before.json`: `b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
   - `SVI.before.json`: `f30a3452d2b85ceb92c7e8b7b5a1f90754b50cf2266a561a81579d86166b731c`
5. **変更前Root SnapshotはEveryoneが存在した時点のもの**。現在の3主体DACLとの完全一致は求めず、Snapshotそのものの不変と既存Stage 1後の記録との適切な比較を行う。
6. SVIの現在ACLを無理に読まない。管理者PowerShellの既存検証スクリプトで別途照合するため`SVIPostStage2AdminCheck=PENDING`とする。

### 絶対禁止

- `icacls /remove:g`の再実行、`/grant`、`/reset`、`/T`、権限追加・削除・変更、Owner変更、継承設定変更、SVI変更、Rollback、Retry。
- Archive／原本コピー／復元試験、Primary ACL操作、Git操作、Baseline／Approved文書修正。
- 個人の実パス、SID/SDDL全文、秘密値、Evidence原本をPublic Gitに転記すること。

## 3. Codex報告書式

```text
Stage2Operator: USER_ADMIN_POWERSHELL
Stage2CommandAlreadyExecuted: YES (once, user reported)
Stage2ExitCodeUserReported: 0
CodexStage2Mutation: NOT_PERFORMED
CodexImmediatePreExecutionCheck: NOT_PERFORMED
MediaMatch: PASS / FAIL / UNKNOWN
RootThreeAcesAfter: PASS / FAIL / UNKNOWN
RootOwnerInheritanceChildrenUnchanged: PASS / FAIL / UNKNOWN
SnapshotHashesUnchanged: PASS / FAIL / UNKNOWN
SVIPostStage2AdminCheck: PENDING
Decision: STAGE2_ROOT_POSTCHECK_PASS_PENDING_SVI / STOP_REVIEW_REQUIRED
```

報告後に**停止**。`STAGE2_VERIFIED`を自動宣言しない。

## 4. ユーザーの別作業：管理者SVI照合

Codex事後確認がPASSしたら、ユーザーが管理者PowerShellで**既存**の `Test-SVI-SnapshotPostStage2.ps1` を信頼済み原本のSHA-256と照合し、内容と必須パラメータを確認してからRead-onlyで実行する。Snapshot引数を要求されたら既存非公開Runフォルダ内の正しいファイルを渡す。スクリプトは改変しない。

期待する観点：対象媒体一致／Root3主体／Root Owner不変／Snapshot SHA一致／SVI継承保護・Owner・DACL不変。実際のスクリプト出力を保存し、PASS/FAILを都合よく読み替えない。

## 5. 判定と以降

- Codex Root事後照合がPASS、かつ管理者SVI事後照合がPASSした場合に、別途レビューで`STAGE2_VERIFIED`を判定する。
- 不一致・UNKNOWNがあれば`STOP / REVIEW_REQUIRED`。**自動修復しない**。復旧操作は別承認。
- 手順差異（ユーザー管理者実行、Codexによる変更直前確認なし）は実行記録に明記。ただし機械的に再実行・Rollbackを要求しない。
- Stage 2完了後は、既存S1の残件（Primary残留リスク判断、Evidence 5件の保存・SHA照合・復元試験、Manifest、G2）に戻る。バックアップの追加設計を始めない。
