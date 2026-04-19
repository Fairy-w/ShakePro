import { UiTokens } from '../../../common/constants/UiTokens';
@Component
export struct RecipeSectionTitle {
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Row({ space: 12 }) {
      Column()
        .width(10)
        .height(52)
        .borderRadius(8)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.accentWarm, 0.0], [UiTokens.primarySoft, 1.0]]
        });

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(this.subtitle)
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
  }
}
