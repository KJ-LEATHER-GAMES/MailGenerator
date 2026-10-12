Attribute VB_Name = "modP2_03SyncPersistenceCoreTest"
Option Explicit

Private Const SHEET_NAME As String = "VariableDefinition"
Private Const TABLE_NAME As String = "tblVariableDefinition"

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

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private mPassCount As Long
Private mFailCount As Long

Public Sub TestP203SyncPersistenceCore()

    Dim lo As ListObject
    Dim originalRows As Collection

    Debug.Print String$(72, "=")
    Debug.Print "P2-03 Sync Persistence Core Verification: START"
    Debug.Print "ThisWorkbook: " & ThisWorkbook.Name
    Debug.Print String$(72, "=")

    mPassCount = 0
    mFailCount = 0

    On Error GoTo FatalError

    Set lo = GetTestTable()
    If lo Is Nothing Then
        Debug.Print "PRECONDITION FAIL: tblVariableDefinition was not found."
        Exit Sub
    End If

    If Not HasRequiredColumns(lo) Then
        Debug.Print "PRECONDITION FAIL: Required VariableDefinition columns are missing."
        Exit Sub
    End If

    Set originalRows = CaptureRows(lo)

    RecordCaseResult "C01 New / Empty Table", TestC01_NewEmptyTable(lo)
    RecordCaseResult "C02 New / Existing Table", TestC02_NewExistingTable(lo)
    RecordCaseResult "C03 Multiple New", TestC03_MultipleNewOrder(lo)
    RecordCaseResult "C04 Existing", TestC04_ExistingPersistence(lo)
    RecordCaseResult "C05 Existing Canonical Identity", TestC05_CanonicalExistingIdentity(lo)
    RecordCaseResult "C06 Reactivated", TestC06_Reactivated(lo)
    RecordCaseResult "C07 Unused", TestC07_Unused(lo)
    RecordCaseResult "C08 Mixed Classification", TestC08_MixedClassification(lo)
    RecordCaseResult "C09 Zero Target No-op", TestC09_ZeroTargetNoOp(lo)
    RecordCaseResult "C10 Date Persistence", TestC10_DatePersistence(lo)
    RecordCaseResult "C11 User Configuration Preservation", TestC11_UserConfigurationPreservation(lo)
    RecordCaseResult "C12 Existing VariableName Preservation", TestC12_VariableNamePreservation(lo)

    RestoreRows lo, originalRows

    Debug.Print String$(72, "-")
    Debug.Print "PASS Count: " & CStr(mPassCount)
    Debug.Print "FAIL Count: " & CStr(mFailCount)

    If mFailCount = 0 Then
        Debug.Print "Overall: PASS"
    Else
        Debug.Print "Overall: FAIL"
    End If

    Debug.Print "Original tblVariableDefinition contents restored."
    Debug.Print String$(72, "=")
    Exit Sub

FatalError:
    Debug.Print "FATAL TEST HARNESS ERROR:"
    Debug.Print "  Number = " & CStr(Err.Number)
    Debug.Print "  Description = " & Err.Description

    On Error Resume Next
    If Not lo Is Nothing Then
        If Not originalRows Is Nothing Then
            RestoreRows lo, originalRows
            Debug.Print "Original tblVariableDefinition contents restored after fatal error."
        End If
    End If
    On Error GoTo 0

    Debug.Print "Overall: ABORTED"
    Debug.Print String$(72, "=")

End Sub

