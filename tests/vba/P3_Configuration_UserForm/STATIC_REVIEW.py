from pathlib import Path
import re
root = Path(__file__).resolve().parent.parent
prod_path = root / 'src/modConfigurationValidator_P3-01_Candidate_v0.1.bas'
test_path = root / 'tests/modP3_01ConfigurationValidatorCandidateTests_v0.1.bas'
prod = prod_path.read_bytes().decode('cp932')
tests = test_path.read_bytes().decode('cp932')
results = {}
results['Production CP932 decode/roundtrip'] = prod.encode('cp932') == prod_path.read_bytes()
results['Tests CP932 decode/roundtrip'] = tests.encode('cp932') == test_path.read_bytes()
results['Single Production Public API'] = len(re.findall(r'^Public Function ', prod, re.M)) == 1 and 'Public Function ValidateConfiguration(' in prod
results['Production function blocks balanced'] = len(re.findall(r'(?m)^(Public|Private) Function ', prod)) == len(re.findall(r'(?m)^End Function',prod))
results['Test function blocks balanced'] = len(re.findall(r'(?m)^Private Function ',tests)) == len(re.findall(r'(?m)^End Function',tests))
results['Test sub blocks balanced'] = len(re.findall(r'(?m)^(Public|Private) Sub ',tests)) == len(re.findall(r'(?m)^End Sub',tests))
code_no_comment = '\n'.join(line for line in prod.splitlines() if not line.lstrip().startswith("'"))
results['No Excel/Outlook/UI APIs in Production'] = all(not re.search(r'\b'+x+r'\b',code_no_comment,re.I) for x in ['ExecuteManualSync','ApplySyncDiff','MsgBox','ThisWorkbook','ListObject','MailItem','Outlook','WordEditor','UserForm','FileSystemObject','Kill','SaveAs','DoEvents'])
results['Result API reuse'] = all(x in prod for x in ['CreateSuccessResult()', 'CreateFailureResult(', 'As COperationResult'])
results['Case-insensitive variable matching'] = prod.count('CompareMode = vbTextCompare') >= 2
results['Exact OptionGroup matching'] = 'StrComp(exactKey, groupName, vbBinaryCompare)' in prod
results['Six approved date formats'] = all(s in prod for s in ['yyyy/mm/dd','yyyy-mm-dd','yyyy年m月d日','m月d日','yyyy年m月d日(aaa)','m月d日(aaa)'])
results['Explicit False accepted'] = 'Case vbBoolean' in prod and 'boolValue = CBool(rawValue)' in prod
results['Test IDs 01-22 declared'] = 'For caseId = 1 To 22' in tests and all(re.search(r'^        Case '+str(i)+r'\b',tests,re.M) for i in range(1,23))
results['Test 19 external dependency scoped out'] = 'SKIP' in tests and 'Data Access failure propagation is Application responsibility' in tests
results['Test 06 UI sort not overclaimed'] = 'Row-order stability is NOT tested here' in tests
results['No test autorun through Workbook event'] = all(x not in tests for x in ['Workbook_Open','Auto_Open','Worksheet_Change'])
for k,v in results.items():print(('PASS' if v else 'FAIL')+' | '+k)
print('Static source checks:',sum(results.values()),'/',len(results))
if not all(results.values()): raise SystemExit(1)
