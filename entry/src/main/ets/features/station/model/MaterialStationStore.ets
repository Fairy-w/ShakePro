import {
  MaterialDraft,
  MaterialRecord,
  SelectableMaterial
} from './StationMaterialModels';
import { getMaterialVisualMeta, normalizeCategoryId, normalizeString } from './StationMaterialApiModels';

let stagingMaterialsState: SelectableMaterial[] = [];
let recordedDraftsState: MaterialDraft[] = [];
const RECORDED_MATERIALS_REFRESH_KEY: string = 'station.recordedMaterialsRefreshSignal';
export function notifyRecordedMaterialsChanged(): void {
  const currentValue: number | undefined = AppStorage.get<number>(RECORDED_MATERIALS_REFRESH_KEY);
  const nextValue = typeof currentValue === 'number' ? currentValue + 1 : 1;
  AppStorage.setOrCreate(RECORDED_MATERIALS_REFRESH_KEY, nextValue);
}

function cloneMaterialDraft(draft: MaterialDraft): MaterialDraft {
  return {
    id: draft.id,
    source: draft.source,
    sourceLabel: draft.sourceLabel,
    name: draft.name,
    subtitle: draft.subtitle,
    brand: draft.brand,
    categoryId: draft.categoryId,
    imageUrl: draft.imageUrl,
    imageUrlThumb: draft.imageUrlThumb,
    imageUrlCard: draft.imageUrlCard,
    imageUrlDetail: draft.imageUrlDetail,
    barcode: draft.barcode,
    addedAt: draft.addedAt,
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
    imageUrl: item.imageUrl,
    imageUrlThumb: item.imageUrlThumb,
    imageUrlCard: item.imageUrlCard,
    imageUrlDetail: item.imageUrlDetail,
    description: item.description,
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

function buildAmountText(draft: MaterialDraft): string {
  return draft.hasItem ? '已标记为有' : '已标记为暂时没有';
}

function buildSubtitle(draft: MaterialDraft): string {
  const normalizedCategoryId = normalizeCategoryId(draft.categoryId);
  const sourceLabel = normalizeString(draft.sourceLabel, draft.source === 'scan' ? '扫码录入' : '手动录入');

  if (draft.hasItem) {
    if (normalizedCategoryId === 'fruit' || normalizedCategoryId === 'glassware') {
      return sourceLabel + ' · 当前标记为有，可随时改成没有。';
    }
    return sourceLabel + ' · 当前标记为有，可参与后续配方匹配。';
  }

  return sourceLabel + ' · 当前标记为暂时没有，后续可随时恢复。';
}

function createMaterialRecordFromDraft(draft: MaterialDraft): MaterialRecord {
  const visualMeta = getMaterialVisualMeta(draft.categoryId);
  return {
    id: draft.id,
    name: draft.name,
    subtitle: buildSubtitle(draft),
    categoryId: visualMeta.categoryId,
    categoryName: visualMeta.categoryName,
    imageUrl: draft.imageUrl,
    imageUrlThumb: draft.imageUrlThumb,
    imageUrlCard: draft.imageUrlCard,
    imageUrlDetail: draft.imageUrlDetail,
    barcode: draft.barcode,
    addedAt: draft.addedAt,
    amountText: buildAmountText(draft),
    statusText: draft.hasItem ? '我有' : '暂时没有',
    needsCompletion: false,
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
    notifyRecordedMaterialsChanged();
    return;
  }
  recordedDraftsState[existingIndex] = clonedDraft;
  recordedDraftsState = recordedDraftsState.slice();
  notifyRecordedMaterialsChanged();
}

export function removeRecordedMaterialById(materialId: string): void {
  recordedDraftsState = recordedDraftsState.filter((item: MaterialDraft): boolean => item.id !== materialId);
  notifyRecordedMaterialsChanged();
}

export function saveMaterialDraft(draft: MaterialDraft): void {
  upsertRecordedMaterialDraft(draft);
}
