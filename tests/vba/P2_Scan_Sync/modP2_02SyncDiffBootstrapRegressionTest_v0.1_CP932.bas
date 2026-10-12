Attribute VB_Name = "modP2_02SyncDiffBootstrapRegressionTest"
Option Explicit

' P2-02 Sync Diff Core
' IF-P2-04-001 Bootstrap Metadata Regression
'
' This test module verifies the correction only.
' Existing P2-02 Core / Negative / Compatibility tests must also be rerun.
'
' Entry point:
'   TestP202SyncDiffBootstrapRegression

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

Public Sub TestP202SyncDiffBootstrapRegression()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(76, "=")
    Debug.Print "P2-02 Sync Diff Core - Bootstrap Metadata Regression"
    Debug.Print "IF-P2-04-001"
    Debug.Print String$(76, "=")

    RunR01ExistingBootstrap passCount, failCount
    RunR02ReactivatedBootstrap passCount, failCount
    RunR03UnusedBootstrap passCount, failCount
    RunR04AlreadyUnusedBootstrap passCount, failCount
    RunR05PartialMetadataPresent passCount, failCount
    RunR06PartialMetadataAbsent passCount, failCount
    RunR07InitializedExisting passCount, failCount
    RunR08InitializedUnused passCount, failCount

    Debug.Print String$(76, "-")
    Debug.Print "PASS Count = " & CStr(passCount)
    Debug.Print "FAIL Count = " & CStr(failCount)

    If failCount = 0 Then
        Debug.Print "Overall = PASS"
    Else
        Debug.Print "Overall = FAIL"
    End If

    Debug.Print String$(76, "=")

End Sub

Private Sub RunR01ExistingBootstrap( _
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

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 1, 1)

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_BOTH))

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        Empty, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R01-01 Existing bootstrap returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_EXISTING).Count = 1, _
            "R01-02 Existing.Count = 1", passCount, failCount

        If diff(KEY_EXISTING).Count = 1 Then
            Set item = diff(KEY_EXISTING)(1)

            RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_BOTH, _
                "R01-03 TemplateLocation = Current", passCount, failCount

            RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), syncTimestamp), _
                "R01-04 FirstDetectedAt = SyncTimestamp", passCount, failCount

            RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), syncTimestamp), _
                "R01-05 LastDetectedAt = SyncTimestamp", passCount, failCount
        End If
    Else
        RecordResult False, _
            "R01-02 SyncDiffResult published", passCount, failCount
    End If

    RecordResult IsEmpty(definition(FIELD_TEMPLATE_LOCATION)), _
        "R01-06 Input TemplateLocation remains Empty", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_FIRST_DETECTED_AT)), _
        "R01-07 Input FirstDetectedAt remains Empty", passCount, failCount
    RecordResult IsEmpty(definition(FIELD_LAST_DETECTED_AT)), _
        "R01-08 Input LastDetectedAt remains Empty", passCount, failCount

End Sub

Private Sub RunR02ReactivatedBootstrap( _
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

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 2, 2)

    Set scanResult = MakeScanResult( _
        Array("Department"), _
        Array(LOCATION_BODY))

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "Department", _
        STATUS_UNUSED, _
        Empty, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R02-01 Reactivated bootstrap returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_REACTIVATED).Count = 1, _
            "R02-02 Reactivated.Count = 1", passCount, failCount

        If diff(KEY_REACTIVATED).Count = 1 Then
            Set item = diff(KEY_REACTIVATED)(1)

            RecordResult CStr(item(FIELD_STATUS)) = STATUS_ACTIVE, _
                "R02-03 Status = Active", passCount, failCount

            RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_BODY, _
                "R02-04 TemplateLocation = Current", passCount, failCount

            RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), syncTimestamp), _
                "R02-05 FirstDetectedAt = SyncTimestamp", passCount, failCount

            RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), syncTimestamp), _
                "R02-06 LastDetectedAt = SyncTimestamp", passCount, failCount
        End If
    End If

End Sub

Private Sub RunR03UnusedBootstrap( _
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

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 3, 3)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    Set definition = MakeDefinition( _
        "OldVariable", _
        STATUS_ACTIVE, _
        Empty, _
        Empty, _
        Empty)
    definitions.Add definition

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R03-01 Unused bootstrap returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult diff(KEY_UNUSED).Count = 1, _
            "R03-02 Unused.Count = 1", passCount, failCount

        If diff(KEY_UNUSED).Count = 1 Then
            Set item = diff(KEY_UNUSED)(1)

            RecordResult CStr(item(FIELD_STATUS)) = STATUS_UNUSED, _
                "R03-03 Status = Unused", passCount, failCount

            RecordResult IsEmpty(item(FIELD_TEMPLATE_LOCATION)), _
                "R03-04 TemplateLocation remains Empty", passCount, failCount

            RecordResult IsEmpty(item(FIELD_FIRST_DETECTED_AT)), _
                "R03-05 FirstDetectedAt remains Empty", passCount, failCount

            RecordResult IsEmpty(item(FIELD_LAST_DETECTED_AT)), _
                "R03-06 LastDetectedAt remains Empty", passCount, failCount
        End If
    End If

