Attribute VB_Name = "modP2_03SyncPersistenceV012RegressionSuite"
Option Explicit

' P2-03 v0.1.2 Regression Suite Runner
'
' Entry point:
'   TestP203SyncPersistenceV012RegressionSuite

Public Sub TestP203SyncPersistenceV012RegressionSuite()

    Debug.Print String$(80, "=")
    Debug.Print "P2-03 v0.1.2 Regression Suite"
    Debug.Print "Execution Baseline = BL-MVP-004"
    Debug.Print String$(80, "=")

    Debug.Print
    Debug.Print "[1/5] Existing Bootstrap Regression - Expected 7 / 7 PASS"
    TestP203SyncPersistenceBootstrapRegression

    Debug.Print
    Debug.Print "[2/5] BL-MVP-004 Detection History Persistence Regression - Expected 6 / 6 PASS"
    TestP203SyncPersistenceDetectionHistoryRegression

    Debug.Print
    Debug.Print "[3/5] Existing Core Regression - Expected 12 / 12 PASS"
    TestP203SyncPersistenceCore

    Debug.Print
    Debug.Print "[4/5] Existing Technical Negative Regression - Expected 18 / 18 PASS"
    TestP203SyncPersistenceTechnicalNegative

    Debug.Print
    Debug.Print "[5/5] Existing Compatibility Regression - Expected 3 / 3 PASS"
    TestP203SyncPersistenceCompatibility

    Debug.Print
    Debug.Print String$(80, "-")
    Debug.Print "Expected aggregate cases = 46 PASS / 0 FAIL"
    Debug.Print "Confirm each child test prints Overall = PASS."
    Debug.Print "This suite is Implementation Verification, not Formal MVP Test."
    Debug.Print String$(80, "=")

End Sub
