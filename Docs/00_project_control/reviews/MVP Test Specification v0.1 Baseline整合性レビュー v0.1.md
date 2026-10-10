# MVP Test Specification v0.1 Baseline整合性レビュー v0.1

## 1. 対象

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
MVP Test Specification v0.1
```

レビュー日：2026-09-11

---

## 2. 総合判定

**判定：CONDITIONAL PASS**

`MVP Test Specification v0.1` は、Baseline 3文書に対して全体構造・Traceability・Technical Spike AのRegression継承という点で妥当である。

特に以下は適切。

- AC-001〜020をTestへ展開している
- 47 FR / 6 NFRをTraceability表へ紐付けている
- Technical Spike AのTSA-001〜010をRegression Testへ引き継いでいる
- TF-A-002のFalse Positive対策として「Scanner成立性」と「Unresolved 0件」を別Testとしている
- WordEditor方式を本番MVP実装に対して再検証する方針
- Safety / Current OFT / Current VariableDefinition / Current OptionMasterをTestへ含めている
- PASS / FAILだけでなくBLOCKED / N/Aを区別している

一方、現時点の `47 / 47 FR Coverage` は**Requirement IDが何らかのTestへ紐付いていることを示すCoverage**であり、Requirement本文の全条件をすべて検証できていることまでは保証しない。

条件単位で再確認した結果、以下を修正すべきと判断した。

---

# 3. Finding一覧

| ID | 重要度 | 分類 | Finding | 推奨 |
|---|---|---|---|---|
| TSR-001 | High | Test Gate Defect | Mandatory TestがFAILしてもGate上PASS可能な余地がある | 修正必須 |
| TSR-002 | High | Test Gap | UserForm起動時のTemplate / VariableDefinition不整合2ケースが未検証 | 追加必須 |
| TSR-003 | Medium | Test Gap | Invalid Variable Syntaxの「3処理停止＋不正記述確認」が一連で未検証 | 補強 |
| TSR-004 | Medium | Test Gap | FR-TYPE-DATE-003の「Validation後に日付値として扱う」を直接確認していない | 補強 |
| TSR-005 | Medium | Test Gap | Optional空欄VariableのSubject側置換を確認していない | 補強 |
| TSR-006 | Medium | Test Gap | FR-OPT-001のOptionMaster分離を明示的に検証していない | 補強 |
| TSR-007 | Medium | Design Risk Coverage | RISK-DES-003の実使用変数数でのUserFormレイアウト確認がない | 追加推奨 |
| TSR-008 | Medium | Requirement Weakening Risk | NFR-006をConditional扱いしておりBaselineより弱く解釈する余地がある | 修正推奨 |
| TSR-009 | Low | Redundancy | MTS-SAFE-004がMTS-VAL-005と実質同一 | 統合 |
| TSR-010 | Low | Test Classification | MTS-NFR-004は実行TestではなくSummary Gateに近い | 再分類 |
| TSR-011 | Low | Test Clarity | Date 6 FormatのExpectedが「定義どおり」で具体値不足 | 明確化 |
| TSR-012 | Low | Test Efficiency | 一部Error / Lifecycle Testは同じ実行Evidenceを再利用可能 | 実行重複削減 |

---

# 4. TSR-001 Mandatory Test Gateの不整合

## 現状

§23 Exit Criteria：

```text
1. Mandatory Testをすべて実施済み
2. AC-001〜020がすべてPASS
...
```

§26 PASS：

```text
- Mandatory Test実施済み
- AC-001〜020 PASS
- Blocking Failureなし
...
```

ここではMandatory Testに対して要求されているのが「実施済み」であり、「PASS」ではない。

例えばACへ直接紐付かないMandatory Supplementary TestがFAILしても、

- AC-001〜020 = PASS
- Blocking Failureの定義外

であれば、文書上PASSできる余地がある。

例：

```text
MTS-SYNC-011 Sync metadata更新 = FAIL
```

でも、Gate文言だけでは必ずFAILになるとは限らない。

## 推奨

Exit Criteria：

```text
Mandatory TestはすべてPASS
```

へ変更する。

N/Aを認める場合は、

```text
Mandatory TestのN/Aは、Baseline上そのRequirement / Design Ruleが当該Buildに適用されないことを明示できる場合のみ
```

とする。

また、`High / Blocking Failure` をGateへ使用するならSeverity定義を追加する。

MVPでは簡潔に、

```text
Mandatory Test FAIL / BLOCKEDが1件でも残存 → PASS不可
```

とする方が再現性が高い。

---

# 5. TSR-002 UserForm起動時Configuration CheckのTest抜け

## Baseline

FR-UI-CHECK-001はUserForm起動前に少なくとも以下を確認する。

- テンプレートに未登録変数が存在しない
- テンプレートから削除された変数がActiveのまま残っていない

FR-UI-CHECK-002では、

- 不整合時にUserFormを起動しない
- 自動同期しない

ことを要求する。

## 現Test

以下は存在する。

- MTS-CFG-001 新規Variable設定未完了
- MTS-CFG-002 SortOrder未設定
- MTS-CFG-004 Date Format不正
- MTS-CFG-005 / 006 Select設定不備
- MTS-SCAN-004 Invalid Candidate
- MTS-SYNC-001 手動同期のみ

しかし、以下2Scenarioが独立していない。

### Scenario A

```text
OFT:
{{NewVariable}}

