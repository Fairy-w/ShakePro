import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { sessionStore } from '../../../common/storage/SessionStore';
import { FavoriteRecipeCard } from '../components/FavoriteRecipeCard';
import { FavoriteAiCocktailItem } from '../model/FavoriteAiCocktailModels';
import { favoriteRepository } from '../repository/FavoriteRepository';

@Entry({ routeName: 'MyFavoritePage' })
@Component
export struct MyFavoritePage {
  @State private isLoading: boolean = true;
  @State private isAuthorized: boolean = false;
  @State private errorMessage: string = '';
  @State private favorites: FavoriteAiCocktailItem[] = [];
  @State private removingFavoriteId: number = -1;
  @State private currentCatalogIndex: number = 0;

  private favoriteScroller: Scroller = new Scroller();
  private catalogScroller: Scroller = new Scroller();
  private isCatalogAutoScrolling: boolean = false;
  private catalogTargetIndex: number = -1;

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
    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }
    return fallbackMessage;
  }

  private async loadFavorites(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      await this.ensureSessionStore();
      const authorization: string = await sessionStore.getAuthorizationValue();
      this.isAuthorized = authorization.trim().length > 0;

      if (!this.isAuthorized) {
        this.favorites = [];
        return;
      }

      const response = await favoriteRepository.getAiCocktailList({
        pageNo: 1,
        pageSize: 100,
        sort: 'createdAt,desc'
      });
      this.favorites = response.list ?? [];
      this.currentCatalogIndex = 0;
      this.isCatalogAutoScrolling = false;
      this.catalogTargetIndex = -1;
    } catch (error) {
      this.errorMessage = this.resolveErrorMessage(error, '加载收藏失败，请稍后再试');
    } finally {
      this.isLoading = false;
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
      this.isCatalogAutoScrolling = false;
      this.catalogTargetIndex = -1;
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
          .backgroundColor('#FFF4E2');
      }

      Text(item.name)
        .fontSize(11)
        .fontWeight(this.currentCatalogIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentCatalogIndex === index ? '#23160C' : '#E2D1B6')
        .textAlign(TextAlign.Center);
    }
    .constraintSize({ maxWidth: 220 })
    .padding({
      left: 14,
      right: 14,
      top: this.currentCatalogIndex === index ? 10 : 12,
      bottom: 12
    })
    .backgroundColor(this.currentCatalogIndex === index ? '#E3BE8D' : '#141816')
    .borderRadius(18)
    .border({
      width: 1,
      color: this.currentCatalogIndex === index ? '#F0D3AA' : '#2A2F2A'
    })
    .shadow({
      radius: this.currentCatalogIndex === index ? 16 : 8,
      color: this.currentCatalogIndex === index ? '#D8B07A33' : '#00000012',
      offsetX: 0,
      offsetY: this.currentCatalogIndex === index ? 8 : 4
    })
    .onClick(() => {
      this.isCatalogAutoScrolling = true;
      this.catalogTargetIndex = index;
      this.currentCatalogIndex = index;
      this.scrollCatalogToCenter(index);
      this.favoriteScroller.scrollToIndex(index, true);
    });
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column() {
        Text('我的收藏')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F7F0E4');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Button('返回')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F3E6D2')
        .backgroundColor('#171A18')
        .borderRadius(16)
        .border({ width: 1, color: '#2A2E2A' })
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildStickyCatalog() {
    Column({ space: 10 }) {
      Row() {
        Text('收藏目录')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F4E7D3');

        Blank();

        Text(`${this.currentCatalogIndex + 1} / ${this.favorites.length}`)
          .fontSize(10)
          .fontColor('#A89A86');
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
    .backgroundColor('#111412')
    .borderRadius(22)
    .border({ width: 1, color: '#232823' })
    .shadow({ radius: 12, color: '#00000022', offsetX: 0, offsetY: 8 });
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 14 }) {
      Text('正在整理你的收藏...')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F5ECDD');

      Column()
        .width('100%')
        .height(220)
        .borderRadius(24)
        .backgroundColor('#161917')
        .border({ width: 1, color: '#242824' });
    }
    .width('100%')
    .padding({ top: 28 });
  }

  @Builder
  private buildUnauthorizedState() {
    Column({ space: 16 }) {
      Text('登录后才能查看收藏的 AI 配方')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F7F0E4')
        .textAlign(TextAlign.Center);

      Text('先登录账号，再把喜欢的推荐长期保存下来。')
        .fontSize(13)
        .fontColor('#A79A88')
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      Button('去登录')
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#241A10')
        .backgroundColor('#D4B181')
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({ url: 'features/auth/pages/LoginPage' });
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 26, bottom: 26 })
    .backgroundColor('#121513')
    .borderRadius(24)
    .border({ width: 1, color: '#232823' })
    .margin({ top: 18 });
  }

  @Builder
  private buildErrorState() {
    Column({ space: 14 }) {
      Text('这次没能顺利加载收藏')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F7F0E4');

      Text(this.errorMessage)
        .fontSize(13)
        .fontColor('#B49C90')
        .lineHeight(20);

      Button('重新加载')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#241A10')
        .backgroundColor('#D4B181')
        .borderRadius(15)
        .onClick(() => {
          void this.loadFavorites();
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .backgroundColor('#121513')
    .borderRadius(24)
    .border({ width: 1, color: '#232823' })
    .margin({ top: 18 });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 14 }) {
      Text('你还没有收藏的配方')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F7F0E4');

      Text('下次在 AI 调酒页看到喜欢的那一杯，点一下收藏就会出现在这里。')
        .fontSize(13)
        .fontColor('#A79A88')
        .lineHeight(20);

      Button('去 AI 调酒')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#241A10')
        .backgroundColor('#D4B181')
        .borderRadius(15)
        .onClick(() => {
          router.pushUrl({ url: 'features/cocktail/pages/AICocktailPage' });
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .backgroundColor('#121513')
    .borderRadius(24)
    .border({ width: 1, color: '#232823' })
    .margin({ top: 18 });
  }

  @Builder
  private buildListState() {
    Column({ space: 10 }) {
      this.buildStickyCatalog();
      List({ scroller: this.favoriteScroller, space: 16 }) {
        ForEach(this.favorites, (item: FavoriteAiCocktailItem, index: number) => {
          ListItem() {
            FavoriteRecipeCard({
              item,
              isRemoving: this.removingFavoriteId === item.favoriteId,
              onRemove: (favorite: FavoriteAiCocktailItem) => {
                void this.removeFavorite(favorite);
              }
            });
          }
        }, (item: FavoriteAiCocktailItem) => `${item.favoriteId}-${item.recipeKey}`);
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .listDirection(Axis.Vertical)
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isCatalogAutoScrolling = false;
          this.catalogTargetIndex = -1;
        }
      })
      .onScrollIndex((start: number) => {
        if (this.isCatalogAutoScrolling) {
          if (start === this.catalogTargetIndex) {
            this.isCatalogAutoScrolling = false;
            this.catalogTargetIndex = -1;
          }
          return;
        }

        if (start >= 0 && start < this.favorites.length) {
          this.currentCatalogIndex = start;
          this.scrollCatalogToCenter(start);
        }
      });
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: 4, bottom: 12 });
  }

  build() {
    Column({ space: 6 }) {
      this.buildTopBar();

      if (this.isLoading) {
        this.buildLoadingState();
      } else if (!this.isAuthorized) {
        this.buildUnauthorizedState();
      } else if (this.errorMessage.length > 0) {
        this.buildErrorState();
      } else if (this.favorites.length === 0) {
        this.buildEmptyState();
      } else {
        this.buildListState();
      }
    }
    .padding({ left: 18, right: 18, top: 16, bottom: 20 })
    .width('100%')
    .height('100%')
    .backgroundColor('#0D0F0E')
    .alignItems(HorizontalAlign.Start);
  }
}
