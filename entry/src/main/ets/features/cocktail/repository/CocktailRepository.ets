import { AppLogger } from '../../../core/logging/AppLogger';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { cocktailApi } from '../api/CocktailApi';
import {
  CocktailCategoryDto,
  CocktailDetailDto,
  CocktailPageDto,
  CocktailPageQuery
} from '../model/CocktailDetailModels';
import {
  RecommendCocktailCardModel,
  RecommendCocktailItemDto,
  RecommendCocktailPayloadDto,
  RecommendCocktailRequest,
  toRecommendCocktailCardModel
} from '../model/CocktailRecommendModels';

const COCKTAIL_REPO_LOG_TAG: string = 'ShakeProCocktailRepo';

class CocktailRepository {
  async getCocktailPage(query: CocktailPageQuery = {}): Promise<CocktailPageDto> {
    AppLogger.info(COCKTAIL_REPO_LOG_TAG,
      'get cocktail page page=%{public}d size=%{public}d keyword=%{public}s',
      query.page ?? 0,
      query.size ?? 20,
      query.keyword ?? ''
    );
    const response = await cocktailApi.getCocktailPage(query);
    return this.unwrapResponse<CocktailPageDto>(response, '获取鸡尾酒列表失败');
  }

  async getCocktailDetail(id: number | string): Promise<CocktailDetailDto> {
    AppLogger.info(COCKTAIL_REPO_LOG_TAG,
      'get cocktail detail id=%{public}s',
      String(id)
    );
    const response = await cocktailApi.getCocktailDetail(id);
    return this.unwrapResponse<CocktailDetailDto>(response, '获取鸡尾酒详情失败');
  }

  async getCocktailCategories(): Promise<CocktailCategoryDto[]> {
    AppLogger.info(COCKTAIL_REPO_LOG_TAG, 'get cocktail categories');
    const response = await cocktailApi.getCocktailCategories();
    return this.unwrapResponse<CocktailCategoryDto[]>(response, '获取鸡尾酒分类失败');
  }


  async getRecommendedCocktails(request: RecommendCocktailRequest): Promise<RecommendCocktailCardModel[]> {
    AppLogger.info(COCKTAIL_REPO_LOG_TAG,
      'get recommend cocktails seedId=%{public}d topk=%{public}d offset=%{public}d',
      request.seedId,
      request.topk ?? 3,
      request.offset ?? 0
    );
    const response = await cocktailApi.getRecommendedCocktails(request);
    const payload = this.unwrapResponse<RecommendCocktailPayloadDto>(response, '获取首页推荐失败');
    const result: RecommendCocktailCardModel[] = [];
    const items = Array.isArray(payload.items) ? payload.items : [];
    for (let index: number = 0; index < items.length; index += 1) {
      const mapped: RecommendCocktailCardModel | null = toRecommendCocktailCardModel(items[index] as RecommendCocktailItemDto);
      if (mapped !== null) {
        result.push(mapped);
      }
    }
    return result;
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      AppLogger.error(COCKTAIL_REPO_LOG_TAG,
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

export const cocktailRepository: CocktailRepository = new CocktailRepository();
