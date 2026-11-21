# SOURCE_MANIFEST — P3 Cross-unit Review v0.1

Status: REVIEW COMPLETED WITH FINDINGS / Candidate only
Date: 2026-11-21

## Original unchanged candidate sources

- `p301` `p301/src/modConfigurationValidator_P3-01_Candidate_v0.1.bas`: SHA256 `491012dbaa8fc9cc07f16d0fef2b8cb73d649dfe77c2a70c79fe5e34249a7135`
- `p302` `p302/P3-02_Application_Candidate_Package/src/modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas`: SHA256 `d00fa96dc59cf07bc3b5ca967062066c85d9e26c8d4f16da7e293275ebdf915f`
- `p303` `p303/P3-03_UserForm_Launch_Gate_Candidate_v0.1/src/modP3UserFormLaunchGate_P3-03_Candidate_v0.1_CP932.bas`: SHA256 `6f8f2d934f81e036278d87eac68a2e70413bc19f60312f829d26b52ab57d32f8`
- `p304c` `p304/P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas`: SHA256 `5a26ca5e613b47f7b7c88ddcbec5631c2ebd4f8c338b1917292495e63ae1a19d`
- `p304f` `p304/P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/frmMailGenerator_P3-04_Candidate_v0.1.frm`: SHA256 `7ae49e7a204273136a8c86807f32b584c652b0140fb71b378102faee874a08d7`

## New review files

- `P3-01_to_P3-04_Cross_Unit_Source_Review_v0.1_20261121.md`: SHA256 `ed7c035319210373130ce55cfbe657caa1c14e4729cacd0e47363336d29d84f9`
- `P3_Cross_Unit_Minimal_Fixes_Candidate_v0.1.patch`: SHA256 `c871681d2fd243eda1efe9eaddb578d036654339a29e529cae9110c76b6d3b7b`
- `P3_Cross_Unit_Static_Audit_Result_20261121.json`: SHA256 `122747fd2e38be867989f8d0178f8ed2d7ac5f764e58e197b6175e14e36359d9`
- `patched_source/p301/src/modConfigurationValidator_P3-01_Candidate_v0.1.bas`: SHA256 `217c575c8f7b19d96a7fdd4b5c22db61319809a923d5186082ca29dd4f503ac8` (new CP932/CRLF candidate only)
- `patched_source/p302/P3-02_Application_Candidate_Package/src/modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas`: SHA256 `1fca4d8cae53f4cd0d2cfdf97b5436be67af13d2430fcf5468c35612d4ed83d7` (new CP932/CRLF candidate only)

Nothing was committed to GitHub. No VBA Compile, Import, Runtime Test or formal Gate was performed.

## Project recommended destination

- Report: `MailGenerator/Docs/00_project_control/reviews/`
- Patch and new candidate copies: `MailGenerator/Docs/02_implementation/P3_Configuration_UserForm/` (proposal only, directory not created in GitHub)
- Original P3 candidate zips remain authoritative as inputs for this working review and are not included or overwritten.
