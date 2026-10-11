# 引き継ぎまとめ

## 実施内容

- 対象プロジェクト：
  - 定型メール作成ツール MVP
  - Excel VBA + Classic Outlook
- 対象Phase：
  - `P1 Walking Skeleton`
- この会話の開始時点：
  - `P1-06 Minimal Unresolved Checker 実施仕様 v0.1`
  - Status = `APPROVED`
  - Production実装は未実施
  - P1-05 Minimal Renderまでは `PASS / COMPLETE`

### 1. P1-06 Production実装

Approved済みの `P1-06 Minimal Unresolved Checker 実施仕様 v0.1` を基準としてProduction実装を作成した。

作成したProduction Module：

- `modUnresolvedChecker_P1-06_v0.1_CP932.bas`

Public API：

```vb
Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

Result Carrier：

```text
unresolvedResult
├─ HasUnresolved : Boolean
└─ Variables     : Collection
```

実装した主な挙動：

- Render後のSubject / BodyText String Snapshotだけを入力とする
- Outlook / Word COMへ依存しない
- `{{VariableName}}` 形式の有効Tokenを検出する
- VariableNameはCase Insensitiveで重複統合する
- 同一VariableがSubject / Body双方にあってもVariables上は1件とする
- Unresolved 0件：
  - `Success=True`
  - `HasUnresolved=False`
  - `Variables.Count=0`
- Unresolved 1件以上：
  - `Success=False`
  - `HasUnresolved=True`
  - `Variables`を保持
- Runtime Error：
  - `unresolvedResult = Nothing`
  - `UnexpectedError`
- `RenderError` はP1で必要な暫定ErrorTypeとしてのみ使用
  - 正式なUnresolved Error taxonomyはP6へ残した
- Display / Close / UI / 再帰Renderは実装していない

### 2. P1-06 Test Artifact作成

作成：

- `modP1_06MinimalUnresolvedCheckerCoreTest_v0.1_CP932.bas`
- `modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1_CP932.bas`
- `P1-06 Production 実装手順 v0.1.md`
- `P1-06 Minimal Unresolved Checker Production v0.1.zip`

Core Test：

```text
C1 Unresolved 0
C2 Subject 1件
C3 Body 1件
C4 Subject / Body重複
C5 Case Insensitive
C6 複数Variable
C7 Empty Input
C8 Final Snapshot上Token
```

### 3. 初回Verification

ユーザー実行結果：

```text
C1～C8:
ALL PASS
```

Normal Integration：

```text
ValidVariables.Count=4
InvalidCandidates.Count=0
HasUnresolved=False
Variables.Count=0
CloseWithoutSave=PASS
Normal Integration=PASS
```

Missing Value Integration：

```text
GateDateをFormattedValuesから除外

Subject(post):
【ABC123】ゲート審査 {{GateDate}} / ABC123

HasUnresolved=True
Variables.Count=1
Variable[1]=GateDate
CloseWithoutSave=PASS
Missing Value Integration=PASS
```

Integration全体：

```text
PASS
```

### 4. Compile確認

ユーザー側で、

```text
Debug
→ Compile VBAProject
```

を実施。

結果：

```text
PASS
```

### 5. Body Length 202 / 213差分の検出

P1-06 Initial Integrationでは、

```text
Body Length(post)=213
```

一方、P1-05 Completion時のEvidenceでは、

```text
Body Length(post)=202
```

だったため、再現性確認を実施した。

ユーザーが既存：

```vb
TestP105MinimalRenderIntegration
```

を再実行。

結果：

```text
Body Length(pre)=252
Body Length(post)=202
Known Baseline Tokens Remaining=NONE
PASS
```

よって、

```text
P1-05 = 202
P1-06 = 213
```

の差は過去ログの古さではなく、実際に再現する差としてFinding化した。

### 6. TF-P1-06-001 診断Test作成

一時的に以下のFindingとして扱った。

```text
TF-P1-06-001
Post-Render BodyText Length Inconsistency
```

Productionを変更せずTest Artifactだけで原因を切り分けるため、診断専用Moduleを作成。

作成：

- `modP1_05MinimalRenderIntegrationDiag_v0.1_CP932.bas`
- `modP1_06MinimalUnresolvedCheckerIntegrationDiag_v0.1_CP932.bas`
- `TF-P1-06-001 Post-Render BodyText Diagnostic 実行手順 v0.1.md`
- `TF-P1-06-001 Post-Render BodyText Diagnostic Tests v0.1.zip`

診断項目：

- FormattedValues Key / Value / Len
- Post BodyText全文
- Body Length
- CR / LF / TAB
- Word Table Cell Marker `Chr(7)`
- VT / FF
- 置換後Value出現回数
- Baseline Token残存回数
- 制御文字を可視化したBodyText

### 7. TF-P1-06-001 Root Cause特定

診断結果：

P1-05 Diagnostic：

```text
Body Length(post)=213
```

P1-06 Diagnostic：

```text
Body Length(post)=213
```

両方で以下も一致：

```text
CR=29
CELL=12
VT=1

