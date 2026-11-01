# S1-B USB ACL Remediation — Design Review & G-PREP Action v0.1

- Project: 定型メール作成ツール（Excel VBA / Classic Outlook）
- Date: 2026-10-22 JST
- Status: **Review completed / G-PREP proposed / Changes NOT APPROVED**
- Source: Codex `S1-B USB ACL Remediation Design 最終レビュー` (`REMEDIATION_DESIGN_READY`, 2026-10-22 23:12–23:15 JST)
- Evidence classification: Codex local read-only checks = `VERIFIED` as reported by Codex; user PowerShell output = `USER_PROVIDED_OS_OUTPUT`; not independently inspected by ChatGPT.

## 1. Review Decision

**Design: READY (conditional acceptance).** `REMEDIATION_DESIGN_READY` is a readiness assessment, not execution permission. The existing `BACKUP_PRECHECK_BLOCKED` and `EXECUTE_ARCHIVE` not approved remain unchanged.

- Target USB: `MG_EVIDENCE_BK`, last observed `D:`, ELECOM MF-BSU3, NTFS, Disk 1; re-identification required each session.
- BitLocker: user-provided OS output `FullyEncrypted`, 100%, protection `On`, `Aes128`, unlocked, auto-unlock disabled.
- Current USB root: one explicit inheritable `Everyone / FullControl` ACE.
- SVI: user reported `AreAccessRulesProtected=True`; read-only snapshot of owner and DACL not yet persisted.
- Preferred correction A: root only, grant normal-user/SYSTEM/Administrators full control (OI/CI), validate, then separately consider removing Everyone.
- No recursive operation (`/T`, `/reset`), owner change, administrative privilege escalation by Codex, automatic rollback, or automatic progression to stage 2.

## 2. Pre-execution Gaps

1. No permanently saved root ACL/DACL snapshot; candidate rollback directory is not yet created.
2. No permanently saved SVI owner/DACL snapshot for before/after comparison.
3. Normal-user SID must be frozen from the *non-elevated* session; do not substitute administrator-session identity.
4. The exact authorization scope and acceptable residual risk of using the private rollback folder are not yet approved.
5. No Stage 1 execution approval, and no Stage 2 execution approval.

## 3. Next Action (recommended): G-PREP / Snapshot Preparation

**Approval boundary:** User must explicitly approve the following limited file creation before Codex performs it. Approval of G-PREP does **not** approve any ACL modification.

Proposed private target (not yet created):

```text
%USERPROFILE%\PrivateEvidenceArchive\MailGenerator\
  ACL_Remediation_Rollback\<UniqueRunID>\
```

### Approved scope to request separately

- Codex: re-identify target media; confirm expected USB root and parent-folder state read-only; capture normal-user SID and root owner/DACL/inheritance; create **only** the specifically approved new rollback directory and `Root.before.json`, without overwriting; read back and calculate SHA-256. Report minimal nonsecret status; do not publish SID/SDDL or device serial.
- User (elevated PowerShell): collect SVI owner/DACL and protection flag and save as `SVI.before.json` in the same private folder **only after explicit approval of that save action**. Keep raw SDDL and SIDs local; report comparison or SHA results instead of content.
- Validate snapshots and folder access before any ACL change. If any mismatch, abort preparation without unapproved cleanup.

**Exclusions:** ACL changes, BitLocker changes, owner changes, admin elevation by Codex, recursive enumeration, copies of the five original evidence items, archive `originals`, Private Index, Git add/commit/push/fetch/pull, S1-C, G2.

### Conditions for `G-PREP_COMPLETE`

- Physical USB identity and unchanged starting USB root ACL confirmed.
- Normal-user SID equals expected USB root owner; SID safely recorded and frozen.
- Private rollback folder is outside the repository and known OneDrive sync root; no reparse points; no conflicting files; no open permission to unapproved principals.
- `Root.before.json` and `SVI.before.json` saved, reread, SHA-256 recorded, and SVI `AreAccessRulesProtected=True` verified.
- Baseline owner/DACL captured sufficiently for post-stage comparison; failures and UNKNOWN explicitly recorded.
- No modifications to the USB root DACL or original evidence.

## 4. Gate Sequence

| Gate | Activity | Authority / Status |
|---|---|---|
| G-PREP | Create private rollback directory and before-snapshots only | Separate user approval required |
| G-ACL-1 | Add three grant ACEs while Everyone remains; verify 4 ACEs and unchanged SVI | Separate user approval required **after** G-PREP |
| G-ACL-2 | Remove Everyone grant; verify exactly three ACEs and unchanged SVI | Separate user approval required **after** G-ACL-1 review |
| G-ACL-POST | Create backup empty directories and verify inherited ACL | Separate authorization |
| G-PRIMARY | Accept or treat primary archive residual management-share risk | User decision still pending |
| EXECUTE_ARCHIVE | Five original copies + SHA checks + restore test | Separate user authorization after gates |
| S1-C / G2 | Private manifest and evidence archive closure | After archive execution |

Do not claim S1-B completion on design readiness or G-PREP alone.

## 5. Codex Instruction — G-PREP Planning Only (safe to run now)

> 定型メール作成ツール S1-B のACL変更準備について、**Read-only**でG-PREP実行範囲を最終点検してください。対象USB `MG_EVIDENCE_BK`の媒体再識別、USBルートACLと通常ユーザーSIDの確認、候補退避先の存在・Git/OneDrive/Reparse・ACL状態、`Root.before.json`と`SVI.before.json`の具体的な収集手順・記録項目・読み戻し方法・停止条件を整理してください。`SVI.before.json`はユーザーの管理者PowerShellで取得する前提です。**ファイル／フォルダ作成、ACL変更、BitLocker変更、管理者昇格、Git操作、原本コピーを行わないでください。** 出力は`G_PREP_PLAN_READY`／`REVIEW_REQUIRED`／`BLOCKED`のいずれかとし、次のユーザー承認が必要な操作を列挙して停止してください。

## 6. Residual Risk Notes

- A protected SVI DACL prevents ordinary inheritance changes to its DACL but does not guarantee unchanged OS function or every child object.
- Root `Everyone: FullControl` remains until G-ACL-2 succeeds; BitLocker protection when the drive is locked does not replace access controls while unlocked.
- Private rollback folder resides beneath the previously reviewed Primary candidate and is subject to the still-open management-share risk assessment. A G-PREP-only risk acceptance does not automatically approve the Primary evidence archive.
- Rollback from saved DACL should be treated as an independently authorized limited recovery, not an automatic or complete transaction rollback.

## 7. Summary / まとめ

**日本語:** 設計は条件付きでREADY。次の作業は、承認された範囲に限定した永続退避準備（G-PREP）。Stage 1、Stage 2、Evidenceコピーは未承認。

**English:** The design is ready with conditions. The next step is to prepare saved ACL backups with approval. Do not change the USB ACL or copy evidence yet.
