import ItemData from '../viewmodel/ItemData'
import MainViewModel from '../viewmodel/MainViewModel'
import { router } from '@kit.ArkUI'


@Entry ({ routeName: 'Mine' })
@Component
struct MainPage{
  @State message : string = 'MainPage'
  @Builder settingCell(item:ItemData){
    Row(){
      Row({space:12}){
        Image(item.img)
          .width(45)
          .height(45)
        Text(item.title)
      }
      if(item.others === null){
        Image($r('app.media.right_grey'))
      } else {
        Toggle({
          type: ToggleType.Switch,
          isOn: false
        })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  build() {
    Scroll(){
      Column({space : 10}){
        /*标题区域*/
        Column() {
          Text('我的')
            .fontWeight(FontWeight.Normal)
            .fontSize(30)
            .margin({ top: 8 })
            .padding({ left: 12 })
        }
        .alignItems(HorizontalAlign.Start)

        /*用户明细区域*/
        Row(){
          Image($r('app.media.myself'))
            .width(48)
            .height(48)
          Column(){
            Text('._.')
              .fontSize(20)
            Text('2000000@cdu.com')
              .fontSize(12)
              .margin(4)

          }
          .alignItems(HorizontalAlign.Start)
          .margin(24)
        }
        .margin({top:24})
        .alignItems(VerticalAlign.Center)
        .height(96)
        .backgroundColor(Color.White)
        .padding({left:24})
        .borderRadius(10)

        /*开关列表选项*/
        List(){
          ForEach(MainViewModel.getSettingListData(),(item:ItemData)=>{
            ListItem(){
              this.settingCell(item)
            }
          })
        }
        .backgroundColor(Color.White)
        .width('100%')
        .borderRadius(5)

        Blank()
        /*退出登录*/
        Button('退出登录',{type:ButtonType.Capsule})
          .width(220)
          .height(35)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Pink)
          .margin({bottom : 10})
          .onClick(()=>{
            router.replaceUrl({
              url: 'pages/Index',
            },3000);
          })
      }
      .height('100%')
    }
    .backgroundColor('#F1F3F5')
    .padding({left:12,right:12})
  }
}