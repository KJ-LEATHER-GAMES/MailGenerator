Attribute VB_Name = "modP0FoundationIntegrationSmokeTest"
Option Explicit

Private Const OPTION_SMOKE_GROUP As String = "__SmokeTestGroup__"

Public Sub TestP0FoundationIntegration()

    Dim result As COperationResult
    Dim templatePath As String
    Dim absolutePath As String

    Dim allVariables As Collection
    Dim activeVariables As Collection
    Dim activeOptions As Collection

    Debug.Print "TestP0FoundationIntegration: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path

    If Len(ThisWorkbook.Path) = 0 Then
        Debug.Print "PRECONDITION FAIL: ThisWorkbook has not been saved."
        Debug.Print "TestP0FoundationIntegration: FAIL (PRECONDITION)"
        Exit Sub
    End If

    ' ------------------------------------------------------------
    ' 1. Result / Error model
    ' ------------------------------------------------------------
    Set result = CreateSuccessResult()

    If result Is Nothing Then
        Debug.Print "FAIL: 1. CreateSuccessResult returned Nothing."
        GoTo TestFailed
    End If

    If Not result.Success Then
        Debug.Print "FAIL: 1. Success result returned Success=False."
        GoTo TestFailed
    End If

    If result.Errors.Count <> 0 Then
        Debug.Print "FAIL: 1. Success result contains errors."
        GoTo TestFailed
    End If

    Set result = CreateFailureResult( _
        "IntegrationSmokeError", _
        "P0 integration smoke failure fixture.", _
        "P0")

    If result Is Nothing Then
        Debug.Print "FAIL: 1. CreateFailureResult returned Nothing."
        GoTo TestFailed
    End If

    If result.Success Then
        Debug.Print "FAIL: 1. Failure result returned Success=True."
        GoTo TestFailed
    End If

    If result.Errors.Count <> 1 Then
        Debug.Print "FAIL: 1. Failure result should contain exactly one error."
        GoTo TestFailed
    End If

    Debug.Print "  Result / Error Model: PASS"

    ' ------------------------------------------------------------
    ' 2. Settings Data Access
    ' ------------------------------------------------------------
    Set result = GetSettingValue("TemplatePath", templatePath)

    If Not result.Success Then
        PrintResultErrors "2. GetSettingValue(TemplatePath) failed", result
        GoTo TestFailed
    End If

    If Len(Trim$(templatePath)) = 0 Then
        Debug.Print "FAIL: 2. TemplatePath is empty."
        GoTo TestFailed
    End If

    Set result = ResolveWorkbookRelativePath(templatePath, absolutePath)

    If Not result.Success Then
        PrintResultErrors "2. ResolveWorkbookRelativePath failed", result
        GoTo TestFailed
    End If

    If Len(Trim$(absolutePath)) = 0 Then
        Debug.Print "FAIL: 2. Resolved path is empty."
        Debug.Print "  TemplatePath=" & templatePath
        GoTo TestFailed
    End If

    If IsOneDriveWebWorkbookPath(ThisWorkbook.Path) Then

        If Not IsWindowsAbsolutePath(absolutePath) Then
            Debug.Print "FAIL: 2. OneDrive Web URL was not resolved to a Windows absolute path."
            Debug.Print "  ThisWorkbook.Path=" & ThisWorkbook.Path
            Debug.Print "  TemplatePath     =" & templatePath
            Debug.Print "  AbsolutePath     =" & absolutePath
            GoTo TestFailed
        End If

        If IsHttpUrl(absolutePath) Then
            Debug.Print "FAIL: 2. Resolved path still contains a Web URL."
            Debug.Print "  ThisWorkbook.Path=" & ThisWorkbook.Path
            Debug.Print "  AbsolutePath     =" & absolutePath
            GoTo TestFailed
        End If

        If Not PathEndsWithRelativePath(absolutePath, templatePath) Then
            Debug.Print "FAIL: 2. Resolved local path does not preserve TemplatePath."
            Debug.Print "  ThisWorkbook.Path=" & ThisWorkbook.Path
            Debug.Print "  TemplatePath     =" & templatePath
            Debug.Print "  AbsolutePath     =" & absolutePath
            GoTo TestFailed
        End If

        Debug.Print "    Path Resolution Mode=OneDrive Web URL -> Local Windows Path"

    Else

        If Not IsPathBasedOnWorkbookPath(absolutePath, ThisWorkbook.Path) Then
            Debug.Print "FAIL: 2. Resolved path is not based on local ThisWorkbook.Path."
            Debug.Print "  ThisWorkbook.Path=" & ThisWorkbook.Path
            Debug.Print "  TemplatePath     =" & templatePath
            Debug.Print "  AbsolutePath     =" & absolutePath
            GoTo TestFailed
        End If

        Debug.Print "    Path Resolution Mode=Local Workbook Path"

    End If

    Debug.Print "  Settings Data Access: PASS"
    Debug.Print "    TemplatePath=" & templatePath
    Debug.Print "    AbsolutePath=" & absolutePath

    ' ------------------------------------------------------------
    ' 3. VariableDefinition Data Access
    ' ------------------------------------------------------------
    Set result = GetAllVariableDefinitions(allVariables)

    If Not result.Success Then
        PrintResultErrors "3. GetAllVariableDefinitions failed", result
        GoTo TestFailed
    End If

    If allVariables Is Nothing Then
        Debug.Print "FAIL: 3. GetAllVariableDefinitions returned Nothing."
        GoTo TestFailed
    End If

    If allVariables.Count = 0 Then
        Debug.Print "PRECONDITION FAIL: 3. tblVariableDefinition has no readable rows."
        Debug.Print "TestP0FoundationIntegration: FAIL (PRECONDITION)"
        Exit Sub
    End If

    Set result = GetActiveVariableDefinitions(activeVariables)

    If Not result.Success Then
        PrintResultErrors "3. GetActiveVariableDefinitions failed", result
        GoTo TestFailed
    End If

    If activeVariables Is Nothing Then
        Debug.Print "FAIL: 3. GetActiveVariableDefinitions returned Nothing."
        GoTo TestFailed
    End If

    If activeVariables.Count = 0 Then
        Debug.Print "PRECONDITION FAIL: 3. No Active VariableDefinition rows exist."
        Debug.Print "TestP0FoundationIntegration: FAIL (PRECONDITION)"
        Exit Sub
    End If

    If activeVariables.Count > allVariables.Count Then
        Debug.Print "FAIL: 3. Active count is greater than all-row count."
        GoTo TestFailed
    End If

    If Not ValidateActiveVariableItems(activeVariables) Then
        GoTo TestFailed
    End If

    Debug.Print "  VariableDefinition Data Access: PASS"
    Debug.Print "    All Rows   =" & CStr(allVariables.Count)
    Debug.Print "    Active Rows=" & CStr(activeVariables.Count)

    ' ------------------------------------------------------------
    ' 4. OptionMaster Data Access
    ' ------------------------------------------------------------
    Set result = GetActiveOptions(OPTION_SMOKE_GROUP, activeOptions)

    If Not result.Success Then
        PrintResultErrors _
            "4. GetActiveOptions(" & OPTION_SMOKE_GROUP & ") failed", _
            result
        GoTo TestFailed
    End If

    If activeOptions Is Nothing Then
        Debug.Print "FAIL: 4. GetActiveOptions returned Nothing."
        GoTo TestFailed
    End If

    If activeOptions.Count < 2 Then
        Debug.Print "PRECONDITION FAIL: 4. OptionMaster smoke fixture is incomplete."
        Debug.Print "Expected at least two Active rows for OptionGroup=" & OPTION_SMOKE_GROUP
        Debug.Print "TestP0FoundationIntegration: FAIL (PRECONDITION)"
        Exit Sub
    End If

    If Not ValidateOptionSortOrder(activeOptions) Then
        GoTo TestFailed
    End If

    Debug.Print "  OptionMaster Data Access: PASS"
    Debug.Print "    Active Options=" & CStr(activeOptions.Count)

    ' ------------------------------------------------------------
    ' 5. P0 integrated execution
    ' ------------------------------------------------------------
    Debug.Print "  Integrated Execution: PASS"
    Debug.Print "TestP0FoundationIntegration: PASS"
    Exit Sub

