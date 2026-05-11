import { RoutePaths } from '../../../core/router/RoutePaths';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { sessionStore } from '../../../common/storage/SessionStore';
import { CocktailListItemDto } from '../../cocktail/model/CocktailDetailModels';
import { FavoriteRecipeCard } from '../components/FavoriteRecipeCard';
import { SystemFavoriteRecipeCard } from '../components/SystemFavoriteRecipeCard';
import { FavoriteAiCocktailItem } from '../model/FavoriteAiCocktailModels';
import { favoriteRepository } from '../repository/FavoriteRepository';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
const SYSTEM_FAVORITE_TAB: string = 'system';
const AI_FAVORITE_TAB: string = 'ai';

@Entry({ routeName: 'MyFavoritePage' })
@Component
export struct MyFavoritePage {
  @State private isLoading: boolean = true;
  @State private isAuthorized: boolean = false;
  @State private activeTab: string = SYSTEM_FAVORITE_TAB;
  @State private systemFavorites: CocktailListItemDto[] = [];
  @State private isSystemLoading: boolean = false;
  @State private systemErrorMessage: string = '';
  @State private removingSystemCocktailId: number = -1;
  @State private favorites: FavoriteAiCocktailItem[] = [];
  @State private aiErrorMessage: string = '';
  @State private isAiLoading: boolean = false;
  @State private removingFavoriteId: number = -1;
  @State private currentCatalogIndex: number = 0;

  private catalogScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    void this.loadFavorites();
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

  private resolveErrorMessage(error: Object, fallbackMessage: string = '加载收藏失败'): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private async loadFavorites(): Promise<void> {
    this.isLoading = true;
    this.systemErrorMessage = '';
    this.aiErrorMessage = '';

    try {
      await this.ensureSessionStore();
      const authorization: string = await sessionStore.getAuthorizationValue();
      this.isAuthorized = authorization.trim().length > 0;

      if (!this.isAuthorized) {
        this.systemFavorites = [];
        this.favorites = [];
        this.currentCatalogIndex = 0;
        return;
      }

      await this.loadSystemFavorites(true);
      await this.loadAiFavorites(true);
    } catch (error) {
      const message: string = this.resolveErrorMessage(error, '加载收藏失败，请稍后再试');
      this.isAuthorized = true;
      this.systemFavorites = [];
      this.favorites = [];
      this.systemErrorMessage = message;
      this.aiErrorMessage = message;
    } finally {
      this.isLoading = false;
    }
  }

  private async loadSystemFavorites(isInitialLoad: boolean = false): Promise<void> {
    if (!isInitialLoad) {
      this.isSystemLoading = true;
    }
    this.systemErrorMessage = '';

    try {
      this.systemFavorites = await favoriteRepository.getSystemFavoriteList();
    } catch (error) {
      this.systemFavorites = [];
      this.systemErrorMessage = this.resolveErrorMessage(error, '加载系统收藏失败，请稍后再试');
    } finally {
      if (!isInitialLoad) {
        this.isSystemLoading = false;
      }
    }
  }

  private async loadAiFavorites(isInitialLoad: boolean = false): Promise<void> {
    if (!isInitialLoad) {
      this.isAiLoading = true;
    }
    this.aiErrorMessage = '';

    try {
      const response = await favoriteRepository.getAiCocktailList({
        pageNo: 1,
        pageSize: 100,
        sort: 'createdAt,desc'
      });
      this.favorites = response.list ?? [];
      this.currentCatalogIndex = 0;
    } catch (error) {
      this.favorites = [];
      this.aiErrorMessage = this.resolveErrorMessage(error, '加载收藏失败，请稍后再试');
    } finally {
      if (!isInitialLoad) {
        this.isAiLoading = false;
      }
    }
  }

  private openSystemFavoriteDetail(item: CocktailListItemDto): void {
    router.pushUrl({
      url: RoutePaths.RECIPE_DETAIL,
      params: {
        cocktailId: item.id
      }
    }, 3000);
  }

