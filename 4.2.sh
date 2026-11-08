#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Swarm",
  "코드": "4.2",
  "위험도": "중요도 상",
  "진단_항목": "SSL/TLS 적용",
  "대응방안": {
    "설명": "Swarm mode에서는 SSL/TLS를 이용하여 node 간 통신을 보호하고 사용자 인증을 강화합니다. 이는 데이터를 보호하고 스니핑과 같은 공격으로부터 정보를 안전하게 지키기 위한 조치입니다.",
    "설정방법": [
      "네트워크 구간 데이터 보호 및 사용자 인증을 위해 SSL/TLS 적용",
      "노드 인증서 교환주기 설정 및 관리",
      "CA 인증서 주기적 교환으로 보안 유지",
      "SSL/TLS를 사용하는 네트워크 구성 시 '--opt encrypted' 옵션 사용",
      "Swarm 업데이트 시 인증서 만료 기간을 설정하여 보안 강화"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '4.2'
