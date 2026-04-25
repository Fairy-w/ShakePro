import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { HttpRequestError, toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { communityRepository } from '../../community/repository/CommunityRepository';
import {
  CommunityPostPageDto,
  toCommunityPostCardModel
} from '../../community/model/CommunityApiModels';
import { ProfilePostPreviewItem } from '../model/ProfileMockData';

@Entry({ routeName: 'ProfilePostsPage' })
@Component
export struct ProfilePostsPage {
  @State private posts: ProfilePostPreviewItem[] = [];
  @State private isLoading: boolean = true;
  @State private isAuthorized: boolean = true;
  @State private errorMessage: string = '';

  private readonly pageSize: number = 10;

  aboutToAppear(): void {
    void this.loadPosts();
  }

  private showActionToast(message: string): void {
    promptAction.showToast({ message });
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private mapProfilePosts(response: CommunityPostPageDto): ProfilePostPreviewItem[] {
    const result: ProfilePostPreviewItem[] = [];
    const sourceList = Array.isArray(response.list) ? response.list : [];
    for (let index: number = 0; index < sourceList.length; index += 1) {
      const mappedCard = toCommunityPostCardModel(sourceList[index], index);
      result.push({
        id: mappedCard.id,
        title: mappedCard.title,
        summary: mappedCard.summary,
        publishText: mappedCard.publishText,
        statusText: '已发布'
      } as ProfilePostPreviewItem);
    }
    return result;
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    if (error instanceof HttpRequestError) {
      return toUserFacingMessage(error.message, fallbackMessage);
    }
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private isUnauthorizedError(error: Object): boolean {
    if (!(error instanceof HttpRequestError)) {
      return false;
    }
    return error.statusCode === 401 || error.code === 401 || error.code === 40100;
  }

  private async loadPosts(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      await sessionStore.init(this.getHostContext());
      const authorization: string = await sessionStore.getAuthorizationValue();
      this.isAuthorized = authorization.trim().length > 0;
      if (!this.isAuthorized) {
        this.posts = [];
        return;
      }

      const response: CommunityPostPageDto = await communityRepository.getMyCommunityPosts({
        pageNo: 1,
        pageSize: this.pageSize
      });
      this.posts = this.mapProfilePosts(response);
    } catch (error) {
      this.posts = [];
      if (this.isUnauthorizedError(error as Object)) {
        this.isAuthorized = false;
        this.errorMessage = '';
        return;
      }
      this.errorMessage = this.resolveErrorMessage(error as Object, '加载帖子失败，请稍后再试');
    } finally {
      this.isLoading = false;
    }
  }

  private openPostDetail(postId: string): void {
    if (postId.trim().length === 0) {
      this.showActionToast('页面信息异常，请返回后重试');
      return;
    }
    router.pushUrl({
      url: 'features/community/pages/CommunityPostDetailPage',
      params: {
        postId
      }
    }, 3000);
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('我的帖子')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('集中查看你已发布的社区内容。')
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
  private buildPostCard(item: ProfilePostPreviewItem) {
    Column({ space: 10 }) {
      Row() {
        Text(item.statusText)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textAccent)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(UiTokens.primarySoft)
          .borderRadius(12);

        Blank();

        Text(item.publishText)
          .fontSize(11)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%');

      Text(item.title)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(25);

      Text(item.summary)
        .width('100%')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(19)
        .maxLines(3);
    }
    .width('100%')
    .padding(18)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 12, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 6 })
    .onClick(() => {
      this.openPostDetail(item.id);
    });
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(24)
        .height(24)
        .color(UiTokens.aiPrimary);

      Text('正在同步你的帖子...')
        .fontSize(13)
        .fontColor(UiTokens.textSecondary);
    }
    .width('100%')
    .padding({ top: 36, bottom: 36 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildUnauthorizedState() {
    Column({ space: 12 }) {
      Text('登录后才能查看我的帖子')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      Text('请先登录账号，再查看你在社区发布的内容。')
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      Button('去登录')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textInverse)
        .backgroundColor(UiTokens.brandStrong)
        .borderRadius(16)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'features/auth/pages/LoginPage' }, 3000);
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildErrorState() {
    Column({ space: 12 }) {
      Text('帖子加载失败')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text(this.errorMessage)
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      Button('重新加载')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.surfaceWarm)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          void this.loadPosts();
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 10 }) {
      Text('还没有已发布的帖子')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      Text('去社区发布一条笔记后，这里会自动展示。')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(18)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildContent() {
    if (this.isLoading) {
      this.buildLoadingState();
    } else if (!this.isAuthorized) {
      this.buildUnauthorizedState();
    } else if (this.errorMessage.length > 0) {
      this.buildErrorState();
    } else if (this.posts.length === 0) {
      this.buildEmptyState();
    } else {
      Column({ space: 16 }) {
        ForEach(this.posts, (item: ProfilePostPreviewItem) => {
          this.buildPostCard(item);
        }, (item: ProfilePostPreviewItem) => item.id);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
  }

  build() {
    Column({ space: 16 }) {
      this.buildTopBar();
      Scroll() {
        Column({ space: 16 }) {
          this.buildContent();
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 28 })
    .backgroundColor(UiTokens.pageBackground)
    .alignItems(HorizontalAlign.Start);
  }
}
