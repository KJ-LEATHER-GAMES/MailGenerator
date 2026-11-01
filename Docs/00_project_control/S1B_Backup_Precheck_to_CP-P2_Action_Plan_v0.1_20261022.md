# S1-B Backup Precheck ～ P2 Phase Exit アクション計画 v0.1

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール（Excel VBA + Classic Outlook） |
| 作成日 | 2026-10-22 |
| 文書種別 | Project Control / Execution Action Plan（提案） |
| Status | Proposed / 未承認 |
| 計画起点 | `Context_Handoff_S1B_Backup_Precheck_20261022_v0.1(1).md` |
| Repository内の推奨保存先 | `Docs/00_project_control/S1B_Backup_Precheck_to_CP-P2_Action_Plan_v0.1_20261022.md` |
| 変更権限 | 本計画の作成は実機操作、原本コピー、Repository編集、Commit、Push等の承認を意味しない |

## 1. 目的と計画方針

P2の技術的PASSを過大申告せず、原本Evidenceを安全に保全した後、正式なRegression Closure、Baseline／Project Control整合、P2-05 Completion、P2 Phase Exit（CP-P2）に進む。

以下を分離する。

- 実装・テストの技術的PASS
- 原本Evidenceの存在／同一性／Archive保全
- Unit／Regression Recordの正式Closure
- Baselineの承認・現行管理文書との整合
- P2-05のCompletion Decision
- P2 Phase Exit／Checkpoint確立

既存計画の依存順序 **S0 → S1 → S2 → S3 → S4 → S5 → S6** を維持する。PrimaryとBackupを別Gateに分割してPrimaryコピーを先行する案は採用済みではないため、今は行わない。

## 2. 引継ぎから確定している現在地

| 対象 | 状態 | 根拠／注意 |
|---|---|---|
| S0 | Inventory Complete | Codex現物調査の報告。正式Closureの代替ではない |
| S1-A／G1 | Archive基本方式をユーザー承認済み | PrimaryはGit管理外の非公開領域、Backupは別の暗号化物理媒体 |
| Primary空ディレクトリ | 作成・Read-only調査済み | Codex判定 `PRIMARY_DIRECTORY_REVIEW_REQUIRED`。原本未コピー |
| USB初期設定 | `USER_ATTESTED` | ラベル `MG_EVIDENCE_BK`、直近のドライブ文字 `D:`。BitLocker解除成功等は実測未確認 |
| S1-B Backup Precheck | NOT RUN | 次のCodex作業 |
| `EXECUTE_ARCHIVE` | NOT APPROVED | Primary／Backupコピー、Restore試験は禁止継続 |
| S1-C／G2 | NOT STARTED | Manifest更新、保全結果審査待ち |
| P2-01 Regression | 既存記録上 PASS/CLOSED | P2 Phase Exitを意味しない |
| P2-02／P2-03／P2-04 | 技術的PASS Evidenceあり | 回帰記録の正式Closure／I12 documentary closureは未了 |
| BL-MVP-004 | Approval RecordはAPPROVED | Registry／OverviewがBL-MVP-003、Approved正本不足など整合未了 |
| P2-05 | Completion未了 | Compile、Static Review S01-S32、Patch Review、Finding Assessment等が必要 |
| Git Push | 禁止継続 | Public Repoと個人パス入りRawのローカルGit追跡履歴がある |

### Evidence参照ルール

原本5件のLogical ID、ファイル名、Byte数、SHA-256の既存照合値は、引継ぎ文書 §「Evidence 5件の識別値」を照合基準とする。別の値に差し替えない。CodexのS0再集計として P2-02 111/111、P2-03 46/46、P2-04新Cycle 182/182 が報告されているが、これだけでWorkbook内部の全VBA一致、過去全Run同一性、Formal MVP Test PASSは認定しない。I10初回ABORTをPASSに含めない。

## 3. 実行計画と停止条件

