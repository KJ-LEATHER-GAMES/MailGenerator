# Codex作業指示：G-PREP Snapshot Final Verification（Read-only）

S1-B G-PREPのRoot Snapshot保存は完了しました。

ユーザーによるSVI Snapshot保存結果を受けて、Stage 1実行前の最終整合性確認を実施してください。

**今回はRead-only検証のみを承認します。ACL変更は承認しません。**

## 確認対象

- G-PREP Run ID：`G-PREP-20261022T143534Z-21b5c43a`
- Root Snapshot：`Root.before.json`
- Root Snapshot SHA-256：`b0663196d137eb30bd69c9536394de2a40c25a8d48e402cf8358431316b4d847`
- SVI Snapshot：`SVI.before.json`

## 検証事項

1. USB媒体の再識別とRoot Snapshotとの対応確認。
2. Root／SVI Snapshot双方の存在、サイズ、SHA-256、JSON読み戻し。
3. Run ID、Root Snapshot参照SHA、媒体情報の整合性。
4. 保存先ファイルのACLが承認済み3主体に限定されていること。
5. SVIの`AreAccessRulesProtected=True`。
6. SVIの保存済みOwner・DACLが、現在取得可能な情報と整合するか確認。権限不足ならUNKNOWNとし、管理者昇格しない。
7. USBルートのOwner・DACLがG-PREP時点から変更されていないこと。
8. Stage 1実行前の残留リスクと停止条件。

## 禁止事項

ACL・Owner・BitLockerの変更、ファイル作成・修正・削除、原本コピー、管理者昇格、Git操作、Stage 1／Stage 2実行は禁止します。

## 最終報告

`STAGE1_PRECHECK_READY`／`REVIEW_REQUIRED`／`BLOCKED`のいずれかで報告してください。

READYであってもStage 1の実行承認とは扱わず、結果報告後に停止してください。

SID・SDDL等の機微情報は報告本文に出力しないでください。
