import { EMPTY_SYSTEM_RECIPE, SystemRecipe } from '../model/SystemRecipeData';
import { RecipeInlineHeader } from './RecipeInlineHeader';
import { RecipeStatCard } from './RecipeStatCard';

@Component
export struct RecipeServeSection {
  @Prop recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;

  @Builder
  private buildNoteItem(text: string, textColor: string = '#716559', dotColor: string = '#D2AE7A') {
    Row({ space: 10 }) {
      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(dotColor)
        .margin({ top: 6 });

      Text(text)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor(textColor)
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top);
  }

  build() {
    Column({ space: 14 }) {
      RecipeInlineHeader({
        eyebrow: '享用建议',
        title: '出品标准与搭配建议',
        subtitle: '选对杯型和搭配，这杯酒会更出彩'
      });

      Row({ space: 12 }) {
        RecipeStatCard({
          title: '杯型',
          value: this.recipe.glass,
          detail: '选对杯型更好喝',
          cardBgColor: '#FFFBF5',
          cardAccentColor: '#E7CDA7'
        });
        RecipeStatCard({
          title: '装饰',
          value: this.recipe.garnish,
          detail: '点缀到位更完整',
          cardBgColor: '#F7FBFD',
          cardAccentColor: '#C2DFE8'
        });
      }
      .width('100%');

      Row({ space: 12 }) {
        Column({ space: 12 }) {
          Text('搭配建议')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#201812');

          ForEach(this.recipe.pairings, (item: string) => {
            this.buildNoteItem(item);
          }, (item: string) => `${this.recipe.id}-pairing-${item}`);
        }
        .layoutWeight(1)
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .backgroundColor('#FFFBF5')
        .borderRadius(24)
        .border({ width: 1, color: '#F0DEC5' })
        .shadow({ radius: 16, color: '#A27A3A10', offsetX: 0, offsetY: 8 });

        Column({ space: 12 }) {
          Text('服务提醒')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#201812');

          ForEach(this.recipe.serviceNotes, (item: string) => {
            this.buildNoteItem(item, '#65584C', '#9AD0DD');
          }, (item: string) => `${this.recipe.id}-service-${item}`);
        }
        .layoutWeight(1)
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .backgroundColor('#F7FBFD')
        .borderRadius(24)
        .border({ width: 1, color: '#D9EAF0' })
        .shadow({ radius: 16, color: '#82A9B20C', offsetX: 0, offsetY: 8 });
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);
    }
    .width('100%');
  }
}
