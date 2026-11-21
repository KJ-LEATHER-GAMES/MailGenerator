# P3-04 UserForm Designer作成メモ（Candidate v0.1）

> **未承認／実機未検証。Production WorkbookにはImportしない。**

## 1. 資産の性格

`src/frmMailGenerator_P3-04_Candidate_v0.1.frm`は、設計値とコードを一体化した**テキスト上のDesigner候補**である。
Excel VBA UserFormの正規Exportに必要となる`.frx`の生成、VBIDEによるDesigner保存、VBE Import、Compile、実描画は**実行していない**。この`.frm`が単独でVBEにImportできることは保証しない。Import成功を前提に進めない。

実機で承認済み隔離Workbookを使用できるようになった場合は、VBEで`frmMailGenerator`を新規作成し、以下の**固定Control**をDesigner上で設置したうえで、`src/frmMailGenerator_CodeOnly_v0.1.txt`のコードをフォームコードへ貼り付ける方式を推奨する。Designer書込み・Compileを実施する前に別途承認が必要。

## 2. 固定Control（すべてDesigner配置、**非動的**）

| Name | Type | 役割 | 設定 |
|---|---|---|---|
| `lblHeader` | MSForms.Label | Header | Caption=`定型メール作成` |
| `lblGuidance` | MSForms.Label | Guidance | Caption=`必須項目は * で表示します。` |
| `fraInputArea` | MSForms.Frame | 動的入力Control領域 | 固定。スクロール設定はBuild時 |
| `fraErrorArea` | MSForms.Frame | 固定案内・ErrorArea | 将来のError表示拡張先 |
| `lblErrorText` | MSForms.Label（fraErrorArea内） | 現段階の未接続案内 | 固定 |
| `cmdCreateMail` | MSForms.CommandButton | 作成Button | **Enabled=False** |
| `cmdClear` | MSForms.CommandButton | クリアButton | **Enabled=False** |

FormのCaption、Width/Height、Top/Leftは`.frm`テキストの候補値を参照する。**UI寸法・フォント・スクロール・表示は実機未検証**。特に長いDisplayName/Descriptionや高DPIに対する操作性は未評価。

## 3. 動的Control

1 Active行ごとに`fraInputArea.Controls.Add`で次の4種を生成する。

- `lblDisplay_0001`など：`DisplayName`
- `lblRequired_0001`など：`Required=True`なら`*`を表示
- `txtInput_0001`（Text/Date）または`cboInput_0001`（Select）：**`Tag=VariableName`**
- `lblDescription_0001`など：任意`Description`

`Select`は`fmStyleDropDownList`、OptionMaster有効候補の取得順を維持する。自動Input State保存・復元、作成Button、クリアButton、入力Validationは非実装。

## 4. 隔離テストのモジュール条件

`tests/modP3_04GateStub_v0.1_CP932.bas`は、本物のP3-03 `PrepareUserFormLaunch`と**同じPublic関数名**を持つ。
StubとP3-03 Production候補を同時にImportしてはいけない。専用の隔離テストWorkbookに、次のファイルだけを揃える。

- `frmMailGenerator`（固定ControlのDesignerが必要）
- `modP3UserFormController` Candidate
- `modP3_04GateStub` **TEST ONLY**
- `modP3_04FormCandidateTests` **TEST ONLY**
- 既存`modResult`、`COperationResult`、`CErrorInfo`

VBAテスト入口：`RunP304FormCandidateTests`（テスト実行は未実施）。`ShowMailGeneratorForm`はModalであるため自動試験から除外し、UI操作性は手動で評価する。

## 5. Import／実機前のSTOP条件

P2 Closure／P3正式Phase Gate／隔離方式／Excel-VBE作業承認／Source同一性が未確認のため、Production WorkbookへImportしない。今回の成果物は作業用Candidateに限る。B2-02環境調査は再開しない。
