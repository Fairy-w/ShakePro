export interface ApiResponse<T> {
  code: number;
  message: string;
  data?: T;
  traceId?: string;
}

export interface HttpErrorPayload {
  message: string;
  statusCode?: number;
  code?: number;
  traceId?: string;
}

export class HttpRequestError extends Error {
  statusCode?: number;
  code?: number;
  traceId?: string;

  constructor(payload: HttpErrorPayload) {
    super(payload.message);
    this.name = 'HttpRequestError';
    this.statusCode = payload.statusCode;
    this.code = payload.code;
    this.traceId = payload.traceId;
  }
}

export function isApiSuccess<T>(response: ApiResponse<T>): boolean {
  return response.code === 0 || response.code === 200;
}

export function getApiMessage<T>(response: ApiResponse<T>, fallback: string = '请求失败'): string {
  if (response.message && response.message.trim().length > 0) {
    return response.message;
  }
  return fallback;
}
