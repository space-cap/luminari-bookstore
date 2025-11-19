-- ============================================================
-- Luminari Bookstore - 트리거 생성 스크립트
-- ============================================================
-- 파일명: 03_create_triggers.sql
-- 설명: 자동화된 비즈니스 로직 처리를 위한 트리거 6개
-- 작성일: 2025-11-19
-- ============================================================

USE luminari_bookstore;

DELIMITER $$

-- ============================================================
-- 1. 리뷰 관련 트리거
-- ============================================================

-- 1.1 리뷰 작성 시 도서 통계 및 회원 RXP 업데이트
DROP TRIGGER IF EXISTS trg_review_after_insert$$
CREATE TRIGGER trg_review_after_insert
AFTER INSERT ON review
FOR EACH ROW
BEGIN
    -- 리뷰 수 증가 및 평균 평점 갱신
    UPDATE book
    SET review_count = review_count + 1,
        rating_avg = (
            SELECT AVG(rating) 
            FROM review 
            WHERE book_id = NEW.book_id AND status = 'ACTIVE'
        )
    WHERE book_id = NEW.book_id;
    
    -- 회원 RXP 증가 (기본 100 RXP)
    UPDATE member
    SET rxp = rxp + 100
    WHERE member_id = NEW.member_id;
END$$

-- 1.2 리뷰 삭제 시 도서 통계 업데이트
DROP TRIGGER IF EXISTS trg_review_after_delete$$
CREATE TRIGGER trg_review_after_delete
AFTER DELETE ON review
FOR EACH ROW
BEGIN
    -- 리뷰 수 감소 및 평균 평점 재계산
    UPDATE book
    SET review_count = GREATEST(review_count - 1, 0),
        rating_avg = (
            SELECT AVG(rating) 
            FROM review 
            WHERE book_id = OLD.book_id AND status = 'ACTIVE'
        )
    WHERE book_id = OLD.book_id;
END$$

-- ============================================================
-- 2. 리뷰 좋아요 관련 트리거
-- ============================================================

-- 2.1 리뷰 좋아요 추가 시 좋아요 수 증가
DROP TRIGGER IF EXISTS trg_review_like_after_insert$$
CREATE TRIGGER trg_review_like_after_insert
AFTER INSERT ON review_like
FOR EACH ROW
BEGIN
    UPDATE review
    SET like_count = like_count + 1
    WHERE review_id = NEW.review_id;
END$$

-- 2.2 리뷰 좋아요 삭제 시 좋아요 수 감소
DROP TRIGGER IF EXISTS trg_review_like_after_delete$$
CREATE TRIGGER trg_review_like_after_delete
AFTER DELETE ON review_like
FOR EACH ROW
BEGIN
    UPDATE review
    SET like_count = GREATEST(like_count - 1, 0)
    WHERE review_id = OLD.review_id;
END$$

-- ============================================================
-- 3. 주문 상태 변경 시 재고 및 판매량 업데이트
-- ============================================================

DROP TRIGGER IF EXISTS trg_order_after_update$$
CREATE TRIGGER trg_order_after_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- 결제 완료 시 재고 감소 및 판매 수량 증가
    IF NEW.status = 'PAYMENT_COMPLETED' AND OLD.status != 'PAYMENT_COMPLETED' THEN
        -- 주문 항목별 처리
        UPDATE book b
        INNER JOIN order_item oi ON b.book_id = oi.book_id
        SET b.stock = GREATEST(b.stock - oi.quantity, 0),
            b.sales_count = b.sales_count + oi.quantity,
            b.status = CASE 
                WHEN b.stock - oi.quantity <= 0 THEN 'OUT_OF_STOCK' 
                ELSE b.status 
            END
        WHERE oi.order_id = NEW.order_id;
    END IF;
    
    -- 주문 취소 시 재고 복구
    IF NEW.status = 'CANCELLED' AND OLD.status != 'CANCELLED' THEN
        UPDATE book b
        INNER JOIN order_item oi ON b.book_id = oi.book_id
        SET b.stock = b.stock + oi.quantity,
            b.sales_count = GREATEST(b.sales_count - oi.quantity, 0),
            b.status = 'AVAILABLE'
        WHERE oi.order_id = NEW.order_id;
    END IF;
END$$

-- ============================================================
-- 4. 포인트 변동 시 회원 포인트 잔액 갱신
-- ============================================================

DROP TRIGGER IF EXISTS trg_point_history_after_insert$$
CREATE TRIGGER trg_point_history_after_insert
AFTER INSERT ON point_history
FOR EACH ROW
BEGIN
    UPDATE member
    SET point = NEW.balance
    WHERE member_id = NEW.member_id;
END$$

DELIMITER ;

-- ============================================================
-- 트리거 생성 완료 확인
-- ============================================================

SELECT '=== 트리거 생성 완료 ===' AS 'Status';
SHOW TRIGGERS FROM luminari_bookstore;
