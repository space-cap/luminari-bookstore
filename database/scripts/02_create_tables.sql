-- ============================================================
-- Luminari Bookstore - 테이블 생성 스크립트
-- ============================================================
-- 파일명: 02_create_tables.sql
-- 설명: 전체 28개 테이블 생성 (순서: 부모 테이블 먼저)
-- 작성일: 2025-11-19
-- 참고: docs/4단계_물리적_데이터_모델링.md
-- ============================================================

USE luminari_bookstore;

-- ============================================================
-- 1. 회원 도메인 (Member Domain)
-- ============================================================

-- 1.1 member (회원) - 최상위 테이블
CREATE TABLE member (
    member_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '회원 ID',
    email VARCHAR(100) NOT NULL COMMENT '이메일 (로그인 ID)',
    password VARCHAR(255) NOT NULL COMMENT '암호화된 비밀번호',
    name VARCHAR(50) NOT NULL COMMENT '이름',
    nickname VARCHAR(20) NOT NULL COMMENT '닉네임',
    phone VARCHAR(20) NOT NULL COMMENT '휴대폰 번호',
    profile_image VARCHAR(500) NULL COMMENT '프로필 사진 URL',
    bio VARCHAR(500) NULL COMMENT '자기소개',
    birth_date DATE NULL COMMENT '생년월일',
    gender ENUM('M', 'F', 'OTHER') NULL COMMENT '성별',
    level INT NOT NULL DEFAULT 1 COMMENT '레벨',
    rxp INT NOT NULL DEFAULT 0 COMMENT '경험치 (Reading XP)',
    point INT NOT NULL DEFAULT 0 COMMENT '보유 포인트',
    join_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시',
    last_login DATETIME NULL COMMENT '최근 로그인 일시',
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'WITHDRAWN') NOT NULL DEFAULT 'ACTIVE' COMMENT '계정 상태',
    
    PRIMARY KEY (member_id),
    UNIQUE KEY uk_member_email (email),
    UNIQUE KEY uk_member_nickname (nickname),
    KEY idx_member_phone (phone),
    KEY idx_member_status (status),
    
    CONSTRAINT chk_member_level CHECK (level >= 1),
    CONSTRAINT chk_member_rxp CHECK (rxp >= 0),
    CONSTRAINT chk_member_point CHECK (point >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원';

-- 1.2 address (배송지)
CREATE TABLE address (
    address_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '배송지 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    alias VARCHAR(50) NULL COMMENT '배송지 별칭',
    recipient VARCHAR(50) NOT NULL COMMENT '수령인',
    postal_code VARCHAR(10) NOT NULL COMMENT '우편번호',
    address VARCHAR(200) NOT NULL COMMENT '기본 주소',
    detail_address VARCHAR(100) NULL COMMENT '상세 주소',
    phone VARCHAR(20) NOT NULL COMMENT '연락처',
    is_default BOOLEAN NOT NULL DEFAULT FALSE COMMENT '기본 배송지 여부',
    
    PRIMARY KEY (address_id),
    KEY idx_address_member (member_id),
    
    CONSTRAINT fk_address_member FOREIGN KEY (member_id) 
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배송지';

-- 1.3 authority (권한)
CREATE TABLE authority (
    authority_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '권한 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    role VARCHAR(20) NOT NULL COMMENT '역할 (ROLE_MEMBER, ROLE_ADMIN)',
    
    PRIMARY KEY (authority_id),
    KEY idx_authority_member (member_id),
    
    CONSTRAINT fk_authority_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='권한';

-- ============================================================
-- 2. 상품 도메인 (Product Domain)
-- ============================================================

-- 2.1 author (저자) - 독립 테이블
CREATE TABLE author (
    author_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '저자 ID',
    name VARCHAR(100) NOT NULL COMMENT '저자명',
    bio TEXT NULL COMMENT '약력',
    photo VARCHAR(500) NULL COMMENT '사진 URL',
    nationality VARCHAR(50) NULL COMMENT '국적',
    
    PRIMARY KEY (author_id),
    KEY idx_author_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='저자';

-- 2.2 publisher (출판사) - 독립 테이블
CREATE TABLE publisher (
    publisher_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '출판사 ID',
    name VARCHAR(100) NOT NULL COMMENT '출판사명',
    description TEXT NULL COMMENT '소개',
    website VARCHAR(200) NULL COMMENT '웹사이트',
    contact VARCHAR(100) NULL COMMENT '연락처',
    
    PRIMARY KEY (publisher_id),
    KEY idx_publisher_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='출판사';

-- 2.3 category (카테고리) - 자기 참조 테이블
CREATE TABLE category (
    category_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '카테고리 ID',
    name VARCHAR(50) NOT NULL COMMENT '카테고리명',
    parent_category_id BIGINT NULL COMMENT '부모 카테고리 ID',
    depth TINYINT NOT NULL DEFAULT 1 COMMENT '계층 깊이 (1~3)',
    display_order INT NOT NULL DEFAULT 0 COMMENT '표시 순서',
    description VARCHAR(200) NULL COMMENT '설명',
    
    PRIMARY KEY (category_id),
    KEY idx_category_parent (parent_category_id),
    KEY idx_category_depth (depth),
    
    CONSTRAINT chk_category_depth CHECK (depth >= 1 AND depth <= 3),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id)
        REFERENCES category(category_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='카테고리';

-- 2.4 book (책) - author, publisher 참조
CREATE TABLE book (
    book_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '책 ID',
    isbn VARCHAR(13) NOT NULL COMMENT 'ISBN-13',
    isbn10 VARCHAR(10) NULL COMMENT 'ISBN-10',
    title VARCHAR(200) NOT NULL COMMENT '제목',
    subtitle VARCHAR(200) NULL COMMENT '부제',
    author_id BIGINT NOT NULL COMMENT '저자 ID',
    publisher_id BIGINT NOT NULL COMMENT '출판사 ID',
    publish_date DATE NOT NULL COMMENT '출간일',
    pages INT NULL COMMENT '페이지 수',
    dimensions VARCHAR(50) NULL COMMENT '크기',
    weight INT NULL COMMENT '무게 (g)',
    price DECIMAL(10,2) NOT NULL COMMENT '정가',
    discount_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '할인율 (%)',
    final_price DECIMAL(10,2) NOT NULL COMMENT '최종 가격',
    cover_image VARCHAR(500) NOT NULL COMMENT '표지 이미지 URL',
    detail_images JSON NULL COMMENT '상세 이미지 URL (JSON)',
    description TEXT NULL COMMENT '책 소개',
    table_of_contents TEXT NULL COMMENT '목차',
    preview_pages JSON NULL COMMENT '미리보기 페이지 (JSON)',
    stock INT NOT NULL DEFAULT 0 COMMENT '재고 수량',
    sales_count INT NOT NULL DEFAULT 0 COMMENT '판매 수량',
    rating_avg DECIMAL(3,2) NULL COMMENT '평균 평점',
    review_count INT NOT NULL DEFAULT 0 COMMENT '리뷰 수',
    status ENUM('AVAILABLE', 'OUT_OF_STOCK', 'DISCONTINUED') NOT NULL DEFAULT 'AVAILABLE' COMMENT '상태',
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    updated_date DATETIME NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    
    PRIMARY KEY (book_id),
    UNIQUE KEY uk_book_isbn (isbn),
    KEY idx_book_title (title),
    KEY idx_book_author (author_id),
    KEY idx_book_publisher (publisher_id),
    KEY idx_book_status (status),
    KEY idx_book_publish_date (publish_date),
    KEY idx_book_sales (sales_count DESC),
    KEY idx_book_rating (rating_avg DESC),
    FULLTEXT KEY ft_book_search (title, description),
    
    CONSTRAINT chk_book_price CHECK (price > 0),
    CONSTRAINT chk_book_discount_rate CHECK (discount_rate >= 0 AND discount_rate <= 100),
    CONSTRAINT chk_book_final_price CHECK (final_price >= 0),
    CONSTRAINT chk_book_pages CHECK (pages IS NULL OR pages > 0),
    CONSTRAINT chk_book_weight CHECK (weight IS NULL OR weight > 0),
    CONSTRAINT chk_book_stock CHECK (stock >= 0),
    CONSTRAINT chk_book_sales_count CHECK (sales_count >= 0),
    CONSTRAINT chk_book_review_count CHECK (review_count >= 0),
    CONSTRAINT chk_book_rating_avg CHECK (rating_avg IS NULL OR (rating_avg >= 0 AND rating_avg <= 5.0)),
    
    CONSTRAINT fk_book_author FOREIGN KEY (author_id)
        REFERENCES author(author_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES publisher(publisher_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='책';

-- 2.5 book_category (책-카테고리 연결) - N:M 관계 해소
CREATE TABLE book_category (
    book_category_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '연결 ID',
    book_id BIGINT NOT NULL COMMENT '책 ID',
    category_id BIGINT NOT NULL COMMENT '카테고리 ID',
    is_main BOOLEAN NOT NULL DEFAULT FALSE COMMENT '주 카테고리 여부',
    
    PRIMARY KEY (book_category_id),
    UNIQUE KEY uk_book_category (book_id, category_id),
    KEY idx_book_category_book (book_id),
    KEY idx_book_category_category (category_id),
    
    CONSTRAINT fk_book_category_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_category_category FOREIGN KEY (category_id)
        REFERENCES category(category_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='책-카테고리 연결';

-- ============================================================
-- 3. 주문 도메인 (Order Domain)
-- ============================================================

-- 3.1 cart (장바구니) - member 참조
CREATE TABLE cart (
    cart_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '장바구니 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    updated_date DATETIME NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 수정일시',
    
    PRIMARY KEY (cart_id),
    UNIQUE KEY uk_cart_member (member_id),
    
    CONSTRAINT fk_cart_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장바구니';

-- 3.2 cart_item (장바구니 항목) - cart, book 참조
CREATE TABLE cart_item (
    cart_item_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '장바구니 항목 ID',
    cart_id BIGINT NOT NULL COMMENT '장바구니 ID',
    book_id BIGINT NOT NULL COMMENT '책 ID',
    quantity INT NOT NULL DEFAULT 1 COMMENT '수량',
    added_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '담은 날짜',
    
    PRIMARY KEY (cart_item_id),
    UNIQUE KEY uk_cart_item (cart_id, book_id),
    KEY idx_cart_item_cart (cart_id),
    KEY idx_cart_item_book (book_id),
    
    CONSTRAINT chk_cart_item_quantity CHECK (quantity >= 1 AND quantity <= 99),
    
    CONSTRAINT fk_cart_item_cart FOREIGN KEY (cart_id)
        REFERENCES cart(cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_item_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장바구니 항목';

-- 3.3 orders (주문) - member 참조
CREATE TABLE orders (
    order_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '주문 ID',
    order_number VARCHAR(20) NOT NULL COMMENT '주문번호',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '주문일시',
    status ENUM('PENDING', 'PAYMENT_COMPLETED', 'PREPARING', 'SHIPPING', 'DELIVERED', 'CONFIRMED', 'CANCELLED', 'REFUNDED') 
        NOT NULL DEFAULT 'PENDING' COMMENT '주문 상태',
    total_product_price DECIMAL(10,2) NOT NULL COMMENT '총 상품 금액',
    shipping_fee DECIMAL(10,2) NOT NULL COMMENT '배송비',
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '할인 금액',
    point_used INT NOT NULL DEFAULT 0 COMMENT '사용 포인트',
    final_price DECIMAL(10,2) NOT NULL COMMENT '최종 결제 금액',
    recipient VARCHAR(50) NOT NULL COMMENT '수령인',
    postal_code VARCHAR(10) NOT NULL COMMENT '우편번호',
    address VARCHAR(200) NOT NULL COMMENT '주소',
    detail_address VARCHAR(100) NULL COMMENT '상세 주소',
    phone VARCHAR(20) NOT NULL COMMENT '연락처',
    delivery_request VARCHAR(200) NULL COMMENT '배송 요청사항',
    
    PRIMARY KEY (order_id),
    UNIQUE KEY uk_order_number (order_number),
    KEY idx_order_member (member_id),
    KEY idx_order_date (order_date DESC),
    KEY idx_order_status (status),
    KEY idx_order_member_date (member_id, order_date DESC),
    KEY idx_order_member_status (member_id, status),
    
    CONSTRAINT chk_order_total_product_price CHECK (total_product_price >= 0),
    CONSTRAINT chk_order_shipping_fee CHECK (shipping_fee >= 0),
    CONSTRAINT chk_order_discount_amount CHECK (discount_amount >= 0),
    CONSTRAINT chk_order_point_used CHECK (point_used >= 0),
    CONSTRAINT chk_order_final_price CHECK (final_price >= 0),
    
    CONSTRAINT fk_order_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문';

-- 3.4 order_item (주문 항목) - orders, book 참조
CREATE TABLE order_item (
    order_item_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '주문 항목 ID',
    order_id BIGINT NOT NULL COMMENT '주문 ID',
    book_id BIGINT NOT NULL COMMENT '책 ID',
    quantity INT NOT NULL COMMENT '수량',
    price DECIMAL(10,2) NOT NULL COMMENT '주문 당시 가격',
    discount_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '주문 당시 할인율',
    subtotal DECIMAL(10,2) NOT NULL COMMENT '소계',
    
    PRIMARY KEY (order_item_id),
    KEY idx_order_item_order (order_id),
    KEY idx_order_item_book (book_id),
    
    CONSTRAINT chk_order_item_quantity CHECK (quantity >= 1),
    CONSTRAINT chk_order_item_price CHECK (price > 0),
    CONSTRAINT chk_order_item_discount_rate CHECK (discount_rate >= 0 AND discount_rate <= 100),
    CONSTRAINT chk_order_item_subtotal CHECK (subtotal >= 0),
    
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_item_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 항목';

-- 3.5 payment (결제) - orders 참조
CREATE TABLE payment (
    payment_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '결제 ID',
    order_id BIGINT NOT NULL COMMENT '주문 ID',
    payment_method ENUM('CARD', 'BANK_TRANSFER', 'KAKAO_PAY', 'NAVER_PAY', 'TOSS') NOT NULL COMMENT '결제 수단',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '결제일시',
    amount DECIMAL(10,2) NOT NULL COMMENT '결제 금액',
    pg_provider VARCHAR(50) NULL COMMENT 'PG사',
    pg_transaction_id VARCHAR(100) NULL COMMENT 'PG 거래 ID',
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED') NOT NULL DEFAULT 'PENDING' COMMENT '결제 상태',
    
    PRIMARY KEY (payment_id),
    UNIQUE KEY uk_payment_order (order_id),
    KEY idx_payment_pg_transaction (pg_transaction_id),
    
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='결제';

-- 3.6 shipment (배송) - orders 참조
CREATE TABLE shipment (
    shipment_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '배송 ID',
    order_id BIGINT NOT NULL COMMENT '주문 ID',
    courier VARCHAR(50) NULL COMMENT '택배사',
    tracking_number VARCHAR(50) NULL COMMENT '송장번호',
    shipped_date DATETIME NULL COMMENT '발송일시',
    delivered_date DATETIME NULL COMMENT '배송 완료일시',
    status ENUM('PREPARING', 'SHIPPED', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED', 'RETURNED') 
        NOT NULL DEFAULT 'PREPARING' COMMENT '배송 상태',
    
    PRIMARY KEY (shipment_id),
    UNIQUE KEY uk_shipment_order (order_id),
    KEY idx_shipment_tracking (tracking_number),
    
    CONSTRAINT fk_shipment_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배송';

-- ============================================================
-- 4. 프로모션 도메인 (Promotion Domain)
-- ============================================================

-- 4.1 coupon (쿠폰) - category, book 참조 (선택)
CREATE TABLE coupon (
    coupon_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '쿠폰 ID',
    code VARCHAR(50) NOT NULL COMMENT '쿠폰 코드',
    name VARCHAR(100) NOT NULL COMMENT '쿠폰명',
    type ENUM('FIXED', 'PERCENT', 'FREE_SHIPPING') NOT NULL COMMENT '쿠폰 유형',
    discount_value DECIMAL(10,2) NOT NULL COMMENT '할인 값',
    min_order_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '최소 주문 금액',
    max_discount_amount DECIMAL(10,2) NULL COMMENT '최대 할인 금액',
    start_date DATE NOT NULL COMMENT '사용 시작일',
    end_date DATE NOT NULL COMMENT '사용 종료일',
    total_quantity INT NULL COMMENT '총 발행 수량',
    issued_quantity INT NOT NULL DEFAULT 0 COMMENT '발급된 수량',
    target_category_id BIGINT NULL COMMENT '대상 카테고리',
    target_book_id BIGINT NULL COMMENT '대상 도서',
    
    PRIMARY KEY (coupon_id),
    UNIQUE KEY uk_coupon_code (code),
    KEY idx_coupon_date (start_date, end_date),
    
    CONSTRAINT chk_coupon_discount_value CHECK (discount_value > 0),
    CONSTRAINT chk_coupon_min_order_amount CHECK (min_order_amount >= 0),
    CONSTRAINT chk_coupon_max_discount_amount CHECK (max_discount_amount IS NULL OR max_discount_amount > 0),
    CONSTRAINT chk_coupon_total_quantity CHECK (total_quantity IS NULL OR total_quantity > 0),
    CONSTRAINT chk_coupon_issued_quantity CHECK (issued_quantity >= 0),
    
    CONSTRAINT fk_coupon_category FOREIGN KEY (target_category_id)
        REFERENCES category(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_coupon_book FOREIGN KEY (target_book_id)
        REFERENCES book(book_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰';

-- 4.2 user_coupon (사용자 보유 쿠폰) - member, coupon, orders 참조
CREATE TABLE user_coupon (
    user_coupon_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '사용자 쿠폰 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    coupon_id BIGINT NOT NULL COMMENT '쿠폰 ID',
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발급일시',
    used_date DATETIME NULL COMMENT '사용일시',
    order_id BIGINT NULL COMMENT '사용한 주문 ID',
    status ENUM('AVAILABLE', 'USED', 'EXPIRED') NOT NULL DEFAULT 'AVAILABLE' COMMENT '상태',
    
    PRIMARY KEY (user_coupon_id),
    KEY idx_user_coupon_member (member_id),
    KEY idx_user_coupon_status (status),
    KEY idx_user_coupon_member_status (member_id, status),
    
    CONSTRAINT fk_user_coupon_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_coupon_coupon FOREIGN KEY (coupon_id)
        REFERENCES coupon(coupon_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_coupon_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 보유 쿠폰';

-- 4.3 point_history (포인트 내역) - member, orders 참조
CREATE TABLE point_history (
    point_history_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '포인트 내역 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    type ENUM('EARN', 'USE', 'CANCEL', 'EXPIRE') NOT NULL COMMENT '유형',
    amount INT NOT NULL COMMENT '금액',
    reason VARCHAR(200) NOT NULL COMMENT '사유',
    order_id BIGINT NULL COMMENT '관련 주문 ID',
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발생일시',
    balance INT NOT NULL COMMENT '거래 후 잔액',
    expires_date DATE NULL COMMENT '만료일',
    
    PRIMARY KEY (point_history_id),
    KEY idx_point_history_member (member_id),
    KEY idx_point_history_created (created_date DESC),
    KEY idx_point_history_member_created (member_id, created_date DESC),
    
    CONSTRAINT chk_point_history_balance CHECK (balance >= 0),
    
    CONSTRAINT fk_point_history_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_point_history_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='포인트 내역';

-- ============================================================
-- 5. 커뮤니티 도메인 (Community Domain)
-- ============================================================

-- 5.1 review (리뷰) - member, book, orders 참조
CREATE TABLE review (
    review_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '리뷰 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    book_id BIGINT NOT NULL COMMENT '책 ID',
    order_id BIGINT NULL COMMENT '구매 확인용 주문 ID',
    rating DECIMAL(2,1) NOT NULL COMMENT '별점 (1.0~5.0)',
    content TEXT NOT NULL COMMENT '리뷰 내용',
    photos JSON NULL COMMENT '사진 URL 목록',
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '작성일시',
    updated_date DATETIME NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    like_count INT NOT NULL DEFAULT 0 COMMENT '좋아요 수',
    status ENUM('ACTIVE', 'HIDDEN', 'DELETED') NOT NULL DEFAULT 'ACTIVE' COMMENT '상태',
    
    PRIMARY KEY (review_id),
    UNIQUE KEY uk_review_member_book (member_id, book_id),
    KEY idx_review_book (book_id),
    KEY idx_review_member (member_id),
    KEY idx_review_created (created_date DESC),
    KEY idx_review_rating (rating DESC),
    KEY idx_review_like (like_count DESC),
    KEY idx_review_status (status),
    
    CONSTRAINT chk_review_rating CHECK (rating >= 1.0 AND rating <= 5.0),
    CONSTRAINT chk_review_like_count CHECK (like_count >= 0),
    
    CONSTRAINT fk_review_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='리뷰';

-- 5.2 review_like (리뷰 좋아요) - review, member 참조
CREATE TABLE review_like (
    review_like_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '리뷰 좋아요 ID',
    review_id BIGINT NOT NULL COMMENT '리뷰 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '좋아요 누른 날짜',
    
    PRIMARY KEY (review_like_id),
    UNIQUE KEY uk_review_like (review_id, member_id),
    KEY idx_review_like_review (review_id),
    KEY idx_review_like_member (member_id),
    
    CONSTRAINT fk_review_like_review FOREIGN KEY (review_id)
        REFERENCES review(review_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_like_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='리뷰 좋아요';

-- 5.3 book_club (독서 모임) - book, member 참조
CREATE TABLE book_club (
    club_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '모임 ID',
    title VARCHAR(100) NOT NULL COMMENT '모임명',
    book_id BIGINT NOT NULL COMMENT '대상 도서 ID',
    creator_id BIGINT NOT NULL COMMENT '생성자 ID',
    description TEXT NULL COMMENT '모임 소개',
    start_date DATE NOT NULL COMMENT '시작일',
    end_date DATE NOT NULL COMMENT '종료일',
    max_members INT NOT NULL COMMENT '최대 인원',
    current_members INT NOT NULL DEFAULT 1 COMMENT '현재 인원',
    status ENUM('RECRUITING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'RECRUITING' COMMENT '상태',
    
    PRIMARY KEY (club_id),
    KEY idx_book_club_book (book_id),
    KEY idx_book_club_status (status),
    KEY idx_book_club_status_date (status, start_date),
    
    CONSTRAINT chk_book_club_max_members CHECK (max_members > 0),
    CONSTRAINT chk_book_club_current_members CHECK (current_members >= 0),
    
    CONSTRAINT fk_book_club_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_book_club_creator FOREIGN KEY (creator_id)
        REFERENCES member(member_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='독서 모임';

-- 5.4 club_member (모임 멤버) - book_club, member 참조
CREATE TABLE club_member (
    club_member_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '모임 멤버 ID',
    club_id BIGINT NOT NULL COMMENT '모임 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    joined_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시',
    role ENUM('LEADER', 'MEMBER') NOT NULL DEFAULT 'MEMBER' COMMENT '역할',
    status ENUM('ACTIVE', 'WITHDRAWN') NOT NULL DEFAULT 'ACTIVE' COMMENT '상태',
    
    PRIMARY KEY (club_member_id),
    UNIQUE KEY uk_club_member (club_id, member_id),
    KEY idx_club_member_club (club_id),
    KEY idx_club_member_member (member_id),
    
    CONSTRAINT fk_club_member_club FOREIGN KEY (club_id)
        REFERENCES book_club(club_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_club_member_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='모임 멤버';

-- 5.5 achievement (업적) - 독립 테이블
CREATE TABLE achievement (
    achievement_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '업적 ID',
    type ENUM('BADGE', 'TITLE') NOT NULL COMMENT '유형',
    name VARCHAR(50) NOT NULL COMMENT '업적명',
    description VARCHAR(200) NOT NULL COMMENT '설명',
    `condition` JSON NOT NULL COMMENT '달성 조건',
    icon VARCHAR(500) NULL COMMENT '아이콘 이미지 URL',
    reward_rxp INT NOT NULL DEFAULT 0 COMMENT '보상 RXP',
    reward_item JSON NULL COMMENT '보상 아이템',
    
    PRIMARY KEY (achievement_id),
    UNIQUE KEY uk_achievement_name (name),
    KEY idx_achievement_type (type),
    
    CONSTRAINT chk_achievement_reward_rxp CHECK (reward_rxp >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='업적';

-- 5.6 user_achievement (사용자 획득 업적) - member, achievement 참조
CREATE TABLE user_achievement (
    user_achievement_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '사용자 업적 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    achievement_id BIGINT NOT NULL COMMENT '업적 ID',
    acquired_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '획득일시',
    is_displayed BOOLEAN NOT NULL DEFAULT FALSE COMMENT '프로필 표시 여부',
    
    PRIMARY KEY (user_achievement_id),
    UNIQUE KEY uk_user_achievement (member_id, achievement_id),
    KEY idx_user_achievement_member (member_id),
    KEY idx_user_achievement_achievement (achievement_id),
    
    CONSTRAINT fk_user_achievement_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_achievement_achievement FOREIGN KEY (achievement_id)
        REFERENCES achievement(achievement_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 획득 업적';

-- 5.7 bookshelf (가상 서재) - member 참조
CREATE TABLE bookshelf (
    bookshelf_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '서재 ID',
    member_id BIGINT NOT NULL COMMENT '회원 ID',
    theme VARCHAR(50) NULL DEFAULT 'DEFAULT' COMMENT '테마',
    background VARCHAR(500) NULL COMMENT '배경 이미지 URL',
    is_public BOOLEAN NOT NULL DEFAULT TRUE COMMENT '공개 여부',
    visit_count INT NOT NULL DEFAULT 0 COMMENT '방문자 수',
    like_count INT NOT NULL DEFAULT 0 COMMENT '좋아요 수',
    
    PRIMARY KEY (bookshelf_id),
    UNIQUE KEY uk_bookshelf_member (member_id),
    
    CONSTRAINT chk_bookshelf_visit_count CHECK (visit_count >= 0),
    CONSTRAINT chk_bookshelf_like_count CHECK (like_count >= 0),
    
    CONSTRAINT fk_bookshelf_member FOREIGN KEY (member_id)
        REFERENCES member(member_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='가상 서재';

-- 5.8 bookshelf_item (서재 아이템) - bookshelf 참조
CREATE TABLE bookshelf_item (
    item_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '아이템 ID',
    bookshelf_id BIGINT NOT NULL COMMENT '서재 ID',
    item_type ENUM('BOOK', 'FURNITURE', 'DECORATION', 'BACKGROUND') NOT NULL COMMENT '아이템 유형',
    item_code VARCHAR(100) NOT NULL COMMENT '아이템 코드',
    position_x INT NOT NULL DEFAULT 0 COMMENT 'X 좌표',
    position_y INT NOT NULL DEFAULT 0 COMMENT 'Y 좌표',
    rotation INT NOT NULL DEFAULT 0 COMMENT '회전 각도',
    scale DECIMAL(3,2) NOT NULL DEFAULT 1.00 COMMENT '크기 배율',
    
    PRIMARY KEY (item_id),
    KEY idx_bookshelf_item_bookshelf (bookshelf_id),
    
    CONSTRAINT chk_bookshelf_item_rotation CHECK (rotation >= 0 AND rotation <= 360),
    CONSTRAINT chk_bookshelf_item_scale CHECK (scale > 0),
    
    CONSTRAINT fk_bookshelf_item_bookshelf FOREIGN KEY (bookshelf_id)
        REFERENCES bookshelf(bookshelf_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='서재 아이템';

-- ============================================================
-- 테이블 생성 완료 메시지
-- ============================================================

SELECT '=== 테이블 생성 완료 ===' AS 'Status';
SELECT COUNT(*) AS '생성된 테이블 수' FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'luminari_bookstore';

-- 생성된 테이블 목록 확인
SHOW TABLES;
