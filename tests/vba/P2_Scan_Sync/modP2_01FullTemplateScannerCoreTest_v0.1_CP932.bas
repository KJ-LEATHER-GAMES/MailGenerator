Attribute VB_Name = "modP2_01FullTemplateScannerCoreTest"
Option Explicit

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Public Sub TestP201FullTemplateScannerCore()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(72, "=")
    Debug.Print "P2-01 Full Template Scanner Core Verification C1-C11"
    Debug.Print String$(72, "=")

    RunCase "C1 Subject Only", TestC1SubjectOnly(), passCount, failCount
    RunCase "C2 Body Only", TestC2BodyOnly(), passCount, failCount
    RunCase "C3 Both", TestC3Both(), passCount, failCount
    RunCase "C4 Case Insensitive Both", TestC4CaseInsensitiveBoth(), passCount, failCount
    RunCase "C5 Multiple Same Source", TestC5MultipleSameSource(), passCount, failCount
    RunCase "C6 Mixed Locations", TestC6MixedLocations(), passCount, failCount
    RunCase "C7 Invalid Candidates Regression", TestC7InvalidCandidates(), passCount, failCount
    RunCase "C8 Valid + Invalid Mixed", TestC8ValidInvalidMixed(), passCount, failCount
    RunCase "C9 Empty Input Regression", TestC9EmptyInput(), passCount, failCount
    RunCase "C10 First Detection Order Regression", TestC10FirstDetectionOrder(), passCount, failCount
    RunCase "C11 TemplateScanResult Structural Invariant", TestC11StructuralInvariant(), passCount, failCount

    Debug.Print String$(72, "-")
    Debug.Print "PASS Count: " & CStr(passCount)
    Debug.Print "FAIL Count: " & CStr(failCount)

    If failCount = 0 Then
        Debug.Print "TestP201FullTemplateScannerCore: PASS"
    Else
        Debug.Print "TestP201FullTemplateScannerCore: FAIL"
    End If

    Debug.Print String$(72, "=")

End Sub

Private Sub RunCase( _
    ByVal caseName As String, _
    ByVal casePassed As Boolean, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If casePassed Then
        passCount = passCount + 1
        Debug.Print caseName & ": PASS"
    Else
        failCount = failCount + 1
        Debug.Print caseName & ": FAIL"
    End If

End Sub

Private Function TestC1SubjectOnly() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}}", _
        vbNullString, _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC1SubjectOnly = _
        CollectionEquals(validVariables, Array("ModelName")) And _
        invalidCandidates.Count = 0 And _
        LocationEquals(locations, "ModelName", "Subject") And _
        locations.Count = 1

End Function

Private Function TestC2BodyOnly() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        vbNullString, _
        "{{Department}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC2BodyOnly = _
        CollectionEquals(validVariables, Array("Department")) And _
        invalidCandidates.Count = 0 And _
        LocationEquals(locations, "Department", "Body") And _
        locations.Count = 1

End Function

Private Function TestC3Both() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{GateDate}}", _
        "{{GateDate}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC3Both = _
        CollectionEquals(validVariables, Array("GateDate")) And _
        invalidCandidates.Count = 0 And _
        LocationEquals(locations, "GateDate", "Both") And _
        locations.Count = 1

End Function

Private Function TestC4CaseInsensitiveBoth() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}}", _
        "{{modelname}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC4CaseInsensitiveBoth = _
        CollectionEquals(validVariables, Array("ModelName")) And _
        invalidCandidates.Count = 0 And _
        locations.Count = 1 And _
        locations.Exists("MODELNAME") And _
        LocationEquals(locations, "MODELNAME", "Both")

End Function

Private Function TestC5MultipleSameSource() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}} / {{modelname}} / {{MODELNAME}}", _
        vbNullString, _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC5MultipleSameSource = _
        CollectionEquals(validVariables, Array("ModelName")) And _
        invalidCandidates.Count = 0 And _
        locations.Count = 1 And _
        LocationEquals(locations, "ModelName", "Subject")

End Function

Private Function TestC6MixedLocations() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}} {{GateDate}}", _
        "{{modelname}} {{GateDate}} {{Department}} {{Comment}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC6MixedLocations = _
        CollectionEquals( _
            validVariables, _
            Array("ModelName", "GateDate", "Department", "Comment")) And _
        invalidCandidates.Count = 0 And _
        locations.Count = 4 And _
        LocationEquals(locations, "ModelName", "Both") And _
        LocationEquals(locations, "GateDate", "Both") And _
        LocationEquals(locations, "Department", "Body") And _
        LocationEquals(locations, "Comment", "Body")

End Function

