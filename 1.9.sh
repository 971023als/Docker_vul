#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.9",
  "위험도": "중요도 하",
  "진단_항목": "로그 관리",
  "대응방안": {
    "설명": "Docker의 로그 관리를 통해 시스템 활동을 문서화하고 로그 파일의 보안을 강화합니다. 로그 기록은 정기적으로 확인되어야 하며, 로그 파일의 위·변조 방지를 위해 별도의 저장장치에 백업하고 쓰기 권한을 제한합니다.",
    "설정방법": [
      "로그 레벨 설정: Docker 서비스 실행 시 적절한 로그 레벨 설정",
      "중앙 집중식 원격 로깅 구성: 원격 로깅 드라이버를 사용하여 로그를 중앙 서버로 전송"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '1.9'
