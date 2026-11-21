Attribute VB_Name = "modConfigurationValidator"
Option Explicit

' P3-01 WORKING CANDIDATE, NOT APPROVED AND NOT COMPILED.
' Input snapshots are supplied by an Application layer; this module is read-only.
' Do not call ExecuteManualSync, Excel tables, Outlook, or UserForm here.

Private Const ERROR_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_UNEXPECTED As String = "UnexpectedError"

Private Const KEY_VALID As String = "ValidVariables"
Private Const KEY_INVALID As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"
Private Const KEY_NAME As String = "VariableName"
Private Const KEY_STATUS As String = "Status"
Private Const KEY_DISPLAY As String = "DisplayName"
Private Const KEY_TYPE As String = "Type"
Private Const KEY_REQUIRED As String = "Required"
Private Const KEY_SORT As String = "SortOrder"
Private Const KEY_FORMAT As String = "Format"
Private Const KEY_SOURCE As String = "OptionSource"

' One public entry; all parameters are existing lightweight VBA carriers.
' activeOptionsByGroup: Dictionary(OptionGroup -> Collection from GetActiveOptions).
' Dictionary keys are compared with vbBinaryCompare for OptionGroup identity.
Public Function ValidateConfiguration( _
    ByVal templateExists As Boolean, _
    ByVal templateScanResult As Object, _
    ByVal allVariableDefinitions As Collection, _
    ByVal activeOptionsByGroup As Object _
) As COperationResult

    Dim validNames As Collection
    Dim invalidNames As Collection
    Dim locations As Object
    Dim templateNames As Object
    Dim activeDefinitions As Object
    Dim result As COperationResult
    Dim nameValue As Variant
    Dim rowValue As Variant
    Dim item As Object
    Dim variableName As String

    On Error GoTo UnexpectedFailure

    If Not templateExists Then
        Set ValidateConfiguration = Failure( _
            "Current OFT does not exist. Check TemplatePath.", "TemplatePath")
        Exit Function
    End If

    If templateScanResult Is Nothing Then
        Set ValidateConfiguration = BrokenCarrier("TemplateScanResult")
        Exit Function
    End If

    If allVariableDefinitions Is Nothing Then
        Set ValidateConfiguration = BrokenCarrier("VariableDefinitions")
        Exit Function
    End If

    If activeOptionsByGroup Is Nothing Then
        Set ValidateConfiguration = BrokenCarrier("ActiveOptionsByGroup")
        Exit Function
    End If

    If TypeName(activeOptionsByGroup) <> "Dictionary" Then
        Set ValidateConfiguration = BrokenCarrier("ActiveOptionsByGroup")
        Exit Function
    End If

    Set result = ReadScanSnapshot( _
        templateScanResult, validNames, invalidNames, locations)
    If Not result.Success Then
        Set ValidateConfiguration = result
        Exit Function
    End If

    If invalidNames.Count > 0 Then
        Set ValidateConfiguration = Failure( _
            "Current OFT contains an invalid variable candidate. Review the template.", _
            "TemplateScanResult.InvalidCandidates")
        Exit Function
    End If

    Set result = BuildTemplateNameSet(validNames, locations, templateNames)
    If Not result.Success Then
        Set ValidateConfiguration = result
        Exit Function
    End If

    Set result = BuildActiveDefinitionMap( _
        allVariableDefinitions, activeDefinitions)
    If Not result.Success Then
        Set ValidateConfiguration = result
        Exit Function
    End If

    ' Current template must not contain a missing or Unused definition.
    For Each nameValue In templateNames.Keys
        variableName = CStr(nameValue)
        If Not activeDefinitions.Exists(variableName) Then
            Set ValidateConfiguration = Failure( _
                "Template variable is not registered as Active. Run manual sync and review the settings.", _
                variableName)
            Exit Function
        End If
    Next nameValue

    ' An Active definition must also exist in the current template.
    For Each nameValue In activeDefinitions.Keys
        variableName = CStr(nameValue)
        If Not templateNames.Exists(variableName) Then
            Set ValidateConfiguration = Failure( _
                "Active variable is absent from the current template. Run manual sync and review the settings.", _
                variableName)
            Exit Function
        End If
    Next nameValue

    ' Follow source row order for deterministic first-error selection.
    For Each rowValue In allVariableDefinitions
        If Not IsObject(rowValue) Then
            Set ValidateConfiguration = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If
        Set item = rowValue
        If item Is Nothing Then
            Set ValidateConfiguration = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If
        If TypeName(item) <> "Dictionary" Then
            Set ValidateConfiguration = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If

        If StrComp(CStr(item(KEY_STATUS)), "Active", vbTextCompare) = 0 Then
            Set result = ValidateActiveDefinition(item, activeOptionsByGroup)
            If Not result.Success Then
                Set ValidateConfiguration = result
                Exit Function
            End If
        End If
    Next rowValue

    Set ValidateConfiguration = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    Set ValidateConfiguration = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Configuration validation could not read the supplied snapshot.", _
        "ConfigurationValidator")
