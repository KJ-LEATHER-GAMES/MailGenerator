# P1-07 Display / E2E Integration Boundary Confirmation v0.1

## 1. 文書情報

| 項目                         | 内容                                                          |
| -------------------------- | ----------------------------------------------------------- |
| 文書名                        | P1-07 Display / E2E Integration Boundary Confirmation       |
| バージョン                      | v0.1                                                        |
| 対象プロジェクト                   | 定型メール作成ツール MVP                                              |
| 文書種別                       | Implementation Boundary Confirmation                        |
| Status                     | Draft                                                       |
| Current Execution Baseline | BL-MVP-003                                                  |
| 対象Phase                    | P1 Walking Skeleton                                         |
| 対象Implementation Unit      | P1-07 Display / E2E Integration                             |
| 前提Implementation Unit      | P1-06 Minimal Unresolved Checker = PASS / COMPLETE          |
| Primary Responsibility     | E2E Orchestration / Display Gate / Unresolved Fail Closed接続 |
| Formal Test Result         | 本文書およびP1-07 Verificationでは作成しない                             |

### Related Documents

- `DOC-MVP-REQ` — MVP Requirements
- `DOC-MVP-DES` — MVP Design
- `DOC-MVP-TESTSPEC` — MVP Test Specification
- `DOC-MVP-IMPL` — Implementation Plan
- `DOC-TS-A` — Technical Spike A
- `P1-06 Minimal Unresolved Checker 実施仕様 v0.1`
- `P1-06 Minimal Unresolved Checker Completion Record v0.1`

---

# 2. 目的

P1-07の目的は、P1-06までに成立したProduction経路を最終Display Gateへ接続し、P1 Walking Skeletonとして以下のE2E Boundaryを成立させることである。

```text
Render
↓
Render後 Subject / BodyText Snapshot
↓
CheckUnresolved
↓
Display Gate
├─ Success / Unresolvedなし
│   ↓
│  DisplayMail
│
└─ Failure / Unresolvedあり
    ↓
   Displayしない
    ↓
   Variables保持
    ↓
   CloseWithoutSave
```

本Boundary Confirmationでは、コード実装前に、

- どの状態でDisplayを許可するか
- どの状態でFail Closedするか
- `modUnresolvedChecker`、Application Orchestration、`modOutlookAdapter`の責務境界
- P1とP6の責務境界
- P1-07 VerificationとFormal MVP Testの境界

を確定する。

Requirement / Design / Test Definitionそのものを再定義しない。

---

# 3. Baselineから確定済みの原則

## 3.1 Display成功条件

生成MailItemをDisplayできるのは、メール生成に必要な前段Checkが成功した場合のみとする。

P1-07で直接扱う最終Gateは、

```text
CheckUnresolved
↓
Success
+
HasUnresolved = False
```

である。

未置換Variableが存在する状態からDisplayへ進んではならない。

---

## 3.2 Unresolved Failure

Render後のSubject / BodyTextに有効なVariable Tokenが1件以上残存した場合、

```text
CheckUnresolved:
Success = False

unresolvedResult:
HasUnresolved = True
Variables.Count >= 1
```

となる。

この状態はWarning継続ではなくFailureとする。

P1-07は以下を保証する。

```text
Unresolvedあり
↓
MailItemをDisplayしない
↓
Variablesを保持
↓
CloseWithoutSave
```

---

## 3.3 自動送信禁止

P1-07はMailItemをDisplayするまでを対象とする。

```text
Display
≠
Send
```

Production Codeから自動送信を行わない。

Display成功後の内容確認、編集、宛先確認、送信はユーザー側操作とする。

---

# 4. P1-06から受け取るContract

P1-06で以下のProduction APIが成立済みである。

```vb
CheckUnresolved( _
    subjectText, _
    bodyText, _
    unresolvedResult _
) As COperationResult
```

Result Carrier：

