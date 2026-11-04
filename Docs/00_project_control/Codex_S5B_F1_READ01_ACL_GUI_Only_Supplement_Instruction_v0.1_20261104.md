# S5-B F1-READ-01：ACL情報のGUI限定補完

Codexの静的レビュー結果を受け入れます。

`S5B_F1_READ_01_CloneACL_ReadOnly.ps1`は、全ローカルアカウント照会とパス検査順序の懸念が残るため、現行版の実行を承認しません。無断修正も行わないでください。

次は`RESOURCE-CLONE-A`のルートフォルダーに限定し、ユーザーがWindows標準GUIから手動確認した情報を受領してください。

確認対象：

1. ACL継承の有効／無効
2. 匿名化した許可先の主体区分、Allow／Deny、権限内容、明示／継承
3. Users／Authenticated Users／EveryoneのACE有無
4. 対象フォルダーの直接共有状態

実パス、実ユーザー名、SIDは報告しません。

フォルダー内容のOpen・列挙、ACL編集、管理者昇格、PowerShell実行、既存Excel操作、専用ユーザー作成は許可しません。

GUIで確認できない項目はUNKNOWNとして記録してください。

結果の報告後に停止し、F1-3～F1-5、AUTH-01～AUTH-06へ進まないでください。

```yaml
F1Read01Decision: REVIEW_REQUIRED
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
PreflightAuthorization: NOT_GRANTED
```

既存Closure、限定付きEvidence、Finding／Observation、Baseline履歴を維持してください。
