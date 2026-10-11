Attribute VB_Name = "modP1_07DisplayE2EIntegrationTest"
Option Explicit

' P1-07 Display / E2E Integration - Implementation Verification
'
' IMPORTANT:
' - This is NOT a Formal MVP Test artifact.
' - Production flow is invoked only through modMailApplication.CreateMailForDisplay.
' - Outlook Object Model access in this module is evidence-only:
'     Explorer / Inspector / Draft counts.
' - This module does NOT access WordEditor / Word Document.
' - Success-path displayed MailItem is closed manually by the user without saving.
'
' Public entry points:
'   TestP107DisplayE2EIntegration
'   TestP107WarmStartNormal
'   TestP107ColdStartNormal
'   TestP107UnresolvedFailClosed

Private Const OL_FOLDER_DRAFTS As Long = 16

Private Const KEY_HAS_UNRESOLVED As String = "HasUnresolved"
Private Const KEY_VARIABLES As String = "Variables"

Private Const VARIABLE_MODEL_NAME As String = "ModelName"
Private Const VARIABLE_GATE_DATE As String = "GateDate"
Private Const VARIABLE_DEPARTMENT As String = "Department"
Private Const VARIABLE_COMMENT As String = "Comment"

Private Const VALUE_MODEL_NAME As String = "ABC123"
Private Const VALUE_GATE_DATE As String = "2026/09/30"

Private Const EVIDENCE_REACQUIRE_ATTEMPTS As Long = 10
Private Const EVENT_PUMP_COUNT As Long = 5

Public Sub TestP107DisplayE2EIntegration()

    Debug.Print String$(72, "=")
    Debug.Print "P1-07 Display / E2E Integration Verification"
    Debug.Print "Run the following entry points separately:"
    Debug.Print "  1. TestP107WarmStartNormal"
    Debug.Print "  2. TestP107ColdStartNormal"
    Debug.Print "  3. TestP107UnresolvedFailClosed"
    Debug.Print
    Debug.Print "Do not run all three automatically."
    Debug.Print "Cold Start requires Outlook Explorer Count = 0 before execution."
    Debug.Print "This verification is NOT a Formal MVP Test."
    Debug.Print String$(72, "=")

End Sub

