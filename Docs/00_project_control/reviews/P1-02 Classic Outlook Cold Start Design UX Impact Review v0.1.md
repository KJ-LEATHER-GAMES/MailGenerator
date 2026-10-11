# P1-02 Classic Outlook Cold Start Design / UX Impact Review v0.1

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | P1-02 Classic Outlook Cold Start Design / UX Impact Review |
| バージョン | v0.1 |
| 対象 | TV-P1-02-001結果を受けたDesign / UX影響判定 |
| 対象Phase | P1 Walking Skeleton / P1-02 Inspector WordEditor Connection |
| Review入力 | TV-P1-02-001 Result Record v0.1 |
| 優先方針 | **A. ツール側でClassic Outlookを起動する** |
| Review Result | **REQUIREMENT + DESIGN + TEST SPEC AFFECTED** |
| P1-02 Status | NOT COMPLETE |

---

## 2. Review結論

TV-P1-02-001により、Classic Outlook Cold Start時は以下が確認された。

```text
Hidden Explorer
→ WordEditor Access FAIL

Visible Explorer
→ WordEditor Access PASS
→ 2回連続Cold Start PASS
```

したがって、MVPでは以下の方針を採用候補とする。

```text
Classic OutlookがWordEditor利用可能状態でない
↓
ツールがClassic Outlook Explorerを起動
↓
WordEditor利用可能状態を成立
↓
Scan / Generationを継続
```

ユーザーへ「事前にOutlookを起動しておく」操作は要求しない。

ただし、Classic Outlook Explorerが自動的に画面表示されることは利用者から見える挙動であるため、Implementation Detailだけでは閉じない。

---

## 3. Requirements Impact

### 3.1 判定

```text
DOC-MVP-REQ
Impact = AFFECTED
Change Type = Semantic Clarification / Requirement Decision
Requirement Gap = RESOLVED by user decision
```

A案の採用により、未決だった利用者向け挙動を以下として確定する。

> Classic Outlookが未起動またはWordEditor利用に必要なExplorerが存在しない場合、ツールは必要に応じてClassic Outlookを起動してよい。

### 3.2 推奨修正箇所

新規FRを増やすより、既存 `FR-OUTLOOK-001` へ最小追記する。

追記候補：

```text
Classic Outlookが未起動、またはWordEditor利用に必要な
Outlook Explorerが存在しない場合、ツールはテンプレート依存処理に
必要な範囲でClassic Outlookを起動する。

Classic Outlookが既に利用可能な場合は、既存Outlookを利用し、
不要な追加Explorerを生成しない。

Scan / Validation / Render途中のMailItemは、
既存Requirementどおり利用者へDisplayしない。
```

### 3.3 変更しないRequirement

以下は維持する。

```text
最終MailItem Displayは全Check成功後のみ
自動送信なし
ツール責任範囲は最終MailItem Displayまで
New Outlook対象外
```

---

## 4. UX Impact

### 4.1 Cold Start時

利用者がManual Syncまたはメール作成開始など、
WordEditorを必要とする最初の操作を行った時点で、
Classic Outlookが未起動であればOutlook Explorerが表示される。

```text
Excel操作
↓
Classic Outlook未起動
↓
Outlook Explorer自動起動
↓
Excel側処理継続
```

### 4.2 Warm Start時

既にClassic Outlook Explorerが存在する場合は追加起動しない。

```text
Explorer Count > 0
↓
既存Outlookを利用
↓
新規Explorer生成なし
```

### 4.3 MailItem表示との区別

Cold Start初期化で表示されるのはOutlook Explorerであり、
Scan用またはError途中のMailItemではない。

```text
Outlook Explorer Display
≠
MailItem Display
```

したがって、以下は維持する。

```text
Scan MailItem Display = NONE
Error途中MailItem Display = NONE
最終生成MailItem Display = 全Check成功後のみ
```

---

## 5. Explorer Lifecycle / Ownership

### 5.1 推奨方針

ツールがCold Start時にOutlook Explorerを起動した場合、
初期化完了後に `Explorer.Close` は行わない。

```text
Tool starts Classic Outlook
↓
Explorer.Display
↓
必要なCOM参照のみ解放
↓
Classic Outlook自体は起動状態を維持
```

### 5.2 理由

- 起動直後に閉じるとユーザーから見て起動・終了のちらつきが発生する
- UserForm起動時Scan後に閉じると、メール生成時に再度Cold Startとなり得る
- 最終的に生成メールはClassic OutlookへDisplayするため、Outlookを起動状態で維持する方が処理全体と整合する
- ツールが既存Outlook Explorerを誤って閉じるリスクを避けられる

### 5.3 Ownership

```text
MailItem
Owner = modOutlookAdapter
Cleanup = CloseWithoutSave / Display後はOutlook側

Explorer
Owner = Classic Outlook application
Tool = 初期化のため生成・Displayする場合あり
Tool = Explorer.Closeしない

Local Explorer COM reference
Owner = modOutlookAdapter helper
Cleanup = Nothing
```

---

## 6. Design Impact

### 6.1 判定

```text
DOC-MVP-DES
Impact = AFFECTED
Semantic Design Change = YES
```

理由：

現行Designは `OFT → MailItem → Inspector / WordEditor` を定義しているが、
Cold Start時に必要なClassic Outlook Explorer初期化責務を定義していない。

### 6.2 §12 OFT / MailItem Lifecycle

Scan / Generationの双方へ、MailItem生成前のReadiness処理を追加する。

```text
Classic Outlook Readiness
↓
OFT
↓
MailItem
↓
Inspector / WordEditor
...
```

### 6.3 §13 Outlook Adapter責務

