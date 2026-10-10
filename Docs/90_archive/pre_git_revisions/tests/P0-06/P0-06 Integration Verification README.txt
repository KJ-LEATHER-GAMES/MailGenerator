P0-06 Integration Verification Smoke Test v0.1

Purpose:
Verify that the completed P0 foundation components can run sequentially
in the same MailGenerator.xlsm without introducing new functionality.

Encoding:
CP932 for direct import into the Japanese Windows VBA editor.

Required production modules:
- CErrorInfo
- COperationResult
- modResult
- modSettingsData
- modVariableDefinitionData
- modOptionMasterData

Required workbook fixtures:
1. Settings / tblSettings
   TemplatePath must exist and be non-empty.

2. VariableDefinition / tblVariableDefinition
   At least one readable row.
   At least one row with Status = Active.

3. OptionMaster / tblOptionMaster
   Keep the P0-05 smoke fixture:
   OptionGroup = __SmokeTestGroup__
   At least two Active rows.

Verification scope:
- Result / Error model
- Settings read
- Workbook-relative path resolution
- VariableDefinition all/active reads
- OptionMaster active read and SortOrder
- Sequential integrated execution

Not verified in P0-06:
- VariableDefinition.OptionSource -> OptionMaster configuration consistency
- Dynamic UserForm
- Outlook / WordEditor
- Sync write/update logic
- Formal MVP Test results

Expected successful output ends with:
TestP0FoundationIntegration: PASS

After the smoke test:
Run Debug -> Compile VBAProject.
If both pass, CP-P0 can be evaluated against the manual architecture checklist.