```text
unresolvedResult
├─ HasUnresolved : Boolean
└─ Variables     : Collection
```

P1-07ではこのContractを変更しない。

またP1-07は、

```text
ErrorType = "RenderError"
```

をUnresolved Failure判定条件として使用しない。

Unresolved Failureは少なくとも、

```text
COperationResult.Success = False
+
unresolvedResult Is Not Nothing
+
unresolvedResult("HasUnresolved") = True
```

によって識別可能とする。

`RenderError` はP1 Interim Mappingであり、正式なUnresolved Error taxonomyではない。

正式Error分類、Error Code、User-facing Error Messageの最終化はP6責務として維持する。

---

# 5. Responsibility Boundary

## 5.1 modUnresolvedChecker

責務：

```text
Render後Snapshot
↓
未置換Token検出
↓
HasUnresolved
+
Variables
+
COperationResult
```

行わないこと：

```text
DisplayMail
CloseWithoutSave
MailItem操作
Word / Outlook COM操作
UI表示
再Render
Error taxonomy最終決定
```

P1-07のために`modUnresolvedChecker`へLifecycle責務を追加しない。

---

## 5.2 Application Orchestration

P1-07のDisplay / Fail Closed分岐を制御する責務はApplication側に置く。

Primary Moduleは既存Architectureに従い、

```text
modMailApplication
```

を基本とする。

責務：

```text
Render後Snapshot取得
↓
CheckUnresolved呼出
↓
Result評価
↓
Display / No Display分岐
↓
必要時Cleanup
```

具体的なPublic Procedure名、引数、戻り値はP1-07 Implementation Unit Specificationで決定する。

Boundary Confirmation段階では不要なPublic APIを追加しない。

---

## 5.3 modOutlookAdapter

Outlook / Word COM操作は既存責務どおり`modOutlookAdapter`へ集約する。

P1-07で使用する既存Conceptual APIは、

```text
DisplayMail()
CloseWithoutSave()
```

とする。

Application側がDisplay可否を判断し、Adapterへ実際のMailItem操作を依頼する。

`modUnresolvedChecker`からAdapterを直接呼ばない。

---

# 6. Success Path

正常系Boundaryは以下とする。

```text
Render完了
↓
ReadSubject
+
ReadBodyText
↓
CheckUnresolved
↓
OperationResult.Success = True
↓
unresolvedResult.HasUnresolved = False
↓
DisplayMail
↓
MailItem Display
↓
P1-07 Success
```

成功時は、Display後に`CloseWithoutSave`を実行しない。

DisplayされたMailItemはユーザー確認対象となり、ツール側で自動的にCloseしない。

自動Sendしない。

---

# 7. Unresolved Fail Closed Path

未置換Variableありの場合：

```text
Render完了
↓
ReadSubject
+
ReadBodyText
↓
CheckUnresolved
↓
OperationResult.Success = False
+
HasUnresolved = True
+
Variables.Count >= 1
↓
DisplayMailを呼ばない
↓
Variablesを保持
↓
CloseWithoutSave
↓
Failure Result
```

最低限以下を保証する。

```text
MailItem Display:
NONE

MailItem Save:
NONE

Variables:
保持

Cleanup:
CloseWithoutSave
```

`Variables`は後続のUser Notificationへ接続できる状態を維持する。

P1-07では最終User-facing Message文言を固定しない。

---

# 8. Technical Failure Boundary

`CheckUnresolved`がUnresolved検出ではなくTechnical Failureとなった場合も、成功扱いしてDisplayしてはならない。

例：

```text
OperationResult.Success = False
unresolvedResult = Nothing
```

この場合：

```text
Displayしない
↓
生成途中MailItemを成功扱いしない
```

ことをP1-07 Boundaryとする。

ただし、

- 全COM Error Path
- Error Code体系
- User Message変換
- Error時Lifecycleの全面完成
- Outlook / Word技術例外の網羅処理

