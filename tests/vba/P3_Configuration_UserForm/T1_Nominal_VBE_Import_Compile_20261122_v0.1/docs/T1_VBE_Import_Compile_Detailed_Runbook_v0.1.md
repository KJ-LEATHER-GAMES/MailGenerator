# T1 Nominal隔離Workbook — VBE Import・Compile 詳細手順書

| 管理項目 | 内容 |
|---|---|
| Document ID | DOC-VER-P304P305-T1-IMPORT-COMPILE |
| Revision / Status | v0.1 / PREPARED（作業手順Candidate） |
| 作成日 | 2026-11-22（JST） |
| 対象 | MailGenerator P3-04 × P3-05 Integrated Input State Candidate v0.1 |
| Execution Baseline | BL-MVP-004（変更しない） |
| 作業場所 | **Windows版 Excel Desktop の新規隔離 `.xlsm` Workbook** |
| 今回のゴール | T1で必要部品を読み込み、`Debug > Compile VBAProject` の実測結果と証拠を記録する |
| 今回の対象外 | Runtimeテスト実行、Production適用、GitHub更新、Baseline変更、P3正式開始・P2 Closure判断 |
| 元資料 | `P304_P305_Isolated_VBE_Execution_Kit_20261121_v0.1.zip` 内 `docs/01_ISOLATED_IMPORT_COMPILE_RUNBOOK.md` および `docs/00_README.md` |

> **重要：この文書は実行手順です。現時点でVBE Import／Compileの実測結果はありません。以下の「PASS」は判定基準であり、実行済みの主張ではありません。**

## 0. 最初に確認する安全上の前提

1. **Production Workbookは開かず、Importしない。** 既存Productionを複製してテスト用にすることも避ける。空白Workbookから開始する。
2. GitHub `KJ-LEATHER-GAMES/MailGenerator` は**読み取り専用**。Commit／Pushはしない。
3. Windows版Excel Desktopを使用する。Excel for Web、LibreOffice、Mac Excelは本検証の対象外。
4. マクロ実行が会社のポリシーで禁止されている場合は**設定を迂回しない**。管理者へ確認する。VBEの手動Importに「VBA project object modelへのプログラム的アクセスを信頼する」設定は原則不要。
5. 既存のCandidateのコードは編集しない。Compileでエラーが出たらFindingとして記録し、**この手順の中では勝手に修正しない**。
6. 今回は**T1だけ**を作る。T2のFault StubやT3のTESTONLY UI Fault FormはT1に入れない。
7. T1のGateはテスト専用Stubであり、**P3-01～03の本物のGateはImportしない**。T1のPASSは実P3-03統合PASSではない。

### 0-1. 作業完了条件（Quality Gate）

- **T1 Compile PASS**：対象のT1 Workbook内に必要な**11コンポーネント**が揃い、Formの固定Control名／親子関係が一致し、VBEの `Debug > Compile VBAProject` が**エラーなしで完了**し、Workbook名・日時・実行者・採用したForm作成ルートをEvidenceに残せた状態。
- **Form Direct Import PASS**：`.frm` のVBE直接Importが実測成功した場合だけ。
- **Manual Designer + Compile PASS**：`.frm` Import失敗後に手動DesignerでFormを作成しCompile成功した場合。**Direct Import PASSとは呼ばない**。
- Importが成立しない場合：`BLOCKED_IMPORT`。Compile未実行なら `NOT VERIFIED`。
- Compile Errorが1件でもある場合：`FAIL_COMPILE`。**Runtimeへ進まない**。

## 1. 入手するファイルと保存フォルダー

### 1-1. ZIPを展開する

