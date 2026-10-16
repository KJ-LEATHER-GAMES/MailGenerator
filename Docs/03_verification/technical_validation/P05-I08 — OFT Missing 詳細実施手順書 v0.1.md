# P05-I08 — OFT Missing 詳細実施手順書 v0.1

## 1. 目的

設定されているOFTファイルが存在しない場合に、Manual Syncが正常系へ進まず、**Fail Closed**することを確認する。

確認対象：

```text
OFT Missing
↓
ExecuteManualSync Failure
↓
Success Notification禁止
↓
Failure Notification
↓
VariableDefinition変更なし
↓
Stop
```

本確認は**P2-05 Implementation Verification**であり、Formal MVP Test PASSはClaimしない。

---

## 2. Test Case

| 項目 | 内容 |
|---|---|
| Test ID | `P05-I08` |
| Test Name | OFT Missing |
| Production Entry | `RunManualSync` |
| Application Entry | `ExecuteManualSync` |
| Fixture | 設定されたOFT実体を一時的に不存在にする |
| Expected Result | Failure / Fail Closed |
| Production Code変更 | **NONE** |
| Settings変更 | **NONE推奨** |
| VariableDefinition変更 | **NONE** |

---

# 3. Verification Contract

Specification上の必須Expected：

```text
Failure Notification

Success Notification = 0

Sync EngineへUIから進めない

VariableDefinition更新 = 0
```

P2-05 Fail Closed - Sync Result…

さらにFail Closed Ruleとして、Failure時にはSuccess Notificationを禁止し、UIから`BuildSyncDiff` / `ApplySyncDiff`を再呼出しせず、VariableDefinitionを直接変更せず、自動Retryもしないことが定義されています。P2-05 Fail Closed - Sync Result…

---

# 4. Fixture方針

## 推奨：OFTの一時リネーム

今回は**SettingsのOFT Pathは変更しません**。

現在のOFT：

```text
MailTemplate.oft
```

を一時的に、

```text
MailTemplate.oft.P05-I08
```

などへ変更します。

これにより、

```text
Settings:
変更なし

Configured Path:
MailTemplate.oft

実ファイル:
存在しない
```

という純粋な「OFT Missing」状態を作れます。

### この方法を推奨する理由

Settingsそのものを書き換えると、

```text
OFT Missing
```

だけでなく、

```text
Settings変更
Path設定誤り
Path Resolver問題
```

までFixtureに混ざります。

P05-I08では**ファイル不存在だけを1変数として操作する**方がEvidenceとして明確です。

---

# 5. Test前準備

## Step 1 — 現在のOFT Pathを確認

Settingsで現在指定されているOFTを確認します。

記録：

```text
Configured OFT:
<現在の設定値>

Resolved / Actual OFT:
<現在使用中のOFT>
```

通常のManual Syncで使用しているOFTであることだけ確認してください。

**Settings値は変更しません。**

---

## Step 2 — Baseline OFTの存在確認

エクスプローラー等で、

```text
MailTemplate.oft
```

が存在していることを確認します。

この段階ではまだリネームしません。

---

## Step 3 — VariableDefinition Beforeを記録

現在の`VariableDefinition`をEvidenceとして保存します。

P05-I16直後なので、現在はおそらくActive変数の`LastDetectedAt`が最新時刻になっています。

最低限、以下を確認します。

```text
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

特に今回重要なのは、

```text
LastDetectedAt
Status
Row Count
```

です。

OFT Missing Failure後にこれらが変化していないことを確認します。

---

# 6. OFT Missing Fixture設定

## Step 4 — Excel / Outlook側でOFTを使用中でないことを確認

開いているOFT編集ウィンドウがあれば閉じます。

Draftとして開いている場合も閉じてください。

---

## Step 5 — OFTを一時リネーム

例：

```text
Before:
MailTemplate.oft

After:
MailTemplate.oft.P05-I08
```

重要なのは、**Configured Pathが指す元ファイル名を不存在にすること**です。

元ファイルを削除する必要はありません。

### 禁止

```text
Delete
上書き
内容変更
Settings Path変更
```

今回は不要です。

---

## Step 6 — Fixture成立確認

エクスプローラー等で、

```text
Configured OFT Path:
MailTemplate.oft

