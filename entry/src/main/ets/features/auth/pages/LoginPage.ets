import { RoutePaths } from '../../../core/router/RoutePaths';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { authRepository } from '../repository/AuthRepository';

@Entry({ routeName: 'Index' })
@Component
export struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State isCheckingSession: boolean = true;

  aboutToAppear(): void {
    void this.restoreSessionIfAvailable();
  }

  private async restoreSessionIfAvailable(): Promise<void> {
    try {
      await sessionStore.init(this.getHostContext());
      const authorization = await sessionStore.getAuthorizationValue();
      if (authorization.trim().length > 0) {
        router.replaceUrl({ url: RoutePaths.NAVIGATION });
        return;
      }
    } catch (_) {
      // Ignore persisted-session restore errors and keep the login page usable.
    } finally {
      this.isCheckingSession = false;
    }
  }

  private async login(): Promise<void> {
    const username = this.account.trim();
    const password = this.password;

    if (!username || !password) {
      this.showErrorMessage('请输入用户名和密码');
      return;
    }

    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      await sessionStore.init(this.getHostContext());
      await authRepository.login({
        username,
        password
      });
      router.replaceUrl({ url: RoutePaths.NAVIGATION });
    } catch (error) {
      this.showErrorMessage(this.resolveErrorMessage(error));
    } finally {
      this.isLoading = false;
    }
  }

  private showErrorMessage(message: string): void {
    this.errorMessage = message;
    promptAction.showToast({ message });
  }

  private resolveErrorMessage(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    const code = errorObject['code'];
    if (typeof code === 'number' && code === 400) {
      return '用户名或密码格式不正确';
    }
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, '登录失败，请检查用户名和密码后重试');
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  @Builder
  private buildFloatingAccent(width: number, height: number, color: string, opacity: number, x: number, y: number) {
    Column()
      .width(width)
      .height(height)
      .borderRadius(width / 2)
      .backgroundColor(color)
      .opacity(opacity)
      .position({ x, y });
  }

  @Builder
  private buildInput(label: string, placeholder: string, value: string, isPassword: boolean = false) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textSecondary);

      TextInput({ placeholder, text: value })
        .width('100%')
        .height(52)
        .type(isPassword ? InputType.Password : InputType.Normal)
        .backgroundColor(UiTokens.surfacePrimary)
        .fontSize(15)
        .fontColor(UiTokens.textPrimary)
        .placeholderColor(UiTokens.textTertiary)
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .border({ width: 1, color: UiTokens.borderPrimary })
        .onChange((text: string) => {
          if (isPassword) {
            this.password = text;
          } else {
            this.account = text;
          }
        });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.56], [UiTokens.pageGradientEnd, 1.0]]
        });

      this.buildFloatingAccent(250, 250, UiTokens.pageAccentBlue, 0.26, -72, -36);
      this.buildFloatingAccent(210, 210, UiTokens.pageAccentMint, 0.22, 248, 148);
      this.buildFloatingAccent(170, 170, UiTokens.accentWarmSoft, 0.28, 192, 490);

      Scroll() {
        Column({ space: 18 }) {
          if (this.isCheckingSession) {
            Column({ space: 12 }) {
              LoadingProgress()
                .width(24)
                .height(24)
                .color(UiTokens.aiPrimary);

              Text('正在恢复登录状态...')
                .fontSize(13)
                .fontColor(UiTokens.textSecondary);
            }
            .width('100%')
            .padding({ top: 48, bottom: 48 })
            .backgroundColor(UiTokens.surfacePrimary)
            .borderRadius(24)
            .border({ width: 1, color: UiTokens.borderPrimary })
            .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });
          } else {
            Column({ space: 16 }) {
              Column({ space: 8 }) {
                Text('SHAKEPRO ACCESS')
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(UiTokens.textAccent)
                  .letterSpacing(1.6);

                Text('登录到智能调酒助手')
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(UiTokens.textPrimary);

                Text('继续查看工作台、AI 配方和个人同步内容。')
                  .fontSize(13)
                  .fontColor(UiTokens.textSecondary)
                  .lineHeight(20);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 56 });

              Column({ space: 14 }) {
                this.buildInput('账号', '请输入用户名', this.account);
                this.buildInput('密码', '请输入密码', this.password, true);

                Button(this.isLoading ? '登录中...' : '登录')
                  .width('100%')
                  .height(52)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .enabled(!this.isLoading)
                  .fontColor(UiTokens.textInverse)
                  .backgroundColor(UiTokens.brandStrong)
                  .borderRadius(18)
                  .onClick(() => {
                    void this.login();
                  });

                if (this.isLoading) {
                  Row({ space: 8 }) {
                    LoadingProgress()
                      .width(15)
                      .height(15)
                      .color(UiTokens.aiPrimary);

                    Text('正在同步账号信息...')
                      .fontSize(12)
                      .fontColor(UiTokens.textSecondary);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center);
                }

                if (this.errorMessage.length > 0) {
                  Text(this.errorMessage)
                    .width('100%')
                    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                    .backgroundColor(UiTokens.errorSoft)
                    .borderRadius(12)
                    .border({ width: 1, color: UiTokens.borderWarm })
                    .fontSize(13)
                    .fontColor(UiTokens.error)
                    .textAlign(TextAlign.Center);
                }
              }
              .width('100%')
              .padding({ left: 18, right: 18, top: 18, bottom: 18 })
              .backgroundColor(UiTokens.surfaceWarm)
              .borderRadius(24)
              .border({ width: 1, color: UiTokens.borderWarm })
              .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });

              Row({ space: 10 }) {
                Text('注册账号')
                  .fontSize(14)
                  .fontColor(UiTokens.textSecondary)
                  .onClick(() => {
                    router.pushUrl({ url: RoutePaths.REGISTER });
                  });

                Text('·')
                  .fontSize(14)
                  .fontColor(UiTokens.textTertiary);

                Text('忘记密码')
                  .fontSize(14)
                  .fontColor(UiTokens.textSecondary);
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 28 });
            }
            .width('100%');
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground);
  }
}
