-- ============================================================
-- Luminari Bookstore - 롤백 스크립트
-- ============================================================
-- 파일명: 99_rollback.sql
-- 설명: 전체 데이터베이스 및 사용자 삭제 (주의!)
-- 작성일: 2025-11-19
-- ⚠️ 주의: 이 스크립트는 모든 데이터를 삭제합니다!
-- ============================================================

-- ============================================================
-- 경고 메시지
-- ============================================================

SELECT '===================================================' AS '';
SELECT '⚠️  경고: 데이터베이스 삭제 스크립트입니다!' AS '';
SELECT '===================================================' AS '';
SELECT '이 스크립트를 실행하면 다음이 삭제됩니다:' AS '';
SELECT '1. luminari_bookstore 데이터베이스 (모든 테이블 및 데이터)' AS '';
SELECT '2. 데이터베이스 사용자 계정 (luminari_user, luminari_readonly)' AS '';
SELECT '' AS '';
SELECT '계속하려면 이 스크립트를 수동으로 실행하세요.' AS '';
SELECT '===================================================' AS '';

-- ============================================================
-- 프로덕션 환경 체크 (안전장치)
-- ============================================================

-- 현재 환경 확인
SELECT 
    @@hostname AS 'Hostname',
    DATABASE() AS 'Current Database',
    USER() AS 'Current User';

-- ============================================================
-- 롤백 실행 (주석 해제 후 실행)
-- ============================================================

-- 1. 데이터베이스 삭제
-- ⚠️ 아래 주석을 해제하고 실행하세요
-- DROP DATABASE IF EXISTS luminari_bookstore;

-- 2. 사용자 삭제
-- ⚠️ 아래 주석을 해제하고 실행하세요
-- DROP USER IF EXISTS 'luminari_user'@'localhost';
-- DROP USER IF EXISTS 'luminari_user'@'%';
-- DROP USER IF EXISTS 'luminari_readonly'@'localhost';

-- 3. 권한 재로드
-- FLUSH PRIVILEGES;

-- ============================================================
-- 롤백 확인
-- ============================================================

-- 데이터베이스 목록 확인
-- SHOW DATABASES LIKE 'luminari%';

-- 사용자 목록 확인
-- SELECT User, Host FROM mysql.user WHERE User LIKE 'luminari%';

-- SELECT '=== 롤백 완료 ===' AS 'Status';

-- ============================================================
-- 재배포 가이드
-- ============================================================

/*
롤백 후 재배포하려면 다음 순서로 스크립트를 실행하세요:

1. mysql -u root -p < 01_create_database.sql
2. mysql -u root -p luminari_bookstore < 02_create_tables.sql
3. mysql -u root -p luminari_bookstore < 03_create_triggers.sql
4. mysql -u root -p luminari_bookstore < 04_create_procedures.sql
5. mysql -u root -p luminari_bookstore < 05_insert_initial_data.sql

또는 Windows 자동 배포 스크립트 실행:
   deploy.bat
*/
