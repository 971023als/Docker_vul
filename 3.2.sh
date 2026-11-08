#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "이미지",
  "코드": "3.2",
  "위험도": "중요도 중",
  "진단_항목": "이미지 취약점 및 구성 결함",
  "대응방안": {
    "설명": "Docker 이미지는 컨테이너 생성의 기반으로, 보안에 취약한 이미지 사용은 컨테이너 및 호스트 시스템의 보안을 위협할 수 있습니다. 이를 방지하기 위해 신뢰할 수 있는 이미지 사용, 취약한 구성요소의 업데이트, 이미지 내 주요 정보 포함을 피해야 합니다.",
    "설정방법": [
      "신뢰할 수 있는 소스에서 이미지를 가져오고, Docker Content Trust를 활성화",
      "정기적인 이미지 스캔을 통해 취약점을 식별하고 업데이트",
      "컨테이너 내 불필요한 패키지 삭제 및 필수 패키지의 보안 패치 적용",
      "이미지 내 중요 정보(예: 비밀번호, 키 등)를 직접 포함하지 않도록 환경 변수 또는 별도의 관리 시스템을 사용"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '3.2'
