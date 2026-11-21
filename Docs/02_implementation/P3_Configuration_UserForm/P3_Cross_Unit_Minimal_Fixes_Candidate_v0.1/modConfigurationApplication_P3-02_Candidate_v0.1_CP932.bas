Attribute VB_Name = "modConfigurationApplication"
Option Explicit

' P3 Application CURRENT SNAPSHOT candidate. NOT APPROVED / NOT COMPILED.
' Intended for a separate candidate workbook only after authorization.
' No ExecuteManualSync, ApplySyncDiff, UserForm, or persistence.
' Dependencies: modSettingsData, modOutlookAdapter (P1-07),
' modTemplateScanner (P2-01), modVariableDefinitionData (P2-03),
' modOptionMasterData, modConfigurationValidator (P3-01), modResult.

Private Const TEMPLATE_SETTING As String = "TemplatePath"
Private Const ERROR_UNEXPECTED As String = "UnexpectedError"
Private Const ERROR_CONFIGURATION As String = "ConfigurationError"

' Output snapshots are exposed ONLY when every check succeeds.
' Application/UI caller must check Success before opening a UserForm.
Public Function PrepareCurrentConfiguration( _
    ByRef templateScanResult As Object, _
    ByRef allVariableDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult

    Dim localScan As Object
    Dim localDefinitions As Collection
    Dim localOptions As Object
    Dim stepResult As COperationResult
    Dim checkedResult As COperationResult

    Set templateScanResult = Nothing
    Set allVariableDefinitions = Nothing
    Set activeOptionsByGroup = Nothing

    On Error GoTo UnexpectedFailure

    ' Read-only OFT scan, including successful CloseWithoutSave.
    Set stepResult = CaptureCurrentTemplateScan(localScan)
    Set checkedResult = CheckOperation(stepResult, "TemplateScanResult")
    If Not checkedResult.Success Then
        Set PrepareCurrentConfiguration = checkedResult
        Exit Function
    End If
    If localScan Is Nothing Then
        Set PrepareCurrentConfiguration = MissingOutput("TemplateScanResult")
        Exit Function
    End If

    ' ALL definitions are required (Active and Unused).
    Set stepResult = GetAllVariableDefinitions(localDefinitions)
    Set checkedResult = CheckOperation(stepResult, "VariableDefinitions")
    If Not checkedResult.Success Then
        Set PrepareCurrentConfiguration = checkedResult
        Exit Function
    End If
    If localDefinitions Is Nothing Then
        Set PrepareCurrentConfiguration = MissingOutput("VariableDefinitions")
        Exit Function
    End If

    Set stepResult = LoadActiveOptionSnapshots(localDefinitions, localOptions)
    Set checkedResult = CheckOperation(stepResult, "ActiveOptionsByGroup")
    If Not checkedResult.Success Then
        Set PrepareCurrentConfiguration = checkedResult
        Exit Function
    End If
    If localOptions Is Nothing Then
        Set PrepareCurrentConfiguration = MissingOutput("ActiveOptionsByGroup")
        Exit Function
    End If

    ' This gate does not modify the snapshots, synchronize, or build controls.
    Set stepResult = ValidateConfiguration( _
        True, localScan, localDefinitions, localOptions)
    Set checkedResult = CheckOperation(stepResult, "ConfigurationValidator")
    If Not checkedResult.Success Then
        Set PrepareCurrentConfiguration = checkedResult
        Exit Function
    End If

    Set templateScanResult = localScan
    Set allVariableDefinitions = localDefinitions
    Set activeOptionsByGroup = localOptions
    Set PrepareCurrentConfiguration = checkedResult
    Exit Function

UnexpectedFailure:
    ' No output is published on failure, including a late runtime failure.
    Set templateScanResult = Nothing
    Set allVariableDefinitions = Nothing
    Set activeOptionsByGroup = Nothing
    Set PrepareCurrentConfiguration = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Current configuration snapshot could not be prepared.", _
        "ConfigurationApplication")
End Function

