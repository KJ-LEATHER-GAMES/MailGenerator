Attribute VB_Name = "modP102InspectorWordEditorTest"
Option Explicit

' P1-02 Inspector / WordEditor Connection Smoke Test v0.2
' Cold Start test never creates Outlook before Production.
' Evidence helpers use GetObject only and never access WordEditor directly.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"
Private Const OL_FOLDER_DRAFTS As Long = 16
Private Const EXPECTED_ERROR_TARGET_MAILITEM As String = "MailItem"
Private Const START_MODE_WARM As String = "WARM"
Private Const START_MODE_COLD As String = "COLD"

Public Sub TestP102InspectorWordEditorConnection()
    TestP102InspectorWordEditorWarmStart
End Sub

Public Sub TestP102InspectorWordEditorWarmStart()
    RunP102InspectorWordEditorSmoke START_MODE_WARM
End Sub

Public Sub TestP102InspectorWordEditorColdStart()
    RunP102InspectorWordEditorSmoke START_MODE_COLD
End Sub

Private Sub RunP102InspectorWordEditorSmoke(ByVal startMode As String)

    Dim result As COperationResult
    Dim cleanupResult As COperationResult
    Dim outlookApp As Object
    Dim templatePath As String
    Dim absolutePath As String
    Dim bodyText As String
    Dim explorerCountBefore As Long
    Dim explorerCountAfterReadiness As Long
    Dim explorerCountAfter As Long
    Dim draftCountBaseline As Long
    Dim draftCountAfter As Long
    Dim inspectorCountBaseline As Long
    Dim inspectorCountAfter As Long
    Dim mailItemActive As Boolean
    Dim testPassed As Boolean
    Dim failureMessage As String
    Dim testName As String

    On Error GoTo UnexpectedError

    testName = "TestP102InspectorWordEditor" & IIf( _
        StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0, _
        "ColdStart", _
        "WarmStart")

    Debug.Print testName & ": START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path
    Debug.Print "Outlook Start State: " & startMode

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        Debug.Print "PRECONDITION: Classic Outlook must be fully closed."
    Else
        Debug.Print "PRECONDITION: Classic Outlook must already be open with at least one Explorer."
    End If

    Debug.Print String$(72, "-")

    ' Defensive adapter cleanup. This must not create Outlook.
    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    Set cleanupResult = Nothing

    ' E1: no active MailItem must fail safely without starting Outlook.
    bodyText = "STALE_VALUE"
    Set result = modOutlookAdapter.ReadBodyText(bodyText)

    If result Is Nothing Then
        failureMessage = "ReadBodyText returned Nothing for the no-active-MailItem case."
        GoTo TestFailed
    End If

    If result.Success Then
        failureMessage = "ReadBodyText unexpectedly succeeded without an active MailItem."
        GoTo TestFailed
    End If

    If Len(bodyText) <> 0 Then
        failureMessage = "ReadBodyText did not clear bodyText on failure."
        GoTo TestFailed
    End If

    If Not ResultContainsTarget(result, EXPECTED_ERROR_TARGET_MAILITEM) Then
        PrintOperationResult "ReadBodyText (no active MailItem)", result
        failureMessage = "Failure Result does not identify MailItem as the problem target."
        GoTo TestFailed
    End If

    Debug.Print "Representative Error / No Active MailItem: PASS"
    Set result = Nothing

    ' Settings / path resolution do not touch Outlook.
    Set result = modSettingsData.GetSettingValue(SETTING_TEMPLATE_PATH, templatePath)
    If Not RequireSuccess("GetSettingValue(TemplatePath)", result, failureMessage) Then GoTo TestFailed

    If Len(Trim$(templatePath)) = 0 Then
        failureMessage = "TemplatePath is empty."
        GoTo TestFailed
    End If

    Debug.Print "TemplatePath: " & templatePath

    Set result = modSettingsData.ResolveWorkbookRelativePath(templatePath, absolutePath)
    If Not RequireSuccess("ResolveWorkbookRelativePath", result, failureMessage) Then GoTo TestFailed

    If Len(Trim$(absolutePath)) = 0 Then
        failureMessage = "Resolved absolute path is empty."
        GoTo TestFailed
    End If

    Debug.Print "ResolvedPath: " & absolutePath
    Debug.Print "Settings / Path Resolution: PASS"

    ' Start-state precondition. GetObject only: never CreateObject in harness.
    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

        If Not outlookApp Is Nothing Then
            failureMessage = "Cold Start precondition failed: Classic Outlook is already running."
            GoTo TestFailed
        End If

        explorerCountBefore = 0
        Debug.Print "Explorer Count Before: 0 (Outlook not running)"
    Else
        Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

        If outlookApp Is Nothing Then
            failureMessage = "Warm Start precondition failed: Classic Outlook is not running."
            GoTo TestFailed
        End If

        If Not TryGetExplorerCount(outlookApp, explorerCountBefore) Then
            failureMessage = "Explorer Count Before could not be obtained."
            GoTo TestFailed
        End If

        If explorerCountBefore < 1 Then
            failureMessage = "Warm Start precondition failed: no Outlook Explorer is open."
            GoTo TestFailed
        End If

        If Not TryGetDraftCount(outlookApp, draftCountBaseline) Then
            failureMessage = "Draft Count Before could not be obtained."
            GoTo TestFailed
        End If

        If Not TryGetInspectorCount(outlookApp, inspectorCountBaseline) Then
            failureMessage = "Inspector Count Before could not be obtained."
            GoTo TestFailed
        End If

        Debug.Print "Explorer Count Before: " & CStr(explorerCountBefore)
        Debug.Print "Draft Count Before: " & CStr(draftCountBaseline)
        Debug.Print "Inspector Count Before: " & CStr(inspectorCountBaseline)
    End If

    ' First operation allowed to start Outlook in Cold Start mode.
    Set result = modOutlookAdapter.CreateMailFromTemplate(absolutePath)
    If Not RequireSuccess("CreateMailFromTemplate", result, failureMessage) Then GoTo TestFailed

    mailItemActive = True
    Debug.Print "CreateMailFromTemplate: PASS"

    ' Evidence after Production readiness.
    If outlookApp Is Nothing Then Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

    If outlookApp Is Nothing Then
        failureMessage = "Classic Outlook is not available after CreateMailFromTemplate."
        GoTo TestFailed
    End If

    If Not TryGetExplorerCount(outlookApp, explorerCountAfterReadiness) Then
        failureMessage = "Explorer Count After Readiness could not be obtained."
        GoTo TestFailed
    End If

    Debug.Print "Explorer Count After Readiness: " & CStr(explorerCountAfterReadiness)

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        If explorerCountAfterReadiness < 1 Then
            failureMessage = "Cold Start readiness did not leave an Outlook Explorer open."
            GoTo TestFailed
        End If

        ' Cold Start baseline is intentionally taken only after Production
        ' starts Outlook; measuring it earlier would invalidate Cold Start.
        If Not TryGetDraftCount(outlookApp, draftCountBaseline) Then
            failureMessage = "Draft Count After Readiness could not be obtained."
            GoTo TestFailed
        End If

        If Not TryGetInspectorCount(outlookApp, inspectorCountBaseline) Then
            failureMessage = "Inspector Count After Readiness could not be obtained."
            GoTo TestFailed
        End If

        Debug.Print "Draft Count After Readiness / Lifecycle Baseline: " & CStr(draftCountBaseline)
        Debug.Print "Inspector Count After Readiness / Lifecycle Baseline: " & CStr(inspectorCountBaseline)
    Else
        If explorerCountAfterReadiness <> explorerCountBefore Then
            failureMessage = _
                "Warm Start created or removed an Explorer. Before=" & CStr(explorerCountBefore) & _
                ", AfterReadiness=" & CStr(explorerCountAfterReadiness)
            GoTo TestFailed
        End If

        Debug.Print "Warm Start Existing Explorer Reuse: PASS"
    End If

    ' Production boundary: no direct WordEditor / Word Document access in harness.
    bodyText = vbNullString
    Set result = modOutlookAdapter.ReadBodyText(bodyText)
    If Not RequireSuccess("ReadBodyText", result, failureMessage) Then GoTo TestFailed

    If Len(bodyText) <= 0 Then
        failureMessage = "Baseline OFT BodyText Length is 0."
        GoTo TestFailed
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))
    Debug.Print "Inspector / WordEditor / Word Document: PASS (indirect)"

    Set result = modOutlookAdapter.CloseWithoutSave()
    If Not RequireSuccess("CloseWithoutSave", result, failureMessage) Then GoTo TestFailed

    mailItemActive = False
    Debug.Print "CloseWithoutSave: PASS"

    DoEvents

    If Not TryGetExplorerCount(outlookApp, explorerCountAfter) Then
        failureMessage = "Explorer Count After could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetDraftCount(outlookApp, draftCountAfter) Then
        failureMessage = "Draft Count After could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetInspectorCount(outlookApp, inspectorCountAfter) Then
        failureMessage = "Inspector Count After could not be obtained."
        GoTo TestFailed
    End If

    Debug.Print "Explorer Count After: " & CStr(explorerCountAfter)
    Debug.Print "Draft Count After: " & CStr(draftCountAfter)
    Debug.Print "Inspector Count After: " & CStr(inspectorCountAfter)

    If explorerCountAfter <> explorerCountAfterReadiness Then
        failureMessage = _
            "Explorer lifecycle mismatch. AfterReadiness=" & CStr(explorerCountAfterReadiness) & _
            ", After=" & CStr(explorerCountAfter)
        GoTo TestFailed
    End If

    If draftCountAfter <> draftCountBaseline Then
        failureMessage = _
            "Draft residue detected. LifecycleBaseline=" & CStr(draftCountBaseline) & _
            ", After=" & CStr(draftCountAfter)
        GoTo TestFailed
    End If

    If inspectorCountAfter <> inspectorCountBaseline Then
        failureMessage = _
            "Inspector residue detected. LifecycleBaseline=" & CStr(inspectorCountBaseline) & _
            ", After=" & CStr(inspectorCountAfter)
        GoTo TestFailed
    End If

    Debug.Print "Explorer Lifecycle: PASS"
    Debug.Print "Draft Residue: NONE"
    Debug.Print "Inspector Residue: NONE"
    Debug.Print "Scan MailItem Display: NONE (verify no message window appeared)"

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        Debug.Print "Cold Start Visible Explorer Initialization: PASS"
    Else
        Debug.Print "Warm Start Existing Explorer Reuse: PASS"
    End If

    testPassed = True
    GoTo Finalize

