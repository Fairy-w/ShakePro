import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { aiApi } from '../api/AiApi';
import { AiGenerateRecipeByTextRequest } from '../model/AiGenerateRecipeByTextRequest';
import { AiGenerateRecipeResponse } from '../model/AiGenerateRecipeResponse';

const AI_REPO_LOG_DOMAIN: number = 0x0000;
const AI_REPO_LOG_TAG: string = 'ShakeProAiRepo';

class AiRepository {
  async generateRecipeByText(data: AiGenerateRecipeByTextRequest): Promise<AiGenerateRecipeResponse[]> {
    hilog.info(AI_REPO_LOG_DOMAIN, AI_REPO_LOG_TAG, 'generate recipe by text prompt=%{public}s', data.prompt);
    const response = await aiApi.generateRecipeByText(data);
    return this.unwrapResponse<AiGenerateRecipeResponse[]>(response, '生成配方失败');
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        AI_REPO_LOG_DOMAIN,
        AI_REPO_LOG_TAG,
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

export const aiRepository: AiRepository = new AiRepository();