Public Sub TestP107WarmStartNormal()

    Dim outlookApp As Object
    Dim result As COperationResult
    Dim unresolvedResult As Object
    Dim formattedValues As Object

    Dim explorerBefore As Long
    Dim inspectorBefore As Long
    Dim draftBefore As Long

    Dim explorerAfterDisplay As Long
    Dim inspectorAfterDisplay As Long
    Dim draftAfterDisplay As Long

    Dim explorerAfterCleanup As Long
    Dim inspectorAfterCleanup As Long
    Dim draftAfterCleanup As Long

    Dim fixturePass As Boolean
    Dim operationPass As Boolean
    Dim unresolvedPass As Boolean
    Dim displayPass As Boolean
    Dim explorerPass As Boolean
    Dim draftPass As Boolean
    Dim manualPass As Boolean
    Dim cleanupPass As Boolean
    Dim overallPass As Boolean

    PrintHeader "P1-07 V1 - Warm Start Normal E2E"

    If Not TryAcquireOutlookApplication(outlookApp, 1) Then
        PrintFail "Precondition", _
            "Classic Outlook is not running. Open Classic Outlook first."
        PrintOverall "FAIL"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerBefore, _
        inspectorBefore, _
        draftBefore _
    ) Then
        PrintBlocked "Precondition Evidence", _
            "Unable to capture Outlook counts."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    Debug.Print "Outlook Start State: Warm"
    PrintCount "Explorer Count Before", explorerBefore
    PrintCount "Inspector Count Before", inspectorBefore
    PrintCount "Draft Count Before", draftBefore

    If explorerBefore < 1 Then
        PrintFail "Warm Start Precondition", _
            "Explorer Count must be 1 or greater."
        PrintOverall "FAIL"
        Exit Sub
    End If

    Set formattedValues = BuildFormattedValues(True, fixturePass)

    If Not fixturePass Then
        PrintFail "Fixture Guard", _
            "FormattedValues fixture is invalid."
        PrintOverall "FAIL"
        Exit Sub
    End If

    PrintPass "Fixture Guard"

    Set result = CreateMailForDisplay( _
        formattedValues, _
        unresolvedResult)

    PumpEvents

    operationPass = ResultIsSuccess(result)

    If operationPass Then
        PrintPass "CreateMailForDisplay"
    Else
        PrintFail "CreateMailForDisplay", _
            "Production returned Failure."
        PrintOperationResult result
    End If

    unresolvedPass = ValidateNoUnresolvedResult( _
        result, _
        unresolvedResult)

    If unresolvedPass Then
        PrintPass "Unresolved Gate"
    Else
        PrintFail "Unresolved Gate", _
            "Expected Success + HasUnresolved=False + Variables.Count=0."
        PrintUnresolvedResult unresolvedResult
    End If

    Set outlookApp = Nothing

    If Not TryAcquireOutlookApplication( _
        outlookApp, _
        EVIDENCE_REACQUIRE_ATTEMPTS _
    ) Then
        PrintBlocked "Post-Display Evidence", _
            "Unable to reacquire Classic Outlook."
        PromptManualCleanupIfNeeded
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerAfterDisplay, _
        inspectorAfterDisplay, _
        draftAfterDisplay _
    ) Then
        PrintBlocked "Post-Display Evidence", _
            "Unable to capture Outlook counts."
        PromptManualCleanupIfNeeded
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    PrintCount "Explorer Count After Display", explorerAfterDisplay
    PrintCount "Inspector Count After Display", inspectorAfterDisplay
    PrintCount "Draft Count After Display", draftAfterDisplay

    displayPass = _
        (inspectorAfterDisplay = inspectorBefore + 1)

    explorerPass = _
        (explorerAfterDisplay = explorerBefore)

    draftPass = _
        (draftAfterDisplay = draftBefore)

    If displayPass Then
        PrintPass "Final MailItem Display Evidence"
    Else
        PrintFail "Final MailItem Display Evidence", _
            "Expected Inspector Count Before + 1."
    End If

    If explorerPass Then
        PrintPass "Warm Start Existing Explorer Reuse"
    Else
        PrintFail "Warm Start Existing Explorer Reuse", _
            "Explorer Count changed unexpectedly."
    End If

    If draftPass Then
        PrintPass "Draft Count After Display"
    Else
        PrintFail "Draft Count After Display", _
            "Draft Count changed unexpectedly."
    End If

    manualPass = ConfirmDisplayedMailAndClose()

    If manualPass Then
        PrintPass "Manual Display / No Auto Send Confirmation"
    Else
        PrintFail "Manual Display / No Auto Send Confirmation", _
            "User did not confirm expected displayed and unsent state."
    End If

    PumpEvents

    Set outlookApp = Nothing

    If Not TryAcquireOutlookApplication( _
        outlookApp, _
        EVIDENCE_REACQUIRE_ATTEMPTS _
    ) Then
        PrintBlocked "Post-Cleanup Evidence", _
            "Unable to reacquire Classic Outlook."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerAfterCleanup, _
        inspectorAfterCleanup, _
        draftAfterCleanup _
    ) Then
        PrintBlocked "Post-Cleanup Evidence", _
            "Unable to capture Outlook counts."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    PrintCount "Explorer Count After User Cleanup", explorerAfterCleanup
    PrintCount "Inspector Count After User Cleanup", inspectorAfterCleanup
    PrintCount "Draft Count After User Cleanup", draftAfterCleanup

    cleanupPass = _
        (explorerAfterCleanup = explorerBefore) And _
        (inspectorAfterCleanup = inspectorBefore) And _
        (draftAfterCleanup = draftBefore)

    If cleanupPass Then
        PrintPass "User Cleanup Lifecycle"
    Else
        PrintFail "User Cleanup Lifecycle", _
            "Explorer / Inspector / Draft counts did not return to baseline."
    End If

    overallPass = _
        fixturePass And _
        operationPass And _
        unresolvedPass And _
        displayPass And _
        explorerPass And _
        draftPass And _
        manualPass And _
        cleanupPass

    If overallPass Then
        PrintOverall "PASS"
    Else
        PrintOverall "FAIL"
    End If

    Set formattedValues = Nothing
    Set unresolvedResult = Nothing
    Set result = Nothing
    Set outlookApp = Nothing

