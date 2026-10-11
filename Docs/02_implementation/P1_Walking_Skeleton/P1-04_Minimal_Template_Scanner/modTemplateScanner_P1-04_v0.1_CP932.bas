Attribute VB_Name = "modTemplateScanner"
Option Explicit

' P1-04 Minimal Template Scanner
'
' Input:
' - Subject As String
' - BodyText As String
'
' Output:
' - Lightweight Scripting.Dictionary
'   - ValidVariables    -> Collection
'   - InvalidCandidates -> Collection
'
' P1-04 intentionally does not implement Locations or Sync behavior.

Private Const ERROR_TYPE_UNEXPECTED As String = "UnexpectedError"
Private Const TARGET_TEMPLATE_SCANNER As String = "TemplateScanner"

Private Const KEY_VALID_VARIABLES As String = "ValidVariables"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Private Const PATTERN_CANDIDATE As String = "\{\{([^{}]*)\}\}"
Private Const PATTERN_VARIABLE_NAME As String = "^[A-Za-z][A-Za-z0-9_]*$"

Public Function ScanTemplate( _
    ByVal subjectText As String, _
    ByVal bodyText As String, _
    ByRef scanResult As Object _
) As COperationResult

    Dim validVariables As Collection
    Dim invalidCandidates As Collection
    Dim seenVariables As Object
    Dim resultDictionary As Object
    Dim stepResult As COperationResult

    Set scanResult = Nothing
    On Error GoTo ErrorHandler

    Set validVariables = New Collection
    Set invalidCandidates = New Collection

    Set seenVariables = CreateObject("Scripting.Dictionary")

    If seenVariables Is Nothing Then
        Set ScanTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template variable scanning could not be initialized.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    seenVariables.CompareMode = vbTextCompare

    Set stepResult = ScanText( _
        subjectText, _
        validVariables, _
        invalidCandidates, _
        seenVariables)

    If stepResult Is Nothing Then
        Set ScanTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Subject template scanning did not return an operation result.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanTemplate = stepResult
        GoTo CleanUp
    End If

    Set stepResult = Nothing

    Set stepResult = ScanText( _
        bodyText, _
        validVariables, _
        invalidCandidates, _
        seenVariables)

    If stepResult Is Nothing Then
        Set ScanTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Body template scanning did not return an operation result.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    If Not stepResult.Success Then
        Set ScanTemplate = stepResult
        GoTo CleanUp
    End If

    Set resultDictionary = CreateObject("Scripting.Dictionary")

    If resultDictionary Is Nothing Then
        Set ScanTemplate = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template scan result could not be created.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    resultDictionary.CompareMode = vbBinaryCompare
    resultDictionary.Add KEY_VALID_VARIABLES, validVariables
    resultDictionary.Add KEY_INVALID_CANDIDATES, invalidCandidates

    Set scanResult = resultDictionary
    Set ScanTemplate = CreateSuccessResult()

CleanUp:
    Set stepResult = Nothing
    Set resultDictionary = Nothing
    Set seenVariables = Nothing
    Set invalidCandidates = Nothing
    Set validVariables = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set scanResult = Nothing

    Set ScanTemplate = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Template variable scanning could not be completed: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_TEMPLATE_SCANNER)

    Resume CleanUp
End Function

Private Function ScanText( _
    ByVal sourceText As String, _
    ByRef validVariables As Collection, _
    ByRef invalidCandidates As Collection, _
    ByRef seenVariables As Object _
) As COperationResult

    Dim candidateRegex As Object
    Dim validationRegex As Object
    Dim matches As Object
    Dim match As Object

    Dim candidateText As String
    Dim variableName As String

    On Error GoTo ErrorHandler

    If validVariables Is Nothing Then
        Set ScanText = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Valid variable collection is not available.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    If invalidCandidates Is Nothing Then
        Set ScanText = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Invalid candidate collection is not available.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    If seenVariables Is Nothing Then
        Set ScanText = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Variable comparison state is not available.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    If Len(sourceText) = 0 Then
        Set ScanText = CreateSuccessResult()
        GoTo CleanUp
    End If

    Set candidateRegex = CreateObject("VBScript.RegExp")

    If candidateRegex Is Nothing Then
        Set ScanText = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Template candidate scanner could not be initialized.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    candidateRegex.Pattern = PATTERN_CANDIDATE
    candidateRegex.Global = True
    candidateRegex.IgnoreCase = False

    Set validationRegex = CreateObject("VBScript.RegExp")

    If validationRegex Is Nothing Then
        Set ScanText = CreateFailureResult( _
            ERROR_TYPE_UNEXPECTED, _
            "Variable name validator could not be initialized.", _
            TARGET_TEMPLATE_SCANNER)
        GoTo CleanUp
    End If

    validationRegex.Pattern = PATTERN_VARIABLE_NAME
    validationRegex.Global = False
    validationRegex.IgnoreCase = False

    Set matches = candidateRegex.Execute(sourceText)

    For Each match In matches
        candidateText = CStr(match.Value)
        variableName = CStr(match.SubMatches(0))

        If validationRegex.Test(variableName) Then

            If Not seenVariables.Exists(variableName) Then
                seenVariables.Add variableName, True
                validVariables.Add variableName
            End If

        Else
            ' Keep the raw {{...}} candidate.
            ' Duplicate representation is not a P1-04 public contract.
            invalidCandidates.Add candidateText
        End If
    Next match

    Set ScanText = CreateSuccessResult()

CleanUp:
    Set match = Nothing
    Set matches = Nothing
    Set validationRegex = Nothing
    Set candidateRegex = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set ScanText = CreateFailureResult( _
        ERROR_TYPE_UNEXPECTED, _
        "Template text scanning could not be completed: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_TEMPLATE_SCANNER)

    Resume CleanUp
End Function
