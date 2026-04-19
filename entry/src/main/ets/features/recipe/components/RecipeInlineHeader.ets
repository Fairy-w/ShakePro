import { UiTokens } from '../../../common/constants/UiTokens';
@Component
export struct RecipeInlineHeader {
  @Prop eyebrow: string = '';
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Column({ space: 6 }) {
      if (this.eyebrow.length > 0) {
        Text(this.eyebrow)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.accentWarm)
          .letterSpacing(1.4);
      }

      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text(this.subtitle)
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(18);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
