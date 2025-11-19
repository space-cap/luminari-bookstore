-- ============================================================
-- Luminari Bookstore - 초기 데이터 삽입 스크립트
-- ============================================================
-- 파일명: 05_insert_initial_data.sql
-- 설명: 카테고리, 저자, 출판사, 샘플 도서, 업적, 관리자 계정
-- 작성일: 2025-11-19
-- ============================================================

USE luminari_bookstore;

-- ============================================================
-- 1. 카테고리 초기 데이터
-- ============================================================

-- 1.1 대분류 (depth=1)
INSERT INTO category (name, parent_category_id, depth, display_order, description) VALUES
('소설', NULL, 1, 1, '다양한 장르의 소설'),
('인문', NULL, 1, 2, '인문학 관련 도서'),
('경제경영', NULL, 1, 3, '경제 및 경영 도서'),
('자기계발', NULL, 1, 4, '자기계발 및 성공학'),
('IT/프로그래밍', NULL, 1, 5, 'IT 기술 및 프로그래밍'),
('과학', NULL, 1, 6, '과학 및 기술 도서'),
('예술/대중문화', NULL, 1, 7, '예술 및 대중문화'),
('여행', NULL, 1, 8, '여행 가이드 및 에세이'),
('취미/실용', NULL, 1, 9, '취미 및 실용 도서'),
('아동/청소년', NULL, 1, 10, '아동 및 청소년 도서');

-- 1.2 중분류 (depth=2) - 소설 하위
INSERT INTO category (name, parent_category_id, depth, display_order) VALUES
('한국소설', 1, 2, 1),
('외국소설', 1, 2, 2),
('SF/판타지', 1, 2, 3),
('추리/스릴러', 1, 2, 4),
('로맨스', 1, 2, 5);

-- 1.3 소분류 (depth=3) - 외국소설 하위
INSERT INTO category (name, parent_category_id, depth, display_order) VALUES
('영미소설', 12, 3, 1),
('일본소설', 12, 3, 2),
('프랑스소설', 12, 3, 3),
('독일소설', 12, 3, 4);

-- 1.4 중분류 (depth=2) - IT/프로그래밍 하위
INSERT INTO category (name, parent_category_id, depth, display_order) VALUES
('프로그래밍 언어', 5, 2, 1),
('웹 개발', 5, 2, 2),
('데이터베이스', 5, 2, 3),
('알고리즘/자료구조', 5, 2, 4),
('AI/머신러닝', 5, 2, 5);

SELECT '카테고리 데이터 삽입 완료' AS 'Status';

-- ============================================================
-- 2. 저자 샘플 데이터
-- ============================================================

INSERT INTO author (name, bio, nationality) VALUES
('J.K. 롤링', '해리포터 시리즈 작가. 영국의 소설가이자 영화 제작자.', '영국'),
('무라카미 하루키', '일본 현대 문학의 거장. 세계적으로 사랑받는 소설가.', '일본'),
('김영하', '한국의 대표 소설가. 다수의 문학상 수상.', '한국'),
('조지 오웰', '1984, 동물농장의 작가. 영국의 소설가이자 언론인.', '영국'),
('마틴 클레프만', '데이터 중심 애플리케이션 설계 저자. LinkedIn 소프트웨어 엔지니어.', '영국'),
('로버트 C. 마틴', '클린 코드 저자. 소프트웨어 장인이자 컨설턴트.', '미국'),
('에릭 에반스', '도메인 주도 설계 저자. DDD의 창시자.', '미국'),
('한강', '채식주의자로 맨부커상 수상. 한국의 소설가.', '한국');

SELECT '저자 데이터 삽입 완료' AS 'Status';

-- ============================================================
-- 3. 출판사 샘플 데이터
-- ============================================================

INSERT INTO publisher (name, description, website) VALUES
('문학동네', '1993년 창립한 한국의 대표 출판사', 'http://www.munhak.com'),
('민음사', '1966년 설립된 한국의 출판사', 'http://www.minumsa.com'),
('위즈덤하우스', '다양한 장르의 도서를 출간하는 출판사', 'http://www.wisdomhouse.co.kr'),
('한빛미디어', 'IT 전문 출판사', 'http://www.hanbit.co.kr'),
('인사이트', '개발자를 위한 출판사', 'http://www.insightbook.co.kr'),
('에이콘출판사', 'IT 및 프로그래밍 전문 출판사', 'http://www.acornpub.co.kr');

