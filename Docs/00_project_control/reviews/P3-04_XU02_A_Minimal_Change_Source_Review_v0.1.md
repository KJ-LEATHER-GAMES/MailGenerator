# P3-04 XU-02 A案：Scalar Snapshot参照分離 最小修正Candidateレビュー v0.1

| 項目 | 内容 |
|---|---|
| Document ID | P3-04-XU02-A-REVIEW |
| Revision | v0.1 |
| Status | **WORKING / REVIEW_REQUIRED / NOT APPROVED** |
| 作成日・更新日 | 2026-11-21 |
| Execution Baseline | BL-MVP-004（Approved、変更なし） |
| Parent Artifact | `frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm` |
| 目的 | XU-01のGate強制を維持したまま、XU-02のRow/Option参照共有をForm描画境界で切断する |
| 承認済み設計判断 | **XU-02 A案**：P3-04のPrivate Renderer側で全Row/OptionのScalarコピー。ユーザー承認 |
| 承認済み接続契約 | P3-05の3 Public API + 生文字列String保持（**今回実装は接続しない**） |
| 実行環境 | ソース作成／静的検査のみ。Excel・Outlook・VBE未使用 |
| 関連文書 | DOC-MVP-REQ v0.1.9 / DOC-MVP-DES v0.1.10 §17–18, §25.2 / DOC-MVP-TESTSPEC v0.1.6 / DOC-MVP-IMPL v0.4 |

## 1. 判断とスコープ

- **設計方針：承認済み**。XU-02 A案。元Carrierが可変Dictionary・Collectionであることによる表示時の参照共有を、Form内部のPrivate Snapshotコピーで緩和する。
- **実装候補：未承認**。これまでのP3-04 XU-01 A CandidateのFormだけを変更し、Controllerは無変更。実`P3-01`～`P3-03`、`P3-05`、P2 Production、GitHub、Approved Baselineは無変更。
- **対象外**：Input State復元・保存・Clear接続、Mail生成、VBE Import／Compile、Runtime、P2 Closure、S5-C Gate、P3正式開始、B2-02環境調査。

## 2. Change Log（旧→新）

| 変更箇所 | 変更前 | 変更後（Candidate） | 理由／影響 |
|---|---|---|---|
| `BuildValidatedInputs()` | Gate出力をPrivateレンダラへ渡す | Gate成功後、Private `CreateDisplaySnapshot()`で全件複製。元Carrier参照解放後にレンダラ呼出 | Gate後の元Row/Option参照再取得を避ける |
| Renderer | `BuildInputsFromGate(Collection, Object)` | `BuildInputsFromSnapshot(displaySnapshot As Collection)` | 表示層から元OptionGroupsへの依存を除外 |
| Row/Option検査 | 全件事前検査後、元Row/Optionを表示時に再参照 | 全件検査と値コピーを同じ前処理内で完結 | 元Carrier値が表示処理へ流入する経路を縮小 |
| Rowの表現 | 元Dictionary Object参照 | **毎行別の新Dictionary**（`VariableName`, `DisplayName`, `Type`, `Required`, `Description`, `OptionSource`） | 表示用Scalarのみ保持 |
| Optionの表現 | 元Collection[Dictionary] | **毎Row別の新Collection[String]**（`OptionValues`） | 元Option Dictionaryへの参照を除外 |
| `AppendInputRow()` | RowとOptionGroupを参照 | コピー済みRow／OptionValuesのみ参照 | ScalarからControlを生成 |
| Controller | XU-01 A案 | **バイト単位で同じ** | 既存APIを保持 |
| Public API | `BuildValidatedInputs()` | **変更なし** | XU-01のGate迂回防止を維持 |

### 2.1 処理境界

