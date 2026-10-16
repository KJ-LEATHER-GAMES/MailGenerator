# P05-I16 Fresh Retry 実施手順

## 1. 開始状態

P05-I07の結果を1回目Executionとして採用します。

```text
1st Execution:
P05-I07 Invalid Candidate

Fixture:
{{Bad-Name}}

Result:
COperationResult.Success = False
syncDiffResult = Nothing
Invalid Candidate表示あり
VariableDefinition変更なし

P05-I07 = PASS
```

したがって、**I16のためにInvalid Candidate Failureをもう一度発生させる必要はありません。**

---

## 2. 原因修正

OFTを開き、P05-I07で追加した、

```text
{{Bad-Name}}
```

を**削除**してください。

今回は別のValid Variableへ書き換えるより、Baselineへ戻すため削除を推奨します。

つまり、

```text
Baseline OFT
+ {{Bad-Name}}
```

から、

```text
Baseline OFT
```

へ戻します。

その後、**同じOFT Path / Filenameで保存**してください。

---

## 3. Automatic Retryが発生しないことを確認

OFTを保存したあと、まだ`RunManualSync`を実行しません。

数秒待って、

```text
Manual Sync結果MsgBoxが勝手に表示されない
VariableDefinitionが勝手に更新されない
```

ことを確認してください。

Expected：

```text
Automatic Retry = 0
Automatic Sync = 0
```

これはFresh Retryの重要な前提です。P2-05ではFailure後のAutomatic Retryは禁止されています。P2-05 Fail Closed - Sync Result…

---

# 4. 2回目ExecutionのRuntime Evidence

今回は、**Current State再取得 / Previous Result非再利用**のEvidenceを強くするため、Breakpointを使うことを推奨します。

## Step 1 — Breakpoint

`modUiController.RunManualSync`の、

```vb
ExecuteManualSync
```

呼出し直後にBreakpointを設定します。

P05-I07と同じ位置で構いません。

---

## Step 2 — User explicit action

次に初めて、

```text
Alt + F8
↓
RunManualSync
↓
Run
```

を実行します。

これがP05-I16の**2回目Manual Sync Execution**です。

---

## Step 3 — operationResult確認

Breakpoint停止後、Locals Windowで確認してください。

Expected：

```text
operationResult Is Nothing
→ False

operationResult.Success
→ True
```

P05-I07では、

```text
Success = False
```

でした。

今回、

```text
False
↓
原因修正
↓
新しいManual Sync
↓
True
```

となれば、Fresh Retryの主要Evidenceになります。

---

## Step 4 — syncDiffResult確認

Expected：

```text
syncDiffResult
→ Nothingではない
→ Object / Dictionary
```

P05-I07では、

```text
syncDiffResult = Nothing
```

でした。

今回はSuccess Contractに従い、新しく成立したSyncDiffResultが返ることを確認します。

---

## Step 5 — templateScanResult確認

Expected：

```text
templateScanResult
→ Exists
→ Object / Dictionary
```

可能なら、

```text
Keys:
ValidVariables
InvalidCandidates
Locations
```

まで確認してください。

### InvalidCandidatesについて

今回Baseline OFTへ戻しているため、Invalid Candidateが残っていてはいけません。

ただしLocals上でCollection内部まで確認できなくても、後続のSuccess結果とInvalid Candidate通知なしで補完可能です。

---

# 5. Current State再取得の判定

I16で最重要なのはここです。

P05-I07ではCurrent OFTに、

```text
{{Bad-Name}}
```

が存在していたためFailureしました。

その後OFTを変更し、

```text
{{Bad-Name}}
なし
```

にしています。

2回目Executionが、

```text
Success = True
```

になれば、

**2回目Executionが修正後のCurrent OFTを使用したことの実行Evidence**になります。

もしPrevious Scan Resultを再利用していたなら、前回の、

```text
Invalid Candidate
{{Bad-Name}}
```

