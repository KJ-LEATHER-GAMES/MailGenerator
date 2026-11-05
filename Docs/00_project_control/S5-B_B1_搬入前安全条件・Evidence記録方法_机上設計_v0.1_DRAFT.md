# S5-B B1 搬入前安全条件・Evidence記録方法 机上設計 v0.1 — DRAFT

- 対象：定型メール作成ツール／P2-05／S5-B Current VBA Compile
- 作成日：2026-11-03（JST）
- 文書位置付け：B1の机上設計。新規の実行承認、A＋C1正式選定、現物検証、B1実施完了を意味しない。
- 基準Artifact：`E-P204-WB`／Archive Set `ARC-MG-P2-I12-20261018`
- 設計優先：方式B（管理主体の事前搬入）。搬入経路の条件付き候補：`B-USB-RO`（既存保全USBをコピー元として使用）。
- 保全制約：USB Backupの原本5件、Private Index、既存Primary、Approved/Baseline/Evidenceを変更しない。
- 承認状態：USBの抜き差し、BitLocker解除、媒体接続、ハッシュ測定、コピー、フォルダー作成、ACL／通信変更、Office／VBE起動、Compileはすべて**NOT_GRANTED**。

## 1. 既存Evidenceと今回確定する範囲

| 対象 | 既存の裏付け | B1判定 |
|---|---|---|
| `E-P204-WB` | ユーザーが基準Buildに採用。`MailGeneratorNew.xlsm`、1,003,775 bytes、SHA-256 `0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9` | 論理基準確定。今の現物を再測定したわけではない |
| USB Backup | `Archive_Index_Private.md` §Observed stage results／§Actual SHA-256 matrix：2026-10-24の原本→Primary→USB Backup→USB復元5/5の照合PASS | `HISTORICAL_PASS`。その後の不変性は独立には未検証 |
| USB内XLSMの場所 | ユーザー申告：IndexのUSB Backup `originals`フォルダー内 | `USER_ATTESTED_MATCH`。ファイル内容の現在SHA一致は未知 |
| USB接続先 | ユーザー申告：現在は検証PCと異なるPCに接続 | 物理移送が必要。移動そのものは未承認 |
| BitLocker／USB ACL | 2026-10-24のIndexに保護On・Unlocked、Root ACL等の記録あり | 当時の観測値。今の解除可否・書込防止は未証明 |
| 検証PC | Windows 11 Home、Office 2019（既存報告）、Wi-Fi接続済み | A＋C1実効隔離とOffice可用性は未検証 |
| 作業領域 | `C:\S5B_Preflight\`候補は`NOT_FOUND` | STAGE／WORK／EVIDENCEは未作成 |
| 保全リスク | S1の限定リスク受容は既存保全作業に限定 | 新規移送や検証PC接続に流用不可 |

**扱わないこと**：既存USB保全記録の再監査、Clone調査、PC全体の再調査、追加ネットワーク探索、実パスの公開。

## 2. 項目① 管理側STAGEの場所・非同期・非共有・アクセス境界

### 2.1 論理的な配置提案

| 領域 | 候補配置（論理名） | 使用者／目的 |
|---|---|---|
| `STAGE` | 検証PCの管理側**ローカルユーザープロファイル**下、例：`%LOCALAPPDATA%\S5B\STAGE` | 管理主体だけ。搬入したXLSMを保管。C1から読取不可 |
| `WORK` | 将来のC1ローカル標準ユーザープロファイル下、例：`%LOCALAPPDATA%\S5B\WORK`（C1で解決した別パス） | C1の実行用コピーだけ。STAGEやArchiveへアクセス不可 |
| `EVIDENCE` | 管理側ローカルプロファイル下、例：`%LOCALAPPDATA%\S5B\EVIDENCE` | 搬入・検証記録用Private領域。C1直接書込みは原則不要 |

**重要**：例示の`%LOCALAPPDATA%`が実際にローカル・非同期・非共有・非リパースポイントである保証はない。場所は候補に過ぎない。実ユーザー名、物理パスはPrivate記録のみとし、本案には記載しない。将来の個別承認ではフォルダーごとに対象を確定する。`STAGE`をUSB上、OneDrive/Google Driveの配下、Public Repository、既存Clone配下に作らない。

### 2.2 作成前の必要条件／成立Evidence

- **同一物理PC**：STAGEとWORKの実体は`S5B-TestPC-01`上。バックアップPC側やクラウド上の同名フォルダーを使わない。
- **非同期・非共有**：既知の同期対象・ネットワーク共有ではないこと、親からリダイレクト／リンクしていないことを限定確認。GUIだけで断定できない場合は`UNKNOWN`で停止。同期アプリ設定の無断変更はしない。
- **ACL／実効アクセス**：管理側はSTAGEへ必要な権限を持ち、C1からのアクセス拒否を隔離Gateで実測する。管理者特権によるアクセスは残り得るため、「完全な物理隔離」とは呼ばない。既存Primary／Clone／USBのACLを変更しない。
- **保存前の条件**：Evidenceの初期記録手段と変更対象・復旧方針を先に明示承認する。`NOT_FOUND`だった旧候補を黙って作成しない。
- **実際の完了条件**：作成後の対象一致、親・アクセス境界、同期・共有リスク、Evidence記録を承認範囲で確認。現段階は**すべてNOT_VERIFIED**。

## 3. 項目② 保全用USB・BitLocker・誤書込み防止

### 3.1 2つの経路の設計比較

| 経路 | 概要 | 保全上の評価 | 選定状態 |
|---|---|---|---|
| `B-USB-RO` | 既存の保全用USBを別PCから検証PCへ物理移送し、対象XLSMをSTAGEへ一度だけコピー | 追加媒体不要。ただし、既存の重要Backupを検証PCに直接さらす。**「読み取り目的」と技術的書込み防止は別** | 条件付き優先候補／未承認 |
| `B-TRANSPORT-COPY` | 管理側で別途承認された搬送用コピー／媒体を用意し、保全用USBは元の管理環境に残す | Backupの直接接続リスクを下げられるが、媒体・コピー・照合・保管の追加操作が必要 | 安全条件が満たせない場合の代替候補／未承認 |

**判断原則**：USB Backupの現在の保護と検証PCの安全条件を確認できない場合、`B-USB-RO`を実行しない。代替経路への自動切替えも禁止する。`B-USB-RO`の「RO」は**コピー元を意図的に読み取る運用**を表す仮称であり、ハードウェア書込み禁止の成立を示さない。

### 3.2 将来のUSB接続前に満たす条件

1. 実行主体と対象PC、USB媒体の一致を既存Private Indexの識別情報で確認する。ドライブ文字の一致だけを媒体同一性の証明に使わない。
2. USBを移動・接続する前に、検証PC側のSTAGE、Evidence初期記録、通信・権限の安全条件を個別承認・確認する。可能なら無害Fixture Preflightを先行し、本番XLSMの搬入を不要な段階まで遅らせる。
3. BitLockerについて、既存記録は**2026-10-24時点**の履歴。接続時の認識、ロック／保護状態、解除方法と必要権限は別承認の限定確認が必要。回復キー・パスワード・保護情報をCodexやチャットのEvidenceへ貼らない。認証不明・追加設定要求はSTOP。
4. 書込み防止は未証明。物理的・技術的に強制できる方法があるかとBitLockerで実際に互換するかは**未確認**。強制できなければリスク受容を別途明示するか、`B-TRANSPORT-COPY`を採用する。USBのファイル内容を開く／プレビュー／実行することは禁止。
5. 接続先で予期しない自動起動、修復、フォーマット、スキャン／隔離、同期、再暗号化、アクセス権変更を求められたら、許可せずSTOP。無断で続行、書込み、再接続、解除方法の試行をしない。
6. 搬入は事前固定した`originals`内の**1ファイルだけ**を対象とする。対象サイズ1,003,775 bytes、既存期待SHAを基準とし、コピー元・搬入先それぞれの実測ハッシュ照合を将来の別承認で実施する。**今は計測しない**。USB上のIndexや他4ファイルは無変更。
7. USBの取り外し／返却、残置媒体・一時ファイルの保持／廃棄も後続の承認・記録対象。勝手なクリーンアップやUSBの再利用は禁止。

## 4. 項目③ Evidence保存・STOP・復旧方針

### 4.1 Evidence保管

- **初期記録**：最初のPC変更より前に、ユーザー承認の文面（Authorization ID、対象、範囲、時刻）と、オフライン時にも使える手書き記録を用意する案。手書き記録の媒体・保管方法は次の承認前に固定する。最初のEvidenceフォルダー作成自体の開始／終了も記録する。
- **Private本体**：検証PC上の管理側`EVIDENCE`候補。Private Locator、担当者、正確な時刻、実測値、STOP理由を保管する。既存`Archive_Index_Private.md`は追記・上書きしない。
- **C1実行ログ**：標準ユーザー側で後続の明示承認により生じる記録は、C1から管理側EVIDENCEへ直接書き込ませず、別承認の安全な受渡しで管理主体が保管する。初期は手書きログでもよい。
- **共有用要約**：ChatGPT／Codex／Repositoryに渡す場合は役割名・Artifact ID・時刻・結果・ハッシュのみ。実名、実パス、SID、SSID、鍵や回復キー、媒体固有番号は含めない。生Evidenceの公開・同期は禁止。
- **保持方針**：B1からS5-B最終判定まで無断消去・自動削除なし。判定後の保持期間は**未承認**。旧案「Verification後90日」は参考候補であり、正式期間とはしない。処分・削除は対象を固定して別途承認。

### 4.2 最小Evidenceフィールド（B1～S5-B共通）

```yaml
EvidenceID: PROPOSED
GateOrStep: B1 | B2 | B3 | AUTH-02 | AUTH-03 | AUTH-05 | B-HANDOFF | AUTH-06
AuthorizationID: NOT_GRANTED
OperatorRole: MANAGEMENT | C1 | USER_MANUAL
TargetPC: S5B-TestPC-01
TimestampJST: NOT_RECORDED
SourceArtifact: E-P204-WB
MediaRole: USB_BACKUP | TRANSPORT_COPY | NONE
SourceAndDestination: PRIVATE_RECORD_ONLY
ExpectedSizeBytes: 1003775
ExpectedSHA256: 0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9
ActualSizeBytes: NOT_MEASURED
ActualSourceSHA256: NOT_MEASURED
ActualDestinationSHA256: NOT_MEASURED
AccessBoundaryResult: NOT_VERIFIED
NetworkCondition: WIFI_CONNECTED_PREVIOUSLY_REPORTED
FileMutation: NOT_EXECUTED
PCConfigurationMutation: NOT_EXECUTED
WorkbookOpened: FALSE_AS_PLANNED
CompileExecuted: FALSE_AS_PLANNED
Result: NOT_EXECUTED
StopReason: NONE_REPORTED
ResidualRisks: []
```

`FALSE_AS_PLANNED`は今後の作業で守る禁止条件であり、現時点のPCの独立監査結果ではない。実施結果は実施後に観測区分（USER_ATTESTED、USER_MANUAL_GUI、技術観測等）付きで記録する。

### 4.3 STOPと異常時の扱い

| STOP事象 | 直ちに行うこと | 復旧／再開の扱い |
|---|---|---|
| 対象USB不一致、所在や所有権不明、想定外の認証 | 接続・移送・コピーを開始／継続しない | 原本やBitLockerを操作せず、原因と権限を別承認で判断 |
| コピー元またはSTAGEのサイズ／SHA不一致 | STAGE／WORKへの後続引渡しを停止 | 自動再コピー・上書き・削除なし。相違をPrivate記録へ残して原因評価 |
| 同期／共有／リパースポイント／C1アクセス境界が未確認 | STAGEへの書込みを停止 | 限定Gateで再設計。旧Archive・CloneのACLは変更しない |
| Wi-Fi以外の経路、意図しない接続、Excel追加物などが判明 | USB接続・Workbook起動を行わない | A＋C1の隔離手順を別承認で見直す。勝手にFirewall等を変更しない |
| 自動起動・修復要求・エラー、セキュリティ警告 | 警告に同意せず操作を停止 | 現状態・時刻を記録。取り外し・シャットダウン等も安全に関係するため承認範囲を判断 |
| Evidenceが保存できない／誤った保存先が判明 | 後続操作へ進まない | 初期ログに失敗記録を残し、別承認後に対処 |

**復旧原則**：失敗後の再試行、設定緩和、権限昇格、同名ファイルの再取得、クリーンアップ、媒体返却方法変更を自動で行わない。既存Primary／USB Backupの内容を変更しない。原本保全へ影響する疑いがある場合は当該媒体の利用を停止し、別の既存Primaryへ自動切替えもしない。

## 5. 推奨依存順（従来v0.2のB3早期搬入案との違い）

```text
B1-DESIGN：本書。机上の条件とEvidence様式を決める（実行許可ではない）
  ↓
