# 記事用素材

- **題材**：Excel VBA＋Outlook Classicで開発する定型メール作成ツール。P2 Regression Evidenceの保全作業から、USB Backupの暗号化・ACL・証拠Snapshotへ派生し、開発の主目的へ戻るためにスコープ制御を見直した記録。
- **事実の扱い**：ユーザーPowerShell出力／Codex実行報告による確認、未実施作業、記事上の解釈や提案を区別する。記事公開時にはユーザー名、個人SID、絶対パス、秘密情報、生ログを匿名化する。

## 気づき

- **技術的に正しい一歩が、必ずしもプロジェクト全体の最短経路とは限らない。** Evidenceを守ろうとして、保管先→媒体→暗号化→ACL→Snapshot→復旧計画と確認が連鎖した。
- **技術的PASSと正式な完了判定は違う。** P2-02（111/111）、P2-03（46/46）、P2-04（182/182）は技術Regression PASSだが、正式ClosureやPhase Exitとは別。
- **Securityを『設定した』と『確認した』は別。** BitLocker利用申告から、PowerShellでFullyEncrypted／100%／Protection On／AES-128を確認する段階に進んだ。
- **暗号化とアクセス権は別の層。** BitLockerが有効でも、解除されたUSB上にEveryone FullControlが残っていれば、利用時の権限制御に関する問題は残る。
- **ACLの親子継承は想像より複雑。** `icacls /T`を使わなくても継承可能ACEの変更が子に及び得るため、SVIの`AreAccessRulesProtected=True`を確認し、前後比較を実施した。
- **OwnerとDACLは区別する。** SVI SnapshotファイルのOwnerがAdministratorsでも、DACLに未承認主体が含まれるとは限らない。
- **操作を分けると検証しやすい。** Stage 1で3主体を追加し、4主体の状態を確認した後、Stage 2でEveryoneを除去する計画。Stage 1は実施・SVI不変検証まで終了。Stage 2は未実施。
- **Read-only作業と書込み作業は別承認にできる。** 設計READY、Snapshot保存、ACL Stage 1、Stage 2、Evidenceコピーを区別した。
- **復旧可能性は『元の値を覚えた』だけでは成立しない。** Root／SVIのOwner、DACL SDDL、Run ID、SHA-256を新規ファイルへ永続保管し、読み戻し検証を行った。ただしOS領域の完全復旧保証とは別。
- **保存した証拠の独立性が重要。** 原本ログ・実行Workbookと、退避Snapshot、技術レビュー／承認記録は別の役割を持つ。
- **ツール自体の安全性も運用に含まれる。** 未署名PowerShellスクリプトがブロックされた際、ハッシュを確認して`Unblock-File`を実施。全体のExecution Policyは変更しなかった。
- **YAGNIを管理業務にも適用する。** 必要なGateだけ守り、バックアップ自動化／世代管理／新しい管理ツール開発には今は着手しない。
- **派生課題は『危険かどうか』だけでなく『現Gateを止めるか』で分類する。** NOW／DEFER／OUT OF SCOPEを提案。重大な安全リスクや既存承認条件を軽視せず、戻り先を明示する。

## 記事にできそうな切り口

### 開発日記向き

- **「Excel VBAのメールツールを作っていたはずが、USBのACLを調べていた」**：P2完了を目指すうちに発生した脱線と軌道修正。
- **「バックアップを慎重にしすぎて、本体開発が進まない」**：合理的な安全対策の積み重ねと、Done Whenの必要性。
- **「AIに何を任せ、何を自分で承認するか」**：Codexの非昇格Read-only調査、ユーザーの管理者PowerShell、ChatGPTレビューを役割分担した実例。
- **「失敗しないスクリプトではなく、失敗したら止まる手順を作る」**：署名エラー、ACL取得拒否、UNKNOWNの扱い。
- **「個人開発でもGitHub PublicとEvidenceの扱いは別問題」**：リポジトリ外のEvidence保管に切り替えた背景。
- **「“完了”を何度も定義し直したP2」**：Technical PASS／Archive／Closure／Phase Exitを分離してみた記録。
- **「AIの提案にもブレーキが必要だった」**：新しい問題を見つけるたび管理資料を増やさず、開発へ戻る意思決定。

### 技術記事向き

