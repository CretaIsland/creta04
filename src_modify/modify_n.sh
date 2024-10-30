#!/bin/bash

# 스크립트가 있는 디렉토리로 이동
cd "$(dirname "$0")"

# pub.dev 디렉토리 찾기
if [ -z "$PUB_CACHE" ]; then
    if [ -d "$HOME/.pub-cache" ]; then
        PUB_CACHE="$HOME/.pub-cache"
    elif [ -d "$HOME/snap/flutter/common/pub-cache" ]; then
        PUB_CACHE="$HOME/snap/flutter/common/pub-cache"
    else
        echo "오류: pub-cache 디렉토리를 찾을 수 없습니다"
        exit 1
    fi
fi

PUB_DEV="$PUB_CACHE/hosted/pub.dev"
SRC_MODIFY="."
ERROR_COUNT=0

echo "pub.dev 디렉토리 사용: $PUB_DEV"

# 폰트 파일 여부 확인 함수
is_font_file() {
    local dest="$1"
    [[ "$dest" =~ html_editor_enhanced-.*?/lib/assets/font/ ]]
}

# 파일 복사 함수
copy_file() {
    local src="$1"
    local dest="$2"
    local dest_dir=$(dirname "$dest")
    
    # 폰트 파일일 경우에만 디렉토리 생성
    if ! [ -d "$dest_dir" ]; then
        if is_font_file "$dest"; then
            mkdir -p "$dest_dir"
            if [ $? -ne 0 ]; then
                echo "실패: 폰트 디렉토리 생성 실패 - $dest_dir"
                return 1
            fi
        else
            echo "실패: 대상 디렉토리가 존재하지 않습니다 - $dest_dir"
            return 1
        fi
    fi
    
    if [ -f "$src" ]; then
        if cp "$src" "$dest" 2>/dev/null; then
            echo "성공: $src 를 $dest 로 복사했습니다"
            return 0
        else
            echo "실패: $src 복사 중 오류 발생"
            return 1
        fi
    else
        echo "실패: 소스 파일 $src 를 찾을 수 없습니다"
        return 1
    fi
}

# 파일 복사 처리
while IFS='|' read -r src dest || [ -n "$src" ]; do
    # 주석 및 빈 줄 무시
    [[ $src =~ ^[[:space:]]*# || -z "${src// }" ]] && continue
    
    # Windows 경로를 Linux 경로로 변환
    src=$(echo "$src" | tr -d '\r' | sed 's/\\/\//g')
    dest=$(echo "$dest" | tr -d '\r' | sed 's/\\/\//g')
    
    src_path="$SRC_MODIFY/$src"
    dest_path="$PUB_DEV/$dest"
    
    if ! copy_file "$src_path" "$dest_path"; then
        ((ERROR_COUNT++))
    fi
done < modify_target_list.txt

echo
if [ $ERROR_COUNT -gt 0 ]; then
    echo "작업 완료: ${ERROR_COUNT}개의 오류가 발생했습니다."
    exit 1
else
    echo "작업 완료: 모든 파일이 성공적으로 복사되었습니다."
    exit 0
fi
