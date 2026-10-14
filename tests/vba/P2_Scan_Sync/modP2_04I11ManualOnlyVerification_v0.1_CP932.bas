Attribute VB_Name = "modP204I11ManualOnly"
Option Explicit

' ============================================================
' P2-04 Remaining Verification
' I11 Manual Only
'
' Two-stage verification across a real Workbook close / reopen:
'
' Stage A:
'   PrepareP204I11ManualOnlyBaseline
'   - save workbook
'   - capture VariableDefinition full fingerprint
'   - capture LastDetectedAt fingerprint
'   - store fingerprints in Windows TEMP
'
' User action:
'   - close workbook / Excel normally
'   - reopen the workbook
'   - DO NOT run Manual Sync before Stage B
'
' Stage B:
'   TestP204I11ManualOnlyAfterReopen
'   - compare post-open state with saved baseline
'   - verify VariableDefinition unchanged
'   - verify LastDetectedAt unchanged
'   - explicitly run ExecuteManualSync
'   - verify success and metadata-only update behavior
'   - restore pre-manual-sync state and save workbook
'
' No Workbook_Open / Auto_Open code is added by this harness.
' This is Implementation Verification, not Formal MVP Test.
' ============================================================

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"

Private Const COLUMN_VARIABLE_NAME As String = "VariableName"
Private Const COLUMN_DISPLAY_NAME As String = "DisplayName"
Private Const COLUMN_TYPE As String = "Type"
Private Const COLUMN_REQUIRED As String = "Required"
Private Const COLUMN_DESCRIPTION As String = "Description"
Private Const COLUMN_OPTION_SOURCE As String = "OptionSource"
Private Const COLUMN_SORT_ORDER As String = "SortOrder"
Private Const COLUMN_FORMAT As String = "Format"

Private Const COLUMN_LAST_DETECTED_AT As String = "LastDetectedAt"

Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"
Private Const KEY_UNUSED As String = "Unused"

Private Const SNAPSHOT_VALUES As String = "Values"
Private Const SNAPSHOT_FORMULAS As String = "Formulas"
Private Const SNAPSHOT_ROW_COUNT As String = "RowCount"
Private Const SNAPSHOT_COLUMN_COUNT As String = "ColumnCount"
Private Const SNAPSHOT_HEADERS As String = "Headers"

Private Const BASELINE_VERSION As String = "P2-04-I11-v0.1"


Public Sub PrepareP204I11ManualOnlyBaseline()

    Dim fullFingerprint As String
    Dim lastDetectedFingerprint As String

    Dim fullPath As String
    Dim lastPath As String

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 I11 Manual Only - Baseline Preparation"
    Debug.Print String$(76, "=")

    On Error GoTo PreparationError

    ' Save first so the fingerprint represents the exact persisted workbook state
    ' that will be reopened.
    ThisWorkbook.Save

    Debug.Print "PASS  Workbook saved before baseline capture"

    fullFingerprint = _
        BuildVariableDefinitionFingerprint(False)

    lastDetectedFingerprint = _
        BuildVariableDefinitionFingerprint(True)

    If Len(fullFingerprint) = 0 Then
        Debug.Print _
            "ABORT: Full VariableDefinition fingerprint could not be created."
        GoTo CleanUp
    End If

    If Len(lastDetectedFingerprint) = 0 Then
        Debug.Print _
            "ABORT: LastDetectedAt fingerprint could not be created."
        GoTo CleanUp
    End If

    fullPath = GetI11FullBaselinePath()
    lastPath = GetI11LastDetectedBaselinePath()

    WriteUnicodeTextFile fullPath, fullFingerprint
    WriteUnicodeTextFile lastPath, lastDetectedFingerprint

    If Not FileExists(fullPath) Or Not FileExists(lastPath) Then
        Debug.Print _
            "ABORT: I11 baseline evidence file creation failed."
        GoTo CleanUp
    End If

    Debug.Print "PASS  VariableDefinition baseline saved"
    Debug.Print "PASS  LastDetectedAt baseline saved"

    Debug.Print _
        "Full Baseline File = " & fullPath
    Debug.Print _
        "LastDetectedAt Baseline File = " & lastPath

    Debug.Print String$(76, "-")
    Debug.Print "NEXT:"
    Debug.Print "  1. Close the workbook / Excel normally."
    Debug.Print "  2. Reopen the same workbook."
    Debug.Print "  3. DO NOT run Manual Sync."
    Debug.Print "  4. Run:"
    Debug.Print "       TestP204I11ManualOnlyAfterReopen"
    Debug.Print String$(76, "=")

