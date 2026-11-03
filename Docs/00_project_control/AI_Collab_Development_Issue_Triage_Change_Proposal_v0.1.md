# AI協働開発 運用ルール改訂提案 v0.1

## 提案テーマ

新規課題発見時の「今対応／後回し／対象外」判断と、主目的への復帰条件の明確化

## 依頼

「AI協働開発の関連ドキュメント整備」プロジェクトの、**現行Approved版**の共通運用プロセスおよび関連ルールを確認し、次の考え方を最小限の改訂で導入する案を検討してください。これは改訂提案であり、まだ承認済みの運用ルールではありません。

### 1. 背景・問題

定型メール作成ツールのP2完了作業で、Regression Evidenceの正式保全を確認する過程から、保存先の権限、バックアップ媒体、暗号化、復元試験などへ作業が拡張した。個々の論点には合理性がある一方、派生課題をすべて即時解決しようとすると、本来の「P2を完了し、P3の実装へ進む」という目的が後退する。

これを個人の注意力に任せず、AI協働開発の共通運用ルールとして防ぎたい。ただし、セキュリティ事故・データ損失・正式Gateの未充足など、本当に停止すべき問題を安易に先送りしない。

### 2. 追加したい基本原則

> 新しい課題・改善案・リスクを発見しても、発見したという理由だけで現在の作業範囲を拡張しない。まず現在の目的、Done When、Phase Exit Criteria、承認済みBaselineへの影響を確認し、「今対応」「後回し」「対象外」に分類する。AIは判断と理由、後回しにする場合の再評価条件を提示し、必要なユーザー判断を得る。現在の作業へ戻る条件を明示する。

### 3. 提案する判断手順

1. **現在の主目的を再確認**：Current Objective / Done When / Phase Exit Criteria / 次の正式Gateを1〜2行で再提示する。
2. **課題の影響を評価**：既存Requirement・Design・Test・承認条件、セキュリティ、データ保全、再現性、ユーザーへの影響、対応せずに進むリスクを確認する。事実・仮説・未確認を区別する。
3. **3分類する**：
   - **NOW（今対応）**：現在のGateを阻害する、重大な安全・セキュリティ・データ損失リスクがある、または後回しにすると不可逆な損害・大きな手戻りが生じる。作業を止め、必要最小限の対策を実施する。
   - **DEFER（後回し）**：有用だが現Gateの必須条件ではなく、残留リスクを説明・必要に応じて受容した上で作業を継続できる。既存のProject Overview / Context Handoff等へ最小限記録し、再評価トリガーを指定する。
   - **OUT OF SCOPE（対象外）**：MVP・現プロジェクトの目的に寄与しない、または費用対効果が低い。理由を簡潔に示して原則実施しない。必要以上にBacklogを増やさない。
4. **スコープ変更を制御**：NOWでも対処範囲はGate通過に必要な最小限に限定する。新しい文書、技術検証、プロセス追加、Baseline変更は自動的に提案・実行しない。影響評価と必要な承認を行う。
5. **作業復帰点を明示**：「この課題のDone When」「保留できる残余事項」「終了後に戻る元の作業」を明示し、派生課題の連鎖を止める。

### 4. 判断結果の最小記録

既存の管理先に、必要な場合のみ以下を記録する。新たなIssue台帳や承認文書を標準必須としない。

| 項目 | 内容 |
|---|---|
| Issue | 新規課題の要点 |
| Relation to current goal | 現在の目的・Gateとの関係 |
| Assessment | NOW / DEFER / OUT OF SCOPE |
| Reason / Risk | 判断理由、後回し時の残留リスク |
| Revisit trigger | 再評価条件（DEFER時） |
| Return point | 元の作業へ戻る条件・次アクション |
| Approval | 必要な場合のユーザー判断・受容 |

詳細な判断履歴が必要な場合のみ既存のDecision Log等で記録し、同じ情報の多重管理を避ける。

### 5. AIの応答例

> 新規課題：バックアップ媒体の定期自動検証。判定：DEFER。理由：今回のP2 Evidence保全Gateでは、初回のコピー・SHA照合・復元確認までで必要条件を満たせるため。再評価条件：運用中に更新頻度・障害リスクが増大した場合。今回は現行のS1完了条件を満たした時点でS2へ戻る。

※現Gateの必須条件や重大な安全リスクが確認された場合はNOWへ変更する。例は一般化した判断形式であり、個別の承認済み仕様に優先しない。

### 6. 既存ルールとの整合に関する希望

- **YAGNI**、文書管理コストの最小化、Requirements / Design / Test / Project Control / Handoff / Decision Logの責務分離を維持する。
- Requirement Gap / Design Finding / Implementation Finding / Blocking Finding / Semantic Changeといった既存の分類・承認・Quality Gateを置き換えず、**新規課題に対する着手優先度とスコープ制御**として追加する。
- NOW / DEFER / OUT OF SCOPEは**作業優先度の分類**とし、既存Finding StatusやDocument Status、Baseline Statusと混同しない。
- 承認済みGateを省略したり、証拠不足のままPASS / CLOSEDに変更したりするためには使わない。
- 変更先は、まず共通の**基本運用プロセス**を候補とし、必要なら**文書管理・Baseline運用ルール**のAI行動原則、**Context Handoff**のOpen Items / Next Actionへ最小限の反映を検討する。
- 既存Approved最新版・Document Registry・Current Baselineを確認し、**改訂が必要な文書のみ**変更する。Version Upの連鎖、新規管理文書の追加は避ける。

### 7. 先方プロジェクトへの依頼成果物

1. 現行Approvedルールと今回の追加案との差分・重複・矛盾の確認。
2. 適切な挿入先と具体的な追記案（Markdown）。
3. 変更分類（Editorial / Clarification / Semantic等）と影響範囲の評価。影響なし文書は改訂しない理由も提示。
4. 通常開発／Finding発見時／チャットHandoff時の簡単な適用例。
5. 運用負荷の増加を抑えた採用案と、判断を要する点の明示。

**注意：この依頼だけで文書改訂・Baseline更新を承認したものとは扱わない。** 最初に影響分析と差分案を提示し、その後、既存の承認フローに従って正式反映する。

## まとめ / Summary

**日本語**：派生課題を見つけたら、Gateへの必要性とリスクでNOW / DEFER / OUT OF SCOPEに分類し、必要最小限だけ対応する。後回しにする場合は再評価条件を残し、本来の開発目的へ戻る点を明示する。既存ルールと管理文書を増やしすぎない。

**English**: When a new issue appears, decide if it must be handled now, later, or not at all. Record the reason and when to review it again. Return to the main development task without adding extra management work.
