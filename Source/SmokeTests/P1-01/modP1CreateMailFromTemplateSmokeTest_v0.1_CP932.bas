Attribute VB_Name = "modP1CreateMailFromTemplateSmokeTest"
Option Explicit

' P1-01 control test:
' Verify only whether modOutlookAdapter.CreateMailFromTemplate
' can open an OFT by using a local Windows file-system path.
'
' CloseWithoutSave is used only for cleanup after a successful create.
' Its result does not affect the PASS / FAIL judgment of this test.

Private Const TEST_TEMPLATE_PATH As String = _
    "C:\Users\monsi\OneDrive\ÉhÉLÉÖÉÅÉìÉg\MailGenerator\Templates\MailTemplate.oft"

Public Sub TestCreateMailFromTemplateLocalPath()

    Dim result As COperationResult
    Dim cleanupResult As COperationResult
    Dim createPassed As Boolean

    On Error GoTo UnexpectedFailure

    Debug.Print "TestCreateMailFromTemplateLocalPath: START"
    Debug.Print "TemplatePath: " & TEST_TEMPLATE_PATH

    Set result = modOutlookAdapter.CreateMailFromTemplate(TEST_TEMPLATE_PATH)

    If result Is Nothing Then
        Debug.Print "CreateMailFromTemplate: FAIL"
        Debug.Print "  Result is Nothing."
        GoTo TestFinished
    End If

    If Not result.Success Then
        Debug.Print "CreateMailFromTemplate: FAIL"
        PrintResultErrors result
        GoTo TestFinished
    End If

    createPassed = True
    Debug.Print "CreateMailFromTemplate: PASS"

Cleanup:
    ' Cleanup only. This is not part of the CreateMailFromTemplate judgment.
    If createPassed Then
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()

        If cleanupResult Is Nothing Then
            Debug.Print "Cleanup CloseWithoutSave: WARNING"
            Debug.Print "  Result is Nothing."
        ElseIf cleanupResult.Success Then
            Debug.Print "Cleanup CloseWithoutSave: PASS"
        Else
            Debug.Print "Cleanup CloseWithoutSave: WARNING"
            PrintResultErrors cleanupResult
        End If
    End If

TestFinished:
    If createPassed Then
        Debug.Print "TestCreateMailFromTemplateLocalPath: PASS"
    Else
        Debug.Print "TestCreateMailFromTemplateLocalPath: FAIL"
    End If

    Exit Sub

UnexpectedFailure:
    Debug.Print "TestCreateMailFromTemplateLocalPath: FAIL"
    Debug.Print "  Unexpected VBA runtime error."
    Debug.Print "  Err.Number=" & CStr(Err.Number)
    Debug.Print "  Err.Description=" & Err.Description

    On Error Resume Next
    If createPassed Then
        Set cleanupResult = modOutlookAdapter.CloseWithoutSave()
    End If
    On Error GoTo 0
End Sub

Private Sub PrintResultErrors(ByVal result As COperationResult)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim i As Long

    If result Is Nothing Then Exit Sub

    Set errors = result.Errors

    For i = 1 To errors.Count
        Set errorInfo = errors(i)

        Debug.Print "  ErrorType=" & errorInfo.ErrorType
        Debug.Print "  Message=" & errorInfo.Message
        Debug.Print "  Target=" & errorInfo.Target
    Next i
End Sub
