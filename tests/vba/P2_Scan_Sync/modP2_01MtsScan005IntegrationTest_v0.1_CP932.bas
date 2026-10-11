Attribute VB_Name = "modP2_01MtsScan005IntegrationTest"
Option Explicit

Private Const TEST_TEMPLATE_PATH As String = "Templates\\MailTemplate_MTS-SCAN-005.oft"

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Private Const VAR_SUBJECT As String = "ModelName"
Private Const VAR_BODY As String = "Department"
Private Const VAR_TO As String = "RecipientTo"
Private Const VAR_CC As String = "RecipientCc"
Private Const VAR_BCC As String = "RecipientBcc"

Public Sub TestP201MtsScan005RecipientExclusionIntegration()

    Dim result As COperationResult
    Dim resolvedPath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    Dim mailCreated As Boolean
    Dim overallPass As Boolean
    Dim cleanupPass As Boolean

    overallPass = False
    cleanupPass = True

    Debug.Print String$(76, "=")
    Debug.Print "P2-01 MTS-SCAN-005 Recipient Exclusion Integration Verification"
    Debug.Print String$(76, "=")
    Debug.Print "Test Fixture: " & TEST_TEMPLATE_PATH
    Debug.Print "Fixture Precondition:"
    Debug.Print "  Subject contains {{" & VAR_SUBJECT & "}}"
    Debug.Print "  Body contains {{" & VAR_BODY & "}}"
    Debug.Print "  To contains {{" & VAR_TO & "}}"
    Debug.Print "  CC contains {{" & VAR_CC & "}}"
    Debug.Print "  BCC contains {{" & VAR_BCC & "}}"

    On Error GoTo RuntimeError

    Set result = ResolveWorkbookRelativePath(TEST_TEMPLATE_PATH, resolvedPath)
    If Not ResultSucceeded(result, "ResolveWorkbookRelativePath") Then GoTo CleanUp
    Debug.Print "ResolvedPath: " & resolvedPath

    Set result = CreateMailFromTemplate(resolvedPath)
    If Not ResultSucceeded(result, "CreateMailFromTemplate") Then GoTo CleanUp
    mailCreated = True

    Set result = ReadSubject(subjectText)
    If Not ResultSucceeded(result, "ReadSubject") Then GoTo CleanUp
    Debug.Print "Subject Snapshot: " & subjectText

    Set result = ReadBodyText(bodyText)
    If Not ResultSucceeded(result, "ReadBodyText") Then GoTo CleanUp
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))

    If InStr(1, subjectText, "{{" & VAR_SUBJECT & "}}", vbBinaryCompare) = 0 Then
        Debug.Print "Fixture Subject Precondition: FAIL - Expected {{" & VAR_SUBJECT & "}}."
        GoTo CleanUp
    End If
    Debug.Print "Fixture Subject Precondition: PASS"

    If InStr(1, bodyText, "{{" & VAR_BODY & "}}", vbBinaryCompare) = 0 Then
        Debug.Print "Fixture Body Precondition: FAIL - Expected {{" & VAR_BODY & "}}."
        GoTo CleanUp
    End If
    Debug.Print "Fixture Body Precondition: PASS"

    Set result = ScanTemplate(subjectText, bodyText, scanResult)
    If Not ResultSucceeded(result, "ScanTemplate") Then GoTo CleanUp

    If Not TryGetScanResultParts(scanResult, validVariables, invalidCandidates, locations) Then GoTo CleanUp

    Debug.Print "ValidVariables Count: " & CStr(validVariables.Count)
    PrintCollection "ValidVariables", validVariables
    Debug.Print "InvalidCandidates Count: " & CStr(invalidCandidates.Count)
    PrintCollection "InvalidCandidates", invalidCandidates
    Debug.Print "Locations Count: " & CStr(locations.Count)
    PrintLocations locations

    If Not CollectionEquals(validVariables, Array(VAR_SUBJECT, VAR_BODY)) Then
        Debug.Print "Subject / Body Scan Target: FAIL"
        GoTo CleanUp
    End If
    Debug.Print "Subject / Body Scan Target: PASS"

    If Not LocationEquals(locations, VAR_SUBJECT, "Subject") Then
        Debug.Print VAR_SUBJECT & " Location: FAIL - Expected Subject."
        GoTo CleanUp
    End If
    Debug.Print VAR_SUBJECT & " Location: PASS / Subject"

    If Not LocationEquals(locations, VAR_BODY, "Body") Then
        Debug.Print VAR_BODY & " Location: FAIL - Expected Body."
        GoTo CleanUp
    End If
    Debug.Print VAR_BODY & " Location: PASS / Body"

    If CollectionContainsText(validVariables, VAR_TO) Or locations.Exists(VAR_TO) Then
        Debug.Print "To Exclusion: FAIL - " & VAR_TO & " was detected."
        GoTo CleanUp
    End If
    Debug.Print "To Exclusion: PASS / " & VAR_TO & " not detected"

    If CollectionContainsText(validVariables, VAR_CC) Or locations.Exists(VAR_CC) Then
        Debug.Print "CC Exclusion: FAIL - " & VAR_CC & " was detected."
        GoTo CleanUp
    End If
    Debug.Print "CC Exclusion: PASS / " & VAR_CC & " not detected"

    If CollectionContainsText(validVariables, VAR_BCC) Or locations.Exists(VAR_BCC) Then
        Debug.Print "BCC Exclusion: FAIL - " & VAR_BCC & " was detected."
        GoTo CleanUp
    End If
    Debug.Print "BCC Exclusion: PASS / " & VAR_BCC & " not detected"

    If invalidCandidates.Count <> 0 Then
        Debug.Print "InvalidCandidates: FAIL - Expected 0."
        GoTo CleanUp
    End If
    Debug.Print "InvalidCandidates: PASS / 0"

    If locations.compareMode <> vbTextCompare Then
        Debug.Print "Locations CompareMode: FAIL - Expected vbTextCompare."
        GoTo CleanUp
    End If
    Debug.Print "Locations CompareMode: PASS"

    If Not ValidateStructuralInvariant(validVariables, invalidCandidates, locations) Then
        Debug.Print "TemplateScanResult Structural Invariant: FAIL"
        GoTo CleanUp
    End If
    Debug.Print "TemplateScanResult Structural Invariant: PASS"

    overallPass = True

