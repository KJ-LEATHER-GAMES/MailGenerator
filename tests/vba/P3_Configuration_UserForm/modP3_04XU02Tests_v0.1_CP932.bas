Attribute VB_Name = "modP3_04XU02Tests"
Option Explicit

' Isolated VBA test only. DO NOT run in a Production workbook.
' Prerequisite: frmMailGenerator + modP3UserFormController + modResult +
'              COperationResult + CErrorInfo + modP3_04GateStub.
' No Outlook, Excel data tables or real P3-01/02/03 modules are required.

Public Sub RunP304XU02CandidateTests()
    Dim cases As Variant
    Dim key As Variant
    Dim passed As Long
    Dim failed As Long
    Dim result As Boolean

    cases = Array( _
        "FAIL", "NIL_RESULT", "NO_ROWS", "NO_GROUPS", "GROUP_WRONG_TYPE", _
        "MIXED", "TAG_BINDING", "LABELS", "REQUIRED_MARKERS", _
        "OPTION_ORDER", "SELECT_STYLE", "TEXT_SINGLE_LINE", _
        "EMPTY", "BAD_TYPE", "BAD_DESCRIPTION", "MISSING_GROUP", _
        "BAD_OPTION_VALUE", "REPEATED_FORM", "BUILD_TWICE", _
        "DIRECT_BUILD_SUCCESS", "DIRECT_BUILD_FAILURE", _
        "DIRECT_BUILD_NIL_RESULT", "DIRECT_BUILD_BAD_ROWS", _
        "DIRECT_BUILD_BAD_OPTION", "DIRECT_SHOW_UNBUILT", _
        "DIRECT_SHOW_AFTER_FAILURE", "DIRECT_SHOW_AFTER_SUCCESS", _
        "SOURCE_ROW_MUTATION", "SOURCE_OPTION_MUTATION", "SOURCE_CLEAR", _
        "CASE_MISMATCH", "SECOND_ROW_INVALID", "MISSING_REQUIRED", _
        "OPTION_NONOBJECT", "OPTION_ARRAY_VALUE")

    For Each key In cases
        result = CheckCase(CStr(key))
        If result Then
            passed = passed + 1
            Debug.Print "DEV-P3FORM-" & CStr(key) & " PASS"
        Else
            failed = failed + 1
            Debug.Print "DEV-P3FORM-" & CStr(key) & " FAIL"
        End If
    Next key
    Debug.Print "P3-04 candidate total: PASS=" & passed & " FAIL=" & failed
End Sub

