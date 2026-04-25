import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct ProfileHeroCard {
  @Prop avatar: ResourceStr = $r('app.media.myself');
  @Prop displayName: string = '';

  @Builder
  private buildGlow(width: number, height: number, color: string, opacity: number, x: number, y: number) {
    Column()
      .width(width)
      .height(height)
      .borderRadius(width / 2)
      .backgroundColor(color)
      .opacity(opacity)
      .position({ x, y });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(220)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.surfaceWarm, 0.0], [UiTokens.surfaceWarmAlt, 0.56], [UiTokens.primarySoftAlt, 1.0]]
        })
        .borderRadius(UiTokens.radiusHero)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });

      this.buildGlow(180, 180, UiTokens.surfaceOverlay, 0.58, -44, -56);
      this.buildGlow(130, 130, UiTokens.accentWarmSoft, 0.38, 248, 22);

      Column({ space: 14 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(110)
            .height(110)
            .borderRadius(55)
            .backgroundColor(UiTokens.surfacePrimary)
            .border({ width: 1, color: UiTokens.borderWarm })
            .shadow({ radius: 12, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 6 });

          Image(this.avatar)
            .width(96)
            .height(96)
            .borderRadius(48)
            .objectFit(ImageFit.Cover)
            .border({ width: 1, color: UiTokens.borderSecondary });
        }

        Text(this.displayName)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .maxLines(1)
          .textAlign(TextAlign.Center);

        Text('SHAKEPRO USER')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .letterSpacing(1.2)
          .fontColor(UiTokens.textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(UiTokens.surfaceOverlay)
          .borderRadius(12)
          .border({ width: 1, color: UiTokens.borderSecondary });
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 20, right: 20, top: 24, bottom: 24 });
    }
    .width('100%')
    .height(220)
    .align(Alignment.TopStart);
  }
}
