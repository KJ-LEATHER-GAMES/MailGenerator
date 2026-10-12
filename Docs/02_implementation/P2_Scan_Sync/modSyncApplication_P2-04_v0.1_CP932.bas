Attribute VB_Name = "modSyncApplication"
Option Explicit

' P2-04 Manual Sync Integration
'
' Responsibility:
' - Orchestrate the Manual Sync production flow
' - Acquire one SyncTimestamp per successful pre-sync state
' - Connect Template Scanner / Sync Engine / Persistence
' - Enforce pre-sync mutation guards
' - Return the current TemplateScanResult and persisted SyncDiffResult
'
' Non-responsibility:
' - Template scan semantics
' - Sync classification / canonical name / metadata calculation
' - VariableDefinition persistence semantics
' - User-facing Sync Result UI / notification
' - Final error taxonomy / user-facing error UI
' - Automatic retry / rollback
'
' Final error integration / precedence is finalized in P6.

Private Const SETTING_TEMPLATE_PATH As String = "TemplatePath"

Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Private Const ERROR_TYPE_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"

Private Const TARGET_SYNC_APPLICATION As String = "SyncApplication"
Private Const TARGET_TEMPLATE_SCAN_RESULT As String = "TemplateScanResult"
Private Const TARGET_VARIABLE_DEFINITIONS As String = "VariableDefinitions"
Private Const TARGET_SYNC_DIFF_RESULT As String = "SyncDiffResult"
Private Const TARGET_MAIL_CLEANUP As String = "MailItemCleanup"

Public Function ExecuteManualSync( _
    ByRef syncDiffResult As Object, _
    ByRef templateScanResult As Object _
) As COperationResult

    Dim stepResult As COperationResult
    Dim gateResult As COperationResult

    Dim candidateTemplateScanResult As Object
    Dim candidateSyncDiffResult As Object
    Dim currentDefinitions As Collection

    Dim syncTimestamp As Date

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Acquire the current template snapshot and close the
    ' scan MailItem before exposing the scan result.
    ' --------------------------------------------------------
    Set stepResult = ScanCurrentTemplate(candidateTemplateScanResult)

    If stepResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Current template scan did not return an operation result.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ExecuteManualSync = stepResult
        GoTo CleanUp
    End If

    If candidateTemplateScanResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Current template scan returned Success without a result carrier.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        GoTo CleanUp
    End If

    ' The current scan carrier remains available to the caller even when
    ' the InvalidCandidates gate stops synchronization.
    Set templateScanResult = candidateTemplateScanResult

    ' --------------------------------------------------------
    ' Pre-sync invalid candidate gate.
    ' --------------------------------------------------------
    Set gateResult = ValidateSyncScanGate(candidateTemplateScanResult)

    If gateResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Manual Sync scan gate did not return an operation result.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        GoTo CleanUp
    End If

    If Not gateResult.Success Then
        Set ExecuteManualSync = gateResult
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Current VariableDefinitions.
    ' Active + Unused are both required for Reactivated / Unused logic.
    ' --------------------------------------------------------
    Set stepResult = GetAllVariableDefinitions(currentDefinitions)

    If stepResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "VariableDefinition access did not return an operation result.", _
            TARGET_VARIABLE_DEFINITIONS)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ExecuteManualSync = stepResult
        GoTo CleanUp
    End If

    If currentDefinitions Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "VariableDefinition access returned Success without a collection.", _
            TARGET_VARIABLE_DEFINITIONS)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Sync Processing Start.
    ' Acquire exactly one timestamp after all pre-sync guards and current
    ' definition retrieval have succeeded.
    ' --------------------------------------------------------
    syncTimestamp = Now

    ' --------------------------------------------------------
    ' Build target diff state.
    ' P2-04 does not reclassify or recalculate metadata.
    ' --------------------------------------------------------
    Set stepResult = BuildSyncDiff( _
        candidateTemplateScanResult, _
        currentDefinitions, _
        syncTimestamp, _
        candidateSyncDiffResult)

    If stepResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Sync diff construction did not return an operation result.", _
            TARGET_SYNC_DIFF_RESULT)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ExecuteManualSync = stepResult
        GoTo CleanUp
    End If

    If candidateSyncDiffResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Sync diff construction returned Success without a result carrier.", _
            TARGET_SYNC_DIFF_RESULT)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Persistence.
    ' Do not publish syncDiffResult until persistence succeeds.
    ' --------------------------------------------------------
    Set stepResult = ApplySyncDiff(candidateSyncDiffResult)

    If stepResult Is Nothing Then
        Set ExecuteManualSync = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Sync diff persistence did not return an operation result.", _
            TARGET_SYNC_DIFF_RESULT)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ExecuteManualSync = stepResult
        GoTo CleanUp
    End If

    ' Persistence is the successful result publication boundary.
    Set syncDiffResult = candidateSyncDiffResult
    Set ExecuteManualSync = CreateSuccessResult()