Actual:
存在しない
```

ことを確認します。

一方、

```text
MailTemplate.oft.P05-I08
```

としてBackup実体が存在することも確認してください。

---

# 7. Automatic Execution確認

P05-I16と同じく、OFTをリネームしただけではManual Syncが自動実行されないことも確認しておくとEvidenceが強くなります。

数秒待ち、

```text
MsgBoxなし
VariableDefinition変更なし
```

を確認します。

Expected：

```text
Automatic Manual Sync = 0
```

これはP05-I08の中心Expectedではありませんが、P2-05のManual Only / Automatic Execution Prohibitionとの整合Evidenceになります。

---

# 8. Runtime Verification

## Step 7 — Breakpoint設定

P05-I07 / I16と同じく、

```vb
RunManualSync
```

内の、

```vb
ExecuteManualSync
```

呼出し直後へBreakpointを設定してください。

Production Codeは変更しません。

---

## Step 8 — Manual Syncを1回実行

Excelから、

```text
Alt + F8
↓
RunManualSync
↓
Run
```

を実行します。

**1回だけ実行します。**

---

# 9. Carrier確認

## Step 9 — COperationResult

Locals Windowで確認します。

Expected：

```text
operationResult Is Nothing
→ False

operationResult.Success
→ False
```

### Error情報

可能であれば、

```text
ErrorType
Message
Target
```

も記録してください。

ただしP05-I08では**Error文言の完全一致は要求しません**。

P2-05はFinal Error MappingをP6へ残しており、既存`COperationResult / CErrorInfo`のMessage / TargetをBasic UIへ接続する仕様だからです。

---

## Step 10 — syncDiffResult

Expected：

```text
syncDiffResult
= Nothing
```

OFT取得段階でFailureしているため、そのExecutionがSuccess用SyncDiffResultを返していてはいけません。

P2-04 Other Failure ContractでもFailure時は`syncDiffResult = Nothing`です。P2-05 Fail Closed - Sync Result…

---

## Step 11 — templateScanResult

ここは**値を決め打ちしません**。

確認した実測値を記録します。

```text
templateScanResult:
Nothing
```

または、実装上成立済みObjectが返るならその状態を記録します。

SpecificationではOther Failure時の`templateScanResult`はFailure Stageにより、

```text
Nothing
```

または、

```text
成立済みCurrent TemplateScanResult
```

となり得るためです。P2-05 Fail Closed - Sync Result…

したがって、**P05-I08のPASS条件にtemplateScanResultの特定値を追加しません。**

---

# 10. UI Verification

## Step 12 — Failure Notification確認

Breakpointから、

```text
F5 / Continue
```

で進めます。

Expected：

```text
Failure Notification = 1
```

内容は、OFT取得・テンプレート取得等に失敗したことを識別できるBasic Failureであればよいです。

例えば実装によっては、

```text
テンプレート同期に失敗しました。

<既存Error Message>

確認対象:
<既存Target>
```

のようになります。

### 必ず記録するもの

表示されたMessageを**そのまま転記またはScreenshot保存**してください。

---

## Step 13 — Success Notificationなし確認

以下が表示されてはいけません。

```text
テンプレート同期結果

新規 (...)
継続 (...)
復活 (...)
Unused化 (...)
```

Expected：

```text
Success Notification = 0
```

---

## Step 14 — Notification Count

1回のManual Syncに対して、

```text
Failure Notification = 1
Success Notification = 0
```

を確認します。

以下ならFAILです。

```text
Failure
+
Success
```

あるいは、

```text
Failure MsgBox
+
別Failure MsgBox
```

のような不必要な二重通知。

---

# 11. VariableDefinition Fail Closed確認

## Step 15 — VariableDefinition After確認

Manual Sync終了後、VariableDefinitionを確認します。

Before / Afterを比較します。

Expected：

```text
Added Row = 0
Deleted Row = 0

Status Change = 0
TemplateLocation Change = 0

FirstDetectedAt Change = 0
LastDetectedAt Change = 0

