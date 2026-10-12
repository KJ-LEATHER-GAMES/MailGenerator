Attribute VB_Name = "modP2_02SyncDiffCompatibilityTest"
Option Explicit

Public Sub TestP202SyncDiffContractCompatibility()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(70, "=")
    Debug.Print "P2-02 Sync Diff Contract Compatibility"
    Debug.Print String$(70, "=")

    RecordResult _
        "K1 P2-01 ScanTemplate Carrier", _
        TestP201CarrierCompatibility(), _
        passCount, _
        failCount

    RecordResult _
        "K2 P0 VariableDefinition Carrier", _
        TestP0VariableDefinitionCarrierCompatibility(), _
        passCount, _
        failCount

    Debug.Print String$(70, "-")
    Debug.Print "PASS Count: " & CStr(passCount)
    Debug.Print "FAIL Count: " & CStr(failCount)

    If passCount = 2 And failCount = 0 Then
        Debug.Print "Overall:"
        Debug.Print "PASS"
    Else
        Debug.Print "Overall:"
        Debug.Print "FAIL"
    End If

    Debug.Print String$(70, "=")

End Sub

Private Function TestP201CarrierCompatibility() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set result = ScanTemplate( _
        "{{ModelName}}", _
        "{{Department}}", _
        scanResult)

    If Not result.Success Then
        PrintResultErrors "K1 ScanTemplate", result
        Exit Function
    End If

    If scanResult Is Nothing Then
        Debug.Print "  K1: ScanTemplate returned Nothing result carrier."
        Exit Function
    End If

    If Not scanResult.Exists("ValidVariables") Then Exit Function
    If Not scanResult.Exists("InvalidCandidates") Then Exit Function
    If Not scanResult.Exists("Locations") Then Exit Function

    Set defs = New Collection

    Set result = BuildSyncDiff( _
        scanResult, _
        defs, _
        DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0), _
        diff)

    If Not result.Success Then
        PrintResultErrors "K1 BuildSyncDiff", result
        Exit Function
    End If

    If diff Is Nothing Then Exit Function

    If diff("New").Count <> 2 Then
        Debug.Print "  K1: expected 2 New items."
        Exit Function
    End If

    TestP201CarrierCompatibility = True

End Function

Private Function TestP0VariableDefinitionCarrierCompatibility() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set result = GetAllVariableDefinitions(defs)

    If Not result.Success Then
        PrintResultErrors "K2 GetAllVariableDefinitions", result
        Exit Function
    End If

    If defs Is Nothing Then
        Debug.Print "  K2: GetAllVariableDefinitions returned Nothing."
        Exit Function
    End If

    ' Use the real P2-01 scanner to create a valid empty TemplateScanResult.
    Set result = ScanTemplate(vbNullString, vbNullString, scanResult)

    If Not result.Success Then
        PrintResultErrors "K2 ScanTemplate", result
        Exit Function
    End If

    Set result = BuildSyncDiff( _
        scanResult, _
        defs, _
        DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0), _
        diff)

    If Not result.Success Then
        PrintResultErrors "K2 BuildSyncDiff", result
        Exit Function
    End If

    If diff Is Nothing Then Exit Function

    TestP0VariableDefinitionCarrierCompatibility = True

End Function

Private Sub RecordResult( _
    ByVal label As String, _
    ByVal passed As Boolean, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If passed Then
        Debug.Print label & Space$(MaxLong(1, 48 - Len(label))) & "PASS"
        passCount = passCount + 1
    Else
        Debug.Print label & Space$(MaxLong(1, 48 - Len(label))) & "FAIL"
        failCount = failCount + 1
    End If

End Sub

Private Sub PrintResultErrors( _
    ByVal context As String, _
    ByVal result As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    Debug.Print "  FAIL: " & context

    If result Is Nothing Then
        Debug.Print "    Result is Nothing."
        Exit Sub
    End If

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)
        Debug.Print "    Error[" & CStr(i) & "]"
        Debug.Print "      Type   = " & errorInfo.ErrorType
        Debug.Print "      Message= " & errorInfo.Message
        Debug.Print "      Target = " & errorInfo.Target
    Next i

End Sub

Private Function MaxLong( _
    ByVal leftValue As Long, _
    ByVal rightValue As Long _
) As Long

    If leftValue > rightValue Then
        MaxLong = leftValue
    Else
        MaxLong = rightValue
    End If

End Function
