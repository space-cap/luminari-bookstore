-- ============================================================
-- Luminari Bookstore - 데이터베이스 생성 스크립트
-- ============================================================
-- 파일명: 01_create_database.sql
-- 설명: 데이터베이스 및 사용자 생성
-- 작성일: 2025-11-19
-- ============================================================

-- 기존 데이터베이스 삭제 (개발 환경에서만 사용)
-- 주의: 프로덕션 환경에서는 주석 처리할 것!
DROP DATABASE IF EXISTS luminari_bookstore;

-- 데이터베이스 생성
CREATE DATABASE luminari_bookstore
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 데이터베이스 선택
USE luminari_bookstore;

-- 데이터베이스 정보 확인
SELECT 
    SCHEMA_NAME AS '데이터베이스명',
    DEFAULT_CHARACTER_SET_NAME AS '문자셋',
    DEFAULT_COLLATION_NAME AS 'Collation'
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'luminari_bookstore';

-- 사용자 생성 및 권한 부여
-- 애플리케이션 사용자
CREATE USER IF NOT EXISTS 'luminari_user'@'localhost' IDENTIFIED BY 'Luminari2025!';
CREATE USER IF NOT EXISTS 'luminari_user'@'%' IDENTIFIED BY 'Luminari2025!';

-- 모든 권한 부여
GRANT ALL PRIVILEGES ON luminari_bookstore.* TO 'luminari_user'@'localhost';
GRANT ALL PRIVILEGES ON luminari_bookstore.* TO 'luminari_user'@'%';

-- 읽기 전용 사용자 (리포트/분석용)
CREATE USER IF NOT EXISTS 'luminari_readonly'@'localhost' IDENTIFIED BY 'ReadOnly2025!';
GRANT SELECT ON luminari_bookstore.* TO 'luminari_readonly'@'localhost';

-- 권한 적용
FLUSH PRIVILEGES;

-- 생성된 사용자 확인
SELECT User, Host FROM mysql.user WHERE User LIKE 'luminari%';

-- 완료 메시지
SELECT '데이터베이스 생성 완료!' AS 'Status';
