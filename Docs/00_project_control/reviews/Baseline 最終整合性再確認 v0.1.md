# Baseline 最終整合性再確認 v0.1

## 1. 対象Baseline

```text
MVP Requirements v0.1.6
+
MVP Design v0.1.4
+
Technical Spike A v0.2 CLOSED
```

レビュー日：2026-09-11

---

## 2. 総合判定

**判定：CONDITIONAL PASS**

Technical Direction、Requirement→Designの主要Traceability、Technical Spike AのTechnical Decision反映は整合している。

前回レビューで確認したCR-001〜CR-006はすべてCloseを確認した。

一方、今回の再確認で以下を新たに確認した。

| ID | 重要度 | 分類 | 内容 | Test Specification開始への影響 |
|---|---|---|---|---|
| FCR-001 | High | Design Completeness | Mail生成時Input ValidatorがCurrent VariableDefinition / OptionMasterを取得する前に実行される | **要修正** |
| FCR-002 | Low | Design Consistency | §5 Input Stateの責務が「Excel終了まで」となっており、FR-INPUT-001 / §18.2の「Workbookを閉じるまで」と表現不一致 | **要修正（軽微）** |
| OBS-001 | Info | Document Lifecycle | Requirements §34およびSpikeの次工程記述は作成時点の工程Snapshotであり、現在は一部完了済み | 修正不要 |
| OBS-002 | Info | Spike Metadata | Spike §8のOS / Excel / Outlook詳細Versionは後日確認のまま | Non-Blocking |

**Requirement Gap：なし**

**追加Technical Spike：不要**

FCR-001 / FCR-002をDesignへ局所反映後、BaselineをPASSとしてMVP Test Specification v0.1へ進める。

---

# 3. 前回Finding Close確認

## CR-001 メール生成直前のCurrent OFT再確認

**Close：YES**

Design v0.1.4 §12.2 / §25.3に以下を反映済み。

```text
生成用MailItem
↓
Subject / BodyText取得
↓
Template Scanner
↓
Configuration Validator
↓
Current Template / Configuration確認
↓
Render
```

UserForm起動時のScan結果をメール生成時まで無条件に信用しないことも明文化されている。

---

## CR-002 未置換Variable一覧

**Close：YES**

Design §23に以下を定義済み。

```text
UnresolvedCheckResult
├─ HasUnresolved
└─ Variables[]
```

FR-UNRESOLVED-002の一覧表示までUIへ引き渡せる。

---

## CR-003 Select自由入力禁止

**Close：YES**

Design §17.2でSelectを選択専用ComboBoxとし、`fmStyleDropDownList` 相当を明記済み。

---

## CR-004 VariableDefinition自動列更新規則

**Close：YES**

Design §7.4 / §15に以下の更新規則を定義済み。

- TemplateLocation
- Status
- FirstDetectedAt
- LastDetectedAt
- SyncTimestamp

---

## CR-005 Unused通常非表示 / 必要時確認

**Close：YES**

Design §7.5 / §10.3でActive通常表示と全件取得を分離済み。

---

## CR-006 Requirements旧工程参照

**Close：YES（当時の対象問題）**

旧 `MVP Design v0.1.2 Reopen` をActiveな次工程として参照する状態は解消済み。

Requirements §34はv0.1.6作成時点の工程Snapshotとして、

```text
Requirements v0.1.6
→ Design v0.1.4
→ 最終整合性再確認
→ Test Specification
```

を記録している。

現在Design v0.1.4まで完了したため工程自体は進行済みだが、Versioned Documentの履歴として矛盾とは扱わない。

---

# 4. 新規Finding

## FCR-001 Mail生成時Input ValidatorのCurrent Data参照順序

### 関連Requirements

- FR-VAL-001
- FR-TYPE-SELECT-001
- FR-OPT-001 / 002
- NFR-004

### 現Design

Design §25.3：

```text
Control値 → InputValues
↓
Input Validator
↓
...
VariableDefinition / OptionMaster取得
↓
Configuration Validator
```

