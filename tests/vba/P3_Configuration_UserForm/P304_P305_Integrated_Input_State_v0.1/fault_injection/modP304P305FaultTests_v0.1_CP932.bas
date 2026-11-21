Attribute VB_Name = "modP304P305FaultTests"
Option Explicit

' TEST ONLY. Requires fault stub INSTEAD of the real modInputState and
' same gate stub used by nominal tests. Never mix these API implementations.
Public Sub RunP304P305FaultCandidateTests()
    Dim ids As Variant
    Dim id As Variant
    Dim passed As Long
    Dim failed As Long

    ids = Array("RESTORE_GET_FAIL", "RESTORE_GET_NIL", _
        "SAVE_SECOND_FAIL", "SAVE_SECOND_NIL", "SAVE_RETRY_ALL", _
        "CLEAR_FAIL_LOCK", "CLEAR_NIL_LOCK", "CLEAR_RETRY_RECOVER", _
        "NO_DOUBLE_SAVE")
    For Each id In ids
        If RunFaultCase(CStr(id)) Then
            passed = passed + 1
            Debug.Print "P304-P305-FI-" & CStr(id) & " PASS"
        Else
            failed = failed + 1
            Debug.Print "P304-P305-FI-" & CStr(id) & " FAIL"
        End If
    Next id
    Debug.Print "P304-P305 fault: PASS=" & passed & " FAIL=" & failed
End Sub

Private Function RunFaultCase(ByVal testId As String) As Boolean
    Dim f As frmMailGenerator
    Dim result As COperationResult
    Dim checked As Boolean
    Dim firstCount As Long

    On Error GoTo Failed
    ConfigureP305Faults
    ConfigureP304Stub "MIXED"

    Select Case testId
        Case "RESTORE_GET_FAIL": FIFailGetAt = 2
        Case "RESTORE_GET_NIL": FIReturnNilGetAt = 2
        Case "SAVE_SECOND_FAIL", "SAVE_RETRY_ALL": FIFailSetAt = 2
        Case "SAVE_SECOND_NIL": FIReturnNilSetAt = 2
        Case "CLEAR_FAIL_LOCK", "CLEAR_RETRY_RECOVER": FIFailClear = True
        Case "CLEAR_NIL_LOCK": FIReturnNilClear = True
    End Select

    Set result = BuildMailGeneratorForm(f)
    If result Is Nothing Then GoTo Failed
    If testId = "RESTORE_GET_FAIL" Or testId = "RESTORE_GET_NIL" Then
        checked = (Not result.Success And f Is Nothing And P304GateCalls = 1)
        GoTo Done
    End If
    If Not result.Success Or f Is Nothing Then GoTo Failed

    If testId = "NO_DOUBLE_SAVE" Then
        f.Controls("fraInputArea").Controls("txtInput_0001").Value = "CommitOnce"
        Unload f
        If Not f.InputCommitSucceeded Then GoTo Failed
        firstCount = FISetCalls
        If firstCount <> 3 Then GoTo Failed
        Unload f
        checked = (FISetCalls = firstCount)
        GoTo Done
    End If

    If Left$(testId, 5) = "SAVE_" Then
        f.Controls("fraInputArea").Controls("txtInput_0001").Value = "新Model"
        f.Controls("fraInputArea").Controls("txtInput_0002").Value = "新Date"
        f.Controls("fraInputArea").Controls("cboInput_0003").ListIndex = 1
        Unload f
        If f.InputCommitSucceeded Then GoTo Failed
        If FISetCalls <> 2 Then GoTo Failed
        If Not FIStore.Exists("ModelName") Then GoTo Failed
        If CStr(FIStore("ModelName")) <> "新Model" Then GoTo Failed
        If FIStore.Exists("GateDate") Then GoTo Failed
        If FIStore.Exists("Department") Then GoTo Failed
        If testId = "SAVE_RETRY_ALL" Then
            FIFailSetAt = 0
            Unload f
            checked = (f.InputCommitSucceeded And FISetCalls = 5 And _
                CStr(FIStore("ModelName")) = "新Model" And _
                CStr(FIStore("GateDate")) = "新Date" And _
                CStr(FIStore("Department")) = "品質部")
        Else
            checked = True
        End If
    Else
        FIStore("ModelName") = "旧値"
        f.Controls("fraInputArea").Controls("txtInput_0001").Value = "画面値"
        f.Controls("cmdClear").Value = True
        If FIClearCalls <> 1 Then GoTo Failed
        If CStr(FIStore("ModelName")) <> "旧値" Then GoTo Failed
        If CStr(f.Controls("fraInputArea").Controls("txtInput_0001").Value) <> "画面値" Then GoTo Failed
        Unload f
        If f.InputCommitSucceeded Then GoTo Failed
        If testId = "CLEAR_RETRY_RECOVER" Then
            FIFailClear = False
            f.Controls("cmdClear").Value = True
            If FIClearCalls <> 2 Or FIStore.Count <> 0 Then GoTo Failed
            Unload f
            checked = f.InputCommitSucceeded
        Else
            checked = True
        End If
    End If
Done:
    On Error Resume Next
    If Not f Is Nothing Then
        If f.InputCommitSucceeded Then Unload f
    End If
    Set f = Nothing
    On Error GoTo 0
    RunFaultCase = checked
    Exit Function
Failed:
    checked = False
    Resume Done
End Function