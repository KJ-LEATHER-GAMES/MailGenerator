# TF-P1-06-001 P1-06 Integration Test Artifact Correction v0.1

## Correction

対象：

`modP1_06MinimalUnresolvedCheckerIntegrationTest`

変更対象はTest Artifactのみ。Production Codeは変更しない。

### Root Cause

P1-06 Integration Test内に直接記述していた日本語Fixture：

- Department = 品質部
- Comment = 確認お願いします

がImport環境で文字化けし、Fixture Lengthがそれぞれ3→6、8→13へ変化した。

### Correction

日本語String Literalを直接埋め込まず、`ChrW()`でBaseline値を生成する。

さらにFixture生成直後に以下をGuardする。

```text
Department Len = 3
Comment Len    = 8
```

一致しなければTestをFAILさせる。

### Production Impact

```text
modUnresolvedChecker:
NO CHANGE

modSubjectRenderer:
NO CHANGE

modOutlookAdapter:
NO CHANGE

Other Production Modules:
NO CHANGE
```

## Import

既存：

`modP1_06MinimalUnresolvedCheckerIntegrationTest`

を削除し、

`modP1_06MinimalUnresolvedCheckerIntegrationTest_v0.1.1_CP932.bas`

をImportする。

同名Moduleを残したままImportしない。

その後：

```text
Debug > Compile VBAProject
```

を実行する。

## Re-run

### Normal

```vb
TestP106UnresolvedZeroIntegration
```

確認ポイント：

```text
Fixture Department Len=3
Fixture Comment Len=8
Body Length(post)=202  （現在のBaseline OFTでの期待Evidence）
HasUnresolved=False
Variables.Count=0
Normal Integration: PASS
```

### Missing Value

```vb
TestP106MissingValueIntegration
```

確認ポイント：

```text
Fixture Department Len=3
Fixture Comment Len=8
Body Length(post)=206  （GateDateがBodyで2箇所残る場合の期待Evidence）
HasUnresolved=True
Variables.Count=1
Variable[1]=GateDate
Missing Value Integration: PASS
```

Body Length 202 / 206は今回のBaseline Fixtureに対する診断上の期待値であり、
Unresolved CheckerのPublic Contractそのものではない。
