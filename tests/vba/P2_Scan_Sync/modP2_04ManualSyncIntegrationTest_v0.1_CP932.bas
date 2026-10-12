Attribute VB_Name = "modP2_04ManualSyncIntegTest"
Option Explicit

' P2-04 Manual Sync Integration - Local Verification
'
' Production code is not modified by this test artifact.
'
' Entry points:
'   TestP204ManualSyncIntegrationNormal
'       Happy-path / result-contract / common SyncTimestamp verification.
'
'   RunP204ManualSyncDiagnostic
'       Diagnostic runner for manual negative / Warm / Cold variants.
'
' IMPORTANT:
' - This is Implementation Verification, not Formal MVP Test.
' - This module intentionally does not create test-only hooks in Production.
' - Negative test preconditions (invalid OFT, missing OFT, protected sheet, etc.)
'   are prepared outside this module and then verified through the public
'   ExecuteManualSync entry point.

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"
Private Const KEY_UNUSED As String = "Unused"

Private Const FIELD_VARIABLE_NAME As String = "VariableName"
Private Const FIELD_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const FIELD_LAST_DETECTED_AT As String = "LastDetectedAt"

Public Sub TestP204ManualSyncIntegrationNormal()

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Dim passCount As Long
    Dim failCount As Long
    Dim skipCount As Long

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Manual Sync Integration - Local Verification / Normal"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    CheckCondition Not result Is Nothing, _
        "I01-01 ExecuteManualSync returns COperationResult", _
        passCount, failCount

    If result Is Nothing Then
        GoTo Finalize
    End If

    PrintOperationResult "ExecuteManualSync", result

    CheckCondition result.Success, _
        "I01-02 ExecuteManualSync Success", _
        passCount, failCount

    If Not result.Success Then
        GoTo Finalize
    End If

    CheckCondition Not templateScanResult Is Nothing, _
        "I01-03 templateScanResult published on Success", _
        passCount, failCount

    If Not templateScanResult Is Nothing Then
        CheckCondition IsDictionary(templateScanResult), _
            "I01-04 templateScanResult is Dictionary", _
            passCount, failCount

        If IsDictionary(templateScanResult) Then
            CheckCondition templateScanResult.Exists(KEY_VALID_VARIABLES), _
                "I01-05 ValidVariables exists", _
                passCount, failCount

            CheckCondition templateScanResult.Exists(KEY_INVALID_CANDIDATES), _
                "I01-06 InvalidCandidates exists", _
                passCount, failCount

            CheckCondition templateScanResult.Exists(KEY_LOCATIONS), _
                "I01-07 Locations exists", _
                passCount, failCount

            If templateScanResult.Exists(KEY_INVALID_CANDIDATES) Then
                CheckCollectionCountEquals _
                    templateScanResult.Item(KEY_INVALID_CANDIDATES), _
                    0, _
                    "I01-08 InvalidCandidates.Count = 0", _
                    passCount, failCount
            End If
        End If
    End If

    CheckCondition Not syncDiffResult Is Nothing, _
        "I01-09 syncDiffResult published only after successful persistence", _
        passCount, failCount

    If Not syncDiffResult Is Nothing Then
        CheckCondition IsDictionary(syncDiffResult), _
            "I01-10 syncDiffResult is Dictionary", _
            passCount, failCount

        If IsDictionary(syncDiffResult) Then
            CheckCondition syncDiffResult.Exists(KEY_NEW), _
                "I01-11 New collection exists", _
                passCount, failCount

            CheckCondition syncDiffResult.Exists(KEY_EXISTING), _
                "I01-12 Existing collection exists", _
                passCount, failCount

            CheckCondition syncDiffResult.Exists(KEY_REACTIVATED), _
                "I01-13 Reactivated collection exists", _
                passCount, failCount

            CheckCondition syncDiffResult.Exists(KEY_UNUSED), _
                "I01-14 Unused collection exists", _
                passCount, failCount

            PrintSyncDiffCounts syncDiffResult

            VerifyCommonSyncTimestamp _
                syncDiffResult, _
                passCount, _
                failCount, _
                skipCount
        End If
    End If

Finalize:
    Debug.Print String$(72, "-")
    Debug.Print "PASS Count = " & CStr(passCount)
    Debug.Print "FAIL Count = " & CStr(failCount)
    Debug.Print "SKIP Count = " & CStr(skipCount)

    If failCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print String$(72, "=")

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing
    Exit Sub

UnexpectedError:
    failCount = failCount + 1
    Debug.Print "FAIL  Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume Finalize
End Sub

