-- ============================================================
-- Luminari Bookstore - 스토어드 프로시저 생성 스크립트
-- ============================================================
-- 파일명: 04_create_procedures.sql
-- 설명: 핵심 비즈니스 로직을 위한 스토어드 프로시저
-- 작성일: 2025-11-19
-- ============================================================

USE luminari_bookstore;

DELIMITER $$

-- ============================================================
-- 1. 회원 가입 프로시저
-- ============================================================

DROP PROCEDURE IF EXISTS sp_register_member$$
CREATE PROCEDURE sp_register_member(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_name VARCHAR(50),
    IN p_nickname VARCHAR(20),
    IN p_phone VARCHAR(20),
    OUT p_member_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '회원 가입 실패';
    END;
    
    START TRANSACTION;
    
    -- 1. 회원 정보 삽입
    INSERT INTO member (email, password, name, nickname, phone)
    VALUES (p_email, p_password, p_name, p_nickname, p_phone);
    
    SET p_member_id = LAST_INSERT_ID();
    
    -- 2. 기본 권한 부여 (ROLE_MEMBER)
    INSERT INTO authority (member_id, role)
    VALUES (p_member_id, 'ROLE_MEMBER');
    
    -- 3. 장바구니 생성
    INSERT INTO cart (member_id)
    VALUES (p_member_id);
    
    -- 4. 서재 생성
    INSERT INTO bookshelf (member_id)
    VALUES (p_member_id);
    
    -- 5. 웰컴 포인트 1000P 지급
    INSERT INTO point_history (member_id, type, amount, reason, balance, expires_date)
    VALUES (p_member_id, 'EARN', 1000, '회원 가입 축하', 1000, DATE_ADD(CURDATE(), INTERVAL 1 YEAR));
    
    COMMIT;
END$$

-- ============================================================
-- 2. 주문 생성 프로시저 (간단 버전)
-- ============================================================

DROP PROCEDURE IF EXISTS sp_create_order$$
CREATE PROCEDURE sp_create_order(
    IN p_member_id BIGINT,
    IN p_cart_id BIGINT,
    IN p_recipient VARCHAR(50),
    IN p_postal_code VARCHAR(10),
    IN p_address VARCHAR(200),
    IN p_detail_address VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_delivery_request VARCHAR(200),
    IN p_coupon_id BIGINT,
    IN p_point_used INT,
    OUT p_order_id BIGINT,
    OUT p_order_number VARCHAR(20)
)
BEGIN
    DECLARE v_total_product_price DECIMAL(10,2);
    DECLARE v_shipping_fee DECIMAL(10,2);
    DECLARE v_discount_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_final_price DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '주문 생성 실패';
    END;
    
    START TRANSACTION;
    
    -- 1. 장바구니 총액 계산
    SELECT SUM(b.final_price * ci.quantity)
    INTO v_total_product_price
    FROM cart_item ci
    INNER JOIN book b ON ci.book_id = b.book_id
    WHERE ci.cart_id = p_cart_id;
    
    -- 2. 배송비 계산 (3만원 이상 무료)
    IF v_total_product_price >= 30000 THEN
        SET v_shipping_fee = 0;
    ELSE
        SET v_shipping_fee = 3000;
    END IF;
    
    -- 3. 쿠폰 할인 계산 (간단 버전)
    IF p_coupon_id IS NOT NULL THEN
        SELECT 
            CASE 
                WHEN c.type = 'FIXED' THEN c.discount_value
                WHEN c.type = 'PERCENT' THEN LEAST(v_total_product_price * c.discount_value / 100, IFNULL(c.max_discount_amount, 999999))
                WHEN c.type = 'FREE_SHIPPING' THEN v_shipping_fee
                ELSE 0
            END
        INTO v_discount_amount
        FROM coupon c
        WHERE c.coupon_id = p_coupon_id;
    END IF;
    
    -- 4. 최종 금액 계산
    SET v_final_price = v_total_product_price + v_shipping_fee - v_discount_amount - p_point_used;
    
    -- 5. 주문번호 생성 (ORD + 연월일시분초)
    SET p_order_number = CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
    
    -- 6. 주문 생성
    INSERT INTO orders (
        order_number, member_id, total_product_price, shipping_fee, 
        discount_amount, point_used, final_price,
        recipient, postal_code, address, detail_address, phone, delivery_request
    ) VALUES (
        p_order_number, p_member_id, v_total_product_price, v_shipping_fee,
        v_discount_amount, p_point_used, v_final_price,
        p_recipient, p_postal_code, p_address, p_detail_address, p_phone, p_delivery_request
    );
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- 7. 주문 항목 생성
    INSERT INTO order_item (order_id, book_id, quantity, price, discount_rate, subtotal)
    SELECT 
        p_order_id,
        ci.book_id,
        ci.quantity,
        b.price,
        b.discount_rate,
        b.final_price * ci.quantity
    FROM cart_item ci
    INNER JOIN book b ON ci.book_id = b.book_id
    WHERE ci.cart_id = p_cart_id;
    
    -- 8. 배송 정보 생성
    INSERT INTO shipment (order_id)
    VALUES (p_order_id);
    
    -- 9. 장바구니 비우기
    DELETE FROM cart_item WHERE cart_id = p_cart_id;
    
    -- 10. 쿠폰 사용 처리
    IF p_coupon_id IS NOT NULL THEN
        UPDATE user_coupon
        SET status = 'USED', used_date = NOW(), order_id = p_order_id
        WHERE coupon_id = p_coupon_id AND member_id = p_member_id AND status = 'AVAILABLE'
        LIMIT 1;
    END IF;
    
    -- 11. 포인트 사용 처리
    IF p_point_used > 0 THEN
        INSERT INTO point_history (member_id, type, amount, reason, order_id, balance)
        SELECT p_member_id, 'USE', -p_point_used, '주문 시 포인트 사용', p_order_id, m.point - p_point_used
        FROM member m
        WHERE m.member_id = p_member_id;
    END IF;
    
    COMMIT;
END$$

DELIMITER ;

-- ============================================================
-- 프로시저 생성 완료 확인
-- ============================================================

SELECT '=== 스토어드 프로시저 생성 완료 ===' AS 'Status';
SHOW PROCEDURE STATUS WHERE Db = 'luminari_bookstore';
