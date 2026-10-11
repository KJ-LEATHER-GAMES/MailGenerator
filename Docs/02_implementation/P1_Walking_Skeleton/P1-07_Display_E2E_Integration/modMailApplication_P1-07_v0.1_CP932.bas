Attribute VB_Name = "modMailApplication"
Option Explicit

' P1-07 Display / E2E Integration
'
' Responsibility:
' - Orchestrate the P1 Walking Skeleton production flow
' - Enforce the positive-allow Display Gate
' - Request CloseWithoutSave on pre-display failure
'
' Non-responsibility:
' - Outlook / Word COM access
' - Token scanning implementation
' - Rendering implementation
' - Final error taxonomy / user-facing error UI
' - Current Data Guard (P5)
'
' Formal error integration / precedence is finalized in P6.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Private Const KEY_HAS_UNRESOLVED As String = "HasUnresolved"
Private Const KEY_VARIABLES As String = "Variables"

Private Const ERROR_TYPE_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"

Private Const TARGET_MAIL_APPLICATION As String = "MailApplication"
Private Const TARGET_TEMPLATE_SCAN_RESULT As String = "TemplateScanResult"
Private Const TARGET_UNRESOLVED_RESULT As String = "UnresolvedResult"
Private Const TARGET_MAIL_CLEANUP As String = "MailItemCleanup"

