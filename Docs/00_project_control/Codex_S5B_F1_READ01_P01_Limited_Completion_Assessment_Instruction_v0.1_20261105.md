# S5-B F1-READ-01：P01調査の限定完了評価

今回のUSER_ATTESTED / USER_MANUAL_COMMANDの結果を受け入れます。

P01の直接メンバー確認は、限定付きで完了したものとして評価してください。

確認済み事項：

- 対象PC：S5B-TestPC-01（ユーザーGUI確認）
- コマンド：通常の非昇格セッションで1回実行
- 結果：SUCCESS_REPORTED
- 照会した同名主体：LOCAL_GROUP
- 直接メンバー：2件（M01、M02）

維持するUNKNOWN：

- ACL上のP01とのSID一致
- M01・M02の主体区分
- 推移的グループ所属
- 個別WorkbookのACL
- 将来の専用ユーザーの実効アクセス

上記UNKNOWNを、確認済み事項として扱わないでください。

次は新たなPC操作を行わず、既存Evidenceだけに基づいてF1-READ-01全体をCOMPLETE_WITH_LIMITATIONSと判定できるか評価してください。

判定できない場合は、残る必須確認事項とその理由を明示し、REVIEW_REQUIREDを維持してください。

```yaml
C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

追加コマンド、ACL変更、ユーザー作成、Excel操作、Preflight実行、Git操作は禁止します。

F1-3～F1-5、AUTH-01～AUTH-06には進まず、評価結果を報告して停止してください。
