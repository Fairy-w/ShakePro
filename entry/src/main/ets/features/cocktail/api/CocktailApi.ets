import { COCKTAILS_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  CocktailBannerDto,
  CocktailCategoryDto,
  CocktailDetailDto,
  CocktailPageDto,
  CocktailPageQuery
} from '../model/CocktailDetailModels';

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

  getCocktailBanner(): Promise<ApiResponse<CocktailBannerDto[]>> {
    const options: HttpRequestOptions = {
      attachToken: true
    };
    return httpClient.get<CocktailBannerDto[]>(`${COCKTAILS_PATH}/banner`, options);
  }

  getCocktailCategories(): Promise<ApiResponse<CocktailCategoryDto[]>> {
    const options: HttpRequestOptions = {
      attachToken: true
    };
    return httpClient.get<CocktailCategoryDto[]>(`${COCKTAILS_PATH}/categories`, options);
  }
}

export const cocktailApi: CocktailApi = new CocktailApi();
