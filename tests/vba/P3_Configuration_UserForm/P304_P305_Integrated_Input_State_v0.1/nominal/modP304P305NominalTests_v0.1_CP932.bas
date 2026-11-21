Attribute VB_Name = "modP304P305NominalTests"
Option Explicit

' TEST ONLY. Requires P0 modResult/COperationResult/CErrorInfo,
' integrated frmMailGenerator, real P3-05 modInputState and
' modP3_04GateStub (instead of real P3-03). NOT a formal MVP Test.

Public Sub RunP304P305NominalCandidateTests()
    Dim ids As Variant
    Dim id As Variant
    Dim passed As Long
    Dim failed As Long

    ids = Array( _
        "RESTORE_TEXT", "RESTORE_DATE_RAW", "RESTORE_SELECT_EXACT", _
        "RESTORE_MISSING", "RESTORE_EMPTY", "RESTORE_CASE_KEY", _
        "STALE_SELECT", "SELECT_CASE", "CLOSE_CAPTURE", _
        "CLOSE_EMPTY_SELECT", "PREFLIGHT_BAD_TAG", "PREFLIGHT_DUP_TAG", _
        "CLEAR_BOTH", "CLEAR_SKIP_COMMIT", "CLEAR_REINPUT", _
        "CLEAR_MANUAL_EMPTY", "SINGLE_GATE", "SCALAR_ISOLATED", _
        "GATE_FAILURE", "UNBUILT_NO_SAVE", "STALE_CLOSE_EMPTY")

    For Each id In ids
        If RunNominalCase(CStr(id)) Then
            passed = passed + 1
            Debug.Print "P304-P305-NOM-" & CStr(id) & " PASS"
        Else
            failed = failed + 1
            Debug.Print "P304-P305-NOM-" & CStr(id) & " FAIL"
        End If
    Next id
    Debug.Print "P304-P305 nominal: PASS=" & passed & " FAIL=" & failed
End Sub

