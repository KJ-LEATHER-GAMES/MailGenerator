Attribute VB_Name = "modP1_06MinimalUnresolvedCheckerIntegrationTest"
Option Explicit

Private Const TEMPLATE_PATH_KEY As String = "TemplatePath"

Public Sub TestP106MinimalUnresolvedCheckerIntegration()

    Dim normalPassed As Boolean
    Dim missingPassed As Boolean

    Debug.Print "========================================"
    Debug.Print "P1-06 Minimal Unresolved Checker Integration"
    Debug.Print "START"
    Debug.Print "========================================"

    normalPassed = RunP106Integration(False)
    missingPassed = RunP106Integration(True)

    Debug.Print "----------------------------------------"

    If normalPassed And missingPassed Then
        Debug.Print "TestP106MinimalUnresolvedCheckerIntegration: PASS"
    Else
        Debug.Print "TestP106MinimalUnresolvedCheckerIntegration: FAIL"
    End If

End Sub

Public Sub TestP106UnresolvedZeroIntegration()
    Call RunP106Integration(False)
End Sub

Public Sub TestP106MissingValueIntegration()
    Call RunP106Integration(True)
End Sub

Private Function RunP106Integration( _
    ByVal omitGateDate As Boolean _
) As Boolean

    Dim result As COperationResult
    Dim closeResult As COperationResult

    Dim templatePath As String
    Dim resolvedPath As String

    Dim subjectText As String
    Dim bodyText As String
    Dim renderedSubject As String
    Dim postSubject As String
    Dim postBodyText As String

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    Dim formattedValues As Object
    Dim unresolvedResult As Object
    Dim unresolvedVariables As Collection

    Dim testName As String
    Dim passed As Boolean
    Dim mailCreated As Boolean

    passed = False
    mailCreated = False

    If omitGateDate Then
        testName = "Missing Value Integration"
    Else
        testName = "Normal Integration"
    End If

    Debug.Print "----------------------------------------"
    Debug.Print testName & ": START"

    On Error GoTo UnexpectedError

    Set result = GetSettingValue( _
        TEMPLATE_PATH_KEY, _
        templatePath)

    If Not result.Success Then
        PrintFailure "GetSettingValue", result
        GoTo Cleanup
    End If

    Debug.Print "  TemplatePath=" & templatePath

    Set result = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedPath)

    If Not result.Success Then
        PrintFailure "ResolveWorkbookRelativePath", result
        GoTo Cleanup
    End If

    Debug.Print "  ResolvedPath=" & resolvedPath

    Set result = CreateMailFromTemplate(resolvedPath)

    If Not result.Success Then
        PrintFailure "CreateMailFromTemplate", result
        GoTo Cleanup
    End If

    mailCreated = True

    Set result = ReadSubject(subjectText)

    If Not result.Success Then
        PrintFailure "ReadSubject(pre)", result
        GoTo Cleanup
    End If

    Set result = ReadBodyText(bodyText)

    If Not result.Success Then
        PrintFailure "ReadBodyText(pre)", result
        GoTo Cleanup
    End If

    Debug.Print "  Subject Length(pre)=" & CStr(Len(subjectText))
    Debug.Print "  Body Length(pre)   =" & CStr(Len(bodyText))

    Set result = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If Not result.Success Then
        PrintFailure "ScanTemplate", result
        GoTo Cleanup
    End If

    If scanResult Is Nothing Then
        Debug.Print "  FAIL: scanResult is Nothing."
        GoTo Cleanup
    End If

    Set validVariables = scanResult("ValidVariables")
    Set invalidCandidates = scanResult("InvalidCandidates")

    Debug.Print "  ValidVariables.Count   =" & CStr(validVariables.Count)
    Debug.Print "  InvalidCandidates.Count=" & CStr(invalidCandidates.Count)

    If invalidCandidates.Count <> 0 Then
        Debug.Print "  FAIL: InvalidCandidates must be 0 for P1-06 fixture."
        GoTo Cleanup
    End If

    If Not ContainsVariable(validVariables, "ModelName") Or _
       Not ContainsVariable(validVariables, "GateDate") Or _
       Not ContainsVariable(validVariables, "Department") Or _
       Not ContainsVariable(validVariables, "Comment") Then

        Debug.Print "  FAIL: Expected baseline variables were not all detected."
        GoTo Cleanup
    End If

    Set formattedValues = CreateObject("Scripting.Dictionary")
    formattedValues.CompareMode = vbTextCompare

    formattedValues.Add "ModelName", "ABC123"

    If Not omitGateDate Then
        formattedValues.Add "GateDate", "2026/09/30"
    End If

    formattedValues.Add "Department", "•iŽ¿•”"
    formattedValues.Add "Comment", "Šm”F‚¨Šè‚¢‚µ‚Ü‚·"

    Set result = RenderSubject( _
        subjectText, _
        formattedValues, _
        renderedSubject)

    If Not result.Success Then
        PrintFailure "RenderSubject", result
        GoTo Cleanup
    End If

    Set result = SetSubject(renderedSubject)

    If Not result.Success Then
        PrintFailure "SetSubject", result
        GoTo Cleanup
    End If

    Set result = ReplaceBodyVariables(formattedValues)

    If Not result.Success Then
        PrintFailure "ReplaceBodyVariables", result
        GoTo Cleanup
    End If

    Set result = ReadSubject(postSubject)

    If Not result.Success Then
        PrintFailure "ReadSubject(post)", result
        GoTo Cleanup
    End If

    Set result = ReadBodyText(postBodyText)

    If Not result.Success Then
        PrintFailure "ReadBodyText(post)", result
        GoTo Cleanup
    End If

    Debug.Print "  Subject(post)=" & postSubject
    Debug.Print "  Body Length(post)=" & CStr(Len(postBodyText))

    Set result = CheckUnresolved( _
        postSubject, _
        postBodyText, _
        unresolvedResult)

    If unresolvedResult Is Nothing Then
        Debug.Print "  FAIL: unresolvedResult is Nothing."
        PrintFailure "CheckUnresolved", result
        GoTo Cleanup
    End If

    Set unresolvedVariables = unresolvedResult("Variables")

    Debug.Print "  HasUnresolved=" & _
        CStr(CBool(unresolvedResult("HasUnresolved")))
    Debug.Print "  Variables.Count=" & _
        CStr(unresolvedVariables.Count)

    PrintVariables unresolvedVariables

    If omitGateDate Then

        If result.Success Then
            Debug.Print "  FAIL: Missing GateDate must return Failure Result."
            GoTo Cleanup
        End If

        If Not CBool(unresolvedResult("HasUnresolved")) Then
            Debug.Print "  FAIL: HasUnresolved must be True."
            GoTo Cleanup
        End If

        If unresolvedVariables.Count <> 1 Then
            Debug.Print "  FAIL: Expected exactly one logical unresolved variable."
            GoTo Cleanup
        End If

        If Not CollectionContainsText( _
            unresolvedVariables, _
            "GateDate") Then

            Debug.Print "  FAIL: GateDate was not detected."
            GoTo Cleanup
        End If

    Else

        If Not result.Success Then
            PrintFailure "CheckUnresolved(normal)", result
            GoTo Cleanup
        End If

        If CBool(unresolvedResult("HasUnresolved")) Then
            Debug.Print "  FAIL: HasUnresolved must be False."
            GoTo Cleanup
        End If

        If unresolvedVariables.Count <> 0 Then
            Debug.Print "  FAIL: Variables.Count must be 0."
            GoTo Cleanup
        End If

    End If

    passed = True

