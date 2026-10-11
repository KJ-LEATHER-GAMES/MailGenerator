# Implementation Plan v0.3 Candidate 日本語版

## 1. 文書情報

| 項目 | 内容 |
|---|---|
| 文書名 | Implementation Plan |
| Document ID | DOC-MVP-IMPL |
| バージョン | v0.3 |
| 文書種別 | Implementation Plan |
| 対象プロジェクト | 定型メール作成ツール MVP |
| Status | Review / Candidate |
| Execution Baseline | BL-MVP-003 |
| Primary Gate | 各Phase Exit Criteria |
| Formal Product Gate | DOC-MVP-TESTSPECによるMVP Test |
| Checkpoint | CP-P0 ～ CP-P7 |
| Test Candidate Build | MVP-Bxxx |

### Related Documents

- DOC-MVP-REQ
- DOC-MVP-DES
- DOC-TS-A
- DOC-MVP-TESTSPEC

### Supporting Decision

- Technical Spike B-C 要否判定 v0.1：B / Cともに NOT REQUIRED

### v0.3 更新概要

本Revisionは、`BL-MVP-003` のApproved化および `DOC-MVP-IMPL v0.2 / BL-MVP-003 Impact Review v0.1` の判定を反映し、Implementation PlanのExecution BaselineとP1 / P6実装計画をCurrent Approved Baselineへ整合させるCandidate Revisionである。

主な変更は以下である。

1. Execution Baselineを `BL-MVP-002` から `BL-MVP-003` へ更新
2. Baseline Manifestを `DOC-MVP-REQ v0.1.9` / `DOC-MVP-DES v0.1.9` / `DOC-MVP-TESTSPEC v0.1.5` を含む構成へ更新
3. `IMP-R01 Baseline Driven`、P0 Input / Exit Criteria、Formal Test Result、Implementation Entry Criteria、Appendix AのActive Baseline参照を更新
4. P1 Walking Skeletonへ `Classic Outlook Readiness` とCold Start時のVisible Explorer Initializationを追加
5. P1 InputへDesign Decision `D18 Classic Outlook Cold Start Initialization` を追加
6. P1 VerificationへWarm Start / Cold Startの両経路とExplorer / Draft / Inspector Lifecycle確認を追加
7. P6 Error / Safety ScopeへOutlook Startup / Explorer Initialization Failureを追加
8. P6 VerificationへCold Start Readiness Failureの `OutlookError` 変換とFail Closed確認を追加
9. Phase構成、Checkpoint構成、Module Mapping、Route W / WordEditor、Technical Spike B / C = NOT REQUIRED、Formal MVP Test方針は変更しない
10. P1-02 Implementation Unit Specificationは別Revision対象とし、本Plan内で詳細Production APIを再定義しない

**Change Type：Execution Baseline Update / Plan-level Semantic Alignment**
**Requirement Impact：None（DOC-MVP-REQ v0.1.9を反映）**
**Additional Design Change：None（DOC-MVP-DES v0.1.9を反映）**
**Technical Decision Impact：None**
**Additional Test Definition Change：None（DOC-MVP-TESTSPEC v0.1.5を反映）**
**Candidate Status：Review / Not Yet Approved**

---

### v0.2 更新概要

本Revisionは、`BL-MVP-002` のApproved化に伴う `DOC-MVP-IMPL v0.1 / BL-MVP-002 Impact Review v0.1` の判定を反映し、Implementation PlanのExecution BaselineをCurrent Approved Baselineへ整合させる正式Revisionである。

主な変更は以下である。

1. Execution Baselineを `BL-MVP-001` から `BL-MVP-002` へ更新
2. Baseline Manifestを `DOC-MVP-DES v0.1.8` / `DOC-MVP-TESTSPEC v0.1.4` を含む構成へ更新
3. `IMP-R01 Baseline Driven`、P0 Input / Exit Criteria、Test Candidate Build、Implementation Entry Criteria、Appendix AのBaseline参照を更新
4. Baseline変更ルールを特定Baseline ID依存から `Current Execution Baseline` ベースへ整理
5. Technical Spike B / Cは `NOT REQUIRED` を維持
6. Phase構成、Module構成、Route W / WordEditor、P1 Walking Skeleton、P1-02以降の実装方針は変更しない
7. OneDrive Local Path Resolutionの詳細仕様は `DOC-MVP-DES` / `DOC-MVP-TESTSPEC` をSource of Truthとし、本書へ重複記載しない

**Change Type：Execution Baseline Update / Plan-level Semantic Alignment**
**Requirement Impact：None**
**Additional Design Change：None**
**Technical Decision Impact：None**
**Additional Test Definition Change：None**

### v0.1 作成概要

本書は、BL-MVP-001で承認されたRequirement / Design / Technical Evidence / Test Definitionを、VBA実装へ段階的かつ再現可能な形で落とし込むためのImplementation Plan初版である。

本書では、Requirement / Design / Test Definitionを再定義せず、以下を管理する。

1. 実装Phaseと依存関係
2. 各PhaseのImplementation Scope
3. Implementation Detailを決定するタイミング
4. 各PhaseのDeliverable / Verification / Exit Criteria
5. DOC-MVP-TESTSPECとの接続
6. Commit / Checkpoint / Test Candidate Buildの管理方針
7. Implementation Finding発生時のEscalation Rule

---

## 2. 目的

本書の目的は、BL-MVP-003で承認されたMVPを、確定済みDesignに従ってVBA実装へ安全に落とし込むため、実装順序、依存関係、Verification、および完了条件を定義することである。

本書は「何を作るか」または「どのようなArchitectureを採用するか」を再決定する文書ではない。

