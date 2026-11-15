Attribute VB_Name = "modP3_01ConfigurationValidatorCandidateTests"
Option Explicit

' P3-01 local test fixture, NOT EXECUTED and NOT a formal MTS run.
' Requires Excel VBA project with modResult, COperationResult, CErrorInfo,
' and the candidate modConfigurationValidator imported under CP932.
' Call RunP3_01ConfigurationValidatorCandidateTests manually in an isolated
' test workbook only after separate authorization; never in Production.

Private mPass As Long
Private mFail As Long
Private mSkip As Long

Public Sub RunP3_01ConfigurationValidatorCandidateTests()
    Dim caseId As Long

    mPass = 0
    mFail = 0
    mSkip = 0

    Debug.Print "P3-01 local candidate test fixture (NOT FORMAL)"
    For caseId = 1 To 22
        RunCase caseId
    Next caseId
    Debug.Print "Summary PASS=" & mPass & " FAIL=" & mFail & " SKIP=" & mSkip
End Sub

Private Sub RunCase(ByVal caseId As Long)
    Dim scan As Object
    Dim defs As Collection
    Dim groups As Object
    Dim row As Object
    Dim row2 As Object
    Dim options As Collection
    Dim result As COperationResult
    Dim formats As Variant
    Dim formatValue As Variant
    Dim fingerprintBefore As String
    Dim fingerprintAfter As String
    Dim caseLabel As String

    On Error GoTo TestRuntimeFailure
    caseLabel = "DEV-P3CFG-" & Format$(caseId, "00")

    Set scan = MakeScan()
    Set defs = New Collection
    Set row = MakeDefinition("ModelName", "Active")
    defs.Add row
    Set groups = CreateObject("Scripting.Dictionary")
    groups.CompareMode = vbBinaryCompare

    Select Case caseId
        Case 1
            CheckResult caseLabel, True, "", True, scan, defs, groups

        Case 2
            row("DisplayName") = vbNullString
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 3
            row("Type") = vbNullString
            CheckResult caseLabel & "-empty", False, "ConfigurationError", True, scan, defs, groups
            row("Type") = "Number"
            CheckResult caseLabel & "-invalid", False, "ConfigurationError", True, scan, defs, groups

        Case 4
            row("Required") = vbNullString
            CheckResult caseLabel & "-empty", False, "ConfigurationError", True, scan, defs, groups
            row("Required") = False
            CheckResult caseLabel & "-false", True, "", True, scan, defs, groups

        Case 5
            row("SortOrder") = vbNullString
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 6
            Set row2 = MakeDefinition("StageName", "Active")
            row2("SortOrder") = row("SortOrder")
            defs.Add row2
            AddTemplateName scan, "StageName", "Subject"
            CheckResult caseLabel & "-equal-sort", True, "", True, scan, defs, groups
            ' Row-order stability is NOT tested here; it belongs to UserForm.

        Case 7
            formats = Array( _
                "yyyy/mm/dd", "yyyy-mm-dd", "yyyy”NmŒŽd“ú", _
                "mŒŽd“ú", "yyyy”NmŒŽd“ú(aaa)", "mŒŽd“ú(aaa)")
            row("Type") = "Date"
            For Each formatValue In formats
                row("Format") = CStr(formatValue)
                CheckResult caseLabel & "-" & CStr(formatValue), _
                    True, "", True, scan, defs, groups
            Next formatValue

        Case 8
            row("Type") = "Date"
            row("Format") = "mm/dd/yyyy"
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 9
            row("Type") = "Select"
            row("OptionSource") = vbNullString
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 10
            row("Type") = "Select"
            row("OptionSource") = "Department"
            Set options = New Collection
            groups.Add "Department", options
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 11
            AddTemplateName scan, "NewVariable", "Body"
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 12
            scan("ValidVariables").Remove 1
            scan("Locations").Remove "ModelName"
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 13
            Set row2 = MakeDefinition("OldVariable", "Unused")
            row2("DisplayName") = vbNullString
            defs.Add row2
            CheckResult caseLabel, True, "", True, scan, defs, groups

        Case 14
            row("Status") = "Unused"
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 15
            scan("ValidVariables").Remove 1
            scan("ValidVariables").Add "modelname"
            CheckResult caseLabel, True, "", True, scan, defs, groups

        Case 16
            scan("InvalidCandidates").Add "{{!}}"
            CheckResult caseLabel, False, "ConfigurationError", True, scan, defs, groups

        Case 17
            CheckResult caseLabel, False, "ConfigurationError", False, scan, defs, groups

        Case 18
            Set result = ValidateConfiguration(True, Nothing, defs, groups)
            AssertResult caseLabel & "-missing-scan", result, False, "UnexpectedError"
            Set result = ValidateConfiguration(True, scan, Nothing, groups)
            AssertResult caseLabel & "-missing-definitions", result, False, "UnexpectedError"
            Set result = ValidateConfiguration(True, scan, defs, Nothing)
            AssertResult caseLabel & "-missing-options", result, False, "UnexpectedError"

        Case 19
            mSkip = mSkip + 1
            Debug.Print "SKIP " & caseLabel & " Data Access failure propagation is Application responsibility"

        Case 20
            scan.Remove "Locations"
            CheckResult caseLabel, False, "UnexpectedError", True, scan, defs, groups

        Case 21
            row("Type") = "Select"
            row("OptionSource") = "Department"
            Set row2 = MakeDefinition("StageName", "Active")
            row2("Type") = "Select"
            row2("OptionSource") = "Department"
            defs.Add row2
            AddTemplateName scan, "StageName", "Subject"
            Set options = New Collection
            options.Add MakeOption("Department", "Design", True)
            groups.Add "Department", options
            CheckResult caseLabel & "-shared-snapshot", True, "", True, scan, defs, groups
            ' Application-level caching/no duplicate GetActiveOptions calls is NOT proved.

        Case 22
            fingerprintBefore = CarrierFingerprint(scan, defs, groups)
            Set result = ValidateConfiguration(True, scan, defs, groups)
            AssertResult caseLabel & "-first", result, True, ""
            Set result = ValidateConfiguration(True, scan, defs, groups)
            AssertResult caseLabel & "-second", result, True, ""
            fingerprintAfter = CarrierFingerprint(scan, defs, groups)
            If fingerprintBefore = fingerprintAfter Then
                mPass = mPass + 1
                Debug.Print "PASS " & caseLabel & " footprint unchanged"
            Else
                mFail = mFail + 1
                Debug.Print "FAIL " & caseLabel & " footprint changed"
            End If
    End Select
    Exit Sub

