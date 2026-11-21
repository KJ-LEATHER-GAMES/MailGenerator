#!/usr/bin/env python3
"""Source-only invariants for P3-04 XU-02 A candidate. Does NOT compile or run VBA."""
from pathlib import Path
from hashlib import sha256
from zipfile import ZipFile
import json, re, sys, subprocess, tempfile, shutil

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src/frmMailGenerator_P3-04_XU01_XU02_A_Candidate_v0.1.frm'
CTRL=ROOT/'src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas'
STUB=ROOT/'tests/modP3_04GateStub_XU02_v0.1_CP932.bas'
RUNNER=ROOT/'tests/modP3_04XU02Tests_v0.1_CP932.bas'
BASE=Path('/mnt/data/P3-04_XU01_Gate_Enforced_Candidate_v0.1/src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm')
BASE_CTRL=Path('/mnt/data/P3-04_XU01_Gate_Enforced_Candidate_v0.1/src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas')
PATCH=ROOT/'docs/XU02_UTF8_Normalized_Review_Diff_v0.1.patch'

check=[]
def test(name, assertion, detail=''):
    check.append(dict(check=name,status='PASS' if assertion else 'FAIL',detail=detail))

def sec(text, head):
    match=re.search(r'(?im)^Private Function '+re.escape(head)+r'\(',text)
    if not match: return ''
    return text[match.start():text.index('End Function',match.start())+len('End Function')]

def normal(s):return s.replace('\r\n','\n').replace('\r','\n')

raw=SRC.read_bytes();form=raw.decode('cp932');u=normal(form)
ctrlraw=CTRL.read_bytes();ctrl=normal(ctrlraw.decode('cp932'))
stubraw=STUB.read_bytes();stub=normal(stubraw.decode('cp932'))
runraw=RUNNER.read_bytes();runner=normal(runraw.decode('cp932'))
functions={k:sec(u,k) for k in ['CreateDisplaySnapshot','BuildInputsFromSnapshot','AppendInputRow','TryGetGroup']}
copy=functions['CreateDisplaySnapshot'];render=functions['BuildInputsFromSnapshot'];append=functions['AppendInputRow'];group=functions['TryGetGroup']
pub=u[u.index('Public Function BuildValidatedInputs()'):u.index('End Function',u.index('Public Function BuildValidatedInputs()'))+len('End Function')]

# File identity and encoding
for file,data in [(SRC,raw),(CTRL,ctrlraw),(STUB,stubraw),(RUNNER,runraw)]:
    test('CP932 decode '+file.name, bool(data.decode('cp932')), 'bytes='+str(len(data)))
    test('CRLF newlines '+file.name, data.count(b'\r\n')==data.count(b'\n') and data.count(b'\n')>0)

test('Form VB_Name unchanged','Attribute VB_Name = "frmMailGenerator"' in u)
test('Only one public builder',len(re.findall(r'^Public Function BuildValidatedInputs\(',u,re.M))==1)
test('Public Builder no caller carriers','Public Function BuildValidatedInputs() As COperationResult' in u)
test('Gate remains mandatory',pub.count('PrepareUserFormLaunch(')==1)
test('Gate failure returns original Result','Set BuildValidatedInputs = gateResult' in pub)
test('Gate call occurs before copy',pub.index('PrepareUserFormLaunch(')<pub.index('CreateDisplaySnapshot('))
test('Copy returns COperationResult',bool(copy and re.search(r'\) As COperationResult',copy)))
test('Copy failure forwarded unchanged','Set BuildValidatedInputs = snapshotResult' in pub)
test('No render until successful copy',pub.index('If Not snapshotResult.Success Then')<pub.index('BuildInputsFromSnapshot(displaySnapshot)'))
test('Original row carrier released before render',pub.index('Set sortedActiveDefinitions = Nothing')<pub.index('BuildInputsFromSnapshot(displaySnapshot)'))
test('Original option carrier released before render',pub.index('Set activeOptionsByGroup = Nothing')<pub.index('BuildInputsFromSnapshot(displaySnapshot)'))
test('Render uses only displaySnapshot',bool(re.search(r'Private Function BuildInputsFromSnapshot\(\s*_\n\s*ByVal displaySnapshot As Collection',render)))
test('Copy includes no Controls.Add', 'Controls.Add(' not in copy)
test('Renderer adds via AppendInputRow', 'AppendInputRow(snapshotRow, itemIndex)' in render)
test('Renderer independent of original carriers', not any(x in render for x in ('sortedActiveDefinitions','activeOptionsByGroup','sourceRow','sourceOptions','TryGetGroup')))
test('Row append independent of source OptionGroup',not any(x in append for x in ('activeOptionsByGroup','optionGroups','TryGetGroup','sourceOption')))
test('New display row for each source row','For Each itemValue In sortedActiveDefinitions' in copy and 'Set snapshotRow = CreateObject("Scripting.Dictionary")' in copy)
test('New option collection for each source row','Set optionValues = New Collection' in copy)
test('Snapshot row primitive fields',all('snapshotRow.Add "'+x+'"' in copy for x in ('VariableName','DisplayName','Type','Required','Description','OptionSource')))
test('Snapshot option values are new strings','optionValues.Add valueText' in copy and 'snapshotRow.Add "OptionValues", optionValues' in copy)
test('Options source type checked','If TypeName(sourceOption) <> "Dictionary" Then GoTo InvalidRow' in copy)
test('No nested source option references in snapshot',not any(s in copy for s in ('optionValues.Add sourceOption','snapshotRow.Add "SourceRow"','snapshotRow.Add "Options", sourceOptions')))
test('One row added only after snapshot fields','candidate.Add snapshotRow' in copy and copy.index('snapshotRow.Add "OptionValues"')<copy.index('candidate.Add snapshotRow'))
test('Snapshot published only after all rows copied', copy.index('Next itemValue')<copy.index('Set displaySnapshot = candidate'))
test('Snapshot result only after copy completed', copy.index('Set displaySnapshot = candidate')<copy.index('Set CreateDisplaySnapshot = CreateSuccessResult()'))
test('Case sensitive OptionGroup via StrComp', 'vbBinaryCompare' in group and 'StrComp(CStr(k), requiredGroup, vbBinaryCompare)' in group)
test('Selected order preserved','For Each optionValue In sourceOptions' in copy and 'optionValues.Add valueText' in copy and 'For Each optionValue In optionItems' in append)
test('All source options preflight before controls',copy.index('For Each optionValue In sourceOptions')<copy.index('Set displaySnapshot = candidate') and 'Controls.Add(' not in copy)
test('No SortOrder logic duplicated in Form','SortOrder' not in copy and 'SortOrder' not in render and 'SortOrder' not in append)
test('Only one mBuilt=True post control loop',u.count('mBuilt = True')==1 and render.index('Next snapshotValue')<render.index('mBuilt = True'))
test('Render failure removes controls','RemoveDynamicControls' in render and 'mBuilt = False' in render)
test('Direct Show guard unchanged','Private Sub UserForm_Activate()\n    If Not mBuilt Then Me.Hide' in u)
test('No state or email added','SetInputValue(' not in u and 'TryGetInputValue(' not in u and 'CreateMailFromTemplate(' not in u)
test('Clear/Create stay disabled','Me.cmdCreateMail.Enabled = False' in render and 'Me.cmdClear.Enabled = False' in render)
test('Text/Date single-line',' .MultiLine = False' in append or '.MultiLine = False' in append)
test('Select list-only','fmStyleDropDownList' in append)
test('Binding Tag remains',' .Tag = variableName' in append or '.Tag = variableName' in append)
test('Controller still calls public builder', 'Set stepResult = localForm.BuildValidatedInputs()' in ctrl)
test('Controller Show behind Success','If Not stepResult.Success Then' in ctrl and 'newForm.Show vbModal' in ctrl)
test('No production version embedded in runner','Public Sub RunP304XU02CandidateTests()' in runner and 'Attribute VB_Name = "modP3_04XU02Tests"' in runner)
test('Stub API collision explained','TEST-ONLY STUB' in stub and 'PrepareUserFormLaunch(' in stub)
test('Stub exposes source references for mutation tests','Public P304SourceRows As Collection' in stub and 'Public P304SourceGroups As Object' in stub)

