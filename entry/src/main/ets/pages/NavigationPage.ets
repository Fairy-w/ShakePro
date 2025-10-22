import { TabsConcaveCircle } from '../components/tabsConcaveCircle/TabsConcaveCircle';
import { TabMenusInterfaceIRequired } from '../types/TabMenusInterface';
import { router } from '@kit.ArkUI';
import { MainPage } from './MainPage';
import { SecondaryLinkExample } from './SecondaryLinkExample';
import { SlideToHideAndDisplaceComponent } from './SlideToHideAndDisplace';
import { PageLoadingComponent } from './PageLoading';

@Entry ({ routeName: 'NavigationPage' })
@Component
export struct NavigationPage {
  @State title: string = ''
  @State currentIndex: number = 0;
  @State TabsMenu: TabMenusInterfaceIRequired[] = [
    {
      text: $r("app.string.custom_tab_home"),
      image: $r("app.media.tab_home"),
      selectImage: $r("app.media.tab_community"),
      pagePath:'Index'
    },

    {
      text: $r("app.string.custom_tab_news"),
      image: $r("app.media.tab_new"),
      selectImage: $r("app.media.tab_community"),
      pagePath:'LoginPage'
    },

    {
      text: $r("app.string.custom_tab_mine"),
      image: $r("app.media.tab_user"),
      selectImage: $r("app.media.tab_community"),
      pagePath:'LoginPage'
    }
  ];



  private renderContent = (index: number) => {
    // 根据索引渲染不同的内容
    // 这里只是一个示例，您需要根据您的实际内容来实现
    switch (index) {
      case 0:
        // 渲染首页内容

        break;
      case 1:
        // 渲染新闻内容
        break;
      case 2:
        // 渲染我的页面内容
        break;
    // ...其他案例
    }
  };
  build() {

    Column() {
      Row(){
        if (this.currentIndex === 0) {
          PageLoadingComponent()
          // 渲染首页内容
        } else if (this.currentIndex === 1) {
          SecondaryLinkExample()
          // 渲染新闻内容
        } else if (this.currentIndex === 2) {
          // 渲染我的页面内容
          SlideToHideAndDisplaceComponent()
        }
      }
      .height('95%')

      TabsConcaveCircle({
        tabsMenu: this.TabsMenu,
        selectIndex: this.currentIndex,
        renderContent: this.renderContent,
      })

    }
    .height('100%')
    //.hideTitleBar(true)
    .linearGradient({
      direction: GradientDirection.Left,
      repeating: false,
      colors: [[Color.White, 0.0], ['#F1F3F5', 0.0]]
    })
    .justifyContent(FlexAlign.End)





    //   fontSize: 24,
    //   fontWeight: 'bold',
    //   color: 'white',
    //   textAlign: 'center', // 让标题居中
    // },

  }
}