Public Function CreateMailForDisplay( _
    ByVal formattedValues As Object, _
    ByRef unresolvedResult As Object _
) As COperationResult

    Dim stepResult As COperationResult
    Dim primaryFailure As COperationResult
    Dim gateResult As COperationResult

    Dim templatePath As String
    Dim resolvedTemplatePath As String

    Dim subjectText As String
    Dim bodyText As String
    Dim renderedSubject As String

    Dim scanResult As Object

    Dim hasUnresolved As Boolean
    Dim mailCreated As Boolean

    Set unresolvedResult = Nothing

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Settings / path
    ' --------------------------------------------------------
    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If stepResult Is Nothing Then
        Set CreateMailForDisplay = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Settings access did not return an operation result.", _
            SETTING_TEMPLATE_PATH)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = stepResult
        GoTo CleanUp
    End If

    Set stepResult = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedTemplatePath)

    If stepResult Is Nothing Then
        Set CreateMailForDisplay = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template path resolution did not return an operation result.", _
            SETTING_TEMPLATE_PATH)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = stepResult
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Create active MailItem.
    ' Classic Outlook readiness remains inside modOutlookAdapter.
    ' --------------------------------------------------------
    Set stepResult = CreateMailFromTemplate(resolvedTemplatePath)

    If stepResult Is Nothing Then
        Set CreateMailForDisplay = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "MailItem creation did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = stepResult
        GoTo CleanUp
    End If

    mailCreated = True

    ' --------------------------------------------------------
    ' Pre-render snapshot
    ' --------------------------------------------------------
    Set stepResult = ReadSubject(subjectText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Subject snapshot did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = ReadBodyText(bodyText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Body snapshot did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Template scan gate
    ' --------------------------------------------------------
    Set stepResult = ScanTemplate( _
        subjectText, _
        bodyText, _
        scanResult)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scanning did not return an operation result.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set gateResult = ValidateScanGate(scanResult)

    If gateResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan gate did not return an operation result.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not gateResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(gateResult, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Render
    ' --------------------------------------------------------
    Set stepResult = RenderSubject( _
        subjectText, _
        formattedValues, _
        renderedSubject)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Subject rendering did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = SetSubject(renderedSubject)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Subject update did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = ReplaceBodyVariables(formattedValues)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Body rendering did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Post-render snapshot
    ' --------------------------------------------------------
    subjectText = vbNullString
    bodyText = vbNullString

    Set stepResult = ReadSubject(subjectText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Post-render subject snapshot did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = ReadBodyText(bodyText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Post-render body snapshot did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Unresolved check
    ' --------------------------------------------------------
    Set stepResult = CheckUnresolved( _
        subjectText, _
        bodyText, _
        unresolvedResult)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved checking did not return an operation result.", _
            TARGET_UNRESOLVED_RESULT)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    ' Technical checker failure:
    ' P1-06 contract returns Failure + unresolvedResult = Nothing.
    If unresolvedResult Is Nothing Then

        If stepResult.Success Then
            Set primaryFailure = CreateFailureResult( _
                ERROR_TYPE_UNEXPECTED, _
                "Unresolved checker returned Success without a result carrier.", _
                TARGET_UNRESOLVED_RESULT)
            Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        Else
            Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        End If

        GoTo CleanUp
    End If

    ' Validate the carrier contract without reading ErrorType.
    Set gateResult = ValidateUnresolvedGate( _
        stepResult, _
        unresolvedResult, _
        hasUnresolved)

    If gateResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Display gate validation did not return an operation result.", _
            TARGET_UNRESOLVED_RESULT)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not gateResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(gateResult, mailCreated)
        GoTo CleanUp
    End If

    ' Valid unresolved failure:
    ' preserve unresolvedResult, do not display, close without save.
    If hasUnresolved Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Positive-allow Display Gate
    ' Only the valid Success + HasUnresolved=False + Variables.Count=0
    ' contract can reach DisplayMail.
    ' --------------------------------------------------------
    Set stepResult = DisplayMail()

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "MailItem display did not return an operation result.", _
            TARGET_MAIL_APPLICATION)
        Set CreateMailForDisplay = FailAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set CreateMailForDisplay = FailAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    ' DisplayMail transfers the active MailItem out of Adapter ownership.
    mailCreated = False

    Set CreateMailForDisplay = CreateSuccessResult()

CleanUp:
    Set gateResult = Nothing
    Set primaryFailure = Nothing
    Set stepResult = Nothing
    Set scanResult = Nothing
    Exit Function

UnexpectedError:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set primaryFailure = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error in mail creation orchestration: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_MAIL_APPLICATION)

    Set CreateMailForDisplay = FailAndCleanup( _
        primaryFailure, _
        mailCreated)

    Resume CleanUp
End Function

Private Function ValidateScanGate( _
    ByVal scanResult As Object _
) As COperationResult

    Dim validVariables As Collection
    Dim invalidCandidates As Collection

    On Error GoTo ErrorHandler

    If scanResult Is Nothing Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result is not available.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If StrComp(TypeName(scanResult), "Dictionary", vbTextCompare) <> 0 Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result must be a Scripting.Dictionary.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If Not scanResult.Exists(KEY_VALID_VARIABLES) Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result does not contain ValidVariables.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result does not contain InvalidCandidates.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    Set validVariables = scanResult.Item(KEY_VALID_VARIABLES)
    Set invalidCandidates = scanResult.Item(KEY_INVALID_CANDIDATES)

    If validVariables Is Nothing Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "ValidVariables collection is not available.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If invalidCandidates Is Nothing Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "InvalidCandidates collection is not available.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If invalidCandidates.Count > 0 Then
        Set ValidateScanGate = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "The template contains invalid variable candidates.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    Set ValidateScanGate = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set ValidateScanGate = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Template scan result could not be validated.", _
        TARGET_TEMPLATE_SCAN_RESULT)
End Function