CleanUp:
    Set currentDefinitions = Nothing
    Set candidateSyncDiffResult = Nothing
    Set candidateTemplateScanResult = Nothing
    Set gateResult = Nothing
    Set stepResult = Nothing
    Exit Function

UnexpectedError:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set syncDiffResult = Nothing

    Set ExecuteManualSync = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error in Manual Sync orchestration: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_SYNC_APPLICATION)

    Resume CleanUp
End Function

Private Function ScanCurrentTemplate( _
    ByRef scanResult As Object _
) As COperationResult

    Dim stepResult As COperationResult
    Dim primaryFailure As COperationResult
    Dim cleanupResult As COperationResult

    Dim candidateScanResult As Object

    Dim templatePath As String
    Dim resolvedTemplatePath As String
    Dim subjectText As String
    Dim bodyText As String

    Dim mailCreated As Boolean

    Set scanResult = Nothing

    On Error GoTo UnexpectedError

    ' --------------------------------------------------------
    ' Settings / path
    ' --------------------------------------------------------
    Set stepResult = GetSettingValue( _
        SETTING_TEMPLATE_PATH, _
        templatePath)

    If stepResult Is Nothing Then
        Set ScanCurrentTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Settings access did not return an operation result.", _
            SETTING_TEMPLATE_PATH)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = stepResult
        GoTo CleanUp
    End If

    Set stepResult = ResolveWorkbookRelativePath( _
        templatePath, _
        resolvedTemplatePath)

    If stepResult Is Nothing Then
        Set ScanCurrentTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template path resolution did not return an operation result.", _
            SETTING_TEMPLATE_PATH)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = stepResult
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' FR-SYNC-008 / Design 25.1:
    ' OFT existence must be confirmed before Outlook processing begins.
    ' --------------------------------------------------------
    Set stepResult = ValidateTemplateFileExists(resolvedTemplatePath)

    If stepResult Is Nothing Then
        Set ScanCurrentTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template existence validation did not return an operation result.", _
            SETTING_TEMPLATE_PATH)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = stepResult
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Create scan MailItem.
    ' Classic Outlook readiness remains inside modOutlookAdapter.
    ' --------------------------------------------------------
    Set stepResult = CreateMailFromTemplate(resolvedTemplatePath)

    If stepResult Is Nothing Then
        Set ScanCurrentTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "MailItem creation did not return an operation result.", _
            TARGET_SYNC_APPLICATION)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = stepResult
        GoTo CleanUp
    End If

    mailCreated = True

    ' --------------------------------------------------------
    ' Current template snapshot.
    ' --------------------------------------------------------
    Set stepResult = ReadSubject(subjectText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Subject snapshot did not return an operation result.", _
            TARGET_SYNC_APPLICATION)
        Set ScanCurrentTemplate = FailScanAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = FailScanAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = ReadBodyText(bodyText)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Body snapshot did not return an operation result.", _
            TARGET_SYNC_APPLICATION)
        Set ScanCurrentTemplate = FailScanAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = FailScanAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    Set stepResult = ScanTemplate( _
        subjectText, _
        bodyText, _
        candidateScanResult)

    If stepResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scanning did not return an operation result.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Set ScanCurrentTemplate = FailScanAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanCurrentTemplate = FailScanAndCleanup(stepResult, mailCreated)
        GoTo CleanUp
    End If

    If candidateScanResult Is Nothing Then
        Set primaryFailure = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scanning returned Success without a result carrier.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Set ScanCurrentTemplate = FailScanAndCleanup(primaryFailure, mailCreated)
        GoTo CleanUp
    End If

    ' --------------------------------------------------------
    ' Normal scan MailItem cleanup.
    ' The scan carrier is not published until cleanup succeeds.
    ' --------------------------------------------------------
    Set cleanupResult = CloseWithoutSave()

    If cleanupResult Is Nothing Then
        Set ScanCurrentTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "MailItem cleanup did not return an operation result.", _
            TARGET_MAIL_CLEANUP)
        GoTo CleanUp
    End If

    If Not cleanupResult.Success Then
        Set ScanCurrentTemplate = cleanupResult
        GoTo CleanUp
    End If

    mailCreated = False

    Set scanResult = candidateScanResult
    Set ScanCurrentTemplate = CreateSuccessResult()

