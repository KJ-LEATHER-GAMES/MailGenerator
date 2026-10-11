Attribute VB_Name = "modP1_05MinimalRenderNegativeTest"
Option Explicit

' P1-05 Minimal Render Negative Verification v0.2
'
' Source:
' - P1-05 Minimal Render 実施仕様 v0.1 / Approved
'
' Cases:
' N1  formattedValues = Nothing
'     - RenderSubject
'     - ReplaceBodyVariables
'
' N2  Active MailItemなし / SetSubject
'
' N3  Active MailItemなし / ReplaceBodyVariables
'     - valid formattedValuesを使用し、FormattedValues Validationで
'       先にFailureしないこと
'
' N4  Missing Formatted Value
'     - Renderer自体はSuccess
'     - Missing tokenはそのまま残る
'
' N5  Body Find 0件
'     - Bodyに存在しないVariableNameだけを渡す
'     - ReplaceBodyVariables = Success
'     - BodyTextは変化しない
'
' N6 WordEditor failure injectionは本Module対象外。
' 安全に再現可能な既存経路がない場合はStatic Review / P6へ残す。

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Public Sub TestP105MinimalRenderNegative()

    Dim allPassed As Boolean
    Dim message As String

    Debug.Print "TestP105MinimalRenderNegative: START"
    Debug.Print String$(72, "-")

    allPassed = True

    message = vbNullString
    If TestN1RenderSubjectNothing(message) Then
        Debug.Print "N1a RenderSubject(Nothing): PASS"
    Else
        Debug.Print "N1a RenderSubject(Nothing): FAIL - " & message
        allPassed = False
    End If

    message = vbNullString
    If TestN1ReplaceBodyNothing(message) Then
        Debug.Print "N1b ReplaceBodyVariables(Nothing): PASS"
    Else
        Debug.Print "N1b ReplaceBodyVariables(Nothing): FAIL - " & message
        allPassed = False
    End If

    message = vbNullString
    If TestN2SetSubjectWithoutActiveMailItem(message) Then
        Debug.Print "N2 SetSubject without Active MailItem: PASS"
    Else
        Debug.Print "N2 SetSubject without Active MailItem: FAIL - " & message
        allPassed = False
    End If

    message = vbNullString
    If TestN3ReplaceBodyWithoutActiveMailItem(message) Then
        Debug.Print "N3 ReplaceBodyVariables without Active MailItem: PASS"
    Else
        Debug.Print "N3 ReplaceBodyVariables without Active MailItem: FAIL - " & message
        allPassed = False
    End If

    message = vbNullString
    If TestN4MissingFormattedValue(message) Then
        Debug.Print "N4 Missing Formatted Value: PASS"
    Else
        Debug.Print "N4 Missing Formatted Value: FAIL - " & message
        allPassed = False
    End If

    message = vbNullString
    If TestN5BodyFindZero(message) Then
        Debug.Print "N5 Body Find 0: PASS"
    Else
        Debug.Print "N5 Body Find 0: FAIL - " & message
        allPassed = False
    End If

    Debug.Print String$(72, "-")
    Debug.Print "TestP105MinimalRenderNegative: " & _
        IIf(allPassed, "PASS", "FAIL")
End Sub

