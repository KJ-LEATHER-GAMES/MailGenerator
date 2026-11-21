Attribute VB_Name = "modP3UserFormController"
Option Explicit

' P3-04 WORKING CANDIDATE. Do not overwrite P2-05 modUiController.
' Only the P3-03 successful Gate may produce a form instance.
' UI errors remain a COperationResult for the future caller to present.
Private Const ERR_UNEXPECTED As String = "UnexpectedError"

Public Function BuildMailGeneratorForm( _
    ByRef candidateForm As frmMailGenerator _
) As COperationResult
    Dim sortedDefinitions As Collection
    Dim optionGroups As Object
    Dim stepResult As COperationResult
    Dim localForm As frmMailGenerator

    Set candidateForm = Nothing
    On Error GoTo UnexpectedFailure

    Set stepResult = PrepareUserFormLaunch(sortedDefinitions, optionGroups)
    If stepResult Is Nothing Then
        Set BuildMailGeneratorForm = MissingCarrier("UserFormLaunchGate.Result")
        Exit Function
    End If
    If Not stepResult.Success Then
        ' Preserve upstream Result; do not initialize a UserForm.
        Set BuildMailGeneratorForm = stepResult
        Exit Function
    End If
    If sortedDefinitions Is Nothing Or optionGroups Is Nothing Then
        Set BuildMailGeneratorForm = MissingCarrier("UserFormLaunchGate.Outputs")
        Exit Function
    End If
    If TypeName(optionGroups) <> "Dictionary" Then
        Set BuildMailGeneratorForm = MissingCarrier("ActiveOptionsByGroup")
        Exit Function
    End If

    ' New UserForm is created ONLY AFTER successful Gate and output checks.
    Set localForm = New frmMailGenerator
    Set stepResult = localForm.BuildValidatedInputs(sortedDefinitions, optionGroups)
    If stepResult Is Nothing Then
        Set BuildMailGeneratorForm = MissingCarrier("frmMailGenerator.BuildResult")
        GoTo BuildFailed
    End If
    If Not stepResult.Success Then
        Set BuildMailGeneratorForm = stepResult
        GoTo BuildFailed
    End If

    Set candidateForm = localForm
    Set BuildMailGeneratorForm = stepResult
    Exit Function

BuildFailed:
    If Not localForm Is Nothing Then Unload localForm
    Set localForm = Nothing
    Exit Function

UnexpectedFailure:
    Set candidateForm = Nothing
    On Error Resume Next
    If Not localForm Is Nothing Then Unload localForm
    On Error GoTo 0
    Set BuildMailGeneratorForm = MissingCarrier("P3UserFormController")
End Function

Public Function ShowMailGeneratorForm() As COperationResult
    Dim newForm As frmMailGenerator
    Dim stepResult As COperationResult
    On Error GoTo UnexpectedFailure

    Set stepResult = BuildMailGeneratorForm(newForm)
    If stepResult Is Nothing Then
        Set ShowMailGeneratorForm = MissingCarrier("UserForm.BuildResult")
        Exit Function
    End If
    If Not stepResult.Success Then
        Set ShowMailGeneratorForm = stepResult
        Exit Function
    End If
    If newForm Is Nothing Then
        Set ShowMailGeneratorForm = MissingCarrier("frmMailGenerator")
        Exit Function
    End If

    ' No Input State restore, mail generation, or Clear handlers in P3-04.
    newForm.Show vbModal
    Unload newForm
    Set newForm = Nothing
    Set ShowMailGeneratorForm = CreateSuccessResult()
    Exit Function

UnexpectedFailure:
    On Error Resume Next
    If Not newForm Is Nothing Then Unload newForm
    Set newForm = Nothing
    On Error GoTo 0
    Set ShowMailGeneratorForm = MissingCarrier("frmMailGenerator.Show")
End Function

Private Function MissingCarrier(ByVal target As String) As COperationResult
    Set MissingCarrier = CreateFailureResult( _
        ERR_UNEXPECTED, "The UserForm launch could not be completed.", target)
End Function
