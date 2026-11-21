# P3-03 UserForm Launch Gate・Stable Sort 実装候補レビュー v0.1

> **Status: WORKING CANDIDATE / NOT APPROVED / NOT COMPILED / NOT EXECUTED**  
> 作成日: 2026-11-16  
> Phase: P3 Configuration / UserForm **先行開発準備**（P3正式開始ではない）  
> Product: MailGenerator（Excel VBA + Classic Outlook）

## 1. 判定・結論

**今回作成したのは** Validation成功後にActive VariableDefinitionを `SortOrder ASC`、同値は `__RowIndex ASC` で確定して、将来のUserForm Generatorに安全なデータを渡す**起動準備Gate**である。表示可能な`frmMailGenerator`は今回実装しない。実際の`.Show`呼出・UI通知は**未接続**、ユーザーに見えるUserForm起動はできない。

| 評価項目 | 結果 |
|---|---|
| P3-03 Production候補 `.bas` | **CREATED / CANDIDATE** |
| 既存P3-02 Public APIとの接続 | **SOURCE LEVEL MATCH** |
| P3-01/P3-02実装変更 | **NONE** |
| 21ケース隔離Fixture | **DEFINED / NOT RUN** |
| Static source checks | **SEE `STATIC_REVIEW_RESULT.md`** |
| VBA Import / VBA Compile / VBA runtime | **NOT RUN** |
| 実機Outlook・UserForm表示 | **NOT RUN** |
| P2 Closure / CP-P2 | **NOT ESTABLISHED** |
| P3正式Phase Entry | **NOT STARTED** |
| GitHub保存 / Baseline変更 | **NONE** |

## 2. 基準と既存契約

- Current Approved Baseline: `BL-MVP-004`。
- `DOC-MVP-REQ v0.1.9 §17 / FR-UI-003`: `SortOrder`昇順、同値はVariableDefinitionテーブル行順、同値許可。
- `DOC-MVP-DES v0.1.10 §7.3 / §16 / §17.3 / §25.2`: Active設定の整合確認、取得時のCurrent OFT再Scan、UserForm起動前Gate、必要なデータの行順保持。
- `DOC-MVP-TESTSPEC v0.1.6 MTS-CFG-003`: `ModelName(10), StageName(20), GateDate(20), OwnerName(30)`の行順保持が正式検証対象。今回のFixtureは**正式MTSを実行していない**。
- `DOC-MVP-IMPL v0.4 §8.4`: Configuration Gate → UserForm Generator → Input State。ソートは起動前のデータ準備であり、フォーム生成とは分ける。
- `P3-01 modConfigurationValidator` **Candidate v0.1**: 設定値検証（SortOrder数値等）はしてもソートしない。4つの実装詳細がOPEN。
- `P3-02 modConfigurationApplication` **Candidate v0.1**: 以下の既存候補APIでCurrent OFTスナップショットを取得し、P3-01を呼ぶ。**FailureならCarrierはNothing**、成功時のみ結果公開。

```vb
Public Function PrepareCurrentConfiguration( _
    ByRef templateScanResult As Object, _
    ByRef allVariableDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult
```

**再利用する元データ契約**: `GetAllVariableDefinitions` は `Collection` の各行Dictionaryに `VariableName, Status, SortOrder, __RowIndex` 等を持つ。`__RowIndex`は `tblVariableDefinition` の1始まり行番号としてP2-03 Data Accessが付加している。GetAllはActiveとUnusedを含む。

## 3. 新規実装候補のAPIと処理順

Artifact: `src/modP3UserFormLaunchGate_P3-03_Candidate_v0.1_CP932.bas`。VBA Module名: `modP3UserFormLaunchGate`。

```vb
Public Function PrepareUserFormLaunch( _
    ByRef sortedActiveDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult
```

1. `ByRef`出力2件を`Nothing`に初期化する。
2. `PrepareCurrentConfiguration`を**1回**呼ぶ。ここまでのOFT再Scan・CloseWithoutSave・Definition/Option読取・ValidationはP3-02/P3-01の責務。
3. `COperationResult Nothing` → `UnexpectedError`。`Success=False` → **元Result参照のまま返す**。後続ソート・Formへ進まない。
4. `Success=True`で必要Carrierの`Nothing`/型異常を防御し、Active行だけを抽出する。`Unused`は無視する。
5. Activeの `SortOrder` を`CDbl`へ安全に変換し、`__RowIndex`を正のLong整数として確認。`SortOrder`同値は`__RowIndex`昇順で比較する。
6. 元のCollectionや行Dictionaryを**書き換えず**、新たなCollectionへ行Dictionary参照を追加する。小規模Variable数を想定し挿入ソートを選択（`O(n²)`）。
7. 全処理成功時だけ、`sortedActiveDefinitions`と`activeOptionsByGroup`を公開する。

