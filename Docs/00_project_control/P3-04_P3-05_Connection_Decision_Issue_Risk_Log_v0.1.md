# Decision Log / Issue & Risk Log v0.1

| 項目 | 内容 |
|---|---|
| Document ID | P3-04-P305-CONNECTION-DL |
| Date / Status | 2026-11-21 / Working Candidate |
| Project | MailGenerator / BL-MVP-004（不変更） |

## 承認済み事項（ユーザーの既存承認）

| ID | 決定内容 | 適用範囲 | 状態 |
|---|---|---|---|
| D-P305-01 | `SetInputValue`, `TryGetInputValue`, `ClearInputValues`の3 API | P3-04接続Candidate | APPROVED（Production未採用） |
| D-P305-02 | 生文字列 `String` をStore保持 | P3-04接続Candidate | APPROVED（Production未採用） |
| D-XU-01 | Form公開構築入口がP3-03 Gateを強制する | P3-04 Candidate | APPROVED DESIGN / Runtime NOT VERIFIED |
| D-XU-02 | Form Private Rendererで全Row/参照OptionのScalar Snapshotを作成する | P3-04 Candidate | APPROVED DESIGN / Runtime NOT VERIFIED |

## 未決事項：優先順

| ID | 選択肢・AI推奨 | 決める理由 | 影響 | 状態 |
|---|---|---|---|---|
| D-UI-CLOSE | **A（推奨）**：`QueryClose`で全入力Capture、失敗時はCancel、直接Hide禁止。B：専用SaveAndClose＋Xガード | Form終了で入力消失を防ぐ | Form/Controller/テスト | OPEN |
| D-UI-CLEAR | **A（推奨）**：Store+画面Clear、明示Clear直後の全空CloseはSaveスキップ。B：空文字Key再保存を許容（Designの「クリア」と意味差あり） | Clearの消去を終了後も保持 | Clear UIとCapture条件 | OPEN |
| D-SEL-STALE | **A（推奨）**：未選択表示＋対象通知、Storeを勝手に変更しない。B：復元FailureでFormを開かない | 保存値が無効化される場合のUX/安全 | Select復元/エラー表示 | OPEN |
| D-SELECT-CASE | Select **Value** 照合をCase Sensitive（推奨）/Insensitiveから決定。OptionGroupは既存BinaryCompare維持 | Option値の誤マッチ回避 | Select復元 | OPEN |
| D-COMMIT | 既承認3 APIのまま非原子逐次保存＋再試行（推奨）／Batch API変更の再承認要求 | 部分更新への扱い | P3-05 API／保存UI | OPEN |
| XU-06 | 独立`modP3UserFormController`の採用か`modUiController`への統合か | Plan §6 Module Mapping | Phase Implementation | OPEN |

## リスク・制約

| ID | 内容 | 予防・確認 | Status |
|---|---|---|---|
| R-01 | P3-04 `.frm`の実VBE Import/Compile未確認 | 実機Gateで確認 | NOT VERIFIED |
| R-02 | UserForm `QueryClose`イベントのCloseMode差・二重実行／直接Hide | 閉鎖経路を制限し実行テスト | OPEN |
| R-03 | Coreの逐次Setに部分更新の可能性 | 全ControlのPreflight、FailureでClose停止／再試行 | OPEN |
| R-04 | ClearがStoreで成功後、UI Control操作に失敗する可能性 | エラー報告、補償方針とRuntimeテスト | OPEN |
| R-05 | Gate成功からScalarコピー開始までの可変参照 | 現行XU-02の制約として維持 | OPEN / KNOWN BOUNDARY |
| R-06 | 初回表示やWorkbook Close実行時のInput Session実挙動 | Formal MTS-INPUT-001で検証 | NOT VERIFIED |
| R-07 | XU-01直接`.Show`の描画・操作ガード実挙動 | Runtime検証 | NOT VERIFIED |

## 承認済みBaseline・Productionへの影響

今回、Production、GitHub、Baseline、既存P3候補ソースに**変更なし**。P2 Closure、S5-C、P3正式Phase開始は依然未承認。
