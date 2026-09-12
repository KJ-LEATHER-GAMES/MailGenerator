# MVP Test Specification v0.1 → v0.1.1 差分パッチ v0.1

## 1. パッチ情報

| 項目 | 内容 |
|---|---|
| パッチ名 | MVP Test Specification v0.1 → v0.1.1 差分パッチ |
| パッチバージョン | v0.1 |
| Source | `MVP Test Specification v0.1 日本語版.md` |
| Target | `MVP Test Specification v0.1.1 日本語版.md` |
| Requirements Baseline | `MVP Requirements v0.1.6 日本語版.md` |
| Design Baseline | `MVP Design v0.1.5 日本語版.md` |
| Technical Evidence | `Technical Spike A 実施仕様書 v0.2 日本語版_CLOSED.md` |
| 起点レビュー | `MVP Test Specification v0.1 Baseline整合性レビュー v0.1.md` |
| 対象Finding | TSR-001〜TSR-012 |
| Requirement Change | なし |
| Design Change | なし |
| Requirement Gap | なし |
| Additional Technical Spike | 不要 |
| 作成日 | 2026-09-11 |

---

## 2. 目的

本Patchは、`MVP Test Specification v0.1` のBaseline整合性レビューで確認したTest Gate、条件Coverage、重複Test、Test分類、Expected明確性を修正する。

本Patchでは、利用者向けRequirementやDesign Decisionを新規追加・変更しない。

変更対象はTest Specification内の以下に限定する。

1. Mandatory Test Gateの厳格化
2. UserForm起動時Configuration Checkの条件Coverage補完
3. Invalid Variable Syntaxの停止・通知Evidence補強
4. Date内部値 / 再Formatの直接確認
5. Optional空欄のSubject / Body両方の確認
6. OptionMaster分離の直接確認
7. Dynamic UserFormの実使用Variable数確認
8. NFR-006のMandatory Design Review化
9. 重複Test統合
10. Safety TestのSummary Gate化
11. Date Expectedの具体化
12. Evidence再利用ルールの明文化

---

# 3. 差分一覧

| Patch ID | 対象 | 内容 | Finding |
|---|---|---|---|
| PATCH-TS-011-001 | Version / 更新概要 | v0.1.1化 | Mechanical |
| PATCH-TS-011-002 | §4 Traceability | Coverageの意味を明確化 | Review conclusion |
| PATCH-TS-011-003 | §6 Evidence | Evidence再利用ルール追加 | TSR-012 |
| PATCH-TS-011-004 | §9.3 / §12 | CFG-007 / CFG-008追加 | TSR-002 |
| PATCH-TS-011-005 | §10 / §12 / Traceability | Invalid Variable停止・通知補強 | TSR-003 |
| PATCH-TS-011-006 | §9.3 / §12 | UI-005実使用Variable数レイアウト追加 | TSR-007 |
| PATCH-TS-011-007 | MTS-UI-004 | OptionMaster分離Evidence追加 | TSR-006 |
| PATCH-TS-011-008 | MTS-REN-003 | Optional空欄Subject / Body Variant化 | TSR-005 |
| PATCH-TS-011-009 | MTS-REN-004 | Date内部値 / 6 Format具体Expected | TSR-004 / 011 |
| PATCH-TS-011-010 | §9.6 / §15 | SAFE-004をVAL-005へ統合 | TSR-009 |
| PATCH-TS-011-011 | §9.7 / §16 | NFR-004をSummary Gate化 | TSR-010 |
| PATCH-TS-011-012 | §9.7 / §16 | NFR-006をMandatory Design Review化 | TSR-008 |
| PATCH-TS-011-013 | §17〜20 | Traceability表更新 | Consequence |
| PATCH-TS-011-014 | §23 / §26 | Mandatory Test PASS必須化 | TSR-001 |
| PATCH-TS-011-015 | §27 | Target Version / 次工程更新 | Mechanical |

---

# 4. 詳細差分

