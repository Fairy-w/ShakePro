import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponse, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { MaterialDraft, SelectableMaterial } from '../model/BartendingStationMockData';
import { stationMaterialApi } from '../api/StationMaterialApi';
import {
  BarcodeLookupRequest,
  BarcodeLookupResponse,
  MaterialResponse,
  SaveManualUserMaterialBatchItem,
  SaveManualUserMaterialRequest,
  SaveManualUserMaterialsBatchRequest,
  SaveScannedUserMaterialRequest,
  UserMaterialResponse,
  UserMaterialsQuery,
  normalizeBarcode,
  normalizeCategoryId,
  normalizeString,
  normalizeTags,
  toMaterialDraft,
  toNullableText,
  toSelectableMaterial
} from '../model/StationMaterialApiModels';

const STATION_MATERIAL_REPO_LOG_DOMAIN: number = 0x0000;
const STATION_MATERIAL_REPO_LOG_TAG: string = 'ShakeProStationMaterialRepo';
const BARCODE_PARAM_ERROR_CODE: number = 40001;
const BARCODE_NOT_FOUND_CODE: number = 40410;
const BARCODE_SERVICE_ERROR_CODE: number = 50030;
const DEFAULT_LOOKUP_LOCALE: string = 'zh-CN';

class StationMaterialRepository {
  async lookupBarcode(request: BarcodeLookupRequest): Promise<MaterialDraft> {
    const normalizedRequest = this.normalizeLookupRequest(request);
    this.ensureBarcode(normalizedRequest.barcode);

    hilog.info(
      STATION_MATERIAL_REPO_LOG_DOMAIN,
      STATION_MATERIAL_REPO_LOG_TAG,
      'lookup barcode=%{public}s locale=%{public}s',
      normalizedRequest.barcode,
      normalizedRequest.locale ?? ''
    );

    const response = await stationMaterialApi.lookupBarcode(normalizedRequest);
    const dto = this.unwrapResponse<BarcodeLookupResponse>(response, '条码识别失败');
    return toMaterialDraft(dto);
  }

  async getUserMaterials(query?: UserMaterialsQuery): Promise<MaterialDraft[]> {
    const response = await stationMaterialApi.getUserMaterials(this.normalizeUserMaterialsQuery(query));
    const items = this.unwrapListResponse<UserMaterialResponse>(response, '获取材料列表失败');
    return items.map((item: UserMaterialResponse): MaterialDraft => toMaterialDraft(item));
  }

  async getManualMaterialOptions(keyword?: string): Promise<SelectableMaterial[]> {
    const response = await stationMaterialApi.getMaterials({
      keyword: toNullableText(keyword) ?? undefined
    } as UserMaterialsQuery);
    const items = this.unwrapListResponse<MaterialResponse>(response, '获取基础材料列表失败');
    return items.map((item: MaterialResponse): SelectableMaterial => toSelectableMaterial(item));
  }

  async getMaterialCategories(): Promise<string[]> {
    const response = await stationMaterialApi.getMaterialCategories();
    return this.unwrapListResponse<string>(response, '获取材料分类失败');
  }

  async saveScannedMaterial(draft: MaterialDraft): Promise<MaterialDraft> {
    const payload = this.buildScannedSavePayload(draft);
    this.ensureBarcode(payload.barcode);

    hilog.info(
      STATION_MATERIAL_REPO_LOG_DOMAIN,
      STATION_MATERIAL_REPO_LOG_TAG,
      'save scanned material name=%{public}s barcode=%{public}s hasItem=%{public}s',
      payload.name ?? '',
      payload.barcode,
      String(payload.hasItem)
    );

    const response = await stationMaterialApi.saveScannedUserMaterial(payload);
    const dto = this.unwrapResponse<UserMaterialResponse>(response, '保存扫码材料失败');
    return toMaterialDraft(dto);
  }

  async saveManualMaterial(draft: MaterialDraft): Promise<MaterialDraft> {
    const payload = this.buildManualSavePayload(draft);

    hilog.info(
      STATION_MATERIAL_REPO_LOG_DOMAIN,
      STATION_MATERIAL_REPO_LOG_TAG,
      'save manual material materialId=%{public}s hasItem=%{public}s',
      String(payload.materialId),
      String(payload.hasItem)
    );

    const response = await stationMaterialApi.saveManualUserMaterial(payload);
    const dto = this.unwrapResponse<UserMaterialResponse>(response, '保存手动材料失败');
    return toMaterialDraft(dto);
  }

  async saveUserMaterial(draft: MaterialDraft): Promise<MaterialDraft> {
    if (this.isScanSource(draft)) {
      return this.saveScannedMaterial(draft);
    }
    return this.saveManualMaterial(draft);
  }

  async batchSaveManualMaterials(items: SelectableMaterial[], hasItem: boolean = true): Promise<MaterialDraft[]> {
    const payloadItems: SaveManualUserMaterialBatchItem[] = items
      .filter((item: SelectableMaterial): boolean => typeof item.materialId === 'number' && item.materialId > 0)
      .map((item: SelectableMaterial): SaveManualUserMaterialBatchItem => {
        return {
          materialId: item.materialId!,
          hasItem
        } as SaveManualUserMaterialBatchItem;
      });

    if (payloadItems.length === 0) {
      return [];
    }

    const payload: SaveManualUserMaterialsBatchRequest = {
      items: payloadItems
    };
    const response = await stationMaterialApi.saveManualUserMaterialsBatch(payload);
    const savedItems = this.unwrapListResponse<UserMaterialResponse>(response, '批量保存手动材料失败');
    return savedItems.map((item: UserMaterialResponse): MaterialDraft => toMaterialDraft(item));
  }