CleanUp:
    Set cleanupResult = Nothing
    Set primaryFailure = Nothing
    Set stepResult = Nothing
    Set candidateScanResult = Nothing
    Exit Function

UnexpectedError:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set primaryFailure = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error while acquiring the current template scan: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_SYNC_APPLICATION)

    Set ScanCurrentTemplate = FailScanAndCleanup( _
        primaryFailure, _
        mailCreated)

    Resume CleanUp
End Function

Private Function ValidateSyncScanGate( _
    ByVal scanResult As Object _
) As COperationResult

    Dim invalidCandidates As Collection

    On Error GoTo ErrorHandler

    If scanResult Is Nothing Then
        Set ValidateSyncScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result is not available.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If StrComp(TypeName(scanResult), "Dictionary", vbTextCompare) <> 0 Then
        Set ValidateSyncScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result must be a Scripting.Dictionary.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If Not scanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Set ValidateSyncScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result does not contain InvalidCandidates.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    Set invalidCandidates = scanResult.Item(KEY_INVALID_CANDIDATES)

    If invalidCandidates Is Nothing Then
        Set ValidateSyncScanGate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "InvalidCandidates collection is not available.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    If invalidCandidates.Count > 0 Then
        Set ValidateSyncScanGate = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "The template contains invalid variable candidates.", _
            TARGET_TEMPLATE_SCAN_RESULT)
        Exit Function
    End If

    Set ValidateSyncScanGate = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set ValidateSyncScanGate = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Template scan result could not be validated for Manual Sync.", _
        TARGET_TEMPLATE_SCAN_RESULT)
End Function

Private Function ValidateTemplateFileExists( _
    ByVal resolvedTemplatePath As String _
) As COperationResult

    Dim matchedPath As String

    On Error GoTo ErrorHandler

    If Len(Trim$(resolvedTemplatePath)) = 0 Then
        Set ValidateTemplateFileExists = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Resolved template path is empty.", _
            SETTING_TEMPLATE_PATH)
        Exit Function
    End If

    matchedPath = Dir$( _
        resolvedTemplatePath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)

    If Len(matchedPath) = 0 Then
        Set ValidateTemplateFileExists = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Template file does not exist.", _
            SETTING_TEMPLATE_PATH)
        Exit Function
    End If

    Set ValidateTemplateFileExists = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set ValidateTemplateFileExists = CreateFailureResult( _
        ERROR_TYPE_CONFIGURATION, _
        "Template file existence could not be confirmed.", _
        SETTING_TEMPLATE_PATH)
End Function

Private Function FailScanAndCleanup( _
    ByVal primaryResult As COperationResult, _
    ByVal mailCreated As Boolean _
) As COperationResult

    Dim cleanupResult As COperationResult

    On Error GoTo ErrorHandler

    If primaryResult Is Nothing Then
        Set primaryResult = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "A scan failure path did not provide an operation result.", _
            TARGET_SYNC_APPLICATION)
    End If

    If Not mailCreated Then
        Set FailScanAndCleanup = primaryResult
        Exit Function
    End If

    Set cleanupResult = CloseWithoutSave()

    If cleanupResult Is Nothing Then
        DebugPrintOperationResult _
            "P2-04 primary failure before missing cleanup result", _
            primaryResult

        Debug.Print "P2-04 cleanup result: Nothing"

        ' P2-04 preserves the primary failure as the root cause.
        Set FailScanAndCleanup = primaryResult
        Exit Function
    End If

    If Not cleanupResult.Success Then
        DebugPrintOperationResult _
            "P2-04 primary failure before cleanup failure", _
            primaryResult

        DebugPrintOperationResult _
            "P2-04 cleanup failure", _
            cleanupResult

        ' Multiple-error aggregation is not introduced in P2-04.
        ' Preserve the primary failure; P6 finalizes error precedence.
        Set FailScanAndCleanup = primaryResult
        Exit Function
    End If

    Set FailScanAndCleanup = primaryResult
    Exit Function

ErrorHandler:
    If primaryResult Is Nothing Then
        Set FailScanAndCleanup = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Unexpected error while cleaning up a failed scan MailItem.", _
            TARGET_MAIL_CLEANUP)
    Else
        Debug.Print _
            "P2-04 unexpected cleanup error: " & _
            CStr(Err.Number) & " - " & Err.Description

        Set FailScanAndCleanup = primaryResult
    End If
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
