#!/bin/bash

# 초기 설정
umask 077
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A OS_PACKAGE_MANAGER=(
    [debian]="apt-get"
    [ubuntu]="apt-get"
    [centos]="yum"
    [rhel]="yum"
    [fedora]="dnf"
)

declare -A OS_PACKAGES=(
    [debian]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [ubuntu]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [centos]="httpd mod_wsgi python3"
    [rhel]="httpd mod_wsgi python3"
    [fedora]="httpd mod_wsgi python3-virtualenv"
)

# cron은 이 스크립트 자체를 bash로 실행해야 하며, 설치 없이 점검/변환만 수행한다.
printf -v CRON_JOB '/bin/bash %q --cron' "$SCRIPT_DIR/vul.sh"
# crontab treats percent signs specially, including inside shell quotes.
CRON_JOB=${CRON_JOB//%/\\%}
NOW=$(date +'%Y-%m-%d_%H-%M-%S')_$$
# 기본 출력은 저장소 로컬 ./output. --web 또는 WEB_DIRECTORY 지정 시에만 웹 서빙 경로 사용.
WEB_MODE=false
WEB_DIRECTORY="${WEB_DIRECTORY:-$SCRIPT_DIR/output}"
RESULTS_PATH="$WEB_DIRECTORY/results_${NOW}.json"
ERRORS_PATH="$WEB_DIRECTORY/errors_${NOW}.log"
CSV_PATH="$WEB_DIRECTORY/results_${NOW}.csv"
HTML_PATH="$WEB_DIRECTORY/index.html"

# 운영체제 확인 및 패키지 관리자 설정
setup_environment() {
    if [ ! -f /etc/os-release ]; then
        echo "/etc/os-release 파일을 찾을 수 없습니다. 리눅스 배포판을 확인할 수 없습니다."
        exit 1
    fi

    source /etc/os-release
    PKG_MANAGER=${OS_PACKAGE_MANAGER[$ID]}
    PACKAGES=${OS_PACKAGES[$ID]}
    if [ -z "$PKG_MANAGER" ] || [ -z "$PACKAGES" ]; then
        echo "지원되지 않는 리눅스 배포판입니다."
        exit 1
    fi

    if { [ "$ID" = centos ] || [ "$ID" = rhel ]; } && [ "${VERSION_ID%%.*}" -ge 8 ]; then
        PKG_MANAGER=dnf
    fi

    install_packages
}

# 필요 패키지 설치 전 sudo 권한 확인
check_sudo() {
    if ! sudo -v; then
        echo "이 스크립트를 실행하기 위해서는 sudo 권한이 필요합니다."
        exit 1
    fi
}

install_packages() {
    check_sudo
    echo "필요한 패키지를 설치합니다: $PACKAGES"
    sudo $PKG_MANAGER update -y
    for PACKAGE in $PACKAGES; do
        sudo $PKG_MANAGER install $PACKAGE -y || { echo "$PACKAGE 패키지 설치 실패"; exit 1; }
    done
    setup_cron_job
}

# Cron 작업 설정 및 cronie 패키지 설치
setup_cron_job() {
    # crontab 명령이 존재하는지 확인
    if ! command -v crontab &> /dev/null; then
        echo "crontab 명령을 찾을 수 없습니다. cronie 패키지를 설치합니다."
        sudo $PKG_MANAGER install cronie -y
        sudo systemctl enable crond.service
        sudo systemctl start crond.service
    fi

    # Cron 작업 추가
    (crontab -l 2>/dev/null | grep -Fq "$CRON_JOB") && echo "Cron job이 이미 존재합니다." || {
        (crontab -l 2>/dev/null; echo "0 0 * * * $CRON_JOB # 매일 스크립트 실행") | crontab - &&
        echo "Cron job을 추가했습니다." || {
            echo "Cron job 추가에 실패했습니다. crontab이 설정되어 있는지 확인해주세요."
            exit 1
        }
    }
}



# Apache 인코딩 설정
setup_apache_encoding() {
    echo "Apache 인코딩 설정 시작..."
    local apache_config

    # 운영체제별 Apache 설정 파일 경로 지정
    echo "현재 운영 체제: $ID"
    if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        apache_config="/etc/apache2/apache2.conf"
        echo "Debian/Ubuntu 시스템 감지됨. Apache 설정 파일: $apache_config"
    elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "fedora" ]]; then
        apache_config="/etc/httpd/conf/httpd.conf"
        echo "CentOS/RHEL/Fedora 시스템 감지됨. Apache 설정 파일: $apache_config"
    else
        echo "지원되지 않는 리눅스 배포판입니다. Apache 설정 파일 경로를 수동으로 지정해야 합니다."
        return 1
    fi

    # UTF-8 설정 추가
    echo "Apache 설정 파일에 UTF-8 charset 설정을 검사합니다."
    if grep -q "AddDefaultCharset UTF-8" "$apache_config"; then
        echo "UTF-8 charset 설정이 이미 존재합니다. 추가 작업 없음."
    else
        echo "Apache 설정 파일에 UTF-8 charset 설정이 존재하지 않습니다. 설정을 추가합니다."
        if echo "AddDefaultCharset UTF-8" | sudo tee -a "$apache_config" > /dev/null; then
            echo "Apache 설정 파일에 UTF-8 charset 설정을 성공적으로 추가했습니다."
        else
            echo "Apache 설정 파일 수정 중 오류가 발생했습니다. 관리자 권한이 있는지 확인해주세요."
            return 1
        fi
    fi

    echo "Apache 인코딩 설정 완료."
}


