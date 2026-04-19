import { CocktailListItemDto, resolveCocktailListImage } from '../../cocktail/model/CocktailDetailModels';
import { resolveRecipeHeroImage } from '../../recipe/model/SystemRecipeData';
import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct SystemFavoriteRecipeCard {
  @Prop item: CocktailListItemDto = {
    id: 0,
    name: ''
  };
  @Prop isRemoving: boolean = false;
  onOpen: (item: CocktailListItemDto) => void = () => {};
  onRemove: (item: CocktailListItemDto) => void = () => {};

  private resolveCardImage(): string {
    const imagePath = resolveCocktailListImage(this.item);
    if (imagePath.length === 0) {
      return '';
    }
    return String(resolveRecipeHeroImage(imagePath));
  }

  private hasCardImage(): boolean {
    return this.resolveCardImage().length > 0;
  }

  private buildAlcoholLevelText(): string {
    if (typeof this.item.alcoholLevel !== 'number') {
      return '系统酒谱';
    }
    return `酒精度 ${this.item.alcoholLevel}%`;
  }

  private buildDescriptionText(): string {
    if (typeof this.item.description === 'string' && this.item.description.trim().length > 0) {
      return this.item.description.trim();
    }
    return '已收藏到系统酒谱列表，随时回看这杯经典配方。';
  }

  @Builder
  private buildMetaTag(text: string, backgroundColor: string, fontColor: string) {
    Text(text)
      .fontSize(11)
      .fontColor(fontColor)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(backgroundColor)
      .borderRadius(14);
  }

  build() {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        if (this.hasCardImage()) {
          Image(this.resolveCardImage())
            .width(104)
            .height(132)
            .borderRadius(22)
            .objectFit(ImageFit.Cover);
        } else {
          Column({ space: 6 }) {
            Text('Shake')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(UiTokens.primary);

            Text('System')
              .fontSize(12)
              .fontColor(UiTokens.textSecondary);
          }
          .width(104)
          .height(132)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(UiTokens.surfaceSecondary)
          .borderRadius(22)
          .border({ width: 1, color: UiTokens.borderPrimary });
        }

        Column({ space: 10 }) {
          Row({ space: 8 }) {
            this.buildMetaTag('系统收藏', UiTokens.pageAccentMint, UiTokens.textPrimary);
            this.buildMetaTag(this.buildAlcoholLevelText(), UiTokens.surfaceMuted, UiTokens.textSecondary);
          }

          Text(this.item.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .maxLines(2)
            .lineHeight(28);

          Text(this.buildDescriptionText())
            .fontSize(13)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(20)
            .maxLines(3);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Row({ space: 10 }) {
        Button('查看详情')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary)
          .backgroundColor(UiTokens.pageAccentMint)
          .borderRadius(16)
          .onClick(() => {
            this.onOpen(this.item);
          });

        Button(this.isRemoving ? '移除中...' : '取消收藏')
          .layoutWeight(1)
          .height(44)
          .enabled(!this.isRemoving)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary)
          .backgroundColor(UiTokens.accentWarmSoft)
          .borderRadius(16)
          .onClick(() => {
            this.onRemove(this.item);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });
  }
}
