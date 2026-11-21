Attribute VB_Name = "modP3_04GateStub"
Option Explicit

' TEST-ONLY STUB: replaces P3-03 PrepareUserFormLaunch by PUBLIC NAME.
' NEVER import into the same VBA project as real modP3UserFormLaunchGate.
Public P304Scenario As String
Public P304GateCalls As Long
Public P304Failure As COperationResult
Public P304SourceRows As Collection
Public P304SourceGroups As Object

Public Sub ConfigureP304Stub(ByVal scenario As String)
    P304Scenario = scenario
    P304GateCalls = 0
    Set P304SourceRows = Nothing
    Set P304SourceGroups = Nothing
    Set P304Failure = CreateFailureResult( _
        "ConfigurationError", "Injected upstream failure.", "TestStub")
End Sub

Public Function PrepareUserFormLaunch( _
    ByRef sortedActiveDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult
    Dim rows As Collection
    Dim groups As Object
    Dim opts As Collection
    Dim row As Object

    P304GateCalls = P304GateCalls + 1
    Set sortedActiveDefinitions = Nothing
    Set activeOptionsByGroup = Nothing

    If P304Scenario = "FAIL" Then
        Set PrepareUserFormLaunch = P304Failure
        Exit Function
    End If
    If P304Scenario = "NIL_RESULT" Then Exit Function
    If P304Scenario = "NO_ROWS" Then
        Set activeOptionsByGroup = CreateObject("Scripting.Dictionary")
        Set PrepareUserFormLaunch = CreateSuccessResult()
        Exit Function
    End If
    If P304Scenario = "NO_GROUPS" Then
        Set sortedActiveDefinitions = New Collection
        Set PrepareUserFormLaunch = CreateSuccessResult()
        Exit Function
    End If
    If P304Scenario = "GROUP_WRONG_TYPE" Then
        Set sortedActiveDefinitions = New Collection
        Set activeOptionsByGroup = New Collection
        Set PrepareUserFormLaunch = CreateSuccessResult()
        Exit Function
    End If

    Set rows = New Collection
    Set groups = CreateObject("Scripting.Dictionary")
    groups.CompareMode = vbBinaryCompare

    If P304Scenario <> "EMPTY" Then
        ' Already sorted by the upstream gate. P3-04 MUST preserve this order.
        Set row = MakeRow("ModelName", "機種名", "Text", True, "名称を入力", "")
        rows.Add row
        Set row = MakeRow("GateDate", "判定日", "Date", False, "西暦で入力", "")
        If P304Scenario = "SECOND_ROW_INVALID" Then row("Type") = "Number"
        rows.Add row
        Set row = MakeRow("Department", "担当部門", "Select", True, "部門を選択", "Department")

        If P304Scenario = "BAD_TYPE" Then row("Type") = "Number"
        If P304Scenario = "BAD_DESCRIPTION" Then row("Description") = Null
        If P304Scenario = "MISSING_REQUIRED" Then row.Remove "Required"
        rows.Add row

        Set opts = New Collection
        Set row = CreateObject("Scripting.Dictionary")
        row.Add "Value", "設計部"
        opts.Add row
        Set row = CreateObject("Scripting.Dictionary")
        row.Add "Value", "品質部"
        If P304Scenario = "BAD_OPTION_VALUE" Then row("Value") = Null
        If P304Scenario = "OPTION_ARRAY_VALUE" Then row("Value") = Array("invalid")
        If P304Scenario = "OPTION_NONOBJECT" Then
            opts.Add "not-a-dictionary"
        Else
            opts.Add row
        End If

        If P304Scenario <> "MISSING_GROUP" Then
            If P304Scenario = "CASE_MISMATCH" Then
                groups.CompareMode = vbTextCompare
                groups.Add "department", opts
            Else
                groups.Add "Department", opts
            End If
        End If
    End If

    Set P304SourceRows = rows
    Set P304SourceGroups = groups
    Set sortedActiveDefinitions = rows
    Set activeOptionsByGroup = groups
    Set PrepareUserFormLaunch = CreateSuccessResult()
End Function

Private Function MakeRow( _
    ByVal variableName As String, _
    ByVal displayName As String, _
    ByVal variableType As String, _
    ByVal required As Boolean, _
    ByVal hint As String, _
    ByVal optionSource As String _
) As Object
    Dim item As Object
    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare
    item.Add "VariableName", variableName
    item.Add "DisplayName", displayName
    item.Add "Type", variableType
    item.Add "Required", required
    item.Add "Description", hint
    item.Add "OptionSource", optionSource
    Set MakeRow = item
End Function
