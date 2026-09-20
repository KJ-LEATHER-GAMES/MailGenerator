# Baseline 4文書 Migration QA Correction Patch v0.1

## 1. Patch情報

| 項目 | 内容 |
|---|---|
| Patch名 | Baseline 4文書 Migration QA Correction Patch |
| バージョン | v0.1 |
| 対象 | Migration QAで検出したGovernance 3件 + Consistency Clarification 1件 |
| 変更分類 | Editorial / Governance Correction + Consistency Clarification |
| Semantic Change | None |
| Requirement追加・削除 | なし |
| Design Decision変更 | なし |
| Technical Decision変更 | なし |
| Test Definition変更 | なし |

---

## 2. 対象文書と更新Version

| Document ID | Before | After |
|---|---|---|
| DOC-MVP-REQ | MVP Requirements v0.1.7 | MVP Requirements v0.1.8 |
| DOC-MVP-DES | MVP Design v0.1.6 | MVP Design v0.1.7 |
| DOC-TS-A | Technical Spike A v0.3 CLOSED | Technical Spike A v0.4 CLOSED |
| DOC-MVP-TESTSPEC | MVP Test Specification v0.1.2 | MVP Test Specification v0.1.3 |

---

# 3. COR-001 Requirements入力保持表現

## Finding

FR-INPUT-001は以下を定義している。

```text
UserFormで入力した値は、Excelファイルを閉じるまで保持する。
```

Design / Test Specificationは `Workbookを閉じるまで` で一致している一方、Requirements §33 Requirements決定サマリーのみ以下となっていた。

```text
入力値保持 | Excel終了まで
```

## Correction

Requirements §33のみ以下へ変更する。

```text
入力値保持 | Workbookを閉じるまで
```

## Classification

Consistency Clarification

## Impact

- FR-INPUT-001本文：変更なし
- Acceptance Criteria：変更なし
- NFR：変更なし
- 利用者向け挙動：変更なし
- Semantic Change：なし

---

# 4. COR-002 Design Technical Evidence参照

## Finding

ActiveなDesign本文に以下のVersion固定参照が残存していた。

```text
Technical Spike A v0.2の結果、Route W：WordEditorを採用する。
```

```text
Technical Spike A v0.2で本リスクの実発生を確認した。
```

## Correction

以下へ変更する。

```text
DOC-TS-AのTechnical Decisionに基づき、Route W：WordEditorを採用する。
```

```text
DOC-TS-Aで本リスクの実発生を確認した。
```

過去の改訂履歴に含まれるVersion固定参照はHistorical Recordとして維持する。

## Classification

Editorial / Governance Correction

## Impact

- Route W：変更なし
- D16 Design Decision：変更なし
- RISK-DES-001判定：変更なし
- Semantic Change：なし

---

# 5. COR-003 Technical Spike A §8環境メタデータ

## Finding

§8に以下のCurrent / Future Actionが残存していた。

```text
OS / Excel / Outlookの詳細バージョン等は後日確認し、本節へ追記する。
```

実績記入欄にも `後日確認` が残存していた。

## Correction

Current / Future Actionを削除し、Close時点のHistorical Factへ変更する。

```text
Close時点でOS / Excel / Outlookの詳細バージョン等の一部環境メタデータは未記録であった。
```

未記録項目は以下の表記とする。

```text
Close時点未記録
```

## Classification

Editorial / Governance Correction

## Impact

- Technical Test Result：変更なし
- Evidence：変更なし
- Finding：変更なし
- Route W：変更なし
- PASS / CLOSED：変更なし
- Semantic Change：なし

---

# 6. COR-004 Test Specification §7 Test環境

## Finding

Test Specification §7にActual Environmentの記入欄と `後日確認` が残存していた。

これはTest SpecificationとTest Resultの責務分離に反する。

## Correction

Test Specificationでは、Test Resultへ記録すべきEnvironment項目のみを定義する。

```text
Test実行時は、Test Resultへ以下のEnvironment情報を記録する。
```

各項目は `必須` とし、実際の値はTest Resultへ保持する。

## Classification

Editorial / Governance Correction

## Impact

- Test Case：変更なし
- Expected Result：変更なし
- Test Gate：変更なし
- Traceability：変更なし
- Semantic Change：なし

---

# 7. Correction Gate

以下をすべて満たすことをPASS条件とする。

- [x] Requirements §33入力保持表現がFR-INPUT-001 / Design / Testと整合
- [x] Design Active Bodyに `Technical Spike A v0.2` 固定参照なし
- [x] Technical Spike A §8にCurrent / Future Actionなし
- [x] Test Specification §7にActual Environment値・`後日確認`なし
- [x] FR件数変更なし
- [x] AC件数変更なし
- [x] NFR件数変更なし
- [x] Route W変更なし
- [x] PASS / CLOSED変更なし
- [x] Test Case件数変更なし
- [x] Test Expected変更なし
- [x] Test Gate変更なし

**Correction Gate：PASS**
