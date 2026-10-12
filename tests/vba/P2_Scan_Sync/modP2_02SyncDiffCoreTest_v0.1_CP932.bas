Attribute VB_Name = "modP2_02SyncDiffCoreTest"
Option Explicit

Private Const KEY_NEW As String = "New"
Private Const KEY_EXISTING As String = "Existing"
Private Const KEY_REACTIVATED As String = "Reactivated"
Private Const KEY_UNUSED As String = "Unused"

Private Const FIELD_VARIABLE_NAME As String = "VariableName"
Private Const FIELD_DISPLAY_NAME As String = "DisplayName"
Private Const FIELD_TYPE As String = "Type"
Private Const FIELD_REQUIRED As String = "Required"
Private Const FIELD_DESCRIPTION As String = "Description"
Private Const FIELD_OPTION_SOURCE As String = "OptionSource"
Private Const FIELD_SORT_ORDER As String = "SortOrder"
Private Const FIELD_FORMAT As String = "Format"
Private Const FIELD_TEMPLATE_LOCATION As String = "TemplateLocation"
Private Const FIELD_STATUS As String = "Status"
Private Const FIELD_FIRST_DETECTED_AT As String = "FirstDetectedAt"
Private Const FIELD_LAST_DETECTED_AT As String = "LastDetectedAt"
Private Const FIELD_ROW_INDEX As String = "__RowIndex"

Private Const STATUS_ACTIVE As String = "Active"
Private Const STATUS_UNUSED As String = "Unused"

Public Sub TestP202SyncDiffCore()

    Dim passCount As Long
    Dim failCount As Long

    Debug.Print String$(70, "=")
    Debug.Print "P2-02 Sync Diff Core Test"
    Debug.Print String$(70, "=")

    RunCase "C1  New", AddressOfCase("C1"), passCount, failCount
    RunCase "C2  Existing", AddressOfCase("C2"), passCount, failCount
    RunCase "C3  Reactivated", AddressOfCase("C3"), passCount, failCount
    RunCase "C4  Unused", AddressOfCase("C4"), passCount, failCount
    RunCase "C5  Already-Unused No-op", AddressOfCase("C5"), passCount, failCount
    RunCase "C6  Case Insensitive Existing", AddressOfCase("C6"), passCount, failCount
    RunCase "C7  Case Insensitive Reactivated", AddressOfCase("C7"), passCount, failCount
    RunCase "C8  Existing Canonical Name Preservation", AddressOfCase("C8"), passCount, failCount
    RunCase "C9  Rename = Old Unused + New", AddressOfCase("C9"), passCount, failCount
    RunCase "C10 Mixed Classification", AddressOfCase("C10"), passCount, failCount
    RunCase "C11 New Metadata", AddressOfCase("C11"), passCount, failCount
    RunCase "C12 Existing Metadata", AddressOfCase("C12"), passCount, failCount
    RunCase "C13 Reactivated Metadata", AddressOfCase("C13"), passCount, failCount
    RunCase "C14 Unused Metadata", AddressOfCase("C14"), passCount, failCount
    RunCase "C15 Common SyncTimestamp", AddressOfCase("C15"), passCount, failCount
    RunCase "C16 User Config / Input Immutability", AddressOfCase("C16"), passCount, failCount
    RunCase "C17 Empty Template Active -> Unused", AddressOfCase("C17"), passCount, failCount
    RunCase "C18 Empty Template Unused -> No-op", AddressOfCase("C18"), passCount, failCount

    Debug.Print String$(70, "-")
    Debug.Print "PASS Count: " & CStr(passCount)
    Debug.Print "FAIL Count: " & CStr(failCount)
    Debug.Print

    If failCount = 0 And passCount = 18 Then
        Debug.Print "Overall:"
        Debug.Print "PASS"
    Else
        Debug.Print "Overall:"
        Debug.Print "FAIL"
    End If

    Debug.Print String$(70, "=")

End Sub

' VBA has no first-class function pointer for ordinary procedures.
' This dispatcher keeps the runner explicit and prevents Debug.Assert false positives.
Private Function AddressOfCase(ByVal caseId As String) As String
    AddressOfCase = caseId
End Function

