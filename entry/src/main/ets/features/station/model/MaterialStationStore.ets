import {
  LIBRARY_ITEMS,
  PENDING_MATERIALS,
  RECORDED_MATERIALS,
  MaterialDraft,
  MaterialRecord,
  SelectableMaterial,
  getDraftById
} from './BartendingStationMockData';

let stagingMaterialIdsState: string[] = [];
let recordedMaterialsState: MaterialRecord[] = RECORDED_MATERIALS.map((item: MaterialRecord): MaterialRecord => cloneMaterialRecord(item));

function cloneMaterialRecord(item: MaterialRecord): MaterialRecord {
  return {
    id: item.id,
    name: item.name,
    subtitle: item.subtitle,
    categoryId: item.categoryId,
    categoryName: item.categoryName,
    amountText: item.amountText,
    statusText: item.statusText,
    needsCompletion: item.needsCompletion,
    badge: item.badge,
    accentColor: item.accentColor,
    softColor: item.softColor,
    tags: item.tags.slice()
  };
}

function getSelectableMaterialById(materialId: string): SelectableMaterial | undefined {
  return LIBRARY_ITEMS.find((item: SelectableMaterial): boolean => item.id === materialId);
}

function getVisualSourceMaterial(materialId: string): MaterialRecord | undefined {
  return recordedMaterialsState.find((item: MaterialRecord): boolean => item.id === materialId) ||
    RECORDED_MATERIALS.find((item: MaterialRecord): boolean => item.id === materialId) ||
    PENDING_MATERIALS.find((item: MaterialRecord): boolean => item.id === materialId);
}

function getCategoryName(categoryId: string, materialId: string): string {
  const visualMaterial: MaterialRecord | undefined = getVisualSourceMaterial(materialId);
  if (visualMaterial) {
    return visualMaterial.categoryName;
  }

  const selectableMaterial: SelectableMaterial | undefined = getSelectableMaterialById(materialId);
  if (selectableMaterial) {
    return selectableMaterial.categoryName;
  }

  if (categoryId === 'spirit') {
    return '基酒';
  }
  if (categoryId === 'liqueur') {
    return '风味酒';
  }
  if (categoryId === 'mixer') {
    return '软饮 / 糖浆';
  }
  if (categoryId === 'fruit') {
    return '水果';
  }
  if (categoryId === 'glassware') {
    return '杯具';
  }
  return '材料';
}

function getBadge(materialId: string, fallbackBadge: string): string {
  const visualMaterial: MaterialRecord | undefined = getVisualSourceMaterial(materialId);
  if (visualMaterial) {
    return visualMaterial.badge;
  }

  const selectableMaterial: SelectableMaterial | undefined = getSelectableMaterialById(materialId);
  if (selectableMaterial) {
    return selectableMaterial.badge;
  }
  return fallbackBadge;
}

function getAccentColor(materialId: string, fallbackColor: string): string {
  const visualMaterial: MaterialRecord | undefined = getVisualSourceMaterial(materialId);
  if (visualMaterial) {
    return visualMaterial.accentColor;
  }

  const selectableMaterial: SelectableMaterial | undefined = getSelectableMaterialById(materialId);
  if (selectableMaterial) {
    return selectableMaterial.accentColor;
  }
  return fallbackColor;
}

function getSoftColor(materialId: string, fallbackColor: string): string {
  const visualMaterial: MaterialRecord | undefined = getVisualSourceMaterial(materialId);
  if (visualMaterial) {
    return visualMaterial.softColor;
  }

  const selectableMaterial: SelectableMaterial | undefined = getSelectableMaterialById(materialId);
  if (selectableMaterial) {
    return selectableMaterial.softColor;
  }
  return fallbackColor;
}

function shouldNeedsCompletion(draft: MaterialDraft): boolean {
  if (draft.categoryId === 'fruit' || draft.categoryId === 'glassware') {
    return false;
  }
  if (!draft.hasItem) {
    return false;
  }
  if (draft.capacityText.length === 0 || draft.capacityText === '-') {
    return true;
  }
  if (draft.tags.length === 0) {
    return true;
  }
  return false;
}

function buildAmountText(draft: MaterialDraft): string {
  if (draft.categoryId === 'fruit' || draft.categoryId === 'glassware') {
    return draft.hasItem ? '已标记为有' : '已标记为没有';
  }
  if (draft.capacityText.length > 0 && draft.capacityText !== '-') {
    return draft.capacityText + ' · ' + draft.remainLevel;
  }
  if (draft.remainLevel.length > 0) {
    return draft.remainLevel;
  }
  return '信息待补充';
}

