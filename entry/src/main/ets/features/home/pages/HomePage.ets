import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import ItemData from '../model/ItemData';
import MainViewModel from '../viewmodel/MainViewModel';
import router from '@ohos.router';
import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';
import { sessionStore } from '../../../common/storage/SessionStore';
import { cocktailRepository } from '../../cocktail/repository/CocktailRepository';
import { CocktailBannerDto } from '../../cocktail/model/CocktailDetailModels';

interface DashboardStat {
  value: string;
  label: string;
}

interface HomeBannerItem {
  cocktailId: number;
  title: string;
  imageUrl: string;
}

@Entry({ routeName: 'MainPage' })
@Component
export struct MainPage {
  private swiperController: SwiperController = new SwiperController();
  private readonly featuredCocktailIds: number[] = [8, 9, 10];
  @State private heroBanners: HomeBannerItem[] = [];

  private readonly stats: DashboardStat[] = [
    { value: '12', label: '今日建议' },
    { value: '84%', label: '库存匹配' },
    { value: '3.2m', label: '平均出杯' }
  ];

  aboutToAppear(): void {
    if (this.heroBanners.length === 0) {
      void this.refreshHeroBanners();
    }
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

  private normalizeBannerText(value?: string | null): string {
    return typeof value === 'string' ? value.trim() : '';
  }

  private resolveTraceId(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const traceId = errorObject['traceId'];
    if (typeof traceId === 'string') {
      return traceId;
    }
    return '';
  }

  private resolveBannerErrorMessage(error: Object): string {
    const errorObject = error as Record<string, Object>;
    const code = errorObject['code'];
    const message = errorObject['message'];

    if (typeof code === 'number' && code === 40100) {
      return '登录后可同步首页 Banner 推荐';
    }

    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }

    return '同步首页 Banner 失败，已保留本地展示图';
  }

  private mapBannerDto(dto: CocktailBannerDto): HomeBannerItem | null {
    const title = this.normalizeBannerText(dto.title);
    const imageUrl = buildPublicAssetUrl(this.normalizeBannerText(dto.imageUrl));
    if (dto.cocktailId === undefined || title.length === 0 || imageUrl.length === 0) {
      return null;
    }
    return {
      cocktailId: dto.cocktailId,
      title,
      imageUrl
    } as HomeBannerItem;
  }

  private async refreshHeroBanners(): Promise<void> {
    try {
      await this.ensureSessionStore();
      const remoteBanners = await cocktailRepository.getCocktailBanner();
      const nextBanners: HomeBannerItem[] = [];

      for (let index: number = 0; index < remoteBanners.length; index += 1) {
        const mappedBanner = this.mapBannerDto(remoteBanners[index]);
        if (mappedBanner) {
          nextBanners.push(mappedBanner);
        }
      }

      this.heroBanners = nextBanners;
    } catch (error) {
      const message = this.resolveBannerErrorMessage(error as Object);
      const traceId = this.resolveTraceId(error as Object);
      promptAction.showToast({
        message: traceId.length > 0 ? `${message} (${traceId})` : message
      });
    }
  }