  private async removeSystemFavorite(item: CocktailListItemDto): Promise<void> {
    if (this.removingSystemCocktailId !== -1) {
      return;
    }

    this.removingSystemCocktailId = item.id;
    try {
      await favoriteRepository.removeSystemFavorite(item.id);
      this.systemFavorites = this.systemFavorites.filter((favorite: CocktailListItemDto): boolean => favorite.id !== item.id);
      promptAction.showToast({ message: '已取消收藏' });
    } catch (error) {
      promptAction.showToast({ message: this.resolveErrorMessage(error, '取消收藏失败，请稍后再试') });
    } finally {
      this.removingSystemCocktailId = -1;
    }
  }

  private async removeFavorite(item: FavoriteAiCocktailItem): Promise<void> {
    if (this.removingFavoriteId !== -1) {
      return;
    }

    this.removingFavoriteId = item.favoriteId;
    try {
      await favoriteRepository.deleteAiCocktailById(item.favoriteId);
      this.favorites = this.favorites.filter((favorite: FavoriteAiCocktailItem): boolean => favorite.favoriteId !== item.favoriteId);
      if (this.favorites.length === 0) {
        this.currentCatalogIndex = 0;
      } else if (this.currentCatalogIndex >= this.favorites.length) {
        this.currentCatalogIndex = this.favorites.length - 1;
      }
      promptAction.showToast({ message: '已取消收藏' });
    } catch (error) {
      promptAction.showToast({ message: this.resolveErrorMessage(error, '取消收藏失败，请稍后再试') });
    } finally {
      this.removingFavoriteId = -1;
    }
  }

  private scrollCatalogToCenter(index: number): void {
    if (this.favorites.length <= 1) {
      return;
    }

    let anchorIndex: number = index;
    if (index > 0 && index < this.favorites.length - 1) {
      anchorIndex = index - 1;
    } else if (index >= this.favorites.length - 1) {
      anchorIndex = Math.max(0, this.favorites.length - 2);
    }

    this.catalogScroller.scrollToIndex(anchorIndex + 1, true);
  }

  @Builder
  private buildCatalogPill(item: FavoriteAiCocktailItem, index: number) {
    Column({ space: 6 }) {
      if (this.currentCatalogIndex === index) {
        Column()
          .width(28)
          .height(4)
          .borderRadius(2)
          .backgroundColor(UiTokens.accentWarmSoft);
      }

      Text(item.name)
        .fontSize(11)
        .fontWeight(this.currentCatalogIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentCatalogIndex === index ? UiTokens.textPrimary : UiTokens.textSecondary)
        .textAlign(TextAlign.Center);
    }
    .constraintSize({ maxWidth: 220 })
    .padding({
      left: 14,
      right: 14,
      top: this.currentCatalogIndex === index ? 10 : 12,
      bottom: 12
    })
    .backgroundColor(this.currentCatalogIndex === index ? UiTokens.accentWarm : UiTokens.surfaceSecondary)
    .borderRadius(18)
    .border({
      width: 1,
      color: this.currentCatalogIndex === index ? UiTokens.borderWarm : UiTokens.borderPrimary
    })
    .shadow({
      radius: this.currentCatalogIndex === index ? 16 : 8,
      color: this.currentCatalogIndex === index ? UiTokens.shadowMedium : UiTokens.shadowSoft,
      offsetX: 0,
      offsetY: this.currentCatalogIndex === index ? 8 : 4
    })
    .onClick(() => {
      this.currentCatalogIndex = index;
      this.scrollCatalogToCenter(index);
    });
  }

  @Builder
  private buildTabItem(tabKey: string, title: string, count: number) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(this.activeTab === tabKey ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.activeTab === tabKey ? UiTokens.textInverse : UiTokens.textSecondary);