**Output**: `Success`かつ出力2件あり → *UserForm生成処理へ進めてよいというGate成功*。これはUserForm表示成功を意味しない。失敗は2出力とも`Nothing`。

### 3.1 次のControllerでの接続条件（設計例、未実装）

```vb
Dim stepResult As COperationResult
Dim sortedActive As Collection
Dim optionGroups As Object
Set stepResult = PrepareUserFormLaunch(sortedActive, optionGroups)
If stepResult Is Nothing Then
    ' Treat missing result as Failure; never create a Form.
    Exit Sub
End If
If Not stepResult.Success Then
    ' Later UI layer formats the existing ErrorInfo, then stops.
    Exit Sub
End If
' ONLY HERE: pass sortedActive / optionGroups to later UserForm Generator.
' No frmMailGenerator.Show exists in this candidate.
```

**責務境界**: P2-05 `modUiController`には手を加えない。既存`ExecuteManualSync`を呼ばない。`modP3UserFormLaunchGate`という独立Module名はPlan §8.4に明記された名称ではなく、正式採用前にModule Mapping判断が必要。

## 4. SortOrderと行順の判定仕様（候補）

| 入力 | 期待挙動 | 区分 |
|---|---|---|
| `SortOrder = 10,20,30` | 昇順 | Requirement固定 |
| `SortOrder = 20`が複数行 | `__RowIndex ASC` | Requirement固定 |
| Source Collectionが元の順序と異なる | `__RowIndex`を基準とする | Candidate Defensive |
| `Status=Unused` | 表示対象から除外 | Design/Plan |
| 小数、負数、数値文字列 | `CDbl`変換可能なら順序付け | **OPEN; 非承認の技術的選択** |
| 空文字、Boolean、非数値、`CDbl` Overflow | `ConfigurationError`, `<VariableName>.SortOrder` | Candidate Fail Closed |
| `__RowIndex`欠落・非整数・範囲外・Active行間重複 | `UnexpectedError` | Candidate Carrier Defense |
| Activeなし（整合した空Snapshotという上流Success） | 空CollectionでSuccess | Candidate: 最小変数数の新Requirementは追加しない |

`SortOrder`の完全な許容範囲がApproved Requirementに明示されていないため、本Gateは「実際に比較可能か」の技術的防御を行う。P3-01の`IsNumeric`だけでは`CDbl`のOverflowを除外できないため、**Gateでの変換失敗をConfigurationErrorとして停止**する。P3-01の既存候補には変更を入れていない。

`__RowIndex`はSystem-managed内部メタデータであり、負数や小数は正常なP2-03 Data Access Carrierに存在しない。これはユーザー設定への新しい範囲制約ではない。

## 5. Exception / Fail Closed

| 場面 | Result分類・対象 | 次工程 |
|---|---|---|
| P3-02がFailureを返す | 上流Result**同一参照** | Stop、出力Nothing |
| P3-02がNothing Result | `UnexpectedError` / `ConfigurationApplication.Result` | Stop |
| P3-02がSuccessなのに必要CarrierがNothing／Options非Dictionary | `UnexpectedError` / Carrier名 | Stop |
| SortOrder非数値・CDbl変換不能 | `ConfigurationError` / `VariableName.SortOrder` | Stop |
| `__RowIndex`異常 | `UnexpectedError` / `VariableDefinitions.__RowIndex` | Stop |
| 予期しないVBA例外 | `UnexpectedError` / `UserFormLaunchGate` | Stop |

- first-error方針は現行候補を保持し、上流FailureのErrorInfoを覆い隠さない。UIはこのModule内で表示しない。
- 対象Collectionの**並び順のみ新規作成**し、各Dictionaryの内容は変更しない。ただし返却されるDictionaryは元のオブジェクト参照のため、Callerからの変更まで防止するDeep Immutable構造ではない。
- `PrepareUserFormLaunch`の成功を**将来のメール生成処理に流用しない**。Design §25.3に従い、Mail生成時に再検証が必要。
- Current SnapshotのCOM cleanup、安全な実環境Source同一性等はP3-02の残課題であり、P3-03の静的確認で検証したとみなさない。

## 6. テストFixture（21ケース、定義済み・未実行）

使用: `modP3_03GateTestStub`（P3-02 Public関数のテスト代替）と`modP3_03LaunchGateCandidateTests`。テスト環境用であり、**実Productionと同一VBA Projectへ混在禁止**。