Private Function CaptureCurrentTemplateScan( _
    ByRef scanResult As Object _
) As COperationResult

    Dim templatePath As String
    Dim resolvedPath As String
    Dim subjectText As String
    Dim bodyText As String
    Dim candidateScan As Object
    Dim stepResult As COperationResult
    Dim terminalResult As COperationResult
    Dim cleanupResult As COperationResult
    Dim mailCreated As Boolean
    Dim cleanupErrorNumber As Long

    Set scanResult = Nothing
    mailCreated = False
    On Error GoTo UnexpectedFailure

    Set stepResult = GetSettingValue(TEMPLATE_SETTING, templatePath)
    Set terminalResult = CheckOperation(stepResult, TEMPLATE_SETTING)
    If Not terminalResult.Success Then GoTo FinishScan

    Set stepResult = ResolveWorkbookRelativePath(templatePath, resolvedPath)
    Set terminalResult = CheckOperation(stepResult, TEMPLATE_SETTING)
    If Not terminalResult.Success Then GoTo FinishScan

    Set terminalResult = CheckTemplateFileExists(resolvedPath)
    If Not terminalResult.Success Then GoTo FinishScan

    Set stepResult = CreateMailFromTemplate(resolvedPath)
    Set terminalResult = CheckOperation(stepResult, "OutlookTemplate")
    If Not terminalResult.Success Then GoTo FinishScan
    mailCreated = True

    Set stepResult = ReadSubject(subjectText)
    Set terminalResult = CheckOperation(stepResult, "Subject")
    If Not terminalResult.Success Then GoTo FinishScan

    Set stepResult = ReadBodyText(bodyText)
    Set terminalResult = CheckOperation(stepResult, "BodyText")
    If Not terminalResult.Success Then GoTo FinishScan

    Set stepResult = ScanTemplate(subjectText, bodyText, candidateScan)
    Set terminalResult = CheckOperation(stepResult, "TemplateScanResult")
    If Not terminalResult.Success Then GoTo FinishScan
    If candidateScan Is Nothing Then
        Set terminalResult = MissingOutput("TemplateScanResult")
        GoTo FinishScan
    End If

FinishScan:
    ' Always close a successfully created scan MailItem before publishing data.
    If mailCreated Then
        cleanupErrorNumber = 0
        Set cleanupResult = Nothing
        On Error Resume Next
        Err.Clear
        Set cleanupResult = CloseWithoutSave()
        cleanupErrorNumber = Err.Number
        Err.Clear
        On Error GoTo 0

        If cleanupErrorNumber <> 0 Then
            If terminalResult Is Nothing Then
                Set terminalResult = MissingOutput("MailItemCleanup")
            ElseIf terminalResult.Success Then
                Set terminalResult = CreateFailureResult( _
                    ERROR_UNEXPECTED, _
                    "Scan MailItem cleanup raised an unexpected error.", _
                    "MailItemCleanup")
            Else
                Debug.Print "P3-02 secondary cleanup exception after primary failure."
            End If
        ElseIf cleanupResult Is Nothing Then
            If terminalResult Is Nothing Then
                Set terminalResult = MissingOutput("MailItemCleanup")
            ElseIf terminalResult.Success Then
                Set terminalResult = MissingOutput("MailItemCleanup")
            Else
                Debug.Print "P3-02 secondary cleanup returned no result."
            End If
        ElseIf Not cleanupResult.Success Then
            ' Keep the first failure if scan failed; no error aggregation here.
            If terminalResult Is Nothing Then
                Set terminalResult = cleanupResult
            ElseIf terminalResult.Success Then
                Set terminalResult = cleanupResult
            Else
                Debug.Print "P3-02 secondary cleanup failed after primary failure."
            End If
        End If
    End If

    If terminalResult Is Nothing Then
        Set terminalResult = MissingOutput("TemplateScanResult")
    End If
    If terminalResult.Success Then
        Set scanResult = candidateScan
    Else
        Set scanResult = Nothing
    End If
    Set CaptureCurrentTemplateScan = terminalResult
    Exit Function

UnexpectedFailure:
    Set terminalResult = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Current template scan could not complete.", _
        "ConfigurationApplication")
    Resume FinishScan
End Function