      Text(`${count} 项`)
        .fontSize(11)
        .fontColor(this.activeTab === tabKey ? UiTokens.accentWarmSoft : UiTokens.textTertiary);
    }
    .padding({ left: 18, right: 18, top: 12, bottom: 12 })
    .backgroundColor(this.activeTab === tabKey ? UiTokens.brandStrong : UiTokens.surfacePrimary)
    .borderRadius(18)
    .border({ width: 1, color: this.activeTab === tabKey ? UiTokens.borderStrong : UiTokens.borderPrimary })
    .layoutWeight(1)
    .onClick(() => {
      this.activeTab = tabKey;
    });
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('我的收藏')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('系统酒谱与 AI 结果都收拢在这里，方便回看和继续生成。')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('返回')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textAccent)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildTabBar() {
    Row({ space: 10 }) {
      this.buildTabItem(SYSTEM_FAVORITE_TAB, '系统收藏', this.systemFavorites.length);
      this.buildTabItem(AI_FAVORITE_TAB, 'AI 收藏', this.favorites.length);
    }
    .width('100%');
  }

  @Builder
  private buildStickyCatalog() {
    Column({ space: 10 }) {
      Row() {
        Text('收藏目录')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.accentWarmSoft);

        Blank();

        Text(`${this.currentCatalogIndex + 1} / ${this.favorites.length}`)
          .fontSize(10)
          .fontColor(UiTokens.textTertiary);
      }
      .width('100%');
      List({ scroller: this.catalogScroller, space: 10, initialIndex: 0 }) {
        ListItem() {
          Row() {
            Blank()
              .width(26)
              .height(1);
          }
        }

        ForEach(this.favorites, (item: FavoriteAiCocktailItem, index: number) => {
          ListItem() {
            this.buildCatalogPill(item, index);
          }
        }, (item: FavoriteAiCocktailItem) => `catalog-${item.favoriteId}-${item.recipeKey}`);
        ListItem() {
          Row() {
            Blank()
              .width(26)
              .height(1);
          }
        }
      }
      .width('100%')
      .height(52)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 12, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 14 }) {
      Text('正在整理你的收藏...')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Column()
        .width('100%')
        .height(220)
        .borderRadius(24)
        .backgroundColor(UiTokens.surfaceSecondary)
        .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%')
    .padding({ top: 28 });
  }

  @Builder
  private buildUnauthorizedState() {
    Column({ space: 16 }) {
      Text(this.activeTab === SYSTEM_FAVORITE_TAB ? '登录后才能查看系统收藏' : '登录后才能查看收藏的 AI 配方')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      Text(this.activeTab === SYSTEM_FAVORITE_TAB
        ? '先登录账号，再把喜欢的酒谱保存到系统收藏里。'
        : '先登录账号，再把喜欢的推荐长期保存下来。')
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      Button('去登录')
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarm)
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({ url: RoutePaths.LOGIN });
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 26, bottom: 26 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .margin({ top: 18 });
  }

  @Builder
  private buildSystemLoadingState() {
    Column({ space: 14 }) {
      Text('正在同步系统收藏...')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Column()
        .width('100%')
        .height(220)
        .borderRadius(24)
        .backgroundColor(UiTokens.surfaceSecondary)
        .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%')
    .padding({ top: 28 });
  }

  @Builder
  private buildErrorState() {
    Column({ space: 14 }) {
      Text(this.activeTab === SYSTEM_FAVORITE_TAB ? '这次没能顺利加载系统收藏' : '这次没能顺利加载收藏')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Text(this.activeTab === SYSTEM_FAVORITE_TAB ? this.systemErrorMessage : this.aiErrorMessage)
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20);

      Button('重新加载')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarm)
        .borderRadius(15)
        .onClick(() => {
          if (this.activeTab === SYSTEM_FAVORITE_TAB) {
            void this.loadSystemFavorites();
          } else {
            void this.loadAiFavorites();
          }
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .margin({ top: 18 });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 14 }) {
      Text(this.activeTab === SYSTEM_FAVORITE_TAB ? '你还没有收藏系统酒谱' : '你还没有收藏的配方')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);

      Text(this.activeTab === SYSTEM_FAVORITE_TAB
        ? '下次在配方详情页看到喜欢的那一杯，点一下收藏就会出现在这里。'
        : '下次在 AI 调酒页看到喜欢的那一杯，点一下收藏就会出现在这里。')
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20);

      Button(this.activeTab === SYSTEM_FAVORITE_TAB ? '去配方库' : '去 AI 调酒')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.accentWarm)
        .borderRadius(15)
        .onClick(() => {
          if (this.activeTab === SYSTEM_FAVORITE_TAB) {
            router.pushUrl({ url: RoutePaths.RECIPE_LIBRARY });
          } else {
            router.pushUrl({ url: RoutePaths.AI_COCKTAIL });
          }
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .margin({ top: 18 });
  }

  @Builder
  private buildSystemListState() {
    List({ space: 16 }) {
      ForEach(this.systemFavorites, (item: CocktailListItemDto) => {
        ListItem() {
          SystemFavoriteRecipeCard({
            item,
            isRemoving: this.removingSystemCocktailId === item.id,
            onOpen: (favorite: CocktailListItemDto) => {
              this.openSystemFavoriteDetail(favorite);
            },
            onRemove: (favorite: CocktailListItemDto) => {
              void this.removeSystemFavorite(favorite);
            }
          });
        }
      }, (item: CocktailListItemDto) => String(item.id));
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Vertical)
    .padding({ top: 6, bottom: 12 });
  }

  @Builder
  private buildAiListState() {
    Column({ space: 10 }) {
      this.buildStickyCatalog();
      Swiper() {
        ForEach(this.favorites, (item: FavoriteAiCocktailItem) => {
          Scroll() {
            FavoriteRecipeCard({
              item,
              isRemoving: this.removingFavoriteId === item.favoriteId,
              onRemove: (favorite: FavoriteAiCocktailItem) => {
                void this.removeFavorite(favorite);
              }
            });
          }
          .width('100%')
          .scrollBar(BarState.Off);
        }, (item: FavoriteAiCocktailItem) => `${item.favoriteId}-${item.recipeKey}`);
      }
      .layoutWeight(1)
      .width('100%')
      .indicator(false)
      .index(this.currentCatalogIndex)
      .loop(false)
      .onChange((index: number) => {
        if (index >= 0 && index < this.favorites.length) {
          this.currentCatalogIndex = index;
          this.scrollCatalogToCenter(index);
        }
      });
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: 4, bottom: 12 });
  }

  @Builder
  private buildCurrentTabContent() {
    if (!this.isAuthorized) {
      this.buildUnauthorizedState();
    } else if (this.activeTab === SYSTEM_FAVORITE_TAB) {
      if (this.isSystemLoading) {
        this.buildSystemLoadingState();
      } else if (this.systemErrorMessage.length > 0) {
        this.buildErrorState();
      } else if (this.systemFavorites.length === 0) {
        this.buildEmptyState();
      } else {
        this.buildSystemListState();
      }
    } else if (this.isAiLoading) {
      this.buildLoadingState();
    } else if (this.aiErrorMessage.length > 0) {
      this.buildErrorState();
    } else if (this.favorites.length === 0) {
      this.buildEmptyState();
    } else {
      this.buildAiListState();
    }
  }

  build() {
    Column({ space: 12 }) {
      this.buildTopBar();

      if (this.isLoading) {
        this.buildLoadingState();
      } else {
        this.buildTabBar();
        this.buildCurrentTabContent();
      }
    }
    .padding({ left: 18, right: 18, top: 16, bottom: 20 })
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground)
    .alignItems(HorizontalAlign.Start);
  }
}
