import { preferences } from '@kit.ArkData';
import common from '@ohos.app.ability.common';
import {
  SESSION_PREFERENCES_NAME,
  STORAGE_KEY_ACCESS_TOKEN,
  STORAGE_KEY_EXPIRE_SECONDS,
  STORAGE_KEY_TOKEN_TYPE,
  STORAGE_KEY_USER_PROFILE,
  STORAGE_KEY_API_BASE_URL
} from '../constants/StorageKeys';

export interface SessionSnapshot {
  accessToken?: string;
  tokenType?: string;
  expireSeconds?: number;
  userProfile?: string;
}

class SessionStore {
  private store?: preferences.Preferences;

  async init(context: common.BaseContext): Promise<void> {
    if (this.store) {
      return;
    }

    this.store = await preferences.getPreferences(context, {
      name: SESSION_PREFERENCES_NAME
    });
  }

  isInitialized(): boolean {
    return this.store !== undefined;
  }

  async saveSession(session: SessionSnapshot): Promise<void> {
    await this.ensureStore();

    if (session.accessToken !== undefined) {
      await this.store!.put(STORAGE_KEY_ACCESS_TOKEN, session.accessToken);
    }
    if (session.tokenType !== undefined) {
      await this.store!.put(STORAGE_KEY_TOKEN_TYPE, session.tokenType);
    }
    if (session.expireSeconds !== undefined) {
      await this.store!.put(STORAGE_KEY_EXPIRE_SECONDS, session.expireSeconds);
    }
    if (session.userProfile !== undefined) {
      await this.store!.put(STORAGE_KEY_USER_PROFILE, session.userProfile);
    }

    await this.store!.flush();
  }

  async setAccessToken(token: string): Promise<void> {
    await this.saveSession({ accessToken: token });
  }

  async getAccessToken(): Promise<string> {
    await this.ensureStore();
    return this.readString(STORAGE_KEY_ACCESS_TOKEN);
  }

  async setTokenType(tokenType: string): Promise<void> {
    await this.saveSession({ tokenType });
  }

  async getTokenType(): Promise<string> {
    await this.ensureStore();
    return this.readString(STORAGE_KEY_TOKEN_TYPE, 'Bearer');
  }

  async setExpireSeconds(expireSeconds: number): Promise<void> {
    await this.saveSession({ expireSeconds });
  }

  async getExpireSeconds(): Promise<number> {
    await this.ensureStore();
    return this.readNumber(STORAGE_KEY_EXPIRE_SECONDS);
  }

  async setUserProfile(userProfile: string): Promise<void> {
    await this.saveSession({ userProfile });
  }

  async getUserProfile(): Promise<string> {
    await this.ensureStore();
    return this.readString(STORAGE_KEY_USER_PROFILE);
  }

  async setApiBaseUrl(baseUrl: string): Promise<void> {
    await this.ensureStore();
    await this.store!.put(STORAGE_KEY_API_BASE_URL, baseUrl);
    await this.store!.flush();
  }

  async getApiBaseUrl(): Promise<string> {
    await this.ensureStore();
    return this.readString(STORAGE_KEY_API_BASE_URL);
  }

  async getAuthorizationValue(): Promise<string> {
    const accessToken = await this.getAccessToken();
    if (!accessToken) {
      return '';
    }

    const tokenType = await this.getTokenType();
    return `${tokenType} ${accessToken}`;
  }

  async clearSession(): Promise<void> {
    await this.ensureStore();
    await this.store!.delete(STORAGE_KEY_ACCESS_TOKEN);
    await this.store!.delete(STORAGE_KEY_TOKEN_TYPE);
    await this.store!.delete(STORAGE_KEY_EXPIRE_SECONDS);
    await this.store!.delete(STORAGE_KEY_USER_PROFILE);
    await this.store!.flush();
  }

  private async ensureStore(): Promise<void> {
    if (!this.store) {
      throw new Error('SessionStore is not initialized. Call SessionStore.init(context) first.');
    }
  }

  private readString(key: string, fallback: string = ''): string {
    return this.store!.getSync(key, fallback) as string;
  }

  private readNumber(key: string, fallback: number = 0): number {
    return this.store!.getSync(key, fallback) as number;
  }
}

export const sessionStore: SessionStore = new SessionStore();