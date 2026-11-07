#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.8",
  "위험도": "중요도 중",
  "진단_항목": "컨테이너 보안 정책",
  "대응방안": {
    "설명": "AppArmor, SELinux, seccomp를 포함한 리눅스 커널 보안 모듈을 사용하여 컨테이너 보안을 강화합니다. 이를 통해 컨테이너와 호스트 간의 권한 상승을 방지하고 리눅스 OS 및 응용 프로그램을 보호합니다.",
    "설정방법": [
      "AppArmor 프로필 활성화",
      "SELinux 사용 설정",
      "seccomp 프로필 적용",
      "리눅스 커널 Capabilities 제한"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.8'