End Function

Private Function ReadScanSnapshot( _
    ByVal snapshot As Object, _
    ByRef validNames As Collection, _
    ByRef invalidNames As Collection, _
    ByRef locations As Object _
) As COperationResult

    Set validNames = Nothing
    Set invalidNames = Nothing
    Set locations = Nothing

    If TypeName(snapshot) <> "Dictionary" Then
        Set ReadScanSnapshot = BrokenCarrier("TemplateScanResult")
        Exit Function
    End If

    If Not snapshot.Exists(KEY_VALID) Or _
       Not snapshot.Exists(KEY_INVALID) Or _
       Not snapshot.Exists(KEY_LOCATIONS) Then
        Set ReadScanSnapshot = BrokenCarrier("TemplateScanResult.Keys")
        Exit Function
    End If

    ' A malformed object payload is caught by the public entry error guard.
    Set validNames = snapshot(KEY_VALID)
    Set invalidNames = snapshot(KEY_INVALID)
    Set locations = snapshot(KEY_LOCATIONS)

    If validNames Is Nothing Or invalidNames Is Nothing Or locations Is Nothing Then
        Set ReadScanSnapshot = BrokenCarrier("TemplateScanResult.Values")
        Exit Function
    End If

    If TypeName(validNames) <> "Collection" Or _
       TypeName(invalidNames) <> "Collection" Or _
       TypeName(locations) <> "Dictionary" Then
        Set ReadScanSnapshot = BrokenCarrier("TemplateScanResult.Types")
        Exit Function
    End If

    Set ReadScanSnapshot = CreateSuccessResult()
End Function

Private Function BuildTemplateNameSet( _
    ByVal validNames As Collection, _
    ByVal locations As Object, _
    ByRef templateNames As Object _
) As COperationResult

    Dim nameValue As Variant
    Dim variableName As String
    Dim locationValue As Variant

    Set templateNames = CreateObject("Scripting.Dictionary")
    templateNames.CompareMode = vbTextCompare

    For Each nameValue In validNames
        If Not TryGetNonblankText(nameValue, variableName) Then
            Set BuildTemplateNameSet = BrokenCarrier("TemplateScanResult.ValidVariables")
            Exit Function
        End If

        If templateNames.Exists(variableName) Then
            Set BuildTemplateNameSet = BrokenCarrier("TemplateScanResult.DuplicateVariable")
            Exit Function
        End If

        If Not locations.Exists(variableName) Then
            Set BuildTemplateNameSet = BrokenCarrier("TemplateScanResult.Locations")
            Exit Function
        End If

        locationValue = locations(variableName)
        If Not IsValidLocation(locationValue) Then
            Set BuildTemplateNameSet = BrokenCarrier("TemplateScanResult.Locations")
            Exit Function
        End If

        templateNames.Add variableName, True
    Next nameValue

    If locations.Count <> templateNames.Count Then
        Set BuildTemplateNameSet = BrokenCarrier("TemplateScanResult.Locations")
        Exit Function
    End If

    Set BuildTemplateNameSet = CreateSuccessResult()
End Function

Private Function BuildActiveDefinitionMap( _
    ByVal definitions As Collection, _
    ByRef activeDefinitions As Object _
) As COperationResult

    Dim seenNames As Object
    Dim rowValue As Variant
    Dim item As Object
    Dim variableName As String
    Dim statusText As String

    Set seenNames = CreateObject("Scripting.Dictionary")
    seenNames.CompareMode = vbTextCompare

    Set activeDefinitions = CreateObject("Scripting.Dictionary")
    activeDefinitions.CompareMode = vbTextCompare

    For Each rowValue In definitions
        If Not IsObject(rowValue) Then
            Set BuildActiveDefinitionMap = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If
        Set item = rowValue
        If item Is Nothing Then
            Set BuildActiveDefinitionMap = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If
        If TypeName(item) <> "Dictionary" Then
            Set BuildActiveDefinitionMap = BrokenCarrier("VariableDefinitions.Row")
            Exit Function
        End If
        If Not item.Exists(KEY_NAME) Or Not item.Exists(KEY_STATUS) Then
            Set BuildActiveDefinitionMap = BrokenCarrier("VariableDefinitions.Identity")
            Exit Function
        End If
        If Not TryGetNonblankText(item(KEY_NAME), variableName) Then
            Set BuildActiveDefinitionMap = Failure( _
                "VariableName is blank or invalid.", "VariableName")
            Exit Function
        End If
        If Not TryGetNonblankText(item(KEY_STATUS), statusText) Then
            Set BuildActiveDefinitionMap = Failure( _
                "Status is blank or invalid.", variableName & ".Status")
            Exit Function
        End If
        If seenNames.Exists(variableName) Then
            Set BuildActiveDefinitionMap = Failure( _
                "VariableName is duplicated in VariableDefinition.", variableName)
            Exit Function
        End If
        seenNames.Add variableName, True

        If StrComp(statusText, "Active", vbTextCompare) = 0 Then
            activeDefinitions.Add variableName, item
        ElseIf StrComp(statusText, "Unused", vbTextCompare) <> 0 Then
            Set BuildActiveDefinitionMap = Failure( _
                "Status must be Active or Unused.", variableName & ".Status")
            Exit Function
        End If
    Next rowValue

    Set BuildActiveDefinitionMap = CreateSuccessResult()
