Attribute VB_Name = "modP2_02P2_03BootstrapProductionCompatibilityTest"
Option Explicit

' P2-02 -> P2-03 Bootstrap Production Compatibility
' IF-P2-04-001
'
' Purpose:
'   Verify the real lower-layer production pipeline for the workbook state that
'   originally exposed IF-P2-04-001.
'
' Production path under test:
'   tblVariableDefinition fixture
'   -> GetAllVariableDefinitions
'   -> BuildSyncDiff
'   -> ApplySyncDiff
'   -> tblVariableDefinition
'
' Entry point:
'   TestP202P203BootstrapProductionCompatibility
'
' This is Implementation Verification, not Formal MVP Test.

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

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"

Private Const LOCATION_SUBJECT As String = "Subject"
Private Const LOCATION_BODY As String = "Body"

Private mPassCount As Long
Private mFailCount As Long

Public Sub TestP202P203BootstrapProductionCompatibility()

    Dim lo As ListObject
    Dim originalRows As Collection
    Dim currentDefinitions As Collection
    Dim scanResult As Object
    Dim syncDiffResult As Object
    Dim result As COperationResult
    Dim syncTimestamp As Date
    Dim existingItems As Collection
    Dim existingItem As Object

    Debug.Print String$(82, "=")
    Debug.Print "P2-02 -> P2-03 Bootstrap Production Compatibility"
    Debug.Print "Execution Baseline = BL-MVP-004"
    Debug.Print "IF-P2-04-001"
    Debug.Print "ThisWorkbook = " & ThisWorkbook.Name
    Debug.Print String$(82, "=")

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

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(16, 30, 0)

    ' -----------------------------------------------------------------
    ' Root-cause fixture:
    '
    ' ModelName
    '   Active / Subject / Empty / Empty
    '
    ' OldVariable
    '   Unused / Body / Empty / Empty
    ' -----------------------------------------------------------------
    ClearTable lo

    AddFixtureRow lo, _
        "ModelName", _
        "Model Display", _
        "Text", _
        True, _
        "Model description", _
        vbNullString, _
        10, _
        vbNullString, _
        LOCATION_SUBJECT, _
        STATUS_ACTIVE, _
        Empty, _
        Empty

    AddFixtureRow lo, _
        "OldVariable", _
        "Old Display", _
        "Select", _
        False, _
        "Old description", _
        "LegacyOptions", _
        20, _
        vbNullString, _
        LOCATION_BODY, _
        STATUS_UNUSED, _
        Empty, _
        Empty

    Set result = GetAllVariableDefinitions(currentDefinitions)

    RecordResult ResultSucceeded(result), _
        "K-B01 GetAllVariableDefinitions returns Success"

    If Not ResultSucceeded(result) Then GoTo VerificationEnd

    RecordResult currentDefinitions.Count = 2, _
        "K-B02 CurrentDefinitions.Count = 2"

    RecordResult DefinitionMatchesBootstrapState( _
        currentDefinitions, _
        "ModelName", _
        STATUS_ACTIVE, _
        LOCATION_SUBJECT), _
        "K-B03 ModelName carrier = Active / Subject / Blank-Blank"

    RecordResult DefinitionMatchesBootstrapState( _
        currentDefinitions, _
        "OldVariable", _
        STATUS_UNUSED, _
        LOCATION_BODY), _
        "K-B04 OldVariable carrier = Unused / Body / Blank-Blank"

    Set scanResult = CreateBootstrapScanResult()

    Set result = BuildSyncDiff( _
        scanResult, _
        currentDefinitions, _
        syncTimestamp, _
        syncDiffResult)

    RecordResult ResultSucceeded(result), _
        "K-B05 BuildSyncDiff returns Success"

    If Not ResultSucceeded(result) Then
        PrintResultErrors result
        GoTo VerificationEnd
    End If

    RecordResult Not syncDiffResult Is Nothing, _
        "K-B06 SyncDiffResult published"

    If syncDiffResult Is Nothing Then GoTo VerificationEnd

    RecordResult ClassificationCount(syncDiffResult, SYNC_NEW) = 0, _
        "K-B07 New.Count = 0"

    RecordResult ClassificationCount(syncDiffResult, SYNC_EXISTING) = 1, _
        "K-B08 Existing.Count = 1"

    RecordResult ClassificationCount(syncDiffResult, SYNC_REACTIVATED) = 0, _
        "K-B09 Reactivated.Count = 0"

    ' OldVariable is already Unused and absent from the template.
    ' It must remain a true no-op and therefore must not appear in Unused.
    RecordResult ClassificationCount(syncDiffResult, SYNC_UNUSED) = 0, _
        "K-B10 Unused.Count = 0 (Already-Unused no-op)"

    If ClassificationCount(syncDiffResult, SYNC_EXISTING) = 1 Then

        Set existingItems = syncDiffResult(SYNC_EXISTING)
        Set existingItem = existingItems(1)

        RecordResult CStr(existingItem(KEY_VARIABLE_NAME)) = "ModelName", _
            "K-B11 Existing.VariableName = ModelName"

        RecordResult CStr(existingItem(KEY_STATUS)) = STATUS_ACTIVE, _
            "K-B12 Existing.Status = Active"

        RecordResult CStr(existingItem(KEY_TEMPLATE_LOCATION)) = LOCATION_SUBJECT, _
            "K-B13 Existing.TemplateLocation = Subject"

        RecordResult SameDate( _
            existingItem(KEY_FIRST_DETECTED_AT), _
            syncTimestamp), _
            "K-B14 Existing.FirstDetectedAt = SyncTimestamp"

        RecordResult SameDate( _
            existingItem(KEY_LAST_DETECTED_AT), _
            syncTimestamp), _
            "K-B15 Existing.LastDetectedAt = SyncTimestamp"

    Else
        RecordResult False, "K-B11 Existing item available"
        RecordResult False, "K-B12 Existing item available"
        RecordResult False, "K-B13 Existing item available"
        RecordResult False, "K-B14 Existing item available"
        RecordResult False, "K-B15 Existing item available"
    End If

    Set result = ApplySyncDiff(syncDiffResult)

    RecordResult ResultSucceeded(result), _
        "K-B16 ApplySyncDiff returns Success"

    If Not ResultSucceeded(result) Then
        PrintResultErrors result
        GoTo VerificationEnd
    End If

    RecordResult lo.ListRows.Count = 2, _
        "K-B17 Row Count remains 2"

    RecordResult AssertTextCellValue( _
        lo, 1, KEY_VARIABLE_NAME, "ModelName"), _
        "K-B18 ModelName.VariableName preserved"

    RecordResult AssertTextCellValue( _
        lo, 1, KEY_STATUS, STATUS_ACTIVE), _
        "K-B19 ModelName.Status = Active"

    RecordResult AssertTextCellValue( _
        lo, 1, KEY_TEMPLATE_LOCATION, LOCATION_SUBJECT), _
        "K-B20 ModelName.TemplateLocation = Subject"

    RecordResult AssertDateCellValue( _
        lo, 1, KEY_FIRST_DETECTED_AT, syncTimestamp), _
        "K-B21 ModelName.FirstDetectedAt = SyncTimestamp"

    RecordResult AssertDateCellValue( _
        lo, 1, KEY_LAST_DETECTED_AT, syncTimestamp), _
        "K-B22 ModelName.LastDetectedAt = SyncTimestamp"

    RecordResult AssertModelUserConfigurationPreserved(lo, 1), _
        "K-B23 ModelName user configuration preserved"

    RecordResult AssertTextCellValue( _
        lo, 2, KEY_VARIABLE_NAME, "OldVariable"), _
        "K-B24 OldVariable.VariableName preserved"

    RecordResult AssertTextCellValue( _
        lo, 2, KEY_STATUS, STATUS_UNUSED), _
        "K-B25 OldVariable.Status remains Unused"

    RecordResult AssertTextCellValue( _
        lo, 2, KEY_TEMPLATE_LOCATION, LOCATION_BODY), _
        "K-B26 OldVariable.TemplateLocation remains Body"

    RecordResult AssertEmptyCellValue( _
        lo, 2, KEY_FIRST_DETECTED_AT), _
        "K-B27 OldVariable.FirstDetectedAt remains Blank"

    RecordResult AssertEmptyCellValue( _
        lo, 2, KEY_LAST_DETECTED_AT), _
        "K-B28 OldVariable.LastDetectedAt remains Blank"

    RecordResult AssertOldUserConfigurationPreserved(lo, 2), _
        "K-B29 OldVariable user configuration preserved"

