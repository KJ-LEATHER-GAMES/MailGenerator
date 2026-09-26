Attribute VB_Name = "modP1OftConnectionSmokeTest"
Option Explicit

Public Sub TestP1OftConnection()
    Dim result As COperationResult
    Dim templatePath As String
    Dim resolvedPath As String
    Dim mailCreated As Boolean

    On Error GoTo UnexpectedFailure

    Debug.Print "TestP1OftConnection: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path

    Set result = GetSettingValue("TemplatePath", templatePath)
    If Not RequireSuccess("GetSettingValue(TemplatePath)", result) Then GoTo TestFailed

    If Len(Trim$(templatePath)) = 0 Then
        Debug.Print "GetSettingValue(TemplatePath): FAIL"
        Debug.Print "  TemplatePath is empty."
        GoTo TestFailed
    End If

    Debug.Print "TemplatePath: " & templatePath

    Set result = ResolveWorkbookRelativePath(templatePath, resolvedPath)
    If Not RequireSuccess("ResolveWorkbookRelativePath", result) Then GoTo TestFailed

    If Len(Trim$(resolvedPath)) = 0 Then
        Debug.Print "ResolveWorkbookRelativePath: FAIL"
        Debug.Print "  ResolvedPath is empty."
        GoTo TestFailed
    End If

    Debug.Print "ResolvedPath: " & resolvedPath
    Debug.Print "  Settings / Path Resolution: PASS"

    Set result = modOutlookAdapter.CreateMailFromTemplate(resolvedPath)
    If Not RequireSuccess("CreateItemFromTemplate", result) Then GoTo TestFailed

    mailCreated = True
    Debug.Print "  CreateItemFromTemplate: PASS"

    Set result = modOutlookAdapter.CloseWithoutSave()
    mailCreated = False
    If Not RequireSuccess("CloseWithoutSave", result) Then GoTo TestFailed

    Debug.Print "  Close Without Save: PASS"
    Debug.Print "TestP1OftConnection: PASS"
    Exit Sub

TestFailed:
    If mailCreated Then
        Set result = modOutlookAdapter.CloseWithoutSave()
        mailCreated = False
        If Not result Is Nothing Then
            If Not result.Success Then
                Debug.Print "Cleanup CloseWithoutSave: FAIL"
                PrintResultErrors result
            End If
        End If
    End If

    Debug.Print "TestP1OftConnection: FAIL"
    Exit Sub

UnexpectedFailure:
    Debug.Print "TestP1OftConnection: FAIL"
    Debug.Print "  Unexpected VBA runtime error."
    Debug.Print "  Err.Number=" & CStr(Err.Number)
    Debug.Print "  Err.Description=" & Err.Description

    On Error Resume Next
    If mailCreated Then
        Set result = modOutlookAdapter.CloseWithoutSave()
    End If
    On Error GoTo 0
End Sub

Private Function RequireSuccess( _
    ByVal stepName As String, _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then
        Debug.Print stepName & ": FAIL"
        Debug.Print "  Result is Nothing."
        RequireSuccess = False
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print stepName & ": FAIL"
        PrintResultErrors result
        RequireSuccess = False
        Exit Function
    End If

    RequireSuccess = True
End Function

Private Sub PrintResultErrors(ByVal result As COperationResult)
    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    If result Is Nothing Then Exit Sub

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)
        Debug.Print "  ErrorType=" & errorInfo.ErrorType
        Debug.Print "  Message=" & errorInfo.Message
        Debug.Print "  Target=" & errorInfo.Target
    Next i
End Sub
