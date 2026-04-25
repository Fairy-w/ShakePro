import { UiTokens } from '../../../common/constants/UiTokens';
import { AiGenerateRecipeResponse } from '../../ai/model/AiGenerateRecipeResponse';
import { buildAiCocktailRecipeKey } from '../../favorite/model/FavoriteAiCocktailKeyUtil';

@Component
export struct AICocktailResultsSection {
  @Prop prompt: string = '';
  @Prop isLoading: boolean = false;
  @Prop errorMessage: string = '';
  @Prop recipes: AiGenerateRecipeResponse[] = [];
  @Prop loadingCardKeys: string[] = [];
  @Prop favoritedRecipeKeys: string[] = [];
  @Prop favoriteBusy: boolean = false;
  onToggleFavorite: (recipe: AiGenerateRecipeResponse) => void = () => {};

  @State private activeRecipeIndex: number = 0;

  @Builder
  private buildPromptSummary() {
    Column({ space: 10 }) {
      Row() {
        Text('当前需求')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.aiPrimary)
          .letterSpacing(1.6);

        Blank();

        if (this.isLoading) {
          Text('正在生成')
            .fontSize(11)
            .fontColor(UiTokens.textSecondary);
        }
      }
      .width('100%');

      Text(this.prompt)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(28);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildSectionMeta() {
    Row() {
      Text(this.recipes.length > 0 ? '推荐结果' : '酒单建议')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Blank();

      if (this.recipes.length > 0) {
        Text(`${this.recipes.length} 杯`)
          .fontSize(11)
          .fontColor(UiTokens.textSecondary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(UiTokens.surfaceSecondary)
          .borderRadius(12)
          .border({ width: 1, color: UiTokens.borderPrimary });
      }
    }
    .width('100%');
  }

  private getSafeActiveRecipeIndex(): number {
    if (this.recipes.length === 0) {
      return 0;
    }
    if (this.activeRecipeIndex < 0) {
      return 0;
    }
    if (this.activeRecipeIndex >= this.recipes.length) {
      return this.recipes.length - 1;
    }
    return this.activeRecipeIndex;
  }

  private getActiveRecipe(): AiGenerateRecipeResponse | undefined {
    if (this.recipes.length === 0) {
      return undefined;
    }
    return this.recipes[this.getSafeActiveRecipeIndex()];
  }

  private isActiveRecipeFavorited(): boolean {
    const recipe: AiGenerateRecipeResponse | undefined = this.getActiveRecipe();
    if (!recipe) {
      return false;
    }
    return this.favoritedRecipeKeys.indexOf(buildAiCocktailRecipeKey(recipe)) !== -1;
  }

  private toggleCurrentRecipeFavorite(): void {
    const recipe: AiGenerateRecipeResponse | undefined = this.getActiveRecipe();
    if (!recipe) {
      return;
    }
    this.onToggleFavorite(recipe);
  }

  @Builder
  private buildLoadingBody() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(UiTokens.aiPrimary);

        Text('正在为你整理更适合的酒单...')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(20);
      }
      .width('100%');

      Column({ space: 8 }) {
        Column()
          .width('62%')
          .height(30)
          .borderRadius(10)
          .backgroundColor(UiTokens.accentWarmSoft);

        Column()
          .width('100%')
          .height(14)
          .borderRadius(7)
          .backgroundColor(UiTokens.surfaceSecondary);

        Column()
          .width('84%')
          .height(14)
          .borderRadius(7)
          .backgroundColor(UiTokens.surfaceSecondary);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Row({ space: 10 }) {
        Column()
          .width(96)
          .height(30)
          .borderRadius(15)
          .backgroundColor(UiTokens.aiSoft);

        Column()
          .width(96)
          .height(30)
          .borderRadius(15)
          .backgroundColor(UiTokens.primarySoft);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Column({ space: 10 }) {
        Column()
          .width(96)
          .height(18)
          .borderRadius(9)
          .backgroundColor(UiTokens.accentWarmSoft);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Column({ space: 10 }) {
        ForEach(this.loadingCardKeys, (item: string) => {
          Column({ space: 8 }) {
            Column()
              .width('52%')
              .height(14)
              .borderRadius(7)
              .backgroundColor(UiTokens.surfaceSecondary);

            Column()
              .width('100%')
              .height(12)
              .borderRadius(6)
              .backgroundColor(UiTokens.surfaceSecondary);

            Column()
              .width('84%')
              .height(12)
              .borderRadius(6)
              .backgroundColor(UiTokens.surfaceSecondary);
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 12, right: 12, top: 12, bottom: 12 })
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(16)
          .border({ width: 1, color: UiTokens.borderPrimary });
        }, (item: string) => `loading-step-${item}`);
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 });
  }

  @Builder
  private buildMaterialItem(material: string, index: number) {
    Row({ space: 10 }) {
      Row() {
        Text(`${index + 1}`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.aiPrimary);
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.aiSoft)
      .borderRadius(14);

      Text(material)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(20);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(16)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(VerticalAlign.Top);
  }

  @Builder
  private buildStepItem(step: string, index: number) {
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

      Text(step)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(20);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(16)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(VerticalAlign.Top);
  }

  @Builder
  private buildRecipeBody(recipe: AiGenerateRecipeResponse) {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text(recipe.name)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .lineHeight(34);

          Text(recipe.description)
            .fontSize(13)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(21);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Row({ space: 8 }) {
          Text(`${recipe.materials.length} 种材料`)
            .fontSize(11)
            .fontColor(UiTokens.textAccent)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor(UiTokens.primarySoft)
            .borderRadius(14);

          Text(`${recipe.steps.length} 步完成`)
            .fontSize(11)
            .fontColor(UiTokens.aiPrimary)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor(UiTokens.aiSoft)
            .borderRadius(14);
        }
        .width('100%');

        Column({ space: 10 }) {
          Text('你需要准备')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textSecondary)
            .letterSpacing(1.2);

          Column({ space: 10 }) {
            ForEach(recipe.materials, (material: string, materialIndex: number) => {
              this.buildMaterialItem(material, materialIndex);
            }, (material: string, materialIndex: number) => `${recipe.name}-${materialIndex}-${material}`);
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Column({ space: 10 }) {
          Text('怎么调')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textSecondary)
            .letterSpacing(1.2);

          Column({ space: 10 }) {
            ForEach(recipe.steps, (step: string, stepIndex: number) => {
              this.buildStepItem(step, stepIndex);
            }, (step: string, stepIndex: number) => `${recipe.name}-${stepIndex}-${step}`);
          }
          .width('100%');
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 8, bottom: 18 });
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildRecipeContentCarousel() {
    Swiper() {
      ForEach(this.recipes, (recipe: AiGenerateRecipeResponse, index: number) => {
        Column() {
          this.buildRecipeBody(recipe);
        }
        .width('100%');
      }, (recipe: AiGenerateRecipeResponse, index: number) => `${recipe.name}-${index}`);
    }
    .width('100%')
    .height('100%')
    .indicator(this.recipes.length > 1)
    .loop(false)
    .onChange((index: number) => {
      this.activeRecipeIndex = index;
    });
  }

  @Builder
  private buildMessageBody(title: string, description: string, titleColor: string, bodyColor: string) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(titleColor);

      Text(description)
        .fontSize(13)
        .fontColor(bodyColor)
        .lineHeight(20);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 18, right: 18, top: 16, bottom: 28 });
  }

  @Builder
  private buildUnifiedResultCard() {
    Column({ space: 16 }) {
      Row() {
        Text(
          this.isLoading ? '推荐 1' :
          this.recipes.length > 0 ? `推荐 ${this.getSafeActiveRecipeIndex() + 1}` :
          this.errorMessage.length > 0 ? '生成结果' : '推荐结果'
        )
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.aiPrimary)
          .letterSpacing(1.6);

        Blank();

        Row({ space: 10 }) {
          Text(
            this.isLoading ? '正在生成' :
            this.recipes.length > 0 ? `第 ${this.getSafeActiveRecipeIndex() + 1} 杯，共 ${this.recipes.length} 杯` :
            this.errorMessage.length > 0 ? '请稍后重试' : '可重新描述'
          )
            .fontSize(11)
            .fontColor(UiTokens.textSecondary);

          if (this.recipes.length > 0) {
            Button(this.favoriteBusy ? '处理中...' : (this.isActiveRecipeFavorited() ? '已收藏' : '收藏'))
              .height(30)
              .enabled(!this.favoriteBusy)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isActiveRecipeFavorited() ? UiTokens.textInverse : UiTokens.aiPrimary)
              .backgroundColor(this.isActiveRecipeFavorited() ? UiTokens.aiPrimary : UiTokens.aiSoft)
              .borderRadius(15)
              .border({
                width: 1,
                color: this.isActiveRecipeFavorited() ? UiTokens.aiPrimaryHover : UiTokens.borderPrimary
              })
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.toggleCurrentRecipeFavorite();
              });
          }
        }
      }
      .width('100%');

      Column()
        .width('100%')
        .height(1)
        .backgroundColor(UiTokens.borderWarm);

      Column() {
        if (this.isLoading) {
          this.buildLoadingBody();
        } else if (this.errorMessage.length > 0) {
          this.buildMessageBody('这次没能顺利配出合适的酒单', this.errorMessage, UiTokens.error, UiTokens.textSecondary);
        } else if (this.recipes.length > 0) {
          this.buildRecipeContentCarousel();
        } else {
          this.buildMessageBody(
            '还没找到特别合适的这一杯',
            '换一种说法通常会更准确，比如补充基酒、甜度、酒精感、是否想要气泡，或者告诉我你现在手边有什么材料。',
            UiTokens.textPrimary,
            UiTokens.textSecondary
          );
        }
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 20, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 12 });
  }

  build() {
    Column({ space: 14 }) {
      if (this.prompt.length > 0) {
        this.buildPromptSummary();
      }

      this.buildSectionMeta();
      this.buildUnifiedResultCard();
    }
    .width('100%')
    .height('100%');
  }
}
