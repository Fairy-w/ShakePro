import { EMPTY_SYSTEM_RECIPE, RecipeIngredient, RecipeStep, SystemRecipe } from '../model/SystemRecipeData';
import { RecipeSectionTitle } from './RecipeSectionTitle';

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
        .fontColor(this.activeTabIndex === index ? '#241A10' : '#E7D7C1');

      Text(detail)
        .fontSize(10)
        .fontColor(this.activeTabIndex === index ? '#6F5A44' : '#A8937C');
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(this.activeTabIndex === index ? '#F7E6CF' : '#241B16')
    .borderRadius(20)
    .border({ width: 1, color: this.activeTabIndex === index ? '#F0DEC5' : '#3C3028' })
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
          .fontColor('#38281C');
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#EEDCBE')
      .borderRadius(14);

      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1711');

        Text(item.note)
          .fontSize(12)
          .fontColor('#74685C')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Text(item.amount)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#3D2E22')
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .backgroundColor('#FFF4E4')
        .borderRadius(14);
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(index % 2 === 0 ? '#FFFBF5' : '#FFF8F0')
    .borderRadius(20)
    .border({ width: 1, color: '#F0DEC5' });
  }

  @Builder
  private buildStepRow(item: RecipeStep, index: number, isLast: boolean) {
    Row({ space: 14 }) {
      Column({ space: 8 }) {
        Row() {
          Text(`${index + 1}`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF7EA');
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#201712')
        .borderRadius(18);

        Column()
          .width(2)
          .height(34)
          .backgroundColor('#E8D9C4')
          .borderRadius(1)
          .opacity(isLast ? 0 : 1);
      }
      .alignItems(HorizontalAlign.Center);

      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E1711');

        Text(item.detail)
          .fontSize(13)
          .fontColor('#74685C')
          .lineHeight(21);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' });
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
          .fontColor('#E7D7C1')
          .padding({ left: 10, right: 10, top: 7, bottom: 7 })
          .backgroundColor('#241B16')
          .borderRadius(14)
          .border({ width: 1, color: '#3C3028' });

        Text(this.activeTabIndex === 0 ? '准备齐全后，风味会更稳定' : '按顺序操作，更容易一次成功')
          .fontSize(11)
          .fontColor('#AB9882');
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
    .backgroundColor('#1B1511')
    .borderRadius(30)
    .border({ width: 1, color: '#312620' })
    .shadow({ radius: 20, color: '#140B061E', offsetX: 0, offsetY: 12 });
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
