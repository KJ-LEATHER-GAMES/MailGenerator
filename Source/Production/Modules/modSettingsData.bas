Attribute VB_Name = "modSettingsData"
Option Explicit

Private Const SETTINGS_SHEET_NAME As String = "Settings"
Private Const SETTINGS_TABLE_NAME As String = "tblSettings"
Private Const SETTINGS_KEY_COLUMN As String = "Key"
Private Const SETTINGS_VALUE_COLUMN As String = "Value"

Public Function GetSettingValue( _
    ByVal key As String, _
    ByRef value As String _
) As COperationResult

    Dim result As COperationResult
    Dim settingsTable As ListObject
    Dim keyColumnIndex As Long
    Dim valueColumnIndex As Long
    Dim rowIndex As Long
    Dim matchedCount As Long
    Dim currentKey As String
    Dim currentValue As Variant
    Dim normalizedKey As String

    On Error GoTo UnexpectedError

    value = vbNullString
    normalizedKey = Trim$(key)

    If Len(normalizedKey) = 0 Then
        Set GetSettingValue = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsから取得するKeyが指定されていません。", _
            "Settings.Key")
        Exit Function
    End If

    Set result = GetSettingsTable(settingsTable)
    If Not result.Success Then
        Set GetSettingValue = result
        Exit Function
    End If

    keyColumnIndex = GetListColumnIndex(settingsTable, SETTINGS_KEY_COLUMN)
    valueColumnIndex = GetListColumnIndex(settingsTable, SETTINGS_VALUE_COLUMN)

    If keyColumnIndex = 0 Or valueColumnIndex = 0 Then
        Set GetSettingValue = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsテーブルに必要なKey / Value列がありません。", _
            SETTINGS_TABLE_NAME)
        Exit Function
    End If

    If settingsTable.DataBodyRange Is Nothing Then
        Set GetSettingValue = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsテーブルに設定値が登録されていません。", _
            normalizedKey)
        Exit Function
    End If

    matchedCount = 0

    For rowIndex = 1 To settingsTable.DataBodyRange.Rows.Count
        currentValue = settingsTable.DataBodyRange.Cells(rowIndex, keyColumnIndex).Value2

        If Not IsError(currentValue) Then
            currentKey = Trim$(CStr(currentValue))

            If StrComp(currentKey, normalizedKey, vbTextCompare) = 0 Then
                matchedCount = matchedCount + 1

                If matchedCount > 1 Then
                    Set GetSettingValue = CreateFailureResult( _
                        "ConfigurationError", _
                        "Settingsに同じKeyが複数登録されています。", _
                        normalizedKey)
                    Exit Function
                End If

                currentValue = settingsTable.DataBodyRange.Cells(rowIndex, valueColumnIndex).Value2

                If IsError(currentValue) Then
                    Set GetSettingValue = CreateFailureResult( _
                        "ConfigurationError", _
                        "SettingsのValueにExcelエラー値が設定されています。", _
                        normalizedKey)
                    Exit Function
                End If

                If IsEmpty(currentValue) Then
                    value = vbNullString
                Else
                    value = CStr(currentValue)
                End If
            End If
        End If
    Next rowIndex

    If matchedCount = 0 Then
        Set GetSettingValue = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsに指定されたKeyが登録されていません。", _
            normalizedKey)
        Exit Function
    End If

    Set GetSettingValue = CreateSuccessResult()
    Exit Function

UnexpectedError:
    value = vbNullString
    Set GetSettingValue = CreateFailureResult( _
        "UnexpectedError", _
        "Settingsの読み取り中に予期しないエラーが発生しました。", _
        normalizedKey)
End Function

Public Function ResolveWorkbookRelativePath( _
    ByVal relativePath As String, _
    ByRef absolutePath As String _
) As COperationResult

    Dim normalizedPath As String
    Dim workbookPath As String
    Dim separator As String

    On Error GoTo UnexpectedError

    absolutePath = vbNullString
    normalizedPath = Trim$(relativePath)

    If Len(normalizedPath) = 0 Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            "ConfigurationError", _
            "Workbook基準で解決する相対Pathが指定されていません。", _
            "TemplatePath")
        Exit Function
    End If

    If IsAbsolutePath(normalizedPath) Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            "ConfigurationError", _
            "TemplatePathにはWorkbook基準の相対Pathを指定してください。", _
            "TemplatePath")
        Exit Function
    End If

    workbookPath = ThisWorkbook.Path

    If Len(workbookPath) = 0 Then
        Set ResolveWorkbookRelativePath = CreateFailureResult( _
            "ConfigurationError", _
            "Workbookの保存場所を特定できません。Workbookを保存してから再実行してください。", _
            "ThisWorkbook.Path")
        Exit Function
    End If

    separator = Application.PathSeparator

    If Right$(workbookPath, 1) = separator Then
        absolutePath = workbookPath & normalizedPath
    Else
        absolutePath = workbookPath & separator & normalizedPath
    End If

    Set ResolveWorkbookRelativePath = CreateSuccessResult()
    Exit Function

UnexpectedError:
    absolutePath = vbNullString
    Set ResolveWorkbookRelativePath = CreateFailureResult( _
        "UnexpectedError", _
        "Workbook基準のPath解決中に予期しないエラーが発生しました。", _
        "TemplatePath")
End Function

Private Function GetSettingsTable( _
    ByRef settingsTable As ListObject _
) As COperationResult

    Dim settingsSheet As Worksheet

    On Error GoTo UnexpectedError

    Set settingsTable = Nothing

    On Error Resume Next
    Set settingsSheet = ThisWorkbook.Worksheets(SETTINGS_SHEET_NAME)
    On Error GoTo UnexpectedError

    If settingsSheet Is Nothing Then
        Set GetSettingsTable = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsシートが見つかりません。", _
            SETTINGS_SHEET_NAME)
        Exit Function
    End If

    On Error Resume Next
    Set settingsTable = settingsSheet.ListObjects(SETTINGS_TABLE_NAME)
    On Error GoTo UnexpectedError

    If settingsTable Is Nothing Then
        Set GetSettingsTable = CreateFailureResult( _
            "ConfigurationError", _
            "Settingsテーブルが見つかりません。", _
            SETTINGS_TABLE_NAME)
        Exit Function
    End If

    Set GetSettingsTable = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set settingsTable = Nothing
    Set GetSettingsTable = CreateFailureResult( _
        "UnexpectedError", _
        "Settingsテーブルの取得中に予期しないエラーが発生しました。", _
        SETTINGS_TABLE_NAME)
End Function

Private Function GetListColumnIndex( _
    ByVal table As ListObject, _
    ByVal columnName As String _
) As Long

    Dim listColumn As ListColumn

    On Error Resume Next
    Set listColumn = table.ListColumns(columnName)
    On Error GoTo 0

    If listColumn Is Nothing Then
        GetListColumnIndex = 0
    Else
        GetListColumnIndex = listColumn.Index
    End If
End Function

Private Function IsAbsolutePath(ByVal pathValue As String) As Boolean
    Dim firstCharacter As String

    If Len(pathValue) = 0 Then Exit Function

    firstCharacter = Left$(pathValue, 1)

    If firstCharacter = "\" Or firstCharacter = "/" Then
        IsAbsolutePath = True
        Exit Function
    End If

    If Len(pathValue) >= 2 Then
        If Mid$(pathValue, 2, 1) = ":" Then
            IsAbsolutePath = True
        End If
    End If
End Function
