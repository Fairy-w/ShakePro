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
        Text('你的偏好')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor('#A58C66')
          .letterSpacing(1.6);

        Blank();

        if (this.isLoading) {
          Text('正在生成')
            .fontSize(11)
            .fontColor('#D5BC93');
        }
      }
      .width('100%');

      Text(this.prompt)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F5EDDF')
        .lineHeight(28);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor('#131614')
    .borderRadius(24)
    .border({ width: 1, color: '#2A2F2A' });
  }

  @Builder
  private buildSectionMeta() {
    Row() {
      Text(this.recipes.length > 0 ? '推荐结果' : '酒单建议')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#EFE6D7');

      Blank();

      if (this.recipes.length > 0) {
        Text(`${this.recipes.length} 杯`)
          .fontSize(11)
          .fontColor('#A9977E')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#151917')
          .borderRadius(12)
          .border({ width: 1, color: '#2A302B' });
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
    Column({ space: 14 }) {
      Row({ space: 10 }) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color('#C6A16C');

        Text('正在为您调酒...')
          .fontSize(13)
          .fontColor('#5A4B3D')
          .lineHeight(20);
      }
      .width('100%');

      Column({ space: 10 }) {
        Column()
          .width('62%')
          .height(30)
          .borderRadius(10)
          .backgroundColor('#E7D7C1');

        Column()
          .width('100%')
          .height(14)
          .borderRadius(7)
          .backgroundColor('#EDE1D1');

        Column()
          .width('84%')
          .height(14)
          .borderRadius(7)
          .backgroundColor('#EDE1D1');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Row({ space: 8 }) {
        Column()
          .width(96)
          .height(30)
          .borderRadius(15)
          .backgroundColor('#EAD9BE');

        Column()
          .width(96)
          .height(30)
          .borderRadius(15)
          .backgroundColor('#EAD9BE');
      }
      .width('100%');

      Column({ space: 10 }) {
        Column()
          .width(96)
          .height(18)
          .borderRadius(9)
          .backgroundColor('#E7D7C1');

        ForEach(this.loadingCardKeys, (_: string, lineIndex: number) => {
          Column()
            .width('100%')
            .height(lineIndex === 0 ? 44 : 52)
            .borderRadius(16)
            .backgroundColor('#F8F1E7');
        }, (item: string) => `loading-step-${item}`);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 28 });
  }

  @Builder
  private buildMaterialItem(material: string) {
    Row({ space: 10 }) {
      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor('#A98758')
        .margin({ top: 7 });

      Text(material)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor('#40342B')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top);
  }

  @Builder
  private buildStepItem(step: string, index: number) {
    Row({ space: 12 }) {
      Row() {
        Text(`${index + 1}`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4D3820');
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E2CFB1')
      .borderRadius(14);

      Text(step)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor('#40342B')
        .lineHeight(20);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor('#F8F1E7')
    .borderRadius(16)
    .border({ width: 1, color: '#E7D7C0' })
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
            .fontColor('#1E1A17')
            .lineHeight(34);

          Text(recipe.description)
            .fontSize(13)
            .fontColor('#5A4B3D')
            .lineHeight(21);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Row({ space: 8 }) {
          Text(`${recipe.materials.length} 种材料`)
            .fontSize(11)
            .fontColor('#5F4C36')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor('#EAD9BE')
            .borderRadius(14);

          Text(`${recipe.steps.length} 步完成`)
            .fontSize(11)
            .fontColor('#5F4C36')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor('#EAD9BE')
            .borderRadius(14);
        }
        .width('100%');

        Column({ space: 10 }) {
          Text('你需要准备')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#7A5D3C')
            .letterSpacing(1.2);

          Column({ space: 10 }) {
            ForEach(recipe.materials, (material: string) => {
              this.buildMaterialItem(material);
            }, (material: string) => `${recipe.name}-${material}`);
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
            .fontColor('#7A5D3C')
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
      .padding({ left: 18, right: 18, top: 16, bottom: 18 });
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
          .fontColor('#8B6840')
          .letterSpacing(1.6);

        Blank();

        Row({ space: 10 }) {
          Text(
            this.isLoading ? '正在生成' :
            this.recipes.length > 0 ? `第 ${this.getSafeActiveRecipeIndex() + 1} 杯，共 ${this.recipes.length} 杯` :
            this.errorMessage.length > 0 ? '请稍后重试' : '可重新描述'
          )
            .fontSize(11)
            .fontColor('#826B4C');

          if (this.recipes.length > 0) {
            Button(this.favoriteBusy ? '处理中...' : (this.isActiveRecipeFavorited() ? '已收藏' : '收藏'))
              .height(30)
              .enabled(!this.favoriteBusy)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isActiveRecipeFavorited() ? '#3D2B16' : '#684B2D')
              .backgroundColor(this.isActiveRecipeFavorited() ? '#E7CDA7' : '#F7EDDE')
              .borderRadius(15)
              .border({
                width: 1,
                color: this.isActiveRecipeFavorited() ? '#D6B485' : '#DDC4A4'
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
        .backgroundColor('#DFCDB1');

      Column() {
        if (this.isLoading) {
          this.buildLoadingBody();
        } else if (this.errorMessage.length > 0) {
          this.buildMessageBody('这次没能顺利配出合适的酒单', this.errorMessage, '#6A2428', '#7E4C4F');
        } else if (this.recipes.length > 0) {
          this.buildRecipeContentCarousel();
        } else {
          this.buildMessageBody(
            '还没找到特别合适的这一杯',
            '换一种说法通常会更准确，比如补充基酒、甜度、酒精感、是否想要气泡，或者告诉我你现在手边有什么材料。',
            '#6D5232',
            '#7B6A57'
          );
        }
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height(490)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor('#F2E5D3')
    .borderRadius(24)
    .border({ width: 1, color: '#D6BE9D' })
    .shadow({ radius: 20, color: '#2A1C0C1A', offsetX: 0, offsetY: 12 });
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
