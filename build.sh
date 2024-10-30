#!/bin/bash

# 오류 처리 함수
handle_error() {
    echo "실패: $1" >&2
    exit 1
}

# 명령 실행 및 결과 확인 함수
execute_command() {
    "$@" > /dev/null 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        handle_error "$*"
    fi
    echo "성공: $*"
}

# Flutter pub upgrade 명령 실행
packages=(
    "creta_common"
    "creta_user_model"
    "creta_studio_model"
    "creta_user_io"
    "creta_studio_io"
    "my_syncfusion_flutter_pdfviewer"
)

for package in "${packages[@]}"; do
    execute_command flutter pub upgrade "$package"
done

# src_modify/modify_n.sh 실행 후 의존성 재설치
execute_command src_modify/modify_n.sh
#execute_command flutter clean
#execute_command flutter pub get

echo "package updgrade 작업이 완료되었습니다."

# 웹 빌드 실행
flutter build web --web-renderer html --release --base-href=/creta04_v11/ \
    --dart-define=serviceType=barricade --dart-define=serverType=firebase

