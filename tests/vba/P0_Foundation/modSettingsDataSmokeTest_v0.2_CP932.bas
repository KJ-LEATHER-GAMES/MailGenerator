Attribute VB_Name = "modSettingsDataSmokeTest"
Option Explicit

Public Sub TestSettingsData()

    Dim result As COperationResult
    Dim settingValue As String
    Dim absolutePath As String
    Dim errors As Collection

    Debug.Print "TestSettingsData: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path

    ' Precondition: Settings sheet/table/columns and TemplatePath fixture must exist.
    If Not ValidateSettingsFixture() Then
        Debug.Print "TestSettingsData: FAIL (PRECONDITION)"
        Exit Sub
    End If

    ' 1. TemplatePath can be read from Settings / tblSettings.
    Set result = GetSettingValue("TemplatePath", settingValue)

    If Not result.Success Then
        PrintResultErrors "1. TemplatePath read failed", result
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If Len(settingValue) = 0 Then
        Debug.Print "FAIL: 1. TemplatePath value is empty."
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    ' 2. Key matching is case-insensitive.
    settingValue = vbNullString
    Set result = GetSettingValue("templatepath", settingValue)

    If Not result.Success Then
        PrintResultErrors "2. Case-insensitive lookup failed", result
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If Len(settingValue) = 0 Then
        Debug.Print "FAIL: 2. Case-insensitive lookup returned an empty value."
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    ' 3. Missing key returns ConfigurationError and the requested key as Target.
    settingValue = vbNullString
    Set result = GetSettingValue("__MissingKey__", settingValue)

    If result.Success Then
        Debug.Print "FAIL: 3. Missing key unexpectedly returned Success."
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If result.Errors.Count <> 1 Then
        Debug.Print "FAIL: 3. Expected exactly one error. Actual=" & CStr(result.Errors.Count)
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    Set errors = result.Errors

    If errors(1).ErrorType <> "ConfigurationError" Then
        Debug.Print "FAIL: 3. ErrorType expected ConfigurationError. Actual=" & errors(1).ErrorType
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If errors(1).Target <> "__MissingKey__" Then
        Debug.Print "FAIL: 3. Target expected __MissingKey__. Actual=" & errors(1).Target
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    ' 4. Relative path resolves from ThisWorkbook.Path.
    Set result = ResolveWorkbookRelativePath("Templates\MailTemplate.oft", absolutePath)

    If Not result.Success Then
        PrintResultErrors "4. Relative path resolution failed", result
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If Len(absolutePath) <= Len(ThisWorkbook.Path) Then
        Debug.Print "FAIL: 4. Resolved path is not longer than ThisWorkbook.Path."
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If StrComp( _
        Left$(absolutePath, Len(ThisWorkbook.Path)), _
        ThisWorkbook.Path, _
        vbTextCompare) <> 0 Then

        Debug.Print "FAIL: 4. Resolved path is not based on ThisWorkbook.Path."
        Debug.Print "Actual: " & absolutePath
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    ' 5. Absolute path is rejected because Settings uses workbook-relative paths.
    absolutePath = vbNullString
    Set result = ResolveWorkbookRelativePath("C:\Templates\MailTemplate.oft", absolutePath)

    If result.Success Then
        Debug.Print "FAIL: 5. Absolute path unexpectedly returned Success."
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    If result.Errors.Count <> 1 Then
        Debug.Print "FAIL: 5. Expected exactly one error. Actual=" & CStr(result.Errors.Count)
        Debug.Print "TestSettingsData: FAIL"
        Exit Sub
    End If

    Debug.Print "TestSettingsData: PASS"

End Sub

Private Function ValidateSettingsFixture() As Boolean

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim keyColumn As ListColumn
    Dim valueColumn As ListColumn
    Dim result As COperationResult
    Dim templatePath As String

    ValidateSettingsFixture = False

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets("Settings")
    On Error GoTo 0

    If ws Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Worksheet 'Settings' was not found in ThisWorkbook."
        Debug.Print "ThisWorkbook = " & ThisWorkbook.Name
        PrintWorksheetNames
        Exit Function
    End If

    On Error Resume Next
    Set lo = ws.ListObjects("tblSettings")
    On Error GoTo 0

    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Table 'tblSettings' was not found on worksheet 'Settings'."
        Exit Function
    End If

    On Error Resume Next
    Set keyColumn = lo.ListColumns("Key")
    Set valueColumn = lo.ListColumns("Value")
    On Error GoTo 0

    If keyColumn Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Column 'Key' was not found in tblSettings."
        Exit Function
    End If

    If valueColumn Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Column 'Value' was not found in tblSettings."
        Exit Function
    End If

    Set result = GetSettingValue("TemplatePath", templatePath)

    If Not result.Success Then
        PrintResultErrors "PRECONDITION: TemplatePath fixture is invalid", result
        Exit Function
    End If

    If Len(templatePath) = 0 Then
        Debug.Print "PRECONDITION FAIL: TemplatePath exists but Value is empty."
        Exit Function
    End If

    ValidateSettingsFixture = True

End Function

Private Sub PrintWorksheetNames()

    Dim ws As Worksheet

    Debug.Print "Worksheets in ThisWorkbook:"
    For Each ws In ThisWorkbook.Worksheets
        Debug.Print "  - [" & ws.Name & "]"
    Next ws

End Sub

Private Sub PrintResultErrors( _
    ByVal context As String, _
    ByVal result As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    Debug.Print "FAIL: " & context

    If result Is Nothing Then
        Debug.Print "  Result is Nothing."
        Exit Sub
    End If

    Debug.Print "  Success = " & CStr(result.Success)

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)
        Debug.Print "  Error[" & CStr(i) & "]"
        Debug.Print "    Type   = " & errorInfo.ErrorType
        Debug.Print "    Message= " & errorInfo.Message
        Debug.Print "    Target = " & errorInfo.Target
    Next i

End Sub
