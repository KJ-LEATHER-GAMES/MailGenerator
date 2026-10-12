Attribute VB_Name = "modSyncEngine"
Option Explicit

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"
Private Const KEY_LOCATIONS As String = "Locations"

Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"
Private Const KEY_UNUSED As String = "Unused"

Private Const FIELD_VARIABLE_NAME As String = "VariableName"
Private Const FIELD_TEMPLATE_LOCATION As String = "TemplateLocation"
Private Const FIELD_STATUS As String = "Status"
Private Const FIELD_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const FIELD_LAST_DETECTED_AT As String = "LastDetectedAt"

Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"

Private Const LOCATION_SUBJECT As String = "Subject"
Private Const LOCATION_BODY As String = "Body"
Private Const LOCATION_BOTH As String = "Both"

Private Const TARGET_SYNC_ENGINE As String = "SyncEngine"
Private Const TARGET_VARIABLE_DEFINITION As String = "VariableDefinition"
Private Const TARGET_INVALID_CANDIDATES As String = "InvalidCandidates"

Public Function BuildSyncDiff( _
    ByVal templateScanResult As Object, _
    ByVal currentDefinitions As Collection, _
    ByVal syncTimestamp As Date, _
    ByRef syncDiffResult As Object _
) As COperationResult

    Dim result As COperationResult
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object
    Dim templateIndex As Object
    Dim currentIndex As Object
    Dim workingResult As Object
    Dim variableValue As Variant
    Dim variableName As String
    Dim currentLocation As String
    Dim currentDefinition As Object
    Dim diffItem As Object
    Dim i As Long

    Set syncDiffResult = Nothing

    On Error GoTo UnexpectedError

    Set result = ReadTemplateScanResult( _
        templateScanResult, _
        validVariables, _
        invalidCandidates, _
        locations)
    If Not result.Success Then
        Set BuildSyncDiff = result
        Exit Function
    End If

    If invalidCandidates.Count > 0 Then
        Set BuildSyncDiff = CreateFailureResult( _
            "ConfigurationError", _
            "TemplateScanResult contains invalid candidates.", _
            TARGET_INVALID_CANDIDATES)
        Exit Function
    End If

    Set result = BuildTemplateIndex( _
        validVariables, _
        locations, _
        templateIndex)
    If Not result.Success Then
        Set BuildSyncDiff = result
        Exit Function
    End If

    Set result = BuildCurrentIndex( _
        currentDefinitions, _
        currentIndex)
    If Not result.Success Then
        Set BuildSyncDiff = result
        Exit Function
    End If

    Set result = CreateSyncDiffResult(workingResult)
    If Not result.Success Then
        Set BuildSyncDiff = result
        Exit Function
    End If

    ' Pass A: variables currently present in the template.
    For Each variableValue In validVariables

        variableName = CStr(variableValue)
        currentLocation = CStr(templateIndex(variableName))

        If Not currentIndex.Exists(variableName) Then

            Set result = CreateDiffItem( _
                variableName, _
                currentLocation, _
                STATUS_ACTIVE, _
                syncTimestamp, _
                syncTimestamp, _
                diffItem)
            If Not result.Success Then GoTo ReturnFailure

            workingResult(KEY_NEW).Add diffItem

        Else

            Set currentDefinition = currentIndex(variableName)

            If IsStatusActive(CStr(currentDefinition(FIELD_STATUS))) Then

                Set result = CreateDiffItem( _
                    CStr(currentDefinition(FIELD_VARIABLE_NAME)), _
                    currentLocation, _
                    STATUS_ACTIVE, _
                    currentDefinition(FIELD_FIRST_DETECTED_AT), _
                    syncTimestamp, _
                    diffItem)
                If Not result.Success Then GoTo ReturnFailure

                workingResult(KEY_EXISTING).Add diffItem

            ElseIf IsStatusUnused(CStr(currentDefinition(FIELD_STATUS))) Then

                Set result = CreateDiffItem( _
                    CStr(currentDefinition(FIELD_VARIABLE_NAME)), _
                    currentLocation, _
                    STATUS_ACTIVE, _
                    currentDefinition(FIELD_FIRST_DETECTED_AT), _
                    syncTimestamp, _
                    diffItem)
                If Not result.Success Then GoTo ReturnFailure

                workingResult(KEY_REACTIVATED).Add diffItem

            Else
                Set result = CreateFailureResult( _
                    "ConfigurationError", _
                    "VariableDefinition contains an unsupported Status.", _
                    FIELD_STATUS)
                GoTo ReturnFailure
            End If

        End If

    Next variableValue

    ' Pass B: definitions no longer present in the template.
    For i = 1 To currentDefinitions.Count

        Set currentDefinition = currentDefinitions(i)
        variableName = CStr(currentDefinition(FIELD_VARIABLE_NAME))

        If Not templateIndex.Exists(variableName) Then

            If IsStatusActive(CStr(currentDefinition(FIELD_STATUS))) Then

                Set result = CreateDiffItem( _
                    CStr(currentDefinition(FIELD_VARIABLE_NAME)), _
                    CStr(currentDefinition(FIELD_TEMPLATE_LOCATION)), _
                    STATUS_UNUSED, _
                    currentDefinition(FIELD_FIRST_DETECTED_AT), _
                    currentDefinition(FIELD_LAST_DETECTED_AT), _
                    diffItem)
                If Not result.Success Then GoTo ReturnFailure

                workingResult(KEY_UNUSED).Add diffItem

            ElseIf IsStatusUnused(CStr(currentDefinition(FIELD_STATUS))) Then
                ' Already-Unused: no-op.
            Else
                Set result = CreateFailureResult( _
                    "ConfigurationError", _
                    "VariableDefinition contains an unsupported Status.", _
                    FIELD_STATUS)
                GoTo ReturnFailure
            End If

        End If

    Next i

    Set syncDiffResult = workingResult
    Set BuildSyncDiff = CreateSuccessResult()
    Exit Function

