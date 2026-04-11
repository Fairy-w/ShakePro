import {
  FAVORITE_AI_COCKTAILS_PATH,
  FAVORITE_AI_COCKTAIL_STATUS_PATH
} from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  FavoriteAiCocktailListQuery,
  FavoriteAiCocktailListResponse,
  FavoriteAiCocktailMutationResponse,
  FavoriteAiCocktailStatusResponse,
  SaveAiCocktailFavoriteRequest
} from '../model/FavoriteAiCocktailModels';

class FavoriteApi {
  saveAiCocktail(data: SaveAiCocktailFavoriteRequest): Promise<ApiResponse<FavoriteAiCocktailMutationResponse>> {
    return httpClient.post<FavoriteAiCocktailMutationResponse>(FAVORITE_AI_COCKTAILS_PATH, {
      data,
      attachToken: true
    } as HttpRequestOptions);
  }
  deleteAiCocktailById(favoriteId: number): Promise<ApiResponse<FavoriteAiCocktailMutationResponse>> {
    return httpClient.delete<FavoriteAiCocktailMutationResponse>(`${FAVORITE_AI_COCKTAILS_PATH}/${favoriteId}`, {
      attachToken: true
    } as HttpRequestOptions);
  }
  deleteAiCocktailByRecipeKey(recipeKey: string): Promise<ApiResponse<FavoriteAiCocktailMutationResponse>> {
    const queryObj: Record<string, string | number | boolean> = {};
    queryObj.recipeKey = recipeKey;
    return httpClient.delete<FavoriteAiCocktailMutationResponse>(FAVORITE_AI_COCKTAILS_PATH, {
      query: queryObj,
      attachToken: true
    } as HttpRequestOptions);
  }
  getAiCocktailList(query: FavoriteAiCocktailListQuery): Promise<ApiResponse<FavoriteAiCocktailListResponse>> {
    const queryParams: Record<string, string | number | boolean> = {};
    if (query.pageNo !== undefined) queryParams.pageNo = query.pageNo;
    if (query.pageSize !== undefined) queryParams.pageSize = query.pageSize;
    if (query.keyword !== undefined) queryParams.keyword = query.keyword;
    if (query.sort !== undefined) queryParams.sort = query.sort;
    return httpClient.get<FavoriteAiCocktailListResponse>(FAVORITE_AI_COCKTAILS_PATH, {
      query: queryParams,
      attachToken: true
    } as HttpRequestOptions);
  }
  getAiCocktailStatus(recipeKey: string): Promise<ApiResponse<FavoriteAiCocktailStatusResponse>> {
    const queryObj: Record<string, string | number | boolean> = {};
    queryObj.recipeKey = recipeKey;
    return httpClient.get<FavoriteAiCocktailStatusResponse>(FAVORITE_AI_COCKTAIL_STATUS_PATH, {
      query: queryObj,
      attachToken: true
    } as HttpRequestOptions);
  }
}

export const favoriteApi: FavoriteApi = new FavoriteApi();
