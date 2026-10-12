Attribute VB_Name = "modP2_03SyncPersistenceBootstrapRegressionTest"
Option Explicit

' P2-03 VariableDefinition Sync Persistence
' IF-P2-04-001 Bootstrap Metadata Regression
'
' Production responsibility under test:
'   - validate P2-02 target metadata
'   - persist target metadata
'   - do NOT generate bootstrap values
'
' Entry point:
'   TestP203SyncPersistenceBootstrapRegression
'
' Existing P2-03 Core / Negative tests must also be rerun.

Private Const SHEET_NAME As String = "VariableDefinition"
Private Const TABLE_NAME As String = "tblVariableDefinition"

Private Const KEY_VARIABLE_NAME As String = "VariableName"
Private Const KEY_DISPLAY_NAME As String = "DisplayName"
Private Const KEY_TYPE As String = "Type"
Private Const KEY_REQUIRED As String = "Required"
Private Const KEY_DESCRIPTION As String = "Description"
Private Const KEY_OPTION_SOURCE As String = "OptionSource"
Private Const KEY_SORT_ORDER As String = "SortOrder"
Private Const KEY_FORMAT As String = "Format"
Private Const KEY_TEMPLATE_LOCATION As String = "TemplateLocation"
Private Const KEY_STATUS As String = "Status"
Private Const KEY_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const KEY_LAST_DETECTED_AT As String = "LastDetectedAt"

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private mPassCount As Long
Private mFailCount As Long

Public Sub TestP203SyncPersistenceBootstrapRegression()

    Dim lo As ListObject
    Dim originalRows As Collection

    Debug.Print String$(76, "=")
    Debug.Print "P2-03 Sync Persistence - Bootstrap Metadata Regression"
    Debug.Print "IF-P2-04-001"
    Debug.Print String$(76, "=")

    mPassCount = 0
    mFailCount = 0

    On Error GoTo FatalError

    Set lo = GetTestTable()
    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: tblVariableDefinition was not found."
        Exit Sub
    End If

    If Not HasRequiredColumns(lo) Then
        Debug.Print "PRECONDITION FAIL: Required VariableDefinition columns are missing."
        Exit Sub
    End If

    Set originalRows = CaptureRows(lo)

    RecordCaseResult "R01 Unused Bootstrap Persistence", TestR01_UnusedBootstrap(lo)
    RecordCaseResult "R02 Unused Initialized Persistence", TestR02_UnusedInitialized(lo)
    RecordCaseResult "R03 New Requires Date Metadata", TestR03_NewRequiresDates(lo)
    RecordCaseResult "R04 Existing Requires Date Metadata", TestR04_ExistingRequiresDates(lo)
    RecordCaseResult "R05 Reactivated Requires Date Metadata", TestR05_ReactivatedRequiresDates(lo)
    RecordCaseResult "R06 Unused Partial Metadata Rejected", TestR06_UnusedPartialRejected(lo)
    RecordCaseResult "R07 Unused Invalid Non-empty Metadata Rejected", TestR07_UnusedInvalidDateRejected(lo)

    RestoreRows lo, originalRows

    Debug.Print String$(76, "-")
    Debug.Print "PASS Count = " & CStr(mPassCount)
    Debug.Print "FAIL Count = " & CStr(mFailCount)

    If mFailCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print "Original tblVariableDefinition contents restored."
    Debug.Print String$(76, "=")
    Exit Sub

FatalError:
    Debug.Print "FATAL TEST HARNESS ERROR:"
    Debug.Print "  Number = " & CStr(Err.Number)
    Debug.Print "  Description = " & Err.Description

    On Error Resume Next
    If Not lo Is Nothing Then
        If Not originalRows Is Nothing Then
            RestoreRows lo, originalRows
            Debug.Print "Original tblVariableDefinition contents restored after fatal error."
        End If
    End If
    On Error GoTo 0

    Debug.Print "Overall = ABORTED"
    Debug.Print String$(76, "=")

