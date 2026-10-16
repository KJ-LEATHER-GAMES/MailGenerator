# P05-I07 Invalid Candidate 詳細実施手順書 v0.1

## 1. 目的

P2-05 Production実装に対して、OFTテンプレート内に命名規則違反のVariable Candidateが存在する場合に、Manual SyncがFail Closedし、VariableDefinitionを変更せず、検出したInvalid Candidateを利用者へ通知できることを確認する。

本確認は **P2-05 Implementation Verification** であり、Formal MVP Test PASSはClaimしない。

---

## 2. Test Case

| 項目                  | 内容                         |
| ------------------- | -------------------------- |
| Test ID             | P05-I07                    |
| Test名               | Invalid Candidate          |
| 対象Entry             | `RunManualSync`            |
| Application Entry   | `ExecuteManualSync`        |
| Fixture             | OFTへInvalid Candidateを1件追加 |
| 推奨Invalid Candidate | `{{Bad-Name}}`             |
| Expected Result     | Failure / Fail Closed      |
| Production Code変更   | NONE                       |

---

## 3. 確認するContract

Invalid Candidate時に以下が成立することを確認する。

```text
COperationResult.Success = False

syncDiffResult = Nothing

templateScanResult
= Current TemplateScanResult

templateScanResult("InvalidCandidates")
にInvalid Candidateが保持される

VariableDefinition更新 = 0

Success Notification = 0

Failure Notification = 1
```

UIでは少なくとも、

```text
{{Bad-Name}}
```

がInvalid Candidateとして識別可能であることを確認する。

---

## 4. Test Fixture

### 4.1 OFT変更前

現在使用しているProduction Test OFTを使用する。

例：

```text
Templates\MailTemplate.oft
```

Test開始前に、元のOFTを復元可能な状態にしておく。

Productionコード、Settings、VariableDefinitionの設定値は変更しない。

### 4.2 Invalid Candidate追加

OFT本文の末尾など、既存Variableへの影響が少ない位置へ以下を1件追加する。

```text
{{Bad-Name}}
```

`-` はVariableName命名規則外のためInvalid Candidateとなる。

既存のValid Variableは削除・変更しない。

### 4.3 推奨Fixture

```text
既存OFT
+
{{Bad-Name}} 1件
```

Invalid Candidateを複数追加しない。

P05-I07では1件だけにして、Failure原因を単純化する。

---

# 5. Test前Evidence取得

## Step 1 — OFT変更前状態を記録

以下を記録する。

```text
OFT Path:
<実際のPath>

Invalid Candidate追加前:
{{Bad-Name}} = なし
```

必要に応じて元OFTをBackupする。

---

## Step 2 — VariableDefinition Beforeを記録

`tblVariableDefinition` のTest前状態を記録する。

最低限確認対象：

```text
VariableName
DisplayName
Type
Required
Description
OptionSource
SortOrder
Format
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

特に後で比較できるよう、

```text
行数
VariableName
TemplateLocation
Status
FirstDetectedAt
LastDetectedAt
```

は必ず確認できる状態にする。

Screenshotでもよいが、値を比較可能なEvidenceを残す。

---

# 6. Fixture設定

## Step 3 — OFTへInvalid Candidateを追加

対象OFTを編集する。

本文末尾などへ、

```text
{{Bad-Name}}
```

を追加する。

OFTを**元と同じPath / Filename**で保存する。

---

## Step 4 — Fixture確認

Manual Sync実行前に、

```text
OFTに {{Bad-Name}} が存在する
```

ことを確認する。

この時点ではManual Syncをまだ実行しない。

---

# 7. Runtime Verification

## Step 5 — 必要に応じてVBE Breakpointを設定

Carrierまで直接Evidence化したい場合は、`modUiController.RunManualSync`内の、

```vb
ExecuteManualSync
```

呼出し直後の行へBreakpointを設定する。

Productionコード自体は変更しない。

これによりManual Sync実行中に、

```text
operationResult
syncDiffResult
templateScanResult
```

をLocals / Watchで確認できる。

Breakpointを使用しない場合でも、UI結果とVariableDefinition Before / AfterによるP05-I07確認は継続する。

---

## Step 6 — Manual Syncを1回だけ実行

Excelから、

```text
Alt + F8
↓
RunManualSync
↓
実行
```

とする。

**1回だけ実行する。**

自動Retryや追加Manual Syncは行わない。

---

# 8. Carrier確認

Breakpointを設定した場合は以下を確認する。

## Step 7 — COperationResult

```text
operationResult Is Nothing
→ False

operationResult.Success
→ False
```

Expected：

```text
PASS
```

---

## Step 8 — syncDiffResult

確認：

```text
syncDiffResult Is Nothing
→ True
```

Expected：

```text
PASS
```

Invalid Candidate検出後にSyncDiffResultが生成されていてはいけない。

---

## Step 9 — templateScanResult

確認：

```text
templateScanResult Is Nothing
→ False
```

Expected：

```text
PASS
```

---

## Step 10 — InvalidCandidates

`templateScanResult` 内の、

```text
InvalidCandidates
```

を確認する。

Expected：

```text
Count = 1
```

内容：

```text
{{Bad-Name}}
```

Expected：

```text
PASS
```

確認後、

```text
F5 / Continue
```

で処理を継続する。

---

# 9. UI Verification

## Step 11 — Failure Notificationを確認

表示されたModal Notificationを確認する。

期待する意味：

```text
テンプレート内に
命名規則違反の変数記法が存在する

