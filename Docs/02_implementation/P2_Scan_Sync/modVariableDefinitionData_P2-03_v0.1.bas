Attribute VB_Name = "modVariableDefinitionData"
Option Explicit

Private Const VARIABLE_DEFINITION_SHEET_NAME As String = "VariableDefinition"
Private Const VARIABLE_DEFINITION_TABLE_NAME As String = "tblVariableDefinition"

Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"

Private Const LOCATION_SUBJECT As String = "Subject"
Private Const LOCATION_BODY As String = "Body"
Private Const LOCATION_BOTH As String = "Both"

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private Const VARIABLE_NAME_PATTERN As String = "^[A-Za-z][A-Za-z0-9_]*$"

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

Public Function ApplySyncDiff( _
    ByVal syncDiffResult As Object _
) As COperationResult

    Dim lo As ListObject
    Dim result As COperationResult
    Dim rowMap As Object
    Dim newItems As Collection
    Dim existingItems As Collection
    Dim reactivatedItems As Collection
    Dim unusedItems As Collection
    Dim writeStarted As Boolean
    Dim errorNumber As Long
    Dim errorDescription As String

    writeStarted = False

    On Error GoTo UnexpectedError

    Set result = ValidateSyncDiffStructure(syncDiffResult)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = GetVariableDefinitionTable(lo)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = BuildExistingRowMap(lo, rowMap)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = ValidateDiffItems(syncDiffResult)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = ValidateCurrentState(lo, syncDiffResult, rowMap)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_NEW, newItems)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_EXISTING, existingItems)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_REACTIVATED, reactivatedItems)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_UNUSED, unusedItems)
    If Not result.Success Then
        Set ApplySyncDiff = result
        Exit Function
    End If

    If existingItems.Count = 0 And _
       reactivatedItems.Count = 0 And _
       unusedItems.Count = 0 And _
       newItems.Count = 0 Then

        Set ApplySyncDiff = CreateSuccessResult()
        Exit Function

    End If

    writeStarted = True

    ApplyExistingCollection lo, existingItems, rowMap
    ApplyExistingCollection lo, reactivatedItems, rowMap
    ApplyExistingCollection lo, unusedItems, rowMap
    AppendNewItems lo, newItems

    Set ApplySyncDiff = CreateSuccessResult()
    Exit Function

UnexpectedError:
    errorNumber = Err.Number
    errorDescription = Err.Description

    If writeStarted Then
        Set ApplySyncDiff = CreateFailureResult( _
            "UnexpectedError", _
            "Unexpected error while persisting VariableDefinition after writing started. " & _
                "The table may be partially updated. " & _
                CStr(errorNumber) & " - " & errorDescription, _
            VARIABLE_DEFINITION_TABLE_NAME)
    Else
        Set ApplySyncDiff = CreateFailureResult( _
            "UnexpectedError", _
            "Unexpected error while preparing VariableDefinition persistence: " & _
                CStr(errorNumber) & " - " & errorDescription, _
            VARIABLE_DEFINITION_TABLE_NAME)
    End If

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

Private Function ValidateSyncDiffStructure( _
    ByVal syncDiffResult As Object _
) As COperationResult

    Dim result As COperationResult
    Dim items As Collection

    If syncDiffResult Is Nothing Then
        Set ValidateSyncDiffStructure = CreateFailureResult( _
            "UnexpectedError", _
            "SyncDiffResult is Nothing.", _
            "SyncDiffResult")
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_NEW, items)
    If Not result.Success Then
        Set ValidateSyncDiffStructure = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_EXISTING, items)
    If Not result.Success Then
        Set ValidateSyncDiffStructure = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_REACTIVATED, items)
    If Not result.Success Then
        Set ValidateSyncDiffStructure = result
        Exit Function
    End If

    Set result = GetSyncCollection(syncDiffResult, SYNC_UNUSED, items)
    If Not result.Success Then
        Set ValidateSyncDiffStructure = result
        Exit Function
    End If

    Set ValidateSyncDiffStructure = CreateSuccessResult()

End Function

