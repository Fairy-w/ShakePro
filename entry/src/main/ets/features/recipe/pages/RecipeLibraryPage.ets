import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { cocktailRepository } from '../../cocktail/repository/CocktailRepository';
import {
  CocktailCategoryDto,
  CocktailListItemDto,
  CocktailPageDto,
  resolveCocktailListImage
} from '../../cocktail/model/CocktailDetailModels';
import { resolveRecipeHeroImage } from '../model/SystemRecipeData';

interface RecipeCategoryItem {
  id: string;
  label: string;
  description: string;
  icon: string;
}

const ALL_RECIPE_CATEGORY_ID: string = '全部';
const DEFAULT_RECIPE_CATEGORY: RecipeCategoryItem = {
  id: ALL_RECIPE_CATEGORY_ID,
  label: ALL_RECIPE_CATEGORY_ID,
  description: '浏览当前酒谱库',
  icon: 'all'
};

const COCKTAIL_PAGE_SIZE: number = 40;
@Entry
@Component
export struct RecipeLibraryPage {
  @Prop pageBottomInset: number = 0;

  @State private currentCategoryId: string = DEFAULT_RECIPE_CATEGORY.id;
  @State private categoryItems: RecipeCategoryItem[] = [DEFAULT_RECIPE_CATEGORY];
  @State private summaries: CocktailListItemDto[] = [];
  @State private isLoading: boolean = true;
  @State private errorMessage: string = '';
  @State private traceId: string = '';

  private readonly classifyScroller: Scroller = new Scroller();
  private readonly contentScroller: Scroller = new Scroller();
  private cocktailSummaries: CocktailListItemDto[] = [];
  private requestVersion: number = 0;

  aboutToAppear(): void {
    void this.refreshSummaries();
  }

  private resolvePageBottomInset(): number {
    return this.pageBottomInset > 0 ? this.pageBottomInset : 24;
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

  private getCurrentCategory(): RecipeCategoryItem {
    for (let index: number = 0; index < this.categoryItems.length; index += 1) {
      if (this.categoryItems[index].id === this.currentCategoryId) {
        return this.categoryItems[index];
      }
    }
    return DEFAULT_RECIPE_CATEGORY;
  }

  private normalizeCategory(category?: string | null): string {
    return category ? category.trim() : '';
  }

  private buildCategoryDescription(categoryName: string, icon?: string | null): string {
    const normalizedIcon = this.normalizeCategory(icon).toLowerCase();
    if (normalizedIcon === 'classic') {
      return '酒单常驻，适合标准化复刻';
    }
    if (normalizedIcon === 'spirit') {
      return '酒感更强，适合进阶尝试';
    }
    if (normalizedIcon === 'fruity') {
      return '轻盈果香，适合清爽场景';
    }
    if (normalizedIcon === 'low_alcohol') {
      return '保留风味层次，酒精更轻';
    }
    if (normalizedIcon === 'mocktail') {
      return '无醇方案，适合全天候饮用';
    }
    if (normalizedIcon === 'hot') {
      return '适合夜晚或低温场景';
    }
    if (normalizedIcon === 'party') {
      return '适合聚会分享与批量出杯';
    }
    if (normalizedIcon === 'creative') {
      return '尝试更具表达感的特调';
    }
    return `${categoryName} 主题配方`;
  }

  private mapCategoryDto(dto: CocktailCategoryDto): RecipeCategoryItem | null {
    const name = this.normalizeCategory(dto.name);
    if (name.length === 0) {
      return null;
    }
    return {
      id: name,
      label: name,
      description: this.buildCategoryDescription(name, dto.icon),
      icon: this.normalizeCategory(dto.icon)
    } as RecipeCategoryItem;
  }

  private hasCategoryItem(items: RecipeCategoryItem[], categoryId: string): boolean {
    for (let index: number = 0; index < items.length; index += 1) {
      if (items[index].id === categoryId) {
        return true;
      }
    }
    return false;
  }

  private async ensureCategoryItems(): Promise<void> {
    if (this.categoryItems.length > 1) {
      return;
    }

    const remoteCategories = await cocktailRepository.getCocktailCategories();
    const nextItems: RecipeCategoryItem[] = [DEFAULT_RECIPE_CATEGORY];

    for (let index: number = 0; index < remoteCategories.length; index += 1) {
      const mapped = this.mapCategoryDto(remoteCategories[index]);
      if (!mapped) {
        continue;
      }
      if (this.hasCategoryItem(nextItems, mapped.id)) {
        continue;
      }
      nextItems.push(mapped);
    }

    this.categoryItems = nextItems;
    if (!this.hasCategoryItem(nextItems, this.currentCategoryId)) {
      this.currentCategoryId = DEFAULT_RECIPE_CATEGORY.id;
    }
  }

  private resolveErrorMessage(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const code = errorObject['code'];
    const message = errorObject['message'];

    if (typeof code === 'number' && code === 40100) {
      return '登录已失效，请重新登录后查看配方库';
    }
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, '加载配方库失败，请稍后重试');
  }

