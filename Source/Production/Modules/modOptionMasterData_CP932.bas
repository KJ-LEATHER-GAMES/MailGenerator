Attribute VB_Name = "modOptionMasterData"
Option Explicit

Private Const OPTION_MASTER_SHEET_NAME As String = "OptionMaster"
Private Const OPTION_MASTER_TABLE_NAME As String = "tblOptionMaster"

Private Const KEY_OPTION_GROUP As String = "OptionGroup"
Private Const KEY_VALUE As String = "Value"
Private Const KEY_SORT_ORDER As String = "SortOrder"
Private Const KEY_ACTIVE As String = "Active"
Private Const KEY_ROW_INDEX As String = "__RowIndex"

Public Function GetActiveOptions( _
    ByVal optionGroup As String, _
    ByRef items As Collection _
) As COperationResult

    Dim lo As ListObject
    Dim result As COperationResult
    Dim rowIndex As Long
    Dim item As Object
    Dim activeValue As Boolean
    Dim groupValue As Variant

    Set items = New Collection

    If Len(Trim$(optionGroup)) = 0 Then
        Set GetActiveOptions = CreateFailureResult( _
            "ConfigurationError", _
            "OptionGroup is empty.", _
            KEY_OPTION_GROUP)
        Exit Function
    End If

    Set result = GetOptionMasterTable(lo)
    If Not result.Success Then
        Set GetActiveOptions = result
        Exit Function
    End If

    If lo.DataBodyRange Is Nothing Then
        Set GetActiveOptions = CreateSuccessResult()
        Exit Function
    End If

    For rowIndex = 1 To lo.ListRows.Count

        Set result = ReadCellValue(lo, KEY_OPTION_GROUP, rowIndex, groupValue)
        If Not result.Success Then
            Set GetActiveOptions = result
            Exit Function
        End If

        If StrComp(CStr(groupValue), optionGroup, vbBinaryCompare) = 0 Then

            Set result = ReadActiveValue(lo, rowIndex, activeValue)
            If Not result.Success Then
                Set GetActiveOptions = result
                Exit Function
            End If

            If activeValue Then

                Set result = ReadOptionRow(lo, rowIndex, item)
                If Not result.Success Then
                    Set GetActiveOptions = result
                    Exit Function
                End If

                Set result = InsertSortedBySortOrder(items, item)
                If Not result.Success Then
                    Set GetActiveOptions = result
                    Exit Function
                End If

            End If

        End If

    Next rowIndex

    Set GetActiveOptions = CreateSuccessResult()

End Function

Private Function GetOptionMasterTable( _
    ByRef lo As ListObject _
) As COperationResult

    Dim ws As Worksheet
    Dim result As COperationResult

    Set lo = Nothing

    On Error GoTo UnexpectedError

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(OPTION_MASTER_SHEET_NAME)
    On Error GoTo UnexpectedError

    If ws Is Nothing Then
        Set GetOptionMasterTable = CreateFailureResult( _
            "ConfigurationError", _
            "OptionMaster worksheet was not found.", _
            OPTION_MASTER_SHEET_NAME)
        Exit Function
    End If

    On Error Resume Next
    Set lo = ws.ListObjects(OPTION_MASTER_TABLE_NAME)
    On Error GoTo UnexpectedError

    If lo Is Nothing Then
        Set GetOptionMasterTable = CreateFailureResult( _
            "ConfigurationError", _
            "tblOptionMaster table was not found.", _
            OPTION_MASTER_TABLE_NAME)
        Exit Function
    End If

    Set result = ValidateRequiredColumns(lo)
    If Not result.Success Then
        Set GetOptionMasterTable = result
        Exit Function
    End If

    Set GetOptionMasterTable = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set GetOptionMasterTable = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected error while accessing OptionMaster table: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        OPTION_MASTER_TABLE_NAME)

End Function

Private Function ValidateRequiredColumns( _
    ByVal lo As ListObject _
) As COperationResult

    Dim requiredColumns As Variant
    Dim columnName As Variant
    Dim listColumn As ListColumn

    requiredColumns = Array( _
        KEY_OPTION_GROUP, _
        KEY_VALUE, _
        KEY_SORT_ORDER, _
        KEY_ACTIVE)

    For Each columnName In requiredColumns

        Set listColumn = Nothing

        On Error Resume Next
        Set listColumn = lo.ListColumns(CStr(columnName))
        On Error GoTo 0

        If listColumn Is Nothing Then
            Set ValidateRequiredColumns = CreateFailureResult( _
                "ConfigurationError", _
                "Required column was not found in tblOptionMaster.", _
                CStr(columnName))
            Exit Function
        End If

    Next columnName

    Set ValidateRequiredColumns = CreateSuccessResult()

End Function