SELECT '출판사 데이터 삽입 완료' AS 'Status';

-- ============================================================
-- 4. 도서 샘플 데이터
-- ============================================================

INSERT INTO book (
    isbn, title, author_id, publisher_id, publish_date, pages, 
    price, discount_rate, final_price, cover_image, description, stock
) VALUES
('9788932917245', '해리포터와 마법사의 돌', 1, 1, '1999-06-26', 392, 
 15000, 10, 13500, '/images/books/harry-potter-1.jpg', 
 '영국의 평범한 소년 해리포터가 마법 세계로 들어가며 시작되는 모험 이야기', 50),
 
('9788937460883', '노르웨이의 숲', 2, 2, '1989-07-04', 456,
 14000, 10, 12600, '/images/books/norwegian-wood.jpg',
 '상실의 시대를 살아가는 젊은이들의 사랑과 방황을 그린 무라카미 하루키의 대표작', 30),
 
('9788954682084', '살인자의 기억법', 3, 1, '2013-07-16', 252,
 13000, 10, 11700, '/images/books/memory-of-murderer.jpg',
 '알츠하이머에 걸린 전직 연쇄살인마의 기억. 김영하의 스릴러 소설', 40),
 
('9788937462795', '1984', 4, 2, '1949-06-08', 408,
 12000, 15, 10200, '/images/books/1984.jpg',
 '전체주의 디스토피아를 그린 조지 오웰의 고전', 60),
 
('9788966262335', '데이터 중심 애플리케이션 설계', 5, 5, '2018-04-09', 680,
 36000, 0, 36000, '/images/books/designing-data-intensive.jpg',
 '신뢰할 수 있고 확장 가능하며 유지보수하기 쉬운 시스템을 지탱하는 핵심 아이디어', 20),
 
('9788966262656', '클린 코드', 6, 5, '2013-12-24', 584,
 33000, 10, 29700, '/images/books/clean-code.jpg',
 '애자일 소프트웨어 장인 정신. 로버트 C. 마틴의 코드 품질 가이드', 25),
 
('9788960771352', '도메인 주도 설계', 7, 6, '2011-08-01', 648,
 38000, 10, 34200, '/images/books/domain-driven-design.jpg',
 '소프트웨어의 복잡성을 다루는 혁신적인 접근법. DDD의 바이블', 15),
 
('9788936434120', '채식주의자', 8, 1, '2007-10-30', 192,
 10000, 10, 9000, '/images/books/vegetarian.jpg',
 '맨부커상 수상작. 한강의 대표작으로 인간 내면의 폭력성을 그린 소설', 35);

SELECT '도서 데이터 삽입 완료' AS 'Status';

-- ============================================================
-- 5. 도서-카테고리 연결
-- ============================================================

INSERT INTO book_category (book_id, category_id, is_main) VALUES
(1, 16, TRUE),  -- 해리포터 - 영미소설 (주)
(1, 13, FALSE), -- 해리포터 - SF/판타지
(2, 17, TRUE),  -- 노르웨이의 숲 - 일본소설 (주)
(3, 11, TRUE),  -- 살인자의 기억법 - 한국소설 (주)
(3, 14, FALSE), -- 살인자의 기억법 - 추리/스릴러
(4, 12, TRUE),  -- 1984 - 외국소설 (주)
(4, 13, FALSE), -- 1984 - SF/판타지
(5, 5, TRUE),   -- 데이터 중심 애플리케이션 설계 - IT/프로그래밍 (주)
(5, 23, FALSE), -- 데이터 중심 애플리케이션 설계 - 데이터베이스
(6, 5, TRUE),   -- 클린 코드 - IT/프로그래밍 (주)
(6, 21, FALSE), -- 클린 코드 - 프로그래밍 언어
(7, 5, TRUE),   -- 도메인 주도 설계 - IT/프로그래밍 (주)
(8, 11, TRUE);  -- 채식주의자 - 한국소설 (주)

