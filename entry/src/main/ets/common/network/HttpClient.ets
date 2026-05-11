import axios from '@ohos/axios';
import {
  API_FALLBACK_TIMEOUT_MS,
  API_MAX_RETRY_COUNT,
  API_TIMEOUT_MS,
  API_BASE_URL_CANDIDATES
} from '../../core/env/AppEnv';
import {
  DEFAULT_HEADERS,
  buildApiUrl,
  buildApiUrlWithBase,
  isAbsoluteUrl
} from '../constants/ApiConfig';
import { AppLogger } from '../../core/logging/AppLogger';
import { ApiResponse, HttpRequestError, HttpErrorPayload, toUserFacingMessage } from './ApiResponse';
import { sessionStore } from '../storage/SessionStore';

export interface HttpRequestOptions {
  headers?: Record<string, string>;
  query?: Record<string, string | number | boolean | undefined | null>;
  data?: string | Object;
  timeoutMs?: number;
  attachToken?: boolean;
  skipAuthorization?: boolean;
}

interface RequestTarget {
  baseUrl?: string;
  url: string;
}

interface AxiosHttpResponse {
  status: number;
  data: string | Object;
}
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';


const HTTP_LOG_TAG: string = 'ShakeProHttp';

class HttpClient {
  async get<T>(path: string, options: HttpRequestOptions = {}): Promise<ApiResponse<T>> {
    return this.request<T>(path, 'GET', options);
  }

  async post<T>(path: string, options: HttpRequestOptions = {}): Promise<ApiResponse<T>> {
    return this.request<T>(path, 'POST', options);
  }

  async put<T>(path: string, options: HttpRequestOptions = {}): Promise<ApiResponse<T>> {
    return this.request<T>(path, 'PUT', options);
  }

  async delete<T>(path: string, options: HttpRequestOptions = {}): Promise<ApiResponse<T>> {
    return this.request<T>(path, 'DELETE', options);
  }

  async request<T>(path: string, method: HttpMethod, options: HttpRequestOptions = {}): Promise<ApiResponse<T>> {
    const requestBody = this.buildBody(options.data);
    const headers = await this.buildHeaders(options);
    const timeoutMs = options.timeoutMs ?? API_TIMEOUT_MS;
    const targets = await this.buildRequestTargets(path, options.query);
    const attemptCount = Math.min(targets.length, API_MAX_RETRY_COUNT + 1);

    let lastError: Object | undefined = undefined;

    for (let attempt: number = 0; attempt < attemptCount; attempt++) {
      const target = targets[attempt];
      const attemptTimeout = attempt === 0 ? timeoutMs : Math.min(timeoutMs, API_FALLBACK_TIMEOUT_MS);

      try {
        AppLogger.info(
          HTTP_LOG_TAG,
          'request start method=%{public}s path=%{public}s url=%{public}s attachToken=%{public}s skipAuthorization=%{public}s attempt=%{public}d headers=%{public}s body=%{public}s',
          method,
          path,
          target.url,
          String(options.attachToken === true),
          String(options.skipAuthorization === true),
          attempt + 1,
          JSON.stringify(headers),
          this.sanitizePayload(requestBody)
        );
        const response: AxiosHttpResponse = await axios.request({
          url: target.url,
          method,
          headers,
          timeout: attemptTimeout,
          data: requestBody,
          validateStatus: (status: number): boolean => true
        }) as AxiosHttpResponse;

        AppLogger.info(
          HTTP_LOG_TAG,
          'request done method=%{public}s path=%{public}s status=%{public}d raw=%{public}s',
          method,
          path,
          response.status,
          this.sanitizePayload(response.data)
        );

        if (target.baseUrl) {
          await this.storePreferredBaseUrl(target.baseUrl);
        }

        const body = this.parseBody<ApiResponse<T>>(response.data);
        if (body && typeof body === 'object') {
          const apiResponse = body as ApiResponse<T>;
          if (apiResponse.code !== undefined && apiResponse.message !== undefined) {
            AppLogger.info(
              HTTP_LOG_TAG,
              'api response path=%{public}s code=%{public}d message=%{public}s traceId=%{public}s',
              path,
              apiResponse.code,
              apiResponse.message ?? '',
              apiResponse.traceId ?? ''
            );
            return body;
          }
        }

        return {
          code: response.status,
          message: 'OK',
          data: body as T
        } as ApiResponse<T>;
      } catch (error) {
        lastError = error as Object;
        AppLogger.error(
          HTTP_LOG_TAG,
          'request failed method=%{public}s path=%{public}s url=%{public}s attempt=%{public}d error=%{public}s',
          method,
          path,
          target.url,
          attempt + 1,
          this.stringifyUnknown(error as Object)
        );

        if (!this.shouldRetry(path, error as Object, attempt, attemptCount)) {
          throw this.normalizeError(error as Object);
        }

        AppLogger.warn(
          HTTP_LOG_TAG,
          'switch backend and retry path=%{public}s nextAttempt=%{public}d',
          path,
          attempt + 2
        );
      }
    }

    throw this.normalizeError(lastError ?? new Error('Network request failed'));
  }