case_match=re.search(r'cases\s*=\s*Array\((.*?)\)\s*\n\s*For Each key',runner,re.S)
ids=re.findall(r'"([A-Z_]+)"',case_match.group(1)) if case_match else []
test('35 distinct scenario IDs',len(ids)==35 and len(set(ids))==35,'count='+str(len(ids)))
for key in ('SOURCE_ROW_MUTATION','SOURCE_OPTION_MUTATION','SOURCE_CLEAR','CASE_MISMATCH','SECOND_ROW_INVALID','MISSING_REQUIRED','OPTION_NONOBJECT','OPTION_ARRAY_VALUE'):
    test('Fixture has '+key,key in ids and key in runner and (key in stub or key.startswith('SOURCE_')))

test('XU01 27 preexisting IDs retained',all(x in ids for x in ('DIRECT_BUILD_SUCCESS','DIRECT_SHOW_UNBUILT','DIRECT_SHOW_AFTER_FAILURE','DIRECT_SHOW_AFTER_SUCCESS','BUILD_TWICE','OPTION_ORDER','TAG_BINDING')))
# Defensive condition: controller remained byte identical to approved XU01 candidate
if BASE_CTRL.exists():test('Controller bytes unchanged from XU01 candidate',CTRL.read_bytes()==BASE_CTRL.read_bytes())
else:test('Controller baseline comparison available',False,'missing old candidate')
# Check normalized UTF8 review patch truly applies to normalized original.
if BASE.exists() and shutil.which('patch'):
    with tempfile.TemporaryDirectory() as d:
        d=Path(d)
        f=d/'frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm'
        f.write_text(normal(BASE.read_bytes().decode('cp932')),encoding='utf-8')
        cmd=subprocess.run(['patch','--batch','-p1','--directory',str(d),'--input',str(PATCH)],capture_output=True,text=True)
        candidates=[d/'frmMailGenerator_P3-04_XU01_XU02_A_Candidate_v0.1.frm',f]
        success=cmd.returncode==0 and any(c.exists() and c.read_text(encoding='utf-8')==u for c in candidates)
        test('Normalized review diff applies exactly',success,'returncode='+str(cmd.returncode)+' '+cmd.stdout[:100]+' '+cmd.stderr[:100])
else:
    test('Normalized review diff applies exactly',False,'Base or patch utility unavailable')

result={
 'document':'P3-04 XU-02 A Static Source Review',
 'date':'2026-11-21',
 'scope':'Source structure / encoding / contract / fixture presence only; no VBA runtime',
 'source_form_sha256':sha256(raw).hexdigest(),
 'counts':{'checks':len(check),'pass':sum(x['status']=='PASS' for x in check),'fail':sum(x['status']=='FAIL' for x in check),'candidate_vba_cases_defined':len(ids),'candidate_vba_cases_run':0},
 'checks':check,
 'vba_compile':'NOT VERIFIED','runtime':'NOT RUN','production_approval':'NOT APPROVED',
}
( ROOT/'verification/XU02_STATIC_AUDIT.json' ).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result['counts'],ensure_ascii=False))
for x in check:
 if x['status']!='PASS':print('FAIL:',x)
sys.exit(0 if result['counts']['fail']==0 else 1)
