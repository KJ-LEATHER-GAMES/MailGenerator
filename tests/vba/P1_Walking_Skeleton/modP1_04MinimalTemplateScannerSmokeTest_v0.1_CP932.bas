Attribute VB_Name = "modP104MinimalTemplateScannerTest"
Option Explicit

' P1-04 Minimal Template Scanner Smoke Test v0.1
'
' Core tests use fixed strings.
' Integration test reuses the P1-03 Subject / BodyText snapshot boundary.
' This is Implementation Unit Verification, not Formal MVP Test.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"
Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Public Sub TestP104MinimalTemplateScannerCore()

    Dim failureMessage As String
    Dim allPassed As Boolean

    Debug.Print "TestP104MinimalTemplateScannerCore: START"
    Debug.Print String$(72, "-")

    allPassed = True

    If Not TestCoreBaseline(failureMessage) Then
        Debug.Print "C1 Baseline Happy Path: FAIL"
        Debug.Print "  " & failureMessage
        allPassed = False
    Else
        Debug.Print "C1 Baseline Happy Path: PASS"
    End If

    failureMessage = vbNullString

    If Not TestCoreCaseInsensitive(failureMessage) Then
        Debug.Print "C2 Case Insensitive Integration: FAIL"
        Debug.Print "  " & failureMessage
        allPassed = False
    Else
        Debug.Print "C2 Case Insensitive Integration: PASS"
    End If

    failureMessage = vbNullString

    If Not TestCoreInvalidCandidates(failureMessage) Then
        Debug.Print "C3 Invalid Candidate Detection: FAIL"
        Debug.Print "  " & failureMessage
        allPassed = False
    Else
        Debug.Print "C3 Invalid Candidate Detection: PASS"
    End If

    failureMessage = vbNullString

    If Not TestCoreEmptyInput(failureMessage) Then
        Debug.Print "C4 Empty Input: FAIL"
        Debug.Print "  " & failureMessage
        allPassed = False
    Else
        Debug.Print "C4 Empty Input: PASS"
    End If

    Debug.Print String$(72, "-")

    If allPassed Then
        Debug.Print "TestP104MinimalTemplateScannerCore: PASS"
    Else
        Debug.Print "TestP104MinimalTemplateScannerCore: FAIL"
    End If
End Sub

