import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { cocktailApi } from '../api/CocktailApi';
import {
  CocktailBannerDto,
  CocktailCategoryDto,
  CocktailDetailDto,
  CocktailPageDto,
  CocktailPageQuery
} from '../model/CocktailDetailModels';

const COCKTAIL_REPO_LOG_DOMAIN: number = 0x0000;
const COCKTAIL_REPO_LOG_TAG: string = 'ShakeProCocktailRepo';

class CocktailRepository {
  async getCocktailPage(query: CocktailPageQuery = {}): Promise<CocktailPageDto> {
    hilog.info(
      COCKTAIL_REPO_LOG_DOMAIN,
      COCKTAIL_REPO_LOG_TAG,
      'get cocktail page page=%{public}d size=%{public}d keyword=%{public}s',
      query.page ?? 0,
      query.size ?? 20,
      query.keyword ?? ''
    );
    const response = await cocktailApi.getCocktailPage(query);
    return this.unwrapResponse<CocktailPageDto>(response, '获取鸡尾酒列表失败');
  }

  async getCocktailDetail(id: number | string): Promise<CocktailDetailDto> {
    hilog.info(
      COCKTAIL_REPO_LOG_DOMAIN,
      COCKTAIL_REPO_LOG_TAG,
      'get cocktail detail id=%{public}s',
      String(id)
    );
    const response = await cocktailApi.getCocktailDetail(id);
    return this.unwrapResponse<CocktailDetailDto>(response, '获取鸡尾酒详情失败');
  }

  async getCocktailBanner(): Promise<CocktailBannerDto[]> {
    hilog.info(COCKTAIL_REPO_LOG_DOMAIN, COCKTAIL_REPO_LOG_TAG, 'get cocktail banner');
    const response = await cocktailApi.getCocktailBanner();
    return this.unwrapResponse<CocktailBannerDto[]>(response, '获取首页 Banner 失败');
  }

  async getCocktailCategories(): Promise<CocktailCategoryDto[]> {
    hilog.info(COCKTAIL_REPO_LOG_DOMAIN, COCKTAIL_REPO_LOG_TAG, 'get cocktail categories');
    const response = await cocktailApi.getCocktailCategories();
    return this.unwrapResponse<CocktailCategoryDto[]>(response, '获取鸡尾酒分类失败');
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        COCKTAIL_REPO_LOG_DOMAIN,
        COCKTAIL_REPO_LOG_TAG,
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
