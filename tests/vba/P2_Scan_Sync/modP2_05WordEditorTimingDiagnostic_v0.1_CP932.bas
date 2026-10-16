Attribute VB_Name = "modP2_05WordEditorTimingDiagnostic"
Option Explicit

' Diagnostic-only test artifact for IF-P2-05-001.
'
' Purpose:
' - Compare immediate WordEditor access against a single DoEvents pump.
' - Reproduce the P2-04 pre-scan sequence without modifying Production code.
'
' Production mutation:
' - NONE
' - Creates temporary MailItem from OFT and closes without save.
'
' Do not import this module as Production code.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Public Sub TestP205DiagImmediateNoGuard()
    RunSnapshotVariant "A Immediate / No File Guard", False, False
End Sub

Public Sub TestP205DiagImmediateWithGuard()
    RunSnapshotVariant "B Immediate / With File Guard", True, False
End Sub

Public Sub TestP205DiagDoEventsWithGuard()
    RunSnapshotVariant "C DoEvents / With File Guard", True, True
End Sub

Public Sub TestP205WordEditorTimingDiagnostic()

    Debug.Print String$(72, "-")
    Debug.Print "TestP205WordEditorTimingDiagnostic: START"
    Debug.Print String$(72, "-")

    RunSnapshotVariant "A Immediate / No File Guard", False, False
    RunSnapshotVariant "B Immediate / With File Guard", True, False
    RunSnapshotVariant "C DoEvents / With File Guard", True, True

    Debug.Print String$(72, "-")
    Debug.Print "TestP205WordEditorTimingDiagnostic: END"
    Debug.Print String$(72, "-")

End Sub

Private Sub RunSnapshotVariant( _
    ByVal caseName As String, _
    ByVal useFileGuard As Boolean, _
    ByVal pumpBeforeBody As Boolean _
)

    Dim result As COperationResult
    Dim cleanupResult As COperationResult

    Dim templatePath As String
    Dim resolvedPath As String
    Dim matchedPath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim mailCreated As Boolean
    Dim subjectSucceeded As Boolean
    Dim bodySucceeded As Boolean
    Dim cleanupSucceeded As Boolean

    Dim failureStage As String
    Dim failureDetail As String

    On Error GoTo UnexpectedError

    ' No Debug.Print is intentionally executed between
    ' CreateMailFromTemplate -> ReadSubject -> ReadBodyText.

    Set result = GetSettingValue(SETTING_TEMPLATE_PATH, templatePath)
    If result Is Nothing Then
        failureStage = "GetSettingValue / Nothing Result"
        GoTo Finish
    End If
    If Not result.Success Then
        failureStage = "GetSettingValue"
        failureDetail = ResultSummary(result)
        GoTo Finish
    End If

    Set result = ResolveWorkbookRelativePath(templatePath, resolvedPath)
    If result Is Nothing Then
        failureStage = "ResolveWorkbookRelativePath / Nothing Result"
        GoTo Finish
    End If
    If Not result.Success Then
        failureStage = "ResolveWorkbookRelativePath"
        failureDetail = ResultSummary(result)
        GoTo Finish
    End If

    If useFileGuard Then
        matchedPath = Dir$( _
            resolvedPath, _
            vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

        If Len(matchedPath) = 0 Then
            failureStage = "File Guard"
            failureDetail = "Template file does not exist."
            GoTo Finish
        End If
    End If

    Set result = CreateMailFromTemplate(resolvedPath)
    If result Is Nothing Then
        failureStage = "CreateMailFromTemplate / Nothing Result"
        GoTo Finish
    End If
    If Not result.Success Then
        failureStage = "CreateMailFromTemplate"
        failureDetail = ResultSummary(result)
        GoTo Finish
    End If

    mailCreated = True

    Set result = ReadSubject(subjectText)
    If result Is Nothing Then
        failureStage = "ReadSubject / Nothing Result"
        GoTo Finish
    End If
    If Not result.Success Then
        failureStage = "ReadSubject"
        failureDetail = ResultSummary(result)
        GoTo Finish
    End If

    subjectSucceeded = True

    If pumpBeforeBody Then
        DoEvents
    End If

    Set result = ReadBodyText(bodyText)
    If result Is Nothing Then
        failureStage = "ReadBodyText / Nothing Result"
        GoTo Finish
    End If
    If Not result.Success Then
        failureStage = "ReadBodyText"
        failureDetail = ResultSummary(result)
        GoTo Finish
    End If

    bodySucceeded = True

Finish:

    If mailCreated Then
        Set cleanupResult = CloseWithoutSave()

        If Not cleanupResult Is Nothing Then
            cleanupSucceeded = cleanupResult.Success
        End If
    End If

    Debug.Print String$(72, "-")
    Debug.Print "Case: " & caseName
    Debug.Print "Use File Guard: " & CStr(useFileGuard)
    Debug.Print "Pump Before Body: " & CStr(pumpBeforeBody)
    Debug.Print "ResolvedPath: " & resolvedPath
    Debug.Print "ReadSubject: " & PassFail(subjectSucceeded)

    If subjectSucceeded Then
        Debug.Print "Subject Length: " & CStr(Len(subjectText))
    End If

    Debug.Print "ReadBodyText: " & PassFail(bodySucceeded)

    If bodySucceeded Then
        Debug.Print "BodyText Length: " & CStr(Len(bodyText))
    End If

    If Len(failureStage) > 0 Then
        Debug.Print "Failure Stage: " & failureStage
    End If

    If Len(failureDetail) > 0 Then
        Debug.Print "Failure Detail: " & failureDetail
    End If

    If mailCreated Then
        Debug.Print "CloseWithoutSave: " & PassFail(cleanupSucceeded)
    Else
        Debug.Print "CloseWithoutSave: N/A"
    End If

    If bodySucceeded And (Not mailCreated Or cleanupSucceeded) Then
        Debug.Print "RESULT: PASS"
    Else
        Debug.Print "RESULT: FAIL"
    End If

    Set cleanupResult = Nothing
    Set result = Nothing
    Exit Sub

UnexpectedError:

    failureStage = "Unexpected VBA Error"
    failureDetail = CStr(Err.Number) & " - " & Err.Description

    Resume Finish

End Sub

Private Function ResultSummary( _
    ByVal operationResult As COperationResult _
) As String

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim textValue As String

    On Error GoTo SafeExit

    If operationResult Is Nothing Then
        ResultSummary = "Result = Nothing"
        Exit Function
    End If

    Set errors = operationResult.Errors

    For Each errorInfo In errors

        If Len(textValue) > 0 Then
            textValue = textValue & " | "
        End If

        textValue = textValue & _
            "ErrorType=" & errorInfo.ErrorType & _
            "; Target=" & errorInfo.Target & _
            "; Message=" & errorInfo.Message

    Next errorInfo

SafeExit:
    ResultSummary = textValue

    Set errorInfo = Nothing
    Set errors = Nothing

End Function

Private Function PassFail( _
    ByVal value As Boolean _
) As String

    If value Then
        PassFail = "PASS"
    Else
        PassFail = "FAIL"
    End If

End Function
