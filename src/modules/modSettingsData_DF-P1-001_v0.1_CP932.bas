Attribute VB_Name = "modSettingsData"
Option Explicit

' ============================================================
' Settings Data Access
'
' DF-P1-001:
' ResolveWorkbookRelativePath supports:
'   1) Windows local ThisWorkbook.Path
'   2) OneDrive Personal web URL:
'      https://d.docs.live.net/<CID>/...
'
' Public API is unchanged.
' ============================================================

Private Const SETTINGS_SHEET_NAME As String = "Settings"
Private Const SETTINGS_TABLE_NAME As String = "tblSettings"
Private Const COLUMN_KEY As String = "Key"
Private Const COLUMN_VALUE As String = "Value"

Private Const ERROR_TYPE_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"

Private Const ONEDRIVE_URL_PREFIX As String = "https://d.docs.live.net/"

Public Function GetSettingValue( _
    ByVal key As String, _
    ByRef value As String _
) As COperationResult

    Dim settingsTable As ListObject
    Dim keyColumn As ListColumn
    Dim valueColumn As ListColumn
    Dim rowIndex As Long
    Dim currentKeyValue As Variant
    Dim currentSettingValue As Variant
    Dim matchCount As Long

    On Error GoTo ErrorHandler

    value = vbNullString

    If Len(Trim$(key)) = 0 Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Setting key is empty.", _
            "Key")
        Exit Function
    End If

    Set settingsTable = GetSettingsTable()

    If settingsTable Is Nothing Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Settings sheet or tblSettings could not be found.", _
            SETTINGS_SHEET_NAME)
        Exit Function
    End If

    Set keyColumn = GetListColumn(settingsTable, COLUMN_KEY)

    If keyColumn Is Nothing Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Required column was not found in tblSettings.", _
            COLUMN_KEY)
        Exit Function
    End If

    Set valueColumn = GetListColumn(settingsTable, COLUMN_VALUE)

    If valueColumn Is Nothing Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Required column was not found in tblSettings.", _
            COLUMN_VALUE)
        Exit Function
    End If

    If settingsTable.DataBodyRange Is Nothing Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "tblSettings contains no data rows.", _
            key)
        Exit Function
    End If

    For rowIndex = 1 To settingsTable.ListRows.Count

        currentKeyValue = keyColumn.DataBodyRange.Cells(rowIndex, 1).Value

        If IsError(currentKeyValue) Then
            Set GetSettingValue = CreateFailureResult( _
                ERROR_TYPE_CONFIGURATION, _
                "An Excel error value was found in the Settings Key column.", _
                COLUMN_KEY)
            Exit Function
        End If

        If StrComp( _
            Trim$(CStr(currentKeyValue)), _
            Trim$(key), _
            vbTextCompare _
        ) = 0 Then

            matchCount = matchCount + 1

            If matchCount > 1 Then
                Set GetSettingValue = CreateFailureResult( _
                    ERROR_TYPE_CONFIGURATION, _
                    "Duplicate setting keys were found.", _
                    key)
                Exit Function
            End If

            currentSettingValue = valueColumn.DataBodyRange.Cells(rowIndex, 1).Value

            If IsError(currentSettingValue) Then
                Set GetSettingValue = CreateFailureResult( _
                    ERROR_TYPE_CONFIGURATION, _
                    "An Excel error value was found in the Settings Value column.", _
                    key)
                Exit Function
            End If

            value = CStr(currentSettingValue)
        End If
    Next rowIndex

    If matchCount = 0 Then
        Set GetSettingValue = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "The requested setting key was not found.", _
            key)
        Exit Function
    End If

    Set GetSettingValue = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set GetSettingValue = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error while reading Settings: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        key)
End Function