この順序では、Input Validatorが現在のVariableDefinition / OptionMasterを取得する前に実行されている。

### 問題

UserForm表示後にOptionMaster等が変更されたケースを考える。

```text
UserForm起動時
OptionMaster:
A / B / C

ユーザーが C を選択

UserForm表示後
OptionMaster:
A / B
C = Inactive

メール生成
```

FR-VAL-001では、Select値が**現在のOptionMasterの有効Optionに存在すること**をValidationしなければならない。

しかし現シーケンスでは、Input ValidatorがUserForm起動時の旧設定または不明確な設定を参照する余地がある。

その後Configuration ValidatorがCurrent OptionMasterを確認しても、

```text
OptionSourceにActive Optionが1件以上存在する
```

ことしか確認しないため、選択済み `C` が現在InactiveであることをInput Validationで取りこぼす可能性がある。

### 判定

新Requirementではない。

FR-VAL-001を満たすためのDesign completeness不足。

### 推奨修正

Mail生成時は、Input Validatorより前にCurrent VariableDefinition / OptionMasterを取得する。

推奨順序：

```text
Control値 → InputValues
↓
VariableDefinition / OptionMaster取得
↓
Input Validator
  - Current Required
  - Current Type
  - Current Active Options
↓
Input Error？
↓
Current OFT Scan
↓
Configuration Validator
↓
Render
```

またはCurrent Template / Configuration Checkを先に実行した後、その同じCurrent VariableDefinition / OptionMasterをInput Validatorへ渡してもよい。

重要なのは、

> Input Validatorがメール生成時点のCurrent VariableDefinition / OptionMasterを入力として使用する

ことをDesign上明示することである。

新しいComponent / Snapshot管理 / Version管理はMVPでは追加しない。

---

## FCR-002 Input Stateの保持期間表現

### Requirements

FR-INPUT-001：

> UserFormで入力した値は、Excelファイルを閉じるまで保持する。

### Design §18.2

```text
InputValuesはWorkbook Session中のメモリ上の状態
Workbookを閉じた時点で保持対象外
```

これはRequirementsと一致している。

### Design §5

一方、Component責務表では、

```text
Input State | Excel終了までの入力値保持
```

となっている。

### 判定

Design内部の軽微な文言不整合。

### 推奨修正

```text
Before:
Input State | Excel終了までの入力値保持

After:
Input State | Workbookを閉じるまでの入力値保持
```

---

# 5. Technical Spike A整合性

## Route W

**整合：PASS**

Spike：

```text
Route W：WordEditor
Range.Find + Range.Text
```

Design D16：

```text
Route W：Inspector.WordEditor
+ Word Range.Find / Range.Text
```

一致。

---

## Scanner / Unresolved Checker

SpikeではWordEditor / Word Document上で成立性を検証した。

Designでは外部COM依存をInfrastructureへ閉じ込めるため、

```text
Word Document
↓
Outlook Adapter
↓
BodyText
↓
Template Scanner / Unresolved Checker
```

へ抽象化している。

Spike Evidenceと矛盾せず、Architecture上の責務分離として妥当。

---

## TF-A-001

**反映：PASS**

Design `RISK-DES-001 — CLOSED` へEvidenceと不採用理由を反映済み。

---

## TF-A-002

**反映：PASS**

Requirements §34 / Design §32で、

```text
Variable検出成立性
≠
Unresolved 0件判定
```

を別TestとしてMVP Test Specificationへ引き継ぐことを明示済み。

---

# 6. Requirements領域別最終Coverage