End Function

Private Function ValidateActiveDefinition( _
    ByVal item As Object, _
    ByVal activeOptionsByGroup As Object _
) As COperationResult

    Dim nameText As String
    Dim textValue As String
    Dim typeText As String
    Dim optionGroup As String
    Dim rawValue As Variant
    Dim configured As Boolean
    Dim result As COperationResult

    nameText = CStr(item(KEY_NAME))

    If Not item.Exists(KEY_DISPLAY) Then
        Set ValidateActiveDefinition = Failure("DisplayName is missing.", nameText & ".DisplayName")
        Exit Function
    End If
    If Not TryGetNonblankText(item(KEY_DISPLAY), textValue) Then
        Set ValidateActiveDefinition = Failure("DisplayName is not configured.", nameText & ".DisplayName")
        Exit Function
    End If

    If Not item.Exists(KEY_TYPE) Then
        Set ValidateActiveDefinition = Failure("Type is missing.", nameText & ".Type")
        Exit Function
    End If
    If Not TryGetNonblankText(item(KEY_TYPE), typeText) Then
        Set ValidateActiveDefinition = Failure("Type is not configured.", nameText & ".Type")
        Exit Function
    End If
    If typeText <> "Text" And typeText <> "Date" And typeText <> "Select" Then
        Set ValidateActiveDefinition = Failure("Type must be Text, Date, or Select.", nameText & ".Type")
        Exit Function
    End If

    If Not item.Exists(KEY_REQUIRED) Then
        Set ValidateActiveDefinition = Failure("Required is missing.", nameText & ".Required")
        Exit Function
    End If
    rawValue = item(KEY_REQUIRED)
    If Not TryGetBoolean(rawValue, configured) Then
        Set ValidateActiveDefinition = Failure("Required must be explicitly True or False.", nameText & ".Required")
        Exit Function
    End If

    If Not item.Exists(KEY_SORT) Then
        Set ValidateActiveDefinition = Failure("SortOrder is missing.", nameText & ".SortOrder")
        Exit Function
    End If
    rawValue = item(KEY_SORT)
    If Not IsValidSortOrder(rawValue) Then
        Set ValidateActiveDefinition = Failure("SortOrder must be a numeric value.", nameText & ".SortOrder")
        Exit Function
    End If

    If typeText = "Date" Then
        If Not item.Exists(KEY_FORMAT) Then
            Set ValidateActiveDefinition = Failure("Date Format is missing.", nameText & ".Format")
            Exit Function
        End If
        If Not IsApprovedDateFormat(item(KEY_FORMAT)) Then
            Set ValidateActiveDefinition = Failure("Date Format must match one of the six approved formats.", nameText & ".Format")
            Exit Function
        End If
    ElseIf typeText = "Select" Then
        If Not item.Exists(KEY_SOURCE) Then
            Set ValidateActiveDefinition = Failure("OptionSource is missing.", nameText & ".OptionSource")
            Exit Function
        End If
        If Not TryGetNonblankText(item(KEY_SOURCE), optionGroup) Then
            Set ValidateActiveDefinition = Failure("OptionSource is not configured.", nameText & ".OptionSource")
            Exit Function
        End If

        Set result = CheckActiveOptions(optionGroup, activeOptionsByGroup)
        If Not result.Success Then
            Set ValidateActiveDefinition = result
            Exit Function
        End If
    End If

    Set ValidateActiveDefinition = CreateSuccessResult()
End Function

