Attribute VB_Name = "modP1OneDrivePathVerification"
Option Explicit

Private Const ONEDRIVE_URL_PREFIX As String = "https://d.docs.live.net/"

Public Sub TestOneDriveLocalPathResolution()

    Dim workbookWebPath As String
    Dim relativeWorkbookPath As String
    Dim selectedRoot As String
    Dim localWorkbookPath As String
    Dim templatePath As String
    Dim localTemplatePath As String
    Dim result As COperationResult
    Dim cleanupResult As COperationResult
    Dim mailCreated As Boolean
    Dim testPassed As Boolean

    On Error GoTo UnexpectedFailure

    Debug.Print "TV-P1-001: START"
    Debug.Print
    Debug.Print "ThisWorkbook:"
    Debug.Print ThisWorkbook.Name
    Debug.Print
    Debug.Print "ThisWorkbook.Path:"
    Debug.Print ThisWorkbook.Path
    Debug.Print

    workbookWebPath = Trim$(ThisWorkbook.Path)

    If Len(workbookWebPath) = 0 Then
        Debug.Print "Precondition: FAIL"
        Debug.Print "  ThisWorkbook.Path is empty."
        GoTo TestFinished
    End If

    If Not IsOneDriveWebPath(workbookWebPath) Then
        Debug.Print "Precondition: NOT APPLICABLE"
        Debug.Print "  ThisWorkbook.Path is not a d.docs.live.net URL."
        Debug.Print "  Target=" & workbookWebPath
        GoTo TestFinished
    End If

    Debug.Print "Precondition: PASS"
    Debug.Print "  OneDrive web URL reproduced."
    Debug.Print

    Debug.Print "Environment Variables:"
    Debug.Print "  OneDrive=" & DisplayValue(Environ$("OneDrive"))
    Debug.Print "  OneDriveConsumer=" & DisplayValue(Environ$("OneDriveConsumer"))
    Debug.Print "  OneDriveCommercial=" & DisplayValue(Environ$("OneDriveCommercial"))
    Debug.Print

    If Not TryExtractOneDriveRelativePath(workbookWebPath, relativeWorkbookPath) Then
        Debug.Print "Relative Path Extraction: FAIL"
        Debug.Print "  Target=" & workbookWebPath
        GoTo TestFinished
    End If

    Debug.Print "Relative Workbook Path:"
    Debug.Print relativeWorkbookPath
    Debug.Print

    If Not TryResolveLocalWorkbookPath( _
        relativeWorkbookPath, _
        selectedRoot, _
        localWorkbookPath _
    ) Then
        Debug.Print "Local Workbook Path Resolution: FAIL"
        Debug.Print "  No environment-variable candidate produced"
        Debug.Print "  an existing local workbook folder."
        GoTo TestFinished
    End If

    Debug.Print "Detected OneDrive Root:"
    Debug.Print selectedRoot
    Debug.Print

    Debug.Print "Resolved Local Workbook Path:"
    Debug.Print localWorkbookPath
    Debug.Print

    Set result = modSettingsData.GetSettingValue("TemplatePath", templatePath)

    If result Is Nothing Then
        Debug.Print "TemplatePath Read: FAIL"
        Debug.Print "  Result is Nothing."
        GoTo TestFinished
    End If

    If Not result.Success Then
        Debug.Print "TemplatePath Read: FAIL"
        PrintResultErrors result
        GoTo TestFinished
    End If

    Debug.Print "TemplatePath:"
    Debug.Print templatePath
    Debug.Print

    localTemplatePath = JoinWindowsPath(localWorkbookPath, templatePath)

    Debug.Print "Resolved Local Template Path:"
    Debug.Print localTemplatePath
    Debug.Print

    If Not FileExists(localTemplatePath) Then
        Debug.Print "File Exists: FAIL"
        Debug.Print "  Target=" & localTemplatePath
        GoTo TestFinished
    End If

    Debug.Print "File Exists: PASS"
    Debug.Print

    Set result = modOutlookAdapter.CreateMailFromTemplate(localTemplatePath)

    If result Is Nothing Then
        Debug.Print "CreateMailFromTemplate: FAIL"
        Debug.Print "  Result is Nothing."
        GoTo TestFinished
    End If

    If Not result.Success Then
        Debug.Print "CreateMailFromTemplate: FAIL"
        PrintResultErrors result
        GoTo TestFinished
    End If

    mailCreated = True
    Debug.Print "CreateMailFromTemplate: PASS"
    Debug.Print

    Set cleanupResult = modOutlookAdapter.CloseWithoutSave()

    If cleanupResult Is Nothing Then
        Debug.Print "Cleanup CloseWithoutSave: FAIL"
        Debug.Print "  Result is Nothing."
        GoTo TestFinished
    End If

    If Not cleanupResult.Success Then
        Debug.Print "Cleanup CloseWithoutSave: FAIL"
        PrintResultErrors cleanupResult
        GoTo TestFinished
    End If

    mailCreated = False
    Debug.Print "Cleanup CloseWithoutSave: PASS"
    Debug.Print

    testPassed = True

TestFinished:
    If testPassed Then
        Debug.Print "TV-P1-001: PASS"
    Else
        Debug.Print "TV-P1-001: FAIL"
    End If

    Exit Sub

UnexpectedFailure:
    Debug.Print "TV-P1-001: FAIL"
    Debug.Print "  Unexpected VBA runtime error."
    Debug.Print "  Err.Number=" & CStr(Err.Number)
    Debug.Print "  Err.Description=" & Err.Description

    If mailCreated Then
        On Error Resume Next
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
        On Error GoTo 0
    End If
End Sub

