# S1-B Primary Archive空フォルダ検証 Review・次アクション計画 v0.1

- Project: 定型メール作成ツール / P2 Regression Closure
- Review date: 2026-10-21
- Document status: Review Proposal / Not Approved
- Archive Set ID: `ARC-MG-P2-I12-20261018`
- Scope: Primary Archive directory preparation review and next actions; NOT S1-B Completion
- Source: ユーザー提供「Primary Archive空フォルダ作成・検証結果」（2026-10-21 23:21–23:25 JST）

## 1. 結論

指定3階層の作成とNTFS ACL検査は報告上成立した。未承認主体のDACL許可は検出されず、Git Repository・既知のOneDrive同期範囲から分離されている。Codexが `PRIMARY_DIRECTORY_REVIEW_REQUIRED` として停止したことは指示に沿う。

推奨する次のユーザー判断は、個人開発用のEvidence保全に限り、管理共有経由の実効アクセス等の未確認事項を明記して **`PRIMARY_DIRECTORY_ACCEPTED_WITH_RESIDUAL_RISK`** とすること。これは受入れ提案であり自動承認ではない。会社機密・認証情報等が含まれる場合は、この受入れ基準を適用せず別途セキュリティ審査を要する。特にWorkbook内部の機微情報検査は完了していない。

S1-B全体は未完了。原本5件のPrimary/Backupコピー、復元試験、G2承認は未実施。

## 2. 評価表

| 観点 | 判定 | 根拠／限界 |
|---|---|---|
| 指定3階層の新規作成 | PASS（報告上） | 3ディレクトリのみ、ファイル0 |
| Owner / NTFS ACL | PASS（報告上） | 実行ユーザー・SYSTEM・Administratorsのみ継承FullControl、未承認ACE 0 |
| Git分離 | PASS（報告上） | Repository外・`.git`なし |
| 同期分離 | CONDITIONAL | 取得できたOneDrive設定の範囲外。全同期方式までは未証明 |
| SMB管理共有 | RESIDUAL RISK | 共有ACLとNTFS/トークンを組み合わせた他主体の実効アクセス未検証 |
| SMB EncryptData=false | RESIDUAL RISK | 共有設定のみで実通信の暗号化状況を断定しない |
| Raw/Source/Workbook | UNCHANGED | 原本コピーなし、過去のSHA証拠を維持 |
| Backup / Restore | NOT DONE | 媒体・保存先未決定 |
| Git | UNCHANGED | Push禁止継続 |

## 3. Gate運用・承認境界

- `Directory Gate`: ユーザーが残留リスクを認識し、Primary空ディレクトリを保全先として受け入れるか判断する。
- `Copy Gate`: 現行承認済み手順では、Backup媒体・保存先・暗号化・独立性・権限が確認されるまで原本コピーをしない。
- `G2`: 原本→Primary→Backup→隔離されたRestoreコピーのSHA-256一致、取得性、アクセス権限を確認後、ユーザーが承認する。

Primaryコピー先行（Gate B1/B2分離）は改善案に留める。先行する場合には、既存S1-B実施条件書の手順変更と一時的な単一保管先リスクをユーザーが明示承認する必要がある。Gate B1単独ではS1-B完了を宣言しない。

## 4. 次アクション（推奨順序）

### A1 ユーザー：Directory Gate判定

- [ ] `PRIMARY_DIRECTORY_ACCEPTED_WITH_RESIDUAL_RISK` を明示承認するか決定
- [ ] 受容範囲を「当該個人開発Evidence Archive」に限定
- [ ] 管理共有経由アクセス、全同期設定、親ACL将来変更の未確認を残留リスクとして記録
- [ ] 会社機密や認証情報の存在が疑われる場合は停止・別途検討

### A2 ユーザー：Backup媒体の選定

- [ ] Primaryと別の物理媒体を選ぶ（例：暗号化可能な外付けUSBストレージ）
- [ ] 保存先と媒体識別情報を決める
- [ ] 暗号化方式と有効状態を本人が確認できるようにする（回復キー・パスワードをCodex/チャット/Gitへ提出しない）
- [ ] バックアップと独立して回復キー等を安全に保管