function buildSubtitle(draft: MaterialDraft): string {
  if (draft.categoryId === 'fruit' || draft.categoryId === 'glassware') {
    if (draft.hasItem) {
      return '已按有无状态记录，可在材料清单中随时修改。';
    }
    return '已标记为没有，当前不会参与配方匹配。';
  }
  if (shouldNeedsCompletion(draft)) {
    return '已加入我的材料，仍可点开补充库存或风味信息。';
  }
  return '已加入我的材料，可直接参与当前配方匹配。';
}

function createMaterialRecordFromDraft(draft: MaterialDraft): MaterialRecord {
  return {
    id: draft.id,
    name: draft.name,
    subtitle: buildSubtitle(draft),
    categoryId: draft.categoryId,
    categoryName: getCategoryName(draft.categoryId, draft.id),
    amountText: buildAmountText(draft),
    statusText: shouldNeedsCompletion(draft) ? '待补全' : '已补全',
    needsCompletion: shouldNeedsCompletion(draft),
    badge: getBadge(draft.id, draft.badge),
    accentColor: getAccentColor(draft.id, draft.accentColor),
    softColor: getSoftColor(draft.id, draft.softColor),
    tags: draft.tags.slice()
  };
}

function createMaterialRecordFromSelectableMaterial(item: SelectableMaterial): MaterialRecord {
  return {
    id: item.id,
    name: item.name,
    subtitle: item.categoryId === 'mixer' ? '已从待入台清单加入，可点开补充库存信息。' : '已从待入台清单加入，当前可直接参与配方匹配。',
    categoryId: item.categoryId,
    categoryName: item.categoryName,
    amountText: item.categoryId === 'mixer' ? '信息待补充' : '已标记为有',
    statusText: item.categoryId === 'mixer' ? '待补全' : '已收录',
    needsCompletion: item.categoryId === 'mixer',
    badge: item.badge,
    accentColor: item.accentColor,
    softColor: item.softColor,
    tags: item.tags.slice()
  };
}

export function getStagingMaterialIds(): string[] {
  return stagingMaterialIdsState.slice();
}

export function getStagingMaterials(): SelectableMaterial[] {
  const selectedMaterials: SelectableMaterial[] = [];
  stagingMaterialIdsState.forEach((materialId: string) => {
    const selectableMaterial: SelectableMaterial | undefined = getSelectableMaterialById(materialId);
    if (selectableMaterial) {
      selectedMaterials.push(selectableMaterial);
    }
  });
  return selectedMaterials;
}

export function isInStagingList(materialId: string): boolean {
  return stagingMaterialIdsState.indexOf(materialId) !== -1;
}

export function toggleStagingMaterial(materialId: string): void {
  if (isInStagingList(materialId)) {
    removeFromStagingMaterials(materialId);
    return;
  }
  stagingMaterialIdsState = stagingMaterialIdsState.concat([materialId]);
}

export function removeFromStagingMaterials(materialId: string): void {
  stagingMaterialIdsState = stagingMaterialIdsState.filter((itemId: string): boolean => itemId !== materialId);
}

export function clearStagingMaterials(): void {
  stagingMaterialIdsState = [];
}

export function getRecordedMaterials(): MaterialRecord[] {
  return recordedMaterialsState.map((item: MaterialRecord): MaterialRecord => cloneMaterialRecord(item));
}

export function upsertRecordedMaterial(record: MaterialRecord): void {
  const clonedRecord: MaterialRecord = cloneMaterialRecord(record);
  const existingIndex: number = recordedMaterialsState.findIndex((item: MaterialRecord): boolean => item.id === clonedRecord.id);
  if (existingIndex === -1) {
    recordedMaterialsState = recordedMaterialsState.concat([clonedRecord]);
    return;
  }
  recordedMaterialsState[existingIndex] = clonedRecord;
  recordedMaterialsState = recordedMaterialsState.slice();
}

export function removeRecordedMaterial(materialId: string): void {
  recordedMaterialsState = recordedMaterialsState.filter((item: MaterialRecord): boolean => item.id !== materialId);
}

export function directIntakeScannedMaterial(materialId: string): void {
  const pendingMaterial: MaterialRecord | undefined = PENDING_MATERIALS.find((item: MaterialRecord): boolean => item.id === materialId);
  if (pendingMaterial) {
    upsertRecordedMaterial(pendingMaterial);
    return;
  }
  saveMaterialDraft(getDraftById(materialId));
}

export function saveMaterialDraft(draft: MaterialDraft): void {
  if ((draft.categoryId === 'fruit' || draft.categoryId === 'glassware') && !draft.hasItem) {
    removeRecordedMaterial(draft.id);
    return;
  }
  upsertRecordedMaterial(createMaterialRecordFromDraft(draft));
}

export function confirmStagingMaterials(): number {
  const stagingMaterials: SelectableMaterial[] = getStagingMaterials();
  stagingMaterials.forEach((item: SelectableMaterial) => {
    upsertRecordedMaterial(createMaterialRecordFromSelectableMaterial(item));
  });
  clearStagingMaterials();
  return stagingMaterials.length;
}