Private Function GetSyncCollection( _
    ByVal syncDiffResult As Object, _
    ByVal classification As String, _
    ByRef items As Collection _
) As COperationResult

    Dim exists As Boolean

    Set items = Nothing

    On Error GoTo InvalidStructure

    exists = syncDiffResult.Exists(classification)

    If Not exists Then
        Set GetSyncCollection = CreateFailureResult( _
            "UnexpectedError", _
            "Required SyncDiffResult classification was not found.", _
            classification)
        Exit Function
    End If

    Set items = syncDiffResult(classification)

    If items Is Nothing Then
        Set GetSyncCollection = CreateFailureResult( _
            "UnexpectedError", _
            "SyncDiffResult classification is Nothing.", _
            classification)
        Exit Function
    End If

    Set GetSyncCollection = CreateSuccessResult()
    Exit Function

InvalidStructure:
    Set items = Nothing
    Set GetSyncCollection = CreateFailureResult( _
        "UnexpectedError", _
        "SyncDiffResult classification is not a valid Collection.", _
        classification)

End Function

Private Function BuildExistingRowMap( _
    ByVal lo As ListObject, _
    ByRef rowMap As Object _
) As COperationResult

    Dim rowIndex As Long
    Dim variableNameValue As Variant
    Dim variableName As String
    Dim result As COperationResult

    Set rowMap = CreateObject("Scripting.Dictionary")
    rowMap.CompareMode = vbTextCompare

    If lo.DataBodyRange Is Nothing Then
        Set BuildExistingRowMap = CreateSuccessResult()
        Exit Function
    End If

    For rowIndex = 1 To lo.ListRows.Count

        Set result = ReadCellValue(lo, KEY_VARIABLE_NAME, rowIndex, variableNameValue)
        If Not result.Success Then
            Set rowMap = Nothing
            Set BuildExistingRowMap = result
            Exit Function
        End If

        If IsNull(variableNameValue) Then
            variableName = vbNullString
        Else
            variableName = CStr(variableNameValue)
        End If

        If rowMap.Exists(variableName) Then
            Set rowMap = Nothing
            Set BuildExistingRowMap = CreateFailureResult( _
                "ConfigurationError", _
                "Duplicate VariableName was found in tblVariableDefinition.", _
                variableName)
            Exit Function
        End If

        rowMap.Add variableName, rowIndex

    Next rowIndex

    Set BuildExistingRowMap = CreateSuccessResult()

End Function

Private Function ValidateDiffItems( _
    ByVal syncDiffResult As Object _
) As COperationResult

    Dim seenNames As Object
    Dim result As COperationResult

    Set seenNames = CreateObject("Scripting.Dictionary")
    seenNames.CompareMode = vbTextCompare

    Set result = ValidateDiffCollection(syncDiffResult, SYNC_NEW, seenNames)
    If Not result.Success Then
        Set ValidateDiffItems = result
        Exit Function
    End If

    Set result = ValidateDiffCollection(syncDiffResult, SYNC_EXISTING, seenNames)
    If Not result.Success Then
        Set ValidateDiffItems = result
        Exit Function
    End If

    Set result = ValidateDiffCollection(syncDiffResult, SYNC_REACTIVATED, seenNames)
    If Not result.Success Then
        Set ValidateDiffItems = result
        Exit Function
    End If

    Set result = ValidateDiffCollection(syncDiffResult, SYNC_UNUSED, seenNames)
    If Not result.Success Then
        Set ValidateDiffItems = result
        Exit Function
    End If

    Set ValidateDiffItems = CreateSuccessResult()

End Function

Private Function ValidateDiffCollection( _
    ByVal syncDiffResult As Object, _
    ByVal classification As String, _
    ByVal seenNames As Object _
) As COperationResult

    Dim items As Collection
    Dim item As Object
    Dim result As COperationResult
    Dim variableNameValue As Variant
    Dim variableName As String

    Set result = GetSyncCollection(syncDiffResult, classification, items)
    If Not result.Success Then
        Set ValidateDiffCollection = result
        Exit Function
    End If

    For Each item In items

        Set result = ValidateDiffItem(item, classification)
        If Not result.Success Then
            Set ValidateDiffCollection = result
            Exit Function
        End If

        Set result = GetRequiredDiffValue( _
            item, _
            KEY_VARIABLE_NAME, _
            variableNameValue, _
            classification)

        If Not result.Success Then
            Set ValidateDiffCollection = result
            Exit Function
        End If

        variableName = CStr(variableNameValue)

        If seenNames.Exists(variableName) Then
            Set ValidateDiffCollection = CreateFailureResult( _
                "UnexpectedError", _
                "VariableName appears in more than one SyncDiffResult classification.", _
                variableName)
            Exit Function
        End If

        seenNames.Add variableName, classification

    Next item

    Set ValidateDiffCollection = CreateSuccessResult()