ABC123=3
2026/09/30=2
Department replacement=2
Comment replacement=1

{{ModelName}}=0
{{GateDate}}=0
{{Department}}=0
{{Comment}}=0
```

Post BodyText全文も一致。

これにより、

```text
P1-05 Production Render
≠
P1-06 Production Render
```

という仮説は棄却した。

診断ログでTest Fixtureを確認すると、日本語値が文字化けしていた。

本来：

```text
Department = 品質部
Len=3

Comment = 確認お願いします
Len=8
```

診断版 / 初期P1-06 Integrationでは：

```text
Department Len=6
Comment Len=13
```

となっていた。

数値上も、

```text
Baseline正常Fixture
252 → 202

Encoding Drift Fixture
252 → 213
```

と完全一致した。

Root Cause：

```text
P1-06 Integration Test Artifact内の
日本語String LiteralのEncoding Drift
```

最終分類：

```text
Test Artifact Defect
/
Test Fixture Encoding Defect
```

Production Defectではないと確定した。

### 8. P1-06 Integration Test Artifact Correction

P1-06 Integration Test Artifactだけを修正。

作成：

- `modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas`
- `TF-P1-06-001 P1-06 Integration Test Artifact Correction v0.1.md`
- `TF-P1-06-001 P1-06 Integration Test Artifact Correction v0.1.zip`

Correction内容：

- `品質部`
- `確認お願いします`

を直接String Literalで記述しない。

代わりにTest Artifact内部で `ChrW()` により生成する。

さらにFixture Guardを追加：

```text
Department Len = 3
Comment Len = 8
```

不一致の場合はTest開始前にFAIL。

Production Module変更：

```text
NONE
```

### 9. Correction後の再Verification

Normal Integration：

```text
Fixture Department Len=3
Fixture Comment Len=8

Subject Length(pre)=49
Body Length(pre)=252

ValidVariables.Count=4
InvalidCandidates.Count=0

Subject(post):
【ABC123】ゲート審査 2026/09/30 / ABC123

Body Length(post)=202

HasUnresolved=False
Variables.Count=0

CloseWithoutSave=PASS

Normal Integration:
PASS
```

Missing Value Integration：

```text
Fixture Department Len=3
Fixture Comment Len=8

Subject(post):
【ABC123】ゲート審査 {{GateDate}} / ABC123

Body Length(post)=206

HasUnresolved=True
Variables.Count=1
Variable[1]=GateDate

CloseWithoutSave=PASS

Missing Value Integration:
PASS
```

`206` はNormal `202` に対し、Body内の `{{GateDate}}` 2箇所が未置換で残ることによる4文字差と整合。

結果：

```text
TF-P1-06-001
RESOLVED / CLOSED
```

### 10. P1-06 Execution Record作成

P1-06の正式Close用として3文書を作成した。

#### Production Patch Review

- `P1-06 Minimal Unresolved Checker Production Patch Review v0.1.md`

最終結果：

```text
Static Review:
PASS

VBA Compile:
PASS

Core Verification:
PASS

Normal Integration:
PASS

Missing Value Integration:
PASS

Scanner / Unresolved Independent Verification:
PASS

P1-05 Major Regression:
PASS

Scope Boundary:
PASS

Production Defect:
NONE

Blocking Finding:
0

RESULT:
PASS
```

#### Finding Assessment

- `P1-06 Minimal Unresolved Checker Finding Assessment v0.1.md`

最終Finding：

```text
Implementation Defect:
NONE

Test Artifact Defect:
RESOLVED

Requirement Gap:
NONE

Design Finding:
NONE

