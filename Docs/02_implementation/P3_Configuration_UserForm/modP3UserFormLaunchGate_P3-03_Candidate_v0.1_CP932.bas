Attribute VB_Name = "modP3UserFormLaunchGate"
Option Explicit

' P3-03 WORKING CANDIDATE ONLY. Not approved, compiled, or executed.
' Gate only: no Form.Show, MsgBox, Sync, persistence, Excel/Outlook access.
' P3-02 PrepareCurrentConfiguration does current OFT scan and P3-01 validation.
' Returned Collections contain existing read-only row object references.

Private Const ERROR_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_UNEXPECTED As String = "UnexpectedError"
Private Const KEY_STATUS As String = "Status"
Private Const KEY_NAME As String = "VariableName"
Private Const KEY_SORT As String = "SortOrder"
Private Const KEY_ROW As String = "__RowIndex"

' The caller MUST check Success before creating or displaying a UserForm.
' On any failure, both output carriers are Nothing. No automatic sync.
Public Function PrepareUserFormLaunch( _
    ByRef sortedActiveDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult

    Dim scanSnapshot As Object
    Dim allDefinitions As Collection
    Dim optionSnapshot As Object
    Dim sortedCandidate As Collection
    Dim stepResult As COperationResult

    Set sortedActiveDefinitions = Nothing
    Set activeOptionsByGroup = Nothing
    On Error GoTo UnexpectedFailure

    Set stepResult = PrepareCurrentConfiguration( _
        scanSnapshot, allDefinitions, optionSnapshot)

    If stepResult Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier( _
            "ConfigurationApplication.Result")
        Exit Function
    End If

    If Not stepResult.Success Then
        ' Preserve exact upstream Result and its ErrorInfo; never sort on Failure.
        Set PrepareUserFormLaunch = stepResult
        Exit Function
    End If

    If scanSnapshot Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier("TemplateScanResult")
        Exit Function
    End If
    If allDefinitions Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier("VariableDefinitions")
        Exit Function
    End If
    If optionSnapshot Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier("ActiveOptionsByGroup")
        Exit Function
    End If
    If TypeName(optionSnapshot) <> "Dictionary" Then
        Set PrepareUserFormLaunch = BrokenCarrier("ActiveOptionsByGroup")
        Exit Function
    End If

    Set stepResult = SortActiveDefinitions(allDefinitions, sortedCandidate)
    If stepResult Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier("SortActiveDefinitions.Result")
        Exit Function
    End If
    If Not stepResult.Success Then
        Set PrepareUserFormLaunch = stepResult
        Exit Function
    End If
    If sortedCandidate Is Nothing Then
        Set PrepareUserFormLaunch = BrokenCarrier("SortedActiveDefinitions")
        Exit Function
    End If

    ' Atomic publication: NEVER expose a partial sorted set.
    Set sortedActiveDefinitions = sortedCandidate
    Set activeOptionsByGroup = optionSnapshot
    Set PrepareUserFormLaunch = stepResult
    Exit Function

UnexpectedFailure:
    Set sortedActiveDefinitions = Nothing
    Set activeOptionsByGroup = Nothing
    Set PrepareUserFormLaunch = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "UserForm launch preparation could not be completed.", _
        "UserFormLaunchGate")
End Function

