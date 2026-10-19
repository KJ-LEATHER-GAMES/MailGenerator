# P2-04 I12 Historical Regression Evidence Applicability Assessment v0.1 — Draft

## 1. 目的と今回の裁定範囲

- 評価日：2026-10-19
- 対象：P2-01／P2-02／P2-03の既存回帰証拠を、2026-10-18にP2-04回帰を実施したSource構成へ適用できるか。
- 既存実行結果の再実行ではなく、**Evidence Applicability Assessment**。
- ユーザー申告：「すべて少し前に提供したProductionSource9モジュールで実行したことは間違いありません。」
- GitHub参照：`KJ-LEATHER-GAMES/MailGenerator` のcommit `edf5c5175b103e250144341071d885a3a992c65f`。
- `P2-04_Regression_Build_Provenance_Verification_v0.2_Draft.md`で**9/9 Normalized Source Match**。今回この成果をv0.3に引き継ぐ。

### 判定用の区別

- **RUN PASS**：ユーザー提供実行ログに記録されたテスト結果。
- **SOURCE ATTESTED**：実行者がProduction 9モジュールは共通と明示したこと。
- **REUSE ACCEPTABLE**：対象Contract・Source差分を踏まえ、新たな一括再実行を要求せず既存ログを利用可能とする技術的な評価。
- **CLOSED**：原RecordのQuality Gateが正式に確定した状態。上記とは別。
- **INDEPENDENT BINARY VERIFICATION**：過去Workbook現物や当時のfingerprintによる証明。本資料では未実施。

## 2. Evidence別評価

| Unit / Scope | 実行Evidenceと履歴 | Source／Baseline境界 | Applicability Decision |
|---|---|---|---|
| P2-01 Scanner | 既存Regression Record v0.1 `PASS/CLOSED`。Core 11/11 PASS、OFT／Recipient Integrationは初回WordEditor Read失敗の後Fresh WarmでPASS | `modTemplateScanner`がGitHub P2-01 v0.1.1と一致。実行者は同一9Sourceと申告。既存RecordはBL-MVP-003の歴史的記録 | **REUSE ACCEPTABLE（Scanner Contract限定）**。BL-MVP-004のMetadata Bootstrap変更をP2-01の新しい実行結果と誤認しない |
| P2-02 Sync Diff | 6 Suite `33 + 43 + 9 + 18 + 6 + 2 = 111/111 PASS`。追加Bootstrap33件は原文再掲のため重複加算しない | `modSyncEngine` v0.1.3とZIP一致。実行者が同一9Sourceを確認。ログにBL-MVP-004表示あり | **REUSE ACCEPTABLE**（Source Revision／Contractについて）。独立Recordは**DRAFT／CLOSURE PENDING**のまま |
| P2-03 Persistence | 5 Suite `7 + 6 + 12 + 18 + 3 = 46/46 PASS`。各Suite復元メッセージあり | `modVariableDefinitionData` v0.1.2とZIP一致。実行者が同一9Sourceを確認。BL-MVP-004 Detection History含む | **REUSE ACCEPTABLE**（Source Revision／Contractについて）。独立Recordは**DRAFT／CLOSURE PENDING**のまま |
| P2-02→P2-03 Bootstrap | 2026-10-18 P2-04 29/29 PASS | 現行9Sourceと直接関連付けられた原文ログ | **CURRENT-CYCLE VERIFIED TEXT** |
| P2-04 I03–I11 | 153/153 PASS、I10初回ABORT→Prepare→PASSを記録 | 同上 | **CURRENT-CYCLE VERIFIED TEXT** |
| P2-04 I01/I02 | 歴史的Completion Recordで両方PASS。今回は個別Harnessの新規実行なし | Source9件共通の実行者申告と今回のBootstrap／Lifecycle／Manual Only Evidenceが補強 | **HISTORICAL EVIDENCE REUSABLE AS SUPPORT**。今回のI01/I02を新規PASSとして二重計上しない |

### 技術評価

