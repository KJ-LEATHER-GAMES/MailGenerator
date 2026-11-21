Attribute VB_Name = "modP305FaultInjectionStub"
Option Explicit

' TEST-ONLY REPLACEMENT for modInputState. Never import alongside REAL P3-05.
' Exposes exactly the 3 approved APIs, plus TEST-only scenario controls.
Public FIStore As Object
Public FIGetCalls As Long
Public FISetCalls As Long
Public FIClearCalls As Long
Public FIFailGetAt As Long
Public FIReturnNilGetAt As Long
Public FIFailSetAt As Long
Public FIReturnNilSetAt As Long
Public FIFailClear As Boolean
Public FIReturnNilClear As Boolean

Public Sub ConfigureP305Faults()
    Set FIStore = CreateObject("Scripting.Dictionary")
    FIStore.CompareMode = vbTextCompare
    FIGetCalls = 0
    FISetCalls = 0
    FIClearCalls = 0
    FIFailGetAt = 0
    FIReturnNilGetAt = 0
    FIFailSetAt = 0
    FIReturnNilSetAt = 0
    FIFailClear = False
    FIReturnNilClear = False
End Sub

Public Function TryGetInputValue( _
    ByVal variableName As String, _
    ByRef hasValue As Boolean, _
    ByRef inputText As String _
) As COperationResult
    hasValue = False
    inputText = vbNullString
    FIGetCalls = FIGetCalls + 1
    If FIGetCalls = FIReturnNilGetAt Then Exit Function
    If FIGetCalls = FIFailGetAt Then
        Set TryGetInputValue = CreateFailureResult("UnexpectedError", "Injected get failure", variableName)
        Exit Function
    End If
    If FIStore.Exists(variableName) Then
        hasValue = True
        inputText = CStr(FIStore(variableName))
    End If
    Set TryGetInputValue = CreateSuccessResult()
End Function

Public Function SetInputValue( _
    ByVal variableName As String, _
    ByVal inputText As String _
) As COperationResult
    FISetCalls = FISetCalls + 1
    If FISetCalls = FIReturnNilSetAt Then Exit Function
    If FISetCalls = FIFailSetAt Then
        Set SetInputValue = CreateFailureResult("UnexpectedError", "Injected set failure", variableName)
        Exit Function
    End If
    FIStore(variableName) = inputText
    Set SetInputValue = CreateSuccessResult()
End Function

Public Function ClearInputValues() As COperationResult
    FIClearCalls = FIClearCalls + 1
    If FIReturnNilClear Then Exit Function
    If FIFailClear Then
        Set ClearInputValues = CreateFailureResult("UnexpectedError", "Injected clear failure", "InputState")
        Exit Function
    End If
    FIStore.RemoveAll
    Set ClearInputValues = CreateSuccessResult()
End Function