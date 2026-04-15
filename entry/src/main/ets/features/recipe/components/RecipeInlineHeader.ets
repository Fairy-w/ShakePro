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
          .fontColor('#9B7A4F')
          .letterSpacing(1.4);
      }

      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#201812');

      Text(this.subtitle)
        .fontSize(12)
        .fontColor('#77695A')
        .lineHeight(18);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
