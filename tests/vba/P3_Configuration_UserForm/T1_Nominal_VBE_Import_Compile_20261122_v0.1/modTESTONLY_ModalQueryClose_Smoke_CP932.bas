Attribute VB_Name = "modTESTONLY_ModalQueryClose_Smoke"
Option Explicit

' In a separate T1 test workbook only: type QC-OK into the first field,
' then click X. This tests the actual Show->QueryClose->Hide->Unload route.
Public Sub RunTESTONLY_ModalQueryClose_Smoke()
    Dim stepResult As COperationResult
    Dim found As Boolean
    Dim textValue As String
    Dim passed As Boolean
    On Error GoTo Failed
    Set stepResult = ClearInputValues()
    If stepResult Is Nothing Then GoTo Failed
    If Not stepResult.Success Then GoTo Failed
    ConfigureP304Stub "MIXED"
    MsgBox "In the next form, enter QC-OK in the first input and click X.", vbInformation
    Set stepResult = ShowMailGeneratorForm()
    If stepResult Is Nothing Then GoTo Failed
    If Not stepResult.Success Then GoTo Failed
    Set stepResult = TryGetInputValue("ModelName", found, textValue)
    If stepResult Is Nothing Then GoTo Failed
    passed = (stepResult.Success And found And textValue = "QC-OK")
    GoTo Report
Failed:
    passed = False
Report:
    Debug.Print "QC-MODAL-001 Real X/QueryClose route: "; IIf(passed, "PASS", "FAIL")
    On Error Resume Next
    Set stepResult = ClearInputValues()
    On Error GoTo 0
End Sub
