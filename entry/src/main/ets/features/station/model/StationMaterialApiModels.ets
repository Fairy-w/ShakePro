import { MaterialDraft, SelectableMaterial } from './BartendingStationMockData';
import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';

export interface BarcodeLookupRequest {
  barcode: string;
  locale?: string;
}

export interface UserMaterialsQuery {
  keyword?: string;
  categoryId?: string;
}

export interface MaterialResponse {
  id: number;
  name: string;
  category?: string | null;
  nameEn?: string | null;
  imageUrl?: string | null;
  imageUrlThumb?: string | null;
  imageUrlCard?: string | null;
  imageUrlDetail?: string | null;
  source?: string | null;
  sourceId?: string | null;
  description?: string | null;
  subtitle?: string | null;
}

export interface BarcodeLookupResponse {
  id?: number | null;
  barcode: string;
  materialId?: number | null;
  name?: string | null;
  brand?: string | null;
  categoryId?: string | null;
  imageUrl?: string | null;
  imageUrlThumb?: string | null;
  imageUrlCard?: string | null;
  imageUrlDetail?: string | null;
  source?: string | null;
  hasItem?: boolean | null;
  tags?: string[] | null;
}

export interface UserMaterialResponse extends BarcodeLookupResponse {
  userId?: number | null;
  createdAt?: string | null;
  updatedAt?: string | null;
}

export interface SaveScannedUserMaterialRequest {
  barcode: string;
  materialId?: number | null;
  name?: string | null;
  brand?: string | null;
  categoryId?: string | null;
  source?: string | null;
  hasItem: boolean;
  tags: string[];
}

export interface SaveManualUserMaterialRequest {
  materialId: number;
  source?: string | null;
  brand?: string | null;
  categoryId?: string | null;
  hasItem: boolean;
  tags: string[];
}

export interface SaveManualUserMaterialBatchItem {
  materialId: number;
  hasItem: boolean;
}

export interface SaveManualUserMaterialsBatchRequest {
  items: SaveManualUserMaterialBatchItem[];
}

export interface MaterialVisualMeta {
  categoryId: string;
  categoryName: string;
  badge: string;
  accentColor: string;
  softColor: string;
}

interface ResolvedMaterialImageUrls {
  imageUrl?: string;
  imageUrlThumb?: string;
  imageUrlCard?: string;
  imageUrlDetail?: string;
}

const DEFAULT_NAME: string = '未命名材料';

export function normalizeString(value: string | null | undefined, fallback: string): string {
  if (typeof value !== 'string') {
    return fallback;
  }
  const trimmed: string = value.trim();
  if (trimmed.length === 0) {
    return fallback;
  }
  return trimmed;
}

export function toNullableText(value: string | null | undefined): string | null {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed: string = value.trim();
  if (trimmed.length === 0 || trimmed === '-') {
    return null;
  }
  return trimmed;
}

export function normalizeBarcode(value: string | null | undefined): string {
  if (typeof value !== 'string') {
    return '';
  }
  return value.replace(/[^0-9]/g, '');
}

export function normalizeTags(tags: string[] | null | undefined): string[] {
  if (!Array.isArray(tags)) {
    return [];
  }

  const normalizedTags: string[] = [];
  tags.forEach((tag: string) => {
    const normalizedTag = toNullableText(tag);
    if (normalizedTag !== null) {
      normalizedTags.push(normalizedTag);
    }
  });
  return normalizedTags;
}

export function normalizeCategoryId(value: string | null | undefined): string {
  const normalizedValue: string = normalizeString(value, '').toLowerCase();
  if (normalizedValue.length === 0) {
    return 'spirit';
  }

  if (normalizedValue === 'spirit' || normalizedValue === '基酒') {
    return 'spirit';
  }
  if (normalizedValue === 'liqueur' || normalizedValue === '风味酒' || normalizedValue === '利口酒') {
    return 'liqueur';
  }
  if (normalizedValue === 'mixer' || normalizedValue === '软饮 / 糖浆' || normalizedValue === '软饮' ||
    normalizedValue === '糖浆' || normalizedValue === '果汁' || normalizedValue === '辅料') {
    return 'mixer';
  }
  if (normalizedValue === 'fruit' || normalizedValue === '水果' || normalizedValue === '装饰') {
    return 'fruit';
  }
  if (normalizedValue === 'glassware' || normalizedValue === '杯具' || normalizedValue === '工具') {
    return 'glassware';
  }
  return normalizedValue;
}

