# S5-B Target Workbook特定の既存資料Read-only照合結果

**TARGET_BUILD_IDENTIFICATION: INCOMPLETE**です。

保全済みBuildの識別情報は特定できますが、現行S5-BでCompile元とする物理ファイル、特にローカルCloneとの対応が、指定資料だけでは一意になりません。
これは、過去のS5-Aで行ったSHA-256一致確認を取り消す判断ではありません。

## 1. 資料上で識別できるWorkbook

| 対象 | 識別・所在 | 記録上の状態 |
| --- | --- | --- |
| 保全済みWorkbook | E-P204-WB／Archive Set ARC-MG-P2-I12-20261018 | 1,003,775 bytes。Primary・Backup・復元のSHA照合PASS |
| 2026-10-21の外部開発Workbook | OneDrive配下として記録された外部開発フォルダーのMailGeneratorNew.xlsm | 申告SHAと一致する現物を当時確認 |
| Repositoryルートの同名Workbook | Repository側MailGeneratorNew.xlsm | 外部開発Workbookとは別バイナリ |
| ローカルClone内のWorkbook | RESOURCE-CLONE-Aとの対応対象 | Workbookの物理同一性・SHA対応は未確認 |

E-P204-WBと外部開発Workbookに記録されたSHA-256：

```text
0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9
```

Repository側に記録されたSHA-256：

```text
07336d8779f27039822539895c38fc8570c82fefc206ed83fb04672cb091a22e
```

根拠は、S0結果まとめ §5.2・§6と、Manifest本文v0.3 §2です。実Archive Locatorは非公開Private Index参照のままとし、転載していません。

## 2. 10月21日の外部Workbookとの対応

S0結果まとめは、2026-10-21の調査で外部開発WorkbookのSHA一致を確認したと記録しています。そのSHAと、後のManifestのE-P204-WBは一致します。

したがって、両記録は同じバイナリ指紋を指しています。ただし、その外部ファイルが現在も不変であることや、Clone内Workbookと同一であることまでは示しません。

また、OneDrive配下という所在記録と、同期登録・稼働状態の検証は別です。既存のOneDriveRegistration: UNKNOWNを維持します。

## 3. S4完了はWorkbook採用・同期完了ではない

Project Overview v1.67のS4最新節とCurrent Handoff v1.40は、S4を文書統合・Repository文書受入とし、Workbook一致・Source Import・Compileの証明ではないと明記しています。

OverviewのRepository Workbookへのリンクだけを、現行Compile対象の指定とは扱えません。

P2-05 Production Implementation Recordも、Production候補Moduleの作成・Import予定を扱う履歴であり、対象WorkbookのArtifact ID・所在・SHAを固定する記録ではありません。

## 4. S4後の変更記録

今回読んだ資料では、S4完了後のVBAProject／Workbook変更を確定する記録は確認できませんでした。これは「変更がなかった」という証明ではありません。

Build Provenance v0.4の変更なし申告は、過去Compile・Regressionへの適用範囲を持つ記録です。S4後から現在までの全Workbook変更履歴へ拡張できません。

9 Sourceの構成・正規化一致も、Workbook内VBAProject全体の同一性とは区別します。

## 5. 不足する最小Evidence

追加探索ではなく、次の対応記録が必要です。

1. **現行Compile元の役割・所在対応**

   対象PC、Workbookの安全なLocator識別子、E-P204-WBとの対応。Cloneを使うのか、既存の外部開発原本等から後続承認の検証コピーを作るのかを区別する。

2. **その指定ファイルの既存Hash Evidenceと取得時点**

   Cloneを採用するならClone側の対応記録が必要です。採用しないCloneのHash確認は不要です。既存記録がなければ、今回はUNKNOWNのままとし、新規計測は行いません。

3. **指定ファイルについてのS4後の変更履歴・実行者申告**

   Workbook保存、VBA編集・Import等の有無と対象時点。Source変更なしとWorkbook全体不変は区別します。

```yaml
TARGET_BUILD_IDENTIFICATION: INCOMPLETE
ReferenceArtifact: E-P204-WB
ReferenceBinaryFingerprint: IDENTIFIED_FROM_EXISTING_RECORDS
ExternalWorkbook_20261021_Correspondence: SUPPORTED_BY_RECORDED_SHA256
CurrentCompileFileBinding: UNKNOWN
LocalCloneWorkbookIdentity: UNKNOWN
PostS4WorkbookChangeStatus: UNKNOWN

WorkbookOpened: FALSE
ExcelVBEStarted: FALSE
CompileExecuted: FALSE
FileMutation: NONE
GitOperation: NONE
BaselineMutation: NONE
```

既存資料の読取りAPIだけを使用し、OSコマンド・スクリプトファイルの実行、Workbook実体へのアクセス、再Hash取得は行っていません。既存のClosure・限定付きEvidence・残留UNKNOWNを維持して停止します。