RequirementsのSource of TruthはDOC-MVP-REQ、DesignのSource of TruthはDOC-MVP-DES、Technical EvidenceのSource of TruthはDOC-TS-A、正式Test DefinitionのSource of TruthはDOC-MVP-TESTSPECとする。

---

## 3. Scope / Out of Scope

### 3.1 Scope

本Implementation Planの対象は以下とする。

- VBA Project Skeleton
- Excel Data Access
- Result / Error Model
- Settings取得
- OFT参照
- Outlook / WordEditor連携
- Template Scanner
- Sync Engine
- Configuration Validator
- Dynamic UserForm
- Input State
- Input Validator
- Date処理
- Value Formatter
- Subject Renderer
- WordEditor Body Rendering
- Unresolved Checker
- Error Handling
- Outlook Lifecycle
- Phase単位Verification
- Test Candidate Build固定までの実装作業

### 3.2 Implementationで具体化する事項

DOC-MVP-REQ / DOC-MVP-DESでImplementation Detailとして残されている以下を、対応Phaseで具体化する。

1. Validation Error強調の具体的な表示方式・色
2. 曜日表記生成の具体的なVBA実装
3. エラーコード体系および例外捕捉の具体コード
4. Unused表示切替の具体的なUI実装
5. 同期結果UIの具体表示
6. OFT不存在時の具体的な復旧UI
7. Dictionary / RegExp / Word Object Model等のBinding方式
8. UserForm寸法・Scroll方式
9. Range.Findの具体的な検索ループ
10. COM参照解放の具体コード
11. Module統合の最終調整

### 3.3 Out of Scope

以下は本書の対象外とする。

- Requirementの追加・削除・意味変更
- Design Decisionの変更
- Route W / WordEditor Technical Decisionの再選定
- Test Case / Expected Result / Test Gateの再設計
- v0.2以降を想定した先回り実装
- Number型
- 条件分岐
- 添付自動処理
- 自動送信
- ログ機能
- 将来拡張のみを目的としたClass / Interface / Repository / Adapter追加

---

## 4. Implementation Baseline

### 4.1 Execution Baseline

本Implementation Planの実行基準は以下とする。

```text
Baseline ID : BL-MVP-003
Status      : Approved
```

Baseline構成：

```text
BL-MVP-003
│
├─ DOC-MVP-REQ      MVP Requirements v0.1.9
├─ DOC-MVP-DES      MVP Design v0.1.9
├─ DOC-TS-A         Technical Spike A v0.4 CLOSED / PASS
└─ DOC-MVP-TESTSPEC MVP Test Specification v0.1.5
```

### 4.2 Baseline変更ルール

Implementation中に新しいRevisionが作成されても、Current Execution Baselineを自動更新しない。

Requirement Gap / Design Gap等によりBaseline変更が必要となった場合は、Implementation側だけで解釈を変更せず、文書管理ルールに従い新Baseline Approvalを行う。

### 4.3 Technical Spike B / C

BL-MVP-003を基準として再確認した結果、Technical Spike B / CはともにNOT REQUIREDを維持する。

Implementation中に新たなTechnical Riskが発生した場合も、自動的にSpike B / Cを復活させない。

通常Implementation + Verificationでの確認が遅すぎ、大規模な手戻りにつながる新しいTechnical Questionが具体化した場合のみ、Technical Spike要否を再判定する。

---

## 5. Implementation Principles

### IMP-R01 Baseline Driven

すべての実装判断はBL-MVP-003を基準とする。

### IMP-R02 Design Conformance

DOC-MVP-DESで確定した責務境界、処理Sequence、Design Decisionを維持する。

### IMP-R03 Walking Skeleton First

最終ArchitectureのModule境界を用いて、早期に最小E2E経路を成立させる。

Walking Skeleton専用の捨てArchitectureは作成しない。

### IMP-R04 Incremental Integration

全Moduleを単体完成させてから最後に統合する方式は採用しない。

動作可能なVertical Sliceを段階的に拡張する。

### IMP-R05 Fail Fast / Fail Closed

Configuration Error / Input Error / Render Error / Unresolved Error等の不完全状態から、MailItemをDisplayできる経路を作らない。

### IMP-R06 Phase VerificationとFormal MVP Testを分離する

Phase内でDOC-MVP-TESTSPECのScenarioを参考に確認しても、それはImplementation Verificationであり正式MVP Test Resultではない。

正式Test Evidenceは、P7で固定したTest Candidate Buildに対して改めて実施する。

### IMP-R07 No Spec-by-Implementation

実装しにくいことを理由としてRequirement / Designを暗黙的に変更しない。

### IMP-R08 YAGNI

MVPで必要になっていない将来拡張用のClass / Interface / Adapter等を先行実装しない。

### IMP-R09 Responsibility Preservation

Module統合を行う場合も、UI / Application / Core Logic / Infrastructure / Stateの責務境界を崩さない。

### IMP-R10 Reproducible Checkpoint

各PhaseはCompile可能かつVerification可能な状態でExitし、Checkpointを記録する。

---

## 6. Design / Module Mapping

DOC-MVP-DESのVBA構成案を、以下のModule群としてImplementationへ接続する。

| Layer | Module / Component | 主なImplementation Phase |
|---|---|---|
| UI | frmMailGenerator | P3 / P4 / P6 |
| UI | modUiController | P3 / P4 / P6 |
| Application | modMailApplication | P1 / P5 / P6 |
| Application | modSyncApplication | P2 / P6 |
| Core Logic | modTemplateScanner | P1 / P2 / P5 |
| Core Logic | modSyncEngine | P2 |
| Core Logic | modConfigurationValidator | P3 / P5 |
| Core Logic | modInputValidator | P4 / P5 |
| Core Logic | modValueFormatter | P4 / P5 |
| Core Logic | modSubjectRenderer | P1 / P5 |
| Core Logic | modUnresolvedChecker | P1 / P5 |
| Infrastructure | modVariableDefinitionData | P0 / P2 / P3 / P5 |
| Infrastructure | modOptionMasterData | P0 / P3 / P5 |
| Infrastructure | modSettingsData | P0 / P1 / P5 |
| Infrastructure | modOutlookAdapter | P1 / P2 / P5 / P6 |
| Shared / State | modInputState | P3 / P4 |
| Shared / State | modResult | P0 / 全Phase |

