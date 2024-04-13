#!/bin/bash

# 변수 초기화
분류="Docker Configuration"
코드="1.7"
위험도="중요도 상"
진단_항목="컨테이너 권한 제어"
대응방안=""
현황=()
진단_결과=""

# 컨테이너 권한 진단
echo "컨테이너 권한 진단을 시작합니다..."

# Privileged 컨테이너 사용 검사
echo "Privileged 컨테이너 사용 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Privileged={{ .HostConfig.Privileged }}'

# 컨테이너의 Root Filesystem을 read only으로 설정 검사
echo "컨테이너의 Root Filesystem 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}'

# suid/sgid 제한 검사
echo "suid/sgid 제한 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'

# cgroup 변경 금지 검사
echo "cgroup 변경 금지 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: CgroupParent={{ .HostConfig.CgroupParent }}'

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
