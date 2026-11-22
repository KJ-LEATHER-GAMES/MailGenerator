Attribute VB_Name = "modTESTONLY_DirectHide_Tests"
Option Explicit

' Test-only: modeless direct Hide MUST NOT be mistaken for QueryClose commit.
Public Sub RunTESTONLY_DirectHide_Test()
    Dim f As frmMailGenerator
    Dim stepResult As COperationResult
    Dim found As Boolean
    Dim storedText As String
    Dim passed As Boolean
    On Error GoTo TestFailed
    Set stepResult = ClearInputValues()
    If stepResult Is Nothing Then GoTo TestFailed
    If Not stepResult.Success Then GoTo TestFailed
    Set stepResult = SetInputValue("ModelName", "before")
    If stepResult Is Nothing Then GoTo TestFailed
    If Not stepResult.Success Then GoTo TestFailed
    ConfigureP304Stub "MIXED"
    Set stepResult = BuildMailGeneratorForm(f)
    If stepResult Is Nothing Then GoTo TestFailed
    If Not stepResult.Success Or f Is Nothing Then GoTo TestFailed
    f.Controls("fraInputArea").Controls("txtInput_0001").Value = "after"
    f.Show vbModeless
    f.Hide  ' Intentional forbidden call in TEST ONLY.
    Set stepResult = TryGetInputValue("ModelName", found, storedText)
    If stepResult Is Nothing Then GoTo TestFailed
    passed = (stepResult.Success And found And storedText = "before" And _
        Not f.InputCommitSucceeded)
    GoTo TestExit
TestFailed:
    passed = False
TestExit:
    Debug.Print "DIRECT-HIDE-001 Modeless external Hide: "; IIf(passed, "PASS", "FAIL")
    On Error Resume Next
    Set f = Nothing  ' Do not Unload here: Unload would exercise QueryClose.
    Set stepResult = ClearInputValues()
    On Error GoTo 0
End Sub
