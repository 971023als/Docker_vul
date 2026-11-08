#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.4",
  "위험도": "중요도 중",
  "진단_항목": "네임스페이스 관리",
  "대응방안": {
    "설명": "Docker는 리눅스의 namespace 기술을 사용하여 각 컨테이너에 격리된 환경을 제공합니다. 이를 통해 컨테이너는 독립적으로 실행되며, 호스트 OS의 중요한 시스템 자원에 대한 접근을 제한합니다. 과도한 권한을 방지하기 위해 네임스페이스를 적절히 관리해야 합니다.",
    "설정방법": [
      "network namespace 공유 금지: 컨테이너 실행 시 '--net=host' 옵션을 사용하지 않음",
      "process namespace 공유 금지: 컨테이너 실행 시 '--pid=host' 옵션을 사용하지 않음",
      "IPC namespace 공유 금지: 컨테이너 실행 시 '--ipc=host' 옵션을 사용하지 않음",
      "UTS namespace 공유 금지: 컨테이너 실행 시 '--uts=host' 옵션을 사용하지 않음",
      "user namespace 공유 금지: 컨테이너 실행 시 '--userns=host' 옵션을 사용하지 않음",
      "user namespace support 사용: 조직 내 정책을 고려하여 사용자 namespace 설정 및 Docker daemon에서 '--userns-remap=default' 옵션 사용"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.4'
