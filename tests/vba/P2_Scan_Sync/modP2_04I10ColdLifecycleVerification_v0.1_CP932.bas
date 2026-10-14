Attribute VB_Name = "modP204I10ColdLifecycle"
Option Explicit

' ============================================================
' P2-04 Remaining Verification
' I10 Cold Lifecycle
'
' Two-step verification:
'
' Step A (Outlook running):
'   PrepareP204I10ColdLifecycleBaseline
'   - capture Draft Count baseline
'   - require Explorer >= 1 / Inspector = 0
'   - release all Outlook COM references
'
' User action:
'   - fully exit Classic Outlook
'   - keep Excel / VBA project open
'
' Step B (Outlook fully stopped):
'   TestP204I10ColdLifecycle
'   - verify OUTLOOK.EXE process count = 0
'   - verify GetObject cannot attach to Outlook
'   - execute real ExecuteManualSync
'   - verify Outlook process + Visible Explorer established
'   - verify Inspector residue = 0
'   - verify Draft Count unchanged from Step A
'   - restore VariableDefinition snapshot
'
' This is Implementation Verification, not Formal MVP Test.
' ============================================================

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"

Private Const OL_FOLDER_DRAFTS As Long = 16

Private Const SNAPSHOT_VALUES As String = "Values"
Private Const SNAPSHOT_FORMULAS As String = "Formulas"
Private Const SNAPSHOT_ROW_COUNT As String = "RowCount"
Private Const SNAPSHOT_COLUMN_COUNT As String = "ColumnCount"

Private mI10BaselinePrepared As Boolean
Private mI10DraftCountBaseline As Long
Private mI10ExplorerCountBaseline As Long
Private mI10InspectorCountBaseline As Long
Private mI10BaselineCapturedAt As Date


Public Sub PrepareP204I10ColdLifecycleBaseline()

    Dim outlookApp As Object
    Dim outlookNamespace As Object
    Dim draftsFolder As Object

    Dim processCount As Long
    Dim explorerCount As Long
    Dim inspectorCount As Long
    Dim draftCount As Long

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 I10 Cold Lifecycle - Baseline Preparation"
    Debug.Print String$(76, "=")

    mI10BaselinePrepared = False

    On Error GoTo PreparationError

    processCount = CountOutlookProcesses()

    If processCount < 1 Then
        Debug.Print _
            "ABORT: OUTLOOK.EXE is not running."
        Debug.Print _
            "Open Classic Outlook manually before baseline preparation."
        GoTo CleanUp
    End If

    Set outlookApp = GetRunningOutlookApplication()

    If outlookApp Is Nothing Then
        Debug.Print _
            "ABORT: Could not attach to the running Classic Outlook instance."
        GoTo CleanUp
    End If

    explorerCount = SafeExplorerCount(outlookApp)
    inspectorCount = SafeInspectorCount(outlookApp)

    If explorerCount < 1 Then
        Debug.Print _
            "ABORT: Baseline preparation requires Explorer Count >= 1."
        GoTo CleanUp
    End If

    If inspectorCount <> 0 Then
        Debug.Print _
            "ABORT: Close all open mail Inspector windows before preparation."
        Debug.Print _
            "Inspector Count = " & CStr(inspectorCount)
        GoTo CleanUp
    End If

    Set outlookNamespace = outlookApp.GetNamespace("MAPI")
    Set draftsFolder = outlookNamespace.GetDefaultFolder(OL_FOLDER_DRAFTS)

    draftCount = SafeItemsCount(draftsFolder)

    If draftCount < 0 Then
        Debug.Print _
            "ABORT: Draft Count could not be acquired."
        GoTo CleanUp
    End If

    mI10DraftCountBaseline = draftCount
    mI10ExplorerCountBaseline = explorerCount
    mI10InspectorCountBaseline = inspectorCount
    mI10BaselineCapturedAt = Now
    mI10BaselinePrepared = True

    Debug.Print "PASS  Baseline prepared"
    Debug.Print _
        "OUTLOOK.EXE Process Count = " & CStr(processCount)
    Debug.Print _
        "Explorer Count Baseline = " & CStr(explorerCount)
    Debug.Print _
        "Inspector Count Baseline = " & CStr(inspectorCount)
    Debug.Print _
        "Draft Count Baseline = " & CStr(draftCount)
    Debug.Print _
        "Baseline Captured At = " & _
        Format$(mI10BaselineCapturedAt, "yyyy-mm-dd hh:nn:ss")

    Debug.Print String$(76, "-")
    Debug.Print _
        "NEXT: Fully exit Classic Outlook, keep Excel open, then run:"
    Debug.Print _
        "      TestP204I10ColdLifecycle"
    Debug.Print String$(76, "=")

CleanUp:
    ' Critical: release all Harness-held Outlook references so that
    ' the user can fully terminate Classic Outlook.
    Set draftsFolder = Nothing
    Set outlookNamespace = Nothing
    Set outlookApp = Nothing
    Exit Sub