Public Sub TestP104MinimalTemplateScannerIntegration()

    Dim result As COperationResult
    Dim cleanupResult As COperationResult
    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    Dim templatePath As String
    Dim absolutePath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim mailItemActive As Boolean
    Dim testPassed As Boolean
    Dim failureMessage As String

    On Error GoTo UnexpectedError

    Debug.Print "TestP104MinimalTemplateScannerIntegration: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path
    Debug.Print String$(72, "-")

    ' Defensive adapter cleanup. This must not create Outlook.
    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    Set cleanupResult = Nothing

    Set result = modSettingsData.GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If Not RequireSuccess( _
        "GetSettingValue(TemplatePath)", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Len(Trim$(templatePath)) = 0 Then
        failureMessage = "TemplatePath is empty."
        GoTo TestFailed
    End If

    Debug.Print "TemplatePath: " & templatePath

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        templatePath, _
        absolutePath)

    If Not RequireSuccess( _
        "ResolveWorkbookRelativePath", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Len(Trim$(absolutePath)) = 0 Then
        failureMessage = "Resolved absolute path is empty."
        GoTo TestFailed
    End If

    Debug.Print "ResolvedPath: " & absolutePath
    Debug.Print "Settings / Path Resolution: PASS"

    Set result = modOutlookAdapter.CreateMailFromTemplate(absolutePath)

    If Not RequireSuccess( _
        "CreateMailFromTemplate", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    mailItemActive = True
    Debug.Print "CreateMailFromTemplate: PASS"

    Set result = modOutlookAdapter.ReadSubject(subjectText)

    If Not RequireSuccess( _
        "ReadSubject", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    Debug.Print "ReadSubject: PASS"
    Debug.Print "Subject Length: " & CStr(Len(subjectText))
    Debug.Print "Subject Snapshot: " & subjectText

    Set result = modOutlookAdapter.ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "ReadBodyText", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))

    Set result = modTemplateScanner.ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If Not RequireSuccess( _
        "ScanTemplate", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Not GetScanCollections( _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If validVariables.Count <> 4 Then
        failureMessage = _
            "Baseline ValidVariables.Count mismatch. Expected=4, Actual=" & _
            CStr(validVariables.Count)
        GoTo TestFailed
    End If

    If Not HasExpectedVariables(validVariables) Then
        failureMessage = _
            "Baseline ValidVariables do not match expected variables."
        GoTo TestFailed
    End If

    If invalidCandidates.Count <> 0 Then
        failureMessage = _
            "Baseline InvalidCandidates.Count mismatch. Expected=0, Actual=" & _
            CStr(invalidCandidates.Count)
        GoTo TestFailed
    End If

    Debug.Print "ScanTemplate: PASS"
    Debug.Print "ValidVariables Count: " & CStr(validVariables.Count)
    PrintCollection "ValidVariables", validVariables
    Debug.Print _
        "InvalidCandidates Count: " & _
        CStr(invalidCandidates.Count)

    Set result = modOutlookAdapter.CloseWithoutSave()

    If Not RequireSuccess( _
        "CloseWithoutSave", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    mailItemActive = False
    Debug.Print "CloseWithoutSave: PASS"

    testPassed = True
    GoTo Finalize

TestFailed:
    Debug.Print "FAIL: " & failureMessage

Finalize:

    If mailItemActive Then
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()

        If cleanupResult Is Nothing Then
            Debug.Print _
                "Cleanup CloseWithoutSave: FAIL (Nothing result)"
        ElseIf cleanupResult.Success Then
            Debug.Print "Cleanup CloseWithoutSave: PASS"
        Else
            Debug.Print "Cleanup CloseWithoutSave: FAIL"
            PrintOperationResult _
                "Cleanup CloseWithoutSave", _
                cleanupResult
        End If

        Set cleanupResult = Nothing
        mailItemActive = False
    End If

    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Set scanResult = Nothing
    Set result = Nothing

    Debug.Print String$(72, "-")

    If testPassed Then
        Debug.Print _
            "TestP104MinimalTemplateScannerIntegration: PASS"
    Else
        Debug.Print _
            "TestP104MinimalTemplateScannerIntegration: FAIL"
    End If

    Exit Sub

UnexpectedError:
    failureMessage = _
        "Unexpected VBA error in integration smoke test: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume TestFailed
End Sub

Private Function TestCoreBaseline( _
    ByRef failureMessage As String _
) As Boolean

    Dim result As COperationResult
    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    Dim subjectText As String
    Dim bodyText As String

    TestCoreBaseline = False
    failureMessage = vbNullString

    subjectText = _
        "Åy{{ModelName}}ÅzÉQÅ[ÉgêRç∏ {{GateDate}} / {{modelname}}"

    bodyText = _
        "ëŒè€ã@éÌÅF{{ModelName}}" & vbCrLf & _
        "äJç√ì˙ÅF{{GateDate}}" & vbCrLf & _
        "íSìñïîèêÅF{{Department}}" & vbCrLf & _
        "îıçlÅF{{Comment}}" & vbCrLf & _
        "ëŒè€ã@éÌçƒåfÅF{{MODELNAME}}" & vbCrLf & _
        "íSìñïîèêçƒåfÅF{{department}}"

    Set result = modTemplateScanner.ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If Not RequireSuccess( _
        "ScanTemplate / C1", _
        result, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If Not GetScanCollections( _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If validVariables.Count <> 4 Then
        failureMessage = _
            "Expected 4 ValidVariables, Actual=" & _
            CStr(validVariables.Count)
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        1, _
        "ModelName") Then

        failureMessage = _
            "ValidVariables(1) is not ModelName."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        2, _
        "GateDate") Then

        failureMessage = _
            "ValidVariables(2) is not GateDate."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        3, _
        "Department") Then

        failureMessage = _
            "ValidVariables(3) is not Department."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        4, _
        "Comment") Then

        failureMessage = _
            "ValidVariables(4) is not Comment."
        GoTo CleanUp
    End If

    If invalidCandidates.Count <> 0 Then
        failureMessage = _
            "Expected 0 InvalidCandidates, Actual=" & _
            CStr(invalidCandidates.Count)
        GoTo CleanUp
    End If

    TestCoreBaseline = True

CleanUp:
    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Set scanResult = Nothing
    Set result = Nothing
End Function

Private Function TestCoreCaseInsensitive( _
    ByRef failureMessage As String _
) As Boolean

    Dim result As COperationResult
    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    TestCoreCaseInsensitive = False
    failureMessage = vbNullString

    Set result = modTemplateScanner.ScanTemplate( _
        "{{ModelName}}{{modelname}}{{MODELNAME}}", _
        vbNullString, _
        scanResult)

    If Not RequireSuccess( _
        "ScanTemplate / C2", _
        result, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If Not GetScanCollections( _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If validVariables.Count <> 1 Then
        failureMessage = _
            "Expected 1 ValidVariable, Actual=" & _
            CStr(validVariables.Count)
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        1, _
        "ModelName") Then

        failureMessage = _
            "First detected VariableName casing was not preserved."
        GoTo CleanUp
    End If

    If invalidCandidates.Count <> 0 Then
        failureMessage = _
            "Expected 0 InvalidCandidates, Actual=" & _
            CStr(invalidCandidates.Count)
        GoTo CleanUp
    End If

    TestCoreCaseInsensitive = True

CleanUp:
    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Set scanResult = Nothing
    Set result = Nothing
End Function

Private Function TestCoreInvalidCandidates( _
    ByRef failureMessage As String _
) As Boolean

    Dim result As COperationResult
    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim sourceText As String

    TestCoreInvalidCandidates = False
    failureMessage = vbNullString

    sourceText = _
        "{{ModelName}}" & vbCrLf & _
        "{{1stGate}}" & vbCrLf & _
        "{{_GateDate}}" & vbCrLf & _
        "{{êRç∏ì˙}}" & vbCrLf & _
        "{{User-Name}}" & vbCrLf & _
        "{{ UserName }}"

    Set result = modTemplateScanner.ScanTemplate( _
        sourceText, _
        vbNullString, _
        scanResult)

    If Not RequireSuccess( _
        "ScanTemplate / C3", _
        result, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If Not GetScanCollections( _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If validVariables.Count <> 1 Then
        failureMessage = _
            "Expected 1 ValidVariable, Actual=" & _
            CStr(validVariables.Count)
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        validVariables, _
        1, _
        "ModelName") Then

        failureMessage = _
            "Expected valid variable ModelName."
        GoTo CleanUp
    End If

    If invalidCandidates.Count <> 5 Then
        failureMessage = _
            "Expected 5 InvalidCandidates, Actual=" & _
            CStr(invalidCandidates.Count)
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        invalidCandidates, _
        1, _
        "{{1stGate}}") Then

        failureMessage = _
            "InvalidCandidates(1) raw text mismatch."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        invalidCandidates, _
        2, _
        "{{_GateDate}}") Then

        failureMessage = _
            "InvalidCandidates(2) raw text mismatch."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        invalidCandidates, _
        3, _
        "{{êRç∏ì˙}}") Then

        failureMessage = _
            "InvalidCandidates(3) raw text mismatch."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        invalidCandidates, _
        4, _
        "{{User-Name}}") Then

        failureMessage = _
            "InvalidCandidates(4) raw text mismatch."
        GoTo CleanUp
    End If

    If Not CollectionItemEquals( _
        invalidCandidates, _
        5, _
        "{{ UserName }}") Then

        failureMessage = _
            "InvalidCandidates(5) raw text mismatch."
        GoTo CleanUp
    End If

    TestCoreInvalidCandidates = True

