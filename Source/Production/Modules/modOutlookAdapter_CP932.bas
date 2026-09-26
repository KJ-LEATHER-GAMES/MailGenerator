Attribute VB_Name = "modOutlookAdapter"
Option Explicit

' P1-01 minimum Outlook Adapter.
' Outlook / MailItem COM objects are kept inside this module.

Private Const ERROR_TYPE_TEMPLATE As String = "TemplateError"
Private Const ERROR_TYPE_OUTLOOK As String = "OutlookError"
Private Const TARGET_OUTLOOK As String = "Classic Outlook"
Private Const OL_DISCARD As Long = 1

Private mOutlookApp As Object
Private mMailItem As Object

Public Function CreateMailFromTemplate( _
    ByVal templatePath As String _
) As COperationResult

    On Error GoTo ErrorHandler

    If Len(Trim$(templatePath)) = 0 Then
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_TEMPLATE, _
            "OFT TemplatePath is empty.", _
            "TemplatePath")
        Exit Function
    End If

    If Not mMailItem Is Nothing Then
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "A MailItem is already active in Outlook Adapter.", _
            templatePath)
        Exit Function
    End If

    Set mOutlookApp = GetOutlookApplication()

    If mOutlookApp Is Nothing Then
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "Classic Outlook could not be obtained or started.", _
            TARGET_OUTLOOK)
        Exit Function
    End If

    ' Intentionally pass the resolved path as-is.
    ' Do not pre-check with Dir/FileSystemObject in P1-01.
    Set mMailItem = mOutlookApp.CreateItemFromTemplate(templatePath)

    If mMailItem Is Nothing Then
        Set mOutlookApp = Nothing
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "OFT could not be opened as a MailItem.", _
            templatePath)
        Exit Function
    End If

    If StrComp(TypeName(mMailItem), "MailItem", vbTextCompare) <> 0 Then
        Set mMailItem = Nothing
        Set mOutlookApp = Nothing
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "The object created from the OFT is not a MailItem.", _
            templatePath)
        Exit Function
    End If

    Set CreateMailFromTemplate = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Set mMailItem = Nothing
    Set mOutlookApp = Nothing

    Set CreateMailFromTemplate = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "OFT could not be opened in Classic Outlook: " & _
            CStr(Err.Number) & " - " & Err.Description, _
        templatePath)
End Function

Public Function CloseWithoutSave() As COperationResult
    On Error GoTo ErrorHandler

    If mMailItem Is Nothing Then
        Set mOutlookApp = Nothing
        Set CloseWithoutSave = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "There is no active MailItem to close.", _
            "MailItem")
        Exit Function
    End If

    mMailItem.Close OL_DISCARD

    Set mMailItem = Nothing
    Set mOutlookApp = Nothing

    Set CloseWithoutSave = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    On Error Resume Next
    If Not mMailItem Is Nothing Then mMailItem.Close OL_DISCARD
    On Error GoTo 0

    Set mMailItem = Nothing
    Set mOutlookApp = Nothing

    Set CloseWithoutSave = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The MailItem could not be closed without saving: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        "MailItem")
End Function

Private Function GetOutlookApplication() As Object
    Dim app As Object

    On Error Resume Next
    Set app = GetObject(, "Outlook.Application")
    On Error GoTo 0

    If app Is Nothing Then
        On Error Resume Next
        Set app = CreateObject("Outlook.Application")
        On Error GoTo 0
    End If

    Set GetOutlookApplication = app
End Function