Private Function ReadOptionRow( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByRef item As Object _
) As COperationResult

    Dim result As COperationResult
    Dim value As Variant

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    Set result = ReadCellValue(lo, KEY_OPTION_GROUP, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_OPTION_GROUP, value

    Set result = ReadCellValue(lo, KEY_VALUE, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_VALUE, value

    Set result = ReadCellValue(lo, KEY_SORT_ORDER, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed

    If Len(Trim$(CStr(value))) = 0 Or Not IsNumeric(value) Then
        Set ReadOptionRow = CreateFailureResult( _
            "ConfigurationError", _
            "Active Option SortOrder must be numeric.", _
            BuildCellTarget(KEY_SORT_ORDER, rowIndex))
        Set item = Nothing
        Exit Function
    End If

    item.Add KEY_SORT_ORDER, CDbl(value)

    Set result = ReadCellValue(lo, KEY_ACTIVE, rowIndex, value)
    If Not result.Success Then GoTo ReadFailed
    item.Add KEY_ACTIVE, value

    item.Add KEY_ROW_INDEX, rowIndex

    Set ReadOptionRow = CreateSuccessResult()
    Exit Function

ReadFailed:
    Set item = Nothing
    Set ReadOptionRow = result

End Function

Private Function ReadActiveValue( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByRef activeValue As Boolean _
) As COperationResult

    Dim rawValue As Variant
    Dim result As COperationResult
    Dim normalized As String

    activeValue = False

    Set result = ReadCellValue(lo, KEY_ACTIVE, rowIndex, rawValue)
    If Not result.Success Then
        Set ReadActiveValue = result
        Exit Function
    End If

    If VarType(rawValue) = vbBoolean Then
        activeValue = CBool(rawValue)
        Set ReadActiveValue = CreateSuccessResult()
        Exit Function
    End If

    If IsNumeric(rawValue) Then
        If CDbl(rawValue) = 1 Then
            activeValue = True
            Set ReadActiveValue = CreateSuccessResult()
            Exit Function
        ElseIf CDbl(rawValue) = 0 Then
            activeValue = False
            Set ReadActiveValue = CreateSuccessResult()
            Exit Function
        End If
    End If

    normalized = LCase$(Trim$(CStr(rawValue)))

    If normalized = "true" Then
        activeValue = True
        Set ReadActiveValue = CreateSuccessResult()
        Exit Function
    End If

    If normalized = "false" Then
        activeValue = False
        Set ReadActiveValue = CreateSuccessResult()
        Exit Function
    End If

    Set ReadActiveValue = CreateFailureResult( _
        "ConfigurationError", _
        "Active must be True or False.", _
        BuildCellTarget(KEY_ACTIVE, rowIndex))

End Function

Private Function InsertSortedBySortOrder( _
    ByRef items As Collection, _
    ByVal newItem As Object _
) As COperationResult

    Dim sortedItems As Collection
    Dim currentItem As Object
    Dim inserted As Boolean
    Dim i As Long

    On Error GoTo UnexpectedError

    Set sortedItems = New Collection
    inserted = False

    For i = 1 To items.Count

        Set currentItem = items(i)

        If Not inserted Then
            If ShouldComeBefore(newItem, currentItem) Then
                sortedItems.Add newItem
                inserted = True
            End If
        End If

        sortedItems.Add currentItem

    Next i

    If Not inserted Then
        sortedItems.Add newItem
    End If

    Set items = sortedItems
    Set InsertSortedBySortOrder = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set InsertSortedBySortOrder = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected error while sorting OptionMaster values: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        OPTION_MASTER_TABLE_NAME)

End Function

Private Function ShouldComeBefore( _
    ByVal leftItem As Object, _
    ByVal rightItem As Object _
) As Boolean

    Dim leftSortOrder As Double
    Dim rightSortOrder As Double
    Dim leftRowIndex As Long
    Dim rightRowIndex As Long

    leftSortOrder = CDbl(leftItem(KEY_SORT_ORDER))
    rightSortOrder = CDbl(rightItem(KEY_SORT_ORDER))

    If leftSortOrder < rightSortOrder Then
        ShouldComeBefore = True
        Exit Function
    End If

    If leftSortOrder > rightSortOrder Then
        ShouldComeBefore = False
        Exit Function
    End If

    leftRowIndex = CLng(leftItem(KEY_ROW_INDEX))
    rightRowIndex = CLng(rightItem(KEY_ROW_INDEX))

    ShouldComeBefore = (leftRowIndex < rightRowIndex)

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
            "OptionMaster contains an Excel error value.", _
            BuildCellTarget(columnName, rowIndex))
        Exit Function
    End If

    value = cellValue
    Set ReadCellValue = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set ReadCellValue = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected error while reading OptionMaster: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        BuildCellTarget(columnName, rowIndex))

End Function

Private Function BuildCellTarget( _
    ByVal columnName As String, _
    ByVal rowIndex As Long _
) As String

    BuildCellTarget = OPTION_MASTER_TABLE_NAME & _
        "[" & columnName & "] Row=" & CStr(rowIndex)

End Function
