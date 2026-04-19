import { TabsConcaveCircle } from '../../../common/components/navigation/TabsConcaveCircle';
import { UiTokens } from '../../../common/constants/UiTokens';
import { TabMenusInterfaceIRequired } from '../../../common/types/TabMenusInterface';
import { MyFavoritePage } from '../../favorite/pages/MyFavoritePage';
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
      pagePath: 'features/home/pages/HomePage'
    },
    {
      text: $r('app.string.custom_tab_bar'),
      image: $r('app.media.img_1'),
      selectImage: $r('app.media.img_1'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: 'features/home/pages/BartendingStationPage'
    },
    {
      text: $r('app.string.custom_tab_news'),
      image: $r('app.media.img'),
      selectImage: $r('app.media.img'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: 'features/recipe/pages/RecipeLibraryPage'
    },
    {
      text: $r('app.string.custom_tab_mine'),
      image: $r('app.media.tab_user'),
      selectImage: $r('app.media.tab_user'),
      tabsFontColor: UiTokens.textSecondary,
      tabsSelectFontColor: UiTokens.textPrimary,
      pagePath: 'features/favorite/pages/MyFavoritePage'
    }
  ];

  private renderContent = (index: number) => {
    this.currentIndex = index;
  };

  @Builder
  private buildCurrentPage() {
    if (this.currentIndex === 0) {
      MainPage();
    } else if (this.currentIndex === 1) {
      BartendingStationPage();
    } else if (this.currentIndex === 2) {
      RecipeLibraryPage();
    } else {
      MyFavoritePage();
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
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor(UiTokens.pageAccentBlue)
        .opacity(0.52)
        .position({ x: -70, y: -36 });

      Column()
        .width(220)
        .height(220)
        .borderRadius(110)
        .backgroundColor(UiTokens.pageAccentMint)
        .opacity(0.72)
        .position({ x: 250, y: 600 });

      Stack({ alignContent: Alignment.Bottom }) {
        Stack() {
          this.buildCurrentPage();
        }
        .width('100%')
        .height('100%')
        .borderRadius(UiTokens.radiusXl)
        .backgroundColor(UiTokens.pageGradientStart)
        .margin({ left: 12, right: 12, top: 12 });

        TabsConcaveCircle({
          tabsMenu: this.tabsMenu,
          selectIndex: this.currentIndex,
          renderContent: this.renderContent,
          tabsBgColor: UiTokens.surfacePrimary,
          tabsSelectBgColor: UiTokens.aiSoft,
          tabsFontColor: UiTokens.textSecondary,
          tabsSelectFontColor: UiTokens.textPrimary,
          tabHeight: 82
        })
          .margin({ left: 16, right: 16, bottom: 18 });
      }
      .width('100%')
      .height('100%')
      .padding({ top: 6, bottom: 4 });
    }
    .width('100%')
    .height('100%');
  }
}