### Module調整ルール

実装開始後、上記Module数が処理量に対して明らかに過剰な場合は、責務を崩さない範囲で近接Moduleを統合してよい。

ただし以下は維持する。

- Value FormatterとOutlook Adapterは分離
- Word Object Model依存はOutlook Adapter側へ集約
- UIはValidation判定ロジックを持たない
- Core LogicはExcel ListObject / Outlook Object Modelへ直接依存しない
- WordEditor専用Class / Adapterは必要性が実証されるまで追加しない

---

## 7. Implementation Phase Overview

| Phase | 名称 | Primary Objective | Dependency | Checkpoint |
|---|---|---|---|---|
| P0 | Foundation | 共通基盤・Data Access・Result構築 | なし | CP-P0 |
| P1 | Walking Skeleton | 最小E2Eを本番Architectureで成立 | P0 | CP-P1 |
| P2 | Scan / Sync | Template ScanとVariableDefinition同期完成 | P0 / P1 | CP-P2 |
| P3 | Configuration / UserForm | 設定Gate・動的UI・Input State完成 | P0 / P2 | CP-P3 |
| P4 | Validation / Formatting | Input ValidationとFormat完成 | P3 | CP-P4 |
| P5 | Full Mail Generation | Current Guardを含む正式生成経路完成 | P1～P4 | CP-P5 |
| P6 | Error / Safety / Integration | 異常系・Lifecycle・Fail Closed完成 | P1～P5 | CP-P6 |
| P7 | MVP Test Readiness | Test Candidate Build固定 | P0～P6 | CP-P7 |

### Phase Gate

各PhaseのPrimary Gateは、そのPhaseに定義するExit Criteriaとする。

Phase Exit Criteriaを満たさない状態で、依存する次Phaseを正式開始しない。

軽微な並行作業を行う場合も、未完了Dependencyを「完了扱い」しない。

---

## 8. Phase詳細

### 8.1 P0 — Foundation

#### Objective

後続Phaseが共通利用するVBA Project基盤、Result / Error、Excel Data Access、Settings取得基盤を構築する。

#### Input

- BL-MVP-003
- DOC-MVP-DES §9～11、§24、§26、§29

#### Implementation Scope

```text
VBA Project Skeleton
modResult
modSettingsData
modVariableDefinitionData
modOptionMasterData
必要最小限の共通定数
各後続ModuleのShell
```

後続ModuleのShellを作成する場合、中身を先回り実装しない。

#### 主な実装内容

- OperationResult相当のSuccess / Error表現
- ErrorType / Message / Target等の最低限のError情報
- Settings Key / Value取得
- VariableDefinition基本Read
- OptionMaster基本Read
- Excel ListObject操作のData Access内封じ込め
- Excel Workbook基準の相対Path解決基盤
- Case Insensitive Dictionaryを利用可能な基盤
- Compile可能なProject Skeleton

#### Implementation Detail to Decide

- Result / ErrorInfoをClass化するか軽量構造にするか
- Scripting.DictionaryのEarly Binding / Late Binding
- Module内Public / Private基本規則
- 共通定数の配置
- Error Code体系をP0で導入するか、P6まで保留するか

Error CodeがMVPに不要な場合、番号体系を作ること自体を目的化しない。

#### Deliverables

- VBA Project Skeleton
- modResult
- modSettingsData
- modVariableDefinitionData
- modOptionMasterData

#### Phase Verification

- Workbook / VBA ProjectがCompile可能
- SettingsをKey指定で取得可能
- VariableDefinitionをData Access経由で取得可能
- OptionMasterをData Access経由で取得可能
- Core / Application側へListObject操作が漏れていない
- Success / Error Resultを生成し、呼出元へ返却可能

#### Related Test Area

- MTS-TPL-001 / 002
- MTS-NFR-002
- 後続MTS-CFG-*のData Access前提

#### Exit Criteria

- 後続処理がExcel Tableへ直接依存せず必要データを取得できる
- Result / Errorを共通形式で返却できる
- Project全体がCompile可能
- BL-MVP-003とのConflictがない
- Blocking Implementation Findingがない

---

### 8.2 P1 — Walking Skeleton

#### Objective

最終Architectureを使用して、Excel → OFT → Classic Outlook Readiness → Outlook → WordEditor → Render → Unresolved Check → Displayの最小E2E経路を成立させる。

#### Input

- CP-P0
- DOC-MVP-DES §12～14、§22～25、D16、D18
- DOC-TS-A Route W Technical Evidence

#### Implementation Scope

```text
modMailApplication
modOutlookAdapter
modTemplateScanner      最小Happy Path
modSubjectRenderer      最小Happy Path
modUnresolvedChecker    最小Happy Path
```

#### Minimum Vertical Slice

正常な1つ以上のVariableを持つOFTを用いて、以下を最終Data Flow上で成立させる。

```text
Settings
↓
OFT Path
↓
Classic Outlook Readiness
↓
Explorerあり？
├─ Yes → Existing Outlook reuse
└─ No  → Visible Explorer起動 / Display
↓
Create MailItem
↓
Inspector / WordEditor
↓
Subject / BodyText取得
↓
Template Scanner
↓
Input Value
↓
Subject Render
↓
Word Range Body Render
↓
Subject / BodyText再取得
↓
Unresolved Check = 0
↓
Display
```

