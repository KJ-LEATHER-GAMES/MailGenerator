# P1-07 Display / E2E Integration Production 実装手順 v0.1

## 1. 対象

Approved:

- `P1-07 Display / E2E Integration 実施仕様 v0.1`

Production変更:

- 新規 `modMailApplication`
- `modOutlookAdapter` をP1-07統合版へ差し替え

既存の以下は変更しない。

- `modSettingsData`
- `modTemplateScanner`
- `modSubjectRenderer`
- `modUnresolvedChecker`
- `modResult`
- `COperationResult`
- `CErrorInfo`

---

## 2. ファイル

### 新規

`modMailApplication_P1-07_v0.1_CP932.bas`

Production Entry Point:

```vb
Public Function CreateMailForDisplay( _
    ByVal formattedValues As Object, _
    ByRef unresolvedResult As Object _
) As COperationResult
```

### 差し替え

`modOutlookAdapter_P1-07_v0.1_CP932.bas`

P1-05統合版を維持し、以下だけを追加する。

```vb
Public Function DisplayMail() As COperationResult
```

---

## 3. Import手順

### 3.1 Backup

現在のWorkbookを別名保存する。

### 3.2 modOutlookAdapter差し替え

VBEで既存：

```text
modOutlookAdapter
```

を削除する。

削除時に「エクスポートしますか」と聞かれた場合、既にBackup済みなら任意。

次に：

```text
modOutlookAdapter_P1-07_v0.1_CP932.bas
```

をImportする。

同名Moduleを残したままImportしない。

### 3.3 modMailApplication追加

```text
modMailApplication_P1-07_v0.1_CP932.bas
```

をImportする。

AttributeによりModule名は：

```text
modMailApplication
```

となる。

---

## 4. Compile Gate

VBE:

```text
Debug
→ Compile VBAProject
```

Expected:

```text
Compile Error:
NONE
```

Compileが通らない場合、Runtime Verificationへ進まない。

---

## 5. Production Flow

```text
CreateMailForDisplay
↓
GetSettingValue("TemplatePath")
↓
ResolveWorkbookRelativePath
↓
CreateMailFromTemplate
↓
ReadSubject / ReadBodyText
↓
ScanTemplate
↓
InvalidCandidates = 0
↓
RenderSubject
↓
SetSubject
↓
ReplaceBodyVariables
↓
ReadSubject / ReadBodyText
↓
CheckUnresolved
↓
Display Gate
├─ Success + HasUnresolved=False + Variables.Count=0
│    ↓
│  DisplayMail
│
└─ その他
     ↓
   No Display
     ↓
   CloseWithoutSave
```

---

## 6. DisplayMail実装

`DisplayMail()` は、

```text
Active mMailItem確認
↓
mMailItem.Display
↓
Adapter-held mMailItem referenceをNothing
↓
Success
```

とする。

以下は行わない。

```text
Send
Save
Close
```

Display失敗時は`mMailItem`を保持し、Application側が`CloseWithoutSave()`を試行できる状態を残す。

---

## 7. Display Gate

Production Codeは`ErrorType="RenderError"`を参照しない。

Display許可条件：

```text
CheckUnresolved.Success = True
AND
unresolvedResult exists
AND
HasUnresolved = False
AND
Variables.Count = 0
```

Unresolved Failure:

```text
Success = False
AND
HasUnresolved = True
AND
Variables.Count >= 1
```

の場合：

```text
DisplayMail:
NOT CALLED

Variables:
PRESERVED

CloseWithoutSave:
CALLED
```

---

## 8. Cleanup

MailItem生成前のFailure:

```text
CloseWithoutSave:
NOT CALLED
```

MailItem生成後、Display成功前のFailure:

```text
CloseWithoutSave:
CALLED
```

Display成功後:

```text
CloseWithoutSave:
NOT CALLED
```

Cleanup Failure時はOverall Failureとし、成功扱いしない。

P1-07ではPrimary Error / Cleanup Errorの最終統合方式を確定しない。P6へ残す。

---

## 9. Static Review結果

生成Artifactに対し以下を確認済み。

```text
modMailApplication:
- Outlook / Word COM直接参照なし
- .Sendなし
- ErrorType="RenderError"分岐なし
- Display Gateあり
- Unresolved Variables保持
- Failure Cleanupあり

modOutlookAdapter:
- P1-05 API維持
- DisplayMail追加
- DisplayMail内.Sendなし
- DisplayMail内.Saveなし
- DisplayMail内.Closeなし
- Display Failure時mMailItem保持
```

これはStatic Reviewであり、VBA Compile / Runtime PASSを代替しない。

---

## 10. Verification前提

Production Import + Compile後、次工程で少なくとも以下を確認する。

```text
Warm Start Normal E2E
Cold Start Normal E2E
Unresolved Fail Closed
No Auto Send
Draft / Inspector Lifecycle
P1-01～P1-06 Regression
```

この結果はImplementation VerificationでありFormal MVP Test Resultではない。
