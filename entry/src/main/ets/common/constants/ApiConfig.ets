export const API_BASE_URL: string = 'http://172.20.10.3:8080';
export const API_TIMEOUT_MS: number = 10000;
export const API_FALLBACK_TIMEOUT_MS: number = 2500;
export const API_MAX_RETRY_COUNT: number = 0;
export const API_BASE_URL_CANDIDATES: string[] = [
  API_BASE_URL,
  'http://api.shakepro.local:8080'
];

export const DEFAULT_HEADERS: Record<string, string> = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};

export const AUTH_REGISTER_PATH: string = '/api/auth/register';
export const AUTH_LOGIN_PATH: string = '/api/auth/login';
export const AUTH_ME_PATH: string = '/api/me';
export const AI_GENERATE_RECIPE_PATH: string = '/api/ai/generate-recipe';
export const AI_GENERATE_RECIPE_BY_TEXT_PATH: string = '/api/ai/generate-recipe-by-text';
export const FAVORITE_AI_COCKTAILS_PATH: string = '/api/favorites/ai-cocktails';
export const FAVORITE_AI_COCKTAIL_STATUS_PATH: string = '/api/favorites/ai-cocktails/status';

export function isAbsoluteUrl(path: string): boolean {
  return path.startsWith('http://') || path.startsWith('https://');
}

export function buildApiUrl(path: string): string {
  if (isAbsoluteUrl(path)) {
    return path;
  }
  return `${API_BASE_URL}${path}`;
}

export function buildApiUrlWithBase(baseUrl: string, path: string): string {
  if (isAbsoluteUrl(path)) {
    return path;
  }
  return `${baseUrl}${path}`;
}
