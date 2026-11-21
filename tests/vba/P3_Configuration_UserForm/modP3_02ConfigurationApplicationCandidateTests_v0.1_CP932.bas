Attribute VB_Name = "modP3_02ConfigurationApplicationCandidateTests"
Option Explicit

' NOT RUN. Isolated saved local .xlsm workbook with STUBS ONLY.
' Import: modConfigurationApplication candidate, modConfigurationValidator
' candidate, modResult, COperationResult, CErrorInfo, modP3_02TestStubs.
' DO NOT IMPORT REAL modSettingsData / modOutlookAdapter / etc alongside stubs.

Private mPass As Long
Private mFail As Long

Public Sub RunP3_02ConfigurationApplicationCandidateTests()
    Dim scenarioId As Long
    mPass = 0
    mFail = 0
    Debug.Print "P3-02 Application local contract fixture (NOT FORMAL)"
    For scenarioId = 1 To 23
        RunCase scenarioId
    Next scenarioId
    Debug.Print "P3-02 RESULT PASS=" & mPass & " FAIL=" & mFail
End Sub

Private Sub RunCase(ByVal scenarioId As Long)
    Dim scan As Object
    Dim definitions As Collection
    Dim groups As Object
    Dim result As COperationResult
    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim expectedSuccess As Boolean
    Dim expectedType As String
    Dim expectedTarget As String
    Dim expectedCleanup As Long
    Dim label As String
    Dim okay As Boolean

    On Error GoTo FixtureRuntimeFailure
    label = "DEV-P3APP-" & Format$(scenarioId, "00")
    P3StubReset scenarioId
    Set scan = Nothing
    Set definitions = Nothing
    Set groups = Nothing

    Set result = PrepareCurrentConfiguration(scan, definitions, groups)

    expectedSuccess = (scenarioId = 1 Or scenarioId = 16)
    expectedType = "ConfigurationError"
    Select Case scenarioId
        Case 2, 3, 4, 10, 12, 13, 14, 15, 17, 18, 23
            expectedType = "ConfigurationError"
        Case 5, 6, 7, 9, 22
            expectedType = "OutlookError"
        Case 8
            expectedType = "TemplateError"
        Case 19, 20, 21
            expectedType = "UnexpectedError"
        Case 11
            expectedType = "ConfigurationError"
    End Select

    expectedTarget = vbNullString
    If scenarioId = 22 Then expectedTarget = "StubBodyError"

    expectedCleanup = 1
    If scenarioId = 2 Or scenarioId = 3 Or _
       scenarioId = 4 Or scenarioId = 5 Then
        expectedCleanup = 0
    End If

    okay = (Not result Is Nothing)
    If okay Then
        okay = (result.Success = expectedSuccess)
        Set errors = result.Errors
        If expectedSuccess Then
            okay = okay And (errors.Count = 0)
        Else
            okay = okay And (errors.Count > 0)
            If errors.Count > 0 Then
                Set errorInfo = errors(1)
                okay = okay And (errorInfo.ErrorType = expectedType)
                If Len(expectedTarget) > 0 Then
                    okay = okay And (errorInfo.Target = expectedTarget)
                End If
            End If
        End If
    End If

    If expectedSuccess Then
        okay = okay And (Not scan Is Nothing)
        okay = okay And (Not definitions Is Nothing)
        okay = okay And (Not groups Is Nothing)
    Else
        okay = okay And (scan Is Nothing)
        okay = okay And (definitions Is Nothing)
        okay = okay And (groups Is Nothing)
    End If

    okay = okay And (P3StubCloseCalls() = expectedCleanup)
    If scenarioId = 16 Then okay = okay And (P3StubOptionCalls() = 1)
    If scenarioId = 17 Then okay = okay And (P3StubOptionCalls() = 0)
    If scenarioId = 9 Then okay = okay And (P3StubCloseCalls() = 1)

    If okay Then
        mPass = mPass + 1
        Debug.Print "PASS " & label
    Else
        mFail = mFail + 1
        Debug.Print "FAIL " & label
    End If
    Exit Sub

FixtureRuntimeFailure:
    mFail = mFail + 1
    Debug.Print "FAIL " & label & " runtime: " & Err.Number & " " & Err.Description
End Sub