はP6 `Error / Safety / Integration` の責務として維持する。

P1-07だけでP6を先回り実装しない。

---

# 9. Display Gate

P1-07ではDisplay条件をPositive Allow方式とする。

```text
Display Allowed
=
CheckUnresolved.Success = True
AND
unresolvedResult exists
AND
HasUnresolved = False
```

上記条件を満たさない状態を暗黙的にDisplay許可しない。

概念：

```text
CanDisplay?
├─ Yes
│   ↓
│ DisplayMail
│
└─ No
    ↓
   No Display
```

これにより、不明状態・不完全状態を成功側へ倒さない。

---

# 10. P1-07 Production Flow

P1-07完了時のP1 Walking Skeleton Production Flowを以下とする。

```text
Settings.TemplatePath
↓
ResolveWorkbookRelativePath
↓
Classic Outlook Readiness
↓
CreateMailFromTemplate
↓
ReadSubject / ReadBodyText
↓
ScanTemplate
↓
P1 FormattedValues
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
ReadSubject / ReadBodyText
↓
CheckUnresolved
↓
Display Gate
├─ Unresolvedなし
│   ↓
│ DisplayMail
│   ↓
│ UserへMailItem表示
│
└─ Unresolvedあり
    ↓
   No Display
    ↓
   Variables保持
    ↓
   CloseWithoutSave
```

P1-07はP1-06までのProduction Data Flowを置き換えず、最終区間を接続する。

---

# 11. Warm Start / Cold Start Boundary

P1-07ではWalking Skeleton全体を接続するため、

```text
Warm Start
Cold Start
```

双方でE2E経路が成立可能であることをImplementation Verification対象とする。

Warm Start：

```text
Existing Explorer reuse
↓
E2E
↓
Display
```

Cold Start：

```text
Explorer Count = 0
↓
Visible Explorer Initialization
↓
Classic Outlook Readiness
↓
E2E
↓
Display
```

Cold Startで表示されるOutlook Explorerと、最終生成MailItemのDisplayは別Lifecycleとして扱う。

Cold Start時に起動したExplorerをP1-07 Cleanup対象としない。

---

# 12. Verification Boundary

P1-07では以下をImplementation Verificationとして確認する。

### V1 — Normal E2E / Warm Start

```text
Unresolved = 0
↓
DisplayMail
↓
MailItem Display
↓
自動Sendなし
```

### V2 — Normal E2E / Cold Start

```text
Classic Outlook未起動
↓
Readiness成立
↓
Unresolved = 0
↓
DisplayMail
```

### V3 — Unresolved Fail Closed

1つ以上のFormatted Valueを意図的に欠落させる。

例：

```text
GateDate:
NOT INCLUDED
```

Expected：

```text
HasUnresolved = True
Variables = GateDate

Display:
NONE

CloseWithoutSave:
PASS
```

### V4 — Lifecycle / Regression

最低限：

```text
VBA Compile
P1-01～P1-06主要Production経路
Draft増加有無
Inspector残存有無
自動Sendなし
```

を確認する。

---

# 13. MVP Test Specificationとの関係

P1-07 Verificationでは以下のTest Scenarioを参照する。

```text
MTS-UNR-002
未置換1件以上でDisplay停止

MTS-MAIL-001
成功時Classic Outlook Display

MTS-MAIL-002
自動送信されない

MTS-MAIL-003
MailItem Lifecycle

MTS-MAIL-004
Error時生成MailItem非表示 / 保存なしClose
```

ただしP1-07で得られた結果は、

```text
Implementation Verification Evidence
```

として扱う。

以下とは扱わない。

```text
Formal MVP Test Result
MTS-UNR-002 = Formal PASS
MTS-MAIL-004 = Formal PASS
```

Formal MVP Testは、Implementation Planに従い後続のTest Candidate Buildに対して別途実施する。

---

# 14. Out of Scope

P1-07では以下を完成させない。

