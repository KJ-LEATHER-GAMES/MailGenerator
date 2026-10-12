Attribute VB_Name = "modP2_03SyncPersNegaTest"
Option Explicit

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

Private Const TEMP_TABLE_NAME As String = "__P203_N10_TempTable"
Private Const TEMP_COLUMN_NAME As String = "__P203_N11_TempColumn"
Private Const N18_PASSWORD As String = "__P203_N18__"

Private mPassCount As Long
Private mFailCount As Long

Public Sub TestP203SyncPersistenceTechnicalNegative()

    Dim lo As ListObject
    Dim originalRows As Collection
    Dim ws As Worksheet
    Dim casePassed As Boolean

    Debug.Print String$(72, "=")
    Debug.Print "P2-03 Sync Persistence Technical Negative Verification: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print String$(72, "=")

    mPassCount = 0
    mFailCount = 0

    On Error GoTo FatalError

    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)
    Set lo = ws.ListObjects(TABLE_NAME)

    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: tblVariableDefinition was not found."
        Exit Sub
    End If

    If Not HasRequiredColumns(lo) Then
        Debug.Print "PRECONDITION FAIL: Required VariableDefinition columns are missing."
        Exit Sub
    End If

    If ws.ProtectContents Then
        Debug.Print "PRECONDITION FAIL: VariableDefinition worksheet is already protected."
        Debug.Print "N18 needs temporary test protection and cannot safely restore an unknown password."
        Exit Sub
    End If

    Set originalRows = CaptureRows(lo)

    casePassed = TestN01_SyncDiffNothing(lo)
    RecordCaseResult "N01 SyncDiffResult = Nothing", casePassed

    casePassed = TestN02_ClassificationMissing(lo)
    RecordCaseResult "N02 Classification Missing", casePassed

    casePassed = TestN03_RequiredFieldMissing(lo)
    RecordCaseResult "N03 Diff Item Required Field Missing", casePassed

    casePassed = TestN04_InvalidVariableName(lo)
    RecordCaseResult "N04 Invalid VariableName", casePassed

    casePassed = TestN05_InvalidTemplateLocation(lo)
    RecordCaseResult "N05 Invalid TemplateLocation", casePassed

    casePassed = TestN06_InvalidStatus(lo)
    RecordCaseResult "N06 Invalid Status", casePassed

    casePassed = TestN07_ClassificationStatusConflict(lo)
    RecordCaseResult "N07 Classification / Status Conflict", casePassed

    casePassed = TestN08_InvalidTimestamp(lo)
    RecordCaseResult "N08 Invalid Timestamp", casePassed

    casePassed = TestN09_CrossClassDuplicate(lo)
    RecordCaseResult "N09 Cross-class Duplicate", casePassed

    casePassed = TestN10_TableMissing(lo)
    RecordCaseResult "N10 Table Missing", casePassed

    casePassed = TestN11_RequiredColumnMissing(lo)
    RecordCaseResult "N11 Required Column Missing", casePassed

    casePassed = TestN12_ExistingTableDuplicate(lo)
    RecordCaseResult "N12 Existing Table Duplicate", casePassed

    casePassed = TestN13_NewConflict(lo)
    RecordCaseResult "N13 New Conflict", casePassed

    casePassed = TestN14_ExistingMissing(lo)
    RecordCaseResult "N14 Existing Missing", casePassed

    casePassed = TestN15_ReactivatedMissing(lo)
    RecordCaseResult "N15 Reactivated Missing", casePassed

    casePassed = TestN16_UnusedMissing(lo)
    RecordCaseResult "N16 Unused Missing", casePassed

    casePassed = TestN17_CanonicalNameConflict(lo)
    RecordCaseResult "N17 Canonical Name Conflict", casePassed

    casePassed = TestN18_RuntimeWriteFailure(lo, ws)
    RecordCaseResult "N18 Runtime Write Failure", casePassed

    RestoreRows lo, originalRows

    Debug.Print String$(72, "-")
    Debug.Print "PASS Count: " & CStr(mPassCount)
    Debug.Print "FAIL Count: " & CStr(mFailCount)

    If mFailCount = 0 Then
        Debug.Print "Overall: PASS"
    Else
        Debug.Print "Overall: FAIL"
    End If

    Debug.Print "Original tblVariableDefinition contents restored."
    Debug.Print String$(72, "=")
    Exit Sub