| Requirements領域 | Design Coverage | 判定 |
|---|---|---|
| OFT相対パス | Settings / Outlook Adapter | PASS |
| OFT不存在 | Fail Fast / §25各Sequence | PASS |
| Variable Syntax | Template Scanner | PASS |
| Case Insensitive | Scanner / Dictionary / Renderer / Checker | PASS |
| Invalid Candidate | TemplateScanResult / Configuration Validator | PASS |
| Template Sync | Sync Engine | PASS |
| Sync metadata | Sync Engine / VariableDefinition Data | PASS |
| Unused | Data Access / UI方針 | PASS |
| Required | Configuration / Input Validator | PASS |
| Text 1行 | UserForm Generator | PASS |
| Date | Input Validator / Formatter | PASS |
| Select | UserForm / OptionMaster / Input Validator | **CONDITIONAL：FCR-001** |
| UserForm | UserForm Generator | PASS |
| SortOrder | Data Access / Generator / Validator | PASS |
| Input保持 | Input State | PASS（§5文言のみFCR-002） |
| Input Clear | Input State / UI | PASS |
| Validation一括表示 | Input Validator / Result / UI | PASS |
| Validation強調 | Tag / UI | PASS |
| Subject Render | Subject Renderer | PASS |
| Body Render | Outlook Adapter / WordEditor | PASS |
| Body書式 | WordEditor / Spike Evidence | PASS |
| Unresolved | Unresolved Checker / Result / UI | PASS |
| Outlook Display | Outlook Adapter | PASS |
| 自動送信防止 | Mail処理SequenceがDisplayで終了、Send責務なし | PASS |
| Error可観測性 | Result / Error / UI | PASS |
| Safety | Fail Fast | PASS after FCR-001 |
| Extensibility | Lightweight layered design | PASS |

---

# 7. Reference / Version確認

## Design → Requirements

Active参照：

```text
MVP Design v0.1.4
→ MVP Requirements v0.1.6
```

**PASS**

旧v0.1.5参照は更新履歴内のみ。

---

## Spike → Requirements / Design

Spike：

```text
Requirements v0.1.4
Design v0.1.2
```

これはSpike実施時点のBaselineを示すため維持する。

**PASS**

CLOSED文書を現在版へ更新しない。

---

## Requirements §34

Design v0.1.4を「次工程」とする記述は、v0.1.6作成時点の工程Snapshot。

現在はその工程を完了している。

これを追い続けてRequirements / Designの版を相互に上げるとVersion Churnになるため、**本再確認ではRequirement変更理由としない**。

運用上のCurrent Next Actionは本レビュー文書 / Context Handoffで管理することを推奨する。

---

# 8. Technical Spike環境メタデータ

Spike §8には以下が後日確認として残っている。

- OS
- Excel Version / Bitness
- Classic Outlook Version / Bitness
- VBA実行元ブック
- 実施者

Spike自身がNon-Blocking metadataとしてClose済み。

したがって、

```text
Test Specification開始：Blockingしない
Technical Decision：再Openしない
```

と判定する。

ただし再現性向上のため、確認できた時点で追記する。

---

# 9. Requirement Gap / Additional Spike

```text
Requirement Gap：なし
Additional Technical Spike：不要
```

FCR-001 / 002はいずれも既存RequirementをDesignへ正確に落とし込む局所修正である。

---

# 10. 次アクション

Test Specificationへ進む前にDesignのみ局所修正する。

想定：

```text
MVP Requirements v0.1.6
        +
MVP Design v0.1.5
  - FCR-001修正
  - FCR-002修正
        +
Technical Spike A v0.2 CLOSED
        ↓
最終確認
        ↓
MVP Test Specification v0.1
```

Requirements v0.1.6およびTechnical Spike Aは変更不要。

Design修正は以下の2点だけとし、Scopeを拡張しない。

1. §25.3 / §19でInput ValidatorがCurrent VariableDefinition / OptionMasterを使用することを明示
2. §5 Input State責務を「Workbookを閉じるまで」に修正

---

## 11. 最終結論

現BaselineはTechnical Directionとして整合しており、前回の主要FindingもCloseしている。

ただしFCR-001はFR-VAL-001 / NFR-004に直接関係するため、Test Specification開始前に修正する。

FCR-002は軽微だが同時に修正する。

修正後は、追加Requirement判断や追加Spikeを行わずMVP Test Specification v0.1へ進める。