Public Sub RunP204ManualSyncDiagnostic()

    Dim result As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object

    Debug.Print String$(72, "=")
    Debug.Print "P2-04 Manual Sync Integration - Diagnostic Runner"
    Debug.Print String$(72, "=")

    On Error GoTo UnexpectedError

    Set result = ExecuteManualSync(syncDiffResult, templateScanResult)

    PrintOperationResult "ExecuteManualSync", result

    Debug.Print "templateScanResult Is Nothing = " & _
        CStr(templateScanResult Is Nothing)

    If Not templateScanResult Is Nothing Then
        PrintTemplateScanSummary templateScanResult
    End If

    Debug.Print "syncDiffResult Is Nothing = " & _
        CStr(syncDiffResult Is Nothing)

    If Not syncDiffResult Is Nothing Then
        PrintSyncDiffCounts syncDiffResult
    End If

CleanUp:
    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing
    Set result = Nothing
    Debug.Print String$(72, "=")
    Exit Sub

UnexpectedError:
    Debug.Print "Diagnostic runner runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description
    Resume CleanUp
End Sub

Private Sub VerifyCommonSyncTimestamp( _
    ByVal syncDiffResult As Object, _
    ByRef passCount As Long, _
    ByRef failCount As Long, _
    ByRef skipCount As Long _
)

    Dim hasTimestamp As Boolean
    Dim commonTimestamp As Date
    Dim allCommon As Boolean
    Dim newFirstLastMatch As Boolean

    allCommon = True
    newFirstLastMatch = True

    CheckTimestampCollection _
        syncDiffResult, _
        KEY_NEW, _
        True, _
        hasTimestamp, _
        commonTimestamp, _
        allCommon, _
        newFirstLastMatch

    CheckTimestampCollection _
        syncDiffResult, _
        KEY_EXISTING, _
        False, _
        hasTimestamp, _
        commonTimestamp, _
        allCommon, _
        newFirstLastMatch

    CheckTimestampCollection _
        syncDiffResult, _
        KEY_REACTIVATED, _
        False, _
        hasTimestamp, _
        commonTimestamp, _
        allCommon, _
        newFirstLastMatch

    If hasTimestamp Then
        CheckCondition allCommon, _
            "I02-01 New / Existing / Reactivated share one LastDetectedAt", _
            passCount, failCount

        CheckCondition newFirstLastMatch, _
            "I02-02 New FirstDetectedAt = LastDetectedAt", _
            passCount, failCount

        Debug.Print "Observed SyncTimestamp = " & _
            Format$(commonTimestamp, "yyyy-mm-dd hh:nn:ss")
    Else
        skipCount = skipCount + 1
        Debug.Print _
            "SKIP  I02 Common SyncTimestamp: no New / Existing / Reactivated item."
    End If
End Sub

Private Sub CheckTimestampCollection( _
    ByVal syncDiffResult As Object, _
    ByVal classificationKey As String, _
    ByVal checkFirstDetectedAt As Boolean, _
    ByRef hasTimestamp As Boolean, _
    ByRef commonTimestamp As Date, _
    ByRef allCommon As Boolean, _
    ByRef firstLastMatch As Boolean _
)

    Dim items As Collection
    Dim item As Variant
    Dim itemDictionary As Object
    Dim lastDetectedAt As Date
    Dim firstDetectedAt As Date

    If syncDiffResult Is Nothing Then Exit Sub
    If Not syncDiffResult.Exists(classificationKey) Then Exit Sub

    Set items = syncDiffResult.Item(classificationKey)

    If items Is Nothing Then Exit Sub

    For Each item In items
        If IsObject(item) Then
            Set itemDictionary = item

            If IsDictionary(itemDictionary) Then
                If itemDictionary.Exists(FIELD_LAST_DETECTED_AT) Then
                    If TryGetDate( _
                        itemDictionary.Item(FIELD_LAST_DETECTED_AT), _
                        lastDetectedAt) Then

                        If Not hasTimestamp Then
                            commonTimestamp = lastDetectedAt
                            hasTimestamp = True
                        ElseIf CDbl(commonTimestamp) <> CDbl(lastDetectedAt) Then
                            allCommon = False
                        End If
                    Else
                        allCommon = False
                    End If
                Else
                    allCommon = False
                End If

                If checkFirstDetectedAt Then
                    If itemDictionary.Exists(FIELD_FIRST_DETECTED_AT) Then
                        If TryGetDate( _
                            itemDictionary.Item(FIELD_FIRST_DETECTED_AT), _
                            firstDetectedAt) And _
                           TryGetDate( _
                            itemDictionary.Item(FIELD_LAST_DETECTED_AT), _
                            lastDetectedAt) Then

                            If CDbl(firstDetectedAt) <> CDbl(lastDetectedAt) Then
                                firstLastMatch = False
                            End If
                        Else
                            firstLastMatch = False
                        End If
                    Else
                        firstLastMatch = False
                    End If
                End If
            Else
                allCommon = False
            End If
        Else
            allCommon = False
        End If

        Set itemDictionary = Nothing
    Next item

    Set items = Nothing
End Sub