PreparationError:
    mI10BaselinePrepared = False

    Debug.Print _
        "ABORT: Baseline preparation runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume CleanUp
End Sub


Public Sub TestP204I10ColdLifecycle()

    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean
    Dim productionRunStarted As Boolean

    Dim outlookAppBefore As Object
    Dim outlookAppAfter As Object
    Dim outlookNamespaceAfter As Object
    Dim draftsFolderAfter As Object

    Dim processCountBefore As Long
    Dim processCountAfter As Long

    Dim explorerCountAfter As Long
    Dim inspectorCountAfter As Long
    Dim draftCountAfter As Long

    Dim hasActiveExplorerAfter As Boolean

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim originalSnapshot As Object
    Dim afterSyncSnapshot As Object
    Dim restoredSnapshot As Object

    Dim restorationSucceeded As Boolean

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 Remaining Verification - I10 Cold Lifecycle"
    Debug.Print String$(76, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Step A baseline must have been captured before Outlook shutdown.
    ' --------------------------------------------------------
    If Not mI10BaselinePrepared Then
        Debug.Print _
            "ABORT: I10 baseline has not been prepared in this VBA session."
        Debug.Print _
            "Run PrepareP204I10ColdLifecycleBaseline while Outlook is running."
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "I10-00 Pre-shutdown lifecycle baseline available", _
        passCount, failCount

    Debug.Print _
        "Draft Count Baseline = " & CStr(mI10DraftCountBaseline)
    Debug.Print _
        "Baseline Captured At = " & _
        Format$(mI10BaselineCapturedAt, "yyyy-mm-dd hh:nn:ss")

    ' --------------------------------------------------------
    ' Cold Start precondition.
    ' WMI query does not start Outlook.
    ' GetObject only attempts to attach; it does not CreateObject.
    ' --------------------------------------------------------
    processCountBefore = CountOutlookProcesses()

    Debug.Print _
        "OUTLOOK.EXE Process Count Before = " & _
        CStr(processCountBefore)

    RecordResult _
        (processCountBefore = 0), _
        "I10-01 OUTLOOK.EXE Not Running", _
        passCount, failCount

    If processCountBefore <> 0 Then
        Debug.Print _
            "ABORT: Cold Start requires OUTLOOK.EXE process count = 0."
        aborted = True
        GoTo Finalize
    End If

    Set outlookAppBefore = GetRunningOutlookApplication()

    RecordResult _
        (outlookAppBefore Is Nothing), _
        "I10-02 No running Outlook.Application available", _
        passCount, failCount

    If Not outlookAppBefore Is Nothing Then
        Debug.Print _
            "ABORT: GetObject unexpectedly attached to Outlook."
        aborted = True
        GoTo Finalize
    End If

    ' --------------------------------------------------------
    ' Preserve VariableDefinition because successful sync updates metadata.
    ' --------------------------------------------------------
    Set originalSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not originalSnapshot Is Nothing, _
        "I10-03 VariableDefinition original snapshot", _
        passCount, failCount

    If originalSnapshot Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    ' --------------------------------------------------------
    ' Real P2-04 path.
    ' This call must start / initialize Classic Outlook as needed.
    ' --------------------------------------------------------
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing

    productionRunStarted = True

    Set result = ExecuteManualSync( _
        syncDiffResult, _
        templateScanResult)

    RecordResult Not result Is Nothing, _
        "I10-04 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If result Is Nothing Then
        GoTo CaptureAfter
    End If

    PrintOperationResult "ExecuteManualSync", result

    RecordResult result.Success, _
        "I10-05 ExecuteManualSync = Success", _
        passCount, failCount

    RecordResult Not templateScanResult Is Nothing, _
        "I10-06 templateScanResult = Published", _
        passCount, failCount

    RecordResult Not syncDiffResult Is Nothing, _
        "I10-07 syncDiffResult = Published", _
        passCount, failCount

CaptureAfter:
    DoEvents

    ' --------------------------------------------------------
    ' Reacquire Outlook only AFTER the Production cold-start path ran.
    ' --------------------------------------------------------
    processCountAfter = CountOutlookProcesses()

    Debug.Print _
        "OUTLOOK.EXE Process Count After = " & _
        CStr(processCountAfter)

    RecordResult _
        (processCountAfter >= 1), _
        "I10-08 Classic Outlook process established", _
        passCount, failCount

    Set outlookAppAfter = GetRunningOutlookApplication()

    RecordResult _
        (Not outlookAppAfter Is Nothing), _
        "I10-09 Cold Start Outlook.Application reacquired", _
        passCount, failCount

    If outlookAppAfter Is Nothing Then
        GoTo RestoreState
    End If

    explorerCountAfter = SafeExplorerCount(outlookAppAfter)
    inspectorCountAfter = SafeInspectorCount(outlookAppAfter)
    hasActiveExplorerAfter = SafeHasActiveExplorer(outlookAppAfter)

    Debug.Print _
        "Explorer Count After = " & CStr(explorerCountAfter)
    Debug.Print _
        "Inspector Count After = " & CStr(inspectorCountAfter)
    Debug.Print _
        "Active Explorer After = " & CStr(hasActiveExplorerAfter)

    RecordResult _
        (explorerCountAfter >= 1), _
        "I10-10 Visible Explorer established", _
        passCount, failCount

    RecordResult _
        hasActiveExplorerAfter, _
        "I10-11 Active Explorer available", _
        passCount, failCount

    RecordResult _
        (inspectorCountAfter = 0), _
        "I10-12 Inspector residue = NONE", _
        passCount, failCount

    Set outlookNamespaceAfter = _
        outlookAppAfter.GetNamespace("MAPI")

    Set draftsFolderAfter = _
        outlookNamespaceAfter.GetDefaultFolder(OL_FOLDER_DRAFTS)

    draftCountAfter = SafeItemsCount(draftsFolderAfter)

    Debug.Print _
        "Draft Count After = " & CStr(draftCountAfter)

    RecordResult _
        (draftCountAfter = mI10DraftCountBaseline), _
        "I10-13 Draft residue = NONE", _
        passCount, failCount

    ' Runtime lifecycle evidence + established Adapter contract.
    RecordResult _
        (inspectorCountAfter = 0) And _
        (draftCountAfter = mI10DraftCountBaseline), _
        "I10-14 Scan MailItem Display residue = NONE (indirect)", _
        passCount, failCount

    ' Cold-start Explorer is intentionally left running by Production.
    RecordResult _
        (explorerCountAfter >= 1), _
        "I10-15 Cold-start Explorer remains open", _
        passCount, failCount

    Set afterSyncSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not afterSyncSnapshot Is Nothing, _
        "I10-16 Post-sync VariableDefinition snapshot", _
        passCount, failCount

RestoreState:
    ' --------------------------------------------------------
    ' Restore workbook data only.
    ' Do NOT close the cold-start Explorer; remaining open is expected.
    ' --------------------------------------------------------
    If Not originalSnapshot Is Nothing Then

        restorationSucceeded = _
            RestoreVariableDefinitionSnapshot(originalSnapshot)

        RecordResult restorationSucceeded, _
            "I10-17 Original VariableDefinition state restored", _
            passCount, failCount

        If restorationSucceeded Then

            Set restoredSnapshot = _
                CaptureVariableDefinitionSnapshot()

            RecordResult Not restoredSnapshot Is Nothing, _
                "I10-18 Restored snapshot captured", _
                passCount, failCount

            If restoredSnapshot Is Nothing Then
                RecordResult False, _
                    "I10-19 Original State = Restored State", _
                    passCount, failCount
            Else
                RecordResult _
                    SnapshotsValueEqual( _
                        originalSnapshot, _
                        restoredSnapshot), _
                    "I10-19 Original State = Restored State", _
                    passCount, failCount
            End If
        Else
            RecordResult False, _
                "I10-18 Restored snapshot captured", _
                passCount, failCount

            RecordResult False, _
                "I10-19 Original State = Restored State", _
                passCount, failCount
        End If
    End If

    If productionRunStarted Then
        ' Prevent accidental reuse of an old Draft baseline on another run.
        mI10BaselinePrepared = False
    End If

Finalize:
    Debug.Print String$(76, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "Cold Start precondition was not satisfied; Production path was not run."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If

        Debug.Print _
            "NOTE: Cold-start Explorer is intentionally left open."
    End If

    Debug.Print String$(76, "=")

    Set restoredSnapshot = Nothing
    Set afterSyncSnapshot = Nothing
    Set originalSnapshot = Nothing

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing

    Set draftsFolderAfter = Nothing
    Set outlookNamespaceAfter = Nothing
    Set outlookAppAfter = Nothing
    Set outlookAppBefore = Nothing
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

    If productionRunStarted Then
        mI10BaselinePrepared = False
    End If

    On Error GoTo 0
    Resume Finalize
End Sub


Private Function CountOutlookProcesses() As Long

    Dim wmiService As Object
    Dim processes As Object

    CountOutlookProcesses = -1

    On Error GoTo QueryError

    Set wmiService = _
        GetObject("winmgmts:\\.\root\cimv2")

    Set processes = wmiService.ExecQuery( _
        "SELECT * FROM Win32_Process " & _
        "WHERE Name='OUTLOOK.EXE'")

    CountOutlookProcesses = processes.Count

CleanUp:
    Set processes = Nothing
    Set wmiService = Nothing
    Exit Function

QueryError:
    Debug.Print _
        "OUTLOOK.EXE process query error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function


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


Private Function SafeHasActiveExplorer( _
    ByVal outlookApp As Object _
) As Boolean

    Dim explorerValue As Object

    SafeHasActiveExplorer = False

    If outlookApp Is Nothing Then Exit Function

    On Error GoTo ExplorerError

    Set explorerValue = outlookApp.ActiveExplorer

    SafeHasActiveExplorer = _
        Not explorerValue Is Nothing

CleanUp:
    Set explorerValue = Nothing
    Exit Function

ExplorerError:
    SafeHasActiveExplorer = False
    Resume CleanUp
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
