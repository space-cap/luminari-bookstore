# Luminari Bookstore - 데이터베이스 스크립트

## 개요
이 디렉토리는 Luminari Bookstore 프로젝트의 MySQL 데이터베이스 스크립트를 포함합니다.

## 디렉토리 구조
```
database/
├── scripts/                          # SQL 스크립트 파일들
│   ├── 01_create_database.sql       # 데이터베이스 생성 ✅
│   ├── 02_create_tables.sql         # 전체 테이블 생성 (28개) ✅
│   ├── 03_create_triggers.sql       # 트리거 생성 (6개) ✅
│   ├── 04_create_procedures.sql     # 스토어드 프로시저 (2개) ✅
│   ├── 05_insert_initial_data.sql   # 초기 데이터 삽입 ✅
│   └── 99_rollback.sql              # 롤백 스크립트 ✅
├── deploy.bat                        # Windows 자동 배포 스크립트
└── README.md                         # 이 파일

```

## 스크립트 실행 순서

### 1. 데이터베이스 생성
```bash
mysql -u root -p < scripts/01_create_database.sql
```

### 2. 테이블 생성
```bash
mysql -u root -p luminari_bookstore < scripts/02_create_tables.sql
```

### 3. 트리거 생성
```bash
mysql -u root -p luminari_bookstore < scripts/03_create_triggers.sql
```

### 4. 스토어드 프로시저 생성
```bash
mysql -u root -p luminari_bookstore < scripts/04_create_procedures.sql
```

### 5. 초기 데이터 삽입
```bash
mysql -u root -p luminari_bookstore < scripts/05_insert_initial_data.sql
```

## 전체 자동 배포 (Windows)
```batch
@echo off
echo ====== Luminari Bookstore DB 배포 ======
set DB_NAME=luminari_bookstore
set DB_USER=root
set /p DB_PASS="MySQL root 비밀번호 입력: "

echo 1. 데이터베이스 생성...
mysql -u %DB_USER% -p%DB_PASS% < scripts\01_create_database.sql

echo 2. 테이블 생성...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < scripts\02_create_tables.sql

echo 3. 트리거 생성...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < scripts\03_create_triggers.sql

echo 4. 스토어드 프로시저 생성...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < scripts\04_create_procedures.sql

echo 5. 초기 데이터 삽입...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < scripts\05_insert_initial_data.sql

echo ====== 배포 완료 ======
pause
```

## 데이터베이스 정보

### 기본 설정
- **데이터베이스명**: `luminari_bookstore`
- **문자셋**: `utf8mb4`
- **Collation**: `utf8mb4_unicode_ci`
- **스토리지 엔진**: `InnoDB`

### 사용자 계정
| 사용자 | 비밀번호 | 권한 | 용도 |
|:------|:--------|:-----|:-----|
| luminari_user@localhost | Luminari2025! | ALL PRIVILEGES | 애플리케이션 사용자 (로컬) |
| luminari_user@% | Luminari2025! | ALL PRIVILEGES | 애플리케이션 사용자 (원격) |
| luminari_readonly@localhost | ReadOnly2025! | SELECT | 읽기 전용 (리포트용) |

**⚠️ 주의**: 프로덕션 환경에서는 반드시 강력한 비밀번호로 변경하세요!

### 테이블 목록 (총 28개)

#### 회원 도메인
- `member` - 회원
- `address` - 배송지
- `authority` - 권한

#### 상품 도메인
- `author` - 저자
- `publisher` - 출판사
- `category` - 카테고리
- `book` - 책
- `book_category` - 책-카테고리 연결

#### 주문 도메인
- `cart` - 장바구니
- `cart_item` - 장바구니 항목
- `orders` - 주문
- `order_item` - 주문 항목
- `payment` - 결제
- `shipment` - 배송

#### 프로모션 도메인
- `coupon` - 쿠폰
- `user_coupon` - 사용자 보유 쿠폰
- `point_history` - 포인트 내역

#### 커뮤니티 도메인
- `review` - 리뷰
- `review_like` - 리뷰 좋아요
- `book_club` - 독서 모임
- `club_member` - 모임 멤버
- `achievement` - 업적
- `user_achievement` - 사용자 획득 업적
- `bookshelf` - 가상 서재
- `bookshelf_item` - 서재 아이템

## 백업 및 복구

### 백업
```bash
# 전체 백업
mysqldump -u luminari_user -p --databases luminari_bookstore \
    --routines --triggers --events \
    --single-transaction \
    --quick \
    --lock-tables=false \
    > luminari_backup_$(date +%Y%m%d_%H%M%S).sql

# 특정 테이블만 백업
mysqldump -u luminari_user -p luminari_bookstore member orders order_item \
    > critical_tables_backup.sql
```

### 복구
```bash
mysql -u luminari_user -p luminari_bookstore < luminari_backup_20250119_120000.sql
```

## 검증

### 테이블 생성 확인
```sql
USE luminari_bookstore;
SHOW TABLES;
```

### 데이터 확인
```sql
-- 카테고리 조회
SELECT * FROM category WHERE depth = 1;

-- 샘플 도서 조회
SELECT b.title, a.name AS author, p.name AS publisher, b.price
FROM book b
INNER JOIN author a ON b.author_id = a.author_id
INNER JOIN publisher p ON b.publisher_id = p.publisher_id;

-- 업적 조회
SELECT * FROM achievement;
```

### 인덱스 확인
```sql
SHOW INDEX FROM book;
SHOW INDEX FROM orders;
```

### 트리거 확인
```sql
SHOW TRIGGERS;
```

## 트러블슈팅

### 문제 1: "Access denied for user" 오류
**원인**: 사용자 권한이 없음
**해결**:
```sql
-- root로 접속 후
GRANT ALL PRIVILEGES ON luminari_bookstore.* TO 'luminari_user'@'localhost';
FLUSH PRIVILEGES;
```

### 문제 2: 외래키 제약조건 오류
**원인**: 참조하는 테이블이 먼저 생성되지 않음
**해결**: 스크립트 실행 순서 확인 (부모 테이블 먼저 생성)

### 문제 3: 문자셋 관련 오류
**원인**: utf8mb4가 아닌 utf8 사용
**해결**:
```sql
ALTER DATABASE luminari_bookstore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE 테이블명 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 성능 최적화 팁

1. **슬로우 쿼리 로그 활성화**
```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
```

2. **인덱스 사용률 확인**
```sql
SHOW INDEX FROM book;
EXPLAIN SELECT * FROM book WHERE title LIKE '%검색어%';
```

3. **InnoDB 버퍼 풀 크기 조정**
```ini
# my.cnf / my.ini
[mysqld]
innodb_buffer_pool_size = 2G  # 전체 메모리의 70~80%
```

## 참고 문서
- [1단계: 요구사항 분석](../docs/1단계_요구사항_분석_상세.md)
- [2단계: 개념적 데이터 모델링](../docs/2단계_개념적_데이터_모델링.md)
- [3단계: 논리적 데이터 모델링](../docs/3단계_논리적_데이터_모델링.md)
- [4단계: 물리적 데이터 모델링](../docs/4단계_물리적_데이터_모델링.md)

## 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---
**작성일**: 2025-11-19  
**버전**: 1.0  
**작성자**: Luminari Development Team
