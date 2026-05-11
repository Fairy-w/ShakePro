import { RoutePaths } from '../../../core/router/RoutePaths';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { AICocktailSessionSnapshot, aiCocktailSessionStore, ChatMessage } from '../../ai/viewmodel/AICocktailSessionStore';
import { AiGenerateRecipeResponse } from '../../ai/model/AiGenerateRecipeResponse';
import { buildAiCocktailRecipeKey } from '../../favorite/model/FavoriteAiCocktailKeyUtil';
import { FavoriteAiCocktailMutationResponse, FavoriteAiCocktailStatusResponse } from '../../favorite/model/FavoriteAiCocktailModels';
import { favoriteRepository } from '../../favorite/repository/FavoriteRepository';
import { AICocktailHeroSection } from '../components/AICocktailHeroSection';
import { AICocktailRefineSheet } from '../components/AICocktailRefineSheet';
import { AICocktailResultsSection } from '../components/AICocktailResultsSection';

@Entry({ routeName: 'AICocktailPage' })
@Component
export struct AICocktailPage {
  @State private inputText: string = '';
  @State private isLoading: boolean = false;
  @State private isShowRefineSheet: boolean = false;
  @State private isShowEmptyPromptOverlay: boolean = false;
  @State private forceInputMode: boolean = false;
  @State private errorMessage: string = '';
  @State private messageList: ChatMessage[] = [];
  @State private favoritedRecipeKeys: string[] = [];
  @State private favoriteIdsByRecipeKey: Record<string, number> = {};
  @State private favoriteBusyKey: string = '';

  private sessionListenerId: number = -1;
  private favoriteSyncSignature: string = '';
  private readonly loadingCardKeys: string[] = ['first', 'second'];
  private readonly quickPromptSamples: string[] = [
    '清爽一点，适合晚餐后',
    '低酒精，女生聚会喝',
    '果香明显，适合拍照'
  ];

  aboutToAppear(): void {
    this.favoriteSyncSignature = '';
    this.bindSessionStore();
    void this.ensureSessionStore();
  }

  aboutToDisappear(): void {
    this.unbindSessionStore();
  }

  private bindSessionStore(): void {
    if (this.sessionListenerId !== -1) {
      this.syncFromSessionStore();
      return;
    }

    this.sessionListenerId = aiCocktailSessionStore.addListener((): void => {
      this.syncFromSessionStore();
    });
    this.syncFromSessionStore();
  }

  private unbindSessionStore(): void {
    if (this.sessionListenerId === -1) {
      return;
    }
    aiCocktailSessionStore.removeListener(this.sessionListenerId);
    this.sessionListenerId = -1;
  }

  private syncFromSessionStore(): void {
    const snapshot: AICocktailSessionSnapshot = aiCocktailSessionStore.getSnapshot();
    this.inputText = snapshot.inputText;
    this.isLoading = snapshot.isLoading;
    this.errorMessage = snapshot.errorMessage;
    this.messageList = snapshot.messageList;
    this.syncFavoriteStatusesIfNeeded();
  }

  private async ensureSessionStore(): Promise<void> {
    if (sessionStore.isInitialized()) {
      return;
    }

    try {
      await sessionStore.init(this.getHostContext());
    } catch (error) {
      aiCocktailSessionStore.setErrorMessage(this.resolveErrorMessage(error, '服务准备中，请稍后再试'));
      this.syncFromSessionStore();
    }
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string = '暂时没能生成你的酒单建议'): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private showError(message: string): void {
    aiCocktailSessionStore.setErrorMessage(message);
    promptAction.showToast({ message });
  }

  private updateInputText(value: string): void {
    aiCocktailSessionStore.setInputText(value);
    this.inputText = value;
    this.isShowEmptyPromptOverlay = false;
    if (value.trim().length > 0) {
      this.forceInputMode = false;
    }
  }

  private applyPromptSample(sample: string): void {
    this.updateInputText(sample);
  }

