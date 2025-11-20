# 🌟 Luminari Bookstore

온라인 서점 플랫폼 - 독서를 사랑하는 사람들을 위한 커뮤니티 기반 서점

## 📋 프로젝트 개요

Luminari Bookstore는 단순한 도서 판매를 넘어 독서 커뮤니티를 형성하고 게이미피케이션 요소를 통해 독서 활동을 장려하는 혁신적인 온라인 서점입니다.

### 주요 기능

- 📚 **도서 관리**: 다양한 카테고리의 도서 검색, 조회, 구매
- 👤 **회원 시스템**: 회원가입, 로그인, 프로필 관리
- 🛒 **장바구니 & 주문**: 장바구니 관리 및 주문/결제 처리
- ⭐ **리뷰 시스템**: 도서 리뷰 작성 및 사진 첨부
- 📖 **개인 서재**: 구매한 도서 관리 및 독서 진행률 추적
- 🎮 **게이미피케이션**: 레벨, RXP(Reader Experience Points), 업적 시스템
- 👥 **독서 모임**: 독서 토론 및 커뮤니티 활동
- 💰 **포인트 & 쿠폰**: 리워드 시스템 및 할인 혜택

## 🏗️ 프로젝트 구조 (Monorepo)

```
luminari-bookstore/
├── backend/                    # Spring Boot 백엔드
│   ├── src/
│   │   ├── main/java/
│   │   └── test/java/
│   ├── pom.xml
│   └── README.md
│
├── frontend/                   # React + Vite 프론트엔드
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── types/
│   ├── package.json
│   └── README.md
│
├── database/                   # 데이터베이스 스크립트
│   ├── scripts/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_tables.sql
│   │   ├── 03_create_triggers.sql
│   │   ├── 04_create_procedures.sql
│   │   ├── 05_insert_initial_data.sql
│   │   └── 99_rollback.sql
│   ├── deploy.bat
│   └── README.md
│
├── docs/                       # 프로젝트 문서
│   ├── 1단계_요구사항_분석_상세.md
│   ├── 2단계_개념적_데이터_모델링.md
│   ├── 3단계_논리적_데이터_모델링.md
│   ├── 4단계_물리적_데이터_모델링.md
│   └── 프론트엔드_프로젝트_구조_결정.md
│
├── .gitignore
└── README.md                   # 이 파일
```

## 🛠️ 기술 스택

### Backend
- **Framework**: Spring Boot 3.x
- **Language**: Java 17
- **Database**: MySQL 8.0
- **ORM**: Spring Data JPA (Hibernate)
- **Security**: Spring Security + JWT
- **Build Tool**: Maven

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite 6
- **Language**: TypeScript 5
- **State Management**: Zustand
- **Routing**: React Router DOM
- **HTTP Client**: Axios

### Database
- **RDBMS**: MySQL 8.0
- **Tables**: 28개
- **Triggers**: 6개
- **Stored Procedures**: 2개

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions
- **Version Control**: Git

## 🚀 시작하기

### 사전 요구사항

- Java 17 이상
- Node.js 18 이상
- MySQL 8.0
- Maven 3.6 이상
- npm 또는 yarn

### 1. 저장소 클론

```bash
git clone https://github.com/space-cap/luminari-bookstore.git
cd luminari-bookstore
```

### 2. 데이터베이스 설정

#### 방법 1: 자동 배포 (Windows)
```bash
cd database
deploy.bat
```

#### 방법 2: 수동 배포
```bash
cd database
mysql -u root -p < scripts/01_create_database.sql
mysql -u root -p luminari_bookstore < scripts/02_create_tables.sql
mysql -u root -p luminari_bookstore < scripts/03_create_triggers.sql
mysql -u root -p luminari_bookstore < scripts/04_create_procedures.sql
mysql -u root -p luminari_bookstore < scripts/05_insert_initial_data.sql
```

### 3. 백엔드 실행

```bash
cd backend
./mvnw spring-boot:run
```

백엔드 서버: http://localhost:8080

### 4. 프론트엔드 실행

```bash
cd frontend
npm install
npm run dev
```

프론트엔드 서버: http://localhost:3000

### 5. Docker Compose로 전체 환경 실행 (선택)

```bash
# docker-compose.yml 작성 후
docker-compose up -d
```

## 📚 API 문서

### Swagger UI
백엔드 실행 후: http://localhost:8080/swagger-ui.html

### 주요 API 엔드포인트

| 카테고리 | Method | 경로 | 설명 |
|:--------|:-------|:-----|:-----|
| 인증 | POST | /api/auth/register | 회원가입 |
| 인증 | POST | /api/auth/login | 로그인 |
| 도서 | GET | /api/books | 도서 목록 |
| 도서 | GET | /api/books/{id} | 도서 상세 |
| 장바구니 | GET | /api/cart | 장바구니 조회 |
| 장바구니 | POST | /api/cart/items | 장바구니 추가 |
| 주문 | POST | /api/orders | 주문 생성 |
| 리뷰 | POST | /api/books/{id}/reviews | 리뷰 작성 |

전체 API 문서는 [API 명세서](docs/api/) 참조

## 📊 데이터베이스 스키마

### 주요 테이블 (28개)

- **member**: 회원 정보
- **book**: 도서 정보
- **orders**: 주문 정보
- **review**: 리뷰 정보
- **cart**: 장바구니
- **bookshelf**: 개인 서재
- **book_club**: 독서 모임
- **achievement**: 업적 시스템

상세 ERD는 [데이터 모델링 문서](docs/2단계_개념적_데이터_모델링.md) 참조

## 🧪 테스트

### 백엔드 테스트
```bash
cd backend
./mvnw test
```

### 프론트엔드 테스트
```bash
cd frontend
npm run test
```

## 📦 빌드 & 배포

### 백엔드 빌드
```bash
cd backend
./mvnw clean package
```

### 프론트엔드 빌드
```bash
cd frontend
npm run build
```

### Docker 이미지 빌드
```bash
# 백엔드
cd backend
docker build -t luminari-backend .

# 프론트엔드
cd frontend
docker build -t luminari-frontend .
```

## 📖 문서

- [요구사항 분석](docs/1단계_요구사항_분석_상세.md)
- [개념적 데이터 모델링](docs/2단계_개념적_데이터_모델링.md)
- [논리적 데이터 모델링](docs/3단계_논리적_데이터_모델링.md)
- [물리적 데이터 모델링](docs/4단계_물리적_데이터_모델링.md)
- [프론트엔드 구조 결정](docs/프론트엔드_프로젝트_구조_결정.md)
- [백엔드 개발 가이드](backend/README.md)
- [프론트엔드 개발 가이드](frontend/README.md)
- [데이터베이스 설정 가이드](database/README.md)

## 🤝 기여 가이드

### 브랜치 전략

- `main`: 프로덕션 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

### 커밋 컨벤션

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 코드
chore: 빌드 설정 등
```

## 📝 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 👥 팀

- **프로젝트 관리**: space-cap
- **백엔드 개발**: space-cap
- **프론트엔드 개발**: space-cap
- **데이터베이스 설계**: space-cap

## 📞 문의

- **이슈 등록**: [GitHub Issues](https://github.com/space-cap/luminari-bookstore/issues)
- **이메일**: [문의하기](mailto:your-email@example.com)

---

**프로젝트 시작일**: 2025-11-19  
**버전**: 1.0.0  
**상태**: 🚧 개발 중

Made with ❤️ by space-cap
