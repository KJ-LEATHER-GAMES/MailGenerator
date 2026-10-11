Attribute VB_Name = "modP105MinimalRenderIntegrationTest"
Option Explicit

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"
Private Const KEY_VALID As String = "ValidVariables"
Private Const KEY_INVALID As String = "InvalidCandidates"

Public Sub TestP105MinimalRenderIntegration()

    Dim r As COperationResult
    Dim cleanup As COperationResult

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim values As Object

    Dim templatePath As String
    Dim absolutePath As String

    Dim subjectBefore As String
    Dim bodyBefore As String
    Dim renderedSubject As String
    Dim subjectAfter As String
    Dim bodyAfter As String

    Dim activeMail As Boolean
    Dim ok As Boolean
    Dim msg As String

    On Error GoTo EH

    Debug.Print "TestP105MinimalRenderIntegration: START"
    Debug.Print String$(72, "-")

    ' Best-effort cleanup from a prior interrupted smoke test.
    Set cleanup = modOutlookAdapter.CloseWithoutSave()
    Set cleanup = Nothing

    Set r = modSettingsData.GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If Not RequireSuccess("GetSettingValue", r, msg) Then GoTo Failed

    Set r = modSettingsData.ResolveWorkbookRelativePath( _
        templatePath, _
        absolutePath)

    If Not RequireSuccess("ResolveWorkbookRelativePath", r, msg) Then GoTo Failed

    Debug.Print "TemplatePath: " & templatePath
    Debug.Print "ResolvedPath: " & absolutePath

    Set r = modOutlookAdapter.CreateMailFromTemplate(absolutePath)
    If Not RequireSuccess("CreateMailFromTemplate", r, msg) Then GoTo Failed
    activeMail = True

    Set r = modOutlookAdapter.ReadSubject(subjectBefore)
    If Not RequireSuccess("ReadSubject(pre)", r, msg) Then GoTo Failed

    Set r = modOutlookAdapter.ReadBodyText(bodyBefore)
    If Not RequireSuccess("ReadBodyText(pre)", r, msg) Then GoTo Failed

    Set r = modTemplateScanner.ScanTemplate( _
        subjectBefore, _
        bodyBefore, _
        scanResult)

    If Not RequireSuccess("ScanTemplate", r, msg) Then GoTo Failed

    If scanResult Is Nothing Then
        msg = "scanResult=Nothing"
        GoTo Failed
    End If

    If Not scanResult.Exists(KEY_VALID) Then
        msg = "ValidVariables key missing."
        GoTo Failed
    End If

    If Not scanResult.Exists(KEY_INVALID) Then
        msg = "InvalidCandidates key missing."
        GoTo Failed
    End If

    Set validVariables = scanResult(KEY_VALID)
    Set invalidCandidates = scanResult(KEY_INVALID)

    If invalidCandidates.Count <> 0 Then
        msg = "Precondition Finding: InvalidCandidates.Count=" & _
            CStr(invalidCandidates.Count)
        GoTo Failed
    End If

    If validVariables.Count <> 4 Then
        msg = "Precondition Finding: ValidVariables.Count=" & _
            CStr(validVariables.Count)
        GoTo Failed
    End If

    If Not Contains(validVariables, "ModelName") Then
        msg = "Precondition Finding: ModelName missing."
        GoTo Failed
    End If

    If Not Contains(validVariables, "GateDate") Then
        msg = "Precondition Finding: GateDate missing."
        GoTo Failed
    End If

    If Not Contains(validVariables, "Department") Then
        msg = "Precondition Finding: Department missing."
        GoTo Failed
    End If

    If Not Contains(validVariables, "Comment") Then
        msg = "Precondition Finding: Comment missing."
        GoTo Failed
    End If

    Set values = CreateFormattedValues()

    Set r = modSubjectRenderer.RenderSubject( _
        subjectBefore, _
        values, _
        renderedSubject)

    If Not RequireSuccess("RenderSubject", r, msg) Then GoTo Failed

    Set r = modOutlookAdapter.SetSubject(renderedSubject)
    If Not RequireSuccess("SetSubject", r, msg) Then GoTo Failed

    Set r = modOutlookAdapter.ReplaceBodyVariables(values)
    If Not RequireSuccess("ReplaceBodyVariables", r, msg) Then GoTo Failed

    Set r = modOutlookAdapter.ReadSubject(subjectAfter)
    If Not RequireSuccess("ReadSubject(post)", r, msg) Then GoTo Failed

    Set r = modOutlookAdapter.ReadBodyText(bodyAfter)
    If Not RequireSuccess("ReadBodyText(post)", r, msg) Then GoTo Failed

    If StrComp( _
        subjectAfter, _
        "【ABC123】ゲート審査 2026/09/30 / ABC123", _
        vbBinaryCompare) <> 0 Then

        msg = "Rendered Subject mismatch: [" & subjectAfter & "]"
        GoTo Failed
    End If

    If HasKnownToken(bodyAfter) Then
        msg = "Known baseline token remains in rendered BodyText."
        GoTo Failed
    End If

    If InStr(1, bodyAfter, "ABC123", vbBinaryCompare) = 0 Then
        msg = "Rendered BodyText does not contain ABC123."
        GoTo Failed
    End If

    If InStr(1, bodyAfter, "2026/09/30", vbBinaryCompare) = 0 Then
        msg = "Rendered BodyText does not contain 2026/09/30."
        GoTo Failed
    End If

    If InStr(1, bodyAfter, "品質部", vbBinaryCompare) = 0 Then
        msg = "Rendered BodyText does not contain 品質部."
        GoTo Failed
    End If

    If InStr(1, bodyAfter, "確認お願いします", vbBinaryCompare) = 0 Then
        msg = "Rendered BodyText does not contain Comment value."
        GoTo Failed
    End If

    Debug.Print "ReadSubject(pre): PASS / Length=" & CStr(Len(subjectBefore))
    Debug.Print "ReadBodyText(pre): PASS / Length=" & CStr(Len(bodyBefore))
    Debug.Print "ScanTemplate: PASS"
    Debug.Print "ValidVariables Count: " & CStr(validVariables.Count)
    Debug.Print "InvalidCandidates Count: " & CStr(invalidCandidates.Count)
    Debug.Print "RenderSubject: PASS"
    Debug.Print "SetSubject: PASS"
    Debug.Print "ReplaceBodyVariables: PASS"
    Debug.Print "ReadSubject(post): PASS"
    Debug.Print "Rendered Subject: " & subjectAfter
    Debug.Print "ReadBodyText(post): PASS / Length=" & CStr(Len(bodyAfter))
    Debug.Print "Known Baseline Tokens Remaining: NONE"

    Set r = modOutlookAdapter.CloseWithoutSave()
    If Not RequireSuccess("CloseWithoutSave", r, msg) Then GoTo Failed
    activeMail = False

    ok = True
    GoTo Finish

