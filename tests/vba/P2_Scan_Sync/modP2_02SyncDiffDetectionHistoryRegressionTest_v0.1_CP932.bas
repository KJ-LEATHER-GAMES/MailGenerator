Attribute VB_Name = "modP2_02SyncDiffDetectionHistoryRegressionTest"
Option Explicit

' P2-02 Sync Diff Core
' BL-MVP-004 / IF-P2-04-001 Detection History Regression
'
' This module adds only the BL-MVP-004 delta coverage.
' Keep and rerun the existing Bootstrap/Core/Negative/Compatibility tests.
'
' Entry point:
'   TestP202SyncDiffDetectionHistoryRegression

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

Public Sub TestP202SyncDiffDetectionHistoryRegression()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(76, "=")
    Debug.Print "P2-02 Sync Diff Core - BL-MVP-004 Detection History Regression"
    Debug.Print "IF-P2-04-001"
    Debug.Print String$(76, "=")

    RunR09ExistingUninitializedWithLocation passCount, failCount
    RunR10ReactivatedUninitializedWithLocation passCount, failCount
    RunR11UnusedUninitializedWithLocation passCount, failCount
    RunR12AlreadyUnusedUninitializedWithLocation passCount, failCount

    RunR13PartialExisting_FirstBlankLastDate passCount, failCount
    RunR14PartialUnused_FirstDateLastBlank passCount, failCount
    RunR15InvalidExisting_FirstNonDate passCount, failCount
    RunR16InvalidUnused_LastNonDate passCount, failCount

    RunR17PartialReactivated_FirstBlankLastDate passCount, failCount
    RunR18PartialAlreadyUnused_FirstDateLastBlank passCount, failCount

    RunR19InvalidTemplateLocation_UninitializedHistory passCount, failCount

    Debug.Print String$(76, "-")
    Debug.Print "PASS Count = " & CStr(passCount)
    Debug.Print "FAIL Count = " & CStr(failCount)

    If passCount = 43 And failCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print String$(76, "=")

End Sub

Private Sub RunR09ExistingUninitializedWithLocation( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim definition As Object
    Dim result As COperationResult
    Dim diff As Object
    Dim item As Object
    Dim syncTimestamp As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 9, 9)

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_BODY))

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        LOCATION_SUBJECT, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff(scanResult, definitions, syncTimestamp, diff)

    RecordResult ResultSucceeded(result), _
        "R09-01 Existing uninitialized / Location present returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_EXISTING).Count = 1, _
            "R09-02 Existing.Count = 1", passCount, failCount

        If diff(KEY_EXISTING).Count = 1 Then
            Set item = diff(KEY_EXISTING)(1)

            RecordResult CStr(item(FIELD_STATUS)) = STATUS_ACTIVE, _
                "R09-03 Status = Active", passCount, failCount
            RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_BODY, _
                "R09-04 TemplateLocation = Current", passCount, failCount
            RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), syncTimestamp), _
                "R09-05 FirstDetectedAt = SyncTimestamp", passCount, failCount
            RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), syncTimestamp), _
                "R09-06 LastDetectedAt = SyncTimestamp", passCount, failCount
        End If
    Else
        RecordResult False, _
            "R09-02 SyncDiffResult published", passCount, failCount
    End If

    RecordResult CStr(definition(FIELD_TEMPLATE_LOCATION)) = LOCATION_SUBJECT, _
        "R09-07 Input TemplateLocation remains unchanged", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_FIRST_DETECTED_AT)), _
        "R09-08 Input FirstDetectedAt remains Empty", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_LAST_DETECTED_AT)), _
        "R09-09 Input LastDetectedAt remains Empty", passCount, failCount

End Sub

Private Sub RunR10ReactivatedUninitializedWithLocation( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim definition As Object
    Dim result As COperationResult
    Dim diff As Object
    Dim item As Object
    Dim syncTimestamp As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 10, 10)

    Set scanResult = MakeScanResult( _
        Array("Department"), _
        Array(LOCATION_SUBJECT))

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "Department", _
        STATUS_UNUSED, _
        LOCATION_BODY, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff(scanResult, definitions, syncTimestamp, diff)

    RecordResult ResultSucceeded(result), _
        "R10-01 Reactivated uninitialized / Location present returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_REACTIVATED).Count = 1, _
            "R10-02 Reactivated.Count = 1", passCount, failCount

        If diff(KEY_REACTIVATED).Count = 1 Then
            Set item = diff(KEY_REACTIVATED)(1)

            RecordResult CStr(item(FIELD_STATUS)) = STATUS_ACTIVE, _
                "R10-03 Status = Active", passCount, failCount
            RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_SUBJECT, _
                "R10-04 TemplateLocation = Current", passCount, failCount
            RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), syncTimestamp), _
                "R10-05 FirstDetectedAt = SyncTimestamp", passCount, failCount
            RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), syncTimestamp), _
                "R10-06 LastDetectedAt = SyncTimestamp", passCount, failCount
        End If
    Else
        RecordResult False, _
            "R10-02 SyncDiffResult published", passCount, failCount
    End If

    RecordResult CStr(definition(FIELD_TEMPLATE_LOCATION)) = LOCATION_BODY, _
        "R10-07 Input TemplateLocation remains unchanged", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_FIRST_DETECTED_AT)), _
        "R10-08 Input FirstDetectedAt remains Empty", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_LAST_DETECTED_AT)), _
        "R10-09 Input LastDetectedAt remains Empty", passCount, failCount