VerificationEnd:

    RestoreRows lo, originalRows

    Debug.Print String$(82, "-")
    Debug.Print "PASS Count = " & CStr(mPassCount)
    Debug.Print "FAIL Count = " & CStr(mFailCount)

    If mPassCount = 29 And mFailCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print "Original tblVariableDefinition contents restored."
    Debug.Print String$(82, "=")
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
    Debug.Print String$(82, "=")

End Sub

Private Function CreateBootstrapScanResult() As Object

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    Set scanResult = CreateObject("Scripting.Dictionary")
    scanResult.CompareMode = vbTextCompare

    Set validVariables = New Collection
    validVariables.Add "ModelName"

    Set invalidCandidates = New Collection

    Set locations = CreateObject("Scripting.Dictionary")
    locations.CompareMode = vbTextCompare
    locations.Add "ModelName", LOCATION_SUBJECT

    scanResult.Add KEY_VALID_VARIABLES, validVariables
    scanResult.Add KEY_INVALID_CANDIDATES, invalidCandidates
    scanResult.Add KEY_LOCATIONS, locations

    Set CreateBootstrapScanResult = scanResult

End Function

Private Function DefinitionMatchesBootstrapState( _
    ByVal definitions As Collection, _
    ByVal variableName As String, _
    ByVal expectedStatus As String, _
    ByVal expectedLocation As String _
) As Boolean

    Dim item As Object

    Set item = FindDefinition(definitions, variableName)

    If item Is Nothing Then Exit Function

    If StrComp(CStr(item(KEY_STATUS)), expectedStatus, vbBinaryCompare) <> 0 Then
        Exit Function
    End If

    If StrComp(CStr(item(KEY_TEMPLATE_LOCATION)), expectedLocation, vbBinaryCompare) <> 0 Then
        Exit Function
    End If

    If Not IsEmpty(item(KEY_FIRST_DETECTED_AT)) Then Exit Function
    If Not IsEmpty(item(KEY_LAST_DETECTED_AT)) Then Exit Function

    DefinitionMatchesBootstrapState = True

