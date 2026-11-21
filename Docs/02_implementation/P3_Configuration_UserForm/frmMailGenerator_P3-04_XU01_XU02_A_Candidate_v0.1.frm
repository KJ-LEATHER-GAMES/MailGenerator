VERSION 5.00
Begin VB.UserForm frmMailGenerator
   Caption         =   "定型メール作成 - P3候補"
   ClientHeight    =   7575
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   8715
   StartUpPosition =   1  'CenterOwner
   Begin MSForms.Label lblHeader
      Caption         =   "定型メール作成"
      Height          =   285
      Left            =   180
      Top             =   135
      Width           =   8295
   End
   Begin MSForms.Label lblGuidance
      Caption         =   "必須項目は * で表示します。"
      Height          =   270
      Left            =   180
      Top             =   480
      Width           =   8295
   End
   Begin MSForms.Frame fraInputArea
      Caption         =   "入力項目"
      Height          =   5370
      Left            =   180
      Top             =   810
      Width           =   8355
   End
   Begin MSForms.Frame fraErrorArea
      Caption         =   "案内"
      Height          =   615
      Left            =   180
      Top             =   6240
      Width           =   8355
      Begin MSForms.Label lblErrorText
         Caption         =   "開発候補：メール作成・クリア・入力保持は未接続です。"
         Height          =   285
         Left            =   120
         Top             =   225
         Width           =   7965
      End
   End
   Begin MSForms.CommandButton cmdCreateMail
      Caption         =   "メール作成（未実装）"
      Enabled         =   0   'False
      Height          =   420
      Left            =   4470
      Top             =   6945
      Width           =   1965
   End
   Begin MSForms.CommandButton cmdClear
      Caption         =   "入力クリア（未実装）"
      Enabled         =   0   'False
      Height          =   420
      Left            =   6585
      Top             =   6945
      Width           =   1965
   End
End
Attribute VB_Name = "frmMailGenerator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

' P3-04 WORKING CANDIDATE. Designer export is NOT VBE-import/Compile verified.
' The fixed shell is in the designer; only InputArea children are dynamic.
' The public builder invokes P3-03 Gate itself; never bypass it.
' XU-02 A: all Row/Option values are copied before the first Controls.Add.
' Input State, Clear, Mail generation and input validation are NOT implemented.

Private Const ERR_CONFIG As String = "ConfigurationError"
Private Const ERR_UNEXPECTED As String = "UnexpectedError"
Private Const ROW_HEIGHT As Single = 63!
Private Const INPUT_LEFT As Single = 12!
Private Const INPUT_WIDTH As Single = 485!
Private mBuilt As Boolean
Private mBuildInProgress As Boolean

' IMPORTANT: .Show is an intrinsic UserForm method and cannot be overridden.
' Immediately hide a form that has not completed the validated builder.
' An instant of native painting cannot be excluded without a real VBE/UI test.
Private Sub UserForm_Activate()
    If Not mBuilt Then Me.Hide
End Sub