```text
New frmMailGenerator（固定Shell）
   ↓
Public BuildValidatedInputs()
   ↓
P3-03 PrepareUserFormLaunch()  ※1回、Failure時はそのまま返す
   ↓ Success
Private CreateDisplaySnapshot()
   ├─ Row型、VariableName、DisplayName、Type、Required、Descriptionの検査
   ├─ SelectはOptionSourceから厳密一致（vbBinaryCompare）でActive Options取得
   ├─ Option順のまま全Valueを文字列コピー
   ├─ 各Rowごとに新しいDictionary + OptionValues Collection
   └─ 全Row成功したときだけ新Snapshot Collectionを公開
   ↓
元のGate出力Carrier参照を解放
   ↓
Private BuildInputsFromSnapshot()
   ├─ Scalarコピーだけを読む（元Dictionaryは読まない）
   ├─ Text/Dateは1行TextBox、Selectは選択専用ComboBox
   ├─ Tag=VariableName、Required表示、Description維持
   └─ 最後まで成功してからmBuilt=True
   ↓
Controllerが成功したFormだけ公開／表示
```

### 2.2 安全条件

1. 最初の`Controls.Add`前に**全行・全Optionの検証とコピー**が完了する。
2. `AppendInputRow`へ元OptionGroupを渡さない。`TryGetGroup`はコピー前処理でしか呼ばない。
3. Required値は既存XU-01の受容規則でBooleanへ変換する（未決のRequired全体仕様は変更しない）。
4. Date FormatやSortOrderをこのFormで再検証／再ソートしない。P3-03までの責務分離を維持する。
5. OptionGroup照合は`vbBinaryCompare`でCase Sensitive。Data Accessが返すActive Option順を変更しない。
6. コピー途中のFailureではSnapshotを公開せず、**Controlをひとつも生成しない**。Renderer途中のFailureでは従来どおり動的Controlを削除して`mBuilt=False`を維持する。
7. Gate Failureの`COperationResult`をそのまま返す。Snapshot/Carrier不正は既存`UnexpectedError`、Required/Type等は既存の分類を維持する。
8. `UserForm_Activate`の未構築`Me.Hide`ガード、二重Build防御、Clear/Mail作成ボタン無効化を維持する。

## 3. Source Evidence（読み取った実ソース）

| Artifact | SHA-256 |
|---|---|
| 親P3-04 XU-01 Form | `dfa70b8e4d3ede487c061bc82ac5be1ff0a7c2b0801c8899660da98a7d58a322` |
| 今回P3-04 XU-01 + XU-02 Form | `4fb506869d32ce8f7081b0b4a2678f511b452e770fe59d003bfa5feacb9f87df` |
| 無変更Controller | `87fdefe7f53b568e4c7d3df56884828a7647f51c91fa24a0f998ef9c86d9cd88` |

対象SourceはZIP内`SOURCE_MANIFEST.md`と一致する。既存Candidateへの上書きは行っていない。

## 4. Fixtureと静的検査

- **独立テスト：35ケース定義、未実行**。XU-01の27ケースを継承し、XU-02追加8ケースを設計。詳細は`P3-04_XU02_A_Test_Matrix_v0.1.md`。
- XU-02追加では、Source Row値／Option値を**Form生成後に変更**、元Collectionの削除後も描画値が変わらないこと、OptionGroup case mismatch、途中Row/Option破損、必須属性欠落などを検査予定。
- `verification/XU02_STATIC_AUDIT.json`：**62/62 PASS / FAIL=0**（構文・API・参照使用箇所・全件コピー順・Fixture定義・CP932/CRLF・正規化Diff一致等の**静的な検査結果のみ**）。
- 差分ファイル`XU02_UTF8_Normalized_Review_Diff_v0.1.patch`は**ソースレビュアー向けUTF-8 LF正規化Diff**であり、CP932/CRLF原本へ直接適用する配布Patchではない。正規化した使い捨てコピーで適用して同一ソースになることを検証した。
- VBA Compile、Designer Import、実UIイベント、35ケース実行は**NOT RUN / NOT VERIFIED**。

**注意：実行用VBA Project**では、TEST ONLY Stubの`PrepareUserFormLaunch`と本物のP3-03モジュールを同時ImportするとPublic関数が競合する。Runnerの旧Revisionとも混同しないこと。正規UserForm Designerの`.frx`は本Candidateから生成していない。

## 5. Risk / Issue Log

