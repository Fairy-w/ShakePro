import { MaterialDraft, SelectableMaterial } from './BartendingStationMockData';

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
}

export interface BarcodeLookupResponse {
  id?: number | null;
  barcode: string;
  materialId?: number | null;
  name?: string | null;
  brand?: string | null;
  categoryId?: string | null;
  source?: string | null;
  capacityText?: string | null;
  remainLevel?: string | null;
  opened?: boolean | null;
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
  capacityText?: string | null;
  remainLevel?: string | null;
  opened: boolean;
  hasItem: boolean;
  tags: string[];
}

export interface SaveManualUserMaterialRequest {
  materialId: number;
  source?: string | null;
  brand?: string | null;
  categoryId?: string | null;
  capacityText?: string | null;
  remainLevel?: string | null;
  opened: boolean;
  hasItem: boolean;
  tags: string[];
}

export interface SaveManualUserMaterialBatchItem {
  materialId: number;
  hasItem: boolean;
  remainLevel?: string | null;
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

const DEFAULT_REMAIN_LEVEL: string = 'full';
const DISPLAY_REMAIN_LEVEL_FULL: string = '满瓶';
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
    normalizedValue === '糖浆') {
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
  if (categoryId === 'fruit' || categoryId === 'glassware') {
    return hasItem ? '已记录为有，可随时调整。' : '已记录为没有，当前不会参与推荐。';
  }

  if (source === 'scan') {
    return '已识别基础信息，可直接加入材料台。';
  }

  return '已从基础材料库选择，可继续补充库存信息。';
}

export function toDisplayRemainLevel(remainLevel: string | null | undefined): string {
  const normalizedRemainLevel = normalizeString(remainLevel, DEFAULT_REMAIN_LEVEL);
  if (normalizedRemainLevel === DEFAULT_REMAIN_LEVEL) {
    return DISPLAY_REMAIN_LEVEL_FULL;
  }
  return normalizedRemainLevel;
}

export function toApiRemainLevel(remainLevel: string | null | undefined): string {
  const normalizedRemainLevel = normalizeString(remainLevel, DEFAULT_REMAIN_LEVEL);
  if (normalizedRemainLevel === DISPLAY_REMAIN_LEVEL_FULL) {
    return DEFAULT_REMAIN_LEVEL;
  }
  return normalizedRemainLevel;
}

export function toMaterialDraft(dto: BarcodeLookupResponse | UserMaterialResponse): MaterialDraft {
  const categoryId = normalizeCategoryId(dto.categoryId);
  const visualMeta = getMaterialVisualMeta(categoryId);
  const source = normalizeString(dto.source, 'scan') === 'scan' ? 'scan' : 'manual';
  const hasItem = dto.hasItem !== false;

  return {
    id: buildDraftId(dto),
    source,
    sourceLabel: buildSourceLabel(source),
    name: normalizeString(dto.name, DEFAULT_NAME),
    subtitle: buildDraftSubtitle(source, visualMeta.categoryId, hasItem),
    brand: normalizeString(dto.brand, source === 'scan' ? '未识别品牌' : '未填写'),
    categoryId: visualMeta.categoryId,
    barcode: normalizeBarcode(dto.barcode),
    materialId: typeof dto.materialId === 'number' ? dto.materialId : undefined,
    capacityText: normalizeString(dto.capacityText, ''),
    remainLevel: toDisplayRemainLevel(dto.remainLevel),
    opened: dto.opened === true,
    hasItem,
    tags: normalizeTags(dto.tags),
    note: '',
    badge: visualMeta.badge,
    accentColor: visualMeta.accentColor,
    softColor: visualMeta.softColor
  };
}

function buildSelectableSubtitle(categoryId: string): string {
  if (categoryId === 'fruit') {
    return '高频鲜果材料，适合快速记录有无。';
  }
  if (categoryId === 'glassware') {
    return '补齐杯具后，出杯推荐会更准确。';
  }
  if (categoryId === 'mixer') {
    return '常见软饮或糖浆，建议先加入再补充库存。';
  }
  if (categoryId === 'liqueur') {
    return '风味酒会直接影响推荐结果。';
  }
  return '常用基础材料，可直接加入材料台。';
}

function buildSelectableQuickNote(categoryId: string): string {
  if (categoryId === 'fruit' || categoryId === 'glassware') {
    return '支持只记录有无状态。';
  }
  return '加入后可继续补充容量和剩余量。';
}

export function toSelectableMaterial(dto: MaterialResponse): SelectableMaterial {
  const categoryId = normalizeCategoryId(dto.category);
  const visualMeta = getMaterialVisualMeta(categoryId);

  return {
    id: `material-${dto.id.toString()}`,
    materialId: dto.id,
    name: normalizeString(dto.name, DEFAULT_NAME),
    subtitle: buildSelectableSubtitle(categoryId),
    categoryId: visualMeta.categoryId,
    categoryName: normalizeString(dto.category, visualMeta.categoryName),
    quickNote: buildSelectableQuickNote(categoryId),
    badge: visualMeta.badge,
    accentColor: visualMeta.accentColor,
    softColor: visualMeta.softColor,
    tags: [],
    isCommon: false,
    isRecent: false,
    isRecommended: false
  };
}