ReturnFailure:
    Set syncDiffResult = Nothing
    Set BuildSyncDiff = result
    Exit Function

UnexpectedError:
    Set syncDiffResult = Nothing
    Set BuildSyncDiff = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to build sync diff: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function ReadTemplateScanResult( _
    ByVal templateScanResult As Object, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef locations As Object _
) As COperationResult

    On Error GoTo UnexpectedError

    Set validVariables = Nothing
    Set invalidCandidates = Nothing
    Set locations = Nothing

    If templateScanResult Is Nothing Then
        Set ReadTemplateScanResult = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateScanResult is Nothing.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    If Not templateScanResult.Exists(KEY_VALID_VARIABLES) Then
        Set ReadTemplateScanResult = MissingScanResultKey(KEY_VALID_VARIABLES)
        Exit Function
    End If

    If Not templateScanResult.Exists(KEY_INVALID_CANDIDATES) Then
        Set ReadTemplateScanResult = MissingScanResultKey(KEY_INVALID_CANDIDATES)
        Exit Function
    End If

    If Not templateScanResult.Exists(KEY_LOCATIONS) Then
        Set ReadTemplateScanResult = MissingScanResultKey(KEY_LOCATIONS)
        Exit Function
    End If

    Set validVariables = templateScanResult(KEY_VALID_VARIABLES)
    Set invalidCandidates = templateScanResult(KEY_INVALID_CANDIDATES)
    Set locations = templateScanResult(KEY_LOCATIONS)

    If validVariables Is Nothing Then
        Set ReadTemplateScanResult = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateScanResult.ValidVariables is Nothing.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    If invalidCandidates Is Nothing Then
        Set ReadTemplateScanResult = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateScanResult.InvalidCandidates is Nothing.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    If locations Is Nothing Then
        Set ReadTemplateScanResult = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateScanResult.Locations is Nothing.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    Set ReadTemplateScanResult = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set ReadTemplateScanResult = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to read TemplateScanResult: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function MissingScanResultKey( _
    ByVal keyName As String _
) As COperationResult

    Set MissingScanResultKey = CreateFailureResult( _
        "UnexpectedError", _
        "TemplateScanResult is missing required key: " & keyName, _
        TARGET_SYNC_ENGINE)

End Function