Variable名等をProduction CodeへHard CodingしてWalking Skeletonを成立させてはならない。

最終Module境界と最終データ経路を用い、対応するケース数のみを最小化する。

#### Implementation Detail to Decide

- Word Object Model参照設定 / Late Binding方針
- Classic Outlook Readiness確認の具体コード
- Existing Explorer再利用判定
- Cold Start時Visible Explorer初期化
- Explorer Local COM Reference解放
- Startup / Explorer Initialization Error変換
- Inspector / WordEditor取得コード
- Range.Find基本検索ループ
- Subject全出現置換の具体実装
- BodyText取得方法
- MailItem Close基本パターン
- COM参照解放の基本パターン
- WordEditor取得失敗時のResult変換基本形

#### Deliverable

Production Architecture上の最小E2E動作経路。

#### Phase Verification

- Excel基準相対PathからOFTを参照できる
- Warm Startでは既存Explorerを利用し、Readiness用の不要な追加Explorerを生成しない
- Cold Startではユーザー事前起動なしでVisible Explorerを起動し、Classic Outlook Readinessを成立できる
- Cold Start時もScan用MailItem自体はDisplayしない
- Cold Start時もDraft増加なし / Inspector残存なしを確認できる
- OFTからMailItemを生成できる
- Display前にInspector / WordEditorを取得できる
- Subjectを取得・変更できる
- BodyTextを取得できる
- Range.Find / Range.TextでBody Variableを置換できる
- Render後にSubject / BodyTextを再取得できる
- Unresolved 0件を判定できる
- 正常時のみClassic OutlookへDisplayできる
- 自動送信されない
- Scan / Error用途のMailItemを保存せずCloseできる基本経路がある

#### Related Test Area

- MTS-TPL-001
- MTS-SCAN-001
- MTS-REN-001 / 002
- MTS-UNR-001
- MTS-MAIL-001 / 002 / 003

#### Exit Criteria

- 本番ArchitectureによるHappy Pathが端から端まで1本通る
- Route WのProduction実装経路が成立する
- Warm / Cold Start双方でClassic Outlook Readiness → WordEditorのProduction経路が成立する
- P2以降が利用できるOFT / WordEditorアクセス基盤がある
- 不完全状態を成功扱いしてDisplayする経路がない
- Blocking Technical Findingがない

P1 Exit Criteriaを満たさない場合、P2以降へ正式進行しない。

---

### 8.3 P2 — Scan / Sync

#### Objective

Template Variable検出とVariableDefinition同期をDesignどおり完成させる。

#### Input

- CP-P0
- CP-P1
- DOC-MVP-DES §14 / §15 / §25.1

#### Implementation Scope

```text
modTemplateScanner
modSyncEngine
modSyncApplication
modVariableDefinitionData
modSettingsData
modOutlookAdapter
```

#### Template Scanner

- `{{...}}` Candidate抽出
- VariableName Syntax Validation
- ValidVariables / InvalidCandidates分離
- Case Insensitive統合
- Subject / Body / Both Location統合
- TemplateScanResult生成
- To / CC / BCCを抽出対象外とする

#### Sync Engine

- New
- Existing
- Reactivated
- Unused
- Rename = Old Unused + New
- TemplateLocation
- FirstDetectedAt
- LastDetectedAt
- SyncTimestamp
- Existingユーザー設定維持
- Sync開始前Error時はVariableDefinitionを更新しない

#### Implementation Detail to Decide

- VBScript.RegExpの生成方式
- Dictionary Key正規化方式
- SyncTimestampの取得・1 Sync内共有方法
- 同期結果UIの基本表示方式
- Unused確認UIへ渡すData形式

#### Deliverables

- 完成版Template Scanner
- Manual Sync処理
- Sync Result

#### Phase Verification

- Valid VariableをSubject / Bodyから抽出できる
- Invalid Candidateを検出できる
- Case違いを同一Variableとして扱える
- LocationをSubject / Body / Bothへ統合できる
- Newを追加できる
- Existingのユーザー設定を維持できる
- 削除VariableをUnused化できる
- Reactivatedを再有効化できる
- Renameを推測せずOld Unused + Newとして扱える
- MetadataがNew / Existing / Reactivated / Unused規則どおり更新される
- OFT不存在 / Invalid Variable時にSync更新されない
- 同期結果を利用者へ通知可能なDataを生成できる

#### Related Test Area

- MTS-TPL-001～004
- MTS-SCAN-001～005
- MTS-SYNC-001～012

#### Exit Criteria

- TemplateScanResultだけで後続処理がVariable集合とInvalid Candidateを判断可能
- Sync差分分類がDesignどおり成立する
- Existingユーザー設定をSyncが破壊しない
- Invalid TemplateからVariableDefinitionを更新できない
- Sync Metadata規則が成立する
- Blocking Sync / Scanner Findingがない

---

### 8.4 P3 — Configuration / UserForm

#### Objective

Current TemplateとExcel Configurationが整合している場合のみ、入力可能なDynamic UserFormを生成し、Workbook Session中のInput Stateを管理する。

#### Input

- CP-P0
- CP-P2
- DOC-MVP-DES §16～18、§25.2

#### Implementation Scope

```text
modConfigurationValidator
frmMailGenerator
modUiController
modVariableDefinitionData
modOptionMasterData
modInputState
modOutlookAdapter
modTemplateScanner
```

#### Configuration Validation

- OFT存在
- InvalidCandidates = 0
- Template / VariableDefinition整合
- Active Variable設定完了
- Type
- DisplayName
- Required
- SortOrder
- Date Format
- Select OptionSource
- Active Option存在
- Template未登録Variable
- Template削除済みActive Variable

#### Dynamic UserForm