| ID | Step／実行主体 | 内容 | 完了・判定基準 | Gate／停止条件 |
|---|---|---|---|---|
| A01 | S1-B Backup Precheck／Codex | 既存の前チャット末尾の正本 `S1-B Backup Precheck 実施指示（Read-only）` を実行。媒体識別、別物理ディスク性、BitLocker状態、NTFS、容量、候補保存先の衝突、Primary継続性を確認 | `BACKUP_PRECHECK_PASS` / `REVIEW_REQUIRED` / `BLOCKED`。事実とUNKNOWNを別記 | **Read-onlyのみ**。生成・コピー・初期化・設定変更・管理者昇格・Git操作禁止 |
| A02 | Precheck Review／ChatGPT・ユーザー | A01の実測証拠をレビュー。Primaryの管理共有／実効アクセス等の残留リスクを「受容」または「追加措置必要」で明示判断 | 媒体の適否とPrimaryの残留リスク判断を記録。判断不能は保留 | BitLocker保護無効、物理独立性なし、重大なアクセス不備等はコピーに進まない |
| A03 | `EXECUTE_ARCHIVE` 範囲確定／ChatGPT・ユーザー | 5原本、コピー元とPrimary／Backup保存先、作成を許すディレクトリ、上書き禁止、ハッシュ照合、復元試験の隔離先／後始末を列挙。ユーザーの明示承認を取得 | 対象・パス・操作・禁止事項が一意で承認済み | A01/A02未解決、または承認なしなら作業停止 |
| A04 | S1-B Evidence保全／Codex | コピー直前の5件サイズ・SHA再計測 → 新規のPrimary保存 → 別物理USB Backup保存 → 両コピー全5件SHA照合 → Backupから隔離場所へ5件を復元しSHA照合 | 全5件の原本・Primary・Backup・復元物が一致。実施環境、日時、異常／再試行記録を保全 | 衝突、SHA不一致、想定外の既存ファイル、アクセス不備で停止。原本・Workbook・Sourceは変更しない |
| A05 | S1-C／G2／Codex・ChatGPT・ユーザー | 既存Archive Manifestを最小改訂。公開可能な論理IDと非公開のPrivate Locatorを分離して記録。Codex技術報告をユーザーがG2審査 | 保管証跡、位置情報、アクセス前提、SHAとRestore結果、留保事項の記録・G2明示判断 | G2前に「S1正式完了」を主張しない。実パス、Raw、秘密情報をPublic Gitに配置しない |
| A06 | S2／Codex・ChatGPT・ユーザー | P2-02／P2-03 Regression Recordを原本ログ・対象Build・テスト範囲に基づき正式レビュー／Closure | 各Recordの対象、結果、Finding、制約、承認履歴が明示されてClosed | 技術PASS数だけで承認しない |
| A07 | S3／Codex・ChatGPT・ユーザー | P2-04新CycleおよびI12のdocumentary closure | I12 `TECHNICAL PASS / REVIEWED` から正式文書Closureへ。失敗／ABORT・異Revisionの扱いを明記 | 初回I10 ABORTや過去Runを今回のPASSに読み替えない |
| A08 | S4／Codex・ChatGPT・ユーザー | `BL-MVP-004_Approval_Record`、Approved文書正本、`Document_Registry.md`、`Project_Overview.md` の整合を点検・修復 | Approved Baseline IDとManifest、Repositoryの文書正本、Project Controlの表示が一致 | BL-MVP-003を無審査でBL-MVP-004に上書きしない。実更新は別承認 |
| A09 | S5／Codex・ユーザー・ChatGPT | 現行BuildのVBA Compile、P2-05 Static Review S01-S32、Production Patch Review、Final Finding Assessment、Active／Blocking Finding数の集計、Completion Decision | 正式P2-05 Completion記録とBlocking 0の根拠が揃う | `OBS-P2-05-002` OPEN/NON-BLOCKING維持。根拠なき「解消」不可。Formal MVP Test PASSを主張しない |
| A10 | S6／ユーザー | P2 Phase Exit Criteriaを一括照合し、CP-P2判定 | 依存Gate／文書／Source／Evidenceが揃ってPhase Exitを明示承認 | 依存Gateに未承認・BlockingがあればCP-P2を確立しない |

## 4. A01で求める出力項目（新指示ではなく、正本との照合チェック）