## PATCH-TS-011-001 Version / 更新概要

### Before

```markdown
# MVP Test Specification v0.1 日本語版
```

```markdown
| バージョン | v0.1 |
```

### After

```markdown
# MVP Test Specification v0.1.1 日本語版
```

```markdown
| バージョン | v0.1.1 |
```

§1 文書情報の後へ追加する。

```markdown
### v0.1.1 更新概要

`MVP Test Specification v0.1` とBaseline 3文書の整合性レビュー結果を反映した。

主な変更は以下である。

1. Mandatory Testは「実施済み」ではなく「すべてPASS」をMVP Test Gate条件とした
2. UserForm起動時の未登録Variable / 削除済みActive Variableを独立Testとして追加した
3. Invalid Variable Syntaxについて、処理停止だけでなく不正記述をユーザーが確認できることを明示した
4. Date入力をValidation後に日付値として扱い、入力表記を直接引き継がず再FormatするTestを明確化した
5. Optional空欄VariableのSubject / Body双方での空文字列置換を確認対象とした
6. Select OptionがOptionMaster管理であることを直接確認するEvidenceを追加した
7. RISK-DES-003に対応し、実使用Variable数でのUserForm利用可能性を確認するTestを追加した
8. NFR-006をMandatory Design Reviewとした
9. 重複していたMTS-SAFE-004をMTS-VAL-005へ統合した
10. MTS-NFR-004を独立実行TestではなくSafety Summary Gateへ再分類した
11. Date 6 FormatのExpectedを具体値で定義した
12. 1回の実行Evidenceを複数Test Caseへ再利用できるルールを明示した

利用者向けRequirement、Design Decision、Technical Decisionは変更していない。
```

---

## PATCH-TS-011-002 §4.1 Traceability / Coverageの意味

### 対象

`### 4.1 Traceability`

### 追記

```markdown
Requirement Coverageは以下の2段階で扱う。

```text
Traceability Mapping Coverage
= Requirement IDが1件以上のTest Caseへ紐付いていること

Condition Coverage
= Requirement本文に含まれる必要条件がTest手順 / Expectedへ具体化されていること
```

§18の `47 / 47 FR` はTraceability Mapping Coverageを表す。

MVP Test PASS判定では、IDの紐付けだけでなく、各Mandatory TestのExpected ResultがPASSしていることを必要とする。
```

### 理由

`47 / 47 FR` を「Requirement本文の全条件が既にPASSした」という意味に誤解しないため。

---

## PATCH-TS-011-003 §6 Evidence再利用ルール

### 対象

`## 6. Evidence方針`

末尾へ追加する。

```markdown
### 6.1 Evidence再利用

1回のTest実行が複数のRequirement / Test Caseを同時に検証する場合、同一Evidenceを複数Test Caseから参照してよい。

ただし以下を満たすこと。

- 各Test IDごとのExpected Resultを個別に判定できる
- Evidenceの参照先を記録する
- 1つのTest CaseがFAILしたことを、同じEvidenceを参照する別Test Caseへ自動的に波及させない
- Test目的の異なるCaseを単に1件として統合しない

例：

```text
MTS-TPL-004実行Evidence
→ MTS-ERR-001のOFT読込Error確認にも参照可能

MTS-UNR-002実行Evidence
→ MTS-MAIL-004のError時Lifecycle確認にも参照可能
```

Test Coverageを維持しながら、不要な再実行を避ける。
```

---

# 5. Configuration / UserForm Test追加

## PATCH-TS-011-004 §9.3 Test Case一覧

### Before

```markdown
| MTS-CFG-006 | Select Active Optionなし | Negative | Mandatory |
| MTS-UI-001 | Dynamic UserForm生成 | Manual / Functional | Mandatory |
...
| MTS-UI-004 | Select選択専用 / Active Option順 | Manual / Functional | Mandatory |
```

### After