1. 元実行キット `P304_P305_Isolated_VBE_Execution_Kit_20261121_v0.1.zip` または本手順書同梱の `T1_sources/` を、**ローカルの試験専用フォルダー**へ展開する。
2. 例：`C:\MailGenerator_Test\T1_20261122\`（例示。実際の保存先は運用ルールに従う）。
3. WindowsのZIPプロパティにセキュリティ通知がある場合は、組織ポリシーと配布元の確認を優先する。安全設定の迂回はしない。
4. **`T1_sources/`は元キットのT1用ファイルのバイト同一コピー**。ファイルの内容を書き換えない。
5. 証拠保存用に `evidence\screenshots\` と `evidence\logs\` を作る。例：`C:\MailGenerator_Test\T1_20261122\evidence\`。

### 1-2. 必須P0共通部品3件をGitHubから取得（ZIPには非収録）

GitHub Repository：`KJ-LEATHER-GAMES/MailGenerator`、branch：`main`。GitHub上で該当ファイルを開き、**Raw版をダウンロード**してファイル名・拡張子を維持する。原本のGitHubは更新しない。

| 順序 | パス | VBE上の名前 | 種別 |
|---:|---|---|---|
| 1 | `src/classes/COperationResult.cls` | `COperationResult` | Class Module |
| 2 | `src/classes/CErrorInfo.cls` | `CErrorInfo` | Class Module |
| 3 | `src/modules/modResult.bas` | `modResult` | Standard Module |

**閲覧先：**

- `https://github.com/KJ-LEATHER-GAMES/MailGenerator/blob/main/src/classes/COperationResult.cls`
- `https://github.com/KJ-LEATHER-GAMES/MailGenerator/blob/main/src/classes/CErrorInfo.cls`
- `https://github.com/KJ-LEATHER-GAMES/MailGenerator/blob/main/src/modules/modResult.bas`

> GitHubの画面に表示されたコードをそのまま `.cls` ファイルに手入力する方式は避ける。元ファイルをダウンロードし、そのままVBEでImportする。取得日時、ブランチ、表示できるCommit IDまたはファイル版をEvidenceへ記録する。GitHubのファイル表示上のblob SHAとSHA-256を混同しない。

### 1-3. T1にImportする8コンポーネント

以下は本詳細手順書ZIP内では `T1_sources/` 以下、元キット内では `candidate/` 以下にある。

| 順序 | ファイル（`T1_sources/`からの相対Path） | VBE上の名前 | 種別 |
|---:|---|---|---|
| 4 | `candidate/src/modP3UserFormController_P304_P305_Integrated_Candidate_v0.1_CP932.bas` | `modP3UserFormController` | Standard Module |
| 5 | `candidate/src/modInputState_P305_ApprovedContract_Unmodified_v0.1_CP932.bas` | `modInputState` | Standard Module（実Candidate） |
| 6 | `candidate/tests/nominal/modP3_04GateStub_From_XU02_v0.1_CP932.bas` | `modP3_04GateStub` | Standard Module（TEST ONLY） |
| 7 | `candidate/tests/nominal/modP304P305NominalTests_v0.1_CP932.bas` | `modP304P305NominalTests` | Standard Module（TEST ONLY） |
| 8 | `candidate/tests/nominal/modP3_04XU02RegressionTests_v0.1_CP932.bas` | `modP3_04XU02Tests` | Standard Module（TEST ONLY） |
| 9 | `candidate/tests/nominal/modTESTONLY_DirectHide_Tests_CP932.bas` | `modTESTONLY_DirectHide_Tests` | Standard Module（TEST ONLY） |
| 10 | `candidate/tests/nominal/modTESTONLY_ModalQueryClose_Smoke_CP932.bas` | `modTESTONLY_ModalQueryClose_Smoke` | Standard Module（TEST ONLY） |
| 11 | `candidate/src/frmMailGenerator_P304_P305_Integrated_Candidate_v0.1.frm` | `frmMailGenerator` | UserForm（Importまたは手動作成） |

**T1に入れないもの**：`modP305FaultInjectionStub`、`modP304P305FaultTests`、`frmMailGenerator_TESTONLY_UI_Clear_Fault`、実`modP3UserFormLaunchGate`、その他P3-01～03の本番候補、Productionのモジュール。

## 2. 新規T1 Workbookを作成する

