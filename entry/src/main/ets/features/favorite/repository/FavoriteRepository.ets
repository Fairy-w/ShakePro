import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { favoriteApi } from '../api/FavoriteApi';
import {
  FavoriteAiCocktailListQuery,
  FavoriteAiCocktailListResponse,
  FavoriteAiCocktailMutationResponse,
  FavoriteAiCocktailStatusResponse,
  SaveAiCocktailFavoriteRequest
} from '../model/FavoriteAiCocktailModels';

const FAVORITE_REPO_LOG_DOMAIN: number = 0x0000;
const FAVORITE_REPO_LOG_TAG: string = 'ShakeProFavoriteRepo';

class FavoriteRepository {
  async saveAiCocktail(data: SaveAiCocktailFavoriteRequest): Promise<FavoriteAiCocktailMutationResponse> {
    hilog.info(
      FAVORITE_REPO_LOG_DOMAIN,
      FAVORITE_REPO_LOG_TAG,
      'save ai cocktail favorite recipeKey=%{public}s name=%{public}s',
      data.recipeKey ?? '',
      data.name
    );
    const response = await favoriteApi.saveAiCocktail(data);
    return this.unwrapResponse<FavoriteAiCocktailMutationResponse>(response, '收藏失败');
  }

  async deleteAiCocktailById(favoriteId: number): Promise<FavoriteAiCocktailMutationResponse> {
    hilog.info(FAVORITE_REPO_LOG_DOMAIN, FAVORITE_REPO_LOG_TAG, 'delete favorite by id=%{public}d', favoriteId);
    const response = await favoriteApi.deleteAiCocktailById(favoriteId);
    return this.unwrapResponse<FavoriteAiCocktailMutationResponse>(response, '取消收藏失败');
  }

  async deleteAiCocktailByRecipeKey(recipeKey: string): Promise<FavoriteAiCocktailMutationResponse> {
    hilog.info(
      FAVORITE_REPO_LOG_DOMAIN,
      FAVORITE_REPO_LOG_TAG,
      'delete favorite by recipeKey=%{public}s',
      recipeKey
    );
    const response = await favoriteApi.deleteAiCocktailByRecipeKey(recipeKey);
    return this.unwrapResponse<FavoriteAiCocktailMutationResponse>(response, '取消收藏失败');
  }

  async getAiCocktailList(query: FavoriteAiCocktailListQuery): Promise<FavoriteAiCocktailListResponse> {
    hilog.info(
      FAVORITE_REPO_LOG_DOMAIN,
      FAVORITE_REPO_LOG_TAG,
      'get ai cocktail list pageNo=%{public}s pageSize=%{public}s keyword=%{public}s',
      String(query.pageNo ?? 1),
      String(query.pageSize ?? 10),
      query.keyword ?? ''
    );
    const response = await favoriteApi.getAiCocktailList(query);
    return this.unwrapResponse<FavoriteAiCocktailListResponse>(response, '获取收藏列表失败');
  }

  async getAiCocktailStatus(recipeKey: string): Promise<FavoriteAiCocktailStatusResponse> {
    const response = await favoriteApi.getAiCocktailStatus(recipeKey);
    return this.unwrapResponse<FavoriteAiCocktailStatusResponse>(response, '获取收藏状态失败');
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        FAVORITE_REPO_LOG_DOMAIN,
        FAVORITE_REPO_LOG_TAG,
        'api unwrap failed code=%{public}s message=%{public}s traceId=%{public}s',
        String(response.code),
        response.message ?? '',
        response.traceId ?? ''
      );
      throw new HttpRequestError({
        message: getApiMessage(response, fallbackMessage),
        code: response.code,
        traceId: response.traceId
      });
    }
    return response.data;
  }
}

export const favoriteRepository: FavoriteRepository = new FavoriteRepository();
