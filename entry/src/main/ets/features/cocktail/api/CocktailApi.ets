import { COCKTAILS_PATH, RECOMMEND_COCKTAILS_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  CocktailCategoryDto,
  CocktailDetailDto,
  CocktailPageDto,
  CocktailPageQuery
} from '../model/CocktailDetailModels';
import { RecommendCocktailPayloadDto, RecommendCocktailRequest } from '../model/CocktailRecommendModels';

class CocktailApi {
  getCocktailPage(query: CocktailPageQuery = {}): Promise<ApiResponse<CocktailPageDto>> {
    const queryParams: CocktailPageQuery = {
      keyword: query.keyword ?? undefined,
      page: query.page ?? 0,
      size: query.size ?? 20
    };
    const options: HttpRequestOptions = {
      attachToken: true,
      query: queryParams as Record<string, string | number | boolean | undefined | null>
    };
    return httpClient.get<CocktailPageDto>(COCKTAILS_PATH, options);
  }
  getCocktailDetail(id: number | string): Promise<ApiResponse<CocktailDetailDto>> {
    const options: HttpRequestOptions = {
      attachToken: true
    };
    return httpClient.get<CocktailDetailDto>(`${COCKTAILS_PATH}/${id}`, options);
  }

  getCocktailCategories(): Promise<ApiResponse<CocktailCategoryDto[]>> {
    const options: HttpRequestOptions = {
      attachToken: true
    };
    return httpClient.get<CocktailCategoryDto[]>(`${COCKTAILS_PATH}/categories`, options);
  }


  getRecommendedCocktails(data: RecommendCocktailRequest): Promise<ApiResponse<RecommendCocktailPayloadDto>> {
    const options: HttpRequestOptions = {
      data,
      attachToken: true
    };
    return httpClient.post<RecommendCocktailPayloadDto>(RECOMMEND_COCKTAILS_PATH, options);
  }
}

export const cocktailApi: CocktailApi = new CocktailApi();
