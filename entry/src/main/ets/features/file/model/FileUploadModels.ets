export interface OssPresignRequest {
  filename: string;
  contentType: string;
  size: number;
}

export interface OssPresignResponse {
  uploadUrl: string;
  objectKey: string;
  publicUrl: string;
  expireSeconds?: number;
}

export interface FileRecordCreateRequest {
  objectKey: string;
  url: string;
  contentType: string;
  size: number;
}

export interface FileRecordCreateResponse {
  fileId: number;
}
