Attribute VB_Name = "modP1_06MinimalUnresolvedCheckerCoreTest"
Option Explicit

Public Sub TestP106MinimalUnresolvedCheckerCore()

    Dim allPassed As Boolean

    Debug.Print "========================================"
    Debug.Print "P1-06 Minimal Unresolved Checker Core"
    Debug.Print "START"
    Debug.Print "========================================"

    allPassed = True

    allPassed = RunCase( _
        "C1 Unresolved 0", _
        "【ABC123】ゲート審査 2026/09/30 / ABC123", _
        "対象機種：ABC123" & vbCrLf & _
        "開催日：2026/09/30" & vbCrLf & _
        "担当部署：品質部" & vbCrLf & _
        "備考：確認お願いします", _
        False, _
        vbNullString) And allPassed

    allPassed = RunCase( _
        "C2 Subject 1", _
        "【ABC123】ゲート審査 {{GateDate}}", _
        "未置換なし", _
        True, _
        "GateDate") And allPassed

    allPassed = RunCase( _
        "C3 Body 1", _
        "未置換なし", _
        "開催日：{{GateDate}}", _
        True, _
        "GateDate") And allPassed

    allPassed = RunCase( _
        "C4 Subject Body Duplicate", _
        "{{GateDate}}", _
        "{{GateDate}}", _
        True, _
        "GateDate") And allPassed

    allPassed = RunCase( _
        "C5 Case Insensitive", _
        "{{GateDate}} / {{gatedate}}", _
        "{{GATEDATE}}", _
        True, _
        "GateDate") And allPassed

    allPassed = RunCase( _
        "C6 Multiple Variables", _
        "{{ModelName}} / {{GateDate}}", _
        "{{Department}} / {{modelname}}", _
        True, _
        "ModelName,GateDate,Department") And allPassed

    allPassed = RunCase( _
        "C7 Empty Input", _
        vbNullString, _
        vbNullString, _
        False, _
        vbNullString) And allPassed

    allPassed = RunCase( _
        "C8 Final Snapshot Token", _
        "未置換なし", _
        "備考：担当：{{Department}}", _
        True, _
        "Department") And allPassed

    Debug.Print "----------------------------------------"

    If allPassed Then
        Debug.Print "TestP106MinimalUnresolvedCheckerCore: PASS"
    Else
        Debug.Print "TestP106MinimalUnresolvedCheckerCore: FAIL"
    End If

End Sub

Private Function RunCase( _
    ByVal caseName As String, _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByVal expectedHasUnresolved As Boolean, _
    ByVal expectedVariablesCsv As String _
) As Boolean

    Dim result As COperationResult
    Dim unresolvedResult As Object
    Dim variables As Collection
    Dim expectedNames As Variant
    Dim expectedCount As Long
    Dim i As Long
    Dim currentName As String
    Dim actualHasUnresolved As Boolean
    Dim passed As Boolean

    passed = True

    Set result = CheckUnresolved( _
        subjectText, _
        bodyText, _
        unresolvedResult)

    If unresolvedResult Is Nothing Then
        Debug.Print caseName & ": FAIL"
        Debug.Print "  unresolvedResult is Nothing."
        PrintResultErrors result
        RunCase = False
        Exit Function
    End If

    If Not unresolvedResult.Exists("HasUnresolved") Then
        Debug.Print caseName & ": FAIL"
        Debug.Print "  Missing key: HasUnresolved"
        RunCase = False
        Exit Function
    End If

    If Not unresolvedResult.Exists("Variables") Then
        Debug.Print caseName & ": FAIL"
        Debug.Print "  Missing key: Variables"
        RunCase = False
        Exit Function
    End If

    actualHasUnresolved = CBool(unresolvedResult("HasUnresolved"))
    Set variables = unresolvedResult("Variables")

    If expectedHasUnresolved Then

        If result.Success Then
            passed = False
            Debug.Print "  Expected Failure Result but got Success."
        End If

        If result.Errors.Count = 0 Then
            passed = False
            Debug.Print "  Expected error detail but Errors.Count = 0."
        End If

        If Not actualHasUnresolved Then
            passed = False
            Debug.Print "  Expected HasUnresolved=True."
        End If

    Else

        If Not result.Success Then
            passed = False
            Debug.Print "  Expected Success but got Failure."
            PrintResultErrors result
        End If

        If actualHasUnresolved Then
            passed = False
            Debug.Print "  Expected HasUnresolved=False."
        End If

    End If

    If Len(expectedVariablesCsv) = 0 Then
        expectedCount = 0
    Else
        expectedNames = Split(expectedVariablesCsv, ",")
        expectedCount = UBound(expectedNames) - LBound(expectedNames) + 1
    End If

    If variables.Count <> expectedCount Then
        passed = False
        Debug.Print "  Variables.Count mismatch."
        Debug.Print "    Expected=" & CStr(expectedCount)
        Debug.Print "    Actual  =" & CStr(variables.Count)
    End If

    If expectedCount > 0 Then

        For i = LBound(expectedNames) To UBound(expectedNames)

            currentName = CStr(expectedNames(i))

            If Not CollectionContainsText(variables, currentName) Then
                passed = False
                Debug.Print "  Missing expected variable: " & currentName
            End If

        Next i

    End If

    If actualHasUnresolved <> (variables.Count > 0) Then
        passed = False
        Debug.Print "  Invariant mismatch: HasUnresolved <> (Variables.Count > 0)"
    End If

    If passed Then
        Debug.Print caseName & ": PASS"
    Else
        Debug.Print caseName & ": FAIL"
        PrintVariables variables
        PrintResultErrors result
    End If

    RunCase = passed

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

    Debug.Print "  Variables.Count=" & CStr(variables.Count)

    For i = 1 To variables.Count
        Debug.Print "    [" & CStr(i) & "] " & CStr(variables(i))
    Next i

End Sub

Private Sub PrintResultErrors(ByVal result As COperationResult)

    Dim errorInfo As CErrorInfo
    Dim i As Long

    If result Is Nothing Then
        Debug.Print "  Result is Nothing."
        Exit Sub
    End If

    Debug.Print "  Result.Success=" & CStr(result.Success)

    For i = 1 To result.Errors.Count

        Set errorInfo = result.Errors(i)

        Debug.Print "  Error[" & CStr(i) & "]"
        Debug.Print "    Type   =" & errorInfo.ErrorType
        Debug.Print "    Message=" & errorInfo.Message
        Debug.Print "    Target =" & errorInfo.Target

    Next i

End Sub