TestRuntimeFailure:
    mFail = mFail + 1
    Debug.Print "FAIL " & caseLabel & " test runtime error: " & CStr(Err.Number) & " " & Err.Description
End Sub

Private Sub CheckResult( _
    ByVal caseLabel As String, _
    ByVal expectedSuccess As Boolean, _
    ByVal expectedType As String, _
    ByVal exists As Boolean, _
    ByVal scan As Object, _
    ByVal defs As Collection, _
    ByVal groups As Object _
)
    Dim result As COperationResult
    Set result = ValidateConfiguration(exists, scan, defs, groups)
    AssertResult caseLabel, result, expectedSuccess, expectedType
End Sub

Private Sub AssertResult( _
    ByVal caseLabel As String, _
    ByVal result As COperationResult, _
    ByVal expectedSuccess As Boolean, _
    ByVal expectedType As String _
)
    Dim errors As Collection
    Dim firstError As CErrorInfo
    Dim actualType As String

    If result Is Nothing Then
        mFail = mFail + 1
        Debug.Print "FAIL " & caseLabel & " Nothing result"
        Exit Sub
    End If

    Set errors = result.Errors
    If result.Success = expectedSuccess Then
        If expectedSuccess Then
            If errors.Count = 0 Then
                mPass = mPass + 1
                Debug.Print "PASS " & caseLabel
                Exit Sub
            End If
        ElseIf errors.Count > 0 Then
            Set firstError = errors(1)
            actualType = firstError.ErrorType
            If actualType = expectedType And Len(firstError.Target) > 0 Then
                mPass = mPass + 1
                Debug.Print "PASS " & caseLabel & " " & actualType & " " & firstError.Target
                Exit Sub
            End If
        End If
    End If

    mFail = mFail + 1
    Debug.Print "FAIL " & caseLabel & _
        " expectedSuccess=" & CStr(expectedSuccess) & _
        " actualSuccess=" & CStr(result.Success) & _
        " errorCount=" & CStr(errors.Count)
End Sub

Private Function MakeScan() As Object
    Dim scan As Object
    Dim validNames As Collection
    Dim invalidNames As Collection
    Dim locations As Object

    Set scan = CreateObject("Scripting.Dictionary")
    scan.CompareMode = vbBinaryCompare
    Set validNames = New Collection
    Set invalidNames = New Collection
    Set locations = CreateObject("Scripting.Dictionary")
    locations.CompareMode = vbTextCompare

    validNames.Add "ModelName"
    locations.Add "ModelName", "Subject"
    scan.Add "ValidVariables", validNames
    scan.Add "InvalidCandidates", invalidNames
    scan.Add "Locations", locations
    Set MakeScan = scan
End Function

Private Sub AddTemplateName( _
    ByVal scan As Object, _
    ByVal nameText As String, _
    ByVal locationText As String _
)
    scan("ValidVariables").Add nameText
    scan("Locations").Add nameText, locationText
End Sub

Private Function MakeDefinition( _
    ByVal nameText As String, _
    ByVal statusText As String _
) As Object
    Dim item As Object
    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add "VariableName", nameText
    item.Add "DisplayName", nameText
    item.Add "Type", "Text"
    item.Add "Required", False
    item.Add "Description", vbNullString
    item.Add "OptionSource", vbNullString
    item.Add "SortOrder", 10
    item.Add "Format", vbNullString
    item.Add "TemplateLocation", "Subject"
    item.Add "Status", statusText
    item.Add "FirstDetectedAt", Empty
    item.Add "LastDetectedAt", Empty
    item.Add "__RowIndex", 1

    Set MakeDefinition = item
End Function

Private Function MakeOption( _
    ByVal groupName As String, _
    ByVal optionText As String, _
    ByVal isActive As Boolean _
) As Object
    Dim item As Object
    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare
    item.Add "OptionGroup", groupName
    item.Add "Value", optionText
    item.Add "SortOrder", 10
    item.Add "Active", isActive
    item.Add "__RowIndex", 1
    Set MakeOption = item
End Function

' Small test-side fingerprint; it is not a complete deep-object hash.
' It checks the properties and collection counts targeted by DEV-P3CFG-22.
Private Function CarrierFingerprint( _
    ByVal scan As Object, _
    ByVal defs As Collection, _
    ByVal groups As Object _
) As String
    Dim item As Object
    Set item = defs(1)
    CarrierFingerprint = _
        CStr(scan("ValidVariables").Count) & "|" & _
        CStr(scan("InvalidCandidates").Count) & "|" & _
        CStr(scan("Locations").Count) & "|" & _
        CStr(defs.Count) & "|" & _
        CStr(groups.Count) & "|" & _
        CStr(item("VariableName")) & "|" & _
        CStr(item("DisplayName")) & "|" & _
        CStr(item("Type")) & "|" & _
        CStr(item("Required")) & "|" & _
        CStr(item("SortOrder")) & "|" & _
        CStr(item("Status"))
End Function