End Function

Private Function ValidateDiffItem( _
    ByVal item As Object, _
    ByVal classification As String _
) As COperationResult

    Dim result As COperationResult
    Dim rawValue As Variant
    Dim variableName As String
    Dim templateLocation As String
    Dim statusValue As String
    Dim dateValue As Date

    If item Is Nothing Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "SyncDiffResult contains a Nothing item.", _
            classification)
        Exit Function
    End If

    Set result = GetRequiredDiffValue( _
        item, _
        KEY_VARIABLE_NAME, _
        rawValue, _
        classification)

    If Not result.Success Then
        Set ValidateDiffItem = result
        Exit Function
    End If

    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "VariableName is missing or invalid.", _
            classification)
        Exit Function
    End If

    variableName = CStr(rawValue)

    If Not IsValidVariableName(variableName) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "VariableName does not satisfy the required syntax.", _
            variableName)
        Exit Function
    End If

    Set result = GetRequiredDiffValue( _
        item, _
        KEY_TEMPLATE_LOCATION, _
        rawValue, _
        variableName)

    If Not result.Success Then
        Set ValidateDiffItem = result
        Exit Function
    End If

    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateLocation is missing or invalid.", _
            variableName)
        Exit Function
    End If

    templateLocation = CStr(rawValue)

    If StrComp(templateLocation, LOCATION_SUBJECT, vbBinaryCompare) <> 0 And _
       StrComp(templateLocation, LOCATION_BODY, vbBinaryCompare) <> 0 And _
       StrComp(templateLocation, LOCATION_BOTH, vbBinaryCompare) <> 0 Then

        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateLocation is outside the allowed value domain.", _
            variableName)
        Exit Function

    End If

    Set result = GetRequiredDiffValue( _
        item, _
        KEY_STATUS, _
        rawValue, _
        variableName)

    If Not result.Success Then
        Set ValidateDiffItem = result
        Exit Function
    End If

    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "Status is missing or invalid.", _
            variableName)
        Exit Function
    End If

    statusValue = CStr(rawValue)

    If StrComp(statusValue, STATUS_ACTIVE, vbBinaryCompare) <> 0 And _
       StrComp(statusValue, STATUS_UNUSED, vbBinaryCompare) <> 0 Then

        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "Status is outside the allowed value domain.", _
            variableName)
        Exit Function

    End If

    If StrComp(classification, SYNC_NEW, vbBinaryCompare) = 0 Or _
       StrComp(classification, SYNC_EXISTING, vbBinaryCompare) = 0 Or _
       StrComp(classification, SYNC_REACTIVATED, vbBinaryCompare) = 0 Then

        If StrComp(statusValue, STATUS_ACTIVE, vbBinaryCompare) <> 0 Then
            Set ValidateDiffItem = CreateFailureResult( _
                "UnexpectedError", _
                "SyncDiffResult classification and Status are inconsistent.", _
                variableName)
            Exit Function
        End If

    ElseIf StrComp(classification, SYNC_UNUSED, vbBinaryCompare) = 0 Then

        If StrComp(statusValue, STATUS_UNUSED, vbBinaryCompare) <> 0 Then
            Set ValidateDiffItem = CreateFailureResult( _
                "UnexpectedError", _
                "SyncDiffResult classification and Status are inconsistent.", _
                variableName)
            Exit Function
        End If

    Else
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "Unknown SyncDiffResult classification.", _
            classification)
        Exit Function
    End If

    Set result = GetRequiredDiffValue( _
        item, _
        KEY_FIRST_DETECTED_AT, _
        rawValue, _
        variableName)

    If Not result.Success Then
        Set ValidateDiffItem = result
        Exit Function
    End If

    If Not TryGetDateValue(rawValue, dateValue) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "FirstDetectedAt is not a valid persisted date value.", _
            variableName)
        Exit Function
    End If

    Set result = GetRequiredDiffValue( _
        item, _
        KEY_LAST_DETECTED_AT, _
        rawValue, _
        variableName)

    If Not result.Success Then
        Set ValidateDiffItem = result
        Exit Function
    End If

    If Not TryGetDateValue(rawValue, dateValue) Then
        Set ValidateDiffItem = CreateFailureResult( _
            "UnexpectedError", _
            "LastDetectedAt is not a valid persisted date value.", _
            variableName)
        Exit Function
    End If

    Set ValidateDiffItem = CreateSuccessResult()

