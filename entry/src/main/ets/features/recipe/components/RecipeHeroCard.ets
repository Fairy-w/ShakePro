import { EMPTY_SYSTEM_RECIPE, SystemRecipe, resolveRecipeHeroImage } from '../model/SystemRecipeData';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct RecipeHeroCard {
  @Prop recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;
  @Prop canPreview: boolean = false;
  onPreviewImage: () => void = () => {};

  @Builder
  private buildTag(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor('#D4B08C')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor('#221913CC')
      .borderRadius(14)
      .border({ width: 1, color: '#4A382E' });
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(resolveRecipeHeroImage(this.recipe.heroImage))
        .width('100%')
        .height(330)
        .borderRadius(32)
        .objectFit(ImageFit.Cover);

      Column()
        .width('100%')
        .height(330)
        .borderRadius(32)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#120B0700', 0.0], ['#19110D55', 0.32], ['#17100BE6', 1.0]]
        });

      Column()
        .width('100%')
        .height(124)
        .borderRadius({ topLeft: 32, topRight: 32, bottomLeft: 28, bottomRight: 28 })
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#120B09E8', 0.0], ['#1B130FBC', 0.62], ['#2217104A', 1.0]]
        })
        .position({ x: 0, y: 0 });

      Column({ space: 16 }) {
        Column({ space: 10 }) {
          Row({ space: 8 }) {
            Text(this.recipe.category)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#E2C29E')
              .letterSpacing(1.2)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#2A1D15D8')
              .borderRadius(16)
              .border({ width: 1, color: '#7A5A3E' });

            Text('推荐给你')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#120C08')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(UiTokens.accentWarm)
              .borderRadius(16);

            if (this.canPreview) {
              Blank().layoutWeight(1);
            }
          }
          .width('100%');

          Text(this.recipe.highlight)
            .fontSize(12)
            .fontColor('#BC9471')
            .lineHeight(19)
            .maxLines(2)
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('#201611C2')
            .borderRadius(18)
            .border({ width: 1, color: '#4C392C' });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Blank().layoutWeight(1);

        Column({ space: 10 }) {
          Text(this.recipe.name)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#C49D79')
            .lineHeight(40);

          Text(this.recipe.englishName)
            .fontSize(13)
            .fontColor('#A87E5D')
            .letterSpacing(0.8);

          Text(this.recipe.subtitle)
            .fontSize(14)
            .fontColor('#B88E6C')
            .lineHeight(22);

          Row({ space: 8 }) {
            ForEach(this.recipe.flavorTags, (tag: string) => {
              this.buildTag(tag);
            }, (tag: string) => `${this.recipe.id}-tag-${tag}`);
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .height(330)
      .padding({ left: 22, right: 22, top: 20, bottom: 24 });
    }
    .width('100%')
    .borderRadius(32)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 20, color: UiTokens.shadowMedium, offsetX: 0, offsetY: 12 })
    .onClick(() => {
      if (this.canPreview) {
        this.onPreviewImage();
      }
    });
  }
}
