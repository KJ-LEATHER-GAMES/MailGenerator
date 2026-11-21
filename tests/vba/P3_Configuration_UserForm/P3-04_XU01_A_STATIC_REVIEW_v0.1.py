from pathlib import Path
import re,hashlib,json,zipfile,subprocess,tempfile,shutil
base=Path(__file__).resolve().parents[2]
out=Path(__file__).resolve().parents[1]
form=(out/'src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm').read_bytes().decode('cp932')
controller=(out/'src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas').read_bytes().decode('cp932')
tests=(out/'tests/modP3_04FormXU01ATests_v0.1_CP932.bas').read_bytes().decode('cp932')
stub=(out/'tests/modP3_04GateStub_v0.1_CP932.bas').read_bytes().decode('cp932')
patch=(out/'Docs/P3-04_XU01_A_UTF8_Normalized_Review_Diff_v0.1.patch').read_text(encoding='utf-8')
frml=form.replace('\r\n','\n')
ctrl=controller.replace('\r\n','\n')
test=tests.replace('\r\n','\n')

def section(txt,start,end):
    a=txt.index(start)
    b=txt.index(end,a+len(start))
    return txt[a:b]
public=section(frml,'Public Function BuildValidatedInputs()','Private Function BuildInputsFromGate(')
private=section(frml,'Private Function BuildInputsFromGate(','Private Function ValidateRenderableRow(')
ctrl_build=section(ctrl,'Public Function BuildMailGeneratorForm(','Public Function ShowMailGeneratorForm(')
activ=section(frml,'Private Sub UserForm_Activate()','End Sub')
case_span=section(test,'    cases = Array(', '    For Each key In cases')
case_names=re.findall(r'"([A-Z_]+)"',case_span)
checks=[]
def ck(name,expr,details=''):
    checks.append({'id':f'ST-{len(checks)+1:02d}','name':name,'status':'PASS' if expr else 'FAIL','details':details})
