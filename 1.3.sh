#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
# Original item metadata; collection does not assign a security verdict.
META_JSON=$(cat <<'JSON'
{
  "분류": "Docker Configuration",
  "코드": "1.3",
  "위험도": "중요도 상",
  "진단_항목": "SSL/TLS 적용",
  "대응방안": {
    "설명": "TLS(Transport Layer Security)는 정보를 암호화해서 송수신하는 프로토콜로, Docker가 TCP Socket을 통해 네트워크에 연결되는 경우 SSL/TLS를 적용하여 데이터와 사용자 인증을 보호합니다. 주기적인 인증서 갱신과 안전한 암호화 방식 사용이 필수입니다.",
    "설정방법": [
      "OpenSSL을 사용하여 CA, 서버 및 클라이언트 키 생성",
      "Docker 서비스 실행 시 SSL/TLS 옵션 적용: docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H=$HOST:2376 version"
    ]
  }
}
JSON
)
collect_evidence '1.3'
