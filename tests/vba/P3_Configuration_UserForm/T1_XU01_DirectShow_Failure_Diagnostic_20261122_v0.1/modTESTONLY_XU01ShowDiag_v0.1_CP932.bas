Attribute VB_Name = "modTESTONLY_XU01ShowDiag"
Option Explicit

' TEST ONLY. Import into isolated T1 only. Never into Production.
' Requires existing frmMailGenerator, modP3_04GateStub, modResult,
' COperationResult, CErrorInfo. Does NOT change any Candidate API.
Public Sub RunTESTONLY_XU01_ShowDiagnostics()
    Debug.Print String$(55, "=")
    Debug.Print "XU01-SHOW-DIAG START"
    DiagnoseShow "DIRECT_SHOW_UNBUILT", "MIXED", False
    DiagnoseShow "DIRECT_SHOW_AFTER_FAILURE", "FAIL", True
    Debug.Print "XU01-SHOW-DIAG END; DIAGNOSTIC ONLY / NO PASS CLAIM"
    Debug.Print String$(55, "=")
End Sub

Private Sub DiagnoseShow( _
    ByVal caseId As String, _
    ByVal scenario As String, _
    ByVal callBuilder As Boolean _
)
    Dim frm As frmMailGenerator
    Dim result As COperationResult
    Dim showErrNo As Long
    Dim showErrDesc As String
    Dim resultIsFailure As Boolean

    On Error GoTo Unexpected
    ConfigureP304Stub scenario
    Set frm = New frmMailGenerator
    Debug.Print caseId & " | BEFORE | GateCalls=" & CStr(P304GateCalls)

    If callBuilder Then
        Set result = frm.BuildValidatedInputs()
        If result Is Nothing Then
            Debug.Print caseId & " | BUILDER | Result=Nothing"
        Else
            resultIsFailure = (result Is P304Failure)
            Debug.Print caseId & " | BUILDER | Success=" & CStr(result.Success) & _
                " UpstreamResultIdentity=" & CStr(resultIsFailure)
        End If
    End If

    PrintState caseId, "BEFORE_SHOW", frm
    On Error Resume Next
    frm.Show vbModeless
    showErrNo = Err.Number
    showErrDesc = Err.Description
    Err.Clear
    On Error GoTo Unexpected
    Debug.Print caseId & " | SHOW | Err.Number=" & CStr(showErrNo) & _
        " Err.Description=" & showErrDesc
    PrintState caseId, "IMMEDIATE_AFTER_SHOW", frm
    DoEvents
    PrintState caseId, "AFTER_DOEVENTS", frm
    GoTo Cleanup

Unexpected:
    Debug.Print caseId & " | UNEXPECTED | Err.Number=" & CStr(Err.Number) & _
        " Err.Description=" & Err.Description
    Resume Cleanup

Cleanup:
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    Set frm = Nothing
    Err.Clear
    On Error GoTo 0
    Debug.Print caseId & " | CLEANUP_DONE"
End Sub

Private Sub PrintState( _
    ByVal caseId As String, _
    ByVal phase As String, _
    ByVal frm As frmMailGenerator _
)
    Dim isVisible As Boolean
    Dim visibleErr As Long
    Dim childCount As Long
    Dim childErr As Long
    On Error Resume Next
    isVisible = frm.Visible
    visibleErr = Err.Number
    Err.Clear
    childCount = frm.Controls("fraInputArea").Controls.Count
    childErr = Err.Number
    Err.Clear
    On Error GoTo 0
    Debug.Print caseId & " | " & phase & _
        " | Visible=" & CStr(isVisible) & _
        " VisibleErr=" & CStr(visibleErr) & _
        " InputControlCount=" & CStr(childCount) & _
        " ControlErr=" & CStr(childErr) & _
        " GateCalls=" & CStr(P304GateCalls)
End Sub
