import {
  BARCODE_LOOKUP_PATH,
  MATERIALS_PATH,
  MATERIAL_CATEGORIES_PATH,
  USER_MATERIALS_PATH,
  USER_MATERIALS_MANUAL_PATH,
  USER_MATERIALS_MANUAL_BATCH_PATH
} from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  BarcodeLookupRequest,
  BarcodeLookupResponse,
  MaterialResponse,
  SaveManualUserMaterialRequest,
  SaveManualUserMaterialsBatchRequest,
  SaveScannedUserMaterialRequest,
  UserMaterialResponse,
  UserMaterialsQuery
} from '../model/StationMaterialApiModels';

class StationMaterialApi {
  lookupBarcode(data: BarcodeLookupRequest): Promise<ApiResponse<BarcodeLookupResponse>> {
    return httpClient.post<BarcodeLookupResponse>(BARCODE_LOOKUP_PATH, {
      data,
      attachToken: true
    } as HttpRequestOptions);
  }

  getMaterials(query?: UserMaterialsQuery): Promise<ApiResponse<MaterialResponse[]>> {
    return httpClient.get<MaterialResponse[]>(MATERIALS_PATH, {
      query,
      attachToken: true
    } as HttpRequestOptions);
  }

  getMaterialCategories(): Promise<ApiResponse<string[]>> {
    return httpClient.get<string[]>(MATERIAL_CATEGORIES_PATH, {
      attachToken: true
    } as HttpRequestOptions);
  }

  getUserMaterials(query?: UserMaterialsQuery): Promise<ApiResponse<UserMaterialResponse[]>> {
    return httpClient.get<UserMaterialResponse[]>(USER_MATERIALS_PATH, {
      query,
      attachToken: true
    } as HttpRequestOptions);
  }

  saveScannedUserMaterial(data: SaveScannedUserMaterialRequest): Promise<ApiResponse<UserMaterialResponse>> {
    return httpClient.post<UserMaterialResponse>(USER_MATERIALS_PATH, {
      data,
      attachToken: true
    } as HttpRequestOptions);
  }

  saveManualUserMaterial(data: SaveManualUserMaterialRequest): Promise<ApiResponse<UserMaterialResponse>> {
    return httpClient.post<UserMaterialResponse>(USER_MATERIALS_MANUAL_PATH, {
      data,
      attachToken: true
    } as HttpRequestOptions);
  }

  saveManualUserMaterialsBatch(data: SaveManualUserMaterialsBatchRequest): Promise<ApiResponse<UserMaterialResponse[]>> {
    return httpClient.post<UserMaterialResponse[]>(USER_MATERIALS_MANUAL_BATCH_PATH, {
      data,
      attachToken: true
    } as HttpRequestOptions);
  }

  deleteUserMaterial(barcode: string): Promise<ApiResponse<void>> {
    return httpClient.delete<void>(`${USER_MATERIALS_PATH}/${barcode}`, {
      attachToken: true
    } as HttpRequestOptions);
  }
}

export const stationMaterialApi: StationMaterialApi = new StationMaterialApi();