Blocking Technical Finding:
NONE

Regression Finding:
NONE

Lifecycle Finding:
NONE

Blocking Finding:
0

RESULT:
PASS
```

TF-P1-06-001：

```text
Classification:
Test Artifact Defect

Root Cause:
Japanese Fixture String Literal Encoding Drift

Correction:
Integration Test v0.1 → v0.1.1
ChrW() Fixture
Length Guard

Status:
RESOLVED / CLOSED
```

#### Completion Record

- `P1-06 Minimal Unresolved Checker Completion Record v0.1.md`

Completion Criteria：

```text
Approved Unit Specification       PASS
VBA Compile                       PASS
modUnresolvedChecker Production   PASS
Unresolved 0件判定               PASS
Subject残存検出                   PASS
Body残存検出                      PASS
Case Insensitive重複統合          PASS
Variables一覧                     PASS
Unresolved Failure Result         PASS
P1-05 Integration                 PASS
Missing Value Integration         PASS
必要Regression                    PASS
Production Patch Review           PASS
Blocking Finding = 0              PASS
```

最終判定：

```text
P1-06 Minimal Unresolved Checker
PASS / COMPLETE
```

一括ファイル：

- `P1-06 Minimal Unresolved Checker Execution Records v0.1.zip`

---

## 決定事項

- `P1-06 Minimal Unresolved Checker` は正式に：

```text
PASS / COMPLETE
```

とする。

- Production Moduleは：

```text
modUnresolvedChecker
```

を採用する。

- Public APIは：

```vb
CheckUnresolved(subjectText, bodyText, unresolvedResult)
As COperationResult
```

で確定。

- Unresolved Checkerは：

  - Render後Subject / BodyText Snapshotだけを見る
  - Outlook / Word COMを直接扱わない
  - Scanner Resultを入力にしない
  - Rendererと独立した後段Checkerとする

- 残存Token検出は有効な：

```text
{{VariableName}}
```

だけを対象とする。

- VariableはCase Insensitiveで重複統合する。

- 同一VariableがSubject / Bodyの双方に残っていてもVariables上は1件とする。

- Unresolved 1件以上は：

  - Warning継続ではなくFailure
  - `COperationResult.Success=False`
  - `HasUnresolved=True`
  - `Variables`保持

- P1で使用する `RenderError` は：

  - `P1 Interim Mapping`
  - 正式なUnresolved Error taxonomyではない
  - 正式分類はP6で最終化する

- P1-06では以下を実装しない：

  - Display
  - Production CloseWithoutSave orchestration
  - User-facing未置換一覧UI
  - Final User Message
  - 正式Error Code
  - Current Data Guard
  - COM Error / Lifecycle最終化

- `TF-P1-06-001` は：

  - Production Defectではない
  - `Test Artifact Defect / Test Fixture Encoding Defect`
  - `RESOLVED / CLOSED`

- P1-06正式Integration Test Artifactは：

```text
modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas
```

を使用する。

- 旧v0.1 Integration Test ArtifactはEncoding Driftを含むためSuperseded扱いとする。

- Test Artifact内の日本語Fixtureについて：

  - 今回問題になった値は `ChrW()` 生成を採用
  - Length GuardでEncoding Driftを早期検知する

- 診断専用ModuleはProduction / 正式Regression Suiteへ組み込まない。

  - Root Cause確認用Evidenceとして扱う。

- P1-06 Completionだけでは：

```text
CP-P1 ESTABLISHED
```

とはしない。

---

## 未解決事項

### P1-07 Display / E2E Integration

未着手。

P1 Walking Skeletonで残る接続：

```text
Render
↓
Unresolved Check
↓
Display / Fail Closed
```

主な未確定論点：

- `CheckUnresolved.Success=True` かつ `HasUnresolved=False` の場合にDisplayへ進む具体的Orchestration
- Unresolvedありの場合の生成MailItem Cleanup
- P1-07における `DisplayMail()` の責務境界
- P1-07が `ErrorType="RenderError"` に依存しない実装方法
- Normal E2E / Unresolved E2EのTest Boundary
- P1-07でどこまでFail Closedを成立させ、どこからP6へ残すか

### P1 Phase Verification

P1-07完了後に必要。

Implementation Plan上、少なくとも以下をWalking Skeleton全体として確認する必要がある。

```text
Warm Start
Cold Start
Classic Outlook Readiness
OFT
WordEditor
Scanner
Render
Post-Render Snapshot
Unresolved Check
Display
No Auto Send
Error / Scan用途MailItem Cleanup
Explorer / Draft / Inspector Lifecycle
```

### CP-P1

現在：

```text
NOT YET ESTABLISHED
```

P1-07 + P1 Phase Verification後に判定する。

### P5 / P6へ残している事項

今回決めていないもの：

```text
Optional空欄の正式Render保証
Date 6 Format
特殊文字Formal Verification
Body基本書式Formal Guarantee
Range Loop最終Edge Case
Current OFT Guard
Current VariableDefinition Guard
Current OptionMaster Guard
正式Unresolved Error taxonomy
正式Error Code
User-facing Error Message
COM Error / Lifecycle Finalization
Formal MVP Test
```

これらは既存Planどおり後続Phaseで扱う。

---

## 次アクション

### 優先度1：P1-07 Boundary Confirmation

次チャットで最初に実施する。

作成候補：

```text
P1-07 Display / E2E Integration Boundary Confirmation v0.1
```

最初はコードを書かず、責務境界を確認する。

主な確認フロー：

```text
RenderSubject
+
ReplaceBodyVariables
↓
ReadSubject / ReadBodyText
↓
CheckUnresolved
↓
Success=True
AND
HasUnresolved=False
├─ Yes → DisplayMail
└─ No  → Displayしない / Cleanup
```

重点論点：

- Display Gateの正式条件
- `COperationResult.Success` と `HasUnresolved` の扱い
- ErrorType文字列へ依存しないOrchestration
- `DisplayMail()` の責務
- Unresolved時のCloseWithoutSave責務
- Test Harness CleanupとProduction Cleanupの区別
- P1-07とP6のError / Lifecycle Scope境界
- Warm / Cold Start再Verification範囲
- 自動送信が発生しないこと
- P1 Walking Skeleton Exit Criteriaとの整合

### 優先度2：Cross-document確認

P1-07 Boundary確認時に最低限参照する。

```text
MVP Requirements v0.1.9 日本語版.md
MVP Design v0.1.9 日本語版.md
MVP Test Specification v0.1.5 日本語版.md
Implementation Plan v0.3 日本語版(2).md
P1-05 Minimal Render Completion Record v0.1.md
P1-06 Minimal Unresolved Checker 実施仕様 v0.1.md
P1-06 Minimal Unresolved Checker Completion Record v0.1.md
```

特に確認するTest：

```text
MTS-UNR-002
MTS-MAIL-001
MTS-MAIL-002
MTS-MAIL-003
MTS-MAIL-004
```

要確認：P1-07の最小Verificationでどこまで直接扱うか。

### 優先度3：P1-07 実施仕様

Boundary確定後：

```text
P1-07 Display / E2E Integration 実施仕様 v0.1 Draft
```

を作成。

その後：

```text
Cross-document Consistency Review
↓
Correction
↓
Approved
↓
Production実装
```

### 優先度4：P1 Phase Verification

P1-07完了後：

```text
Warm Start E2E
Cold Start E2E
Lifecycle
Display Gate
No Auto Send
Fail Closed
```

をP1 Walking Skeleton全体として確認。

### 優先度5：CP-P1判定

全P1 Exit Criteriaを満たしたら：

```text
CP-P1 ESTABLISHMENT CANDIDATE
```

としてCheckpoint判定へ進む。

---

# 記事用素材

## 気づき

- 「TestがPASSしている」ことと「Fixtureが正しい」ことは別問題だった。
- P1-06初期IntegrationはPASSしていたが、Body LengthがP1-05のEvidenceと一致しなかった。
- Unresolved Checkerは正しく0件を返していても、入力した置換値そのものが文字化けしていればメール内容は正しくない。
- `Unresolved=0` は「Tokenが残っていない」ことしか保証しない。
  - Scanner成立
  - Renderer成立
  - Input Valueの正当性
  - Encodingの正当性\
    を代替しない。
- P1-05とP1-06でScannerとUnresolved Checkerを独立判定した設計が有効だった。
- Body Lengthという一見単純な観測値がRegression Detectionに役立った。
- `202 → 213` の11文字差を文字数計算すると、Fixture異常を定量的に説明できた。
- Productionコードをすぐ疑って変更せず、
  - Test Harness
  - Fixture
  - Encoding
  - Production\
    を分けて調査したことで不要なProduction修正を避けられた。
- Root Cause切り分けでは、
  - Post Body全文
  - 制御文字
  - Token Count
  - Replacement Value Count\
    を比較するとWordEditor経路の問題かFixture問題かをかなり明確に分離できた。
- Word `Document.Content.Text` には、
  - `Chr(7)` のTable Cell Marker
  - `Chr(11)` のManual Line Break\
    など通常テキストでは意識しない制御文字が含まれる。
- 表示上同じメール本文でも、BodyText Lengthを評価するときはWord制御文字を考慮する必要がある。
- CP932でVBE Importするだけでは、日本語Literalの安全性を完全には保証できないケースがある。
- Test Fixtureでは、必要なら `ChrW()` を使ってEncoding非依存化するという選択肢がある。
- Encoding問題はProductionではなくTest Artifact Defectとして分類することで、責務を混同せず対応できた。
- Findingを見つけたとき、
  - Implementation Defect
  - Test Artifact Defect
  - Requirement Gap
  - Design Finding
  - Technical Finding\
    に分類する仕組みが有効だった。
- P1-06 CompletionとCP-P1を分離したことで、「1 Unitの完成」と「Phase全体の完成」を混同せずに済んだ。

---

## 記事にできそうな切り口

### 開発日記向き

- 「全部PASSなのに、なぜかBody Lengthが11文字違う」
  - P1-05は202、P1-06は213
  - そこからEncoding Driftを突き止めるまでの調査記録
- AIと一緒にVBAを作っていたら、ProductionではなくAI生成Test Codeの文字化けが原因だった話
- 「PASSを信用しすぎない」個人開発でのRegression Evidenceの使い方
- Productionコードを直したくなる誘惑を抑えて、まずFixtureを疑った話
- 11文字差を文字数計算してRoot Causeに辿り着いたデバッグ記録
- Excel VBA + Outlook + WordEditorという古典的な技術構成で、現代的なBaseline / Finding / Completion運用を試した話
- 1機能ごとに `Boundary → Spec → Review → Implementation → Verification → Completion Record` を回す個人開発
- AI協働開発で「コードを書かせる」より「勝手にProductionを直させない」ルールの方が重要だった話
- 小さなMVPでもCompletion Recordを残してみたら、次チャットへの引継ぎがかなり楽になった話

### 技術記事向き

- VBAで `{{VariableName}}` の未置換変数を安全に検出するMinimal Unresolved Checker
- `VBScript.RegExp + Scripting.Dictionary(vbTextCompare)` によるCase Insensitive Token Dedup
- ScannerとUnresolved Checkerを分離する理由
  - Pre-render structure check
  - Post-render completeness check
- Unresolved CheckerをOutlook / Word COMから切り離してPure Core Logic化する設計
- `COperationResult + unresolvedResult` によるSemantic FailureとTechnical Failureの分離
- 「Missing ValueをRenderer Errorにしない」設計
  - RendererはTokenを残す
  - 後段CheckerがFail Closed判定する
- Outlook WordEditor `Document.Content.Text` の制御文字
  - `Chr(7)` Table Cell Marker
  - `Chr(11)` Manual Line Break
  - Body Length診断時の注意点
- VBA `.bas` Importと日本語String LiteralのEncoding問題
- Test Fixtureを `ChrW()` 生成してEncoding Driftを防ぐ方法
- Integration TestにFixture Self-Guardを入れる方法
  - `Department Len=3`
  - `Comment Len=8`
- 「Unresolved=0だけではRenderer成功を証明できない」テスト設計
- Production DefectとTest Artifact Defectを切り分ける診断手順
- Regression EvidenceとしてBody Lengthを利用する方法
- Word Range Renderの出力をPost Snapshotで検証する設計
- Unit CompletionとPhase Checkpointを分離する開発運用

---

## 有料note / テンプレート化候補

### 1. Implementation Unit Completionテンプレート

以下を1セットにする。

```text
Boundary Confirmation
Implementation Unit Specification
Cross-document Consistency Review
Production Patch Review
Finding Assessment
Completion Record
```

用途：

- AI協働開発
- 個人開発
- 小規模業務ツール
- VBA / Python / TypeScript等に共通利用可能

### 2. Finding Classificationテンプレート

分類：

```text
Implementation Defect
Test Artifact Defect
Requirement Gap
Design Finding
Technical Finding
Regression Finding
Lifecycle Finding
```

各分類について、

```text
症状
Root Cause
Impact
Correction
Re-verification
Blocking判定
Close条件
```

を記録するテンプレート。

### 3. Productionを触る前のデバッグチェックリスト

例：

```text
1. 再現するか
2. 過去Evidenceとの差か
3. Test Fixtureは同一か
4. Input Valueは同一か
5. Test Harness差はないか
6. Production経路は本当に同じか
7. Raw Outputを比較したか
8. 制御文字を比較したか
9. Production Defectと断定できるか
10. Production変更なしで診断できないか
```

### 4. Integration Evidenceテンプレート

```text
Pre State
Input Fixture
Production API
Post State
Length
Count
Token Remaining
Lifecycle
Cleanup
PASS / FAIL
```

### 5. Encoding Drift対策チェックリスト

VBA / CP932向け：

```text
日本語Literal有無
.bas Encoding
Import後Length
ChrW()利用要否
Fixture Guard
Expected Length
Expected Count
```

### 6. AI協働開発用「勝手に直さない」プロンプト

内容候補：

```text
差分を検出してもProduction Codeを先に修正しない
Findingを分類する
Test Artifact / Fixture / Environmentを先に切り分ける
Requirement GapならImplementationで決めない
Design Findingなら局所Patchしない
Blocking / Non-blockingを明示する
Correction後は必ず同じEvidenceで再Verificationする
```

### 7. Unresolved Checker実装テンプレート

汎用構成：

```text
Input:
Rendered Subject
Rendered Body