Private Function TestC7InvalidCandidates() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{1stGate}} {{_GateDate}} {{êRç∏ì˙}} {{User-Name}} {{ UserName }}", _
        vbNullString, _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC7InvalidCandidates = _
        validVariables.Count = 0 And _
        CollectionEquals( _
            invalidCandidates, _
            Array( _
                "{{1stGate}}", _
                "{{_GateDate}}", _
                "{{êRç∏ì˙}}", _
                "{{User-Name}}", _
                "{{ UserName }}")) And _
        locations.Count = 0

End Function

Private Function TestC8ValidInvalidMixed() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}} {{1stGate}}", _
        "{{Department}} {{ UserName }}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC8ValidInvalidMixed = _
        CollectionEquals( _
            validVariables, _
            Array("ModelName", "Department")) And _
        CollectionEquals( _
            invalidCandidates, _
            Array("{{1stGate}}", "{{ UserName }}")) And _
        locations.Count = 2 And _
        LocationEquals(locations, "ModelName", "Subject") And _
        LocationEquals(locations, "Department", "Body") And _
        Not locations.Exists("1stGate") And _
        Not locations.Exists(" UserName ")

End Function

Private Function TestC9EmptyInput() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        vbNullString, _
        vbNullString, _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC9EmptyInput = _
        validVariables.Count = 0 And _
        invalidCandidates.Count = 0 And _
        locations.Count = 0

End Function

Private Function TestC10FirstDetectionOrder() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{B}} {{A}}", _
        "{{C}} {{A}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC10FirstDetectionOrder = _
        CollectionEquals(validVariables, Array("B", "A", "C")) And _
        invalidCandidates.Count = 0 And _
        locations.Count = 3 And _
        LocationEquals(locations, "B", "Subject") And _
        LocationEquals(locations, "A", "Both") And _
        LocationEquals(locations, "C", "Body")

End Function

Private Function TestC11StructuralInvariant() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    If Not ExecuteScan( _
        "{{ModelName}} {{GateDate}} {{1stGate}}", _
        "{{modelname}} {{Department}}", _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        locations) Then
        Exit Function
    End If

    TestC11StructuralInvariant = _
        CollectionEquals( _
            validVariables, _
            Array("ModelName", "GateDate", "Department")) And _
        CollectionEquals( _
            invalidCandidates, _
            Array("{{1stGate}}")) And _
        LocationEquals(locations, "ModelName", "Both") And _
        LocationEquals(locations, "GateDate", "Subject") And _
        LocationEquals(locations, "Department", "Body") And _
        ValidateStructuralInvariant( _
            validVariables, _
            invalidCandidates, _
            locations)

End Function

Private Function ExecuteScan( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef locations As Object _
) As Boolean

    Dim result As COperationResult

    Set scanResult = Nothing
    Set validVariables = Nothing
    Set invalidCandidates = Nothing
    Set locations = Nothing

    On Error GoTo ErrorHandler

    Set result = ScanTemplate(subjectText, bodyText, scanResult)

    If result Is Nothing Then
        Debug.Print "  ExecuteScan: OperationResult is Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print "  ExecuteScan: ScanTemplate returned Failure."
        Exit Function
    End If

    If scanResult Is Nothing Then
        Debug.Print "  ExecuteScan: scanResult is Nothing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_VALID_VARIABLES) Then
        Debug.Print "  ExecuteScan: ValidVariables key is missing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Debug.Print "  ExecuteScan: InvalidCandidates key is missing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_LOCATIONS) Then
        Debug.Print "  ExecuteScan: Locations key is missing."
        Exit Function
    End If

    Set validVariables = scanResult(KEY_VALID_VARIABLES)
    Set invalidCandidates = scanResult(KEY_INVALID_CANDIDATES)
    Set locations = scanResult(KEY_LOCATIONS)

    If validVariables Is Nothing Then
        Debug.Print "  ExecuteScan: ValidVariables is Nothing."
        Exit Function
    End If

    If invalidCandidates Is Nothing Then
        Debug.Print "  ExecuteScan: InvalidCandidates is Nothing."
        Exit Function
    End If

    If locations Is Nothing Then
        Debug.Print "  ExecuteScan: Locations is Nothing."
        Exit Function
    End If

    If locations.compareMode <> vbTextCompare Then
        Debug.Print "  ExecuteScan: Locations.CompareMode is not vbTextCompare."
        Exit Function
    End If

    ExecuteScan = True
    Exit Function

ErrorHandler:
    Debug.Print _
        "  ExecuteScan Runtime Error " & _
        CStr(Err.Number) & ": " & Err.Description

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

    If validVariables Is Nothing Then
        Exit Function
    End If

    If invalidCandidates Is Nothing Then
        Exit Function
    End If

    If locations Is Nothing Then
        Exit Function
    End If

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