  private async sendMessage(): Promise<void> {
    const prompt: string = this.inputText.trim();
    if (!prompt) {
      this.isShowEmptyPromptOverlay = true;
      return;
    }

    this.forceInputMode = false;

    if (this.isLoading) {
      return;
    }

    await this.ensureSessionStore();
    if (!sessionStore.isInitialized()) {
      this.showError('服务还在准备中，请稍后再试');
      return;
    }

    await aiCocktailSessionStore.submitPrompt(prompt);
  }

  private async sendMessageFromSheet(): Promise<void> {
    await this.sendMessage();
    if (!this.isLoading) {
      this.isShowRefineSheet = false;
    }
  }

  private getLatestUserMessageIndex(): number {
    for (let index: number = this.messageList.length - 1; index >= 0; index -= 1) {
      if (this.messageList[index].role === 'user') {
        return index;
      }
    }
    return -1;
  }

  private getLatestUserPrompt(): string {
    const messageIndex: number = this.getLatestUserMessageIndex();
    if (messageIndex === -1) {
      return '';
    }
    return this.messageList[messageIndex].content;
  }

  private getCurrentRecipeMessage(): ChatMessage | undefined {
    const messageIndex: number = this.getLatestUserMessageIndex();
    if (messageIndex === -1) {
      return undefined;
    }

    for (let index: number = this.messageList.length - 1; index > messageIndex; index -= 1) {
      const message: ChatMessage = this.messageList[index];
      if (message.role === 'ai' && message.recipes && message.recipes.length > 0) {
        return message;
      }
    }
    return undefined;
  }

  private getCurrentRecipes(): AiGenerateRecipeResponse[] {
    const recipeMessage: ChatMessage | undefined = this.getCurrentRecipeMessage();
    if (!recipeMessage || !recipeMessage.recipes) {
      return [];
    }
    return recipeMessage.recipes;
  }

  private clearFavoriteState(): void {
    this.favoritedRecipeKeys = [];
    this.favoriteIdsByRecipeKey = {};
    this.favoriteBusyKey = '';
  }

  private buildFavoriteSignature(recipes: AiGenerateRecipeResponse[]): string {
    if (recipes.length === 0) {
      return '';
    }
    return recipes.map((recipe: AiGenerateRecipeResponse): string => buildAiCocktailRecipeKey(recipe)).join('|');
  }

  private syncFavoriteStatusesIfNeeded(): void {
    const recipes: AiGenerateRecipeResponse[] = this.getCurrentRecipes();
    const nextSignature: string = this.buildFavoriteSignature(recipes);
    if (nextSignature === this.favoriteSyncSignature) {
      return;
    }

    this.favoriteSyncSignature = nextSignature;
    if (nextSignature.length === 0) {
      this.clearFavoriteState();
      return;
    }

    void this.loadFavoriteStatuses(recipes, nextSignature);
  }

  private async hasAuthorization(): Promise<boolean> {
    await this.ensureSessionStore();
    if (!sessionStore.isInitialized()) {
      return false;
    }
    const authorization: string = await sessionStore.getAuthorizationValue();
    return authorization.trim().length > 0;
  }

  private async loadFavoriteStatuses(recipes: AiGenerateRecipeResponse[], signature: string): Promise<void> {
    this.clearFavoriteState();
    if (!(await this.hasAuthorization())) {
      return;
    }

    const nextFavoritedRecipeKeys: string[] = [];
    const nextFavoriteIdsByRecipeKey: Record<string, number> = {};

    for (let index: number = 0; index < recipes.length; index += 1) {
      const recipe: AiGenerateRecipeResponse = recipes[index];
      const recipeKey: string = buildAiCocktailRecipeKey(recipe);

      try {
        const status: FavoriteAiCocktailStatusResponse = await favoriteRepository.getAiCocktailStatus(recipeKey);
        if (!status.favorited) {
          continue;
        }
        nextFavoritedRecipeKeys.push(recipeKey);
        if (typeof status.favoriteId === 'number') {
          nextFavoriteIdsByRecipeKey[recipeKey] = status.favoriteId;
        }
      } catch (_) {
      }
    }

    if (this.favoriteSyncSignature !== signature) {
      return;
    }

    this.favoritedRecipeKeys = nextFavoritedRecipeKeys;
    this.favoriteIdsByRecipeKey = nextFavoriteIdsByRecipeKey;
  }