TestFailed:
    Debug.Print "FAIL: " & failureMessage

Finalize:
    If mailItemActive Then
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()

        If cleanupResult Is Nothing Then
            Debug.Print "Cleanup CloseWithoutSave: FAIL (Nothing result)"
        ElseIf cleanupResult.Success Then
            Debug.Print "Cleanup CloseWithoutSave: PASS"
        Else
            Debug.Print "Cleanup CloseWithoutSave: FAIL"
            PrintOperationResult "Cleanup CloseWithoutSave", cleanupResult
        End If

        Set cleanupResult = Nothing
        mailItemActive = False
    End If

    Set result = Nothing
    Set outlookApp = Nothing

    Debug.Print String$(72, "-")

    If testPassed Then
        Debug.Print testName & ": PASS"
    Else
        Debug.Print testName & ": FAIL"
    End If

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        Debug.Print "POSTCONDITION: Outlook Explorer should remain open. Close Outlook fully before another Cold Start run."
    End If

    Exit Sub

UnexpectedError:
    failureMessage = _
        "Unexpected VBA error in smoke test: " & CStr(Err.Number) & " - " & Err.Description
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
        If StrComp(errorInfo.Target, expectedTarget, vbTextCompare) = 0 Then
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

    Debug.Print operationName & ": Success=" & CStr(result.Success)
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

