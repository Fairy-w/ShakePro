import { COCKTAILS_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import { CocktailDetailDto } from '../model/CocktailDetailModels';

class CocktailApi {
  getCocktailDetail(id: number | string): Promise<ApiResponse<CocktailDetailDto>> {
    return httpClient.get<CocktailDetailDto>(`${COCKTAILS_PATH}/${id}`, {
      attachToken: true
    } as HttpRequestOptions);
  }
}

export const cocktailApi: CocktailApi = new CocktailApi();
