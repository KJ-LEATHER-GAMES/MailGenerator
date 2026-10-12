# TF-P2-02-001 Core Test Local Name Collision Correction v0.1

## 1. Finding

`modP2_02SyncDiffCoreTest_v0.1_CP932.bas` のCompile時に以下を検出した。

```text
Compile Error:
配列がありません
```

代表箇所：

```vb
Dim T0 As Date
...
T0 = T0()
```

右辺の `T0()` にフォーカスする。

---

## 2. Root Cause

VBAの識別子は大文字・小文字を区別しない。

Test ModuleにはModule-level Functionとして、

```vb
Private Function T0() As Date
Private Function T1() As Date
```

が存在する一方、以下のCase内でLocal Variableとして、

```vb
Dim t0 As Date
Dim t1 As Date
```

を宣言していた。

対象：

```text
CaseC2_Existing
CaseC3_Reactivated
CaseC4_Unused
```

VBAでは `t0` と `T0` は同一Identifierであるため、Local VariableがModule-level Function名をshadowする。

その結果、

```vb
t0 = T0()
```

の右辺 `T0()` はFunction Callではなく、Local Variable `T0` に対する配列添字参照として解釈され、

```text
配列がありません
```

となった。

---

## 3. Classification

```text
Finding ID:
TF-P2-02-001

Classification:
Test Artifact Defect

Production Defect:
NONE

Requirement Gap:
NONE

Design Finding:
NONE

Production modSyncEngine Change:
NONE
```

---

## 4. Correction

Local Variable名のみ変更する。

```text
t0
→ firstDetectedAt

t1
→ lastDetectedAt
```

Module-level Fixture Function：

```vb
T0()
T1()
```

は変更しない。

対象Case：

```text
C2
C3
C4
```

---

## 5. Why This Correction

最小Correctionであり、

```text
Test semantics
Expected values
Production API
Production implementation
C1-C18 coverage
```

を変更しない。

Function `T0()` / `T1()` のGlobal RenameよりChange Surfaceが小さいため採用する。

---

## 6. Corrected Artifact

```text
modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas
```

---

## 7. Next Verification

旧v0.1 Test Moduleを削除またはImportしない。

```text
modP2_02SyncDiffCoreTest_v0.1_CP932.bas
→ Superseded for Test Execution
```

代わりに、

```text
modP2_02SyncDiffCoreTest_v0.1.1_CP932.bas
```

をImportし、

```text
Debug
→ Compile VBAProject
```

を再実行する。

Compile PASS後に、

```vb
TestP202SyncDiffCore
```

へ進む。