  @Builder
  private buildHeader() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 6 }) {
          Text('ShakePro Control')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5D7B8C')
            .letterSpacing(1.1);

          Text('智能调酒工作台')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#16303E');

          Text('集中查看推荐、库存和功能入口。')
            .fontSize(13)
            .fontColor('#6E818D');
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Row() {
          Image($r('app.media.myself'))
            .width(48)
            .height(48)
            .borderRadius(24);
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .border({ width: 1, color: '#D7E6ED' });
      }
      .width('100%');

      Row({ space: 10 }) {
        Row({ space: 10 }) {
          Text('◌')
            .fontSize(18)
            .fontColor('#6A8EA0');

          TextInput({ placeholder: $r('app.string.search_interesting_content') })
            .layoutWeight(1)
            .height(48)
            .backgroundColor(Color.Transparent)
            .fontSize(15)
            .placeholderColor('#8BA0AC');
        }
        .layoutWeight(1)
        .height(54)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });

        Column({ space: 2 }) {
          Text('AI调酒')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#124056');
        }
        .width(74)
        .height(54)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#DDF5F1')
        .borderRadius(18)
        .border({ width: 1, color: '#BFE7E6' })
        .onClick(() => {
          router.pushUrl({ url: 'features/cocktail/pages/AICocktailPage' }, 3000);
        });
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildStaticHeroCard(img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img)
        .width('100%')
        .height(228)
        .borderRadius(24)
        .objectFit(ImageFit.Cover);

      Column()
        .width('100%')
        .height('100%')
        .borderRadius(24)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#1D4A5A12', 0.0], ['#1D4A5A55', 0.58], ['#123241D0', 1.0]]
        });

      Column({ space: 8 }) {
        Text('本地展示 Banner')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D5E7F0')
          .letterSpacing(0.8);

        Text('登录后自动同步最新鸡尾酒推荐')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(2);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, bottom: 22 });
    }
    .width('100%')
    .onClick(() => {
      router.pushUrl({ url: 'features/recipe/pages/RecipeLibraryPage' }, 3000);
    });
  }

  @Builder
  private buildRemoteHeroCard(item: HomeBannerItem) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.imageUrl)
        .width('100%')
        .height(228)
        .borderRadius(24)
        .objectFit(ImageFit.Cover);

      Column()
        .width('100%')
        .height('100%')
        .borderRadius(24)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#14374414', 0.0], ['#163D4F66', 0.56], ['#102A35DC', 1.0]]
        });

      Column({ space: 8 }) {
        Text('后端 Banner')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D7EAF3')
          .letterSpacing(0.8);

        Text(item.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(2);

        Text('点击查看这杯酒的完整配方详情')
          .fontSize(12)
          .fontColor('#D4E8F1');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, bottom: 22 });
    }
    .width('100%')
    .onClick(() => {
      this.navigateToRecipeDetail(item.cocktailId);
    });
  }

  @Builder
  private buildHeroSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Swiper(this.swiperController) {
        if (this.heroBanners.length > 0) {
          ForEach(this.heroBanners, (item: HomeBannerItem) => {
            this.buildRemoteHeroCard(item);
          }, (item: HomeBannerItem) => `banner-${item.cocktailId}`);
        } else {
          ForEach(MainViewModel.getSwiperImages(), (img: Resource) => {
            this.buildStaticHeroCard(img);
          }, (img: Resource) => String(img.id));
        }
      }
      .autoPlay(true)
      .indicator(true)
      .interval(3600)
      .width('100%')
      .height(228);
    }
    .width('100%');
  }

  @Builder
  private buildStatsPanel() {
    Row({ space: 10 }) {
      ForEach(this.stats, (item: DashboardStat) => {
        Column({ space: 8 }) {
          Text(item.value)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#153342');

          Text(item.label)
            .fontSize(12)
            .fontColor('#71838F')
            .textAlign(TextAlign.Center);
        }
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });
      });
    }
    .width('100%');
  }

  @Builder
  private buildSectionHeader(title: string, subtitle: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#16303E');

        Text(subtitle)
          .fontSize(12)
          .fontColor('#738590');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Text('更多')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C8192');
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom);
  }

  @Builder
  private buildQuickActionCard(item: ItemData, index: number) {
    Row({ space: 12 }) {
      Row() {
        if (item.img) {
          Image(item.img)
            .width(34)
            .height(34)
            .objectFit(ImageFit.Contain);
        }
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(index % 2 === 0 ? '#E8F5FB' : '#DDF5F1')
      .borderRadius(18);

      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#193342')
          .maxLines(2);

        Text(this.getMenuDescription(item.title))
          .fontSize(9)
          .fontColor('#72838F')
          .lineHeight(17)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      this.navigateToPage(item.title);
    });
  }

  @Builder
  private buildQuickActions() {
    Column({ space: 12 }) {
      this.buildSectionHeader('功能模块', '按用途分组显示')

      Grid() {
        ForEach(MainViewModel.getFirstGirdData(), (item: ItemData, index: number) => {
          GridItem() {
            this.buildQuickActionCard(item, index);
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildRecipeCard(item: ItemData, index: number) {
    Row({ space: 14 }) {
      if (item.img) {
        Image(item.img)
          .width(100)
          .height(120)
          .borderRadius(20)
          .objectFit(ImageFit.Cover);
      }

      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240')
          .maxLines(2);

        if (item.others) {
          Text(item.others)
            .fontSize(12)
            .fontColor('#5C8797');
        }

        Text(index === 0 ? '结构清晰，适合标准化复刻。' : index === 1 ? '层次更强，适合聚会与展示。' : '风味轻盈，适合快速上手。')
          .fontSize(12)
          .fontColor('#71828D')
          .lineHeight(18)
          .maxLines(3);

        Row({ space: 8 }) {
          Text(index === 0 ? '经典' : index === 1 ? '推荐' : '轻饮')
            .fontSize(11)
            .fontColor('#1D5667')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#E8F5FB')
            .borderRadius(14);

          Text('查看酒谱')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4F7E91');
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      this.navigateToRecipeDetail(this.getFeaturedCocktailId(index));
    });
  }

  @Builder
  private buildFeaturedRecipes() {
    Column({ space: 12 }) {
      this.buildSectionHeader('推荐配方', '结合当前素材和常用主题')

      Column({ space: 12 }) {
        ForEach(MainViewModel.getSecondGridData(), (item: ItemData, index: number) => {
          this.buildRecipeCard(item, index);
        });
      }
      .width('100%');
    }
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildHeroSection();
        this.buildStatsPanel();
        this.buildQuickActions();
        this.buildFeaturedRecipes();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 110 });
    }
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }

  private getMenuDescription(title: Resource): string {
    if (title.id === $r('app.string.my_cocktail').id) {
      return '查看已保存的配方与出杯记录';
    }
    if (title.id === $r('app.string.material_selection').id) {
      return '根据原料快速定位可执行方案';
    }
    if (title.id === $r('app.string.favorite_recipes').id) {
      return '集中管理高频使用的收藏酒谱';
    }
    if (title.id === $r('app.string.classic_formula').id) {
      return '按标准结构浏览经典配方';
    }
    if (title.id === $r('app.string.friend').id) {
      return '用于分享作品和查看协作内容';
    }
    if (title.id === $r('app.string.ai_cocktail').id) {
      return '根据口味、场景和材料快速生成专属推荐';
    }
    return '后续用于扩展更多历史与实验模块';
  }

  private navigateToPage(title: Resource): void {
    let targetUrl: string = '';

    if (title.id === $r('app.string.my_cocktail').id ||
      title.id === $r('app.string.favorite_recipes').id) {
      targetUrl = 'features/favorite/pages/MyFavoritePage';
    } else if (title.id === $r('app.string.material_selection').id) {
      targetUrl = 'features/station/pages/MaterialLibraryPage';
    } else if (title.id === $r('app.string.classic_formula').id) {
      this.navigateToRecipeDetail();
      return;
    } else if (title.id === $r('app.string.ai_cocktail').id) {
      targetUrl = 'features/cocktail/pages/AICocktailPage';
    }

    if (!targetUrl) {
      promptAction.showToast({ message: '该功能页面暂未开放' });
      return;
    }

    router.pushUrl({ url: targetUrl }, 3000);
  }

  private getFeaturedCocktailId(index: number): number {
    if (index >= 0 && index < this.featuredCocktailIds.length) {
      return this.featuredCocktailIds[index];
    }
    return this.featuredCocktailIds[0];
  }

  private navigateToRecipeDetail(cocktailId: number = this.featuredCocktailIds[0]): void {
    router.pushUrl({
      url: 'features/recipe/pages/RecipeDetailPage',
      params: {
        cocktailId
      }
    }, 3000);
  }
}
