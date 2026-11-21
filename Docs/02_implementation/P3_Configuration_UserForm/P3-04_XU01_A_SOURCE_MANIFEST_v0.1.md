# P3-04 XU-01 A Candidate Source Manifest

- Revision: v0.1
- 作成日: 2026-11-21
- Status: WORKING CANDIDATE / NOT APPLIED
- Original Base: `P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1` (user-provided archived candidate)
- Source Encoding: `.frm/.bas/.txt` CP932 + CRLF; `.md/.json/.py` UTF-8
- Verification: 46/46 static PASS; 27 VBA cases defined / NOT RUN

| Package file | Size bytes | SHA-256 |
|---|---:|---|
| `00_README.md` | 2759 | `efde2c35781df4abc77f0d8223ea97d258eca1652682796ab7c8e89449724e98` |
| `Docs/Designer_Setup_and_Import_Limitations_v0.1.md` | 3538 | `1ec3610b70b64bd00091d147c43b5cb896c8d034fbf6a2bd142fb7a2da221a98` |
| `Docs/P3-04_XU01_A_CP932_CRLF_Apply_Candidate_v0.1.patch` | 14485 | `429b78c8811a645892a5a5c9bb27cdd4b81eb8371bef3cfb7d6a453387cfa6d8` |
| `Docs/P3-04_XU01_A_Design_Implementation_Review_v0.1.md` | 12038 | `3fda74d88db1b034f2b319cba7a93a9577b198ad17ef4b7734f58915119ff031` |
| `Docs/P3-04_XU01_A_UTF8_Normalized_Review_Diff_v0.1.patch` | 13226 | `a15b3d4667f25b95aa49374e44ff4b11223228f8b7c3e70c04fdba836966cd20` |
| `Docs/STATIC_REVIEW_RESULT_XU01_A.json` | 7234 | `988852dd596fa89e1fdc49d1543f39575d090a34d35b5625107bb79df1e674a0` |
| `Docs/STATIC_REVIEW_XU01_A.py` | 11508 | `ad442e840fa90026a9457dd3924a28c2724517ec95d82b0402d738e19a26f829` |
| `src/frmMailGenerator_CodeOnly_XU01_A_v0.1.txt` | 15226 | `9ea39db6132b44ac111afdcc8a6fee4d8e22a4e5ef8c4fd4d59ca26d405136a4` |
| `src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm` | 17316 | `dfa70b8e4d3ede487c061bc82ac5be1ff0a7c2b0801c8899660da98a7d58a322` |
| `src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas` | 2848 | `87fdefe7f53b568e4c7d3df56884828a7647f51c91fa24a0f998ef9c86d9cd88` |
| `tests/modP3_04FormXU01ATests_v0.1_CP932.bas` | 9475 | `0f2747f178446b6fc603b4936a3dd1059869f6b6ab5ea7aedf2b24ab8aea82ec` |
| `tests/modP3_04GateStub_v0.1_CP932.bas` | 3715 | `d5678e4b5faa33dac832036f8ca40dbb2145858164c11534fdddfd5c35a4c195` |

**Manifest自身は自己参照によるHash循環を防ぐため一覧から除外する。**

## Base Candidate SHA-256 (actual original files)
- `frmMailGenerator_P3-04_Candidate_v0.1.frm`: `7ae49e7a204273136a8c86807f32b584c652b0140fb71b378102faee874a08d7`
- `modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas`: `5a26ca5e613b47f7b7c88ddcbec5631c2ebd4f8c338b1917292495e63ae1a19d`

P3-01/02/03、P2 Production、GitHub、BL-MVP-004は更新していない。
