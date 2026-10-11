Attribute VB_Name = "modP102InspectorWordEditorTest"
Option Explicit

' P1-02 Inspector / WordEditor Connection Smoke Test v0.2.2
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
    Dim explorerCountLifecycleBaseline As Long
    Dim explorerCountAfter As Long

    Dim draftCountBaseline As Long
    Dim draftCountAfter As Long
    Dim inspectorCountBaseline As Long
    Dim inspectorCountDuring As Long
    Dim inspectorCountAfter As Long

    Dim mailItemActive As Boolean
    Dim productionFunctionalPassed As Boolean
    Dim lifecycleBaselineAvailable As Boolean
    Dim testPassed As Boolean
    Dim testBlocked As Boolean

    Dim failureMessage As String
    Dim blockedMessage As String
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

    ' ------------------------------------------------------------
    ' E1: no active MailItem must fail safely.
    ' This must not start Outlook.
    ' ------------------------------------------------------------
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

    ' ------------------------------------------------------------
    ' P1-01 prerequisite: Settings + Workbook-relative path.
    ' Safe before the Cold Start precondition check.
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
    ' Start-state precondition.
    ' Evidence helper uses GetObject only and never CreateObject.
    ' ------------------------------------------------------------
    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then

        Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

        If Not outlookApp Is Nothing Then
            failureMessage = "Cold Start precondition failed: Classic Outlook is already running."
            GoTo TestFailed
        End If

        explorerCountBefore = 0
        inspectorCountBaseline = 0
        Debug.Print "Explorer Count Before: 0 (Outlook not running)"
        Debug.Print "Inspector Count Before: 0 (inferred from Outlook not running)"

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

        explorerCountLifecycleBaseline = explorerCountBefore
        lifecycleBaselineAvailable = True

        Debug.Print "Explorer Count Before: " & CStr(explorerCountBefore)
        Debug.Print "Draft Count Before: " & CStr(draftCountBaseline)
        Debug.Print "Inspector Count Before: " & CStr(inspectorCountBaseline)

    End If

    ' ------------------------------------------------------------
    ' Production Functional Path.
    '
    ' In Cold Start mode, no evidence reacquisition is allowed between
    ' CreateMailFromTemplate and ReadBodyText. The previous v0.2 harness
    ' incorrectly blocked here when GetObject could not immediately
    ' reacquire the Outlook.Application started by Production.
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

    If StrComp(startMode, START_MODE_WARM, vbTextCompare) = 0 Then

        If Not TryGetExplorerCount( _
            outlookApp, _
            explorerCountLifecycleBaseline) Then

            failureMessage = "Explorer Count After Readiness could not be obtained."
            GoTo TestFailed
        End If

        Debug.Print _
            "Explorer Count After Readiness: " & _
            CStr(explorerCountLifecycleBaseline)

        If explorerCountLifecycleBaseline <> explorerCountBefore Then
            failureMessage = _
                "Warm Start created or removed an Explorer. Before=" & _
                CStr(explorerCountBefore) & _
                ", AfterReadiness=" & _
                CStr(explorerCountLifecycleBaseline)

            GoTo TestFailed
        End If

        Debug.Print "Warm Start Existing Explorer Reuse: PASS"

    Else
        Debug.Print _
            "Cold Start Evidence Reacquisition: DEFERRED until after ReadBodyText."
    End If

    ' ------------------------------------------------------------
    ' Production WordEditor boundary.
    ' Harness never accesses Inspector / WordEditor / Word Document.
    ' ------------------------------------------------------------
    bodyText = vbNullString
    Set result = modOutlookAdapter.ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "ReadBodyText", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    If Len(bodyText) <= 0 Then
        failureMessage = "Baseline OFT BodyText Length is 0."
        GoTo TestFailed
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))
    Debug.Print "Inspector / WordEditor / Word Document: PASS (indirect)"

    ' ------------------------------------------------------------
    ' Cold Start lifecycle baseline acquisition.
    '
    ' This evidence is intentionally collected only AFTER the Production
    ' WordEditor path has succeeded. Failure to reacquire Outlook here
    ' must not convert the Production functional path into a FAIL.
    ' ------------------------------------------------------------
    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then

        Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

        If outlookApp Is Nothing Then

            Debug.Print _
                "Cold Start Evidence Reacquisition After ReadBodyText: BLOCKED"
            Debug.Print _
                "Production Functional Path continues to CloseWithoutSave."

        Else

            If TryGetExplorerCount( _
                outlookApp, _
                explorerCountLifecycleBaseline) And _
               TryGetDraftCount( _
                outlookApp, _
                draftCountBaseline) And _
               TryGetInspectorCount( _
                outlookApp, _
                inspectorCountDuring) Then

                lifecycleBaselineAvailable = True

                Debug.Print _
                    "Cold Start Evidence Reacquisition After ReadBodyText: PASS"
                Debug.Print _
                    "Explorer Count Lifecycle Baseline: " & _
                    CStr(explorerCountLifecycleBaseline)
                Debug.Print _
                    "Draft Count Lifecycle Baseline: " & _
                    CStr(draftCountBaseline)
                Debug.Print _
                    "Inspector Count During ReadBodyText: " & _
                    CStr(inspectorCountDuring)

            Else

                Set outlookApp = Nothing

                Debug.Print _
                    "Cold Start Lifecycle Baseline Acquisition: BLOCKED"
                Debug.Print _
                    "Production Functional Path continues to CloseWithoutSave."

            End If

        End If

    End If

    ' ------------------------------------------------------------
    ' Production MailItem cleanup.
    ' This must be attempted regardless of lifecycle evidence availability.
    ' ------------------------------------------------------------
    Set result = modOutlookAdapter.CloseWithoutSave()

    If Not RequireSuccess( _
        "CloseWithoutSave", _
        result, _
        failureMessage) Then

        GoTo TestFailed
    End If

    mailItemActive = False
    productionFunctionalPassed = True

    Debug.Print "CloseWithoutSave: PASS"
    Debug.Print "Production Functional Path: PASS"

    DoEvents

    ' ------------------------------------------------------------
    ' Lifecycle Evidence.
    '
    ' Warm Start always has a baseline.
    ' Cold Start may be BLOCKED if GetObject cannot reacquire the
    ' Production-started Outlook.Application. That is an evidence problem,
    ' not a Production functional failure.
    ' ------------------------------------------------------------
    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 And _
       outlookApp Is Nothing Then

        Set outlookApp = TryGetExistingOutlookApplicationForEvidence()

        If outlookApp Is Nothing Then
            testBlocked = True
            blockedMessage = _
                "Lifecycle Evidence blocked: GetObject could not reacquire " & _
                "the Production-started Outlook.Application after " & _
                "CloseWithoutSave."

            Debug.Print "Lifecycle Evidence: BLOCKED"
            Debug.Print blockedMessage
            GoTo Finalize
        End If

        ' Reacquisition only after Close cannot recreate a valid before/after
        ' Draft/Inspector baseline, so do not claim residue PASS.
        If Not TryGetExplorerCount(outlookApp, explorerCountAfter) Then
            testBlocked = True
            blockedMessage = _
                "Lifecycle Evidence blocked: Explorer Count After " & _
                "could not be obtained."

            Debug.Print "Lifecycle Evidence: BLOCKED"
            Debug.Print blockedMessage
            GoTo Finalize
        End If

        Debug.Print _
            "Cold Start Evidence Reacquisition After CloseWithoutSave: PASS"
        Debug.Print "Explorer Count After: " & CStr(explorerCountAfter)

        If explorerCountAfter < 1 Then
            failureMessage = _
                "Cold Start Explorer is not open after CloseWithoutSave."
            GoTo TestFailed
        End If

        testBlocked = True
        blockedMessage = _
            "Explorer persistence was observed, but Draft/Inspector " & _
            "before/after lifecycle baseline was unavailable."

        Debug.Print "Explorer Lifecycle: PASS (post-close observation)"
        Debug.Print "Draft / Inspector Residue Evidence: BLOCKED"
        Debug.Print blockedMessage
        GoTo Finalize

    End If

    If Not lifecycleBaselineAvailable Then
        testBlocked = True
        blockedMessage = _
            "Lifecycle Evidence baseline is unavailable."

        Debug.Print "Lifecycle Evidence: BLOCKED"
        Debug.Print blockedMessage
        GoTo Finalize
    End If

    If Not TryGetExplorerCount( _
        outlookApp, _
        explorerCountAfter) Then

        failureMessage = "Explorer Count After could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetDraftCount( _
        outlookApp, _
        draftCountAfter) Then

        failureMessage = "Draft Count After could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetInspectorCount( _
        outlookApp, _
        inspectorCountAfter) Then

        failureMessage = "Inspector Count After could not be obtained."
        GoTo TestFailed
    End If

    Debug.Print "Explorer Count After: " & CStr(explorerCountAfter)
    Debug.Print "Draft Count After: " & CStr(draftCountAfter)
    Debug.Print "Inspector Count After: " & CStr(inspectorCountAfter)

    If explorerCountAfter <> explorerCountLifecycleBaseline Then
        failureMessage = _
            "Explorer lifecycle mismatch. Baseline=" & _
            CStr(explorerCountLifecycleBaseline) & _
            ", After=" & CStr(explorerCountAfter)

        GoTo TestFailed
    End If

    If draftCountAfter <> draftCountBaseline Then
        failureMessage = _
            "Draft residue detected. LifecycleBaseline=" & _
            CStr(draftCountBaseline) & _
            ", After=" & CStr(draftCountAfter)

        GoTo TestFailed
    End If

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then

        If inspectorCountAfter <> 0 Then
            failureMessage = _
                "Inspector residue detected after Cold Start. Expected=0" & _
                ", After=" & CStr(inspectorCountAfter)

            GoTo TestFailed
        End If

    Else

        If inspectorCountAfter <> inspectorCountBaseline Then
            failureMessage = _
                "Inspector residue detected. Before=" & _
                CStr(inspectorCountBaseline) & _
                ", After=" & CStr(inspectorCountAfter)

            GoTo TestFailed
        End If

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

    ' Cleanup must be attempted on both success and failure.
    ' CloseWithoutSave never closes the Outlook Explorer.
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
    Set outlookApp = Nothing

    Debug.Print String$(72, "-")

    If testBlocked And productionFunctionalPassed Then
        Debug.Print _
            testName & _
            ": BLOCKED (Production Functional Path PASS)"
    ElseIf testPassed Then
        Debug.Print testName & ": PASS"
    Else
        Debug.Print testName & ": FAIL"
    End If

    If StrComp(startMode, START_MODE_COLD, vbTextCompare) = 0 Then
        Debug.Print _
            "POSTCONDITION: Outlook Explorer should remain open. " & _
            "Close Outlook fully before another Cold Start run."
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
