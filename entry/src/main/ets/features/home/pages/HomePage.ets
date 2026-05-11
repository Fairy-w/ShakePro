import { AppLogger } from '../../../core/logging/AppLogger';
import { RoutePaths } from '../../../core/router/RoutePaths';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { HttpRequestError, toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { aiCocktailSessionStore } from '../../ai/viewmodel/AICocktailSessionStore';
import { cocktailRepository } from '../../cocktail/repository/CocktailRepository';
import { favoriteRepository } from '../../favorite/repository/FavoriteRepository';
import { RecommendCocktailCardModel, RecommendCocktailRequest } from '../../cocktail/model/CocktailRecommendModels';

interface DashboardStat {
  value: string;
  label: string;
  detail: string;
}

const HOME_PAGE_LOG_TAG: string = 'ShakeProHomePage';

@Entry({ routeName: 'MainPage' })
@Component
export struct MainPage {
  @Prop pageBottomInset: number = 0;

  private readonly quickPromptSamples: string[] = ['清爽低酒精', '适合聚会', '果香清甜'];
  private readonly recommendPageSize: number = 3;
  private recommendSeedId: number = -1;
  private recommendOffset: number = 0;

  @State private recommendedRecipes: RecommendCocktailCardModel[] = [];
  @State private recommendLoading: boolean = false;
  @State private recommendHint: string = '';
  @State private aiPromptDraft: string = '';

  private readonly stats: DashboardStat[] = [
    { value: '12', label: '今日建议', detail: 'AI 已准备好候选酒单' },
    { value: '84%', label: '库存匹配', detail: '结合已录入材料估算' },
    { value: '3.2m', label: '平均出杯', detail: '适合快速执行的方案' }
  ];

  aboutToAppear(): void {
    if (this.recommendedRecipes.length === 0 && !this.recommendLoading) {
      void this.refreshRecommendedRecipes();
    }
  }

  private resolvePageBottomInset(): number {
    return this.pageBottomInset > 0 ? this.pageBottomInset : 28;
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

  private async hasAuthorization(): Promise<boolean> {
    const authorization: string = await sessionStore.getAuthorizationValue();
    return authorization.trim().length > 0;
  }

  private resolveRecommendHint(error: Object): string {
    if (error instanceof HttpRequestError) {
      if (error.code === 40100) {
        return '登录后才能查看首页推荐';
      }
      return toUserFacingMessage(error.message, '暂时拿不到推荐配方，请稍后再试');
    }
    return '暂时拿不到推荐配方，请稍后再试';
  }

  private pushUniqueRecommendSeed(candidateIds: number[], seedId?: number): void {
    if (typeof seedId !== 'number' || seedId <= 0 || candidateIds.includes(seedId)) {
      return;
    }
    candidateIds.push(seedId);
  }

  private pickRecommendSeedId(candidateIds: number[]): number {
    if (candidateIds.length === 0) {
      throw new Error('EMPTY_RECOMMEND_SEED');
    }
    if (candidateIds.length === 1 || this.recommendSeedId <= 0) {
      return candidateIds[0];
    }

    const currentIndex: number = candidateIds.indexOf(this.recommendSeedId);
    if (currentIndex < 0) {
      return candidateIds[0];
    }
    return candidateIds[(currentIndex + 1) % candidateIds.length];
  }

  private async resolveRecommendSeedId(useNextOffset: boolean): Promise<number> {
    if (useNextOffset && this.recommendSeedId > 0) {
      return this.recommendSeedId;
    }

    const candidateIds: number[] = [];
    try {
      const systemFavorites = await favoriteRepository.getSystemFavoriteList();
      for (let index: number = 0; index < systemFavorites.length; index += 1) {
        this.pushUniqueRecommendSeed(candidateIds, systemFavorites[index].id);
      }
    } catch (error) {
      const errorMessage: string = error instanceof Error ? error.message : JSON.stringify(error);
      AppLogger.warn(HOME_PAGE_LOG_TAG,
        'load favorite seeds failed error=%{public}s',
        errorMessage
      );
    }

    return this.pickRecommendSeedId(candidateIds);
  }

  private async refreshRecommendedRecipes(useNextOffset: boolean = false): Promise<void> {
    if (this.recommendLoading) {
      return;
    }

    this.recommendLoading = true;
    this.recommendHint = '';

    try {
      await this.ensureSessionStore();
      if (!(await this.hasAuthorization())) {
        this.recommendedRecipes = [];
        this.recommendSeedId = -1;
        this.recommendOffset = 0;
        this.recommendHint = '登录后可查看首页个性化推荐';
        return;
      }

      const seedId: number = await this.resolveRecommendSeedId(useNextOffset);
      const offset: number = useNextOffset && this.recommendSeedId === seedId ? this.recommendOffset : 0;
      const recommendRequest: RecommendCocktailRequest = {
        seedId: seedId,
        topk: this.recommendPageSize,
        offset: offset
      };
      AppLogger.info(HOME_PAGE_LOG_TAG,
        'recommend request seedId=%{public}d topk=%{public}d offset=%{public}d',
        recommendRequest.seedId,
        recommendRequest.topk ?? this.recommendPageSize,
        recommendRequest.offset ?? 0
      );
      const remoteRecipes: RecommendCocktailCardModel[] = await cocktailRepository.getRecommendedCocktails(recommendRequest);
      this.recommendedRecipes = remoteRecipes;
      this.recommendSeedId = seedId;
      this.recommendOffset = offset + this.recommendPageSize;
      if (remoteRecipes.length === 0) {
        this.recommendHint = '暂时没有更多推荐结果，稍后再试试';
      }
    } catch (error) {
      this.recommendedRecipes = [];
      this.recommendSeedId = -1;
      this.recommendOffset = 0;
      if (error instanceof Error && error.message === 'EMPTY_RECOMMEND_SEED') {
        this.recommendHint = '推荐入口还在准备中，请稍后再试';
      } else {
        this.recommendHint = this.resolveRecommendHint(error as Object);
      }
    } finally {
      this.recommendLoading = false;
    }
  }

  private openAiPage(prefillPrompt: string = this.aiPromptDraft): void {
    aiCocktailSessionStore.setInputText(prefillPrompt);
    router.pushUrl({ url: RoutePaths.AI_COCKTAIL }, 3000);
  }

  private async handleStartAiRecommendation(): Promise<void> {
    const prompt: string = this.aiPromptDraft.trim();
    if (prompt.length === 0) {
      this.openAiPage();
      return;
    }

    aiCocktailSessionStore.setInputText(prompt);

    try {
      await this.ensureSessionStore();
    } catch (error) {
      this.openAiPage(prompt);
      return;
    }

    if (!sessionStore.isInitialized()) {
      this.openAiPage(prompt);
      return;
    }

    await aiCocktailSessionStore.submitPrompt(prompt);
    router.pushUrl({ url: RoutePaths.AI_COCKTAIL }, 3000);
  }

  private applyPromptSample(sample: string): void {
    this.aiPromptDraft = sample;
  }

  @Builder
  private buildHeader() {
    Row() {
      Column({ space: 6 }) {
        Text('ShakePro Control')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textSecondary)
          .letterSpacing(1.6);

        Text('智能调酒工作台')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .lineHeight(38);

        Text('先从 AI 调酒开始，再结合库存和酒谱继续细化。')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(20);
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
      .backgroundColor(UiTokens.surfaceWarm)
      .borderRadius(UiTokens.radiusMd)
      .border({ width: 1, color: UiTokens.borderPrimary })
      .shadow({ radius: 16, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 });
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
            .fontColor(UiTokens.textAccent)
            .letterSpacing(1.2);

          Text('今天想调一杯什么状态？')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .lineHeight(36);

          Text('输入口味、场景或酒感偏好，AI 先给你出配方，再继续走库存与酒谱工作流。')
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
            .backgroundColor(UiTokens.surfaceWarm)
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
          .backgroundColor(UiTokens.brandStrong)
          .borderRadius(18)
          .onClick(() => {
            void this.handleStartAiRecommendation();
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
            router.pushUrl({ url: RoutePaths.RECIPE_LIBRARY }, 3000);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 20, bottom: 20 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(UiTokens.radiusXl)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 20, color: UiTokens.shadowMedium, offsetX: 0, offsetY: 10 });
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
        .fontColor(UiTokens.textAccent)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(UiTokens.surfaceWarm)
        .borderRadius(14);
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom);
  }

  private hasRecommendImage(item: RecommendCocktailCardModel): boolean {
    if (typeof item.imageSource === 'string') {
      return item.imageSource.trim().length > 0;
    }
    return true;
  }

  @Builder
  private buildRecipeCard(item: RecommendCocktailCardModel) {
    Row({ space: 14 }) {
      if (this.hasRecommendImage(item)) {
        Image(item.imageSource)
          .width(100)
          .height(120)
          .borderRadius(20)
          .objectFit(ImageFit.Cover);
      } else {
        Column()
          .width(100)
          .height(120)
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(20)
          .border({ width: 1, color: UiTokens.borderPrimary });
      }

      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .maxLines(2);

        if (item.subtitle.length > 0) {
          Text(item.subtitle)
            .fontSize(12)
            .fontColor(UiTokens.textAccent)
            .maxLines(1);
        }

        Text(item.description)
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18)
          .maxLines(3);

        Row({ space: 8 }) {
          Text(item.badgeText)
            .fontSize(11)
            .fontColor(UiTokens.textAccent)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(UiTokens.surfaceWarm)
            .borderRadius(14);

          Text(item.metaText)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiTokens.textAccent);
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 })
    .onClick(() => {
      this.navigateToRecipeDetail(item.cocktailId);
    });
  }

  @Builder
  private buildRecommendStatusCard() {
    Column({ space: 12 }) {
      if (this.recommendLoading) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color(UiTokens.textPrimary);

        Text('正在生成首页推荐...')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .textAlign(TextAlign.Center);
      } else {
        Text(this.recommendHint.length > 0 ? this.recommendHint : '暂时没有推荐结果')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(20)
          .textAlign(TextAlign.Center);
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildFeaturedRecipes() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('推荐配方')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text('优先展示和你当前口味更接近的鸡尾酒建议')
            .fontSize(12)
            .fontColor(UiTokens.textSecondary);
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Button(this.recommendLoading ? '刷新中' : '换一批')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.recommendLoading ? UiTokens.textTertiary : UiTokens.textAccent)
          .backgroundColor(UiTokens.surfaceWarm)
          .borderRadius(16)
          .border({ width: 1, color: UiTokens.borderPrimary })
          .padding({ left: 12, right: 12 })
          .enabled(!this.recommendLoading)
          .onClick(() => {
            void this.refreshRecommendedRecipes(true);
          });
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom);

      if (this.recommendLoading || this.recommendedRecipes.length === 0) {
        this.buildRecommendStatusCard();
      } else {
        Column({ space: 12 }) {
          ForEach(this.recommendedRecipes, (item: RecommendCocktailCardModel) => {
            this.buildRecipeCard(item);
          }, (item: RecommendCocktailCardModel) => `recommend-${item.cocktailId}`);
        }
        .width('100%');
      }
    }
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildAiHeroCard();
        this.buildFeaturedRecipes();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: this.resolvePageBottomInset() });
    }
    .height('100%')
    .backgroundColor(UiTokens.pageBackground)
    .scrollBar(BarState.Off);
  }

  private navigateToRecipeDetail(cocktailId: number): void {
    router.pushUrl({
      url: RoutePaths.RECIPE_DETAIL,
      params: {
        cocktailId
      }
    }, 3000);
  }
}
