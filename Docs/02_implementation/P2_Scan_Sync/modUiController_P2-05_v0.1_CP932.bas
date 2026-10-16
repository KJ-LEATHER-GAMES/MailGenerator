Attribute VB_Name = "modUiController"
Option Explicit

' P2-05 Fail Closed / Sync Result / Phase Integration
'
' Responsibility:
' - Provide the explicit Manual Sync user entry
' - Invoke modSyncApplication.ExecuteManualSync
' - Present the basic Sync Result
' - Present InvalidCandidates without rescanning
' - Present existing COperationResult error information
' - Fail closed when the returned carrier contract is incomplete
'
' Non-responsibility:
' - Template scanning / variable syntax validation
' - Sync classification / metadata calculation
' - VariableDefinition persistence
' - Outlook lifecycle
' - Automatic retry
' - Final error taxonomy / final recovery UI
' - Unused confirmation UI

Private Const SYNC_NEW As String = "New"
Private Const SYNC_EXISTING As String = "Existing"
Private Const SYNC_REACTIVATED As String = "Reactivated"
Private Const SYNC_UNUSED As String = "Unused"

Private Const KEY_VARIABLE_NAME As String = "VariableName"
Private Const KEY_INVALID_CANDIDATES As String = "InvalidCandidates"

Private Const LABEL_NEW As String = "新規"
Private Const LABEL_EXISTING As String = "継続"
Private Const LABEL_REACTIVATED As String = "復活"
Private Const LABEL_UNUSED As String = "Unused化"

Private Const TITLE_MANUAL_SYNC As String = "テンプレート同期"

Public Sub RunManualSync()

    Dim operationResult As COperationResult
    Dim syncDiffResult As Object
    Dim templateScanResult As Object
    Dim messageText As String

    Set syncDiffResult = Nothing
    Set templateScanResult = Nothing

    On Error GoTo UnexpectedError

    Set operationResult = ExecuteManualSync( _
        syncDiffResult, _
        templateScanResult)

    If operationResult Is Nothing Then
        messageText = BuildGenericFailureMessage()
        ShowManualSyncNotification messageText
        GoTo CleanUp
    End If

    If operationResult.Success Then

        If syncDiffResult Is Nothing Or _
           templateScanResult Is Nothing Then

            messageText = BuildGenericFailureMessage()
            ShowManualSyncNotification messageText
            GoTo CleanUp
        End If

        If Not BuildSyncSuccessMessage( _
            syncDiffResult, _
            messageText) Then

            messageText = BuildGenericFailureMessage()
            ShowManualSyncNotification messageText
            GoTo CleanUp
        End If

        ShowManualSyncNotification messageText
        GoTo CleanUp
    End If

    ' Failure path.
    ' InvalidCandidates have priority when the current scan result is available.
    If BuildInvalidCandidateMessage( _
        templateScanResult, _
        messageText) Then

        ShowManualSyncNotification messageText
        GoTo CleanUp
    End If

    If BuildOperationFailureMessage( _
        operationResult, _
        messageText) Then

        ShowManualSyncNotification messageText
        GoTo CleanUp
    End If

    messageText = BuildGenericFailureMessage()
    ShowManualSyncNotification messageText

CleanUp:
    Set templateScanResult = Nothing
    Set syncDiffResult = Nothing
    Set operationResult = Nothing
    Exit Sub

UnexpectedError:
    messageText = BuildGenericFailureMessage()
    On Error Resume Next
    ShowManualSyncNotification messageText
    On Error GoTo 0
    Resume CleanUp

End Sub

Private Function BuildSyncSuccessMessage( _
    ByVal syncDiffResult As Object, _
    ByRef messageText As String _
) As Boolean

    On Error GoTo InvalidCarrier

    messageText = "テンプレート同期結果" & vbCrLf & vbCrLf

    If Not AppendSyncCategory( _
        syncDiffResult, _
        SYNC_NEW, _
        LABEL_NEW, _
        messageText) Then
        GoTo InvalidCarrier
    End If

    messageText = messageText & vbCrLf

    If Not AppendSyncCategory( _
        syncDiffResult, _
        SYNC_EXISTING, _
        LABEL_EXISTING, _
        messageText) Then
        GoTo InvalidCarrier
    End If

    messageText = messageText & vbCrLf

    If Not AppendSyncCategory( _
        syncDiffResult, _
        SYNC_REACTIVATED, _
        LABEL_REACTIVATED, _
        messageText) Then
        GoTo InvalidCarrier
    End If

    messageText = messageText & vbCrLf

    If Not AppendSyncCategory( _
        syncDiffResult, _
        SYNC_UNUSED, _
        LABEL_UNUSED, _
        messageText) Then
        GoTo InvalidCarrier
    End If

    BuildSyncSuccessMessage = True
    Exit Function

InvalidCarrier:
    messageText = vbNullString
    BuildSyncSuccessMessage = False

End Function

