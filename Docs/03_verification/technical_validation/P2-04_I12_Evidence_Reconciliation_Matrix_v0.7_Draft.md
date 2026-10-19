# P2-04 I12 Evidence照合マトリクス v0.7 — Draft

## 1. 今回の変更点（2026-10-19）

- I12 Direct Rerun vs Evidence Reuse：後続Planを採用する方針をユーザーが**明示承認**（Decision v0.2 Accepted）。
- Compile：ユーザー申告`2026-10-10 PASS`を歴史的記録として反映。`2026-10-18 compile`へ置換しない。
- MailTemplate.oft：元に戻したとユーザー申告。P2-04 I03 Raw内の復元行欠落はそのまま残す。
- Settings.TemplatePath：意図した値とのユーザー申告を追加。ログ内のI04ケース単体での復元とは別証拠。
- P2-02/03：それぞれClosure Review v0.2 Candidateに更新。**技術PASS / Closure推奨、正式Repo RecordはDRAFT**を維持。

## 2. Traceability Matrix

| Item | Execution / Evidence | Provenance / Disposition | Status |
|---|---|---|---|
| P2-01 Core/OFT/Recipient | 既存Regression Record v0.1、Core 11/11、Integration PASS | BL003歴史的Record／Scanner現9モジュール共通使用を申告 | **HISTORICAL PASS/CLOSED / REUSE ACCEPTED** |
| P2-02 6 Suite | `261018_P2-02_Regression Log.txt`、111/111 PASS、SHA `b91f028b4679dc9…` | v0.1.3＋9 Source共通申告、BL004 Approval確認 | **TECHNICAL PASS / CLOSURE RECOMMENDED** |
| P2-03 5 Suite | `261018_P2-03_Regression Log.txt`、46/46 PASS、SHA `f0253df8e7e77a0…` | v0.1.2＋9 Source共通申告、復元5回のログ | **TECHNICAL PASS / CLOSURE RECOMMENDED** |
| P2-02→P2-03 BOOT | 2026-10-18 P2-04 Raw 29/29 PASS | 今回Cycle、新規 | **PASS** |
| P2-04 I03–I11 | 2026-10-18 P2-04 Raw 153/153 PASS（I10 first ABORTは別記録） | 今回Cycle、新規 | **PASS** |
| I01 / I02 | 旧P2-04 Completion I01/I02 PASS（旧Revision表示あり） | **HISTORICAL SUPPORT ONLY**。今回の新規Test Countに含めない | **REUSE AS SUPPORT** |
| I12実行方針 | `P2-04_I12_Execution_Policy_Alignment_Decision_v0.2_Accepted.md` | ユーザー承認、後続PlanのReuse方式適用 | **ACCEPTED** |
| I12 Compile | `2026-10-10 Debug > Compile PASS`（実行者申告） | 当時のCompile履歴、当日最終Build Compileではない | **HISTORICAL PASS / LIMITED** |
| I12 OFT restore | MailTemplate.oftは戻した（実行者申告） | I03 Raw内に復元出力なし | **USER-ATTESTED** |
| I12 Settings state | TemplatePathは意図した値（実行者申告） | 最終セル値は未提供 | **USER-ATTESTED** |
| I12 Final Technical Review | 合格根拠は該当Contractの履歴／今回実行と9 Source Match | 新Blocking Production Regressionの証拠なし | **TECHNICAL PASS** |
| I12 Formal Closure | Decision／Log RegistryのSoT適用なし | 正式Archiveと既存Record改訂未実施 | **PENDING DOCUMENTARY ACTIONS** |

**注意**：`111+46+182`を一つのBuildで339件新規実行したと記載しない。P2-02末尾Bootstrap33再掲も111件とは別の追加Assertionに数えない。

## 3. Source and Build Scope

- 9 Production Modules：提供ZIPとGitHub Versioned Source 9/9 Normalized Match。
- すべてのRegressionで同じ9モジュールを使用したと実行者が申告。
- 今回のWorkbook SHA-256：`0A4B1392D66FB22630FEFD4DBB6D3E78C265B5404A66FB009D934F0866AD2AE9`（ユーザー申告、Workbook bytes未取得）。過去WorkbookのSHAとはみなさない。
- 2026-10-10 Compile PASS：**その時点のCompile結果**。Regression後にソース／Workbook保存なしという申告は2026-10-18以降を説明するもので、10月10日からの全VBAProject変更なしを証明しない。

## 4. Findings / Boundaries

- WordEditor `OBS-P2-05-002`：**OPEN / NON-BLOCKING**。原因不明は維持。
- I10初回ABORT：同VBA SessionのBaseline未準備。後続準備→20/20 PASS。Production Failureと見做さない。
- I07 Runtime 1004：Expected guarded failure、I08 Retry PASS。Rollback/Atomicity保証なし。
- I06 Preflight Headerの`I05`誤記：NON-BLOCKING TEST ARTIFACT。
- I03 OFT戻し・Settings最終状態：実行者自己申告を保存し、ログ原文の欠落を捏造しない。
- Active/Blocking Finding 0をProject全体として無条件に認定しない。

## 5. 次の管理アクション

1. Raw 3ログ・ZIP Export・Source照合／Closure Review／I12 Decisionを正式管理場所に登録。原文ログにはWindows個人ユーザーパスがあるためアクセス範囲を制限。
2. GitHubのP2-02／P2-03独立Regression RecordにEvidence登録、Source申告、Compile限定、正式Dispositionを反映し、所定承認後に`PASS/CLOSED`へ変更。
3. I12 Final Quality Gate Reviewの正式Document Revision／承認とProject Controlへ反映（本会話では既存Repo状態未変更）。
4. P2-05別Gateで最終VBA Compile、Static Review S01–S32、Production Patch Review、Final Finding Assessmentを実施し、P2-05 Completionを判断。

## まとめ / Summary

**日本語**：ユーザー回答によりI12手順方針と最終Fixture状態の保留は解消。Compileは10/10の履歴PASSとして採用。I12技術審査PASS、正式ClosureはEvidenceの正式登録・Record改訂待ち。

**English**: The I12 procedure decision is accepted and fixture status attested. Compile is historical (Oct 10). Technical review passes; formal closure awaits authoritative evidence registration.
