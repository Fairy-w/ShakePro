import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { sessionStore } from '../../../common/storage/SessionStore';
import { ProfileHeroCard } from '../components/ProfileHeroCard';
import { ProfileMenuSection } from '../components/ProfileMenuSection';
import { PROFILE_OVERVIEW, PROFILE_SHORTCUTS, ProfileMenuItem } from '../model/ProfileMockData';

@Entry({ routeName: 'Mine' })
@Component
export struct ProfilePage {
  @Prop pageBottomInset: number = 0;
  private readonly shortcutItems: ProfileMenuItem[] = PROFILE_SHORTCUTS;
  @State private profileDisplayName: string = PROFILE_OVERVIEW.displayName;

  aboutToAppear(): void {
    void this.refreshProfileOverview();
  }

  onPageShow(): void {
    void this.refreshProfileOverview();
  }

  private resolvePageBottomInset(): number {
    return this.pageBottomInset > 0 ? this.pageBottomInset : 32;
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

  private resolveUsernameFromRawProfile(rawProfile: string): string {
    if (rawProfile.trim().length === 0) {
      return '';
    }

    try {
      const parsed = JSON.parse(rawProfile) as Record<string, Object>;
      const usernameValue = parsed['username'];
      if (typeof usernameValue === 'string') {
        return usernameValue.trim();
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  private async refreshProfileOverview(): Promise<void> {
    try {
      await sessionStore.init(this.getHostContext());
      const rawProfile: string = await sessionStore.getUserProfile();
      const username: string = this.resolveUsernameFromRawProfile(rawProfile);
      if (username.length === 0) {
        this.profileDisplayName = PROFILE_OVERVIEW.displayName;
        return;
      }

      this.profileDisplayName = username;
    } catch (_) {
      this.profileDisplayName = PROFILE_OVERVIEW.displayName;
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.55], [UiTokens.pageGradientEnd, 1.0]]
        });

      this.buildFloatingAccent(260, 260, UiTokens.pageAccentBlue, 0.22, -94, -40);
      this.buildFloatingAccent(210, 210, UiTokens.pageAccentMint, 0.2, 248, 176);
      this.buildFloatingAccent(180, 180, UiTokens.accentWarmSoft, 0.22, 168, 508);

      Scroll() {
        Column({ space: 18 }) {
          ProfileHeroCard({
            avatar: PROFILE_OVERVIEW.avatar,
            displayName: this.profileDisplayName
          });

          ProfileMenuSection({
            title: '我的',
            items: this.shortcutItems,
            onItemClick: (itemId: string) => {
              if (itemId === 'favorite-page') {
                router.pushUrl({ url: 'features/favorite/pages/MyFavoritePage' }, 3000);
              } else if (itemId === 'my-posts') {
                router.pushUrl({ url: 'features/profile/pages/ProfilePostsPage' }, 3000);
              } else {
                router.pushUrl({ url: 'features/profile/pages/ProfileSettingsPage' }, 3000);
              }
            }
          });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16, top: 20, bottom: this.resolvePageBottomInset() })
        .constraintSize({ minHeight: '100%' })
        .justifyContent(FlexAlign.Start);
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
