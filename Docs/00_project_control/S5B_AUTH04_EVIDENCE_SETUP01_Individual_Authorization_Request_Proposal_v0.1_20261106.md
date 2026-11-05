# AUTH-04-EVIDENCE-SETUP-01 個別承認依頼案

**Status:** READY_FOR_USER_APPROVAL / NOT_GRANTED

**Target PC:** S5B-TestPC-01

**Operator:** ユーザー本人（管理側操作主体）

## 目的

S5-Bの今後の実行Evidenceを保存するため、管理側ローカルプロファイル内に専用のEVIDENCEフォルダーを準備する。

## 事前Evidence

- AUTH-04-B1-LOCATOR-CHECK-01：COMPLETED_WITH_LIMITATIONS
- ManagementProfile：IDENTIFIED_BY_USER
- SyncCondition：NO_KNOWN_SYNC_INDICATION
- ShareCondition：NO_SHARED_INDICATION
- FolderCollision：NO_VISIBLE_COLLISION
- StopReason：NONE
- FileMutation：NONE_USER_ATTESTED
- PCConfigurationMutation：NONE_USER_ATTESTED

## 承認対象

1. 管理側ローカルプロファイルの確認済み候補親領域で、対象パスと既存状態を確認する。
2. 承認情報、作業開始日時、対象を手書きで記録する。
3. 対象が存在せず、STOP条件に該当しない場合に限り、`S5B\EVIDENCE`を新規作成する。
4. 作成フォルダーの全般・共有・セキュリティプロパティを閲覧する。
5. 作成結果と終了日時を手書きで記録し、匿名化して報告する。

## 禁止事項

- ACL・所有者・継承設定の変更
- 管理者権限への昇格
- STAGE／WORKの作成
- Evidenceファイルの新規保存
- USB移動・接続・コピー・BitLocker操作
- ネットワーク・PC設定変更
- Excel／VBE／Outlook起動、Compile
- Codexによる実機操作
- Git・Approved仕様・Baseline・既存Evidence変更

## STOP条件

対象パス不一致、既存対象との衝突、想定外のACL、同期・共有・リダイレクト、管理者認証要求、Evidence記録不可、その他の予期しない操作要求。

STOP時は、自動再試行、修正、削除、代替場所への作成を行わない。

## 実施後の判定

- EVIDENCEフォルダー作成：SUCCESS / BLOCKED / NOT_EXECUTED
- 同期・共有・ACLの異常：NONE_OBSERVED / FOUND / UNKNOWN
- 許可範囲外の変更：NONE_USER_ATTESTED / CHANGED / UNKNOWN
- STOP理由
- 次の個別承認に必要な事項

フォルダー作成成功のみでは、アクセス隔離やEvidence保存環境の安全性PASSとは扱わない。

**本依頼は承認判断用の案であり、実行承認ではない。**