End Function

Private Function FindDefinition( _
    ByVal definitions As Collection, _
    ByVal variableName As String _
) As Object

    Dim item As Object

    For Each item In definitions
        If StrComp( _
            CStr(item(KEY_VARIABLE_NAME)), _
            variableName, _
            vbTextCompare) = 0 Then

            Set FindDefinition = item
            Exit Function
        End If
    Next item

    Set FindDefinition = Nothing

End Function

Private Function ClassificationCount( _
    ByVal syncDiffResult As Object, _
    ByVal classification As String _
) As Long

    Dim items As Collection

    On Error GoTo InvalidCarrier

    If syncDiffResult Is Nothing Then Exit Function
    If Not syncDiffResult.Exists(classification) Then Exit Function

    Set items = syncDiffResult(classification)
    ClassificationCount = items.Count
    Exit Function

InvalidCarrier:
    ClassificationCount = -1

End Function

Private Function ResultSucceeded( _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then Exit Function
    ResultSucceeded = result.Success

End Function

Private Function SameDate( _
    ByVal actualValue As Variant, _
    ByVal expectedValue As Date _
) As Boolean

    On Error GoTo InvalidValue

    If IsError(actualValue) Or _
       IsNull(actualValue) Or _
       IsEmpty(actualValue) Then
        Exit Function
    End If

    SameDate = _
        (Abs(CDbl(CDate(actualValue)) - CDbl(expectedValue)) < 0.0000001)

    Exit Function

InvalidValue:
    SameDate = False

End Function

Private Function GetTestTable() As ListObject

    Dim ws As Worksheet
    Dim lo As ListObject

    On Error Resume Next

    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)

    If Not ws Is Nothing Then
        Set lo = ws.ListObjects(TABLE_NAME)
    End If

    On Error GoTo 0

    Set GetTestTable = lo

