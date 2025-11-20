# Luminari Bookstore - Backend

## 기술 스택

- **Framework**: Spring Boot 3.x
- **Language**: Java 17
- **Build Tool**: Maven
- **Database**: MySQL 8.0
- **ORM**: Spring Data JPA (Hibernate)
- **Security**: Spring Security + JWT
- **API Documentation**: SpringDoc OpenAPI (Swagger)

## 디렉토리 구조

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/ezlevup/luminari/
│   │   │   ├── LuminariApplication.java    # 메인 애플리케이션
│   │   │   ├── domain/                      # 도메인 엔티티
│   │   │   │   ├── member/
│   │   │   │   ├── book/
│   │   │   │   ├── order/
│   │   │   │   ├── review/
│   │   │   │   └── community/
│   │   │   ├── repository/                  # JPA Repository
│   │   │   ├── service/                     # 비즈니스 로직
│   │   │   ├── controller/                  # REST API 컨트롤러
│   │   │   ├── dto/                         # 데이터 전송 객체
│   │   │   │   ├── request/
│   │   │   │   └── response/
│   │   │   ├── security/                    # 인증/인가
│   │   │   │   ├── jwt/
│   │   │   │   └── filter/
│   │   │   ├── config/                      # 설정
│   │   │   ├── exception/                   # 예외 처리
│   │   │   └── util/                        # 유틸리티
│   │   └── resources/
│   │       ├── application.yml              # 기본 설정
│   │       ├── application-dev.yml          # 개발 환경
│   │       ├── application-prod.yml         # 프로덕션 환경
│   │       └── application-test.yml         # 테스트 환경
│   └── test/
│       └── java/com/ezlevup/luminari/
│           ├── domain/                      # 도메인 테스트
│           ├── service/                     # 서비스 테스트
│           └── controller/                  # 컨트롤러 테스트
├── .mvn/
├── target/                                  # (gitignore)
├── mvnw
├── mvnw.cmd
├── pom.xml
└── README.md
```

## 시작하기

### 1. 사전 요구사항

- Java 17 이상
- Maven 3.6 이상
- MySQL 8.0

### 2. 데이터베이스 설정

```bash
# 데이터베이스 생성 (프로젝트 루트에서)
cd ../database
mysql -u root -p < scripts/01_create_database.sql
mysql -u root -p luminari_bookstore < scripts/02_create_tables.sql
mysql -u root -p luminari_bookstore < scripts/03_create_triggers.sql
mysql -u root -p luminari_bookstore < scripts/04_create_procedures.sql
mysql -u root -p luminari_bookstore < scripts/05_insert_initial_data.sql

# 또는 Windows 자동 배포
cd ../database
deploy.bat
```

### 3. 애플리케이션 실행

```bash
# 개발 모드로 실행
./mvnw spring-boot:run

# 또는 특정 프로파일로 실행
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 또는 JAR 빌드 후 실행
./mvnw clean package
java -jar target/luminari-0.0.1-SNAPSHOT.jar
```

서버가 실행되면 http://localhost:8080 에서 확인할 수 있습니다.

### 4. API 문서 확인

Swagger UI: http://localhost:8080/swagger-ui.html

### 5. 테스트

```bash
# 전체 테스트 실행
./mvnw test

# 특정 테스트 클래스 실행
./mvnw test -Dtest=MemberServiceTest

# 테스트 커버리지 확인
./mvnw test jacoco:report
```

## 환경 설정

### application.yml 예시

```yaml
spring:
  profiles:
    active: dev
  datasource:
    url: jdbc:mysql://localhost:3306/luminari_bookstore
    username: luminari_user
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.MySQL8Dialect

logging:
  level:
    com.ezlevup.luminari: DEBUG
    org.hibernate.SQL: DEBUG
```

### 환경 변수

`.env` 파일 또는 시스템 환경 변수로 설정:

```bash
# 데이터베이스
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=86400000

# 이메일 (선택)
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

## 주요 API 엔드포인트

### 인증 (Authentication)

```
POST   /api/auth/register      # 회원가입
POST   /api/auth/login         # 로그인
POST   /api/auth/refresh       # 토큰 갱신
POST   /api/auth/logout        # 로그아웃
```

### 도서 (Books)

```
GET    /api/books              # 도서 목록 조회
GET    /api/books/{id}         # 도서 상세 조회
GET    /api/books/search       # 도서 검색
GET    /api/books/category/{categoryId}  # 카테고리별 조회
POST   /api/books              # 도서 등록 (관리자)
PUT    /api/books/{id}         # 도서 수정 (관리자)
DELETE /api/books/{id}         # 도서 삭제 (관리자)
```