Private Function CheckTemplateFileExists( _
    ByVal resolvedPath As String _
) As COperationResult

    Dim matchedFile As String
    On Error GoTo FileFailure

    If Len(Trim$(resolvedPath)) = 0 Then
        Set CheckTemplateFileExists = CreateFailureResult( _
            ERROR_CONFIGURATION, "Resolved TemplatePath is empty.", TEMPLATE_SETTING)
        Exit Function
    End If

    ' Mirrors P2-04 guard semantics; does NOT invoke P2 private methods.
    matchedFile = Dir$(resolvedPath, _
        vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)
    If Len(matchedFile) = 0 Then
        Set CheckTemplateFileExists = CreateFailureResult( _
            ERROR_CONFIGURATION, "Current OFT does not exist.", TEMPLATE_SETTING)
        Exit Function
    End If

    Set CheckTemplateFileExists = CreateSuccessResult()
    Exit Function

FileFailure:
    Set CheckTemplateFileExists = CreateFailureResult( _
        ERROR_CONFIGURATION, "Current OFT existence could not be confirmed.", _
        TEMPLATE_SETTING)
End Function

Private Function LoadActiveOptionSnapshots( _
    ByVal allDefinitions As Collection, _
    ByRef activeOptionsByGroup As Object _
) As COperationResult

    Dim groups As Object
    Dim rowValue As Variant
    Dim item As Object
    Dim statusText As String
    Dim typeText As String
    Dim optionSource As String
    Dim options As Collection
    Dim stepResult As COperationResult
    Dim checkedResult As COperationResult

    Set activeOptionsByGroup = Nothing
    On Error GoTo UnexpectedFailure

    If allDefinitions Is Nothing Then
        Set LoadActiveOptionSnapshots = MissingOutput("VariableDefinitions")
        Exit Function
    End If

    Set groups = CreateObject("Scripting.Dictionary")
    groups.CompareMode = vbBinaryCompare  ' Existing OptionGroup strict match.

    For Each rowValue In allDefinitions
        If Not IsObject(rowValue) Then GoTo NextRow
        Set item = rowValue
        If item Is Nothing Then GoTo NextRow
        If TypeName(item) <> "Dictionary" Then GoTo NextRow
        If Not item.Exists("Status") Then GoTo NextRow
        If Not TryScalarText(item("Status"), statusText) Then GoTo NextRow
        If StrComp(statusText, "Active", vbTextCompare) <> 0 Then GoTo NextRow
        If Not item.Exists("Type") Then GoTo NextRow
        If Not TryScalarText(item("Type"), typeText) Then GoTo NextRow
        If StrComp(typeText, "Select", vbBinaryCompare) <> 0 Then GoTo NextRow
        If Not item.Exists("OptionSource") Then GoTo NextRow
        If Not TryScalarText(item("OptionSource"), optionSource) Then GoTo NextRow
        If Len(Trim$(optionSource)) = 0 Then GoTo NextRow

        If Not groups.Exists(optionSource) Then
            Set options = Nothing
            Set stepResult = GetActiveOptions(optionSource, options)
            Set checkedResult = CheckOperation(stepResult, optionSource)
            If Not checkedResult.Success Then
                Set LoadActiveOptionSnapshots = checkedResult
                Exit Function
            End If
            If options Is Nothing Then
                Set LoadActiveOptionSnapshots = MissingOutput( _
                    "ActiveOptionsByGroup." & optionSource)
                Exit Function
            End If
            groups.Add optionSource, options
        End If
NextRow:
    Next rowValue

    Set activeOptionsByGroup = groups
    Set LoadActiveOptionSnapshots = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    Set activeOptionsByGroup = Nothing
    Set LoadActiveOptionSnapshots = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Active option snapshot could not be prepared.", _
        "ActiveOptionsByGroup")
End Function

Private Function TryScalarText( _
    ByVal rawValue As Variant, _
    ByRef textValue As String _
) As Boolean
    textValue = vbNullString
    If IsError(rawValue) Then Exit Function
    If IsNull(rawValue) Then Exit Function
    If IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Then Exit Function
    If IsArray(rawValue) Then Exit Function
    textValue = CStr(rawValue)
    TryScalarText = True
End Function

Private Function CheckOperation( _
    ByVal result As COperationResult, _
    ByVal target As String _
) As COperationResult
    If result Is Nothing Then
        Set CheckOperation = MissingOutput(target)
    Else
        ' Exact upstream failure object is retained, including ErrorInfo.
        Set CheckOperation = result
    End If
End Function

Private Function MissingOutput(ByVal target As String) As COperationResult
    Set MissingOutput = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "An upstream operation did not return a valid result.", target)
End Function
