# Codex指示：S5-B 初回個別承認案の最終レビュー

添付の「S5-B 初回個別承認依頼案（AUTH-04-PRECHECK-01）」をレビューしてください。

## 前提

- 基準Build：`E-P204-WB`（採用済み）
- PC一般調査：`CLOSED_WITH_LIMITATIONS`
- A＋C1方式：推奨候補、正式選定前
- `AUTH-04-PRECHECK-01`：`NOT_GRANTED`
- コピー作成・PC変更・Excel/VBE起動・Compile：未承認

## 今回の作業

**既存Evidenceと提案内容の机上レビューのみ実施してください。**

1. 3つの確認事項について、既存Evidenceで判断できる内容を整理する。
2. 新たなPC確認が本当に必要な項目だけを抽出する。
3. Codexが実施可能な確認と、ユーザーによるGUI操作が必要な確認を区別する。
4. A＋C1方式の成立を妨げる設計上の条件を確認する。
5. 最初の個別承認対象について、最小の操作範囲・STOP条件・必要Evidenceを提示する。

## 禁止事項

- 新たなPC調査・OSコマンド・スクリプト実行
- ファイル・フォルダーの作成、コピー、変更
- Windows設定・ACL・ネットワークの変更
- Excel／VBE／Outlook起動、Compile
- Git操作
- Approved仕様・Baseline・過去Evidenceの変更

## 出力

- `REVIEW_RESULT`: READY_FOR_USER_APPROVAL / REVISION_REQUIRED / BLOCKED
- `EXISTING_EVIDENCE_SUFFICIENT`: 該当項目
- `MINIMUM_ADDITIONAL_CHECKS`: 本当に必要な項目
- `FIRST_AUTHORIZATION_SCOPE`: 最小の承認範囲
- `RESIDUAL_RISKS`: 未解決事項
- `NEXT_ACTION`: 1つだけ提示

**レビュー結果を報告した時点で停止してください。ユーザーの個別承認なしに実機操作へ進まないでください。**