Private Function RunNominalCase(ByVal testId As String) As Boolean
    Dim f As frmMailGenerator
    Dim result As COperationResult
    Dim hasValue As Boolean
    Dim textValue As String
    Dim sourceRow As Object
    Dim caseResult As Boolean
    Dim originalTag As String

    On Error GoTo Failed
    Set result = ClearInputValues()
    If result Is Nothing Then GoTo Failed
    If Not result.Success Then GoTo Failed
    ConfigureP304Stub "MIXED"

    Select Case testId
        Case "RESTORE_TEXT"
            Set result = SetInputValue("ModelName", "試作A")
        Case "RESTORE_DATE_RAW"
            Set result = SetInputValue("GateDate", "invalid-date-raw")
        Case "RESTORE_SELECT_EXACT"
            Set result = SetInputValue("Department", "品質部")
        Case "RESTORE_EMPTY"
            Set result = SetInputValue("ModelName", "")
        Case "RESTORE_CASE_KEY"
            Set result = SetInputValue("modelname", "Case-key")
        Case "STALE_SELECT", "STALE_CLOSE_EMPTY"
            Set result = SetInputValue("Department", "旧部門")
        Case "SELECT_CASE"
            ConfigureP304Stub "CASE_VALUE"
            Set result = SetInputValue("Department", "sales")
        Case "CLEAR_BOTH", "CLEAR_SKIP_COMMIT", "CLEAR_REINPUT"
            Set result = SetInputValue("ModelName", "旧値")
        Case "PREFLIGHT_BAD_TAG", "PREFLIGHT_DUP_TAG"
            Set result = SetInputValue("ModelName", "保存済み")
        Case "GATE_FAILURE"
            ConfigureP304Stub "FAIL"
        Case Else
            Set result = CreateSuccessResult()
    End Select
    If testId <> "GATE_FAILURE" Then
        If result Is Nothing Then GoTo Failed
        If Not result.Success Then GoTo Failed
    End If

    If testId = "UNBUILT_NO_SAVE" Then
        Set f = New frmMailGenerator
        Unload f
        Set result = TryGetInputValue("ModelName", hasValue, textValue)
        caseResult = (result.Success And Not hasValue And P304GateCalls = 0)
        GoTo Finished
    End If

    Set result = BuildMailGeneratorForm(f)
    If result Is Nothing Then GoTo Failed
    If testId = "GATE_FAILURE" Then
        caseResult = (Not result.Success And f Is Nothing And P304GateCalls = 1)
        GoTo Finished
    End If
    If Not result.Success Or f Is Nothing Then GoTo Failed

    Select Case testId
        Case "RESTORE_TEXT"
            caseResult = (InputText(f, "txtInput_0001") = "試作A")
        Case "RESTORE_DATE_RAW"
            caseResult = (InputText(f, "txtInput_0002") = "invalid-date-raw")
        Case "RESTORE_SELECT_EXACT"
            caseResult = (SelectIndex(f) = 1)
        Case "RESTORE_MISSING"
            caseResult = (InputText(f, "txtInput_0001") = "" And SelectIndex(f) = -1)
        Case "RESTORE_EMPTY"
            Set result = TryGetInputValue("ModelName", hasValue, textValue)
            caseResult = (InputText(f, "txtInput_0001") = "" And result.Success And hasValue)
        Case "RESTORE_CASE_KEY"
            caseResult = (InputText(f, "txtInput_0001") = "Case-key")
        Case "STALE_SELECT"
            Set result = TryGetInputValue("Department", hasValue, textValue)
            caseResult = (SelectIndex(f) = -1 And hasValue And _
                textValue = "旧部門" And _
                InStr(1, f.Controls("fraErrorArea").Controls("lblErrorText").Caption, "旧部門", vbBinaryCompare) > 0)
        Case "STALE_CLOSE_EMPTY"
            If SelectIndex(f) <> -1 Then GoTo Failed
            Unload f
            If Not f.InputCommitSucceeded Then GoTo Failed
            Set result = TryGetInputValue("Department", hasValue, textValue)
            caseResult = (result.Success And hasValue And textValue = "")
        Case "SELECT_CASE"
            caseResult = (SelectIndex(f) = -1 And _
                InStr(1, f.Controls("fraErrorArea").Controls("lblErrorText").Caption, "sales", vbBinaryCompare) > 0)
        Case "CLOSE_CAPTURE", "CLOSE_EMPTY_SELECT"
            f.Controls("fraInputArea").Controls("txtInput_0001").Value = "新A"
            f.Controls("fraInputArea").Controls("txtInput_0002").Value = "not-a-date"
            If testId = "CLOSE_CAPTURE" Then
                f.Controls("fraInputArea").Controls("cboInput_0003").ListIndex = 1
            End If
            Unload f   ' first close: QueryClose saves + hides, but Cancel=True
            If Not f.InputCommitSucceeded Then GoTo Failed
            Set result = TryGetInputValue("ModelName", hasValue, textValue)
            If Not result.Success Or Not hasValue Or textValue <> "新A" Then GoTo Failed
            Set result = TryGetInputValue("GateDate", hasValue, textValue)
            If Not result.Success Or textValue <> "not-a-date" Then GoTo Failed
            Set result = TryGetInputValue("Department", hasValue, textValue)
            caseResult = (result.Success And hasValue And _
                ((testId = "CLOSE_CAPTURE" And textValue = "品質部") Or _
                 (testId = "CLOSE_EMPTY_SELECT" And textValue = "")))
        Case "PREFLIGHT_BAD_TAG", "PREFLIGHT_DUP_TAG"
            If testId = "PREFLIGHT_BAD_TAG" Then
                f.Controls("fraInputArea").Controls("txtInput_0002").Tag = ""
            Else
                f.Controls("fraInputArea").Controls("txtInput_0002").Tag = "modelname"
            End If
            f.Controls("fraInputArea").Controls("txtInput_0001").Value = "新値"
            Unload f
            Set result = TryGetInputValue("ModelName", hasValue, textValue)
            caseResult = (Not f.InputCommitSucceeded And result.Success And hasValue And textValue = "保存済み")
        Case "CLEAR_BOTH", "CLEAR_SKIP_COMMIT", "CLEAR_REINPUT"
            f.Controls("fraInputArea").Controls("txtInput_0001").Value = "新値"
            f.Controls("fraInputArea").Controls("cboInput_0003").ListIndex = 0
            ' MSForms.CommandButton.Value=True triggers Click in the isolated UI.
            f.Controls("cmdClear").Value = True
            Set result = TryGetInputValue("ModelName", hasValue, textValue)
            If Not result.Success Then GoTo Failed
            If hasValue Or InputText(f, "txtInput_0001") <> "" Or SelectIndex(f) <> -1 Then GoTo Failed
            If testId = "CLEAR_REINPUT" Then
                f.Controls("fraInputArea").Controls("txtInput_0001").Value = "再入力"
            End If
            If testId = "CLEAR_SKIP_COMMIT" Or testId = "CLEAR_REINPUT" Then
                Unload f
                If Not f.InputCommitSucceeded Then GoTo Failed
                Set result = TryGetInputValue("ModelName", hasValue, textValue)
                caseResult = (result.Success And _
                    ((testId = "CLEAR_SKIP_COMMIT" And Not hasValue) Or _
                     (testId = "CLEAR_REINPUT" And hasValue And textValue = "再入力")))
            Else
                caseResult = True
            End If
        Case "CLEAR_MANUAL_EMPTY"
            f.Controls("fraInputArea").Controls("txtInput_0001").Value = ""
            Unload f
            Set result = TryGetInputValue("ModelName", hasValue, textValue)
            caseResult = (f.InputCommitSucceeded And result.Success And hasValue And textValue = "")
        Case "SINGLE_GATE"
            caseResult = (P304GateCalls = 1 And f.Controls("cmdClear").Enabled)
        Case "SCALAR_ISOLATED"
            Set sourceRow = P304SourceRows(1)
            sourceRow("VariableName") = "Tampered"
            caseResult = (f.Controls("fraInputArea").Controls("txtInput_0001").Tag = "ModelName")
    End Select

Finished:
    On Error Resume Next
    If Not f Is Nothing Then
        If f.InputCommitSucceeded Then Unload f
    End If
    Set f = Nothing
    ClearInputValues
    On Error GoTo 0
    RunNominalCase = caseResult
    Exit Function
Failed:
    caseResult = False
    Resume Finished
End Function

Private Function InputText(ByVal f As frmMailGenerator, ByVal name As String) As String
    InputText = CStr(f.Controls("fraInputArea").Controls(name).Value)
End Function

Private Function SelectIndex(ByVal f As frmMailGenerator) As Long
    SelectIndex = CLng(f.Controls("fraInputArea").Controls("cboInput_0003").ListIndex)
End Function