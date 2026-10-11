Attribute VB_Name = "modP2_01FullTemplateScannerIntegrationTest"
Option Explicit

Private Const KEY_TEMPLATE_PATH As String = "TemplatePath"

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Public Sub TestP201FullTemplateScannerBaselineOftIntegration()

    Dim result As COperationResult
    Dim templatePath As String
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
    Debug.Print "P2-01 Baseline OFT Integration Verification"
    Debug.Print String$(76, "=")
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path

    On Error GoTo RuntimeError

    ' ------------------------------------------------------------
    ' 1. Settings.TemplatePath
    ' ------------------------------------------------------------
    Set result = GetSettingValue(KEY_TEMPLATE_PATH, templatePath)

    If Not ResultIsSuccess(result, "GetSettingValue(TemplatePath)") Then
        GoTo CleanUp
    End If

    Debug.Print "TemplatePath: " & templatePath

    ' ------------------------------------------------------------
    ' 2. Workbook Relative Path Resolution
    ' ------------------------------------------------------------
    Set result = ResolveWorkbookRelativePath(templatePath, resolvedPath)

    If Not ResultIsSuccess(result, "ResolveWorkbookRelativePath") Then
        GoTo CleanUp
    End If

    Debug.Print "ResolvedPath: " & resolvedPath

    ' ------------------------------------------------------------
    ' 3. Create Scan MailItem from real Baseline OFT
    ' ------------------------------------------------------------
    Set result = CreateMailFromTemplate(resolvedPath)

    If Not ResultIsSuccess(result, "CreateMailFromTemplate") Then
        GoTo CleanUp
    End If

    mailCreated = True
    Debug.Print "CreateMailFromTemplate: PASS"

    ' ------------------------------------------------------------
    ' 4. Read Subject Snapshot
    ' ------------------------------------------------------------
    Set result = ReadSubject(subjectText)

    If Not ResultIsSuccess(result, "ReadSubject") Then
        GoTo CleanUp
    End If

    Debug.Print "ReadSubject: PASS"
    Debug.Print "Subject Length: " & CStr(Len(subjectText))
    Debug.Print "Subject Snapshot: " & subjectText

    ' ------------------------------------------------------------
    ' 5. Read BodyText Snapshot via Outlook Adapter / WordEditor
    ' ------------------------------------------------------------
    Set result = ReadBodyText(bodyText)

    If Not ResultIsSuccess(result, "ReadBodyText") Then
        GoTo CleanUp
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))

    ' ------------------------------------------------------------
    ' 6. Production ScanTemplate
    ' ------------------------------------------------------------
    Set result = ScanTemplate(subjectText, bodyText, scanResult)

    If Not ResultIsSuccess(result, "ScanTemplate") Then
        GoTo CleanUp
    End If

    If scanResult Is Nothing Then
        Debug.Print "ScanTemplate Result Carrier: FAIL - scanResult is Nothing."
        GoTo CleanUp
    End If

    If Not scanResult.Exists(KEY_VALID_VARIABLES) Then
        Debug.Print "TemplateScanResult: FAIL - ValidVariables key missing."
        GoTo CleanUp
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Debug.Print "TemplateScanResult: FAIL - InvalidCandidates key missing."
        GoTo CleanUp
    End If

    If Not scanResult.Exists(KEY_LOCATIONS) Then
        Debug.Print "TemplateScanResult: FAIL - Locations key missing."
        GoTo CleanUp
    End If

    Set validVariables = scanResult(KEY_VALID_VARIABLES)
    Set invalidCandidates = scanResult(KEY_INVALID_CANDIDATES)
    Set locations = scanResult(KEY_LOCATIONS)

    If validVariables Is Nothing Then
        Debug.Print "TemplateScanResult: FAIL - ValidVariables is Nothing."
        GoTo CleanUp
    End If

    If invalidCandidates Is Nothing Then
        Debug.Print "TemplateScanResult: FAIL - InvalidCandidates is Nothing."
        GoTo CleanUp
    End If

    If locations Is Nothing Then
        Debug.Print "TemplateScanResult: FAIL - Locations is Nothing."
        GoTo CleanUp
    End If

    Debug.Print "ScanTemplate: PASS"
    Debug.Print "ValidVariables Count: " & CStr(validVariables.Count)
    PrintCollection "ValidVariables", validVariables

    Debug.Print "InvalidCandidates Count: " & CStr(invalidCandidates.Count)
    PrintCollection "InvalidCandidates", invalidCandidates

    Debug.Print "Locations Count: " & CStr(locations.Count)
    PrintLocations locations

    ' ------------------------------------------------------------
    ' 7. Baseline OFT Expected Result
    ' ------------------------------------------------------------
    If Not CollectionEquals( _
        validVariables, _
        Array("ModelName", "GateDate", "Department", "Comment")) Then

        Debug.Print "Baseline ValidVariables: FAIL"
        GoTo CleanUp
    End If

    Debug.Print "Baseline ValidVariables: PASS"

    If invalidCandidates.Count <> 0 Then
        Debug.Print "Baseline InvalidCandidates: FAIL - Expected 0."
        GoTo CleanUp
    End If

    Debug.Print "Baseline InvalidCandidates: PASS"

    If locations.compareMode <> vbTextCompare Then
        Debug.Print "Locations CompareMode: FAIL - Expected vbTextCompare."
        GoTo CleanUp
    End If

    Debug.Print "Locations CompareMode: PASS"

    If locations.Count <> 4 Then
        Debug.Print "Baseline Locations Count: FAIL - Expected 4."
        GoTo CleanUp
    End If

    If Not LocationEquals(locations, "ModelName", "Both") Then
        Debug.Print "ModelName Location: FAIL - Expected Both."
        GoTo CleanUp
    End If
    Debug.Print "ModelName Location: PASS / Both"

    If Not LocationEquals(locations, "GateDate", "Both") Then
        Debug.Print "GateDate Location: FAIL - Expected Both."
        GoTo CleanUp
    End If
    Debug.Print "GateDate Location: PASS / Both"

    If Not LocationEquals(locations, "Department", "Body") Then
        Debug.Print "Department Location: FAIL - Expected Body."
        GoTo CleanUp
    End If
    Debug.Print "Department Location: PASS / Body"

    If Not LocationEquals(locations, "Comment", "Body") Then
        Debug.Print "Comment Location: FAIL - Expected Body."
        GoTo CleanUp
    End If
    Debug.Print "Comment Location: PASS / Body"

    If Not ValidateStructuralInvariant( _
        validVariables, _
        invalidCandidates, _
        locations) Then

        Debug.Print "TemplateScanResult Structural Invariant: FAIL"
        GoTo CleanUp
    End If

    Debug.Print "TemplateScanResult Structural Invariant: PASS"

    overallPass = True