```text
Configuration Validator完成
Dynamic UserForm
Input Validation完成
Value Formatter完成
Current OFT Guard完成
Current VariableDefinition Guard
Current OptionMaster Guard
正式Error Code体系
正式Unresolved Error taxonomy
Error UI最終形
User-facing Message最終文言
全COM Error Path
全Lifecycle Error Path
Formal MVP Test
```

またP1-07のためだけに、

```text
新しいAdapter
新しいDomain Class
Display専用Interface
Unresolved専用Application Class
Test専用Production API
```

を追加しない。

YAGNIを維持する。

---

# 15. P1 / P6責務境界

P1-07で確認するFail Closedは、

```text
Unresolvedを検出した生成途中MailItemを
DisplayせずCleanupできる
```

というWalking Skeleton上の接続成立性である。

一方P6では、

```text
全既知異常経路
COM Error
Unexpected Error
正式Error分類
User Notification
Lifecycle Completion
Fail Closed全面保証
```

を完成させる。

したがって、

```text
P1-07 Unresolved Fail Closed PASS
≠
P6 Fail Closed Completion
```

とする。

---

# 16. Requirement Gap Assessment

P1-07 Boundary検討時点で、新しい利用者向け振る舞いを決定する必要はない。

既存Requirementsにより、

```text
未置換あり
→ 生成停止

全Check成功
→ Display

自動Send
→ しない
```

が既に確定している。

判定：

```text
Requirement Gap:
NONE
```

---

# 17. Design Gap Assessment

以下の責務は既存Designで定義済みである。

```text
Unresolved Checker
→ Render後の独立Check

Application
→ 処理Sequence / Orchestration

Outlook Adapter
→ DisplayMail / CloseWithoutSave

Unresolvedあり
→ No Display / Close

Unresolvedなし
→ Display
```

P1-07では既存DesignをImplementationへ接続するだけで、新しいArchitecture / Component Responsibility / Technical Decisionを決める必要はない。

判定：

```text
Design Gap:
NONE
```

---

# 18. Implementation Detailとして次工程で決定する事項

以下はRequirement Gap / Design Gapではなく、P1-07 Implementation Detailとする。

```text
modMailApplication内の具体Procedure
既存APIを接続する具体的Call順
MailItem Local Referenceの保持方法
Display Gate判定コード
Cleanup呼出パターン
Result返却方法
Test Harness構成
Debug Evidence出力内容
```

これらは次の、

```text
P1-07 Display / E2E Integration 実施仕様 v0.1
```

で具体化する。

---

# 19. Boundary Decision

P1-07のBoundaryを以下で固定候補とする。

```text
Render
↓
Post-Render Snapshot
↓
CheckUnresolved
↓
Display Gate
├─ Success
│  + HasUnresolved=False
│      ↓
│   DisplayMail
│
└─ Failure
   + HasUnresolved=True
       ↓
    No Display
       ↓
    Variables保持
       ↓
    CloseWithoutSave
```

責務：

```text
modUnresolvedChecker
= 判定

modMailApplication
= Orchestration / Gate

modOutlookAdapter
= MailItem Display / Close

P6
= Error / Safety / Lifecycle最終化
```

---

# 20. Gap / Impact Summary

```text
Requirement Gap:
NONE

Design Gap:
NONE

Technical Spike Reopen:
NOT REQUIRED

Test Specification Change:
NOT REQUIRED

Baseline Change:
NOT REQUIRED

P1-06 Contract Change:
NOT REQUIRED

Formal Test Execution:
NOT PERFORMED

Next:
P1-07 Display / E2E Integration 実施仕様 v0.1
```

---

# 21. Boundary Confirmation Result

```text
P1-07 Display / E2E Integration

Boundary:
DEFINED

Requirement Gap:
NONE

Design Gap:
NONE

Blocking Question:
NONE

Ready for Unit Specification:
YES
```