End Sub

Public Sub TestP107ColdStartNormal()

    Dim outlookApp As Object
    Dim result As COperationResult
    Dim unresolvedResult As Object
    Dim formattedValues As Object

    Dim explorerBefore As Long
    Dim inspectorBefore As Long
    Dim draftBefore As Long
    Dim draftBeforeAvailable As Boolean

    Dim explorerAfterDisplay As Long
    Dim inspectorAfterDisplay As Long
    Dim draftAfterDisplay As Long

    Dim explorerAfterCleanup As Long
    Dim inspectorAfterCleanup As Long
    Dim draftAfterCleanup As Long

    Dim fixturePass As Boolean
    Dim operationPass As Boolean
    Dim unresolvedPass As Boolean
    Dim displayPass As Boolean
    Dim explorerPass As Boolean
    Dim draftPass As Boolean
    Dim manualPass As Boolean
    Dim cleanupPass As Boolean
    Dim overallPass As Boolean

    PrintHeader "P1-07 V2 - Cold Start Normal E2E"

    explorerBefore = 0
    inspectorBefore = 0
    draftBefore = -1
    draftBeforeAvailable = False

    If TryAcquireOutlookApplication(outlookApp, 1) Then

        If Not CaptureEvidence( _
            outlookApp, _
            explorerBefore, _
            inspectorBefore, _
            draftBefore _
        ) Then
            PrintBlocked "Precondition Evidence", _
                "Unable to capture existing Outlook counts."
            PrintOverall "BLOCKED"
            Exit Sub
        End If

        draftBeforeAvailable = True

    End If

    Debug.Print "Outlook Start State: Cold Candidate"
    PrintCount "Explorer Count Before", explorerBefore
    PrintCount "Inspector Count Before", inspectorBefore

    If draftBeforeAvailable Then
        PrintCount "Draft Count Before", draftBefore
    Else
        Debug.Print "Draft Count Before: N/A (Outlook not started by test harness)"
    End If

    If explorerBefore <> 0 Then
        PrintFail "Cold Start Precondition", _
            "Explorer Count must be 0. Close Classic Outlook Explorers first."
        PrintOverall "FAIL"
        Exit Sub
    End If

    Set outlookApp = Nothing

    Set formattedValues = BuildFormattedValues(True, fixturePass)

    If Not fixturePass Then
        PrintFail "Fixture Guard", _
            "FormattedValues fixture is invalid."
        PrintOverall "FAIL"
        Exit Sub
    End If

    PrintPass "Fixture Guard"

    Set result = CreateMailForDisplay( _
        formattedValues, _
        unresolvedResult)

    PumpEvents

    operationPass = ResultIsSuccess(result)

    If operationPass Then
        PrintPass "CreateMailForDisplay"
    Else
        PrintFail "CreateMailForDisplay", _
            "Production returned Failure."
        PrintOperationResult result
    End If

    unresolvedPass = ValidateNoUnresolvedResult( _
        result, _
        unresolvedResult)

    If unresolvedPass Then
        PrintPass "Unresolved Gate"
    Else
        PrintFail "Unresolved Gate", _
            "Expected Success + HasUnresolved=False + Variables.Count=0."
        PrintUnresolvedResult unresolvedResult
    End If

    If Not TryAcquireOutlookApplication( _
        outlookApp, _
        EVIDENCE_REACQUIRE_ATTEMPTS _
    ) Then
        PrintBlocked "Post-Display Evidence", _
            "Production returned, but Classic Outlook could not be reacquired."
        PromptManualCleanupIfNeeded
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerAfterDisplay, _
        inspectorAfterDisplay, _
        draftAfterDisplay _
    ) Then
        PrintBlocked "Post-Display Evidence", _
            "Unable to capture Outlook counts."
        PromptManualCleanupIfNeeded
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    PrintCount "Explorer Count After Display", explorerAfterDisplay
    PrintCount "Inspector Count After Display", inspectorAfterDisplay
    PrintCount "Draft Count After Display", draftAfterDisplay

    explorerPass = (explorerAfterDisplay >= 1)

    displayPass = _
        (inspectorAfterDisplay = inspectorBefore + 1)

    If explorerPass Then
        PrintPass "Cold Start Visible Explorer Initialization"
    Else
        PrintFail "Cold Start Visible Explorer Initialization", _
            "Expected Explorer Count 0 -> 1 or greater."
    End If

    If displayPass Then
        PrintPass "Final MailItem Display Evidence"
    Else
        PrintFail "Final MailItem Display Evidence", _
            "Expected Inspector Count Before + 1."
    End If

    If draftBeforeAvailable Then

        draftPass = (draftAfterDisplay = draftBefore)

        If draftPass Then
            PrintPass "Draft Count After Display"
        Else
            PrintFail "Draft Count After Display", _
                "Draft Count changed unexpectedly."
        End If

    Else

        ' When Outlook is truly not running, obtaining Draft Count Before
        ' would start Outlook and destroy the Cold Start precondition.
        ' Do not manufacture a precondition measurement.
        draftPass = True

        Debug.Print _
            "Draft Count Before/After Display comparison: N/A " & _
            "(preserved Cold Start precondition)"

    End If

    manualPass = ConfirmDisplayedMailAndClose()

    If manualPass Then
        PrintPass "Manual Display / No Auto Send Confirmation"
    Else
        PrintFail "Manual Display / No Auto Send Confirmation", _
            "User did not confirm expected displayed and unsent state."
    End If

    PumpEvents

    Set outlookApp = Nothing

    If Not TryAcquireOutlookApplication( _
        outlookApp, _
        EVIDENCE_REACQUIRE_ATTEMPTS _
    ) Then
        PrintBlocked "Post-Cleanup Evidence", _
            "Unable to reacquire Classic Outlook."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerAfterCleanup, _
        inspectorAfterCleanup, _
        draftAfterCleanup _
    ) Then
        PrintBlocked "Post-Cleanup Evidence", _
            "Unable to capture Outlook counts."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    PrintCount "Explorer Count After User Cleanup", explorerAfterCleanup
    PrintCount "Inspector Count After User Cleanup", inspectorAfterCleanup
    PrintCount "Draft Count After User Cleanup", draftAfterCleanup

    cleanupPass = _
        (explorerAfterCleanup >= 1) And _
        (inspectorAfterCleanup = inspectorBefore)

    If draftBeforeAvailable Then
        cleanupPass = cleanupPass And _
            (draftAfterCleanup = draftBefore)
    Else
        ' At minimum, manual close without saving must not increase
        ' the Draft count observed immediately after Display.
        cleanupPass = cleanupPass And _
            (draftAfterCleanup = draftAfterDisplay)
    End If

    If cleanupPass Then
        PrintPass "Cold Start User Cleanup Lifecycle"
    Else
        PrintFail "Cold Start User Cleanup Lifecycle", _
            "Explorer / Inspector / Draft evidence did not match expectations."
    End If

    overallPass = _
        fixturePass And _
        operationPass And _
        unresolvedPass And _
        explorerPass And _
        displayPass And _
        draftPass And _
        manualPass And _
        cleanupPass

    If overallPass Then
        PrintOverall "PASS"
    Else
        PrintOverall "FAIL"
    End If

    Set formattedValues = Nothing
    Set unresolvedResult = Nothing
    Set result = Nothing
    Set outlookApp = Nothing

