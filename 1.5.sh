#!/bin/bash

# 초기 변수 설정
분류="Docker Configuration"
코드="1.5"
위험도="중요도 중"
진단_항목="컨테이너 네트워크 제어"
대응방안=""
현황=()
진단_결과=""

# 컨테이너 네트워크 설정 검사 시작
echo "컨테이너 네트워크 설정 검사 시작..."

# bridge 방식의 default 네트워크 사용 여부 확인
echo "bridge 방식의 default 네트워크 사용 여부 확인:"
docker network ls --filter driver=bridge --quiet | xargs -L 1 docker network inspect --format '{{ .Name }}: {{ .Options }}'

# 불필요한 포트 매핑 검사
echo "불필요한 포트 매핑 검사:"
docker ps --quiet | xargs -L 1 docker inspect --format '{{ .Id }}: Ports={{ .NetworkSettings.Ports }}'

# 호스트 네트워크 인터페이스 설정 검사
echo "호스트 네트워크 인터페이스 설정 검사:"
docker ps --quiet | xargs -L 1 docker inspect --format '{{ .Id }}: Network={{ .HostConfig.NetworkMode }}'

# 컨테이너 내 SSH 실행 여부 검사
echo "컨테이너 내 SSH 실행 여부 검사:"
docker ps --quiet | xargs -I {} docker exec {} sh -c 'command -v sshd'

# Userland 프록시 사용 여부 확인
echo "Userland 프록시 사용 여부 확인:"
ps -ef | grep 'dockerd' | grep 'userland-proxy=false'

# 진단 결과 업데이트
진단_결과="양호" # 이 부분은 실제 진단 결과에 따라 "양호" 또는 "취약"으로 업데이트

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