  private async buildRequestTargets(path: string,
    query?: Record<string, string | number | boolean | undefined | null>): Promise<RequestTarget[]> {
    if (isAbsoluteUrl(path)) {
      return [{ url: this.buildUrl(path, query) } as RequestTarget];
    }

    const querySuffix = this.buildQuerySuffix(query);
    const baseUrls = await this.loadCandidateBaseUrls();
    return baseUrls.map((baseUrl: string) => {
      return {
        baseUrl,
        url: `${buildApiUrlWithBase(baseUrl, path)}${querySuffix}`
      } as RequestTarget;
    });
  }

  private async loadCandidateBaseUrls(): Promise<string[]> {
    return API_BASE_URL_CANDIDATES;
  }

  private buildUrl(path: string, query?: Record<string, string | number | boolean | undefined | null>): string {
    return `${buildApiUrl(path)}${this.buildQuerySuffix(query)}`;
  }

  private buildQuerySuffix(query?: Record<string, string | number | boolean | undefined | null>): string {
    if (!query) {
      return '';
    }

    const queryItems: string[] = [];
    Object.keys(query).forEach((key: string) => {
      const value = query[key];
      if (value === undefined || value === null || value === '') {
        return;
      }
      queryItems.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
    });

    if (queryItems.length === 0) {
      return '';
    }

    return `?${queryItems.join('&')}`;
  }

  private async buildHeaders(options: HttpRequestOptions): Promise<Record<string, string>> {
    const headers: Record<string, string> = {};

    if (DEFAULT_HEADERS) {
      Object.keys(DEFAULT_HEADERS).forEach(key => {
        headers[key] = DEFAULT_HEADERS[key];
      });
    }

    if (options.headers) {
      Object.keys(options.headers).forEach(key => {
        headers[key] = options.headers![key];
      });
    }

    if (options.skipAuthorization) {
      const filteredHeaders: Record<string, string> = {};
      Object.keys(headers).forEach(key => {
        if (key.toLowerCase() !== 'authorization') {
          filteredHeaders[key] = headers[key];
        }
      });
      return filteredHeaders;
    }

    if (options.attachToken) {
      const authorization = await sessionStore.getAuthorizationValue();
      if (authorization) {
        headers['Authorization'] = authorization;
      }
    }

    return headers;
  }

  private buildBody(data?: string | Object): string | Object | undefined {
    if (data === undefined) {
      return undefined;
    }
    if (typeof data === 'string') {
      return data;
    }
    return data;
  }

  private parseBody<T>(result: string | Object): T {
    if (typeof result !== 'string') {
      return result as T;
    }

    const trimmed = result.trim();
    if (trimmed.length === 0) {
      return null as T;
    }

    try {
      return JSON.parse(trimmed) as T;
    } catch (_error) {
      return trimmed as T;
    }
  }