End Function

Private Function HasRequiredColumns(ByVal lo As ListObject) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn

    columns = RequiredColumns()

    On Error GoTo Failed

    For Each columnName In columns
        Set lc = lo.ListColumns(CStr(columnName))
    Next columnName

    HasRequiredColumns = True
    Exit Function

Failed:
    HasRequiredColumns = False

End Function

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

Private Function AssertTextCellValue( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = _
        lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If IsError(actualValue) Or IsNull(actualValue) Then Exit Function

    AssertTextCellValue = _
        (StrComp(CStr(actualValue), expectedValue, vbBinaryCompare) = 0)

End Function

Private Function AssertEmptyCellValue( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String _
) As Boolean

    Dim actualValue As Variant

    actualValue = _
        lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    AssertEmptyCellValue = IsEmpty(actualValue)

End Function

Private Function AssertDateCellValue( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal expectedValue As Date _
) As Boolean

    Dim actualValue As Variant

    actualValue = _
        lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    On Error GoTo InvalidDate

    If IsError(actualValue) Or _
       IsNull(actualValue) Or _
       IsEmpty(actualValue) Or _
       Not IsNumeric(actualValue) Then
        Exit Function
    End If

    AssertDateCellValue = _
        (Abs(CDbl(actualValue) - CDbl(expectedValue)) < 0.0000001)

    Exit Function

InvalidDate:
    AssertDateCellValue = False

End Function

Private Function AssertModelUserConfigurationPreserved( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long _
) As Boolean

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_DISPLAY_NAME, "Model Display") Then Exit Function

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_TYPE, "Text") Then Exit Function

    If CBool(lo.ListColumns(KEY_REQUIRED).DataBodyRange.Cells(rowIndex, 1).Value2) <> True Then
        Exit Function
    End If

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_DESCRIPTION, "Model description") Then Exit Function

    If CDbl(lo.ListColumns(KEY_SORT_ORDER).DataBodyRange.Cells(rowIndex, 1).Value2) <> 10 Then
        Exit Function
    End If

    AssertModelUserConfigurationPreserved = True

End Function

Private Function AssertOldUserConfigurationPreserved( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long _
) As Boolean

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_DISPLAY_NAME, "Old Display") Then Exit Function

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_TYPE, "Select") Then Exit Function

    If CBool(lo.ListColumns(KEY_REQUIRED).DataBodyRange.Cells(rowIndex, 1).Value2) <> False Then
        Exit Function
    End If

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_DESCRIPTION, "Old description") Then Exit Function

    If Not AssertTextCellValue( _
        lo, rowIndex, KEY_OPTION_SOURCE, "LegacyOptions") Then Exit Function

    If CDbl(lo.ListColumns(KEY_SORT_ORDER).DataBodyRange.Cells(rowIndex, 1).Value2) <> 20 Then
        Exit Function
    End If

    AssertOldUserConfigurationPreserved = True

End Function

Private Sub RecordResult( _
    ByVal passed As Boolean, _
    ByVal testName As String _
)

    If passed Then
        mPassCount = mPassCount + 1
        Debug.Print "PASS  " & testName
    Else
        mFailCount = mFailCount + 1
        Debug.Print "FAIL  " & testName
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
