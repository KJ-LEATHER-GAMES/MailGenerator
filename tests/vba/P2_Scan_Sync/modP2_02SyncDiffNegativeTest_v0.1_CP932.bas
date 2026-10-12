Attribute VB_Name = "modP2_02SyncDiffNegativeTest"
Option Explicit

Public Sub TestP202SyncDiffTechnicalNegative()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(70, "=")
    Debug.Print "P2-02 Sync Diff Technical Negative Verification"
    Debug.Print String$(70, "=")

    RecordNegative "N1 TemplateScanResult = Nothing", TestN1_TemplateNothing(), passCount, failCount
    RecordNegative "N2 CurrentDefinitions = Nothing", TestN2_DefinitionsNothing(), passCount, failCount
    RecordNegative "N3 InvalidCandidates > 0", TestN3_InvalidCandidates(), passCount, failCount
    RecordNegative "N4 Duplicate Definition Identity", TestN4_DuplicateDefinitions(), passCount, failCount
    RecordNegative "N5 Unknown Status", TestN5_UnknownStatus(), passCount, failCount
    RecordNegative "N6 Scan Structural Invariant", TestN6_ScanInvariant(), passCount, failCount

    Debug.Print String$(70, "-")
    Debug.Print "PASS Count: " & CStr(passCount)
    Debug.Print "FAIL Count: " & CStr(failCount)

    If passCount = 6 And failCount = 0 Then
        Debug.Print "Overall:"
        Debug.Print "PASS"
    Else
        Debug.Print "Overall:"
        Debug.Print "FAIL"
    End If

    Debug.Print String$(70, "=")

End Sub

Private Function TestN1_TemplateNothing() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = Nothing
    Set defs = New Collection

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN1_TemplateNothing = IsExpectedFailure(result, diff, "UnexpectedError")

End Function

Private Function TestN2_DefinitionsNothing() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = CreateEmptyScanResult()
    Set defs = Nothing

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN2_DefinitionsNothing = IsExpectedFailure(result, diff, "UnexpectedError")

End Function

Private Function TestN3_InvalidCandidates() As Boolean

    Dim scanResult As Object
    Dim invalidCandidates As Collection
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = CreateEmptyScanResult()
    Set invalidCandidates = scanResult("InvalidCandidates")
    invalidCandidates.Add "{{123Name}}"

    Set defs = New Collection

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN3_InvalidCandidates = _
        IsExpectedFailure(result, diff, "ConfigurationError")

End Function

Private Function TestN4_DuplicateDefinitions() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = CreateEmptyScanResult()

    Set defs = New Collection
    defs.Add CreateDefinition("ModelName", "Active")
    defs.Add CreateDefinition("MODELNAME", "Unused")

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN4_DuplicateDefinitions = _
        IsExpectedFailure(result, diff, "ConfigurationError")

End Function

Private Function TestN5_UnknownStatus() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = CreateEmptyScanResult()

    Set defs = New Collection
    defs.Add CreateDefinition("ModelName", "Unknown")

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN5_UnknownStatus = _
        IsExpectedFailure(result, diff, "ConfigurationError")

End Function

Private Function TestN6_ScanInvariant() As Boolean

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = CreateEmptyScanResult()
    Set validVariables = scanResult("ValidVariables")

    validVariables.Add "ModelName"
    ' Intentionally omit Locations("ModelName").

    Set defs = New Collection

    Set result = BuildSyncDiff(scanResult, defs, TestTimestamp(), diff)

    TestN6_ScanInvariant = _
        IsExpectedFailure(result, diff, "UnexpectedError")

End Function

Private Function CreateEmptyScanResult() As Object

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    Set scanResult = CreateObject("Scripting.Dictionary")
    scanResult.CompareMode = vbTextCompare

    Set validVariables = New Collection
    Set invalidCandidates = New Collection
    Set locations = CreateObject("Scripting.Dictionary")
    locations.CompareMode = vbTextCompare

    scanResult.Add "ValidVariables", validVariables
    scanResult.Add "InvalidCandidates", invalidCandidates
    scanResult.Add "Locations", locations

    Set CreateEmptyScanResult = scanResult

End Function

Private Function CreateDefinition( _
    ByVal variableName As String, _
    ByVal statusValue As String _
) As Object

    Dim item As Object

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add "VariableName", variableName
    item.Add "TemplateLocation", "Body"
    item.Add "Status", statusValue
    item.Add "FirstDetectedAt", _
        DateSerial(2026, 9, 1) + TimeSerial(9, 0, 0)
    item.Add "LastDetectedAt", _
        DateSerial(2026, 9, 20) + TimeSerial(10, 0, 0)

    Set CreateDefinition = item

End Function

Private Function IsExpectedFailure( _
    ByVal result As COperationResult, _
    ByVal diff As Object, _
    ByVal expectedErrorType As String _
) As Boolean

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    If result Is Nothing Then Exit Function
    If result.Success Then Exit Function
    If Not diff Is Nothing Then Exit Function

    Set errors = result.Errors

    If errors.Count = 0 Then Exit Function

    Set errorInfo = errors(1)

    IsExpectedFailure = _
        (StrComp( _
            errorInfo.ErrorType, _
            expectedErrorType, _
            vbTextCompare) = 0)

End Function

Private Sub RecordNegative( _
    ByVal label As String, _
    ByVal passed As Boolean, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If passed Then
        Debug.Print label & Space$(MaxLong(1, 48 - Len(label))) & "PASS"
        passCount = passCount + 1
    Else
        Debug.Print label & Space$(MaxLong(1, 48 - Len(label))) & "FAIL"
        failCount = failCount + 1
    End If

End Sub

Private Function TestTimestamp() As Date
    TestTimestamp = _
        DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0)
End Function

Private Function MaxLong( _
    ByVal leftValue As Long, _
    ByVal rightValue As Long _
) As Long

    If leftValue > rightValue Then
        MaxLong = leftValue
    Else
        MaxLong = rightValue
    End If

End Function
