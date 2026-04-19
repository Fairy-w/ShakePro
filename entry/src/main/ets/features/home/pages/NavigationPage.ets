import { TabsConcaveCircle } from '../../../common/components/navigation/TabsConcaveCircle';
import { TabMenusInterfaceIRequired } from '../../../common/types/TabMenusInterface';
import { MainPage } from './HomePage';
import { SlideToHideAndDisplaceComponent } from '../../../legacy/pages/SlideToHideAndDisplaceDemo';
import { BartendingStationPage } from './BartendingStationPage';
import { RecipeLibraryPage } from '../../recipe/pages/RecipeLibraryPage';

@Entry({ routeName: 'NavigationPage' })
@Component
export struct NavigationPage {
  @State currentIndex: number = 0;
  @State tabsMenu: TabMenusInterfaceIRequired[] = [
    {
      text: $r('app.string.custom_tab_home'),
      image: $r('app.media.tab_home'),
      selectImage: $r('app.media.tab_home'),
      tabsFontColor: '#6D7F8B',
      tabsSelectFontColor: '#18323F',
      pagePath: 'features/home/pages/HomePage'
    },
    {
      text: $r('app.string.custom_tab_bar'),
      image: $r('app.media.tab_community'),
      selectImage: $r('app.media.tab_community'),
      tabsFontColor: '#6D7F8B',
      tabsSelectFontColor: '#18323F',
      pagePath: 'features/home/pages/BartendingStationPage'
    },
    {
      text: $r('app.string.custom_tab_news'),
      image: $r('app.media.news'),
      selectImage: $r('app.media.news'),
      tabsFontColor: '#6D7F8B',
      tabsSelectFontColor: '#18323F',
      pagePath: 'features/recipe/pages/RecipeLibraryPage'
    },
    {
      text: $r('app.string.custom_tab_mine'),
      image: $r('app.media.tab_user'),
      selectImage: $r('app.media.tab_user'),
      tabsFontColor: '#6D7F8B',
      tabsSelectFontColor: '#18323F',
      pagePath: 'legacy/pages/SlideToHideAndDisplaceDemo'
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
      SlideToHideAndDisplaceComponent();
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
          colors: [['#F7FBFD', 0.0], ['#EEF5F8', 0.56], ['#E9F1F5', 1.0]]
        });

      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor('#D8EEF4')
        .opacity(0.52)
        .position({ x: -70, y: -36 });

      Column()
        .width(220)
        .height(220)
        .borderRadius(110)
        .backgroundColor('#DDF5F1')
        .opacity(0.72)
        .position({ x: 250, y: 600 });

      Stack({ alignContent: Alignment.Bottom }) {
        Stack() {
          this.buildCurrentPage();
        }
        .width('100%')
        .height('100%')
        .borderRadius(28)
        .backgroundColor('#F7FBFD')
        .margin({ left: 12, right: 12, top: 12 });

        TabsConcaveCircle({
          tabsMenu: this.tabsMenu,
          selectIndex: this.currentIndex,
          renderContent: this.renderContent,
          tabsBgColor: '#FFFFFF',
          tabsSelectBgColor: '#DDF5F1',
          tabsFontColor: '#6D7F8B',
          tabsSelectFontColor: '#18323F',
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
