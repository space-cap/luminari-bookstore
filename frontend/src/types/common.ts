/**
 * 공통 타입 정의
 */

// 공통 엔티티 기본 필드
export interface BaseEntity {
  createdDate?: string;
  updatedDate?: string;
}

// 페이지네이션 파라미터
export interface PageParams {
  page?: number;
  size?: number;
  sort?: string;
}

// 검색 파라미터
export interface SearchParams extends PageParams {
  keyword?: string;
}

// 에러 응답
export interface ErrorResponse {
  message: string;
  status: number;
  timestamp: string;
  path?: string;
}