' The ONLY public input-building entry. Caller-supplied carriers are forbidden.
' Every unbuilt instance must acquire its own current validated snapshot.
Public Function BuildValidatedInputs() As COperationResult
    Dim sortedActiveDefinitions As Collection
    Dim activeOptionsByGroup As Object
    Dim gateResult As COperationResult
    Dim buildResult As COperationResult
    Dim snapshotResult As COperationResult
    Dim displaySnapshot As Collection

    On Error GoTo UnexpectedFailure

    If mBuilt Then
        Set BuildValidatedInputs = CreateFailureResult( _
            ERR_UNEXPECTED, "This form was already built.", "frmMailGenerator")
        Exit Function
    End If
    If mBuildInProgress Then
        Set BuildValidatedInputs = BadCarrier("frmMailGenerator.BuildInProgress")
        Exit Function
    End If

    mBuildInProgress = True
    Set gateResult = PrepareUserFormLaunch( _
        sortedActiveDefinitions, activeOptionsByGroup)

    If gateResult Is Nothing Then
        Set BuildValidatedInputs = BadCarrier("UserFormLaunchGate.Result")
        GoTo CleanExit
    End If
    If Not gateResult.Success Then
        ' Keep original upstream Result/ErrorInfo identity and precedence.
        Set BuildValidatedInputs = gateResult
        GoTo CleanExit
    End If
    If sortedActiveDefinitions Is Nothing Or activeOptionsByGroup Is Nothing Then
        Set BuildValidatedInputs = BadCarrier("UserFormLaunchGate.Outputs")
        GoTo CleanExit
    End If
    If TypeName(activeOptionsByGroup) <> "Dictionary" Then
        Set BuildValidatedInputs = BadCarrier("ActiveOptionsByGroup")
        GoTo CleanExit
    End If

    ' XU-02 A: take an all-row, all-option scalar snapshot BEFORE any Controls.Add.
    ' No original Row/Option dictionary may be read during rendering.
    Set snapshotResult = CreateDisplaySnapshot( _
        sortedActiveDefinitions, activeOptionsByGroup, displaySnapshot)

    ' Release the original Gate carriers before entering the private renderer.
    Set sortedActiveDefinitions = Nothing
    Set activeOptionsByGroup = Nothing

    If snapshotResult Is Nothing Then
        Set BuildValidatedInputs = BadCarrier("frmMailGenerator.SnapshotResult")
        GoTo CleanExit
    End If
    If Not snapshotResult.Success Then
        Set BuildValidatedInputs = snapshotResult
        GoTo CleanExit
    End If
    If displaySnapshot Is Nothing Then
        Set BuildValidatedInputs = BadCarrier("frmMailGenerator.DisplaySnapshot")
        GoTo CleanExit
    End If

    Set buildResult = BuildInputsFromSnapshot(displaySnapshot)
    If buildResult Is Nothing Then
        Set BuildValidatedInputs = BadCarrier("frmMailGenerator.RenderResult")
    Else
        Set BuildValidatedInputs = buildResult
    End If

CleanExit:
    mBuildInProgress = False
    Exit Function

UnexpectedFailure:
    ' Never leave a partially rendered form eligible for display.
    RemoveDynamicControls
    mBuilt = False
    Set BuildValidatedInputs = BadCarrier("frmMailGenerator.BuildValidatedInputs")
    Resume CleanExit
End Function

