Attribute VB_Name = "modOptionMasterDataSmokeTest"
Option Explicit

Private Const SHEET_NAME As String = "OptionMaster"
Private Const TABLE_NAME As String = "tblOptionMaster"
Private Const TEST_GROUP As String = "__SmokeTestGroup__"

Public Sub TestOptionMasterData()

    Dim result As COperationResult
    Dim items As Collection
    Dim item As Object
    Dim expectedValues As Collection
    Dim i As Long

    Debug.Print "TestOptionMasterData: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name

    If Not ValidateOptionMasterFixture(expectedValues) Then
        Debug.Print "TestOptionMasterData: FAIL (PRECONDITION)"
        Exit Sub
    End If

    Set result = GetActiveOptions(TEST_GROUP, items)

    If Not result.Success Then
        PrintResultErrors "1. GetActiveOptions failed", result
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    If items.Count <> expectedValues.Count Then
        Debug.Print "FAIL: 1. Active option count mismatch."
        Debug.Print "  Expected=" & CStr(expectedValues.Count)
        Debug.Print "  Actual  =" & CStr(items.Count)
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    For i = 1 To items.Count

        Set item = items(i)

        If CStr(item("Value")) <> CStr(expectedValues(i)) Then
            Debug.Print "FAIL: 2. Sort order mismatch."
            Debug.Print "  Position=" & CStr(i)
            Debug.Print "  Expected=" & CStr(expectedValues(i))
            Debug.Print "  Actual  =" & CStr(item("Value"))
            Debug.Print "TestOptionMasterData: FAIL"
            Exit Sub
        End If

        If Not ItemHasRequiredKeys(item) Then
            Debug.Print "FAIL: 2. Returned item is missing required keys."
            Debug.Print "  Position=" & CStr(i)
            Debug.Print "TestOptionMasterData: FAIL"
            Exit Sub
        End If

    Next i

    Set result = GetActiveOptions("__UnknownOptionGroup__", items)

    If Not result.Success Then
        PrintResultErrors "3. Unknown group should not be a Data Access error", result
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    If items.Count <> 0 Then
        Debug.Print "FAIL: 3. Unknown group should return an empty Collection."
        Debug.Print "  Actual Count=" & CStr(items.Count)
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    Set result = GetActiveOptions(vbNullString, items)

    If result.Success Then
        Debug.Print "FAIL: 4. Empty OptionGroup unexpectedly returned Success."
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    If result.Errors.Count = 0 Then
        Debug.Print "FAIL: 4. Empty OptionGroup returned no error detail."
        Debug.Print "TestOptionMasterData: FAIL"
        Exit Sub
    End If

    Debug.Print "TestOptionMasterData: PASS"

End Sub

Private Function ValidateOptionMasterFixture( _
    ByRef expectedValues As Collection _
) As Boolean

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim requiredColumns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn
    Dim rowIndex As Long
    Dim groupValue As Variant
    Dim valueValue As Variant
    Dim sortValue As Variant
    Dim activeValue As Variant
    Dim tempItems As Collection
    Dim activeCount As Long
    Dim inactiveCount As Long

    ValidateOptionMasterFixture = False
    Set expectedValues = New Collection
    Set tempItems = New Collection

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)
    On Error GoTo 0

    If ws Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Worksheet 'OptionMaster' was not found."
        Exit Function
    End If

    On Error Resume Next
    Set lo = ws.ListObjects(TABLE_NAME)
    On Error GoTo 0

    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: Table 'tblOptionMaster' was not found."
        Exit Function
    End If

    requiredColumns = Array("OptionGroup", "Value", "SortOrder", "Active")

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
        PrintFixtureInstructions
        Exit Function
    End If

    For rowIndex = 1 To lo.ListRows.Count

        groupValue = lo.ListColumns("OptionGroup").DataBodyRange.Cells(rowIndex, 1).Value2

        If StrComp(CStr(groupValue), TEST_GROUP, vbBinaryCompare) = 0 Then

            valueValue = lo.ListColumns("Value").DataBodyRange.Cells(rowIndex, 1).Value2
            sortValue = lo.ListColumns("SortOrder").DataBodyRange.Cells(rowIndex, 1).Value2
            activeValue = lo.ListColumns("Active").DataBodyRange.Cells(rowIndex, 1).Value2

            If IsError(valueValue) Or IsError(sortValue) Or IsError(activeValue) Then
                Debug.Print "PRECONDITION FAIL: Smoke test fixture contains an Excel error."
                Exit Function
            End If

            If IsSmokeActive(activeValue) Then

                If Len(Trim$(CStr(sortValue))) = 0 Or Not IsNumeric(sortValue) Then
                    Debug.Print "PRECONDITION FAIL: Active smoke test option has invalid SortOrder."
                    Exit Function
                End If

                InsertExpectedValue tempItems, CStr(valueValue), CDbl(sortValue), rowIndex
                activeCount = activeCount + 1

            Else
                inactiveCount = inactiveCount + 1
            End If

        End If

    Next rowIndex

    If activeCount < 2 Or inactiveCount < 1 Then
        PrintFixtureInstructions
        Exit Function
    End If

    CopyExpectedValues tempItems, expectedValues
    ValidateOptionMasterFixture = True