### 회원 (Members)

```
GET    /api/members/me         # 내 정보 조회
PUT    /api/members/me         # 내 정보 수정
GET    /api/members/me/orders  # 내 주문 내역
GET    /api/members/me/reviews # 내 리뷰 목록
```

### 장바구니 (Cart)

```
GET    /api/cart               # 장바구니 조회
POST   /api/cart/items         # 장바구니 추가
PUT    /api/cart/items/{id}    # 장바구니 수량 변경
DELETE /api/cart/items/{id}    # 장바구니 삭제
DELETE /api/cart                # 장바구니 비우기
```

### 주문 (Orders)

```
POST   /api/orders             # 주문 생성
GET    /api/orders/{id}        # 주문 상세 조회
PUT    /api/orders/{id}/cancel # 주문 취소
```

### 리뷰 (Reviews)

```
GET    /api/books/{bookId}/reviews      # 도서 리뷰 목록
POST   /api/books/{bookId}/reviews      # 리뷰 작성
PUT    /api/reviews/{id}                # 리뷰 수정
DELETE /api/reviews/{id}                # 리뷰 삭제
POST   /api/reviews/{id}/like           # 리뷰 좋아요
```

## 개발 가이드

### 엔티티 작성 예시

```java
@Entity
@Table(name = "book")
@Getter @Setter
@NoArgsConstructor
public class Book extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 13, unique = true)
    private String isbn;
    
    @Column(nullable = false, length = 200)
    private String title;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id")
    private Author author;
    
    @Column(nullable = false)
    private Integer price;
    
    private Integer discountRate = 0;
    
    @Column(nullable = false)
    private Integer finalPrice;
    
    private Integer stock = 0;
}
```

### 서비스 작성 예시

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BookService {
    
    private final BookRepository bookRepository;
    
    public Page<BookResponse> getBooks(Pageable pageable) {
        return bookRepository.findAll(pageable)
            .map(BookResponse::from);
    }
    
    public BookResponse getBook(Long id) {
        Book book = bookRepository.findById(id)
            .orElseThrow(() -> new BookNotFoundException(id));
        return BookResponse.from(book);
    }
    
    @Transactional
    public BookResponse createBook(BookRequest request) {
        Book book = request.toEntity();
        Book saved = bookRepository.save(book);
        return BookResponse.from(saved);
    }
}
```

### 컨트롤러 작성 예시

```java
@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {
    
    private final BookService bookService;
    
    @GetMapping
    public ResponseEntity<Page<BookResponse>> getBooks(
        @PageableDefault(size = 20, sort = "createdDate", direction = DESC) Pageable pageable
    ) {
        Page<BookResponse> books = bookService.getBooks(pageable);
        return ResponseEntity.ok(books);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<BookResponse> getBook(@PathVariable Long id) {
        BookResponse book = bookService.getBook(id);
        return ResponseEntity.ok(book);
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookResponse> createBook(@Valid @RequestBody BookRequest request) {
        BookResponse created = bookService.createBook(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
```

## 배포

### JAR 빌드

```bash
./mvnw clean package -DskipTests
```

### Docker 이미지 빌드

```bash
docker build -t luminari-backend .
docker run -p 8080:8080 luminari-backend
```

### 프로파일별 실행

```bash
# 개발 환경
java -jar -Dspring.profiles.active=dev target/luminari-0.0.1-SNAPSHOT.jar

# 프로덕션 환경
java -jar -Dspring.profiles.active=prod target/luminari-0.0.1-SNAPSHOT.jar
```

## 트러블슈팅

### 데이터베이스 연결 오류
- MySQL 서버가 실행 중인지 확인
- application.yml의 데이터베이스 설정 확인
- 방화벽 설정 확인

### 포트 충돌
```yaml
# application.yml
server:
  port: 8081  # 다른 포트로 변경
```

### 빌드 오류
```bash
# Maven 캐시 삭제
./mvnw clean
rm -rf ~/.m2/repository

# 다시 빌드
./mvnw clean install
```

## 참고 문서

- [Spring Boot 공식 문서](https://spring.io/projects/spring-boot)
- [Spring Data JPA 공식 문서](https://spring.io/projects/spring-data-jpa)
- [Spring Security 공식 문서](https://spring.io/projects/spring-security)
- [SpringDoc OpenAPI](https://springdoc.org/)

---

**작성일**: 2025-11-19  
**버전**: 1.0  
**프로젝트**: Luminari Bookstore