End Sub

Public Sub TestP107UnresolvedFailClosed()

    Dim outlookApp As Object
    Dim result As COperationResult
    Dim unresolvedResult As Object
    Dim formattedValues As Object

    Dim explorerBefore As Long
    Dim inspectorBefore As Long
    Dim draftBefore As Long

    Dim explorerAfter As Long
    Dim inspectorAfter As Long
    Dim draftAfter As Long

    Dim fixturePass As Boolean
    Dim failurePass As Boolean
    Dim unresolvedPass As Boolean
    Dim noDisplayPass As Boolean
    Dim lifecyclePass As Boolean
    Dim overallPass As Boolean

    PrintHeader "P1-07 V3 - Unresolved Fail Closed"

    If Not TryAcquireOutlookApplication(outlookApp, 1) Then
        PrintFail "Precondition", _
            "Classic Outlook is not running. Keep the Explorer open from V2 or open Outlook."
        PrintOverall "FAIL"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerBefore, _
        inspectorBefore, _
        draftBefore _
    ) Then
        PrintBlocked "Precondition Evidence", _
            "Unable to capture Outlook counts."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    Debug.Print "Outlook Start State: Warm"
    PrintCount "Explorer Count Before", explorerBefore
    PrintCount "Inspector Count Before", inspectorBefore
    PrintCount "Draft Count Before", draftBefore

    If explorerBefore < 1 Then
        PrintFail "Fail Closed Precondition", _
            "Explorer Count must be 1 or greater."
        PrintOverall "FAIL"
        Exit Sub
    End If

    Set formattedValues = BuildFormattedValues(False, fixturePass)

    If Not fixturePass Then
        PrintFail "Fixture Guard", _
            "Missing-GateDate fixture is invalid."
        PrintOverall "FAIL"
        Exit Sub
    End If

    PrintPass "Fixture Guard"
    Debug.Print "Intentional Missing Variable: GateDate"

    Set result = CreateMailForDisplay( _
        formattedValues, _
        unresolvedResult)

    PumpEvents

    failurePass = _
        (Not result Is Nothing) And _
        (Not result.Success)

    If failurePass Then
        PrintPass "CreateMailForDisplay Failure Expected"
    Else
        PrintFail "CreateMailForDisplay Failure Expected", _
            "Expected Failure for unresolved GateDate."

        If Not result Is Nothing Then
            PrintOperationResult result
        End If
    End If

    unresolvedPass = ValidateExpectedGateDateUnresolved( _
        unresolvedResult)

    If unresolvedPass Then
        PrintPass "Unresolved Result Preservation"
        PrintUnresolvedResult unresolvedResult
    Else
        PrintFail "Unresolved Result Preservation", _
            "Expected HasUnresolved=True / Variables.Count=1 / GateDate."
        PrintUnresolvedResult unresolvedResult
    End If

    Set outlookApp = Nothing

    If Not TryAcquireOutlookApplication( _
        outlookApp, _
        EVIDENCE_REACQUIRE_ATTEMPTS _
    ) Then
        PrintBlocked "Fail Closed Evidence", _
            "Unable to reacquire Classic Outlook."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    If Not CaptureEvidence( _
        outlookApp, _
        explorerAfter, _
        inspectorAfter, _
        draftAfter _
    ) Then
        PrintBlocked "Fail Closed Evidence", _
            "Unable to capture Outlook counts."
        PrintOverall "BLOCKED"
        Exit Sub
    End If

    PrintCount "Explorer Count After", explorerAfter
    PrintCount "Inspector Count After", inspectorAfter
    PrintCount "Draft Count After", draftAfter

    noDisplayPass = _
        (inspectorAfter = inspectorBefore)

    lifecyclePass = _
        (explorerAfter = explorerBefore) And _
        (inspectorAfter = inspectorBefore) And _
        (draftAfter = draftBefore)

    If noDisplayPass Then
        PrintPass "Final MailItem Display = NONE"
    Else
        PrintFail "Final MailItem Display = NONE", _
            "Inspector Count increased unexpectedly."
    End If

    If lifecyclePass Then
        PrintPass "Production CloseWithoutSave Lifecycle"
    Else
        PrintFail "Production CloseWithoutSave Lifecycle", _
            "Explorer / Inspector / Draft counts changed unexpectedly."
    End If

    overallPass = _
        fixturePass And _
        failurePass And _
        unresolvedPass And _
        noDisplayPass And _
        lifecyclePass

    If overallPass Then
        PrintOverall "PASS"
    Else
        If inspectorAfter > inspectorBefore Then
            PromptManualCleanupIfNeeded
        End If

        PrintOverall "FAIL"
    End If

    Set formattedValues = Nothing
    Set unresolvedResult = Nothing
    Set result = Nothing
    Set outlookApp = Nothing

