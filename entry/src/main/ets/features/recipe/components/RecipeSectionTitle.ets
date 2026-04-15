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
          colors: [['#E7CDA7', 0.0], ['#D7E8F0', 1.0]]
        });

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#201812');

        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#77695A')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' })
    .shadow({ radius: 18, color: '#A27A3A12', offsetX: 0, offsetY: 10 });
  }
}
