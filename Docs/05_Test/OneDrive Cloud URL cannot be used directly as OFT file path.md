Finding ID:
DF-P1-001

Title:
OneDrive Cloud URL cannot be used directly as OFT file path

Observed:
ThisWorkbook.Path returns
https://d.docs.live.net/...

ResolveWorkbookRelativePath therefore returns
https://d.docs.live.net/.../Templates/MailTemplate.oft

CreateMailFromTemplate:
FAIL

Control Test:
C:\Users\monsi\OneDrive\...\Templates\MailTemplate.oft
→ PASS

Classification:
Design Finding

Requirement Gap:
None identified

Outlook Adapter Defect:
None identified