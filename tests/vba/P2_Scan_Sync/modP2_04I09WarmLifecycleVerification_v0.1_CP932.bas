Attribute VB_Name = "modP2_04I09WarmLCVerification"
Option Explicit

' ============================================================
' P2-04 Remaining Verification
' I09 Warm Lifecycle
'
' Preconditions:
' - Classic Outlook is already running.
' - At least one existing Explorer is visible/available.
'
' Purpose:
' - Execute the real P2-04 ExecuteManualSync path.
' - Verify existing Explorer reuse.
' - Verify no additional Explorer / Draft / Inspector residue.
' - Verify sync succeeds.
' - Restore VariableDefinition after successful sync.
'
' Notes:
' - Outlook is NEVER started by this harness.
' - "Scan MailItem Display = NONE" is indirect lifecycle evidence:
'   no additional Inspector/Draft residue + established Adapter non-display contract.
' ============================================================

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"

Private Const OL_FOLDER_DRAFTS As Long = 16

Private Const SNAPSHOT_VALUES As String = "Values"
Private Const SNAPSHOT_FORMULAS As String = "Formulas"
Private Const SNAPSHOT_ROW_COUNT As String = "RowCount"
Private Const SNAPSHOT_COLUMN_COUNT As String = "ColumnCount"


Public Sub TestP204I09WarmLifecycle()

    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Dim outlookApp As Object
    Dim outlookNamespace As Object
    Dim draftsFolder As Object

    Dim explorerCountBefore As Long
    Dim explorerCountAfter As Long

    Dim inspectorCountBefore As Long
    Dim inspectorCountAfter As Long

    Dim draftCountBefore As Long
    Dim draftCountAfter As Long

    Dim lifecycleEvidenceAvailable As Boolean

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim originalSnapshot As Object
    Dim afterSyncSnapshot As Object
    Dim restoredSnapshot As Object

    Dim restorationSucceeded As Boolean

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 Remaining Verification - I09 Warm Lifecycle"
    Debug.Print String$(76, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Warm Start precondition.
    ' Do NOT CreateObject / start Outlook here.
    ' --------------------------------------------------------
    Set outlookApp = GetRunningOutlookApplication()

    If outlookApp Is Nothing Then
        Debug.Print _
            "ABORT: Classic Outlook is not already running."
        Debug.Print _
            "Open Classic Outlook manually, then rerun I09."
        aborted = True
        GoTo Finalize
    End If

    explorerCountBefore = SafeExplorerCount(outlookApp)

    If explorerCountBefore < 1 Then
        Debug.Print _
            "ABORT: Warm Start requires Explorer Count >= 1."
        Debug.Print _
            "Explorer Count Before = " & CStr(explorerCountBefore)
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "I09-00 Classic Outlook Warm Start precondition", _
        passCount, failCount

    ' --------------------------------------------------------
    ' Lifecycle baseline.
    ' --------------------------------------------------------
    inspectorCountBefore = SafeInspectorCount(outlookApp)

    Set outlookNamespace = outlookApp.GetNamespace("MAPI")
    Set draftsFolder = outlookNamespace.GetDefaultFolder(OL_FOLDER_DRAFTS)

    draftCountBefore = SafeItemsCount(draftsFolder)

    lifecycleEvidenceAvailable = _
        (explorerCountBefore >= 0) And _
        (inspectorCountBefore >= 0) And _
        (draftCountBefore >= 0)

    RecordResult lifecycleEvidenceAvailable, _
        "I09-01 Lifecycle baseline acquired", _
        passCount, failCount

    If Not lifecycleEvidenceAvailable Then
        Debug.Print _
            "ABORT: Could not acquire complete Outlook lifecycle baseline."
        aborted = True
        GoTo Finalize
    End If

    Debug.Print _
        "Explorer Count Before = " & CStr(explorerCountBefore)
    Debug.Print _
        "Inspector Count Before = " & CStr(inspectorCountBefore)
    Debug.Print _
        "Draft Count Before = " & CStr(draftCountBefore)

    ' --------------------------------------------------------
    ' Preserve VariableDefinition because successful sync changes metadata.
    ' --------------------------------------------------------
    Set originalSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not originalSnapshot Is Nothing, _
        "I09-02 VariableDefinition original snapshot", _
        passCount, failCount

    If originalSnapshot Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    ' --------------------------------------------------------
    ' Real P2-04 Manual Sync.
    ' --------------------------------------------------------
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing

    Set result = ExecuteManualSync( _
        syncDiffResult, _
        templateScanResult)

    RecordResult Not result Is Nothing, _
        "I09-03 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If result Is Nothing Then
        GoTo CaptureAfter
    End If

    PrintOperationResult "ExecuteManualSync", result

    RecordResult result.Success, _
        "I09-04 ExecuteManualSync = Success", _
        passCount, failCount

    RecordResult Not templateScanResult Is Nothing, _
        "I09-05 templateScanResult = Published", _
        passCount, failCount

    RecordResult Not syncDiffResult Is Nothing, _
        "I09-06 syncDiffResult = Published", _
        passCount, failCount

CaptureAfter:
    ' Give Outlook a chance to settle COM/UI cleanup generated by the call.
    DoEvents

    explorerCountAfter = SafeExplorerCount(outlookApp)
    inspectorCountAfter = SafeInspectorCount(outlookApp)
    draftCountAfter = SafeItemsCount(draftsFolder)

    Debug.Print _
        "Explorer Count After = " & CStr(explorerCountAfter)
    Debug.Print _
        "Inspector Count After = " & CStr(inspectorCountAfter)
    Debug.Print _
        "Draft Count After = " & CStr(draftCountAfter)

    ' --------------------------------------------------------
    ' Warm lifecycle assertions.
    ' --------------------------------------------------------
    RecordResult _
        (explorerCountAfter = explorerCountBefore), _
        "I09-07 Existing Explorer reused / no unnecessary Explorer", _
        passCount, failCount

    RecordResult _
        (inspectorCountAfter = inspectorCountBefore), _
        "I09-08 Inspector residue = NONE", _
        passCount, failCount

    RecordResult _
        (draftCountAfter = draftCountBefore), _
        "I09-09 Draft residue = NONE", _
        passCount, failCount

    ' Indirect evidence consistent with the established Adapter contract:
    ' no new Explorer and no Inspector/Draft residue after scan/sync.
    RecordResult _
        (explorerCountAfter = explorerCountBefore) And _
        (inspectorCountAfter = inspectorCountBefore) And _
        (draftCountAfter = draftCountBefore), _
        "I09-10 Scan MailItem Display residue = NONE (indirect)", _
        passCount, failCount

    ' Existing Explorer must still exist after sync.
    RecordResult _
        (explorerCountAfter >= 1), _
        "I09-11 Existing Explorer remains open", _
        passCount, failCount

    Set afterSyncSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not afterSyncSnapshot Is Nothing, _
        "I09-12 Post-sync VariableDefinition snapshot", _
        passCount, failCount

RestoreState:
    ' --------------------------------------------------------
    ' Cleanup: restore VariableDefinition to pre-I09 state.
    ' This is test cleanup only; successful Manual Sync itself is expected
    ' to update LastDetectedAt and related metadata.
    ' --------------------------------------------------------
    If Not originalSnapshot Is Nothing Then

        restorationSucceeded = _
            RestoreVariableDefinitionSnapshot(originalSnapshot)

        RecordResult restorationSucceeded, _
            "I09-13 Original VariableDefinition state restored", _
            passCount, failCount

        If restorationSucceeded Then

            Set restoredSnapshot = _
                CaptureVariableDefinitionSnapshot()

            RecordResult Not restoredSnapshot Is Nothing, _
                "I09-14 Restored snapshot captured", _
                passCount, failCount

            If restoredSnapshot Is Nothing Then

                RecordResult False, _
                    "I09-15 Original State = Restored State", _
                    passCount, failCount
            Else
                RecordResult _
                    SnapshotsValueEqual( _
                        originalSnapshot, _
                        restoredSnapshot), _
                    "I09-15 Original State = Restored State", _
                    passCount, failCount
            End If
        Else
            RecordResult False, _
                "I09-14 Restored snapshot captured", _
                passCount, failCount

            RecordResult False, _
                "I09-15 Original State = Restored State", _
                passCount, failCount
        End If
    End If

Finalize:
    Debug.Print String$(76, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "I09 requires Classic Outlook to be running with an existing Explorer."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print String$(76, "=")

    Set restoredSnapshot = Nothing
    Set afterSyncSnapshot = Nothing
    Set originalSnapshot = Nothing

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing

    Set draftsFolder = Nothing
    Set outlookNamespace = Nothing
    Set outlookApp = Nothing
    Exit Sub

UnexpectedError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  Unexpected runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    On Error Resume Next

    If Not originalSnapshot Is Nothing Then
        restorationSucceeded = _
            RestoreVariableDefinitionSnapshot(originalSnapshot)

        If restorationSucceeded Then
            Debug.Print _
                "Last-chance VariableDefinition restore: PASS"
        Else
            Debug.Print _
                "Last-chance VariableDefinition restore: FAIL"
        End If
    End If

    On Error GoTo 0
    Resume Finalize
End Sub


Private Function GetRunningOutlookApplication() As Object

    Dim appValue As Object

    Set GetRunningOutlookApplication = Nothing

    On Error Resume Next
    Set appValue = GetObject(, "Outlook.Application")
    On Error GoTo 0

    If Not appValue Is Nothing Then
        Set GetRunningOutlookApplication = appValue
    End If

    Set appValue = Nothing
End Function


Private Function SafeExplorerCount( _
    ByVal outlookApp As Object _
) As Long

    SafeExplorerCount = -1

    If outlookApp Is Nothing Then Exit Function

    On Error GoTo CountError

    SafeExplorerCount = outlookApp.Explorers.Count
    Exit Function

CountError:
    SafeExplorerCount = -1
End Function


Private Function SafeInspectorCount( _
    ByVal outlookApp As Object _
) As Long

    SafeInspectorCount = -1

    If outlookApp Is Nothing Then Exit Function

    On Error GoTo CountError

    SafeInspectorCount = outlookApp.Inspectors.Count
    Exit Function

CountError:
    SafeInspectorCount = -1
End Function


Private Function SafeItemsCount( _
    ByVal folderValue As Object _
) As Long

    SafeItemsCount = -1

    If folderValue Is Nothing Then Exit Function

    On Error GoTo CountError

    SafeItemsCount = folderValue.Items.Count
    Exit Function

CountError:
    SafeItemsCount = -1
End Function


Private Function CaptureVariableDefinitionSnapshot() As Object

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim snapshot As Object

    Set CaptureVariableDefinitionSnapshot = Nothing

    On Error GoTo CaptureError

    Set ws = ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)
    Set lo = ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    Set snapshot = CreateObject("Scripting.Dictionary")
    snapshot.CompareMode = vbTextCompare

    snapshot.Add SNAPSHOT_ROW_COUNT, lo.ListRows.Count
    snapshot.Add SNAPSHOT_COLUMN_COUNT, lo.ListColumns.Count

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

    Set ws = ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)
    Set lo = ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    targetRows = CLng(snapshot.Item(SNAPSHOT_ROW_COUNT))
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

    Dim leftValues As Variant
    Dim rightValues As Variant

    Dim rowIndex As Long
    Dim columnIndex As Long

    Dim rowCount As Long
    Dim columnCount As Long

    SnapshotsValueEqual = False

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

    rowCount = CLng(leftSnapshot.Item(SNAPSHOT_ROW_COUNT))
    columnCount = CLng(leftSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    If rowCount = 0 Then
        SnapshotsValueEqual = True
        Exit Function
    End If

    leftValues = leftSnapshot.Item(SNAPSHOT_VALUES)
    rightValues = rightSnapshot.Item(SNAPSHOT_VALUES)

    For rowIndex = 1 To rowCount
        For columnIndex = 1 To columnCount

            If Not ScalarValuesEqual( _
                leftValues(rowIndex, columnIndex), _
                rightValues(rowIndex, columnIndex)) Then

                Exit Function
            End If
        Next columnIndex
    Next rowIndex

    SnapshotsValueEqual = True
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