- **P2-01**：既存BL-MVP-003のScanner Recordを歴史的結果として維持。BL-MVP-004の主要な変更はSync Metadata Bootstrap／Detection Historyであり、Scannerへ新しい期待値を無断で割当てない。Scanner同一Sourceを実行者が確認し、P2-04 I03（invalid candidate）、I05/I06（normal Scanner path）、I09/I10（OFT/Outlook Lifecycle）で現在の統合経路を補強している。
- **P2-02/P2-03**：それぞれBL-MVP-004で重要なBootstrap／Detection Historyのケースを既存原文が含み、対象Versioned Sourceと実行者申告が一致。**過去実行WorkbookのSHAが未記録でも、Source Contractの適用評価には必ずしも追加の全件再テストを要しない。** ただしWorkbook全体の同一性は未証明。
- **I01/I02**：別CycleのImplementation Completion Recordであるため、2026-10-18の新規回帰Assertionsへ足さない。P2-04 Happy PathとCommon SyncTimestampの傍証として参照可能。

## 3. 観測／Findingの継続条件

| 事項 | Evidence | 扱い |
|---|---|---|
| WordEditor一時失敗 (`OBS-P2-05-002`) | P2-01初回Integration `ReadBodyText` FAIL、Fresh Warm後PASS。P2-04 I09/I10 PASS | **OPEN / NON-BLOCKING**のまま。根本原因解消を宣言しない |
| I10 first ABORT | 2026-10-18 P2-04 Raw Logに明記。Prerequisite未達のためProduction path未実行 | 記録を残す。最終20/20 PASSへ上書きせず並記 |
| I07 persistence failure | 保護シートでError→I08 Fresh Retry成功、37/37 | 今回のBefore/After一致をRollback・Atomicity保証にしない |
| Fixture restore | P2-03各Suiteに復元報告、P2-04に個別Before/After／保護状態復元 | サブセットの表示一致。書式・数式・全関連Fixtureを網羅した証明ではない |
| Compile | P2-02原Recordに2026-10-10 preflight user-reported PASS | **2026-10-18実機Compile PASSへ自動転用しない** |

## 4. 正式Closureの要件と非要件

**本Reviewで技術的に完了したこと**：9 Production Modulesの共通Revisionに関する実行者証言を受領し、既存GitHub Sourceとの9/9照合および157件のRaw Logに接続。**P2-01/02/03の既存Evidenceを現行Source Contractに再利用してよいという技術的判断を成立**させた。

**Closure前に残る管理項目**：

1. P2-02／P2-03独立Regression Recordへの本Attestation・Raw Evidence Hash・適用判断の正式参照と、各Recordの`DRAFT → PASS/CLOSED`審査。
2. Project `Evidence/`保管場所・参照の確定（生ログにローカル個人Pathがあるため公開範囲を確認）。GitHubへのPush自体はEvidence評価の技術的前提ではない。
3. 旧`P2-04_I12_Contract_Regression_Guide_v0.1`の**直接再実行**と、後続`P2-04 Manual Sync Integration Regression 実施計画 v0.1`の**既存Evidence再利用**との優先関係を実施計画/Revisionで明示。現在は後続の計画に従った再利用評価を行っている。
4. I01/I02の歴史的Evidenceへの正確なReferenceと、P2-04今回CycleのFinding Assessment（Blocking Findingの有無）を明記。
5. 実行時BuildのWorkbook SHA-256 `0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9` は今回実行に対する**ユーザー申告**。別の日付に行われた過去Regressionすべてへ同一SHAを自動付与しない。

### 判定案

```text
P2-01 Historical Regression Reuse: ACCEPTABLE FOR SCANNER CONTRACT
P2-02 Historical Regression Reuse: ACCEPTABLE FOR SYNC DIFF CONTRACT
P2-03 Historical Regression Reuse: ACCEPTABLE FOR PERSISTENCE CONTRACT
I01/I02 Historical Evidence Reuse: ACCEPTABLE AS SUPPORTING EVIDENCE
No mandatory blanket retest identified from Source comparison.
I12 Final Closure: PENDING (documentary gates and final finding assessment)
P2-05 Completion: NOT CLAIMED
CP-P2: NOT ESTABLISHED BY THIS ASSESSMENT
```

正式DecisionはRecordの権限／レビュープロセスに従う。本Draft単独で既存Approved/Closed statusを変更しない。

## まとめ / Summary

**日本語：** 全回帰でProduction Source 9件が同一という実行者申告により、過去BuildのSource Revision不明という保留を実務上解消できる。P2-01/02/03の歴史的Regression Evidenceは各Contractに限定して技術的に再利用可能と評価。個別RecordのClosureとI12最終判定は別管理。

**English:** The operator attests that the same nine production modules were used in prior and current regressions. Source-based evidence reuse is technically acceptable for P2-01/02/03 contracts. Historical record closure and final I12 approval remain separate review gates.
