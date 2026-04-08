import { UserInfo } from './UserInfo';

export interface LoginResponse {
  token: string;
  tokenType: string;
  expireSeconds: number;
  user: UserInfo;
}
