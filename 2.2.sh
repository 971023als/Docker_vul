#!/bin/bash

# 변수 초기화
분류="호스트 OS"
코드="2.2"
위험도="중요도 하"
진단_항목="audit 설정"
대응방안=""
현황=()
진단_결과=""

# Docker 관련 파일 및 디렉터리의 audit 감사 설정 확인
echo "Docker 관련 파일 및 디렉터리의 audit 감사 설정을 확인합니다..."

# 감사 설정 확인
echo "감사 설정 확인:"
auditctl -l | grep /usr/bin/docker
auditctl -l | grep /var/lib/docker
auditctl -l | grep /etc/docker
auditctl -l | grep /etc/default/docker
auditctl -l | grep /etc/docker/daemon.json
auditctl -l | grep /usr/bin/docker-containerd
auditctl -l | grep /usr/bin/docker-runc

# 감사 설정 적용
echo "audit 규칙 적용 중..."
echo "-w /usr/bin/docker -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /var/lib/docker -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /etc/docker -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /etc/default/docker -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /etc/docker/daemon.json -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /usr/bin/docker-containerd -p wa -k docker" >> /etc/audit/audit.rules
echo "-w /usr/bin/docker-runc -p wa -k docker" >> /etc/audit/audit.rules

# audit 데몬 재시작
service auditd restart

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
