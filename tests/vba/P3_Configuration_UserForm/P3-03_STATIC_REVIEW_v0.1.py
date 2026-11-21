from pathlib import Path
import re, hashlib, sys
here = Path(__file__).resolve().parent.parent
srcp = here / 'src/modP3UserFormLaunchGate_P3-03_Candidate_v0.1_CP932.bas'
stubp = here / 'tests/modP3_03GateTestStub_v0.1_CP932.bas'
runnerp = here / 'tests/modP3_03LaunchGateCandidateTests_v0.1_CP932.bas'
files = [srcp,stubp,runnerp]
sources = [p.read_bytes().decode('cp932') for p in files]
s, stub, runner = sources
results=[]
def check(name, pred):
    try: ok=bool(pred())
    except Exception as exc: ok=False
    results.append((name,ok))
    print(('PASS' if ok else 'FAIL') + ' ' + name)

# NOTE: These are static text/invariant checks only; NEVER claims VBA Compile.
check('Three intended VBA files exist',lambda:all(p.is_file() for p in files))
check('All VBA files decode and CP932 round-trip',lambda:all(p.read_bytes()==s0.encode('cp932') for p,s0 in zip(files,sources)))
check('All VBA source files use CRLF',lambda:all(b'\r\n' in p.read_bytes() and b'\n' not in p.read_bytes().replace(b'\r\n',b'') for p in files))
check('Option Explicit in all files',lambda:all('Option Explicit' in x for x in sources))
check('Correct production module name',lambda:'Attribute VB_Name = "modP3UserFormLaunchGate"' in s)
check('Only one Public Production function',lambda:re.findall(r'(?im)^Public Function (\w+)',s)==['PrepareUserFormLaunch'])
check('Public API return type is COperationResult',lambda:re.search(r'(?s)Public Function PrepareUserFormLaunch\(.+?\) As COperationResult',s) is not None)
check('Two output ByRef parameters',lambda:re.search(r'ByRef sortedActiveDefinitions As Collection',s) is not None and re.search(r'ByRef activeOptionsByGroup As Object',s) is not None)
check('P3-02 source call used',lambda:len(re.findall(r'\bPrepareCurrentConfiguration\s*\(',s))==1)
check('Result Nothing guard exists',lambda:'If stepResult Is Nothing Then' in s)
check('Upstream Failure result passed by reference',lambda:'Set PrepareUserFormLaunch = stepResult' in s)
check('Sort function called only after upstream Success guard',lambda:s.index('If Not stepResult.Success Then')<s.index('SortActiveDefinitions(allDefinitions, sortedCandidate)'))
check('Outputs initialized to Nothing',lambda:'Set sortedActiveDefinitions = Nothing' in s and 'Set activeOptionsByGroup = Nothing' in s)
check('Output publication happens after all guards',lambda:s.index('Set sortedActiveDefinitions = sortedCandidate')>s.index('SortActiveDefinitions(allDefinitions, sortedCandidate)'))
check('Status filters Active/Unused',lambda:'"Active"' in s and '"Unused"' in s)
check('SortOrder is ascending',lambda:'sortKey < priorSortKey' in s)
check('Tie breaks by __RowIndex',lambda:'sortKey = priorSortKey And rowIndex < priorIndex' in s)
check('Stable insertion via new collection',lambda:'Set sortedCandidate = New Collection' in s and 'sortedCandidate.Add item, Before:=insertionPoint' in s)
check('Double sort key conversion guarded',lambda:'On Error GoTo InvalidValue' in s and 'sortKey = CDbl(rawValue)' in s)
check('Boolean SortOrder rejected',lambda:'If VarType(rawValue) = vbBoolean Then Exit Function' in s)
check('Row index positive integer / Long bounds',lambda:'numericValue > 2147483647#' in s and 'numericValue <> Fix(numericValue)' in s)
check('Duplicate row index detected',lambda:'seenRowNumbers.Exists(CStr(rowIndex))' in s)
check('Config/Carrier errors have distinct types',lambda:'ERROR_CONFIGURATION' in s and 'ERROR_UNEXPECTED' in s)
check('No runtime Sheet/Outlook/Form/Sync in production code',lambda:not re.search(r'(?im)^\s*(?:Set\s+\w+\s*=\s*)?(?:ExecuteManualSync|ApplySyncDiff|GetAllVariableDefinitions|CreateMailFromTemplate|Show|MsgBox|GetSettingValue|GetActiveOptions)\s*\(?',s))
check('No VBA Worksheet/Outlook UI tokens in non-comment code',lambda:not re.search(r'\b(ThisWorkbook|Worksheet|ListObject|CreateItemFromTemplate|\.Show|frmMailGenerator|\bDebug\.Print\b)\b', '\n'.join(x for x in s.splitlines() if not x.strip().startswith("'"))))
check('Function and End Function counts balanced',lambda:len(re.findall(r'(?m)^(?:Public|Private) Function ',s))==len(re.findall(r'(?m)^End Function\s*$',s)))
check('Stub defines public dependency function exactly once',lambda:len(re.findall(r'(?m)^Public Function PrepareCurrentConfiguration\(',stub))==1)
check('Stub has exactly one numbered reset per case',lambda:'P3GateStubReset caseId' in runner and 'mScenario = scenarioId' in stub)
check('Runner covers cases 1 through 21',lambda:'For caseId = 1 To 21' in runner and 'DEV-P3GATE-' in runner)
check('Runner checks result and no-output on failure',lambda:'result.Success = isSuccess' in runner and '(sorted Is Nothing)' in runner and '(groups Is Nothing)' in runner)
check('Runner checks upstream result identity',lambda:'(result Is upstreamResult)' in runner)
check('Runner checks source order unchanged',lambda:'JoinNames(original)' in runner)
check('No test stub calls actual Excel/Outlook',lambda:not re.search(r'\b(ThisWorkbook|CreateItemFromTemplate|Worksheets|ListObject|GetObject\s*\(|CreateObject\(\s*"Outlook)',stub,re.I))
check('Code lines below 1023 char VBA limit',lambda:all(max((len(l) for l in t.splitlines()),default=0)<1023 for t in sources))
check('No source docs claim formal gate',lambda:'NOT FORMAL' in runner and 'not approved' in s.lower())
passed=sum(x for _,x in results)
print(f'\nSTATIC ONLY: {passed}/{len(results)} PASS (VBA COMPILE/TEST EXECUTION NOT PERFORMED)')
sys.exit(0 if passed==len(results) else 1)
