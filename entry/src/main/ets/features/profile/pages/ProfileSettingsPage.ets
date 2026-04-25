import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { UiTokens } from '../../../common/constants/UiTokens';
import { sessionStore } from '../../../common/storage/SessionStore';
import { authRepository } from '../../auth/repository/AuthRepository';
import { ProfileMenuSection } from '../components/ProfileMenuSection';
import { PROFILE_SETTING_ITEMS } from '../model/ProfileMockData';

@Entry({ routeName: 'ProfileSettingsPage' })
@Component
export struct ProfileSettingsPage {
  private showActionToast(message: string): void {
    promptAction.showToast({ message });
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private async logout(): Promise<void> {
    try {
      await sessionStore.init(this.getHostContext());
      await authRepository.logout();
      router.replaceUrl({ url: 'features/auth/pages/LoginPage' }, 3000);
    } catch (error) {
      this.showActionToast('退出登录失败，请稍后再试');
    }
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('设置')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('管理账号、安全、通知和反馈入口。')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('返回')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textAccent)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  build() {
    Column() {
      this.buildTopBar();
      Scroll() {
        Column({ space: 18 }) {
          ProfileMenuSection({
            items: PROFILE_SETTING_ITEMS,
            onItemClick: (itemId: string) => {
              if (itemId === 'account') {
                this.showActionToast('账号与安全功能即将上线');
              } else if (itemId === 'notification') {
                this.showActionToast('通知设置功能即将上线');
              } else {
                this.showActionToast('帮助与反馈功能即将上线');
              }
            }
          });

          Button('退出登录', { type: ButtonType.Capsule })
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textInverse)
            .backgroundColor(UiTokens.brandStrong)
            .margin({ top: 4, bottom: 24 })
            .onClick(() => {
              void this.logout();
            });
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 28 })
    .backgroundColor(UiTokens.pageBackground)
    .alignItems(HorizontalAlign.Start);
  }
}