End Sub

Private Function BuildFormattedValues( _
    ByVal includeGateDate As Boolean, _
    ByRef fixturePass As Boolean _
) As Object

    Dim values As Object
    Dim departmentValue As String
    Dim commentValue As String

    fixturePass = False

    departmentValue = BuildDepartmentValue()
    commentValue = BuildCommentValue()

    Debug.Print "Fixture Department Len=" & CStr(Len(departmentValue))
    Debug.Print "Fixture Comment Len=" & CStr(Len(commentValue))

    If Len(departmentValue) <> 3 Then Exit Function
    If Len(commentValue) <> 8 Then Exit Function

    Set values = CreateObject("Scripting.Dictionary")

    If values Is Nothing Then Exit Function

    values.CompareMode = vbTextCompare

    values.Add VARIABLE_MODEL_NAME, VALUE_MODEL_NAME

    If includeGateDate Then
        values.Add VARIABLE_GATE_DATE, VALUE_GATE_DATE
    End If

    values.Add VARIABLE_DEPARTMENT, departmentValue
    values.Add VARIABLE_COMMENT, commentValue

    fixturePass = True
    Set BuildFormattedValues = values

End Function

Private Function BuildDepartmentValue() As String

    ' Unicode fixture construction avoids Japanese String Literal drift.
    ' •iŽ¿•”
    BuildDepartmentValue = _
        ChrW(&H54C1&) & _
        ChrW(&H8CEA&) & _
        ChrW(&H90E8&)

