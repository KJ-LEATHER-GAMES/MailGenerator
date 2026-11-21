Attribute VB_Name = "modP3_02TestStubs"
Option Explicit

' ISOLATED TEST WORKBOOK ONLY. Never import with real Data/Outlook modules.
' These public symbols stand in for existing Production dependencies.
' Do not import or execute in the Production workbook.

Private mScenario As Long
Private mCloseCalls As Long
Private mOptionCalls As Long

Public Sub P3StubReset(ByVal scenarioId As Long)
    mScenario = scenarioId
    mCloseCalls = 0
    mOptionCalls = 0
End Sub

Public Function P3StubCloseCalls() As Long
    P3StubCloseCalls = mCloseCalls
End Function

Public Function P3StubOptionCalls() As Long
    P3StubOptionCalls = mOptionCalls
End Function

Public Function GetSettingValue( _
    ByVal key As String, ByRef value As String _
) As COperationResult
    value = "fixture.oft"
    If mScenario = 2 Then
        Set GetSettingValue = CreateFailureResult( _
            "ConfigurationError", "Stub settings failure.", "Settings")
    Else
        Set GetSettingValue = CreateSuccessResult()
    End If
End Function

Public Function ResolveWorkbookRelativePath( _
    ByVal pathValue As String, ByRef resolvedPath As String _
) As COperationResult
    resolvedPath = ThisWorkbook.FullName  ' A saved local test workbook is required.
    If mScenario = 3 Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            "ConfigurationError", "Stub path failure.", "TemplatePath")
    ElseIf mScenario = 4 Then
        resolvedPath = ThisWorkbook.Path & Application.PathSeparator & _
            "___P3_02_absent_0f9c8e2b6d35.oft"
        Set ResolveWorkbookRelativePath = CreateSuccessResult()
    Else
        Set ResolveWorkbookRelativePath = CreateSuccessResult()
    End If
End Function

Public Function CreateMailFromTemplate( _
    ByVal templatePath As String _
) As COperationResult
    If mScenario = 5 Then
        Set CreateMailFromTemplate = CreateFailureResult( _
            "OutlookError", "Stub MailItem creation failure.", "OutlookTemplate")
    Else
        Set CreateMailFromTemplate = CreateSuccessResult()
    End If
End Function

Public Function ReadSubject(ByRef subjectText As String) As COperationResult
    subjectText = "Subject {{ModelName}}"
    If mScenario = 6 Then
        Set ReadSubject = CreateFailureResult( _
            "OutlookError", "Stub subject failure.", "Subject")
    Else
        Set ReadSubject = CreateSuccessResult()
    End If
End Function

Public Function ReadBodyText(ByRef bodyText As String) As COperationResult
    bodyText = "Body"
    If mScenario = 7 Or mScenario = 22 Then
        Set ReadBodyText = CreateFailureResult( _
            "OutlookError", "Stub body failure.", "StubBodyError")
    Else
        Set ReadBodyText = CreateSuccessResult()
    End If
End Function

Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult

    Set scanResult = Nothing
    If mScenario = 8 Then
        Set ScanTemplate = CreateFailureResult( _
            "TemplateError", "Stub scan failure.", "Scanner")
        Exit Function
    End If
    If mScenario = 19 Then
        Set ScanTemplate = CreateSuccessResult()
        Exit Function
    End If

    Set scanResult = MakeStubScan()
    If mScenario = 13 Then
        scanResult("InvalidCandidates").Add "{{!!!}}"
    ElseIf mScenario = 14 Then
        scanResult("ValidVariables").Add "NewName"
        scanResult("Locations").Add "NewName", "Body"
    ElseIf mScenario = 15 Then
        scanResult("ValidVariables").Remove 1
        scanResult("Locations").Remove "ModelName"
    ElseIf mScenario = 16 Then
        scanResult("ValidVariables").Add "StageName"
        scanResult("Locations").Add "StageName", "Body"
    End If
    Set ScanTemplate = CreateSuccessResult()
End Function

