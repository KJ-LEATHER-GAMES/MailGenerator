Attribute VB_Name = "modP2_04RemainingVerification"
Option Explicit

' P2-04 Manual Sync Integration - Remaining Verification Harness
'
' Current scope:
' - I03 Invalid Candidate
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

Private Const SHEET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TABLE_VARIABLE_DEFINITION As String = "tblVariableDefinition"

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
