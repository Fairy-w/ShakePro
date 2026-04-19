import { EMPTY_SYSTEM_RECIPE, SystemRecipe } from '../model/SystemRecipeData';
import { RecipeInlineHeader } from './RecipeInlineHeader';
import { RecipeStatCard } from './RecipeStatCard';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct RecipeOverviewSection {
  @Prop recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;

  build() {
    Column({ space: 14 }) {
      RecipeInlineHeader({
        eyebrow: '推荐亮点',
        title: '先看这杯为什么值得推荐',
        subtitle: '先认识它的风格，再决定要不要点这一杯'
      });

      Column({ space: 12 }) {
        Text(this.recipe.description)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary)
          .lineHeight(25);

        Text(this.recipe.story)
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(22);
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18, bottom: 18 })
      .backgroundColor(UiTokens.surfaceWarm)
      .borderRadius(28)
      .border({ width: 1, color: UiTokens.borderWarm })
      .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });

      Row({ space: 12 }) {
        RecipeStatCard({
          title: '制作难度',
          value: this.recipe.difficulty,
          detail: '上手前先有预期',
          cardBgColor: UiTokens.pageGradientStart,
          cardAccentColor: UiTokens.primary
        });
        RecipeStatCard({
          title: '预计酒精度',
          value: this.recipe.abv,
          detail: '喝之前先有准备',
          cardBgColor: UiTokens.surfaceWarm,
          cardAccentColor: UiTokens.accentWarm
        });
      }
      .width('100%');
    }
    .width('100%');
  }
}