CleanUp:
    If mailCreated Then
        Set result = CloseWithoutSave()

        If result Is Nothing Then
            Debug.Print "CloseWithoutSave: FAIL - OperationResult is Nothing."
            cleanupPass = False
        ElseIf Not result.Success Then
            Debug.Print "CloseWithoutSave: FAIL"
            cleanupPass = False
        Else
            Debug.Print "CloseWithoutSave: PASS"
        End If
    Else
        Debug.Print "CloseWithoutSave: NOT REQUIRED"
    End If

    Debug.Print String$(76, "-")

    If overallPass And cleanupPass Then
        Debug.Print "TestP201MtsScan005RecipientExclusionIntegration: PASS"
    Else
        Debug.Print "TestP201MtsScan005RecipientExclusionIntegration: FAIL"
    End If

    Debug.Print String$(76, "=")
    Exit Sub

RuntimeError:
    Debug.Print "Integration Test Runtime Error " & CStr(Err.Number) & ": " & Err.Description
    overallPass = False
    Resume CleanUp

End Sub

Private Function ResultSucceeded(ByVal result As COperationResult, ByVal stageName As String) As Boolean

    If result Is Nothing Then
        Debug.Print stageName & ": FAIL - OperationResult is Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print stageName & ": FAIL"
        Exit Function
    End If

    Debug.Print stageName & ": PASS"
    ResultSucceeded = True

End Function