Private Function AppendSyncCategory( _
    ByVal syncDiffResult As Object, _
    ByVal classification As String, _
    ByVal displayLabel As String, _
    ByRef messageText As String _
) As Boolean

    Dim items As Collection
    Dim item As Object
    Dim rawVariableName As Variant
    Dim variableName As String

    On Error GoTo InvalidCarrier

    If syncDiffResult Is Nothing Then
        GoTo InvalidCarrier
    End If

    If Not syncDiffResult.Exists(classification) Then
        GoTo InvalidCarrier
    End If

    Set items = syncDiffResult.Item(classification)

    If items Is Nothing Then
        GoTo InvalidCarrier
    End If

    messageText = messageText & _
        displayLabel & _
        " (" & CStr(items.Count) & "件)" & _
        vbCrLf

    If items.Count = 0 Then
        messageText = messageText & "なし" & vbCrLf
        AppendSyncCategory = True
        Exit Function
    End If

    For Each item In items

        If item Is Nothing Then
            GoTo InvalidCarrier
        End If

        If Not item.Exists(KEY_VARIABLE_NAME) Then
            GoTo InvalidCarrier
        End If

        rawVariableName = item.Item(KEY_VARIABLE_NAME)

        If IsError(rawVariableName) Or _
           IsNull(rawVariableName) Or _
           IsEmpty(rawVariableName) Then
            GoTo InvalidCarrier
        End If

        variableName = CStr(rawVariableName)

        If Len(variableName) = 0 Then
            GoTo InvalidCarrier
        End If

        messageText = messageText & _
            "- " & variableName & vbCrLf

    Next item

    AppendSyncCategory = True
    Exit Function

InvalidCarrier:
    Set item = Nothing
    Set items = Nothing
    AppendSyncCategory = False

End Function

Private Function BuildInvalidCandidateMessage( _
    ByVal templateScanResult As Object, _
    ByRef messageText As String _
) As Boolean

    Dim invalidCandidates As Collection
    Dim candidate As Variant

    On Error GoTo NotAvailable

    messageText = vbNullString

    If templateScanResult Is Nothing Then
        GoTo NotAvailable
    End If

    If Not templateScanResult.Exists(KEY_INVALID_CANDIDATES) Then
        GoTo NotAvailable
    End If

    Set invalidCandidates = _
        templateScanResult.Item(KEY_INVALID_CANDIDATES)

    If invalidCandidates Is Nothing Then
        GoTo NotAvailable
    End If

    If invalidCandidates.Count = 0 Then
        GoTo NotAvailable
    End If

    messageText = _
        "テンプレート内に命名規則違反の変数記法があります。" & _
        vbCrLf & _
        "同期は実行されませんでした。" & _
        vbCrLf & vbCrLf & _
        "対象" & vbCrLf

    For Each candidate In invalidCandidates

        If IsError(candidate) Or _
           IsNull(candidate) Or _
           IsEmpty(candidate) Then
            GoTo NotAvailable
        End If

        messageText = messageText & _
            "- " & CStr(candidate) & vbCrLf

    Next candidate

    BuildInvalidCandidateMessage = True
    Exit Function

NotAvailable:
    Set invalidCandidates = Nothing
    messageText = vbNullString
    BuildInvalidCandidateMessage = False

End Function

Private Function BuildOperationFailureMessage( _
    ByVal operationResult As COperationResult, _
    ByRef messageText As String _
) As Boolean

    Dim errors As Collection
    Dim errorInfo As CErrorInfo
    Dim itemText As String
    Dim itemNumber As Long
    Dim displayedCount As Long

    On Error GoTo NotAvailable

    messageText = vbNullString

    If operationResult Is Nothing Then
        GoTo NotAvailable
    End If

    Set errors = operationResult.Errors

    If errors Is Nothing Then
        GoTo NotAvailable
    End If

    If errors.Count = 0 Then
        GoTo NotAvailable
    End If

    messageText = _
        "テンプレート同期に失敗しました。" & _
        vbCrLf & vbCrLf

    displayedCount = 0

    For Each errorInfo In errors

        If Not errorInfo Is Nothing Then

            itemText = BuildErrorInfoText(errorInfo)

            If Len(itemText) > 0 Then

                displayedCount = displayedCount + 1

                If errors.Count > 1 Then
                    messageText = messageText & _
                        "[" & CStr(displayedCount) & "]" & _
                        vbCrLf
                End If

                messageText = messageText & itemText & vbCrLf

            End If

        End If

    Next errorInfo

    If displayedCount = 0 Then
        GoTo NotAvailable
    End If

    BuildOperationFailureMessage = True
    Exit Function

NotAvailable:
    Set errorInfo = Nothing
    Set errors = Nothing
    messageText = vbNullString
    BuildOperationFailureMessage = False

End Function

Private Function BuildErrorInfoText( _
    ByVal errorInfo As CErrorInfo _
) As String

    Dim messageValue As String
    Dim targetValue As String
    Dim resultText As String

    On Error GoTo NotAvailable

    If errorInfo Is Nothing Then
        Exit Function
    End If

    messageValue = Trim$(errorInfo.Message)
    targetValue = Trim$(errorInfo.Target)

    If Len(messageValue) > 0 Then
        resultText = messageValue & vbCrLf
    End If

    If Len(targetValue) > 0 Then
        resultText = resultText & _
            "確認対象: " & targetValue & vbCrLf
    End If

    BuildErrorInfoText = resultText
    Exit Function

NotAvailable:
    BuildErrorInfoText = vbNullString

End Function

Private Function BuildGenericFailureMessage() As String

    BuildGenericFailureMessage = _
        "テンプレート同期に失敗しました。" & _
        vbCrLf & _
        "同期結果を確定できませんでした。"

End Function

Private Sub ShowManualSyncNotification( _
    ByVal messageText As String _
)

    MsgBox _
        messageText, _
        vbOKOnly, _
        TITLE_MANUAL_SYNC

End Sub
