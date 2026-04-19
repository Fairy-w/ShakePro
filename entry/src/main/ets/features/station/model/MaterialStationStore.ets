import {
  MaterialDraft,
  MaterialRecord,
  SelectableMaterial
} from './BartendingStationMockData';
import { getMaterialVisualMeta, normalizeCategoryId, normalizeString } from './StationMaterialApiModels';

let stagingMaterialsState: SelectableMaterial[] = [];
let recordedDraftsState: MaterialDraft[] = [];

function cloneMaterialDraft(draft: MaterialDraft): MaterialDraft {
  return {
    id: draft.id,
    source: draft.source,
    sourceLabel: draft.sourceLabel,
    name: draft.name,
    subtitle: draft.subtitle,
    brand: draft.brand,
    categoryId: draft.categoryId,
    barcode: draft.barcode,
    materialId: draft.materialId,
    capacityText: draft.capacityText,
    remainLevel: draft.remainLevel,
    opened: draft.opened,
    hasItem: draft.hasItem,
    tags: draft.tags.slice(),
    note: draft.note,
    badge: draft.badge,
    accentColor: draft.accentColor,
    softColor: draft.softColor
  };
}

function cloneSelectableMaterial(item: SelectableMaterial): SelectableMaterial {
  return {
    id: item.id,
    materialId: item.materialId,
    name: item.name,
    subtitle: item.subtitle,
    categoryId: item.categoryId,
    categoryName: item.categoryName,
    quickNote: item.quickNote,
    badge: item.badge,
    accentColor: item.accentColor,
    softColor: item.softColor,
    tags: item.tags.slice(),
    isCommon: item.isCommon,
    isRecent: item.isRecent,
    isRecommended: item.isRecommended
  };
}

function shouldNeedsCompletion(draft: MaterialDraft): boolean {
  const normalizedCategoryId = normalizeCategoryId(draft.categoryId);
  if (normalizedCategoryId === 'fruit' || normalizedCategoryId === 'glassware') {
    return false;
  }
  if (!draft.hasItem) {
    return false;
  }
  if (normalizeString(draft.capacityText, '').length === 0) {
    return true;
  }
  return draft.tags.length === 0;
}

function buildAmountText(draft: MaterialDraft): string {
  const normalizedCategoryId = normalizeCategoryId(draft.categoryId);
  if (normalizedCategoryId === 'fruit' || normalizedCategoryId === 'glassware') {
    return draft.hasItem ? '已标记为有' : '已标记为没有';
  }

  const capacityText = normalizeString(draft.capacityText, '');
  if (capacityText.length > 0) {
    return `${capacityText} · ${normalizeString(draft.remainLevel, '满瓶')}`;
  }
  return normalizeString(draft.remainLevel, '信息待补充');
}

function buildSubtitle(draft: MaterialDraft): string {
  const normalizedCategoryId = normalizeCategoryId(draft.categoryId);
  if (normalizedCategoryId === 'fruit' || normalizedCategoryId === 'glassware') {
    return draft.hasItem ? '已按有无状态记录，可随时修改。' : '已标记为没有，当前不会参与配方匹配。';
  }

  if (!draft.hasItem) {
    return '当前已标记为缺货，可在编辑页重新恢复。';
  }

  if (shouldNeedsCompletion(draft)) {
    return '已加入我的材料，仍可继续补充库存或风味信息。';
  }

  return '已加入我的材料，可直接参与当前配方匹配。';
}

function createMaterialRecordFromDraft(draft: MaterialDraft): MaterialRecord {
  const visualMeta = getMaterialVisualMeta(draft.categoryId);
  return {
    id: draft.id,
    name: draft.name,
    subtitle: buildSubtitle(draft),
    categoryId: visualMeta.categoryId,
    categoryName: visualMeta.categoryName,
    amountText: buildAmountText(draft),
    statusText: shouldNeedsCompletion(draft) ? '待补全' : (draft.hasItem ? '已补全' : '缺货'),
    needsCompletion: shouldNeedsCompletion(draft),
    badge: normalizeString(draft.badge, visualMeta.badge),
    accentColor: normalizeString(draft.accentColor, visualMeta.accentColor),
    softColor: normalizeString(draft.softColor, visualMeta.softColor),
    tags: draft.tags.slice()
  };
}

export function setRecordedMaterialDrafts(drafts: MaterialDraft[]): void {
  recordedDraftsState = drafts.map((item: MaterialDraft): MaterialDraft => cloneMaterialDraft(item));
}

export function getRecordedMaterialDrafts(): MaterialDraft[] {
  return recordedDraftsState.map((item: MaterialDraft): MaterialDraft => cloneMaterialDraft(item));
}

export function getRecordedDraftById(materialId?: string): MaterialDraft | undefined {
  if (typeof materialId !== 'string' || materialId.length === 0) {
    return undefined;
  }
  const matchedDraft = recordedDraftsState.find((item: MaterialDraft): boolean => item.id === materialId);
  if (!matchedDraft) {
    return undefined;
  }
  return cloneMaterialDraft(matchedDraft);
}

export function getStagingMaterialIds(): string[] {
  return stagingMaterialsState.map((item: SelectableMaterial): string => item.id);
}

export function getStagingMaterials(): SelectableMaterial[] {
  return stagingMaterialsState.map((item: SelectableMaterial): SelectableMaterial => cloneSelectableMaterial(item));
}

export function isInStagingList(materialId: string): boolean {
  return stagingMaterialsState.some((item: SelectableMaterial): boolean => item.id === materialId);
}

export function toggleStagingMaterial(item: SelectableMaterial): void {
  if (isInStagingList(item.id)) {
    removeFromStagingMaterials(item.id);
    return;
  }
  stagingMaterialsState = stagingMaterialsState.concat([cloneSelectableMaterial(item)]);
}

export function removeFromStagingMaterials(materialId: string): void {
  stagingMaterialsState = stagingMaterialsState.filter((item: SelectableMaterial): boolean => item.id !== materialId);
}

export function clearStagingMaterials(): void {
  stagingMaterialsState = [];
}

export function getRecordedMaterials(): MaterialRecord[] {
  return recordedDraftsState
    .map((item: MaterialDraft): MaterialRecord => createMaterialRecordFromDraft(item))
    .slice();
}

export function upsertRecordedMaterialDraft(draft: MaterialDraft): void {
  const clonedDraft: MaterialDraft = cloneMaterialDraft(draft);
  const existingIndex = recordedDraftsState.findIndex((item: MaterialDraft): boolean => item.id === clonedDraft.id);
  if (existingIndex === -1) {
    recordedDraftsState = [clonedDraft].concat(recordedDraftsState);
    return;
  }
  recordedDraftsState[existingIndex] = clonedDraft;
  recordedDraftsState = recordedDraftsState.slice();
}

export function removeRecordedMaterialById(materialId: string): void {
  recordedDraftsState = recordedDraftsState.filter((item: MaterialDraft): boolean => item.id !== materialId);
}

export function saveMaterialDraft(draft: MaterialDraft): void {
  upsertRecordedMaterialDraft(draft);
}
