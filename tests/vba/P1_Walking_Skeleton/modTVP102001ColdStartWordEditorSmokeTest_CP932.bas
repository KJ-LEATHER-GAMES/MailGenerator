Attribute VB_Name = "modTVP102001ColdStartWordEditorTest"
Option Explicit

' TV-P1-02-001
' Classic Outlook Cold Start / WordEditor Initialization
'
' IMPORTANT:
' - Run each test from a true Cold Start.
' - Close Classic Outlook completely between cases.
' - This module is Technical Verification only.
' - It does not access WordEditor / Word Document directly.
' - Production access remains:
'     CreateMailFromTemplate -> ReadBodyText -> CloseWithoutSave

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"
Private Const OL_FOLDER_INBOX As Long = 6
Private Const OL_FOLDER_DRAFTS As Long = 16
Private Const OL_FOLDER_DISPLAY_NORMAL As Long = 0

Public Sub TestTVP102001_HiddenExplorer()

    RunColdStartCandidate False

End Sub

Public Sub TestTVP102001_VisibleExplorer()

    RunColdStartCandidate True

End Sub

Private Sub RunColdStartCandidate( _
    ByVal displayExplorer As Boolean _
)

    Dim outlookApp As Object
    Dim outlookNamespace As Object
    Dim inboxFolder As Object
    Dim explorer As Object

    Dim result As COperationResult
    Dim cleanupResult As COperationResult

    Dim templatePath As String
    Dim absolutePath As String
    Dim bodyText As String

    Dim explorerCountBefore As Long
    Dim explorerCountAfterInit As Long
    Dim draftCountBefore As Long
    Dim draftCountAfter As Long
    Dim inspectorCountBefore As Long
    Dim inspectorCountAfter As Long

    Dim mailItemActive As Boolean
    Dim testPassed As Boolean
    Dim failureMessage As String
    Dim caseName As String

    On Error GoTo UnexpectedError

    If displayExplorer Then
        caseName = "TV-C02 Visible Explorer"
    Else
        caseName = "TV-C01 Hidden Explorer"
    End If

    Debug.Print caseName & ": START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print "ThisWorkbook.Path: " & ThisWorkbook.Path
    Debug.Print "PRECONDITION: Classic Outlook must be fully closed before this test."
    Debug.Print String$(72, "-")

    ' Defensive cleanup of adapter-owned MailItem.
    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    Set cleanupResult = Nothing

    ' ------------------------------------------------------------
    ' Candidate initialization.
    ' ------------------------------------------------------------
    Set outlookApp = CreateObject("Outlook.Application")

    If outlookApp Is Nothing Then
        failureMessage = "CreateObject(Outlook.Application) returned Nothing."
        GoTo TestFailed
    End If

    explorerCountBefore = CLng(outlookApp.Explorers.Count)

    Set outlookNamespace = outlookApp.GetNamespace("MAPI")
    If outlookNamespace Is Nothing Then
        failureMessage = "GetNamespace(MAPI) returned Nothing."
        GoTo TestFailed
    End If

    Set inboxFolder = outlookNamespace.GetDefaultFolder(OL_FOLDER_INBOX)
    If inboxFolder Is Nothing Then
        failureMessage = "Default Inbox folder could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetDraftCount(outlookApp, draftCountBefore) Then
        failureMessage = "Draft Count Before could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetInspectorCount(outlookApp, inspectorCountBefore) Then
        failureMessage = "Inspector Count Before could not be obtained."
        GoTo TestFailed
    End If

    Set explorer = outlookApp.Explorers.Add( _
        inboxFolder, _
        OL_FOLDER_DISPLAY_NORMAL)

    If explorer Is Nothing Then
        failureMessage = "Explorers.Add returned Nothing."
        GoTo TestFailed
    End If

    explorerCountAfterInit = CLng(outlookApp.Explorers.Count)

    Debug.Print "Explorer Count Before: " & CStr(explorerCountBefore)
    Debug.Print "Explorer Count After Initialization: " & CStr(explorerCountAfterInit)

    If displayExplorer Then
        explorer.Display
        DoEvents
        Debug.Print "Explorer Initialization: VISIBLE"
    Else
        Debug.Print "Explorer Initialization: HIDDEN"
        Debug.Print "Expected visible Outlook Explorer: NONE"
    End If

    Debug.Print "Draft Count Before: " & CStr(draftCountBefore)
    Debug.Print "Inspector Count Before: " & CStr(inspectorCountBefore)

    ' ------------------------------------------------------------
    ' Production path prerequisite.
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

    Set result = modSettingsData.ResolveWorkbookRelativePath( _
        templatePath, _
        absolutePath)

    If Not RequireSuccess( _
        "ResolveWorkbookRelativePath", _
        result, _
        failureMessage) Then
        GoTo TestFailed
    End If

    Debug.Print "TemplatePath: " & templatePath
    Debug.Print "ResolvedPath: " & absolutePath

    ' ------------------------------------------------------------
    ' Production boundary.
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

    bodyText = vbNullString
    Set result = modOutlookAdapter.ReadBodyText(bodyText)

    If Not RequireSuccess( _
        "ReadBodyText", _
        result, _
        failureMessage) Then
        GoTo TestFailed
    End If

    If Len(bodyText) <= 0 Then
        failureMessage = "BodyText Length is 0."
        GoTo TestFailed
    End If

    Debug.Print "ReadBodyText: PASS"
    Debug.Print "BodyText Length: " & CStr(Len(bodyText))
    Debug.Print "Inspector / WordEditor / Word Document: PASS (indirect)"

    Set result = modOutlookAdapter.CloseWithoutSave()

    If Not RequireSuccess( _
        "CloseWithoutSave", _
        result, _
        failureMessage) Then
        GoTo TestFailed
    End If

    mailItemActive = False
    Debug.Print "CloseWithoutSave: PASS"

    DoEvents

    If Not TryGetDraftCount(outlookApp, draftCountAfter) Then
        failureMessage = "Draft Count After could not be obtained."
        GoTo TestFailed
    End If

    If Not TryGetInspectorCount(outlookApp, inspectorCountAfter) Then
        failureMessage = "Inspector Count After could not be obtained."
        GoTo TestFailed
    End If

    Debug.Print "Draft Count After: " & CStr(draftCountAfter)
    Debug.Print "Inspector Count After: " & CStr(inspectorCountAfter)

    If draftCountAfter <> draftCountBefore Then
        failureMessage = _
            "Draft residue detected. Before=" & _
            CStr(draftCountBefore) & _
            ", After=" & _
            CStr(draftCountAfter)
        GoTo TestFailed
    End If

    If inspectorCountAfter <> inspectorCountBefore Then
        failureMessage = _
            "Inspector residue detected. Before=" & _
            CStr(inspectorCountBefore) & _
            ", After=" & _
            CStr(inspectorCountAfter)
        GoTo TestFailed
    End If

    Debug.Print "Draft Residue: NONE"
    Debug.Print "Inspector Residue: NONE"
    Debug.Print "MailItem Display: NONE"

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
            PrintOperationResult _
                "Cleanup CloseWithoutSave", _
                cleanupResult
        End If

        Set cleanupResult = Nothing
        mailItemActive = False
    End If

    On Error Resume Next
    If Not explorer Is Nothing Then explorer.Close
    On Error GoTo 0

    Set explorer = Nothing
    Set inboxFolder = Nothing
    Set outlookNamespace = Nothing
    Set outlookApp = Nothing
    Set result = Nothing

    Debug.Print String$(72, "-")

    If testPassed Then
        Debug.Print caseName & ": PASS"
    Else
        Debug.Print caseName & ": FAIL"
    End If

    Debug.Print _
        "POSTCONDITION: Close Classic Outlook fully before another Cold Start case."

    Exit Sub

UnexpectedError:
    failureMessage = _
        "Unexpected VBA error in TV harness: " & _
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

    Set draftsFolder = _
        outlookNamespace.GetDefaultFolder(OL_FOLDER_DRAFTS)

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
