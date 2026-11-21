# P3-04 × P3-05 Input State 接続方式 ― 設計Candidate v0.1

| 項目 | 内容 |
|---|---|
| Document ID | P3-04-P305-INTEGRATION-DESIGN-CANDIDATE |
| Revision | v0.1 |
| Date / Status | 2026-11-21 / WORKING CANDIDATE・NOT APPROVED |
| Baseline | BL-MVP-004（変更なし） |
| 参照 | P3-04 XU-01 A案修正Candidate、P3-05 API Source Review v0.1、DOC-MVP-DES v0.1.10 §18・§25.2 |

## 1. 目的・制約

**目的**：MTS-INPUT-001/002を将来満たすため、P3-04 XU-01 A案Gateを維持したまま、保存・復元・Clearの呼出経路を設計する。

**設計検討のみ。** `frmMailGenerator`、Controller、P3-05、既存Production・GitHubを編集しない。Input Validator、メール生成、Workbookイベント、正式Phase開始、実機検証は対象外。

## 2. 現状確認（実ソース）

1. XU-01 A案後、`frmMailGenerator.BuildValidatedInputs()`が**必ずP3-03 `PrepareUserFormLaunch`**を実行する。Gate Success時だけ`BuildInputsFromGate`でControlを生成。
2. `AppendInputRow`はText/DateをTextBox、Selectを`fmStyleDropDownList` ComboBoxとして作成し、入力Controlへ`.Tag=VariableName`を設定。Selectは`ListIndex=-1`で初期化。
3. Formは`UserForm_Activate`ガードを持つが、**`UserForm_QueryClose`は未実装**。Input Stateの3 API呼出しも未実装。
4. Controller `ShowMailGeneratorForm`は`.Show vbModal`から復帰後に`Unload newForm`する。閉じる直前に入力値を採取しないまま破棄され得る。
5. `cmdClear.Enabled=False`。表示中ControlとのClear整合は未実装。
6. P3-03は`sortedCandidate.Add item`で元Row DictionaryのObject参照を保持し、Option Dictionaryも元の参照を公開する。**XU-02未解決。**

## 3. 推奨する連携経路（まだ未承認）

```text
Controller -> New frmMailGenerator
  -> Form.BuildValidatedInputs()                [XU-01 A案: Gate強制]
       -> PrepareUserFormLaunch()               [P3-03]
       -> Validator Success / SortOrder確定
       -> P3-04内で表示用Scalar Snapshotへ変換 [XU-02対策候補]
       -> TextBox / ComboBox生成                [既存]
       -> TryGetInputValue(Control.Tag, ...)   [P3-05; 復元]
       -> 不正Select復元値があれば通知+未選択化 [判断待ち]
       -> Formの構築完了
  -> 成功時だけ .Show vbModal
       -> 入力編集
       -> 標準X終了のQueryCloseイベント
            -> 全ControlのTag/Type/Valueを先行検査
            -> SetInputValue(Tag, rawString)で保存
            -> 保存成功: 閉じる許可
            -> 保存失敗: Cancel=True、表示維持、ErrorAreaへ通知
  -> .Show復帰後、ControllerがFormを解放
```

### 3.1 Form生成・復元順序

- P3-03 Gateは**1回**。復元処理はP3-05 Storeだけを読み、OFTを再Scanしない。
- Controlを全件構築した後、`mBuilt=True`にする前に保存値を各`Control.Tag`へ対応付けて復元する。復元失敗ならFormを表示せず破棄する（XU-01維持）。
- Text/Dateは`TextBox.Value = 保存文字列`。Dateの妥当性は復元時に新しく判定しない。
- Selectは`ComboBox.ListIndex`に一致するActive `Value`がある場合のみ選択。未登録または空文字は`ListIndex=-1`。保存値不一致時は**自動で先頭Optionを選ばない**。
- Select照合のCase Sensitivity、失効保存値の処理・通知は実装前に決定する。OptionGroup名の照合とOption Valueの照合は別契約。

### 3.2 終了時Capture（データ消失防止）

- VBA `UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)`は標準Close（X）/Unloadの検討箇所。フォームのControlがまだ存在する間に全入力を取得する。
- **第一段階**：動的入力Controlだけを収集し、すべての`Tag`が非空で、Valueが文字列へ正規化できるか検査。Selectの`ListIndex=-1`は`""`とする。Labelは保存対象外。
- **第二段階**：検査済みの入力一覧を`SetInputValue`へ順次保存。すべてSuccessなら終了許可。Failureなら`Cancel=True`として画面を残し、ErrorAreaで失敗を伝える。`COperationResult`をUIイベントから黙って捨てない。
- この3 APIでは全件を**原子的に一括Commitできない**。途中Failureで一部値が更新される可能性を、Retryで同じ全件を再保存する制限付き設計として記録する。真のAtomic Commitが要件化した場合にのみBatch API追加を検討する。
- **制約**：VBA `UserForm.Hide`は`QueryClose`を通過しない。直接`.Hide`するCallsiteを明示的に禁止・監査し、必要なら`SaveAndHide`のような制御されたForm APIを将来設ける。`UserForm_Deactivate`が常に発火するという仮定で設計しない。
- `QueryClose`のCloseMode差異（X、`Unload`、Workbook終了など）とイベント内の`Cancel`の実挙動は**Runtime NOT VERIFIED**。Workbook終了まで確実に閉じられるUXは別途検証する。

### 3.3 Clearとデータ整合