End Function

Private Function BuildCommentValue() As String

    ' Unicode fixture construction avoids Japanese String Literal drift.
    ' Šm”F‚¨Šè‚¢‚µ‚Ü‚·
    BuildCommentValue = _
        ChrW(&H78BA&) & _
        ChrW(&H8A8D&) & _
        ChrW(&H304A&) & _
        ChrW(&H9858&) & _
        ChrW(&H3044&) & _
        ChrW(&H3057&) & _
        ChrW(&H307E&) & _
        ChrW(&H3059&)

End Function

Private Function ValidateNoUnresolvedResult( _
    ByVal operationResult As COperationResult, _
    ByVal unresolvedResult As Object _
) As Boolean

    Dim variables As Collection
    Dim hasUnresolved As Boolean

    On Error GoTo Failed

    If operationResult Is Nothing Then Exit Function
    If Not operationResult.Success Then Exit Function

    If unresolvedResult Is Nothing Then Exit Function

    If StrComp( _
        TypeName(unresolvedResult), _
        "Dictionary", _
        vbTextCompare _
    ) <> 0 Then
        Exit Function
    End If

    If Not unresolvedResult.Exists(KEY_HAS_UNRESOLVED) Then Exit Function
    If Not unresolvedResult.Exists(KEY_VARIABLES) Then Exit Function

    If VarType( _
        unresolvedResult.Item(KEY_HAS_UNRESOLVED) _
    ) <> vbBoolean Then
        Exit Function
    End If

    hasUnresolved = CBool( _
        unresolvedResult.Item(KEY_HAS_UNRESOLVED))

    Set variables = unresolvedResult.Item(KEY_VARIABLES)

    If variables Is Nothing Then Exit Function

    ValidateNoUnresolvedResult = _
        (Not hasUnresolved) And _
        (variables.Count = 0)

    Exit Function