End Function

Private Function IsSmokeActive(ByVal rawValue As Variant) As Boolean

    Dim normalized As String

    If VarType(rawValue) = vbBoolean Then
        IsSmokeActive = CBool(rawValue)
        Exit Function
    End If

    If IsNumeric(rawValue) Then
        IsSmokeActive = (CDbl(rawValue) = 1)
        Exit Function
    End If

    normalized = LCase$(Trim$(CStr(rawValue)))
    IsSmokeActive = (normalized = "true")

End Function

Private Sub InsertExpectedValue( _
    ByRef items As Collection, _
    ByVal optionValue As String, _
    ByVal sortOrder As Double, _
    ByVal rowIndex As Long _
)

    Dim sortedItems As Collection
    Dim current As Variant
    Dim currentSort As Double
    Dim currentRow As Long
    Dim inserted As Boolean
    Dim i As Long
    Dim entry(0 To 2) As Variant

    entry(0) = optionValue
    entry(1) = sortOrder
    entry(2) = rowIndex

    Set sortedItems = New Collection

    For i = 1 To items.Count

        current = items(i)
        currentSort = CDbl(current(1))
        currentRow = CLng(current(2))

        If Not inserted Then
            If sortOrder < currentSort Or _
               (sortOrder = currentSort And rowIndex < currentRow) Then

                sortedItems.Add entry
                inserted = True
            End If
        End If

        sortedItems.Add current

    Next i

    If Not inserted Then
        sortedItems.Add entry
    End If

    Set items = sortedItems

End Sub

Private Sub CopyExpectedValues( _
    ByVal sourceItems As Collection, _
    ByRef expectedValues As Collection _
)

    Dim entry As Variant
    Dim i As Long

    Set expectedValues = New Collection

    For i = 1 To sourceItems.Count
        entry = sourceItems(i)
        expectedValues.Add CStr(entry(0))
    Next i

End Sub

Private Function ItemHasRequiredKeys(ByVal item As Object) As Boolean

    Dim keys As Variant
    Dim key As Variant

    keys = Array("OptionGroup", "Value", "SortOrder", "Active", "__RowIndex")

    For Each key In keys
        If Not item.Exists(CStr(key)) Then
            ItemHasRequiredKeys = False
            Exit Function
        End If
    Next key

    ItemHasRequiredKeys = True

End Function

Private Sub PrintFixtureInstructions()

    Debug.Print "PRECONDITION FAIL: Prepare smoke test rows in tblOptionMaster."
    Debug.Print "Use OptionGroup = " & TEST_GROUP
    Debug.Print "Example:"
    Debug.Print "  OptionGroup          Value     SortOrder  Active"
    Debug.Print "  " & TEST_GROUP & "  Second    20         True"
    Debug.Print "  " & TEST_GROUP & "  Disabled  10         False"
    Debug.Print "  " & TEST_GROUP & "  First      5         True"
    Debug.Print "At least two Active rows and one inactive row are required."

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
