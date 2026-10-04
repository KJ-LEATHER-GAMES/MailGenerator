Attribute VB_Name = "modResolveWorkbookRelativePathSmokeTest"
Option Explicit

Private Const TEST_RELATIVE_PATH As String = "Templates\MailTemplate.oft"

Public Sub TestResolveWorkbookRelativePath()

    Debug.Print "TestResolveWorkbookRelativePath: START"
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path
    Debug.Print

    If Not TestHappyPath() Then
        Debug.Print "TestResolveWorkbookRelativePath: FAIL"
        Exit Sub
    End If

    If Not TestRejectEmptyPath() Then
        Debug.Print "TestResolveWorkbookRelativePath: FAIL"
        Exit Sub
    End If

    If Not TestRejectAbsolutePath() Then
        Debug.Print "TestResolveWorkbookRelativePath: FAIL"
        Exit Sub
    End If

    Debug.Print "TestResolveWorkbookRelativePath: PASS"
End Sub

Private Function TestHappyPath() As Boolean

    Dim result As COperationResult
    Dim absolutePath As String

    Debug.Print "[Case 1] Workbook-relative path resolution"

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        TEST_RELATIVE_PATH, _
        absolutePath _
    )

    If result Is Nothing Then
        Debug.Print "  FAIL"
        Debug.Print "  Result is Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print "  FAIL"
        PrintResultErrors result
        Exit Function
    End If

    If Len(Trim$(absolutePath)) = 0 Then
        Debug.Print "  FAIL"
        Debug.Print "  Resolved path is empty."
        Exit Function
    End If

    If IsWebUrl(absolutePath) Then
        Debug.Print "  FAIL"
        Debug.Print "  Resolved path is still a web URL."
        Debug.Print "  Actual=" & absolutePath
        Exit Function
    End If

    If Not IsWindowsAbsolutePath(absolutePath) Then
        Debug.Print "  FAIL"
        Debug.Print "  Resolved path is not a Windows absolute path."
        Debug.Print "  Actual=" & absolutePath
        Exit Function
    End If

    If Not EndsWithPath(absolutePath, TEST_RELATIVE_PATH) Then
        Debug.Print "  FAIL"
        Debug.Print "  Resolved path does not end with the requested relative path."
        Debug.Print "  Expected suffix=" & TEST_RELATIVE_PATH
        Debug.Print "  Actual=" & absolutePath
        Exit Function
    End If

    Debug.Print "  PASS"
    Debug.Print "  RelativePath=" & TEST_RELATIVE_PATH
    Debug.Print "  ResolvedPath=" & absolutePath
    Debug.Print

    TestHappyPath = True
End Function

Private Function TestRejectEmptyPath() As Boolean

    Dim result As COperationResult
    Dim absolutePath As String

    Debug.Print "[Case 2] Empty relative path rejection"

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        vbNullString, _
        absolutePath _
    )

    If result Is Nothing Then
        Debug.Print "  FAIL"
        Debug.Print "  Result is Nothing."
        Exit Function
    End If

    If result.Success Then
        Debug.Print "  FAIL"
        Debug.Print "  Empty relative path was unexpectedly accepted."
        Debug.Print "  ResolvedPath=" & absolutePath
        Exit Function
    End If

    If Len(absolutePath) <> 0 Then
        Debug.Print "  FAIL"
        Debug.Print "  absolutePath should remain empty on failure."
        Debug.Print "  Actual=" & absolutePath
        Exit Function
    End If

    Debug.Print "  PASS"
    PrintResultErrors result
    Debug.Print

    TestRejectEmptyPath = True
End Function

Private Function TestRejectAbsolutePath() As Boolean

    Dim result As COperationResult
    Dim absolutePath As String
    Dim inputPath As String

    inputPath = "C:\Temp\MailTemplate.oft"

    Debug.Print "[Case 3] Absolute path rejection"

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        inputPath, _
        absolutePath _
    )

    If result Is Nothing Then
        Debug.Print "  FAIL"
        Debug.Print "  Result is Nothing."
        Exit Function
    End If

    If result.Success Then
        Debug.Print "  FAIL"
        Debug.Print "  Absolute path was unexpectedly accepted."
        Debug.Print "  ResolvedPath=" & absolutePath
        Exit Function
    End If

    If Len(absolutePath) <> 0 Then
        Debug.Print "  FAIL"
        Debug.Print "  absolutePath should remain empty on failure."
        Debug.Print "  Actual=" & absolutePath
        Exit Function
    End If

    Debug.Print "  PASS"
    PrintResultErrors result
    Debug.Print

    TestRejectAbsolutePath = True
End Function

Private Function IsWebUrl(ByVal pathValue As String) As Boolean

    IsWebUrl = (InStr(1, pathValue, "://", vbTextCompare) > 0)
End Function

Private Function IsWindowsAbsolutePath(ByVal pathValue As String) As Boolean

    Dim normalizedPath As String

    normalizedPath = Trim$(pathValue)

    If Len(normalizedPath) < 3 Then Exit Function
    If Mid$(normalizedPath, 2, 1) <> ":" Then Exit Function

    If Mid$(normalizedPath, 3, 1) <> "\" And _
       Mid$(normalizedPath, 3, 1) <> "/" Then
        Exit Function
    End If

    IsWindowsAbsolutePath = True
End Function

Private Function EndsWithPath( _
    ByVal fullPath As String, _
    ByVal expectedSuffix As String _
) As Boolean

    Dim normalizedFull As String
    Dim normalizedSuffix As String

    normalizedFull = NormalizeWindowsPath(fullPath)
    normalizedSuffix = NormalizeWindowsPath(expectedSuffix)

    If Len(normalizedFull) < Len(normalizedSuffix) Then Exit Function

    EndsWithPath = _
        (StrComp( _
            Right$(normalizedFull, Len(normalizedSuffix)), _
            normalizedSuffix, _
            vbTextCompare _
        ) = 0)
End Function

Private Function NormalizeWindowsPath(ByVal pathValue As String) As String

    NormalizeWindowsPath = Replace(Trim$(pathValue), "/", "\")
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