Failed:
    ValidateNoUnresolvedResult = False

End Function

Private Function ValidateExpectedGateDateUnresolved( _
    ByVal unresolvedResult As Object _
) As Boolean

    Dim variables As Collection
    Dim hasUnresolved As Boolean

    On Error GoTo Failed

    If unresolvedResult Is Nothing Then Exit Function

    If StrComp( _
        TypeName(unresolvedResult), _
        "Dictionary", _
        vbTextCompare _
    ) <> 0 Then
        Exit Function
    End If

    If Not unresolvedResult.Exists(KEY_HAS_UNRESOLVED) Then Exit Function
    If Not unresolvedResult.Exists(KEY_VARIABLES) Then Exit Function

    If VarType( _
        unresolvedResult.Item(KEY_HAS_UNRESOLVED) _
    ) <> vbBoolean Then
        Exit Function
    End If

    hasUnresolved = CBool( _
        unresolvedResult.Item(KEY_HAS_UNRESOLVED))

    Set variables = unresolvedResult.Item(KEY_VARIABLES)

    If variables Is Nothing Then Exit Function

    ValidateExpectedGateDateUnresolved = _
        hasUnresolved And _
        (variables.Count = 1) And _
        CollectionContainsText( _
            variables, _
            VARIABLE_GATE_DATE)

    Exit Function

Failed:
    ValidateExpectedGateDateUnresolved = False

End Function

Private Function CollectionContainsText( _
    ByVal values As Collection, _
    ByVal expectedValue As String _
) As Boolean

    Dim item As Variant

    If values Is Nothing Then Exit Function

    For Each item In values

        If StrComp( _
            CStr(item), _
            expectedValue, _
            vbTextCompare _
        ) = 0 Then

            CollectionContainsText = True
            Exit Function

        End If

    Next item

End Function

Private Function TryAcquireOutlookApplication( _
    ByRef outlookApp As Object, _
    ByVal attempts As Long _
) As Boolean

    Dim attemptIndex As Long

    Set outlookApp = Nothing

    If attempts < 1 Then attempts = 1

    For attemptIndex = 1 To attempts

        On Error Resume Next
        Set outlookApp = GetObject(, "Outlook.Application")
        On Error GoTo 0

        If Not outlookApp Is Nothing Then
            TryAcquireOutlookApplication = True
            Exit Function
        End If

        DoEvents

    Next attemptIndex

End Function

Private Function CaptureEvidence( _
    ByVal outlookApp As Object, _
    ByRef explorerCount As Long, _
    ByRef inspectorCount As Long, _
    ByRef draftCount As Long _
) As Boolean

    Dim outlookNamespace As Object
    Dim draftsFolder As Object

    explorerCount = -1
    inspectorCount = -1
    draftCount = -1

    On Error GoTo Failed

    If outlookApp Is Nothing Then Exit Function

    explorerCount = CLng(outlookApp.Explorers.Count)
    inspectorCount = CLng(outlookApp.Inspectors.Count)

    Set outlookNamespace = outlookApp.GetNamespace("MAPI")

    If outlookNamespace Is Nothing Then GoTo Failed

    Set draftsFolder = outlookNamespace.GetDefaultFolder( _
        OL_FOLDER_DRAFTS)

    If draftsFolder Is Nothing Then GoTo Failed

    draftCount = CLng(draftsFolder.Items.Count)

    CaptureEvidence = True

CleanUp:
    Set draftsFolder = Nothing
    Set outlookNamespace = Nothing
    Exit Function

Failed:
    CaptureEvidence = False
    Resume CleanUp

End Function

Private Function ResultIsSuccess( _
    ByVal operationResult As COperationResult _
) As Boolean

    If operationResult Is Nothing Then Exit Function

    ResultIsSuccess = operationResult.Success