Detection:
Valid Token Regex

Identity:
Case Insensitive

Output:
HasUnresolved
Variables[]

Failure:
Semantic Failure

Technical Error:
Separate Error Result
```

VBAだけでなく、Python / TypeScript等にも応用可能。

### 8. Completion Gateチェックリスト

```text
Approved Specification
Compile / Build
Core Verification
Integration
Negative / Missing Value
Regression
Static Review
Finding Assessment
Blocking Finding=0
Completion Record
```

---

# 次チャット開始用短縮版

```text
定型メール作成ツール MVP

Current Phase:
P1 Walking Skeleton

Current Approved Baseline:
BL-MVP-003

Completed:
P0 Foundation PASS / COMPLETE
P1-01 PASS / COMPLETE
P1-02 PASS / COMPLETE
P1-03 PASS / COMPLETE
P1-04 PASS / COMPLETE
P1-05 PASS / COMPLETE
P1-06 Minimal Unresolved Checker PASS / COMPLETE

P1-06 Production:
modUnresolvedChecker

API:
CheckUnresolved(
    subjectText,
    bodyText,
    unresolvedResult
) As COperationResult

Result:
HasUnresolved
Variables

Core C1-C8:
ALL PASS

Normal Integration:
Body pre=252
Body post=202
HasUnresolved=False
Variables=0
PASS

Missing GateDate:
Body post=206
HasUnresolved=True
Variables=GateDate
PASS

Compile:
PASS

TF-P1-06-001:
P1-06 Integration Test Fixture Encoding Drift
→ Test Artifact Defect
→ Japanese Literal文字化け
→ ChrW() Fixture + Length Guard
→ Re-verification PASS
→ RESOLVED / CLOSED

Formal Integration Test:
modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas

Execution Records:
P1-06 Minimal Unresolved Checker Production Patch Review v0.1
P1-06 Minimal Unresolved Checker Finding Assessment v0.1
P1-06 Minimal Unresolved Checker Completion Record v0.1

P1-06:
PASS / COMPLETE

CP-P1:
NOT YET ESTABLISHED

Next:
P1-07 Display / E2E Integration Boundary Confirmation

Start without coding.

Primary flow to confirm:
Render
→ Post Snapshot
→ CheckUnresolved
→ Success + HasUnresolved=False
   → Display
→ Failure / HasUnresolved=True
   → No Display / Cleanup

Important:
P1-07 must not depend on ErrorType="RenderError".
Formal Unresolved Error taxonomy remains P6 scope.
After P1-07:
P1 Phase Verification
→ CP-P1 Establishment Candidate
```
