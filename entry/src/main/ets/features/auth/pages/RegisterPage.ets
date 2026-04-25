import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { authRepository } from '../repository/AuthRepository';

@Entry({ routeName: 'RegisterPage' })
@Component
export struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State nickname: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private async register(): Promise<void> {
    const validationMessage = this.validateForm();
    if (validationMessage) {
      this.showMessage(validationMessage, true);
      return;
    }

    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const nickname: string = this.nickname.trim();
      await authRepository.register({
        username: this.username.trim(),
        password: this.password,
        nickname: nickname.length > 0 ? nickname : undefined
      });

      this.showMessage('注册成功，请前往登录', false);
      router.replaceUrl({ url: 'features/auth/pages/LoginPage' });
    } catch (error) {
      this.showMessage(this.resolveErrorMessage(error), true);
    } finally {
      this.isLoading = false;
    }
  }

  private validateForm(): string {
    const username = this.username.trim();
    const password = this.password;
    const nickname = this.nickname.trim();

    if (!username || !password) {
      return '请输入用户名和密码，昵称可选';
    }
    if (username.length < 3 || username.length > 50) {
      return '用户名长度需在 3 到 50 个字符之间';
    }
    if (password.length < 6 || password.length > 50) {
      return '密码长度需在 6 到 50 个字符之间';
    }
    if (nickname.length > 50) {
      return '昵称最多 50 个字符，可留空';
    }

    return '';
  }

  private showMessage(message: string, isError: boolean): void {
    this.errorMessage = isError ? message : '';
    promptAction.showToast({ message });
  }

  private resolveErrorMessage(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    const code = errorObject['code'];
    if (typeof code === 'number' && code === 400) {
      return '注册信息格式不正确，请检查后重试';
    }
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, '注册失败，请检查用户名和密码格式后重试');
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
  private buildInput(
    label: string,
    placeholder: string,
    field: string,
    fieldKey: 'username' | 'password' | 'nickname',
    isPassword: boolean = false
  ) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textSecondary);

      TextInput({ placeholder, text: field })
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
        .onChange((value: string) => {
          if (fieldKey === 'username') {
            this.username = value;
          } else if (fieldKey === 'password') {
            this.password = value;
          } else {
            this.nickname = value;
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

      this.buildFloatingAccent(236, 236, UiTokens.pageAccentMint, 0.24, 228, -40);
      this.buildFloatingAccent(198, 198, UiTokens.pageAccentBlue, 0.22, -62, 150);
      this.buildFloatingAccent(154, 154, UiTokens.accentWarmSoft, 0.3, 188, 520);

      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 8 }) {
            Text('SHAKEPRO ACCOUNT')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiTokens.textAccent)
              .letterSpacing(1.6);

            Text('创建账号')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(UiTokens.textPrimary);

            Text('注册后可使用 AI 配方、工作台和资料同步。')
              .fontSize(13)
              .fontColor(UiTokens.textSecondary)
              .lineHeight(20);
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 56 });

          Column({ space: 14 }) {
            this.buildInput('用户名', '请输入用户名（3-50个字符）', this.username, 'username');
            this.buildInput('密码', '请输入密码（6-50个字符）', this.password, 'password', true);
            this.buildInput('昵称（选填）', '请输入昵称（可留空）', this.nickname, 'nickname');

            Button(this.isLoading ? '注册中...' : '立即注册')
              .width('100%')
              .height(52)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .enabled(!this.isLoading)
              .fontColor(UiTokens.textInverse)
              .backgroundColor(UiTokens.brandStrong)
              .borderRadius(18)
              .onClick(() => {
                void this.register();
              });

            if (this.isLoading) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(15)
                  .height(15)
                  .color(UiTokens.aiPrimary);

                Text('正在创建账号...')
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

          Row({ space: 8 }) {
            Text('已有账号？')
              .fontSize(14)
              .fontColor(UiTokens.textSecondary);

            Text('去登录')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiTokens.textAccent)
              .onClick(() => {
                router.replaceUrl({ url: 'features/auth/pages/LoginPage' });
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 28 });
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
