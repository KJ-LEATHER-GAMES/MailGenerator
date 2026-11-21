from pathlib import Path
import re
root=Path(__file__).resolve().parent.parent
source=(root/'src/modConfigurationApplication_P3-02_Candidate_v0.1_CP932.bas').read_bytes()
stubs=(root/'tests/modP3_02TestStubs_v0.1_CP932.bas').read_bytes()
runner=(root/'tests/modP3_02ConfigurationApplicationCandidateTests_v0.1_CP932.bas').read_bytes()
asserts=[]
def check(label,cond):
    asserts.append((label,bool(cond)))
for p,b in [('app',source),('stubs',stubs),('runner',runner)]:
    check(p+' CP932 reversible',b.decode('cp932').encode('cp932')==b)
    check(p+' CRLF',b'\r\n' in b and b'\n' not in b.replace(b'\r\n',b''))
s=source.decode('cp932');t=stubs.decode('cp932');u=runner.decode('cp932')
check('Production exported only one function', len(re.findall(r'^Public Function\s+',s,re.M))==1 and 'Public Function PrepareCurrentConfiguration(' in s)
check('No Production public test hooks',len(re.findall(r'^Public Sub\s+',s,re.M))==0)
check('Dependencies exposed in pipeline',all(x in s for x in ['GetSettingValue(', 'ResolveWorkbookRelativePath(', 'CreateMailFromTemplate(', 'ReadSubject(', 'ReadBodyText(', 'ScanTemplate(', 'CloseWithoutSave()', 'GetAllVariableDefinitions(', 'GetActiveOptions(', 'ValidateConfiguration(']))
check('Read/scan/cleanup and application steps ordered',s.index('Set stepResult = ReadSubject(')<s.index('Set stepResult = ReadBodyText(')<s.index('Set stepResult = ScanTemplate(')<s.index('Set cleanupResult = CloseWithoutSave()') and s.index('Set stepResult = CaptureCurrentTemplateScan(')<s.index('Set stepResult = GetAllVariableDefinitions(')<s.index('Set stepResult = LoadActiveOptionSnapshots(')<s.index('Set stepResult = ValidateConfiguration('))
check('Only publishes success outputs after validation',s.index('Set stepResult = ValidateConfiguration(')<s.index('Set templateScanResult = localScan'))
check('First failure preserved after cleanup', 'ElseIf terminalResult.Success Then' in s and 'Set terminalResult = cleanupResult' in s)
check('No Production direct COM/Excel or UI generation',not re.search(r'\b(?:GetObject|Worksheet|ListObject|Worksheets|MsgBox|Controls\.Add|DisplayMail)\b|CreateObject\("Outlook', '\n'.join(line for line in s.splitlines() if not line.lstrip().startswith("'")),re.I))
check('No sync or persistence calls',not re.search(r'(?im)^\s*(?:Set \w+ = |Call )?(?:ExecuteManualSync|ApplySyncDiff|BuildSyncDiff)\s*\(',s))
check('Strict OptionGroup carrier cache', 'groups.CompareMode = vbBinaryCompare' in s and 'If Not groups.Exists(optionSource) Then' in s)
check('Unchanged upstream failure propagated', 'Set CheckOperation = result' in s)
check('Defined malformed outputs guards',all(x in s for x in ['If localScan Is Nothing Then','If localDefinitions Is Nothing Then','If localOptions Is Nothing Then']))
check('VBA block count Production',len(re.findall(r'^(?:Public|Private) Function ',s,re.M))==len(re.findall(r'^End Function',s,re.M)))
check('Stub functions cover all upstream APIs',all(re.search(r'^Public Function '+re.escape(x)+r'\(',t,re.M) for x in ['GetSettingValue','ResolveWorkbookRelativePath','CreateMailFromTemplate','ReadSubject','ReadBodyText','ScanTemplate','CloseWithoutSave','GetAllVariableDefinitions','GetActiveOptions']))
check('Stub blocks balanced',len(re.findall(r'^(?:Public|Private) (?:Function|Sub) ',t,re.M))==len(re.findall(r'^End (?:Function|Sub)',t,re.M)))
check('Runner scenarios cover 1 through 23', 'For scenarioId = 1 To 23' in u and 'mScenario = 23' in t and 'mScenario = 22' in t and '23' in u)
check('Runner success expectation 1 and 16 only', 'scenarioId = 1 Or scenarioId = 16' in u)
check('Runner validates no outputs on Failure',all(x in u for x in ['(scan Is Nothing)','(definitions Is Nothing)','(groups Is Nothing)']))
check('Runner checks cleanup and caching',all(x in u for x in ['P3StubCloseCalls()','P3StubOptionCalls() = 1','P3StubOptionCalls() = 0']))
check('Runner blocks balanced',len(re.findall(r'^(?:Public|Private) (?:Function|Sub) ',u,re.M))==len(re.findall(r'^End (?:Function|Sub)',u,re.M)))
for label,p in asserts:
    print(('PASS' if p else 'FAIL')+' '+label)
print(f'STATIC REVIEW: {sum(v for _,v in asserts)}/{len(asserts)} PASS (NOT VBA COMPILE OR EXECUTION)')
raise SystemExit(0 if all(v for _,v in asserts) else 1)
