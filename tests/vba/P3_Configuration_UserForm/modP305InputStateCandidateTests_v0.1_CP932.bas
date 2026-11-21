Attribute VB_Name = "modP305InputStateCandidateTests"
Option Explicit

' P3-05 isolated unit-test fixture. Requires actual P0 modResult,
' COperationResult and CErrorInfo plus candidate modInputState.
' No Outlook, Excel ListObject, UserForm or replacement stubs.
' Run manually in a disposable VBA project only when authorized.
' This source has NOT been executed or compiled.

Private mPass As Long
Private mFail As Long

Public Sub RunP305InputStateCandidateTests()
    Dim result As COperationResult
    Dim hasValue As Boolean
    Dim textValue As String
    Dim ok As Boolean

    mPass = 0
    mFail = 0
    On Error GoTo TestHarnessFailure

    ' C01: cold store is empty.
    Set result = ClearInputValues()
    ok = IsGood(result)
    hasValue = True
    textValue = "stale"
    Set result = TryGetInputValue("ModelName", hasValue, textValue)
    RecordCase "P305-C01_EMPTY_STORE", ok And IsGood(result) And _
        (Not hasValue) And textValue = vbNullString

    ' C02: normal set/read.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", "Model-X"))
    Set result = TryGetInputValue("ModelName", hasValue, textValue)
    RecordCase "P305-C02_SAVE_READ", ok And IsGood(result) And _
        hasValue And textValue = "Model-X"

    ' C03: identity is case-insensitive.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", "A"))
    Set result = TryGetInputValue("modelname", hasValue, textValue)
    RecordCase "P305-C03_CASE_INSENSITIVE", ok And IsGood(result) And _
        hasValue And textValue = "A"

    ' C04: differently-cased save overwrites one logical key.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", "old"))
    ok = ok And IsGood(SetInputValue("MODELNAME", "new"))
    Set result = TryGetInputValue("modelname", hasValue, textValue)
    RecordCase "P305-C04_OVERWRITE_CASE", ok And IsGood(result) And _
        hasValue And textValue = "new"

    ' C05: stored blank and absent are different states.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", vbNullString))
    Set result = TryGetInputValue("ModelName", hasValue, textValue)
    ok = ok And IsGood(result) And hasValue And textValue = vbNullString
    Set result = TryGetInputValue("UnknownName", hasValue, textValue)
    RecordCase "P305-C05_EMPTY_VS_ABSENT", ok And IsGood(result) And _
        (Not hasValue) And textValue = vbNullString

    ' C06: numeric-looking UI text remains text.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", "0"))
    Set result = TryGetInputValue("ModelName", hasValue, textValue)
    RecordCase "P305-C06_ZERO_TEXT", ok And IsGood(result) And _
        hasValue And textValue = "0"

    ' C07: false-looking UI text remains text.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("ModelName", "False"))
    Set result = TryGetInputValue("ModelName", hasValue, textValue)
    RecordCase "P305-C07_FALSE_TEXT", ok And IsGood(result) And _
        hasValue And textValue = "False"

    ' C08: CP932 Japanese characters survive round-trip.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Department", "ê›åvïî"))
    Set result = TryGetInputValue("Department", hasValue, textValue)
    RecordCase "P305-C08_JAPANESE_TEXT", ok And IsGood(result) And _
        hasValue And textValue = "ê›åvïî"

    ' C09: preserve raw spacing; Input Validator handles semantics later.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Owner", "  A B  "))
    Set result = TryGetInputValue("Owner", hasValue, textValue)
    RecordCase "P305-C09_SPACES_PRESERVED", ok And IsGood(result) And _
        hasValue And textValue = "  A B  "

    ' C10: entries do not overwrite one another.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Owner", "Alice"))
    ok = ok And IsGood(SetInputValue("Department", "QA"))
    Set result = TryGetInputValue("Owner", hasValue, textValue)
    ok = ok And IsGood(result) And hasValue And textValue = "Alice"
    Set result = TryGetInputValue("Department", hasValue, textValue)
    RecordCase "P305-C10_MULTI_KEY", ok And IsGood(result) And _
        hasValue And textValue = "QA"

    ' C11: clear removes all saved values.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Owner", "Alice"))
    ok = ok And IsGood(SetInputValue("Department", "QA"))
    ok = ok And IsGood(ClearInputValues())
    Set result = TryGetInputValue("Owner", hasValue, textValue)
    ok = ok And IsGood(result) And Not hasValue
    Set result = TryGetInputValue("Department", hasValue, textValue)
    RecordCase "P305-C11_CLEAR_ALL", ok And IsGood(result) And Not hasValue

    ' C12: clearing an empty state is a no-op success.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(ClearInputValues())
    RecordCase "P305-C12_CLEAR_IDEMPOTENT", ok

    ' C13: reject an empty key, never create an anonymous entry.
    Set result = ClearInputValues()
    ok = IsGood(result)
    Set result = SetInputValue(vbNullString, "value")
    RecordCase "P305-C13_REJECT_EMPTY_KEY", ok And IsBadType(result, "ConfigurationError")

    ' C14: reject an all-space key.
    Set result = SetInputValue("   ", "value")
    RecordCase "P305-C14_REJECT_BLANK_KEY", IsBadType(result, "ConfigurationError")

    ' C15: get failure clears ByRef output parameters.
    hasValue = True
    textValue = "stale"
    Set result = TryGetInputValue(vbNullString, hasValue, textValue)
    RecordCase "P305-C15_GET_OUTPUT_RESET", _
        IsBadType(result, "ConfigurationError") And (Not hasValue) And _
        textValue = vbNullString

    ' C16: store remains reusable after clear.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Owner", "first"))
    ok = ok And IsGood(ClearInputValues())
    ok = ok And IsGood(SetInputValue("Owner", "second"))
    Set result = TryGetInputValue("Owner", hasValue, textValue)
    RecordCase "P305-C16_REUSE_AFTER_CLEAR", ok And IsGood(result) And _
        hasValue And textValue = "second"

    ' C17: rejected set must not remove an earlier valid value.
    Set result = ClearInputValues()
    ok = IsGood(result) And IsGood(SetInputValue("Owner", "stable"))
    Set result = SetInputValue(vbNullString, "bad")
    ok = ok And IsBadType(result, "ConfigurationError")
    Set result = TryGetInputValue("Owner", hasValue, textValue)
    RecordCase "P305-C17_FAILED_SET_NONMUTATION", ok And IsGood(result) And _
        hasValue And textValue = "stable"

    ' C18: missing lookup returns Success with found=False.
    Set result = ClearInputValues()
    ok = IsGood(result)
    hasValue = True
    textValue = "stale"
    Set result = TryGetInputValue("NotPresent", hasValue, textValue)
    RecordCase "P305-C18_ABSENT_SUCCESS", ok And IsGood(result) And _
        Not hasValue And textValue = vbNullString

    Debug.Print "P3-05 Candidate Tests: PASS=" & mPass & "; FAIL=" & mFail
    Exit Sub

