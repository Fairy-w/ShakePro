import { UiTokens } from '../../../common/constants/UiTokens';
import { ProfileMenuItem } from '../model/ProfileMockData';

@Component
export struct ProfileMenuSection {
  @Prop title: string = '';
  @Prop items: ProfileMenuItem[] = [];
  onItemClick: (itemId: string) => void = () => {};

  @Builder
  private buildItem(item: ProfileMenuItem) {
    Row({ space: 12 }) {
      Row() {
        Image(item.icon)
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain);
      }
      .width(42)
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(item.softColor)
      .borderRadius(14);

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(item.subtitle)
          .fontSize(11)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(17)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      if (item.trailingText.length > 0) {
        Text(item.trailingText)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.accentColor)
          .padding({ left: 11, right: 11, top: 6, bottom: 6 })
          .backgroundColor(item.softColor)
          .borderRadius(12)
          .border({ width: 1, color: UiTokens.borderSecondary });
      } else {
        Image($r('app.media.right_grey'))
          .width(18)
          .height(18)
          .opacity(0.56);
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(20)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 10, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 5 })
    .onClick(() => {
      this.onItemClick(item.id);
    });
  }

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Column({ space: 10 }) {
        ForEach(this.items, (item: ProfileMenuItem) => {
          this.buildItem(item);
        }, (item: ProfileMenuItem) => item.id);
      }
      .width('100%');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
