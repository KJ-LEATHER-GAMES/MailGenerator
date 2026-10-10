Attribute VB_Name = "modVariableDefinitionData"
Option Explicit

Private Const VARIABLE_DEFINITION_SHEET_NAME As String = "VariableDefinition"
Private Const VARIABLE_DEFINITION_TABLE_NAME As String = "tblVariableDefinition"

Private Const STATUS_ACTIVE As String = "Active"

Private Const KEY_VARIABLE_NAME As String = "VariableName"
Private Const KEY_DISPLAY_NAME As String = "DisplayName"
Private Const KEY_TYPE As String = "Type"
Private Const KEY_REQUIRED As String = "Required"
Private Const KEY_DESCRIPTION As String = "Description"
Private Const KEY_OPTION_SOURCE As String = "OptionSource"
Private Const KEY_SORT_ORDER As String = "SortOrder"
Private Const KEY_FORMAT As String = "Format"
Private Const KEY_TEMPLATE_LOCATION As String = "TemplateLocation"
Private Const KEY_STATUS As String = "Status"
Private Const KEY_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const KEY_LAST_DETECTED_AT As String = "LastDetectedAt"

' Internal metadata used by later UI sorting.
' 1-based index within tblVariableDefinition.DataBodyRange.
Private Const KEY_ROW_INDEX As String = "__RowIndex"

Public Function GetAllVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult

    Dim lo As ListObject
    Dim result As COperationResult

    Set items = New Collection

    Set result = GetVariableDefinitionTable(lo)
    If Not result.Success Then
        Set GetAllVariableDefinitions = result
        Exit Function
    End If

    Set result = ReadVariableDefinitions(lo, False, items)
    Set GetAllVariableDefinitions = result

End Function

Public Function GetActiveVariableDefinitions( _
    ByRef items As Collection _
) As COperationResult

    Dim lo As ListObject
    Dim result As COperationResult

    Set items = New Collection

    Set result = GetVariableDefinitionTable(lo)
    If Not result.Success Then
        Set GetActiveVariableDefinitions = result
        Exit Function
    End If

    Set result = ReadVariableDefinitions(lo, True, items)
    Set GetActiveVariableDefinitions = result

End Function

Private Function GetVariableDefinitionTable( _
    ByRef lo As ListObject _
) As COperationResult

    Dim ws As Worksheet
    Dim result As COperationResult

    Set lo = Nothing

    On Error GoTo UnexpectedError

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(VARIABLE_DEFINITION_SHEET_NAME)
    On Error GoTo UnexpectedError

    If ws Is Nothing Then
        Set GetVariableDefinitionTable = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition worksheet was not found.", _
            VARIABLE_DEFINITION_SHEET_NAME)
        Exit Function
    End If

    On Error Resume Next
    Set lo = ws.ListObjects(VARIABLE_DEFINITION_TABLE_NAME)
    On Error GoTo UnexpectedError

    If lo Is Nothing Then
        Set GetVariableDefinitionTable = CreateFailureResult( _
            "ConfigurationError", _
            "tblVariableDefinition table was not found.", _
            VARIABLE_DEFINITION_TABLE_NAME)
        Exit Function
    End If

    Set result = ValidateRequiredColumns(lo)
    If Not result.Success Then
        Set GetVariableDefinitionTable = result
        Exit Function
    End If

    Set GetVariableDefinitionTable = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set GetVariableDefinitionTable = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected error while accessing VariableDefinition table: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        VARIABLE_DEFINITION_TABLE_NAME)

End Function

Private Function ValidateRequiredColumns( _
    ByVal lo As ListObject _
) As COperationResult

    Dim requiredColumns As Variant
    Dim columnName As Variant
    Dim listColumn As ListColumn

    requiredColumns = Array( _
        KEY_VARIABLE_NAME, _
        KEY_DISPLAY_NAME, _
        KEY_TYPE, _
        KEY_REQUIRED, _
        KEY_DESCRIPTION, _
        KEY_OPTION_SOURCE, _
        KEY_SORT_ORDER, _
        KEY_FORMAT, _
        KEY_TEMPLATE_LOCATION, _
        KEY_STATUS, _
        KEY_FIRST_DETECTED_AT, _
        KEY_LAST_DETECTED_AT)

    For Each columnName In requiredColumns

        Set listColumn = Nothing

        On Error Resume Next
        Set listColumn = lo.ListColumns(CStr(columnName))
        On Error GoTo 0

        If listColumn Is Nothing Then
            Set ValidateRequiredColumns = CreateFailureResult( _
                "ConfigurationError", _
                "Required column was not found in tblVariableDefinition.", _
                CStr(columnName))
            Exit Function
        End If

    Next columnName

    Set ValidateRequiredColumns = CreateSuccessResult()