- Text → TextBox
- Date → TextBox
- Select → ComboBox
- SortOrder昇順
- 同SortOrder時VariableDefinition行順
- Control.Tag = VariableName
- DisplayName表示
- Required表示
- Description表示
- Select自由入力禁止
- Active Option順表示
- InputValues復元
- 入力クリア

#### Implementation Detail to Decide

- UserForm具体寸法
- Dynamic InputAreaのScroll方式
- Label / Control配置寸法
- Description表示方式
- Select ComboBox Property設定コード
- fmStyleDropDownList相当設定方法
- Unused確認UIの具体方式

#### Deliverables

- Configuration Gate
- Dynamic UserForm
- Input State

#### Phase Verification

- Configuration Error時にUserFormを開かない
- SortOrder未設定をConfiguration Errorとする
- SortOrder同順位でExcel行順を維持する
- Date Format不正を停止する
- Select OptionSource未設定 / Active Optionなしを停止する
- Template未登録Variableを停止する
- Template削除済みActive Variableを停止する
- Typeに対応したControlを生成する
- DisplayName / Required / Descriptionを表示する
- Selectを自由入力不可にする
- OptionMaster Active Optionを定義順で表示する
- InputValuesを再表示時に復元する
- Workbookを閉じるまでInput Stateを保持できる
- ClearでControl / State双方を消去できる
- 実使用Variable数でUserFormが操作可能

#### Related Test Area

- MTS-CFG-001～008
- MTS-UI-001～005
- MTS-INPUT-001 / 002

#### Exit Criteria

- 正しいConfigurationだけがUserFormへ到達する
- 実使用Templateの全Active VariableをUIだけで入力可能
- Select自由入力ができない
- Input StateがDesignどおり保持 / Clearできる
- UIがValidation判定ロジックを持っていない
- Blocking UI / Configuration Findingがない

---

### 8.5 P4 — Validation / Formatting

#### Objective

Raw InputをCurrent Configurationに基づきValidationし、Render可能なFormatted Valueへ変換する。

#### Input

- CP-P3
- DOC-MVP-DES §19～21

#### Implementation Scope

```text
modInputValidator
modValueFormatter
modUiController
frmMailGenerator
modInputState
```

#### Validation

- Required=True未入力
- Required=False空欄
- Date許容4入力形式
- 実在Date判定
- 4桁年必須
- 2桁年拒否
- Select Current Active Option判定
- 複数Error一括返却
- Error Control関連付け
- 再Validation Reset

#### Formatting

- Internal Date Value
- Date Output 6 Format
- 曜日表記
- Text文字列
- Select文字列
- Optional空欄 → `""`

#### Implementation Detail to Decide

- Date Parse具体VBA実装
- 曜日表記生成コード
- Validation強調色
- ErrorAreaレイアウト
- Error Control特定方法
- 再Validation時Reset処理

#### Deliverables

- Input Validation
- Value Formatting
- Validation UI

#### Phase Verification

- Required=True空欄をErrorにできる
- Required=FalseのDate / Select空欄を正常扱いできる
- 許容Date形式を受理できる
- 不正Date / 2桁年を拒否できる
- Current Active Option以外のSelect値を拒否できる
- 複数Errorを一括返却できる
- 全対象Controlを強調できる
- 再Validation時に前回強調状態をResetできる
- Dateを定義済み6形式へFormatできる
- Optional空欄を空文字としてFormatterへ渡せる

#### Related Test Area

- MTS-VAL-001～008
- MTS-REN-003 / 004

#### Exit Criteria

- Input Validatorは判定のみを担当する
- UIはError表示・強調のみを担当する
- Value Formatterは出力文字列化のみを担当する
- Date / Select / Optional空欄のMVP Ruleが成立する
- Blocking Validation / Formatting Findingがない

---

### 8.6 P5 — Full Mail Generation

#### Objective

P1 Walking Skeletonを、Current Data Guardを含む正式なMail生成経路へ拡張する。

#### Input

- CP-P1
- CP-P2
- CP-P3
- CP-P4
- DOC-MVP-DES §22 / §23 / §25.3

#### Implementation Scope

```text
modMailApplication
modVariableDefinitionData
modOptionMasterData
modSettingsData
modInputValidator
modTemplateScanner
modConfigurationValidator
modValueFormatter
modSubjectRenderer
modOutlookAdapter
modUnresolvedChecker
```

#### Formal Sequence

```text
Control → InputValues
↓
Current VariableDefinition / OptionMaster取得
↓
Input Validator
↓
Settings / Current OFT
↓
生成用MailItem
↓
Subject / BodyText取得
↓
Current Template Scan
↓
Configuration Validator
↓
Value Formatter
↓
Subject Renderer
↓
Word Range Body Render
↓
Subject / BodyText再取得
↓
Unresolved Checker
↓
0件のみDisplay
```

#### Production Render Rules

- Subjectは文字列処理
- BodyはInspector.WordEditor + Word Range.Find / Range.Text
- Body全文をPlain Text等で再設定しない
- Case Insensitive
- 全出現箇所を置換
- Optional空欄を空文字置換
- 特殊文字を表示文字列として保持
- Render後にSubject / BodyTextを再取得
- Unresolved Variable 1件以上でDisplayしない
- Unresolved Variable一覧をCase Insensitiveで重複統合
- UserForm起動時のConfiguration Snapshotを生成時に無条件信用しない

#### Implementation Detail to Finalize

- Range.Find全出現検索のRange更新ループ
- 空文字置換時のRange処理
- 特殊文字時のRange.Text処理
- Current Data取得値の同一生成処理内共有
- Subject全置換実装の最終化

#### Deliverable

Production Mail Generation Flow。

#### Phase Verification

