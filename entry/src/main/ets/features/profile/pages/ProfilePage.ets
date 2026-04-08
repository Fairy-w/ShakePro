import ItemData from '../../home/model/ItemData';
import MainViewModel from '../../home/viewmodel/MainViewModel';
import { router } from '@kit.ArkUI';

@Entry({ routeName: 'Mine' })
@Component
export struct ProfilePage {
  @Builder
  private settingCell(item: ItemData, index: number) {
    Row({ space: 12 }) {
      Row({ space: 12 }) {
        if (item.img) {
          Row() {
            Image(item.img)
              .width(28)
              .height(28)
              .objectFit(ImageFit.Contain);
          }
          .width(46)
          .height(46)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(index % 2 === 0 ? '#E8F5FB' : '#DDF5F1')
          .borderRadius(16);
        }

        Column({ space: 4 }) {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text(index === 0 ? '查看消息、活动和内容推荐' : index === 1 ? '同步调酒数据与历史记录' : '整理你的页面展示与偏好')
            .fontSize(11)
            .fontColor('#72838F')
            .lineHeight(16);
        }
        .alignItems(HorizontalAlign.Start);
      }
      .layoutWeight(1);

      if (item.others === null) {
        Image($r('app.media.right_grey'))
          .width(20)
          .height(20)
          .opacity(0.6);
      } else {
        Toggle({ type: ToggleType.Switch, isOn: true })
          .selectedColor('#8EDBCD');
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#D7E6ED' });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 14 }) {
          Text('资料中心')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Row({ space: 14 }) {
            Image($r('app.media.myself'))
              .width(72)
              .height(72)
              .borderRadius(36);

            Column({ space: 8 }) {
              Text('._.')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#173240');

              Text('2000000@cdu.com')
                .fontSize(13)
                .fontColor('#72838F');

              Text('已开启同步、偏爱金酒和清爽风味')
                .fontSize(12)
                .fontColor('#7E909A');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .border({ width: 1, color: '#D7E6ED' });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Column({ space: 12 }) {
          Text('常用设置')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          ForEach(MainViewModel.getSettingListData(), (item: ItemData, index: number) => {
            this.settingCell(item, index);
          });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Button('退出登录', { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#1E566A')
          .margin({ top: 10, bottom: 24 })
          .onClick(() => {
            router.replaceUrl({
              url: 'features/auth/pages/LoginPage'
            }, 3000);
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 40 });
    }
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }
}