1. **Excel Desktopを起動**し、**新規 → 空白のブック**を選ぶ。既存Production WorkbookやMVP元ブックを開かない。
2. `ファイル > 名前を付けて保存 > 参照`を選び、**Excel マクロ有効ブック（*.xlsm）**で保存する。
3. 例：`C:\MailGenerator_Test\T1_20261122\T1_Nominal_20261122.xlsm`。
4. Excelのタイトルバーで **`T1_Nominal_20261122.xlsm`** が開かれていることを確認する。
5. **Alt+F11** でVisual Basic Editor（VBE）を開く。**Ctrl+R** でProject Explorerを表示する。
6. Project Explorerで `VBAProject (T1_Nominal_20261122.xlsm)` があることを確認し、**そのプロジェクトを選択**する。`PERSONAL.XLSB`や他WorkbookのProjectを選ばない。
7. VBEメニュー `ツール > 参照設定` を開き、`MISSING:`（参照不可）項目がないか確認する。参照設定を安易に追加・削除しない。Form作成後はMicrosoft Forms 2.0 Object Libraryを使用可能である必要がある。
8. **最初の画面証拠**としてProject ExplorerとWorkbook名が見えるスクリーンショットを保存し、Excel／Windowsのバージョン・bit数をEvidenceへ記録する。

## 3. P0共通部品のImport

1. Project Explorerで **T1 WorkbookのVBAProject** をクリックする。
2. VBEメニュー `ファイル > ファイルのインポート`（英語表示は `File > Import File...`）を選ぶ。
3. `COperationResult.cls` を指定して読み込む。
4. 同様に `CErrorInfo.cls`、`modResult.bas` の順にImportする。
5. **Ctrl+R** でProject Explorerを表示し、`クラス モジュール` に `COperationResult`、`CErrorInfo`、`標準モジュール`に `modResult` があることを確認する。
6. 名前と種別が異なる場合は先へ進まない。ファイル名ではなく **VBEの `(Name)`** を確認する。
7. Evidenceに3件のImport結果を記録する。

> `.cls` の全文をコード画面へ貼る方法では、隠し属性やClass種別を再現できないことがある。Classは `.cls` のImportを使う。

## 4. T1専用Standard ModuleのImport

1. 続けて同じ `File > Import File...` を使用する。
2. 上表の **順序4～10の `.bas` 7ファイル**を1件ずつImportする。Importファイルの物理名と、VBE内の実Module名が異なる点に注意。
3. 各Import後、Project Explorerで上表の名前と一致することを確認する。
4. **同名Public Function衝突を防ぐ確認：** T1には実`modInputState` **だけ**、Gateは`modP3_04GateStub` **だけ**があることをProject Explorerで確認する。
5. ここでは**テストRunnerを実行しない**。

### 4-1. ここまでの中間確認

Standard Modulesは次の**8件**のみ（P0の`modResult`を含む）。

```
modResult
modP3UserFormController
modInputState
modP3_04GateStub
modP304P305NominalTests
modP3_04XU02Tests
modTESTONLY_DirectHide_Tests
modTESTONLY_ModalQueryClose_Smoke
```

Class Modulesは `COperationResult` と `CErrorInfo` の2件。UserFormは次項で1件作る。合計で **11コンポーネント**となる。

## 5. UserFormを設定する（経路A→失敗時経路B）

### 経路A：配布 `.frm` ファイルを直接Importする

1. T1のVBAProjectを選択したまま、`File > Import File...` を開く。
2. `candidate/src/frmMailGenerator_P304_P305_Integrated_Candidate_v0.1.frm` を指定する。
3. Import成功の場合、Project Explorerに **`frmMailGenerator`** が1件だけあるか確認する。
4. FormをダブルクリックしてDesignerを表示。後述の固定Control **7件**と親子関係を確認する。必要ならF4で各Controlの `(Name)` を確認する。
5. `F7` でFormのコード表示へ切り替え、`Public Function BuildValidatedInputs()`、`UserForm_QueryClose`、`cmdClear_Click` が存在することを確認する。
6. 上記がすべて満たされた場合のみ **`FormImportRoute=Direct`** と記録し、6章へ進む。

**Importに失敗した場合：** エラーダイアログをスクリーンショットで保存し、**`DirectFormImport=BLOCKED`** と記録する。途中作成されたFormがあれば、選択中のT1内であることを確かめて除去し、同名の残骸をなくす。**元Candidateの `.frm` は修正しない。** 経路Bへ進む。

> `.frm`はテキスト上のDesigner候補であり、正式なVBE Exportと`.frx`のペアとして検証済みではない。直接Importは成功を前提にしない。

