P1-01 OFT Path / Outlook Connection v0.1

Files:
- P1-01 OFT Path Outlook Connection 実施仕様 v0.1.md
- modOutlookAdapter_CP932.bas
- modP1OftConnectionSmokeTest_v0.1_CP932.bas

Import order (existing P0 classes/modules must already exist):
1. modOutlookAdapter_CP932.bas
2. modP1OftConnectionSmokeTest_v0.1_CP932.bas

Then:
1. Debug > Compile VBAProject
2. Confirm Settings!tblSettings has TemplatePath
3. Run TestP1OftConnection
4. Copy the Immediate Window output for PASS/FAIL classification

Important:
- BAS files are encoded as CP932 for Japanese Windows VBE import compatibility.
- This implementation intentionally does NOT pre-check file existence and does NOT convert OneDrive URL paths.
- Outlook.Application.Quit is never called.
