#!/usr/bin/env python3
"""Bind a manual approval to one successful main workflow and exact saved plan."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

def gh_json(path):
    return json.loads(subprocess.check_output(['gh', 'api', path], text=True))

def validate_source(run, workflow_id, commit, main_commit):
    if not (run['status'] == 'completed' and run['conclusion'] == 'success'
            and run['workflow_id'] == workflow_id and run['head_branch'] == 'main'
            and run['event'] in ('push', 'workflow_dispatch')
            and run['head_sha'] == commit == main_commit):
        raise ValueError('Plan must be a successful trusted main run at the current approved commit')

def validate_plan(directory, run_id, attempt, commit, digest):
    metadata = json.loads((directory/'plan-metadata.json').read_text())
    actual = hashlib.sha256((directory/'infra.tfplan').read_bytes()).hexdigest()
    expected = {'run_id':str(run_id), 'run_attempt':str(attempt), 'commit':commit, 'sha256':digest}
    if metadata != expected or actual != digest:
        raise ValueError('Approved plan metadata or SHA-256 does not match')

def record():
    metadata = {'run_id':os.environ['GITHUB_RUN_ID'],
                'run_attempt':os.environ['GITHUB_RUN_ATTEMPT'],
                'commit':os.environ['GITHUB_SHA'],
                'sha256':hashlib.sha256(Path('infra.tfplan').read_bytes()).hexdigest()}
    Path('plan-metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as summary:
        summary.write('\nManual approval requires these exact values:\n\n```json\n'+json.dumps(metadata,indent=2)+'\n```\n')
    print(json.dumps(metadata))

def fetch():
    run_id = os.environ['APPROVED_RUN_ID']
    commit = os.environ['APPROVED_COMMIT']
    digest = os.environ['APPROVED_SHA256']
    if not (re.fullmatch(r'[1-9][0-9]*',run_id) and re.fullmatch(r'[0-9a-f]{40}',commit)
            and re.fullmatch(r'[0-9a-f]{64}',digest)):
        raise ValueError('Expected numeric plan run ID, full commit and lowercase SHA-256')
    if os.environ['GITHUB_REF'] != 'refs/heads/main':
        raise ValueError('Apply workflow must be dispatched on main')
    repo = os.environ['GITHUB_REPOSITORY']
    run = gh_json(f'repos/{repo}/actions/runs/{run_id}')
    workflow = gh_json(f'repos/{repo}/actions/workflows/terraform.yml')
    head = gh_json(f'repos/{repo}/git/ref/heads/main')['object']['sha']
    validate_source(run, workflow['id'], commit, head)
    if commit != os.environ['GITHUB_SHA']:
        raise ValueError('Dispatch commit differs from approved plan; request a fresh plan')
    directory = Path('.approved-plan')
    directory.mkdir(mode=0o700)
    subprocess.run(['gh','run','download',run_id,'--repo',repo,'--name',
                    f'terraform-plan-{run_id}-{run["run_attempt"]}','--dir',str(directory)],check=True)
    validate_plan(directory, run_id, run['run_attempt'], commit, digest)
    print('Approved plan source, current main commit and SHA-256 verified. No re-plan.')

if __name__ == '__main__':
    {'record':record,'fetch':fetch}[sys.argv[1]]()
