import { UiTokens } from '../../../common/constants/UiTokens';
@Component
export struct RecipeDetailHeader {
  @Prop isBookmarked: boolean = false;
  @Prop isBookmarkBusy: boolean = false;
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
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarmSoft)
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onBack();
        });

      Column({ space: 2 }) {
        Text('酒谱详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('为你整理这一杯的完整信息')
          .fontSize(11)
          .fontColor(UiTokens.textSecondary);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button(this.isBookmarkBusy ? '处理中...' : (this.isBookmarked ? '已收藏' : '收藏'))
        .height(40)
        .enabled(!this.isBookmarkBusy)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isBookmarked ? UiTokens.textInverse : UiTokens.textPrimary)
        .backgroundColor(this.isBookmarked ? UiTokens.brandStrong : UiTokens.accentWarm)
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
          colors: [[UiTokens.accentWarm, 0.0], [UiTokens.primarySoft, 1.0]]
        });

      Column({ space: 6 }) {
        Text('这杯酒值得慢慢看')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary);

        Text('从风味、材料到调制方式，我们已经帮你整理好这一杯的全部重点。')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('了解')
        .height(34)
        .fontSize(12)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarmSoft)
        .borderRadius(14)
        .onClick(() => {
          this.onShowMockHint();
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
  }

  build() {
    Column({ space: 18 }) {
      this.buildTopBar();
      this.buildMockBanner();
    }
    .width('100%');
  }
}