Private Function IsOneDriveWebPath(ByVal pathValue As String) As Boolean
    If Len(pathValue) < Len(ONEDRIVE_URL_PREFIX) Then
        IsOneDriveWebPath = False
        Exit Function
    End If

    IsOneDriveWebPath = _
        (StrComp(Left$(pathValue, Len(ONEDRIVE_URL_PREFIX)), _
                 ONEDRIVE_URL_PREFIX, vbTextCompare) = 0)
End Function

Private Function TryExtractOneDriveRelativePath( _
    ByVal workbookWebPath As String, _
    ByRef relativePath As String _
) As Boolean

    Dim remainder As String
    Dim separatorPosition As Long
    Dim cid As String

    relativePath = vbNullString

    If Not IsOneDriveWebPath(workbookWebPath) Then Exit Function

    remainder = Mid$(workbookWebPath, Len(ONEDRIVE_URL_PREFIX) + 1)
    separatorPosition = InStr(1, remainder, "/", vbBinaryCompare)

    If separatorPosition <= 1 Then Exit Function

    cid = Left$(remainder, separatorPosition - 1)
    If Len(Trim$(cid)) = 0 Then Exit Function

    relativePath = Mid$(remainder, separatorPosition + 1)
    relativePath = Replace(relativePath, "/", "\")
    relativePath = TrimLeadingPathSeparators(relativePath)
    relativePath = TrimTrailingPathSeparators(relativePath)

    If Len(relativePath) = 0 Then Exit Function

    TryExtractOneDriveRelativePath = True
End Function

Private Function TryResolveLocalWorkbookPath( _
    ByVal relativeWorkbookPath As String, _
    ByRef selectedRoot As String, _
    ByRef localWorkbookPath As String _
) As Boolean

    Dim candidateNames(1 To 3) As String
    Dim candidateRoots(1 To 3) As String
    Dim i As Long
    Dim candidateRoot As String
    Dim candidatePath As String

    selectedRoot = vbNullString
    localWorkbookPath = vbNullString

    candidateNames(1) = "OneDrive"
    candidateNames(2) = "OneDriveConsumer"
    candidateNames(3) = "OneDriveCommercial"

    candidateRoots(1) = Trim$(Environ$("OneDrive"))
    candidateRoots(2) = Trim$(Environ$("OneDriveConsumer"))
    candidateRoots(3) = Trim$(Environ$("OneDriveCommercial"))

    Debug.Print "Local Root Candidates:"

    For i = 1 To 3
        candidateRoot = candidateRoots(i)

        If Len(candidateRoot) = 0 Then
            Debug.Print "  " & candidateNames(i) & ": SKIP (empty)"
        Else
            candidatePath = JoinWindowsPath(candidateRoot, relativeWorkbookPath)

            Debug.Print "  " & candidateNames(i) & ":"
            Debug.Print "    Root=" & candidateRoot
            Debug.Print "    WorkbookPath=" & candidatePath

            If DirectoryExists(candidatePath) Then
                Debug.Print "    Directory Exists: PASS"
                selectedRoot = candidateRoot
                localWorkbookPath = candidatePath
                TryResolveLocalWorkbookPath = True
                Exit Function
            Else
                Debug.Print "    Directory Exists: FAIL"
            End If
        End If
    Next i

    Debug.Print
End Function

Private Function JoinWindowsPath( _
    ByVal basePath As String, _
    ByVal childPath As String _
) As String

    Dim normalizedBase As String
    Dim normalizedChild As String

    normalizedBase = Replace(Trim$(basePath), "/", "\")
    normalizedChild = Replace(Trim$(childPath), "/", "\")

    normalizedBase = TrimTrailingPathSeparators(normalizedBase)
    normalizedChild = TrimLeadingPathSeparators(normalizedChild)

    If Len(normalizedBase) = 0 Then
        JoinWindowsPath = normalizedChild
    ElseIf Len(normalizedChild) = 0 Then
        JoinWindowsPath = normalizedBase
    Else
        JoinWindowsPath = normalizedBase & "\" & normalizedChild
    End If
End Function

Private Function TrimLeadingPathSeparators(ByVal pathValue As String) As String
    Do While Len(pathValue) > 0
        If Left$(pathValue, 1) <> "\" And Left$(pathValue, 1) <> "/" Then Exit Do
        pathValue = Mid$(pathValue, 2)
    Loop

    TrimLeadingPathSeparators = pathValue
End Function

Private Function TrimTrailingPathSeparators(ByVal pathValue As String) As String
    Do While Len(pathValue) > 0
        If Right$(pathValue, 1) <> "\" And Right$(pathValue, 1) <> "/" Then Exit Do
        pathValue = Left$(pathValue, Len(pathValue) - 1)
    Loop

    TrimTrailingPathSeparators = pathValue
End Function

Private Function DirectoryExists(ByVal folderPath As String) As Boolean
    Dim attributes As Long

    On Error GoTo NotFound
    attributes = GetAttr(folderPath)
    DirectoryExists = ((attributes And vbDirectory) = vbDirectory)
    Exit Function

NotFound:
    DirectoryExists = False
End Function

Private Function FileExists(ByVal filePath As String) As Boolean
    Dim fileName As String

    On Error GoTo NotFound
    fileName = Dir$(filePath, vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive)
    FileExists = (Len(fileName) > 0)
    Exit Function

NotFound:
    FileExists = False
End Function

Private Function DisplayValue(ByVal value As String) As String
    If Len(value) = 0 Then
        DisplayValue = "<empty>"
    Else
        DisplayValue = value
    End If
End Function

Private Sub PrintResultErrors(ByVal result As COperationResult)
    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    If result Is Nothing Then Exit Sub

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)

        Debug.Print "  ErrorType=" & errorInfo.ErrorType
        Debug.Print "  Message=" & errorInfo.Message
        Debug.Print "  Target=" & errorInfo.Target
    Next i
End Sub