ck('CP932 .frm is readable',frml.startswith('VERSION 5.00\nBegin VB.UserForm'))
ck('Original fixed shell retained',all(x in frml for x in ['lblHeader','lblGuidance','fraInputArea','fraErrorArea','cmdCreateMail','cmdClear']))
ck('Form has a single no-argument public builder',len(re.findall(r'Public Function BuildValidatedInputs\(\) As COperationResult',frml))==1)
ck('Old public carrier signature eliminated',not bool(re.search(r'Public Function BuildValidatedInputs\(\s*_',frml)))
ck('Renderer is private and accepts carrier',bool(re.search(r'Private Function BuildInputsFromGate\( _\n    ByVal sortedActiveDefinitions As Collection',frml)))
ck('Gate direct call appears only in Form public builder',frml.count('Set gateResult = PrepareUserFormLaunch(')==1)
ck('Build validated inputs calls gate before private renderer',public.index('Set gateResult = PrepareUserFormLaunch(')<public.index('Set buildResult = BuildInputsFromGate('))
ck('Gate result Nothing returns fail-closed', 'If gateResult Is Nothing Then' in public and 'BadCarrier("UserFormLaunchGate.Result")' in public)
ck('Gate failure result object is propagated', 'If Not gateResult.Success Then' in public and 'Set BuildValidatedInputs = gateResult' in public)
ck('Gate carrier absence and wrong type fail-closed', all(x in public for x in ['sortedActiveDefinitions Is Nothing','activeOptionsByGroup Is Nothing','TypeName(activeOptionsByGroup) <> "Dictionary"']))
ck('Renderer is private and cannot be called by Controller', 'BuildInputsFromGate' not in ctrl)
ck('No direct Gate call in Controller', 'PrepareUserFormLaunch(' not in ctrl)
ck('Controller calls public builder exactly once',ctrl_build.count('Set stepResult = localForm.BuildValidatedInputs()')==1)
ck('Controller instantiates before delegated gate',ctrl_build.index('Set localForm = New frmMailGenerator')<ctrl_build.index('Set stepResult = localForm.BuildValidatedInputs()'))
ck('Controller publishes only after Success',ctrl_build.index('If Not stepResult.Success Then') < ctrl_build.index('Set candidateForm = localForm'))
ck('Controller unloads Form on build failure', 'BuildFailed:' in ctrl_build and 'Unload localForm' in ctrl_build)
ck('Controller Show gated by Build Result',ctrl.index('If Not stepResult.Success Then',ctrl.index('Public Function ShowMailGeneratorForm('))<ctrl.index('newForm.Show vbModal'))
ck('Unbuilt direct Show guarded in Activate', 'If Not mBuilt Then Me.Hide' in activ)
ck('Display guard does not perform implicit gate or sync', 'PrepareUserFormLaunch' not in activ and 'ExecuteManualSync' not in activ)
ck('mBuilt remains private',bool(re.search(r'Private mBuilt As Boolean',frml)) and not bool(re.search(r'Public mBuilt',frml)))
ck('mBuilt becomes True only after constructing controls',private.index('mBuilt = True')>private.index('For Each itemValue In sortedActiveDefinitions',private.index('itemIndex = 0')))
ck('Control-add exceptions reset readiness', 'RemoveDynamicControls' in private and 'mBuilt = False' in private)
ck('Guard against duplicate/reentrant build', 'mBuildInProgress' in public and 'If mBuilt Then' in public)
ck('Gate in-progress marker cleared', 'CleanExit:' in public and 'mBuildInProgress = False' in public)
ck('Input State and mail generation not implemented', 'cmdCreateMail.Enabled = False' in private and 'cmdClear.Enabled = False' in private)
ck('Control Tag kept', '.Tag = variableName' in frml)
ck('Select remains list only', '.Style = fmStyleDropDownList' in frml)
ck('Existing result/error class compatible', 'As COperationResult' in public and 'CreateFailureResult' in public)
ck('Test-only Stub separates real P3-03', 'TEST-ONLY STUB' in stub and 'Public Function PrepareUserFormLaunch(' in stub)
ck('All original 19 cases retained',len(case_names)==27 and len(set(case_names))==27,details=f'{len(case_names)} unique cases (19 original + 8 new)')
ck('Direct unbuilt Show scenario exists','Case "DIRECT_SHOW_UNBUILT"' in test and 'frm.Show vbModeless' in test)
ck('Direct show after failure scenario exists','Case "DIRECT_SHOW_AFTER_FAILURE"' in test and 'Not frm.Visible' in test)
ck('Direct show after success scenario exists','Case "DIRECT_SHOW_AFTER_SUCCESS"' in test and 'frm.Visible And P304GateCalls = 1' in test)
ck('Upstream Result identity test present','result Is P304Failure' in test)
ck('Rebuild does not rerun Gate', 'Not repeatResult.Success And P304GateCalls = 1' in test)
ck('No forbidden Production dependencies',all(x not in frml+'\n'+ctrl for x in ['ExecuteManualSync(', 'ApplySyncDiff(', 'GetActiveVariableDefinitions(', 'CreateMailFromTemplate(', 'DoEvents', 'Sleep(', 'GetSettingValue(']))
ck('Patch defines Form + Controller + Test',all(patch.count('--- a/'+x)==1 for x in ['src/frmMailGenerator_P3-04_Candidate_v0.1.frm','src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas','tests/modP3_04FormCandidateTests_v0.1_CP932.bas']))
# minimal UI source consistency check, not formal VBA compile
for name,s in [('Form',frml),('Controller',ctrl),('Runner',test)]:
    f=len(re.findall(r'^\s*(?:Public |Private )?Function ',s,re.M));end=len(re.findall(r'^End Function\s*$',s,re.M))
    sub=len(re.findall(r'^\s*(?:Public |Private )?Sub ',s,re.M));es=len(re.findall(r'^End Sub\s*$',s,re.M))
    ck(f'{name} Function/Sub block count balanced',f==end and sub==es,details=f'Functions {f}/{end}; Subs {sub}/{es}')