Private Sub RunCase( _
    ByVal label As String, _
    ByVal caseId As String, _
    ByRef passCount As Long, _
    ByRef failCount As Long _
)

    Dim passed As Boolean

    On Error GoTo CaseRuntimeError

    Select Case caseId
        Case "C1": passed = CaseC1_New()
        Case "C2": passed = CaseC2_Existing()
        Case "C3": passed = CaseC3_Reactivated()
        Case "C4": passed = CaseC4_Unused()
        Case "C5": passed = CaseC5_AlreadyUnused()
        Case "C6": passed = CaseC6_CaseInsensitiveExisting()
        Case "C7": passed = CaseC7_CaseInsensitiveReactivated()
        Case "C8": passed = CaseC8_CanonicalPreservation()
        Case "C9": passed = CaseC9_Rename()
        Case "C10": passed = CaseC10_Mixed()
        Case "C11": passed = CaseC11_NewMetadata()
        Case "C12": passed = CaseC12_ExistingMetadata()
        Case "C13": passed = CaseC13_ReactivatedMetadata()
        Case "C14": passed = CaseC14_UnusedMetadata()
        Case "C15": passed = CaseC15_CommonTimestamp()
        Case "C16": passed = CaseC16_UserConfigAndImmutability()
        Case "C17": passed = CaseC17_EmptyTemplateActive()
        Case "C18": passed = CaseC18_EmptyTemplateUnused()
        Case Else
            passed = False
    End Select

    If passed Then
        Debug.Print label & Space$(MaxLong(1, 52 - Len(label))) & "PASS"
        passCount = passCount + 1
    Else
        Debug.Print label & Space$(MaxLong(1, 52 - Len(label))) & "FAIL"
        failCount = failCount + 1
    End If

    Exit Sub

CaseRuntimeError:
    Debug.Print label & "  FAIL (Test Runtime Error " & _
        CStr(Err.Number) & ": " & Err.Description & ")"
    failCount = failCount + 1

End Sub

Private Function CaseC1_New() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim ts As Date

    ts = TestSyncTimestamp()

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "GateOwner", "Body"
    Set defs = New Collection

    Set result = BuildSyncDiff(scanResult, defs, ts, diff)

    If Not RequireSuccess(result, diff, "C1") Then Exit Function
    If Not CheckCounts(diff, 1, 0, 0, 0, "C1") Then Exit Function

    Set item = diff(KEY_NEW)(1)

    CaseC1_New = _
        CheckItem(item, "GateOwner", "Body", STATUS_ACTIVE, ts, ts, "C1")

End Function

Private Function CaseC2_Existing() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim t0 As Date
    Dim t1 As Date
    Dim ts As Date

    t0 = T0()
    t1 = T1()
    ts = TestSyncTimestamp()

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "ModelName", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Subject", t0, t1)

    Set result = BuildSyncDiff(scanResult, defs, ts, diff)

    If Not RequireSuccess(result, diff, "C2") Then Exit Function
    If Not CheckCounts(diff, 0, 1, 0, 0, "C2") Then Exit Function

    Set item = diff(KEY_EXISTING)(1)

    CaseC2_Existing = _
        CheckItem(item, "ModelName", "Both", STATUS_ACTIVE, t0, ts, "C2")

End Function

Private Function CaseC3_Reactivated() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim t0 As Date
    Dim t1 As Date
    Dim ts As Date

    t0 = T0()
    t1 = T1()
    ts = TestSyncTimestamp()

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "GateDate", "Subject"

    Set defs = New Collection
    defs.Add NewDefinition("GateDate", STATUS_UNUSED, "Body", t0, t1)

    Set result = BuildSyncDiff(scanResult, defs, ts, diff)

    If Not RequireSuccess(result, diff, "C3") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 1, 0, "C3") Then Exit Function

    Set item = diff(KEY_REACTIVATED)(1)

    CaseC3_Reactivated = _
        CheckItem(item, "GateDate", "Subject", STATUS_ACTIVE, t0, ts, "C3")

End Function

Private Function CaseC4_Unused() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim t0 As Date
    Dim t1 As Date

    t0 = T0()
    t1 = T1()

    Set scanResult = NewScanResult()

    Set defs = New Collection
    defs.Add NewDefinition("Department", STATUS_ACTIVE, "Body", t0, t1)

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C4") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 0, 1, "C4") Then Exit Function

    Set item = diff(KEY_UNUSED)(1)

    CaseC4_Unused = _
        CheckItem(item, "Department", "Body", STATUS_UNUSED, t0, t1, "C4")

