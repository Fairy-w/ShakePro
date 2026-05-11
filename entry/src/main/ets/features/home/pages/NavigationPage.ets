import { RoutePaths } from '../../../core/router/RoutePaths';
import { FloatingDock } from '../../../common/components/navigation/FloatingDock';
import { UiTokens } from '../../../common/constants/UiTokens';
import { TabMenusInterfaceIRequired } from '../../../common/types/TabMenusInterface';
import { CommunityPage } from '../../community/pages/CommunityPage';
import { ProfilePage } from '../../profile/pages/ProfilePage';
import { RecipeLibraryPage } from '../../recipe/pages/RecipeLibraryPage';
import { BartendingStationPage } from './BartendingStationPage';
import { MainPage } from './HomePage';

@Entry({ routeName: 'NavigationPage' })
@Component
export struct NavigationPage {
  @State currentIndex: number = 0;
  @State tabsMenu: TabMenusInterfaceIRequired[] = [
    {
      text: $r('app.string.custom_tab_home'),
      image: $r('app.media.tab_home'),
      selectImage: $r('app.media.tab_home'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: RoutePaths.HOME
    },
    {
      text: $r('app.string.custom_tab_bar'),
      image: $r('app.media.icon1'),
      selectImage: $r('app.media.icon1'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: RoutePaths.BARTENDING_STATION
    },
    {
      text: $r('app.string.custom_tab_news'),
      image: $r('app.media.icon2'),
      selectImage: $r('app.media.icon2'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: RoutePaths.RECIPE_LIBRARY
    },
    {
      text: $r('app.string.custom_tab_friend'),
      image: $r('app.media.icon3'),
      selectImage: $r('app.media.icon3'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: RoutePaths.COMMUNITY
    },
    {
      text: $r('app.string.custom_tab_mine'),
      image: $r('app.media.tab_user'),
      selectImage: $r('app.media.tab_user'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: RoutePaths.PROFILE
    }
  ];

  private renderContent = (index: number) => {
    this.currentIndex = index;
  };

  @Builder
  private buildCurrentPage() {
    if (this.currentIndex === 0) {
      MainPage({ pageBottomInset: UiTokens.dockPageInset });
    } else if (this.currentIndex === 1) {
      BartendingStationPage({
        floatingActionBottomInset: UiTokens.stationFloatingBarInset,
        contentBottomInset: UiTokens.stationContentBottomInset
      });
    } else if (this.currentIndex === 2) {
      RecipeLibraryPage({ pageBottomInset: UiTokens.dockPageInset });
    } else if (this.currentIndex === 3) {
      CommunityPage({ pageBottomInset: UiTokens.dockPageInset });
    } else {
      ProfilePage({ pageBottomInset: UiTokens.dockPageInset });
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.56], [UiTokens.pageGradientEnd, 1.0]]
        });

      Column()
        .width(200)
        .height(240)
        .borderRadius(48)
        .backgroundColor(UiTokens.pageAccentBlue)
        .opacity(0.46)
        .position({ x: -44, y: -18 });

      Column()
        .width(240)
        .height(176)
        .borderRadius(44)
        .backgroundColor(UiTokens.surfaceWarmAlt)
        .opacity(0.88)
        .position({ x: 178, y: 632 });

      Stack({ alignContent: Alignment.Bottom }) {
        Stack() {
          this.buildCurrentPage();
        }
        .width('100%')
        .height('100%');

        FloatingDock({
          items: this.tabsMenu,
          selectedIndex: this.currentIndex,
          renderContent: this.renderContent,
          dockHeight: UiTokens.dockHeight
        })
          .margin({
            left: UiTokens.dockHorizontalMargin,
            right: UiTokens.dockHorizontalMargin,
            bottom: UiTokens.dockBottomMargin
          });
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%');
  }
}
