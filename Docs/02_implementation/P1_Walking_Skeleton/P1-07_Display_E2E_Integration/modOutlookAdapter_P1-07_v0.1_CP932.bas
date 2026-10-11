Attribute VB_Name = "modOutlookAdapter"
Option Explicit

' P1-07 Outlook Adapter
'
' Established boundaries retained:
' - P1-02 Classic Outlook Warm / Cold Start readiness
' - P1-02 WordEditor connection
' - P1-03 ReadSubject / ReadBodyText snapshot boundary
' - P1-05 SetSubject / ReplaceBodyVariables
'
' P1-07 addition:
' - DisplayMail
'
' Outlook / Explorer / MailItem / WordEditor / Word Document / Word Range
' COM objects remain inside this module.

Private Const ERROR_TYPE_TEMPLATE As String = "TemplateError"
Private Const ERROR_TYPE_OUTLOOK As String = "OutlookError"
Private Const ERROR_TYPE_RENDER As String = "RenderError"

Private Const TARGET_OUTLOOK_STARTUP As String = "OutlookStartup"
Private Const TARGET_OUTLOOK_EXPLORER As String = "OutlookExplorer"
Private Const TARGET_SUBJECT As String = "Subject"
Private Const TARGET_BODY_RENDER As String = "BodyRender"
Private Const TARGET_MAIL_DISPLAY As String = "MailItemDisplay"

Private Const OL_DISCARD As Long = 1
Private Const OL_FOLDER_INBOX As Long = 6
Private Const OL_FOLDER_DISPLAY_NORMAL As Long = 0

' Word.WdFindWrap.wdFindStop
Private Const WD_FIND_STOP As Long = 0

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

Public Function ReadSubject( _
    ByRef subjectText As String _
) As COperationResult

    subjectText = vbNullString
    On Error GoTo ErrorHandler

    If mMailItem Is Nothing Then
        Set ReadSubject = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "There is no active MailItem to read.", _
            "MailItem")
        Exit Function
    End If

    subjectText = CStr(mMailItem.Subject)
    Set ReadSubject = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description
    subjectText = vbNullString

    Set ReadSubject = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The Outlook mail subject could not be read: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_SUBJECT)
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

Public Function SetSubject( _
    ByVal subjectText As String _
) As COperationResult

    On Error GoTo ErrorHandler

    If mMailItem Is Nothing Then
        Set SetSubject = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "There is no active MailItem to update.", _
            "MailItem")
        Exit Function
    End If

    mMailItem.Subject = subjectText
    Set SetSubject = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set SetSubject = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The Outlook mail subject could not be set: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_SUBJECT)
End Function

Public Function ReplaceBodyVariables( _
    ByVal formattedValues As Object _
) As COperationResult

    Dim validationResult As COperationResult
    Dim connectionResult As COperationResult
    Dim wordDocument As Object
    Dim searchRange As Object

    Dim key As Variant
    Dim variableName As String
    Dim replacement As String
    Dim searchText As String

    Dim found As Boolean
    Dim nextStart As Long
    Dim documentEnd As Long

    On Error GoTo ErrorHandler

    Set validationResult = ValidateFormattedValues( _
        formattedValues, _
        TARGET_BODY_RENDER)

    If validationResult Is Nothing Then
        Set ReplaceBodyVariables = CreateFailureResult( _
            ERROR_TYPE_RENDER, _
            "Formatted values validation did not return an operation result.", _
            TARGET_BODY_RENDER)
        GoTo CleanUp
    End If

    If Not validationResult.Success Then
        Set ReplaceBodyVariables = validationResult
        GoTo CleanUp
    End If

    Set validationResult = Nothing

    Set connectionResult = TryGetWordDocument(mMailItem, wordDocument)

    If connectionResult Is Nothing Then
        Set ReplaceBodyVariables = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "WordEditor connection did not return an operation result.", _
            TARGET_BODY_RENDER)
        GoTo CleanUp
    End If

    If Not connectionResult.Success Then
        Set ReplaceBodyVariables = connectionResult
        GoTo CleanUp
    End If

    For Each key In formattedValues.Keys
        variableName = CStr(key)
        replacement = CStr(formattedValues.Item(key))
        searchText = "{{" & variableName & "}}"

        Set searchRange = wordDocument.Content

        If searchRange Is Nothing Then
            Set ReplaceBodyVariables = CreateFailureResult( _
                ERROR_TYPE_OUTLOOK, _
                "The Word document body could not be obtained for rendering.", _
                TARGET_BODY_RENDER)
            GoTo CleanUp
        End If

        Do
            With searchRange.Find
                .ClearFormatting
                .Text = searchText
                .Forward = True
                .Wrap = WD_FIND_STOP
                .Format = False
                .MatchCase = False
                .MatchWholeWord = False

                found = CBool(.Execute)
            End With

            If Not found Then Exit Do

            ' Range.Find redefines searchRange to the found occurrence.
            ' Replace only that found Range. Do not rebuild the full Body.
            searchRange.Text = replacement

            ' Continue strictly after the replaced Range.
            ' P5 will finalize edge handling for empty values / special values.
            nextStart = CLng(searchRange.End)
            documentEnd = CLng(wordDocument.Content.End)

            If nextStart >= documentEnd Then Exit Do

            searchRange.SetRange nextStart, documentEnd
        Loop

        Set searchRange = Nothing
    Next key

    Set ReplaceBodyVariables = CreateSuccessResult()

CleanUp:
    ' P1 basic COM cleanup:
    ' local Word Range / Word Document references do not escape this call.
    Set searchRange = Nothing
    Set wordDocument = Nothing
    Set connectionResult = Nothing
    Set validationResult = Nothing
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    Set ReplaceBodyVariables = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The Outlook mail body could not be rendered: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_BODY_RENDER)

    Resume CleanUp
End Function

Public Function DisplayMail() As COperationResult
    On Error GoTo ErrorHandler

    If mMailItem Is Nothing Then
        Set DisplayMail = CreateFailureResult( _
            ERROR_TYPE_OUTLOOK, _
            "There is no active MailItem to display.", _
            TARGET_MAIL_DISPLAY)
        Exit Function
    End If

    ' Display only. Do not Save, Send, or Close.
    mMailItem.Display

    ' P1-07 ownership transfer:
    ' Release only the Adapter-held COM reference.
    ' This does NOT close/save/send the displayed Outlook item.
    Set mMailItem = Nothing

    Set DisplayMail = CreateSuccessResult()
    Exit Function

ErrorHandler:
    Dim errorNumber As Long
    Dim errorDescription As String

    errorNumber = Err.Number
    errorDescription = Err.Description

    ' Keep mMailItem when Display fails so the caller can attempt
    ' CloseWithoutSave as fail-closed cleanup.
    Set DisplayMail = CreateFailureResult( _
        ERROR_TYPE_OUTLOOK, _
        "The MailItem could not be displayed: " & _
            CStr(errorNumber) & " - " & errorDescription, _
        TARGET_MAIL_DISPLAY)
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
