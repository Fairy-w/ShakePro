import common from '@ohos.app.ability.common';
import axios, { AxiosRequestConfig, AxiosResponse, FormData } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { buildApiUrl } from '../../../common/constants/ApiConfig';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { communityApi } from '../api/CommunityApi';
import {
  CommunityPostDetailDto,
  CommunityPostListQuery,
  CommunityPostPageDto,
  CreateCommunityPostRequest,
  CreateCommunityPostResponse,
  UploadCommunityImageResponse
} from '../model/CommunityApiModels';

const COMMUNITY_REPO_LOG_DOMAIN: number = 0x0000;
const COMMUNITY_REPO_LOG_TAG: string = 'ShakeProCommunityRepo';

function resolveUploadFileName(fileUri: string): string {
  const normalizedUri = fileUri.trim();
  const queryIndex = normalizedUri.indexOf('?');
  const pathValue = queryIndex >= 0 ? normalizedUri.slice(0, queryIndex) : normalizedUri;
  const slashIndex = pathValue.lastIndexOf('/');
  if (slashIndex >= 0 && slashIndex < pathValue.length - 1) {
    return pathValue.slice(slashIndex + 1);
  }
  return 'community_image.jpg';
}

function resolveUploadMimeType(filename: string): string {
  const normalized = filename.toLowerCase();
  if (normalized.endsWith('.png')) {
    return 'image/png';
  }
  if (normalized.endsWith('.gif')) {
    return 'image/gif';
  }
  if (normalized.endsWith('.webp')) {
    return 'image/webp';
  }
  if (normalized.endsWith('.svg')) {
    return 'image/svg+xml';
  }
  return 'image/jpeg';
}

class CommunityRepository {
  async getCommunityPosts(query: CommunityPostListQuery = {}): Promise<CommunityPostPageDto> {
    hilog.info(
      COMMUNITY_REPO_LOG_DOMAIN,
      COMMUNITY_REPO_LOG_TAG,
      'get community posts pageNo=%{public}d pageSize=%{public}d',
      query.pageNo ?? 1,
      query.pageSize ?? 10
    );
    const response = await communityApi.getCommunityPosts(query);
    return this.unwrapResponse<CommunityPostPageDto>(response, '获取社区帖子列表失败');
  }

  async getMyCommunityPosts(query: CommunityPostListQuery = {}): Promise<CommunityPostPageDto> {
    hilog.info(
      COMMUNITY_REPO_LOG_DOMAIN,
      COMMUNITY_REPO_LOG_TAG,
      'get my community posts pageNo=%{public}d pageSize=%{public}d',
      query.pageNo ?? 1,
      query.pageSize ?? 10
    );
    const response = await communityApi.getMyCommunityPosts(query);
    return this.unwrapResponse<CommunityPostPageDto>(response, '获取我的帖子列表失败');
  }

  async getCommunityPostDetail(postId: string): Promise<CommunityPostDetailDto> {
    if (postId.trim().length === 0) {
      throw new HttpRequestError({
        message: '帖子信息异常，请返回后重试',
        code: 40001
      });
    }

    hilog.info(
      COMMUNITY_REPO_LOG_DOMAIN,
      COMMUNITY_REPO_LOG_TAG,
      'get community post detail postId=%{public}s',
      postId
    );
    const response = await communityApi.getCommunityPostDetail(postId);
    return this.unwrapResponse<CommunityPostDetailDto>(response, '获取帖子详情失败');
  }

  async createCommunityPost(data: CreateCommunityPostRequest): Promise<CreateCommunityPostResponse> {
    hilog.info(
      COMMUNITY_REPO_LOG_DOMAIN,
      COMMUNITY_REPO_LOG_TAG,
      'create community post title=%{public}s contentLength=%{public}d imageCount=%{public}d tagCount=%{public}d',
      data.title ?? '',
      data.content.length,
      data.images?.length ?? 0,
      data.tags?.length ?? 0
    );
    const response = await communityApi.createCommunityPost(data);
    return this.unwrapResponse<CreateCommunityPostResponse>(response, '发布笔记失败');
  }

  async uploadCommunityImage(context: common.BaseContext, fileUri: string): Promise<string> {
    const normalizedUri = fileUri.trim();
    if (normalizedUri.length === 0) {
      throw new HttpRequestError({
        message: '图片路径不能为空',
        code: 40001
      });
    }

    const authorization = await sessionStore.getAuthorizationValue();
    if (authorization.length === 0) {
      throw new HttpRequestError({
        message: '请先登录后再上传图片',
        code: 40100
      });
    }

    hilog.info(
      COMMUNITY_REPO_LOG_DOMAIN,
      COMMUNITY_REPO_LOG_TAG,
      'upload community image uri=%{public}s',
      normalizedUri
    );

    const formData: FormData = new FormData();
    const uploadFileName = resolveUploadFileName(normalizedUri);
    formData.append('file', normalizedUri, {
      filename: uploadFileName,
      type: resolveUploadMimeType(uploadFileName)
    });

    const headers: Record<string, string> = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': authorization
    };
    const config: AxiosRequestConfig<FormData> = {
      headers: headers,
      context: context
    };
    const response: AxiosResponse<string | Object> = await axios.post<string | Object, AxiosResponse<string | Object>, FormData>(
      buildApiUrl(communityApi.getCommunityImageUploadPath()),
      formData,
      config
    );
    const parsedResponse = this.parseApiResponse<UploadCommunityImageResponse>(response.data);
    const data = this.unwrapResponse<UploadCommunityImageResponse>(parsedResponse, '上传图片失败');
    const uploadedUrl = typeof data.url === 'string' ? data.url.trim() : '';
    if (uploadedUrl.length === 0) {
      throw new HttpRequestError({
        message: '上传图片成功但未返回地址',
        code: 50000,
        traceId: parsedResponse.traceId
      });
    }
    return uploadedUrl;
  }

  private parseApiResponse<T>(raw: string | Object): ApiResponse<T> {
    if (typeof raw !== 'string') {
      return raw as ApiResponse<T>;
    }

    const trimmed = raw.trim();
    if (trimmed.length === 0) {
      return {
        code: 50000,
        message: 'Empty response'
      } as ApiResponse<T>;
    }

    try {
      return JSON.parse(trimmed) as ApiResponse<T>;
    } catch (_error) {
      return {
        code: 50000,
        message: trimmed
      } as ApiResponse<T>;
    }
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        COMMUNITY_REPO_LOG_DOMAIN,
        COMMUNITY_REPO_LOG_TAG,
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

export const communityRepository: CommunityRepository = new CommunityRepository();
