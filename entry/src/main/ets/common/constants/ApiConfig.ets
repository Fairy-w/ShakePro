import { API_BASE_URL, OSS_PUBLIC_BASE_URL } from '../../core/env/AppEnv';

export const DEFAULT_HEADERS: Record<string, string> = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};

export const AUTH_REGISTER_PATH: string = '/api/auth/register';
export const AUTH_LOGIN_PATH: string = '/api/auth/login';
export const AUTH_ME_PATH: string = '/api/me';
export const AI_GENERATE_RECIPE_PATH: string = '/api/ai/generate-recipe';
export const AI_GENERATE_RECIPE_BY_TEXT_PATH: string = '/api/ai/generate-recipe-by-text';
export const COCKTAILS_PATH: string = '/api/cocktails';
export const OSS_PRESIGN_PATH: string = '/api/oss/presign';
export const FILES_PATH: string = '/api/files';
export const FAVORITES_PATH: string = '/api/favorites';
export const FAVORITE_AI_COCKTAILS_PATH: string = '/api/favorites/ai-cocktails';
export const FAVORITE_AI_COCKTAIL_STATUS_PATH: string = '/api/favorites/ai-cocktails/status';
export const BARCODE_LOOKUP_PATH: string = '/api/barcodes/lookup';
export const MATERIALS_PATH: string = '/api/materials';
export const MATERIAL_CATEGORIES_PATH: string = '/api/materials/categories';
export const USER_MATERIALS_PATH: string = '/api/user-materials';
export const USER_MATERIALS_MANUAL_PATH: string = '/api/user-materials/manual';
export const USER_MATERIALS_MANUAL_BATCH_PATH: string = '/api/user-materials/manual/batch';
export const COMMUNITY_POSTS_PATH: string = '/api/community/posts';
export const COMMUNITY_MY_POSTS_PATH: string = '/api/community/my/posts';
export const COMMUNITY_UPLOAD_IMAGE_PATH: string = '/api/community/upload/image';
export const RECOMMEND_COCKTAILS_PATH: string = '/api/recommend/cocktails';

export function isAbsoluteUrl(path: string): boolean {
  return path.startsWith('http://') || path.startsWith('https://') || path.startsWith('//');
}

export function normalizeAbsoluteUrl(path: string): string {
  if (path.startsWith('//')) {
    return `https:${path}`;
  }
  return path;
}

export function buildApiUrl(path: string): string {
  if (isAbsoluteUrl(path)) {
    return normalizeAbsoluteUrl(path);
  }
  return `${API_BASE_URL}${path}`;
}

export function buildApiUrlWithBase(baseUrl: string, path: string): string {
  if (isAbsoluteUrl(path)) {
    return normalizeAbsoluteUrl(path);
  }
  return `${baseUrl}${path}`;
}

export function buildPublicAssetUrl(path: string): string {
  const trimmedPath = path.trim();
  if (trimmedPath.length === 0) {
    return trimmedPath;
  }

  if (isAbsoluteUrl(trimmedPath)) {
    return normalizeAbsoluteUrl(trimmedPath);
  }

  if (trimmedPath.startsWith('/')) {
    return buildApiUrl(trimmedPath);
  }

  if (OSS_PUBLIC_BASE_URL.length > 0) {
    const normalizedBase = OSS_PUBLIC_BASE_URL.endsWith('/') ? OSS_PUBLIC_BASE_URL.slice(0, -1) : OSS_PUBLIC_BASE_URL;
    const normalizedPath = trimmedPath.startsWith('/') ? trimmedPath.slice(1) : trimmedPath;
    return `${normalizedBase}/${normalizedPath}`;
  }

  return trimmedPath;
}