  private addFavoriteState(recipeKey: string, favoriteId?: number): void {
    if (this.favoritedRecipeKeys.indexOf(recipeKey) === -1) {
      const newArray: string[] = [];
      for (let i = 0; i < this.favoritedRecipeKeys.length; i++) {
        newArray.push(this.favoritedRecipeKeys[i]);
      }
      newArray.push(recipeKey);
      this.favoritedRecipeKeys = newArray;
    }
    if (typeof favoriteId === 'number') {
      const newMap: Record<string, number> = {};
      Object.keys(this.favoriteIdsByRecipeKey).forEach((key: string) => {
        newMap[key] = this.favoriteIdsByRecipeKey[key];
      });
      newMap[recipeKey] = favoriteId;
      this.favoriteIdsByRecipeKey = newMap;
    }
  }

  private removeFavoriteState(recipeKey: string): void {
    this.favoritedRecipeKeys = this.favoritedRecipeKeys.filter((item: string): boolean => item !== recipeKey);
    const nextMap: Record<string, number> = {};
    Object.keys(this.favoriteIdsByRecipeKey).forEach((key: string) => {
      if (key !== recipeKey) {
        nextMap[key] = this.favoriteIdsByRecipeKey[key];
      }
    });
    this.favoriteIdsByRecipeKey = nextMap;
  }

  private async handleToggleFavorite(recipe: AiGenerateRecipeResponse): Promise<void> {
    const recipeKey: string = buildAiCocktailRecipeKey(recipe);
    if (this.favoriteBusyKey.length > 0) {
      return;
    }

    if (!(await this.hasAuthorization())) {
      promptAction.showToast({ message: '请先登录后再收藏' });
      router.pushUrl({ url: RoutePaths.LOGIN });
      return;
    }

    this.favoriteBusyKey = recipeKey;

    try {
      if (this.favoritedRecipeKeys.indexOf(recipeKey) !== -1) {
        const favoriteId: number | undefined = this.favoriteIdsByRecipeKey[recipeKey];
        if (typeof favoriteId === 'number') {
          await favoriteRepository.deleteAiCocktailById(favoriteId);
        } else {
          await favoriteRepository.deleteAiCocktailByRecipeKey(recipeKey);
        }
        this.removeFavoriteState(recipeKey);
        promptAction.showToast({ message: '已取消收藏' });
      } else {
        const result: FavoriteAiCocktailMutationResponse = await favoriteRepository.saveAiCocktail({
          recipeKey,
          name: recipe.name,
          description: recipe.description,
          materials: [...recipe.materials],
          steps: [...recipe.steps],
          prompt: this.getLatestUserPrompt(),
          source: 'ai'
        });
        this.addFavoriteState(recipeKey, result.favoriteId);
        promptAction.showToast({ message: '已加入我的收藏' });
      }
    } catch (error) {
      promptAction.showToast({ message: this.resolveErrorMessage(error, '收藏失败，请稍后再试') });
    } finally {
      if (this.favoriteBusyKey === recipeKey) {
        this.favoriteBusyKey = '';
      }
    }
  }

  private hasSubmittedRequest(): boolean {
    return this.getLatestUserMessageIndex() !== -1;
  }

  private shouldShowResultLayout(): boolean {
    return !this.forceInputMode && (this.hasSubmittedRequest() || this.errorMessage.length > 0);
  }

  @Builder
  private buildFloatingAccent(width: number, height: number, color: string, opacity: number, x: number, y: number) {
    Column()
      .width(width)
      .height(height)
      .borderRadius(width / 2)
      .backgroundColor(color)
      .opacity(opacity)
      .position({ x, y });
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('AI COCKTAIL')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.aiPrimary)
          .letterSpacing(1.8);

