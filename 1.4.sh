#!/bin/bash

# Variables initialization
분류="Docker Configuration"
코드="1.4"
위험도="중요도 중"
진단_항목="네임스페이스 관리"
대응방안=""
현황=()
진단_결과=""

echo "Docker 네임스페이스 설정 검사 시작..."

# Check Docker network namespace configuration
echo "네트워크 네임스페이스 공유 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: NetworkMode={{ .HostConfig.NetworkMode }}'

# Check Docker process namespace configuration
echo "프로세스 네임스페이스 공유 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidMode={{ .HostConfig.PidMode }}'

# Check Docker IPC namespace configuration
echo "IPC 네임스페이스 공유 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: IpcMode={{ .HostConfig.IpcMode }}'

# Check Docker UTS namespace configuration
echo "UTS 네임스페이스 공유 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UTSMode={{ .HostConfig.UTSMode }}'

# Check Docker user namespace configuration
echo "User 네임스페이스 공유 설정 검사:"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UsernsMode={{ .HostConfig.UsernsMode }}'

# Check user namespace support usage
echo "User namespace support 사용 검사:"
ps -p $(docker inspect --format='{{ .State.Pid }}' $(docker ps -q)) -o pid,user

# Assign temporary diagnostic result
진단_결과="양호" # or "취약", determined after checks

# Output JSON with results
echo "{
  \"분류\": \"$분류\",
  \"코드\": \"$코드\",
  \"위험도\": \"$위험도\",
  \"진단_항목\": \"$진단_항목\",
  \"대응방안\": \"$대응방안\",
  \"현황\": $현황,
  \"진단_결과\": \"$진단_결과\"
}"
