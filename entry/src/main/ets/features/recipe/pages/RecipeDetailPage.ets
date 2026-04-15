import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { RecipeDetailHeader } from '../components/RecipeDetailHeader';
import { RecipeFlavorSection } from '../components/RecipeFlavorSection';
import { RecipeHeroCard } from '../components/RecipeHeroCard';
import { RecipeOverviewSection } from '../components/RecipeOverviewSection';
import { RecipeProductionCapsule } from '../components/RecipeProductionCapsule';
import { RecipeServeSection } from '../components/RecipeServeSection';
import { sessionStore } from '../../../common/storage/SessionStore';
import { cocktailRepository } from '../../cocktail/repository/CocktailRepository';
import { mapCocktailDetailToSystemRecipe } from '../model/RecipeDetailMapper';
import { EMPTY_SYSTEM_RECIPE, RecipeIngredient, RecipeStep, SystemRecipe } from '../model/SystemRecipeData';

interface RecipeRouteParams {
  cocktailId?: string | number;
  recipeId?: string | number;
}

@Entry({ routeName: 'RecipeDetailPage' })
@Component
export struct RecipeDetailPage {
  @State private recipe: SystemRecipe = EMPTY_SYSTEM_RECIPE;
  @State private isLoading: boolean = true;
  @State private errorMessage: string = '';
  @State private traceId: string = '';
  @State private isMinimalView: boolean = false;
  @State private bookmarkedRecipeIds: string[] = [];

  aboutToAppear(): void {
    void this.loadRecipeDetail();
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private async ensureSessionStore(): Promise<void> {
    if (sessionStore.isInitialized()) {
      return;
    }
    await sessionStore.init(this.getHostContext());
  }

  private normalizeRouteId(value?: string | number): string {
    if (typeof value === 'number') {
      return String(value);
    }
    if (typeof value === 'string') {
      return value.trim();
    }
    return '';
  }

  private resolveRouteCocktailId(): string {
    const routeParams: RecipeRouteParams = router.getParams() as RecipeRouteParams;
    const cocktailId = this.normalizeRouteId(routeParams?.cocktailId);
    if (cocktailId.length > 0) {
      return cocktailId;
    }
    return this.normalizeRouteId(routeParams?.recipeId);
  }

  private isNumericId(value: string): boolean {
    return /^[0-9]+$/.test(value);
  }

  private resolveErrorMessage(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const code = errorObject['code'];
    const message = errorObject['message'];

    if (typeof code === 'number') {
      if (code === 40100) {
        return '登录已失效，请重新登录后查看详情';
      }
      if (code === 40400) {
        return '这杯鸡尾酒不存在或已下线';
      }
    }

    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }

    return '加载鸡尾酒详情失败，请稍后重试';
  }

  private resolveTraceId(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const traceId = errorObject['traceId'];
    if (typeof traceId === 'string') {
      return traceId;
    }
    return '';
  }