### A3 Codex：Backup実施前のRead-only確認

- [ ] 指定された媒体と保存先の存在・状態、別物理媒体性、暗号化の確認根拠、アクセス権限、空き容量、衝突を確認
- [ ] `UNKNOWN`があれば項目と影響を報告
- [ ] Git状態に変更を加えない
- [ ] コピー/フォルダ作成/ACL変更/暗号化の有効化はしない

### A4 ユーザー：EXECUTE_ARCHIVEの個別承認

- [ ] A1–A3の条件を確認し、対象5ファイル・Primary/Backup実パス・必要な新規サブフォルダを明示
- [ ] 作業専用の一時ファイルを使う場合も範囲を明示し、原本変更・上書きを禁止
- [ ] 現行手順を維持するか、B1先行の例外を正式承認するか決める

### A5 Codex：保全実行（A4承認後のみ）

- [ ] コピー直前に原本5件のSize/SHA-256再照合
- [ ] Primaryへ新規コピーしてSHA-256照合（既存同名があれば上書きせず停止）
- [ ] 別物理媒体BackupへコピーしてSHA-256照合
- [ ] 隔離されたRestore先へ実際に復元コピーしSHA-256照合
- [ ] コピー後の読み取り可能性・状態を記録
- [ ] 新規作成したパス・検証結果・未確認事項・失敗履歴を報告
- [ ] Git Add/Commit/Push/Fetch/Pull/履歴変更は禁止

### A6 S1-C / G2（別承認）

- [ ] S1-B Evidenceの結果が確定してから既存Manifestの最小改訂案を作成
- [ ] S1-B完了・G2はユーザーが別途判定する

## 5. 条件別分岐

| 状況 | 対応 |
|---|---|
| Directory Gate承認、Backup媒体未準備 | 原本コピー禁止のまま媒体を準備。必要ならB1先行の例外を別途審査 |
| Backup媒体の暗号化/独立性が確認不能 | `PRECHECK_BLOCKED`継続、推測でCOPY PASSとしない |
| 承認済みBackupが適合 | 個別EXECUTE_ARCHIVE承認を経てコピー・復元試験へ |
| 原本SHA不一致、保存先衝突、ACL不適合 | コピー前に停止・ユーザーへ報告 |

## 6. Codex次回依頼文（Backup媒体が指定された後に使用）

> S1-Bの次作業として、指定されたBackup媒体・保存先の `BACKUP_PRECHECK_ONLY` を実施してください。Primary空ディレクトリ3階層の作成とNTFS ACL検査は完了しています。Directory Gateのユーザー承認状態を報告に記載し、未承認なら受入れ済みとみなさないでください。指定BackupがPrimaryと異なる物理媒体であること、暗号化有効状態、ファイルシステム、共有/アクセス権限、空き容量、保存先衝突の有無を現在の権限で読み取り確認してください。確認不能事項はUNKNOWNとし、実機情報・根拠・必要なユーザー判断をMarkdownで報告してください。ファイル/フォルダ作成、原本コピー、ACL/共有変更、暗号化有効化、管理者昇格、Git操作、Workbook/OFT起動、S1-C開始は禁止です。特に個人パスを含むローカルGit履歴のPushは禁止を継続してください。報告後は停止し、EXECUTE_ARCHIVEへ進まないでください。

## 7. 完了状態

- Primary directory creation / NTFS ACL inspection: **DONE (reported)**
- Primary Directory Gate: **RECOMMENDED FOR ACCEPTANCE / USER DECISION PENDING**
- Backup medium / location: **UNDECIDED**
- Copy / Backup / Restore: **NOT STARTED**
- S1-B / G2: **NOT COMPLETE**
- S1-C / S2: **NOT AUTHORIZED**

## まとめ / Summary

**日本語：** Primary空フォルダは指定どおり作成され、NTFS権限も想定に合っています。残留リスクを明示してDirectory Gateを承認し、別物理媒体の暗号化Backupを選定することが次の重点です。原本コピーとS1-B完了は未承認です。

**English:** The primary folders were created as planned, and NTFS permissions match the design. Next, accept the known limits and choose a separate encrypted backup device. File copying and S1-B completion are not approved yet.
