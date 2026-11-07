#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Swarm",
  "코드": "4.3",
  "위험도": "중요도 중",
  "진단_항목": "네트워크 제어",
  "대응방안": {
    "설명": "Docker Swarm 네트워크는 호스트 시스템의 네트워크 인터페이스 설정을 통해 보안이 강화된 접근을 보장합니다. 외부 인터페이스에서의 접근만을 허용하고, 컨테이너 데이터 트래픽과 클러스터 관리 트래픽을 분리하여 각각 모니터링하고 제어할 수 있습니다.",
    "설정방법": [
      "특정 인터페이스에서만 Swarm 서비스가 수신하도록 설정",
      "netstat 명령어를 사용하여 특정 인터페이스에서만 수신 대기 중인지 확인",
      "docker swarm init 명령어에 --listen-addr 옵션을 사용하여 네트워크 인터페이스 지정",
      "네트워크 트래픽의 분리 및 모니터링 구성"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '4.3'