  private normalizeError(error: Object): HttpRequestError {
    if (error instanceof HttpRequestError) {
      return error;
    }

    const maybeError = error as Record<string, Object>;
    const responseObj = maybeError['response'] as Record<string, Object> | undefined;
    const statusCode = this.readNumber(responseObj, 'status');
    const responseData = responseObj ? responseObj['data'] : undefined;
    const parsed = this.parseBody<HttpErrorPayload | Record<string, Object>>(responseData as string | Object);

    let message = this.extractString(parsed as Record<string, Object>, 'message');
    if (!message) {
      message = typeof maybeError['message'] === 'string' ? maybeError['message'] as string : '';
    }
    message = toUserFacingMessage(message, '网络异常，请稍后重试');

    const errorPayload: HttpErrorPayload = {
      message,
      statusCode,
      code: this.extractNumber(parsed as Record<string, Object>, 'code'),
      traceId: this.extractString(parsed as Record<string, Object>, 'traceId')
    };

    return new HttpRequestError(errorPayload);
  }

  private shouldRetry(path: string, error: Object, attempt: number, totalAttempts: number): boolean {
    if (isAbsoluteUrl(path)) {
      return false;
    }
    if (attempt >= totalAttempts - 1) {
      return false;
    }
    return this.isConnectivityError(error);
  }

  private isConnectivityError(error: Object): boolean {
    const content = this.stringifyUnknown(error).toLowerCase();
    const signals: string[] = [
      'curlcode result 28',
      'timed out',
      'timeout',
      'failed to connect',
      'connection refused',
      'could not resolve host',
      'name or service not known',
      'network is unreachable',
      'epoll wait event',
      'econnaborted',
      'enotfound',
      'network error'
    ];

    return signals.some((signal: string) => content.includes(signal));
  }

  private async getPreferredBaseUrl(): Promise<string> {
    if (!sessionStore.isInitialized()) {
      return '';
    }

    try {
      return await sessionStore.getApiBaseUrl();
    } catch (_error) {
      return '';
    }
  }

  private async storePreferredBaseUrl(baseUrl: string): Promise<void> {
    if (!sessionStore.isInitialized()) {
      return;
    }

    const current = await this.getPreferredBaseUrl();
    if (current === baseUrl) {
      return;
    }

    try {
      await sessionStore.setApiBaseUrl(baseUrl);
    } catch (_error) {
      AppLogger.warn(HTTP_LOG_TAG, 'store preferred base url failed baseUrl=%{public}s', baseUrl);
    }
  }

  private sanitizePayload(payload: string | Object | undefined): string {
    if (payload === undefined) {
      return '';
    }

    const text = typeof payload === 'string' ? payload : JSON.stringify(payload);
    return text
      .replace(/"password":"[^"]*"/g, '"password":"***"')
      .replace(/"token":"[^"]*"/g, '"token":"***"')
      .slice(0, 800);
  }

  private stringifyUnknown(value: Object): string {
    try {
      return JSON.stringify(value);
    } catch (_error) {
      return `${value}`;
    }
  }

  private extractString(source: Record<string, Object> | undefined, key: string): string | undefined {
    if (!source) {
      return undefined;
    }
    const value = source[key];
    if (typeof value === 'string' && value.trim().length > 0) {
      return value;
    }
    return undefined;
  }

  private extractNumber(source: Record<string, Object> | undefined, key: string): number | undefined {
    if (!source) {
      return undefined;
    }
    const value = source[key];
    if (typeof value === 'number') {
      return value;
    }
    return undefined;
  }

  private readNumber(source: Record<string, Object> | undefined, key: string): number | undefined {
    if (!source) {
      return undefined;
    }
    const value = source[key];
    if (typeof value === 'number') {
      return value;
    }
    return undefined;
  }
}

export const httpClient: HttpClient = new HttpClient();