CleanUp:
    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Set scanResult = Nothing
    Set result = Nothing
End Function

Private Function TestCoreEmptyInput( _
    ByRef failureMessage As String _
) As Boolean

    Dim result As COperationResult
    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    TestCoreEmptyInput = False
    failureMessage = vbNullString

    Set result = modTemplateScanner.ScanTemplate( _
        vbNullString, _
        vbNullString, _
        scanResult)

    If Not RequireSuccess( _
        "ScanTemplate / C4", _
        result, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If Not GetScanCollections( _
        scanResult, _
        validVariables, _
        invalidCandidates, _
        failureMessage) Then

        GoTo CleanUp
    End If

    If validVariables.Count <> 0 Then
        failureMessage = _
            "Expected 0 ValidVariables, Actual=" & _
            CStr(validVariables.Count)
        GoTo CleanUp
    End If

    If invalidCandidates.Count <> 0 Then
        failureMessage = _
            "Expected 0 InvalidCandidates, Actual=" & _
            CStr(invalidCandidates.Count)
        GoTo CleanUp
    End If

    TestCoreEmptyInput = True

CleanUp:
    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Set scanResult = Nothing
    Set result = Nothing
End Function

Private Function GetScanCollections( _
    ByVal scanResult As Object, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef failureMessage As String _
) As Boolean

    Set validVariables = Nothing
    Set invalidCandidates = Nothing
    GetScanCollections = False

    On Error GoTo ResultError

    If scanResult Is Nothing Then
        failureMessage = "scanResult is Nothing."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_VALID_VARIABLES) Then
        failureMessage = _
            "scanResult does not contain ValidVariables."
        Exit Function
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        failureMessage = _
            "scanResult does not contain InvalidCandidates."
        Exit Function
    End If

    Set validVariables = scanResult(KEY_VALID_VARIABLES)
    Set invalidCandidates = scanResult(KEY_INVALID_CANDIDATES)

    If validVariables Is Nothing Then
        failureMessage = "ValidVariables is Nothing."
        Exit Function
    End If

    If invalidCandidates Is Nothing Then
        failureMessage = "InvalidCandidates is Nothing."
        Exit Function
    End If

    GetScanCollections = True
    Exit Function