Private Function TryGetScanResultParts( _
    ByVal scanResult As Object, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef locations As Object _
) As Boolean

    Set validVariables = Nothing
    Set invalidCandidates = Nothing
    Set locations = Nothing

    If scanResult Is Nothing Then
        Debug.Print "TemplateScanResult: FAIL - scanResult is Nothing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_VALID_VARIABLES) Then
        Debug.Print "TemplateScanResult: FAIL - ValidVariables key missing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Debug.Print "TemplateScanResult: FAIL - InvalidCandidates key missing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_LOCATIONS) Then
        Debug.Print "TemplateScanResult: FAIL - Locations key missing."
        Exit Function
    End If

    Set validVariables = scanResult(KEY_VALID_VARIABLES)
    Set invalidCandidates = scanResult(KEY_INVALID_CANDIDATES)
    Set locations = scanResult(KEY_LOCATIONS)

    If validVariables Is Nothing Then Exit Function
    If invalidCandidates Is Nothing Then Exit Function
    If locations Is Nothing Then Exit Function

    TryGetScanResultParts = True

End Function

Private Function CollectionEquals(ByVal actual As Collection, ByVal expectedValues As Variant) As Boolean

    Dim expectedCount As Long
    Dim i As Long

    If actual Is Nothing Then Exit Function

    expectedCount = UBound(expectedValues) - LBound(expectedValues) + 1
    If actual.Count <> expectedCount Then Exit Function

    For i = 1 To actual.Count
        If StrComp(CStr(actual(i)), CStr(expectedValues(LBound(expectedValues) + i - 1)), vbBinaryCompare) <> 0 Then
            Exit Function
        End If
    Next i

    CollectionEquals = True

End Function

Private Function CollectionContainsText(ByVal items As Collection, ByVal expectedText As String) As Boolean

    Dim item As Variant

    If items Is Nothing Then Exit Function

    For Each item In items
        If StrComp(CStr(item), expectedText, vbTextCompare) = 0 Then
            CollectionContainsText = True
            Exit Function
        End If
    Next item

End Function

Private Function LocationEquals(ByVal locations As Object, ByVal variableName As String, ByVal expectedLocation As String) As Boolean

    If locations Is Nothing Then Exit Function
    If Not locations.Exists(variableName) Then Exit Function

    LocationEquals = (StrComp(CStr(locations(variableName)), expectedLocation, vbBinaryCompare) = 0)

End Function

Private Function ValidateStructuralInvariant( _
    ByVal validVariables As Collection, _
    ByVal invalidCandidates As Collection, _
    ByVal locations As Object _
) As Boolean

    Dim validSet As Object
    Dim item As Variant
    Dim key As Variant
    Dim rawCandidate As String
    Dim innerText As String

    If validVariables Is Nothing Then Exit Function
    If invalidCandidates Is Nothing Then Exit Function
    If locations Is Nothing Then Exit Function
    If validVariables.Count <> locations.Count Then Exit Function

    Set validSet = CreateObject("Scripting.Dictionary")
    validSet.compareMode = vbTextCompare

    For Each item In validVariables
        If Not locations.Exists(CStr(item)) Then Exit Function
        If validSet.Exists(CStr(item)) Then Exit Function
        validSet.Add CStr(item), True
    Next item

    For Each key In locations.Keys
        If Not validSet.Exists(CStr(key)) Then Exit Function
    Next key

    For Each item In invalidCandidates
        rawCandidate = CStr(item)

        If Len(rawCandidate) >= 4 Then
            innerText = Mid$(rawCandidate, 3, Len(rawCandidate) - 4)
            If locations.Exists(innerText) Then Exit Function
        End If
    Next item

    ValidateStructuralInvariant = True

End Function

Private Sub PrintCollection(ByVal label As String, ByVal items As Collection)

    Dim i As Long

    If items Is Nothing Then
        Debug.Print label & ": <Nothing>"
        Exit Sub
    End If

    If items.Count = 0 Then
        Debug.Print label & ": <empty>"
        Exit Sub
    End If

    For i = 1 To items.Count
        Debug.Print "  " & label & "[" & CStr(i) & "] = " & CStr(items(i))
    Next i

End Sub

Private Sub PrintLocations(ByVal locations As Object)

    Dim key As Variant

    If locations Is Nothing Then
        Debug.Print "Locations: <Nothing>"
        Exit Sub
    End If

    If locations.Count = 0 Then
        Debug.Print "Locations: <empty>"
        Exit Sub
    End If

    For Each key In locations.Keys
        Debug.Print "  Location[" & CStr(key) & "] = " & CStr(locations(key))
    Next key

End Sub