Private Function ValidateUnresolvedGate( _
    ByVal checkResult As COperationResult, _
    ByVal unresolvedResult As Object, _
    ByRef hasUnresolved As Boolean _
) As COperationResult

    Dim variables As Collection
    Dim rawHasUnresolved As Variant

    hasUnresolved = False

    On Error GoTo ErrorHandler

    If checkResult Is Nothing Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved check operation result is not available.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    If unresolvedResult Is Nothing Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved result carrier is not available.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    If StrComp(TypeName(unresolvedResult), "Dictionary", vbTextCompare) <> 0 Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved result must be a Scripting.Dictionary.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    If Not unresolvedResult.Exists(KEY_HAS_UNRESOLVED) Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved result does not contain HasUnresolved.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    If Not unresolvedResult.Exists(KEY_VARIABLES) Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved result does not contain Variables.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    rawHasUnresolved = unresolvedResult.Item(KEY_HAS_UNRESOLVED)

    If VarType(rawHasUnresolved) <> vbBoolean Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "HasUnresolved must be Boolean.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    hasUnresolved = CBool(rawHasUnresolved)
    Set variables = unresolvedResult.Item(KEY_VARIABLES)

    If variables Is Nothing Then
        Set ValidateUnresolvedGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unresolved Variables collection is not available.", _
            TARGET_UNRESOLVED_RESULT)
        Exit Function
    End If

    If hasUnresolved Then

        If variables.Count < 1 Then
            Set ValidateUnresolvedGate = CreateFailureResult( _
                ERROR_TYPE_UNEXPECTED, _
                "HasUnresolved is True but Variables is empty.", _
                TARGET_UNRESOLVED_RESULT)
            Exit Function
        End If

        If checkResult.Success Then
            Set ValidateUnresolvedGate = CreateFailureResult( _
                ERROR_TYPE_UNEXPECTED, _
                "Unresolved checker returned Success while unresolved variables exist.", _
                TARGET_UNRESOLVED_RESULT)
            Exit Function
        End If

    Else

        If variables.Count <> 0 Then
            Set ValidateUnresolvedGate = CreateFailureResult( _
                ERROR_TYPE_UNEXPECTED, _
                "HasUnresolved is False but Variables is not empty.", _
                TARGET_UNRESOLVED_RESULT)
            Exit Function
        End If

        If Not checkResult.Success Then
            Set ValidateUnresolvedGate = CreateFailureResult( _
                ERROR_TYPE_UNEXPECTED, _
                "Unresolved checker returned Failure while no unresolved variables exist.", _
                TARGET_UNRESOLVED_RESULT)
            Exit Function
        End If

    End If

    Set ValidateUnresolvedGate = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set ValidateUnresolvedGate = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unresolved result contract could not be validated.", _
        TARGET_UNRESOLVED_RESULT)
End Function

Private Function FailAndCleanup( _
    ByVal primaryResult As COperationResult, _
    ByVal mailCreated As Boolean _
) As COperationResult

    Dim cleanupResult As COperationResult

    On Error GoTo ErrorHandler

    If primaryResult Is Nothing Then
        Set primaryResult = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "A failure path did not provide an operation result.", _
            TARGET_MAIL_APPLICATION)
    End If

    If Not mailCreated Then
        Set FailAndCleanup = primaryResult
        Exit Function
    End If

    Set cleanupResult = CloseWithoutSave()

    If cleanupResult Is Nothing Then
        DebugPrintOperationResult _
            "P1-07 primary failure before missing cleanup result", _
            primaryResult

        Set FailAndCleanup = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "MailItem cleanup did not return an operation result.", _
            TARGET_MAIL_CLEANUP)
        Exit Function
    End If

    If Not cleanupResult.Success Then
        ' P1-07 does not finalize multiple-error aggregation.
        ' Keep the primary failure diagnosable while returning an overall
        ' failure that makes the cleanup failure visible.
        DebugPrintOperationResult _
            "P1-07 primary failure before cleanup failure", _
            primaryResult

        Set FailAndCleanup = cleanupResult
        Exit Function
    End If

    Set FailAndCleanup = primaryResult
    Exit Function

ErrorHandler:
    Set FailAndCleanup = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error while cleaning up a failed MailItem.", _
        TARGET_MAIL_CLEANUP)
End Function

Private Sub DebugPrintOperationResult( _
    ByVal prefix As String, _
    ByVal operationResult As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    On Error Resume Next

    Debug.Print prefix

    If operationResult Is Nothing Then
        Debug.Print "  Result: Nothing"
        Exit Sub
    End If

    Debug.Print "  Success=" & CStr(operationResult.Success)

    Set errors = operationResult.Errors

    For Each errorInfo In errors
        Debug.Print _
            "  ErrorType=" & errorInfo.ErrorType & _
            "; Target=" & errorInfo.Target & _
            "; Message=" & errorInfo.Message
    Next errorInfo

    Set errorInfo = Nothing
    Set errors = Nothing

    On Error GoTo 0
End Sub