TestFailed:
    Debug.Print "TestP0FoundationIntegration: FAIL"

End Sub

Private Function IsOneDriveWebWorkbookPath( _
    ByVal workbookPath As String _
) As Boolean

    Const ONEDRIVE_WEB_PREFIX As String = "https://d.docs.live.net/"

    IsOneDriveWebWorkbookPath = _
        (StrComp( _
            Left$(workbookPath, Len(ONEDRIVE_WEB_PREFIX)), _
            ONEDRIVE_WEB_PREFIX, _
            vbTextCompare) = 0)

End Function

Private Function IsHttpUrl( _
    ByVal value As String _
) As Boolean

    Dim normalized As String

    normalized = LCase$(Trim$(value))

    IsHttpUrl = _
        (Left$(normalized, 7) = "http://") Or _
        (Left$(normalized, 8) = "https://")

End Function

Private Function IsWindowsAbsolutePath( _
    ByVal value As String _
) As Boolean

    Dim normalized As String

    normalized = Replace(Trim$(value), "/", "\")

    If Len(normalized) < 3 Then
        IsWindowsAbsolutePath = False
        Exit Function
    End If

    IsWindowsAbsolutePath = _
        (Mid$(normalized, 2, 1) = ":") And _
        (Mid$(normalized, 3, 1) = "\")

End Function

Private Function PathEndsWithRelativePath( _
    ByVal absolutePath As String, _
    ByVal relativePath As String _
) As Boolean

    Dim normalizedAbsolute As String
    Dim normalizedRelative As String

    normalizedAbsolute = NormalizePathForComparison(absolutePath)
    normalizedRelative = NormalizeRelativePathForComparison(relativePath)

    If Len(normalizedRelative) = 0 Then
        PathEndsWithRelativePath = False
        Exit Function
    End If

    If Len(normalizedAbsolute) < Len(normalizedRelative) Then
        PathEndsWithRelativePath = False
        Exit Function
    End If

    PathEndsWithRelativePath = _
        (StrComp( _
            Right$(normalizedAbsolute, Len(normalizedRelative)), _
            normalizedRelative, _
            vbTextCompare) = 0)

End Function

Private Function IsPathBasedOnWorkbookPath( _
    ByVal absolutePath As String, _
    ByVal workbookPath As String _
) As Boolean

    Dim normalizedAbsolute As String
    Dim normalizedWorkbook As String
    Dim expectedPrefix As String

    normalizedAbsolute = NormalizePathForComparison(absolutePath)
    normalizedWorkbook = NormalizePathForComparison(workbookPath)

    If Len(normalizedWorkbook) = 0 Then
        IsPathBasedOnWorkbookPath = False
        Exit Function
    End If

    expectedPrefix = normalizedWorkbook & "\"

    If Len(normalizedAbsolute) <= Len(expectedPrefix) Then
        IsPathBasedOnWorkbookPath = False
        Exit Function
    End If

    IsPathBasedOnWorkbookPath = _
        (StrComp( _
            Left$(normalizedAbsolute, Len(expectedPrefix)), _
            expectedPrefix, _
            vbTextCompare) = 0)

End Function

Private Function NormalizePathForComparison( _
    ByVal value As String _
) As String

    Dim normalized As String

    normalized = Replace(Trim$(value), "/", "\")

    Do While Len(normalized) > 3 And Right$(normalized, 1) = "\"
        normalized = Left$(normalized, Len(normalized) - 1)
    Loop

    NormalizePathForComparison = normalized

End Function

Private Function NormalizeRelativePathForComparison( _
    ByVal value As String _
) As String

    Dim normalized As String

    normalized = Replace(Trim$(value), "/", "\")

    Do While Len(normalized) > 0 And Left$(normalized, 1) = "\"
        normalized = Mid$(normalized, 2)
    Loop

    Do While Len(normalized) > 0 And Right$(normalized, 1) = "\"
        normalized = Left$(normalized, Len(normalized) - 1)
    Loop

    NormalizeRelativePathForComparison = normalized

End Function

Private Function ValidateActiveVariableItems( _
    ByVal items As Collection _
) As Boolean

    Dim item As Object
    Dim requiredKeys As Variant
    Dim key As Variant
    Dim i As Long

    ValidateActiveVariableItems = False

    requiredKeys = Array( _
        "VariableName", _
        "DisplayName", _
        "Type", _
        "Required", _
        "Description", _
        "OptionSource", _
        "SortOrder", _
        "Format", _
        "TemplateLocation", _
        "Status", _
        "FirstDetectedAt", _
        "LastDetectedAt", _
        "__RowIndex")

    For i = 1 To items.Count

        Set item = items(i)

        For Each key In requiredKeys
            If Not item.Exists(CStr(key)) Then
                Debug.Print "FAIL: 3. Active variable item is missing a required key."
                Debug.Print "  ItemIndex=" & CStr(i)
                Debug.Print "  Key      =" & CStr(key)
                Exit Function
            End If
        Next key

        If StrComp(CStr(item("Status")), "Active", vbTextCompare) <> 0 Then
            Debug.Print "FAIL: 3. GetActiveVariableDefinitions returned a non-Active row."
            Debug.Print "  VariableName=" & CStr(item("VariableName"))
            Debug.Print "  Status      =" & CStr(item("Status"))
            Exit Function
        End If

    Next i

    ValidateActiveVariableItems = True

End Function

Private Function ValidateOptionSortOrder( _
    ByVal items As Collection _
) As Boolean

    Dim previousItem As Object
    Dim currentItem As Object
    Dim previousSort As Double
    Dim currentSort As Double
    Dim previousRow As Long
    Dim currentRow As Long
    Dim i As Long

    ValidateOptionSortOrder = False

    If items.Count = 0 Then
        ValidateOptionSortOrder = True
        Exit Function
    End If

    Set previousItem = items(1)

    If Not OptionItemHasRequiredKeys(previousItem, 1) Then
        Exit Function
    End If

    previousSort = CDbl(previousItem("SortOrder"))
    previousRow = CLng(previousItem("__RowIndex"))

    For i = 2 To items.Count

        Set currentItem = items(i)

        If Not OptionItemHasRequiredKeys(currentItem, i) Then
            Exit Function
        End If

        currentSort = CDbl(currentItem("SortOrder"))
        currentRow = CLng(currentItem("__RowIndex"))

        If currentSort < previousSort Then
            Debug.Print "FAIL: 4. OptionMaster result is not sorted by SortOrder ASC."
            Debug.Print "  PreviousSort=" & CStr(previousSort)
            Debug.Print "  CurrentSort =" & CStr(currentSort)
            Exit Function
        End If

        If currentSort = previousSort And currentRow < previousRow Then
            Debug.Print "FAIL: 4. Equal SortOrder does not preserve table row order."
            Debug.Print "  PreviousRow=" & CStr(previousRow)
            Debug.Print "  CurrentRow =" & CStr(currentRow)
            Exit Function
        End If

        Set previousItem = currentItem
        previousSort = currentSort
        previousRow = currentRow

    Next i

    ValidateOptionSortOrder = True

End Function

Private Function OptionItemHasRequiredKeys( _
    ByVal item As Object, _
    ByVal itemIndex As Long _
) As Boolean

    Dim keys As Variant
    Dim key As Variant

    OptionItemHasRequiredKeys = False

    keys = Array( _
        "OptionGroup", _
        "Value", _
        "SortOrder", _
        "Active", _
        "__RowIndex")

    For Each key In keys
        If Not item.Exists(CStr(key)) Then
            Debug.Print "FAIL: 4. Option item is missing a required key."
            Debug.Print "  ItemIndex=" & CStr(itemIndex)
            Debug.Print "  Key      =" & CStr(key)
            Exit Function
        End If
    Next key

    OptionItemHasRequiredKeys = True

End Function

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

    Debug.Print "  Success=" & CStr(result.Success)

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)
        Debug.Print "  Error[" & CStr(i) & "]"
        Debug.Print "    Type   =" & errorInfo.ErrorType
        Debug.Print "    Message=" & errorInfo.Message
        Debug.Print "    Target =" & errorInfo.Target
    Next i

End Sub