End Sub

Private Function TestR01_UnusedBootstrap(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult

    ClearTable lo

    AddFixtureRow lo, _
        "OldVariable", _
        "Old Display", _
        "Text", _
        True, _
        "Keep me", _
        vbNullString, _
        10, _
        vbNullString, _
        Empty, _
        "Active", _
        Empty, _
        Empty

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem( _
            "OldVariable", _
            Empty, _
            "Unused", _
            Empty, _
            Empty)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("R01 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("R01 Row Count", 1, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Unused", "R01 Status") Then Exit Function
    If Not AssertEmptyCell(lo, 1, KEY_TEMPLATE_LOCATION, "R01 TemplateLocation") Then Exit Function
    If Not AssertEmptyCell(lo, 1, KEY_FIRST_DETECTED_AT, "R01 FirstDetectedAt") Then Exit Function
    If Not AssertEmptyCell(lo, 1, KEY_LAST_DETECTED_AT, "R01 LastDetectedAt") Then Exit Function

    If Not AssertTextCell(lo, 1, KEY_DISPLAY_NAME, "Old Display", "R01 DisplayName preserved") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TYPE, "Text", "R01 Type preserved") Then Exit Function
    If Not AssertBooleanCell(lo, 1, KEY_REQUIRED, True, "R01 Required preserved") Then Exit Function
    If Not AssertNumericCell(lo, 1, KEY_SORT_ORDER, 10, "R01 SortOrder preserved") Then Exit Function

    TestR01_UnusedBootstrap = True

End Function

Private Function TestR02_UnusedInitialized(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    firstDetectedAt = DateSerial(2026, 7, 1)
    lastDetectedAt = DateSerial(2026, 9, 20) + TimeSerial(10, 0, 0)

    ClearTable lo

    AddFixtureRow lo, _
        "UnusedVar", _
        "Unused Display", _
        "Text", _
        False, _
        "Initialized metadata", _
        vbNullString, _
        20, _
        vbNullString, _
        "Body", _
        "Active", _
        firstDetectedAt, _
        lastDetectedAt

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem( _
            "UnusedVar", _
            "Body", _
            "Unused", _
            firstDetectedAt, _
            lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("R02 ApplySyncDiff", result) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Unused", "R02 Status") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Body", "R02 TemplateLocation") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, firstDetectedAt, "R02 FirstDetectedAt") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, lastDetectedAt, "R02 LastDetectedAt") Then Exit Function

    TestR02_UnusedInitialized = True

End Function