End Function

Private Function GetRequiredDiffValue( _
    ByVal item As Object, _
    ByVal keyName As String, _
    ByRef value As Variant, _
    ByVal target As String _
) As COperationResult

    Dim exists As Boolean

    On Error GoTo InvalidStructure

    exists = item.Exists(keyName)

    If Not exists Then
        Set GetRequiredDiffValue = CreateFailureResult( _
            "UnexpectedError", _
            "Required SyncDiffResult item field was not found: " & keyName, _
            target)
        Exit Function
    End If

    value = item(keyName)

    Set GetRequiredDiffValue = CreateSuccessResult()
    Exit Function

InvalidStructure:
    Set GetRequiredDiffValue = CreateFailureResult( _
        "UnexpectedError", _
        "SyncDiffResult item is not a valid Dictionary.", _
        target)

End Function

Private Function ValidateCurrentState( _
    ByVal lo As ListObject, _
    ByVal syncDiffResult As Object, _
    ByVal rowMap As Object _
) As COperationResult

    Dim result As COperationResult

    Set result = ValidateCurrentStateCollection( _
        lo, syncDiffResult, SYNC_NEW, rowMap)
    If Not result.Success Then
        Set ValidateCurrentState = result
        Exit Function
    End If

    Set result = ValidateCurrentStateCollection( _
        lo, syncDiffResult, SYNC_EXISTING, rowMap)
    If Not result.Success Then
        Set ValidateCurrentState = result
        Exit Function
    End If

    Set result = ValidateCurrentStateCollection( _
        lo, syncDiffResult, SYNC_REACTIVATED, rowMap)
    If Not result.Success Then
        Set ValidateCurrentState = result
        Exit Function
    End If

    Set result = ValidateCurrentStateCollection( _
        lo, syncDiffResult, SYNC_UNUSED, rowMap)
    If Not result.Success Then
        Set ValidateCurrentState = result
        Exit Function
    End If

    Set ValidateCurrentState = CreateSuccessResult()

End Function

Private Function ValidateCurrentStateCollection( _
    ByVal lo As ListObject, _
    ByVal syncDiffResult As Object, _
    ByVal classification As String, _
    ByVal rowMap As Object _
) As COperationResult

    Dim items As Collection
    Dim item As Object
    Dim result As COperationResult
    Dim variableNameValue As Variant
    Dim tableVariableNameValue As Variant
    Dim variableName As String
    Dim rowIndex As Long

    Set result = GetSyncCollection(syncDiffResult, classification, items)
    If Not result.Success Then
        Set ValidateCurrentStateCollection = result
        Exit Function
    End If

    For Each item In items

        Set result = GetRequiredDiffValue( _
            item, _
            KEY_VARIABLE_NAME, _
            variableNameValue, _
            classification)

        If Not result.Success Then
            Set ValidateCurrentStateCollection = result
            Exit Function
        End If

        variableName = CStr(variableNameValue)

        If StrComp(classification, SYNC_NEW, vbBinaryCompare) = 0 Then

            If rowMap.Exists(variableName) Then
                Set ValidateCurrentStateCollection = CreateFailureResult( _
                    "UnexpectedError", _
                    "New SyncDiffResult item already exists in tblVariableDefinition.", _
                    variableName)
                Exit Function
            End If

        Else

            If Not rowMap.Exists(variableName) Then
                Set ValidateCurrentStateCollection = CreateFailureResult( _
                    "UnexpectedError", _
                    "Existing SyncDiffResult item was not found in tblVariableDefinition.", _
                    variableName)
                Exit Function
            End If

            rowIndex = CLng(rowMap(variableName))

            Set result = ReadCellValue( _
                lo, _
                KEY_VARIABLE_NAME, _
                rowIndex, _
                tableVariableNameValue)

            If Not result.Success Then
                Set ValidateCurrentStateCollection = result
                Exit Function
            End If

            If IsNull(tableVariableNameValue) Or _
               StrComp( _
                    CStr(tableVariableNameValue), _
                    variableName, _
                    vbBinaryCompare) <> 0 Then

                Set ValidateCurrentStateCollection = CreateFailureResult( _
                    "UnexpectedError", _
                    "Canonical VariableName does not match the current table value.", _
                    variableName)
                Exit Function

            End If

        End If

    Next item

    Set ValidateCurrentStateCollection = CreateSuccessResult()