VariableDefinition:
NewVariableなし
```

UserForm起動を試行する。

Expected：

- 未登録VariableとしてConfiguration Error
- UserForm起動しない
- VariableDefinitionへ自動追加しない

### Scenario B

```text
OFT:
ModelNameなし

VariableDefinition:
ModelName = Active
```

UserForm起動を試行する。

Expected：

- Templateから削除されたActive VariableとしてConfiguration Error
- UserForm起動しない
- 自動でUnusedへ変更しない

## 推奨

以下を追加。

```text
MTS-CFG-007 Template未登録Variable
MTS-CFG-008 Template削除済みActive Variable
```

またはMTS-CFG-001を複数Scenario化する。

安全性と切り分けを考えると独立Testを推奨する。

---

# 6. TSR-003 Invalid Variable SyntaxのE2E不足

## Baseline

FR-VAR-005 / AC-003：

Invalid `{{...}}` が存在する場合、

- 手動同期停止
- UserForm起動停止
- メール生成停止
- 検出した不正記述をユーザーが確認可能

が必要。

## 現Test

MTS-SCAN-004：

- InvalidCandidatesとしてScanner検出
- 「3処理を停止可能なResult」

MTS-SYNC-010：

- Sync停止

MTS-SAFE-002：

- UserForm表示後に追加したInvalid VariableでMail生成停止

一方で、

```text
最初からInvalid VariableがあるOFT
↓
UserForm起動
```

および、

```text
ユーザー通知で実際の不正記述
{{User-Name}}
等を確認できる
```

という点が明示的ではない。

## 推奨

MTS-SCAN-004のExpectedをScanner内部だけで完了させず、以下のTraceability Testへ接続する。

```text
Invalid Candidate
↓
Sync停止
↓
UserForm停止
↓
Mail生成停止
↓
UIで不正記述一覧を確認
```

全部を1回のTestにする必要はないが、4条件すべてのEvidenceをTraceability上明示する。

---

# 7. TSR-004 Date内部値の意味論確認不足

## Baseline

FR-TYPE-DATE-003：

> 入力された日付は、Validation後に日付値として扱う。  
> ユーザーが入力したゼロ埋めやセパレータは出力形式には直接引き継がない。

## 現Test

- MTS-VAL-003：入力形式Validation
- MTS-REN-004：6 Format出力

FR Coverage上はFR-TYPE-DATE-003 → MTS-REN-004となっている。

しかしMTS-REN-004は「同一日付を6 Formatで出力」としか記述されておらず、

```text
Input = 2026-9-8
Format = yyyy/mm/dd
Expected = 2026/09/08
```

のような「入力文字列表現を引き継がずDate意味値から再Formatする」確認が明確ではない。

## 推奨

MTS-REN-004に代表ケースを追加。

```text
Raw Input : 2026-9-8
Internal  : Date(2026/09/08)
Format    : yyyy/mm/dd
Expected  : 2026/09/08
```

これによりFR-TYPE-DATE-003を直接Evidence化する。

---

# 8. TSR-005 Optional空欄のSubject側Test不足

## Baseline Design

Value Formatter：

```text
Required=False + 空欄
→ Formatted Value = ""
```

Subject Renderer / Body Renderingの双方が空文字列を使用する。

## 現Test

MTS-REN-003：

```text
Comment = 空欄
Required = False
```

Baseline OFTのCommentはBodyのみ。

したがってBody側は確認するが、Subject内にOptional Variableが存在した場合の空文字列置換を確認していない。

## 推奨

新規Testを増やさず、MTS-REN-003を2Variantにする。

### Variant A

Optional Variable = Body

### Variant B

Optional Variable = Subject

Expected：

- 空文字列へ置換
- Unresolvedとして残らない

---

# 9. TSR-006 FR-OPT-001 OptionMaster分離のTest不足

## Baseline

FR-OPT-001：

- Select OptionをVariableDefinitionへ直接保持しない
- OptionMasterで管理
- VariableDefinitionはOptionSource参照

## 現Test

MTS-UI-004：

- Active Optionのみ
- SortOrder順
- 自由入力不可

これは表示結果は確認するが、

> 選択肢のSourceがOptionMasterであり、VariableDefinitionへ埋め込んでいない

ことを明示的に確認していない。

## 推奨

MTS-UI-004またはMTS-NFR-002へ以下のEvidenceを追加。

```text
VariableDefinition:
OptionSource = Department