TestHarnessFailure:
    mFail = mFail + 1
    Debug.Print "P3-05 TEST HARNESS ERROR: " & CStr(Err.Number) & _
        " - " & Err.Description
    Debug.Print "P3-05 Candidate Tests: PASS=" & mPass & "; FAIL=" & mFail
End Sub

Private Function IsGood(ByVal result As COperationResult) As Boolean
    If result Is Nothing Then Exit Function
    IsGood = result.Success
End Function

Private Function IsBadType( _
    ByVal result As COperationResult, _
    ByVal expectedErrorType As String _
) As Boolean
    Dim errors As Collection
    Dim firstError As CErrorInfo

    If result Is Nothing Then Exit Function
    If result.Success Then Exit Function
    Set errors = result.Errors
    If errors Is Nothing Then Exit Function
    If errors.Count = 0 Then Exit Function
    Set firstError = errors(1)
    If firstError Is Nothing Then Exit Function
    IsBadType = (firstError.ErrorType = expectedErrorType)
End Function

Private Sub RecordCase(ByVal caseId As String, ByVal passed As Boolean)
    If passed Then
        mPass = mPass + 1
        Debug.Print caseId & " PASS"
    Else
        mFail = mFail + 1
        Debug.Print caseId & " FAIL"
    End If
End Sub