Public Function ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult

    Dim workbookPath As String
    Dim localWorkbookPath As String
    Dim resolutionErrorMessage As String

    On Error GoTo ErrorHandler

    absolutePath = vbNullString
    relativePath = Trim$(relativePath)

    If Len(relativePath) = 0 Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "Relative path is empty.", _
            "relativePath")
        Exit Function
    End If

    If IsAbsolutePath(relativePath) Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "An absolute path is not allowed. Use a workbook-relative path.", _
            relativePath)
        Exit Function
    End If

    workbookPath = Trim$(ThisWorkbook.Path)

    If Len(workbookPath) = 0 Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "ThisWorkbook has not been saved. Workbook-relative path cannot be resolved.", _
            "ThisWorkbook.Path")
        Exit Function
    End If

    If IsOneDriveWebPath(workbookPath) Then

        If Not TryResolveOneDriveLocalWorkbookPath( _
            workbookPath, _
            localWorkbookPath, _
            resolutionErrorMessage _
        ) Then
            Set ResolveWorkbookRelativePath = CreateFailureResult( _
                ERROR_TYPE_CONFIGURATION, _
                resolutionErrorMessage, _
                workbookPath)
            Exit Function
        End If

    ElseIf IsWebUrl(workbookPath) Then

        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            ERROR_TYPE_CONFIGURATION, _
            "ThisWorkbook.Path is a web URL that is not supported by the current path resolver.", _
            workbookPath)
        Exit Function

    Else

        localWorkbookPath = NormalizeWindowsPath(workbookPath)

    End If

    absolutePath = JoinWindowsPath(localWorkbookPath, relativePath)

    Set ResolveWorkbookRelativePath = CreateSuccessResult()
    Exit Function

ErrorHandler:
    absolutePath = vbNullString

    Set ResolveWorkbookRelativePath = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unexpected error while resolving workbook-relative path: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        relativePath)
End Function

Private Function GetSettingsTable() As ListObject

    Dim ws As Worksheet

    On Error GoTo NotFound

    Set ws = ThisWorkbook.Worksheets(SETTINGS_SHEET_NAME)
    Set GetSettingsTable = ws.ListObjects(SETTINGS_TABLE_NAME)

    Exit Function

NotFound:
    Set GetSettingsTable = Nothing
End Function

Private Function GetListColumn( _
    ByVal table As ListObject, _
    ByVal columnName As String _
) As ListColumn

    On Error GoTo NotFound

    Set GetListColumn = table.ListColumns(columnName)
    Exit Function

NotFound:
    Set GetListColumn = Nothing
End Function

Private Function IsAbsolutePath(ByVal pathValue As String) As Boolean

    Dim normalizedPath As String

    normalizedPath = Trim$(pathValue)

    If Len(normalizedPath) = 0 Then Exit Function

    ' Drive-letter path: C:\... or C:/...
    If Len(normalizedPath) >= 3 Then
        If Mid$(normalizedPath, 2, 1) = ":" Then
            If Mid$(normalizedPath, 3, 1) = "\" Or _
               Mid$(normalizedPath, 3, 1) = "/" Then
                IsAbsolutePath = True
                Exit Function
            End If
        End If
    End If

    ' Rooted / UNC path.
    If Left$(normalizedPath, 1) = "\" Or _
       Left$(normalizedPath, 1) = "/" Then
        IsAbsolutePath = True
        Exit Function
    End If

    ' URL.
    If InStr(1, normalizedPath, "://", vbTextCompare) > 0 Then
        IsAbsolutePath = True
    End If
End Function

Private Function IsOneDriveWebPath(ByVal pathValue As String) As Boolean

    If Len(pathValue) < Len(ONEDRIVE_URL_PREFIX) Then Exit Function

    IsOneDriveWebPath = _
        (StrComp( _
            Left$(pathValue, Len(ONEDRIVE_URL_PREFIX)), _
            ONEDRIVE_URL_PREFIX, _
            vbTextCompare _
        ) = 0)
End Function

Private Function IsWebUrl(ByVal pathValue As String) As Boolean

    IsWebUrl = _
        (InStr(1, pathValue, "://", vbTextCompare) > 0)
End Function

