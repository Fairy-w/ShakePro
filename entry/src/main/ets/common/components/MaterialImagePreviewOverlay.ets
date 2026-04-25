import { UiTokens } from '../constants/UiTokens';

export interface MaterialPreviewImageSource {
  imageUrlDetail?: string;
  imageUrl?: string;
  imageUrlCard?: string;
  imageUrlThumb?: string;
}

export interface MaterialPreviewTagStyle {
  label: string;
  textColor: string;
  backgroundColor: string;
}

export function resolveMaterialPreviewImageUrl(item: MaterialPreviewImageSource): string {
  if (typeof item.imageUrlDetail === 'string' && item.imageUrlDetail.trim().length > 0) {
    return item.imageUrlDetail;
  }
  if (typeof item.imageUrl === 'string' && item.imageUrl.trim().length > 0) {
    return item.imageUrl;
  }
  if (typeof item.imageUrlCard === 'string' && item.imageUrlCard.trim().length > 0) {
    return item.imageUrlCard;
  }
  if (typeof item.imageUrlThumb === 'string' && item.imageUrlThumb.trim().length > 0) {
    return item.imageUrlThumb;
  }
  return '';
}

@Component
export struct MaterialImagePreviewOverlay {
  @Prop title: string = '';
  @Prop subtitle: string = '材料大图预览，轻触空白处即可关闭';
  @Prop imageUrl: string = '';
  @Prop emptyTitle: string = '暂无材料大图';
  @Prop emptyDescription: string = '当前材料还没有上传大图，后续补充后会自动展示。';
  @Prop primaryTag: MaterialPreviewTagStyle = {
    label: '',
    textColor: UiTokens.textAccent,
    backgroundColor: UiTokens.primarySoft
  };
  @Prop secondaryTag: MaterialPreviewTagStyle = {
    label: '',
    textColor: UiTokens.success,
    backgroundColor: UiTokens.successSoft
  };
  onClose: () => void = () => {};

  @Builder
  private buildTag(tag: MaterialPreviewTagStyle) {
    Text(tag.label)
      .fontSize(11)
      .fontColor(tag.textColor)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(tag.backgroundColor)
      .borderRadius(14);
  }
  @Builder
  private buildPreviewBody() {
    if (this.imageUrl.length > 0) {
      Image(this.imageUrl)
        .width('100%')
        .layoutWeight(1)
        .objectFit(ImageFit.Contain)
        .borderRadius(26)
        .backgroundColor('#000000')
        .onClick(() => {
        });
    } else {
      Column({ space: 12 }) {
      Image($r('app.media.icon_cocktail'))
        .width(72)
        .height(72)
        .opacity(0.75)
        .objectFit(ImageFit.Contain);

      Text(this.emptyTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textInverse)
        .textAlign(TextAlign.Center);

      Text(this.emptyDescription)
        .fontSize(12)
        .fontColor('#CACACA')
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .maxLines(2);
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#111111')
    .borderRadius(26)
    .border({ width: 1, color: '#2F2F2F' })
    .onClick(() => {
    });
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000F2')
        .onClick(() => {
          this.onClose();
        });

      Column({ space: 16 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(UiTokens.textInverse)
              .maxLines(2);

            Text(this.subtitle)
              .fontSize(12)
              .fontColor('#CACACA');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Button('关闭', { type: ButtonType.Capsule })
            .height(38)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textInverse)
            .backgroundColor('#1F1F1F')
            .border({ width: 1, color: '#353535' })
            .padding({ left: 14, right: 14 })
            .onClick(() => {
              this.onClose();
            });
        }
        .width('100%')
        .alignItems(VerticalAlign.Top);

        this.buildPreviewBody();

        if (this.primaryTag.label.length > 0 || this.secondaryTag.label.length > 0) {
          Row({ space: 8 }) {
            if (this.primaryTag.label.length > 0) {
              this.buildTag(this.primaryTag);
            }
            if (this.secondaryTag.label.length > 0) {
              this.buildTag(this.secondaryTag);
            }
          }
          .width('100%');
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
      .padding({ left: 16, right: 16, top: 28, bottom: 28 });
    }
    .width('100%')
    .height('100%');
  }
}
