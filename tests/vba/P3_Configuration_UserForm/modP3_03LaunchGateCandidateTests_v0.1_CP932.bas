Attribute VB_Name = "modP3_03LaunchGateCandidateTests"
Option Explicit

' NOT RUN / NOT FORMAL. Stub-based gate contract only; no Excel/Outlook calls.
' Import into an APPROVED isolated test workbook only:
' modP3UserFormLaunchGate, modP3_03GateTestStub, modResult,
' COperationResult, CErrorInfo, this runner.
' NEVER import real modConfigurationApplication together with this stub.

Private mPass As Long
Private mFail As Long

Public Sub RunP3_03LaunchGateCandidateTests()
    Dim caseId As Long
    mPass = 0
    mFail = 0
    Debug.Print "P3-03 UserForm launch gate LOCAL fixture (NOT FORMAL)"
    For caseId = 1 To 21
        RunCase caseId
    Next caseId
    Debug.Print "P3-03: PASS=" & CStr(mPass) & "; FAIL=" & CStr(mFail)
End Sub

Private Sub RunCase(ByVal caseId As Long)
    Dim sorted As Collection
    Dim groups As Object
    Dim result As COperationResult
    Dim upstreamResult As COperationResult
    Dim errors As Collection
    Dim info As CErrorInfo
    Dim expectedNames As String
    Dim expectedType As String
    Dim expectedTarget As String
    Dim isSuccess As Boolean
    Dim isOkay As Boolean
    Dim labelText As String
    Dim beforeOrder As String

    On Error GoTo FixtureFailure
    labelText = "DEV-P3GATE-" & Format$(caseId, "00")
    P3GateStubReset caseId
    Set sorted = Nothing
    Set groups = Nothing

    Set result = PrepareUserFormLaunch(sorted, groups)

    expectedNames = vbNullString
    expectedType = "UnexpectedError"
    expectedTarget = vbNullString
    Select Case caseId
        Case 1, 18
            expectedNames = "First|Middle|Late"
        Case 2
            expectedNames = "FirstRow|SecondRow|ThirdRow"
        Case 3
            expectedNames = "Minus|Fraction|TextNumber"
        Case 4
            expectedNames = "Used"
        Case 5
            expectedNames = vbNullString
        Case 14, 15
            expectedType = "ConfigurationError"
        Case 21
            expectedNames = "Small|Large"
        Case 6
            expectedType = "ConfigurationError"
            expectedTarget = "StubUpstream"
        Case 7 To 17, 19, 20
            ' These are all Fail Closed, except the selected success IDs above.
    End Select
    isSuccess = (caseId = 1 Or caseId = 2 Or caseId = 3 Or _
                 caseId = 4 Or caseId = 5 Or caseId = 18 Or caseId = 21)

    isOkay = (Not result Is Nothing)
    If isOkay Then
        isOkay = (result.Success = isSuccess)
        Set errors = result.Errors
        If isSuccess Then
            isOkay = isOkay And (errors.Count = 0)
        Else
            isOkay = isOkay And (errors.Count >= 1)
            If errors.Count > 0 Then
                Set info = errors(1)
                isOkay = isOkay And (info.ErrorType = expectedType)
                If Len(expectedTarget) > 0 Then
                    isOkay = isOkay And (info.Target = expectedTarget)
                End If
            End If
        End If
    End If

    If isSuccess Then
        isOkay = isOkay And (Not sorted Is Nothing)
        isOkay = isOkay And (Not groups Is Nothing)
        If Not sorted Is Nothing Then
            isOkay = isOkay And (JoinNames(sorted) = expectedNames)
        End If
    Else
        isOkay = isOkay And (sorted Is Nothing)
        isOkay = isOkay And (groups Is Nothing)
    End If

    isOkay = isOkay And (P3GateStubCalls() = 1)
    If caseId = 6 Then
        Set upstreamResult = P3GateStubResult()
        isOkay = isOkay And (result Is upstreamResult)
    End If
    If caseId = 1 Or caseId = 2 Or caseId = 18 Then
        ' The original getter Collection order is retained.
        Dim original As Collection
        Set original = P3GateStubSource()
        If caseId = 2 Then
            isOkay = isOkay And (JoinNames(original) = _
                "ThirdRow|FirstRow|SecondRow")
        Else
            isOkay = isOkay And (JoinNames(original) = _
                "Late|First|Middle")
        End If
    End If
    If caseId = 18 Then
        ' Two independent calls; no cross-run cached sorted state.
        Dim sortedAgain As Collection
        Dim optionsAgain As Object
        Dim resultAgain As COperationResult
        Set resultAgain = PrepareUserFormLaunch(sortedAgain, optionsAgain)
        If resultAgain Is Nothing Then
            isOkay = False
        Else
            isOkay = isOkay And resultAgain.Success
            If Not sortedAgain Is Nothing Then
                isOkay = isOkay And (JoinNames(sortedAgain) = expectedNames)
            Else
                isOkay = False
            End If
        End If
        isOkay = isOkay And (P3GateStubCalls() = 2)
    End If

    If isOkay Then
        mPass = mPass + 1
        Debug.Print "PASS " & labelText
    Else
        mFail = mFail + 1
        Debug.Print "FAIL " & labelText
    End If
    Exit Sub
FixtureFailure:
    mFail = mFail + 1
    Debug.Print "FAIL " & labelText & " runtime " & _
        CStr(Err.Number) & ": " & Err.Description
End Sub

Private Function JoinNames(ByVal items As Collection) As String
    Dim position As Long
    Dim value As String
    Dim item As Object
    For position = 1 To items.Count
        Set item = items(position)
        If position > 1 Then value = value & "|"
        value = value & CStr(item("VariableName"))
    Next position
    JoinNames = value
End Function