- **「Windows USBのBitLocker状態をPowerShellで検証する」**：`Get-BitLockerVolume`のVolumeStatus、EncryptionPercentage、ProtectionStatus、LockStatus、EncryptionMethod、AutoUnlockEnabledの読み方。ドライブ全体暗号化の選択とOS出力の証明範囲を区別。
- **「NTFS ACLの最小是正：icacls /grant:rと/remove:gを分離する」**：Explicit／Inherited、OI／CI、Everyoneの権限、SIDを用いた主体指定、Owner／DACLの違い。
- **「System Volume Informationを壊さずUSBルートACLを見直す」**：通常権限でAccessDenied、管理者PowerShellで`AreAccessRulesProtected=True`、SVI Owner／DACL SDDLの変更前後照合。
- **「PowerShellによる証拠保全の実装パターン」**：CreateNew、SHA-256、JSON SchemaVersion、Run ID、Root／SVI相互参照、読み戻し照合、上書き禁止。
- **「Read-only Precheck → 個別承認 → 変更 → 事後照合」**：Windows管理スクリプトの安全な段階適用フロー。Stage 2以降の成功実例は未取得。
- **「ユーザー確認・Codex検証・AIレビューを混同しないEvidence分類」**：USER_PROVIDED_OS_OUTPUT／USER_ATTESTED／Codex VERIFIED／UNKNOWN、事実と承認の違い。
- **「Public GitHubとPrivate Evidence Archiveを分離する理由」**：個人パス入りRawのGit履歴をPushしない、公開可能なManifestとPrivate Locatorを区別する。
- **「Regression PASSからCP-P2へ：Quality Gateの追跡性」**：P2-02／03／04のPASS数、正式Closure、BL-MVP-004整合、P2-05 Completion、Phase Exit。
- **「NOW／DEFER／OUT OF SCOPEによる派生IssueのTriage」**：Requirement GapやBlocking Findingを置き換えず、着手優先度と復帰点だけを付加する設計。
- ※DB／Repositoryパターン／DTO／DFDなどは今回の会話で新規設計・実装していないため、この記事の直接の中心題材とはしない。

## 有料note / テンプレート化候補

- **AI協働開発・派生課題Triageテンプレート**：Current Objective、Gate／Done When、NOW／DEFER／OUT OF SCOPE、理由／残留リスク、再評価トリガー、Return Point、Approval。
- **Read-only調査→段階承認プロンプト集**：Scope、禁止操作、Evidence分類、UNKNOWN、STOP条件、次Gate。Windows環境に限定しない汎用化が可能。
- **Evidence Archive最小完了チェックリスト**：媒体独立性、暗号化状態、ACL、原本／コピーのSHA、全件復元、Manifest、Approval。※本会話時点で全項目実施済みではない。
- **Windows ACL変更前後チェックリスト**：媒体再識別、主体SID、DACL／Owner、継承保護、変更前Snapshot、段階実行、事後照合、復旧時の別承認。
- **PowerShell Snapshot取得・照合スクリプトセット**：`Save-SVI-Snapshot.ps1`、`Test-SVI-SnapshotPreStage1.ps1`、`Test-SVI-SnapshotPostStage1.ps1`、`Test-SVI-SnapshotPostStage2.ps1`。※現場固有パス／SID／期待ハッシュをパラメータ化、秘密情報削除、異環境検証してから公開する。
- **Quality GateとEvidenceを切り分けるHandoffテンプレート**：Technical PASS、Evidence Stored、Formal Closure、Baseline、Phase Exit、Unresolved Blocking、Next Approval。
- **AI協働開発 運用ルール改訂提案 v0.1**：現行Approvedルールに対する変更提案の雛形。※正式採用・Baseline反映はまだ未承認。

### 記事化に向けた注意

- **公開前に匿名化**：個人ユーザーパス、SID、DACL SDDL、スクリプトの固定Run ID、証拠の生ログ、機密になり得る業務情報。Git履歴に個人情報が残る問題も未解決。
- **完了の誤表現を避ける**：Stage 1の検証は完了したが、Stage 2、Evidence 5件の二重保管・復元試験、G2、P2 Phase Exitは未完了。
- **再利用の注意**：Windows PowerShellスクリプトは特定の環境／Snapshot形式に依存。汎用パッケージとして配布するには別途レビューと動作検証が必要。

## まとめ / Summary

- **日本語**：USB ACLの段階是正とEvidence保全を通じ、確認・変更・承認を分ける重要性を学んだ。同時に、派生課題を無制限に解決せず、S1完了後は本来のP2開発へ戻るというスコープ制御が必要だと分かった。
- **English**: Separate checks, changes, and approvals. Protect evidence, but avoid endless side tasks. Finish S1 and return to the main development work.