```markdown
| MTS-CFG-006 | Select Active Optionなし | Negative | Mandatory |
| MTS-CFG-007 | Template未登録VariableでUserForm停止 | Negative | Mandatory |
| MTS-CFG-008 | Template削除済みActive VariableでUserForm停止 | Negative | Mandatory |
| MTS-UI-001 | Dynamic UserForm生成 | Manual / Functional | Mandatory |
...
| MTS-UI-004 | Select選択専用 / Active Option順 / OptionMaster参照 | Manual / Functional | Mandatory |
| MTS-UI-005 | 実使用Variable数でのUserForm利用可能性 | Manual / Risk | Mandatory |
```

---

## MTS-CFG-007 Template未登録VariableでUserForm停止

§12へ追加する。

```markdown
## MTS-CFG-007 Template未登録VariableでUserForm停止

**Traceability**

- FR-UI-CHECK-001
- FR-UI-CHECK-002
- NFR-004

**Precondition**

VariableDefinitionには存在しないVariableをOFTへ追加する。

```text
OFT:
{{NewVariable}}

VariableDefinition:
NewVariableなし
```

手動同期は実施しない。

**Steps**

1. UserForm起動を実行する
2. VariableDefinitionを確認する

**Expected**

- Current OFT Scanで `NewVariable` を検出する
- Template未登録VariableとしてConfiguration Error
- UserFormを起動しない
- VariableDefinitionへ `NewVariable` を自動追加しない
- 自動同期を実行しない
- ユーザーが `NewVariable` が未登録であることを確認できる
```

---

## MTS-CFG-008 Template削除済みActive VariableでUserForm停止

§12へ追加する。

```markdown
## MTS-CFG-008 Template削除済みActive VariableでUserForm停止

**Traceability**

- FR-UI-CHECK-001
- FR-UI-CHECK-002
- NFR-004

**Precondition**

```text
OFT:
ModelNameなし

VariableDefinition:
ModelName = Active
```

手動同期は実施しない。

**Steps**

1. UserForm起動を実行する
2. VariableDefinitionを確認する

**Expected**

- Templateから削除されたActive VariableとしてConfiguration Error
- UserFormを起動しない
- `ModelName` を自動でUnusedへ変更しない
- 自動同期を実行しない
- ユーザーが `ModelName` の不整合を確認できる
```

---

# 6. Invalid Variable Syntax Test補強

## PATCH-TS-011-005 MTS-SCAN-004

### Before Expected

```markdown
**Expected**

- ValidVariablesへ入らない
- InvalidCandidatesとして全件検出する
- 手動同期 / UserForm / メール生成を停止可能なResultとなる
```

### After Expected

```markdown
**Expected**

- ValidVariablesへ入らない
- InvalidCandidatesとして全件検出する
- 検出した不正記述そのものをResultとして保持する

Expected InvalidCandidates：

```text
{{1stGate}}
{{_GateDate}}
{{審査日}}
{{User-Name}}
{{ UserName }}
```

このResultが以下へ接続できること。

```text
InvalidCandidates
├─ 手動同期停止 → MTS-SYNC-010
├─ UserForm起動停止
└─ メール生成停止 → MTS-SAFE-002等
```

UI通知では、少なくとも検出した不正記述をユーザーが確認できる。

Scanner内部の検出成功だけでFR-VAR-005全体をPASSとしない。
```

### UserForm起動停止の確認

MTS-CFG群に以下を追加してもよいが、Test数増加を抑えるため、`MTS-SCAN-004` のIntegration Variantとして実施する。

```markdown
**Integration Variant：UserForm**

1. Invalid Variableを含むOFTを最初から用意する
2. UserForm起動を実行する

Expected：

- UserForm起動停止
- 自動同期しない
- 不正記述一覧を通知
```

手動同期停止は `MTS-SYNC-010`、メール生成停止は `MTS-SAFE-002` のEvidenceと合わせてFR-VAR-005を判定する。

---

# 7. Dynamic UserForm Risk Test

## PATCH-TS-011-006 MTS-UI-005

§12へ追加する。

