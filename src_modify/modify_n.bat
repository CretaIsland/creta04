@echo off
setlocal enabledelayedexpansion

:: 스크립트가 있는 디렉토리로 이동
cd /d "%~dp0"

:: PUB_DEV 경로 설정
if not defined PUB_DEV (
    set "PUB_DEV=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev"
)

set "SRC_MODIFY=."
set "ERROR_COUNT=0"

echo pub.dev 디렉토리 사용: %PUB_DEV%

:: 폰트 파일 여부 확인 함수
:is_font_file
set "dest_path=%~1"
echo "%dest_path%" | findstr /i "html_editor_enhanced.*[\\\/]lib[\\\/]assets[\\\/]font[\\\/]" >nul
exit /b %errorlevel%

:: 파일 복사 함수
:copy_file
set "src=%~1"
set "dest=%~2"
set "dest_dir=%~dp2"

:: 대상 디렉토리가 없을 경우
if not exist "!dest_dir!" (
    :: 폰트 파일인 경우에만 디렉토리 생성
    call :is_font_file "!dest!"
    if !errorlevel! equ 0 (
        mkdir "!dest_dir!" 2>nul
        if errorlevel 1 (
            echo 실패: 폰트 디렉토리 생성 실패 - !dest_dir!
            exit /b 1
        )
    ) else (
        echo 실패: 대상 디렉토리가 존재하지 않습니다 - !dest_dir!
        exit /b 1
    )
)

if exist "!src!" (
    copy "!src!" "!dest!" >nul 2>&1
    if errorlevel 1 (
        echo 실패: !src! 복사 중 오류 발생
        exit /b 1
    ) else (
        echo 성공: !src! 를 !dest! 로 복사했습니다
        exit /b 0
    )
) else (
    echo 실패: 소스 파일 !src! 를 찾을 수 없습니다
    exit /b 1
)

:: 메인 처리
for /f "usebackq tokens=1,2 delims=|" %%a in ("modify_target_list.txt") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        set "src=%SRC_MODIFY%\%%a"
        set "dest=%PUB_DEV%\%%b"
        set "dest=!dest:/=\!"
        
        call :copy_file "!src!" "!dest!"
        if errorlevel 1 (
            set /a ERROR_COUNT+=1
        )
    )
)

echo.
if !ERROR_COUNT! gtr 0 (
    echo 작업 완료: !ERROR_COUNT!개의 오류가 발생했습니다.
    exit /b 1
) else (
    echo 작업 완료: 모든 파일이 성공적으로 복사되었습니다.
    exit /b 0
)