Private Sub PrintTemplateScanSummary( _
    ByVal templateScanResult As Object _
)

    If Not IsDictionary(templateScanResult) Then
        Debug.Print "TemplateScanResult Type = " & TypeName(templateScanResult)
        Exit Sub
    End If

    Debug.Print "TemplateScanResult:"
    PrintCarrierCount templateScanResult, KEY_VALID_VARIABLES
    PrintCarrierCount templateScanResult, KEY_INVALID_CANDIDATES
    PrintCarrierCount templateScanResult, KEY_LOCATIONS

    If templateScanResult.Exists(KEY_INVALID_CANDIDATES) Then
        PrintCollectionValues _
            "Invalid Candidate", _
            templateScanResult.Item(KEY_INVALID_CANDIDATES)
    End If
End Sub

Private Sub PrintSyncDiffCounts( _
    ByVal syncDiffResult As Object _
)

    If Not IsDictionary(syncDiffResult) Then
        Debug.Print "SyncDiffResult Type = " & TypeName(syncDiffResult)
        Exit Sub
    End If

    Debug.Print "SyncDiffResult:"
    PrintCarrierCount syncDiffResult, KEY_NEW
    PrintCarrierCount syncDiffResult, KEY_EXISTING
    PrintCarrierCount syncDiffResult, KEY_REACTIVATED
    PrintCarrierCount syncDiffResult, KEY_UNUSED
End Sub

Private Sub PrintCarrierCount( _
    ByVal carrier As Object, _
    ByVal keyName As String _
)

    Dim valueObject As Object

    If carrier Is Nothing Then
        Debug.Print "  " & keyName & " = <carrier Nothing>"
        Exit Sub
    End If

    If Not carrier.Exists(keyName) Then
        Debug.Print "  " & keyName & " = <missing>"
        Exit Sub
    End If

    If Not IsObject(carrier.Item(keyName)) Then
        Debug.Print "  " & keyName & " = <not object>"
        Exit Sub
    End If

    Set valueObject = carrier.Item(keyName)

    On Error GoTo CountError
    Debug.Print "  " & keyName & ".Count = " & CStr(valueObject.Count)
    Set valueObject = Nothing
    Exit Sub

CountError:
    Debug.Print "  " & keyName & ".Count = <unavailable>"
    Set valueObject = Nothing
End Sub

Private Sub PrintCollectionValues( _
    ByVal prefix As String, _
    ByVal values As Object _
)

    Dim value As Variant

    If values Is Nothing Then Exit Sub

    On Error GoTo PrintError

    For Each value In values
        If IsObject(value) Then
            If IsDictionary(value) Then
                If value.Exists(FIELD_VARIABLE_NAME) Then
                    Debug.Print "  " & prefix & ": " & _
                        CStr(value.Item(FIELD_VARIABLE_NAME))
                Else
                    Debug.Print "  " & prefix & ": <Dictionary>"
                End If
            Else
                Debug.Print "  " & prefix & ": <" & TypeName(value) & ">"
            End If
        Else
            Debug.Print "  " & prefix & ": " & CStr(value)
        End If
    Next value

    Exit Sub

PrintError:
    Debug.Print "  " & prefix & ": <unable to enumerate>"
End Sub

Private Sub PrintOperationResult( _
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

Private Sub CheckCollectionCountEquals( _
    ByVal value As Variant, _
    ByVal expectedCount As Long, _
    ByVal testName As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim collectionValue As Object

    If Not IsObject(value) Then
        RecordResult False, testName, passCount, failCount
        Exit Sub
    End If

    Set collectionValue = value

    On Error GoTo CountError
    RecordResult _
        (collectionValue.Count = expectedCount), _
        testName, _
        passCount, _
        failCount

    Set collectionValue = Nothing
    Exit Sub

CountError:
    RecordResult False, testName, passCount, failCount
    Set collectionValue = Nothing
End Sub

Private Sub CheckCondition( _
    ByVal condition As Boolean, _
    ByVal testName As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)
    RecordResult condition, testName, passCount, failCount
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

Private Function IsDictionary( _
    ByVal value As Object _
) As Boolean

    If value Is Nothing Then
        IsDictionary = False
        Exit Function
    End If

    IsDictionary = _
        (StrComp(TypeName(value), "Dictionary", vbTextCompare) = 0)
End Function

Private Function TryGetDate( _
    ByVal value As Variant, _
    ByRef dateValue As Date _
) As Boolean

    On Error GoTo InvalidDate

    If IsError(value) Then Exit Function
    If IsNull(value) Then Exit Function
    If IsEmpty(value) Then Exit Function

    If VarType(value) = vbDate Then
        dateValue = CDate(value)
        TryGetDate = True
        Exit Function
    End If

    If IsNumeric(value) Then
        dateValue = CDate(CDbl(value))
        TryGetDate = True
        Exit Function
    End If

    Exit Function

InvalidDate:
    TryGetDate = False
End Function
