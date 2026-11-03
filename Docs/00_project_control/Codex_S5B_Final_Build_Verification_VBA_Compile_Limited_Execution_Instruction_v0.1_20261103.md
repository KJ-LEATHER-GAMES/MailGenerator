# S5-B 最終Build確認・VBA Compile 限定実行指示

## 1. 実行承認

ユーザーはS5-Bの開始を承認した。

本作業では、S5-Aで識別済みのWorkbookについて、必要なVBA構成・Manual Sync Entry接続の確認と、最終VBA Compileを実施する。

S5-Bの結果を報告した時点で停止する。

**S5-C Static Review S01～S32、S5-D Production Patch Review／Final Finding Assessment、S5-E Completion Decisionは未承認。**

## 2. 対象Build

S5-Aで検証済みの外部作業Workbookを使用する。

```text
Target:
  E-P204-WBと一致する外部作業Workbook

Expected Size:
  1,003,775 bytes

Expected SHA-256:
  0a4b1392d66fb22630fefd4dbb6d3e78c265b5404a66fb009d934f0866ad2ae9

Repository Workbook:
  1,003,571 bytes
  DIFFERENT BINARY
  NOT SELECTED
```

実行開始時に、対象Workbookの実在・サイズ・SHA-256を再確認する。

不一致の場合はSTOP_REVIEW_REQUIREDとし、別Workbookへの自動切替を禁止する。

## 3. 実行者申告・Evidence前提

次を維持する。

```text
P05 Runtime Source Configuration:
  USER_ATTESTED_SAME_CONFIGURATION

Post-P05 Runtime Production Changes:
  USER_ATTESTED_NO_CHANGE

Historical Runtime Build Hash:
  UNKNOWN

Workbook VBAProject Full Identity:
  UNKNOWN

Existing P05-I01～I17:
  DOCUMENTED_PASS_WITH_LIMITATION

Existing P05-K01～K04:
  DOCUMENTED_PASS_WITH_LIMITATION

Evidence Reuse:
  ACCEPTED_FOR_COMPLETION_ASSESSMENT_WITH_LIMITATIONS
```

実行者申告を独立検証結果へ格上げしない。

既存21ケースのRuntime再実行は行わない。

## 4. 原本保護・実行環境

原本Workbook、保全済みE-P204-WB、Repository側Workbookは変更しない。

安全な検証のため、必要な場合のみ、対象WorkbookとSHA-256が一致する一時作業コピーをRepositoryおよびEvidence保管領域の外に1件作成してよい。

コピーの保存先、作成日時、作成直後のHashを報告する。

Excelを起動する場合は、可能な範囲で次を実施する。

- 独立したExcelセッションを使用する。
- Workbook_Open等の自動イベントを実行させない。
- 外部リンクを自動更新しない。
- 検証用コピーを使用し、原本は開かない。
- 既存のセキュリティ設定を恒久的に変更しない。
- マクロやManual Syncを実行しない。
- Workbookを保存しない。

安全な自動実行抑止を確保できない場合は、Excelを開かず停止する。

一時コピーは検証に必要な範囲だけ使用し、予期しない変更があった場合は破棄・Rollbackを独断で実行せず報告する。

## 5. VBAProjectとSource確認

対象Workbook内で、以下のProduction Sourceとの対応を可能な範囲で確認する。

```text
modTemplateScanner
modSyncEngine
modVariableDefinitionData
modSyncApplication
modUiController
modOutlookAdapter
modSettingsData
COperationResult
CErrorInfo
```

既存Repository Sourceの版付きファイル、およびS5-A確認結果との対応を調べる。

確認項目：

1. 必要なモジュールが存在するか。
2. `modUiController.RunManualSync`が存在するか。
3. `modSyncApplication.ExecuteManualSync`との呼出関係を維持しているか。
4. 既存の2出力APIが維持されているか。
5. `COperationResult.Success`によるSuccess／Failure分岐があるか。
6. Success時に既存4分類を表示する構造か。
7. Failure時にInvalidCandidates、Message／Target、汎用通知へ接続する構造か。
8. Productionコードの想定外差分がないか。

VBAProjectの参照が可能な場合のみ、必要なソース内容を読み取って比較する。Import／Exportは禁止する。

VBAProjectへのプログラムアクセス権限が無い場合は、セキュリティ設定を変更せず、VBE等で安全に確認できる範囲だけ調べる。

確認できない範囲はUNKNOWNとする。

`modVariableDefinitionData`の現行版v0.1.2と、過去Source Reviewが参照した旧v0.1.1 fix1は混同しない。既存Provenanceと現在のSourceの対応を確認し、不一致が判明した場合は停止する。

## 6. Workbook／Worksheetイベント接続

Manual Syncの起動経路について、次を静的に確認する。

