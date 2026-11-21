#!/usr/bin/env python3
"""Source-only audit; DOES NOT compile or execute VBA."""
from pathlib import Path
import re
import json
import hashlib

root = Path(__file__).resolve().parents[1]
prod_path = root / 'src/modInputState_P3-05_Candidate_v0.1_CP932.bas'
test_path = root / 'tests/modP305InputStateCandidateTests_v0.1_CP932.bas'
raw_prod = prod_path.read_bytes()
raw_test = test_path.read_bytes()
prod = raw_prod.decode('cp932')
test = raw_test.decode('cp932')
checks = []

def check(name, passed, detail=''):
    checks.append({'id': f'S{len(checks)+1:02d}', 'check': name, 'result': 'PASS' if passed else 'FAIL', 'detail': detail})

def api_declarations(s):
    return re.findall(r'^Public Function\s+(\w+)\s*\(', s, re.M)

check('Production valid CP932 roundtrip', prod.encode('cp932') == raw_prod)
check('Fixture valid CP932 roundtrip', test.encode('cp932') == raw_test)
check('Production CRLF only', raw_prod.count(b'\r\n') == raw_prod.count(b'\n') and b'\n' in raw_prod)
check('Fixture CRLF only', raw_test.count(b'\r\n') == raw_test.count(b'\n') and b'\n' in raw_test)
check('Correct Production VB_Name', 'Attribute VB_Name = "modInputState"' in prod)
check('Correct fixture VB_Name', 'Attribute VB_Name = "modP305InputStateCandidateTests"' in test)
check('Option Explicit in both', prod.count('Option Explicit') == 1 and test.count('Option Explicit') == 1)
check('Only three public Production APIs', api_declarations(prod) == ['SetInputValue', 'TryGetInputValue', 'ClearInputValues'], str(api_declarations(prod)))
check('State store private at module scope', 'Private mInputValues As Object' in prod and 'Public mInputValues' not in prod)
check('Dictionary used for in-memory storage', 'CreateObject("Scripting.Dictionary")' in prod)
check('Case insensitive dictionary', 'candidate.CompareMode = vbTextCompare' in prod)
check('Init candidate before assignment to global', prod.index('candidate.CompareMode = vbTextCompare') < prod.index('Set mInputValues = candidate'))
check('Write handles add and replace', '.Exists(variableName)' in prod and 'mInputValues.Add variableName, inputText' in prod and 'mInputValues.Item(variableName) = inputText' in prod)
check('No input text Trim/Format', not re.search(r'(Trim\$?|Format\$?)\s*\(\s*inputText', prod))
check('Empty/absent lookup uses hasValue flag', 'hasValue = False' in prod and 'hasValue = True' in prod and '.Exists(variableName)' in prod)
check('Lookup clears both outputs before read', re.search(r'Public Function TryGetInputValue\([\s\S]+?hasValue = False\s+inputText = vbNullString\s+On Error GoTo', prod) is not None)
check('Both access paths validate blank key', prod.count('If Len(Trim$(variableName)) = 0 Then') == 2)
check('Clear removes all entries', 'mInputValues.RemoveAll' in prod)
check('Clear of uninitialized store safe', 'If Not mInputValues Is Nothing Then' in prod)
check('Failure uses existing COperationResult model', all(t in prod for t in ['CreateSuccessResult()', 'CreateFailureResult(', 'As COperationResult']))
check('Expected error taxonomy', all(s in prod for s in ['"ConfigurationError"', '"UnexpectedError"']))
check('No direct Excel/Outlook/Word/UserForm dependencies', not re.search(r'\b(ThisWorkbook|Worksheets?|ListObject|Outlook|WordEditor|MailItem|UserForm|MSForms)\b', '\n'.join(x for x in prod.splitlines() if not x.strip().startswith("'")), flags=re.I))
check('No persistence/network/MsgBox/Debug in Production', not re.search(r'\b(SaveAs|Open\s+.*\s+For|Write\s+#|Print\s+#|FileSystemObject|XMLHTTP|MsgBox|Debug\.Print)\b', prod, flags=re.I))
check('No retry/sleep/doevents in Production', not re.search(r'\b(DoEvents|Sleep|Retry|Application\.Wait)\b', '\n'.join(x for x in prod.splitlines() if not x.strip().startswith("'")), flags=re.I))
check('No Object/Dictionary reference exposed via Public', not re.search(r'^Public Function .*\bAs Object\b', prod, re.M) and 'ByRef store As Object' not in prod)
check('Production Function ends balanced', len(re.findall(r'^(?:Public|Private) Function\b', prod, re.M)) == len(re.findall(r'^End Function\s*$', prod, re.M)))
check('Fixture has one public runner', re.findall(r'^Public Sub\s+(\w+)', test, re.M) == ['RunP305InputStateCandidateTests'])
ids = re.findall(r'RecordCase\s+"(P305-C\d\d_[A-Z0-9_]+)"', test)
check('18 unique test IDs', len(ids) == 18 and len(set(ids)) == 18, f'count={len(ids)}')
check('All case IDs C01-C18', sorted(re.findall(r'P305-C(\d\d)_', '\n'.join(ids))) == [f'{i:02}' for i in range(1,19)])
check('Fixture tests core APIs', all(s in test for s in ['SetInputValue(', 'TryGetInputValue(', 'ClearInputValues()']))
check('Fixture tests false/zero/blank/non-ASCII', all(s in test for s in ['"False"', '"0"', 'vbNullString', '設計部']))
check('Fixture uses P0 error model rather than stub result', 'CErrorInfo' in test and 'COperationResult' in test and 'Class COperationResult' not in test)
check('Fixture does not define production APIs', not re.search(r'^(Public|Private) Function (SetInputValue|TryGetInputValue|ClearInputValues)\b', test, re.M))
check('Fixture has no Form/Outlook/Excel invocation', not re.search(r'\b(CreateMailFromTemplate|ShowMailGeneratorForm|BuildValidatedInputs|ExecuteManualSync|ThisWorkbook|Worksheets)\b', test))
check('Fixture Sub/Function structure balanced', len(re.findall(r'^(?:Public|Private) Function\b', test, re.M)) == len(re.findall(r'^End Function\s*$', test, re.M)) and len(re.findall(r'^(?:Public|Private) Sub\b', test, re.M)) == len(re.findall(r'^End Sub\s*$', test, re.M)))
check('No line above conservative 1000-character limit', max(map(len, prod.splitlines())) < 1000 and max(map(len, test.splitlines())) < 1000)

result = {
    'document_id': 'P3-05-STATIC-REVIEW-20261121',
    'date': '2026-11-21',
    'scope': 'Source-only textual/structural checks; no VBE Compile or VBA runtime execution',
    'production_source_sha256': hashlib.sha256(raw_prod).hexdigest(),
    'test_fixture_sha256': hashlib.sha256(raw_test).hexdigest(),
    'check_count': len(checks),
    'pass_count': sum(x['result'] == 'PASS' for x in checks),
    'fail_count': sum(x['result'] == 'FAIL' for x in checks),
    'vba_compile': 'NOT VERIFIED',
    'vba_runtime': 'NOT RUN',
    'formal_MTS_input': 'NOT RUN',
    'checks': checks,
}
(root/'verification/P3-05_Static_Audit_20261121.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
print(f"Source static audit: {result['pass_count']}/{result['check_count']} PASS; {result['fail_count']} FAIL")
for ch in checks:
    if ch['result'] != 'PASS': print(ch)
if result['fail_count']:
    raise SystemExit(1)
