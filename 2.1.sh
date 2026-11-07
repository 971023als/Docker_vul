#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "호스트 OS",
  "코드": "2.1",
  "위험도": "중요도 하",
  "진단_항목": "설정 파일 및 주요 디렉터리 권한 설정",
  "대응방안": {
    "설명": "Docker 설정 파일과 주요 디렉터리의 권한을 적절히 관리하여 비인가자의 접근을 제한하고, SSL/TLS 구성을 통한 인증서 보호를 강화합니다. 이는 Docker 설정의 무결성을 유지하고, 시스템 보안을 강화하는 데 필수적입니다.",
    "설정방법": [
      "docker.service, docker.socket, daemon.json, /etc/docker, /etc/default/docker 파일 및 디렉터리의 소유권과 권한을 root 사용자/그룹에게 할당하여 권한 제한",
      "인증서 파일과 키의 권한을 설정하여 파일의 무결성 보장"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '2.1'