Private Function TestR03_NewRequiresDates(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim lastDetectedAt As Date

    lastDetectedAt = DateSerial(2026, 10, 1) + TimeSerial(12, 3, 0)

    ClearTable lo
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem( _
            "NewVar", _
            "Body", _
            "Active", _
            Empty, _
            lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure("R03 ApplySyncDiff", result) Then Exit Function
    If Not AssertMessageContains(result, KEY_FIRST_DETECTED_AT, "R03") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "R03 Write=0") Then Exit Function

    TestR03_NewRequiresDates = True

End Function

Private Function TestR04_ExistingRequiresDates(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim oldFirst As Date
    Dim oldLast As Date
    Dim newLast As Date

    oldFirst = DateSerial(2026, 7, 1)
    oldLast = DateSerial(2026, 9, 1)
    newLast = DateSerial(2026, 10, 1) + TimeSerial(12, 4, 0)

    ClearTable lo
    AddFixtureRow lo, _
        "ExistingVar", _
        "Existing", _
        "Text", _
        True, _
        "Existing fixture", _
        vbNullString, _
        10, _
        vbNullString, _
        "Subject", _
        "Active", _
        oldFirst, _
        oldLast

    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, _
        CreateDiffItem( _
            "ExistingVar", _
            "Both", _
            "Active", _
            Empty, _
            newLast)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure("R04 ApplySyncDiff", result) Then Exit Function
    If Not AssertMessageContains(result, KEY_FIRST_DETECTED_AT, "R04") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "R04 Write=0") Then Exit Function

    TestR04_ExistingRequiresDates = True

End Function

Private Function TestR05_ReactivatedRequiresDates(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim oldFirst As Date
    Dim oldLast As Date
    Dim newLast As Date

    oldFirst = DateSerial(2026, 6, 1)
    oldLast = DateSerial(2026, 8, 1)
    newLast = DateSerial(2026, 10, 1) + TimeSerial(12, 5, 0)

    ClearTable lo
    AddFixtureRow lo, _
        "ReactivatedVar", _
        "Reactivated", _
        "Text", _
        False, _
        "Reactivated fixture", _
        vbNullString, _
        20, _
        vbNullString, _
        "Body", _
        "Unused", _
        oldFirst, _
        oldLast

    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_REACTIVATED, _
        CreateDiffItem( _
            "ReactivatedVar", _
            "Subject", _
            "Active", _
            Empty, _
            newLast)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure("R05 ApplySyncDiff", result) Then Exit Function
    If Not AssertMessageContains(result, KEY_FIRST_DETECTED_AT, "R05") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "R05 Write=0") Then Exit Function

    TestR05_ReactivatedRequiresDates = True

End Function

Private Function TestR06_UnusedPartialRejected(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim lastDetectedAt As Date

    lastDetectedAt = DateSerial(2026, 9, 15)

    ClearTable lo
    AddFixtureRow lo, _
        "PartialUnused", _
        "Partial", _
        "Text", _
        True, _
        "Partial fixture", _
        vbNullString, _
        30, _
        vbNullString, _
        Empty, _
        "Active", _
        Empty, _
        Empty

    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem( _
            "PartialUnused", _
            Empty, _
            "Unused", _
            Empty, _
            lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure("R06 ApplySyncDiff", result) Then Exit Function
    If Not AssertMessageContains(result, "partially initialized", "R06") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "R06 Write=0") Then Exit Function

    TestR06_UnusedPartialRejected = True

End Function

Private Function TestR07_UnusedInvalidDateRejected(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim lastDetectedAt As Date

    lastDetectedAt = DateSerial(2026, 9, 15)

    ClearTable lo
    AddFixtureRow lo, _
        "InvalidUnused", _
        "Invalid", _
        "Text", _
        True, _
        "Invalid date fixture", _
        vbNullString, _
        40, _
        vbNullString, _
        "Body", _
        "Active", _
        DateSerial(2026, 7, 1), _
        DateSerial(2026, 8, 1)

    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem( _
            "InvalidUnused", _
            "Body", _
            "Unused", _
            "not-a-date", _
            lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure("R07 ApplySyncDiff", result) Then Exit Function
    If Not AssertMessageContains(result, KEY_FIRST_DETECTED_AT, "R07") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "R07 Write=0") Then Exit Function

    TestR07_UnusedInvalidDateRejected = True

End Function

Private Function GetTestTable() As ListObject

    Dim ws As Worksheet

    On Error GoTo Failed

    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)
    Set GetTestTable = ws.ListObjects(TABLE_NAME)
    Exit Function

Failed:
    Set GetTestTable = Nothing

End Function

Private Function HasRequiredColumns(ByVal lo As ListObject) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn

    columns = Array( _
        KEY_VARIABLE_NAME, _
        KEY_DISPLAY_NAME, _
        KEY_TYPE, _
        KEY_REQUIRED, _
        KEY_DESCRIPTION, _
        KEY_OPTION_SOURCE, _
        KEY_SORT_ORDER, _
        KEY_FORMAT, _
        KEY_TEMPLATE_LOCATION, _
        KEY_STATUS, _
        KEY_FIRST_DETECTED_AT, _
        KEY_LAST_DETECTED_AT)

    On Error GoTo Failed

    For Each columnName In columns
        Set lc = lo.ListColumns(CStr(columnName))
    Next columnName

    HasRequiredColumns = True
    Exit Function

Failed:
    HasRequiredColumns = False

End Function

Private Function CreateEmptySyncDiff() As Object

    Dim diff As Object
    Dim items As Collection

    Set diff = CreateObject("Scripting.Dictionary")
    diff.CompareMode = vbTextCompare

    Set items = New Collection
    diff.Add SYNC_NEW, items

    Set items = New Collection
    diff.Add SYNC_EXISTING, items

    Set items = New Collection
    diff.Add SYNC_REACTIVATED, items

    Set items = New Collection
    diff.Add SYNC_UNUSED, items

    Set CreateEmptySyncDiff = diff

End Function

Private Sub AddDiffItem( _
    ByVal diff As Object, _
    ByVal classification As String, _
    ByVal item As Object _
)

    Dim items As Collection

    Set items = diff(classification)
    items.Add item

End Sub

Private Function CreateDiffItem( _
    ByVal variableName As String, _
    ByVal templateLocation As Variant, _
    ByVal statusValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
) As Object

    Dim item As Object

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add KEY_VARIABLE_NAME, variableName
    item.Add KEY_TEMPLATE_LOCATION, templateLocation
    item.Add KEY_STATUS, statusValue
    item.Add KEY_FIRST_DETECTED_AT, firstDetectedAt
    item.Add KEY_LAST_DETECTED_AT, lastDetectedAt

    Set CreateDiffItem = item

End Function

Private Sub AddFixtureRow( _
    ByVal lo As ListObject, _
    ByVal variableName As String, _
    ByVal displayName As Variant, _
    ByVal typeValue As Variant, _
    ByVal requiredValue As Variant, _
    ByVal descriptionValue As Variant, _
    ByVal optionSourceValue As Variant, _
    ByVal sortOrderValue As Variant, _
    ByVal formatValue As Variant, _
    ByVal templateLocation As Variant, _
    ByVal statusValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
)

    Dim row As ListRow
    Dim rowIndex As Long

    Set row = lo.ListRows.Add
    rowIndex = row.Index

    WriteCell lo, rowIndex, KEY_VARIABLE_NAME, variableName
    WriteCell lo, rowIndex, KEY_DISPLAY_NAME, displayName
    WriteCell lo, rowIndex, KEY_TYPE, typeValue
    WriteCell lo, rowIndex, KEY_REQUIRED, requiredValue
    WriteCell lo, rowIndex, KEY_DESCRIPTION, descriptionValue
    WriteCell lo, rowIndex, KEY_OPTION_SOURCE, optionSourceValue
    WriteCell lo, rowIndex, KEY_SORT_ORDER, sortOrderValue
    WriteCell lo, rowIndex, KEY_FORMAT, formatValue
    WriteCell lo, rowIndex, KEY_TEMPLATE_LOCATION, templateLocation
    WriteCell lo, rowIndex, KEY_STATUS, statusValue
    WriteCell lo, rowIndex, KEY_FIRST_DETECTED_AT, firstDetectedAt
    WriteCell lo, rowIndex, KEY_LAST_DETECTED_AT, lastDetectedAt

End Sub

Private Sub WriteCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal value As Variant _
)

    If IsEmpty(value) Then
        lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).ClearContents
    Else
        lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2 = value
    End If