| ID | 入力・狙い | 期待 |
|---|---|---|
| DEV-P3GATE-01 | Source順が30/10/20で乱れている | 10→20→30 Success |
| 02 | SortOrderが全て20、Source順はRow3/1/2 | Row1→2→3 Success |
| 03 | 負値・小数・数値文字列 | 比較可能ならSuccess（候補ルール） |
| 04 | ActiveとUnused混在 | Activeだけ出力 |
| 05 | 全行Unused | 空Active CollectionでSuccess（上流Success仮定） |
| 06 | 上流ConfigurationError | 元Result同一参照、出力なし |
| 07 | 上流Result Nothing | UnexpectedError |
| 08 | 上流Definitions Nothing | UnexpectedError |
| 09 | 上流Options Nothing | UnexpectedError |
| 10 | 上流Scan Nothing | UnexpectedError |
| 11 | OptionsがDictionaryでない | UnexpectedError |
| 12 | `__RowIndex`欠落 | UnexpectedError |
| 13 | Active間で`__RowIndex`重複 | UnexpectedError |
| 14 | SortOrder文字列非数値 | ConfigurationError |
| 15 | SortOrderが極大指数表現 | Overflow/非数値をFail Closed |
| 16 | RowIndex Boolean | UnexpectedError |
| 17 | RowIndex小数 | UnexpectedError |
| 18 | 2回連続実行・元Source順保持 | 結果一貫、Mutationなし（浅い順序確認） |
| 19 | Stubが例外を投げる | UnexpectedError、出力なし |
| 20 | RowIndexがLong上限超過 | UnexpectedError |
| 21 | 大きなDouble SortOrder | 安全に比較してSuccess |

Fixtureは本物の`PrepareCurrentConfiguration`を**置き換えて**Gateの契約だけを検証する。したがってP3-01 Validation、P3-02 Outlook/Data Access、Form表示、Workbook実機はテストしていない。

### 6.1 隔離Fixtureの構成条件

1. 将来、実行を**別途承認された隔離VBA Test Workbook**で行う場合は、`modP3UserFormLaunchGate`、本テストStub、Runner、`modResult`、`COperationResult`、`CErrorInfo`の6モジュールだけを使用する（既存Workbookに同名があれば置換可否を別途確認）。
2. 本物の`modConfigurationApplication`とStubの `PrepareCurrentConfiguration` を**同時Importしない**。
3. Production WorkbookへのImport、Excel/Outlook起動、GitHub Commit、正式テスト実施は本レビューで承認しない。
4. `DEV-`IDは開発テストであり、正式`MTS-CFG-003`等のPASSではない。

## 7. 正式採用前の判断（OPEN）

- **Requiredの受容表現**（P3-01 Candidate: Boolean、数値0/1、文字列True/False）: **OPEN / NO CHANGE**。
- **SortOrderの許容範囲・小数・数値文字列**: **OPEN**。本Gateは`CDbl`可能性の防御のみ実装。Approvedの正数/整数限定要件は存在するものとして扱っていない。
- **Carrier異常時ErrorType**: `UnexpectedError`（内部構造）/ `ConfigurationError`（設定不備）の分類候補: **OPEN**。
- **First-errorのみを返す方針**: 現候補維持。複数ErrorのUI集約は**OPEN**。
- **Module Mapping**: P3-02 `modConfigurationApplication`とP3-03 `modP3UserFormLaunchGate`を独立Production Moduleとして採用するか、既存`modUiController`等に責務を置くか: **OPEN**。
- **実UIへの接続**: `frmMailGenerator`および入力Stateはまだ候補外。Gate成功後の表示を実装する段階で、UI通知とControl生成の責務をレビューする。

## 8. 次の優先アクション

**次**: 本Gateのコード／Fixtureを静的レビューし、正式採用判断前のIssue（SortOrder変換互換性・Module Mapping・テスト結果）を保持する。環境調査やP2-05 Production変更には戻らない。必要なら次のP3単位でDynamic UserForm最小レイアウトとInput Stateへ進むが、P2 Closure以前はP3正式Phase開始と称さない。

想定Project保存先（**GitHub未保存**）:

- Production Candidate: `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Test Stub/Runner: `MailGenerator/tests/vba/P3_Configuration_UserForm/`
- Review: `MailGenerator/Docs/00_project_control/reviews/`

## 9. まとめ / Summary

**日本語:** P3-02のValidation Success後だけActive定義を安定ソートし、将来のUserForm起動に渡すGate候補を作成した。実Formの生成・表示、VBA Compile・Runtimeテストは未実施。P2/P3の承認状態は不変。

**English:** We created a gate candidate that sorts Active variables only after validation succeeds. It keeps row order for equal SortOrder values. The real form, VBA Compile, and runtime tests are not done. P3 has not formally started.
