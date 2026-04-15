import { EMPTY_SYSTEM_RECIPE, SystemRecipe } from '../model/SystemRecipeData';
import { RecipeInlineHeader } from './RecipeInlineHeader';
import { RecipeStatCard } from './RecipeStatCard';

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
          .fontColor('#201812')
          .lineHeight(25);

        Text(this.recipe.story)
          .fontSize(13)
          .fontColor('#74695F')
          .lineHeight(22);
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18, bottom: 18 })
      .backgroundColor('#FFF8F0')
      .borderRadius(28)
      .border({ width: 1, color: '#F0DEC5' })
      .shadow({ radius: 18, color: '#A27A3A12', offsetX: 0, offsetY: 10 });

      Row({ space: 12 }) {
        RecipeStatCard({
          title: '制作难度',
          value: this.recipe.difficulty,
          detail: '上手前先有预期',
          cardBgColor: '#F7FBFD',
          cardAccentColor: '#C2DFE8'
        });
        RecipeStatCard({
          title: '预计酒精度',
          value: this.recipe.abv,
          detail: '喝之前先有准备',
          cardBgColor: '#FFFBF5',
          cardAccentColor: '#E7CDA7'
        });
      }
      .width('100%');
    }
    .width('100%');
  }
}