End Sub

Private Sub ClearTable(ByVal lo As ListObject)

    Do While lo.ListRows.Count > 0
        lo.ListRows(1).Delete
    Loop

End Sub

Private Function CaptureRows(ByVal lo As ListObject) As Collection

    Dim rows As Collection
    Dim rowSnapshot As Object
    Dim columns As Variant
    Dim columnName As Variant
    Dim rowIndex As Long

    Set rows = New Collection

    If lo.DataBodyRange Is Nothing Then
        Set CaptureRows = rows
        Exit Function
    End If

    columns = RequiredColumns()

    For rowIndex = 1 To lo.ListRows.Count
        Set rowSnapshot = CreateObject("Scripting.Dictionary")
        rowSnapshot.CompareMode = vbTextCompare

        For Each columnName In columns
            rowSnapshot.Add CStr(columnName), _
                lo.ListColumns(CStr(columnName)).DataBodyRange.Cells(rowIndex, 1).Value2
        Next columnName

        rows.Add rowSnapshot
    Next rowIndex

    Set CaptureRows = rows

End Function

Private Sub RestoreRows( _
    ByVal lo As ListObject, _
    ByVal rows As Collection _
)

    Dim rowSnapshot As Object
    Dim row As ListRow
    Dim columns As Variant
    Dim columnName As Variant
    Dim rowIndex As Long

    ClearTable lo
    columns = RequiredColumns()

    For Each rowSnapshot In rows
        Set row = lo.ListRows.Add
        rowIndex = row.Index

        For Each columnName In columns
            WriteCell lo, rowIndex, CStr(columnName), rowSnapshot(CStr(columnName))
        Next columnName
    Next rowSnapshot

