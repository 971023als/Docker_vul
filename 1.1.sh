#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.1",
  "위험도": "중요도 상",
  "진단_항목": "호스트 OS 주요 자원 접근 제어",
  "대응방안": {
    "설명": "컨테이너에서 호스트 OS의 주요 자원에 접근하는 것을 제한하여 호스트 및 다른 컨테이너의 안정성과 보안을 보장합니다. 주요 시스템 디렉터리 마운트와 호스트 장치 파일의 직접 노출을 금지합니다.",
    "설정방법": [
      "주요 시스템 디렉터리 마운트 금지: 컨테이너 생성 시 호스트의 중요 시스템 디렉터리를 마운트 하지 않도록 설정합니다.",
      "호스트 장치 파일 컨테이너에 직접 노출 금지: 컨테이너에 필요한 호스트 장치 파일만 노출하고, 적절한 권한 설정을 통해 접근을 제어합니다."
    ]
  }
}
JSON
)
collect_evidence '1.1'