Private Function TryResolveOneDriveLocalWorkbookPath( _
    ByVal workbookWebPath As String, _
    ByRef localWorkbookPath As String, _
    ByRef errorMessage As String _
) As Boolean

    Dim relativeWorkbookPath As String
    Dim roots As Object
    Dim validPaths As Object
    Dim rootKey As Variant
    Dim candidateRoot As String
    Dim candidateWorkbookPath As String
    Dim resolvedItems As Variant

    localWorkbookPath = vbNullString
    errorMessage = vbNullString

    If Not TryExtractOneDriveRelativePath( _
        workbookWebPath, _
        relativeWorkbookPath _
    ) Then
        errorMessage = _
            "The OneDrive web URL could not be parsed into a workbook-relative path."
        Exit Function
    End If

    Set roots = CreateObject("Scripting.Dictionary")
    roots.CompareMode = vbTextCompare

    AddUniqueRoot roots, Environ$("OneDrive")
    AddUniqueRoot roots, Environ$("OneDriveConsumer")
    AddUniqueRoot roots, Environ$("OneDriveCommercial")

    If roots.Count = 0 Then
        errorMessage = _
            "No OneDrive local root could be obtained from environment variables."
        Exit Function
    End If

    Set validPaths = CreateObject("Scripting.Dictionary")
    validPaths.CompareMode = vbTextCompare

    For Each rootKey In roots.Keys

        candidateRoot = CStr(roots(rootKey))
        candidateWorkbookPath = JoinWindowsPath( _
            candidateRoot, _
            relativeWorkbookPath _
        )

        If DirectoryExists(candidateWorkbookPath) Then
            If Not validPaths.Exists(candidateWorkbookPath) Then
                validPaths.Add candidateWorkbookPath, candidateWorkbookPath
            End If
        End If

    Next rootKey

    If validPaths.Count = 0 Then
        errorMessage = _
            "No existing local OneDrive workbook directory matched the web URL."
        Exit Function
    End If

    If validPaths.Count > 1 Then
        errorMessage = _
            "Multiple local OneDrive workbook directories matched the web URL."
        Exit Function
    End If

    resolvedItems = validPaths.Items
    localWorkbookPath = CStr(resolvedItems(0))

    TryResolveOneDriveLocalWorkbookPath = True
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

    remainder = Mid$( _
        workbookWebPath, _
        Len(ONEDRIVE_URL_PREFIX) + 1 _
    )

    separatorPosition = InStr(1, remainder, "/", vbBinaryCompare)

    If separatorPosition <= 1 Then Exit Function

    cid = Left$(remainder, separatorPosition - 1)

    If Len(Trim$(cid)) = 0 Then Exit Function

    relativePath = Mid$(remainder, separatorPosition + 1)
    relativePath = NormalizeWindowsPath(relativePath)
    relativePath = TrimLeadingPathSeparators(relativePath)
    relativePath = TrimTrailingPathSeparators(relativePath)

    If Len(relativePath) = 0 Then Exit Function

    TryExtractOneDriveRelativePath = True
End Function

Private Sub AddUniqueRoot( _
    ByVal roots As Object, _
    ByVal rootValue As String _
)

    Dim normalizedRoot As String

    normalizedRoot = NormalizeWindowsPath(Trim$(rootValue))
    normalizedRoot = TrimTrailingPathSeparators(normalizedRoot)

    If Len(normalizedRoot) = 0 Then Exit Sub

    If Not roots.Exists(normalizedRoot) Then
        roots.Add normalizedRoot, normalizedRoot
    End If
End Sub

Private Function JoinWindowsPath( _
    ByVal basePath As String, _
    ByVal childPath As String _
) As String

    Dim normalizedBase As String
    Dim normalizedChild As String

    normalizedBase = NormalizeWindowsPath(basePath)
    normalizedChild = NormalizeWindowsPath(childPath)

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

Private Function NormalizeWindowsPath( _
    ByVal pathValue As String _
) As String

    NormalizeWindowsPath = Replace(Trim$(pathValue), "/", "\")
End Function

Private Function TrimLeadingPathSeparators( _
    ByVal pathValue As String _
) As String

    Do While Len(pathValue) > 0
        If Left$(pathValue, 1) <> "\" And _
           Left$(pathValue, 1) <> "/" Then
            Exit Do
        End If

        pathValue = Mid$(pathValue, 2)
    Loop

    TrimLeadingPathSeparators = pathValue
End Function

Private Function TrimTrailingPathSeparators( _
    ByVal pathValue As String _
) As String

    Do While Len(pathValue) > 0
        If Right$(pathValue, 1) <> "\" And _
           Right$(pathValue, 1) <> "/" Then
            Exit Do
        End If

        pathValue = Left$(pathValue, Len(pathValue) - 1)
    Loop

    TrimTrailingPathSeparators = pathValue
End Function

Private Function DirectoryExists( _
    ByVal folderPath As String _
) As Boolean

    Dim attributes As Long

    On Error GoTo NotFound

    attributes = GetAttr(folderPath)
    DirectoryExists = ((attributes And vbDirectory) = vbDirectory)

    Exit Function

NotFound:
    DirectoryExists = False
End Function
