import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponse, getApiMessage, HttpRequestError, isApiSuccess } from '../../../common/network/ApiResponse';
import { fileUploadApi } from '../api/FileUploadApi';
import {
  FileRecordCreateRequest,
  FileRecordCreateResponse,
  OssPresignRequest,
  OssPresignResponse
} from '../model/FileUploadModels';

const FILE_UPLOAD_LOG_DOMAIN: number = 0x0000;
const FILE_UPLOAD_LOG_TAG: string = 'ShakeProFileUploadRepo';

class FileUploadRepository {
  async getImageUploadPresign(data: OssPresignRequest): Promise<OssPresignResponse> {
    hilog.info(
      FILE_UPLOAD_LOG_DOMAIN,
      FILE_UPLOAD_LOG_TAG,
      'get image upload presign filename=%{public}s contentType=%{public}s size=%{public}d',
      data.filename,
      data.contentType,
      data.size
    );
    const response = await fileUploadApi.getImageUploadPresign(data);
    return this.unwrapResponse<OssPresignResponse>(response, '获取 OSS 上传签名失败');
  }

  async createFileRecord(data: FileRecordCreateRequest): Promise<FileRecordCreateResponse> {
    hilog.info(
      FILE_UPLOAD_LOG_DOMAIN,
      FILE_UPLOAD_LOG_TAG,
      'create file record objectKey=%{public}s contentType=%{public}s size=%{public}d',
      data.objectKey,
      data.contentType,
      data.size
    );
    const response = await fileUploadApi.createFileRecord(data);
    return this.unwrapResponse<FileRecordCreateResponse>(response, '保存文件记录失败');
  }

  private unwrapResponse<T>(response: ApiResponse<T>, fallbackMessage: string): T {
    if (!isApiSuccess(response) || response.data === undefined || response.data === null) {
      hilog.error(
        FILE_UPLOAD_LOG_DOMAIN,
        FILE_UPLOAD_LOG_TAG,
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

export const fileUploadRepository: FileUploadRepository = new FileUploadRepository();