End Sub

Private Function RequiredColumns() As Variant

    RequiredColumns = Array( _
        KEY_VARIABLE_NAME, _
        KEY_DISPLAY_NAME, _
        KEY_TYPE, _
        KEY_REQUIRED, _
        KEY_DESCRIPTION, _
        KEY_OPTION_SOURCE, _
        KEY_SORT_ORDER, _
        KEY_FORMAT, _
        KEY_TEMPLATE_LOCATION, _
        KEY_STATUS, _
        KEY_FIRST_DETECTED_AT, _
        KEY_LAST_DETECTED_AT)

End Function

Private Function AssertTableMatchesSnapshot( _
    ByVal lo As ListObject, _
    ByVal expectedRows As Collection, _
    ByVal label As String _
) As Boolean

    Dim actualRows As Collection
    Dim expectedRow As Object
    Dim actualRow As Object
    Dim columns As Variant
    Dim columnName As Variant
    Dim i As Long

    Set actualRows = CaptureRows(lo)

    If actualRows.Count <> expectedRows.Count Then
        Debug.Print "  FAIL DETAIL: " & label & " row count mismatch."
        Exit Function
    End If

    columns = RequiredColumns()

    For i = 1 To expectedRows.Count
        Set expectedRow = expectedRows(i)
        Set actualRow = actualRows(i)

        For Each columnName In columns
            If Not VariantValuesEqual( _
                expectedRow(CStr(columnName)), _
                actualRow(CStr(columnName))) Then

                Debug.Print "  FAIL DETAIL: " & label & _
                    " mismatch at row " & CStr(i) & _
                    ", column " & CStr(columnName)
                Exit Function
            End If
        Next columnName
    Next i

    AssertTableMatchesSnapshot = True

End Function

Private Function VariantValuesEqual( _
    ByVal leftValue As Variant, _
    ByVal rightValue As Variant _
) As Boolean

    If IsError(leftValue) Or IsError(rightValue) Then Exit Function

    If IsEmpty(leftValue) And IsEmpty(rightValue) Then
        VariantValuesEqual = True
        Exit Function
    End If

    If IsNull(leftValue) Or IsNull(rightValue) Then
        VariantValuesEqual = (IsNull(leftValue) And IsNull(rightValue))
        Exit Function
    End If

    If IsNumeric(leftValue) And IsNumeric(rightValue) Then
        VariantValuesEqual = (CDbl(leftValue) = CDbl(rightValue))
        Exit Function
    End If

    VariantValuesEqual = (CStr(leftValue) = CStr(rightValue))

End Function

