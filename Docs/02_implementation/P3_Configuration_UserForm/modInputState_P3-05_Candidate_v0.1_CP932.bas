Attribute VB_Name = "modInputState"
Option Explicit

' P3-05 WORKING CANDIDATE / NOT PRODUCTION APPROVED.
' Workbook VBA-project lifetime only; nothing is written to worksheets or files.
' InputValue is the current raw UI text, not a typed/validated business value.
' Case-insensitive keys follow Design v0.1.10 section 18.2.
' The UserForm controls and their Clear/Restore events are separate work.

Private Const ERROR_CONFIGURATION As String = "ConfigurationError"
Private Const ERROR_UNEXPECTED As String = "UnexpectedError"
Private Const TARGET_INPUT_STATE As String = "InputState"
Private Const TARGET_VARIABLE_NAME As String = "InputState.VariableName"

Private mInputValues As Object

' Save a raw text value. An explicit empty string is a stored value.
' Control.Tag supplies VariableName; this module never interprets Type/Required.
Public Function SetInputValue( _
    ByVal variableName As String, _
    ByVal inputText As String _
) As COperationResult

    Dim stepResult As COperationResult

    On Error GoTo UnexpectedFailure

    If Len(Trim$(variableName)) = 0 Then
        Set SetInputValue = InvalidVariableName()
        Exit Function
    End If

    Set stepResult = EnsureInputStore()
    If Not stepResult.Success Then
        Set SetInputValue = stepResult
        Exit Function
    End If

    If mInputValues.Exists(variableName) Then
        mInputValues.Item(variableName) = inputText
    Else
        mInputValues.Add variableName, inputText
    End If

    Set SetInputValue = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    Set SetInputValue = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "The input value could not be stored.", _
        TARGET_INPUT_STATE)
End Function

' Distinguish an absent key from a stored empty string with hasValue.
' On failure or not-found: hasValue=False, inputText="".
Public Function TryGetInputValue( _
    ByVal variableName As String, _
    ByRef hasValue As Boolean, _
    ByRef inputText As String _
) As COperationResult

    Dim stepResult As COperationResult

    hasValue = False
    inputText = vbNullString

    On Error GoTo UnexpectedFailure

    If Len(Trim$(variableName)) = 0 Then
        Set TryGetInputValue = InvalidVariableName()
        Exit Function
    End If

    Set stepResult = EnsureInputStore()
    If Not stepResult.Success Then
        Set TryGetInputValue = stepResult
        Exit Function
    End If

    If mInputValues.Exists(variableName) Then
        inputText = CStr(mInputValues.Item(variableName))
        hasValue = True
    End If

    Set TryGetInputValue = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    hasValue = False
    inputText = vbNullString
    Set TryGetInputValue = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "The input value could not be read.", _
        TARGET_INPUT_STATE)
End Function

' Clear the in-memory dictionary only. The UI must clear visible controls too.
Public Function ClearInputValues() As COperationResult

    On Error GoTo UnexpectedFailure

    If Not mInputValues Is Nothing Then
        mInputValues.RemoveAll
    End If

    Set ClearInputValues = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    Set ClearInputValues = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Stored input values could not be cleared.", _
        TARGET_INPUT_STATE)
End Function

Private Function EnsureInputStore() As COperationResult
    Dim candidate As Object

    On Error GoTo UnexpectedFailure

    If mInputValues Is Nothing Then
        Set candidate = CreateObject("Scripting.Dictionary")
        If candidate Is Nothing Then GoTo UnexpectedFailure
        candidate.CompareMode = vbTextCompare
        Set mInputValues = candidate
    End If

    Set EnsureInputStore = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    Set EnsureInputStore = CreateFailureResult( _
        ERROR_UNEXPECTED, _
        "Input State could not be initialized.", _
        TARGET_INPUT_STATE)
End Function

Private Function InvalidVariableName() As COperationResult
    Set InvalidVariableName = CreateFailureResult( _
        ERROR_CONFIGURATION, _
        "VariableName is required to access Input State.", _
        TARGET_VARIABLE_NAME)
End Function