同期は実行されていない

対象として
{{Bad-Name}}
を識別可能
```

代表的な期待イメージ：

```text
テンプレート内に命名規則違反の変数記法があります。
同期は実行されませんでした。

対象
{{Bad-Name}}
```

文言の完全一致は要求しない。

ただし、

```text
{{Bad-Name}}
```

が利用者から識別できなければFAILとする。

---

## Step 12 — Notification Count確認

1回の`RunManualSync`に対して、

```text
Failure Notification = 1
```

を確認する。

以下はFAIL：

```text
Failure Notification
+
Success Notification
```

または、

```text
Failure MsgBox
+
別のResult MsgBox
```

のような二重通知。

---

## Step 13 — Success Notificationがないことを確認

以下のSuccess Resultが表示されないことを確認する。

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

# 10. VariableDefinition Fail Closed確認

## Step 14 — VariableDefinition Afterを確認

Manual Sync終了後、`tblVariableDefinition`を確認する。

Test前Evidenceと比較する。

Expected：

```text
追加行 = 0
削除行 = 0
Status変更 = 0
TemplateLocation変更 = 0
FirstDetectedAt変更 = 0
LastDetectedAt変更 = 0

User Configuration変更 = 0
```

つまり、

```text
VariableDefinition Before
=
VariableDefinition After
```

であることを確認する。

特に、

```text
Bad-Name
```

または類似したVariableDefinition行が新規作成されていてはいけない。

---

# 11. PASS / FAIL判定

以下をすべて満たした場合のみP05-I07をPASSとする。

| Check                       | Expected       |
| --------------------------- | -------------- |
| Manual Sync Result          | Failure        |
| `COperationResult.Success`  | `False`        |
| `syncDiffResult`            | `Nothing`      |
| `templateScanResult`        | Exists         |
| `InvalidCandidates.Count`   | `1`            |
| Invalid Candidate           | `{{Bad-Name}}` |
| Invalid Candidate UI表示      | PASS           |
| Failure Notification        | 1回             |
| Success Notification        | 0回             |
| VariableDefinition追加        | 0              |
| VariableDefinition更新        | 0              |
| Unhandled VBA Runtime Error | なし             |

1項目でもExpectedを満たさない場合、

```text
P05-I07 = FAIL
```

としてFinding Assessmentへ移行する。

---

# 12. Evidence Record

実行後、以下の形式で記録する。

```text
P05-I07 — Invalid Candidate

Execution Date:
YYYY-MM-DD

Production Entry:
RunManualSync

Fixture:
OFTへ {{Bad-Name}} を1件追加

Initial OFT:
Baseline OFT + {{Bad-Name}}

Initial VariableDefinition:
<Before状態>

User Action:
Alt + F8
→ RunManualSync
→ Run

COperationResult.Success:
False

syncDiffResult:
Nothing

templateScanResult:
Exists

InvalidCandidates:
Count = 1

Invalid Candidate:
{{Bad-Name}}

Displayed Invalid Candidate:
{{Bad-Name}}

Failure Notification Count:
1

Success Notification Count:
0

VariableDefinition Added:
0

VariableDefinition Updated:
0

Unhandled Runtime Error:
None

Actual Result:
<実測結果>

Result:
PASS / FAIL
```

---

# 13. WordEditor E_FAIL再発時

P05-I07実行途中で、

```text
Unable to access WordEditor
-2147467259
```

等の既知のWordEditor E_FAILが再発した場合は、**P05-I07 FAILとは即判定しない**。

そのExecutionではInvalid Candidate Branchまで到達していないため、

```text
P05-I07:
NOT COMPLETED
```

として扱う。

既存Observation、

```text
OBS-P2-05-002
Intermittent WordEditor E_FAIL
```

のReopen条件に該当する可能性があるため、そのSessionを壊さず、既定のDiagnostic手順へ切り替える。

OFTやProduction Codeを追加変更してI07を無理に続行しない。

---

# 14. Test終了時のFixture取扱い

P05-I07がPASSしたら、Evidenceを確定するまでOFTを変更しない。

Evidence確定後、次に

```text
P05-I16 — Fresh Retry
```

を連続実施する場合は、

```text
{{Bad-Name}}
```

を修正・削除する操作そのものをI16の「Failure原因修正」として使用する。

したがって、

```text
I07 PASS
↓
Evidence確定
↓
{{Bad-Name}} 修正
↓
自動Retryなし確認
↓
Userが再度RunManualSync
↓
I16
```

と進める。

I16を直後に実施しない場合のみ、OFTをBaseline状態へ復元してTestを終了する。

---

# 15. Done When

```text
P05-I07 Expectedを全件確認

Invalid CandidateをUserが識別可能

Failure Notification = 1

Success Notification = 0

VariableDefinition Before = After

syncDiffResult = Nothing
（直接確認または既存Contract Evidenceとの組合せ）

Production Code Change = NONE

PASS / FAIL記録完了
```

以上を満たした時点でP05-I07 Verificationを終了する。
