import { TabsConcaveCircle } from '../../../common/components/navigation/TabsConcaveCircle';
import { TabMenusInterfaceIRequired } from '../../../common/types/TabMenusInterface';
import { MainPage } from './HomePage';
import { SecondaryLinkExample } from '../../../legacy/pages/SecondaryLinkExample';
import { SlideToHideAndDisplaceComponent } from '../../../legacy/pages/SlideToHideAndDisplaceDemo';
import { AICocktailPage } from './AICocktailPage';
import { BartendingStationPage } from './BartendingStationPage';

@Entry({ routeName: 'NavigationPage' })
@Component
export struct NavigationPage {
  @State @Watch('handleCurrentIndexChange') currentIndex: number = 0;
  @State isNavigationHidden: boolean = false;
  @State navigationOffsetY: number = 0;
  @State navigationOpacity: number = 1;
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
      text: $r('app.string.custom_tab_ai'),
      image: $r('app.media.tab_new'),
      selectImage: $r('app.media.tab_new'),
      tabsFontColor: '#6D7F8B',
      tabsSelectFontColor: '#18323F',
      pagePath: 'features/home/pages/AICocktailPage'
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
      pagePath: 'legacy/pages/SecondaryLinkExample'
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

  private handleCurrentIndexChange(): void {
    if (this.currentIndex === 1) {
      this.hideNavigationBar();
      return;
    }
    this.showNavigationBar();
  }

  private hideNavigationBar(): void {
    if (this.isNavigationHidden && this.navigationOffsetY > 0) {
      return;
    }
    this.isNavigationHidden = true;
    animateTo({ duration: 260 }, () => {
      this.navigationOffsetY = 120;
      this.navigationOpacity = 0;
    });
  }

  private showNavigationBar(): void {
    if (!this.isNavigationHidden && this.navigationOffsetY === 0 && this.navigationOpacity === 1) {
      return;
    }
    this.isNavigationHidden = false;
    animateTo({ duration: 260 }, () => {
      this.navigationOffsetY = 0;
      this.navigationOpacity = 1;
    });
  }

  private requestShowNavigationBar = () => {
    if (this.currentIndex === 1) {
      this.showNavigationBar();
    }
  };

  private requestHideNavigationBar = () => {
    if (this.currentIndex === 1) {
      this.hideNavigationBar();
    }
  };

  @Builder
  private buildCurrentPage() {
    if (this.currentIndex === 0) {
      MainPage();
    } else if (this.currentIndex === 1) {
      AICocktailPage({
        isNavigationHidden: this.isNavigationHidden,
        onRequestShowNavigation: this.requestShowNavigationBar,
        onRequestHideNavigation: this.requestHideNavigationBar
      });
    } else if (this.currentIndex === 2) {
      BartendingStationPage();
    } else if (this.currentIndex === 3) {
      SecondaryLinkExample();
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
        .clip(!(this.currentIndex === 1 && this.isNavigationHidden))
        .borderRadius(this.currentIndex === 1 && this.isNavigationHidden ? 0 : 28)
        .backgroundColor('#F7FBFD')
        .margin(this.currentIndex === 1 && this.isNavigationHidden ? { left: 0, right: 0, top: 0 } :
          { left: 12, right: 12, top: 12 });

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
          .margin({ left: 16, right: 16, bottom: 18 })
          .translate({ x: 0, y: this.navigationOffsetY })
          .opacity(this.navigationOpacity);
      }
      .width('100%')
      .height('100%')
      .padding(this.currentIndex === 1 && this.isNavigationHidden ? { top: 0, bottom: 0 } : { top: 6, bottom: 4 });
    }
    .width('100%')
    .height('100%');
  }
}