- `ThisWorkbook`の関連イベント
- 関連するWorksheetイベント
- 関連するUserFormが存在する場合のイベント
- Manual Syncの明示的User Entry
- `RunManualSync`への接続
- 意図しないAutomatic Sync／Automatic Retry経路の有無

前回のOOXML調査では、確認した部分にButton、ActiveX、マクロ割当が見つかっていない。

この事実だけで不適合と判定しない。

VBAイベントを確認できない場合はUNKNOWNとする。

今回の確認を、正式Static Review S01～S32のPASSとして記録しない。

明確な無断自動実行経路や重大な構造不一致が発見された場合は、Compileへ進む前に停止する。

## 7. 最終VBA Compile

対象Buildの構成に重大な不一致がなく、安全な実行環境を確保できた場合のみ、検証用コピーで次を実施する。

```text
VBE
Debug
→ Compile VBAProject
```

P2-05 Approved Implementation Specification §52に従う。

実際にCompile操作を行い、エラーが発生しなかった場合のみPASSとする。

過去の2026-10-10 Compile申告を今回の結果として転記しない。

エラー発生時は次を記録して停止する。

- 表示されたCompile Error
- 対象Module／Procedure
- 問題箇所
- 実行日時
- 使用Workbookの識別情報

**Compile失敗時のProduction修正、Import、Reference変更、再Compileは未承認。**

VBE操作が不可能、VBAProjectが保護されている、またはCompile実行を確認できない場合は、PASSと推定せずREVIEW_REQUIREDで停止する。

## 8. 保存後の保全確認

検証後に以下を確認する。

- 外部作業Workbook原本のSHA-256が不変。
- Repository側Workbookは未変更。
- Repository Sourceは未変更。
- 既存EvidenceおよびClosure記録は未変更。
- Workbookの保存操作を行っていない。
- 一時コピーの状態と所在を報告する。
- Compileによる未保存のメモリ上の変更をRepositoryへの適用とみなさない。

必要なEvidenceはCodexの実行結果として報告する。

既存の管理文書に新しいPASSを追記することは許可しない。

## 9. 維持する制約

- S1～S4 Closureを維持。
- BL-MVP-004 Repository Acceptance PASSを維持。
- BL-MVP-003の歴史的Execution Baselineを維持。
- I01～I17／K01～K04の限定付きPASSを維持。
- IF-P2-05-001のCLOSEDを維持。
- OBS-P2-05-002のOPEN／NON-BLOCKINGを維持。
- 既存の残留UNKNOWNを維持。

禁止事項：

- Production Source／Workbook原本の変更
- VBA Import／Export
- マクロ・Runtime Test実行
- Regression再実行
- Compile失敗時の無断修正・再試行
- S01～S32正式レビュー
- Production Patch Review
- Final Finding Assessment
- 文書編集
- Git操作
- Baseline変更
- Archive再実行
- P2-05 Completion
- S6着手

## 10. 結果報告

```text
S5BAuthorization: APPROVED_BY_USER

TargetWorkbook:
  SHA256Match: PASS / FAIL
  OriginalPreserved: TRUE / FALSE
  TemporaryCopyUsed: TRUE / FALSE

SourceVerification:
  RequiredModules: PASS / FAIL / UNKNOWN
  SourceCorrespondence: PASS / PARTIAL / UNKNOWN
  WorkbookVBAProjectFullIdentity: VERIFIED / UNKNOWN
  UIEntryConnection: PASS / PARTIAL / UNKNOWN
  EventConnection: PASS / PARTIAL / UNKNOWN

FinalVBACompile:
  Executed: TRUE / FALSE
  Result: PASS / FAIL / NOT_VERIFIED
  Evidence: [execution details]

ExistingP05Evidence:
  I01_I17: DOCUMENTED_PASS_WITH_LIMITATION
  K01_K04: DOCUMENTED_PASS_WITH_LIMITATION
  Reuse: ACCEPTED_WITH_LIMITATIONS

OriginalWorkbookSHA256Unchanged: TRUE / FALSE
RepositoryMutation: NONE / [details]
TemporaryArtifacts: [details]
UnexpectedChanges: NONE / [details]

StaticReview_S01_S32: NOT_STARTED
ProductionPatchReview: NOT_STARTED
FinalFindingAssessment: NOT_STARTED

OBS_P2_05_002: OPEN_NON_BLOCKING

S5BDecision:
  PASS_READY_FOR_S5_C_REVIEW /
  REVIEW_REQUIRED /
  BLOCKED

P2_05CompletionRecorded: FALSE
P2PhaseClosed: FALSE
CP_P2Established: FALSE
S6Started: FALSE
```

SourceおよびCompileの実施根拠、残ったUNKNOWN、次工程への影響を簡潔に記載する。

**S5-B完了結果を報告して停止すること。S5-Cへ自動移行しない。**