# 보안 점검 스크립트 실행 및 결과 처리
# 저장소의 실제 점검 스크립트(<번호>.<번호>.sh)를 bash로 실행한다.
execute_security_checks() {
    mkdir -p "$WEB_DIRECTORY" || return 1
    local tmpdir
    tmpdir=$(mktemp -d) || return 1
    local count=0
    : > "$ERRORS_PATH"

    for script in "$SCRIPT_DIR"/[0-9]*.[0-9]*.sh; do
        [ -f "$script" ] || continue
        local name out errf rc
        name=$(basename "$script")
        out="$tmpdir/$name.out"
        errf="$tmpdir/$name.err"
        timeout 120 bash "$script" >"$out" 2>"$errf" && rc=0 || rc=$?

        if [ "$rc" -eq 0 ] && python3 -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    obj = json.load(f)
assert isinstance(obj, dict) and "진단_결과" in obj
' "$out" 2>/dev/null; then
            :
        else
            echo "[$name] 실행 실패(exit=$rc) 또는 유효하지 않은 JSON 출력:" >> "$ERRORS_PATH"
            head -c 2000 "$errf" >> "$ERRORS_PATH"
            echo "--- stdout ---" >> "$ERRORS_PATH"
            head -c 2000 "$out" >> "$ERRORS_PATH"
            # 실패한 항목도 보고서에 '오류'로 기록해 점검 누락이 보이게 한다
            python3 - "$name" > "$out.fixed" <<'EOF'
import json, sys
name = sys.argv[1]
code = name[:-3] if name.endswith('.sh') else name
obj = {
    "분류": "점검 오류",
    "코드": code,
    "위험도": "",
    "진단_항목": name,
    "대응방안": {"설명": "", "설정방법": []},
    "현황": ["스크립트 실행에 실패했거나 올바른 JSON을 출력하지 않았습니다. errors 로그를 확인하세요."],
    "진단_결과": "오류",
}
print(json.dumps(obj, ensure_ascii=False))
EOF
            mv "$out.fixed" "$out"
        fi
        mv "$out" "$(printf '%s/entry_%03d.json' "$tmpdir" "$count")"
        count=$((count + 1))
    done

    if [ "$count" -eq 0 ]; then
        echo "실행할 점검 스크립트가 없습니다 ($SCRIPT_DIR)." | tee -a "$ERRORS_PATH"
    fi

    python3 - "$tmpdir" "$RESULTS_PATH" <<'EOF'
import glob, json, os, sys
tmpdir, results_path = sys.argv[1], sys.argv[2]
items = []
for path in sorted(glob.glob(os.path.join(tmpdir, 'entry_*.json'))):
    with open(path, encoding='utf-8') as f:
        items.append(json.load(f))
with open(results_path, 'w', encoding='utf-8') as f:
    json.dump(items, f, ensure_ascii=False, indent=2)
ok = sum(1 for i in items if i.get('진단_결과') != '오류')
print(f"총 {len(items)}개 항목 기록 ({ok}개 유효 JSON, {len(items) - ok}개 실행/출력 오류) -> {results_path}")
EOF

    rm -rf "$tmpdir"

    if [ -s "$ERRORS_PATH" ]; then
        echo "에러가 존재함 -> $ERRORS_PATH"
    else
        rm -f "$ERRORS_PATH"
        echo "에러 없음."
    fi
    [ "$count" -gt 0 ]
}