export function getMaterialVisualMeta(categoryId: string): MaterialVisualMeta {
  const normalizedCategoryId = normalizeCategoryId(categoryId);
  if (normalizedCategoryId === 'liqueur') {
    return {
      categoryId: 'liqueur',
      categoryName: '风味酒',
      badge: 'LQ',
      accentColor: '#A66A1C',
      softColor: '#F8E9CF'
    };
  }
  if (normalizedCategoryId === 'mixer') {
    return {
      categoryId: 'mixer',
      categoryName: '软饮 / 糖浆',
      badge: 'MX',
      accentColor: '#245C82',
      softColor: '#E8F5FB'
    };
  }
  if (normalizedCategoryId === 'fruit') {
    return {
      categoryId: 'fruit',
      categoryName: '水果',
      badge: 'FR',
      accentColor: '#2B6C63',
      softColor: '#DDF5F1'
    };
  }
  if (normalizedCategoryId === 'glassware') {
    return {
      categoryId: 'glassware',
      categoryName: '杯具',
      badge: 'GW',
      accentColor: '#3F5D75',
      softColor: '#EAF1F6'
    };
  }
  return {
    categoryId: 'spirit',
    categoryName: '基酒',
    badge: 'SP',
    accentColor: '#1B596E',
    softColor: '#DDF5F1'
  };
}

function buildDraftId(dto: BarcodeLookupResponse | UserMaterialResponse): string {
  if (typeof dto.id === 'number' && dto.id > 0) {
    return dto.id.toString();
  }

  const normalizedBarcode = normalizeBarcode(dto.barcode);
  if (normalizedBarcode.length > 0) {
    return normalizedBarcode;
  }

  if (typeof dto.materialId === 'number' && dto.materialId > 0) {
    return `material-${dto.materialId.toString()}`;
  }

  return 'new-material';
}

function buildSourceLabel(source: string): string {
  if (source === 'scan') {
    return '条码识别结果';
  }
  return '手动录入';
}

function buildDraftSubtitle(source: string, categoryId: string, hasItem: boolean): string {
  if (hasItem) {
    return source === 'scan'
      ? '已识别成功，你当前标记为有。'
      : '已从基础材料库加入，你当前标记为有。';
  }

  if (categoryId === 'fruit' || categoryId === 'glassware') {
    return '当前只记录有无状态，你标记为暂时没有。';
  }

  return '当前只记录有无状态，你标记为暂时没有。';
}

function pickAddedAt(dto: UserMaterialResponse | BarcodeLookupResponse): string | undefined {
  const userMaterialDto = dto as UserMaterialResponse;
  const updatedAt = toNullableText(userMaterialDto.updatedAt);
  if (updatedAt !== null) {
    return updatedAt;
  }
  const createdAt = toNullableText(userMaterialDto.createdAt);
  if (createdAt !== null) {
    return createdAt;
  }
  return undefined;
}

