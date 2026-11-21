Attribute VB_Name = "modP3_03GateTestStub"
Option Explicit

' ISOLATED VBA TEST WORKBOOK ONLY, NEVER WITH REAL modConfigurationApplication.
' The stub has the same Public PrepareCurrentConfiguration symbol as P3-02.
' Do not import this stub and P3-02 application into the same VBA project.

Private mScenario As Long
Private mCalls As Long
Private mSource As Collection
Private mLastResult As COperationResult

Public Sub P3GateStubReset(ByVal scenarioId As Long)
    mScenario = scenarioId
    mCalls = 0
    Set mSource = Nothing
    Set mLastResult = Nothing
End Sub

Public Function P3GateStubCalls() As Long
    P3GateStubCalls = mCalls
End Function

Public Function P3GateStubSource() As Collection
    Set P3GateStubSource = mSource
End Function

Public Function P3GateStubResult() As COperationResult
    Set P3GateStubResult = mLastResult
End Function

Public Function PrepareCurrentConfiguration( _
    ByRef templateScanResult As Object, _
    ByRef allVariableDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult

    Dim groupSnapshot As Object
    Dim originalRows As Collection
    Dim item As Object

    mCalls = mCalls + 1
    Set templateScanResult = Nothing
    Set allVariableDefinitions = Nothing
    Set activeOptionsByGroup = Nothing
    Set mSource = Nothing

    If mScenario = 6 Then
        Set mLastResult = CreateFailureResult( _
            "ConfigurationError", "Upstream validation failed.", "StubUpstream")
        Set PrepareCurrentConfiguration = mLastResult
        Exit Function
    End If
    If mScenario = 7 Then
        Set mLastResult = Nothing
        Set PrepareCurrentConfiguration = Nothing
        Exit Function
    End If
    If mScenario = 19 Then
        Err.Raise vbObjectError + 337, "P3GateStub", "Injected exception"
    End If

    If mScenario <> 10 Then
        Set templateScanResult = CreateObject("Scripting.Dictionary")
    End If
    If mScenario <> 9 Then
        If mScenario = 11 Then
            Set activeOptionsByGroup = New Collection
        Else
            Set groupSnapshot = CreateObject("Scripting.Dictionary")
            groupSnapshot.CompareMode = vbBinaryCompare
            Set activeOptionsByGroup = groupSnapshot
        End If
    End If

    If mScenario <> 8 Then
        Set originalRows = New Collection
        Select Case mScenario
            Case 1, 18
                originalRows.Add Row("Late", 30, 3, "Active")
                originalRows.Add Row("First", 10, 1, "Active")
                originalRows.Add Row("Middle", 20, 2, "Active")
            Case 2
                originalRows.Add Row("ThirdRow", 20, 3, "Active")
                originalRows.Add Row("FirstRow", 20, 1, "Active")
                originalRows.Add Row("SecondRow", 20, 2, "Active")
            Case 3
                originalRows.Add Row("Minus", -5, 1, "Active")
                originalRows.Add Row("Fraction", 1.25, 2, "Active")
                originalRows.Add Row("TextNumber", "2.5", 3, "Active")
            Case 4
                originalRows.Add Row("Used", 10, 2, "Active")
                originalRows.Add Row("Old", 0, 1, "Unused")
            Case 5
                originalRows.Add Row("Old", 10, 1, "Unused")
            Case 12
                Set item = Row("MissingRow", 10, 1, "Active")
                item.Remove "__RowIndex"
                originalRows.Add item
            Case 13
                originalRows.Add Row("One", 10, 1, "Active")
                originalRows.Add Row("Other", 20, 1, "Active")
            Case 14
                originalRows.Add Row("BadNumber", "NotANumber", 1, "Active")
            Case 15
                originalRows.Add Row("BigNumber", "1E9999", 1, "Active")
            Case 16
                originalRows.Add Row("BooleanRow", 1, True, "Active")
            Case 17
                originalRows.Add Row("FractionRow", 1, 1.5, "Active")
            Case 20
                originalRows.Add Row("OutOfRange", 1, 2147483648#, "Active")
            Case 21
                originalRows.Add Row("Large", "1E308", 2, "Active")
                originalRows.Add Row("Small", "1E307", 1, "Active")
            Case Else
                originalRows.Add Row("Only", 10, 1, "Active")
        End Select
        Set mSource = originalRows
        Set allVariableDefinitions = originalRows
    End If

    Set mLastResult = CreateSuccessResult()
    Set PrepareCurrentConfiguration = mLastResult
End Function

Private Function Row( _
    ByVal variableName As String, _
    ByVal sortValue As Variant, _
    ByVal rowValue As Variant, _
    ByVal statusValue As String _
) As Object
    Dim record As Object
    Set record = CreateObject("Scripting.Dictionary")
    record.CompareMode = vbTextCompare
    record.Add "VariableName", variableName
    record.Add "Status", statusValue
    record.Add "SortOrder", sortValue
    record.Add "__RowIndex", rowValue
    Set Row = record
End Function
