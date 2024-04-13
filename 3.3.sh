#!/bin/bash

# 변수 초기화
{
  "분류": "이미지",
  "코드": "3.3",
  "위험도": "중요도 중",
  "진단_항목": "레지스트리 운영 관리",
  "대응방안": {
    "설명": "레지스트리는 이미지를 저장하고 식별, 버전 관리하여 개발자가 쉽게 사용할 수 있도록 도와주는 서비스입니다. 보안적으로 중요한 정보가 포함된 이미지가 레지스트리에 저장되므로 이를 적절히 보호해야 합니다.",
    "설정방법": [
      "레지스트리와의 통신에 SSL/TLS 프로토콜 적용하여 보안 강화",
      "레지스트리 내 인증 및 권한 부여를 통해 이미지 접근 제어",
      "레지스트리에 저장된 이미지 관리하여 취약점 및 오래된 버전 제거",
      "Content trust를 사용하여 원격 레지스트리와의 데이터 교환에 무결성을 보장"
    ]
  },
  "현황": [],
  "진단_결과": ""
}

# 레지스트리 운영 관리 진단
echo "레지스트리 운영 관리를 진단합니다..."

# Content trust 활성화 여부 확인
echo "Content trust 활성화 여부:"
echo "$DOCKER_CONTENT_TRUST"

# 레지스트리와 암호화 연결 설정 확인
echo "레지스트리 암호화 연결 설정:"
ps -ef | grep dockerd

# 구버전(v1) legacy registry 사용 금지 여부 확인
echo "구 버전 레지스트리 비활성화 설정:"
dockerd --disable-legacy-registry

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
