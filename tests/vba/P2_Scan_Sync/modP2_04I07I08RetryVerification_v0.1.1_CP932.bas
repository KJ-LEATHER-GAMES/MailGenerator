Attribute VB_Name = "modP2_04I07I08RetryVerifi"
Option Explicit

' ============================================================
' P2-04 Remaining Verification
' I07 ApplySyncDiff Failure + I08 Retry Fresh State
'
' Scope:
' - Implementation Verification only
' - Production modules are not modified
' - I07 and I08 are intentionally executed as one continuous scenario
'
' Key evidence:
' I07:
'   Scan Success
'   Definition Read Success
'   BuildSyncDiff Success
'   ApplySyncDiff Failure via worksheet protection
'   ExecuteManualSync Failure
'   syncDiffResult = Nothing
'
' I08:
'   Unprotect
'   ModelName.Status Active -> Unused
'   Retry ExecuteManualSync
'   Success
'   ModelName classified Reactivated
'   New SyncTimestamp
'   New SyncDiffResult
'
' Note:
' VariableDefinition Before = After in I07 is SUPPORTING evidence only.
' P2-03 does not provide a universal rollback / transaction contract.
' ============================================================

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"

Private Const COLUMN_VARIABLE_NAME As String = "VariableName"
Private Const COLUMN_STATUS As String = "Status"

Private Const FIELD_VARIABLE_NAME As String = "VariableName"
Private Const FIELD_STATUS As String = "Status"
Private Const FIELD_LAST_DETECTED_AT As String = "LastDetectedAt"

Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"

Private Const TARGET_VARIABLE As String = "ModelName"
Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"

Private Const TEST_PROTECT_PASSWORD As String = "P204_I07_I08_TEST_ONLY"

Private Const SNAPSHOT_VALUES As String = "Values"
Private Const SNAPSHOT_FORMULAS As String = "Formulas"
Private Const SNAPSHOT_ROW_COUNT As String = "RowCount"
Private Const SNAPSHOT_COLUMN_COUNT As String = "ColumnCount"


