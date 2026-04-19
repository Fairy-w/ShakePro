import { EMPTY_SYSTEM_RECIPE, RecipeIngredient, RecipeStep, SystemRecipe } from '../model/SystemRecipeData';
import { RecipeSectionTitle } from './RecipeSectionTitle';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct RecipeProductionCapsule {
  @Prop recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;
  @State private activeTabIndex: number = 0;

  @Builder
  private buildSegment(text: string, detail: string, index: number) {
    Column({ space: 4 }) {
      Text(text)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.activeTabIndex === index ? UiTokens.textPrimary : UiTokens.textSecondary);

      Text(detail)
        .fontSize(10)
        .fontColor(this.activeTabIndex === index ? UiTokens.textSecondary : UiTokens.textTertiary);
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(this.activeTabIndex === index ? UiTokens.accentWarmSoft : UiTokens.surfaceSecondary)
    .borderRadius(20)
    .border({ width: 1, color: this.activeTabIndex === index ? UiTokens.borderWarm : UiTokens.borderPrimary })
    .onClick(() => {
      this.activeTabIndex = index;
    });
  }

  @Builder
  private buildIngredientRow(item: RecipeIngredient, index: number) {
    Row({ space: 12 }) {
      Row() {
        Text(`${index + 1}`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.accentWarmSoft)
      .borderRadius(14);

      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(item.note)
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Text(item.amount)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .backgroundColor(UiTokens.accentWarmSoft)
        .borderRadius(14);
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(index % 2 === 0 ? UiTokens.surfaceWarm : UiTokens.surfaceWarm)
    .borderRadius(20)
    .border({ width: 1, color: UiTokens.borderWarm });
  }

  @Builder
  private buildStepRow(item: RecipeStep, index: number, isLast: boolean) {
    Row({ space: 14 }) {
      Column({ space: 8 }) {
        Row() {
          Text(`${index + 1}`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textInverse);
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(UiTokens.brandStrong)
        .borderRadius(18);

        Column()
          .width(2)
          .height(34)
          .backgroundColor(UiTokens.borderWarm)
          .borderRadius(1)
          .opacity(isLast ? 0 : 1);
      }
      .alignItems(HorizontalAlign.Center);

      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(item.detail)
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(21);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm });
  }

  @Builder
  private buildCapsuleBody() {
    Column({ space: 16 }) {
      Row({ space: 10 }) {
        this.buildSegment('材料清单', `${this.recipe.ingredients.length} 项准备`, 0);
        this.buildSegment('出杯步骤', `${this.recipe.steps.length} 步完成`, 1);
      }
      .width('100%');

      Row({ space: 10 }) {
        Text(this.activeTabIndex === 0 ? '先准备这些材料' : '跟着步骤调制')
          .fontSize(11)
          .fontColor(UiTokens.textAccent)
          .padding({ left: 10, right: 10, top: 7, bottom: 7 })
          .backgroundColor(UiTokens.primarySoft)
          .borderRadius(14)
          .border({ width: 1, color: UiTokens.borderPrimary });

        Text(this.activeTabIndex === 0 ? '准备齐全后，风味会更稳定' : '按顺序操作，更容易一次成功')
          .fontSize(11)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%');

      if (this.activeTabIndex === 0) {
        Column({ space: 10 }) {
          ForEach(this.recipe.ingredients, (item: RecipeIngredient, index: number) => {
            this.buildIngredientRow(item, index);
          }, (item: RecipeIngredient, index: number) => `${this.recipe.id}-capsule-ingredient-${index}-${item.name}`);
        }
        .width('100%');
      } else {
        Column({ space: 10 }) {
          ForEach(this.recipe.steps, (item: RecipeStep, index: number) => {
            this.buildStepRow(item, index, index === this.recipe.steps.length - 1);
          }, (item: RecipeStep, index: number) => `${this.recipe.id}-capsule-step-${index}-${item.title}`);
        }
        .width('100%');
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(30)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 20, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 12 });
  }

  build() {
    Column({ space: 14 }) {
      RecipeSectionTitle({
        title: '调制指南',
        subtitle: '先看要准备什么，再按步骤慢慢完成这一杯'
      });

      this.buildCapsuleBody();
    }
    .width('100%');
  }
}