| ID | リスク／残件 | Status | 次の対応 |
|---|---|---|---|
| XU-02 | Formの元Mutable参照共有 | A案設計承認、Candidateソース作成。**REVIEW_REQUIRED** | 実機でCode/Fixtureを検証後にClosure判断 |
| XU-02-R1 | 元Carrierがコピー前に変更された場合 | OPEN / 制約 | Gateからコピーまでの順序・再入検証。Snapshotはコピー前の不変性を保証しない |
| XU-02-R2 | Testの事後書換えだけでは「コピー前の競合防止」は実証できない | OPEN / 制約 | 静的参照検査とRuntime挙動を分けて評価 |
| XU-01 | Public Builder Gate強制と直接Show非表示 | ソース候補維持、**Runtime NOT VERIFIED** | 別途検証。今回CLOSEしない |
| XU-03 | SortOrder `CDbl`受容差 | PATCH CANDIDATE（未適用） | 別作業で判断 |
| XU-04 | Cleanup二次Failure診断 | PATCH CANDIDATE（未適用） | 別作業で判断 |
| XU-05 | テストStubと本物P3-03のPublic名競合 | CONTROLLED / 混合Import禁止 | 隔離Fixtureのみ使用 |
| XU-06 | 追加ModuleのMapping | OPEN | Production採用前に判断 |
| XU-07 | `.frm/.frx`、VBE Import、Compile、UI表示 | NOT VERIFIED | 承認済み環境が整った後の別Gate |
| P3-05-INT | Input State保存・復元・ClearのForm接続 | DEFERRED / 対象外 | 今回のXU-02実装候補をレビュー後に別判断 |

## 6. Quality Gate

| Quality Gate | 判定 | 根拠 |
|---|---|---|
| XU-02 A案 Design Approval | **APPROVED** | ユーザー明示承認 |
| 最小修正Candidate作成 | **PASS** | Form／Stub／Runner／レビュー記録 |
| Static Source Audit | **PASS 62/62** | JSONログ（静的） |
| 保持すべきXU-01 Gate / Controller構造 | **PASS（ソース）** | `BuildValidatedInputs`→Gate、Controller無変更 |
| Verified Scalar Copy before Controls.Add | **PASS（ソース構造）** | 全件コピー完了後にBuildInputsFromSnapshot |
| VBA Import / Compile | **NOT VERIFIED** | 実機操作なし |
| 35 VBA Runtime Test Cases | **NOT RUN** | Fixture定義のみ |
| XU-02正式Closure | **REVIEW_REQUIRED** | Runtime Evidenceなし |
| P3-04 Production採用 | **NOT APPROVED** | 既存残件あり |
| P2 Closure / S5-C / P3 Phase開始 | **UNCHANGED** | 本作業の対象外 |

## 7. Decision Log／次工程

- **承認済み（ユーザー）**：XU-02 A案、P3-05の3 APIおよびString保存はP3-04接続Candidate用の契約。XU-01 A案は従前から承認済み。
- **今回作成した案**：Form内のPrivate `CreateDisplaySnapshot`と`BuildInputsFromSnapshot`へ処理分離した実装。ユーザー承認済みの設計方針を実装した**候補**であり、コードへの承認は未取得。
- **未決**：実機検証・XU-02 Closure、Input State接続用の終了方式とSelect失効値、XU-06 Module Mapping。既存のOpen項目を解決済みにはしない。
- **次工程（提案）**：XU-02ソースCandidateの差分レビュー→実機が別途可能になったときに隔離Fixture/Import/Compile→XU-02 Closure判断→P3-04×P3-05 UI接続候補。

## 8. 保存先（提案）

- Form／Controller候補：`MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/`
- Stub／Runner：`MailGenerator/tests/vba/P3_Configuration_UserForm/`
- レビュー／監査：`MailGenerator/Docs/00_project_control/reviews/`

**今回保存したのはローカル作業領域の成果物のみ。GitHub、Baseline、Productionには書き込んでいない。**

## まとめ / Summary

日本語：XU-02 A案をForm内Private Scalar Snapshotとして候補実装した。XU-01を維持し、Static AuditをPASSした。Runtime未実行なので正式Closure・Production採用は行わない。  
English: We prepared a private scalar snapshot inside the form. The XU-01 gate stays in place. Static checks passed. Runtime tests and production approval are still pending.