Public Function CloseWithoutSave() As COperationResult
    mCloseCalls = mCloseCalls + 1
    If mScenario = 9 Or mScenario = 22 Then
        Set CloseWithoutSave = CreateFailureResult( _
            "OutlookError", "Stub cleanup failure.", "MailItemCleanup")
    Else
        Set CloseWithoutSave = CreateSuccessResult()
    End If
End Function

Public Function GetAllVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult
    Set items = Nothing
    If mScenario = 10 Then
        Set GetAllVariableDefinitions = CreateFailureResult( _
            "ConfigurationError", "Stub definitions failure.", "VariableDefinitions")
        Exit Function
    End If
    If mScenario = 20 Then
        Set GetAllVariableDefinitions = CreateSuccessResult()
        Exit Function
    End If
    Set items = New Collection
    Dim model As Object
    Set model = MakeStubDefinition("ModelName")
    If mScenario = 12 Then model("DisplayName") = vbNullString
    If mScenario = 16 Or mScenario = 17 Or mScenario = 18 Or _
       mScenario = 11 Or mScenario = 21 Or mScenario = 23 Then
        model("Type") = "Select"
        model("OptionSource") = "Department"
    End If
    If mScenario = 17 Then model("OptionSource") = vbNullString
    If mScenario = 23 Then model("OptionSource") = "department"
    items.Add model
    If mScenario = 16 Then
        Dim second As Object
        Set second = MakeStubDefinition("StageName")
        second("Type") = "Select"
        second("OptionSource") = "Department"
        second("__RowIndex") = 2
        items.Add second
    End If
    Set GetAllVariableDefinitions = CreateSuccessResult()
End Function

Public Function GetActiveOptions( _
    ByVal optionGroup As String, _
    ByRef items As Collection _
) As COperationResult
    mOptionCalls = mOptionCalls + 1
    Set items = Nothing
    If mScenario = 11 Then
        Set GetActiveOptions = CreateFailureResult( _
            "ConfigurationError", "Stub options failure.", "OptionMaster")
        Exit Function
    End If
    If mScenario = 21 Then
        Set GetActiveOptions = CreateSuccessResult()
        Exit Function
    End If
    Set items = New Collection
    If mScenario <> 18 And mScenario <> 23 Then
        Dim opt As Object
        Set opt = CreateObject("Scripting.Dictionary")
        opt.CompareMode = vbTextCompare
        opt.Add "OptionGroup", "Department"
        opt.Add "Value", "Design"
        opt.Add "SortOrder", 10
        opt.Add "Active", True
        opt.Add "__RowIndex", 1
        items.Add opt
    End If
    Set GetActiveOptions = CreateSuccessResult()
End Function

Private Function MakeStubScan() As Object
    Dim scan As Object
    Dim validNames As Collection
    Dim invalidNames As Collection
    Dim locations As Object
    Set scan = CreateObject("Scripting.Dictionary")
    scan.CompareMode = vbBinaryCompare
    Set validNames = New Collection
    Set invalidNames = New Collection
    Set locations = CreateObject("Scripting.Dictionary")
    locations.CompareMode = vbTextCompare
    validNames.Add "ModelName"
    locations.Add "ModelName", "Subject"
    scan.Add "ValidVariables", validNames
    scan.Add "InvalidCandidates", invalidNames
    scan.Add "Locations", locations
    Set MakeStubScan = scan
End Function

Private Function MakeStubDefinition( _
    ByVal variableName As String _
) As Object
    Dim item As Object
    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare
    item.Add "VariableName", variableName
    item.Add "DisplayName", variableName
    item.Add "Type", "Text"
    item.Add "Required", False
    item.Add "Description", vbNullString
    item.Add "OptionSource", vbNullString
    item.Add "SortOrder", 10
    item.Add "Format", vbNullString
    item.Add "TemplateLocation", "Subject"
    item.Add "Status", "Active"
    item.Add "FirstDetectedAt", Empty
    item.Add "LastDetectedAt", Empty
    item.Add "__RowIndex", 1
    Set MakeStubDefinition = item
End Function
