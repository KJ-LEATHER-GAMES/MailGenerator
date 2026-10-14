Attribute VB_Name = "modP2_02SyncDiffV013RegressionSuite"
Option Explicit

' P2-02 v0.1.3 Regression Suite Runner
'
' Entry point:
'   TestP202SyncDiffV013RegressionSuite

Public Sub TestP202SyncDiffV013RegressionSuite()

    Debug.Print String$(80, "=")
    Debug.Print "P2-02 v0.1.3 Regression Suite"
    Debug.Print "Execution Baseline = BL-MVP-004"
    Debug.Print String$(80, "=")

    Debug.Print
    Debug.Print "[1/6] Existing Bootstrap Regression - Expected 33 / 33 PASS"
    TestP202SyncDiffBootstrapRegression

    Debug.Print
    Debug.Print "[2/6] BL-MVP-004 Detection History Regression - Expected 43 / 43 PASS"
    TestP202SyncDiffDetectionHistoryRegression

    Debug.Print
    Debug.Print "[3/6] Excel Date Serial Compatibility Regression - Expected 9 / 9 PASS"
    TestP202SyncDiffDateSerialRegression

    Debug.Print
    Debug.Print "[4/6] Existing Core Regression - Expected 18 / 18 PASS"
    TestP202SyncDiffCore

    Debug.Print
    Debug.Print "[5/6] Existing Technical Negative Regression - Expected 6 / 6 PASS"
    TestP202SyncDiffTechnicalNegative

    Debug.Print
    Debug.Print "[6/6] Existing Contract Compatibility - Expected 2 / 2 PASS"
    TestP202SyncDiffContractCompatibility

    Debug.Print
    Debug.Print String$(80, "-")
    Debug.Print "Expected aggregate assertions = 111 PASS / 0 FAIL"
    Debug.Print "Confirm each child test prints Overall = PASS."
    Debug.Print "This suite is Implementation Verification, not Formal MVP Test."
    Debug.Print String$(80, "=")

End Sub
