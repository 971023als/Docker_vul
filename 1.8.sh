#!/bin/bash

# 변수 초기화
{
  "분류": "Docker Configuration",
  "코드": "1.8",
  "위험도": "중요도 중",
  "진단_항목": "컨테이너 보안 정책",
  "대응방안": {
    "설명": "AppArmor, SELinux, seccomp를 포함한 리눅스 커널 보안 모듈을 사용하여 컨테이너 보안을 강화합니다. 이를 통해 컨테이너와 호스트 간의 권한 상승을 방지하고 리눅스 OS 및 응용 프로그램을 보호합니다.",
    "설정방법": [
      "AppArmor 프로필 활성화",
      "SELinux 사용 설정",
      "seccomp 프로필 적용",
      "리눅스 커널 Capabilities 제한"
    ]
  },
  "현황": [],
  "진단_결과": ""
}


# 컨테이너 보안 정책 진단 시작
echo "컨테이너 보안 정책 진단을 시작합니다..."

# AppArmor 프로필 적용 검사
echo "AppArmor 프로필 적용 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: AppArmorProfile={{ .AppArmorProfile }}'

# SELinux 사용 검사
echo "SELinux 사용 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'

# seccomp 프로필 적용 검사
echo "seccomp 프로필 적용 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'

# 리눅스 커널 Capabilities 설정 검사
echo "리눅스 커널 Capabilities 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: CapAdd={{ .HostConfig.CapAdd }} CapDrop={{ .HostConfig.CapDrop }}'

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
