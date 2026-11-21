# P3-04 XU-02 A Candidate Source Manifest v0.1

| 管理項目 | 内容 |
|---|---|
| Revision | v0.1 |
| 作成日 | 2026-11-21 |
| Status | CANDIDATE / NOT APPLIED |
| Execution Baseline | BL-MVP-004（変更なし） |
| Parent Form SHA-256 | `dfa70b8e4d3ede487c061bc82ac5be1ff0a7c2b0801c8899660da98a7d58a322` |
| Parent Controller SHA-256 | `87fdefe7f53b568e4c7d3df56884828a7647f51c91fa24a0f998ef9c86d9cd88` |
| New Form SHA-256 | `4fb506869d32ce8f7081b0b4a2678f511b452e770fe59d003bfa5feacb9f87df` |
| Static Source Audit | 62/62 PASS、VBA Runtime NOT RUN |

## 収録ファイル

| ZIP内相対Path | Size (bytes) | SHA-256 |
|---|---:|---|
| `00_README.md` | 3,761 | `2653bda05bbeadd3154f6adef58f918c437a0b98a9b073fb00c1edd2af078d4c` |
| `docs/P3-04_XU02_A_Minimal_Change_Source_Review_v0.1.md` | 10,934 | `694cbf983244d37c1c6185986859232080e5151dd7243a443190adb144400c1b` |
| `docs/P3-04_XU02_A_Test_Matrix_v0.1.md` | 6,553 | `472afc219b37d540a3474336841ba4aa3c274c61a7bfcae3e548754c214689b7` |
| `docs/XU02_UTF8_Normalized_Review_Diff_v0.1.patch` | 14,667 | `16e8cc8b80284b0148a7879f586a8242637bffdc12119dfaf27ebf82f72dca6f` |
| `src/frmMailGenerator_CodeOnly_XU01_XU02_A_v0.1.txt` | 17,637 | `63a458854621bfd7ef04393f9c10474d8574ef35de7a2da0b6387452924661a1` |
| `src/frmMailGenerator_P3-04_XU01_XU02_A_Candidate_v0.1.frm` | 19,727 | `4fb506869d32ce8f7081b0b4a2678f511b452e770fe59d003bfa5feacb9f87df` |
| `src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas` | 2,848 | `87fdefe7f53b568e4c7d3df56884828a7647f51c91fa24a0f998ef9c86d9cd88` |
| `tests/modP3_04GateStub_XU02_v0.1_CP932.bas` | 4,476 | `087d528ab23b7d28dff3d6b0ad8197a939b6723d12b6a04e2975b62ef9903b50` |
| `tests/modP3_04XU02Tests_v0.1_CP932.bas` | 11,934 | `21335430c963c18567f8d8eda03e39e25ed1a38d1d200327cb58ced2431910fb` |
| `verification/XU02_STATIC_AUDIT.json` | 7,533 | `5d95a7ef66042246d602ea4c4d593ced2dfcde425ce300bb286c70a3eb84d500` |
| `verification/static_review_xu02.py` | 10,241 | `ed69cd38de6ae95a49f97d66d313a28b4bef2a5fba7e2b21a4e300e9f8fef05c` |

**位置付け：** 元のP3-04 XU-01 Candidateを上書きしていない。Formのみ変更。Controllerをバイト単位でそのまま同梱。StubとRunnerはTEST ONLY。正式Production・GitHub・Baseline更新ではない。

## 検査条件

- ZIP内の全ファイルの存在、Size、SHA-256はZIP作成後に機械的に照合する。
- `XU02_UTF8_Normalized_Review_Diff_v0.1.patch`はUTF-8/LFコピー向け。元のCP932/CRLFファイルへ直接適用しない。

## まとめ / Summary

日本語：Manifestは配布パッケージのSHA-256とStatusを記録する。  
English: This manifest records file hashes and candidate status.
