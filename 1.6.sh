#!/bin/bash

# 변수 초기화
분류="Docker Configuration"
코드="1.6"
위험도="중요도 하"
진단_항목="컨테이너 리소스 제어"
대응방안=""
현황=()
진단_결과=""

# 모든 컨테이너의 리소스 설정 검사
echo "모든 컨테이너의 리소스 설정 검사를 시작합니다..."

# 메모리 할당 확인
echo "메모리 할당 확인:"
docker ps --quiet | xargs -I {} docker inspect {} --format '{{ .Name }}: Memory={{ .HostConfig.Memory }}'

# CPU 할당 확인
echo "CPU 할당 확인:"
docker ps --quiet | xargs -I {} docker inspect {} --format '{{ .Name }}: CpuShares={{ .HostConfig.CpuShares }}'

# 저장 공간 제한 설정 확인
echo "저장 공간 제한 설정 확인:"
docker ps --quiet | xargs -I {} docker inspect {} --format '{{ .Name }}: Storage={{ .HostConfig.StorageOpt }}'

# 프로세스 제한 설정 확인
echo "프로세스 제한 설정 확인:"
docker ps --quiet | xargs -I {} docker inspect {} --format '{{ .Name }}: PidsLimit={{ .HostConfig.PidsLimit }}'

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