' XU-02 A: copy every source Row/Option to PRIVATE DISPLAY DATA.
' Each row is a fresh Dictionary of primitive strings/Boolean; OptionValues is
' a fresh Collection of strings. No original Collection/Dictionary is stored.
' This entire operation completes BEFORE the first Controls.Add call.
Private Function CreateDisplaySnapshot( _
    ByVal sortedActiveDefinitions As Collection, _
    ByVal activeOptionsByGroup As Object, _
    ByRef displaySnapshot As Collection _
) As COperationResult
    Dim candidate As Collection
    Dim itemValue As Variant
    Dim sourceRow As Object
    Dim snapshotRow As Object
    Dim optionValues As Collection
    Dim sourceOptions As Collection
    Dim optionValue As Variant
    Dim sourceOption As Object
    Dim variableName As String
    Dim displayText As String
    Dim typeText As String
    Dim descriptionText As String
    Dim groupName As String
    Dim valueText As String
    Dim requiredFlag As Boolean

    Set displaySnapshot = Nothing
    On Error GoTo UnexpectedFailure
    If sortedActiveDefinitions Is Nothing Then GoTo InvalidRow
    If activeOptionsByGroup Is Nothing Then GoTo InvalidRow
    If TypeName(activeOptionsByGroup) <> "Dictionary" Then GoTo InvalidRow

    Set candidate = New Collection
    For Each itemValue In sortedActiveDefinitions
        If Not IsObject(itemValue) Then GoTo InvalidRow
        Set sourceRow = itemValue
        If sourceRow Is Nothing Then GoTo InvalidRow
        If TypeName(sourceRow) <> "Dictionary" Then GoTo InvalidRow

        If Not ReadNonBlank(sourceRow, "VariableName", variableName) Then GoTo InvalidRow
        If Not ReadNonBlank(sourceRow, "DisplayName", displayText) Then GoTo InvalidRow
        If Not ReadNonBlank(sourceRow, "Type", typeText) Then GoTo InvalidRow
        If Not sourceRow.Exists("Required") Then GoTo InvalidRow
        If Not TryRequiredFlag(sourceRow("Required"), requiredFlag) Then
            Set CreateDisplaySnapshot = CreateFailureResult( _
                ERR_CONFIG, "Required is not a supported value.", variableName & ".Required")
            Exit Function
        End If
        If typeText <> "Text" And typeText <> "Date" And typeText <> "Select" Then
            Set CreateDisplaySnapshot = CreateFailureResult( _
                ERR_CONFIG, "Unsupported input Type.", variableName & ".Type")
            Exit Function
        End If

        descriptionText = vbNullString
        If sourceRow.Exists("Description") Then
            If Not TryOptionalText(sourceRow("Description"), descriptionText) Then GoTo InvalidRow
        End If

        groupName = vbNullString
        Set optionValues = New Collection
        If typeText = "Select" Then
            If Not ReadNonBlank(sourceRow, "OptionSource", groupName) Then GoTo InvalidRow
            ' Preserve exact, case-sensitive OptionGroup identity (vbBinaryCompare).
            If Not TryGetGroup(activeOptionsByGroup, groupName, sourceOptions) Then GoTo InvalidRow
            If sourceOptions.Count = 0 Then
                Set CreateDisplaySnapshot = CreateFailureResult( _
                    ERR_CONFIG, "Select has no active option.", groupName)
                Exit Function
            End If
            For Each optionValue In sourceOptions
                If Not IsObject(optionValue) Then GoTo InvalidRow
                Set sourceOption = optionValue
                If sourceOption Is Nothing Then GoTo InvalidRow
                If TypeName(sourceOption) <> "Dictionary" Then GoTo InvalidRow
                If Not sourceOption.Exists("Value") Then GoTo InvalidRow
                If Not TryScalarText(sourceOption("Value"), valueText) Then GoTo InvalidRow
                ' Store only the string, never the source Option dictionary.
                optionValues.Add valueText
            Next optionValue
        End If

        Set snapshotRow = CreateObject("Scripting.Dictionary")
        snapshotRow.CompareMode = vbBinaryCompare
        snapshotRow.Add "VariableName", variableName
        snapshotRow.Add "DisplayName", displayText
        snapshotRow.Add "Type", typeText
        snapshotRow.Add "Required", requiredFlag
        snapshotRow.Add "Description", descriptionText
        snapshotRow.Add "OptionSource", groupName
        snapshotRow.Add "OptionValues", optionValues
        candidate.Add snapshotRow
    Next itemValue

    ' Publish only after the LAST row and LAST Option have been copied.
    Set displaySnapshot = candidate
    Set CreateDisplaySnapshot = CreateSuccessResult()
    Exit Function
InvalidRow:
    Set displaySnapshot = Nothing
    Set CreateDisplaySnapshot = BadCarrier("UserForm.InputSnapshot.Row")
    Exit Function
UnexpectedFailure:
    Set displaySnapshot = Nothing
    Set CreateDisplaySnapshot = BadCarrier("frmMailGenerator.CreateDisplaySnapshot")
End Function