User Configuration Change = 0
```

今回の重要ポイントは**LastDetectedAtも変化してはいけない**ことです。

P05-I16はSuccessだったためLastDetectedAt更新が正常でした。

P05-I08はFailureなので、

```text
LastDetectedAt更新なし
```

である必要があります。

つまり、

```text
VariableDefinition Before
=
VariableDefinition After
```

を確認します。

---

# 12. 「Sync EngineへUIから進めない」の確認方法

ここは少し注意が必要です。

Specification上のP05-I08 Expectedには、

```text
Sync EngineへUIから進めない
```

があります。P2-05 Fail Closed - Sync Result…

ただし、これをRuntimeだけで証明するために、

```text
BuildSyncDiffへBreakpoint追加
ApplySyncDiffへBreakpoint追加
Test Hook追加
Productionログ追加
```

まで行う必要はありません。

すでにStatic / Source Reviewでは、

```text
UI
→ ExecuteManualSync
```

のみをApplication Entryとし、UIから`BuildSyncDiff`や`ApplySyncDiff`を直接呼ばないContractが固定されています。P2-05 Fail Closed - Sync Result…

今回のRuntime Evidenceとして、

```text
OFT Missing
+
Success=False
+
syncDiffResult=Nothing
+
VariableDefinition変更なし
```

を確認し、

既存Source Evidence：

```text
UIからBuildSyncDiff直接Callなし
UIからApplySyncDiff直接Callなし
```

と組み合わせれば十分です。

**このためだけにProduction Codeへ観測用コードを追加しません。**

---

# 13. PASS / FAIL判定

以下を確認します。

| Check | Expected |
|---|---|
| Configured OFT | 不存在 |
| User Action | 明示Manual Sync |
| `COperationResult.Success` | `False` |
| `syncDiffResult` | `Nothing` |
| Failure Notification | 1 |
| Success Notification | 0 |
| VariableDefinition Added | 0 |
| VariableDefinition Updated | 0 |
| LastDetectedAt Change | 0 |
| Unhandled Runtime Error | None |
| UI direct Sync Engine invocation | なし（Source Evidence併用） |

すべて満たせば、

```text
P05-I08
PASS
```

と判定できます。

---

# 14. 想定外結果の扱い

## A. Successになった

```text
COperationResult.Success = True
```

なら**FAIL候補**です。

Configured OFTが本当に不存在だったか確認してからFinding Assessmentへ進みます。

---

## B. VariableDefinitionが更新された

例えば、

```text
LastDetectedAt changed
Status changed
```

なら**Fail Closed違反の可能性**があります。

P05-I08はFAIL候補として扱います。

---

## C. VBA Runtime Errorで停止

User-facing Failure Resultではなく、

```text
Unhandled Runtime Error
```

でVBAが停止した場合はFAIL候補です。

P05-I08 ExpectedにはFail ClosedされたFailure Notificationが必要です。

---

## D. WordEditor E_FAIL

今回Configured OFTが本当に不存在であるにもかかわらず、

```text
Unable to access WordEditor
-2147467259
```

へ進んだ場合は、**即P05-I08 PASSにはしません**。

OFT Missing Boundaryより後段へ進んだ可能性があるため、

```text
P05-I08 = NOT COMPLETED / INVESTIGATE
```

としてFixture・実行経路を確認します。

---

# 15. Fixture復元

P05-I08 Evidenceを確定した後、

```text
MailTemplate.oft.P05-I08
```

を、

```text
MailTemplate.oft
```

へ戻します。

**Settingsは変更していないため、ファイル名復元だけでBaseline状態へ戻ります。**

復元後に、

```text
Configured OFT exists
```

を確認します。

この時点では、確認のためだけにManual Syncを実行する必要はありません。

次のVerification Fixtureにそのまま進めます。

---

# 16. Evidence Record Template

実行後は、以下を送ってください。

```text
P05-I08 — OFT Missing

Execution Date:
YYYY-MM-DD

Production Entry:
RunManualSync

Fixture:
Configured OFT file temporarily renamed

Configured OFT:
<filename / path>

Missing State Confirmed:
Yes

Settings Changed:
No

Initial VariableDefinition:
Before screenshot参照

Automatic Sync after OFT rename:
None

VariableDefinition Automatic Change:
None

User Action:
Alt + F8
→ RunManualSync
→ Run

COperationResult.Success:
False / True

COperationResult ErrorType:
<実測>

COperationResult Message:
<実測>

COperationResult Target:
<実測>

syncDiffResult:
Nothing / Exists

templateScanResult:
Nothing / Exists

Failure Notification Count:
0 / 1 / Other

Success Notification Count:
0 / 1 / Other

Displayed Failure:
<表示内容>

VariableDefinition Added:
0 / Other

VariableDefinition Updated:
0 / Other

LastDetectedAt Changed:
No / Yes

Unhandled Runtime Error:
None / <内容>

OFT Restored:
Yes / Not Yet

Actual Result:
<補足>

Result:
未判定
```

SpecificationではP2-05 EvidenceとしてInitial Template State、Initial VariableDefinition State、User Action、`COperationResult.Success`、Carrier存在、Failure Message、VariableDefinition Before/After、Notification Count、Actual Result、PASS/FAILを記録することが求められています。P2-05 Fail Closed - Sync Result…

---

# 17. 今回の最短実施フロー

実際には次の順番で十分です。

```text
① VariableDefinition BeforeをScreenshot

② MailTemplate.oft
   ↓ rename
   MailTemplate.oft.P05-I08

③ 元Filenameが不存在であること確認

④ 自動通知・自動更新なし確認

⑤ RunManualSync呼出直後にBreakpoint

⑥ Alt+F8
   → RunManualSync

⑦ Locals確認
   Success=False
   syncDiffResult=Nothing
   Error情報記録

⑧ F5

⑨ Failure MsgBoxをScreenshot

⑩ VariableDefinition AfterをScreenshot
    Beforeと変更なし確認

⑪ Evidence確定

⑫ OFT Filenameを元へ復元
```