FatalError:
    Debug.Print "FATAL TEST HARNESS ERROR:"
    Debug.Print "  Number = " & CStr(Err.Number)
    Debug.Print "  Description = " & Err.Description

    On Error Resume Next
    If Not ws Is Nothing Then
        If ws.ProtectContents Then
            ws.Unprotect Password:=N18_PASSWORD
        End If
    End If

    If Not lo Is Nothing Then
        If StrComp(lo.Name, TABLE_NAME, vbBinaryCompare) <> 0 Then
            lo.Name = TABLE_NAME
        End If

        RestoreColumnNameIfNeeded lo

        If Not originalRows Is Nothing Then
            RestoreRows lo, originalRows
            Debug.Print "Original tblVariableDefinition contents restored after fatal error."
        End If
    End If
    On Error GoTo 0

    Debug.Print "Overall: ABORTED"
    Debug.Print String$(72, "=")

End Sub

Private Function TestN01_SyncDiffNothing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection

    TestN01_SyncDiffNothing = False

    PrepareSingleBaselineRow lo, "BaselineN01"
    Set beforeRows = CaptureRows(lo)

    Set diff = Nothing
    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "SyncDiffResult", "N01") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N01 Write=0") Then Exit Function

    TestN01_SyncDiffNothing = True

End Function

Private Function TestN02_ClassificationMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim items As Collection
    Dim result As COperationResult
    Dim beforeRows As Collection

    TestN02_ClassificationMissing = False

    PrepareSingleBaselineRow lo, "BaselineN02"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateObject("Scripting.Dictionary")
    diff.CompareMode = vbTextCompare

    Set items = New Collection
    diff.Add SYNC_NEW, items

    Set items = New Collection
    diff.Add SYNC_EXISTING, items

    Set items = New Collection
    diff.Add SYNC_REACTIVATED, items

    ' Intentionally omit Unused.

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", SYNC_UNUSED, "N02") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N02 Write=0") Then Exit Function

    TestN02_ClassificationMissing = True

End Function

Private Function TestN03_RequiredFieldMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim item As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN03_RequiredFieldMissing = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN03"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    Set item = CreateDiffItem("MissingFieldVar", "Body", "Active", detectedAt, detectedAt)
    item.Remove KEY_LAST_DETECTED_AT
    AddDiffItem diff, SYNC_NEW, item

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "MissingFieldVar", "N03") Then Exit Function
    If Not AssertMessageContains(result, KEY_LAST_DETECTED_AT, "N03") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N03 Write=0") Then Exit Function

    TestN03_RequiredFieldMissing = True

End Function

Private Function TestN04_InvalidVariableName(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN04_InvalidVariableName = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN04"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("1Invalid", "Body", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "1Invalid", "N04") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N04 Write=0") Then Exit Function

    TestN04_InvalidVariableName = True

End Function

Private Function TestN05_InvalidTemplateLocation(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN05_InvalidTemplateLocation = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN05"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("LocationVar", "Header", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "LocationVar", "N05") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N05 Write=0") Then Exit Function

    TestN05_InvalidTemplateLocation = True

End Function

Private Function TestN06_InvalidStatus(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN06_InvalidStatus = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN06"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("StatusVar", "Body", "Enabled", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "StatusVar", "N06") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N06 Write=0") Then Exit Function

    TestN06_InvalidStatus = True

End Function