CleanUp:
    Exit Sub

PreparationError:
    Debug.Print _
        "ABORT: Baseline preparation runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Sub


Public Sub TestP204I11ManualOnlyAfterReopen()

    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Dim fullPath As String
    Dim lastPath As String

    Dim expectedFullFingerprint As String
    Dim expectedLastDetectedFingerprint As String

    Dim currentFullFingerprint As String
    Dim currentLastDetectedFingerprint As String

    Dim preManualSnapshot As Object
    Dim postManualSnapshot As Object
    Dim restoredSnapshot As Object

    Dim preManualLastFingerprint As String
    Dim postManualLastFingerprint As String

    Dim result As COperationResult
    Dim templateScanResult As Object
    Dim syncDiffResult As Object

    Dim restorationSucceeded As Boolean
    Dim explicitSyncStarted As Boolean

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 Remaining Verification - I11 Manual Only"
    Debug.Print String$(76, "=")

    On Error GoTo UnexpectedError

    fullPath = GetI11FullBaselinePath()
    lastPath = GetI11LastDetectedBaselinePath()

    RecordResult _
        FileExists(fullPath) And FileExists(lastPath), _
        "I11-00 Reopen baseline evidence files available", _
        passCount, failCount

    If Not FileExists(fullPath) Or Not FileExists(lastPath) Then
        Debug.Print _
            "ABORT: Run PrepareP204I11ManualOnlyBaseline before closing the workbook."
        aborted = True
        GoTo Finalize
    End If

    expectedFullFingerprint = _
        ReadUnicodeTextFile(fullPath)

    expectedLastDetectedFingerprint = _
        ReadUnicodeTextFile(lastPath)

    currentFullFingerprint = _
        BuildVariableDefinitionFingerprint(False)

    currentLastDetectedFingerprint = _
        BuildVariableDefinitionFingerprint(True)

    ' --------------------------------------------------------
    ' Core Manual-Only evidence after actual reopen.
    ' No ExecuteManualSync has been called by this stage-B harness yet.
    ' --------------------------------------------------------
    RecordResult _
        (currentFullFingerprint = expectedFullFingerprint), _
        "I11-01 VariableDefinition Before Close = After Reopen", _
        passCount, failCount

    RecordResult _
        (currentLastDetectedFingerprint = expectedLastDetectedFingerprint), _
        "I11-02 LastDetectedAt unchanged after Workbook Open", _
        passCount, failCount

    If currentFullFingerprint <> expectedFullFingerprint Or _
       currentLastDetectedFingerprint <> expectedLastDetectedFingerprint Then

        Debug.Print _
            "ABORT: Workbook Open changed VariableDefinition before explicit Manual Sync."
        aborted = True
        GoTo Finalize
    End If

    Debug.Print _
        "PASS  Workbook Open caused no VariableDefinition sync update"

    ' --------------------------------------------------------
    ' Capture current reopened state for explicit-sync verification / cleanup.
    ' --------------------------------------------------------
    Set preManualSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not preManualSnapshot Is Nothing, _
        "I11-03 Pre-manual-sync VariableDefinition snapshot", _
        passCount, failCount

    If preManualSnapshot Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    preManualLastFingerprint = _
        BuildVariableDefinitionFingerprint(True)

    ' Create an observable timestamp boundary.
    Application.Wait DateAdd("s", 2, Now)

    ' --------------------------------------------------------
    ' Explicit Manual Sync.
    ' --------------------------------------------------------
    Set templateScanResult = Nothing
    Set syncDiffResult = Nothing

    explicitSyncStarted = True

    Set result = ExecuteManualSync( _
        syncDiffResult, _
        templateScanResult)

    RecordResult Not result Is Nothing, _
        "I11-04 Explicit ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If result Is Nothing Then
        GoTo RestoreState
    End If

    PrintOperationResult _
        "Explicit ExecuteManualSync", _
        result

    RecordResult result.Success, _
        "I11-05 Explicit ExecuteManualSync = Success", _
        passCount, failCount

    RecordResult Not templateScanResult Is Nothing, _
        "I11-06 templateScanResult = Published", _
        passCount, failCount

    RecordResult Not syncDiffResult Is Nothing, _
        "I11-07 syncDiffResult = Published", _
        passCount, failCount

    If Not result.Success Or syncDiffResult Is Nothing Then
        GoTo RestoreState
    End If

    ' Stable current template/table should not create a New / Reactivated /
    ' Unused transition in this scenario.
    RecordResult _
        (DiffCollectionCount(syncDiffResult, KEY_NEW) = 0), _
        "I11-08 New.Count = 0", _
        passCount, failCount

    RecordResult _
        (DiffCollectionCount(syncDiffResult, KEY_REACTIVATED) = 0), _
        "I11-09 Reactivated.Count = 0", _
        passCount, failCount

    RecordResult _
        (DiffCollectionCount(syncDiffResult, KEY_UNUSED) = 0), _
        "I11-10 Unused.Count = 0", _
        passCount, failCount

    RecordResult _
        (DiffCollectionCount(syncDiffResult, KEY_EXISTING) > 0), _
        "I11-11 Existing.Count > 0", _
        passCount, failCount

    Set postManualSnapshot = _
        CaptureVariableDefinitionSnapshot()

    RecordResult Not postManualSnapshot Is Nothing, _
        "I11-12 Post-manual-sync VariableDefinition snapshot", _
        passCount, failCount

    If postManualSnapshot Is Nothing Then
        GoTo RestoreState
    End If

    ' User configuration must remain unchanged.
    RecordResult _
        UserConfigurationEqual( _
            preManualSnapshot, _
            postManualSnapshot), _
        "I11-13 User Configuration unchanged", _
        passCount, failCount

    ' Under the stable-template I11 fixture, all non-LastDetectedAt columns
    ' should remain unchanged. Existing items only refresh LastDetectedAt.
    RecordResult _
        SnapshotsEqualExceptColumn( _
            preManualSnapshot, _
            postManualSnapshot, _
            COLUMN_LAST_DETECTED_AT), _
        "I11-14 Only LastDetectedAt changed in stable explicit sync", _
        passCount, failCount

    postManualLastFingerprint = _
        BuildVariableDefinitionFingerprint(True)

    RecordResult _
        (postManualLastFingerprint <> preManualLastFingerprint), _
        "I11-15 LastDetectedAt updated only after explicit Manual Sync", _
        passCount, failCount

