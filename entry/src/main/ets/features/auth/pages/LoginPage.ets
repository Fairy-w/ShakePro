import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { sessionStore } from '../../../common/storage/SessionStore';
import { authRepository } from '../repository/AuthRepository';

@Entry({ routeName: 'Index' })
@Component
export struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private async login(): Promise<void> {
    const username = this.account.trim();
    const password = this.password;

    if (!username || !password) {
      this.showErrorMessage(this.getResourceString($r('app.string.input_empty_error')));
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
      router.replaceUrl({ url: 'features/home/pages/NavigationPage' });
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
    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }
    return '登录失败';
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private getResourceString(resource: Resource): string {
    return resource.toString();
  }

  @Builder
  private buildInput(label: string, placeholder: string, value: string, isPassword?: boolean) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5F7481');

      TextInput({ placeholder, text: value })
        .height(52)
        .type(isPassword ? InputType.Password : InputType.Normal)
        .backgroundColor('#FFFFFF')
        .fontSize(16)
        .fontColor('#173240')
        .placeholderColor('#91A3AE')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .border({ width: 1, color: '#D7E6ED' })
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
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#F7FBFD', 0.0], ['#EEF5F8', 0.62], ['#E8F1F5', 1.0]]
        });

      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor('#D8EEF4')
        .opacity(0.52)
        .position({ x: -70, y: -40 });

      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 10 }) {
            Text('ShakePro')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#5A7C8D')
              .letterSpacing(1.2);

            Text('登录到智能调酒助手')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#173240');

            Text('继续查看工作台、AI 配方和个人同步内容。')
              .fontSize(13)
              .fontColor('#748591');
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 72 });

          Column({ space: 14 }) {
            this.buildInput('账号', '手机号/邮箱', this.account);
            this.buildInput('密码', '请输入密码', this.password, true);

            Button(this.isLoading ? '登录中...' : '登录')
              .width('100%')
              .height(52)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .enabled(!this.isLoading)
              .fontColor('#124056')
              .backgroundColor('#DDF5F1')
              .borderRadius(18)
              .border({ width: 1, color: '#BFE7E6' })
              .onClick(() => {
                void this.login();
              });

            if (this.isLoading) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color('#2F728A');

                Text('正在同步账号信息...')
                  .fontSize(12)
                  .fontColor('#72838F');
              }
              .width('100%')
              .justifyContent(FlexAlign.Center);
            }

            if (this.errorMessage) {
              Text(this.errorMessage)
                .width('100%')
                .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                .backgroundColor('#FDEFF0')
                .borderRadius(12)
                .fontSize(13)
                .fontColor('#C24A63')
                .textAlign(TextAlign.Center);
            }
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#F7FBFD')
          .borderRadius(24)
          .border({ width: 1, color: '#D7E6ED' });

          Row({ space: 18 }) {
            Text($r('app.string.register_account'))
              .fontSize(14)
              .fontColor('#5D7E8F')
              .onClick(() => {
                router.pushUrl({ url: 'features/auth/pages/RegisterPage' });
              });

            Text('|')
              .fontSize(14)
              .fontColor('#9AAAB4');

            Text($r('app.string.forgot_password'))
              .fontSize(14)
              .fontColor('#5D7E8F');
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 28 });
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 24 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%');
  }
}