SELECT '도서-카테고리 연결 완료' AS 'Status';

-- ============================================================
-- 6. 업적 초기 데이터
-- ============================================================

INSERT INTO achievement (type, name, description, `condition`, reward_rxp) VALUES
('BADGE', '첫 발걸음', '첫 번째 도서 구매', '{"purchase_count": 1}', 100),
('BADGE', '책벌레', '도서 10권 구매', '{"purchase_count": 10}', 500),
('BADGE', '독서광', '도서 50권 구매', '{"purchase_count": 50}', 2000),
('BADGE', '도서관 관장', '도서 100권 구매', '{"purchase_count": 100}', 5000),
('TITLE', '베스트 리뷰어', '리뷰 10개 이상 작성', '{"review_count": 10}', 300),
('TITLE', '사진 작가', '사진 포함 리뷰 5개 이상', '{"photo_review_count": 5}', 200),
('TITLE', '토론의 달인', '독서 모임 10회 이상 참여', '{"club_participation": 10}', 500),
('BADGE', '백만 원의 독서', '누적 구매 금액 100만 원', '{"total_purchase_amount": 1000000}', 1000),
('BADGE', '소설 마니아', '소설 카테고리 30권 구매', '{"category_id": 1, "purchase_count": 30}', 800),
('BADGE', 'IT 전문가', 'IT/프로그래밍 카테고리 20권 구매', '{"category_id": 5, "purchase_count": 20}', 800);

SELECT '업적 데이터 삽입 완료' AS 'Status';

-- ============================================================
-- 7. 관리자 계정 생성
-- ============================================================

-- 관리자 계정 생성 (비밀번호: Admin2025! - BCrypt 해시 예시)
-- 실제 프로덕션에서는 BCrypt로 암호화된 비밀번호 사용
INSERT INTO member (email, password, name, nickname, phone, level, status)
VALUES ('admin@luminari.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCy', 
        '관리자', 'admin', '010-0000-0000', 99, 'ACTIVE');

SET @admin_id = LAST_INSERT_ID();

-- 관리자 권한 부여 (MEMBER + ADMIN)
INSERT INTO authority (member_id, role) VALUES 
(@admin_id, 'ROLE_MEMBER'),
(@admin_id, 'ROLE_ADMIN');

-- 관리자 장바구니 및 서재 생성
INSERT INTO cart (member_id) VALUES (@admin_id);
INSERT INTO bookshelf (member_id) VALUES (@admin_id);

SELECT '관리자 계정 생성 완료' AS 'Status', @admin_id AS 'Admin ID';

-- ============================================================
-- 8. 테스트 회원 계정 생성 (선택)
-- ============================================================

-- 테스트 회원 1 (비밀번호: Test1234!)
CALL sp_register_member(
    'user1@test.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCy',
    '홍길동',
    'hong123',
    '010-1111-1111',
    @user1_id
);

SELECT '테스트 회원 1 생성 완료' AS 'Status', @user1_id AS 'User1 ID';

-- 테스트 회원 2 (비밀번호: Test1234!)
CALL sp_register_member(
    'user2@test.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCy',
    '김철수',
    'kim456',
    '010-2222-2222',
    @user2_id
);

SELECT '테스트 회원 2 생성 완료' AS 'Status', @user2_id AS 'User2 ID';

-- ============================================================
-- 초기 데이터 삽입 완료 메시지
-- ============================================================

SELECT '=== 초기 데이터 삽입 완료 ===' AS 'Status';
SELECT '카테고리' AS '항목', COUNT(*) AS '개수' FROM category
UNION ALL
SELECT '저자', COUNT(*) FROM author
UNION ALL
SELECT '출판사', COUNT(*) FROM publisher
UNION ALL
SELECT '도서', COUNT(*) FROM book
UNION ALL
SELECT '업적', COUNT(*) FROM achievement
UNION ALL
SELECT '회원', COUNT(*) FROM member;
