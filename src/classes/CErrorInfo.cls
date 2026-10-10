VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CErrorInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mErrorType As String
Private mMessage As String
Private mTarget As String

Public Property Get ErrorType() As String
    ErrorType = mErrorType
End Property

Public Property Let ErrorType(ByVal value As String)
    mErrorType = value
End Property

Public Property Get Message() As String
    Message = mMessage
End Property

Public Property Let Message(ByVal value As String)
    mMessage = value
End Property

Public Property Get Target() As String
    Target = mTarget
End Property

Public Property Let Target(ByVal value As String)
    mTarget = value
End Property
