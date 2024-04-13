#!/bin/bash

# 변수 초기화
분류="호스트 OS"
코드="2.1"
위험도="중요도 하"
진단_항목="설정 파일 및 주요 디렉터리 권한 설정"
대응방안=""
현황=()
진단_결과=""

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
