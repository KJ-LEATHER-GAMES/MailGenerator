Attribute VB_Name = "modOutlookAdapter"
Option Explicit

' P1-02 Outlook Adapter.
' Outlook / Explorer / MailItem / WordEditor COM objects are kept inside this module.
'
' P1-02 v0.2:
' - Warm Start: reuse an existing Outlook Explorer.
' - Cold Start: create and display one Outlook Explorer before MailItem creation.
' - Do not display scan/error MailItems.
' - Do not close an Explorer after readiness succeeds.

Private Const ERROR_TYPE_TEMPLATE As String = "TemplateError"
Private Const ERROR_TYPE_OUTLOOK As String = "OutlookError"

Private Const TARGET_OUTLOOK_STARTUP As String = "OutlookStartup"
Private Const TARGET_OUTLOOK_EXPLORER As String = "OutlookExplorer"

Private Const OL_DISCARD As Long = 1
Private Const OL_FOLDER_INBOX As Long = 6
Private Const OL_FOLDER_DISPLAY_NORMAL As Long = 0

Private mOutlookApp As Object
Private mMailItem As Object

Public Function CreateMailFromTemplate( _
    ByVal templatePath As String _
) As COperationResult

    Dim readinessResult As COperationResult

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

    Set readinessResult = EnsureOutlookReady()

    If readinessResult Is Nothing Then
        Set CreateMailFromTemplate = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "Classic Outlook readiness did not return an operation result.", _
            TARGET_OUTLOOK_STARTUP)
        Exit Function
    End If

    If Not readinessResult.Success Then
        Set CreateMailFromTemplate = readinessResult
        Set readinessResult = Nothing
        Exit Function
    End If

    Set readinessResult = Nothing

    ' Intentionally pass the resolved path as-is.
    ' File existence / path resolution responsibility remains outside this module.
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
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set readinessResult = Nothing
    Set mMailItem = Nothing
    Set mOutlookApp = Nothing

    Set CreateMailFromTemplate = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "OFT could not be opened in Classic Outlook: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        templatePath)
End Function

Public Function ReadBodyText( _
    ByRef bodyText As String _
) As COperationResult

    Dim wordDocument As Object
    Dim bodyRange As Object
    Dim connectionResult As COperationResult

    bodyText = vbNullString
    On Error GoTo ErrorHandler

    Set connectionResult = TryGetWordDocument(mMailItem, wordDocument)

    If connectionResult Is Nothing Then
        Set ReadBodyText = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "WordEditor connection did not return an operation result.", _
            "ReadBodyText")
        GoTo CleanUp
    End If

    If Not connectionResult.Success Then
        Set ReadBodyText = connectionResult
        GoTo CleanUp
    End If

    Set bodyRange = wordDocument.Content

    If bodyRange Is Nothing Then
        Set ReadBodyText = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "The Word document body could not be obtained.", _
            "BodyText")
        GoTo CleanUp
    End If

    bodyText = CStr(bodyRange.Text)
    Set ReadBodyText = CreateSuccessResult()

CleanUp:
    Set bodyRange = Nothing
    Set wordDocument = Nothing
    Set connectionResult = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description
    bodyText = vbNullString

    Set ReadBodyText = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The Word document body could not be read: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        "BodyText")

    Resume CleanUp
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