AUTH-04（限定）：初期Evidence記録手段・対象・保持条件の個別承認／準備
  ↓
独立承認：STAGE／EVIDENCE領域の必要最小限の準備と境界確認
  ↓
必要なAUTH-02／03：C1実行主体・通信・アクセス分離の構築と実測
  ↓
AUTH-05：安全Fixture Preflight（実行前条件が整う場合は先行）
  ↓
個別承認：USBの移動・接続・BitLocker認証／ファイル読取確認
  ↓
B-TRANSFER-01：対象XLSMのハッシュ／サイズ → STAGEへ1件コピー → ハッシュ照合
  ↓
B-HANDOFF-01：別承認でWORKへ引渡しと再照合
  ↓
AUTH-06：対象WORKコピーのCompile（別承認）
```

USBを検証PCへ直接接続する場合、USB保護を優先して、**隔離とFixtureをできる範囲で先行させてから搬入**する方針を推奨する。これは方式B v0.2の「B3をB4より前に行う」という代表順序を局所的に変更する**提案**であり、既存v0.2を正式改訂したものではない。BitLockerのオフライン利用可否などで順序が成立しなければSTOPし、専用搬送コピー方式の採用を別判断する。

## 6. 必要な実機操作の抽出と個別承認境界（すべてNOT_GRANTED）

| 将来の承認単位（仮称） | 許可する最小操作 | 必要な前提 | 明示的除外 |
|---|---|---|---|
| `AUTH-04-B1-LOCATOR-CHECK-01` | 検証PCの通常GUIで管理側ローカルプロファイル内の**候補親領域だけ**をRead-only確認 | 対象PC・管理主体を識別。既存Evidenceで十分なら省略 | ファイル探索、フォルダー作成、ACL変更、USB、Excel |
| `AUTH-04-EVIDENCE-SETUP-01` | 合意した手段で初期記録を開始し、個別指定されたEVIDENCE領域だけ作成・確認 | 正確なPrivate Locatorと保持／アクセス条件を承認で固定 | STAGE・WORK作成、USB操作、他の環境設定 |
| `STAGE-SETUP-01` | 個別指定STAGEの作成と対象範囲限定の権限確認 | Evidence準備済み、親領域の条件確認済み | 原本・Clone ACL変更、コピー、C1作成 |
| `AUTH-02-*`／`AUTH-03-*` | C1／通信制限の構築と実効確認（細分化） | A＋C1の正式選定と安全停止・復旧手順 | 本番Workbook Open、Compile |
| `USB-TRANSFER-PRECHECK-01` | 別PCからの移送・接続、媒体とBitLocker状態の限定確認 | USB保全リスク受容、検証PC安全条件、媒体と作業者を固定 | USB書込み、修復、XLSM Open、コピー |
| `B-TRANSFER-01` | 許可されたXLSMのハッシュ計測とSTAGEへの**1件コピー**、再照合 | 先行Gate PASS、EVIDENCE記録可能 | USB上変更、追加コピー、Excel起動、Work引渡し |
| `B-HANDOFF-01` | 照合済みSTAGE→指定WORKコピーへの移送・再照合 | AUTH-03/05のPASS、C1の実効アクセス | ArchiveやSTAGEへのC1権限付与、Compile |
| `AUTH-06` | 特定したWORKコピーのCompileのみ | 全先行Gate成立、明示個別承認 | 想定外の保存／改変、他Workbook利用 |

上記の仮称は**既存AUTHの付与済み権限ではない**。個々の申請では正確なPC、操作する役割、対象フォルダー、操作方法、期待される変化、STOP、Evidence、戻し方を固定し、承認前に実施しない。

### 最初に提案する個別承認（今回は提出のみ）

**`AUTH-04-B1-LOCATOR-CHECK-01`：通常権限GUIによる管理側候補親領域のRead-only限定確認。** 既存情報が足りない場合のみ実施。確認対象は検証PCの管理主体ローカルプロファイル（例：`%LOCALAPPDATA%`が指す候補親）とその直接の親プロパティに限る。見る内容は候補が当該PCのローカル領域か、明示された同期・共有の兆候があるか、既存フォルダーやリンクでないか。`UNKNOWN`は許容し、その場合は作成しない。環境変数の展開を実機コマンド等で求めず、予期しないプロンプトならSTOP。**新規ファイル・フォルダー・設定変更、管理者昇格、USB抜き差し、BitLocker解除、ハッシュ、Office起動は許可対象外。**

承認状態：`NOT_GRANTED`。ユーザーが明示承認するまで、Codexによる実機確認を含め実行しない。

## 7. B1判定

```yaml
B1_DESK_DESIGN: COMPLETE_WITH_OPEN_CONDITIONS
B1_OPERATIONAL_READY: FALSE
ReferenceBuild: E-P204-WB
PreferredTransfer: B_USB_RO_CONDITIONAL
BackupMediaCurrentIdentity: NOT_VERIFIED
BackupMediaTechnicalWriteProtection: NOT_VERIFIED
BitLockerOnTestPC: UNKNOWN
STAGE: NOT_CREATED
EVIDENCE: NOT_CREATED
WORK: NOT_CREATED
A_PLUS_C1_SELECTED: FALSE
A_PLUS_C1_ISOLATION: NOT_VERIFIED
AUTH_04_B1_LOCATOR_CHECK_01: NOT_GRANTED
AUTH_04_EVIDENCE_SETUP_01: NOT_GRANTED
STAGE_SETUP_01: NOT_GRANTED
USB_TRANSFER_PRECHECK_01: NOT_GRANTED
B_TRANSFER_01: NOT_GRANTED
B_HANDOFF_01: NOT_GRANTED
AUTH_02_03_05_06: NOT_GRANTED
S5_B_COMPILE: NOT_VERIFIED
FileMutationOnUserPC: NONE_PERFORMED_BY_THIS_DESIGN
```

## まとめ / Summary

**日本語：** B1の机上設計は条件付きで整理できた。STAGEとEvidenceの候補、USB／BitLocker保全条件、記録様式、停止・復旧条件を定義した。保全用USBの直接接続は技術的書込み保護が未証明のため条件付き。次の候補は管理側親領域の限定Read-only確認であり、個別承認が必要。コピー、USB移送、環境変更、Compileは未承認。

**English:** The B1 desk design is ready with open conditions. It covers the staging area, USB safety, evidence records, and stop rules. The USB backup is not proven write-protected. The next proposed action is a limited read-only folder check. No transfer, PC change, or Compile is approved.
