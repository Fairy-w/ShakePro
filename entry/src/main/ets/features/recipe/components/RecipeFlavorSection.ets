import { EMPTY_SYSTEM_RECIPE, FlavorMetric, SystemRecipe, getFlavorMetricList } from '../model/SystemRecipeData';
import { RecipeInlineHeader } from './RecipeInlineHeader';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct RecipeFlavorSection {
  @Prop recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;

  @Builder
  private buildTag(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor(UiTokens.textAccent)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(UiTokens.primarySoft)
      .borderRadius(14)
      .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildFlavorMetric(item: FlavorMetric) {
    Row({ space: 12 }) {
      Text(item.label)
        .width(54)
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .borderRadius(4)
          .backgroundColor(UiTokens.surfaceSecondary);

        Row()
          .width(`${item.value * 20}%`)
          .height(8)
          .borderRadius(4)
          .linearGradient({
            direction: GradientDirection.Left,
            repeating: false,
            colors: [[UiTokens.accentWarm, 0.0], [UiTokens.primary, 1.0]]
          });
      }
      .layoutWeight(1)
      .height(8);

      Text(`${item.value}/5`)
        .fontSize(11)
        .fontColor(UiTokens.textTertiary);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  build() {
    Column({ space: 14 }) {
      RecipeInlineHeader({
        eyebrow: '风味印象',
        title: '风味画像',
        subtitle: '提前感受它的酒感、清爽度和整体层次'
      });

      Column({ space: 16 }) {
        Row({ space: 8 }) {
          ForEach(this.recipe.flavorTags, (tag: string) => {
            this.buildTag(tag);
          }, (tag: string) => `${this.recipe.id}-flavor-tag-${tag}`);
        }

        Column({ space: 12 }) {
          ForEach(getFlavorMetricList(this.recipe.flavorMetrics), (item: FlavorMetric) => {
            this.buildFlavorMetric(item);
          }, (item: FlavorMetric) => `${this.recipe.id}-${item.label}`);
        }
        .width('100%');
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18, bottom: 18 })
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(30)
      .border({ width: 1, color: UiTokens.borderPrimary })
      .shadow({ radius: 20, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 12 });
    }
    .width('100%');
  }
}
