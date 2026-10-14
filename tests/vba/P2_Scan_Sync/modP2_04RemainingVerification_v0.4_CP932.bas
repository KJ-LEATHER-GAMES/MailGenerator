Attribute VB_Name = "modP2_04RemainVerification"
Option Explicit

' P2-04 Manual Sync Integration - Remaining Verification Harness
'
' Current scope:
' - I03 Invalid Candidate
' - I04 OFT Missing
' - I05 Definition Read Failure
'   v0.3.1: I05-07 aligned with existing GetAllVariableDefinitions carrier contract
' - I06 BuildSyncDiff Failure
'
' This is Implementation Verification, not Formal MVP Test.
' Production code is not modified by this test artifact.
' No test-only Production Public API is required.
'
' I03 fixture:
' - Current OFT contains at least one invalid variable candidate.
' - Recommended fixture: {{1stGate}}
'
' Entry point:
'   TestP204I03InvalidCandidate
'
' Safety:
' - Before ExecuteManualSync is called, this harness independently scans the
'   current OFT through existing Production public APIs.
' - If InvalidCandidates.Count = 0, the test ABORTS before Manual Sync so that
'   an incorrectly prepared fixture cannot update tblVariableDefinition.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Private Const SHEET_SETTINGS As String = "Settings"
Private Const TABLE_SETTINGS As String = "tblSettings"
Private Const COLUMN_SETTINGS_KEY As String = "Key"
Private Const COLUMN_SETTINGS_VALUE As String = "Value"

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"
Private Const COLUMN_VARIABLE_NAME As String = "VariableName"
Private Const COLUMN_VARIABLE_STATUS As String = "Status"
Private Const COLUMN_VARIABLE_STATUS_BROKEN As String = "Status_TEST_BROKEN"

Private Const I06_TARGET_VARIABLE As String = "ModelName"
Private Const I06_INVALID_STATUS As String = "InvalidStatus"

Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const FIELD_VARIABLE_NAME As String = "VariableName"

Private Const SNAPSHOT_HAS_DATA As String = "HasData"
Private Const SNAPSHOT_ROW_COUNT As String = "RowCount"
Private Const SNAPSHOT_COLUMN_COUNT As String = "ColumnCount"
Private Const SNAPSHOT_VALUES As String = "Values"