Private Function TryGetExistingOutlookApplicationForEvidence() As Object
    Dim app As Object

    ' GetObject only. Never CreateObject in the test harness.
    On Error Resume Next
    Set app = GetObject(, "Outlook.Application")
    On Error GoTo 0

    Set TryGetExistingOutlookApplicationForEvidence = app
End Function

Private Function TryGetExplorerCount( _
    ByVal outlookApp As Object, _
    ByRef explorerCount As Long _
) As Boolean

    explorerCount = 0
    TryGetExplorerCount = False

    On Error GoTo CountFailed
    If outlookApp Is Nothing Then Exit Function

    explorerCount = CLng(outlookApp.Explorers.Count)
    TryGetExplorerCount = True
    Exit Function

CountFailed:
    TryGetExplorerCount = False
End Function

Private Function TryGetDraftCount( _
    ByVal outlookApp As Object, _
    ByRef draftCount As Long _
) As Boolean

    Dim outlookNamespace As Object
    Dim draftsFolder As Object

    draftCount = 0
    TryGetDraftCount = False

    On Error GoTo CountFailed
    If outlookApp Is Nothing Then Exit Function

    Set outlookNamespace = outlookApp.GetNamespace("MAPI")
    If outlookNamespace Is Nothing Then Exit Function

    Set draftsFolder = outlookNamespace.GetDefaultFolder(OL_FOLDER_DRAFTS)
    If draftsFolder Is Nothing Then Exit Function

    draftCount = CLng(draftsFolder.Items.Count)
    TryGetDraftCount = True

CleanUp:
    Set draftsFolder = Nothing
    Set outlookNamespace = Nothing
    Exit Function

CountFailed:
    TryGetDraftCount = False
    Resume CleanUp
End Function

Private Function TryGetInspectorCount( _
    ByVal outlookApp As Object, _
    ByRef inspectorCount As Long _
) As Boolean

    inspectorCount = 0
    TryGetInspectorCount = False

    On Error GoTo CountFailed
    If outlookApp Is Nothing Then Exit Function

    inspectorCount = CLng(outlookApp.Inspectors.Count)
    TryGetInspectorCount = True
    Exit Function

CountFailed:
    TryGetInspectorCount = False
End Function
