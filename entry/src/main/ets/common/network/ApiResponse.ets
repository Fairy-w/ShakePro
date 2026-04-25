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

const TECHNICAL_MESSAGE_TOKENS: string[] = [
  '[object object]',
  'exception',
  'stack',
  'traceid',
  'http',
  'sql',
  'nullpointer',
  'undefined',
  'timeout',
  'network request failed',
  'econn',
  'enotfound',
  'failed to connect',
  'code='
];

function includesTechnicalToken(message: string): boolean {
  const normalized = message.toLowerCase();
  if (/^[A-Z0-9_-]{5,}$/.test(message)) {
    return true;
  }
  if (/(code|status)\s*[:=]/i.test(message)) {
    return true;
  }
  for (let index: number = 0; index < TECHNICAL_MESSAGE_TOKENS.length; index += 1) {
    if (normalized.indexOf(TECHNICAL_MESSAGE_TOKENS[index]) !== -1) {
      return true;
    }
  }
  return false;
}

export function toUserFacingMessage(message: string | null | undefined, fallback: string): string {
  const normalizedMessage = typeof message === 'string' ? message.trim() : '';
  if (normalizedMessage.length === 0) {
    return fallback;
  }
  if (includesTechnicalToken(normalizedMessage)) {
    return fallback;
  }
  return normalizedMessage;
}

export function isApiSuccess<T>(response: ApiResponse<T>): boolean {
  return response.code === 0 || response.code === 200;
}

export function getApiMessage<T>(response: ApiResponse<T>, fallback: string = '请求失败'): string {
  return toUserFacingMessage(response.message, fallback);
}
