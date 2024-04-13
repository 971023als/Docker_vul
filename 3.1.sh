#!/bin/bash

# 변수 초기화
{
  "분류": "이미지",
  "코드": "3.1",
  "위험도": "중요도 중",
  "진단_항목": "Dockerfile Config",
  "대응방안": {
    "설명": "Dockerfile 설정은 컨테이너 이미지 구성 시 중요한 보안 측면을 포함합니다. 적절한 사용자 권한 설정, 불필요한 권한 제거, 기밀 정보 관리 등을 통해 보안을 강화해야 합니다. Dockerfile 내에서 사용되는 명령들은 컨테이너의 보안성 및 효율성에 직접적인 영향을 미칩니다.",
    "설정방법": [
      "FROM 명령을 사용하여 적절한 베이스 이미지 선택",
      "RUN 명령으로 필요한 패키지만 설치하여 이미지 크기 최소화",
      "EXPOSE 명령으로 필요한 포트만 열기",
      "ENV로 중요 환경변수 설정",
      "CMD 또는 ENTRYPOINT를 사용하여 컨테이너 실행 시 초기화 명령 설정",
      "USER 명령으로 non-root 사용자로 실행",
      "COPY 대신 ADD 사용을 피하고, 필요한 파일만 컨테이너로 복사",
      "LABEL로 이미지에 메타데이터 추가",
      "ARG로 빌드 시 필요한 변수 설정",
      "Dockerfile을 통한 업데이트 명령어 금지"
    ]
  },
  "현황": [],
  "진단_결과": ""
}


# Docker 이미지와 Dockerfile 검사
echo "Docker 이미지 및 Dockerfile 설정을 검사합니다..."

# Dockerfile 명령 사용 확인
echo "Dockerfile 내 설정된 명령어들을 검사합니다..."
docker images --format '{{.Repository}}:{{.Tag}}' | while read image; do
    echo "검사 중: $image"
    docker history "$image" | grep -E 'ADD|RUN|USER'
done

# 사용자 지정 및 secrets 존재 여부 검사
echo "Dockerfile 내 사용자 설정 및 secrets 존재 여부를 검사합니다..."
docker images --quiet | xargs -I {} docker inspect --format '{{ .Id }}: User={{ .Config.User }}' {}

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