export function toMaterialDraft(dto: BarcodeLookupResponse | UserMaterialResponse): MaterialDraft {
  const categoryId = normalizeCategoryId(dto.categoryId);
  const visualMeta = getMaterialVisualMeta(categoryId);
  const source = normalizeString(dto.source, 'scan') === 'scan' ? 'scan' : 'manual';
  const hasItem = dto.hasItem !== false;
  const resolvedImageUrls = resolveMaterialImageUrls(dto);

  return {
    id: buildDraftId(dto),
    source,
    sourceLabel: buildSourceLabel(source),
    name: normalizeString(dto.name, DEFAULT_NAME),
    subtitle: buildDraftSubtitle(source, visualMeta.categoryId, hasItem),
    brand: normalizeString(dto.brand, source === 'scan' ? '未识别品牌' : '未填写'),
    categoryId: visualMeta.categoryId,
    imageUrl: resolvedImageUrls.imageUrl,
    imageUrlThumb: resolvedImageUrls.imageUrlThumb,
    imageUrlCard: resolvedImageUrls.imageUrlCard,
    imageUrlDetail: resolvedImageUrls.imageUrlDetail,
    barcode: normalizeBarcode(dto.barcode),
    addedAt: pickAddedAt(dto),
    materialId: typeof dto.materialId === 'number' ? dto.materialId : undefined,
    capacityText: '',
    remainLevel: '满瓶',
    opened: false,
    hasItem,
    tags: normalizeTags(dto.tags),
    note: '',
    badge: visualMeta.badge,
    accentColor: visualMeta.accentColor,
    softColor: visualMeta.softColor
  };
}

function pickFirstImageUrl(candidates: Array<string | undefined>): string | undefined {
  for (let index = 0; index < candidates.length; index += 1) {
    const candidate = candidates[index];
    if (typeof candidate === 'string' && candidate.trim().length > 0) {
      return candidate;
    }
  }
  return undefined;
}

function normalizeImageUrl(value: string | null | undefined): string | undefined {
  const normalizedValue = normalizeString(value, '');
  if (normalizedValue.length === 0) {
    return undefined;
  }
  return buildPublicAssetUrl(normalizedValue);
}

function resolveMaterialImageUrls(dto: MaterialResponse | BarcodeLookupResponse): ResolvedMaterialImageUrls {
  const rawImageUrl = normalizeImageUrl(dto.imageUrl);
  const rawImageUrlThumb = normalizeImageUrl(dto.imageUrlThumb);
  const rawImageUrlCard = normalizeImageUrl(dto.imageUrlCard);
  const rawImageUrlDetail = normalizeImageUrl(dto.imageUrlDetail);
  const imageUrl = pickFirstImageUrl([rawImageUrl, rawImageUrlCard, rawImageUrlThumb, rawImageUrlDetail]);
  const imageUrlThumb = pickFirstImageUrl([rawImageUrlThumb, rawImageUrlCard, imageUrl]);
  const imageUrlCard = pickFirstImageUrl([rawImageUrlCard, rawImageUrlThumb, imageUrl]);
  const imageUrlDetail = pickFirstImageUrl([rawImageUrlDetail, rawImageUrl, rawImageUrlCard, rawImageUrlThumb, imageUrl]);

  return {
    imageUrl,
    imageUrlThumb,
    imageUrlCard,
    imageUrlDetail
  };
}

function resolveMaterialDescription(dto: MaterialResponse): string {
  return normalizeString(dto.description, normalizeString(dto.subtitle, ''));
}

export function toSelectableMaterial(dto: MaterialResponse): SelectableMaterial {
  const categoryName = normalizeString(dto.category, '');
  const categoryId = categoryName.length > 0 ? normalizeCategoryId(categoryName) : 'other';
  const visualMeta = getMaterialVisualMeta(categoryId);
  const description = resolveMaterialDescription(dto);
  const resolvedImageUrls = resolveMaterialImageUrls(dto);

  return {
    id: `material-${dto.id.toString()}`,
    materialId: dto.id,
    name: normalizeString(dto.name, ''),
    imageUrl: resolvedImageUrls.imageUrl,
    imageUrlThumb: resolvedImageUrls.imageUrlThumb,
    imageUrlCard: resolvedImageUrls.imageUrlCard,
    imageUrlDetail: resolvedImageUrls.imageUrlDetail,
    description,
    subtitle: description,
    categoryId: visualMeta.categoryId,
    categoryName,
    quickNote: '',
    badge: visualMeta.badge,
    accentColor: visualMeta.accentColor,
    softColor: visualMeta.softColor,
    tags: [],
    isCommon: false,
    isRecent: false,
    isRecommended: false
  };
}
