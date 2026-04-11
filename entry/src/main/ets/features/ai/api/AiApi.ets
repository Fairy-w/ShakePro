import { AI_GENERATE_RECIPE_BY_TEXT_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient } from '../../../common/network/HttpClient';
import { AiGenerateRecipeByTextRequest } from '../model/AiGenerateRecipeByTextRequest';
import { AiGenerateRecipeResponse } from '../model/AiGenerateRecipeResponse';

const AI_REQUEST_TIMEOUT_MS: number = 60000;

class AiApi {
  generateRecipeByText(data: AiGenerateRecipeByTextRequest): Promise<ApiResponse<AiGenerateRecipeResponse[]>> {
    return httpClient.post<AiGenerateRecipeResponse[]>(AI_GENERATE_RECIPE_BY_TEXT_PATH, {
      data,
      timeoutMs: AI_REQUEST_TIMEOUT_MS,
      attachToken: true
    });
  }
}

export const aiApi: AiApi = new AiApi();