- Subject全出現箇所をCase Insensitiveで置換できる
- Body全出現箇所をCase Insensitiveで置換できる
- Optional空欄をSubject / Body双方で空文字化できる
- Date 6 Formatを出力できる
- Body特殊文字を正しく出力できる
- Requirements保証範囲の基本書式を維持できる
- 正常系Unresolved = 0となる
- 未置換Variableを検出し一覧化できる
- UnresolvedありでDisplayしない
- UserForm表示後のOFT削除を検出できる
- UserForm表示後のInvalid Variable追加を検出できる
- UserForm表示後のVariableDefinition変更をCurrent Dataで検出できる

#### Related Test Area

- MTS-REN-001～006
- MTS-UNR-001～004
- MTS-SAFE-001～003
- MTS-MAIL-001

#### Exit Criteria

- 正常なCurrent状態だけがDisplayへ到達する
- Render後Unresolved Checkが独立して成立する
- Current OFT / Configuration Guardが生成直前に成立する
- Route W Production RenderingがRequirements保証範囲で成立する
- Blocking Render / Current Data Findingがない

---

### 8.7 P6 — Error / Safety / Integration

#### Objective

異常系、COM Error、Lifecycle、User Notificationを完成させ、Fail Closedを保証する。

#### Input

- CP-P1～CP-P5
- DOC-MVP-DES §12 / §13 / §24 / RISK-DES-002

#### Implementation Scope

中心Module：

```text
modResult
modMailApplication
modSyncApplication
modOutlookAdapter
modUiController
```

必要に応じて全Module横断でError Pathを統合する。

#### Error / Safety Scope

- OFT不存在
- OFT Open失敗
- Invalid Variable
- Configuration Error
- Input Error
- Outlook Application取得失敗
- MAPI Session取得失敗
- Default Folder取得失敗
- Explorer生成失敗
- Explorer Display失敗
- Classic Outlook Readiness失敗
- WordEditor取得失敗
- Word Range操作失敗
- COM Error
- Unexpected VBA Error
- Render Error
- Unresolved Error
- Error時MailItem非Display
- 保存なしClose
- COM参照解放
- 自動送信防止
- ユーザー理解可能なMessage

#### Implementation Detail to Decide

- VBA例外捕捉の共通パターン
- Error Code体系採否の最終決定
- Word / Outlook COM Release手順
- Outlook Startup / Explorer Initialization Errorの具体的なUser Message変換
- OFT不存在時の具体的な復旧UI
- 同期結果UIの最終形
- 技術例外 → User Message変換規則

#### Deliverables

- Fail Closed Error Paths
- Lifecycle Completion
- User-facing Error Handling

#### Phase Verification

- OFT不存在時にTemplate依存処理を停止する
- OFT Open失敗を理解可能なMessageへ変換する
- Outlook Startup / Explorer Initialization Failureを `OutlookError` へ変換する
- Readiness失敗後にMailItem生成 / Template Scan / Renderへ進まない
- WordEditor取得失敗をResultへ変換する
- Outlook / Word COM ErrorをResultへ変換する
- Error時生成MailItemをDisplayしない
- Error時MailItemを保存せずCloseする
- Scan用MailItemを保存せずCloseする
- 自動送信が発生しない
- Error Messageから問題箇所を利用者が判断可能
- 既知異常経路から不完全MailItemをDisplayできない

#### Related Test Area

- MTS-TPL-003 / 004
- MTS-MAIL-002～004
- MTS-ERR-001 / 002
- MTS-NFR-003 / 004
- Safety Summary対象Test

#### Exit Criteria

- 既知異常経路から不完全MailItemをDisplayできない
- Outlook / Word技術例外がApplication / UIへResultとして伝播する
- MailItem Lifecycleに既知の残存問題がない
- 自動送信経路が存在しない
- Fail Closedが成立する
- Blocking Safety / Lifecycle Findingがない

---

### 8.8 P7 — MVP Test Readiness

#### Objective

正式MVP Testを開始可能なBuildへImplementationを固定する。

P7では新機能を追加しない。

#### Input

- CP-P0～CP-P6
- DOC-MVP-TESTSPEC §22 Entry Criteria

#### Activities

- VBA Project Compile確認
- Module Responsibility Review
- Baseline Conflict確認
- Blocking Implementation Finding確認
- Requirement Gap / Design Gap確認
- Test用Workbook準備確認
- Test用OFT準備確認
- Baseline Test Data再現確認
- Classic Outlook環境確認
- Evidence保存先確認
- Build ID採番
- Commit ID記録
- Environment記録準備
- Test Candidate Build Freeze

#### Test Candidate Build

正式MVP Test候補Buildは以下の形式で識別する。

```text
MVP-B001
MVP-B002
...
```

すべての開発CommitへBuild IDを採番する必要はない。

正式MVP Test候補として固定するBuildに対してのみBuild IDを付与する。

#### Related Review / Test Area

- MTS-NFR-001
- MTS-NFR-002
- MTS-NFR-005
- MTS-NFR-006
- DOC-MVP-TESTSPEC §22 Entry Criteria

正式69 Test CaseはP7完了後にTest Candidate Buildへ対して実施する。

#### Exit Criteria

```text
P0～P6 Exit Criteria = PASS
Blocking Implementation Finding = 0
Blocking Requirement Gap = 0
Blocking Design Gap = 0
Build ID = Assigned
Commit ID = Identifiable
Test Assets = Ready
Classic Outlook = Available
Baseline Test Data = Reproducible
DOC-MVP-TESTSPEC Entry Criteria = Satisfied
```

これをもって、

```text
Implementation Complete
MVP Test Ready
```

とする。

これはMVP Product PASSを意味しない。

MVP Product PASSはDOC-MVP-TESTSPECに基づくFormal MVP Testで判定する。

---

## 9. Implementation Detail Decision Rules