End Function

Private Function CaseC5_AlreadyUnused() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = NewScanResult()

    Set defs = New Collection
    defs.Add NewDefinition("Comment", STATUS_UNUSED, "Body", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C5") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 0, 0, "C5") Then Exit Function

    If diff.Exists("Already-Unused") Then
        Debug.Print "  C5: unexpected Already-Unused key."
        Exit Function
    End If

    CaseC5_AlreadyUnused = True

End Function

Private Function CaseC6_CaseInsensitiveExisting() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "MODELNAME", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C6") Then Exit Function
    If Not CheckCounts(diff, 0, 1, 0, 0, "C6") Then Exit Function

    Set item = diff(KEY_EXISTING)(1)

    If CStr(item(FIELD_VARIABLE_NAME)) <> "ModelName" Then
        Debug.Print "  C6: canonical name mismatch."
        Exit Function
    End If

    CaseC6_CaseInsensitiveExisting = True

End Function

Private Function CaseC7_CaseInsensitiveReactivated() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "GATEDATE", "Body"

    Set defs = New Collection
    defs.Add NewDefinition("GateDate", STATUS_UNUSED, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C7") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 1, 0, "C7") Then Exit Function

    Set item = diff(KEY_REACTIVATED)(1)

    If CStr(item(FIELD_VARIABLE_NAME)) <> "GateDate" Then
        Debug.Print "  C7: canonical name mismatch."
        Exit Function
    End If

    If CStr(item(FIELD_STATUS)) <> STATUS_ACTIVE Then
        Debug.Print "  C7: status mismatch."
        Exit Function
    End If

    CaseC7_CaseInsensitiveReactivated = True

End Function

Private Function CaseC8_CanonicalPreservation() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "mOdElNaMe", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Body", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C8") Then Exit Function
    If Not CheckCounts(diff, 0, 1, 0, 0, "C8") Then Exit Function

    Set item = diff(KEY_EXISTING)(1)

    CaseC8_CanonicalPreservation = _
        (CStr(item(FIELD_VARIABLE_NAME)) = "ModelName")

    If Not CaseC8_CanonicalPreservation Then
        Debug.Print "  C8: Existing canonical spelling was not preserved."
    End If

End Function

Private Function CaseC9_Rename() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim newItem As Object
    Dim unusedItem As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "PersonInCharge", "Body"

    Set defs = New Collection
    defs.Add NewDefinition("PIC", STATUS_ACTIVE, "Body", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C9") Then Exit Function
    If Not CheckCounts(diff, 1, 0, 0, 1, "C9") Then Exit Function

    Set newItem = diff(KEY_NEW)(1)
    Set unusedItem = diff(KEY_UNUSED)(1)

    If CStr(newItem(FIELD_VARIABLE_NAME)) <> "PersonInCharge" Then
        Debug.Print "  C9: New variable mismatch."
        Exit Function
    End If

    If CStr(unusedItem(FIELD_VARIABLE_NAME)) <> "PIC" Then
        Debug.Print "  C9: Unused variable mismatch."
        Exit Function
    End If

    If diff.Exists("Rename") Or diff.Exists("Renamed") Then
        Debug.Print "  C9: Rename classification should not exist."
        Exit Function
    End If

    CaseC9_Rename = True

End Function

Private Function CaseC10_Mixed() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "ModelName", "Both"
    AddScanVariable scanResult, "GateDate", "Subject"
    AddScanVariable scanResult, "GateOwner", "Body"

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Subject", T0(), T1())
    defs.Add NewDefinition("GateDate", STATUS_UNUSED, "Body", T0(), T1())
    defs.Add NewDefinition("Department", STATUS_ACTIVE, "Body", T0(), T1())
    defs.Add NewDefinition("Comment", STATUS_UNUSED, "Body", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C10") Then Exit Function
    If Not CheckCounts(diff, 1, 1, 1, 1, "C10") Then Exit Function

    If CStr(GetBucketItem(diff, KEY_NEW, 1)(FIELD_VARIABLE_NAME)) <> "GateOwner" Then Exit Function
    If CStr(GetBucketItem(diff, KEY_EXISTING, 1)(FIELD_VARIABLE_NAME)) <> "ModelName" Then Exit Function
    If CStr(GetBucketItem(diff, KEY_REACTIVATED, 1)(FIELD_VARIABLE_NAME)) <> "GateDate" Then Exit Function
    If CStr(GetBucketItem(diff, KEY_UNUSED, 1)(FIELD_VARIABLE_NAME)) <> "Department" Then Exit Function

    CaseC10_Mixed = True

End Function

Private Function CaseC11_NewMetadata() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object
    Dim ts As Date

    ts = TestSyncTimestamp()

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "GateOwner", "Body"
    Set defs = New Collection

    Set result = BuildSyncDiff(scanResult, defs, ts, diff)

    If Not RequireSuccess(result, diff, "C11") Then Exit Function
    Set item = diff(KEY_NEW)(1)

    CaseC11_NewMetadata = _
        CheckItem(item, "GateOwner", "Body", STATUS_ACTIVE, ts, ts, "C11")

End Function

Private Function CaseC12_ExistingMetadata() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "ModelName", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C12") Then Exit Function
    Set item = diff(KEY_EXISTING)(1)

    CaseC12_ExistingMetadata = _
        CheckItem( _
            item, _
            "ModelName", _
            "Both", _
            STATUS_ACTIVE, _
            T0(), _
            TestSyncTimestamp(), _
            "C12")

End Function

Private Function CaseC13_ReactivatedMetadata() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "GateDate", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("GateDate", STATUS_UNUSED, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C13") Then Exit Function
    Set item = diff(KEY_REACTIVATED)(1)

    CaseC13_ReactivatedMetadata = _
        CheckItem( _
            item, _
            "GateDate", _
            "Both", _
            STATUS_ACTIVE, _
            T0(), _
            TestSyncTimestamp(), _
            "C13")

End Function

Private Function CaseC14_UnusedMetadata() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim item As Object

    Set scanResult = NewScanResult()

    Set defs = New Collection
    defs.Add NewDefinition("Department", STATUS_ACTIVE, "Body", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C14") Then Exit Function
    Set item = diff(KEY_UNUSED)(1)

    CaseC14_UnusedMetadata = _
        CheckItem( _
            item, _
            "Department", _
            "Body", _
            STATUS_UNUSED, _
            T0(), _
            T1(), _
            "C14")

End Function

Private Function CaseC15_CommonTimestamp() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim ts As Date
    Dim itemNew As Object
    Dim itemExisting As Object
    Dim itemReactivated As Object

    ts = TestSyncTimestamp()

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "NewVariable", "Body"
    AddScanVariable scanResult, "ExistingVariable", "Subject"
    AddScanVariable scanResult, "ReactivatedVariable", "Both"

    Set defs = New Collection
    defs.Add NewDefinition("ExistingVariable", STATUS_ACTIVE, "Body", T0(), T1())
    defs.Add NewDefinition("ReactivatedVariable", STATUS_UNUSED, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, ts, diff)

    If Not RequireSuccess(result, diff, "C15") Then Exit Function
    If Not CheckCounts(diff, 1, 1, 1, 0, "C15") Then Exit Function

    Set itemNew = diff(KEY_NEW)(1)
    Set itemExisting = diff(KEY_EXISTING)(1)
    Set itemReactivated = diff(KEY_REACTIVATED)(1)

    If CDate(itemNew(FIELD_FIRST_DETECTED_AT)) <> ts Then Exit Function
    If CDate(itemNew(FIELD_LAST_DETECTED_AT)) <> ts Then Exit Function
    If CDate(itemExisting(FIELD_LAST_DETECTED_AT)) <> ts Then Exit Function
    If CDate(itemReactivated(FIELD_LAST_DETECTED_AT)) <> ts Then Exit Function

    CaseC15_CommonTimestamp = True

End Function

Private Function CaseC16_UserConfigAndImmutability() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim definition As Object
    Dim item As Object

    Set scanResult = NewScanResult()
    AddScanVariable scanResult, "ModelName", "Both"

    Set defs = New Collection
    Set definition = NewDefinition("ModelName", STATUS_ACTIVE, "Subject", T0(), T1())

    definition.Add FIELD_DISPLAY_NAME, "Model"
    definition.Add FIELD_TYPE, "Text"
    definition.Add FIELD_REQUIRED, True
    definition.Add FIELD_DESCRIPTION, "Description"
    definition.Add FIELD_OPTION_SOURCE, vbNullString
    definition.Add FIELD_SORT_ORDER, 10
    definition.Add FIELD_FORMAT, vbNullString
    definition.Add FIELD_ROW_INDEX, 1

    defs.Add definition

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C16") Then Exit Function
    Set item = diff(KEY_EXISTING)(1)

    If item.Exists(FIELD_DISPLAY_NAME) Then Exit Function
    If item.Exists(FIELD_TYPE) Then Exit Function
    If item.Exists(FIELD_REQUIRED) Then Exit Function
    If item.Exists(FIELD_DESCRIPTION) Then Exit Function
    If item.Exists(FIELD_OPTION_SOURCE) Then Exit Function
    If item.Exists(FIELD_SORT_ORDER) Then Exit Function
    If item.Exists(FIELD_FORMAT) Then Exit Function

    If CStr(definition(FIELD_VARIABLE_NAME)) <> "ModelName" Then Exit Function
    If CStr(definition(FIELD_DISPLAY_NAME)) <> "Model" Then Exit Function
    If CStr(definition(FIELD_TYPE)) <> "Text" Then Exit Function
    If CBool(definition(FIELD_REQUIRED)) <> True Then Exit Function
    If CStr(definition(FIELD_DESCRIPTION)) <> "Description" Then Exit Function
    If CStr(definition(FIELD_OPTION_SOURCE)) <> vbNullString Then Exit Function
    If CLng(definition(FIELD_SORT_ORDER)) <> 10 Then Exit Function
    If CStr(definition(FIELD_FORMAT)) <> vbNullString Then Exit Function
    If CStr(definition(FIELD_TEMPLATE_LOCATION)) <> "Subject" Then Exit Function
    If CStr(definition(FIELD_STATUS)) <> STATUS_ACTIVE Then Exit Function
    If CDate(definition(FIELD_FIRST_DETECTED_AT)) <> T0() Then Exit Function
    If CDate(definition(FIELD_LAST_DETECTED_AT)) <> T1() Then Exit Function
    If CLng(definition(FIELD_ROW_INDEX)) <> 1 Then Exit Function

    CaseC16_UserConfigAndImmutability = True

End Function

Private Function CaseC17_EmptyTemplateActive() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult

    Set scanResult = NewScanResult()

    Set defs = New Collection
    defs.Add NewDefinition("ModelName", STATUS_ACTIVE, "Both", T0(), T1())
    defs.Add NewDefinition("GateDate", STATUS_ACTIVE, "Subject", T0(), T1())

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C17") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 0, 2, "C17") Then Exit Function

    If CStr(GetBucketItem(diff, KEY_UNUSED, 1)(FIELD_VARIABLE_NAME)) <> "ModelName" Then Exit Function
    If CStr(GetBucketItem(diff, KEY_UNUSED, 2)(FIELD_VARIABLE_NAME)) <> "GateDate" Then Exit Function

    CaseC17_EmptyTemplateActive = True

End Function

Private Function CaseC18_EmptyTemplateUnused() As Boolean

    Dim scanResult As Object
    Dim defs As Collection
    Dim diff As Object
    Dim result As COperationResult
    Dim d1 As Object
    Dim d2 As Object

    Set scanResult = NewScanResult()

    Set defs = New Collection
    Set d1 = NewDefinition("Comment", STATUS_UNUSED, "Body", T0(), T1())
    Set d2 = NewDefinition("Department", STATUS_UNUSED, "Body", T0(), T1())
    defs.Add d1
    defs.Add d2

    Set result = BuildSyncDiff(scanResult, defs, TestSyncTimestamp(), diff)

    If Not RequireSuccess(result, diff, "C18") Then Exit Function
    If Not CheckCounts(diff, 0, 0, 0, 0, "C18") Then Exit Function

    If CStr(d1(FIELD_STATUS)) <> STATUS_UNUSED Then Exit Function
    If CStr(d1(FIELD_TEMPLATE_LOCATION)) <> "Body" Then Exit Function
    If CDate(d1(FIELD_FIRST_DETECTED_AT)) <> T0() Then Exit Function
    If CDate(d1(FIELD_LAST_DETECTED_AT)) <> T1() Then Exit Function

    If CStr(d2(FIELD_STATUS)) <> STATUS_UNUSED Then Exit Function
    If CStr(d2(FIELD_TEMPLATE_LOCATION)) <> "Body" Then Exit Function
    If CDate(d2(FIELD_FIRST_DETECTED_AT)) <> T0() Then Exit Function
    If CDate(d2(FIELD_LAST_DETECTED_AT)) <> T1() Then Exit Function

    CaseC18_EmptyTemplateUnused = True

End Function

Private Function NewScanResult() As Object

    Dim scanResult As Object
    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim locations As Object

    Set scanResult = CreateObject("Scripting.Dictionary")
    scanResult.CompareMode = vbTextCompare

    Set validVariables = New Collection
    Set invalidCandidates = New Collection
    Set locations = CreateObject("Scripting.Dictionary")
    locations.CompareMode = vbTextCompare

    scanResult.Add "ValidVariables", validVariables
    scanResult.Add "InvalidCandidates", invalidCandidates
    scanResult.Add "Locations", locations

    Set NewScanResult = scanResult

End Function

Private Sub AddScanVariable( _
    ByVal scanResult As Object, _
    ByVal variableName As String, _
    ByVal locationValue As String _
)

    Dim validVariables As Collection
    Dim locations As Object

    Set validVariables = scanResult("ValidVariables")
    Set locations = scanResult("Locations")

    validVariables.Add variableName
    locations.Add variableName, locationValue

End Sub

Private Function NewDefinition( _
    ByVal variableName As String, _
    ByVal statusValue As String, _
    ByVal locationValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
) As Object

    Dim item As Object

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add FIELD_VARIABLE_NAME, variableName
    item.Add FIELD_TEMPLATE_LOCATION, locationValue
    item.Add FIELD_STATUS, statusValue
    item.Add FIELD_FIRST_DETECTED_AT, firstDetectedAt
    item.Add FIELD_LAST_DETECTED_AT, lastDetectedAt

    Set NewDefinition = item

End Function


Private Function GetBucketItem( _
    ByVal diff As Object, _
    ByVal bucketKey As String, _
    ByVal itemIndex As Long _
) As Object

    Dim bucket As Collection

    Set bucket = diff(bucketKey)
    Set GetBucketItem = bucket(itemIndex)

End Function

Private Function RequireSuccess( _
    ByVal result As COperationResult, _
    ByVal diff As Object, _
    ByVal context As String _
) As Boolean

    If result Is Nothing Then
        Debug.Print "  " & context & ": COperationResult is Nothing."
        Exit Function
    End If

    If Not result.Success Then
        PrintResultErrors context, result
        Exit Function
    End If

    If diff Is Nothing Then
        Debug.Print "  " & context & ": SyncDiffResult is Nothing on Success."
        Exit Function
    End If

    If Not DiffHasRequiredKeys(diff) Then
        Debug.Print "  " & context & ": SyncDiffResult missing required keys."
        Exit Function
    End If

    RequireSuccess = True

End Function

Private Function DiffHasRequiredKeys(ByVal diff As Object) As Boolean

    DiffHasRequiredKeys = _
        diff.Exists(KEY_NEW) And _
        diff.Exists(KEY_EXISTING) And _
        diff.Exists(KEY_REACTIVATED) And _
        diff.Exists(KEY_UNUSED)

End Function

Private Function CheckCounts( _
    ByVal diff As Object, _
    ByVal expectedNew As Long, _
    ByVal expectedExisting As Long, _
    ByVal expectedReactivated As Long, _
    ByVal expectedUnused As Long, _
    ByVal context As String _
) As Boolean

    If diff(KEY_NEW).Count <> expectedNew Then
        PrintCountMismatch context, KEY_NEW, expectedNew, diff(KEY_NEW).Count
        Exit Function
    End If

    If diff(KEY_EXISTING).Count <> expectedExisting Then
        PrintCountMismatch context, KEY_EXISTING, expectedExisting, diff(KEY_EXISTING).Count
        Exit Function
    End If

    If diff(KEY_REACTIVATED).Count <> expectedReactivated Then
        PrintCountMismatch context, KEY_REACTIVATED, expectedReactivated, diff(KEY_REACTIVATED).Count
        Exit Function
    End If

    If diff(KEY_UNUSED).Count <> expectedUnused Then
        PrintCountMismatch context, KEY_UNUSED, expectedUnused, diff(KEY_UNUSED).Count
        Exit Function
    End If

    CheckCounts = True

End Function

Private Function CheckItem( _
    ByVal item As Object, _
    ByVal expectedVariableName As String, _
    ByVal expectedLocation As String, _
    ByVal expectedStatus As String, _
    ByVal expectedFirst As Date, _
    ByVal expectedLast As Date, _
    ByVal context As String _
) As Boolean

    If item Is Nothing Then
        Debug.Print "  " & context & ": item is Nothing."
        Exit Function
    End If

    If Not ItemHasMetadataKeys(item) Then
        Debug.Print "  " & context & ": item missing metadata keys."
        Exit Function
    End If

    If CStr(item(FIELD_VARIABLE_NAME)) <> expectedVariableName Then
        Debug.Print "  " & context & ": VariableName mismatch."
        Exit Function
    End If

    If CStr(item(FIELD_TEMPLATE_LOCATION)) <> expectedLocation Then
        Debug.Print "  " & context & ": TemplateLocation mismatch."
        Exit Function
    End If

    If CStr(item(FIELD_STATUS)) <> expectedStatus Then
        Debug.Print "  " & context & ": Status mismatch."
        Exit Function
    End If

    If CDate(item(FIELD_FIRST_DETECTED_AT)) <> expectedFirst Then
        Debug.Print "  " & context & ": FirstDetectedAt mismatch."
        Exit Function
    End If

    If CDate(item(FIELD_LAST_DETECTED_AT)) <> expectedLast Then
        Debug.Print "  " & context & ": LastDetectedAt mismatch."
        Exit Function
    End If

    CheckItem = True

End Function

Private Function ItemHasMetadataKeys(ByVal item As Object) As Boolean

    ItemHasMetadataKeys = _
        item.Exists(FIELD_VARIABLE_NAME) And _
        item.Exists(FIELD_TEMPLATE_LOCATION) And _
        item.Exists(FIELD_STATUS) And _
        item.Exists(FIELD_FIRST_DETECTED_AT) And _
        item.Exists(FIELD_LAST_DETECTED_AT)

End Function

Private Sub PrintCountMismatch( _
    ByVal context As String, _
    ByVal bucket As String, _
    ByVal expectedCount As Long, _
    ByVal actualCount As Long _
)

    Debug.Print "  " & context & ": " & bucket & " count mismatch."
    Debug.Print "    Expected = " & CStr(expectedCount)
    Debug.Print "    Actual   = " & CStr(actualCount)

End Sub

Private Sub PrintResultErrors( _
    ByVal context As String, _
    ByVal result As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    Debug.Print "  " & context & ": BuildSyncDiff returned Failure."

    If result Is Nothing Then
        Debug.Print "    Result is Nothing."
        Exit Sub
    End If

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)
        Debug.Print "    Error[" & CStr(i) & "]"
        Debug.Print "      Type   = " & errorInfo.ErrorType
        Debug.Print "      Message= " & errorInfo.Message
        Debug.Print "      Target = " & errorInfo.Target
    Next i

End Sub

Private Function TestSyncTimestamp() As Date
    TestSyncTimestamp = _
        DateSerial(2026, 9, 28) + TimeSerial(6, 30, 0)
End Function

Private Function T0() As Date
    T0 = DateSerial(2026, 9, 1) + TimeSerial(9, 0, 0)
End Function

Private Function T1() As Date
    T1 = DateSerial(2026, 9, 20) + TimeSerial(10, 0, 0)
End Function

Private Function MaxLong( _
    ByVal leftValue As Long, _
    ByVal rightValue As Long _
) As Long

    If leftValue > rightValue Then
        MaxLong = leftValue
    Else
        MaxLong = rightValue
    End If

End Function