CleanUp:

    ' ------------------------------------------------------------
    ' 8. Production Lifecycle Cleanup
    ' ------------------------------------------------------------
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
        Debug.Print "TestP201FullTemplateScannerBaselineOftIntegration: PASS"
    Else
        Debug.Print "TestP201FullTemplateScannerBaselineOftIntegration: FAIL"
    End If

    Debug.Print String$(76, "=")
    Exit Sub

RuntimeError:
    Debug.Print _
        "Integration Test Runtime Error " & _
        CStr(Err.Number) & ": " & Err.Description

    overallPass = False
    Resume CleanUp

End Sub

Private Function ResultIsSuccess( _
    ByVal result As COperationResult, _
    ByVal stageName As String _
) As Boolean

    If result Is Nothing Then
        Debug.Print stageName & ": FAIL - OperationResult is Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print stageName & ": FAIL"
        Exit Function
    End If

    Debug.Print stageName & ": PASS"
    ResultIsSuccess = True

End Function

Private Function CollectionEquals( _
    ByVal actual As Collection, _
    ByVal expectedValues As Variant _
) As Boolean

    Dim expectedCount As Long
    Dim i As Long

    If actual Is Nothing Then
        Exit Function
    End If

    expectedCount = UBound(expectedValues) - LBound(expectedValues) + 1

    If actual.Count <> expectedCount Then
        Exit Function
    End If

    For i = 1 To actual.Count

        If StrComp( _
            CStr(actual(i)), _
            CStr(expectedValues(LBound(expectedValues) + i - 1)), _
            vbBinaryCompare) <> 0 Then

            Exit Function
        End If

    Next i

    CollectionEquals = True

End Function

Private Function LocationEquals( _
    ByVal locations As Object, _
    ByVal variableName As String, _
    ByVal expectedLocation As String _
) As Boolean

    If locations Is Nothing Then
        Exit Function
    End If

    If Not locations.Exists(variableName) Then
        Exit Function
    End If

    LocationEquals = _
        (StrComp( _
            CStr(locations(variableName)), _
            expectedLocation, _
            vbBinaryCompare) = 0)

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

    If validVariables.Count <> locations.Count Then
        Exit Function
    End If

    Set validSet = CreateObject("Scripting.Dictionary")
    validSet.compareMode = vbTextCompare

    For Each item In validVariables

        If Not locations.Exists(CStr(item)) Then
            Exit Function
        End If

        If validSet.Exists(CStr(item)) Then
            Exit Function
        End If

        validSet.Add CStr(item), True

    Next item

    For Each key In locations.Keys

        If Not validSet.Exists(CStr(key)) Then
            Exit Function
        End If

    Next key

    For Each item In invalidCandidates

        rawCandidate = CStr(item)

        If Len(rawCandidate) >= 4 Then
            innerText = Mid$(rawCandidate, 3, Len(rawCandidate) - 4)

            If locations.Exists(innerText) Then
                Exit Function
            End If
        End If

    Next item

    ValidateStructuralInvariant = True

End Function

Private Sub PrintCollection( _
    ByVal label As String, _
    ByVal items As Collection _
)

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
        Debug.Print _
            "  Location[" & CStr(key) & "] = " & _
            CStr(locations(key))
    Next key

End Sub