### 経路B：VBE Designerを手動作成し、CodeOnlyを貼り付ける

1. Project Explorerで **T1 Workbook** を選択する。
2. VBEメニュー `挿入 > ユーザーフォーム`（`Insert > UserForm`）を選ぶ。
3. Formをクリックし **F4** でPropertiesを開く。`(Name)` を **`frmMailGenerator`** とする。`Caption` は `定型メール作成 - P3候補` とする。
4. Formの幅・高さを最初はおおむね **Width=590 pt / Height=610 pt** とする（レイアウト参照値。Compileの合否条件に厳密なピクセル寸法は含めない）。スクロールや配置は実機で調整可能だが、**固定Controlの名前・型・親は変更しない**。
5. Toolboxが見えない場合は `表示 > ツールボックス` を選ぶ。Designerで次の7つの固定Controlを追加する。

| # | 親 | Control種類 | `(Name)`（完全一致） | 初期設定・注意点 | 参考の左/上/幅/高さ（pt換算） |
|---:|---|---|---|---|---|
| 1 | Form | Label | `lblHeader` | Caption=`定型メール作成` | 12 / 9 / 553 / 19 |
| 2 | Form | Label | `lblGuidance` | Caption=`必須項目は * で表示します。` | 12 / 32 / 553 / 18 |
| 3 | Form | Frame | `fraInputArea` | Caption=`入力項目`。**中身は空** | 12 / 54 / 557 / 358 |
| 4 | Form | Frame | `fraErrorArea` | Caption=`案内` | 12 / 416 / 557 / 103 |
| 5 | **fraErrorArea内** | Label | `lblErrorText` | Caption=`入力値を準備しています。`、WordWrap=True、複数行表示 | 8 / 15 / 531 / 77（Frame内相対） |
| 6 | Form | CommandButton | `cmdCreateMail` | Caption=`メール作成（未実装）`、**Enabled=False** | 298 / 532 / 131 / 28 |
| 7 | Form | CommandButton | `cmdClear` | Caption=`入力クリア`、**Enabled=False** | 439 / 532 / 131 / 28 |

> 参考位置は元 `.frm` のDesigner値を1 pt=15 twipで換算した目安。重要なのは7件の **名前・型・親子関係**。`lblErrorText`をFrameの外へ置かない。動的Controlは**この段階で手動追加しない**。

6. `lblErrorText` を選択した状態でParentが `fraErrorArea` 内であることをDesigner上の枠内表示で確認する。`cmdCreateMail`は無効、`cmdClear`は無効のまま。
7. VBEでFormを選んで `F7` または `表示 > コード` を開く。
8. `T1_sources/docs/frmMailGenerator_Original_CodeOnly_CP932.txt` を**Shift-JIS/CP932として開く**（文字化けしている場合はエディターの文字コードを「日本語（Shift-JIS）」で開き直す）。
9. コード画面の既存空コード／自動生成された空イベントを確認して取り除き、**`Option Explicit` の行からファイル末尾まで**をすべて貼り付ける。元`.frm`の `VERSION`、`Begin`、`End`、`Attribute VB_...` は**貼らない**。
10. `Option Explicit` が重複していないことを確認する。`BuildValidatedInputs()`、`UserForm_QueryClose`、`cmdClear_Click`、`InputCommitSucceeded` の各Procedureが**1件ずつ**存在するか、Code WindowのProcedureドロップダウンまたは検索で確認する。
11. Project ExplorerにはFormが**`frmMailGenerator` 1件のみ**残ることを確認する。`FormImportRoute=Manual Designer` と記録し、**Direct Importが成功したとは記録しない**。

### UserFormのコードをコピーする際の注意

- テキストファイルは**CP932 / CRLF**。文字化けのまま貼ると日本語メッセージが壊れ、場合によって文字列リテラルにも影響する。
- `.frm`のDesigner全文をコード画面に貼り付けない。`CodeOnly`の`Option Explicit`以降だけを使用する。
- Dynamic Controls（`txtInput_0001`、`cboInput_0003`等）は、VBAの実行時に自動生成される。Compile前に手動で作らない。
- Designer手動作成を選んだ場合、`Source Type = Manual Designer + Original CodeOnly` と証拠に記録する。

