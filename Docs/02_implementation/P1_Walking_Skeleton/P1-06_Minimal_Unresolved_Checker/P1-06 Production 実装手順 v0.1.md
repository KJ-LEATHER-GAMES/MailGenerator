# P1-06 Minimal Unresolved Checker Production 実装パッケージ v0.1

## 内容

- `modUnresolvedChecker_P1-06_v0.1_CP932.bas`
  - Production `modUnresolvedChecker`
- `modP1_06MinimalUnresolvedCheckerCoreTest_v0.1_CP932.bas`
  - Core Test C1～C8
- `modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1_CP932.bas`
  - Normal Integration
  - Missing Value Integration

## Import順

1. Workbookをバックアップ
2. VBEを開く
3. 既存の空Shell `modUnresolvedChecker` が存在する場合のみ削除
4. `modUnresolvedChecker_P1-06_v0.1_CP932.bas` をImport
5. Core Test ModuleをImport
6. Integration Test ModuleをImport
7. `Debug > Compile VBAProject`

既存Production Module
`modResult / modSettingsData / modTemplateScanner / modSubjectRenderer / modOutlookAdapter`
は変更しない。

## Verification順

### 1. Compile

```text
Debug > Compile VBAProject
```

Expected:

```text
PASS
```

### 2. Core

実行:

```vb
TestP106MinimalUnresolvedCheckerCore
```

Expected:

```text
C1 Unresolved 0: PASS
C2 Subject 1: PASS
C3 Body 1: PASS
C4 Subject Body Duplicate: PASS
C5 Case Insensitive: PASS
C6 Multiple Variables: PASS
C7 Empty Input: PASS
C8 Final Snapshot Token: PASS

TestP106MinimalUnresolvedCheckerCore: PASS
```

### 3. Normal Integration

実行:

```vb
TestP106UnresolvedZeroIntegration
```

Expected:

```text
HasUnresolved=False
Variables.Count=0
CloseWithoutSave=PASS
Normal Integration: PASS
```

### 4. Missing Value Integration

実行:

```vb
TestP106MissingValueIntegration
```

GateDateをFormattedValuesから意図的に除外する。

Expected:

```text
CheckUnresolved = Failure Result
HasUnresolved=True
Variables.Count=1
GateDate検出
CloseWithoutSave=PASS
Missing Value Integration: PASS
```

### 5. 全Integration

必要なら実行:

```vb
TestP106MinimalUnresolvedCheckerIntegration
```

## P1 Interim Error Mapping

未置換1件以上では現在の `CreateFailureResult()` Contractに合わせ、
Production Code上は `RenderError` を指定する。

これは **P1 Interim Mapping** であり、
`Unresolved = RenderError` を最終Error taxonomyとして固定するものではない。

正式なUnresolved Error分類 / Error Code / User-facing MessageはP6で最終化する。

## P1-06で実装しないもの

- DisplayMail
- Fail Closed E2E Orchestration
- User-facing未置換一覧UI
- Current Data Guard
- 正式Unresolved Error taxonomy
- COM Error / Lifecycle最終化

これらはP1-07 / P5 / P6の責務。
