# 記事用素材

- **対象**：個人開発「定型メール作成ツール」のP2 Regression Evidence保全／GitHub公開リスク／AI（ChatGPT・Codex）との協働運用。
- **注意**：以下の「気づき」は会話から得た学び・評価。「記事にできそうな切り口」「テンプレート化候補」は今後の企画案であって、公開済み記事や完成製品ではない。
- **公開時の注意**：Windowsの実ユーザー名、ローカル絶対パス、コミットの著者メール、Rawログ中の個人パス、GitHub公開先など、特定につながる情報は適切に匿名化する。機密情報・企業由来データの有無も公開前に確認する。

## 気づき

### Evidenceは「PASSの数字」だけでは品質保証にならない

- Codexは生ログからP2-02 **111/111**、P2-03 **46/46**、P2-04 **182/182**のPASSを再確認した。
- それでも正式なRegression ClosureやI12のDocumentary Closureは未完了。**技術結果、Evidence保管、レビュー、承認、Baseline／Phase Exitは別のGate**である。
- P2-04のI10初回ABORTをPASS数に含めないなど、集計に含む／含まない根拠を明示する必要があった。
- Source ZIPの正規化文字列が9/9一致しても、**元のバイト列一致や実行Workbook内部のVBAProject一致まで証明したわけではない**。証拠から言えることの範囲を明示するのが重要。

### 「保管先がある」と「正式Archiveが成立した」は異なる

- 生ログ、Source ZIP、実行Workbook候補はOneDriveの開発フォルダ等に存在していたが、アクセス範囲・同期・独立Backup・復元可能性までは確認できなかった。
- S1では、保管対象の特定→原本Hash確認→専用Archive方針→ACL確認→独立Backup→復元試験という条件を切り分けた。
- USBメモリ自体は約1MBのEvidenceを格納するには十分でも、問題になるのは容量ではなく**秘匿性、物理的独立性、後日取り出せること**だった。

### Public Gitとローカル履歴の組合せに注意

- GitHub RepositoryがPublicであることがS1-Aで判明。
- 個人パス入りP2-04 Rawは**ローカルGit履歴には存在**したが、調査時点の公開`main`には未掲載だった。
- 作業ツリーからファイルを削除しても、過去のGit Commitから消えるとは限らない。**公開前の履歴と差分の扱いが運用設計の一部**になる。
- Gitの通常Pushを停止し、Archive保全と履歴対応を別問題として扱った。

### AIに「ここで停止」を明示すると作業の境界が守りやすい

- CodexにはS0→S1-AをRead-onlyで実施させ、S1-Bでも**空フォルダ作成だけを個別承認**した。
- 未確認があるときCodexは`PRECHECK_BLOCKED`や`PRIMARY_DIRECTORY_REVIEW_REQUIRED`を返し、RawコピーやACL改変へ進まなかった。
- ユーザーの承認を、文書追加／空フォルダ作成／原本コピー／暗号化設定／Git操作といった**変更単位で分離**すると、過剰な自動実行を防ぎやすい。
- 「まだ存在しないフォルダのACLを事前検証せよ」は成立しない。**作成前の親ACL検査→空フォルダ作成→作成後ACL検査→コピー承認**へ順序を調整した。

### 個人開発での合理的な運用は、技術だけでなく役割分担で決まる

- Grill Meで、暗号化・秘密情報はユーザー、Read-only調査と承認後のコピー／Hash照合はCodex、最終承認はユーザーと分けた。
- BitLockerの回復キーは紙とパスワードマネージャーで管理し、AIには秘密値を渡さない。
- USBメモリはバックアップ時のみ接続し、自宅の別室に保管する方針。自宅全体に及ぶ災害による同時損失は残留リスクとして認識。
- 更新頻度は毎週・毎月ではなく**重要Evidenceが追加・確定したとき**。初回だけ全件復元試験を行い、後続はSHA照合中心にする方針を選択した。

### 文書管理は「増やす」より「正本の役割を分ける」

- S0調査報告、S1実施計画、Codex実行指示書、Review Record、Archive Manifestは目的が異なる。
- 計画書に含まれる参考指示とチャットの実行指示に差があり、**1作業＝1つの正本指示書**が望ましいと整理した。
- 既存`P2-04_I12_Evidence_Archive_Manifest_v0.1_Draft.md`の最小改訂を優先し、同じ役割の新しい台帳を乱立させない方針。

## 記事にできそうな切り口

### 開発日記向き