RestoreState:
    ' --------------------------------------------------------
    ' Test cleanup.
    ' Restore the state that existed immediately after reopen and save it.
    ' --------------------------------------------------------
    If Not preManualSnapshot Is Nothing Then

        restorationSucceeded = _
            RestoreVariableDefinitionSnapshot(preManualSnapshot)

        RecordResult restorationSucceeded, _
            "I11-16 Pre-manual-sync state restored", _
            passCount, failCount

        If restorationSucceeded Then

            Set restoredSnapshot = _
                CaptureVariableDefinitionSnapshot()

            RecordResult Not restoredSnapshot Is Nothing, _
                "I11-17 Restored snapshot captured", _
                passCount, failCount

            If restoredSnapshot Is Nothing Then
                RecordResult False, _
                    "I11-18 Original reopened State = Restored State", _
                    passCount, failCount
            Else
                RecordResult _
                    SnapshotsValueEqual( _
                        preManualSnapshot, _
                        restoredSnapshot), _
                    "I11-18 Original reopened State = Restored State", _
                    passCount, failCount
            End If

            ' Persist cleanup so closing Excel later does not re-save test metadata.
            ThisWorkbook.Save

            RecordResult ThisWorkbook.Saved, _
                "I11-19 Restored workbook saved", _
                passCount, failCount
        Else
            RecordResult False, _
                "I11-17 Restored snapshot captured", _
                passCount, failCount
            RecordResult False, _
                "I11-18 Original reopened State = Restored State", _
                passCount, failCount
            RecordResult False, _
                "I11-19 Restored workbook saved", _
                passCount, failCount
        End If
    End If

