Attribute VB_Name = "modSettingsDataSmokeTest"
Option Explicit

Public Sub TestSettingsData()
    Dim result As COperationResult
    Dim settingValue As String
    Dim absolutePath As String
    Dim errors As Collection

    ' 1. TemplatePath can be read from Settings / tblSettings.
    Set result = GetSettingValue("TemplatePath", settingValue)

    Debug.Assert result.Success = True
    Debug.Assert Len(settingValue) > 0

    ' 2. Key matching is case-insensitive.
    settingValue = vbNullString
    Set result = GetSettingValue("templatepath", settingValue)

    Debug.Assert result.Success = True
    Debug.Assert Len(settingValue) > 0

    ' 3. Missing key returns ConfigurationError.
    settingValue = vbNullString
    Set result = GetSettingValue("__MissingKey__", settingValue)

    Debug.Assert result.Success = False
    Debug.Assert result.Errors.Count = 1

    Set errors = result.Errors
    Debug.Assert errors(1).ErrorType = "ConfigurationError"
    Debug.Assert errors(1).Target = "__MissingKey__"

    ' 4. Relative path resolves from ThisWorkbook.Path.
    Set result = ResolveWorkbookRelativePath("Templates\MailTemplate.oft", absolutePath)

    Debug.Assert result.Success = True
    Debug.Assert Len(absolutePath) > Len(ThisWorkbook.Path)
    Debug.Assert StrComp( _
        Left$(absolutePath, Len(ThisWorkbook.Path)), _
        ThisWorkbook.Path, _
        vbTextCompare) = 0

    ' 5. Absolute path is rejected because Settings uses workbook-relative paths.
    absolutePath = vbNullString
    Set result = ResolveWorkbookRelativePath("C:\Templates\MailTemplate.oft", absolutePath)

    Debug.Assert result.Success = False
    Debug.Assert result.Errors.Count = 1

    Debug.Print "TestSettingsData: PASS"
End Sub
