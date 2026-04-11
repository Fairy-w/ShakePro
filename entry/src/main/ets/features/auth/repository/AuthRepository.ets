import { hilog } from '@kit.PerformanceAnalysisKit';
import { getApiMessage, HttpRequestError, ApiResponse, isApiSuccess } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { authApi } from '../api/AuthApi';
import { LoginRequest } from '../model/LoginRequest';
import { LoginResponse } from '../model/LoginResponse';
import { RegisterRequest } from '../model/RegisterRequest';
import { UserInfo } from '../model/UserInfo';
const AUTH_REPO_LOG_DOMAIN: number = 0x0000;
const AUTH_REPO_LOG_TAG: string = 'ShakeProAuthRepo';
class AuthRepository {
  async register(data: RegisterRequest): Promise<UserInfo> {
    hilog.info(AUTH_REPO_LOG_DOMAIN, AUTH_REPO_LOG_TAG, 'register called username=%{public}s nickname=%{public}s', data.username, data.nickname ?? '');
    const response = await authApi.register(data);
    return this.unwrapResponse<UserInfo>(response, '??????');
  }
  async login(data: LoginRequest): Promise<LoginResponse> {
    hilog.info(AUTH_REPO_LOG_DOMAIN, AUTH_REPO_LOG_TAG, 'login called username=%{public}s', data.username);
    const response = await authApi.login(data);
    const loginResult = this.unwrapResponse<LoginResponse>(response, '??????');
    hilog.info(AUTH_REPO_LOG_DOMAIN, AUTH_REPO_LOG_TAG, 'login success username=%{public}s tokenType=%{public}s expireSeconds=%{public}s', data.username, loginResult.tokenType, String(loginResult.expireSeconds));
    await sessionStore.saveSession({
      accessToken: loginResult.token,
      tokenType: loginResult.tokenType,
      expireSeconds: loginResult.expireSeconds,
      userProfile: JSON.stringify(loginResult.user)
    });
    return loginResult;
  }
  async getCurrentUser(): Promise<UserInfo> {
    const response = await authApi.getMe();
    const userInfo = this.unwrapResponse<UserInfo>(response, '???????????????');
    await sessionStore.setUserProfile(JSON.stringify(userInfo));
    return userInfo;
  }
  async logout(): Promise<void> {
    await sessionStore.clearSession();
  }
  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(AUTH_REPO_LOG_DOMAIN, AUTH_REPO_LOG_TAG, 'api unwrap failed code=%{public}s message=%{public}s traceId=%{public}s', String(response.code), response.message ?? '', response.traceId ?? '');
      throw new HttpRequestError({
        message: getApiMessage(response, fallbackMessage),
        code: response.code,
        traceId: response.traceId
      });
    }
    return response.data;
  }
}
export const authRepository: AuthRepository = new AuthRepository();