  private async loadRecipeDetail(): Promise<void> {
    const routeCocktailId = this.resolveRouteCocktailId();
    this.isLoading = true;
    this.errorMessage = '';
    this.traceId = '';

    if (!routeCocktailId || !this.isNumericId(routeCocktailId)) {
      this.isLoading = false;
      this.errorMessage = '缺少有效的鸡尾酒 ID，请从酒单页重新进入';
      return;
    }

    try {
      await this.ensureSessionStore();
      const detail = await cocktailRepository.getCocktailDetail(routeCocktailId);
      this.recipe = mapCocktailDetailToSystemRecipe(detail);
    } catch (error) {
      this.errorMessage = this.resolveErrorMessage(error as Object);
      this.traceId = this.resolveTraceId(error as Object);
      promptAction.showToast({ message: this.errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  private isCurrentRecipeBookmarked(): boolean {
    return this.bookmarkedRecipeIds.indexOf(this.recipe.id) !== -1;
  }

  private toggleBookmark(): void {
    if (this.isCurrentRecipeBookmarked()) {
      this.bookmarkedRecipeIds = this.bookmarkedRecipeIds.filter((recipeId: string): boolean => recipeId !== this.recipe.id);
      promptAction.showToast({ message: '已取消收藏' });
      return;
    }

    this.bookmarkedRecipeIds = this.bookmarkedRecipeIds.concat([this.recipe.id]);
    promptAction.showToast({ message: '已加入收藏' });
  }

  private showMockDataHint(): void {
    promptAction.showToast({ message: '向下滑动，继续查看材料、步骤和享用建议' });
  }

  private toggleMinimalView(): void {
    this.isMinimalView = !this.isMinimalView;
    promptAction.showToast({ message: this.isMinimalView ? '已切换到极简视图' : '已恢复完整视图' });
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 14 }) {
      LoadingProgress()
        .width(26)
        .height(26)
        .color('#B68961');

      Text('正在加载鸡尾酒详情...')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#56473A');

      Text('已连接后端接口，正在同步这杯酒的风味、材料和步骤。')
        .fontSize(12)
        .fontColor('#8A7968')
        .textAlign(TextAlign.Center)
        .lineHeight(18);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 26, bottom: 26 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' });
  }

  @Builder
  private buildErrorState() {
    Column({ space: 14 }) {
      Text('详情加载失败')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3A2417');

      Text(this.errorMessage)
        .fontSize(13)
        .fontColor('#7B6555')
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      if (this.traceId.length > 0) {
        Text(`traceId: ${this.traceId}`)
          .fontSize(11)
          .fontColor('#9C8472')
          .textAlign(TextAlign.Center);
      }

      Button('重新加载')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2F2118')
        .backgroundColor('#E7CDA7')
        .borderRadius(16)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          void this.loadRecipeDetail();
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 22, bottom: 22 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' })
    .shadow({ radius: 18, color: '#A27A3A12', offsetX: 0, offsetY: 10 });
  }

  @Builder
  private buildViewModeCard() {
    Row({ space: 14 }) {
      Column({ space: 6 }) {
        Text(this.isMinimalView ? '极简视图已开启' : '一键切换极简视图')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2A1C14');

        Text(this.isMinimalView ? '当前只保留材料和步骤，适合边看边做。' : '隐藏风味解读和附加信息，马上进入调制模式。')
          .fontSize(12)
          .fontColor('#7D6A5A')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button(this.isMinimalView ? '完整视图' : '极简视图')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isMinimalView ? '#2E2118' : '#FFF9EF')
        .backgroundColor(this.isMinimalView ? '#F4E4CF' : '#1F1712')
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          this.toggleMinimalView();
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFBF5')
    .borderRadius(24)
    .border({ width: 1, color: '#F0DEC5' })
    .shadow({ radius: 18, color: '#A27A3A12', offsetX: 0, offsetY: 10 });
  }

  @Builder
  private buildMinimalHeroCard() {
    Column({ space: 10 }) {
      Text(this.recipe.name)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#201812');

      if (this.recipe.englishName.length > 0) {
        Text(this.recipe.englishName)
          .fontSize(13)
          .fontColor('#8D7258')
          .letterSpacing(0.6);
      }

      Row({ space: 8 }) {
        if (this.recipe.difficulty.length > 0) {
          Text(this.recipe.difficulty)
            .fontSize(11)
            .fontColor('#3A2B1E')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#F4E4CF')
            .borderRadius(14);
        }

        if (this.recipe.abv.length > 0) {
          Text(this.recipe.abv)
            .fontSize(11)
            .fontColor('#3A2B1E')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#F7EFE2')
            .borderRadius(14);
        }
      }

      Text('准备好材料后，直接按顺序完成即可。')
        .fontSize(13)
        .fontColor('#6E5D4E')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor('#FFF8F0')
    .borderRadius(28)
    .border({ width: 1, color: '#F0DEC5' });
  }

  @Builder
  private buildMinimalSectionTitle(title: string, detail: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#201812');

        Text(detail)
          .fontSize(12)
          .fontColor('#857464');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();
    }
    .width('100%');
  }

  @Builder
  private buildMinimalIngredientRow(name: string, amount: string, note: string, index: number) {
    Row({ space: 12 }) {
      Text(`${index + 1}`)
        .width(28)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3A281C')
        .textAlign(TextAlign.Center);

      Column({ space: 4 }) {
        Text(name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#201812');

        if (note.length > 0) {
          Text(note)
            .fontSize(12)
            .fontColor('#75675C')
            .lineHeight(18);
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      if (amount.length > 0) {
        Text(amount)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3C2B1D')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#FFF0DB')
          .borderRadius(12);
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(index % 2 === 0 ? '#FFFBF5' : '#FFF7EE')
    .borderRadius(20)
    .border({ width: 1, color: '#F0DEC5' });
  }

  @Builder
  private buildMinimalStepRow(title: string, detail: string, index: number) {
    Row({ space: 14 }) {
      Text(`${index + 1}`)
        .width(34)
        .height(34)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFF8EF')
        .textAlign(TextAlign.Center)
        .backgroundColor('#201712')
        .borderRadius(17);

      Column({ space: 6 }) {
        Text(title.length > 0 ? title : `步骤 ${index + 1}`)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#201812');

        Text(detail)
          .fontSize(13)
          .fontColor('#6F6258')
          .lineHeight(20);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#FFFBF5')
    .borderRadius(20)
    .border({ width: 1, color: '#F0DEC5' });
  }

  @Builder
  private buildMinimalContent() {
    Column({ space: 18 }) {
      this.buildMinimalHeroCard();

      Column({ space: 12 }) {
        this.buildMinimalSectionTitle('材料清单', `${this.recipe.ingredients.length} 项准备`)

        if (this.recipe.ingredients.length === 0) {
          Text('当前没有可展示的材料信息。')
            .width('100%')
            .fontSize(13)
            .fontColor('#7F6D5D')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor('#FFFBF5')
            .borderRadius(18)
            .border({ width: 1, color: '#F0DEC5' });
        } else {
          Column({ space: 10 }) {
            ForEach(this.recipe.ingredients, (item: RecipeIngredient, index: number) => {
              this.buildMinimalIngredientRow(item.name, item.amount, item.note, index);
            }, (item: RecipeIngredient, index: number) => `${this.recipe.id}-minimal-ingredient-${index}-${item.name}`);
          }
          .width('100%');
        }
      }
      .width('100%');

      Column({ space: 12 }) {
        this.buildMinimalSectionTitle('调制步骤', `${this.recipe.steps.length} 步完成`)

        if (this.recipe.steps.length === 0) {
          Text('当前没有可展示的步骤信息。')
            .width('100%')
            .fontSize(13)
            .fontColor('#7F6D5D')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor('#FFFBF5')
            .borderRadius(18)
            .border({ width: 1, color: '#F0DEC5' });
        } else {
          Column({ space: 10 }) {
            ForEach(this.recipe.steps, (item: RecipeStep, index: number) => {
              this.buildMinimalStepRow(item.title, item.detail, index);
            }, (item: RecipeStep, index: number) => `${this.recipe.id}-minimal-step-${index}-${item.title}`);
          }
          .width('100%');
        }
      }
      .width('100%');
    }
    .width('100%');
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#F5EFE7', 0.0], ['#F7F4EE', 0.42], ['#F3EFE8', 1.0]]
        })

      Column()
        .width(220)
        .height(220)
        .borderRadius(110)
        .backgroundColor('#F0DDC0')
        .opacity(0.42)
        .position({ x: -70, y: 140 });

      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor('#D9EAF0')
        .opacity(0.4)
        .position({ x: 210, y: 540 });

      Scroll() {
        Column({ space: 18 }) {
          RecipeDetailHeader({
            isBookmarked: this.isCurrentRecipeBookmarked(),
            onBack: () => {
              router.back();
            },
            onToggleBookmark: () => {
              this.toggleBookmark();
            },
            onShowMockHint: () => {
              this.showMockDataHint();
            }
          });

          if (this.isLoading) {
            this.buildLoadingState();
          } else if (this.errorMessage.length > 0) {
            this.buildErrorState();
          } else {
            this.buildViewModeCard();

            if (this.isMinimalView) {
              this.buildMinimalContent();
            } else {
              RecipeHeroCard({ recipe: this.recipe });
              RecipeOverviewSection({ recipe: this.recipe });
              RecipeFlavorSection({ recipe: this.recipe });
              RecipeProductionCapsule({ recipe: this.recipe });
              RecipeServeSection({ recipe: this.recipe });
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 18, bottom: 34 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%');
  }
}
