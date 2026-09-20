# Technical Spike B / C 要否判定 v0.1

## 1. 判定情報

| 項目 | 内容 |
|---|---|
| 対象プロジェクト | 定型メール作成ツール |
| 判定基準Baseline | BL-MVP-001 |
| 判定対象 | Technical Spike B / Technical Spike C |
| 判定 | **Both Not Required** |
| 判定種別 | Implementation Entry Decision |
| 判定日 | 2026-09-12 |

---

## 2. 結論

**Technical Spike B：Not Required**  
**Technical Spike C：Not Required**

BL-MVP-001には、Implementation開始前に独立したTechnical Spikeとして成立性Evidenceを追加取得しなければならないBlocking Technical Questionは残っていない。

したがって、次工程は **Implementation Plan v0.1 の構成設計** とする。

---

## 3. 判定基準

追加Technical SpikeをRequiredとするのは、原則として以下を満たす場合とする。

1. 未解決のTechnical Questionが存在する
2. その結果によってBL-MVP-001のArchitecture / Design Decisionが成立しなくなる可能性がある
3. Implementationへ進んでから判明すると大きな手戻りとなる
4. 通常のImplementation Checkpoint / Mandatory Testだけでは十分に早く・安価に確認できない
5. 独立したHypothesis / Validation Method / Evidence / Decisionを持つ価値がある

この基準に該当しないImplementation Detailや通常の実装リスクは、Technical Spikeへ昇格させない。

---

## 4. Candidate Risk評価

### 4.1 Outlook / Word COM

関連：RISK-DES-002

Technical Spike Aで以下は成立確認済み。

- Display前WordEditor取得
- Scan用MailItemの保存なしClose
- Draft残存なし
- Inspector残存なし
- Route W / WordEditor採用成立性

残る論点は、Object取得失敗、Range操作失敗、COM参照解放失敗等を本番実装でError / Result Modelへ変換することである。

これは技術方式選定を左右する未解決Questionではなく、Implementation責務である。

Test SpecificationにはOutlook / Word COM Error変換のMandatory Testが定義されている。

**判定：Spike不要。Implementation + Testで扱う。**

---

### 4.2 動的UserForm

関連：RISK-DES-003

残る論点は、実使用Variable数に対して縦方向レイアウト・スクロールを含むUserForm利用性が成立するかである。

Designでは具体的Form寸法・スクロール方式をImplementation Detailとしており、利用者Requirementとして固定していない。

Test Specificationには、実使用Variable数で全入力項目・主要操作へアクセス可能かを確認するMandatory Testが定義されている。

したがって、独立Spikeで先に技術成立性を確認する必要はない。

**判定：Spike不要。Implementation + MTS-UI-005で扱う。**

---

### 4.3 Dictionary / RegExp / Binding方式

対象例：

- Scripting.DictionaryのEarly / Late Binding
- VBScript.RegExp生成方式
- Word Object Model参照設定 / Late Binding

これらはDesign上、Requirements変更を伴わないImplementation Detailとして明示されている。

方式選択がMVP Architectureそのものを左右するものではなく、Implementation Plan内で実装方針を確定可能である。

**判定：Spike不要。**

---

### 4.4 Word Range.Find / COM解放の具体実装

Technical Spike AでRoute W / WordEditor / Range.Find / Range.Textの成立性は確認済み。

残っているのは、

- Range更新ループ
- COM参照解放コード
- WordEditor取得失敗時のError変換

等の本番実装詳細である。

これらはWalking Skeleton / Outlook Adapter実装時に早期確認でき、必要なRegression / Error TestもTest Specificationに存在する。

**判定：Spike不要。**

---

### 4.5 Technical Spike A Scope外項目

Technical Spike AでScope外だった以下についても確認した。

- UserForm
- Excel Tables / Data Access
- Configuration Validation
- Sync Engine
- Date Formatter
- Select OptionSource
- Error Code体系
- Module / Class構成
- 本番COM解放コード

これらはSpike Aが「未検証だった」という理由だけで新しいSpike対象にはしない。

BL-MVP-001ではRequirements / Design / Test Specificationで責務・期待結果・検証経路が定義されており、Implementation中に段階的に確認可能である。

---

## 5. Spike B判定

### Decision

**Not Required**

### Rationale

Technical Spike Bとして独立させるべき具体的Technical QuestionがBL-MVP-001上に定義されていない。

最も近いCandidateであるOutlook / Word COMについても、WordEditor採用自体はBlocking Riskではなく、残件は本番実装時のError Handling / Resource Handlingである。

---

## 6. Spike C判定

### Decision

**Not Required**

### Rationale

Technical Spike Cとして独立させるべき具体的Technical QuestionがBL-MVP-001上に定義されていない。

最も近いCandidateであるDynamic UserFormについても、実使用Variable数での利用性をImplementation後のMandatory Testで直接確認可能であり、先行Spikeの費用対効果が低い。

---

## 7. Implementation Entryへの影響

追加Technical SpikeはImplementation Plan開始条件としない。

次工程：

```text
BL-MVP-001
    ↓
Technical Spike B : Not Required
Technical Spike C : Not Required
    ↓
Implementation Plan v0.1 構成設計
    ↓
Implementation Plan v0.1
    ↓
VBA Implementation
    ↓
MVP Test
```

---

## 8. 再判定トリガ

今回のNot Required判定は、「今後Technical Spikeを禁止する」という意味ではない。

Implementation Planまたは実装中に以下が発生した場合のみ、新規Technical Spikeを起票する。

- Baseline Design Decisionの成立性を疑う新しいTechnical Question
- 実装を進める前に独立検証しないと高確率で大規模手戻りになる不確実性
- Existing Testでは十分に早く確認できないPlatform / API制約
- WordEditor / Outlook / Excel環境差によりArchitecture変更の可能性が生じた場合
- Requirement GapではなくTechnical Feasibilityの問題であることが明確な場合

その際は「B」「C」という予約名を機械的に使わず、Technical Questionを明示して新規Spikeとして管理する。

---

## 9. Formal Decision

```text
Baseline              : BL-MVP-001
Technical Spike B     : NOT REQUIRED
Technical Spike C     : NOT REQUIRED
Blocking Tech Question: NONE
Implementation Entry  : ALLOWED
Next Action           : Implementation Plan v0.1 構成設計
```