Private Function CheckActiveOptions( _
    ByVal groupName As String, _
    ByVal groups As Object _
) As COperationResult

    Dim groupKey As Variant
    Dim exactKey As String
    Dim found As Boolean
    Dim options As Collection
    Dim optionValue As Variant
    Dim item As Object
    Dim activeValue As Boolean
    Dim optionGroup As String

    found = False
    For Each groupKey In groups.Keys
        exactKey = CStr(groupKey)
        If StrComp(exactKey, groupName, vbBinaryCompare) = 0 Then
            found = True
            Exit For
        End If
    Next groupKey

    If Not found Then
        Set CheckActiveOptions = Failure( _
            "Active options were not supplied for the OptionSource.", groupName)
        Exit Function
    End If

    Set options = groups(groupKey)
    If options Is Nothing Then
        Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
        Exit Function
    End If
    If TypeName(options) <> "Collection" Then
        Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
        Exit Function
    End If
    If options.Count = 0 Then
        Set CheckActiveOptions = Failure( _
            "OptionSource has no active options.", groupName)
        Exit Function
    End If

    ' Validate active-only snapshot semantics; no option sorting or lookup here.
    For Each optionValue In options
        If Not IsObject(optionValue) Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        Set item = optionValue
        If item Is Nothing Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If TypeName(item) <> "Dictionary" Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If Not item.Exists("OptionGroup") Or Not item.Exists("Active") Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If Not TryGetNonblankText(item("OptionGroup"), optionGroup) Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If StrComp(optionGroup, groupName, vbBinaryCompare) <> 0 Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If Not TryGetBoolean(item("Active"), activeValue) Then
            Set CheckActiveOptions = BrokenCarrier("ActiveOptionsByGroup." & groupName)
            Exit Function
        End If
        If Not activeValue Then
            Set CheckActiveOptions = Failure( _
                "OptionSource has no verified active option in the supplied snapshot.", groupName)
            Exit Function
        End If
    Next optionValue

    Set CheckActiveOptions = CreateSuccessResult()
End Function

Private Function TryGetNonblankText( _
    ByVal rawValue As Variant, _
    ByRef textValue As String _
) As Boolean

    textValue = vbNullString
    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Or IsArray(rawValue) Then Exit Function
    textValue = CStr(rawValue)
    TryGetNonblankText = (Len(Trim$(textValue)) > 0)
End Function

Private Function TryGetBoolean( _
    ByVal rawValue As Variant, _
    ByRef boolValue As Boolean _
) As Boolean

    Dim normalized As String

    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Or IsArray(rawValue) Then Exit Function

    Select Case VarType(rawValue)
        Case vbBoolean
            boolValue = CBool(rawValue)
            TryGetBoolean = True
        Case vbByte, vbInteger, vbLong, vbSingle, vbDouble, vbCurrency, vbDecimal
            If CDbl(rawValue) = 0 Then
                boolValue = False
                TryGetBoolean = True
            ElseIf CDbl(rawValue) = 1 Then
                boolValue = True
                TryGetBoolean = True
            End If
        Case vbString
            normalized = LCase$(Trim$(CStr(rawValue)))
            If normalized = "true" Then
                boolValue = True
                TryGetBoolean = True
            ElseIf normalized = "false" Then
                boolValue = False
                TryGetBoolean = True
            End If
    End Select
End Function

Private Function IsValidSortOrder(ByVal rawValue As Variant) As Boolean
    Dim sortKey As Double

    On Error GoTo InvalidValue
    If IsError(rawValue) Or IsNull(rawValue) Or IsEmpty(rawValue) Then Exit Function
    If IsObject(rawValue) Or IsArray(rawValue) Then Exit Function
    If VarType(rawValue) = vbBoolean Then Exit Function
    If Len(Trim$(CStr(rawValue))) = 0 Then Exit Function
    If Not IsNumeric(rawValue) Then Exit Function

    ' Match the P3-03 sortable numeric domain; prevent late CDbl failures.
    sortKey = CDbl(rawValue)
    IsValidSortOrder = True
    Exit Function
InvalidValue:
    IsValidSortOrder = False
End Function

Private Function IsApprovedDateFormat(ByVal rawValue As Variant) As Boolean
    Dim fmt As String
    If Not TryGetNonblankText(rawValue, fmt) Then Exit Function
    Select Case fmt
        Case "yyyy/mm/dd", "yyyy-mm-dd", "yyyy”NmŒŽd“ú", _
             "mŒŽd“ú", "yyyy”NmŒŽd“ú(aaa)", "mŒŽd“ú(aaa)"
            IsApprovedDateFormat = True
    End Select
End Function

Private Function IsValidLocation(ByVal rawValue As Variant) As Boolean
    Dim locationText As String
    If Not TryGetNonblankText(rawValue, locationText) Then Exit Function
    IsValidLocation = (locationText = "Subject" Or _
                       locationText = "Body" Or locationText = "Both")
End Function

Private Function Failure( _
    ByVal message As String, ByVal target As String _
) As COperationResult
    Set Failure = CreateFailureResult(ERROR_CONFIGURATION, message, target)
End Function

Private Function BrokenCarrier(ByVal target As String) As COperationResult
    Set BrokenCarrier = CreateFailureResult( _
        ERROR_UNEXPECTED, "Configuration snapshot is missing or malformed.", target)
End Function
