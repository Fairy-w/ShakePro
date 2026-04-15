@Component
export struct RecipeStatCard {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop detail: string = '';
  @Prop cardBgColor: ResourceColor = '#FFFBF5';
  @Prop cardAccentColor: ResourceColor = '#E7CDA7';

  build() {
    Column({ space: 12 }) {
      Column()
        .width(34)
        .height(4)
        .borderRadius(2)
        .backgroundColor(this.cardAccentColor);

      Text(this.title)
        .fontSize(12)
        .fontColor('#7A6D60');

      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E1711')
        .lineHeight(24)
        .maxLines(3);

      Text(this.detail)
        .fontSize(11)
        .fontColor('#76695D')
        .lineHeight(17);
    }
    .layoutWeight(1)
    .height(162)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardBgColor)
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' })
    .shadow({ radius: 14, color: '#A27A3A10', offsetX: 0, offsetY: 8 });
  }
}
