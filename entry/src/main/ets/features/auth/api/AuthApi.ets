import { AUTH_LOGIN_PATH, AUTH_ME_PATH, AUTH_REGISTER_PATH } from '../../../common/constants/ApiConfig';
import { httpClient } from '../../../common/network/HttpClient';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { LoginRequest } from '../model/LoginRequest';
import { LoginResponse } from '../model/LoginResponse';
import { RegisterRequest } from '../model/RegisterRequest';
import { UserInfo } from '../model/UserInfo';

class AuthApi {
  register(data: RegisterRequest): Promise<ApiResponse<UserInfo>> {
    return httpClient.post<UserInfo>(AUTH_REGISTER_PATH, {
      data,
      skipAuthorization: true
    });
  }

  login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    return httpClient.post<LoginResponse>(AUTH_LOGIN_PATH, {
      data,
      skipAuthorization: true
    });
  }

  getMe(): Promise<ApiResponse<UserInfo>> {
    return httpClient.get<UserInfo>(AUTH_ME_PATH, {
      attachToken: true
    });
  }
}

export const authApi: AuthApi = new AuthApi();