Finalize:
    ' Delete cross-session baseline files only after a clean run.
    If Not aborted And failCount = 0 Then
        DeleteFileIfExists fullPath
        DeleteFileIfExists lastPath

        Debug.Print _
            "PASS  Temporary I11 baseline evidence files removed"
    Else
        If Len(fullPath) > 0 Then
            Debug.Print _
                "I11 baseline retained for diagnosis: " & fullPath
        End If
        If Len(lastPath) > 0 Then
            Debug.Print _
                "I11 LastDetectedAt baseline retained for diagnosis: " & lastPath
        End If
    End If

    Debug.Print String$(76, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print _
        "P3 UserForm Variant = N/A - P3 not implemented"
    Debug.Print String$(76, "=")

    Set restoredSnapshot = Nothing
    Set postManualSnapshot = Nothing
    Set preManualSnapshot = Nothing

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing
    Exit Sub

UnexpectedError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  Unexpected runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    On Error Resume Next

    If explicitSyncStarted Then
        If Not preManualSnapshot Is Nothing Then
            restorationSucceeded = _
                RestoreVariableDefinitionSnapshot(preManualSnapshot)

            If restorationSucceeded Then
                ThisWorkbook.Save
                Debug.Print _
                    "Last-chance VariableDefinition restore/save: PASS"
            Else
                Debug.Print _
                    "Last-chance VariableDefinition restore: FAIL"
            End If
        End If
    End If

    On Error GoTo 0
    Resume Finalize
End Sub


Private Function GetI11FullBaselinePath() As String

    GetI11FullBaselinePath = _
        GetI11BaselinePrefix() & "_full.txt"
End Function


Private Function GetI11LastDetectedBaselinePath() As String

    GetI11LastDetectedBaselinePath = _
        GetI11BaselinePrefix() & "_lastdetected.txt"
End Function


Private Function GetI11BaselinePrefix() As String

    Dim safeWorkbookName As String

    safeWorkbookName = _
        SanitizeFileName(ThisWorkbook.Name)

    GetI11BaselinePrefix = _
        Environ$("TEMP") & _
        "\P2-04_I11_" & _
        safeWorkbookName
End Function


Private Function SanitizeFileName( _
    ByVal value As String _
) As String

    Dim result As String

    result = value

    result = Replace(result, "\", "_")
    result = Replace(result, "/", "_")
    result = Replace(result, ":", "_")
    result = Replace(result, "*", "_")
    result = Replace(result, "?", "_")
    result = Replace(result, """", "_")
    result = Replace(result, "<", "_")
    result = Replace(result, ">", "_")
    result = Replace(result, "|", "_")

    SanitizeFileName = result
End Function


Private Function BuildVariableDefinitionFingerprint( _
    ByVal lastDetectedOnly As Boolean _
) As String

    Dim ws As Worksheet
    Dim lo As ListObject

    Dim variableColumn As ListColumn
    Dim lastDetectedColumn As ListColumn

    Dim rowIndex As Long
    Dim columnIndex As Long

    Dim result As String

    BuildVariableDefinitionFingerprint = vbNullString

    On Error GoTo FingerprintError

    Set ws = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set lo = _
        ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    result = _
        BASELINE_VERSION & vbCrLf & _
        "Workbook=" & ThisWorkbook.Name & vbCrLf & _
        "Rows=" & CStr(lo.ListRows.Count) & vbCrLf & _
        "Columns=" & CStr(lo.ListColumns.Count) & vbCrLf

    If lastDetectedOnly Then

        Set variableColumn = _
            lo.ListColumns(COLUMN_VARIABLE_NAME)

        Set lastDetectedColumn = _
            lo.ListColumns(COLUMN_LAST_DETECTED_AT)

        result = result & "Mode=LastDetectedAt" & vbCrLf

        If lo.DataBodyRange Is Nothing Then
            BuildVariableDefinitionFingerprint = result
            GoTo CleanUp
        End If

        For rowIndex = 1 To lo.ListRows.Count

            result = result & _
                SerializeVariant( _
                    variableColumn.DataBodyRange.Cells(rowIndex, 1).Value2) & _
                "|" & _
                SerializeVariant( _
                    lastDetectedColumn.DataBodyRange.Cells(rowIndex, 1).Value2) & _
                vbCrLf
        Next rowIndex

    Else

        result = result & "Mode=FullTable" & vbCrLf

        For columnIndex = 1 To lo.ListColumns.Count
            result = result & _
                "H" & CStr(columnIndex) & "=" & _
                SerializeVariant( _
                    lo.HeaderRowRange.Cells(1, columnIndex).Value2) & _
                vbCrLf
        Next columnIndex

        If Not lo.DataBodyRange Is Nothing Then

            For rowIndex = 1 To lo.ListRows.Count
                For columnIndex = 1 To lo.ListColumns.Count

                    result = result & _
                        "R" & CStr(rowIndex) & _
                        "C" & CStr(columnIndex) & "=" & _
                        SerializeVariant( _
                            lo.DataBodyRange.Cells(rowIndex, columnIndex).Value2) & _
                        vbCrLf
                Next columnIndex
            Next rowIndex
        End If
    End If

    BuildVariableDefinitionFingerprint = result

CleanUp:
    Set lastDetectedColumn = Nothing
    Set variableColumn = Nothing
    Set lo = Nothing
    Set ws = Nothing
    Exit Function

FingerprintError:
    Debug.Print _
        "Fingerprint runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function


Private Function SerializeVariant( _
    ByVal value As Variant _
) As String

    Dim textValue As String

    If IsError(value) Then
        SerializeVariant = _
            "Error:" & CStr(CVErr(value))
        Exit Function
    End If

    If IsNull(value) Then
        SerializeVariant = "Null"
        Exit Function
    End If

    If IsEmpty(value) Then
        SerializeVariant = "Empty"
        Exit Function
    End If

    textValue = CStr(value)

    SerializeVariant = _
        "VarType=" & CStr(VarType(value)) & _
        ";Len=" & CStr(Len(textValue)) & _
        ";Value=" & textValue
End Function


Private Sub WriteUnicodeTextFile( _
    ByVal filePath As String, _
    ByVal content As String _
)

    Dim fso As Object
    Dim stream As Object

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set stream = fso.CreateTextFile(filePath, True, True)

    stream.Write content
    stream.Close

    Set stream = Nothing
    Set fso = Nothing
End Sub


Private Function ReadUnicodeTextFile( _
    ByVal filePath As String _
) As String

    Dim fso As Object
    Dim stream As Object

    ReadUnicodeTextFile = vbNullString

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set stream = fso.OpenTextFile(filePath, 1, False, -1)

    ReadUnicodeTextFile = stream.ReadAll

    stream.Close

    Set stream = Nothing
    Set fso = Nothing
End Function


Private Function FileExists( _
    ByVal filePath As String _
) As Boolean

    Dim fso As Object

    Set fso = CreateObject("Scripting.FileSystemObject")

    FileExists = fso.FileExists(filePath)

    Set fso = Nothing
End Function


Private Sub DeleteFileIfExists( _
    ByVal filePath As String _
)

    Dim fso As Object

    If Len(filePath) = 0 Then Exit Sub

    Set fso = CreateObject("Scripting.FileSystemObject")

    If fso.FileExists(filePath) Then
        fso.DeleteFile filePath, True
    End If

    Set fso = Nothing
End Sub


Private Function CaptureVariableDefinitionSnapshot() As Object

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim snapshot As Object
    Dim headers() As Variant

    Dim columnIndex As Long

    Set CaptureVariableDefinitionSnapshot = Nothing

    On Error GoTo CaptureError

    Set ws = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set lo = _
        ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    Set snapshot = CreateObject("Scripting.Dictionary")
    snapshot.CompareMode = vbTextCompare

    snapshot.Add SNAPSHOT_ROW_COUNT, lo.ListRows.Count
    snapshot.Add SNAPSHOT_COLUMN_COUNT, lo.ListColumns.Count

    ReDim headers(1 To lo.ListColumns.Count)

    For columnIndex = 1 To lo.ListColumns.Count
        headers(columnIndex) = _
            lo.HeaderRowRange.Cells(1, columnIndex).Value2
    Next columnIndex

    snapshot.Add SNAPSHOT_HEADERS, headers

    If lo.DataBodyRange Is Nothing Then
        snapshot.Add SNAPSHOT_VALUES, Empty
        snapshot.Add SNAPSHOT_FORMULAS, Empty
    Else
        snapshot.Add SNAPSHOT_VALUES, lo.DataBodyRange.Value2
        snapshot.Add SNAPSHOT_FORMULAS, lo.DataBodyRange.Formula
    End If

    Set CaptureVariableDefinitionSnapshot = snapshot

CleanUp:
    Set snapshot = Nothing
    Set lo = Nothing
    Set ws = Nothing
    Exit Function

CaptureError:
    Debug.Print _
        "Snapshot capture error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function


Private Function RestoreVariableDefinitionSnapshot( _
    ByVal snapshot As Object _
) As Boolean

    Dim ws As Worksheet
    Dim lo As ListObject

    Dim targetRows As Long
    Dim currentRows As Long

    RestoreVariableDefinitionSnapshot = False

    If snapshot Is Nothing Then Exit Function

    On Error GoTo RestoreError

    Set ws = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set lo = _
        ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    targetRows = _
        CLng(snapshot.Item(SNAPSHOT_ROW_COUNT))

    currentRows = lo.ListRows.Count

    Do While currentRows > targetRows
        lo.ListRows(currentRows).Delete
        currentRows = lo.ListRows.Count
    Loop

    Do While currentRows < targetRows
        lo.ListRows.Add
        currentRows = lo.ListRows.Count
    Loop

    If targetRows > 0 Then

        If lo.ListColumns.Count <> _
           CLng(snapshot.Item(SNAPSHOT_COLUMN_COUNT)) Then

            GoTo CleanUp
        End If

        lo.DataBodyRange.Formula = _
            snapshot.Item(SNAPSHOT_FORMULAS)
    End If

    RestoreVariableDefinitionSnapshot = True

CleanUp:
    Set lo = Nothing
    Set ws = Nothing
    Exit Function

RestoreError:
    Debug.Print _
        "Snapshot restore error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function


Private Function SnapshotsValueEqual( _
    ByVal leftSnapshot As Object, _
    ByVal rightSnapshot As Object _
) As Boolean

    SnapshotsValueEqual = _
        SnapshotsEqualExceptColumn( _
            leftSnapshot, _
            rightSnapshot, _
            vbNullString)
End Function


Private Function SnapshotsEqualExceptColumn( _
    ByVal leftSnapshot As Object, _
    ByVal rightSnapshot As Object, _
    ByVal excludedColumnName As String _
) As Boolean

    Dim leftValues As Variant
    Dim rightValues As Variant
    Dim headers As Variant

    Dim rowIndex As Long
    Dim columnIndex As Long

    Dim rowCount As Long
    Dim columnCount As Long

    SnapshotsEqualExceptColumn = False

    If leftSnapshot Is Nothing Then Exit Function
    If rightSnapshot Is Nothing Then Exit Function

    If CLng(leftSnapshot.Item(SNAPSHOT_ROW_COUNT)) <> _
       CLng(rightSnapshot.Item(SNAPSHOT_ROW_COUNT)) Then
        Exit Function
    End If

    If CLng(leftSnapshot.Item(SNAPSHOT_COLUMN_COUNT)) <> _
       CLng(rightSnapshot.Item(SNAPSHOT_COLUMN_COUNT)) Then
        Exit Function
    End If

    rowCount = _
        CLng(leftSnapshot.Item(SNAPSHOT_ROW_COUNT))

    columnCount = _
        CLng(leftSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    If rowCount = 0 Then
        SnapshotsEqualExceptColumn = True
        Exit Function
    End If

    leftValues = leftSnapshot.Item(SNAPSHOT_VALUES)
    rightValues = rightSnapshot.Item(SNAPSHOT_VALUES)
    headers = leftSnapshot.Item(SNAPSHOT_HEADERS)

    For rowIndex = 1 To rowCount
        For columnIndex = 1 To columnCount

            If Len(excludedColumnName) = 0 Or _
               StrComp( _
                    CStr(headers(columnIndex)), _
                    excludedColumnName, _
                    vbTextCompare) <> 0 Then

                If Not ScalarValuesEqual( _
                    leftValues(rowIndex, columnIndex), _
                    rightValues(rowIndex, columnIndex)) Then

                    Exit Function
                End If
            End If
        Next columnIndex
    Next rowIndex

    SnapshotsEqualExceptColumn = True
End Function


Private Function UserConfigurationEqual( _
    ByVal leftSnapshot As Object, _
    ByVal rightSnapshot As Object _
) As Boolean

    Dim configColumns As Variant
    Dim columnName As Variant

    configColumns = Array( _
        COLUMN_DISPLAY_NAME, _
        COLUMN_TYPE, _
        COLUMN_REQUIRED, _
        COLUMN_DESCRIPTION, _
        COLUMN_OPTION_SOURCE, _
        COLUMN_SORT_ORDER, _
        COLUMN_FORMAT)

    UserConfigurationEqual = True

    For Each columnName In configColumns

        If Not SnapshotColumnEqual( _
            leftSnapshot, _
            rightSnapshot, _
            CStr(columnName)) Then

            UserConfigurationEqual = False
            Exit Function
        End If
    Next columnName
End Function


Private Function SnapshotColumnEqual( _
    ByVal leftSnapshot As Object, _
    ByVal rightSnapshot As Object, _
    ByVal columnName As String _
) As Boolean

    Dim leftValues As Variant
    Dim rightValues As Variant
    Dim leftHeaders As Variant
    Dim rightHeaders As Variant

    Dim leftIndex As Long
    Dim rightIndex As Long

    Dim rowIndex As Long
    Dim rowCount As Long

    SnapshotColumnEqual = False

    If leftSnapshot Is Nothing Then Exit Function
    If rightSnapshot Is Nothing Then Exit Function

    If CLng(leftSnapshot.Item(SNAPSHOT_ROW_COUNT)) <> _
       CLng(rightSnapshot.Item(SNAPSHOT_ROW_COUNT)) Then
        Exit Function
    End If

    leftHeaders = leftSnapshot.Item(SNAPSHOT_HEADERS)
    rightHeaders = rightSnapshot.Item(SNAPSHOT_HEADERS)

    leftIndex = _
        FindHeaderIndex(leftHeaders, columnName)

    rightIndex = _
        FindHeaderIndex(rightHeaders, columnName)

    If leftIndex = 0 Or rightIndex = 0 Then Exit Function

    rowCount = _
        CLng(leftSnapshot.Item(SNAPSHOT_ROW_COUNT))

    If rowCount = 0 Then
        SnapshotColumnEqual = True
        Exit Function
    End If

    leftValues = leftSnapshot.Item(SNAPSHOT_VALUES)
    rightValues = rightSnapshot.Item(SNAPSHOT_VALUES)

    For rowIndex = 1 To rowCount

        If Not ScalarValuesEqual( _
            leftValues(rowIndex, leftIndex), _
            rightValues(rowIndex, rightIndex)) Then

            Exit Function
        End If
    Next rowIndex

    SnapshotColumnEqual = True
End Function


Private Function FindHeaderIndex( _
    ByVal headers As Variant, _
    ByVal columnName As String _
) As Long

    Dim indexValue As Long

    FindHeaderIndex = 0

    For indexValue = LBound(headers) To UBound(headers)

        If StrComp( _
            CStr(headers(indexValue)), _
            columnName, _
            vbTextCompare) = 0 Then

            FindHeaderIndex = indexValue
            Exit Function
        End If
    Next indexValue
End Function


Private Function ScalarValuesEqual( _
    ByVal leftValue As Variant, _
    ByVal rightValue As Variant _
) As Boolean

    ScalarValuesEqual = False

    If IsError(leftValue) Or IsError(rightValue) Then
        ScalarValuesEqual = _
            (IsError(leftValue) And IsError(rightValue))
        Exit Function
    End If

    If IsEmpty(leftValue) And IsEmpty(rightValue) Then
        ScalarValuesEqual = True
        Exit Function
    End If

    If IsNull(leftValue) Or IsNull(rightValue) Then
        ScalarValuesEqual = _
            (IsNull(leftValue) And IsNull(rightValue))
        Exit Function
    End If

    If IsDate(leftValue) And IsDate(rightValue) Then
        ScalarValuesEqual = _
            (CDbl(CDate(leftValue)) = CDbl(CDate(rightValue)))
        Exit Function
    End If

    ScalarValuesEqual = _
        (CStr(leftValue) = CStr(rightValue))
End Function


Private Function DiffCollectionCount( _
    ByVal syncDiffResult As Object, _
    ByVal classificationKey As String _
) As Long

    Dim items As Collection

    DiffCollectionCount = -1

    If syncDiffResult Is Nothing Then Exit Function
    If Not IsDictionary(syncDiffResult) Then Exit Function
    If Not syncDiffResult.Exists(classificationKey) Then Exit Function

    On Error GoTo InspectError

    Set items = _
        syncDiffResult.Item(classificationKey)

    If items Is Nothing Then Exit Function

    DiffCollectionCount = items.Count

CleanUp:
    Set items = Nothing
    Exit Function

InspectError:
    DiffCollectionCount = -1
    Resume CleanUp
End Function


Private Function IsDictionary( _
    ByVal value As Object _
) As Boolean

    IsDictionary = False

    If value Is Nothing Then Exit Function

    On Error GoTo NotDictionary

    IsDictionary = _
        (StrComp( _
            TypeName(value), _
            "Dictionary", _
            vbTextCompare) = 0)

    Exit Function

NotDictionary:
    IsDictionary = False
End Function


Private Sub PrintOperationResult( _
    ByVal labelText As String, _
    ByVal result As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    Debug.Print labelText & ":"

    If result Is Nothing Then
        Debug.Print "  Result = Nothing"
        Exit Sub
    End If

    Debug.Print "  Success = " & CStr(result.Success)

    If result.Success Then Exit Sub

    On Error GoTo PrintError

    Set errors = result.Errors

    If errors Is Nothing Then
        Debug.Print "  Errors = Nothing"
        GoTo CleanUp
    End If

    For Each errorInfo In errors
        Debug.Print _
            "  ErrorType=" & errorInfo.ErrorType & _
            "; Target=" & errorInfo.Target & _
            "; Message=" & errorInfo.Message
    Next errorInfo

CleanUp:
    Set errorInfo = Nothing
    Set errors = Nothing
    Exit Sub

PrintError:
    Debug.Print _
        "  Error inspection failed: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Sub


Private Sub RecordResult( _
    ByVal conditionValue As Boolean, _
    ByVal testName As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If conditionValue Then
        passCount = passCount + 1
        Debug.Print "PASS  " & testName
    Else
        failCount = failCount + 1
        Debug.Print "FAIL  " & testName
    End If
End Sub