Private Function CheckCase(ByVal key As String) As Boolean
    Dim scenario As String
    Dim formInstance As frmMailGenerator
    Dim secondInstance As frmMailGenerator
    Dim stepResult As COperationResult
    Dim repeatResult As COperationResult
    Dim combo As MSForms.ComboBox
    Dim selector As MSForms.ComboBox
    Dim txt1 As MSForms.TextBox
    Dim txt2 As MSForms.TextBox
    Dim sourceRow As Object
    Dim sourceOptions As Collection
    Dim sourceOption As Object

    On Error GoTo TestFailed
    scenario = key
    Select Case key
        Case "MIXED", "TAG_BINDING", "LABELS", "REQUIRED_MARKERS", _
             "OPTION_ORDER", "SELECT_STYLE", "TEXT_SINGLE_LINE", _
             "REPEATED_FORM", "BUILD_TWICE", _
             "SOURCE_ROW_MUTATION", "SOURCE_OPTION_MUTATION", "SOURCE_CLEAR"
            scenario = "MIXED"
    End Select

    Select Case key
        Case "DIRECT_BUILD_SUCCESS", "DIRECT_BUILD_FAILURE", _
             "DIRECT_BUILD_NIL_RESULT", "DIRECT_BUILD_BAD_ROWS", _
             "DIRECT_BUILD_BAD_OPTION", "DIRECT_SHOW_UNBUILT", _
             "DIRECT_SHOW_AFTER_FAILURE", "DIRECT_SHOW_AFTER_SUCCESS"
            CheckCase = CheckDirectCase(key)
            Exit Function
    End Select

    ConfigureP304Stub scenario
    Set stepResult = BuildMailGeneratorForm(formInstance)
    If stepResult Is Nothing Then GoTo TestFailed
    If P304GateCalls <> 1 Then GoTo TestFailed

    Select Case key
        Case "FAIL"
            If stepResult Is P304Failure And formInstance Is Nothing Then CheckCase = True
        Case "NIL_RESULT", "NO_ROWS", "NO_GROUPS", "GROUP_WRONG_TYPE", _
             "BAD_TYPE", "BAD_DESCRIPTION", "MISSING_GROUP", "BAD_OPTION_VALUE", _
             "CASE_MISMATCH", "SECOND_ROW_INVALID", "MISSING_REQUIRED", _
             "OPTION_NONOBJECT", "OPTION_ARRAY_VALUE"
            If Not stepResult.Success And formInstance Is Nothing Then CheckCase = True
        Case "EMPTY"
            If stepResult.Success And Not formInstance Is Nothing Then
                CheckCase = (formInstance.Controls("fraInputArea").Controls.Count = 0)
            End If
        Case Else
            If Not stepResult.Success Then GoTo TestFailed
            If formInstance Is Nothing Then GoTo TestFailed
            Select Case key
                Case "MIXED"
                    CheckCase = (formInstance.Controls("fraInputArea").Controls.Count = 12)
                Case "TAG_BINDING"
                    CheckCase = ( _
                        CStr(GetInput(formInstance, "txtInput_0001").Tag) = "ModelName" And _
                        CStr(GetInput(formInstance, "txtInput_0002").Tag) = "GateDate" And _
                        CStr(GetInput(formInstance, "cboInput_0003").Tag) = "Department")
                Case "LABELS"
                    CheckCase = ( _
                        formInstance.Controls("fraInputArea").Controls("lblDisplay_0001").Caption = "機種名" And _
                        formInstance.Controls("fraInputArea").Controls("lblDescription_0003").Caption = "部門を選択")
                Case "REQUIRED_MARKERS"
                    CheckCase = ( _
                        formInstance.Controls("fraInputArea").Controls("lblRequired_0001").Visible And _
                        Not formInstance.Controls("fraInputArea").Controls("lblRequired_0002").Visible And _
                        formInstance.Controls("fraInputArea").Controls("lblRequired_0003").Visible)
                Case "OPTION_ORDER"
                    Set combo = formInstance.Controls("fraInputArea").Controls("cboInput_0003")
                    CheckCase = (combo.ListCount = 2 And combo.List(0) = "設計部" And combo.List(1) = "品質部")
                Case "SELECT_STYLE"
                    Set selector = formInstance.Controls("fraInputArea").Controls("cboInput_0003")
                    CheckCase = (selector.Style = fmStyleDropDownList And selector.ListIndex = -1)
                Case "TEXT_SINGLE_LINE"
                    Set txt1 = formInstance.Controls("fraInputArea").Controls("txtInput_0001")
                    Set txt2 = formInstance.Controls("fraInputArea").Controls("txtInput_0002")
                    CheckCase = (Not txt1.MultiLine And Not txt2.MultiLine)
                Case "REPEATED_FORM"
                    Set repeatResult = BuildMailGeneratorForm(secondInstance)
                    CheckCase = (repeatResult.Success And _
                        P304GateCalls = 2 And Not secondInstance Is Nothing)
                Case "BUILD_TWICE"
                    Set repeatResult = formInstance.BuildValidatedInputs()
                    CheckCase = (Not repeatResult.Success And P304GateCalls = 1)
                Case "SOURCE_ROW_MUTATION"
                    ' External source dictionaries remain mutable after Gate.
                    Set sourceRow = P304SourceRows(1)
                    sourceRow("VariableName") = "ChangedName"
                    sourceRow("DisplayName") = "改変した名前"
                    sourceRow("Required") = False
                    sourceRow("Description") = "改変した説明"
                    CheckCase = ( _
                        GetInput(formInstance, "txtInput_0001").Tag = "ModelName" And _
                        formInstance.Controls("fraInputArea").Controls("lblDisplay_0001").Caption = "機種名" And _
                        formInstance.Controls("fraInputArea").Controls("lblRequired_0001").Visible And _
                        formInstance.Controls("fraInputArea").Controls("lblDescription_0001").Caption = "名称を入力")
                Case "SOURCE_OPTION_MUTATION"
                    Set sourceOptions = P304SourceGroups("Department")
                    Set sourceOption = sourceOptions(1)
                    sourceOption("Value") = "改変した選択肢"
                    Set combo = formInstance.Controls("fraInputArea").Controls("cboInput_0003")
                    CheckCase = (combo.ListCount = 2 And combo.List(0) = "設計部" And combo.List(1) = "品質部")
                Case "SOURCE_CLEAR"
                    P304SourceRows.Remove 3
                    P304SourceRows.Remove 2
                    P304SourceRows.Remove 1
                    P304SourceGroups.Remove "Department"
                    Set combo = formInstance.Controls("fraInputArea").Controls("cboInput_0003")
                    CheckCase = ( _
                        formInstance.Controls("fraInputArea").Controls.Count = 12 And _
                        GetInput(formInstance, "txtInput_0001").Tag = "ModelName" And _
                        combo.ListCount = 2 And combo.List(1) = "品質部")
            End Select
    End Select