  private resolveTraceId(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const traceId = errorObject['traceId'];
    if (typeof traceId === 'string') {
      return traceId;
    }
    return '';
  }

  private async fetchAllCocktailSummaries(): Promise<CocktailListItemDto[]> {
    const summaries: CocktailListItemDto[] = [];
    let page: number = 0;

    while (true) {
      const pageData: CocktailPageDto = await cocktailRepository.getCocktailPage({
        page: page,
        size: COCKTAIL_PAGE_SIZE
      });
      const content: CocktailListItemDto[] = pageData.content ?? [];

      for (let i: number = 0; i < content.length; i++) {
        summaries.push(content[i]);
      }

      if (pageData.last === true || content.length === 0) {
        break;
      }

      if (typeof pageData.totalPages === 'number' && page + 1 >= pageData.totalPages) {
        break;
      }

      page += 1;
    }

    return summaries;
  }

  private getMatchedSummaries(categoryId: string): CocktailListItemDto[] {
    if (categoryId === ALL_RECIPE_CATEGORY_ID) {
      const result: CocktailListItemDto[] = [];
      for (let i: number = 0; i < this.cocktailSummaries.length; i++) {
        result.push(this.cocktailSummaries[i]);
      }
      return result;
    }

    const result: CocktailListItemDto[] = [];
    for (let i: number = 0; i < this.cocktailSummaries.length; i++) {
      const item: CocktailListItemDto = this.cocktailSummaries[i];
      if (this.normalizeCategory(item.category) === categoryId) {
        result.push(item);
      }
    }
    return result;
  }

  private async refreshSummaries(): Promise<void> {
    const currentVersion: number = this.requestVersion + 1;
    this.requestVersion = currentVersion;
    this.isLoading = true;
    this.errorMessage = '';
    this.traceId = '';

    try {
      await this.ensureSessionStore();
      await this.ensureCategoryItems();
      if (this.cocktailSummaries.length === 0) {
        this.cocktailSummaries = await this.fetchAllCocktailSummaries();
      }
      if (currentVersion !== this.requestVersion) {
        return;
      }
      this.summaries = this.getMatchedSummaries(this.currentCategoryId);
    } catch (error) {
      if (currentVersion !== this.requestVersion) {
        return;
      }
      this.summaries = [];
      this.errorMessage = this.resolveErrorMessage(error as Object);
      this.traceId = this.resolveTraceId(error as Object);
      promptAction.showToast({ message: this.errorMessage });
    } finally {
      if (currentVersion === this.requestVersion) {
        this.isLoading = false;
      }
    }
  }

  private selectCategory(item: RecipeCategoryItem, index: number): void {
    if (item.id === this.currentCategoryId) {
      return;
    }
    this.currentCategoryId = item.id;
    this.classifyScroller.scrollToIndex(index, true);
    this.errorMessage = '';
    this.traceId = '';

    if (this.cocktailSummaries.length > 0) {
      this.summaries = this.getMatchedSummaries(this.currentCategoryId);
      return;
    }

    void this.refreshSummaries();
  }

  private buildRecipeCountText(): string {
    return `${this.summaries.length} 杯`;
  }

