@Component
export struct RecipeDetailHeader {
  @Prop isBookmarked: boolean = false;
  onBack: () => void = () => {};
  onToggleBookmark: () => void = () => {};
  onShowMockHint: () => void = () => {};

  @Builder
  private buildTopBar() {
    Row({ space: 12 }) {
      Button('返回')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F1711')
        .backgroundColor('#F7E6CF')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onBack();
        });

      Column({ space: 2 }) {
        Text('酒谱详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1D1712');

        Text('为你整理这一杯的完整信息')
          .fontSize(11)
          .fontColor('#847666');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button(this.isBookmarked ? '已收藏' : '收藏')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isBookmarked ? '#FFF8EE' : '#3C2A18')
        .backgroundColor(this.isBookmarked ? '#231A14' : '#E7CDA7')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onToggleBookmark();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildMockBanner() {
    Row({ space: 12 }) {
      Column()
        .width(10)
        .height(56)
        .borderRadius(8)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#E7CDA7', 0.0], ['#D7E8F0', 1.0]]
        });

      Column({ space: 6 }) {
        Text('这杯酒值得慢慢看')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#201812');

        Text('从风味、材料到调制方式，我们已经帮你整理好这一杯的全部重点。')
          .fontSize(12)
          .fontColor('#77695A')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('了解')
        .height(34)
        .fontSize(12)
        .fontColor('#3D2C1A')
        .backgroundColor('#F5E4CE')
        .borderRadius(14)
        .onClick(() => {
          this.onShowMockHint();
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' })
    .shadow({ radius: 18, color: '#A27A3A12', offsetX: 0, offsetY: 10 });
  }

  build() {
    Column({ space: 18 }) {
      this.buildTopBar();
      this.buildMockBanner();
    }
    .width('100%');
  }
}
