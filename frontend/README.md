# Luminari Bookstore - Frontend

## 기술 스택

- **Framework**: React 18
- **Build Tool**: Vite 6
- **Language**: TypeScript 5
- **State Management**: Zustand
- **Routing**: React Router DOM
- **HTTP Client**: Axios
- **Styling**: CSS Modules (또는 추후 Tailwind CSS / Styled Components)

## 디렉토리 구조

```
frontend/
├── public/                         # 정적 파일
│   └── images/                     # 이미지 리소스
├── src/
│   ├── assets/                     # 에셋 (이미지, 폰트 등)
│   ├── components/                 # 컴포넌트
│   │   ├── common/                 # 공통 컴포넌트 (Button, Input 등)
│   │   ├── layout/                 # 레이아웃 (Header, Footer, Sidebar)
│   │   ├── book/                   # 도서 관련 컴포넌트
│   │   ├── member/                 # 회원 관련 컴포넌트
│   │   ├── order/                  # 주문 관련 컴포넌트
│   │   └── community/              # 커뮤니티 관련 컴포넌트
│   ├── pages/                      # 페이지 컴포넌트
│   │   ├── Home.tsx
│   │   ├── BookDetail.tsx
│   │   ├── Cart.tsx
│   │   ├── Order.tsx
│   │   ├── MyPage.tsx
│   │   └── Admin/                  # 관리자 페이지
│   ├── hooks/                      # Custom Hooks
│   ├── services/                   # API 서비스
│   │   ├── api.ts                  # Axios 설정
│   │   ├── bookService.ts          # 도서 API
│   │   ├── memberService.ts        # 회원 API
│   │   ├── orderService.ts         # 주문 API
│   │   └── reviewService.ts        # 리뷰 API
│   ├── stores/                     # 전역 상태 관리
│   ├── types/                      # TypeScript 타입 정의
│   │   ├── common.ts               # 공통 타입
│   │   ├── book.ts
│   │   ├── member.ts
│   │   └── order.ts
│   ├── utils/                      # 유틸리티 함수
│   ├── styles/                     # 글로벌 스타일
│   ├── App.tsx
│   ├── main.tsx
│   └── router.tsx                  # 라우터 설정
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 시작하기

### 1. 의존성 설치

```bash
npm install
```

### 2. 개발 서버 실행

```bash
npm run dev
```

서버가 실행되면 http://localhost:3000 에서 확인할 수 있습니다.

### 3. 빌드

```bash
npm run build
```

빌드 결과물은 `dist/` 디렉토리에 생성됩니다.

### 4. 프리뷰 (빌드 결과물 확인)

```bash
npm run preview
```

## 주요 기능

### API 프록시

개발 환경에서 백엔드 API는 자동으로 프록시됩니다:

- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8080`
- API 요청: `/api/*` → `http://localhost:8080/*`

### 경로 별칭 (Path Alias)

편리한 import를 위한 경로 별칭이 설정되어 있습니다:

```typescript
import Button from '@components/common/Button';
import { Book } from '@types/book';
import { useAuth } from '@hooks/useAuth';
import apiClient from '@services/api';
```

- `@/` → `src/`
- `@components/` → `src/components/`
- `@pages/` → `src/pages/`
- `@services/` → `src/services/`
- `@types/` → `src/types/`
- `@hooks/` → `src/hooks/`
- `@utils/` → `src/utils/`
- `@stores/` → `src/stores/`
- `@styles/` → `src/styles/`

## 개발 가이드

### API 호출 예시

```typescript
// src/services/bookService.ts
import apiClient, { ApiResponse, PageResponse } from './api';
import { Book } from '@types/book';

export const bookService = {
  // 도서 목록 조회
  getBooks: async (page: number = 0, size: number = 20) => {
    const response = await apiClient.get<PageResponse<Book>>('/books', {
      params: { page, size }
    });
    return response.data;
  },

  // 도서 상세 조회
  getBook: async (bookId: number) => {
    const response = await apiClient.get<ApiResponse<Book>>(`/books/${bookId}`);
    return response.data.data;
  },

  // 도서 검색
  searchBooks: async (keyword: string, page: number = 0) => {
    const response = await apiClient.get<PageResponse<Book>>('/books/search', {
      params: { keyword, page, size: 20 }
    });
    return response.data;
  }
};
```

### 컴포넌트 작성 예시

```typescript
// src/components/book/BookCard.tsx
import { Book } from '@types/book';

interface BookCardProps {
  book: Book;
  onClick?: (book: Book) => void;
}

export const BookCard: React.FC<BookCardProps> = ({ book, onClick }) => {
  return (
    <div className="book-card" onClick={() => onClick?.(book)}>
      <img src={book.coverImage} alt={book.title} />
      <h3>{book.title}</h3>
      <p>{book.author}</p>
      <span>{book.finalPrice.toLocaleString()}원</span>
    </div>
  );
};
```

### Custom Hook 예시

```typescript
// src/hooks/useBooks.ts
import { useState, useEffect } from 'react';
import { bookService } from '@services/bookService';
import { Book } from '@types/book';

export const useBooks = (page: number = 0) => {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchBooks = async () => {
      try {
        setLoading(true);
        const data = await bookService.getBooks(page);
        setBooks(data.content);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    fetchBooks();
  }, [page]);

  return { books, loading, error };
};
```

## 환경 변수

`.env` 파일을 생성하여 환경 변수를 설정할 수 있습니다:

```env
# .env.development
VITE_API_BASE_URL=http://localhost:8080

# .env.production
VITE_API_BASE_URL=https://api.luminari.com
```

## 스크립트

```json
{
  "dev": "vite",                    // 개발 서버 실행
  "build": "tsc && vite build",     // 프로덕션 빌드
  "preview": "vite preview",        // 빌드 결과물 미리보기
  "lint": "eslint . --ext ts,tsx"   // 코드 린트
}
```

## 배포

### Docker로 배포

```bash
# 이미지 빌드
docker build -t luminari-frontend .

# 컨테이너 실행
docker run -p 80:80 luminari-frontend
```

### Docker Compose로 전체 환경 실행

프로젝트 루트에서:

```bash
docker-compose up -d
```

## 주의사항

- `node_modules/`, `dist/`는 `.gitignore`에 포함되어 있습니다.
- API 요청 시 `/api` 프리픽스를 사용하세요 (자동으로 프록시됨).
- 타입 정의는 반드시 `@types/` 디렉토리에 작성하세요.
- 공통 컴포넌트는 `@components/common/`에 작성하세요.

## 트러블슈팅

### CORS 오류
- 개발 환경에서는 Vite 프록시가 자동으로 처리합니다.
- 프록시 설정은 `vite.config.ts`에서 확인하세요.

### 경로 별칭 오류
- `tsconfig.json`과 `vite.config.ts` 양쪽에 경로가 설정되어 있는지 확인하세요.

### 빌드 오류
```bash
# 캐시 삭제 후 재빌드
rm -rf node_modules dist
npm install
npm run build
```

## 참고 문서

- [Vite 공식 문서](https://vitejs.dev/)
- [React 공식 문서](https://react.dev/)
- [TypeScript 공식 문서](https://www.typescriptlang.org/)
- [React Router 공식 문서](https://reactrouter.com/)
- [Zustand 공식 문서](https://zustand-demo.pmnd.rs/)

---

**작성일**: 2025-11-19  
**버전**: 1.0  
**프로젝트**: Luminari Bookstore