OptionMaster:
Department / 設計部
Department / 品質部
```

確認：

- ComboBox項目はOptionMasterから生成
- VariableDefinitionには選択肢文字列リストを保持しない

これは新RequirementではなくFR-OPT-001の直接検証。

---

# 10. TSR-007 RISK-DES-003 Dynamic UserForm

## Baseline Design

RISK-DES-003：

> 変数数が増えた場合の縦方向レイアウト・スクロールが必要になる可能性がある。  
> MVPでは実使用テンプレートの変数数を基準に確認する。

## 現Test

MTS-UI-001〜004 / MTS-NFR-005はUserForm生成・E2Eを確認するが、

```text
実使用テンプレートの全Variable数
```

で画面が利用可能かを明示していない。

## 推奨

Manual Visual Testとして追加。

```text
MTS-UI-005 実使用Variable数レイアウト
```

Expected：

- 必要な入力項目へアクセス可能
- Mail作成 / 入力クリア操作が利用可能
- 項目が画面外へ消えて操作不能にならない

具体的な寸法・Scroll方式をTest側から新Requirementとして固定しない。

---

# 11. TSR-008 NFR-006をConditional扱いしている

## Baseline

NFR-006：

> 将来型追加時に大規模な構造変更を必要としないことを目標とする。

## 現Test

```text
MTS-NFR-006
Gate = Conditional
```

Exit Criteria：

```text
NFR-006はDesign Review結果を記録
```

この書き方では、Review結果が明らかに不適合でもMVP PASSできる解釈が可能。

これはRequirement追加ではないが、Baseline RequirementをTest Gateで弱くしている。

## 推奨

以下のいずれか。

### 推奨A

```text
MTS-NFR-006 = Mandatory Design Review
```

PASS条件：

- 型追加の影響が局所化されている
- 大規模な全体構造変更を前提としていない

将来型を実装する必要はない。

### 非推奨B

Conditionalのままにする場合、Requirements側でNFR-006をNon-Gatingと明示する。

今回はRequirement変更を避けるためAを推奨。

---

# 12. TSR-009 重複Test

## 現状

MTS-VAL-005：

```text
UserForm表示中にOptionMasterを変更
↓
Current Active OptionでValidation
```

MTS-SAFE-004：

> MTS-VAL-005と同じScenarioをSafety視点で確認する。

実行内容が同一。

## 推奨

MTS-SAFE-004を削除し、

```text
MTS-VAL-005
Traceability:
FR-VAL-001
NFR-004
FCR-001
```

へ統合する。

Test件数を増やさずCoverageを維持できる。

---

# 13. TSR-010 MTS-NFR-004はSummary Gate

MTS-NFR-004は、

```text
以下の個別TestがすべてPASS
```

という定義であり、独立したTest Procedureを持たない。

これは実行TestというよりDerived Result / Summary Gate。

## 推奨

Test一覧では、

```text
Type = Summary Gate
```

または別章のSafety Gateへ移す。

重複実行しない。

---

# 14. TSR-011 Date 6 Format Expectedの具体化

MTS-REN-004：

```text
定義どおり
```

のみではEvidence比較時に判断者差が生じる。

Baseline Date：

```text
2026/09/30
```

を用いるならExpectedを具体化する。

例：

```text
yyyy/mm/dd        → 2026/09/30
yyyy-mm-dd        → 2026-09-30
yyyy年m月d日       → 2026年9月30日
m月d日             → 9月30日
yyyy年m月d日(aaa)  → 2026年9月30日(水)
m月d日(aaa)        → 9月30日(水)
```

曜日生成の具体VBA実装は固定しない。

---

# 15. TSR-012 Evidence再利用

以下はTest目的が異なるためTest ID自体は残してよいが、同じ実行結果をEvidenceとして共有できる。

例：

```text
MTS-TPL-004
→ MTS-ERR-001のOFT読込Error Evidence