  async deleteUserMaterial(barcode: string): Promise<void> {
    const normalizedBarcode = normalizeBarcode(barcode);
    this.ensureBarcode(normalizedBarcode);
    const response = await stationMaterialApi.deleteUserMaterial(normalizedBarcode);
    this.unwrapVoidResponse(response, '删除材料失败');
  }

  private normalizeLookupRequest(request: BarcodeLookupRequest): BarcodeLookupRequest {
    return {
      barcode: normalizeBarcode(request.barcode),
      locale: this.normalizeLocale(request.locale)
    } as BarcodeLookupRequest;
  }

  private normalizeUserMaterialsQuery(query?: UserMaterialsQuery): UserMaterialsQuery {
    if (!query) {
      return {};
    }
    return {
      keyword: toNullableText(query.keyword) ?? undefined,
      categoryId: this.normalizeCategoryQuery(query.categoryId)
    } as UserMaterialsQuery;
  }

  private normalizeCategoryQuery(categoryId?: string): string | undefined {
    const normalizedCategoryId = toNullableText(categoryId);
    if (normalizedCategoryId === null || normalizedCategoryId === 'all') {
      return undefined;
    }
    return normalizeCategoryId(normalizedCategoryId);
  }

  private buildScannedSavePayload(draft: MaterialDraft): SaveScannedUserMaterialRequest {
    return {
      barcode: normalizeBarcode(draft.barcode),
      materialId: typeof draft.materialId === 'number' ? draft.materialId : null,
      name: toNullableText(draft.name),
      brand: toNullableText(draft.brand),
      categoryId: this.resolveCategoryIdForSave(draft),
      source: 'scan',
      hasItem: draft.hasItem === true,
      tags: normalizeTags(draft.tags)
    };
  }

  private buildManualSavePayload(draft: MaterialDraft): SaveManualUserMaterialRequest {
    const materialId = this.resolveManualMaterialId(draft);
    if (materialId === undefined) {
      throw new HttpRequestError({
        message: '手动材料缺少 materialId，无法保存',
        code: BARCODE_PARAM_ERROR_CODE
      });
    }

    return {
      materialId,
      source: 'manual',
      brand: toNullableText(draft.brand),
      categoryId: this.resolveCategoryIdForSave(draft),
      hasItem: draft.hasItem === true,
      tags: normalizeTags(draft.tags)
    };
  }

  private resolveManualMaterialId(draft: MaterialDraft): number | undefined {
    if (typeof draft.materialId === 'number' && draft.materialId > 0) {
      return draft.materialId;
    }

    const matchedMaterialId = /^material-(\d+)$/.exec(draft.id);
    if (matchedMaterialId && matchedMaterialId[1]) {
      return parseInt(matchedMaterialId[1], 10);
    }

    return undefined;
  }

  private resolveCategoryIdForSave(draft: MaterialDraft): string | null {
    const categoryId = toNullableText(draft.categoryId);
    if (categoryId === null) {
      return null;
    }
    return normalizeCategoryId(categoryId);
  }

  private isScanSource(draft: MaterialDraft): boolean {
    return normalizeString(draft.source, 'manual') === 'scan';
  }

  private normalizeLocale(locale: string | undefined): string {
    if (typeof locale !== 'string') {
      return DEFAULT_LOOKUP_LOCALE;
    }
    const trimmed = locale.trim();
    if (trimmed.length === 0) {
      return DEFAULT_LOOKUP_LOCALE;
    }
    return trimmed;
  }

  private ensureBarcode(barcode: string): void {
    if (barcode.length > 0) {
      return;
    }
    throw new HttpRequestError({
      message: this.resolveErrorMessage(BARCODE_PARAM_ERROR_CODE, '', '条码格式不正确'),
      code: BARCODE_PARAM_ERROR_CODE
    });
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        STATION_MATERIAL_REPO_LOG_DOMAIN,
        STATION_MATERIAL_REPO_LOG_TAG,
        'api unwrap failed code=%{public}s message=%{public}s traceId=%{public}s',
        String(response.code),
        response.message ?? '',
        response.traceId ?? ''
      );
      throw new HttpRequestError({
        message: this.resolveErrorMessage(response.code, response.message, fallbackMessage),
        code: response.code,
        traceId: response.traceId
      });
    }
    return response.data;
  }
  private unwrapListResponse<T>(response: ApiResponse<T[]>, fallbackMessage: string): T[] {
    const data = this.unwrapResponse<T[]>(response, fallbackMessage);
    if (Array.isArray(data)) {
      return data;
    }
    return [];
  }

  private unwrapVoidResponse(response: ApiResponse<void>, fallbackMessage: string): void {
    if (isApiSuccess(response)) {
      return;
    }
    throw new HttpRequestError({
      message: this.resolveErrorMessage(response.code, response.message, fallbackMessage),
      code: response.code,
      traceId: response.traceId
    });
  }

  private resolveErrorMessage(code: number, message: string | null | undefined, fallbackMessage: string): string {
    const normalizedMessage = typeof message === 'string' ? message.trim() : '';
    if (normalizedMessage.length > 0) {
      return normalizedMessage;
    }
    if (code === BARCODE_NOT_FOUND_CODE) {
      return '没有识别到这个条码对应的材料';
    }
    if (code === BARCODE_SERVICE_ERROR_CODE) {
      return '条码识别服务暂时不可用，请稍后重试';
    }
    return fallbackMessage;
  }
}

export const stationMaterialRepository: StationMaterialRepository = new StationMaterialRepository();