Private Function TestC01_NewEmptyTable(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim detectedAt As Date

    detectedAt = DateSerial(2026, 9, 1) + TimeSerial(10, 15, 0)
    ClearTable lo

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("GateDate", "Body", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C01 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C01 Row Count", 1, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_VARIABLE_NAME, "GateDate", "C01 VariableName") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Body", "C01 TemplateLocation") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Active", "C01 Status") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, detectedAt, "C01 FirstDetectedAt") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, detectedAt, "C01 LastDetectedAt") Then Exit Function
    If Not AssertUserConfigurationBlank(lo, 1, "C01") Then Exit Function

    TestC01_NewEmptyTable = True

End Function

Private Function TestC02_NewExistingTable(ByVal lo As ListObject) As Boolean

    Dim beforeRow As Object
    Dim diff As Object
    Dim result As COperationResult
    Dim detectedAt As Date

    detectedAt = DateSerial(2026, 9, 2) + TimeSerial(11, 0, 0)
    ClearTable lo

    AddFixtureRow lo, "BaseVar", "Base Display", "Text", True, "Base Description", vbNullString, 10, vbNullString, "Subject", "Active", DateSerial(2026, 8, 1), DateSerial(2026, 8, 20)
    Set beforeRow = CaptureRow(lo, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("AddedVar", "Both", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C02 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C02 Row Count", 2, lo.ListRows.Count) Then Exit Function
    If Not AssertRowMatchesSnapshot(lo, 1, beforeRow, "C02 Existing Row Unchanged") Then Exit Function
    If Not AssertTextCell(lo, 2, KEY_VARIABLE_NAME, "AddedVar", "C02 New VariableName") Then Exit Function
    If Not AssertUserConfigurationBlank(lo, 2, "C02") Then Exit Function

    TestC02_NewExistingTable = True

End Function

Private Function TestC03_MultipleNewOrder(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim detectedAt As Date

    detectedAt = DateSerial(2026, 9, 3) + TimeSerial(9, 30, 0)
    ClearTable lo

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("FirstVar", "Subject", "Active", detectedAt, detectedAt)
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("SecondVar", "Body", "Active", detectedAt, detectedAt)
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("ThirdVar", "Both", "Active", detectedAt, detectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C03 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C03 Row Count", 3, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_VARIABLE_NAME, "FirstVar", "C03 Row1") Then Exit Function
    If Not AssertTextCell(lo, 2, KEY_VARIABLE_NAME, "SecondVar", "C03 Row2") Then Exit Function
    If Not AssertTextCell(lo, 3, KEY_VARIABLE_NAME, "ThirdVar", "C03 Row3") Then Exit Function

    TestC03_MultipleNewOrder = True

End Function

Private Function TestC04_ExistingPersistence(ByVal lo As ListObject) As Boolean

    Dim userBefore As Object
    Dim diff As Object
    Dim result As COperationResult
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    firstDetectedAt = DateSerial(2026, 7, 1) + TimeSerial(8, 0, 0)
    lastDetectedAt = DateSerial(2026, 9, 4) + TimeSerial(12, 30, 0)
    ClearTable lo

    AddFixtureRow lo, "ExistingVar", "Existing Display", "Date", True, "Existing Description", vbNullString, 20, "yyyy/mm/dd", "Subject", "Active", firstDetectedAt, DateSerial(2026, 8, 15)
    Set userBefore = CaptureUserConfiguration(lo, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("ExistingVar", "Both", "Active", firstDetectedAt, lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C04 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C04 Row Count", 1, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_VARIABLE_NAME, "ExistingVar", "C04 VariableName") Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 1, userBefore, "C04 User Configuration") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Both", "C04 TemplateLocation") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Active", "C04 Status") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, firstDetectedAt, "C04 FirstDetectedAt") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, lastDetectedAt, "C04 LastDetectedAt") Then Exit Function

    TestC04_ExistingPersistence = True

End Function

Private Function TestC05_CanonicalExistingIdentity(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    firstDetectedAt = DateSerial(2026, 6, 1)
    lastDetectedAt = DateSerial(2026, 9, 5) + TimeSerial(13, 0, 0)
    ClearTable lo

    AddFixtureRow lo, "ModelName", "Model", "Text", True, "Canonical test", vbNullString, 10, vbNullString, "Body", "Active", firstDetectedAt, DateSerial(2026, 8, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("ModelName", "Both", "Active", firstDetectedAt, lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C05 ApplySyncDiff", result) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_VARIABLE_NAME, "ModelName", "C05 Canonical VariableName") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Both", "C05 Metadata Updated") Then Exit Function

    TestC05_CanonicalExistingIdentity = True

End Function

Private Function TestC06_Reactivated(ByVal lo As ListObject) As Boolean

    Dim userBefore As Object
    Dim diff As Object
    Dim result As COperationResult
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    firstDetectedAt = DateSerial(2026, 5, 10)
    lastDetectedAt = DateSerial(2026, 9, 6) + TimeSerial(14, 0, 0)
    ClearTable lo

    AddFixtureRow lo, "ReactivatedVar", "Reactivated Display", "Select", False, "Reactivated Description", "Department", 30, vbNullString, "Body", "Unused", firstDetectedAt, DateSerial(2026, 6, 1)
    Set userBefore = CaptureUserConfiguration(lo, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_REACTIVATED, CreateDiffItem("ReactivatedVar", "Subject", "Active", firstDetectedAt, lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C06 ApplySyncDiff", result) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Active", "C06 Status") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Subject", "C06 TemplateLocation") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, firstDetectedAt, "C06 FirstDetectedAt") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, lastDetectedAt, "C06 LastDetectedAt") Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 1, userBefore, "C06 User Configuration") Then Exit Function

    TestC06_Reactivated = True

End Function

Private Function TestC07_Unused(ByVal lo As ListObject) As Boolean

    Dim userBefore As Object
    Dim diff As Object
    Dim result As COperationResult
    Dim firstDetectedAt As Date
    Dim lastDetectedAt As Date

    firstDetectedAt = DateSerial(2026, 4, 1)
    lastDetectedAt = DateSerial(2026, 8, 31) + TimeSerial(16, 0, 0)
    ClearTable lo

    AddFixtureRow lo, "UnusedVar", "Unused Display", "Text", False, "Keep configuration", vbNullString, 40, vbNullString, "Both", "Active", firstDetectedAt, lastDetectedAt
    Set userBefore = CaptureUserConfiguration(lo, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_UNUSED, CreateDiffItem("UnusedVar", "Both", "Unused", firstDetectedAt, lastDetectedAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C07 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C07 Row Count", 1, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Unused", "C07 Status") Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_TEMPLATE_LOCATION, "Both", "C07 TemplateLocation") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, firstDetectedAt, "C07 FirstDetectedAt") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, lastDetectedAt, "C07 LastDetectedAt") Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 1, userBefore, "C07 User Configuration") Then Exit Function

    TestC07_Unused = True

End Function

Private Function TestC08_MixedClassification(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim firstA As Date
    Dim firstB As Date
    Dim firstC As Date
    Dim syncAt As Date

    firstA = DateSerial(2026, 1, 1)
    firstB = DateSerial(2026, 2, 1)
    firstC = DateSerial(2026, 3, 1)
    syncAt = DateSerial(2026, 9, 8) + TimeSerial(10, 45, 0)
    ClearTable lo

    AddFixtureRow lo, "MixExisting", "Mix E", "Text", True, "E", vbNullString, 10, vbNullString, "Subject", "Active", firstA, DateSerial(2026, 8, 1)
    AddFixtureRow lo, "MixReactivated", "Mix R", "Text", False, "R", vbNullString, 20, vbNullString, "Body", "Unused", firstB, DateSerial(2026, 7, 1)
    AddFixtureRow lo, "MixUnused", "Mix U", "Text", False, "U", vbNullString, 30, vbNullString, "Both", "Active", firstC, DateSerial(2026, 6, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("MixExisting", "Both", "Active", firstA, syncAt)
    AddDiffItem diff, SYNC_REACTIVATED, CreateDiffItem("MixReactivated", "Subject", "Active", firstB, syncAt)
    AddDiffItem diff, SYNC_UNUSED, CreateDiffItem("MixUnused", "Both", "Unused", firstC, DateSerial(2026, 6, 1))
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("MixNew1", "Body", "Active", syncAt, syncAt)
    AddDiffItem diff, SYNC_NEW, CreateDiffItem("MixNew2", "Subject", "Active", syncAt, syncAt)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C08 ApplySyncDiff", result) Then Exit Function
    If Not AssertLong("C08 Row Count", 5, lo.ListRows.Count) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_STATUS, "Active", "C08 Existing") Then Exit Function
    If Not AssertTextCell(lo, 2, KEY_STATUS, "Active", "C08 Reactivated") Then Exit Function
    If Not AssertTextCell(lo, 3, KEY_STATUS, "Unused", "C08 Unused") Then Exit Function
    If Not AssertTextCell(lo, 4, KEY_VARIABLE_NAME, "MixNew1", "C08 New1") Then Exit Function
    If Not AssertTextCell(lo, 5, KEY_VARIABLE_NAME, "MixNew2", "C08 New2") Then Exit Function

    TestC08_MixedClassification = True

End Function

Private Function TestC09_ZeroTargetNoOp(ByVal lo As ListObject) As Boolean

    Dim beforeRows As Collection
    Dim diff As Object
    Dim result As COperationResult

    ClearTable lo
    AddFixtureRow lo, "NoOpVar", "No-op", "Text", True, "Must remain unchanged", vbNullString, 10, vbNullString, "Body", "Unused", DateSerial(2026, 1, 15), DateSerial(2026, 5, 15)

    Set beforeRows = CaptureRows(lo)
    Set diff = CreateEmptySyncDiff()
    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C09 ApplySyncDiff", result) Then Exit Function
    If Not AssertTableMatchesSnapshot(lo, beforeRows, "C09 Table unchanged") Then Exit Function

    TestC09_ZeroTargetNoOp = True

End Function

Private Function TestC10_DatePersistence(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim firstDate As Date
    Dim lastDate As Date
    Dim firstSerial As Double

    firstDate = DateSerial(2026, 2, 10) + TimeSerial(7, 45, 0)
    lastDate = DateSerial(2026, 9, 10) + TimeSerial(18, 20, 0)
    firstSerial = CDbl(firstDate)
    ClearTable lo

    AddFixtureRow lo, "DateVar", "Date test", "Date", True, "Date persistence", vbNullString, 10, "yyyy/mm/dd", "Subject", "Active", firstDate, DateSerial(2026, 8, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("DateVar", "Body", "Active", firstSerial, lastDate)

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C10 ApplySyncDiff", result) Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_FIRST_DETECTED_AT, firstDate, "C10 FirstDetectedAt serial") Then Exit Function
    If Not AssertDateCell(lo, 1, KEY_LAST_DETECTED_AT, lastDate, "C10 LastDetectedAt Date") Then Exit Function

    If VarType(GetCellValue2(lo, 1, KEY_FIRST_DETECTED_AT)) = vbString Then
        Debug.Print "  FAIL DETAIL: C10 FirstDetectedAt was stored as String."
        Exit Function
    End If

    If VarType(GetCellValue2(lo, 1, KEY_LAST_DETECTED_AT)) = vbString Then
        Debug.Print "  FAIL DETAIL: C10 LastDetectedAt was stored as String."
        Exit Function
    End If

    TestC10_DatePersistence = True

End Function

Private Function TestC11_UserConfigurationPreservation(ByVal lo As ListObject) As Boolean

    Dim beforeE As Object
    Dim beforeR As Object
    Dim beforeU As Object
    Dim diff As Object
    Dim result As COperationResult
    Dim syncAt As Date

    syncAt = DateSerial(2026, 9, 11) + TimeSerial(11, 11, 0)
    ClearTable lo

    AddFixtureRow lo, "CfgExisting", "Display E", "Text", True, "Desc E", "SourceE", 11, "FmtE", "Subject", "Active", DateSerial(2026, 1, 1), DateSerial(2026, 8, 1)
    AddFixtureRow lo, "CfgReactivated", "Display R", "Select", False, "Desc R", "SourceR", 22, "FmtR", "Body", "Unused", DateSerial(2026, 2, 2), DateSerial(2026, 7, 2)
    AddFixtureRow lo, "CfgUnused", "Display U", "Date", True, "Desc U", "SourceU", 33, "FmtU", "Both", "Active", DateSerial(2026, 3, 3), DateSerial(2026, 6, 3)

    Set beforeE = CaptureUserConfiguration(lo, 1)
    Set beforeR = CaptureUserConfiguration(lo, 2)
    Set beforeU = CaptureUserConfiguration(lo, 3)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("CfgExisting", "Both", "Active", DateSerial(2026, 1, 1), syncAt)
    AddDiffItem diff, SYNC_REACTIVATED, CreateDiffItem("CfgReactivated", "Subject", "Active", DateSerial(2026, 2, 2), syncAt)
    AddDiffItem diff, SYNC_UNUSED, CreateDiffItem("CfgUnused", "Both", "Unused", DateSerial(2026, 3, 3), DateSerial(2026, 6, 3))

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C11 ApplySyncDiff", result) Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 1, beforeE, "C11 Existing Config") Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 2, beforeR, "C11 Reactivated Config") Then Exit Function
    If Not AssertUserConfigurationMatches(lo, 3, beforeU, "C11 Unused Config") Then Exit Function

    TestC11_UserConfigurationPreservation = True

End Function

Private Function TestC12_VariableNamePreservation(ByVal lo As ListObject) As Boolean

    Dim diff As Object
    Dim result As COperationResult
    Dim syncAt As Date

    syncAt = DateSerial(2026, 9, 12) + TimeSerial(12, 0, 0)
    ClearTable lo

    AddFixtureRow lo, "PreserveNameE", "E", "Text", True, "E", vbNullString, 10, vbNullString, "Subject", "Active", DateSerial(2026, 1, 1), DateSerial(2026, 8, 1)
    AddFixtureRow lo, "PreserveNameR", "R", "Text", True, "R", vbNullString, 20, vbNullString, "Body", "Unused", DateSerial(2026, 2, 1), DateSerial(2026, 7, 1)
    AddFixtureRow lo, "PreserveNameU", "U", "Text", True, "U", vbNullString, 30, vbNullString, "Both", "Active", DateSerial(2026, 3, 1), DateSerial(2026, 6, 1)

    Set diff = CreateEmptySyncDiff()
    AddDiffItem diff, SYNC_EXISTING, CreateDiffItem("PreserveNameE", "Both", "Active", DateSerial(2026, 1, 1), syncAt)
    AddDiffItem diff, SYNC_REACTIVATED, CreateDiffItem("PreserveNameR", "Subject", "Active", DateSerial(2026, 2, 1), syncAt)
    AddDiffItem diff, SYNC_UNUSED, CreateDiffItem("PreserveNameU", "Both", "Unused", DateSerial(2026, 3, 1), DateSerial(2026, 6, 1))

    Set result = ApplySyncDiff(diff)

    If Not AssertSuccess("C12 ApplySyncDiff", result) Then Exit Function
    If Not AssertTextCell(lo, 1, KEY_VARIABLE_NAME, "PreserveNameE", "C12 Existing Name") Then Exit Function
    If Not AssertTextCell(lo, 2, KEY_VARIABLE_NAME, "PreserveNameR", "C12 Reactivated Name") Then Exit Function
    If Not AssertTextCell(lo, 3, KEY_VARIABLE_NAME, "PreserveNameU", "C12 Unused Name") Then Exit Function

    TestC12_VariableNamePreservation = True

End Function

Private Function CreateEmptySyncDiff() As Object

    Dim diff As Object
    Dim items As Collection

    Set diff = CreateObject("Scripting.Dictionary")
    diff.CompareMode = vbTextCompare

    Set items = New Collection
    diff.Add SYNC_NEW, items

    Set items = New Collection
    diff.Add SYNC_EXISTING, items

    Set items = New Collection
    diff.Add SYNC_REACTIVATED, items

    Set items = New Collection
    diff.Add SYNC_UNUSED, items

    Set CreateEmptySyncDiff = diff

End Function

Private Sub AddDiffItem(ByVal diff As Object, ByVal classification As String, ByVal item As Object)

    Dim items As Collection

    Set items = diff(classification)
    items.Add item

End Sub

Private Function CreateDiffItem( _
    ByVal variableName As String, _
    ByVal templateLocation As String, _
    ByVal statusValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
) As Object

    Dim item As Object

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add KEY_VARIABLE_NAME, variableName
    item.Add KEY_TEMPLATE_LOCATION, templateLocation
    item.Add KEY_STATUS, statusValue
    item.Add KEY_FIRST_DETECTED_AT, firstDetectedAt
    item.Add KEY_LAST_DETECTED_AT, lastDetectedAt

    Set CreateDiffItem = item

End Function

Private Function GetTestTable() As ListObject

    Dim ws As Worksheet
    Dim lo As ListObject

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(SHEET_NAME)
    If Not ws Is Nothing Then Set lo = ws.ListObjects(TABLE_NAME)
    On Error GoTo 0

    Set GetTestTable = lo

End Function

Private Function HasRequiredColumns(ByVal lo As ListObject) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim lc As ListColumn

    columns = Array(KEY_VARIABLE_NAME, KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT, KEY_TEMPLATE_LOCATION, KEY_STATUS, KEY_FIRST_DETECTED_AT, KEY_LAST_DETECTED_AT)

    For Each columnName In columns
        Set lc = Nothing
        On Error Resume Next
        Set lc = lo.ListColumns(CStr(columnName))
        On Error GoTo 0
        If lc Is Nothing Then
            Debug.Print "  Missing column: " & CStr(columnName)
            Exit Function
        End If
    Next columnName

    HasRequiredColumns = True

End Function

Private Sub ClearTable(ByVal lo As ListObject)

    Do While lo.ListRows.Count > 0
        lo.ListRows(lo.ListRows.Count).Delete
    Loop

End Sub

Private Sub AddFixtureRow( _
    ByVal lo As ListObject, _
    ByVal variableName As String, _
    ByVal displayName As Variant, _
    ByVal typeValue As Variant, _
    ByVal requiredValue As Variant, _
    ByVal descriptionValue As Variant, _
    ByVal optionSourceValue As Variant, _
    ByVal sortOrderValue As Variant, _
    ByVal formatValue As Variant, _
    ByVal templateLocation As String, _
    ByVal statusValue As String, _
    ByVal firstDetectedAt As Variant, _
    ByVal lastDetectedAt As Variant _
)

    Dim row As ListRow
    Dim rowIndex As Long

    Set row = lo.ListRows.Add
    rowIndex = row.Index

    WriteCell lo, rowIndex, KEY_VARIABLE_NAME, variableName
    WriteCell lo, rowIndex, KEY_DISPLAY_NAME, displayName
    WriteCell lo, rowIndex, KEY_TYPE, typeValue
    WriteCell lo, rowIndex, KEY_REQUIRED, requiredValue
    WriteCell lo, rowIndex, KEY_DESCRIPTION, descriptionValue
    WriteCell lo, rowIndex, KEY_OPTION_SOURCE, optionSourceValue
    WriteCell lo, rowIndex, KEY_SORT_ORDER, sortOrderValue
    WriteCell lo, rowIndex, KEY_FORMAT, formatValue
    WriteCell lo, rowIndex, KEY_TEMPLATE_LOCATION, templateLocation
    WriteCell lo, rowIndex, KEY_STATUS, statusValue
    lo.ListColumns(KEY_FIRST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = firstDetectedAt
    lo.ListColumns(KEY_LAST_DETECTED_AT).DataBodyRange.Cells(rowIndex, 1).Value = lastDetectedAt

End Sub

Private Sub WriteCell(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal columnName As String, ByVal value As Variant)
    lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2 = value
End Sub

Private Function CaptureRows(ByVal lo As ListObject) As Collection

    Dim rows As Collection
    Dim rowIndex As Long

    Set rows = New Collection

    If Not lo.DataBodyRange Is Nothing Then
        For rowIndex = 1 To lo.ListRows.Count
            rows.Add CaptureRow(lo, rowIndex)
        Next rowIndex
    End If

    Set CaptureRows = rows

End Function

Private Function CaptureRow(ByVal lo As ListObject, ByVal rowIndex As Long) As Object

    Dim item As Object
    Dim columns As Variant
    Dim columnName As Variant

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    columns = Array(KEY_VARIABLE_NAME, KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT, KEY_TEMPLATE_LOCATION, KEY_STATUS, KEY_FIRST_DETECTED_AT, KEY_LAST_DETECTED_AT)

    For Each columnName In columns
        item.Add CStr(columnName), GetCellValue2(lo, rowIndex, CStr(columnName))
    Next columnName

    Set CaptureRow = item

End Function

Private Sub RestoreRows(ByVal lo As ListObject, ByVal rows As Collection)

    Dim item As Object
    Dim row As ListRow
    Dim rowIndex As Long
    Dim columns As Variant
    Dim columnName As Variant

    ClearTable lo
    columns = Array(KEY_VARIABLE_NAME, KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT, KEY_TEMPLATE_LOCATION, KEY_STATUS, KEY_FIRST_DETECTED_AT, KEY_LAST_DETECTED_AT)

    For Each item In rows
        Set row = lo.ListRows.Add
        rowIndex = row.Index
        For Each columnName In columns
            WriteCell lo, rowIndex, CStr(columnName), item(CStr(columnName))
        Next columnName
    Next item

End Sub

Private Function CaptureUserConfiguration(ByVal lo As ListObject, ByVal rowIndex As Long) As Object

    Dim item As Object

    Set item = CreateObject("Scripting.Dictionary")
    item.CompareMode = vbTextCompare

    item.Add KEY_DISPLAY_NAME, GetCellValue2(lo, rowIndex, KEY_DISPLAY_NAME)
    item.Add KEY_TYPE, GetCellValue2(lo, rowIndex, KEY_TYPE)
    item.Add KEY_REQUIRED, GetCellValue2(lo, rowIndex, KEY_REQUIRED)
    item.Add KEY_DESCRIPTION, GetCellValue2(lo, rowIndex, KEY_DESCRIPTION)
    item.Add KEY_OPTION_SOURCE, GetCellValue2(lo, rowIndex, KEY_OPTION_SOURCE)
    item.Add KEY_SORT_ORDER, GetCellValue2(lo, rowIndex, KEY_SORT_ORDER)
    item.Add KEY_FORMAT, GetCellValue2(lo, rowIndex, KEY_FORMAT)

    Set CaptureUserConfiguration = item

End Function

Private Function GetCellValue2(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal columnName As String) As Variant
    GetCellValue2 = lo.ListColumns(columnName).DataBodyRange.Cells(rowIndex, 1).Value2
End Function

Private Function AssertSuccess(ByVal context As String, ByVal result As COperationResult) As Boolean

    If result Is Nothing Then
        Debug.Print "  FAIL DETAIL: " & context & " returned Nothing."
        Exit Function
    End If

    If Not result.Success Then
        Debug.Print "  FAIL DETAIL: " & context & " returned Failure."
        PrintResultErrors result
        Exit Function
    End If

    AssertSuccess = True

End Function

Private Function AssertLong(ByVal context As String, ByVal expected As Long, ByVal actual As Long) As Boolean

    AssertLong = (expected = actual)

    If Not AssertLong Then
        Debug.Print "  FAIL DETAIL: " & context
        Debug.Print "    Expected=" & CStr(expected)
        Debug.Print "    Actual  =" & CStr(actual)
    End If

End Function

Private Function AssertTextCell(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal columnName As String, ByVal expected As String, ByVal context As String) As Boolean

    Dim actual As Variant

    actual = GetCellValue2(lo, rowIndex, columnName)

    If IsError(actual) Or IsNull(actual) Then
        Debug.Print "  FAIL DETAIL: " & context & " is Error/Null."
        Exit Function
    End If

    AssertTextCell = (StrComp(CStr(actual), expected, vbBinaryCompare) = 0)

    If Not AssertTextCell Then
        Debug.Print "  FAIL DETAIL: " & context
        Debug.Print "    Expected=" & expected
        Debug.Print "    Actual  =" & CStr(actual)
    End If

End Function

Private Function AssertDateCell(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal columnName As String, ByVal expected As Date, ByVal context As String) As Boolean

    Dim actual As Variant
    Dim actualSerial As Double
    Dim expectedSerial As Double

    actual = GetCellValue2(lo, rowIndex, columnName)
    expectedSerial = CDbl(expected)

    If IsError(actual) Or IsNull(actual) Or IsEmpty(actual) Or Not IsNumeric(actual) Then
        Debug.Print "  FAIL DETAIL: " & context & " is not a numeric Excel date serial."
        Exit Function
    End If

    actualSerial = CDbl(actual)
    AssertDateCell = (Abs(actualSerial - expectedSerial) < 0.0000001)

    If Not AssertDateCell Then
        Debug.Print "  FAIL DETAIL: " & context
        Debug.Print "    Expected Serial=" & CStr(expectedSerial)
        Debug.Print "    Actual Serial  =" & CStr(actualSerial)
    End If

End Function

Private Function AssertUserConfigurationBlank(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal context As String) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim value As Variant

    columns = Array(KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT)

    For Each columnName In columns
        value = GetCellValue2(lo, rowIndex, CStr(columnName))
        If IsError(value) Or IsNull(value) Or Len(CStr(value)) <> 0 Then
            Debug.Print "  FAIL DETAIL: " & context & " " & CStr(columnName) & " is not blank."
            Debug.Print "    Actual=" & SafeVariantText(value)
            Exit Function
        End If
    Next columnName

    AssertUserConfigurationBlank = True

End Function

Private Function AssertUserConfigurationMatches(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal expected As Object, ByVal context As String) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim actual As Variant

    columns = Array(KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT)

    For Each columnName In columns
        actual = GetCellValue2(lo, rowIndex, CStr(columnName))
        If Not VariantsEqual(expected(CStr(columnName)), actual) Then
            Debug.Print "  FAIL DETAIL: " & context & " mismatch at " & CStr(columnName)
            Debug.Print "    Expected=" & SafeVariantText(expected(CStr(columnName)))
            Debug.Print "    Actual  =" & SafeVariantText(actual)
            Exit Function
        End If
    Next columnName

    AssertUserConfigurationMatches = True

End Function

Private Function AssertRowMatchesSnapshot(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal expected As Object, ByVal context As String) As Boolean

    Dim columns As Variant
    Dim columnName As Variant
    Dim actual As Variant

    columns = Array(KEY_VARIABLE_NAME, KEY_DISPLAY_NAME, KEY_TYPE, KEY_REQUIRED, KEY_DESCRIPTION, KEY_OPTION_SOURCE, KEY_SORT_ORDER, KEY_FORMAT, KEY_TEMPLATE_LOCATION, KEY_STATUS, KEY_FIRST_DETECTED_AT, KEY_LAST_DETECTED_AT)

    For Each columnName In columns
        actual = GetCellValue2(lo, rowIndex, CStr(columnName))
        If Not VariantsEqual(expected(CStr(columnName)), actual) Then
            Debug.Print "  FAIL DETAIL: " & context & " mismatch at " & CStr(columnName)
            Debug.Print "    Expected=" & SafeVariantText(expected(CStr(columnName)))
            Debug.Print "    Actual  =" & SafeVariantText(actual)
            Exit Function
        End If
    Next columnName

    AssertRowMatchesSnapshot = True

End Function

Private Function AssertTableMatchesSnapshot(ByVal lo As ListObject, ByVal expectedRows As Collection, ByVal context As String) As Boolean

    Dim i As Long
    Dim expectedRow As Object

    If lo.ListRows.Count <> expectedRows.Count Then
        Debug.Print "  FAIL DETAIL: " & context & " row count mismatch."
        Debug.Print "    Expected=" & CStr(expectedRows.Count)
        Debug.Print "    Actual  =" & CStr(lo.ListRows.Count)
        Exit Function
    End If

    For i = 1 To expectedRows.Count
        Set expectedRow = expectedRows(i)
        If Not AssertRowMatchesSnapshot(lo, i, expectedRow, context & " Row " & CStr(i)) Then Exit Function
    Next i

    AssertTableMatchesSnapshot = True

End Function

Private Function VariantsEqual(ByVal expected As Variant, ByVal actual As Variant) As Boolean

    If IsError(expected) Or IsError(actual) Then
        VariantsEqual = (IsError(expected) And IsError(actual))
        Exit Function
    End If

    If IsNull(expected) Or IsNull(actual) Then
        VariantsEqual = (IsNull(expected) And IsNull(actual))
        Exit Function
    End If

    If IsNumeric(expected) And IsNumeric(actual) Then
        VariantsEqual = (Abs(CDbl(expected) - CDbl(actual)) < 0.0000001)
        Exit Function
    End If

    VariantsEqual = (StrComp(CStr(expected), CStr(actual), vbBinaryCompare) = 0)

End Function

Private Function SafeVariantText(ByVal value As Variant) As String

    If IsError(value) Then
        SafeVariantText = "<Excel Error>"
    ElseIf IsNull(value) Then
        SafeVariantText = "<Null>"
    ElseIf IsEmpty(value) Then
        SafeVariantText = "<Empty>"
    Else
        SafeVariantText = CStr(value)
    End If

End Function

Private Sub PrintResultErrors(ByVal result As COperationResult)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

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

Private Sub RecordCaseResult(ByVal caseName As String, ByVal passed As Boolean)

    If passed Then
        mPassCount = mPassCount + 1
        Debug.Print caseName & ": PASS"
    Else
        mFailCount = mFailCount + 1
        Debug.Print caseName & ": FAIL"
    End If

End Sub
