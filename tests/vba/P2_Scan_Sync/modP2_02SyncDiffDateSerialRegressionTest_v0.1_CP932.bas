Attribute VB_Name = "modP2_02SyncDiffDateSerialRegressionTest"
Option Explicit

' P2-02 Sync Diff Core
' Excel .Value2 Date Serial Compatibility Regression
'
' Regression source:
'   P2-03 K1 Production Compatibility exposed that
'   GetAllVariableDefinitions returns Excel date cells as numeric serials.
'
' Entry point:
'   TestP202SyncDiffDateSerialRegression

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

Public Sub TestP202SyncDiffDateSerialRegression()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(76, "=")
    Debug.Print "P2-02 Sync Diff - Excel Date Serial Compatibility Regression"
    Debug.Print "BL-MVP-004"
    Debug.Print String$(76, "=")

    RunR20InitializedDateSerialPipeline passCount, failCount

    Debug.Print String$(76, "-")
    Debug.Print "PASS Count = " & CStr(passCount)
    Debug.Print "FAIL Count = " & CStr(failCount)

    If passCount = 9 And failCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print String$(76, "=")

End Sub

Private Sub RunR20InitializedDateSerialPipeline( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim syncTimestamp As Date
    Dim firstExisting As Date
    Dim lastExisting As Date
    Dim firstReactivated As Date
    Dim lastReactivated As Date
    Dim firstGone As Date
    Dim lastGone As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(15, 20, 0)

    firstExisting = DateSerial(2026, 7, 1)
    lastExisting = DateSerial(2026, 8, 20)

    firstReactivated = DateSerial(2026, 6, 1)
    lastReactivated = DateSerial(2026, 7, 10)

    firstGone = DateSerial(2026, 5, 1)
    lastGone = DateSerial(2026, 8, 15)

    Set scanResult = MakeScanResult( _
        Array("ExistingVar", "NewVar", "ReactivatedVar"), _
        Array(LOCATION_SUBJECT, LOCATION_SUBJECT, LOCATION_BODY))

    Set definitions = New Collection

    definitions.Add MakeDefinition( _
        "ExistingVar", _
        STATUS_ACTIVE, _
        LOCATION_BODY, _
        CDbl(firstExisting), _
        CDbl(lastExisting))

    definitions.Add MakeDefinition( _
        "ReactivatedVar", _
        STATUS_UNUSED, _
        LOCATION_SUBJECT, _
        CDbl(firstReactivated), _
        CDbl(lastReactivated))

    definitions.Add MakeDefinition( _
        "GoneVar", _
        STATUS_ACTIVE, _
        LOCATION_BOTH, _
        CDbl(firstGone), _
        CDbl(lastGone))

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult ResultSucceeded(result), _
        "R20-01 Numeric Excel Date Serial metadata returns Success", _
        passCount, failCount

    If diff Is Nothing Then
        RecordResult False, _
            "R20-02 SyncDiffResult published", passCount, failCount
        Exit Sub
    End If

    RecordResult diff(KEY_NEW).Count = 1, _
        "R20-02 New.Count = 1", passCount, failCount

    RecordResult diff(KEY_EXISTING).Count = 1, _
        "R20-03 Existing.Count = 1", passCount, failCount

    RecordResult diff(KEY_REACTIVATED).Count = 1, _
        "R20-04 Reactivated.Count = 1", passCount, failCount

    RecordResult diff(KEY_UNUSED).Count = 1, _
        "R20-05 Unused.Count = 1", passCount, failCount

    If diff(KEY_EXISTING).Count = 1 Then
        Set item = diff(KEY_EXISTING)(1)

        RecordResult SameDate( _
            item(FIELD_FIRST_DETECTED_AT), _
            firstExisting), _
            "R20-06 Existing FirstDetectedAt preserves Date Serial value", _
            passCount, failCount

        RecordResult SameDate( _
            item(FIELD_LAST_DETECTED_AT), _
            syncTimestamp), _
            "R20-07 Existing LastDetectedAt = SyncTimestamp", _
            passCount, failCount
    Else
        RecordResult False, _
            "R20-06 Existing item available", passCount, failCount
        RecordResult False, _
            "R20-07 Existing item available", passCount, failCount
    End If

    If diff(KEY_UNUSED).Count = 1 Then
        Set item = diff(KEY_UNUSED)(1)

        RecordResult SameDate( _
            item(FIELD_FIRST_DETECTED_AT), _
            firstGone), _
            "R20-08 Unused FirstDetectedAt preserves Date Serial value", _
            passCount, failCount

        RecordResult SameDate( _
            item(FIELD_LAST_DETECTED_AT), _
            lastGone), _
            "R20-09 Unused LastDetectedAt preserves Date Serial value", _
            passCount, failCount
    Else
        RecordResult False, _
            "R20-08 Unused item available", passCount, failCount
        RecordResult False, _
            "R20-09 Unused item available", passCount, failCount
    End If

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

Private Function SameDate( _
    ByVal actualValue As Variant, _
    ByVal expectedValue As Date _
) As Boolean

    On Error GoTo InvalidValue

    If IsEmpty(actualValue) Or _
       IsNull(actualValue) Or _
       IsError(actualValue) Then
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