' Private renderer: receives ONLY the isolated display snapshot.
Private Function BuildInputsFromSnapshot( _
    ByVal displaySnapshot As Collection _
) As COperationResult
    Dim snapshotValue As Variant
    Dim snapshotRow As Object
    Dim itemIndex As Long
    Dim stepResult As COperationResult

    On Error GoTo UnexpectedFailure
    If mBuilt Then
        Set BuildInputsFromSnapshot = CreateFailureResult( _
            ERR_UNEXPECTED, "This form was already built.", "frmMailGenerator")
        Exit Function
    End If
    If displaySnapshot Is Nothing Then
        Set BuildInputsFromSnapshot = BadCarrier("UserForm.DisplaySnapshot")
        Exit Function
    End If

    Me.cmdCreateMail.Enabled = False
    Me.cmdClear.Enabled = False
    Me.fraInputArea.ScrollBars = fmScrollBarsVertical
    Me.fraInputArea.ScrollTop = 0
    Me.fraInputArea.ScrollWidth = Me.fraInputArea.Width - 18!

    itemIndex = 0
    For Each snapshotValue In displaySnapshot
        Set snapshotRow = snapshotValue
        itemIndex = itemIndex + 1
        Set stepResult = AppendInputRow(snapshotRow, itemIndex)
        If stepResult Is Nothing Then GoTo UnexpectedFailure
        If Not stepResult.Success Then
            RemoveDynamicControls
            Set BuildInputsFromSnapshot = stepResult
            Exit Function
        End If
    Next snapshotValue

    If (12! + CSng(itemIndex) * ROW_HEIGHT) > Me.fraInputArea.Height Then
        Me.fraInputArea.ScrollHeight = 20! + CSng(itemIndex) * ROW_HEIGHT
    Else
        Me.fraInputArea.ScrollHeight = Me.fraInputArea.Height
    End If

    mBuilt = True
    Set BuildInputsFromSnapshot = CreateSuccessResult()
    Exit Function
UnexpectedFailure:
    RemoveDynamicControls
    mBuilt = False
    Set BuildInputsFromSnapshot = BadCarrier("frmMailGenerator.BuildInputsFromSnapshot")
End Function

Private Function AppendInputRow( _
    ByVal row As Object, _
    ByVal position As Long _
) As COperationResult
    Dim displayLabel As MSForms.Label
    Dim requiredLabel As MSForms.Label
    Dim descriptionLabel As MSForms.Label
    Dim inputBox As MSForms.TextBox
    Dim choiceBox As MSForms.ComboBox
    Dim optionItems As Collection
    Dim optionValue As Variant
    Dim suffix As String
    Dim y As Single
    Dim typeText As String
    Dim variableName As String
    Dim displayText As String
    Dim hintText As String
    Dim requiredFlag As Boolean

    On Error GoTo UnexpectedFailure
    suffix = Format$(position, "0000")
    y = 10! + (CSng(position) - 1!) * ROW_HEIGHT
    variableName = CStr(row("VariableName"))
    displayText = CStr(row("DisplayName"))
    typeText = CStr(row("Type"))
    requiredFlag = False
    If Not TryRequiredFlag(row("Required"), requiredFlag) Then GoTo UnexpectedFailure

    Set displayLabel = Me.fraInputArea.Controls.Add( _
        "Forms.Label.1", "lblDisplay_" & suffix, True)
    With displayLabel
        .Caption = displayText
        .Left = INPUT_LEFT
        .Top = y
        .Width = INPUT_WIDTH - 25!
        .Height = 15!
        .WordWrap = False
    End With

    Set requiredLabel = Me.fraInputArea.Controls.Add( _
        "Forms.Label.1", "lblRequired_" & suffix, True)
    With requiredLabel
        .Caption = "*"
        .Left = INPUT_LEFT + INPUT_WIDTH - 23!
        .Top = y
        .Width = 18!
        .Height = 15!
        .Visible = requiredFlag
    End With

    If typeText = "Text" Or typeText = "Date" Then
        Set inputBox = Me.fraInputArea.Controls.Add( _
            "Forms.TextBox.1", "txtInput_" & suffix, True)
        With inputBox
            .Left = INPUT_LEFT
            .Top = y + 17!
            .Width = INPUT_WIDTH
            .Height = 20!
            .MultiLine = False
            .Tag = variableName
            .Value = vbNullString
        End With
    Else
        ' OptionValues is the private String-only collection, NOT OptionMaster.
        Set optionItems = row("OptionValues")
        Set choiceBox = Me.fraInputArea.Controls.Add( _
            "Forms.ComboBox.1", "cboInput_" & suffix, True)
        With choiceBox
            .Left = INPUT_LEFT
            .Top = y + 17!
            .Width = INPUT_WIDTH
            .Height = 20!
            .Style = fmStyleDropDownList
            .Tag = variableName
            .ListIndex = -1
        End With
        For Each optionValue In optionItems
            choiceBox.AddItem CStr(optionValue)
        Next optionValue
        choiceBox.ListIndex = -1
    End If

    hintText = CStr(row("Description"))
    Set descriptionLabel = Me.fraInputArea.Controls.Add( _
        "Forms.Label.1", "lblDescription_" & suffix, True)
    With descriptionLabel
        .Caption = hintText
        .Left = INPUT_LEFT
        .Top = y + 40!
        .Width = INPUT_WIDTH
        .Height = 16!
        .WordWrap = False
    End With

    Set AppendInputRow = CreateSuccessResult()
    Exit Function
