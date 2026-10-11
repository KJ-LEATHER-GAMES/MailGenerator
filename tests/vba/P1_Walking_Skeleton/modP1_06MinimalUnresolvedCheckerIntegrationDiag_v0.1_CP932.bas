Attribute VB_Name = "modP1_06MinimalUnresolvedCheckerIntegrationDiag"
Option Explicit

Private Const TEMPLATE_PATH_KEY As String = "TemplatePath"

Public Sub TestP106UnresolvedZeroIntegrationDiagnostic()

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

    Dim passed As Boolean
    Dim mailCreated As Boolean

    passed = False
    mailCreated = False

    Debug.Print "========================================"
    Debug.Print "P1-06 Unresolved Zero Integration DIAGNOSTIC"
    Debug.Print "START"
    Debug.Print "========================================"

    On Error GoTo UnexpectedError

    Set result = GetSettingValue(TEMPLATE_PATH_KEY, templatePath)

    If Not result.Success Then
        PrintFailure "GetSettingValue", result
        GoTo Cleanup
    End If

    Debug.Print "  TemplatePath=" & templatePath

    Set result = ResolveWorkbookRelativePath(templatePath, resolvedPath)

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

    Set result = ScanTemplate(subjectText, bodyText, scanResult)

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
        Debug.Print "  FAIL: InvalidCandidates must be 0."
        GoTo Cleanup
    End If

    If Not CollectionContainsText(validVariables, "ModelName") Or _
       Not CollectionContainsText(validVariables, "GateDate") Or _
       Not CollectionContainsText(validVariables, "Department") Or _
       Not CollectionContainsText(validVariables, "Comment") Then

        Debug.Print "  FAIL: Expected baseline variables were not all detected."
        GoTo Cleanup
    End If

    Set formattedValues = CreateObject("Scripting.Dictionary")
    formattedValues.CompareMode = vbTextCompare

    formattedValues.Add "ModelName", "ABC123"
    formattedValues.Add "GateDate", "2026/09/30"
    formattedValues.Add "Department", "品質部"
    formattedValues.Add "Comment", "確認お願いします"

    PrintFormattedValuesDiagnostic formattedValues

    Set result = RenderSubject(subjectText, formattedValues, renderedSubject)

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

    PrintBodyDiagnostic "P1-06 POST BODY", postBodyText

    Set result = CheckUnresolved(postSubject, postBodyText, unresolvedResult)

    If unresolvedResult Is Nothing Then
        Debug.Print "  FAIL: unresolvedResult is Nothing."
        PrintFailure "CheckUnresolved", result
        GoTo Cleanup
    End If

    Set unresolvedVariables = unresolvedResult("Variables")

    Debug.Print "  HasUnresolved=" & CStr(CBool(unresolvedResult("HasUnresolved")))
    Debug.Print "  Variables.Count=" & CStr(unresolvedVariables.Count)

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

    passed = True

Cleanup:

    If mailCreated Then
        Set closeResult = CloseWithoutSave()

        If closeResult Is Nothing Then
            Debug.Print "  CloseWithoutSave: FAIL (Result is Nothing)"
            passed = False
        ElseIf Not closeResult.Success Then
            PrintFailure "CloseWithoutSave", closeResult
            passed = False
        Else
            Debug.Print "  CloseWithoutSave: PASS"
        End If
    End If

    Debug.Print "----------------------------------------"

    If passed Then
        Debug.Print "TestP106UnresolvedZeroIntegrationDiagnostic: PASS"
    Else
        Debug.Print "TestP106UnresolvedZeroIntegrationDiagnostic: FAIL"
    End If

    Exit Sub

UnexpectedError:
    Debug.Print "  Unexpected Test Harness Error:"
    Debug.Print "    " & CStr(Err.Number) & " - " & Err.Description
    passed = False
    Resume Cleanup

End Sub

Private Sub PrintFormattedValuesDiagnostic(ByVal formattedValues As Object)

    Dim key As Variant

    Debug.Print "  ----- FORMATTED VALUES -----"

    For Each key In formattedValues.Keys
        Debug.Print "  " & CStr(key) & " = [" & CStr(formattedValues(key)) & "]" & _
            " / Len=" & CStr(Len(CStr(formattedValues(key))))
    Next key

    Debug.Print "  ----- END FORMATTED VALUES -----"

End Sub