```markdown
## MTS-UI-005 実使用Variable数でのUserForm利用可能性

**Traceability**

- FR-UI-001
- NFR-005
- Design RISK-DES-003

**Type**

Manual / Risk

**Precondition**

MVPで実際に使用予定のOFT / VariableDefinitionの最大または代表的Variable数を使用する。

**Steps**

1. UserFormを起動する
2. 全入力項目へアクセスできるか確認する
3. 末尾付近の項目へ入力する
4. 「入力クリア」「メール作成」等の主要操作へアクセスする

**Expected**

- 必要なすべての入力項目へアクセスできる
- 入力Controlが操作不能な位置へ隠れない
- Mail作成 / 入力クリア等の主要操作を実行できる
- 実使用Variable数でUserForm利用が成立する

具体的なForm寸法、ScrollBar有無、配置方式を本Testから新Requirementとして固定しない。
```

---

# 8. OptionMaster分離Test補強

## PATCH-TS-011-007 MTS-UI-004

### Before Expected

```markdown
**Expected**

- Active Optionのみ
- SortOrder順
- 自由入力不可
- Inactive Option「生産部」は表示しない
```

### After

```markdown
**Precondition**

```text
VariableDefinition:
VariableName = Department
Type         = Select
OptionSource = Department
```

```text
OptionMaster:
Department / 設計部 / Active=True
Department / 品質部 / Active=True
Department / 生産部 / Active=False
```

**Expected**

- ComboBoxの選択肢はOptionMasterから取得する
- VariableDefinitionは選択肢文字列リストを直接保持せず、OptionSourceだけを参照する
- Active Optionのみ表示
- SortOrder順
- 自由入力不可
- Inactive Option「生産部」は表示しない
```

### 理由

FR-OPT-001の「VariableDefinitionとOptionMasterの責務分離」を表示結果だけでなく直接Evidence化する。

---

# 9. Optional空欄Test補強

## PATCH-TS-011-008 MTS-REN-003

### Before

```markdown
## MTS-REN-003 Optional空欄

**Traceability**

- FR-VAL-001
- Design §21.1

**Input**

```text
Comment = 空欄
Required = False
```

**Expected**

`{{Comment}}` を空文字列へ置換し、未置換として残さない。
```

### After

```markdown
## MTS-REN-003 Optional空欄

**Traceability**

- FR-VAL-001
- FR-RENDER-SUB-001
- FR-RENDER-BODY-001
- Design §21.1

Optional Variableの空欄をSubject / Body双方で確認する。

### Variant A：Body

Baseline OFTの `{{Comment}}` を使用する。

```text
Comment  = 空欄
Required = False
```

Expected：

- Bodyの `{{Comment}}` を空文字列へ置換
- Unresolved Variableとして残らない

### Variant B：Subject

Test用OFTのSubjectへOptional Variableを配置する。

```text
Subject:
【{{ModelName}}】{{OptionalNote}}

OptionalNote = 空欄
Required     = False
```

Expected：

- Subjectの `{{OptionalNote}}` を空文字列へ置換
- Unresolved Variableとして残らない

Optional空欄が存在してもRender / Displayを阻害しない。
```

---

# 10. Date Test補強

## PATCH-TS-011-009 MTS-REN-004

### Before

```markdown
**Input**

同一日付を6 Formatで出力する。

**Expected**

```text
yyyy/mm/dd
yyyy-mm-dd
yyyy年m月d日
m月d日
yyyy年m月d日(aaa)
m月d日(aaa)
```

定義どおり。
```

### After

```markdown
**Input**

ユーザー入力：

```text
2026-9-30
```

Validation後は日付値 `2026-09-30` として扱い、入力時のゼロ埋め・セパレータを出力へ直接引き継がない。

同一日付値へ6種類のFormatを適用する。

**Expected**

```text
yyyy/mm/dd        → 2026/09/30
yyyy-mm-dd        → 2026-09-30
yyyy年m月d日       → 2026年9月30日
m月d日             → 9月30日
yyyy年m月d日(aaa)  → 2026年9月30日(水)
m月d日(aaa)        → 9月30日(水)
```

**PASS条件**

- Raw Input `2026-9-30` の文字列表現を直接コピーしていない
- Validation後の日付意味値から各Formatを生成している
- 6種類すべてExpectedと一致する
```

