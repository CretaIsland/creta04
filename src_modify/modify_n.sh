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

echo "pub.dev 디렉토리 사용: $PUB_DEV"

while IFS='|' read -r src dest || [ -n "$src" ]; do
    # 주석 줄 무시
    [[ $src =~ ^[[:space:]]*# ]] && continue

    src=$(echo "$src" | tr -d '\r' | sed 's/\\/\//g')
    dest=$(echo "$dest" | tr -d '\r' | sed 's/\\/\//g')
    src_path="$SRC_MODIFY/$src"
    dest_path="$PUB_DEV/$dest"
    
    if [ -f "$src_path" ]; then
        dest_dir=$(dirname "$dest_path")
        if [ -d "$dest_dir" ]; then
            cp "$src_path" "$dest_path"
            echo "$src_path 를 $dest_path 로 복사했습니다"
        else
            echo "오류: 대상 디렉토리 $dest_dir 가 존재하지 않습니다"
        fi
    else
        echo "경고: 소스 파일 $src_path 를 찾을 수 없습니다"
    fi
done < modify_target_list.txt

echo "모든 파일 복사가 완료되었습니다."

echo "All files have been copied successfully."