MTS-UNR-002
→ MTS-MAIL-004のError時Lifecycle Evidence

MTS-CFG系Negative Test
→ MTS-NFR-004 Safety Summary
```

これによりTest SpecificationのCoverageを落とさず実行負荷を減らせる。

---

# 16. Requirementを勝手に追加していないか

## 結論

**利用者向けProduct Requirementの追加は確認されなかった。**

以下はBaselineから正当に導出されるSupplementary Testであり、新Requirementではない。

- UserForm表示後のOFT変更
- UserForm表示後のVariableDefinition変更
- UserForm表示後のOptionMaster変更
- WordEditor Lifecycle
- COM Error変換
- Scanner成立性 / Unresolved独立判定
- Sync metadata

これらはRequirements / Design / Technical Spike Aの既存DecisionをTestへ具体化したもの。

### Test工程独自のルール

以下はProduct RequirementではなくTest Governanceとして追加されている。

- NOT RUN / PASS / FAIL / BLOCKED / N/A
- Evidence記録
- Entry / Exit Criteria
- Finding分類

これらはTest Specificationで決めてよい。

ただし、前述のTSR-001 / TSR-008のようにProduct Requirementを弱めるGate定義にはしない。

---

# 17. 過剰Test判定

## 明確に統合可能

```text
MTS-SAFE-004
→ MTS-VAL-005へ統合
```

## Summary扱いへ変更可能

```text
MTS-NFR-004
→ Safety Summary Gate
```

## Evidence共有可能

- MTS-TPL-004 / MTS-ERR-001
- MTS-UNR-002 / MTS-MAIL-004
- Configuration Negative Tests / Safety Gate

## 残すべきSupplementary Test

以下は一見Acceptance Criteria外だが、削除しない。

- Existing設定保持
- Reactivated
- Rename
- Sync metadata
- Current Config Validation
- MailItem Lifecycle
- TF-A-002 Regression

いずれもBaseline文書に根拠がある。

---

# 18. Test抜け判定

修正優先度順：

### Must Fix

1. Mandatory Test Gateを「実施」ではなく「PASS」にする
2. Template未登録VariableでUserForm停止
3. Template削除済みVariableがActiveのままならUserForm停止
4. UserForm不整合時に自動同期しないEvidence

### Should Fix

5. Invalid Variableの実際の不正記述をユーザーが確認可能
6. Date内部値 / 再Format
7. Optional空欄Subject置換
8. OptionMaster分離
9. RISK-DES-003 UserForm実使用変数数
10. NFR-006 Gate整合

### Cleanup

11. SAFE-004統合
12. NFR-004 Summary化
13. Date expected具体化
14. Evidence共有

---

# 19. 修正後の期待状態

```text
Requirements v0.1.6
+
Design v0.1.5
+
Technical Spike A v0.2 CLOSED
+
Test Specification v0.1.1
```

想定判定：

```text
Requirement追加      : なし
Requirement Gap      : なし
Design変更           : 原則なし
Additional Spike     : 不要
Test Case追加/補強   : あり
Test重複削減         : あり
```

---

# 20. 最終結論

`MVP Test Specification v0.1` はBaselineに対して概ね正しく、全面的な作り直しは不要。

ただし、

- Test GateのPASS条件
- UserForm起動時Configuration Checkの条件Coverage

には実質的な穴があるため、このままTest SpecificationをBaseline化するのは推奨しない。

上記Findingを差分パッチで反映した `v0.1.1` を作成した後、Test SpecificationをBaseline化することを推奨する。