Failed:
    Debug.Print "FAIL: " & msg

Finish:
    If activeMail Then
        Set cleanup = modOutlookAdapter.CloseWithoutSave()
        Set cleanup = Nothing
    End If

    Debug.Print String$(72, "-")
    Debug.Print "TestP105MinimalRenderIntegration: " & _
        IIf(ok, "PASS", "FAIL")
    Exit Sub

EH:
    msg = CStr(Err.Number) & " - " & Err.Description
    Resume Failed
End Sub

Public Sub TestP105MinimalRenderNegative()

    Dim r As COperationResult
    Dim cleanup As COperationResult
    Dim ok As Boolean

    Debug.Print "TestP105MinimalRenderNegative: START"
    Debug.Print String$(72, "-")

    ok = True

    Set cleanup = modOutlookAdapter.CloseWithoutSave()
    Set cleanup = Nothing

    Set r = modOutlookAdapter.SetSubject("test")
    If r Is Nothing Then
        Debug.Print "N2 SetSubject without Active MailItem: FAIL - Result=Nothing"
        ok = False
    ElseIf r.Success Then
        Debug.Print "N2 SetSubject without Active MailItem: FAIL - Expected Failure"
        ok = False
    Else
        Debug.Print "N2 SetSubject without Active MailItem: PASS"
    End If

    Set r = modOutlookAdapter.ReplaceBodyVariables(Nothing)
    If r Is Nothing Then
        Debug.Print "N3 ReplaceBodyVariables(Nothing): FAIL - Result=Nothing"
        ok = False
    ElseIf r.Success Then
        Debug.Print "N3 ReplaceBodyVariables(Nothing): FAIL - Expected Failure"
        ok = False
    Else
        Debug.Print "N3 ReplaceBodyVariables(Nothing): PASS"
    End If

    Debug.Print String$(72, "-")
    Debug.Print "TestP105MinimalRenderNegative: " & IIf(ok, "PASS", "FAIL")
End Sub

Private Function CreateFormattedValues() As Object

    Dim values As Object

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare

    values.Add "ModelName", "ABC123"
    values.Add "GateDate", "2026/09/30"
    values.Add "Department", "品質部"
    values.Add "Comment", "確認お願いします"

    Set CreateFormattedValues = values
End Function

Private Function RequireSuccess( _
    ByVal operationName As String, _
    ByVal r As COperationResult, _
    ByRef msg As String _
) As Boolean

    If r Is Nothing Then
        msg = operationName & ": Result=Nothing"
        Exit Function
    End If

    If Not r.Success Then
        msg = operationName & ": Failure"
        Exit Function
    End If

    RequireSuccess = True
End Function

Private Function Contains( _
    ByVal values As Collection, _
    ByVal expected As String _
) As Boolean

    Dim item As Variant

    For Each item In values
        If StrComp(CStr(item), expected, vbTextCompare) = 0 Then
            Contains = True
            Exit Function
        End If
    Next item
End Function

Private Function HasKnownToken(ByVal bodyText As String) As Boolean

    If InStr(1, bodyText, "{{ModelName}}", vbTextCompare) > 0 Then
        HasKnownToken = True
        Exit Function
    End If

    If InStr(1, bodyText, "{{GateDate}}", vbTextCompare) > 0 Then
        HasKnownToken = True
        Exit Function
    End If

    If InStr(1, bodyText, "{{Department}}", vbTextCompare) > 0 Then
        HasKnownToken = True
        Exit Function
    End If

    If InStr(1, bodyText, "{{Comment}}", vbTextCompare) > 0 Then
        HasKnownToken = True
        Exit Function
    End If
End Function
