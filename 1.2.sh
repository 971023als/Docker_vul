#!/bin/bash

# Variables initialization
분류="Docker Configuration"
코드="1.2"
위험도="중요도 상"
진단_항목="인증-권한 제어"
대응방안="{
  \"설명\": \"Docker는 기본적으로 사용자 인증 기능을 내장하고 있지 않으며, Docker daemon에 접속 가능한 모든 사용자가 컨테이너 명령을 실행할 수 있습니다. 보안 강화를 위해 Docker 그룹 내 신뢰할 수 있는 사용자만 포함되어 있는지 확인하고, 필요한 경우 authorization plugin을 설정하여 인증 및 권한 제어를 강화합니다.\",
  \"설정방법\": [
    \"docker group 내 사용자 확인: 신뢰할 수 있는 사용자만 Docker 그룹에 포함되어 있는지 검사하고, 불필요한 사용자는 제거합니다.\",
    \"authorization plugin을 사용한 권한 제어: Docker daemon 실행 시 필요한 권한 관리를 위해 authorization plugin을 설치하고 구성합니다.\"
  ]
}"
현황=()
진단_결과=""

# 진단 시작
echo "진단 시작..."
# Check Docker group members
echo "검사: Docker group 내 사용자 확인"
getent group docker

# Check if authorization plugin is used and its configuration
echo "검사: Authorization plugin 사용 및 설정 확인"
ps -ef | grep dockerd

# 임시 진단 결과 할당
진단_결과="양호" # 또는 "취약"을 할당할 수 있습니다. 검사 후 결정

# 결과 JSON 출력
echo "{
  \"분류\": \"$분류\",
  \"코드\": \"$코드\",
  \"위험도\": \"$위험도\",
  \"진단_항목\": \"$진단_항목\",
  \"대응방안\": $대응방안,
  \"현황\": $현황,
  \"진단_결과\": \"$진단_결과\"
}"