曜日生成の具体的なVBA実装方法はTest側で固定しない。

---

# 11. 重複Test整理

## PATCH-TS-011-010 MTS-SAFE-004削除 / MTS-VAL-005へ統合

### §9.6 Test Case一覧

以下を削除する。

```markdown
| MTS-SAFE-004 | UserForm表示後OptionMaster変更 | Negative / Safety | Mandatory |
```

### §15

以下の独立Test Caseを削除する。

```markdown
## MTS-SAFE-004 UserForm表示後OptionMaster変更
...
MTS-VAL-005と同じScenarioをSafety視点で確認する。
```

### MTS-VAL-005 Traceability

既存：

```markdown
- FR-VAL-001
- NFR-004
- Design §19 / §25.3
- FCR-001
```

を維持する。

MTS-VAL-005自身をSafety RequirementのEvidenceとして使用する。

### 理由

実行Scenarioが完全に同一であり、別実行Testを持つ必要がない。

Test ID `MTS-SAFE-004` はv0.1.1でRetiredとし、別目的へ再利用しない。

---

# 12. Safety Summary Gate

## PATCH-TS-011-011 §9.7 / MTS-NFR-004

### §9.7 Before

```markdown
| MTS-NFR-004 | 不完全状態Fail Fast | Safety Summary | Mandatory |
```

※現行表記が `Safety Summary` でない場合は、Typeを以下へ変更する。

### After

```markdown
| MTS-NFR-004 | 不完全状態Fail Fast | Summary Gate | Mandatory |
```

### §16 MTS-NFR-004

見出しを維持し、以下へ置換する。

```markdown
## MTS-NFR-004 安全性

**Traceability**

- NFR-004

**Type**

Summary Gate

本Case自体で新しい操作を実行しない。

以下のSafety関連Mandatory Test Resultを集約する。

- MTS-TPL-003
- MTS-SCAN-004
- MTS-CFG-001〜008
- MTS-VAL-001
- MTS-VAL-003〜008
- MTS-UNR-002 / 003
- MTS-SAFE-001〜003
- MTS-MAIL-004

**PASS**

上記の適用対象Mandatory TestがすべてPASSしている。

**FAIL**

上記のいずれかにFAIL / BLOCKEDが残存している。

同一Evidenceを複数Caseから参照してよく、本Summary GateのためにTestを再実行しない。
```

---

# 13. NFR-006 Gate修正

## PATCH-TS-011-012 §9.7

### Before

```markdown
| MTS-NFR-006 | 将来型追加時の局所変更性Review | Design Review | Conditional |
```

### After

```markdown
| MTS-NFR-006 | 将来型追加時の局所変更性Review | Design Review | Mandatory |
```

## §16 MTS-NFR-006

### Before

```markdown
**Gate**

Conditional。

MVP実装完了をBlockingする定量性能Testとはしない。
```

### After

```markdown
**Gate**

Mandatory Design Review。

将来型そのものを実装する必要はない。

**PASS**

以下が局所化されており、将来型追加のためにMVP全体の大規模な構造変更を前提としていない。

- Type / Control mapping
- Validation
- Value Formatter
- Data Access
- Renderer / Outlook Adapter責務

Review Evidenceとして、影響Componentと変更箇所の想定を記録する。

NFR-006は性能数値のTestではないが、Baseline RequirementであるためReview自体を省略可能なConditional Testとはしない。
```

---

# 14. Traceability更新

## PATCH-TS-011-013 §17 Acceptance Criteria Traceability

以下を更新する。