End Sub

Private Sub RunR04AlreadyUnusedBootstrap( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim syncTimestamp As Date

    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 4, 4)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "Legacy", _
        STATUS_UNUSED, _
        Empty, _
        Empty, _
        Empty)

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R04-01 Already-Unused bootstrap returns Success", passCount, failCount

    If Not diff Is Nothing Then
        RecordResult TotalDiffCount(diff) = 0, _
            "R04-02 Already-Unused remains no-op", passCount, failCount
    End If

End Sub

Private Sub RunR05PartialMetadataPresent( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldFirst As Date
    Dim syncTimestamp As Date

    oldFirst = DateSerial(2026, 9, 1)
    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 5, 5)

    Set scanResult = MakeScanResult( _
        Array("ModelName"), _
        Array(LOCATION_SUBJECT))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "ModelName", _
        STATUS_ACTIVE, _
        Empty, _
        oldFirst, _
        Empty)

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And Not result.Success, _
        "R05-01 Partial metadata / present returns Failure", passCount, failCount

    RecordResult diff Is Nothing, _
        "R05-02 Failure does not publish SyncDiffResult", passCount, failCount

End Sub

Private Sub RunR06PartialMetadataAbsent( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim oldLast As Date
    Dim syncTimestamp As Date

    oldLast = DateSerial(2026, 9, 15)
    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 6, 6)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "OldVariable", _
        STATUS_ACTIVE, _
        LOCATION_BODY, _
        Empty, _
        oldLast)

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And Not result.Success, _
        "R06-01 Partial metadata / absent returns Failure", passCount, failCount

    RecordResult diff Is Nothing, _
        "R06-02 Failure does not publish SyncDiffResult", passCount, failCount

End Sub

Private Sub RunR07InitializedExisting( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim item As Object
    Dim oldFirst As Date
    Dim oldLast As Date
    Dim syncTimestamp As Date

    oldFirst = DateSerial(2026, 8, 1)
    oldLast = DateSerial(2026, 9, 1)
    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 7, 7)

    Set scanResult = MakeScanResult( _
        Array("GateDate"), _
        Array(LOCATION_BOTH))

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "GateDate", _
        STATUS_ACTIVE, _
        LOCATION_SUBJECT, _
        oldFirst, _
        oldLast)

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R07-01 Initialized Existing remains Success", passCount, failCount

    If Not diff Is Nothing And diff(KEY_EXISTING).Count = 1 Then
        Set item = diff(KEY_EXISTING)(1)

        RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), oldFirst), _
            "R07-02 Existing FirstDetectedAt remains preserved", passCount, failCount

        RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), syncTimestamp), _
            "R07-03 Existing LastDetectedAt updates", passCount, failCount
    Else
        RecordResult False, _
            "R07-02 Existing item available", passCount, failCount
    End If

End Sub

Private Sub RunR08InitializedUnused( _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim scanResult As Object
    Dim definitions As Collection
    Dim result As COperationResult
    Dim diff As Object
    Dim item As Object
    Dim oldFirst As Date
    Dim oldLast As Date
    Dim syncTimestamp As Date

    oldFirst = DateSerial(2026, 7, 1)
    oldLast = DateSerial(2026, 9, 20)
    syncTimestamp = DateSerial(2026, 10, 1) + TimeSerial(12, 8, 8)

    Set scanResult = MakeScanResult(Array(), Array())

    Set definitions = New Collection
    definitions.Add MakeDefinition( _
        "Department", _
        STATUS_ACTIVE, _
        LOCATION_BODY, _
        oldFirst, _
        oldLast)

    Set result = BuildSyncDiff( _
        scanResult, _
        definitions, _
        syncTimestamp, _
        diff)

    RecordResult Not result Is Nothing And result.Success, _
        "R08-01 Initialized Unused remains Success", passCount, failCount

    If Not diff Is Nothing And diff(KEY_UNUSED).Count = 1 Then
        Set item = diff(KEY_UNUSED)(1)

        RecordResult CStr(item(FIELD_TEMPLATE_LOCATION)) = LOCATION_BODY, _
            "R08-02 Unused TemplateLocation preserved", passCount, failCount

        RecordResult SameDate(item(FIELD_FIRST_DETECTED_AT), oldFirst), _
            "R08-03 Unused FirstDetectedAt preserved", passCount, failCount

        RecordResult SameDate(item(FIELD_LAST_DETECTED_AT), oldLast), _
            "R08-04 Unused LastDetectedAt preserved", passCount, failCount
    Else
        RecordResult False, _
            "R08-02 Unused item available", passCount, failCount
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