DOC-MVP-DES §29等でImplementation Detailとして残された事項は、以下のPhaseで決定する。

| Implementation Detail | 決定Phase | 備考 |
|---|---|---|
| Result / ErrorInfo構造 | P0 | 必要最小限 |
| Dictionary Early / Late Binding | P0 | 開発環境・配布性を考慮 |
| RegExp生成方式 | P2 | Scanner内へ閉じ込める |
| SyncTimestamp処理 | P2 | 1 Sync内の一貫性確保 |
| 同期結果UI | P2基本形 / P6最終化 | Requirementを増やさない |
| Unused確認UI | P3 | 通常非表示を維持 |
| UserForm寸法 / Scroll | P3 | 実使用Variable数基準 |
| Description表示 | P3 | 利用可能性優先 |
| ComboBox Property | P3 | 自由入力禁止 |
| Date Parse具体実装 | P4 | 4桁年・許容形式を維持 |
| 曜日生成 | P4 | Date Format定義に従う |
| Validation強調色 | P4 | 意味を色だけに依存させない |
| Word Object Model参照方式 | P1 | Route W維持 |
| Range.Find Loop | P1基本形 / P5最終化 | 全出現置換 |
| COM Release | P1基本形 / P6最終化 | Lifecycle優先 |
| WordEditor失敗Error変換 | P1基本形 / P6最終化 | Result Model利用 |
| OFT不存在復旧UI | P6 | Template依存処理停止を維持 |
| Error Code体系 | P6 | 必要性がある場合のみ |
| Module統合 | P3後Review / P7最終判断 | 責務境界維持 |

### Decision Rule

Implementation Detailの判断によって利用者から見た振る舞い、Design責務、Test Expected Resultを変更してはならない。

変更が必要に見える場合はImplementation Detailとして閉じず、Finding Ruleへ従う。

---

## 10. Verification Strategy

### 10.1 Verification階層

```text
Local Verification
↓
Phase Verification
↓
Phase Exit Criteria
↓
P7 Test Candidate Build Freeze
↓
Formal MVP Test
```

### 10.2 Local Verification

意味のあるImplementation Unitごとに、最低限以下を確認する。

- Compile可能
- 対象機能のHappy Path
- 対象機能の代表Error Path
- 既存Phase機能への明らかなRegressionなし

### 10.3 Phase Verification

各Phaseで定義したVerification項目を確認する。

Phase Verification時にMTS-IDと同等のScenarioを確認しても、正式なMVP Test PASS実績には算入しない。

### 10.4 Formal MVP Test

P7で固定したTest Candidate Buildに対し、DOC-MVP-TESTSPECのEntry Criteria成立後、69 Test Caseを正式実施する。

正式Test Resultには、最低限以下を記録する。

```text
Baseline ID
Build ID
Commit ID
Environment
Result
Evidence
Finding
```

---

## 11. Test Specification Mapping

Implementation PlanではTest内容を複製せず、DOC-MVP-TESTSPECのTest ID群へ参照する。

| Implementation Phase | 主なTest Area |
|---|---|
| P0 Foundation | MTS-TPL-001/002、MTS-NFR-002前提 |
| P1 Walking Skeleton | MTS-TPL-001、MTS-SCAN-001、MTS-REN-001/002、MTS-UNR-001、MTS-MAIL-001～003 |
| P2 Scan / Sync | MTS-TPL-001～004、MTS-SCAN-001～005、MTS-SYNC-001～012 |
| P3 Configuration / UserForm | MTS-CFG-001～008、MTS-UI-001～005、MTS-INPUT-001/002 |
| P4 Validation / Formatting | MTS-VAL-001～008、MTS-REN-003/004 |
| P5 Full Mail Generation | MTS-REN-001～006、MTS-UNR-001～004、MTS-SAFE-001～003、MTS-MAIL-001 |
| P6 Error / Safety / Integration | MTS-TPL-003/004、MTS-MAIL-002～004、MTS-ERR-001/002、MTS-NFR-003/004 |
| P7 MVP Test Readiness | MTS-NFR-001/002/005/006実行可能状態、§22 Entry Criteria |

### Technical Spike A Regression

DOC-TS-AでPASSしたTechnical EvidenceもProduction Buildの正式Test代替にはしない。

P7後のMVP Testにおいて、DOC-MVP-TESTSPEC §20のRegression Traceabilityに従い再確認する。

---

## 12. Build / Commit / Checkpoint Strategy

### 12.1 Implementation Unit

基本フロー：

```text
Implementation Unit
↓
Compile
↓
Local Verification
↓
Commit
↓
Phase Verification
↓
Phase Checkpoint
```

### 12.2 Commit

1 Commitは、原則として「意味のある変更単位 + Verification可能な状態」とする。

Phase全体を1つの巨大Commitにまとめる必要はない。

Commit Messageの形式自体は本書で強制しないが、後から変更目的を判別可能な名称とする。

### 12.3 Phase Checkpoint

各Phase完了時に以下のCheckpointを使用する。

```text
CP-P0
CP-P1
CP-P2
CP-P3
CP-P4
CP-P5
CP-P6
CP-P7
```

CheckpointはPhase Exit Criteriaを満たした状態を示す。

### 12.4 Test Candidate Build

Formal MVP Test候補のみ以下のBuild IDを付与する。

```text
MVP-B001
MVP-B002
...
```

Formal Test Resultでは、以下を組み合わせて対象実装を一意化する。

```text
Baseline ID : BL-MVP-003
Build ID    : MVP-Bxxx
Commit ID   : <Git Commit ID>
```

---

## 13. Error / Finding Handling

### 13.1 Implementation Finding Rule

Implementation中にExpectedと異なる事象、曖昧さ、技術問題を発見した場合は、以下の順序で分類する。