```markdown
| AC-003 | MTS-SCAN-004 / MTS-SYNC-010 / MTS-SAFE-002 |
| AC-006 | MTS-UI-001 / 002 / 003 / 005 |
```

AC-005等は変更不要。

---

## §18 Functional Requirement Coverage

以下を更新する。

```markdown
| FR-VAR-005 | MTS-SCAN-004 / MTS-SYNC-010 / MTS-SAFE-002 |
| FR-OPT-001 | MTS-UI-004 |
| FR-UI-001 | MTS-UI-001 / MTS-UI-005 |
| FR-UI-CHECK-001 | MTS-TPL-003 / MTS-SCAN-004 / MTS-CFG-001〜008 |
| FR-UI-CHECK-002 | MTS-SCAN-004 / MTS-CFG-001〜008 |
| FR-TYPE-DATE-003 | MTS-REN-004 |
| FR-RENDER-SUB-001 | MTS-REN-001 / MTS-REN-003 |
| FR-RENDER-BODY-001 | MTS-REN-002 / MTS-REN-003 |
```

既存の他Mappingは維持する。

§18末尾の、

```markdown
**Coverage：47 / 47 FR**
```

を以下へ変更する。

```markdown
**Traceability Mapping Coverage：47 / 47 FR**

これは全47 FRが1件以上のTest Caseへ紐付いていることを示す。

実行後のRequirement PASS Coverageは、各Mandatory Test Resultを基に判定する。
```

---

## §19 NFR Coverage

### Before

```markdown
| NFR-006 拡張性 | MTS-NFR-006 |
```

行自体は維持し、末尾の説明へ以下を追加する。

```markdown
MTS-NFR-006はMandatory Design Reviewとする。
```

---

## §20 Technical Spike A Regression Traceability

変更不要。

TF-A-002 → MTS-UNR-004を維持する。

---

# 15. Exit Criteria / MVP Test Gate修正

## PATCH-TS-011-014 §23 Exit Criteria

### Before

```markdown
1. Mandatory Testをすべて実施済み
2. AC-001〜020がすべてPASS
3. 47 FRのCoverageがすべてPASSまたは正当なN/A
4. NFR-001〜005がPASS
5. NFR-006はDesign Review結果を記録
6. High / Blocking Failureが0件
...
10. FAILが存在する場合、MVP Release可否判断を記録済み
```

### After

```markdown
MVP Test完了条件：

1. Mandatory Testをすべて実施済み
2. Mandatory TestにFAIL / BLOCKEDが残っていない
3. Mandatory TestはすべてPASS、またはBaseline上適用外であることを明示した正当なN/Aである
4. AC-001〜020がすべてPASS
5. 47 FRのTraceability Mappingが維持され、適用対象RequirementのMandatory TestがPASSしている
6. NFR-001〜006がすべてPASS
7. Safety Summary Gate（MTS-NFR-004）がPASS
8. Technical Spike A Regression項目がPASS
9. Test Evidenceを保存済み
10. Requirement Gap / Design Gapが発生した場合、Baseline側で解決済み
```

### N/A Rule追記

```markdown
Mandatory TestのN/Aは、Baseline上そのRequirement / Design Ruleが当該Buildへ適用されないことを明示できる場合のみ使用できる。

「実施困難」「未実装」「時間不足」はN/A理由としない。
```

---

## §26 MVP Test Gate

### PASS Before

```markdown
- Mandatory Test実施済み
- AC-001〜020 PASS
- Blocking Failureなし
- Safety Test PASS
- Technical Spike A Regression PASS
- Requirement / Design Gap未解決なし
```

### PASS After

```markdown
以下をすべて満たす。

- Mandatory TestにFAIL / BLOCKEDが残っていない
- Mandatory TestはすべてPASS、または正当なN/A
- AC-001〜020 PASS
- NFR-001〜006 PASS
- MTS-NFR-004 Safety Summary Gate PASS
- Technical Spike A Regression PASS
- Requirement / Design Gap未解決なし
```

### CONDITIONAL PASS

以下へ変更する。

