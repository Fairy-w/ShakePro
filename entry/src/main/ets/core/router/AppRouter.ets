import router from '@ohos.router';

export class AppRouter {
  static push(url: string, mode?: number): void {
    if (mode === undefined) {
      router.pushUrl({ url });
      return;
    }
    router.pushUrl({ url }, mode);
  }

  static replace(url: string, mode?: number): void {
    if (mode === undefined) {
      router.replaceUrl({ url });
      return;
    }
    router.replaceUrl({ url }, mode);
  }

  static back(): void {
    router.back();
  }
}
