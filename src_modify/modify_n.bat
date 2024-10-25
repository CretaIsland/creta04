@echo off
setlocal enabledelayedexpansion

:: 스크립트가 있는 디렉토리로 이동
cd /d "%~dp0"

set "PUB_DEV=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev"
set "SRC_MODIFY=."

echo pub.dev 디렉토리 사용: %PUB_DEV%

for /f "usebackq tokens=1,2 delims=|" %%a in ("modify_target_list.txt") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        set "src=%SRC_MODIFY%\%%a"
        set "dest=%PUB_DEV%\%%b"
        set "dest=!dest:/=\!"
        if exist "!src!" (
            if exist "!dest:~0,-1!" (
                copy "!src!" "!dest!"
                echo !src! 를 !dest! 로 복사했습니다
            ) else (
                echo 오류: 대상 디렉토리 !dest:~0,-1! 가 존재하지 않습니다
            )
        ) else (
            echo 경고: 소스 파일 !src! 를 찾을 수 없습니다
        )
    )
)

echo 모든 파일 복사가 완료되었습니다.
