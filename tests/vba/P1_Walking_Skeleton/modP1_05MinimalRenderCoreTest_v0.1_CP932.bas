Attribute VB_Name = "modP105MinimalRenderCoreTest"
Option Explicit

Public Sub TestP105MinimalRenderCore()

    Dim ok As Boolean
    Dim msg As String

    Debug.Print "TestP105MinimalRenderCore: START"
    Debug.Print String$(72, "-")

    ok = True

    If Not CheckBaselineSubject(msg) Then
        Debug.Print "C1 Baseline Subject: FAIL - " & msg
        ok = False
    Else
        Debug.Print "C1 Baseline Subject: PASS"
    End If

    msg = vbNullString
    If Not CheckCaseInsensitiveAllOccurrences(msg) Then
        Debug.Print "C2 Case Insensitive / All Occurrences: FAIL - " & msg
        ok = False
    Else
        Debug.Print "C2 Case Insensitive / All Occurrences: PASS"
    End If

    msg = vbNullString
    If Not CheckMissingValueLeavesToken(msg) Then
        Debug.Print "C3 Missing Value Leaves Token: FAIL - " & msg
        ok = False
    Else
        Debug.Print "C3 Missing Value Leaves Token: PASS"
    End If

    msg = vbNullString
    If Not CheckExtraValueNoOp(msg) Then
        Debug.Print "C4 Extra Value No-op: FAIL - " & msg
        ok = False
    Else
        Debug.Print "C4 Extra Value No-op: PASS"
    End If

    msg = vbNullString
    If Not CheckEmptySubject(msg) Then
        Debug.Print "C5 Empty Subject: FAIL - " & msg
        ok = False
    Else
        Debug.Print "C5 Empty Subject: PASS"
    End If

    msg = vbNullString
    If Not CheckNothingFormattedValues(msg) Then
        Debug.Print "N1 formattedValues=Nothing: FAIL - " & msg
        ok = False
    Else
        Debug.Print "N1 formattedValues=Nothing: PASS"
    End If

    Debug.Print String$(72, "-")
    Debug.Print "TestP105MinimalRenderCore: " & IIf(ok, "PASS", "FAIL")
End Sub

Private Function CheckBaselineSubject(ByRef msg As String) As Boolean

    Dim values As Object
    Dim r As COperationResult
    Dim actual As String
    Dim expected As String

    Set values = CreateValues()
    expected = "ÅyABC123ÅzÉQÅ[ÉgêRç∏ 2026/09/30 / ABC123"

    Set r = modSubjectRenderer.RenderSubject( _
        "Åy{{ModelName}}ÅzÉQÅ[ÉgêRç∏ {{GateDate}} / {{modelname}}", _
        values, _
        actual)

    If Not RequireSuccess(r, msg) Then Exit Function

    If StrComp(actual, expected, vbBinaryCompare) <> 0 Then
        msg = "Actual=[" & actual & "]"
        Exit Function
    End If

    CheckBaselineSubject = True
End Function

Private Function CheckCaseInsensitiveAllOccurrences(ByRef msg As String) As Boolean

    Dim values As Object
    Dim r As COperationResult
    Dim actual As String
    Dim expected As String

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare
    values.Add "ModelName", "ABC123"

    expected = "ABC123 / ABC123 / ABC123"

    Set r = modSubjectRenderer.RenderSubject( _
        "{{ModelName}} / {{modelname}} / {{MODELNAME}}", _
        values, _
        actual)

    If Not RequireSuccess(r, msg) Then Exit Function

    If StrComp(actual, expected, vbBinaryCompare) <> 0 Then
        msg = "Actual=[" & actual & "]"
        Exit Function
    End If

    CheckCaseInsensitiveAllOccurrences = True
End Function

Private Function CheckMissingValueLeavesToken(ByRef msg As String) As Boolean

    Dim values As Object
    Dim r As COperationResult
    Dim actual As String
    Dim expected As String

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare
    values.Add "ModelName", "ABC123"

    expected = "ABC123 / {{GateDate}}"

    Set r = modSubjectRenderer.RenderSubject( _
        "{{ModelName}} / {{GateDate}}", _
        values, _
        actual)

    If Not RequireSuccess(r, msg) Then Exit Function

    If StrComp(actual, expected, vbBinaryCompare) <> 0 Then
        msg = "Actual=[" & actual & "]"
        Exit Function
    End If

    CheckMissingValueLeavesToken = True
End Function

Private Function CheckExtraValueNoOp(ByRef msg As String) As Boolean

    Dim values As Object
    Dim r As COperationResult
    Dim actual As String

    Set values = CreateValues()

    Set r = modSubjectRenderer.RenderSubject( _
        "{{ModelName}}", _
        values, _
        actual)

    If Not RequireSuccess(r, msg) Then Exit Function

    If StrComp(actual, "ABC123", vbBinaryCompare) <> 0 Then
        msg = "Actual=[" & actual & "]"
        Exit Function
    End If

    CheckExtraValueNoOp = True
End Function

Private Function CheckEmptySubject(ByRef msg As String) As Boolean

    Dim values As Object
    Dim r As COperationResult
    Dim actual As String

    Set values = CreateValues()

    Set r = modSubjectRenderer.RenderSubject( _
        vbNullString, _
        values, _
        actual)

    If Not RequireSuccess(r, msg) Then Exit Function

    If Len(actual) <> 0 Then
        msg = "Expected empty subject."
        Exit Function
    End If

    CheckEmptySubject = True
End Function

Private Function CheckNothingFormattedValues(ByRef msg As String) As Boolean

    Dim r As COperationResult
    Dim actual As String

    actual = "stale"

    Set r = modSubjectRenderer.RenderSubject( _
        "{{ModelName}}", _
        Nothing, _
        actual)

    If r Is Nothing Then
        msg = "Result=Nothing"
        Exit Function
    End If

    If r.Success Then
        msg = "Expected Failure."
        Exit Function
    End If

    If Len(actual) <> 0 Then
        msg = "renderedSubject was not reset."
        Exit Function
    End If

    CheckNothingFormattedValues = True
End Function

Private Function CreateValues() As Object

    Dim values As Object

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare

    values.Add "ModelName", "ABC123"
    values.Add "GateDate", "2026/09/30"
    values.Add "Department", "ïiéøïî"
    values.Add "Comment", "ämîFÇ®äËÇ¢ÇµÇ‹Ç∑"

    Set CreateValues = values
End Function

Private Function RequireSuccess( _
    ByVal r As COperationResult, _
    ByRef msg As String _
) As Boolean

    If r Is Nothing Then
        msg = "Result=Nothing"
        Exit Function
    End If

    If Not r.Success Then
        msg = "Operation returned Failure."
        Exit Function
    End If

    RequireSuccess = True
End Function
