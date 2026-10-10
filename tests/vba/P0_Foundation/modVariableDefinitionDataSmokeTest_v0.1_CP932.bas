Attribute VB_Name = "modVariableDefinitionDataSmokeTest"
Option Explicit

Private Const SHEET_NAME As String = "VariableDefinition"
Private Const TABLE_NAME As String = "tblVariableDefinition"

Public Sub TestVariableDefinitionData()

    Dim result As COperationResult
    Dim allItems As Collection
    Dim activeItems As Collection
    Dim item As Object
    Dim expectedAllCount As Long
    Dim expectedActiveCount As Long
    Dim i As Long

    Debug.Print "TestVariableDefinitionData: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name

    If Not ValidateVariableDefinitionFixture(expectedAllCount, expectedActiveCount) Then
        Debug.Print "TestVariableDefinitionData: FAIL (PRECONDITION)"
        Exit Sub
    End If

    ' 1. Read all rows.
    Set result = GetAllVariableDefinitions(allItems)

    If Not result.Success Then
        PrintResultErrors "1. GetAllVariableDefinitions failed", result
        Debug.Print "TestVariableDefinitionData: FAIL"
        Exit Sub
    End If

    If allItems.Count <> expectedAllCount Then
        Debug.Print "FAIL: 1. All count mismatch."
        Debug.Print "  Expected=" & CStr(expectedAllCount)
        Debug.Print "  Actual  =" & CStr(allItems.Count)
        Debug.Print "TestVariableDefinitionData: FAIL"
        Exit Sub
    End If

    ' 2. Every item has the required keys and a stable table row index.
    For i = 1 To allItems.Count

        Set item = allItems(i)

        If Not ValidateItemKeys(item, i) Then
            Debug.Print "TestVariableDefinitionData: FAIL"
            Exit Sub
        End If

        If CLng(item("__RowIndex")) <> i Then
            Debug.Print "FAIL: 2. __RowIndex mismatch."
            Debug.Print "  CollectionIndex=" & CStr(i)
            Debug.Print "  __RowIndex     =" & CStr(item("__RowIndex"))
            Debug.Print "TestVariableDefinitionData: FAIL"
            Exit Sub
        End If

    Next i

    ' 3. Read Active rows only.
    Set result = GetActiveVariableDefinitions(activeItems)

    If Not result.Success Then
        PrintResultErrors "3. GetActiveVariableDefinitions failed", result
        Debug.Print "TestVariableDefinitionData: FAIL"
        Exit Sub
    End If

    If activeItems.Count <> expectedActiveCount Then
        Debug.Print "FAIL: 3. Active count mismatch."
        Debug.Print "  Expected=" & CStr(expectedActiveCount)
        Debug.Print "  Actual  =" & CStr(activeItems.Count)
        Debug.Print "TestVariableDefinitionData: FAIL"
        Exit Sub
    End If

    For Each item In activeItems
        If StrComp(CStr(item("Status")), "Active", vbTextCompare) <> 0 Then
            Debug.Print "FAIL: 3. Non-Active row returned by GetActiveVariableDefinitions."
            Debug.Print "  VariableName=" & CStr(item("VariableName"))
            Debug.Print "  Status      =" & CStr(item("Status"))
            Debug.Print "TestVariableDefinitionData: FAIL"
            Exit Sub
        End If
    Next item

    ' 4. Returned dictionaries are case-insensitive.
    Set item = allItems(1)

    If StrComp( _
        CStr(item("VariableName")), _
        CStr(item("variablename")), _
        vbBinaryCompare) <> 0 Then

        Debug.Print "FAIL: 4. Dictionary key lookup is not case-insensitive."
        Debug.Print "TestVariableDefinitionData: FAIL"
        Exit Sub
    End If

    Debug.Print "TestVariableDefinitionData: PASS"

End Sub

Private Function ValidateVariableDefinitionFixture( _
    ByRef expectedAllCount As Long, _
    ByRef expectedActiveCount As Long _
) As Boolean

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim requiredColumns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn
    Dim rowIndex As Long
    Dim statusValue As Variant
    Dim activeCount As Long
    Dim unusedCount As Long

    ValidateVariableDefinitionFixture = False
    expectedAllCount = 0
    expectedActiveCount = 0

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)
    On Error GoTo 0

    If ws Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Worksheet 'VariableDefinition' was not found."
        Exit Function
    End If

    On Error Resume Next
    Set lo = ws.ListObjects(TABLE_NAME)
    On Error GoTo 0

    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Table 'tblVariableDefinition' was not found."
        Exit Function
    End If

    requiredColumns = Array( _
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
        "LastDetectedAt")

    For Each columnName In requiredColumns

        Set lc = Nothing

        On Error Resume Next
        Set lc = lo.ListColumns(CStr(columnName))
        On Error GoTo 0

        If lc Is Nothing Then
            Debug.Print "PRECONDITION FAIL: Required column was not found: " & CStr(columnName)
            Exit Function
        End If

    Next columnName

    If lo.DataBodyRange Is Nothing Then
        Debug.Print "PRECONDITION FAIL: tblVariableDefinition has no data rows."
        Debug.Print "Add at least one Active row and one Unused row for this smoke test."
        Exit Function
    End If

    expectedAllCount = lo.ListRows.Count

    For rowIndex = 1 To lo.ListRows.Count

        statusValue = lo.ListColumns("Status").DataBodyRange.Cells(rowIndex, 1).Value2

        If IsError(statusValue) Then
            Debug.Print "PRECONDITION FAIL: Status contains an Excel error at row " & CStr(rowIndex)
            Exit Function
        End If

        If StrComp(CStr(statusValue), "Active", vbTextCompare) = 0 Then
            activeCount = activeCount + 1
        ElseIf StrComp(CStr(statusValue), "Unused", vbTextCompare) = 0 Then
            unusedCount = unusedCount + 1
        End If

    Next rowIndex

    If activeCount = 0 Then
        Debug.Print "PRECONDITION FAIL: Add at least one row with Status=Active."
        Exit Function
    End If

    If unusedCount = 0 Then
        Debug.Print "PRECONDITION FAIL: Add at least one row with Status=Unused."
        Exit Function
    End If

    expectedActiveCount = activeCount
    ValidateVariableDefinitionFixture = True

End Function

Private Function ValidateItemKeys( _
    ByVal item As Object, _
    ByVal collectionIndex As Long _
) As Boolean

    Dim requiredKeys As Variant
    Dim key As Variant

    ValidateItemKeys = False

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

    For Each key In requiredKeys

        If Not item.Exists(CStr(key)) Then
            Debug.Print "FAIL: 2. Missing dictionary key."
            Debug.Print "  CollectionIndex=" & CStr(collectionIndex)
            Debug.Print "  Key            =" & CStr(key)
            Exit Function
        End If

    Next key

    ValidateItemKeys = True

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
