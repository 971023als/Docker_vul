#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "호스트 OS",
  "코드": "2.2",
  "위험도": "중요도 하",
  "진단_항목": "audit 설정",
  "대응방안": {
    "설명": "호스트에서 Docker 관련 파일 및 디렉터리의 Audit 로그를 관리하여 시스템에 영향을 미치는 활동을 문서화합니다. 이는 시스템의 변경사항을 효과적으로 추적하고, 파일의 위·변조를 방지하여 보안을 강화하는 데 필수적입니다.",
    "설정방법": [
      "auditctl을 사용하여 Docker 관련 파일 및 디렉터리의 감사 설정",
      "적절한 audit.rules 설정을 통해 파일 감사를 활성화하고, 감사 로그를 안전하게 백업 및 보관"
    ]
  },
  "현황": [],
  "진단_결과": ""
}
JSON
)
collect_evidence '2.2'