Public Sub TestP204I03InvalidCandidate()

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim beforeSnapshot As Object
    Dim afterSnapshot As Object

    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Remaining Verification - I03 Invalid Candidate"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Safety preflight.
    ' Abort before ExecuteManualSync if the OFT fixture does not actually
    ' contain InvalidCandidates.
    ' --------------------------------------------------------
    If Not VerifyI03FixtureReady() Then
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "I03-00 Invalid Candidate fixture preflight", _
        passCount, failCount

    Set beforeSnapshot = CaptureVariableDefinitionSnapshot()

    If beforeSnapshot Is Nothing Then
        RecordResult False, _
            "I03-01 VariableDefinition Before snapshot", _
            passCount, failCount
        GoTo Finalize
    End If

    RecordResult True, _
        "I03-01 VariableDefinition Before snapshot", _
        passCount, failCount

    Debug.Print _
        "Before Snapshot: Rows=" & CStr(beforeSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
        "; Columns=" & CStr(beforeSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    ' --------------------------------------------------------
    ' Production entry point under test.
    ' --------------------------------------------------------
    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    Set afterSnapshot = CaptureVariableDefinitionSnapshot()

    ' --------------------------------------------------------
    ' Expected:
    ' ExecuteManualSync = Failure
    ' templateScanResult = Published
    ' InvalidCandidates.Count > 0
    ' syncDiffResult = Nothing
    ' VariableDefinition Before = After
    ' --------------------------------------------------------
    RecordResult Not result Is Nothing, _
        "I03-02 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not result Is Nothing Then
        PrintOperationResultI03 "ExecuteManualSync", result

        RecordResult Not result.Success, _
            "I03-03 ExecuteManualSync = Failure", _
            passCount, failCount
    Else
        RecordResult False, _
            "I03-03 ExecuteManualSync = Failure", _
            passCount, failCount
    End If

    RecordResult Not templateScanResult Is Nothing, _
        "I03-04 templateScanResult = Published", _
        passCount, failCount

    If Not templateScanResult Is Nothing Then
        RecordResult IsDictionaryI03(templateScanResult), _
            "I03-05 templateScanResult is Dictionary", _
            passCount, failCount

        If IsDictionaryI03(templateScanResult) Then
            RecordResult _
                HasInvalidCandidates(templateScanResult), _
                "I03-06 InvalidCandidates.Count > 0", _
                passCount, failCount

            PrintInvalidCandidates templateScanResult
        Else
            RecordResult False, _
                "I03-06 InvalidCandidates.Count > 0", _
                passCount, failCount
        End If
    Else
        RecordResult False, _
            "I03-05 templateScanResult is Dictionary", _
            passCount, failCount

        RecordResult False, _
            "I03-06 InvalidCandidates.Count > 0", _
            passCount, failCount
    End If

    RecordResult (syncDiffResult Is Nothing), _
        "I03-07 syncDiffResult = Nothing", _
        passCount, failCount

    RecordResult Not afterSnapshot Is Nothing, _
        "I03-08 VariableDefinition After snapshot", _
        passCount, failCount

    If Not afterSnapshot Is Nothing Then
        Debug.Print _
            "After Snapshot: Rows=" & CStr(afterSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
            "; Columns=" & CStr(afterSnapshot.Item(SNAPSHOT_COLUMN_COUNT))
    End If

    If beforeSnapshot Is Nothing Or afterSnapshot Is Nothing Then
        RecordResult False, _
            "I03-09 VariableDefinition Before = After", _
            passCount, failCount
    Else
        RecordResult _
            SnapshotsEqual(beforeSnapshot, afterSnapshot), _
            "I03-09 VariableDefinition Before = After", _
            passCount, failCount
    End If

Finalize:
    Debug.Print String$(72, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "Reason: I03 fixture preflight did not confirm InvalidCandidates > 0."
        Debug.Print _
            "No ExecuteManualSync call was made by this test."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print String$(72, "=")

    Set afterSnapshot = Nothing
    Set beforeSnapshot = Nothing
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing
    Exit Sub

UnexpectedError:
    failCount = failCount + 1
    Debug.Print _
        "FAIL  Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume Finalize
End Sub


Public Sub TestP204I04OftMissing()

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim beforeSnapshot As Object
    Dim afterSnapshot As Object

    Dim templatePathCell As Range
    Dim originalTemplatePath As Variant
    Dim originalTemplateFormula As Variant
    Dim originalHadFormula As Boolean

    Dim missingTemplatePath As String
    Dim resolvedMissingPath As String
    Dim restoredTemplatePath As String

    Dim fixtureChanged As Boolean
    Dim restorationSucceeded As Boolean
    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Remaining Verification - I04 OFT Missing"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Locate and capture the real Settings.TemplatePath cell.
    ' The harness restores this exact cell before it finishes.
    ' --------------------------------------------------------
    Set templatePathCell = FindTemplatePathValueCell()

    If templatePathCell Is Nothing Then
        Debug.Print "ABORT: Settings.TemplatePath cell could not be located."
        aborted = True
        GoTo Finalize
    End If

    originalHadFormula = templatePathCell.HasFormula
    originalTemplatePath = templatePathCell.Value2
    originalTemplateFormula = templatePathCell.Formula

    If Len(Trim$(CStr(originalTemplatePath))) = 0 Then
        Debug.Print "ABORT: Original Settings.TemplatePath is blank."
        aborted = True
        GoTo Finalize
    End If

    Debug.Print "Original TemplatePath = " & CStr(originalTemplatePath)

    ' --------------------------------------------------------
    ' Generate a unique relative path under Templates and confirm that the
    ' resolved absolute path does not exist BEFORE changing Settings.
    ' --------------------------------------------------------
    If Not BuildMissingTemplateFixturePath( _
        missingTemplatePath, _
        resolvedMissingPath) Then

        Debug.Print _
            "ABORT: Unable to create a confirmed-missing OFT fixture path."
        aborted = True
        GoTo Finalize
    End If

    Debug.Print "Missing TemplatePath = " & missingTemplatePath
    Debug.Print "Resolved Missing Path = " & resolvedMissingPath

    RecordResult True, _
        "I04-00 Missing OFT fixture preflight", _
        passCount, failCount

    Set beforeSnapshot = CaptureVariableDefinitionSnapshot()

    If beforeSnapshot Is Nothing Then
        RecordResult False, _
            "I04-01 VariableDefinition Before snapshot", _
            passCount, failCount
        GoTo Finalize
    End If

    RecordResult True, _
        "I04-01 VariableDefinition Before snapshot", _
        passCount, failCount

    Debug.Print _
        "Before Snapshot: Rows=" & CStr(beforeSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
        "; Columns=" & CStr(beforeSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    ' --------------------------------------------------------
    ' Fixture setup.
    ' Write only the Settings.TemplatePath Value cell.
    ' --------------------------------------------------------
    templatePathCell.Value2 = missingTemplatePath
    fixtureChanged = True

    RecordResult _
        SettingValueMatches(missingTemplatePath), _
        "I04-02 Temporary TemplatePath applied", _
        passCount, failCount

    If Not SettingValueMatches(missingTemplatePath) Then
        GoTo RestoreFixture
    End If

    ' --------------------------------------------------------
    ' Production entry point under test.
    ' --------------------------------------------------------
    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    Set afterSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not result Is Nothing, _
        "I04-03 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not result Is Nothing Then
        PrintOperationResultI03 "ExecuteManualSync", result

        RecordResult Not result.Success, _
            "I04-04 ExecuteManualSync = Failure", _
            passCount, failCount

        RecordResult _
            OperationResultContainsError( _
                result, _
                "ConfigurationError", _
                SETTING_TEMPLATE_PATH, _
                "Template file does not exist."), _
            "I04-05 ConfigurationError / TemplatePath / OFT missing", _
            passCount, failCount
    Else
        RecordResult False, _
            "I04-04 ExecuteManualSync = Failure", _
            passCount, failCount

        RecordResult False, _
            "I04-05 ConfigurationError / TemplatePath / OFT missing", _
            passCount, failCount
    End If

    ' ScanCurrentTemplate fails at OFT existence validation, so no
    ' TemplateScanResult carrier is published.
    RecordResult (templateScanResult Is Nothing), _
        "I04-06 templateScanResult = Nothing", _
        passCount, failCount

    ' Build / Apply are downstream of successful template scan.
    ' syncDiffResult must remain unpublished.
    RecordResult (syncDiffResult Is Nothing), _
        "I04-07 syncDiffResult = Nothing", _
        passCount, failCount

    RecordResult Not afterSnapshot Is Nothing, _
        "I04-08 VariableDefinition After snapshot", _
        passCount, failCount

    If Not afterSnapshot Is Nothing Then
        Debug.Print _
            "After Snapshot: Rows=" & CStr(afterSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
            "; Columns=" & CStr(afterSnapshot.Item(SNAPSHOT_COLUMN_COUNT))
    End If

    If beforeSnapshot Is Nothing Or afterSnapshot Is Nothing Then
        RecordResult False, _
            "I04-09 VariableDefinition Before = After", _
            passCount, failCount
    Else
        RecordResult _
            SnapshotsEqual(beforeSnapshot, afterSnapshot), _
            "I04-09 VariableDefinition Before = After", _
            passCount, failCount
    End If

RestoreFixture:
    ' --------------------------------------------------------
    ' Restore Settings before evaluating the final result.
    ' This also runs after any test failure following fixture setup.
    ' --------------------------------------------------------
    If fixtureChanged Then
        On Error GoTo RestorationError

        If originalHadFormula Then
            templatePathCell.Formula = originalTemplateFormula
        Else
            templatePathCell.Value2 = originalTemplatePath
        End If

        fixtureChanged = False

        Set result = GetSettingValue( _
            SETTING_TEMPLATE_PATH, _
            restoredTemplatePath)

        restorationSucceeded = False

        If Not result Is Nothing Then
            If result.Success Then
                restorationSucceeded = _
                    (StrComp( _
                        restoredTemplatePath, _
                        CStr(originalTemplatePath), _
                        vbBinaryCompare) = 0)
            End If
        End If

        RecordResult restorationSucceeded, _
            "I04-10 Settings.TemplatePath restored", _
            passCount, failCount

        If restorationSucceeded Then
            Debug.Print _
                "Restored TemplatePath = " & restoredTemplatePath
        Else
            Debug.Print _
                "WARNING: Settings.TemplatePath restoration verification failed."
        End If
    Else
        restorationSucceeded = True
    End If

Finalize:
    ' Last-chance restore if an unexpected error occurred after fixture setup.
    If fixtureChanged Then
        On Error Resume Next

        If originalHadFormula Then
            templatePathCell.Formula = originalTemplateFormula
        Else
            templatePathCell.Value2 = originalTemplatePath
        End If

        fixtureChanged = False

        Err.Clear
        On Error GoTo 0

        Debug.Print _
            "Last-chance Settings.TemplatePath restore executed."
    End If

    Debug.Print String$(72, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "No ExecuteManualSync call was made by this test."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print String$(72, "=")

    Set templatePathCell = Nothing
    Set afterSnapshot = Nothing
    Set beforeSnapshot = Nothing
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing
    Exit Sub

RestorationError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  I04-10 Settings.TemplatePath restore runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize

UnexpectedError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize
End Sub

Private Function FindTemplatePathValueCell() As Range

    Dim worksheetValue As Worksheet
    Dim tableValue As ListObject
    Dim keyColumn As ListColumn
    Dim valueColumn As ListColumn
    Dim rowIndex As Long
    Dim keyValue As Variant

    Set FindTemplatePathValueCell = Nothing

    On Error GoTo LookupError

    Set worksheetValue = ThisWorkbook.Worksheets(SHEET_SETTINGS)
    Set tableValue = worksheetValue.ListObjects(TABLE_SETTINGS)
    Set keyColumn = tableValue.ListColumns(COLUMN_SETTINGS_KEY)
    Set valueColumn = tableValue.ListColumns(COLUMN_SETTINGS_VALUE)

    If keyColumn.DataBodyRange Is Nothing Then
        GoTo CleanUp
    End If

    For rowIndex = 1 To keyColumn.DataBodyRange.Rows.Count
        keyValue = keyColumn.DataBodyRange.Cells(rowIndex, 1).Value2

        If StrComp( _
            Trim$(CStr(keyValue)), _
            SETTING_TEMPLATE_PATH, _
            vbTextCompare) = 0 Then

            Set FindTemplatePathValueCell = _
                valueColumn.DataBodyRange.Cells(rowIndex, 1)

            GoTo CleanUp
        End If
    Next rowIndex

CleanUp:
    Set valueColumn = Nothing
    Set keyColumn = Nothing
    Set tableValue = Nothing
    Set worksheetValue = Nothing
    Exit Function

LookupError:
    Debug.Print _
        "Settings lookup error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function BuildMissingTemplateFixturePath( _
    ByRef relativePath As String, _
    ByRef resolvedPath As String _
) As Boolean

    Dim stepResult As COperationResult
    Dim candidateRelativePath As String
    Dim candidateResolvedPath As String
    Dim matchedPath As String
    Dim attempt As Long

    BuildMissingTemplateFixturePath = False
    relativePath = vbNullString
    resolvedPath = vbNullString

    On Error GoTo FixtureError

    For attempt = 1 To 25

        candidateRelativePath = _
            "Templates\__P2_04_I04_MISSING_" & _
            Format$(Now, "yyyymmdd_hhnnss") & _
            "_" & Format$(attempt, "00") & ".oft"

        Set stepResult = ResolveWorkbookRelativePath( _
            candidateRelativePath, _
            candidateResolvedPath)

        If stepResult Is Nothing Then
            GoTo NextAttempt
        End If

        If Not stepResult.Success Then
            GoTo NextAttempt
        End If

        matchedPath = Dir$( _
            candidateResolvedPath, _
            vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

        If Len(matchedPath) = 0 Then
            relativePath = candidateRelativePath
            resolvedPath = candidateResolvedPath
            BuildMissingTemplateFixturePath = True
            GoTo CleanUp
        End If

NextAttempt:
        Set stepResult = Nothing
    Next attempt

CleanUp:
    Set stepResult = Nothing
    Exit Function

FixtureError:
    Debug.Print _
        "Missing OFT fixture path error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function SettingValueMatches( _
    ByVal expectedValue As String _
) As Boolean

    Dim stepResult As COperationResult
    Dim actualValue As String

    SettingValueMatches = False

    On Error GoTo ReadError

    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        actualValue)

    If stepResult Is Nothing Then
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        GoTo CleanUp
    End If

    SettingValueMatches = _
        (StrComp(actualValue, expectedValue, vbBinaryCompare) = 0)

CleanUp:
    Set stepResult = Nothing
    Exit Function

ReadError:
    SettingValueMatches = False
    Resume CleanUp
End Function

Private Function OperationResultContainsError( _
    ByVal operationResult As COperationResult, _
    ByVal expectedErrorType As String, _
    ByVal expectedTarget As String, _
    ByVal expectedMessage As String _
) As Boolean

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    OperationResultContainsError = False

    If operationResult Is Nothing Then Exit Function

    On Error GoTo InspectError

    Set errors = operationResult.Errors

    If errors Is Nothing Then
        GoTo CleanUp
    End If

    For Each errorInfo In errors
        If StrComp( _
            errorInfo.ErrorType, _
            expectedErrorType, _
            vbBinaryCompare) = 0 Then

            If StrComp( _
                errorInfo.Target, _
                expectedTarget, _
                vbBinaryCompare) = 0 Then

                If StrComp( _
                    errorInfo.Message, _
                    expectedMessage, _
                    vbBinaryCompare) = 0 Then

                    OperationResultContainsError = True
                    GoTo CleanUp
                End If
            End If
        End If
    Next errorInfo

CleanUp:
    Set errorInfo = Nothing
    Set errors = Nothing
    Exit Function

InspectError:
    OperationResultContainsError = False
    Resume CleanUp
End Function


Public Sub TestP204I05DefinitionReadFailure()

    Dim result As COperationResult
    Dim definitionReadResult As COperationResult

    Dim syncDiffResult As Object
    Dim templateScanResult As Object
    Dim directDefinitions As Collection

    Dim beforeSnapshot As Object
    Dim afterSnapshot As Object

    Dim statusColumn As ListColumn
    Dim originalStatusName As String

    Dim fixtureChanged As Boolean
    Dim restorationSucceeded As Boolean
    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Remaining Verification - I05 Definition Read Failure"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Preflight 1:
    ' Current OFT must be readable and must contain no InvalidCandidates.
    ' Otherwise I05 would not reach VariableDefinition retrieval.
    ' --------------------------------------------------------
    If Not VerifyNormalTemplateReady() Then
        Debug.Print _
            "ABORT: Current OFT did not pass the normal-template preflight."
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "I05-00 Normal template preflight", _
        passCount, failCount

    ' --------------------------------------------------------
    ' Preflight 2:
    ' Locate the real Status column and confirm that the broken fixture name
    ' is not already present.
    ' --------------------------------------------------------
    Set statusColumn = FindVariableDefinitionColumn(COLUMN_VARIABLE_STATUS)

    If statusColumn Is Nothing Then
        Debug.Print _
            "ABORT: tblVariableDefinition.Status column could not be located."
        aborted = True
        GoTo Finalize
    End If

    If VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS_BROKEN) Then
        Debug.Print _
            "ABORT: Fixture column already exists: " & _
            COLUMN_VARIABLE_STATUS_BROKEN
        aborted = True
        GoTo Finalize
    End If

    originalStatusName = statusColumn.Name

    RecordResult _
        (StrComp( _
            originalStatusName, _
            COLUMN_VARIABLE_STATUS, _
            vbBinaryCompare) = 0), _
        "I05-01 Status column preflight", _
        passCount, failCount

    If StrComp( _
        originalStatusName, _
        COLUMN_VARIABLE_STATUS, _
        vbBinaryCompare) <> 0 Then

        GoTo Finalize
    End If

    Set beforeSnapshot = CaptureVariableDefinitionSnapshot()

    If beforeSnapshot Is Nothing Then
        RecordResult False, _
            "I05-02 VariableDefinition Before snapshot", _
            passCount, failCount
        GoTo Finalize
    End If

    RecordResult True, _
        "I05-02 VariableDefinition Before snapshot", _
        passCount, failCount

    Debug.Print _
        "Before Snapshot: Rows=" & CStr(beforeSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
        "; Columns=" & CStr(beforeSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    ' --------------------------------------------------------
    ' Fixture setup:
    ' Status -> Status_TEST_BROKEN
    ' --------------------------------------------------------
    statusColumn.Name = COLUMN_VARIABLE_STATUS_BROKEN
    fixtureChanged = True

    RecordResult _
        VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS_BROKEN), _
        "I05-03 Broken Status column applied", _
        passCount, failCount

    If Not VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS_BROKEN) Then
        GoTo RestoreFixture
    End If

    RecordResult _
        Not VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS), _
        "I05-04 Original Status column unavailable", _
        passCount, failCount

    If VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS) Then
        GoTo RestoreFixture
    End If

    ' --------------------------------------------------------
    ' Safety check:
    ' Confirm directly that this fixture actually causes
    ' GetAllVariableDefinitions to fail BEFORE calling ExecuteManualSync.
    ' If the read unexpectedly succeeds, do not allow a normal sync to run.
    ' --------------------------------------------------------
    Set directDefinitions = Nothing
    Set definitionReadResult = _
        GetAllVariableDefinitions(directDefinitions)

    RecordResult Not definitionReadResult Is Nothing, _
        "I05-05 Direct definition read returns COperationResult", _
        passCount, failCount

    If definitionReadResult Is Nothing Then
        Debug.Print _
            "ABORT: Definition read returned Nothing; Manual Sync not executed."
        aborted = True
        GoTo RestoreFixture
    End If

    PrintOperationResultI03 _
        "Direct GetAllVariableDefinitions", _
        definitionReadResult

    RecordResult Not definitionReadResult.Success, _
        "I05-06 Direct GetAllVariableDefinitions = Failure", _
        passCount, failCount

    If definitionReadResult.Success Then
        Debug.Print _
            "ABORT: Broken Status fixture did not cause Definition Read Failure."
        Debug.Print _
            "ExecuteManualSync was not called to avoid unintended persistence."
        aborted = True
        GoTo RestoreFixture
    End If

    Dim failedReadCarrierValid As Boolean

    failedReadCarrierValid = False

    If Not directDefinitions Is Nothing Then
        failedReadCarrierValid = (directDefinitions.Count = 0)
    End If

    RecordResult failedReadCarrierValid, _
        "I05-07 Failed definition read returns initialized empty collection", _
        passCount, failCount

    ' --------------------------------------------------------
    ' Production entry point under test.
    ' --------------------------------------------------------
    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    Set afterSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not result Is Nothing, _
        "I05-08 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not result Is Nothing Then
        PrintOperationResultI03 "ExecuteManualSync", result

        RecordResult Not result.Success, _
            "I05-09 ExecuteManualSync = Failure", _
            passCount, failCount
    Else
        RecordResult False, _
            "I05-09 ExecuteManualSync = Failure", _
            passCount, failCount
    End If

    ' --------------------------------------------------------
    ' Template Scan must have completed successfully before the
    ' VariableDefinition read failure occurs.
    ' --------------------------------------------------------
    RecordResult Not templateScanResult Is Nothing, _
        "I05-10 templateScanResult = Published", _
        passCount, failCount

    If Not templateScanResult Is Nothing Then
        RecordResult IsDictionaryI03(templateScanResult), _
            "I05-11 templateScanResult is Dictionary", _
            passCount, failCount

        If IsDictionaryI03(templateScanResult) Then
            RecordResult _
                Not HasInvalidCandidates(templateScanResult), _
                "I05-12 InvalidCandidates.Count = 0", _
                passCount, failCount
        Else
            RecordResult False, _
                "I05-12 InvalidCandidates.Count = 0", _
                passCount, failCount
        End If
    Else
        RecordResult False, _
            "I05-11 templateScanResult is Dictionary", _
            passCount, failCount

        RecordResult False, _
            "I05-12 InvalidCandidates.Count = 0", _
            passCount, failCount
    End If

    ' BuildSyncDiff and ApplySyncDiff are downstream of successful
    ' GetAllVariableDefinitions. syncDiffResult therefore must remain Nothing.
    RecordResult (syncDiffResult Is Nothing), _
        "I05-13 syncDiffResult = Nothing", _
        passCount, failCount

    RecordResult Not afterSnapshot Is Nothing, _
        "I05-14 VariableDefinition After snapshot", _
        passCount, failCount

    If Not afterSnapshot Is Nothing Then
        Debug.Print _
            "After Snapshot: Rows=" & CStr(afterSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
            "; Columns=" & CStr(afterSnapshot.Item(SNAPSHOT_COLUMN_COUNT))
    End If

    If beforeSnapshot Is Nothing Or afterSnapshot Is Nothing Then
        RecordResult False, _
            "I05-15 VariableDefinition Data Before = After", _
            passCount, failCount
    Else
        RecordResult _
            SnapshotsEqual(beforeSnapshot, afterSnapshot), _
            "I05-15 VariableDefinition Data Before = After", _
            passCount, failCount
    End If

RestoreFixture:
    ' --------------------------------------------------------
    ' Restore Status column before final result.
    ' This path also executes after any expected verification failure
    ' following fixture setup.
    ' --------------------------------------------------------
    If fixtureChanged Then
        On Error GoTo RestorationError

        statusColumn.Name = originalStatusName
        fixtureChanged = False

        restorationSucceeded = _
            VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS)

        If restorationSucceeded Then
            If VariableDefinitionColumnExists(COLUMN_VARIABLE_STATUS_BROKEN) Then
                restorationSucceeded = False
            End If
        End If

        RecordResult restorationSucceeded, _
            "I05-16 Status column restored", _
            passCount, failCount

        If restorationSucceeded Then
            Debug.Print _
                "Restored Column Name = " & COLUMN_VARIABLE_STATUS
        Else
            Debug.Print _
                "WARNING: Status column restoration verification failed."
        End If
    Else
        restorationSucceeded = True
    End If

Finalize:
    ' Last-chance restore after unexpected runtime errors.
    If fixtureChanged Then
        On Error Resume Next
        statusColumn.Name = originalStatusName
        fixtureChanged = False
        Err.Clear
        On Error GoTo 0

        Debug.Print _
            "Last-chance Status column restore executed."
    End If

    Debug.Print String$(72, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "I05 safety preflight stopped ExecuteManualSync or final verification."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print String$(72, "=")

    Set statusColumn = Nothing
    Set afterSnapshot = Nothing
    Set beforeSnapshot = Nothing
    Set directDefinitions = Nothing
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set definitionReadResult = Nothing
    Set result = Nothing
    Exit Sub

RestorationError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  I05-16 Status column restore runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize

UnexpectedError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize
End Sub

Private Function VerifyNormalTemplateReady() As Boolean

    Dim stepResult As COperationResult
    Dim cleanupResult As COperationResult
    Dim scanResult As Object

    Dim templatePath As String
    Dim resolvedTemplatePath As String
    Dim subjectText As String
    Dim bodyText As String
    Dim matchedPath As String
    Dim mailCreated As Boolean

    VerifyNormalTemplateReady = False

    On Error GoTo UnexpectedError

    Debug.Print "I05 Normal Template Preflight:"

    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If Not RequireSuccess( _
        "  GetSettingValue", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedTemplatePath)

    If Not RequireSuccess( _
        "  ResolveWorkbookRelativePath", _
        stepResult) Then
        GoTo CleanUp
    End If

    Debug.Print _
        "  Resolved Template Path = " & resolvedTemplatePath

    matchedPath = Dir$( _
        resolvedTemplatePath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

    If Len(matchedPath) = 0 Then
        Debug.Print _
            "  ABORT: Current OFT does not exist."
        GoTo CleanUp
    End If

    Set stepResult = CreateMailFromTemplate(resolvedTemplatePath)

    If Not RequireSuccess( _
        "  CreateMailFromTemplate", _
        stepResult) Then
        GoTo CleanUp
    End If

    mailCreated = True

    Set stepResult = ReadSubject(subjectText)

    If Not RequireSuccess( _
        "  ReadSubject", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "  ReadBodyText", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If Not RequireSuccess( _
        "  ScanTemplate", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set cleanupResult = CloseWithoutSave()

    If Not RequireSuccess( _
        "  CloseWithoutSave", _
        cleanupResult) Then
        GoTo CleanUp
    End If

    mailCreated = False

    If scanResult Is Nothing Then
        Debug.Print _
            "  ABORT: ScanTemplate returned no result carrier."
        GoTo CleanUp
    End If

    If Not IsDictionaryI03(scanResult) Then
        Debug.Print _
            "  ABORT: ScanTemplate carrier is not a Dictionary."
        GoTo CleanUp
    End If

    If HasInvalidCandidates(scanResult) Then
        Debug.Print _
            "  ABORT: Current OFT contains InvalidCandidates."
        PrintInvalidCandidates scanResult
        GoTo CleanUp
    End If

    Debug.Print "  InvalidCandidates.Count = 0 = PASS"

    VerifyNormalTemplateReady = True

CleanUp:
    If mailCreated Then
        Set cleanupResult = CloseWithoutSave()

        If cleanupResult Is Nothing Then
            Debug.Print _
                "  WARNING: Preflight cleanup returned Nothing."
        ElseIf Not cleanupResult.Success Then
            Debug.Print _
                "  WARNING: Preflight cleanup returned Failure."
            PrintOperationResultI03 _
                "  Preflight CloseWithoutSave", _
                cleanupResult
        End If
    End If

    Set scanResult = Nothing
    Set cleanupResult = Nothing
    Set stepResult = Nothing
    Exit Function

UnexpectedError:
    Debug.Print _
        "  ABORT: Unexpected normal-template preflight error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function FindVariableDefinitionColumn( _
    ByVal columnName As String _
) As ListColumn

    Dim worksheetValue As Worksheet
    Dim tableValue As ListObject
    Dim columnValue As ListColumn

    Set FindVariableDefinitionColumn = Nothing

    On Error GoTo LookupError

    Set worksheetValue = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set tableValue = _
        worksheetValue.ListObjects(TABLE_VARIABLE_DEFINITION)

    For Each columnValue In tableValue.ListColumns
        If StrComp( _
            columnValue.Name, _
            columnName, _
            vbTextCompare) = 0 Then

            Set FindVariableDefinitionColumn = columnValue
            GoTo CleanUp
        End If
    Next columnValue

CleanUp:
    Set columnValue = Nothing
    Set tableValue = Nothing
    Set worksheetValue = Nothing
    Exit Function

LookupError:
    Debug.Print _
        "VariableDefinition column lookup error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function VariableDefinitionColumnExists( _
    ByVal columnName As String _
) As Boolean

    Dim columnValue As ListColumn

    Set columnValue = FindVariableDefinitionColumn(columnName)

    VariableDefinitionColumnExists = _
        Not columnValue Is Nothing

    Set columnValue = Nothing
End Function


Public Sub TestP204I06BuildSyncDiffFailure()

    Dim result As COperationResult
    Dim definitionReadResult As COperationResult
    Dim directBuildResult As COperationResult

    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim directTemplateScanResult As Object
    Dim directSyncDiffResult As Object
    Dim currentDefinitions As Collection

    Dim originalSnapshot As Object
    Dim fixtureSnapshot As Object
    Dim afterExecutionSnapshot As Object
    Dim restoredSnapshot As Object

    Dim statusCell As Range
    Dim originalStatusValue As Variant
    Dim originalStatusFormula As Variant
    Dim originalHadFormula As Boolean

    Dim directSyncTimestamp As Date

    Dim fixtureChanged As Boolean
    Dim restorationSucceeded As Boolean
    Dim passCount As Long
    Dim failCount As Long
    Dim aborted As Boolean

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Remaining Verification - I06 BuildSyncDiff Failure"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Preflight 1:
    ' Current OFT must be a normal valid template.
    ' --------------------------------------------------------
    If Not VerifyNormalTemplateReady() Then
        Debug.Print _
            "ABORT: Current OFT did not pass the normal-template preflight."
        aborted = True
        GoTo Finalize
    End If

    RecordResult True, _
        "I06-00 Normal template preflight", _
        passCount, failCount

    ' --------------------------------------------------------
    ' Preflight 2:
    ' Locate ModelName.Status and preserve its exact original cell state.
    ' --------------------------------------------------------
    Set statusCell = FindVariableDefinitionDataCell( _
        I06_TARGET_VARIABLE, _
        COLUMN_VARIABLE_STATUS)

    If statusCell Is Nothing Then
        Debug.Print _
            "ABORT: Could not locate " & _
            I06_TARGET_VARIABLE & "." & COLUMN_VARIABLE_STATUS & "."
        aborted = True
        GoTo Finalize
    End If

    originalHadFormula = statusCell.HasFormula
    originalStatusValue = statusCell.Value2
    originalStatusFormula = statusCell.Formula

    Debug.Print _
        "Original " & I06_TARGET_VARIABLE & ".Status = " & _
        CStr(originalStatusValue)

    RecordResult _
        (Len(Trim$(CStr(originalStatusValue))) > 0), _
        "I06-01 Target Status cell preflight", _
        passCount, failCount

    If Len(Trim$(CStr(originalStatusValue))) = 0 Then
        GoTo Finalize
    End If

    Set originalSnapshot = CaptureVariableDefinitionSnapshot()

    If originalSnapshot Is Nothing Then
        RecordResult False, _
            "I06-02 Original VariableDefinition snapshot", _
            passCount, failCount
        GoTo Finalize
    End If

    RecordResult True, _
        "I06-02 Original VariableDefinition snapshot", _
        passCount, failCount

    Debug.Print _
        "Original Snapshot: Rows=" & _
        CStr(originalSnapshot.Item(SNAPSHOT_ROW_COUNT)) & _
        "; Columns=" & _
        CStr(originalSnapshot.Item(SNAPSHOT_COLUMN_COUNT))

    ' --------------------------------------------------------
    ' Fixture setup:
    ' ModelName.Status -> InvalidStatus
    ' --------------------------------------------------------
    statusCell.Value2 = I06_INVALID_STATUS
    fixtureChanged = True

    RecordResult _
        (StrComp( _
            CStr(statusCell.Value2), _
            I06_INVALID_STATUS, _
            vbBinaryCompare) = 0), _
        "I06-03 Invalid Status fixture applied", _
        passCount, failCount

    If StrComp( _
        CStr(statusCell.Value2), _
        I06_INVALID_STATUS, _
        vbBinaryCompare) <> 0 Then

        GoTo RestoreFixture
    End If

    Set fixtureSnapshot = CaptureVariableDefinitionSnapshot()

    If fixtureSnapshot Is Nothing Then
        RecordResult False, _
            "I06-04 Fixture VariableDefinition snapshot", _
            passCount, failCount
        GoTo RestoreFixture
    End If

    RecordResult True, _
        "I06-04 Fixture VariableDefinition snapshot", _
        passCount, failCount

    ' --------------------------------------------------------
    ' Safety check 1:
    ' Definition Read must succeed and carry InvalidStatus.
    ' This proves the failure boundary is downstream in BuildSyncDiff.
    ' --------------------------------------------------------
    Set currentDefinitions = Nothing
    Set definitionReadResult = _
        GetAllVariableDefinitions(currentDefinitions)

    RecordResult Not definitionReadResult Is Nothing, _
        "I06-05 Definition read returns COperationResult", _
        passCount, failCount

    If definitionReadResult Is Nothing Then
        Debug.Print _
            "ABORT: Definition read returned Nothing."
        aborted = True
        GoTo RestoreFixture
    End If

    PrintOperationResultI03 _
        "Direct GetAllVariableDefinitions", _
        definitionReadResult

    RecordResult definitionReadResult.Success, _
        "I06-06 GetAllVariableDefinitions = Success", _
        passCount, failCount

    If Not definitionReadResult.Success Then
        Debug.Print _
            "ABORT: I06 requires Definition Read Success."
        aborted = True
        GoTo RestoreFixture
    End If

    RecordResult _
        CollectionHasVariableStatus( _
            currentDefinitions, _
            I06_TARGET_VARIABLE, _
            I06_INVALID_STATUS), _
        "I06-07 Definition carrier contains ModelName / InvalidStatus", _
        passCount, failCount

    If Not CollectionHasVariableStatus( _
        currentDefinitions, _
        I06_TARGET_VARIABLE, _
        I06_INVALID_STATUS) Then

        Debug.Print _
            "ABORT: InvalidStatus did not propagate into the Definition carrier."
        aborted = True
        GoTo RestoreFixture
    End If

    ' --------------------------------------------------------
    ' Safety check 2:
    ' Obtain a valid current TemplateScanResult independently and call
    ' BuildSyncDiff directly. Manual Sync is allowed only after direct Build
    ' has proven that this fixture fails at the intended boundary.
    ' --------------------------------------------------------
    If Not GetNormalTemplateScanResultForVerification( _
        directTemplateScanResult) Then

        Debug.Print _
            "ABORT: Unable to obtain direct TemplateScanResult."
        aborted = True
        GoTo RestoreFixture
    End If

    RecordResult Not directTemplateScanResult Is Nothing, _
        "I06-08 Direct TemplateScanResult obtained", _
        passCount, failCount

    If directTemplateScanResult Is Nothing Then
        aborted = True
        GoTo RestoreFixture
    End If

    directSyncTimestamp = Now
    Debug.Print _
        "Direct Build SyncTimestamp = " & _
        Format$(directSyncTimestamp, "yyyy-mm-dd hh:nn:ss")

    Set directSyncDiffResult = Nothing

    Set directBuildResult = BuildSyncDiff( _
        directTemplateScanResult, _
        currentDefinitions, _
        directSyncTimestamp, _
        directSyncDiffResult)

    RecordResult Not directBuildResult Is Nothing, _
        "I06-09 Direct BuildSyncDiff returns COperationResult", _
        passCount, failCount

    If directBuildResult Is Nothing Then
        Debug.Print _
            "ABORT: Direct BuildSyncDiff returned Nothing."
        aborted = True
        GoTo RestoreFixture
    End If

    PrintOperationResultI03 _
        "Direct BuildSyncDiff", _
        directBuildResult

    RecordResult Not directBuildResult.Success, _
        "I06-10 Direct BuildSyncDiff = Failure", _
        passCount, failCount

    If directBuildResult.Success Then
        Debug.Print _
            "ABORT: InvalidStatus fixture did not cause BuildSyncDiff Failure."
        Debug.Print _
            "ExecuteManualSync was not called to avoid unintended persistence."
        aborted = True
        GoTo RestoreFixture
    End If

    ' --------------------------------------------------------
    ' Production entry point under test.
    ' --------------------------------------------------------
    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    Set afterExecutionSnapshot = CaptureVariableDefinitionSnapshot()

    RecordResult Not result Is Nothing, _
        "I06-11 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If Not result Is Nothing Then
        PrintOperationResultI03 "ExecuteManualSync", result

        RecordResult Not result.Success, _
            "I06-12 ExecuteManualSync = Failure", _
            passCount, failCount
    Else
        RecordResult False, _
            "I06-12 ExecuteManualSync = Failure", _
            passCount, failCount
    End If

    ' Scan must complete successfully before BuildSyncDiff fails.
    RecordResult Not templateScanResult Is Nothing, _
        "I06-13 templateScanResult = Published", _
        passCount, failCount

    If Not templateScanResult Is Nothing Then
        RecordResult IsDictionaryI03(templateScanResult), _
            "I06-14 templateScanResult is Dictionary", _
            passCount, failCount

        If IsDictionaryI03(templateScanResult) Then
            RecordResult _
                Not HasInvalidCandidates(templateScanResult), _
                "I06-15 InvalidCandidates.Count = 0", _
                passCount, failCount
        Else
            RecordResult False, _
                "I06-15 InvalidCandidates.Count = 0", _
                passCount, failCount
        End If
    Else
        RecordResult False, _
            "I06-14 templateScanResult is Dictionary", _
            passCount, failCount

        RecordResult False, _
            "I06-15 InvalidCandidates.Count = 0", _
            passCount, failCount
    End If

    ' Build failure must prevent persistence result publication.
    RecordResult (syncDiffResult Is Nothing), _
        "I06-16 syncDiffResult = Nothing", _
        passCount, failCount

    RecordResult Not afterExecutionSnapshot Is Nothing, _
        "I06-17 Post-execution VariableDefinition snapshot", _
        passCount, failCount

    If fixtureSnapshot Is Nothing Or _
       afterExecutionSnapshot Is Nothing Then

        RecordResult False, _
            "I06-18 Fixture State = Post-execution State", _
            passCount, failCount
    Else
        RecordResult _
            SnapshotsEqual( _
                fixtureSnapshot, _
                afterExecutionSnapshot), _
            "I06-18 Fixture State = Post-execution State", _
            passCount, failCount
    End If

RestoreFixture:
    ' --------------------------------------------------------
    ' Restore the exact original Status cell.
    ' --------------------------------------------------------
    If fixtureChanged Then
        On Error GoTo RestorationError

        If originalHadFormula Then
            statusCell.Formula = originalStatusFormula
        Else
            statusCell.Value2 = originalStatusValue
        End If

        fixtureChanged = False

        restorationSucceeded = _
            (StrComp( _
                CStr(statusCell.Value2), _
                CStr(originalStatusValue), _
                vbBinaryCompare) = 0)

        RecordResult restorationSucceeded, _
            "I06-19 ModelName.Status restored", _
            passCount, failCount

        If restorationSucceeded Then
            Debug.Print _
                "Restored " & I06_TARGET_VARIABLE & ".Status = " & _
                CStr(statusCell.Value2)
        Else
            Debug.Print _
                "WARNING: ModelName.Status restoration verification failed."
        End If

        Set restoredSnapshot = CaptureVariableDefinitionSnapshot()

        RecordResult Not restoredSnapshot Is Nothing, _
            "I06-20 Restored VariableDefinition snapshot", _
            passCount, failCount

        If originalSnapshot Is Nothing Or restoredSnapshot Is Nothing Then
            RecordResult False, _
                "I06-21 Original State = Restored State", _
                passCount, failCount
        Else
            RecordResult _
                SnapshotsEqual( _
                    originalSnapshot, _
                    restoredSnapshot), _
                "I06-21 Original State = Restored State", _
                passCount, failCount
        End If
    Else
        restorationSucceeded = True
    End If

Finalize:
    ' Last-chance restore after an unexpected runtime error.
    If fixtureChanged Then
        On Error Resume Next

        If originalHadFormula Then
            statusCell.Formula = originalStatusFormula
        Else
            statusCell.Value2 = originalStatusValue
        End If

        fixtureChanged = False
        Err.Clear
        On Error GoTo 0

        Debug.Print _
            "Last-chance ModelName.Status restore executed."
    End If

    Debug.Print String$(72, "-")

    If aborted Then
        Debug.Print "RESULT = ABORTED"
        Debug.Print _
            "I06 safety preflight stopped ExecuteManualSync or final verification."
    Else
        Debug.Print "PASS Count = " & CStr(passCount)
        Debug.Print "FAIL Count = " & CStr(failCount)

        If failCount = 0 Then
            Debug.Print "Overall = PASS"
        Else
            Debug.Print "Overall = FAIL"
        End If
    End If

    Debug.Print String$(72, "=")

    Set restoredSnapshot = Nothing
    Set afterExecutionSnapshot = Nothing
    Set fixtureSnapshot = Nothing
    Set originalSnapshot = Nothing

    Set statusCell = Nothing

    Set currentDefinitions = Nothing
    Set directSyncDiffResult = Nothing
    Set directTemplateScanResult = Nothing

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing

    Set directBuildResult = Nothing
    Set definitionReadResult = Nothing
    Set result = Nothing
    Exit Sub

RestorationError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  I06-19 ModelName.Status restore runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize

UnexpectedError:
    failCount = failCount + 1

    Debug.Print _
        "FAIL  Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume Finalize
End Sub

Private Function FindVariableDefinitionDataCell( _
    ByVal variableName As String, _
    ByVal columnName As String _
) As Range

    Dim worksheetValue As Worksheet
    Dim tableValue As ListObject
    Dim variableColumn As ListColumn
    Dim targetColumn As ListColumn

    Dim rowIndex As Long
    Dim currentVariableName As Variant

    Set FindVariableDefinitionDataCell = Nothing

    On Error GoTo LookupError

    Set worksheetValue = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set tableValue = _
        worksheetValue.ListObjects(TABLE_VARIABLE_DEFINITION)

    Set variableColumn = _
        tableValue.ListColumns(COLUMN_VARIABLE_NAME)

    Set targetColumn = _
        tableValue.ListColumns(columnName)

    If variableColumn.DataBodyRange Is Nothing Then
        GoTo CleanUp
    End If

    For rowIndex = 1 To variableColumn.DataBodyRange.Rows.Count

        currentVariableName = _
            variableColumn.DataBodyRange.Cells(rowIndex, 1).Value2

        If StrComp( _
            Trim$(CStr(currentVariableName)), _
            variableName, _
            vbTextCompare) = 0 Then

            Set FindVariableDefinitionDataCell = _
                targetColumn.DataBodyRange.Cells(rowIndex, 1)

            GoTo CleanUp
        End If
    Next rowIndex

CleanUp:
    Set targetColumn = Nothing
    Set variableColumn = Nothing
    Set tableValue = Nothing
    Set worksheetValue = Nothing
    Exit Function

LookupError:
    Debug.Print _
        "VariableDefinition data-cell lookup error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function CollectionHasVariableStatus( _
    ByVal definitions As Collection, _
    ByVal variableName As String, _
    ByVal expectedStatus As String _
) As Boolean

    Dim item As Variant
    Dim itemObject As Object

    CollectionHasVariableStatus = False

    If definitions Is Nothing Then Exit Function

    On Error GoTo InspectError

    For Each item In definitions

        If IsObject(item) Then
            Set itemObject = item

            If IsDictionaryI03(itemObject) Then

                If itemObject.Exists(FIELD_VARIABLE_NAME) And _
                   itemObject.Exists(COLUMN_VARIABLE_STATUS) Then

                    If StrComp( _
                        CStr(itemObject.Item(FIELD_VARIABLE_NAME)), _
                        variableName, _
                        vbTextCompare) = 0 Then

                        CollectionHasVariableStatus = _
                            (StrComp( _
                                CStr(itemObject.Item(COLUMN_VARIABLE_STATUS)), _
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
    CollectionHasVariableStatus = False
    Resume CleanUp
End Function

Private Function GetNormalTemplateScanResultForVerification( _
    ByRef scanResult As Object _
) As Boolean

    Dim stepResult As COperationResult
    Dim cleanupResult As COperationResult

    Dim templatePath As String
    Dim resolvedTemplatePath As String
    Dim subjectText As String
    Dim bodyText As String
    Dim matchedPath As String

    Dim mailCreated As Boolean

    Set scanResult = Nothing
    GetNormalTemplateScanResultForVerification = False

    On Error GoTo UnexpectedError

    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    Set stepResult = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedTemplatePath)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    matchedPath = Dir$( _
        resolvedTemplatePath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

    If Len(matchedPath) = 0 Then GoTo CleanUp

    Set stepResult = CreateMailFromTemplate(resolvedTemplatePath)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    mailCreated = True

    Set stepResult = ReadSubject(subjectText)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    Set stepResult = ReadBodyText(bodyText)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    Set stepResult = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If stepResult Is Nothing Then GoTo CleanUp
    If Not stepResult.Success Then GoTo CleanUp

    Set cleanupResult = CloseWithoutSave()

    If cleanupResult Is Nothing Then GoTo CleanUp
    If Not cleanupResult.Success Then GoTo CleanUp

    mailCreated = False

    If scanResult Is Nothing Then GoTo CleanUp
    If Not IsDictionaryI03(scanResult) Then GoTo CleanUp
    If HasInvalidCandidates(scanResult) Then GoTo CleanUp

    GetNormalTemplateScanResultForVerification = True

CleanUp:
    If mailCreated Then
        Set cleanupResult = CloseWithoutSave()
    End If

    Set cleanupResult = Nothing
    Set stepResult = Nothing
    Exit Function

UnexpectedError:
    Debug.Print _
        "Direct TemplateScanResult acquisition error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function VerifyI03FixtureReady() As Boolean

    Dim stepResult As COperationResult
    Dim cleanupResult As COperationResult
    Dim scanResult As Object

    Dim templatePath As String
    Dim resolvedTemplatePath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim matchedPath As String
    Dim mailCreated As Boolean

    VerifyI03FixtureReady = False

    On Error GoTo UnexpectedError

    Debug.Print "I03 Fixture Preflight:"

    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If Not RequireSuccess( _
        "  GetSettingValue", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedTemplatePath)

    If Not RequireSuccess( _
        "  ResolveWorkbookRelativePath", _
        stepResult) Then
        GoTo CleanUp
    End If

    Debug.Print "  Resolved Template Path = " & resolvedTemplatePath

    matchedPath = Dir$( _
        resolvedTemplatePath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

    If Len(matchedPath) = 0 Then
        Debug.Print "  ABORT: Current OFT does not exist."
        GoTo CleanUp
    End If

    Set stepResult = CreateMailFromTemplate(resolvedTemplatePath)

    If Not RequireSuccess( _
        "  CreateMailFromTemplate", _
        stepResult) Then
        GoTo CleanUp
    End If

    mailCreated = True

    Set stepResult = ReadSubject(subjectText)

    If Not RequireSuccess( _
        "  ReadSubject", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "  ReadBodyText", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set stepResult = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If Not RequireSuccess( _
        "  ScanTemplate", _
        stepResult) Then
        GoTo CleanUp
    End If

    Set cleanupResult = CloseWithoutSave()

    If Not RequireSuccess( _
        "  CloseWithoutSave", _
        cleanupResult) Then
        GoTo CleanUp
    End If

    mailCreated = False

    If scanResult Is Nothing Then
        Debug.Print "  ABORT: ScanTemplate returned no carrier."
        GoTo CleanUp
    End If

    If Not IsDictionaryI03(scanResult) Then
        Debug.Print _
            "  ABORT: ScanTemplate carrier is not a Scripting.Dictionary."
        GoTo CleanUp
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Debug.Print _
            "  ABORT: ScanTemplate carrier has no InvalidCandidates key."
        GoTo CleanUp
    End If

    If Not HasInvalidCandidates(scanResult) Then
        Debug.Print _
            "  ABORT: InvalidCandidates.Count = 0."
        Debug.Print _
            "  Prepare the OFT with an invalid token such as {{1stGate}}."
        GoTo CleanUp
    End If

    Debug.Print "  InvalidCandidates.Count > 0 = PASS"
    PrintInvalidCandidates scanResult

    VerifyI03FixtureReady = True

CleanUp:
    If mailCreated Then
        Set cleanupResult = CloseWithoutSave()

        If cleanupResult Is Nothing Then
            Debug.Print _
                "  WARNING: Preflight cleanup returned Nothing."
        ElseIf Not cleanupResult.Success Then
            Debug.Print _
                "  WARNING: Preflight cleanup returned Failure."
            PrintOperationResultI03 _
                "  Preflight CloseWithoutSave", _
                cleanupResult
        End If
    End If

    Set scanResult = Nothing
    Set cleanupResult = Nothing
    Set stepResult = Nothing
    Exit Function

UnexpectedError:
    Debug.Print _
        "  ABORT: Unexpected preflight error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Function

Private Function CaptureVariableDefinitionSnapshot() As Object

    Dim worksheetValue As Worksheet
    Dim tableValue As ListObject
    Dim snapshot As Object
    Dim values As Variant

    On Error GoTo SnapshotError

    Set worksheetValue = _
        ThisWorkbook.Worksheets(SHEET_VARIABLE_DEFINITION)

    Set tableValue = _
        worksheetValue.ListObjects(TABLE_VARIABLE_DEFINITION)

    Set snapshot = CreateObject("Scripting.Dictionary")
    snapshot.CompareMode = vbTextCompare

    snapshot.Add SNAPSHOT_COLUMN_COUNT, tableValue.ListColumns.Count

    If tableValue.DataBodyRange Is Nothing Then
        snapshot.Add SNAPSHOT_HAS_DATA, False
        snapshot.Add SNAPSHOT_ROW_COUNT, 0
        snapshot.Add SNAPSHOT_VALUES, Empty
    Else
        snapshot.Add SNAPSHOT_HAS_DATA, True
        snapshot.Add SNAPSHOT_ROW_COUNT, tableValue.ListRows.Count

        values = tableValue.DataBodyRange.Value2
        snapshot.Add SNAPSHOT_VALUES, values
    End If

    Set CaptureVariableDefinitionSnapshot = snapshot

CleanUp:
    Set snapshot = Nothing
    Set tableValue = Nothing
    Set worksheetValue = Nothing
    Exit Function

SnapshotError:
    Debug.Print _
        "Snapshot error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Set CaptureVariableDefinitionSnapshot = Nothing
    Resume CleanUp
End Function

Private Function SnapshotsEqual( _
    ByVal beforeSnapshot As Object, _
    ByVal afterSnapshot As Object _
) As Boolean

    Dim beforeValues As Variant
    Dim afterValues As Variant

    Dim rowIndex As Long
    Dim columnIndex As Long

    SnapshotsEqual = False

    On Error GoTo CompareError

    If beforeSnapshot Is Nothing Then Exit Function
    If afterSnapshot Is Nothing Then Exit Function

    If CLng(beforeSnapshot.Item(SNAPSHOT_COLUMN_COUNT)) <> _
       CLng(afterSnapshot.Item(SNAPSHOT_COLUMN_COUNT)) Then
        Exit Function
    End If

    If CLng(beforeSnapshot.Item(SNAPSHOT_ROW_COUNT)) <> _
       CLng(afterSnapshot.Item(SNAPSHOT_ROW_COUNT)) Then
        Exit Function
    End If

    If CBool(beforeSnapshot.Item(SNAPSHOT_HAS_DATA)) <> _
       CBool(afterSnapshot.Item(SNAPSHOT_HAS_DATA)) Then
        Exit Function
    End If

    If Not CBool(beforeSnapshot.Item(SNAPSHOT_HAS_DATA)) Then
        SnapshotsEqual = True
        Exit Function
    End If

    beforeValues = beforeSnapshot.Item(SNAPSHOT_VALUES)
    afterValues = afterSnapshot.Item(SNAPSHOT_VALUES)

    If IsArray(beforeValues) <> IsArray(afterValues) Then
        Exit Function
    End If

    If Not IsArray(beforeValues) Then
        SnapshotsEqual = _
            CellValuesEqual(beforeValues, afterValues)
        Exit Function
    End If

    If LBound(beforeValues, 1) <> LBound(afterValues, 1) Then Exit Function
    If UBound(beforeValues, 1) <> UBound(afterValues, 1) Then Exit Function
    If LBound(beforeValues, 2) <> LBound(afterValues, 2) Then Exit Function
    If UBound(beforeValues, 2) <> UBound(afterValues, 2) Then Exit Function

    For rowIndex = LBound(beforeValues, 1) To UBound(beforeValues, 1)
        For columnIndex = _
            LBound(beforeValues, 2) To UBound(beforeValues, 2)

            If Not CellValuesEqual( _
                beforeValues(rowIndex, columnIndex), _
                afterValues(rowIndex, columnIndex)) Then
                Exit Function
            End If
        Next columnIndex
    Next rowIndex

    SnapshotsEqual = True
    Exit Function

CompareError:
    Debug.Print _
        "Snapshot comparison error: " & _
        CStr(Err.Number) & " - " & Err.Description
    SnapshotsEqual = False
End Function

Private Function CellValuesEqual( _
    ByVal beforeValue As Variant, _
    ByVal afterValue As Variant _
) As Boolean

    CellValuesEqual = False

    If IsError(beforeValue) Or IsError(afterValue) Then
        If Not IsError(beforeValue) Then Exit Function
        If Not IsError(afterValue) Then Exit Function

        CellValuesEqual = _
            (CStr(beforeValue) = CStr(afterValue))
        Exit Function
    End If

    If IsNull(beforeValue) Or IsNull(afterValue) Then
        CellValuesEqual = _
            (IsNull(beforeValue) And IsNull(afterValue))
        Exit Function
    End If

    If IsEmpty(beforeValue) Or IsEmpty(afterValue) Then
        CellValuesEqual = _
            (IsEmpty(beforeValue) And IsEmpty(afterValue))
        Exit Function
    End If

    If VarType(beforeValue) <> VarType(afterValue) Then
        Exit Function
    End If

    CellValuesEqual = (beforeValue = afterValue)
End Function

Private Function HasInvalidCandidates( _
    ByVal scanResult As Object _
) As Boolean

    Dim invalidCandidates As Object

    HasInvalidCandidates = False

    If scanResult Is Nothing Then Exit Function
    If Not IsDictionaryI03(scanResult) Then Exit Function
    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then Exit Function

    If Not IsObject(scanResult.Item(KEY_INVALID_CANDIDATES)) Then
        Exit Function
    End If

    Set invalidCandidates = scanResult.Item(KEY_INVALID_CANDIDATES)

    On Error GoTo CountError

    HasInvalidCandidates = (invalidCandidates.Count > 0)

CleanUp:
    Set invalidCandidates = Nothing
    Exit Function

CountError:
    HasInvalidCandidates = False
    Resume CleanUp
End Function

Private Sub PrintInvalidCandidates( _
    ByVal scanResult As Object _
)

    Dim invalidCandidates As Object
    Dim value As Variant

    If Not HasInvalidCandidates(scanResult) Then Exit Sub

    Set invalidCandidates = scanResult.Item(KEY_INVALID_CANDIDATES)

    On Error GoTo PrintError

    Debug.Print _
        "  InvalidCandidates.Count = " & CStr(invalidCandidates.Count)

    For Each value In invalidCandidates
        If IsObject(value) Then
            If IsDictionaryI03(value) Then
                If value.Exists(FIELD_VARIABLE_NAME) Then
                    Debug.Print _
                        "  Invalid Candidate: " & _
                        CStr(value.Item(FIELD_VARIABLE_NAME))
                Else
                    Debug.Print _
                        "  Invalid Candidate: <Dictionary>"
                End If
            Else
                Debug.Print _
                    "  Invalid Candidate: <" & TypeName(value) & ">"
            End If
        Else
            Debug.Print _
                "  Invalid Candidate: " & CStr(value)
        End If
    Next value

CleanUp:
    Set invalidCandidates = Nothing
    Exit Sub

PrintError:
    Debug.Print "  Invalid Candidate: <unable to enumerate>"
    Resume CleanUp
End Sub

Private Function RequireSuccess( _
    ByVal stepName As String, _
    ByVal result As COperationResult _
) As Boolean

    RequireSuccess = False

    If result Is Nothing Then
        Debug.Print stepName & " = Nothing"
        Exit Function
    End If

    PrintOperationResultI03 stepName, result

    RequireSuccess = result.Success
End Function

Private Sub PrintOperationResultI03( _
    ByVal prefix As String, _
    ByVal operationResult As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    Debug.Print prefix & ":"

    If operationResult Is Nothing Then
        Debug.Print "  Result = Nothing"
        Exit Sub
    End If

    Debug.Print "  Success = " & CStr(operationResult.Success)

    On Error GoTo PrintError

    Set errors = operationResult.Errors

    If errors Is Nothing Then Exit Sub

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
    Debug.Print "  Error detail unavailable."
    Resume CleanUp
End Sub

Private Sub RecordResult( _
    ByVal passed As Boolean, _
    ByVal testName As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If passed Then
        passCount = passCount + 1
        Debug.Print "PASS  " & testName
    Else
        failCount = failCount + 1
        Debug.Print "FAIL  " & testName
    End If
End Sub

Private Function IsDictionaryI03( _
    ByVal value As Object _
) As Boolean

    If value Is Nothing Then
        IsDictionaryI03 = False
        Exit Function
    End If

    IsDictionaryI03 = _
        (StrComp(TypeName(value), "Dictionary", vbTextCompare) = 0)
End Function