        Text(this.shouldShowResultLayout() ? '为你定制的鸡尾酒' : '描述你现在想喝的口味')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Button(this.getCurrentRecipes().length > 0 ? '再调整一轮' : '生成结果后可继续调整')
        .height(40)
        .enabled(this.getCurrentRecipes().length > 0 && !this.isLoading)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor((this.getCurrentRecipes().length > 0 && !this.isLoading) ? UiTokens.textAccent : UiTokens.textTertiary)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          this.isShowRefineSheet = true;
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildInitialLayout() {
    Column({ space: 18 }) {
      Column({ space: 10 }) {
        Text('输入一句偏好，AI 会先给你几种可执行方案，再继续结合材料站和酒谱库细化。')
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(20)
          .textAlign(TextAlign.Center);
      }
      .width('100%');

      Column() {
        AICocktailHeroSection({
          title: '今晚想喝点什么？',
          description: '写下口味、场景或心情即可。',
          inputText: this.inputText,
          isLoading: this.isLoading,
          promptSamples: this.quickPromptSamples,
          onInputChange: (value: string) => {
            this.updateInputText(value);
          },
          onSubmit: () => {
            void this.sendMessage();
          },
          onSelectSample: (sample: string) => {
            this.applyPromptSample(sample);
          }
        });
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 18, right: 18, top: 20, bottom: 20 })
      .backgroundColor(UiTokens.surfaceWarm)
      .borderRadius(28)
      .border({ width: 1, color: UiTokens.borderWarm })
      .shadow({ radius: 18, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
    }
    .width('100%')
    .layoutWeight(1);
  }

  @Builder
  private buildResultLayout() {
    Column() {
      AICocktailResultsSection({
        prompt: this.getLatestUserPrompt(),
        isLoading: this.isLoading,
        errorMessage: this.errorMessage,
        recipes: this.getCurrentRecipes(),
        loadingCardKeys: this.loadingCardKeys,
        favoritedRecipeKeys: this.favoritedRecipeKeys,
        favoriteBusy: this.favoriteBusyKey.length > 0,
        onToggleFavorite: (recipe: AiGenerateRecipeResponse) => {
          void this.handleToggleFavorite(recipe);
        }
      })
        .layoutWeight(1);
    }
    .width('100%')
    .layoutWeight(1);
  }

  @Builder
  private buildRefineSheetOverlay() {
    Column() {
      AICocktailRefineSheet({
        inputText: this.inputText,
        isLoading: this.isLoading,
        promptSamples: this.quickPromptSamples,
        onClose: () => {
          this.isShowRefineSheet = false;
        },
        onInputChange: (value: string) => {
          this.updateInputText(value);
        },
        onSelectSample: (sample: string) => {
          this.applyPromptSample(sample);
        },
        onSubmit: () => {
          void this.sendMessageFromSheet();
        }
      });
    }
    .width('100%')
    .padding({ left: 14, right: 14, bottom: 18 })
    .align(Alignment.Bottom);
  }

  @Builder
  private buildEmptyPromptOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(UiTokens.overlayMask);

      Column({ space: 16 }) {
        Text('先告诉我你想喝什么吧')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textPrimary)
          .textAlign(TextAlign.Center);

        Button('OK')
          .width('100%')
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.aiPrimary)
          .borderRadius(16)
          .onClick(() => {
            this.isShowEmptyPromptOverlay = false;
            this.isShowRefineSheet = false;
            this.forceInputMode = true;
          });
      }
      .width('78%')
      .constraintSize({ maxWidth: 420 })
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(24)
      .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%')
    .height('100%');
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.5], [UiTokens.pageGradientEnd, 1.0]]
        });

      this.buildFloatingAccent(260, 260, UiTokens.pageAccentBlue, 0.24, -72, 58);
      this.buildFloatingAccent(220, 220, UiTokens.pageAccentMint, 0.18, 250, 420);
      this.buildFloatingAccent(160, 160, UiTokens.accentWarmSoft, 0.24, 210, 96);

      Column({ space: 18 }) {
        this.buildTopBar();

        if (this.shouldShowResultLayout()) {
          this.buildResultLayout();
        } else {
          this.buildInitialLayout();
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 10, right: 10, top: 20, bottom: 10 })
      .backgroundColor(UiTokens.pageBackground);

      if (this.isShowRefineSheet) {
        this.buildRefineSheetOverlay();
      }

      if (this.isShowEmptyPromptOverlay) {
        this.buildEmptyPromptOverlay();
      }
    }
    .width('100%')
    .height('100%');
  }
}