- ドライブ文字は再接続で変動し得るため、ラベル `MG_EVIDENCE_BK` だけでなく実ディスク番号・BusType・対象Volumeとの対応、Primary所在OSディスクとの相違を確認する。個人識別性の高い完全なSerial等は公開文書に転記しない。
- 期待するBitLocker実測：完全暗号化、Protection On、作業中は本人解除済みのUnlocked、対応するVolumeがNTFS。取得不能項目は `UNKNOWN`、推定を `PASS` にしない。
- Backup候補（前回申告 `D:\MailGenerator\P2_I12_20261018\`）の存在／衝突、空き容量、実効書込みの可否を**書込み試験せず**確認できる範囲で調べる。ドライブ文字を固定前提にしない。
- Primaryの既存3階層について、作成済み・空であること、Git管理外・既知同期範囲外の前回評価が現時点でも変化していないことを再確認する。管理共有のリスクは自動的に受容扱いにしない。
- 観測結果は `VERIFIED / USER_ATTESTED / UNKNOWN` を区別。Read-onlyではファイル生成やWindows設定変更をしない。
- 判定は `BACKUP_PRECHECK_PASS` / `REVIEW_REQUIRED` / `BLOCKED` のいずれか。必要なら一次判定と未確定事項を分離する。

**注意**：引継ぎには前チャット末尾のCodex正本指示の全文が含まれていない。本表はその正本の代替・自動改訂ではない。原指示が手元にある場合は、重複した実行指示を発行せず原指示一つを使う。

## 5. ユーザー承認の境界

1. A01は既に策定済みRead-only指示の範囲で実施。対象外の書込み・管理者権限昇格は認めない。
2. A02でPrimary残留リスクを明示判断。判断保留ならA04を開始しない。
3. A03で実コピー／新規ディレクトリ作成／復元用ファイル作成／後始末の許可範囲を別途承認する。A01のPASSはコピー承認ではない。
4. A04の結果確認後にS1-C記録更新範囲とG2を判断する。
5. Git `Add`／`Commit`／`Push`、履歴改変、強制Push、リモート操作はArchive作業と切り離して別途判断する。Public Repoへの危険な履歴Pushは引き続き禁止。

## 6. レビューで特に重視する懸念点

- **保管先の安全性**：PrimaryはローカルACLの観測だけでネットワーク経由の実効アクセスが完全否定されたわけではない。危険性・脅威モデル・受容理由を明示。
- **媒体の独立性**：`D:`／USBラベルだけでは別物理媒体の証明にならない。物理ディスク／Volumeの対応が必須。
- **機微情報**：生ログの個人パスやPrivate Locatorは公開Repoの計画書・Manifestに記載しない。BitLockerのパスワード・回復キーはChatGPT／Codexへ提示しない。
- **整合性の限界**：9/9 Sourceの正規化一致はバイト一致・Workbook VBAProject全体の独立一致ではない。Workbook SHAの一致は過去実行の独立証明ではない。
- **文書管理負荷**：Archive台帳は既存Manifestを軸とし、不要な新規Registryや技術文書Version Upを増やさない。
- **非再現性Observation**：`OBS-P2-05-002`を原因確定・修正済みとして扱わない。

## 7. 次回のレビュー入力

A01が完了したら、CodexのRead-only報告をそのままレビューし、次の項目だけをまず判定する。

| 判定項目 | 結果 |
|---|---|
| 媒体識別・OSディスクとの独立性 | PASS / REVIEW / BLOCK / UNKNOWN |
| BitLocker完全暗号化・Protection・Unlock | PASS / REVIEW / BLOCK / UNKNOWN |
| NTFS・容量・Backup候補パスの衝突 | PASS / REVIEW / BLOCK / UNKNOWN |
| Primary継続性・残留リスク | 受容検討 / 追加措置 / 保留 |
| `EXECUTE_ARCHIVE`承認準備 | READY / NOT READY |

## 8. まとめ / Summary

**日本語：** 直近はA01のUSB Backup Read-only Precheckを実施する。結果をレビューしPrimaryの残留リスクをユーザーが判断した後、A03で原本5件のコピー・検証・復元試験を明示承認する。その後、S1-C／G2、S2〜S6の正式Closureを進める。

**English:** First, run the read-only USB backup check. Review the results and decide if the Primary archive risk is acceptable. Approve the file copy and restore test separately. Then complete the archive and the P2 closure steps.
