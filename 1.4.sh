#!/bin/bash

# Variables initialization
{
  "분류": "Docker Configuration",
  "코드": "1.4",
  "위험도": "중요도 중",
  "진단_항목": "네임스페이스 관리",
  "대응방안": {
    "설명": "Docker는 리눅스의 namespace 기술을 사용하여 각 컨테이너에 격리된 환경을 제공합니다. 이를 통해 컨테이너는 독립적으로 실행되며, 호스트 OS의 중요한 시스템 자원에 대한 접근을 제한합니다. 과도한 권한을 방지하기 위해 네임스페이스를 적절히 관리해야 합니다.",
    "설정방법": [
      "network namespace 공유 금지: 컨테이너 실행 시 '--net=host' 옵션을 사용하지 않음",
      "process namespace 공유 금지: 컨테이너 실행 시 '--pid=host' 옵션을 사용하지 않음",
      "IPC namespace 공유 금지: 컨테이너 실행 시 '--ipc=host' 옵션을 사용하지 않음",
      "UTS namespace 공유 금지: 컨테이너 실행 시 '--uts=host' 옵션을 사용하지 않음",
      "user namespace 공유 금지: 컨테이너 실행 시 '--userns=host' 옵션을 사용하지 않음",
      "user namespace support 사용: 조직 내 정책을 고려하여 사용자 namespace 설정 및 Docker daemon에서 '--userns-remap=default' 옵션 사용"
    ]
  },
  "현황": [],
  "진단_결과": ""
}


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