## 6. Compile前チェック（11コンポーネント整合）

Project ExplorerとDesigner／Code Windowを使って**次の項目をすべて目視確認**する。

- [ ] Excelタイトルバー／Project Explorerの対象が `T1_Nominal_YYYYMMDD.xlsm`。
- [ ] Class 2件：`COperationResult`、`CErrorInfo`。
- [ ] Standard Module 8件：4-1章の一覧と完全一致。
- [ ] Form 1件：`frmMailGenerator`。
- [ ] **実`modInputState`あり、Failure Stubなし**。
- [ ] **Gate Stubあり、本物のP3-03 Gateなし**。
- [ ] 元Form・TESTONLY UI Fault Formの**混在なし**。
- [ ] 固定Control 7件。特に `fraInputArea` と `fraErrorArea.Controls("lblErrorText")`。
- [ ] `cmdClear`・`cmdCreateMail`は初期Enabled=False、CodeOnly側がClick処理を持つ。
- [ ] `MSForms.TextBox`、`MSForms.ComboBox` 等が使用できる参照状態。`MISSING:` 参照なし。
- [ ] Form CodeOnlyが欠損していない。末尾まで貼られている。
- [ ] **テストRunnerをまだ実行していない**。

このリストに未解決があればCompile前にSTOPして、原因を記録する。ユーザーの承認なしに既存Candidateを修正しない。

## 7. VBE Compile実行（今回の主作業）

1. `Ctrl+S` で**隔離Workbook**を保存する。保存先がProductionでないことを再確認する。
2. VBEで `VBAProject (T1_Nominal_YYYYMMDD.xlsm)` 配下のModuleを開き、**T1 Projectがアクティブ**であることを確認する。
3. メニュー `デバッグ > VBAProject のコンパイル`（英語表示 `Debug > Compile VBAProject`）をクリックする。メニュー名はWorkbook名を含むことがある。
4. **エラーダイアログが出た場合：** その場で作業を中断し、次を記録する。①画面のエラーメッセージ原文、②選択されたModule/Form、③VBEが強調した行、④スクリーンショット、⑤何件目か（最初のエラーから順番）。**Compile結果=`FAIL_COMPILE`**。**Runtimeへ進まない**。
5. エラーがない場合、Compileメニューを再度開く。環境によってはCompile済みでグレー表示になる。ProjectがCompileされたことを判断する**補助情報**として記録する（グレー表示だけを単独の証拠にしない）。
6. VBEのProject ExplorerとCompileメニュー、日時が分かるスクリーンショットをEvidenceへ保存する。**結果=`COMPILE_PASS`**と書くのは、実行者が実際にエラーなし完了を観測した場合だけ。
7. `Ctrl+S` で保存する。テスト用Workbookのパス、Form作成経路、Import結果、Compile結果をEvidenceへ転記する。
8. **今回の作業はここで停止**。`RunP304P305NominalCandidateTests` 等のRuntime Entryは実行しない（別の工程で実行する）。

### 7-1. Compileエラー時のFinding記録

以下の形式でEvidenceへ記録する。

```text
Finding ID: T1-COMP-001
Workbook: T1_Nominal_YYYYMMDD.xlsm
Form route: Direct / Manual Designer
Error message (verbatim): <表示された日本語/英語のまま>
Component: <モジュールまたはForm名>
Highlighted line: <原文をコピー。長い場合は前後数行も付記>
Action taken: STOP / No source modification
Actual: FAIL_COMPILE
Attachment: evidence/screenshots/T1-COMP-001.png
```

**よくある見落とし（原因の断定ではない）**