Private Function TestN1RenderSubjectNothing( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult
    Dim renderedSubject As String

    renderedSubject = "stale-value"

    Set result = modSubjectRenderer.RenderSubject( _
        "{{ModelName}}", _
        Nothing, _
        renderedSubject)

    If result Is Nothing Then
        message = "Result=Nothing"
        Exit Function
    End If

    If result.Success Then
        message = "Expected Failure."
        Exit Function
    End If

    If Len(renderedSubject) <> 0 Then
        message = "renderedSubject was not reset to vbNullString."
        Exit Function
    End If

    TestN1RenderSubjectNothing = True
End Function

Private Function TestN1ReplaceBodyNothing( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult

    EnsureNoActiveMailItem

    Set result = modOutlookAdapter.ReplaceBodyVariables(Nothing)

    If result Is Nothing Then
        message = "Result=Nothing"
        Exit Function
    End If

    If result.Success Then
        message = "Expected Failure."
        Exit Function
    End If

    TestN1ReplaceBodyNothing = True
End Function

Private Function TestN2SetSubjectWithoutActiveMailItem( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult

    EnsureNoActiveMailItem

    Set result = modOutlookAdapter.SetSubject("test")

    If result Is Nothing Then
        message = "Result=Nothing"
        Exit Function
    End If

    If result.Success Then
        message = "Expected Failure."
        Exit Function
    End If

    TestN2SetSubjectWithoutActiveMailItem = True
End Function

Private Function TestN3ReplaceBodyWithoutActiveMailItem( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult
    Dim values As Object

    EnsureNoActiveMailItem

    Set values = CreateValidFormattedValues()

    Set result = modOutlookAdapter.ReplaceBodyVariables(values)

    If result Is Nothing Then
        message = "Result=Nothing"
        Exit Function
    End If

    If result.Success Then
        message = "Expected Failure."
        Exit Function
    End If

    TestN3ReplaceBodyWithoutActiveMailItem = True
End Function

Private Function TestN4MissingFormattedValue( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult
    Dim values As Object
    Dim actual As String
    Dim expected As String

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare
    values.Add "ModelName", "ABC123"

    expected = "ABC123 / {{GateDate}}"

    Set result = modSubjectRenderer.RenderSubject( _
        "{{ModelName}} / {{GateDate}}", _
        values, _
        actual)

    If result Is Nothing Then
        message = "Result=Nothing"
        Exit Function
    End If

    If Not result.Success Then
        message = "Renderer returned Failure."
        Exit Function
    End If

    If StrComp(actual, expected, vbBinaryCompare) <> 0 Then
        message = "Expected=[" & expected & "] Actual=[" & actual & "]"
        Exit Function
    End If

    TestN4MissingFormattedValue = True
End Function

Private Function TestN5BodyFindZero( _
    ByRef message As String _
) As Boolean

    Dim result As COperationResult
    Dim cleanupResult As COperationResult
    Dim values As Object

    Dim templatePath As String
    Dim absolutePath As String
    Dim bodyBefore As String
    Dim bodyAfter As String

    Dim activeMailItem As Boolean

    On Error GoTo ErrorHandler

    EnsureNoActiveMailItem

    Set result = modSettingsData.GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If Not RequireSuccess("GetSettingValue", result, message) Then
        GoTo CleanUp
    End If

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        templatePath, _
        absolutePath)

    If Not RequireSuccess( _
        "ResolveWorkbookRelativePath", _
        result, _
        message) Then

        GoTo CleanUp
    End If

    Set result = modOutlookAdapter.CreateMailFromTemplate(absolutePath)

    If Not RequireSuccess( _
        "CreateMailFromTemplate", _
        result, _
        message) Then

        GoTo CleanUp
    End If

    activeMailItem = True

    Set result = modOutlookAdapter.ReadBodyText(bodyBefore)

    If Not RequireSuccess("ReadBodyText(pre)", result, message) Then
        GoTo CleanUp
    End If

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare

    ' Test Fixture only.
    ' This variable does not exist in the Baseline Body.
    values.Add "P105NotInBody", "dummy"

    Set result = modOutlookAdapter.ReplaceBodyVariables(values)

    If Not RequireSuccess( _
        "ReplaceBodyVariables(Find 0)", _
        result, _
        message) Then

        GoTo CleanUp
    End If

    Set result = modOutlookAdapter.ReadBodyText(bodyAfter)

    If Not RequireSuccess("ReadBodyText(post)", result, message) Then
        GoTo CleanUp
    End If

    If StrComp(bodyBefore, bodyAfter, vbBinaryCompare) <> 0 Then
        message = "BodyText changed even though Find count should be 0."
        GoTo CleanUp
    End If

    TestN5BodyFindZero = True

CleanUp:
    If activeMailItem Then
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()

        If cleanupResult Is Nothing Then
            If TestN5BodyFindZero Then
                TestN5BodyFindZero = False
                message = "CloseWithoutSave returned Nothing."
            End If
        ElseIf Not cleanupResult.Success Then
            If TestN5BodyFindZero Then
                TestN5BodyFindZero = False
                message = "CloseWithoutSave returned Failure."
            End If
        End If
    End If

    Set cleanupResult = Nothing
    Set result = Nothing
    Set values = Nothing
    Exit Function

ErrorHandler:
    message = "Unexpected test runtime error: " & _
        CStr(Err.Number) & " - " & Err.Description

    TestN5BodyFindZero = False
    Resume CleanUp
End Function

Private Function CreateValidFormattedValues() As Object

    Dim values As Object

    Set values = CreateObject("Scripting.Dictionary")
    values.CompareMode = vbTextCompare

    values.Add "ModelName", "ABC123"
    values.Add "GateDate", "2026/09/30"
    values.Add "Department", "品質部"
    values.Add "Comment", "確認お願いします"

    Set CreateValidFormattedValues = values
End Function

Private Function RequireSuccess( _
    ByVal operationName As String, _
    ByVal result As COperationResult, _
    ByRef message As String _
) As Boolean

    If result Is Nothing Then
        message = operationName & ": Result=Nothing"
        Exit Function
    End If

    If Not result.Success Then
        message = operationName & ": Failure"
        Exit Function
    End If

    RequireSuccess = True
End Function

Private Sub EnsureNoActiveMailItem()

    Dim cleanupResult As COperationResult

    ' Best-effort cleanup.
    ' CloseWithoutSave Failure when no active MailItem is acceptable here.
    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    Set cleanupResult = Nothing
End Sub
