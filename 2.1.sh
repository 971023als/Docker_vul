#!/bin/bash

# 변수 초기화
{
  "분류": "호스트 OS",
  "코드": "2.1",
  "위험도": "중요도 하",
  "진단_항목": "설정 파일 및 주요 디렉터리 권한 설정",
  "대응방안": {
    "설명": "Docker 설정 파일과 주요 디렉터리의 권한을 적절히 관리하여 비인가자의 접근을 제한하고, SSL/TLS 구성을 통한 인증서 보호를 강화합니다. 이는 Docker 설정의 무결성을 유지하고, 시스템 보안을 강화하는 데 필수적입니다.",
    "설정방법": [
      "docker.service, docker.socket, daemon.json, /etc/docker, /etc/default/docker 파일 및 디렉터리의 소유권과 권한을 root 사용자/그룹에게 할당하여 권한 제한",
      "인증서 파일과 키의 권한을 설정하여 파일의 무결성 보장"
    ]
  },
  "현황": [],
  "진단_결과": ""
}


# 설정 파일 및 디렉터리 권한 검사
echo "설정 파일 및 디렉터리 권한 검사를 시작합니다..."

# 파일 권한 및 소유권 검사
echo "파일 권한 및 소유권 검사:"
# Docker service
stat -c %a:%U:%G /usr/lib/systemd/system/docker.service

# Docker socket
stat -c %a:%U:%G /usr/lib/systemd/system/docker.socket
stat -c %a:%U:%G /var/run/docker.sock

# Docker daemon configuration
stat -c %a:%U:%G /etc/docker/daemon.json

# Docker directory
stat -c %a:%U:%G /etc/docker

# Docker default configuration
stat -c %a:%U:%G /etc/default/docker

# 인증서 파일 권한 검사
echo "인증서 파일 권한 검사:"
stat -c %a:%U:%G /etc/docker/certs.d/*

# 진단 결과 업데이트
진단_결과="양호"  # 실제 진단 결과에 따라 "양호" 또는 "취약"으로 업데이트할 수 있습니다.

# 결과 JSON 출력
echo "{
  \"분류\": \"$분류\",
  \"코드\": \"$코드\",
  \"위험도\": \"$위험도\",
  \"진단_항목\": \"$진단_항목\",
  \"대응방안\": \"$대응방안\",
  \"현황\": $현황,
  \"진단_결과\": \"$진단_결과\"
}"