Public Sub TestP204I07I08ContinuousRetry()

    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Dim ws As Worksheet
    Dim statusCell As Range

    Dim originalSnapshot As Object
    Dim afterI07Snapshot As Object
    Dim retryFixtureSnapshot As Object
    Dim finalSnapshot As Object
    Dim restoredSnapshot As Object

    Dim originalStatus As Variant
    Dim originalHadFormula As Boolean
    Dim originalStatusFormula As Variant

    Dim normalScanResult As Object
    Dim protectedDefinitions As Collection
    Dim protectedBuildDiff As Object

    Dim stepResult As COperationResult
    Dim buildResult As COperationResult
    Dim executeResult As COperationResult

    Dim i07TemplateScanResult As Object
    Dim i07SyncDiffResult As Object

    Dim i08TemplateScanResult As Object
    Dim i08SyncDiffResult As Object

    Dim protectedBuildTimestamp As Date
    Dim retryStart As Date
    Dim retryLastDetectedAt As Date
    Dim retryTimestampValid As Boolean

    Dim protectionApplied As Boolean
    Dim fixtureChanged As Boolean
    Dim originalRestored As Boolean
    Dim i07StateUnchanged As Boolean

    Debug.Print String$(76, "=")
    Debug.Print "P2-04 Remaining Verification - I07 / I08 Continuous Retry"
    Debug.Print String$(76, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Environment / fixture preflight
    ' --------------------------------------------------------
    Set ws = ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    If ws.ProtectContents Then
        Debug.Print _
            "ABORT: VariableDefinition worksheet is already protected."
        Debug.Print _
            "Harness will not alter an existing protection state."
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "P00 VariableDefinition worksheet initially unprotected", _
        passCount, failCount

    Set statusCell = FindVariableDefinitionDataCell( _
        TARGET_VARIABLE, _
        COLUMN_STATUS)

    If statusCell Is Nothing Then
        Debug.Print _
            "ABORT: Could not locate ModelName.Status."
        aborted = True
        GoTo Finalize
    End If

    originalStatus = statusCell.Value2
    originalHadFormula = statusCell.HasFormula
    originalStatusFormula = statusCell.Formula

    Debug.Print _
        "Original ModelName.Status = " & CStr(originalStatus)

    RecordResult _
        (StrComp(CStr(originalStatus), STATUS_ACTIVE, vbBinaryCompare) = 0), _
        "P01 ModelName.Status = Active precondition", _
        passCount, failCount

    If StrComp(CStr(originalStatus), STATUS_ACTIVE, vbBinaryCompare) <> 0 Then
        Debug.Print _
            "ABORT: I07/I08 requires ModelName.Status = Active at start."
        aborted = True
        GoTo Finalize
    End If

    Set originalSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not originalSnapshot Is Nothing, _
        "P02 Original VariableDefinition snapshot", _
        passCount, failCount

    If originalSnapshot Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    ' Obtain normal current scan result.
    If Not GetCurrentTemplateScanResult(normalScanResult) Then
        Debug.Print _
            "ABORT: Unable to obtain normal TemplateScanResult."
        aborted = True
        GoTo Finalize
    End If

    RecordResult Not normalScanResult Is Nothing, _
        "P03 Normal TemplateScanResult obtained", _
        passCount, failCount

    If normalScanResult Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    RecordResult _
        (Not HasInvalidCandidates(normalScanResult)), _
        "P04 InvalidCandidates.Count = 0", _
        passCount, failCount

    If HasInvalidCandidates(normalScanResult) Then
        Debug.Print _
            "ABORT: Current OFT contains InvalidCandidates."
        aborted = True
        GoTo Finalize
    End If

    ' Normal-state direct build preflight:
    ' proves current data is buildable before fault injection.
    Set protectedDefinitions = Nothing
    Set stepResult = GetAllVariableDefinitions(protectedDefinitions)

    RecordResult _
        OperationSucceeded(stepResult), _
        "P05 Normal GetAllVariableDefinitions = Success", _
        passCount, failCount

    If stepResult Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    If Not stepResult.Success Then
        PrintOperationResult "Normal GetAllVariableDefinitions", stepResult
        aborted = True
        GoTo Finalize
    End If

    protectedBuildTimestamp = Now
    Set protectedBuildDiff = Nothing

    Set buildResult = BuildSyncDiff( _
        normalScanResult, _
        protectedDefinitions, _
        protectedBuildTimestamp, _
        protectedBuildDiff)

    RecordResult _
        OperationSucceeded(buildResult), _
        "P06 Normal BuildSyncDiff = Success", _
        passCount, failCount

    If buildResult Is Nothing Then
        aborted = True
        GoTo Finalize
    End If

    If Not buildResult.Success Then
        PrintOperationResult "Normal BuildSyncDiff", buildResult
        aborted = True
        GoTo Finalize
    End If

    RecordResult _
        DiffContainsVariable( _
            protectedBuildDiff, _
            KEY_EXISTING, _
            TARGET_VARIABLE), _
        "P07 ModelName classified Existing before I07", _
        passCount, failCount

    If Not DiffContainsVariable( _
        protectedBuildDiff, _
        KEY_EXISTING, _
        TARGET_VARIABLE) Then

        Debug.Print _
            "ABORT: ModelName is not Existing before I07."
        aborted = True
        GoTo Finalize
    End If

    RecordResult _
        (DiffCollectionCount(protectedBuildDiff, KEY_NEW) = 0), _
        "P08 Preflight New.Count = 0", _
        passCount, failCount

    If DiffCollectionCount(protectedBuildDiff, KEY_NEW) <> 0 Then
        Debug.Print _
            "ABORT: New variables are present; test cleanup would be ambiguous."
        aborted = True
        GoTo Finalize
    End If

    ' ========================================================
    ' I07 - ApplySyncDiff Failure
    ' ========================================================
    Debug.Print String$(76, "-")
    Debug.Print "I07 ApplySyncDiff Failure"
    Debug.Print String$(76, "-")

    ws.Protect _
        Password:=TEST_PROTECT_PASSWORD, _
        DrawingObjects:=True, _
        Contents:=True, _
        Scenarios:=True, _
        UserInterfaceOnly:=False

    protectionApplied = True

    RecordResult ws.ProtectContents, _
        "I07-00 Worksheet protection applied", _
        passCount, failCount

    If Not ws.ProtectContents Then
        Debug.Print _
            "ABORT: Worksheet protection fixture was not established."
        aborted = True
        GoTo RestoreEnvironment
    End If

    ' With protection active, read + build must still succeed.
    Set protectedDefinitions = Nothing
    Set stepResult = GetAllVariableDefinitions(protectedDefinitions)

    RecordResult _
        OperationSucceeded(stepResult), _
        "I07-01 Definition Read under protection = Success", _
        passCount, failCount

    If stepResult Is Nothing Then
        aborted = True
        GoTo RestoreEnvironment
    End If

    If Not stepResult.Success Then
        PrintOperationResult _
            "Protected GetAllVariableDefinitions", _
            stepResult
        aborted = True
        GoTo RestoreEnvironment
    End If

    protectedBuildTimestamp = Now
    Set protectedBuildDiff = Nothing

    Set buildResult = BuildSyncDiff( _
        normalScanResult, _
        protectedDefinitions, _
        protectedBuildTimestamp, _
        protectedBuildDiff)

    RecordResult _
        OperationSucceeded(buildResult), _
        "I07-02 BuildSyncDiff under protection = Success", _
        passCount, failCount

    If buildResult Is Nothing Then
        aborted = True
        GoTo RestoreEnvironment
    End If

    If Not buildResult.Success Then
        PrintOperationResult "Protected BuildSyncDiff", buildResult
        aborted = True
        GoTo RestoreEnvironment
    End If

    RecordResult _
        DiffContainsVariable( _
            protectedBuildDiff, _
            KEY_EXISTING, _
            TARGET_VARIABLE), _
        "I07-03 Protected Build classifies ModelName Existing", _
        passCount, failCount

    If Not DiffContainsVariable( _
        protectedBuildDiff, _
        KEY_EXISTING, _
        TARGET_VARIABLE) Then

        aborted = True
        GoTo RestoreEnvironment
    End If

    Set i07SyncDiffResult = Nothing
    Set i07TemplateScanResult = Nothing

    Set executeResult = ExecuteManualSync( _
        i07SyncDiffResult, _
        i07TemplateScanResult)

    RecordResult Not executeResult Is Nothing, _
        "I07-04 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not executeResult Is Nothing Then
        PrintOperationResult "I07 ExecuteManualSync", executeResult

        RecordResult Not executeResult.Success, _
            "I07-05 ExecuteManualSync = Failure", _
            passCount, failCount
    Else
        RecordResult False, _
            "I07-05 ExecuteManualSync = Failure", _
            passCount, failCount
    End If

    RecordResult Not i07TemplateScanResult Is Nothing, _
        "I07-06 templateScanResult = Published", _
        passCount, failCount

    RecordResult (i07SyncDiffResult Is Nothing), _
        "I07-07 syncDiffResult = Nothing", _
        passCount, failCount

    ' No automatic retry should have converted the operation to Success.
    RecordResult _
        OperationFailed(executeResult), _
        "I07-08 Automatic retry did not convert failure to success", _
        passCount, failCount

    Set afterI07Snapshot = CaptureVariableDefinitionSnapshot()

    If originalSnapshot Is Nothing Or afterI07Snapshot Is Nothing Then
        Debug.Print _
            "SUPPORT I07 VariableDefinition Before = After: NOT AVAILABLE"
        i07StateUnchanged = False
    Else
        i07StateUnchanged = _
            SnapshotsValueEqual(originalSnapshot, afterI07Snapshot)

        If i07StateUnchanged Then
            Debug.Print _
                "SUPPORT PASS  I07 VariableDefinition Before = After"
        Else
            Debug.Print _
                "SUPPORT OBSERVATION  I07 VariableDefinition changed during failed persistence"
        End If
    End If

    Debug.Print _
        "NOTE: This SUPPORT observation is not a universal rollback contract."

    ' I07 must end before the retry fixture is prepared.
    If protectionApplied Then
        ws.Unprotect Password:=TEST_PROTECT_PASSWORD
        protectionApplied = False
    End If

    RecordResult (Not ws.ProtectContents), _
        "I07-09 Worksheet protection removed", _
        passCount, failCount

    If ws.ProtectContents Then
        Debug.Print _
            "ABORT: Could not remove I07 protection."
        aborted = True
        GoTo RestoreEnvironment
    End If

    ' If the specific protection fixture somehow caused a partial write,
    ' restore the original data before constructing the explicit I08 state.
    ' This is cleanup for test determinism, not a rollback requirement.
    If Not i07StateUnchanged Then
        If Not RestoreVariableDefinitionSnapshot(originalSnapshot) Then
            Debug.Print _
                "ABORT: Could not restore original state before I08."
            aborted = True
            GoTo RestoreEnvironment
        End If

        Debug.Print _
            "INFO: Original state restored before preparing I08 fixture."
    End If

    ' ========================================================
    ' I08 - Retry Fresh State
    ' ========================================================
    Debug.Print String$(76, "-")
    Debug.Print "I08 Retry Fresh State"
    Debug.Print String$(76, "-")

    Set statusCell = FindVariableDefinitionDataCell( _
        TARGET_VARIABLE, _
        COLUMN_STATUS)

    If statusCell Is Nothing Then
        Debug.Print _
            "ABORT: Could not reacquire ModelName.Status before I08."
        aborted = True
        GoTo RestoreEnvironment
    End If

    statusCell.Value2 = STATUS_UNUSED
    fixtureChanged = True

    RecordResult _
        (StrComp(CStr(statusCell.Value2), STATUS_UNUSED, vbBinaryCompare) = 0), _
        "I08-00 ModelName.Status Active -> Unused", _
        passCount, failCount

    If StrComp(CStr(statusCell.Value2), STATUS_UNUSED, vbBinaryCompare) <> 0 Then
        aborted = True
        GoTo RestoreEnvironment
    End If

    Set retryFixtureSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not retryFixtureSnapshot Is Nothing, _
        "I08-01 Retry fixture snapshot captured", _
        passCount, failCount

    If retryFixtureSnapshot Is Nothing Then
        aborted = True
        GoTo RestoreEnvironment
    End If

    ' Explicitly verify the current persisted state immediately before retry.
    Set protectedDefinitions = Nothing
    Set stepResult = GetAllVariableDefinitions(protectedDefinitions)

    RecordResult _
        OperationSucceeded(stepResult), _
        "I08-02 Fresh pre-retry Definition Read = Success", _
        passCount, failCount

    If stepResult Is Nothing Then
        aborted = True
        GoTo RestoreEnvironment
    End If

    If Not stepResult.Success Then
        PrintOperationResult _
            "I08 Pre-retry GetAllVariableDefinitions", _
            stepResult
        aborted = True
        GoTo RestoreEnvironment
    End If

    RecordResult _
        CollectionContainsVariableStatus( _
            protectedDefinitions, _
            TARGET_VARIABLE, _
            STATUS_UNUSED), _
        "I08-03 CurrentDefinitions contains ModelName / Unused", _
        passCount, failCount

    If Not CollectionContainsVariableStatus( _
        protectedDefinitions, _
        TARGET_VARIABLE, _
        STATUS_UNUSED) Then

        Debug.Print _
            "ABORT: Retry fixture is not visible through production Data Access."
        aborted = True
        GoTo RestoreEnvironment
    End If

    ' Give the retry a distinct observable time boundary.
    Application.Wait DateAdd("s", 2, Now)
    retryStart = Now

    Debug.Print _
        "Retry lower-bound timestamp = " & _
        Format$(retryStart, "yyyy-mm-dd hh:nn:ss")

    Set i08SyncDiffResult = Nothing
    Set i08TemplateScanResult = Nothing

    Set executeResult = ExecuteManualSync( _
        i08SyncDiffResult, _
        i08TemplateScanResult)

    RecordResult Not executeResult Is Nothing, _
        "I08-04 Retry ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not executeResult Is Nothing Then
        PrintOperationResult "I08 Retry ExecuteManualSync", executeResult

        RecordResult executeResult.Success, _
            "I08-05 Retry ExecuteManualSync = Success", _
            passCount, failCount
    Else
        RecordResult False, _
            "I08-05 Retry ExecuteManualSync = Success", _
            passCount, failCount
    End If

    If executeResult Is Nothing Then
        GoTo RestoreEnvironment
    End If

    If Not executeResult.Success Then
        GoTo RestoreEnvironment
    End If

    RecordResult Not i08TemplateScanResult Is Nothing, _
        "I08-06 templateScanResult = Published", _
        passCount, failCount

    RecordResult Not i08SyncDiffResult Is Nothing, _
        "I08-07 New syncDiffResult = Published", _
        passCount, failCount

    If i08SyncDiffResult Is Nothing Then
        GoTo RestoreEnvironment
    End If

    RecordResult _
        DiffContainsVariable( _
            i08SyncDiffResult, _
            KEY_REACTIVATED, _
            TARGET_VARIABLE), _
        "I08-08 ModelName classified Reactivated", _
        passCount, failCount

    ' This is the strongest fresh-state evidence.
    ' If stale I07 CurrentDefinitions / Diff were reused, ModelName would remain
    ' Existing rather than Reactivated.
    RecordResult _
        Not DiffContainsVariable( _
            i08SyncDiffResult, _
            KEY_EXISTING, _
            TARGET_VARIABLE), _
        "I08-09 ModelName is not classified Existing", _
        passCount, failCount

    Set statusCell = FindVariableDefinitionDataCell( _
        TARGET_VARIABLE, _
        COLUMN_STATUS)

    If statusCell Is Nothing Then
        RecordResult False, _
            "I08-10 Persisted ModelName.Status = Active", _
            passCount, failCount
    Else
        RecordResult _
            (StrComp( _
                CStr(statusCell.Value2), _
                STATUS_ACTIVE, _
                vbBinaryCompare) = 0), _
            "I08-10 Persisted ModelName.Status = Active", _
            passCount, failCount
    End If

    retryTimestampValid = _
        TryGetDiffItemDate( _
            i08SyncDiffResult, _
            KEY_REACTIVATED, _
            TARGET_VARIABLE, _
            FIELD_LAST_DETECTED_AT, _
            retryLastDetectedAt)

    RecordResult retryTimestampValid, _
        "I08-11 Reactivated LastDetectedAt readable", _
        passCount, failCount

    If retryTimestampValid Then
        Debug.Print _
            "I08 Reactivated LastDetectedAt = " & _
            Format$(retryLastDetectedAt, "yyyy-mm-dd hh:nn:ss")

        RecordResult _
            (retryLastDetectedAt >= retryStart), _
            "I08-12 Retry uses new SyncTimestamp", _
            passCount, failCount
    Else
        RecordResult False, _
            "I08-12 Retry uses new SyncTimestamp", _
            passCount, failCount
    End If

    Set finalSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not finalSnapshot Is Nothing, _
        "I08-13 Post-retry VariableDefinition snapshot", _
        passCount, failCount

RestoreEnvironment:
    ' --------------------------------------------------------
    ' Cleanup / restore original workbook state
    ' --------------------------------------------------------
    On Error Resume Next

    If protectionApplied Then
        ws.Unprotect Password:=TEST_PROTECT_PASSWORD
        protectionApplied = False
    End If

    On Error GoTo CleanupError

    If Not originalSnapshot Is Nothing Then
        originalRestored = _
            RestoreVariableDefinitionSnapshot(originalSnapshot)

        RecordResult originalRestored, _
            "C00 Original VariableDefinition state restored", _
            passCount, failCount

        If originalRestored Then
            Set restoredSnapshot = CaptureVariableDefinitionSnapshot()

            RecordResult _
                (Not restoredSnapshot Is Nothing), _
                "C01 Restored snapshot captured", _
                passCount, failCount

            If restoredSnapshot Is Nothing Then
                RecordResult False, _
                    "C02 Original State = Restored State", _
                    passCount, failCount
            Else
                RecordResult _
                    SnapshotsValueEqual( _
                        originalSnapshot, _
                        restoredSnapshot), _
                    "C02 Original State = Restored State", _
                    passCount, failCount
            End If
        Else
            RecordResult False, _
                "C01 Restored snapshot captured", _
                passCount, failCount

            RecordResult False, _
                "C02 Original State = Restored State", _
                passCount, failCount
        End If
    End If

    fixtureChanged = False

    RecordResult (Not ws.ProtectContents), _
        "C03 Worksheet protection state restored", _
        passCount, failCount

Finalize:
    If protectionApplied Then
        On Error Resume Next
        ws.Unprotect Password:=TEST_PROTECT_PASSWORD
        protectionApplied = False
        On Error GoTo 0
        Debug.Print _
            "Last-chance worksheet unprotect executed."
    End If

    Debug.Print String$(76, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "Safety precondition stopped part of the I07/I08 scenario."
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
    Set finalSnapshot = Nothing
    Set retryFixtureSnapshot = Nothing
    Set afterI07Snapshot = Nothing
    Set originalSnapshot = Nothing

    Set i08SyncDiffResult = Nothing
    Set i08TemplateScanResult = Nothing
    Set i07SyncDiffResult = Nothing
    Set i07TemplateScanResult = Nothing

    Set protectedBuildDiff = Nothing
    Set normalScanResult = Nothing
    Set protectedDefinitions = Nothing

    Set executeResult = Nothing
    Set buildResult = Nothing
    Set stepResult = Nothing

    Set statusCell = Nothing
    Set ws = Nothing
    Exit Sub

CleanupError:
    failCount = failCount + 1
    Debug.Print _
        "FAIL  Cleanup runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume Finalize

UnexpectedError:
    failCount = failCount + 1
    Debug.Print _
        "FAIL  Unexpected runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume RestoreEnvironment
End Sub


Private Function OperationSucceeded( _
    ByVal result As COperationResult _
) As Boolean

    OperationSucceeded = False

    If result Is Nothing Then Exit Function

    OperationSucceeded = result.Success
End Function


Private Function OperationFailed( _
    ByVal result As COperationResult _
) As Boolean

    OperationFailed = False

    If result Is Nothing Then Exit Function

    OperationFailed = Not result.Success
End Function


Private Function GetCurrentTemplateScanResult( _
    ByRef scanResult As Object _
) As Boolean

    Dim result As COperationResult
    Dim cleanupResult As COperationResult

    Dim templatePath As String
    Dim resolvedPath As String
    Dim subjectText As String
    Dim bodyText As String
    Dim matchedPath As String

    Dim mailCreated As Boolean

    Set scanResult = Nothing
    GetCurrentTemplateScanResult = False

    On Error GoTo UnexpectedError

    Set result = GetSettingValue("TemplatePath", templatePath)
    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    Set result = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedPath)

    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    matchedPath = Dir$( _
        resolvedPath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

    If Len(matchedPath) = 0 Then GoTo CleanUp

    Set result = CreateMailFromTemplate(resolvedPath)
    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    mailCreated = True

    Set result = ReadSubject(subjectText)
    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    Set result = ReadBodyText(bodyText)
    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    Set result = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If result Is Nothing Then GoTo CleanUp
    If Not result.Success Then GoTo CleanUp

    Set cleanupResult = CloseWithoutSave()
    If cleanupResult Is Nothing Then GoTo CleanUp
    If Not cleanupResult.Success Then GoTo CleanUp

    mailCreated = False

    If scanResult Is Nothing Then GoTo CleanUp
    If Not IsDictionary(scanResult) Then GoTo CleanUp

    GetCurrentTemplateScanResult = True

CleanUp:
    If mailCreated Then
        Set cleanupResult = CloseWithoutSave()
    End If

    Set cleanupResult = Nothing
    Set result = Nothing
    Exit Function

UnexpectedError:
    Debug.Print _
        "Template scan preflight runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function


Private Function FindVariableDefinitionDataCell( _
    ByVal variableName As String, _
    ByVal columnName As String _
) As Range

    Dim ws As Worksheet
    Dim lo As ListObject
    Dim variableColumn As ListColumn
    Dim targetColumn As ListColumn
    Dim rowIndex As Long

    Set FindVariableDefinitionDataCell = Nothing

    On Error GoTo CleanUp

    Set ws = ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)
    Set lo = ws.ListObjects(TABLE_VARIABLE_DEFINITION)

    Set variableColumn = lo.ListColumns(COLUMN_VARIABLE_NAME)
    Set targetColumn = lo.ListColumns(columnName)

    If variableColumn.DataBodyRange Is Nothing Then GoTo CleanUp

    For rowIndex = 1 To variableColumn.DataBodyRange.Rows.Count

        If StrComp( _
            Trim$(CStr( _
                variableColumn.DataBodyRange.Cells(rowIndex, 1).Value2)), _
            variableName, _
            vbTextCompare) = 0 Then

            Set FindVariableDefinitionDataCell = _
                targetColumn.DataBodyRange.Cells(rowIndex, 1)

            Exit For
        End If
    Next rowIndex

CleanUp:
    Set targetColumn = Nothing
    Set variableColumn = Nothing
    Set lo = Nothing
    Set ws = Nothing
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

    ' Remove unexpected appended rows first.
    Do While currentRows > targetRows
        lo.ListRows(currentRows).Delete
        currentRows = lo.ListRows.Count
    Loop

    ' Add missing rows only if needed.
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


Private Function HasInvalidCandidates( _
    ByVal templateScanResult As Object _
) As Boolean

    Dim invalidCandidates As Collection

    HasInvalidCandidates = True

    If templateScanResult Is Nothing Then Exit Function
    If Not IsDictionary(templateScanResult) Then Exit Function
    If Not templateScanResult.Exists(KEY_INVALID_CANDIDATES) Then Exit Function

    On Error GoTo InspectError

    Set invalidCandidates = _
        templateScanResult.Item(KEY_INVALID_CANDIDATES)

    If invalidCandidates Is Nothing Then Exit Function

    HasInvalidCandidates = (invalidCandidates.Count > 0)

CleanUp:
    Set invalidCandidates = Nothing
    Exit Function

InspectError:
    HasInvalidCandidates = True
    Resume CleanUp
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

    Set items = syncDiffResult.Item(classificationKey)

    If items Is Nothing Then Exit Function

    DiffCollectionCount = items.Count

CleanUp:
    Set items = Nothing
    Exit Function

InspectError:
    DiffCollectionCount = -1
    Resume CleanUp
End Function


Private Function DiffContainsVariable( _
    ByVal syncDiffResult As Object, _
    ByVal classificationKey As String, _
    ByVal variableName As String _
) As Boolean

    Dim items As Collection
    Dim item As Variant
    Dim itemObject As Object

    DiffContainsVariable = False

    If syncDiffResult Is Nothing Then Exit Function
    If Not IsDictionary(syncDiffResult) Then Exit Function
    If Not syncDiffResult.Exists(classificationKey) Then Exit Function

    On Error GoTo InspectError

    Set items = syncDiffResult.Item(classificationKey)

    If items Is Nothing Then GoTo CleanUp

    For Each item In items
        If IsObject(item) Then
            Set itemObject = item

            If IsDictionary(itemObject) Then
                If itemObject.Exists(FIELD_VARIABLE_NAME) Then
                    If StrComp( _
                        CStr(itemObject.Item(FIELD_VARIABLE_NAME)), _
                        variableName, _
                        vbTextCompare) = 0 Then

                        DiffContainsVariable = True
                        GoTo CleanUp
                    End If
                End If
            End If
        End If

        Set itemObject = Nothing
    Next item

CleanUp:
    Set itemObject = Nothing
    Set items = Nothing
    Exit Function

InspectError:
    DiffContainsVariable = False
    Resume CleanUp
End Function


Private Function CollectionContainsVariableStatus( _
    ByVal definitions As Collection, _
    ByVal variableName As String, _
    ByVal expectedStatus As String _
) As Boolean

    Dim item As Variant
    Dim itemObject As Object

    CollectionContainsVariableStatus = False

    If definitions Is Nothing Then Exit Function

    On Error GoTo InspectError

    For Each item In definitions
        If IsObject(item) Then
            Set itemObject = item

            If IsDictionary(itemObject) Then
                If itemObject.Exists(FIELD_VARIABLE_NAME) And _
                   itemObject.Exists(FIELD_STATUS) Then

                    If StrComp( _
                        CStr(itemObject.Item(FIELD_VARIABLE_NAME)), _
                        variableName, _
                        vbTextCompare) = 0 Then

                        CollectionContainsVariableStatus = _
                            (StrComp( _
                                CStr(itemObject.Item(FIELD_STATUS)), _
                                expectedStatus, _
                                vbBinaryCompare) = 0)

                        GoTo CleanUp
                    End If
                End If
            End If
        End If

        Set itemObject = Nothing
    Next item

CleanUp:
    Set itemObject = Nothing
    Exit Function

InspectError:
    CollectionContainsVariableStatus = False
    Resume CleanUp
End Function


Private Function TryGetDiffItemDate( _
    ByVal syncDiffResult As Object, _
    ByVal classificationKey As String, _
    ByVal variableName As String, _
    ByVal fieldName As String, _
    ByRef dateValue As Date _
) As Boolean

    Dim items As Collection
    Dim item As Variant
    Dim itemObject As Object
    Dim rawValue As Variant

    TryGetDiffItemDate = False
    dateValue = 0

    If syncDiffResult Is Nothing Then Exit Function
    If Not IsDictionary(syncDiffResult) Then Exit Function
    If Not syncDiffResult.Exists(classificationKey) Then Exit Function

    On Error GoTo InspectError

    Set items = syncDiffResult.Item(classificationKey)

    If items Is Nothing Then GoTo CleanUp

    For Each item In items
        If IsObject(item) Then
            Set itemObject = item

            If IsDictionary(itemObject) Then
                If itemObject.Exists(FIELD_VARIABLE_NAME) Then
                    If StrComp( _
                        CStr(itemObject.Item(FIELD_VARIABLE_NAME)), _
                        variableName, _
                        vbTextCompare) = 0 Then

                        If Not itemObject.Exists(fieldName) Then
                            GoTo CleanUp
                        End If

                        rawValue = itemObject.Item(fieldName)

                        If IsDate(rawValue) Then
                            dateValue = CDate(rawValue)
                            TryGetDiffItemDate = True
                            GoTo CleanUp
                        End If

                        If IsNumeric(rawValue) Then
                            dateValue = CDate(CDbl(rawValue))
                            TryGetDiffItemDate = True
                            GoTo CleanUp
                        End If

                        GoTo CleanUp
                    End If
                End If
            End If
        End If

        Set itemObject = Nothing
    Next item

CleanUp:
    Set itemObject = Nothing
    Set items = Nothing
    Exit Function

InspectError:
    TryGetDiffItemDate = False
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
