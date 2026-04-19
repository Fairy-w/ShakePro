import { FILES_PATH, OSS_PRESIGN_PATH } from '../../../common/constants/ApiConfig';
import { ApiResponse } from '../../../common/network/ApiResponse';
import { httpClient, HttpRequestOptions } from '../../../common/network/HttpClient';
import {
  FileRecordCreateRequest,
  FileRecordCreateResponse,
  OssPresignRequest,
  OssPresignResponse
} from '../model/FileUploadModels';

class FileUploadApi {
  getImageUploadPresign(data: OssPresignRequest): Promise<ApiResponse<OssPresignResponse>> {
    return httpClient.post<OssPresignResponse>(OSS_PRESIGN_PATH, {
      attachToken: true,
      data: data
    } as HttpRequestOptions);
  }

  createFileRecord(data: FileRecordCreateRequest): Promise<ApiResponse<FileRecordCreateResponse>> {
    return httpClient.post<FileRecordCreateResponse>(FILES_PATH, {
      attachToken: true,
      data: data
    } as HttpRequestOptions);
  }
}

export const fileUploadApi: FileUploadApi = new FileUploadApi();