を保持したままFailureするはずです。

したがって、

```text
1st:
{{Bad-Name}}あり
→ Failure

2nd:
{{Bad-Name}}削除済み
→ Success
```

という結果自体が、Fresh Current State acquisitionを強く支持します。

---

# 6. Previous Result非再利用の判定

今回の比較は非常に明確です。

### Previous Execution

```text
operationResult.Success = False
syncDiffResult = Nothing
Invalid Candidate = {{Bad-Name}}
```

### Fresh Retry

期待：

```text
operationResult.Success = True
syncDiffResult = Exists
Invalid Candidate Failure = なし
```

つまり、Previous Resultが再利用されていれば成立しない状態変化です。

この比較をEvidenceへ残します。

---

# 7. Success Notification確認

Breakpoint確認後、

```text
F5 / Continue
```

で続行してください。

Baseline OFTと現在のVariableDefinition状態から考えると、今回の期待結果はおそらく、

```text
テンプレート同期結果

新規 (0件)
なし

継続 (4件)
ModelName
GateDate
Department
Comment

復活 (0件)
なし

Unused化 (0件)
なし
```

です。

ただし、**P05-I16のPASS条件はこの具体的件数ではありません**。

I16では、

```text
現在状態が正常
→ Success
```

であることが主目的です。

したがって分類件数に予想外の差がある場合は、I16とは別にSync Classificationとして評価します。

---

# 8. Notification Count確認

Expected：

```text
2nd Execution:

Success Notification = 1
Failure Notification = 0
```

また、

```text
OFT修正時:
Automatic Notification = 0
```

も記録します。

---

# 9. VariableDefinition確認

2回目Manual Sync後にVariableDefinitionを確認します。

今回Baseline OFTに戻しているため、通常は、

```text
ModelName
GateDate
Department
Comment
```

の`LastDetectedAt`が今回のSyncTimestampへ更新される可能性があります。

これは**異常ではありません**。

P05-I07のFail Closed確認とは異なり、今回はSuccess Persistenceが実行されるためです。

したがってI16では、

```text
VariableDefinition Before = After
```

を要求してはいけません。

むしろ新しいCurrent Stateに基づいた正常Persistenceの結果として評価します。

---

# 10. PASS判定条件

以下を満たせばP05-I16 PASSです。

| Check | Expected |
|---|---|
| 1st Execution | P05-I07 Failure |
| Failure原因修正 | `{{Bad-Name}}`削除 |
| 修正時Automatic Retry | なし |
| 2nd Manual Sync | User explicit action |
| 2nd `COperationResult.Success` | `True` |
| 2nd `syncDiffResult` | Exists |
| 2nd `templateScanResult` | Exists |
| Previous Invalid Candidate Failure | 再利用されない |
| Current OFT | 修正後状態が反映 |
| Success Notification | 1 |
| Failure Notification | 0 |
| Unhandled Runtime Error | None |

---

# 11. 今回記録してほしい内容

実行後、こちらへ次の形式で結果を送ってください。

```text
P05-I16 — Fresh Retry

1st Execution:
P05-I07 PASS / Failure

Cause Correction:
{{Bad-Name}} deleted from OFT

OFT Saved:
Yes

Automatic Retry after Save:
None

VariableDefinition Automatic Change before Manual Sync:
None

2nd User Action:
Alt + F8
→ RunManualSync
→ Run

COperationResult.Success:
True / False

syncDiffResult:
Exists / Nothing

templateScanResult:
Exists / Nothing

Success Notification Count:
0 / 1 / Other

Failure Notification Count:
0 / 1 / Other

Displayed Result:
<表示内容>

Invalid Candidate Message Reappeared:
Yes / No

VariableDefinition after 2nd execution:
<確認結果>

Unhandled Runtime Error:
None / <内容>

Actual Result:
<補足>

Result:
未判定
```