End Function

Private Function ReadVariableDefinitions( _
    ByVal lo As ListObject, _
    ByVal activeOnly As Boolean, _
    ByRef items As Collection _
) As COperationResult

    Dim rowIndex As Long
    Dim item As Object
    Dim statusValue As Variant
    Dim result As COperationResult

    Set items = New Collection

    If lo.DataBodyRange Is Nothing Then
        Set ReadVariableDefinitions = CreateSuccessResult()
        Exit Function
    End If

    For rowIndex = 1 To lo.ListRows.Count

        Set result = ReadVariableDefinitionRow(lo, rowIndex, item)
        If Not result.Success Then
            Set ReadVariableDefinitions = result
            Exit Function
        End If

        statusValue = item(KEY_STATUS)

        If activeOnly Then
            If IsError(statusValue) Then
                Set ReadVariableDefinitions = CreateFailureResult( _
                    "ConfigurationError", _
                    "Status contains an Excel error value.", _
                    BuildCellTarget(KEY_STATUS, rowIndex))
                Exit Function
            End If

            If StrComp(CStr(statusValue), STATUS_ACTIVE, vbTextCompare) = 0 Then
                items.Add item
            End If
        Else
            items.Add item
        End If

    Next rowIndex

    Set ReadVariableDefinitions = CreateSuccessResult()

End Function

Private Function ReadVariableDefinitionRow( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByRef item As Object _
) As COperationResult

    Dim result As COperationResult
    Dim value As Variant

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    Set result = ReadCellValue(lo, KEY_VARIABLE_NAME, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_VARIABLE_NAME, value

    Set result = ReadCellValue(lo, KEY_DISPLAY_NAME, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_DISPLAY_NAME, value

    Set result = ReadCellValue(lo, KEY_TYPE, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_TYPE, value

    Set result = ReadCellValue(lo, KEY_REQUIRED, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_REQUIRED, value

    Set result = ReadCellValue(lo, KEY_DESCRIPTION, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_DESCRIPTION, value

    Set result = ReadCellValue(lo, KEY_OPTION_SOURCE, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_OPTION_SOURCE, value

    Set result = ReadCellValue(lo, KEY_SORT_ORDER, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_SORT_ORDER, value

    Set result = ReadCellValue(lo, KEY_FORMAT, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_FORMAT, value

    Set result = ReadCellValue(lo, KEY_TEMPLATE_LOCATION, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_TEMPLATE_LOCATION, value

    Set result = ReadCellValue(lo, KEY_STATUS, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_STATUS, value

    Set result = ReadCellValue(lo, KEY_FIRST_DETECTED_AT, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_FIRST_DETECTED_AT, value

    Set result = ReadCellValue(lo, KEY_LAST_DETECTED_AT, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_LAST_DETECTED_AT, value

    item.Add KEY_ROW_INDEX, rowIndex

    Set ReadVariableDefinitionRow = CreateSuccessResult()
    Exit Function

ReadFailed:
    Set item = Nothing
    Set ReadVariableDefinitionRow = result

End Function

Private Function ReadCellValue( _
    ByVal lo As ListObject, _
    ByVal columnName As String, _
    ByVal rowIndex As Long, _
    ByRef value As Variant _
) As COperationResult

    Dim cellValue As Variant

    On Error GoTo UnexpectedError

    cellValue = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2

    If IsError(cellValue) Then
        Set ReadCellValue = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition contains an Excel error value.", _
            BuildCellTarget(columnName, rowIndex))
        Exit Function
    End If

    value = cellValue
    Set ReadCellValue = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set ReadCellValue = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected error while reading VariableDefinition: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        BuildCellTarget(columnName, rowIndex))

End Function

Private Function BuildCellTarget( _
    ByVal columnName As String, _
    ByVal rowIndex As Long _
) As String

    BuildCellTarget = VARIABLE_DEFINITION_TABLE_NAME & _
        "[" & columnName & "] Row=" & CStr(rowIndex)

End Function
