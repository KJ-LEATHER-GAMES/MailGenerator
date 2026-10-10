Attribute VB_Name = "modResult"
Option Explicit

Public Function CreateSuccessResult() As COperationResult
    Dim result As COperationResult

    Set result = New COperationResult
    Set CreateSuccessResult = result
End Function

Public Function CreateFailureResult( _
    ByVal errorType As String, _
    ByVal message As String, _
    Optional ByVal target As String = "" _
) As COperationResult

    Dim result As COperationResult

    Set result = New COperationResult
    AddError result, errorType, message, target

    Set CreateFailureResult = result
End Function

Public Sub AddError( _
    ByRef result As COperationResult, _
    ByVal errorType As String, _
    ByVal message As String, _
    Optional ByVal target As String = "" _
)

    Dim errorInfo As CErrorInfo

    If result Is Nothing Then
        Set result = New COperationResult
    End If

    Set errorInfo = New CErrorInfo
    errorInfo.ErrorType = errorType
    errorInfo.Message = message
    errorInfo.Target = target

    result.AppendError errorInfo
End Sub
