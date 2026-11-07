#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.6",
  "위험도": "중요도 하",
  "진단_항목": "컨테이너 리소스 제어",
  "대응방안": {
    "설명": "컨테이너 리소스 제어를 통해 CPU, 메모리, 저장 공간을 컨테이너 별로 차등 공유하고, 서비스 거부 공격(Distributed DoS)을 방지합니다.",
    "설정방법": [
      "컨테이너 별로 리소스 할당 설정",
      "CPU 및 메모리 제한 설정",
      "저장 공간 관리 및 접근 제한",
      "프로세스 생성 제한 설정"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.6'