TestExit:
    On Error Resume Next
    If Not secondInstance Is Nothing Then Unload secondInstance
    If Not formInstance Is Nothing Then Unload formInstance
    Set secondInstance = Nothing
    Set formInstance = Nothing
    On Error GoTo 0
    Exit Function
TestFailed:
    CheckCase = False
    Resume TestExit
End Function

Private Function GetInput( _
    ByVal formInstance As frmMailGenerator, _
    ByVal controlName As String _
) As MSForms.Control
    Set GetInput = formInstance.Controls("fraInputArea").Controls(controlName)
End Function

' XU-01 regression: exercise direct entry points (NOT just UI Controller).
Private Function CheckDirectCase(ByVal key As String) As Boolean
    Dim frm As frmMailGenerator
    Dim result As COperationResult
    Dim scenario As String
    On Error GoTo TestFailed

    scenario = "MIXED"
    Select Case key
        Case "DIRECT_BUILD_FAILURE", "DIRECT_SHOW_AFTER_FAILURE"
            scenario = "FAIL"
        Case "DIRECT_BUILD_NIL_RESULT"
            scenario = "NIL_RESULT"
        Case "DIRECT_BUILD_BAD_ROWS"
            scenario = "NO_ROWS"
        Case "DIRECT_BUILD_BAD_OPTION"
            scenario = "BAD_OPTION_VALUE"
    End Select

    ConfigureP304Stub scenario
    Set frm = New frmMailGenerator

    Select Case key
        Case "DIRECT_SHOW_UNBUILT"
            ' .Show without any public builder must never leave UI visible.
            frm.Show vbModeless
            CheckDirectCase = (Not frm.Visible And _
                P304GateCalls = 0 And _
                frm.Controls("fraInputArea").Controls.Count = 0)
        Case "DIRECT_BUILD_SUCCESS"
            Set result = frm.BuildValidatedInputs()
            If Not result Is Nothing Then
                CheckDirectCase = (result.Success And _
                    P304GateCalls = 1 And _
                    frm.Controls("fraInputArea").Controls.Count = 12)
            End If
        Case "DIRECT_BUILD_FAILURE"
            Set result = frm.BuildValidatedInputs()
            CheckDirectCase = (result Is P304Failure And _
                P304GateCalls = 1 And _
                frm.Controls("fraInputArea").Controls.Count = 0)
        Case "DIRECT_BUILD_NIL_RESULT", "DIRECT_BUILD_BAD_ROWS", _
             "DIRECT_BUILD_BAD_OPTION"
            Set result = frm.BuildValidatedInputs()
            If Not result Is Nothing Then
                CheckDirectCase = (Not result.Success And _
                    P304GateCalls = 1 And _
                    frm.Controls("fraInputArea").Controls.Count = 0)
            End If
        Case "DIRECT_SHOW_AFTER_FAILURE"
            Set result = frm.BuildValidatedInputs()
            If result Is P304Failure Then
                frm.Show vbModeless
                CheckDirectCase = (Not frm.Visible And P304GateCalls = 1)
            End If
        Case "DIRECT_SHOW_AFTER_SUCCESS"
            Set result = frm.BuildValidatedInputs()
            If Not result Is Nothing Then
                If result.Success Then
                    frm.Show vbModeless
                    CheckDirectCase = (frm.Visible And P304GateCalls = 1)
                End If
            End If
    End Select

TestExit:
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    Set frm = Nothing
    On Error GoTo 0
    Exit Function
TestFailed:
    CheckDirectCase = False
    Resume TestExit
End Function
