import { scanCore } from '@kit.ScanKit';

export interface ScanResult {
  originalValue: string;
}

export interface Position {
  x: number;
  y: number;
}

export interface ScanOptions {
  scanTypes: scanCore.ScanType[];
  enableMultiMode: boolean;
  enableAlbum: boolean;
}

export interface ViewControl {
  width: number;
  height: number;
  surfaceId: string;
}
