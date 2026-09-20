VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "COperationResult"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mSuccess As Boolean
Private mErrors As Collection

Private Sub Class_Initialize()
    mSuccess = True
    Set mErrors = New Collection
End Sub

Public Property Get Success() As Boolean
    Success = mSuccess
End Property

Public Property Get Errors() As Collection
    Dim snapshot As Collection
    Dim errorInfo As CErrorInfo

    Set snapshot = New Collection

    For Each errorInfo In mErrors
        snapshot.Add errorInfo
    Next errorInfo

    Set Errors = snapshot
End Property

Friend Sub AppendError(ByVal errorInfo As CErrorInfo)
    If errorInfo Is Nothing Then Exit Sub

    mErrors.Add errorInfo
    mSuccess = False
End Sub