ResultError:
    failureMessage = _
        "Unable to read scanResult: " & _
        CStr(Err.Number) & " - " & Err.Description
End Function

Private Function HasExpectedVariables( _
    ByVal validVariables As Collection _
) As Boolean

    HasExpectedVariables = _
        CollectionContainsCaseInsensitive( _
            validVariables, _
            "ModelName") And _
        CollectionContainsCaseInsensitive( _
            validVariables, _
            "GateDate") And _
        CollectionContainsCaseInsensitive( _
            validVariables, _
            "Department") And _
        CollectionContainsCaseInsensitive( _
            validVariables, _
            "Comment")
End Function

Private Function CollectionContainsCaseInsensitive( _
    ByVal values As Collection, _
    ByVal expectedValue As String _
) As Boolean

    Dim item As Variant

    CollectionContainsCaseInsensitive = False

    If values Is Nothing Then Exit Function

    For Each item In values
        If StrComp( _
            CStr(item), _
            expectedValue, _
            vbTextCompare) = 0 Then

            CollectionContainsCaseInsensitive = True
            Exit Function
        End If
    Next item
End Function

Private Function CollectionItemEquals( _
    ByVal values As Collection, _
    ByVal itemIndex As Long, _
    ByVal expectedValue As String _
) As Boolean

    CollectionItemEquals = False

    If values Is Nothing Then Exit Function
    If itemIndex < 1 Then Exit Function
    If itemIndex > values.Count Then Exit Function

    CollectionItemEquals = _
        (StrComp( _
            CStr(values(itemIndex)), _
            expectedValue, _
            vbBinaryCompare) = 0)
End Function

Private Function RequireSuccess( _
    ByVal operationName As String, _
    ByVal result As COperationResult, _
    ByRef failureMessage As String _
) As Boolean

    RequireSuccess = False

    If result Is Nothing Then
        failureMessage = operationName & " returned Nothing."
        Exit Function
    End If

    If Not result.Success Then
        PrintOperationResult operationName, result
        failureMessage = operationName & " returned Failure."
        Exit Function
    End If

    RequireSuccess = True
End Function

Private Sub PrintCollection( _
    ByVal collectionName As String, _
    ByVal values As Collection _
)

    Dim item As Variant

    Debug.Print collectionName & ":"

    If values Is Nothing Then
        Debug.Print "  <Nothing>"
        Exit Sub
    End If

    For Each item In values
        Debug.Print "  " & CStr(item)
    Next item
End Sub

Private Sub PrintOperationResult( _
    ByVal operationName As String, _
    ByVal result As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    If result Is Nothing Then
        Debug.Print operationName & ": Result=Nothing"
        Exit Sub
    End If

    Debug.Print _
        operationName & ": Success=" & CStr(result.Success)

    If result.Success Then Exit Sub

    Set errors = result.Errors

    For Each errorInfo In errors
        Debug.Print _
            "  ErrorType=" & errorInfo.ErrorType & _
            ", Target=" & errorInfo.Target & _
            ", Message=" & errorInfo.Message
    Next errorInfo

    Set errorInfo = Nothing
    Set errors = Nothing
End Sub