```text
Implementation Detail
        ↓ 既存Design内で解決可能
Implementation内で決定

        ↓ Designの意味・責務が不足
Design Finding

        ↓ 利用者から見た新しい振る舞い判断が必要
Requirement Gap

        ↓ 既存Technical Decisionの成立性に新しい重大不確実性
Technical Spike再判定
```

### 13.2 Implementation Detail

以下を満たす場合のみImplementation内で決定してよい。

- Requirementを変えない
- Design Decisionを変えない
- Test Expected Resultを変えない
- Baselineを変更する必要がない

### 13.3 Design Finding

Requirementは明確だが、Design責務・Sequence・Data Model等が不足または矛盾している場合はDesign Findingとする。

Implementation側で推測補完して継続しない。

### 13.4 Requirement Gap

利用者から見た振る舞いを新しく決める必要がある場合はRequirement Gapとする。

Implementation都合だけでRequirementを変更しない。

### 13.5 Technical Spike再判定

以下をすべて満たす場合のみ新しいTechnical Spike候補とする。

- 技術成立性自体が未確定
- 既存Design Decisionが成立しない可能性がある
- 通常Implementation + Verificationまで待つと大規模手戻りになる
- 独立したTechnical Question / Hypothesis / Evidence / Decisionを定義可能

### 13.6 Baseline変更

Requirement Gap / Design Gap解消等でBaseline変更が必要となった場合、Current Execution Baselineを直接書き換えない。

新Revision / Consistency Review / Baseline Approvalの正式手順へ戻る。

---

## 14. Implementation Entry / Exit Criteria

### 14.1 Implementation Entry Criteria

Implementation開始条件：

- BL-MVP-003がApproved
- DOC-MVP-REQがApproved
- DOC-MVP-DESがApproved
- DOC-TS-AがCLOSED / PASS
- DOC-MVP-TESTSPECがApproved
- Technical Spike B / CがNOT REQUIRED
- 本Implementation PlanがApproved
- VBA開発環境を利用可能
- Classic Outlookを利用可能
- Baseline文書へアクセス可能

### 14.2 Phase Entry Criteria

各Phase開始時は、依存PhaseのCheckpointが成立していることを確認する。

### 14.3 Implementation Exit Criteria

Implementation完了条件：

1. P0～P7のExit Criteriaをすべて満たす
2. CP-P0～CP-P7が成立する
3. Blocking Implementation Findingが0件
4. Blocking Requirement Gapが0件
5. Blocking Design Gapが0件
6. Test Candidate BuildをBuild IDで識別可能
7. Commit IDを識別可能
8. Test用Workbook / OFTを準備済み
9. Baseline Test Dataを再現可能
10. Classic Outlook Test環境を利用可能
11. Evidence保存方法を準備済み
12. DOC-MVP-TESTSPEC §22 Entry Criteriaを満たす

---

## 15. Completion Definition

### 15.1 Implementation Complete

以下を満たした状態をImplementation Completeとする。

```text
P0～P7 Exit Criteria = PASS
CP-P0～CP-P7 = Established
Blocking Implementation Finding = 0
Blocking Requirement Gap = 0
Blocking Design Gap = 0
Test Candidate Build = Identified
DOC-MVP-TESTSPEC Entry Criteria = Satisfied
```

### 15.2 MVP Test Ready

Implementation CompleteかつFormal Test用Asset / Environmentが利用可能な状態をMVP Test Readyとする。

### 15.3 MVP Completeとの区別

Implementation Complete / MVP Test Readyは、MVP Product PASSを意味しない。

MVP Complete / Product PASSは、DOC-MVP-TESTSPECによるFormal MVP Testで以下を確認した後に判定する。

- Mandatory TestにFAIL / BLOCKEDが残っていない
- 適用対象Mandatory TestがPASSまたは正当なN/A
- AC-001～020 PASS
- NFR-001～006 PASS
- Safety Summary Gate PASS
- Technical Spike A Regression PASS
- Blocking Requirement / Design Gap未解決なし

Formal Product GateはDOC-MVP-TESTSPECをSource of Truthとする。

---

# Appendix A. Implementation Phase Flow

```text
BL-MVP-003
    ↓
P0 Foundation
    ↓ CP-P0
P1 Walking Skeleton
    ↓ CP-P1
P2 Scan / Sync
    ↓ CP-P2
P3 Configuration / UserForm
    ↓ CP-P3
P4 Validation / Formatting
    ↓ CP-P4
P5 Full Mail Generation
    ↓ CP-P5
P6 Error / Safety / Integration
    ↓ CP-P6
P7 MVP Test Readiness
    ↓ CP-P7
MVP-Bxxx Freeze
    ↓
DOC-MVP-TESTSPEC Formal MVP Test
    ↓
MVP Test Gate
```

---

# Appendix B. Implementation Finding Flow

```text
Finding
  │
  ├─ Existing Design内の実装選択か？
  │      └─ Yes → Implementation Detailとして決定
  │
  └─ No
        │
        ├─ Requirementは明確だがDesign不足か？
        │      └─ Yes → Design Finding
        │
        └─ No
              │
              ├─ 利用者振る舞いの新判断が必要か？
              │      └─ Yes → Requirement Gap
              │
              └─ Technical Decision成立性の重大不確実性か？
                     └─ Yes → Technical Spike要否再判定
```

---

# Appendix C. Plan Governance

本Implementation PlanはProject進捗実績を管理しない。

以下はProject Overview / Context Handoff / Test Result等で管理する。

- 現在実装中のPhase
- 完了済みPhase
- 現在のNext Action
- 実装進捗率
- Test実施結果
- PASS / FAIL実績
- 日々の作業記録

本書は実装計画自体が変更された場合のみRevisionを更新する。

単にP0 → P1へ進んだことを理由に本書をVersion Upしない。