UnexpectedFailure:
    Set AppendInputRow = BadCarrier("frmMailGenerator.ControlBuild")
End Function

Private Function TryGetGroup( _
    ByVal groups As Object, _
    ByVal requiredGroup As String, _
    ByRef items As Collection _
) As Boolean
    Dim k As Variant
    Dim candidate As Object
    Set items = Nothing
    On Error GoTo InvalidGroup
    For Each k In groups.Keys
        If StrComp(CStr(k), requiredGroup, vbBinaryCompare) = 0 Then
            Set candidate = groups(CStr(k))
            If candidate Is Nothing Then Exit Function
            If TypeName(candidate) <> "Collection" Then Exit Function
            Set items = candidate
            TryGetGroup = True
            Exit Function
        End If
    Next k
InvalidGroup:
End Function

Private Function ReadNonBlank( _
    ByVal item As Object, _
    ByVal key As String, _
    ByRef textValue As String _
) As Boolean
    If Not item.Exists(key) Then Exit Function
    If Not TryScalarText(item(key), textValue) Then Exit Function
    ReadNonBlank = (Len(Trim$(textValue)) > 0)
End Function

Private Function TryScalarText( _
    ByVal value As Variant, _
    ByRef textValue As String _
) As Boolean
    On Error GoTo InvalidValue
    If IsError(value) Or IsNull(value) Then Exit Function
    If IsObject(value) Or IsArray(value) Then Exit Function
    If IsEmpty(value) Then
        textValue = vbNullString
    Else
        textValue = CStr(value)
    End If
    TryScalarText = True
InvalidValue:
End Function

Private Function TryOptionalText( _
    ByVal value As Variant, _
    ByRef textValue As String _
) As Boolean
    If IsEmpty(value) Then
        textValue = vbNullString
        TryOptionalText = True
    Else
        TryOptionalText = TryScalarText(value, textValue)
    End If
End Function

Private Function TryRequiredFlag( _
    ByVal value As Variant, _
    ByRef isRequired As Boolean _
) As Boolean
    Dim normalized As String
    On Error GoTo InvalidValue
    If IsError(value) Or IsNull(value) Or IsEmpty(value) Then Exit Function
    If IsObject(value) Or IsArray(value) Then Exit Function
    Select Case VarType(value)
        Case vbBoolean
            isRequired = CBool(value)
            TryRequiredFlag = True
        Case vbByte, vbInteger, vbLong, vbSingle, vbDouble, vbCurrency, vbDecimal
            If CDbl(value) = 1# Then
                isRequired = True
                TryRequiredFlag = True
            ElseIf CDbl(value) = 0# Then
                isRequired = False
                TryRequiredFlag = True
            End If
        Case vbString
            normalized = LCase$(Trim$(CStr(value)))
            If normalized = "true" Then
                isRequired = True
                TryRequiredFlag = True
            ElseIf normalized = "false" Then
                isRequired = False
                TryRequiredFlag = True
            End If
    End Select
InvalidValue:
End Function

Private Sub RemoveDynamicControls()
    Dim i As Long
    On Error Resume Next
    For i = Me.fraInputArea.Controls.Count - 1 To 0 Step -1
        Me.fraInputArea.Controls.Remove Me.fraInputArea.Controls(i).Name
    Next i
    On Error GoTo 0
End Sub

Private Function BadCarrier(ByVal target As String) As COperationResult
    Set BadCarrier = CreateFailureResult( _
        ERR_UNEXPECTED, "Form input carrier is missing or malformed.", target)
End Function