```markdown
- Product Requirement / Acceptance Criteria / Mandatory Safety条件はすべて満たす
- Mandatory TestにFAIL / BLOCKEDは残っていない
- Scope外またはNon-BlockingなDocumentation / Environment Issueのみ残存
- IssueとMVP Releaseへの影響を記録済み
```

### FAIL

以下を先頭へ追加する。

```markdown
- Mandatory TestにFAIL / BLOCKEDが1件以上残存する
```

既存のFAIL条件は維持する。

---

# 16. Test Result記録テンプレート補強

§24のテンプレートへ以下を追加する。

```markdown
- Evidence Reference:
- N/A Reason:
```

ルール：

```markdown
- PASS / FAIL判定時はEvidence Referenceを記録する
- N/A選択時はN/A Reasonを必須とする
```

---

# 17. 次工程更新

## PATCH-TS-011-015 §27

### Before

```text
MVP Test Specification v0.1
        ↓
Test Specificationレビュー
```

### After

```text
MVP Test Specification v0.1.1
        ↓
Test Specification最終整合性確認
```

後続：

```text
Technical Spike B / C 要否確認
↓
Implementation Plan v0.1
↓
VBA実装
↓
MVP Test実施
↓
Test Result / Finding
↓
MVP判定
```

は維持する。

末尾：

```markdown
本Test Specification v0.1の作成によって、新しいRequirement / Design Decisionは追加しない。
```

を以下へ更新する。

```markdown
本Test Specification v0.1.1および本Patchによって、新しい利用者向けRequirement / Design Decisionは追加していない。
```

---

# 18. 変更しない項目

本Patchでは以下を変更しない。

- Requirements v0.1.6
- Design v0.1.5
- Technical Spike A v0.2 CLOSED
- Route W：WordEditor
- AC-001〜020の内容
- FR 47件の内容
- NFR 6件の内容
- Test Result Statusの5分類
- Technical Spike A Regression方針
- TF-A-002の独立判定方針
- Test環境の対象Platform
- Baseline Test Dataの基本構成
- Test実施Phase

---

# 19. Requirement追加有無

```text
新しい利用者向けRequirement：なし
Requirement Gap：なし
Design Gap：なし
Additional Technical Spike：不要
```

追加したTest Caseは、既存Requirement / Design Riskの条件Coverageを具体化したものである。

```text
MTS-CFG-007
→ FR-UI-CHECK-001 / 002

MTS-CFG-008
→ FR-UI-CHECK-001 / 002

MTS-UI-005
→ Design RISK-DES-003 + FR-UI-001 / NFR-005
```

---

# 20. Patch適用後チェックリスト

## Must Fix

- [ ] Mandatory Test PASS必須化
- [ ] CFG-007追加
- [ ] CFG-008追加
- [ ] UserForm不整合時の自動同期禁止をExpectedへ明記
- [ ] Invalid Variableの不正記述一覧通知を確認

## Condition Coverage

- [ ] Date Raw Input → Date意味値 → Formatを確認
- [ ] Optional空欄のSubject / Body双方を確認
- [ ] OptionMaster分離を直接確認
- [ ] 実使用Variable数のUserForm利用可能性を確認
- [ ] NFR-006をMandatory Review化

## Cleanup

- [ ] MTS-SAFE-004をRetired
- [ ] MTS-NFR-004をSummary Gate化
- [ ] Date Expectedを具体値化
- [ ] Evidence再利用ルールを追加
- [ ] Traceability表を更新
- [ ] v0.1.1自己参照へ更新

---

# 21. Patch判定

```text
Source Test Specification : v0.1
Target Test Specification : v0.1.1
Requirements              : v0.1.6
Design                    : v0.1.5
Technical Spike A         : v0.2 CLOSED
Requirement Change        : No
Design Change             : No
Requirement Gap           : No
Additional Spike          : Not Required
Test Gap                  : Closed by patch
Redundant Test            : Reduced
```

**Patch判定：適用可能**