# Test patch applies to snapshots, with no application to user repo
with tempfile.TemporaryDirectory() as d:
    root=Path(d)
    originals={
      'src/frmMailGenerator_P3-04_Candidate_v0.1.frm': base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/frmMailGenerator_P3-04_Candidate_v0.1.frm',
      'src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas':base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas',
    }
    with zipfile.ZipFile(base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1.zip') as z:
        key=next(n for n in z.namelist() if n.endswith('tests/modP3_04FormCandidateTests_v0.1_CP932.bas'))
        (root/'tests').mkdir(exist_ok=True)
        (root/'tests/modP3_04FormCandidateTests_v0.1_CP932.bas').write_text(z.read(key).decode('cp932').replace('\r\n','\n'),encoding='utf-8')
    for dst,src in originals.items():
        path=root/dst
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(src.read_bytes().decode('cp932').replace('\r\n','\n'),encoding='utf-8')
    patch_path=root/'candidate.patch'; patch_path.write_text(patch,encoding='utf-8')
    res=subprocess.run(['git','apply','--check',str(patch_path)],cwd=root,capture_output=True,text=True)
    ck('git apply --check on exact original snapshots',res.returncode==0,details=res.stderr[:400])
    if res.returncode==0:
        app=subprocess.run(['git','apply',str(patch_path)],cwd=root,capture_output=True,text=True)
        ck('git apply to disposable snapshot',app.returncode==0,details=app.stderr[:400])
        dest={
           'src/frmMailGenerator_P3-04_Candidate_v0.1.frm':frml,
           'src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas':ctrl,
           'tests/modP3_04FormCandidateTests_v0.1_CP932.bas':test,
        }
        ck('Patch result equals generated source files',all((root/path).read_text(encoding='utf-8')==s for path,s in dest.items()))
# Raw original CP932 / CRLF apply check (do NOT normalize these files).
raw_patch=out/'Docs/P3-04_XU01_A_CP932_CRLF_Apply_Candidate_v0.1.patch'
with tempfile.TemporaryDirectory() as dr:
    rr=Path(dr)
    (rr/'src').mkdir(parents=True)
    (rr/'tests').mkdir(parents=True)
    raw_originals={
      'src/frmMailGenerator_P3-04_Candidate_v0.1.frm':base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/frmMailGenerator_P3-04_Candidate_v0.1.frm',
      'src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas':base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1/src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas',
    }
    for name,orig in raw_originals.items():
        (rr/name).write_bytes(orig.read_bytes())
    with zipfile.ZipFile(base/'P3-04_Minimal_Dynamic_UserForm_Candidate_v0.1.zip') as z:
        archive_name=next(n for n in z.namelist() if n.endswith('/tests/modP3_04FormCandidateTests_v0.1_CP932.bas'))
        (rr/'tests/modP3_04FormCandidateTests_v0.1_CP932.bas').write_bytes(z.read(archive_name))
    rawcheck=subprocess.run(['git','apply','--check',str(raw_patch)],cwd=rr,capture_output=True)
    ck('Raw CP932 CRLF patch git apply --check',rawcheck.returncode==0,details=rawcheck.stderr.decode('utf-8','replace')[:400])
    if rawcheck.returncode==0:
        rawapply=subprocess.run(['git','apply',str(raw_patch)],cwd=rr,capture_output=True)
        ck('Raw CP932 CRLF patch applies to disposable files',rawapply.returncode==0,details=rawapply.stderr.decode('utf-8','replace')[:400])
        newfiles={
         'src/frmMailGenerator_P3-04_Candidate_v0.1.frm':out/'src/frmMailGenerator_P3-04_XU01_A_Candidate_v0.1.frm',
         'src/modP3UserFormController_P3-04_Candidate_v0.1_CP932.bas':out/'src/modP3UserFormController_P3-04_XU01_A_Candidate_v0.1_CP932.bas',
         'tests/modP3_04FormCandidateTests_v0.1_CP932.bas':out/'tests/modP3_04FormXU01ATests_v0.1_CP932.bas',
        }
        ck('Raw patch yields exact expected bytes',all((rr/name).read_bytes()==f.read_bytes() for name,f in newfiles.items()))
report={'review':'P3-04 XU-01 A source-only static verification','date':'2026-11-21','approved_decision':'XU-01 Option A only','run_context':'Python static checks and disposable git patch application, no VBE/VBA/Outlook execution','total':len(checks),'pass_count':sum(x['status']=='PASS' for x in checks),'fail_count':sum(x['status']=='FAIL' for x in checks),'cases':case_names,'checks':checks}
(out/'Docs/STATIC_REVIEW_RESULT_XU01_A.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['total','pass_count','fail_count','cases']},ensure_ascii=False))
for x in checks:
    if x['status']=='FAIL':print(x)