End Function

Private Function ConfirmDisplayedMailAndClose() As Boolean

    Dim response As VbMsgBoxResult

    response = MsgBox( _
        "Confirm the final MailItem is displayed and has NOT been sent." & _
            vbCrLf & vbCrLf & _
        "Then close the displayed MailItem WITHOUT saving." & _
            vbCrLf & _
        "After it is closed, click Yes." & _
            vbCrLf & vbCrLf & _
        "Click No if the displayed / unsent condition is not correct.", _
        vbYesNo + vbQuestion, _
        "P1-07 Display Verification")

    ConfirmDisplayedMailAndClose = (response = vbYes)

End Function

Private Sub PromptManualCleanupIfNeeded()

    MsgBox _
        "If a generated MailItem is visible, close it WITHOUT saving." & _
            vbCrLf & _
        "This test harness will not close a success-path displayed MailItem.", _
        vbOKOnly + vbExclamation, _
        "P1-07 Manual Cleanup"

End Sub

Private Sub PumpEvents()

    Dim i As Long

    For i = 1 To EVENT_PUMP_COUNT
        DoEvents
    Next i

End Sub

Private Sub PrintUnresolvedResult( _
    ByVal unresolvedResult As Object _
)

    Dim variables As Collection
    Dim item As Variant

    On Error GoTo PrintFailed

    If unresolvedResult Is Nothing Then
        Debug.Print "Unresolved Result: Nothing"
        Exit Sub
    End If

    Debug.Print _
        "HasUnresolved=" & _
        CStr(unresolvedResult.Item(KEY_HAS_UNRESOLVED))

    Set variables = unresolvedResult.Item(KEY_VARIABLES)

    If variables Is Nothing Then
        Debug.Print "Variables: Nothing"
        Exit Sub
    End If

    Debug.Print "Variables.Count=" & CStr(variables.Count)

    For Each item In variables
        Debug.Print "Variable=" & CStr(item)
    Next item

    Exit Sub

PrintFailed:
    Debug.Print "Unresolved Result: unable to print evidence."

End Sub

Private Sub PrintOperationResult( _
    ByVal operationResult As COperationResult _
)

    Dim errors As Collection
    Dim errorInfo As CErrorInfo

    On Error GoTo PrintFailed

    If operationResult Is Nothing Then
        Debug.Print "Operation Result: Nothing"
        Exit Sub
    End If

    Debug.Print _
        "Operation Result Success=" & _
        CStr(operationResult.Success)

    Set errors = operationResult.Errors

    For Each errorInfo In errors

        Debug.Print _
            "ErrorType=" & errorInfo.ErrorType & _
            "; Target=" & errorInfo.Target & _
            "; Message=" & errorInfo.Message

    Next errorInfo

    Exit Sub

PrintFailed:
    Debug.Print "Operation Result: unable to print error evidence."

End Sub

Private Sub PrintHeader(ByVal title As String)

    Debug.Print
    Debug.Print String$(72, "=")
    Debug.Print title
    Debug.Print String$(72, "=")

End Sub

Private Sub PrintCount( _
    ByVal labelText As String, _
    ByVal value As Long _
)

    Debug.Print labelText & ": " & CStr(value)

End Sub

Private Sub PrintPass(ByVal labelText As String)

    Debug.Print labelText & ": PASS"

End Sub

Private Sub PrintFail( _
    ByVal labelText As String, _
    ByVal detailText As String _
)

    Debug.Print labelText & ": FAIL"
    Debug.Print "  " & detailText

End Sub

Private Sub PrintBlocked( _
    ByVal labelText As String, _
    ByVal detailText As String _
)

    Debug.Print labelText & ": BLOCKED"
    Debug.Print "  " & detailText

End Sub

Private Sub PrintOverall(ByVal resultText As String)

    Debug.Print
    Debug.Print "Overall: " & resultText
    Debug.Print String$(72, "=")

End Sub
