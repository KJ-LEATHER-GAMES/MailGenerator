Attribute VB_Name = "TestResultModel"
Option Explicit

Public Sub TestResultModel()

    Dim result As COperationResult
    Dim errorInfo As CErrorInfo

    ' Success
    Set result = CreateSuccessResult()

    Debug.Assert result.Success = True
    Debug.Assert result.Errors.Count = 0

    ' Add first error
    AddError result, _
        "ConfigurationError", _
        "Required setting was not found.", _
        "TemplatePath"

    Debug.Assert result.Success = False
    Debug.Assert result.Errors.Count = 1

    Set errorInfo = result.Errors(1)

    Debug.Assert errorInfo.ErrorType = "ConfigurationError"
    Debug.Assert errorInfo.Message = "Required setting was not found."
    Debug.Assert errorInfo.Target = "TemplatePath"

    ' Multiple errors
    AddError result, _
        "ConfigurationError", _
        "Another setting was not found.", _
        "VariableDefinition"

    Debug.Assert result.Errors.Count = 2

    ' Failure factory
    Set result = CreateFailureResult( _
        "UnexpectedError", _
        "Unexpected processing error.")

    Debug.Assert result.Success = False
    Debug.Assert result.Errors.Count = 1

End Sub