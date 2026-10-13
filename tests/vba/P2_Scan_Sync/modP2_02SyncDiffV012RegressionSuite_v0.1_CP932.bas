Attribute VB_Name = "modP2_02SyncDiffV012RegressionSuite"
Option Explicit

' P2-02 v0.1.2 Regression Suite Runner
'
' This runner only orchestrates existing public test entry points.
' Each test module keeps its own PASS / FAIL judgment and assertion count.
'
' Entry point:
'   TestP202SyncDiffV012RegressionSuite

Public Sub TestP202SyncDiffV012RegressionSuite()

    Debug.Print String$(80, "=")
    Debug.Print "P2-02 v0.1.2 Regression Suite"
    Debug.Print "Execution Baseline = BL-MVP-004"
    Debug.Print String$(80, "=")

    Debug.Print
    Debug.Print "[1/5] Existing Bootstrap Regression - Expected 33 / 33 PASS"
    TestP202SyncDiffBootstrapRegression

    Debug.Print
    Debug.Print "[2/5] BL-MVP-004 Detection History Regression - Expected 43 / 43 PASS"
    TestP202SyncDiffDetectionHistoryRegression

    Debug.Print
    Debug.Print "[3/5] Existing Core Regression - Expected 18 / 18 PASS"
    TestP202SyncDiffCore

    Debug.Print
    Debug.Print "[4/5] Existing Technical Negative Regression - Expected 6 / 6 PASS"
    TestP202SyncDiffTechnicalNegative

    Debug.Print
    Debug.Print "[5/5] Existing Contract Compatibility - Expected 2 / 2 PASS"
    TestP202SyncDiffContractCompatibility

    Debug.Print
    Debug.Print String$(80, "-")
    Debug.Print "Expected aggregate assertions = 102 PASS / 0 FAIL"
    Debug.Print "Confirm each child test prints Overall = PASS."
    Debug.Print "This suite is Implementation Verification, not Formal MVP Test."
    Debug.Print String$(80, "=")

End Sub