- クリア対象は**保存中Dictionaryと画面Controlの両方**（Approved Design §18.4）。
- 画面Controlの対象は動的TextBox/ComboBoxのみ。TextBoxは`""`、ComboBoxは`ListIndex=-1`。
- `ClearInputValues()`がFailureを返した場合、Clear成功と表示しない。UI側の処理順・途中Failure時の部分クリアを後続実装で検査する。
- XU-01 A案とP3-05の境界が安全になるまで、P3-04 `cmdClear`は無効を維持する。

## 4. XU-02：Snapshot参照共有の取り扱い（設計判断案）

### 4.1 問題の正確な範囲

P3-03はソート後のCollectionへ元の**Mutable Dictionary参照**を追加し、Option GroupもMutable Dictionary/Collection参照を公開している。ただし、現在のP3-04は同期処理でこれらを消費し、作成したControlには文字列や選択肢を設定するだけであり、Formのフィールドとして元のDictionaryを保持していない。**現在の呼出経路内で実際に変更が発生した証拠はない**。XU-02は「設計上の保証不足」であり、確認済みProduction Defectではない。

### 4.2 選択肢比較

| 方針 | 利点 | 課題・影響 | 推奨 |
|---|---|---|---|
| **A：P3-04 Private Renderer入口で表示用Scalarをコピー** | 追加Public APIやModule不要。Formに渡した後の参照共有を排除し、既存Gateを維持 | Private Preflight+Copyの最小修正、Option値順とCarrier Errorを再テスト | **推奨** |
| B：P3-03で全CarrierをDeep Copy | 下流の利用者が増える場合も隔離可能 | P3-03責務拡大・コピーの仕様増加。OptionのCarrierを再構成する必要 | 後続の拡張時候補 |
| C：現行Object参照のまま同期利用、Callsite監査のみ | 実装コスト最小 | Snapshot不変性を保証できず、XU-02をCloseできない | 暫定に限る |

**A案の詳細**：Form内部で全Rowの`VariableName`、`DisplayName`、`Type`、`Required`、`Description`、`OptionSource`をコピーし、Optionは表示順どおりの`Value`文字列だけへ写す。検証済み`SortOrder`は入力順が確定しているためRendererでは再ソートしない。コピー完了後、元行/Option辞書参照を保持しない。ControlにはScalarだけを設定する。**コピー前の競合・イベント再入を防げるという意味ではない**ので、同期コールパス/イベント挙動の静的・実機検証を残す。

**現時点のXU-02 Status**：OPEN / A案はAI提案。ユーザー承認・修正Candidate・Runtimeは未実施。新しい`modInputState`のCore自体にはこの参照共有リスクは存在しない（Store非公開）。

## 5. Module Mapping／既存承認との整合

- `modInputState`はApproved Implementation Plan v0.4 §6に存在するため、P3-05単独の追加Module承認は不要。
- P3-04 `modP3UserFormController`の独立採用はXU-06のまま。勝手にApproved `modUiController`へ移管しない。
- Input Stateの保存・復元の**UIイベント処理**はForm / Controllerで行い、`modInputState`はUI Controlへ直接依存させない。
- XU-01 A案：公開BuilderでGate強制、非構築Formの直接`.Show`ガード、これらを維持。
- XU-03/04のPatch、Required/SortOrder/Carrier/Error分類判断は今回扱わない。

## 6. Integration Quality Gate（後続工程）

| Gate ID | 合格条件 | 現状 |
|---|---|---|
| IG-01 | Gate FailureでForm表示・入力復元なし | SOURCE PATH CANDIDATE / NOT RUN |
| IG-02 | Gate Success→Control生成後に保存文字列を復元 | NOT IMPLEMENTED |
| IG-03 | X終了直前にText/Date/SelectをTagで収集 | NOT IMPLEMENTED |
| IG-04 | 保存Failureは閉じず、ErrorAreaに表示 | NOT IMPLEMENTED |
| IG-05 | 直接`.Hide`など管理外終了経路がないこと | NOT VERIFIED |
| IG-06 | ClearでStoreと表示中Controlの双方が消える | NOT IMPLEMENTED |
| IG-07 | Select失効値を自動選択しない | DECISION REQUIRED |
| IG-08 | P3-04の表示用CarrierをMutable元参照から分離 | XU-02 DECISION REQUIRED |
| IG-09 | Workbook Close/Reopenで非永続・同一Session再表示で復元 | NOT VERIFIED / MTS-INPUT-001 |
| IG-10 | P3-04 Designer Import・Compile・表示イベント | NOT VERIFIED |
| IG-11 | 一次Failureの伝播・ResultはSuccess時のみForm利用可 | SOURCE PATH CANDIDATE / NOT RUN |

## 7. 次の意思決定（GrillMe 1問ずつ）

1. **D-P305-01/02**：Public 3 API / String保持Candidateの実装契約を採用するか（先決）。
2. **D-XU02**：Form Private Renderer内でScalarコピーするA案を承認するか（次）。
3. **D-UI-CLOSE**：QueryCloseでのCapture、直接Hide禁止、失敗時Cancelという終了設計を承認するか。
4. **D-SELECT-STALE**：失効Select保存値を未選択に戻して通知するか。

いずれも**今回ユーザーの承認を得ていない提案**。承認後にP3-04/P3-05連携の最小差分Candidateと隔離Fixtureを別Unitとして作成できる。XU-01 Runtime検証・P3正式開始へ進んだことにはならない。

## 8. 保存先

作業領域：`/mnt/data/P3-05_Source_Review_and_P3-04_Integration_Package_v0.1/`

推奨GitHub先：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`（接続設計Candidate）。**GitHub保存は未実施。**