Private Sub PrintBodyDiagnostic( _
    ByVal labelText As String, _
    ByVal bodyText As String _
)

    Debug.Print "  ===== " & labelText & " ====="
    Debug.Print "  Len=" & CStr(Len(bodyText))

    Debug.Print "  Control Counts:"
    Debug.Print "    CR(13)   =" & CStr(CountCharCode(bodyText, 13))
    Debug.Print "    LF(10)   =" & CStr(CountCharCode(bodyText, 10))
    Debug.Print "    TAB(9)   =" & CStr(CountCharCode(bodyText, 9))
    Debug.Print "    CELL(7)  =" & CStr(CountCharCode(bodyText, 7))
    Debug.Print "    VT(11)   =" & CStr(CountCharCode(bodyText, 11))
    Debug.Print "    FF(12)   =" & CStr(CountCharCode(bodyText, 12))

    Debug.Print "  Expected Value Counts:"
    Debug.Print "    ABC123           =" & CStr(CountOccurrences(bodyText, "ABC123", vbTextCompare))
    Debug.Print "    2026/09/30       =" & CStr(CountOccurrences(bodyText, "2026/09/30", vbTextCompare))
    Debug.Print "    品質部             =" & CStr(CountOccurrences(bodyText, "品質部", vbTextCompare))
    Debug.Print "    確認お願いします     =" & CStr(CountOccurrences(bodyText, "確認お願いします", vbTextCompare))

    Debug.Print "  Token Counts:"
    Debug.Print "    {{ModelName}}    =" & CStr(CountOccurrences(bodyText, "{{ModelName}}", vbTextCompare))
    Debug.Print "    {{GateDate}}     =" & CStr(CountOccurrences(bodyText, "{{GateDate}}", vbTextCompare))
    Debug.Print "    {{Department}}   =" & CStr(CountOccurrences(bodyText, "{{Department}}", vbTextCompare))
    Debug.Print "    {{Comment}}      =" & CStr(CountOccurrences(bodyText, "{{Comment}}", vbTextCompare))

    Debug.Print "  ----- BODY RAW START -----"
    Debug.Print bodyText
    Debug.Print "  ----- BODY RAW END -----"

    Debug.Print "  ----- BODY ESCAPED START -----"
    PrintEscapedBody bodyText
    Debug.Print "  ----- BODY ESCAPED END -----"

    Debug.Print "  ===== END " & labelText & " ====="

End Sub

Private Function CountOccurrences( _
    ByVal sourceText As String, _
    ByVal searchText As String, _
    ByVal compareMode As VbCompareMethod _
) As Long

    Dim searchPos As Long
    Dim foundPos As Long
    Dim count As Long

    If Len(searchText) = 0 Then
        CountOccurrences = 0
        Exit Function
    End If

    searchPos = 1

    Do
        foundPos = InStr(searchPos, sourceText, searchText, compareMode)

        If foundPos = 0 Then
            Exit Do
        End If

        count = count + 1
        searchPos = foundPos + Len(searchText)
    Loop

    CountOccurrences = count

End Function

Private Function CountCharCode( _
    ByVal sourceText As String, _
    ByVal targetCode As Long _
) As Long

    Dim i As Long
    Dim count As Long

    For i = 1 To Len(sourceText)
        If AscW(Mid$(sourceText, i, 1)) = targetCode Then
            count = count + 1
        End If
    Next i

    CountCharCode = count

End Function

Private Sub PrintEscapedBody(ByVal bodyText As String)

    Dim i As Long
    Dim currentChar As String
    Dim currentCode As Long
    Dim lineBuffer As String

    lineBuffer = vbNullString

    For i = 1 To Len(bodyText)

        currentChar = Mid$(bodyText, i, 1)
        currentCode = AscW(currentChar)

        Select Case currentCode
            Case 13
                lineBuffer = lineBuffer & "<CR>"
                Debug.Print "    " & lineBuffer
                lineBuffer = vbNullString

            Case 10
                lineBuffer = lineBuffer & "<LF>"
                Debug.Print "    " & lineBuffer
                lineBuffer = vbNullString

            Case 9
                lineBuffer = lineBuffer & "<TAB>"

            Case 7
                lineBuffer = lineBuffer & "<CELL>"

            Case 11
                lineBuffer = lineBuffer & "<VT>"

            Case 12
                lineBuffer = lineBuffer & "<FF>"

            Case Else
                lineBuffer = lineBuffer & currentChar
        End Select

    Next i

    If Len(lineBuffer) > 0 Then
        Debug.Print "    " & lineBuffer
    End If

End Sub

Private Function CollectionContainsText( _
    ByVal items As Collection, _
    ByVal expectedText As String _
) As Boolean

    Dim i As Long

    For i = 1 To items.Count
        If StrComp(CStr(items(i)), expectedText, vbTextCompare) = 0 Then
            CollectionContainsText = True
            Exit Function
        End If
    Next i

    CollectionContainsText = False

End Function

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
