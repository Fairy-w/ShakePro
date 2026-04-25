import { COMMUNITY_MY_POSTS_PATH, COMMUNITY_POSTS_PATH, COMMUNITY_UPLOAD_IMAGE_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  CommunityPostDetailDto,
  CommunityPostListQuery,
  CommunityPostPageDto,
  CreateCommunityPostRequest,
  CreateCommunityPostResponse,
  UploadCommunityImageResponse
} from '../model/CommunityApiModels';

class CommunityApi {
  getCommunityPosts(query: CommunityPostListQuery = {}): Promise<ApiResponse<CommunityPostPageDto>> {
    const queryObj: CommunityPostListQuery = {
      pageNo: query.pageNo,
      pageSize: query.pageSize
    };
    const options: HttpRequestOptions = {
      query: queryObj as Record<string, string | number | boolean | undefined | null>
    };
    return httpClient.get<CommunityPostPageDto>(COMMUNITY_POSTS_PATH, options);
  }

  getMyCommunityPosts(query: CommunityPostListQuery = {}): Promise<ApiResponse<CommunityPostPageDto>> {
    const queryObj: CommunityPostListQuery = {
      pageNo: query.pageNo,
      pageSize: query.pageSize
    };
    const options: HttpRequestOptions = {
      attachToken: true,
      query: queryObj as Record<string, string | number | boolean | undefined | null>
    };
    return httpClient.get<CommunityPostPageDto>(COMMUNITY_MY_POSTS_PATH, options);
  }

  getCommunityPostDetail(postId: string): Promise<ApiResponse<CommunityPostDetailDto>> {
    return httpClient.get<CommunityPostDetailDto>(COMMUNITY_POSTS_PATH + '/' + encodeURIComponent(postId));
  }
  createCommunityPost(data: CreateCommunityPostRequest): Promise<ApiResponse<CreateCommunityPostResponse>> {
    const options: HttpRequestOptions = {
      attachToken: true,
      data: data
    } as HttpRequestOptions;
    return httpClient.post<CreateCommunityPostResponse>(COMMUNITY_POSTS_PATH, options);
  }

  getCommunityImageUploadPath(): string {
    return COMMUNITY_UPLOAD_IMAGE_PATH;
  }

  createEmptyUploadResponse(): UploadCommunityImageResponse {
    return {
      url: ''
    } as UploadCommunityImageResponse;
  }
}

export const communityApi: CommunityApi = new CommunityApi();