  private formatRecipeIndex(index: number): string {
    const displayIndex: number = index + 1;
    return displayIndex < 10 ? `0${displayIndex}` : String(displayIndex);
  }

  private openRecipeDetail(item: CocktailListItemDto): void {
    router.pushUrl({
      url: 'features/recipe/pages/RecipeDetailPage',
      params: {
        cocktailId: item.id
      }
    }, 3000);
  }

  private resolveSummaryImage(item: CocktailListItemDto): string {
    const imagePath = resolveCocktailListImage(item);
    if (imagePath.length > 0) {
      return String(resolveRecipeHeroImage(imagePath));
    }
    return '';
  }

  @Builder
  private buildHeader() {
    Column({ space: 10 }) {
      Text('配方库')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text('左侧按分类切换，右侧展示酒谱列表，点击后进入独立详情页。')
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20);

      Row({ space: 8 }) {
        Text(this.getCurrentCategory().label)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textAccent)
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor(UiTokens.pageAccentMint)
          .borderRadius(14);

        Text(this.isLoading ? '同步中...' : this.buildRecipeCountText())
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%');

      // Row({ space: 12 }) {
      //   Column()
      //     .width(10)
      //     .height(58)
      //     .borderRadius(8)
      //     .linearGradient({
      //       direction: GradientDirection.Top,
      //       repeating: false,
      //       colors: [[UiTokens.primary, 0.0], [UiTokens.aiSoft, 1.0]]
      //     });
      //
      //   Column({ space: 6 }) {
      //     Text('先看经典酒谱，再决定下一步')
      //       .fontSize(15)
      //       .fontWeight(FontWeight.Bold)
      //       .fontColor(UiTokens.textPrimary);
      //
      //     Text('这里更适合找灵感、挑分类和看标准做法，确认方向后再进入详情页继续查看。')
      //       .fontSize(12)
      //       .fontColor(UiTokens.textSecondary)
      //       .lineHeight(18);
      //   }
      //   .layoutWeight(1)
      //   .alignItems(HorizontalAlign.Start);
      // }
      // .width('100%')
      // .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      // .backgroundColor(UiTokens.surfacePrimary)
      // .borderRadius(20)
      // .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildCategoryItem(item: RecipeCategoryItem, index: number) {
    ListItem() {
      Column({ space: 6 }) {
        Text(item.label)
          .fontSize(14)
          .fontWeight(item.id === this.currentCategoryId ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(item.id === this.currentCategoryId ? UiTokens.textPrimary : UiTokens.textSecondary)
          .textAlign(TextAlign.Center);

        Text(item.description)
          .fontSize(10)
          .fontColor(item.id === this.currentCategoryId ? UiTokens.textAccent : UiTokens.textTertiary)
          .textAlign(TextAlign.Center)
          .maxLines(2);
      }
      .width('100%')
      .padding({ top: 14, bottom: 14, left: 10, right: 10 })
      .backgroundColor(item.id === this.currentCategoryId ? UiTokens.pageAccentMint : UiTokens.surfacePrimary)
      .borderRadius(20)
      .border({ width: 1, color: item.id === this.currentCategoryId ? UiTokens.borderStrong : UiTokens.borderPrimary })
      .shadow({ radius: item.id === this.currentCategoryId ? 12 : 0, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 6 })
      .onClick(() => {
        this.selectCategory(item, index);
      });
    }
    .margin({ bottom: 10 });
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(26)
        .height(26)
        .color(UiTokens.textPrimary);

      Text('正在同步配方库...')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Text('已读取左侧分类，正在加载匹配的鸡尾酒列表。')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(18)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildErrorState() {
    Column({ space: 12 }) {
      Text('配方库加载失败')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text(this.errorMessage)
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      if (this.traceId.length > 0) {
        Text(`问题编号：${this.traceId}`)
          .fontSize(11)
          .fontColor(UiTokens.textTertiary)
          .textAlign(TextAlign.Center);
      }

      Button('重新加载')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.pageAccentMint)
        .borderRadius(16)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          void this.refreshSummaries();
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 12 }) {
      Text('当前分类还没有可展示的配方')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      Text(`已按「${this.getCurrentCategory().label}」筛选，暂未找到完全匹配的酒谱。`)
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildSummaryCard(item: CocktailListItemDto, index: number) {
    ListItem() {
      Row({ space: 14 }) {
        if (this.resolveSummaryImage(item).length > 0) {
          Image(this.resolveSummaryImage(item))
            .width(104)
            .height(132)
            .borderRadius(22)
            .objectFit(ImageFit.Cover);
        }

        Column({ space: 9 }) {
          Row({ space: 8 }) {
            Text(this.formatRecipeIndex(index))
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor(UiTokens.textAccent)
              .padding({ left: 9, right: 9, top: 6, bottom: 6 })
              .backgroundColor(UiTokens.pageAccentMint)
              .borderRadius(14);

            if (this.normalizeCategory(item.category).length > 0) {
              Text(this.normalizeCategory(item.category))
                .fontSize(11)
                .fontColor(UiTokens.textSecondary)
                .padding({ left: 9, right: 9, top: 6, bottom: 6 })
                .backgroundColor(UiTokens.surfaceMuted)
                .borderRadius(14);
            }
          }

          Column({ space: 4 }) {
            Text(item.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(UiTokens.textPrimary)
              .maxLines(2);

            if (item.englishName && item.englishName.trim().length > 0) {
              Text(item.englishName)
                .fontSize(12)
                .fontColor(UiTokens.textSecondary)
                .maxLines(1);
            }
          }
          .alignItems(HorizontalAlign.Start);

          Row({ space: 8 }) {
            if (item.difficulty && item.difficulty.trim().length > 0) {
              Text(item.difficulty)
                .fontSize(11)
                .fontColor(UiTokens.textAccent)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .backgroundColor(UiTokens.surfaceSecondary)
                .borderRadius(12);
            }

            if (item.abv && item.abv.trim().length > 0) {
              Text(item.abv)
                .fontSize(11)
                .fontColor(UiTokens.warning)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .backgroundColor(UiTokens.warningSoft)
                .borderRadius(12);
            }
          }

          Text('查看配方详情')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textAccent);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding(16)
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(24)
      .border({ width: 1, color: UiTokens.borderPrimary })
      .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 })
      .onClick(() => {
        this.openRecipeDetail(item);
      });
    }
  }

  @Builder
  private buildSummaryList() {
    Column() {
      List({ scroller: this.contentScroller, space: 14 }) {
        ForEach(this.summaries, (item: CocktailListItemDto, index: number) => {
          this.buildSummaryCard(item, index);
        }, (item: CocktailListItemDto) => String(item.id));
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Vertical);
    }
    .layoutWeight(1)
    .height('100%');
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.56], [UiTokens.pageGradientEnd, 1.0]]
        });

      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor(UiTokens.pageAccentBlue)
        .opacity(0.52)
        .position({ x: -70, y: -36 });

      Column()
        .width(220)
        .height(220)
        .borderRadius(110)
        .backgroundColor(UiTokens.pageAccentMint)
        .opacity(0.72)
        .position({ x: 250, y: 600 });

      Column({ space: 16 }) {
        this.buildHeader();

        Row({ space: 14 }) {
          List({ scroller: this.classifyScroller, initialIndex: 0 }) {
            ForEach(this.categoryItems, (item: RecipeCategoryItem, index: number) => {
              this.buildCategoryItem(item, index);
            }, (item: RecipeCategoryItem) => item.id);
          }
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
          .width(102)
          .height('100%');

          if (this.isLoading) {
            Column() {
              this.buildLoadingState();
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Start);
          } else if (this.errorMessage.length > 0) {
            Column() {
              this.buildErrorState();
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Start);
          } else if (this.summaries.length === 0) {
            Column() {
              this.buildEmptyState();
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Start);
          } else {
            Column() {
              this.buildSummaryList();
            }
            .layoutWeight(1)
            .height('100%');
          }
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top);
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: this.resolvePageBottomInset() });
    }
    .width('100%')
    .height('100%');
  }
}
