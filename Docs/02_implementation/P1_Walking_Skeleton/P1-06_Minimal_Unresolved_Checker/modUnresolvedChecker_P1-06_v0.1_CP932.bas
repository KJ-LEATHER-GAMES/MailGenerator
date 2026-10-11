Attribute VB_Name = "modUnresolvedChecker"
Option Explicit

Private Const KEY_HAS_UNRESOLVED As String = "HasUnresolved"
Private Const KEY_VARIABLES As String = "Variables"

Private Const ERROR_TYPE_P1_INTERIM As String = "RenderError"
Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"
Private Const ERROR_TARGET_UNRESOLVED As String = "UnresolvedVariables"
Private Const ERROR_TARGET_CHECKER As String = "UnresolvedChecker"

Private Const TOKEN_PATTERN As String = "\{\{([A-Za-z][A-Za-z0-9_]*)\}\}"

Public Function CheckUnresolved( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef unresolvedResult As Object _
) As COperationResult

    Dim resultCarrier As Object
    Dim variables As Collection
    Dim seenVariables As Object
    Dim regex As Object
    Dim hasUnresolved As Boolean

    Set unresolvedResult = Nothing

    On Error GoTo UnexpectedError

    Set resultCarrier = CreateObject("Scripting.Dictionary")
    resultCarrier.CompareMode = vbTextCompare

    Set variables = New Collection

    Set seenVariables = CreateObject("Scripting.Dictionary")
    seenVariables.CompareMode = vbTextCompare

    Set regex = CreateObject("VBScript.RegExp")
    regex.Global = True
    regex.IgnoreCase = True
    regex.Pattern = TOKEN_PATTERN

    AddUnresolvedFromText _
        subjectText, _
        regex, _
        seenVariables, _
        variables

    AddUnresolvedFromText _
        bodyText, _
        regex, _
        seenVariables, _
        variables

    hasUnresolved = (variables.Count > 0)

    resultCarrier.Add KEY_HAS_UNRESOLVED, hasUnresolved
    resultCarrier.Add KEY_VARIABLES, variables

    Set unresolvedResult = resultCarrier

    If hasUnresolved Then

        ' P1 Interim Mapping only.
        ' Formal Unresolved Error classification is finalized in P6.
        Set CheckUnresolved = CreateFailureResult( _
            ERROR_TYPE_P1_INTERIM, _
            "Unresolved variables remain after rendering.", _
            ERROR_TARGET_UNRESOLVED)

        Exit Function
    End If

    Set CheckUnresolved = CreateSuccessResult()
    Exit Function

UnexpectedError:
    Set unresolvedResult = Nothing

    Set CheckUnresolved = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Unable to check unresolved variables.", _
        ERROR_TARGET_CHECKER)

End Function

Private Sub AddUnresolvedFromText( _
    ByVal sourceText As String, _
    ByVal regex As Object, _
    ByVal seenVariables As Object, _
    ByVal variables As Collection _
)

    Dim matches As Object
    Dim currentMatch As Object
    Dim variableName As String

    Set matches = regex.Execute(sourceText)

    For Each currentMatch In matches

        variableName = CStr(currentMatch.SubMatches(0))

        If Not seenVariables.Exists(variableName) Then
            seenVariables.Add variableName, True
            variables.Add variableName
        End If

    Next currentMatch

End Sub
