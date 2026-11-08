#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.5",
  "위험도": "중요도 중",
  "진단_항목": "컨테이너 네트워크 제어",
  "대응방안": {
    "설명": "Docker 네트워크 설정을 관리하여 컨테이너 간 네트워크 격리를 강화하고 불필요한 포트 노출을 제한합니다. 특히, bridge 방식의 default 네트워크 제한, 불필요한 포트 매핑의 금지, 호스트 네트워크 인터페이스 설정 등을 통해 보안을 강화합니다.",
    "설정방법": [
      "bridge 방식의 default 네트워크를 제한하고, 사용자 정의 네트워크를 설정하여 사용",
      "불필요한 포트 매핑 금지하고 필요한 포트만 명시적으로 매핑",
      "컨테이너 내에서 SSH 실행 금지, Userland 프록시 사용을 제한하고, docker.sock 파일 마운트를 금지"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.5'