Private Function SortActiveDefinitions( _
    ByVal definitions As Collection, _
    ByRef sortedDefinitions As Collection _
) As COperationResult

    Dim sortedCandidate As Collection
    Dim seenRowNumbers As Object
    Dim rowValue As Variant
    Dim item As Object
    Dim priorItem As Object
    Dim statusText As String
    Dim variableName As String
    Dim sortKey As Double
    Dim rowIndex As Long
    Dim priorSortKey As Double
    Dim priorIndex As Long
    Dim insertionPoint As Long
    Dim position As Long
    Dim inserted As Boolean

    Set sortedDefinitions = Nothing
    On Error GoTo UnexpectedFailure

    Set sortedCandidate = New Collection
    Set seenRowNumbers = CreateObject("Scripting.Dictionary")
    seenRowNumbers.CompareMode = vbBinaryCompare

    For Each rowValue In definitions
        If Not IsObject(rowValue) Then GoTo BadRow
        Set item = rowValue
        If item Is Nothing Then GoTo BadRow
        If TypeName(item) <> "Dictionary" Then GoTo BadRow
        If Not item.Exists(KEY_STATUS) Then GoTo BadRow
        If Not TryScalarText(item(KEY_STATUS), statusText) Then GoTo BadRow

        If StrComp(statusText, "Unused", vbTextCompare) = 0 Then
            ' Unused rows remain in the source snapshot; never appear in Form.
        ElseIf StrComp(statusText, "Active", vbTextCompare) = 0 Then
            If Not item.Exists(KEY_NAME) Then GoTo BadRow
            If Not TryScalarText(item(KEY_NAME), variableName) Then GoTo BadRow
            If Len(Trim$(variableName)) = 0 Then GoTo BadRow
            If Not item.Exists(KEY_SORT) Then
                Set SortActiveDefinitions = BadSortOrder(variableName)
                Exit Function
            End If
            If Not TrySortKey(item(KEY_SORT), sortKey) Then
                Set SortActiveDefinitions = BadSortOrder(variableName)
                Exit Function
            End If
            If Not item.Exists(KEY_ROW) Then GoTo BadRow
            If Not TryRowIndex(item(KEY_ROW), rowIndex) Then GoTo BadRow
            If seenRowNumbers.Exists(CStr(rowIndex)) Then GoTo BadRow
            seenRowNumbers.Add CStr(rowIndex), True

            inserted = False
            For position = 1 To sortedCandidate.Count
                Set priorItem = sortedCandidate(position)
                ' Every prior item was checked before it was inserted.
                priorSortKey = CDbl(priorItem(KEY_SORT))
                priorIndex = CLng(priorItem(KEY_ROW))
                If sortKey < priorSortKey Or _
                   (sortKey = priorSortKey And rowIndex < priorIndex) Then
                    insertionPoint = position
                    sortedCandidate.Add item, Before:=insertionPoint
                    inserted = True
                    Exit For
                End If
            Next position
            If Not inserted Then sortedCandidate.Add item
        Else
            GoTo BadRow
        End If
    Next rowValue

    Set sortedDefinitions = sortedCandidate
    Set SortActiveDefinitions = CreateSuccessResult()
    Exit Function

BadRow:
    Set SortActiveDefinitions = BrokenCarrier("VariableDefinitions.__RowIndex")
    Exit Function

UnexpectedFailure:
    Set sortedDefinitions = Nothing
    Set SortActiveDefinitions = BrokenCarrier("VariableDefinitions.Sort")
End Function

Private Function TrySortKey( _
    ByVal rawValue As Variant, _
    ByRef sortKey As Double _
) As Boolean
    On Error GoTo InvalidValue
    If IsError(rawValue) Then Exit Function
    If IsNull(rawValue) Then Exit Function
    If IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Then Exit Function
    If IsArray(rawValue) Then Exit Function
    If VarType(rawValue) = vbBoolean Then Exit Function
    If Len(Trim$(CStr(rawValue))) = 0 Then Exit Function
    If Not IsNumeric(rawValue) Then Exit Function
    ' IsNumeric alone does not prove CDbl will not Overflow.
    sortKey = CDbl(rawValue)
    TrySortKey = True
    Exit Function
InvalidValue:
    TrySortKey = False
End Function

Private Function TryRowIndex( _
    ByVal rawValue As Variant, _
    ByRef rowIndex As Long _
) As Boolean
    Dim numericValue As Double
    On Error GoTo InvalidValue
    If IsError(rawValue) Then Exit Function
    If IsNull(rawValue) Then Exit Function
    If IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Then Exit Function
    If IsArray(rawValue) Then Exit Function
    If VarType(rawValue) = vbBoolean Then Exit Function
    If Not IsNumeric(rawValue) Then Exit Function
    numericValue = CDbl(rawValue)
    If numericValue < 1# Or numericValue > 2147483647# Then Exit Function
    If numericValue <> Fix(numericValue) Then Exit Function
    rowIndex = CLng(numericValue)
    TryRowIndex = True
    Exit Function
InvalidValue:
    TryRowIndex = False
End Function

Private Function TryScalarText( _
    ByVal rawValue As Variant, _
    ByRef textValue As String _
) As Boolean
    On Error GoTo InvalidValue
    textValue = vbNullString
    If IsError(rawValue) Then Exit Function
    If IsNull(rawValue) Then Exit Function
    If IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Then Exit Function
    If IsArray(rawValue) Then Exit Function
    textValue = CStr(rawValue)
    TryScalarText = True
    Exit Function
InvalidValue:
    TryScalarText = False
End Function

Private Function BadSortOrder( _
    ByVal variableName As String _
) As COperationResult
    Set BadSortOrder = CreateFailureResult( _
        ERROR_CONFIGURATION, _
        "SortOrder cannot be converted to a numeric sort key.", _
        variableName & ".SortOrder")
End Function

Private Function BrokenCarrier( _
    ByVal target As String _
) As COperationResult
    Set BrokenCarrier = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Validated configuration snapshot is missing or malformed.", _
        target)
End Function
