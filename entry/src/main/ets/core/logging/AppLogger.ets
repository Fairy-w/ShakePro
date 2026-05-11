import { hilog } from '@kit.PerformanceAnalysisKit';

export class AppLogger {
  static readonly DOMAIN: number = 0x0000;

  static info(tag: string, format: string, ...args: Array<string | number | boolean | Object>): void {
    hilog.info(AppLogger.DOMAIN, tag, format, ...args);
  }

  static warn(tag: string, format: string, ...args: Array<string | number | boolean | Object>): void {
    hilog.warn(AppLogger.DOMAIN, tag, format, ...args);
  }

  static error(tag: string, format: string, ...args: Array<string | number | boolean | Object>): void {
    hilog.error(AppLogger.DOMAIN, tag, format, ...args);
  }
}
