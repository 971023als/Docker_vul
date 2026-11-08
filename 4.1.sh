#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Swarm",
  "코드": "4.1",
  "위험도": "중요도 상",
  "진단_항목": "인증 제어",
  "대응방안": {
    "설명": "Docker Swarm 모드에서는 manager node와 worker node가 있으며, 인증 관리를 통해 컨테이너 및 클러스터의 보안을 강화합니다. 잘못된 인증 설정이 시스템에 큰 영향을 줄 수 있으므로 엄격한 인증 절차와 설정이 필요합니다.",
    "설정방법": [
      "Swarm mode 활성화를 불필요하게 하지 않음",
      "관리자 노드의 수를 최소화",
      "자동 잠금 모드를 사용하여 시스템 보안을 강화",
      "Swarm 초기화 시 자동 잠금 모드를 활성화하고, 필요에 따라 잠금키를 주기적으로 변경"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '4.1'