Private Function AssertSuccess( _
    ByVal label As String, _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then
        Debug.Print "  FAIL DETAIL: " & label & " returned Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print "  FAIL DETAIL: " & label & " returned Failure."
        PrintResultErrors result
        Exit Function
    End If

    AssertSuccess = True

End Function

Private Function AssertFailure( _
    ByVal label As String, _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then
        Debug.Print "  FAIL DETAIL: " & label & " returned Nothing."
        Exit Function
    End If

    If result.Success Then
        Debug.Print "  FAIL DETAIL: " & label & " unexpectedly returned Success."
        Exit Function
    End If

    AssertFailure = True

End Function

Private Function AssertMessageContains( _
    ByVal result As COperationResult, _
    ByVal expectedText As String, _
    ByVal label As String _
) As Boolean

    Dim errorInfo As CErrorInfo

    If result Is Nothing Then Exit Function

    For Each errorInfo In result.Errors
        If InStr(1, errorInfo.Message, expectedText, vbTextCompare) > 0 Then
            AssertMessageContains = True
            Exit Function
        End If
    Next errorInfo

    Debug.Print "  FAIL DETAIL: " & label & _
        " did not contain expected message text: " & expectedText
    PrintResultErrors result

End Function

Private Function AssertLong( _
    ByVal label As String, _
    ByVal expectedValue As Long, _
    ByVal actualValue As Long _
) As Boolean

    If expectedValue <> actualValue Then
        Debug.Print "  FAIL DETAIL: " & label & _
            " expected=" & CStr(expectedValue) & _
            " actual=" & CStr(actualValue)
        Exit Function
    End If

    AssertLong = True

End Function

Private Function AssertTextCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As String, _
    ByVal label As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If CStr(actualValue) <> expectedValue Then
        Debug.Print "  FAIL DETAIL: " & label & _
            " expected=[" & expectedValue & "]" & _
            " actual=[" & CStr(actualValue) & "]"
        Exit Function
    End If

    AssertTextCell = True

End Function

Private Function AssertEmptyCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal label As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If Not IsEmpty(actualValue) Then
        Debug.Print "  FAIL DETAIL: " & label & _
            " expected Empty, actual=[" & CStr(actualValue) & "]"
        Exit Function
    End If

    AssertEmptyCell = True

End Function

Private Function AssertDateCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As Date, _
    ByVal label As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    On Error GoTo Failed

    If CDbl(actualValue) <> CDbl(expectedValue) Then
        GoTo Failed
    End If

    AssertDateCell = True
    Exit Function

Failed:
    Debug.Print "  FAIL DETAIL: " & label & " date mismatch."

End Function

Private Function AssertBooleanCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As Boolean, _
    ByVal label As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If CBool(actualValue) <> expectedValue Then
        Debug.Print "  FAIL DETAIL: " & label & " boolean mismatch."
        Exit Function
    End If

    AssertBooleanCell = True

End Function

Private Function AssertNumericCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As Double, _
    ByVal label As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If Not IsNumeric(actualValue) Then
        Debug.Print "  FAIL DETAIL: " & label & " is not numeric."
        Exit Function
    End If

    If CDbl(actualValue) <> expectedValue Then
        Debug.Print "  FAIL DETAIL: " & label & " numeric mismatch."
        Exit Function
    End If

    AssertNumericCell = True

End Function

Private Sub RecordCaseResult( _
    ByVal caseName As String, _
    ByVal passed As Boolean _
)

    If passed Then
        mPassCount = mPassCount + 1
        Debug.Print "PASS  " & caseName
    Else
        mFailCount = mFailCount + 1
        Debug.Print "FAIL  " & caseName
    End If

End Sub

Private Sub PrintResultErrors(ByVal result As COperationResult)

    Dim errorInfo As CErrorInfo

    If result Is Nothing Then Exit Sub

    For Each errorInfo In result.Errors
        Debug.Print "    ErrorType=" & errorInfo.ErrorType & _
            "; Target=" & errorInfo.Target & _
            "; Message=" & errorInfo.Message
    Next errorInfo

End Sub