Private Function EnsureOutlookReady() As COperationResult

    Dim outlookNamespace As Object
    Dim defaultFolder As Object
    Dim explorer As Object

    Dim explorerCount As Long
    Dim createdExplorer As Boolean
    Dim readinessSucceeded As Boolean

    Dim errorTarget As String
    Dim errorPrefix As String

    On Error GoTo ErrorHandler

    If mOutlookApp Is Nothing Then
        errorTarget = TARGET_OUTLOOK_STARTUP
        errorPrefix = "Unable to obtain or start Classic Outlook: "

        Set mOutlookApp = GetOutlookApplication()

        If mOutlookApp Is Nothing Then
            Set EnsureOutlookReady = CreateFailureResult( _
                ERROR_TYPE_OUTLOOK, _
                "Classic Outlook could not be obtained or started.", _
                TARGET_OUTLOOK_STARTUP)
            Exit Function
        End If
    End If

    errorTarget = TARGET_OUTLOOK_EXPLORER
    errorPrefix = "Unable to inspect Outlook Explorers: "

    explorerCount = CLng(mOutlookApp.Explorers.Count)

    If explorerCount > 0 Then
        readinessSucceeded = True
        Set EnsureOutlookReady = CreateSuccessResult()
        GoTo CleanUp
    End If

    errorTarget = TARGET_OUTLOOK_STARTUP
    errorPrefix = "Unable to access Outlook MAPI session: "

    Set outlookNamespace = mOutlookApp.GetNamespace("MAPI")

    If outlookNamespace Is Nothing Then
        Set EnsureOutlookReady = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "Classic Outlook MAPI session could not be obtained.", _
            TARGET_OUTLOOK_STARTUP)
        GoTo CleanUp
    End If

    errorTarget = TARGET_OUTLOOK_EXPLORER
    errorPrefix = "Unable to obtain the default Outlook folder: "

    Set defaultFolder = outlookNamespace.GetDefaultFolder(OL_FOLDER_INBOX)

    If defaultFolder Is Nothing Then
        Set EnsureOutlookReady = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "The default Outlook folder could not be obtained.", _
            TARGET_OUTLOOK_EXPLORER)
        GoTo CleanUp
    End If

    errorPrefix = "Unable to create an Outlook Explorer: "

    Set explorer = mOutlookApp.Explorers.Add( _
        defaultFolder, _
        OL_FOLDER_DISPLAY_NORMAL)

    If explorer Is Nothing Then
        Set EnsureOutlookReady = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "An Outlook Explorer could not be created.", _
            TARGET_OUTLOOK_EXPLORER)
        GoTo CleanUp
    End If

    createdExplorer = True

    errorPrefix = "Unable to display the Outlook Explorer: "
    explorer.Display

    ' TV-P1-02-001 established the production candidate with a visible
    ' Explorer and one event-pump opportunity. Do not use a fixed Sleep.
    DoEvents

    readinessSucceeded = True
    Set EnsureOutlookReady = CreateSuccessResult()

CleanUp:
    ' Never close an Explorer after readiness succeeds.
    ' If initialization failed after creating a new Explorer, close only
    ' that newly-created Explorer to avoid leaving a hidden/partial window.
    If createdExplorer And Not readinessSucceeded Then
        On Error Resume Next
        explorer.Close
        On Error GoTo 0
    End If

    Set explorer = Nothing
    Set defaultFolder = Nothing
    Set outlookNamespace = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    If createdExplorer And Not readinessSucceeded Then
        On Error Resume Next
        explorer.Close
        On Error GoTo 0
    End If

    Set explorer = Nothing
    Set defaultFolder = Nothing
    Set outlookNamespace = Nothing

    Set EnsureOutlookReady = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        errorPrefix & CStr(errorNumber) & " - " & errorDescription, _
        errorTarget)
End Function

Private Function TryGetWordDocument( _
    ByVal mailItem As Object, _
    ByRef wordDocument As Object _
) As COperationResult

    Dim inspector As Object
    Dim errorTarget As String
    Dim errorPrefix As String

    Set wordDocument = Nothing
    On Error GoTo ErrorHandler

    If mailItem Is Nothing Then
        Set TryGetWordDocument = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "There is no active MailItem to read.", _
            "MailItem")
        Exit Function
    End If

    errorTarget = "Inspector"
    errorPrefix = "Unable to access Outlook Inspector: "
    Set inspector = mailItem.GetInspector

    If inspector Is Nothing Then
        Set TryGetWordDocument = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "Unable to access Outlook Inspector.", _
            "Inspector")
        Exit Function
    End If

    errorTarget = "WordEditor"
    errorPrefix = "Unable to access WordEditor: "
    Set wordDocument = inspector.WordEditor

    If wordDocument Is Nothing Then
        Set inspector = Nothing
        Set TryGetWordDocument = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "WordEditor did not return a Word document.", _
            "WordEditor")
        Exit Function
    End If

    Set inspector = Nothing
    Set TryGetWordDocument = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set wordDocument = Nothing
    Set inspector = Nothing

    Set TryGetWordDocument = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        errorPrefix & CStr(errorNumber) & " - " & errorDescription, _
        errorTarget)
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
