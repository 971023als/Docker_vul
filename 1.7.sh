#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.7",
  "위험도": "중요도 상",
  "진단_항목": "컨테이너 권한 제어",
  "대응방안": {
    "설명": "컨테이너 내 불필요하게 과도한 권한을 제거하여 권한 상승 공격을 방지합니다. Privileged 및 Unprivileged 컨테이너 설정을 통해 보안을 강화합니다.",
    "설정방법": [
      "Privileged 컨테이너의 사용 제한",
      "컨테이너의 Root Filesystem을 read only로 설정",
      "suid/sgid 제한 설정",
      "cgroup 변경 금지",
      "실험 기능 비활성화",
      "exec 사용 제한"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.7'
