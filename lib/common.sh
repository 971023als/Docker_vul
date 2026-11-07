#!/bin/bash
# Read-only evidence collection. stdout is one JSON object, never a security verdict.
collect_evidence() {
    META_JSON="$META_JSON" python3 - "$1" <<'PY'
import json, os, subprocess, sys
meta = json.loads(os.environ['META_JSON'])
code = sys.argv[1]
evidence = []
failed = False

def run(args):
    global failed
    try:
        p = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           encoding='utf-8', errors='replace', timeout=15, check=False)
        evidence.append({'command': args, 'exit_code': p.returncode,
                         'stdout': p.stdout, 'stderr': p.stderr})
        if p.returncode != 0:
            failed = True
            return None
        return p.stdout
    except (OSError, subprocess.TimeoutExpired) as exc:
        failed = True
        evidence.append({'command': args, 'error': str(exc)})
        return None

# Keep collection close to the original commands. Do not infer policy compliance.
if code in ('1.1', '1.4', '1.5', '1.6', '1.7', '1.8'):
    listing = run(['docker', 'ps', '--quiet', '--all'])
    if listing is not None:
        ids = listing.split()
        if ids:
            fields = {
                '1.1': ('Mounts', 'HostConfig.Devices'),
                '1.4': ('HostConfig.NetworkMode', 'HostConfig.PidMode', 'HostConfig.IpcMode', 'HostConfig.UTSMode', 'HostConfig.UsernsMode'),
                '1.5': ('HostConfig.NetworkMode', 'NetworkSettings.Ports'),
                '1.6': ('HostConfig.Memory', 'HostConfig.CpuShares', 'HostConfig.StorageOpt', 'HostConfig.PidsLimit'),
                '1.7': ('HostConfig.Privileged', 'HostConfig.ReadonlyRootfs', 'HostConfig.SecurityOpt', 'HostConfig.CgroupParent'),
                '1.8': ('AppArmorProfile', 'HostConfig.SecurityOpt', 'HostConfig.CapAdd', 'HostConfig.CapDrop'),
            }[code]
            for cid in ids:
                for field in fields:
                    run(['docker', 'inspect', '--format', '{{json .' + field + '}}', cid])
        else:
            evidence.append({'note': 'docker ps succeeded; no containers listed.'})
    if code == '1.5':
        networks = run(['docker', 'network', 'ls', '--filter', 'driver=bridge', '--quiet'])
        if networks is not None:
            for nid in networks.split():
                run(['docker', 'network', 'inspect', '--format', '{{json .Options}}', nid])
        evidence.append({'note': 'Container exec is not performed; SSH processes and necessity of exposed ports require manual review.'})
elif code in ('1.2', '1.3', '1.9', '3.3'):
    if code == '1.2':
        run(['getent', 'group', 'docker'])
    if code == '1.9':
        run(['docker', 'info', '--format', '{{json .LoggingDriver}}'])
    else:
        run(['docker', 'info', '--format', '{{json .}}'])
    # Raw configuration is evidence, not proof that a setting is effective.
    try:
        with open('/etc/docker/daemon.json', encoding='utf-8') as f:
            evidence.append({'path': '/etc/docker/daemon.json', 'content': f.read()})
    except OSError as exc:
        evidence.append({'path': '/etc/docker/daemon.json', 'unavailable': str(exc)})
    if code == '3.3':
        evidence.append({'DOCKER_CONTENT_TRUST': os.environ.get('DOCKER_CONTENT_TRUST'),
                         'note': 'Client environment value only; registry/signature policy is not verified.'})
elif code == '2.1':
    paths = ['/usr/lib/systemd/system/docker.service', '/usr/lib/systemd/system/docker.socket',
             '/var/run/docker.sock', '/etc/docker/daemon.json', '/etc/docker', '/etc/default/docker']
    for path in paths:
        run(['stat', '-c', '%n %a %U %G', path])
    run(['find', '/etc/docker/certs.d', '-type', 'f', '-exec', 'stat', '-c', '%n %a %U %G', '{}', ';'])
elif code == '2.2':
    run(['auditctl', '-l'])
    evidence.append({'note': 'No audit rules are installed and auditd is not restarted.'})
elif code in ('3.1', '3.2'):
    images = run(['docker', 'images', '--quiet', '--no-trunc'])
    if images is not None:
        for image in dict.fromkeys(images.split()):
            run(['docker', 'image', 'inspect', '--format', '{{json .Config.User}}', image])
            run(['docker', 'history', '--no-trunc', image])
        if not images.strip():
            evidence.append({'note': 'docker images succeeded; no images listed.'})
    evidence.append({'note': 'No vulnerability scanner or container exec is run. Image history is evidence only, not a vulnerability or Dockerfile compliance assessment.'})
elif code in ('4.1', '4.2', '4.3'):
    run(['docker', 'info', '--format', '{{json .Swarm}}'])
    if code == '4.1':
        run(['docker', 'node', 'ls'])
        evidence.append({'note': 'Unlock keys are not retrieved. Autolock requires manual verification.'})
    elif code == '4.2':
        networks = run(['docker', 'network', 'ls', '--filter', 'driver=overlay', '--quiet'])
        if networks is not None:
            for nid in networks.split():
                run(['docker', 'network', 'inspect', '--format', '{{json .Options}}', nid])
        run(['stat', '/var/lib/docker/swarm/certificates/swarm-root-ca.crt'])
        evidence.append({'note': 'Certificate rotation and encryption policy require manual verification.'})
    else:
        run(['ss', '-ltn'])
        evidence.append({'note': 'Swarm is not initialized or modified. Port bindings require manual review.'})
else:
    raise SystemExit('Unknown check: ' + code)
meta['현황'] = evidence
meta['진단_결과'] = '점검불가' if failed else '수동확인'
meta['판정_안내'] = '자동 양호/취약 판정을 수행하지 않습니다. 수집 범위와 각 명령의 종료 상태를 확인하세요.'
print(json.dumps(meta, ensure_ascii=False, indent=2))
PY
}
