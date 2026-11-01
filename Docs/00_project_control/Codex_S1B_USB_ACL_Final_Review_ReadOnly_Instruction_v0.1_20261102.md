# Codex作業指示：S1-B USB ACL Remediation Design 最終レビュー

## 目的

前回の`S1-B USB ACL Remediation Design`の`REVIEW_REQUIRED`について、追加Evidenceを反映し、案Aの実行承認に進めるか評価してください。

今回は**Read-only調査・設計レビューのみ**です。

## 追加Evidence

ユーザーが管理者PowerShellで以下を実施しました。
```sql
(Get-Acl -LiteralPath 'D:\System Volume Information' -ErrorAction Stop).AreAccessRulesProtected
```

実行結果：
```
True
```

Evidence分類：`USER_PROVIDED_OS_OUTPUT`

これはSVIのDACLが親からの継承に対して保護されていることを示します。Codexによる独立再検証ではありません。

## 実施内容

1. 前回確認したUSB媒体識別結果およびルートACLをRead-onlyで再確認する。
2. SVIの継承保護を踏まえ、案Aの影響評価を更新する。
3. USBルートの3主体へのACL変更手順を再評価する。
4. 既存子要素への想定影響と残留リスクを明示する。
5. 変更前DACLの永続退避先・退避方法・復旧手順を具体化する。
6. 管理者実行アカウントと通常利用ユーザーのSIDが異なる場合の誤設定防止策を定義する。
7. 変更前後のSVI DACL比較方法を提示する。必要な確認操作はユーザー実施としてよい。
8. ACL変更を段階的に承認・検証する手順を提示する。
9. 実行承認前の未解決事項と停止条件を整理する。

不要なSVI内部の再帰調査は提案しないでください。

## 禁止事項

- ACL・Owner・BitLocker設定の変更
- ファイル作成、コピー、削除
- 原本Evidenceの変更
- 管理者昇格
- Git操作・Repository変更
- S1-B Evidenceコピー・S1-C着手

変更用コマンドは提案のみとし、実行しないでください。

## 出力

以下を報告してください。

- 新しいEvidenceによって解消した不確実性
- 案Aの採否と判断理由
- 修正対象・コマンド案・実行権限
- 永続退避・復旧手順
- 修正前後の検証方法
- 残留リスクとUNKNOWN
- ユーザーによる次の承認事項

最終判定は次のいずれかとしてください。

- `REMEDIATION_DESIGN_READY`
- `REVIEW_REQUIRED`
- `BLOCKED`

`REMEDIATION_DESIGN_READY`であっても、ACL修正の実行承認を意味しません。結果報告後に停止してください。
