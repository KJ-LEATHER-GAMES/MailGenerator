# S5-B B2-02-F1-2：専用Windowsユーザー／Office・VBE利用条件 設計レビュー

## 目的

F1-READ-01のCOMPLETE_WITH_LIMITATIONSを引き継ぎ、B2-02-F1-2を既存Evidenceと公式製品仕様に基づいて机上レビューしてください。

今回承認するのはレビューのみです。

## 既存Evidence

```text
TargetPC: S5B-TestPC-01

WindowsEdition: Windows 11 Home
Evidence: USER_ATTESTED

CurrentWindowsUser: ADMINISTRATOR_USER_ATTESTED
DedicatedStandardUserExisting: NO_USER_ATTESTED

F1Read01Decision: COMPLETE_WITH_LIMITATIONS
CloneRootACLInheritance: ENABLED_USER_ATTESTED
CloneRootACEList: P01_TO_P04_ALL_ENTRIES_USER_ATTESTED
CommonPrincipalACEs: ABSENT_IN_ROOT_ACL_USER_ATTESTED

CodexSandboxUsers:
QueriedPrincipalType: LOCAL_GROUP_USER_ATTESTED
DirectMemberCount: 2
ACL_P01_SIDMatch: NOT_VERIFIED
TransitiveMembership: NOT_VERIFIED

ExistingOffice:
Product: Personal2019Retail_REPORTED
Architecture: 64BIT_REPORTED
VBE_DLL: PRESENT_REPORTED
DedicatedUserExcelAvailability: NOT_VERIFIED
DedicatedUserVBEAvailability: NOT_VERIFIED
CompileAvailability: NOT_VERIFIED
```

## 設計レビュー対象

1. 新規ローカル標準ユーザーを利用する設計の成立条件
2. AdministratorsおよびCodexSandboxUsersへの非所属を維持する設計
3. Production関連Clone、Workbook、Evidence Archiveのアクセス遮断条件
4. 既存Office 2019の専用ユーザーからの利用条件
5. Officeライセンス認証とVBE利用可否
6. セキュリティ設定を変更せずに安全なCompileを確認するための前提条件
7. Office 2019サポート終了の残留リスク
8. F1-3、F1-4、F1-5、AUTH-03、AUTH-05への依存関係

## レビュー原則

- 既存Evidenceと推論・公式仕様を区別する。
- 専用ユーザーの作成可能性を実効アクセス遮断の証明としない。
- Officeの既存インストールを専用ユーザーでの利用PASSとしない。
- VBE DLLの存在をVBA Compile PASSとしない。
- F1-READ-01の限定付き完了を維持する。
- Office 2019のサポート終了と動作不能を同一視しない。
- A＋C1の正式採用を行わない。
- UNKNOWNを無断でPASSへ変更しない。

## 報告事項

B2-02-F1-2の設計レビューとして以下を報告してください。

```text
DesignFeasibility:
DedicatedStandardUser: CANDIDATE / REVIEW_REQUIRED
ProductionResourceIsolation: NOT_VERIFIED
ExistingOfficeReuse: CANDIDATE / REVIEW_REQUIRED
DedicatedUserVBE: NOT_VERIFIED
VBACompile: NOT_VERIFIED
```

Risks:

- リスクID
- 内容
- 影響
- 後続確認ゲート

RemainingUnknowns:

- 必須確認事項
- 確認予定工程
- 必要な承認

```text
F1_2_ReviewDecision:
REVIEW_REQUIRED / DESIGN_REVIEW_COMPLETE_WITH_OPEN_CONDITIONS

C1OverallAssessment: C1_REVIEW_REQUIRED
IsolationMethodSelected: NONE
IsolationEstablished: NOT_VERIFIED
```

## 禁止事項

Windowsユーザー作成・切替、ACL変更、グループ所属変更、PowerShell/CMD実行、Excel/VBE起動、Office認証操作、ネットワーク変更、Fixture作成、Preflight、Workbook変更、Git操作、管理文書変更は禁止します。

既存Closure、S5-Aの限定付きEvidence、P05の21ケース、Finding／Observation、Baseline履歴を維持してください。

レビュー結果を報告して停止してください。F1-3～F1-5、AUTH-01～AUTH-06には進まないでください。