| 症状 | 最初に確認すること | 対応 |
|---|---|---|
| `ユーザー定義型は定義されていません` / `User-defined type not defined` | `COperationResult` / `CErrorInfo` のClass Import、`MSForms`参照 | 原因を記録。参照追加が必要ならポリシー確認 |
| `Sub or Function not defined` | `modResult`、`modP3_04GateStub`の未Import | 追加Import前にMissing Componentを証拠化 |
| `Ambiguous name detected` | 実GateとStub、実Input StateとFault Stub、同名Module重複 | **競合するTEST ONLYを確認**。混在があれば停止 |
| `Method or data member not found` | `frmMailGenerator`の固定Control名・親、CodeOnly貼付漏れ | Designer上の`(Name)`とコードを照合 |
| `Invalid outside procedure` など | `.frm`の`Attribute`や`Begin/End`をコード欄に貼っていないか | 貼付経路を記録し、Candidate原本は変更しない |
| `.frm` Importできない | `.frx`不在・Designerが手生成候補である点 | **経路Bを使用**。Direct ImportはBLOCKEDと記録 |
| `MISSING:` 参照 | Microsoft Forms 2.0等、VBEの参照ライブラリ | 組織管理下で確認。勝手に保護設定を解除しない |

> エラー原因を推測だけで確定しない。まずVBEが示した実際のメッセージと行を保存する。修正は、**別RevisionのCandidateで設計・レビューしてから**実施する。

## 8. Evidenceの記入方法と提出物

結果は `docs/T1_Import_Compile_Evidence_Template.md` を複製して記入する。推奨ファイル名：`T1_Import_Compile_Result_YYYYMMDD.md`。

必要な記録：

1. 実行日時（JST）、実行者、Windows・ExcelのVersion/bit数。
2. T1 Workbookフルパス・ファイル名、プロジェクト名。
3. GitHubから取得したP0 3ファイルの出所（branchと取得日、取得できるならCommit ID）。
4. T1 Components 11件の存在確認と、Import対象のファイル名。
5. `.frm` Direct Import結果、Manual Designer移行の有無、固定Control親子関係。
6. Compile実測結果と最初のエラー、スクリーンショット、参照設定の状態。
7. 元Candidate／GitHub／Baselineに**変更していない**ことの確認。
8. 判定（`COMPILE_PASS`、`FAIL_COMPILE`、`BLOCKED_IMPORT`、`NOT VERIFIED`）と次アクション。

証拠例：

```
evidence/
  T1_Import_Compile_Result_YYYYMMDD.md
  screenshots/
    T1_01_Excel_Title.png
    T1_02_Project_Explorer.png
    T1_03_Form_Designer.png
    T1_04_Form_Code.png
    T1_05_Compile_Result.png
  logs/
    T1_Compile_First_Error.txt  # エラー時のみ
```

### 8-1. 作業終了条件と次工程

- **COMPILE_PASS**：Runnerを実行せず、Evidenceを共有する。次工程でT1のNominal 21件＋XU-01/02回帰35件およびDirect Hide/Xボタン手動チェックへ進むかを判断する。
- **FAIL_COMPILE**：最初のエラーを報告し、修正候補の設計レビューへ戻す。RuntimeのPASSは主張しない。
- **BLOCKED_IMPORT**：Designer回避を含め、どの段階で止まったかを記録する。Compileが行われていなければ `NOT VERIFIED`。
- **Production/GitHub/Baseline**：いずれも変更しない。

## 9. 次工程の参考（今回は実行しない）

実機CompileをPASSした後に検討するRuntime Entryは次のとおり（**実行予約や実行実績ではない**）。

```vb
RunP304P305NominalCandidateTests   ' T1 nominal 21 cases
RunP304XU02CandidateTests           ' XU-01/XU-02 regression 35 cases
RunTESTONLY_DirectHide_Test         ' Direct Hide one additional check
RunTESTONLY_ModalQueryClose_Smoke   ' Actual X button one additional check (manual interaction)
```

`Immediate Window` はVBEで `Ctrl+G`。Runtimeの実施方法・判定は元キットの `docs/02_PRIORITY_CASE_MATRIX.md` を参照し、**Import／Compile結果と区別**して記録する。

---

## まとめ / Summary

**日本語：** T1用の11コンポーネントを新規隔離WorkbookへImportし、Formの直接Importまたは手動Designer方式を選んだうえでVBE Compileを実測する。結果と最初のエラーを証拠化し、Runtimeへは進まない。Production、GitHub、BL-MVP-004は変更しない。

**English:** Import 11 components into a new T1 test workbook. Use direct Form import or create the Form manually. Run VBA Compile and record the result. Do not run runtime tests yet. Do not change Production, GitHub, or BL-MVP-004.
