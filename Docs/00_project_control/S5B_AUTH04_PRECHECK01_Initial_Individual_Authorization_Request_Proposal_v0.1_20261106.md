# S5-B 初回個別承認依頼案

**Request ID:** AUTH-04-PRECHECK-01（提案番号）

**Status:** NOT_GRANTED / USER DECISION REQUIRED

**対象PC:** S5B-TestPC-01

**目的:** A＋C1方式によるE-P204-WBの検証用コピー受渡しとEvidence記録方式が、既存環境で成立するかを判定する。

## 許可を求める操作

ユーザーによる既存資料の参照と、対象PCの通常権限GUIでのRead-only確認のみ。

1. **保全済みBuildの受渡し経路**
   - Private Indexの既存記録から、E-P204-WBのPrimaryが検証PC上でオフライン利用可能かを確認する。
   - 別PCにある場合は、オフライン受渡しか事前搬入が必要かを分類する。
   - Private Locatorの実パスを公開報告へ転記しない。
2. **非同期作業領域の候補**
   - `C:\S5B_Preflight\`の既存状態と、親領域の既知のアクセス・同期条件をGUIで限定確認する。
   - 存在しない場合は`NOT_FOUND`とし、作成しない。
   - ACL変更、既存ファイルのOpen、コピー、ハッシュ測定は行わない。
3. **A方式の通信制限条件**
   - Windowsの通常GUIで、使用中のネットワーク接続方式を必要範囲で確認する。
   - オフライン化の方法と復旧手順の設計に必要な情報のみ記録する。
   - 接続切断、Wi-Fi設定変更、Firewall変更、同期アプリ操作は行わない。

## 禁止事項

- 新規Windowsユーザー作成、権限昇格、ACL・グループ変更
- フォルダー・ファイル作成、移動、コピー、削除
- PowerShell・CMD・スクリプト実行
- Production Workbook、Archive原本、Cloneの内容Open
- Excel／VBE／Outlookの起動、Fixture実行、Compile
- ネットワーク切断・接続設定変更
- Git操作、Approved仕様・Baseline・既存Evidence変更

## STOP条件

管理者認証、権限変更、対象外ファイルへのアクセス、想定外の操作が必要になった場合は即停止する。自動再試行しない。

## 完了報告

- `ArchiveTransferRoute`: OFFLINE_AVAILABLE / PRESTAGING_REQUIRED / UNKNOWN
- `WorkspaceCandidate`: EXISTING_REVIEW_REQUIRED / NOT_FOUND / UNKNOWN
- `NetworkIsolationMethod`: DESIGNABLE / REVIEW_REQUIRED / UNKNOWN
- `RequiredNextAuthorization`: 最小の具体的操作のみ
- `FileMutation`: NONE
- `PCConfigurationMutation`: NONE
- `WorkbookOpened`: FALSE
- `CompileExecuted`: FALSE

**この依頼は承認前であり、作業開始を許可しない。**