End Sub

Private Sub RunR11UnusedUninitializedWithLocation( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim item As Object
    Dim syncTimestamp As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 11, 11)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "OldVariable", _
        STATUS_ACTIVE, _
        LOCATION_BOTH, _
        Empty, _
        Empty)

    Set result = BuildSyncDiff(scanResult, definitions, syncTimestamp, diff)

    RecordResult ResultSucceeded(result), _
        "R11-01 Unused uninitialized / Location present returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_UNUSED).Count = 1, _
            "R11-02 Unused.Count = 1", passCount, failCount

        If diff(KEY_UNUSED).Count = 1 Then
            Set item = diff(KEY_UNUSED)(1)

            RecordResult CStr(item(FIELD_STATUS)) = STATUS_UNUSED, _
                "R11-03 Status = Unused", passCount, failCount
            RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_BOTH, _
                "R11-04 TemplateLocation preserved", passCount, failCount
            RecordResult IsEmpty(item(FIELD_FIRST_DETECTED_AT)), _
                "R11-05 FirstDetectedAt remains Empty", passCount, failCount
            RecordResult IsEmpty(item(FIELD_LAST_DETECTED_AT)), _
                "R11-06 LastDetectedAt remains Empty", passCount, failCount
        End If
    Else
        RecordResult False, _
            "R11-02 SyncDiffResult published", passCount, failCount
    End If

End Sub

Private Sub RunR12AlreadyUnusedUninitializedWithLocation( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim definition As Object
    Dim result As COperationResult
    Dim diff As Object
    Dim syncTimestamp As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 12, 12)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "Legacy", _
        STATUS_UNUSED, _
        LOCATION_BODY, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff(scanResult, definitions, syncTimestamp, diff)

    RecordResult ResultSucceeded(result), _
        "R12-01 Already-Unused uninitialized / Location present returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult TotalDiffCount(diff) = 0, _
            "R12-02 Already-Unused remains no-op", passCount, failCount
    Else
        RecordResult False, _
            "R12-02 SyncDiffResult published", passCount, failCount
    End If

    RecordResult CStr(definition(FIELD_TEMPLATE_LOCATION)) = LOCATION_BODY, _
        "R12-03 Input TemplateLocation remains unchanged", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_FIRST_DETECTED_AT)), _
        "R12-04 Input FirstDetectedAt remains Empty", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_LAST_DETECTED_AT)), _
        "R12-05 Input LastDetectedAt remains Empty", passCount, failCount

End Sub

Private Sub RunR13PartialExisting_FirstBlankLastDate( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldLast As Date

    oldLast = DateSerial(2026, 9, 10)

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_BODY))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        LOCATION_SUBJECT, _
        Empty, _
        oldLast)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(13), diff)

    RecordFailurePair result, diff, _
        "R13 First Blank / Last Date / Existing", passCount, failCount

End Sub

Private Sub RunR14PartialUnused_FirstDateLastBlank( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldFirst As Date

    oldFirst = DateSerial(2026, 9, 11)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "OldVariable", _
        STATUS_ACTIVE, _
        LOCATION_BOTH, _
        oldFirst, _
        Empty)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(14), diff)

    RecordFailurePair result, diff, _
        "R14 First Date / Last Blank / Unused", passCount, failCount

End Sub

Private Sub RunR15InvalidExisting_FirstNonDate( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldLast As Date

    oldLast = DateSerial(2026, 9, 12)

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_SUBJECT))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        LOCATION_SUBJECT, _
        "invalid-date", _
        oldLast)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(15), diff)

    RecordFailurePair result, diff, _
        "R15 Invalid FirstDetectedAt / Existing", passCount, failCount

End Sub

Private Sub RunR16InvalidUnused_LastNonDate( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldFirst As Date

    oldFirst = DateSerial(2026, 9, 13)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "OldVariable", _
        STATUS_ACTIVE, _
        LOCATION_BODY, _
        oldFirst, _
        "invalid-date")

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(16), diff)

    RecordFailurePair result, diff, _
        "R16 Invalid LastDetectedAt / Unused", passCount, failCount

End Sub

