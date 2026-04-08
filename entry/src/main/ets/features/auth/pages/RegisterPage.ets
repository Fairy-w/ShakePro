import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
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
      await authRepository.register({
        username: this.username.trim(),
        password: this.password,
        nickname: this.nickname.trim()
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

    if (!username || !password || !nickname) {
      return '请输入用户名、密码和昵称';
    }
    if (username.length < 3 || username.length > 50) {
      return '用户名长度需在3到50个字符之间';
    }
    if (password.length < 6 || password.length > 50) {
      return '密码长度需在6到50个字符之间';
    }
    if (nickname.length > 50) {
      return '昵称长度不能超过50个字符';
    }

    return '';
  }

  private showMessage(message: string, isError: boolean): void {
    this.errorMessage = isError ? message : '';
    promptAction.showToast({ message });
  }

  private resolveErrorMessage(error: Object): string {
    try {
      const errorObj = error as Record<string, string>;
      if (errorObj && errorObj.message && typeof errorObj.message === 'string') {
        const message = errorObj.message.trim();
        if (message.length > 0) {
          return message;
        }
      }
    } catch {
    }
    return '注册失败';
  }

  @Builder
  private buildInput(label: string, placeholder: string, field: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5F7481');

      TextInput({ placeholder, text: field })
        .height(52)
        .type(label === '密码' ? InputType.Password : InputType.Normal)
        .backgroundColor('#FFFFFF')
        .fontSize(16)
        .fontColor('#173240')
        .placeholderColor('#91A3AE')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .border({ width: 1, color: '#D7E6ED' })
        .onChange((value: string) => {
          if (label === '用户名') {
            this.username = value;
          } else if (label === '密码') {
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
        .width(220)
        .height(220)
        .borderRadius(110)
        .backgroundColor('#DDF5F1')
        .opacity(0.74)
        .position({ x: 250, y: -30 });

      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 10 }) {
            Text('创建账号')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#173240');

            Text('注册后可使用 AI 配方、工作台和资料同步。')
              .fontSize(13)
              .fontColor('#748591');
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 72 });

          Column({ space: 14 }) {
            this.buildInput('用户名', '请输入用户名', this.username);
            this.buildInput('密码', '请输入密码', this.password);
            this.buildInput('昵称', '请输入昵称', this.nickname);

            Button(this.isLoading ? '注册中...' : '立即注册')
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
                void this.register();
              });

            if (this.isLoading) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color('#2F728A');

                Text('正在创建账号...')
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

          Row({ space: 8 }) {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#5F7E8F');

            Text('去登录')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2C7288')
              .onClick(() => {
                router.replaceUrl({ url: 'features/auth/pages/LoginPage' });
              });
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
