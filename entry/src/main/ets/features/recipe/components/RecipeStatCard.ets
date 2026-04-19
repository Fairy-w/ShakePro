import { UiTokens } from '../../../common/constants/UiTokens';
@Component
export struct RecipeStatCard {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop detail: string = '';
  @Prop cardBgColor: ResourceColor = UiTokens.surfaceWarm;
  @Prop cardAccentColor: ResourceColor = UiTokens.accentWarm;

  build() {
    Column({ space: 12 }) {
      Column()
        .width(34)
        .height(4)
        .borderRadius(2)
        .backgroundColor(this.cardAccentColor);

      Text(this.title)
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);

      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(24)
        .maxLines(3);

      Text(this.detail)
        .fontSize(11)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(17);
    }
    .layoutWeight(1)
    .height(162)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardBgColor)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });
  }
}