convert_results() {
    python3 - "$RESULTS_PATH" "$CSV_PATH" "$HTML_PATH" <<'EOF'
import csv
import html
import json
import sys

results_path, csv_path, html_path = sys.argv[1], sys.argv[2], sys.argv[3]

try:
    with open(results_path, encoding='utf-8') as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError('결과가 배열 형식이 아닙니다')
    parse_error = None
except Exception as e:
    data = []
    parse_error = str(e)

# CSV: 결과가 없어도 헤더는 항상 기록한다
fieldnames = ['분류', '코드', '위험도', '진단_항목', '대응방안', '현황', '진단_결과']
with open(csv_path, 'w', newline='', encoding='utf-8-sig') as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    writer.writeheader()
    for item in data:
        row = {k: item.get(k, '') for k in fieldnames}
        remed = item.get('대응방안') or {}
        if isinstance(remed, dict):
            methods = remed.get('설정방법') or []
            row['대응방안'] = remed.get('설명', '') + ' | ' + '; '.join(map(str, methods))
        status = item.get('현황') or []
        row['현황'] = '; '.join(map(str, status)) if isinstance(status, list) else str(status)
        writer.writerow(row)

# HTML
rows = ''
for item in data:
    cells = ''.join(
        '<td>{}</td>'.format(html.escape(str(item.get(k, ''))))
        for k in ('분류', '코드', '위험도', '진단_항목', '진단_결과')
    )
    status = item.get('현황') or []
    status_text = '; '.join(map(str, status)) if isinstance(status, list) else str(status)
    rows += '<tr>{}<td>{}</td></tr>'.format(cells, html.escape(status_text))

banner = ''
if parse_error:
    banner = '<p style="color:red">결과 JSON 파싱 실패: {}</p>'.format(html.escape(parse_error))
elif not data:
    banner = '<p style="color:red">점검 결과가 없습니다. 점검 스크립트 실행 여부와 errors 로그를 확인하세요.</p>'

csv_name = csv_path.rsplit('/', 1)[-1]
page = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Security Check Results</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }}
        h1 {{ color: #333; }}
        table {{ width: 100%; border-collapse: collapse; }}
        th, td {{ text-align: left; padding: 8px; border: 1px solid #ddd; }}
        th {{ background-color: #4CAF50; color: white; }}
        tr:nth-child(even) {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <h1>Security Check Results</h1>
    {banner}
    <a href="{csv_name}">Download CSV</a><br>
    <table>
        <tr><th>분류</th><th>코드</th><th>위험도</th><th>진단_항목</th><th>진단_결과</th><th>현황</th></tr>
        {rows}
    </table>
</body>
</html>'''.format(banner=banner, csv_name=csv_name, rows=rows)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(page)

print(f"결과 {len(data)}건을 CSV와 HTML로 변환했습니다.")
EOF
}


# Apache 서비스 재시작 개선된 버전
restart_apache() {
    local service_names=("apache2.service" "httpd.service") # 서비스 파일 이름 명시
    local service_found=false

    for name in "${service_names[@]}"; do
        # 시스템에 서비스 파일이 존재하는지 확인
        if systemctl list-unit-files | grep -qw "$name"; then
            echo "$name 서비스를 재시작합니다."
            if sudo systemctl restart "$name"; then
                echo "$name 서비스가 성공적으로 재시작되었습니다."
                service_found=true
                break
            else
                echo "$name 서비스 재시작에 실패했습니다."
            fi
        fi
    done

    if [ "$service_found" = false ]; then
        echo "Apache/Httpd 서비스를 찾을 수 없습니다. 시스템에 서비스가 설치되어 있는지 확인해주세요."
    fi
}



# 메인 로직 실행
main() {
    local mode="checks" explicit_mode=false
    for arg in "$@"; do
        case "$arg" in
            --web) WEB_MODE=true
                   [ "$WEB_DIRECTORY" = "$SCRIPT_DIR/output" ] && WEB_DIRECTORY="/var/www/html" ;;
            --checks-only|--cron|--setup)
                if [ "$explicit_mode" = true ]; then
                    echo "Specify only one execution mode" >&2; return 2
                fi
                explicit_mode=true
                case "$arg" in
                    --checks-only) mode="checks" ;;
                    --cron) mode="cron" ;;
                    --setup) mode="setup" ;;
                esac ;;
            *) echo "Usage: $0 [--checks-only|--cron|--setup] [--web]" >&2
               return 2 ;;
        esac
    done
    RESULTS_PATH="$WEB_DIRECTORY/results_${NOW}.json"
    ERRORS_PATH="$WEB_DIRECTORY/errors_${NOW}.log"
    CSV_PATH="$WEB_DIRECTORY/results_${NOW}.csv"
    HTML_PATH="$WEB_DIRECTORY/index.html"
    case "$mode" in
        checks)
            local check_rc=0
            execute_security_checks || check_rc=$?
            convert_results || return $?
            [ "$check_rc" -eq 0 ] || return "$check_rc"
            ;;
        cron)
            local check_rc=0
            execute_security_checks || check_rc=$?
            convert_results || return $?
            [ "$check_rc" -eq 0 ] || return "$check_rc"
            if [ "$WEB_MODE" = true ]; then restart_apache; fi
            ;;
        setup)
            setup_environment
            setup_apache_encoding
            ;;
    esac
}

main "$@"