End Function

Private Function IsValidVariableName( _
    ByVal variableName As String _
) As Boolean

    Dim re As Object

    Set re = CreateObject("VBScript.RegExp")
    re.Global = False
    re.IgnoreCase = False
    re.Pattern = VARIABLE_NAME_PATTERN

    IsValidVariableName = re.Test(variableName)

End Function

Private Function TryGetDateValue( _
    ByVal rawValue As Variant, _
    ByRef dateValue As Date _
) As Boolean

    TryGetDateValue = False

    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then
        Exit Function
    End If

    Select Case VarType(rawValue)

        Case vbDate, vbByte, vbInteger, vbLong, vbSingle, vbDouble, vbCurrency, vbDecimal

            On Error GoTo InvalidDate
            dateValue = CDate(rawValue)
            On Error GoTo 0

            TryGetDateValue = True
            Exit Function

        Case Else
            Exit Function

    End Select

InvalidDate:
    On Error GoTo 0
    TryGetDateValue = False

End Function

Private Sub ApplyExistingCollection( _
    ByVal lo As ListObject, _
    ByVal items As Collection, _
    ByVal rowMap As Object _
)

    Dim item As Object
    Dim variableName As String
    Dim rowIndex As Long

    For Each item In items

        variableName = CStr(item(KEY_VARIABLE_NAME))
        rowIndex = CLng(rowMap(variableName))

        WriteExistingMetadata lo, rowIndex, item

    Next item

End Sub

Private Sub WriteExistingMetadata( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal item As Object _
)

    lo.ListColumns(KEY_TEMPLATE_LOCATION).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        item(KEY_TEMPLATE_LOCATION)

    lo.ListColumns(KEY_STATUS).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        item(KEY_STATUS)

    lo.ListColumns(KEY_FIRST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        CDate(item(KEY_FIRST_DETECTED_AT))

    lo.ListColumns(KEY_LAST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        CDate(item(KEY_LAST_DETECTED_AT))

End Sub

Private Sub AppendNewItems( _
    ByVal lo As ListObject, _
    ByVal items As Collection _
)

    Dim item As Object
    Dim newRow As ListRow

    For Each item In items

        Set newRow = lo.ListRows.Add
        WriteNewRow lo, newRow.Index, item

    Next item

End Sub

Private Sub WriteNewRow( _
    ByVal lo As ListObject, _
    ByVal rowIndex As Long, _
    ByVal item As Object _
)

    lo.ListColumns(KEY_VARIABLE_NAME).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        item(KEY_VARIABLE_NAME)

    lo.ListColumns(KEY_DISPLAY_NAME).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_TYPE).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_REQUIRED).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_DESCRIPTION).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_OPTION_SOURCE).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_SORT_ORDER).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_FORMAT).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        vbNullString

    lo.ListColumns(KEY_TEMPLATE_LOCATION).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        item(KEY_TEMPLATE_LOCATION)

    lo.ListColumns(KEY_STATUS).DataBodyRange.Cells(rowIndex, 1).Value2 = _
        item(KEY_STATUS)

    lo.ListColumns(KEY_FIRST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        CDate(item(KEY_FIRST_DETECTED_AT))

    lo.ListColumns(KEY_LAST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = _
        CDate(item(KEY_LAST_DETECTED_AT))

End Sub
