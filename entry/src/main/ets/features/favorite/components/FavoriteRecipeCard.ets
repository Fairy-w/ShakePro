import { FavoriteAiCocktailItem } from '../model/FavoriteAiCocktailModels';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct FavoriteRecipeCard {
  @Prop item: FavoriteAiCocktailItem = {
    favoriteId: 0,
    recipeKey: '',
    name: '',
    description: '',
    materials: [],
    steps: [],
    prompt: '',
    source: 'ai',
    createdAt: ''
  };
  @Prop isRemoving: boolean = false;
  onRemove: (item: FavoriteAiCocktailItem) => void = () => {};

  @Builder
  private buildTag(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor(UiTokens.textAccent)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(UiTokens.accentWarmSoft)
      .borderRadius(14);
  }

  @Builder
  private buildBullet(text: string, color: string = UiTokens.textPrimary) {
    Row({ space: 10 }) {
      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor(UiTokens.accentWarm)
        .margin({ top: 7 });

      Text(text)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor(color)
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top);
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 8 }) {
          Text(this.item.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .lineHeight(28);

          if (this.item.description.length > 0) {
            Text(this.item.description)
              .fontSize(13)
              .fontColor(UiTokens.textSecondary)
              .lineHeight(20);
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Text('AI 收藏')
          .fontSize(11)
          .fontColor(UiTokens.textAccent)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(UiTokens.accentWarmSoft)
          .borderRadius(14);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Row({ space: 8 }) {
        this.buildTag(`${this.item.materials.length} 种材料`);
        this.buildTag(`${this.item.steps.length} 步完成`);
        if (this.item.createdAt.length > 0) {
          this.buildTag(this.item.createdAt);
        }
      }
      .width('100%');

      if (this.item.prompt.length > 0) {
        Column({ space: 8 }) {
          Text('当时你的需求')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textAccent)
            .letterSpacing(1.2);

          Text(this.item.prompt)
            .fontSize(13)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(20);
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 14, bottom: 14 })
        .backgroundColor(UiTokens.surfaceWarmAlt)
        .borderRadius(18);
      }

      Column({ space: 10 }) {
        Text('你需要准备')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textAccent)
          .letterSpacing(1.2);

        Column({ space: 10 }) {
          ForEach(this.item.materials, (material: string) => {
            this.buildBullet(material);
          }, (material: string) => `${this.item.recipeKey}-material-${material}`);
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Column({ space: 10 }) {
        Text('怎么调')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textAccent)
          .letterSpacing(1.2);

        Column({ space: 10 }) {
          ForEach(this.item.steps, (step: string, index: number) => {
            Row({ space: 12 }) {
              Row() {
                Text(`${index + 1}`)
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(UiTokens.textPrimary);
              }
              .width(24)
              .height(24)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(UiTokens.accentWarmSoft)
              .borderRadius(12);

              Text(step)
                .layoutWeight(1)
                .fontSize(13)
                .fontColor(UiTokens.textPrimary)
                .lineHeight(20);
            }
            .width('100%')
            .alignItems(VerticalAlign.Top);
          }, (step: string, index: number) => `${this.item.recipeKey}-step-${index}-${step}`);
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Button(this.isRemoving ? '移除中...' : '取消收藏')
        .width('100%')
        .height(46)
        .enabled(!this.isRemoving)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarm)
        .borderRadius(16)
        .onClick(() => {
          this.onRemove(this.item);
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 16, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
  }
}