Outlook Adapterへ以下の責務を追加する。

```text
Classic Outlook readiness確認
Cold Start時のExplorer initialization
既存Explorer存在時の再利用
Explorer initialization errorのResult変換
```

新しい専用Adapter / Classは追加しない。

### 6.4 推奨Design API境界

Public APIは増やさず、Adapter内部Helperとする。

概念候補：

```text
Private EnsureOutlookReady(...)
```

または既存 `GetOutlookApplication` 内部から呼び出す。

外部ComponentへExplorer Objectを公開しない。

### 6.5 §24 Error Design

Cold Start初期化失敗は既存 `OutlookError` を使用する。

Target候補：

```text
OutlookStartup
OutlookExplorer
```

新規ErrorTypeは追加しない。

### 6.6 §25 Sequence

以下3フローで、最初のOutlook Adapter利用時にReadiness処理を通す。

```text
Manual Sync
UserForm起動
Mail Generation
```

同一処理内でOutlookが既にReadyなら追加Explorerは生成しない。

### 6.7 Design Decision追加

推奨：

```text
D18 Classic Outlook Cold Start Initialization
```

採用内容：

```text
WordEditor利用前にClassic Outlook readinessを確認する。
利用可能なExplorerが存在しない場合、
Outlook AdapterがVisible Explorerを起動する。

既存Explorerが存在する場合は追加生成しない。
Scan / Error途中のMailItemはDisplayしない。
```

---

## 7. Risk Impact

`RISK-DES-002 Outlook / Word COM` を更新する。

追加Evidence：

```text
Warm Start:
WordEditor PASS

Cold Start + Hidden Explorer:
WordEditor FAIL

Cold Start + Visible Explorer:
WordEditor PASS x2
```

Risk Treatment：

```text
Cold Start initializationをOutlook Adapterへ局所化
↓
WordEditor接続前にReadiness成立
↓
COM FailureはOutlookErrorへ変換
```

WordEditor方式そのものをReopenする必要はない。

Technical Spike AもReopenしない。

---

## 8. Test Specification Impact

### 8.1 判定

```text
DOC-MVP-TESTSPEC
Impact = AFFECTED
```

新しいTest IDを必須とはせず、既存CaseへVariantを追加する。

### 8.2 MTS-MAIL-003

Cold Start Variantを追加する。

Precondition：

```text
Classic Outlook完全終了
Explorer Count = 0
```

Expected：

```text
ツールがClassic Outlook Explorerを起動
Scan MailItemはDisplayしない
ReadBodyText成功
Draft増加なし
Inspector残存なし
```

### 8.3 MTS-MAIL-001

Cold Startから最終Mail DisplayまでのIntegration Variantを追加する。

Expected：

```text
ユーザーによるOutlook事前起動不要
最終MailItemは全Check成功後のみDisplay
```

### 8.4 MTS-ERR-002

Outlook Explorer initialization失敗を再現可能な場合、
既存Outlook / Word COM Error変換CaseのEvidence対象へ追加する。

### 8.5 MTS-NFR-005

操作性E2Eで以下を明確化する。

```text
Excel
↓
User操作
↓
必要時Classic Outlook自動起動
↓
UserForm / Mail生成
↓
最終Mail Display
```

ユーザーへ「先にOutlookを起動する」手作業を要求しない。

---

## 9. Implementation Plan Impact

Phase構成の変更は不要。

```text
P1 Walking Skeleton
```

内のP1-02 Production Resolutionとして処理する。

Implementation Planの工程構造やP1/P6責務を変更する必要はない。

---

## 10. Baseline / Document Governance Impact

Semantic Changeを伴うため、現行BL-MVP-002へ直接上書きしない。

推奨Candidate：

```text
DOC-MVP-REQ
v0.1.8 → v0.1.9 Candidate

DOC-MVP-DES
v0.1.8 → v0.1.9 Candidate

DOC-MVP-TESTSPEC
v0.1.4 → v0.1.5 Candidate
```

整合性確認後に次Baseline Candidateへ昇格する。

現行BL-MVP-002は、新Baseline承認までCurrent Approved Baselineとして保持する。

---

## 11. Review Decision

### A. ツール側でClassic Outlookを起動する

```text
ADOPT
```

### B. ユーザーへClassic Outlook事前起動を要求する

```text
REJECT
```

理由：

- Aはユーザーの事前操作を増やさない
- TV-P1-02-001で技術成立性を確認済み
- Scan用MailItemをDisplayせず成立する
- Draft / Inspector残存なしを維持できる
- Outlook / Word依存をAdapter内部へ局所化できる

---

## 12. Review Result

```text
Requirements Impact:
AFFECTED

Design Impact:
AFFECTED

Test Specification Impact:
AFFECTED

Implementation Plan Structure:
UNCHANGED

Technical Spike A:
NO REOPEN

Requirement Decision:
A. Tool automatically starts Classic Outlook when required

Production Implementation:
NOT YET APPROVED

P1-02:
NOT COMPLETE
```

---

## 13. 次アクション

```text
1. Requirements Semantic Patch
   FR-OUTLOOK-001
   ↓
2. Design Semantic Patch
   §12 / §13 / §24 / §25 / §27 / RISK-DES-002
   ↓
3. Test Specification Impact Patch
   MTS-MAIL-001 / 003
   MTS-ERR-002
   MTS-NFR-005
   ↓
4. 3文書整合性Review
   ↓
5. Baseline Candidate更新
   ↓
6. P1-02 Production Patch
   EnsureOutlookReady
   ↓
7. Cold / Warm Regression
   ↓
8. P1-02 PASS / COMPLETE判定
```
