@echo off
REM ============================================================
REM Luminari Bookstore - 데이터베이스 자동 배포 스크립트 (Windows)
REM ============================================================
REM 파일명: deploy.bat
REM 설명: 전체 데이터베이스 스크립트를 순차적으로 실행
REM 작성일: 2025-11-19
REM ============================================================

echo ========================================
echo   Luminari Bookstore DB 자동 배포
echo ========================================
echo.

REM 변수 설정
set DB_NAME=luminari_bookstore
set DB_USER=root
set SCRIPT_DIR=%~dp0scripts

REM MySQL 비밀번호 입력
set /p DB_PASS="MySQL root 비밀번호 입력: "

echo.
echo [1/5] 데이터베이스 생성 중...
mysql -u %DB_USER% -p%DB_PASS% < "%SCRIPT_DIR%\01_create_database.sql"
if errorlevel 1 (
    echo ❌ 데이터베이스 생성 실패!
    pause
    exit /b 1
)
echo ✅ 데이터베이스 생성 완료

echo.
echo [2/5] 테이블 생성 중 (28개)...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SCRIPT_DIR%\02_create_tables.sql"
if errorlevel 1 (
    echo ❌ 테이블 생성 실패!
    pause
    exit /b 1
)
echo ✅ 테이블 생성 완료

echo.
echo [3/5] 트리거 생성 중 (6개)...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SCRIPT_DIR%\03_create_triggers.sql"
if errorlevel 1 (
    echo ❌ 트리거 생성 실패!
    pause
    exit /b 1
)
echo ✅ 트리거 생성 완료

echo.
echo [4/5] 스토어드 프로시저 생성 중 (2개)...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SCRIPT_DIR%\04_create_procedures.sql"
if errorlevel 1 (
    echo ❌ 스토어드 프로시저 생성 실패!
    pause
    exit /b 1
)
echo ✅ 스토어드 프로시저 생성 완료

echo.
echo [5/5] 초기 데이터 삽입 중...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SCRIPT_DIR%\05_insert_initial_data.sql"
if errorlevel 1 (
    echo ❌ 초기 데이터 삽입 실패!
    pause
    exit /b 1
)
echo ✅ 초기 데이터 삽입 완료

echo.
echo ========================================
echo   🎉 배포 완료!
echo ========================================
echo.
echo 데이터베이스: %DB_NAME%
echo 테이블: 28개
echo 트리거: 6개
echo 스토어드 프로시저: 2개
echo.
echo 접속 정보:
echo   - 애플리케이션 사용자: luminari_user / Luminari2025!
echo   - 읽기 전용 사용자: luminari_readonly / ReadOnly2025!
echo.
echo ⚠️ 프로덕션 환경에서는 비밀번호를 변경하세요!
echo.

pause
