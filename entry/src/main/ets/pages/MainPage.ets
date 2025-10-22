import ItemData from '../viewmodel/ItemData'
import MainViewModel from '../viewmodel/MainViewModel'
import { router } from '@kit.ArkUI';

@Entry ({ routeName: 'MainPage' })
@Component
export struct MainPage {
  @State message: string = 'Hello World';
  private swiperController: SwiperController = new SwiperController();



  build() {



    Scroll(){
      Column({space : 16}){
        /* 标题 */
        Row(){
          Image($r('app.media.icon_cocktail'))
            .width(38)
            .height(38)
          TextInput({placeholder:$r('app.string.search_interesting_content')})
            .width('90%')
            .height(40)
            .margin({top:10})

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        /* 广告轮播 */
        Swiper(this.swiperController){
          ForEach(MainViewModel.getSwiperImages(),(img : Resource)=>{
            Image(img)
              .width('100%')  // 设置固定宽度
              .height(200) // 设置固定高度
              .borderRadius(16)
              .objectFit(ImageFit.Cover) // 保持图片比例，裁剪超出部分
          })
        }

        .autoPlay(true)
        Blank()

        /* Grid分类 */
        Grid(){
          ForEach(MainViewModel.getFirstGirdData(),(item: ItemData)=>{
            GridItem(){
              Column(){
                Image(item.img)
                  .width(65)
                  .height(65)
                  .onClick(() => {
                    let title : string;
                    title = this.ResourceToString(item.title);
                    console.info(`Clicked item: ${title}`);
                    this.navigateToPage(title);
                  });

                Text(item.title)
                  .fontSize(15)
                  .margin({top:4})

              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')  //划分为三列
        .rowsTemplate('1fr 1fr')
        .rowsGap(10) //行间距
        .columnsGap(8)  //列间距
        .backgroundColor(Color.White)
        .borderRadius(24)
        .padding({top:10,bottom:10})
        .height(204)

        Row(){
          /* 列表标题 */
          Text($r('app.string.list'))
            .fontSize(16)

            .width('100%')
            .margin({top:5})
          Text('查看全部 >')
            .fontSize(10)  // 字体大小
            .fontColor(Color.Gray)  // 设置为灰色

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)  // 两端对齐
        .alignItems(VerticalAlign.Bottom)  // 下端对齐
        .padding({ left:5, right: 55 })



        Grid(){
          ForEach(MainViewModel.getSecondGridData(),(secondItem: ItemData)=>{
            GridItem(){
              Column(){
                Text(secondItem.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(secondItem.others)
                  .margin({top:4})
                  .fontSize(8)
                  .fontColor('#99182431')
              }
              .alignItems(HorizontalAlign.Start)
            }
            .padding({top:8,left:8})
            .borderRadius(12)
            .align(Alignment.TopStart)
            .backgroundImage(secondItem.img)
            .backgroundImageSize(ImageSize.Cover)
            .width('100%')
            .height('100%')
          })
        }
        .width('100%')
        .height(260)
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr')
        .columnsGap(8)
        .rowsGap(12)
        .margin({bottom:55})


      }
    }
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor('#F1F3F5')
    .padding({left:12,right:12})



    // TabsConcaveCircle({
    //   tabsMenu: this.TabsMenu,
    //   selectIndex: this.currentIndex,
    // })




  }

  private navigateToPage(title: string) {

    let targetUrl = '';
    switch (title) {
      case '我的鸡尾酒':
        targetUrl = 'pages/MyCocktail';
        break;
      case '选择材料':
        targetUrl = 'pages/PhotoPage';
        break;

    }

    console.info(`Attempting to navigate to: ${targetUrl}`);

    router.pushUrl({
      url: targetUrl,
    },3000);

    console.info(`Navigating to ${targetUrl} with title: ${title}`);
  }


  ResourceToString(resource:Resource):string{
    return getContext(this).resourceManager.getStringSync(resource)
  }

  // @Builder
  // PageMap(name: string) {
  //   if (name === 'LoginPage') {
  //     LoginPage()
  //   }
  //
  // }
  // build() {
  //   Navigation(this.pageStack) {
  //     Scroll() {
  //       Column() {
  //         /* 标题 */
  //         Row() {
  //           Image($r('app.media.icon_cocktail'))
  //             .width(38)
  //             .height(38)
  //           TextInput({ placeholder: $r('app.string.search_interesting_content') })
  //             .width('90%')
  //             .height(40)
  //             .margin({ top: 10 })
  //
  //         }
  //         .width('100%')
  //         .justifyContent(FlexAlign.SpaceBetween)
  //
  //         /* 广告轮播 */
  //         Swiper(this.swiperController) {
  //           ForEach(MainViewModel.getSwiperImages(), (img: Resource) => {
  //             Image(img)
  //               .width('100%')// 设置固定宽度
  //               .height(200)// 设置固定高度
  //               .borderRadius(16)
  //               .objectFit(ImageFit.Cover) // 保持图片比例，裁剪超出部分
  //           })
  //         }
  //
  //         .autoPlay(true)
  //
  //         Blank()
  //
  //         /* Grid分类 */
  //         Grid() {
  //           ForEach(MainViewModel.getFirstGirdData(), (item: ItemData) => {
  //             GridItem() {
  //               Column() {
  //                 Image(item.img)
  //                   .width(65)
  //                   .height(65)
  //                 Text(item.title)
  //                   .fontSize(15)
  //                   .margin({ top: 4 })
  //               }
  //               .onClick(()=>{
  //                 this.pageStack.pushPathByName('LoginPage',item.title)
  //               })
  //             }
  //           })
  //         }
  //         .columnsTemplate('1fr 1fr 1fr') //划分为三列
  //         .rowsTemplate('1fr 1fr')
  //         .rowsGap(10) //行间距
  //         .columnsGap(8) //列间距
  //         .backgroundColor(Color.White)
  //         .borderRadius(24)
  //         .padding({ top: 10, bottom: 10 })
  //         .height(204)
  //
  //         Row() {
  //           /* 列表标题 */
  //           Text($r('app.string.list'))
  //             .fontSize(16)
  //
  //             .width('100%')
  //             .margin({ top: 5 })
  //           Text('查看全部 >')
  //             .fontSize(10)// 字体大小
  //             .fontColor(Color.Gray) // 设置为灰色
  //
  //         }
  //         .width('100%')
  //         .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
  //         .alignItems(VerticalAlign.Bottom) // 下端对齐
  //         .padding({ left: 5, right: 55 })
  //
  //
  //         Grid() {
  //           ForEach(MainViewModel.getSecondGridData(), (secondItem: ItemData) => {
  //             GridItem() {
  //               Column() {
  //                 Text(secondItem.title)
  //                   .fontSize(16)
  //                   .fontWeight(FontWeight.Medium)
  //                 Text(secondItem.others)
  //                   .margin({ top: 4 })
  //                   .fontSize(8)
  //                   .fontColor('#99182431')
  //               }
  //               .alignItems(HorizontalAlign.Start)
  //             }
  //             .padding({ top: 8, left: 8 })
  //             .borderRadius(12)
  //             .align(Alignment.TopStart)
  //             .backgroundImage(secondItem.img)
  //             .backgroundImageSize(ImageSize.Cover)
  //             .width('100%')
  //             .height('100%')
  //           })
  //         }
  //         .width('100%')
  //         .height(260)
  //         .columnsTemplate('1fr 1fr 1fr')
  //         .rowsTemplate('1fr')
  //         .columnsGap(8)
  //         .rowsGap(12)
  //         //.margin({ bottom: 55 })
  //
  //       }
  //     }
  //     .height('100%')
  //     .align(Alignment.Top)
  //     .backgroundColor('#F1F3F5')
  //     .padding({ left: 12, right: 12 })
  //      // 禁用边缘弹性效果
  //   }
  //   .navDestination(this.PageMap)
  //   .height('100%')
  //   .backgroundColor('#F1F3F5')
  // }

}