Cleanup:

    If mailCreated Then

        Set closeResult = CloseWithoutSave()

        If closeResult Is Nothing Then
            Debug.Print "  CloseWithoutSave: FAIL (Result is Nothing)"
            passed = False
        ElseIf Not closeResult.Success Then
            Debug.Print "  CloseWithoutSave: FAIL"
            PrintFailure "CloseWithoutSave", closeResult
            passed = False
        Else
            Debug.Print "  CloseWithoutSave: PASS"
        End If

    End If

    If passed Then
        Debug.Print testName & ": PASS"
    Else
        Debug.Print testName & ": FAIL"
    End If

    RunP106Integration = passed
    Exit Function

UnexpectedError:
    Debug.Print "  Unexpected Test Harness Error:"
    Debug.Print "    " & CStr(Err.Number) & " - " & Err.Description
    passed = False
    Resume Cleanup

End Function

Private Function ContainsVariable( _
    ByVal variables As Collection, _
    ByVal expectedName As String _
) As Boolean

    ContainsVariable = CollectionContainsText( _
        variables, _
        expectedName)

End Function

Private Function CollectionContainsText( _
    ByVal items As Collection, _
    ByVal expectedText As String _
) As Boolean

    Dim i As Long

    For i = 1 To items.Count

        If StrComp( _
            CStr(items(i)), _
            expectedText, _
            vbTextCompare) = 0 Then

            CollectionContainsText = True
            Exit Function
        End If

    Next i

    CollectionContainsText = False

End Function

Private Sub PrintVariables(ByVal variables As Collection)

    Dim i As Long

    For i = 1 To variables.Count
        Debug.Print "    Variable[" & CStr(i) & "]=" & _
            CStr(variables(i))
    Next i

End Sub

Private Sub PrintFailure( _
    ByVal context As String, _
    ByVal result As COperationResult _
)

    Dim errorInfo As CErrorInfo
    Dim i As Long

    Debug.Print "  FAIL: " & context

    If result Is Nothing Then
        Debug.Print "    Result is Nothing."
        Exit Sub
    End If

    Debug.Print "    Success=" & CStr(result.Success)

    For i = 1 To result.Errors.Count

        Set errorInfo = result.Errors(i)

        Debug.Print "    Error[" & CStr(i) & "]"
        Debug.Print "      Type   =" & errorInfo.ErrorType
        Debug.Print "      Message=" & errorInfo.Message
        Debug.Print "      Target =" & errorInfo.Target

    Next i

End Sub