Private Sub RunR17PartialReactivated_FirstBlankLastDate( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldLast As Date

    oldLast = DateSerial(2026, 9, 14)

    Set scanResult = MakeScanResult( _
        Array("Department"), _
        Array(LOCATION_BOTH))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "Department", _
        STATUS_UNUSED, _
        LOCATION_BODY, _
        Empty, _
        oldLast)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(17), diff)

    RecordFailurePair result, diff, _
        "R17 First Blank / Last Date / Reactivated", passCount, failCount

End Sub

Private Sub RunR18PartialAlreadyUnused_FirstDateLastBlank( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldFirst As Date

    oldFirst = DateSerial(2026, 9, 15)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "Legacy", _
        STATUS_UNUSED, _
        LOCATION_BODY, _
        oldFirst, _
        Empty)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(18), diff)

    RecordFailurePair result, diff, _
        "R18 First Date / Last Blank / Already-Unused", passCount, failCount

End Sub

Private Sub RunR19InvalidTemplateLocation_UninitializedHistory( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_SUBJECT))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        "InvalidLocation", _
        Empty, _
        Empty)

    Set result = BuildSyncDiff(scanResult, definitions, TestTimestamp(19), diff)

    RecordFailurePair result, diff, _
        "R19 Invalid non-blank TemplateLocation remains invalid", passCount, failCount

End Sub

Private Sub RecordFailurePair( _
    ByVal result As COperationResult, _
    ByVal diff As Object, _
    ByVal label As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    RecordResult ResultFailed(result), _
        label & " returns Failure", passCount, failCount
    RecordResult diff Is Nothing, _
        label & " does not publish SyncDiffResult", passCount, failCount

End Sub

Private Function MakeScanResult( _
    ByVal variableNames As Variant, _
    ByVal locations As Variant _
) As Object

    Dim result As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locationMap As Object
    Dim i As Long

    Set result = CreateObject("Scripting.Dictionary")
    result.CompareMode = vbTextCompare

    Set validVariables = New Collection
    Set invalidCandidates = New Collection

    Set locationMap = CreateObject("Scripting.Dictionary")
    locationMap.CompareMode = vbTextCompare

    If ArrayLength(variableNames) > 0 Then
        For i = LBound(variableNames) To UBound(variableNames)
            validVariables.Add CStr(variableNames(i))
            locationMap.Add CStr(variableNames(i)), CStr(locations(i))
        Next i
    End If

    result.Add KEY_VALID_VARIABLES, validVariables
    result.Add KEY_INVALID_CANDIDATES, invalidCandidates
    result.Add KEY_LOCATIONS, locationMap

    Set MakeScanResult = result

End Function

Private Function MakeDefinition( _
    ByVal variableName As String, _
    ByVal statusValue As String, _
    ByVal templateLocation As Variant, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
) As Object

    Dim definition As Object

    Set definition = CreateObject("Scripting.Dictionary")
    definition.CompareMode = vbTextCompare

    definition.Add FIELD_VARIABLE_NAME, variableName
    definition.Add FIELD_STATUS, statusValue
    definition.Add FIELD_TEMPLATE_LOCATION, templateLocation
    definition.Add FIELD_FIRST_DETECTED_AT, firstDetectedAt
    definition.Add FIELD_LAST_DETECTED_AT, lastDetectedAt

    Set MakeDefinition = definition

End Function

Private Function ArrayLength( _
    ByVal values As Variant _
) As Long

    On Error GoTo EmptyArray

    ArrayLength = UBound(values) - LBound(values) + 1
    Exit Function

EmptyArray:
    ArrayLength = 0

End Function

Private Function TotalDiffCount( _
    ByVal diff As Object _
) As Long

    TotalDiffCount = _
        diff(KEY_NEW).Count + _
        diff(KEY_EXISTING).Count + _
        diff(KEY_REACTIVATED).Count + _
        diff(KEY_UNUSED).Count

End Function

Private Function SameDate( _
    ByVal actualValue As Variant, _
    ByVal expectedValue As Date _
) As Boolean

    On Error GoTo InvalidValue

    If IsEmpty(actualValue) Or IsNull(actualValue) Or IsError(actualValue) Then
        Exit Function
    End If

    SameDate = (CDbl(CDate(actualValue)) = CDbl(expectedValue))
    Exit Function

InvalidValue:
    SameDate = False

End Function

Private Function ResultSucceeded( _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then Exit Function
    ResultSucceeded = result.Success

End Function

Private Function ResultFailed( _
    ByVal result As COperationResult _
) As Boolean

    If result Is Nothing Then Exit Function
    ResultFailed = Not result.Success

End Function

Private Function TestTimestamp( _
    ByVal secondsValue As Long _
) As Date

    TestTimestamp = _
        DateSerial(2026, 10, 1) + _
        TimeSerial(12, 20, secondsValue)

End Function

Private Sub RecordResult( _
    ByVal passed As Boolean, _
    ByVal testName As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    If passed Then
        passCount = passCount + 1
        Debug.Print "PASS  " & testName
    Else
        failCount = failCount + 1
        Debug.Print "FAIL  " & testName
    End If

End Sub