Private Function TestN07_ClassificationStatusConflict(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN07_ClassificationStatusConflict = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN07"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem("ConflictVar", "Both", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "ConflictVar", "N07") Then Exit Function
    If Not AssertMessageContains(result, "inconsistent", "N07") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N07 Write=0") Then Exit Function

    TestN07_ClassificationStatusConflict = True

End Function

Private Function TestN08_InvalidTimestamp(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN08_InvalidTimestamp = False
    detectedAt = DateSerial(2026, 9, 20)

    PrepareSingleBaselineRow lo, "BaselineN08"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("BadDateVar", "Subject", "Active", "not-a-date", detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "BadDateVar", "N08") Then Exit Function
    If Not AssertMessageContains(result, KEY_FIRST_DETECTED_AT, "N08") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N08 Write=0") Then Exit Function

    TestN08_InvalidTimestamp = True

End Function

Private Function TestN09_CrossClassDuplicate(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN09_CrossClassDuplicate = False
    detectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()

    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("DuplicateVar", "Body", "Active", detectedAt, detectedAt)

    AddDiffItem diff, SYNC_EXISTING, _
        CreateDiffItem("DUPLICATEVAR", "Body", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "DUPLICATEVAR", "N09") Then Exit Function
    If Not AssertMessageContains(result, "more than one", "N09") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N09 Write=0") Then Exit Function

    TestN09_CrossClassDuplicate = True

End Function

Private Function TestN10_TableMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim originalName As String
    Dim restored As Boolean

    TestN10_TableMissing = False

    PrepareSingleBaselineRow lo, "BaselineN10"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()

    originalName = lo.Name
    restored = False

    On Error GoTo CleanupFailure

    lo.Name = TEMP_TABLE_NAME

    Set result = ApplySyncDiff(diff)

    lo.Name = originalName
    restored = True

    If Not AssertFailure(result, "ConfigurationError", TABLE_NAME, "N10") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N10 Write=0") Then Exit Function

    TestN10_TableMissing = True
    Exit Function

CleanupFailure:
    On Error Resume Next
    If Not restored Then lo.Name = originalName
    On Error GoTo 0

    Debug.Print "  FAIL DETAIL: N10 test harness failed while renaming/restoring table."
    Debug.Print "    Number=" & CStr(Err.Number)
    Debug.Print "    Description=" & Err.Description

End Function

Private Function TestN11_RequiredColumnMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim lc As ListColumn
    Dim originalName As String
    Dim restored As Boolean

    TestN11_RequiredColumnMissing = False

    PrepareSingleBaselineRow lo, "BaselineN11"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()

    Set lc = lo.ListColumns(KEY_LAST_DETECTED_AT)
    originalName = lc.Name
    restored = False

    On Error GoTo CleanupFailure

    lc.Name = TEMP_COLUMN_NAME

    Set result = ApplySyncDiff(diff)

    lc.Name = originalName
    restored = True

    If Not AssertFailure(result, "ConfigurationError", KEY_LAST_DETECTED_AT, "N11") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N11 Write=0") Then Exit Function

    TestN11_RequiredColumnMissing = True
    Exit Function

CleanupFailure:
    On Error Resume Next
    If Not restored Then lc.Name = originalName
    On Error GoTo 0

    Debug.Print "  FAIL DETAIL: N11 test harness failed while renaming/restoring column."
    Debug.Print "    Number=" & CStr(Err.Number)
    Debug.Print "    Description=" & Err.Description

End Function

Private Function TestN12_ExistingTableDuplicate(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection

    TestN12_ExistingTableDuplicate = False

    ClearTable lo

    AddBaselineRow lo, "ModelName"
    AddBaselineRow lo, "modelname"

    Set beforeRows = CaptureRows(lo)
    Set diff = CreateEmptySyncDiff()

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "ConfigurationError", "modelname", "N12") Then Exit Function
    If Not AssertMessageContains(result, "Duplicate VariableName", "N12") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N12 Write=0") Then Exit Function

    TestN12_ExistingTableDuplicate = True

End Function

Private Function TestN13_NewConflict(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN13_NewConflict = False
    detectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    AddBaselineRow lo, "ConflictNew"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, _
        CreateDiffItem("ConflictNew", "Both", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "ConflictNew", "N13") Then Exit Function
    If Not AssertMessageContains(result, "already exists", "N13") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N13 Write=0") Then Exit Function

    TestN13_NewConflict = True

End Function

Private Function TestN14_ExistingMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN14_ExistingMissing = False
    detectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, _
        CreateDiffItem("MissingExisting", "Body", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "MissingExisting", "N14") Then Exit Function
    If Not AssertMessageContains(result, "was not found", "N14") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N14 Write=0") Then Exit Function

    TestN14_ExistingMissing = True

End Function

Private Function TestN15_ReactivatedMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN15_ReactivatedMissing = False
    detectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_REACTIVATED, _
        CreateDiffItem("MissingReactivated", "Subject", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "MissingReactivated", "N15") Then Exit Function
    If Not AssertMessageContains(result, "was not found", "N15") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N15 Write=0") Then Exit Function

    TestN15_ReactivatedMissing = True

End Function

Private Function TestN16_UnusedMissing(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim detectedAt As Date

    TestN16_UnusedMissing = False
    detectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, _
        CreateDiffItem("MissingUnused", "Both", "Unused", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "MissingUnused", "N16") Then Exit Function
    If Not AssertMessageContains(result, "was not found", "N16") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N16 Write=0") Then Exit Function

    TestN16_UnusedMissing = True

End Function

Private Function TestN17_CanonicalNameConflict(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    TestN17_CanonicalNameConflict = False

    firstDetectedAt = DateSerial(2026, 7, 1)
    lastDetectedAt = DateSerial(2026, 9, 20)

    ClearTable lo
    AddBaselineRow lo, "ModelName"
    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, _
        CreateDiffItem("MODELNAME", "Both", "Active", firstDetectedAt, lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertFailure(result, "UnexpectedError", "MODELNAME", "N17") Then Exit Function
    If Not AssertMessageContains(result, "Canonical VariableName", "N17") Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N17 Write=0") Then Exit Function

    TestN17_CanonicalNameConflict = True

End Function

Private Function TestN18_RuntimeWriteFailure( _
    ByVal lo As ListObject, _
    ByVal ws As Worksheet _
) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim beforeRows As Collection
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date
    Dim unprotected As Boolean

    TestN18_RuntimeWriteFailure = False

    firstDetectedAt = DateSerial(2026, 7, 1)
    lastDetectedAt = DateSerial(2026, 9, 20) + TimeSerial(17, 30, 0)

    ClearTable lo

    AddFixtureRow lo, _
        "ProtectedWriteVar", _
        "Protected", _
        "Text", _
        True, _
        "N18 fixture", _
        vbNullString, _
        10, _
        vbNullString, _
        "Subject", _
        "Active", _
        firstDetectedAt, _
        DateSerial(2026, 8, 1)

    Set beforeRows = CaptureRows(lo)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, _
        CreateDiffItem( _
            "ProtectedWriteVar", _
            "Both", _
            "Active", _
            firstDetectedAt, _
            lastDetectedAt)

    unprotected = False

    On Error GoTo CleanupFailure

    ws.Protect Password:=N18_PASSWORD, Contents:=True, UserInterfaceOnly:=False

    Set result = ApplySyncDiff(diff)

    ws.Unprotect Password:=N18_PASSWORD
    unprotected = True

    If result Is Nothing Then
        Debug.Print "  FAIL DETAIL: N18 result is Nothing."
        Exit Function
    End If

    If result.Success Then
        Debug.Print "  FAIL DETAIL: N18 unexpectedly returned Success."
        Exit Function
    End If

    If Not AssertFailure(result, "UnexpectedError", TABLE_NAME, "N18") Then Exit Function
    If Not AssertMessageContains(result, "after writing started", "N18") Then Exit Function

    ' Protection should block the first attempted write, so the fixture should
    ' remain unchanged. The key verification is runtime error conversion after
    ' writeStarted=True; this test does not require an actual partial mutation.
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "N18 Fixture remains readable") Then Exit Function

    TestN18_RuntimeWriteFailure = True
    Exit Function

CleanupFailure:
    On Error Resume Next
    If Not unprotected Then
        ws.Unprotect Password:=N18_PASSWORD
    End If
    On Error GoTo 0

    Debug.Print "  FAIL DETAIL: N18 test harness failed while protecting/restoring sheet."
    Debug.Print "    Number=" & CStr(Err.Number)
    Debug.Print "    Description=" & Err.Description

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
    ByVal templateLocation As String, _
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

Private Sub PrepareSingleBaselineRow( _
    ByVal lo As ListObject, _
    ByVal variableName As String _
)

    ClearTable lo
    AddBaselineRow lo, variableName

End Sub

Private Sub AddBaselineRow( _
    ByVal lo As ListObject, _
    ByVal variableName As String _
)

    AddFixtureRow lo, _
        variableName, _
        "Baseline Display", _
        "Text", _
        True, _
        "Baseline Description", _
        vbNullString, _
        10, _
        vbNullString, _
        "Body", _
        "Active", _
        DateSerial(2026, 7, 1), _
        DateSerial(2026, 8, 1)

End Sub

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
    ByVal templateLocation As String, _
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

    lo.ListColumns(KEY_FIRST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        firstDetectedAt

    lo.ListColumns(KEY_LAST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        lastDetectedAt

End Sub

Private Function HasRequiredColumns(ByVal lo As ListObject) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn

    HasRequiredColumns = False

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

    For Each columnName In columns
        Set lc = Nothing

        On Error Resume Next
        Set lc = lo.ListColumns(CStr(columnName))
        On Error GoTo 0

        If lc Is Nothing Then
            Debug.Print "  Missing column: " & CStr(columnName)
            Exit Function
        End If
    Next columnName

    HasRequiredColumns = True

End Function

Private Sub ClearTable(ByVal lo As ListObject)

    Do While lo.ListRows.Count > 0
        lo.ListRows(lo.ListRows.Count).Delete
    Loop

End Sub

Private Sub WriteCell( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal columnName As String, _
    ByVal value As Variant _
)

    lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2 = value

End Sub

Private Function CaptureRows(ByVal lo As ListObject) As Collection

    Dim rows As Collection
    Dim rowIndex As Long

    Set rows = New Collection

    If Not lo.DataBodyRange Is Nothing Then
        For rowIndex = 1 To lo.ListRows.Count
            rows.Add CaptureRow(lo, rowIndex)
        Next rowIndex
    End If

    Set CaptureRows = rows

End Function

Private Function CaptureRow( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long _
) As Object

    Dim item As Object
    Dim columns As Variant
    Dim columnName As Variant

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

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

    For Each columnName In columns
        item.Add CStr(columnName), _
            lo.ListColumns(CStr(columnName)).DataBodyRange.Cells(rowIndex, 1).Value2
    Next columnName

    Set CaptureRow = item

End Function

Private Sub RestoreRows( _
    ByVal lo As ListObject, _
    ByVal rows As Collection _
)

    Dim item As Object
    Dim row As ListRow
    Dim rowIndex As Long

    ClearTable lo

    For Each item In rows

        Set row = lo.ListRows.Add
        rowIndex = row.Index

        WriteCell lo, rowIndex, KEY_VARIABLE_NAME, item(KEY_VARIABLE_NAME)
        WriteCell lo, rowIndex, KEY_DISPLAY_NAME, item(KEY_DISPLAY_NAME)
        WriteCell lo, rowIndex, KEY_TYPE, item(KEY_TYPE)
        WriteCell lo, rowIndex, KEY_REQUIRED, item(KEY_REQUIRED)
        WriteCell lo, rowIndex, KEY_DESCRIPTION, item(KEY_DESCRIPTION)
        WriteCell lo, rowIndex, KEY_OPTION_SOURCE, item(KEY_OPTION_SOURCE)
        WriteCell lo, rowIndex, KEY_SORT_ORDER, item(KEY_SORT_ORDER)
        WriteCell lo, rowIndex, KEY_FORMAT, item(KEY_FORMAT)
        WriteCell lo, rowIndex, KEY_TEMPLATE_LOCATION, item(KEY_TEMPLATE_LOCATION)
        WriteCell lo, rowIndex, KEY_STATUS, item(KEY_STATUS)
        WriteCell lo, rowIndex, KEY_FIRST_DETECTED_AT, item(KEY_FIRST_DETECTED_AT)
        WriteCell lo, rowIndex, KEY_LAST_DETECTED_AT, item(KEY_LAST_DETECTED_AT)

    Next item

End Sub

Private Sub RestoreColumnNameIfNeeded(ByVal lo As ListObject)

    Dim lc As ListColumn

    Set lc = Nothing

    On Error Resume Next
    Set lc = lo.ListColumns(TEMP_COLUMN_NAME)

    If Not lc Is Nothing Then
        lc.Name = KEY_LAST_DETECTED_AT
    End If

    On Error GoTo 0

End Sub

Private Function AssertFailure( _
    ByVal result As COperationResult, _
    ByVal expectedErrorType As String, _
    ByVal expectedTarget As String, _
    ByVal context As String _
) As Boolean

    Dim errorInfo As CErrorInfo

    AssertFailure = False

    If result Is Nothing Then
        Debug.Print "  FAIL DETAIL: " & context & " result is Nothing."
        Exit Function
    End If

    If result.Success Then
        Debug.Print "  FAIL DETAIL: " & context & " unexpectedly returned Success."
        Exit Function
    End If

    If result.Errors.Count = 0 Then
        Debug.Print "  FAIL DETAIL: " & context & " returned no ErrorInfo."
        Exit Function
    End If

    Set errorInfo = result.Errors(1)

    If StrComp(errorInfo.ErrorType, expectedErrorType, vbBinaryCompare) <> 0 Then
        Debug.Print "  FAIL DETAIL: " & context & " ErrorType mismatch."
        Debug.Print "    Expected=" & expectedErrorType
        Debug.Print "    Actual  =" & errorInfo.ErrorType
        Exit Function
    End If

    If StrComp(errorInfo.Target, expectedTarget, vbBinaryCompare) <> 0 Then
        Debug.Print "  FAIL DETAIL: " & context & " Target mismatch."
        Debug.Print "    Expected=" & expectedTarget
        Debug.Print "    Actual  =" & errorInfo.Target
        Exit Function
    End If

    AssertFailure = True

End Function

Private Function AssertMessageContains( _
    ByVal result As COperationResult, _
    ByVal expectedText As String, _
    ByVal context As String _
) As Boolean

    Dim errorInfo As CErrorInfo

    AssertMessageContains = False

    If result Is Nothing Then Exit Function
    If result.Errors.Count = 0 Then Exit Function

    Set errorInfo = result.Errors(1)

    If InStr(1, errorInfo.Message, expectedText, vbTextCompare) = 0 Then
        Debug.Print "  FAIL DETAIL: " & context & " Message did not contain expected text."
        Debug.Print "    Expected fragment=" & expectedText
        Debug.Print "    Actual Message   =" & errorInfo.Message
        Exit Function
    End If

    AssertMessageContains = True

End Function

Private Function AssertTableMatchesSnapshot( _
    ByVal lo As ListObject, _
    ByVal expectedRows As Collection, _
    ByVal context As String _
) As Boolean

    Dim i As Long
    Dim expectedRow As Object

    If lo.ListRows.Count <> expectedRows.Count Then
        Debug.Print "  FAIL DETAIL: " & context & " row count mismatch."
        Debug.Print "    Expected=" & CStr(expectedRows.Count)
        Debug.Print "    Actual  =" & CStr(lo.ListRows.Count)
        AssertTableMatchesSnapshot = False
        Exit Function
    End If

    For i = 1 To expectedRows.Count
        Set expectedRow = expectedRows(i)

        If Not AssertRowMatchesSnapshot(lo, i, expectedRow, context & " Row " & CStr(i)) Then
            AssertTableMatchesSnapshot = False
            Exit Function
        End If
    Next i

    AssertTableMatchesSnapshot = True

End Function

Private Function AssertRowMatchesSnapshot( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal expected As Object, _
    ByVal context As String _
) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim actual As Variant

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

    For Each columnName In columns

        actual = lo.ListColumns(CStr(columnName)).DataBodyRange.Cells(rowIndex, 1).Value2

        If Not VariantsEqual(expected(CStr(columnName)), actual) Then
            Debug.Print "  FAIL DETAIL: " & context & " mismatch at " & CStr(columnName)
            Debug.Print "    Expected=" & SafeVariantText(expected(CStr(columnName)))
            Debug.Print "    Actual  =" & SafeVariantText(actual)
            AssertRowMatchesSnapshot = False
            Exit Function
        End If

    Next columnName

    AssertRowMatchesSnapshot = True

End Function

Private Function VariantsEqual( _
    ByVal expected As Variant, _
    ByVal actual As Variant _
) As Boolean

    If IsError(expected) Or IsError(actual) Then
        VariantsEqual = (IsError(expected) And IsError(actual))
        Exit Function
    End If

    If IsNull(expected) Or IsNull(actual) Then
        VariantsEqual = (IsNull(expected) And IsNull(actual))
        Exit Function
    End If

    If IsNumeric(expected) And IsNumeric(actual) Then
        VariantsEqual = (Abs(CDbl(expected) - CDbl(actual)) < 0.0000001)
        Exit Function
    End If

    VariantsEqual = (StrComp(CStr(expected), CStr(actual), vbBinaryCompare) = 0)

End Function

Private Function SafeVariantText(ByVal value As Variant) As String

    If IsError(value) Then
        SafeVariantText = "<Excel Error>"
    ElseIf IsNull(value) Then
        SafeVariantText = "<Null>"
    ElseIf IsEmpty(value) Then
        SafeVariantText = "<Empty>"
    Else
        SafeVariantText = CStr(value)
    End If

End Function

Private Sub RecordCaseResult( _
    ByVal caseName As String, _
    ByVal passed As Boolean _
)

    If passed Then
        mPassCount = mPassCount + 1
        Debug.Print caseName & ": PASS"
    Else
        mFailCount = mFailCount + 1
        Debug.Print caseName & ": FAIL"
    End If

End Sub