- **「テストは全部PASS。でも、なぜ開発が次に進まないのか？」**：111＋46＋182件のPASS後にも文書Closure／Archive／Baselineが残る実体験。
- **「Codexに“コピー禁止”を何度も伝えた理由」**：AIへの限定承認、失敗ではなく停止する設計、`PRECHECK_BLOCKED`を歓迎する判断。
- **「たった約1MBの証拠のためにUSBメモリを暗号化した話」**：容量よりも復元性・公開リスクが重要だったという発見。
- **「GitHubがPublicだった。ローカル履歴のRawログをどう扱う？」**：公開事故の可能性に気づいてPushを止めた過程。※実際にRawが公開されたとは書かない。
- **「Grill Me 23問でバックアップ運用を決めた」**：USB、BitLocker、回復キー、更新タイミング、オフライン保管、AIとの役割分担を順に選んだ過程。
- **「厳密さと運用負荷のバランス」**：Primary ACLから管理共有の実効アクセスまで考えた結果、何を残留リスクとして受容するか悩んだ話。

### 技術記事向き

- **「Raw EvidenceのProvenance Matrixを作る」**：Logical ID、原本名、Size、SHA-256、SOURCE／Workbookの照合、確認日時、証拠確度、Historical Limitation。
- **「正規化一致とバイナリ一致は何が違う？」**：VBA `.bas`／`.cls`とProduction Source ZIPの9/9照合、CP932、改行・大文字小文字正規化と、Workbook内部未検証の境界。
- **「Read-only → Decision Gate → WriteのCodex運用パターン」**：作業許可、停止条件、実施後の証拠、結果に応じた承認プロトコル。
- **「Windows Private ArchiveのACL確認手順」**：親ACL、継承、Owner、Explicit／Inherited ACE、共有権限とNTFS実効アクセスの違い。`UNKNOWN`を無理にPASSへ変えない。
- **「BitLocker To Goを使ったEvidenceオフラインBackup」**：専用USB、全体暗号化、回復キー別保管、保全コピーと復元後のHash一致。※設定作業はユーザー実施、BitLocker状態のCodex独立検証は今後。
- **「Git履歴の機密情報とPublic Repoの境界」**：作業ツリー非掲載と履歴包含の違い、Push保留、RawをGit外Archiveに分離する運用。
- **「Regression PASSとFormal Closureの状態遷移」**：Unit Completion、Regression Cycle、I12 Technical Review、Archive、Documentary Closure、Baseline／P2 Exitの対応図。MermaidのGate図素材として利用可能。
- **「原本→Primary→Backup→Restoreのハッシュ照合」**：検証フロー、衝突時停止、上書き禁止、復元先分離、監査記録。実コピー／復元の実施結果は**未取得**と明記。
- **「Evidenceを使用できる範囲だけで再利用する」**：旧I01/I02を補助証拠とする際のRevision差、I07／I08からRollback保証を推定しない方法。

## 有料note / テンプレート化候補

- **Evidence Inventory Template**：Artifact／Logical ID／元ファイル／所在／Size／SHA／確度／過去実行の限界／保管状態／次のGate。
- **Archive Manifest Template**：Original SHAとArchive Copy SHA、Private Locator、アクセス範囲、取得日時、Related Copies、復元試験結果を分ける。
- **Codex Read-only調査プロンプト集**：S0棚卸し、S1-A公開リスク確認、Primary ACL Precheck、USB BitLocker Backup Precheck。
- **段階承認チェックリスト**：Read-only、空フォルダ作成、ACL修正、原本コピー、Backupコピー、復元試験、Git Commit／Pushを独立許可。
- **Backup媒体Grill Me質問票**：媒体有無・種類・空き・初期化可否・OS・管理権限・回復キー・オフライン保管・更新頻度・復元試験・Codex分担・媒体識別。
- **Evidence復元性テスト手順**：Primary／Backup／Restore各段のHash照合、結果欄、失敗時の停止条件。
- **GitHub Public Repository公開前監査チェックリスト**：対象ツリーだけでなく履歴、個人パス／シークレット、保管ポリシー、Push可否を確認する。
- **Quality Gate／Closure判断表**：Technical PASS、Evidence Verified、Archive Complete、Review Closed、Approved、Baseline Accepted、Phase Exitを区別する。
- **文書役割マトリクス**：Plan（将来の作業）、Instruction（今回許可する作業）、Evidence（実測事実）、Review（評価）、Decision（承認）、Manifest（保管参照）。

### 素材化に際して守るべき線引き

- **実施済み**：S0/S1-A Read-only調査、Primaryの空3階層作成・ACL検査、USB BitLockerセットアップ（ユーザー申告）、Grill Meの運用方針決定。
- **未実施**：Codex Backup Precheck、5原本のPrimary／Backupコピー、復元試験、S1-C正式Manifest登録、S1-B/G2正式完了、P2-02／03／04正式Closure、P2-05 Completion。
- **未確認**：BitLockerのCodexによる独立検証、管理共有の実効アクセス、将来のGit履歴公開の安全性、完全なWorkbook VBAProject同一性。
- 記事では「自動化できた／全Gateを通過した／公開漏洩が起きた」などの未確認の断定を避ける。
