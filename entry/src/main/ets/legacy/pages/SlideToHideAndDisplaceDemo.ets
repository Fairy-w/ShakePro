import promptAction from '@ohos.promptAction';
import { IconAndDescription } from '../model/Util';
import { router } from '@kit.ArkUI';

@Component
export struct SlideToHideAndDisplaceComponent {
  ordersInfo: IconAndDescription[] = [
    new IconAndDescription($r('app.media.slidetohideanddisplace_payment'), $r('app.string.slidetohideanddisplace_payment')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_receiving'), $r('app.string.slidetohideanddisplace_receiving')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_comments'), $r('app.string.slidetohideanddisplace_comments')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_more'), $r('app.string.slidetohideanddisplace_more'))
  ];

  interactionInfo: IconAndDescription[] = [
    new IconAndDescription($r('app.media.slidetohideanddisplace_fans'), $r('app.string.slidetohideanddisplace_fans')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_favorites'), $r('app.string.slidetohideanddisplace_favorites')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_follow'), $r('app.string.slidetohideanddisplace_follow')),
    new IconAndDescription($r('app.media.slidetohideanddisplace_history'), $r('app.string.slidetohideanddisplace_history'))
  ];

  @Builder
  private buildHero() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 6 }) {
          Text('个人工作区')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text('查看偏好、收藏和常用操作入口。')
            .fontSize(13)
            .fontColor('#72838F');
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Text('SYNC')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1B596E')
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor('#DDF5F1')
          .borderRadius(16);
      }
      .width('100%');

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
            .fontColor('#738590');

          Row({ space: 8 }) {
            Text('酸甜偏好')
              .fontSize(11)
              .fontColor('#23576A')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('#E8F5FB')
              .borderRadius(14);

            Text('夜间调酒')
              .fontSize(11)
              .fontColor('#1D586C')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('#DDF5F1')
              .borderRadius(14);
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildActionGrid(title: string, items: IconAndDescription[]) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Grid() {
        ForEach(items, (item: IconAndDescription, index: number) => {
          GridItem() {
            Column({ space: 10 }) {
              Row() {
                Image(item.icon)
                  .width(28)
                  .height(28)
                  .objectFit(ImageFit.Contain);
              }
              .width(48)
              .height(48)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(index % 2 === 0 ? '#E8F5FB' : '#DDF5F1')
              .borderRadius(16);

              Text(item.description)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#173240')
                .textAlign(TextAlign.Center)
                .maxLines(2);
            }
            .width('100%')
            .height(112)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .border({ width: 1, color: '#D7E6ED' })
            .onClick(() => {
              promptAction.showToast({ message: item.description });
            });
          }
        });
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildBanner() {
    Row({ space: 14 }) {
      Column({ space: 8 }) {
        Text('同步与权限')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('查看资料、偏好和账号设置。')
          .fontSize(12)
          .fontColor('#72838F')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('打开')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#124056')
        .backgroundColor('#DDF5F1')
        .borderRadius(18)
        .border({ width: 1, color: '#BFE7E6' })
        .onClick(() => {
          router.pushUrl({ url: 'features/profile/pages/ProfilePage' }, 3000);
        });
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHero();
        this.buildActionGrid('订单与服务', this.ordersInfo);
        this.buildActionGrid('互动记录', this.interactionInfo);
        this.buildBanner();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 110 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }
}
