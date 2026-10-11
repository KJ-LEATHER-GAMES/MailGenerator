Attribute VB_Name = "modSubjectRenderer"
Option Explicit

' P1-05 Minimal Subject Renderer
'
' Responsibility:
' - Plain-text Subject rendering only.
' - formattedValues is a late-bound Scripting.Dictionary.
' - Key   : VariableName without {{ }}
' - Value : already-formatted String
'
' Explicitly out of scope:
' - Outlook / Word COM access
' - Input validation / value formatting
' - Unresolved-variable checking
' - Display / MailItem lifecycle

Private Const ERROR_TYPE_RENDER As String = "RenderError"
Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"

Private Const TARGET_SUBJECT_RENDER As String = "SubjectRender"

Public Function RenderSubject( _
    ByVal subjectText As String, _
    ByVal formattedValues As Object, _
    ByRef renderedSubject As String _
) As COperationResult

    Dim validationResult As COperationResult
    Dim key As Variant
    Dim variableName As String
    Dim replacement As String
    Dim token As String
    Dim workingSubject As String

    renderedSubject = vbNullString
    On Error GoTo ErrorHandler

    Set validationResult = ValidateFormattedValues( _
        formattedValues, _
        TARGET_SUBJECT_RENDER)

    If validationResult Is Nothing Then
        Set RenderSubject = CreateFailureResult( _
            ERROR_TYPE_RENDER, _
            "Formatted values validation did not return an operation result.", _
            TARGET_SUBJECT_RENDER)
        GoTo CleanUp
    End If

    If Not validationResult.Success Then
        Set RenderSubject = validationResult
        GoTo CleanUp
    End If

    Set validationResult = Nothing
    workingSubject = subjectText

    For Each key In formattedValues.Keys
        variableName = CStr(key)
        replacement = CStr(formattedValues.Item(key))
        token = "{{" & variableName & "}}"

        workingSubject = Replace( _
            workingSubject, _
            token, _
            replacement, _
            1, _
            -1, _
            vbTextCompare)
    Next key

    renderedSubject = workingSubject
    Set RenderSubject = CreateSuccessResult()

CleanUp:
    Set validationResult = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    renderedSubject = vbNullString

    Set RenderSubject = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "The mail subject could not be rendered: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_SUBJECT_RENDER)

    Resume CleanUp
End Function

Private Function ValidateFormattedValues( _
    ByVal formattedValues As Object, _
    ByVal target As String _
) As COperationResult

    Dim key As Variant

    On Error GoTo ErrorHandler

    If formattedValues Is Nothing Then
        Set ValidateFormattedValues = CreateFailureResult( _
            ERROR_TYPE_RENDER, _
            "Formatted values are not available.", _
            target)
        Exit Function
    End If

    If StrComp(TypeName(formattedValues), "Dictionary", vbTextCompare) <> 0 Then
        Set ValidateFormattedValues = CreateFailureResult( _
            ERROR_TYPE_RENDER, _
            "Formatted values must be provided as a Scripting.Dictionary.", _
            target)
        Exit Function
    End If

    For Each key In formattedValues.Keys
        If VarType(key) <> vbString Then
            Set ValidateFormattedValues = CreateFailureResult( _
                ERROR_TYPE_RENDER, _
                "Formatted values contain a non-string variable name.", _
                target)
            Exit Function
        End If

        If Len(CStr(key)) = 0 Then
            Set ValidateFormattedValues = CreateFailureResult( _
                ERROR_TYPE_RENDER, _
                "Formatted values contain an empty variable name.", _
                target)
            Exit Function
        End If

        If VarType(formattedValues.Item(key)) <> vbString Then
            Set ValidateFormattedValues = CreateFailureResult( _
                ERROR_TYPE_RENDER, _
                "Formatted values contain a non-string replacement value.", _
                CStr(key))
            Exit Function
        End If
    Next key

    Set ValidateFormattedValues = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set ValidateFormattedValues = CreateFailureResult( _
        ERROR_TYPE_RENDER, _
        "Formatted values could not be validated.", _
        target)
End Function