Private Function BuildTemplateIndex( _
    ByVal validVariables As Collection, _
    ByVal locations As Object, _
    ByRef templateIndex As Object _
) As COperationResult

    Dim variableValue As Variant
    Dim variableName As String
    Dim locationValue As String

    Set templateIndex = Nothing

    On Error GoTo UnexpectedError

    If locations.Count <> validVariables.Count Then
        Set BuildTemplateIndex = CreateFailureResult( _
            "UnexpectedError", _
            "TemplateScanResult structural invariant failed: " & _
                "Locations.Count differs from ValidVariables.Count.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    Set templateIndex = CreateObject("Scripting.Dictionary")
    templateIndex.CompareMode = vbTextCompare

    For Each variableValue In validVariables

        If IsNull(variableValue) Or IsEmpty(variableValue) Then
            Set templateIndex = Nothing
            Set BuildTemplateIndex = CreateFailureResult( _
                "UnexpectedError", _
                "TemplateScanResult contains an empty VariableName.", _
                TARGET_SYNC_ENGINE)
            Exit Function
        End If

        variableName = Trim$(CStr(variableValue))

        If Len(variableName) = 0 Then
            Set templateIndex = Nothing
            Set BuildTemplateIndex = CreateFailureResult( _
                "UnexpectedError", _
                "TemplateScanResult contains an empty VariableName.", _
                TARGET_SYNC_ENGINE)
            Exit Function
        End If

        If templateIndex.Exists(variableName) Then
            Set templateIndex = Nothing
            Set BuildTemplateIndex = CreateFailureResult( _
                "UnexpectedError", _
                "TemplateScanResult contains a case-insensitive duplicate VariableName.", _
                TARGET_SYNC_ENGINE)
            Exit Function
        End If

        If Not locations.Exists(variableName) Then
            Set templateIndex = Nothing
            Set BuildTemplateIndex = CreateFailureResult( _
                "UnexpectedError", _
                "TemplateScanResult is missing Location for VariableName: " & variableName, _
                TARGET_SYNC_ENGINE)
            Exit Function
        End If

        locationValue = CStr(locations(variableName))

        If Not IsValidLocation(locationValue) Then
            Set templateIndex = Nothing
            Set BuildTemplateIndex = CreateFailureResult( _
                "UnexpectedError", _
                "TemplateScanResult contains an unsupported Location.", _
                TARGET_SYNC_ENGINE)
            Exit Function
        End If

        templateIndex.Add variableName, locationValue

    Next variableValue

    Set BuildTemplateIndex = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set templateIndex = Nothing
    Set BuildTemplateIndex = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to build template index: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function BuildCurrentIndex( _
    ByVal currentDefinitions As Collection, _
    ByRef currentIndex As Object _
) As COperationResult

    Dim definition As Object
    Dim variableName As String
    Dim statusValue As String
    Dim result As COperationResult
    Dim i As Long

    Set currentIndex = Nothing

    On Error GoTo UnexpectedError

    If currentDefinitions Is Nothing Then
        Set BuildCurrentIndex = CreateFailureResult( _
            "UnexpectedError", _
            "Current VariableDefinitions is Nothing.", _
            TARGET_SYNC_ENGINE)
        Exit Function
    End If

    Set currentIndex = CreateObject("Scripting.Dictionary")
    currentIndex.CompareMode = vbTextCompare

    For i = 1 To currentDefinitions.Count

        Set definition = currentDefinitions(i)

        If definition Is Nothing Then
            Set currentIndex = Nothing
            Set BuildCurrentIndex = CreateFailureResult( _
                "ConfigurationError", _
                "VariableDefinition contains a Nothing item.", _
                TARGET_VARIABLE_DEFINITION)
            Exit Function
        End If

        Set result = ValidateCurrentDefinition(definition, variableName, statusValue)
        If Not result.Success Then
            Set currentIndex = Nothing
            Set BuildCurrentIndex = result
            Exit Function
        End If

        If currentIndex.Exists(variableName) Then
            Set currentIndex = Nothing
            Set BuildCurrentIndex = CreateFailureResult( _
                "ConfigurationError", _
                "VariableDefinition contains duplicate VariableName identities.", _
                TARGET_VARIABLE_DEFINITION)
            Exit Function
        End If

        currentIndex.Add variableName, definition

    Next i

    Set BuildCurrentIndex = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set currentIndex = Nothing
    Set BuildCurrentIndex = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to build VariableDefinition index: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function ValidateCurrentDefinition( _
    ByVal definition As Object, _
    ByRef variableName As String, _
    ByRef statusValue As String _
) As COperationResult

    Dim requiredFields As Variant
    Dim fieldName As Variant
    Dim rawVariableName As Variant
    Dim rawStatus As Variant

    On Error GoTo UnexpectedError

    variableName = vbNullString
    statusValue = vbNullString

    requiredFields = Array( _
        FIELD_VARIABLE_NAME, _
        FIELD_STATUS, _
        FIELD_TEMPLATE_LOCATION, _
        FIELD_FIRST_DETECTED_AT, _
        FIELD_LAST_DETECTED_AT)

    For Each fieldName In requiredFields
        If Not definition.Exists(CStr(fieldName)) Then
            Set ValidateCurrentDefinition = CreateFailureResult( _
                "ConfigurationError", _
                "VariableDefinition is missing required field: " & CStr(fieldName), _
                TARGET_VARIABLE_DEFINITION)
            Exit Function
        End If
    Next fieldName

    rawVariableName = definition(FIELD_VARIABLE_NAME)

    If IsNull(rawVariableName) Or IsEmpty(rawVariableName) Then
        Set ValidateCurrentDefinition = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition.VariableName is empty.", _
            TARGET_VARIABLE_DEFINITION)
        Exit Function
    End If

    variableName = Trim$(CStr(rawVariableName))

    If Len(variableName) = 0 Then
        Set ValidateCurrentDefinition = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition.VariableName is empty.", _
            TARGET_VARIABLE_DEFINITION)
        Exit Function
    End If

    rawStatus = definition(FIELD_STATUS)

    If IsNull(rawStatus) Or IsEmpty(rawStatus) Then
        Set ValidateCurrentDefinition = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition.Status is empty.", _
            TARGET_VARIABLE_DEFINITION)
        Exit Function
    End If

    statusValue = Trim$(CStr(rawStatus))

    If Not IsStatusActive(statusValue) And _
       Not IsStatusUnused(statusValue) Then

        Set ValidateCurrentDefinition = CreateFailureResult( _
            "ConfigurationError", _
            "VariableDefinition contains an unsupported Status.", _
            FIELD_STATUS)
        Exit Function
    End If

    Set ValidateCurrentDefinition = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set ValidateCurrentDefinition = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to validate VariableDefinition item: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function CreateSyncDiffResult( _
    ByRef syncDiffResult As Object _
) As COperationResult

    Dim newItems As Collection
    Dim existingItems As Collection
    Dim reactivatedItems As Collection
    Dim unusedItems As Collection

    Set syncDiffResult = Nothing

    On Error GoTo UnexpectedError

    Set syncDiffResult = CreateObject("Scripting.Dictionary")
    syncDiffResult.CompareMode = vbTextCompare

    Set newItems = New Collection
    Set existingItems = New Collection
    Set reactivatedItems = New Collection
    Set unusedItems = New Collection

    syncDiffResult.Add KEY_NEW, newItems
    syncDiffResult.Add KEY_EXISTING, existingItems
    syncDiffResult.Add KEY_REACTIVATED, reactivatedItems
    syncDiffResult.Add KEY_UNUSED, unusedItems

    Set CreateSyncDiffResult = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set syncDiffResult = Nothing
    Set CreateSyncDiffResult = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to create SyncDiffResult: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function CreateDiffItem( _
    ByVal variableName As String, _
    ByVal templateLocation As String, _
    ByVal statusValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant, _
    ByRef diffItem As Object _
) As COperationResult

    Set diffItem = Nothing

    On Error GoTo UnexpectedError

    Set diffItem = CreateObject("Scripting.Dictionary")
    diffItem.CompareMode = vbTextCompare

    diffItem.Add FIELD_VARIABLE_NAME, variableName
    diffItem.Add FIELD_TEMPLATE_LOCATION, templateLocation
    diffItem.Add FIELD_STATUS, statusValue
    diffItem.Add FIELD_FIRST_DETECTED_AT, firstDetectedAt
    diffItem.Add FIELD_LAST_DETECTED_AT, lastDetectedAt

    Set CreateDiffItem = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set diffItem = Nothing
    Set CreateDiffItem = CreateFailureResult( _
        "UnexpectedError", _
        "Unable to create sync diff item: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        TARGET_SYNC_ENGINE)

End Function

Private Function IsStatusActive( _
    ByVal statusValue As String _
) As Boolean

    IsStatusActive = _
        (StrComp(Trim$(statusValue), STATUS_ACTIVE, vbTextCompare) = 0)

End Function

Private Function IsStatusUnused( _
    ByVal statusValue As String _
) As Boolean

    IsStatusUnused = _
        (StrComp(Trim$(statusValue), STATUS_UNUSED, vbTextCompare) = 0)

End Function

Private Function IsValidLocation( _
    ByVal locationValue As String _
) As Boolean

    Select Case LCase$(Trim$(locationValue))
        Case LCase$(LOCATION_SUBJECT), _
             LCase$(LOCATION_BODY), _
             LCase$(LOCATION_BOTH)
            IsValidLocation = True

        Case Else
            IsValidLocation = False
    End Select

End Function
