import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';
import { sessionStore } from '../../../common/storage/SessionStore';
import { aiCocktailSessionStore } from '../../ai/viewmodel/AICocktailSessionStore';
import { cocktailRepository } from '../../cocktail/repository/CocktailRepository';
import { CocktailBannerDto } from '../../cocktail/model/CocktailDetailModels';
import ItemData from '../model/ItemData';
import MainViewModel from '../viewmodel/MainViewModel';

interface DashboardStat {
  value: string;
  label: string;
  detail: string;
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
  private readonly quickPromptSamples: string[] = ['清爽低酒精', '适合聚会', '只用现有材料'];

  @State private heroBanners: HomeBannerItem[] = [];
  @State private aiPromptDraft: string = '';

  private readonly stats: DashboardStat[] = [
    { value: '12', label: '今日建议', detail: 'AI 已准备好候选酒单' },
    { value: '84%', label: '库存匹配', detail: '结合已录入材料估算' },
    { value: '3.2m', label: '平均出杯', detail: '适合快速执行的方案' }
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

  private openAiPage(prefillPrompt: string = this.aiPromptDraft): void {
    aiCocktailSessionStore.setInputText(prefillPrompt);
    router.pushUrl({ url: 'features/cocktail/pages/AICocktailPage' }, 3000);
  }

  private applyPromptSample(sample: string): void {
    this.aiPromptDraft = sample;
    this.openAiPage(sample);
  }

  @Builder
  private buildHeader() {
    Row() {
      Column({ space: 6 }) {
        Text('ShakePro Control')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textSecondary)
          .letterSpacing(1.1);

        Text('智能调酒工作台')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('先从 AI 调酒开始，再结合库存和酒谱继续细化。')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary);
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
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(UiTokens.radiusMd)
      .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%');
  }

  @Builder
  private buildAiHeroCard() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 8 }) {
          Text('AI 调酒优先入口')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.aiPrimary)
            .letterSpacing(1.2);

          Text('今天想调一杯什么状态？')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .lineHeight(36);

          Text('输入口味、场景或现有材料，AI 先给你出配方，再继续走库存与酒谱工作流。')
            .fontSize(13)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(20);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Column({ space: 8 }) {
          Text('建议流程')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textSecondary);

          Text('AI 推荐')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(UiTokens.aiSoft)
            .borderRadius(16);

          Text('查看酒谱')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(UiTokens.surfaceSecondary)
            .borderRadius(16);
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Column({ space: 10 }) {
        TextInput({
          placeholder: '比如：清爽一点，适合聚会，家里有金酒和柠檬',
          text: this.aiPromptDraft
        })
          .width('100%')
          .height(56)
          .fontSize(15)
          .fontColor(UiTokens.textPrimary)
          .placeholderColor(UiTokens.textTertiary)
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(20)
          .padding({ left: 18, right: 18 })
          .border({ width: 1, color: UiTokens.borderPrimary })
          .onChange((value: string) => {
            this.aiPromptDraft = value;
          });

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.quickPromptSamples, (sample: string) => {
              Button(sample)
                .fontSize(12)
                .fontColor(UiTokens.textAccent)
                .backgroundColor(UiTokens.surfacePrimary)
                .borderRadius(16)
                .border({ width: 1, color: UiTokens.borderPrimary })
                .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                .onClick(() => {
                  this.applyPromptSample(sample);
                });
            }, (sample: string) => sample);
          }
          .padding({ right: 16 });
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off);
      }
      .width('100%');

      Row({ space: 10 }) {
        Button('开始 AI 推荐')
          .layoutWeight(1)
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.aiPrimary)
          .borderRadius(18)
          .onClick(() => {
            this.openAiPage();
          });

        Button('浏览酒谱')
          .layoutWeight(1)
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary)
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(18)
          .border({ width: 1, color: UiTokens.borderPrimary })
          .onClick(() => {
            router.pushUrl({ url: 'features/recipe/pages/RecipeLibraryPage' }, 3000);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 20, bottom: 20 })
    .backgroundColor(UiTokens.aiSurface)
    .borderRadius(UiTokens.radiusXl)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
  }

  @Builder
  private buildStaticHeroCard(img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img)
        .width('100%')
        .height(212)
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
        Text('灵感酒单')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textInverse)
          .letterSpacing(0.8);

        Text('登录后自动同步最新鸡尾酒推荐')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
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
        .height(212)
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
        Text('今日灵感')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textInverse)
          .letterSpacing(0.8);

        Text(item.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
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
  private buildShowcaseSection() {
    Column({ space: 12 }) {
      this.buildSectionHeader('今日建议', '基于当前工作流给你的灵感入口')

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
        .height(212);
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildStatsPanel() {
    Row({ space: 10 }) {
      ForEach(this.stats, (item: DashboardStat, index: number) => {
        Column({ space: 8 }) {
          Text(item.value)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text(item.label)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textSecondary)
            .textAlign(TextAlign.Center);

          Text(item.detail)
            .fontSize(10)
            .fontColor(UiTokens.textTertiary)
            .textAlign(TextAlign.Center)
            .lineHeight(16)
            .maxLines(2);
        }
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 16, bottom: 16 })
        .backgroundColor(index === 0 ? UiTokens.aiSurface : UiTokens.surfacePrimary)
        .borderRadius(20)
        .border({ width: 1, color: UiTokens.borderPrimary });
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
          .fontColor(UiTokens.textPrimary);

        Text(subtitle)
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Text('更多')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textAccent);
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
      .backgroundColor(index % 2 === 0 ? UiTokens.primarySoft : UiTokens.aiSoft)
      .borderRadius(18);

      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .maxLines(2);

        Text(this.getMenuDescription(item.title))
          .fontSize(10)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(17)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(20)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .onClick(() => {
      this.navigateToPage(item.title);
    });
  }

  @Builder
  private buildQuickActions() {
    Column({ space: 12 }) {
      this.buildSectionHeader('快捷操作', '先录入库存，再决定要不要继续生成或收藏')

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
          .fontColor(UiTokens.textPrimary)
          .maxLines(2);

        if (item.others) {
          Text(item.others)
            .fontSize(12)
            .fontColor(UiTokens.textAccent);
        }

        Text(index === 0 ? '适合标准化复刻，也适合先从经典版本开始尝试。' : index === 1 ? '层次更强，适合聚会与展示。' : '风味轻盈，适合快速上手。')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18)
          .maxLines(3);

        Row({ space: 8 }) {
          Text(index === 0 ? '经典底稿' : index === 1 ? '聚会推荐' : '轻饮友好')
            .fontSize(11)
            .fontColor(UiTokens.textAccent)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(UiTokens.primarySoft)
            .borderRadius(14);

          Text('查看酒谱')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.aiPrimary);
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .onClick(() => {
      this.navigateToRecipeDetail(this.getFeaturedCocktailId(index));
    });
  }

  @Builder
  private buildFeaturedRecipes() {
    Column({ space: 12 }) {
      this.buildSectionHeader('推荐配方', '先浏览经典酒谱，再决定要不要继续深入查看')

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
        this.buildAiHeroCard();
        this.buildStatsPanel();
        this.buildQuickActions();
        this.buildShowcaseSection();
        this.buildFeaturedRecipes();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 110 });
    }
    .height('100%')
    .backgroundColor(UiTokens.pageBackground)
    .scrollBar(BarState.Off);
  }

  private getMenuDescription(title: Resource): string {
    if (title.id === $r('app.string.my_cocktail').id) {
      return '查看已保存的配方与出杯记录';
    }
    if (title.id === $r('app.string.material_selection').id) {
      return '进入材料库，管理已经录入的库存与原料';
    }
    if (title.id === $r('app.string.favorite_recipes').id) {
      return '集中管理高频使用的收藏酒谱';
    }
    if (title.id === $r('app.string.classic_formula').id) {
      return '先找灵感，再查看标准配方与做法';
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
