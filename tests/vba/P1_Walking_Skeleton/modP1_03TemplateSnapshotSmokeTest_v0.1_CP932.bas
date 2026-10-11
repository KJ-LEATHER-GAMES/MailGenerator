Attribute VB_Name = "modP103TemplateSnapshotTest"
Option Explicit

' P1-03 Template Snapshot Boundary Smoke Test v0.1
'
' Scope:
' - Production ReadSubject()
' - Existing Production ReadBodyText()
' - Same active MailItem lifecycle
' - Snapshot boundary = Subject String + BodyText String
'
' Out of scope:
' - Scanner
' - Renderer
' - Unresolved Checker
' - Lifecycle evidence already covered by P1-02 v0.2.2 regression

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"
Private Const EXPECTED_ERROR_TARGET_MAILITEM As String = "MailItem"

Public Sub TestP103TemplateSnapshotBoundary()

    Dim result As COperationResult
    Dim cleanupResult As COperationResult

    Dim templatePath As String
    Dim absolutePath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim mailItemActive As Boolean
    Dim snapshotEstablished As Boolean
    Dim testPassed As Boolean
    Dim failureMessage As String

    On Error GoTo UnexpectedError

    Debug.Print "TestP103TemplateSnapshotBoundary: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path
    Debug.Print String$(72, "-")

    ' Defensive cleanup. This does not create Outlook.
    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    Set cleanupResult = Nothing

    ' ------------------------------------------------------------
    ' N1: ReadSubject without an active MailItem must fail safely.
    ' ------------------------------------------------------------
    subjectText = "STALE_VALUE"
    Set result = modOutlookAdapter.ReadSubject(subjectText)

    If result Is Nothing Then
        failureMessage = _
            "ReadSubject returned Nothing for the no-active-MailItem case."
        GoTo TestFailed
    End If

    If result.Success Then
        failureMessage = _
            "ReadSubject unexpectedly succeeded without an active MailItem."
        GoTo TestFailed
    End If

    If Len(subjectText) <> 0 Then
        failureMessage = _
            "ReadSubject did not clear subjectText on failure."
        GoTo TestFailed
    End If

    If Not ResultContainsTarget( _
        result, _
        EXPECTED_ERROR_TARGET_MAILITEM) Then

        PrintOperationResult _
            "ReadSubject (no active MailItem)", _
            result

        failureMessage = _
            "ReadSubject failure does not identify MailItem as the target."
        GoTo TestFailed
    End If

    Debug.Print "ReadSubject / No Active MailItem: PASS"
    Set result = Nothing

    ' ------------------------------------------------------------
    ' P1-01 prerequisite: Settings + local OFT path resolution.
    ' ------------------------------------------------------------
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

    ' ------------------------------------------------------------
    ' Production MailItem lifecycle starts here.
    ' Create once. Read Subject and Body from the same adapter state.
    ' ------------------------------------------------------------
    Set result = modOutlookAdapter.CreateMailFromTemplate(absolutePath)

    If Not RequireSuccess( _
        "CreateMailFromTemplate", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    mailItemActive = True
    Debug.Print "CreateMailFromTemplate: PASS"

    ' ------------------------------------------------------------
    ' Subject Snapshot
    ' ------------------------------------------------------------
    subjectText = "STALE_VALUE"
    Set result = modOutlookAdapter.ReadSubject(subjectText)

    If Not RequireSuccess( _
        "ReadSubject", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Len(subjectText) = 0 Then
        failureMessage = _
            "Baseline OFT Subject is empty. Expected Subject Length > 0."
        GoTo TestFailed
    End If

    Debug.Print "ReadSubject: PASS"
    Debug.Print "Subject Length: " & CStr(Len(subjectText))
    Debug.Print "Subject Snapshot: " & subjectText

    ' ------------------------------------------------------------
    ' BodyText Snapshot
    ' Existing P1-02 Production API is reused unchanged.
    ' ------------------------------------------------------------
    bodyText = "STALE_VALUE"
    Set result = modOutlookAdapter.ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "ReadBodyText", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Len(bodyText) = 0 Then
        failureMessage = _
            "Baseline OFT BodyText is empty. Expected BodyText Length > 0."
        GoTo TestFailed
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))

    ' Both reads occurred after one CreateMailFromTemplate call and before
    ' any Close/re-create operation. The private adapter MailItem therefore
    ' defines one active MailItem lifecycle for both snapshots.
    snapshotEstablished = True

    Debug.Print _
        "Same Active MailItem Boundary: CONFIRMED " & _
        "(single adapter lifecycle)"
    Debug.Print "Snapshot Boundary: ESTABLISHED"

    ' ------------------------------------------------------------
    ' Cleanup
    ' ------------------------------------------------------------
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
    snapshotEstablished = False
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

    Set result = Nothing

    Debug.Print String$(72, "-")
    Debug.Print _
        "Snapshot Boundary Result: " & _
        IIf(snapshotEstablished, "ESTABLISHED", "NOT ESTABLISHED")

    If testPassed Then
        Debug.Print "TestP103TemplateSnapshotBoundary: PASS"
    Else
        Debug.Print "TestP103TemplateSnapshotBoundary: FAIL"
    End If

    Exit Sub

UnexpectedError:
    failureMessage = _
        "Unexpected VBA error in smoke test: " & _
        CStr(Err.Number) & " - " & Err.Description

    Resume TestFailed

End Sub

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

Private Function ResultContainsTarget( _
    ByVal result As COperationResult, _
    ByVal expectedTarget As String _
) As Boolean

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    ResultContainsTarget = False
    If result Is Nothing Then Exit Function

    Set errors = result.Errors

    For Each errorInfo In errors
        If StrComp( _
            errorInfo.Target, _
            expectedTarget, _
            vbTextCompare) = 0 Then

            ResultContainsTarget = True
            Exit For
        End If
    Next errorInfo

    Set errorInfo = Nothing
    Set errors = Nothing
End Function

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
